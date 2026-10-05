# run_maxscript.ps1 - 通过 MXSPyCOM 把 MaxScript 文件送进 3ds Max 执行
# 用法:
#   .\run_maxscript.ps1 -ScriptFile "path\to\script.ms"
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptFile
)

if (-not (Test-Path $ScriptFile)) {
    Write-Host "Script file not found: $ScriptFile" -ForegroundColor Red
    exit 1
}

function Find-MXSPyCOM {
    # 1. 环境变量（由 VS Code 用户设置 bskeytools.mxspycomPath 传入）
    if ($env:BSKEYTOOLS_MXSPYCOM_PATH -and (Test-Path $env:BSKEYTOOLS_MXSPYCOM_PATH)) {
        return $env:BSKEYTOOLS_MXSPYCOM_PATH
    }

    # 2. PATH
    $inPath = Get-Command MXSPyCOM.exe -ErrorAction SilentlyContinue
    if ($inPath) { return $inPath.Source }

    # 3. 3ds Max 常见安装目录
    $roots = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ }
    foreach ($root in $roots) {
        $maxDirs = @(Get-ChildItem -Path $root -Filter '3ds Max *' -Directory -ErrorAction SilentlyContinue) |
                   Sort-Object Name -Descending
        foreach ($d in $maxDirs) {
            $candidate = Join-Path $d.FullName 'MXSPyCOM.exe'
            if (Test-Path $candidate) { return $candidate }
        }
    }

    # 4. Autodesk 根目录下递归一层
    foreach ($root in $roots) {
        $autoDesk = Join-Path $root 'Autodesk'
        if (Test-Path $autoDesk) {
            $found = Get-ChildItem -Path $autoDesk -Filter 'MXSPyCOM.exe' -Recurse -Depth 2 -ErrorAction SilentlyContinue |
                     Select-Object -First 1
            if ($found) { return $found.FullName }
        }
    }

    # 5. 各盘根目录下名含 MXSPyCOM 的文件夹（如 D:\MXSPyCOM\MXSPyCOM.exe）
    $drives = (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue).Root
    foreach ($drive in $drives) {
        $candidate = Join-Path $drive 'MXSPyCOM\MXSPyCOM.exe'
        if (Test-Path $candidate) { return $candidate }
    }

    return $null
}

# ── 主流程 ──────────────────────────────────────────────────────────────────
$mxspycom = Find-MXSPyCOM

if (-not $mxspycom) {
    Write-Host "MXSPyCOM.exe not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "  1. Add MXSPyCOM.exe to PATH"
    Write-Host "  2. In VS Code / Cursor user settings, set:"
    Write-Host "       `"bskeytools.mxspycomPath`": `"C:\\path\\to\\MXSPyCOM.exe`""
    exit 1
}

$resolvedScript = (Resolve-Path $ScriptFile).Path
& $mxspycom -s $resolvedScript
exit $LASTEXITCODE
