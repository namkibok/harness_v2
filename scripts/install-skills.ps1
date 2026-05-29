<#
.SYNOPSIS
  Install skills from .harness/skills.lock.yaml via ant-skills catalog (local or GitHub sparse).

.DESCRIPTION
  Catalog resolution (first match):
    1. -CatalogPath or HARNESS_SKILL_CATALOG
    2. Local default: E:\workspace\skills\antigravity
    3. Sparse clone: https://github.com/namkibok/ant-skills.git

  Does NOT copy the full catalog to ~/.gemini/antigravity/skills/.
#>
[CmdletBinding()]
param(
    [string]$LockFile = ".harness\skills.lock.yaml",
    [string[]]$Skills = @(),
    [string]$TargetDir = ".agent\skills",
    [ValidateSet("Junction", "Copy")]
    [string]$Mode = "Junction",
    [string]$CatalogPath = "",
    [string]$CatalogRepo = "https://github.com/namkibok/ant-skills.git",
    [string]$CacheDir = "$env:LOCALAPPDATA\harness\ant-skills-sparse",
    [switch]$Refresh,
    [switch]$ForceRemote
)

$ErrorActionPreference = "Stop"

$DefaultCatalogLocal = "E:\workspace\skills\antigravity"

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

function Get-CatalogPathCandidates {
    param([string]$Explicit)
    $paths = @()
    if ($Explicit) { $paths += $Explicit }
    if ($env:HARNESS_SKILL_CATALOG) { $paths += $env:HARNESS_SKILL_CATALOG }
    $paths += $DefaultCatalogLocal
    return @($paths | Where-Object { $_ } | Select-Object -Unique)
}

function Ensure-SparseCatalog {
    param([string[]]$SkillIds, [string]$Dir, [string]$Repo, [switch]$ForceRefresh)

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git is required for remote catalog sparse fetch. Install Git for Windows or clone ant-skills locally."
    }

    $needClone = -not (Test-Path (Join-Path $Dir ".git"))
    if ($needClone -or $ForceRefresh) {
        if (Test-Path $Dir) {
            Remove-Item $Dir -Recurse -Force
        }
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
        Write-Host "Cloning ant-skills (sparse): $Repo"
        git clone --filter=blob:none --sparse $Repo $Dir
        if ($LASTEXITCODE -ne 0) { throw "git clone failed: $Repo" }
    }

    Push-Location $Dir
    try {
        git sparse-checkout init --cone
        if ($LASTEXITCODE -ne 0) { throw "git sparse-checkout init failed" }
        Write-Host "Sparse-checkout: $($SkillIds -join ', ')"
        git sparse-checkout set @SkillIds
        if ($LASTEXITCODE -ne 0) { throw "git sparse-checkout set failed" }
        git pull --ff-only 2>$null
    }
    finally {
        Pop-Location
    }
}

function Resolve-CatalogRoot {
    param(
        [string[]]$SkillIds,
        [string]$ExplicitPath,
        [string]$Repo,
        [string]$SparseDir,
        [switch]$ForceRemote,
        [switch]$ForceRefresh
    )

    if (-not $ForceRemote) {
        foreach ($p in (Get-CatalogPathCandidates -Explicit $ExplicitPath)) {
            if ((Test-Path $p) -and -not (Test-Path (Join-Path $p ".git"))) {
                return @{ Root = (Resolve-Path $p).Path; Source = "local"; Path = $p }
            }
        }
    }

    Ensure-SparseCatalog -SkillIds $SkillIds -Dir $SparseDir -Repo $Repo -ForceRefresh:$ForceRefresh
    return @{ Root = $SparseDir; Source = "sparse"; Path = $SparseDir }
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

$resolved = Resolve-CatalogRoot -SkillIds $skillList -ExplicitPath $CatalogPath -Repo $CatalogRepo `
    -SparseDir $CacheDir -ForceRemote:$ForceRemote -ForceRefresh:$Refresh
$catalogRoot = $resolved.Root
Write-Host "Catalog [$($resolved.Source)]: $catalogRoot"

foreach ($id in $skillList) {
    Install-SkillToTarget -SkillId $id -SourceRoot $catalogRoot -DestRoot $TargetDir -InstallMode $Mode
}

Write-Host "Done. Catalog: $catalogRoot ($($resolved.Source))"
