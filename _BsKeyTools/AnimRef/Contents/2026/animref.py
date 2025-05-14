import os
import subprocess
import urllib.request

from pymxs import runtime as mxs
from PySide6 import QtCore, QtGui
from PySide6.QtCore import QFile, QPoint, Qt
from PySide6.QtGui import QAction, QColor, QCursor
from PySide6.QtUiTools import QUiLoader
from PySide6.QtWidgets import (
    QApplication,
    QDialog,
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QMenu,
    QMessageBox,
    QPushButton,
    QSizePolicy,
    QSlider,
    QSpinBox,
    QVBoxLayout,
    QWidget,
)


class HelpDialog(QDialog):
    """自定义帮助对话框，没有底部按钮区域"""
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("AnimRef 帮助")
        self.setWindowFlags(Qt.Dialog | Qt.WindowCloseButtonHint)
        
        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        
        self.textLabel = QLabel(self)
        self.textLabel.setTextFormat(Qt.RichText)
        self.textLabel.setWordWrap(True)
        self.textLabel.setOpenExternalLinks(True)
        layout.addWidget(self.textLabel)
        
        self.setMinimumSize(400, 300)
    
    def setText(self, text):
        self.textLabel.setText(text)


class AnimRef(QDialog):
    def __init__(self, parent=QWidget.find(mxs.windows.getMAXHWND())):
        QDialog.__init__(self, parent)

        self.init()

        # 使用无边框窗口，但保留调整大小功能
        self.setWindowFlags(QtCore.Qt.WindowType.Window | QtCore.Qt.WindowType.FramelessWindowHint)
        self.setAttribute(Qt.WA_DeleteOnClose)
        self.setWindowTitle("AnimRef v1.5.2")
        self.resize(720, 460)

        self.defineVariables()
        self.defineSignals()
        self.setupButtonText()
        self.createRestoreButton()
        self.createTimelineSlider()
        self.createHelpButton()
        self.start()

        self.timer = QtCore.QTimer(self)
        
        # 创建鼠标拖动支持
        self.dragging = False
        self.clickPos = None
        self.windowPos = None
        self.resizing = False
        self.resizeStartPos = None
        self.resizeStartSize = None
        self.resizeDirection = None
        
        # 允许通过窗口边缘调整大小
        self.setWindowFlag(Qt.WindowType.WindowMinMaxButtonsHint, True)
        self.setSizeGripEnabled(True)
        
        # 创建右下角大小调整手柄
        self.updateSizeGripLocation()
        
        # 图片拖拽控制帧数
        self.imageScrolling = False
        self.lastImageDragPos = None

    def updateSizeGripLocation(self):
        """更新右下角大小调整手柄位置"""
        # 在PyQt中，QSizeGrip通常是由Qt自动管理的
        # 这个方法添加这里主要用于任何需要手动调整大小手柄的操作
        pass

    def createTimelineSlider(self):
        """创建时间轴滑块用于拖动帧"""
        # 创建横向容器放置滑块
        self.timelineContainer = QWidget(self)
        self.timelineContainer.setFixedHeight(15)  # 限制整体高度
        timelineLayout = QHBoxLayout(self.timelineContainer)
        timelineLayout.setContentsMargins(5, 0, 5, 0)
        timelineLayout.setSpacing(0)
        
        # 创建滑块
        self.frameSlider = QSlider(Qt.Horizontal, self.timelineContainer)
        self.frameSlider.setMinimum(0)
        self.frameSlider.setMaximum(100)  # 初始值，稍后会根据帧数更新
        self.frameSlider.setValue(0)
        self.frameSlider.setTracking(True)
        self.frameSlider.setEnabled(False)
        self.frameSlider.setFixedHeight(10)  # 限制滑块高度
        
        # 设置样式 - 使进度条更细
        self.frameSlider.setStyleSheet('''
            QSlider {
                height: 10px;
                margin: 0px;
                background: transparent;
            }
            QSlider::groove:horizontal {
                border: 1px solid #444444;
                height: 2px;
                background: #333333;
                margin: 0px;
                border-radius: 1px;
            }
            QSlider::handle:horizontal {
                background: #6A9AE0;
                border: 1px solid #7AB0FF;
                width: 8px;
                height: 8px;
                margin: -4px 0;
                border-radius: 4px;
            }
            QSlider::handle:horizontal:hover {
                background: #7AB0FF;
            }
            QSlider::sub-page:horizontal {
                background: #41729F;
            }
        ''')
        
        timelineLayout.addWidget(self.frameSlider)
        
        # 将滑块容器添加到UI中
        self.ui.layout().insertWidget(1, self.timelineContainer)  # 添加到图片下方，控件上方
        
        # 连接滑块的信号
        self.frameSlider.sliderPressed.connect(self.sliderPressed)
        self.frameSlider.sliderReleased.connect(self.sliderReleased)
        self.frameSlider.valueChanged.connect(self.sliderFrameChanged)
        
        # 滑块拖动中标志
        self.sliderDragging = False
    
    def sliderPressed(self):
        """开始拖动滑块"""
        self.sliderDragging = True
        
    def sliderReleased(self):
        """结束拖动滑块"""
        self.sliderDragging = False
    
    def sliderFrameChanged(self, value):
        """当滑块值改变时更新帧"""
        if self.isLoaded and not self.updatingSlider:
            # 计算对应的帧
            frame = self.time_shift + int(value * (self.last_frame - 1) / 100)
            # 更新MAX时间滑块
            mxs.sliderTime = frame

    def createHelpButton(self):
        """创建帮助按钮 - 此方法已不再需要，帮助按钮在init方法中直接创建"""
        pass  # 不再需要这个方法，因为帮助按钮已在init方法中创建

    def createRestoreButton(self):
        # 创建左下角的还原按钮
        self.restoreButton = QPushButton("🔍", self)
        self.restoreButton.setToolTip("还原窗口")
        self.restoreButton.resize(28, 28)
        self.restoreButton.setStyleSheet('''
            QPushButton {
                background-color: #2A2A2A;
                border: 1px solid #444444;
                border-radius: 3px;
                font-size: 16px;
                font-weight: bold;
                color: #FFFFFF;
                padding: 0px;
            }
            QPushButton:hover {
                background-color: #3A3A3A;
                border: 1px solid #666666;
            }
        ''')
        self.restoreButton.clicked.connect(self.showNormalAndMove)
        self.restoreButton.hide()  # 初始隐藏，最小化时显示
        
    def showNormalAndMove(self):
        # 还原窗口并移动到合适位置
        self.showNormal()
        
        # 获取3ds Max所在的屏幕
        try:
            # 获取MAX主窗口句柄
            maxHWND = mxs.windows.getMAXHWND()
            if maxHWND:
                # 直接从MaxPlus获取屏幕位置信息
                import ctypes
                user32 = ctypes.windll.user32
                
                # 获取窗口矩形
                rect = ctypes.wintypes.RECT()
                user32.GetWindowRect(maxHWND, ctypes.byref(rect))
                
                # 获取所有屏幕信息
                maxPosX = (rect.left + rect.right) // 2
                maxPosY = (rect.top + rect.bottom) // 2
                
                # 找到MAX所在的屏幕
                maxScreen = None
                for screen in QApplication.screens():
                    screenGeom = screen.geometry()
                    if screenGeom.contains(QPoint(maxPosX, maxPosY)):
                        maxScreen = screen
                        break
                
                if maxScreen:
                    screenGeometry = maxScreen.availableGeometry()
                else:
                    # 如果找不到，使用主屏幕
                    screenGeometry = QApplication.primaryScreen().availableGeometry()
            else:
                # 如果找不到MAX窗口，使用主屏幕
                screenGeometry = QApplication.primaryScreen().availableGeometry()
        except Exception as e:
            print(f"获取MAX屏幕失败: {str(e)}")
            # 使用主屏幕
            screenGeometry = QApplication.primaryScreen().availableGeometry()
        
        # 移动到屏幕中央
        self.move((screenGeometry.width() - self.width()) // 2 + screenGeometry.left(), 
                 (screenGeometry.height() - self.height()) // 2 + screenGeometry.top())
        
        # 隐藏恢复按钮
        self.restoreButton.hide()
        
        # 激活窗口并更新大小手柄位置
        self.activateWindow()
        self.updateSizeGripLocation()

    def showMinimized(self):
        super().showMinimized()
        # 显示还原按钮在3ds Max所在屏幕的左下角
        try:
            # 获取MAX主窗口句柄
            maxHWND = mxs.windows.getMAXHWND()
            if maxHWND:
                # 直接从MaxPlus获取屏幕位置信息
                import ctypes
                user32 = ctypes.windll.user32
                
                # 获取窗口矩形
                rect = ctypes.wintypes.RECT()
                user32.GetWindowRect(maxHWND, ctypes.byref(rect))
                
                # 获取所有屏幕信息
                maxPosX = (rect.left + rect.right) // 2
                maxPosY = (rect.top + rect.bottom) // 2
                
                # 找到MAX所在的屏幕
                maxScreen = None
                for screen in QApplication.screens():
                    screenGeom = screen.geometry()
                    if screenGeom.contains(QPoint(maxPosX, maxPosY)):
                        maxScreen = screen
                        break
                
                if maxScreen:
                    screenGeometry = maxScreen.availableGeometry()
                else:
                    # 如果找不到，使用主屏幕
                    screenGeometry = QApplication.primaryScreen().availableGeometry()
            else:
                # 如果找不到MAX窗口，使用主屏幕
                screenGeometry = QApplication.primaryScreen().availableGeometry()
        except Exception as e:
            print(f"获取MAX屏幕失败: {str(e)}")
            # 使用主屏幕
            screenGeometry = QApplication.primaryScreen().availableGeometry()
        
        # 移动到MAX所在屏幕的左下角
        self.restoreButton.move(screenGeometry.left() + 10, screenGeometry.bottom() - 38)
        self.restoreButton.show()
        self.restoreButton.raise_()

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.dragging = True
            self.clickPos = event.globalPosition().toPoint()
            self.windowPos = self.frameGeometry().topLeft()
            
            # 检查是否点击在窗口边缘进行调整大小
            margin = 10
            rect = self.rect()
            if (event.position().x() <= margin or 
                event.position().x() >= rect.width() - margin or 
                event.position().y() <= margin or 
                event.position().y() >= rect.height() - margin):
                
                self.resizing = True
                self.resizeStartPos = event.globalPosition().toPoint()
                self.resizeStartSize = self.size()
                
                # 判断调整方向
                if event.position().x() <= margin:
                    if event.position().y() <= margin:
                        self.resizeDirection = "top-left"
                    elif event.position().y() >= rect.height() - margin:
                        self.resizeDirection = "bottom-left"
                    else:
                        self.resizeDirection = "left"
                elif event.position().x() >= rect.width() - margin:
                    if event.position().y() <= margin:
                        self.resizeDirection = "top-right"
                    elif event.position().y() >= rect.height() - margin:
                        self.resizeDirection = "bottom-right"
                    else:
                        self.resizeDirection = "right"
                elif event.position().y() <= margin:
                    self.resizeDirection = "top"
                elif event.position().y() >= rect.height() - margin:
                    self.resizeDirection = "bottom"
                    
                self.dragging = False
            else:
                self.resizing = False

    def mouseMoveEvent(self, event):
        # 更改鼠标光标形状
        margin = 10
        rect = self.rect()
        pos = event.position()
        
        if not self.dragging and not self.resizing:
            if pos.x() <= margin and pos.y() <= margin:
                self.setCursor(Qt.SizeFDiagCursor)  # 左上角
            elif pos.x() >= rect.width() - margin and pos.y() >= rect.height() - margin:
                self.setCursor(Qt.SizeFDiagCursor)  # 右下角
            elif pos.x() <= margin and pos.y() >= rect.height() - margin:
                self.setCursor(Qt.SizeBDiagCursor)  # 左下角
            elif pos.x() >= rect.width() - margin and pos.y() <= margin:
                self.setCursor(Qt.SizeBDiagCursor)  # 右上角
            elif pos.x() <= margin or pos.x() >= rect.width() - margin:
                self.setCursor(Qt.SizeHorCursor)    # 左边或右边
            elif pos.y() <= margin or pos.y() >= rect.height() - margin:
                self.setCursor(Qt.SizeVerCursor)    # 上边或下边
            else:
                self.setCursor(Qt.ArrowCursor)      # 默认
        
        # 处理拖动或调整大小
        if self.dragging:
            delta = event.globalPosition().toPoint() - self.clickPos
            self.move(self.windowPos + delta)
        elif self.resizing:
            delta = event.globalPosition().toPoint() - self.resizeStartPos
            newSize = QtCore.QSize(self.resizeStartSize)
            newPos = QtCore.QPoint(self.pos())
            
            if "left" in self.resizeDirection:
                width = max(300, self.resizeStartSize.width() - delta.x())
                newSize.setWidth(width)
                newPos.setX(self.x() + self.resizeStartSize.width() - width)
            elif "right" in self.resizeDirection:
                width = max(300, self.resizeStartSize.width() + delta.x())
                newSize.setWidth(width)
                
            if "top" in self.resizeDirection:
                height = max(200, self.resizeStartSize.height() - delta.y())
                newSize.setHeight(height)
                newPos.setY(self.y() + self.resizeStartSize.height() - height)
            elif "bottom" in self.resizeDirection:
                height = max(200, self.resizeStartSize.height() + delta.y())
                newSize.setHeight(height)
            
            self.resize(newSize)
            self.move(newPos)

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.dragging = False
            self.resizing = False
            self.setCursor(Qt.ArrowCursor)
            # 确保鼠标恢复为箭头状态
            QApplication.restoreOverrideCursor()  # 恢复所有被覆盖的鼠标样式

    def wheelEvent(self, event):
        """简化的滚轮事件，避免错误"""
        try:
            delta = event.angleDelta().y()
            if delta > 0:
                # 放大窗口
                w = self.width() + 20
                h = self.height() + 20
            else:
                # 缩小窗口
                w = max(300, self.width() - 20)
                h = max(200, self.height() - 20)
                
            # 保持窗口中心不变
            oldCenter = self.frameGeometry().center()
            self.resize(w, h)
            newRect = self.frameGeometry()
            newRect.moveCenter(oldCenter)
            self.move(newRect.topLeft())
        except Exception as e:
            print(f"调整窗口大小出错: {str(e)}")

    def contextMenuEvent(self, event):
        # 创建右键菜单替代标题栏
        menu = QMenu(self)
        
        minimizeAction = QAction("最小化", self)
        maximizeAction = QAction("最大化/恢复", self)
        sizeAction = QAction("还原初始大小", self)
        helpAction = QAction("帮助", self)
        closeAction = QAction("关闭", self)
        
        minimizeAction.triggered.connect(self.showMinimized)
        maximizeAction.triggered.connect(self.toggleMaximized)
        sizeAction.triggered.connect(lambda: self.resize(720, 460))
        helpAction.triggered.connect(self.showHelp)
        closeAction.triggered.connect(self.close)
        
        menu.addAction(minimizeAction)
        menu.addAction(maximizeAction)
        menu.addAction(sizeAction)
        menu.addSeparator()
        menu.addAction(helpAction)
        menu.addSeparator()
        menu.addAction(closeAction)
        
        menu.exec(QCursor.pos())

    def toggleMaximized(self):
        if self.isMaximized():
            self.showNormal()
        else:
            self.showMaximized()

    def showNormal(self):
        super().showNormal()
        self.restoreButton.hide()
        self.activateWindow()
        self.updateSizeGripLocation()

    def downloadConverter(self):

        converter_path = os.path.join(self.dir, 'ApplicationPlugins', 'AnimRef', 'Contents', 'converter',
                                      'video_to_sequence.exe')
        download_path = "https://raw.githubusercontent.com/ShirzadBh/AnimRef/main/AnimRef/Contents/converter/video_to_sequence.exe"

        try:
            urllib.request.urlretrieve(download_path, converter_path)
            # self.ui.state.setStyleSheet('''color : #98fc03;
            #     font-size: 12px;
            #     font-family:"Comic Sans MS", cursive, sans-serif;''')

            # self.ui.state.setText("video_to_sequence.exe is ready!")
            self.time_counting = True
            self.startTime()
        except:
            # self.ui.state.setStyleSheet('''color : #fc5203;
            #     font-size: 12px;
            #     font-family:"Comic Sans MS", cursive, sans-serif;''')

            # self.ui.state.setText("Download failed...")
            self.time_counting = True
            self.startTime()

    def convertedExist(self):

        FILEBROWSER_PATH = os.path.join(os.getenv('WINDIR'), 'explorer.exe')
        path = os.path.join(self.dir, 'AnimRef', 'Contents', 'converter', 'video_to_sequence.exe')
        converterPath = os.path.join(self.dir, 'AnimRef', 'Contents', 'converter')

        if os.path.exists(path):
            subprocess.run([FILEBROWSER_PATH, converterPath])
        else:
            msgBox = QMessageBox()
            msgBox.setText("Do You Want To Download video_to_sequence.exe")
            msgBox.setWindowTitle("Sequence Converter")
            msgBox.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)

            returnValue = msgBox.exec()
            if returnValue == QMessageBox.Ok:
                self.downloadConverter()

    def startTime(self):
        if self.time_counting:
            self.timer.timeout.connect(self.stopTime)
            self.timer.start(3000)

    def stopTime(self):
        # self.ui.state.clear()
        self.timer.stop()
        self.time_counting = False

    def init(self):
        self.dir = mxs.getDir(mxs.name('publicExchangeStoreInstallPath'))
        
        # 创建主UI对象
        self.ui = QWidget()
        
        # 创建主布局
        main_layout = QVBoxLayout(self.ui)
        main_layout.setContentsMargins(5, 5, 5, 0)  # 减少底部间距
        main_layout.setSpacing(0)  # 减少间距到0，让控件贴紧
        
        # 创建图像查看器
        self.ui.viewer = QLabel()
        self.ui.viewer.setObjectName("viewer")
        self.ui.viewer.setAlignment(Qt.AlignCenter)
        self.ui.viewer.setMinimumSize(300, 200)
        self.ui.viewer.setStyleSheet("background-color: #303030; border: 1px solid #444444;")
        main_layout.addWidget(self.ui.viewer, 1)  # 添加拉伸因子1，让查看器占据更多空间
        
        # 创建控制区域
        control_widget = QWidget()
        control_layout = QHBoxLayout(control_widget)
        control_layout.setContentsMargins(5, 0, 5, 0)  # 减少上下间距
        control_layout.setSpacing(8)  # 增加按钮间距
        
        # 创建按钮，设置固定大小
        button_size = 28
        
        # 控制按钮组：首帧、上一帧、播放、下一帧、尾帧，循环
        self.ui.btn_s_frame = QPushButton()
        self.ui.btn_s_frame.setEnabled(False)
        self.ui.btn_s_frame.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_s_frame)
        
        self.ui.btn_p_frame = QPushButton()
        self.ui.btn_p_frame.setEnabled(False)
        self.ui.btn_p_frame.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_p_frame)
        
        self.ui.btn_play = QPushButton()
        self.ui.btn_play.setCheckable(True)
        self.ui.btn_play.setEnabled(False)
        self.ui.btn_play.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_play)
        
        self.ui.btn_n_frame = QPushButton()
        self.ui.btn_n_frame.setEnabled(False)
        self.ui.btn_n_frame.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_n_frame)
        
        self.ui.btn_e_frame = QPushButton()
        self.ui.btn_e_frame.setEnabled(False)
        self.ui.btn_e_frame.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_e_frame)
        
        # 循环按钮放在播放控制按钮组的末尾
        self.ui.btn_loop = QPushButton()
        self.ui.btn_loop.setEnabled(False)
        self.ui.btn_loop.setCheckable(True)
        self.ui.btn_loop.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_loop)
        
        # # 添加状态标签，放在功能条内部
        # self.ui.state = QLabel("")
        # self.ui.state.setAlignment(Qt.AlignCenter)
        # self.ui.state.setMinimumWidth(80)
        # self.ui.state.setMaximumWidth(150)
        # self.ui.state.setFixedHeight(20)  # 固定高度避免布局拉伸
        # control_layout.addWidget(self.ui.state)

        # 添加时间偏移控制
        shift_widget = QWidget()
        shift_layout = QHBoxLayout(shift_widget)
        shift_layout.setContentsMargins(0, 0, 0, 0)
        shift_layout.setSpacing(4)
        
        shift_label = QLabel("帧偏移:")
        shift_layout.addWidget(shift_label)
                
        self.ui.sb_time_shift = QSpinBox()
        self.ui.sb_time_shift.setMinimum(-10000)
        self.ui.sb_time_shift.setMaximum(10000)
        self.ui.sb_time_shift.setValue(0)
        self.ui.sb_time_shift.setEnabled(False)
        self.ui.sb_time_shift.setFixedWidth(70)
        shift_layout.addWidget(self.ui.sb_time_shift)
        
        control_layout.addWidget(shift_widget)
        
        # 添加弹性空间
        spacer = QWidget()
        spacer.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Preferred)
        control_layout.addWidget(spacer)
        
        # 创建时间轴标签区
        time_info = QWidget()
        time_info_layout = QHBoxLayout(time_info)
        time_info_layout.setContentsMargins(0, 0, 0, 0)
        time_info_layout.setSpacing(4)
        
        # 创建标签
        self.ui.maxframe_label = QLabel("MAX帧:")
        time_info_layout.addWidget(self.ui.maxframe_label)
        
        self.ui.maxframe = QLabel("0")
        self.ui.maxframe.setMinimumWidth(30)
        time_info_layout.addWidget(self.ui.maxframe)
        
        self.ui.refframe_label = QLabel("参考帧:")
        time_info_layout.addWidget(self.ui.refframe_label)
        
        self.ui.refframe = QLabel("0")
        self.ui.refframe.setMinimumWidth(30)
        time_info_layout.addWidget(self.ui.refframe)
        
        control_layout.addWidget(time_info)

        # 添加透明度控制
        opacity_widget = QWidget()
        opacity_layout = QHBoxLayout(opacity_widget)
        opacity_layout.setContentsMargins(0, 0, 0, 0)
        opacity_layout.setSpacing(4)
        
        opacity_label = QLabel("透明度:")
        opacity_layout.addWidget(opacity_label)
        
        self.ui.sl_opacity = QSlider(Qt.Horizontal)
        self.ui.sl_opacity.setMinimum(20)
        self.ui.sl_opacity.setMaximum(100)
        self.ui.sl_opacity.setValue(100)
        self.ui.sl_opacity.setFixedWidth(80)
        opacity_layout.addWidget(self.ui.sl_opacity)
        
        control_layout.addWidget(opacity_widget)
        
        # 加载按钮和转换器按钮
        self.ui.btn_load_seq = QPushButton()
        self.ui.btn_load_seq.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_load_seq)
        
        self.ui.btn_converter = QPushButton()
        self.ui.btn_converter.setFixedSize(button_size, button_size)
        control_layout.addWidget(self.ui.btn_converter)
        
        # 创建帮助按钮并直接添加到布局中
        self.helpButton = QPushButton("❓")
        self.helpButton.setToolTip("显示帮助")
        self.helpButton.setObjectName("helpButton")
        self.helpButton.setFixedSize(button_size, button_size)
        self.helpButton.setStyleSheet('''
            QPushButton {
                background-color: #2A2A2A;
                border: 1px solid #444444;
                border-radius: 3px;
                font-size: 16px;
                font-weight: bold;
                color: #FFFFFF;
                padding: 0px;
            }
            QPushButton:hover {
                background-color: #3A3A3A;
                border: 1px solid #666666;
            }
            QPushButton:pressed {
                background-color: #222222;
            }
        ''')
        self.helpButton.clicked.connect(self.showHelp)
        control_layout.addWidget(self.helpButton)
        
        # 将控制区域添加到主布局
        main_layout.addWidget(control_widget)
        
        # 设置主布局
        layout = QVBoxLayout()
        layout.addWidget(self.ui)
        layout.setContentsMargins(4, 4, 4, 4)
        layout.setSpacing(2)  # 减少间距
        self.setLayout(layout)

    def start(self):
        self.ui.viewer.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
        self.pixmap = QtGui.QPixmap(400, 200)
        self.pixmap.fill(QColor(48, 48, 48))
        self.ui.viewer.setPixmap(self.pixmap)
        mxs.registerTimeCallback(self.changeTime)
        
        # 初始化滑块状态
        self.updatingSlider = False
        self.sliderDragging = False

    def changeOpacity(self):
        self.opacity = self.ui.sl_opacity.value() / 100
        self.setWindowOpacity(self.opacity)

    def defineVariables(self):
        self.last_valid_frame = 0
        self.time_counting = False
        self.out_of_range = False
        self.pixmap = None
        self.isLoaded = False
        self.current_time = int(mxs.currentTime)
        self.time_shift = self.ui.sb_time_shift.value()
        self.time = self.current_time + self.time_shift
        self.height = self.ui.viewer.height()
        self.width = self.ui.viewer.width()
        self.images_backup = {}
        self.images = {}
        self.opacity = 1
        self.images_path = None
        self.last_frame = 0
        self.previous_frame = 0

    def defineSignals(self):
        self.ui.btn_converter.clicked.connect(self.convertedExist)
        self.ui.sl_opacity.valueChanged.connect(self.changeOpacity)
        self.ui.btn_load_seq.clicked.connect(self.load_seq)
        self.ui.sb_time_shift.valueChanged.connect(self.updateTimeShift)
        self.ui.btn_n_frame.clicked.connect(self.nextFrame)
        self.ui.btn_p_frame.clicked.connect(self.previousFrame)
        self.ui.btn_play.clicked.connect(self.playFrame)
        self.ui.btn_s_frame.clicked.connect(self.startFrame)
        self.ui.btn_e_frame.clicked.connect(self.endFrame)

    def nextFrame(self):
        mxs.stopAnimation()
        self.ui.btn_play.setChecked(False)
        mxs.sliderTime += 1
        self.ui.sb_time_shift.setEnabled(True)

    def previousFrame(self):
        mxs.stopAnimation()
        self.ui.btn_play.setChecked(False)
        mxs.sliderTime -= 1
        self.ui.sb_time_shift.setEnabled(True)

    def playFrame(self):
        if mxs.isAnimPlaying():
            self.ui.sb_time_shift.setEnabled(True)
            mxs.stopAnimation()
            self.ui.btn_play.setText("▶️")
        elif not mxs.isAnimPlaying():
            self.ui.sb_time_shift.setEnabled(False)
            mxs.playAnimation()
            self.ui.btn_play.setText("⏸️")

    def startFrame(self):
        mxs.stopAnimation()
        mxs.sliderTime = self.time_shift
        self.ui.btn_play.setText("▶️")
        self.ui.btn_play.setChecked(False)
        self.ui.sb_time_shift.setEnabled(True)

    def endFrame(self):
        mxs.stopAnimation()
        mxs.sliderTime = self.time_shift + (self.last_frame - 1)
        self.ui.btn_play.setText("▶️")
        self.ui.btn_play.setChecked(False)
        self.ui.sb_time_shift.setEnabled(True)

    def updateTimeShift(self):
        self.time_shift = self.ui.sb_time_shift.value()
        self.changeTime()

    def load_seq(self):
        self.height = self.ui.viewer.height()
        self.width = self.ui.viewer.width()

        try:
            fname = list(QFileDialog.getOpenFileNames(self, 'Select Range OF Sequences',
                                                      filter="Images (*.jpeg *.jpg *.png *.bmp)", ))

            if len(fname[0]) > 0:
                self.images = {}
                self.images_path = os.path.dirname(os.path.realpath(fname[0][0]))

                self.test = {}
                for i in range(int(len(fname[0]))):
                    self.images[i] = QtGui.QPixmap(fname[0][i])
                    self.test[i] = fname[0][i]

                self.last_frame = len(fname[0])
                self.isLoaded = True
                
                # 启用动画控制
                self.ui.btn_play.setEnabled(True)
                self.ui.btn_s_frame.setEnabled(True)
                self.ui.btn_p_frame.setEnabled(True)
                self.ui.btn_n_frame.setEnabled(True)
                self.ui.btn_e_frame.setEnabled(True)
                self.ui.sb_time_shift.setEnabled(True)
                self.ui.btn_loop.setEnabled(True)
                
                # 更新帧滑块
                self.frameSlider.setEnabled(True)
                self.frameSlider.setValue(0)
                
                # self.status_1()
                self.changeTime()
            else:
                # self.status_3()
                self.changeTime()
        except Exception as e:
            print(f"加载序列出错: {str(e)}")
            # self.status_3()
            self.changeTime()

    def changeTime(self):
        if self.isLoaded:
            self.ui.maxframe.setText(str(int(mxs.currentTime)))
            self.ui.refframe.setText(str(int(mxs.currentTime) - self.time_shift))

            try:
                self.pixmap = self.images[int(mxs.currentTime) - self.time_shift].scaled(self.width, self.height,
                                                                                         QtCore.Qt.KeepAspectRatio,
                                                                                         QtCore.Qt.FastTransformation)
                self.ui.viewer.setPixmap(self.pixmap)
                self.ui.viewer.repaint()
                self.ui.maxframe.setText(str(int(mxs.currentTime)))
                self.ui.refframe.setText(str(int(mxs.currentTime) - self.time_shift))
                self.out_of_range = False
                self.last_valid_frame = int(mxs.currentTime) - self.time_shift
                
                # 更新滑块位置，无论何时都保持同步，只避免重复调用
                self.updatingSlider = True
                if self.last_frame > 1:
                    currentFrame = int(mxs.currentTime) - self.time_shift
                    if 0 <= currentFrame < self.last_frame:
                        sliderValue = int(currentFrame * 100 / (self.last_frame - 1))
                        self.frameSlider.setValue(max(0, min(100, sliderValue)))
                self.updatingSlider = False
                
            except:
                out = True
                is_playing = mxs.isAnimPlaying()
                # if self.isLoaded and not self.ui.btn_loop.isChecked():
                    # self.status_2()

                if self.isLoaded:
                    if self.ui.btn_loop.isChecked():
                        mxs.stopAnimation()
                        mxs.sliderTime = self.time_shift
                        if is_playing and out:
                            mxs.playAnimation()
                self.out_of_range = True

    def setupButtonText(self):
        """使用Unicode字符替代图标"""
        # 设置通用按钮样式 - 透明背景和适当大小的图标
        buttonStyle = '''
            QPushButton {
                background-color: #2A2A2A;
                border: 1px solid #444444;
                border-radius: 3px;
                font-size: 16px;
                font-weight: bold;
                color: #FFFFFF;
                padding: 2px;
                min-width: 26px;
                min-height: 26px;
                max-width: 28px;
                max-height: 28px;
            }
            QPushButton:hover {
                background-color: #3A3A3A;
                border: 1px solid #666666;
            }
            QPushButton:pressed {
                background-color: #222222;
            }
            QPushButton:disabled {
                color: #666666;
                border: 1px solid #333333;
                background-color: #353535;
            }
        '''
        
        # 应用样式到所有按钮
        self.ui.btn_play.setStyleSheet(buttonStyle)
        self.ui.btn_n_frame.setStyleSheet(buttonStyle)
        self.ui.btn_p_frame.setStyleSheet(buttonStyle)
        self.ui.btn_s_frame.setStyleSheet(buttonStyle)
        self.ui.btn_e_frame.setStyleSheet(buttonStyle)
        self.ui.btn_load_seq.setStyleSheet(buttonStyle)
        self.ui.btn_loop.setStyleSheet(buttonStyle)
        self.ui.btn_converter.setStyleSheet(buttonStyle)
        
        # 使用广泛兼容的Emoji图标
        self.ui.btn_play.setText("▶️")       # 播放按钮
        self.ui.btn_n_frame.setText("⏩")    # 快进
        self.ui.btn_p_frame.setText("⏪")    # 快退
        self.ui.btn_s_frame.setText("⏮️")    # 跳到开始
        self.ui.btn_e_frame.setText("⏭️")    # 跳到结束
        self.ui.btn_load_seq.setText("📂")   # 文件夹
        self.ui.btn_loop.setText("🔄")       # 循环箭头
        self.ui.btn_converter.setText("⚙️")   # 设置齿轮
        
        # 设置暗色主题
        darkThemeStyle = '''
            QWidget {
                background-color: #303030;
                color: #DDDDDD;
            }
            QLabel {
                background-color: transparent;
                color: #DDDDDD;
                border: none;
            }
            QLabel#viewer {
                background-color: #303030;
                border: 1px solid #444444;
            }
            QSpinBox {
                background-color: #2A2A2A;
                color: #FFFFFF;
                border: 1px solid #444444;
                padding: 2px;
                border-radius: 3px;
            }
            QSpinBox::up-button, QSpinBox::down-button {
                background-color: #333333;
                border: 1px solid #444444;
                border-radius: 2px;
            }
            QSlider::groove:horizontal {
                border: 1px solid #444444;
                height: 8px;
                background: #333333;
                margin: 2px 0;
                border-radius: 4px;
            }
            QSlider::handle:horizontal {
                background: #6A9AE0;
                border: 1px solid #7AB0FF;
                width: 16px;
                height: 16px;
                margin: -5px 0;
                border-radius: 8px;
            }
            QSlider::handle:horizontal:hover {
                background: #7AB0FF;
            }
            QCheckBox {
                background-color: transparent;
                color: #DDDDDD;
                padding: 2px;
            }
            QCheckBox::indicator {
                width: 14px;
                height: 14px;
                background-color: #2A2A2A;
                border: 1px solid #444444;
                border-radius: 2px;
            }
            QCheckBox::indicator:checked {
                background-color: #3A6A9A;
            }
            QStatusBar {
                background-color: #2A2A2A;
                color: #BBBBBB;
            }
        '''
        
        # 应用暗色主题到整个对话框
        self.setStyleSheet(darkThemeStyle)
        self.ui.btn_loop.setCheckable(True)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self.updateFrame()
        self.changeTime()
        self.updateSizeGripLocation()
        # 在缩放事件后确保鼠标恢复正常
        self.setCursor(Qt.ArrowCursor)

    def closeEvent(self, event):
        self.restoreButton.hide()
        mxs.unregisterTimeCallback(self.changeTime)
        self.timer.stop()

    def updateFrame(self):
        if self.isLoaded:
            self.height = self.ui.viewer.height()
            self.width = self.ui.viewer.width()

            self.pixmap = self.images[self.last_valid_frame].scaled(self.width, self.height,
                                                                    QtCore.Qt.KeepAspectRatio,
                                                                    QtCore.Qt.FastTransformation)
            self.ui.viewer.setPixmap(self.pixmap)

    # def status_1(self):
    #     # self.ui.state.clear()
    #     self.ui.state.setStyleSheet('''color : #98fc03;
    #         font-size: 12px;
    #         font-family:"Comic Sans MS", cursive, sans-serif;''')

    #     self.ui.state.setText(f"{self.last_frame} images were imported")
    #     self.time_counting = True
    #     self.startTime()

    # def status_2(self):
    #     self.ui.state.clear()
    #     self.ui.state.setStyleSheet('''color : #fcbe03;
    #         font-size: 12px;
    #         font-family:"Comic Sans MS", cursive, sans-serif;''')

    #     self.ui.state.setText(f"Out of range")
    #     self.time_counting = True
    #     self.startTime()

    # def status_3(self):
    #     self.ui.state.clear()
    #     self.ui.state.setStyleSheet('''color : #fc5203;
    #         font-size: 12px;
    #         font-family:"Comic Sans MS", cursive, sans-serif;''')

    #     self.ui.state.setText(f"Import was canceled")
    #     self.time_counting = True
    #     self.startTime()

    def showHelp(self):
        """显示帮助信息"""
        helpText = """
        <b>AnimRef 使用指南</b><br><br>
        
        <b>基本操作：</b><br>
        • 拖动窗口：按住窗口的任何位置拖动<br>
        • 调整窗口大小：鼠标移到窗口边缘进行拉伸<br>
        • 滚轮：调整窗口大小<br><br>
        
        <b>动画控制：</b><br>
        • ▶️ - 播放/暂停动画<br>
        • ⏪ - 前一帧<br>
        • ⏩ - 后一帧<br>
        • ⏮️ - 跳到开始<br>
        • ⏭️ - 跳到结束<br>
        • 🔄 - 循环播放<br>
        • 时间线滑块：拖动控制当前帧<br><br>
        
        <b>其他功能：</b><br>
        • 📂 - 加载图像序列<br>
        • ⚙️ - 转换器设置<br>
        • 透明度滑块：调整窗口透明度<br><br>
        
        <b>右键菜单：</b><br>
        右键点击窗口可以<br>
        • 最小化/最大化窗口<br>
        • 还原初始大小<br>
        • 关闭程序<br><br>
        
        <b>最小化：</b><br>
        • 窗口最小化后，会在屏幕左下角显示还原按钮<br>
        • 也可通过任务栏点击恢复<br>
        """
        
        # 创建自定义帮助对话框
        helpDialog = HelpDialog(self)
        helpDialog.setText(helpText)
        helpDialog.exec()


def main():
    dlg = AnimRef()
    dlg.show()


if __name__ == '__main__':
    main()