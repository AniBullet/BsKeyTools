(
Global ATfn_
Struct ATfn_ (
	FUNCTION GetINI strState ini SectionStr KeyStr def =
(
if (hasINISetting ini SectionStr KeyStr)
then
	(
	local Key = getINISetting ini SectionStr KeyStr
	case strState of (0: (execute Key); 1: (Key)) 
	)
else (return def)
)
,	FUNCTION ddlWidthDynamic ddl =
(
local ddl_koef = 5.; local ddlLim = 30.
local itemsArr = ddl.items
local maxStr = 100; if itemsArr.count != 0 then (strCountArr = (for f in itemsArr collect f.count);  maxStr = aMax strCountArr)
windows.sendmessage ddl.hwnd[1] 352 (maxStr*(ddl_koef + ddlLim/maxStr)) 0
)
,	FUNCTION chbtnColorUpdate cntrlArr defColor =
(
for cntrl in cntrlArr where (classOf cntrl == CheckButtonControl) do
	(
	if cntrl.enabled
	then (cntrl.highlightColor = defColor)
	else (cntrl.highlightColor = [100, 100, 100])
	)
)
,	FUNCTION chbtnRunColor cntrlArr ExcludePattern:"" =
(
for cntrl in cntrlArr where (classOf cntrl == CheckButtonControl) and not (matchPattern (cntrl as string) pattern:ExcludePattern) do (if not cntrl.enabled do cntrl.highlightColor = gray)
)
,	FUNCTION quickResetXForm InArr =
(
for objct in InArr do	
	(
	try(
		local ntm = objct.transform
		objct.transform=transMatrix objct.pos
		local piv = objct.objecttransform * inverse objct.transform
		objct.objectoffsetPos = [0,0,0]
		objct.objectoffsetRot = (quat 0 0 0 1)
		objct.objectoffsetScale = [1,1,1]
		ntm.translation = [0,0,0]
		ntm = piv * ntm
		local xformMod = xform()
		addmodifier objct xformMod
		xformMod.gizmo.transform=ntm
		maxOps.CollapseNode objct off
		)
	catch(continue)
	)
)
,	FUNCTION ResetsXForm LocalPivot InArr =
(
InstanceMgr.MakeObjectsUnique InArr #individual
for objct in InArr do
	(
	if LocalPivot == 0 do ATfn_.AlignPivotTo objct (matrix3 1)
	local NegativeScale = (objct.scale[1] < 0 or objct.scale[2] < 0 or objct.scale[3] < 0)
	local ObjPos = objct.position; local ObjRot = objct.rotation
	objct.rotation = (quat 0 0 0 1); objct.position = ObjPos
	local ObjTm = objct.transform; objct.transform = transMatrix objct.pos
	local piv = objct.objecttransform * inverse objct.transform
	objct.objectoffsetPos = [0,0,0]; objct.objectoffsetRot = (quat 0 0 0 1); objct.objectoffsetScale = [1,1,1]; ObjTm.translation = [0,0,0]; ObjTm = piv * ObjTm
	if NegativeScale then (addModifier objct (normalModifier flip:true))
	local xformMod = XForm(); addmodifier objct xformMod; xformMod.gizmo.transform = ObjTm; convertToPoly objct
-- 	local xformMod = XForm(); addmodifier objct xformMod; xformMod.gizmo.transform = ObjTm; maxOps.CollapseNode objct off
	objct.rotation = ObjRot; objct.position = ObjPos
	)
)
,	FUNCTION Attach_ InArr = 
(
for n in InArr.count to 2 by -1 do (polyop.attach InArr[1] InArr[n])
local objName = ATfn_.RemoveCounter InArr[1].name
-- InArr[1].name = uniqueName objName numDigits:3
ATfn_.RenameAddCounter objName #(InArr[1])
return InArr[1]
)
,	FUNCTION FindAllItems inArr val =
(
local foundIndexes = #()
local copyArr = deepCopy inArr
while ((fIndex = (findItem copyArr val)) != 0) do (appendIfUnique foundIndexes fIndex; copyArr[fIndex] = undefined)
sort foundIndexes
return foundIndexes
)
,	FUNCTION ArraysSum arrA arrB =
(
local tArr = deepCopy arrA
for objct in arrB where findItem arrA objct == 0 do (append tArr objct)
return tArr
)
,	FUNCTION ArraysDifference arrA arrB = (for objct in arrA where findItem arrB objct == 0 collect objct)
-- ,	FUNCTION ArraysDifference arrA arrB = (for objct in arrA where (findItem arrB objct == 0 and not objct.isHidden) collect objct)
,	FUNCTION ArraysIntersect arrA arrB = (for objct in arrA where findItem arrB objct != 0 collect objct)
,	FUNCTION RandomFromArray InArr percentage =
(
local selCount = ATfn_.Round ((InArr.count)*percentage/100.) 0
local indexArr = for n=1 to InArr.count collect n
FN fn_Randomize i1 i2 = (random -1 1)
qsort indexArr fn_Randomize
return (for n=1 to selCount collect InArr[indexArr[n]])
)
,	FUNCTION AlphabetSortArray sortArr =
(
local aArr = #(); local bArr = #()
	FN fn_compareBy a b = stricmp a[2] b[2]
qSort sortArr fn_compareBy
for s in sortArr do (append aArr s[1]; append bArr s[2])
return #(aArr, bArr)
)
,	FUNCTION MakeUniqueMaterialArray matArr byName:false =
(
local uMatArr = #()
local matNames = #()
if byName
then
	(
	for m in matArr where
		(
		local found = findItem matNames m.name > 0
		if not found do append matNames m.name
		not found
		) do (appendIfUnique uMatArr m)
	)
else (for m in matArr do (appendIfUnique uMatArr m))
return uMatArr
)
,	FUNCTION InstancesGet InArr =
(
local instArr = #()
for objct in InArr do
	(
	if InstanceMgr.GetInstances objct &SceneInstArr > 1
	then (for inst in SceneInstArr where (findItem instArr inst == 0) do (append instArr inst))
	)
return instArr
)
,	FUNCTION InstancesAppend InArr = (ATfn_.ArraysSum (ATfn_.InstancesGet InArr) InArr)
,	FUNCTION InstancesTrim InArr =
(
local TrimArr = #()
for objct in InArr do
	(
	local objUnique = true
	for trimmed in TrimArr do (if (areNodesInstances trimmed objct) then objUnique = false)
	if objUnique then (appendIfUnique TrimArr objct)
	)
return TrimArr
)
,	FUNCTION StringsMatch stringsArray Namelimit:4 =
(
local matchedName = ""
if stringsArray.count == 1
	then (matchedName = stringsArray[1])
	else
		(
		local state = true
		local firstName = stringsArray[1]
		for sn=1 to firstName.count do
			(
			if not state then exit
			for n=2 to stringsArray.count do
				(
				try (if stringsArray[n][sn] != firstName[sn] do state = false) catch (state = false)
				)
			if state do matchedName += firstName[sn]
			)
		)
if matchedName.count < Namelimit do (matchedName = "")
return matchedName
)
,	FUNCTION ReplaceString mainStr itStr byStr CaseSensitive:false = ((dotnetClass "System.Text.RegularExpressions.Regex").Replace mainStr ((if CaseSensitive then "" else "(?i)") + itStr) byStr)
-- ,	FUNCTION RandomColor = ([(random 0 255), (random 0 255), (random 0 255)])
,	FUNCTION RandomColor = (color (random 0 255) (random 0 255) (random 0 255))
,	FUNCTION CompareNames str1 str2 = (stricmp str1.name str2.name)
,	FUNCTION Round val n = (local outVal = (floor ((val * (10.0 ^ n)) + 0.5)) / (10.0 ^ n); if n==0 then (outVal = outVal as integer); return outVal)
,	FUNCTION Counter Count CounterDigits:2 StartFrom:1 Step:1 = 
(
Count = Count + (StartFrom - 1) + ((Step - 1)*(Count - 1))
local cntStr = ""; for n=1 to (CounterDigits - (Count as string).count) do cntStr += "0"; cntStr += Count as string
return cntStr
)
,	FUNCTION RemoveCounter str =
(
str = trimRight str "_1234567890"
return str
)
,	FUNCTION RenameAddCounter NewName ObjectsArray Separator:"_" CounterDigits:3 = 
(
for objct in ObjectsArray do (objct.name = uniqueName "AbrAbrvalg" numDigits:9)
for objct in ObjectsArray do (objct.name = uniqueName (NewName + Separator) numDigits:(if CounterDigits == 0 then (ObjectsArray.count as string).count else CounterDigits))
)
,	FUNCTION CheckStripGetPath TexPath = 
(
if (filterString TexPath "\\").count > 1 then TexPath else (maxFilePath + TexPath)
)
,	FUNCTION FoundNewFilename targFile exFile CounterDigits: =
(
local cnt = 1
do (
	local cntStr = "_" + (ATfn_.Counter cnt CounterDigits:CounterDigits)
	targFile = (getFilenamePath targFile) + (getFilenameFile exFile) + cntStr + (getFilenameType targFile)
	cnt += 1
	)
while (doesFileExist targFile and getFileSize exFile != getFileSize targFile)
return targFile
)
,	FUNCTION CollectByPattern pattern inside:Objects = (for objct in inside where (matchPattern objct.name pattern:("*" + pattern + "*")) collect objct)
	---Floater
,	FUNCTION CreateFloater floater_ ini fl0W fl0H FTitle rolloutsArr =
(
local fl0P = ATfn_.GetINI 0 ini FTitle "LastPosition" [50,50]
local DockState = ATfn_.GetINI 1 ini FTitle "DockState" "undefined"
if DockState != "undefined" do (fl0P = [sysInfo.DesktopSize[1]-1,sysInfo.DesktopSize[2]-1]; fl0H = sysInfo.DesktopSize[2])
floater_ = NewRolloutFloater FTitle fl0W fl0H fl0P[1] fl0P[2]
for roll in rolloutsArr do (addRollout roll floater_ rolledUp:(ATfn_.GetINI 0 ini roll.title (roll.title + "_RolledUp") false))
-- for roll in rolloutsArr do (cui.RegisterDialogBar roll style:#(#cui_floatable))
case DockState of
	(
	"cui_dock_left": (cui.RegisterDialogBar floater_ style:#(#cui_dock_vert); cui.DockDialogBar floater_ #cui_dock_left)
	"cui_dock_right": (cui.RegisterDialogBar floater_ style:#(#cui_dock_vert); cui.DockDialogBar floater_ #cui_dock_right)
	)
return floater_
)
,	FUNCTION SaveFloaterPosSize floater_ ini =
(
if (ATfn_.GetINI 1 ini floater_.title "DockState" "undefined") == "undefined" do
	(
	setINISetting ini floater_.title "LastPosition" (floater_.pos as string)
	setINISetting ini floater_.title "LastSize" (floater_.size as string)
	)
)
,	FUNCTION SaveFloaterINI floater_ ini ExcludedControls =
(
local ItemsControls = #(ListBoxControl, MultiListBoxControl, ComboBoxControl)
local ValueControls = #(SpinnerControl)
local StateControls = #(CheckBoxControl, CheckButtonControl, RadioControl)
local SelectionControls = #(ListBoxControl, MultiListBoxControl, ComboBoxControl)
local Rolls = floater_.Rollouts
for r in Rolls do (for c in r.controls where ((FindItem ItemsControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini r.title (c.name + "_Items") (with printAllElements on (c.items as string))))
for r in Rolls do (for c in r.controls where ((FindItem ValueControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini r.title (c.name + "_Value") (c.value as string)))
for r in Rolls do (for c in r.controls where ((FindItem StateControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini r.title (c.name + "_State") (c.state as string)))
for r in Rolls do (for c in r.controls where (FindItem SelectionControls (ClassOf c) > 0) do
	(setINISetting ini r.title (c.name + "_Selection") (c.selection as string)))
for r in Rolls do (for c in r.controls where ((ClassOf c == ColorPickerControl) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini r.title (c.name + "_Color") (c.color as string)))
for r in Rolls do (for c in r.controls where ((ClassOf c == EditTextControl) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini r.title (c.name + "_Text") (c.text as string)))
-- for r in Rolls do (for c in r.controls where (FindItem ExcludedControls c.name == 0) do
for r in Rolls do (for c in r.controls do
	(setINISetting ini r.title (c.name + "_Enabled") (c.enabled as string)))
	---
for r in Rolls do (setINISetting ini r.title (r.title + "_RolledUp") ((not r.open) as string))
if (ATfn_.GetINI 1 ini floater_.title "DockState" "undefined") == "undefined" do
	(
	setINISetting ini floater_.title "LastPosition" (floater_.pos as string)
	setINISetting ini floater_.title "LastSize" (floater_.size as string)
	)
)
,	FUNCTION LoadFloaterINI floater_ ini ExcludedControls =
(
local ItemsControls = #(ComboBoxControl, MultiListBoxControl)
local ValueControls = #(SpinnerControl)
local StateControls = #(CheckBoxControl, CheckButtonControl, RadioControl)
-- local StateControls = #(CheckBoxControl, CheckButtonControl)
-- local StateNumControls = #(RadioControl)
local SelectionControls = #(ComboBoxControl, MultiListBoxControl)
local Rolls = floater_.Rollouts
for r in Rolls do (for c in r.controls where ((FindItem ItemsControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(c.items = ATfn_.GetINI 0 ini r.title (c.name + "_Items") #()))
for r in Rolls do (for c in r.controls where ((FindItem ValueControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(c.value = ATfn_.GetINI 0 ini r.title (c.name + "_Value") 0.))
for r in Rolls do (for c in r.controls where ((FindItem StateControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(c.state = ATfn_.GetINI 0 ini r.title (c.name + "_State") false))
-- for r in Rolls do (for c in r.controls where ((FindItem StateNumControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
-- 	(c.state = ATfn_.GetINI 0 ini r.title (c.name + "_State") 1))
for r in Rolls do (for c in r.controls where (FindItem SelectionControls (ClassOf c) > 0) do
	(c.selection = ATfn_.GetINI 0 ini r.title (c.name + "_Selection") 1))
for r in Rolls do (for c in r.controls where ((ClassOf c == ColorPickerControl) and (FindItem ExcludedControls c.name == 0)) do
	(c.color = ATfn_.GetINI 0 ini r.title (c.name + "_Color") gray))
for r in Rolls do (for c in r.controls where ((ClassOf c == EditTextControl) and (FindItem ExcludedControls c.name == 0)) do
	(c.text = ATfn_.GetINI 1 ini r.title (c.name + "_Text") ""))
-- for r in Rolls do (for c in r.controls where (FindItem ExcludedControls c.name == 0) do
for r in Rolls do (for c in r.controls do
	(c.enabled = ATfn_.GetINI 0 ini r.title (c.name + "_Enabled") true))
for r in Rolls do (for c in r.controls where ((ClassOf c == CheckButtonControl) and (FindItem ExcludedControls c.name == 0)) do (if not c.enabled do (c.highlightColor = [100, 100, 100])))
if not (ATfn_.GetINI 0 ((getFilenamePath (getThisScriptFilename())) + "INI\AssemblyTool_Settings.ini") "Preferences" "TooltipShow" true) do
	(for r in Rolls do (for c in r.controls do (try(c.tooltip = "")catch())))
)
,	FUNCTION DockFloaterSide floater_ ini dockSide =
(
-- local CurMousePos = [mouse.screenpos.X,mouse.screenpos.Y]
if not floater_.dialogBar
then
	(
	setINISetting ini floater_.title "LastPosition" (floater_.pos as string)
	setINISetting ini floater_.title "LastSize" (floater_.size as string)
	floater_.size.y = sysInfo.DesktopSize[2]/3
	floater_.pos = [sysInfo.DesktopSize[1]-1,sysInfo.DesktopSize[2]-1]
-- 	if not keyboard.altPressed then (floater_.size.y = sysInfo.DesktopSize[2])
	cui.RegisterDialogBar floater_ style:#(#cui_dock_vert)
	cui.DockDialogBar floater_ (if dockSide == "left" then #cui_dock_left else #cui_dock_right)
	)
else (if cui.getDockState floater_ == (if not dockSide == "left" then #cui_dock_left else #cui_dock_right) do (cui.DockDialogBar floater_ (if dockSide == "left" then #cui_dock_left else #cui_dock_right)))
setINISetting ini floater_.title "DockState" ((try (cui.getDockState floater_) catch(undefined)) as string)
-- (dotnetClass "Cursor").Position = dotnetObject "System.Drawing.Point" (CurMousePos[1]) (CurMousePos[2])
)
,	FUNCTION DockFloaterFloat floater_ ini fl0W fl0H =
(
-- local CurMousePos = [mouse.screenpos.X,mouse.screenpos.Y]
if floater_.dialogBar
then
	(
	cui.UnRegisterDialogBar floater_
	floater_.pos = ATfn_.GetINI 0 ini floater_.title "LastPosition" [5,30]
	floater_.size = ATfn_.GetINI 0 ini floater_.title "LastSize" [fl0W,fl0H]
	)
setINISetting ini floater_.title "DockState" ((try (cui.getDockState floater_) catch(undefined)) as string)
-- (dotnetClass "Cursor").Position = dotnetObject "System.Drawing.Point" (CurMousePos[1]) (CurMousePos[2])
)
	---Rollout
,	FUNCTION CreateRollout rollout_ ini rollTitle rolloutWidth rolloutHeight RStyle:#(#style_titlebar, #style_sysmenu, #style_minimizebox, #style_maximizebox) loadSize:true =
(
local DialogPos = ATfn_.GetINI 0 ini rollTitle "LastPosition" [50,50]
local rollSize = if loadSize then (ATfn_.GetINI 0 ini rollTitle "LastSize" [rolloutWidth,rolloutHeight]) else [rolloutWidth,rolloutHeight]
local DockState = ATfn_.GetINI 1 ini rollTitle "DockState" "undefined"
local rollWidth = rollSize[1]; local rollHeight = rollSize[2]
if (DialogPos[1] > (sysInfo.DesktopSize[1] - rollWidth)) then abs(DialogPos[1] = (sysInfo.DesktopSize[1] - rollWidth - 10))
if (DialogPos[2] > (sysInfo.DesktopSize[2] - rollHeight)) then abs(DialogPos[2] = (sysInfo.DesktopSize[2] - rollHeight - 30))
if DialogPos[1] < 0 then DialogPos[1] = 10; if DialogPos[2] < 30 then DialogPos[2] = 30
if DockState != "undefined" do (DialogPos = [sysInfo.DesktopSize[1]-1,sysInfo.DesktopSize[2]-1]; rollHeight = sysInfo.DesktopSize[2])
CreateDialog rollout_ rollWidth rollHeight pos:DialogPos style:RStyle
case DockState of
	(
	"cui_dock_left": (cui.RegisterDialogBar rollout_ style:#(#cui_dock_vert); cui.DockDialogBar rollout_ #cui_dock_left)
	"cui_dock_right": (cui.RegisterDialogBar rollout_ style:#(#cui_dock_vert); cui.DockDialogBar rollout_ #cui_dock_right)
	)
return rollout_
)
,	FUNCTION SaveRolloutINI rollout_ ini ExcludedControls =
(
local ItemsControls = #(ListBoxControl, MultiListBoxControl, ComboBoxControl)
local ValueControls = #(SpinnerControl)
local StateControls = #(CheckBoxControl, CheckButtonControl, RadioControl)
local SelectionControls = #(ListBoxControl, MultiListBoxControl, ComboBoxControl)
for c in rollout_.controls where ((FindItem ItemsControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini rollout_.title (c.name + "_Items") (with printAllElements on (c.items as string)))
for c in rollout_.controls where ((FindItem ValueControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini rollout_.title (c.name + "_Value") (c.value as string))
for c in rollout_.controls where ((FindItem StateControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini rollout_.title (c.name + "_State") (c.state as string))
for c in rollout_.controls where (FindItem SelectionControls (ClassOf c) > 0) do
	(setINISetting ini rollout_.title (c.name + "_Selection") (c.selection as string))
for c in rollout_.controls where ((ClassOf c == ColorPickerControl) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini rollout_.title (c.name + "_Color") (c.color as string))
for c in rollout_.controls where ((ClassOf c == EditTextControl) and (FindItem ExcludedControls c.name == 0)) do
	(setINISetting ini rollout_.title (c.name + "_Text") (c.text as string))
-- for c in rollout_.controls where (FindItem ExcludedControls c.name == 0) do
for c in rollout_.controls do
	(setINISetting ini rollout_.title (c.name + "_Enabled") (c.enabled as string))
	---
if (ATfn_.GetINI 1 ini rollout_.title "DockState" "undefined") == "undefined" do
	(
	setINISetting ini rollout_.title "LastPosition" ((GetDialogPos rollout_) as string)
	setINISetting ini rollout_.title "LastSize" ((GetDialogSize rollout_) as string)
	)
)
,	FUNCTION LoadRolloutINI rollout_ ini ExcludedControls =
(
local ItemsControls = #(ComboBoxControl, MultiListBoxControl)
local ValueControls = #(SpinnerControl)
local StateControls = #(CheckBoxControl, CheckButtonControl)
local StateNumControls = #(RadioControl)
local SelectionControls = #(ComboBoxControl, MultiListBoxControl)
for c in rollout_.controls where ((FindItem ItemsControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(c.items = ATfn_.GetINI 0 ini rollout_.title (c.name + "_Items") #())
for c in rollout_.controls where ((FindItem ValueControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(c.value = ATfn_.GetINI 0 ini rollout_.title (c.name + "_Value") 0.)
for c in rollout_.controls where ((FindItem StateControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(c.state = ATfn_.GetINI 0 ini rollout_.title (c.name + "_State") false)
for c in rollout_.controls where ((FindItem StateNumControls (ClassOf c) > 0) and (FindItem ExcludedControls c.name == 0)) do
	(c.state = ATfn_.GetINI 0 ini rollout_.title (c.name + "_State") 1)
for c in rollout_.controls where (FindItem SelectionControls (ClassOf c) > 0) do
	(c.selection = ATfn_.GetINI 0 ini rollout_.title (c.name + "_Selection") 1)
for c in rollout_.controls where ((ClassOf c == ColorPickerControl) and (FindItem ExcludedControls c.name == 0)) do
	(c.color = ATfn_.GetINI 0 ini rollout_.title (c.name + "_Color") gray)
for c in rollout_.controls where ((ClassOf c == EditTextControl) and (FindItem ExcludedControls c.name == 0)) do
	(c.text = ATfn_.GetINI 1 ini rollout_.title (c.name + "_Text") "")
-- for c in rollout_.controls where (FindItem ExcludedControls c.name == 0) do
for c in rollout_.controls do
	(c.enabled = ATfn_.GetINI 0 ini rollout_.title (c.name + "_Enabled") true)
for c in rollout_.controls where ((ClassOf c == CheckButtonControl) and (FindItem ExcludedControls c.name == 0)) do (if not c.enabled do (c.highlightColor = [100, 100, 100]))
if not (ATfn_.GetINI 0 ((getFilenamePath (getThisScriptFilename())) + "INI\AssemblyTool_Settings.ini") "Preferences" "TooltipShow" true) do
	(for c in rollout_.controls do (try(c.tooltip = "")catch()))
)
,	FUNCTION DockRolloutSide rollout_ ini dockSide =
(
if not rollout_.dialogBar
then
	(
	setINISetting ini rollout_.title "LastPosition" ((GetDialogPos rollout_) as string)
	setINISetting ini rollout_.title "LastSize" ((GetDialogSize rollout_) as string)
	SetDialogPos rollout_ [sysInfo.DesktopSize[1]-1,sysInfo.DesktopSize[2]-1]
-- 	if not keyboard.altPressed then (rollout_.height = sysInfo.DesktopSize[2])
-- 	rollout_.height = sysInfo.DesktopSize[2]
	cui.RegisterDialogBar rollout_ style:#(#cui_dock_vert)
	cui.DockDialogBar rollout_ (if dockSide == "left" then #cui_dock_left else #cui_dock_right)
	)
else (if cui.getDockState rollout_ == (if not dockSide == "left" then #cui_dock_left else #cui_dock_right) do (cui.DockDialogBar rollout_ (if dockSide == "left" then #cui_dock_left else #cui_dock_right)))
setINISetting ini rollout_.title "DockState" ((try (cui.getDockState rollout_) catch(undefined)) as string)
)
,	FUNCTION DockRolloutFloat rollout_ ini fl0W fl0H =
(
if rollout_.dialogBar
then
	(
	cui.UnRegisterDialogBar rollout_
	SetDialogPos rollout_ (ATfn_.GetINI 0 ini rollout_.title "LastPosition" [5,30])
	local rolloutSize = ATfn_.GetINI 0 ini rollout_.title "LastSize" [fl0W,fl0H]
	rollout_.width = rolloutSize[1]; rollout_.height = rolloutSize[2]
	)
setINISetting ini rollout_.title "DockState" ((try (cui.getDockState rollout_) catch(undefined)) as string)
)
,	FUNCTION ProgBarFade ProgBar FadeTimer =
(
local pc = ProgBar.color; local k1 = 66
local R = if pc.r<k1 then (pc.r + 1) else k1; local G = if pc.g>68 then (pc.g - 3) else 68; local B = if pc.b<k1 then (pc.b + 1) else k1
ProgBar.color = [R, G, B]; if G<=68 then (FadeTimer.active = false)
)
,	FUNCTION GetDirFiles types:"All Files (*.*)|*.*" initialDir:"C:\\" =
(
local files = undefined
local FileDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
FileDialog.title = "Select One Or More Files"
FileDialog.Multiselect = true
FileDialog.InitialDirectory = initialDir
FileDialog.Filter = types --"FBX Files (*.fbx)|*.fbx" --|"All Files (*.*)|*.*"
FileDialog.FilterIndex = 1 --set the filter drop-down list to All Files
local result = FileDialog.showDialog() --display the dialog, get result into variable
if result.Equals result.OK == true do
	(
	files = for f in (FileDialog.fileNames) collect f
	)
return files
)
,	FUNCTION AddListItem listControl str =
(
local listArr = listControl.items as array
appendIfUnique listArr str
listControl.items = listArr
)
,	FUNCTION AddListItems listControl ItemsArray =
(
if ItemsArray.count == 0 do return false
local list = deepcopy listControl.items
-- join list ItemsArray
for item in ItemsArray do appendIfUnique list item
listControl.items = list
listControl.selection = #{}
)
,	FUNCTION RemoveListItems listControl Indexs =
(
if classOf Indexs == BitArray do (Indexs = Indexs as array)
if Indexs.count == 0 do return false
local list = listControl.items as array
for n=Indexs.count to 1 by -1 do deleteItem list Indexs[n]
listControl.items = list
listControl.selection = #{}
)
,	FUNCTION MoveInListUp listControl ControlArr ToTop =
(
local ListItems = listControl.items
local ListSelection = listControl.selection as array
if (ListItems.count != 0 and ListSelection.count != 0 and ListSelection[1] > 1) do
	(
	local MaxStep = if ToTop then (ListSelection[1] - 1) else 1
	for n=1 to ListSelection.count do
		(
		local NSel = ListSelection[n]
		local LItem = ListItems[NSel]
		local ObjItem = ControlArr[NSel]
		deleteItem ListItems NSel
		insertItem LItem ListItems (NSel - MaxStep)
		deleteItem ControlArr NSel
		insertItem ObjItem ControlArr (NSel - MaxStep)
		ListSelection[n] = NSel - MaxStep
		listControl.items = ListItems
		)
	listControl.selection = ListSelection as bitarray
	)
)
,	FUNCTION MoveInListDown listControl ControlArr ToBottom =
(
local ListItems = listControl.items
local ListSelection = for i=(listControl.selection as array).count to 1 by -1 collect (listControl.selection as array)[i]
if (ListItems.count != 0 and ListSelection.count != 0 and ListItems.count > ListSelection[1]) do
	(
	local MaxStep = if ToBottom then (ListItems.count - ListSelection[1]) else 1
	for n=1 to ListSelection.count do
		(
		local NSel = ListSelection[n]
		local LItem = ListItems[NSel]
		local ObjItem = ControlArr[NSel]
		deleteItem ListItems NSel
		insertItem LItem ListItems (NSel + MaxStep)
		deleteItem ControlArr NSel
		insertItem ObjItem ControlArr (NSel + MaxStep)
		ListSelection[n] = NSel + MaxStep
		listControl.items = ListItems
		)
	listControl.selection = ListSelection as bitarray
	)
)
,	FUNCTION AddListBoxObjects inArr cntrl cntrlArr =
(
local NewArr = ATfn_.ArraysDifference inArr cntrlArr
if NewArr.count > 0 then
	(
	local Items = cntrl.items
-- 	for objct in NewArr where (findItem Items objct.name > 0) do objct.name = uniqueName objct.name --- Check Names Overlap
	for objct in NewArr do
		(
		appendIfUnique cntrlArr objct
		appendIfUnique Items objct.name
		)
	cntrl.items = Items
	cntrl.selection = 0
	)
return cntrlArr
)
,	FUNCTION RemoveListBoxObjects inArr cntrl cntrlArr =
(
local NewArr = ATfn_.ArraysIntersect inArr cntrlArr
if NewArr.count > 0 then
	(
	local Items = cntrl.items
	for objct in NewArr do
		(
		local IIndex = FindItem cntrlArr objct
		if IIndex > 0 do
			(
			DeleteItem cntrlArr IIndex
			DeleteItem Items IIndex
-- 			DeleteItem cntrlArr (FindItem cntrlArr objct)
-- 			DeleteItem Items (FindItem Items objct.name)
			)
		)
	cntrl.items = Items
	cntrl.selection = 0
	)
return cntrlArr
)
,	FUNCTION CompareBySizeDecrease o1 o2 =
(
local o1sz = Distance o1.min o1.max
local o2sz = Distance o2.min o2.max
case of
	(
	(o1sz > o2sz): -1
	(o1sz < o2sz): 1
	default: 0
	)
)
,	FUNCTION GetGeometry selectionArray VRProxy:true =
(
for objct in selectionArray where \
	(((IsValidNode objct and SuperClassOf objct == GeometryClass \
		and canConvertTo objct Editable_Poly \
		and not classOf objct == BoneGeometry \
		and not classOf objct == Biped_Object \
		and (if VRProxy then true else (not classOf objct == VRayProxy)) \
		) \
	or (IsValidNode objct and SuperClassOf objct == Shape and objct.render_displayRenderMesh)) \
-- 	and not (matchPattern objct.name pattern:"Name*") \
	) collect objct
)
,	FUNCTION GetShapes selectionArray VRProxy:true =
(
for objct in selectionArray where \
	(IsValidNode objct and SuperClassOf objct == Shape \
		and canConvertTo objct SplineShape) \
	collect objct
)
,	FUNCTION GetShapeXGeometry selectionArray VRProxy:true =
(
for objct in selectionArray where \
	(((IsValidNode objct and SuperClassOf objct == GeometryClass \
		and canConvertTo objct Editable_Poly \
		and not classOf objct == BoneGeometry \
		and not classOf objct == Biped_Object \
		and (if VRProxy then true else (not classOf objct == VRayProxy)) \
		) \
	or (IsValidNode objct and SuperClassOf objct == Shape \
		and canConvertTo objct SplineShape)) \
	) collect objct
)
,	FUNCTION GCheck objct VRProxy:true =
(
Local Pass = false
if (((IsValidNode objct and SuperClassOf objct == GeometryClass \
		and canConvertTo objct Editable_Poly \
		and not classOf objct == BoneGeometry \
		and not classOf objct == Biped_Object \
		and (if VRProxy then true else (not classOf objct == VRayProxy)) \
		) \
	or (IsValidNode objct and SuperClassOf objct == Shape and objct.render_displayRenderMesh)) \
-- 	and not (matchPattern objct.name pattern:"Name*") \
	) then (Pass = true)
Pass
)
,	FUNCTION AddModifer modif func Unique:false =
(
local inArr = #()
if classOf func == MAXScriptFunction
then (inArr = func (if Unique then (ATfn_.InstancesTrim selection) else selection))
else 
	(
	if classOf func == Array
	then (inArr = if Unique then (ATfn_.InstancesTrim func) else func)
	)
if inArr.count == 0 do return false
if Unique
then (select inArr; for objct in inArr do (addModifier objct modif; InstanceMgr.MakeModifiersUnique objct modif #individual))
else (select inArr; modPanel.addModToSelection modif ui:on)
)
,	FUNCTION GetMinMax InArr =
(
local SizesMin = #(); local SizesMax = #()
local SizesMinX = #(); local SizesMinY = #(); local SizesMinZ = #()
local SizesMaxX = #(); local SizesMaxY = #(); local SizesMaxZ = #()
local Sizes = #()
local Centers = #()
if InArr.count > 0 do
(
for objct in InArr do
	(
-- 	local bb = nodeGetBoundingBox objct objct.transform
	local bb = nodeGetBoundingBox objct (matrix3 1)
	append SizesMin bb[1]
	append SizesMax bb[2]
	append SizesMinX bb[1][1]; append SizesMinY bb[1][2]; append SizesMinZ bb[1][3]
	append SizesMaxX bb[2][1]; append SizesMaxY bb[2][2]; append SizesMaxZ bb[2][3]
	append Sizes (bb[2] - bb[1])
	append Centers (bb[1] + (bb[2] - bb[1])/2.)
	)
local ArrMin = [(amin SizesMinX), (amin SizesMinY), (amin SizesMinZ)]
local ArrMax = [(amax SizesMaxX), (amax SizesMaxY), (amax SizesMaxZ)]
)
return #(SizesMin, SizesMax, ArrMin, ArrMax, Sizes, Centers)
)
,	FUNCTION Center objct =
(
local bb = nodeGetBoundingBox objct (matrix3 1)
return (bb[1] + (bb[2] - bb[1])/2.)
)
,	FUNCTION Size objct =
(
local bb = nodeGetBoundingBox objct (matrix3 1)
return (bb[2] - bb[1])
)
,	FUNCTION SetPivot objArr byX byY byZ WorldAlign =
(
if objArr.count > 0 do
	(
	local mmArr = ATfn_.GetMinMax objArr
	if WorldAlign do (WorldAlignPivot objArr)
	for n=1 to objArr.count do
		(
		if byX != undefined do
			(objArr[n].pivot.x = case byX of
				(
				0: (mmArr[1][n].x + (mmArr[2][n].x - mmArr[1][n].x)/2)
				1: (mmArr[1][n].x)
				2: (mmArr[2][n].x)
				)
			)
		if byY != undefined do
			(objArr[n].pivot.y = case byY of
				(
				0: (mmArr[1][n].y + (mmArr[2][n].y - mmArr[1][n].y)/2)
				1: (mmArr[1][n].y)
				2: (mmArr[2][n].y)
				)
			)
		if byZ != undefined do
			(objArr[n].pivot.z = case byZ of
				(
				0: (mmArr[1][n].z + (mmArr[2][n].z - mmArr[1][n].z)/2)
				1: (mmArr[1][n].z)
				2: (mmArr[2][n].z)
				)
			)
		)
	)
)
,	FUNCTION AlignPivotTo Obj Trgt SetPosition:false =
(
if not isGroupHead Obj do
	(
	if classOf Trgt != matrix3 then Trgt = Trgt.transform
	if not SetPosition do Trgt.pos = Obj.pos
	local TmScale = scaleMatrix Obj.objectOffsetScale
	local TmRot = Obj.objectOffsetRot as matrix3
	local TmPos = transMatrix Obj.objectOffsetPos
	local TmOffset = TmScale * TmRot * TmPos
	TmOffset *= obj.transform * inverse Trgt
	Obj.transform = Trgt
	Obj.objectOffsetPos = TmOffset.translation
	Obj.objectOffsetRot = TmOffset.rotation
	Obj.objectOffsetScale = TmOffset.scale
	)
)
,	FUNCTION CreateBoundingBoxes InArr baseName:"BoundingBoxHelper" hidden:false frozen:true = with undo off
(
local bbArr = #()
for objct in InArr do
	(
	local bb = nodeGetBoundingBox objct (matrix3 1)
-- 	local bb = #(objct.min, objct.max)
	local objSize = (bb[2] - bb[1])
-- 	fn fn_normbb axbb = (if axbb < 0.01 then 0.01 else axbb)
-- 	local objSize = [fn_normbb (bb[2][1] - bb[1][1]), fn_normbb (bb[2][2] - bb[1][2]), fn_normbb (bb[2][3] - bb[1][3])]
	local bbBox = box width:objSize.x length:objSize.y height:objSize.z pivot:[0., 0., objSize.z/2.] pos:(ATfn_.Center objct) wirecolor:green showFrozenInGray:false \
						name:(uniquename (baseName + "_") numDigits:3) isHidden:hidden isFrozen:frozen
	append bbArr bbBox
	)
gc()
return bbArr
)
,	FUNCTION GroupCollect InArr tolerance:0 = with undo off
(
local GTol = tolerance + 1.
local groupArr = #()
local groupBBArr = #()
local BBArr = ATfn_.CreateBoundingBoxes InArr hidden:true
BBArr.scale = [GTol, GTol, GTol]
for objct in BBArr do
	(
	local FoundInGroups = false
	for n=1 to groupBBArr.count do (if findItem groupBBArr[n] objct > 0 do (FoundInGroups = true))
	if not FoundInGroups do
		(
		append groupBBArr #(objct)
		append groupArr #(InArr[findItem BBArr objct])
		local ng = groupBBArr.count
		for obj in groupBBArr[ng] do
			(
			for o in BBArr where obj != o do
				(if intersects obj o do (appendIfUnique groupBBArr[ng] o; appendIfUnique groupArr[ng] InArr[findItem BBArr o]))
			)
		)
	)
delete BBArr
free groupBBArr
gc()
return groupArr
)
,	FUNCTION SelectInGroups objArr =
(
local HArr = #()
for obj in objArr where isGroupMember obj AND (NOT isOpenGroupMember obj) do
	(
	par = obj.parent
	while par != undefined do
		(
		if isGroupHead par do (setGroupOpen par true; appendIfUnique HArr par)
		par = par.parent
		)
	)	
for obj in objArr where (IsGroupHead obj) AND (NOT isOpenGroupHead obj) do (setGroupOpen obj true; appendIfUnique HArr obj)
select objArr
completeRedraw()
return HArr
)
,	FUNCTION GetTopParent Objct =
(
local out = objct
local par = objct.parent
if par != undefined do
	(
	while par != undefined do
		(
-- 		if isGroupHead par and not IsGroupMember par
-- 		then (out = par; par = undefined)
-- 		else (par = par.parent)
		out = par
		par = par.parent
		)
	)
return out
)
,	FUNCTION GetTopParentArray InArr =
(
local TopParentArray = #()
for o in InArr do (appendIfUnique TopParentArray (ATfn_.GetTopParent o))
return TopParentArray
)
,	FUNCTION GetNHH selectionArray joinArr UseChildren:false =
(
selectionArray = selectionArray as array
local NotHeadsArr = #()
local HeadsArr = #()
for objct in selectionArray do
	(
	local par = objct.parent
	if par == undefined
	then
		(
		if isGroupHead objct
		then (AppendIfUnique HeadsArr objct)
		else (AppendIfUnique NotHeadsArr objct)
		)
	else
		(
		if UseChildren do
			(
			if isGroupHead par
			then (if isOpenGroupHead par and findItem selectionArray par == 0 do (AppendIfUnique NotHeadsArr objct))
			else (if findItem selectionArray par == 0 do (AppendIfUnique NotHeadsArr objct))
			)
		)
	)
return (if joinArr then (NotHeadsArr + HeadsArr) else #(NotHeadsArr, HeadsArr))
)
,	FUNCTION GetNotGroupHeads InArr = (for o in InArr where not (isGroupHead o) collect o)
,	FUNCTION GetGroupByHead GHead ObjectsOnly:false =
(
local GHArr = #(GHead)
local AllGroupArr = GHArr
do
	(
	local SearchArr = #()
	for gh in GHArr do (join SearchArr gh.children)
-- 	for gh in GHArr do (for ch in gh.children do (appendIfUnique SearchArr ch))
	GHArr = for objct in SearchArr where (isGroupHead objct) collect objct
	join AllGroupArr SearchArr
-- 	for o in SearchArr do (appendIfUnique AllGroupArr o)
	) while (GHArr.count > 0)
return (if ObjectsOnly then (for o in AllGroupArr where not (isGroupHead o) collect o) else AllGroupArr)
)
,	FUNCTION GetArrayByHeads InArr ObjectsOnly:false =
(
local OutArr = #()
for objct in InArr do
	(
	if isGroupHead objct
-- 	then (join OutArr (ATfn_.GetGroupByHead objct ObjectsOnly:ObjectsOnly))
	then (for o in (ATfn_.GetGroupByHead objct ObjectsOnly:ObjectsOnly) do (appendIfUnique OutArr o))
	else (AppendIfUnique OutArr objct)
	)
OutArr
)
,	FUNCTION DetachFromGroups InArr =
(
local ObjArr = ATfn_.GetNotGroupHeads InArr
local GMArr = for o in ObjArr where isGroupMember o collect o
if GMArr.count > 0 do
	(
	local GHArr = #(); for o in ObjArr do (local par = o.parent; if par != undefined and isGroupHead par and not (isOpenGroupHead o) do appendIfUnique GHArr par)
	local openStateGHArr = for h in GHArr collect isOpenGroupHead h
	for h in GHArr do (setGroupOpen h true); select ObjArr
	detachNodesFromGroup GMArr
	for n=1 to GHArr.count where isValidNode GHArr[n] do
		(if GHArr[n].children.count == 0 then delete GHArr[n] else setGroupOpen GHArr[n] openStateGHArr[n])
	)
return ObjArr
)
,	FUNCTION FreezeIt Arr State =
(
if Arr.count > 0 then
	(
	local InArr = ATfn_.GetArrayByHeads Arr ObjectsOnly:false
	local FState = false; for objct in InArr do (if objct.isFrozen then FState = true)
	if State != undefined then (FState = State)
	if FState then (unFreeze InArr) else (Freeze InArr)
	)
return FState
)
,	FUNCTION HideIt Arr State =
(
if Arr.count > 0 then
	(
	local InArr = ATfn_.GetArrayByHeads Arr ObjectsOnly:false
	local HState = false; for objct in InArr do (if objct.isHidden then HState = true)
	if State != undefined then (HState = State)
	if HState then (unHide InArr) else (Hide InArr)
	)
return HState
)
,	FUNCTION CopyObject InObj IInstance:true expandHierarchy:false Frozen:false Hidden:false =
(
-- if IInstance == unSupplied do IInstance = true; if Frozen == unSupplied do Frozen = false; if Hidden == unSupplied do Hidden = false
local OutArr = #()
maxOps.cloneNodes InObj clonetype:(if IInstance then #instance else #copy) expandHierarchy:expandHierarchy newNodes:&OutArr
if Frozen != undefined then OutArr.isFrozen = Frozen
if Hidden != undefined then OutArr.isHidden = Hidden
return (if isGroupHead InObj then ((ATfn_.GetNHH OutArr false)[2][1]) else (OutArr[1]))
)
,	FUNCTION CopyArray InArr IInstance:true expandHierarchy:false Frozen:false Hidden:false =
(
-- if IInstance == unSupplied do IInstance = true; if Frozen == unSupplied do Frozen = false; if Hidden == unSupplied do Hidden = false
local OutArr = #()
maxOps.cloneNodes InArr clonetype:(if IInstance then #instance else #copy) expandHierarchy:expandHierarchy newNodes:&OutArr
if Frozen != undefined then OutArr.isFrozen = Frozen
if Hidden != undefined then OutArr.isHidden = Hidden
return OutArr
)
,	FUNCTION CheckEmpty InArr message:true deleteEmpty:true =
(
-- for io in InArr do (for so in (Objects as array) where (io != so) do (if io.name == so.name do so.name = uniqueName io.name))
local Pass = true
setCommandPanelTaskMode #create
local EmptyArr = #()
local GeomArr = ATfn_.GetGeometry InArr
for objct in GeomArr do
	(
	if (ClassOf objct == PolyMeshObject or ClassOf objct == Editable_Poly or ClassOf objct == Editable_mesh)
	then (if objct.numfaces == 0 then (append EmptyArr objct))
	else
		(
		addModifier objct (Edit_Poly ())
		if objct.numfaces == 0 then ( append EmptyArr objct )
		deleteModifier objct 1
		)
	)
if EmptyArr.count > 0 then
	(
	if message
	then
		(
		ATfn_.SelectInGroups EmptyArr
		messageBox ((EmptyArr.count as string) + "  Empty Objects Found And Selected.") title:" WARNING !!!" beep:false
		)
	else
		(
		if deleteEmpty do delete EmptyArr
		)
	Pass = false
	)
return Pass
)
,	FUNCTION ValidateArray InArr = (for o in InArr where (isValidNode o) collect o)
-- ,	FUNCTION ValidateControlArray InArr Cntrl =
-- (
-- local ValidArr = for o in InArr where (isValidNode o) collect o
-- if Cntrl != undefined do (Cntrl.items = for o in ValidArr collect o.name)
-- ValidArr
-- )
,	FUNCTION VerifyControlItems Cntrl =
(
local VerArr = #()
local VerItems = #()
local CntrlItems = Cntrl.items
for i in CntrlItems do
	(
	local NodeByName = GetNodeByName i
	if NodeByName != Undefined do
		(
		append VerArr NodeByName
		append VerItems i
		)
	)
Cntrl.items = VerItems
return VerArr
)
,	FUNCTION IDCheckerMaterial =
(
local colorsArr = #(white)
for n=0 to 7 do
	(
	local scol = red
	scol.h = 1 + n * 30
	append colorsArr scol
	)
for n=0 to 7 do
	(
	local scol = [255,118,115] as color
	scol.h = 1 + n * 30
	append colorsArr scol
	)
for n=0 to 7 do
	(
	local scol = [140,3,0] as color
	scol.h = 1 + n * 30
	append colorsArr scol
	)
local ChMat = Multimaterial numsubs:25 name:"ID Checker"
for n=1 to colorsArr.count do ChMat.materialList[n] = Standardmaterial name:("ID " + (n as string)) diffusecolor:colorsArr[n]
return ChMat
)
,	FUNCTION UpdateSceneMaterials full:false =
(
if full do (tempFile = GetDir #temp + "\\_temp.max"; saveNodes #() tempFile; deleteFile tempFile)
for mat in sceneMaterials do updateMTLInMedit mat
)
,	FUNCTION AppendSubMaterials matArr changeInput:true =
(
if not changeInput do matArr = deepCopy matArr
for mat in matArr do
	(
	for n = 1 to getNumSubMtls mat do
		(
		local subMat = getSubMtl mat n
		if isKindOf subMat Material do appendIfUnique matArr subMat
		)
	)
return matArr
)
,	FUNCTION GetMapsTextures MapsMatsArr AlphabetSort:true SingleTexture: FilterName: FilterInvert: Corona:false =
(
-- if AlphabetSort == unsupplied do AlphabetSort = true
local allSubMats = #()
for n = (MapsMatsArr.count) to 1 by -1 where (superClassOf MapsMatsArr[n] == textureMap) do (append allSubMats MapsMatsArr[n]; deleteItem MapsMatsArr n)
for pm in MapsMatsArr do
	(
	local passSubMats = #(pm)
	for smt in passSubMats do (join passSubMats (for i = 1 to (getNumSubMtls smt) where (Mat = getSubMtl smt i) != undefined collect Mat))
	for m in passSubMats do (appendIfUnique allSubMats m)
	)
local allSubMaps = #()
for asmp in allSubMats do
	(
	local passSubMaps = #(asmp)
	for smp in passSubMaps do (join passSubMaps (for i = 1 to (getNumSubTexmaps smp) where (Map = getSubTexmap smp i) != undefined collect Map))
	if (superClassOf passSubMaps[1] == material) do deleteItem passSubMaps 1
	for smp in passSubMaps do (appendIfUnique allSubMaps smp)
	)
local sortArr = #()
for map in allSubMaps do
	(
	case classOf map of
		(
		Bitmaptexture: (if map.FileName != "" do append sortArr #(map, map.FileName))
		VRayBitmap: (if map.HDRIMapName != "" do append sortArr #(map, map.HDRIMapName))
		)
	if Corona do (if classOf map == CoronaBitmap do (if map.FileName != "" do append sortArr #(map, map.FileName)))
	)
local MapArr = #(); local TexArr = #()
	FN fn_compareBy a b = stricmp a[2] b[2]
if AlphabetSort do (qSort sortArr fn_compareBy)
if FilterName != unSupplied do 
	(sortArr = for n=1 to sortArr.count where (matchPattern (getFilenameFile sortArr[n][2]) pattern:("*" + FilterName + "*")) == (if FilterInvert == unsupplied then true else not FilterInvert) collect (sortArr[n]))
-- 	(sortArr = for n=1 to sortArr.count where (matchPattern (getFilenameFile sortArr[n][2]) pattern:("*" + FilterName + "*")) collect (sortArr[n]))
for s in sortArr do (append MapArr s[1]; append TexArr s[2])
local singleMapArr = #(); local singleTexArr = #()
for n=1 to TexArr.count do
	(
	local tex = TexArr[n]
	if (findItem singleTexArr tex == 0) do
		(
		append singleTexArr tex
		local nIndexArr = ATfn_.FindAllItems TexArr tex
		local nMapArr = for i in nIndexArr collect MapArr[i]
		append singleMapArr nMapArr
		)
	)
local outputArr = #(MapArr, TexArr)
if SingleTexture != unSupplied do (if SingleTexture do outputArr = #(singleMapArr, singleTexArr))
return outputArr
)
,	FUNCTION GetStringDialog Title:"Enter Name" =
(
local RenameDialog = dotNetObject "MaxCustomControls.RenameInstanceDialog" ""
RenameDialog.text = Title
DialogResult = RenameDialog.Showmodal()
if (dotnet.compareenums RenameDialog.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK))
then (RenameDialog.InstanceName)
else (Undefined)
)
,	FUNCTION FixName inStr =
(
local inSymbols =    "0|1|2|3|4|5|6|7|8|9" + \
					"|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z" + \
					"|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z" + \
					"|А|Б|В|Г|Д|Е|Ё|Ж|З|И|Й|К|Л|М|Н|О|П|Р|С|Т|У|Ф|Х|Ц|Ч|Ш|Щ|Ъ|Ы|Ь|Э|Ю|Я" + \
					"|а|б|в|г|д|е|ё|ж|з|и|й|к|л|м|н|о|п|р|с|т|у|ф|х|ц|ч|ш|щ|ъ|ы|ь|э|ю|я" + \
					"| |_|-|.|+|`|~|!|@|\"|#|№|$|;|%|^|:|&|?|*|(|)|=|[|]|{|}|'|\\|\/|,|<|>" + \
					"" ; local inSymbolsArr =  filterString inSymbols "|"; append inSymbolsArr "|"
local outSymbols =   "0|1|2|3|4|5|6|7|8|9" + \
					"|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z" + \
					"|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z" + \
					"|A|B|V|G|D|E|Yo|Zh|Z|I|J|K|L|M|N|O|P|R|S|T|U|F|H|C|Ch|Sh|Sh|b|Y|b|E|Yu|Ya" + \
					"|a|b|v|g|d|e|yo|zh|z|i|j|k|l|m|n|o|p|r|s|t|u|f|h|c|ch|sh|sh|b|y|b|e|yu|ya" + \
					"|_|_|-|.|_" + \
					"" ; local outSymbolsArr = filterString outSymbols "|"; for n=1 to 29 do (append outSymbolsArr "")
local outStr = ""
for n=1 to inStr.count do
	(
	local index = findItem inSymbolsArr inStr[n]
	if index != 0
		then outStr += outSymbolsArr[index]
		else outStr += outSymbolsArr[random 37 62]
	)
return outStr
)
,	FUNCTION DeleteEmptyLayers =
(
(layermanager.getlayer 0).current = true
for i = Layermanager.count-1 to 1 by-1 do
	(
	layer = layermanager.getLayer i
	layer.nodes &theNodes
	if theNodes.count == 0 then (LayerManager.deleteLayerbyname layer.name)
	)
)
,	FUNCTION SetupBMP =
(
rollout rolloutSetupBMP "BMP Configuration"
(
groupBox grp_Colors "Colors" pos:[10,6] width:212 height:60
radiobuttons rdbtn_ColorPalette "" labels:#("8 Bit Optimized palette  (256 Colors)","RGB 24 bit  (16.7 Million Colors)") pos:[22,24] columns:1 default:(def; case (bmp.getType()) of (#paletted: def=1; #true24: def=2); def)
button btn_OK "OK" pos:[30,72] width:80 height:24
button btn_Cancel "Cancel" pos:[122,72] width:80 height:24
on btn_OK pressed do
(
case rdbtn_ColorPalette.state of 
	(
	1: bmp.setType #paletted
	2: bmp.setType #true24
	)
destroyDialog rolloutSetupBMP
)
on btn_Cancel pressed do (destroyDialog rolloutSetupBMP)
)
X = mouse.screenpos.X; Y = mouse.screenpos.Y
CreateDialog rolloutSetupBMP 232 104 pos:[(X-114),(Y-10)] style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) modal:true
)
,	FUNCTION SetupJPEG =
(
rollout rolloutSetupJPEG "JPEG Image Control"
(
groupBox grp_ImageControl "Image Control" pos:[10,6] width:212 height:44
spinner spnr_Quality "Quality:" pos:[48,26] width:56 range:[1,100,(JPEG.getQuality())] type:#integer scale:1 enabled:true tooltip:"JPEG Quality"
spinner spnr_Smoothing "Smoothing:" pos:[150,26] width:60 range:[0,100,(JPEG.getSmoothing())] type:#integer scale:1 enabled:true tooltip:"JPEG Smoothing"
button btn_OK "OK" pos:[30,56] width:80 height:24
button btn_Cancel "Cancel" pos:[122,56] width:80 height:24
on btn_OK pressed do (JPEG.setQuality spnr_Quality.value; JPEG.setSmoothing spnr_Smoothing.value; destroyDialog rolloutSetupJPEG)
on btn_Cancel pressed do (destroyDialog rolloutSetupJPEG)
)
X = mouse.screenpos.X; Y = mouse.screenpos.Y
CreateDialog rolloutSetupJPEG 232 88 pos:[(X-114),(Y-10)] style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) modal:true
)
,	FUNCTION SetupPNG =
(
rollout rolloutSetupPNG "PNG Configuration"
(
groupBox grp_Colors "Colors" pos:[10,6] width:180 height:102
radiobuttons rdbtn_ColorPalette "" labels:#("Optimized palette  (256)", "RGB 24bit  (16.7 Million)", "RGB 48 bit  (281 Trillion)", "Grayscale 8 bit  (256)", "Grayscale 16 bit  (65,536)") pos:[22,24] columns:1 default:(def; case (pngIO.getType()) of (#paletted: def=1; #true24: def=2; #true48: def=3; #gray8: def=4; #gray16: def=5); def)
checkbox chbx_AlphaChannel "Alpha channel" pos:[16,114] checked:(pngIO.getAlpha())
checkbox chbx_Interlaced "Interlaced" pos:[116,114] checked:(pngIO.getInterlaced())
button btn_OK "OK" pos:[15,142] width:80 height:24
button btn_Cancel "Cancel" pos:[107,142] width:80 height:24
on btn_OK pressed do
(
pngIO.setAlpha (chbx_AlphaChannel.checked)
pngIO.setInterlaced (chbx_Interlaced.checked)
case rdbtn_ColorPalette.state of 
	(
	1: pngIO.setType #paletted
	2: pngIO.setType #true24
	3: pngIO.setType #true48
	4: pngIO.setType #gray8
	5: pngIO.setType #gray16
	)
destroyDialog rolloutSetupPNG
)
on btn_Cancel pressed do (destroyDialog rolloutSetupPNG)
)
X = mouse.screenpos.X; Y = mouse.screenpos.Y
CreateDialog rolloutSetupPNG 200 174 pos:[(X-100),(Y-10)] style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) modal:true
)
,	FUNCTION SetupTGA =
(
rollout rolloutSetupTGA "Targa Image Control"
(
groupBox grp_ImageAttributes "Image Attributes" pos:[10,6] width:264 height:74
label lbl_BitsPerPixel "Bits-Per-Pixel:" pos:[22,37]
radiobuttons rdbtn_ColorPalette "" labels:#("16", "24", "32") pos:[92,24] columns:1 default:(def; case (Targa.getColorDepth()) of (16: def=1; 24: def=2; 32: def=3); def)
checkbox chbx_Compress "Compress" pos:[152,24] checked:(Targa.getCompressed()==1)
checkbox chbx_AlphaSplit "Alpha Split" pos:[152,39] checked:(Targa.getAlphaSplit())
checkbox chbx_PreMultAlpha "Pre-Multiplied Alpha" pos:[152,54] checked:(Targa.getPreMultAlpha())
button btn_OK "OK" pos:[52,86] width:80 height:24
button btn_Cancel "Cancel" pos:[150,86] width:80 height:24
on btn_OK pressed do
(
Targa.setCompressed (chbx_Compress.checked)
Targa.setAlphaSplit (chbx_AlphaSplit.checked)
Targa.setPreMultAlpha (chbx_PreMultAlpha.checked)
case rdbtn_ColorPalette.state of 
	(
	1: Targa.setColorDepth 16
	2: Targa.setColorDepth 24
	3: Targa.setColorDepth 32
	)
destroyDialog rolloutSetupTGA
)
on btn_Cancel pressed do (destroyDialog rolloutSetupTGA)
)
X = mouse.screenpos.X; Y = mouse.screenpos.Y
CreateDialog rolloutSetupTGA 284 118 pos:[(X-140),(Y-10)] style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) modal:true
)
,	FUNCTION SetupTIFF =
(
rollout rolloutSetupTIFF "Targa Image Control"
(
groupBox grp_ImageType "Image Type" pos:[10,6] width:138 height:126
radiobuttons rdbtn_ColorPalette "" labels:#("8-bit Greyscale", "8-bit Color", "16-bit Color", "16-bit SGI LogL", "32-bit SGI LogLUV") pos:[22,24] columns:1 default:(def; case (TIF.getType()) of (#mono: def=1; #color: def=2; #color16: def=3; #logL: def=4; #logLUV: def=5); def)
checkbox chbx_AlphaChannel "Store Alpha Channel" pos:[22,106] checked:(if TIF.getAlpha()==#true then true else false)
groupBox grp_CompressionType "Compression Type" pos:[154,6] width:138 height:56
radiobuttons rdbtn_Compression "" labels:#("No Compression", "Packbits") pos:[166,24] columns:1 default:(if TIF.getCompression()==#none then 1 else 2)
spinner spnr_DPI "Dots Per Inch" pos:[204,69] width:84 range:[0,12000,(TIF.getDPI())] type:#float scale:1 enabled:true
button btn_OK "OK" pos:[156,106] width:64 height:24
button btn_Cancel "Cancel" pos:[227,106] width:64 height:24
on btn_OK pressed do
(
case rdbtn_ColorPalette.state of 
	(
	1: TIF.setType #mono
	2: TIF.setType #color
	3: TIF.setType #color16
	4: TIF.setType #logL
	5: TIF.setType #logLUV
	)
TIF.setAlpha (if chbx_AlphaChannel.checked then #true else #false)
case rdbtn_Compression.state of 
	(
	1: TIF.setCompression #none
	2: TIF.setCompression #packBits
	)
TIF.setDPI (spnr_DPI.value)
destroyDialog rolloutSetupTIFF
)
on btn_Cancel pressed do (destroyDialog rolloutSetupTIFF)
)
X = mouse.screenpos.X; Y = mouse.screenpos.Y
CreateDialog rolloutSetupTIFF 300 140 pos:[(X-150),(Y-10)] style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) modal:true
)
,	FUNCTION Refresh = 
(
local hbcG = hideByCategory.Geometry
local hbcSh = hideByCategory.Shapes
local hbcL = hideByCategory.Lights
local hbcC = hideByCategory.Cameras
local hbcH = hideByCategory.Helpers
local hbcSp = hideByCategory.Spacewarps
local hbcP = hideByCategory.Particles
local hbcB = hideByCategory.Bones
with undo off (local p = point(); delete p)
hideByCategory.Geometry = hbcG
hideByCategory.Shapes = hbcSh
hideByCategory.Lights = hbcL
hideByCategory.Cameras = hbcC
hideByCategory.Helpers = hbcH
hideByCategory.Spacewarps = hbcSp
hideByCategory.Particles = hbcP
hideByCategory.Bones = hbcB
)
,	FUNCTION messageNS title:" Assembly Tool" = (messageBox "Objects Not Selected." title:title beep:false)
,	FUNCTION messageNGNS title:" Assembly Tool" = (messageBox "Objects Not Selected Or Not Gometry Class." title:title beep:false)
,	FUNCTION messageOGO title:" Assembly Tool" = (messageBox "Select One Gometry Class Object." title:title beep:false)
,	FUNCTION messageGF title:" Assembly Tool" = (messageBox "Groups Found in Selection." title:title beep:false)
,	FUNCTION messageSI title:" Assembly Tool" = (messageBox "Select Items In List." title:title beep:false)

)---Struct ATfn_

)