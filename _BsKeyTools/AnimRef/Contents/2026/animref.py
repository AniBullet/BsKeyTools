import ctypes
import ctypes.wintypes  # 明确导入wintypes子模块
import os
import subprocess
import urllib.request

from pymxs import runtime as mxs
from PySide6 import QtCore, QtGui
from PySide6.QtCore import QPoint, Qt
from PySide6.QtGui import QAction, QColor, QCursor
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
    # 存储所有AnimRef实例的列表
    instances = []
    
    def __init__(self, parent=QWidget.find(mxs.windows.getMAXHWND())):
        QDialog.__init__(self, parent)

        # 将实例添加到类变量中
        AnimRef.instances.append(self)
        
        self.init()

        # 使用无边框窗口，但保留调整大小功能
        self.setWindowFlags(QtCore.Qt.WindowType.Window | QtCore.Qt.WindowType.FramelessWindowHint)
        self.setAttribute(Qt.WA_DeleteOnClose)
        self.setWindowTitle("AnimRef v1.5.7")  # 更新版本号
        self.resize(800, 500)  # 增加默认窗口尺寸，确保所有控件可见
        
        # 明确设置最小尺寸
        self.setMinimumSize(150, 100)
        
        # 无边框模式标志
        self.borderless_mode = False
        self.saved_ui_state = {}

        self.defineVariables()
        self.defineSignals()
        self.setupButtonText()
        self.createRestoreButton()
        self.createTimelineSlider()
        self.createHelpButton()
        self.start()

        self.timer = QtCore.QTimer(self)
        
        # 创建专用于时间同步的定时器，提高刷新率到60FPS
        self.timeUpdateTimer = QtCore.QTimer(self)
        self.timeUpdateTimer.setInterval(16)  # 16ms更新间隔，约60FPS
        self.timeUpdateTimer.timeout.connect(self.updateTimeFromMax)
        self.timeUpdateTimer.start()
        
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
        
        # 添加帧范围设置按钮
        self.frameRangeButton = QPushButton("⚡", self.timelineContainer)
        self.frameRangeButton.setToolTip("快速设置帧范围")
        self.frameRangeButton.setFixedSize(30, 15)
        self.frameRangeButton.setEnabled(False)  # 初始时禁用按钮
        self.frameRangeButton.setStyleSheet('''
            QPushButton {
                background-color: #2A2A2A;
                border: 1px solid #444444;
                border-radius: 3px;
                font-size: 10px;
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
        self.frameRangeButton.clicked.connect(self.setFrameRangeToSequence)
        timelineLayout.addWidget(self.frameRangeButton)
        
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
        
        # 确保滑块能够拉伸占据所有可用空间
        self.frameSlider.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Fixed)
        
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
            frame = self.time_shift + value
            # 更新MAX时间滑块
            mxs.sliderTime = frame
            
            # 直接更新当前窗口的图像显示，不等待定时器
            try:
                self.changeTime()
            except Exception as e:
                print(f"直接更新帧时出错: {str(e)}")

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
                try:
                    # 确保ctypes.wintypes已正确导入
                    rect = ctypes.wintypes.RECT()
                    ctypes.windll.user32.GetWindowRect(maxHWND, ctypes.byref(rect))
                    
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
                except Exception as e:
                    print(f"获取窗口位置失败: {str(e)}")
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
                try:
                    # 确保ctypes.wintypes已正确导入
                    rect = ctypes.wintypes.RECT()
                    ctypes.windll.user32.GetWindowRect(maxHWND, ctypes.byref(rect))
                    
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
                except Exception as e:
                    print(f"获取窗口位置失败: {str(e)}")
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
            
            # 在无边框模式下，只允许拖动窗口，不调整大小
            if self.borderless_mode:
                return
            
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
                window_width = max(150, self.resizeStartSize.width() - delta.x())  # 减小到150
                newSize.setWidth(window_width)
                newPos.setX(self.x() + self.resizeStartSize.width() - window_width)
            elif "right" in self.resizeDirection:
                window_width = max(150, self.resizeStartSize.width() + delta.x())  # 减小到150
                newSize.setWidth(window_width)
                
            if "top" in self.resizeDirection:
                height = max(100, self.resizeStartSize.height() - delta.y())  # 减小到100
                newSize.setHeight(height)
                newPos.setY(self.y() + self.resizeStartSize.height() - height)
            elif "bottom" in self.resizeDirection:
                height = max(100, self.resizeStartSize.height() + delta.y())  # 减小到100
                newSize.setHeight(height)
            
            self.resize(newSize)
            self.move(newPos)
            
            # 调整UI布局适应小窗口
            try:
                self.adjustLayoutForWindowSize()
            except Exception as e:
                print(f"调整布局出错: {str(e)}")

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            was_resizing = self.resizing  # 保存当前状态以便后续处理
            was_dragging = self.dragging
            
            # 重置状态
            self.dragging = False
            self.resizing = False
            
            # 强制恢复为箭头鼠标样式，无论在什么情况下
            self.unsetCursor()  # 首先取消任何自定义光标
            self.setCursor(Qt.ArrowCursor)  # 然后设置箭头光标
            
            # 确保全局鼠标样式也被重置
            QApplication.restoreOverrideCursor()
            
            # 彻底清除应用程序级别的光标设置
            while QApplication.overrideCursor():
                QApplication.restoreOverrideCursor()
            
            # 再次设置为箭头光标确保一致性
            QApplication.setOverrideCursor(Qt.ArrowCursor)
            QApplication.restoreOverrideCursor()
            
            # 强制更新UI，确保光标改变立即生效
            QApplication.processEvents()

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
                w = max(150, self.width() - 20)  # 减小到150
                h = max(100, self.height() - 20)  # 减小到100
                
            # 保持窗口中心不变
            oldCenter = self.frameGeometry().center()
            self.resize(w, h)
            newRect = self.frameGeometry()
            newRect.moveCenter(oldCenter)
            self.move(newRect.topLeft())
            
            # 调整UI布局适应小窗口
            try:
                self.adjustLayoutForWindowSize()
            except Exception as e:
                print(f"调整布局出错: {str(e)}")
                
        except Exception as e:
            print(f"调整窗口大小出错: {str(e)}")
            
        # 确保鼠标指针恢复正常
        self.setCursor(Qt.ArrowCursor)

    def contextMenuEvent(self, event):
        # 创建右键菜单替代标题栏
        menu = QMenu(self)
        
        minimizeAction = QAction("最小化", self)
        maximizeAction = QAction("最大化/恢复", self)
        sizeAction = QAction("还原初始大小", self)
        helpAction = QAction("帮助", self)
        closeAction = QAction("关闭", self)
        
        # 添加无边框模式切换选项
        if self.borderless_mode:
            borderlessModeAction = QAction("退出无边框模式", self)
        else:
            borderlessModeAction = QAction("进入无边框模式", self)
        
        minimizeAction.triggered.connect(self.showMinimized)
        maximizeAction.triggered.connect(self.toggleMaximized)
        sizeAction.triggered.connect(lambda: self.resize(720, 460))
        helpAction.triggered.connect(self.showHelp)
        closeAction.triggered.connect(self.close)
        borderlessModeAction.triggered.connect(self.toggleBorderlessMode)
        
        menu.addAction(minimizeAction)
        menu.addAction(maximizeAction)
        menu.addAction(sizeAction)
        menu.addSeparator()
        menu.addAction(borderlessModeAction)  # 添加无边框模式菜单项
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
        main_layout.setContentsMargins(1, 1, 1, 1)  # 增加底部间距
        main_layout.setSpacing(5)  # 增加间距，防止控件挤压
        
        # 创建图像查看器
        self.ui.viewer = QLabel()
        self.ui.viewer.setObjectName("viewer")
        self.ui.viewer.setAlignment(Qt.AlignCenter)
        self.ui.viewer.setMinimumSize(100, 50)  # 减少图像查看器最小尺寸
        self.ui.viewer.setStyleSheet("background-color: #303030; border: 1px solid #444444;")
        main_layout.addWidget(self.ui.viewer, 1)  # 添加拉伸因子1，让查看器占据更多空间
        
        # 创建控制区域
        control_widget = QWidget()
        control_widget.setMinimumHeight(36)  # 确保控制区域有足够高度
        control_layout = QHBoxLayout(control_widget)
        control_layout.setContentsMargins(5, 5, 5, 5)  # 增加控制区域内边距
        control_layout.setSpacing(2)  # 减少按钮间距，让按钮更紧凑
        
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
        
        # 添加时间偏移控制
        shift_widget = QWidget()
        shift_layout = QHBoxLayout(shift_widget)
        shift_layout.setContentsMargins(10, 0, 0, 0)
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
        
        # 调整控件排列顺序，确保重要按钮显示
        # 将加载按钮移到前面更明显的位置
        self.ui.btn_load_seq = QPushButton()
        self.ui.btn_load_seq.setFixedSize(button_size, button_size)
        control_layout.insertWidget(0, self.ui.btn_load_seq)  # 插入到最前面
        
        # 转换器按钮
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
        layout.setContentsMargins(0, 0, 0, 0)  # 增加底部边距
        layout.setSpacing(0)  # 适当增加间距
        self.setLayout(layout)

    def start(self):
        self.ui.viewer.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
        self.pixmap = QtGui.QPixmap(400, 200)
        self.pixmap.fill(QColor(48, 48, 48))
        self.ui.viewer.setPixmap(self.pixmap)
        
        # 我们现在使用QTimer而不是MAX回调
        # 初始化最后检查的MAX时间
        self.last_max_time = int(mxs.currentTime)
        
        # 存储回调ID（如果注册了回调）
        self.callback_id = None
        
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
        # 避免与QWidget的width()和height()方法冲突
        self.viewer_width = self.ui.viewer.geometry().width()
        self.viewer_height = self.ui.viewer.geometry().height()
        self.images_backup = {}
        self.images = {}
        self.opacity = 1
        self.images_path = None
        self.last_frame = 0
        self.previous_frame = 0
        
        # 添加缩放图像缓存
        self.scaled_images_cache = {}
        
        # 播放状态跟踪
        self.is_playing = False

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
        """处理播放/暂停按钮点击"""
        # 基于当前跟踪的状态直接切换，而不是检查MAX状态
        # 这样可以确保按钮响应更直接
        
        if self.is_playing:
            # 当前正在播放，需要暂停
            mxs.stopAnimation()
            self.is_playing = False
            self.ui.btn_play.setText("▶️")
            self.ui.btn_play.setChecked(False)
            self.ui.sb_time_shift.setEnabled(True)
        else:
            # 当前已暂停，需要播放
            mxs.playAnimation()
            self.is_playing = True
            self.ui.btn_play.setText("⏸️")
            self.ui.btn_play.setChecked(True)
            self.ui.sb_time_shift.setEnabled(False)
            
        # 强制更新按钮显示
        self.ui.btn_play.repaint()

    def startFrame(self):
        mxs.stopAnimation()
        mxs.sliderTime = self.time_shift
        self.ui.btn_play.setText("▶️")
        self.ui.btn_play.setChecked(False)
        self.is_playing = False
        self.ui.sb_time_shift.setEnabled(True)

    def endFrame(self):
        mxs.stopAnimation()
        mxs.sliderTime = self.time_shift + (self.last_frame - 1)
        self.ui.btn_play.setText("▶️")
        self.ui.btn_play.setChecked(False)
        self.is_playing = False
        self.ui.sb_time_shift.setEnabled(True)

    def updateTimeShift(self):
        self.time_shift = self.ui.sb_time_shift.value()
        self.changeTime()

    def load_seq(self):
        self.viewer_width = self.ui.viewer.geometry().width()
        self.viewer_height = self.ui.viewer.geometry().height()

        try:
            fname = list(QFileDialog.getOpenFileNames(self, 'Select Range OF Sequences',
                                                      filter="Images (*.jpeg *.jpg *.png *.bmp)", ))

            if len(fname[0]) > 0:
                self.images = {}
                self.scaled_images_cache = {}  # 清空缩放图像缓存
                self.images_path = os.path.dirname(os.path.realpath(fname[0][0]))

                self.test = {}
                for i in range(int(len(fname[0]))):
                    self.images[i] = QtGui.QPixmap(fname[0][i])
                    self.test[i] = fname[0][i]

                self.last_frame = len(fname[0])
                self.isLoaded = True
                
                # 预缩放常用尺寸的前几帧图像
                self.precacheImages()
                
                # 启用动画控制
                self.ui.btn_play.setEnabled(True)
                self.ui.btn_s_frame.setEnabled(True)
                self.ui.btn_p_frame.setEnabled(True)
                self.ui.btn_n_frame.setEnabled(True)
                self.ui.btn_e_frame.setEnabled(True)
                self.ui.sb_time_shift.setEnabled(True)
                self.ui.btn_loop.setEnabled(True)
                self.frameRangeButton.setEnabled(True)  # 启用帧范围按钮
                
                # 更新帧滑块
                self.frameSlider.setEnabled(True)
                self.frameSlider.setMaximum(self.last_frame - 1)  # 设置最大值为帧数-1
                self.frameSlider.setValue(0)
                
                self.changeTime()
            else:
                self.changeTime()
        except Exception as e:
            print(f"加载序列出错: {str(e)}")
            self.changeTime()

    def precacheImages(self):
        """预缓存图像以提高播放性能"""
        try:
            # 获取当前尺寸
            self.viewer_width = self.ui.viewer.geometry().width()
            self.viewer_height = self.ui.viewer.geometry().height()
            
            # 清空旧缓存
            self.scaled_images_cache = {}
            
            # 只缓存前10帧或所有帧（如果总帧数小于10）
            frames_to_cache = min(10, self.last_frame)
            
            for i in range(frames_to_cache):
                if i in self.images:
                    # 缓存缩放图像
                    scaled_image = self.images[i].scaled(
                        self.viewer_width, self.viewer_height,
                        QtCore.Qt.KeepAspectRatio,
                        QtCore.Qt.FastTransformation
                    )
                    self.scaled_images_cache[(i, self.viewer_width, self.viewer_height)] = scaled_image
        except Exception as e:
            print(f"预缓存图像出错: {str(e)}")

    def changeTime(self):
        if self.isLoaded:
            # 更新显示的帧号
            current_time = int(mxs.currentTime)
            self.ui.maxframe.setText(str(current_time))
            ref_frame = current_time - self.time_shift
            self.ui.refframe.setText(str(ref_frame))

            try:
                # 检查是否在有效范围内
                if 0 <= ref_frame < self.last_frame:
                    # 获取当前尺寸，安全使用方法而非变量
                    current_width = self.ui.viewer.geometry().width()
                    current_height = self.ui.viewer.geometry().height()
                    
                    # 检查缓存中是否已存在缩放后的图像
                    cache_key = (ref_frame, current_width, current_height)
                    
                    if cache_key in self.scaled_images_cache:
                        # 使用缓存图像
                        self.pixmap = self.scaled_images_cache[cache_key]
                    else:
                        # 缩放图像并缓存
                        self.pixmap = self.images[ref_frame].scaled(
                            current_width, current_height,
                            QtCore.Qt.KeepAspectRatio,
                            QtCore.Qt.FastTransformation
                        )
                        # 仅在播放时缓存，以避免内存占用过大
                        if self.is_playing and len(self.scaled_images_cache) < 30:  # 限制缓存大小
                            self.scaled_images_cache[cache_key] = self.pixmap
                    
                    # 更新显示
                    self.ui.viewer.setPixmap(self.pixmap)
                    self.ui.viewer.repaint()
                    self.out_of_range = False
                    self.last_valid_frame = ref_frame
                    
                    # 更新滑块位置，避免重复调用
                    self.updatingSlider = True
                    self.frameSlider.setValue(ref_frame)
                    self.updatingSlider = False
                else:
                    # 超出范围处理
                    self.out_of_range = True
                    is_playing = mxs.isAnimPlaying()
                    
                    # 循环播放逻辑
                    if self.ui.btn_loop.isChecked():
                        mxs.stopAnimation()
                        mxs.sliderTime = self.time_shift
                        if is_playing:
                            mxs.playAnimation()
            except Exception as e:
                print(f"图像显示错误: {str(e)}")
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
        
        # 调整大小时清除图像缓存
        self.scaled_images_cache = {}
        
        # 调整UI布局适应小窗口
        try:
            self.adjustLayoutForWindowSize()
        except Exception as e:
            print(f"调整布局出错: {str(e)}")
        
        try:
            self.updateFrame()
        except Exception as e:
            print(f"更新帧出错: {str(e)}")
            
        try:
            self.changeTime()
        except Exception as e:
            print(f"更新时间出错: {str(e)}")
            
        try:
            self.updateSizeGripLocation()
        except Exception as e:
            print(f"更新大小手柄位置出错: {str(e)}")
        
        # 在缩放事件后确保鼠标恢复正常
        self.setCursor(Qt.ArrowCursor)

    def closeEvent(self, event):
        self.restoreButton.hide()
        
        # 先从实例列表中移除当前实例
        if self in AnimRef.instances:
            AnimRef.instances.remove(self)
        
        # 安全注销回调函数
        try:
            # 检查回调ID是否是可调用对象
            if self.callback_id is not None and callable(self.callback_id):
                mxs.unregisterTimeCallback(self.callback_id)
            elif hasattr(self, 'time_callback_closure') and callable(self.time_callback_closure):
                # 尝试注销闭包回调
                mxs.unregisterTimeCallback(self.time_callback_closure)
            # 不要尝试注销其他不是函数的对象
        except Exception as e:
            print(f"注销回调函数失败(可忽略): {str(e)}")
        
        # 停止所有定时器
        self.timer.stop()
        self.timeUpdateTimer.stop()

    def updateFrame(self):
        if self.isLoaded:
            # 获取当前尺寸，避免使用width/height变量
            self.viewer_width = self.ui.viewer.geometry().width()
            self.viewer_height = self.ui.viewer.geometry().height()
            
            try:
                self.pixmap = self.images[self.last_valid_frame].scaled(
                    self.viewer_width, 
                    self.viewer_height,
                    QtCore.Qt.KeepAspectRatio,
                    QtCore.Qt.FastTransformation
                )
                self.ui.viewer.setPixmap(self.pixmap)
            except Exception as e:
                print(f"更新帧时出错: {str(e)}")

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
        • 时间线滑块：拖动控制当前帧<br>
        • ⚡ - 快速设置MAX帧范围与序列同步<br><br>
        
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

    def updateTimeFromMax(self):
        """使用定时器更新时间，代替MAX的回调函数"""
        # 确保窗口处于活动状态，并且已加载序列
        if not self.isVisible() or not self.isLoaded:
            return
            
        # 获取当前MAX时间
        current_max_time = int(mxs.currentTime)
        
        # 如果时间变化了，更新UI
        time_changed = (not hasattr(self, 'last_max_time')) or (self.last_max_time != current_max_time)
        if time_changed:
            self.last_max_time = current_max_time
            
            # 调用changeTime更新界面
            try:
                self.changeTime()
            except Exception as e:
                print(f"更新时间时出错: {str(e)}")
        
        # 始终同步播放按钮状态，不依赖于时间变化
        self.syncPlayButtonState()

    def syncPlayButtonState(self):
        """同步播放按钮状态与MAX实际播放状态"""
        try:
            # 获取MAX实际播放状态
            max_playing = mxs.isAnimPlaying()
            
            # 如果状态不匹配，则同步
            if max_playing != self.is_playing:
                self.is_playing = max_playing
                
                if max_playing:
                    # MAX在播放但我们的状态是非播放，更新为播放状态
                    self.ui.btn_play.setText("⏸️")
                    self.ui.btn_play.setChecked(True)
                    self.ui.sb_time_shift.setEnabled(False)
                else:
                    # MAX已停止但我们的状态是播放，更新为停止状态
                    self.ui.btn_play.setText("▶️")
                    self.ui.btn_play.setChecked(False)
                    self.ui.sb_time_shift.setEnabled(True)
                
                # 强制更新按钮显示
                self.ui.btn_play.repaint()
        except Exception as e:
            print(f"同步播放按钮状态出错: {str(e)}")

    def adjustLayoutForWindowSize(self):
        """根据窗口尺寸调整UI布局"""
        try:
            # 安全获取窗口尺寸，使用方法
            window_width = self.geometry().width()
            
            # 直接调用控件可见性更新
            self.updateControlVisibility(window_width)
                
        except Exception as e:
            print(f"调整UI布局出错: {str(e)}")
            
    def updateControlVisibility(self, window_width):
        """根据窗口宽度调整控制区域可见性"""
        try:
            # 确保window_width是整数
            if not isinstance(window_width, int):
                window_width = int(window_width)
                
            # 获取时间信息标签
            time_info = None
            ref_frame_label = None
            max_frame_label = None
            
            # 获取所有标签控件
            if hasattr(self.ui, 'maxframe_label'):
                max_frame_label = self.ui.maxframe_label
                # 找到包含所有标签的父容器
                if max_frame_label and max_frame_label.parent():
                    time_info = max_frame_label.parent()
            
            if hasattr(self.ui, 'refframe_label'):
                ref_frame_label = self.ui.refframe_label
            
            # 根据可用宽度决定是否显示时间信息区域
            min_text_display_width = 250  # 显示文本所需的最小宽度
            
            if time_info:
                if window_width < min_text_display_width:
                    time_info.hide()
                else:
                    time_info.show()
            
            # 控制透明度滑块区域可见性
            opacity_control = None
            for child in self.ui.findChildren(QWidget):
                if hasattr(self.ui, 'sl_opacity') and (child == self.ui.sl_opacity or 
                   (child.parent() and child.parent() == self.ui.sl_opacity.parent())):
                    opacity_control = self.ui.sl_opacity.parent()
                    break
            
            if opacity_control:
                if window_width < 200:
                    opacity_control.hide()
                else:
                    opacity_control.show()
            
        except Exception as e:
            print(f"调整控件可见性出错: {str(e)}")

    def toggleBorderlessMode(self):
        """切换无边框模式 - 只显示图片，隐藏所有控制元素"""
        if not self.borderless_mode:
            # 进入无边框模式
            self.enterBorderlessMode()
        else:
            # 退出无边框模式
            self.exitBorderlessMode()
    
    def enterBorderlessMode(self):
        """进入无边框模式"""
        self.borderless_mode = True
        
        # 保存当前窗口状态以便恢复
        self.saved_ui_state = {
            'window_geometry': self.geometry(),
            'main_layout_margins': self.ui.layout().contentsMargins(),
            'main_layout_spacing': self.ui.layout().spacing(),
            'outer_layout_margins': self.layout().contentsMargins(),
            'outer_layout_spacing': self.layout().spacing(),
            'viewer_stylesheet': self.ui.viewer.styleSheet()
        }
        
        # 遍历所有控件，隐藏除了图像查看器之外的所有元素
        for i in range(self.ui.layout().count()):
            if i >= self.ui.layout().count():
                break
                
            item = self.ui.layout().itemAt(i)
            if not item:
                continue
                
            widget = item.widget()
            if not widget:
                continue
                
            # 保留图像查看器，隐藏其他所有元素
            if widget == self.ui.viewer:
                continue
                
            # 保存当前可见状态并隐藏
            self.saved_ui_state[widget] = widget.isVisible()
            widget.hide()
        
        # 移除所有布局间距和边距
        self.ui.layout().setContentsMargins(0, 0, 0, 0)
        self.ui.layout().setSpacing(0)
        self.layout().setContentsMargins(0, 0, 0, 0)
        self.layout().setSpacing(0)
        
        # 确保图像查看器填满整个窗口，无边框无背景
        self.ui.viewer.setStyleSheet("background-color: transparent; border: none;")
        
        # 设置窗口样式为无边框、全透明背景
        self.setWindowFlags(QtCore.Qt.WindowType.Window | QtCore.Qt.WindowType.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground, True)
        
        # 应用窗口标志更改
        self.show()
        
        # 调整窗口大小以匹配当前图片
        self.resizeToCurrentImage()
    
    def resizeToCurrentImage(self):
        """调整窗口大小以匹配当前显示的图片"""
        if not self.isLoaded or not hasattr(self, 'pixmap') or self.pixmap is None:
            return
            
        try:
            # 获取当前图片的实际尺寸
            pixmap_size = self.pixmap.size()
            if pixmap_size.width() <= 0 or pixmap_size.height() <= 0:
                return
                
            # 获取屏幕尺寸，确保调整后的窗口不会超出屏幕
            screen = QApplication.screenAt(self.mapToGlobal(QPoint(0, 0)))
            if not screen:
                screen = QApplication.primaryScreen()
                
            screen_size = screen.availableSize()
            
            # 计算合适的窗口尺寸，确保不超过屏幕80%
            max_width = int(screen_size.width() * 0.8)
            max_height = int(screen_size.height() * 0.8)
            
            # 如果图片尺寸超过限制，按比例缩小
            window_width = pixmap_size.width()
            window_height = pixmap_size.height()
            
            if window_width > max_width:
                scale_factor = max_width / float(window_width)
                window_width = max_width
                window_height = int(window_height * scale_factor)
                
            if window_height > max_height:
                scale_factor = max_height / float(window_height)
                window_height = max_height
                window_width = int(window_width * scale_factor)
            
            # 应用新尺寸到窗口 - 但不固定大小，保持可调整
            self.resize(window_width, window_height)
            
            # 确保图片查看器填满整个窗口，但不固定大小
            # 移除固定大小设置，保持可调整
            
            # 移动窗口到屏幕中央
            center_pos = screen.availableGeometry().center()
            window_rect = self.frameGeometry()
            window_rect.moveCenter(center_pos)
            self.move(window_rect.topLeft())
            
        except Exception as e:
            print(f"调整窗口大小出错: {str(e)}")
    
    def exitBorderlessMode(self):
        """退出无边框模式，恢复正常界面"""
        self.borderless_mode = False
        
        # 不需要恢复固定大小设置，因为没有设置固定大小
        
        # 恢复所有隐藏的控件
        for widget, was_visible in self.saved_ui_state.items():
            if isinstance(widget, QWidget):
                if was_visible:
                    widget.show()
        
        # 恢复布局边距和间距
        if 'main_layout_margins' in self.saved_ui_state:
            margins = self.saved_ui_state['main_layout_margins']
            self.ui.layout().setContentsMargins(margins.left(), margins.top(), 
                                             margins.right(), margins.bottom())
            
        if 'main_layout_spacing' in self.saved_ui_state:
            self.ui.layout().setSpacing(self.saved_ui_state['main_layout_spacing'])
            
        if 'outer_layout_margins' in self.saved_ui_state:
            margins = self.saved_ui_state['outer_layout_margins']
            self.layout().setContentsMargins(margins.left(), margins.top(), 
                                          margins.right(), margins.bottom())
            
        if 'outer_layout_spacing' in self.saved_ui_state:
            self.layout().setSpacing(self.saved_ui_state['outer_layout_spacing'])
        
        # 恢复图像查看器样式
        if 'viewer_stylesheet' in self.saved_ui_state:
            self.ui.viewer.setStyleSheet(self.saved_ui_state['viewer_stylesheet'])
        else:
            self.ui.viewer.setStyleSheet("background-color: #303030; border: 1px solid #444444;")
        
        # 恢复窗口样式
        self.setWindowFlags(QtCore.Qt.WindowType.Window | QtCore.Qt.WindowType.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground, False)
        
        # 恢复原始窗口几何形状
        if 'window_geometry' in self.saved_ui_state:
            self.setGeometry(self.saved_ui_state['window_geometry'])
        
        # 应用更改并调整布局
        self.show()
        self.adjustLayoutForWindowSize()

    def leaveEvent(self, event):
        """鼠标离开窗口时恢复默认光标"""
        # 只有在不拖动和不调整大小时才恢复
        if not self.dragging and not self.resizing:
            self.unsetCursor()
            self.setCursor(Qt.ArrowCursor)
            
            # 确保全局鼠标样式也被重置
            QApplication.restoreOverrideCursor()
            
            # 彻底清除所有光标覆盖
            while QApplication.overrideCursor():
                QApplication.restoreOverrideCursor()
                
        super().leaveEvent(event)

    def setFrameRangeToSequence(self):
        """快速设置3ds Max的动画帧范围与加载的序列一致"""
        if not self.isLoaded or self.last_frame <= 0:
            return
            
        try:
            # 计算开始帧和结束帧
            start_frame = self.time_shift
            end_frame = self.time_shift + self.last_frame - 1
            
            # 设置3ds Max的动画范围
            # 使用MAXScript命令来确保UI也更新
            mxs.execute(f"animationRange = interval {start_frame} {end_frame}")
            
            # 更新时间滑块位置到起始帧
            mxs.sliderTime = start_frame
            
            # 更新界面显示
            self.updateTimeFromMax()  # 强制更新时间
            
            # 显示成功消息
            msg = f"已设置动画范围: {start_frame} - {end_frame}"
            self.showTemporaryMessage(msg)
            
            # 修改帧范围后，如果MAX不在播放状态，更新MAX的时间配置器
            if not mxs.isAnimPlaying():
                try:
                    # 更新时间配置器显示范围
                    mxs.execute("timeConfiguration.viewRange = [animationRange.start, animationRange.end]")
                except:
                    pass  # 忽略此步骤的错误，不影响主要功能
            
        except Exception as e:
            print(f"设置帧范围时出错: {str(e)}")
    
    def showTemporaryMessage(self, message, duration=2000):
        """显示临时消息，使用非模态标签"""
        try:
            # 创建临时标签
            msgLabel = QLabel(message, self)
            msgLabel.setAlignment(Qt.AlignCenter)
            msgLabel.setStyleSheet("""
                background-color: rgba(58, 58, 58, 220);
                color: #FFFFFF;
                border: 1px solid #555555;
                border-radius: 5px;
                padding: 10px;
                font-size: 12px;
            """)
            
            # 设置标签大小和位置
            msgLabel.adjustSize()
            msgLabel.move(
                (self.width() - msgLabel.width()) // 2,
                (self.height() - msgLabel.height()) // 2
            )
            
            # 显示标签
            msgLabel.show()
            msgLabel.raise_()
            
            # 使用QTimer延迟删除标签
            def removeLabel():
                try:
                    if msgLabel and msgLabel.isVisible():
                        msgLabel.hide()
                        msgLabel.deleteLater()
                except:
                    pass
            
            # 创建并启动定时器
            timer = QtCore.QTimer(self)
            timer.setSingleShot(True)
            timer.timeout.connect(removeLabel)
            timer.start(duration)
            
        except Exception as e:
            print(f"显示临时消息出错: {str(e)}")


def main():
    dlg = AnimRef()
    dlg.show()


if __name__ == '__main__':
    main()