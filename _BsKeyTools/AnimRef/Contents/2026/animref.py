import ctypes
import ctypes.wintypes  # 明确导入wintypes子模块
import os
import subprocess
import time
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
        self.timeUpdateTimer.setInterval(33)  # 改为33ms，约30FPS
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
        openFramesDirAction = QAction("打开序列帧文件夹", self)
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
        openFramesDirAction.triggered.connect(self.openFramesDir)
        helpAction.triggered.connect(self.showHelp)
        closeAction.triggered.connect(self.close)
        borderlessModeAction.triggered.connect(self.toggleBorderlessMode)
        
        menu.addAction(minimizeAction)
        menu.addAction(maximizeAction)
        menu.addAction(sizeAction)
        menu.addSeparator()
        menu.addAction(borderlessModeAction)  # 添加无边框模式菜单项
        menu.addAction(openFramesDirAction)       
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

    def convertedExist(self):
        """视频转序列帧功能"""
        try:
            # 获取3dsMax临时目录，创建AnimRef_Frame文件夹
            temp_dir = mxs.getDir(mxs.name('temp'))
            output_base_dir = os.path.join(temp_dir, 'AnimRef_Frame')
            
            # 确保输出目录存在
            if not os.path.exists(output_base_dir):
                os.makedirs(output_base_dir)
            
            # 弹出文件选择对话框，选择视频文件
            files = list(QFileDialog.getOpenFileNames(
                self, 
                '选择要转换的视频文件',
                filter="视频文件 (*.mp4 *.gif *.avi)"
            ))
            
            # 如果用户选择了文件
            if len(files[0]) > 0:
                # 对每个文件进行处理
                for video_file in files[0]:
                    # 提取文件名(不含扩展名)和扩展名
                    file_name = os.path.splitext(os.path.basename(video_file))[0]
                    file_ext = os.path.splitext(video_file)[1].lower()
                    
                    # 添加时间戳以避免冲突 (使用毫秒级时间戳)
                    import time
                    timestamp = int(time.time() * 1000) % 10000  # 取最后4位数字作为简短时间戳
                    
                    # 创建输出子文件夹（添加时间戳避免重名）
                    output_dir = os.path.join(output_base_dir, f"{file_name}_AnimRef_{timestamp}")
                    if not os.path.exists(output_dir):
                        os.makedirs(output_dir)
                    
                    # 执行转换
                    self.convertVideoToFrames(video_file, output_dir, file_ext)
        except Exception as e:
            QMessageBox.warning(self, "转换错误", f"转换过程中出错: {str(e)}")
    
    def convertVideoToFrames(self, video_file, output_dir, file_ext=None):
        """将视频文件转换为序列帧"""
        try:
            # 根据文件类型选择处理工具
            if file_ext is None:
                file_ext = os.path.splitext(video_file)[1].lower()
                
            if file_ext and file_ext.lower() == '.gif':
                # 使用gifsicle处理GIF
                return self.convertGifToFrames(video_file, output_dir)
            else:
                # 使用ffmpeg处理其他视频
                return self.convertVideoWithFfmpeg(video_file, output_dir)
        except Exception as e:
            QMessageBox.warning(self, "转换错误", f"转换过程中出错: {str(e)}")
            return False
            
    def convertGifToFrames(self, gif_file, output_dir):
        """使用gifsicle将GIF转换为序列帧"""
        try:
            # 确保gifsicle.exe可用
            gifsicle_path = self.ensureGifsicleAvailable()
            if not gifsicle_path:
                # 如果gifsicle不可用，尝试使用ffmpeg作为备选
                return self.convertVideoWithFfmpeg(gif_file, output_dir)
            
            # 进度对话框
            progress_dialog = QMessageBox()
            progress_dialog.setWindowTitle("正在转换")
            progress_dialog.setText(f"正在将GIF {os.path.basename(gif_file)} 转换为序列帧...")
            progress_dialog.setStandardButtons(QMessageBox.NoButton)
            progress_dialog.show()
            QApplication.processEvents()
            
            # 直接使用gifsicle的explode命令分解GIF为独立帧，输出到最终目录
            base_name = os.path.splitext(os.path.basename(gif_file))[0]
            
            # 构建gifsicle命令 - 直接输出到最终目录
            # 添加--unoptimize和--careful参数以获得最高质量
            command = f'"{gifsicle_path}" --unoptimize --careful --no-extensions --no-conserve-memory --explode --output="{os.path.join(output_dir, "frame")}.%04d" "{gif_file}"'
            
            result = subprocess.run(command, shell=True, check=False, 
                                  stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            
            # 处理gifsicle输出
            frame_count = 0
            try:
                # 计算输出的帧数
                frames = [f for f in os.listdir(output_dir) if f.startswith("frame") and f.endswith(".png")]
                frame_count = len(frames)
                
                # 根据输出格式，可能需要重命名文件
                if frame_count == 0:
                    # 如果没有找到frame*.png格式的文件，寻找其他可能的格式
                    all_frames = [f for f in os.listdir(output_dir) 
                                 if (f.startswith("frame") and "." in f and f.split(".")[-1].isdigit()) or
                                    (f.startswith(base_name) and "." in f and f.split(".")[-1].isdigit())]
                    
                    # 如果有帧，重命名为标准格式
                    if all_frames:
                        all_frames.sort()
                        for index, filename in enumerate(all_frames):
                            old_path = os.path.join(output_dir, filename)
                            new_path = os.path.join(output_dir, f"frame{index+1:04d}.png")
                            
                            # 使用PIL转换 - 确保最高质量
                            try:
                                from PIL import Image
                                img = Image.open(old_path)
                                # 保存为最高质量PNG (无压缩)
                                img.save(new_path, "PNG", compress_level=0)
                                os.remove(old_path)  # 删除原始文件
                                frame_count += 1
                            except Exception as e:
                                # 如果PIL不可用，尝试重命名
                                try:
                                    os.rename(old_path, new_path)
                                    frame_count += 1
                                except:
                                    import shutil
                                    shutil.copy2(old_path, new_path)
                                    os.remove(old_path)
                                    frame_count += 1
            except Exception as e:
                print(f"处理gifsicle输出文件时出错: {str(e)}")
            
            progress_dialog.close()
            
            # 检查是否成功转换
            if frame_count > 0:
                # 转换成功，询问用户是否要加载序列帧
                reply = QMessageBox.question(
                    self, 
                    "转换成功", 
                    f"GIF已成功转换为{frame_count}帧序列图像，\n保存在: {output_dir}\n\n是否加载这些序列帧？",
                    QMessageBox.Yes | QMessageBox.No,
                    QMessageBox.Yes
                )
                
                if reply == QMessageBox.Yes:
                    # 打开文件选择对话框，默认指向刚才的目录
                    self.load_seq_from_dir(output_dir)
                
                return True
            else:
                # 如果gifsicle失败，尝试使用ffmpeg
                return self.convertVideoWithFfmpeg(gif_file, output_dir)
                
        except Exception as e:
            QMessageBox.warning(self, "GIF转换错误", f"使用gifsicle转换GIF时出错: {str(e)}")
            # 失败时尝试使用ffmpeg
            return self.convertVideoWithFfmpeg(gif_file, output_dir)
            
    def load_seq_from_dir(self, directory):
        """从指定目录加载序列帧"""
        # 获取当前窗口尺寸
        self.viewer_width = self.ui.viewer.geometry().width()
        self.viewer_height = self.ui.viewer.geometry().height()
        
        # 打开文件选择对话框，默认定位到指定目录
        try:
            fname = list(QFileDialog.getOpenFileNames(
                self, 
                '选择图像序列', 
                directory,  # 默认打开指定目录
                filter="图像文件 (*.jpeg *.jpg *.png *.bmp)"
            ))

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
        try:
            current_frame = int(mxs.currentTime) - self.time_shift
            # 缓存当前帧和周围的几帧
            frames_to_cache = [max(0, current_frame-5), max(0, current_frame-2), 
                              current_frame, 
                              min(self.last_frame-1, current_frame+2), 
                              min(self.last_frame-1, current_frame+5)]
            
            for i in frames_to_cache:
                if i in self.images and i >= 0 and i < self.last_frame:
                    # 缓存缩放图像
                    cache_key = (i, self.viewer_width, self.viewer_height)
                    if cache_key not in self.scaled_images_cache:
                        self.scaled_images_cache[cache_key] = self.images[i].scaled(
                            self.viewer_width, self.viewer_height,
                            QtCore.Qt.KeepAspectRatio,
                            QtCore.Qt.FastTransformation
                        )
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
                        if self.is_playing:
                            scaling_method = QtCore.Qt.FastTransformation
                        else:
                            scaling_method = QtCore.Qt.SmoothTransformation
                        self.pixmap = self.images[ref_frame].scaled(
                            current_width, current_height,
                            QtCore.Qt.KeepAspectRatio,
                            scaling_method
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
        self.ui.btn_converter.setText("♻️")   # 设置齿轮
        
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
        
        # 只清除与新尺寸不匹配的缓存，而不是全部清空
        new_width = self.ui.viewer.geometry().width()
        new_height = self.ui.viewer.geometry().height()
        self.scaled_images_cache = {k: v for k, v in self.scaled_images_cache.items() 
                                  if k[1] == new_width and k[2] == new_height}
        
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
                    QtCore.Qt.SmoothTransformation
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
        • 📂 - 文件夹按钮<br>
        &nbsp;&nbsp;&nbsp;- 打开文件选择器，默认定位到AnimRef_Frame文件夹<br>
        &nbsp;&nbsp;&nbsp;- 可选择并加载序列帧作为动画参考<br>
        • ♻️ - 视频转序列帧转换工具<br>
        &nbsp;&nbsp;&nbsp;- 点击：选择视频文件转为序列帧<br>
        &nbsp;&nbsp;&nbsp;- 右键：打开序列帧文件夹或查看转换工具说明<br>
        &nbsp;&nbsp;&nbsp;- 注意：需要手动下载转换工具到插件目录<br>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• gifsicle.exe - 用于GIF转换<br>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• ffmpeg_lite.exe - 用于MP4和AVI转换<br>
        • 透明度滑块：调整窗口透明度<br><br>
        
        <b>右键菜单：</b><br>
        右键点击窗口可以<br>
        • 最小化/最大化窗口<br>
        • 还原初始大小<br>
        • 打开序列帧文件夹 - 默认打开AnimRef_Frame<br>
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

        # 在updateTimeFromMax方法中添加帧率限制
        self.last_update_time = getattr(self, 'last_update_time', 0)
        current_time = time.time() * 1000  # 转为毫秒
        if current_time - self.last_update_time < 30:  # 至少30ms间隔
            return
        self.last_update_time = current_time

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

    def showConverterContextMenu(self, pos):
        """显示转换器按钮的右键菜单"""
        menu = QMenu(self)
        openDirAction = QAction("打开序列帧文件夹", self)
        openDirAction.triggered.connect(self.openFramesDir)
        menu.addAction(openDirAction)
        
        # 添加下载工具的帮助选项
        menu.addSeparator()
        downloadHelpAction = QAction("下载转换工具说明", self)
        downloadHelpAction.triggered.connect(self.showDownloadHelp)
        menu.addAction(downloadHelpAction)
        
        # 在按钮位置显示菜单
        global_pos = self.ui.btn_converter.mapToGlobal(pos)
        menu.exec(global_pos)
        
    def showDownloadHelp(self):
        """显示下载转换工具的帮助信息"""
        helpText = """
        <b>转换工具下载说明</b><br><br>
        
        AnimRef需要以下工具来转换视频为序列帧：<br><br>
        
        <b>1. gifsicle.exe</b> - 用于处理GIF文件<br>
        • 官方网站：<a href="https://www.lcdf.org/gifsicle/">https://www.lcdf.org/gifsicle/</a><br>
        • Windows版本下载：<a href="https://eternallybored.org/misc/gifsicle/">https://eternallybored.org/misc/gifsicle/</a><br>
        • 推荐使用gifsicle 1.96或更高版本<br>
        • gifsicle提供高品质的GIF分解功能<br><br>
        
        <b>2. ffmpeg_lite.exe</b> - 用于处理MP4和AVI等视频文件<br>
        • 精简版可从各大软件下载站获取<br>
        • 完整版FFmpeg: <a href="https://ffmpeg.org/download.html">https://ffmpeg.org/download.html</a><br>
        • 用于保持原始帧率和质量转换视频<br><br>
        
        <b>安装方法：</b><br>
        1. 下载上述工具<br>
        2. 将文件放置到以下目录：<br>
        <span style="color: #0066cc">{}</span><br>
        3. 重启AnimRef即可使用转换功能<br><br>
        
        <b>推荐参数设置:</b><br>
        • GIF转换时使用--no-extensions减小文件大小<br>
        • 保持视频原始帧率以获得最佳效果<br>
        • 视频帧将输出到AnimRef_Frame文件夹下<br>
        """.format(os.path.join(self.dir, 'AnimRef', 'Contents', 'converter'))
        
        # 创建自定义帮助对话框
        helpDialog = HelpDialog(self)
        helpDialog.setText(helpText)
        helpDialog.exec()

    def ensureGifsicleAvailable(self):
        """确保gifsicle.exe可用，返回其路径"""
        # 检查插件目录中是否有gifsicle.exe
        gifsicle_path = os.path.join(self.dir, 'AnimRef', 'Contents', 'converter', 'gifsicle.exe')
        
        if os.path.exists(gifsicle_path):
            return gifsicle_path
        
        # 如果不存在，提示用户手动下载
        QMessageBox.warning(
            self,
            "缺少GIF处理工具",
            "未找到gifsicle.exe。请手动下载并放置在如下目录：\n" + 
            os.path.join(self.dir, 'AnimRef', 'Contents', 'converter')
        )
        
        return None

    def convertVideoWithFfmpeg(self, video_file, output_dir):
        """使用ffmpeg将视频转换为序列帧"""
        try:
            # 确保ffmpeg_lite.exe可用
            ffmpeg_path = self.ensureFfmpegAvailable()
            if not ffmpeg_path:
                QMessageBox.warning(self, "转换工具缺失", "未找到ffmpeg_lite.exe，无法进行转换。")
                return False
            
            # 进度对话框
            progress_dialog = QMessageBox()
            progress_dialog.setWindowTitle("正在转换")
            progress_dialog.setText(f"正在将 {os.path.basename(video_file)} 转换为序列帧...")
            progress_dialog.setStandardButtons(QMessageBox.NoButton)
            progress_dialog.show()
            QApplication.processEvents()
            
            # 构建转换命令
            output_pattern = os.path.join(output_dir, "frame%04d.png")
            
            # 根据文件类型设置不同的ffmpeg参数
            file_ext = os.path.splitext(video_file)[1].lower()
            if file_ext == '.gif':
                # GIF专用处理参数 - 使用err_detect ignore_err，保持原帧率
                command = f'"{ffmpeg_path}" -err_detect ignore_err -i "{video_file}" -vsync 0 -f image2 "{output_pattern}"'
            else:
                # 普通视频处理 - 保持原帧率，不指定fps
                command = f'"{ffmpeg_path}" -i "{video_file}" -vsync 0 -f image2 "{output_pattern}"'
            
            # 执行命令
            try:
                result = subprocess.run(command, shell=True, check=False, 
                                      stderr=subprocess.PIPE, stdout=subprocess.PIPE)
                progress_dialog.close()
                
                # 检查输出目录中是否有生成的帧
                frame_files = [f for f in os.listdir(output_dir) if f.startswith("frame") and f.endswith(".png")]
                frame_count = len(frame_files)
                
                # 转换成功后显示消息
                if frame_count > 0:
                    # 转换成功，询问用户是否要加载序列帧
                    reply = QMessageBox.question(
                        self, 
                        "转换成功", 
                        f"视频已成功转换为{frame_count}帧序列图像，\n保存在: {output_dir}\n\n是否加载这些序列帧？",
                        QMessageBox.Yes | QMessageBox.No,
                        QMessageBox.Yes
                    )
                    
                    if reply == QMessageBox.Yes:
                        # 打开文件选择对话框，默认指向刚才的目录
                        self.load_seq_from_dir(output_dir)
                        
                    return True
                else:
                    error_output = result.stderr.decode('utf-8', errors='ignore')
                    QMessageBox.warning(
                        self, 
                        "转换失败", 
                        f"无法正确转换文件 {os.path.basename(video_file)}。\n可能是不支持的格式或编码问题。\n\n详细错误:\n{error_output[:300]}..."
                    )
                    return False
            except subprocess.CalledProcessError as e:
                progress_dialog.close()
                QMessageBox.warning(
                    self, 
                    "转换失败", 
                    f"无法转换文件 {os.path.basename(video_file)}。请确保文件格式正确。\n错误信息: {str(e)}"
                )
                return False
        except Exception as e:
            QMessageBox.warning(self, "转换错误", f"转换过程中出错: {str(e)}")
            return False


def main():
    dlg = AnimRef()
    dlg.show()


if __name__ == '__main__':
    main()