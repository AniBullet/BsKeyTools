/*
* @Description: 关键帧小工具,逐渐丰富中
* @Author: Bullet.S
* @Date: 2019-09-28 11:48:53
 * @LastEditors: Bullet.S
 * @LastEditTime: 2025-02-14 18:52:54
* @Email: animator.bullet@foxmail.com
*/
try(cui.UnRegisterDialogBar rolBsKeyTools) catch()
try(destroydialog rolBsKeyTools)catch()
try(destroydialog rolFnKeys)catch()
try(destroydialog rolAddMyScripts)catch()
try(destroydialog rolCustomFps)catch()
try(destroydialog rolCustomBtn)catch()
try (callbacks.removeScripts #animationRangeChange id:#BsUpdateTimeRange) catch ()
try (callbacks.removeScripts #filePostOpen id:#BsUpdateFps) catch ()
try (callbacks.removeScripts #timeunitsChange id:#BsUpdateFps) catch ()
try (callbacks.removeScripts #filePostOpen id:#BsUpdatePlaySpeed) catch ()
try (callbacks.removeScripts #timeunitsChange id:#BsUpdatePlaySpeed) catch ()
try (callbacks.removeScripts #filePostOpen id:#BsRefreshRecentFiles) catch ()

global curVerBsKeyTools  = "1.0.1"
global verUrlBsKeyTools  = "https://gitee.com/acebullet/BsKeyTools/raw/main/_BsKeyTools/version.dat"
global oldUrlBskeyTools  = "https://gitee.com/acebullet/BsKeyTools/raw/main/_BsKeyTools/_BsKeyTools%EF%BC%88%E8%A3%85%E5%AE%8C%E9%87%8D%E5%90%AFMAX,%E8%AF%AF%E6%9D%80%E8%AF%B7%E4%BF%A1%E4%BB%BB%EF%BC%89.exe"
global oldFileBsKeyTools = (getdir #temp) + "\\_BsKeyTools_Classic.exe"
-- global dlUrlBsKeyTools   = "https://gitee.com/acebullet/BsKeyTools/raw/main/_BsKeyTools/_BsKeyTools.exe"
global dlUrlBsKeyTools   = "https://anibullet.github.io/guide/"
global dlFileBsKeyTools  = (getdir #temp) + "\\_BsKeyTools.exe"

Global BulletConfig       = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
Global startupBsKeyTools  = (getDir #Scripts) + "\\BulletScripts\\StartupMS\\BulletKeyTools.ms"
Global startupPath        = (getDir #StartupScripts)+ "\\BulletKeyTools.ms"
Global iniPos  	--位置保存记录
global iniRolDockPos
global iniTogglePanelPos
Global idBtn                = 1
global iniBsAutoCheckUpdate = false
global iniCollopseType		= 0
Global switchToolPanel      = 0
-- global switchMSPanel        = 0
Global iniToolBtnAll        = #(101,102,103,104,105,106,107,108,109,110,111,112,
							201,202,203,204,205,206,207,208,209,210,211,212,
							301,302,303,304,305,306,307,308,309,310,311,312,
							401,402,403,404,405,406,407,408,409,410,411,412)
global iniIsIcon   = false
global tooglePersp = false
-- global isMouseInBsKeyTools = true
global dateTime    		= (dotNetClass "System.DateTime").Now
global iniCostTime 		= #(0,0,0,0)
global arrNewCostTime 	= iniCostTime

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "加载配置失败，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
stLoadConfigAll.fnLoadConfigBsKeyToolsAll()
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnCheckUpdate.ms"))
catch(messagebox "打开 fnCheckUpdate.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开 fnGetColorTheme.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsSwitchBtnString.ms"))
catch(messagebox "打开 BsSwitchBtnString.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")

Global arrToolC1 = #()
Global arrToolC2 = #()
Global arrToolC3 = #()
Global arrToolC4 = #()
Global arrSourToolC1 = #()
Global arrSourToolC2 = #()
Global arrSourToolC3 = #()
Global arrSourToolC4 = #()

Global rolBsKeyTools
global rolAddMyScripts
global rolTogglePanel
Global posMouMoved       = [0,0]
Global switchMouseState  = false
Global switchSelKeyRange = 0
Global arrLastSelRange   = #()
Global switchAllKeyRange = 0
Global iniAddToolbars    = 0
Global arrLastAllRange   = #()
Global arrKeysTime       = #()  -----------biped和bone的首尾帧
Global arrLinkKeys       = #()  -----------存link帧
Global arrKeysSelected   = #()  -----------存选中的帧
global arrBlockingKeys   = #()  -----------选中或者所有物体的所有关键帧
global arrBoneEndAll     = #()  -----------末端骨骼临时层
Global keyFirst
Global keyEnd
Global keySelFirst
Global keySelEnd
Global fnAddKyes
Global fnSelectKeys
Global fnSelLinkKeys
-- Global fnAddLinkTimesKeys
-- Global fnAddLinkParamsKeys
Global keyMovedOffset = 5
Global symbol ----选择的范围判断, 0左边,1右边,2全部
Global layerTraj --轨迹辅助层
Global arrTraj            = #()  ---轨迹存放数组, 方便删除
Global arrTempUnSelection = #()  ---隐藏未选中临时存放数组
Global menuSetFps
Global menuSetSpeed
Global SIOFile = dotNetClass "System.IO.File"
Global SIODir = dotNetClass "System.IO.Directory"
dotnet.loadAssembly "Microsoft.VisualBasic.dll"
Global FileIO = dotnetclass "Microsoft.VisualBasic.FileIO.FileSystem"
Global UIOption = (dotnetclass "Microsoft.VisualBasic.FileIO.UIOption").OnlyErrorDialogs
-- Global myTimer = dotnetobject "System.Timers.Timer" 500 autoreset:true
------------------全局变量-------------------------------------------------------------------

-------------------右键面板空白处设置---------------------------------------------------------
fn getFilesequenceFile f &base &digits = 
(
	f = getFilenameFile f
	base = trimRight f "0123456789"
	digits = subString f (base.count + 1) -1
)

fn fnPseudoNaturalSort a b =  --文件名排序新方法--https://forums.cgsociety.org/t/sorting-filenames/1219205/4
(
	a = a as string
	b = b as string
	getFilesequenceFile a &aBase &aDigits
	-- hackhackhack.  This pads a number with zeros to 6 digits without using a loop.
	-- things will fail if there's more digits.. 6 'seems' safe.
	aDigits = subString ((1000000 + (aDigits as integer)) as string) 2 -1
	getFilesequenceFile b &bBase &bDigits
	bDigits = subString ((1000000 + (bDigits as integer)) as string) 2 -1
	a = aBase + aDigits
	b = bBase + bDigits

	case of (
	(a == b): 0
	(a < b): -1
	(a > b): 1
	)
)

------------------添加toolbar-----------------------------------------------
-- <Item typeID="2" type="CTB_MACROBUTTON" width="77" height="0" controlID="0" macroTypeID="3" macroType="MB_TYPE_ACTION" actionTableID="647394" imageID="-1" imageName="" actionID="BulletKeyTools`_[BulletTools]" tip="BsKeyTools" label="BsKeyTools" />

-- <Item typeID="2" type="CTB_MACROBUTTON" width="0" height="0" controlID="0" macroTypeID="3" macroType="MB_TYPE_ACTION" actionTableID="647394" imageID="-1" imageName="" actionID="BulletKeyTools`_[BulletTools]" tip="BsKeyTools" label="BsKeyTools" />
iniAddToolbars  = fnGetConfig iniAddToolbars "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
----addToolBarButton在BsKeyToolsMenuBar.ms中
-----------------------------------------------------------------------------------------------------
global arrToolNewC1 = #();global arrToolNewC2 = #();global arrToolNewC3 = #();global arrToolNewC4 = #();
global arrToolsAll
global arrToolsNameAll

rollout rolCustomBtn "自定义功能按钮位置" width:490 height:210
(
	dotNetControl dotnetBtnTabCon "System.Windows.Forms.TabControl" height:165 width:30 align:#center pos:[136,18]

	multilistbox mlbToolsBtnAll "已选择:        " width:100 height:12 pos:[5,4] selection:0
	button btnAddToSort ">>>" width:30 height:40 pos:[106,20]
	button btnRemoveFromSort "<<<" width:30 height:40 pos:[106,60]
	listbox mlbToolBtn1 "剩余:     " width:80 height:12 pos:[167,4] selection:0
	listbox mlbToolBtn2 "剩余:     " width:80 height:12 pos:[247,4] selection:0
	listbox mlbToolBtn3 "剩余:     " width:80 height:12 pos:[327,4] selection:0
	listbox mlbToolBtn4 "剩余:     " width:80 height:12 pos:[407,4] selection:0
	button btnMoveUp "↑" width:30 height:40 pos:[106,100]
	button btnMoveDown "↓" width:30 height:40 pos:[106,140]
	button btnResetBtn "重置默认" width:60 height:25 pos:[0,185]
	button btnCollectCurrent "加载当前" width:60 height:25 pos:[60,185]
	button btnReAdd "清空" width:50 height:25 pos:[120,185]
	button btnSetBtn ">>> 确认设置排序（每组最多12个按钮）<<<" width:320 height:25 pos:[170,185]
	
	fn fnSwitchTab = 
	(
		local strCurIndex = (rolCustomBtn.dotnetBtnTabCon.SelectedIndex + 1) as string
		local arrMlbToolBtn = #(mlbToolBtn1,mlbToolBtn2,mlbToolBtn3,mlbToolBtn4)
		for i in arrMlbToolBtn do
		(
			if (i.name)[i.name.count] == strCurIndex then i.enabled = true
			else i.enabled = false
		)
	)
	
	on dotnetBtnTabCon Selected arg do
	(
		fnSwitchTab()
	)		
	
	fn fnToolBtnCountText =
	(
		mlbToolBtn1.caption = "剩余: " + (12 - mlbToolBtn1.items.count) as string
		mlbToolBtn2.caption = "剩余: " + (12 - mlbToolBtn2.items.count) as string
		mlbToolBtn3.caption = "剩余: " + (12 - mlbToolBtn3.items.count) as string
		mlbToolBtn4.caption = "剩余: " + (12 - mlbToolBtn4.items.count) as string
	)
	
	fn fnAddRemoveItems action:"add" =
	(
		local arrBtnSort = #(rolCustomBtn.mlbToolBtn1,rolCustomBtn.mlbToolBtn2,
							rolCustomBtn.mlbToolBtn3,rolCustomBtn.mlbToolBtn4)
		local arrTarSort = arrBtnSort[rolCustomBtn.dotnetBtnTabCon.SelectedIndex + 1]
		local numSelAddBtn = (rolCustomBtn.mlbToolsBtnAll.selection as array).count
		local arrBtnAllTemp = join #() (mlbToolsBtnAll.items as array)
		local arrTarSortTemp = join #() (arrTarSort.items as array)
		
		if (action == "add") then 
		(
			if numSelAddBtn > 0 and ((arrTarSort.items as array).count + numSelAddBtn) <= 12 then
			(
				for i in mlbToolsBtnAll.selection as array do
				(
					append arrTarSortTemp arrBtnAllTemp[i]
				)
				for i in mlbToolsBtnAll.selection as array do
				(
					deleteitem arrBtnAllTemp (finditem arrBtnAllTemp mlbToolsBtnAll.items[i])
				)
				arrTarSort.items = arrTarSortTemp
				mlbToolsBtnAll.items = arrBtnAllTemp
				-- mlbToolsBtnAll.selection = 0
			)
			else if ((arrTarSort.items as array).count + numSelAddBtn) > 12 then (messagebox"每栏最多12个按钮...          "beep:false)
		)
		else if (action == "remove") then 
		(
			if arrTarSort.selection != 0 then 
			(
				arrBtnAllTemp = join #(arrTarSort.selected) arrBtnAllTemp
				deleteitem arrTarSortTemp (finditem arrTarSortTemp arrTarSort.selected)
				mlbToolsBtnAll.items = arrBtnAllTemp
				arrTarSort.items = arrTarSortTemp
				-- arrTarSort.selection = 0
			)
		)
	)

	fn fnSaveBtnSort =
	(
		arrToolNewC1 = mlbToolBtn1.items
		arrToolNewC2 = mlbToolBtn2.items
		arrToolNewC3 = mlbToolBtn3.items
		arrToolNewC4 = mlbToolBtn4.items
		-- arrToolsAll = arrToolC1 + arrToolC2 + arrToolC3 + arrToolC4
		-- arrToolsNameAll = for i in arrToolsAll collect i.caption
		local arrToolsNewAll = arrToolNewC1 + arrToolNewC2 + arrToolNewC3 + arrToolNewC4
		local arrIniToolBtnAllNew = #()
		for i in arrToolsNewAll do 
		(
			append arrIniToolBtnAllNew iniToolBtnAll[finditem arrToolsNameAll i]
		)
		iniToolBtnAll = (join #() arrIniToolBtnAllNew)
		fnSetToolBtnConfig ()
		-- print iniToolBtnAll #nomap
		rolBsKeyTools.fnReloadToolsBtn()
		rolBsKeyTools.fnSwitchToolsBtn idBtn
	)

	fn fnRefreshMlbToolBtn =
	(
		mlbToolBtn1.items    = for i in arrToolC1 collect i.caption
		mlbToolBtn2.items    = for i in arrToolC2 collect i.caption
		mlbToolBtn3.items    = for i in arrToolC3 collect i.caption
		mlbToolBtn4.items    = for i in arrToolC4 collect i.caption
		mlbToolsBtnAll.items = #()
		fnToolBtnCountText()
	)

	fn fnCheckSort =
	(
		if (((mlbToolsBtnAll.items as array).count == 0) and ((mlbToolBtn1.items as array).count == 12) and
			((mlbToolBtn1.items as array).count == 12) and ((mlbToolBtn1.items as array).count == 12) and 
			((mlbToolBtn1.items as array).count == 12)) then (true) else (false)
	)

	fn fnMoveItems action:"MoveUp" = 
	(
		local arrBtnSort = #(rolCustomBtn.mlbToolBtn1,rolCustomBtn.mlbToolBtn2,
							rolCustomBtn.mlbToolBtn3,rolCustomBtn.mlbToolBtn4)
		local arrTarSort = arrBtnSort[rolCustomBtn.dotnetBtnTabCon.SelectedIndex + 1]
		local arrTarSortTemp = join #() (arrTarSort.items as array)
		
		if arrTarSort.selection != 0 then 
		(
			local tarSortBtn = arrTarSort.selected
			local tarSortBtnIndex = arrTarSort.selection
			
			if (action == "MoveUp") and (tarSortBtnIndex != 1) then 
			(
				deleteItem arrTarSortTemp tarSortBtnIndex
				insertitem tarSortBtn arrTarSortTemp (tarSortBtnIndex - 1)
				arrTarSort.selection = (tarSortBtnIndex - 1)
			)
			else if (action == "MoveDown") and (tarSortBtnIndex != 12) then
			(
				deleteItem arrTarSortTemp tarSortBtnIndex
				insertitem tarSortBtn arrTarSortTemp (tarSortBtnIndex + 1)
				arrTarSort.selection = (tarSortBtnIndex + 1)
			)
			arrTarSort.items = arrTarSortTemp
			-- print arrTarSortTemp #nomap
		)
	)

	on rolCustomBtn open do 
	(
		local arrBtnTabCon = #(rolBsKeyTools.ckbC1.caption,rolBsKeyTools.ckbC2.caption,
						rolBsKeyTools.ckbC3.caption,rolBsKeyTools.ckbC4.caption)
		arrToolNewC1              = #();arrToolNewC2 = #();arrToolNewC3 = #();arrToolNewC4 = #();
		arrToolsAll               = arrToolC1 + arrToolC2 + arrToolC3 + arrToolC4
		arrToolsNameAll           = for i in arrToolsAll collect i.caption
		mlbToolsBtnAll.items      = arrToolsNameAll
		mlbToolsBtnAll.text       = "已选择: " + (rolCustomBtn.mlbToolsBtnAll.selection as array).count as string
		dotnetBtnTabCon.dock      = dotnetBtnTabCon.dock.Fill
		dotnetBtnTabCon.Drawmode  = dotnetBtnTabCon.Drawmode.OwnerDrawFixed
		dotnetBtnTabCon.SizeMode  = dotnetBtnTabCon.SizeMode.Fixed
		dotnetBtnTabCon.ItemSize  = dotNetobject "System.Drawing.Size" 40 30
		dotnetBtnTabCon.alignment = (dotnetclass "system.Windows.Forms.Tabalignment").left
        
        for aTab in arrBtnTabCon do
        (
            dotnetBtnTabCon.TabPages.add aTab
        )
        rolCustomBtn.dotnetBtnTabCon.SelectedIndex = 0
		fnSwitchTab()
		fnToolBtnCountText()
	)
	
	on mlbToolsBtnAll selectionEnd do 
	(
		mlbToolsBtnAll.text = "已选择: " + (rolCustomBtn.mlbToolsBtnAll.selection as array).count as string
	)
	
	on btnAddToSort pressed do
	(
		fnAddRemoveItems()
		fnToolBtnCountText()
		mlbToolsBtnAll.text = "已选择: " + (rolCustomBtn.mlbToolsBtnAll.selection as array).count as string
	)

	on btnRemoveFromSort pressed do
	(
		fnAddRemoveItems action:"remove"
		fnToolBtnCountText()
		mlbToolsBtnAll.text = "已选择: " + (rolCustomBtn.mlbToolsBtnAll.selection as array).count as string
	)

	on btnSetBtn pressed do 
	(
		if fnCheckSort() == true then
		(
			fnSaveBtnSort()
			try(destroydialog rolCustomBtn)catch()
		)
		else (messagebox "请确认按钮都排序完毕,才能完成设置...                    " beep:false)
	)
	on btnResetBtn pressed do 
	(
		if (queryBox "是否重置功能按钮默认位置？                   " \
		title:"重置位置" beep:false) then
		(
			iniToolBtnAll = #(101,102,103,104,105,106,107,108,109,110,111,112,
							201,202,203,204,205,206,207,208,209,210,211,212,
							301,302,303,304,305,306,307,308,309,310,311,312,
							401,402,403,404,405,406,407,408,409,410,411,412)
			fnSetToolBtnConfig ()
			rolBsKeyTools.fnReloadToolsBtn()
			rolBsKeyTools.fnSwitchToolsBtn idBtn
			-- print iniToolBtnAll #nomap
			fnRefreshMlbToolBtn()
			arrToolsAll = arrToolC1 + arrToolC2 + arrToolC3 + arrToolC4
			arrToolsNameAll = for i in arrToolsAll collect i.caption
			mlbToolsBtnAll.text = "已选择: " + (rolCustomBtn.mlbToolsBtnAll.selection as array).count as string
		)
	)
	on btnReAdd pressed do 
	(
		if (queryBox "是否清空当前列表重新排序？                   " \
		title:"清空重新排序" beep:false) then
		(
			arrToolsAll = arrToolC1 + arrToolC2 + arrToolC3 + arrToolC4
			arrToolsNameAll = for i in arrToolsAll collect i.caption
			mlbToolsBtnAll.items = arrToolsNameAll
			arrToolNewC1 = #();arrToolNewC2 = #();arrToolNewC3 = #();arrToolNewC4 = #();
			mlbToolBtn1.items = #();mlbToolBtn2.items = #();mlbToolBtn3.items = #();mlbToolBtn4.items = #()
			fnToolBtnCountText()
			mlbToolsBtnAll.selection = 0
			mlbToolsBtnAll.text = "已选择: " + (rolCustomBtn.mlbToolsBtnAll.selection as array).count as string
		)
	)
	on btnCollectCurrent pressed do 
	(
		fnRefreshMlbToolBtn()
		mlbToolsBtnAll.text = "已选择: " + (rolCustomBtn.mlbToolsBtnAll.selection as array).count as string
	)
	
	on btnMoveUp pressed do 
	(
		fnMoveItems action:"MoveUp"
	)

	on btnMoveDown pressed do 
	(
		fnMoveItems action:"MoveDown"
	)
)
--------------------------------------------------------------------------------------------------------
fn fnSwitchIconStyle = 
(
	rolBsKeyTools.ckbFnBoxDisplay.images      = #("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",28,9,10,9,10,true,false)
	rolBsKeyTools.ckbIsoSelection.images      = #("IsolateSelection_16i.bmp","IsolateSelection_16i.bmp",1,1,1,1,1,true,true)
	-- rolBsKeyTools.chkJudgeLinkKey.images      = #("Maintoolbar_24i.bmp","Maintoolbar_24i.bmp",103,6,5,6,5,true,true)
	rolBsKeyTools.ckbShadowCut.images         = #("Radiosity_16i.bmp","Radiosity_16i.bmp",6,3,4,3,4,true,true)
	rolBsKeyTools.ckbFreezeMesh.images        = #("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,17,19,17,19,true,false)
	rolBsKeyTools.btnCutFrameDisplay.images   = #("AutoGrid_16i.bmp","AutoGrid_16i.bmp",2,2,2,2,2,true,true)
	rolBsKeyTools.btnAllFrameDisplay.images   = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16a.bmp",28,11,12,11,12,true,false)
	-- rolBsKeyTools.btnTrackBarTools.images     = #("PFSubObjectIcons_24i.bmp","PFSubObjectIcons_24i.bmp",2,2,2,2,2,true,true)
	rolBsKeyTools.ckbHideBones.images         = #("Systems_16i.bmp","Systems_16i.bmp",3,3,1,3,1,true,true)
	rolBsKeyTools.ckbHideBiped.images         = #("PhysX_Main_16i.bmp","PhysX_Main_16a.bmp",33,18,17,18,17,true,false)
	rolBsKeyTools.btnImageComp.images         = #("FileLinkActionItems_16i.bmp","FileLinkActionItems_16i.bmp",9,5,6,5,6,true,true)
	rolBsKeyTools.btnTrajedit.images          = #("bip_curve_16i.bmp","bip_curve_16i.bmp",20,7,7,7,7,true,true)
	rolBsKeyTools.btnFileOpen.images          = #("UVWUnwrapOption_16i.bmp","UVWUnwrapOption_16a.bmp",30,6,6,6,6,true,false)
	rolBsKeyTools.btnLightTable.images        = #("SW_PartDyn_16i.bmp","SW_PartDyn_16i.bmp",5,1,1,1,1,true,true)
	rolBsKeyTools.ckbPlayBlocking.images      = #("bip_mfltrans_i.bmp","bip_mfltrans_i.bmp",26,21,21,21,21,true,true)
	rolBsKeyTools.btnSpringMagic.images       = #("PhysX_Main_16i.bmp","PhysX_Main_16a.bmp",33,32,32,32,32,true,false)
	rolBsKeyTools.btnCSTools.images           = #("bip_layer_i.bmp","bip_layer_i.bmp",24,17,17,17,17,true,true)
	rolBsKeyTools.btnAnimCopyPaste.images     = #("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,1,2,1,2,true,false)
	rolBsKeyTools.btnLayerManager.images      = #("AnimLayerToolbar_16i.bmp","AnimLayerToolbar_16i.bmp",12,1,1,1,1,true,true)
	rolBsKeyTools.btnSelectionsetTools.images = #("enss_tools_16i.bmp","enss_tools_16i.bmp",13,1,1,1,1,true,true)
	rolBsKeyTools.btnPoseTool.images          = #("bip_modes_i.bmp","bip_modes_i.bmp",8,1,1,1,1,true,true)
	rolBsKeyTools.btnQuicksave.images         = #("PhysX_Main_16i.bmp","PhysX_Main_16a.bmp",33,1,1,1,1,true,false)
)

rcmenu menuConfig
(
	subMenu "帮助  /  Help"
	(
		menuItem mItemHelpVideo ">> 视频教程 <<"
		menuItem mItemHelpDoc ">> 帮助文档 <<"
		menuItem mItemBugReport ">> 问题建议 <<"
		-- subMenu "关于我 [欢迎交流]"
		-- (
			separator menuAboutMe
			menuItem mItemBilibili "📺 Bilibili"
			menuItem mItemTwitter "🐦 Twitter"
			menuItem mItemQgroup "🐧 Qgroup"
		-- )
		separator menuSepClose
		menuItem mItemUninstall "卸载 [期待再再见]"
	)
	submenu "面板嵌入设置"
	(
		menuItem mItemFloat "浮动" checked:(if not rolBsKeyTools.dialogBar then true else false)
		separator menuSepDock
		menuItem mItemTop "上" checked:(if rolBsKeyTools.dialogBar and (cui.getDockState rolBsKeyTools) as string == "cui_dock_top" then true else false)
		menuItem mItemBottom "下" checked:(if rolBsKeyTools.dialogBar and (cui.getDockState rolBsKeyTools) as string == "cui_dock_bottom" then true else false)
		menuItem mItemLeft "左" checked:(if rolBsKeyTools.dialogBar and (cui.getDockState rolBsKeyTools) as string == "cui_dock_left" then true else false)
		menuItem mItemRight "右" checked:(if rolBsKeyTools.dialogBar and (cui.getDockState rolBsKeyTools) as string == "cui_dock_right" then true else false)
	)
	separator menuSepHelp
	menuItem mItemCleanVirus "杀毒工具 [推荐开启]"
	menuItem mItemWinBack "窗口找回 [会有用的]"
	menuItem mItemTimeline "时间轴工具 [Maya风格]"
	menuItem mItemIsStartup "是否随3dsMax自启"
	menuItem mItemAddToolBarBtn "添加工具栏快速启动"
	subMenu "自定义功能配置"
	(
		menuItem mItemCustomSortBtn "自定义功能按钮位置"
		-- menuItem mItemCustomScripts "自定义脚本配置管理"
		menuItem mItemCollapse "自动收缩面板 [精简]"
		menuItem mItemCollapseFull "自动收缩面板 [浮夸]"
		menuItem mItemResetCount "面板计时重置 [浮夸]"
		menuItem mItemIsIcon "切换图标模式 [实验]"
	)
	separator menuSepCustom
	subMenu "更新设置 [需要联网]"
	(
		menuItem mItemCheckUpdate "检查更新 [需要联网]"
		menuItem mItemForceUpdate "强制更新 [Beta尝鲜]"
		menuItem mItemAutoCheckUpdate "自启检测 [建议更新]"
		menuItem mItemUpdateLog "更新记录 [需求何在]"
		menuItem mItemUndoVersion "回退版本 [上个版本]"
	)
	subMenu "调试相关 [谨慎使用]"
	(
		menuItem mItemScriptsPath "脚本目录 [查错优化]"
		menuItem mItemConfigFilePath "配置文件 [备份导入]"
		menuItem mItemBackupConfigFile "备份配置 [到电脑桌面]"
		menuItem mItemDarkEditor "深色编辑器 [Maxscript]"
		menuItem mItemHelpDocs "脚本文档 [3dsMax官方]"
		menuItem mItemFBXReview "FBX查看器 [3dsMax官方]"
		menuItem mItemRolloutBuilder "脚本界面创建 [学习工具]"
		menuItem mItemHwndViewer "句柄研究 [查看工具]"
		menuItem mItemDotNetProperty "DotNet属性 [索引工具]"
		menuItem mItemFixThumbnail "修复缩略图 [管理员运行]"
	)
	menuItem mItemClose "关闭工具 | [ Close ]"

	fn fnLoadDockPos rolTarget wSize hSize =
	(
		if doesFileExist BulletConfig do
		(
			curMaxVersion = ((maxVersion())[1] / 1000)
			if curMaxVersion > 20 then  --高版本max,2019+
			(
				try
				(
					nameAttrClass = "BulletKeyToolsSet"
					btnsArr = rolTarget.controls
					iniRolDockPos = fnGetConfig iniRolDockPos nameAttrClass "DockPos" "float"
					case iniRolDockPos of
					(
						"cui_dock_top":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be horizontal
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 38
									btnsArr[b].width = 130
								)
								else if b == 2 then (btnsArr[b].pos = [50,20])
								else if b == 3 then (btnsArr[b].pos = [115,20])
								else if b == 4 then (btnsArr[b].pos = [351,2])
								else if b == 7 then (btnsArr[b].pos = [135,0];btnsArr[b].width = 30;btnsArr[b].height = 40)
								else if b == 8 then (btnsArr[b].pos = [165,0];btnsArr[b].width = 30;btnsArr[b].height = 40)
								else if b == 9 then (btnsArr[b].pos = [195,0];btnsArr[b].width = 30;btnsArr[b].height = 40)
								else if b == 11 then (btnsArr[b].pos = [232,2];btnsArr[b].width = 47;btnsArr[b].height = 17)
								else if b == 12 then (btnsArr[b].pos = [230,20];btnsArr[b].width = 50)
								else if b == 13 then (btnsArr[b].pos = [280,0];btnsArr[b].width = 60)
								else if b == 14 then (btnsArr[b].pos = [280,20];btnsArr[b].width = 60)
								else if b == 15 then (btnsArr[b].pos = [380,0];btnsArr[b].width = 60;btnsArr[b].height = 20) --选定帧
								else if b == 16 then (btnsArr[b].pos = [380,20];btnsArr[b].width = 60;btnsArr[b].height = 20) --首尾帧
								else if b > 16 and b < 31 then 
								(
									btnsArr[b].height = 20
									btnsArr[b].width = 60
									if ((mod b 2) == 1) then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,0])
									else (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,20])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].height = 20)
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 20)
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 20)
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 4].pos.x + btnsArr[b - 4].width,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 38 then (btnsArr[b].pos = rolBsKeyTools.btnPos)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[35].pos.x + btnsArr[35].width + 5,0];btnsArr[b].height = 40;btnsArr[b].width = 25)
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[35].pos.y]
									btnsArr[b].height = 40
									btnsArr[b].width = 25
								)
								else if b == 43 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width + 5,0];btnsArr[b].width = 60;btnsArr[b].height = 20) --右边工具箱第一个按钮
								else if b == 44 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [btnsArr[43].pos.x,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 56 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 67 then (btnsArr[b].pos = [btnsArr[43].pos.x,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 68 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 79 then (btnsArr[b].pos = [btnsArr[43].pos.x,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 80 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b > 44 and b <= 90 then 
								(
									btnsArr[b].height = 20
									btnsArr[b].width = 60
									if ((mod b 2) == 0) then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,btnsArr[b - 2].pos.y])
									else (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,btnsArr[b - 2].pos.y])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = false
									btnsArr[b].pos = rolBsKeyTools.btnPos
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = [342,22]
									btnsArr[b].width = 35
									btnsArr[b].height = 16
								)
								else if b == 95 then (btnsArr[b].visible = false;btnsArr[b].pos = rolBsKeyTools.btnPos;btnsArr[b].width = 130)
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 40
							rolTarget.width = 2050
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_horz)
							cui.DockDialogBar rolTarget #cui_dock_top
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_top as string))catch()
						)
						"cui_dock_bottom":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be horizontal
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 38
									btnsArr[b].width = 130
								)
								else if b == 2 then (btnsArr[b].pos = [50,20])
								else if b == 3 then (btnsArr[b].pos = [115,20])
								else if b == 4 then (btnsArr[b].pos = [351,2])
								else if b == 7 then (btnsArr[b].pos = [135,0];btnsArr[b].width = 30;btnsArr[b].height = 40)
								else if b == 8 then (btnsArr[b].pos = [165,0];btnsArr[b].width = 30;btnsArr[b].height = 40)
								else if b == 9 then (btnsArr[b].pos = [195,0];btnsArr[b].width = 30;btnsArr[b].height = 40)
								else if b == 11 then (btnsArr[b].pos = [232,2];btnsArr[b].width = 47;btnsArr[b].height = 17)
								else if b == 12 then (btnsArr[b].pos = [230,20];btnsArr[b].width = 50)
								else if b == 13 then (btnsArr[b].pos = [280,0];btnsArr[b].width = 60)
								else if b == 14 then (btnsArr[b].pos = [280,20];btnsArr[b].width = 60)
								else if b == 15 then (btnsArr[b].pos = [380,0];btnsArr[b].width = 60;btnsArr[b].height = 20) --选定帧
								else if b == 16 then (btnsArr[b].pos = [380,20];btnsArr[b].width = 60;btnsArr[b].height = 20) --首尾帧
								else if b > 16 and b < 31 then 
								(
									btnsArr[b].height = 20
									btnsArr[b].width = 60
									if ((mod b 2) == 1) then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,0])
									else (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,20])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].height = 20)
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 20)
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 20)
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 4].pos.x + btnsArr[b - 4].width,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 38 then (btnsArr[b].pos = rolBsKeyTools.btnPos)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[35].pos.x + btnsArr[35].width + 5,0];btnsArr[b].height = 40;btnsArr[b].width = 25)
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[35].pos.y]
									btnsArr[b].height = 40
									btnsArr[b].width = 25
								)
								else if b == 43 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width + 5,0];btnsArr[b].width = 60;btnsArr[b].height = 20) --右边工具箱第一个按钮
								else if b == 44 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [btnsArr[43].pos.x,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 56 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 67 then (btnsArr[b].pos = [btnsArr[43].pos.x,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 68 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 79 then (btnsArr[b].pos = [btnsArr[43].pos.x,0];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b == 80 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,20];btnsArr[b].width = 60;btnsArr[b].height = 20)
								else if b > 44 and b <= 90 then 
								(
									btnsArr[b].height = 20
									btnsArr[b].width = 60
									if ((mod b 2) == 0) then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,btnsArr[b - 2].pos.y])
									else (btnsArr[b].pos = [btnsArr[b - 2].pos.x + btnsArr[b - 2].width,btnsArr[b - 2].pos.y])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = false
									btnsArr[b].pos = rolBsKeyTools.btnPos
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = [342,22]
									btnsArr[b].width = 35
									btnsArr[b].height = 16
								)
								else if b == 95 then (btnsArr[b].visible = false;btnsArr[b].pos = rolBsKeyTools.btnPos;btnsArr[b].width = 130)
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 40
							rolTarget.width = 2050
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_horz)
							cui.DockDialogBar rolTarget #cui_dock_bottom
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_bottom as string))catch()
						)
						"cui_dock_left":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be vertical 
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 140
									btnsArr[b].width = 130
								)
								else if b == 2 then (btnsArr[b].pos = [50,40])
								else if b == 3 then (btnsArr[b].pos = [115,40])
								else if b == 4 then (btnsArr[b].pos = [5,20])
								else if b == 7 then (btnsArr[b].pos = [5,60];btnsArr[b].width = 40;btnsArr[b].height = 30)
								else if b == 8 then (btnsArr[b].pos = [45,60];btnsArr[b].width = 40;btnsArr[b].height = 30)
								else if b == 9 then (btnsArr[b].pos = [85,60];btnsArr[b].width = 40;btnsArr[b].height = 30)
								else if b == 11 then (btnsArr[b].pos = [7,95];btnsArr[b].width = 55;btnsArr[b].height = 17)
								else if b == 12 then (btnsArr[b].pos = [65,93];btnsArr[b].width = 60)
								else if b == 13 then (btnsArr[b].pos = [5,115];btnsArr[b].width = 60)
								else if b == 14 then (btnsArr[b].pos = [65,115];btnsArr[b].width = 60)
								else if b == 15 then (btnsArr[b].pos = [5,155];btnsArr[b].width = 60;btnsArr[b].height = 25) --选定帧
								else if b == 16 then (btnsArr[b].pos = [65,155];btnsArr[b].width = 60;btnsArr[b].height = 25) --首尾帧
								else if b > 16 and b < 31 then 
								(
									btnsArr[b].height = 25
									btnsArr[b].width = 60
									if ((mod b 2) == 1) then (btnsArr[b].pos = [5,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
									else (btnsArr[b].pos = [65,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 2].pos.x,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2];btnsArr[b].width = 60;btnsArr[b].height = 25)
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 25)
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 25)
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 25)
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 4].pos.x,btnsArr[b - 4].pos.y + btnsArr[b - 4].height + 2];btnsArr[b].width = 60;btnsArr[b].height = 25)
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].width = 60;btnsArr[b].height = 25)
								else if b == 38 then
								(
									btnsArr[b].pos = [0,440]
									btnsArr[b].width = 130
									btnsArr[b].height = 260
								)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[35].pos.x,btnsArr[35].pos.y + btnsArr[35].height + 30];btnsArr[b].height = 30;btnsArr[b].width = 30)
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[35].pos.y + btnsArr[35].height + 30]
									btnsArr[b].width = 30
									btnsArr[b].height = 30
								)
								else if b == 43 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32) --右边工具箱第一个按钮
								else if b == 44 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 56 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 67 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 68 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 79 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 80 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b > 44 and b <= 90 then 
								(
									;btnsArr[b].height = 32
									btnsArr[b].width = 60
									if ((mod b 2) == 1) then (btnsArr[b].pos = [5,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
									else (btnsArr[b].pos = [65,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = true;btnsArr[b].pos = [10,708]
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = [25,20]
									btnsArr[b].width = 100
									btnsArr[b].height = 16
								)
								else if b == 95 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,725];btnsArr[b].width = 130)
								else if b == 96 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,140])
								else if b == 97 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,430])
								else if b == 98 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,880])
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 940
							rolTarget.width = 130
							--
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_vert)
							cui.DockDialogBar rolTarget #cui_dock_left
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_left as string))catch()
						)
						"cui_dock_right":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be vertical 
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 140
									btnsArr[b].width = 130
								)
								else if b == 2 then (btnsArr[b].pos = [50,40])
								else if b == 3 then (btnsArr[b].pos = [115,40])
								else if b == 4 then (btnsArr[b].pos = [5,20])
								else if b == 7 then (btnsArr[b].pos = [5,60];btnsArr[b].width = 40;btnsArr[b].height = 30)
								else if b == 8 then (btnsArr[b].pos = [45,60];btnsArr[b].width = 40;btnsArr[b].height = 30)
								else if b == 9 then (btnsArr[b].pos = [85,60];btnsArr[b].width = 40;btnsArr[b].height = 30)
								else if b == 11 then (btnsArr[b].pos = [7,95];btnsArr[b].width = 55;btnsArr[b].height = 17)
								else if b == 12 then (btnsArr[b].pos = [65,93];btnsArr[b].width = 60)
								else if b == 13 then (btnsArr[b].pos = [5,115];btnsArr[b].width = 60)
								else if b == 14 then (btnsArr[b].pos = [65,115];btnsArr[b].width = 60)
								else if b == 15 then (btnsArr[b].pos = [5,155];btnsArr[b].width = 60;btnsArr[b].height = 25) --选定帧
								else if b == 16 then (btnsArr[b].pos = [65,155];btnsArr[b].width = 60;btnsArr[b].height = 25) --首尾帧
								else if b > 16 and b < 31 then 
								(
									btnsArr[b].height = 25
									btnsArr[b].width = 60
									if ((mod b 2) == 1) then (btnsArr[b].pos = [5,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
									else (btnsArr[b].pos = [65,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 2].pos.x,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2];btnsArr[b].width = 60;btnsArr[b].height = 25)
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 25)
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 25)
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].height = 25)
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 4].pos.x,btnsArr[b - 4].pos.y + btnsArr[b - 4].height + 2];btnsArr[b].width = 60;btnsArr[b].height = 25)
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[b - 1].pos.y];btnsArr[b].width = 60;btnsArr[b].height = 25)
								else if b == 38 then
								(
									btnsArr[b].pos = [0,440]
									btnsArr[b].width = 130
									btnsArr[b].height = 260
								)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[35].pos.x,btnsArr[35].pos.y + btnsArr[35].height + 30];btnsArr[b].height = 30;btnsArr[b].width = 30)
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,btnsArr[35].pos.y + btnsArr[35].height + 30]
									btnsArr[b].width = 30
									btnsArr[b].height = 30
								)
								else if b == 43 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32) --右边工具箱第一个按钮
								else if b == 44 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 56 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 67 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 68 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 79 then (btnsArr[b].pos = [5,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b == 80 then (btnsArr[b].pos = [65,490];btnsArr[b].width = 60;btnsArr[b].height = 32)
								else if b > 44 and b <= 90 then 
								(
									;btnsArr[b].height = 32
									btnsArr[b].width = 60
									if ((mod b 2) == 1) then (btnsArr[b].pos = [5,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
									else (btnsArr[b].pos = [65,btnsArr[b - 2].pos.y + btnsArr[b - 2].height + 2])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = true;btnsArr[b].pos = [10,708]
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = [25,20]
									btnsArr[b].width = 100
									btnsArr[b].height = 16
								)
								else if b == 95 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,725];btnsArr[b].width = 130)
								else if b == 96 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,140])
								else if b == 97 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,430])
								else if b == 98 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,880])
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 940
							rolTarget.width = 130
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_vert)
							cui.DockDialogBar rolTarget #cui_dock_right
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_right as string))catch()
						)
						default:
						(
							btnsArr[92].text = "2019.9 _ [ Bullet.S ]✨"
							try(cui.UnRegisterDialogBar rolTarget)catch()
							-- for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							-- (
							-- 	case b of
							-- 	(
							-- 		(92):
							-- 		(
							-- 			btnsArr[b].pos = [12,226]
							-- 			btnsArr[b].width = 125 
							-- 			btnsArr[b].height = 15
							-- 		)
							-- 		default:
							-- 		(
										
							-- 		)
							-- 	)
							-- )
							rolTarget.height = hSize
							rolTarget.width = wSize
						)
					)
				)
				catch()
			)
			else
			(
				try
				(
					nameAttrClass = "BulletKeyToolsSet"
					btnsArr = rolTarget.controls
					iniRolDockPos = fnGetConfig iniRolDockPos nameAttrClass "DockPos" "float"
					case iniRolDockPos of
					(
						"cui_dock_top":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be horizontal
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 45
									btnsArr[b].width = 135
								)
								else if b == 2 then (btnsArr[b].pos = [50,25])
								else if b == 3 then (btnsArr[b].pos = [120,25])
								else if b == 4 then (btnsArr[b].pos = [415,5])
								else if b == 7 then (btnsArr[b].pos = [140,10])
								else if b == 8 then (btnsArr[b].pos = [190,10])
								else if b == 9 then (btnsArr[b].pos = [240,10])
								else if b == 11 then (btnsArr[b].pos = [297,7])
								else if b == 12 then (btnsArr[b].visible = true;btnsArr[b].pos = [295,25])
								else if b == 13 then (btnsArr[b].pos = [350,5])
								else if b == 14 then (btnsArr[b].pos = [350,25])
								else if b == 15 then (btnsArr[b].pos = [450,0]) --选定帧
								else if b == 16 then (btnsArr[b].pos = [450,25]) --首尾帧
								else if b > 16 and b < 31 then 
								(
									if ((mod b 2) == 1) then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + 50,0])
									else (btnsArr[b].pos = [btnsArr[b - 2].pos.x + 50,25])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + 50,0])
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,25])
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,25])
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 4].pos.x + 60,0])
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 38 then (btnsArr[b].pos = rolBsKeyTools.btnPos)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[35].pos.x + 50 + 5,10])
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + 30,btnsArr[39].pos.y]
								)
								else if b == 43 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10]) --右边工具箱第一个按钮
								-- else if b == 44 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25]) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10])
								-- else if b == 56 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 67 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10])
								-- else if b == 68 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 79 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10])
								-- else if b == 80 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b >= 44 and b <= 90 then 
								(
									-- btnsArr[b].pos = [btnsArr[b - 1].pos.x + 60,btnsArr[b - 1].pos.y]
									if ((mod (b - 43) 12) != 0) then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 60,btnsArr[b - 1].pos.y])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = false
									btnsArr[b].pos = rolBsKeyTools.btnPos
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = [405,25]
								)
								else if b == 95 then (btnsArr[b].visible = false;btnsArr[b].pos = rolBsKeyTools.btnPos)
								-- else if b == 96 then (btnsArr[b].pos = [1435,20];btnsArr[b].width = 110)
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 50
							rolTarget.width = 1820
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_horz)
							cui.DockDialogBar rolTarget #cui_dock_top
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_top as string))catch()
						)
						"cui_dock_bottom":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be horizontal
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 45
									btnsArr[b].width = 135
								)
								else if b == 2 then (btnsArr[b].pos = [50,25])
								else if b == 3 then (btnsArr[b].pos = [120,25])
								else if b == 4 then (btnsArr[b].pos = [415,5])
								else if b == 7 then (btnsArr[b].pos = [140,10])
								else if b == 8 then (btnsArr[b].pos = [190,10])
								else if b == 9 then (btnsArr[b].pos = [240,10])
								else if b == 11 then (btnsArr[b].pos = [297,7])
								else if b == 12 then (btnsArr[b].visible = true;btnsArr[b].pos = [295,25])
								else if b == 13 then (btnsArr[b].pos = [350,5])
								else if b == 14 then (btnsArr[b].pos = [350,25])
								else if b == 15 then (btnsArr[b].pos = [450,0]) --选定帧
								else if b == 16 then (btnsArr[b].pos = [450,25]) --首尾帧
								else if b > 16 and b < 31 then 
								(
									if ((mod b 2) == 1) then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + 50,0])
									else (btnsArr[b].pos = [btnsArr[b - 2].pos.x + 50,25])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 2].pos.x + 50,0])
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,25])
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,25])
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 4].pos.x + 60,0])
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 38 then (btnsArr[b].pos = rolBsKeyTools.btnPos)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[35].pos.x + 50 + 5,10])
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + 30,btnsArr[39].pos.y]
								)
								else if b == 43 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10]) --右边工具箱第一个按钮
								-- else if b == 44 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25]) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10])
								-- else if b == 56 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 67 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10])
								-- else if b == 68 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b == 79 then (btnsArr[b].pos = [btnsArr[42].pos.x + 35,10])
								-- else if b == 80 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x,25])
								else if b >= 44 and b <= 90 then 
								(
									-- btnsArr[b].pos = [btnsArr[b - 1].pos.x + 60,btnsArr[b - 1].pos.y]
									if ((mod (b - 43) 12) != 0) then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 60,btnsArr[b - 1].pos.y])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = false
									btnsArr[b].pos = rolBsKeyTools.btnPos
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = [405,25]
								)
								else if b == 95 then (btnsArr[b].visible = false;btnsArr[b].pos = rolBsKeyTools.btnPos)
								-- else if b == 96 then (btnsArr[b].pos = [1435,20];btnsArr[b].width = 110)
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 50
							rolTarget.width = 1820
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_horz)
							cui.DockDialogBar rolTarget #cui_dock_bottom
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_bottom as string))catch()
						)
						"cui_dock_left":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be vertical 
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 100
									btnsArr[b].width = 160
								)
								else if b == 2 then (btnsArr[b].pos = [52,20])
								else if b == 3 then (btnsArr[b].pos = [143,20])
								else if b == 4 then (btnsArr[b].pos = [70,20])
								else if b == 7 then (btnsArr[b].pos = [5,40])
								else if b == 8 then (btnsArr[b].pos = [55,40])
								else if b == 9 then (btnsArr[b].pos = [105,40])
								else if b == 11 then (btnsArr[b].pos = [7,77])
								else if b == 12 then (btnsArr[b].visible = false;btnsArr[b].pos = rolBsKeyTools.btnPos)
								else if b == 13 then (btnsArr[b].pos = [55,75])
								else if b == 14 then (btnsArr[b].pos = [105,75])
								else if b == 15 then (btnsArr[b].pos = [5,115]) --选定帧
								else if b == 16 then (btnsArr[b].pos = [55,115]) --首尾帧
								else if b == 17 then (btnsArr[b].pos = [105,115]) --首尾帧
								else if b > 17 and b < 31 then 
								(
									if ((mod b 3) == 0) then (btnsArr[b].pos = [5,btnsArr[b - 3].pos.y + 25 + 2])
									else if (mod b 3) == 1 then (btnsArr[b].pos = [55,btnsArr[b - 3].pos.y + 25 + 2])
									else if (mod b 3) == 2 then (btnsArr[b].pos = [105,btnsArr[b - 3].pos.y + 25 + 2])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 50,btnsArr[b - 1].pos.y])
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 40,btnsArr[b - 1].pos.y])
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,btnsArr[b - 1].pos.y])
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,btnsArr[b - 1].pos.y])
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 5].pos.x,btnsArr[b - 5].pos.y + 25 + 2])
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 50,btnsArr[b - 1].pos.y])
								else if b == 38 then
								(
									btnsArr[b].pos = [5,320]
									btnsArr[b].width = 150
									btnsArr[b].height = 260
								)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[30].pos.x + 15,btnsArr[30].pos.y + 50 + 35])
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + 30,btnsArr[39].pos.y]
								)
								else if b == 43 then (btnsArr[b].pos = [15,370]) --右边工具箱第一个按钮
								else if b == 44 then (btnsArr[b].pos = [85,370]) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [15,370])
								else if b == 56 then (btnsArr[b].pos = [85,370])
								else if b == 67 then (btnsArr[b].pos = [15,370])
								else if b == 68 then (btnsArr[b].pos = [85,370])
								else if b == 79 then (btnsArr[b].pos = [15,370])
								else if b == 80 then (btnsArr[b].pos = [85,370])
								else if b > 44 and b <= 90 then 
								(

									if ((mod b 2) == 1) then (btnsArr[b].pos = [15,btnsArr[b - 2].pos.y + 34])
									else (btnsArr[b].pos = [85,btnsArr[b - 2].pos.y + 34])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = true;btnsArr[b].pos = [25,590]
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = btnsArr[36].pos + [60,3]
								)
								else if b == 95 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,610])
								else if b == 96 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,100])
								else if b == 97 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,310])
								else if b == 98 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,765])
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 915
							rolTarget.width = 160
							--
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_vert)
							cui.DockDialogBar rolTarget #cui_dock_left
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_left as string))catch()
						)
						"cui_dock_right":
						(
							try(cui.UnRegisterDialogBar rolTarget)catch()
							--	rearrange buttons to be vertical 
							for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							(
								if b == 1 then
								(
									btnsArr[b].pos = [0,2]
									btnsArr[b].text = ("BsKeyTools_v" + curVerBsKeyTools)
									btnsArr[b].height = 100
									btnsArr[b].width = 160
								)
								else if b == 2 then (btnsArr[b].pos = [52,20])
								else if b == 3 then (btnsArr[b].pos = [143,20])
								else if b == 4 then (btnsArr[b].pos = [70,20])
								else if b == 7 then (btnsArr[b].pos = [5,40])
								else if b == 8 then (btnsArr[b].pos = [55,40])
								else if b == 9 then (btnsArr[b].pos = [105,40])
								else if b == 11 then (btnsArr[b].pos = [7,77])
								else if b == 12 then (btnsArr[b].visible = false;btnsArr[b].pos = rolBsKeyTools.btnPos)
								else if b == 13 then (btnsArr[b].pos = [55,75])
								else if b == 14 then (btnsArr[b].pos = [105,75])
								else if b == 15 then (btnsArr[b].pos = [5,115]) --选定帧
								else if b == 16 then (btnsArr[b].pos = [55,115]) --首尾帧
								else if b == 17 then (btnsArr[b].pos = [105,115]) --首尾帧
								else if b > 17 and b < 31 then 
								(
									if ((mod b 3) == 0) then (btnsArr[b].pos = [5,btnsArr[b - 3].pos.y + 25 + 2])
									else if (mod b 3) == 1 then (btnsArr[b].pos = [55,btnsArr[b - 3].pos.y + 25 + 2])
									else if (mod b 3) == 2 then (btnsArr[b].pos = [105,btnsArr[b - 3].pos.y + 25 + 2])
								)
								else if b == 31 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 50,btnsArr[b - 1].pos.y])
								else if b == 32 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 40,btnsArr[b - 1].pos.y])
								else if b == 33 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,btnsArr[b - 1].pos.y])
								else if b == 34 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 20,btnsArr[b - 1].pos.y])
								else if b == 35 then (btnsArr[b].pos = [btnsArr[b - 5].pos.x,btnsArr[b - 5].pos.y + 25 + 2])
								else if b == 36 then (btnsArr[b].pos = [btnsArr[b - 1].pos.x + 50,btnsArr[b - 1].pos.y])
								else if b == 38 then
								(
									btnsArr[b].pos = [5,320]
									btnsArr[b].width = 150
									btnsArr[b].height = 260
								)
								else if b == 39 then (btnsArr[b].pos = [btnsArr[30].pos.x + 15,btnsArr[30].pos.y + 50 + 35])
								else if b >= 40 and b <= 42 then 
								(
									btnsArr[b].pos = [btnsArr[b - 1].pos.x + 30,btnsArr[39].pos.y]
								)
								else if b == 43 then (btnsArr[b].pos = [15,370]) --右边工具箱第一个按钮
								else if b == 44 then (btnsArr[b].pos = [85,370]) --右边工具箱第二个按钮
								else if b == 55 then (btnsArr[b].pos = [15,370])
								else if b == 56 then (btnsArr[b].pos = [85,370])
								else if b == 67 then (btnsArr[b].pos = [15,370])
								else if b == 68 then (btnsArr[b].pos = [85,370])
								else if b == 79 then (btnsArr[b].pos = [15,370])
								else if b == 80 then (btnsArr[b].pos = [85,370])
								else if b > 44 and b <= 90 then 
								(

									if ((mod b 2) == 1) then (btnsArr[b].pos = [15,btnsArr[b - 2].pos.y + 34])
									else (btnsArr[b].pos = [85,btnsArr[b - 2].pos.y + 34])
								)
								else if b == 92 then 
								(
									-- btnsArr[b].text = "2019 [ Bullet.S ]✨"
									btnsArr[b].visible = true;btnsArr[b].pos = [25,590]
								)
								else if b == 93 then
								(
									btnsArr[b].text = "设置"
									btnsArr[b].pos = btnsArr[36].pos + [60,3]
								)
								else if b == 95 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,610])
								else if b == 96 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,100])
								else if b == 97 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,310])
								else if b == 98 then (btnsArr[b].visible = true;btnsArr[b].pos = [0,765])
								else
								(
									btnsArr[b].visible = false
									-- btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
								)
							)
							rolTarget.height = 915
							rolTarget.width = 160
							cui.RegisterDialogBar rolTarget minSize:[rolTarget.width,rolTarget.height] maxSize:[rolTarget.width,rolTarget.height] style:#(#cui_dock_vert)
							cui.DockDialogBar rolTarget #cui_dock_right
							try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_right as string))catch()
						)
						default:
						(
							-- btnsArr[92].text = "2019.9 _ [ Bullet.S ]✨"
							try(cui.UnRegisterDialogBar rolTarget)catch()
							-- for b = 1 to btnsArr.count where ((btnsArr[b]) != undefined) do
							-- (
							-- 	case b of
							-- 	(
							-- 		(92):
							-- 		(
							-- 			btnsArr[b].pos = [12,226]
							-- 			btnsArr[b].width = 125 
							-- 			btnsArr[b].height = 15
							-- 		)
							-- 		default:
							-- 		(
										
							-- 		)
							-- 	)
							-- )
							rolTarget.height = hSize
							rolTarget.width = wSize
						)
					)
				)
				catch()
			)
		)
	)

	local startupEXTimelineMS = (getDir #Scripts) + "\\BulletScripts\\StartupMS\\EXTimelineStartup.ms"
	local startupEXTimelinePath = (getDir #StartupScripts)+ "\\EXTimelineStartup.ms"

	on menuConfig open do
	(
		-- rolBsKeyTools.timerTickTock.active = false
		-- stLoadConfigAll.fnLoadConfigBsKeyToolsAll ()
		if(SIOFile.Exists startupPath) then (mItemIsStartup.checked = true)
		else (mItemIsStartup.checked = false)
		if(SIOFile.Exists startupEXTimelinePath) then (mItemTimeline.checked = true)
		else (mItemTimeline.checked = false)
		if (iniAddToolbars == 1) then (mItemAddToolBarBtn.checked = true)
		else (mItemAddToolBarBtn.checked = false)
		mItemAutoCheckUpdate.checked = iniBsAutoCheckUpdate
		mItemIsIcon.checked = iniIsIcon
		case iniCollopseType of
		(
			0:(mItemCollapse.checked = false;mItemCollapseFull.checked = false)
			1:(mItemCollapse.checked = true;mItemCollapseFull.checked = false)
			2:(mItemCollapse.checked = false;mItemCollapseFull.checked = true)
			default:mItemCollapse.checked = false
		)
	)

	on mItemTop picked do
	(
		if not mItemTop.checked then 
		(
			rolBsKeyTools.timerTickTock.active = false
			if iniRolDockPos == "float" then (iniPos = (GetDialogPos rolBsKeyTools))
			iniRolDockPos = "cui_dock_top"
			stSetConfigAll.fnSetConfigBsKeyTools ()
			fnLoadDockPos rolBsKeyTools rolBsKeyTools.widthBsSize rolBsKeyTools.heightBsSize
		)
	)

	on mItemBottom picked do
	(
		if not mItemBottom.checked then 
		(
			rolBsKeyTools.timerTickTock.active = false
			if iniRolDockPos == "float" then (iniPos = (GetDialogPos rolBsKeyTools))
			iniRolDockPos = "cui_dock_bottom"
			stSetConfigAll.fnSetConfigBsKeyTools ()
			fnLoadDockPos rolBsKeyTools rolBsKeyTools.widthBsSize rolBsKeyTools.heightBsSize
		)
	)

	on mItemLeft picked do
	(
		if not mItemLeft.checked then 
		(
			rolBsKeyTools.timerTickTock.active = false
			if iniRolDockPos == "float" then (iniPos = (GetDialogPos rolBsKeyTools))
			iniRolDockPos = "cui_dock_left"
			stSetConfigAll.fnSetConfigBsKeyTools ()
			fnLoadDockPos rolBsKeyTools rolBsKeyTools.widthBsSize rolBsKeyTools.heightBsSize
		)
	)

	on mItemRight picked do
	(
		if not mItemRight.checked then 
		(
			rolBsKeyTools.timerTickTock.active = false
			if iniRolDockPos == "float" then (iniPos = (GetDialogPos rolBsKeyTools))
			iniRolDockPos = "cui_dock_right"
			stSetConfigAll.fnSetConfigBsKeyTools ()
			fnLoadDockPos rolBsKeyTools rolBsKeyTools.widthBsSize rolBsKeyTools.heightBsSize
		)
	)

	on mItemFloat picked do
	(
		if not mItemFloat.checked then 
		(
			if iniRolDockPos == "float" then (iniPos = (GetDialogPos rolBsKeyTools))
			iniRolDockPos = "float"
			stSetConfigAll.fnSetConfigBsKeyTools ()
			fnLoadDockPos rolBsKeyTools rolBsKeyTools.widthBsSize rolBsKeyTools.heightBsSize
			setdialogpos rolBsKeyTools iniPos
			try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms");fnCheckRolloutPos rolBsKeyTools)
			catch(messagebox "打开 BulletKeyTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
		)
	)

	on mItemResetCount picked do
	(
		if not rolBsKeyTools.dialogBar then
		(
			if (queryBox "是否重置收缩面板计时统计？                " \
			title:"计时重置" beep:false) then
			(
				dateTime     	= (dotNetClass "System.DateTime").Now
				iniCostTime 	= #(0,0,0,0)
				arrNewCostTime 	= #(0,0,0,0)
				SetINISetting BulletConfig "BulletKeyToolsSet" "CostTime" (arrNewCostTime as string)
				messagebox " (工具第一次打开开始计时) 重置完成!                                          " beep:false title:"BsKeyTools"
			)
		)
		else
		(
			messagebox "请设置嵌入模式为【浮动】!                        "
		)
	)

	on mItemHelpVideo picked do 
	(shellLaunch "https://space.bilibili.com/2031113/lists/560782" "")

	on mItemHelpDoc picked do 
	(shellLaunch "https://anibullet.github.io/" "")

	on mItemBugReport picked do
	(shellLaunch "https://github.com/AniBullet/BsKeyTools/issues" "")

	on mItemBilibili picked do 
	(shellLaunch "https://space.bilibili.com/2031113" "")

	on mItemTwitter picked do 
	(shellLaunch "https://twitter.com/aniBulletCom" "")

	on mItemScriptsPath picked do 
	(shellLaunch (getdir #Scripts) "")

	on mItemQgroup picked do
	(
		if (queryBox "是否加入个人分享交流群？\r\n\r\n(游戏，动画爱好者休闲吹水正能量分享群)\r\n\r\n子弹工具人(993590655)，确认可直接跳转链接~          \r\n        " \
		title:"加入交流群" beep:false) then
		(shellLaunch "https://jq.qq.com/?_wv=1027&k=hmeHhTwu" "")
	)

	on mItemCleanVirus picked do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsCleanVirus.ms"))
		catch(messagebox "打开 BsCleanVirus.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemConfigFilePath picked do
	(
		if (queryBox "是否打开配置文件目录？（配置文件：BulletConfig.ini）\r\n\r\n【另存或替换此文件可手动处理备份或导入脚本配置】                                                     " \
		title:"配置文件" beep:false) then (shellLaunch (getFilenamePath BulletConfig) "")
	)

	on mItemRolloutBuilder picked do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\RolloutBuilder.ms"))
		catch(messagebox "打开 RolloutBuilder.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemHwndViewer picked do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\simple_hwnd_viewer.ms"))
		catch(messagebox "打开 simple_hwnd_viewer.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemDotNetProperty picked do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\Show.NetProperty.ms"))
		catch(messagebox "打开 Show.NetProperty.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemFBXReview picked do
	(
		try(shelllaunch ((getDir #scripts) + "\\BulletScripts\\Res\\fbxreview.exe") "")
		catch(messagebox "打开 FBXReview 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemIsStartup picked do 
	(
		if (mItemIsStartup.checked == true) then 
		(
			fnDelFileDir startupPath
			mItemIsStartup.checked = false
			messagebox ("已解除 BsKeyTools 自启！                  ")  title:"自启设置"
		)
		else 
		(
			if (not (SIOFile.Exists startupPath)) do
			(
				try 
				(
					FileIO.Copyfile startupBsKeyTools startupPath UIOption
					-- SIOFile.Copy startupBsKeyTools startupPath
					messagebox ("已打开 BsKeyTools 自启！                  ")  title:"自启设置"
					mItemIsStartup.checked = true
					setFileAttribute startupPath #readOnly true
				)
				catch
				(
					-- messagebox ("自启失败，烦请管理员运行 max 或手动处理：\r\n\r\n把 StartupMS\\BulletKeyTools.ms 复制到\r\n\r\n" + (getDir #StartupScripts) + "                    ")
					-- (shellLaunch (getfilenamepath startupBsKeyTools) "")
				)
			)
		)
	)

	on mItemBackupConfigFile picked do 
	(
		local pathDesktop = (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\")
		local fileConfigBcakup = (pathDesktop + "//BulletConfig.ini")
		if (SIOFile.Exists fileConfigBcakup) then 
		(
			fnDelFileDir fileConfigBcakup
			-- SIOFile.Copy BulletConfig fileConfigBcakup
			FileIO.Copyfile BulletConfig fileConfigBcakup UIOption
		)
		else 
		(
			-- SIOFile.Copy BulletConfig fileConfigBcakup
			FileIO.Copyfile BulletConfig fileConfigBcakup UIOption
		)
		if (queryBox "是否打开配置文件备份目录？（配置文件：BulletConfig.ini）\r\n\r\n【另存或替换此文件可手动处理备份或导入脚本配置】                                                     " \
		title:"备份配置文件" beep:false) then (shellLaunch pathDesktop "")
	)

	on mItemDarkEditor picked do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\DarkScintilla.mzp"))
		catch(messagebox "打开 DarkScintilla.mzp 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemHelpDocs picked do 
	(
		try(shellLaunch ((getDir #scripts) + "\\BulletScripts\\Res\\MAXScript-Help_2024_ENU.chm") "")
		catch(messagebox "打开 MAXScript-Help 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemAddToolBarBtn picked do
	(
		if (mItemAddToolBarBtn.checked == false) then 
		(
			if (queryBox "是否添加 BsKeyTools 快捷启动图标到工具栏？\r\n\r\n(添加后可在工具栏中找到 S 图标，点击即可打开)                                             " title:"添加到工具栏") do
			(
				addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools" remove: true
				addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools"
				mItemAddToolBarBtn.checked = true
				iniAddToolbars = 1
			)
		)
		else
		(
			if (queryBox "是否移除 BsKeyTools 工具栏快捷启动图标？(不会卸载插件)                                           " title:"添加到工具栏") do
			(
				addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools" remove: true
				mItemAddToolBarBtn.checked = false
				iniAddToolbars = 0
			)
		)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
	)

	on mItemCheckUpdate picked do 
	(fnCheckUpdate curVerBsKeyTools verUrlBsKeyTools dlUrlBsKeyTools dlFileBsKeyTools isForceUpdate:false)

	on mItemForceUpdate picked do 
	(fnCheckUpdate curVerBsKeyTools verUrlBsKeyTools dlUrlBsKeyTools dlFileBsKeyTools isForceUpdate:true)

	on mItemUndoVersion picked do 
	(
		local dlUrlPreviousVersion = "https://gitee.com/acebullet/BsKeyTools/raw/main/_BsKeyTools/_PreviousVersion.exe"
		local dlFilePreviousVersion = (getdir #temp) + "\\_PreviousVersion.exe"
		fnCheckUpdate curVerBsKeyTools verUrlBsKeyTools dlUrlPreviousVersion dlFilePreviousVersion isForceUpdate:true
	)

	on mItemAutoCheckUpdate picked do 
	(
		if (mItemAutoCheckUpdate.checked == true) then (mItemAutoCheckUpdate.checked = false)
		else (mItemAutoCheckUpdate.checked = true)
		iniBsAutoCheckUpdate = mItemAutoCheckUpdate.checked
	)

	on mItemClose picked do 
	(
		try(cui.UnRegisterDialogBar rolBsKeyTools) catch()
		try(destroydialog rolBsKeyTools)catch()
		try(destroydialog rolFnKeys)catch()
		try(destroydialog rolAddMyScripts)catch()
	)

	on mItemUninstall picked do
	(
		if (queryBox "是否彻底清除 BsKeyTools？          \r\n( 配置文件默认保留 )" \
		title:"有缘再会" beep:false) then
		(
			if (iniAddToolbars == 1) then 
			(
				addToolBarButton "BulletKeyTools" "BulletTools" "BsKeyTools" remove: true
				iniAddToolbars = 0
				SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolBarBtn" (iniAddToolbars as string)
			)
			curMaxVersion = ((maxVersion())[1] / 1000)
			if curMaxVersion < 27 then
			(
				if ((menuMan.findMenu "🎮 BsKeyTools") != undefined) then 
				(
					menuMan.unRegisterMenu (menuMan.findMenu "🎮 BsKeyTools")
					menuMan.updateMenuBar()
				)
				if ((menuMan.findMenu "BsKeyTools") != undefined) then 
				(
					menuMan.unRegisterMenu (menuMan.findMenu "BsKeyTools")
					menuMan.updateMenuBar()
				)
			)

			arrDelPath = #(((getDir #Scripts)+ "\\BulletScripts"),((getDir #maxroot) + "\\UI_ln\\Icons\\cstoolIcons"))
			arrDelMs = #(((getDir #StartupScripts)+ "\\BulletKeyTools.ms"),\
			((getDir #StartupScripts)+ "\\BsKeyToolsMacro.ms"),\
			((getDir #StartupScripts)+ "\\BsKeyToolsMenuBar.ms"),\
			((getDir #StartupScripts)+ "\\BsTrackBarToolsStartup.ms"),\
			((getDir #StartupScripts)+ "\\BsCleanVirusStartup.ms"),\
			((getDir #StartupScripts)+ "\\EXTimelineStartup.ms"))
			for d in arrDelPath do (fnDelDir d)
			for f in arrDelMs do (fnDelFileDir f)
			try(cui.UnRegisterDialogBar rolBsKeyTools) catch()
			try(destroydialog rolBsKeyTools)catch()
			try(destroydialog rolFnKeys)catch()
			try(destroydialog rolAddMyScripts)catch()
			(messagebox "已清理干净，保留配置文件备用...    \r\n" beep:false title:"卸载成功！")
		)
	)

	on mItemUpdateLog picked do (shellLaunch "https://www.notion.so/bullet4869/4e28c488d5474a9082e164b7c5b6926c" "")

	on mItemCustomSortBtn picked do 
	(
		try(destroydialog rolCustomBtn)catch()
		Createdialog rolCustomBtn fgcolor:myFgColor pos:((getdialogpos rolBsKeyTools)+[0,rolBsKeyTools.height]) parent:rolBsKeyTools.hwnd
	)

	on mItemCustomScripts picked do 
	(
		try(destroydialog rolAddMyScripts)catch()
		createDialog rolAddMyScripts fgcolor:myFgColor \
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y +20]
	)

	on mItemIsIcon picked do 
	(
		-- if not rolBsKeyTools.dialogBar then
		-- (
			if (mItemIsIcon.checked == false) then 
			(
				fnSwitchIconStyle()
				mItemIsIcon.checked = not mItemIsIcon.checked
				iniIsIcon = mItemIsIcon.checked
			)
			else
			(
				mItemIsIcon.checked = not mItemIsIcon.checked
				iniIsIcon = mItemIsIcon.checked
				try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms"))
				catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
			)
		-- )
		-- else
		-- (
		-- 	messagebox "请设置嵌入模式为【浮动】!                        "
		-- )
	)

	on mItemCollapse picked do 
	(
		mItemCollapse.checked = not mItemCollapse.checked
		-- iniCollopseType = mItemCollapse.checked
		if mItemCollapse.checked == true then 
		(
			if not rolBsKeyTools.dialogBar then
			(
				mItemCollapseFull.checked = false
				iniCollopseType = 1
			)
			else
			(
				messagebox "请设置嵌入模式为【浮动】!                        "
			)
		)
		else
		(
			if mItemCollapseFull.checked == true then iniCollopseType = 2
			else iniCollopseType = 0
		)
		rolBsKeyTools.timerTickTock.active = mItemCollapse.checked
	)

	on mItemCollapseFull picked do 
	(
		mItemCollapseFull.checked = not mItemCollapseFull.checked
		-- iniCollopseType = mItemCollapse.checked
		if mItemCollapseFull.checked == true then 
		(
			if not rolBsKeyTools.dialogBar then
			(
				mItemCollapse.checked = false
				iniCollopseType = 2
			)
			else
			(
				messagebox "请设置嵌入模式为【浮动】!                        "
			)
		)
		else
		(
			if mItemCollapse.checked == true then iniCollopseType = 1
			else iniCollopseType = 0
		)
		rolBsKeyTools.timerTickTock.active = mItemCollapseFull.checked
	)

	on mItemWinBack picked do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\WinBox.ms"))
		catch(messagebox "打开 WinBox.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on mItemTimeline picked do 
	(
		if (mItemTimeline.checked == true) then 
		(
			fnDelFileDir startupEXTimelinePath
			mItemTimeline.checked = false
			messagebox ("已解除 extended_timeline 自启！                  ")  title:"timeline 自启设置"
		)
		else 
		(
			try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\Quote\\Heavenly Pictures\\Extended Timeline\\extended_timeline.ms"))
			catch(messagebox "打开 extended_timeline.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
			if (not (SIOFile.Exists startupEXTimelinePath)) do
			(
				try 
				(
					FileIO.Copyfile startupEXTimelineMS startupEXTimelinePath UIOption
					messagebox ("已打开 extended_timeline 自启！                  ")  title:"timeline 自启设置"
					mItemTimeline.checked = true
					setFileAttribute startupEXTimelinePath #readOnly true
				)
				catch()
			)
		)
	)

	on mItemFixThumbnail picked do
	(
		if (queryBox "尝试修复缩略图，若失败请注意先用管理员运行3dsMax...                          " title:"BsKeyTools") then
		(
			try(HiddenDOSCommand ("regsvr32 \"" + (getdir #maxroot) + "MaxThumbnailShellExt.dll\""))catch(messagebox "修复缩略图失败，\r\n\r\n必须先管理员运行3dsMax...                    " beep:false title:"BsKeyTools")
		)
	)
)

-------------------帧率,播放速度--------------------------------------------------------------
Global valueFps
Global valuePlaySpeed = ""
Global strCurrentFps = framerate as string + "FPS"

fn fnBsRefFps =
(
	local arrMenuSetFps = #(menuSetFps.menuSet60Fps,menuSetFps.menuSet30Fps, \
							menuSetFps.menuSet24Fps,menuSetFps.menuCustomFps)
	for i in arrMenuSetFps do i.checked = false
	case of
	(
		(framerate == 60):(menuSetFps.menuSet60Fps.checked = true)
		(framerate == 30):(menuSetFps.menuSet30Fps.checked = true)
		(framerate == 24):(menuSetFps.menuSet24Fps.checked = true)
		default:(menuSetFps.menuCustomFps.checked = true)
	)
	menuSetFps.menuCurrentFps.text = "当前: " + framerate as string + "FPS"
	strCurrentFps = framerate as string + "FPS"
	rolBsKeyTools.btnSetFps.text = strCurrentFps
)

fn fnSetFps numFps =
(
	framerate = numFps
	valueFps = numFps
	fnBsRefFps ()
	slidertime -= 1
	slidertime += 1
)

fn fnRefPlaySpeedValue =
(
	local arrMenuSetSpeed = #(menuSetSpeed.menuSet14Speed,menuSetSpeed.menuSet12Speed, \
		menuSetSpeed.menuSet1Speed,menuSetSpeed.menuSet2Speed,menuSetSpeed.menuSet4Speed)
		for i in arrMenuSetSpeed do i.checked = false
	case of
	(
		(timeConfiguration.playbackSpeed == 1):(valuePlaySpeed = "-1/4x-";menuSetSpeed.menuSet14Speed.checked =true)
		(timeConfiguration.playbackSpeed == 2):(valuePlaySpeed = "-1/2x-";menuSetSpeed.menuSet12Speed.checked =true)
		(timeConfiguration.playbackSpeed == 3):(valuePlaySpeed = "- 1x -";menuSetSpeed.menuSet1Speed.checked =true)
		(timeConfiguration.playbackSpeed == 4):(valuePlaySpeed = "- 2x -";menuSetSpeed.menuSet2Speed.checked =true)
		(timeConfiguration.playbackSpeed == 5):(valuePlaySpeed = "- 4x -";menuSetSpeed.menuSet4Speed.checked =true)
	)
	rolBsKeyTools.btnSetSpeed.text = valuePlaySpeed
	menuSetSpeed.menuCurrentSpeed.text = "当前: " + valuePlaySpeed
)

fn fnSetSpeed numSpeed =
(
	timeConfiguration.playbackSpeed = numSpeed
	fnRefPlaySpeedValue ()
)

rollout rolCustomFps ""
(
	edittext edtFpsValue "FPS: "  pos:[10,10] width:60 usePercentageWidth:true \
	percentageWidth:44.0 labelOnTop:false text:"60" bold:true readOnly:false --帧率数值
	button btnSetFps "Set" pos:[80,8]
	label labTips strCurrentFps

	on rolCustomFps open do 
	(
		edtFpsValue.text = framerate as string
		labTips.text = "当前:" + framerate as string + "FPS"
		valueFps = framerate as integer
	)

	on edtFpsValue entered val do 
	(
		if ((val != ".") and (val as integer != undefined) and (val != "") and (val as integer >= 0)) then
		(
			valueFps = (val as integer)
		)
		else messagebox "---------------------------\r\n请输入正确帧率数值\r\n"
	)
	on btnSetFps pressed do 
	(
		framerate = valueFps
		labTips.text = "当前:" + framerate as string + "FPS"
		fnBsRefFps ()
		slidertime -= 1
		slidertime += 1
	)
)

rcmenu menuSetFps
(
	menuItem menuCurrentFps "" enabled:false
	menuItem menuSet60Fps "- 60Fps -"
	menuItem menuSet30Fps "- 30Fps -"
	menuItem menuSet24Fps "- 24Fps -"
	separator menuSepCustom
	menuItem menuCustomFps "自定义帧率"

	on menuSetFps open do (fnBsRefFps ())

	on menuSet60Fps picked do (fnSetFps 60)
	on menuSet30Fps picked do(fnSetFps 30)
	on menuSet24Fps picked do (fnSetFps 24)

	on menuCustomFps picked do
	(
		try (destroyDialog rolCustomFps) catch()
		createdialog rolCustomFps 120 55 fgcolor:myFgColor \
		pos:[mouse.screenpos.x,mouse.screenpos.y]
	)
)

rcmenu menuSetSpeed
(
	menuItem menuCurrentSpeed "" enabled:false
	menuItem menuSet14Speed "-1/4x-"
	menuItem menuSet12Speed "-1/2x-"
	separator menuSepSpeedLow
	menuItem menuSet1Speed "- 1x -"
	separator menuSepSpeedHigh
	menuItem menuSet2Speed "- 2x -"
	menuItem menuSet4Speed "- 4x -"

	on menuSetSpeed open do (fnRefPlaySpeedValue ())

	on menuSet14Speed picked do (fnSetSpeed 1)
	on menuSet12Speed picked do(fnSetSpeed 2)
	on menuSet1Speed picked do (fnSetSpeed 3)
	on menuSet2Speed picked do (fnSetSpeed 4)
	on menuSet4Speed picked do (fnSetSpeed 5)
)
------------------帧率,播放速度------------------------------------------------------------

---------------------滑动帧切换rollout---------------------------------
rollout rolFnKeys "滑动帧切换 v1.1" width:280 height:120
(
	group ""
	(
		checkbox chkLHand "左手" pos:[24,20] width:50 height:20 color:Blue
		checkbox chkRHand "右手" pos:[96,20] width:50 height:20 color:Green
		checkbox chkLFoot "左脚" pos:[24,55] width:50 height:20 color:Blue checked:true
		checkbox chkRFoot "右脚" pos:[96,55] width:50 height:20 color:Green checked:true
		button btnPlanted "固定关键帧" pos:[184,20] width:80 height:25 toolTip:"Set Planted Key"
		button btnSliding "滑动关键帧" pos:[184,50] width:80 height:25 toolTip:"Set Sliding Key"
		button btnFree "自由关键帧" pos:[184,80] width:80 height:25 toolTip:"Set Free Key"
		label lblMe "[2019.05.28]  Bullet.S" pos:[24,92] width:120 height:16 color:Green
	)
	
	Fn fnSetKeyType keyType = 
	(
		sliderTime = animationRange.start
		for obj in selection where ((classof obj.baseObject == Biped_Object) \
		and (biped.getCurrentLayer obj.controller == 0)) do
		(
			bipCtrl = obj.controller
			if chkLHand.checked then 
			(
				sel_obj1 = (biped.getNode bipCtrl #larm)
				k = numKeys sel_obj1.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj1.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj1)
								(keyType == 2):(biped.SetSlidingKey sel_obj1)
								(keyType == 3):(biped.SetFreeKey sel_obj1)
							)
						)
					)
			)
			if chkRHand.checked then 
			(
				sel_obj2 = (biped.getNode bipCtrl #rarm)
				k = numKeys sel_obj2.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj2.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj2)
								(keyType == 2):(biped.SetSlidingKey sel_obj2)
								(keyType == 3):(biped.SetFreeKey sel_obj2)
							)
						)
					)
			)
			if chkLFoot.checked then 
			(
				sel_obj3 = (biped.getNode bipCtrl #lleg)
				k = numKeys sel_obj3.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj3.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj3)
								(keyType == 2):(biped.SetSlidingKey sel_obj3)
								(keyType == 3):(biped.SetFreeKey sel_obj3)
							)
						)
					)
			)
			if chkRFoot.checked then 
			(
				sel_obj4 = (biped.getNode bipCtrl #rleg)
				k = numKeys sel_obj4.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj4.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							case of
							(
								(keyType == 1):(biped.SetPlantedKey sel_obj4)
								(keyType == 2):(biped.SetSlidingKey sel_obj4)
								(keyType == 3):(biped.SetFreeKey sel_obj4)
							)
						)
					)
			)
		)
	)
	
	on btnPlanted pressed  do
	(
		fnSetKeyType 1
	)
	
	on btnSliding pressed  do
	(
		fnSetKeyType 2
	)
	
	on btnFree pressed  do
	(
		fnSetKeyType 3
	)
)
-----------------------------------------------------------------
-------------主UI-----------------------------------------------------------------
rollout rolBsKeyTools "" width:355 height:250
(
	local heightBsSize    = 250
	local widthBsSize     = 355
	local strMainRol      = ("BsKeyTools_v" + curVerBsKeyTools)
	local ui_clientOffset = undefined
	local strBtnName      = fnSwitchBtnString()
	local iconPath        = pathconfig.appendpath (getDir #Scripts) @"\\BulletScripts\\Res\\Element"
	local iconCurStr      = strBtnName[2]
	local iconElement     = (iconPath + @"\\" + iconCurStr)
	local iconPrimogem    = (iconPath + @"\\Primogem.png")
	---------------------------------UI--------------------------------------
	groupbox gbxMainUI strMainRol pos:[5,5] width:210 height:217
	
	-- label lblRangeStartText "起始帧" pos:[15,21] width:80 height:20
	-- label lblRangeEndText "结束帧" pos:[65,21] width:80 height:20
	spinner spiStartTime "" pos:[10,21] width:60 height:20 type:#integer \
	range:[-999999999,999999999,animationrange.start] scale:1
	spinner spiEndTime "" pos:[70,21] width:60 height:20 type:#integer \
	range:[-999999999,999999999,animationrange.end] scale:1

	dotnetcontrol btnPrimogem "button" pos:[130,20] width:20 height:18

	button btnMagicBtn "" pos:[150,20] width:60 height:18  \
	tooltip:"点我点我点我~良心小工具" border:false
	checkbox chkJudgeLinkKey "Link?" visible:false \
	pos:[12,48] tooltip:"选择帧前确认是否存在 Link 帧" width:40 height:15 checked:false
	button btnSelBeforeKeys "" border:true \
	pos:[10,40] width:50 height:30 toolTip:"选择滑条前面关键帧"  
	button btnSelAllKeys "" border:true \
	pos:[60,40] width:50 height:30 toolTip:"选择所有关键帧"  
	button btnSelAfterKeys "" border:true \
	pos:[110,40] width:50 height:30 toolTip:"选择滑条后面关键帧"

	dotnetcontrol btnElement "button" pos:[170,40] width:30 height:30

	edittext edtMoveKey "" width:50 usePercentageWidth:true percentageWidth:44.0 \ 
	pos:[7,72] labelOnTop:false text:"5f" bold:true readOnly:false height:17
	button btnSet5 "±5f" width:50 pos:[60,70] height:20 \
	toolTip:"恢复默认移动帧数\r\n左击：5f\r\n右击：-5f"
	button btnSetAdd "左+右-" width:50 pos:[110,70] height:20 \
	toolTip:"移动帧数设置增减 5 帧\r\n左击增加；右击减少"
	-- button btnSetOpposite "负" width:30 pos:[160,85] height:20
	button btnMoveKeys "移动帧" width:50 height:20 \
	pos:[160,70] toolTip:"移动关键帧，先左边设定帧数\r\n左击：帧栏范围保持不变~\r\n右击：帧栏范围同步增减~"  

	button btnCutFrameDisplay "选定帧" pos:[10,90] width:50 height:25 \
	tooltip:"预览选择帧\r\n再点回到上次帧范围"
	button btnAllFrameDisplay "首尾帧" pos:[60,90] width:50 height:25 \
	tooltip:"预览全部帧\r\n再点回到上次帧范围"
	-- button btnZeroFrameDisplay "零帧" pos:[100,40] width:30 height:20 \
	-- tooltip:"首帧回到0帧"
	checkbutton ckbShadowCut "秀剪影" highlightcolor:myCheckedColor \
	pos:[110,90] width:50 height:25 toolTip:"切换剪影显示\r\n右键打开环境色设置(8)"
	button btnQuicksave "快备份" pos:[160,90] width:50 height:25 \
	tooltip:"备份当前文件\r\n当前文件目录.backup 文件夹\r\n右键可快速打开备份文件夹\r\n“时光机” 工具中也能快速查看自动保存目录"
	checkbutton ckbFnBoxDisplay "BOX显"  highlightcolor:myCheckedColor \
	width:50 height:25 toolTip:"骨骼切换Box显示" pos:[10,115]
	checkbutton ckbFreezeMesh "冻模型" highlightcolor:myCheckedColor \
	toolTip:"冻结解冻模型" width:50 height:25 pos:[60,115]
	checkbutton ckbHideBones "隐Bone" highlightcolor:myCheckedColor \
	width:50 height:25 toolTip:"显示隐藏 bone\r\n所在层若隐藏则不会显示" pos:[110,115]
	checkbutton ckbHideBiped "隐Biped" width:50 height:25 highlightcolor:myCheckedColor \
	toolTip:"显示隐藏 Bip\r\n所在层若隐藏则不会显示" pos:[160,115]
	button btnImageComp "构图框" pos:[10,140] width:50 height:25 \
	tooltip:"各种经典分割视图以辅助构图"
	button btnTrajedit "轨迹线" pos:[60,140] width:50 height:25 \
	tooltip:"动画轨迹工具个人优化版（by 东见云）\r\n左键原版优化\r\n右键重构新版"
	button btnFileOpen "时光机" pos:[110,140] width:50 height:25 \
	tooltip:"快速打开max文件\r\n可收藏常用目录"
	button btnLightTable "洋葱皮" pos:[160,140] width:50 height:25 \
	toolTip:"显示运动重影 (修改自San_oOo)"
	checkButton ckbPlayBlocking "跳帧播" pos:[10,165] width:50 height:25 
	highlightcolor:myCheckedColor tooltip:"点击预览关键帧 Blocking 动画\r\n若有 Link 帧需要按下上面按钮" checked:false
	button btnSpringMagic "飘带解" pos:[60,165] width:50 height:25 \
	tooltip:"左点新版,右点旧版" 
	button btnCSTools "CS选择" pos:[110,165] width:50 height:25 \
	toolTip:"快速选择CS骨骼和调Biped等\r\n左键BsBipedTools\r\n右键老版CSTools精简版" 
	button btnAnimCopyPaste "暴力贴"  pos:[160,165] width:50 height:25 \
	toolTip:"左键动画暴力粘贴东见云优化版\r\n右键原版未修改版\r\n(有时间我也会优化或新写)" 
	checkButton ckbIsoSelection "独显" pos:[10,190] width:40 height:25 highlightcolor:myCheckedColor \
	toolTip:"隐藏当前显示的未选中物体\r\n再次点击可重新显示\r\n利用 IsolateSelection\r\n但是不改变镜头缩进"
	button btnLayerManager "层" pos:[50,190] width:20 height:25 \
	toolTip:"模拟旧版层管理器\r\n左键可嵌套层管理器\r\n右键旧版层管理器" 
	button btnSelectionsetTools "集" pos:[70,190] width:20 height:25 \
	toolTip:"选择集工具增强版" 
	button btnPoseTool "库" pos:[90,190] width:20 height:25 \
	toolTip:"参考库工具,待完善"
	button btnSetFps "" pos:[110,190] width:50 height:25 \
	toolTip:"设置帧率" 
	button btnSetSpeed "" pos:[160,190] width:50 height:25 \
	toolTip:"设置播放速度" 
	timer clock "PlayClock" interval:1 active:false
	
	groupbox gbxMinTools "" pos:[220,5] width:130 height:240

	checkbutton ckbC1 "" width:30 height:29 highlightcolor:(myCheckedColor) \
	pos:[225,15] toolTip:"" border:true
	checkbutton ckbC2 "" width:30 height:29 highlightcolor:(myCheckedColor) \
	pos:[255,15] toolTip:"" border:true
	checkbutton ckbC3 "" width:30 height:29 highlightcolor:(myCheckedColor) \
	pos:[285,15] toolTip:"" border:true
	checkbutton ckbC4 "" width:30 height:29 highlightcolor:(myCheckedColor) \
	pos:[315,15] toolTip:"" border:true

	local btnHeight = 32
	local btnWidth = 60
	local btnPos = [999999,999999]
	button btnPicker "选选择器" width:btnWidth height:btnHeight visible:false \
	tooltip:"创建带背景的选择面板\r\n\r\n左右键分别两个工具" pos:btnPos
	button btnFastAlign "对齐减帧" width:btnWidth height:btnHeight visible:false \
	toolTip:"快速对齐工具，支持 Biped\r\nCreated by Alex Velez" pos:btnPos
	checkbutton ckbPerspLock "透视锁定" width:btnWidth height:btnHeight visible:false \
	tooltip:"旋转视图后自动打开透视（类似按 P 键）\r\n再次点击可切换开关" pos:btnPos
	button btnAnimMirror "动画镜像" width:btnWidth height:btnHeight visible:false \
	toolTip:"目前引用4698to大佬的插件\r\n后面随缘新写" pos:btnPos
	button btnVportTools "视窗切镜" width:btnWidth height:btnHeight visible:false \
	toolTip:"储存视角参数，便于分镜头" pos:btnPos
	button btnBatchExport "批量降低" width:btnWidth height:btnHeight visible:false \
	toolTip:"左:新版批量降版本工具\r\n\r\n右:老版批量转换\r\n\r\n2021 以上降版本可能有损害，工具做了修复处理，注意保存蒙皮" pos:btnPos
	button btnTweenMachine "补间工具" width:btnWidth height:btnHeight visible:false pos:btnPos \
	tooltip:"前后切关键帧设置，\r\n可配合删帧或单轴修帧"
	button btnProTraj "轨迹编辑" width:btnWidth height:btnHeight visible:false \
	toolTip:"左：调节轨迹改变动画的工具,\r\n暂不支持Biped，高版本也有自带功能\r\n右：为选择物体显示简单轨迹" pos:btnPos
	button btnRescaleWU "蒙皮缩放" width:btnWidth height:btnHeight visible:false \
	toolTip:"带有Skin的缩放,带批处理\r\n(右键打开老版本)" pos:btnPos
	button btnXrSkinTool "蒙皮辅助" width:btnWidth height:btnHeight visible:false \
	tooltip:"by:东见云" pos:btnPos
	button btnFnFrame "整小数帧" width:btnWidth height:btnHeight visible:false \
	tooltip:"整数小数帧切换,\r\n平滑拖帧看卡顿" pos:btnPos
	button btnRetargetTools "FBX转CS" width:btnWidth height:btnHeight visible:false \
	tooltip:"FBX转CS骨骼，附带动画重定向工具" pos:btnPos
	button btnTrackBarTools "帧栏工具" width:btnWidth height:btnHeight visible:false \
	toolTip:"帧栏工具条" pos:btnPos
	button btnDemoTool "作品预设" width:btnWidth height:btnHeight visible:false pos:btnPos \
	toolTip:"[已有想法待补充]\r\n方便渲染作品和练习的工具"
	button btnSelBiped "选择Biped" width:btnWidth height:btnHeight visible:false \
	toolTip:"选择所有biped" pos:btnPos
	button btnSelBone "选择Bone" width:btnWidth height:btnHeight  visible:false \
	toolTip:"选择所有bone" pos:btnPos
	button btnFnTCB "TCB/欧拉" width:btnWidth height:btnHeight visible:false \
	tooltip:"欧拉和TCB互转" pos:btnPos
	button btnEulerFilter "欧拉过滤" width:btnWidth height:btnHeight visible:false \
	tooltip:"Bone骨骼过滤欧拉旋转" pos:btnPos
	button btnDelOutKeys "清所有帧" width:btnWidth height:btnHeight visible:false \
	toolTip:"清除所有关键帧" pos:btnPos
	button btnCleanOutKeys "清无限帧" width:btnWidth height:btnHeight visible:false \
	toolTip:"清范围外帧(无限帧)" pos:btnPos
	button btnEndBone "增删末端" width:btnWidth height:btnHeight visible:false \
	toolTip:"添加选择的Bone末端，可回退\r\n右键清除（注意 \"tempBoneEndAll\" 层）" pos:btnPos
	button btnRenameTools "改名工具" width:btnWidth height:btnHeight visible:false \
	toolTip:"超级重命名工具" pos:btnPos
	button btnBipedScale "CS缩放" width:btnWidth height:btnHeight visible:false \
	toolTip:"效果展示可用，导入引擎别用\r\n再次点击可解除" pos:btnPos
	button btnSelByColor "同色选择" width:btnWidth height:btnHeight visible:false \
	tooltip:"选择同颜色物体" pos:btnPos
	button btnMeshToBone "破碎工具" width:btnWidth height:btnHeight visible:false \
	toolTip:"破碎碎块快速加骨骼" pos:btnPos
	button btnMassFX "动动力学" width:btnWidth height:btnHeight visible:false \
	tooltip:"3dsMax 自带 MassFX 模拟，引擎应该无效" pos:btnPos
	button btnCollider "碰撞模拟" width:btnWidth height:btnHeight visible:false \
	tooltip:"模拟碰撞，分开物体" pos:btnPos
	button btnBakeAnim "动画烘焙" width:btnWidth height:btnHeight visible:false \
	tooltip:"可保持偏移" pos:btnPos
	button btnHideBipedTwists "隐藏Twist" width:btnWidth height:btnHeight visible:false \
	toolTip:"隐藏所有 Biped 自带 Twists，再点显示" pos:btnPos
	button btnQuickPrev "快速拍屏" width:btnWidth height:btnHeight visible:false \
	toolTip:"左：快速拍屏预览\r\n右：打开预览文件夹" pos:btnPos
	button btnChainsTools "链条工具" width:btnWidth height:btnHeight visible:false \
	tooltip:"根据样条线创建链条绑定的工具" pos:btnPos
	button btnCutSequence "动画分段" width:btnWidth height:btnHeight visible:false pos:btnPos \
	toolTip:"为长动画分段动作区间 (修改自San_oOo)"
	button btnSkinTools "Skin 工具" width:btnWidth height:btnHeight visible:false \
	toolTip:"Skin工具集成 (修改自San_oOo)" pos:btnPos
	button btnCombineDetachSkin "Skin 拆合" width:btnWidth height:btnHeight visible:false \
	tooltip:"拆分合并 Mesh 并且保留 Skin 信息，选中 Mesh 执行" pos:btnPos
	button btnBoxMan "方块超人" width:btnWidth height:btnHeight visible:false \
	tooltip:"方块练习人制作工具，半成品待完善" pos:btnPos
	button btnTwistBones "Twist创建" width:btnWidth height:btnHeight visible:false \
	tooltip:"用 bone 代替 Biped 自带 Twist，避免过度翻转" pos:btnPos
	button btnFnKeyType "改滑动帧" width:btnWidth height:btnHeight visible:false \
	toolTip:"批量转换滑动关键帧等,\r\n后续可能按需优化更多设置" pos:btnPos
	button btnRenderTools "多向渲染" width:btnWidth height:btnHeight visible:false \
	tooltip:"多方向渲染工具" pos:btnPos
	button btnMopherSlider "表情滑条" width:btnWidth height:btnHeight visible:false \
	toolTip:"选择带morpher的mesh，\r\n打开快速调节滑条方便K表情~" pos:btnPos
	button btnMorpherCtrl "表情控件" width:btnWidth height:btnHeight visible:false \
	tooltip:"快速创建表情控制器" pos:btnPos
	button btnMirrorMoph "Morph镜像" width:btnWidth height:btnHeight visible:false \
	toolTip:"镜像 Morpher 拾取对象，方便表情绑定" pos:btnPos
	button btnDelDecimalKeys "删小数帧" width:btnWidth height:btnHeight visible:false \
	toolTip:"删除所有小数帧" pos:btnPos
	button btnReplaceSkinBones "蒙皮换骨" width:btnWidth height:btnHeight visible:false \
	tooltip:"替换Skin蒙皮骨骼~\r\n（左右键点击有2个不同插件）" pos:btnPos
	checkbutton ckbFnMtlDisplay "素模切换" width:btnWidth height:btnHeight visible:false \
	toolTip:"左:切换显示隐藏贴图,方便白模预览\r\n右:Clay显示开关(红色模型显示)\r\n暂不支持子材质和Vray材质..."
	button btnXpsConvert "XPS 转换" width:btnWidth height:btnHeight visible:false \
	tooltip:"Xnalara 导入 3dsMax" pos:btnPos
	button btnCleanCustomAtts "清理冗余" width:btnWidth height:btnHeight visible:false \
	tooltip:"清理冗余自定义属性，\r\n如 day1reCA 和 SimpleFaceData ？\r\n请注意备份和保存文件" pos:btnPos
	button btnLODCreate "LOD 创建" width:btnWidth height:btnHeight visible:false \
	tooltip:"创建 LOD，保留 Skin，方便面数多的模型做动画" pos:btnPos
	checkbutton ckbIsoMesh "单显模型" width:btnWidth height:btnHeight visible:false \
	toolTip:"单独显示模型预览" pos:btnPos highlightcolor:myCheckedColor 
	pos:btnPos highlightcolor:myCheckedColor 

	groupbox gbxTips "" pos:[5,215] width:210 height:30
	
	-- label lblLink "2019.9[Bullet.S]4869" pos:[12,226] width:145 height:15
	dotnetcontrol lblLink "Label" text:"2019.9 _ [ Bullet.S ]✨" pos:[12,226] width:145 height:15
	checkbutton btnConfig "设置" pos:[170,223] width:40 height:20 border:false checked:true highlightColor:myCheckedColor

	timer timerTickTock interval:200 active:true

	dotNetControl dotLVFilesList "system.windows.forms.listView" selection:0 height:150 width:160 pos:[0,585]
	-- checkbutton ckbOpenConfigFilePath "打开配置文件目录" width:120 height:20 pos:btnPos  border:false checked:true highlightColor:myCheckedColor

	progressBar pgbLine01 "" pos:[0,-9999] width:160 height:9 color:white value:100
	progressBar pgbLine02 "" pos:[0,-9999] width:160 height:9 color:yellow value:100
	progressBar pgbLine03 "" pos:[0,-9999] width:160 height:9 color:(color myCheckedColor.r myCheckedColor.g myCheckedColor.b) value:100

	local m_PBKeyTimeArray
	local m_PBKeyMiliSecArray
	local m_PBStartTime
	local m_PBPointer
----------------------------------UI及作者ID------------------------------------------------
	fn fnInitDotNetListView =
	(	
		local align = dotNetClass "HorizontalAlignment"
		
		dotLVFilesList.Clear()
		dotLVFilesList.View = (dotNetClass "System.Windows.Forms.View").Details	
		dotLVFilesList.FullRowSelect = true
		dotLVFilesList.GridLines = false		
		dotLVFilesList.ShowItemToolTips = true
		dotLVFilesList.MultiSelect = false
		dotLVFilesList.CheckBoxes = false
		dotLVFilesList.HideSelection = false
		dotLVFilesList.Columns.Add "打开最近文件" 150
		dotLVFilesList.ForeColor = BsDotForeColor
		dotLVFilesList.BackColor = BsDotBackColor
		if dotLVFilesList.SelectedItems.Count > 0 then
		(
			dotLVFilesList.SelectedItems[0].BackColor = BsDotCheckColor
		)

		dotLVFilesList.Update()
		dotLVFilesList.Refresh()
	)

	fn fnAddToLbxList r =
	(				
		dotLVFilesList.Items.Clear()
		rows = #()	
		i = 1
		for x in r do	
		(
			li = dotNetObject "System.Windows.Forms.ListViewItem" ""
			li.useItemStyleForSubItems = false
			bold = (dotnetclass "System.Drawing.FontStyle").Bold
						
			li.text = (x as string)
			li.subitems.add x	
			
			append rows li		
			i += 1
		)
		
		dotLVFilesList.Items.addRange rows
	)

	fn fnRefreshRecentFiles =
	(
		fnInitDotNetListView()
		local recentfiles = (getdir #maxData) + "RecentDocuments.xml"
		if doesfileexist recentfiles then
		(
			local arrRecentFiles     = #()
			local xDoc = dotnetobject "system.xml.xmldocument"	
			xDoc.Load recentfiles
			local Rootelement = xDoc.documentelement

			arrRecentFiles = for i = 0 to rootelement.childnodes.item[4].childnodes.itemof[0].childnodes.count-1 collect 
			(
				rootelement.childnodes.item[4].childnodes.itemof[0].childnodes.itemof[i].childnodes.itemof[3].innertext	
			)
			LRXML = Undefined
			XDoc = Undefined
			XDoc = nothing	
		)
		return arrRecentFiles
	)

	fn fnRefreshRecentFileList =
	(
		local arrRecentFiles = fnRefreshRecentFiles()
		local arrRecentFilesName = #()
		if arrRecentFiles[1] != undefined then
		(
			for i in arrRecentFiles do 
			(
				if doesFileExist i then
				(
					append arrRecentFilesName ("📄 " + (getFilenameFile i) + ".max")
				)
				else append arrRecentFilesName ("📄 ( X ) " + (getFilenameFile i) + ".max")
			)
			-- dotLVFilesList.items = arrRecentFilesName
			fnAddToLbxList arrRecentFilesName
		)
	)
	
	fn fnGetSelectedId =
	(
		c = dotLVFilesList.SelectedItems.Count - 1		
		id = 0		
		for i = 0 to c do id = dotLVFilesList.SelectedItems.Item[i].Index + 1
		return id
	)

	fn fnOpenRecentFile =
	(
		local idSelFile = fnGetSelectedId()
		local arrRecentFiles = fnRefreshRecentFiles()

		if idSelFile > 0  then
		(
			if doesFileExist arrRecentFiles[idSelFile] then
			(
				loadMaxFile (arrRecentFiles[idSelFile] as string) useFileUnits:true quiet:true
			)
			else (messagebox ("文件可能已被删除或移走，请检查！：\r\n\r\n" + (arrRecentFiles[idSelFile] as string) + "                                                                            ") title:"提示")
		)
		fnRefreshRecentFileList()
	)

	fn fnOpenRecentFilePath =
	(
		local idSelFile = fnGetSelectedId()
		local arrRecentFiles = fnRefreshRecentFiles()

		if idSelFile > 0 and arrRecentFiles[idSelFile] != undefined then
		(
			if doesFileExist arrRecentFiles[idSelFile] then
			(
				shellLaunch (getFilenamePath (arrRecentFiles[idSelFile])) ""
			)
		)
		fnRefreshRecentFileList()
	)

	fn fnDotnetBitmap fName =
	(
		if doesFileExist fName then
		(
			local img = (dotnetclass "System.Drawing.Image").fromfile fName 
			local retBmp = dotnetObject "System.Drawing.Bitmap" (img.Width + 2) (img.height + 2)
			local g = (dotnetclass "system.drawing.graphics").fromImage retBmp
			g.drawimage img 0 0 	
			img.Dispose();
			retBmp
		)
		else return undefined
	)

	fn fnSwitchToolBtnName =
	(
		ToolTipObj = dotnetobject "System.Windows.Forms.ToolTip"
		ToolTipObj.SetToolTip btnelement "手指解压放松按钮"

		ckbC1.text = strBtnName[1][1]
		ckbC2.text = strBtnName[1][2]
		ckbC3.text = strBtnName[1][3]
		ckbC4.text = strBtnName[1][4]

		btnElement.flatstyle                         = btnElement.flatstyle.flat
		btnElement.FlatAppearance.BorderSize         = 0
		btnElement.backcolor                         = BsDotBackColor
		btnelement.FlatAppearance.MouseDownBackColor = BsDotBackColor
		btnelement.FlatAppearance.MouseOverBackColor = BsDotBackColor
		-- btnElement.TextAlign                         = (dotnetclass "System.Drawing.ContentAlignment").MiddleCenter
		btnElement.image                             = (fnDotnetBitmap iconElement)
	)

	fn fnSetBtnPrimogem =
	(
		ToolTipObj = dotnetobject "System.Windows.Forms.ToolTip"
		ToolTipObj.SetToolTip btnPrimogem "点击打开自定义脚本集"

		btnPrimogem.flatstyle                         = btnPrimogem.flatstyle.flat
		btnPrimogem.FlatAppearance.BorderSize         = 0
		btnPrimogem.backcolor                         = BsDotBackColor
		btnPrimogem.FlatAppearance.MouseDownBackColor = BsDotBackColor
		btnPrimogem.FlatAppearance.MouseOverBackColor = BsDotCheckColor
		btnPrimogem.image                             = (fnDotnetBitmap iconPrimogem)
	)

	fn fnSwitchMagicBtn toggleID =
	(
		if toggleID == 1 then
		(
			rolBsKeyTools.width        = 220
			-- rolBsKeyTools.height       = 250
			btnMagicBtn.text           = "(≖ ◡ ≖)✧"
			switchToolPanel            = 0
		)
		else
		(
			rolBsKeyTools.width        = 355
			-- rolBsKeyTools.height       = 250
			btnMagicBtn.text           = "( = `▽`)ノ"
			switchToolPanel            = 1
		)
	)

	fn fnRefreshMagicBtn =
	(
		if switchToolPanel == 0 then (fnSwitchMagicBtn 1) else (fnSwitchMagicBtn 0)
	)

	fn fnReloadToolsBtn =
	(
		arrSourToolC1 = #(rolBsKeyTools.btnPicker,rolBsKeyTools.btnFastAlign,
						rolBsKeyTools.ckbPerspLock,rolBsKeyTools.btnAnimMirror,
						rolBsKeyTools.btnVportTools,rolBsKeyTools.btnBatchExport,
						rolBsKeyTools.btnTweenMachine,rolBsKeyTools.btnProTraj,
						rolBsKeyTools.btnRescaleWU,rolBsKeyTools.btnXrSkinTool,
						rolBsKeyTools.btnFnFrame,rolBsKeyTools.btnRetargetTools)
		arrSourToolC2 = #(rolBsKeyTools.btnTrackBarTools,rolBsKeyTools.btnDemoTool,
						rolBsKeyTools.btnSelBiped,rolBsKeyTools.btnSelBone,
						rolBsKeyTools.btnFnTCB,rolBsKeyTools.btnEulerFilter,
						rolBsKeyTools.btnDelOutKeys,rolBsKeyTools.btnCleanOutKeys,
						rolBsKeyTools.btnEndBone,rolBsKeyTools.btnRenameTools,
						rolBsKeyTools.btnBipedScale,rolBsKeyTools.btnSelByColor)
		arrSourToolC3 = #(rolBsKeyTools.btnMeshToBone,rolBsKeyTools.btnMassFX,
						rolBsKeyTools.btnCollider,rolBsKeyTools.btnBakeAnim,
						rolBsKeyTools.btnHideBipedTwists,rolBsKeyTools.btnQuickPrev,
						rolBsKeyTools.btnChainsTools,rolBsKeyTools.btnCutSequence,
						rolBsKeyTools.btnSkinTools,rolBsKeyTools.btnCombineDetachSkin,
						rolBsKeyTools.btnBoxMan,rolBsKeyTools.btnTwistBones)
		arrSourToolC4 = #(rolBsKeyTools.btnFnKeyType,rolBsKeyTools.btnRenderTools,
						rolBsKeyTools.btnMopherSlider,rolBsKeyTools.btnMorpherCtrl,
						rolBsKeyTools.btnMirrorMoph,rolBsKeyTools.btnDelDecimalKeys,
						rolBsKeyTools.btnReplaceSkinBones,rolBsKeyTools.ckbFnMtlDisplay,
						rolBsKeyTools.btnXpsConvert,rolBsKeyTools.btnCleanCustomAtts,
						rolBsKeyTools.btnLODCreate,rolBsKeyTools.ckbIsoMesh)
		
		fnLoadToolBtnConfig()
		arrToolsAllTemp = arrSourToolC1 + arrSourToolC2 + arrSourToolC3 + arrSourToolC4
		arrTargetTemp = #()
		for i in iniToolBtnAll where i != undefined do
		(
			local strSortID = i as string
			local indexToolID = (strSortID[1] as number - 1) * 12 + (strSortID[2] + strSortID[3]) as Number
			append arrTargetTemp arrToolsAllTemp[indexToolID]
		)
		arrToolC1 = for i = 1 to arrTargetTemp.count/4 collect arrTargetTemp[i]
		arrToolC2 = for i = (arrTargetTemp.count/4 + 1) to (2 * arrTargetTemp.count/4) collect arrTargetTemp[i]
		arrToolC3 = for i = (2 * arrTargetTemp.count/4 + 1) to (3 * arrTargetTemp.count/4) collect arrTargetTemp[i]
		arrToolC4 = for i = (3 * arrTargetTemp.count/4 + 1) to (4 * arrTargetTemp.count/4) collect arrTargetTemp[i]
	)

	fn fnSwitchToolsBtn idBtn =
	(
		local arrBtnAll = arrToolC1 + arrToolC2 + arrToolC3 + arrToolC4
		local curMaxVersion = ((maxVersion())[1] / 1000)
		for b in arrBtnAll do (b.visible = false)

		if not rolBsKeyTools.dialogBar then 
		(
			str  = "for b = 1 to arrToolC" + idBtn as string + ".count do" + "\r\n"
			str += "(" + "\r\n"
			str += "	arrToolC" + idBtn as string + "[b].visible = true" + "\r\n"
			str += "	if (mod b 2 == 1) then \r\n"
			str += "	("
			str += "		arrToolC" + idBtn as string + "[b].pos = " + [225,45] as string + " + [0,(b - 1) * 16.5]" + "\r\n"
			str += "	)"
			str += "	else if (mod b 2 == 0) then"
			str += "	("
			str += "		arrToolC" + idBtn as string + "[b].pos = " + [285,45] as string + " + [0,(b - 2) * 16.5]" + "\r\n"
			str += "	)"
			str += ")"
		)
		else if rolBsKeyTools.dialogBar and ((cui.getDockState rolBsKeyTools) as string == "cui_dock_left" or (cui.getDockState rolBsKeyTools) as string == "cui_dock_right") then
		(
			str  = "for b = 1 to arrToolC" + idBtn as string + ".count do" + "\r\n"
			str += "(" + "\r\n"
			str += "	arrToolC" + idBtn as string + "[b].visible = true" + "\r\n"
			str += "	if (mod b 2 == 1) then \r\n"
			str += "	("
			str += "        if " + curMaxVersion as string + " > 20 then "
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [5,490] as string + " + [0,(b - 1) * 17]" + "\r\n"
			str += "		)"
			str += "		else"
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [15,370] as string + " + [0,(b - 1) * 17]" + "\r\n"
			str += "		)"
			str += "	)"
			str += "	else if (mod b 2 == 0) then"
			str += "	("
			str += "		if " + curMaxVersion as string + " > 20 then "
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [65,490] as string + " + [0,(b - 2) * 17]" + "\r\n"
			str += "		)"
			str += "		else"
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [85,370] as string + " + [0,(b - 2) * 17]" + "\r\n"
			str += "		)"
			str += "	)"
			str += ")"
		)
		else if rolBsKeyTools.dialogBar and ((cui.getDockState rolBsKeyTools) as string == "cui_dock_top" or (cui.getDockState rolBsKeyTools) as string == "cui_dock_bottom") then
		(
			str  = "for b = 1 to arrToolC" + idBtn as string + ".count do" + "\r\n"
			str += "(" + "\r\n"
			str += "	arrToolC" + idBtn as string + "[b].visible = true" + "\r\n"
			str += "	if (mod b 2 == 1) then \r\n"
			str += "	("
			str += "        if " + curMaxVersion as string + " > 20 then "
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [1090,0] as string + " + [(b - 1) * 30,0]" + "\r\n"
			str += "		)"
			str += "		else"
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [1090,10] as string + " + [(b - 1) * 60,0]" + "\r\n"
			str += "		)"
			str += "	)"
			str += "	else if (mod b 2 == 0) then"
			str += "	("
			str += "		if " + curMaxVersion as string + " > 20 then "
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [1090,20] as string + " + [(b - 2) * 30,0]" + "\r\n"
			str += "		)"
			str += "		else"
			str += "		("
			str += "			arrToolC" + idBtn as string + "[b].pos = " + [1090,10] as string + " + [(b - 1) * 60,0]" + "\r\n"
			str += "		)"
			str += "	)"
			str += ")"
		)
		execute str
	)

	fn fnSwitchMsBtn idMsBtn =
	(
		strMsBtn = idMsBtn as string
		execute ("arrMsTemp = for i in iniArrMyScripts" + strMsBtn + " collect i")
	)

	fn fnSwitchToolBtnChecked Btn =
	(
		arrToolsBtn = #(rolBsKeyTools.ckbC1,rolBsKeyTools.ckbC2,rolBsKeyTools.ckbC3,rolBsKeyTools.ckbC4)
		arrBtn = arrToolsBtn
		for i = 1 to arrBtn.count do
		(
			if i != Btn then 
			(
				arrBtn[i].checked = false
			)
			else 
			(
				idBtn = Btn
				arrBtn[Btn].checked = true
			)
		)
	)

	fn fnIsBipRoot obj = 
	(
		if ((classof obj.baseobject) == Biped_Object) do 
		(
			if (obj.controller.rootNode == obj) do (return true)
		)
		return false
	)

	fn fnBipedScale =
	(
		if (selection.count != 0) then 
		(
			for i in selection as Array do
			(
				if ((fnIsBipRoot i) == false) then 
				(
					subAnimSelected = getSubAnimName (i.transform.controller[1][1]) 1
					undo "addDelBipedScale" on
					(
						if (subAnimSelected == #ScaleXYZ) then 
						try (i.transform.controller[1][1].delete 1)catch()
						else if (subAnimSelected == #available) then 
						(
							try
							(
								rootnodeSelected = i.transform.controller.rootnode
								rootnodeSelected.transform.controller.enableSubAnims = true
								i.transform.controller[1][1][1].controller = ScaleXYZ ()
							)catch()
						)
					)
				)
			)
		)
	else (messagebox "请选择一根或多根 Biped 骨骼!    \r\n" beep:false title:"选择有误！")
	)

	Fn fnCleanOutRangeKeys inputObject =  ---清理无限帧,以前收集的,找不到来源了,大概是遍历子动画
	(
		startTime = AnimationRange.Start
		endTime = AnimationRange.End
		for i = 1 to inputObject.numSubs do
		(
			tempSubAnim = GetSubAnim inputObject i
			tempController = tempSubAnim.Controller
			
			if tempController != undefined do
			(
				tempKeyList = tempController.Keys
				
				outEndKeysIndex = for i = 1 to tempKeyList.Count where tempKeyList[i].Time > endTime collect i
				if outEndKeysIndex.Count > 0 do for i = 1 to outEndKeysIndex.Count do DeleteKey tempKeyList tempKeyList.count
				
				outStartKeysIndex = for i = 1 to tempKeyList.Count where  tempKeyList[i].Time < startTime collect i
				for i = 1 to outStartKeysIndex.Count do DeleteKey tempKeyList 1
			)
			if tempSubAnim.numSubs > 0 do fnCleanOutRangeKeys tempSubAnim
		)
	)

	-- fn fnDelSelKeys =
	-- (
	-- 	for o in selection where (o.ishidden == false) do 
	-- 	(
	-- 		if (classof o == Biped_Object) then
	-- 		(
	-- 			if classof o.controller == Vertical_Horizontal_Turn then  --清理质心帧
	-- 			(
	-- 				biped.deleteKeys o.controller.vertical #selection
	-- 				biped.deleteKeys o.controller.horizontal #selection
	-- 				if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
	-- 					(biped.deleteKeys o.controller.flip #selection)
	-- 					else(biped.deleteKeys o.controller.turning #selection)
	-- 			)
	-- 			else if classof o.controller == BipSlave_Control then  --清理biped正常帧
	-- 			(
	-- 				biped.deleteKeys o.controller #selection
	-- 				subanimBipedScale = GetSubAnim o.controller[1] 1
	-- 				if ((subanimBipedScale != undefined) and \
	-- 				(GetSubAnimName subanimBipedScale 1 == #ScaleXYZ)) then  --清理biped的缩放针
	-- 				(
	-- 					deleteKeys subanimBipedScale.controller #selection
	-- 				)
	-- 			)
	-- 		)
	-- 		else (deleteKeys o #selection)   ---清理非biped帧
	-- 	)
	-- )

	fn fnDelAllDecimalKeys arrAllKey = 
	(
		local arrDelKeyIndex = #()
		for i in arrAllKey do ----获取小数帧的帧数
		(
			if (int(i) as time) != i then appendIfUnique arrDelKeyIndex i
		)
		for o in objects do 
		(
			deselectKeys o --取消之前选择的帧防止误删
			for k in arrDelKeyIndex do
			(
				case of 
				(
					(classof o.controller == Vertical_Horizontal_Turn): --删除Biped质心小数帧
					(
						selectkeys o.controller.vertical k
						selectkeys o.controller.horizontal k
						if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
						(selectkeys o.controller.flip k)
						else(selectkeys o.controller.turning k)
						biped.deleteKeys o.controller.vertical #selection
						biped.deleteKeys o.controller.horizontal #selection
						if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
						(biped.deleteKeys o.controller.flip #selection)
						else(biped.deleteKeys o.controller.turning #selection)
					)
					(classof o.controller == BipSlave_Control):
					(
						selectkeys o.controller k
						biped.deleteKeys o.controller #selection  --清理biped正常小数帧
						subanimBipedScale = GetSubAnim o.controller[1] 1
						if ((subanimBipedScale != undefined) and \
						(GetSubAnimName subanimBipedScale 1 == #ScaleXYZ)) then  --清理biped的缩放小数针
						(
							selectkeys subanimBipedScale.controller k
							deleteKeys subanimBipedScale.controller #selection
						)
					)
					default:(selectkeys o k;deleteKeys o #selection)   ---清理非biped帧
				)
			)
		)
	)

	fn fnAddAllSubsKeys tempObj =
	(
		for i = 1 to tempObj.numSubs do
		(
			tempSubAnim     = GetSubAnim tempObj i
			tempSubAnimName = getSubAnimName tempObj i
			tempController  = tempSubAnim.Controller
			
			if tempController != undefined do
			(
				for j in tempController.Keys do
				(
					if (tempSubAnimName == #Link_Times or tempSubAnimName == ("链接时间" as name)) then
					(
						appendIfUnique arrLinkKeys j  ---------添加link帧到数组
					)
					appendIfUnique arrKeysTime j.time
					appendIfUnique arrBlockingKeys j.time
					if j.selected == true then (appendIfUnique arrKeysSelected j.time)
				)
			)
			if tempSubAnim.numSubs > 0 do fnAddAllSubsKeys tempSubAnim
		)
	)

	-- -- fn fnAddLinkKeys tempObj =
	-- -- (
	-- 	fn fnAddLinkTimesKeys tempObj i=     --添加linkTimes关键帧
	-- 	(
	-- 		-- for i = 1 to tempObj.controller.numsubs do 
	-- 		-- (
	-- 			if ((GetSubAnimName tempObj.controller i) == #Link_Times or (GetSubAnimName tempObj.controller i) == ("链接时间" as name)) then
	-- 			(
	-- 				if tempObj.controller[i].keys[1] != undefined then
	-- 				(
	-- 					for i in tempObj.controller[i].keys do 
	-- 					(
	-- 						appendIfUnique arrLinkKeys i  ---------添加link帧到数组
	-- 						appendIfUnique arrKeysTime i.time
	-- 						appendIfUnique arrBlockingKeys i.time
	-- 						if i.selected == true then (appendIfUnique arrKeysSelected i.time)
	-- 					)
	-- 				)
	-- 			)
	-- 		-- )
	-- 	)
	-- 	fn fnAddLinkParamsKeys tempObj i=   ----添加LinkParams下面的Transform帧
	-- 	(
	-- 		local tempLinkController
	-- 		local keyTimeStartTemp
	-- 		local keyTimeEndTemp
			
	-- 		-- for i = 1 to tempObj.controller.numsubs do 
	-- 		-- (
	-- 			if ((GetSubAnimName tempObj.controller i) == #Link_Params) then
	-- 			(
	-- 				tempLinkController = tempObj.controller[i]
	-- 				if tempLinkController[1] != undefined then
	-- 				(
	-- 					for i = 1 to tempLinkController.numsubs do -----link属性的bone下面的prs帧------
	-- 					(
	-- 						if (((tempLinkController[i]).name == "Position") or \
	-- 						((tempLinkController[i]).name == "Rotation") or \
	-- 						((tempLinkController[i]).name == "Scale")) then
	-- 						(
	-- 							if tempLinkController[i].keys[1] != undefined then
	-- 							(
	-- 								keyTimeStartTemp = tempLinkController[i].keys[1].time
	-- 								keyTimeEndTemp = tempLinkController[i].keys[tempLinkController[i].keys.count].time
	-- 								appendIfUnique arrKeysTime keyTimeStartTemp
	-- 								appendIfUnique arrKeysTime keyTimeEndTemp
	-- 								for i in tempLinkController[i].keys do 
	-- 								(
	-- 									appendIfUnique arrBlockingKeys i.time
	-- 									if i.selected == true then (
	-- 										appendIfUnique arrKeysSelected i.time
	-- 									)
	-- 								)
	-- 							)
	-- 						)
	-- 					)
	-- 				)
	-- 			)
	-- 		-- )
	-- 	)
	-- 	-- fnAddLinkTimesKeys tempObj
	-- 	-- fnAddLinkParamsKeys tempObj
	-- -- )

	-- fn fnAddPrsKeys tempObj i=  ---------添加正常非biped的prs帧(没加link),i是子动画ID,后面用到,提前传入减少遍历
	-- (
	-- 	local keyTimeStartTemp
	-- 	local keyTimeEndTemp
		
	-- 	-- for i = 1 to tempObj.controller.numsubs do 
	-- 	-- (
	-- 		if (((tempObj.controller[i]).name == "Position") or \
	-- 		((tempObj.controller[i]).name == "Rotation") or \
	-- 		((tempObj.controller[i]).name == "Scale")) then
	-- 		(
	-- 			if tempObj.controller[i].keys[1] != undefined then
	-- 			(
	-- 				keyTimeStartTemp = tempObj.controller[i].keys[1].time
	-- 				keyTimeEndTemp = tempObj.controller[i].keys[tempObj.controller[i].keys.count].time
	-- 				appendIfUnique arrKeysTime keyTimeStartTemp
	-- 				appendIfUnique arrKeysTime keyTimeEndTemp
	-- 				for i in tempObj.controller[i].keys do 
	-- 				(
	-- 					appendIfUnique arrBlockingKeys i.time
	-- 					if i.selected == true then (
	-- 						appendIfUnique arrKeysSelected i.time
	-- 					)
	-- 				)
	-- 			)
	-- 		)
	-- 	-- )
	-- )

	fn fnAddBipedKeys tempObj =  ---------收集Biped帧
	(
		local keyTimeStartTemp
		local keyTimeEndTemp
		local subanimBipedScale

		if classof tempObj.controller != Footsteps then
		(
			if classof tempObj.controller != Vertical_Horizontal_Turn then
			(
				--筛选出非质心的biped帧
				fnAddAllSubsKeys tempObj
				-- if (tempObj.controller.keys[1] != undefined) then
				-- (
				-- 	for i in tempObj.controller.keys do 
				-- 	(
				-- 		appendIfUnique arrKeysTime i.time   ---添加到数组
				-- 		appendIfUnique arrBlockingKeys i.time
				-- 		if i.selected == true then (
				-- 			appendIfUnique arrKeysSelected i.time
				-- 		)
				-- 	)
				-- )
				-- subanimBipedScale = GetSubAnim tempObj.controller[1] 1
				-- if ((subanimBipedScale != undefined) and \
				-- (GetSubAnimName subanimBipedScale 1 == #ScaleXYZ)) then  ----筛选出biped的缩放帧
				-- (
				-- 	if subanimBipedScale[1].keys[1] != undefined then
				-- 	(
				-- 		keyTimeStartTemp = subanimBipedScale[1].keys[1].time
				-- 		keyTimeEndTemp = subanimBipedScale[1].keys[subanimBipedScale[1].keys.count].time
				-- 		appendIfUnique arrKeysTime keyTimeStartTemp
				-- 		appendIfUnique arrKeysTime keyTimeEndTemp
				-- 		for i in subanimBipedScale[1].keys do 
				-- 		(
				-- 			appendIfUnique arrBlockingKeys i.time
				-- 			if i.selected == true then (
				-- 				appendIfUnique arrKeysSelected i.time
				-- 			)
				-- 		)
				-- 	)
				-- )
			)
			else
			(-------------------下面是收集质心的关键帧,坑在于中英文turning名字还不一样...
				if classof tempObj.controller == Vertical_Horizontal_Turn then
				(
					bipCtrl  = tempObj.controller
					vertCtrl = bipCtrl.vertical.controller
					horzCtrl = bipCtrl.horizontal.controller
					if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
						(turnCtrl = bipCtrl.flip.controller)
						else(turnCtrl = bipCtrl.turning.controller)
					bipCtrlTemp = #(vertCtrl,horzCtrl,turnCtrl)
					for c in bipCtrlTemp do
					(
						if c.keys[1] != undefined then
						(
							keyTimeStartTemp = c.keys[1].time
							keyTimeEndTemp = c.keys[c.keys.count].time
							appendIfUnique arrKeysTime keyTimeStartTemp
							appendIfUnique arrKeysTime keyTimeEndTemp
							for i in c.keys do 
							(
								appendIfUnique arrBlockingKeys i.time
								if i.selected == true then (
									appendIfUnique arrKeysSelected i.time
								)
							)
						)
					)
				)
			)
		)
	)
-- 去掉 link 判断 fnLink
	fn fnAddKyes tempObj =   ---添加帧(主要是首尾帧),加个判断是否勾选link
	(	
		if (classof tempObj != Biped_Object) then
		(
			-- if tempObj.controller != undefined then
			-- (
			-- 	if (classof tempObj.controller) == prs then
			-- 	(
			-- 		for i = 1 to tempObj.controller.numsubs do 
			-- 		(
			-- 			fnAddPrsKeys tempObj i        ---非biped物体的位移旋转缩放帧
			-- 		)
			-- 	)
			-- 	if (classof tempObj.controller) == Link_Constraint then
			-- 	(
			-- 		for i = 1 to tempObj.controller.numsubs do 
			-- 		(
			-- 			if fnLink == 1 then (fnAddLinkTimesKeys tempObj i)         ---------link属性的物体link帧和非link帧
			-- 			fnAddLinkParamsKeys tempObj i
			-- 		)
			-- 	)
			-- )
			fnAddAllSubsKeys tempObj ---非 Biped 的物体所有子动画帧
		)
		else
		(
			fnAddBipedKeys tempObj   ---------biped帧
		)

		-- arrKeysTime = makeUniqueArray arrKeysTime  ---去除重复帧数
		sort arrKeysTime  ----帧数排序
		sort arrKeysSelected
		if (arrKeysTime.count != 0) then
		(
			case of 
			(
				(arrKeysTime.count > 1):
				(
					keyFirst = arrKeysTime[1]            ------找到首帧
					keyEnd = arrKeysTime[arrKeysTime.count]   -----------找到尾帧
				)
				(arrKeysTime.count == 1):   --防止首尾同帧的保险
				(
					keyFirst = arrKeysTime[1]
					keyEnd = keyFirst + 1
				)
			)
		)
		if (arrKeysSelected.count != 0) then
		(
			case of 
			(
				(arrKeysSelected.count > 1):
				(
					keySelFirst = arrKeysSelected[1]            ------找到首帧
					keySelEnd = arrKeysSelected[arrKeysSelected.count]   -----------找到尾帧
				)
				(arrKeysSelected.count == 1):   --防止首尾同帧的保险
				(
					keySelFirst = arrKeysSelected[1]
					keySelEnd = keySelFirst + 1
				)
			)
		)
	)

	fn fnCollectKeys = ---------收集关键帧
	(
		arrKeysTime     = #()
		arrKeysSelected = #() ----------------先清空数组
		arrLinkKeys     = #()
		arrBlockingKeys = #()
		case of  -----------处理选中,未选中则处理全部
		(
			(selection.count == 0):
			(
				for i in (objects as array) where (i.ishidden == false) do 
				(
					fnAddKyes i
				)
			)
			default:
			(
				for i in (selection as array) where (i.ishidden == false) do 
				(
					fnAddKyes i
				)
			)
		)
	)

	fn fnSelLinkKeys keyFirst KeyEnd symbol =  ---------------选择link帧方法
	(
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do   -------link帧选中
			(
				i.selected = false ---先取消之前link帧选中状态
				case of  -------------判断link帧位置,数字是随便取的方便判断情况
				(
					(symbol == 0):(if i.time <= KeyEnd then i.selected = true)
					(symbol == 1):(if i.time >= keyFirst then i.selected = true)
					(symbol == 2):(i.selected = true)
				)
			)
		)
	)

	fn fnSelKeys keyFirst KeyEnd symbol =  ---------------选择帧的方法
	(
		fn fnSelectKeys keyFirst KeyEnd symbol =  -------因为有选中和没选择状态, 所以加一个方法精简下
		(
			for i in objects where (i.ishidden == false) do deselectKeys i          --清除之前选中的关键帧
			if arrKeysTime.count != 0 then
			(
				selectkeys $ keyFirst KeyEnd  -------------选中正常帧
				-- if rolBsKeyTools.chkJudgeLinkKey.state == true then
				-- (
					fnSelLinkKeys keyFirst KeyEnd symbol --------------选中link帧
				-- )
			)
			else
			(
				-- if rolBsKeyTools.chkJudgeLinkKey.state == true then
				-- (
					fnSelLinkKeys keyFirst KeyEnd symbol
				-- )
			)
		)
		case of 
		(
			(selection.count == 0):  ----------判断是否有选中物体
			(
				actionMan.executeAction 0 "40021"    ---没有选择物体则选择所有物体
				fnSelectKeys keyFirst KeyEnd symbol
			)
			default:  ----------------
			(
				fnSelectKeys keyFirst KeyEnd symbol
			)
		)
	)

	mapped fn fnMoveKeysAndLinkKeys obj offset =  ----https://forums.cgsociety.org/t/moving-keys-from-link-constraint-keys-access/1575053
	(
		local arrTargetID  = #()
		moveKeys obj offset #selection  ---先移动非link帧
		-- if rolBsKeyTools.chkJudgeLinkKey.state == true then 
		-- (
			if classof obj.controller == Link_Constraint do
			(
				nTargets = obj.controller.getNumTargets()  ---得到link的帧数量

				if nTargets > 0 do
				(
					--排序 link 帧
					obj.controller.setFrameNo 1 (obj.controller.getFrameNo 1)

					-- for i = nTargets to 1 by -1 do  ------如果大于0则从最后link帧开始移
					-- (
					-- 	fNumber = obj.controller.getFrameNo i
					-- 	if ((fNumber >= keySelFirst) and (fNumber <= keySelEnd)) then
					-- 	(
					-- 		appendIfUnique arrTargetID i
					-- 	)
					-- )
					if offset > 0 then  --------判断向前还是向后移动帧
					(
						for i = nTargets to 1 by -1 do  ------如果大于0则从最后link帧开始移
						(
							fNumber = obj.controller.getFrameNo i
							obj.controller.setFrameNo i (fNumber + offset)
						)
					)
					else
					(
						for i = 1 to nTargets do  ---如果移动帧小于0,从第一个link帧开始移
						(
							fNumber = obj.controller.getFrameNo i
							obj.controller.setFrameNo i (fNumber + offset)
						)
					)
				)
			)
		-- )
	)

	-- fn fnSplitSelBiped = --分开选择四肢和身体,例如同一条手臂只选择最父级的(方便移动帧)
	-- (
	-- 	arrSelBiped = for i in selection where classof i.controller == BipSlave_Control collect i 

	-- )

	fn fnMoveBipedKeys offsetFrame =  -------移动Biped帧
	(
		bipedRoot = #()   -------判断选择了几个biped骨架
		for i in selection where ((classof i == Biped_Object) and (i.ishidden == false)) do  
		(
			appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
		)
		for c in bipedRoot do  ---按每个骨架处理
		(
			ctrlBiped = c.controller
			bipedAll = #(biped.getNode ctrlBiped #pelvis, -----四肢同帧处理,只处理他首节biped
						biped.getNode ctrlBiped #spine,
						biped.getNode ctrlBiped #neck,
						biped.getNode ctrlBiped #larm,
						biped.getNode ctrlBiped #rarm,
						biped.getNode ctrlBiped #lleg,
						biped.getNode ctrlBiped #rleg,
						biped.getNode ctrlBiped #prop1,
						biped.getNode ctrlBiped #prop2,
						biped.getNode ctrlBiped #prop3,
						biped.getNode ctrlBiped #tail)

			vertCtrl = ctrlBiped.vertical.controller  -----质心ctrl关键帧
			horzCtrl = ctrlBiped.horizontal.controller
			if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
			(turnCtrl = ctrlBiped.flip.controller)
			else(turnCtrl = ctrlBiped.turning.controller)
			bipCtrlTemp = #(vertCtrl,horzCtrl,turnCtrl)
			for c in bipCtrlTemp do
			(
				biped.moveKeys c offsetFrame #selection  -----移动选定的质心帧
			)
			for nodeBiped in bipedAll where nodeBiped != undefined do  -----移动其他biped的选定帧
			(
				biped.moveKeys nodeBiped.controller offsetFrame #selection
			)
		)
	)		

	mapped fn fnMoveBipedScaleKeys tempObj offsetFrame =  -------移动biped的缩放帧
	(
		ctrlBiped = tempObj.controller
		if classof ctrlBiped == BipSlave_Control then  --------下面判定子动画是否为scaleXYZ
		(
			if ((ctrlBiped[1][1] != undefined) and ((getSubAnimName ctrlBiped[1][1] 1) == #ScaleXYZ)) then
			(
				movekeys ctrlBiped[1][1][1] offsetFrame #selection
			)
		)
	)

	fn fnMoveAllKeys keyMovedOffset fnRange:off =
	(
		local rangEnd = animationrange.end
		local rangeStart = animationrange.start
		local n = 0  --n来判定是否有选中biped

		if keyMovedOffset != undefined and keySelFirst != undefined and keySelEnd != undefined then
		(
			if selection.count != 0 then
			(
				for i in selection where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset
					)
					else 
					(
						fnMoveBipedScaleKeys i keyMovedOffset
						n += 1
					)
				)
				if n != 0 then  ----------分开解决biped多移动的问题,傻瓜式方法
				(
					fnMoveBipedKeys keyMovedOffset
				)
			)
			else  ---跟上面一样,只是对所有物体
			(
				for i in objects where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset
					)
					else fnMoveBipedScaleKeys i keyMovedOffset
				)
				fnMoveBipedKeys keyMovedOffset
			)
			if fnRange == on then
			(
				if keyMovedOffset > 0 then 
				(
					rangEnd = animationrange.end + keyMovedOffset
					animationrange = interval animationrange.start rangEnd
				)
				else if keyMovedOffset < 0 then 
				(
					rangeStart = animationrange.start + keyMovedOffset
					animationrange = interval rangeStart animationrange.end
				)
			)
			keySelFirst += keyMovedOffset
			keySelEnd  += keyMovedOffset
		)
	)

	fn fnAddTrajLayer strlayerName templayerTarget =
	(
		if (LayerManager.getLayerFromName strlayerName) != undefined then
		(
			templayerTarget = LayerManager.getLayerFromName strlayerName
		)
		else templayerTarget = LayerManager.newLayerFromName strlayerName
		templayerTarget.lock = on
		templayerTarget
	)

	fn fnAddBipedTraj tempBiped =
	(
		pointTraj = point name:("Traj_" + tempBiped.name) size:0 cross:true 
		appendIfUnique arrTraj pointTraj
		freeze pointTraj
		arrBipedSonTemp = tempBiped.children
		bipedTarget = arrBipedSonTemp[(arrBipedSonTemp.count + 1)/2]
		pointTraj.transform = bipedTarget.transform
		pointTraj.parent = tempBiped
		layerTraj.addNode pointTraj
		deleteKeys pointTraj #allKeys
		pointTraj.showTrajectory = true
		-- ResetXForm pointTraj
	)

	fn fnDeleteTraj tempBiped =
	(
		local deleteTraj
		local deleteTrajName = ("Traj_" + tempBiped.name)
		local deleteTraArrID = findItem arrTraj deleteTrajName
		if deleteTraArrID != 0 then
		(
			deleteTraj = arrTraj[deleteTraArrID]
			deleteItem arrTraj deleteTraArrID
		)
		if (getNodeByName deleteTrajName) != undefined then (delete (getNodeByName deleteTrajName))
	)

	fn fnBSQuickSave =
	(
		local strCurFilePath    = (maxFilePath + maxFileName)
		local strCurFileName    = getFilenameFile maxFileName
		local strBackupPathRoot = maxFilePath + strCurFileName + ".backup"
		local arrBackupFiles = getfiles (strBackupPathRoot + "\\*.max")
		qsort arrBackupFiles fnPseudoNaturalSort
		-- print arrBackupFiles

		if matchpattern strCurFilePath pattern:("*.backup\\*.max") then 
		(
			strBackupPathRoot = maxFilePath
			arrBackupFiles    = getfiles (strBackupPathRoot + "\\*.max")
			qsort arrBackupFiles fnPseudoNaturalSort
			strSaveFileName   = getFilenameFile arrBackupFiles[arrBackupFiles.count]
			arrEndCountFilter = (filterString strSaveFileName "_")
			strSaveCount      = ((execute arrEndCountFilter[arrEndCountFilter.count])) as string
			strSaveName       = substring strSaveFileName 1 (strSaveFileName.count - strSaveCount.count - 1)
			strSaveCount      = ((execute strSaveCount) + 1) as string
			strBackupFilePath = strBackupPathRoot + "\\" + strSaveName + "_" + strSaveCount + ".max"
			saveMaxFile strBackupFilePath
			displayTempPrompt ("已备份并打开：" + strBackupFilePath) 10000
			messagebox ("当前备份的是已备份文件，请注意跟源文件对比新旧！\r\n\r\n可能的源文件：" + strSaveName + ".max\r\n\r\n刚才备份的文件：" + strCurFileName + ".max                                                                           ") title:"BsKeyTools"
		) 
		else
		(
			if (not (SIODir.Exists strBackupPathRoot))
			do (SIODir.CreateDirectory strBackupPathRoot)
			if arrBackupFiles.count == 0 then 
			(
				strSaveCount = "1"
			) 
			else if arrBackupFiles.count > 0 then
			(
				strSaveFileName   = getFilenameFile arrBackupFiles[arrBackupFiles.count]
				arrEndCountFilter = (filterString strSaveFileName "_")
				strSaveCount      = ((execute arrEndCountFilter[arrEndCountFilter.count]) + 1) as string
			)
			strBackupFilePath = strBackupPathRoot + "\\" + strCurFileName + "_" + strSaveCount + ".max"
			-- saveMaxFile strCurFilePath
			if (not (SIOFile.Exists strBackupFilePath)) do
			(
				try 
				(
					-- SIOFile.Copy strCurFilePath strBackupFilePath
					-- FileIO.Copyfile strCurFilePath strBackupFilePath UIOption
					saveMaxFile strBackupFilePath clearNeedSaveFlag:false useNewFile:false
					displayTempPrompt ("已备份至：" + strBackupFilePath) 10000 
				)
				catch()
			)
		)
	)

	fn fnCutDisplayKeyRange keyFirst keyEnd isSelected:false =  ---显示首尾帧范围
	(
		if ((keyFirst != undefined) and (keyEnd != undefined)) then
		(
			if (arrKeysTime.count != 0) then
			(
				if not isSelected then
				(
					if (arrLinkKeys.count != 0) then
					(
						case of  ------万恶的link帧导致更多判定
						(
							((arrLinkKeys[1].time >= keyFirst) and (arrLinkKeys[arrLinkKeys.count].time <= keyEnd)):
							(animationrange = (interval keyFirst keyEnd))
							((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time <= keyEnd)):
							(animationrange = (interval arrLinkKeys[1].time keyEnd))
							((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time >= keyEnd)):
							(animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time))
							((arrLinkKeys[1].time >= keyFirst) and (arrLinkKeys[arrLinkKeys.count].time > keyEnd)):
							(animationrange = (interval keyFirst arrLinkKeys[arrLinkKeys.count].time))
							((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time > keyEnd)):
							(animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time))
						)
					)
					else
					(
						animationrange = interval keyFirst keyEnd
					)
				)
				else animationrange = interval keyFirst keyEnd
			)
			else 
			(
				if ((arrLinkKeys.count != 0) and (arrLinkKeys.count > 1)) then 
				(
					animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time)
				)
				else 
				(
					if (arrLinkKeys.count == 1) then
					(
						animationrange = (interval arrLinkKeys[1].time (arrLinkKeys[1].time + 1))
					)
				)
			)
		)
	)

	fn fnGetPlaySpeedValue =
	(
		case of
		(
			(timeConfiguration.playbackSpeed == 1):(return 0.25)
			(timeConfiguration.playbackSpeed == 2):(return 0.5)
			(timeConfiguration.playbackSpeed == 3):(return 1)
			(timeConfiguration.playbackSpeed == 4):(return 2)
			(timeConfiguration.playbackSpeed == 5):(return 4)
		)
	)

	-- https://cafe.naver.com/pinksox/6131
	-- 优化支持 bone

	fn FramToMilisecond frame = 
	(
		return ((((frame - animationRange.start) as integer) * (10.0 / 48.0) * fnGetPlaySpeedValue()) as integer)
    )

	fn AppendKeyTimeArray m_PBKeyMiliSecArray keys = 
	(
        if keys.count == 0 do return()
        for i = 1 to keys.count do (
            if (keys[i] >= animationRange.start) AND (keys[i] <= animationRange.end) do (
                appendifUnique m_PBKeyMiliSecArray (FramToMilisecond keys[i])
                appendifUnique m_PBKeyTimeArray keys[i]
            )
        )
        appendifUnique m_PBKeyMiliSecArray (FramToMilisecond animationRange.start)
        appendifUnique m_PBKeyTimeArray animationRange.start
        appendifUnique m_PBKeyMiliSecArray (FramToMilisecond animationRange.end)
        appendifUnique m_PBKeyTimeArray animationRange.end
	)

	fn StopBlocking = 
	(
        clock.active = false
        ckbPlayBlocking.state = false
        ckbPlayBlocking.text = "跳帧播"
	)

	fn PlayBlocking = 
	(
		fnCollectKeys ()
		m_PBKeyTimeArray = #()
		m_PBKeyMiliSecArray = #()
		local nowTime = timeStamp()
		AppendKeyTimeArray m_PBKeyMiliSecArray arrBlockingKeys
		if m_PBKeyMiliSecArray.count == 0 do (
			StopBlocking()
			return()
		)
		
		if (isAnimPlaying()) do (
			stopAnimation()
		)		
		
		sort m_PBKeyTimeArray
		sort m_PBKeyMiliSecArray
		m_PBPointer = 1
		while (m_PBKeyTimeArray[m_PBPointer] < sliderTime) do (m_PBPointer += 1)

		m_PBStartTime = timeStamp() - (FramToMilisecond sliderTime)
		sliderTime = m_PBKeyTimeArray[m_PBPointer]
		clock.active = true
		ckbPlayBlocking.text = "停止!"
	)

	fn ReplayBlocking = 
	(
		m_PBPointer = 1
		m_PBStartTime = timeStamp()
		sliderTime = m_PBKeyTimeArray[m_PBPointer]
	)

	fn fnGetAllBipedTwist =
	(
		arrBipedRootAll = $'Bip00?'
		arrBipedTwistAll = #()
		for r in arrBipedRootAll do
		(
			nn = biped.maxTwistNodes r
			nl = biped.maxTwistLinks r
			ts = biped.getTwistStartId r
			
			for i = ts to ts+nn-1 do
			(
				anode = biped.getNode r i
				if anode != undefined do
				(
				for j = 1 to nl do
					(
						alink = biped.getNode r i link:j
						if alink != undefined do
						(
							appendIfUnique arrBipedTwistAll alink
						)
					)
				)
			)
		)
		for j in arrBipedTwistAll where j != undefined do
		(
			j.isHidden = not (j.isHidden)
		)
	)

	fn fnOrthoToPersp =
	(
		--DON'T CONVERT VIEWPORT IF ORBITING / PANNING
		mouseControl = (dotNetClass "Control")
		mouseDown = dotnet.CompareEnums mouseControl.MouseButtons.value__ mouseControl.MouseButtons.Middle.value__
		
		if not mouseDown and viewport.getType() == #view_iso_user do
		(
			viewport.setType #view_persp_user
			ForceCompleteRedraw()
		)
	)

	on rolBsKeyTools open do  ----打开脚本时操作
	(
		-- panelMyTools.backcolor = BsDotBackColor
		-- panelMyTools.autoScroll = true
		-- fnAddDotButton()
		arrNewCostTime 		= iniCostTime
		lblLink.font        = BsDotFont
		lblLink.backcolor   = BsDotBackColor
		lblLink.forecolor   = BsDotForeColor
		fnSwitchToolBtnName()
		fnSetBtnPrimogem()
		------刷新图标, 图标是max自带的,主要是懒得做
		btnSelBeforeKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,3,3,3,3,true,true) 
		btnSelAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,11,11,11,11,true,true) 
		btnSelAllKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,26,26,26,26,true,true)
		-- btnMoveKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,21,21,21,21,true,true)
		-- btnMoveAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,13,13,13,13,true,true)
		-- dotnet.AddEventHandler myTimer #elapsed fnRefreshHelpText
		-- myTimer.Start()
		-- timeDIsTemp      = timeDisplayMode  ----小数帧还是整数帧
		-- iniPos = (GetDialogPos rolBsKeyTools) 
		stLoadConfigAll.fnLoadConfigBsKeyToolsAll ()  ---------------脚本位置赋值
		stSetConfigAll.fnSetConfigBsKeyTools ()  ----------------保存位置信息到ini文件
		fnReloadToolsBtn()
		-- if(switchMSPanel == 0) then (ckbSwitchMyScripts.checked = false)
		-- else (ckbSwitchMyScripts.checked = true)
		fnRefPlaySpeedValue ()  -----判断播放速度
		fnBsRefFps ()
		-- fnRefreshMsPanel ()
		-- if (switchToolPanel == 1) then
		-- (
		-- )
		ckbIsoSelection.state = IsolateSelection.IsolateSelectionModeActive()
		ckbPlayBlocking.state = false
		clock.active = false
		ckbPerspLock.state = tooglePersp
		fnRefreshRecentFileList()
		menuConfig.fnLoadDockPos rolBsKeyTools widthBsSize heightBsSize
		fnSwitchToolsBtn idBtn
		fnSwitchToolBtnChecked idBtn
		if not rolBsKeyTools.dialogBar then fnRefreshMagicBtn ()
		if iniIsIcon do fnSwitchIconStyle()
		if (iniBsAutoCheckUpdate == true) then 
		(fnAutoCheckVersion curVerBsKeyTools verUrlBsKeyTools dlUrlBsKeyTools dlFileBsKeyTools)
		if iniCollopseType == 1 or iniCollopseType == 2 then
		(
			tempTogglePanelPos = (getDialogPos rolBsKeyTools)
			SetINISetting BulletConfig "BsTogglePanelSet"  "TogglePanelPos" (tempTogglePanelPos as string)
			rolBsKeyTools.height = 0
			try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BsTogglePanel.ms"))
			catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
		)
		-- print ("iniBsAutoCheckUpdate: " + iniBsAutoCheckUpdate as string)
	)
	
	on rolBsKeyTools close do -- 关闭记忆浮动窗口位置
	(
		iniPos = (GetDialogPos rolBsKeyTools)
		stSetConfigAll.fnSetConfigBsKeyTools ()
		try (callbacks.removeScripts #animationRangeChange id:#BsUpdateTimeRange) catch ()
		try (callbacks.removeScripts #filePostOpen id:#BsUpdateFps) catch ()
		try (callbacks.removeScripts #timeunitsChange id:#BsUpdateFps) catch ()
		try (callbacks.removeScripts #filePostOpen id:#BsUpdatePlaySpeed) catch ()
		try (callbacks.removeScripts #timeunitsChange id:#BsUpdatePlaySpeed) catch ()
		try (callbacks.removeScripts #filePostOpen id:#BsRefreshRecentFiles) catch ()
		try(destroydialog rolTogglePanel)catch()
		unRegisterRedrawViewsCallback fnOrthoToPersp
		tooglePersp = false
	)
	-----------------------------------------------------------------------------------------
	on rolBsKeyTools rbuttondown pos do 
	(
		popupMenu menuConfig pos:(GetDialogPos rolBsKeyTools)
	)

	on btnConfig changed state do 
	(
		btnConfig.state = true
		popupMenu menuConfig pos:(GetDialogPos rolBsKeyTools)
	)

	on btnConfig rightclick do 
	(
		btnConfig.state = true
		popupMenu menuConfig pos:(GetDialogPos rolBsKeyTools)
	)

	-- on rolBsKeyTools mbuttondown pos do 
	-- (
	-- 	try(cui.UnRegisterDialogBar rolBsKeyTools) catch()
	-- 	try (destroydialog rolBsKeyTools) catch ()
	-- )
	
	on rolBsKeyTools lbuttondown posMou do
	(
		setSysCur #move
		posMouMoved = posMou
		switchMouseState = on
	)
	
	on rolBsKeyTools lbuttonup posMou do
	(
		switchMouseState = off
		iniPos = (GetDialogPos rolBsKeyTools)
		stSetConfigAll.fnSetConfigBsKeyTools()
	)
	
	on rolBsKeyTools mouseMove pos do
	(
		if not rolBsKeyTools.dialogBar then
		(
			-- myTimer.Start()
			if (ui_clientOffset == undefined) and (switchMouseState == off) then 
			(ui_clientOffset = pos - (mouse.screenPos - (getDialogPos rolBsKeyTools)))
			if switchMouseState == on then
			(
				SetDialogPos rolBsKeyTools (mouse.screenpos - posMouMoved)
			)
		)
	)

	on timerTickTock tick do 
    (
        if (ui_clientOffset != undefined) and (iniCollopseType == 1 or iniCollopseType == 2) then 
		(
            local mouseClientPos = mouse.screenPos - (getDialogPos rolBsKeyTools) + ui_clientOffset
            
            local dialogPos = getDialogPos rolBsKeyTools
            local dialogBox = 
			(if switchToolPanel == 1 then (Box2 (dialogPos.x - 30) (dialogPos.y - 30) (rolBsKeyTools.width + 60) (rolBsKeyTools.height + 60))
			else (Box2 (dialogPos.x - 30) (dialogPos.y - 30) (rolBsKeyTools.width + 360)  (rolBsKeyTools.height + 60)))

			if not (contains dialogBox mouse.screenPos) then
			(
				if rolTogglePanel == undefined or rolTogglePanel.open == false then 
				(
					SetINISetting BulletConfig "BsTogglePanelSet"  "TogglePanelPos" ((getDialogPos rolBsKeyTools) as string)
					rolBsKeyTools.height = 0
					try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BsTogglePanel.ms"))
					catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
				)
				else 
				(
					rolTogglePanel.timerTickTock.active = true
					SetDialogPos rolTogglePanel (getDialogPos rolBsKeyTools)
					if iniCollopseType == 1 then 
					(
						rolTogglePanel.height = 30
						rolTogglePanel.width  = 355
					) 
					else 
					(
						rolTogglePanel.height = 100
						rolTogglePanel.width  = 355
					)
					rolTogglePanel.lblOneWord.height = (rolTogglePanel.height - 4)
					rolTogglePanel.lblOneWord.width  = (rolTogglePanel.width - 4)
					rolBsKeyTools.height = 0
				)
					-- isMouseInBsKeyTools = true
				rolBsKeyTools.timerTickTock.active = false
			)
			else (if rolTogglePanel != undefined then (rolTogglePanel.timerTickTock.active = false))
        )
    )
	---------------------上面设置拖动脚本窗口,去掉标题栏后默认无法拖动---------------------
	on btnSelBiped pressed do ----选择biped
	(
		-- for o in objects where (o.ishidden == false) do 
		-- (
		-- 	if classof o == Biped_Object then selectmore o
		-- 	-- if (matchpattern o.name pattern:"*Bip*") then selectmore o
		-- )
		if ((selection.count == 1) and (classof $ == Biped_Object) and ($.ishidden == false)) then 
		(
			local tempSel = $
			execute ("select $'" + tempSel.controller.rootNode.name + "*'")
			execute ("deselect $'" + tempSel.controller.rootNode.name + "*Footsteps'")
		)
		else 
		(
			select $'Bip*'
			deselect $'Bip*Footsteps'
		)
	)

	on btnSelBone pressed do ----选择bone
	(
		clearselection ()
		for o in objects where (o.ishidden == false) do 
		(
			if classof o == BoneGeometry then selectmore o
		)
	)

	on spiStartTime changed valTime do  --------初始帧定位到输入的帧数
	(		
		local rangeStart = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \
		(valTime != "")) then
		(
			if (rangeStart < animationrange.end) then 
			(animationrange = (interval rangeStart animationrange.end))
			else (animationrange = (interval rangeStart (rangeStart + 60)))
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)

	on spiEndTime changed valTime do  --------初始帧定位到输入的帧数
	(		
		local rangEnd = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \ 
		(valTime != "")) then
		(
			if (rangEnd > animationrange.start) then
			(animationrange = (interval animationrange.start rangEnd))
			else (animationrange = (interval (rangEnd - 60) rangEnd))
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)
	
	on btnFnFrame pressed do  -------------切换整数帧小数帧,方便拖动滑条平滑预览
	(
		if timeDisplayMode != #frameTicks then 
		(
			timeDisplayMode = #frameTicks
		)
		else 
		(
			timeDisplayMode = #frames
		)
		-- slidertime -= 1
		-- slidertime += 1  ----------默认改了要划一下滑条才生效,脚本直接操作了~~没找到refresh的
		disableSceneRedraw()
		trackbar.visible = false
		trackbar.visible = true
		enableSceneRedraw()
	)
	
	on btnMagicBtn pressed do  -------------切换整数帧小数帧,方便拖动滑条平滑预览
	(
		setfocus rolbskeytools.btnPrimogem
		fnSwitchMagicBtn switchToolPanel
		-- fnRefreshMsPanel()
	)

	on ckbPlayBlocking changed state do (
        -- if (selection.count == 0) do (
        --     StopBlocking()
        --     return()
        -- )
		if state then (
            PlayBlocking()
        )
        else (
            StopBlocking()
        )
    )
    
    -- Play Blocking용 틱 이벤트 처리
    on clock tick do (
        if (m_PBPointer > m_PBKeyMiliSecArray.count) do return()
		local now = timeStamp()
		local pointer
		if (m_PBKeyMiliSecArray.count == m_PBPointer) then (
			ReplayBlocking()
			pointer = 1
		)
		else (
			pointer = m_PBStartTime + m_PBKeyMiliSecArray[m_PBPointer + 1]
		)
        
        if ( now > pointer ) do (
            m_PBPointer += 1
            sliderTime = m_PBKeyTimeArray[m_PBPointer]
        )
        
        if (m_PBPointer >= m_PBKeyMiliSecArray.count) do (
            ReplayBlocking()
        )

        if keyboard.escPressed do (
            StopBlocking()
		)
		
		if (sliderTime != m_PBKeyTimeArray[m_PBPointer]) do (
			StopBlocking()
		)
    )

	on btnCSTools pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts" + "\\BsBipedTools.ms"))
		catch(messagebox "打开 BsBipedTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnCSTools rightclick do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\cstools.ms"))
		catch(messagebox "打开 cstools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)
	on btnSpringMagic pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\SpringMagic_Enhanced.ms"))
		catch(messagebox "打开 SpringMagic_Enhanced.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)
	on btnSpringMagic rightclick do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\SpringMagic_Old.mse"))
		catch(messagebox "打开 SpringMagic_Old.mse 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnFileOpen pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts" + "\\BsOpenTools.ms"))
		catch(messagebox "打开 BsOpenTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on ckbIsoMesh changed state do
	(
		if state then
		(
			hideByCategory.geometry = false
			hideByCategory.shapes = true
			-- hideByCategory.lights = true
			-- hideByCategory.cameras = true
			hideByCategory.helpers = true
			-- hideByCategory.spacewarps = true
			-- hideByCategory.particles = true
			hideByCategory.bones = true
		)
		else 
		(
			hideByCategory.shapes = false
			-- hideByCategory.lights = false
			-- hideByCategory.cameras = false
			hideByCategory.helpers = false
			-- hideByCategory.spacewarps = false
			-- hideByCategory.particles = false
			hideByCategory.bones = false
		)
	)
	on btnProTraj pressed do 
	(
		-- layerTraj = (fnAddTrajLayer "Biped_Trajectories" layerTraj) ----是否创建轨迹层
		-- if (selection.count > 1) then
		-- (
		-- 	for i in (selection as array) do
		-- 	(
		-- 		if classof i == Biped_Object then
		-- 		(
		-- 			if (getNodeByName ("Traj_" + i.name)) != undefined then 
		-- 			(
		-- 				fnDeleteTraj i
		-- 			)
		-- 		)
		-- 	)
		-- )
		-- else if selection.count == 1 then
		-- (
		-- 	if classof $ == Biped_Object then
		-- 		(
		-- 			if (getNodeByName ("Traj_" + $.name)) != undefined then 
		-- 			(
		-- 				fnDeleteTraj $
		-- 			)
		-- 			else fnAddBipedTraj $
		-- 		)
		-- )
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\ProTrajectoryHandles.ms"))
		catch(messagebox "打开 ProTrajectoryHandles.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnProTraj rightclick do
	(
		actionMan.executeAction 0 "276"  -- Tools: Show Trajectories Toggle
	)

	-- on btnProTraj rightclick do
	-- (
	-- 	-- bipedRoot = #()   -------判断选择了几个biped骨架
	-- 	if (selection.count > 0) then
	-- 	(
	-- 		-- for i in (selection as array) where classof i == Biped_Object do  
	-- 		-- (
	-- 		-- 	appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
	-- 		-- )
	-- 		for i in (selection as array) do 
	-- 		(
	-- 			if (classof i == Biped_Object) then
	-- 			(
	-- 				nodeTemp = i.controller.rootNode
	-- 				trajDisFn = nodeTemp.controller.displayTrajectories
	-- 				if trajDisFn == true then nodeTemp.controller.displayTrajectories = false
	-- 				else nodeTemp.controller.displayTrajectories = true
	-- 				exit
	-- 			)
	-- 		)
	-- 	)
	-- )

	on edtMoveKey entered val do   -----移动帧数自定义,输入即可
	(
		if ((val != ".") and (val as time != undefined) and (val != "")) then
		(------"."他也认为是数字...
			keyMovedOffset = val as integer
			rolBsKeyTools.edtMoveKey.text = keyMovedOffset as string + "f"
		)
		else (print "[BskeyTools] warning: 请输入正确移动帧数!";edtMoveKey.text = "5f")
	)

	on btnSet5 pressed do 
	(
		edtMoveKey.text = "5f"
		keyMovedOffset = 5
	)

	on btnSet5 rightclick do 
	(
		edtMoveKey.text = "-5f"
		keyMovedOffset = -5
	)

	on btnSetAdd pressed do 
	(
		keyMovedOffset += 5
		edtMoveKey.text = keyMovedOffset as string + "f"
	)

	on btnSetAdd rightclick do 
	(
		keyMovedOffset -= 5
		edtMoveKey.text = keyMovedOffset as string + "f"
	)
	-- on btnSetOpposite pressed do
	-- (
	-- 	keyMovedOffset = - keyMovedOffset
	-- 	edtMoveKey.text = keyMovedOffset as string + "f"
	-- )
	on btnMoveKeys pressed do with undo on   ------移动选定帧
	(
		if (selection as array).count == 0 then select objects
		if arrKeysSelected.count == 0 then (btnSelAllKeys.pressed())
		fnCollectKeys ()
		fnMoveAllKeys keyMovedOffset fnRange:off
	)
	on btnMoveKeys rightclick do with undo on
	(
		if (selection as array).count == 0 then select objects
		if arrKeysSelected.count == 0 then (btnSelAllKeys.pressed())
		fnCollectKeys ()
		fnMoveAllKeys keyMovedOffset fnRange:on
	)
	on btnSelBeforeKeys pressed do  ------------选择滑条之前帧
	(
		symbol = 0
		fnCollectKeys ()
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do i.selected = false
		)
		if arrKeysTime.count != 0 then
		(
			if keyFirst <= sliderTime then 
			(
				fnSelKeys keyFirst sliderTime symbol
			)
			else 
			(
				fnSelKeys sliderTime sliderTime symbol
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time <= sliderTime then 
				(
					fnSelLinkKeys arrLinkKeys[1].time sliderTime symbol
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime symbol
				)
			)
		)
	)
	
	on btnSelAfterKeys pressed do  -------------选择滑条之后帧
	(
		symbol = 1
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
			if keyEnd >= sliderTime then 
			(
				fnSelKeys sliderTime keyEnd symbol
			)
			else 
			(
				fnSelKeys sliderTime sliderTime symbol
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time >= sliderTime then 
				(
					fnSelLinkKeys sliderTime arrLinkKeys[1].time symbol
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime symbol
				)
			)
		)
	)
	
	on btnSelAllKeys pressed do     ------------------选择所有帧
	(
		symbol = 2
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			fnSelKeys keyFirst keyEnd symbol
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				fnSelLinkKeys arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time symbol
			)
		)
	)
	
	on btnSetFps pressed do (popupMenu menuSetFps pos:[mouse.screenpos.x - 120,mouse.screenpos.y - 120])
		
	on btnSetSpeed pressed do (popupMenu menuSetSpeed pos:[mouse.screenpos.x,mouse.screenpos.y - 160])

	-- on chkJudgeLinkKey changed state do   --切换是否勾选link
	-- (
	-- 	if chkJudgeLinkKey.state == false then
	-- 	(
	-- 		if arrLinkKeys.count != 0 then
	-- 		(
	-- 			for i in arrLinkKeys do i.selected = false
	-- 		)
	-- 	)
	-- 	else 
	-- 	(
	-- 		fnCollectKeys ()
	-- 		(messagebox "无法移动选定 Link 帧，\r\n\r\n只能全局移动，\r\n\r\n其他功能正常生效，\r\n\r\n反正 Link 也很坑还要重新调整你说是吧~                            " title:"BsKeyTools" beep:false)
	-- 	)
	-- )

	on btnCleanOutKeys pressed do with undo on  -----------清理范围外帧(无限帧)
	(
		if (queryBox "是否清除范围外关键帧？\r\n( Link 帧请手动删除 )    " \
		title:"是否清除范围外关键帧？" beep:false) then
		(
			if (selection as array).count == 0 then 
			(
				for tempObject in (objects as Array) do fnCleanOutRangeKeys tempObject
			)
			else
			(
				for tempObject in (selection as Array) do fnCleanOutRangeKeys tempObject
			)
			messagebox "清理成功！    " beep:false
		)
	)

	on btnDelOutKeys pressed do with undo on --清理选择帧
	(
		if (queryBox "是否清除所有关键帧？\r\n\r\n有选择物体则删选择物体的帧，\r\n\r\n否则删所有物体的关键帧。\r\n\r\n(请注意保存 Skin Pose 和备份文件！)                                " \
		title:"是否清除所有关键帧" beep:false) then
		(
			-- max select all  -- Selection: Select All
			-- fnCollectKeys ()
			-- fnSelKeys keyFirst keyEnd 2
			-- fnDelSelKeys ()
			-- if arrLinkKeys.count != 0 then (
			-- 	fnSelLinkKeys arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time 2
			-- )
			if selection.count == 0 then
			(
				max select all
				maxops.deleteSelectedAnimation()
			)
			else (maxops.deleteSelectedAnimation())
		)
	)

	on btnBoxMan pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts" + "\\BsBoxMan.ms"))
		catch(messagebox "打开 BsBoxMan.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on ckbHideBones changed state do
	(
		if state == false then
		(
			for o in geometry as array where (classof o == BoneGeometry and o.layer.ishidden != true) do o.isHidden = false
			rolBsKeyTools.ckbHideBones.text = "隐Bone"
		)
		else
		(
			arrHiddenBones = #()
			for o in geometry as array where (classof o == BoneGeometry) do o.isHidden = true
			rolBsKeyTools.ckbHideBones.text = "显Bone"
		)
	)
	
	on ckbHideBiped changed state do
	(
		if state == false then
		(
			for o in geometry as array where (classof o == Biped_Object and o.layer.ishidden != true) do o.isHidden = false
			rolBsKeyTools.ckbHideBiped.text = "隐Biped"
		)
		else
		(
			arrHiddenBones = #()
			for o in geometry as array where (classof o == Biped_Object) do o.isHidden = true
			rolBsKeyTools.ckbHideBiped.text = "显Biped"
		)
	)

	on ckbFreezeMesh changed state do 
	(
		if state == on then
		(
			rolBsKeyTools.ckbFreezeMesh.text = "解模型"
			for o in objects where (((classof o == Editable_mesh) \
			or (classof o == Editable_Poly) or (classof o == PolyMeshObject) or (classof o == Plane) or (classof o == Box)) \
			and (o.isHidden == false)) do
			(
				freeze o
				o.showFrozenInGray = off
			)
		)
		else
		(
			rolBsKeyTools.ckbFreezeMesh.text = "冻模型"
			for o in objects where (((classof o == Editable_mesh) \
			or (classof o == Editable_Poly) or (classof o == PolyMeshObject) or (classof o == Plane) or (classof o == Box)) \
			and (o.isHidden == false)) do
			(
				unfreeze o
				o.showFrozenInGray = off
			)
		)
	)

	on btnQuicksave pressed do 
	(
		if maxFilePath == "" then 
		(
			messagebox "------------------------------------\r\n\r\n当前场景未保存过,\r\n\r\n请先保存初始版本~\r\n\r\n------------------------------------"
			max file saveas
		)
		else fnBSQuickSave ()
	)

	on btnQuicksave rightclick do 
	(
		if matchpattern (maxFilePath + maxFileName) pattern:("*.backup\\*.max") then 
		(
			try(shellLaunch maxfilepath "")catch()
		)
		else
		(
			try(shellLaunch (maxfilepath + (getFilenameFile maxFileName) + ".backup") "")catch()
		)
	)

	on btnCutFrameDisplay pressed do with undo on  ---------------帧栏显示选定帧范围
	(
		if switchSelKeyRange == 0 then
		(
			fnCollectKeys ()
			arrLastSelRange = #(animationrange.start,animationrange.end)
			fnCutDisplayKeyRange keySelFirst keySelEnd isSelected:true
			switchSelKeyRange = 1
		)
		else 
		(
			animationrange = interval arrLastSelRange[1] arrLastSelRange[2]
			switchSelKeyRange = 0
			arrLastSelRange = #()
		)
	)
	on btnAllFrameDisplay pressed do with undo on  ---------------帧栏显示首尾帧范围
	(
		if switchAllKeyRange == 0 then
		(
			fnCollectKeys ()
			arrLastAllRange = #(animationrange.start,animationrange.end)
			fnCutDisplayKeyRange keyFirst keyEnd isSelected:false
			switchAllKeyRange = 1
		)
		else 
		(
			animationrange = interval arrLastAllRange[1] arrLastAllRange[2]
			switchAllKeyRange = 0
			arrLastAllRange = #()
		)
	)

	-- on btnZeroFrameDisplay pressed do with undo on  ---------------帧栏显示0帧
	-- (
	-- 	animationrange = interval 0f animationrange.end
	-- )

	------------切换工具栏分类--------------------------------------------
	on ckbC1 changed state do 
	(
		setfocus rolbskeytools.btnPrimogem
		if state == true then 
		(
			fnSwitchToolBtnChecked 1
			fnSwitchToolsBtn 1
		)
		else ckbC1.checked = true
	)
	on ckbC2 changed state do 
	(
		setfocus rolbskeytools.btnPrimogem
		if state == true then 
		(
			fnSwitchToolBtnChecked 2
			fnSwitchToolsBtn 2
		)
		else ckbC2.checked = true
	)
	on ckbC3 changed state do 
	(
		setfocus rolbskeytools.btnPrimogem
		if state == true then 
		(
			fnSwitchToolBtnChecked 3
			fnSwitchToolsBtn 3
		)
		else ckbC3.checked = true
	)
	on ckbC4 changed state do 
	(
		setfocus rolbskeytools.btnPrimogem
		if state == true then 
		(
			fnSwitchToolBtnChecked 4
			fnSwitchToolsBtn 4
		)
		else ckbC4.checked = true
	)
	-- on ckbSwitchMyScripts changed state do 
	-- (
	-- 	if state then switchMSPanel = 1 else switchMSPanel = 0
	-- 	fnRefreshMsPanel()
	-- )
	--------------------------------------------------------------------

	on btnFnTCB pressed do 
	(
		for i in selection where classof i == BoneGeometry do
		(
			if classof i.rotation.controller == tcb_rotation then
				(i.rotation.controller = Euler_XYZ ())
				else (i.rotation.controller = tcb_rotation ())
		)
	)

	on btnImageComp pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\ImageCompHelper.ms"))
		catch(messagebox "打开 ImageCompHelper.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)
	
	on btnFnKeyType pressed do 
	(
		try(destroydialog rolFnKeys)catch()
		Createdialog rolFnKeys  fgcolor:myFgColor \
		pos:[mouse.screenpos.x,mouse.screenpos.y]
	)

	on btnEulerFilter pressed do 
	(
		for i in selection where classof i == BoneGeometry do
		(
			if classof i.rotation.controller == Euler_XYZ then
			(
				i.rotation.controller = tcb_rotation ()
				i.rotation.controller = Euler_XYZ ()
			)
		)
	)

	on ckbFnBoxDisplay changed state do 
	(
		if state == on then ckbFnBoxDisplay.text = "实体"
				else ckbFnBoxDisplay.text = "BOX显"
		for o in Geometry where (o.isHidden == false) do 
		(
			if ((classof o == BoneGeometry) or (classof o == Biped_Object)) then
			(
				if state == on then o.boxmode = on 
				else o.boxmode = off
			)
		)
	)
	
	on ckbFnMtlDisplay changed state do 
	(
		if state == off then
		(
			-- for mat in (getClassInstances vrayMtl processAllAnimatables:true) do showTextureMap mat on
			for mat in (getClassInstances standard processAllAnimatables:true) do showTextureMap mat on
		)
		else
		(
			-- for mat in (getClassInstances vrayMtl processAllAnimatables:true) do showTextureMap mat off
			for mat in (getClassInstances standard processAllAnimatables:true) do showTextureMap mat off
		)
	)

	on ckbFnMtlDisplay rightclick do 
	(
		local disp = NitrousGraphicsManager.GetActiveViewportSetting() 
		if disp.VisualStyleMode == #clay then disp.VisualStyleMode = #Realistic
		else disp.VisualStyleMode =  #clay
	)

	on btnMopherSlider pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\MorphSliders_11.ms"))
		catch(messagebox "打开 MorphSliders_11.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnLayerManager rightclick do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\LayerManagerAlternative.ms"))
		catch(messagebox "打开 ayerManagerAlternative.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnLayerManager pressed do 
	(
		if keyboard.controlpressed == true then
		(
			try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\nestedLayerManager.mzp"))
			catch(messagebox "打开 nestedLayerManager.mzp 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
		)
		else
		(
			try(macros.run "Layers" "nestedLayerManagerMacro")
			catch
			(
				FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\nestedLayerManager.mzp")
			)
		)
	)

	on btnAnimMirror pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote" + "\\Anim_mirror.ms"))
		catch(messagebox "打开 Anim_mirror.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on ckbIsoSelection changed stateIso do 
	(
		-- local arrTempSelObj = #()
		-- local arrTemp = objects as array
		-- local arrTempAllObj = for o in arrTemp where o.isHidden == false collect o
		-- local numTempCurrentSel = selection.count
		-- if arrTempAllObj.count > numTempCurrentSel then
		-- (
		-- 	if numTempCurrentSel != 0 then 
		-- 	(
		-- 		arrTempSelObj = selection as array
		-- 	)
		-- 	for i in arrTempSelObj where (arrTempSelObj.count != 0) do
		-- 	(
		-- 		num = finditem arrTempAllObj i
		-- 		if num != 0 then deleteItem arrTempAllObj num
		-- 	)
		-- 	arrTempUnSelection = arrTempAllObj
		-- 	actionMan.executeAction 0 "281"
		-- )
		if stateIso == true then
		(
			if selection.count != 0 then
			(
				if (not IsolateSelection.IsolateSelectionModeActive()) then
				(
					IsolateSelection.EnterIsolateSelectionMode()
					actionMan.executeAction 0 "40104"  -- Views: Undo Viewport Operation
				)
				else 
				(
					ckbIsoSelection.state = false
					IsolateSelection.ExitIsolateSelectionMode()
					actionMan.executeAction 0 "40104"  -- Views: Undo Viewport Operation
				)
			)
			else ckbIsoSelection.state = false
		)
		else
		(
			if (IsolateSelection.IsolateSelectionModeActive()) then 
			(
				IsolateSelection.ExitIsolateSelectionMode()
				actionMan.executeAction 0 "40104"  -- Views: Undo Viewport Operation
			)
		)
	)

	-- on ckbIsoSelection rightclick do
	-- (
	-- 	if arrTempUnSelection.count != 0 then
	-- 	(
	-- 		for i in arrTempUnSelection do i.isHidden = false
	-- 	)
	-- )

	on btnQuickPrev pressed do 
	(
		createPreview percentSize:100 \
		dspGeometry:true dspShapes:false dspLights:false \
		dspCameras:false dspHelpers:false dspParticles:true dspBones:false \
		dspGrid:true dspSafeFrame:false dspFrameNums:false dspBkg:true \
		rndLevel:#smoothhighlights
	)

	on btnQuickPrev rightclick do (shellLaunch (getdir #preview) "")

	on btnSelByColor pressed do
	(
		for i in selection as array where (i.ishidden == false) do
		(
			for o in objects as array where (i.ishidden == false) do
			(
				if o.wirecolor == i.wirecolor then selectmore o
			)
		)
	)

	on btnBipedScale pressed do (fnBipedScale ())

	on btnReplaceSkinBones pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\sox_replacebonefromskin.ms"))
		catch(messagebox "打开 sox_replacebonefromskin.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnReplaceSkinBones rightclick do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\ChangeSkinBones.ms"))
		catch(messagebox "打开 ChangeSkinBones.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnAnimCopyPaste pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\CPTools_New.ms"))
		catch(messagebox "打开 CPTools_New.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnAnimCopyPaste rightclick do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\CPTools.ms"))
		catch(messagebox "打开 CPTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnPoseTool pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsRefTools.ms"))
		catch(messagebox "打开 BsRefTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnTrajedit pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\DTrajEdit.ms"))
		catch(messagebox "打开 DTrajEdit.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnTrajedit rightclick do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\DTrajEdit_New.ms"))
		catch(messagebox "打开 DTrajEdit_New.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnTrackBarTools pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts" + "\\BsTrackBarTools.ms"))
		catch(messagebox "打开 BsTrackBarTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on ckbShadowCut changed state do
	(
		if state then
		(
			actionMan.executeAction 0 "63566"
			ambientColor = color 0 0 0
			lightTintColor = color 0 0 0
			redrawViews()
		)
		else 
		(
			ambientColor=color 0 0 0
			lightTintColor=color 255 255 255
			redrawViews()
		)
		deletekeys ambientColorController #allKeys
		deletekeys lightTintColorController #allKeys
	)

	on ckbShadowCut rightclick do 
	(
		actionMan.executeAction 0 "40029"  -- Render: Environment Dialog Toggle
	)

	on btnRenameTools pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\P_ObjectRenamer.ms"))
		catch(messagebox "打开 P_ObjectRenamer.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnMirrorMoph pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\mirrormorph.ms"))
		catch(messagebox "打开 mirrormorph.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnVportTools pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsVportTools.ms"))
		catch(messagebox "打开 BsVportTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnMeshToBone pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\FractureVoronoi.ms"))
		catch(messagebox "打开 FractureVoronoi.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnLightTable pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\LightTable.ms"))
		catch(messagebox "打开 LightTable.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnCutSequence pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\AnimaRange.ms"))
		catch(messagebox "打开 AnimaRange.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnTwistBones pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\twistbones.ms"))
		catch(messagebox "打开 twistbones.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnChainsTools pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\ChainsTools.ms"))
		catch(messagebox "打开 ChainsTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnBatchExport pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\Batch version down.ms"))
		catch(messagebox "打开 Batch version down.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnBatchExport rightclick do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\Batch Import Convert.ms"))
		catch(messagebox "打开 Batch Import Convert.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnFastAlign pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\alexanimalign_0.ms"))
		catch(messagebox "打开 alexanimalign_0.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnCollider pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\Collider.ms"))
		catch(messagebox "打开 Collider.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnMassFX pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\MassFX.ms"))
		catch(messagebox "打开 MassFX.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnPicker pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\UILayout_V1.01_HPK.ms"))
		catch(messagebox "打开 UILayout_V1.01_HPK.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnPicker rightclick do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\objectPicker.ms"))
		catch(messagebox "打开 objectPicker.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnBakeAnim pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\BakeAnim.ms"))
		catch(messagebox "打开 BakeAnim.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnXpsConvert pressed do
	(
		try(messagebox "若导入报错，可尝试用高版本 3dsMax 重新导入，基本可解决！                                       " beep:false title:"BsKeyTools";FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\XnaLara Converter.ms"))
		catch(messagebox "打开 XnaLara Converter.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnCleanCustomAtts pressed do
	(
		if (queryBox "是否清理冗余自定义属性，\r\n\r\n如 day1reCA 和 SimpleFaceData ？\r\n\r\n请注意备份和保存文件！                                               " \
		title:"BsKeyTools" beep:false) then
		(
			cusAtt = rootscene.custAttributes
			for i =1 to cusAtt.count do deleteItem cusAtt 1
		)
	)

	on btnLODCreate pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\lod_creator.ms"))
		catch(messagebox "打开 lod_creator.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnMorpherCtrl pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\pxMorphSliders.ms"))
		catch(messagebox "打开 pxMorphSliders.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnEndBone pressed do 
	(
		local tempLayerBoneEnd
		if (LayerManager.getLayerFromName "tempBoneEndAll") != undefined then
		(tempLayerBoneEnd = LayerManager.getLayerFromName "tempBoneEndAll")
		else (tempLayerBoneEnd = LayerManager.newLayerFromName "tempBoneEndAll")
		if selection.count != 0 then with undo on 
		(
			arrSel = selection as array
			for i in 1 to arrSel.count do
			(
				arrChild = (execute ("$'" + arrSel[i].name + "'/...*")) as array
				for c in arrChild where c.children.count == 0 do 
				(
					if (c != undefined) then 
					(
						parentBone = c
					)
					else (parentBone  = arrSel[i])
					parentTrans = parentBone.transform
					parentPos   = parentTrans.translation
			
					newBone = BoneSys.createBone parentPos (parentPos+6) parentBone.dir
					newBone.transform = parentTrans
					newBone.taper     = 90
			
					if iskindof arrSel[i] BoneGeometry==true do 
					(
						in coordSys Local move newBone [parentBone.length,0,0]
						newBone.parent    = parentBone
						newBone.width     = parentBone.width
						newBone.height    = parentBone.height
						newBone.length    = (parentBone.width+parentBone.height)/2
						newBone.wirecolor = parentBone.wirecolor
					)
					append arrBoneEndAll newBone
					tempLayerBoneEnd.addNode newBone
				)
			)
			messageBox "注意：\r\n\r\n点确定完成添加，\r\n\r\n会创建新层存放末端，\r\n\r\n重启软件后无法回退，\r\n\r\n可点击右键或手动清除之前添加的末端，\r\n\r\n（在 tempBoneEndAll 层中）                                     "
		)
		else (messagebox "请选择要添加末端的 Bone 骨骼~                    " beep:false)
	)

	on btnEndBone rightclick do with undo on
	(
		if (LayerManager.getLayerFromName "tempBoneEndAll") != undefined then
		(
			tempLayerBoneEnd = LayerManager.getLayerFromName "tempBoneEndAll"
			tempLayerBoneEnd.nodes &arrLayerNodeTemp
			for i in arrLayerNodeTemp do delete i
			(LayerManager.getLayer 0).current = true
			LayerManager.deleteLayerByName "tempBoneEndAll"
			arrBoneEndAll = #()
			messagebox "点确定清理添加的骨骼末端 (在 tempBoneEndAll 层中的骨骼) ~          "
		)
	)

	on btnHideBipedTwists pressed do (fnGetAllBipedTwist())

	on btnDelDecimalKeys pressed do 
	(
		fnCollectKeys ()
		fnDelAllDecimalKeys arrBlockingKeys
		(messagebox "已清理所有小数帧，Link帧请自行清理                    " beep:false)
	)

	on btnRescaleWU pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsBatchRescaleWU.ms"))
		catch(messagebox "打开 BsBatchRescaleWU.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnRescaleWU rightclick do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\RescaleWU.ms"))
		catch(messagebox "打开 RescaleWU.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnSkinTools pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\SkinTools.ms"))
		catch(messagebox "打开 SkinTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnTweenMachine pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\TweenMachine.ms"))
		catch(messagebox "打开 BsKeyStepMode.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnSelectionsetTools pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsSelSetTools.ms"))
		catch(messagebox "打开 BsSelSetTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)
	on btnXrSkinTool pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\Xr_SkinTool.ms"))
		catch(messagebox "打开 Xr_SkinTool.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnRetargetTools pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsRetargetTools.ms"))
		catch(messagebox "打开 BsRetargetTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnCombineDetachSkin pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\Rigging_CombineSkin.ms"))
		catch(messagebox "打开 Rigging_CombineSkin.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnRenderTools pressed do 
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\Quote\\多方向渲染工具（集成修改版）.ms"))
		catch(messagebox "打开 多方向渲染工具（集成修改版）.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on btnElement mouseDown senderArg arg do
	(
		iconCurStr = (fnChangeBtnElement iconCurStr)
		iconElement = (iconPath + @"\\" + iconCurStr)
		btnElement.image = (fnDotnetBitmap iconElement)
	)

	on btnPrimogem mouseDown senderArg arg do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsScriptsSet.ms"))
		catch(messagebox "打开 BsScriptsSet.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on ckbPerspLock changed state do
	(
		msgPersp = ""
		if state then 
		(
			registerRedrawViewsCallback fnOrthoToPersp 
			msgPersp = "已开启"
			tooglePersp = true
		)
		else
		(
			unRegisterRedrawViewsCallback fnOrthoToPersp
			msgPersp = "已关闭"
			tooglePersp = false
		)
		tooglePersp = (not tooglePersp)
		messagebox ("BsKeyTools：透视锁定（旋转镜头自动按 P 转透视）-- " + msgPersp + "                                ") beep:false title:"BsKeyTools" 
	)

	on btnDemoTool pressed do
	(
		try(FileIn ((getDir #scripts) + "\\BulletScripts\\BsAnimDemoTools.ms"))
		catch(messagebox "打开 BsAnimDemoTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
	)

	on dotLVFilesList DoubleClick do
	(		
		fnOpenRecentFile()
	)

	on dotLVFilesList mouseup sender args do
	(
		if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Right do fnOpenRecentFilePath()
	)

	-- on ckbOpenConfigFilePath changed state do
	-- (
	-- 	ckbOpenConfigFilePath.state = true
	-- 	if (queryBox "是否打开配置文件目录？（配置文件：BulletConfig.ini）\r\n\r\n【另存或替换此文件可手动处理备份或导入脚本配置】                                                     " \
	-- 	title:"配置文件" beep:false) then (shellLaunch (getFilenamePath BulletConfig) "")
	-- )
	-- on ckbOpenConfigFilePath rightClick do
	-- (
	-- 	ckbOpenConfigFilePath.state = true
	-- 	if (queryBox "是否打开配置文件目录？（配置文件：BulletConfig.ini）\r\n\r\n【另存或替换此文件可手动处理备份或导入脚本配置】                                                     " \
	-- 	title:"配置文件" beep:false) then (shellLaunch (getFilenamePath BulletConfig) "")
	-- )
)
if (iniPos != 0) then (Createdialog rolBsKeyTools fgcolor:myFgColor pos:iniPos style:#())
else (Createdialog rolBsKeyTools fgcolor:myFgColor style:#())

fn fnBsUpdateTimeRange = 
(
	rolBsKeyTools.spiStartTime.value = (animationRange.start.frame as integer)   
	rolBsKeyTools.spiEndTime.value = (animationRange.end.frame as integer)
)

fnDelFileDir ((getDir #StartupScripts)+ "\\BsGetTimeCost.ms")

callbacks.addScript #animationRangeChange "fnBsUpdateTimeRange()" id:#BsUpdateTimeRange
callbacks.addScript #filePostOpen "fnBsRefFps()" id:#BsUpdateFps
callbacks.addScript #timeunitsChange "fnBsRefFps()" id:#BsUpdateFps
callbacks.addScript #filePostOpen "fnRefPlaySpeedValue()" id:#BsUpdatePlaySpeed
callbacks.addScript #timeunitsChange "fnRefPlaySpeedValue()" id:#BsUpdatePlaySpeed
callbacks.addScript #filePostOpen "rolBsKeyTools.fnRefreshRecentFileList()" id:#BsRefreshRecentFiles
-- gc()
clearListener()  ---------清除侦听器