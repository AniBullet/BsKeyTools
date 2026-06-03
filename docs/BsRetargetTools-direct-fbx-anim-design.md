# BsRetargetTools - FBX 动画直转 Biped 设计文档

创建时间：2026-06-02

## 需求背景

当前 BsRetargetTools 的 FBX → Biped 流程要求：
1. 先导入 T-pose FBX → 创建 Biped 映射文件（Tab1）
2. 再用映射文件 + 动画 FBX → 重定向输出（Tab2）

**痛点**：很多时候用户只有带动画的 FBX（没有独立的 T-pose/SkinPose 文件），无法走现有流程。

## 新功能目标

**一键流程**：动画 FBX + .list 映射 → 自动创建 Biped + 写入动画 → 输出 .bip / .max / .fbx

- 不需要单独的 T-pose 文件
- 不需要 Skin 文件
- 直接从动画 FBX 的第一帧提取骨骼比例来创建 Biped

## 设计方案

### UI 布局

新增第三个 Tab：**「FBX 动画直转」**（或 "动画直传"）

控件列表：
- `btnSelectDirectFbx` — 选择动画 FBX 文件（或文件夹，支持批量）
- `edtDirectFbxPath` — 显示 FBX 路径
- `btnSelectDirectList` — 选择 .list 映射文件
- `edtDirectListPath` — 显示 .list 路径
- `btnSelectDirectOutput` — 选择输出目录
- `edtDirectOutputPath` — 显示输出路径
- `ddlDirectRefFrame` — 参考帧选择（默认 "第一帧"）
- `chkDirectExportFbx` — 是否同时导出 FBX（默认开）
- `chkDirectExportBip` — 是否同时导出 .bip（默认开）
- `btnDirectConvert` — **「>>> 直转选中 <<<」**
- `btnDirectConvertAll` — **「>>> 批量直转 <<<」**
- `pgbDirectBar` — 进度条

### 核心函数

#### `fnDirectFBXToBiped animFbxPath listFilePath outputDir`

```
流程：
1. resetMaxFile
2. 加载 .list 映射 → 填充 characterBones 数据
3. importFile animFbxPath (FBX 导入，完整场景)
4. 定位到参考帧（默认第一帧）
5. 通过 .list 中的骨骼名在场景中查找对应节点
   → 如果找不到必要骨骼，报错退出
6. 计算骨骼位置/长度（复用 GetBonePos 逻辑）
7. 创建 Biped（复用现有 biped.createNew + 参数计算逻辑）
   - 计算 headPos、rootPos、legLen
   - 确定 neckLinks、spineLinks、fingers 等参数
   - AdjustBipedScale 设置各段比例
   - AlignBipToFaux 对齐到参考帧姿态
8. Biped figure mode = false
9. 逐帧烘焙动画：
   for t = animationRange.start to animationRange.end do
   (
       slidertime = t
       with animate on
       (
           for each mapped bone pair (fbxBone, bipedNode):
               worldPos = fbxBone.transform.position
               worldRot = fbxBone.transform.rotation
               biped.setTransform bipedNode #pos worldPos true
               biped.setTransform bipedNode #rotation worldRot true
       )
   )
10. 保存输出：
    - biped.saveBipFile → .bip
    - saveMaxFile → .max
    - (可选) exportFile → .fbx
```

#### `fnBatchDirectFBXToBiped animFbxFolder listFilePath outputDir`

对文件夹中所有 FBX 逐一调用 `fnDirectFBXToBiped`，带进度条。

### 骨骼映射复用

直接使用现有 .list 文件格式（v2）：
- `characterBones.items[i]` = FBX 中对应 Biped 第 i 个槽位的骨骼名
- 无需新增映射格式
- Root 行为延续现有逻辑（list 尾部的 Root 名称或自动推断）

### 关键技术点

#### 1. 从任意 pose 创建 Biped

- 骨骼长度 = 相邻关节的位置距离（在任何帧都有效）
- 现有 `AdjustBipedScale` 用 `GetBonePos(index0)` 和 `GetBonePos(index1)` 计算距离，不依赖 T-pose
- `AlignBipToFaux` 对齐 rotation 也不要求特定 pose
- 唯一区别：Biped 的 figure mode 姿态将是动画第一帧的姿态（而非标准 T-pose），这对动画传递不影响

#### 2. 逐帧烘焙 vs 约束驱动

| 方法 | 精度 | 速度 | 复杂度 |
|---|---|---|---|
| 逐帧烘焙 | 最高（精确匹配） | 慢（1000帧约30-60s） | 中等 |
| 约束驱动 | 高（微小偏差） | 快 | 需 RTHelper | 

**选择逐帧烘焙**作为默认方式：
- 精度最高
- 不需要创建 RTHelper 中间节点
- 代码更简单直接
- 速度对单文件可接受

#### 3. Root / 世界空间处理

- Biped Root（质心）对应 .list 中的 1 号槽位
- 位移通过 `biped.setTransform bipRoot #pos worldPos true` 直接写入
- 如果 FBX 有独立 Root motion 骨骼（如 "Root" 节点），需要把它的位移叠加到 Biped 质心上

### 与现有流程的关系

- **不影响** Tab1（FBX 转 Biped）和 Tab2（动画重定向）的任何功能
- 新 Tab 是完全独立的一键流程
- 共享的底层函数：`GetBonePos`、`GetBipedNode`、`GetSkeletalNode`、`AdjustBipedScale`、`AlignBipToFaux`、`fnIsIgnoreBone`、.list 加载逻辑

### 输出文件结构

```
outputDir/
├── BIP/
│   └── animName.bip
├── MAX/
│   └── animName.max
└── FBX/        (如果勾选导出 FBX)
    └── animName.fbx
```

### 错误处理

- .list 加载失败 → 提示 "映射文件无效"
- FBX 中找不到 .list 中的必要骨骼 → 列出缺失骨骼名
- Biped 创建失败 → 提示并退出
- 烘焙中断 → 提示已处理帧数，不导出半成品

### 后续扩展可能

- 支持选择参考帧（不一定是第一帧）
- 支持 "只烘焙，不创建 Biped"（使用已有 Biped）
- 支持动画裁剪（指定起止帧）
- 支持半速/倍速处理

## 实现优先级

1. **P0** — 核心函数 `fnDirectFBXToBiped`（单文件完整流程）
2. **P0** — Tab3 基础 UI
3. **P1** — 批量处理 `fnBatchDirectFBXToBiped`
4. **P2** — 参考帧选择、裁剪等高级选项
