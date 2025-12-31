# -*- coding: utf-8 -*-
"""
自动扫描 BsScriptHub 目录，生成 scripts_index.json
每次添加/修改脚本后运行此脚本更新索引

用法: python generate_index.py
"""

import os
import json
import subprocess
from datetime import datetime

# 获取当前脚本所在目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INDEX_FILE = os.path.join(SCRIPT_DIR, "scripts_index.json")

def get_git_root():
    """获取 Git 仓库根目录"""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, cwd=SCRIPT_DIR
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    return None

def get_git_commit_date(file_path):
    """获取文件的 Git 最后提交日期"""
    try:
        git_root = get_git_root()
        if not git_root:
            return ""
        
        # 计算相对于仓库根目录的路径
        rel_path = os.path.relpath(file_path, git_root).replace("\\", "/")
        
        result = subprocess.run(
            ["git", "log", "-1", "--format=%ci", "--", rel_path],
            capture_output=True, text=True, cwd=git_root
        )
        if result.returncode == 0 and result.stdout.strip():
            # 格式: "2025-01-15 10:30:00 +0800" -> "2025-01-15"
            return result.stdout.strip().split()[0]
    except:
        pass
    return ""

def scan_scripts():
    """扫描目录生成索引"""
    categories = {}
    
    # 遍历当前目录下的所有文件夹（作为分类）
    for item in sorted(os.listdir(SCRIPT_DIR)):
        item_path = os.path.join(SCRIPT_DIR, item)
        
        # 跳过文件和隐藏文件夹
        if not os.path.isdir(item_path) or item.startswith("."):
            continue
        
        # 跳过 __pycache__ 等特殊目录
        if item.startswith("__"):
            continue
        
        category_name = item
        scripts = []
        
        # 扫描分类文件夹中的 .json 文件
        for file in sorted(os.listdir(item_path)):
            if file.endswith(".json"):
                json_path = os.path.join(item_path, file)
                try:
                    with open(json_path, 'r', encoding='utf-8') as f:
                        script_info = json.load(f)
                    
                    # 确保必要字段存在
                    script_info["category"] = category_name
                    if "name" not in script_info:
                        script_info["name"] = os.path.splitext(file)[0]
                    
                    # 修改日期：从 Git 提交记录获取（真正的最后修改时间）
                    script_file = script_info.get("script", "")
                    if script_file:
                        script_path = os.path.join(item_path, script_file)
                        git_date = get_git_commit_date(script_path)
                        if git_date:
                            script_info["modified_date"] = git_date
                        elif "modified_date" not in script_info:
                            script_info["modified_date"] = ""
                    
                    scripts.append(script_info)
                    print(f"  + {category_name}/{file}")
                except Exception as e:
                    print(f"  ! 读取失败: {json_path} - {e}")
        
        # 即使没有脚本也保留分类（显示空分类）
        categories[category_name] = scripts
        print(f"[{category_name}] {len(scripts)} 个脚本")
    
    return categories

def main():
    print("=" * 50)
    print("BsScriptHub 索引生成器")
    print("=" * 50)
    print(f"扫描目录: {SCRIPT_DIR}")
    print("-" * 50)
    
    categories = scan_scripts()
    
    # 生成索引数据
    index_data = {
        "version": "1.0",
        "categories": categories
    }
    
    # 写入文件
    with open(INDEX_FILE, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, ensure_ascii=False, indent=2)
    
    print("-" * 50)
    total_scripts = sum(len(scripts) for scripts in categories.values())
    print(f"完成! 共 {len(categories)} 个分类, {total_scripts} 个脚本")
    print(f"索引文件: {INDEX_FILE}")

if __name__ == "__main__":
    main()

