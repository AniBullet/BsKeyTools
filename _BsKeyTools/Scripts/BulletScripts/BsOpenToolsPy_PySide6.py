# -*- coding: utf-8 -*-
"""
时光机 v2.0 - 快速打开max文件
Author: Bullet.S
Compatibility: 3ds Max 2025-2026 (PySide6)
"""

import os
import sys
import json
import datetime
import re
import subprocess
import ctypes
from ctypes import wintypes
import xml.etree.ElementTree as ET

# region HiDPI Support - Must be set before importing Qt
os.environ.setdefault("QT_ENABLE_HIGHDPI_SCALING", "1")
os.environ.setdefault("QT_SCALE_FACTOR_ROUNDING_POLICY", "PassThrough")
# endregion

from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QLineEdit, QListWidget, QListWidgetItem,
    QGroupBox, QCheckBox, QRadioButton, QButtonGroup, QMessageBox,
    QFileDialog, QInputDialog, QMenu, QSplitter, QSizePolicy, QToolButton,
    QDialog, QFrame
)
from PySide6.QtCore import Qt, Signal, QSize, QUrl, QTimer, QProcess
from PySide6.QtGui import QPixmap, QDesktopServices, QAction

try:
    import pymxs
    from pymxs import runtime as rt
    IN_MAX = True
except ImportError:
    IN_MAX = False

VERSION = "2.0"

# Windows API for embedding
user32 = ctypes.WinDLL("user32", use_last_error=True)
SetParent = user32.SetParent
SetParent.argtypes = [wintypes.HWND, wintypes.HWND]
SetParent.restype = wintypes.HWND
ShowWindow = user32.ShowWindow
ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
SetWindowPos = user32.SetWindowPos
SetWindowPos.argtypes = [wintypes.HWND, wintypes.HWND, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_uint]
GetWindowThreadProcessId = user32.GetWindowThreadProcessId
GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
EnumWindows = user32.EnumWindows
GetAncestor = user32.GetAncestor
GetAncestor.argtypes = [wintypes.HWND, wintypes.UINT]
GetAncestor.restype = wintypes.HWND
if ctypes.sizeof(ctypes.c_void_p) == 8:
    GetWindowLongX = user32.GetWindowLongPtrW
    SetWindowLongX = user32.SetWindowLongPtrW
else:
    GetWindowLongX = user32.GetWindowLongW
    SetWindowLongX = user32.SetWindowLongW

GWL_STYLE = -16
WS_CHILD = 0x40000000
WS_POPUP = 0x80000000
WS_CAPTION = 0x00C00000
WS_THICKFRAME = 0x00040000
SWP_NOZORDER = 0x0004
SWP_FRAMECHANGED = 0x0020
SWP_NOMOVE = 0x0002
SWP_NOSIZE = 0x0001
SW_SHOW = 5
GA_ROOT = 2

# region Style Sheet with HiDPI Support
def _get_dpi_scale():
    """Get current DPI scale factor"""
    try:
        app = QApplication.instance()
        if app:
            screen = app.primaryScreen()
            if screen:
                return screen.logicalDotsPerInch() / 96.0
    except:
        pass
    return 1.0

def _scaled_font(base_size, dpi_scale=None):
    """Return DPI-scaled font size in pixels"""
    if dpi_scale is None:
        dpi_scale = _get_dpi_scale()
    return int(base_size * dpi_scale)

def _get_style(dpi_scale=1.0):
    """Generate stylesheet with DPI-scaled font sizes"""
    base_font = 11
    small_font = 10
    if dpi_scale > 1.0:
        base_font = int(base_font * dpi_scale)
        small_font = int(small_font * dpi_scale)
    
    return """
* { font-family: "Microsoft YaHei", "Segoe UI"; font-size: %dpx; color: #ddd; }
QWidget { background: #3c3c3c; color: #ddd; }
QGroupBox { 
    border: 1px solid #555; border-radius: 3px; 
    margin-top: 10px; padding: 3px; padding-top: 14px;
    font-weight: bold; color: #8cf;
}
QGroupBox::title { subcontrol-origin: margin; left: 6px; padding: 0 4px; color: #8cf; }
QPushButton, QToolButton {
    background: #4a4a4a; border: 1px solid #555; border-radius: 2px;
    padding: 3px 8px; min-height: 20px; color: #ddd;
}
QPushButton:hover, QToolButton:hover { background: #555; border-color: #7af; color: #fff; }
QPushButton:pressed { background: #333; color: #fff; }
QPushButton:checked { background: #357; border-color: #7af; color: #fff; }
QLineEdit {
    background: #333; border: 1px solid #555; border-radius: 2px;
    padding: 3px 5px; selection-background-color: #357; color: #ddd;
    selection-color: #fff;
}
QLineEdit:focus { border-color: #7af; color: #fff; }
QLineEdit:read-only { background: #2d2d2d; color: #999; }
QListWidget {
    background: #2d2d2d; border: 1px solid #555; border-radius: 2px; outline: none;
    color: #ddd;
}
QListWidget::item { padding: 4px; border-radius: 2px; color: #ddd; }
QListWidget::item:selected { background: #357; color: #fff; }
QListWidget::item:hover:!selected { background: #444; color: #fff; }
QLabel { color: #ddd; }
QCheckBox { spacing: 6px; color: #ddd; }
QCheckBox::indicator {
    width: 14px; height: 14px;
    border: 2px solid #666; border-radius: 3px;
    background: #2d2d2d;
}
QCheckBox::indicator:checked {
    background: #5af; border-color: #5af;
}
QCheckBox::indicator:hover { border-color: #8cf; }
QRadioButton { spacing: 6px; color: #ddd; }
QRadioButton::indicator {
    width: 14px; height: 14px;
    border: 2px solid #666; border-radius: 8px;
    background: #2d2d2d;
}
QRadioButton::indicator:checked {
    background: #5af; border-color: #5af;
}
QRadioButton::indicator:hover { border-color: #8cf; }
QMenu { background: #444; border: 1px solid #555; color: #ddd; }
QMenu::item { padding: 5px 20px; color: #ddd; }
QMenu::item:selected { background: #357; color: #fff; }
QSplitter::handle { background: #555; }
QSplitter::handle:horizontal { width: 3px; }
QToolTip { background: #444; color: #fff; border: 1px solid #555; padding: 4px; }
""" % (base_font, )

# Default style for backward compatibility
STYLE = _get_style(1.0)
# endregion


# FBX嵌入容器
class FbxEmbedArea(QWidget):
    """用于嵌入FBX Review窗口的容器"""
    resized = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setAttribute(Qt.WA_NativeWindow, True)
        self.setMinimumSize(200, 150)
        self.setStyleSheet("background: #202020; border: 1px solid #444;")
    
    def resizeEvent(self, e):
        super().resizeEvent(e)
        self.resized.emit()


def get_hwnd_from_widget(widget):
    """获取Qt Widget的Windows句柄"""
    try:
        return int(widget.winId())
    except:
        return None

def get_root_windows_by_pid(pid):
    """获取指定进程的所有顶层窗口"""
    out = []
    @ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
    def cb(hwnd, lParam):
        lpdwPid = wintypes.DWORD()
        GetWindowThreadProcessId(hwnd, ctypes.byref(lpdwPid))
        if lpdwPid.value == pid:
            root = GetAncestor(hwnd, GA_ROOT)
            if root == hwnd:
                out.append(hwnd)
        return True
    EnumWindows(cb, 0)
    return out

def make_child_style(hwnd):
    """将窗口设置为子窗口样式"""
    style = GetWindowLongX(hwnd, GWL_STYLE)
    style &= ~(WS_POPUP | WS_CAPTION | WS_THICKFRAME)
    style |= WS_CHILD
    SetWindowLongX(hwnd, GWL_STYLE, style)
    SetWindowPos(hwnd, None, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED)


class Config:
    def __init__(self):
        self.path = self._get_path()
        self.data = self._load()
    
    def _get_path(self):
        if IN_MAX:
            try:
                return os.path.join(rt.getDir(rt.name("maxData")), "BsOpenToolsPy.json")
            except: pass
        return os.path.join(os.path.expanduser("~"), ".BsKeyTools", "BsOpenToolsPy.json")
    
    def _load(self):
        defaults = {
            "pos": [100, 100], "size": [580, 420], "favorites": [], "filters": [],
            "file_type": 0, "desktop": "", "silent": True, "reverse": False,
            "auto_fbx": True, "preview": False, "selected_fav": 0
        }
        if os.path.exists(self.path):
            try:
                with open(self.path, 'r', encoding='utf-8') as f:
                    d = json.load(f)
                    for k, v in defaults.items():
                        if k not in d: d[k] = v
                    return d
            except: pass
        return defaults
    
    def save(self):
        try:
            os.makedirs(os.path.dirname(self.path), exist_ok=True)
            with open(self.path, 'w', encoding='utf-8') as f:
                json.dump(self.data, f, ensure_ascii=False, indent=2)
        except: pass
    
    def get(self, k, d=None): return self.data.get(k, d)
    def set(self, k, v): self.data[k] = v


class FileOps:
    @staticmethod
    def natural_key(s):
        return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]
    
    @staticmethod
    def get_folders(path):
        if not os.path.isdir(path): return []
        try:
            items = [os.path.join(path, x) for x in os.listdir(path) if os.path.isdir(os.path.join(path, x))]
            return sorted(items, key=lambda x: FileOps.natural_key(os.path.basename(x)))
        except: return []
    
    @staticmethod
    def get_files(path, ext):
        if not os.path.isdir(path): return []
        try:
            items = []
            for x in os.listdir(path):
                fp = os.path.join(path, x)
                if os.path.isfile(fp):
                    _, e = os.path.splitext(x.lower())
                    if ext.endswith('*'):
                        if e.startswith(ext[:-1]): items.append(fp)
                    elif e == ext.lower(): items.append(fp)
            return sorted(items, key=lambda x: FileOps.natural_key(os.path.basename(x)))
        except: return []
    
    @staticmethod
    def get_parent(p): return os.path.dirname(p.rstrip(os.sep))
    
    @staticmethod
    def fmt_size(s):
        if s >= 1048576: return "%.1f MB" % (s / 1048576)
        if s >= 1024: return "%.1f KB" % (s / 1024)
        return "%d B" % s
    
    @staticmethod
    def get_info(p):
        if not os.path.exists(p): return {}
        s = os.stat(p)
        return {'size': FileOps.fmt_size(s.st_size), 
                'time': datetime.datetime.fromtimestamp(s.st_mtime).strftime('%Y/%m/%d %H:%M')}
    
    @staticmethod
    def get_recent():
        if not IN_MAX: return []
        try:
            xml = os.path.join(rt.getDir(rt.name("maxData")), "RecentDocuments.xml")
            if not os.path.exists(xml): return []
            tree = ET.parse(xml)
            files = []
            for e in tree.getroot().iter():
                if e.text:
                    t = e.text.strip()
                    if t.lower().endswith('.max') and t not in files: files.append(t)
            return files
        except: return []


class MaxOps:
    @staticmethod
    def open_max(p, quiet=True):
        if not IN_MAX: return
        try:
            if rt.checkForSave(): rt.loadMaxFile(p, useFileUnits=True, quiet=quiet)
        except Exception as e: QMessageBox.warning(None, "错误", str(e))
    
    @staticmethod
    def import_fbx(p):
        if not IN_MAX: return
        try: rt.importFile(p, rt.name("noPrompt"), using=rt.FBXIMP)
        except Exception as e: QMessageBox.warning(None, "错误", str(e))
    
    @staticmethod
    def load_bip(p):
        if not IN_MAX: return
        try:
            roots = []
            for o in list(rt.selection):
                if rt.classOf(o) == rt.Biped_Object and not o.isHidden:
                    r = o.controller.rootNode
                    if r not in roots: roots.append(r)
            if roots:
                for r in roots:
                    rt.biped.loadBipFile(r.controller, p, rt.name("noRedraw"))
                rt.forceCompleteRedraw()
            else: QMessageBox.information(None, "提示", "请先选择Biped对象")
        except Exception as e: QMessageBox.warning(None, "错误", str(e))
    
    @staticmethod
    def run_script(p):
        if not IN_MAX: return
        try: rt.fileIn(p)
        except Exception as e: QMessageBox.warning(None, "错误", str(e))
    
    @staticmethod
    def get_path():
        if IN_MAX:
            try:
                p = rt.maxFilePath
                if p: return p.rstrip("\\")
            except: pass
        return ""
    
    @staticmethod
    def get_scripts(): return rt.getDir(rt.name("scripts")) if IN_MAX else ""
    
    @staticmethod
    def get_autoback(): return rt.getDir(rt.name("autoback")) if IN_MAX else ""
    
    @staticmethod
    def get_thumb(p):
        if not IN_MAX: return None
        try:
            dll = os.path.join(rt.getDir(rt.name("scripts")), "BulletScripts", "Res", "MaxFileUtilitiesDotNet.dll")
            if os.path.exists(dll):
                rt.dotnet.loadAssembly(dll)
                mfu = rt.dotNetObject("MaxFileUtilities.MaxFileInterface")
                thumb = mfu.GetThumbnail(p)
                if thumb:
                    ms = rt.dotNetObject("System.IO.MemoryStream")
                    thumb.Save(ms, rt.dotNetClass("System.Drawing.Imaging.ImageFormat").Png)
                    pix = QPixmap()
                    pix.loadFromData(bytes(list(ms.ToArray())))
                    return pix
        except: pass
        return None
    
    @staticmethod
    def get_max_file_info(p):
        """获取Max文件的详细信息"""
        if not IN_MAX: return {}
        info = {}
        try:
            dll = os.path.join(rt.getDir(rt.name("scripts")), "BulletScripts", "Res", "MaxFileUtilitiesDotNet.dll")
            if os.path.exists(dll):
                rt.dotnet.loadAssembly(dll)
                mfu = rt.dotNetObject("MaxFileUtilities.MaxFileInterface")
                
                # 获取基本信息
                general = mfu.GetGeneralInformation(p)
                if general:
                    if hasattr(general, 'ReadableSavedAsVersion') and general.ReadableSavedAsVersion:
                        info['version'] = str(general.ReadableSavedAsVersion)
                
                # 获取场景统计
                scene = mfu.GetSceneTotalsInformation(p)
                if scene:
                    info['total'] = scene.Total
                    info['objects'] = scene.NbOfObjects
                    info['shapes'] = scene.NbOfShapes
                    info['lights'] = scene.NbOfLights
                    info['cameras'] = scene.NbOfCameras
                    info['helpers'] = scene.NbOfHelpers
                    info['spacewarps'] = scene.NbOfSpaceWarps
                
                # 获取网格统计
                mesh = mfu.GetMeshTotalsInformation(p)
                if mesh:
                    info['vertices'] = mesh.NbOfVertices
                    info['faces'] = mesh.NbOfFaces
                
                # 尝试获取骨骼数量
                try:
                    allObjects = mfu.GetObjectsNames(p)
                    boneCount = 0
                    for objName in allObjects:
                        if 'Bone' in objName or 'Bip' in objName or 'Armature' in objName:
                            boneCount += 1
                    info['bones'] = boneCount
                except:
                    info['bones'] = 0
        except: pass
        return info
    
    @staticmethod
    def get_fbxreview_path():
        """获取FBX Review可执行文件路径"""
        paths = [
            r"C:\Program Files\Autodesk\FBX\FBX Review\fbxreview.exe",
            r"C:\Program Files (x86)\Autodesk\FBX\FBX Review\fbxreview.exe",
        ]
        if IN_MAX:
            try:
                scripts_dir = rt.getDir(rt.name("scripts"))
                paths.insert(0, os.path.join(scripts_dir, "BulletScripts", "Res", "fbxreview.exe"))
            except: pass
        for p in paths:
            if os.path.isfile(p):
                return p
        return None
    
    @staticmethod
    def preview_fbx(p):
        if not IN_MAX: return
        try:
            py = os.path.join(rt.getDir(rt.name("scripts")), "BulletScripts", "BsAnimLib.py")
            if os.path.exists(py):
                rt.python.ExecuteFile(py)
                rt.python.execute("show_fbx_viewer(r'%s')" % p)
        except: pass


class FileItem(QListWidgetItem):
    def __init__(self, path, is_folder=False, exists=True):
        super().__init__()
        self.path = path
        self.is_folder = is_folder
        name = os.path.basename(path)
        if is_folder:
            self.setText("📁 " + name)
        elif not exists:
            self.setText("❌ " + name)
        else:
            self.setText("📄 " + name)
        self.setToolTip(path)


class TimeMachine(QDialog):
    closed = Signal()
    
    def __init__(self, parent=None):
        # 尝试获取Max主窗口作为父窗口
        if parent is None and IN_MAX:
            try:
                parent = QWidget.find(rt.windows.getMAXHWND())
            except:
                pass
        super().__init__(parent)
        
        self.cfg = Config()
        self.path = ""
        self.ext = ".max"
        self.folders = []
        self.files = []
        self.recent_mode = False
        self.fbx_process = None
        self.current_preview_file = ""
        self.sort_by_name = True  # True=按名称, False=按时间
        self._resizing = False  # 切换预览时的标志
        
        # Calculate DPI scale for HiDPI support
        self.dpi_scale = _get_dpi_scale()
        
        self._ui()
        self._connect()
        self._load()
        self._init_path()
    
    def _fs(self, base_size):
        """Get DPI-scaled font size string for inline styles"""
        return "%dpx" % _scaled_font(base_size, self.dpi_scale)
    
    def _ui(self):
        self.setWindowTitle("时光机 v" + VERSION)
        # 使用 Dialog + WindowMinMaxButtonsHint 使窗口跟随Max，不单独显示在任务栏
        self.setWindowFlags(Qt.Dialog | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint)
        self.setAttribute(Qt.WA_DeleteOnClose)
        self.setStyleSheet(_get_style(self.dpi_scale))
        
        root = QHBoxLayout(self)
        root.setContentsMargins(6, 6, 6, 6)
        root.setSpacing(6)
        
        # === 左侧主面板 ===
        left = QVBoxLayout()
        left.setSpacing(4)
        
        # 路径栏
        path_row = QHBoxLayout()
        path_row.setSpacing(3)
        
        self.btn_refresh = QPushButton("刷新")
        self.btn_refresh.setFixedWidth(40)
        self.btn_refresh.setToolTip("刷新目录\n右键: 重置场景")
        path_row.addWidget(self.btn_refresh)
        
        self.btn_browse = QPushButton("...")
        self.btn_browse.setFixedWidth(28)
        self.btn_browse.setToolTip("选择目录")
        path_row.addWidget(self.btn_browse)
        
        self.edt_path = QLineEdit()
        self.edt_path.setReadOnly(True)
        path_row.addWidget(self.edt_path, 1)
        
        self.btn_add_fav = QPushButton("★")
        self.btn_add_fav.setFixedWidth(28)
        self.btn_add_fav.setToolTip("收藏当前目录")
        path_row.addWidget(self.btn_add_fav)
        
        self.btn_explorer = QPushButton("📂")
        self.btn_explorer.setFixedWidth(28)
        self.btn_explorer.setToolTip("在资源管理器中打开")
        path_row.addWidget(self.btn_explorer)
        
        self.btn_settings = QPushButton("⚙")
        self.btn_settings.setFixedWidth(28)
        self.btn_settings.setToolTip("设置")
        path_row.addWidget(self.btn_settings)
        
        left.addLayout(path_row)
        
        # 内容区
        content = QHBoxLayout()
        content.setSpacing(4)
        
        # 左侧边栏
        sidebar = QVBoxLayout()
        sidebar.setSpacing(4)
        
        # 收藏目录 (右键菜单操作)
        grp_fav = QGroupBox("收藏目录 (右键操作)")
        lay_fav = QVBoxLayout(grp_fav)
        lay_fav.setContentsMargins(3, 3, 3, 3)
        lay_fav.setSpacing(2)
        
        self.lst_fav = QListWidget()
        self.lst_fav.setMaximumWidth(140)
        self.lst_fav.setMinimumHeight(100)
        self.lst_fav.setContextMenuPolicy(Qt.CustomContextMenu)
        self.lst_fav.setToolTip("右键: 添加/删除收藏")
        lay_fav.addWidget(self.lst_fav)
        sidebar.addWidget(grp_fav, 3)
        
        # 过滤词缀
        grp_filter = QGroupBox("过滤词缀")
        lay_filter = QVBoxLayout(grp_filter)
        lay_filter.setContentsMargins(3, 3, 3, 3)
        lay_filter.setSpacing(2)
        
        # 输入框 + 添加按钮
        filter_input = QHBoxLayout()
        filter_input.setSpacing(2)
        self.edt_filter = QLineEdit()
        self.edt_filter.setPlaceholderText("输入后回车添加...")
        filter_input.addWidget(self.edt_filter)
        self.btn_filter_add = QPushButton("＋")
        self.btn_filter_add.setFixedSize(22, 22)
        self.btn_filter_add.setToolTip("添加过滤词")
        filter_input.addWidget(self.btn_filter_add)
        lay_filter.addLayout(filter_input)
        
        self.lst_filter = QListWidget()
        self.lst_filter.setMaximumWidth(140)
        self.lst_filter.setMinimumHeight(80)
        self.lst_filter.setContextMenuPolicy(Qt.CustomContextMenu)
        self.lst_filter.setToolTip("点击应用过滤 | 右键删除")
        lay_filter.addWidget(self.lst_filter)
        
        # 底部操作按钮
        filter_btns = QHBoxLayout()
        filter_btns.setSpacing(2)
        self.btn_filter_clear = QPushButton("显示全部")
        self.btn_filter_clear.setToolTip("取消过滤，显示全部文件")
        filter_btns.addWidget(self.btn_filter_clear)
        lay_filter.addLayout(filter_btns)
        
        sidebar.addWidget(grp_filter, 2)
        
        # 快捷按钮
        grp_quick = QGroupBox("快捷操作")
        lay_quick = QVBoxLayout(grp_quick)
        lay_quick.setContentsMargins(3, 3, 3, 3)
        lay_quick.setSpacing(3)
        
        self.btn_recent = QPushButton("最近打开")
        self.btn_scripts = QPushButton("脚本目录")
        self.btn_autoback = QPushButton("自动备份")
        for b in [self.btn_recent, self.btn_scripts, self.btn_autoback]:
            lay_quick.addWidget(b)
        sidebar.addWidget(grp_quick)
        
        # 静默打开选项（隐藏，通过设置菜单控制）
        self.silent_mode = True
        
        content.addLayout(sidebar)
        
        # 文件列表
        grp_files = QGroupBox("文件列表")
        lay_files = QVBoxLayout(grp_files)
        lay_files.setContentsMargins(3, 3, 3, 3)
        lay_files.setSpacing(3)
        
        # 工具栏
        toolbar = QHBoxLayout()
        toolbar.setSpacing(4)
        
        self.grp_type = QButtonGroup(self)
        self.rb_max = QRadioButton(".max")
        self.rb_fbx = QRadioButton(".fbx")
        self.rb_bip = QRadioButton(".bip")
        self.rb_ms = QRadioButton(".ms")
        self.rb_max.setChecked(True)
        for i, r in enumerate([self.rb_max, self.rb_fbx, self.rb_bip, self.rb_ms]):
            self.grp_type.addButton(r, i)
            toolbar.addWidget(r)
        
        toolbar.addStretch()
        
        # 排序方式
        self.cmb_sort = QPushButton("名称▼")
        self.cmb_sort.setFixedWidth(55)
        self.cmb_sort.setToolTip("切换排序方式：按名称/按时间")
        toolbar.addWidget(self.cmb_sort)
        
        self.chk_rev = QCheckBox("倒序")
        toolbar.addWidget(self.chk_rev)
        
        self.btn_up = QPushButton("上层")
        self.btn_up.setFixedWidth(40)
        toolbar.addWidget(self.btn_up)
        
        self.btn_preview = QPushButton("预览 >>")
        self.btn_preview.setCheckable(True)
        self.btn_preview.setFixedWidth(60)
        toolbar.addWidget(self.btn_preview)
        
        lay_files.addLayout(toolbar)
        
        self.lst_files = QListWidget()
        self.lst_files.setContextMenuPolicy(Qt.CustomContextMenu)
        lay_files.addWidget(self.lst_files)
        
        # 状态栏
        status_row = QHBoxLayout()
        status_row.setSpacing(6)
        
        self.lbl_status = QLabel("文件: 0")
        self.lbl_status.setStyleSheet("color: #888;")
        status_row.addWidget(self.lbl_status)
        
        status_row.addStretch()
        
        # 日期 | 作者链接
        from datetime import datetime
        weekdays = ["一", "二", "三", "四", "五", "六", "日"]
        now = datetime.now()
        date_str = "%d/%d/%d 周%s" % (now.year, now.month, now.day, weekdays[now.weekday()])
        self.lbl_date = QLabel(date_str)
        self.lbl_date.setStyleSheet("color: #666; font-size: %s;" % self._fs(10))
        status_row.addWidget(self.lbl_date)
        
        sep = QLabel("|")
        sep.setStyleSheet("color: #555; font-size: %s;" % self._fs(10))
        status_row.addWidget(sep)
        
        # 作者名作为可点击链接
        self.lbl_author = QLabel('<a href="#" style="color:#7af; text-decoration:none;">Bullet.S</a>')
        self.lbl_author.setStyleSheet("font-size: %s;" % self._fs(10))
        self.lbl_author.setCursor(Qt.PointingHandCursor)
        self.lbl_author.setToolTip("点击访问作者B站主页")
        self.lbl_author.linkActivated.connect(self._show_help)
        status_row.addWidget(self.lbl_author)
        
        lay_files.addLayout(status_row)
        
        content.addWidget(grp_files, 1)
        left.addLayout(content)
        root.addLayout(left, 1)
        
        # === 右侧预览面板 ===
        self.preview_panel = QWidget()
        self.preview_panel.setFixedWidth(365)
        self.preview_panel.setVisible(False)
        
        prev_lay = QVBoxLayout(self.preview_panel)
        prev_lay.setContentsMargins(5, 0, 0, 0)
        prev_lay.setSpacing(4)
        
        # 预览窗口 - 与原版一致
        grp_prev = QGroupBox("预览窗口 (FBX会内嵌预览)")
        lay_prev = QVBoxLayout(grp_prev)
        lay_prev.setContentsMargins(4, 4, 4, 4)
        lay_prev.setSpacing(4)
        
        # 缩略图/FBX预览容器 - 增大预览窗口 (4:3比例)
        self.preview_container = QWidget()
        self.preview_container.setFixedSize(350, 263)
        self.preview_container.setStyleSheet("background: #202020; border: 1px solid #444;")
        preview_lay = QVBoxLayout(self.preview_container)
        preview_lay.setContentsMargins(0, 0, 0, 0)
        preview_lay.setSpacing(0)
        
        self.lbl_thumb = QLabel()
        self.lbl_thumb.setAlignment(Qt.AlignCenter)
        self.lbl_thumb.setText("选择文件预览")
        self.lbl_thumb.setStyleSheet("background: transparent; border: none; color: #888;")
        preview_lay.addWidget(self.lbl_thumb)
        
        # FBX嵌入容器 (初始隐藏)
        self.fbx_embed = FbxEmbedArea(self.preview_container)
        self.fbx_embed.setGeometry(0, 0, 350, 263)
        self.fbx_embed.hide()
        self.fbx_embed.resized.connect(self._resize_fbx_child)
        self.fbx_process = None
        self.fbx_child_hwnd = None
        
        lay_prev.addWidget(self.preview_container)
        prev_lay.addWidget(grp_prev)
        
        # 文件属性 - 紧凑布局
        grp_info = QGroupBox("文件属性")
        lay_info = QVBoxLayout(grp_info)
        lay_info.setContentsMargins(4, 2, 4, 2)
        lay_info.setSpacing(0)
        
        self.lbl_info = QLabel()
        self.lbl_info.setWordWrap(True)
        self.lbl_info.setAlignment(Qt.AlignTop | Qt.AlignLeft)
        self.lbl_info.setStyleSheet("color: #ccc; font-size: %s; line-height: 1.2;" % self._fs(10))
        lay_info.addWidget(self.lbl_info)
        
        prev_lay.addWidget(grp_info)
        
        # 操作按钮行 - 与原版一致
        btn_row = QHBoxLayout()
        btn_row.setSpacing(4)
        self.btn_copy_path = QPushButton("复制路径")
        self.btn_copy_path.setFixedWidth(85)
        self.btn_copy_name = QPushButton("复制文件名")
        self.btn_copy_name.setFixedWidth(85)
        self.btn_fbx_external = QPushButton("外部预览")
        self.btn_fbx_external.setFixedWidth(70)
        self.btn_fbx_external.setToolTip("在独立窗口中打开FBX预览（更大视图）")
        self.btn_fbx_external.setVisible(False)
        self.chk_auto_fbx = QCheckBox("自动预览")
        self.chk_auto_fbx.setChecked(True)
        self.chk_auto_fbx.setToolTip("自动预览FBX文件")
        btn_row.addWidget(self.btn_copy_path)
        btn_row.addWidget(self.btn_copy_name)
        btn_row.addWidget(self.btn_fbx_external)
        btn_row.addWidget(self.chk_auto_fbx)
        btn_row.addStretch()
        prev_lay.addLayout(btn_row)
        
        root.addWidget(self.preview_panel)
        
        self.resize(580, 420)
    
    def _connect(self):
        self.btn_refresh.clicked.connect(self._refresh_path)
        self.btn_refresh.setContextMenuPolicy(Qt.CustomContextMenu)
        self.btn_refresh.customContextMenuRequested.connect(self._reset_scene)
        self.btn_browse.clicked.connect(self._browse_dir)
        self.btn_add_fav.clicked.connect(self._add_current_fav)
        self.btn_explorer.clicked.connect(self._open_explorer)
        
        self.lst_fav.itemClicked.connect(self._on_fav_click)
        self.lst_fav.customContextMenuRequested.connect(self._fav_menu)
        
        self.btn_filter_add.clicked.connect(self._add_filter)
        self.btn_filter_clear.clicked.connect(self._clear_filter)
        self.edt_filter.returnPressed.connect(self._add_filter)
        self.lst_filter.itemClicked.connect(self._on_filter_click)
        self.lst_filter.customContextMenuRequested.connect(self._filter_menu)
        
        self.btn_recent.clicked.connect(self._show_recent)
        self.btn_scripts.clicked.connect(self._go_scripts)
        self.btn_autoback.clicked.connect(self._go_autoback)
        self.btn_settings.clicked.connect(self._show_settings)
        
        self.grp_type.buttonClicked.connect(self._on_type_change)
        self.cmb_sort.clicked.connect(self._toggle_sort_mode)
        self.chk_rev.stateChanged.connect(self._refresh_list)
        self.btn_up.clicked.connect(self._go_up)
        self.btn_preview.toggled.connect(self._toggle_preview)
        
        self.lst_files.itemClicked.connect(self._on_file_click)
        self.lst_files.itemDoubleClicked.connect(self._on_file_dbl)
        self.lst_files.customContextMenuRequested.connect(self._file_menu)
        
        self.btn_copy_path.clicked.connect(self._copy_path)
        self.btn_copy_name.clicked.connect(self._copy_name)
        self.btn_fbx_external.clicked.connect(self._open_fbx_external)
    
    def _load(self):
        pos = self.cfg.get("pos", [100, 100])
        size = self.cfg.get("size", [580, 420])
        self.move(pos[0], pos[1])
        self.resize(size[0], size[1])
        
        for fav in reversed(self.cfg.get("favorites", [])):
            if isinstance(fav, dict) and os.path.isdir(fav.get("dir", "")):
                item = QListWidgetItem(fav.get("name", ""))
                item.setData(Qt.UserRole, fav.get("dir"))
                item.setToolTip(fav.get("dir"))
                self.lst_fav.addItem(item)
        
        for f in reversed(self.cfg.get("filters", [])):
            self.lst_filter.addItem(f)
        
        self.silent_mode = self.cfg.get("silent", True)
        self.chk_rev.setChecked(self.cfg.get("reverse", False))
        self.chk_auto_fbx.setChecked(self.cfg.get("auto_fbx", True))
        
        idx = self.cfg.get("file_type", 0)
        btns = [self.rb_max, self.rb_fbx, self.rb_bip, self.rb_ms]
        if 0 <= idx < len(btns):
            btns[idx].setChecked(True)
            self._update_ext(idx)
        
        sel = self.cfg.get("selected_fav", 0)
        if 0 <= sel < self.lst_fav.count():
            self.lst_fav.setCurrentRow(sel)
    
    def _save(self):
        self.cfg.set("pos", [self.x(), self.y()])
        # 保存不含预览面板的宽度
        w = self.width()
        if self.preview_panel.isVisible():
            w -= 371  # 预览面板宽度
        self.cfg.set("size", [w, self.height()])
        
        favs = []
        for i in range(self.lst_fav.count()):
            item = self.lst_fav.item(i)
            favs.append({"name": item.text(), "dir": item.data(Qt.UserRole)})
        self.cfg.set("favorites", list(reversed(favs)))
        
        filters = [self.lst_filter.item(i).text() for i in range(self.lst_filter.count())]
        self.cfg.set("filters", list(reversed(filters)))
        
        self.cfg.set("silent", self.silent_mode)
        self.cfg.set("reverse", self.chk_rev.isChecked())
        self.cfg.set("auto_fbx", self.chk_auto_fbx.isChecked())
        self.cfg.set("file_type", self.grp_type.checkedId())
        self.cfg.set("selected_fav", self.lst_fav.currentRow())
        self.cfg.set("preview", self.btn_preview.isChecked())
        self.cfg.save()
    
    def _update_ext(self, idx):
        exts = [".max", ".fbx", ".bip", ".ms*"]
        if 0 <= idx < len(exts): self.ext = exts[idx]
    
    def _init_path(self):
        p = MaxOps.get_path()
        if p and os.path.isdir(p):
            self._go_path(p)
        elif self.lst_fav.count() > 0:
            self.lst_fav.setCurrentRow(0)
            self._on_fav_click(self.lst_fav.currentItem())
    
    def _go_path(self, p):
        if not os.path.isdir(p): return
        self.path = p
        self.edt_path.setText(p)
        self.recent_mode = False
        self._refresh_list()
        
        for i in range(self.lst_fav.count()):
            if self.lst_fav.item(i).data(Qt.UserRole) == p:
                self.lst_fav.setCurrentRow(i)
                return
        self.lst_fav.clearSelection()
    
    def _refresh_list(self):
        if self.recent_mode: return
        self.lst_files.clear()
        self.folders = FileOps.get_folders(self.path)
        all_files = FileOps.get_files(self.path, self.ext)
        
        flt = self.edt_filter.text().strip()
        if not flt and self.lst_filter.currentItem():
            flt = self.lst_filter.currentItem().text()
        
        self.files = [f for f in all_files if flt.lower() in os.path.basename(f).lower()] if flt else all_files
        
        # 排序：按名称或按修改时间
        if self.sort_by_name:
            self.folders.sort(key=lambda x: os.path.basename(x).lower())
            self.files.sort(key=lambda x: os.path.basename(x).lower())
        else:
            self.folders.sort(key=lambda x: os.path.getmtime(x) if os.path.exists(x) else 0)
            self.files.sort(key=lambda x: os.path.getmtime(x) if os.path.exists(x) else 0)
        
        items = [FileItem(f, is_folder=True) for f in self.folders] + [FileItem(f) for f in self.files]
        if self.chk_rev.isChecked(): items.reverse()
        for item in items: self.lst_files.addItem(item)
        
        self.lbl_status.setText("文件夹: %d | 文件: %d" % (len(self.folders), len(self.files)))
    
    def _toggle_sort_mode(self):
        self.sort_by_name = not self.sort_by_name
        if self.sort_by_name:
            self.cmb_sort.setText("名称▼")
            self.cmb_sort.setToolTip("当前：按名称排序\n点击切换为按修改时间排序")
        else:
            self.cmb_sort.setText("时间▼")
            self.cmb_sort.setToolTip("当前：按修改时间排序\n点击切换为按名称排序")
        self._refresh_list()
    
    def _show_help(self):
        # 打开作者B站主页
        import webbrowser
        webbrowser.open("https://space.bilibili.com/2031113")
    
    def _refresh_path(self):
        p = MaxOps.get_path()
        if p and os.path.isdir(p): self._go_path(p)
        elif self.path: self._refresh_list()
    
    def _reset_scene(self):
        if QMessageBox.question(self, "确认", "重置当前场景？") == QMessageBox.Yes:
            if IN_MAX:
                try:
                    if rt.checkForSave(): rt.resetMaxFile(rt.name("noPrompt"))
                except: pass
    
    def _browse_dir(self):
        p = QFileDialog.getExistingDirectory(self, "选择目录", self.path)
        if p: self._go_path(p)
    
    def _add_current_fav(self):
        if not self.path: return
        for i in range(self.lst_fav.count()):
            if self.lst_fav.item(i).data(Qt.UserRole) == self.path:
                QMessageBox.information(self, "提示", "该目录已收藏")
                return
        name, ok = QInputDialog.getText(self, "添加收藏", "名称:", text=os.path.basename(self.path))
        if ok and name:
            item = QListWidgetItem(name)
            item.setData(Qt.UserRole, self.path)
            item.setToolTip(self.path)
            self.lst_fav.insertItem(0, item)
            self.lst_fav.setCurrentRow(0)
            self._save()  # 立即保存
    
    def _open_explorer(self):
        if self.path and os.path.isdir(self.path):
            QDesktopServices.openUrl(QUrl.fromLocalFile(self.path))
    
    def _show_settings(self):
        menu = QMenu(self)
        act_silent = menu.addAction("静默打开 (不弹对话框)")
        act_silent.setCheckable(True)
        act_silent.setChecked(self.silent_mode)
        act_silent.triggered.connect(self._toggle_silent)
        menu.exec_(self.btn_settings.mapToGlobal(self.btn_settings.rect().bottomLeft()))
    
    def _toggle_silent(self):
        self.silent_mode = not self.silent_mode
        self._save()
    
    def _add_fav(self):
        p = QFileDialog.getExistingDirectory(self, "选择收藏目录")
        if p:
            for i in range(self.lst_fav.count()):
                if self.lst_fav.item(i).data(Qt.UserRole) == p: return
            name, ok = QInputDialog.getText(self, "添加收藏", "名称:", text=os.path.basename(p))
            if ok and name:
                item = QListWidgetItem(name)
                item.setData(Qt.UserRole, p)
                item.setToolTip(p)
                self.lst_fav.insertItem(0, item)
                self._save()  # 立即保存
    
    def _del_fav(self):
        row = self.lst_fav.currentRow()
        if row >= 0:
            self.lst_fav.takeItem(row)
            self._save()  # 立即保存
    
    def _on_fav_click(self, item):
        if item:
            p = item.data(Qt.UserRole)
            if os.path.isdir(p): self._go_path(p)
    
    def _fav_menu(self, pos):
        menu = QMenu(self)
        menu.addAction("添加当前目录").triggered.connect(self._add_current_fav)
        menu.addAction("浏览添加...").triggered.connect(self._add_fav)
        item = self.lst_fav.itemAt(pos)
        if item:
            menu.addSeparator()
            menu.addAction("删除").triggered.connect(self._del_fav)
            menu.addAction("打开目录").triggered.connect(
                lambda: QDesktopServices.openUrl(QUrl.fromLocalFile(item.data(Qt.UserRole))))
        menu.exec_(self.lst_fav.mapToGlobal(pos))
    
    def _filter_menu(self, pos):
        item = self.lst_filter.itemAt(pos)
        menu = QMenu(self)
        menu.addAction("显示全部").triggered.connect(self._clear_filter)
        if item:
            menu.addSeparator()
            menu.addAction("删除").triggered.connect(self._del_filter)
        menu.exec_(self.lst_filter.mapToGlobal(pos))
    
    def _add_filter(self):
        t = self.edt_filter.text().strip()
        if t:
            for i in range(self.lst_filter.count()):
                if self.lst_filter.item(i).text() == t: return
            self.lst_filter.insertItem(0, t)
            self.lst_filter.setCurrentRow(0)
            self._refresh_list()
            self._save()  # 立即保存
    
    def _del_filter(self):
        row = self.lst_filter.currentRow()
        if row >= 0:
            self.lst_filter.takeItem(row)
            self._refresh_list()
            self._save()  # 立即保存
    
    def _apply_filter(self):
        self.lst_filter.clearSelection()
        self._refresh_list()
    
    def _clear_filter(self):
        self.edt_filter.clear()
        self.lst_filter.setCurrentRow(-1)  # 清除当前选中项
        self._refresh_list()
    
    def _on_filter_click(self, item):
        if item:
            self.edt_filter.setText(item.text())
            self._refresh_list()
    
    def _show_recent(self):
        self.recent_mode = True
        self.lst_files.clear()
        self.edt_path.setText("( 最近打开文件 )")
        for p in FileOps.get_recent():
            self.lst_files.addItem(FileItem(p, exists=os.path.exists(p)))
        self.lbl_status.setText("最近文件: %d" % self.lst_files.count())
    
    def _go_scripts(self):
        p = MaxOps.get_scripts()
        if p and os.path.isdir(p):
            self.rb_ms.setChecked(True)
            self._update_ext(3)
            self._go_path(p)
    
    def _go_autoback(self):
        p = MaxOps.get_autoback()
        if p and os.path.isdir(p):
            self.rb_max.setChecked(True)
            self._update_ext(0)
            self._go_path(p)
    
    def _on_type_change(self, btn):
        self._update_ext(self.grp_type.id(btn))
        self._refresh_list()
    
    def _go_up(self):
        if self.path:
            parent = FileOps.get_parent(self.path)
            if parent and os.path.isdir(parent): self._go_path(parent)
    
    def _toggle_preview(self, on):
        # 预览面板宽度 = 365 (fixedWidth) + 6 (spacing)
        PREVIEW_WIDTH = 371
        
        # 暂停 resizeEvent 保存
        self._resizing = True
        
        if on:
            # 保存当前左侧宽度
            self._left_width = self.width()
            self.preview_panel.setVisible(True)
            self.btn_preview.setText("预览 <<")
            self.resize(self._left_width + PREVIEW_WIDTH, self.height())
            item = self.lst_files.currentItem()
            if isinstance(item, FileItem) and not item.is_folder:
                self._update_preview(item.path)
        else:
            # 关闭预览：恢复到保存的左侧宽度
            target_width = getattr(self, '_left_width', self.width() - PREVIEW_WIDTH)
            self.preview_panel.setVisible(False)
            self.btn_preview.setText("预览 >>")
            # 强制布局重新计算
            self.layout().invalidate()
            self.layout().activate()
            # 设置最小宽度允许缩小
            self.setMinimumWidth(0)
            self.resize(target_width, self.height())
        
        self._resizing = False
    
    def _on_file_click(self, item):
        if isinstance(item, FileItem) and not item.is_folder:
            if self.btn_preview.isChecked():
                self._update_preview(item.path)
    
    def _update_preview(self, p):
        self.current_preview_file = p
        
        # 清理之前的FBX预览
        self._cleanup_fbx_preview()
        self.fbx_embed.hide()
        self.lbl_thumb.show()
        self.btn_fbx_external.setVisible(False)
        
        if not p or not os.path.exists(p):
            self.lbl_thumb.setText("文件不存在")
            self.lbl_info.setText("")
            return
        
        file_info = FileOps.get_info(p)
        ext = os.path.splitext(p)[1].lower()
        
        # 根据文件类型显示不同内容
        if ext == ".max":
            # Max文件 - 显示缩略图和详细信息
            thumb = MaxOps.get_thumb(p)
            if thumb:
                self.lbl_thumb.setPixmap(thumb.scaled(348, 261, Qt.KeepAspectRatio, Qt.SmoothTransformation))
            else:
                self.lbl_thumb.setText("无缩略图")
            
            # 获取详细文件信息
            max_info = MaxOps.get_max_file_info(p)
            txt = ""
            if 'version' in max_info:
                txt += "保存版本: %s\n\n" % max_info['version']
            
            if 'total' in max_info:
                txt += "物体总数: %s\n" % max_info['total']
                txt += "几何体: %s  ||  形状: %s  ||  灯光: %s  ||  相机: %s\n" % (
                    max_info.get('objects', 0), max_info.get('shapes', 0),
                    max_info.get('lights', 0), max_info.get('cameras', 0))
                txt += "辅助对象: %s  ||  空间扭曲: %s\n" % (
                    max_info.get('helpers', 0), max_info.get('spacewarps', 0))
                txt += "骨骼数量: %s\n\n" % max_info.get('bones', 0)
            
            if 'vertices' in max_info:
                txt += "顶点数: %s  ||  面数: %s\n\n" % (max_info['vertices'], max_info['faces'])
            
            txt += "文件大小: %s  ||  修改时间: %s" % (file_info.get('size', '?'), file_info.get('time', '?'))
            self.lbl_info.setText(txt)
            
        elif ext == ".fbx":
            # FBX文件 - 内嵌预览
            txt = "FBX文件属性:\n文件类型: FBX格式\n\n"
            txt += "文件大小: %s  ||  修改时间: %s" % (file_info.get('size', '?'), file_info.get('time', '?'))
            self.lbl_info.setText(txt)
            self.btn_fbx_external.setVisible(True)
            
            if self.chk_auto_fbx.isChecked():
                # 自动内嵌预览
                QTimer.singleShot(200, lambda: self._start_fbx_embed(p))
            else:
                self.lbl_thumb.setText("FBX文件\n\n勾选'自动预览'启用内嵌预览\n或点击'外部预览'打开独立窗口")
                
        elif ext == ".bip":
            self.lbl_thumb.setText("BIP文件\nBiped动画")
            txt = "BIP文件属性:\n文件类型: Biped动画\n\n"
            txt += "文件大小: %s  ||  修改时间: %s" % (file_info.get('size', '?'), file_info.get('time', '?'))
            self.lbl_info.setText(txt)
            
        else:
            self.lbl_thumb.setText(ext.upper() + " 文件")
            txt = "文件属性:\n文件类型: %s\n\n" % ext.upper()
            txt += "文件大小: %s  ||  修改时间: %s" % (file_info.get('size', '?'), file_info.get('time', '?'))
            self.lbl_info.setText(txt)
    
    def _on_file_dbl(self, item):
        if not isinstance(item, FileItem): return
        if item.is_folder:
            self._go_path(item.path)
        else:
            ext = os.path.splitext(item.path)[1].lower()
            if ext == ".max": MaxOps.open_max(item.path, self.silent_mode)
            elif ext == ".fbx": MaxOps.import_fbx(item.path)
            elif ext == ".bip": MaxOps.load_bip(item.path)
            elif ext.startswith(".ms"): MaxOps.run_script(item.path)
            
            if self.recent_mode and os.path.exists(item.path):
                self._go_path(os.path.dirname(item.path))
    
    def _file_menu(self, pos):
        item = self.lst_files.itemAt(pos)
        menu = QMenu(self)
        if item and isinstance(item, FileItem):
            if not item.is_folder:
                menu.addAction("打开").triggered.connect(lambda: self._on_file_dbl(item))
                menu.addAction("复制路径").triggered.connect(lambda: self._clip(item.path))
                menu.addAction("复制文件名").triggered.connect(lambda: self._clip(os.path.basename(item.path)))
                menu.addSeparator()
            menu.addAction("打开所在目录").triggered.connect(
                lambda: QDesktopServices.openUrl(QUrl.fromLocalFile(
                    item.path if item.is_folder else os.path.dirname(item.path))))
            menu.addSeparator()
        menu.addAction("返回上层").triggered.connect(self._go_up)
        menu.addAction("刷新").triggered.connect(self._refresh_list)
        menu.exec_(self.lst_files.mapToGlobal(pos))
    
    def _copy_path(self):
        item = self.lst_files.currentItem()
        if isinstance(item, FileItem): self._clip(item.path)
    
    def _copy_name(self):
        item = self.lst_files.currentItem()
        if isinstance(item, FileItem): self._clip(os.path.basename(item.path))
    
    def _clip(self, t):
        app = QApplication.instance()
        if app: app.clipboard().setText(t)
    
    def _start_fbx_embed(self, file_path):
        """启动FBX Review并内嵌到预览窗口"""
        fbx_exe = MaxOps.get_fbxreview_path()
        if not fbx_exe or not os.path.isfile(fbx_exe):
            self.lbl_thumb.setText("未找到FBX Review\n请安装Autodesk FBX Review")
            return
        
        try:
            # 清理之前的
            self._cleanup_fbx_preview()
            
            # 启动FBX Review进程 (隐藏启动)
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            si.wShowWindow = 0  # SW_HIDE
            self.fbx_process = subprocess.Popen([fbx_exe, file_path], startupinfo=si)
            
            # 等待窗口创建然后嵌入
            self.lbl_thumb.setText("正在加载FBX预览...")
            QTimer.singleShot(500, self._try_embed_fbx)
            
        except Exception as e:
            self.lbl_thumb.setText("FBX预览失败:\n%s" % str(e))
    
    def _try_embed_fbx(self, retry=0):
        """尝试嵌入FBX Review窗口"""
        if not self.fbx_process:
            return
        
        try:
            # 查找FBX Review窗口
            wins = get_root_windows_by_pid(self.fbx_process.pid)
            if wins:
                hwnd = wins[0]
                container_hwnd = get_hwnd_from_widget(self.fbx_embed)
                
                if container_hwnd:
                    # 设置为子窗口并嵌入
                    SetParent(hwnd, container_hwnd)
                    make_child_style(hwnd)
                    self.fbx_child_hwnd = hwnd
                    
                    # 调整大小
                    w, h = self.fbx_embed.width(), self.fbx_embed.height()
                    SetWindowPos(hwnd, None, 0, 0, w, h, SWP_NOZORDER)
                    ShowWindow(hwnd, SW_SHOW)
                    
                    # 显示嵌入容器，隐藏标签
                    self.lbl_thumb.hide()
                    self.fbx_embed.show()
                    return
            
            # 未找到窗口，重试
            if retry < 20:  # 最多重试10秒
                QTimer.singleShot(500, lambda: self._try_embed_fbx(retry + 1))
            else:
                self.lbl_thumb.setText("FBX预览超时\n请检查FBX Review是否正常")
                self._cleanup_fbx_preview()
                
        except Exception as e:
            self.lbl_thumb.setText("嵌入失败:\n%s" % str(e))
    
    def _resize_fbx_child(self):
        """调整嵌入的FBX窗口大小"""
        if self.fbx_child_hwnd:
            w, h = self.fbx_embed.width(), self.fbx_embed.height()
            SetWindowPos(self.fbx_child_hwnd, None, 0, 0, w, h, SWP_NOZORDER)
    
    def _cleanup_fbx_preview(self):
        """清理FBX预览"""
        self.fbx_child_hwnd = None
        if self.fbx_process:
            try:
                self.fbx_process.terminate()
                self.fbx_process.wait(timeout=1)
            except:
                try: self.fbx_process.kill()
                except: pass
            self.fbx_process = None
    
    def _open_fbx_external(self):
        """在外部独立窗口打开FBX预览"""
        if not hasattr(self, 'current_preview_file') or not self.current_preview_file:
            return
        p = self.current_preview_file
        if not os.path.exists(p):
            return
        
        # 清理内嵌预览
        self._cleanup_fbx_preview()
        self.fbx_embed.hide()
        self.lbl_thumb.show()
        self.lbl_thumb.setText("FBX已在外部窗口打开")
        
        # 使用 BsAnimLib 的预览器（独立窗口，更大视图）
        if IN_MAX:
            try:
                py = os.path.join(rt.getDir(rt.name("scripts")), "BulletScripts", "BsAnimLib.py")
                if os.path.exists(py):
                    rt.python.ExecuteFile(py)
                    rt.python.execute("show_fbx_viewer(r'%s')" % p)
                    return
            except: pass
        
        # 备选：直接启动 FBX Review
        fbx_exe = MaxOps.get_fbxreview_path()
        if fbx_exe and os.path.isfile(fbx_exe):
            try:
                subprocess.Popen([fbx_exe, p])
            except: pass
    
    def resizeEvent(self, e):
        super().resizeEvent(e)
        # 切换预览时不保存
        if getattr(self, '_resizing', False):
            return
        # 实时保存窗口大小（保存不含预览面板的宽度）
        if hasattr(self, 'cfg') and hasattr(self, 'preview_panel'):
            w = self.width()
            if self.preview_panel.isVisible():
                w -= 371
            self.cfg.set("size", [w, self.height()])
            self.cfg.save()
    
    def moveEvent(self, e):
        super().moveEvent(e)
        # 实时保存窗口位置
        if hasattr(self, 'cfg'):
            self.cfg.set("pos", [self.x(), self.y()])
            self.cfg.save()
    
    def closeEvent(self, e):
        # 关闭FBX预览进程
        self._cleanup_fbx_preview()
        self._save()
        self.closed.emit()
        super().closeEvent(e)
    
    def keyPressEvent(self, e):
        if e.key() == Qt.Key_Escape: self.close()
        elif e.key() == Qt.Key_Backspace: self._go_up()
        elif e.key() == Qt.Key_F5: self._refresh_list()
        else: super().keyPressEvent(e)


_win = None

def show_window():
    global _win
    if _win:
        try:
            _win.close()
            _win.deleteLater()
        except: pass
    _win = TimeMachine()
    _win.show()
    _win.raise_()
    _win.activateWindow()
    return _win

def close_window():
    global _win
    if _win:
        try:
            _win.close()
            _win.deleteLater()
        except: pass
        _win = None
