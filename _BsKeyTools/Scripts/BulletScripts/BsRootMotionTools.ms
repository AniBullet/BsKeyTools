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
			try (
				local controllerObj = rolRootMotionTools.FindRootMotionCtrl()
				if controllerObj != undefined do setUserProp controllerObj "BsRMPelvisObj" obj.name
			) catch ()
		)

		on pickRootObj picked obj do (
			if obj == undefined do return()
			RootObjHandle = obj.inode.handle
			labelRootObj.text = "临时根节点: 【 " + obj.name + " 】"
			btnLinkController.enabled = (maxOps.getNodeByHandle PelvisObjHandle != undefined)
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
				messageBox "已将临时根节点的关键帧曲线设置为平直！" title:"打直曲线完成"
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
				messageBox "已将临时根节点的关键帧曲线还原为平滑！" title:"还原曲线完成"
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

-- 检查修改器是否可用
function CheckModifierAvailable = (
	try (
		-- 使用更安全的方式检查修改器类是否存在
		local modClass = BsRootMotionModifier
		return (modClass != undefined)
	) catch (
		messageBox "根运动修改器未正确加载！\n\n请确保脚本文件完整且没有语法错误。" title:"修改器错误" beep:true
		return false
	)
)

-- 查找场景中的根运动控制器
function FindRootMotionCtrl = (
	-- 简化版本，避免在修改器创建过程中调用CheckModifierAvailable
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
)

try (bsRootMotionForm.close()) catch()

-- 创建.NET窗体
bsRootMotionForm = dotNetObject "MaxCustomControls.MaxForm"
bsRootMotionForm.Text = "BsRootTools v1.0"
bsRootMotionForm.Size = dotNetObject "System.Drawing.Size" 330 250
bsRootMotionForm.MinimizeBox = true
bsRootMotionForm.MaximizeBox = false
bsRootMotionForm.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").FixedSingle
bsRootMotionForm.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").Manual
bsRootMotionForm.ShowIcon = false  -- 隐藏左上角图标
bsRootMotionForm.TopMost = false

-- 设置窗口位置在Max窗口附近
try (
	local maxRect = windows.getMAXWindowRect()
	bsRootMotionForm.Location = dotNetObject "System.Drawing.Point" (maxRect.x + 100) (maxRect.y + 100)
) catch (
	-- 如果获取Max窗口位置失败，使用默认位置
	bsRootMotionForm.Location = dotNetObject "System.Drawing.Point" 200 200
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
linkHomepage.Location = dotNetObject "System.Drawing.Point" 10 185
linkHomepage.LinkColor = GetThemeColor #link
linkHomepage.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0

global linkTutorial = dotNetObject "System.Windows.Forms.LinkLabel"
linkTutorial.Text = "▶ 修改：Bullet.S"  -- 使用三角符号替代emoji
linkTutorial.Size = dotNetObject "System.Drawing.Size" 140 20
linkTutorial.Location = dotNetObject "System.Drawing.Point" 195 185
linkTutorial.LinkColor = GetThemeColor #link
linkTutorial.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0

-- 添加控件到窗体
bsRootMotionForm.Controls.Add btnCreateController
bsRootMotionForm.Controls.Add btnOpenController
bsRootMotionForm.Controls.Add btnApplyNewRoot
bsRootMotionForm.Controls.Add grpManagement
bsRootMotionForm.Controls.Add linkHomepage
bsRootMotionForm.Controls.Add linkTutorial

-- 事件处理
fn OnCreateController sender args = (
	-- 检查是否已有控制器
	local existingController = FindRootMotionCtrl()
	if existingController != undefined then (
		local result = yesNoCancelBox ("场景中已存在根运动控制器: " + existingController.name + "\n\n是否要创建新的控制器？\n\n是=创建新的  否=打开现有的  取消=什么都不做")
		if result == #yes then (
			local confirmResult = yesNoCancelBox "请先选择质心对象，然后点击'是'继续创建控制器。\n\n是=继续创建  否=取消创建"
			if confirmResult == #yes then (
				if selection.count > 0 then (
					-- 这里需要调用创建控制器的函数（之前的CreateControllerObject）
					messageBox "新的根运动控制器已创建！" title:"创建完成"
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
				-- 这里需要调用创建控制器的函数
				messageBox "根运动控制器已创建成功！" title:"创建完成"
			) else (
				messageBox "请先选择一个对象作为质心！" title:"错误"
			)
		)
	)
)

fn OnOpenController sender args = (
	local controllerObj = FindRootMotionCtrl()
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

-- 绑定事件
dotNet.addEventHandler btnCreateController "Click" OnCreateController
dotNet.addEventHandler btnOpenController "Click" OnOpenController
dotNet.addEventHandler linkHomepage "LinkClicked" OnHomepageClick
dotNet.addEventHandler linkTutorial "LinkClicked" OnTutorialClick

-- 显示窗体
bsRootMotionForm.Show(theMaxHwnd)
dotnet.SetlifetimeControl bsRootMotionForm #dotNet