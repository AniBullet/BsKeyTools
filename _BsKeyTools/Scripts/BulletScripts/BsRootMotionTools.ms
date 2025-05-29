--制作者：李相元

global BS_RM_DataCA
-- 自定义属性定义，用于实现动态控制
BS_RM_DataCA = attributes RM_Data attribID:#(0x7b72aada, 0x1462108b) (
	parameters main rollout:BsRMRollout (
		-- 使用handle方式存储对象引用，避免循环依赖
		PelvisObjHandle type:#integer subAnim:false
		RootObjHandle type:#integer subAnim:false

		-- 控制参数，这些会显示在曲线编辑器中
		ManualX type:#float ui:spnManualX default:0
		ManualY type:#float ui:spnManualY default:0
		ManualZ type:#float ui:spnManualZ default:0
		TrackX type:#float ui:sliderTrackX default:0
		TrackX_Offset type:#float ui:spnTrackX_Offset default:0
		TrackY type:#float ui:sliderTrackY default:0
		TrackY_Offset type:#float ui:spnTrackY_Offset default:0
		TrackZ type:#float ui:sliderTrackZ default:0
		TrackZ_Offset type:#float ui:spnTrackZ_Offset default:0
		ManualYaw type:#float ui:spnManualYaw default:0
		TrackYaw type:#float ui:sliderTrackYaw default:0
		TrackYaw_Offset type:#float ui:spnTrackYaw_Offset default:90
	)

	rollout BsRMRollout ("Bs_RootMotion_Ctrl") width:160 height:630 (
		local animStateBackup

		label labelPelvisObj "骨盆: " align:#left pos:[5, 12]
		pickbutton pickAnimPelvisObj "选择动画骨盆" pos:[5, 32] width:150 tooltip:"选择有动画信息的骨盆。对于Biped，请选择Bip001。"
		label labelRootObj "根节点: " align:#left pos:[5, 62]
		pickbutton pickRootObj "选择根节点" width:150 pos:[5, 82] tooltip:"选择要用作根节点的对象。"
		button btnLinkController "链接控制器" width:150 height:25 pos:[5, 112] tooltip:"将控制器应用到根节点并与骨盆连接。"
		
		groupbox gpbPos "位置控制" pos:[5, 150] width:150 height:300
		
		spinner spnManualX "手动X:   " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 170]
		spinner spnManualY "手动Y:   " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 195]
		spinner spnManualZ "手动Z:   " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 220]
		label labelTrackX "TrackX: " align:#left width:50 pos:[10, 250]
		slider sliderTrackX "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left pos:[55, 240]
		spinner spnTrackX_Offset "TrackX 偏移:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136 pos:[10, 280]
		label labelTrackY "TrackY: " align:#left width:50 pos:[10, 305]
		slider sliderTrackY "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left pos:[55, 295]
		spinner spnTrackY_Offset "TrackY 偏移:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136 pos:[10, 335]
		label labelTrackZ "TrackZ: " align:#left width:50 pos:[10, 360]
		slider sliderTrackZ "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left pos:[55, 350]
		spinner spnTrackZ_Offset "TrackZ 偏移:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136 pos:[10, 390]
		button btnGetPelvisPosZ "获取骨盆Z位置" align:#center width:140 pos:[10, 420] tooltip:"自动获取骨盆距离地面的高度值并应用到TrackZ偏移中。"
		
		groupbox gpbRot "旋转控制" pos:[5, 460] width:150 height:100

		spinner spnManualYaw "手动 yaw:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 480]
		label labelTrackYaw "Track yaw:  " align:#left width:60 pos:[10, 505]
		slider sliderTrackYaw "" type:#float range:[0.0, 1.0, 0.0] width:90 align:#left pos:[70, 495]
		spinner spnTrackYaw_Offset "Track yaw 偏移:   " type:#float range:[-99999.0, 99999.0, 90.0] align:#left width:118 pos:[10, 530] tooltip:"默认值 = 90"

		button uiBtnHelp "关于" width:140 pos:[10, 570]
		
		function Initialize = (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if (pelvisObj != undefined) do (
				labelPelvisObj.text = "骨盆: " + pelvisObj.name
			)
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if (rootObj != undefined) do (
				labelRootObj.text = "根节点: " + rootObj.name
			)
			-- 为参数设置控制器（如果还没有的话）
			if (ManualX.controller == undefined) do (ManualX.controller = bezier_float ())
			if (ManualY.controller == undefined) do (ManualY.controller = bezier_float ())
			if (ManualZ.controller == undefined) do (ManualZ.controller = bezier_float ())
			if (TrackX.controller == undefined) do (TrackX.controller = bezier_float ())
			if (TrackX_Offset.controller == undefined) do (TrackX_Offset.controller = bezier_float ())
			if (TrackY.controller == undefined) do (TrackY.controller = bezier_float ())
			if (TrackY_Offset.controller == undefined) do (TrackY_Offset.controller = bezier_float ())
			if (TrackZ.controller == undefined) do (TrackZ.controller = bezier_float ())
			if (TrackZ_Offset.controller == undefined) do (TrackZ_Offset.controller = bezier_float ())
			if (ManualYaw.controller == undefined) do (ManualYaw.controller = bezier_float ())
			if (TrackYaw.controller == undefined) do (TrackYaw.controller = bezier_float ())
			if (TrackYaw_Offset.controller == undefined) do (TrackYaw_Offset.controller = bezier_float ())
		)

		on pickAnimPelvisObj picked obj do (
			if obj == undefined do return()
			PelvisObjHandle = obj.inode.handle
			labelPelvisObj.text = "骨盆: " + obj.name
		)

		on pickRootObj picked obj do (
			if obj == undefined do return()
			RootObjHandle = obj.inode.handle
			labelRootObj.text = "根节点: " + obj.name
		)
		
		on btnLinkController pressed do (
			-- 检查对象是否已选择
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if pelvisObj == undefined do return()
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj == undefined do return()
			local myRM_Data = selection[1].baseObject.RM_Data	-- 获取当前自定义属性数据

			-- 设置位置控制器
			rootObj.pos.controller = Position_XYZ ()
			rootObj.pos.controller.X_Position.controller = Float_Expression ()
			rootObj.pos.controller.Y_Position.controller = Float_Expression ()
			rootObj.pos.controller.Z_Position.controller = Float_Expression ()
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "ManualX" myRM_Data.ManualX.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "ManualY" myRM_Data.ManualY.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "ManualZ" myRM_Data.ManualZ.controller
			rootObj.pos.controller.X_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Y_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Z_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX" myRM_Data.TrackX.controller
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX_Offset" myRM_Data.TrackX_Offset.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY" myRM_Data.TrackY.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY_Offset" myRM_Data.TrackY_Offset.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ" myRM_Data.TrackZ.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ_Offset" myRM_Data.TrackZ_Offset.controller
			rootObj.pos.controller.X_Position.controller.SetExpression "(TrackX_Offset + PelvisPos.x)*TrackX + ManualX*(1-TrackX)"
			rootObj.pos.controller.Y_Position.controller.SetExpression "(TrackY_Offset + PelvisPos.y)*TrackY + ManualY*(1-TrackY)"
			rootObj.pos.controller.Z_Position.controller.SetExpression "(TrackZ_Offset + PelvisPos.z)*TrackZ + ManualZ*(1-TrackZ)"
			
			-- 设置旋转控制器
			rootObj.rotation.controller = Euler_XYZ ()
			rootObj.rotation.controller.X_Rotation.controller = Float_Expression ()
			rootObj.rotation.controller.X_Rotation.controller.SetExpression "0"
			rootObj.rotation.controller.Y_Rotation.controller = Float_Expression ()
			rootObj.rotation.controller.Y_Rotation.controller.SetExpression "0"
			rootObj.rotation.controller.Z_Rotation.controller = float_script ()
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "ManualYaw" myRM_Data.ManualYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw" myRM_Data.TrackYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw_Offset" myRM_Data.TrackYaw_Offset.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddNode "PelvisObj" pelvisObj
			rootObj.rotation.controller.Z_Rotation.controller.SetExpression ("local pelvisYaw = degToRad (PelvisObj.transform.rotation as EulerAngles).z\n" + 
				"local track = (pelvisYaw + degToRad (TrackYaw_Offset)) * TrackYaw\n" + 
				"local manual = degToRad(ManualYaw) * (1-TrackYaw)\n" + 
				"return (track + manual)")
		)

		on btnGetPelvisPosZ pressed do (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if pelvisObj == undefined do return()
			TrackZ_Offset = -pelvisObj.transform.pos.z
		)

		on BsRMRollout open do (
			Initialize()
		)

		-- 防止播放时产生意外关键帧的函数
		function OnButtonDown = (
			animStateBackup = animButtonState
			if isAnimPlaying() do (
				animButtonState = false
			)
		)

		function OnButtonUp = (
			animButtonState = animStateBackup
		)

		on spnManualX buttondown do (OnButtonDown())
		on spnManualX buttonup do (OnButtonUp())
		on spnManualY buttondown do (OnButtonDown())
		on spnManualY buttonup do (OnButtonUp())
		on spnManualZ buttondown do (OnButtonDown())
		on spnManualZ buttonup do (OnButtonUp())
		on sliderTrackX buttondown do (OnButtonDown())
		on sliderTrackX buttonup do (OnButtonUp())
		on spnTrackX_Offset buttondown do (OnButtonDown())
		on spnTrackX_Offset buttonup do (OnButtonUp())
		on sliderTrackY buttondown do (OnButtonDown())
		on sliderTrackY buttonup do (OnButtonUp())
		on spnTrackY_Offset buttondown do (OnButtonDown())
		on spnTrackY_Offset buttonup do (OnButtonUp())
		on sliderTrackZ buttondown do (OnButtonDown())
		on sliderTrackZ buttonup do (OnButtonUp())
		on spnTrackZ_Offset buttondown do (OnButtonDown())
		on spnTrackZ_Offset buttonup do (OnButtonUp())
		on spnManualYaw buttondown do (OnButtonDown())
		on spnManualYaw buttonup do (OnButtonUp())
		on sliderTrackYaw buttondown do (OnButtonDown())
		on sliderTrackYaw buttonup do (OnButtonUp())
		on spnTrackYaw_Offset buttondown do (OnButtonDown())
		on spnTrackYaw_Offset buttonup do (OnButtonUp())

		on uiBtnHelp pressed do (
			shellLaunch "https://cafe.naver.com/pinksox/9011" ""
		)
	)
)

global rolRootMotionTools
try (destroydialog rolRootMotionTools) catch()

rollout rolRootMotionTools ("BsRootTools_v1.0") width:240
(
	button uiCreateController "创建根运动控制器" width:100 height:30 tooltip:"在场景中创建一个新的根运动控制器对象" across:2
	button uiOpenController "打开现有控制器" width:100 height:30 tooltip:"查找并打开场景中已有的根运动控制器"
	group "管理工具" (
		button uiAddRMAttribute "添加根运动属性" width:200 tooltip:"给选中的对象添加根运动控制器属性"
		button uiRemoveRMAttribute "移除根运动属性" width:200 tooltip:"仅移除选中对象的根运动控制器属性，保留其他属性"
	)
	button uiBtnHelp "关于"

	-- 比较自定义属性ID的函数
	function CompareAttribID idA idB = (
		if (idA[1] == idB[1] AND idA[2] == idB[2]) then (return true) else (return false)
	)

	-- 获取根运动控制器属性索引
	function GetRootMotionCtrlAttrIndex obj = (
		local attrCount = custAttributes.count obj
		for i = 1 to attrCount do (
			local tID = (custAttributes.getDef obj i).attribID
			if (CompareAttribID tID #(0x7b72aada, 0x1462108b)) do (return i)
		)
		return 0		
	)

	-- 查找场景中的根运动控制器
	function FindRootMotionCtrl = (
		for obj in objects do (
			if (GetRootMotionCtrlAttrIndex obj) != 0 do (return obj)
		)
		return undefined
	)

	-- 创建表情控制器样式的手柄
	function CreateControllerObject = (
		-- 创建文字标识作为主控制器
		local mainController = Text()
		mainController.text = "ROOT\nMOTION"
		mainController.size = 8
		mainController.wirecolor = color 255 255 0  -- 黄色
		mainController.renderable = false
		
		-- 设置控制器属性
		mainController.name = uniqueName "RootMotionCtrl"
		
		-- 将控制器放置在膝盖侧边位置
		mainController.pos = [-60, 50, -50]  -- X轴正方向60单位（侧边），Z轴50单位（膝盖高度）
		
		-- 文字立起来显示（旋转90度面向摄像机）
		mainController.rotation = (eulerAngles -90 0 0)  -- 绕Z轴旋转90度让文字立起来
		
		-- 添加自定义属性到主控制器
		custAttributes.add mainController BS_RM_DataCA
		
		-- 选中新创建的控制器
		select mainController
		
		-- 自动打开修改面板显示自定义属性
		setCommandPanelTaskMode #modify
		
		return mainController
	)
	
	on uiCreateController pressed do (
		-- 检查是否已有控制器
		local existingController = FindRootMotionCtrl()
		if existingController != undefined then (
			local result = yesNoCancelBox ("场景中已存在根运动控制器: " + existingController.name + "\n\n是否要创建新的控制器？\n\n是=创建新的  否=打开现有的  取消=什么都不做")
			if result == #yes then (
				CreateControllerObject()
				messageBox "新的根运动控制器已创建！\n\n请在右侧修改器面板中找到\n'Bs_RootMotion_Ctrl' 控制面板。" title:"创建完成"
			) else if result == #no then (
				select existingController
				-- 自动打开修改面板显示自定义属性
				setCommandPanelTaskMode #modify
				-- messageBox "已选中现有的根运动控制器\n\n请在右侧修改器面板中查看\n'Bs_RootMotion_Ctrl' 控制面板。" title:"选中现有"
			)
		) else (
			CreateControllerObject()
			messageBox "根运动控制器已创建成功！\n\n请在右侧修改器面板中找到\n'Bs_RootMotion_Ctrl' 控制面板\n设置骨盆和根节点对象。" title:"创建完成"
		)
	)

	on uiOpenController pressed do (
		local controllerObj = FindRootMotionCtrl()
		if controllerObj != undefined then (
			select controllerObj
			-- 自动打开修改面板显示自定义属性
			setCommandPanelTaskMode #modify
			-- messageBox ("已选中根运动控制器: " + controllerObj.name + "\n\n请在右侧修改器面板中查看\n'Bs_RootMotion_Ctrl' 控制面板。") title:"已选中"
		) else (
			messageBox "场景中没有找到根运动控制器。\n请先点击'创建根运动控制器'。" title:"未找到"
		)
	)

	on uiAddRMAttribute pressed do (
		if selection.count == 0 do (
			messageBox "请先选择一个要添加根运动控制器属性的对象"
			return()
		)
		
		local obj = selection[1]
		local attrIndex = GetRootMotionCtrlAttrIndex obj
		if attrIndex > 0 then (
			messageBox ("对象 " + obj.name + " 已经有根运动控制器属性了！")
		) else (
			-- 添加自定义属性
			custAttributes.add obj BS_RM_DataCA
			-- 自动打开修改面板显示自定义属性
			setCommandPanelTaskMode #modify
			messageBox ("成功给对象 " + obj.name + " 添加根运动控制器属性！") title:"添加完成"
		)
	)

	on uiRemoveRMAttribute pressed do (
		if selection.count == 0 do (
			messageBox "请先选择一个对象"
			return()
		)
		
		local obj = selection[1]
		local attrIndex = GetRootMotionCtrlAttrIndex obj
		if attrIndex > 0 then (
			local result = yesNoCancelBox ("确定要移除对象 " + obj.name + " 的根运动控制器属性吗？\n\n这将删除所有相关的动画数据。")
			if result == #yes do with undo on (
				custAttributes.delete obj attrIndex
				messageBox "根运动控制器属性已移除" title:"移除完成"
			)
		) else (
			messageBox "选中的对象没有根运动控制器属性"
		)
	)

	on uiBtnHelp pressed do (
		shellLaunch "https://cafe.naver.com/pinksox/9011" ""
	)
)
createDialog rolRootMotionTools style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) lockWidth:true