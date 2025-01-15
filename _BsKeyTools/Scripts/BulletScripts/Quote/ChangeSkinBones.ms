(
local skin_obj, From_bone, To_bone, confirmLoadEnvelopes, loadEnvelope

fn confirmLoadEnvelopes removeIncomingPrefix:false removeCurrentPrefix:false =
(
	--local BM_SETCHECK = 241
	local hwnd = dialogMonitorOps.getWindowHandle()
	if (uiAccessor.getWindowText hwnd == "Load Envelopes") then
	(
		UIAccessor.PressButtonByName hwnd "Match by Name"
		forceCompleteRedraw()
		UIAccessor.PressButtonByName hwnd "OK"
	)
	true
)

fn confTT = (confirmLoadEnvelopes removeIncomingPrefix:true removeCurrentPrefix:true)
fn confTF = (confirmLoadEnvelopes removeIncomingPrefix:true removeCurrentPrefix:false)
fn confFT = (confirmLoadEnvelopes removeIncomingPrefix:false removeCurrentPrefix:true)
fn confFF = (confirmLoadEnvelopes removeIncomingPrefix:false removeCurrentPrefix:false)

fn loadEnvelope theSkin envFile removeIncomingPrefix:false removeCurrentPrefix:false =
(
	--determine which confirmLoadEnvelopes to use
	local confirmFn = case of
	(
		(removeIncomingPrefix and removeCurrentPrefix):confTT
		(removeIncomingPrefix and not removeCurrentPrefix):confTF
		(not removeIncomingPrefix and removeCurrentPrefix):confFT
		(not removeIncomingPrefix and not removeCurrentPrefix):confFF
	)
	
	DialogMonitorOps.Enabled = true	--DialogMonitorOps.Enabled = false
	DialogMonitorOps.RegisterNotification confirmFn id:#pressSkinOK
	skinOps.LoadEnvelope theSkin envFile
	DialogMonitorOps.unRegisterNotification id:#pressSkinOK
	DialogMonitorOps.Enabled = false
	ok
)






rollout unnamedRollout "Skin Bone Change" width:192 height:230
(
		pickbutton 'btn1' "Select Skin Object" pos:[40,16] width:104 height:48 align:#left
	pickbutton 'btn2' "From" pos:[8,96] width:60 height:40 align:#left
	pickbutton 'btn3' "To" pos:[120,96] width:60 height:40 align:#left
	label 'lbl1' "------>" pos:[80,112] width:40 height:16 align:#left
	button 'btn4' "Start" pos:[8,152] width:176 height:32 align:#left
	label 'lbl3' "Select Bone" pos:[8,80] width:101 height:16 align:#left
	label 'lbl6' "------------------------------------------" pos:[8,64] width:192 height:16 align:#left	
	button 'btn5' "Help" pos:[8,192] width:176 height:32 align:#left
	label 'lbl14' "Select Skin Object" pos:[8,0] width:101 height:16 align:#left
	label 'lbl5' "------------------------------------------" pos:[8,136] width:192 height:16 align:#left

	on btn1 picked a do 
	(btn1.text = a.name
	skin_obj=a
	)
	
	on btn2 picked a do 
	(btn2.text = a.name
	From_bone=a
	)
	
	on btn3 picked a do 
	(btn3.text = a.name
	To_bone=a
	)
	
	on btn5 pressed do 
	(
		help_text=""+
		"1. Select Skin Object\n"+
		"2. Select the bone you want to Copy the Value\n"+
		"That bone must be registered with Skin Modifier\n"+
		"3. Select the bone you want to Paste the Value\n"+
		"That bone must be not registered with Skin Modifier\n\n"+
		"The Bone from which the value is extracted will disappear from the list, and the pasted Bone will replace it"
		messagebox help_text
	)
	
	on btn4 pressed do
	(
	if skin_obj==undefined or From_bone==undefined or To_bone==undefined do
		(messagebox "Object registration not completed"		return 0)
	
	if skin_obj==From_bone or From_bone==To_bone or To_bone==skin_obj do
		(messagebox "Registering duplicate objects\nCheck All Elements"		return 0)
	
	if skin_obj.modifiers["Skin"]==undefined do
		(messagebox (skin_obj.name+" does not have a skin modifier")	return 0)
	skinn=skin_obj.modifiers["Skin"]
	check_From_bone_exists=false
	select skin_obj
	for i=1 to (skinOps.GetNumberBones skinn) do
		(
		if From_bone.name == (skinOps.GetBoneName skinn i 1) do
		(check_From_bone_exists=true; exit) 
		)
	if check_From_bone_exists==false do 
		(messagebox (From_bone.name+"(From) must be registered")	return 0)
	
	for i=1 to (skinOps.GetNumberBones skinn) do
		(
		if To_bone.name == (skinOps.GetBoneName skinn i 1) do
		(messagebox (To_bone.name+"(To) must not be registered")	return 0)
		)
	
	
	skinOps.SaveEnvelope skinn (getdir #autoback+"\\SkinBoneChange.env")
	skinOps.addBone skinn To_bone -1
	Original_From_bone_name=From_bone.name
	From_bone.name="imsi"
	Original_To_bone_name=To_bone.name
	To_bone.name=Original_From_bone_name
	for i=1 to (skinOps.GetNumberBones skinn) do
		(
		if "imsi" == (skinOps.GetBoneName skinn i 1) do
		(skinOps.removeBone $.modifiers[#Skin] i; exit) 
		)
	loadEnvelope skinn (getdir #autoback+"\\SkinBoneChange.env")
	From_bone.name=Original_From_bone_name
	To_bone.name=Original_To_bone_name
		Messagebox "Succes"
	)
)
createdialog unnamedRollout
)