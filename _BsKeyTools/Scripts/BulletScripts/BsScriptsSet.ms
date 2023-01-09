/*
 * @Description: 自定义脚本小窗
 * @Author: Bullet.S
 * @Date: 2022-12-23 17:04:08
 * @LastEditors: Bullet.S
 * @LastEditTime: 2023-01-10 00:43:20
 * @Email: animator.bullet@foxmail.com
 */


try(destroydialog rolBsScriptsSet)catch()

struct myScript (id,msName,dir)
Global iniArrMyScripts1   = #((myScript id:1 msName:"<＋＋>" dir:""), \
(myScript id:2 msName:"<＋＋>" dir:""), \
(myScript id:3 msName:"<＋＋>" dir:""), \
(myScript id:4 msName:"<＋＋>" dir:""), \
(myScript id:5 msName:"<＋＋>" dir:""), \
(myScript id:6 msName:"<＋＋>" dir:""), \
(myScript id:7 msName:"<＋＋>" dir:""), \
(myScript id:8 msName:"<＋＋>" dir:""))
Global iniArrMyScripts2   = #((myScript id:1 msName:"<＋＋>" dir:""), \
(myScript id:2 msName:"<＋＋>" dir:""), \
(myScript id:3 msName:"<＋＋>" dir:""), \
(myScript id:4 msName:"<＋＋>" dir:""), \
(myScript id:5 msName:"<＋＋>" dir:""), \
(myScript id:6 msName:"<＋＋>" dir:""), \
(myScript id:7 msName:"<＋＋>" dir:""), \
(myScript id:8 msName:"<＋＋>" dir:""))
Global iniArrMyScripts3   = #((myScript id:1 msName:"<＋＋>" dir:""), \
(myScript id:2 msName:"<＋＋>" dir:""), \
(myScript id:3 msName:"<＋＋>" dir:""), \
(myScript id:4 msName:"<＋＋>" dir:""), \
(myScript id:5 msName:"<＋＋>" dir:""), \
(myScript id:6 msName:"<＋＋>" dir:""), \
(myScript id:7 msName:"<＋＋>" dir:""), \
(myScript id:8 msName:"<＋＋>" dir:""))
Global iniArrMyScripts4   = #((myScript id:1 msName:"<＋＋>" dir:""), \
(myScript id:2 msName:"<＋＋>" dir:""), \
(myScript id:3 msName:"<＋＋>" dir:""), \
(myScript id:4 msName:"<＋＋>" dir:""), \
(myScript id:5 msName:"<＋＋>" dir:""), \
(myScript id:6 msName:"<＋＋>" dir:""), \
(myScript id:7 msName:"<＋＋>" dir:""), \
(myScript id:8 msName:"<＋＋>" dir:""))
Global iniArrMyScripts5   = #((myScript id:1 msName:"<＋＋>" dir:""), \
(myScript id:2 msName:"<＋＋>" dir:""), \
(myScript id:3 msName:"<＋＋>" dir:""), \
(myScript id:4 msName:"<＋＋>" dir:""), \
(myScript id:5 msName:"<＋＋>" dir:""), \
(myScript id:6 msName:"<＋＋>" dir:""), \
(myScript id:7 msName:"<＋＋>" dir:""), \
(myScript id:8 msName:"<＋＋>" dir:""))
Global BulletConfig       = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
Global iniBsScriptsSetPos  	--位置保存记录
global arrMyMsBtn           = #()
global arrAddMyMsBtn        = #()
global idMsBtn				= 1

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "加载配置失败，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
stLoadConfigAll.fnLoadConfigBsScriptsSet()
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")

Global rolBsScriptsSet
global rolAddMyMs
Global posMsMouMoved       = [0,0]
Global switchMsMouseState  = false

------------------全局变量-------------------------------------------------------------------
global fnLoadMsArray
fn fnLoadMsArray =
(
	case idMsBtn of
	(
		(1):(return iniArrMyScripts1)
		(2):(return iniArrMyScripts2)
		(3):(return iniArrMyScripts3)
		(4):(return iniArrMyScripts4)
		(5):(return iniArrMyScripts5)
		default:(return undefined)
	)
)
global fnSaveMsArray
fn fnSaveMsArray arrMsTemp =
(
	case idMsBtn of
	(
		(1):(iniArrMyScripts1 = for i in arrMsTemp collect i)
		(2):(iniArrMyScripts2 = for i in arrMsTemp collect i)
		(3):(iniArrMyScripts3 = for i in arrMsTemp collect i)
		(4):(iniArrMyScripts4 = for i in arrMsTemp collect i)
		(5):(iniArrMyScripts5 = for i in arrMsTemp collect i)
	)
	fnSetMsBtnConfig()
)

fn fnRefreshMyMsBtn = 
(
	arrMyMsBtn = #(rolBsScriptsSet.btnMyScripts1, \
		rolBsScriptsSet.btnMyScripts2, \
		rolBsScriptsSet.btnMyScripts3, \
		rolBsScriptsSet.btnMyScripts4, \
		rolBsScriptsSet.btnMyScripts5, \
		rolBsScriptsSet.btnMyScripts6, \
		rolBsScriptsSet.btnMyScripts7, \
		rolBsScriptsSet.btnMyScripts8)
	arrAddMyMsBtn = #(rolAddMyMs.edtRenameMs1, \
		rolAddMyMs.edtRenameMs2, \
		rolAddMyMs.edtRenameMs3, \
		rolAddMyMs.edtRenameMs4, \
		rolAddMyMs.edtRenameMs5, \
		rolAddMyMs.edtRenameMs6, \
		rolAddMyMs.edtRenameMs7, \
		rolAddMyMs.edtRenameMs8)
)

rollout rolAddMyMs "我的脚本" width:300 height:220
(
	local btnMSWidth = 200

	label lblRename "↓ 请输入命名 ↓" pos:[20,5]
	label lblReDir "指定路径" pos:[210,5]
	label lblClearOneMs "清除" pos:[265,5]
	edittext edtRenameMs1 "01"  pos:[5,25] width:btnMSWidth height:20 text:""
	edittext edtRenameMs2 "02"  pos:[5,45] width:btnMSWidth height:20 text:""
	edittext edtRenameMs3 "03"  pos:[5,65] width:btnMSWidth height:20 text:""
	edittext edtRenameMs4 "04"  pos:[5,85] width:btnMSWidth height:20 text:""
	edittext edtRenameMs5 "05"  pos:[5,105] width:btnMSWidth height:20 text:""
	edittext edtRenameMs6 "06"  pos:[5,125] width:btnMSWidth height:20 text:""
	edittext edtRenameMs7 "07"  pos:[5,145] width:btnMSWidth height:20 text:""
	edittext edtRenameMs8 "08"  pos:[5,165] width:btnMSWidth height:20 text:""
	-- edittext edtRenameMs9 "09"  pos:[5,185] width:btnMSWidth height:20 text:""
	-- edittext edtRenameMs10 "10"  pos:[5,205] width:btnMSWidth height:20 text:""
	button btnReAddMs1 "..."  pos:[btnMSWidth + 10,25] width:50 height:20 border:true
	button btnReAddMs2 "..."  pos:[btnMSWidth + 10,45] width:50 height:20 border:true
	button btnReAddMs3 "..."  pos:[btnMSWidth + 10,65] width:50 height:20 border:true
	button btnReAddMs4 "..."  pos:[btnMSWidth + 10,85] width:50 height:20 border:true
	button btnReAddMs5 "..."  pos:[btnMSWidth + 10,105] width:50 height:20 border:true
	button btnReAddMs6 "..."  pos:[btnMSWidth + 10,125] width:50 height:20 border:true
	button btnReAddMs7 "..."  pos:[btnMSWidth + 10,145] width:50 height:20 border:true
	button btnReAddMs8 "..."  pos:[btnMSWidth + 10,165] width:50 height:20 border:true
	-- button btnReAddMs9 "..."  pos:[btnMSWidth + 10,185] width:50 height:20 border:true
	-- button btnReAddMs10 "..."  pos:[btnMSWidth + 10,205] width:50 height:20 border:true
	button btnClearMs1 "X" pos:[btnMSWidth + 65,25]  width:30 height:20 border:true
	button btnClearMs2 "X" pos:[btnMSWidth + 65,45]  width:30 height:20 border:true
	button btnClearMs3 "X" pos:[btnMSWidth + 65,65]  width:30 height:20 border:true
	button btnClearMs4 "X" pos:[btnMSWidth + 65,85]  width:30 height:20 border:true
	button btnClearMs5 "X" pos:[btnMSWidth + 65,105]  width:30 height:20 border:true
	button btnClearMs6 "X" pos:[btnMSWidth + 65,125]  width:30 height:20 border:true
	button btnClearMs7 "X" pos:[btnMSWidth + 65,145]  width:30 height:20 border:true
	button btnClearMs8 "X" pos:[btnMSWidth + 65,165]  width:30 height:20 border:true
	-- button btnClearMs9 "X" pos:[btnMSWidth + 65,185]  width:30 height:20 border:true
	-- button btnClearMs10 "X" pos:[btnMSWidth + 65,205]  width:30 height:20 border:true
	button btnClearMyScripts "! 清除当前切页脚本引用 !" pos:[15,190] width:160 height:25 border:true
	button btnDoit "! 注意确认 !" pos:[175,190] width:120 height:25 border:true

	fn fnRefreshBtnReAddMs btnMsName btnMsDir edtRenameMs id =
	(
		arrMsTemp = fnLoadMsArray()

		dirScript = getOpenFileName caption:"请选择添加的Max脚本:" historyCategory:"myScripts" \
		types:"maxscript(*.ms,*.mse,*.mzp)|*.m*|All(*.*)|*.*" filename:(getDir #scripts + @"\") 
		if (dirScript != undefined) then
		(
			nameMyScript = getFilenameFile dirScript
			btnMsName.text = nameMyScript
			btnMsDir.text = "已修改"
			if arrMsTemp[id] != undefined then arrMsTemp[id].dir = dirScript
			else (append arrMsTemp (myScript id edtRenameMs.text dirScript))
			fnSaveMsArray arrMsTemp
			-- fnSetMsBtnConfig()
		)
		-- print dirScript
	)

	fn fnAddMsName id edtRenameMs =
	(
		arrMsTemp = fnLoadMsArray()
		if (arrMsTemp[id] != undefined) then
		(
			if edtRenameMs.text != "" then arrMsTemp[id].msName = edtRenameMs.text
			else arrMsTemp[id].msName = "<＋＋>"
			fnSaveMsArray arrMsTemp
			-- fnSetMsBtnConfig()
		)
	)

	fn fnRefreshMyScriptsUI =
	(
		fnRefreshMyMsBtn()
		arrMsTemp = fnLoadMsArray()
		for b = 1 to arrAddMyMsBtn.count do
		(
			if arrMsTemp[b] != undefined then
			(
				if arrMsTemp[b].msName != undefined then 
				(
					arrAddMyMsBtn[b].text = arrMsTemp[b].msName 
				)
				else arrAddMyMsBtn[b].text = ""
			)
		)
	)

	fn fnClearOneMs id =
	(
		strMsBtn = idMsBtn as string
		execute ("iniArrMyScripts" + strMsBtn + "[" + (id as string) + "].msName = \"<＋＋>\"")
		execute ("iniArrMyScripts" + strMsBtn + "[" + (id as string) + "].dir = \"<＋＋>\"")
		execute ("rolBsScriptsSet.btnMyScripts" + (id as string) + ".tooltip = \"<＋＋>\"")
		fnRefreshMyScriptsUI()
	)

	fn fnClearMyScripts = --清除脚本
	(
		fnRefreshMyMsBtn()

		--设置dotNet窗口元素
		local mb = dotNetClass "System.Windows.Forms.MessageBox"
		local buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
		local icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
		local defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
		local dialogResult = dotNetClass "System.Windows.Forms.DialogResult"

		local result = mb.show "确定清除【当前切页】引用的脚本按钮吗 ?" "自定脚本一键清除" buttons.YesNoCancel icons.Information defaultButton.Button3

		arrMsTemp = fnLoadMsArray()

		--选项按钮
		if ( result == dialogResult.Yes ) then
		(
			arrMsTemp   = #((myScript id:1 msName:"<＋＋>" dir:""), \
			(myScript id:2 msName:"<＋＋>" dir:""), \
			(myScript id:3 msName:"<＋＋>" dir:""), \
			(myScript id:4 msName:"<＋＋>" dir:""), \
			(myScript id:5 msName:"<＋＋>" dir:""), \
			(myScript id:6 msName:"<＋＋>" dir:""), \
			(myScript id:7 msName:"<＋＋>" dir:""), \
			(myScript id:8 msName:"<＋＋>" dir:""))

			fnSaveMsArray arrMsTemp
			-- fnSetMsBtnConfig()

			for b = 1 to arrMyMsBtn.count do 
			(
				arrMyMsBtn[b].text = "<＋＋>"
				arrMyMsBtn[b].tooltip = "<＋＋>"
			)
			for b = 1 to arrAddMyMsBtn.count do 
			(
				arrAddMyMsBtn[b].text = "<＋＋>"
			)
		)
		else if ( result == dialogResult.No ) then
		(
			format "NO\n"
		)
		else if ( result == dialogResult.Cancel ) then
		(
			format "CANCEL\n"
		)
	)

	fn fnApplyMyMs =
	(
		fnRefreshMyMsBtn()

		fnAddMsName 1 edtRenameMs1
		fnAddMsName 2 edtRenameMs2
		fnAddMsName 3 edtRenameMs3
		fnAddMsName 4 edtRenameMs4
		fnAddMsName 5 edtRenameMs5
		fnAddMsName 6 edtRenameMs6
		fnAddMsName 7 edtRenameMs7
		fnAddMsName 8 edtRenameMs8

		arrMsTemp = fnLoadMsArray()

		for b = 1 to arrMyMsBtn.count do 
		(
			if arrMsTemp[b] != undefined then
			(
				if (arrMsTemp[b].msName != undefined) then 
				(
					arrMyMsBtn[b].text = arrMsTemp[b].msName
				)
			)
		)
		fnSaveMsArray arrMsTemp
		-- fnSetMsBtnConfig()
		try(destroydialog rolAddMyMs)catch()
		stSetConfigAll.fnSetConfigBsScriptsSet ()
	)

	on rolAddMyMs open do 
	(
		fnRefreshMyScriptsUI ()
	)

	on btnReAddMs1 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs1 btnReAddMs1 edtRenameMs1 1
	)

	on btnReAddMs2 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs2 btnReAddMs2 edtRenameMs2 2
	)

	on btnReAddMs3 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs3 btnReAddMs3 edtRenameMs3 3
	)
	on btnReAddMs4 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs4 btnReAddMs4 edtRenameMs4 4
	)
	on btnReAddMs5 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs5 btnReAddMs5 edtRenameMs5 5
	)
	on btnReAddMs6 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs6 btnReAddMs6 edtRenameMs6 6
	)
	on btnReAddMs7 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs7 btnReAddMs7 edtRenameMs7 7
	)
	on btnReAddMs8 pressed do 
	(
		fnRefreshBtnReAddMs edtRenameMs8 btnReAddMs8 edtRenameMs8 8
	)

	on edtRenameMs1 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs1.text = tempText
	)

	on edtRenameMs2 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs2.text = tempText
	)

	on edtRenameMs3 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs3.text = tempText
	)
	on edtRenameMs4 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs4.text = tempText
	)
	on edtRenameMs5 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs5.text = tempText
	)
	on edtRenameMs6 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs6.text = tempText
	)
	on edtRenameMs7 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs7.text = tempText
	)
	on edtRenameMs8 changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtRenameMs8.text = tempText
	)

	on btnClearMs1 pressed do (fnClearOneMs 1)
	on btnClearMs2 pressed do (fnClearOneMs 2)
	on btnClearMs3 pressed do (fnClearOneMs 3)
	on btnClearMs4 pressed do (fnClearOneMs 4)
	on btnClearMs5 pressed do (fnClearOneMs 5)
	on btnClearMs6 pressed do (fnClearOneMs 6)
	on btnClearMs7 pressed do (fnClearOneMs 7)
	on btnClearMs8 pressed do (fnClearOneMs 8)

	on btnDoit pressed do(fnApplyMyMs())

	on rolAddMyMs close do (fnApplyMyMs())

	on btnClearMyScripts pressed do (fnClearMyScripts())
)
-----------------------------------------------------------------
-------------主UI-----------------------------------------------------------------
rollout rolBsScriptsSet "" width:170 height:265
(
	groupbox gbxMyTools "" pos:[5,15] width:160 height:245

	local btnMsWidth  = 150
	local btnMsHeight = 25
	local btnMsPos    = [10,55]
	
	button btnConfig "配置" pos:[0,0] height:20 width:30 tootip:"也可按钮上右键打开配置" border:false
	label lblTitle "[ BsScriptsSet ]" pos:[rolBsScriptsSet.width/2 - 45,3] height:15 width:80
	button btnMin "-" pos:[rolBsScriptsSet.width - 40,0] height:20 width:20 border:false
	button btnClose "X" pos:[rolBsScriptsSet.width - 20,0] height:20 width:20 border:false

	checkbutton ckbMs1 "生" width:30 height:26 highlightcolor:myCheckedColor \
	pos:[10,25] toolTip:"" border:false
	checkbutton ckbMs2 "死" width:30 height:26 highlightcolor:myCheckedColor \
	pos:[40,25] toolTip:"" border:false
	checkbutton ckbMs3 "时" width:30 height:26 highlightcolor:myCheckedColor \
	pos:[70,25] toolTip:"" border:false
	checkbutton ckbMs4 "空" width:30 height:26 highlightcolor:myCheckedColor \
	pos:[100,25] toolTip:"" border:false
	checkbutton ckbMs5 "理" width:30 height:26 highlightcolor:myCheckedColor \
	pos:[130,25] toolTip:"" border:false

	button btnMyScripts1 "<＋＋>" pos:btnMsPos width:btnMsWidth height:btnMsHeight
	border:true visible:true
	button btnMyScripts2 "<＋＋>" pos:(btnMsPos + [0,btnMsHeight]) width:btnMsWidth height:btnMsHeight
	border:true visible:true
	button btnMyScripts3 "<＋＋>" pos:(btnMsPos + [0,2 * btnMsHeight]) width:btnMsWidth height:btnMsHeight
	border:true visible:true
	button btnMyScripts4 "<＋＋>" pos:(btnMsPos + [0,3 * btnMsHeight]) width:btnMsWidth height:btnMsHeight
	border:true visible:true
	button btnMyScripts5 "<＋＋>" pos:(btnMsPos + [0,4 * btnMsHeight]) width:btnMsWidth height:btnMsHeight
	border:true visible:true
	button btnMyScripts6 "<＋＋>" pos:(btnMsPos + [0,5 * btnMsHeight]) width:btnMsWidth height:btnMsHeight
	border:true visible:true
	button btnMyScripts7 "<＋＋>" pos:(btnMsPos + [0,6 * btnMsHeight]) width:btnMsWidth height:btnMsHeight
	border:true visible:true
	button btnMyScripts8 "<＋＋>" pos:(btnMsPos + [0,7 * btnMsHeight]) width:btnMsWidth height:btnMsHeight
	border:true visible:true

	fn fnAddMyScript btnMyScript idMyScript =
	(
		dirScript = getOpenFileName caption:"请选择添加的Max脚本:" historyCategory:"myScripts" \
		types:"maxscript(*.ms,*.mse,*.mzp)|*.m*|All(*.*)|*.*" filename:(getDir #scripts + @"\") 
		if (dirScript != undefined) then
		(
			arrMsTemp           = fnLoadMsArray()
			nameMyScript        = getFilenameFile dirScript
			btnMyScript.text    = nameMyScript
			btnMyScript.tooltip = dirScript
			arrMsTemp[idMyScript].msName = nameMyScript
			arrMsTemp[idMyScript].dir    = dirScript
			fnSaveMsArray arrMsTemp
			messagebox "右键可重新设置脚本快捷键!\r\n\r\n(按钮较窄,建议右键设置脚本昵称~)                                "
		)
		stSetConfigAll.fnSetConfigBsScriptsSet ()
	)

	fn fnRefreshMyScripts =
	(
		fnRefreshMyMsBtn()
		arrMsTemp = fnLoadMsArray()
		for b = 1 to arrMyMsBtn.count do 
		(
			if arrMsTemp[b] != undefined then
			(
				if (arrMsTemp[b].msName != undefined) then 
				(
					arrMyMsBtn[b].text    = arrMsTemp[b].msName
					arrMyMsBtn[b].tooltip = arrMsTemp[b].dir
				)
				else 
				(
					arrMyMsBtn[b].text    = "<＋＋>"
					arrMyMsBtn[b].tooltip = "<＋＋>"
				)
			)
		)
		fnSaveMsArray arrMsTemp
	)

	fn fnSwitchToolBtnChecked Btn =
	(
		arrMsBtn = #(rolBsScriptsSet.ckbMs1,rolBsScriptsSet.ckbMs2,rolBsScriptsSet.ckbMs3,rolBsScriptsSet.ckbMs4,rolBsScriptsSet.ckbMs5)
		for i = 1 to arrMsBtn.count do
		(
			if i != Btn then 
			(
				arrMsBtn[i].checked = false
			)
			else 
			(
				idMsBtn = Btn
				arrMsBtn[Btn].checked = true
			)
		)
	)

	on rolBsScriptsSet open do  ----打开脚本时操作
	(
		fnSwitchToolBtnChecked idMsBtn
		fnRefreshMyScripts()
	)
	
	on rolBsScriptsSet close do -- 关闭记忆浮动窗口位置
	(
		iniBsScriptsSetPos = (GetDialogPos rolBsScriptsSet)
		stSetConfigAll.fnSetConfigBsScriptsSet ()
	)
	-----------------------------------------------------------------------------------------
	on rolBsScriptsSet mbuttondown pos do 
	(
		try (destroydialog rolBsScriptsSet) catch ()
	)
	
	on rolBsScriptsSet lbuttondown posMou do
	(
		posMsMouMoved = posMou
		switchMsMouseState = on
	)

	on rolBsScriptsSet rbuttondown posMou do
	(
		if rolBsScriptsSet.height != undefined
		(
			if rolBsScriptsSet.height != 265 then rolBsScriptsSet.height = 265 else rolBsScriptsSet.height = 20
		)
	)
	
	on rolBsScriptsSet lbuttonup posMou do
	(
		switchMsMouseState = off
		iniBsScriptsSetPos = (GetDialogPos rolBsScriptsSet)
		stSetConfigAll.fnSetConfigBsScriptsSet()
	)
	
	on rolBsScriptsSet mouseMove pos do
	(
		-- myTimer.Start()
		if (ui_clientOffset == undefined) and (switchMsMouseState == off) then 
		(ui_clientOffset = pos - (mouse.screenPos - (getDialogPos rolBsScriptsSet)))
		if switchMsMouseState == on then
		(
			SetDialogPos rolBsScriptsSet (mouse.screenpos - posMsMouMoved)
		)
	)

	on btnMin pressed do
	(
		if rolBsScriptsSet.height != undefined
		(
			if rolBsScriptsSet.height != 265 then rolBsScriptsSet.height = 265 else rolBsScriptsSet.height = 20
		)
	)

	on ckbMs1 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 1 isMsBtn:true
			fnRefreshMyScripts()
		)
		else ckbMs1.checked = true
	)
	on ckbMs2 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 2 isMsBtn:true
			fnRefreshMyScripts()
		)
		else ckbMs2.checked = true
	)
	on ckbMs3 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 3 isMsBtn:true
			fnRefreshMyScripts()
		)
		else ckbMs3.checked = true
	)
	on ckbMs4 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 4 isMsBtn:true
			fnRefreshMyScripts()
		)
		else ckbMs4.checked = true
	)
	on ckbMs5 changed state do 
	(
		if state == true then 
		(
			fnSwitchToolBtnChecked 5 isMsBtn:true
			fnRefreshMyScripts()
		)
		else ckbMs5.checked = true
	)

	on btnMyScripts1 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[1] != undefined) and (doesfileexist arrMsTemp[1].dir)) then 
		(
			try(fileIn arrMsTemp[1].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts1.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts1 1
		)
	)
	on btnMyScripts2 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[2] != undefined) and (doesfileexist arrMsTemp[2].dir)) then 
		(
			try(fileIn arrMsTemp[2].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts2.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts2 2
		)
	)
	on btnMyScripts3 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[3] != undefined) and (doesfileexist arrMsTemp[3].dir)) then 
		(
			try(fileIn arrMsTemp[3].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts3.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts3 3
		)
	)
	on btnMyScripts4 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[4] != undefined) and (doesfileexist arrMsTemp[4].dir)) then 
		(
			try(fileIn arrMsTemp[4].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts4.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts4 4
		)
	)
	on btnMyScripts5 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[5] != undefined) and (doesfileexist arrMsTemp[5].dir)) then 
		(
			try(fileIn arrMsTemp[5].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts5.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts5 5
		)
	)
	on btnMyScripts6 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[6] != undefined) and (doesfileexist arrMsTemp[6].dir)) then 
		(
			try(fileIn arrMsTemp[6].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts6.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts6 6
		)
	)
	on btnMyScripts7 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[7] != undefined) and (doesfileexist arrMsTemp[7].dir)) then 
		(
			try(fileIn arrMsTemp[7].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts7.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts7 7
		)
	)
	on btnMyScripts8 pressed do 
	(
		arrMsTemp = fnLoadMsArray()
		if ((arrMsTemp[8] != undefined) and (doesfileexist arrMsTemp[8].dir)) then 
		(
			try(fileIn arrMsTemp[8].dir)catch(messagebox "打开失败，可能脚本错误或安装不完全...                            " beep:false title:"BsKeyTools")
		)
		else 
		(
			if btnMyScripts8.text != "<＋＋>" then 
			(messagebox "找不到该脚本，请确认脚本路径或重新指定！                         " title:"BsKeyTools";)
			fnAddMyScript btnMyScripts8 8
		)
	)

	on btnMyScripts1 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor \
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y +20]
	)
	on btnMyScripts2 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor \
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y + 20]
	)
	on btnMyScripts3 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor\
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y + 20]
	)
	on btnMyScripts4 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor\
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y + 20]
	)
	on btnMyScripts5 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor\
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y + 20]
	)
	on btnMyScripts6 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor\
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y + 20]
	)
	on btnMyScripts7 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor\
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y + 20]
	)
	on btnMyScripts8 rightclick do 
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor\
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y + 20]
	)
	
	on btnClose pressed do 
	(
		try (destroydialog rolBsScriptsSet) catch()
	)

	on btnConfig pressed do
	(
		try(destroydialog rolAddMyMs)catch()
		createDialog rolAddMyMs fgcolor:myFgColor \
		pos:[mouse.screenpos.x - 150,mouse.screenpos.y +20]
	)
)
if (iniBsScriptsSetPos != 0) then (Createdialog rolBsScriptsSet fgcolor:myFgColor pos:iniBsScriptsSetPos style:#())
else (Createdialog rolBsScriptsSet pos:(iniPos - [rolBsScriptsSet.width,0]) fgcolor:myFgColor style:#())
clearListener()  ---------清除侦听器