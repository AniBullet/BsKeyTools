# -*- coding: utf-8 -*-
"""
BsScriptHub v1.0 - 远程脚本集合平台
Author: Bullet.S
Compatibility: 3ds Max 2020+ (PySide2/PySide6)
"""

import os
import sys
import json
import re
import tempfile
import threading
from datetime import datetime

# PySide 兼容层
try:
    from PySide6.QtWidgets import (
        QApplication, QWidget, QDialog, QVBoxLayout, QHBoxLayout, QGridLayout,
        QLabel, QPushButton, QLineEdit, QListWidget, QListWidgetItem,
        QGroupBox, QScrollArea, QFrame, QSplitter, QTextEdit,
        QTreeWidget, QTreeWidgetItem, QHeaderView, QSizePolicy,
        QMessageBox, QProgressBar, QToolButton, QMenu
    )
    from PySide6.QtCore import Qt, Signal, QSize, QUrl, QTimer, QThread
    from PySide6.QtGui import QPixmap, QIcon, QFont, QDesktopServices, QAction
    PYSIDE_VERSION = 6
except ImportError:
    from PySide2.QtWidgets import (
        QApplication, QWidget, QDialog, QVBoxLayout, QHBoxLayout, QGridLayout,
        QLabel, QPushButton, QLineEdit, QListWidget, QListWidgetItem,
        QGroupBox, QScrollArea, QFrame, QSplitter, QTextEdit,
        QTreeWidget, QTreeWidgetItem, QHeaderView, QSizePolicy,
        QMessageBox, QProgressBar, QToolButton, QMenu, QAction
    )
    from PySide2.QtCore import Qt, Signal, QSize, QUrl, QTimer, QThread
    from PySide2.QtGui import QPixmap, QIcon, QFont, QDesktopServices
    PYSIDE_VERSION = 2

# 尝试导入 3ds Max 模块
try:
    import pymxs
    from pymxs import runtime as rt
    IN_MAX = True
except ImportError:
    IN_MAX = False

# 尝试导入网络请求模块
try:
    from urllib.request import urlopen, Request
    from urllib.error import URLError, HTTPError
    from urllib.parse import quote
except ImportError:
    from urllib2 import urlopen, Request, URLError, HTTPError
    from urllib import quote

VERSION = "1.0"

# GitHub 仓库配置
GITHUB_OWNER = "AnimatorBullet"
GITHUB_REPO = "BsKeyTools"
GITHUB_REPO_BASE = "https://raw.githubusercontent.com/%s/%s" % (GITHUB_OWNER, GITHUB_REPO)
GITHUB_API_BASE = "https://api.github.com/repos/%s/%s/contents" % (GITHUB_OWNER, GITHUB_REPO)
GITHUB_PAGE_BASE = "https://github.com/%s/%s" % (GITHUB_OWNER, GITHUB_REPO)
GITHUB_BRANCHES = ["main", "dev"]  # 可用分支
DEFAULT_BRANCH = "main"
SCRIPTS_PATH = "_BsKeyTools/Scripts/BsScriptHub"
INDEX_FILE = "scripts_index.json"  # 远程索引文件
LOCAL_VERSIONS_FILE = "local_versions.json"  # 本地版本记录文件
CONFIG_FILE = "config.json"  # 窗口配置文件
CACHE_INDEX_FILE = "cached_index.json"  # 本地缓存的索引

# 窗口尺寸配置
LEFT_PANEL_WIDTH = 250  # 左侧面板宽度
RIGHT_PANEL_WIDTH = 300  # 右侧面板宽度
MARGIN = 16  # 主布局边距
SPACING = 8  # 主布局间距
WINDOW_WIDTH_COLLAPSED = LEFT_PANEL_WIDTH + MARGIN  # 折叠宽度
WINDOW_WIDTH_EXPANDED = LEFT_PANEL_WIDTH + RIGHT_PANEL_WIDTH + SPACING + MARGIN  # 展开宽度
WINDOW_HEIGHT = 550

# 单例窗口管理 - 使用 builtins 存储窗口引用，实现跨文件执行的单例
_WIN_KEY = '_BsScriptHub_Window_Instance_'

def _get_win():
    """获取窗口实例"""
    import builtins
    return getattr(builtins, _WIN_KEY, None)

def _set_win(win):
    """设置窗口实例"""
    import builtins
    setattr(builtins, _WIN_KEY, win)


def compare_versions(local_ver, remote_ver):
    """
    比较版本号
    返回: -1 (本地旧), 0 (相同), 1 (本地新)
    """
    def parse_version(v):
        try:
            return [int(x) for x in v.replace('v', '').split('.')]
        except:
            return [0]
    
    local = parse_version(local_ver)
    remote = parse_version(remote_ver)
    
    # 补齐长度
    max_len = max(len(local), len(remote))
    local.extend([0] * (max_len - len(local)))
    remote.extend([0] * (max_len - len(remote)))
    
    for l, r in zip(local, remote):
        if l < r:
            return -1
        elif l > r:
            return 1
    return 0

# 帮助链接
HELP_URL = "https://space.bilibili.com/2031113/lists/560782"

# 样式表
STYLE = """
* { font-family: "Microsoft YaHei", "Segoe UI", sans-serif; font-size: 11px; }
QDialog, QWidget { background: #2b2b2b; color: #e0e0e0; }
QPushButton, QToolButton {
    background: #404040; border: 1px solid #555; border-radius: 3px;
    padding: 3px 8px; color: #fff;
}
QPushButton:hover, QToolButton:hover { background: #505050; border-color: #7ecbff; color: #fff; }
QPushButton:pressed { background: #333; }
QPushButton:disabled { background: #3a3a3a; color: #777; }
QPushButton#runBtn {
    background: #2d7d46; border-color: #3a9956; font-weight: bold; color: #fff;
}
QPushButton#runBtn:hover { background: #3a9956; }
QToolButton#iconBtn {
    background: #4a4a4a; border: 1px solid #666; font-size: 14px; color: #fff; font-weight: bold;
}
QToolButton#iconBtn:hover { background: #5a5a5a; border-color: #7ecbff; }
QToolButton#toggleBtn {
    background: #2d5a7d; border: 1px solid #4a9fd4; font-size: 14px; color: #7ecbff; font-weight: bold;
}
QToolButton#toggleBtn:hover { background: #3d6a8d; border-color: #7ecbff; color: #fff; }
QLabel#urlLabel {
    color: #7ecbff; font-size: 10px; text-decoration: underline;
}
QLabel#urlLabel:hover { color: #a0d8ff; }
QLineEdit {
    background: #1e1e1e; border: 1px solid #404040; border-radius: 3px;
    padding: 4px 8px; color: #fff;
}
QLineEdit:focus { border-color: #7ecbff; }
QScrollArea { border: none; background: transparent; }
QScrollBar:vertical { 
    background: #2a2a2a; 
    width: 8px; 
    border-radius: 4px;
    margin: 0;
}
QScrollBar::handle:vertical { 
    background: #606060; 
    min-height: 20px; 
    border-radius: 4px; 
}
QScrollBar::handle:vertical:hover { background: #707070; }
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; background: none; }
QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical { background: #2a2a2a; }
QTextEdit {
    background: #1e1e1e; border: 1px solid #404040; border-radius: 3px;
    padding: 6px; color: #fff;
}
QTextEdit:read-only { background: #222; color: #ddd; }
QFrame#previewFrame { background: #1a1a1a; border: 1px solid #404040; border-radius: 4px; }
QProgressBar { background: #1e1e1e; border: none; border-radius: 2px; height: 3px; }
QProgressBar::chunk { background: #7ecbff; border-radius: 2px; }
QLabel { color: #e0e0e0; }
QLabel#titleLabel { color: #fff; font-weight: bold; }
QLabel#infoLabel { color: #bbb; }
QLabel#keywordLabel {
    background: #404040; border-radius: 2px; padding: 1px 4px;
    color: #aaa; font-size: 9px;
}
"""


class NetworkWorker(QThread):
    """网络请求工作线程"""
    finished = Signal(object, str)  # data, error
    progress = Signal(int)
    
    def __init__(self, url, parent=None):
        super().__init__(parent)
        self.url = url
    
    def run(self):
        try:
            req = Request(self.url)
            req.add_header('User-Agent', 'BsScriptHub/1.0')
            response = urlopen(req, timeout=15)
            data = response.read()
            self.finished.emit(data, "")
        except HTTPError as e:
            if e.code == 404:
                self.finished.emit(None, "[404] 文件不存在，请确认远程仓库已上传该文件")
            elif e.code == 403:
                self.finished.emit(None, "[403] 访问被拒绝，可能是请求过于频繁")
            elif e.code >= 500:
                self.finished.emit(None, "[%d] 服务器错误，GitHub 暂时不可用" % e.code)
            else:
                self.finished.emit(None, "[%d] HTTP 错误" % e.code)
        except URLError as e:
            self.finished.emit(None, "[网络] 连接失败: %s" % str(e.reason))
        except Exception as e:
            self.finished.emit(None, "[异常] %s" % str(e))


class CollapsibleCategory(QWidget):
    """可折叠的分类组件"""
    toggled = Signal(str, bool)  # (category_key, expanded)
    
    def __init__(self, title, category_key="", parent=None):
        super().__init__(parent)
        self.expanded = True
        self.scripts = []
        self.category_key = category_key or title  # 用于保存状态的 key
        
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(2)
        
        # 标题栏
        self.header = QPushButton("▼ " + title)
        self.header.setStyleSheet("""
            QPushButton {
                background: #353535;
                border: none;
                border-radius: 3px;
                padding: 4px 8px;
                text-align: left;
                font-size: 11px;
                font-weight: bold;
                color: #8ac;
            }
            QPushButton:hover {
                background: #404040;
                color: #7ecbff;
            }
        """)
        self.header.clicked.connect(self._toggle)
        layout.addWidget(self.header)
        
        # 内容区域
        self.content = QWidget()
        self.content_layout = QVBoxLayout(self.content)
        self.content_layout.setContentsMargins(8, 4, 8, 4)  # 增加右边距
        self.content_layout.setSpacing(2)
        layout.addWidget(self.content)
        
        self.title = title
    
    def _toggle(self):
        self.expanded = not self.expanded
        self.content.setVisible(self.expanded)
        arrow = "▼" if self.expanded else "▶"
        self.header.setText(arrow + " " + self.title)
        self.toggled.emit(self.category_key, self.expanded)
    
    def set_expanded(self, expanded):
        """设置展开状态（不触发信号）"""
        if self.expanded != expanded:
            self.expanded = expanded
            self.content.setVisible(expanded)
            arrow = "▼" if expanded else "▶"
            self.header.setText(arrow + " " + self.title)
    
    def add_script_item(self, script_btn):
        self.content_layout.addWidget(script_btn)
        self.scripts.append(script_btn)
    
    def collapse(self):
        if self.expanded:
            self._toggle()
    
    def expand(self):
        if not self.expanded:
            self._toggle()


class ScriptButton(QPushButton):
    """脚本按钮"""
    script_selected = Signal(dict)
    script_run = Signal(dict)  # 双击运行信号
    script_context_menu = Signal(dict, object)  # 右键菜单信号 (script_data, pos)
    
    # 版本状态常量
    STATUS_NOT_INSTALLED = 0  # 未安装
    STATUS_UP_TO_DATE = 1     # 已是最新
    STATUS_UPDATE_AVAILABLE = 2  # 有更新
    
    def __init__(self, script_data, local_versions=None, parent=None):
        super().__init__(parent)
        self.script_data = script_data
        self.local_versions = local_versions or {}
        self.version_status = self._check_version_status()
        
        self._update_display()
        self.setToolTip(script_data.get("description", ""))
        self.clicked.connect(lambda: self.script_selected.emit(self.script_data))
        self.setContextMenuPolicy(Qt.CustomContextMenu)
        self.customContextMenuRequested.connect(self._show_context_menu)
    
    def mouseDoubleClickEvent(self, event):
        """双击运行脚本"""
        self.script_run.emit(self.script_data)
    
    def _show_context_menu(self, pos):
        """显示右键菜单"""
        self.script_context_menu.emit(self.script_data, self.mapToGlobal(pos))
    
    def _check_version_status(self):
        """检查版本状态"""
        name = self.script_data.get("name", "")
        remote_ver = self.script_data.get("version", "1.0.0")
        local_ver = self.local_versions.get(name, {}).get("version", "")
        
        if not local_ver:
            return self.STATUS_NOT_INSTALLED
        
        cmp = compare_versions(local_ver, remote_ver)
        if cmp < 0:
            return self.STATUS_UPDATE_AVAILABLE
        return self.STATUS_UP_TO_DATE
    
    def _update_display(self):
        """更新显示"""
        name = self.script_data.get("name", "未知脚本")
        
        # 根据状态添加标记 (已下载为普通样式，未下载/有更新为特殊样式)
        if self.version_status == self.STATUS_UPDATE_AVAILABLE:
            display_name = "🔺 " + name  # 有更新 - 特殊样式
            border_color = "#ff9800"  # 橙色边框
            bg_color = "#3d3520"
        elif self.version_status == self.STATUS_NOT_INSTALLED:
            display_name = "○ " + name  # 未安装 - 特殊样式
            border_color = "#666666"  # 灰色边框
            bg_color = "#2a2a2a"
        else:
            display_name = name  # 已是最新 - 普通样式(无标记)
            border_color = "#404040"
            bg_color = "#333333"
        
        self.setText(display_name)
        self.setStyleSheet("""
            QPushButton {
                background: %s;
                border: 1px solid %s;
                border-radius: 4px;
                padding: 8px 12px;
                text-align: left;
                color: #e0e0e0;
            }
            QPushButton:hover {
                background: #3a3a3a;
                border-color: #7ecbff;
            }
            QPushButton:pressed {
                background: #2a2a2a;
            }
        """ % (bg_color, border_color))
    
    def update_local_versions(self, local_versions):
        """更新本地版本信息并刷新显示"""
        self.local_versions = local_versions
        self.version_status = self._check_version_status()
        self._update_display()
    
    def matches_filter(self, text):
        """检查是否匹配搜索文本"""
        if not text:
            return True
        text = text.lower()
        name = self.script_data.get("name", "").lower()
        desc = self.script_data.get("description", "").lower()
        keywords = " ".join(self.script_data.get("keywords", [])).lower()
        author = self.script_data.get("author", "").lower()
        return text in name or text in desc or text in keywords or text in author


class BsScriptHub(QDialog):
    """BsScriptHub 主窗口"""
    closed = Signal()
    
    def __init__(self, parent=None):
        # 尝试获取Max主窗口作为父窗口
        if parent is None and IN_MAX:
            try:
                parent = QWidget.find(rt.windows.getMAXHWND())
            except:
                pass
        super().__init__(parent)
        
        self.scripts_data = []
        self.categories_data = {}  # 分类和脚本名列表
        self.categories = {}  # UI 分类组件
        self.script_info_cache = {}  # 脚本详情缓存
        self.current_script = None
        self._expected_script = None  # 当前期望加载的脚本（防止异步回调覆盖）
        self.workers = []
        self.local_cache_dir = self._get_cache_dir()
        self.local_versions = {}  # 本地版本记录
        self.config = {}  # 窗口配置
        
        self._load_config()  # 加载窗口配置
        self.current_branch = self.config.get("current_branch", DEFAULT_BRANCH)  # 从配置加载分支
        self.detail_visible = self.config.get("detail_visible", False)  # 默认收起
        self.category_states = self.config.get("category_states", {})  # 分类展开状态
        self.last_selected_script = self.config.get("last_selected_script", None)  # 上次选中的脚本
        self.saved_window_pos = self.config.get("window_pos", None)  # 窗口位置
        
        # 设置窗口标志：Dialog 类型跟随Max
        self.setWindowFlags(Qt.Dialog | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint)
        
        self._update_window_title()
        self._load_local_versions()  # 加载本地版本信息
        self._init_ui()
        self.setStyleSheet(STYLE)
        
        # 根据保存的状态设置窗口大小和面板显示
        self._apply_saved_state()
        
        # 延迟加载脚本列表
        QTimer.singleShot(100, self._load_scripts_index)
    
    def _update_window_title(self):
        """更新窗口标题"""
        branch_tag = " [DEV]" if self.current_branch == "dev" else ""
        self.setWindowTitle("BsScriptHub_v%s%s" % (VERSION, branch_tag))
    
    def _get_github_url(self, path=""):
        """获取当前分支的 GitHub Raw URL (用于下载)"""
        base_url = "%s/%s" % (GITHUB_REPO_BASE, self.current_branch)
        if path:
            # 对中文路径进行 URL 编码
            encoded_path = "/".join(quote(p, safe='') for p in path.split("/"))
            return "%s/%s" % (base_url, encoded_path)
        return base_url
    
    def _get_github_page_url(self, path=""):
        """获取当前分支的 GitHub 页面 URL (用于浏览)"""
        base_url = "%s/tree/%s" % (GITHUB_PAGE_BASE, self.current_branch)
        if path:
            return "%s/%s" % (base_url, path)
        return base_url
    
    def _load_config(self):
        """加载窗口配置"""
        config_file = os.path.join(self.local_cache_dir, CONFIG_FILE)
        if os.path.exists(config_file):
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    self.config = json.load(f)
            except:
                self.config = {}
    
    def _save_config(self):
        """保存窗口配置"""
        config_file = os.path.join(self.local_cache_dir, CONFIG_FILE)
        try:
            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, ensure_ascii=False, indent=2)
        except:
            pass
    
    def _apply_saved_state(self):
        """应用保存的窗口状态"""
        # 设置分支按钮状态
        self._update_branch_btn()
        
        # 设置详情面板显示状态
        self.right_panel.setVisible(self.detail_visible)
        
        if self.detail_visible:
            self.toggle_detail_btn.setText("◀")
            width = WINDOW_WIDTH_EXPANDED
        else:
            self.toggle_detail_btn.setText("▶")
            width = WINDOW_WIDTH_COLLAPSED
        
        self.setFixedWidth(width)
        self.resize(width, WINDOW_HEIGHT)
        
        # 恢复窗口位置
        self._restore_window_position()
    
    def _restore_window_position(self):
        """恢复窗口位置（适配多显示器）"""
        if not self.saved_window_pos:
            return
        
        x = self.saved_window_pos.get("x", 0)
        y = self.saved_window_pos.get("y", 0)
        
        # 检查位置是否在可见屏幕范围内
        if self._is_position_visible(x, y):
            self.move(x, y)
    
    def _is_position_visible(self, x, y):
        """检查位置是否在任意显示器的可见范围内"""
        # 获取所有屏幕
        app = QApplication.instance()
        if not app:
            return True  # 无法检查，默认可见
        
        screens = app.screens()
        if not screens:
            return True
        
        # 检查位置是否在任一屏幕内
        for screen in screens:
            geo = screen.availableGeometry()
            # 只要窗口左上角在某个屏幕范围内即可
            if (geo.x() <= x < geo.x() + geo.width() and
                geo.y() <= y < geo.y() + geo.height()):
                return True
        
        return False
    
    def _save_window_position(self):
        """保存窗口位置"""
        pos = self.pos()
        self.saved_window_pos = {"x": pos.x(), "y": pos.y()}
        self.config["window_pos"] = self.saved_window_pos
        self._save_config()
    
    def _load_local_versions(self):
        """加载本地版本记录"""
        versions_file = os.path.join(self.local_cache_dir, LOCAL_VERSIONS_FILE)
        if os.path.exists(versions_file):
            try:
                with open(versions_file, 'r', encoding='utf-8') as f:
                    self.local_versions = json.load(f)
            except:
                self.local_versions = {}
        else:
            # 文件不存在时清空版本记录
            self.local_versions = {}
    
    def _save_local_versions(self):
        """保存本地版本记录"""
        versions_file = os.path.join(self.local_cache_dir, LOCAL_VERSIONS_FILE)
        try:
            with open(versions_file, 'w', encoding='utf-8') as f:
                json.dump(self.local_versions, f, ensure_ascii=False, indent=2)
        except:
            pass
    
    def _update_script_version(self, script_name, version):
        """更新脚本的本地版本记录"""
        self.local_versions[script_name] = {
            "version": version,
            "installed_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        self._save_local_versions()
        
        # 刷新所有脚本按钮的显示
        for cat_widget in self.categories.values():
            for btn in cat_widget.scripts:
                btn.update_local_versions(self.local_versions)
    
    def _get_cache_dir(self):
        """获取本地缓存目录（使用有写入权限的目录）"""
        if IN_MAX:
            # 使用 maxData 目录（用户数据目录，有写入权限）
            cache = os.path.join(str(rt.getDir(rt.name("maxData"))), "BsScriptHub_Cache")
        else:
            cache = os.path.join(tempfile.gettempdir(), "BsScriptHub_Cache")
        if not os.path.exists(cache):
            os.makedirs(cache)
        return cache
    
    def _init_ui(self):
        main_layout = QHBoxLayout(self)
        main_layout.setContentsMargins(8, 8, 8, 8)
        main_layout.setSpacing(8)
        
        # ========== 左侧面板：搜索和分类 ==========
        self.left_panel = QWidget()
        left_layout = QVBoxLayout(self.left_panel)
        left_layout.setContentsMargins(0, 0, 0, 0)
        left_layout.setSpacing(4)
        
        # 标题行
        title_row = QHBoxLayout()
        title_row.setSpacing(4)
        
        # 分支切换按钮
        self.branch_btn = QPushButton("main")
        self.branch_btn.setToolTip("点击切换分支\nmain: 稳定版\ndev: 开发版")
        self.branch_btn.setFixedSize(42, 20)
        self.branch_btn.setStyleSheet("""
            QPushButton { background: #2d5a2d; border: 1px solid #4caf50; border-radius: 3px;
                font-size: 10px; font-weight: bold; color: #8bc34a; }
            QPushButton:hover { background: #3d6a3d; }
        """)
        self.branch_btn.clicked.connect(self._toggle_branch)
        title_row.addWidget(self.branch_btn)
        
        title_row.addStretch()
        
        # 帮助按钮
        self.help_btn = QToolButton()
        self.help_btn.setText("?")
        self.help_btn.setObjectName("iconBtn")
        self.help_btn.setToolTip("帮助 - 打开视频教程")
        self.help_btn.setFixedSize(28, 24)
        self.help_btn.clicked.connect(self._open_help)
        title_row.addWidget(self.help_btn)
        
        self.refresh_btn = QToolButton()
        self.refresh_btn.setText("↻")  # 刷新符号
        self.refresh_btn.setObjectName("iconBtn")
        self.refresh_btn.setToolTip("刷新脚本列表\n右键: 清空缓存")
        self.refresh_btn.setFixedSize(28, 24)
        self.refresh_btn.clicked.connect(self._refresh_all)
        self.refresh_btn.setContextMenuPolicy(Qt.CustomContextMenu)
        self.refresh_btn.customContextMenuRequested.connect(self._show_refresh_menu)
        title_row.addWidget(self.refresh_btn)
        
        # 批量更新按钮
        self.update_all_btn = QToolButton()
        self.update_all_btn.setText("↓")  # 下载符号
        self.update_all_btn.setObjectName("iconBtn")
        self.update_all_btn.setToolTip("批量下载/更新所有脚本")
        self.update_all_btn.setFixedSize(28, 24)
        self.update_all_btn.clicked.connect(self._update_all_scripts)
        title_row.addWidget(self.update_all_btn)
        
        # 详情面板切换按钮
        self.toggle_detail_btn = QToolButton()
        self.toggle_detail_btn.setText("◀")
        self.toggle_detail_btn.setObjectName("toggleBtn")
        self.toggle_detail_btn.setToolTip("显示/隐藏详情面板")
        self.toggle_detail_btn.setFixedSize(28, 24)
        self.toggle_detail_btn.clicked.connect(self._toggle_detail_panel)
        title_row.addWidget(self.toggle_detail_btn)
        
        left_layout.addLayout(title_row)
        
        # 搜索框
        self.search_box = QLineEdit()
        self.search_box.setPlaceholderText("🔍 搜索...")
        self.search_box.setFixedHeight(24)
        self.search_box.textChanged.connect(self._filter_scripts)
        left_layout.addWidget(self.search_box)
        
        # 进度条
        self.progress_bar = QProgressBar()
        self.progress_bar.setVisible(False)
        self.progress_bar.setTextVisible(False)
        self.progress_bar.setMaximumHeight(3)
        left_layout.addWidget(self.progress_bar)
        
        # 分类滚动区域
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        
        self.categories_widget = QWidget()
        self.categories_layout = QVBoxLayout(self.categories_widget)
        self.categories_layout.setContentsMargins(0, 0, 8, 0)  # 增加右边距给滚动条留空间
        self.categories_layout.setSpacing(4)
        self.categories_layout.addStretch()
        
        scroll.setWidget(self.categories_widget)
        left_layout.addWidget(scroll, 1)
        
        # 底部工具栏
        bottom_bar = QHBoxLayout()
        bottom_bar.setSpacing(4)
        
        self.run_btn = QPushButton("▶ 运行")
        self.run_btn.setObjectName("runBtn")
        self.run_btn.setEnabled(False)
        self.run_btn.setFixedHeight(26)
        self.run_btn.clicked.connect(self._run_script)
        bottom_bar.addWidget(self.run_btn, 1)
        
        self.github_btn = QPushButton("🔗")
        self.github_btn.setToolTip("查看源码")
        self.github_btn.setFixedSize(30, 26)
        self.github_btn.clicked.connect(self._open_github)
        bottom_bar.addWidget(self.github_btn)
        
        left_layout.addLayout(bottom_bar)
        
        # 状态标签
        self.status_label = QLabel("准备中...")
        self.status_label.setStyleSheet("color: #666; font-size: 10px; padding: 2px;")
        left_layout.addWidget(self.status_label)
        
        self.left_panel.setFixedWidth(LEFT_PANEL_WIDTH)
        main_layout.addWidget(self.left_panel)
        
        # ========== 右侧面板：详情 ==========
        self.right_panel = QWidget()
        right_layout = QVBoxLayout(self.right_panel)
        right_layout.setContentsMargins(0, 0, 0, 0)
        right_layout.setSpacing(6)
        
        # 预览图区域
        preview_frame = QFrame()
        preview_frame.setObjectName("previewFrame")
        preview_frame.setFixedHeight(160)
        preview_layout = QVBoxLayout(preview_frame)
        preview_layout.setContentsMargins(8, 8, 8, 8)
        
        self.preview_label = QLabel("选择脚本查看预览")
        self.preview_label.setAlignment(Qt.AlignCenter)
        self.preview_label.setStyleSheet("color: #555; font-size: 12px;")
        preview_layout.addWidget(self.preview_label)
        right_layout.addWidget(preview_frame)
        
        # 脚本信息区域 (精简版)
        info_widget = QWidget()
        info_layout = QGridLayout(info_widget)
        info_layout.setContentsMargins(4, 4, 4, 4)
        info_layout.setSpacing(4)
        info_layout.setColumnStretch(1, 1)
        info_layout.setColumnStretch(3, 1)
        
        # 名称 + 版本状态
        self.name_label = QLabel("-")
        self.name_label.setStyleSheet("font-size: 13px; font-weight: bold; color: #7ecbff;")
        info_layout.addWidget(self.name_label, 0, 0, 1, 4)
        
        # 版本状态
        self.version_status_label = QLabel("")
        self.version_status_label.setStyleSheet("font-size: 10px;")
        info_layout.addWidget(self.version_status_label, 1, 0, 1, 4)
        
        # 远程/本地版本
        lbl_style = "color: #888; font-size: 10px;"
        info_layout.addWidget(QLabel("远程:"), 2, 0)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.version_label = QLabel("-")
        self.version_label.setStyleSheet("color: #8bc34a; font-size: 10px;")
        info_layout.addWidget(self.version_label, 2, 1)
        
        info_layout.addWidget(QLabel("本地:"), 2, 2)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.local_version_label = QLabel("-")
        self.local_version_label.setStyleSheet("font-size: 10px;")
        info_layout.addWidget(self.local_version_label, 2, 3)
        
        # 原作者/修改人
        info_layout.addWidget(QLabel("原作者:"), 3, 0)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.author_label = QLabel("-")
        self.author_label.setStyleSheet("color: #ffb74d; font-size: 10px;")
        info_layout.addWidget(self.author_label, 3, 1)
        
        info_layout.addWidget(QLabel("修改人:"), 3, 2)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.optimizer_label = QLabel("-")
        self.optimizer_label.setStyleSheet("font-size: 10px;")
        info_layout.addWidget(self.optimizer_label, 3, 3)
        
        # 更新日期
        info_layout.addWidget(QLabel("更新:"), 4, 0)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.date_label = QLabel("-")
        self.date_label.setStyleSheet("font-size: 10px;")
        info_layout.addWidget(self.date_label, 4, 1, 1, 3)
        
        # 标签
        info_layout.addWidget(QLabel("标签:"), 5, 0)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.keywords_layout = QHBoxLayout()
        self.keywords_layout.setSpacing(3)
        self.keywords_layout.addStretch()
        info_layout.addLayout(self.keywords_layout, 5, 1, 1, 3)
        
        # 发布地址
        info_layout.addWidget(QLabel("地址:"), 6, 0)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.url_label = QPushButton("点击查看")
        self.url_label.setFlat(True)
        self.url_label.setStyleSheet("""
            QPushButton { color: #7ecbff; font-size: 10px; text-decoration: underline; 
                text-align: left; padding: 0; border: none; background: transparent; }
            QPushButton:hover { color: #a0d8ff; }
        """)
        self.url_label.setCursor(Qt.PointingHandCursor)
        self.url_label.clicked.connect(self._on_url_clicked)
        info_layout.addWidget(self.url_label, 6, 1, 1, 3)
        
        # 帮助教程
        info_layout.addWidget(QLabel("教程:"), 7, 0)
        info_layout.itemAt(info_layout.count()-1).widget().setStyleSheet(lbl_style)
        self.tutorial_label = QPushButton("无")
        self.tutorial_label.setFlat(True)
        self.tutorial_label.setStyleSheet("""
            QPushButton { color: #666; font-size: 10px; text-align: left; 
                padding: 0; border: none; background: transparent; }
        """)
        self.tutorial_label.setCursor(Qt.PointingHandCursor)
        self.tutorial_label.clicked.connect(self._on_tutorial_clicked)
        info_layout.addWidget(self.tutorial_label, 7, 1, 1, 3)
        
        right_layout.addWidget(info_widget)
        
        # 描述区域
        self.desc_text = QTextEdit()
        self.desc_text.setReadOnly(True)
        self.desc_text.setPlaceholderText("选择脚本查看描述...")
        self.desc_text.setStyleSheet("font-size: 11px;")
        right_layout.addWidget(self.desc_text, 1)
        
        # 操作按钮
        btn_layout = QHBoxLayout()
        btn_layout.setSpacing(4)
        
        self.download_btn = QPushButton("📥 下载")
        self.download_btn.setEnabled(False)
        self.download_btn.setFixedHeight(26)
        self.download_btn.clicked.connect(self._download_script)
        btn_layout.addWidget(self.download_btn)
        
        right_layout.addLayout(btn_layout)
        
        self.right_panel.setFixedWidth(RIGHT_PANEL_WIDTH)
        main_layout.addWidget(self.right_panel)
    
    def _toggle_detail_panel(self):
        """切换详情面板显示/隐藏"""
        self.detail_visible = not self.detail_visible
        
        if self.detail_visible:
            self.right_panel.setVisible(True)
            self.toggle_detail_btn.setText("◀")
            self.setFixedWidth(WINDOW_WIDTH_EXPANDED)
            self.resize(WINDOW_WIDTH_EXPANDED, self.height())
        else:
            self.right_panel.setVisible(False)
            self.toggle_detail_btn.setText("▶")
            self.setFixedWidth(WINDOW_WIDTH_COLLAPSED)
            self.resize(WINDOW_WIDTH_COLLAPSED, self.height())
        
        # 保存状态
        self.config["detail_visible"] = self.detail_visible
        self._save_config()
    
    def _on_url_clicked(self):
        """点击发布地址时打开链接"""
        if self.current_script:
            url = self.current_script.get("url", "")
            if url:
                QDesktopServices.openUrl(QUrl(url))
    
    def _on_tutorial_clicked(self):
        """点击教程地址时打开链接"""
        if self.current_script:
            tutorial = self.current_script.get("tutorial", "")
            if tutorial:
                QDesktopServices.openUrl(QUrl(tutorial))
    
    def _open_help(self):
        """打开帮助页面"""
        QDesktopServices.openUrl(QUrl(HELP_URL))
    
    def _toggle_branch(self):
        """切换分支"""
        # 切换到下一个分支
        current_idx = GITHUB_BRANCHES.index(self.current_branch)
        next_idx = (current_idx + 1) % len(GITHUB_BRANCHES)
        self.current_branch = GITHUB_BRANCHES[next_idx]
        
        # 保存分支设置
        self.config["current_branch"] = self.current_branch
        self._save_config()
        
        # 更新按钮显示
        self._update_branch_btn()
        self._update_window_title()
        
        # 重新加载脚本列表
        self._load_scripts_index()
    
    def _update_branch_btn(self):
        """更新分支按钮样式"""
        if self.current_branch == "dev":
            self.branch_btn.setText("dev")
            self.branch_btn.setStyleSheet("""
                QPushButton {
                    background: #5a3d2d;
                    border: 1px solid #ff9800;
                    border-radius: 3px;
                    padding: 2px 6px;
                    font-size: 10px;
                    font-weight: bold;
                    color: #ffb74d;
                }
                QPushButton:hover {
                    background: #6a4d3d;
                    border-color: #ffb74d;
                }
            """)
        else:
            self.branch_btn.setText("main")
            self.branch_btn.setStyleSheet("""
                QPushButton {
                    background: #2d5a2d;
                    border: 1px solid #4caf50;
                    border-radius: 3px;
                    padding: 2px 6px;
                    font-size: 10px;
                    font-weight: bold;
                    color: #8bc34a;
                }
                QPushButton:hover {
                    background: #3d6a3d;
                    border-color: #8bc34a;
                }
            """)
    
    def _get_github_api_url(self, path=""):
        """获取 GitHub API URL"""
        base = "%s/%s" % (GITHUB_API_BASE, SCRIPTS_PATH)
        if path:
            # 对中文路径进行 URL 编码
            encoded_path = "/".join(quote(p, safe='') for p in path.split("/"))
            base = "%s/%s" % (base, encoded_path)
        return "%s?ref=%s" % (base, self.current_branch)
    
    def _load_scripts_index(self):
        """下载远程脚本索引文件"""
        branch_text = " [%s]" % self.current_branch if self.current_branch != "main" else ""
        self.status_label.setText("正在加载脚本索引%s..." % branch_text)
        self.progress_bar.setVisible(True)
        self.progress_bar.setRange(0, 0)  # 无限进度
        
        # 直接下载 scripts_index.json
        url = self._get_github_url("%s/%s" % (SCRIPTS_PATH, INDEX_FILE))
        worker = NetworkWorker(url)
        worker.finished.connect(self._on_index_loaded)
        self.workers.append(worker)
        worker.start()
    
    def _on_index_loaded(self, data, error):
        """索引加载完成"""
        self.progress_bar.setVisible(False)
        
        if error:
            self.status_label.setText("加载失败: " + error)
            self._load_local_cache()
            return
        
        try:
            index_data = json.loads(data.decode('utf-8'))
            self.categories_data = index_data.get("categories", {})
            
            # 保存到本地缓存
            cache_file = os.path.join(self.local_cache_dir, CACHE_INDEX_FILE)
            try:
                with open(cache_file, 'w', encoding='utf-8') as f:
                    json.dump(index_data, f, ensure_ascii=False, indent=2)
            except:
                pass
            
            self._build_categories()
            self._refresh_script_buttons()  # 确保按钮状态正确
            total_scripts = sum(len(scripts) for scripts in self.categories_data.values())
            self.status_label.setText("已加载 %d 个脚本，%d 个分类" % (total_scripts, len(self.categories_data)))
            
        except Exception as e:
            self.status_label.setText("解析索引失败: " + str(e))
            self._load_local_cache()
    
    def _load_local_cache(self):
        """加载本地缓存"""
        cache_file = os.path.join(self.local_cache_dir, CACHE_INDEX_FILE)
        if os.path.exists(cache_file):
            try:
                with open(cache_file, 'r', encoding='utf-8') as f:
                    index_data = json.load(f)
                self.categories_data = index_data.get("categories", {})
                self._build_categories()
                self._refresh_script_buttons()  # 确保按钮状态正确
                total_scripts = sum(len(scripts) if isinstance(scripts, list) else 0 
                                   for scripts in self.categories_data.values())
                self.status_label.setText("已从缓存加载 %d 个脚本 (离线模式)" % total_scripts)
            except Exception as e:
                self.status_label.setText("缓存加载失败: " + str(e))
        else:
            self.status_label.setText("无可用数据，请检查网络连接")
    
    def _get_script_info_url(self, category, script_name):
        """获取脚本配置 JSON 的远程 URL"""
        return self._get_github_url("%s/%s/%s.json" % (SCRIPTS_PATH, category, script_name))
    
    def _get_script_info_cache_path(self, category, script_name):
        """获取脚本配置 JSON 的本地缓存路径"""
        return os.path.join(self.local_cache_dir, category, "%s.json" % script_name)
    
    def _load_script_info(self, category, script_name, callback):
        """加载单个脚本的详细信息（优先缓存，否则远程获取）"""
        cache_key = "%s/%s" % (category, script_name)
        
        # 检查内存缓存
        if cache_key in self.script_info_cache:
            callback(self.script_info_cache[cache_key], None)
            return
        
        # 检查本地文件缓存
        cache_path = self._get_script_info_cache_path(category, script_name)
        if os.path.exists(cache_path):
            try:
                with open(cache_path, 'r', encoding='utf-8') as f:
                    info = json.load(f)
                info["category"] = category  # 添加分类信息
                self.script_info_cache[cache_key] = info
                callback(info, None)
                return
            except:
                pass
        
        # 从远程获取
        self.status_label.setText("正在加载脚本信息...")
        url = self._get_script_info_url(category, script_name)
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_script_info_loaded(d, e, category, script_name, callback))
        self.workers.append(worker)
        worker.start()
    
    def _on_script_info_loaded(self, data, error, category, script_name, callback):
        """脚本信息加载完成"""
        # 先检查是否是当前期望的脚本（防止过时请求）
        if hasattr(self, '_expected_script') and script_name != self._expected_script:
            return  # 忽略过时的请求
        
        if error or not data:
            callback(None, error or "加载失败")
            return
        
        try:
            info = json.loads(data.decode('utf-8'))
            info["category"] = category  # 添加分类信息
            
            # 保存到本地缓存
            cache_path = self._get_script_info_cache_path(category, script_name)
            os.makedirs(os.path.dirname(cache_path), exist_ok=True)
            with open(cache_path, 'w', encoding='utf-8') as f:
                json.dump(info, f, ensure_ascii=False, indent=2)
            
            # 保存到内存缓存
            cache_key = "%s/%s" % (category, script_name)
            self.script_info_cache[cache_key] = info
            
            callback(info, None)
        except Exception as e:
            callback(None, str(e))
    
    def _get_display_category_name(self, cat_name):
        """获取分类显示名称（去掉数字前缀）"""
        # 支持格式: "01_基础工具" -> "基础工具"
        match = re.match(r'^\d+[_\-\s]*(.+)$', cat_name)
        return match.group(1) if match else cat_name
    
    def _build_categories(self):
        """构建分类列表"""
        # 清除现有分类
        for cat in list(self.categories.values()):
            cat.deleteLater()
        self.categories.clear()
        
        # 移除布局中的 stretch
        while self.categories_layout.count() > 0:
            item = self.categories_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()
        
        # 清空并重建 scripts_data
        self.scripts_data = []
        
        # 按分类构建 UI
        for cat_name, scripts in self.categories_data.items():
            display_name = self._get_display_category_name(cat_name)
            cat_widget = CollapsibleCategory(display_name, category_key=cat_name)
            cat_widget.toggled.connect(self._on_category_toggled)
            
            # 恢复保存的展开状态
            if cat_name in self.category_states:
                cat_widget.set_expanded(self.category_states[cat_name])
            
            self.categories[cat_name] = cat_widget  # key 保持原名用于路径匹配
            
            # scripts 是脚本信息对象列表 (可能为空)
            if isinstance(scripts, list):
                for script_info in scripts:
                    # script_info 是完整的脚本数据对象
                    if isinstance(script_info, dict):
                        script_data = script_info.copy()
                        script_data["category"] = cat_name  # 确保有分类信息
                    else:
                        # 兼容旧格式（字符串）
                        script_data = {"name": script_info, "category": cat_name}
                    
                    # 添加到 scripts_data 供批量更新使用
                    self.scripts_data.append(script_data)
                    
                    btn = ScriptButton(script_data, self.local_versions)
                    btn.script_selected.connect(self._on_script_selected)
                    btn.script_run.connect(self._on_script_run)
                    btn.script_context_menu.connect(self._show_script_context_menu)
                    cat_widget.add_script_item(btn)
            
            self.categories_layout.addWidget(cat_widget)
        
        self.categories_layout.addStretch()
        
        # 恢复上次选中的脚本
        self._restore_last_selection()
    
    def _restore_last_selection(self):
        """恢复上次选中的脚本"""
        if not self.last_selected_script:
            return
        
        target_name = self.last_selected_script.get("name", "")
        target_category = self.last_selected_script.get("category", "")
        
        if not target_name:
            return
        
        # 在分类中查找并选中脚本
        for cat_name, cat_widget in self.categories.items():
            for btn in cat_widget.scripts:
                script_data = btn.script_data
                if script_data.get("name") == target_name:
                    # 找到了，触发选中
                    QTimer.singleShot(100, lambda sd=script_data: self._on_script_selected(sd))
                    return
    
    def _on_category_toggled(self, category_key, expanded):
        """分类展开/收缩时保存状态"""
        self.category_states[category_key] = expanded
        self.config["category_states"] = self.category_states
        self._save_config()
    
    def _filter_scripts(self, text):
        """过滤脚本"""
        for cat_widget in self.categories.values():
            visible_count = 0
            for btn in cat_widget.scripts:
                matches = btn.matches_filter(text)
                btn.setVisible(matches)
                if matches:
                    visible_count += 1
            
            # 如果有匹配的脚本，展开分类
            if text:
                if visible_count > 0:
                    cat_widget.expand()
                    cat_widget.setVisible(True)
                else:
                    cat_widget.setVisible(False)
            else:
                cat_widget.setVisible(True)
    
    def _expand_all(self):
        """展开所有分类"""
        for cat in self.categories.values():
            cat.expand()
    
    def _collapse_all(self):
        """折叠所有分类"""
        for cat in self.categories.values():
            cat.collapse()
    
    def _on_script_run(self, script_data):
        """双击运行脚本"""
        script_name = script_data.get("name", "")
        category = script_data.get("category", "")
        
        # 如果没有完整信息，先加载
        if "script" not in script_data and category:
            self.status_label.setText("正在加载脚本信息...")
            self._load_script_info(category, script_name, self._on_script_info_for_run)
            return
        
        self.current_script = script_data
        self._run_script()
    
    def _on_script_info_for_run(self, info, error):
        """获取脚本信息后运行"""
        if error:
            self.status_label.setText("加载失败: " + error)
            QMessageBox.warning(self, "加载失败", error)
            return
        
        if info:
            self.current_script = info
            self._run_script()
    
    def _show_script_context_menu(self, script_data, pos):
        """显示脚本右键菜单"""
        # 先保存基本信息，用于后续操作
        self._pending_script_data = script_data
        
        menu = QMenu(self)
        menu.setStyleSheet("""
            QMenu { background: #2b2b2b; border: 1px solid #404040; border-radius: 4px; padding: 4px; }
            QMenu::item { padding: 6px 20px; border-radius: 3px; }
            QMenu::item:selected { background: #357abd; }
        """)
        
        # 运行脚本
        action_run = menu.addAction("▶ 运行脚本")
        action_run.triggered.connect(lambda: self._on_script_run(script_data))
        
        # 下载/更新
        script_name = script_data.get("name", "")
        local_ver = self.local_versions.get(script_name, {}).get("version", "")
        if local_ver:
            action_download = menu.addAction("📥 更新脚本")
        else:
            action_download = menu.addAction("📥 下载脚本")
        action_download.triggered.connect(lambda: self._context_download_script(script_data))
        
        menu.addSeparator()
        
        # 查看源码
        action_github = menu.addAction("🔗 查看源码")
        action_github.triggered.connect(self._open_github)
        
        # 打开发布地址
        url = script_data.get("url", "")
        if url:
            action_url = menu.addAction("🌐 打开发布地址")
            action_url.triggered.connect(lambda: QDesktopServices.openUrl(QUrl(url)))
        
        menu.addSeparator()
        
        # 打开缓存目录
        action_cache = menu.addAction("📁 打开缓存目录")
        action_cache.triggered.connect(self._open_cache_folder)
        
        # 清空缓存
        action_clear = menu.addAction("🗑 清空本地缓存")
        action_clear.triggered.connect(self._clear_cache)
        
        menu.exec_(pos)
    
    def _context_download_script(self, script_data):
        """从右键菜单下载脚本"""
        script_name = script_data.get("name", "")
        category = script_data.get("category", "")
        
        # 如果没有完整信息，先加载
        if "script" not in script_data and category:
            self.status_label.setText("正在加载脚本信息...")
            self._load_script_info(category, script_name, self._on_script_info_for_download)
            return
        
        self.current_script = script_data
        self._download_script()
    
    def _on_script_info_for_download(self, info, error):
        """获取脚本信息后下载"""
        if error:
            self.status_label.setText("加载失败: " + error)
            QMessageBox.warning(self, "加载失败", error)
            return
        
        if info:
            self.current_script = info
            self._download_script()
    
    def _update_all_scripts(self):
        """批量下载/更新所有脚本"""
        # 收集未安装和需要更新的脚本
        scripts_to_download = []
        scripts_to_update = []
        
        for script in self.scripts_data:
            name = script.get("name", "")
            # 检查是否有 script 字段
            if not script.get("script"):
                continue
            
            remote_ver = script.get("version", "1.0.0")
            local_ver = self.local_versions.get(name, {}).get("version", "")
            
            if not local_ver:
                # 未安装
                scripts_to_download.append(script)
            elif compare_versions(local_ver, remote_ver) < 0:
                # 需要更新
                scripts_to_update.append(script)
        
        total_count = len(scripts_to_download) + len(scripts_to_update)
        
        if total_count == 0:
            QMessageBox.information(self, "提示", "所有脚本都已是最新版本！")
            return
        
        msg = ""
        if scripts_to_download:
            msg += "未安装: %d 个\n" % len(scripts_to_download)
        if scripts_to_update:
            msg += "需更新: %d 个\n" % len(scripts_to_update)
        msg += "\n是否全部下载？"
        
        reply = QMessageBox.question(
            self, "批量下载",
            msg,
            QMessageBox.Yes | QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            all_scripts = scripts_to_download + scripts_to_update
            self._batch_update_scripts(all_scripts)
    
    def _batch_update_scripts(self, scripts):
        """批量下载更新脚本"""
        self.status_label.setText("正在批量下载 %d 个脚本..." % len(scripts))
        self.progress_bar.setVisible(True)
        self.progress_bar.setRange(0, len(scripts))
        self.progress_bar.setValue(0)
        
        self._batch_scripts = scripts
        self._batch_index = 0
        self._batch_success = 0
        self._batch_failed = 0
        self._batch_download_next()
    
    def _batch_download_next(self):
        """下载下一个批量脚本"""
        if self._batch_index >= len(self._batch_scripts):
            self.progress_bar.setVisible(False)
            msg = "批量下载完成！\n成功: %d 个" % self._batch_success
            if self._batch_failed > 0:
                msg += "\n失败: %d 个" % self._batch_failed
            self.status_label.setText("完成！成功 %d，失败 %d" % (self._batch_success, self._batch_failed))
            QMessageBox.information(self, "完成", msg)
            # 刷新列表显示
            self._refresh_script_buttons()
            return
        
        script = self._batch_scripts[self._batch_index]
        script_name = script.get("name", "未知")
        
        self.status_label.setText("正在下载: %s (%d/%d)" % (
            script_name, self._batch_index + 1, len(self._batch_scripts)))
        
        # 使用分类路径
        remote_path = self._get_script_remote_path(script)
        if not remote_path or not script.get("script"):
            # 跳过无效脚本
            self._batch_index += 1
            self._batch_failed += 1
            QTimer.singleShot(10, self._batch_download_next)
            return
        
        url = self._get_github_url(remote_path)
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_batch_script_downloaded(d, e, script))
        self.workers.append(worker)
        worker.start()
    
    def _on_batch_script_downloaded(self, data, error, script):
        """批量脚本下载完成"""
        script_name = script.get("name", "")
        
        if not error and data:
            # 使用分类路径保存
            save_path = self._get_script_local_path(script)
            try:
                os.makedirs(os.path.dirname(save_path), exist_ok=True)
                with open(save_path, 'wb') as f:
                    f.write(data)
                
                # 更新版本记录
                script_version = script.get("version", "1.0.0")
                self._update_script_version(script_name, script_version)
                self._batch_success += 1
            except Exception as e:
                print("保存失败: %s - %s" % (script_name, str(e)))
                self._batch_failed += 1
        else:
            print("下载失败: %s - %s" % (script_name, error or "未知错误"))
            self._batch_failed += 1
        
        self._batch_index += 1
        self.progress_bar.setValue(self._batch_index)
        
        # 下载下一个
        QTimer.singleShot(50, self._batch_download_next)
    
    def _refresh_all(self):
        """刷新所有数据（重新加载本地版本和脚本列表）"""
        self._load_local_versions()  # 重新加载本地版本记录
        self._load_scripts_index()   # 重新加载脚本列表
    
    def _show_refresh_menu(self, pos):
        """显示刷新按钮右键菜单"""
        menu = QMenu(self)
        menu.setStyleSheet("""
            QMenu { background: #2b2b2b; border: 1px solid #404040; border-radius: 4px; padding: 4px; }
            QMenu::item { padding: 6px 20px; border-radius: 3px; }
            QMenu::item:selected { background: #357abd; }
        """)
        
        action_refresh = menu.addAction("🔄 刷新列表")
        action_refresh.triggered.connect(self._refresh_all)
        
        menu.addSeparator()
        
        action_clear = menu.addAction("🗑 清空本地缓存")
        action_clear.triggered.connect(self._clear_cache)
        
        action_open = menu.addAction("📁 打开缓存目录")
        action_open.triggered.connect(self._open_cache_folder)
        
        menu.exec_(self.refresh_btn.mapToGlobal(pos))
    
    def _refresh_script_buttons(self):
        """刷新脚本按钮状态"""
        for cat_widget in self.categories.values():
            for btn in cat_widget.scripts:
                btn.update_local_versions(self.local_versions)
    
    def _on_script_selected(self, script_data):
        """脚本选中回调"""
        script_name = script_data.get("name", "-")
        category = script_data.get("category", "")
        
        # 记录当前期望加载的脚本（用于防止异步回调覆盖）
        self._expected_script = script_name
        
        # 保存选中的脚本（立即保存配置）
        self.last_selected_script = {"name": script_name, "category": category}
        self.config["last_selected_script"] = self.last_selected_script
        self._save_config()
        
        # 如果没有详细信息（只有 name 和 category），需要懒加载
        if "version" not in script_data and category:
            # 先显示基本信息
            self.name_label.setText(script_name)
            self.version_label.setText("加载中...")
            self.author_label.setText("-")
            self.optimizer_label.setText("-")
            self.date_label.setText("-")
            self.desc_text.setText("正在加载脚本信息...")
            self._clear_keywords()
            self.run_btn.setEnabled(False)
            self.download_btn.setEnabled(False)
            
            # 异步加载详情
            self._load_script_info(category, script_name, self._on_script_info_ready)
            return
        
        # 有完整信息，直接显示
        self._display_script_info(script_data)
    
    def _on_script_info_ready(self, info, error):
        """脚本详情加载完成"""
        if error:
            self.status_label.setText("加载失败: " + error)
            self.desc_text.setText("加载失败: " + error)
            return
        
        if info:
            # 检查是否是当前期望的脚本（防止旧请求覆盖新选择）
            if hasattr(self, '_expected_script') and info.get("name") != self._expected_script:
                return  # 忽略过时的回调
            self._display_script_info(info)
    
    def _display_script_info(self, script_data):
        """显示脚本详细信息"""
        self.current_script = script_data
        self._expected_script = script_data.get("name", "")
        
        # 强制处理 UI 事件，确保立即更新
        QApplication.processEvents()
        
        script_name = script_data.get("name", "-")
        remote_ver = script_data.get("version", "1.0.0")
        local_info = self.local_versions.get(script_name, {})
        local_ver = local_info.get("version", "")
        
        # 更新信息
        self.name_label.setText(script_name)
        self.version_label.setText("v" + remote_ver)
        self.author_label.setText(script_data.get("author", "-"))
        self.optimizer_label.setText(script_data.get("optimizer", "-") or "-")
        self.date_label.setText(script_data.get("modified_date", "-"))
        
        # 更新本地版本显示
        if local_ver:
            self.local_version_label.setText("v" + local_ver)
            self.local_version_label.setStyleSheet("color: #8bc34a; font-size: 10px;")
        else:
            self.local_version_label.setText("未安装")
            self.local_version_label.setStyleSheet("color: #666; font-size: 10px;")
        
        # 更新版本状态标签
        if not local_ver:
            self.version_status_label.setText("📦 未安装")
            self.version_status_label.setStyleSheet("color: #888; font-size: 10px;")
            self.download_btn.setText("📥 下载")
        else:
            cmp = compare_versions(local_ver, remote_ver)
            if cmp < 0:
                self.version_status_label.setText("🔺 有更新 v%s→v%s" % (local_ver, remote_ver))
                self.version_status_label.setStyleSheet("color: #ff9800; font-size: 10px; font-weight: bold;")
                self.download_btn.setText("📥 更新")
            else:
                self.version_status_label.setText("✓ 已是最新")
                self.version_status_label.setStyleSheet("color: #4caf50; font-size: 10px;")
                self.download_btn.setText("📥 重新下载")
        
        # 更新描述
        self.desc_text.setText(script_data.get("description", "暂无描述"))
        
        # 更新标签
        self._clear_keywords()
        for kw in script_data.get("keywords", []):
            lbl = QLabel(kw)
            lbl.setObjectName("keywordLabel")
            self.keywords_layout.insertWidget(self.keywords_layout.count() - 1, lbl)
        
        # 更新发布地址
        url = script_data.get("url", "")
        if url:
            # 截断显示过长的 URL
            display_url = url if len(url) <= 40 else url[:37] + "..."
            self.url_label.setText(display_url)
            self.url_label.setToolTip(url)
            self.url_label.setEnabled(True)
            self.url_label.setStyleSheet("""
                QPushButton { color: #7ecbff; font-size: 10px; text-decoration: underline; 
                    text-align: left; padding: 0; border: none; background: transparent; }
                QPushButton:hover { color: #a0d8ff; }
            """)
        else:
            self.url_label.setText("无")
            self.url_label.setToolTip("")
            self.url_label.setEnabled(False)
            self.url_label.setStyleSheet("""
                QPushButton { color: #666; font-size: 10px; text-align: left; 
                    padding: 0; border: none; background: transparent; }
            """)
        
        # 更新教程地址
        tutorial = script_data.get("tutorial", "")
        if tutorial:
            self.tutorial_label.setText("📺 查看教程")
            self.tutorial_label.setToolTip(tutorial)
            self.tutorial_label.setEnabled(True)
            self.tutorial_label.setStyleSheet("""
                QPushButton { color: #fb7299; font-size: 10px; text-decoration: underline; 
                    text-align: left; padding: 0; border: none; background: transparent; }
                QPushButton:hover { color: #ff9ab5; }
            """)
        else:
            self.tutorial_label.setText("无")
            self.tutorial_label.setToolTip("")
            self.tutorial_label.setEnabled(False)
            self.tutorial_label.setStyleSheet("""
                QPushButton { color: #666; font-size: 10px; text-align: left; 
                    padding: 0; border: none; background: transparent; }
            """)
        
        # 启用按钮
        self.run_btn.setEnabled(True)
        self.download_btn.setEnabled(True)
        
        self.status_label.setText("已选择: " + script_name)
        
        # 强制刷新 UI，确保详情立即显示
        QApplication.processEvents()
        
        # 加载预览图
        self._load_preview(script_data)
    
    def _clear_keywords(self):
        """清除标签"""
        while self.keywords_layout.count() > 1:
            item = self.keywords_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()
    
    def _load_preview(self, script_data):
        """加载预览图"""
        preview = script_data.get("preview", "")
        if not preview:
            self.preview_label.setText("暂无预览图")
            self.preview_label.setPixmap(QPixmap())
            return
        
        category = script_data.get("category", "")
        
        # 先检查本地缓存（分类文件夹下）
        cache_path = os.path.join(self.local_cache_dir, category, preview) if category else os.path.join(self.local_cache_dir, preview)
        if os.path.exists(cache_path):
            self._set_preview_image(cache_path)
            return
        
        self.preview_label.setText("正在加载预览图...")
        
        # 下载预览图（从分类文件夹）
        if category:
            remote_path = "%s/%s/%s" % (SCRIPTS_PATH, category, preview)
        else:
            remote_path = "%s/%s" % (SCRIPTS_PATH, preview)
        
        url = self._get_github_url(remote_path)
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_preview_loaded(d, e, category, preview))
        self.workers.append(worker)
        worker.start()
    
    def _on_preview_loaded(self, data, error, category, filename):
        """预览图加载完成"""
        if error or not data:
            self.preview_label.setText("预览图加载失败")
            return
        
        # 保存到缓存（分类文件夹下）
        if category:
            cache_path = os.path.join(self.local_cache_dir, category, filename)
        else:
            cache_path = os.path.join(self.local_cache_dir, filename)
        
        try:
            os.makedirs(os.path.dirname(cache_path), exist_ok=True)
            with open(cache_path, 'wb') as f:
                f.write(data)
            self._set_preview_image(cache_path)
        except Exception as e:
            self.preview_label.setText("预览图保存失败: " + str(e))
    
    def _set_preview_image(self, path):
        """设置预览图"""
        pixmap = QPixmap(path)
        if pixmap.isNull():
            self.preview_label.setText("预览图格式不支持")
            return
        
        # 使用固定宽度，避免首次加载时 label 宽度不正确
        preview_width = RIGHT_PANEL_WIDTH - 20
        preview_height = 140
        
        # 缩放图片以适应区域
        scaled = pixmap.scaled(
            preview_width,
            preview_height,
            Qt.KeepAspectRatio,
            Qt.SmoothTransformation
        )
        self.preview_label.setPixmap(scaled)
    
    def _get_script_remote_path(self, script_data):
        """获取脚本的远程路径（包含分类文件夹）"""
        category = script_data.get("category", "未分类")
        script_file = script_data.get("script", "")
        return "%s/%s/%s" % (SCRIPTS_PATH, category, script_file)
    
    def _get_script_local_path(self, script_data):
        """获取脚本的本地缓存路径"""
        category = script_data.get("category", "未分类")
        script_file = script_data.get("script", "")
        return os.path.join(self.local_cache_dir, category, script_file)
    
    def _run_script(self):
        """运行脚本"""
        if not self.current_script:
            return
        
        script_file = self.current_script.get("script", "")
        if not script_file:
            QMessageBox.warning(self, "错误", "脚本文件未指定")
            return
        
        # 先检查本地缓存是否已有脚本
        local_path = self._get_script_local_path(self.current_script)
        if os.path.exists(local_path):
            # 本地已有，直接运行
            self._execute_script(local_path)
            return
        
        # 本地没有，需要下载
        self.status_label.setText("正在下载脚本...")
        self.progress_bar.setVisible(True)
        self.progress_bar.setRange(0, 0)
        
        # 下载脚本（使用分类路径）
        remote_path = self._get_script_remote_path(self.current_script)
        url = self._get_github_url(remote_path)
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_script_downloaded(d, e, self.current_script, True))
        self.workers.append(worker)
        worker.start()
    
    def _download_script(self):
        """下载脚本到本地"""
        if not self.current_script:
            return
        
        script_file = self.current_script.get("script", "")
        if not script_file:
            QMessageBox.warning(self, "错误", "脚本文件未指定")
            return
        
        self.status_label.setText("正在下载脚本...")
        self.progress_bar.setVisible(True)
        self.progress_bar.setRange(0, 0)
        
        # 下载脚本（使用分类路径）
        remote_path = self._get_script_remote_path(self.current_script)
        url = self._get_github_url(remote_path)
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_script_downloaded(d, e, self.current_script, False))
        self.workers.append(worker)
        worker.start()
    
    def _on_script_downloaded(self, data, error, script_data, run_after=False):
        """脚本下载完成"""
        self.progress_bar.setVisible(False)
        
        if error or not data:
            self.status_label.setText("下载失败: " + (error or "未知错误"))
            QMessageBox.warning(self, "下载失败", error or "未知错误")
            return
        
        # 保存脚本（使用分类路径）
        save_path = self._get_script_local_path(script_data)
        try:
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            with open(save_path, 'wb') as f:
                f.write(data)
            
            # 更新本地版本记录
            script_name = script_data.get("name", "")
            script_version = script_data.get("version", "1.0.0")
            if script_name:
                self._update_script_version(script_name, script_version)
                # 刷新当前选中脚本的显示
                if self.current_script and self.current_script.get("name") == script_name:
                    self._on_script_selected(self.current_script)
            
            if run_after:
                self.status_label.setText("正在执行脚本...")
                self._execute_script(save_path)
            else:
                self.status_label.setText("脚本已下载: " + script_data.get("name", ""))
                QMessageBox.information(self, "下载完成", "脚本已保存到:\n" + save_path)
        except Exception as e:
            self.status_label.setText("保存失败: " + str(e))
            QMessageBox.warning(self, "保存失败", str(e))
    
    def _execute_script(self, script_path):
        """执行脚本"""
        if not IN_MAX:
            self.status_label.setText("非 3ds Max 环境，无法执行脚本")
            QMessageBox.information(self, "提示", "请在 3ds Max 中运行此脚本")
            return
        
        try:
            ext = os.path.splitext(script_path)[1].lower()
            if ext in ['.ms', '.mse', '.mcr', '.mzp']:
                # MaxScript 脚本
                rt.fileIn(script_path)
                self.status_label.setText("脚本执行完成")
            elif ext == '.py':
                # Python 脚本
                rt.python.ExecuteFile(script_path)
                self.status_label.setText("脚本执行完成")
            else:
                self.status_label.setText("不支持的脚本格式: " + ext)
        except Exception as e:
            self.status_label.setText("执行失败: " + str(e))
            QMessageBox.warning(self, "执行失败", str(e))
    
    def _open_github(self):
        """打开 GitHub 源码页面（定位到具体脚本文件）"""
        if self.current_script:
            # 获取脚本的远程路径
            script_path = self._get_script_remote_path(self.current_script)
            url = self._get_github_page_url(script_path)
        else:
            # 没有选中脚本时打开脚本目录
            url = self._get_github_page_url(SCRIPTS_PATH)
        QDesktopServices.openUrl(QUrl(url))
    
    def _open_cache_folder(self):
        """打开本地缓存目录"""
        import subprocess
        cache_dir = self.local_cache_dir
        if os.path.exists(cache_dir):
            if sys.platform == "win32":
                os.startfile(cache_dir)
            elif sys.platform == "darwin":
                subprocess.run(["open", cache_dir])
            else:
                subprocess.run(["xdg-open", cache_dir])
        else:
            QMessageBox.information(self, "提示", "缓存目录不存在：\n" + cache_dir)
    
    def _clear_cache(self):
        """清空本地缓存"""
        import shutil
        
        reply = QMessageBox.question(
            self, "确认清空",
            "确定要清空本地缓存吗？\n\n这将删除所有已下载的脚本和配置，\n下次使用时会重新从远程下载。",
            QMessageBox.Yes | QMessageBox.No
        )
        
        if reply != QMessageBox.Yes:
            return
        
        try:
            # 删除缓存目录中的所有内容（保留目录本身）
            for item in os.listdir(self.local_cache_dir):
                item_path = os.path.join(self.local_cache_dir, item)
                if os.path.isdir(item_path):
                    shutil.rmtree(item_path)
                else:
                    os.remove(item_path)
            
            # 清空内存缓存
            self.local_versions = {}
            self.script_info_cache = {}
            self.categories_data = {}
            
            self.status_label.setText("缓存已清空，正在重新加载...")
            QMessageBox.information(self, "完成", "缓存已清空！\n正在重新加载脚本列表...")
            
            # 重新加载
            self._refresh_all()
            
        except Exception as e:
            QMessageBox.warning(self, "错误", "清空缓存失败：\n" + str(e))
    
    def moveEvent(self, event):
        """窗口移动时保存位置"""
        super().moveEvent(event)
        # 使用延迟保存，避免频繁写入
        if not hasattr(self, '_move_timer'):
            self._move_timer = QTimer(self)
            self._move_timer.setSingleShot(True)
            self._move_timer.timeout.connect(self._save_window_position)
        self._move_timer.start(500)  # 500ms 延迟
    
    def closeEvent(self, event):
        # 保存窗口位置
        try:
            self._save_window_position()
        except:
            pass
        
        # 断开所有信号连接，防止回调到已销毁的对象
        try:
            self.closed.disconnect()
        except:
            pass
        
        # 停止所有工作线程
        for worker in self.workers:
            try:
                if worker.isRunning():
                    worker.quit()
                    worker.wait(500)  # 减少等待时间
                    if worker.isRunning():
                        worker.terminate()  # 强制终止
            except:
                pass
        self.workers.clear()
        
        # 清理窗口引用
        _set_win(None)
        
        # 接受关闭事件
        event.accept()
    
    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Escape:
            self.close()
        elif event.key() == Qt.Key_F5:
            self._load_scripts_index()
        else:
            super().keyPressEvent(event)


def show_window():
    """显示窗口（单例模式）"""
    _win = _get_win()
    
    # 如果窗口已存在且有效，直接激活
    if _win is not None:
        try:
            # 检查窗口是否仍然有效
            _win.isVisible()  # 如果窗口已删除，这会抛出异常
            _win.show()
            _win.raise_()
            _win.activateWindow()
            return _win
        except (RuntimeError, AttributeError):
            # 窗口已被删除
            _set_win(None)
    
    # 创建新窗口
    _win = BsScriptHub()
    _set_win(_win)
    _win.show()
    _win.raise_()
    _win.activateWindow()
    return _win

def close_window():
    """关闭窗口"""
    global _win
    if _win:
        try:
            _win.close()
            _win.deleteLater()
        except:
            pass
        _win = None


# 启动窗口
if IN_MAX:
    # 在 Max 中执行时自动显示窗口
    show_window()
elif __name__ == "__main__":
    # 独立运行测试
    app = QApplication.instance() or QApplication(sys.argv)
    win = show_window()
    _exec_func = getattr(app, 'exec', getattr(app, 'exec_', None))
    sys.exit(_exec_func())

