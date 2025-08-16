# -*- coding: utf-8 -*-
"""
FBX Viewer for 3ds Max - 全版本兼容（2020-2026+）
在 3ds Max 内嵌入 FBX Review 查看器，支持实时交互和材质显示
"""
import ctypes
import os
import subprocess
import sys
import time
from ctypes import wintypes

try:
    from pymxs import runtime as rt
except ImportError:
    # 兼容老版本 Max
    try:
        import pymxs
        rt = pymxs.runtime
    except ImportError:
        raise RuntimeError("无法导入 pymxs。请确保在 3ds Max 环境中运行此脚本。")

# 兼容 PySide2/PySide6
try:
    from PySide2 import QtCore, QtGui, QtWidgets
    QT_VERSION = "PySide2"
except ImportError:
    try:
        from PySide6 import QtCore, QtGui, QtWidgets
        QT_VERSION = "PySide6"
    except ImportError:
        raise RuntimeError("需要安装 PySide2 或 PySide6。")


# ---------------- Path: 通过 getDir #scripts 生成 fbxreview.exe 绝对路径 ----------------
def get_fbxreview_path():
    """获取 fbxreview.exe 路径，兼容所有 Max 版本"""
    try:
        # 方法1：优先使用 scripts 目录（如你的 animref 一样）
        scripts_dir = rt.getDir(rt.Name('scripts'))
        path = os.path.join(scripts_dir, 'BulletScripts', 'Res', 'fbxreview.exe')
        if os.path.isfile(path):
            return os.path.normpath(path)
        
        # 方法2：回退到 publicExchangeStoreInstallPath（如果 scripts 没有）
        install_dir = rt.getDir(rt.Name('publicExchangeStoreInstallPath'))
        path = os.path.join(install_dir, 'Scripts', 'Res', 'fbxreview.exe')
        if os.path.isfile(path):
            return os.path.normpath(path)
        
        # 方法3：检查当前脚本目录相对路径
        script_dir = os.path.dirname(os.path.abspath(__file__))
        for relative_path in [
            '../../_BsKeyTools/Scripts/Res/fbxreview.exe',
            '../Scripts/Res/fbxreview.exe',
            'Res/fbxreview.exe',
            'fbxreview.exe'
        ]:
            path = os.path.normpath(os.path.join(script_dir, relative_path))
            if os.path.isfile(path):
                return path
        
        # 方法4：在 Max 安装目录查找
        max_root = os.path.dirname(os.path.dirname(rt.getDir(rt.Name('maxroot'))))
        for search_path in [
            os.path.join(max_root, 'Scripts', 'BulletScripts', 'Res', 'fbxreview.exe'),
            os.path.join(max_root, 'plugins', 'BsKeyTools', 'Res', 'fbxreview.exe')
        ]:
            if os.path.isfile(search_path):
                return os.path.normpath(search_path)
        
        # 返回默认路径（即使不存在，让用户看到期望的位置）
        return os.path.normpath(os.path.join(scripts_dir, 'BulletScripts', 'Res', 'fbxreview.exe'))
    
    except Exception as e:
        print(f"获取 FBX Review 路径失败: {e}")
        # 返回一个常见的默认路径
        return r"C:\Program Files\Autodesk\3ds Max 2024\Scripts\BulletScripts\Res\fbxreview.exe"

# --------------------------------------------------------------------------------------
# Win32 API (增强版：包含桌面操作)
# --------------------------------------------------------------------------------------
user32 = ctypes.WinDLL("user32", use_last_error=True)
kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)

# 标准窗口操作
EnumWindows = user32.EnumWindows
EnumWindows.argtypes = [ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM), wintypes.LPARAM]
EnumWindows.restype = wintypes.BOOL

GetWindowThreadProcessId = user32.GetWindowThreadProcessId
GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
GetWindowThreadProcessId.restype = wintypes.DWORD

GetAncestor = user32.GetAncestor
GetAncestor.argtypes = [wintypes.HWND, wintypes.UINT]
GetAncestor.restype = wintypes.HWND
GA_ROOT = 2

SetParent = user32.SetParent
SetParent.argtypes = [wintypes.HWND, wintypes.HWND]
SetParent.restype = wintypes.HWND

ShowWindow = user32.ShowWindow
ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
SW_HIDE, SW_SHOW, SW_SHOWMINNOACTIVE = 0, 5, 7

SetFocus = user32.SetFocus
SetFocus.argtypes = [wintypes.HWND]

SetWindowPos = user32.SetWindowPos
SetWindowPos.argtypes = [wintypes.HWND, wintypes.HWND, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_uint]
SWP_NOSIZE = 0x0001
SWP_NOMOVE = 0x0002
SWP_NOZORDER = 0x0004
SWP_FRAMECHANGED = 0x0020

SendMessageW = user32.SendMessageW
SendMessageW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]
WM_MOUSEWHEEL = 0x020A
WM_MOUSEHWHEEL = 0x020E

# 桌面操作
CreateDesktopW = user32.CreateDesktopW
CreateDesktopW.argtypes = [wintypes.LPCWSTR, wintypes.LPCWSTR, ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p]
CreateDesktopW.restype = wintypes.HANDLE

CloseDesktop = user32.CloseDesktop
CloseDesktop.argtypes = [wintypes.HANDLE]
CloseDesktop.restype = wintypes.BOOL

SetThreadDesktop = user32.SetThreadDesktop
SetThreadDesktop.argtypes = [wintypes.HANDLE]
SetThreadDesktop.restype = wintypes.BOOL

GetThreadDesktop = user32.GetThreadDesktop
GetThreadDesktop.argtypes = [wintypes.DWORD]
GetThreadDesktop.restype = wintypes.HANDLE

GetCurrentThreadId = kernel32.GetCurrentThreadId
GetCurrentThreadId.restype = wintypes.DWORD

SwitchDesktop = user32.SwitchDesktop
SwitchDesktop.argtypes = [wintypes.HANDLE]
SwitchDesktop.restype = wintypes.BOOL

EnumDesktopWindows = user32.EnumDesktopWindows
EnumDesktopWindows.argtypes = [wintypes.HANDLE, ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM), wintypes.LPARAM]
EnumDesktopWindows.restype = wintypes.BOOL

DESKTOP_CREATEWINDOW = 0x0002
DESKTOP_ENUMERATE = 0x0040
DESKTOP_WRITEOBJECTS = 0x0080
DESKTOP_READOBJECTS = 0x0001
GENERIC_ALL = 0x10000000

if ctypes.sizeof(ctypes.c_void_p) == 8:
    GetWindowLongX = user32.GetWindowLongPtrW
    SetWindowLongX = user32.SetWindowLongPtrW
    GetWindowLongX.restype = ctypes.c_longlong
    SetWindowLongX.restype = ctypes.c_longlong
else:
    GetWindowLongX = user32.GetWindowLongW
    SetWindowLongX = user32.SetWindowLongW
    GetWindowLongX.restype = ctypes.c_long
    SetWindowLongX.restype = ctypes.c_long

GWL_STYLE = -16
WS_CHILD      = 0x40000000
WS_POPUP      = 0x80000000
WS_CAPTION    = 0x00C00000
WS_THICKFRAME = 0x00040000
WS_MINIMIZE   = 0x20000000
WS_MAXIMIZE   = 0x01000000
WS_SYSMENU    = 0x00080000

MK_LBUTTON  = 0x0001
MK_RBUTTON  = 0x0002
MK_SHIFT    = 0x0004
MK_CONTROL  = 0x0008
MK_MBUTTON  = 0x0010

PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
OpenProcess = kernel32.OpenProcess
QueryFullProcessImageNameW = kernel32.QueryFullProcessImageNameW
CloseHandle = kernel32.CloseHandle

def get_process_image_path(pid):
    h = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, pid)
    if not h:
        return ""
    try:
        size = wintypes.DWORD(260)
        buf = ctypes.create_unicode_buffer(size.value)
        if QueryFullProcessImageNameW(h, 0, buf, ctypes.byref(size)):
            return buf.value
        return ""
    finally:
        CloseHandle(h)

def enum_desktop_windows(desktop_handle):
    hwnds = []
    @ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
    def cb(hwnd, lParam):
        hwnds.append(hwnd)
        return True
    EnumDesktopWindows(desktop_handle, cb, 0)
    return hwnds

def enum_top_level_windows():
    hwnds = []
    @ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
    def cb(hwnd, lParam):
        hwnds.append(hwnd)
        return True
    EnumWindows(cb, 0)
    return hwnds

def get_root_windows_by_pid(pid, desktop_handle=None):
    out = []
    if desktop_handle:
        windows = enum_desktop_windows(desktop_handle)
    else:
        windows = enum_top_level_windows()
    
    for hwnd in windows:
        lpdwProcessId = wintypes.DWORD()
        GetWindowThreadProcessId(hwnd, ctypes.byref(lpdwProcessId))
        if lpdwProcessId.value == pid:
            root = GetAncestor(hwnd, GA_ROOT)
            if root == hwnd:
                out.append(hwnd)
    return out

def find_fbxreview_in_desktop(desktop_handle, target_pid=None):
    windows = enum_desktop_windows(desktop_handle)
    for hwnd in windows:
        lpdwProcessId = wintypes.DWORD()
        GetWindowThreadProcessId(hwnd, ctypes.byref(lpdwProcessId))
        pid = lpdwProcessId.value
        
        # 优先匹配目标PID
        if target_pid and pid == target_pid:
            root = GetAncestor(hwnd, GA_ROOT)
            if root == hwnd:
                return hwnd
        
        # 兜底：任何fbxreview.exe
        exe = get_process_image_path(pid).lower()
        if exe.endswith("\\fbxreview.exe"):
            root = GetAncestor(hwnd, GA_ROOT)
            if root == hwnd:
                return hwnd
    return None

def make_child_style(hwnd):
    style = GetWindowLongX(hwnd, GWL_STYLE)
    style &= ~(WS_POPUP | WS_CAPTION | WS_THICKFRAME | WS_MINIMIZE | WS_MAXIMIZE | WS_SYSMENU)
    style |= WS_CHILD
    SetWindowLongX(hwnd, GWL_STYLE, style)
    SetWindowPos(hwnd, None, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED)

def make_wheel_wparam(delta, qt_buttons, qt_mods):
    flags = 0
    if qt_buttons & QtCore.Qt.LeftButton:
        flags |= MK_LBUTTON
    if qt_buttons & QtCore.Qt.RightButton:
        flags |= MK_RBUTTON
    if qt_buttons & QtCore.Qt.MidButton:
        flags |= MK_MBUTTON
    if qt_mods & QtCore.Qt.ShiftModifier:
        flags |= MK_SHIFT
    if qt_mods & QtCore.Qt.ControlModifier:
        flags |= MK_CONTROL
    hi = ctypes.c_short(delta).value & 0xFFFF
    lo = flags & 0xFFFF
    return (hi << 16) | lo

def make_lparam_from_point(global_qpoint):
    x = ctypes.c_short(global_qpoint.x()).value & 0xFFFF
    y = ctypes.c_short(global_qpoint.y()).value & 0xFFFF
    return (y << 16) | x

# --------------------------------------------------------------------------------------
# 不可见桌面管理器
# --------------------------------------------------------------------------------------
class InvisibleDesktop:
    def __init__(self):
        self.desktop_handle = None
        self.original_desktop = None
        
    def create(self):
        """创建不可见桌面"""
        try:
            # 保存当前桌面
            self.original_desktop = GetThreadDesktop(GetCurrentThreadId())
            
            # 创建新的隐藏桌面
            desktop_name = f"BsFbxHidden_{int(time.time())}"
            self.desktop_handle = CreateDesktopW(
                desktop_name, None, None, 0,
                DESKTOP_CREATEWINDOW | DESKTOP_ENUMERATE | DESKTOP_WRITEOBJECTS | DESKTOP_READOBJECTS,
                None
            )
            return self.desktop_handle is not None
        except Exception:
            return False
    
    def switch_to_hidden(self):
        """切换到隐藏桌面"""
        if self.desktop_handle:
            return SetThreadDesktop(self.desktop_handle)
        return False
    
    def switch_to_original(self):
        """切换回原桌面"""
        if self.original_desktop:
            return SetThreadDesktop(self.original_desktop)
        return False
    
    def cleanup(self):
        """清理桌面资源"""
        if self.original_desktop:
            SetThreadDesktop(self.original_desktop)
        if self.desktop_handle:
            CloseDesktop(self.desktop_handle)
            self.desktop_handle = None

# --------------------------------------------------------------------------------------
# Qt 容器（拦截滚轮并转发）
# --------------------------------------------------------------------------------------
class WinEmbedArea(QtWidgets.QWidget):
    resized = QtCore.Signal()
    clicked = QtCore.Signal()
    wheelForward = QtCore.Signal(int, QtCore.QPoint, bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setAttribute(QtCore.Qt.WA_NativeWindow, True)
        self.setFocusPolicy(QtCore.Qt.StrongFocus)
        self.setMouseTracking(True)
        self.setMinimumSize(240, 160)
        self.setStyleSheet("background:#202020;")

    def resizeEvent(self, e):
        super().resizeEvent(e)
        self.resized.emit()

    def mousePressEvent(self, e):
        self.clicked.emit()
        super().mousePressEvent(e)

    def wheelEvent(self, e):
        ad = e.angleDelta()
        delta_v = ad.y()
        delta_h = ad.x()
        if delta_v != 0:
            self.wheelForward.emit(delta_v, e.globalPos(), False)
            e.accept()
            return
        if delta_h != 0:
            self.wheelForward.emit(delta_h, e.globalPos(), True)
            e.accept()
            return
        super().wheelEvent(e)

    def enterEvent(self, e):
        self.clicked.emit()
        super().enterEvent(e)

# --------------------------------------------------------------------------------------
# 主窗口
# --------------------------------------------------------------------------------------
def get_max_version():
    """获取 3ds Max 版本号"""
    try:
        version_info = rt.maxversion()
        if hasattr(version_info, '__getitem__') and len(version_info) >= 1:
            return version_info[0]  # 主版本号
        else:
            return int(str(version_info))
    except Exception:
        return 2024  # 默认版本

def get_max_parent_widget():
    """获取 Max 主窗口，兼容所有版本"""
    try:
        # 方法1：使用 qtmax（较新版本）
        import qtmax
        parent = qtmax.GetQMaxMainWindow()
        if parent:
            return parent
    except ImportError:
        pass
    except Exception:
        pass
    
    try:
        # 方法2：直接从 Max HWND 创建 QWidget（兼容老版本）
        max_hwnd = rt.windows.getMAXHWND()
        if max_hwnd and QT_VERSION == "PySide2":
            return QtWidgets.QWidget.find(max_hwnd)
        elif max_hwnd and QT_VERSION == "PySide6":
            # PySide6 的方法稍有不同
            from shiboken6 import wrapInstance
            return wrapInstance(int(max_hwnd), QtWidgets.QWidget)
    except Exception as e:
        print(f"获取 Max 主窗口失败: {e}")
    
    # 方法3：返回 None（独立窗口）
    return None

class FbxReviewEmbedder(QtWidgets.QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # 版本信息
        self.max_version = get_max_version()
        self.qt_version = QT_VERSION
        
        self.setWindowTitle(f"FBX Viewer (Max {self.max_version}, {self.qt_version})")
        self.resize(1200, 800)
        
        # 初始化路径和进程
        self.fbxreview_path = get_fbxreview_path()
        self.process = None
        self._child_hwnd = None
        self.current_file = None
        self.invisible_desktop = InvisibleDesktop()
        
        # 构建 UI
        self._build_ui()
        self._verify_fbxreview()
        
        # 连接应用状态变化（PySide2/6 兼容）
        try:
            app = QtWidgets.QApplication.instance()
            if app and hasattr(app, 'applicationStateChanged'):
                app.applicationStateChanged.connect(self._on_app_state_changed)
        except Exception as e:
            print(f"连接应用状态变化失败: {e}")
        
        print(f"FBX Viewer 初始化完成 - Max {self.max_version}, {self.qt_version}")
        print(f"FBX Review 路径: {self.fbxreview_path}")
        print(f"路径存在: {os.path.isfile(self.fbxreview_path)}")

    def _build_ui(self):
        central = QtWidgets.QWidget(self)
        self.setCentralWidget(central)
        vbox = QtWidgets.QVBoxLayout(central)
        vbox.setContentsMargins(6,6,6,6)
        vbox.setSpacing(6)

        bar = QtWidgets.QHBoxLayout()
        btn_open = QtWidgets.QPushButton("打开 FBX")
        btn_reload = QtWidgets.QPushButton("重新加载")
        btn_detach = QtWidgets.QPushButton("外部打开")
        btn_close = QtWidgets.QPushButton("关闭查看器")
        btn_open.clicked.connect(self.open_fbx_dialog)
        btn_reload.clicked.connect(self.reload_current)
        btn_detach.clicked.connect(self.open_external)
        btn_close.clicked.connect(self.close_viewer)
        bar.addWidget(btn_open)
        bar.addWidget(btn_reload)
        bar.addStretch(1)
        bar.addWidget(btn_detach)
        bar.addWidget(btn_close)
        vbox.addLayout(bar)

        self.embedArea = WinEmbedArea(self)
        vbox.addWidget(self.embedArea, 1)
        self.embedArea.resized.connect(self._resize_child)
        self.embedArea.clicked.connect(self._focus_child)
        self.embedArea.wheelForward.connect(self._forward_wheel_to_child)

        self.statusBar().showMessage("准备就绪")

    def _verify_fbxreview(self):
        """验证 FBX Review 可执行文件，提供版本特定的帮助"""
        if not os.path.isfile(self.fbxreview_path):
            # 根据 Max 版本提供不同的帮助信息
            if self.max_version >= 2026:
                help_text = (
                    f"未找到 FBX Review 可执行文件。\n\n"
                    f"路径: {self.fbxreview_path}\n\n"
                    f"对于 3ds Max {self.max_version}，请确保：\n"
                    f"1. FBX Review 已正确安装\n"
                    f"2. 路径指向正确的可执行文件\n"
                    f"3. 或将 fbxreview.exe 放置在上述路径中"
                )
            else:
                help_text = (
                    f"未找到 FBX Review 可执行文件。\n\n"
                    f"当前路径: {self.fbxreview_path}\n"
                    f"Max 版本: {self.max_version}\n\n"
                    f"请检查 FBX Review 是否已安装，或将 fbxreview.exe 放在正确位置。"
                )
            
            QtWidgets.QMessageBox.warning(self, "找不到 FBX Review", help_text)

    # ---- 按钮 ----
    def open_fbx_dialog(self):
        fp, _ = QtWidgets.QFileDialog.getOpenFileName(
            self, "选择 FBX", os.path.expanduser("~"), "FBX Files (*.fbx);;All Files (*.*)"
        )
        if fp:
            self.load_file(fp)

    def reload_current(self):
        if not self.current_file:
            self.statusBar().showMessage("没有已加载的文件")
            return
        self.load_file(self.current_file)

    def open_external(self):
        if not self.current_file:
            self.open_fbx_dialog()
            return
        subprocess.Popen([self.fbxreview_path, self.current_file], shell=False)
        self.statusBar().showMessage("已在外部打开")

    def close_viewer(self):
        self._teardown()
        self.close()

    # ---- 无闪现加载流程 ----
    def load_file(self, file_path):
        if not os.path.isfile(file_path):
            QtWidgets.QMessageBox.warning(self, "文件不存在", file_path)
            return
        if not os.path.isfile(self.fbxreview_path):
            QtWidgets.QMessageBox.warning(self, "找不到 fbxreview.exe", self.fbxreview_path)
            return

        self.current_file = file_path
        self.statusBar().showMessage(f"加载：{file_path}")
        self._teardown()

        # 方案1：隐藏桌面启动（彻底无闪现）
        hwnd = self._try_invisible_desktop_launch()
        if hwnd:
            self._embed(hwnd)
            return

        # 方案2：隐藏启动回退
        if self._start_fbxreview("hidden"):
            hwnd = self._wait_and_find_hwnd(timeout_sec=12.0)
            if hwnd:
                self._embed(hwnd)
                return
            self._kill_process()

        # 方案3：最小化启动
        if self._start_fbxreview("minimized"):
            hwnd = self._wait_and_find_hwnd(timeout_sec=8.0)
            if hwnd:
                self._embed(hwnd)
                return
            self._kill_process()

        QtWidgets.QMessageBox.warning(self, "嵌入失败", "未能获取 FBX Review 窗口，将外部打开。")
        self.open_external()

    def _try_invisible_desktop_launch(self):
        """在不可见桌面启动，彻底无闪现"""
        try:
            # 创建隐藏桌面
            if not self.invisible_desktop.create():
                return None

            # 临时切换到隐藏桌面启动进程
            original_switched = self.invisible_desktop.switch_to_hidden()
            if not original_switched:
                return None

            # 在隐藏桌面启动FBX Review
            success = self._start_fbxreview("normal")  # 在隐藏桌面可以用normal
            
            # 立即切换回主桌面
            self.invisible_desktop.switch_to_original()
            
            if not success:
                return None

            # 等待窗口在隐藏桌面创建
            time.sleep(0.5)  # 给进程时间初始化
            
            # 在隐藏桌面寻找窗口
            hwnd = find_fbxreview_in_desktop(self.invisible_desktop.desktop_handle, self.process.pid)
            if not hwnd:
                # 多等一会儿
                for _ in range(20):  # 最多等2秒
                    time.sleep(0.1)
                    hwnd = find_fbxreview_in_desktop(self.invisible_desktop.desktop_handle, self.process.pid)
                    if hwnd:
                        break

            if hwnd:
                # 找到了！把窗口从隐藏桌面移到主桌面（通过SetParent到我们的容器）
                return hwnd

            return None
            
        except Exception as e:
            self.statusBar().showMessage(f"隐藏桌面方案失败: {e}")
            return None

    def _start_fbxreview(self, mode="hidden"):
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            if mode == "hidden":
                si.wShowWindow = SW_HIDE
            elif mode == "minimized":
                si.wShowWindow = SW_SHOWMINNOACTIVE
            else:
                si.wShowWindow = SW_SHOW
            self.process = subprocess.Popen([self.fbxreview_path, self.current_file], shell=False, startupinfo=si)
            return True
        except Exception as exc:
            QtWidgets.QMessageBox.critical(self, "启动失败", str(exc))
            self.process = None
            return False

    def _wait_and_find_hwnd(self, timeout_sec=10.0):
        deadline = time.time() + timeout_sec
        while time.time() < deadline:
            if self.process:
                wins = get_root_windows_by_pid(self.process.pid)
                if wins:
                    return wins[0]
            time.sleep(0.05)
        return None

    # ---- 嵌入/尺寸/焦点/滚轮转发 ----
    def _embed(self, child_hwnd):
        container_hwnd = int(self.embedArea.winId())
        SetParent(child_hwnd, container_hwnd)
        make_child_style(child_hwnd)
        self._child_hwnd = child_hwnd
        self._resize_child()
        ShowWindow(child_hwnd, SW_SHOW)
        self._focus_child()
        self.statusBar().showMessage(f"已加载：{os.path.basename(self.current_file)}")

    def _resize_child(self):
        if not self._child_hwnd:
            return
        w = max(1, self.embedArea.width())
        h = max(1, self.embedArea.height())
        SetWindowPos(self._child_hwnd, None, 0, 0, w, h, SWP_NOZORDER)

    def _focus_child(self):
        if self._child_hwnd:
            SetFocus(self._child_hwnd)

    def _forward_wheel_to_child(self, delta, global_pos, is_horizontal):
        if not self._child_hwnd:
            return
        step = 120
        if delta == 0:
            return
        delta_norm = int(round(delta / step)) * step
        wparam = make_wheel_wparam(delta_norm, QtWidgets.QApplication.mouseButtons(), QtWidgets.QApplication.keyboardModifiers())
        lparam = make_lparam_from_point(global_pos)
        msg = WM_MOUSEHWHEEL if is_horizontal else WM_MOUSEWHEEL
        SendMessageW(self._child_hwnd, msg, wparam, lparam)

    def _on_app_state_changed(self, state):
        if state == QtCore.Qt.ApplicationActive:
            self._focus_child()

    def focusInEvent(self, e):
        super().focusInEvent(e)
        self._focus_child()

    # ---- 清理 ----
    def _kill_process(self):
        if self.process:
            try:
                self.process.terminate()
                self.process.wait(timeout=2.0)
            except Exception:
                try:
                    self.process.kill()
                except Exception:
                    pass
        self.process = None

    def _teardown(self):
        self._child_hwnd = None
        self._kill_process()
        self.invisible_desktop.cleanup()

    def closeEvent(self, e):
        self._teardown()
        super().closeEvent(e)

# --------------------------------------------------------------------------------------
# 入口
# --------------------------------------------------------------------------------------
_FBXR_WIN = None

def show_fbx_viewer():
    """显示 FBX 查看器，兼容所有 Max 版本"""
    app = QtWidgets.QApplication.instance()
    if app is None:
        raise RuntimeError("请在 3ds Max 内运行此脚本。")
    
    # 获取 Max 主窗口作为父窗口
    parent = get_max_parent_widget()
    
    global _FBXR_WIN
    if _FBXR_WIN is None:
        try:
            _FBXR_WIN = FbxReviewEmbedder(parent=parent)
        except Exception as e:
            print(f"创建 FBX 查看器失败: {e}")
            # 尝试无父窗口创建
            try:
                _FBXR_WIN = FbxReviewEmbedder(parent=None)
                print("已创建独立窗口模式的 FBX 查看器")
            except Exception as e2:
                raise RuntimeError(f"无法创建 FBX 查看器: {e2}")
    
    # 显示窗口
    try:
        _FBXR_WIN.show()
        _FBXR_WIN.raise_()
        _FBXR_WIN.activateWindow()
        
        # 版本信息提示
        max_ver = get_max_version()
        print(f"FBX Viewer 已启动 - 3ds Max {max_ver} ({QT_VERSION})")
        
        return _FBXR_WIN
    except Exception as e:
        print(f"显示 FBX 查看器失败: {e}")
        raise

def main():
    """主入口函数"""
    return show_fbx_viewer()

if __name__ == "__main__":
    main()
else:
    # 自动启动（当作为模块导入时）
    try:
        show_fbx_viewer()
    except Exception as e:
        print(f"自动启动 FBX 查看器失败: {e}")
        print("请手动调用 show_fbx_viewer() 函数")