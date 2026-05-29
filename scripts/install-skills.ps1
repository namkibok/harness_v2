<#
.SYNOPSIS
  Install only the skills listed in .harness/skills.lock.yaml (sparse fetch from cursor-skills).

.DESCRIPTION
  Does NOT copy the full catalog to ~/.cursor/skills/.
  Uses git sparse-checkout against https://github.com/namkibok/cursor-skills
  then Junction (default) or Copy into the project .cursor/skills/.

.EXAMPLE
  # Team developer — project has .harness/skills.lock.yaml
  .\scripts\install-skills.ps1

.EXAMPLE
  # Harness designer — ad-hoc skills into cache only
  .\scripts\install-skills.ps1 -Skills typescript-expert,webapp-testing -TargetDir .cursor\skills
#>
[CmdletBinding()]
param(
    [string]$LockFile = ".harness\skills.lock.yaml",
    [string[]]$Skills = @(),
    [string]$TargetDir = ".cursor\skills",
    [ValidateSet("Junction", "Copy")]
    [string]$Mode = "Junction",
    [string]$CacheDir = "$env:LOCALAPPDATA\harness\cursor-skills-sparse",
    [string]$CatalogRepo = "https://github.com/namkibok/cursor-skills.git",
    [switch]$Refresh
)

$ErrorActionPreference = "Stop"

function Get-SkillsFromLockFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        throw "Lock file not found: $Path"
    }
    $list = @()
    $inBlock = $false
    foreach ($line in Get-Content $Path -Encoding UTF8) {
        $trim = $line.Trim()
        if ($trim -match '^skills\s*:') { $inBlock = $true; continue }
        if ($inBlock -and $trim -match '^-\s+(\S+)') { $list += $Matches[1]; continue }
        if ($inBlock -and $trim -ne '' -and $trim -notmatch '^#' -and $trim -notmatch '^-') {
            $inBlock = $false
        }
    }
    if ($list.Count -eq 0) {
        throw "No skills listed under 'skills:' in $Path"
    }
    return $list
}

function Ensure-SparseCatalog {
    param([string[]]$SkillIds, [string]$Dir, [string]$Repo, [switch]$ForceRefresh)

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git is required for sparse catalog fetch. Install Git for Windows."
    }

    $needClone = -not (Test-Path (Join-Path $Dir ".git"))
    if ($needClone -or $ForceRefresh) {
        if (Test-Path $Dir) {
            Remove-Item $Dir -Recurse -Force
        }
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
        Write-Host "Cloning catalog (sparse): $Repo"
        git clone --filter=blob:none --sparse $Repo $Dir
        if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
    }

    Push-Location $Dir
    try {
        git sparse-checkout init --cone
        if ($LASTEXITCODE -ne 0) { throw "git sparse-checkout init failed" }
        $dirs = @($SkillIds)
        Write-Host "Sparse-checkout: $($SkillIds -join ', ')"
        git sparse-checkout set @dirs
        if ($LASTEXITCODE -ne 0) { throw "git sparse-checkout set failed" }
        git pull --ff-only 2>$null
    }
    finally {
        Pop-Location
    }
}

function Install-SkillToTarget {
    param(
        [string]$SkillId,
        [string]$SourceRoot,
        [string]$DestRoot,
        [string]$InstallMode
    )
    $src = Join-Path $SourceRoot $SkillId
    $dest = Join-Path $DestRoot $SkillId

    if (-not (Test-Path (Join-Path $src "SKILL.md"))) {
        throw "Missing SKILL.md in catalog for skill: $SkillId ($src)"
    }

    New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null

    if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Remove-Item $dest -Force
        }
        else {
            Remove-Item $dest -Recurse -Force
        }
    }

    if ($InstallMode -eq "Junction") {
        New-Item -ItemType Junction -Path $dest -Target $src | Out-Null
        Write-Host "  Junction: $dest -> $src"
    }
    else {
        Copy-Item -Recurse -Force $src $dest
        Write-Host "  Copied: $dest"
    }
}

# Resolve skill list
$skillList = @()
if ($Skills.Count -gt 0) {
    $skillList = $Skills | ForEach-Object {
        $_ -split ',' | ForEach-Object { $_.Trim().Trim('"').Trim("'") }
    } | Where-Object { $_ }
}
elseif (Test-Path $LockFile) {
    $skillList = Get-SkillsFromLockFile -Path $LockFile
}
else {
    throw @"
No skills to install. Provide either:
  -LockFile .harness\skills.lock.yaml
  -Skills skill-a,skill-b
"@
}

$skillList = @($skillList | Select-Object -Unique)
Write-Host "Installing $($skillList.Count) skill(s) -> $TargetDir ($Mode)"

Ensure-SparseCatalog -SkillIds $skillList -Dir $CacheDir -Repo $CatalogRepo -ForceRefresh:$Refresh

foreach ($id in $skillList) {
    Install-SkillToTarget -SkillId $id -SourceRoot $CacheDir -DestRoot $TargetDir -InstallMode $Mode
}

Write-Host "Done. Cache: $CacheDir"
