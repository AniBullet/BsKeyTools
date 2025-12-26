# -*- coding: utf-8 -*-
"""
批量生成 Quote 文件夹脚本的 BsScriptHub 配置
运行方式：在此目录下执行 python generate_quote_scripts.py
"""

import os
import json
from datetime import datetime

# 脚本目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
QUOTE_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), "BulletScripts", "Quote")

# 脚本分类配置 - 格式: "脚本文件名": ("分类文件夹", "显示名称", "描述", "原作者", "关键词列表")
SCRIPTS_CONFIG = {
    # ===== 05_动画工具 =====
    "TweenMachine.ms": ("05_动画工具", "补间动画工具", "在关键帧之间快速创建补间动画，支持多种缓动曲线", "Justin Barrett", ["动画", "补间", "Tween", "关键帧"]),
    "CPTools_New.ms": ("05_动画工具", "动画复制粘贴", "高级动画复制粘贴工具，支持跨对象、跨场景操作", "", ["动画", "复制", "粘贴", "关键帧"]),
    "DTrajEdit_New.ms": ("05_动画工具", "轨迹编辑器", "可视化编辑运动轨迹，支持轨迹修改和平滑", "", ["动画", "轨迹", "路径", "编辑"]),
    "ProTrajectoryHandles.ms": ("05_动画工具", "专业轨迹控制", "专业级轨迹控制手柄，精确调整运动路径", "", ["动画", "轨迹", "控制", "专业"]),
    "BakeAnim.ms": ("05_动画工具", "烘焙动画", "将程序动画烘焙为关键帧动画", "", ["动画", "烘焙", "Bake", "关键帧"]),
    "Anim_mirror.ms": ("05_动画工具", "动画镜像", "镜像复制动画数据，适用于对称动作", "", ["动画", "镜像", "Mirror", "对称"]),
    "AnimaRange.ms": ("05_动画工具", "动画范围工具", "快速设置和管理动画时间范围", "", ["动画", "范围", "时间", "帧"]),
    "alexanimalign_0.ms": ("05_动画工具", "动画对齐工具", "对齐多个对象的动画关键帧", "Alex", ["动画", "对齐", "Align", "关键帧"]),

    # ===== 06_骨骼绑定 =====
    "SpringMagic_Enhanced.ms": ("06_骨骼绑定", "弹簧魔法增强版", "增强版弹簧动力学工具，模拟弹性运动效果，支持更多参数调节", "", ["绑定", "弹簧", "Spring", "动力学"]),
    "ChainsTools.ms": ("06_骨骼绑定", "链条工具", "创建和管理骨骼链条，适用于绳索、链条等效果", "", ["绑定", "链条", "Chain", "骨骼"]),
    "twistbones.ms": ("06_骨骼绑定", "扭曲骨骼", "创建扭曲骨骼系统，改善关节变形效果", "", ["绑定", "扭曲", "Twist", "骨骼"]),
    "springcontroller.ms": ("06_骨骼绑定", "弹簧控制器", "为对象添加弹簧控制器，实现弹性跟随效果", "", ["绑定", "弹簧", "控制器", "跟随"]),
    "飘带解算.mse": ("06_骨骼绑定", "飘带解算", "飘带和布料的简易动力学解算工具", "", ["绑定", "飘带", "布料", "解算"]),

    # ===== 07_场景管理 =====
    "nestedLayerManager.mzp": ("07_场景管理", "嵌套图层管理", "支持嵌套结构的高级图层管理工具", "", ["场景", "图层", "Layer", "嵌套"]),
    "LayerManagerAlternative.ms": ("07_场景管理", "图层管理替代版", "轻量级图层管理工具，快速操作图层", "", ["场景", "图层", "Layer", "管理"]),
    "P_ObjectRenamer.ms": ("07_场景管理", "对象批量重命名", "强大的批量重命名工具，支持多种命名规则", "", ["场景", "重命名", "Rename", "批量"]),
    "objectPicker.ms": ("07_场景管理", "对象选择器", "高级对象选择工具，支持多种筛选条件", "", ["场景", "选择", "Picker", "筛选"]),
    "ProColor.ms": ("07_场景管理", "专业颜色工具", "批量修改对象线框颜色，方便场景管理", "", ["场景", "颜色", "Color", "线框"]),
    "lod_creator.ms": ("07_场景管理", "LOD创建器", "自动创建多级细节模型", "", ["场景", "LOD", "细节", "优化"]),

    # ===== 08_导入导出 =====
    "Batch Import Convert.ms": ("08_导入导出", "批量导入转换", "批量导入文件并转换格式", "", ["导入", "导出", "批量", "转换"]),
    "Batch version down.ms": ("08_导入导出", "批量降版本", "批量将Max文件降低版本保存", "", ["导入", "导出", "版本", "批量"]),

    # ===== 10_蒙皮权重 (新增) =====
    "P_SkinWeightTool.ms": ("10_蒙皮权重", "蒙皮权重工具", "专业蒙皮权重编辑工具，支持权重复制、镜像等功能", "", ["蒙皮", "权重", "Skin", "编辑"]),
    "SkinTools.ms": ("10_蒙皮权重", "蒙皮工具集", "蒙皮相关工具集合，包含多种实用功能", "", ["蒙皮", "权重", "Skin", "工具"]),
    "Xr_SkinTool.ms": ("10_蒙皮权重", "XR蒙皮工具", "XR系列蒙皮权重编辑工具", "Xr", ["蒙皮", "权重", "Skin", "XR"]),
    "权重分区平滑.ms": ("10_蒙皮权重", "权重分区平滑", "按分区平滑蒙皮权重，提高变形质量", "", ["蒙皮", "权重", "平滑", "分区"]),
    "sox_replacebonefromskin.ms": ("10_蒙皮权重", "替换蒙皮骨骼", "替换蒙皮修改器中的骨骼引用", "Sox", ["蒙皮", "骨骼", "替换", "Skin"]),
    "Rigging_CombineSkin.ms": ("10_蒙皮权重", "合并蒙皮", "合并多个蒙皮修改器或蒙皮数据", "", ["蒙皮", "合并", "Combine", "绑定"]),
    "ChangeSkinBones.ms": ("10_蒙皮权重", "修改蒙皮骨骼", "批量修改蒙皮骨骼设置", "", ["蒙皮", "骨骼", "修改", "Skin"]),

    # ===== 11_特效渲染 (新增) =====
    "MassFX.ms": ("11_特效渲染", "MassFX物理工具", "MassFX物理模拟增强工具", "", ["特效", "物理", "MassFX", "模拟"]),
    "FractureVoronoi.ms": ("11_特效渲染", "Voronoi破碎", "基于Voronoi算法的模型破碎工具", "", ["特效", "破碎", "Voronoi", "碎片"]),
    "Collider.ms": ("11_特效渲染", "碰撞器工具", "快速创建和管理碰撞器", "", ["特效", "碰撞", "Collider", "物理"]),
    "多方向渲染工具（集成修改版）.ms": ("11_特效渲染", "多方向渲染工具", "从多个角度批量渲染场景", "", ["渲染", "多角度", "批量", "输出"]),
    "LightTable.ms": ("11_特效渲染", "灯光台", "灯光管理和编辑工具台", "", ["渲染", "灯光", "Light", "管理"]),
    "ImageCompHelper.ms": ("11_特效渲染", "图像合成助手", "渲染图像的合成辅助工具", "", ["渲染", "合成", "图像", "后期"]),
    "参考大师.mse": ("11_特效渲染", "参考大师", "参考图管理工具，方便查看参考资料", "", ["渲染", "参考", "Reference", "图片"]),

    # ===== 12_开发工具 (新增) =====
    "RolloutBuilder.ms": ("12_开发工具", "Rollout构建器", "可视化MaxScript界面构建工具", "", ["开发", "Rollout", "界面", "构建"]),
    "Show.NetProperty.ms": ("12_开发工具", ".NET属性查看器", "查看.NET对象的属性和方法", "", ["开发", ".NET", "属性", "调试"]),
    "DarkScintilla.mzp": ("12_开发工具", "暗黑代码编辑器", "暗色主题的MaxScript代码编辑器", "", ["开发", "编辑器", "代码", "暗色"]),
    "simple_hwnd_viewer.ms": ("12_开发工具", "窗口句柄查看器", "查看窗口句柄信息的调试工具", "", ["开发", "窗口", "句柄", "HWND"]),
    "WinBox.ms": ("12_开发工具", "窗口工具箱", "窗口操作和管理工具集", "", ["开发", "窗口", "工具", "管理"]),
    "cstools.ms": ("12_开发工具", "CS工具集", "CS系列开发辅助工具", "", ["开发", "工具", "CS", "辅助"]),
    "UILayout_V1.01_HPK.ms": ("12_开发工具", "UI布局工具", "MaxScript界面布局辅助工具", "HPK", ["开发", "UI", "布局", "界面"]),
    "RescaleWU.ms": ("12_开发工具", "世界单位缩放", "调整场景世界单位比例", "", ["开发", "单位", "缩放", "场景"]),

    # ===== 03_建模工具 =====
    "pxMorphSliders.ms": ("03_建模工具", "变形滑块", "便捷的变形目标滑块控制工具", "px", ["建模", "变形", "Morph", "滑块"]),
    "mirrormorph.ms": ("03_建模工具", "镜像变形", "镜像复制变形目标", "", ["建模", "变形", "镜像", "Morph"]),
}


def get_file_modified_date(filepath):
    """获取文件修改日期"""
    try:
        timestamp = os.path.getmtime(filepath)
        return datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d")
    except:
        return datetime.now().strftime("%Y-%m-%d")


def create_wrapper_script(script_name, display_name):
    """创建wrapper脚本内容"""
    return f'''/*
 * BsScriptHub Wrapper
 * 脚本名称: {display_name}
 * 原始位置: Quote/{script_name}
 */
(
    local scriptPath = (getDir #scripts) + "\\\\BulletScripts\\\\Quote\\\\{script_name}"
    if doesFileExist scriptPath then (
        try (
            fileIn scriptPath
        ) catch (
            messageBox ("执行脚本失败:\\n" + (getCurrentException())) title:"BsScriptHub" beep:false
        )
    ) else (
        messageBox ("找不到脚本文件:\\n" + scriptPath + "\\n\\n请确保 BsKeyTools 安装完整。") title:"BsScriptHub" beep:false
    )
)
'''


def create_json_config(display_name, description, author, keywords, wrapper_name, original_name):
    """创建JSON配置"""
    return {
        "name": display_name,
        "version": "1.0",
        "description": description,
        "author": author if author else "未知",
        "optimizer": "Bullet.S",
        "modified_date": "",  # 会被 generate_index.py 自动填充
        "keywords": keywords,
        "preview": "",
        "script": wrapper_name,
        "url": "",
        "tutorial": ""
    }


def sanitize_filename(name):
    """清理文件名，移除不安全字符"""
    # 移除或替换不安全字符
    unsafe_chars = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', '（', '）']
    result = name
    for char in unsafe_chars:
        result = result.replace(char, '_')
    return result


def main():
    print("=" * 60)
    print("BsScriptHub Quote脚本批量生成工具")
    print("=" * 60)
    
    # 统计
    created_folders = set()
    created_files = 0
    skipped_files = 0
    missing_scripts = []
    
    for script_name, config in SCRIPTS_CONFIG.items():
        category, display_name, description, author, keywords = config
        
        # 检查原始脚本是否存在
        original_path = os.path.join(QUOTE_DIR, script_name)
        if not os.path.exists(original_path):
            missing_scripts.append(script_name)
            print(f"[警告] 原始脚本不存在: {script_name}")
            continue
        
        # 创建分类文件夹
        category_path = os.path.join(SCRIPT_DIR, category)
        if not os.path.exists(category_path):
            os.makedirs(category_path)
            created_folders.add(category)
            print(f"[创建文件夹] {category}")
        
        # 生成wrapper文件名（使用显示名称）
        wrapper_base = sanitize_filename(display_name)
        wrapper_name = wrapper_base + ".ms"
        json_name = wrapper_base + ".json"
        
        wrapper_path = os.path.join(category_path, wrapper_name)
        json_path = os.path.join(category_path, json_name)
        
        # 检查是否已存在
        if os.path.exists(wrapper_path) and os.path.exists(json_path):
            print(f"[跳过] 已存在: {display_name}")
            skipped_files += 1
            continue
        
        # 创建wrapper脚本
        wrapper_content = create_wrapper_script(script_name, display_name)
        with open(wrapper_path, 'w', encoding='utf-8') as f:
            f.write(wrapper_content)
        
        # 创建JSON配置
        json_config = create_json_config(display_name, description, author, keywords, wrapper_name, script_name)
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(json_config, f, ensure_ascii=False, indent=4)
        
        print(f"[创建] {category}/{display_name}")
        created_files += 1
    
    # 输出统计
    print("\n" + "=" * 60)
    print("生成完成!")
    print(f"  新建文件夹: {len(created_folders)} 个")
    print(f"  创建脚本: {created_files} 个")
    print(f"  跳过已存在: {skipped_files} 个")
    if missing_scripts:
        print(f"  缺失原始脚本: {len(missing_scripts)} 个")
        for s in missing_scripts:
            print(f"    - {s}")
    
    print("\n提示: 请运行 generate_index.py 更新索引文件")


if __name__ == "__main__":
    main()

