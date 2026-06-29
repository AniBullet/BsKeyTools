$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $repoRoot "_BsKeyTools/Scripts/BulletScripts/BsRetargetTools.ms"

if (-not (Test-Path -LiteralPath $scriptPath)) {
    Write-Error "Script not found: $scriptPath"
    exit 1
}

$bytes = [IO.File]::ReadAllBytes($scriptPath)
$text = [Text.Encoding]::UTF8.GetString($bytes)

if ($bytes -contains 0) {
    Write-Error "Script contains NUL bytes; it still looks like UTF-16/binary."
    exit 1
}


$requiredMarkers = @(
    "struct BsMappingState",
    "fn fnResolveRootBone",
    "fn fnResolveAndSetRoot",
    "fn fnBuildMappingState",
    "fn fnLoadMappingListAndRefresh",
    "fn fnGetExistingBipedRoot",
    "fn fnShowBlockedAction",
    "fn fnValidateRetargetInputs",
    "fn fnTryApplyDetectedPreset",
    "local createdBipRoot",
    "local rootBone",
    "local numFinger",
    "local copycol",
    "local icpmxbipcopy",
    "out_file == undefined",
    "canCreateMapping",
    "canReplaceToBiped",
    "bipRootMotion == undefined"
)

foreach ($marker in $requiredMarkers) {
    if (-not $text.Contains($marker)) {
        Write-Error "Required marker missing: $marker"
        exit 1
    }
}

$orderRules = @(
    @("fn fnShowBlockedAction", "fn fnLoadMappingList"),
    @("fn fnSetListItem", "fn fnLoadMappingList"),
    @("fn fnEnsureMappingListLengths", "fn fnSetListItem"),
    @("fn fnEnsureMappingListLengths", "fn fnGetListItem"),
    @("fn fnGetListItem", "fn fnUpdateStatusBar"),
    @("fn fnUpdateStatusBar", "fn fnLoadMappingListAndRefresh"),
    @("fn GetBipedNode", "fn fnGetExistingBipedRoot")
)

foreach ($rule in $orderRules) {
    $before = $rule[0]
    $after = $rule[1]
    $beforeIndex = $text.IndexOf($before)
    $afterIndex = $text.IndexOf($after)

    if ($beforeIndex -lt 0 -or $afterIndex -lt 0) {
        Write-Error "Order marker missing: $before -> $after"
        exit 1
    }

    if ($beforeIndex -gt $afterIndex) {
        Write-Error "Function order invalid: '$before' must appear before '$after'"
        exit 1
    }
}

Write-Host "BsRetarget script check completed."
