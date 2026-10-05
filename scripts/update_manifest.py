#!/usr/bin/env python3
"""
update_manifest.py — BsKeyTools 版本文件自动更新脚本
运行时机：发版前在 dev 本地运行并提交结果（main 受保护，CI 不能回推）；CI 构建时也会运行以校验版本
功能：
  1. 从 BulletKeyTools.ms 读取 BsKeyTools 版本号
  2. 从 BsCleanVirus.ms 读取 BsCleanVirus 版本号
  3. 写入 version.dat（单行：BsKeyTools 版本）
  4. 更新 Setup_BsKeyTools.nsi / Setup_BsCleanVirus.nsi 中的版本号
"""

import os
import re

REPO_ROOT      = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERSION_DAT    = os.path.join(REPO_ROOT, "_BsKeyTools", "version.dat")
MAIN_MS        = os.path.join(REPO_ROOT, "_BsKeyTools", "Scripts", "BulletScripts", "BulletKeyTools.ms")
CLEANER_MS     = os.path.join(REPO_ROOT, "_BsKeyTools", "Scripts", "BulletScripts", "BsCleanVirus.ms")
NSIS_BSKT      = os.path.join(REPO_ROOT, "_BsKeyTools", "Setup_BsKeyTools.nsi")
NSIS_BSCV      = os.path.join(REPO_ROOT, "_BsKeyTools", "Setup_BsCleanVirus.nsi")


def read_bskeytools_version() -> str:
    with open(MAIN_MS, encoding="utf-8", errors="replace") as f:
        content = f.read()
    m = re.search(r'global\s+curVerBsKeyTools\s*=\s*"([^"]+)"', content)
    if not m:
        raise RuntimeError(f"无法在 {MAIN_MS} 中找到 curVerBsKeyTools")
    return m.group(1)


def read_bscleanvirus_version() -> str:
    """从 BsCleanVirus.ms 读取 curVerBsCleanVirus，与 BsKeyTools 读法一致。"""
    with open(CLEANER_MS, encoding="utf-8", errors="replace") as f:
        content = f.read()
    m = re.search(r'global\s+curVerBsCleanVirus\s*=\s*"([^"]+)"', content)
    if not m:
        raise RuntimeError(f"无法在 {CLEANER_MS} 中找到 curVerBsCleanVirus")
    return m.group(1)


def validate_release_version(bskt_version: str) -> None:
    """确保 CI 传入的 RELEASE_VERSION 与脚本内版本一致。"""
    release_version = os.environ.get("RELEASE_VERSION", "")
    if not release_version:
        return
    if release_version != bskt_version:
        raise RuntimeError(
            f"release 版本不一致: RELEASE_VERSION={release_version}, BulletKeyTools.ms={bskt_version}"
        )


def write_version_dat(bskt_version: str) -> None:
    """写入 version.dat（单行 BsKeyTools 版本，不再包含 BsCleanVirus）。"""
    with open(VERSION_DAT, "w", encoding="utf-8", newline="\n") as f:
        f.write(bskt_version + "\n")
    print(f"[update_manifest] version.dat → {bskt_version}")


UTF8_BOM = b"\xef\xbb\xbf"


def read_nsis(path: str) -> str:
    """读取 .nsi：必须是 UTF-8 带 BOM（Unicode true），严格解码，保留原换行。"""
    with open(path, "rb") as f:
        data = f.read()
    if not data.startswith(UTF8_BOM):
        raise RuntimeError(f"{path} 缺少 UTF-8 BOM（NSIS Unicode 脚本需要 BOM）")
    return data[len(UTF8_BOM):].decode("utf-8")


def write_nsis(path: str, content: str) -> None:
    with open(path, "wb") as f:
        f.write(UTF8_BOM + content.encode("utf-8"))


def update_bskeytools_nsis_version(version: str) -> None:
    """更新 Setup_BsKeyTools.nsi 中的 PRODUCT_VERSION_NUM。"""
    if not os.path.isfile(NSIS_BSKT):
        return
    content = read_nsis(NSIS_BSKT)
    new_content = re.sub(
        r'(!define\s+PRODUCT_VERSION_NUM\s+")[^"]*(")',
        lambda m: m.group(1) + version + m.group(2),
        content,
    )
    if new_content != content:
        write_nsis(NSIS_BSKT, new_content)
        print(f"[update_manifest] Setup_BsKeyTools.nsi PRODUCT_VERSION_NUM → {version}")


def update_bscleanvirus_nsis_version(version: str) -> None:
    """更新 Setup_BsCleanVirus.nsi 中的 PRODUCT_VERSION（格式 _vX.X）。"""
    if not os.path.isfile(NSIS_BSCV):
        return
    content = read_nsis(NSIS_BSCV)
    new_content = re.sub(
        r'(!define\s+PRODUCT_VERSION\s+")_v[^"]*(")',
        lambda m: m.group(1) + "_v" + version + m.group(2),
        content,
    )
    if new_content != content:
        write_nsis(NSIS_BSCV, new_content)
        print(f"[update_manifest] Setup_BsCleanVirus.nsi PRODUCT_VERSION → _v{version}")


def main():
    print("[update_manifest] 开始更新版本文件 ...")

    bskt_version = read_bskeytools_version()
    bscv_version = read_bscleanvirus_version()
    validate_release_version(bskt_version)

    print(f"[update_manifest] BsKeyTools: {bskt_version}  BsCleanVirus: {bscv_version}")

    write_version_dat(bskt_version)
    update_bskeytools_nsis_version(bskt_version)
    update_bscleanvirus_nsis_version(bscv_version)

    print("[update_manifest] 完成 OK")


if __name__ == "__main__":
    main()
