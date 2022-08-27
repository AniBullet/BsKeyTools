(if ATIcons == undefined then (fileIn ((getFilenamePath(getThisScriptFilename())) + "AssemblyToolIcons.ms")))
(if ATfn_ == undefined then (fileIn ((getFilenamePath(getThisScriptFilename())) + "AssemblyToolStruct.ms")))
	-----------------
(
Global floater_Collider
Global floater_AssemblyTool
try (if floater_Collider.dialogBar then (cui.UnRegisterDialogBar floater_Collider); closeRolloutFloater floater_Collider) catch()
	-------------------------------------------------------------------------------------------------------------------
local floaterTitle = "Collider"
local iniPath = (getDir #maxData)
local iniFile = iniPath + "Collider_Settings.ini"
local fl0W = 220; local fl0H = (ATfn_.GetINI 0 iniFile floaterTitle "LastSize" [fl0W,530])[2]
-- local fl0P = ATfn_.GetINI 0 iniFile floaterTitle "LastPosition" [50,50]
local colCHBX = ATfn_.GetINI 0 (iniPath + "AssemblyTool_Settings.ini") "Preferences" "color_PS_ChBxColor" [255,156,0]
local ExcludedControls = #("prgrs_CO_ProBar", "tmr_CO_prgrsFade", "btn_CO_DockLeft", "btn_CO_DockFloat", "btn_CO_DockRight", \
	"chbtn_CO_MagnetizeObjects", "chbtn_CO_Uncollide")
	----=Collider==========================================================================================================================
local SimArr = #()
local DynamicArr = #()
local StaticArr = #()
local SimCenter = [0,0,0]
	-------
rollout rollout_CO_ "Collider"
(
local yp1 = #(18, 158, 300, 337, 362, 383, 403, 448, 490)
-- local yp1 = #(18, 158, 300, 337, 362, 383, 403, 403, 453)
local DockX = 181; local DockW = 13
button btn_CO_DockLeft "<" pos:[DockX-DockW,0] width:DockW height:10 tooltip:" 嵌入左边 "
button btn_CO_DockFloat "::" pos:[DockX,0] width:DockW height:10 tooltip:" 浮动窗口 "
button btn_CO_DockRight ">" pos:[DockX+DockW,0] width:DockW height:10 tooltip:" 嵌入右边 "
on btn_CO_DockLeft pressed do (ATfn_.DockFloaterSide floater_Collider iniFile "left")
on btn_CO_DockRight pressed do (ATfn_.DockFloaterSide floater_Collider iniFile "right")
on btn_CO_DockFloat pressed do (ATfn_.DockFloaterFloat floater_Collider iniFile fl0W fl0H)
	-------
label lbl_CO_Dynamica "动态物体 / Dynamic :" pos:[2,yp1[1]-16]
radiobuttons rdbtn_CO_SelectedOrList "" labels:#("所选","列表") pos:[54,yp1[1]-16] columns:2 offsets:#([55,yp1[1]],[5,yp1[1]]) default:2 tooltip:" 使用选定的场景对象散布 \n 或以列表中的对象散布 "
button btn_CO_AddObjDynamic "+" width:22 height:21 pos:[0,yp1[1]] images:ATIcons[1] tooltip:" 将对象添加到动态物体列表 "
button btn_CO_RemoveObjDynamic "-" width:22 height:21 pos:[26,yp1[1]] images:ATIcons[2] tooltip:" 从动态物体列表中删除对象 "
button btn_CO_RemoveAllObjDynamic "_" width:22 height:21 pos:[52,yp1[1]] images:ATIcons[3] tooltip:" 从列表中删除所有动态对象 "
button btn_CO_SelectAllDynamic "All" width:22 height:21 pos:[78,yp1[1]] images:ATIcons[4] tooltip:" 选择所有动态对象 "
multilistBox mlbx_CO_Dynamic items:#() width:(fl0W-16) height:7 pos:[2,yp1[1]+22] selection:1 tooltip:" 动态物体 "

label lbl_CO_Static "静态物体 / Static :" pos:[2,yp1[2]-16]
button btn_CO_AddObjStatic "+" width:22 height:21 pos:[0,yp1[2]] images:ATIcons[1] tooltip:" 将对象添加到静态物体列表 "
button btn_CO_RemoveObjStatic "-" width:22 height:21 pos:[26,yp1[2]] images:ATIcons[2] tooltip:" 从静态物体列表中删除对象 "
button btn_CO_RemoveAllObjStatic "_" width:22 height:21 pos:[52,yp1[2]] images:ATIcons[3] tooltip:" 从列表中删除所有静态对象 "
button btn_CO_SelectAllStatic "All" width:22 height:21 pos:[78,yp1[2]] images:ATIcons[4] tooltip:" 选择所有静态对象 "
multilistBox mlbx_CO_Static items:#() width:(fl0W-16) height:7 pos:[2,yp1[2]+22] selection:1 tooltip:" 静态物体 "

radiobuttons rdbtn_CO_BBoxOrVolSel "" labels:#("包围盒","内部顶点") pos:[10,yp1[3]-18] columns:2 offsets:#([0,0],[0,0]) default:1 \
tooltip:" 通过包围盒 \n 或 \n 物体2 体积内的 物体1顶点 检测相交 "

checkButton chbtn_CO_MagnetizeObjects "磁吸化" pos:[0,yp1[3]] width:70 height:30 highlightColor:colCHBX tooltip:" 将动态对象磁吸到静态物体 "
spinner spnr_CO_Loops "循环限制:" pos:[130,yp1[3]] width:70 range:[1,999,5] type:#integer scale:1 toolTip:" 模拟循环限制 "
spinner spnr_CO_Iterations "距离精度:" pos:[127,yp1[3]+17] width:74 range:[1,16,5] type:#integer scale:1 toolTip:" 距离近似精度 "

checkButton chbtn_CO_BySize "按大小" pos:[0,yp1[4]-5] width:27 height:26 images:ATIcons[22] checked:false highlightColor:colCHBX tooltip:" 按大小解除碰撞 "
spinner spnr_CO_BySizeSteps "大小步长:" pos:[70,yp1[4]+4] width:50 range:[1,9,5] type:#integer scale:1 enabled:false toolTip:" 按大小步长解除碰撞 "
checkButton chbtn_CO_PositionLockX "X" pos:[130,yp1[4]] width:23 height:21 checked:true highlightColor:[204,64,64] tooltip:" 按 X 移动 "
checkButton chbtn_CO_PositionLockY "Y" pos:[155,yp1[4]] width:23 height:21 checked:true highlightColor:[63,164,63] tooltip:" 按 Y 移动 "
checkButton chbtn_CO_PositionLockZ "Z" pos:[180,yp1[4]] width:23 height:21 checked:true highlightColor:[70,114,255] tooltip:" 按 Z 移动 "

radiobuttons rdbtn_CO_StaticObjectsOrPoint "" labels:#("物体中心","静态物体") pos:[12,yp1[5]] columns:2 offsets:#([0,0],[0,0]) default:1 tooltip:" Use Processed Objects Mean \n Or Static Objects (Multiple) \n As Simulation Center "

checkButton chbtn_CO_SetWireColorState pos:[4,yp1[6]] width:14 height:14 highlightColor:colCHBX tooltip:" 为已处理的对象设置统一的线颜色 "
label lbl_CO_SetWireColorState "为已处理的对象设置统一的线颜色" pos:[22,yp1[6]]

GroupBox grp_CO_ "Collapse" pos:[2,yp1[7]] width:(fl0W-15) height:40
button btn_CO_Collapse "堆叠 | Collapse" pos:[86,yp1[7]+14] width:115 height:21 tooltip:" 将对象堆叠到所有物体中心 "
checkButton chbtn_CO_CollapseByX "X" pos:[7,yp1[7]+14] width:23 height:21 checked:true highlightColor:[204,64,64] tooltip:" 按 X 堆叠 "
checkButton chbtn_CO_CollapseByY "Y" pos:[32,yp1[7]+14] width:23 height:21 checked:true highlightColor:[63,164,63] tooltip:" 按 Y 堆叠 "
checkButton chbtn_CO_CollapseByZ "Z" pos:[58,yp1[7]+14] width:23 height:21 checked:true highlightColor:[70,114,255] tooltip:" 按 Z 堆叠 "

checkButton chbtn_CO_Uncollide "模拟碰撞，解除交叉重合" pos:[0,yp1[8]] width:(fl0W-13) height:37 highlightColor:colCHBX tooltip:" 解除对象交叉重合 "
progressBar prgrs_CO_ProBar pos:[0,yp1[9]] width:(fl0W-13) height:10 value:0 color:orange
timer tmr_CO_prgrsFade interval:((3*1000/68) as integer) active:false
on tmr_CO_prgrsFade tick do (ATfn_.ProgBarFade prgrs_CO_ProBar tmr_CO_prgrsFade)
	-------------------------------------------------------------------------------------------------------------------
-- local DynamicControlsArr = for cntr in rollout_CO_.controls where (matchPattern cntr.name pattern:"*Dynamic") collect cntr
local DynamicControlsArr = for cntr in rollout_CO_.controls where (matchPattern cntr.name pattern:"*Dynamic") and not (matchPattern cntr.name pattern:"btn_CO_SelectAllDynamic") collect cntr
local CenterControlsArr = for cntr in rollout_CO_.controls where (matchPattern cntr.name pattern:"*Center") collect cntr
	-------------------------------------------------------------------------------------------------------------------
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_VerifyItems =
(
DynamicArr = ATfn_.VerifyControlItems mlbx_CO_Dynamic
StaticArr = ATfn_.VerifyControlItems mlbx_CO_Static
SimArr = DynamicArr + StaticArr
)
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_Colision objct1 objct2 state GeomArr =
(
case state of
	(
	1: (intersects objct1 objct2)
	2: (if ((FindItem GeomArr objct1 > 0) and (FindItem GeomArr objct2 > 0)) then (((getVertSelection objct1) as array).count > 0) else (intersects objct1 objct2))
	)
)
	-----fn------------------------------------------------------------------------------------------------------------
	/*
FN fn_VolSelectSetNode ModifObj NodeObj ModsArr =
(
if ((FindItem ModsArr ModifObj > 0) and (FindItem ModsArr NodeObj > 0)) do
	(
	if NodeObj.modifiers[#Vol__Select].Node == ModifObj do (NodeObj.modifiers[#Vol__Select].Node = TNode)
-- 	try( if NodeObj.modifiers[#Vol__Select].Node == ModifObj do (NodeObj.modifiers[#Vol__Select].Node = TNode) )catch(print "ERROR --- TNode")
-- 	ModifObj.modifiers[#Vol__Select].Node = NodeObj
	try(ModifObj.modifiers[#Vol__Select].Node = NodeObj)
	catch
		(
		format " ModifObj = % \n NodeObj = % \n ModifObj.Node = % \n NodeObj.Node = % \n--------------------------------------\n" \
		ModifObj NodeObj (ModifObj.modifiers[#Vol__Select].Node) (NodeObj.modifiers[#Vol__Select].Node)
		)
	)
)
	-- */
FN fn_VolSelectSetNode ModifObj NodeObj ModsArr =
(
if ((FindItem ModsArr ModifObj > 0) and (FindItem ModsArr NodeObj > 0)) do
	(
	if NodeObj.modifiers[#Vol__Select].Node == ModifObj do (NodeObj.modifiers[#Vol__Select].Node = TNode)
	try(ModifObj.modifiers[#Vol__Select].Node = NodeObj)catch()
	)
)
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_AddModifs Arr =
(
local GArr = ATfn_.GetGeometry Arr
for objct in GArr do
	(
	if ((classOf objct.modifiers[1] != Edit_mesh) or (classOf objct.modifiers[2] != VolumeSelect)) do
		(
		addModifier objct (VolumeSelect level:1 volume:3)
		addModifier objct (Edit_mesh())
		)
	)
GArr
)
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_DeleteModifs modsArr =
(
setCommandPanelTaskMode #create
for objct in modsArr do
	(
	if ((classOf objct.modifiers[1] == Edit_mesh) and (classOf objct.modifiers[2] == VolumeSelect))
	do (for n=1 to 2 do (DeleteModifier objct 1))
	)
)
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_DeleteTemp =
(
try(delete (GetNodeByName "SimulationCenterPoint"))catch()
try(delete (GetNodeByName "SimulationTempNode"))catch()
)
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_compareByDistanceIncrease o1 o2 =
(
local o1d = Distance SimCenter o1.pos
local o2d = Distance SimCenter o2.pos
case of
	(
	(o1d < o2d): -1
	(o1d > o2d): 1
	default: 0
	)
)
FN fn_compareByDistanceDecrease o1 o2 =
(
local o1d = Distance SimCenter o1.pos
local o2d = Distance SimCenter o2.pos
case of
	(
	(o1d > o2d): -1
	(o1d < o2d): 1
	default: 0
	)
)
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_Move1 st o1 o2 dis = 
(
if st
then (o1.pos += dis)
else
	(
	if (FindItem StaticArr o2) > 0
	then (o1.pos -= dis)
	else (o2.pos -= dis)
	)
)
	-----fn------------------------------------------------------------------------------------------------------------
FN fn_Move2 st o1 o2 dis = 
(
if st
then (o1.pos -= dis)
else
	(
	if (FindItem StaticArr o2) > 0
	then (o1.pos += dis)
	else (o2.pos += dis)
	)
)
	-----fn------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_Collapse pressed do with undo on
(
local InArr = selection
if InArr.count == 0 do return ATfn_.messageNS()
local count = InArr.count
local center = [0,0,0]
for o in selection do center += o.pos; center /= count
local vecArr = for o in InArr collect (o.pos - center)
for n=1 to count do
	(
	local newPos = center + (normalize vecArr[n]) * (units.decodeValue "1mm")
	if not chbtn_CO_CollapseByX.checked do (newPos[1] = InArr[n].pos.x)
	if not chbtn_CO_CollapseByY.checked do (newPos[2] = InArr[n].pos.y)
	if not chbtn_CO_CollapseByZ.checked do (newPos[3] = InArr[n].pos.z)
	InArr[n].pos = newPos
	)
)
	-------------------------------------------------------------------------------------------------------------------
on rdbtn_CO_SelectedOrList changed state do (DynamicControlsArr.enabled = (state == 2))
	-------------------------------------------------------------------------------------------------------------------
on chbtn_CO_Uncollide changed state do with undo on
(
escapeEnable = false
local startTime= timeStamp()
local SelListState = (rdbtn_CO_SelectedOrList.state == 1)
local BBorVSState = (rdbtn_CO_BBoxOrVolSel.state == 2)
local StatPointState = (rdbtn_CO_StaticObjectsOrPoint.state == 2)
local BySizeState = chbtn_CO_BySize.state
local StartState = true
local ArhiveListDynamicArr = #()
local ModifsArr = #()
local selArr = selection as array
if state
then
(
if SelListState do
	(
	if (ATfn_.CheckEmpty selArr)
	then
		(
		ArhiveListDynamicArr = deepCopy DynamicArr
		DynamicArr = deepCopy (ATfn_.ArraysDifference (ATfn_.GetNHH selArr true) StaticArr)
		SimArr = StaticArr + DynamicArr
		)
	else (StartState = false)
	)
if StartState
then
(
if DynamicArr.count == 0 do (chbtn_CO_Uncollide.state = false; return messageBox "The Dynamic Objects List Or Selection Is Empty." title:" Collider" beep:false)
if StatPointState and StaticArr.count == 0 do (chbtn_CO_Uncollide.state = false; return messageBox "The Static Objects List Is Empty." title:" Collider" beep:false)
-- clearListener()
if chbtn_CO_SetWireColorState.checked do
	(
	if SelListState
	then ((ATfn_.GetArrayByHeads (ATfn_.ArraysDifference (ATfn_.GetNHH selArr true) StaticArr) ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	else ((ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false).wirecolor = (ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:true)[1].wirecolor)
	if StaticArr.count != 0 do ((ATfn_.GetArrayByHeads StaticArr ObjectsOnly:false).wirecolor = (ATfn_.GetArrayByHeads StaticArr ObjectsOnly:true)[1].wirecolor)
	)
clearSelection()
local CurrentTaskMode = getCommandPanelTaskMode()
setCommandPanelTaskMode #create
chbtn_CO_Uncollide.images = undefined
chbtn_CO_MagnetizeObjects.enabled = false; chbtn_CO_BySize.enabled = false; rdbtn_CO_StaticObjectsOrPoint.enabled = false
tmr_CO_prgrsFade.active = false; prgrs_CO_ProBar.value = 0; prgrs_CO_ProBar.color = orange
local Loops = spnr_CO_Loops.value
local Steps = spnr_CO_BySizeSteps.value; if BySizeState then (if Steps > DynamicArr.count then Steps = DynamicArr.count) else (Steps = 1)
-- local savedSimArr = deepCopy SimArr; local savedDynamicArr = deepCopy DynamicArr; local savedStaticArr = deepCopy StaticArr
local savedSimArr = SimArr; local savedDynamicArr = DynamicArr; local savedStaticArr = StaticArr
local SimGeomArr = ATfn_.GetGeometry SimArr

SimCenter = [0,0,0]; for obj in SimArr do SimCenter += obj.pos; SimCenter /= SimArr.count
local TNode = box name:"SimulationTempNode" isNodeHidden:true
TNode.pos = SimCenter

qSort DynamicArr ATfn_.CompareBySizeDecrease
for objct in SimArr do (InstanceMgr.MakeObjectsUnique objct #individual)
CenterPivot SimArr
if BBorVSState do (ModifsArr = fn_AddModifs SimArr)

local randomShift = units.decodeValue "1mm"
-- if chbtn_CO_PositionLockX.checked and not chbtn_CO_PositionLockY.checked and not chbtn_CO_PositionLockZ.checked do
-- 	(for o1 in DynamicArr do (for o2 in DynamicArr do (if o1.pos.x == o2.pos.x do o2.pos.x += random -randomShift randomShift)))
-- if chbtn_CO_PositionLockY.checked and not chbtn_CO_PositionLockX.checked and not chbtn_CO_PositionLockZ.checked do
-- 	(for o1 in DynamicArr do (for o2 in DynamicArr do (if o1.pos.y == o2.pos.y do o2.pos.y += random -randomShift randomShift)))
-- if chbtn_CO_PositionLockZ.checked and not chbtn_CO_PositionLockX.checked and not chbtn_CO_PositionLockY.checked do
-- 	(for o1 in DynamicArr do (for o2 in DynamicArr do (if o1.pos.z == o2.pos.z do o2.pos.z += random -randomShift randomShift)))
if chbtn_CO_PositionLockX.checked do
	(for o1 in DynamicArr do (for o2 in DynamicArr do (if o1.pos.x == o2.pos.x do o2.pos.x += random -randomShift randomShift)))
if chbtn_CO_PositionLockY.checked do
	(for o1 in DynamicArr do (for o2 in DynamicArr do (if o1.pos.y == o2.pos.y do o2.pos.y += random -randomShift randomShift)))
if chbtn_CO_PositionLockZ.checked do
	(for o1 in DynamicArr do (for o2 in DynamicArr do (if o1.pos.z == o2.pos.z do o2.pos.z += random -randomShift randomShift)))

local StepArrArr = deepCopy #(DynamicArr)
if BySizeState do
(
StepArrArr = #()
local SizeArr = #()
local DynMM = ATfn_.GetMinMax DynamicArr
for n=1 to DynamicArr.count do (append SizeArr (distance DynMM[1][n] DynMM[2][n]))
local SizeMax = (amax SizeArr)
local SizeMin = (amin SizeArr)
SizeMax *= 1.01; SizeMin /= 1.01
local StepSize = (SizeMax - SizeMin)/Steps
for step=1 to Steps do
	(
	local StepArr = #()
	for n=1 to DynamicArr.count do
		(
		local objSize = distance DynMM[1][n] DynMM[2][n]
		if objSize <= (SizeMax - StepSize*(step-1)) and objSize >= (SizeMax - StepSize*step) do (append StepArr DynamicArr[n])
		)
	if StepArr.count != 0 then (append StepArrArr StepArr)
	)
for s=2 to StepArrArr.count do (StepArrArr[s] = ATfn_.ArraysDifference StepArrArr[s] StepArrArr[s-1])
Steps = StepArrArr.count
)

for step=1 to Steps do
(
if keyboard.escPressed then exit; if not chbtn_CO_Uncollide.checked then exit
DynamicArr = deepCopy StepArrArr[step]
SimArr = StaticArr + DynamicArr
for loop=1 to Loops do
(
if keyboard.escPressed then exit; if not chbtn_CO_Uncollide.checked then exit
local Colision = false
local iters = spnr_CO_Iterations.value
if BySizeState
	then (chbtn_CO_Uncollide.text = "Step: " + (step as string) + "  |  Loop: " + (loop as string))
	else (chbtn_CO_Uncollide.text = "Loop: " + (loop as string))
qSort DynamicArr fn_compareByDistanceIncrease
for DynObjct in DynamicArr do
(
if keyboard.escPressed then exit; if not chbtn_CO_Uncollide.checked then exit
for SimObjct in SimArr do
(
if keyboard.escPressed then exit; if not chbtn_CO_Uncollide.checked then exit
if DynObjct != SimObjct and (intersects DynObjct SimObjct) do
(
if (((maxVersion())[1] / 1000) >= 13) do windows.processPostedMessages()
local DistSplit = (normalize (DynObjct.pos - SimObjct.pos))*(amin (distance DynObjct.max DynObjct.min) (distance SimObjct.max SimObjct.min))/2
if not chbtn_CO_PositionLockX.checked then DistSplit[1] = 0
if not chbtn_CO_PositionLockY.checked then DistSplit[2] = 0
if not chbtn_CO_PositionLockZ.checked then DistSplit[3] = 0
if BBorVSState do (fn_VolSelectSetNode DynObjct SimObjct ModifsArr)
if StatPointState
then
	(
	local DistArr = for Magnet in savedStaticArr collect (Distance DynObjct.pos Magnet.pos)
	SimCenter = (savedStaticArr[findItem DistArr (aMin DistArr)]).pos
	)
else 
	(
	SimCenter = [0,0,0]
	for obj in SimArr do SimCenter += obj.pos; SimCenter /= SimArr.count
	)
local disDS = (distance SimCenter DynObjct.pos) >= (distance SimCenter SimObjct.pos)
local BBorVS = rdbtn_CO_BBoxOrVolSel.state
for i=1 to iters do
	(
	local exiSt = false
	if (fn_Colision DynObjct SimObjct BBorVS SimGeomArr)
	then
		(
		Colision = true
		do (fn_Move1 disDS DynObjct SimObjct DistSplit)
		while (fn_Colision DynObjct SimObjct BBorVS SimGeomArr)
		)
	else
		(
		if i>1
		then (Colision = true; fn_Move2 disDS DynObjct SimObjct DistSplit)
		else
			(
			if BBorVSState do
				(
				fn_VolSelectSetNode SimObjct DynObjct ModifsArr
				)
			if (fn_Colision SimObjct DynObjct BBorVS SimGeomArr)
			then
				(
				Colision = true
				do (fn_Move1 disDS DynObjct SimObjct DistSplit)
				while (fn_Colision SimObjct DynObjct BBorVS SimGeomArr)
				)
			else (exiSt = true)
			if BBorVSState do
				(
				fn_VolSelectSetNode DynObjct SimObjct ModifsArr
				)
			)
		)
	DistSplit /= 2
	if exiSt then exit
	)---iters
redrawViews()
)
)---SimArr
prgrs_CO_ProBar.value = 100.0*(findItem DynamicArr DynObjct)/DynamicArr.count
)---DynamicArr
if not Colision then exit
)---Loops
StaticArr = StaticArr + DynamicArr
)---Steps

-- SimArr = deepCopy savedSimArr; DynamicArr = deepCopy savedDynamicArr; StaticArr = deepCopy savedStaticArr
SimArr = savedSimArr; DynamicArr = savedDynamicArr; StaticArr = savedStaticArr
setCommandPanelTaskMode #create
-- ResetPivot SimArr
-- fn_DeleteTemp()

setCommandPanelTaskMode CurrentTaskMode
chbtn_CO_Uncollide.state = false
chbtn_CO_Uncollide.text = "Uncollide  Objects"
chbtn_CO_MagnetizeObjects.enabled = true; chbtn_CO_BySize.enabled = true; rdbtn_CO_StaticObjectsOrPoint.enabled = true
-- (dotNetClass "System.Media.SystemSounds").Asterisk.Play()
)
else (chbtn_CO_Uncollide.checked = false)
)
else
	(
	chbtn_CO_Uncollide.text = "Uncollide  Objects"
	chbtn_CO_MagnetizeObjects.enabled = true; chbtn_CO_BySize.enabled = true; rdbtn_CO_StaticObjectsOrPoint.enabled = true
	)
if StartState do
	(
	fn_DeleteTemp()
	if BBorVSState do (fn_DeleteModifs ModifsArr)
	if SelListState
	then (select selArr; DynamicArr = deepCopy ArhiveListDynamicArr; SimArr = StaticArr + DynamicArr)
	else (select DynamicArr)
	)
prgrs_CO_ProBar.color = green; tmr_CO_prgrsFade.active = true
-- clearUndoBuffer()
-- gc light:true
gc()
format "Processing took % seconds\n" (filterString (((dotnetclass "TimeSpan").FromMilliseconds (timeStamp() - startTime)).ToString()) ".")[1]
)
	-------------------------------------------------------------------------------------------------------------------
on chbtn_CO_MagnetizeObjects changed state do with undo off
(
local SelListState = (rdbtn_CO_SelectedOrList.state == 1)
local BBorVSState = (rdbtn_CO_BBoxOrVolSel.state == 2)
local StartState = true
local ArhiveListDynamicArr = #()
local ModifsArr = #()
local selArr = selection as array
if StaticArr.count == 0 do (chbtn_CO_MagnetizeObjects.state = false; return messageBox "The Static Objects List Is Empty." title:" Collider" beep:false)
if state
then
(
if SelListState do
	(
	if (ATfn_.CheckEmpty selArr)
	then
		(
		ArhiveListDynamicArr = deepCopy DynamicArr
		DynamicArr = deepCopy (ATfn_.ArraysDifference (ATfn_.GetNHH selArr true) StaticArr)
		SimArr = StaticArr + DynamicArr
		)
	else (StartState = false)
	)
local SimGeomArr = ATfn_.GetGeometry SimArr
if StartState
then
(
if DynamicArr.count == 0 do (chbtn_CO_MagnetizeObjects.state = false; return messageBox "The Dynamic Objects List Or Selection Is Empty." title:" Collider" beep:false)
-- clearListener()
clearSelection()
local CurrentTaskMode = getCommandPanelTaskMode()
setCommandPanelTaskMode #create
local TNode = box name:"SimulationTempNode" isNodeHidden:true
chbtn_CO_Uncollide.enabled = false
tmr_CO_prgrsFade.active = false; prgrs_CO_ProBar.value = 0; prgrs_CO_ProBar.color = orange
local Iters = spnr_CO_Iterations.value
local Loops = spnr_CO_Loops.value
for objct in SimArr do (InstanceMgr.MakeObjectsUnique objct #individual)
CenterPivot SimArr
if BBorVSState do (ModifsArr = fn_AddModifs SimArr)
qSort DynamicArr ATfn_.CompareBySizeDecrease

-- 	/*
for ActObjct in DynamicArr do
(
if (((maxVersion())[1] / 1000) >= 13) do windows.processPostedMessages()
if keyboard.escPressed then exit
if not chbtn_CO_MagnetizeObjects.checked then exit
local DistArr = for Magnet in StaticArr collect (Distance ActObjct.pos Magnet.pos)
local NearStat = StaticArr[findItem DistArr (aMin DistArr)]
local NewDist = NearStat.pos - ( (normalize (NearStat.pos - ActObjct.pos)) * (Distance NearStat.max NearStat.min)/4 )
if not chbtn_CO_PositionLockX.checked then NewDist[1] = ActObjct.pos.x
if not chbtn_CO_PositionLockY.checked then NewDist[2] = ActObjct.pos.y
if not chbtn_CO_PositionLockZ.checked then NewDist[3] = ActObjct.pos.z
ActObjct.pos = NewDist
local DistSplit = (ActObjct.pos - NearStat.pos)/2
if not chbtn_CO_PositionLockX.checked then DistSplit[1] = 0.
if not chbtn_CO_PositionLockY.checked then DistSplit[2] = 0.
if not chbtn_CO_PositionLockZ.checked then DistSplit[3] = 0.
if BBorVSState do (fn_VolSelectSetNode ActObjct NearStat ModifsArr)
-- 	/*
local BBorVS = rdbtn_CO_BBoxOrVolSel.state
for i=1 to Iters do
	(
	local exiIter = false
	if (fn_Colision ActObjct NearStat BBorVS SimGeomArr)
	then
		(
		do (ActObjct.pos += DistSplit)
		while (fn_Colision ActObjct NearStat BBorVS SimGeomArr)
		)
	else
		(
		do (
			BBorVS = 1
			local lastDist = Distance ActObjct.pos NearStat.pos
			ActObjct.pos -= DistSplit
			if (lastDist < (Distance ActObjct.pos NearStat.pos)) do
				(
				local posDiff = ActObjct.pos - NearStat.pos
				if not chbtn_CO_PositionLockX.checked then posDiff[1] = 0.
				if not chbtn_CO_PositionLockY.checked then posDiff[2] = 0.
				if not chbtn_CO_PositionLockZ.checked then posDiff[3] = 0.
				ActObjct.pos -= 2*posDiff
				exiIter = true
				exit
				)
			)
		while (not (fn_Colision ActObjct NearStat BBorVS SimGeomArr))
		)
	if exiIter do exit
	DistSplit /= 2
	)---Iters
	-- */
redrawViews()
prgrs_CO_ProBar.value = 100.0*(findItem DynamicArr ActObjct)/DynamicArr.count
)
	-- */

-- ResetPivot SimArr
setCommandPanelTaskMode CurrentTaskMode
prgrs_CO_ProBar.color = green
tmr_CO_prgrsFade.active = true
chbtn_CO_MagnetizeObjects.checked = false
chbtn_CO_Uncollide.enabled = true
-- (dotNetClass "System.Media.SystemSounds").Asterisk.Play()
) else (chbtn_CO_MagnetizeObjects.checked = false)
) else (chbtn_CO_Uncollide.enabled = true)
if StartState do
	(
	fn_DeleteTemp()
	if BBorVSState do (fn_DeleteModifs ModifsArr)
	if SelListState
	then (select selArr; DynamicArr = deepCopy ArhiveListDynamicArr; SimArr = StaticArr + DynamicArr)
	else (select DynamicArr)
	)
prgrs_CO_ProBar.color = green; tmr_CO_prgrsFade.active = true
-- clearUndoBuffer()
-- gc light:true
gc()
)
	-------------------------------------------------------------------------------------------------------------------
local ch_CO_CArr = #(chbtn_CO_CollapseByX,chbtn_CO_CollapseByY,chbtn_CO_CollapseByZ)
on chbtn_CO_CollapseByX changed state do (if not chbtn_CO_CollapseByY.checked and not chbtn_CO_CollapseByZ.checked then (chbtn_CO_CollapseByX.checked = true))
on chbtn_CO_CollapseByY changed state do (if not chbtn_CO_CollapseByX.checked and not chbtn_CO_CollapseByZ.checked then (chbtn_CO_CollapseByY.checked = true))
on chbtn_CO_CollapseByZ changed state do (if not chbtn_CO_CollapseByX.checked and not chbtn_CO_CollapseByY.checked then (chbtn_CO_CollapseByZ.checked = true))
	---
on chbtn_CO_CollapseByX rightclick do (ch_CO_CArr.checked = false; chbtn_CO_CollapseByX.checked = true)
on chbtn_CO_CollapseByY rightclick do (ch_CO_CArr.checked = false; chbtn_CO_CollapseByY.checked = true)
on chbtn_CO_CollapseByZ rightclick do (ch_CO_CArr.checked = false; chbtn_CO_CollapseByZ.checked = true)
	-------------------------------------------------------------------------------------------------------------------
local ch_CO_LArr = #(chbtn_CO_PositionLockX,chbtn_CO_PositionLockY,chbtn_CO_PositionLockZ)
on chbtn_CO_PositionLockX changed state do (if not chbtn_CO_PositionLockY.checked and not chbtn_CO_PositionLockZ.checked then (chbtn_CO_PositionLockX.checked = true))
on chbtn_CO_PositionLockY changed state do (if not chbtn_CO_PositionLockX.checked and not chbtn_CO_PositionLockZ.checked then (chbtn_CO_PositionLockY.checked = true))
on chbtn_CO_PositionLockZ changed state do (if not chbtn_CO_PositionLockX.checked and not chbtn_CO_PositionLockY.checked then (chbtn_CO_PositionLockZ.checked = true))
	---
on chbtn_CO_PositionLockX rightclick do (ch_CO_LArr.checked = false; chbtn_CO_PositionLockX.checked = true)
on chbtn_CO_PositionLockY rightclick do (ch_CO_LArr.checked = false; chbtn_CO_PositionLockY.checked = true)
on chbtn_CO_PositionLockZ rightclick do (ch_CO_LArr.checked = false; chbtn_CO_PositionLockZ.checked = true)
	-------------------------------------------------------------------------------------------------------------------
on chbtn_CO_BySize changed state do (spnr_CO_BySizeSteps.enabled = state)
	-------------------------------------------------------------------------------------------------------------------
on rdbtn_CO_StaticObjectsOrPoint changed state do (for cntr in CenterControlsArr do (cntr.enabled = (state == 1)))
	-------------------------------------------------------------------------------------------------------------------
on mlbx_CO_Dynamic selectionEnd do with undo off 
(
clearSelection()
local items = mlbx_CO_Dynamic.items
local selArr = for s in mlbx_CO_Dynamic.selection where not IsDeleted (GetNodeByName items[s]) collect (GetNodeByName items[s])
select selArr
forceCompleteRedraw()
)
on mlbx_CO_Dynamic rightclick do with undo off (mlbx_CO_Dynamic.selection = #{})
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_AddObjDynamic pressed do with undo off
(
local selArr = ATfn_.GetNHH (selection as array) true
-- if (ATfn_.CheckEmpty selArr) and not chbtn_CO_Uncollide.checked do
if not chbtn_CO_Uncollide.checked do
	(
	if chbtn_CO_SetWireColorState.checked do
		(
		local DWC = if DynamicArr.count > 0 then (ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:true)[1].wirecolor else (ATfn_.RandomColor())
		(selection as array).wirecolor = DWC
		)
	DynamicArr = ATfn_.AddListBoxObjects selArr mlbx_CO_Dynamic DynamicArr
	StaticArr = ATfn_.RemoveListBoxObjects selArr mlbx_CO_Static StaticArr
	SimArr = DynamicArr + StaticArr
	mlbx_CO_Dynamic.selection = mlbx_CO_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_RemoveObjDynamic pressed do with undo off
(
local selArr = ATfn_.GetNHH (selection as array) true
if not chbtn_CO_Uncollide.checked then
	(
	if chbtn_CO_SetWireColorState.checked do ((ATfn_.GetArrayByHeads (ATfn_.ArraysIntersect selArr DynamicArr) ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	DynamicArr = ATfn_.RemoveListBoxObjects selArr mlbx_CO_Dynamic DynamicArr
	SimArr = DynamicArr + StaticArr
	mlbx_CO_Dynamic.selection = mlbx_CO_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_RemoveAllObjDynamic pressed do with undo off
(
if not chbtn_CO_Uncollide.checked then
	(
	if chbtn_CO_SetWireColorState.checked do ((ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	DynamicArr = #()
	mlbx_CO_Dynamic.items = #()
	SimArr = DeepCopy StaticArr
	mlbx_CO_Dynamic.selection = mlbx_CO_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_SelectAllDynamic pressed do with undo on (clearSelection(); select DynamicArr; redrawviews())
	-------------------------------------------------------------------------------------------------------------------
on mlbx_CO_Static selectionEnd do
with undo off 
(
clearSelection()
local items = mlbx_CO_Static.items
local selArr = for s in mlbx_CO_Static.selection collect (GetNodeByName items[s])
select selArr
forceCompleteRedraw()
)
on mlbx_CO_Static rightclick do with undo off (mlbx_CO_Static.selection = #{})
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_AddObjStatic pressed do with undo off
(
-- 	/*
local selArr = ATfn_.GetNHH (selection as array) true
-- if (ATfn_.CheckEmpty selArr) and not chbtn_CO_Uncollide.checked do
if not chbtn_CO_Uncollide.checked do
	(
	if chbtn_CO_SetWireColorState.checked do
		(
		local SWC = if StaticArr.count > 0 then (ATfn_.GetArrayByHeads StaticArr ObjectsOnly:true)[1].wirecolor else (ATfn_.RandomColor())
		(selection as array).wirecolor = SWC
		)
	StaticArr = ATfn_.AddListBoxObjects selArr mlbx_CO_Static StaticArr
	DynamicArr = ATfn_.RemoveListBoxObjects selArr mlbx_CO_Dynamic DynamicArr
	SimArr = DynamicArr + StaticArr
	mlbx_CO_Dynamic.selection = mlbx_CO_Static.selection = #{}
	)
--  */
)
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_RemoveObjStatic pressed do with undo off
(
local selArr = ATfn_.GetNHH (selection as array) true
if not chbtn_CO_Uncollide.checked then
	(
	if chbtn_CO_SetWireColorState.checked do ((ATfn_.GetArrayByHeads (ATfn_.ArraysIntersect selArr StaticArr) ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	StaticArr = ATfn_.RemoveListBoxObjects selArr mlbx_CO_Static StaticArr
	SimArr = DynamicArr + StaticArr
	mlbx_CO_Dynamic.selection = mlbx_CO_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_RemoveAllObjStatic pressed do with undo off
(
if not chbtn_CO_Uncollide.checked then
	(
	if chbtn_CO_SetWireColorState.checked do ((ATfn_.GetArrayByHeads StaticArr ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	StaticArr = #()
	mlbx_CO_Static.items = #()
	SimArr = DeepCopy DynamicArr
	mlbx_CO_Dynamic.selection = mlbx_CO_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------
on btn_CO_SelectAllStatic pressed do with undo on (clearSelection(); select StaticArr; redrawviews())
	-------------------------------------------------------------------------------------------------------------------
on rollout_CO_ open do
	(
	fn_DeleteTemp()
	if floater_AssemblyTool != undefined do (floater_AssemblyTool.rollouts[1].chbtn_TL_Collider.checked = true)
	callbacks.addScript #nodePostDelete "floater_Collider.rollouts[1].fn_VerifyItems()" id:#ATcallbacks_CO_
	callbacks.addScript #filePostOpenProcess "floater_Collider.rollouts[1].fn_VerifyItems()" id:#ATcallbacks_CO_
	)
on rollout_CO_ close do
	(
	fn_DeleteModifs Objects
	fn_DeleteTemp()
	if floater_AssemblyTool != undefined do (floater_AssemblyTool.rollouts[1].chbtn_TL_Collider.checked = false)
	ATfn_.SaveFloaterINI floater_Collider iniFile ExcludedControls
	callbacks.removeScripts id:#ATcallbacks_CO_
	floater_Collider = undefined
	)
)
	----================================================================================================================================
floater_Collider = ATfn_.CreateFloater floater_Collider iniFile fl0W fl0H floaterTitle #(rollout_CO_)
on execute do
	(
	if (hasINISetting iniFile floaterTitle) do (ATfn_.LoadFloaterINI floater_Collider iniFile ExcludedControls)
	floater_Collider.rollouts[1].fn_VerifyItems()
	)
)