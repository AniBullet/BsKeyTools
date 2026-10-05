$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$canonical = Join-Path $repoRoot "AGENTS.md"
$mirrors = @(
    (Join-Path $repoRoot "CLAUDE.md"),
    (Join-Path $repoRoot ".cursor/rules/agents.mdc")
)

if (-not (Test-Path -LiteralPath $canonical)) {
    Write-Error "Missing canonical rules file: $canonical"
    exit 1
}

$canonicalBytes = [IO.File]::ReadAllBytes($canonical)

if ($canonicalBytes -contains 0) {
    Write-Error "AGENTS.md contains NUL bytes."
    exit 1
}

if ($canonicalBytes.Length -ge 3 -and $canonicalBytes[0] -eq 0xEF -and $canonicalBytes[1] -eq 0xBB -and $canonicalBytes[2] -eq 0xBF) {
    Write-Error "AGENTS.md has a UTF-8 BOM; expected UTF-8 without BOM."
    exit 1
}

try {
    $canonicalText = (New-Object System.Text.UTF8Encoding($false, $true)).GetString($canonicalBytes)
} catch {
    Write-Error "AGENTS.md is not valid UTF-8: $($_.Exception.Message)"
    exit 1
}

# .gitattributes checks out *.md with eol=lf
if ($canonicalText.Contains("`r")) {
    Write-Error "AGENTS.md contains CR characters; expected LF line endings (see .gitattributes)."
    exit 1
}

$requiredMarkers = @(
    "Repository Agent Rules",
    "alwaysApply: true",
    "MaxScript",
    "tools/check-bs-retarget-script.ps1",
    "docs/BsRetargetTools-validation-checklist.md"
)

foreach ($marker in $requiredMarkers) {
    if (-not $canonicalText.Contains($marker)) {
        Write-Error "Required marker missing from AGENTS.md: $marker"
        exit 1
    }
}

$fsutil = Get-Command fsutil.exe -ErrorAction SilentlyContinue
$hardlinkNames = $null
if ($fsutil) {
    $hardlinkOutput = & $fsutil.Source hardlink list $canonical 2>&1
    if ($LASTEXITCODE -eq 0) {
        $hardlinkNames = @($hardlinkOutput | ForEach-Object { ([string]$_).Trim().Replace('/', '\').ToLowerInvariant() })
    } else {
        Write-Warning "fsutil hardlink list failed; hardlink check skipped: $hardlinkOutput"
    }
} else {
    Write-Warning "fsutil.exe not found; hardlink check skipped."
}

foreach ($mirror in $mirrors) {
    if (-not (Test-Path -LiteralPath $mirror)) {
        Write-Error "Missing mirror rules file: $mirror"
        exit 1
    }

    if ($null -ne $hardlinkNames) {
        $mirrorFull = [IO.Path]::GetFullPath($mirror).Replace('/', '\')
        $mirrorNoDrive = $mirrorFull.Substring([IO.Path]::GetPathRoot($mirrorFull).Length - 1).ToLowerInvariant()
        if ($hardlinkNames -notcontains $mirrorNoDrive) {
            Write-Error "Mirror is not a hardlink of AGENTS.md: $mirror (recreate: Remove-Item '$mirror'; New-Item -ItemType HardLink -Path '$mirror' -Target '$canonical')"
            exit 1
        }
    }

    $mirrorBytes = [IO.File]::ReadAllBytes($mirror)
    if ($mirrorBytes.Length -ne $canonicalBytes.Length) {
        Write-Error "Mirror length differs from AGENTS.md: $mirror"
        exit 1
    }

    for ($i = 0; $i -lt $canonicalBytes.Length; $i++) {
        if ($canonicalBytes[$i] -ne $mirrorBytes[$i]) {
            Write-Error "Mirror content differs from AGENTS.md: $mirror"
            exit 1
        }
    }
}

Write-Host "Agent rules check completed."
