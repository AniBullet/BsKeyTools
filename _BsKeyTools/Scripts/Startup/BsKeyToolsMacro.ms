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
	buttonText:"工具窗口  位置重置"
	toolTip:"工具窗口  位置重置"
	(
		on execute do
		(
            try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms");SetDialogPos rolBsKeyTools [0,0])
            catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
		)
	)

	macroScript OpenPanel
	category:"_[BulletTools]"
	buttonText:"精简版"
	toolTip:"开启精简版自动收缩面板"
	(
		on execute do
		(
			iniCollopseType = 1
			SetINISetting BulletConfig "BulletKeyToolsSet"  "CollopseType" (iniCollopseType as string)
			if (rolBsKeyTools.open) then rolBsKeyTools.timerTickTock.active = true
		)
	)

	macroScript OpenPanelFull
	category:"_[BulletTools]"
	buttonText:"浮夸版"
	toolTip:"开启浮夸版自动收缩面板"
	(
		on execute do
		(
			iniCollopseType = 2
			SetINISetting BulletConfig "BulletKeyToolsSet"  "CollopseType" (iniCollopseType as string)
			if (rolBsKeyTools.open) then rolBsKeyTools.timerTickTock.active = true
		)
	)

	macroScript ClosePanel
	category:"_[BulletTools]"
	buttonText:"关闭"
	toolTip:"关闭自动收缩面板"
	(
		on execute do
		(
			iniCollopseType = 0
			SetINISetting BulletConfig "BulletKeyToolsSet"  "CollopseType" (iniCollopseType as string)
			if (rolBsKeyTools.open) then rolBsKeyTools.timerTickTock.active = false
		)
	)

	macroScript UrlBsToolsDocs
	category:"_[BulletTools]"
	buttonText:">> 使用说明 <<"
	toolTip:"打开帮助文档"
	(
		on execute do
		(
			shellLaunch "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" ""
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
			SetINISetting BulletConfig "BulletKeyToolsSet"  "CollopseType" (iniCollopseType as string)
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
			SetINISetting BulletConfig "BulletKeyToolsSet"  "CollopseType" (iniCollopseType as string)
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

	macroScript BsCleanVirus
	category:"_[BulletTools]"
	buttonText:"杀毒工具  推荐开启"
	toolTip:"杀毒工具  推荐开启"
	(
		on execute do
		(
            try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsCleanVirus.ms"))
			catch(messagebox "打开失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false)
		)
	)

	macroScript BsKeyToolsStartupOn
	category:"_[BulletTools]"
	buttonText:"开启"
	toolTip:"开启自动启动工具"
	(
		on execute do
		(
			if (not (SIOFile.Exists startupPath)) do
			(
				try 
				(
					SIOFile.Copy startupBsKeyTools startupPath
					messagebox ("已打开 BsKeyTools 自启！                  ")  title:"自启设置"
					setFileAttribute startupPath #readOnly true
				)
				catch
				(
					messagebox ("自启失败，烦请手动处理：\r\n把 StartupMS\\BulletKeyTools.ms 复制到\r\n\r\n" + (getDir #StartupScripts) + "                    ")
					(shellLaunch (getfilenamepath startupBsKeyTools) "")
				)
			)
		)
	)

	macroScript BsKeyToolsStartupOff
	category:"_[BulletTools]"
	buttonText:"关闭"
	toolTip:"关闭自动启动工具"
	(
		on execute do
		(
			-- try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms"))
			-- catch(messagebox "打开失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false)
			fnDelFileDir startupPath
			-- rolBsKeyTools.mItemIsStartup.checked = false
			messagebox ("已解除 BsKeyTools 自启！                  ")  title:"自启设置"
		)
	)

	macroScript BsKeyToolsBarAdd
	category:"_[BulletTools]"
	buttonText:"添加"
	toolTip:"添加工具栏按钮"
	(
		on execute do
		(
			addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools" remove: true
			addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools"
			iniAddToolbars = 1
			SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
		)
	)

	macroScript BsKeyToolsBarRemove
	category:"_[BulletTools]"
	buttonText:"移除"
	toolTip:"移除工具栏按钮"
	(
		on execute do
		(
			addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools" remove: true
			iniAddToolbars = 0
			SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
		)
	)
)