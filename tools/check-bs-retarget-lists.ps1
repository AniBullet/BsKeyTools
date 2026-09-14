$ErrorActionPreference = "Continue"

$repoRoot = Split-Path -Parent $PSScriptRoot
$presetDir = Join-Path $repoRoot "_BsKeyTools/Scripts/BulletScripts/Res/BsMappingList"
$failed = $false

if (-not (Test-Path -LiteralPath $presetDir)) {
    Write-Error "Preset directory not found: $presetDir"
    exit 1
}

$files = Get-ChildItem -LiteralPath $presetDir -Filter "*.list" -File

foreach ($file in $files) {
    $lines = Get-Content -LiteralPath $file.FullName -Encoding UTF8
    $name = $file.Name
    $isV2 = ($lines.Count -gt 0 -and $lines[0] -eq "v2")

    if ($isV2) {
        if ($lines.Count -lt 77) {
            Write-Error "${name}: v2 list must have at least 77 lines, got $($lines.Count)"
            $failed = $true
        }
        $hipsLine = if ($lines.Count -ge 2) { $lines[1] } else { "<missing>" }
        $rootLine = if ($lines.Count -ge 71) { $lines[70] } else { "<missing>" }
    }
    else {
        if ($lines.Count -lt 69) {
            Write-Error "${name}: legacy list must have at least 69 lines, got $($lines.Count)"
            $failed = $true
        }
        $hipsLine = if ($lines.Count -ge 1) { $lines[0] } else { "<missing>" }
        $rootLine = if ($lines.Count -ge 70) { $lines[69] } else { "<missing>" }
    }

    if ($rootLine -eq "<missing>") {
        Write-Warning "${name}: no Root line; loader must infer Root"
    }
    elseif ($rootLine -eq "~undefined~") {
        Write-Warning "${name}: Root is undefined; runtime must infer Root or block unsafe steps"
    }
    elseif ($rootLine -eq $hipsLine) {
        Write-Error "${name}: Root must not use the same node as mapped Hips: $rootLine"
        $failed = $true
    }
}

if ($failed) {
    exit 1
}

Write-Host "BsRetarget list check completed."
