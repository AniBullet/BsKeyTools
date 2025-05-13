import os
import subprocess
import urllib.request

from pymxs import runtime as mxs
from PySide6 import QtCore, QtGui
from PySide6.QtCore import QFile
from PySide6.QtGui import QColor, QIcon
from PySide6.QtUiTools import QUiLoader
from PySide6.QtWidgets import (
    QApplication,
    QDialog,
    QFileDialog,
    QLabel,
    QMessageBox,
    QPushButton,
    QSizePolicy,
    QVBoxLayout,
    QWidget,
)


class AnimRef(QDialog):
    def __init__(self, parent=QWidget.find(mxs.windows.getMAXHWND())):
        QDialog.__init__(self, parent)

        self.init()

        self.setWindowFlags(QtCore.Qt.WindowType.Window)
        self.resize(720, 460)
        self.setWindowTitle("AnimRef v1.5.2")
        self.setObjectName("AnimRefTool")

        self.defineVariables()
        self.defineSignals()
        self.defineIcons()
        self.start()

        self.setWindowIcon(self.icon)

        self.timer = QtCore.QTimer(self)

    def downloadConverter(self):

        converter_path = os.path.join(self.dir, 'ApplicationPlugins', 'AnimRef', 'Contents', 'converter',
                                      'video_to_sequence.exe')
        download_path = "https://raw.githubusercontent.com/ShirzadBh/AnimRef/main/AnimRef/Contents/converter/video_to_sequence.exe"

        try:
            urllib.request.urlretrieve(download_path, converter_path)
            self.ui.state.setStyleSheet('''color : #98fc03;
                font-size: 12px;
                font-family:"Comic Sans MS", cursive, sans-serif;''')

            self.ui.state.setText("video_to_sequence.exe is ready!")
            self.time_counting = True
            self.startTime()
        except:
            self.ui.state.setStyleSheet('''color : #fc5203;
                font-size: 12px;
                font-family:"Comic Sans MS", cursive, sans-serif;''')

            self.ui.state.setText("Download failed...")
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
        self.ui.state.clear()
        self.timer.stop()
        self.time_counting = False

    def init(self):

        self.dir = mxs.getDir(mxs.name('publicExchangeStoreInstallPath'))
        loader = QUiLoader()
        ui_file_path = os.path.join(self.dir, 'AnimRef', 'Contents', 'interface', 'interface.ui')
        ui_file = QFile(ui_file_path)
        ui_file.open(QFile.ReadOnly)
        self.ui = loader.load(ui_file, self)
        ui_file.close()
        layout = QVBoxLayout()
        layout.addWidget(self.ui)
        layout.setContentsMargins(4, 4, 4, 4)
        self.setLayout(layout)

    def start(self):
        self.ui.viewer.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
        self.pixmap = self.no_image.scaled(400, 200, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation)
        self.ui.viewer.setPixmap(self.pixmap)
        mxs.registerTimeCallback(self.changeTime)

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
        self.no_image = QtGui.QPixmap(
            os.path.join(os.path.dirname(os.path.realpath(__file__)) + "\\icons\\no_data.png"))

    def defineSignals(self):
        self.ui.btn_converter.clicked.connect(self.convertedExist)

        # self.ui.timeSlider.valueChanged.connect(self.goToFrame)
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

        elif not mxs.isAnimPlaying():
            self.ui.sb_time_shift.setEnabled(False)
            mxs.playAnimation()

    def startFrame(self):
        # mxs.execute("max time start")
        mxs.stopAnimation()
        mxs.sliderTime = self.time_shift
        self.ui.btn_play.setIcon(self.play_icon)
        self.ui.btn_play.setChecked(False)
        self.ui.sb_time_shift.setEnabled(True)

    def endFrame(self):
        # mxs.execute("max time end")
        mxs.stopAnimation()
        mxs.sliderTime = self.time_shift + (self.last_frame - 1)
        self.ui.btn_play.setIcon(self.play_icon)
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
                self.ui.btn_play.setEnabled(True)
                self.ui.btn_s_frame.setEnabled(True)
                self.ui.btn_p_frame.setEnabled(True)
                self.ui.btn_n_frame.setEnabled(True)
                self.ui.btn_e_frame.setEnabled(True)
                self.ui.sb_time_shift.setEnabled(True)
                self.ui.btn_loop.setEnabled(True)
                self.status_1()
                self.changeTime()

            else:
                self.status_3()
                self.changeTime()

        except:
            self.status_3()
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
            except:
                out = True
                is_playing = mxs.isAnimPlaying()
                if self.isLoaded and not self.ui.btn_loop.isChecked():
                    self.status_2()

                if self.isLoaded:

                    if self.ui.btn_loop.isChecked():
                        mxs.stopAnimation()
                        mxs.sliderTime = self.time_shift
                        if is_playing and out:
                            mxs.playAnimation()
                self.out_of_range = True

    def defineIcons(self):
        self.icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'icon.png'))
        self.play_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'play.png'))
        self.n_frame_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'n_frame.png'))
        self.p_frame_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'p_frame.png'))
        self.s_frame_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 's_frame.png'))
        self.e_frame_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'e_frame.png'))
        self.load_images_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'load_images.png'))
        self.loop_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'loop.png'))
        self.pause_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'pause.png'))
        self.seq_icon = QtGui.QIcon(
            os.path.join(self.dir, 'AnimRef', 'Contents', 'icons', 'seq.png'))

        self.ui.btn_play.setIcon(self.play_icon)
        self.ui.btn_n_frame.setIcon(self.n_frame_icon)
        self.ui.btn_p_frame.setIcon(self.p_frame_icon)
        self.ui.btn_s_frame.setIcon(self.s_frame_icon)
        self.ui.btn_e_frame.setIcon(self.e_frame_icon)
        self.ui.btn_load_seq.setIcon(self.load_images_icon)
        self.ui.btn_loop.setIcon(self.loop_icon)
        self.ui.btn_converter.setIcon(self.seq_icon)

    def wheelEvent(self, event):
        if self.isLoaded:
            mxs.sliderTime += (event.angleDelta().y() / 120)

    def resizeEvent(self, event):
        self.updateFrame()
        self.changeTime()

    def closeEvent(self, event):
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

    def status_1(self):
        self.ui.state.clear()
        self.ui.state.setStyleSheet('''color : #98fc03;
            font-size: 12px;
            font-family:"Comic Sans MS", cursive, sans-serif;''')

        self.ui.state.setText(f"{self.last_frame} images were imported")
        self.time_counting = True
        self.startTime()

    def status_2(self):
        self.ui.state.clear()
        self.ui.state.setStyleSheet('''color : #fcbe03;
            font-size: 12px;
            font-family:"Comic Sans MS", cursive, sans-serif;''')

        self.ui.state.setText(f"Out of range")
        self.time_counting = True
        self.startTime()

    def status_3(self):
        self.ui.state.clear()
        self.ui.state.setStyleSheet('''color : #fc5203;
            font-size: 12px;
            font-family:"Comic Sans MS", cursive, sans-serif;''')

        self.ui.state.setText(f"Import was canceled")
        self.time_counting = True
        self.startTime()


def main():
    # 查找并关闭所有可能存在的AnimRef窗口
    for widget in QApplication.topLevelWidgets():
        if widget.objectName() == "AnimRefTool" and widget.isVisible():
            try:
                widget.close()
            except:
                pass
    
    # 创建新实例
    dlg = AnimRef()
    dlg.show()


if __name__ == '__main__':
    main()
