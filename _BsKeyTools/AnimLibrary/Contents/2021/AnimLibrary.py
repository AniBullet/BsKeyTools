# AnimLibrary_Bullet.S
# 基于 Posture 代码改写，添加库管理功能

import json
import os
import shutil
import pymxs
import time
import uuid
import base64
from io import BytesIO
from datetime import datetime
from PySide2 import QtGui, QtCore, QtWidgets
from PySide2.QtCore import Qt, QSize, QBuffer, QIODevice
from PySide2.QtGui import QIcon, QColor, QPixmap, QPainter, QImage
from PySide2.QtWidgets import (QMainWindow, QWidget, QFileDialog, QMessageBox,
                               QListWidget, QListWidgetItem, QTreeWidget, QTreeWidgetItem,
                               QSplitter, QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                               QLineEdit, QCheckBox, QRadioButton, QGroupBox, QTextEdit,
                               QProgressBar, QScrollArea, QGridLayout, QMenu, QSlider,
                               QFrame, QColorDialog, QInputDialog, QLayout, QWidgetItem)
from pymxs import runtime as mxs
from qtmax import GetQMaxMainWindow


# 流式布局类（支持自动换行）
class FlowLayout(QLayout):
    def __init__(self, parent=None, margin=0, spacing=-1):
        super().__init__(parent)
        if parent is not None:
            self.setContentsMargins(margin, margin, margin, margin)
        self.setSpacing(spacing)
        self._item_list = []

    def __del__(self):
        item = self.takeAt(0)
        while item:
            item = self.takeAt(0)

    def addItem(self, item):
        self._item_list.append(item)

    def count(self):
        return len(self._item_list)

    def itemAt(self, index):
        if 0 <= index < len(self._item_list):
            return self._item_list[index]
        return None

    def takeAt(self, index):
        if 0 <= index < len(self._item_list):
            return self._item_list.pop(index)
        return None

    def expandingDirections(self):
        return QtCore.Qt.Orientation(0)

    def hasHeightForWidth(self):
        return True

    def heightForWidth(self, width):
        height = self._do_layout(QtCore.QRect(0, 0, width, 0), True)
        return height

    def setGeometry(self, rect):
        super().setGeometry(rect)
        self._do_layout(rect, False)

    def sizeHint(self):
        return self.minimumSize()

    def minimumSize(self):
        size = QtCore.QSize()
        for item in self._item_list:
            size = size.expandedTo(item.minimumSize())
        margin = self.contentsMargins().left()
        size += QtCore.QSize(2 * margin, 2 * margin)
        return size

    def _do_layout(self, rect, test_only):
        x = rect.x()
        y = rect.y()
        line_height = 0

        for item in self._item_list:
            widget = item.widget()
            space_x = self.spacing()
            space_y = self.spacing()
            next_x = x + item.sizeHint().width() + space_x
            if next_x - space_x > rect.right() and line_height > 0:
                x = rect.x()
                y = y + line_height + space_y
                next_x = x + item.sizeHint().width() + space_x
                line_height = 0

            if not test_only:
                item.setGeometry(QtCore.QRect(QtCore.QPoint(x, y), item.sizeHint()))

            x = next_x
            line_height = max(line_height, item.sizeHint().height())

        return y + line_height - rect.y()


class AnimLibraryDialog(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowFlags(Qt.Window)
        
        # 初始化变量
        self.library_path = ""  # 库路径（根目录）
        self.current_folder_path = ""  # 当前查看的文件夹
        self.global_data = {}  # 存储所有姿势数据
        self.ordered_selection_list = []
        self.current_selected_pose = None  # 当前选中的姿势
        self.card_size = 150  # 姿势卡片大小
        self.selected_poses = []  # 多选的姿势列表
        self.selected_cards = []  # 多选的卡片列表
        self.filter_tags = []  # 标签筛选列表 [{"name": "标签名", "color": "#RRGGBB"}, ...]
        self.active_filter_tag = None  # 当前激活的筛选标签名
        
        # 配置文件路径
        self.config_file = self.get_config_path()
        
        # 设置窗口
        self.setWindowTitle('AnimLibrary_v1.0_Bullet.S')
        self.resize(1000, 600)
        
        # 定义对象类型（用于图标）
        self.geometry_class = mxs.execute("GeometryClass")
        self.shape_class = mxs.execute("shape")
        self.light_class = mxs.execute("light")
        self.camera_class = mxs.execute("camera")
        self.helper_class = mxs.execute("helper")
        
        # 初始化UI
        self.init_ui()
        self.connect_signals()
        
        # 加载配置（如果存在，会自动加载上次的库）
        self.load_config()
        
        # 如果配置中没有库路径，加载默认库
        if not self.library_path:
            self.load_default_library()
    
    def init_ui(self):
        """初始化界面"""
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout()
        central_widget.setLayout(main_layout)
        
        # 顶部工具栏
        toolbar_layout = QHBoxLayout()
        toolbar_layout.addWidget(QLabel("路径:"))
        self.path_edit = QLineEdit()
        self.path_edit.setReadOnly(True)
        toolbar_layout.addWidget(self.path_edit, 1)
        self.btn_browse = QPushButton("重设库目录")
        toolbar_layout.addWidget(self.btn_browse)
        self.btn_new_folder = QPushButton("新建文件夹")
        toolbar_layout.addWidget(self.btn_new_folder)
        
        # 搜索框
        toolbar_layout.addWidget(QLabel("搜索:"))
        self.search_edit = QLineEdit()
        self.search_edit.setPlaceholderText("输入名称或标签...")
        self.search_edit.setMaximumWidth(200)
        toolbar_layout.addWidget(self.search_edit)
        
        main_layout.addLayout(toolbar_layout)
        
        # 分割器
        splitter = QSplitter(Qt.Horizontal)
        
        # 左侧：文件夹树
        left_panel = QWidget()
        left_layout = QVBoxLayout()
        left_panel.setLayout(left_layout)
        left_layout.addWidget(QLabel("文件夹"))
        self.folder_tree = QTreeWidget()
        self.folder_tree.setHeaderHidden(True)
        self.folder_tree.setContextMenuPolicy(Qt.CustomContextMenu)
        self.folder_tree.customContextMenuRequested.connect(self.show_folder_context_menu)
        left_layout.addWidget(self.folder_tree)
        splitter.addWidget(left_panel)
        
        # 中间：姿势网格视图（带缩略图）
        center_panel = QWidget()
        center_layout = QVBoxLayout()
        center_panel.setLayout(center_layout)
        
        # 顶部控制栏（第一行：标题和图标大小控制）
        control_layout_top = QHBoxLayout()
        
        title_label = QLabel("姿势库")
        title_label.setStyleSheet("QLabel { font-weight: bold; font-size: 12px; }")
        control_layout_top.addWidget(title_label)
        
        control_layout_top.addStretch()
        
        # 缩放控制
        control_layout_top.addWidget(QLabel("图标大小:"))
        self.size_slider = QSlider(Qt.Horizontal)
        self.size_slider.setMinimum(80)
        self.size_slider.setMaximum(250)
        self.size_slider.setValue(150)
        self.size_slider.setMaximumWidth(100)
        control_layout_top.addWidget(self.size_slider)
        
        center_layout.addLayout(control_layout_top)
        
        # 标签筛选栏（可展开设计）
        self.tag_container = QWidget()
        self.tag_container.setMaximumHeight(32)  # 默认单行高度
        tag_layout = QHBoxLayout(self.tag_container)
        tag_layout.setContentsMargins(0, 3, 0, 3)
        tag_layout.setSpacing(5)
        
        # 添加标签按钮（图标样式）
        self.btn_add_tag = QPushButton("+")
        self.btn_add_tag.setFixedSize(26, 26)
        self.btn_add_tag.setToolTip("添加新的筛选标签")
        self.btn_add_tag.setStyleSheet("""
            QPushButton {
                background-color: palette(button);
                border: 1px solid palette(mid);
                border-radius: 3px;
                font-weight: bold;
                font-size: 14px;
            }
            QPushButton:hover {
                background-color: palette(light);
                border: 1px solid palette(highlight);
            }
        """)
        self.btn_add_tag.clicked.connect(self.add_new_tag)
        tag_layout.addWidget(self.btn_add_tag)
        
        # 展开/收起按钮
        self.btn_expand_tags = QPushButton("▼")
        self.btn_expand_tags.setFixedSize(26, 26)
        self.btn_expand_tags.setToolTip("展开/收起标签区域")
        self.btn_expand_tags.setStyleSheet("""
            QPushButton {
                background-color: palette(button);
                border: 1px solid palette(mid);
                border-radius: 3px;
                font-weight: bold;
                font-size: 10px;
            }
            QPushButton:hover {
                background-color: palette(light);
                border: 1px solid palette(highlight);
            }
        """)
        self.btn_expand_tags.clicked.connect(self.toggle_tag_area)
        tag_layout.addWidget(self.btn_expand_tags)
        
        # 标签筛选按钮区域（使用FlowLayout支持换行，带滚动）
        self.tag_expanded = False  # 是否展开
        self.tag_scroll_area = QScrollArea()
        self.tag_scroll_area.setWidgetResizable(True)
        self.tag_scroll_area.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.tag_scroll_area.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
        self.tag_scroll_area.setMinimumHeight(30)
        self.tag_scroll_area.setMaximumHeight(30)  # 默认1行
        self.tag_scroll_area.setFrameShape(QFrame.NoFrame)
        
        self.tag_buttons_widget = QWidget()
        self.tag_buttons_layout = FlowLayout(self.tag_buttons_widget, margin=0, spacing=5)
        self.tag_buttons_widget.setLayout(self.tag_buttons_layout)
        self.tag_scroll_area.setWidget(self.tag_buttons_widget)
        
        tag_layout.addWidget(self.tag_scroll_area, 1)  # 拉伸占据剩余空间
        
        center_layout.addWidget(self.tag_container)
        
        # 筛选提示横幅（默认隐藏）
        self.filter_banner = QLabel()
        self.filter_banner.setAlignment(Qt.AlignCenter)
        self.filter_banner.setStyleSheet("""
            QLabel {
                background-color: palette(highlight);
                color: palette(highlighted-text);
                padding: 8px;
                font-weight: bold;
                border-radius: 3px;
            }
        """)
        self.filter_banner.setVisible(False)
        self.filter_banner.mousePressEvent = lambda event: self.clear_filter()  # 点击取消筛选
        self.filter_banner.setCursor(Qt.PointingHandCursor)
        center_layout.addWidget(self.filter_banner)
        
        # 使用滚动区域显示缩略图网格
        self.scroll_area = QScrollArea()
        self.scroll_area.setWidgetResizable(True)
        self.grid_widget = QWidget()
        self.grid_layout = QGridLayout()
        self.grid_layout.setAlignment(Qt.AlignLeft | Qt.AlignTop)  # 左上对齐
        self.grid_layout.setSpacing(10)
        self.grid_widget.setLayout(self.grid_layout)
        self.scroll_area.setWidget(self.grid_widget)
        center_layout.addWidget(self.scroll_area)
        
        splitter.addWidget(center_panel)
        
        # 右侧：操作面板
        right_panel = QWidget()
        right_layout = QVBoxLayout()
        right_panel.setLayout(right_layout)
        
        # 保存组
        save_group = QGroupBox("保存姿势")
        save_layout = QVBoxLayout()
        
        self.save_name_edit = QLineEdit()
        self.save_name_edit.setPlaceholderText("输入姿势名称... (必填)")
        save_layout.addWidget(self.save_name_edit)
        
        self.save_tags_edit = QLineEdit()
        self.save_tags_edit.setPlaceholderText("标签 (可选，用逗号分隔)")
        save_layout.addWidget(self.save_tags_edit)
        
        self.save_desc_edit = QLineEdit()
        self.save_desc_edit.setPlaceholderText("描述 (可选)")
        save_layout.addWidget(self.save_desc_edit)
        
        # 保存选项：全局/局部单选 + 仅选中复选
        save_opt_layout = QHBoxLayout()
        self.save_rb_global = QRadioButton("全局")
        self.save_rb_global.setChecked(True)
        self.save_rb_local = QRadioButton("局部")
        save_opt_layout.addWidget(self.save_rb_global)
        save_opt_layout.addWidget(self.save_rb_local)
        save_opt_layout.addStretch()
        save_layout.addLayout(save_opt_layout)
        
        self.chk_save_selected_only = QCheckBox("仅选中")
        self.chk_save_selected_only.setChecked(False)  # 默认不勾选，保存所有
        self.chk_save_selected_only.setToolTip("勾选：只保存当前选中的对象\n不勾选：保存所有对象")
        save_layout.addWidget(self.chk_save_selected_only)
        
        # 按钮组：覆盖 + 保存
        btn_layout = QHBoxLayout()
        self.btn_overwrite = QPushButton("覆盖")
        self.btn_overwrite.setStyleSheet("QPushButton { padding: 8px; }")
        self.btn_overwrite.setToolTip("覆盖选中的pose（需要先在下方选中一个pose）")
        self.btn_overwrite.setMaximumWidth(60)  # 限制覆盖按钮宽度
        btn_layout.addWidget(self.btn_overwrite)
        
        self.btn_save = QPushButton("保存")
        self.btn_save.setStyleSheet("QPushButton { font-weight: bold; padding: 8px; }")
        btn_layout.addWidget(self.btn_save, 1)  # 拉伸因子1，占据剩余空间
        
        save_layout.addLayout(btn_layout)
        
        save_group.setLayout(save_layout)
        right_layout.addWidget(save_group)
        
        # 详情组 - 显示选中pose的信息
        detail_group = QGroupBox("详情")
        detail_layout = QVBoxLayout()
        
        self.detail_name_label = QLabel("名称: -")
        self.detail_name_label.setWordWrap(True)
        self.detail_name_label.setStyleSheet("QLabel { color: palette(window-text); font-weight: bold; }")
        detail_layout.addWidget(self.detail_name_label)
        
        detail_layout.addWidget(QLabel("标签:"))
        # 标签区域使用 QTextEdit 以支持更多内容显示
        self.detail_tags_label = QTextEdit()
        self.detail_tags_label.setReadOnly(True)
        self.detail_tags_label.setMinimumHeight(80)  # 增大显示区域
        self.detail_tags_label.setMaximumHeight(120)
        self.detail_tags_label.setStyleSheet("QTextEdit { color: palette(window-text); padding: 4px; background-color: palette(base); }")
        detail_layout.addWidget(self.detail_tags_label)
        
        detail_layout.addWidget(QLabel("描述:"))
        self.detail_desc_label = QLabel("-")
        self.detail_desc_label.setWordWrap(True)
        self.detail_desc_label.setMinimumHeight(40)
        self.detail_desc_label.setStyleSheet("QLabel { color: palette(window-text); padding: 4px; background-color: palette(base); }")
        detail_layout.addWidget(self.detail_desc_label)
        
        detail_group.setLayout(detail_layout)
        right_layout.addWidget(detail_group)
        
        # 加载组
        load_group = QGroupBox("加载姿势")
        load_layout = QVBoxLayout()
        
        # 全局/局部单选放在同一行
        load_mode_layout = QHBoxLayout()
        self.rb_global = QRadioButton("全局")
        self.rb_global.setChecked(True)
        self.rb_local = QRadioButton("局部")
        load_mode_layout.addWidget(self.rb_global)
        load_mode_layout.addWidget(self.rb_local)
        load_mode_layout.addStretch()
        load_layout.addLayout(load_mode_layout)
        
        # 暴力加载选项
        self.chk_force_load = QCheckBox("暴力加载")
        self.chk_force_load.setToolTip("不使用UUID匹配，直接通过节点名称匹配\n可以将pose应用到同名骨骼上")
        load_layout.addWidget(self.chk_force_load)
        
        # 仅选中选项
        self.chk_load_selected_only = QCheckBox("仅选中")
        self.chk_load_selected_only.setChecked(False)  # 默认不勾选，加载到所有匹配对象
        self.chk_load_selected_only.setToolTip("勾选：只加载到当前选中的对象\n不勾选：加载到所有匹配的对象")
        load_layout.addWidget(self.chk_load_selected_only)
        
        self.btn_load = QPushButton("加载")
        self.btn_load.setStyleSheet("QPushButton { font-weight: bold; padding: 8px; }")
        load_layout.addWidget(self.btn_load)
        
        load_group.setLayout(load_layout)
        right_layout.addWidget(load_group)
        
        # 其他操作
        self.btn_delete = QPushButton("删除选中项")
        self.btn_delete.setStyleSheet("QPushButton { font-weight: bold; padding: 8px; }")
        right_layout.addWidget(self.btn_delete)
        
        # 进度条
        self.progress = QProgressBar()
        self.progress.setMaximumHeight(4)
        right_layout.addWidget(self.progress)
        
        # 日志（可折叠）
        self.log_toggle_btn = QPushButton("▼ 日志")
        self.log_toggle_btn.setCheckable(True)
        self.log_toggle_btn.setChecked(False)
        self.log_toggle_btn.setStyleSheet("QPushButton { text-align: left; padding: 4px; }")
        right_layout.addWidget(self.log_toggle_btn)
        
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setMaximumHeight(80)
        self.log_text.setVisible(False)  # 默认隐藏
        right_layout.addWidget(self.log_text)
        
        right_layout.addStretch()
        
        splitter.addWidget(right_panel)
        
        # 设置分割比例（左:中:右 = 1:5:1，中间最大）
        splitter.setStretchFactor(0, 1)
        splitter.setStretchFactor(1, 5)
        splitter.setStretchFactor(2, 1)
        
        # 设置初始宽度
        splitter.setSizes([150, 700, 150])
        self.splitter = splitter  # 保存引用以便保存配置
        
        main_layout.addWidget(splitter)
        
        # 状态栏
        self.status_bar = self.statusBar()
        self.status_bar.showMessage("就绪")
    
    def get_config_path(self):
        """获取配置文件路径"""
        # 配置文件保存在默认库目录下
        scripts_dir = mxs.getDir(mxs.name('scripts'))
        config_dir = os.path.join(scripts_dir, 'BulletScripts', 'Res', 'BsAnimLibrary')
        if not os.path.exists(config_dir):
            os.makedirs(config_dir, exist_ok=True)
        return os.path.join(config_dir, 'BsAnimLibConfig.json')
    
    def load_config(self):
        """加载配置"""
        config_exists = os.path.exists(self.config_file)
        
        try:
            if config_exists:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                
                # 恢复窗口大小
                if 'window_width' in config and 'window_height' in config:
                    self.resize(config['window_width'], config['window_height'])
                
                # 恢复窗口位置
                if 'window_x' in config and 'window_y' in config:
                    self.move(config['window_x'], config['window_y'])
                
                # 恢复卡片大小
                if 'card_size' in config:
                    self.card_size = config['card_size']
                    self.size_slider.setValue(self.card_size)
                
                # 恢复库路径
                if 'library_path' in config and os.path.exists(config['library_path']):
                    self.library_path = config['library_path']
                    self.current_folder_path = self.library_path  # 默认显示根目录
                    self.path_edit.setText(self.current_folder_path)
                    self.refresh_folder_tree()
                    self.load_poses_from_folder(self.current_folder_path)
                
                # 恢复分割器大小
                if 'splitter_sizes' in config:
                    self.splitter.setSizes(config['splitter_sizes'])
                
                # 恢复日志可见性
                if 'log_visible' in config:
                    is_visible = config['log_visible']
                    self.log_text.setVisible(is_visible)
                    self.log_toggle_btn.setText("▼ 日志" if is_visible else "▶ 日志")
                    self.log_toggle_btn.setChecked(is_visible)
                
                # 恢复标签筛选
                if 'filter_tags' in config:
                    self.filter_tags = config['filter_tags']
                    self.log(f"加载了 {len(self.filter_tags)} 个标签", "cyan")
                    self.refresh_tag_buttons()
                
                self.log("已加载配置", "green")
            else:
                # 配置文件不存在，立即创建默认配置
                self.log("配置文件不存在，创建默认配置", "yellow")
                self.save_config()
        except Exception as e:
            self.log(f"加载配置失败: {e}", "orange")
            # 加载失败也保存一个新的配置
            self.save_config()
    
    def save_config(self):
        """保存配置"""
        try:
            config = {
                'window_width': self.width(),
                'window_height': self.height(),
                'window_x': self.x(),
                'window_y': self.y(),
                'card_size': self.card_size,
                'library_path': self.library_path,
                'splitter_sizes': self.splitter.sizes(),
                'log_visible': self.log_text.isVisible(),
                'filter_tags': self.filter_tags  # 保存标签配置
            }
            
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2)
        except Exception as e:
            print(f"保存配置失败: {e}")
    
    def closeEvent(self, event):
        """窗口关闭事件"""
        self.save_config()
        event.accept()
    
    def resizeEvent(self, event):
        """窗口大小改变事件"""
        super().resizeEvent(event)
        # 延迟保存，避免拖动时频繁保存
        if hasattr(self, '_resize_timer'):
            self._resize_timer.stop()
        else:
            from PySide2.QtCore import QTimer
            self._resize_timer = QTimer()
            self._resize_timer.setSingleShot(True)
            self._resize_timer.timeout.connect(self.save_config)
        self._resize_timer.start(500)  # 500ms 后保存
    
    def moveEvent(self, event):
        """窗口移动事件"""
        super().moveEvent(event)
        # 延迟保存
        if hasattr(self, '_move_timer'):
            self._move_timer.stop()
        else:
            from PySide2.QtCore import QTimer
            self._move_timer = QTimer()
            self._move_timer.setSingleShot(True)
            self._move_timer.timeout.connect(self.save_config)
        self._move_timer.start(500)  # 500ms 后保存
    
    def connect_signals(self):
        """连接信号"""
        self.btn_browse.clicked.connect(self.browse_library)
        self.btn_new_folder.clicked.connect(self.new_folder)
        self.btn_save.clicked.connect(self.save_pose)
        self.btn_overwrite.clicked.connect(self.overwrite_pose_from_button)
        self.btn_load.clicked.connect(self.load_pose)
        self.btn_delete.clicked.connect(self.delete_pose)
        self.folder_tree.itemClicked.connect(self.on_folder_clicked)
        self.search_edit.textChanged.connect(self.on_search_changed)
        self.size_slider.valueChanged.connect(self.on_size_changed)
        self.log_toggle_btn.clicked.connect(self.toggle_log)
        self.splitter.splitterMoved.connect(self.on_splitter_moved)
    
    def log(self, message, color="white"):
        """添加日志"""
        self.log_text.append(f'<span style="color:{color}">{message}</span>')
    
    def toggle_log(self):
        """切换日志显示/隐藏"""
        is_visible = self.log_text.isVisible()
        self.log_text.setVisible(not is_visible)
        if is_visible:
            self.log_toggle_btn.setText("▶ 日志")
        else:
            self.log_toggle_btn.setText("▼ 日志")
        self.save_config()  # 保存配置
    
    def on_splitter_moved(self, pos, index):
        """分割器移动事件"""
        # 延迟保存
        if hasattr(self, '_splitter_timer'):
            self._splitter_timer.stop()
        else:
            from PySide2.QtCore import QTimer
            self._splitter_timer = QTimer()
            self._splitter_timer.setSingleShot(True)
            self._splitter_timer.timeout.connect(self.save_config)
        self._splitter_timer.start(500)  # 500ms 后保存
    
    def create_pose_card(self, pose_name, pose_data, file_path):
        """创建姿势卡片（带缩略图）"""
        card = QWidget()
        
        # 获取Max视口比例 (通常是16:9或4:3，这里使用常见的16:9)
        aspect_ratio = 16.0 / 9.0
        thumb_width = self.card_size
        thumb_height = int(thumb_width / aspect_ratio)
        card_height = thumb_height + 25  # 预留名称空间
        
        card.setFixedSize(thumb_width, card_height)
        card.setStyleSheet("""
            QWidget {
                background-color: palette(window);
                border: none;
            }
        """)
        layout = QVBoxLayout()
        layout.setContentsMargins(2, 2, 2, 2)
        layout.setSpacing(2)
        
        # 缩略图 - 无边框
        thumbnail_label = QLabel()
        thumbnail_label.setFixedSize(thumb_width - 4, thumb_height - 4)
        thumbnail_label.setAlignment(Qt.AlignCenter)
        thumbnail_label.setStyleSheet("QLabel { background-color: palette(base); }")
        
        # 尝试加载缩略图
        if "thumbnail" in pose_data and pose_data["thumbnail"]:
            try:
                image_data = base64.b64decode(pose_data["thumbnail"])
                image = QImage()
                image.loadFromData(image_data)
                pixmap = QPixmap.fromImage(image)
                # 保持宽高比缩放
                scaled_pixmap = pixmap.scaled(thumb_width - 4, thumb_height - 4, 
                                              Qt.KeepAspectRatio, Qt.SmoothTransformation)
                thumbnail_label.setPixmap(scaled_pixmap)
            except:
                thumbnail_label.setText("无预览")
                thumbnail_label.setStyleSheet("QLabel { background-color: palette(base); color: palette(window-text); }")
        else:
            thumbnail_label.setText("无预览")
            thumbnail_label.setStyleSheet("QLabel { background-color: palette(base); color: palette(window-text); }")
        
        layout.addWidget(thumbnail_label)
        
        # 名称标签 - 精简样式
        name_label = QLabel(pose_name)
        name_label.setAlignment(Qt.AlignCenter)
        name_label.setWordWrap(False)
        name_label.setStyleSheet("QLabel { color: palette(window-text); font-size: 10px; }")
        # 使用省略号截断过长的名称
        name_label.setMaximumWidth(thumb_width - 4)
        font_metrics = name_label.fontMetrics()
        elided_text = font_metrics.elidedText(pose_name, Qt.ElideRight, thumb_width - 4)
        name_label.setText(elided_text)
        name_label.setToolTip(pose_name)  # 完整名称作为提示
        layout.addWidget(name_label)
        
        card.setLayout(layout)
        
        # 添加点击事件
        def on_mouse_press(event):
            if event.button() == Qt.LeftButton:
                # 支持 Ctrl 和 Shift 多选
                modifiers = event.modifiers()
                self.on_pose_card_clicked(pose_name, card, modifiers)
            elif event.button() == Qt.RightButton:
                # 使用新API: globalPosition() 代替 globalPos()
                pos = event.globalPos()
                self.show_pose_context_menu(pose_name, pos)
        
        card.mousePressEvent = on_mouse_press
        card.mouseDoubleClickEvent = lambda event: self.on_pose_card_double_clicked(pose_name)
        
        return card
    
    def on_pose_card_clicked(self, pose_name, card, modifiers=None):
        """姿势卡片单击事件（支持多选）"""
        if modifiers is None:
            modifiers = QtCore.Qt.NoModifier
        
        # Ctrl 多选
        if modifiers & QtCore.Qt.ControlModifier:
            if pose_name in self.selected_poses:
                # 取消选择
                self.selected_poses.remove(pose_name)
                self.selected_cards.remove(card)
                card.setStyleSheet("""
                    QWidget {
                        background-color: palette(window);
                        border: none;
                    }
                """)
            else:
                # 添加到选择
                self.selected_poses.append(pose_name)
                self.selected_cards.append(card)
                card.setStyleSheet("""
                    QWidget {
                        background-color: palette(window);
                        border: 2px solid palette(highlight);
                    }
                """)
        else:
            # 单选：清除之前的所有选择
            for selected_card in self.selected_cards:
                try:
                    selected_card.setStyleSheet("""
                        QWidget {
                            background-color: palette(window);
                            border: none;
                        }
                    """)
                except:
                    pass
            
            self.selected_poses = [pose_name]
            self.selected_cards = [card]
            
            # 高亮当前选中
            card.setStyleSheet("""
                QWidget {
                    background-color: palette(window);
                    border: 2px solid palette(highlight);
                }
            """)
        
        # 更新当前选中（用于单个加载）
        if self.selected_poses:
            self.current_selected_pose = self.selected_poses[0]
        else:
            self.current_selected_pose = None
        
        # 更新详情显示
        self.update_detail_panel()
        
        if len(self.selected_poses) > 1:
            self.log(f"已选中 {len(self.selected_poses)} 个姿势", "blue")
        elif self.selected_poses:
            self.log(f"选中: {pose_name}", "blue")
    
    def update_detail_panel(self):
        """更新右侧详情面板"""
        if not self.selected_poses:
            # 清空详情
            self.detail_name_label.setText("名称: -")
            self.detail_tags_label.setText("-")
            self.detail_desc_label.setText("(无)")
            return
        
        if len(self.selected_poses) == 1:
            # 单选：显示详细信息
            pose_name = self.selected_poses[0]
            if pose_name in self.global_data:
                pose_data = self.global_data[pose_name]
                
                # 显示名称
                self.detail_name_label.setText(f"名称: {pose_name}")
                
                # 显示标签
                tags = pose_data.get("tags", "")
                if tags:
                    self.detail_tags_label.setText(tags)
                else:
                    self.detail_tags_label.setText("(无)")
                
                # 显示描述
                desc = pose_data.get("description", "")
                if desc:
                    self.detail_desc_label.setText(desc)
                else:
                    self.detail_desc_label.setText("(无)")
        else:
            # 多选：显示所有选中项的标签合集
            self.detail_name_label.setText(f"已选中 {len(self.selected_poses)} 项")
            
            # 收集所有标签
            all_tags = set()
            for pose_name in self.selected_poses:
                if pose_name in self.global_data:
                    tags = self.global_data[pose_name].get("tags", "")
                    if tags:
                        for tag in tags.split(','):
                            all_tags.add(tag.strip())
            
            if all_tags:
                self.detail_tags_label.setText(", ".join(sorted(all_tags)))
            else:
                self.detail_tags_label.setText("(无)")
            
            self.detail_desc_label.setText(f"多选模式 ({len(self.selected_poses)} 项)")
    
    def on_pose_card_double_clicked(self, pose_name):
        """姿势卡片双击事件 - 直接加载"""
        self.current_selected_pose = pose_name
        self.load_pose()
    
    def show_pose_context_menu(self, pose_name, pos):
        """显示姿势右键菜单"""
        menu = QMenu(self)
        
        load_action = menu.addAction("加载")
        load_action.triggered.connect(lambda: self.load_pose_by_name(pose_name))
        
        menu.addSeparator()
        
        overwrite_action = menu.addAction("覆盖")
        overwrite_action.triggered.connect(lambda: self.overwrite_pose(pose_name))
        
        edit_action = menu.addAction("编辑标签...")
        edit_action.triggered.connect(lambda: self.edit_pose_tags(pose_name))
        
        update_thumb_action = menu.addAction("更新缩略图")
        update_thumb_action.triggered.connect(lambda: self.update_pose_thumbnail(pose_name))
        
        menu.addSeparator()
        
        delete_action = menu.addAction("删除")
        delete_action.triggered.connect(lambda: self.delete_pose_by_name(pose_name))
        
        menu.exec_(pos)
    
    def edit_pose_tags(self, pose_name):
        """编辑姿势标签和描述"""
        if pose_name not in self.global_data:
            return
        
        pose_data = self.global_data[pose_name]
        current_tags = pose_data.get("tags", "")
        current_desc = pose_data.get("description", "")
        
        # 简单对话框输入
        new_tags, ok1 = QtWidgets.QInputDialog.getText(self, "编辑标签", 
                                                        "标签 (用逗号分隔):", 
                                                        text=current_tags)
        if ok1:
            new_desc, ok2 = QtWidgets.QInputDialog.getText(self, "编辑描述", 
                                                           "描述:", 
                                                           text=current_desc)
            if ok2:
                # 更新数据
                pose_data["tags"] = new_tags
                pose_data["description"] = new_desc
                
                # 保存到文件
                file_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
                try:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(pose_data, f, indent=2, ensure_ascii=False)
                    self.log(f"已更新标签: {pose_name}", "green")
                except Exception as e:
                    self.log(f"保存失败: {e}", "red")
    
    def update_pose_thumbnail(self, pose_name):
        """更新姿势缩略图"""
        if pose_name not in self.global_data:
            return
        
        # 捕获当前视口缩略图
        self.log("正在更新缩略图...", "yellow")
        thumbnail = self.capture_viewport_thumbnail()
        
        if thumbnail:
            # 更新数据
            pose_data = self.global_data[pose_name]
            pose_data["thumbnail"] = thumbnail
            
            # 保存到文件
            file_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(pose_data, f, indent=2, ensure_ascii=False)
                
                # 刷新显示
                self.refresh_pose_display()
                self.log(f"已更新缩略图: {pose_name}", "green")
                
                try:
                    self.status_bar.showMessage(f"已更新缩略图: {pose_name}")
                except:
                    pass
            except Exception as e:
                self.log(f"保存失败: {e}", "red")
                QMessageBox.warning(self, "错误", f"保存失败: {e}")
        else:
            self.log("缩略图捕获失败", "red")
            QMessageBox.warning(self, "错误", "缩略图捕获失败，请确保视口中有内容")
    
    def overwrite_pose(self, pose_name):
        """覆盖现有姿势（右键菜单）"""
        if pose_name not in self.global_data:
            return
        
        # 弹出确认对话框
        reply = QMessageBox.question(
            self, "确认覆盖", 
            f"确定要用当前对象覆盖姿势 '{pose_name}' 吗？\n此操作不可恢复！",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            # 根据"仅选中"复选框决定覆盖使用哪些对象
            if self.chk_save_selected_only.isChecked():
                # 仅使用选中的对象
                nodes = list(mxs.selection)
                if not nodes:
                    QMessageBox.warning(self, "警告", "请先选择对象")
                    return
            else:
                # 使用所有对象
                nodes = list(mxs.objects)
                if not nodes:
                    QMessageBox.warning(self, "警告", "场景中没有对象")
                    return
            
            mxs.escapeEnable = False
            
            try:
                # 保留原有的标签和描述
                old_pose_data = self.global_data[pose_name]
                old_tags = old_pose_data.get("tags", "")
                old_desc = old_pose_data.get("description", "")
                
                # 收集新的节点数据
                pose_data = {
                    "ID": [],
                    "name": [],
                    "parent_ID": [],
                    "children_IDs": [],
                    "color": [],
                    "parent_transform": []
                }
                
                # 生成 UUID
                for node in nodes:
                    node_id = mxs.getAppData(node, 10)
                    if node_id is None:
                        node_id = str(uuid.uuid1())
                        mxs.setAppData(node, 10, node_id)
                    else:
                        node_id = str(node_id)
                    pose_data["ID"].append(node_id)
                    pose_data["name"].append(str(node.name))
                    pose_data["color"].append(str(node.wirecolor))
                    
                    # 父节点
                    if mxs.isValidNode(node.parent):
                        parent_id = mxs.getAppData(node.parent, 10)
                        if parent_id is None:
                            parent_id = str(uuid.uuid1())
                            mxs.setAppData(node.parent, 10, parent_id)
                        else:
                            parent_id = str(parent_id)
                        pose_data["parent_ID"].append(parent_id)
                        pose_data["parent_transform"].append(str(node.parent.transform))
                    else:
                        pose_data["parent_ID"].append(None)
                        pose_data["parent_transform"].append(None)
                    
                    # 子节点
                    if node.children.count == 0:
                        pose_data["children_IDs"].append(None)
                    else:
                        children_ids = []
                        for j in range(node.children.count):
                            child = node.children[j]
                            child_id = mxs.getAppData(child, 10)
                            if child_id is None:
                                child_id = str(uuid.uuid1())
                                mxs.setAppData(child, 10, child_id)
                            else:
                                child_id = str(child_id)
                            children_ids.append(child_id)
                        pose_data["children_IDs"].append(children_ids)
                
                # 保存变换（默认保存全局和局部）
                pose_data["global_transform"] = []
                for node in nodes:
                    pose_data["global_transform"].append(str(node.transform))
                
                pose_data["local_transform"] = []
                for node in nodes:
                    if mxs.isValidNode(node.parent):
                        offset = mxs.inverse(node.parent.transform * mxs.inverse(node.transform))
                        pose_data["local_transform"].append(str(offset))
                    else:
                        pose_data["local_transform"].append(None)
                
                # 恢复标签和描述
                pose_data["tags"] = old_tags
                pose_data["description"] = old_desc
                
                # 捕获新缩略图
                self.log("正在捕获视口缩略图...", "yellow")
                thumbnail = self.capture_viewport_thumbnail()
                if thumbnail:
                    pose_data["thumbnail"] = thumbnail
                else:
                    pose_data["thumbnail"] = ""
                
                # 保存到文件
                save_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
                with open(save_path, 'w', encoding='utf-8') as f:
                    json.dump(pose_data, f, indent=2, ensure_ascii=False)
                
                # 更新显示
                self.global_data[pose_name] = pose_data
                self.refresh_pose_display()
                
                self.log(f"已覆盖姿势: {pose_name}", "green")
                try:
                    self.status_bar.showMessage(f"已覆盖: {pose_name}")
                except:
                    pass
                
            except Exception as e:
                self.log(f"覆盖失败: {str(e)}", "red")
                QMessageBox.critical(self, "错误", f"覆盖失败: {str(e)}")
            finally:
                mxs.escapeEnable = True
    
    def load_pose_by_name(self, pose_name):
        """通过名称加载姿势"""
        self.current_selected_pose = pose_name
        self.load_pose()
    
    def delete_pose_by_name(self, pose_name):
        """通过名称删除姿势"""
        self.current_selected_pose = pose_name
        self.delete_pose()
    
    def capture_viewport_thumbnail(self, target_width=400):
        """捕获视口缩略图（保持Max视口原始比例）"""
        try:
            # 使用3ds Max的视口捕获功能
            temp_path = os.path.join(mxs.getDir(mxs.name('temp')), "thumbnail_temp.jpg")
            
            # 捕获当前活动视口
            bmp = mxs.gw.getViewportDib()
            bmp.filename = temp_path
            mxs.save(bmp, temp_path)
            
            # 加载并调整大小
            if os.path.exists(temp_path):
                image = QImage(temp_path)
                if not image.isNull():
                    # 获取原始尺寸和比例
                    original_width = image.width()
                    original_height = image.height()
                    aspect_ratio = original_width / float(original_height)
                    
                    # 根据目标宽度计算高度，保持原始比例
                    target_height = int(target_width / aspect_ratio)
                    
                    scaled_image = image.scaled(target_width, target_height, 
                                               Qt.KeepAspectRatio, Qt.SmoothTransformation)
                    
                    # 使用 QBuffer 转换为 base64
                    byte_array = QtCore.QByteArray()
                    buffer = QBuffer(byte_array)
                    buffer.open(QIODevice.WriteOnly)
                    scaled_image.save(buffer, "JPEG", 85)  # 85% 质量
                    buffer.close()
                    
                    thumbnail_base64 = base64.b64encode(byte_array.data()).decode()
                    
                    # 清理临时文件
                    try:
                        os.remove(temp_path)
                    except:
                        pass
                    
                    return thumbnail_base64
        except Exception as e:
            print(f"捕获缩略图失败: {e}")
            import traceback
            traceback.print_exc()
        
        return None
    
    def load_default_library(self):
        """加载默认库"""
        # 获取 Max Scripts 目录
        scripts_dir = mxs.getDir(mxs.name('scripts'))
        default_path = os.path.join(scripts_dir, 'BulletScripts', 'Res', 'BsAnimLibrary')
        
        if not os.path.exists(default_path):
            os.makedirs(default_path, exist_ok=True)
        
        self.library_path = default_path
        self.current_folder_path = default_path
        self.path_edit.setText(default_path)
        self.refresh_folder_tree()
        self.load_poses_from_folder(default_path)
        self.log("加载默认库")
    
    def browse_library(self):
        """重设库目录"""
        path = QFileDialog.getExistingDirectory(self, "选择新的库目录")
        if path:
            self.library_path = path
            self.current_folder_path = path
            self.path_edit.setText(path)
            self.refresh_folder_tree()
            self.load_poses_from_folder(path)
            self.save_config()  # 保存配置
            self.log(f"加载库: {path}")
    
    def show_folder_context_menu(self, position):
        """显示文件夹右键菜单"""
        item = self.folder_tree.itemAt(position)
        if not item:
            return
        
        folder_path = item.data(0, Qt.UserRole)
        if not folder_path:
            return
        
        menu = QMenu(self)
        
        new_action = menu.addAction("新建文件夹")
        rename_action = menu.addAction("重命名")
        delete_action = menu.addAction("删除")
        
        action = menu.exec_(self.folder_tree.viewport().mapToGlobal(position))
        
        if action == new_action:
            self.create_subfolder(folder_path)
        elif action == rename_action:
            self.rename_folder(item, folder_path)
        elif action == delete_action:
            self.delete_folder(item, folder_path)
    
    def create_subfolder(self, parent_path):
        """在指定路径下创建子文件夹"""
        folder_name, ok = QtWidgets.QInputDialog.getText(self, "新建文件夹", "文件夹名称:")
        if ok and folder_name:
            new_path = os.path.join(parent_path, folder_name)
            try:
                os.makedirs(new_path, exist_ok=True)
                self.refresh_folder_tree()
                self.log(f"创建文件夹: {folder_name}", "green")
            except Exception as e:
                QMessageBox.warning(self, "错误", f"创建文件夹失败: {e}")
                self.log(f"创建文件夹失败: {e}", "red")
    
    def rename_folder(self, item, folder_path):
        """重命名文件夹"""
        old_name = os.path.basename(folder_path)
        new_name, ok = QtWidgets.QInputDialog.getText(self, "重命名文件夹", "新名称:", text=old_name)
        
        if ok and new_name and new_name != old_name:
            parent_path = os.path.dirname(folder_path)
            new_path = os.path.join(parent_path, new_name)
            
            try:
                os.rename(folder_path, new_path)
                self.refresh_folder_tree()
                self.log(f"重命名文件夹: {old_name} -> {new_name}", "green")
                
                # 如果重命名的是当前选中的文件夹，更新路径
                if self.current_folder_path == folder_path:
                    self.current_folder_path = new_path
                    self.path_edit.setText(new_path)
                    self.save_config()
            except Exception as e:
                QMessageBox.warning(self, "错误", f"重命名失败: {e}")
                self.log(f"重命名失败: {e}", "red")
    
    def delete_folder(self, item, folder_path):
        """删除文件夹"""
        folder_name = os.path.basename(folder_path)
        
        # 弹出确认对话框
        reply = QMessageBox.question(
            self, "确认删除", 
            f"确定要删除文件夹 '{folder_name}' 及其所有内容吗？\n此操作不可恢复！",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            try:
                shutil.rmtree(folder_path)
                self.refresh_folder_tree()
                self.log(f"已删除文件夹: {folder_name}", "green")
                
                # 如果删除的是当前文件夹，清空显示
                if self.current_folder_path == folder_path or self.current_folder_path.startswith(folder_path + os.sep):
                    self.current_folder_path = os.path.dirname(folder_path)
                    self.path_edit.setText(self.current_folder_path)
                    self.load_poses_from_folder(self.current_folder_path)
                    self.save_config()
            except Exception as e:
                QMessageBox.warning(self, "错误", f"删除文件夹失败: {e}")
                self.log(f"删除失败: {e}", "red")
    
    def new_folder(self):
        """新建文件夹（从工具栏按钮调用）"""
        if not self.current_folder_path:
            QMessageBox.warning(self, "警告", "请先选择一个库")
            return
        
        self.create_subfolder(self.current_folder_path)
    
    def refresh_folder_tree(self):
        """刷新文件夹树"""
        self.folder_tree.clear()
        if not self.library_path:
            return
        
        # 始终显示库的根目录
        root_item = QTreeWidgetItem(self.folder_tree)
        root_item.setText(0, os.path.basename(self.library_path) or self.library_path)
        root_item.setData(0, Qt.UserRole, self.library_path)
        root_item.setExpanded(True)
        self._add_folder_items(root_item, self.library_path)
    
    def _add_folder_items(self, parent_item, path):
        """递归添加文件夹"""
        try:
            for item in os.listdir(path):
                item_path = os.path.join(path, item)
                if os.path.isdir(item_path):
                    folder_item = QTreeWidgetItem(parent_item)
                    folder_item.setText(0, item)
                    folder_item.setData(0, Qt.UserRole, item_path)
                    self._add_folder_items(folder_item, item_path)
        except:
            pass
    
    def on_folder_clicked(self, item, column):
        """文件夹点击事件"""
        folder_path = item.data(0, Qt.UserRole)
        if folder_path:
            self.current_folder_path = folder_path
            self.path_edit.setText(folder_path)
            self.load_poses_from_folder(folder_path)
            # 注意：点击子文件夹不改变库路径配置，只改变当前显示
    
    def load_poses_from_folder(self, folder_path):
        """从文件夹加载姿势列表（带缩略图）"""
        # 清空现有网格
        for i in reversed(range(self.grid_layout.count())):
            widget = self.grid_layout.itemAt(i).widget()
            if widget:
                widget.deleteLater()
        
        self.global_data = {}
        
        if not os.path.exists(folder_path):
            return
        
        # 加载该文件夹下的所有 json 文件（排除配置文件）
        for file in os.listdir(folder_path):
            if file.endswith('.json') and file.lower() not in ['config.json', 'bsanimlibconfig.json']:
                file_path = os.path.join(folder_path, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    pose_name = os.path.splitext(file)[0]
                    self.global_data[pose_name] = data
                except:
                    pass
        
        # 刷新显示
        self.refresh_pose_display()
        
        try:
            self.status_bar.showMessage(f"已加载 {len(self.global_data)} 个姿势")
        except:
            pass
    
    def get_contrast_color(self, hex_color):
        """根据背景颜色返回对比色（黑色或白色）"""
        # 移除 # 号
        hex_color = hex_color.lstrip('#')
        
        # 转换为 RGB
        r = int(hex_color[0:2], 16)
        g = int(hex_color[2:4], 16)
        b = int(hex_color[4:6], 16)
        
        # 计算相对亮度 (使用 YIQ 公式)
        luminance = (0.299 * r + 0.587 * g + 0.114 * b)
        
        # 如果亮度高（浅色背景）返回黑色，否则返回白色
        return 'black' if luminance > 128 else 'white'
    
    def refresh_tag_buttons(self):
        """刷新标签按钮显示"""
        # 清空所有现有按钮
        while self.tag_buttons_layout.count() > 0:
            item = self.tag_buttons_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()
        
        # 创建标签按钮
        for tag in self.filter_tags:
            btn = QPushButton(tag["name"])
            btn.setFixedHeight(26)  # 与+按钮一致
            
            # 根据背景颜色自动选择文字颜色
            text_color = self.get_contrast_color(tag["color"])
            
            btn.setStyleSheet(f"""
                QPushButton {{
                    background-color: {tag["color"]};
                    color: {text_color};
                    border: 2px solid transparent;
                    border-radius: 3px;
                    padding: 2px 12px;
                    font-weight: bold;
                    font-size: 11px;
                }}
                QPushButton:hover {{
                    border: 2px solid palette(highlight);
                }}
                QPushButton:checked {{
                    border: 3px solid {text_color};
                    padding: 1px 11px;
                }}
            """)
            btn.setCheckable(True)
            btn.setChecked(self.active_filter_tag == tag["name"])
            
            # 使用闭包函数正确捕获循环变量
            def make_click_handler(name):
                return lambda checked: self.on_tag_button_clicked(name, checked)
            
            def make_context_handler(name, button):
                return lambda pos: self.show_tag_context_menu(name, button.mapToGlobal(pos))
            
            btn.clicked.connect(make_click_handler(tag["name"]))
            btn.setContextMenuPolicy(Qt.CustomContextMenu)
            btn.customContextMenuRequested.connect(make_context_handler(tag["name"], btn))
            # 直接添加到布局
            self.tag_buttons_layout.addWidget(btn)
        
        # 直接使用HBoxLayout，不需要计算宽度
    
    def toggle_tag_area(self):
        """切换标签区域展开/收起"""
        self.tag_expanded = not self.tag_expanded
        
        if self.tag_expanded:
            # 展开到2行
            self.tag_scroll_area.setMinimumHeight(60)
            self.tag_scroll_area.setMaximumHeight(60)
            self.btn_expand_tags.setText("▲")
            self.tag_container.setMaximumHeight(64)
        else:
            # 收起到1行
            self.tag_scroll_area.setMinimumHeight(30)
            self.tag_scroll_area.setMaximumHeight(30)
            self.btn_expand_tags.setText("▼")
            self.tag_container.setMaximumHeight(32)
    
    def add_new_tag(self):
        """添加新标签"""
        name, ok = QInputDialog.getText(self, "添加标签", "标签名称:")
        if ok and name.strip():
            name = name.strip()
            # 检查是否已存在
            if any(tag["name"] == name for tag in self.filter_tags):
                QMessageBox.warning(self, "警告", f"标签 '{name}' 已存在")
                return
            
            # 选择颜色
            color = QColorDialog.getColor(QColor("#3498db"), self, "选择标签颜色")
            if color.isValid():
                self.filter_tags.append({"name": name, "color": color.name()})
                self.refresh_tag_buttons()
                self.save_config()
                self.log(f"已添加标签: {name}")
    
    def on_tag_button_clicked(self, tag_name, checked):
        """标签按钮点击"""
        if checked:
            # 激活筛选
            self.active_filter_tag = tag_name
            # 取消其他标签的选中状态
            for i in range(self.tag_buttons_layout.count()):
                btn = self.tag_buttons_layout.itemAt(i).widget()
                if btn and btn.text() != tag_name:
                    btn.setChecked(False)
            # 显示筛选横幅
            self.filter_banner.setText(f"🔍 正在筛选: {tag_name}  (点击此处取消)")
            self.filter_banner.setVisible(True)
        else:
            # 取消筛选
            self.active_filter_tag = None
            # 隐藏筛选横幅
            self.filter_banner.setVisible(False)
        
        self.refresh_pose_display()
        self.log(f"筛选标签: {tag_name if checked else '全部'}")
    
    def clear_filter(self):
        """清除筛选（点击横幅时调用）"""
        self.active_filter_tag = None
        self.filter_banner.setVisible(False)
        
        # 取消所有标签按钮的选中状态
        for i in range(self.tag_buttons_layout.count()):
            btn = self.tag_buttons_layout.itemAt(i).widget()
            if btn:
                btn.setChecked(False)
        
        self.refresh_pose_display()
        self.log("已取消筛选")
    
    def show_tag_context_menu(self, tag_name, pos):
        """显示标签右键菜单"""
        menu = QMenu(self)
        
        edit_color_action = menu.addAction("修改颜色")
        edit_color_action.triggered.connect(lambda: self.edit_tag_color(tag_name))
        
        delete_action = menu.addAction("删除标签")
        delete_action.triggered.connect(lambda: self.delete_tag(tag_name))
        
        menu.exec_(pos)
    
    def edit_tag_color(self, tag_name):
        """编辑标签颜色"""
        # 找到标签
        tag = next((t for t in self.filter_tags if t["name"] == tag_name), None)
        if not tag:
            return
        
        # 选择新颜色
        current_color = QColor(tag["color"])
        color = QColorDialog.getColor(current_color, self, f"修改 '{tag_name}' 的颜色")
        if color.isValid():
            tag["color"] = color.name()
            self.refresh_tag_buttons()
            self.save_config()
            self.log(f"已修改标签颜色: {tag_name}")
    
    def delete_tag(self, tag_name):
        """删除标签"""
        reply = QMessageBox.question(
            self, "确认删除",
            f"确定要删除标签 '{tag_name}' 吗？",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            self.filter_tags = [t for t in self.filter_tags if t["name"] != tag_name]
            if self.active_filter_tag == tag_name:
                self.active_filter_tag = None
            self.refresh_tag_buttons()
            self.refresh_pose_display()
            self.save_config()
            self.log(f"已删除标签: {tag_name}")
    
    def refresh_pose_display(self):
        """刷新姿势显示"""
        # 清空网格
        for i in reversed(range(self.grid_layout.count())):
            widget = self.grid_layout.itemAt(i).widget()
            if widget:
                widget.deleteLater()
        
        # 获取搜索关键词
        search_text = self.search_edit.text().lower().strip()
        
        # 过滤和显示
        row = 0
        col = 0
        # 根据卡片大小动态计算每行数量
        max_cols = max(1, int(self.scroll_area.width() / (self.card_size + 20)))
        
        for pose_name, pose_data in self.global_data.items():
            # 标签筛选
            if self.active_filter_tag:
                pose_tags = pose_data.get("tags", "").lower()
                # 将pose的标签字符串分割成列表
                pose_tag_list = [t.strip() for t in pose_tags.split(',') if t.strip()]
                # 检查激活的筛选标签是否在pose的标签列表中
                if self.active_filter_tag.lower() not in pose_tag_list:
                    continue
            
            # 搜索过滤
            if search_text:
                tags = pose_data.get("tags", "").lower()
                desc = pose_data.get("description", "").lower()
                if search_text not in pose_name.lower() and search_text not in tags and search_text not in desc:
                    continue
            
            # 创建卡片
            file_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
            card = self.create_pose_card(pose_name, pose_data, file_path)
            self.grid_layout.addWidget(card, row, col)
            
            col += 1
            if col >= max_cols:
                col = 0
                row += 1
    
    def on_search_changed(self, text):
        """搜索文本改变"""
        self.refresh_pose_display()
    
    def on_size_changed(self, value):
        """卡片大小改变"""
        self.card_size = value
        self.refresh_pose_display()
        self.save_config()  # 保存配置
    
    def save_pose(self):
        """保存姿势（使用 Posture 的逻辑）"""
        pose_name = self.save_name_edit.text().strip()
        if not pose_name:
            QMessageBox.warning(self, "警告", "请输入姿势名称")
            return
        
        # 检查是否已存在同名pose
        save_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
        if os.path.exists(save_path):
            reply = QMessageBox.question(
                self, "确认覆盖", 
                f"姿势 '{pose_name}' 已存在，是否覆盖？",
                QMessageBox.Yes | QMessageBox.No,
                QMessageBox.No
            )
            if reply == QMessageBox.No:
                return  # 用户选择不覆盖，直接返回
        
        # 根据"仅选中"复选框决定保存哪些对象
        if self.chk_save_selected_only.isChecked():
            # 仅保存选中的对象
            nodes = list(mxs.selection)
            if not nodes:
                QMessageBox.warning(self, "警告", "请先选择对象")
                return
        else:
            # 保存所有对象
            nodes = list(mxs.objects)
            if not nodes:
                QMessageBox.warning(self, "警告", "场景中没有对象")
                return
        
        mxs.escapeEnable = False
        
        try:
            # 收集节点数据
            pose_data = {
                "ID": [],
                "name": [],
                "parent_ID": [],
                "children_IDs": [],
                "color": [],
                "parent_transform": []
            }
            
            # 生成 UUID
            for node in nodes:
                node_id = mxs.getAppData(node, 10)
                if node_id is None:
                    node_id = str(uuid.uuid1())
                    mxs.setAppData(node, 10, node_id)
                else:
                    node_id = str(node_id)
                pose_data["ID"].append(node_id)
                pose_data["name"].append(str(node.name))
                pose_data["color"].append(str(node.wirecolor))
                
                # 父节点
                if mxs.isValidNode(node.parent):
                    parent_id = mxs.getAppData(node.parent, 10)
                    if parent_id is None:
                        parent_id = str(uuid.uuid1())
                        mxs.setAppData(node.parent, 10, parent_id)
                    else:
                        parent_id = str(parent_id)
                    pose_data["parent_ID"].append(parent_id)
                    pose_data["parent_transform"].append(str(node.parent.transform))
                else:
                    pose_data["parent_ID"].append(None)
                    pose_data["parent_transform"].append(None)
                
                # 子节点
                if node.children.count == 0:
                    pose_data["children_IDs"].append(None)
                else:
                    children_ids = []
                    for j in range(node.children.count):
                        child = node.children[j]
                        child_id = mxs.getAppData(child, 10)
                        if child_id is None:
                            child_id = str(uuid.uuid1())
                            mxs.setAppData(child, 10, child_id)
                        else:
                            child_id = str(child_id)
                        children_ids.append(child_id)
                    pose_data["children_IDs"].append(children_ids)
            
            # 保存变换
            if self.save_rb_global.isChecked():
                pose_data["global_transform"] = []
                for node in nodes:
                    pose_data["global_transform"].append(str(node.transform))
            
            if self.save_rb_local.isChecked():
                pose_data["local_transform"] = []
                for node in nodes:
                    if mxs.isValidNode(node.parent):
                        offset = mxs.inverse(node.parent.transform * mxs.inverse(node.transform))
                        pose_data["local_transform"].append(str(offset))
                    else:
                        pose_data["local_transform"].append(None)
            
            # 添加标签和描述（可选）
            tags = self.save_tags_edit.text().strip()
            desc = self.save_desc_edit.text().strip()
            if tags:  # 只有在有内容时才保存
                pose_data["tags"] = tags
            else:
                pose_data["tags"] = ""
            
            if desc:  # 只有在有内容时才保存
                pose_data["description"] = desc
            else:
                pose_data["description"] = ""
            
            # 捕获缩略图
            self.log("正在捕获视口缩略图...", "yellow")
            thumbnail = self.capture_viewport_thumbnail()
            if thumbnail:
                pose_data["thumbnail"] = thumbnail
                self.log("缩略图已捕获", "green")
            else:
                pose_data["thumbnail"] = ""
                self.log("缩略图捕获失败，将保存为无预览", "orange")
            
            # 保存到文件
            save_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
            with open(save_path, 'w', encoding='utf-8') as f:
                json.dump(pose_data, f, indent=2, ensure_ascii=False)
            
            # 更新显示
            self.global_data[pose_name] = pose_data
            self.refresh_pose_display()
            
            self.save_name_edit.clear()
            self.save_tags_edit.clear()
            self.save_desc_edit.clear()
            self.log(f"保存姿势: {pose_name}", "green")
            try:
                self.status_bar.showMessage(f"已保存: {pose_name}")
            except:
                pass
            
        except Exception as e:
            self.log(f"保存失败: {str(e)}", "red")
            QMessageBox.critical(self, "错误", f"保存失败: {str(e)}")
        finally:
            mxs.escapeEnable = True
    
    def overwrite_pose_from_button(self):
        """从按钮覆盖姿势（需要先选中一个pose）"""
        # 检查是否选中了pose
        if not hasattr(self, 'current_selected_pose') or not self.current_selected_pose:
            QMessageBox.warning(self, "警告", "请先在下方选择要覆盖的姿势")
            return
        
        pose_name = self.current_selected_pose
        if pose_name not in self.global_data:
            QMessageBox.warning(self, "警告", "姿势数据不存在")
            return
        
        # 弹出确认对话框
        reply = QMessageBox.question(
            self, "确认覆盖", 
            f"确定要用当前对象覆盖姿势 '{pose_name}' 吗？\n此操作不可恢复！",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            # 根据"仅选中"复选框决定覆盖使用哪些对象
            if self.chk_save_selected_only.isChecked():
                # 仅使用选中的对象
                nodes = list(mxs.selection)
                if not nodes:
                    QMessageBox.warning(self, "警告", "请先选择对象")
                    return
            else:
                # 使用所有对象
                nodes = list(mxs.objects)
                if not nodes:
                    QMessageBox.warning(self, "警告", "场景中没有对象")
                    return
            
            mxs.escapeEnable = False
            
            try:
                # 保留原有的标签和描述
                old_pose_data = self.global_data[pose_name]
                old_tags = old_pose_data.get("tags", "")
                old_desc = old_pose_data.get("description", "")
                
                # 收集新的节点数据
                pose_data = {
                    "ID": [],
                    "name": [],
                    "parent_ID": [],
                    "children_IDs": [],
                    "color": [],
                    "parent_transform": []
                }
                
                # 生成 UUID
                for node in nodes:
                    node_id = mxs.getAppData(node, 10)
                    if node_id is None:
                        node_id = str(uuid.uuid1())
                        mxs.setAppData(node, 10, node_id)
                    else:
                        node_id = str(node_id)
                    pose_data["ID"].append(node_id)
                    pose_data["name"].append(str(node.name))
                    pose_data["color"].append(str(node.wirecolor))
                    
                    # 父节点
                    if mxs.isValidNode(node.parent):
                        parent_id = mxs.getAppData(node.parent, 10)
                        if parent_id is None:
                            parent_id = str(uuid.uuid1())
                            mxs.setAppData(node.parent, 10, parent_id)
                        else:
                            parent_id = str(parent_id)
                        pose_data["parent_ID"].append(parent_id)
                        pose_data["parent_transform"].append(str(node.parent.transform))
                    else:
                        pose_data["parent_ID"].append(None)
                        pose_data["parent_transform"].append(None)
                    
                    # 子节点
                    if node.children.count == 0:
                        pose_data["children_IDs"].append(None)
                    else:
                        children_ids = []
                        for j in range(node.children.count):
                            child = node.children[j]
                            child_id = mxs.getAppData(child, 10)
                            if child_id is None:
                                child_id = str(uuid.uuid1())
                                mxs.setAppData(child, 10, child_id)
                            else:
                                child_id = str(child_id)
                            children_ids.append(child_id)
                        pose_data["children_IDs"].append(children_ids)
                
                # 保存变换（默认保存全局和局部）
                pose_data["global_transform"] = []
                for node in nodes:
                    pose_data["global_transform"].append(str(node.transform))
                
                pose_data["local_transform"] = []
                for node in nodes:
                    if mxs.isValidNode(node.parent):
                        offset = mxs.inverse(node.parent.transform * mxs.inverse(node.transform))
                        pose_data["local_transform"].append(str(offset))
                    else:
                        pose_data["local_transform"].append(None)
                
                # 恢复标签和描述
                pose_data["tags"] = old_tags
                pose_data["description"] = old_desc
                
                # 捕获新缩略图
                self.log("正在捕获视口缩略图...", "yellow")
                thumbnail = self.capture_viewport_thumbnail()
                if thumbnail:
                    pose_data["thumbnail"] = thumbnail
                else:
                    pose_data["thumbnail"] = ""
                
                # 保存到文件
                save_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
                with open(save_path, 'w', encoding='utf-8') as f:
                    json.dump(pose_data, f, indent=2, ensure_ascii=False)
                
                # 更新显示
                self.global_data[pose_name] = pose_data
                self.refresh_pose_display()
                
                self.log(f"已覆盖姿势: {pose_name}", "green")
                try:
                    self.status_bar.showMessage(f"已覆盖: {pose_name}")
                except:
                    pass
                
            except Exception as e:
                self.log(f"覆盖失败: {str(e)}", "red")
                QMessageBox.critical(self, "错误", f"覆盖失败: {str(e)}")
            finally:
                mxs.escapeEnable = True
    
    def load_pose(self):
        """加载姿势（使用 Posture 的逻辑）"""
        if not hasattr(self, 'current_selected_pose') or not self.current_selected_pose:
            QMessageBox.warning(self, "警告", "请先选择一个姿势")
            return
        
        pose_name = self.current_selected_pose
        if pose_name not in self.global_data:
            QMessageBox.warning(self, "警告", "姿势数据不存在")
            return
        
        pose_data = self.global_data[pose_name]
        apply_global = self.rb_global.isChecked()
        force_load = self.chk_force_load.isChecked()
        load_selected_only = self.chk_load_selected_only.isChecked()
        
        # 如果勾选了"仅选中"，获取选中的对象列表
        selected_nodes = set(mxs.selection) if load_selected_only else None
        
        mxs.escapeEnable = False
        
        with pymxs.undo(True):
            try:
                # 禁用场景重绘以提高性能
                mxs.DisableSceneRedraw()
                
                # 查找节点并应用变换
                found_count = 0
                total_count = len(pose_data.get("ID", []))
                
                for i, node_id in enumerate(pose_data.get("ID", [])):
                    # 根据模式选择查找方法
                    if force_load:
                        # 暴力加载：通过节点名称匹配
                        node_name = pose_data.get("name", [])[i] if i < len(pose_data.get("name", [])) else None
                        node = self._find_node_by_name(node_name) if node_name else None
                    else:
                        # 正常加载：通过UUID匹配
                        node = self._find_node_by_id(node_id)
                    
                    if node and mxs.isValidNode(node):
                        # 如果勾选了"仅选中"，检查节点是否在选中列表中
                        if selected_nodes is not None and node not in selected_nodes:
                            continue  # 跳过未选中的节点
                        
                        found_count += 1
                        if apply_global and "global_transform" in pose_data:
                            node.transform = mxs.execute(pose_data["global_transform"][i])
                        elif "local_transform" in pose_data and pose_data["local_transform"][i]:
                            if mxs.isValidNode(node.parent):
                                node.transform = mxs.execute(pose_data["local_transform"][i]) * node.parent.transform
                
                # 完成后重新启用场景重绘
                mxs.enableSceneRedraw()
                mxs.redrawViews()
                
                # 显示加载结果
                mode_text = "暴力加载" if force_load else "加载"
                result_text = f"{mode_text}姿势: {pose_name} (匹配 {found_count}/{total_count} 个节点)"
                self.log(result_text, "cyan")
                try:
                    self.status_bar.showMessage(result_text)
                except:
                    pass
                
            except Exception as e:
                self.log(f"加载失败: {str(e)}", "red")
                QMessageBox.critical(self, "错误", f"加载失败: {str(e)}")
                mxs.enableSceneRedraw()
            finally:
                mxs.escapeEnable = True
    
    def delete_pose(self):
        """删除姿势（支持批量删除）"""
        if not self.selected_poses:
            QMessageBox.warning(self, "警告", "请先选择要删除的姿势")
            return
        
        # 确认删除
        if len(self.selected_poses) == 1:
            message = f"确定要删除 '{self.selected_poses[0]}' 吗？"
        else:
            message = f"确定要删除选中的 {len(self.selected_poses)} 个姿势吗？"
        
        reply = QMessageBox.question(self, "确认删除", message,
                                     QMessageBox.Yes | QMessageBox.No,
                                     QMessageBox.No)
        
        if reply == QMessageBox.Yes:
            deleted_count = 0
            try:
                for pose_name in self.selected_poses[:]:  # 使用副本遍历
                    file_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
                    if os.path.exists(file_path):
                        os.remove(file_path)
                    
                    if pose_name in self.global_data:
                        del self.global_data[pose_name]
                    
                    deleted_count += 1
                
                # 清空选择
                self.selected_poses = []
                self.selected_cards = []
                self.current_selected_pose = None
                
                # 刷新显示
                self.refresh_pose_display()
                self.log(f"已删除 {deleted_count} 个姿势", "orange")
                try:
                    self.status_bar.showMessage(f"已删除 {deleted_count} 个姿势")
                except:
                    pass
            except Exception as e:
                QMessageBox.critical(self, "错误", f"删除失败: {str(e)}")
    
    def _find_node_by_id(self, node_id):
        """通过 ID 查找节点"""
        for obj in mxs.objects:
            if str(mxs.getAppData(obj, 10)) == str(node_id):
                return obj
        return None
    
    def _find_node_by_name(self, node_name):
        """通过名称查找节点（暴力加载用）"""
        if not node_name:
            return None
        try:
            # 使用 Max 的 getNodeByName 函数
            node = mxs.getNodeByName(node_name)
            if node and mxs.isValidNode(node):
                return node
        except:
            pass
        return None


# 执行函数
def execute():
    try:
        studio_library = AnimLibraryDialog(GetQMaxMainWindow())
        studio_library.show()
    except Exception as e:
        print(f"启动 Anim Library 失败: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    execute()
