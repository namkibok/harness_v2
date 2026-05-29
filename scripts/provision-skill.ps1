<#
.SYNOPSIS
  Resolve skill name(s) from natural language and install from the Antigravity skills catalog.

.EXAMPLE
  .\scripts\provision-skill.ps1 -Query "hwpx 스킬 구성해줘"
  .\scripts\provision-skill.ps1 -SkillIds hwpx,typescript-expert
#>
[CmdletBinding()]
param(
    [string]$Query = "",
    [string[]]$SkillIds = @(),
    [string]$ProjectRoot = ".",
    [string]$TargetDir = ".agent\skills",
    [string]$LockFile = ".harness\skills.lock.yaml",
    [string]$CatalogPath = "",
    [ValidateSet("Junction", "Copy")]
    [string]$Mode = "Junction"
)

$ErrorActionPreference = "Stop"

$DefaultCatalog = "E:\workspace\skills_안티그래비티\antigravity"
if (-not $CatalogPath) {
    if ($env:HARNESS_SKILL_CATALOG) { $CatalogPath = $env:HARNESS_SKILL_CATALOG }
    else { $CatalogPath = $DefaultCatalog }
}

function Get-HarnessHome {
    if ($env:HARNESS_HOME -and (Test-Path (Join-Path $env:HARNESS_HOME "scripts\install-skills.ps1"))) {
        return (Resolve-Path $env:HARNESS_HOME).Path
    }
    $here = $PSScriptRoot
    if ($here -and (Test-Path (Join-Path $here "install-skills.ps1"))) {
        return (Resolve-Path (Join-Path $here "..")).Path
    }
    throw "HARNESS_HOME is not set and provision-skill.ps1 is not inside the harness repo/scripts. Set `$env:HARNESS_HOME to the harness repo root."
}

function Get-AliasMap {
    param([string]$HarnessRoot)
    $map = @{}
    $indexPath = Join-Path $HarnessRoot "skills\catalog-index.yaml"
    if (-not (Test-Path $indexPath)) { return $map }

    $lines = Get-Content $indexPath -Encoding UTF8
    $inAliases = $false
    foreach ($line in $lines) {
        $t = $line.Trim()
        if ($t -match '^aliases\s*:') { $inAliases = $true; continue }
        if ($inAliases) {
            if ($t -match '^(\S+)\s*:\s*(\S+)') {
                $map[$Matches[1].ToLowerInvariant()] = $Matches[2]
            }
            elseif ($t -match '^[a-zA-Z0-9_-]+\s*:') {
                $inAliases = $false
            }
        }
    }
    return $map
}

function Get-CandidateIdsFromQuery {
    param([string]$Text, [hashtable]$Aliases)

    $normalized = $Text.ToLowerInvariant()
    foreach ($key in $Aliases.Keys) {
        if ($normalized -match [regex]::Escape($key)) {
            return @($Aliases[$key])
        }
    }

    $stop = '(스킬|skill|skills|구성|설치|적용|해줘|해주세요|please|install|setup|configure|add|put|the|and|와|과|을|를|이|가|좀|만)'
    $clean = [regex]::Replace($normalized, $stop, ' ')
    $tokens = $clean -split '[^\w-]+' | Where-Object { $_ -match '^[a-z][a-z0-9-]*$' -and $_.Length -ge 2 }

    return @($tokens | Select-Object -Unique)
}

function Test-CatalogSkillExists {
    param([string]$SkillId, [string]$CatalogRoot)

    $skillMd = Join-Path $CatalogRoot "$SkillId\SKILL.md"
    return Test-Path $skillMd
}

function Resolve-SkillIds {
    param(
        [string]$Text,
        [string[]]$Explicit,
        [hashtable]$Aliases,
        [string]$CatalogRoot
    )

    $candidates = @()
    if ($Explicit.Count -gt 0) {
        $candidates = $Explicit | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ }
    }
    if ($Text) {
        $candidates += Get-CandidateIdsFromQuery -Text $Text -Aliases $Aliases
    }
    $candidates = @($candidates | Select-Object -Unique)

    $found = @()
    foreach ($id in $candidates) {
        $resolved = if ($Aliases.ContainsKey($id)) { $Aliases[$id] } else { $id }
        if (Test-CatalogSkillExists -SkillId $resolved -CatalogRoot $CatalogRoot) {
            $found += $resolved
        }
    }
    return @($found | Select-Object -Unique)
}

function Update-LockFile {
    param([string]$Path, [string[]]$NewSkills)

    $existing = @()
    $header = @()
    if (Test-Path $Path) {
        $inBlock = $false
        foreach ($line in Get-Content $Path -Encoding UTF8) {
            $t = $line.Trim()
            if ($t -match '^skills\s*:') { $inBlock = $true; $header += $line; continue }
            if ($inBlock -and $t -match '^-\s+(\S+)') { $existing += $Matches[1]; continue }
            if (-not $inBlock) { $header += $line }
        }
    }
    else {
        $dir = Split-Path $Path -Parent
        if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        $header = @(
            "# Auto-maintained by provision-skill.ps1",
            "updated: $(Get-Date -Format 'yyyy-MM-dd')",
            "",
            "skills:"
        )
    }

    $merged = @($existing + $NewSkills) | Select-Object -Unique
    $body = $header
    if ($body[-1] -notmatch '^skills\s*:') {
        if ($body.Count -gt 0 -and $body[-1] -ne "") { $body += "" }
        $body += "skills:"
    }
    foreach ($s in $merged) {
        $body += "  - $s"
    }
    Set-Content -Path $Path -Value ($body -join "`n") -Encoding UTF8
}

# --- main ---
if (-not (Test-Path $CatalogPath)) {
    throw "Catalog path not found: $CatalogPath`nSet HARNESS_SKILL_CATALOG to E:\workspace\skills_안티그래비티\antigravity"
}

$harnessRoot = Get-HarnessHome
$aliases = Get-AliasMap -HarnessRoot $harnessRoot
Push-Location $ProjectRoot
try {
    $resolved = Resolve-SkillIds -Text $Query -Explicit $SkillIds -Aliases $aliases -CatalogRoot $CatalogPath

    if ($resolved.Count -eq 0) {
        $hint = if ($Query) { "Query: $Query" } else { "SkillIds: $($SkillIds -join ', ')" }
        throw @"
No matching skills in catalog ($CatalogPath).
$hint

Tips:
  - Use the catalog folder name (e.g. typescript-expert), not a display name.
  - Add aliases in skills/catalog-index.yaml under 'aliases:'.
  - If the skill is new, add it under $CatalogPath\<name>\SKILL.md first.
"@
    }

    Write-Host "Resolved skill(s): $($resolved -join ', ')"
    Update-LockFile -Path $LockFile -NewSkills $resolved

    $installScript = Join-Path $harnessRoot "scripts\install-skills.ps1"
    $skillArg = ($resolved -join ',')
    & $installScript -Skills $skillArg -TargetDir $TargetDir -LockFile $LockFile -Mode $Mode -CatalogPath $CatalogPath

    Write-Host ""
    Write-Host "Installed to: $(Resolve-Path $TargetDir -ErrorAction SilentlyContinue)"
    Write-Host "Lock file: $(Resolve-Path $LockFile -ErrorAction SilentlyContinue)"
    Write-Output ($resolved -join ",")
}
finally {
    Pop-Location
}
