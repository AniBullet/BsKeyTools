(if ATIcons == undefined then (fileIn ((getFilenamePath(getThisScriptFilename())) + "AssemblyToolIcons.ms")))
(if ATfn_ == undefined then (fileIn ((getFilenamePath(getThisScriptFilename())) + "AssemblyToolStruct.ms")))
(
Global floater_MassFX
Global floater_AssemblyTool
try (if floater_MassFX.dialogBar then (cui.UnRegisterDialogBar floater_MassFX); closeRolloutFloater floater_MassFX) catch()
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local floaterTitle = "MassFX"
local iniPath = (getDir #maxData)
local iniFile = iniPath + "MassFX_Settings.ini"
local fl0W = 220; local fl0H = (ATfn_.GetINI 0 iniFile floaterTitle "LastSize" [fl0W,640])[2]
-- local fl0P = ATfn_.GetINI 0 iniFile floaterTitle "LastPosition" [50,50]
local colCHBX = ATfn_.GetINI 0 (iniPath + "AssemblyTool_Settings.ini") "Preferences" "color_PS_ChBxColor" [255,156,0]
local ExcludedControls = #("prgrs_MF_ProBar", "tmr_MF_prgrsFade", "btn_MF_DockLeft", "btn_MF_DockFloat", "btn_MF_DockRight", "razdel00", "razdel01", \
	"ddl_MF_DynMat", "ddl_MF_StatMeshType", "ddl_MF_StatMat", "spnr_MF_Substeps", "spnr_MF_SolverIter", "spnr_MF_ContactDistance", "spnr_MF_RestDepth", \
	"chbtn_MF_SimulationMode", "btn_MF_BakeSim", "btn_MF_UnbakeSim", "chbtn_MF_PlaySim", "btn_MF_ResetSim", "btn_MF_CaptureTransform", "spnr_MF_AnimStart", "spnr_MF_AnimLength", "chbtn_MF_UseGround", "spnr_MF_GroundHeight")
	----=MassFX==========================================================================================================================
local DynamicArr = #()
local StaticArr = #()
local SimDynArr = #()
local SimStatArr = #()
local GPPattern = ":;:GProxy"
	-------
rollout rollout_MF_ "MassFX"
(
local yp1 = #(18, 182, 332, 370, 410, 482, 520, 560, 597)
local DockX = 181; local DockW = 13; local rh = 3; local hc = [160,160,160]
button btn_MF_DockLeft "<" pos:[DockX-DockW,0] width:DockW height:10 tooltip:" 嵌入左边 "
button btn_MF_DockFloat "::" pos:[DockX,0] width:DockW height:10 tooltip:" 浮动窗口 "
button btn_MF_DockRight ">" pos:[DockX+DockW,0] width:DockW height:10 tooltip:" 嵌入右边 "
on btn_MF_DockLeft pressed do (ATfn_.DockFloaterSide floater_MassFX iniFile "left")
on btn_MF_DockRight pressed do (ATfn_.DockFloaterSide floater_MassFX iniFile "right")
on btn_MF_DockFloat pressed do (ATfn_.DockFloaterFloat floater_MassFX iniFile fl0W fl0H)
	-------
label lbl_MF_Dynamica "动态物体 / Dynamic :" pos:[2,yp1[1]-16]
button btn_MF_AddObjDynamic "+" width:22 height:21 pos:[0,yp1[1]] images:ATIcons[1] tooltip:" 将对象添加到动态物体列表 "
button btn_MF_RemoveObjDynamic "-" width:22 height:21 pos:[26,yp1[1]] images:ATIcons[2] tooltip:" 从动态物体列表中删除对象 "
button btn_MF_RemoveAllObjDynamic "_" width:22 height:21 pos:[52,yp1[1]] images:ATIcons[3] tooltip:" 从动态物体列表中删除对象 "
button btn_MF_SelectAllDynamic "All" width:22 height:21 pos:[78,yp1[1]] images:ATIcons[4] tooltip:" 左键 -选择所有动态对象 \n 右键 -设置动态对象边框线颜色 "
multilistBox mlbx_MF_Dynamic items:#() width:(fl0W-16) height:7 pos:[2,yp1[1]+22] selection:1 tooltip:" 动态物体 "

local ttp_MeshQuality = " 物理网格质量 (Convex 凸包) \n 用于凸包的顶点数。 "
spinner spnr_MF_DynMeshQuality "网格质量" pos:[40,yp1[1]+125] width:74 range:[4,256,128] type:#integer scale:1 toolTip:ttp_MeshQuality
dropdownlist ddl_MF_DynMat items:(for i=1 to nvpx.MaterialGetCount() collect nvpx.MaterialGetParam (nvpx.MaterialGetId (i-1)) "Name") pos:[120,yp1[1]+122] width:86 height:9 selection:1 tooltip:" 物理材质预设 "

checkButton razdel00 "" tooltip:"" pos:[0,yp1[2]-20] width:fl0W height:rh highlightColor:hc checked:true enabled:false
label lbl_MF_Static "静态物体 / Static :" pos:[2,yp1[2]-16]
button btn_MF_AddObjStatic "+" width:22 height:21 pos:[0,yp1[2]] images:ATIcons[1] tooltip:" 将对象添加到刚体列表 "
button btn_MF_RemoveObjStatic "-" width:22 height:21 pos:[26,yp1[2]] images:ATIcons[2] tooltip:" 从刚体列表中删除对象 "
button btn_MF_RemoveAllObjStatic "_" width:22 height:21 pos:[52,yp1[2]] images:ATIcons[3] tooltip:" Remove All Static Objects From List "
button btn_MF_SelectAllStatic "All" width:22 height:21 pos:[78,yp1[2]] images:ATIcons[4] tooltip:" 左键 -选择所有静态对象 \n 右键 -设置静态对象边框线颜色 "
multilistBox mlbx_MF_Static items:#() width:(fl0W-16) height:7 pos:[2,yp1[2]+22] selection:1 tooltip:" 静态物体 "

dropdownlist ddl_MF_StatMeshType items:#("凸包 | Convex","原始 | Original") pos:[0,yp1[2]+122] width:66 height:9 selection:2 tooltip:" 物理网格类型 "
spinner spnr_MF_StatMeshQuality pos:[67,yp1[2]+125] width:44 range:[4,256,128] type:#integer scale:1 enabled:false toolTip:ttp_MeshQuality
dropdownlist ddl_MF_StatMat items:(for i=1 to nvpx.MaterialGetCount() collect nvpx.MaterialGetParam (nvpx.MaterialGetId (i-1)) "Name") pos:[120,yp1[2]+122] width:86 height:9 selection:1 tooltip:" 物理材质预设 "

checkButton razdel01 "" tooltip:"" pos:[0,yp1[2]+144] width:fl0W height:rh highlightColor:hc checked:true enabled:false

GroupBox grp_MF_RigidBodies "刚体" pos:[2,yp1[3]] width:(fl0W-16) height:36
spinner spnr_MF_Substeps "分步" pos:[36,yp1[3]+16] width:58 range:[0,159,(PhysXPanelData.subSteps)] type:#integer scale:1 toolTip:" 每次图形更新之间执行的模拟步骤数。 "
spinner spnr_MF_SolverIter "求解次数." pos:[133,yp1[3]+16] width:68 range:[1,255,(PhysXPanelData.solverIteration)] type:#integer scale:1 toolTip:" 全局设置：约束求解器强制碰撞和约束的次数。 "

GroupBox grp_MF_ContactShell "接触设置" pos:[2,yp1[4]] width:(fl0W-16) height:36
spinner spnr_MF_ContactDistance "移动" pos:[24,yp1[4]+16] width:77 range:[0,999,(PhysXPanelData.contactShellContactDistance)] type:#worldunits scale:0.1 toolTip:" 允许移动刚体重叠的距离。 "
spinner spnr_MF_RestDepth "静止" pos:[123,yp1[4]+16] width:78 range:[0,999,(PhysXPanelData.skinWidth)] type:#worldunits scale:0.1 toolTip:" 允许静止物体重叠的距离。 "

checkButton chbtn_MF_SimulationMode "模拟模式" pos:[0,yp1[5]] width:(fl0W-13) height:30 highlightColor:colCHBX tooltip:" 模拟模式切换 "
checkButton chbtn_MF_PlaySim "Play" pos:[0,yp1[5]+33] width:38 height:37 images:ATIcons[53] enabled:false checked:(PxIsSimulationRunning()) highlightColor:colCHBX tooltip:" 运行模拟 "
button btn_MF_ResetSim "Reset" width:38 height:37 pos:[40,yp1[5]+33] images:ATIcons[54] enabled:false tooltip:" 重置模拟 "
button btn_MF_CaptureTransform "Capture" width:38 height:37 pos:[80,yp1[5]+33] images:ATIcons[59] enabled:false tooltip:" 左键 - 捕捉选择变换 \n 右键 - 捕捉场景对象变换 "
button btn_MF_BakeSim "Bake" width:40 height:37 pos:[125,yp1[5]+33] images:ATIcons[51] enabled:false tooltip:"左键 - 烘焙场景对象 \n 右键 - 烘焙选定对象 "
button btn_MF_UnbakeSim "Unbake" width:40 height:37 pos:[167,yp1[5]+33] images:ATIcons[52] enabled:false tooltip:" 左键 - 取消烘焙场景对象 \n 右键 - 取消烘焙选定对象 "

GroupBox grp_MF_Animation "动画" pos:[2,yp1[6]] width:(fl0W-16) height:36
spinner spnr_MF_AnimStart "起始" pos:[21,yp1[6]+16] width:70 range:[-999999,999999,animationRange.start] type:#integer scale:1 toolTip:" 动画开始帧数 "
spinner spnr_MF_AnimLength "长度" pos:[115,yp1[6]+16] width:86 range:[1,999999,(animationRange.end - animationRange.start)] type:#integer scale:1 toolTip:" 动画长度 "

GroupBox grp_MF_Environment "环境" pos:[2,yp1[7]] width:(fl0W-16) height:36
checkButton chbtn_MF_UseGround "" pos:[8,yp1[7]+16] width:14 height:14 checked:(PhysXPanelData.useGroundPlane) highlightColor:colCHBX toolTip:" 使用地面碰撞 "
label lbl_MF_UseGround "使用地面碰撞" pos:[26,yp1[7]+16]
spinner spnr_MF_GroundHeight "高度" pos:[105,yp1[7]+16] width:96 range:[-PxMaxValue,PxMaxValue,PhysXPanelData.groundHeight] type:#worldunits toolTip:" 设置地面高度 "

button btn_MF_WorldParameters "World" width:49 height:30 pos:[1,yp1[8]] images:ATIcons[55] tooltip:" 世界参数面板 "
button btn_MF_SimulationTools "Tools" width:49 height:30 pos:[53,yp1[8]] images:ATIcons[56] tooltip:" 模拟工具面板 "
button btn_MF_MultiObjectEditor "Editor" width:49 height:30 pos:[105,yp1[8]] images:ATIcons[57] tooltip:" 多对象编辑器面板 "
button btn_MF_DisplayOptions "Display" width:49 height:30 pos:[157,yp1[8]] images:ATIcons[58] tooltip:" 显示选项面板 "

checkButton chbtn_MF_SetWireColorState pos:[4,yp1[9]] width:14 height:14 highlightColor:colCHBX tooltip:" 为已处理的对象设置随机的线颜色 "
label lbl_MF_SetWireColorState "为已处理的对象设置随机的线颜色" pos:[22,yp1[9]]
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local BakePlayControlsArr = #(btn_MF_BakeSim, btn_MF_UnbakeSim, chbtn_MF_PlaySim, btn_MF_ResetSim, btn_MF_CaptureTransform)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_VerifyItemsDel =
(
if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
if chbtn_MF_SimulationMode.checked do
	(
	SimDynArr = for o in SimDynArr where isValidNode o collect o
	SimStatArr = for o in SimStatArr where isValidNode o collect o
	for o in DynamicArr where (isValidNode o) and (isGroupHead o) do 
		(
		if (GetNodeByName (o.name + GPPattern)) == undefined do
			(
			delete (ATfn_.GetGroupByHead o ObjectsOnly:false)
			)
		)
	)
DynamicArr = ATfn_.VerifyControlItems mlbx_MF_Dynamic
StaticArr = ATfn_.VerifyControlItems mlbx_MF_Static
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_AddRigidBodyMod inArr RigBodType MatID ShapeType ShapeVerts =
(
for objct in inArr do
	(
	local RBMod = MassFX_RBody type:RigBodType
	RBMod.SetRBPresetMaterial MatID
	addModifier objct RBMod
	RBMod.SetRBMeshType 1 ShapeType
	if ShapeVerts != undefined do RBMod.SetRBMeshVertexLimit 1 ShapeVerts
-- 	RBMod.RBMeshRegenerate 1
	)
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_DeleteRigidBodyMod inArr =
(
-- for objct in inArr where isValidNode objct do (if classOf objct.modifiers[1] == MassFX_RBody do (deleteModifier objct 1))
for objct in inArr where isValidNode objct and not isdeleted objct do
	(
	local RBmod = objct.modifiers[MassFX_RBody]
	if RBmod != undefined do (deleteModifier objct RBmod)
	)
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_SetRBMeshVertexLimit inArr val =
(
if chbtn_MF_SimulationMode.checked do
	(
	for objct in inArr do
		(
		local RBmod = objct.modifiers[MassFX_RBody]
		if RBmod != undefined and val != undefined do
			(
			RBMod.meshVerticesLimit = val
-- 			RBMod.SetRBMeshVertexLimit 1 val
-- 			setProperty RBmod #meshVerticesLimit val
			)
		)
	)
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_SetRBPresetMaterial inArr item =
(
if chbtn_MF_SimulationMode.checked do
	(
	local MatID = nvpx.MaterialGetId (item - 1)
	for objct in inArr do
		(
		local RBmod = objct.modifiers[MassFX_RBody]
		if RBmod != undefined do
			(
			RBMod.SetRBPresetMaterial MatID
			)
		)
	)
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_CreateGProxy GHArr =
(
local GProxyArr = #()
-- local DMQ = spnr_MF_DynMeshQuality.value
local DMQ = 256
local GProxyMat = StandardMaterial opacity:0
for gh in GHArr do
	(
	local GObjs = ATfn_.GetGroupByHead gh ObjectsOnly:true
	local GHeadsObjs = ATfn_.GetGroupByHead gh ObjectsOnly:false
	local GProxy = Editable_Mesh wirecolor:green name:(gh.name + GPPattern)
	GProxy.mesh = nvpx.CreateBoundingConvexFromNodes GObjs DMQ 0
	GProxy.pivot = gh.pivot
	GProxy.material = GProxyMat
	gh.parent = GProxy
	GHeadsObjs.isFrozen = true
	GHeadsObjs.showFrozenInGray = false
	append GProxyArr GProxy
	)
GProxyArr
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_UnProxyGroups GProxyArr =
(
if GProxyArr.count > 0 do
	(
	for gp in GProxyArr do
		(
		local GHeadsObjs = ATfn_.GetGroupByHead (GetNodeByName (filterString gp.name ":;:")[1]) ObjectsOnly:false
		GHeadsObjs.isFrozen = false
		GHeadsObjs.showFrozenInGray = true
		)
	callbacks.removeScripts id:#ATcallbacks_MF_
	delete GProxyArr
	callbacks.addScript #nodePostDelete "floater_MassFX.rollouts[1].fn_VerifyItemsDel()" id:#ATcallbacks_MF_
	callbacks.addScript #filePostOpenProcess "floater_MassFX.rollouts[1].fn_VerifyItemsOpen()" id:#ATcallbacks_MF_
	)
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_ExitSimulationMode =
(
chbtn_MF_SimulationMode.checked = false   --- Prevent Groups Delete by Callback
if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
	/*
select SimDynArr
-- nvpx.CaptureInitTransforms SimDynArr true
PxCaptureTransform true   --- Capture Selected Scene Objects
deleteKeys SimDynArr #allKeys
clearSelection()
fn_DeleteRigidBodyMod SimDynArr
	-- */
	/*
PxCaptureTransform false   --- Capture All Scene Objects
deleteKeys SimDynArr #allKeys
clearSelection()
fn_DeleteRigidBodyMod SimDynArr
	-- */
clearSelection()
fn_DeleteRigidBodyMod SimDynArr
if SimDynArr != undefined then (deleteKeys SimDynArr #allKeys)
	/*
clearSelection()
fn_DeleteRigidBodyMod SimDynArr
for objct in SimDynArr do objct.transform = objct.transform
deleteKeys SimDynArr #allKeys
	-- */
	/*
clearSelection()
fn_DeleteRigidBodyMod SimDynArr
local TransformArr = for objct in SimDynArr collect objct.transform
deleteKeys SimDynArr #allKeys
for n=1 to SimDynArr.count do SimDynArr[n].transform = TransformArr[n]
	-- */
fn_UnProxyGroups (for objct in SimDynArr where (matchPattern objct.name pattern:("*"+GPPattern)) collect objct)
for objct in SimDynArr where classof objct.pos.controller == Position_List do objct.pos.controller = Position_XYZ()
if StaticArr.count > 0 do (fn_DeleteRigidBodyMod SimStatArr)
SimDynArr = #(); SimStatArr = #()
chbtn_MF_PlaySim.checked = false
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FN fn_VerifyItemsOpen =
(
if chbtn_MF_SimulationMode.checked do (fn_ExitSimulationMode())
DynamicArr = ATfn_.VerifyControlItems mlbx_MF_Dynamic
StaticArr = ATfn_.VerifyControlItems mlbx_MF_Static
ddl_MF_DynMat.items = ddl_MF_StatMat.items = for i=1 to nvpx.MaterialGetCount() collect nvpx.MaterialGetParam (nvpx.MaterialGetId (i-1)) "Name"
spnr_MF_Substeps.value = PhysXPanelData.subSteps
spnr_MF_SolverIter.value = PhysXPanelData.solverIteration
spnr_MF_ContactDistance.value = PhysXPanelData.contactShellContactDistance
spnr_MF_RestDepth.value = PhysXPanelData.skinWidth
spnr_MF_AnimStart.value = animationRange.start
spnr_MF_AnimLength.value = (animationRange.end - animationRange.start)
chbtn_MF_UseGround.checked = PhysXPanelData.useGroundPlane
spnr_MF_GroundHeight.value = PhysXPanelData.groundHeight
)
	-----fn------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on chbtn_MF_SimulationMode changed state do
(
clearSelection()
PxCaptureTransform false  --- Capture All Scene Objects
if state
then
	(
	if DynamicArr.count == 0 do
		(chbtn_MF_SimulationMode.checked = false; return messageBox "The Dynamic Objects List Is Empty." title:" MassFX")
	SimDynArr = #(); SimStatArr = #()
	local DynamicGHArr = #()
	for objct in DynamicArr do
		(if isGroupHead objct then append DynamicGHArr objct else append SimDynArr objct)
	InstanceMgr.MakeObjectsUnique SimDynArr #individual
	join SimDynArr (fn_CreateGProxy DynamicGHArr)
	local MatID = nvpx.MaterialGetId (ddl_MF_DynMat.selection - 1)
	local ShapeVerts = spnr_MF_DynMeshQuality.value
	fn_AddRigidBodyMod SimDynArr 1 MatID 4 ShapeVerts
	if chbtn_MF_SetWireColorState.checked do
		(
		local DWC = SimDynArr[1].wirecolor
		(ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false).wirecolor = DWC + [1,1,1]
		SimDynArr.wirecolor = DWC
		)
	if StaticArr.count > 0 do
		(
		local StatObjsAndHeadsArr = ATfn_.GetArrayByHeads StaticArr ObjectsOnly:false
		InstanceMgr.MakeObjectsUnique StatObjsAndHeadsArr #individual
		SimStatArr = ATfn_.GetArrayByHeads StaticArr ObjectsOnly:true
		MatID = nvpx.MaterialGetId (ddl_MF_StatMat.selection - 1)
		local ShapeType = if ddl_MF_StatMeshType.selection == 1 then 4 else 5
		ShapeVerts = if ShapeType == 4 then spnr_MF_StatMeshQuality.value else undefined
		local StatHeadsArr = for o in StatObjsAndHeadsArr where isGroupHead o collect o
		for gh in StatHeadsArr do setGroupOpen gh true
		fn_AddRigidBodyMod SimStatArr 3 MatID ShapeType ShapeVerts
		for gh in StatHeadsArr do setGroupOpen gh false
		if chbtn_MF_SetWireColorState.checked do ((ATfn_.GetArrayByHeads StaticArr ObjectsOnly:false).wirecolor = StaticArr[1].wirecolor)
		)
	)
else
	(
	if chbtn_MF_SetWireColorState.checked do (if DynamicArr.count > 0 do ((ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false).wirecolor = SimDynArr[1].wirecolor))
	fn_ExitSimulationMode()
	)
redrawviews()
BakePlayControlsArr.enabled = state
clearUndoBuffer()
-- gc light:true
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_BakeSim pressed do
(
if DynamicArr.count == 0 do (return messageBox "The Dynamic Objects List Is Empty." title:" MassFX")
-- InstanceMgr.MakeObjectsUnique (ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false) #individual
	/*
select SimDynArr
pxBakeSelection false
clearSelection()
	-- */
-- 	/*
clearSelection()
pxBakeAll false
	-- */
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_BakeSim rightclick do
(
if DynamicArr.count == 0 do (return messageBox "The Dynamic Objects List Is Empty." title:" MassFX")
pxBakeSelection false
-- clearSelection()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_UnbakeSim pressed do (pxBakeAll true)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_UnbakeSim rightclick do (pxBakeSelection true)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on chbtn_MF_PlaySim changed state do
(
if DynamicArr.count == 0 do (chbtn_MF_PlaySim.checked = false; return messageBox "The Dynamic Objects List Is Empty." title:" MassFX")
-- InstanceMgr.MakeObjectsUnique (ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false) #individual
clearSelection()
if not PxIsSimulationRunning() do nvpx.SetAnimationState(true)
PxRunSimulation()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_ResetSim pressed do
(
PxStopSimulation()
chbtn_MF_PlaySim.checked = false
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_CaptureTransform pressed do
(
if PxIsSimulationRunning() do (PxRunSimulation())
PxCaptureTransform true  --- Capture Selected Objects
chbtn_MF_PlaySim.checked = false
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_CaptureTransform rightclick do
(
if PxIsSimulationRunning() do (PxRunSimulation())
PxCaptureTransform false  --- Capture All Scene Objects
chbtn_MF_PlaySim.checked = false
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_DynMeshQuality entered do with undo off
(
local val = spnr_MF_DynMeshQuality.value
fn_SetRBMeshVertexLimit SimDynArr val
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_StatMeshQuality entered do with undo off
(
local val = if ddl_MF_StatMeshType.selection == 1 then spnr_MF_StatMeshQuality.value else undefined 
fn_SetRBMeshVertexLimit SimStatArr val
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on ddl_MF_StatMeshType selected item do with undo off
(
if chbtn_MF_SimulationMode.checked do
	(
	if item == 1
	then
		(
		local val = spnr_MF_StatMeshQuality.value
		for objct in SimStatArr do
			(
			local RBmod = objct.modifiers[MassFX_RBody]
			if RBmod != undefined do
				(
				RBMod.meshType = 4
				RBMod.meshVerticesLimit = val
				)
			)
		)
	else
		(
		for objct in SimStatArr do
			(
			local RBmod = objct.modifiers[MassFX_RBody]
			if RBmod != undefined do
				(
				RBMod.meshType = 5
				)
			)
		)
	)
spnr_MF_StatMeshQuality.enabled = (item == 1)
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on ddl_MF_DynMat selected item do with undo off (fn_SetRBPresetMaterial SimDynArr item)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on ddl_MF_StatMat selected item do with undo off (fn_SetRBPresetMaterial SimStatArr item)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_RestDepth entered do with undo off
(
local val = spnr_MF_RestDepth.value
PhysXPanelData.skinWidth = val
px_sdk_skinwidth = physXpaneldata.skinWidth
PxUpdatePhysXParameters()
PxSaveGlobalParams()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_ContactDistance entered do with undo off
(
local val = spnr_MF_ContactDistance.value
PhysXPanelData.contactShellContactDistance = val
px_sdk_contactDistance = PhysXPanelData.contactShellContactDistance
-- spnr_MF_RestDepth.value = PhysXPanelData.skinWidth
PxUpdatePhysXParameters()
PxSaveGlobalParams()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_SolverIter entered do with undo off
(
local val = spnr_MF_SolverIter.value
PxSetProperty PhysXPanelData #solverIteration val
px_rb_solveritertions = nvpx.setSolverIterations val
PxSaveGlobalParams()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_Substeps entered do with undo off
(
local val = spnr_MF_Substeps.value
PxSetProperty PhysXPanelData #subSteps val
px_sdk_sub_sim_steps = nvpx.SetSimulationSubSteps val
PxSaveGlobalParams()		
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on chbtn_MF_UseGround changed state do with undo off
(
PxSetProperty PhysXPanelData #useGroundPlane state
gPxUseGround = state
PxSaveGlobalParams()
PxUpdateGroundPlane()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_GroundHeight entered do with undo off
(
local val = spnr_MF_GroundHeight.value
PxSetProperty PhysXPanelData #groundHeight val
gPxGroundHeight = val
PxSaveGlobalParams()
PxUpdateGroundPlane()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_AnimStart entered do with undo off (animationRange = interval spnr_MF_AnimStart.value animationRange.end)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on spnr_MF_AnimLength entered do with undo off (animationRange = interval animationRange.start (animationRange.start + spnr_MF_AnimLength.value))
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_WorldParameters pressed do (macros.run "PhysX" "PxShowToolsWindowWorldMS")
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_SimulationTools pressed do (macros.run "PhysX" "PxShowToolsWindowToolsMS")
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_MultiObjectEditor pressed do (macros.run "PhysX" "PxShowToolsWindowMultiEditMS")
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_DisplayOptions pressed do (macros.run "PhysX" "PxShowToolsWindowDisplayMS")
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on mlbx_MF_Dynamic selectionEnd do with undo off 
(
clearSelection()
local items = mlbx_MF_Dynamic.items
local sel = mlbx_MF_Dynamic.selection
local selArr = #()
if chbtn_MF_SimulationMode.checked
then
	(
	for s in sel do
		(
		local GProxy = GetNodeByName (items[s] + GPPattern)
		if GProxy == undefined
			then (appendIfUnique selArr (GetNodeByName items[s]))
			else (appendIfUnique selArr GProxy)
		)
	)
else (selArr = for s in sel collect (GetNodeByName items[s]))
select selArr
forceCompleteRedraw()
)
on mlbx_MF_Dynamic rightclick do with undo off (mlbx_MF_Dynamic.selection = #{})
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_AddObjDynamic pressed do with undo off
(
local selArr = ATfn_.GetNHH (selection as array) true
if (ATfn_.CheckEmpty selArr) and selArr.count > 0 do
	(
-- 	/*
	if chbtn_MF_SimulationMode.checked do
		(
		if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
		selArr = for objct in selArr where not (matchPattern objct.name pattern:("*"+GPPattern)) collect objct
		local DiffDynArr = ATfn_.ArraysDifference selArr DynamicArr
		local IntStatArr = ATfn_.ArraysIntersect DiffDynArr StaticArr
		if IntStatArr.count > 0 do
			(
			for objct in IntStatArr do
				(
				if isGroupHead objct
				then
					(
					local GObjArr = ATfn_.GetGroupByHead objct ObjectsOnly:true
					fn_DeleteRigidBodyMod GObjArr
					SimStatArr = ATfn_.ArraysDifference SimStatArr GObjArr
					)
				else
					(
					fn_DeleteRigidBodyMod #(objct)
					deleteItem SimStatArr (findItem SimStatArr objct)
					)
				)
			)
		local DynArr = #()
		if DiffDynArr.count > 0 do
			(
			local DynGHArr = #()
			for objct in DiffDynArr do
				(
				if isGroupHead objct
				then (appendIfUnique DynGHArr objct)
				else (appendIfUnique DynArr objct)
				)
			InstanceMgr.MakeObjectsUnique DynArr #individual
			join DynArr (fn_CreateGProxy DynGHArr)
			local MatID = nvpx.MaterialGetId (ddl_MF_DynMat.selection - 1)
			local ShapeVerts = spnr_MF_DynMeshQuality.value
			fn_AddRigidBodyMod DynArr 1 MatID 4 ShapeVerts
			join SimDynArr DynArr
			)
-- 		clearSelection()
		select DynArr
		)
	local DWC = if DynamicArr.count > 0 then (ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:true)[1].wirecolor else (ATfn_.RandomColor())
	DynamicArr = ATfn_.AddListBoxObjects selArr mlbx_MF_Dynamic DynamicArr
	if chbtn_MF_SetWireColorState.checked do
		(
		(ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false).wirecolor = if chbtn_MF_SimulationMode.checked then (DWC + [1,1,1]) else DWC
		SimDynArr.wirecolor = DWC
		)
	if StaticArr.count > 0 do StaticArr = ATfn_.RemoveListBoxObjects selArr mlbx_MF_Static StaticArr
	mlbx_MF_Dynamic.selection = mlbx_MF_Static.selection = #{}
--  */
	)
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_RemoveObjDynamic pressed do with undo off
(
local selArr = ATfn_.GetNHH (selection as array) true
if selArr.count > 0 and DynamicArr.count > 0 do
	(
	local oldDynamicArr = deepCopy DynamicArr
	if chbtn_MF_SimulationMode.checked
	then
		(
		if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
		local IntDynArr = ATfn_.ArraysIntersect selArr SimDynArr
		if IntDynArr.count > 0 do
			(
			local GProxyArr = #()
			local DynArr = #()
			for objct in IntDynArr do
				(
				if (matchPattern objct.name pattern:("*"+GPPattern))
				then
					(
					appendIfUnique GProxyArr objct
					appendIfUnique DynArr (GetNodeByName (filterString objct.name ":;:")[1])
					)
				else (appendIfUnique DynArr objct)
				)
			PxCaptureTransform true  --- Capture Selected Objects
			fn_DeleteRigidBodyMod IntDynArr
			SimDynArr = ATfn_.ArraysDifference SimDynArr IntDynArr
			fn_UnProxyGroups GProxyArr
			DynamicArr = ATfn_.RemoveListBoxObjects DynArr mlbx_MF_Dynamic DynamicArr
			)
		select DynArr
		)
	else (DynamicArr = ATfn_.RemoveListBoxObjects selArr mlbx_MF_Dynamic DynamicArr)
	if chbtn_MF_SetWireColorState.checked do ((ATfn_.GetArrayByHeads (ATfn_.ArraysDifference oldDynamicArr DynamicArr) ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	mlbx_MF_Dynamic.selection = mlbx_MF_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_RemoveAllObjDynamic pressed do with undo off
(
-- local selArr = selection as array
if DynamicArr.count > 0 do
	(
	if chbtn_MF_SimulationMode.checked do
		(
		if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
		select SimDynArr
		PxCaptureTransform true  --- Capture Selected Objects
		fn_DeleteRigidBodyMod SimDynArr
		fn_UnProxyGroups (for objct in SimDynArr where (matchPattern objct.name pattern:("*"+GPPattern)) collect objct)
-- 		select selArr
		clearSelection()
		)
	if chbtn_MF_SetWireColorState.checked do ((ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	DynamicArr = #(); SimDynArr = #()
	mlbx_MF_Dynamic.items = #()
	mlbx_MF_Dynamic.selection = mlbx_MF_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_SelectAllDynamic pressed do with undo on
(
clearSelection()
select (if chbtn_MF_SimulationMode.checked then SimDynArr else DynamicArr)
redrawviews()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_SelectAllDynamic rightclick do with undo on
(
local RC = ATfn_.RandomColor()
(ATfn_.GetArrayByHeads DynamicArr ObjectsOnly:false).wirecolor = RC + [1,1,1]
if chbtn_MF_SimulationMode.checked do (SimDynArr.wirecolor = RC)
redrawviews()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on mlbx_MF_Static selectionEnd do
with undo off 
(
clearSelection()
local items = mlbx_MF_Static.items
local selArr = for s in mlbx_MF_Static.selection collect (GetNodeByName items[s])
select selArr
forceCompleteRedraw()
)
on mlbx_MF_Static rightclick do with undo off (mlbx_MF_Static.selection = #{})
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_AddObjStatic pressed do with undo off
(
local selArr = ATfn_.GetNHH (selection as array) true
if (ATfn_.CheckEmpty selArr) do
	(
	if selArr.count > 0 do
		(
		local SWC = if StaticArr.count > 0 then (ATfn_.GetArrayByHeads StaticArr ObjectsOnly:true)[1].wirecolor else (ATfn_.RandomColor())
		if chbtn_MF_SimulationMode.checked
		then
			(
			if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
			PxCaptureTransform false  --- Capture All Scene Objects
			local IntDynArr = ATfn_.ArraysIntersect selArr SimDynArr
			local GProxyArr = #()
			if IntDynArr.count > 0 do
				(
				local DynArr = #()
				for objct in IntDynArr do
					(
					if (matchPattern objct.name pattern:("*"+GPPattern))
					then
						(
						appendIfUnique GProxyArr objct
						appendIfUnique DynArr (GetNodeByName (filterString objct.name ":;:")[1])
						)
					else (appendIfUnique DynArr objct)
					)
				fn_DeleteRigidBodyMod IntDynArr
				SimDynArr = ATfn_.ArraysDifference SimDynArr IntDynArr
				DynamicArr = ATfn_.RemoveListBoxObjects DynArr mlbx_MF_Dynamic DynamicArr
				)
			-------------------------------------------------------------------------------------------------------------------------------------------------------- 
			local StatArr = #()
			local AddStatArr = #()
			for objct in selArr do
				(
				if (matchPattern objct.name pattern:("*"+GPPattern))
				then
					(
					local ProxyNode = GetNodeByName (filterString objct.name ":;:")[1]
					join StatArr (ATfn_.GetGroupByHead ProxyNode ObjectsOnly:true)
					appendIfUnique AddStatArr ProxyNode
					)
				else
					(
					if isGroupHead objct
					then
						(
						join StatArr (ATfn_.GetGroupByHead objct ObjectsOnly:true)
						)
					else
						(
						appendIfUnique StatArr objct
						)
					appendIfUnique AddStatArr objct
					)
				)
			local MatID = nvpx.MaterialGetId (ddl_MF_StatMat.selection - 1)
			local ShapeType = if ddl_MF_StatMeshType.selection == 1 then 4 else 5
			local ShapeVerts = if ShapeType == 4 then spnr_MF_StatMeshQuality.value else undefined
			local StatHeadsArr = for o in AddStatArr where isGroupHead o collect o
			for gh in StatHeadsArr do setGroupOpen gh true
			fn_AddRigidBodyMod StatArr 3 MatID ShapeType ShapeVerts
-- 			fn_AddRigidBodyMod (ATfn_.InstancesTrim StatArr) 3 MatID ShapeType ShapeVerts
			for gh in StatHeadsArr do setGroupOpen gh false
			join SimStatArr StatArr
			select (ATfn_.ArraysDifference AddStatArr StaticArr)
			StaticArr = ATfn_.AddListBoxObjects AddStatArr mlbx_MF_Static StaticArr
			fn_UnProxyGroups GProxyArr
			)
		else
			(
			StaticArr = ATfn_.AddListBoxObjects selArr mlbx_MF_Static StaticArr
			DynamicArr = ATfn_.RemoveListBoxObjects selArr mlbx_MF_Dynamic DynamicArr
			)
		if chbtn_MF_SetWireColorState.checked do ((ATfn_.GetArrayByHeads StaticArr ObjectsOnly:false).wirecolor = SWC)
		mlbx_MF_Dynamic.selection = mlbx_MF_Static.selection = #{}
		)
	)
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_RemoveObjStatic pressed do with undo off
(
local selArr = ATfn_.GetNHH (selection as array) true
if selArr.count > 0 do
	(
	local oldStaticArr = deepCopy StaticArr
	if chbtn_MF_SimulationMode.checked do
		(
		if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
		selArr = for objct in selArr where not (matchPattern objct.name pattern:("*"+GPPattern)) collect objct
		local IntStatArr = ATfn_.ArraysIntersect selArr StaticArr
		if IntStatArr.count > 0 do
			(
			for objct in IntStatArr do
				(
				if isGroupHead objct
				then
					(
					local GObjArr = ATfn_.GetGroupByHead objct ObjectsOnly:true
					fn_DeleteRigidBodyMod GObjArr
					SimStatArr = ATfn_.ArraysDifference SimStatArr GObjArr
					)
				else
					(
					fn_DeleteRigidBodyMod #(objct)
					deleteItem SimStatArr (findItem SimStatArr objct)
					)
				)
			)
		)
	StaticArr = ATfn_.RemoveListBoxObjects selArr mlbx_MF_Static StaticArr
	if chbtn_MF_SetWireColorState.checked do ((ATfn_.GetArrayByHeads (ATfn_.ArraysDifference oldStaticArr StaticArr) ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
	mlbx_MF_Dynamic.selection = mlbx_MF_Static.selection = #{}
	)
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_RemoveAllObjStatic pressed do with undo off
(
if PxIsSimulationRunning() do (PxRunSimulation(); chbtn_MF_PlaySim.checked = false)
fn_DeleteRigidBodyMod SimStatArr
if chbtn_MF_SetWireColorState.checked do ((ATfn_.GetArrayByHeads StaticArr ObjectsOnly:false).wirecolor = ATfn_.RandomColor())
StaticArr = #(); SimStatArr = #()
mlbx_MF_Static.items = #()
mlbx_MF_Dynamic.selection = mlbx_MF_Static.selection = #{}
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_SelectAllStatic pressed do with undo on (clearSelection(); select StaticArr; redrawviews())
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on btn_MF_SelectAllStatic rightclick do with undo on
(
(ATfn_.GetArrayByHeads StaticArr ObjectsOnly:false).wirecolor = ATfn_.RandomColor()
redrawviews()
)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
on rollout_MF_ open do
	(
	PxCaptureTransform false
	if floater_AssemblyTool != undefined do (floater_AssemblyTool.rollouts[1].chbtn_TL_MassFX.checked = true)
	callbacks.addScript #nodePostDelete "floater_MassFX.rollouts[1].fn_VerifyItemsDel()" id:#ATcallbacks_MF_
	callbacks.addScript #filePostOpenProcess "floater_MassFX.rollouts[1].fn_VerifyItemsOpen()" id:#ATcallbacks_MF_
	)
on rollout_MF_ close do
	(
	if PxIsSimulationRunning() do (PxRunSimulation())
	if chbtn_MF_SimulationMode.checked do (fn_ExitSimulationMode())
	PxCaptureTransform false
	if floater_AssemblyTool != undefined do (floater_AssemblyTool.rollouts[1].chbtn_TL_MassFX.checked = false)
	ATfn_.SaveFloaterINI floater_MassFX iniFile ExcludedControls
	callbacks.removeScripts id:#ATcallbacks_MF_
	floater_MassFX = undefined
	)
)
	----================================================================================================================================
floater_MassFX = ATfn_.CreateFloater floater_MassFX iniFile fl0W fl0H floaterTitle #(rollout_MF_)
on execute do
	(
	if (hasINISetting iniFile floaterTitle) do (ATfn_.LoadFloaterINI floater_MassFX iniFile ExcludedControls)
	floater_MassFX.rollouts[1].fn_VerifyItemsDel()
	)
)