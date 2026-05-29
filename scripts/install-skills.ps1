<#
.SYNOPSIS
  Install skills from .harness/skills.lock.yaml via Git sparse checkout from ant-skills.

.DESCRIPTION
  Fetches only lock-listed skills from https://github.com/namkibok/ant-skills (default).
  Cache: %LOCALAPPDATA%\harness\ant-skills-sparse (override with HARNESS_SKILL_CACHE).

  Does NOT use machine-specific local paths. All users share the same Git catalog.

.EXAMPLE
  .\scripts\install-skills.ps1

.EXAMPLE
  .\scripts\install-skills.ps1 -Skills typescript-expert,webapp-testing -TargetDir .agent\skills
#>
[CmdletBinding()]
param(
    [string]$LockFile = ".harness\skills.lock.yaml",
    [string[]]$Skills = @(),
    [string]$TargetDir = ".agent\skills",
    [ValidateSet("Junction", "Copy")]
    [string]$Mode = "Junction",
    [string]$CatalogRepo = "",
    [string]$CacheDir = "",
    [switch]$Refresh
)

$ErrorActionPreference = "Stop"

$DefaultCatalogRepo = "https://github.com/namkibok/ant-skills.git"
$DefaultCacheDir = "$env:LOCALAPPDATA\harness\ant-skills-sparse"

if (-not $CatalogRepo) {
    $CatalogRepo = if ($env:HARNESS_SKILL_REPO) { $env:HARNESS_SKILL_REPO } else { $DefaultCatalogRepo }
}
if (-not $CacheDir) {
    $CacheDir = if ($env:HARNESS_SKILL_CACHE) { $env:HARNESS_SKILL_CACHE } else { $DefaultCacheDir }
}

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
        throw "git is required. Install Git for Windows, then re-run install-skills.ps1."
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
Write-Host "Catalog repo: $CatalogRepo"
Write-Host "Sparse cache: $CacheDir"

Ensure-SparseCatalog -SkillIds $skillList -Dir $CacheDir -Repo $CatalogRepo -ForceRefresh:$Refresh

foreach ($id in $skillList) {
    Install-SkillToTarget -SkillId $id -SourceRoot $CacheDir -DestRoot $TargetDir -InstallMode $Mode
}

Write-Host "Done. Catalog cache: $CacheDir"
