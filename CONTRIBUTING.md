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
├── 01_基础工具/         ← 数字前缀控制排序，显示时自动去掉
├── 02_选择工具/
│   ├── MyScript.ms      ← 脚本文件
│   └── MyScript.json    ← 配置文件（同名）
```

> 💡 分类文件夹用 `数字_名称` 格式（如 `01_基础工具`），界面显示时会自动去掉前缀。

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

### 第一步：Fork 仓库

1. 打开 [BsKeyTools 仓库](https://github.com/AniBullet/BsKeyTools)
2. 点击右上角 **Fork** 按钮
3. 等待 Fork 完成，会跳转到你自己的仓库副本

### 第二步：Clone 到本地

```bash
# 把 "你的用户名" 替换成你的 GitHub 用户名
git clone https://github.com/你的用户名/BsKeyTools.git

# 进入项目文件夹
cd BsKeyTools

# 添加上游仓库（用于同步最新代码）
git remote add upstream https://github.com/AniBullet/BsKeyTools.git
```

### 第三步：创建新分支

```bash
# 切换到 dev 分支
git checkout dev

# 拉取最新代码
git pull upstream dev

# 创建你的工作分支（根据类型选择）
git checkout -b feature/你的功能名   # 新功能
git checkout -b fix/修复说明        # Bug 修复
```

### 第四步：修改代码并提交

```bash
# 修改完成后，添加所有更改
git add .

# 提交（参考下方提交信息格式）
git commit -m "feat: 添加了xxx功能"

# 推送到你的仓库
git push origin feature/你的功能名
```

### 第五步：创建 Pull Request

1. 打开你 Fork 的仓库页面
2. 点击 **Compare & pull request** 按钮
3. **重要**：确保目标分支是 `dev`（不是 main）
4. 填写 PR 描述，点击 **Create pull request**

🎉 **完成！** 等待审核即可。

---

## 📝 提交信息格式

```
feat: 新增功能
fix: 修复 Bug
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
```

**示例：**
- `feat: 添加批量导出动画功能`
- `fix: 修复时间轴同步问题`
- `docs: 更新安装说明`

---

## ✅ 提交前检查清单

- [ ] 在 3ds Max 中测试过，没有报错
- [ ] PR 目标分支是 `dev`
- [ ] 提交信息符合格式规范

---

## 📮 需要帮助？

- **QQ 群1**：[993590655](https://jq.qq.com/?_wv=1027&k=hmeHhTwu)
- **QQ 群2**：[907481113](https://qm.qq.com/q/FZ2gBKJeYE)
- **GitHub**：[提问/讨论](https://github.com/AniBullet/BsKeyTools/issues)

---

**感谢你的贡献！** 🎉
