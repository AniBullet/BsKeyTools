# 贡献指南

感谢你对 BsKeyTools 的关注！我们欢迎任何形式的贡献。

---

## 🚀 快速开始

### 提交代码

```bash
# 1. Fork 仓库并 clone
git clone https://github.com/你的用户名/BsKeyTools.git
cd BsKeyTools

# 2. 添加上游仓库
git remote add upstream https://github.com/AniBullet/BsKeyTools.git

# 3. 创建新分支（从 dev 分支）
git checkout dev
git pull upstream dev
git checkout -b feature/你的功能名称

# 4. 进行修改、测试

# 5. 提交更改
git add .
git commit -m "feat: 你的改动描述"

# 6. 推送并创建 PR
git push origin feature/你的功能名称
# 然后在 GitHub 创建 Pull Request 到 dev 分支
```

### 保持同步

```bash
git fetch upstream
git checkout dev
git merge upstream/dev
git push origin dev
```

---

## 🐞 报告问题

发现 Bug？[提交 Issue](https://github.com/AniBullet/BsKeyTools/issues/new/choose)

请包含：
- 问题描述和复现步骤
- 3ds Max 版本和操作系统
- 错误信息或截图

---

## 💡 功能建议

有好想法？[提交建议](https://github.com/AniBullet/BsKeyTools/issues/new/choose)

请说明：
- 功能描述和使用场景
- 解决什么问题
- 参考示例（如有）

---

## 📝 代码规范

### 提交信息格式

```
feat: 添加新功能
fix: 修复 Bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 其他
```

### MAXScript 规范

```maxscript
-- 使用有意义的变量名和函数名
fn exportAnimation startFrame endFrame = 
(
    -- 添加必要的注释
    -- 缩进使用 Tab 或 4 空格
    local result = true
    
    -- 代码逻辑
    
    return result
)
```

### 文件注释

```maxscript
/*
工具名称: 文件名.ms
功能描述: 功能说明
作者: 你的名字
创建日期: 2025-12-03
版本: v1.0.0
参考来源: 原作者/项目（如有）
*/
```

---

## 🌿 分支说明

- **`main`**: 稳定发布分支
- **`dev`**: 开发分支 **(请提交 PR 到此分支)**

分支命名：
- `feature/功能名` - 新功能
- `fix/问题描述` - Bug 修复
- `docs/说明` - 文档更新

---

## ✅ 提交 PR 前检查

- [ ] 在 3ds Max 中测试过
- [ ] 没有语法错误
- [ ] 添加了必要注释
- [ ] PR 提交到 `dev` 分支
- [ ] 使用了规范的提交信息

---

## 📮 需要帮助？

- **GitHub Issues**: [提问](https://github.com/AniBullet/BsKeyTools/issues)
- **QQ 群1**: 993590655
- **QQ 群2**: 907481113

---

## 🎯 优先贡献方向

- [ ] Bug 修复
- [ ] 新版本 3ds Max 适配
- [ ] 性能优化

---

**感谢你的贡献！** 🎉
