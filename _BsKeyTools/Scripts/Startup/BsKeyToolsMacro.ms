(
	macroScript BulletKeyTools
	category:"_[BulletTools]"
	buttonText:"BsKeyTools"
	toolTip:"BsKeyTools"
	-- icon:#("VCRControls", 25)
	(
		on execute do
		(
			try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms"))
			catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
		)
	)

	macroScript BsKeyToolsPosReset
	category:"_[BulletTools]"
	buttonText:"工具窗口位置重置"
	toolTip:"工具窗口位置重置"
	(
		on execute do
		(
            try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms");SetDialogPos rolBsKeyTools [0,0])
            catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
		)
	)

	macroScript OpenBsTogglePanel
	category:"_[BulletTools]"
	buttonText:"开启"
	toolTip:"开启自动收缩面板"
	(
		on execute do
		(
			iniIsCollopse = true
			SetINISetting BulletConfig "BulletKeyToolsSet"  "IsCollopse" (iniIsCollopse as string)
			if (rolBsKeyTools.open) then rolBsKeyTools.timerTickTock.active = iniIsCollopse
		)
	)

	macroScript CloseBsTogglePanel
	category:"_[BulletTools]"
	buttonText:"关闭"
	toolTip:"关闭自动收缩面板"
	(
		on execute do
		(
			iniIsCollopse = false
			SetINISetting BulletConfig "BulletKeyToolsSet"  "IsCollopse" (iniIsCollopse as string)
			if (rolBsKeyTools.open) then rolBsKeyTools.timerTickTock.active = iniIsCollopse
		)
	)

	macroScript UrlBsToolsDocs
	category:"_[BulletTools]"
	buttonText:">> 帮助文档 <<"
	toolTip:"打开帮助文档"
	(
		on execute do
		(
			shellLaunch "https://animatorbullet.github.io/" ""
		)
	)

	macroScript UrlBsToolsIssues
	category:"_[BulletTools]"
	buttonText:">> 问题建议 <<"
	toolTip:"打开问题建议"
	(
		on execute do
		(
			shellLaunch "https://github.com/AnimatorBullet/BsKeyTools/issues" ""
		)
	)

	macroScript CheckUpdateOn
	category:"_[BulletTools]"
	buttonText:"开启"
	toolTip:"打开自动检测更新"
	(
		on execute do
		(
			iniBsAutoCheckUpdate = true
			SetINISetting BulletConfig "BulletKeyToolsSet"  "IsCollopse" (iniIsCollopse as string)
			if (rolBsKeyTools.open) then 
			(
				try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms"))
				catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
			)
		)
	)

	macroScript CheckUpdateOff
	category:"_[BulletTools]"
	buttonText:"关闭"
	toolTip:"关闭自动检测更新"
	(
		on execute do
		(
			iniBsAutoCheckUpdate = false
			SetINISetting BulletConfig "BulletKeyToolsSet"  "IsCollopse" (iniIsCollopse as string)
		)
	)

	macroScript UninstallBsKeyTools
	category:"_[BulletTools]"
	buttonText:"卸载 BsKeyTools"
	toolTip:"卸载 BsKeyTools"
	(
		on execute do
		(
			if (queryBox "是否彻底清除 BsKeyTools？          \r\n( 配置文件默认保留 )" \
			title:"有缘再会" beep:false) then
			(
				try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms"))
				catch(messagebox "卸载BsKeyTools失败,\r\n可能安装不完全无法获取卸载功能...          ")
				if (iniAddToolbars == 1) then 
				(
					addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools" remove: true
					iniAddToolbars = 0
					SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
				)
				if ((menuMan.findMenu "🎮 BsKeyTools") != undefined) then 
				(
					menuMan.unRegisterMenu (menuMan.findMenu "🎮 BsKeyTools")
					menuMan.updateMenuBar()
				)
				if (SIOFile.Exists startupPath) do (fnDelFileDir startupPath)
				if (SIOFile.Exists startupMarcroPath) do (fnDelFileDir startupMarcroPath)
				if (SIOFile.Exists startupMenuBarPath) do (fnDelFileDir startupMenuBarPath)
				arrDelPath = #(((getDir #Scripts)+ "\\BulletScripts"),((getDir #maxroot) + "\\UI_ln\\Icons\\cstoolIcons"))
				for d in arrDelPath do (fnDelDir d)
				try(destroydialog rolBsKeyTools)catch()
				try(destroydialog rolFnKeys)catch()
				try(destroydialog rolAddMyScripts)catch()
				(messagebox "已清理干净，保留配置文件备用...    \r\n" beep:false title:"卸载成功！")
			)
		)
	)

	macroScript UrlBilibili
	category:"_[BulletTools]"
	buttonText:"📺 Bilibili"
	toolTip:"📺 Bilibili"
	(
		on execute do
		(
			shellLaunch "https://space.bilibili.com/2031113" ""
		)
	)

	macroScript UrlTwitter
	category:"_[BulletTools]"
	buttonText:"🐦 Twitter"
	toolTip:"🐦 Twitter"
	(
		on execute do
		(
			shellLaunch "https://twitter.com/aniBulletCom" ""
		)
	)

	macroScript UrlQgroup
	category:"_[BulletTools]"
	buttonText:"🐧 Qgroup"
	toolTip:"🐧 Qgroup"
	(
		on execute do
		(
			if (queryBox "是否加入个人分享交流群？\r\n\r\n(游戏，动画爱好者休闲吹水正能量分享群)\r\n\r\n子弹工具人(993590655)，确认可直接跳转链接~          \r\n        " \
			title:"加入交流群" beep:false) then (shellLaunch "https://jq.qq.com/?_wv=1027&k=hmeHhTwu" "")
		)
	)
)