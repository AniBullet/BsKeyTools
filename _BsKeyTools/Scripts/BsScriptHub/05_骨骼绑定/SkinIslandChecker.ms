/*
macroScript SkinIslandChecker
category: "QdzTools"
tooltip: "飞点检查"
/*26.1.22 
    待解决：
        1.速度慢。
        2.判断逻辑待优化。
        3.是不是要添加修复功能。
        4.UI  。   
26.1.23 
    更新：
        1.使用bitary对比优化了速度。
        2.使用dotnet丰富了UI。
        3.添加日志框功能。
        4.判断逻辑优化：只有一块岛的骨骼不算飞点。
        5.问许：如果不在modfiy界面获取蒙皮点内容（使用skinOps一定要在对应的界面下，否则获取的内容为空）。        skinUtils.ShrinkSelection currentObj可不在modfiy下获取  fn_quickGetSelectedVerts
        6.添加初版 右键菜单《修复》功能。
        7.添加画圈标记功能。
        8.修改左上角ICON。
        9.添加进度条提示功能。
    
26.1.26 
    更新：
        1.使用预缓存功能优化了速度。
        2.使用dotnet进一步丰富了UI。
        3.添加日志框避免弹错脚本终止。
        4.修复空选节点报错问题。
    
26.1.27 fn_
    更新：
        1.日志框改为富文本框，用不同的颜色提示不同的日志
        2.调整日志，最后提示线&面&骨骼数量。
        3.进一步优化处理速度。bitary。
        4.提示处理时间。
    
26.1.28 
    更新：
        1.兼容低版本，使用不同的Api处理以20为分界的文件   低版本(以20往下)后面不能跟参数，识别错误：skinOps.GetNumberBones currentSkinMod node:currentObj
        待处理：需要整合一下这个两个API文件。
    
26.2.2 
    更新：
        1.更新帮助文档。
        2.添加忽略功能，目前使用最多五个点设计哈希字符串来储存。
         【Bone_HatB03_M】          ← 有忽略项，显示紫色
             区域 1: 6 个问题顶点   ← 已忽略
             区域 2: 6 个问题顶点   ← 已修复
         【Bone_HatB01_L】          ← 全部修复，显示绿色
             区域 1: 2 个问题顶点   ← 已修复
         【Bone_HatB02_R】          ← 有未处理项，显示红色
             区域 1: 3 个问题顶点   ← 未处理
    
26.2.3 
    更新：
        1.解决处理函数高度重复的问题。
        2.添加动态修复，1-20前期快速修复飞点问题，20-50后期细致调整，避免过度平滑。
    
26.2.3 
    更新：
        1.Mesh节点标记功能失效重置
26.2.9
    更新：
        1.将除了主岛以外的岛做两次收缩测试
        2.如果无法判断出主岛的话，列出所有的岛
26.2.11
    更新：
        1.设置骨骼栏不可选
        2.将忽略内容放在列表最下面
*/
--macroScript SkinIslandChecker
--category: "QdzTools"
--tooltip: "飞点检查"
(
try (DestroyDialog ::SkinIslandChecker) catch()
rollout SkinIslandChecker "SkinIslateChecker v1.02" width:300 height:460
(
    GroupBox 'grp_object' "" pos:[10,10] width:280 height:43 
    button 'btn_help' "🗯" pos:[280,440] width:15 height:15 
    dotNetControl 'edt_selection' "System.Windows.Forms.TextBox" pos:[20,23] width:260 height:60
    GroupBox 'grp_problems' "" pos:[10,55] width:280 height:250 
    dotNetControl 'lst_problems' "System.Windows.Forms.ListView" pos:[20,67] width:260 height:225
    progressBar 'pb3' "" pos:[10,309] width:280 height:4 color:red
    GroupBox 'grp_log' "" pos:[10,310] width:280 height:120 
    dotNetControl 'edt_log' "System.Windows.Forms.RichTextBox" pos:[20,323] width:260 height:95
    dotNetControl 'contextMenu' "System.Windows.Forms.ContextMenuStrip"
    button 'btn_check' "检 查" pos:[20,435] width:120 height:20 toolTip:"左键单击精确检查，右键单击宽泛检查..."  --images:#("FileLinkActionItems_24i.bmp","FileLinkActionItems_24i.bmp",9,3,4,0,0,false,true) 
    button 'btn_clear' "清 除" pos:[160,435] width:120 height:20  toolTip:"左键单击重置列表，右键单击清楚选择标记..."
    local problemBones = #()
    local logText = ""
    local currentObj = undefined
    local currentSkinMod = undefined
    local vertexDataMap = #()
    local markedVertices = #()
    local roundInfoList = #()
    local ignoredRegions = #()   -- 存储被忽略的区域，重开脚本重置
    local fixedRegions = #()     -- 临时，存储本次检查中被修复的区域（重新检查时清空）

    fn fn_helpText =
    (
        messageBox "蒙皮飞点检查工具使用说明:\n
        1.选择蒙皮的模型。(多选也只处理第一个) \n
        2.点击≮检 查≯开始检查尝试检查蒙皮问题。\n          检查有两种方式≮左键点击≯宽泛检查，≮右键点击\n          ≯细致检查。(建议使用宽泛检查)\n
        3.如有问题，≮双击≯区域可跳转至问题蒙皮点并标\n          记，≮右键点击≯可选择修复（最好修复完自己检查\n          一下）。≮点击忽略≯可标记出来为紫色,不关闭脚\n          本下次检查依然生效。\n
        4.右键点击≮清 除≯可以临时清除蒙皮点标记，\n          左侧点击清除重置所有节点。\n
        5.脚本以2020分界使用不同的Api低版本运行速度相比\n          高版本慢2~5倍左右。使用20及以后版本获得更优\n          体验。\n
                                                                By：虹 
        " title:"使用说明" beep:false fgcolor:[100,200,100]
    )
    fn fn_getVertexHash boneName vertArray = ( --使用骨骼名称与最多前五个点组成唯一哈希字符串 用来标记忽略区域
        -- 排序顶点数组以确保一致性
        local sortedVerts = sort (deepCopy vertArray)
        -- 取前几个顶点和总数作为签名（避免字符串过长）
        local hashStr = boneName + "_"
        hashStr += sortedVerts.count as string + "_"
        -- 取最多前5个顶点ID(数量已经足够区分，极少数情况下会冲突，也是节省性能)
        local sampleCount = amin #(5, sortedVerts.count)
        for i = 1 to sampleCount do
            hashStr += sortedVerts[i] as string + "_"
        return hashStr
    )
    --获取一下版本用来使用不同的API处理
    fn fn_getMaxVersion =(
        maxVes = ((maxVersion())[1] / 1000 + 1998)
        return (maxVes as integer)
    )
    -- 标记一下左上角Icon
    fn fn_string2Bmp string = (
        clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
        ConvertClass = dotnetclass "system.convert"
        imageclass = dotNetclass "System.Drawing.image"
        bytearr = convertclass.FromBase64String string
        memstream = dotnetobject "System.IO.MemoryStream" bytearr
        DecodedImg = ImageClass.fromstream memstream
        memstream.close()
        DecodedImg
    )
    fn fn_loadMyLogoAsTitlebarIcon = (
        logoIcon = "iVBORw0KGgoAAAANSUhEUgAAAC8AAAAwCAYAAACBpyPiAAAACXBIWXMAAAsTAAALEwEAmpwYAAAF82lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDMgMTE2LmRkYzdiYzQsIDIwMjEvMDgvMTctMTM6MTg6MzcgICAgICAgICI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCAyMS4yIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjYtMDItMDJUMTc6NTc6NTgrMDg6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI2LTAyLTAyVDE4OjAyOjM5KzA4OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI2LTAyLTAyVDE4OjAyOjM5KzA4OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgcGhvdG9zaG9wOklDQ1Byb2ZpbGU9InNSR0IgSUVDNjE5NjYtMi4xIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjk5M2MyNzRkLWEzN2YtM2Y0Yi04OTc2LTAzMGUxNzY3MzcyOSIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmMwZGZkN2EwLTJhMTktZjQ0NC04NWVjLWIwZTU3MTdjNmZjYiIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjliMTIzM2NkLTA5YmEtMTM0Yi1iZDg1LTdhY2E3ZjFjMDQyMSI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6OWIxMjMzY2QtMDliYS0xMzRiLWJkODUtN2FjYTdmMWMwNDIxIiBzdEV2dDp3aGVuPSIyMDI2LTAyLTAyVDE3OjU3OjU4KzA4OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjEuMiAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjk5M2MyNzRkLWEzN2YtM2Y0Yi04OTc2LTAzMGUxNzY3MzcyOSIgc3RFdnQ6d2hlbj0iMjAyNi0wMi0wMlQxODowMjozOSswODowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PvHAf+AAAAsmSURBVGiB7Zp5jF3Vfcc/5+5vn3lvdns8HhsvOC7GMI5xDA1ODBEBQpPgNBGEqEppTVqSVKKBtqkyaRVQlEhkcRKJSkGNHGKgSZRgCAZiO1AzDnYj4/E+XsYz4/HMvDdvm7fc5d17+k/HOMX2eHkIIeX77z339/3od3/3nN895wopJe9VKe82wJXoPQ2vAQgh3pHg/7B/OJnVrVWucCIW1W1PLliQrkfc6VJ/xzLfu39/tNjQsfugq2we1Bqf9mKzN/Xu3h2up8c7Bl9uX/LT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"
        d = (windows.getChildHWND 0 ::SkinIslandChecker.title)[1]
        WM_SETICON = 0x0080
        ICON_SMALL = 0
        bm = dotnetobject "System.Drawing.Bitmap" (fn_string2Bmp logoIcon)         
        ptr = bm.GetHicon()
        icon = (dotnetclass "System.Drawing.Icon").FromHandle (dotnetobject "IntPtr" ptr)           
        windows.SendMessage d WM_SETICON ICON_SMALL icon.handle
    )
    -- 初始化选择对象文本框
    fn fn_initSelectionControl = (
        edt_selection.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 43 43 43
        edt_selection.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 255 180 180
        edt_selection.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").None
        edt_selection.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei UI" 10
        edt_selection.ReadOnly = true
        edt_selection.Text = "未选择对象..."
        edt_selection.TextAlign = (dotNetClass "System.Windows.Forms.HorizontalAlignment").Left 
    )
    -- 修改初始化列表控件函数
    fn fn_initListControl = (
        lst_problems.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 43 43 43
        lst_problems.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
        lst_problems.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").None
        lst_problems.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei UI" 10
        lst_problems.View = (dotNetClass "System.Windows.Forms.View").Details
        lst_problems.FullRowSelect = true
        lst_problems.GridLines = false
        lst_problems.HeaderStyle = (dotNetClass "System.Windows.Forms.ColumnHeaderStyle").None
        lst_problems.OwnerDraw = true            
        lst_problems.Columns.Add "" 360
        local menuItem = contextMenu.Items.Add "•   选择    "
        local menuItem = contextMenu.Items.Add "•   修复    "
        local menuItem = contextMenu.Items.Add "•   忽略    "
        local menuItem = contextMenu.Items.Add "•   取消忽略    "
        local menuItem = contextMenu.Items.Add "•   全选    "
        menuItem.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei UI" 9
    )
    -- 初始化日志控件
    fn fn_initLogControl = (
        edt_log.Multiline = true
        edt_log.ReadOnly = true
        edt_log.ScrollBars = (dotNetClass "System.Windows.Forms.RichTextBoxScrollBars").Vertical
        edt_log.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 43 43 43
        edt_log.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 144 238 144
        edt_log.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").none
        edt_log.Font = dotNetObject "System.Drawing.Font" "Consolas" 9
        edt_log.DetectUrls = false
        --edt_log.WordWrap = false  -- 不自动换行
    )
    --日志 ：根据不同的操作返回不同颜色的日志
    fn fn_addLog msg level:#info = ( --level:#success
        try 
        (
            local colorClass = dotNetClass "System.Drawing.Color"
            local color = case level of (
                #error:   colorClass.FromArgb 255 10 10
                #warning: colorClass.FromArgb 255 100 100
                #success: colorClass.FromArgb 144 238 144
                #info:    colorClass.FromArgb 90 200 200
            )
            local t = getLocalTime()
            local timeStr = "[" + (formattedPrint t[5] format:"02d") + ":" + (formattedPrint t[6] format:"02d") + ":" + (formattedPrint t[7] format:"02d") + "]"
            local logEntry = timeStr + "•" + msg
        
            local startPos = edt_log.TextLength

            edt_log.AppendText logEntry

            local actualLength = edt_log.TextLength - startPos
            edt_log.Select startPos actualLength
            edt_log.SelectionColor = color

            edt_log.AppendText "\r\n"
            
            edt_log.SelectionStart = edt_log.TextLength
            edt_log.ScrollToCaret()
        ) 
        catch 
        (
            format "日志错误: %\n" (getCurrentException())
        )
    )
    fn fn_clearIni = (
        edt_log.Clear()
        lst_problems.Items.Clear()
        problemBones = #()
        vertexDataMap = #()
        markedVertices = #()
        roundInfoList = #()
        ignoredRegions = #()    -- 清除忽略列表
        fixedRegions = #()      -- 清除修复列表
        edt_selection.Text = "未选择对象..."
        currentObj = undefined
        currentSkinMod = undefined
        pb3.value = 0
        completeRedraw()
        fn_addLog "已清除所有数据。" level:#success 
        fn_addLog  "选择蒙皮对象,点击检查按钮开始" level:#success 
        fn_addLog "可使用左键/右键两种检查方式。" level:#success
    )
    --获取点周（核
    fn fn_getVertexRing obj vertIndex = 
    (
        local neighborVerts = #()
        local edges = meshop.getEdgesUsingVert obj vertIndex as array
        
        for e in edges do
        (
            local verts = meshop.getVertsUsingEdge obj #{e} as array

            if verts[1] == vertIndex then
                append neighborVerts verts[2]
            else
                append neighborVerts verts[1]
        )
        append neighborVerts vertIndex
        
        return neighborVerts
    )
    -- 求和数组
    fn fn_sumArray arr = (
        local total = 0.0
        for v in arr do total += v
        return total
    )
    -- 获取顶点权重
    fn fn_getVertexWeights vid = (
        local boneList = #()
        local weightList = #()
        local numWeights = skinOps.GetVertexWeightCount currentSkinMod vid
        
        for i = 1 to numWeights do 
        (
            local boneID = skinOps.GetVertexWeightBoneID currentSkinMod vid i
            local weight = skinOps.GetVertexWeight currentSkinMod vid i
            if weight > 0.0001 then
            (
                append boneList boneID
                append weightList weight
            )
        )
        return #(boneList, weightList)
    )
    -- 快速获取选中顶点 ID 数组 （兼容低版本  低版本skinOps不能直接根据骨骼ID获取蒙皮点
    fn fn_quickGetSelectedVerts skinMod =
    (
        local sel = #()
        local n = skinOps.GetNumberVertices skinMod
        for i = 1 to n where skinOps.IsVertexSelected skinMod i do
            append sel i
        return sel
    )
    -- 获取受影响的顶点（包括周围顶点）
    fn fn_meshGetAffectedVerts vidList = (
        local result = deepCopy vidList
        for vid in vidList do 
        (
            local ringVerts = fn_getVertexRing currentObj vid
            for rv in ringVerts do 
            (
                if findItem result rv == 0 do
                    append result rv
            )
        )
        return result
    )
   -- 获取顶点周围信息
    fn fn_getVertRoundDisWeightsInfo vid = (
        local ringVerts = fn_getVertexRing currentObj vid
        local idx = findItem ringVerts vid
        if idx > 0 do deleteItem ringVerts idx
        return #(ringVerts)
    )
   -- 替换顶点权重
    fn fn_skinReplaceVertexWeights skinMod vid boneList weightList = (
        local total = fn_sumArray weightList
        if total > 0.0001 then 
        (
            for i = 1 to weightList.count do
                weightList[i] = weightList[i] / total
            skinOps.ReplaceVertexWeights skinMod vid boneList weightList
        )
    )
    
   -- Laplacian平滑算法 混合顶点权重函数(修复用) 将选定顶点的权重与其周围顶点的权重进行混合，从而平滑过渡蒙皮权重
    /* 
    新权重 = (周围顶点平均权重 × 混合强度) + (原权重 × (1 - 混合强度))
    输入: vidList=[10], valList=[0.7]
    ↓
    获取受影响顶点: [8,9,10,11,12]
    ↓
    预缓存所有顶点的权重数据
    ↓
    对于顶点10:
    ├─ 获取周围顶点 [8,9,11,12]
    ├─ 计算周围4个顶点的平均权重
    ├─ 周围权重 × 0.7
    ├─ 原权重 × 0.3
    └─ 合并并应用新权重
    ↓
    输出: 顶点10的权重已平滑 */
    
    fn fn_blendVerticesWeight vidList valList = (
        if vidList.count > 0 do 
        (
            local affectedVerts = fn_meshGetAffectedVerts vidList
            local affectedVertsWeightsList = #()
            for vid in affectedVerts do
            (
                affectedVertsWeightsList[vid] = fn_getVertexWeights vid
            )
            for i = 1 to vidList.count do 
            (
                local vid = vidList[i]
                local val = valList[i]
                if val > 0.001 do 
                (
                    local dval = 1 - val
                    local selfWeights = affectedVertsWeightsList[vid]
                    local selfBoneList = selfWeights[1]
                    local selfWeightList = selfWeights[2]
                    if roundInfoList[vid] == undefined do
                        roundInfoList[vid] = fn_getVertRoundDisWeightsInfo vid
                    local newBones = #()
                    local newWeights = #()
                    local roundInfo = roundInfoList[vid]
                    local roundVid = roundInfo[1]
                    for j = 1 to roundVid.count do (
                        local rid = roundVid[j]
                        local disW = 1.0 / roundVid.count
                        local rWeights = affectedVertsWeightsList[rid]
                        local rvb = rWeights[1]
                        local rvw = rWeights[2]
                        for id = 1 to rvb.count do (
                            local w = rvw[id] * disW
                            local blid = findItem newBones rvb[id]
                            if blid > 0 then
                                newWeights[blid] += w
                            else (
                                append newBones rvb[id]
                                append newWeights w
                            )
                        )
                    )
                    if newWeights.count > 0 do 
                    (
                        local totalWeight = fn_sumArray newWeights
                        for j = 1 to newWeights.count do
                            newWeights[j] = (newWeights[j] / totalWeight) * val
                        for id = 1 to selfBoneList.count do 
                        (
                            local bid = selfBoneList[id]
                            local w = selfWeightList[id] * dval
                            local blid = findItem newBones bid
                            if blid > 0 then
                                newWeights[blid] += w
                            else 
                            (
                                append newBones bid
                                append newWeights w
                            )
                        )
                        fn_skinReplaceVertexWeights currentSkinMod vid newBones newWeights
                    )
                )
            )
        )
    )
    fn fn_CircleLine axisPoint angle radius width = (
        local scaleRadius = (getViewFOV() / 10.0 * radius)
        local halfSize = scaleRadius
        local lineWidth = (getViewFOV() / 10.0 * width)
        
        gw.setRndLimits #(#colorVerts,#flat,#twoSided)
        
        local tran = Inverse(getViewTM())
        tran.row4 = axisPoint
        gw.settransform tran
        
        local topLeft = [-halfSize, halfSize, 0]
        local topRight = [halfSize, halfSize, 0]
        local bottomLeft = [-halfSize, -halfSize, 0]
        local bottomRight = [halfSize, -halfSize, 0]
        
        local offset1 = normalize(topRight - bottomLeft)
        local perpOffset1 = [-offset1.y, offset1.x, 0] * lineWidth * 0.5
        
        local offset2 = normalize(topLeft - bottomRight)
        local perpOffset2 = [-offset2.y, offset2.x, 0] * lineWidth * 0.5
        
        gw.startTriangles()
        
        local line1_p1 = topLeft + perpOffset2
        local line1_p2 = topLeft - perpOffset2
        local line1_p3 = bottomRight + perpOffset2
        local line1_p4 = bottomRight - perpOffset2
        
        gw.triangle #(line1_p1, line1_p2, line1_p3) #(green, green, green)
        gw.triangle #(line1_p2, line1_p4, line1_p3) #(green, green, green)
        
        local line2_p1 = topRight + perpOffset1
        local line2_p2 = topRight - perpOffset1
        local line2_p3 = bottomLeft + perpOffset1
        local line2_p4 = bottomLeft - perpOffset1
        
        gw.triangle #(line2_p1, line2_p2, line2_p3) #(green, green, green)
        gw.triangle #(line2_p2, line2_p4, line2_p3) #(green, green, green)
        
        gw.endTriangles()

        gw.settransform (matrix3 1)
    )
    -- 视口绘制回调函数
    fn fn_drawMarkers = (
        try (
            if markedVertices.count > 0 and currentObj != undefined and isValidNode currentObj then (
                for vertData in markedVertices do (
                    local vertIndex = vertData[1]
                    local obj = vertData[2]
                    if isValidNode obj then 
                    (
                        try 
                        (
                            --local vertPos = polyop.getVert obj vertIndex
                            vertPos = case (classof obj) of
                            (
                                PolyMeshObject: polyop.getVert obj vertIndex
                                Editable_mesh: getVert obj vertIndex
                            )
                            fn_CircleLine vertPos 90 0.3 0.1 
                            -- 参数说明：
                            -- 0.5 = X 的大小
                            -- 0.1 = 线条粗细（数值越大越粗）
                        ) catch()
                    )
                )
                gw.enlargeUpdateRect #whole
                gw.updateScreen()
            )
        ) catch 
        (
            markedVertices = #()
        )
    )
    fn registerViewportCallback = (
        unregisterRedrawViewsCallback fn_drawMarkers
        registerRedrawViewsCallback fn_drawMarkers
    )
    fn unregisterViewportCallback = (
        unregisterRedrawViewsCallback fn_drawMarkers
    )
    -- 获取两个数组的交集
    fn fn_getIntersection arr1 arr2 = (
        if arr1.count == 0 or arr2.count == 0 then return #()
        
        local result = #()
        local ba2 = arr2 as BitArray
        
        for item in arr1 do (
            if ba2[item] do
                append result item
        )
        return result
    )
    fn fn_getDifference arr1 arr2 = (
        if arr1.count == 0 then return #()
        if arr2.count == 0 then return deepCopy arr1
        
        local result = #()
        local ba2 = arr2 as BitArray
        
        for item in arr1 do (
            if not ba2[item] do
                append result item
        )
        return result
    )
    -- 比较两个数组是否相同
    fn fn_arraysEqual arr1 arr2 = (
        if arr1.count != arr2.count then return false
        
        local ba1 = arr1 as BitArray
        local ba2 = arr2 as BitArray
        
        return (ba1 == ba2)
    )
    on SkinIslandChecker open do
    (
        fn_loadMyLogoAsTitlebarIcon()
        fn_initSelectionControl()
        fn_initListControl()
        fn_initLogControl()
        fn_addLog "选择蒙皮对象,点击检查按钮开始" level:#success
        fn_addLog "可使用左键/右键两种检查方式。" level:#success
        registerViewportCallback()
        pb3.value = 0
    )
    on SkinIslandChecker close do
    (
        unregisterViewportCallback()
    )
    on lst_problems DrawSubItem sender args do
    (
        local colorClass = dotNetClass "System.Drawing.Color"
        local itemIndex = args.Item.Index + 1
        
        local backColor = colorClass.FromArgb 43 43 43
        local textColor = colorClass.FromArgb 200 200 200
        
        if args.Item.Text == "✓ 没有发现问题" then
        (
            textColor = colorClass.FromArgb 144 238 144 
        )
        else if itemIndex <= vertexDataMap.count then 
        (
            local data = vertexDataMap[itemIndex]
            -- 骨骼标题行
            if data[2] > 0 and data[3] == undefined then 
            (
                local boneName = data[1]
                local hasIgnored = false
                local hasFixed = false
                local hasUnfixed = false
                -- 检查该骨骼下的所有区域状态
                for i = (itemIndex + 1) to vertexDataMap.count do
                (
                    local childData = vertexDataMap[i]
                    -- 如果遇到下一个骨骼标题，退出
                    if childData[1] != boneName or childData[3] == undefined then
                        exit
                    -- 检查该区域的顶点哈希
                    if childData[3] != undefined then
                    (
                        local regionHash = fn_getVertexHash boneName childData[3]
                        
                        if findItem ignoredRegions regionHash > 0 then
                            hasIgnored = true
                        else if findItem fixedRegions regionHash > 0 then
                            hasFixed = true
                        else
                            hasUnfixed = true
                    )
                )
                -- 颜色优先级：有忽略(紫) > 有未处理(红) > 全部修复(绿)
                if hasIgnored then
                    textColor = colorClass.FromArgb 200 150 255  -- 紫色
                else if hasUnfixed then
                    textColor = colorClass.FromArgb 255 100 100  -- 红色
                else if hasFixed then
                    textColor = colorClass.FromArgb 144 238 144  -- 绿色
            )
            -- 问题区域行
            else if data[3] != undefined then
            (
                local boneName = data[1]
                local verts = data[3]
                local regionHash = fn_getVertexHash boneName verts
                -- 优先级：已忽略(紫) > 已修复(绿) > 未处理(灰白)
                if findItem ignoredRegions regionHash > 0 then 
                (
                    textColor = colorClass.FromArgb 200 150 255  -- 紫色
                )
                else if findItem fixedRegions regionHash > 0 then
                (
                    textColor = colorClass.FromArgb 144 238 144  -- 绿色
                )
                else
                (
                    textColor = colorClass.FromArgb 200 200 200  -- 灰白色（未处理）
                )
            )
        )
        if args.Item.Selected then 
        (
            backColor = colorClass.FromArgb 100 100 100
        )
        local backBrush = dotNetObject "System.Drawing.SolidBrush" backColor
        args.Graphics.FillRectangle backBrush args.Bounds
        backBrush.Dispose()
        
        local textBrush = dotNetObject "System.Drawing.SolidBrush" textColor
        local sf = dotNetObject "System.Drawing.StringFormat"
        sf.LineAlignment = (dotNetClass "System.Drawing.StringAlignment").Center
        
        local rect = dotNetObject "System.Drawing.RectangleF" (args.Bounds.X + 3) args.Bounds.Y (args.Bounds.Width - 3) args.Bounds.Height
        args.Graphics.DrawString args.SubItem.Text args.Item.Font textBrush rect sf
        
        textBrush.Dispose()
    )
    on lst_problems MouseUp sender args do
    (
        try 
        (
            if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Right then 
            (
                local hitTest = lst_problems.HitTest (dotNetObject "System.Drawing.Point" args.X args.Y)
                if hitTest.Item != undefined then 
                (
                    local index = hitTest.Item.Index
                    -- 检查是否点击的是骨骼标题行
                    if (index + 1) <= vertexDataMap.count then
                    (
                        local dataEntry = vertexDataMap[index + 1]
                        -- 如果是骨骼标题行，不显示菜单
                        if dataEntry[3] == undefined or dataEntry[2] == 0 then
                        (
                            fn_addLog "请在具体的问题区域上右键操作" level:#warning
                            return()
                        )
                    )
                    if not hitTest.Item.Selected then
                    (
                        hitTest.Item.Selected = true
                    )
                    if index < vertexDataMap.count then 
                    (
                        local dataEntry = vertexDataMap[index + 1]
                        if dataEntry[3] != undefined and dataEntry[2] > 0 then 
                        (
                            contextMenu.Show lst_problems (dotNetObject "System.Drawing.Point" args.X args.Y)
                        )
                    )
                )
            )
        ) 
        catch 
        (
            fn_addLog ("右键菜单错误: " + (getCurrentException())) level:#error
        )
    )
    on lst_problems ItemSelectionChanged sender args do
    (
        try
        (
            -- 检查是否选中了骨骼标题行
            if args.Item != undefined and args.IsSelected then
            (
                local index = args.Item.Index + 1
                if index <= vertexDataMap.count then
                (
                    local dataEntry = vertexDataMap[index]
                    -- 如果是骨骼标题行（没有顶点数据），取消选中
                    if dataEntry[3] == undefined or dataEntry[2] == 0 then
                    (
                        args.Item.Selected = false
                    )
                )
            )
        )
        catch()
    )
    on lst_problems DoubleClick sender args do
    (
        try
        (
            registerViewportCallback()
            if currentObj == undefined or currentSkinMod == undefined then 
            (
                fn_addLog "错误:请先执行检查" level:#error
                return()
            )
            if lst_problems.SelectedItems.Count == 0 then return()
            local sel = lst_problems.SelectedItems.Item[0].Index + 1
            if sel <= 0 or sel > vertexDataMap.count then return()
            local dataEntry = vertexDataMap[sel]
            local boneName = dataEntry[1]
            local boneID = dataEntry[2]
            local verts = dataEntry[3]
            if verts == undefined or boneID == 0 then 
            (
                fn_addLog "选择了骨骼标题或空行,无法跳转" level:#error
                return()
            )
            --跳转蒙皮点
            select currentObj
            max modify mode
            modPanel.setCurrentObject currentSkinMod
            subobjectLevel = 1
            skinOps.SelectBone currentSkinMod boneID 
            local vertBitArray = verts as BitArray
            skinOps.SelectVertices currentSkinMod vertBitArray
            markedVertices = #()
            for v in verts do 
            (
                append markedVertices #(v, currentObj)
            )
            completeRedraw()
            fn_addLog ("已跳转到【" + boneName + "】并选择了 " + verts.count as string + " 个顶点") level:#success 
        ) 
        catch 
        (
            errMsg = "跳转失败: " + (getCurrentException()) 
            fn_addLog errMsg level:#error
        )
    )
    on contextMenu ItemClicked sender args do
    (
        local menuIndex = contextMenu.Items.IndexOf args.ClickedItem
        --选择
        if menuIndex == 0 then
        (
            try
            (
                if currentObj == undefined or currentSkinMod == undefined then 
                (
                    fn_addLog "错误: 请先执行检查" level:#error
                    return()
                )
                if lst_problems.SelectedIndices.Count == 0 then 
                (
                    fn_addLog "错误: 未选择有效项" level:#warning
                    return()
                )
                -- 收集所有选中项对应的顶点
                local allSelectedVerts = #()
                local selectedRegionCount = 0
                
                for i = 0 to (lst_problems.SelectedIndices.Count - 1) do
                (
                    local sel = lst_problems.SelectedIndices.Item[i] + 1
                    
                    if sel > 0 and sel <= vertexDataMap.count then
                    (
                        local dataEntry = vertexDataMap[sel]
                        local verts = dataEntry[3]
                        
                        -- 只处理有顶点数据的条目（跳过骨骼标题行）
                        if verts != undefined and verts.count > 0 then
                        (
                            selectedRegionCount += 1
                            for v in verts do
                            (
                                if findItem allSelectedVerts v == 0 do
                                    append allSelectedVerts v
                            )
                        )
                    )
                )
                if allSelectedVerts.count == 0 then
                (
                    fn_addLog "所选项中没有顶点数据" level:#warning
                    return()
                )
                -- 选择对象并进入修改模式
                select currentObj
                max modify mode
                modPanel.setCurrentObject currentSkinMod
                subobjectLevel = 1
                -- 选择所有收集到的顶点
                local vertBitArray = allSelectedVerts as BitArray
                skinOps.SelectVertices currentSkinMod vertBitArray
                -- 标记所有顶点（用于视口显示）
                markedVertices = #()
                for v in allSelectedVerts do
                (
                    append markedVertices #(v, currentObj)
                )
                -- 注册视口回调以显示标记
                registerViewportCallback()
                completeRedraw()
                
                fn_addLog ("已选择 " + selectedRegionCount as string + " 个区域，共 " + allSelectedVerts.count as string + " 个顶点") level:#success
                --fn_addLog "绿色标记已在视口中显示" level:#info
            )
            catch
            (
                local errMsg = "选择顶点失败: " + (getCurrentException())
                fn_addLog errMsg level:#error
            )
        )
        --修复
        if menuIndex == 1 then  
        (
            if lst_problems.SelectedIndices.Count == 0 then 
            (
                fn_addLog "错误: 未选择有效项" level:#error
                return()
            )
            -- 收集所有选中的有效区域
            local validRegions = #()
            for i = 0 to (lst_problems.SelectedIndices.Count - 1) do
            (
                local sel = lst_problems.SelectedIndices.Item[i] + 1
                
                if sel > 0 and sel <= vertexDataMap.count then
                (
                    local dataEntry = vertexDataMap[sel]
                    local boneName = dataEntry[1]
                    local boneID = dataEntry[2]
                    local verts = dataEntry[3]
                    
                    -- 只处理有顶点数据的条目（跳过骨骼标题行）
                    if verts != undefined and boneID > 0 then
                    (
                        append validRegions #(boneName, boneID, verts)
                    )
                )
            )
            if validRegions.count == 0 then
            (
                fn_addLog "错误: 请选择具体的区域进行修复" level:#error
                return()
            )
            -- 批量修复
            fn_addLog ("开始批量修复 " + validRegions.count as string + " 个问题区域...") level:#info
            
            local tempMesh = snapshotasmesh currentObj
            local originalObj = currentObj
            currentObj = tempMesh
            
            local totalVertCount = 0
            
            for regionData in validRegions do
            (
                local boneName = regionData[1]
                local boneID = regionData[2]
                local verts = regionData[3]
                
                fn_addLog ("  修复【" + boneName + "】区域（" + verts.count as string + " 个顶点）...") level:#info
                
                local vidList = verts
                local valList = #()
                for i = 1 to vidList.count do
                    append valList 1.0
                    
                for n = 1 to 50 do 
                (
                    -- 动态调整强度：前期激进，后期温和
                    local blendStrength = case of
                    (
                        (n <= 10):  1.0    -- 前10次全力平滑
                        (n <= 30):  0.7    -- 中期适度平滑
                        (n <= 50):  0.3    -- 后期微调
                        default:    0.1
                    )
                    -- 更新所有顶点的混合强度
                    for i = 1 to valList.count do
                        valList[i] = blendStrength
                    
                    fn_blendVerticesWeight vidList valList
                )
                -- 生成该区域的哈希并添加到修复列表
                local regionHash = fn_getVertexHash boneName verts
                if findItem fixedRegions regionHash == 0 do
                    append fixedRegions regionHash
                -- 从忽略列表中移除（如果存在）
                local ignoreIdx = findItem ignoredRegions regionHash
                if ignoreIdx > 0 do
                    deleteItem ignoredRegions ignoreIdx
                totalVertCount += verts.count
            )
            currentObj = originalObj
            delete tempMesh
            lst_problems.Refresh()
            fn_addLog ("批量修复完成！共修复 " + validRegions.count as string + " 个区域，" + totalVertCount as string + " 个顶点") level:#success
        )
        --忽略
        if menuIndex == 2 then
        (
            if lst_problems.SelectedIndices.Count == 0 then 
            (
                fn_addLog "错误: 未选择有效项" level:#error
                return()
            )
            -- 收集所有选中的有效区域
            local validRegions = #()
            
            for i = 0 to (lst_problems.SelectedIndices.Count - 1) do
            (
                local sel = lst_problems.SelectedIndices.Item[i] + 1
                
                if sel > 0 and sel <= vertexDataMap.count then
                (
                    local dataEntry = vertexDataMap[sel]
                    local boneName = dataEntry[1]
                    local boneID = dataEntry[2]
                    local verts = dataEntry[3]
                    
                    -- 只处理有顶点数据的条目（跳过骨骼标题行）
                    if verts != undefined and boneID > 0 then
                    (
                        append validRegions #(boneName, boneID, verts)
                    )
                )
            )
            if validRegions.count == 0 then
            (
                fn_addLog "错误: 请选择具体的区域进行忽略" level:#error
                return()
            )
            -- 批量忽略
            local ignoredCount = 0
            local alreadyIgnoredCount = 0
            local totalVertCount = 0
            
            for regionData in validRegions do
            (
                local boneName = regionData[1]
                local verts = regionData[3]
                local regionHash = fn_getVertexHash boneName verts
                -- 添加到忽略列表
                if findItem ignoredRegions regionHash == 0 then
                (
                    append ignoredRegions regionHash
                    ignoredCount += 1
                    totalVertCount += verts.count
                    fn_addLog ("  忽略【" + boneName + "】区域（" + verts.count as string + " 个顶点）") level:#info
                )
                else
                (
                    alreadyIgnoredCount += 1
                )
            )
            lst_problems.Refresh()
            if ignoredCount > 0 then
                fn_addLog ("批量忽略完成！共忽略 " + ignoredCount as string + " 个区域，" + totalVertCount as string + " 个顶点") level:#success
            if alreadyIgnoredCount > 0 then
                fn_addLog ("其中 " + alreadyIgnoredCount as string + " 个区域已在忽略列表中") level:#warning
        )
        --取消忽略
        if menuIndex == 3 then
        (
            if lst_problems.SelectedIndices.Count == 0 then 
            (
                fn_addLog "错误: 未选择有效项" level:#error
                return()
            )
            -- 收集所有选中的有效区域
            local validRegions = #()
            for i = 0 to (lst_problems.SelectedIndices.Count - 1) do
            (
                local sel = lst_problems.SelectedIndices.Item[i] + 1
                
                if sel > 0 and sel <= vertexDataMap.count then
                (
                    local dataEntry = vertexDataMap[sel]
                    local boneName = dataEntry[1]
                    local boneID = dataEntry[2]
                    local verts = dataEntry[3]
                    
                    -- 只处理有顶点数据的条目（跳过骨骼标题行）
                    if verts != undefined and boneID > 0 then
                    (
                        append validRegions #(boneName, boneID, verts)
                    )
                )
            )
            if validRegions.count == 0 then
            (
                fn_addLog "错误: 请选择具体的区域进行取消忽略" level:#error
                return()
            )
            -- 批量取消忽略
            local unignoredCount = 0
            local notIgnoredCount = 0
            local totalVertCount = 0
            
            for regionData in validRegions do
            (
                local boneName = regionData[1]
                local verts = regionData[3]
                local regionHash = fn_getVertexHash boneName verts
                
                -- 从忽略列表中移除
                local ignoreIdx = findItem ignoredRegions regionHash
                if ignoreIdx > 0 then
                (
                    deleteItem ignoredRegions ignoreIdx
                    unignoredCount += 1
                    totalVertCount += verts.count
                    fn_addLog ("  取消忽略【" + boneName + "】区域（" + verts.count as string + " 个顶点）") level:#info
                )
                else
                (
                    notIgnoredCount += 1
                )
            )
            lst_problems.Refresh()
            
            if unignoredCount > 0 then
                fn_addLog ("批量取消忽略完成！共取消 " + unignoredCount as string + " 个区域，" + totalVertCount as string + " 个顶点") level:#success
            
            if notIgnoredCount > 0 then
                fn_addLog ("其中 " + notIgnoredCount as string + " 个区域本来就不在忽略列表中") level:#warning
        )
        --全选
        if menuIndex == 4 then
        (
            try
            (
                if vertexDataMap.count == 0 then
                (
                    fn_addLog "列表为空，没有项目可选择" level:#warning
                    return()
                )
                -- 选中所有有效的问题区域项（跳过骨骼标题行）
                local selectedCount = 0
                
                -- 清空当前选择
                lst_problems.SelectedItems.Clear()
                -- 遍历所有列表项
                for i = 0 to (lst_problems.Items.Count - 1) do
                (
                    if (i + 1) <= vertexDataMap.count then
                    (
                        local dataEntry = vertexDataMap[i + 1]
                        -- 只选择有顶点数据的条目（跳过骨骼标题行）
                        if dataEntry[3] != undefined and dataEntry[2] > 0 then
                        (
                            lst_problems.Items.Item[i].Selected = true
                            selectedCount += 1
                        )
                    )
                )
                fn_addLog ("已在列表中选中所有 " + selectedCount as string + " 个问题区域") level:#success
                fn_addLog "可以右键进行批量操作（修复/忽略/取消忽略）" level:#info
            )
            catch
            (
                local errMsg = "全选列表项失败: " + (getCurrentException())
                fn_addLog errMsg level:#error
            )
        )
    )
    fn fn_orderCheck useHighVersion:true checkMode:#probability = 
    (
        try 
        (
            if selection.count == 0 then 
            (
                fn_addLog "错误: 未选择对象" level:#error
                return()
            )
            -- ========== 初始化 ==========
            local savedIgnoredRegions = deepCopy ignoredRegions
            
            edt_log.Clear()
            lst_problems.Items.Clear()
            problemBones = #()
            vertexDataMap = #()
            markedVertices = #()
            roundInfoList = #()
            fixedRegions = #()
            pb3.value = 0
            
            ignoredRegions = savedIgnoredRegions
            
            local startTime = timestamp()
            
            -- 关闭权重工具
            try 
            (
                if selection[1].modifiers[#Skin] != undefined then
                (
                    if useHighVersion then
                        skinOps.closeWeightTool selection[1].modifiers[#Skin] node:selection[1]
                    else
                        skinOps.closeWeightTool selection[1].modifiers[#Skin]
                )
            )
            catch()
            
            -- 设置当前对象
            currentObj = selection[1]
            edt_selection.Text = currentObj.name
            windows.processPostedMessages()
            
            -- 日志提示
            if checkMode == #probability then
                fn_addLog "使用概率检查,精确度默认为 2 " level:#success
            else
                fn_addLog "使用精确检查" level:#success
                
            fn_addLog ("开始检查对象: " + currentObj.name) level:#success
            
            -- 清理标记
            markedVertices = #()
            roundInfoList = #()
            completeRedraw()
            pb3.value = 0
            pb3.color = yellow
            
            -- 根据模式设置
            if not useHighVersion then
                select currentObj
            else
                max create mode
            
            -- ========== 获取 Skin 修改器 ==========
            currentSkinMod = undefined
            for m in currentObj.modifiers do 
            (
                if classOf m == Skin then 
                (
                    currentSkinMod = m
                    exit
                )
            )
            
            if currentSkinMod == undefined then 
            (
                fn_addLog "错误: 对象没有Skin修改器" level:#error
                return()
            )
            
            -- ========== 创建快照并预处理 ==========
            pb3.value = 0
            fn_addLog "创建网格快照..." level:#success
            
            local snapshotMesh = undefined
            try 
            (
                snapshotMesh = snapshotasmesh currentObj
                if snapshotMesh == undefined do throw "快照创建失败"
            ) 
            catch 
            (
                fn_addLog ("快照错误: " + (getCurrentException())) level:#error
                return()
            )
            
            pb3.value = 5
            windows.processPostedMessages()
            
            local numVerts = meshop.getNumVerts snapshotMesh
            local numFaces = meshop.getNumFaces snapshotMesh
            
            -- 构建顶点邻接关系
            local vertexRingBitArrays = #()
            for i = 1 to numVerts do 
                vertexRingBitArrays[i] = #{}
            
            local lastUpdateTime = 0
            for f = 1 to numFaces do
            (
                if mod f 500 == 0 then 
                (
                    local currentTime = timestamp()
                    if currentTime - lastUpdateTime > 100 then
                    (
                        pb3.value = 5 + (20.0 * f / numFaces) as integer
                        windows.processPostedMessages()
                        lastUpdateTime = currentTime
                    )
                )
                
                local face = meshop.getFace snapshotMesh f
                local v1 = face.x as integer
                local v2 = face.y as integer
                local v3 = face.z as integer
                
                vertexRingBitArrays[v1][v2] = true
                vertexRingBitArrays[v1][v3] = true
                vertexRingBitArrays[v2][v1] = true
                vertexRingBitArrays[v2][v3] = true
                vertexRingBitArrays[v3][v1] = true
                vertexRingBitArrays[v3][v2] = true
            )
            
            pb3.value = 25
            windows.processPostedMessages()
            
            -- 转换为数组缓存
            local vertexRingCache = #()
            for v = 1 to numVerts do
            (
                vertexRingCache[v] = vertexRingBitArrays[v] as array
                append vertexRingCache[v] v
            )
            vertexRingBitArrays = undefined
            
            fn_addLog "预处理完成，开始检查骨骼..." level:#success
            
            -- ========== 重置数据结构 ==========
            problemBones = #()
            lst_problems.Items.Clear()
            vertexDataMap = #()
            
            -- 低版本需要设置修改面板
            if not useHighVersion then
            (
                max modify mode
                modPanel.setCurrentObject currentSkinMod
                subobjectLevel = 1
            )
            
            -- 获取骨骼数量
            numSkinBone = if useHighVersion then 
                skinOps.GetNumberBones currentSkinMod node:currentObj 
            else 
                skinOps.GetNumberBones currentSkinMod
            
            -- ========== 遍历每个骨骼 ==========
            lastUpdateTime = 0
            local allBoneProblems = #()  -- 收集所有骨骼的问题数据
            local hasIgnoredRegions = false  -- 标记是否存在被忽略的区域
            
            for num = 1 to numSkinBone do 
            (
                -- 更新进度
                local currentTime = timestamp()
                if currentTime - lastUpdateTime > 100 then
                (
                    pb3.value = 25 + (70.0 * num / numSkinBone) as integer
                    lastUpdateTime = currentTime
                )
                
                -- 获取骨骼名称
                local boneName = ""
                try
                (
                    boneName = if useHighVersion then
                        skinOps.GetBoneName currentSkinMod num 1 node:currentObj
                    else
                        skinOps.GetBoneName currentSkinMod num 1
                )
                catch
                (
                    boneName = "Bone_" + num as string
                )
                
                -- 获取该骨骼影响的顶点
                if useHighVersion then
                (
                    skinOps.SelectBone currentSkinMod num node:currentObj
                    skinOps.selectVerticesByBone currentSkinMod node:currentObj
                    local allSkinVerts = skinOps.GetSelectedVertices currentSkinMod node:currentObj
                )
                else
                (
                    skinOps.SelectBone currentSkinMod num
                    skinOps.selectVerticesByBone currentSkinMod
                    local allSkinVerts = fn_quickGetSelectedVerts currentSkinMod
                    subobjectLevel = 0
                )
                
                local errorAry = #()
                
                -- ========== 区域连通性检查 ==========
                if allSkinVerts.count > 0 then 
                (
                    local allStableSets = #()
                    local remainingVerts = allSkinVerts as bitArray
                    local allSkinVertsBits = allSkinVerts as bitArray
                    
                    -- 使用区域生长算法分离独立区域
                    while remainingVerts.count > 0 do 
                    (
                        local seedArray = remainingVerts as array
                        if seedArray.count == 0 then exit
                        
                        local seedVert = seedArray[1]
                        local region = #{seedVert}
                        local toExpand = #{seedVert}
                        local safeCounter = 0
                        local maxIterations = 100000
                        
                        -- 区域扩展
                        while toExpand.count > 0 do
                        (
                            safeCounter += 1
                            if safeCounter > maxIterations then
                            (
                                fn_addLog ("警告: 骨骼【" + boneName + "】区域扩展超时") level:#warning
                                exit
                            )
                            
                            local newVerts = #{}
                            local expandArray = toExpand as array
                            
                            for v in expandArray do
                            (
                                if v > 0 and v <= vertexRingCache.count then
                                (
                                    local neighborsArray = vertexRingCache[v]
                                    if neighborsArray != undefined then
                                    (
                                        local neighborsBits = neighborsArray as bitArray
                                        local validNeighbors = neighborsBits * allSkinVertsBits - region
                                        newVerts += validNeighbors
                                    )
                                )
                            )
                            
                            region += newVerts
                            toExpand = newVerts
                        )
                        
                        local regionArray = region as array
                        if regionArray.count > 0 then
                            append allStableSets regionArray
                        
                        remainingVerts -= region
                    )
                    
                    -- ========== 飞点判断逻辑（两种模式）==========
                    if allStableSets.count > 1 then 
                    (
                        if not useHighVersion then subobjectLevel = 1
                        
                        -- ========== 找出顶点数最多的区域（主区域）==========
                        local maxCount = 0
                        local mainRegionIndex = 1
                        local maxCountIslands = #()
                        
                        -- 第一步：找出最大顶点数
                        for i = 1 to allStableSets.count do
                        (
                            if allStableSets[i].count > maxCount then
                            (
                                maxCount = allStableSets[i].count
                            )
                        )
                        
                        -- 第二步：收集所有具有最大顶点数的岛
                        for i = 1 to allStableSets.count do
                        (
                            if allStableSets[i].count == maxCount then
                            (
                                append maxCountIslands i
                            )
                        )
                        
                        -- 判断是否有多个岛具有相同的最大顶点数
                        local hasMultipleMaxIslands = (maxCountIslands.count > 1)
                        
                        if hasMultipleMaxIslands then
                        (
                            fn_addLog ("骨骼【" + boneName + "】有 " + allStableSets.count as string + " 个区域，有 " + maxCountIslands.count as string + " 个区域具有相同的最大顶点数: " + maxCount as string + "（无法确定问题）") level:#warning
                        )
                        else
                        (
                            mainRegionIndex = maxCountIslands[1]
                            --fn_addLog ("骨骼【" + boneName + "】有 " + allStableSets.count as string + " 个岛，主岛: " + maxCount as string + " 个顶点") level:#info
                        )
                        
                        case checkMode of
                        (
                            -- ========== 概率检查模式：对非主区域做两次收缩 ==========
                            #probability: 
                            (
                                for i = 1 to allStableSets.count do 
                                (
                                    local shouldCheck = false
                                    
                                    -- 如果有多个最大岛，所有岛都需要检查
                                    if hasMultipleMaxIslands then
                                    (
                                        shouldCheck = true
                                    )
                                    -- 如果只有一个最大岛，跳过该主岛
                                    else if i != mainRegionIndex then
                                    (
                                        shouldCheck = true
                                    )
                                    
                                    if shouldCheck then
                                    (
                                        local regionVerts = allStableSets[i]
                                        if regionVerts.count > 0 then
                                        (
                                            local regionBits = regionVerts as BitArray
                                            local shrunkVerts = #{}
                                            
                                            -- 第一次收缩
                                            if useHighVersion then
                                            (
                                                skinOps.SelectVertices currentSkinMod regionBits node:currentObj
                                                shrunkVerts = skinUtils.ShrinkSelection currentObj
                                                shrunkVerts = skinOps.GetSelectedVertices currentSkinMod node:currentObj
                                            )
                                            else
                                            (
                                                skinOps.SelectVertices currentSkinMod regionBits
                                                shrunkVerts = skinUtils.ShrinkSelection currentObj
                                                shrunkVerts = fn_quickGetSelectedVerts currentSkinMod
                                            )
                                            
                                            -- 第二次收缩（如果第一次收缩后还有顶点）
                                            if shrunkVerts.count > 0 then
                                            (
                                                if useHighVersion then
                                                (
                                                    shrunkVerts = skinUtils.ShrinkSelection currentObj
                                                    shrunkVerts = skinOps.GetSelectedVertices currentSkinMod node:currentObj
                                                )
                                                else
                                                (
                                                    shrunkVerts = skinUtils.ShrinkSelection currentObj
                                                    shrunkVerts = fn_quickGetSelectedVerts currentSkinMod
                                                )
                                            )
                                            
                                            -- 两次收缩后为空则认为是飞点
                                            if shrunkVerts.count == 0 then 
                                            (
                                                append errorAry regionVerts
                                                local islandType = if hasMultipleMaxIslands then "（相同最大数量）" else "（次要岛）"
                                                --fn_addLog ("  - 岛 " + i as string + islandType + ": " + regionVerts.count as string + " 个顶点（两次收缩后为空，标记为问题）") level:#warning
                                            )
                                            else
                                            (
                                                local islandType = if hasMultipleMaxIslands then "（相同最大数量）" else "（次要岛）"
                                                --fn_addLog ("  - 岛 " + i as string + islandType + ": " + regionVerts.count as string + " 个顶点（两次收缩后还有 " + shrunkVerts.count as string + " 个顶点，判定为正常）") level:#info
                                            )
                                        )
                                    )
                                )
                            )
                            
                            -- ========== 精确检查模式：直接判断非主区域为飞点 ==========
                            #accurate: 
                            (
                                for i = 1 to allStableSets.count do
                                (
                                    local shouldMarkAsProblem = false
                                    
                                    -- 如果有多个最大岛，所有岛都标记为问题
                                    if hasMultipleMaxIslands then
                                    (
                                        shouldMarkAsProblem = true
                                    )
                                    -- 如果只有一个最大岛，其他岛标记为问题
                                    else if i != mainRegionIndex then
                                    (
                                        shouldMarkAsProblem = true
                                    )
                                    
                                    if shouldMarkAsProblem then
                                    (
                                        local regionVerts = allStableSets[i]
                                        if regionVerts.count > 0 then
                                        (
                                            append errorAry regionVerts
                                            local islandType = if hasMultipleMaxIslands then "（相同最大数量）" else "（次要区域）"
                                            fn_addLog ("  - 区域 " + i as string + islandType + ": " + regionVerts.count as string + " 个顶点（标记为问题）") level:#warning
                                        )
                                    )
                                )
                            )
                        )
                        
                        if not useHighVersion then subobjectLevel = 0
                    )
                )
                
                -- ========== 收集问题区域（使用数组结构）==========
                if errorAry.count > 0 then 
                (
                    local boneProblemsData = #(boneName, num, #())  -- [1]=骨骼名, [2]=骨骼ID, [3]=区域数组
                    
                    for regionIndex = 1 to errorAry.count do 
                    (
                        local regionVerts = errorAry[regionIndex]
                        local regionHash = fn_getVertexHash boneName regionVerts
                        local isIgnored = findItem ignoredRegions regionHash > 0
                        
                        -- 检查是否有被忽略的区域
                        if isIgnored do hasIgnoredRegions = true
                        
                        append boneProblemsData[3] #(regionVerts, regionHash, isIgnored)
                    )
                    
                    append allBoneProblems boneProblemsData
                )
            )
            
            -- ========== 显示问题区域（根据是否有忽略区域决定处理方式）==========
            pb3.value = 95
            
            -- 如果没有被忽略的区域，直接按原来的方式添加（速度快）
            if not hasIgnoredRegions then
            (
                for boneData in allBoneProblems do
                (
                    local boneName = boneData[1]
                    local boneID = boneData[2]
                    local regions = boneData[3]
                    
                    local boneItem = lst_problems.Items.Add ("【" + boneName + "】")
                    append vertexDataMap #(boneName, boneID, undefined)
                    
                    for regionIndex = 1 to regions.count do 
                    (
                        local regionVerts = regions[regionIndex][1]
                        
                        local item = lst_problems.Items.Add ("        区域 " + regionIndex as string + ": " + regionVerts.count as string + " 个问题顶点")
                        append vertexDataMap #(boneName, boneID, regionVerts)
                    )
                    
                    lst_problems.EnsureVisible (lst_problems.Items.Count - 1)
                    fn_addLog (boneName + " 发现 " + regions.count as string + " 个问题区域") level:#warning
                )
            )
            else
            (
                -- 如果有被忽略的区域，进行排序（有被忽略区域的骨骼放最后）
                fn_addLog "检测到之前被忽略的区域，将这些骨骼排列到列表底部..." level:#info
                
                local normalBones = #()      -- 这个骨骼下没有任何被忽略的区域
                local ignoredBones = #()     -- 这个骨骼下有至少一个被忽略的区域
                
                -- 分类骨骼：根据是否包含被忽略的区域
                for boneData in allBoneProblems do
                (
                    local regions = boneData[3]
                    local hasIgnoredRegion = false
                    
                    -- 检查这个骨骼下是否有被忽略的区域
                    for regionData in regions do
                    (
                        local isIgnored = regionData[3]  -- 这是之前被忽略过的
                        if isIgnored then
                        (
                            hasIgnoredRegion = true
                            exit
                        )
                    )
                    
                    -- 根据是否包含被忽略区域来分类
                    if hasIgnoredRegion then
                        append ignoredBones boneData
                    else
                        append normalBones boneData
                )
                
                -- 先添加没有被忽略区域的骨骼（显示在上面）
                for boneData in normalBones do
                (
                    local boneName = boneData[1]
                    local boneID = boneData[2]
                    local regions = boneData[3]
                    
                    local boneItem = lst_problems.Items.Add ("【" + boneName + "】")
                    append vertexDataMap #(boneName, boneID, undefined)
                    
                    for regionIndex = 1 to regions.count do 
                    (
                        local regionVerts = regions[regionIndex][1]
                        
                        local item = lst_problems.Items.Add ("        区域 " + regionIndex as string + ": " + regionVerts.count as string + " 个问题顶点")
                        append vertexDataMap #(boneName, boneID, regionVerts)
                    )
                    
                    lst_problems.EnsureVisible (lst_problems.Items.Count - 1)
                    fn_addLog (boneName + " 发现 " + regions.count as string + " 个问题区域（新问题）") level:#warning
                )
                
                -- 再添加有被忽略区域的骨骼（显示在下面）
                for boneData in ignoredBones do
                (
                    local boneName = boneData[1]
                    local boneID = boneData[2]
                    local regions = boneData[3]
                    
                    local boneItem = lst_problems.Items.Add ("【" + boneName + "】")
                    append vertexDataMap #(boneName, boneID, undefined)
                    
                    local ignoredCount = 0
                    local normalCount = 0
                    
                    for regionIndex = 1 to regions.count do 
                    (
                        local regionVerts = regions[regionIndex][1]
                        local regionHash = regions[regionIndex][2]
                        local isIgnored = regions[regionIndex][3]
                        
                        local item = lst_problems.Items.Add ("        区域 " + regionIndex as string + ": " + regionVerts.count as string + " 个问题顶点")
                        append vertexDataMap #(boneName, boneID, regionVerts)
                        
                        if isIgnored then
                        (
                            ignoredCount += 1
                            fn_addLog (boneName + " 区域 " + regionIndex as string + " 已被忽略（之前标记）") level:#info
                        )
                        else
                        (
                            normalCount += 1
                        )
                    )
                    
                    fn_addLog (boneName + " 发现 " + regions.count as string + " 个问题区域（" + normalCount as string + " 个新问题，" + ignoredCount as string + " 个已忽略）") level:#warning
                )
                
                if ignoredBones.count > 0 then
                    fn_addLog ("包含被忽略区域的 " + ignoredBones.count as string + " 个骨骼已排列在列表底部") level:#info
            )
            
            -- ========== 清理和结果输出 ==========
            delete snapshotMesh
            vertexRingCache = undefined
            gc light:true
            pb3.value = 100
            
            local endTime = timestamp()
            local elapsed = (endTime - startTime) / 1000.0
            local elapsedStr = formattedPrint elapsed format:".2f"
            
            fn_addLog ("处理了 " + numVerts as string + " 个顶点...")
            fn_addLog ("处理了 " + numFaces as string + " 个面...")
            fn_addLog ("骨骼数量: " + numSkinBone as string) 
            
            if vertexDataMap.count > 0 then 
            (
                fn_addLog ("检查完成,发现问题 (用时: " + elapsedStr + " 秒)") level:#success
                pb3.color = red 
            ) 
            else 
            (
                local item = lst_problems.Items.Add "✓ 没有发现问题"
                item.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 144 238 144
                fn_addLog ("检查完成,没有发现问题 (用时: " + elapsedStr + " 秒)") level:#success
                pb3.color = green 
            )
        )
        catch 
        (
            errMsg = "检查出错: " + (getCurrentException()) 
            fn_addLog errMsg level:#error
            pb3.value = 0
            pb3.color = red
        )
    )
    on btn_check pressed do
    (
        if fn_getMaxVersion() >= 2020 then
            fn_orderCheck useHighVersion:true checkMode:#probability
        else
            fn_orderCheck useHighVersion:false checkMode:#probability
    )
    on btn_check rightclick do
    (
        if fn_getMaxVersion() >= 2020 then
            fn_orderCheck useHighVersion:true checkMode:#accurate
        else
            fn_orderCheck useHighVersion:false checkMode:#accurate
    )
    on btn_clear pressed do
    (
        fn_clearIni()
    )
    on btn_clear rightclick do 
    (
        unregisterViewportCallback()
        fn_addLog ("清理选择标记...") level:#success
    )
    on btn_help pressed do fn_helpText()
)
createDialog SkinIslandChecker backgroundColor:(color 68 68 68) fgcolor:[100,200,100] style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
)