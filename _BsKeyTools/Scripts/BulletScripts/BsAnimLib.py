"""
FBX Viewer for 3ds Max - 全版本兼容（2020-2026+）
在 3ds Max 内嵌入 FBX Review 查看器，支持实时交互和材质显示
"""
from __future__ import unicode_literals

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
    """获取 FBX Review 可执行文件路径"""
    try:
        # 尝试从环境变量获取
        env_path = os.environ.get('FBXREVIEW_PATH')
        if env_path and os.path.isfile(env_path):
            return env_path
        
        # 尝试常见安装路径
        common_paths = [
            r"C:\Program Files\Autodesk\FBX\FBX Review\fbxreview.exe",
            r"C:\Program Files (x86)\Autodesk\FBX\FBX Review\fbxreview.exe",
            r"C:\Program Files\Autodesk\3ds Max 2026\bin\fbxreview.exe",
            r"C:\Program Files\Autodesk\3ds Max 2025\bin\fbxreview.exe",
            r"C:\Program Files\Autodesk\3ds Max 2024\bin\fbxreview.exe",
            r"C:\Program Files\Autodesk\3ds Max 2023\bin\fbxreview.exe",
            r"C:\Program Files\Autodesk\3ds Max 2022\bin\fbxreview.exe",
            r"C:\Program Files\Autodesk\3ds Max 2021\bin\fbxreview.exe",
            r"C:\Program Files\Autodesk\3ds Max 2020\bin\fbxreview.exe",
        ]
        
        for path in common_paths:
            if os.path.isfile(path):
                return path
        
        # 尝试从Max脚本目录获取
        try:
            import pymxs
            rt = pymxs.runtime
            scripts_dir = rt.getDir(rt.Name("scripts"))
            local_path = os.path.join(scripts_dir, "BulletScripts", "Res", "fbxreview.exe")
            if os.path.isfile(local_path):
                return local_path
        except:
            pass
        
        # 如果都找不到，返回默认路径
        return r"C:\Program Files\Autodesk\FBX\FBX Review\fbxreview.exe"
        
    except Exception as e:
        # 返回默认路径
        return r"C:\Program Files\Autodesk\FBX\FBX Review\fbxreview.exe"

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
# HWND/WinId 兼容获取（处理 PyCObject/PyCapsule）
# --------------------------------------------------------------------------------------
def _to_hwnd_int(win_id_obj):
    """将 Qt 的 winId 对象安全转换为 HWND(int)，兼容 PySide/PySide2/PySide6 与 Py2/3。"""
    try:
        return int(win_id_obj)
    except Exception:
        pass
    # 尝试 __int__ 方法
    try:
        if hasattr(win_id_obj, '__int__'):
            return int(win_id_obj.__int__())
    except Exception:
        pass
    # PyCapsule (Python3)
    try:
        _py = ctypes.pythonapi
        _py.PyCapsule_GetPointer.restype = ctypes.c_void_p
        _py.PyCapsule_GetPointer.argtypes = [ctypes.py_object, ctypes.c_char_p]
        ptr = _py.PyCapsule_GetPointer(win_id_obj, None)
        if ptr:
            return int(ctypes.c_void_p(ptr).value)
    except Exception:
        pass
    # PyCObject (Python2)
    try:
        _py = ctypes.pythonapi
        _py.PyCObject_AsVoidPtr.restype = ctypes.c_void_p
        _py.PyCObject_AsVoidPtr.argtypes = [ctypes.py_object]
        ptr = _py.PyCObject_AsVoidPtr(win_id_obj)
        if ptr:
            return int(ctypes.c_void_p(ptr).value)
    except Exception:
        pass
    raise TypeError("无法从 winId 提取有效的 HWND")

def _get_hwnd_from_widget(widget):
    try:
        win_id = widget.winId()
        return _to_hwnd_int(win_id)
    except Exception:
        # 最后尝试 windowHandle 获取
        try:
            handle = widget.windowHandle()
            if handle and hasattr(handle, 'winId'):
                return _to_hwnd_int(handle.winId())
        except Exception:
            pass
    return None

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
            desktop_name = "BsFbxHidden_%d" % int(time.time())
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
    # wheelForward 信号已移除，使用直接事件转发

    def __init__(self, parent=None):
        QtWidgets.QWidget.__init__(self, parent)
        self.setAttribute(QtCore.Qt.WA_NativeWindow, True)
        self.setFocusPolicy(QtCore.Qt.StrongFocus)
        self.setMouseTracking(True)
        self.setMinimumSize(240, 160)
        self.setStyleSheet("background:#202020;")

    def resizeEvent(self, e):
        QtWidgets.QWidget.resizeEvent(self, e)
        self.resized.emit()

    def mousePressEvent(self, e):
        self.clicked.emit()
        QtWidgets.QWidget.mousePressEvent(self, e)

    def wheelEvent(self, e):
        """处理滚轮事件，转发给嵌入的FBX Review窗口"""
        try:
            # 获取滚轮数据
            ad = e.angleDelta()
            delta_v = ad.y()
            delta_h = ad.x()
            
            # 如果有父窗口，尝试转发滚轮事件
            if hasattr(self, 'parent') and self.parent():
                try:
                    # 转发给父窗口处理
                    self.parent().wheelEvent(e)
                    return
                except Exception as parent_error:
                    # 如果转发失败，尝试直接处理
                    self._handle_wheel_directly(delta_v, delta_h)
            else:
                # 没有父窗口，直接处理
                self._handle_wheel_directly(delta_v, delta_h)
            
            # 接受事件，避免传播
            e.accept()
            
        except Exception as e:
            e.accept()
    
    def _handle_wheel_directly(self, delta_v, delta_h):
        """直接处理滚轮事件"""
        try:
            # 如果有嵌入的FBX Review窗口，尝试直接发送消息
            if hasattr(self, 'parent') and self.parent():
                parent = self.parent()
                if hasattr(parent, '_child_hwnd') and parent._child_hwnd:
                    # 尝试直接调用父窗口的滚轮处理方法
                    if hasattr(parent, '_send_wheel_message'):
                        mouse_pos = QtWidgets.QApplication.mouse().pos()
                        if delta_v != 0:
                            parent._send_wheel_message(parent._child_hwnd, delta_v, mouse_pos, False)
                        if delta_h != 0:
                            parent._send_wheel_message(parent._child_hwnd, delta_h, mouse_pos, True)
        except Exception as e:
            pass

    def enterEvent(self, e):
        self.clicked.emit()
        QtWidgets.QWidget.enterEvent(self, e)

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
        pass
    
    # 方法3：返回 None（独立窗口）
    return None

class FbxReviewEmbedder(QtWidgets.QMainWindow):
    def __init__(self, parent=None):
        QtWidgets.QMainWindow.__init__(self, parent)
        
        # 版本信息
        self.max_version = get_max_version()
        self.qt_version = QT_VERSION
        
        self.setWindowTitle("FBX Viewer (Max %s, %s)" % (self.max_version, self.qt_version))
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
            pass
        
        # 设置窗口属性，确保能接收滚轮事件
        self.setAttribute(QtCore.Qt.WA_AlwaysShowToolTips)
        self.setFocusPolicy(QtCore.Qt.StrongFocus)
        self.setMouseTracking(True)
        
        # 添加定时器来定期检查滚轮事件处理
        self.wheel_check_timer = QtCore.QTimer()
        self.wheel_check_timer.timeout.connect(self._check_wheel_handling)
        self.wheel_check_timer.start(5000)  # 每5秒检查一次
        
        # 添加窗口销毁时的清理回调
        self.destroyed.connect(self._on_destroyed)

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
        
        # 滚轮事件现在直接在主窗口处理，不需要转发函数
        
        self.statusBar().showMessage("准备就绪")
        # 状态栏忙碌指示器（不确定进度时使用不确定进度条）
        try:
            self._busy = QtWidgets.QProgressBar()
            self._busy.setRange(0, 0)
            self._busy.setFixedWidth(120)
            self._busy.hide()
            self.statusBar().addPermanentWidget(self._busy)
        except Exception:
            self._busy = None

    def wheelEvent(self, e):
        """主窗口滚轮事件处理，确保滚轮事件能传递到嵌入窗口"""
        try:
            # 获取滚轮数据
            ad = e.angleDelta()
            delta_v = ad.y()
            delta_h = ad.x()
            
            # 如果有嵌入的FBX Review窗口，转发滚轮事件
            if hasattr(self, '_child_hwnd') and self._child_hwnd:
                try:
                    # 使用Windows API直接发送滚轮消息到嵌入窗口
                    if delta_v != 0:
                        self._send_wheel_message(self._child_hwnd, delta_v, self._get_global_pos(e), False)
                    if delta_h != 0:
                        self._send_wheel_message(self._child_hwnd, delta_h, self._get_global_pos(e), True)
                    
                    # 接受事件，避免传播
                    e.accept()
                    return
                except Exception as wheel_error:
                    pass
            
            # 如果没有嵌入窗口或转发失败，接受事件避免传播
            e.accept()
            
        except Exception as e:
            e.accept()
    
    def _get_global_pos(self, wheel_event):
        """获取滚轮事件的全局位置，兼容PySide2和PySide6"""
        try:
            # 尝试PySide6的方法
            if hasattr(wheel_event, 'globalPosition'):
                return wheel_event.globalPosition()
            # 尝试PySide2的方法
            elif hasattr(wheel_event, 'globalPos'):
                return wheel_event.globalPos()
            # 备用方案：使用当前鼠标位置
            else:
                return QtWidgets.QApplication.mouse().pos()
        except Exception as e:
            # 最后的备用方案
            return QtWidgets.QApplication.mouse().pos()
    
    def _send_wheel_message(self, hwnd, delta, global_pos, is_horizontal):
        """使用Windows API发送滚轮消息"""
        try:
            # 导入必要的Windows API
            import ctypes

            # Windows消息常量
            WM_MOUSEWHEEL = 0x020A
            WM_MOUSEHWHEEL = 0x020E
            
            # 获取鼠标按钮和键盘修饰符状态
            buttons = QtWidgets.QApplication.mouseButtons()
            modifiers = QtWidgets.QApplication.keyboardModifiers()
            
            # 构建wParam
            wparam = 0
            if delta > 0:
                wparam |= 0x00780000  # WHEEL_DELTA = 120
            else:
                wparam |= 0xFF880000  # 负值
            
            # 添加按钮状态
            if buttons & QtCore.Qt.LeftButton:
                wparam |= 0x0001
            if buttons & QtCore.Qt.RightButton:
                wparam |= 0x0002
            if buttons & QtCore.Qt.MiddleButton:
                wparam |= 0x0010
            
            # 添加键盘修饰符
            if modifiers & QtCore.Qt.ShiftModifier:
                wparam |= 0x0004
            if modifiers & QtCore.Qt.ControlModifier:
                wparam |= 0x0008
            
            # 构建lParam（屏幕坐标），兼容不同Qt版本
            try:
                # 尝试获取坐标
                if hasattr(global_pos, 'x') and hasattr(global_pos, 'y'):
                    x = global_pos.x()
                    y = global_pos.y()
                elif hasattr(global_pos, '__getitem__'):
                    # 如果是元组或列表
                    x = global_pos[0]
                    y = global_pos[1]
                else:
                    # 备用方案：使用当前鼠标位置
                    mouse_pos = QtWidgets.QApplication.mouse().pos()
                    x = mouse_pos.x()
                    y = mouse_pos.y()
                
                # 确保坐标是整数
                x = int(x) & 0xFFFF
                y = int(y) & 0xFFFF
                lparam = (y << 16) | x
                
            except Exception as coord_error:
                print("构建坐标失败: %s" % (coord_error,))
                # 使用默认坐标
                lparam = 0
            
            # 选择消息类型
            msg = WM_MOUSEHWHEEL if is_horizontal else WM_MOUSEWHEEL
            
            # 发送消息
            result = ctypes.windll.user32.SendMessageW(hwnd, msg, wparam, lparam)
            
        except Exception as e:
            # 如果Windows API失败，尝试其他方法
            self._fallback_wheel_handling(hwnd, delta, is_horizontal)
    
    def _fallback_wheel_handling(self, hwnd, delta, is_horizontal):
        """滚轮事件处理的备用方案"""
        try:
            # 尝试使用Qt的事件系统
            if hasattr(self, 'embedArea') and self.embedArea:
                # 创建新的滚轮事件，兼容PySide2和PySide6
                try:
                    # 尝试PySide6
                    from PySide6.QtCore import QPoint
                    from PySide6.QtGui import QWheelEvent
                except ImportError:
                    try:
                        # 尝试PySide2
                        from PySide2.QtCore import QPoint
                        from PySide2.QtGui import QWheelEvent
                    except ImportError:
                        return
                
                # 获取当前鼠标位置
                cursor_pos = self.embedArea.mapFromGlobal(QtWidgets.QApplication.mouse().pos())
                
                # 创建滚轮事件，兼容不同版本
                try:
                    # PySide6方式
                    wheel_event = QWheelEvent(
                        cursor_pos,
                        QtWidgets.QApplication.mouse().pos(),
                        QPoint(0, delta) if not is_horizontal else QPoint(delta, 0),
                        QPoint(0, delta) if not is_horizontal else QPoint(delta, 0),
                        delta,
                        QtCore.Qt.Vertical if not is_horizontal else QtCore.Qt.Horizontal,
                        QtWidgets.QApplication.mouseButtons(),
                        QtWidgets.QApplication.keyboardModifiers()
                    )
                except TypeError:
                    # PySide2方式
                    wheel_event = QWheelEvent(
                        cursor_pos,
                        QtWidgets.QApplication.mouse().pos(),
                        delta,
                        QtCore.Qt.Vertical if not is_horizontal else QtCore.Qt.Horizontal,
                        QtWidgets.QApplication.mouseButtons(),
                        QtWidgets.QApplication.keyboardModifiers()
                    )
                
                # 发送事件到嵌入区域
                QtWidgets.QApplication.sendEvent(self.embedArea, wheel_event)
                
        except Exception as e:
            # 最后的备用方案：尝试重新聚焦嵌入区域
            try:
                if hasattr(self, 'embedArea') and self.embedArea:
                    self.embedArea.setFocus()
            except Exception as focus_error:
                pass

    def _check_wheel_handling(self):
        """定期检查滚轮事件处理状态"""
        try:
            # 检查窗口是否还存在
            if not hasattr(self, 'wheel_check_timer') or not self.wheel_check_timer:
                return
            
            # 检查窗口是否还可见
            if not self.isVisible() or not self.isEnabled():
                # 如果窗口不可见，停止定时器
                self._force_stop_timer()
                return
            
            # 检查嵌入区域是否有焦点
            if hasattr(self, 'embedArea') and self.embedArea:
                if not self.embedArea.hasFocus():
                    # 如果嵌入区域失去焦点，尝试恢复
                    self.embedArea.setFocus()
                
                # 检查嵌入区域是否可见和启用
                if not self.embedArea.isVisible() or not self.embedArea.isEnabled():
                    self.embedArea.setVisible(True)
                    self.embedArea.setEnabled(True)
                    
        except Exception as e:
            # 如果出错，强制停止定时器
            self._force_stop_timer()
    
    def _force_stop_timer(self):
        """强制停止定时器"""
        try:
            if hasattr(self, 'wheel_check_timer') and self.wheel_check_timer:
                self.wheel_check_timer.stop()
                self.wheel_check_timer.timeout.disconnect()
                self.wheel_check_timer.deleteLater()
                self.wheel_check_timer = None
        except:
            pass

    def _verify_fbxreview(self):
        """验证 FBX Review 可执行文件，提供版本特定的帮助"""
        if not os.path.isfile(self.fbxreview_path):
            # 根据 Max 版本提供不同的帮助信息
            if self.max_version >= 2026:
                help_text = (
                    "未找到 FBX Review 可执行文件。\n\n"
                    "路径: %s\n\n"
                    "对于 3ds Max %s，请确保：\n"
                    "1. FBX Review 已正确安装\n"
                    "2. 路径指向正确的可执行文件\n"
                    "3. 或将 fbxreview.exe 放置在上述路径中"
                    % (self.fbxreview_path, self.max_version)
                )
            else:
                help_text = (
                    "未找到 FBX Review 可执行文件。\n\n"
                    "当前路径: %s\n"
                    "Max 版本: %s\n\n"
                    "请检查 FBX Review 是否已安装，或将 fbxreview.exe 放在正确位置。"
                    % (self.fbxreview_path, self.max_version)
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
        self.statusBar().showMessage("加载：%s" % (file_path,))
        # 显示忙碌提示
        try:
            QtWidgets.QApplication.setOverrideCursor(QtCore.Qt.BusyCursor)
        except Exception:
            pass
        if hasattr(self, '_busy') and self._busy:
            try:
                self._busy.show()
            except Exception:
                pass

        try:
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
        finally:
            # 恢复忙碌提示
            try:
                QtWidgets.QApplication.restoreOverrideCursor()
            except Exception:
                pass
            if hasattr(self, '_busy') and self._busy:
                try:
                    self._busy.hide()
                except Exception:
                    pass

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
            self.statusBar().showMessage("隐藏桌面方案失败: %s" % (e,))
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
        container_hwnd = _get_hwnd_from_widget(self.embedArea)
        if container_hwnd is None:
            QtWidgets.QMessageBox.critical(self, "嵌入失败", "无法获取容器窗口句柄")
            return
        SetParent(child_hwnd, container_hwnd)
        make_child_style(child_hwnd)
        self._child_hwnd = child_hwnd
        self._resize_child()
        ShowWindow(child_hwnd, SW_SHOW)
        self._focus_child()
        self.statusBar().showMessage("已加载：%s" % (os.path.basename(self.current_file),))

    def _resize_child(self):
        if not self._child_hwnd:
            return
        w = max(1, self.embedArea.width())
        h = max(1, self.embedArea.height())
        SetWindowPos(self._child_hwnd, None, 0, 0, w, h, SWP_NOZORDER)

    def _focus_child(self):
        if self._child_hwnd:
            SetFocus(self._child_hwnd)

    def _on_app_state_changed(self, state):
        if state == QtCore.Qt.ApplicationActive:
            self._focus_child()

    def focusInEvent(self, e):
        QtWidgets.QMainWindow.focusInEvent(self, e)
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
        """彻底清理资源"""
        try:
            # 强制停止定时器
            if hasattr(self, 'wheel_check_timer') and self.wheel_check_timer:
                try:
                    # 方法1：停止定时器
                    self.wheel_check_timer.stop()
                    # 方法2：断开信号连接
                    self.wheel_check_timer.timeout.disconnect()
                except:
                    pass
                finally:
                    # 方法3：强制删除
                    self.wheel_check_timer.deleteLater()
                    self.wheel_check_timer = None
            
            # 清理子窗口句柄
            self._child_hwnd = None
            
            # 强制终止进程
            self._kill_process()
            
            # 清理不可见桌面
            if hasattr(self, 'invisible_desktop'):
                self.invisible_desktop.cleanup()
            
            # 强制垃圾回收
            import gc
            gc.collect()
            
        except Exception as e:
            pass

    def closeEvent(self, e):
        """窗口关闭事件"""
        try:
            # 强制停止定时器
            if hasattr(self, 'wheel_check_timer') and self.wheel_check_timer:
                try:
                    # 方法1：停止定时器
                    self.wheel_check_timer.stop()
                    # 方法2：断开信号连接
                    self.wheel_check_timer.timeout.disconnect()
                except:
                    pass
                finally:
                    # 方法3：强制删除
                    self.wheel_check_timer.deleteLater()
                    self.wheel_check_timer = None
            
            # 彻底清理资源
            self._teardown()
            
            # 确保进程被强制终止
            if hasattr(self, 'process') and self.process:
                try:
                    self.process.terminate()
                    self.process.wait(timeout=1.0)
                except:
                    try:
                        self.process.kill()
                    except:
                        pass
                self.process = None
            
            # 重置全局变量
            global _FBXR_WIN
            if _FBXR_WIN == self:
                _FBXR_WIN = None
            
            # 直接销毁
            self.destroy()
            
            e.accept()
        except Exception as e:
            e.accept()

    def _on_destroyed(self):
        """窗口销毁时的清理回调"""
        self._teardown()
        self.process = None
        self._child_hwnd = None
        self.invisible_desktop.cleanup()
        import gc
        gc.collect()

# --------------------------------------------------------------------------------------
# 入口
# --------------------------------------------------------------------------------------
_FBXR_WIN = None

def destroy_fbx_viewer():
    """直接销毁FBX查看器窗口（类似MAXScript的destroydialog）"""
    global _FBXR_WIN
    if _FBXR_WIN is not None:
        try:
            # 强制停止定时器
            if hasattr(_FBXR_WIN, 'wheel_check_timer') and _FBXR_WIN.wheel_check_timer:
                try:
                    # 方法1：停止定时器
                    _FBXR_WIN.wheel_check_timer.stop()
                    # 方法2：断开信号连接
                    _FBXR_WIN.wheel_check_timer.timeout.disconnect()
                except:
                    pass
                finally:
                    # 方法3：强制删除
                    _FBXR_WIN.wheel_check_timer.deleteLater()
                    _FBXR_WIN.wheel_check_timer = None
            
            _FBXR_WIN.destroy()
            _FBXR_WIN = None
            import gc
            gc.collect()
            return True
        except Exception as e:
            _FBXR_WIN = None
            return False
    else:
        return True

def show_fbx_viewer(file_path=None):
    """显示 FBX 查看器，兼容所有 Max 版本"""
    app = QtWidgets.QApplication.instance()
    if app is None:
        raise RuntimeError("请在 3ds Max 内运行此脚本。")
    
    # 获取 Max 主窗口作为父窗口
    parent = get_max_parent_widget()
    
    global _FBXR_WIN
    
    # 如果已有窗口，使用直接销毁方法
    if _FBXR_WIN is not None:
        destroy_fbx_viewer()
    
    # 创建新窗口
    try:
        _FBXR_WIN = FbxReviewEmbedder(parent=parent)
    except Exception as e:
        # 尝试无父窗口创建
        try:
            _FBXR_WIN = FbxReviewEmbedder(parent=None)
        except Exception as e2:
            raise RuntimeError("无法创建 FBX 查看器: %s" % (e2,))
    
    # 显示窗口
    try:
        _FBXR_WIN.show()
        _FBXR_WIN.raise_()
        _FBXR_WIN.activateWindow()
        
        # 如果提供了文件路径，自动加载
        if file_path and os.path.isfile(file_path):
            _FBXR_WIN.load_file(file_path)
        
        return _FBXR_WIN
    except Exception as e:
        raise


try:
    # 检查是否有全局文件路径变量
    if 'FBX_FILE_PATH' in globals():
        show_fbx_viewer(FBX_FILE_PATH)
    else:
        show_fbx_viewer()
except Exception as e:
    pass