#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
下载 GitHub 贡献者头像并合并成一张图片
Download GitHub Contributors Avatars and merge into one image

使用方法 / Usage:
    python download_contributors.py

图片将保存到当前目录下的 contributors.bmp
"""

import os
import sys
import json
import urllib.request
import ssl
import io
import subprocess

def install_pillow():
    """自动安装 Pillow"""
    print("[INFO] Installing Pillow...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow", "-q"])
        print("[OK] Pillow installed successfully!")
        return True
    except Exception as e:
        print(f"[FAIL] Failed to install Pillow: {e}")
        return False

def download_and_merge_avatars():
    """下载贡献者头像并合并成一张图片"""
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "contributors.bmp")
    
    # GitHub API URL
    api_url = "https://api.github.com/repos/AniBullet/BsKeyTools/contributors"
    
    print("Getting contributors list from GitHub...")
    
    try:
        # SSL context
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE
        
        # Get contributors list
        request = urllib.request.Request(api_url)
        request.add_header('User-Agent', 'Mozilla/5.0')
        request.add_header('Accept', 'application/vnd.github.v3+json')
        
        with urllib.request.urlopen(request, context=ssl_context, timeout=30) as response:
            contributors = json.loads(response.read().decode('utf-8'))
        
        print(f"Found {len(contributors)} contributors")
        
        # Download avatars
        avatar_size = 48  # 48x48 pixels
        avatars = []
        
        for i, contributor in enumerate(contributors[:12]):  # Max 12 contributors
            username = contributor['login']
            avatar_url = contributor['avatar_url'] + f"&s={avatar_size}"
            
            print(f"  Downloading [{i+1}/{min(len(contributors), 12)}] {username}...")
            
            try:
                request = urllib.request.Request(avatar_url)
                request.add_header('User-Agent', 'Mozilla/5.0')
                
                with urllib.request.urlopen(request, context=ssl_context, timeout=30) as response:
                    avatar_data = response.read()
                    avatars.append((username, avatar_data))
                    print(f"    [OK]")
            except Exception as e:
                print(f"    [FAIL] {e}")
        
        if not avatars:
            print("[FAIL] No avatars downloaded")
            return False
        
        # Try to use PIL to merge images
        try:
            from PIL import Image
        except ImportError:
            print("\n[WARN] Pillow not installed, trying to install...")
            if install_pillow():
                from PIL import Image
            else:
                # Save individual avatars as fallback
                avatars_dir = os.path.join(script_dir, "contributors_avatars")
                if not os.path.exists(avatars_dir):
                    os.makedirs(avatars_dir)
                
                for username, data in avatars:
                    avatar_path = os.path.join(avatars_dir, f"{username}.png")
                    with open(avatar_path, 'wb') as f:
                        f.write(data)
                
                print(f"[OK] Individual avatars saved to: {avatars_dir}")
                return False
        
        # Calculate merged image size
        cols = min(len(avatars), 6)
        rows = (len(avatars) + cols - 1) // cols
        merged_width = cols * avatar_size + (cols - 1) * 4  # 4px gap
        merged_height = rows * avatar_size + (rows - 1) * 4
        
        # Create merged image
        merged = Image.new('RGB', (merged_width, merged_height), (45, 45, 45))
        
        for i, (username, data) in enumerate(avatars):
            try:
                img = Image.open(io.BytesIO(data))
                img = img.convert('RGB')
                img = img.resize((avatar_size, avatar_size), Image.Resampling.LANCZOS)
                
                col = i % cols
                row = i // cols
                x = col * (avatar_size + 4)
                y = row * (avatar_size + 4)
                
                merged.paste(img, (x, y))
            except Exception as e:
                print(f"    [WARN] Failed to process {username}: {e}")
        
        # Save as BMP (MaxScript friendly)
        merged.save(output_path, 'BMP')
        print(f"\n[OK] Merged image saved to: {output_path}")
        print(f"[OK] Size: {merged_width}x{merged_height} pixels")
        return True
        
    except Exception as e:
        print(f"[FAIL] Error: {e}")
        return False


if __name__ == "__main__":
    print("=" * 50)
    print("BsKeyTools Contributors Avatar Downloader")
    print("=" * 50)
    print()
    
    success = download_and_merge_avatars()
    
    print()
    print("=" * 50)
    print("Done!")
