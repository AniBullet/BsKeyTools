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
global dotNetTimer = dotNetObject "System.Windows.Forms.Timer"

-- 清理可能存在的旧窗口
try(sequence_viewer.close())catch()

-- 颜色定义
Ccolor = dotnetclass "system.drawing.color"
BackGrey = (dotNetClass "system.drawing.color").fromArgb 29 29 29
TopbarGrey = (dotNetClass "system.drawing.color").fromArgb 73 73 73
GreenColor = (dotNetClass "system.drawing.color").fromArgb 152 252 3
YellowColor = (dotNetClass "system.drawing.color").fromArgb 252 190 3
RedColor = (dotNetClass "system.drawing.color").fromArgb 252 82 3

-- 创建主窗口
sequence_viewer = dotNetObject "MaxCustomControls.MaxForm"
sequence_viewer.AllowTransparency = true
sequence_viewer.opacity = 1
sequence_viewer.width = 600
sequence_viewer.height = 600
sequence_viewer.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").none

-- 创建标题栏
lbl_Title = dotNetObject "label"
lbl_Title.text = "序列图片查看器"
lbl_Title.Width = sequence_viewer.width
lbl_Title.Height = 23
lbl_Title.left = 5
lbl_Title.top = 11
lbl_Title.forecolor = Ccolor.green
sequence_viewer.controls.add lbl_Title

-- 创建置顶按钮
btn_TopMost = dotnetObject "system.windows.forms.button"
btn_TopMost.width = 35
btn_TopMost.height = 34
btn_TopMost.top = 0
btn_TopMost.left = (sequence_viewer.width-70)
btn_TopMost.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_TopMost.backcolor = Ccolor.lightgray
btn_TopMost.forecolor = Ccolor.dimgray
btn_TopMost.font = (dotNetObject "System.Drawing.Font" "Verdana" 10 ((dotNetClass "System.Drawing.FontStyle").bold))
btn_TopMost.text = "📌"
btn_TopMost.flatappearance.bordersize = 0
sequence_viewer.controls.add btn_TopMost

-- 创建关闭按钮
btn_Close = dotnetObject "system.windows.forms.button"
btn_Close.width = 35
btn_Close.height = 34
btn_Close.top = 0
btn_Close.left = (sequence_viewer.width-35)
btn_Close.flatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").flat
btn_Close.backcolor = Ccolor.lightgray
btn_Close.forecolor = Ccolor.dimgray
btn_Close.font = (dotNetObject "System.Drawing.Font" "Verdana" 10 ((dotNetClass "System.Drawing.FontStyle").bold))
btn_Close.text = "x"
btn_Close.flatappearance.bordersize = 0
sequence_viewer.controls.add btn_Close

-- 创建透明度滑块
sldOpacity = dotNetObject "System.Windows.Forms.TrackBar"
sldOpacity.width = 300
sldOpacity.height = 45
sldOpacity.top = 40
sldOpacity.left = 10
sldOpacity.minimum = 10
sldOpacity.maximum = 100
sldOpacity.value = 100
sldOpacity.tickFrequency = 10
sequence_viewer.controls.add sldOpacity

-- 创建图片预览区域
picBox = dotNetObject "System.Windows.Forms.PictureBox"
picBox.width = 300
picBox.height = 300
picBox.top = 90
picBox.left = 10
picBox.sizeMode = picBox.sizeMode.Zoom
picBox.backColor = Ccolor.White
sequence_viewer.controls.add picBox

-- 创建状态标签
lblStatus = dotNetObject "System.Windows.Forms.Label"
lblStatus.text = "状态: 未加载图片"
lblStatus.width = 300
lblStatus.height = 20
lblStatus.top = 400
lblStatus.left = 10
sequence_viewer.controls.add lblStatus

-- 创建帧计数标签
lblMaxFrame = dotNetObject "System.Windows.Forms.Label"
lblMaxFrame.text = "当前帧: 0"
lblMaxFrame.width = 150
lblMaxFrame.height = 20
lblMaxFrame.top = 420
lblMaxFrame.left = 10
sequence_viewer.controls.add lblMaxFrame

-- 创建引用帧标签
lblRefFrame = dotNetObject "System.Windows.Forms.Label"
lblRefFrame.text = "引用帧: 0"
lblRefFrame.width = 150
lblRefFrame.height = 20
lblRefFrame.top = 420
lblRefFrame.left = 160
sequence_viewer.controls.add lblRefFrame

-- 创建时间偏移控件
lblTimeShift = dotNetObject "System.Windows.Forms.Label"
lblTimeShift.text = "时间偏移:"
lblTimeShift.width = 80
lblTimeShift.height = 20
lblTimeShift.top = 450
lblTimeShift.left = 10
sequence_viewer.controls.add lblTimeShift

numTimeShift = dotNetObject "System.Windows.Forms.NumericUpDown"
numTimeShift.width = 60
numTimeShift.height = 20
numTimeShift.top = 450
numTimeShift.left = 90
numTimeShift.minimum = -1000
numTimeShift.maximum = 1000
numTimeShift.value = 0
sequence_viewer.controls.add numTimeShift

-- 创建加载按钮
btnLoad = dotNetObject "System.Windows.Forms.Button"
btnLoad.text = "加载序列图片"
btnLoad.width = 150
btnLoad.height = 30
btnLoad.top = 480
btnLoad.left = 10
sequence_viewer.controls.add btnLoad

-- 创建控制按钮面板
pnlControls = dotNetObject "System.Windows.Forms.Panel"
pnlControls.width = 300
pnlControls.height = 40
pnlControls.top = 510
pnlControls.left = 10
sequence_viewer.controls.add pnlControls

-- 开始帧按钮
btnStartFrame = dotNetObject "System.Windows.Forms.Button"
btnStartFrame.text = "⏮"
btnStartFrame.width = 40
btnStartFrame.height = 30
btnStartFrame.top = 5
btnStartFrame.left = 10
btnStartFrame.enabled = false
pnlControls.controls.add btnStartFrame

-- 上一帧按钮
btnPrevFrame = dotNetObject "System.Windows.Forms.Button"
btnPrevFrame.text = "◀"
btnPrevFrame.width = 40
btnPrevFrame.height = 30
btnPrevFrame.top = 5
btnPrevFrame.left = 60
btnPrevFrame.enabled = false
pnlControls.controls.add btnPrevFrame

-- 播放按钮
btnPlay = dotNetObject "System.Windows.Forms.Button"
btnPlay.text = "▶"
btnPlay.width = 40
btnPlay.height = 30
btnPlay.top = 5
btnPlay.left = 110
btnPlay.enabled = false
pnlControls.controls.add btnPlay

-- 下一帧按钮
btnNextFrame = dotNetObject "System.Windows.Forms.Button"
btnNextFrame.text = "▶"
btnNextFrame.width = 40
btnNextFrame.height = 30
btnNextFrame.top = 5
btnNextFrame.left = 160
btnNextFrame.enabled = false
pnlControls.controls.add btnNextFrame

-- 结束帧按钮
btnEndFrame = dotNetObject "System.Windows.Forms.Button"
btnEndFrame.text = "⏭"
btnEndFrame.width = 40
btnEndFrame.height = 30
btnEndFrame.top = 5
btnEndFrame.left = 210
btnEndFrame.enabled = false
pnlControls.controls.add btnEndFrame

-- 创建循环按钮
chkLoop = dotNetObject "System.Windows.Forms.CheckBox"
chkLoop.text = "循环播放"
chkLoop.width = 100
chkLoop.height = 20
chkLoop.top = 450
chkLoop.left = 160
chkLoop.enabled = false
sequence_viewer.controls.add chkLoop

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
    lblMaxFrame.text = "当前帧: 0"
    lblRefFrame.text = "引用帧: 0"
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
    try(
        local testBmp = (dotNetObject "System.Drawing.Bitmap" imageArray[1])
        picBox.image = testBmp
        lblStatus.text = "状态: 已加载 " + imageArray.count as string + " 张图片"
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
    )catch(
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
        lblMaxFrame.text = "当前帧: " + currentFrame as string
        lblRefFrame.text = "引用帧: " + refFrame as string
        
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

-- 切换循环播放
fn toggleLoop sender args = (
    loopEnabled = chkLoop.checked
)

-- 事件处理
fn onOpacityChanged sender e = (
    sequence_viewer.opacity = sldOpacity.value / 100.0
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

-- 窗口拖动
global mouseOffset = [0,0]
global dragging = 0

fn onTitleMouseDown sender e = (
    mouseOffset[1] = mouse.screenPos.x - sequence_viewer.left
    mouseOffset[2] = mouse.screenPos.y - sequence_viewer.top
    global dragging = 1
)
dotnet.addEventHandler lbl_Title "MouseDown" onTitleMouseDown

fn onTitleMouseMove sender e = (
    if dragging == 1 do (
        sequence_viewer.left = mouse.screenpos.x - mouseOffset[1]
        sequence_viewer.top = mouse.screenpos.y - mouseOffset[2]
    )
)
dotnet.addEventHandler lbl_Title "MouseMove" onTitleMouseMove

fn onTitleMouseUp sender e = (
    global dragging = 0
)
dotnet.addEventHandler lbl_Title "MouseUp" onTitleMouseUp

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
        btn_TopMost.backcolor = Ccolor.lightgray
        setStatus "窗口已取消置顶" YellowColor
    )
)

-- 置顶按钮事件
fn onTopMostClick sender e = (
    toggleTopMost()
)
dotnet.addEventHandler btn_TopMost "Click" onTopMostClick

-- 初始化
initializeImages()
registerTimeCallback updateCurrentImage

-- 设置窗口位置
fn getScreenResolution = (
    screen = (dotNetClass "System.Windows.Forms.Screen").PrimaryScreen.Bounds
    return #(screen.Width, screen.Height)
)
res = getScreenResolution()
ResWidth = (res[1]/2)-(sequence_viewer.width/2)
ResHeight = (res[2]/2)-(sequence_viewer.height/2)
sequence_viewer.top = ResHeight
sequence_viewer.left = ResWidth

-- 显示窗口
dotNet.setLifeTimeControl sequence_viewer #dotNet
sequence_viewer.showModeless()