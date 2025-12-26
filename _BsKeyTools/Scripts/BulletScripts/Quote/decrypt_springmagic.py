# -*- coding: utf-8 -*-
"""
SpringMagic MaxScript 解密工具
解密使用 DES 加密的 MaxScript 文件
"""

import re
import base64
from Crypto.Cipher import DES

def des_decrypt(encrypted_b64, key, iv):
    """使用 DES 解密 Base64 编码的字符串"""
    try:
        encrypted_data = base64.b64decode(encrypted_b64)
        cipher = DES.new(key.encode('utf-8'), DES.MODE_CBC, iv.encode('utf-8'))
        decrypted_data = cipher.decrypt(encrypted_data)
        padding_len = decrypted_data[-1]
        if padding_len <= 8:
            decrypted_data = decrypted_data[:-padding_len]
        return decrypted_data.decode('utf-8')
    except Exception as e:
        return f"[解密失败: {e}]"

def parse_obfuscated_values(content):
    """解析混淆的变量赋值，提取变量名和对应的值"""
    values = {}
    
    pattern = r"::'([IilL1]+)'=\(([^;]+)\);"
    matches = re.findall(pattern, content)
    
    for var_name, expr in matches:
        try:
            expr = expr.replace('--', '- -')
            value = eval(expr)
            if isinstance(value, float):
                if value == int(value):
                    value = int(value)
                else:
                    value = round(value, 6)
            values[var_name.lower()] = value
            values[var_name.upper()] = value
        except:
            pass
    
    encrypt_pattern = r"::'([IilL1]+)'='lllil1l1li1IllIliiI'\s+\"([^\"]+)\"\s+\"(\d+)\"\s+\"(\d+)\";"
    encrypt_matches = re.findall(encrypt_pattern, content)
    
    for var_name, b64, key, iv in encrypt_matches:
        decrypted = des_decrypt(b64, key, iv)
        values[var_name.lower()] = decrypted
        values[var_name.upper()] = decrypted
    
    return values

# MaxScript 关键字（需要保持小写）
MAXSCRIPT_KEYWORDS = {
    'global', 'local', 'fn', 'function', 'mapped', 'struct', 'rollout', 'dialog',
    'if', 'then', 'else', 'do', 'while', 'for', 'to', 'by', 'in', 'of', 'from',
    'where', 'collect', 'with', 'undo', 'on', 'off', 'return', 'exit', 'continue',
    'try', 'catch', 'throw', 'as', 'and', 'or', 'not', 'case', 'default',
    'true', 'false', 'undefined', 'ok', 'dontcollect', 'silentvalue',
    'button', 'spinner', 'slider', 'checkbox', 'radiobuttons', 'listbox',
    'dropdownlist', 'edittext', 'label', 'groupbox', 'bitmap', 'mapbutton',
    'materialbutton', 'pickbutton', 'colorpicker', 'combobox', 'progressbar',
    'timer', 'activexcontrol', 'dotnetcontrol', 'imgtag', 'linkcontrol',
    'multilistbox', 'popupmenu', 'subrollout', 'treeview', 'curvecontrol',
    'parameters', 'attributes', 'plugin', 'tool', 'macroscript', 'utility',
    'rcmenu', 'menuitem', 'separator', 'submenu', 'when', 'change', 'set',
    'animate', 'at', 'time', 'level', 'persistent', 'private', 'public',
    'readonly', 'type', 'category', 'pos', 'width', 'height', 'style',
    'tooltip', 'enabled', 'visible', 'checked', 'items', 'selection',
    'value', 'text', 'caption', 'range', 'scale', 'offset', 'ticks',
    'controller', 'classof', 'superclassof', 'iskindof', 'isvalidnode',
    'execute', 'format', 'print', 'messagebox', 'querybox', 'yesnocancelbox',
    'filein', 'include', 'createfile', 'openfile', 'close', 'flush',
    'mod', 'abs', 'ceil', 'floor', 'sqrt', 'pow', 'exp', 'log',
    'biped_object', 'objects', 'geometry', 'shapes', 'lights', 'cameras',
}

# 用于智能驼峰转换的常见单词列表（按长度降序排列以优先匹配长单词）
COMMON_WORDS = sorted([
    # MaxScript 特有
    'rollout', 'spring', 'magic', 'anim', 'layer', 'manager', 'config',
    'button', 'spinner', 'checkbox', 'label', 'group', 'dialog', 'window',
    'controller', 'transform', 'position', 'rotation', 'scale', 'matrix',
    'euler', 'quat', 'quaternion', 'vector', 'point', 'color', 'bitmap',
    'material', 'texture', 'modifier', 'mesh', 'poly', 'spline', 'shape',
    'bone', 'biped', 'skin', 'morph', 'physique', 'rig', 'skeleton',
    'keyframe', 'tangent', 'smooth', 'flat', 'linear', 'step', 'bezier',
    'viewport', 'render', 'scene', 'object', 'node', 'helper', 'dummy',
    'animation', 'timeline', 'frame', 'time', 'range', 'start', 'end',
    'desktop', 'size', 'print', 'elements', 'element', 'options', 'sys',
    
    # 常见编程词汇
    'get', 'set', 'add', 'del', 'delete', 'remove', 'insert', 'update',
    'create', 'destroy', 'init', 'load', 'save', 'read', 'write', 'open', 'close',
    'find', 'search', 'select', 'pick', 'collect', 'filter', 'sort', 'copy',
    'move', 'rotate', 'translate', 'offset', 'align', 'snap', 'mirror', 'flip',
    'show', 'hide', 'toggle', 'switch', 'change', 'modify', 'apply', 'reset',
    'enable', 'disable', 'active', 'visible', 'hidden', 'lock', 'unlock',
    'current', 'selected', 'all', 'none', 'default', 'custom', 'user',
    'parent', 'child', 'children', 'root', 'tip', 'base', 'top', 'bottom',
    'left', 'right', 'front', 'back', 'up', 'down', 'north', 'south', 'east', 'west',
    'min', 'max', 'avg', 'sum', 'count', 'index', 'item', 'items', 'list', 'array',
    'name', 'value', 'type', 'class', 'info', 'data', 'attr', 'prop', 'property',
    'old', 'new', 'prev', 'next', 'first', 'last', 'begin', 'end',
    'input', 'output', 'source', 'target', 'dest', 'result', 'return',
    'error', 'warning', 'message', 'box', 'dialog', 'prompt', 'confirm',
    'file', 'path', 'dir', 'folder', 'ini', 'cfg', 'config', 'setting', 'option',
    'str', 'string', 'int', 'float', 'num', 'number', 'bool', 'boolean',
    'arr', 'array', 'vec', 'vector', 'mat', 'matrix', 'pos', 'rot', 'scl',
    'btn', 'lbl', 'txt', 'chk', 'spn', 'ddl', 'lst', 'grp', 'img', 'pic',
    'conf', 'ctrl', 'sel', 'obj', 'objs', 'desc', 'desk',
    
    # SpringMagic 特有
    'sm', 'lang', 'cn', 'en', 'day', 'week', 'loops', 'subs', 'delay', 'loop',
    'motion', 'bones', 'bnum', 'straight', 'paste', 'bake', 'keys', 'outrange',
    'decimal', 'toolbar', 'pose', 'weight', 'location', 'collapse', 'clear',
    'noise', 'keep', 'retarget', 'export', 'import', 'sce', 'tcb', 'xspring',
    'x', 'y', 'z',
    
    # 2-3字母常见缩写
    'fn', 'bt', 'ms', 'ui', 'id', 'ok', 'ca', 'cb', 'ob',
], key=len, reverse=True)

def to_camel_case(name):
    """将全小写名称转换为驼峰命名"""
    if not name or name in MAXSCRIPT_KEYWORDS:
        return name
    
    # 如果包含下划线，按下划线分割后转驼峰
    if '_' in name:
        parts = name.split('_')
        result = parts[0]
        for part in parts[1:]:
            if part:
                result += part[0].upper() + part[1:] if len(part) > 1 else part.upper()
        return result
    
    # 尝试识别单词边界
    result = []
    remaining = name.lower()
    
    while remaining:
        found = False
        for word in COMMON_WORDS:
            if remaining.startswith(word):
                result.append(word)
                remaining = remaining[len(word):]
                found = True
                break
        
        if not found:
            # 没找到匹配的单词，取一个字符
            result.append(remaining[0])
            remaining = remaining[1:]
    
    # 组合成驼峰格式（第一个单词小写，后续首字母大写）
    if not result:
        return name
    
    camel = result[0]
    for word in result[1:]:
        if len(word) == 1:
            camel += word
        else:
            camel += word[0].upper() + word[1:]
    
    return camel

def fix_case_and_quotes(content):
    """修复大小写并移除不必要的单引号"""
    
    keyword_lower = {kw.upper(): kw for kw in MAXSCRIPT_KEYWORDS}
    
    def replace_quoted(match):
        word = match.group(1)
        word_upper = word.upper()
        word_lower = word.lower()
        
        # 如果是关键字，返回小写
        if word_lower in MAXSCRIPT_KEYWORDS:
            return word_lower
        
        # 否则转换为驼峰
        return to_camel_case(word_lower)
    
    # 匹配单引号包裹的单词 'WORD'
    content = re.sub(r"'([A-Za-z_][A-Za-z0-9_]*)'", replace_quoted, content)
    
    return content

def format_maxscript(content):
    """格式化 MaxScript 代码，添加正确的缩进"""
    lines = content.split('\n')
    formatted_lines = []
    indent_str = '\t'
    
    # 用于跟踪是否在多行字符串中
    in_multiline_string = False
    # 使用括号栈来准确跟踪嵌套级别
    paren_depth = 0
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        # 跳过空行
        if not stripped:
            formatted_lines.append('')
            continue
        
        # 检查是否在多行字符串中
        if in_multiline_string:
            formatted_lines.append(line)  # 保持原样
            # 检查字符串结束
            if stripped == '"' or (stripped.endswith('"') and not stripped.endswith('\\"')):
                in_multiline_string = False
            continue
        
        # 检测多行字符串开始 (str = ")
        if re.match(r'^[a-zA-Z_]\w*\s*=\s*"$', stripped):
            in_multiline_string = True
            formatted_lines.append(indent_str * paren_depth + stripped)
            continue
        
        # 注释行
        if stripped.startswith('--') or stripped.startswith('/*') or stripped.startswith('*'):
            formatted_lines.append(indent_str * paren_depth + stripped)
            continue
        
        # 计算这行开始的 ( 和 ) 数量
        open_count = 0
        close_count = 0
        in_string = False
        prev_char = ''
        for char in stripped:
            if char == '"' and prev_char != '\\':
                in_string = not in_string
            elif not in_string:
                if char == '(':
                    open_count += 1
                elif char == ')':
                    close_count += 1
            prev_char = char
        
        # 如果行以 ) 开始，先减少缩进再输出
        leading_close = 0
        for char in stripped:
            if char == ')':
                leading_close += 1
            elif char not in ' \t':
                break
        
        # 计算当前行的缩进级别
        current_indent = max(0, paren_depth - leading_close)
        
        # 添加当前行（带缩进）
        formatted_lines.append(indent_str * current_indent + stripped)
        
        # 更新括号深度
        paren_depth = max(0, paren_depth + open_count - close_count)
    
    return '\n'.join(formatted_lines)

def decrypt_file(input_path, output_path):
    """解密整个文件"""
    
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("1. 解析混淆变量...")
    obfuscated_values = parse_obfuscated_values(content)
    print(f"   找到 {len(obfuscated_values) // 2} 个混淆变量")
    
    print("\n2. 解密加密字符串...")
    pattern = r"'lllil1l1li1IllIliiI'\s+\"([^\"]+)\"\s+\"(\d+)\"\s+\"(\d+)\""
    
    def replace_encrypted(match):
        encrypted_b64 = match.group(1)
        key = match.group(2)
        iv = match.group(3)
        decrypted = des_decrypt(encrypted_b64, key, iv)
        print(f"   {encrypted_b64[:20]}... -> {decrypted}")
        return f'"{decrypted}"'
    
    decrypted_content = re.sub(pattern, replace_encrypted, content)
    
    print("\n3. 替换混淆变量名为实际值...")
    sorted_vars = sorted(obfuscated_values.items(), key=lambda x: len(x[0]), reverse=True)
    
    for var_name, value in sorted_vars:
        var_pattern = rf"'({re.escape(var_name)})'"
        if isinstance(value, str):
            # 如果字符串已经带引号，直接使用；否则加引号
            if value.startswith('"') and value.endswith('"'):
                replacement = value
            elif value == "":
                replacement = '""'
            else:
                replacement = f'"{value}"'
        else:
            replacement = str(value)
        decrypted_content = re.sub(var_pattern, replacement, decrypted_content, flags=re.IGNORECASE)
    
    print("\n4. 移除解密函数定义和初始化函数...")
    lines = decrypted_content.split('\n')
    cleaned_lines = []
    
    for line in lines:
        if "lllil1l1li1IllIliiI" in line and "dotNetClass" in line:
            continue
        if re.search(r"::\d+(\.\d+)?=\(", line):
            continue
        cleaned_lines.append(line)
    
    decrypted_content = '\n'.join(cleaned_lines)
    
    print("\n5. 修复大小写（智能驼峰转换）...")
    decrypted_content = fix_case_and_quotes(decrypted_content)
    
    print("\n6. 格式化代码（添加缩进）...")
    decrypted_content = format_maxscript(decrypted_content)
    
    # 清理多余的空行
    decrypted_content = re.sub(r'\n{3,}', '\n\n', decrypted_content)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(decrypted_content)
    
    print(f"\n解密完成！输出文件: {output_path}")
    
    # 显示一些转换示例
    print("\n驼峰转换示例:")
    examples = ['rolloutspringmagic', 'fngetsmconfig', 'animlayercolor', 
                'fnloadconfiginispringmagic', 'arrloadvalue', 'tangentkeystart']
    for ex in examples:
        print(f"   {ex} -> {to_camel_case(ex)}")

if __name__ == "__main__":
    import os
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_file = os.path.join(script_dir, "SpringMagic_Enhanced.ms")
    output_file = os.path.join(script_dir, "SpringMagic_Enhanced_Decrypted.ms")
    
    decrypt_file(input_file, output_file)
