<#
.SYNOPSIS
  Resolve skill name(s) from natural language and install from ant-skills (GitHub).
#>
[CmdletBinding()]
param(
    [string]$Query = "",
    [string[]]$SkillIds = @(),
    [string]$ProjectRoot = ".",
    [string]$TargetDir = ".agent\skills",
    [string]$LockFile = ".harness\skills.lock.yaml",
    [string]$CatalogRepo = "namkibok/ant-skills",
    [string]$CatalogBranch = "main",
    [ValidateSet("Junction", "Copy")]
    [string]$Mode = "Junction"
)

$ErrorActionPreference = "Stop"

function Get-HarnessHome {
    if ($env:HARNESS_HOME -and (Test-Path (Join-Path $env:HARNESS_HOME "scripts\install-skills.ps1"))) {
        return (Resolve-Path $env:HARNESS_HOME).Path
    }
    $here = $PSScriptRoot
    if ($here -and (Test-Path (Join-Path $here "install-skills.ps1"))) {
        return (Resolve-Path (Join-Path $here "..")).Path
    }
    throw "HARNESS_HOME is not set. Clone https://github.com/namkibok/harness_ant and set `$env:HARNESS_HOME."
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
    param([string]$SkillId, [string]$Repo, [string]$Ref)
    $uri = "https://api.github.com/repos/$Repo/contents/$SkillId/SKILL.md?ref=$Ref"
    try {
        $null = Invoke-RestMethod -Uri $uri -Headers @{ "User-Agent" = "harness-ant-provision" } -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Resolve-SkillIds {
    param(
        [string]$Text,
        [string[]]$Explicit,
        [hashtable]$Aliases,
        [string]$Repo,
        [string]$Ref
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
        if (Test-CatalogSkillExists -SkillId $resolved -Repo $Repo -Ref $Ref) {
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
$harnessRoot = Get-HarnessHome
$aliases = Get-AliasMap -HarnessRoot $harnessRoot

Push-Location $ProjectRoot
try {
    $resolved = Resolve-SkillIds -Text $Query -Explicit $SkillIds -Aliases $aliases `
        -Repo $CatalogRepo -Ref $CatalogBranch

    if ($resolved.Count -eq 0) {
        $hint = if ($Query) { "Query: $Query" } else { "SkillIds: $($SkillIds -join ', ')" }
        throw @"
No matching skills in https://github.com/$CatalogRepo
$hint

Tips:
  - Use catalog folder name (e.g. typescript-expert).
  - Browse: https://github.com/$CatalogRepo/tree/$CatalogBranch
  - Add aliases in harness_ant/skills/catalog-index.yaml
"@
    }

    Write-Host "Resolved skill(s): $($resolved -join ', ')"
    Update-LockFile -Path $LockFile -NewSkills $resolved

    $installScript = Join-Path $harnessRoot "scripts\install-skills.ps1"
    $skillArg = ($resolved -join ',')
    & $installScript -Skills $skillArg -TargetDir $TargetDir -LockFile $LockFile -Mode $Mode

    Write-Host ""
    Write-Host "Installed to: $(Resolve-Path $TargetDir -ErrorAction SilentlyContinue)"
    Write-Host "Lock file: $(Resolve-Path $LockFile -ErrorAction SilentlyContinue)"
    Write-Output ($resolved -join ",")
}
finally {
    Pop-Location
}
