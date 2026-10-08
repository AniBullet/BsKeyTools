# Superpowers for Cursor - 简明指南

## 🚀 一键安装

### 方法一：运行安装脚本（推荐）

1. 打开 PowerShell（管理员权限）
2. 进入项目的 `.cursor` 目录：
   ```powershell
   cd "<你的项目路径>\.cursor"
   ```
3. 运行安装脚本：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\install-superpowers.ps1
   ```

或者直接在 Cursor 终端中运行：
```powershell
powershell -ExecutionPolicy Bypass -File ".\.cursor\install-superpowers.ps1"
```

### 方法二：手动安装（4 步）

```powershell
# 1. 创建必要目录
New-Item -ItemType Directory -Path "$env:USERPROFILE\.codex" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.cursor\skills" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.cursor\rules" -Force

# 2. 克隆仓库
git clone --depth 1 https://github.com/obra/superpowers.git "$env:USERPROFILE\.codex\superpowers"

# 3. 复制技能文件（不要用 Junction 链接，Cursor 无法正确扫描）
# 注意：每个技能必须是 .cursor\skills\ 的直接子目录
$skillsSource = "$env:USERPROFILE\.codex\superpowers\skills"
Get-ChildItem $skillsSource -Directory | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination "$env:USERPROFILE\.cursor\skills\$($_.Name)" -Recurse -Force
}

# 4. 复制规则文件（从项目中复制，或手动创建）
Copy-Item ".\.cursor\rules\superpowers.md" "$env:USERPROFILE\.cursor\rules\superpowers.md"
```

> **注意**：第 4 步假设当前项目已有 `.cursor\rules\superpowers.md` 文件。如果没有，安装脚本会自动创建。

---

## 📖 Rules 目录中 .md 文件的工作原理

### Cursor Rules 机制

`.cursor\rules\` 目录下的 `.md` 文件是 **Cursor 的规则文件**：

| 位置 | 作用范围 | 说明 |
|------|---------|------|
| `%USERPROFILE%\.cursor\rules\*.md` | 全局 | 对所有项目生效 |
| `<项目>\.cursor\rules\*.md` | 项目 | 仅对当前项目生效 |

### 规则文件如何生效

1. **自动加载**: Cursor 启动时自动读取 rules 目录下的所有 `.md` 文件
2. **系统提示词**: 这些规则会作为 AI 的系统提示词（System Prompt）的一部分
3. **优先级**: 项目级规则优先于全局规则

### 规则文件命名规范

```
.cursor\rules\
├── superpowers.md      # superpowers 技能规则
├── coding-style.md     # 编码风格规则
├── project-specific.md # 项目特定规则
└── ...
```

### 关键标签说明

规则文件中的特殊标签：

| 标签 | 作用 |
|------|------|
| `<EXTREMELY_IMPORTANT>` | 最高优先级指令，AI 必须遵循 |
| `<rule>` | 普通规则 |
| `<context>` | 上下文信息 |

---

## 🎯 Superpowers 简化使用指南

### 日常使用（推荐方式）

安装后，**什么都不用做**！AI 会自动：
- 检测任务类型
- 加载相关技能
- 按照技能流程执行

### 手动触发技能

当你想明确使用某个技能时：

```
# 方式 1: @ 引用
@superpowers/brainstorming 帮我设计一个新功能

# 方式 2: 直接说明
请使用 brainstorming 技能来帮我规划这个任务

# 方式 3: 列出可用技能
请告诉我有哪些 superpowers 技能可用
```

### 常用技能速查表

| 场景 | 使用技能 | 触发方式 |
|------|---------|---------|
| 开始新功能 | `brainstorming` | 自动 |
| 遇到 Bug | `systematic-debugging` | 自动 |
| 写代码前 | `test-driven-development` | 自动 |
| 多步骤任务 | `writing-plans` → `executing-plans` | 说"帮我做个计划" |
| 完成任务 | `verification-before-completion` | 自动 |
| 代码审查 | `requesting-code-review` | 说"审查一下代码" |

---

## 📁 安装后的目录结构

```
%USERPROFILE%\
├── .codex\
│   └── superpowers\                    # superpowers 仓库 (git clone)
│       ├── skills\                     # 技能源文件
│       │   ├── brainstorming\
│       │   │   └── SKILL.md
│       │   ├── systematic-debugging\
│       │   │   └── SKILL.md
│       │   └── ...（共 14 个技能）
│       └── ...
│
└── .cursor\
    ├── skills\                         # 用户自定义技能目录
    │   ├── brainstorming\              # 直接复制的技能文件（非链接）
    │   │   └── SKILL.md
    │   ├── systematic-debugging\
    │   │   └── SKILL.md
    │   └── ...（共 14 个技能）
    │
    ├── skills-cursor\                  # Cursor 内置技能（系统保留，勿修改）
    │
    └── rules\
        └── superpowers.md              # 全局规则文件
```

> **重要**：
> - Cursor 只扫描 `skills` 的**直接子目录**，不能嵌套
> - 必须使用**实际文件复制**，不能用 Junction 链接（Cursor 无法正确扫描链接）

---

## 🔄 更新 Superpowers

重新运行安装脚本即可更新（脚本会自动拉取最新代码并覆盖安装）：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.cursor\install-superpowers.ps1"
```

或者手动更新：

```powershell
# 1. 更新仓库
cd "$env:USERPROFILE\.codex\superpowers"
git pull

# 2. 重新复制技能文件
$src = "$env:USERPROFILE\.codex\superpowers\skills"
$dst = "$env:USERPROFILE\.cursor\skills"
Get-ChildItem $src -Directory | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination "$dst\$($_.Name)" -Recurse -Force
}
```

---

## 👀 查看已安装的技能

1. 按 **Ctrl+Shift+J** 打开 Cursor Settings
2. 点击 **Rules** 标签
3. 在 **Agent Decides** 部分查看所有已安装的技能

---

## ❓ 常见问题

### Q: 安装后技能不显示？
A: 最常见的原因：

1. **使用了 Junction 链接**：Cursor 无法正确扫描 Junction 链接，必须使用实际文件复制
2. **技能嵌套太深**：必须是 `skills/brainstorming/` 而不是 `skills/superpowers/brainstorming/`
3. **没有重启 Cursor**：安装后需要完全关闭并重新打开 Cursor

运行安装脚本可自动修复这些问题。

### Q: 规则文件不生效？
A: 重启 Cursor，或检查文件编码是否为 UTF-8。

### Q: 技能没有自动触发？
A: 确保 `%USERPROFILE%\.cursor\rules\superpowers.md` 存在，并包含正确的规则内容。

### Q: 如何禁用某个技能？
A: 在 Cursor Settings → Rules 中找到该技能，点击禁用。或删除对应的技能文件夹。

### Q: 如何添加自定义技能？
A: 在 `%USERPROFILE%\.cursor\skills\` 下创建新目录，包含 `SKILL.md` 文件。
> **注意**：不要使用 `skills-cursor` 目录，那是 Cursor 内置技能的保留目录。

---

## 📚 相关链接

- [Superpowers 官方仓库](https://github.com/obra/superpowers)
- [Cursor Agent Skills 文档](https://cursor.com/cn/docs/context/skills)
- [Agent Skills 开放标准](https://agentskills.io)
