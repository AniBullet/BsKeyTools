# -*- coding: utf-8 -*-
"""
BsScriptHub v1.0 - 远程脚本集合平台
Author: Bullet.S
Compatibility: 3ds Max 2020+ (PySide2/PySide6)
"""

import os
import sys
import json
import tempfile
import threading
from datetime import datetime

# PySide 兼容层
try:
    from PySide6.QtWidgets import (
        QApplication, QWidget, QVBoxLayout, QHBoxLayout, QGridLayout,
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
        QApplication, QWidget, QVBoxLayout, QHBoxLayout, QGridLayout,
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
except ImportError:
    from urllib2 import urlopen, Request, URLError, HTTPError

VERSION = "1.0"

# GitHub 仓库配置
GITHUB_REPO_BASE = "https://raw.githubusercontent.com/AnimatorBullet/BsKeyTools"
GITHUB_BRANCHES = ["main", "dev"]  # 可用分支
DEFAULT_BRANCH = "main"
SCRIPTS_PATH = "_BsKeyTools/Scripts/BsScriptHub"
INDEX_FILE = "scripts_index.json"
LOCAL_VERSIONS_FILE = "local_versions.json"  # 本地版本记录文件


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

# 样式表
STYLE = """
* {
    font-family: "Microsoft YaHei", "Segoe UI", sans-serif;
    font-size: 11px;
}
QWidget {
    background: #2b2b2b;
    color: #e0e0e0;
}
QGroupBox {
    border: 1px solid #404040;
    border-radius: 6px;
    margin-top: 12px;
    padding: 8px;
    padding-top: 16px;
    font-weight: bold;
    color: #7ecbff;
}
QGroupBox::title {
    subcontrol-origin: margin;
    left: 10px;
    padding: 0 6px;
    color: #7ecbff;
}
QPushButton, QToolButton {
    background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
        stop:0 #4a4a4a, stop:1 #3a3a3a);
    border: 1px solid #505050;
    border-radius: 4px;
    padding: 6px 12px;
    min-height: 22px;
    color: #e0e0e0;
}
QPushButton:hover, QToolButton:hover {
    background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
        stop:0 #5a5a5a, stop:1 #4a4a4a);
    border-color: #7ecbff;
    color: #ffffff;
}
QPushButton:pressed {
    background: #333333;
}
QPushButton:disabled {
    background: #3a3a3a;
    color: #666666;
}
QPushButton#runBtn {
    background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
        stop:0 #2d7d46, stop:1 #1f5c32);
    border-color: #3a9956;
    font-weight: bold;
    font-size: 12px;
}
QPushButton#runBtn:hover {
    background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
        stop:0 #3a9956, stop:1 #2d7d46);
    border-color: #4db86a;
}
QLineEdit {
    background: #1e1e1e;
    border: 1px solid #404040;
    border-radius: 4px;
    padding: 6px 10px;
    selection-background-color: #357abd;
    color: #e0e0e0;
}
QLineEdit:focus {
    border-color: #7ecbff;
}
QLineEdit#searchBox {
    font-size: 12px;
    padding: 8px 12px;
    padding-left: 30px;
}
QTreeWidget {
    background: #1e1e1e;
    border: 1px solid #404040;
    border-radius: 4px;
    outline: none;
    color: #e0e0e0;
}
QTreeWidget::item {
    padding: 6px 4px;
    border-radius: 3px;
}
QTreeWidget::item:selected {
    background: #357abd;
    color: #ffffff;
}
QTreeWidget::item:hover:!selected {
    background: #3a3a3a;
}
QTreeWidget::branch:has-children:!has-siblings:closed,
QTreeWidget::branch:closed:has-children:has-siblings {
    border-image: none;
    image: url(none);
}
QTreeWidget::branch:open:has-children:!has-siblings,
QTreeWidget::branch:open:has-children:has-siblings {
    border-image: none;
    image: url(none);
}
QScrollArea {
    border: none;
    background: transparent;
}
QScrollBar:vertical {
    background: #2b2b2b;
    width: 10px;
    margin: 0;
}
QScrollBar::handle:vertical {
    background: #505050;
    min-height: 30px;
    border-radius: 5px;
}
QScrollBar::handle:vertical:hover {
    background: #606060;
}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0;
}
QScrollBar:horizontal {
    background: #2b2b2b;
    height: 10px;
}
QScrollBar::handle:horizontal {
    background: #505050;
    min-width: 30px;
    border-radius: 5px;
}
QTextEdit {
    background: #1e1e1e;
    border: 1px solid #404040;
    border-radius: 4px;
    padding: 8px;
    color: #e0e0e0;
}
QTextEdit:read-only {
    background: #252525;
}
QLabel#titleLabel {
    font-size: 14px;
    font-weight: bold;
    color: #7ecbff;
}
QLabel#versionLabel {
    color: #8bc34a;
    font-weight: bold;
}
QLabel#authorLabel {
    color: #ffb74d;
}
QLabel#keywordLabel {
    background: #404040;
    border-radius: 3px;
    padding: 2px 6px;
    color: #aaaaaa;
}
QFrame#previewFrame {
    background: #1a1a1a;
    border: 1px solid #404040;
    border-radius: 6px;
}
QProgressBar {
    background: #1e1e1e;
    border: 1px solid #404040;
    border-radius: 4px;
    height: 6px;
    text-align: center;
}
QProgressBar::chunk {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 #7ecbff, stop:1 #4da6ff);
    border-radius: 3px;
}
QMenu {
    background: #2b2b2b;
    border: 1px solid #404040;
    border-radius: 4px;
    padding: 4px;
}
QMenu::item {
    padding: 6px 24px;
    border-radius: 3px;
}
QMenu::item:selected {
    background: #357abd;
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
            self.finished.emit(None, "HTTP错误: %d" % e.code)
        except URLError as e:
            self.finished.emit(None, "网络错误: %s" % str(e.reason))
        except Exception as e:
            self.finished.emit(None, "错误: %s" % str(e))


class CollapsibleCategory(QWidget):
    """可折叠的分类组件"""
    toggled = Signal(bool)
    
    def __init__(self, title, parent=None):
        super().__init__(parent)
        self.expanded = True
        self.scripts = []
        
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(2)
        
        # 标题栏
        self.header = QPushButton("▼  " + title)
        self.header.setStyleSheet("""
            QPushButton {
                background: #383838;
                border: none;
                border-radius: 4px;
                padding: 8px 12px;
                text-align: left;
                font-weight: bold;
                color: #7ecbff;
            }
            QPushButton:hover {
                background: #404040;
            }
        """)
        self.header.clicked.connect(self._toggle)
        layout.addWidget(self.header)
        
        # 内容区域
        self.content = QWidget()
        self.content_layout = QVBoxLayout(self.content)
        self.content_layout.setContentsMargins(8, 4, 0, 4)
        self.content_layout.setSpacing(2)
        layout.addWidget(self.content)
        
        self.title = title
    
    def _toggle(self):
        self.expanded = not self.expanded
        self.content.setVisible(self.expanded)
        arrow = "▼" if self.expanded else "▶"
        self.header.setText(arrow + "  " + self.title)
        self.toggled.emit(self.expanded)
    
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
        
        # 根据状态添加标记
        if self.version_status == self.STATUS_UPDATE_AVAILABLE:
            display_name = "🔺 " + name  # 有更新
            border_color = "#ff9800"  # 橙色边框
            bg_color = "#3d3520"
        elif self.version_status == self.STATUS_UP_TO_DATE:
            display_name = "✓ " + name  # 已是最新
            border_color = "#4caf50"  # 绿色边框
            bg_color = "#2d3d2d"
        else:
            display_name = name  # 未安装
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


class BsScriptHub(QWidget):
    """BsScriptHub 主窗口"""
    closed = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setMinimumSize(800, 600)
        self.resize(950, 700)
        self.setWindowFlags(Qt.Window)
        
        self.scripts_data = []
        self.categories = {}
        self.current_script = None
        self.workers = []
        self.current_branch = DEFAULT_BRANCH  # 当前分支
        self.local_cache_dir = self._get_cache_dir()
        self.local_versions = {}  # 本地版本记录
        
        self._update_window_title()
        self._load_local_versions()  # 加载本地版本信息
        self._init_ui()
        self.setStyleSheet(STYLE)
        
        # 延迟加载脚本列表
        QTimer.singleShot(100, self._load_scripts_index)
    
    def _update_window_title(self):
        """更新窗口标题"""
        branch_tag = " [DEV]" if self.current_branch == "dev" else ""
        self.setWindowTitle("BsScriptHub v%s - 远程脚本集合%s" % (VERSION, branch_tag))
    
    def _get_github_url(self, path=""):
        """获取当前分支的 GitHub URL"""
        base_url = "%s/%s" % (GITHUB_REPO_BASE, self.current_branch)
        if path:
            return "%s/%s" % (base_url, path)
        return base_url
    
    def _load_local_versions(self):
        """加载本地版本记录"""
        versions_file = os.path.join(self.local_cache_dir, LOCAL_VERSIONS_FILE)
        if os.path.exists(versions_file):
            try:
                with open(versions_file, 'r', encoding='utf-8') as f:
                    self.local_versions = json.load(f)
            except:
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
        """获取本地缓存目录"""
        if IN_MAX:
            cache = os.path.join(str(rt.getDir(rt.name("scripts"))), "BulletScripts", "BsScriptHub_Cache")
        else:
            cache = os.path.join(tempfile.gettempdir(), "BsScriptHub_Cache")
        if not os.path.exists(cache):
            os.makedirs(cache)
        return cache
    
    def _init_ui(self):
        main_layout = QHBoxLayout(self)
        main_layout.setContentsMargins(12, 12, 12, 12)
        main_layout.setSpacing(12)
        
        # ========== 左侧面板：搜索和分类 ==========
        left_panel = QWidget()
        left_layout = QVBoxLayout(left_panel)
        left_layout.setContentsMargins(0, 0, 0, 0)
        left_layout.setSpacing(8)
        
        # 标题和刷新按钮
        title_row = QHBoxLayout()
        title_lbl = QLabel("🔧 脚本仓库")
        title_lbl.setStyleSheet("font-size: 14px; font-weight: bold; color: #7ecbff;")
        title_row.addWidget(title_lbl)
        title_row.addStretch()
        
        # 分支切换按钮
        self.branch_btn = QPushButton("main")
        self.branch_btn.setToolTip("点击切换分支\nmain: 稳定版\ndev: 开发版(测试功能)")
        self.branch_btn.setFixedWidth(50)
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
        self.branch_btn.clicked.connect(self._toggle_branch)
        title_row.addWidget(self.branch_btn)
        
        self.refresh_btn = QToolButton()
        self.refresh_btn.setText("🔄")
        self.refresh_btn.setToolTip("刷新脚本列表")
        self.refresh_btn.clicked.connect(self._load_scripts_index)
        title_row.addWidget(self.refresh_btn)
        left_layout.addLayout(title_row)
        
        # 搜索框
        search_layout = QHBoxLayout()
        self.search_box = QLineEdit()
        self.search_box.setObjectName("searchBox")
        self.search_box.setPlaceholderText("🔍 搜索脚本名称、标签、作者...")
        self.search_box.textChanged.connect(self._filter_scripts)
        search_layout.addWidget(self.search_box)
        left_layout.addLayout(search_layout)
        
        # 工具栏
        toolbar = QHBoxLayout()
        self.expand_all_btn = QPushButton("展开全部")
        self.expand_all_btn.clicked.connect(self._expand_all)
        self.collapse_all_btn = QPushButton("折叠全部")
        self.collapse_all_btn.clicked.connect(self._collapse_all)
        toolbar.addWidget(self.expand_all_btn)
        toolbar.addWidget(self.collapse_all_btn)
        toolbar.addStretch()
        left_layout.addLayout(toolbar)
        
        # 进度条
        self.progress_bar = QProgressBar()
        self.progress_bar.setVisible(False)
        self.progress_bar.setTextVisible(False)
        self.progress_bar.setMaximumHeight(4)
        left_layout.addWidget(self.progress_bar)
        
        # 分类滚动区域
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        
        self.categories_widget = QWidget()
        self.categories_layout = QVBoxLayout(self.categories_widget)
        self.categories_layout.setContentsMargins(0, 0, 0, 0)
        self.categories_layout.setSpacing(6)
        self.categories_layout.addStretch()
        
        scroll.setWidget(self.categories_widget)
        left_layout.addWidget(scroll, 1)
        
        # 状态标签
        self.status_label = QLabel("准备加载脚本...")
        self.status_label.setStyleSheet("color: #888888; padding: 4px;")
        left_layout.addWidget(self.status_label)
        
        left_panel.setFixedWidth(320)
        main_layout.addWidget(left_panel)
        
        # ========== 右侧面板：详情 ==========
        right_panel = QWidget()
        right_layout = QVBoxLayout(right_panel)
        right_layout.setContentsMargins(0, 0, 0, 0)
        right_layout.setSpacing(12)
        
        # 预览图区域
        preview_frame = QFrame()
        preview_frame.setObjectName("previewFrame")
        preview_frame.setMinimumHeight(200)
        preview_frame.setMaximumHeight(280)
        preview_layout = QVBoxLayout(preview_frame)
        preview_layout.setContentsMargins(12, 12, 12, 12)
        
        self.preview_label = QLabel("选择脚本查看预览")
        self.preview_label.setAlignment(Qt.AlignCenter)
        self.preview_label.setStyleSheet("color: #666666; font-size: 13px;")
        preview_layout.addWidget(self.preview_label)
        right_layout.addWidget(preview_frame)
        
        # 脚本信息区域
        info_group = QGroupBox("脚本信息")
        info_layout = QGridLayout(info_group)
        info_layout.setSpacing(8)
        
        # 脚本名称
        info_layout.addWidget(QLabel("名称:"), 0, 0)
        self.name_label = QLabel("-")
        self.name_label.setObjectName("titleLabel")
        info_layout.addWidget(self.name_label, 0, 1, 1, 3)
        
        # 版本号 - 远程版本
        info_layout.addWidget(QLabel("远程版本:"), 1, 0)
        self.version_label = QLabel("-")
        self.version_label.setObjectName("versionLabel")
        info_layout.addWidget(self.version_label, 1, 1)
        
        # 版本号 - 本地版本
        info_layout.addWidget(QLabel("本地版本:"), 1, 2)
        self.local_version_label = QLabel("-")
        info_layout.addWidget(self.local_version_label, 1, 3)
        
        # 版本状态
        self.version_status_label = QLabel("")
        self.version_status_label.setStyleSheet("font-weight: bold; padding: 2px 8px; border-radius: 3px;")
        info_layout.addWidget(self.version_status_label, 2, 0, 1, 4)
        
        # 作者
        info_layout.addWidget(QLabel("作者:"), 3, 0)
        self.author_label = QLabel("-")
        self.author_label.setObjectName("authorLabel")
        info_layout.addWidget(self.author_label, 3, 1)
        
        # 优化人
        info_layout.addWidget(QLabel("优化:"), 3, 2)
        self.optimizer_label = QLabel("-")
        info_layout.addWidget(self.optimizer_label, 3, 3)
        
        # 修改日期
        info_layout.addWidget(QLabel("更新:"), 4, 0)
        self.date_label = QLabel("-")
        info_layout.addWidget(self.date_label, 4, 1, 1, 3)
        
        # 标签
        info_layout.addWidget(QLabel("标签:"), 5, 0)
        self.keywords_layout = QHBoxLayout()
        self.keywords_layout.setSpacing(4)
        self.keywords_layout.addStretch()
        info_layout.addLayout(self.keywords_layout, 5, 1, 1, 3)
        
        right_layout.addWidget(info_group)
        
        # 描述区域
        desc_group = QGroupBox("功能描述")
        desc_layout = QVBoxLayout(desc_group)
        self.desc_text = QTextEdit()
        self.desc_text.setReadOnly(True)
        self.desc_text.setMinimumHeight(100)
        self.desc_text.setPlaceholderText("选择脚本查看详细描述...")
        desc_layout.addWidget(self.desc_text)
        right_layout.addWidget(desc_group, 1)
        
        # 操作按钮
        btn_layout = QHBoxLayout()
        
        self.run_btn = QPushButton("▶  运行脚本")
        self.run_btn.setObjectName("runBtn")
        self.run_btn.setEnabled(False)
        self.run_btn.clicked.connect(self._run_script)
        
        self.download_btn = QPushButton("📥  下载到本地")
        self.download_btn.setEnabled(False)
        self.download_btn.clicked.connect(self._download_script)
        
        self.github_btn = QPushButton("🔗  查看源码")
        self.github_btn.clicked.connect(self._open_github)
        
        btn_layout.addWidget(self.run_btn, 2)
        btn_layout.addWidget(self.download_btn, 1)
        btn_layout.addWidget(self.github_btn, 1)
        right_layout.addLayout(btn_layout)
        
        main_layout.addWidget(right_panel, 1)
    
    def _toggle_branch(self):
        """切换分支"""
        # 切换到下一个分支
        current_idx = GITHUB_BRANCHES.index(self.current_branch)
        next_idx = (current_idx + 1) % len(GITHUB_BRANCHES)
        self.current_branch = GITHUB_BRANCHES[next_idx]
        
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
    
    def _load_scripts_index(self):
        """加载远程脚本索引"""
        branch_text = " [%s]" % self.current_branch if self.current_branch != "main" else ""
        self.status_label.setText("正在连接远程仓库%s..." % branch_text)
        self.progress_bar.setVisible(True)
        self.progress_bar.setRange(0, 0)  # 无限进度
        
        url = self._get_github_url("%s/%s" % (SCRIPTS_PATH, INDEX_FILE))
        worker = NetworkWorker(url)
        worker.finished.connect(self._on_index_loaded)
        self.workers.append(worker)
        worker.start()
    
    def _on_index_loaded(self, data, error):
        """索引加载完成回调"""
        self.progress_bar.setVisible(False)
        
        if error:
            self.status_label.setText("加载失败: " + error)
            # 尝试加载本地缓存
            self._load_local_cache()
            return
        
        try:
            index_data = json.loads(data.decode('utf-8'))
            self.scripts_data = index_data.get("scripts", [])
            
            # 保存到本地缓存
            cache_file = os.path.join(self.local_cache_dir, INDEX_FILE)
            with open(cache_file, 'w', encoding='utf-8') as f:
                json.dump(index_data, f, ensure_ascii=False, indent=2)
            
            self._build_categories()
            self.status_label.setText("已加载 %d 个脚本" % len(self.scripts_data))
        except Exception as e:
            self.status_label.setText("解析失败: " + str(e))
            self._load_local_cache()
    
    def _load_local_cache(self):
        """加载本地缓存"""
        cache_file = os.path.join(self.local_cache_dir, INDEX_FILE)
        if os.path.exists(cache_file):
            try:
                with open(cache_file, 'r', encoding='utf-8') as f:
                    index_data = json.load(f)
                self.scripts_data = index_data.get("scripts", [])
                self._build_categories()
                self.status_label.setText("已从缓存加载 %d 个脚本 (离线模式)" % len(self.scripts_data))
            except:
                self.status_label.setText("无可用数据")
    
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
        
        # 按分类组织脚本
        cat_scripts = {}
        for script in self.scripts_data:
            cat = script.get("category", "未分类")
            if cat not in cat_scripts:
                cat_scripts[cat] = []
            cat_scripts[cat].append(script)
        
        # 创建分类组件
        for cat_name in sorted(cat_scripts.keys()):
            cat_widget = CollapsibleCategory(cat_name)
            self.categories[cat_name] = cat_widget
            
            for script in cat_scripts[cat_name]:
                btn = ScriptButton(script, self.local_versions)
                btn.script_selected.connect(self._on_script_selected)
                cat_widget.add_script_item(btn)
            
            self.categories_layout.addWidget(cat_widget)
        
        self.categories_layout.addStretch()
    
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
    
    def _on_script_selected(self, script_data):
        """脚本选中回调"""
        self.current_script = script_data
        
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
            self.local_version_label.setStyleSheet("color: #8bc34a;")  # 绿色
        else:
            self.local_version_label.setText("未安装")
            self.local_version_label.setStyleSheet("color: #888888;")  # 灰色
        
        # 更新版本状态标签
        if not local_ver:
            self.version_status_label.setText("📦 尚未安装此脚本")
            self.version_status_label.setStyleSheet("color: #888888; background: #333333; font-weight: bold; padding: 4px 10px; border-radius: 3px;")
            self.download_btn.setText("📥  下载安装")
        else:
            cmp = compare_versions(local_ver, remote_ver)
            if cmp < 0:
                self.version_status_label.setText("🔺 有新版本可用！ (v%s → v%s)" % (local_ver, remote_ver))
                self.version_status_label.setStyleSheet("color: #fff; background: #ff9800; font-weight: bold; padding: 4px 10px; border-radius: 3px;")
                self.download_btn.setText("📥  更新脚本")
            else:
                installed_date = local_info.get("installed_date", "")
                if installed_date:
                    self.version_status_label.setText("✓ 已是最新版本 (安装于 %s)" % installed_date)
                else:
                    self.version_status_label.setText("✓ 已是最新版本")
                self.version_status_label.setStyleSheet("color: #fff; background: #4caf50; font-weight: bold; padding: 4px 10px; border-radius: 3px;")
                self.download_btn.setText("📥  重新下载")
        
        # 更新描述
        self.desc_text.setText(script_data.get("description", "暂无描述"))
        
        # 更新标签
        self._clear_keywords()
        for kw in script_data.get("keywords", []):
            lbl = QLabel(kw)
            lbl.setObjectName("keywordLabel")
            self.keywords_layout.insertWidget(self.keywords_layout.count() - 1, lbl)
        
        # 启用按钮
        self.run_btn.setEnabled(True)
        self.download_btn.setEnabled(True)
        
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
        
        # 先检查本地缓存
        cache_path = os.path.join(self.local_cache_dir, preview)
        if os.path.exists(cache_path):
            self._set_preview_image(cache_path)
            return
        
        self.preview_label.setText("正在加载预览图...")
        
        # 下载预览图
        url = self._get_github_url("%s/%s" % (SCRIPTS_PATH, preview))
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_preview_loaded(d, e, preview))
        self.workers.append(worker)
        worker.start()
    
    def _on_preview_loaded(self, data, error, filename):
        """预览图加载完成"""
        if error or not data:
            self.preview_label.setText("预览图加载失败")
            return
        
        # 保存到缓存
        cache_path = os.path.join(self.local_cache_dir, filename)
        try:
            # 确保目录存在
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
        
        # 缩放图片以适应区域
        scaled = pixmap.scaled(
            self.preview_label.width() - 20,
            240,
            Qt.KeepAspectRatio,
            Qt.SmoothTransformation
        )
        self.preview_label.setPixmap(scaled)
    
    def _run_script(self):
        """运行脚本"""
        if not self.current_script:
            return
        
        script_file = self.current_script.get("script", "")
        if not script_file:
            QMessageBox.warning(self, "错误", "脚本文件未指定")
            return
        
        self.status_label.setText("正在下载脚本...")
        self.progress_bar.setVisible(True)
        self.progress_bar.setRange(0, 0)
        
        # 下载脚本
        url = self._get_github_url("%s/%s" % (SCRIPTS_PATH, script_file))
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_script_downloaded(d, e, script_file, True))
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
        
        url = self._get_github_url("%s/%s" % (SCRIPTS_PATH, script_file))
        worker = NetworkWorker(url)
        worker.finished.connect(lambda d, e: self._on_script_downloaded(d, e, script_file, False))
        self.workers.append(worker)
        worker.start()
    
    def _on_script_downloaded(self, data, error, filename, run_after=False):
        """脚本下载完成"""
        self.progress_bar.setVisible(False)
        
        if error or not data:
            self.status_label.setText("下载失败: " + (error or "未知错误"))
            QMessageBox.warning(self, "下载失败", error or "未知错误")
            return
        
        # 保存脚本
        save_path = os.path.join(self.local_cache_dir, filename)
        try:
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            with open(save_path, 'wb') as f:
                f.write(data)
            
            # 同时下载对应的 JSON 配置文件
            json_file = os.path.splitext(filename)[0] + ".json"
            json_url = self._get_github_url("%s/%s" % (SCRIPTS_PATH, json_file))
            try:
                req = Request(json_url)
                req.add_header('User-Agent', 'BsScriptHub/1.0')
                response = urlopen(req, timeout=10)
                json_data = response.read()
                json_path = os.path.join(self.local_cache_dir, json_file)
                with open(json_path, 'wb') as f:
                    f.write(json_data)
            except:
                pass
            
            # 更新本地版本记录
            if self.current_script:
                script_name = self.current_script.get("name", "")
                script_version = self.current_script.get("version", "1.0.0")
                if script_name:
                    self._update_script_version(script_name, script_version)
                    # 刷新当前选中脚本的显示
                    self._on_script_selected(self.current_script)
            
            if run_after:
                self.status_label.setText("正在执行脚本...")
                self._execute_script(save_path)
            else:
                self.status_label.setText("脚本已下载到: " + save_path)
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
        """打开 GitHub 仓库"""
        url = "https://github.com/AnimatorBullet/BsKeyTools/tree/main/_BsKeyTools/Scripts/BsScriptHub"
        QDesktopServices.openUrl(QUrl(url))
    
    def closeEvent(self, event):
        # 停止所有工作线程
        for worker in self.workers:
            if worker.isRunning():
                worker.quit()
                worker.wait(1000)
        self.closed.emit()
        super().closeEvent(event)
    
    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Escape:
            self.close()
        elif event.key() == Qt.Key_F5:
            self._load_scripts_index()
        else:
            super().keyPressEvent(event)


# 全局窗口实例
_win = None

def show_window():
    """显示窗口"""
    global _win
    if _win:
        try:
            _win.close()
            _win.deleteLater()
        except:
            pass
    _win = BsScriptHub()
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


# 直接运行时启动
if __name__ == "__main__":
    app = QApplication.instance() or QApplication(sys.argv)
    win = show_window()
    if not IN_MAX:
        sys.exit(app.exec() if PYSIDE_VERSION == 6 else app.exec_())
