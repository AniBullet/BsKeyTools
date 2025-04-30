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
global dotNetTimer = dotNetObject "System.Windows.Forms.Timer"
global BackGrey
global PanelGrey
global TopbarGrey
global windowHandle
global isResizing = false
global startFormSize = [600, 540]
global resizeBoxSize = 20
global bottomMargin = 25  -- 增加底部边距，确保resize控件有足够空间
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
sequence_viewer.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").none
sequence_viewer.BackColor = BackGrey
sequence_viewer.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").Manual
sequence_viewer.ShowInTaskbar = false  -- 不在任务栏显示

-- 创建顶部面板
pnlTopBar = dotNetObject "System.Windows.Forms.Panel"
pnlTopBar.width = sequence_viewer.width
pnlTopBar.height = 30
pnlTopBar.top = 0
pnlTopBar.left = 0
pnlTopBar.BackColor = TopbarGrey
sequence_viewer.controls.add pnlTopBar

-- 创建标题栏
lbl_Title = dotNetObject "label"
lbl_Title.text = "序列图片查看器"
lbl_Title.Width = 200
lbl_Title.Height = 20
lbl_Title.left = 10
lbl_Title.top = 5
lbl_Title.forecolor = TextColor
lbl_Title.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 10 ((dotNetClass "System.Drawing.FontStyle").bold))
pnlTopBar.controls.add lbl_Title

-- 创建鼠标穿透按钮
btn_Passthrough = dotnetObject "system.windows.forms.button"
btn_Passthrough.width = 30
btn_Passthrough.height = 25
btn_Passthrough.top = 2
btn_Passthrough.left = (sequence_viewer.width - 110)
btn_Passthrough.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_Passthrough.backcolor = Ccolor.darkgray
btn_Passthrough.forecolor = TextColor
btn_Passthrough.font = (dotNetObject "System.Drawing.Font" "Arial" 10 ((dotNetClass "System.Drawing.FontStyle").bold))
btn_Passthrough.text = "T"
btn_Passthrough.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_Passthrough

-- 创建置顶按钮
btn_TopMost = dotnetObject "system.windows.forms.button"
btn_TopMost.width = 30
btn_TopMost.height = 25
btn_TopMost.top = 2
btn_TopMost.left = (sequence_viewer.width - 70)
btn_TopMost.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_TopMost.backcolor = Ccolor.darkgray
btn_TopMost.forecolor = TextColor
btn_TopMost.font = (dotNetObject "System.Drawing.Font" "Arial" 10 ((dotNetClass "System.Drawing.FontStyle").bold))
btn_TopMost.text = "↑"
btn_TopMost.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_TopMost

-- 创建关闭按钮
btn_Close = dotnetObject "system.windows.forms.button"
btn_Close.width = 30
btn_Close.height = 25
btn_Close.top = 2
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
pnlContent.width = sequence_viewer.width - 20
pnlContent.height = sequence_viewer.height - 40
pnlContent.top = 35
pnlContent.left = 10
pnlContent.backColor = BackGrey
sequence_viewer.controls.add pnlContent

-- 创建透明度滑块和标签面板
pnlOpacity = dotNetObject "System.Windows.Forms.Panel"
pnlOpacity.width = pnlContent.width - 20
pnlOpacity.height = 40
pnlOpacity.top = 10
pnlOpacity.left = 10
pnlOpacity.BackColor = PanelGrey
pnlOpacity.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
pnlContent.controls.add pnlOpacity

-- 透明度标签
lbl_Opacity = dotNetObject "System.Windows.Forms.Label"
lbl_Opacity.text = "透明度:"
lbl_Opacity.width = 60
lbl_Opacity.height = 20
lbl_Opacity.top = 10
lbl_Opacity.left = 10
lbl_Opacity.forecolor = TextColor
lbl_Opacity.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 9 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlOpacity.controls.add lbl_Opacity

-- 透明度滑块
sldOpacity = dotNetObject "System.Windows.Forms.TrackBar"
sldOpacity.width = pnlOpacity.width - 80
sldOpacity.height = 30
sldOpacity.top = 5
sldOpacity.left = 70
sldOpacity.minimum = 10
sldOpacity.maximum = 100
sldOpacity.value = 100
sldOpacity.tickFrequency = 10
pnlOpacity.controls.add sldOpacity

-- 创建图片预览区域
picBox = dotNetObject "System.Windows.Forms.PictureBox"
picBox.width = pnlContent.width - 20
picBox.height = 380  -- 减小高度，给底部留出更多空间
picBox.top = 60
picBox.left = 10
picBox.sizeMode = picBox.sizeMode.Zoom
picBox.borderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedSingle
picBox.backColor = Ccolor.white
pnlContent.controls.add picBox

-- 创建控制面板
pnlControls = dotNetObject "System.Windows.Forms.Panel"
pnlControls.width = pnlContent.width - 20
pnlControls.height = 40
pnlControls.top = 470
pnlControls.left = 10
pnlControls.BackColor = PanelGrey
pnlControls.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedSingle
pnlContent.controls.add pnlControls

-- 创建加载按钮
btnLoad = dotNetObject "System.Windows.Forms.Button"
btnLoad.text = "加载序列图片"
btnLoad.width = 100
btnLoad.height = 25
btnLoad.top = 7
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
chkLoop.top = 10
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
lblTimeShift.top = 12
lblTimeShift.left = 205  -- 恢复为原来的位置
lblTimeShift.forecolor = TextColor
lblTimeShift.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlControls.controls.add lblTimeShift

-- 时间偏移数字控件
numTimeShift = dotNetObject "System.Windows.Forms.NumericUpDown"
numTimeShift.width = 50
numTimeShift.height = 20
numTimeShift.top = 10
numTimeShift.left = 245  -- 恢复为原来的位置
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
btnStartFrame.top = 7
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
btnPrevFrame.top = 7
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
btnPlay.top = 7
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
btnNextFrame.top = 7
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
btnEndFrame.top = 7
btnEndFrame.left = 470
btnEndFrame.enabled = false
btnEndFrame.BackColor = PanelGrey
btnEndFrame.ForeColor = TextColor
btnEndFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnEndFrame

-- 创建状态面板
pnlStatus = dotNetObject "System.Windows.Forms.Panel"
pnlStatus.width = pnlContent.width - 20
pnlStatus.height = 25
pnlStatus.top = 520
pnlStatus.left = 10
pnlStatus.BackColor = PanelGrey
pnlContent.controls.add pnlStatus

-- 创建状态标签
lblStatus = dotNetObject "System.Windows.Forms.Label"
lblStatus.text = "状态: 未加载图片"
lblStatus.width = 400
lblStatus.height = 20
lblStatus.top = 5
lblStatus.left = 10
lblStatus.forecolor = TextColor
lblStatus.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 9 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlStatus.controls.add lblStatus

-- 创建调整大小控件
resizeBox = dotNetObject "System.Windows.Forms.Panel"
resizeBox.width = resizeBoxSize
resizeBox.height = resizeBoxSize
resizeBox.left = sequence_viewer.width - resizeBoxSize
resizeBox.top = sequence_viewer.height - resizeBoxSize
resizeBox.BackColor = Ccolor.darkgray
resizeBox.cursor = (dotNetClass "System.Windows.Forms.Cursors").SizeNWSE
-- 确保窗口调整控件添加在最后，位于最上层
sequence_viewer.controls.remove resizeBox
sequence_viewer.controls.add resizeBox

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
    
    if files.count == 0 do (
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
        
        true
    ) catch (
        messageBox "加载图片失败！请检查图片格式是否正确。" title:"错误"
        setStatus "加载图片失败" RedColor
        false
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
    btn_Passthrough.left = sequence_viewer.width - 110
    btn_TopMost.left = sequence_viewer.width - 70
    btn_Close.left = sequence_viewer.width - 35
    
    -- 更新主体内容面板
    pnlContent.width = sequence_viewer.width - 20
    pnlContent.height = sequence_viewer.height - 40
    
    -- 更新透明度面板和滑块
    pnlOpacity.width = pnlContent.width - 20
    sldOpacity.width = pnlOpacity.width - 80
    
    -- 更新图片预览区域
    picBox.width = pnlContent.width - 20
    -- 动态计算图片区域高度：总高度减去其他控件所需的空间
    local controlsHeight = 150 -- 底部控件总高度（透明度+控制面板+状态栏+底部边距）
    picBox.height = pnlContent.height - controlsHeight
    
    -- 更新控制面板
    pnlControls.width = pnlContent.width - 20
    pnlControls.top = picBox.top + picBox.height + 10
    
    -- 调整播放按钮的位置
    local controlsWidth = pnlControls.width
    -- 确保右侧按钮组始终对齐到面板右侧
    local rightButtonsStartPos = controlsWidth - 215 -- 5个按钮的总宽度(35*5=175)加上一些间距
    rightButtonsStartPos = if rightButtonsStartPos < 310 then 310 else rightButtonsStartPos
    
    btnStartFrame.left = rightButtonsStartPos
    btnPrevFrame.left = rightButtonsStartPos + 40
    btnPlay.left = rightButtonsStartPos + 80
    btnNextFrame.left = rightButtonsStartPos + 120
    btnEndFrame.left = rightButtonsStartPos + 160
    
    -- 更新状态面板
    pnlStatus.width = pnlContent.width - 20
    pnlStatus.top = pnlControls.top + pnlControls.height + 10
    
    -- 确保状态面板与窗口底部保持足够距离
    if (pnlStatus.top + pnlStatus.height + bottomMargin) > pnlContent.height do (
        pnlContent.height = pnlStatus.top + pnlStatus.height + bottomMargin
    )
    
    -- 移除并重新添加调整大小控件，确保其位于最上层
    sequence_viewer.controls.remove resizeBox
    
    -- 更新调整大小控件位置
    resizeBox.left = sequence_viewer.width - resizeBoxSize
    resizeBox.top = sequence_viewer.height - resizeBoxSize
    
    -- 重新添加到窗口，确保其位于最上层
    sequence_viewer.controls.add resizeBox
)

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
        if newWidth < 550 do newWidth = 550
        if newHeight < 500 do newHeight = 500
        
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

-- 切换窗口置顶状态
fn toggleTopMost = (
    alwaysOnTop = not alwaysOnTop
    
    -- 设置窗口置顶状态
    if alwaysOnTop then (
        sequence_viewer.TopMost = true
        btn_TopMost.backcolor = GreenColor
        setStatus "窗口已置顶" GreenColor
    ) else (
        sequence_viewer.TopMost = false
        btn_TopMost.backcolor = Ccolor.darkgray
        setStatus "窗口已取消置顶" YellowColor
    )
)

-- 置顶按钮事件
fn onTopMostClick sender e = (
    toggleTopMost()
)
dotnet.addEventHandler btn_TopMost "Click" onTopMostClick

-- 保持窗口与MAX一起显示
fn keepVisibleWithMax = (
    try (
        -- 获取窗口句柄
        if windowHandle == undefined do (
            windowHandle = windows.getHWNDByTitle "序列图片查看器"
        )
        
        -- 将窗口设置为相对于MAX的顶层窗口，但不是置顶窗口
        if windowHandle != undefined and maxHwnd != undefined and not alwaysOnTop do (
            -- 使用windows.setWindowPos使窗口保持在MAX之上但不是全局置顶
            windows.setWindowPos windowHandle maxHwnd 0 0 0 0 (bit.or SWP_NOMOVE SWP_NOSIZE SWP_NOACTIVATE)
            sequence_viewer.BringToFront()
        )
    ) catch()
)

-- 注册窗口激活事件
fn onFormActivated sender e = (
    -- 当我们的窗口激活时，记录状态
    sequence_viewer.tag = dotNetObject "System.Object"
)

fn onFormDeactivated sender e = (
    -- 当我们的窗口失去焦点时，尝试保持可见
    try (
        keepVisibleWithMax()
    ) catch()
)

dotnet.addEventHandler sequence_viewer "Activated" onFormActivated
dotnet.addEventHandler sequence_viewer "Deactivate" onFormDeactivated

-- 初始化
initializeImages()
registerTimeCallback updateCurrentImage

-- 初始调整UI以确保正确的初始布局
resizeUI()

-- 添加额外的窗口特性
sequence_viewer.ShowInTaskbar = false  -- 不在任务栏显示

-- 显示窗口并获取其句柄
dotNet.setLifeTimeControl sequence_viewer #dotNet
sequence_viewer.show()

-- 获取窗口句柄并设置窗口样式
try (
    windowHandle = windows.getHWNDByTitle "序列图片查看器"
    if windowHandle != undefined do (
        -- 添加工具窗口样式，使其不在任务栏显示且更容易与MAX集成
        local exStyle = windows.getWindowLong windowHandle GWL_EXSTYLE
        exStyle = bit.or exStyle WS_EX_TOOLWINDOW
        windows.setWindowLong windowHandle GWL_EXSTYLE exStyle
        
        -- 设置窗口位置，确保它在MAX上面但不是全局置顶
        windows.setWindowPos windowHandle maxHwnd 0 0 0 0 (bit.or SWP_NOMOVE SWP_NOSIZE SWP_SHOWWINDOW)
    )
) catch()

-- 在创建完窗口后将其前置显示
sequence_viewer.BringToFront()