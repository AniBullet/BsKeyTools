# -*- coding: utf-8 -*-
"""
自动扫描 BsScriptHub 目录，生成 scripts_index.json
每次添加/修改脚本后运行此脚本更新索引

用法: python generate_index.py
"""

import os
import json
from datetime import datetime

# 获取当前脚本所在目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INDEX_FILE = os.path.join(SCRIPT_DIR, "scripts_index.json")

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
                    
                    # 自动读取脚本文件的修改日期
                    script_file = script_info.get("script", "")
                    if script_file:
                        script_path = os.path.join(item_path, script_file)
                        if os.path.exists(script_path):
                            mtime = os.path.getmtime(script_path)
                            script_info["modified_date"] = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d")
                    
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

