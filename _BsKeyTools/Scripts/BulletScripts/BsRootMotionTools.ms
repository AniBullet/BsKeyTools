--制作者：李相元
--修改: Bullet.S

-- 检查修改器是否已加载
try (
	-- 尝试获取修改器的classID
	local modClassID = execute "BsRootMotionModifier.classID"
	if modClassID == undefined do throw "Modifier not loaded"
) catch (
	messageBox "请先加载根运动控制器脚本！\n\n1. 关闭当前文件\n2. 运行脚本: BsRootMotionTools（根运动工具）\n3. 重新打开Max文件（如果还弹窗不用管，再开一次脚本就好）                                                                  " title:"错误" beep:true
	exit
)

-- 定义根运动修改器
plugin modifier BsRootMotionModifier
	name:"Bs_RootMotion_Ctrl"
	classID:#(0x7b72aada, 0x1462108b)
	version:1
	category:"BsKeyTools"
	extends:EmptyModifier
(
	-- 参数定义
	parameters main rollout:BsRMRollout (
		-- 使用handle方式存储对象引用，避免循环依赖
		PelvisObjHandle type:#integer subAnim:false
		RootObjHandle type:#integer subAnim:false
		OriginalRootHandle type:#integer subAnim:false

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

	-- UI定义
	rollout BsRMRollout "Bs_RootMotion_Ctrl" width:160 height:680 (
		local animStateBackup

		label labelPelvisObj "质心: " align:#left pos:[5, 12]
		pickbutton pickAnimPelvisObj "选择动画质心" pos:[5, 32] width:150 tooltip:"选择有动画信息的质心。对于Biped，请选择Bip001。"
		label labelOriginalRoot "原根节点: " align:#left pos:[5, 62]
		pickbutton pickOriginalRoot "选择原根节点" width:150 pos:[5, 82] tooltip:"选择原始根节点对象。"
		label labelRootObj "临时根节点: " align:#left pos:[5, 112]
		pickbutton pickRootObj "选择临时根节点" width:150 pos:[5, 132] tooltip:"选择要用作临时根节点的对象。"
		
		button btnLinkController ">> 链接控制器 <<" width:140 height:40 pos:[10, 165] tooltip:"将控制器应用到根节点并与质心连接。" enabled:false
		
		groupbox gpbPos "位置控制" pos:[5, 217] width:150 height:280
		
		spinner spnManualX "手动X:   " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 237]
		spinner spnManualY "手动Y:   " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 262]
		spinner spnManualZ "手动Z:   " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 287]
		label labelTrackX "TrackX: " align:#left width:50 pos:[10, 317]
		slider sliderTrackX "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left pos:[55, 307]
		spinner spnTrackX_Offset "TrackX 偏移:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 342]
		label labelTrackY "TrackY: " align:#left width:50 pos:[10, 367]
		slider sliderTrackY "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left pos:[55, 357]
		spinner spnTrackY_Offset "TrackY 偏移:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 392]
		label labelTrackZ "TrackZ: " align:#left width:50 pos:[10, 417]
		slider sliderTrackZ "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left pos:[55, 407]
		spinner spnTrackZ_Offset "TrackZ 偏移:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 442]
		button btnGetPelvisPosZ "获取质心Z位置" align:#center width:140 pos:[10, 467] tooltip:"自动获取质心距离地面的高度值并应用到TrackZ偏移中。"
		
		groupbox gpbRot "旋转控制" pos:[5, 512] width:150 height:100

		spinner spnManualYaw "手动 yaw:  " type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100 pos:[10, 532]
		label labelTrackYaw "Track yaw:  " align:#left width:60 pos:[10, 557]
		slider sliderTrackYaw "" type:#float range:[0.0, 1.0, 0.0] width:90 align:#left pos:[70, 547]
		spinner spnTrackYaw_Offset "Track yaw 偏移:   " type:#float range:[-99999.0, 99999.0, 90.0] align:#left width:118 pos:[10, 582] tooltip:"默认值 = 90"
		
		-- 添加快捷功能区域
		groupbox gpbQuickTools "快捷工具" pos:[5, 622] width:150 height:80
		
		button btnStraightenCurves "打直关键帧曲柄" width:95 height:25 pos:[10, 642] tooltip:"将临时根节点的位移和旋转曲线打直"
		button btnRestoreCurves "还原" width:40 height:25 pos:[110, 642] tooltip:"还原临时根节点的位移和旋转曲线"
		button btnSwitchTrajectory "Root轨迹" width:70 height:20 pos:[10, 672] tooltip:"显示隐藏选中物体的运动轨迹"
		button btnCurvePanel "曲线面板" width:65 height:20 pos:[85, 672] tooltip:"打开曲线面板,修改和删帧"

		-- 添加烘焙功能区域
		groupbox gpbBakeTools "烘焙工具" pos:[5, 710] width:150 height:85
		
		button btnBakeToTempKey "烘焙到临时根(关键帧)" width:140 height:25 pos:[10, 730] tooltip:"将动画烘焙到临时根节点(仅关键帧)"
		button btnBakeToTempFull "烘焙到临时根  (满帧)" width:140 height:25 pos:[10, 760] tooltip:"将动画烘焙到临时根节点  (所有帧)"

		fn Initialize = (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if (pelvisObj != undefined) then (
				labelPelvisObj.text = "质心: 【 " + pelvisObj.name + " 】"
			) else (
				labelPelvisObj.text = "质心: 【 未指定 】"
			)
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if (rootObj != undefined) then (
				labelRootObj.text = "临时根节点: 【 " + rootObj.name + " 】"
			) else (
				labelRootObj.text = "临时根节点: 【 未指定 】"
			)
			local originalRoot = maxOps.getNodeByHandle OriginalRootHandle
			if (originalRoot != undefined) then (
				labelOriginalRoot.text = "原根节点: 【 " + originalRoot.name + " 】"
			) else (
				labelOriginalRoot.text = "原根节点: 【 未指定 】"
			)
			
			-- 检查是否可以启用链接按钮
			btnLinkController.enabled = (pelvisObj != undefined and rootObj != undefined)
			
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
			labelPelvisObj.text = "质心: 【 " + obj.name + " 】"
			btnLinkController.enabled = (maxOps.getNodeByHandle RootObjHandle != undefined)
			-- 保存到自定义属性
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj != undefined do setUserProp controllerObj "BsRMPelvisObj" obj.name
		)

		on pickRootObj picked obj do (
			if obj == undefined do return()
			RootObjHandle = obj.inode.handle
			labelRootObj.text = "临时根节点: 【 " + obj.name + " 】"
			btnLinkController.enabled = (maxOps.getNodeByHandle PelvisObjHandle != undefined)
			-- 保存到自定义属性
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj != undefined do setUserProp controllerObj "BsRMRootObj" obj.name
		)
		
		on pickOriginalRoot picked obj do (
			if obj == undefined do return()
			OriginalRootHandle = obj.inode.handle
			labelOriginalRoot.text = "原根节点: 【 " + obj.name + " 】"
			-- 保存到自定义属性
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj != undefined do setUserProp controllerObj "BsRMOriginalRoot" obj.name
		)
		
		on btnLinkController pressed do (
			-- 检查对象是否已选择
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if pelvisObj == undefined do return()
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj == undefined do return()

			-- 设置位置控制器
			rootObj.pos.controller = Position_XYZ ()
			rootObj.pos.controller.X_Position.controller = Float_Expression ()
			rootObj.pos.controller.Y_Position.controller = Float_Expression ()
			rootObj.pos.controller.Z_Position.controller = Float_Expression ()
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "ManualX" ManualX.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "ManualY" ManualY.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "ManualZ" ManualZ.controller
			rootObj.pos.controller.X_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Y_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Z_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX" TrackX.controller
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX_Offset" TrackX_Offset.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY" TrackY.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY_Offset" TrackY_Offset.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ" TrackZ.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ_Offset" TrackZ_Offset.controller
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
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "ManualYaw" ManualYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw" TrackYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw_Offset" TrackYaw_Offset.controller
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
		fn OnButtonDown = (
			animStateBackup = animButtonState
			if isAnimPlaying() do (
				animButtonState = false
			)
		)

		fn OnButtonUp = (
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

		-- 添加新按钮的事件处理
		on btnStraightenCurves pressed do (
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj != undefined do (
				-- 打直位移曲线
				if rootObj.pos.controller != undefined do (
					
				)
				-- 打直旋转曲线
				if rootObj.rotation.controller != undefined do (
					
				)
			)
		)

		on btnRestoreCurves pressed do (
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj != undefined do (
				-- 还原位移曲线
				if rootObj.pos.controller != undefined do (
					
				)
				-- 还原旋转曲线
				if rootObj.rotation.controller != undefined do (
					
				)
			)
		)

		on btnSwitchTrajectory pressed do (
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj != undefined do (
				rootObj.showTrajectory = not rootObj.showTrajectory
			)
		)

		-- 占位按钮事件
		on btnBakeToTempKey pressed do ()
		on btnBakeToTempFull pressed do ()
	)

	-- 修改器的主要功能
	fn modify obj = (
		-- 这里可以添加修改器的实际功能
		-- 目前我们使用表达式控制器来处理，所以这里可以为空
	)

	-- 添加on create事件处理程序
	on create do (
		-- 初始化参数
		PelvisObjHandle = 0
		RootObjHandle = 0
		OriginalRootHandle = 0
		
		-- 从自定义属性中读取节点引用
		local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
		if controllerObj != undefined do (
			local pelvisName = getUserProp controllerObj "BsRMPelvisObj"
			local rootName = getUserProp controllerObj "BsRMRootObj"
			local originalRootName = getUserProp controllerObj "BsRMOriginalRoot"
			
			if pelvisName != undefined do (
				local pelvisObj = getNodeByName pelvisName
				if pelvisObj != undefined do PelvisObjHandle = pelvisObj.inode.handle
			)
			if rootName != undefined do (
				local rootObj = getNodeByName rootName
				if rootObj != undefined do RootObjHandle = rootObj.inode.handle
			)
			if originalRootName != undefined do (
				local originalRoot = getNodeByName originalRootName
				if originalRoot != undefined do OriginalRootHandle = originalRoot.inode.handle
			)
		)
	)
)

-- 创建UI
global rolRootMotionTools
try (destroydialog rolRootMotionTools) catch()

rollout rolRootMotionTools ("BsRootTools_v1.0") width:240
(
	button uiCreateController "创建根运动控制器" width:100 height:30 tooltip:"在场景中创建一个新的根运动控制器对象" across:2
	button uiOpenController "选中现有控制器" width:100 height:30 tooltip:"查找并打开场景中已有的根运动控制器"
	button btnApplyNewRoot "应用新 Root 动画并清理控制器" width:210 height:35 tooltip:"应用新的根节点动画并清理控制器"
	group "管理工具" (
		button uiAddRMAttribute "单独添加根运动修改器" width:200 tooltip:"给选中的对象添加根运动控制器修改器"
		button uiRemoveRMController "移除根运动控制器（包括物体）" width:200 tooltip:"仅移除选中对象的根运动控制器修改器，保留其他修改器"
	)
	hyperLink hlHomepage "🏠 原作者发布页" width:90 height:20 align:#center across:2 \
	address:"https://cafe.naver.com/pinksox/9011" color:(color 0 100 200) hovercolor:(color 0 150 255)
	hyperLink hlTutorial "📺 修改：Bullet.S" width:90 height:20 align:#center \
	address:"https://space.bilibili.com/2031113/lists/560782?type=season" color:(color 0 100 200) hovercolor:(color 0 150 255)

	-- 查找场景中的根运动控制器
	function FindRootMotionCtrl = (
		for obj in objects do (
			for i = 1 to obj.modifiers.count do (
				if classof obj.modifiers[i] == BsRootMotionModifier do (
					return obj
				)
			)
		)
		return undefined
	)

	-- 创建控制器对象
	function CreateControllerObject = (
		-- 保存当前选中的对象信息
		local selectedObj = selection[1]
		local selectedParent = if selectedObj != undefined then selectedObj.parent else undefined
		
		-- 创建一个文本对象作为控制器
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
		
		-- 创建根节点(使用Point对象)
		local rootNode = Point()
		rootNode.name = uniqueName "Root"
		rootNode.wirecolor = color 255 255 0  -- 黄色
		rootNode.size = 50
		rootNode.cross = true
		rootNode.box = true
		rootNode.centermarker = true
		rootNode.axistripod = true
		rootNode.centermarker = true
		rootNode.renderable = false
		
		-- 设置根节点的变换
		rootNode.transform = matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0]
		rootNode.rotation = eulerAngles 0 0 0
		
		-- 选中新创建的控制器
		select mainController
		
		-- 添加修改器
		addModifier mainController (BsRootMotionModifier())
		
		-- 设置修改器的根节点参数
		mainController.modifiers[#Bs_RootMotion_Ctrl].RootObjHandle = rootNode.inode.handle
		
		-- 设置质心和原根节点
		if selectedObj != undefined then (
			mainController.modifiers[#Bs_RootMotion_Ctrl].PelvisObjHandle = selectedObj.inode.handle
			if selectedParent != undefined then (
				mainController.modifiers[#Bs_RootMotion_Ctrl].OriginalRootHandle = selectedParent.inode.handle
			)
		)
		
		-- 保存到自定义属性
		if selectedObj != undefined do setUserProp mainController "BsRMPelvisObj" selectedObj.name
		setUserProp mainController "BsRMRootObj" rootNode.name
		if selectedParent != undefined do setUserProp mainController "BsRMOriginalRoot" selectedParent.name
		
		-- 自动打开修改面板显示修改器
		setCommandPanelTaskMode #modify
		
		-- 强制更新UI
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.labelPelvisObj.text = "质心: 【 " + (if selectedObj != undefined then selectedObj.name else "未指定") + " 】"
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.labelRootObj.text = "临时根节点: 【 " + rootNode.name + " 】"
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.labelOriginalRoot.text = "原根节点: 【 " + (if selectedParent != undefined then selectedParent.name else "未指定") + " 】"
		
		-- 更新链接按钮状态
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.btnLinkController.enabled = (selectedObj != undefined)
		
		return mainController
	)
	
	on uiCreateController pressed do (
		-- 检查是否已有控制器
		local existingController = FindRootMotionCtrl()
		if existingController != undefined then (
			local result = yesNoCancelBox ("场景中已存在根运动控制器: " + existingController.name + "\n\n是否要创建新的控制器？\n\n是=创建新的  否=打开现有的  取消=什么都不做")
			if result == #yes then (
				local confirmResult = yesNoCancelBox "请先选择质心对象，然后点击'是'继续创建控制器。\n\n是=继续创建  否=取消创建"
				if confirmResult == #yes then (
					if selection.count > 0 then (
						local newController = CreateControllerObject()
						completeredraw()
						messageBox "新的根运动控制器已创建！\n\n请在右侧修改器面板中找到 'Bs_RootMotion_Ctrl' 修改器。                            " title:"创建完成"
					) else (
						messageBox "请先选择一个对象作为质心！" title:"错误"
					)
				)
			) else if result == #no then (
				select existingController
				setCommandPanelTaskMode #modify
			)
		) else (
			local confirmResult = yesNoCancelBox "请先选择质心对象，然后点击'是'继续创建控制器。\n\n是=继续创建  否=取消创建"
			if confirmResult == #yes then (
				if selection.count > 0 then (
					local newController = CreateControllerObject()
					completeredraw()
					messageBox "根运动控制器已创建成功！\n\n\n请在右侧修改器面板中找到 'Bs_RootMotion_Ctrl' 修改器，\n\n设置质心和根节点对象。                                                                         " title:"创建完成"
				) else (
					messageBox "请先选择一个对象作为质心！" title:"错误"
				)
			)
		)
	)

	on uiOpenController pressed do (
		local controllerObj = FindRootMotionCtrl()
		if controllerObj != undefined then (
			select controllerObj
			setCommandPanelTaskMode #modify
		) else (
			messageBox "场景中没有找到根运动控制器。\n请先点击'创建根运动控制器'。" title:"未找到"
		)
	)

	on uiAddRMAttribute pressed do (
		if selection.count == 0 do (
			messageBox "请先选择一个要添加根运动控制器修改器的对象"
			return()
		)
		
		local obj = selection[1]
		local hasModifier = false
		for i = 1 to obj.modifiers.count do (
			if classof obj.modifiers[i] == BsRootMotionModifier do (
				hasModifier = true
				exit
			)
		)
		
		if hasModifier then (
			messageBox ("对象 " + obj.name + " 已经有根运动控制器修改器了！")
		) else (
			-- 添加修改器
			addModifier obj (BsRootMotionModifier())
			setCommandPanelTaskMode #modify
			messageBox ("成功给对象 " + obj.name + " 添加根运动控制器修改器！") title:"添加完成"
		)
	)

	on uiRemoveRMController pressed do (
		local controllerObj = FindRootMotionCtrl()
		if controllerObj != undefined then (
			-- 获取根节点
			local rootObj = maxOps.getNodeByHandle controllerObj.modifiers[#Bs_RootMotion_Ctrl].RootObjHandle
			if rootObj != undefined do delete rootObj
			delete controllerObj
		) else (
			messageBox "场景中没有找到根运动控制器。\n请先点击'创建根运动控制器'。" title:"未找到"
		)
	)
)

createDialog rolRootMotionTools style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) lockWidth:true