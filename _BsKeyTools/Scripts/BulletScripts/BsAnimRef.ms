-- 全局变量
global imageArray = #()
global currentFrame = 0
global timeShift = 0
global isLoaded = false
global isPlaying = false
global loopEnabled = false
global lastFrame = 0
global statusMessage = ""
global alwaysOnTop = false
global mousePassthrough = false
global isMinimized = false
global isZenMode = false  -- 禅模式状态
global originalHeight = 480  -- 默认高度
global originalWidth = 680   -- 默认宽度，增加宽度
global dotNetTimer = dotNetObject "System.Windows.Forms.Timer"
global BackGrey
global PanelGrey
global TopbarGrey
global windowHandle
global isResizing = false
global startFormSize = [680, 430]  -- 默认窗口尺寸，增加宽度，减少高度
global minFormSize = [680, 430]    -- 最小窗口尺寸，与默认尺寸一致
global resizeBoxSize = 20
global bottomMargin = 5  -- 再次减少底部边距
global maxHwnd = undefined -- 存储MAX窗口句柄

-- Windows API常量
global WS_EX_TRANSPARENT = 0x00000020
global GWL_EXSTYLE = -20
global WS_EX_TOOLWINDOW = 0x00000080   -- 工具窗口风格
global WS_EX_NOACTIVATE = 0x08000000   -- 不激活窗口风格
global HWND_TOPMOST = -1
global HWND_NOTOPMOST = -2
global HWND_TOP = 0
global SWP_NOSIZE = 0x0001
global SWP_NOMOVE = 0x0002
global SWP_NOACTIVATE = 0x0010
global SWP_SHOWWINDOW = 0x0040
global WS_CHILD = 0x40000000 -- 子窗口样式
global GWL_STYLE = -16
global GWL_HWNDPARENT = -8  -- 窗口所有者

-- 清理可能存在的旧窗口
try(sequence_viewer.close())catch()

-- 颜色定义 - 浅色主题
Ccolor = dotnetclass "system.drawing.color"
BackGrey = Ccolor.fromArgb 220 220 220     -- 浅色主背景色
PanelGrey = Ccolor.fromArgb 240 240 240    -- 浅色面板背景色
TopbarGrey = Ccolor.fromArgb 200 200 200   -- 浅色标题栏背景色
TextColor = Ccolor.fromArgb 20 20 20       -- 浅色主题文字颜色
GreenColor = Ccolor.fromArgb 0 140 0
YellowColor = Ccolor.fromArgb 180 140 0
RedColor = Ccolor.fromArgb 180 0 0

-- 获取MAX窗口句柄
maxHwnd = windows.getMAXHWND()

-- 创建主窗口
sequence_viewer = dotNetObject "MaxCustomControls.MaxForm"
sequence_viewer.opacity = 1
sequence_viewer.width = startFormSize[1]
sequence_viewer.height = startFormSize[2]
sequence_viewer.clientSize = dotNetObject "System.Drawing.Size" startFormSize[1] startFormSize[2]  -- 确保客户区尺寸正确
sequence_viewer.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").none
sequence_viewer.BackColor = BackGrey
sequence_viewer.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").Manual
sequence_viewer.ShowInTaskbar = false  -- 不在任务栏显示
sequence_viewer.TopMost = false  -- 默认不置顶
alwaysOnTop = false

-- 创建顶部面板
pnlTopBar = dotNetObject "System.Windows.Forms.Panel"
pnlTopBar.width = sequence_viewer.width
pnlTopBar.height = 25  -- 减小高度
pnlTopBar.top = 0
pnlTopBar.left = 0
pnlTopBar.BackColor = TopbarGrey
sequence_viewer.controls.add pnlTopBar

-- 创建标题栏
lbl_Title = dotNetObject "label"
lbl_Title.text = "BsAnimRef_v1.0"
lbl_Title.Width = 120
lbl_Title.Height = 20
lbl_Title.left = 8
lbl_Title.top = 3
lbl_Title.forecolor = TextColor
lbl_Title.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 9 ((dotNetClass "System.Drawing.FontStyle").bold))
pnlTopBar.controls.add lbl_Title

-- 透明度标签
lbl_Opacity = dotNetObject "System.Windows.Forms.Label"
lbl_Opacity.text = "透明度:"
lbl_Opacity.width = 50
lbl_Opacity.height = 20
lbl_Opacity.top = 3
lbl_Opacity.left = 135
lbl_Opacity.forecolor = TextColor
lbl_Opacity.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlTopBar.controls.add lbl_Opacity

-- 透明度滑块
sldOpacity = dotNetObject "System.Windows.Forms.TrackBar"
sldOpacity.width = 150  -- 固定宽度，缩窄
sldOpacity.height = 22
sldOpacity.top = 1
sldOpacity.left = 185
sldOpacity.minimum = 10
sldOpacity.maximum = 100
sldOpacity.value = 100
sldOpacity.TickStyle = (dotNetClass "System.Windows.Forms.TickStyle").None  -- 隐藏刻度标记
sldOpacity.AutoSize = false
pnlTopBar.controls.add sldOpacity

-- 创建鼠标穿透按钮
btn_Passthrough = dotnetObject "system.windows.forms.button"
btn_Passthrough.width = 46  -- 适当调整宽度
btn_Passthrough.height = 22  -- 减小高度
btn_Passthrough.top = 1
btn_Passthrough.left = (sequence_viewer.width - 160)  -- 调整位置更靠右
btn_Passthrough.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_Passthrough.backcolor = Ccolor.darkgray
btn_Passthrough.forecolor = TextColor
btn_Passthrough.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btn_Passthrough.text = "穿透"
btn_Passthrough.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_Passthrough

-- 创建禅模式按钮
btn_ZenMode = dotnetObject "system.windows.forms.button"
btn_ZenMode.width = 58  -- 增加宽度显示"普通模式"
btn_ZenMode.height = 22  -- 减小高度
btn_ZenMode.top = 1
btn_ZenMode.left = (sequence_viewer.width - 280)  -- 调整位置
btn_ZenMode.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_ZenMode.backcolor = Ccolor.darkgray
btn_ZenMode.forecolor = TextColor
btn_ZenMode.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btn_ZenMode.text = "禅模式"
btn_ZenMode.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_ZenMode

-- 创建最小化按钮
btn_Minimize = dotnetObject "system.windows.forms.button"
btn_Minimize.width = 48  -- 适当调整宽度
btn_Minimize.height = 22  -- 减小高度
btn_Minimize.top = 1
btn_Minimize.left = (sequence_viewer.width - 215)  -- 调整位置更靠右
btn_Minimize.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_Minimize.backcolor = Ccolor.darkgray
btn_Minimize.forecolor = TextColor
btn_Minimize.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btn_Minimize.text = "最小化"
btn_Minimize.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_Minimize

-- 创建置顶按钮
btn_TopMost = dotnetObject "system.windows.forms.button"
btn_TopMost.width = 46  -- 适当调整宽度
btn_TopMost.height = 22  -- 减小高度
btn_TopMost.top = 1
btn_TopMost.left = (sequence_viewer.width - 105)  -- 调整位置更靠右
btn_TopMost.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_TopMost.backcolor = Ccolor.darkgray  -- 默认非置顶状态
btn_TopMost.forecolor = TextColor
btn_TopMost.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btn_TopMost.text = "置顶"
btn_TopMost.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_TopMost

-- 创建关闭按钮
btn_Close = dotnetObject "system.windows.forms.button"
btn_Close.width = 25
btn_Close.height = 22  -- 减小高度
btn_Close.top = 1
btn_Close.left = (sequence_viewer.width - 35)
btn_Close.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_Close.backcolor = Ccolor.firebrick
btn_Close.forecolor = Ccolor.white
btn_Close.font = (dotNetObject "System.Drawing.Font" "Arial" 10 ((dotNetClass "System.Drawing.FontStyle").bold))
btn_Close.text = "X"
btn_Close.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_Close

-- 创建主体内容面板
pnlContent = dotNetObject "System.Windows.Forms.Panel"
pnlContent.width = sequence_viewer.width - 10  -- 减小边距
pnlContent.height = sequence_viewer.height - 30 - bottomMargin  -- 适应较小的顶部栏，增加底部边距
pnlContent.top = 28  -- 适应较小的顶部栏
pnlContent.left = 5  -- 减小边距
pnlContent.backColor = BackGrey
sequence_viewer.controls.add pnlContent

-- 创建图片预览区域
picBox = dotNetObject "System.Windows.Forms.PictureBox"
picBox.width = pnlContent.width - 10  -- 减少边距
picBox.height = pnlContent.height - 45  -- 减少底部控制面板空间
picBox.top = 5  -- 直接放在顶部，无需透明度面板
picBox.left = 5
picBox.sizeMode = picBox.sizeMode.Zoom
picBox.borderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedSingle
picBox.backColor = Ccolor.white
pnlContent.controls.add picBox

-- 创建控制面板
pnlControls = dotNetObject "System.Windows.Forms.Panel"
pnlControls.width = pnlContent.width - 10  -- 减少边距
pnlControls.height = 38  -- 控制面板高度
pnlControls.top = picBox.top + picBox.height + 2  -- 减少图片和控制面板间的间隔
pnlControls.left = 5
pnlControls.BackColor = PanelGrey
pnlControls.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedSingle
pnlContent.controls.add pnlControls

-- 创建加载按钮
btnLoad = dotNetObject "System.Windows.Forms.Button"
btnLoad.text = "加载序列图片"
btnLoad.width = 100
btnLoad.height = 25
btnLoad.top = 6
btnLoad.left = 10
btnLoad.BackColor = PanelGrey
btnLoad.ForeColor = TextColor
btnLoad.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btnLoad.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnLoad

-- 创建循环按钮
chkLoop = dotNetObject "System.Windows.Forms.CheckBox"
chkLoop.text = "循环播放"
chkLoop.width = 90
chkLoop.height = 20
chkLoop.top = 8
chkLoop.left = 115
chkLoop.enabled = false
chkLoop.forecolor = TextColor
chkLoop.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 9 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlControls.controls.add chkLoop

-- 创建偏移标签
lblTimeShift = dotNetObject "System.Windows.Forms.Label"
lblTimeShift.text = "偏移:"
lblTimeShift.width = 40
lblTimeShift.height = 20
lblTimeShift.top = 9
lblTimeShift.left = 205
lblTimeShift.forecolor = TextColor
lblTimeShift.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlControls.controls.add lblTimeShift

-- 时间偏移数字控件
numTimeShift = dotNetObject "System.Windows.Forms.NumericUpDown"
numTimeShift.width = 50
numTimeShift.height = 20
numTimeShift.top = 8
numTimeShift.left = 245
numTimeShift.minimum = -1000
numTimeShift.maximum = 1000
numTimeShift.value = 0
numTimeShift.BackColor = BackGrey
numTimeShift.ForeColor = TextColor
pnlControls.controls.add numTimeShift

-- 开始帧按钮
btnStartFrame = dotNetObject "System.Windows.Forms.Button"
btnStartFrame.text = "⏮"
btnStartFrame.width = 35
btnStartFrame.height = 25
btnStartFrame.top = 6
btnStartFrame.left = 310
btnStartFrame.enabled = false
btnStartFrame.BackColor = PanelGrey
btnStartFrame.ForeColor = TextColor
btnStartFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnStartFrame

-- 上一帧按钮
btnPrevFrame = dotNetObject "System.Windows.Forms.Button"
btnPrevFrame.text = "◀"
btnPrevFrame.width = 35
btnPrevFrame.height = 25
btnPrevFrame.top = 6
btnPrevFrame.left = 350
btnPrevFrame.enabled = false
btnPrevFrame.BackColor = PanelGrey
btnPrevFrame.ForeColor = TextColor
btnPrevFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnPrevFrame

-- 播放按钮
btnPlay = dotNetObject "System.Windows.Forms.Button"
btnPlay.text = "▶"
btnPlay.width = 35
btnPlay.height = 25
btnPlay.top = 6
btnPlay.left = 390
btnPlay.enabled = false
btnPlay.BackColor = PanelGrey
btnPlay.ForeColor = TextColor
btnPlay.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnPlay

-- 下一帧按钮
btnNextFrame = dotNetObject "System.Windows.Forms.Button"
btnNextFrame.text = "▶"
btnNextFrame.width = 35
btnNextFrame.height = 25
btnNextFrame.top = 6
btnNextFrame.left = 430
btnNextFrame.enabled = false
btnNextFrame.BackColor = PanelGrey
btnNextFrame.ForeColor = TextColor
btnNextFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnNextFrame

-- 结束帧按钮
btnEndFrame = dotNetObject "System.Windows.Forms.Button"
btnEndFrame.text = "⏭"
btnEndFrame.width = 35
btnEndFrame.height = 25
btnEndFrame.top = 6
btnEndFrame.left = 470
btnEndFrame.enabled = false
btnEndFrame.BackColor = PanelGrey
btnEndFrame.ForeColor = TextColor
btnEndFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnEndFrame

-- 状态标签直接加入控制面板右侧
lblStatus = dotNetObject "System.Windows.Forms.Label"
lblStatus.text = "状态: 未加载图片"
lblStatus.width = 150
lblStatus.height = 18
lblStatus.top = 10
lblStatus.left = 520  -- 放置在控制区域右侧
lblStatus.forecolor = TextColor
lblStatus.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlControls.controls.add lblStatus

-- 创建调整大小控件
resizeBox = dotNetObject "System.Windows.Forms.Panel"
resizeBox.width = resizeBoxSize
resizeBox.height = resizeBoxSize
resizeBox.left = sequence_viewer.width - resizeBoxSize
resizeBox.top = sequence_viewer.height - resizeBoxSize
resizeBox.BackColor = Ccolor.fromArgb 80 80 80  -- 稍微深一点的灰色更醒目
resizeBox.cursor = (dotNetClass "System.Windows.Forms.Cursors").SizeNWSE
-- 确保窗口调整控件添加在最后，位于最上层
sequence_viewer.controls.remove resizeBox
sequence_viewer.controls.add resizeBox

-- 为resize控件添加边框
fn onResizeBoxPaint sender e = (
    local g = e.graphics
    local borderColor = (dotNetClass "System.Drawing.Color").fromArgb 140 140 140
    local borderPen = dotNetObject "System.Drawing.Pen" borderColor 1
    -- 绘制边框
    g.drawRectangle borderPen 0 0 (sender.width-1) (sender.height-1)
    -- 绘制调整大小图标
    local x1 = sender.width - 8
    local y1 = sender.height - 4
    local x2 = sender.width - 4
    local y2 = sender.height - 8
    g.drawLine borderPen x1 y1 x2 y2
    x1 = sender.width - 12
    y1 = sender.height - 4
    x2 = sender.width - 4
    y2 = sender.height - 12
    g.drawLine borderPen x1 y1 x2 y2
    x1 = sender.width - 16
    y1 = sender.height - 4
    x2 = sender.width - 4
    y2 = sender.height - 16
    g.drawLine borderPen x1 y1 x2 y2
    borderPen.dispose()
)
dotnet.addEventHandler resizeBox "Paint" onResizeBoxPaint

--------- 函数定义 ---------

-- 初始化函数
fn initializeImages = (
    imageArray = #()
    currentFrame = 0
    isLoaded = false
    lastFrame = 0
    
    -- 禁用控制按钮
    btnPlay.enabled = false
    btnStartFrame.enabled = false
    btnPrevFrame.enabled = false
    btnNextFrame.enabled = false
    btnEndFrame.enabled = false
    chkLoop.enabled = false
    chkLoop.checked = false
    loopEnabled = false
    
    lblStatus.text = "状态: 未加载图片"
)

-- 设置状态信息
fn setStatus message color = (
    lblStatus.text = message
    lblStatus.forecolor = color
    statusMessage = message
)

-- 加载序列图片
fn loadSequenceImages basePath = (
    -- 确保路径以反斜杠结尾
    if basePath[basePath.count] != "\\" do basePath += "\\"
    
    -- 获取所有支持的图片格式
    local files = #()
    local jpgFiles = getFiles (basePath + "*.jpg")
    local jpegFiles = getFiles (basePath + "*.jpeg")
    local pngFiles = getFiles (basePath + "*.png")
    local bmpFiles = getFiles (basePath + "*.bmp")
    
    -- 合并所有文件
    join files jpgFiles
    join files jpegFiles
    join files pngFiles
    join files bmpFiles
    
    if files.count == 0 then (
        messageBox "未找到序列图片！\n请确保文件夹中包含支持的图片格式(.jpg, .jpeg, .png, .bmp)。" title:"错误"
        return false
    )
    
    -- 按文件名排序
    sort files
    
    imageArray = #()
    for f in files do (
        append imageArray f
    )
    
    -- 测试加载第一张图片
    try (
        local testBmp = (dotNetObject "System.Drawing.Bitmap" imageArray[1])
        picBox.image = testBmp
        setStatus ("已加载 " + imageArray.count as string + " 张图片") GreenColor
        
        -- 启用控制按钮
        btnPlay.enabled = true
        btnStartFrame.enabled = true
        btnPrevFrame.enabled = true
        btnNextFrame.enabled = true
        btnEndFrame.enabled = true
        chkLoop.enabled = true
        
        isLoaded = true
        lastFrame = imageArray.count
        
        return true
    ) catch (
        messageBox "加载图片失败！请检查图片格式是否正确。" title:"错误"
        setStatus "加载图片失败" RedColor
        return false
    )
)

-- 更新当前帧的图片
fn updateCurrentImage = (
    if imageArray.count > 0 and isLoaded do (
        -- 获取当前帧号并确保是整数
        currentFrame = (sliderTime.frame as integer)
        
        -- 计算引用帧（考虑时间偏移）
        local refFrame = currentFrame - timeShift
        
        -- 更新帧信息显示
        local frameInfo = "当前帧: " + currentFrame as string + " | 引用帧: " + refFrame as string
        lblStatus.text = frameInfo
        
        -- 检查是否在有效范围内
        if refFrame >= 0 and refFrame < imageArray.count then (
            try(
                -- 检查文件是否存在
                if doesFileExist imageArray[refFrame + 1] then (
                    -- 使用FileStream加载图片
                    local fs = (dotNetObject "System.IO.FileStream" imageArray[refFrame + 1] (dotNetClass "System.IO.FileMode").Open (dotNetClass "System.IO.FileAccess").Read)
                    local bmp = (dotNetObject "System.Drawing.Bitmap" fs)
                    fs.close()
                    
                    -- 如果当前有图片，先释放它
                    if picBox.image != undefined do (
                        picBox.image.dispose()
                    )
                    
                    picBox.image = bmp
                )
            )catch()
        ) else (
            -- 处理超出范围的情况
            if loopEnabled then (
                -- 循环播放：回到开始
                if isPlaying then (
                    toggleStopAnimation()
                    sliderTime = timeShift
                    togglePlayAnimation()
                ) else (
                    sliderTime = timeShift
                )
            ) else (
                -- 不循环：显示超出范围消息
                if refFrame < 0 then (
                    sliderTime = timeShift
                ) else if refFrame >= imageArray.count then (
                    sliderTime = timeShift + imageArray.count - 1
                )
                setStatus "帧超出范围" YellowColor
            )
        )
    )
)

-- 简单鼠标穿透 - 只使用透明度
fn setMousePassthrough state = (
    mousePassthrough = state
    
    try (
        if state then (
            -- 使用半透明来创造"穿透感"
            sequence_viewer.opacity = 0.4
            sldOpacity.value = 40
            btn_Passthrough.backcolor = GreenColor
            setStatus "已启用半透明模式" GreenColor
        ) else (
            -- 恢复透明度
            sequence_viewer.opacity = 1.0
            sldOpacity.value = 100
            btn_Passthrough.backcolor = Ccolor.darkgray
            setStatus "已禁用半透明模式" YellowColor
        )
    ) catch (
        setStatus "透明度更改失败" RedColor
    )
)

-- 播放动画
fn togglePlayAnimation = (
    if isLoaded then (
        isPlaying = true
        btnPlay.text = "⏸"
        numTimeShift.enabled = false
        playAnimation()
    )
)

-- 停止动画
fn toggleStopAnimation = (
    isPlaying = false
    btnPlay.text = "▶"
    numTimeShift.enabled = true
    stopAnimation()
)

-- 下一帧
fn nextFrame = (
    if isLoaded then (
        toggleStopAnimation()
        sliderTime += 1
    )
)

-- 上一帧
fn previousFrame = (
    if isLoaded then (
        toggleStopAnimation()
        sliderTime -= 1
    )
)

-- 开始帧
fn startFrame = (
    if isLoaded then (
        toggleStopAnimation()
        sliderTime = timeShift
    )
)

-- 结束帧
fn endFrame = (
    if isLoaded then (
        toggleStopAnimation()
        sliderTime = timeShift + (imageArray.count - 1)
    )
)

-- 更新时间偏移
fn updateTimeShift = (
    timeShift = numTimeShift.value as integer
    updateCurrentImage()
)

-- 自适应调整布局
fn resizeUI = (
    -- 更新顶部面板
    pnlTopBar.width = sequence_viewer.width
    
    -- 更新按钮位置
    btn_ZenMode.left = sequence_viewer.width - 280
    btn_Minimize.left = sequence_viewer.width - 215
    btn_Passthrough.left = sequence_viewer.width - 160
    btn_TopMost.left = sequence_viewer.width - 105
    btn_Close.left = sequence_viewer.width - 35
    
    -- 更新透明度滑块位置
    lbl_Opacity.left = 135
    sldOpacity.left = 185
    
    -- 更新主体内容面板
    pnlContent.width = sequence_viewer.width - 10  -- 减小边距
    pnlContent.height = sequence_viewer.height - 30 - bottomMargin  -- 适应较小的顶部栏，增加底部边距
    
    -- 计算基本图片区域可用高度（禅模式和普通模式都用同样的计算）
    local contentHeight = pnlContent.height
    local topMargin = 5  -- 顶部边距
    
    -- 禅模式和普通模式的处理
    if isZenMode then (
        -- 禅模式下只更新宽度，高度保持一致
        picBox.width = pnlContent.width - 10
        picBox.top = topMargin
        -- 禅模式下整个内容区域都用于显示图片
        picBox.height = contentHeight - topMargin
        picBox.left = 5
        
        -- 隐藏控制面板
        pnlControls.visible = false
    ) else (
        -- 常规模式
        -- 更新图片预览区域尺寸
        picBox.width = pnlContent.width - 10
        picBox.left = 5
        
        -- 固定控制面板高度
        local bottomControlsHeight = 42  -- 控制面板及边距
        
        -- 计算图片区可用高度
        local availableHeight = contentHeight - topMargin - bottomControlsHeight
        picBox.height = availableHeight
        picBox.top = topMargin
        
        -- 显示控制面板
        pnlControls.visible = true
        pnlControls.top = picBox.top + picBox.height + 2  -- 减少间隔
        pnlControls.width = pnlContent.width - 10
        pnlControls.left = 5
        
        -- 更新状态标签位置
        lblStatus.left = 520
        lblStatus.width = pnlControls.width - 530
    )
    
    -- 确保调整大小控件始终可见且位于正确位置
    -- 移除并重新添加调整大小控件，确保其位于最上层
    sequence_viewer.controls.remove resizeBox
    
    -- 更新调整大小控件位置
    resizeBox.left = sequence_viewer.width - resizeBoxSize
    resizeBox.top = sequence_viewer.height - resizeBoxSize
    
    -- 重新添加到窗口，确保其位于最上层
    sequence_viewer.controls.add resizeBox
)

-- 启用禅模式
fn enableZenMode = (
    if not isZenMode do (
        isZenMode = true
        
        -- 保存当前窗口状态，但不修改高度
        if not isMinimized do (
            originalHeight = sequence_viewer.height
        )
        
        -- 只更改最小高度，但不强制调整窗口尺寸
        minFormSize[2] = 280  -- 更新禅模式下的最小高度
        
        -- 更改按钮文字
        btn_ZenMode.text = "普通模式"
        btn_ZenMode.backcolor = GreenColor
        
        -- 更新UI布局
        resizeUI()
        
        -- 设置状态
        setStatus "已启用禅模式" GreenColor
    )
)

-- 禁用禅模式
fn disableZenMode = (
    if isZenMode do (
        isZenMode = false
        
        -- 恢复最小尺寸设置
        minFormSize[2] = 430  -- 恢复正常模式的最小高度
        
        -- 不强制恢复窗口高度，除非当前高度低于最小高度
        if sequence_viewer.height < minFormSize[2] do (
            sequence_viewer.height = originalHeight
        )
        
        -- 更改按钮文字
        btn_ZenMode.text = "禅模式"
        btn_ZenMode.backcolor = Ccolor.darkgray
        
        -- 更新UI布局
        resizeUI()
        
        -- 设置状态
        setStatus "已退出禅模式" YellowColor
    )
)

-- 切换禅模式
fn toggleZenMode = (
    if isZenMode then (
        disableZenMode()
    ) else (
        enableZenMode()
    )
)

-- 禅模式按钮事件
fn onZenModeClick sender e = (
    toggleZenMode()
)
dotnet.addEventHandler btn_ZenMode "Click" onZenModeClick

-- 切换循环播放
fn toggleLoop sender args = (
    loopEnabled = chkLoop.checked
)

-- 事件处理
fn onOpacityChanged sender e = (
    if not mousePassthrough do (
        sequence_viewer.opacity = sldOpacity.value / 100.0
    )
)
dotnet.addEventHandler sldOpacity "ValueChanged" onOpacityChanged

fn onLoadClick sender e = (
    local path = getSavePath caption:"选择序列图片所在文件夹"
    if path != undefined do (
        loadSequenceImages path
    )
)
dotnet.addEventHandler btnLoad "Click" onLoadClick

fn onCloseClick sender e = (
    sequence_viewer.dispose()
)
dotnet.addEventHandler btn_Close "Click" onCloseClick

fn onTimeShiftChanged sender e = (
    updateTimeShift()
)
dotnet.addEventHandler numTimeShift "ValueChanged" onTimeShiftChanged

fn onPlayClick sender e = (
    if isPlaying then (
        toggleStopAnimation()
    ) else (
        togglePlayAnimation()
    )
)
dotnet.addEventHandler btnPlay "Click" onPlayClick

fn onNextFrameClick sender e = (
    nextFrame()
)
dotnet.addEventHandler btnNextFrame "Click" onNextFrameClick

fn onPrevFrameClick sender e = (
    previousFrame()
)
dotnet.addEventHandler btnPrevFrame "Click" onPrevFrameClick

fn onStartFrameClick sender e = (
    startFrame()
)
dotnet.addEventHandler btnStartFrame "Click" onStartFrameClick

fn onEndFrameClick sender e = (
    endFrame()
)
dotnet.addEventHandler btnEndFrame "Click" onEndFrameClick

-- 循环播放事件
dotnet.addEventHandler chkLoop "CheckedChanged" toggleLoop

-- 鼠标穿透事件
fn onPassthroughClick sender e = (
    try (
        setMousePassthrough (not mousePassthrough)
    ) catch (
        setStatus "透明模式切换失败" RedColor
    )
)
dotnet.addEventHandler btn_Passthrough "Click" onPassthroughClick

-- 窗口拖动
global mouseOffset = [0,0]
global dragging = 0

-- 为整个窗口添加拖动能力
fn onFormMouseDown sender e = (
    mouseOffset[1] = mouse.screenPos.x - sequence_viewer.left
    mouseOffset[2] = mouse.screenPos.y - sequence_viewer.top
    global dragging = 1
)
dotnet.addEventHandler pnlTopBar "MouseDown" onFormMouseDown
dotnet.addEventHandler lbl_Title "MouseDown" onFormMouseDown

fn onFormMouseMove sender e = (
    if dragging == 1 do (
        sequence_viewer.left = mouse.screenpos.x - mouseOffset[1]
        sequence_viewer.top = mouse.screenpos.y - mouseOffset[2]
    )
)
dotnet.addEventHandler pnlTopBar "MouseMove" onFormMouseMove
dotnet.addEventHandler lbl_Title "MouseMove" onFormMouseMove

fn onFormMouseUp sender e = (
    global dragging = 0
)
dotnet.addEventHandler pnlTopBar "MouseUp" onFormMouseUp
dotnet.addEventHandler lbl_Title "MouseUp" onFormMouseUp

-- 调整大小功能
fn onResizeMouseDown sender e = (
    isResizing = true
    mouseOffset[1] = mouse.screenPos.x
    mouseOffset[2] = mouse.screenPos.y
)
dotnet.addEventHandler resizeBox "MouseDown" onResizeMouseDown

fn onResizeMouseMove sender e = (
    if isResizing do (
        -- 计算新的宽度和高度
        local newWidth = sequence_viewer.width + (mouse.screenPos.x - mouseOffset[1])
        local newHeight = sequence_viewer.height + (mouse.screenPos.y - mouseOffset[2])
        
        -- 设置最小尺寸以防止窗口过小
        if newWidth < minFormSize[1] do newWidth = minFormSize[1]
        if newHeight < minFormSize[2] do newHeight = minFormSize[2]
        
        -- 保存当前尺寸作为原始值，用于恢复
        originalWidth = newWidth
        originalHeight = newHeight
        
        -- 应用新尺寸
        sequence_viewer.width = newWidth
        sequence_viewer.height = newHeight
        
        -- 更新鼠标位置
        mouseOffset[1] = mouse.screenPos.x
        mouseOffset[2] = mouse.screenPos.y
        
        -- 更新UI布局
        resizeUI()
    )
)
dotnet.addEventHandler resizeBox "MouseMove" onResizeMouseMove
dotnet.addEventHandler sequence_viewer "MouseMove" onResizeMouseMove

fn onResizeMouseUp sender e = (
    isResizing = false
)
dotnet.addEventHandler resizeBox "MouseUp" onResizeMouseUp
dotnet.addEventHandler sequence_viewer "MouseUp" onResizeMouseUp

-- 添加新函数：保持窗口在MAX之上但非最顶层
fn keepAboveMax = (
    try (
        -- 确保有有效的句柄
        if windowHandle == undefined do (
            windowHandle = windows.getHWNDByTitle "序列图片查看器"
            if windowHandle == undefined do return false
        )
        
        if maxHwnd == undefined do (
            maxHwnd = windows.getMAXHWND()
            if maxHwnd == undefined do return false
        )
        
        if alwaysOnTop then (
            -- 在置顶模式下使用HWND_TOPMOST
            windows.setWindowPos windowHandle HWND_TOPMOST 0 0 0 0 (bit.or SWP_NOMOVE SWP_NOSIZE SWP_NOACTIVATE)
        ) else (
            -- 在非置顶模式下，将MAX设为窗口的所有者
            windows.setWindowLong windowHandle GWL_HWNDPARENT maxHwnd
            -- 确保窗口在MAX的Z序中可见
            windows.setWindowPos windowHandle HWND_TOP 0 0 0 0 (bit.or SWP_NOMOVE SWP_NOSIZE SWP_NOACTIVATE)
        )
        
        true
    ) catch (
        false
    )
)

-- 切换窗口置顶状态
fn toggleTopMost = (
    try (
        alwaysOnTop = not alwaysOnTop
        
        -- 设置窗口置顶状态
        sequence_viewer.TopMost = alwaysOnTop
        
        -- 调用新函数来设置正确的Z顺序
        keepAboveMax()
        
        if alwaysOnTop then (
            btn_TopMost.backcolor = GreenColor
            setStatus "窗口已置顶" GreenColor
        ) else (
            btn_TopMost.backcolor = Ccolor.darkgray
            setStatus "窗口未置顶但保持在MAX之上" YellowColor
        )
    ) catch (
        -- 如果出错，重置状态
        alwaysOnTop = true
        sequence_viewer.TopMost = true
        btn_TopMost.backcolor = GreenColor
    )
)

-- 置顶按钮事件
fn onTopMostClick sender e = (
    toggleTopMost()
)
dotnet.addEventHandler btn_TopMost "Click" onTopMostClick

-- 最小化窗口
fn minimizeWindow = (
    try (
        isMinimized = true
        -- 缩小到只显示标题栏
        sequence_viewer.height = 30
        btn_Minimize.text = "还原"
    ) catch()
)

-- 恢复窗口
fn restoreWindow = (
    try (
        isMinimized = false
        -- 恢复原始大小
        sequence_viewer.width = originalWidth
        sequence_viewer.height = originalHeight
        btn_Minimize.text = "最小化"
        -- 立即执行一次resizeUI确保布局正确
        resizeUI()
    ) catch()
)

-- 切换最小化状态
fn toggleMinimize = (
    if isMinimized then (
        restoreWindow()
    ) else (
        minimizeWindow()
    )
)

-- 最小化按钮事件
fn onMinimizeClick sender e = (
    toggleMinimize()
)
dotnet.addEventHandler btn_Minimize "Click" onMinimizeClick

-- 获取窗口句柄并设置窗口样式
try (
    -- 获取MAX句柄
    maxHwnd = windows.getMAXHWND()
    
    -- 获取我们窗口的句柄
    windowHandle = windows.getHWNDByTitle "序列图片查看器"
    if windowHandle != undefined do (
        -- 添加工具窗口和不激活窗口样式
        local exStyle = windows.getWindowLong windowHandle GWL_EXSTYLE
        exStyle = bit.or exStyle WS_EX_TOOLWINDOW
        exStyle = bit.or exStyle WS_EX_NOACTIVATE
        windows.setWindowLong windowHandle GWL_EXSTYLE exStyle
    )
) catch()

-- 在创建完窗口后将其前置显示
sequence_viewer.show()
sequence_viewer.BringToFront()
keepAboveMax()  -- 使用新函数设置正确的Z顺序

-- 强制应用初始大小
sequence_viewer.width = startFormSize[1]
sequence_viewer.height = startFormSize[2]

-- 初始调整UI布局确保所有元素正确显示
resizeUI()

-- 添加窗口关闭时的清理
fn onFormClosed sender e = (
    try (
        if dotNetTimer != undefined and dotNetTimer.enabled do (
            dotNetTimer.enabled = false
            dotNetTimer.dispose()
        )
        
        -- 清理MAX焦点计时器
        if maxFocusTimer != undefined and maxFocusTimer.enabled do (
            maxFocusTimer.enabled = false
            maxFocusTimer.dispose()
        )
    ) catch()
)
dotnet.addEventHandler sequence_viewer "FormClosed" onFormClosed

-- 添加一个新的计时器处理MAX焦点变化
fn setupMaxFocusHandler = (
    -- 创建一个计时器来检查MAX窗口状态
    global maxFocusTimer = dotNetObject "System.Windows.Forms.Timer"
    maxFocusTimer.interval = 500 -- 每500毫秒检查一次
    
    fn onMaxFocusTimer sender e = (
        -- 只在非置顶模式下处理
        if not alwaysOnTop and windowHandle != undefined do (
            -- 检查MAX是否在前台
            local foregroundHwnd = windows.getForegroundWindow()
            if foregroundHwnd == maxHwnd do (
                -- MAX获得焦点，保持我们的窗口在MAX之上
                keepAboveMax()
            )
        )
    )
    
    dotnet.addEventHandler maxFocusTimer "Tick" onMaxFocusTimer
    maxFocusTimer.enabled = true
)

-- 启动MAX焦点处理
setupMaxFocusHandler()

-- 创建细边框绘制函数
fn drawThinBorder form = (
    -- 添加窗口Paint事件处理以绘制细边框
    fn onFormPaint sender e = (
        local g = e.graphics
        local borderColor = (dotNetClass "System.Drawing.Color").fromArgb 100 100 100
        local borderPen = dotNetObject "System.Drawing.Pen" borderColor 1
        local rect = dotNetObject "System.Drawing.Rectangle" 0 0 (sender.width-1) (sender.height-1)
        g.drawRectangle borderPen rect
        borderPen.dispose()
    )
    dotnet.addEventHandler form "Paint" onFormPaint
)

-- 应用细边框
drawThinBorder sequence_viewer