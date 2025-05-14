-- 全局变量
global imageArray = #()            -- 图片数组
global currentFrame = 0            -- 当前帧
global timeShift = 0               -- 时间偏移
global isLoaded = false            -- 是否已加载
global isPlaying = false           -- 播放状态
global loopEnabled = false         -- 循环状态
global lastFrame = 0               -- 最后一帧
global dotNetTimer = undefined     -- 定时器对象
global statusTimer = undefined     -- 状态计时器
global maxHwnd = undefined         -- MAX窗口句柄
global winHwnd = undefined         -- 窗口句柄
global mouseOffset = [0,0]         -- 鼠标偏移
global dragging = 0                -- 拖动状态
global isResizing = false          -- 调整大小状态
global lastValidFrame = 0          -- 最后有效帧
global statusTimeout = 3000        -- 状态显示超时(毫秒)
global showStatusMessage = false   -- 是否显示状态消息

-- Windows API常量
global WS_EX_TRANSPARENT = 0x00000020  -- 透明窗口样式
global GWL_EXSTYLE = -20               -- 扩展窗口样式
global HWND_TOPMOST = -1               -- 全局置顶
global HWND_TOP = 0                    -- 相对置顶
global SWP_NOMOVE = 0x0002             -- 不移动窗口
global SWP_NOSIZE = 0x0001             -- 不改变大小
global SWP_NOACTIVATE = 0x0010         -- 不激活

-- 清理可能存在的旧窗口
try(sequence_viewer.close())catch()

-- 确保兼容各种MAX版本获取MAX窗口句柄
fn getMaxHWND = (
    try (
        local maxHwnd = windows.getMAXHWND()
        if maxHwnd != undefined and maxHwnd != 0 do return maxHwnd
    ) catch()
    
    try (
        -- 备用方式：通过特征标题查找
        local hwnd = windows.getHWNDByTitle "Autodesk 3ds Max"
        if hwnd != undefined and hwnd != 0 do return hwnd
        
        -- 其他常见标题模式
        hwnd = windows.getHWNDByTitle "3ds Max"
        if hwnd != undefined and hwnd != 0 do return hwnd
    ) catch()
    
    -- 返回undefined或0表示获取失败
    undefined
)

-- 获取MAX窗口句柄
try (maxHwnd = getMaxHWND()) catch(print "无法获取MAX窗口句柄")

-- 颜色定义
Ccolor = dotnetclass "system.drawing.color"
TextColor = Ccolor.fromArgb 20 20 20    -- 文字颜色
GreenColor = Ccolor.fromArgb 0 140 0
YellowColor = Ccolor.fromArgb 180 140 0
RedColor = Ccolor.fromArgb 180 0 0

-- 创建主窗口 - 关键点：使用MaxForm并设置父窗口为MAX
sequence_viewer = dotNetObject "MaxCustomControls.MaxForm"
sequence_viewer.width = 680
sequence_viewer.height = 430
sequence_viewer.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").none
sequence_viewer.BackColor = Ccolor.fromArgb 220 220 220  -- 背景色
sequence_viewer.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").Manual
sequence_viewer.ShowInTaskbar = false
sequence_viewer.TopMost = false  -- 默认不使用.NET的全局置顶
sequence_viewer.owner = (dotNetObject "System.Windows.Forms.Form").FromHandle(maxHwnd)
sequence_viewer.text = "BsAnimRef_v1.5"

-- 创建顶部面板
pnlTopBar = dotNetObject "System.Windows.Forms.Panel"
pnlTopBar.width = sequence_viewer.width
pnlTopBar.height = 25
pnlTopBar.top = 0
pnlTopBar.left = 0
pnlTopBar.BackColor = Ccolor.fromArgb 200 200 200  -- 顶部栏背景色
sequence_viewer.controls.add pnlTopBar

-- 创建标题栏
lbl_Title = dotNetObject "label"
lbl_Title.text = "BsAnimRef_v1.5"
lbl_Title.Width = 120
lbl_Title.Height = 20
lbl_Title.left = 8
lbl_Title.top = 3
lbl_Title.forecolor = TextColor
lbl_Title.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 9 ((dotNetClass "System.Drawing.FontStyle").bold))
pnlTopBar.controls.add lbl_Title

-- 透明度标签和滑块
lbl_Opacity = dotNetObject "System.Windows.Forms.Label"
lbl_Opacity.text = "透明度:"
lbl_Opacity.width = 50
lbl_Opacity.height = 20
lbl_Opacity.top = 3
lbl_Opacity.left = 135
lbl_Opacity.forecolor = TextColor
lbl_Opacity.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlTopBar.controls.add lbl_Opacity

sldOpacity = dotNetObject "System.Windows.Forms.TrackBar"
sldOpacity.width = 150
sldOpacity.height = 22
sldOpacity.top = 1
sldOpacity.left = 185
sldOpacity.minimum = 10
sldOpacity.maximum = 100
sldOpacity.value = 100
sldOpacity.TickStyle = (dotNetClass "System.Windows.Forms.TickStyle").None
sldOpacity.AutoSize = false
pnlTopBar.controls.add sldOpacity

-- 创建鼠标穿透按钮
btn_Passthrough = dotnetObject "system.windows.forms.button"
btn_Passthrough.width = 46
btn_Passthrough.height = 22
btn_Passthrough.top = 1
btn_Passthrough.left = (sequence_viewer.width - 160)
btn_Passthrough.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_Passthrough.backcolor = Ccolor.darkgray
btn_Passthrough.forecolor = TextColor
btn_Passthrough.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btn_Passthrough.text = "穿透"
btn_Passthrough.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_Passthrough

-- 创建禅模式按钮
btn_ZenMode = dotnetObject "system.windows.forms.button"
btn_ZenMode.width = 58
btn_ZenMode.height = 22
btn_ZenMode.top = 1
btn_ZenMode.left = (sequence_viewer.width - 280)
btn_ZenMode.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_ZenMode.backcolor = Ccolor.darkgray
btn_ZenMode.forecolor = TextColor
btn_ZenMode.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btn_ZenMode.text = "禅模式"
btn_ZenMode.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_ZenMode

-- 创建最小化按钮
btn_Minimize = dotnetObject "system.windows.forms.button"
btn_Minimize.width = 48
btn_Minimize.height = 22
btn_Minimize.top = 1
btn_Minimize.left = (sequence_viewer.width - 215)
btn_Minimize.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_Minimize.backcolor = Ccolor.darkgray
btn_Minimize.forecolor = TextColor
btn_Minimize.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btn_Minimize.text = "最小化"
btn_Minimize.flatappearance.bordersize = 0
pnlTopBar.controls.add btn_Minimize

-- 创建关闭按钮
btn_Close = dotnetObject "system.windows.forms.button"
btn_Close.width = 25
btn_Close.height = 22
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
pnlContent.width = sequence_viewer.width - 10
pnlContent.height = sequence_viewer.height - 30 - 5  -- 底部边距5
pnlContent.top = 28
pnlContent.left = 5
pnlContent.backColor = Ccolor.fromArgb 220 220 220
sequence_viewer.controls.add pnlContent

-- 创建图片预览区域
picBox = dotNetObject "System.Windows.Forms.PictureBox"
picBox.width = pnlContent.width - 10
picBox.height = pnlContent.height - 45
picBox.top = 5
picBox.left = 5
picBox.sizeMode = picBox.sizeMode.Zoom
picBox.borderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedSingle
picBox.backColor = Ccolor.white
pnlContent.controls.add picBox

-- 创建控制面板
pnlControls = dotNetObject "System.Windows.Forms.Panel"
pnlControls.width = pnlContent.width - 10
pnlControls.height = 38
pnlControls.top = picBox.top + picBox.height + 2
pnlControls.left = 5
pnlControls.BackColor = Ccolor.fromArgb 240 240 240
pnlControls.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedSingle
pnlContent.controls.add pnlControls

-- 创建加载按钮
btnLoad = dotNetObject "System.Windows.Forms.Button"
btnLoad.text = "加载序列图片"
btnLoad.width = 100
btnLoad.height = 25
btnLoad.top = 6
btnLoad.left = 10
btnLoad.BackColor = Ccolor.fromArgb 240 240 240
btnLoad.ForeColor = TextColor
btnLoad.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btnLoad.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnLoad

-- 创建视频转换按钮
btnConverter = dotNetObject "System.Windows.Forms.Button"
btnConverter.text = "视频转序列"
btnConverter.width = 100
btnConverter.height = 25
btnConverter.top = 6
btnConverter.left = btnLoad.left + btnLoad.width + 10
btnConverter.BackColor = Ccolor.fromArgb 240 240 240
btnConverter.ForeColor = TextColor
btnConverter.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
btnConverter.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnConverter

-- 创建循环按钮
chkLoop = dotNetObject "System.Windows.Forms.CheckBox"
chkLoop.text = "循环播放"
chkLoop.width = 90
chkLoop.height = 20
chkLoop.top = 8
chkLoop.left = btnConverter.left + btnConverter.width + 10
chkLoop.enabled = false
chkLoop.forecolor = TextColor
chkLoop.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 9 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlControls.controls.add chkLoop

-- 创建偏移标签和控件
lblTimeShift = dotNetObject "System.Windows.Forms.Label"
lblTimeShift.text = "偏移:"
lblTimeShift.width = 40
lblTimeShift.height = 20
lblTimeShift.top = 9
lblTimeShift.left = 205
lblTimeShift.forecolor = TextColor
lblTimeShift.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlControls.controls.add lblTimeShift

numTimeShift = dotNetObject "System.Windows.Forms.NumericUpDown"
numTimeShift.width = 50
numTimeShift.height = 20
numTimeShift.top = 8
numTimeShift.left = 245
numTimeShift.minimum = -1000
numTimeShift.maximum = 1000
numTimeShift.value = 0
numTimeShift.BackColor = Ccolor.fromArgb 220 220 220
numTimeShift.ForeColor = TextColor
pnlControls.controls.add numTimeShift

-- 创建播放控制按钮
btnStartFrame = dotNetObject "System.Windows.Forms.Button"
btnStartFrame.text = "⏮"
btnStartFrame.width = 35
btnStartFrame.height = 25
btnStartFrame.top = 6
btnStartFrame.left = 310
btnStartFrame.enabled = false
btnStartFrame.BackColor = Ccolor.fromArgb 240 240 240
btnStartFrame.ForeColor = TextColor
btnStartFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnStartFrame

btnPrevFrame = dotNetObject "System.Windows.Forms.Button"
btnPrevFrame.text = "◀"
btnPrevFrame.width = 35
btnPrevFrame.height = 25
btnPrevFrame.top = 6
btnPrevFrame.left = 350
btnPrevFrame.enabled = false
btnPrevFrame.BackColor = Ccolor.fromArgb 240 240 240
btnPrevFrame.ForeColor = TextColor
btnPrevFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnPrevFrame

btnPlay = dotNetObject "System.Windows.Forms.Button"
btnPlay.text = "▶"
btnPlay.width = 35
btnPlay.height = 25
btnPlay.top = 6
btnPlay.left = 390
btnPlay.enabled = false
btnPlay.BackColor = Ccolor.fromArgb 240 240 240
btnPlay.ForeColor = TextColor
btnPlay.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnPlay

btnNextFrame = dotNetObject "System.Windows.Forms.Button"
btnNextFrame.text = "▶"
btnNextFrame.width = 35
btnNextFrame.height = 25
btnNextFrame.top = 6
btnNextFrame.left = 430
btnNextFrame.enabled = false
btnNextFrame.BackColor = Ccolor.fromArgb 240 240 240
btnNextFrame.ForeColor = TextColor
btnNextFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnNextFrame

btnEndFrame = dotNetObject "System.Windows.Forms.Button"
btnEndFrame.text = "⏭"
btnEndFrame.width = 35
btnEndFrame.height = 25
btnEndFrame.top = 6
btnEndFrame.left = 470
btnEndFrame.enabled = false
btnEndFrame.BackColor = Ccolor.fromArgb 240 240 240
btnEndFrame.ForeColor = TextColor
btnEndFrame.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
pnlControls.controls.add btnEndFrame

-- 状态标签
lblStatus = dotNetObject "System.Windows.Forms.Label"
lblStatus.text = "状态: 未加载图片"
lblStatus.width = 200
lblStatus.height = 18
lblStatus.top = 10
lblStatus.left = 520
lblStatus.forecolor = TextColor
lblStatus.font = (dotNetObject "System.Drawing.Font" "微软雅黑" 8 ((dotNetClass "System.Drawing.FontStyle").regular))
pnlControls.controls.add lblStatus

-- 创建调整大小控件
resizeBox = dotNetObject "System.Windows.Forms.Panel"
resizeBox.width = 20
resizeBox.height = 20
resizeBox.left = sequence_viewer.width - 20
resizeBox.top = sequence_viewer.height - 20
resizeBox.BackColor = Ccolor.fromArgb 80 80 80
resizeBox.cursor = (dotNetClass "System.Windows.Forms.Cursors").SizeNWSE
sequence_viewer.controls.add resizeBox

-- 创建状态计时器
statusTimer = dotNetObject "System.Windows.Forms.Timer"
statusTimer.interval = statusTimeout

-- 确保窗口关联到MAX并显示
try(
    -- 使用我们的顶层窗口创建函数
    winHwnd = createTopLevelWindow sequence_viewer maxHwnd
    
    -- 尝试加载配置
    loadConfigData()
)catch()

--------- 函数定义 ---------

-- 清除状态信息函数
fn clearStatus = (
    lblStatus.text = ""
    showStatusMessage = false
    statusTimer.enabled = false
)

-- 设置状态信息
fn setStatus message color = (
    -- 确保状态消息不会太长
    local maxLength = 28
    if message.count > maxLength do (
        message = substring message 1 (maxLength-3) + "..."
    )
    
    -- 设置状态文本和颜色
    lblStatus.text = message
    lblStatus.forecolor = color
    
    -- 重置并启动状态计时器
    if statusTimer != undefined do (
        try(
            -- 移除旧的事件处理器
            dotnet.removeAllEventHandlers statusTimer "Tick"
            
            -- 添加新的事件处理器
            showStatusMessage = true
            dotnet.addEventHandler statusTimer "Tick" clearStatus
            
            -- 启动计时器
            statusTimer.enabled = true
        )catch()
    )
)

-- 加载序列图片
fn loadSequenceImages basePath = 
(
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
    
    if files.count == 0 then 
    (
        messageBox "未找到序列图片！\n请确保文件夹中包含支持的图片格式(.jpg, .jpeg, .png, .bmp)。" title:"错误"
        setStatus "未找到序列图片！" RedColor
        return false
    )
    
    -- 按文件名排序
    sort files
    
    -- 清空当前图片数组
    imageArray = #()
    for f in files do 
    (
        append imageArray f
    )
    
    -- 测试加载第一张图片
    try 
    (
        local testBmp = (dotNetObject "System.Drawing.Bitmap" imageArray[1])
        picBox.image = testBmp
        setStatus ("已加载 " + imageArray.count as string + " 张图片") GreenColor
        
        -- 确保定时器已初始化
        if dotNetTimer == undefined do 
        (
            dotNetTimer = dotNetObject "System.Windows.Forms.Timer"
            dotNetTimer.interval = 40
        )
        
        -- 启用控制按钮
        btnPlay.enabled = true
        btnStartFrame.enabled = true
        btnPrevFrame.enabled = true
        btnNextFrame.enabled = true
        btnEndFrame.enabled = true
        chkLoop.enabled = true
        
        isLoaded = true
        lastFrame = imageArray.count
        lastValidFrame = 0
        
        return true
    ) 
    catch 
    (
        messageBox "加载图片失败！请检查图片格式是否正确。" title:"错误"
        setStatus "加载图片失败" RedColor
        return false
    )
)

-- 更新当前帧的图片
fn updateCurrentImage = 
(
    if imageArray.count > 0 and isLoaded do 
    (
        -- 获取当前帧号并确保是整数
        currentFrame = (sliderTime.frame as integer)
        
        -- 计算引用帧（考虑时间偏移）
        local refFrame = currentFrame - timeShift
        
        -- 更新帧信息显示
        local frameInfo = "当前帧: " + currentFrame as string + " | 引用帧: " + refFrame as string
        lblStatus.text = frameInfo
        
        -- 检查是否在有效范围内
        if refFrame >= 0 and refFrame < imageArray.count then 
        (
            try
            (
                -- 检查文件是否存在
                if doesFileExist imageArray[refFrame + 1] then 
                (
                    -- 使用FileStream加载图片
                    local fs = (dotNetObject "System.IO.FileStream" imageArray[refFrame + 1] (dotNetClass "System.IO.FileMode").Open (dotNetClass "System.IO.FileAccess").Read)
                    local bmp = (dotNetObject "System.Drawing.Bitmap" fs)
                    fs.close()
                    
                    -- 如果当前有图片，先释放它
                    if picBox.image != undefined do 
                    (
                        picBox.image.dispose()
                    )
                    
                    picBox.image = bmp
                    
                    -- 记录最后一个有效帧
                    lastValidFrame = refFrame
                )
            )
            catch()
        ) 
        else 
        (
            -- 处理超出范围的情况
            if loopEnabled then 
            (
                -- 循环播放：回到开始
                if isPlaying then 
                (
                    toggleStopAnimation()
                    sliderTime = timeShift
                    togglePlayAnimation()
                ) 
                else 
                (
                    sliderTime = timeShift
                )
            ) 
            else 
            (
                -- 不循环：显示超出范围消息
                if refFrame < 0 then 
                (
                    sliderTime = timeShift
                ) 
                else if refFrame >= imageArray.count then 
                (
                    sliderTime = timeShift + imageArray.count - 1
                )
                setStatus "帧超出范围" YellowColor
            )
        )
    )
)

-- 鼠标穿透功能 - 使用MAXScript API
fn toggleMousePassthrough = (
    try (
        -- 定义穿透状态
        local newState = not (btn_Passthrough.backcolor.R > 100) -- 通过按钮颜色判断状态
        
        if newState then (
            -- 获取窗口句柄
            if winHwnd != undefined and windows.isWindow winHwnd do (
                -- 获取当前窗口扩展样式
                local exStyle = windows.getWindowLong winHwnd GWL_EXSTYLE
                
                -- 添加WS_EX_TRANSPARENT样式允许鼠标穿透
                exStyle = bit.or exStyle WS_EX_TRANSPARENT
                windows.setWindowLong winHwnd GWL_EXSTYLE exStyle
                
                -- 设置半透明
                sequence_viewer.opacity = 0.7
                sldOpacity.value = 70
                btn_Passthrough.backcolor = GreenColor
                setStatus "已启用穿透模式" GreenColor
            )
        ) else (
            -- 获取窗口句柄
            if winHwnd != undefined and windows.isWindow winHwnd do (
                -- 获取当前窗口扩展样式
                local exStyle = windows.getWindowLong winHwnd GWL_EXSTYLE
                
                -- 移除WS_EX_TRANSPARENT样式
                exStyle = bit.and exStyle (bit.not WS_EX_TRANSPARENT)
                windows.setWindowLong winHwnd GWL_EXSTYLE exStyle
                
                -- 恢复透明度
                sequence_viewer.opacity = 1.0
                sldOpacity.value = 100
                btn_Passthrough.backcolor = Ccolor.darkgray
                setStatus "已禁用穿透模式" YellowColor
            )
        )
    ) catch (
        setStatus "穿透模式切换失败" RedColor
    )
)

-- 计时器回调函数
fn onTimerTick sender event = 
(
    if isPlaying and isLoaded do 
    (
        -- 检查是否超出范围
        if loopEnabled and (sliderTime.frame >= (timeShift + imageArray.count)) do 
        (
            sliderTime = timeShift
        )
        try
        (
            updateCurrentImage()
            sliderTime += 1
        )
        catch()
    )
)

-- 播放动画
fn togglePlayAnimation = 
(
    if isLoaded then 
    (
        -- 确保定时器已经初始化
        if dotNetTimer == undefined do 
        (
            dotNetTimer = dotNetObject "System.Windows.Forms.Timer"
            dotNetTimer.interval = 40 -- 约25帧每秒
        )
        
        isPlaying = true
        btnPlay.text = "⏸"
        numTimeShift.enabled = false
        
        -- 移除所有旧事件处理器，避免重复添加
        try(dotnet.removeAllEventHandlers dotNetTimer "Tick")catch()
        
        -- 添加新的事件处理器
        dotnet.addEventHandler dotNetTimer "Tick" onTimerTick
        
        -- 启动定时器
        dotNetTimer.enabled = true
    )
)

-- 停止动画
fn toggleStopAnimation = 
(
    isPlaying = false
    btnPlay.text = "▶"
    numTimeShift.enabled = true
    
    -- 确保定时器存在并停止它
    if dotNetTimer != undefined do 
    (
        try(dotNetTimer.enabled = false)catch()
    )
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

-- 事件处理函数定义
fn onOpacityChanged obj e = (sequence_viewer.opacity = obj.value / 100.0)
fn onLoadClick obj e = (
    local path = getSavePath caption:"选择序列图片所在文件夹"
    if path != undefined do loadSequenceImages path
)
fn onCloseClick obj e = (sequence_viewer.dispose())
fn onTimeShiftChanged obj e = (updateTimeShift())
fn onPlayClick obj e = (
    if isPlaying then toggleStopAnimation() else togglePlayAnimation()
)
fn onNextFrameClick obj e = (nextFrame())
fn onPrevFrameClick obj e = (previousFrame())
fn onStartFrameClick obj e = (startFrame())
fn onEndFrameClick obj e = (endFrame())
fn onLoopChecked obj e = (loopEnabled = obj.checked)
fn onPassthroughClick obj e = (toggleMousePassthrough())
fn onTopMostClick obj e = (
    try (
        -- 使用窗口句柄方式切换置顶状态
        local isTop = (btn_TopMost.backcolor != GreenColor)
        
        if isTop then (
            if winHwnd != undefined and maxHwnd != undefined do (
                -- 确保窗口是3ds Max的子窗口
                sequence_viewer.TopMost = false
                sequence_viewer.owner = (dotNetObject "System.Windows.Forms.Form").FromHandle(maxHwnd)
                
                -- 只使用SetParent使其成为3ds Max的子窗口(仅在MAX内置顶)
                windows.setParent winHwnd maxHwnd
                
                btn_TopMost.backcolor = GreenColor
                setStatus "已启用3ds Max内置顶" GreenColor
            )
        ) else (
            if winHwnd != undefined and maxHwnd != undefined do (
                -- 取消置顶效果
                sequence_viewer.TopMost = false
                windows.setParent winHwnd maxHwnd
                
                btn_TopMost.backcolor = Ccolor.darkgray
                setStatus "已禁用置顶模式" YellowColor
            )
        )
    ) catch (
        setStatus "置顶模式切换失败" RedColor
    )
)
fn onMinimizeClick obj e = (
    sequence_viewer.WindowState = (dotNetClass "System.Windows.Forms.FormWindowState").Minimized
)
fn onFormClosing obj e = (
    try (
        -- 保存窗口尺寸和透明度
        saveConfigData()
        
        -- 注销计时器回调以防止内存泄漏或崩溃
        if dotNetTimer != undefined do (
            try (
                if dotNetTimer.enabled do dotNetTimer.enabled = false
                dotNetTimer.dispose()
            ) catch()
            dotNetTimer = undefined
        )
    ) catch()
)

-- 拖动函数
fn onFormMouseDown obj e = (
    mouseOffset[1] = mouse.screenPos.x - sequence_viewer.left
    mouseOffset[2] = mouse.screenPos.y - sequence_viewer.top
    dragging = 1
)

fn onFormMouseMove obj e = (
    if dragging == 1 do (
        sequence_viewer.left = mouse.screenpos.x - mouseOffset[1]
        sequence_viewer.top = mouse.screenpos.y - mouseOffset[2]
    )
)

fn onFormMouseUp obj e = (
    dragging = 0
)

-- 调整大小函数
fn onResizeMouseDown obj e = (
    isResizing = true
    mouseOffset[1] = mouse.screenPos.x
    mouseOffset[2] = mouse.screenPos.y
)

fn onResizeMouseMove obj e = (
    if isResizing do (
        local newWidth = sequence_viewer.width + (mouse.screenPos.x - mouseOffset[1])
        local newHeight = sequence_viewer.height + (mouse.screenPos.y - mouseOffset[1])
        
        if newWidth < 680 do newWidth = 680
        if newHeight < 430 do newHeight = 430
        
        sequence_viewer.width = newWidth
        sequence_viewer.height = newHeight
        
        -- 更新布局
        pnlTopBar.width = sequence_viewer.width
        btn_ZenMode.left = sequence_viewer.width - 280
        btn_Minimize.left = sequence_viewer.width - 215
        btn_Passthrough.left = sequence_viewer.width - 105
        btn_Close.left = sequence_viewer.width - 35
        
        pnlContent.width = sequence_viewer.width - 10
        pnlContent.height = sequence_viewer.height - 30 - 5
        
        picBox.width = pnlContent.width - 10
        picBox.height = pnlContent.height - 45
        
        pnlControls.width = pnlContent.width - 10
        pnlControls.top = picBox.top + picBox.height + 2
        
        resizeBox.left = sequence_viewer.width - 20
        resizeBox.top = sequence_viewer.height - 20
        
        -- 更新鼠标位置
        mouseOffset[1] = mouse.screenPos.x
        mouseOffset[2] = mouse.screenPos.y
    )
)

fn onResizeMouseUp obj e = (
    isResizing = false
)

-- 鼠标滚轮事件
fn onMouseWheel obj e = (
    if isLoaded do (
        -- 检查滚轮方向
        local delta = e.delta
        local frames = if keyboard.controlPressed then 5 else 1
        
        -- 向上滚动增加帧，向下滚动减少帧
        if delta > 0 then (
            sliderTime += frames
        ) else (
            sliderTime -= frames
        )
    )
    -- 表示事件已处理
    e.handled = true
)

-- 视频转换器点击处理函数
fn onConverterClick obj e = (openVideoConverter())

-- 禅模式按钮事件
fn onZenModeClick obj e = (toggleZenMode())

-- 事件注册
fn registerEvents = (
    -- 透明度滑块
    dotnet.addEventHandler sldOpacity "ValueChanged" onOpacityChanged
    
    -- 加载按钮
    dotnet.addEventHandler btnLoad "Click" onLoadClick
    
    -- 视频转换按钮
    dotnet.addEventHandler btnConverter "Click" onConverterClick
    
    -- 关闭按钮
    dotnet.addEventHandler btn_Close "Click" onCloseClick
    
    -- 禅模式按钮
    dotnet.addEventHandler btn_ZenMode "Click" onZenModeClick
    
    -- 时间偏移
    dotnet.addEventHandler numTimeShift "ValueChanged" onTimeShiftChanged
    
    -- 播放控制
    dotnet.addEventHandler btnPlay "Click" onPlayClick
    
    -- 帧控制
    dotnet.addEventHandler btnNextFrame "Click" onNextFrameClick
    dotnet.addEventHandler btnPrevFrame "Click" onPrevFrameClick
    dotnet.addEventHandler btnStartFrame "Click" onStartFrameClick
    dotnet.addEventHandler btnEndFrame "Click" onEndFrameClick
    
    -- 循环播放
    dotnet.addEventHandler chkLoop "CheckedChanged" onLoopChecked
    
    -- 鼠标穿透
    dotnet.addEventHandler btn_Passthrough "Click" onPassthroughClick
    
    -- 最小化
    dotnet.addEventHandler btn_Minimize "Click" onMinimizeClick
    
    -- 窗口拖动
    dotnet.addEventHandler pnlTopBar "MouseDown" onFormMouseDown
    dotnet.addEventHandler lbl_Title "MouseDown" onFormMouseDown
    dotnet.addEventHandler pnlTopBar "MouseMove" onFormMouseMove
    dotnet.addEventHandler lbl_Title "MouseMove" onFormMouseMove
    dotnet.addEventHandler pnlTopBar "MouseUp" onFormMouseUp
    dotnet.addEventHandler lbl_Title "MouseUp" onFormMouseUp
    
    -- 调整大小
    dotnet.addEventHandler resizeBox "MouseDown" onResizeMouseDown
    dotnet.addEventHandler resizeBox "MouseMove" onResizeMouseMove
    dotnet.addEventHandler sequence_viewer "MouseMove" onResizeMouseMove
    dotnet.addEventHandler resizeBox "MouseUp" onResizeMouseUp
    dotnet.addEventHandler sequence_viewer "MouseUp" onResizeMouseUp
    
    -- 添加窗口关闭时的清理
    dotnet.addEventHandler sequence_viewer "FormClosed" onFormClosing
    
    -- 鼠标滚轮事件
    dotnet.addEventHandler sequence_viewer "MouseWheel" onMouseWheel
)

-- 注册所有事件
registerEvents()

-- 初始化设置
fn initializeImages = (
    imageArray = #()
    currentFrame = 0
    isLoaded = false
    lastFrame = 0
    
    -- 创建新的定时器
    if dotNetTimer != undefined do dotNetTimer.enabled = false
    dotNetTimer = dotNetObject "System.Windows.Forms.Timer"
    dotNetTimer.interval = 40
    
    -- 禁用控制按钮
    btnPlay.enabled = false
    btnStartFrame.enabled = false
    btnPrevFrame.enabled = false
    btnNextFrame.enabled = false
    btnEndFrame.enabled = false
    chkLoop.enabled = false
    chkLoop.checked = false
    loopEnabled = false
    
    -- 设置状态文本（注意：不要在函数最后一行直接设置属性）
    lblStatus.text = "状态: 未加载图片"
    
    -- 返回true以确保函数不返回字符串值
    true
)

-- 执行初始化
initializeImages()

-- 视频转换功能
fn openVideoConverter = (
    try (
        -- 检查存放转换器的目录
        local toolsDir = (getDir #scripts) + "\\BulletScripts\\Tools\\"
        local converterPath = toolsDir + "video_to_sequence.exe"
        
        -- 确保目录存在
        if not doesFileExist toolsDir do makeDir toolsDir
        
        -- 检查转换器是否存在
        if doesFileExist converterPath then (
            -- 直接打开转换器
            shellLaunch converterPath ""
            setStatus "已启动视频转换器" GreenColor
        ) else (
            -- 询问是否下载转换器
            local response = queryBox "视频转换器未找到。是否下载视频转换器？\n这将从网络下载video_to_sequence.exe。" title:"下载转换器"
            
            if response then (
                -- 下载转换器
                local downloadUrl = "https://raw.githubusercontent.com/ShirzadBh/AnimRef/main/AnimRef/Contents/converter/video_to_sequence.exe"
                
                -- 显示下载状态
                setStatus "正在下载转换器..." YellowColor
                
                -- 使用dotNet下载
                local webClient = dotNetObject "System.Net.WebClient"
                webClient.DownloadFile downloadUrl converterPath
                
                -- 检查是否下载成功
                if doesFileExist converterPath then (
                    shellLaunch converterPath ""
                    setStatus "转换器下载成功并启动" GreenColor
                ) else (
                    setStatus "下载失败，请检查网络连接" RedColor
                )
            )
        )
    ) catch (
        setStatus "无法启动视频转换器" RedColor
    )
)

-- 禅模式功能
fn toggleZenMode = (
    try (
        local isZenMode = (btn_ZenMode.backcolor == GreenColor)
        
        if isZenMode then (
            -- 恢复正常模式
            pnlControls.visible = true
            btn_ZenMode.backcolor = Ccolor.darkgray
            setStatus "已退出禅模式" YellowColor
        ) else (
            -- 进入禅模式
            pnlControls.visible = false
            btn_ZenMode.backcolor = GreenColor
            setStatus "已进入禅模式" GreenColor
        )
    ) catch (
        setStatus "切换禅模式失败" RedColor
    )
)

-- 保存配置数据
fn saveConfigData = (
    try (
        local configFile = (getDir #scripts) + "\\BulletScripts\\animref_config.ini"
        local file = createFile configFile
        if file != undefined then (
            format "width=%\n" sequence_viewer.width to:file
            format "height=%\n" sequence_viewer.height to:file
            format "opacity=%\n" sldOpacity.value to:file
            close file
            return true
        )
    ) catch()
    return false
)

-- 加载配置数据
fn loadConfigData = (
    try (
        local configFile = (getDir #scripts) + "\\BulletScripts\\animref_config.ini"
        if doesFileExist configFile then (
            local file = openFile configFile
            if file != undefined then (
                local str = readLine file
                local width = 680 -- 默认值
                if str != undefined and str != "" then (
                    local pos = findString str "width="
                    if pos != undefined then 
                        width = (substring str (pos + 6) -1) as integer
                )
                
                str = readLine file
                local height = 430 -- 默认值
                if str != undefined and str != "" then (
                    local pos = findString str "height="
                    if pos != undefined then 
                        height = (substring str (pos + 7) -1) as integer
                )
                
                str = readLine file
                local opacity = 100 -- 默认值
                if str != undefined and str != "" then (
                    local pos = findString str "opacity="
                    if pos != undefined then 
                        opacity = (substring str (pos + 8) -1) as integer
                )
                
                close file
                
                -- 设置窗口尺寸
                sequence_viewer.width = width
                sequence_viewer.height = height
                sldOpacity.value = opacity
                
                -- 更新布局
                pnlTopBar.width = sequence_viewer.width
                btn_ZenMode.left = sequence_viewer.width - 280
                btn_Minimize.left = sequence_viewer.width - 215
                btn_Passthrough.left = sequence_viewer.width - 105
                btn_Close.left = sequence_viewer.width - 35
                
                pnlContent.width = sequence_viewer.width - 10
                pnlContent.height = sequence_viewer.height - 30 - 5
                
                picBox.width = pnlContent.width - 10
                picBox.height = pnlContent.height - 45
                
                pnlControls.width = pnlContent.width - 10
                pnlControls.top = picBox.top + picBox.height + 2
                
                resizeBox.left = sequence_viewer.width - 20
                resizeBox.top = sequence_viewer.height - 20
                
                return true
            )
        )
    ) catch()
    return false
)

-- 创建适合3dsMax的窗口
fn createTopLevelWindow theForm maxHwnd = (
    -- 使用更安全的方式获取MAX窗口并显示
    local thePtr = DotNetObject "System.IntPtr" maxHwnd
    local theHwnd = dotNetObject "System.Windows.Forms.Control"
    theHwnd = theHwnd.fromHandle thePtr
    theForm.Show(theHwnd)
    
    -- 返回窗口句柄
    windows.getHWNDByTitle theForm.text
)