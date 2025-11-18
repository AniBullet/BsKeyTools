# AnimLibrary_Bullet.S
# 基于 Posture 代码改写，添加库管理功能

import json
import os
import shutil
import pymxs
import time
import uuid
import base64
import math
import webbrowser
from io import BytesIO
from datetime import datetime
from PySide6 import QtGui, QtCore, QtWidgets
from PySide6.QtCore import Qt, QSize, QBuffer, QIODevice
from PySide6.QtGui import QIcon, QColor, QPixmap, QPainter, QImage, QTextOption
from PySide6.QtWidgets import (QMainWindow, QWidget, QFileDialog, QMessageBox,
                               QListWidget, QListWidgetItem, QTreeWidget, QTreeWidgetItem,
                               QSplitter, QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                               QLineEdit, QCheckBox, QRadioButton, QGroupBox, QTextEdit,
                               QProgressBar, QScrollArea, QGridLayout, QMenu, QSlider,
                               QFrame, QColorDialog, QInputDialog, QLayout, QWidgetItem,
                               QDialog, QDialogButtonBox, QApplication, QComboBox)
from pymxs import runtime as mxs
from qtmax import GetQMaxMainWindow


# RBF混合系统
class RBFBlender:
    """径向基函数混合器，用于更自然的姿势混合"""
    
    @staticmethod
    def gaussian_kernel(distance, sigma=1.0):
        """高斯核函数"""
        return math.exp(-(distance ** 2) / (2 * sigma ** 2))
    
    @staticmethod
    def compute_transform_distance(tm1, tm2):
        """计算两个变换矩阵之间的距离"""
        try:
            # 位置距离
            pos1 = tm1.translationPart
            pos2 = tm2.translationPart
            pos_dist = mxs.distance(pos1, pos2)
            
            # 旋转距离（四元数点积转角度）
            rot1 = tm1.rotationPart
            rot2 = tm2.rotationPart
            dot = abs(mxs.dot(rot1, rot2))
            dot = min(1.0, max(-1.0, dot))  # 限制范围
            rot_dist = math.acos(dot) * 57.2958  # 转为度数
            
            # 缩放距离
            scale1 = tm1.scalePart
            scale2 = tm2.scalePart
            scale_dist = mxs.length(scale1 - scale2)
            
            # 加权组合（可调整权重）
            total_dist = pos_dist * 1.0 + rot_dist * 0.5 + scale_dist * 0.3
            return total_dist
        except:
            return 0.0
    
    @staticmethod
    def rbf_blend_transform(current_tm, target_tm, blend_factor, sigma=2.0):
        """使用RBF混合两个变换
        sigma参数控制混合的平滑度：
        - sigma越大：混合越平滑，更接近线性插值
        - sigma越小：混合受距离影响越大，有更强的衰减效果
        """
        try:
            # 提取变换组件
            current_pos = current_tm.translationPart
            current_rot = current_tm.rotationPart
            current_scale = current_tm.scalePart
            
            target_pos = target_tm.translationPart
            target_rot = target_tm.rotationPart
            target_scale = target_tm.scalePart
            
            # 计算简化的距离度量（归一化）
            try:
                pos_dist = mxs.length(target_pos - current_pos)
                # 归一化距离到合理范围（假设100单位是"远"）
                normalized_dist = pos_dist / 100.0
            except:
                normalized_dist = 0.0
            
            # 使用高斯核计算RBF权重
            # sigma值调整：实际使用时除以10，使得UI滑条更直观
            actual_sigma = max(0.1, sigma / 10.0)
            rbf_weight = math.exp(-(normalized_dist ** 2) / (2.0 * actual_sigma ** 2))
            
            # 混合权重：blend_factor主导，rbf_weight作为调制
            # 当sigma大时，rbf_weight接近1，主要由blend_factor控制
            # 当sigma小时，rbf_weight有明显衰减效果
            effective_weight = blend_factor * (rbf_weight * 0.5 + 0.5)
            
            # 限制权重范围
            effective_weight = max(0.0, min(1.0, effective_weight))
            
            # 使用有效权重进行插值
            blended_pos = current_pos + (target_pos - current_pos) * effective_weight
            blended_rot = mxs.slerp(current_rot, target_rot, effective_weight)
            blended_scale = current_scale + (target_scale - current_scale) * effective_weight
            
            return blended_pos, blended_rot, blended_scale
        except Exception as e:
            # 如果RBF失败，回退到简单插值
            print(f"RBF混合失败，使用简单插值: {e}")
            import traceback
            traceback.print_exc()
            
            current_pos = current_tm.translationPart
            current_rot = current_tm.rotationPart
            current_scale = current_tm.scalePart
            
            target_pos = target_tm.translationPart
            target_rot = target_tm.rotationPart
            target_scale = target_tm.scalePart
            
            blended_pos = current_pos + (target_pos - current_pos) * blend_factor
            blended_rot = mxs.slerp(current_rot, target_rot, blend_factor)
            blended_scale = current_scale + (target_scale - current_scale) * blend_factor
            
            return blended_pos, blended_rot, blended_scale


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
        self.setWindowFlags(QtCore.Qt.WindowType.Window)
        
        # 初始化变量
        self.library_path = ""  # 库路径（根目录）
        self.current_folder_path = ""  # 当前查看的文件夹
        self.global_data = {}  # 存储所有姿势数据
        self.ordered_selection_list = []
        self.current_selected_pose = None  # 当前选中的姿势
        self.card_size = 150  # 姿势卡片大小
        self.selected_poses = []  # 多选的姿势列表
        self.selected_cards = []  # 多选的卡片列表
        self.last_selected_pose = None  # 记录最后选择的pose，用于Shift多选
        self.sort_mode = 0  # 0=按名称，1=按时间
        self.filter_tags = []  # 标签筛选列表 [{"name": "标签名", "color": "#RRGGBB"}, ...]
        self.active_filter_tag = None  # 当前激活的筛选标签名
        
        # 缩略图缓存（减少内存占用和重复解码）
        self._thumbnail_cache = {}  # {pose_name: QPixmap}
        self._max_cache_size = 100  # 最大缓存数量
        
        # 用于Shift多选的有序pose列表（与显示顺序一致）
        self.displayed_poses_order = []  # 存储当前显示的poses顺序
        
        # 配置文件路径
        self.config_file = self.get_config_path()
        
        # 设置窗口
        self.setWindowTitle('BsAnimLibrary_v1.0_Bullet.S')
        # 窗口宽度设置为 splitter总宽度(810) + 边距(约30-40)
        self.resize(850, 600)
        
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
        
        # 设置按钮
        self.btn_settings = QPushButton("工具设置")
        self.btn_settings.setToolTip("工具设置")
        toolbar_layout.addWidget(self.btn_settings)
        
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
        
        # 排序控制
        control_layout_top.addWidget(QLabel("排序:"))
        self.sort_combo = QComboBox()
        self.sort_combo.addItem("按名称")
        self.sort_combo.addItem("按时间")
        self.sort_combo.setMaximumWidth(80)
        self.sort_combo.currentIndexChanged.connect(self.on_sort_changed)
        control_layout_top.addWidget(self.sort_combo)
        
        # 缩放控制
        control_layout_top.addWidget(QLabel("大小:"))
        self.size_slider = QSlider(Qt.Horizontal)
        self.size_slider.setMinimum(80)
        self.size_slider.setMaximum(250)
        self.size_slider.setValue(150)
        self.size_slider.setMaximumWidth(100)
        control_layout_top.addWidget(self.size_slider)
        
        center_layout.addLayout(control_layout_top)
        
        # 标签筛选栏（可展开设计）
        self.tag_container = QWidget()
        self.tag_container.setMaximumHeight(30)  # 默认单行高度，更紧凑
        tag_layout = QHBoxLayout(self.tag_container)
        tag_layout.setContentsMargins(0, 2, 0, 2)
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
        self.tag_scroll_area.setMinimumHeight(26)
        self.tag_scroll_area.setMaximumHeight(26)  # 默认1行，更紧凑
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
        self.grid_layout.setSpacing(8)  # 减小间距
        self.grid_widget.setLayout(self.grid_layout)
        self.scroll_area.setWidget(self.grid_widget)
        
        # 添加点击空白区域取消选择的功能
        self.grid_widget.mousePressEvent = self.on_grid_widget_clicked
        center_layout.addWidget(self.scroll_area)
        
        splitter.addWidget(center_panel)
        
        # 右侧：操作面板
        right_panel = QWidget()
        right_panel.setMinimumWidth(160)
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
        
        # 按钮组：覆盖 + 保存
        btn_layout = QHBoxLayout()
        self.btn_overwrite = QPushButton("覆盖")
        self.btn_overwrite.setStyleSheet("""
            QPushButton { 
                padding: 8px; 
                background-color: palette(button); 
                color: palette(button-text);
            }
            QPushButton:hover { 
                background-color: palette(light); 
            }
            QPushButton:pressed { 
                background-color: palette(dark); 
            }
        """)
        self.btn_overwrite.setToolTip("覆盖选中的pose（需要先在下方选中一个pose）")
        self.btn_overwrite.setMaximumWidth(60)  # 限制覆盖按钮宽度
        btn_layout.addWidget(self.btn_overwrite)
        
        self.btn_save = QPushButton("保存")
        self.btn_save.setStyleSheet("""
            QPushButton { 
                font-weight: bold; 
                padding: 8px; 
                background-color: palette(button); 
                color: palette(button-text);
            }
            QPushButton:hover { 
                background-color: palette(light); 
            }
            QPushButton:pressed { 
                background-color: palette(dark); 
            }
        """)
        btn_layout.addWidget(self.btn_save, 1)  # 拉伸因子1，占据剩余空间
        
        save_layout.addLayout(btn_layout)
        
        save_group.setLayout(save_layout)
        right_layout.addWidget(save_group)
        
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
        
        # 位移轴控制（暂时隐藏）
        # trans_layout = QHBoxLayout()
        # trans_layout.addWidget(QLabel("位移:"))
        # self.chk_trans_x = QCheckBox("X")
        # self.chk_trans_x.setChecked(True)
        # self.chk_trans_y = QCheckBox("Y")
        # self.chk_trans_y.setChecked(True)
        # self.chk_trans_z = QCheckBox("Z")
        # self.chk_trans_z.setChecked(True)
        # trans_layout.addWidget(self.chk_trans_x)
        # trans_layout.addWidget(self.chk_trans_y)
        # trans_layout.addWidget(self.chk_trans_z)
        # trans_layout.addStretch()
        # load_layout.addLayout(trans_layout)
        
        # 旋转轴控制（暂时隐藏）
        # rot_layout = QHBoxLayout()
        # rot_layout.addWidget(QLabel("旋转:"))
        # self.chk_rot_x = QCheckBox("X")
        # self.chk_rot_x.setChecked(True)
        # self.chk_rot_y = QCheckBox("Y")
        # self.chk_rot_y.setChecked(True)
        # self.chk_rot_z = QCheckBox("Z")
        # self.chk_rot_z.setChecked(True)
        # rot_layout.addWidget(self.chk_rot_x)
        # rot_layout.addWidget(self.chk_rot_y)
        # rot_layout.addWidget(self.chk_rot_z)
        # rot_layout.addStretch()
        # load_layout.addLayout(rot_layout)
        
        # 加载选项：仅选中、暴力加载
        load_options_layout = QHBoxLayout()
        self.chk_load_selected_only = QCheckBox("仅选中")
        self.chk_load_selected_only.setChecked(False)
        self.chk_load_selected_only.setToolTip("只加载到当前选中的对象（可以选择部分骨骼，如只选小臂）")
        load_options_layout.addWidget(self.chk_load_selected_only)
        
        self.chk_force_load = QCheckBox("暴力加载")
        self.chk_force_load.setToolTip("通过节点名称匹配（忽略UUID）")
        load_options_layout.addWidget(self.chk_force_load)
        load_options_layout.addStretch()
        load_layout.addLayout(load_options_layout)
        
        # 创建启用日志复选框（不显示在界面上，通过设置对话框控制）
        self.chk_enable_log = QCheckBox("启用日志")
        self.chk_enable_log.setChecked(False)
        self.chk_enable_log.setToolTip("开启后在日志区域显示操作信息")
        
        self.btn_load = QPushButton("加载")
        self.btn_load.setStyleSheet("""
            QPushButton { 
                font-weight: bold; 
                padding: 8px; 
                background-color: palette(button); 
                color: palette(button-text);
            }
            QPushButton:hover { 
                background-color: palette(light); 
            }
            QPushButton:pressed { 
                background-color: palette(dark); 
            }
        """)
        load_layout.addWidget(self.btn_load)
        
        load_group.setLayout(load_layout)
        right_layout.addWidget(load_group)
        
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
        self.detail_tags_label.setMinimumHeight(80)
        self.detail_tags_label.setMaximumHeight(100)
        self.detail_tags_label.setWordWrapMode(QTextOption.WordWrap)  # 自动换行
        self.detail_tags_label.setLineWrapMode(QTextEdit.WidgetWidth)  # 按宽度换行
        self.detail_tags_label.setStyleSheet("QTextEdit { color: palette(window-text); padding: 4px; background-color: palette(base); }")
        detail_layout.addWidget(self.detail_tags_label)
        
        detail_layout.addWidget(QLabel("描述:"))
        self.detail_desc_label = QLabel("-")
        self.detail_desc_label.setWordWrap(True)
        self.detail_desc_label.setMinimumHeight(50)
        self.detail_desc_label.setMaximumHeight(80)
        self.detail_desc_label.setStyleSheet("QLabel { color: palette(window-text); padding: 4px; background-color: palette(base); }")
        detail_layout.addWidget(self.detail_desc_label)
        
        detail_group.setLayout(detail_layout)
        right_layout.addWidget(detail_group)
        
        # 其他操作
        self.btn_delete = QPushButton("删除选中项")
        self.btn_delete.setStyleSheet("""
            QPushButton { 
                font-weight: bold; 
                padding: 8px; 
                background-color: palette(button); 
                color: palette(button-text);
            }
            QPushButton:hover { 
                background-color: palette(light); 
            }
            QPushButton:pressed { 
                background-color: palette(dark); 
            }
        """)
        right_layout.addWidget(self.btn_delete)
        
        # 日志（可折叠）
        log_header_layout = QHBoxLayout()
        self.log_toggle_btn = QPushButton("▶ 日志")
        self.log_toggle_btn.setCheckable(True)
        self.log_toggle_btn.setChecked(False)
        self.log_toggle_btn.setStyleSheet("""
            QPushButton { 
                text-align: left; 
                padding: 4px; 
                background-color: palette(button);
                color: palette(window-text);
                border: 1px solid palette(mid);
            }
            QPushButton:hover {
                background-color: palette(light);
            }
        """)
        log_header_layout.addWidget(self.log_toggle_btn)
        
        self.log_clear_btn = QPushButton("清空")
        self.log_clear_btn.setMaximumWidth(60)
        self.log_clear_btn.clicked.connect(lambda: self.log_text.clear())
        self.log_clear_btn.setStyleSheet("""
            QPushButton {
                padding: 4px;
                background-color: palette(button);
                color: palette(window-text);
                border: 1px solid palette(mid);
            }
            QPushButton:hover {
                background-color: palette(light);
            }
        """)
        log_header_layout.addWidget(self.log_clear_btn)
        
        right_layout.addLayout(log_header_layout)
        
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setMinimumHeight(150)
        self.log_text.setMaximumHeight(300)
        self.log_text.setVisible(False)  # 默认隐藏
        self.log_text.setStyleSheet("""
            QTextEdit {
                background-color: palette(base);
                color: palette(text);
                border: 1px solid palette(mid);
                font-family: Consolas, 'Courier New', monospace;
                font-size: 9pt;
            }
        """)
        right_layout.addWidget(self.log_text)
        
        right_layout.addStretch()
        
        splitter.addWidget(right_panel)
        
        # 设置分割比例（左:中:右 = 1:5:1，中间最大）
        splitter.setStretchFactor(0, 1)
        splitter.setStretchFactor(1, 5)
        splitter.setStretchFactor(2, 1)
        
        # 保存引用以便保存配置（默认宽度将在load_config中设置）
        self.splitter = splitter
        
        main_layout.addWidget(splitter)
        
        # 状态栏
        self.status_bar = self.statusBar()
        self.status_bar.showMessage("就绪")
    
    def get_config_path(self):
        """获取配置文件路径"""
        # 配置文件保存在ProgramData目录下，避免权限问题
        config_dir = r'C:\ProgramData\Autodesk\ApplicationPlugins\AnimLibrary\BsAnimLibrary'
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
                
                # 恢复排序模式
                if 'sort_mode' in config:
                    self.sort_mode = config['sort_mode']
                    self.sort_combo.setCurrentIndex(self.sort_mode)
                
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
                else:
                    # 配置中没有splitter_sizes，使用默认值
                    self.splitter.setSizes([150, 500, 160])
                
                # 恢复日志可见性
                if 'log_visible' in config:
                    is_visible = config['log_visible']
                    self.log_text.setVisible(is_visible)
                    self.log_toggle_btn.setText("▼ 日志" if is_visible else "▶ 日志")
                    self.log_toggle_btn.setChecked(is_visible)
                
                # 恢复标签筛选
                if 'filter_tags' in config:
                    self.filter_tags = config['filter_tags']
                    self.refresh_tag_buttons()
                
                # 恢复日志开关设置
                if 'enable_log' in config:
                    self.chk_enable_log.setChecked(config['enable_log'])
            else:
                # 配置文件不存在，设置默认值后创建配置
                self.log("配置文件不存在，创建默认配置", "yellow")
                # 强制设置默认splitter大小
                self.splitter.setSizes([150, 500, 160])
                self.save_config()
        except Exception as e:
            self.log(f"加载配置失败: {e}", "orange")
            # 加载失败也保存一个新的配置
            # 强制设置默认splitter大小
            self.splitter.setSizes([150, 500, 160])
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
                'sort_mode': self.sort_mode,  # 保存排序模式
                'library_path': self.library_path,
                'splitter_sizes': self.splitter.sizes(),
                'log_visible': self.log_text.isVisible(),
                'filter_tags': self.filter_tags,  # 保存标签配置
                'enable_log': self.chk_enable_log.isChecked()  # 保存日志开关设置
            }
            
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2)
        except Exception as e:
            print(f"保存配置失败: {e}")
    
    def closeEvent(self, event):
        """窗口关闭事件"""
        self.save_config()
        
        # 清理内存
        try:
            # 清理缓存
            if hasattr(self, '_thumbnail_cache'):
                self._thumbnail_cache.clear()
            
            # 清理pose数据
            if hasattr(self, 'global_data'):
                self.global_data.clear()
            
            # 清理UI widgets
            for i in reversed(range(self.grid_layout.count())):
                widget = self.grid_layout.itemAt(i).widget()
                if widget:
                    widget.deleteLater()
            
            # 强制垃圾回收
            import gc
            gc.collect()
        except:
            pass
        
        event.accept()
    
    def resizeEvent(self, event):
        """窗口大小改变事件"""
        super().resizeEvent(event)
        # 延迟保存，避免拖动时频繁保存
        if hasattr(self, '_resize_timer'):
            self._resize_timer.stop()
        else:
            from PySide6.QtCore import QTimer
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
            from PySide6.QtCore import QTimer
            self._move_timer = QTimer()
            self._move_timer.setSingleShot(True)
            self._move_timer.timeout.connect(self.save_config)
        self._move_timer.start(500)  # 500ms 后保存
    
    def connect_signals(self):
        """连接信号"""
        self.btn_browse.clicked.connect(self.browse_library)
        self.btn_new_folder.clicked.connect(self.new_folder)
        self.btn_settings.clicked.connect(self.show_settings_dialog)
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
        # 只有启用日志时才输出
        if hasattr(self, 'chk_enable_log') and self.chk_enable_log.isChecked():
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
            from PySide6.QtCore import QTimer
            self._splitter_timer = QTimer()
            self._splitter_timer.setSingleShot(True)
            self._splitter_timer.timeout.connect(self.save_config)
        self._splitter_timer.start(500)  # 500ms 后保存
    
    def create_pose_card(self, pose_name, pose_data, file_path):
        """创建姿势卡片（带缩略图）"""
        card = QWidget()
        
        # 存储pose名称到card对象，用于Shift多选时查找
        card._pose_name = pose_name
        
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
        
        # 尝试加载缩略图（使用缓存）
        if "thumbnail" in pose_data and pose_data["thumbnail"]:
            try:
                # 检查缓存
                cache_key = f"{pose_name}_{thumb_width}x{thumb_height}"
                if cache_key in self._thumbnail_cache:
                    scaled_pixmap = self._thumbnail_cache[cache_key]
                else:
                    # 解码并缓存
                    image_data = base64.b64decode(pose_data["thumbnail"])
                    image = QImage()
                    image.loadFromData(image_data)
                    pixmap = QPixmap.fromImage(image)
                    # 保持宽高比缩放
                    scaled_pixmap = pixmap.scaled(thumb_width - 4, thumb_height - 4, 
                                                  Qt.KeepAspectRatio, Qt.SmoothTransformation)
                    
                    # 缓存管理：限制缓存大小
                    if len(self._thumbnail_cache) >= self._max_cache_size:
                        # 清除最早的缓存项
                        first_key = next(iter(self._thumbnail_cache))
                        del self._thumbnail_cache[first_key]
                    
                    self._thumbnail_cache[cache_key] = scaled_pixmap
                
                thumbnail_label.setPixmap(scaled_pixmap)
            except Exception as e:
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
                # 右键前先确保该pose被选中
                if pose_name not in self.selected_poses:
                    # 如果右键的pose没有被选中，则单选它
                    self.on_pose_card_clicked(pose_name, card, Qt.NoModifier)
                # 使用新API: globalPosition() 代替 globalPos()
                pos = event.globalPosition().toPoint()
                self.show_pose_context_menu(pose_name, pos)
        
        card.mousePressEvent = on_mouse_press
        card.mouseDoubleClickEvent = lambda event: self.on_pose_card_double_clicked(pose_name)
        
        return card
    
    def on_grid_widget_clicked(self, event):
        """点击grid_widget空白区域取消选择"""
        # 检查点击位置是否在某个card上
        click_pos = event.position().toPoint()  # Qt6兼容：使用position()替代pos()
        clicked_widget = self.grid_widget.childAt(click_pos)
        
        # 检查clicked_widget是否是pose card或其子元素
        is_card_clicked = False
        if clicked_widget:
            # 向上遍历父元素，检查是否有_pose_name属性
            current = clicked_widget
            while current and current != self.grid_widget:
                if hasattr(current, '_pose_name'):
                    is_card_clicked = True
                    break
                current = current.parentWidget()
        
        # 如果点击的不是card或card的子元素，清除选择
        if not is_card_clicked:
            # 清除所有选择
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
            
            self.selected_poses = []
            self.selected_cards = []
            self.current_selected_pose = None
            self.last_selected_pose = None
            
            # 更新详情显示
            self.update_detail_panel()
            
            self.log("已取消选择", "blue")
    
    def on_pose_card_clicked(self, pose_name, card, modifiers=None):
        """姿势卡片单击事件（支持多选）"""
        if modifiers is None:
            modifiers = QtCore.Qt.KeyboardModifier.NoModifier
        
        # Shift 范围多选
        if modifiers & QtCore.Qt.KeyboardModifier.ShiftModifier:
            if self.last_selected_pose and self.last_selected_pose in self.displayed_poses_order:
                # 找到上次选择和当前选择的索引
                try:
                    last_idx = self.displayed_poses_order.index(self.last_selected_pose)
                    current_idx = self.displayed_poses_order.index(pose_name)
                    
                    # 确定范围
                    start_idx = min(last_idx, current_idx)
                    end_idx = max(last_idx, current_idx)
                    
                    # 先清空之前的选择
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
                    
                    self.selected_poses = []
                    self.selected_cards = []
                    
                    # 选择范围内的所有poses
                    for idx in range(start_idx, end_idx + 1):
                        range_pose_name = self.displayed_poses_order[idx]
                        # 找到对应的card
                        range_card = self.find_card_by_pose_name(range_pose_name)
                        if range_card:
                            self.selected_poses.append(range_pose_name)
                            self.selected_cards.append(range_card)
                            range_card.setStyleSheet("""
                                QWidget {
                                    background-color: palette(window);
                                    border: 2px solid palette(highlight);
                                }
                            """)
                except ValueError:
                    pass
            else:
                # 如果没有上次选择，当作普通单选
                self.on_pose_card_clicked(pose_name, card, QtCore.Qt.KeyboardModifier.NoModifier)
                return
        # Ctrl 多选
        elif modifiers & QtCore.Qt.KeyboardModifier.ControlModifier:
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
            # 记录最后选择的pose
            self.last_selected_pose = pose_name
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
            # 记录最后选择的pose
            self.last_selected_pose = pose_name
        
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
    
    def find_card_by_pose_name(self, pose_name):
        """根据pose名称找到对应的卡片widget"""
        for i in range(self.grid_layout.count()):
            item = self.grid_layout.itemAt(i)
            if item and item.widget():
                card = item.widget()
                # 检查card是否有pose_name属性或者通过其他方式识别
                # 由于我们在创建卡片时设置了objectName或者可以通过其他方式识别
                # 这里我们遍历所有卡片，通过事件处理函数中保存的信息来匹配
                # 简单方法：给每个card设置objectName
                if hasattr(card, '_pose_name') and card._pose_name == pose_name:
                    return card
        return None
    
    def clear_pose_thumbnail_cache(self, pose_name):
        """清除指定pose的缩略图缓存"""
        # 查找并删除所有与该pose相关的缓存
        keys_to_delete = []
        for key in self._thumbnail_cache.keys():
            if key.startswith(f"{pose_name}_"):
                keys_to_delete.append(key)
        
        for key in keys_to_delete:
            del self._thumbnail_cache[key]
    
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
        
        view_nodes_action = menu.addAction("查看节点列表")
        view_nodes_action.triggered.connect(lambda: self.view_pose_nodes(pose_name))
        
        menu.addSeparator()
        
        overwrite_action = menu.addAction("覆盖")
        overwrite_action.triggered.connect(lambda: self.overwrite_pose(pose_name))
        
        edit_tags_action = menu.addAction("编辑标签")
        edit_tags_action.triggered.connect(lambda: self.edit_pose_tags(pose_name))
        
        edit_desc_action = menu.addAction("编辑描述")
        edit_desc_action.triggered.connect(lambda: self.edit_pose_description(pose_name))
        
        update_thumb_action = menu.addAction("更新缩略图")
        update_thumb_action.triggered.connect(lambda: self.update_pose_thumbnail(pose_name))
        
        menu.addSeparator()
        
        delete_action = menu.addAction("删除")
        delete_action.triggered.connect(lambda: self.delete_pose_by_name(pose_name))
        
        menu.exec(pos)
    
    def view_pose_nodes(self, pose_name):
        """查看姿势包含的节点列表"""
        if pose_name not in self.global_data:
            return
        
        pose_data = self.global_data[pose_name]
        node_names = pose_data.get("name", [])
        node_ids = pose_data.get("ID", [])
        
        if not node_names:
            QMessageBox.information(self, "节点列表", "该姿势没有包含任何节点")
            return
        
        # 创建一个对话框显示节点列表
        dialog = QDialog(self)
        dialog.setWindowTitle(f"节点列表 - {pose_name}")
        dialog.resize(400, 500)
        
        layout = QVBoxLayout(dialog)
        
        # 添加说明标签
        info_label = QLabel(f"该姿势包含 {len(node_names)} 个节点:")
        layout.addWidget(info_label)
        
        # 创建列表显示
        list_widget = QListWidget()
        for i, name in enumerate(node_names):
            # 显示节点名称和UUID（用于调试）
            uuid = node_ids[i] if i < len(node_ids) else "N/A"
            list_widget.addItem(f"{i+1}. {name} (UUID: {uuid[:8]}...)")
        
        layout.addWidget(list_widget)
        
        # 添加按钮
        button_layout = QHBoxLayout()
        
        select_btn = QPushButton("选择这些节点")
        select_btn.clicked.connect(lambda: self.select_pose_nodes(pose_name, dialog))
        button_layout.addWidget(select_btn)
        
        close_btn = QPushButton("关闭")
        close_btn.clicked.connect(dialog.close)
        button_layout.addWidget(close_btn)
        
        layout.addLayout(button_layout)
        
        dialog.exec()
    
    def select_pose_nodes(self, pose_name, dialog=None):
        """选择pose包含的节点"""
        if pose_name not in self.global_data:
            return
        
        pose_data = self.global_data[pose_name]
        node_ids = pose_data.get("ID", [])
        
        if not node_ids:
            QMessageBox.warning(self, "警告", "该姿势没有包含任何节点")
            return
        
        # 查找并选择节点
        nodes_to_select = []
        for node_id in node_ids:
            for obj in mxs.objects:
                if mxs.getAppData(obj, 10):
                    if str(mxs.getAppData(obj, 10)) == str(node_id):
                        nodes_to_select.append(obj)
                        break
        
        if nodes_to_select:
            mxs.clearSelection()
            for node in nodes_to_select:
                mxs.selectMore(node)
            
            self.log(f"已选择 {len(nodes_to_select)}/{len(node_ids)} 个节点", "green")
            QMessageBox.information(self, "成功", f"已选择 {len(nodes_to_select)}/{len(node_ids)} 个节点")
            
            if dialog:
                dialog.close()
        else:
            QMessageBox.warning(self, "警告", "场景中没有找到任何匹配的节点")
    
    def edit_pose_tags(self, pose_name):
        """编辑姿势标签"""
        if pose_name not in self.global_data:
            return
        
        pose_data = self.global_data[pose_name]
        current_tags = pose_data.get("tags", "")
        
        # 输入标签
        new_tags, ok = QtWidgets.QInputDialog.getText(self, "编辑标签", 
                                                       "标签 (用逗号分隔):", 
                                                       text=current_tags)
        if ok:
            # 更新数据
            pose_data["tags"] = new_tags
            
            # 保存到文件
            file_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(pose_data, f, indent=2, ensure_ascii=False)
                self.log(f"已更新标签: {pose_name}", "green")
                
                # 如果该pose在当前选中的poses中，更新详情显示
                if pose_name in self.selected_poses:
                    self.update_detail_panel()
            except Exception as e:
                self.log(f"保存失败: {e}", "red")
    
    def edit_pose_description(self, pose_name):
        """编辑姿势描述"""
        if pose_name not in self.global_data:
            return
        
        pose_data = self.global_data[pose_name]
        current_desc = pose_data.get("description", "")
        
        # 输入描述
        new_desc, ok = QtWidgets.QInputDialog.getText(self, "编辑描述", 
                                                       "描述:", 
                                                       text=current_desc)
        if ok:
            # 更新数据
            pose_data["description"] = new_desc
            
            # 保存到文件
            file_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(pose_data, f, indent=2, ensure_ascii=False)
                self.log(f"已更新描述: {pose_name}", "green")
                
                # 如果该pose在当前选中的poses中，更新详情显示
                if pose_name in self.selected_poses:
                    self.update_detail_panel()
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
                
                # 清除该pose的缩略图缓存
                self.clear_pose_thumbnail_cache(pose_name)
                
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
            f"确定要用当前选中的对象覆盖姿势 '{pose_name}' 吗？\n此操作不可恢复！",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            # 使用选中的对象（对齐save_pose逻辑）
            nodes = list(mxs.selection)
            if not nodes:
                QMessageBox.warning(self, "警告", "请先选择要保存的对象")
                return
            
            # 显示将要覆盖保存的节点信息
            self.log(f"准备覆盖保存 {len(nodes)} 个节点:", "yellow")
            if self.chk_enable_log.isChecked():
                for i, node in enumerate(nodes[:20]):
                    try:
                        node_type = str(mxs.classof(node))
                        node_handle = mxs.getHandleByAnim(node)
                        self.log(f"  [{i+1}] {node.name} (类型:{node_type}, handle:{node_handle})", "gray")
                    except:
                        self.log(f"  [{i+1}] {node.name}", "gray")
                if len(nodes) > 20:
                    self.log(f"  ... 还有 {len(nodes)-20} 个节点", "gray")
            
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
                
                # 清除该pose的缩略图缓存
                self.clear_pose_thumbnail_cache(pose_name)
                
                self.refresh_pose_display()
                
                # 如果该pose在当前选中的poses中，更新详情显示
                if pose_name in self.selected_poses:
                    self.update_detail_panel()
                
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
        # 使用ProgramData目录，避免权限问题
        default_path = r'C:\ProgramData\Autodesk\ApplicationPlugins\AnimLibrary\BsAnimLibrary'
        
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
    
    def show_settings_dialog(self):
        """显示设置对话框"""
        dialog = QDialog(self)
        dialog.setWindowTitle("工具设置")
        dialog.setMinimumWidth(300)
        
        layout = QVBoxLayout()
        
        # 日志设置组
        log_group = QGroupBox("日志设置")
        log_layout = QVBoxLayout()
        
        # 启用日志复选框
        chk_log = QCheckBox("启用日志输出")
        chk_log.setChecked(self.chk_enable_log.isChecked())
        chk_log.setToolTip("开启后在日志区域显示操作信息")
        log_layout.addWidget(chk_log)
        
        log_group.setLayout(log_layout)
        layout.addWidget(log_group)
        
        # 帮助组
        help_group = QGroupBox("帮助")
        help_layout = QVBoxLayout()
        
        # 视频教程按钮
        btn_tutorial = QPushButton("📺 视频教程")
        btn_tutorial.setToolTip("观看B站视频教程")
        btn_tutorial.clicked.connect(lambda: self.open_tutorial_link(dialog))
        help_layout.addWidget(btn_tutorial)
        
        help_group.setLayout(help_layout)
        layout.addWidget(help_group)
        
        # 按钮
        button_box = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        button_box.accepted.connect(dialog.accept)
        button_box.rejected.connect(dialog.reject)
        layout.addWidget(button_box)
        
        dialog.setLayout(layout)
        
        # 显示对话框
        if dialog.exec() == QDialog.Accepted:
            # 保存设置
            self.chk_enable_log.setChecked(chk_log.isChecked())
            self.save_config()
            self.log("设置已保存", "green")
    
    def open_tutorial_link(self, parent_dialog=None):
        """打开视频教程链接"""
        tutorial_url = "https://space.bilibili.com/2031113/lists/560782?type=season"
        
        reply = QMessageBox.question(
            parent_dialog if parent_dialog else self,
            "打开视频教程",
            "是否在浏览器中打开视频教程？\n\n教程地址：\n" + tutorial_url,
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.Yes
        )
        
        if reply == QMessageBox.Yes:
            import webbrowser
            try:
                webbrowser.open(tutorial_url)
                self.log("已打开视频教程链接", "green")
            except Exception as e:
                QMessageBox.warning(
                    parent_dialog if parent_dialog else self,
                    "错误",
                    f"无法打开浏览器：{str(e)}"
                )
    
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
        
        action = menu.exec(self.folder_tree.viewport().mapToGlobal(position))
        
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
        
        # 显式清空旧数据并强制垃圾回收
        if hasattr(self, 'global_data'):
            self.global_data.clear()
        self.global_data = {}
        
        # 清理缩略图缓存（如果存在）
        if hasattr(self, '_thumbnail_cache'):
            self._thumbnail_cache.clear()
        
        # 强制Python垃圾回收
        import gc
        gc.collect()
        
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
            self.tag_scroll_area.setMinimumHeight(48)
            self.tag_scroll_area.setMaximumHeight(48)
            self.btn_expand_tags.setText("▲")
            self.tag_container.setMaximumHeight(52)
        else:
            # 收起到1行
            self.tag_scroll_area.setMinimumHeight(26)
            self.tag_scroll_area.setMaximumHeight(26)
            self.btn_expand_tags.setText("▼")
            self.tag_container.setMaximumHeight(30)
    
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
        
        edit_name_action = menu.addAction("修改名称")
        edit_name_action.triggered.connect(lambda: self.edit_tag_name(tag_name))
        
        edit_color_action = menu.addAction("修改颜色")
        edit_color_action.triggered.connect(lambda: self.edit_tag_color(tag_name))
        
        menu.addSeparator()
        
        delete_action = menu.addAction("删除标签")
        delete_action.triggered.connect(lambda: self.delete_tag(tag_name))
        
        menu.exec(pos)
    
    def edit_tag_name(self, old_tag_name):
        """编辑标签名称"""
        # 找到标签
        tag = next((t for t in self.filter_tags if t["name"] == old_tag_name), None)
        if not tag:
            return
        
        # 输入新名称
        new_name, ok = QInputDialog.getText(
            self, "修改标签名称", 
            f"修改标签 '{old_tag_name}' 的名称:",
            text=old_tag_name
        )
        
        if ok and new_name and new_name != old_tag_name:
            # 检查新名称是否已存在
            if any(t["name"] == new_name for t in self.filter_tags):
                QMessageBox.warning(self, "警告", f"标签 '{new_name}' 已存在！")
                return
            
            # 更新标签名称
            tag["name"] = new_name
            
            # 如果当前激活的筛选标签是被修改的标签，也需要更新
            if self.active_filter_tag == old_tag_name:
                self.active_filter_tag = new_name
            
            self.refresh_tag_buttons()
            self.save_config()
            self.log(f"已修改标签名称: {old_tag_name} → {new_name}", "green")
    
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
        
        # 处理Qt事件队列，确保deleteLater生效
        QApplication.processEvents()
        
        # 清空显示顺序列表
        self.displayed_poses_order = []
        
        # 获取搜索关键词
        search_text = self.search_edit.text().lower().strip()
        
        # 过滤和显示
        row = 0
        col = 0
        # 根据卡片大小动态计算每行数量
        # 计算可用宽度：scroll_area宽度 - 滚动条宽度(20) - 左右边距(约10)
        available_width = self.scroll_area.width() - 30
        # 每个卡片占用宽度 = 卡片大小 + 间距(8)
        card_total_width = self.card_size + 8
        max_cols = max(1, int(available_width / card_total_width))
        
        displayed_count = 0  # 记录实际显示的数量
        
        # 根据排序模式排序pose列表
        if self.sort_mode == 0:
            # 按名称排序（自然排序）
            import re
            def natural_sort_key(item):
                """自然排序key，让pose10排在pose2后面"""
                name = item[0]
                return [int(text) if text.isdigit() else text.lower() 
                        for text in re.split(r'(\d+)', name)]
            sorted_poses = sorted(self.global_data.items(), key=natural_sort_key)
        else:
            # 按修改时间排序（最新的在前）
            def time_sort_key(item):
                pose_name, pose_data = item
                json_path = os.path.join(self.current_folder_path, f"{pose_name}.json")
                if os.path.exists(json_path):
                    return -os.path.getmtime(json_path)  # 负数让最新的排前面
                return 0
            sorted_poses = sorted(self.global_data.items(), key=time_sort_key)
        
        for pose_name, pose_data in sorted_poses:
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
            
            # 记录显示顺序（用于Shift多选）
            self.displayed_poses_order.append(pose_name)
            displayed_count += 1
            
            col += 1
            if col >= max_cols:
                col = 0
                row += 1
        
        # 更新状态栏
        try:
            total_count = len(self.global_data)
            if displayed_count == total_count:
                self.status_bar.showMessage(f"共 {total_count} 个姿势")
            else:
                self.status_bar.showMessage(f"显示 {displayed_count} 个姿势（共 {total_count} 个）")
        except:
            pass
    
    def on_search_changed(self, text):
        """搜索文本改变"""
        self.refresh_pose_display()
    
    def on_size_changed(self, value):
        """卡片大小改变"""
        self.card_size = value
        self.refresh_pose_display()
        self.save_config()  # 保存配置
    
    def on_sort_changed(self, index):
        """排序方式改变"""
        self.sort_mode = index
        self.refresh_pose_display()
        self.save_config()  # 保存配置
    
    def generate_temp_pose_name(self):
        """生成唯一的TempPose名称"""
        if not os.path.exists(self.current_folder_path):
            return "TempPose_1"
        
        # 查找当前文件夹中所有TempPose文件
        existing_numbers = []
        for file in os.listdir(self.current_folder_path):
            if file.startswith("TempPose") and file.endswith(".json"):
                # 提取序号
                name_without_ext = os.path.splitext(file)[0]
                if name_without_ext == "TempPose":
                    existing_numbers.append(0)  # TempPose without number = 0
                elif "_" in name_without_ext:
                    try:
                        number_part = name_without_ext.split("_")[-1]
                        existing_numbers.append(int(number_part))
                    except ValueError:
                        pass
        
        # 找到下一个可用序号
        if not existing_numbers:
            return "TempPose_1"
        else:
            next_number = max(existing_numbers) + 1
            return f"TempPose_{next_number}"
    
    def save_pose(self):
        """保存姿势（使用 Posture 的逻辑）"""
        pose_name = self.save_name_edit.text().strip()
        
        # 如果没有输入名称，自动生成TempPose_序号
        if not pose_name:
            pose_name = self.generate_temp_pose_name()
            self.save_name_edit.setText(pose_name)  # 更新输入框显示
        
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
        
        # 保存选中的对象（对齐posture逻辑）
        nodes = list(mxs.selection)
        if not nodes:
            QMessageBox.warning(self, "警告", "请先选择要保存的对象")
            return
        
        # 显示将要保存的节点信息（详细列出所有节点）
        self.log(f"准备保存 {len(nodes)} 个节点:", "yellow")
        # 列出所有节点，显示类型和handle确认唯一性
        if self.chk_enable_log.isChecked():
            for i, node in enumerate(nodes[:20]):  # 显示前20个
                try:
                    node_type = str(mxs.classof(node))
                    node_handle = mxs.getHandleByAnim(node)
                    self.log(f"  [{i+1}] {node.name} (类型:{node_type}, handle:{node_handle})", "gray")
                except:
                    self.log(f"  [{i+1}] {node.name}", "gray")
            if len(nodes) > 20:
                self.log(f"  ... 还有 {len(nodes)-20} 个节点", "gray")
        
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
            
            # 保存变换（对齐posture逻辑：始终同时保存全局和局部）
            # 保存全局变换
            pose_data["global_transform"] = []
            for node in nodes:
                pose_data["global_transform"].append(str(node.transform))
            
            # 保存局部变换
            pose_data["local_transform"] = []
            trubled_nodes = []
            for node in nodes:
                if mxs.isValidNode(node.parent):
                    offset = mxs.inverse(node.parent.transform * mxs.inverse(node.transform))
                    pose_data["local_transform"].append(str(offset))
                else:
                    trubled_nodes.append(node.name)
                    pose_data["local_transform"].append(None)
            
            # 如果有节点没有父节点，记录日志
            if len(trubled_nodes) > 0 and self.chk_enable_log.isChecked():
                self.log(f"警告: 以下 {len(trubled_nodes)} 个对象没有父节点（局部变换将为None）: {', '.join(trubled_nodes[:5])}{'...' if len(trubled_nodes) > 5 else ''}", "orange")
            
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
            
            # 显示保存成功消息
            success_msg = f"✓ 已保存姿势 '{pose_name}' (包含 {len(nodes)} 个节点)"
            self.log(success_msg, "green")
            try:
                self.status_bar.showMessage(success_msg)
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
            f"确定要用当前选中的对象覆盖姿势 '{pose_name}' 吗？\n此操作不可恢复！",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            # 使用选中的对象（对齐save_pose逻辑）
            nodes = list(mxs.selection)
            if not nodes:
                QMessageBox.warning(self, "警告", "请先选择要保存的对象")
                return
            
            # 显示将要覆盖保存的节点信息
            self.log(f"准备覆盖保存 {len(nodes)} 个节点:", "yellow")
            if self.chk_enable_log.isChecked():
                for i, node in enumerate(nodes[:20]):
                    try:
                        node_type = str(mxs.classof(node))
                        node_handle = mxs.getHandleByAnim(node)
                        self.log(f"  [{i+1}] {node.name} (类型:{node_type}, handle:{node_handle})", "gray")
                    except:
                        self.log(f"  [{i+1}] {node.name}", "gray")
                if len(nodes) > 20:
                    self.log(f"  ... 还有 {len(nodes)-20} 个节点", "gray")
            
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
                
                # 清除该pose的缩略图缓存
                self.clear_pose_thumbnail_cache(pose_name)
                
                self.refresh_pose_display()
                
                # 如果该pose在当前选中的poses中，更新详情显示
                if pose_name in self.selected_poses:
                    self.update_detail_panel()
                
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
        
        if self.chk_enable_log.isChecked():
            self.log(f"开始加载姿势: {pose_name}", "yellow")
        
        # 仅选中模式 或 暴力加载模式：需要先选中对象
        if load_selected_only or force_load:
            selected_nodes = set(mxs.selection)
            if len(selected_nodes) == 0:
                mode_name = "仅选中" if load_selected_only else "暴力加载"
                self.log(f"{mode_name}模式：没有选中任何对象", "orange")
                QMessageBox.warning(self, "警告", f"{mode_name}模式需要先选择物体")
                return
            
            # 显示选中的节点列表（详细）
            if self.chk_enable_log.isChecked():
                selected_list = list(selected_nodes)
                selected_names = [str(node.name) for node in selected_list[:10]]
                self.log(f"已选中 {len(selected_nodes)} 个节点: {', '.join(selected_names)}{' ...' if len(selected_nodes) > 10 else ''}", "yellow")
                # 显示每个选中节点的详细信息
                for i, node in enumerate(selected_list[:5]):
                    try:
                        self.log(f"  选中节点[{i}]: 名称='{node.name}', 类型={mxs.classof(node)}", "gray")
                    except:
                        pass
        else:
            selected_nodes = None  # 默认模式不限制选中
        
        mxs.escapeEnable = False
        
        with pymxs.undo(True):
            try:
                # 禁用场景重绘以提高性能
                mxs.DisableSceneRedraw()
                
                # 创建临时列表用于查找（提高性能，仅在非暴力加载时使用）
                temporary_list = []
                if not force_load:
                    for obj in mxs.objects:
                        if mxs.getAppData(obj, 10):
                            temporary_list.append(obj)
                
                # 查找节点并应用变换
                found_count = 0
                missing_count = 0
                error_count = 0
                max_errors = 50  # 最大错误数，超过则中断
                total_count = len(pose_data.get("ID", []))
                
                # 显示pose包含的节点列表（仅在日志开启时）
                if self.chk_enable_log.isChecked():
                    pose_node_names = pose_data.get("name", [])
                    self.log(f"Pose包含 {total_count} 个节点: {', '.join(pose_node_names[:5])}{' ...' if len(pose_node_names) > 5 else ''}", "cyan")
                
                # 整体循环2次，确保bone层级依赖能正确到位（参考cptools精度机制）
                for loop_pass in range(2):
                    # 安全检查：如果错误过多，中断循环
                    if error_count > max_errors:
                        if self.chk_enable_log.isChecked():
                            self.log(f"⚠ 错误过多({error_count})，中断加载", "red")
                        break
                    
                    # 每次循环重新获取引用，避免引用失效
                    if loop_pass > 0:
                        # 重新获取选中节点（暴力加载和仅选中模式需要）
                        if force_load or load_selected_only:
                            selected_nodes = set(mxs.selection)
                            if self.chk_enable_log.isChecked():
                                self.log(f"  [循环{loop_pass+1}] 重新获取选中节点: {len(selected_nodes)}个", "gray")
                        # 重建UUID临时列表（非暴力加载模式需要）
                        if not force_load:
                            temporary_list = [obj for obj in mxs.objects if mxs.getAppData(obj, 10)]
                    
                    for i, node_id in enumerate(pose_data.get("ID", [])):
                        node = None
                        pose_node_name = pose_data.get("name", [])[i] if i < len(pose_data.get("name", [])) else None
                        
                        # 根据模式选择查找方法
                        if force_load:
                            # 暴力加载：选中对象名字匹配pose节点名字就粘贴
                            if pose_node_name and selected_nodes:
                                for sel_node in selected_nodes:
                                    try:
                                        if str(sel_node.name) == pose_node_name:
                                            node = sel_node
                                            if loop_pass == 0 and self.chk_enable_log.isChecked():
                                                self.log(f"  暴力加载匹配: {pose_node_name}", "cyan")
                                            break
                                    except:
                                        continue
                                
                                # 记录未匹配的节点（仅在第一次循环）
                                if not node and loop_pass == 0 and self.chk_enable_log.isChecked():
                                    self.log(f"  暴力加载未匹配: {pose_node_name}", "orange")
                        else:
                            # 正常加载：通过UUID匹配
                            for item in temporary_list:
                                if str(mxs.getAppData(item, 10)) == str(node_id):
                                    node = item
                                    temporary_list.remove(item)  # 找到后移除，提高后续查找效率
                                    break
                            
                            # 仅选中模式：只处理选中的节点（通过handle比较，更可靠）
                            if load_selected_only and selected_nodes is not None:
                                node_in_selection = False
                                try:
                                    node_handle = mxs.getHandleByAnim(node)
                                    for sel_node in selected_nodes:
                                        try:
                                            sel_handle = mxs.getHandleByAnim(sel_node)
                                            if node_handle == sel_handle:
                                                node_in_selection = True
                                                break
                                        except:
                                            continue
                                except:
                                    node_in_selection = False
                                
                                if not node_in_selection:
                                    if loop_pass == 0 and self.chk_enable_log.isChecked():
                                        self.log(f"  仅选中跳过: {node.name} (未在选中列表中)", "gray")
                                    continue  # 跳过未选中的节点
                        
                        if node and mxs.isValidNode(node):
                            
                            # 只在第一次循环计数
                            if loop_pass == 0:
                                found_count += 1
                            
                            # 详细日志：显示正在加载哪个节点（只在第一次循环显示）
                            if loop_pass == 0 and self.chk_enable_log.isChecked():
                                node_name = pose_data.get("name", [])[i] if i < len(pose_data.get("name", [])) else "Unknown"
                                mode_info = f"[暴力]" if force_load else f"[UUID]"
                                # 显示节点的handle，确认是否是同一个对象
                                try:
                                    node_handle = mxs.getHandleByAnim(node)
                                    self.log(f"  → {mode_info} 加载节点: {node.name} (handle:{node_handle})", "cyan")
                                except:
                                    self.log(f"  → {mode_info} 加载节点: {node.name}", "cyan")
                            
                            # 应用变换（整体循环2次+Biped内部循环）
                            try:
                                if apply_global and "global_transform" in pose_data:
                                    # 全局变换
                                    transform_str = pose_data["global_transform"][i]
                                    
                                    # Biped需要特殊处理：多次直接赋值
                                    is_biped = mxs.classof(node) == mxs.Biped_Object
                                    if is_biped:
                                        # Biped骨骼：Python直接赋值（优化版：第一次3次，第二次1次）
                                        try:
                                            target_transform = mxs.execute(transform_str)
                                            # 第一次循环多次赋值，第二次只赋值一次
                                            repeat_times = 3 if loop_pass == 0 else 1
                                            for biped_attempt in range(repeat_times):
                                                node.transform = target_transform
                                            
                                            if loop_pass == 0 and self.chk_enable_log.isChecked():
                                                self.log(f"    ✓ 应用全局变换(Biped x{repeat_times}): {node.name}", "green")
                                        except Exception as e:
                                            error_count += 1
                                            if loop_pass == 0 and self.chk_enable_log.isChecked() and error_count <= 10:
                                                self.log(f"    ✗ Biped全局变换失败: {node.name} - {str(e)[:50]}", "red")
                                    else:
                                        # 普通节点和bone：直接赋值
                                        try:
                                            target_transform = mxs.execute(transform_str)
                                            node.transform = target_transform
                                            if loop_pass == 0 and self.chk_enable_log.isChecked():
                                                self.log(f"    ✓ 应用全局变换: {node.name}", "green")
                                        except Exception as e:
                                            error_count += 1
                                            if loop_pass == 0 and self.chk_enable_log.isChecked() and error_count <= 10:
                                                self.log(f"    ✗ 全局变换失败: {node.name} - {str(e)[:50]}", "red")
                            
                                elif not apply_global and "local_transform" in pose_data:
                                    # 局部变换
                                    if pose_data["local_transform"][i] is not None:
                                        if mxs.isValidNode(node.parent):
                                            local_transform_str = pose_data["local_transform"][i]
                                            
                                            # Biped需要特殊处理：多次直接赋值
                                            is_biped = mxs.classof(node) == mxs.Biped_Object
                                            if is_biped:
                                                # Biped骨骼：Python直接赋值（优化版：第一次3次，第二次1次）
                                                try:
                                                    offset = mxs.execute(local_transform_str)
                                                    target_transform = offset * node.parent.transform
                                                    # 第一次循环多次赋值，第二次只赋值一次
                                                    repeat_times = 3 if loop_pass == 0 else 1
                                                    for biped_attempt in range(repeat_times):
                                                        node.transform = target_transform
                                                    
                                                    if loop_pass == 0 and self.chk_enable_log.isChecked():
                                                        self.log(f"    ✓ 应用局部变换(Biped x{repeat_times}): {node.name}", "green")
                                                except Exception as e:
                                                    error_count += 1
                                                    if loop_pass == 0 and self.chk_enable_log.isChecked() and error_count <= 10:
                                                        self.log(f"    ✗ Biped局部变换失败: {node.name} - {str(e)[:50]}", "red")
                                            else:
                                                # 普通节点和bone：直接赋值
                                                try:
                                                    offset = mxs.execute(local_transform_str)
                                                    target_transform = offset * node.parent.transform
                                                    node.transform = target_transform
                                                    if loop_pass == 0 and self.chk_enable_log.isChecked():
                                                        self.log(f"    ✓ 应用局部变换: {node.name}", "green")
                                                except Exception as e:
                                                    error_count += 1
                                                    if loop_pass == 0 and self.chk_enable_log.isChecked() and error_count <= 10:
                                                        self.log(f"    ✗ 局部变换失败: {node.name} - {str(e)[:50]}", "red")
                                        else:
                                            if loop_pass == 0 and self.chk_enable_log.isChecked():
                                                self.log(f"    ⚠ 节点 {node.name} 没有父节点，跳过局部变换", "orange")
                                
                                # 处理颜色（全局和局部都适用）
                                if "color" in pose_data and i < len(pose_data["color"]):
                                    try:
                                        color_str = pose_data["color"][i]
                                        if color_str != "(color 0 0 0)":
                                            if mxs.isGroupHead(node):
                                                # 递归处理组头的子节点
                                                color_obj = mxs.execute(color_str)
                                                def apply_color_to_children(parent_node):
                                                    for j in range(parent_node.children.count):
                                                        child = parent_node.children[j]
                                                        if mxs.isValidNode(child):
                                                            child.wirecolor = color_obj
                                                            if child.children.count > 0:
                                                                apply_color_to_children(child)
                                                apply_color_to_children(node)
                                            else:
                                                node.wirecolor = mxs.execute(color_str)
                                    except:
                                        pass
                                        
                            except Exception as e:
                                error_count += 1
                                if loop_pass == 0 and self.chk_enable_log.isChecked() and error_count <= 10:
                                    self.log(f"    ✗ 应用变换失败: {node.name} - {str(e)[:50]}", "red")
                        else:
                            if loop_pass == 0:
                                missing_count += 1
                
                # 不主动清理，让Python自动管理内存（避免与MAXScript垃圾回收冲突）
                
                # 完成后重新启用场景重绘
                mxs.enableSceneRedraw()
                mxs.redrawViews()
                
                # 显示加载结果
                mode_text = "暴力加载" if force_load else "加载"
                transform_mode = "全局" if apply_global else "局部"
                selected_text = " [仅选中]" if load_selected_only else ""
                result_text = f"{mode_text}姿势: {pose_name} ({transform_mode}模式{selected_text}, 匹配 {found_count}/{total_count} 个节点)"
                
                if missing_count > 0:
                    result_text += f" [缺失 {missing_count} 个]"
                
                if error_count > 0:
                    result_text += f" [错误 {error_count} 个]"
                    if error_count > 10 and self.chk_enable_log.isChecked():
                        self.log(f"⚠ 总计 {error_count} 个错误（仅显示前10个）", "orange")
                
                self.log(result_text, "green")
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
                    
                    # 清除该pose的缩略图缓存
                    self.clear_pose_thumbnail_cache(pose_name)
                    
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
