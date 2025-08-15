--制作者：李相元
--修改: Bullet.S

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
		
		button btnAddLink "添加控制" width:68 height:30 pos:[10, 165] tooltip:"将控制器应用到根节点并与质心连接。" enabled:false
		button btnRemoveLink "移除控制" width:68 height:30 pos:[82, 165] tooltip:"移除控制器链接，恢复为普通动画。" enabled:false
		
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
		
		button btnBakeToTempKey "记录到临时根(关键帧)" width:140 height:25 pos:[10, 730] tooltip:"将动画记录到临时根节点(仅关键帧)"
		button btnBakeToTempFull "记录到临时根  (满帧)" width:140 height:25 pos:[10, 760] tooltip:"将动画记录到临时根节点  (所有帧)"

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
			local canLink = (pelvisObj != undefined and rootObj != undefined)
			btnAddLink.enabled = canLink
			-- 检查是否已经链接，如果已链接则启用移除按钮
			local isLinked = false
			if rootObj != undefined then (
				try (
					isLinked = (classof rootObj.pos.controller == Position_XYZ and 
					           classof rootObj.pos.controller.X_Position.controller == Float_Expression)
				) catch ()
			)
			btnRemoveLink.enabled = isLinked
			
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
			local canLink = (maxOps.getNodeByHandle RootObjHandle != undefined)
			btnAddLink.enabled = canLink
			-- 更新移除按钮状态
			local isLinked = false
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj != undefined then (
				try (
					isLinked = (classof rootObj.pos.controller == Position_XYZ and 
					           classof rootObj.pos.controller.X_Position.controller == Float_Expression)
				) catch ()
			)
			btnRemoveLink.enabled = isLinked
			-- 保存到自定义属性
			try (
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj != undefined do setUserProp controllerObj "BsRMPelvisObj" obj.name
			) catch ()
		)

		on pickRootObj picked obj do (
			if obj == undefined do return()
			RootObjHandle = obj.inode.handle
			labelRootObj.text = "临时根节点: 【 " + obj.name + " 】"
			local canLink = (maxOps.getNodeByHandle PelvisObjHandle != undefined)
			btnAddLink.enabled = canLink
			-- 更新移除按钮状态
			local isLinked = false
			local rootObj = maxOps.getNodeByHandle RootObjHandle  
			if rootObj != undefined then (
				try (
					isLinked = (classof rootObj.pos.controller == Position_XYZ and 
					           classof rootObj.pos.controller.X_Position.controller == Float_Expression)
				) catch ()
			)
			btnRemoveLink.enabled = isLinked
			-- 保存到自定义属性
			try (
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj != undefined do setUserProp controllerObj "BsRMRootObj" obj.name
			) catch ()
		)
		
		on pickOriginalRoot picked obj do (
			if obj == undefined do return()
			OriginalRootHandle = obj.inode.handle
			labelOriginalRoot.text = "原根节点: 【 " + obj.name + " 】"
			-- 保存到自定义属性
			try (
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj != undefined do setUserProp controllerObj "BsRMOriginalRoot" obj.name
			) catch ()
		)
		
		on btnAddLink pressed do (
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
			
			-- 更新按钮状态
			btnAddLink.enabled = false
			btnRemoveLink.enabled = true
			messageBox "链接控制器已添加！\n\n临时根节点现在受到质心和修改器参数的控制。" title:"链接完成"
		)
		
		on btnRemoveLink pressed do (
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj == undefined do return()
			
			local result = yesNoCancelBox "确定要移除链接控制吗？\n\n这将：\n- 移除表达式控制器\n- 恢复为普通的Position/Rotation控制器\n- 保留当前的动画数据" title:"确认移除链接"
			if result != #yes then return()
			
			try (
				-- 移除位置控制器链接
				rootObj.pos.controller = Position_XYZ()
				-- 移除旋转控制器链接  
				rootObj.rotation.controller = Euler_XYZ()
				
				-- 更新按钮状态
				btnAddLink.enabled = true
				btnRemoveLink.enabled = false
				messageBox "链接控制器已移除！\n\n临时根节点恢复为普通的动画控制器。" title:"移除完成"
			) catch (
				messageBox ("移除链接控制时出错: " + getCurrentException()) title:"移除错误"
			)
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
					try (
						-- 为位移控制器的所有关键帧设置平直切线
						rootObj.pos.controller.keys.setTangentType #flat
					) catch (
						-- 如果是复合控制器，分别处理X、Y、Z轴
						try (
							if rootObj.pos.controller.X_Position != undefined and rootObj.pos.controller.X_Position.keys != undefined do
								rootObj.pos.controller.X_Position.keys.setTangentType #flat
							if rootObj.pos.controller.Y_Position != undefined and rootObj.pos.controller.Y_Position.keys != undefined do
								rootObj.pos.controller.Y_Position.keys.setTangentType #flat
							if rootObj.pos.controller.Z_Position != undefined and rootObj.pos.controller.Z_Position.keys != undefined do
								rootObj.pos.controller.Z_Position.keys.setTangentType #flat
						) catch ()
					)
				)
				-- 打直旋转曲线
				if rootObj.rotation.controller != undefined do (
					try (
						-- 为旋转控制器的所有关键帧设置平直切线
						rootObj.rotation.controller.keys.setTangentType #flat
					) catch (
						-- 如果是欧拉控制器，分别处理X、Y、Z轴
						try (
							if rootObj.rotation.controller.X_Rotation != undefined and rootObj.rotation.controller.X_Rotation.keys != undefined do
								rootObj.rotation.controller.X_Rotation.keys.setTangentType #flat
							if rootObj.rotation.controller.Y_Rotation != undefined and rootObj.rotation.controller.Y_Rotation.keys != undefined do
								rootObj.rotation.controller.Y_Rotation.keys.setTangentType #flat
							if rootObj.rotation.controller.Z_Rotation != undefined and rootObj.rotation.controller.Z_Rotation.keys != undefined do
								rootObj.rotation.controller.Z_Rotation.keys.setTangentType #flat
						) catch ()
					)
				)
				
				-- 打直修改器参数的关键帧曲线
				try (
					if ManualX.controller != undefined and ManualX.controller.keys != undefined do
						ManualX.controller.keys.setTangentType #flat
					if ManualY.controller != undefined and ManualY.controller.keys != undefined do
						ManualY.controller.keys.setTangentType #flat
					if ManualZ.controller != undefined and ManualZ.controller.keys != undefined do
						ManualZ.controller.keys.setTangentType #flat
					if TrackX.controller != undefined and TrackX.controller.keys != undefined do
						TrackX.controller.keys.setTangentType #flat
					if TrackX_Offset.controller != undefined and TrackX_Offset.controller.keys != undefined do
						TrackX_Offset.controller.keys.setTangentType #flat
					if TrackY.controller != undefined and TrackY.controller.keys != undefined do
						TrackY.controller.keys.setTangentType #flat
					if TrackY_Offset.controller != undefined and TrackY_Offset.controller.keys != undefined do
						TrackY_Offset.controller.keys.setTangentType #flat
					if TrackZ.controller != undefined and TrackZ.controller.keys != undefined do
						TrackZ.controller.keys.setTangentType #flat
					if TrackZ_Offset.controller != undefined and TrackZ_Offset.controller.keys != undefined do
						TrackZ_Offset.controller.keys.setTangentType #flat
					if ManualYaw.controller != undefined and ManualYaw.controller.keys != undefined do
						ManualYaw.controller.keys.setTangentType #flat
					if TrackYaw.controller != undefined and TrackYaw.controller.keys != undefined do
						TrackYaw.controller.keys.setTangentType #flat
					if TrackYaw_Offset.controller != undefined and TrackYaw_Offset.controller.keys != undefined do
						TrackYaw_Offset.controller.keys.setTangentType #flat
				) catch ()
				
				messageBox "已将临时根节点和修改器参数的关键帧曲线设置为平直！" title:"打直曲线完成"
			)
		)

		on btnRestoreCurves pressed do (
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj != undefined do (
				-- 还原位移曲线
				if rootObj.pos.controller != undefined do (
					try (
						-- 为位移控制器的所有关键帧设置平滑切线
						rootObj.pos.controller.keys.setTangentType #smooth
					) catch (
						-- 如果是复合控制器，分别处理X、Y、Z轴
						try (
							if rootObj.pos.controller.X_Position != undefined and rootObj.pos.controller.X_Position.keys != undefined do
								rootObj.pos.controller.X_Position.keys.setTangentType #smooth
							if rootObj.pos.controller.Y_Position != undefined and rootObj.pos.controller.Y_Position.keys != undefined do
								rootObj.pos.controller.Y_Position.keys.setTangentType #smooth
							if rootObj.pos.controller.Z_Position != undefined and rootObj.pos.controller.Z_Position.keys != undefined do
								rootObj.pos.controller.Z_Position.keys.setTangentType #smooth
						) catch ()
					)
				)
				-- 还原旋转曲线
				if rootObj.rotation.controller != undefined do (
					try (
						-- 为旋转控制器的所有关键帧设置平滑切线
						rootObj.rotation.controller.keys.setTangentType #smooth
					) catch (
						-- 如果是欧拉控制器，分别处理X、Y、Z轴
						try (
							if rootObj.rotation.controller.X_Rotation != undefined and rootObj.rotation.controller.X_Rotation.keys != undefined do
								rootObj.rotation.controller.X_Rotation.keys.setTangentType #smooth
							if rootObj.rotation.controller.Y_Rotation != undefined and rootObj.rotation.controller.Y_Rotation.keys != undefined do
								rootObj.rotation.controller.Y_Rotation.keys.setTangentType #smooth
							if rootObj.rotation.controller.Z_Rotation != undefined and rootObj.rotation.controller.Z_Rotation.keys != undefined do
								rootObj.rotation.controller.Z_Rotation.keys.setTangentType #smooth
						) catch ()
					)
				)
				
				-- 还原修改器参数的关键帧曲线
				try (
					if ManualX.controller != undefined and ManualX.controller.keys != undefined do
						ManualX.controller.keys.setTangentType #smooth
					if ManualY.controller != undefined and ManualY.controller.keys != undefined do
						ManualY.controller.keys.setTangentType #smooth
					if ManualZ.controller != undefined and ManualZ.controller.keys != undefined do
						ManualZ.controller.keys.setTangentType #smooth
					if TrackX.controller != undefined and TrackX.controller.keys != undefined do
						TrackX.controller.keys.setTangentType #smooth
					if TrackX_Offset.controller != undefined and TrackX_Offset.controller.keys != undefined do
						TrackX_Offset.controller.keys.setTangentType #smooth
					if TrackY.controller != undefined and TrackY.controller.keys != undefined do
						TrackY.controller.keys.setTangentType #smooth
					if TrackY_Offset.controller != undefined and TrackY_Offset.controller.keys != undefined do
						TrackY_Offset.controller.keys.setTangentType #smooth
					if TrackZ.controller != undefined and TrackZ.controller.keys != undefined do
						TrackZ.controller.keys.setTangentType #smooth
					if TrackZ_Offset.controller != undefined and TrackZ_Offset.controller.keys != undefined do
						TrackZ_Offset.controller.keys.setTangentType #smooth
					if ManualYaw.controller != undefined and ManualYaw.controller.keys != undefined do
						ManualYaw.controller.keys.setTangentType #smooth
					if TrackYaw.controller != undefined and TrackYaw.controller.keys != undefined do
						TrackYaw.controller.keys.setTangentType #smooth
					if TrackYaw_Offset.controller != undefined and TrackYaw_Offset.controller.keys != undefined do
						TrackYaw_Offset.controller.keys.setTangentType #smooth
				) catch ()
				
				messageBox "已将临时根节点和修改器参数的关键帧曲线还原为平滑！" title:"还原曲线完成"
			)
		)

		on btnSwitchTrajectory pressed do (
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj != undefined do (
				rootObj.showTrajectory = not rootObj.showTrajectory
			)
		)

		on btnCurvePanel pressed do (
			-- 使用macros.run打开曲线面板
			try (
				macros.run "Track View" "LaunchFCurveEditor"
			) catch (
				-- 如果macros方法失败，尝试其他方法
				try (
					if trackViews.isOpen #curve_editor then (
						trackViews.close #curve_editor
					) else (
						trackViews.open #curve_editor
					)
				) catch (
					messageBox "无法打开曲线编辑器" title:"错误"
				)
			)
		)

				-- 基于BulletKeyTools的获取关键帧方法（重构为非嵌套函数）
		fn fnGetObjectKeys obj = (
			local arrKeysTime = #()
			
			-- 递归获取所有子动画的关键帧（使用循环栈代替递归避免嵌套问题）
			fn collectAllSubKeys tempObj arrRef = (
				local stack = #(tempObj)
				
				while stack.count > 0 do (
					local currentObj = stack[stack.count]
					deleteItem stack stack.count
					
					for i = 1 to currentObj.numSubs do (
						local tempSubAnim = GetSubAnim currentObj i
						local tempController = tempSubAnim.Controller
						
						if tempController != undefined do (
							for j in tempController.Keys do (
								appendIfUnique arrRef j.time
							)
						)
						
						-- 如果有子动画，添加到栈中继续处理
						if tempSubAnim.numSubs > 0 do (
							append stack tempSubAnim
						)
					)
				)
			)
			
			-- 处理Biped对象
			if (classof obj == Biped_Object) then (
				if classof obj.controller != Footsteps then (
					if classof obj.controller != Vertical_Horizontal_Turn then (
						-- 筛选出非质心的biped帧
						collectAllSubKeys obj arrKeysTime
					) else (
						-- 处理质心(Bip001)的关键帧，中英文版本兼容
						if classof obj.controller == Vertical_Horizontal_Turn then (
							local bipCtrl = obj.controller
							local vertCtrl = bipCtrl.vertical.controller
							local horzCtrl = bipCtrl.horizontal.controller
							local turnCtrl = undefined
							
							-- 处理中英文版本差异
							try (
								if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then (
									turnCtrl = bipCtrl.flip.controller
								) else (
									turnCtrl = bipCtrl.turning.controller
								)
							) catch (
								-- 如果上面的方法失败，尝试直接访问
								try (
									turnCtrl = bipCtrl.turning.controller
								) catch (
									try (
										turnCtrl = bipCtrl.flip.controller
									) catch ()
								)
							)
							
							local bipCtrlTemp = #(vertCtrl, horzCtrl)
							if turnCtrl != undefined do append bipCtrlTemp turnCtrl
							
							for c in bipCtrlTemp do (
								if c != undefined and c.keys != undefined and c.keys.count > 0 then (
									for i in c.keys do (
										appendIfUnique arrKeysTime i.time
									)
								)
							)
						)
					)
				)
			) else (
				-- 非Biped对象直接收集所有子动画关键帧
				collectAllSubKeys obj arrKeysTime
			)
			
			return arrKeysTime
		)

		-- 烘焙功能
		on btnBakeToTempKey pressed do (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			
			if pelvisObj == undefined then (
				messageBox "请先选择质心对象！" title:"错误"
				return()
			)
			if rootObj == undefined then (
				messageBox "请先选择临时根节点！" title:"错误" 
				return()
			)
			
			-- 使用优化的获取关键帧方法
			local keyTimes = fnGetObjectKeys pelvisObj
			
			-- 去除重复时间并排序
			if keyTimes.count > 0 then (
				keyTimes = makeUniqueArray keyTimes
				sort keyTimes
			) else (
				local objTypeStr = if (classof pelvisObj == Biped_Object) then "Biped" else "普通"
				messageBox ("质心对象: " + pelvisObj.name + " (" + objTypeStr + "对象) 没有找到关键帧！\n请确认该对象有动画关键帧。") title:"警告"
				return()
			)
			
			-- 在这些时间点为修改器参数设置关键帧
			local successCount = 0
			-- 保存原始动画状态
			local originalAnimState = animButtonState
			
			-- 获取修改器对象
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj == undefined then (
				messageBox "找不到根运动控制器！" title:"错误"
				return()
			)
			
			local modifier = controllerObj.modifiers[#Bs_RootMotion_Ctrl]
			if modifier == undefined then (
				messageBox "找不到根运动修改器！" title:"错误"
				return()
			)
			
			try (
				animButtonState = true
				for t in keyTimes do (
					at time t (
						try (
							-- 为修改器参数设置关键帧，保持约束系统不变
							with animate on (
								-- 强制为所有参数设置关键帧，确保滑条值和偏移值被正确记录
								modifier.ManualX = modifier.ManualX
								modifier.ManualY = modifier.ManualY
								modifier.ManualZ = modifier.ManualZ
								modifier.TrackX = modifier.TrackX
								modifier.TrackX_Offset = modifier.TrackX_Offset
								modifier.TrackY = modifier.TrackY
								modifier.TrackY_Offset = modifier.TrackY_Offset
								modifier.TrackZ = modifier.TrackZ
								modifier.TrackZ_Offset = modifier.TrackZ_Offset
								modifier.ManualYaw = modifier.ManualYaw
								modifier.TrackYaw = modifier.TrackYaw
								modifier.TrackYaw_Offset = modifier.TrackYaw_Offset
							)
							successCount += 1
						) catch ()
					)
				)
			) catch () (
				-- 恢复原始动画状态
				animButtonState = originalAnimState
			)
			
			local objTypeStr = if (classof pelvisObj == Biped_Object) then "Biped" else "普通"
			messageBox ("质心(" + objTypeStr + "对象)找到 " + keyTimes.count as string + " 个关键帧\n已为临时根节点成功设置 " + successCount as string + " 个关键帧！") title:"烘焙完成"
		)

		on btnBakeToTempFull pressed do (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			
			if pelvisObj == undefined then (
				messageBox "请先选择质心对象！" title:"错误"
				return()
			)
			if rootObj == undefined then (
				messageBox "请先选择临时根节点！" title:"错误"
				return()
			)
			
			-- 获取动画范围（正确计算帧数）
			local startTick = animationRange.start
			local endTick = animationRange.end
			local startFrame = (startTick / ticksPerFrame) as integer
			local endFrame = (endTick / ticksPerFrame) as integer
			local frameCount = endFrame - startFrame + 1
			
			-- 确认操作
			local result = yesNoCancelBox ("将在第 " + startFrame as string + " 帧到第 " + endFrame as string + " 帧\n共 " + frameCount as string + " 帧设置关键帧\n\n注意：这将为每一帧都设置关键帧！\n确定要继续吗？") title:"确认满帧烘焙"
			if result != #yes then return()
			
			-- 为每一帧的修改器参数设置关键帧
			local successCount = 0
			local progressStep = frameCount / 10  -- 用于显示进度
			local nextProgress = progressStep
			
			-- 获取修改器对象
			local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
			if controllerObj == undefined then (
				messageBox "找不到根运动控制器！" title:"错误"
				return()
			)
			
			local modifier = controllerObj.modifiers[#Bs_RootMotion_Ctrl]
			if modifier == undefined then (
				messageBox "找不到根运动修改器！" title:"错误"
				return()
			)
			
			-- 保存原始动画状态
			local originalAnimState = animButtonState
			try (
				animButtonState = true
				for f = startFrame to endFrame do (
					at time (f * ticksPerFrame) (
						try (
							-- 为修改器参数设置关键帧，保持约束系统不变
							with animate on (
								-- 强制为所有参数设置关键帧，确保滑条值和偏移值被正确记录
								modifier.ManualX = modifier.ManualX
								modifier.ManualY = modifier.ManualY
								modifier.ManualZ = modifier.ManualZ
								modifier.TrackX = modifier.TrackX
								modifier.TrackX_Offset = modifier.TrackX_Offset
								modifier.TrackY = modifier.TrackY
								modifier.TrackY_Offset = modifier.TrackY_Offset
								modifier.TrackZ = modifier.TrackZ
								modifier.TrackZ_Offset = modifier.TrackZ_Offset
								modifier.ManualYaw = modifier.ManualYaw
								modifier.TrackYaw = modifier.TrackYaw
								modifier.TrackYaw_Offset = modifier.TrackYaw_Offset
							)
							successCount += 1
							
							-- 显示进度（每10%显示一次）
							if (successCount >= nextProgress) then (
								local percent = (successCount as float / frameCount * 100) as integer
								nextProgress += progressStep
							)
						) catch ()
					)
				)
			) catch () (
				-- 恢复原始动画状态
				animButtonState = originalAnimState
			)
			
			messageBox ("已为临时根节点在第 " + startFrame as string + " 到 " + endFrame as string + " 帧\n共成功设置 " + successCount as string + " 个关键帧！\n(总计 " + frameCount as string + " 帧)") title:"满帧烘焙完成"
		)
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
		try (
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
		) catch ()
	)
)


-- 创建.NET Windows Forms UI
global bsRootMotionForm

-- 检测Max主题并返回适合的颜色
function GetThemeColor colorType = (
	-- 获取系统背景色来判断主题类型
	local bgColor = colorman.getColor #background
	-- bgColor是Point3类型，范围0-1，需要转换为0-255
	local brightness = (bgColor.x + bgColor.y + bgColor.z) / 3.0 * 255
	local isDarkTheme = brightness < 128
	
	case colorType of (
		#green: if isDarkTheme then (dotNetClass "System.Drawing.Color").FromArgb 80 120 80 else (dotNetClass "System.Drawing.Color").FromArgb 180 220 180
		#blue: if isDarkTheme then (dotNetClass "System.Drawing.Color").FromArgb 80 80 120 else (dotNetClass "System.Drawing.Color").FromArgb 180 180 220
		#orange: if isDarkTheme then (dotNetClass "System.Drawing.Color").FromArgb 120 90 60 else (dotNetClass "System.Drawing.Color").FromArgb 220 180 140
		#purple: if isDarkTheme then (dotNetClass "System.Drawing.Color").FromArgb 100 80 100 else (dotNetClass "System.Drawing.Color").FromArgb 200 160 200
		#red: if isDarkTheme then (dotNetClass "System.Drawing.Color").FromArgb 120 80 80 else (dotNetClass "System.Drawing.Color").FromArgb 220 160 160
		#link: if isDarkTheme then (dotNetClass "System.Drawing.Color").FromArgb 100 150 255 else (dotNetClass "System.Drawing.Color").FromArgb 0 100 200
		default: if isDarkTheme then (dotNetClass "System.Drawing.Color").FromArgb 100 100 100 else (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
	)
)

-- 全局变量
global bsHelpForm = undefined

-- 全局函数和工具结构体
struct rolRootMotionTools (
	-- 检查修改器是否可用
	fn CheckModifierAvailable = (
		try (
			local modClass = BsRootMotionModifier
			return (modClass != undefined)
		) catch (
			messageBox "根运动修改器未正确加载！\n\n请确保脚本文件完整且没有语法错误。" title:"修改器错误" beep:true
			return false
		)
	),

	-- 查找场景中的根运动控制器
	fn FindRootMotionCtrl = (
		try (
		for obj in objects do (
			for i = 1 to obj.modifiers.count do (
				if classof obj.modifiers[i] == BsRootMotionModifier do (
					return obj
				)
			)
		)
		return undefined
		) catch (
		return undefined
	)
	),

	-- 创建控制器对象（原始功能）
	fn CreateControllerObject = (
		-- 保存当前选中的对象信息
		local selectedObj = if selection.count > 0 then selection[1] else undefined
		local selectedParent = if selectedObj != undefined then selectedObj.parent else undefined
		
		-- 检查是否已经有控制器
		local existingController = this.FindRootMotionCtrl()
		if existingController != undefined then (
			local result = yesNoCancelBox ("场景中已存在根运动控制器: " + existingController.name + "\n\n是否要创建新的控制器？\n\n是=创建新的  否=打开现有的  取消=什么都不做")
			if result == #yes then (
				-- 继续创建新的
			) else if result == #no then (
				select existingController
				setCommandPanelTaskMode #modify
				return true
			) else (
				return false
			)
		)
		
		-- 创建一个文本对象作为主控制器
		local mainController = Text()
		mainController.text = "RootCtrl"
		mainController.size = 12
		mainController.wirecolor = color 255 255 0  -- 黄色
		mainController.renderable = false
		
		-- 设置控制器属性
		mainController.name = uniqueName "RootMotionCtrl"
		
		-- 将控制器放置在膝盖侧边位置
		mainController.pos = [-60, 30, 0]  -- X轴正方向60单位（侧边），Z轴50单位（膝盖高度）
		
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
		
		-- 强制更新UI（尝试访问修改器rollout）
		try (
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.labelPelvisObj.text = "质心: 【 " + (if selectedObj != undefined then selectedObj.name else "未指定") + " 】"
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.labelRootObj.text = "临时根节点: 【 " + rootNode.name + " 】"
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.labelOriginalRoot.text = "原根节点: 【 " + (if selectedParent != undefined then selectedParent.name else "未指定") + " 】"
		
		-- 更新链接按钮状态
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.btnAddLink.enabled = (selectedObj != undefined)
		mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.btnRemoveLink.enabled = false
		) catch ()
		
		-- 自动建立链接（如果有质心对象）
		if selectedObj != undefined then (
			try (
				local modifier = mainController.modifiers[#Bs_RootMotion_Ctrl]
				
				-- 设置位置控制器
				rootNode.pos.controller = Position_XYZ ()
				rootNode.pos.controller.X_Position.controller = Float_Expression ()
				rootNode.pos.controller.Y_Position.controller = Float_Expression ()
				rootNode.pos.controller.Z_Position.controller = Float_Expression ()
				rootNode.pos.controller.X_Position.controller.AddScalarTarget "ManualX" modifier.ManualX.controller
				rootNode.pos.controller.Y_Position.controller.AddScalarTarget "ManualY" modifier.ManualY.controller
				rootNode.pos.controller.Z_Position.controller.AddScalarTarget "ManualZ" modifier.ManualZ.controller
				rootNode.pos.controller.X_Position.controller.AddVectorNode "PelvisPos" selectedObj
				rootNode.pos.controller.Y_Position.controller.AddVectorNode "PelvisPos" selectedObj
				rootNode.pos.controller.Z_Position.controller.AddVectorNode "PelvisPos" selectedObj
				rootNode.pos.controller.X_Position.controller.AddScalarTarget "TrackX" modifier.TrackX.controller
				rootNode.pos.controller.X_Position.controller.AddScalarTarget "TrackX_Offset" modifier.TrackX_Offset.controller
				rootNode.pos.controller.Y_Position.controller.AddScalarTarget "TrackY" modifier.TrackY.controller
				rootNode.pos.controller.Y_Position.controller.AddScalarTarget "TrackY_Offset" modifier.TrackY_Offset.controller
				rootNode.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ" modifier.TrackZ.controller
				rootNode.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ_Offset" modifier.TrackZ_Offset.controller
				rootNode.pos.controller.X_Position.controller.SetExpression "(TrackX_Offset + PelvisPos.x)*TrackX + ManualX*(1-TrackX)"
				rootNode.pos.controller.Y_Position.controller.SetExpression "(TrackY_Offset + PelvisPos.y)*TrackY + ManualY*(1-TrackY)"
				rootNode.pos.controller.Z_Position.controller.SetExpression "(TrackZ_Offset + PelvisPos.z)*TrackZ + ManualZ*(1-TrackZ)"
				
				-- 设置旋转控制器
				rootNode.rotation.controller = Euler_XYZ ()
				rootNode.rotation.controller.X_Rotation.controller = Float_Expression ()
				rootNode.rotation.controller.X_Rotation.controller.SetExpression "0"
				rootNode.rotation.controller.Y_Rotation.controller = Float_Expression ()
				rootNode.rotation.controller.Y_Rotation.controller.SetExpression "0"
				rootNode.rotation.controller.Z_Rotation.controller = float_script ()
				rootNode.rotation.controller.Z_Rotation.controller.AddTarget "ManualYaw" modifier.ManualYaw.controller
				rootNode.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw" modifier.TrackYaw.controller
				rootNode.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw_Offset" modifier.TrackYaw_Offset.controller
				rootNode.rotation.controller.Z_Rotation.controller.AddNode "PelvisObj" selectedObj
				rootNode.rotation.controller.Z_Rotation.controller.SetExpression ("local pelvisYaw = degToRad (PelvisObj.transform.rotation as EulerAngles).z\n" + 
					"local track = (pelvisYaw + degToRad (TrackYaw_Offset)) * TrackYaw\n" + 
					"local manual = degToRad(ManualYaw) * (1-TrackYaw)\n" + 
					"return (track + manual)")
				
				-- 更新按钮状态
				try (
					mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.btnAddLink.enabled = false
					mainController.modifiers[#Bs_RootMotion_Ctrl].BsRMRollout.btnRemoveLink.enabled = true
				) catch ()
				
			) catch (
				-- 如果自动链接失败，不影响控制器创建
			)
		)
		
		return true
	)
)

-- 创建全局实例
global rolRootMotionTools = rolRootMotionTools()

-- 为向后兼容保留的全局函数
function CheckModifierAvailable = rolRootMotionTools.CheckModifierAvailable()
function FindRootMotionCtrl = rolRootMotionTools.FindRootMotionCtrl()

try (bsRootMotionForm.close()) catch()
try (if bsHelpForm != undefined then bsHelpForm.close()) catch()

-- 创建.NET窗体
bsRootMotionForm = dotNetObject "MaxCustomControls.MaxForm"
bsRootMotionForm.Text = "BsRootTools v1.1"
bsRootMotionForm.Size = dotNetObject "System.Drawing.Size" 330 290
bsRootMotionForm.MinimizeBox = true
bsRootMotionForm.MaximizeBox = false
bsRootMotionForm.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").FixedSingle
bsRootMotionForm.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").Manual
bsRootMotionForm.ShowIcon = false  -- 隐藏左上角图标
bsRootMotionForm.TopMost = false

-- 设置窗口位置在Max窗口附近
try (
	local maxRect = windows.getMAXWindowRect()
	bsRootMotionForm.Location = dotNetObject "System.Drawing.Point" (maxRect.x + 300) (maxRect.y + 100)
) catch (
	-- 如果获取Max窗口位置失败，使用默认位置
	bsRootMotionForm.Location = dotNetObject "System.Drawing.Point" 400 200
)

-- 设置Max窗口句柄包装器
global theMaxPtr = dotNetObject "System.IntPtr" (windows.getMAXHWND())
global theMaxHwnd
try (
	theMaxHwnd = dotNetObject "MaxCustomControls.Win32HandleWrapper" theMaxPtr
) catch ()
bsRootMotionForm.ShowInTaskbar = false  -- 不在任务栏显示

-- 创建按钮
global btnCreateController = dotNetObject "System.Windows.Forms.Button"
btnCreateController.Text = "创建根运动控制器"
btnCreateController.Size = dotNetObject "System.Drawing.Size" 140 30
btnCreateController.Location = dotNetObject "System.Drawing.Point" 10 10
btnCreateController.BackColor = GetThemeColor #green
btnCreateController.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
btnCreateController.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0

global btnOpenController = dotNetObject "System.Windows.Forms.Button"
btnOpenController.Text = "选中现有控制器"
btnOpenController.Size = dotNetObject "System.Drawing.Size" 140 30
btnOpenController.Location = dotNetObject "System.Drawing.Point" 160 10
btnOpenController.BackColor = GetThemeColor #blue
btnOpenController.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat

global btnApplyNewRoot = dotNetObject "System.Windows.Forms.Button"
btnApplyNewRoot.Text = "应用新 Root 动画并清理控制器"
btnApplyNewRoot.Size = dotNetObject "System.Drawing.Size" 290 35
btnApplyNewRoot.Location = dotNetObject "System.Drawing.Point" 10 50
btnApplyNewRoot.BackColor = GetThemeColor #orange
btnApplyNewRoot.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat

-- 管理工具组
global grpManagement = dotNetObject "System.Windows.Forms.GroupBox"
grpManagement.Text = "管理工具"
grpManagement.Size = dotNetObject "System.Drawing.Size" 290 80
grpManagement.Location = dotNetObject "System.Drawing.Point" 10 95

global btnAddModifier = dotNetObject "System.Windows.Forms.Button"
btnAddModifier.Text = "单独添加根运动修改器"
btnAddModifier.Size = dotNetObject "System.Drawing.Size" 270 25
btnAddModifier.Location = dotNetObject "System.Drawing.Point" 10 20
btnAddModifier.BackColor = GetThemeColor #purple
btnAddModifier.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat

global btnRemoveController = dotNetObject "System.Windows.Forms.Button"
btnRemoveController.Text = "移除根运动控制器（包括物体）"
btnRemoveController.Size = dotNetObject "System.Drawing.Size" 270 25
btnRemoveController.Location = dotNetObject "System.Drawing.Point" 10 50
btnRemoveController.BackColor = GetThemeColor #red
btnRemoveController.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat

-- 添加控件到组
grpManagement.Controls.Add btnAddModifier
grpManagement.Controls.Add btnRemoveController

-- 超链接
global linkHomepage = dotNetObject "System.Windows.Forms.LinkLabel"
linkHomepage.Text = "■ 原作者发布页"  -- 使用方块符号替代emoji
linkHomepage.Size = dotNetObject "System.Drawing.Size" 140 20
linkHomepage.Location = dotNetObject "System.Drawing.Point" 10 220
linkHomepage.LinkColor = GetThemeColor #link
linkHomepage.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0

global linkTutorial = dotNetObject "System.Windows.Forms.LinkLabel"
linkTutorial.Text = "▶ 重构：Bullet.S"  -- 使用三角符号替代emoji
linkTutorial.Size = dotNetObject "System.Drawing.Size" 140 20
linkTutorial.Location = dotNetObject "System.Drawing.Point" 200 220
linkTutorial.LinkColor = GetThemeColor #link
linkTutorial.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0

-- 帮助按钮
global btnHelp = dotNetObject "System.Windows.Forms.Button"
btnHelp.Text = "❓ 使用帮助"
btnHelp.Size = dotNetObject "System.Drawing.Size" 290 25
btnHelp.Location = dotNetObject "System.Drawing.Point" 10 185
btnHelp.BackColor = GetThemeColor #purple
btnHelp.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
btnHelp.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0

-- 添加控件到窗体
bsRootMotionForm.Controls.Add btnCreateController
bsRootMotionForm.Controls.Add btnOpenController
bsRootMotionForm.Controls.Add btnApplyNewRoot
bsRootMotionForm.Controls.Add grpManagement
bsRootMotionForm.Controls.Add linkHomepage
bsRootMotionForm.Controls.Add linkTutorial
bsRootMotionForm.Controls.Add btnHelp

-- 事件处理
fn OnCreateController sender args = (
	-- 使用原始的功能逻辑
	if rolRootMotionTools.CheckModifierAvailable() then (
		if rolRootMotionTools.CreateControllerObject() then (
			CompleteRedraw()
			local linkStatus = if selection.count > 0 then "已自动建立链接控制" else "未建立链接（请手动选择质心后添加链接）"
			messageBox ("根运动控制器已创建成功！\n\n控制器包含：\n- Text对象 (主控制器 - RootCtrl)\n- Point对象 (根节点 - Root)\n- 根运动修改器 (核心功能)\n\n链接状态：" + linkStatus + "\n\n请在修改面板中找到 'Bs_RootMotion_Ctrl' 修改器。") title:"创建完成"
		)
	)
)

fn OnOpenController sender args = (
	local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
		if controllerObj != undefined then (
			select controllerObj
			setCommandPanelTaskMode #modify
		) else (
			messageBox "场景中没有找到根运动控制器。\n请先点击'创建根运动控制器'。" title:"未找到"
		)
	)

fn OnHomepageClick sender args = (
	shellLaunch "https://cafe.naver.com/pinksox/9011" ""
)

fn OnTutorialClick sender args = (
	shellLaunch "https://space.bilibili.com/2031113/lists/560782?type=season" ""
)

fn OnHelpClick sender args = (
	-- 检查是否已经打开帮助窗口
	if bsHelpForm != undefined then (
		try (
			-- 如果窗口已存在，激活它
			bsHelpForm.Activate()
			bsHelpForm.BringToFront()
			return()
		) catch (
			-- 如果窗口对象无效，重置为undefined
			bsHelpForm = undefined
		)
	)
	
	-- 创建帮助窗口
	bsHelpForm = dotNetObject "MaxCustomControls.MaxForm"
	bsHelpForm.Text = "BsRootTools 使用帮助"
	bsHelpForm.Size = dotNetObject "System.Drawing.Size" 500 550
	bsHelpForm.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").Sizable
	bsHelpForm.MaximizeBox = true
	bsHelpForm.MinimizeBox = true
	bsHelpForm.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").Manual
	bsHelpForm.ShowIcon = false
	bsHelpForm.TopMost = false
	
	-- 设置窗口位置（主窗口右侧）
	try (
		local mainFormLocation = bsRootMotionForm.Location
		local mainFormSize = bsRootMotionForm.Size
		bsHelpForm.Location = dotNetObject "System.Drawing.Point" (mainFormLocation.X + mainFormSize.Width + 10) mainFormLocation.Y
	) catch (
		-- 如果获取主窗口位置失败，使用默认位置
		bsHelpForm.Location = dotNetObject "System.Drawing.Point" 700 200
	)
	
	-- 创建富文本框显示帮助内容
	local helpText = dotNetObject "System.Windows.Forms.RichTextBox"
	helpText.Size = dotNetObject "System.Drawing.Size" 470 485
	helpText.Location = dotNetObject "System.Drawing.Point" 10 10
	helpText.ReadOnly = true
	helpText.BackColor = (dotNetClass "System.Drawing.SystemColors").Window
	helpText.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0
	helpText.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").Fixed3D
	
	-- 设置帮助内容
	local helpContent = ""
	helpContent += "📋 BsRootTools 根运动工具使用指南\n\n"
	helpContent += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
	
	helpContent += "🚀 快速开始\n"
	helpContent += "  1️⃣ 选择角色的质心骨骼（如 Bip001）\n"
	helpContent += "  2️⃣ 点击「创建根运动控制器」→ 自动建立链接\n"
	helpContent += "  3️⃣ 在修改面板调整根运动参数\n"
	helpContent += "  4️⃣ 调整完成后记录动画到临时Root\n"
	helpContent += "  5️⃣ 最后应用新Root动画并选择是否清理\n\n"
	
	helpContent += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
	
	helpContent += "🎛️ 主要功能\n\n"
	helpContent += "🔹 创建控制器\n"
	helpContent += "   • 自动创建Text控制器 + Point根节点\n"
	helpContent += "   • 自动链接质心和临时Root\n"
	helpContent += "   • 生成完整的根运动修改器\n\n"
	
	helpContent += "🔹 参数调整（修改面板）\n"
	helpContent += "   • Manual X/Y/Z: 手动位移调整\n"
	helpContent += "   • Track X/Y/Z: 追踪质心位移（0-1混合）\n"
	helpContent += "   • Track偏移: 设置追踪的偏移量\n"
	helpContent += "   • Manual/Track Yaw: 旋转控制\n\n"
	
	helpContent += "🔹 动画记录\n"
	helpContent += "   • 记录到临时根（关键帧）: 仅在关键帧设置\n"
	helpContent += "   • 记录到临时根（满帧）: 每帧都设置关键帧\n\n"
	
	helpContent += "🔹 应用根运动\n"
	helpContent += "   • 自动识别Biped/非Biped对象\n"
	helpContent += "   • 智能处理父子关系\n"
	helpContent += "   • 保留原始质心动画\n"
	helpContent += "   • 可选择清理控制器\n\n"
	
	helpContent += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
	
	helpContent += "💡 使用技巧\n\n"
	helpContent += "🔸 质心选择: 对于Biped选择Bip001，对于普通骨骼选择质心骨骼\n"
	helpContent += "🔸 参数调整: Track值控制跟随程度，0=完全手动，1=完全跟随\n"
	helpContent += "🔸 偏移设置: 使用「获取质心Z位置」快速设置高度偏移\n"
	helpContent += "🔸 曲线工具: 使用「打直关键帧曲柄」去除意外的缓动\n"
	helpContent += "🔸 轨迹显示: 「Root轨迹」按钮可切换运动轨迹显示\n\n"
	
	helpContent += "⚠️  注意事项\n\n"
	helpContent += "🔺 建议先备份场景文件\n"
	helpContent += "🔺 应用根运动前确认参数设置正确\n"
	helpContent += "🔺 清理控制器后无法再次编辑根运动参数\n"
	helpContent += "🔺 对于复杂约束系统，建议谨慎使用\n\n"
	
	helpContent += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
	helpContent += "🏷️ 版本信息: v1.0 | 原作者: 李相元 | 修改: Bullet.S"
	
	helpText.Text = helpContent
	
	-- 添加控件到窗体
	bsHelpForm.Controls.Add helpText
	
	-- 添加窗口关闭事件处理，清理全局变量
	fn OnHelpFormClosed sender args = (
		bsHelpForm = undefined
	)
	dotNet.addEventHandler bsHelpForm "FormClosed" OnHelpFormClosed
	
	-- 显示帮助窗口（非模态）
	bsHelpForm.Show(theMaxHwnd)
	dotnet.SetlifetimeControl bsHelpForm #dotNet
)

fn OnAddModifier sender args = (
	if selection.count == 0 then (
		messageBox "请先选择一个对象！" title:"错误"
			return()
		)
		
	local targetObj = selection[1]
	local rootMotionMod = BsRootMotionModifier()
	addModifier targetObj rootMotionMod
	
	setCommandPanelTaskMode #modify
	messageBox ("已为对象 " + targetObj.name + " 添加根运动修改器！") title:"添加完成"
)

fn OnRemoveController sender args = (
	local existingController = rolRootMotionTools.FindRootMotionCtrl()
	if existingController != undefined then (
		local result = yesNoCancelBox ("确定要删除根运动控制器: " + existingController.name + " 吗？\n\n这将删除控制器对象及其所有数据！")
		if result == #yes then (
			with undo on
			(
				-- 获取临时根节点（Root对象）
				local rootObj = undefined
				try (
					local rootHandle = existingController.modifiers[#Bs_RootMotion_Ctrl].RootObjHandle
					if rootHandle != 0 then (
						rootObj = maxOps.getNodeByHandle rootHandle
					)
				) catch ()
				
				-- 删除所有子对象
				for child in existingController.children do (
					delete child
				)
				
				-- 删除临时根节点（Root对象）
				if rootObj != undefined then (
					try (
						delete rootObj
					) catch ()
				)
				
				-- 删除控制器本身
				delete existingController
				CompleteRedraw()
				messageBox "根运动控制器已删除！\n（包括临时根节点）" title:"删除完成"
			)
		)
	) else (
		messageBox "场景中没有找到根运动控制器。" title:"未找到"
	)
)

fn OnApplyNewRoot sender args = (
	-- 获取相关对象
	local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
	if controllerObj == undefined then (
		messageBox "找不到根运动控制器！\n请先创建根运动控制器。" title:"错误"
		return()
	)
	
	local modifier = controllerObj.modifiers[#Bs_RootMotion_Ctrl]
	if modifier == undefined then (
		messageBox "找不到根运动修改器！" title:"错误"
		return()
	)
	
	local pelvisObj = maxOps.getNodeByHandle modifier.PelvisObjHandle
	local tempRootObj = maxOps.getNodeByHandle modifier.RootObjHandle
	local originalRootObj = maxOps.getNodeByHandle modifier.OriginalRootHandle
	
	if pelvisObj == undefined then (
		messageBox "找不到质心对象！\n请确保已正确设置质心。" title:"错误"
		return()
	)
	if tempRootObj == undefined then (
		messageBox "找不到临时根节点！\n请确保已正确设置临时根节点。" title:"错误"
		return()
	)
	
	-- 确认操作
	local confirmMsg = "将要应用新的Root动画到质心系统:\n\n"
	confirmMsg += "质心: " + pelvisObj.name + "\n"
	confirmMsg += "临时Root: " + tempRootObj.name + "\n"
	if originalRootObj != undefined then (
		confirmMsg += "原Root: " + originalRootObj.name + "\n"
	) else (
		confirmMsg += "原Root: 无\n"
	)
	confirmMsg += "\n这个操作会修改动画数据，确定要继续吗？"
	
	local result = yesNoCancelBox confirmMsg title:"确认应用Root动画"
	if result != #yes then return()
	
	-- 检查质心是否是Biped对象
	local isBiped = (classof pelvisObj == Biped_Object)
	
	if isBiped then (
		-- Biped处理流程
		try (
			-- 记录临时Root的完整变换矩阵
			local tempRootTransformList = #()
			
			print ("开始采样临时Root完整变换...")
			for t = animationRange.start to animationRange.end do (
				at time t (
					-- 直接采样完整的变换矩阵
					append tempRootTransformList tempRootObj.transform
				)
			)
			print ("采样完成: " + tempRootTransformList.count as string + " 帧")
			
			-- 记录原始Biped质心的世界空间位置和旋转
			local bipedPosList = #()
			local bipedRotList = #()
			for t = animationRange.start to animationRange.end do (
				at time t (
					append bipedPosList (in coordsys world Biped.getTransform pelvisObj #pos)
					append bipedRotList (in coordsys world Biped.getTransform pelvisObj #rotation)
				)
			)
			
			-- 处理父子关系
			if originalRootObj != undefined then (
				-- 有原Root的情况：将质心的父级设置为原Root，原Root应用临时Root的动画
				
				-- 确保质心的父级是原Root
				if pelvisObj.parent != originalRootObj then (
					pelvisObj.parent = originalRootObj
				)
				
				-- 将临时Root的完整变换应用到原Root
				local frameIndex = 1
				local originalAnimState = animButtonState
				try (
					animButtonState = true
					print ("开始应用变换到原Root...")
					for t = animationRange.start to animationRange.end do (
						at time t (
							with animate on (
								-- 直接应用完整的变换矩阵
								originalRootObj.transform = tempRootTransformList[frameIndex]
							)
							frameIndex += 1
						)
					)
					print ("原Root动画应用完成")
				) catch (ex) (
					print ("应用原Root动画时出错: " + ex as string)
					animButtonState = originalAnimState
				)
				
			) else (
				-- 没有原Root的情况：创建新的Root并应用动画
				
				-- 创建新的Root对象
				local newRoot = Point()
				newRoot.name = "Root"
				newRoot.wirecolor = color 0 255 0  -- 绿色
				newRoot.size = 80
				newRoot.cross = true
				newRoot.box = true
				
				-- 将临时Root的完整变换应用到新Root
				local frameIndex = 1
				local originalAnimState = animButtonState
				try (
					animButtonState = true
					print ("开始应用变换到新Root...")
					for t = animationRange.start to animationRange.end do (
						at time t (
							with animate on (
								-- 直接应用完整的变换矩阵
								newRoot.transform = tempRootTransformList[frameIndex]
							)
							frameIndex += 1
						)
					)
					print ("新Root动画应用完成")
				) catch (ex) (
					print ("应用新Root动画时出错: " + ex as string)
					animButtonState = originalAnimState
				)
				
				-- 设置质心的父级为新Root
				pelvisObj.parent = newRoot
				
				-- 更新修改器的原Root引用
				modifier.OriginalRootHandle = newRoot.inode.handle
				setUserProp controllerObj "BsRMOriginalRoot" newRoot.name
			)
			
			-- 创建Biped层来处理偏移
			try (
				-- 创建第一个偏移层（参考BsRetargetTools的方法）
				biped.createLayer pelvisObj.controller 1 "RootMotionOffset"
				biped.setCurrentLayer pelvisObj.controller 1
				
				local frameIndex = 1
				for t = animationRange.start to animationRange.end do (
					slidertime = t
					with animate on (
						-- 恢复原始Biped位置
						local bipedPos = bipedPosList[frameIndex]
						in coordsys world Biped.setTransform pelvisObj #pos bipedPos true
						
						-- 使用当前父节点的旋转作为参考（适配原Root或新建Root），并在当前帧获取
						local parentNode = pelvisObj.parent
						local rootRot = if parentNode != undefined then (
							at time t parentNode.controller.rotation
						) else (
							(matrix3 1).rotation
						)
						local bipedRot = bipedRotList[frameIndex]
						local localRot = bipedRot * (inverse rootRot)  -- 参考代码的公式
						Biped.setTransform pelvisObj #rotation localRot true
						
						frameIndex += 1
					)
				)
				
				-- 创建第二个反向层：仅还原位置，不再重设旋转，避免抵消第一层的局部旋转修正
				biped.createLayer pelvisObj.controller 2 "RootMotionReverse"
				biped.setCurrentLayer pelvisObj.controller 2
				frameIndex = 1
				for t = animationRange.start to animationRange.end do (
					slidertime = t
					with animate on (
						-- 仅设置原始位置
						local bipedPos = bipedPosList[frameIndex]
						in coordsys world Biped.setTransform pelvisObj #pos bipedPos true
						-- 保留第一层计算好的局部旋转
						frameIndex += 1
					)
				)
				
				-- 塌陷层（重要！）
				biped.collapseAtLayer pelvisObj.controller 1
				biped.collapseAtLayer pelvisObj.controller 0
				
			) catch (
				-- 如果Biped层创建失败，使用基本的位置设置
				local frameIndex = 1
				for t = animationRange.start to animationRange.end do (
					at time t with animate on (
						in coordsys world pelvisObj.transform.pos = bipedPosList[frameIndex]
						in coordsys world pelvisObj.transform.rotation = bipedRotList[frameIndex]
						frameIndex += 1
					)
				)
			)
			CompleteRedraw()
			messageBox "Biped根运动动画已成功应用！\n\n新的Root动画已传递给质心的父级，\n质心保持了原始的相对动画。" title:"应用完成"
			
			-- 询问是否清理控制器
			local cleanupResult = yesNoCancelBox "Root动画已成功应用！\n\n是否要清理根运动控制器和临时Root？\n\n清理后将删除：\n- 根运动控制器对象\n- 临时Root节点\n- 所有相关数据\n\n注意：清理后无法再次编辑根运动参数！" title:"清理控制器"
			if cleanupResult == #yes then (
				try (
					-- 获取临时根节点
					local rootObjToDelete = tempRootObj
					
					-- 删除控制器对象及其所有子对象
					for child in controllerObj.children do (
						delete child
					)
					delete controllerObj
					
					-- 删除临时根节点
					if rootObjToDelete != undefined then (
						delete rootObjToDelete
					)
					
					CompleteRedraw()
					messageBox "控制器清理完成！\n\n已删除：\n- 根运动控制器\n- 临时Root节点\n\nRoot动画已永久应用到骨骼系统。" title:"清理完成"
				) catch (
					messageBox ("清理控制器时出错: " + getCurrentException()) title:"清理错误"
				)
			)
			
		) catch (
			messageBox ("应用Biped根运动时出错: " + getCurrentException()) title:"错误"
		)
		
	) else (
		-- 非Biped对象的处理流程
		try (
			
			-- 记录质心的原始动画（相对于当前父级）
			local pelvisLocalPosList = #()
			local pelvisLocalRotList = #()
			
			for t = animationRange.start to animationRange.end do (
				at time t (
					append pelvisLocalPosList pelvisObj.transform.pos
					append pelvisLocalRotList pelvisObj.transform.rotation
				)
			)
			
			-- 处理Root应用
			if originalRootObj != undefined then (
				-- 有原Root：直接传递临时Root的完整变换
				local originalAnimState = animButtonState
				try (
					animButtonState = true
					print ("非Biped：开始应用变换到原Root...")
					for t = animationRange.start to animationRange.end do (
						at time t (
							with animate on (
								-- 直接应用完整的变换矩阵
								originalRootObj.transform = tempRootObj.transform
							)
						)
					)
					print ("非Biped：原Root动画应用完成")
				) catch (ex) (
					print ("非Biped：应用原Root动画时出错: " + ex as string)
					animButtonState = originalAnimState
				)
			) else (
				-- 没有原Root：创建新Root并设置父子关系
				local newRoot = Point()
				newRoot.name = uniqueName "AppliedRoot"
				newRoot.wirecolor = color 0 255 0  -- 绿色
				newRoot.size = 80
				newRoot.cross = true
				newRoot.box = true
				
				-- 应用临时Root的完整变换到新Root
				local originalAnimState = animButtonState
				try (
					animButtonState = true
					print ("非Biped：开始应用变换到新Root...")
					for t = animationRange.start to animationRange.end do (
						at time t (
							with animate on (
								-- 直接应用完整的变换矩阵
								newRoot.transform = tempRootObj.transform
							)
						)
					)
					print ("非Biped：新Root动画应用完成")
				) catch (ex) (
					print ("非Biped：应用新Root动画时出错: " + ex as string)
					animButtonState = originalAnimState
				)
				
				-- 设置父子关系
				pelvisObj.parent = newRoot
				
				-- 更新修改器引用
				modifier.OriginalRootHandle = newRoot.inode.handle
				setUserProp controllerObj "BsRMOriginalRoot" newRoot.name
			)
			
			messageBox "根运动动画已成功应用！\n\n临时Root的动画已传递给质心的父级。" title:"应用完成"
			
			-- 询问是否清理控制器
			local cleanupResult = yesNoCancelBox "Root动画已成功应用！\n\n是否要清理根运动控制器和临时Root？\n\n清理后将删除：\n- 根运动控制器对象\n- 临时Root节点\n- 所有相关数据\n\n注意：清理后无法再次编辑根运动参数！" title:"清理控制器"
			if cleanupResult == #yes then (
				try (
					with undo on
					(
						-- 获取临时根节点
						local rootObjToDelete = tempRootObj
						
						-- 删除控制器对象及其所有子对象
						for child in controllerObj.children do (
							delete child
						)
						delete controllerObj
						
						-- 删除临时根节点
						if rootObjToDelete != undefined then (
							delete rootObjToDelete
						)
						
						CompleteRedraw()
						messageBox "控制器清理完成！\n\n已删除：\n- 根运动控制器\n- 临时Root节点\n\nRoot动画已永久应用到骨骼系统。" title:"清理完成"
					)
				) catch (
					messageBox ("清理控制器时出错: " + getCurrentException()) title:"清理错误"
				)
			)
			
		) catch (
			messageBox ("应用非Biped根运动时出错: " + getCurrentException()) title:"错误"
		)
	)
)

-- 绑定事件
dotNet.addEventHandler btnCreateController "Click" OnCreateController
dotNet.addEventHandler btnOpenController "Click" OnOpenController
dotNet.addEventHandler btnAddModifier "Click" OnAddModifier
dotNet.addEventHandler btnRemoveController "Click" OnRemoveController
dotNet.addEventHandler btnApplyNewRoot "Click" OnApplyNewRoot
dotNet.addEventHandler linkHomepage "LinkClicked" OnHomepageClick
dotNet.addEventHandler linkTutorial "LinkClicked" OnTutorialClick
dotNet.addEventHandler btnHelp "Click" OnHelpClick

-- 显示窗体
bsRootMotionForm.Show(theMaxHwnd)
dotnet.SetlifetimeControl bsRootMotionForm #dotNet

-- BsRootMotionTools 加载完成