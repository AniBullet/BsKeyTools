-- BsLayerManager v1.0
-- Layer 预设管理器 - 支持动态字段和预设保存
-- 作者: Bullet.S
-- 功能: 创建、编辑、删除、加载layer预设，支持{AAA},{BBB}等动态字段

try(destroyDialog rolBsLayerManager)catch()

global rolBsLayerManager
global offsetBsLayerManager = [0,0]
global dragStateBsLayerManager = off
global BsLayerManagerConfig = execute ("@\"" + (getDir #maxData) + "\\BsLayerManagerConfig.ini\"")

-- 预设数据结构
struct LayerPreset (
    name,
    layerStructure,
    fieldNames,
    description
)

-- 全局变量
global arrLayerPresets = #()
global currentPreset = undefined
global currentPresetIndex = 0
global arrFieldValues = #()
global arrFieldOptions = #("Name", "Type", "Part", "LOD", "Mat") -- 可插入的字段选项

(
    rollout rolBsLayerManager "BsLayerManager 层预设管理器 v1.0" width:720 height:490
    (
        -- 窗口标题和关闭按钮
        button btnAbout "?" pos:[rolBsLayerManager.width - 40,0] height:16 width:20 tooltip:"关于"
        button btnClose "×" pos:[rolBsLayerManager.width - 20,0] height:16 width:20 tooltip:"关闭"
        label lblTitle rolBsLayerManager.title pos:[5,3] color:[70,130,180]
        
        -- 顶部工具栏 - 使用内置图标
        groupBox gpbToolbar "" pos:[5,20] width:710 height:35
        button btnNewPreset "➕新建" pos:[15,30] width:50 height:20 tooltip:"创建新预设"
        button btnCopyPreset "📋复制" pos:[70,30] width:50 height:20 tooltip:"复制预设"
        button btnDeletePreset "🗑删除" pos:[125,30] width:50 height:20 tooltip:"删除预设"
        button btnSaveConfig "💾保存" pos:[180,30] width:50 height:20 tooltip:"保存配置"
        button btnExportPresets "📤导出" pos:[235,30] width:50 height:20 tooltip:"导出所有预设到文件"
        button btnLoadConfig "📥导入" pos:[290,30] width:50 height:20 tooltip:"从预设文件导入"
        button btnCreateLayers "🚀 生成 Layers" pos:[600,30] width:110 height:20 tooltip:"使用当前字段值生成Layer结构"
        
        -- 左列：预设列表区域 (收窄1/3) - 调整groupBox位置向上移动
        groupBox gpbPresetList "预设列表" pos:[5,60] width:155 height:420
        
        -- 预设编辑区域 - 移到预设列表上方
        editText txtPresetName "" pos:[12,80] width:90 height:16 text:""
        button btnUpdatePreset "重命名" pos:[108,80] width:42 height:16 tooltip:"更新预设名称"
        
        listBox lstPresets "" pos:[15,100] width:135 height:20
        
        -- 预设描述编辑区域 - 调整位置
        editText txtPresetDesc "" pos:[10,375] width:140 height:80 readOnly:false
        button btnUpdateDesc "更新描述" pos:[12,460] width:140 height:16 tooltip:"更新预设描述"
        
        -- 中列：配置区域
        groupBox gpbConfig "Layer结构编辑" pos:[170,60] width:280 height:420
        
        -- Layer结构模板编辑区域 (完全扩展)
        editText txtLayerName "Layer:" pos:[180,85] width:200 height:16 text:"00_{Name}_Master" tooltip:"可使用{字段名}作为占位符"
        button btnAddLayer "+" pos:[390,85] width:25 height:20 tooltip:"添加Layer"
        button btnRemoveLayer "-" pos:[420,85] width:25 height:20 tooltip:"删除选中Layer"
        button btnMoveUp "↑" pos:[425,140] width:20 height:80 tooltip:"上移"
        button btnMoveDown "↓" pos:[425,220] width:20 height:80 tooltip:"下移"
        
        -- 字段插入辅助控件
        label lblFieldInsert "插入字段:" pos:[180,115] width:70 height:16
        dropDownList ddlFieldInsert "" pos:[245,113] width:100 height:18 items:#("Name", "Type", "Part", "LOD", "Mat") tooltip:"选择要插入的字段"
        button btnInsertField "插入" pos:[355,113] width:40 height:18 tooltip:"插入选中字段到Layer名称"
        button btnAddToList "+" pos:[400,113] width:20 height:18 tooltip:"添加新的字段选项"
        button btnRemoveFromList "-" pos:[425,113] width:20 height:18 tooltip:"删除选中的字段选项"
        
        listBox lstLayerStructure "" pos:[180,140] width:240 height:12
        
        -- 右列：字段值管理区域
        groupBox gpbFieldValues "字段值管理" pos:[460,60] width:255 height:420
        
        -- 预览区域
        label lblPreviewTitle "预览:" pos:[470,80] width:50 height:16
        editText txtPreview "" pos:[470,100] width:235 height:370 readOnly:true
        
        -- 可滚动的字段列表区域 (支持更多字段)
        listBox lstFieldValues "字段列表:" pos:[180,305] width:240 height:7
        button btnRefreshFields "🔄" pos:[425,320] width:20 height:95 tooltip:"刷新字段列表"
        
        -- 当前选中字段的编辑区域
        editText txtFieldName "字段名:" pos:[180,430] width:160 height:16 text:""
        editText txtFieldValue "字段值:" pos:[180,455] width:160 height:16 text:""
        button btnUpdateField "配置字段值" pos:[355,430] width:80 height:18 tooltip:"更新字段"
        button btnDeleteField "删除字段" pos:[355,455] width:80 height:18 tooltip:"删除字段"
        
        -- 窗口拖拽
        on rolBsLayerManager lbuttondown posMou do
        (
            setSysCur #move
            offsetBsLayerManager = posMou
            dragStateBsLayerManager = on
        )
        
        on rolBsLayerManager lbuttonup posMou do (dragStateBsLayerManager = off)
        
        on rolBsLayerManager mouseMove pos do
        (
            if dragStateBsLayerManager == on then
                SetDialogPos rolBsLayerManager (mouse.screenpos - offsetBsLayerManager)
        )
        
        -- 从Layer结构中提取字段名
        fn fnExtractFieldsFromStructure =
        (
            local extractedFields = #()
            if currentPreset != undefined and currentPreset.layerStructure.count > 0 then
            (
                for layerInfo in currentPreset.layerStructure do
                (
                    local layerName = layerInfo[1]
                    
                    -- 使用循环方式查找所有 {字段名} 格式的占位符
                    local pos = 1
                    local maxLoop = 50 -- 防止无限循环
                    local loopCount = 0
                    
                    while pos <= layerName.count and loopCount < maxLoop do
                    (
                        loopCount += 1
                        -- 从当前位置开始查找
                        local searchStr = substring layerName pos -1
                        local openPos = findString searchStr "{"
                        if openPos == undefined then exit
                        
                        -- 转换为原字符串中的绝对位置
                        openPos = openPos + pos - 1
                        
                        -- 从开括号后开始查找闭括号
                        local closeSearchStr = substring layerName (openPos + 1) -1
                        local closePos = findString closeSearchStr "}"
                        if closePos == undefined then exit
                        
                        -- 转换为原字符串中的绝对位置
                        closePos = closePos + openPos
                        
                        if closePos > openPos + 1 then
                        (
                            local fieldName = substring layerName (openPos + 1) (closePos - openPos - 1)
                            if fieldName != "" and findItem extractedFields fieldName == 0 then
                                append extractedFields fieldName
                        )
                        
                        pos = closePos + 1
                    )
                )
            )
            return extractedFields
        )
        
        -- 防止循环更新的标志
        global updatingUI = false
        
        -- 获取字段值数组
        fn fnGetFieldValues =
        (
            return arrFieldValues
        )
        
        -- 字段值管理
        fn fnUpdateFieldValuesList =
        (
            if updatingUI then return false
            
            -- 自动从Layer结构提取字段
            local extractedFields = fnExtractFieldsFromStructure()
            
            -- 更新当前预设的字段列表
            if currentPreset != undefined then
                currentPreset.fieldNames = extractedFields
            
            local fieldDisplay = #()
            if extractedFields.count > 0 then
            (
                for i = 1 to extractedFields.count do
                (
                    local fieldName = extractedFields[i]
                    local fieldValue = ""
                    
                    -- 获取对应的字段值（如果存在）
                    if i <= arrFieldValues.count then
                        fieldValue = arrFieldValues[i]
                    
                    local displayText = fieldName + " = \"" + fieldValue + "\""
                    append fieldDisplay displayText
                )
            )
            lstFieldValues.items = fieldDisplay
            return true
        )
        
        -- 强制刷新字段列表（不受updatingUI标志影响）
        fn fnForceUpdateFieldList =
        (
            -- 自动从Layer结构提取字段
            local extractedFields = fnExtractFieldsFromStructure()
            
            -- 更新当前预设的字段列表
            if currentPreset != undefined then
                currentPreset.fieldNames = extractedFields
            
            local fieldDisplay = #()
            if extractedFields.count > 0 then
            (
                for i = 1 to extractedFields.count do
                (
                    local fieldName = extractedFields[i]
                    local fieldValue = ""
                    
                    -- 获取对应的字段值（如果存在）
                    if i <= arrFieldValues.count then
                        fieldValue = arrFieldValues[i]
                    
                    local displayText = fieldName + " = \"" + fieldValue + "\""
                    append fieldDisplay displayText
                )
            )
            lstFieldValues.items = fieldDisplay
            
            -- 同时更新预览
            if currentPreset != undefined then
            (
                local previewText = "预设: " + currentPreset.name + "\n\n"
                
                -- 获取字段值
                local fieldValues = fnGetFieldValues()
                local hasValues = false
                for val in fieldValues do
                    if val != "" then (hasValues = true; exit)
                
                if currentPreset.layerStructure.count > 0 then
                (
                    previewText += "生成的Layer结构:\r\n\r\n"
                    for layerInfo in currentPreset.layerStructure do
                    (
                        local layerName = layerInfo[1]
                        -- 如果有字段值，进行替换
                        if hasValues and currentPreset.fieldNames != undefined then
                        (
                            for i = 1 to currentPreset.fieldNames.count do
                            (
                                if i <= fieldValues.count and fieldValues[i] != "" then
                                    layerName = substituteString layerName ("{" + currentPreset.fieldNames[i] + "}") fieldValues[i]
                            )
                        )
                        previewText += layerName + "\n"
                    )
                )
                else
                (
                    previewText += "暂无Layer结构\n请在左侧编辑区域添加Layer"
                )
                
                txtPreview.text = previewText
            )
            
            return true
        )
        
        -- 设置字段值
        fn fnSetFieldValue index value =
        (
            -- 确保数组足够长
            while arrFieldValues.count < index do
                append arrFieldValues ""
            arrFieldValues[index] = value
            
            -- 更新字段列表和预览
            fnUpdateFieldValuesList()
            fnForceUpdateFieldList()
        )
        
        -- UI更新函数
        fn fnUpdateUI =
        (
            if updatingUI then return false
            updatingUI = true
            
            try
            (
                if currentPreset != undefined then
                (
                    txtPresetName.text = currentPreset.name
                    txtPresetDesc.text = currentPreset.description
                    
                    -- 更新Layer结构模板列表
                    local structureDisplay = #()
                    for layerInfo in currentPreset.layerStructure do
                        append structureDisplay layerInfo[1]
                    lstLayerStructure.items = structureDisplay
                    
                    -- 更新字段值列表
                    fnUpdateFieldValuesList()
                    
                    -- 更新预览
                    local previewText = "预设: " + currentPreset.name + "\n\n"
                    
                    -- 获取字段值
                    local fieldValues = fnGetFieldValues()
                    local hasValues = false
                    for val in fieldValues do
                        if val != "" then (hasValues = true; exit)
                    
                    if currentPreset.layerStructure.count > 0 then
                    (
                        previewText += "生成的Layer结构:\r\n\r\n"
                        for layerInfo in currentPreset.layerStructure do
                        (
                            local layerName = layerInfo[1]
                            -- 如果有字段值，进行替换
                            if hasValues and currentPreset.fieldNames != undefined then
                            (
                                for i = 1 to currentPreset.fieldNames.count do
                                (
                                    if i <= fieldValues.count and fieldValues[i] != "" then
                                        layerName = substituteString layerName ("{" + currentPreset.fieldNames[i] + "}") fieldValues[i]
                                )
                            )
                            previewText += layerName + "\n"
                        )
                    )
                    else
                    (
                        previewText += "暂无Layer结构\n请在左侧编辑区域添加Layer"
                    )
                    
                    txtPreview.text = previewText
                )
                else
                (
                    txtPresetName.text = ""
                    txtPresetDesc.text = ""
                    lstLayerStructure.items = #()
                    lstFieldValues.items = #()
                    txtPreview.text = "请选择预设"
                )
            )
            catch
            (
                print "UI更新出错"
            )
            
            updatingUI = false
            return true
        )
        
        -- 更新字段选项下拉列表
        fn fnUpdateFieldOptions =
        (
            ddlFieldInsert.items = arrFieldOptions
            if ddlFieldInsert.items.count > 0 and ddlFieldInsert.selection == 0 then
                ddlFieldInsert.selection = 1
        )
        
        fn fnRefreshPresetList =
        (
            local presetNames = #()
            for i = 1 to arrLayerPresets.count do
            (
                local preset = arrLayerPresets[i]
                local displayName = preset.name
                if preset.layerStructure.count > 0 then
                    displayName += " (" + preset.layerStructure.count as string + ")"
                append presetNames displayName
            )
            lstPresets.items = presetNames
            
            if lstPresets.selection > 0 and lstPresets.selection <= arrLayerPresets.count then
            (
                currentPreset = arrLayerPresets[lstPresets.selection]
                currentPresetIndex = lstPresets.selection
                arrFieldValues = #() -- 重置字段值
                fnUpdateUI()
                -- 强制刷新字段列表
                fnForceUpdateFieldList()
            )
        )
        
        fn fnSavePresets =
        (
            try
            (
                setINISetting BsLayerManagerConfig "BsLayerManager" "PresetCount" (arrLayerPresets.count as string)
                setINISetting BsLayerManagerConfig "BsLayerManager" "FieldOptions" (arrFieldOptions as string)
                
                for i = 1 to arrLayerPresets.count do
                (
                    local preset = arrLayerPresets[i]
                    local sectionName = "Preset_" + i as string
                    setINISetting BsLayerManagerConfig sectionName "Name" preset.name
                    setINISetting BsLayerManagerConfig sectionName "Description" preset.description
                    setINISetting BsLayerManagerConfig sectionName "LayerStructure" (preset.layerStructure as string)
                    setINISetting BsLayerManagerConfig sectionName "FieldNames" (preset.fieldNames as string)
                )
                print "配置已保存"
                return true
            )
            catch
            (
                print "保存失败"
                return false
            )
        )
        
        -- 导出所有预设到文件
        fn fnExportPresets =
        (
            local exportFile = getSaveFileName caption:"导出预设文件" types:"Layer预设文件(*.blm)|*.blm|所有文件(*.*)|*.*|"
            if exportFile != undefined then
            (
                try
                (
                    -- 创建导出数据结构
                    local exportData = #()
                    
                    -- 添加字段选项
                    append exportData ("FieldOptions=" + (arrFieldOptions as string))
                    
                    -- 添加预设数据
                    append exportData ("PresetCount=" + (arrLayerPresets.count as string))
                    
                    for i = 1 to arrLayerPresets.count do
                    (
                        local preset = arrLayerPresets[i]
                        local sectionName = "Preset_" + i as string
                        -- 使用引号包围字符串来保护中文字符
                        append exportData (sectionName + "_Name=\"" + preset.name + "\"")
                        append exportData (sectionName + "_Description=\"" + preset.description + "\"")
                        append exportData (sectionName + "_LayerStructure=" + (preset.layerStructure as string))
                        append exportData (sectionName + "_FieldNames=" + (preset.fieldNames as string))
                    )
                    
                    -- 写入文件
                    local file = createFile exportFile
                    if file != undefined then
                    (
                        format "-- BsLayerManager Presets Export File\n" to:file
                        format "-- Export Time: %\n" (localTime) to:file
                        format "-- Preset Count: %\n\n" arrLayerPresets.count to:file
                        
                        for line in exportData do
                            format "%\n" line to:file
                        
                        close file
                    )
                    
                    messageBox ("成功导出 " + arrLayerPresets.count as string + " 个预设到:\n" + exportFile) title:"导出成功"
                    return true
                )
                catch
                (
                    messageBox "导出失败！请检查文件路径和权限。" title:"导出错误"
                    return false
                )
            )
            return false
        )
        
        -- 从文件导入预设
        fn fnImportPresets =
        (
            local importFile = getOpenFileName caption:"选择预设文件" types:"Layer预设文件(*.blm)|*.blm|所有文件(*.*)|*.*|"
            if importFile != undefined then
            (
                if doesFileExist importFile then
                (
                    try
                    (
                        -- 询问是否替换现有预设
                        local replaceMode = queryBox "是否替换当前所有预设？\n\n选择'是'：清空当前预设，导入新预设\n选择'否'：在现有预设基础上添加导入的预设" title:"导入模式"
                        
                        -- 读取文件
                        local file = openFile importFile
                        local importData = #()
                        while not eof file do
                        (
                            local line = readLine file
                            if line != undefined and findString line "=" != undefined and findString line "--" != 1 then
                                append importData line
                        )
                        close file
                        
                        if not replaceMode then
                        (
                            -- 备份当前预设
                            local backupPresets = deepCopy arrLayerPresets
                            local backupFieldOptions = deepCopy arrFieldOptions
                        )
                        else
                        (
                            -- 清空当前预设
                            arrLayerPresets = #()
                        )
                        
                        -- 解析导入数据
                        local fieldOptionsStr = ""
                        local presetCount = 0
                        
                        for line in importData do
                        (
                            local eqPos = findString line "="
                            if eqPos != undefined then
                            (
                                local key = substring line 1 (eqPos - 1)
                                local value = substring line (eqPos + 1) -1
                                
                                if key == "FieldOptions" then
                                (
                                    try (arrFieldOptions = execute value) catch()
                                )
                                else if key == "PresetCount" then
                                (
                                    try (presetCount = value as integer) catch()
                                )
                            )
                        )
                        
                        -- 导入预设
                        local importedCount = 0
                        for i = 1 to presetCount do
                        (
                            local sectionName = "Preset_" + i as string
                            local presetName = ""
                            local presetDesc = ""
                            local layerStructStr = ""
                            local fieldNamesStr = ""
                            
                            for line in importData do
                            (
                                local eqPos = findString line "="
                                if eqPos != undefined then
                                (
                                    local key = substring line 1 (eqPos - 1)
                                    local value = substring line (eqPos + 1) -1
                                    
                                    -- 移除值周围的引号（如果存在）
                                    if value.count >= 2 and value[1] == "\"" and value[value.count] == "\"" then
                                        value = substring value 2 (value.count - 2)
                                    
                                    if key == (sectionName + "_Name") then presetName = value
                                    else if key == (sectionName + "_Description") then presetDesc = value
                                    else if key == (sectionName + "_LayerStructure") then layerStructStr = value
                                    else if key == (sectionName + "_FieldNames") then fieldNamesStr = value
                                )
                            )
                            
                            if presetName != "" then
                            (
                                local preset = LayerPreset name:presetName description:presetDesc layerStructure:#() fieldNames:#()
                                try (preset.layerStructure = execute layerStructStr) catch (preset.layerStructure = #())
                                try (preset.fieldNames = execute fieldNamesStr) catch (preset.fieldNames = #("Name", "Type"))
                                append arrLayerPresets preset
                                importedCount += 1
                            )
                        )
                        
                        if not replaceMode then
                        (
                            -- 合并备份的预设
                            for preset in backupPresets do
                                append arrLayerPresets preset
                        )
                        
                        fnRefreshPresetList()
                        messageBox ("成功导入 " + importedCount as string + " 个预设！") title:"导入成功"
                        return true
                    )
                    catch
                    (
                        messageBox "导入失败！文件格式可能不正确。" title:"导入错误"
                        return false
                    )
                )
                else
                (
                    messageBox "文件不存在！" title:"导入错误"
                    return false
                )
            )
            return false
        )
        
        fn fnLoadPresets =
        (
            try
            (
                arrLayerPresets = #()
                if doesFileExist BsLayerManagerConfig then
                (
                    -- 加载字段选项
                    local fieldOptionsStr = getINISetting BsLayerManagerConfig "BsLayerManager" "FieldOptions"
                    if fieldOptionsStr != "" then
                    (
                        try (arrFieldOptions = execute fieldOptionsStr) catch (arrFieldOptions = #("Name", "Type", "Part", "LOD", "Mat"))
                    )
                    
                    local presetCount = getINISetting BsLayerManagerConfig "BsLayerManager" "PresetCount"
                    if presetCount != "" then
                    (
                        local count = presetCount as integer
                        for i = 1 to count do
                        (
                            local sectionName = "Preset_" + i as string
                            local presetName = getINISetting BsLayerManagerConfig sectionName "Name"
                            local presetDesc = getINISetting BsLayerManagerConfig sectionName "Description"
                            local layerStructStr = getINISetting BsLayerManagerConfig sectionName "LayerStructure"
                            local fieldNamesStr = getINISetting BsLayerManagerConfig sectionName "FieldNames"
                            
                            if presetName != "" then
                            (
                                local preset = LayerPreset name:presetName description:presetDesc layerStructure:#() fieldNames:#()
                                try (preset.layerStructure = execute layerStructStr) catch (preset.layerStructure = #())
                                try (preset.fieldNames = execute fieldNamesStr) catch (preset.fieldNames = #("AAA", "BBB", "CCC"))
                                append arrLayerPresets preset
                            )
                        )
                    )
                )
                fnRefreshPresetList()
                return true
            )
            catch
            (
                print "加载失败"
                return false
            )
        )
        
        fn fnCreateLayers =
        (
            if currentPreset == undefined then
            (
                print "请先选择预设"
                return false
            )
            
            if currentPreset.layerStructure.count == 0 then
            (
                print "预设无Layer结构"
                return false
            )
            
            local fieldValues = fnGetFieldValues()
            
            -- 替换字段值
            fn replaceFields str fieldNames fieldValues =
            (
                local result = str
                for i = 1 to fieldNames.count do
                (
                    if i <= fieldValues.count then
                        result = substituteString result ("{" + fieldNames[i] + "}") fieldValues[i]
                )
                return result
            )
            
            -- 创建layers
            local createdLayers = #()
            local errorCount = 0
            
            for i = 1 to currentPreset.layerStructure.count do
            (
                local layerInfo = currentPreset.layerStructure[i]
                local layerName = replaceFields layerInfo[1] currentPreset.fieldNames fieldValues
                local parentIndex = layerInfo[2]
                
                try
                (
                    local existingLayer = LayerManager.getLayerFromName layerName
                    if existingLayer == undefined then
                    (
                        LayerManager.newLayerFromName layerName
                        local newLayer = LayerManager.getLayerFromName layerName
                        
                        if newLayer != undefined then
                        (
                            append createdLayers newLayer
                            
                            if parentIndex > 0 and parentIndex <= createdLayers.count then
                                newLayer.setParent createdLayers[parentIndex]
                        )
                    )
                    else errorCount += 1
                )
                catch (errorCount += 1)
            )
            
            print ("创建了 " + createdLayers.count as string + " 个Layers" + 
                   (if errorCount > 0 then (", " + errorCount as string + " 个失败或已存在") else ""))
            
            return true
        )
        
        -- 事件处理
        on lstPresets selected index do
        (
            if index > 0 and index <= arrLayerPresets.count then
            (
                currentPreset = arrLayerPresets[index]
                currentPresetIndex = index
                arrFieldValues = #() -- 重置字段值
                fnUpdateUI()
                -- 强制刷新字段列表
                fnForceUpdateFieldList()
            )
        )
        
        on lstPresets doubleClicked index do
        (
            if index > 0 and index <= arrLayerPresets.count then
                fnCreateLayers()
        )
        
        on btnNewPreset pressed do
        (
            local newName = "新预设" + (arrLayerPresets.count + 1) as string
            local newPreset = LayerPreset name:newName description:"新建预设" layerStructure:#() fieldNames:#("Name", "Type")
            append arrLayerPresets newPreset
            fnRefreshPresetList()
            lstPresets.selection = arrLayerPresets.count
        )
        
        on btnCopyPreset pressed do
        (
            if currentPreset != undefined then
            (
                local copyPreset = LayerPreset name:(currentPreset.name + "_副本") description:currentPreset.description
                copyPreset.layerStructure = deepCopy currentPreset.layerStructure
                copyPreset.fieldNames = deepCopy currentPreset.fieldNames
                append arrLayerPresets copyPreset
                fnRefreshPresetList()
                lstPresets.selection = arrLayerPresets.count
            )
        )
        
        on btnDeletePreset pressed do
        (
            if currentPreset != undefined then
            (
                deleteItem arrLayerPresets currentPresetIndex
                currentPreset = undefined
                currentPresetIndex = 0
                fnRefreshPresetList()
                fnUpdateUI()
                print "预设已删除"
            )
        )
        
        on btnSaveConfig pressed do (fnSavePresets())
        on btnExportPresets pressed do (fnExportPresets())
        on btnLoadConfig pressed do (fnImportPresets())
        on btnCreateLayers pressed do (fnCreateLayers())
        
        on btnInsertField pressed do
        (
            if ddlFieldInsert.selection > 0 then
            (
                local selectedField = ddlFieldInsert.items[ddlFieldInsert.selection]
                local currentText = txtLayerName.text
                txtLayerName.text = currentText + "_{" + selectedField + "}"
                print ("已插入字段: {" + selectedField + "}")
                
                -- 立即刷新字段列表
                fnForceUpdateFieldList()
            )
        )
        
        -- 添加Layer名称文本变化事件
        on txtLayerName changed text do
        (
            -- 如果正在编辑Layer名称，实时更新选中的Layer结构
            if currentPreset != undefined and lstLayerStructure.selection > 0 and lstLayerStructure.selection <= currentPreset.layerStructure.count then
            (
                local index = lstLayerStructure.selection
                local layerInfo = currentPreset.layerStructure[index]
                currentPreset.layerStructure[index] = #(text, layerInfo[2])
                arrLayerPresets[currentPresetIndex] = currentPreset
                
                -- 更新Layer结构显示（不触发selection事件）
                local structureDisplay = #()
                for layerInfo in currentPreset.layerStructure do
                    append structureDisplay layerInfo[1]
                lstLayerStructure.items = structureDisplay
                lstLayerStructure.selection = index -- 保持选择
            )
            
            -- 实时更新字段列表和预览
            fnForceUpdateFieldList()
        )
        
        on btnAddToList pressed do
        (
            -- 使用全局变量来传递数据
            global tempFieldInput = ""
            
            -- 创建一个简单的输入对话框
            rollout dlgFieldInput "添加字段选项" width:250 height:100
            (
                editText txtInput "字段名称:" pos:[10,10] width:230 height:18 text:"NewField"
                button btnOK "确定" pos:[70,40] width:50 height:25
                button btnCancel "取消" pos:[130,40] width:50 height:25
                
                on btnOK pressed do
                (
                    tempFieldInput = txtInput.text
                    destroyDialog dlgFieldInput
                )
                
                on btnCancel pressed do
                (
                    tempFieldInput = ""
                    destroyDialog dlgFieldInput
                )
                
                on txtInput entered text do
                (
                    tempFieldInput = text
                    destroyDialog dlgFieldInput
                )
            )
            
            createDialog dlgFieldInput modal:true
            
            if tempFieldInput != "" then
            (
                if findItem arrFieldOptions tempFieldInput == 0 then
                (
                    append arrFieldOptions tempFieldInput
                    fnUpdateFieldOptions()
                    ddlFieldInsert.selection = arrFieldOptions.count
                    print ("已添加字段选项: " + tempFieldInput)
                )
                else
                (
                    messageBox ("字段选项 '" + tempFieldInput + "' 已存在！") title:"错误"
                )
            )
            
            -- 清理全局变量
            tempFieldInput = undefined
        )
        
        on btnRemoveFromList pressed do
        (
            if ddlFieldInsert.selection > 0 and arrFieldOptions.count > 1 then
            (
                local selectedField = arrFieldOptions[ddlFieldInsert.selection]
                if queryBox ("确定要删除字段选项 '" + selectedField + "' 吗？") title:"确认删除" then
                (
                    deleteItem arrFieldOptions ddlFieldInsert.selection
                    fnUpdateFieldOptions()
                    print ("已删除字段选项: " + selectedField)
                )
            )
            else if arrFieldOptions.count <= 1 then
            (
                messageBox "至少需要保留一个字段选项！" title:"提示"
            )
        )
        
        on btnDeleteField pressed do
        (
            if currentPreset != undefined and lstFieldValues.selection > 0 then
            (
                local index = lstFieldValues.selection
                local fieldName = currentPreset.fieldNames[index]
                
                -- 从所有Layer结构中移除该字段的引用
                for i = 1 to currentPreset.layerStructure.count do
                (
                    local layerInfo = currentPreset.layerStructure[i]
                    local newLayerName = substituteString layerInfo[1] ("{" + fieldName + "}") ""
                    currentPreset.layerStructure[i] = #(newLayerName, layerInfo[2])
                )
                
                -- 同时删除对应的字段值
                if index <= arrFieldValues.count then
                    deleteItem arrFieldValues index
                    
                arrLayerPresets[currentPresetIndex] = currentPreset
                fnUpdateUI()
                
                -- 立即刷新字段列表和预览
                fnForceUpdateFieldList()
                
                txtFieldName.text = ""
                txtFieldValue.text = ""
                print ("已删除字段: " + fieldName + " 及其在Layer结构中的引用")
            )
        )
        
        on btnUpdateField pressed do
        (
            if currentPreset != undefined and lstFieldValues.selection > 0 and txtFieldName.text != "" then
            (
                local index = lstFieldValues.selection
                local oldName = currentPreset.fieldNames[index]
                local newName = txtFieldName.text
                local newValue = txtFieldValue.text
                
                -- 在所有Layer结构中替换字段名
                for i = 1 to currentPreset.layerStructure.count do
                (
                    local layerInfo = currentPreset.layerStructure[i]
                    local newLayerName = substituteString layerInfo[1] ("{" + oldName + "}") ("{" + newName + "}")
                    currentPreset.layerStructure[i] = #(newLayerName, layerInfo[2])
                )
                
                arrLayerPresets[currentPresetIndex] = currentPreset
                
                -- 更新字段值
                fnSetFieldValue index newValue
                
                -- 立即刷新预览
                fnForceUpdateFieldList()
                
                print ("字段已更新: " + oldName + " → " + newName + " = \"" + newValue + "\"")
            )
        )
        
        on lstFieldValues selected index do
        (
            if currentPreset != undefined and index > 0 then
            (
                local extractedFields = fnExtractFieldsFromStructure()
                if index <= extractedFields.count then
                (
                    txtFieldName.text = extractedFields[index]
                    txtFieldValue.text = if index <= arrFieldValues.count then arrFieldValues[index] else ""
                )
            )
        )
        
        on txtFieldValue changed text do
        (
            if not updatingUI and currentPreset != undefined and lstFieldValues.selection > 0 then
            (
                fnSetFieldValue lstFieldValues.selection text
            )
        )
        
        on btnAddLayer pressed do
        (
            if currentPreset != undefined and txtLayerName.text != "" then
            (
                local newLayerInfo = #(txtLayerName.text, 0) -- 暂时不支持父级，都是顶级
                append currentPreset.layerStructure newLayerInfo
                arrLayerPresets[currentPresetIndex] = currentPreset
                fnUpdateUI()
                txtLayerName.text = "00_{Name}_Master"
                
                -- 强制刷新字段列表
                fnForceUpdateFieldList()
            )
        )
        
        on btnRemoveLayer pressed do
        (
            if currentPreset != undefined and lstLayerStructure.selection > 0 then
            (
                deleteItem currentPreset.layerStructure lstLayerStructure.selection
                arrLayerPresets[currentPresetIndex] = currentPreset
                fnUpdateUI()
                
                -- 强制刷新字段列表
                fnForceUpdateFieldList()
            )
        )
        
        on btnMoveUp pressed do
        (
            if currentPreset != undefined and lstLayerStructure.selection > 1 then
            (
                local index = lstLayerStructure.selection
                local temp = currentPreset.layerStructure[index]
                currentPreset.layerStructure[index] = currentPreset.layerStructure[index-1]
                currentPreset.layerStructure[index-1] = temp
                arrLayerPresets[currentPresetIndex] = currentPreset
                fnUpdateUI()
                lstLayerStructure.selection = index - 1
                
                -- 强制刷新字段列表
                fnForceUpdateFieldList()
            )
        )
        
        on btnMoveDown pressed do
        (
            if currentPreset != undefined and lstLayerStructure.selection > 0 and lstLayerStructure.selection < currentPreset.layerStructure.count then
            (
                local index = lstLayerStructure.selection
                local temp = currentPreset.layerStructure[index]
                currentPreset.layerStructure[index] = currentPreset.layerStructure[index+1]
                currentPreset.layerStructure[index+1] = temp
                arrLayerPresets[currentPresetIndex] = currentPreset
                fnUpdateUI()
                lstLayerStructure.selection = index + 1
                
                -- 强制刷新字段列表
                fnForceUpdateFieldList()
            )
        )
        
        -- 添加Layer结构列表选择变化事件
        on lstLayerStructure selected index do
        (
            if currentPreset != undefined and index > 0 and index <= currentPreset.layerStructure.count then
            (
                local layerInfo = currentPreset.layerStructure[index]
                txtLayerName.text = layerInfo[1]
                fnForceUpdateFieldList()
            )
        )
        
        on btnAbout pressed do
        (
            local helpText = "🎯 BsLayerManager v1.0 操作说明\n"
            helpText += "==============================\n\n"
            
            helpText += "📋 【核心概念】\n"
            helpText += "• 预设：Layer结构模板方案\n"
            helpText += "• 字段：{Name}、{Type} 等占位符\n"
            helpText += "• 生成：用字段值替换占位符创建Layer\n\n"
            
            helpText += "🚀 【快速使用】\n"
            helpText += "1. 选择或新建预设\n"
            helpText += "2. 添加Layer模板（如：00_{Name}_Master）\n"
            helpText += "3. 设置字段值（Name=Character, Type=Geo）\n"
            helpText += "4. 查看预览效果\n"
            helpText += "5. 点击'🚀生成Layers'创建\n\n"
            
            helpText += "📝 【主要功能】\n"
            helpText += "• 预设管理：➕新建 📋复制 🗑删除 💾保存\n"
            helpText += "• Layer编辑：添加模板，使用{字段名}占位符\n"
            helpText += "• 字段管理：自动提取字段，配置字段值\n"
            helpText += "• 实时预览：右侧显示生成后的Layer结构\n\n"
            
            helpText += "💡 【常用字段】\n"
            helpText += "{Name} - 角色名  {Type} - 类型  {Part} - 部位\n"
            helpText += "{LOD} - 细节级别  {Mat} - 材质标识\n\n"
            
            helpText += "⚡ 【示例】\n"
            helpText += "模板：01_{Name}_{Type}_Geo\n"
            helpText += "字段：Name=Hero, Type=Body\n"
            helpText += "结果：01_Hero_Body_Geo\n\n"
            
            helpText += "双击预设可快速生成 | 🔄可手动刷新\n"
            helpText += "==============================\n"
            helpText += "作者：Bullet.S"
            
            messageBox helpText title:"BsLayerManager 操作说明" beep:false
        )
        
        on btnUpdatePreset pressed do
        (
            if currentPreset != undefined and txtPresetName.text != "" then
            (
                local oldName = currentPreset.name
                currentPreset.name = txtPresetName.text
                arrLayerPresets[currentPresetIndex] = currentPreset
                fnRefreshPresetList()
                -- 保持当前选择
                lstPresets.selection = currentPresetIndex
                print ("预设名称已更新: " + oldName + " → " + currentPreset.name)
            )
        )
        
        on btnUpdateDesc pressed do
        (
            if currentPreset != undefined and txtPresetDesc.text != undefined then
            (
                local oldDesc = currentPreset.description
                currentPreset.description = txtPresetDesc.text
                arrLayerPresets[currentPresetIndex] = currentPreset
                print ("预设描述已更新: " + oldDesc + " → " + currentPreset.description)
            )
        )
        
        on btnRefreshFields pressed do
        (
            fnForceUpdateFieldList()
            print "字段列表已手动刷新"
        )
        
        on btnClose pressed do
        (
            try (destroydialog rolBsLayerManager) catch ()
        )
        
        on rolBsLayerManager open do
        (   
            updatingUI = false
            arrFieldValues = #()
            
            fnLoadPresets()
            fnUpdateFieldOptions() -- 初始化字段选项下拉列表
            
            -- 创建默认预设 (简化)
            if arrLayerPresets.count == 0 then
            (
                local preset1 = LayerPreset name:"角色结构" description:"游戏角色Layer结构" layerStructure:#() fieldNames:#("Name", "Type")
                append preset1.layerStructure #("00_{Name}_Master", 0)
                append preset1.layerStructure #("01_{Name}_{Type}_Geo", 0)
                append arrLayerPresets preset1
                
                fnRefreshPresetList()
                if arrLayerPresets.count > 0 then
                    lstPresets.selection = 1
            )
            
            -- 确保在打开时强制刷新字段列表
            if currentPreset != undefined then
                fnForceUpdateFieldList()
        )
        
        on rolBsLayerManager close do (fnSavePresets())
    )
    
    createDialog rolBsLayerManager style:#()
) 