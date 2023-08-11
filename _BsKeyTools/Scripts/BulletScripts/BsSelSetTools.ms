/*
 * @Description: 选择集工具 参考自:@Takayuki Sato
 * @Author: Bullet.S
 * @Date: 2021-05-07 12:33:36
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-08-20 22:44:44
 * @Email: animator.bullet@foxmail.com
 */

try(destroydialog rolSelSetTools)catch()
try (callbacks.removeScripts #filePostOpen id:#UpdateSelSetList) catch ()

global iniPosSelSetTools

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
stLoadConfigAll.fnLoadConfigSelSetTools ()

global rolSelSetTools
global rolLoadSelSet

global strXmlRootName = "SelectionSet_Tools"
Global switchRolSelSetMouState = false
Global posRolSelSetMouMove     = [0,0]

global arrSelSetNameLoaded
global arrSelSetObjLoaded

fn fnSaveSelSetAll pathXml = 
(
	local dotNetXmlDoc = dotNetObject "System.xml.xmlDocument"
	local rootElement = dotNetXmlDoc.createElement strXmlRootName
	dotNetXmlDoc.appendChild rootElement

	for s in selectionSets do
	(
		local setElement = dotNetXmlDoc.createElement "SelectionSet"
		setElement.SetAttribute "SetName" s.name
		rootElement.appendChild setElement

		for o in s do
		(
			local objElement = dotNetXmlDoc.createElement "ObjectName"
			objElement.InnerText = o.name
			setElement.appendChild objElement
		)
	)
	dotNetXmlDoc.save pathXml
)

fn fnLoadSelXml pathXml = 
(
	local dotNetXmlDoc = dotNetObject "System.xml.xmlDocument"
	dotNetXmlDoc.Load pathXml
	local rootElement = dotNetXmlDoc.DocumentElement
	
	if rootElement.name != strXmlRootName then
	(
		messagebox "这不是BsSelSetTools创建的XML文件。          \t"
		undefined
	)
	
	local nodesSelSet = rootElement.ChildNodes

	local arrSelSetName = #()
	local arrSelSetObj = #()

	for i = 0 to nodesSelSet.count - 1 do
	(
		local elemSelSet = nodesSelSet.Item[i]
		
		append arrSelSetName (elemSelSet.Attributes.GetNamedItem "SetName").value
		
		local objNodes = elemSelSet.ChildNodes
		
		arrSelSetObj[i+1] = #()
		for j = 0 to objNodes.count - 1 do
		(
			local objElement = objNodes.Item[j]
			append arrSelSetObj[i+1] objElement.InnerText
		)
	)
	local result = #(arrSelSetName, arrSelSetObj)
	result
)

fn fnCreateSelSet arrSelSetName arrSelSetObj n = 
(
	local re_selset_obj_list = #()
	for o in arrSelSetObj[n] do
	(
		if getNodeByName o != undefined  then
		(
			append re_selset_obj_list o
		)
	)
	if re_selset_obj_list.count != 0 then
	(
		local txt = "selectionSets[\""
		txt += arrSelSetName[n] + "\"] = #("
		for o in re_selset_obj_list do
		(
			txt += "$'" + o +"', "
		)
		txt = substring txt  1 (txt.count - 2)
		txt+= ")"

		execute txt
	)else
	(
		messagebox( "Selection Set \"" + arrSelSetName[n] + "\" 是空的。\n选择集\"" + arrSelSetName[n] + "\"包含的对象不在场景中，所以未被读取...                    \t")
	)
)

fn fnSortNames str1 str2 = stricmp str1 str2

fn fnUpdateSelSetList = 
(
	local arrNodesList = #()
	for s in selectionSets do
	(
		append arrNodesList s.name
	)
	qsort arrNodesList fnSortNames
	rolSelSetTools.mlbSelSet.items = arrNodesList
	rolSelSetTools.mlbSelSet.selection = 0
	rolSelSetTools.mlbSelSetNode.items = #()
	rolSelSetTools.lblCount.text = "共 " + selectionsets.count as string + " 个选择集"
)

rollout rolCreateSelSet "创建选择集"
(
	edittext edtCreateName "命名:" width:190 pos:[5,5]
	button btnDoCreate "以选中物体创建选择集" width:190 pos:[5,30]
	
	on edtCreateName entered c do (rolCreateSelSet.btnDoCreate.pressed())

	on btnDoCreate pressed do 
	(
		local strCreate = edtCreateName.text
		local arrSelection = getcurrentselection()
		local arrSelSetName = for i in selectionsets collect i.name
		if ((strCreate != "") or (strCreate != undefined)) then 
		(
			if finditem arrSelSetName strCreate != 0 then
			(
				local duplicateSelSetName = arrSelSetName[finditem arrSelSetName strCreate]
				if (queryBox ("当前已有重名选择集，\r\n\r\n重名选择集：\"" + duplicateSelSetName + "\"\r\n\r\n是否将选择物体添加进该选择集？                                  ") \
				title:"选择集重名" beep:false) then
				(
					selectionsets[duplicateSelSetName] = join (join #() selectionsets[duplicateSelSetName]) arrSelection
					fnUpdateSelSetList()
				)
			)
			else (selectionsets[strCreate] = arrSelection;fnUpdateSelSetList())
		)
		rolSelSetTools.fnAutoSetHeight()
		try(destroydialog rolCreateSelSet)catch()
	)
)

rollout rolLoadSelSet "加载选择集"
(
	multilistbox mlbLoadSelSet "选择集列表" height:22
	button btnLoadSel "加载选中" width:80 height: 25 across:2
	button btnLoadAll "加载所有" width:80 height:25
		
	on btnLoadSel pressed do
	(
		for n in mlbLoadSelSet.selection do
		(
			fnCreateSelSet arrSelSetNameLoaded arrSelSetObjLoaded n
		)
		fnUpdateSelSetList()
		try(destroydialog rolLoadSelSet)catch()
	)
	
	on btnLoadAll pressed do(
		for n = 1 to mlbLoadSelSet.items.count do
		(
			fnCreateSelSet arrSelSetNameLoaded arrSelSetObjLoaded n
		)
		fnUpdateSelSetList()
		try(destroydialog rolLoadSelSet)catch()
	)
)

rollout rolSelSetTools ""
(
	groupbox grpMain "BsSelSetTools_v1.0--MoveMe" width:180 height:277 pos:[5,0]

	MultiListBox mlbSelSet "" width:170 height:15 pos:[10,55]
	label lblCount "" width:170 height:15 pos:[10,40]
	
	button btnCloseRol "关闭" width:35 height:20 pos:[10,15]
	button btnUpdateList "更新列表" width:90 height:20 pos:[45,15]
	checkbutton chkMoreTools "更多" width:45 height:20 pos:[135,15]

	button btnCreateSelSet "" width:30 height:20 pos:[195,35] enabled:false tooltip:"创建选择集"
	button btnDeleteSelSet "" width:30 height:20 pos:[225,35] enabled:false tooltip:"删除选择集"
	button btnAddToSelSet "" width:30 height:20 pos:[255,35] enabled:false tooltip:"添加所选物体到选中的选择集"
	button btnRemoveFromSelSet "" width:30 height:20 pos:[285,35] enabled:false tooltip:"从选中的选择集中移除所选物体"
	button btnHighlightSelObj "" width:30 height:20 pos:[315,35] enabled:false tooltip:"高亮选中物体及其所在选择集"
	MultiListBox mlbSelSetNode "" width:160 height:15 pos:[190,55] enabled:false
	button btnSaveXml "保存" width:60 height:20 pos:[190,15] enabled:false
	button btnLoadXml "加载" width:60 height:20 pos:[250,15] enabled:false
	button btnHelp "帮助" width:40 height:20 pos:[310,15] enabled:false

	fn fnAutoSetHeight =
	(
		if (not chkMoreTools.state) or (chkMoreTools.state and (mlbSelSetNode.items as array).count < 15) then 
		(
			if selectionsets.count <= 5 then
			(
				mlbSelSet.height = 72.5
				mlbSelSetNode.height = 72.5
			)
			else if selectionsets.count >= 5 and selectionsets.count <= 15 then
			(
				mlbSelSet.height = selectionsets.count * 14.5
				mlbSelSetNode.height = selectionsets.count * 14.5
				
			)
			else if selectionsets.count > 15 then
			(
				mlbSelSet.height = 217
				mlbSelSetNode.height = 217
			)
		)
		else if chkMoreTools.state and (mlbSelSetNode.items as array).count > 15 then 
		(
			mlbSelSet.height = 217
			mlbSelSetNode.height = 217
		)
		rolSelSetTools.height = mlbSelSet.height + 65
		grpMain.height = mlbSelSetNode.height + 60
	)

	fn fnUpdateMoreToolsState =
	(
		if chkMoreTools.state then 
		(rolSelSetTools.width = 360;grpMain.width = 350)
		else (rolSelSetTools.width = 190;grpMain.width = 180)
	)

	fn fnUpdateSelSetNodeList selSetAll =
	(
		local arrSelSetNodesName = #()
		for i in selSetAll do
		(
			join arrSelSetNodesName (for i in selectionsets[mlbSelSet.items[i]] collect i.name)
		)
		arrSelSetNodesName = makeUniqueArray arrSelSetNodesName
		qsort arrSelSetNodesName fnSortNames
		-- print arrSelSetNodesName
		mlbSelSetNode.items = arrSelSetNodesName
		mlbSelSetNode.selection = 0
		lblCount.text = "当中共有 " + arrSelSetNodesName.count as string + " 个物体"
	)
	fn fnAddRemoveNode tarSelSet action =
	(
		local arrSelection = getcurrentselection()
		if arrSelection != undefined then 
		(
			case of
			(
				(action == "Add"):(tarSelSet = join (join #() tarSelSet) arrSelection)
				(action == "Del"):
				(
					for o in arrSelection do 
					(
						tarSelSet = for n in tarSelSet where n != o collect n
					)
				)
			)
		)
		tarSelSet
	)

	fn fnRefreshBtnEnabled =
	(
		btnSaveXml.enabled          = chkMoreTools.state
		btnLoadXml.enabled          = chkMoreTools.state
		mlbSelSetNode.enabled       = chkMoreTools.state
		btnHelp.enabled             = chkMoreTools.state
		btnCreateSelSet.enabled     = chkMoreTools.state
		btnDeleteSelSet.enabled     = chkMoreTools.state
		btnAddToSelSet.enabled      = chkMoreTools.state
		btnRemoveFromSelSet.enabled = chkMoreTools.state
		btnHighlightSelObj.enabled  = chkMoreTools.state
	)

	on btnCloseRol pressed do (try (destroydialog rolSelSetTools) catch ())

	on btnHelp pressed do 
	(shellLaunch "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" "")

	on rolSelSetTools mbuttondown pos do (try (destroydialog rolSelSetTools) catch ())

	on rolSelSetTools lbuttondown posMou do
	(
		posRolSelSetMouMove = posMou
		switchRolSelSetMouState = on
	)

	on rolSelSetTools lbuttonup posMou do switchRolSelSetMouState = off

	on rolSelSetTools mouseMove pos do if switchRolSelSetMouState do
		SetDialogPos rolSelSetTools (mouse.screenpos - posRolSelSetMouMove)

	on rolSelSetTools open do
	(
		
		stLoadConfigAll.fnLoadConfigSelSetTools()  ---------------脚本位置等赋值
		stSetConfigAll.fnSetConfigSelSetTools()  ----------------保存位置信息到ini文件
		btnCreateSelSet.images     = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,1,1,2,2,false,true)
		btnDeleteSelSet.images     = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
		btnAddToSelSet.images      = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,5,5,6,6,false,true)
		btnRemoveFromSelSet.images = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,7,7,8,8,false,true)
		btnHighlightSelObj.images  = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,12,12,13,13,false,true)
		fnUpdateMoreToolsState()
		fnRefreshBtnEnabled()
		fnUpdateSelSetList()
		fnAutoSetHeight()
	)

	on rolSelSetTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosSelSetTools   = (GetDialogPos rolSelSetTools)
        stSetConfigAll.fnSetConfigSelSetTools ()
	)

	on btnSaveXml pressed do
	(
		local save_path = getSaveFileName caption:"Save XML File " filename:".xml" types:"XML(*.xml)|*.xml|"
		if save_path != undefined then
		(
			fnSaveSelSetAll save_path
		)
	)	

	on btnLoadXml pressed do
	(
		local pathLoad = getOpenFileName caption:"Load XML File" types:"XML(*.xml)|*.xml|"
		if pathLoad != undefined then
		(
			local dataLoad = fnLoadSelXml pathLoad
			
			if dataLoad != undefined then
			(
				print (dataLoad as string)
				arrSelSetNameLoaded = dataLoad[1]
				arrSelSetObjLoaded  = dataLoad[2]
				iniPosSelSetTools   = (GetDialogPos rolSelSetTools)
				createdialog rolLoadSelSet pos:[iniPosSelSetTools.x+rolSelSetTools.width, iniPosSelSetTools.y ] width:200 height:350 parent:rolSelSetTools.hwnd
				rolLoadSelSet.mlbLoadSelSet.items = dataLoad[1]
			)
		)
	)

	on btnUpdateList pressed do
	(
		fnUpdateSelSetList()
		fnAutoSetHeight()
	)

	on mlbSelSet doubleClicked val do 
	(
		if (selectionsets[mlbSelSet.items[val]] != undefined) then 
		(
			select selectionsets[mlbSelSet.items[val]]
			fnUpdateSelSetNodeList mlbSelSet.selection
			fnAutoSetHeight()
		)
	)	

	on mlbSelSet selectionEnd do
	(
		if (mlbSelSet.selection as array).count != 0 then
		(
			clearselection()
			for i in (mlbSelSet.selection as array) do 
			(
				selectmore selectionsets[mlbSelSet.items[i]]
			)
			fnUpdateSelSetNodeList mlbSelSet.selection
			fnAutoSetHeight()
		)	
	)

	on btnDeleteSelSet pressed do with undo "DeleteSelSet" on
	(
		if (mlbSelSet.selection as array).count != 0 then
		(
			for i in (mlbSelSet.selection as array) do 
			(
				deleteItem selectionSets mlbSelSet.items[i]
			)
			fnUpdateSelSetList()
			fnAutoSetHeight()
		)
	)

	on btnAddToSelSet pressed do
	(
		if (mlbSelSet.selection as array).count != 0 then
		(
			for i in (mlbSelSet.selection as array) do 
			(
				selectionsets[mlbSelSet.items[i]] = fnAddRemoveNode selectionsets[mlbSelSet.items[i]] "Add"
			)
			fnUpdateSelSetNodeList (mlbSelSet.selection as array)
			fnAutoSetHeight()
		)
	)

	on btnRemoveFromSelSet pressed do undo "RemoveSelSet" on
	(
		if (mlbSelSet.selection as array).count != 0 then
		(
			for i in (mlbSelSet.selection as array) do 
			(
				selectionsets[mlbSelSet.items[i]] = fnAddRemoveNode selectionsets[mlbSelSet.items[i]] "Del"
			)
			fnUpdateSelSetNodeList (mlbSelSet.selection as array)
			fnAutoSetHeight()
		)
	)

	on btnHighlightSelObj pressed do 
	(
		local arrCurSelection = getCurrentSelection()
		local arrCurSelSet = #()
		local arrSelIndex = #()
		for i in (mlbSelSet.selection as array) do 
		(
			join arrCurSelSet selectionsets[mlbSelSet.items[i]]
		)
		makeUniqueArray arrCurSelSet
		for i in arrCurSelection do 
		(
			local indexTemp = findItem mlbSelSetNode.items i.name
			if indexTemp != 0 then append arrSelIndex indexTemp
		)
		mlbSelSetNode.selection = arrSelIndex
		lblCount.text = "选中高亮 " + arrSelIndex.count as string + " 个物体"
	)

	on btnCreateSelSet pressed do 
	(
		local arrSelection = getCurrentselection()
		if arrSelection != undefined then 
		(
			iniPosSelSetTools   = (GetDialogPos rolSelSetTools)
			createdialog rolCreateSelSet pos:[iniPosSelSetTools.x - 210,iniPosSelSetTools.y] width:200 height:55 parent:rolSelSetTools.hwnd
			setfocus rolCreateSelSet.edtCreateName 
		)
	)

	on mlbSelSetNode doubleClicked val do 
	(
		if (getNodeByName mlbSelSetNode.items[val] != undefined) then (select (getNodeByName mlbSelSetNode.items[val]))
	)	

	on mlbSelSetNode selectionEnd do 
	(
		if mlbSelSetNode.selection != 0 then
		(
			local strSelSetNode = for i in mlbSelSetNode.selection collect mlbSelSetNode.items[i]
			clearselection()
			for o in strSelSetNode where (getNodeByName o != undefined) do selectmore (getNodeByName o)
		)
	)

	on chkMoreTools changed state do 
	(
		fnUpdateMoreToolsState ()
		fnRefreshBtnEnabled()
		fnAutoSetHeight()
	)

)
if (iniPosSelSetTools != 0) then 
(Createdialog rolSelSetTools 360 295 fgcolor:myFgColor pos:iniPosSelSetTools style:#())
else (Createdialog rolSelSetTools 360 295 fgcolor:myFgColor style:#())

callbacks.addScript #filePostOpen "fnUpdateSelSetList()" id:#UpdateSelSetList