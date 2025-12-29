#Requires -Version 5.1
# BsKeyTools 代码贡献一键设置脚本
# 
# 使用方法：
#   方法1：右键点击此文件 → 使用 PowerShell 运行（需要文件是 UTF-8 with BOM 编码）
#   方法2：powershell -ExecutionPolicy Bypass -File setup-contribute.ps1

# 设置控制台编码为 UTF-8（解决中文显示问题）
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $PSDefaultParameterValues['*:Encoding'] = 'utf8'
} else {
    chcp 65001 | Out-Null
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BsKeyTools 代码贡献一键设置脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Git 是否安装
Write-Host "[1/8] 检查 Git 安装..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "✓ Git 已安装: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git 未安装！请先安装 Git：" -ForegroundColor Red
    Write-Host "  https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "按任意键退出..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""

# 获取用户输入
Write-Host "[2/8] 获取配置信息..." -ForegroundColor Yellow
$githubUsername = Read-Host "请输入你的 GitHub 用户名"
if ([string]::IsNullOrWhiteSpace($githubUsername)) {
    Write-Host "✗ 用户名不能为空！" -ForegroundColor Red
    exit 1
}

$branchType = Read-Host "请输入分支类型 (feature/fix) [默认: feature]"
if ([string]::IsNullOrWhiteSpace($branchType)) {
    $branchType = "feature"
}
if ($branchType -ne "feature" -and $branchType -ne "fix") {
    Write-Host "✗ 分支类型只能是 feature 或 fix！" -ForegroundColor Red
    exit 1
}

$branchName = Read-Host "请输入分支名称 (例如: 添加新工具)"
if ([string]::IsNullOrWhiteSpace($branchName)) {
    Write-Host "✗ 分支名称不能为空！" -ForegroundColor Red
    exit 1
}

$commitMessage = Read-Host "请输入提交信息 (例如: feat: 添加了xxx功能)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    Write-Host "✗ 提交信息不能为空！" -ForegroundColor Red
    exit 1
}

$projectPath = Read-Host "请输入项目存放路径 (例如: D:\Projects) [默认: 当前目录]"
if ([string]::IsNullOrWhiteSpace($projectPath)) {
    $projectPath = Get-Location
} else {
    if (-not (Test-Path $projectPath)) {
        Write-Host "✗ 路径不存在！" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "配置信息确认：" -ForegroundColor Cyan
Write-Host "  GitHub 用户名: $githubUsername" -ForegroundColor Gray
Write-Host "  分支类型: $branchType" -ForegroundColor Gray
Write-Host "  分支名称: $branchName" -ForegroundColor Gray
Write-Host "  提交信息: $commitMessage" -ForegroundColor Gray
Write-Host "  项目路径: $projectPath" -ForegroundColor Gray
Write-Host ""
$confirm = Read-Host "确认无误? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "已取消操作。" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# 设置仓库地址
$repoUrl = "https://github.com/$githubUsername/BsKeyTools.git"
$upstreamUrl = "https://github.com/AniBullet/BsKeyTools.git"
$fullBranchName = "$branchType/$branchName"
$projectFullPath = Join-Path $projectPath "BsKeyTools"

# 检查是否已经 Clone 过
Write-Host "[3/8] 检查本地仓库..." -ForegroundColor Yellow
if (Test-Path $projectFullPath) {
    Write-Host "✓ 检测到已存在的仓库" -ForegroundColor Green
    Set-Location $projectFullPath
    
    # 检查是否是 Git 仓库
    if (Test-Path ".git") {
        Write-Host "✓ 确认是 Git 仓库" -ForegroundColor Green
        
        # 检查上游仓库是否已配置
        $remotes = git remote -v 2>&1
        if ($remotes -match "upstream") {
            Write-Host "✓ 上游仓库已配置" -ForegroundColor Green
        } else {
            Write-Host "[3.5/8] 配置上游仓库..." -ForegroundColor Yellow
            git remote add upstream $upstreamUrl 2>&1 | Out-Null
            Write-Host "✓ 上游仓库配置完成" -ForegroundColor Green
        }
    } else {
        Write-Host "✗ 目录存在但不是 Git 仓库，请删除后重试" -ForegroundColor Red
        exit 1
    }
} else {
    # Clone 仓库
    Write-Host "[3/8] Clone 仓库到本地..." -ForegroundColor Yellow
    Set-Location $projectPath
    Write-Host "  正在 Clone: $repoUrl" -ForegroundColor Gray
    
    $cloneResult = git clone $repoUrl 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Clone 失败！" -ForegroundColor Red
        Write-Host $cloneResult -ForegroundColor Red
        Write-Host ""
        Write-Host "可能的原因：" -ForegroundColor Yellow
        Write-Host "  1. 仓库地址错误或未 Fork" -ForegroundColor Gray
        Write-Host "  2. 网络连接问题" -ForegroundColor Gray
        Write-Host "  3. 权限不足" -ForegroundColor Gray
        exit 1
    }
    
    Set-Location $projectFullPath
    
    # 添加上游仓库
    Write-Host "[3.5/8] 配置上游仓库..." -ForegroundColor Yellow
    git remote add upstream $upstreamUrl 2>&1 | Out-Null
    Write-Host "✓ 上游仓库配置完成" -ForegroundColor Green
}

Write-Host ""

# 检查 Git 用户配置
Write-Host "[4/8] 检查 Git 用户配置..." -ForegroundColor Yellow
$gitUserName = git config --global user.name 2>&1
$gitUserEmail = git config --global user.email 2>&1

if ([string]::IsNullOrWhiteSpace($gitUserName) -or [string]::IsNullOrWhiteSpace($gitUserEmail)) {
    Write-Host "⚠ Git 用户信息未配置，正在配置..." -ForegroundColor Yellow
    $inputName = Read-Host "请输入你的名字"
    $inputEmail = Read-Host "请输入你的邮箱"
    
    git config --global user.name $inputName 2>&1 | Out-Null
    git config --global user.email $inputEmail 2>&1 | Out-Null
    Write-Host "✓ Git 用户信息配置完成" -ForegroundColor Green
} else {
    Write-Host "✓ Git 用户信息已配置" -ForegroundColor Green
    Write-Host "  用户名: $gitUserName" -ForegroundColor Gray
    Write-Host "  邮箱: $gitUserEmail" -ForegroundColor Gray
}

Write-Host ""

# 切换到 dev 分支并拉取最新代码
Write-Host "[5/8] 切换到 dev 分支并同步最新代码..." -ForegroundColor Yellow

# 先 fetch upstream
Write-Host "  正在同步上游仓库..." -ForegroundColor Gray
$fetchResult = git fetch upstream 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠ 无法连接上游仓库，尝试继续..." -ForegroundColor Yellow
    Write-Host "  $fetchResult" -ForegroundColor Gray
}

# 检查 upstream/dev 是否存在
$upstreamDevExists = git branch -r 2>&1 | Select-String "upstream/dev"

if ($upstreamDevExists) {
    # upstream/dev 存在，基于它创建或更新本地 dev
    $localDevExists = git branch 2>&1 | Select-String "dev"
    
    if ($localDevExists) {
        Write-Host "  切换到本地 dev 分支..." -ForegroundColor Gray
        git checkout dev 2>&1 | Out-Null
        Write-Host "  拉取上游最新代码..." -ForegroundColor Gray
        git pull upstream dev 2>&1 | Out-Null
    } else {
        Write-Host "  创建本地 dev 分支（基于 upstream/dev）..." -ForegroundColor Gray
        git checkout -b dev upstream/dev 2>&1 | Out-Null
    }
    Write-Host "✓ dev 分支同步完成" -ForegroundColor Green
} else {
    # upstream/dev 不存在，检查 origin/dev
    Write-Host "⚠ 上游仓库没有 dev 分支，检查 fork 仓库..." -ForegroundColor Yellow
    
    # fetch origin
    git fetch origin 2>&1 | Out-Null
    $originDevExists = git branch -r 2>&1 | Select-String "origin/dev"
    
    if ($originDevExists) {
        Write-Host "  从 origin/dev 创建本地分支..." -ForegroundColor Gray
        git checkout dev 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            git checkout -b dev origin/dev 2>&1 | Out-Null
        }
        Write-Host "✓ dev 分支切换完成" -ForegroundColor Green
    } else {
        # 都没有 dev 分支，从 main/master 创建
        Write-Host "⚠ 未找到 dev 分支，尝试从主分支创建..." -ForegroundColor Yellow
        
        # 检查主分支名称
        $mainBranch = "main"
        $mainExists = git branch -r 2>&1 | Select-String "origin/main"
        if (-not $mainExists) {
            $masterExists = git branch -r 2>&1 | Select-String "origin/master"
            if ($masterExists) {
                $mainBranch = "master"
            }
        }
        
        git checkout $mainBranch 2>&1 | Out-Null
        git checkout -b dev 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ 已从 $mainBranch 创建 dev 分支" -ForegroundColor Green
        } else {
            Write-Host "✗ 无法创建 dev 分支！" -ForegroundColor Red
            Write-Host ""
            Write-Host "请手动操作：" -ForegroundColor Yellow
            Write-Host "  1. 在 GitHub 上为你的 Fork 创建 dev 分支" -ForegroundColor Gray
            Write-Host "  2. 或联系仓库维护者确认分支结构" -ForegroundColor Gray
            Write-Host ""
            Write-Host "按任意键退出..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
    }
}

Write-Host ""

# 创建新分支
Write-Host "[6/8] 创建新分支: $fullBranchName" -ForegroundColor Yellow
git checkout -b $fullBranchName 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠ 分支可能已存在，尝试切换..." -ForegroundColor Yellow
    git checkout $fullBranchName 2>&1 | Out-Null
}
Write-Host "✓ 分支创建/切换完成" -ForegroundColor Green

Write-Host ""

# 提示用户修改代码
Write-Host "[7/8] 等待你修改代码..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  现在你可以修改代码了！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "项目路径: $projectFullPath" -ForegroundColor Gray
Write-Host ""
Write-Host "修改完成后，按任意键继续提交..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""

# 检查是否有修改
Write-Host "[8/8] 检查代码修改..." -ForegroundColor Yellow
$status = git status --short 2>&1
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "⚠ 没有检测到代码修改！" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "是否继续提交? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") {
        Write-Host "已取消提交。" -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "✓ 检测到以下修改：" -ForegroundColor Green
    Write-Host $status -ForegroundColor Gray
}

Write-Host ""

# 添加并提交
Write-Host "正在添加修改到暂存区..." -ForegroundColor Yellow
git add . 2>&1 | Out-Null
Write-Host "✓ 修改已添加到暂存区" -ForegroundColor Green

Write-Host ""
Write-Host "正在提交..." -ForegroundColor Yellow
$commitResult = git commit -m $commitMessage 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 提交成功" -ForegroundColor Green
} else {
    Write-Host "✗ 提交失败！" -ForegroundColor Red
    Write-Host $commitResult -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "  1. 没有修改需要提交" -ForegroundColor Gray
    Write-Host "  2. 提交信息格式错误" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# 推送到远程
Write-Host "正在推送到 GitHub..." -ForegroundColor Yellow
Write-Host "  分支: $fullBranchName" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠ 如果提示输入用户名和密码：" -ForegroundColor Yellow
Write-Host "  - 用户名: 输入你的 GitHub 用户名" -ForegroundColor Gray
Write-Host "  - 密码: 输入 Personal Access Token（不是登录密码）" -ForegroundColor Gray
Write-Host "  - Token 获取地址: https://github.com/settings/tokens" -ForegroundColor Gray
Write-Host ""

$pushResult = git push origin $fullBranchName 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✓ 推送成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # 检查是否安装了 GitHub CLI
    $ghInstalled = $false
    try {
        $ghVersion = gh --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $ghInstalled = $true
        }
    } catch {}
    
    if ($ghInstalled) {
        Write-Host "检测到 GitHub CLI，是否自动创建 Pull Request?" -ForegroundColor Yellow
        $createPR = Read-Host "创建 PR? (Y/N) [默认: Y]"
        if ([string]::IsNullOrWhiteSpace($createPR) -or $createPR -eq "Y" -or $createPR -eq "y") {
            Write-Host ""
            Write-Host "正在创建 Pull Request..." -ForegroundColor Yellow
            
            # 构建 PR 标题和描述
            $prTitle = $commitMessage
            $prBody = @"
## 📝 变更说明

$commitMessage

## ✅ 检查清单

- [ ] 代码在 3ds Max 中测试过，没有报错
- [ ] 代码风格与项目保持一致
- [ ] 没有提交临时文件或敏感信息
"@
            
            # 创建 PR（目标分支为 dev）
            $prResult = gh pr create --repo AniBullet/BsKeyTools --base dev --head "${githubUsername}:${fullBranchName}" --title $prTitle --body $prBody 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Green
                Write-Host "  ✓ Pull Request 创建成功！" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "PR 链接: $prResult" -ForegroundColor Cyan
            } else {
                Write-Host ""
                Write-Host "⚠ PR 创建失败，请手动创建" -ForegroundColor Yellow
                Write-Host $prResult -ForegroundColor Gray
                Write-Host ""
                Write-Host "手动创建步骤：" -ForegroundColor Cyan
                Write-Host "  1. 打开: https://github.com/$githubUsername/BsKeyTools" -ForegroundColor Gray
                Write-Host "  2. 点击 'Compare & pull request'" -ForegroundColor Gray
                Write-Host "  3. 确保目标分支是 'dev'" -ForegroundColor Gray
            }
        } else {
            Write-Host ""
            Write-Host "已跳过 PR 创建。你可以稍后手动创建：" -ForegroundColor Yellow
            Write-Host "  1. 打开: https://github.com/$githubUsername/BsKeyTools" -ForegroundColor Gray
            Write-Host "  2. 点击 'Compare & pull request'" -ForegroundColor Gray
            Write-Host "  3. 确保目标分支是 'dev'" -ForegroundColor Gray
        }
    } else {
        Write-Host "下一步：" -ForegroundColor Cyan
        Write-Host "  1. 打开你的仓库: https://github.com/$githubUsername/BsKeyTools" -ForegroundColor Gray
        Write-Host "  2. 点击 'Compare & pull request' 按钮" -ForegroundColor Gray
        Write-Host "  3. 确保目标分支是 'dev'" -ForegroundColor Gray
        Write-Host "  4. 填写 PR 描述并提交" -ForegroundColor Gray
        Write-Host ""
        Write-Host "💡 提示：安装 GitHub CLI 可自动创建 PR" -ForegroundColor Gray
        Write-Host "   下载地址: https://cli.github.com/" -ForegroundColor Gray
    }
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "✗ 推送失败！" -ForegroundColor Red
    Write-Host $pushResult -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "  1. 认证失败（需要 Personal Access Token）" -ForegroundColor Gray
    Write-Host "  2. 网络连接问题" -ForegroundColor Gray
    Write-Host "  3. 权限不足" -ForegroundColor Gray
    Write-Host ""
    Write-Host "你可以稍后手动推送：" -ForegroundColor Yellow
    Write-Host "  git push origin $fullBranchName" -ForegroundColor Gray
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

