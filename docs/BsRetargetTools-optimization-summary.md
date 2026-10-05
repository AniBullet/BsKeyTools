# BsRetargetTools 优化状态总览

更新时间：2026-05-16

## 当前结论

代码侧优化已推进到可进入 3ds Max 统一验收的状态。

已完成的范围是稳定性、兼容性、入口保护、局部结构清理和静态检查增强。核心 Biped 对齐数学、约束算法、FBX 导入导出参数没有重写；这些需要等 Max 场景验收后，根据真实问题再进入下一阶段。

## 保留文件

- `_BsKeyTools/Scripts/BulletScripts/BsRetargetTools.ms`
  - 插件主脚本。
- `docs/BsRetargetTools-list-format.md`
  - list 格式兼容说明。
- `docs/BsRetargetTools-validation-checklist.md`
  - 3ds Max 手验清单。
- `tools/check-bs-retarget-lists.ps1`
  - list 静态检查。
- `tools/check-bs-retarget-script.ps1`
  - 插件脚本静态检查。

## 已完成优化

- 兼容旧版 legacy list、新版 v2 list、Root 缺失或 `~undefined~` 的情况。
- 增加 Root 推断：list Root、1 号槽位 parent、常见 Root 名称。
- 增加统一 mapping 状态构建，集中判断必选缺失、可选缺失、场景节点缺失、Root 是否有效。
- 验证、创建映射、转 Biped、批量重定向等危险入口增加前置保护。
- 自动识别 preset 后统一执行 list 加载、Root 推断、状态栏刷新。
- 状态栏显示映射数量、Root 状态和下一步提示。
- list 加载失败、短 list、异常 list 不再残留上一次映射状态。
- 保存 list 失败时提前提示并停止。
- 批量/选中重定向增加路径、Skin、动画列表、Biped 存在性检查。
- 核心创建映射流程内缓存 Biped Root，减少重复直接访问。
- pose copy/paste 临时变量局部化。
- Skin 替换、文件删除、转 Biped 等流程中的部分隐式全局变量改为局部变量。
- 增加静态检查脚本，覆盖编码、关键 helper 和保护点（早期的 CRLF 检查已在 894acfb 移除，换行以 `.gitattributes` 的 LF 为准）。

## 已通过的本地检查

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-bs-retarget-script.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-bs-retarget-lists.ps1
```

结果：

- 插件脚本静态检查通过。
- list 静态检查通过。
- 部分 bundled preset 的 Root 为 `~undefined~`，这是预期警告，运行时需要推断 Root 或阻断危险操作。
- 触碰文件已保持 UTF-8、无 NUL（换行规则见 `.gitattributes`）。

## 必须手验

按 `docs/BsRetargetTools-validation-checklist.md` 在 3ds Max 内验收：

- 插件是否无 MaxScript 错误打开。
- legacy / v2 / Root undefined list 是否兼容。
- Mixamo、CC4、Daz、MMD 等 preset 自动识别是否正常。
- Root 推断是否正确。
- 验证按钮、创建映射、转 Biped 是否按预期阻断或继续。
- pose copy / paste、手指重对齐、批量重定向是否没有新增报错。

## 暂缓的深度优化

以下内容暂不继续拆，等 Max 验收后再根据真实问题处理：

- Biped 创建顺序重组。
- 对齐、IK、约束算法重写。
- FBX 导入导出流程重构。
- 单文件拆分为多个运行时脚本。
- 大规模函数/变量重命名。

原因：这些区域高度依赖场景状态，当前静态检查无法证明行为正确。

## 工作区注意

当前并行分支上可能还有 auto-update 相关改动。此次 BsRetarget 优化只应关注：

- `_BsKeyTools/Scripts/BulletScripts/BsRetargetTools.ms`
- `docs/BsRetargetTools-list-format.md`
- `docs/BsRetargetTools-validation-checklist.md`
- `docs/BsRetargetTools-optimization-summary.md`
- `tools/check-bs-retarget-lists.ps1`
- `tools/check-bs-retarget-script.ps1`
