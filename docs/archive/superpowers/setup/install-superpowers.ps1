# Superpowers for Cursor - Install Script

$ErrorActionPreference = "Continue"

Write-Host "========================================"
Write-Host "  Superpowers for Cursor - Install"
Write-Host "========================================"
Write-Host ""

# Config paths
$superpowersRepoSSH = "git@github.com:obra/superpowers.git"
$superpowersRepoHTTPS = "https://github.com/obra/superpowers.git"
$codexDir = Join-Path $env:USERPROFILE ".codex"
$superpowersDir = Join-Path $codexDir "superpowers"
# NOTE: Use ~/.cursor/skills/ (NOT skills-cursor/) for user-defined skills
# skills-cursor/ is reserved for Cursor's internal built-in skills
$cursorSkillsDir = Join-Path $env:USERPROFILE ".cursor\skills"
$cursorRulesDir = Join-Path $env:USERPROFILE ".cursor\rules"

# Step 1: Check Git
Write-Host "[1/5] Checking Git..."
$gitCheck = Get-Command git -ErrorAction SilentlyContinue
if ($null -eq $gitCheck) {
    Write-Host "  [X] Git not installed" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Git installed" -ForegroundColor Green

# Step 2: Create directories
Write-Host "[2/5] Creating directories..."
if (-not (Test-Path $codexDir)) { New-Item -ItemType Directory -Path $codexDir -Force | Out-Null }
if (-not (Test-Path $cursorSkillsDir)) { New-Item -ItemType Directory -Path $cursorSkillsDir -Force | Out-Null }
if (-not (Test-Path $cursorRulesDir)) { New-Item -ItemType Directory -Path $cursorRulesDir -Force | Out-Null }
Write-Host "  [OK] Directories ready" -ForegroundColor Green

# Step 3: Clone or update repo
Write-Host "[3/5] Getting Superpowers repo..."
$skillsSourcePath = Join-Path $superpowersDir "skills"

# Check if repo exists and is valid (has skills directory)
$repoValid = (Test-Path $superpowersDir) -and (Test-Path $skillsSourcePath)

if ($repoValid) {
    Write-Host "  [-] Repo exists, updating..."
    Push-Location $superpowersDir
    
    # Clean up git lock files if they exist
    $gitDir = Join-Path $superpowersDir ".git"
    if (Test-Path (Join-Path $gitDir "FETCH_HEAD.lock")) { 
        Remove-Item (Join-Path $gitDir "FETCH_HEAD.lock") -Force -ErrorAction SilentlyContinue 
    }
    if (Test-Path (Join-Path $gitDir "index.lock")) { 
        Remove-Item (Join-Path $gitDir "index.lock") -Force -ErrorAction SilentlyContinue 
    }
    
    # Get current remote URL
    $currentRemote = git remote get-url origin 2>&1
    
    # Try to pull
    $pullResult = git pull 2>&1
    $pullExitCode = $LASTEXITCODE
    
    if ($pullExitCode -eq 0) {
        Write-Host "  [OK] Updated" -ForegroundColor Green
    }
    else {
        # Pull failed, try switching remote URL
        Write-Host "  [!] Update failed, trying alternate URL..." -ForegroundColor Yellow
        
        if ($currentRemote -match "^https://") {
            # Switch to SSH
            git remote set-url origin $superpowersRepoSSH 2>&1 | Out-Null
            $pullResult = git pull 2>&1
            $pullExitCode = $LASTEXITCODE
        }
        else {
            # Switch to HTTPS
            git remote set-url origin $superpowersRepoHTTPS 2>&1 | Out-Null
            $pullResult = git pull 2>&1
            $pullExitCode = $LASTEXITCODE
        }
        
        if ($pullExitCode -eq 0) {
            Write-Host "  [OK] Updated with alternate URL" -ForegroundColor Green
        }
        else {
            Write-Host "  [!] Update failed: $pullResult" -ForegroundColor Yellow
            Write-Host "  Continuing with existing local copy..." -ForegroundColor Gray
        }
    }
    
    Pop-Location
}
else {
    # Remove incomplete/corrupted directory if exists
    if (Test-Path $superpowersDir) {
        Write-Host "  [-] Removing incomplete repo..."
        Remove-Item -Path $superpowersDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Try SSH first, fallback to HTTPS if it fails
    Write-Host "  [-] Cloning repo (trying SSH)..."
    $cloneResult = git clone --depth 1 $superpowersRepoSSH $superpowersDir 2>&1
    $cloneExitCode = $LASTEXITCODE
    
    if ($cloneExitCode -eq 0 -and (Test-Path $skillsSourcePath)) {
        Write-Host "  [OK] Cloned via SSH" -ForegroundColor Green
    }
    else {
        # SSH failed, try HTTPS
        Write-Host "  [-] SSH failed, trying HTTPS..."
        if (Test-Path $superpowersDir) {
            Remove-Item -Path $superpowersDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        $cloneResult = git clone --depth 1 $superpowersRepoHTTPS $superpowersDir 2>&1
        $cloneExitCode = $LASTEXITCODE
        
        if ($cloneExitCode -eq 0 -and (Test-Path $skillsSourcePath)) {
            Write-Host "  [OK] Cloned via HTTPS" -ForegroundColor Green
        }
        else {
            Write-Host "  [X] Clone failed: $cloneResult" -ForegroundColor Red
            Write-Host "  Please check network connection and try again."
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
}

# Step 4: Copy skills to Cursor skills directory
# Cursor requires each skill to be a DIRECT subdirectory of ~/.cursor/skills/
# NOT nested like ~/.cursor/skills/superpowers/brainstorming/
# NOTE: Must use actual file copy (NOT Junction links) - Cursor cannot scan Junction links properly
Write-Host "[4/5] Installing skills..."

$skillDirs = Get-ChildItem $skillsSourcePath -Directory -ErrorAction SilentlyContinue
if ($null -eq $skillDirs -or $skillDirs.Count -eq 0) {
    Write-Host "  [X] No skills found in $skillsSourcePath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$installedCount = 0
$updatedCount = 0

foreach ($skillDir in $skillDirs) {
    $targetPath = Join-Path $cursorSkillsDir $skillDir.Name
    $skillMdPath = Join-Path $targetPath "SKILL.md"
    $isUpdate = Test-Path $targetPath
    
    # Remove existing directory/link completely
    if (Test-Path $targetPath) {
        Remove-Item -Path $targetPath -Recurse -Force -ErrorAction SilentlyContinue
        # Brief pause to ensure file handles are released
        Start-Sleep -Milliseconds 100
    }
    
    # Copy skill directory
    Copy-Item -Path $skillDir.FullName -Destination $targetPath -Recurse -Force -ErrorAction SilentlyContinue
    
    if (Test-Path $skillMdPath) {
        if ($isUpdate) {
            $updatedCount++
        }
        else {
            $installedCount++
        }
    }
}

$totalCount = $installedCount + $updatedCount
Write-Host "  [OK] $totalCount skills ($installedCount new, $updatedCount updated)" -ForegroundColor Green

# Step 5: Create rule file
Write-Host "[5/5] Creating rule file..."
$globalRulePath = Join-Path $cursorRulesDir "superpowers.md"

$ruleContent = @'
# Superpowers for Cursor

<EXTREMELY_IMPORTANT>
You have superpowers. Superpowers are specialized skills for software development.

## Available Skills

Skills are in ~/.cursor/skills/

### Core Skills (MANDATORY)

- **superpowers/using-superpowers** - MANDATORY: How to find and use skills.
- **superpowers/brainstorming** - MANDATORY before ANY creative work.
- **superpowers/systematic-debugging** - MANDATORY when encountering any bug.
- **superpowers/test-driven-development** - MANDATORY when implementing features.

### Planning Skills

- **superpowers/writing-plans** - Write detailed implementation plans.
- **superpowers/executing-plans** - Execute plans in batches.
- **superpowers/subagent-driven-development** - Execute tasks with subagents.

### Code Review Skills

- **superpowers/requesting-code-review** - Pre-review checklist.
- **superpowers/verification-before-completion** - MANDATORY when claiming work is complete.

## How to Use

1. **Automatic**: AI checks and uses relevant skills automatically
2. **Manual**: Reference with @superpowers/skill-name

IF A SKILL APPLIES, YOU MUST USE IT.
</EXTREMELY_IMPORTANT>
'@

# Remove readonly attribute if file exists
if (Test-Path $globalRulePath) {
    $file = Get-Item $globalRulePath -Force
    if ($file.IsReadOnly) {
        $file.IsReadOnly = $false
    }
}

Set-Content -Path $globalRulePath -Value $ruleContent -Encoding UTF8 -ErrorAction SilentlyContinue
Write-Host "  [OK] Rule file created" -ForegroundColor Green

# Done
Write-Host ""
Write-Host "========================================"
Write-Host "  Install Complete!" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""
Write-Host "Installed:"
Write-Host "  - Repo: $superpowersDir"
Write-Host "  - Skills: $cursorSkillsDir ($totalCount skills)"
Write-Host "  - Rule: $globalRulePath"
Write-Host ""
Write-Host "View skills: Cursor Settings (Ctrl+Shift+J) -> Rules -> Agent Decides"
Write-Host ""
Write-Host "Usage: Restart Cursor, then skills will appear and work automatically"
Write-Host ""
Read-Host "Press Enter to exit"
