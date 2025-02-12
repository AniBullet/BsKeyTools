try(destroyDialog rolKeyStepMode)catch()

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)

rollout rolKeyStepMode "关键帧跳转设置 (by: Bullet.S)"
(
	label lblTips "先打开【关键帧跳转】，\"<\"：前一帧  \">\"：后一帧" pos:[5,8]
	button btnHelp "帮助" width:35 height:20 pos:[250,30] tootip:"跳转帮助网页"
	-- button btnRefresh "刷新" pos:[205,30] width:45 height:20 tooltip:"刷新状态"
	button btnKeyStepMode "|◀▶|  关键帧跳转开关" pos:[95,30] width:155 height:20 tooltip:"非关键帧切帧该工具设置无效。\r\n暂不知代码如何直接获取当前状态..."
	checkbox ckbUseTrackBar "使用轨迹栏" tooltip:"默认模式" pos:[5,33] checked:true
	checkbox ckbSelObjOnly "仅选定对象" tooltip:"仅在选定物体的帧中切换" pos:[5,60] checked:true enabled:false
	checkbox ckbUseCurTrans "使用当前变换" tooltip:"位移旋转缩放之一，按当前使用的变换" pos:[105,60] checked:true enabled:false
	checkbox ckbPosition "位置 Position" tooltip:"切帧是否包含位移帧" pos:[5,85] checked:true enabled:false
	checkbox ckbRotation "旋转 Rotation" tooltip:"切帧是否包含旋转帧" pos:[105,85] checked:true enabled:false
	checkbox ckbScale "缩放 Scale" tooltip:"切帧是否包含缩放帧" pos:[205,85] checked:true enabled:false

	fn fnRefreshChecked =
	(
		ckbUseTrackBar.checked = timeConfiguration.useTrackBar
		ckbSelObjOnly.checked  = getKeyStepsSelOnly()
		ckbUseCurTrans.checked = getKeyStepsUseTrans() 
		ckbPosition.checked    = getKeyStepsPos()
		ckbRotation.checked    = getKeyStepsRot()
		ckbScale.checked       = getKeyStepsScale()
		ckbSelObjOnly.enabled = not ckbUseTrackBar.state
		ckbUseCurTrans.enabled = not ckbUseTrackBar.state
		if ckbUseTrackBar.state == true then 
		(
			ckbPosition.enabled = false
			ckbRotation.enabled = false
			ckbScale.enabled = false
		)
		else
		(
			ckbPosition.enabled = not ckbUseCurTrans.state
			ckbRotation.enabled = not ckbUseCurTrans.state
			ckbScale.enabled = not ckbUseCurTrans.state
		)
		
	)

    on btnHelp pressed do 
    (shellLaunch "https://space.bilibili.com/2031113/lists/560782" "")

	on rolKeyStepMode open do 
	(
		fnRefreshChecked()
	)

	on btnKeyStepMode pressed do (max key mode)

    on ckbUseTrackBar changed state do 
	(
		timeConfiguration.useTrackBar = state
		fnRefreshChecked()
	)
	on ckbSelObjOnly changed state do 
	(
		setKeyStepsSelOnly state
		fnRefreshChecked()
	)
	on ckbUseCurTrans changed state do 
	(
		setKeyStepsUseTrans state
		fnRefreshChecked()
	)
	on ckbPosition changed state do 
	(
		setKeyStepsPos state
		fnRefreshChecked()
	)
	on ckbRotation changed state do 
	(
		setKeyStepsRot state
		fnRefreshChecked()
	)
	on ckbScale changed state do 
	(
		setKeyStepsScale state
		fnRefreshChecked()
	)
)
Createdialog rolKeyStepMode 295 110 fgcolor:myFgColor