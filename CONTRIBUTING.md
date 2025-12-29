# 🤝 贡献指南

感谢你对 BsKeyTools 的关注！以下是参与贡献的方式。

---

## 📋 贡献方式一览

| 方式 | 说明 | 难度 |
|-----|------|-----|
| 🐞 [报告 Bug](#-报告-bug) | 发现问题？告诉我们 | ⭐ |
| 💡 [功能建议](#-功能建议) | 有好想法？提出来 | ⭐ |
| 📦 [添加脚本](#-添加脚本到-bsscripthub) | 分享你的脚本 | ⭐⭐ |
| 🔧 [提交代码](#-提交代码) | 直接贡献代码 | ⭐⭐⭐ |

---

## 🐞 报告 Bug

**👉 [点击这里提交 Bug](https://github.com/AniBullet/BsKeyTools/issues/new?template=bug_report.md)**

提交时请包含：
- ❓ **问题描述**：发生了什么？
- 🔄 **复现步骤**：怎么触发的？
- 💻 **环境信息**：3ds Max 版本 + Windows 版本
- 📸 **截图/报错**：有的话请附上

---

## 💡 功能建议

**👉 [点击这里提交建议](https://github.com/AniBullet/BsKeyTools/issues/new?template=feature_request.md)**

请说明：
- 🎯 想要什么功能？
- 📝 解决什么问题？

---

## 📦 添加脚本到 BsScriptHub

想分享你的脚本？按以下步骤操作：

### 1. 准备文件

在 `_BsKeyTools/Scripts/BsScriptHub/分类名/` 下创建两个文件：

```
BsScriptHub/
├── 01_选择工具/         ← 数字前缀控制排序，显示时自动去掉
├── 02_建模工具/
│   ├── MyScript.ms      ← 脚本文件
│   └── MyScript.json    ← 配置文件（同名）
```

> 💡 分类文件夹用 `数字_名称` 格式（如 `01_选择工具`），界面显示时会自动去掉前缀。

### 2. 编写配置文件

`MyScript.json` 格式：

```json
{
    "name": "MyScript",
    "version": "1.0.0",
    "description": "脚本功能描述",
    "author": "你的名字",
    "script": "MyScript.ms"
}
```

| 字段 | 必填 | 说明 |
|-----|:---:|-----|
| `name` | ✓ | 脚本名（与文件名一致） |
| `version` | ✓ | 版本号 |
| `description` | ✓ | 功能描述（支持 `\n` 换行） |
| `author` | ✓ | 原作者 |
| `script` | ✓ | 脚本文件名 |
| `optimizer` | | 修改人 |
| `keywords` | | 搜索关键词 |
| `url` | | 发布地址 |
| `tutorial` | | 教程链接 |
| `preview` | | 预览图文件名（同目录） |

> 💡 `modified_date` 无需填写，会自动从脚本文件读取修改日期

### 3. 添加预览图（可选）

把预览图放在脚本同目录下，JSON 里只写文件名：

```
BsScriptHub/
├── 选择工具/
│   ├── MyScript.ms
│   ├── MyScript.json
│   └── MyScript_preview.png  ← 预览图
```

**建议**：
- 格式：PNG / JPG
- 尺寸：400×300 左右
- 大小：< 200KB

### 4. 更新索引

```bash
cd _BsKeyTools/Scripts/BsScriptHub
python generate_index.py
```

### 5. 提交 PR

按下方流程提交到 `dev` 分支即可。

---

## 🔧 提交代码

> 💡 **新手提示**：如果你完全没有 Git 使用经验，建议先阅读下方详细步骤。有经验的同学可以直接使用[一键脚本](#一键脚本懒人专用)。

### 📋 前置准备

#### 1. 安装 Git

**下载地址：**
- **官方下载**：https://git-scm.com/download/win
- **国内镜像**：https://mirrors.tuna.tsinghua.edu.cn/git-for-windows/

安装步骤：
1. 双击安装包，一路点击 **Next**，使用默认设置
2. 安装完成后，按 `Win + R`，输入 `cmd` 打开命令提示符
3. 输入 `git --version` 验证安装（应显示版本号）

#### 2. 注册 GitHub 账号

1. 访问 https://github.com
2. 点击右上角 **Sign up**，填写信息完成注册
3. **重要**：记住你的 GitHub 用户名

> 💡 **可选**：配置 SSH 密钥可免密提交，详见 [GitHub 文档](https://docs.github.com/authentication/connecting-to-github-with-ssh)

---

### 详细步骤

#### 第一步：Fork 仓库

1. 打开 [BsKeyTools 仓库](https://github.com/AniBullet/BsKeyTools)
2. 点击右上角 **Fork** 按钮
3. 等待完成，页面会跳转到你的仓库副本

#### 第二步：Clone 到本地

```bash
# 把 "你的用户名" 替换成你的 GitHub 用户名
git clone https://github.com/你的用户名/BsKeyTools.git

# 进入项目文件夹
cd BsKeyTools

# 添加上游仓库（用于同步最新代码）
git remote add upstream https://github.com/AniBullet/BsKeyTools.git

# 验证配置
git remote -v
```

#### 第三步：配置 Git 用户信息

```bash
# 配置你的名字和邮箱（只需设置一次）
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

> 💡 邮箱建议使用 GitHub 账号绑定的邮箱

#### 第四步：创建新分支

```bash
# 切换到 dev 分支
git checkout dev

# 拉取最新代码
git pull upstream dev

# 创建你的工作分支
git checkout -b feature/你的功能名   # 新功能
# 或
git checkout -b fix/修复说明        # Bug 修复
```

#### 第五步：修改代码并提交

```bash
# 1. 修改代码（用任何编辑器打开项目文件夹修改）

# 2. 查看修改
git status

# 3. 添加所有更改到暂存区
git add .

# 4. 提交（参考下方提交信息格式）
git commit -m "feat: 添加了xxx功能"

# 5. 推送到你的仓库
git push origin feature/你的功能名
```

> ⚠️ **注意**：首次推送可能需要输入 GitHub 用户名和 **Personal Access Token**（不是登录密码）
> 
> **获取 Token**：
> 1. 访问 https://github.com/settings/tokens
> 2. 点击 **Generate new token** → **Generate new token (classic)**
> 3. 勾选 `repo` 权限，生成并复制 Token（只显示一次！）
> 4. 在 Git 要求输入密码时，粘贴这个 Token

#### 第六步：创建 Pull Request

1. 打开你 Fork 的仓库页面：`https://github.com/你的用户名/BsKeyTools`
2. 点击 **Compare & pull request** 按钮
3. **重要**：确保 **base repository** 是 `AniBullet/BsKeyTools`，**base** 是 `dev`（不是 main！）
4. 填写 PR 描述，点击 **Create pull request**

🎉 **完成！** 等待审核即可。

---

### 🚀 一键脚本（懒人专用）

如果你觉得手动操作太麻烦，可以使用我们提供的一键脚本！

**使用方法：**

1. 下载脚本文件 `setup-contribute.ps1`（项目根目录）
2. 右键点击脚本 → **使用 PowerShell 运行**
3. 按照提示输入信息：
   - GitHub 用户名
   - 分支类型（feature/fix）
   - 分支名称
   - 提交信息

**脚本功能：**
- ✅ 检查 Git 是否安装
- ✅ Clone 仓库到本地
- ✅ 配置上游仓库
- ✅ 切换到 dev 分支并拉取最新代码
- ✅ 创建新分支
- ✅ 等待你修改代码后，自动提交并推送

> ⚠️ **注意**：首次运行 PowerShell 脚本可能需要设置执行策略：
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

---

### ❓ 常见问题

**Q1: 提示 "git: command not found"**  
**A:** Git 未安装或未添加到系统路径。重新安装 Git，安装时选择 "Add Git to PATH"。

**Q2: Clone 时提示 "Permission denied"**  
**A:** 检查仓库地址是否正确，或尝试使用 SSH 方式（需先配置 SSH 密钥）。

**Q3: Push 时提示 "Authentication failed"**  
**A:** 确保使用 Personal Access Token 而不是密码，Token 需要有 `repo` 权限。

**Q4: 如何同步上游的最新代码？**  
**A:** 
```bash
git checkout dev
git pull upstream dev
git push origin dev
```

**Q5: 提交后发现代码有问题，想修改？**  
**A:** 
```bash
git add .
git commit --amend -m "新的提交信息"
git push origin feature/你的功能名 --force
```
> ⚠️ 注意：`--force` 会覆盖远程分支，谨慎使用！

**Q6: 如何撤销本地修改？**  
**A:** 
```bash
git checkout .              # 撤销所有未提交的修改
git checkout 文件名          # 或只撤销特定文件
```

**Q7: 如何删除分支？**  
**A:** 
```bash
git branch -d feature/你的功能名                    # 删除本地分支
git push origin --delete feature/你的功能名         # 删除远程分支
```

---

## 📝 提交信息格式

| 类型 | 格式 | 示例 |
|-----|------|------|
| 新功能 | `feat: 描述` | `feat: 添加批量导出动画功能` |
| 修复 Bug | `fix: 描述` | `fix: 修复时间轴同步问题` |
| 文档 | `docs: 描述` | `docs: 更新安装说明` |
| 格式 | `style: 描述` | `style: 调整代码缩进` |
| 重构 | `refactor: 描述` | `refactor: 优化函数结构` |
| 测试 | `test: 描述` | `test: 添加单元测试` |
| 构建 | `build: 描述` | `build: 更新依赖版本` |

---

## ✅ 提交前检查清单

在创建 PR 之前，请确认：

- [ ] 代码在 3ds Max 中测试过，没有报错
- [ ] PR 目标分支是 `dev`（不是 main）
- [ ] 提交信息符合格式规范
- [ ] 代码风格与项目保持一致
- [ ] 没有提交临时文件或敏感信息

---

## 📮 需要帮助？

- **QQ 群1**：[993590655](https://jq.qq.com/?_wv=1027&k=hmeHhTwu)
- **QQ 群2**：[907481113](https://qm.qq.com/q/FZ2gBKJeYE)
- **GitHub**：[提问/讨论](https://github.com/AniBullet/BsKeyTools/issues)

---

## 👨‍💼 维护者指南（处理 Pull Request）

> 此部分面向仓库维护者，普通贡献者可跳过。

### 审核流程

#### 1. 查看代码变更

1. 打开 PR 页面，点击 **Files changed** 标签
2. 检查代码是否符合项目规范
3. 如有问题，在具体代码行上添加评论

#### 2. 与贡献者沟通（如需要）

- 在 PR 页面的 **Conversation** 标签下留言
- 贡献者修改后会自动更新到当前 PR

#### 3. 合并 PR

**方法 A：GitHub 网页（推荐）**

1. 确认代码无问题后，点击 **Merge pull request**
2. 选择合并方式：
   - **Create a merge commit**：保留所有提交历史（推荐）
   - **Squash and merge**：压缩成一个提交
3. 点击 **Confirm merge**
4. 可选：点击 **Delete branch** 删除贡献者的分支

**方法 B：GitHub CLI**

```bash
# 查看 PR 列表
gh pr list

# 查看具体 PR 详情
gh pr view PR编号

# 合并 PR（保留提交历史）
gh pr merge PR编号 --merge

# 或压缩合并
gh pr merge PR编号 --squash
```

**方法 C：命令行**

```bash
# 拉取 PR 到本地测试
git fetch origin pull/PR编号/head:pr-test
git checkout pr-test

# 测试无问题后，合并到 dev
git checkout dev
git merge pr-test
git push origin dev

# 删除临时分支
git branch -d pr-test
```

### 审核检查清单

在合并 PR 前，请确认：

- [ ] 代码逻辑正确，没有明显 Bug
- [ ] PR 目标分支是 `dev`
- [ ] 提交信息符合规范
- [ ] 没有引入敏感信息或临时文件
- [ ] 代码风格与项目一致

---

**感谢你的贡献！** 🎉
