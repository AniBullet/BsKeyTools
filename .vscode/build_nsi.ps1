# build_nsi.ps1 - 自动查找/安装 makensis 并编译指定 .nsi 文件
# 用法:
#   .\build_nsi.ps1 -NsiFile "path\to\script.nsi"   # 指定文件
#   .\build_nsi.ps1                                  # 自动扫描项目目录，选择后编译
param(
    [Parameter(Mandatory = $false)]
    [string]$NsiFile
)

# 无参数时：扫描脚本所在目录的上级目录里的 .nsi 文件，让用户选择
if (-not $NsiFile) {
    $searchRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    # 先搜 <workspace>/_BsKeyTools/，再搜 workspace 根
    $candidates = @(Get-ChildItem -Path (Join-Path (Split-Path $PSScriptRoot -Parent) '_BsKeyTools') `
                        -Filter '*.nsi' -ErrorAction SilentlyContinue) +
                  @(Get-ChildItem -Path (Split-Path $PSScriptRoot -Parent) `
                        -Filter '*.nsi' -Depth 2 -ErrorAction SilentlyContinue)
    $candidates = $candidates | Select-Object -Unique

    if ($candidates.Count -eq 0) {
        Write-Host "No .nsi files found. Please pass -NsiFile explicitly." -ForegroundColor Red
        exit 1
    }
    if ($candidates.Count -eq 1) {
        $NsiFile = $candidates[0].FullName
        Write-Host "Auto-selected: $NsiFile" -ForegroundColor Cyan
    } else {
        Write-Host "Select a .nsi file to build:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $candidates.Count; $i++) {
            Write-Host "  [$($i+1)] $($candidates[$i].Name)"
        }
        $choice = Read-Host "Enter number (1-$($candidates.Count))"
        $idx = [int]$choice - 1
        if ($idx -lt 0 -or $idx -ge $candidates.Count) {
            Write-Host "Invalid choice." -ForegroundColor Red; exit 1
        }
        $NsiFile = $candidates[$idx].FullName
    }
}

function Find-Makensis {
    # 1. PATH 里直接有
    if (Get-Command makensis -ErrorAction SilentlyContinue) {
        return 'makensis'
    }
    # 2. 标准 x86 安装路径
    $x86 = "${env:ProgramFiles(x86)}\NSIS\makensis.exe"
    if (Test-Path $x86) { return $x86 }
    # 3. 64-bit 安装路径
    $x64 = "${env:ProgramFiles}\NSIS\makensis.exe"
    if (Test-Path $x64) { return $x64 }
    # 4. 注册表查询
    try {
        $regPath = (Get-ItemProperty 'HKLM:\SOFTWARE\NSIS' -ErrorAction Stop).'(default)'
        $regExe  = Join-Path $regPath 'makensis.exe'
        if (Test-Path $regExe) { return $regExe }
    } catch {}
    return $null
}

function Install-NSIS {
    Write-Host ""
    Write-Host "NSIS not found. Attempting auto-install..." -ForegroundColor Yellow

    # 方式一：winget（Windows 10 1809+ 自带）
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "-> Trying winget install NSIS.NSIS ..." -ForegroundColor Cyan
        winget install --id NSIS.NSIS -e --silent `
            --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            # 刷新当前会话 PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                        [System.Environment]::GetEnvironmentVariable('Path', 'User')
            Write-Host "NSIS installed via winget." -ForegroundColor Green
            return $true
        }
        Write-Host "winget install failed (exit $LASTEXITCODE), trying next..." -ForegroundColor Yellow
    }

    # 方式二：Chocolatey
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "-> Trying choco install nsis ..." -ForegroundColor Cyan
        choco install nsis -y
        if ($LASTEXITCODE -eq 0) {
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                        [System.Environment]::GetEnvironmentVariable('Path', 'User')
            Write-Host "NSIS installed via Chocolatey." -ForegroundColor Green
            return $true
        }
        Write-Host "choco install failed (exit $LASTEXITCODE)." -ForegroundColor Yellow
    }

    # 两种方式都失败
    Write-Host ""
    Write-Host "Auto-install failed. Please install NSIS manually:" -ForegroundColor Red
    Write-Host "  https://nsis.sourceforge.io/Download" -ForegroundColor Yellow
    Write-Host "or run:  winget install NSIS.NSIS" -ForegroundColor Yellow
    return $false
}

# ── 主流程 ──────────────────────────────────────────────────────────────────
$makensis = Find-Makensis

if (-not $makensis) {
    if (-not (Install-NSIS)) { exit 1 }
    # 安装完再找一次
    $makensis = Find-Makensis
    if (-not $makensis) {
        Write-Host "makensis still not found after install. Please restart terminal and try again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Using:    $makensis" -ForegroundColor Cyan
Write-Host "Building: $NsiFile"  -ForegroundColor Cyan
Write-Host ""

& $makensis $NsiFile
exit $LASTEXITCODE
