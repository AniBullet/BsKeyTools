/*
 * @Description: 学习自 http://www.scriptspot.com/3ds-max/scripts/interactive-rollout-builder
 * @Author: Bullet.S 仅修改了一些代码
 * @Date: 2022-02-13 16:37:19
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-02-13 16:43:06
 * @Email: animator.bullet@foxmail.com
 */

struct rolloutConstructor
(
	rolloutName = "",
	rolloutTitle = "",
	getLiveSize = false,
	rolloutWidth = 300,
	rolloutHeight = 500,
	useHeight = true,
	usePos = false,
	pos = [100,100],
	bgcolor = undefined,
	fgcolor = undefined,
	useBitmap = false,
	bitmap = undefined,
	bmpstyle = undefined, --#bmp_center #bmp_tile #bmp_stretch 
	style = #(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox, #style_resizing),
	menu = undefined,
	lockWidth = false,
	lockHeight = false,
	doescapeEnable = false,
	modal = false,
	controls = #(),
	activeControl = 0,
	locals = #(),
	functions = #(),
	eventHandlers = #()
)

struct UIControlStruct
(
	controltype = "",
	controlName = "",
	label = "",
	usePos = false,
	pos = [0,0],
	useWidth = false,
	useHeight = false,
	height = 0,
	width = 0,
	useOffset = false,
	offset = [0,0],
	useVisible = false,
	visible = true,
	useAlign = false,
	align = #left,
	useAcross = false,
	across = 1,
	enabled = undefined,
	value = undefined,
	checked = undefined,
	state = undefined,
	color = undefined, 
	selection = undefined,
	useColumns= undefined,
	columns = undefined,
	useFieldWidth = undefined,
	fieldwidth = undefined,
	range = undefined,
	type = undefined,
	text = undefined,
	items = undefined,
	labels = undefined,
	images = undefined,
	bitmap = undefined, 
	filename = undefined,
	labelontop = undefined,
	border = undefined,
	rollouts = undefined,
	controller = undefined,
	indeterminate = undefined,
	setKeyBrackets = undefined,
	scale = undefined,
	readOnly = undefined,
	bold = undefined,
	message = undefined,
	filter = undefined, 
	autoDisplay = undefined,
	ticks = undefined,
	useTriState = undefined,
	triState = undefined,
	orient = undefined,
	map = undefined,
	material = undefined,
	style = undefined,
	transparent = undefined,
	modal = undefined,
	style_sunkenEdge = undefined,
	highlightColor = undefined,
	offsets = undefined,
	degrees = undefined,
	diameter = undefined,
	startDegree = undefined,
	startRadians = undefined,
	opacity = undefined,
	alpha = undefined,
	dir = undefined,
	title = undefined,
	hoverColor = undefined,
	visitedColor = undefined,
	address = undefined,
	x_range  = undefined,
	y_range = undefined,
	x_value = undefined,
	numCurves = undefined,
	displayModes = undefined,
	commandMode = undefined,
	zoomValues = undefined,
	scrollValues  = undefined,
	curves = undefined,
	uiFlags = undefined,
	rcmFlags = undefined,
	asPopup = undefined,
	tooltip = "",
	comment = "",
	eventHandlers = #(),
	usePercentageWidth = false,
	percentageWidth = 25
	
)


if DW_InteractiveRolloutBuilder == undefined do persistent global DW_InteractiveRolloutBuilderPos

	try(closerolloutfloater rolloutBuilder)catch()
	try(DestroyDialog RL_CustomUI)catch()


	ss = stringstream"--some comment text\nRollout RL_Test \"Test\" width:160\n(\n\tbutton btn_A \"button\" width:150 across:2\n\tcheckbox chk_a \"check\" checked:true\n\tdropdownlist ddl_ABA \"Rad\" items:#(\"a\",\"b\",\"c\")\n)"
	lastRollout
	RL_CustomUI
	global RL_RolloutCreator
	global RL_RolloutBuilder
	global RL_RolloutCreatorPos

	--Feature List to do:
	--Store / Load UIs to disk or in scene? - DONE
	--save position and size of UI
	--All properties for rollout - DONE
	--default colors for rollout - DONE
	--disable tooltip for some controls - label, listbox, multislistbox, hyperlink, progressbar, edittext, angle, bitmap, groupbox, subrollout, colorpicker, curvecontrol - DONE
	--add RC Menu support
	--listbox/multiistbox/combobox/ddL move up/down items - DONE
	--Color bug - DONE
	--can we move child window with main window? Probably not needed
	--Escape characters for any string inputs with quotes. - DONE
	--
	--dotnet controls

	fn checkString str =
	(
		rx = dotnetobject "System.Text.RegularExpressions.Regex" "(?<!\\\\)\""
		while (rx.isMatch str) do
			str = rx.Replace str "\\\""
		
		rx = dotnetobject "System.Text.RegularExpressions.Regex" "(?<!\\\\)(\\\\{2}\")"
		while (rx.isMatch str) do
			str = rx.Replace str "\\\\\\\""
		
		rx = dotnetobject "System.Text.RegularExpressions.Regex" "(?<!\\\\)(\\\\{4}\")"
		while (rx.isMatch str) do
			str = rx.Replace str "\\\\\\\\\\\""
		
		rx = dotnetobject "System.Text.RegularExpressions.Regex" "(?<!\\\\)(\\\\{6}\")"
		while (rx.isMatch str) do
			str = rx.Replace str "\\\\\\\\\\\\\\\""
		
		return str
	)

	struct dotNetControlStruct
	(
		dotnetType = undefined,
		controlName = "",
		dotnetPath = "",
		controltype = "",	
		label = "",
		usePos = false,
		pos = [0,0],
		useWidth = false,
		useHeight = false,
		height = 0,
		width = 0,
		useOffset = false,
		offset = [0,0],
		useAlign = false,
		align = #left,
		useAcross = false,
		across = 1,
		enabled = undefined
		

	)

	struct eventHandler 
	(
		control = undefined,
		event = undefined,
		args = #(),
		code = ""
	)

	struct userFunction
	(
		functionName = "",
		args = #(),
		code = ""
	)

	

	struct scriptConstructor
	(
		rollouts = #(),
		code = ""
	)
	
	global rolloutConstructor
	global UIControlStruct
	
	if newRollout == undefined then
	(		
		global newRollout = rolloutConstructor rolloutName:"RL_Rollout" rolloutTitle:"Test Rollout" Rolloutwidth:330
	)
	else
	(
		newRolloutStruct = rolloutConstructor()
		if (getpropnames newRollout).count < (getpropnames newRolloutStruct).count do
		(
			--print "Node Updated"
			for p in getpropnames newRollout do
			(
				try(setproperty newRolloutStruct p (getproperty newRollout p ))catch()
			)
			
			newRollout = newRolloutStruct
		)
	)
	
	
	
	--Control Rollouts
	--(
			Rollout RL_Spinner "Spinner"
			(
				checkbox chk_useFieldWidth "Field Width" across:2 align:#left
				spinner spn_fieldWidth "" range:[0,1e9,45]
				
				spinner spn_from "From" range:[-1e9,1e9,0] 
				spinner spn_to "To" range:[-1e9,1e9,100]
				spinner spn_value "Value" range:[-1e9,1e9,1]
				
				label lbl_type "Type" align:#left 
				radiobuttons rdo_type "" Labels:#("float","integer","worldUnits") columns:1
				--indeterminate
				checkbox chk_indeterminate "Indeterminate" 
				--controller
				edittext edt_controller "Controller"
				--setKeyBrackets
				checkbox chk_setKeyBrackets "Set Key Brackets"
				--scale
				spinner spn_scale "Scale" type:#float range:[0,100,1]
				
				
				on RL_Spinner open do
				(
					local ui = newRollout.controls[newRollout.activeControl]
					if ui.range != undefined do
					(
						spn_from.value = ui.range[1]
						spn_to.value = ui.range[2]
						spn_value.value = ui.range[3]
					)
					if ui.useFieldWidth != undefined do chk_useFieldWidth.checked = ui.useFieldWidth
					if ui.fieldWidth != undefined do spn_fieldWidth.value = ui.fieldWidth
					if ui.type != undefined then
					(
						rdo_type.state = case ui.type of
						(
							"float" : 1
							"integer" : 2
							"worldUnits" : 3
						)
					)
					else
					(
						rdo_type.state = 1
					)
					if ui.indeterminate != undefined do chk_indeterminate.checked = ui.indeterminate
					if ui.controller != undefined do edt_controller.text = ui.controller
					if ui.setKeyBrackets != undefined do chk_setKeyBrackets.checked = ui.setKeyBrackets
					if ui.scale != undefined do spn_scale.value = ui.scale
				)
				on edt_controller entered text do newRollout.controls[newRollout.activeControl].controller = text
				on chk_setKeyBrackets changed state do 
				(
					newRollout.controls[newRollout.activeControl].setKeyBrackets = state
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_scale changed val do 
				(
					newRollout.controls[newRollout.activeControl].scale = val
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_indeterminate changed state do 
				(
					newRollout.controls[newRollout.activeControl].indeterminate = state
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_From changed val do 
				(
					newRollout.controls[newRollout.activeControl].range[1] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_to changed val do 
				(
					newRollout.controls[newRollout.activeControl].range[2] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_value changed val do 
				(
					newRollout.controls[newRollout.activeControl].range[3] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_useFieldWidth changed state do 
				(
					newRollout.controls[newRollout.activeControl].useFieldWidth = state
					newRollout.controls[newRollout.activeControl].fieldWidth = spn_fieldWidth.value
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_fieldWidth changed val do 
				(
					newRollout.controls[newRollout.activeControl].fieldWidth = val
					RL_RolloutBuilder.addCustomUI()
				)
				on rdo_type changed state do 
				(
					newRollout.controls[newRollout.activeControl].type = case state of
					(
						1 : "float"
						2 : "integer"
						3 : "worldUnits"
					)
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_edittext "Edittext"
			(
				edittext edt_text "Text"
				checkbox chk_labelOnTop "Label on Top"
				checkbox chk_useFieldWidth "Use FieldWidth" --todo
				spinner spn_fieldWidth "Field Width" --todo
				checkbox chk_bold "Bold" --todo
				checkbox chk_readOnly "Read Only" --todo
				
				on RL_edittext open do
				(
					if newRollout.controls[newRollout.activeControl].text != undefined do edt_text.text = newRollout.controls[newRollout.activeControl].text
					if newRollout.controls[newRollout.activeControl].labelOnTop != undefined do chk_labelOnTop.checked = newRollout.controls[newRollout.activeControl].labelOnTop
					if newRollout.controls[newRollout.activeControl].bold != undefined do chk_bold.checked = newRollout.controls[newRollout.activeControl].bold
					if newRollout.controls[newRollout.activeControl].readOnly != undefined do chk_ReadOnly.checked = newRollout.controls[newRollout.activeControl].readOnly
					if newRollout.controls[newRollout.activeControl].useFieldWidth != undefined do chk_useFieldWidth.checked = newRollout.controls[newRollout.activeControl].useFieldWidth
					if newRollout.controls[newRollout.activeControl].fieldWidth != undefined do spn_fieldWidth.value = newRollout.controls[newRollout.activeControl].fieldWidth
				)
				
				on edt_text entered text do 
				(
					text = checkString text
					edt_text.text = text
					newRollout.controls[newRollout.activeControl].text = text
					RL_RolloutBuilder.addCustomUI()
				)
				
				on chk_labelOnTop changed state do 
				(
					newRollout.controls[newRollout.activeControl].labelOnTop = state
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_useFieldWidth changed state do
				(
					newRollout.controls[newRollout.activeControl].useFieldWidth = state
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_fieldWidth changed val do
				(
					newRollout.controls[newRollout.activeControl].fieldWidth = val
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_bold changed state do
				(
					newRollout.controls[newRollout.activeControl].bold = state
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_readOnly changed state do
				(
					newRollout.controls[newRollout.activeControl].readOnly = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_Listbox "Listbox"
			(
				listbox lbx_items "Items"
				edittext edt_newItem "New Item" text:""
				button btn_addItem "Add Item" width:160
				button btn_removeItem "Remove Item" width:160
				spinner spn_selection "Selection" type:#integer
				
				button btn_itemUp "Move Item Up" width:160
				button btn_itemDown "Move Item Down" width:160
				
				checkbox chk_readOnly "Read Only" --todo
				
				on RL_Listbox open do
				(
					if newRollout.controls[newRollout.activeControl].items != undefined do lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					if newRollout.controls[newRollout.activeControl].selection != undefined do spn_selection.value = newRollout.controls[newRollout.activeControl].selection
					if newRollout.controls[newRollout.activeControl].readOnly != undefined do chk_readOnly.checked = newRollout.controls[newRollout.activeControl].readOnly
				)
				
				on btn_addItem pressed do
				(
					if edt_newItem.text != "" and edt_newItem.text != "\"" do
					(
						edt_newItem.text = checkString edt_newItem.text
						append newRollout.controls[newRollout.activeControl].items (edt_newItem.text)
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						lbx_items.selection = lbx_items.items.count
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on btn_removeItem pressed do
				(
					if lbx_items.selection != 0 do
					(
						deleteitem newRollout.controls[newRollout.activeControl].items lbx_items.selection
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on spn_selection changed val do
				(
					newRollout.controls[newRollout.activeControl].selection = val
					RL_RolloutBuilder.addCustomUI()
				)
				
				on btn_itemUp pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != 1 do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection - 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection -= 1
					RL_RolloutBuilder.addCustomUI()
				)
				
				on btn_itemDown pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != lbx_items.items.count do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection + 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection += 1
					RL_RolloutBuilder.addCustomUI()
				)
				
				on chk_readOnly changed state do
				(
					newRollout.controls[newRollout.activeControl].readOnly = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_Multilistbox "Multilistbox"
			(
				--checkbox chk_useSelection "Use Selection"
				spinner spn_selection "Selection" type:#integer
				listbox lbx_items "Items"
				edittext edt_newItem "New Item" text:"\"\""
				button btn_addItem "Add Item" width:160
				button btn_removeItem "Remove Item" width:160
				
				button btn_itemUp "Move Item Up" width:160
				button btn_itemDown "Move Item Down" width:160
				
				on RL_Multilistbox open do
				(
					if newRollout.controls[newRollout.activeControl].selection != undefined do spn_selection.value = newRollout.controls[newRollout.activeControl].selection
					if newRollout.controls[newRollout.activeControl].items != undefined do lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
				)
				
				on btn_addItem pressed do
				(
					if edt_newItem.text != "" and edt_newItem.text != "\"" do
					(
						edt_newItem.text = checkString edt_newItem.text
						append newRollout.controls[newRollout.activeControl].items (edt_newItem.text)
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on btn_removeItem pressed do
				(
					if lbx_items.selection != 0 do
					(
						deleteitem newRollout.controls[newRollout.activeControl].labels lbx_items.selection
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on btn_itemUp pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != 1 do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection - 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection -= 1
					RL_RolloutBuilder.addCustomUI()
				)
				
				on btn_itemDown pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != lbx_items.items.count do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection + 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection += 1
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_combobox "Combobox"
			(
				spinner spn_selection "Selection" type:#integer--todo
				edittext edt_text "Text" labelontop:true--todo
				listbox lbx_items "Items"
				edittext edt_newItem "New Item" text:"\"\""
				button btn_addItem "Add Item" width:160
				button btn_removeItem "Remove Item" width:160
				
				button btn_itemUp "Move Item Up" width:160
				button btn_itemDown "Move Item Down" width:160
				
				on RL_comboBox open do
				(
					if newRollout.controls[newRollout.activeControl].items != undefined do lbx_items.items = newRollout.controls[newRollout.activeControl].items
					if newRollout.controls[newRollout.activeControl].selection != undefined do spn_Selection.value = newRollout.controls[newRollout.activeControl].selection
					if newRollout.controls[newRollout.activeControl].text != undefined do edt_text.text = newRollout.controls[newRollout.activeControl].text
					
				)
				
				on btn_addItem pressed do
				(
					if edt_newItem.text != "" and edt_newItem.text != "\"" do
					(
						edt_newItem.text = checkString edt_newItem.text
						append newRollout.controls[newRollout.activeControl].items (edt_newItem.text)
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on btn_removeItem pressed do
				(
					if lbx_items.selection != 0 do
					(
						deleteitem newRollout.controls[newRollout.activeControl].labels lbx_items.selection
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on spn_selection changed val do
				(
					newRollout.controls[newRollout.activeControl].selection = val
					RL_RolloutBuilder.addCustomUI()
				)
				on edt_text entered text do
				(
					newRollout.controls[newRollout.activeControl].text = text
					RL_RolloutBuilder.addCustomUI()
				)
				on btn_itemUp pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != 1 do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection - 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection -= 1
					RL_RolloutBuilder.addCustomUI()
				)
				
				on btn_itemDown pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != lbx_items.items.count do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection + 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection += 1
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_dropdownlist "Dropdown List"
			(
				spinner spn_selection "Selection" type:#integer
				listbox lbx_items "Items"
				edittext edt_newItem "New Item" text:"\"\""
				button btn_addItem "Add Item" width:160
				button btn_removeItem "Remove Item" width:160
				
				button btn_itemUp "Move Item Up" width:160
				button btn_itemDown "Move Item Down" width:160
				
				on RL_dropdownlist open do
				(
					if newRollout.controls[newRollout.activeControl].items != undefined do lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					if newRollout.controls[newRollout.activeControl].selection != undefined do spn_selection.value = newRollout.controls[newRollout.activeControl].selection
				)
				on btn_addItem pressed do
				(
					if edt_newItem.text != "" and edt_newItem.text != "\"" do
					(
						edt_newItem.text = checkString edt_newItem.text
						append newRollout.controls[newRollout.activeControl].items (edt_newItem.text)
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on btn_removeItem pressed do
				(
					if lbx_items.selection != 0 do
					(
						deleteitem newRollout.controls[newRollout.activeControl].labels lbx_items.selection
						lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on spn_Selection changed val do
				(
					newRollout.controls[newRollout.activeControl].selection = val
					RL_RolloutBuilder.addCustomUI()
				)
				
				on btn_itemUp pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != 1 do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection - 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection -= 1
					RL_RolloutBuilder.addCustomUI()
				)
				
				on btn_itemDown pressed do
				(
					if lbx_items.items.count > 1 and lbx_items.selection != lbx_items.items.count do
					(
						swap newRollout.controls[newRollout.activeControl].items[lbx_items.selection] newRollout.controls[newRollout.activeControl].items[lbx_items.selection + 1]
					)
					lbx_items.items = for o in newRollout.controls[newRollout.activeControl].items collect ("\"" + o + "\"")
					lbx_items.selection += 1
					RL_RolloutBuilder.addCustomUI()
				)
				
			)
			Rollout RL_radiobuttons "Radiobuttons"
			(
				listbox lbx_labels "Labels"
				spinner spn_state "State" type:#integer
				checkbox chk_useColumns "Use Columns" across:2
				spinner spn_columns "Columns" type:#integer range:[1,100,1]
				edittext edt_newItem "New Item" width:150
				button btn_addItem "Add Item" width:150
				button btn_removeItem "Remove Item" width:150
				--todo
				--offsets
				edittext edt_offsets "Offsets" labelontop:true
				button btn_makeOffsetsList "Make Offsets List" width:150
				
				
				on RL_radiobuttons open do
				(
					if newRollout.controls[newRollout.activeControl].labels != undefined do lbx_labels.items = for o in newRollout.controls[newRollout.activeControl].labels collect ("\"" + o + "\"")
					if newRollout.controls[newRollout.activeControl].state != undefined do spn_state.value = newRollout.controls[newRollout.activeControl].state
					if newRollout.controls[newRollout.activeControl].useColumns != undefined do chk_useColumns.checked = newRollout.controls[newRollout.activeControl].useColumns
					if newRollout.controls[newRollout.activeControl].columns != undefined do spn_columns.value = newRollout.controls[newRollout.activeControl].columns
					if newRollout.controls[newRollout.activeControl].offsets != undefined do edt_offsets.text = newRollout.controls[newRollout.activeControl].offsets
				)
				on spn_State changed val do 
				(
					newRollout.controls[newRollout.activeControl].state = val
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_useColumns changed state do
				(
					newRollout.controls[newRollout.activeControl].useColumns = state
					if state then
					(
						newRollout.controls[newRollout.activeControl].columns = spn_columns.value
					)
					else 
						newRollout.controls[newRollout.activeControl].columns = undefined
					
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_columns changed val do
				(
					newRollout.controls[newRollout.activeControl].columns = val
					RL_RolloutBuilder.addCustomUI()
				)
				on btn_addItem pressed do
				(
					if edt_newItem.text != "" and edt_newItem.text != "\"" do
					(
						append newRollout.controls[newRollout.activeControl].labels (execute(edt_newItem.text))
						lbx_labels.items = for o in newRollout.controls[newRollout.activeControl].labels collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on btn_removeItem pressed do
				(
					if lbx_labels.selection != 0 do
					(
						deleteitem newRollout.controls[newRollout.activeControl].labels lbx_labels.selection
						lbx_labels.items = for o in newRollout.controls[newRollout.activeControl].labels collect ("\"" + o + "\"")
						RL_RolloutBuilder.addCustomUI()
					)
				)
				on edt_offsets entered text do
				(
					newRollout.controls[newRollout.activeControl].offsets = text
					if text == "" do newRollout.controls[newRollout.activeControl].offsets = undefined
					RL_RolloutBuilder.addCustomUI()
				)
				on btn_makeOffsetsList pressed do
				(
					t = "#("
					for i = 1 to newRollout.controls[newRollout.activeControl].labels.count do 
					(
						append t "[0,0]"
						
						if i != newRollout.controls[newRollout.activeControl].labels.count then
						(
							append t ", "
						)
						else
						(
							append t ")"
						)
					)
					newRollout.controls[newRollout.activeControl].offsets = edt_offsets.text = t
				)
			)
			Rollout RL_pickButton "Pick Button"
			(
				--message
				edittext edt_message "Message" labelontop:true
				--filter
				edittext edt_filter "Filter" labelonTop:true
				--autoDisplay
				checkbox chk_autoDisplay "Auto Display"
				
				on RL_pickButton open do
				(
					if newRollout.controls[newRollout.activeControl].message != undefined do edt_message.text = newRollout.controls[newRollout.activeControl].message
					if newRollout.controls[newRollout.activeControl].filter != undefined do edt_filter.text = newRollout.controls[newRollout.activeControl].filter
					if newRollout.controls[newRollout.activeControl].autoDisplay != undefined do chk_autoDisplay.checked = newRollout.controls[newRollout.activeControl].autoDisplay
				)
				
				on edt_message entered text do
				(
					newRollout.controls[newRollout.activeControl].message = text
					if text == "" do newRollout.controls[newRollout.activeControl].message = undefined
					RL_RolloutBuilder.addCustomUI()
				)
				
				on edt_filter entered text do
				(
					newRollout.controls[newRollout.activeControl].filter = text
					if text == "" do newRollout.controls[newRollout.activeControl].filter = undefined
					RL_RolloutBuilder.addCustomUI()
				)
				
				on chk_autoDisplay changed state do
				(
					newRollout.controls[newRollout.activeControl].autoDisplay = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_HyperLink "HyperLink"
			(
				--color
				colorpicker cpl_color "Color" align:#right
				--hoverColor
				colorpicker cpl_hoverColor "HoverColor" align:#right
				--visitedColor
				colorpicker cpl_visitedColor "VisitedColor" align:#right
				--address
				edittext edt_address "Address"
				
				on RL_Hyperlink open do
				(
					if newRollout.controls[newRollout.activeControl].color != undefined do cpl_color.color = newRollout.controls[newRollout.activeControl].color
					if newRollout.controls[newRollout.activeControl].hoverColor != undefined do cpl_hoverColor.color = newRollout.controls[newRollout.activeControl].hoverColor
					if newRollout.controls[newRollout.activeControl].visitedColor != undefined do cpl_visitedColor.color = newRollout.controls[newRollout.activeControl].visitedColor
					if newRollout.controls[newRollout.activeControl].address != undefined do edt_address.text = newRollout.controls[newRollout.activeControl].address
				)
				on cpl_color changed col do
				(
					newRollout.controls[newRollout.activeControl].color = col
					RL_RolloutBuilder.addCustomUI()
				)
				on cpl_hoverColor changed col do
				(
					newRollout.controls[newRollout.activeControl].hoverColor = col
					RL_RolloutBuilder.addCustomUI()
				)
				on cpl_visitedColor changed col do
				(
					newRollout.controls[newRollout.activeControl].visitedColor = col
					RL_RolloutBuilder.addCustomUI()
				)
				on edt_address entered text do
				(
					text = checkString text
					edt_address.text = text
					newRollout.controls[newRollout.activeControl].address = text
					RL_RolloutBuilder.addCustomUI()
				)
			)
			--todo CurveControl
			Rollout RL_CurveControl "CurveControl"
			(
				spinner spn_numCurves "numCurves" type:#integer
				spinner spn_x_rangeFrom "Range X:" across:2 offset:[20,0]
				spinner spn_x_rangeTo "to:"
				spinner spn_y_rangeFrom "Range Y:" across:2 offset:[20,0]
				spinner spn_y_rangeTo "to:"
				spinner spn_x_value "X_value"
				spinner spn_zoomValuesX "ZoomValues X:" across:2 offset:[20,0]
				spinner spn_zoomValuesY "to:"
				
				spinner spn_scrollValuesX "scrollValues X:" across:2 offset:[20,0]
				spinner spn_scrollValuesY "Y:"
				
				--multilistbox mlbx_displayModes "displayModes" items:#()
				listbox lbx_commandMode "commandMode" items:#(#move_xy, #move_x, #move_y, #scale, #corner, #bezier)
				multilistBox mlbx_uiFlags "uiFlags (multi-select)" items:#(#drawBG, #drawgrid, #upperToolbar, #showReset, #lowerToolbar, #scrollBars, #autoScroll, #ruler, #constrainY, #hideDisabled, #all, #xvalue, #singleSelect, #noFilterButtons)
				multiListbox mlbx_rcmFlags "rcmFlags (multi-select)" items:#(#move_xy, #move_x, #move_y, #scale, #corner, #bezier, #delete, #all)
				
				checkbox chk_asPopup "asPopup"
				
				on RL_CurveControl open do
				(
					if newRollout.controls[newRollout.activeControl].x_range != undefined do spn_x_rangeFrom.value = newRollout.controls[newRollout.activeControl].x_range[1]
					if newRollout.controls[newRollout.activeControl].x_range != undefined do spn_x_rangeTo.value = newRollout.controls[newRollout.activeControl].x_range[2]
						
					if newRollout.controls[newRollout.activeControl].y_range != undefined do spn_y_rangeFrom.value = newRollout.controls[newRollout.activeControl].y_range[1]
					if newRollout.controls[newRollout.activeControl].y_range != undefined do spn_y_rangeTo.value = newRollout.controls[newRollout.activeControl].y_range[2]
					
					if newRollout.controls[newRollout.activeControl].x_value != undefined do spn_x_value.value = newRollout.controls[newRollout.activeControl].x_value
					
					if newRollout.controls[newRollout.activeControl].zoomValues != undefined do spn_zoomValuesX.value = newRollout.controls[newRollout.activeControl].zoomValues[1]
					if newRollout.controls[newRollout.activeControl].zoomValues != undefined do spn_zoomValuesY.value = newRollout.controls[newRollout.activeControl].zoomValues[2]
						
					if newRollout.controls[newRollout.activeControl].scrollValues != undefined do spn_scrollValuesX.value = newRollout.controls[newRollout.activeControl].scrollValues[1]
					if newRollout.controls[newRollout.activeControl].scrollValues != undefined do spn_scrollValuesY.value = newRollout.controls[newRollout.activeControl].scrollValues[2]
						
					if newRollout.controls[newRollout.activeControl].commandMode != undefined do lbx_commandMode.selection = finditem lbx_commandMode.items newRollout.controls[newRollout.activeControl].commandMode
					
					if newRollout.controls[newRollout.activeControl].uiFlags != undefined do mlbx_uiFlags.selection = (for o in newRollout.controls[newRollout.activeControl].uiFlags where (finditem mlbx_uiFlags.items o) != 0 collect (finditem mlbx_uiFlags.items o)) as bitarray
					if newRollout.controls[newRollout.activeControl].rcmFlags != undefined do mlbx_rcmFlags.selection = (for o in newRollout.controls[newRollout.activeControl].rcmFlags where (finditem mlbx_rcmFlags.items o) != 0 collect (finditem mlbx_rcmFlags.items o)) as bitarray
					
					if newRollout.controls[newRollout.activeControl].asPopup != undefined do chk_asPopup.checked = newRollout.controls[newRollout.activeControl].asPopup
				)
				on spn_numCurves changed val do
				(
					newRollout.controls[newRollout.activeControl].numCurves = col
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_x_rangeFrom changed val do
				(
					if newRollout.controls[newRollout.activeControl].x_range == undefined do newRollout.controls[newRollout.activeControl].x_range = [0,1]
					newRollout.controls[newRollout.activeControl].x_range[1] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_x_rangeTo changed val do
				(
					if newRollout.controls[newRollout.activeControl].x_range == undefined do newRollout.controls[newRollout.activeControl].x_range = [0,1]
					newRollout.controls[newRollout.activeControl].x_range[2] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_y_rangeFrom changed val do
				(
					if newRollout.controls[newRollout.activeControl].y_range == undefined do newRollout.controls[newRollout.activeControl].y_range = [0,1]
					newRollout.controls[newRollout.activeControl].y_range[1] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_y_rangeTo changed val do
				(
					if newRollout.controls[newRollout.activeControl].y_range == undefined do newRollout.controls[newRollout.activeControl].y_range = [0,1]
					newRollout.controls[newRollout.activeControl].y_range[2] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_x_value changed val do
				(
					newRollout.controls[newRollout.activeControl].x_value = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_zoomValuesX changed val do
				(
					if newRollout.controls[newRollout.activeControl].zoomValues == undefined do newRollout.controls[newRollout.activeControl].zoomValues = [0,0]
					newRollout.controls[newRollout.activeControl].zoomValues[1] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_zoomValuesY changed val do
				(
					if newRollout.controls[newRollout.activeControl].zoomValues == undefined do newRollout.controls[newRollout.activeControl].zoomValues = [0,0]
					newRollout.controls[newRollout.activeControl].zoomValues[2] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_scrollValuesX changed val do 
				(
					if newRollout.controls[newRollout.activeControl].scrollValues == undefined do newRollout.controls[newRollout.activeControl].scrollValues = [0,0]
					newRollout.controls[newRollout.activeControl].scrollValues[1] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_scrollValuesY changed val do
				(
					if newRollout.controls[newRollout.activeControl].scrollValues == undefined do newRollout.controls[newRollout.activeControl].scrollValues = [0,0]
					newRollout.controls[newRollout.activeControl].scrollValues[2] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on lbx_commandMode selected sel do
				(
					newRollout.controls[newRollout.activeControl].commandMode = lbx_commandMode.selected
					RL_RolloutBuilder.addCustomUI()
				)
				on mlbx_uiFlags selected sel do
				(
					newRollout.controls[newRollout.activeControl].uiFlags = (for o in mlbx_uiFlags.selection collect mlbx_uiFlags.items[o])
					RL_RolloutBuilder.addCustomUI()
				)
				on mlbx_rcmFlags selected sel do
				(
					newRollout.controls[newRollout.activeControl].rcmFlags = (for o in mlbx_rcmFlags.selection collect mlbx_rcmFlags.items[o])
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_asPopup changed state do
				(
					newRollout.controls[newRollout.activeControl].asPopup  = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_Angle "Angle"
			(
				--color
				colorpicker cpl_color "Color"
				--degrees
				spinner spn_degrees "Degrees" range:[0,360,0] type:#float
				--bitmap
				edittext edt_bitmap "Bitmap"
				--diameter
				spinner spn_diameter "Diameter" range:[0,1e9,64] type:#integer
				--startDegree
				spinner spn_startDegree "Start Degree" range:[0,360,0] type:#float
				--startRadians
				spinner spn_startRadians "Start Radians" range:[0,360,0] type:#float
				--dir #cw #ccw
				radiobuttons rdo_dir "Dir" labels:#("#cw","#ccw")
				--range
				spinner spn_from "From" range:[0,360,0]
				spinner spn_to "To" range:[0,360,360]
				spinner spn_value "Value" range:[0,360,0]
				
				on RL_Angle open do
				(
					if newRollout.controls[newRollout.activeControl].color != undefined do cpl_color.color = newRollout.controls[newRollout.activeControl].color
					if newRollout.controls[newRollout.activeControl].degrees != undefined do spn_degrees.value = newRollout.controls[newRollout.activeControl].degrees
					if newRollout.controls[newRollout.activeControl].bitmap != undefined do edt_bitmap.text = newRollout.controls[newRollout.activeControl].bitmap
					if newRollout.controls[newRollout.activeControl].diameter != undefined do spn_diameter.value = newRollout.controls[newRollout.activeControl].diameter
					if newRollout.controls[newRollout.activeControl].startDegree != undefined do spn_startDegree.value = newRollout.controls[newRollout.activeControl].startDegree
					if newRollout.controls[newRollout.activeControl].startRadians != undefined do spn_startRadians.value = newRollout.controls[newRollout.activeControl].startRadians
					
					if newRollout.controls[newRollout.activeControl].dir != undefined do
					(
						rdo_dir.state = case (newRollout.controls[newRollout.activeControl].dir as string) of
						(
							"cw" : 1
							"ccw" : 2
							default: 0
						)
					)
					if newRollout.controls[newRollout.activeControl].range != undefined do
					(
						spn_from.value = newRollout.controls[newRollout.activeControl].range[1]
						spn_to.value = newRollout.controls[newRollout.activeControl].range[2]
						spn_value.value = newRollout.controls[newRollout.activeControl].range[3]
					)
				)
				on cpl_color changed col do
				(
					newRollout.controls[newRollout.activeControl].color = col
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_degrees changed val do
				(
					newRollout.controls[newRollout.activeControl].degrees = val
					RL_RolloutBuilder.addCustomUI()
				)
				on edt_bitmap entered text do
				(
					newRollout.controls[newRollout.activeControl].bitmap = text
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_diameter changed val do
				(
					newRollout.controls[newRollout.activeControl].diameter = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_startDegree changed val do
				(
					newRollout.controls[newRollout.activeControl].startDegree = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_startRadians changed val do
				(
					newRollout.controls[newRollout.activeControl].startRadians = val
					RL_RolloutBuilder.addCustomUI()
				)
				on rdo_dir changed state do
				(
					newRollout.controls[newRollout.activeControl].dir = case state of
					(
						1: #cw
						2: #ccw
						default: undefined
					)
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_from changed val do
				(
					if newRollout.controls[newRollout.activeControl].range == undefined do newRollout.controls[newRollout.activeControl].range = [0,360,0]
					newRollout.controls[newRollout.activeControl].range[1] = val
					RL_RolloutBuilder.addCustomUI()
				)
				
				on spn_to changed val do
				(
					if newRollout.controls[newRollout.activeControl].range == undefined do newRollout.controls[newRollout.activeControl].range = [0,360,0]
					newRollout.controls[newRollout.activeControl].range[2] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_value changed val do
				(
					if newRollout.controls[newRollout.activeControl].range == undefined do newRollout.controls[newRollout.activeControl].range = [0,360,0]
					newRollout.controls[newRollout.activeControl].range[3] = val
					RL_RolloutBuilder.addCustomUI()
				)
				
			)
			Rollout RL_Group "Group"
			(
				label lbl_non "No Parameters for Group"
			)
			Rollout RL_Groupbox "Groupbox"
			(
				label lbl_non "No Parameters for Groupbox"
			)
			Rollout RL_SubRollout "Sub Rollout"
			(
				label lbl_non "No Parameters for SubRollout"
			)
			Rollout RL_Slider "Slider"
			(
				--range
				spinner spn_from "From" type:#float range:[-1e9,1e9,0]
				spinner spn_to "To" type:#float range:[-1e9,1e9,100]
				spinner spn_value "Value" type:#float range:[-1e9,1e9,0]
				--type
				radiobuttons rdo_type "Type" labels:#("#float","#integer")
				--ticks
				spinner spn_ticks "Ticks" type:#integer range:[0,100,10]
				--orient
				radiobuttons rdo_orient "orient" labels:#("#horizontal","#vertical")
				--controller
				edittext edt_controller "Controller" labelontop:true
				
				on RL_Slider open do
				(
					if newRollout.controls[newRollout.activeControl].range != undefined do
					(
						spn_from.value = newRollout.controls[newRollout.activeControl].range[1]
						spn_to.value = newRollout.controls[newRollout.activeControl].range[2]
						spn_value.value = newRollout.controls[newRollout.activeControl].range[3]
					)
					if newRollout.controls[newRollout.activeControl].type != undefined do
					(
						rdo_type.state = case (newRollout.controls[newRollout.activeControl].type as string) of
						(
							"float" : 1
							"integer" : 2
							default: 0
						)
					)
					if newRollout.controls[newRollout.activeControl].ticks != undefined do spn_ticks.value = newRollout.controls[newRollout.activeControl].ticks
					if newRollout.controls[newRollout.activeControl].orient != undefined do
					(
						rdo_orient.state = case (newRollout.controls[newRollout.activeControl].orient as string) of
						(
							"horizontal" : 1
							"vertical" : 2
							default: 0
						)
					)
					if newRollout.controls[newRollout.activeControl].controller != undefined do edt_controller.text = newRollout.controls[newRollout.activeControl].controller
				)
				on spn_from changed val do 
				(
					if newRollout.controls[newRollout.activeControl].range == undefined do newRollout.controls[newRollout.activeControl].range = [0,100,0]
					newRollout.controls[newRollout.activeControl].range[1] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_to changed val do
				(
					if newRollout.controls[newRollout.activeControl].range == undefined do newRollout.controls[newRollout.activeControl].range = [0,100,0]
					newRollout.controls[newRollout.activeControl].range[2] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_value changed val do
				(
					if newRollout.controls[newRollout.activeControl].range == undefined do newRollout.controls[newRollout.activeControl].range = [0,100,0]
					newRollout.controls[newRollout.activeControl].range[3] = val
					RL_RolloutBuilder.addCustomUI()
				)
				on rdo_type changed state do
				(
					newRollout.controls[newRollout.activeControl].type = case state of
					(
						1 : #float
						2 : #integer
						default: #float
					)
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_ticks changed val do
				(
					newRollout.controls[newRollout.activeControl].ticks = val
					RL_RolloutBuilder.addCustomUI()
				)
				on rdo_orient changed state do
				(
					newRollout.controls[newRollout.activeControl].orient = case state of
					(
						1 : #horizontal
						2 : #vertical
						default: #horizontal
					)
					RL_RolloutBuilder.addCustomUI()
				)
				on edt_controller entered text do
				(
					text = checkString text
					edt_controller.text = text
					newRollout.controls[newRollout.activeControl].controller = text
					if text == "" do newRollout.controls[newRollout.activeControl].controller = undefined
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_MapButton "Map Button"
			(
				--todo
				--map
				edittext edt_map "Map"
				--images
				--border
				checkbox chk_border "Border" checked:true
				
				on RL_MapButton open do
				(
					if newRollout.controls[newRollout.activeControl].map != undefined do edt_map.text = newRollout.controls[newRollout.activeControl].map
					if newRollout.controls[newRollout.activeControl].border != undefined do chk_border.checked = newRollout.controls[newRollout.activeControl].border
				)
				on edt_map entered text do
				(
					newRollout.controls[newRollout.activeControl].map = text
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_border changed state do
				(
					newRollout.controls[newRollout.activeControl].border = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_MaterialButton "Material Button"
			(
				--material
				edittext edt_material "Material"
				--images
				--todo
				--border
				checkbox chk_border "Border" checked:true
				
				on RL_MaterialBUtton open do
				(
					if newRollout.controls[newRollout.activeControl].material != undefined do edt_material.text = newRollout.controls[newRollout.activeControl].material
					if newRollout.controls[newRollout.activeControl].border != undefined do chk_border.checked = newRollout.controls[newRollout.activeControl].border
				)
				on edt_material entered text do
				(
					newRollout.controls[newRollout.activeControl].material = text
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_border changed state do
				(
					newRollout.controls[newRollout.activeControl].border = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_Progressbar "Progress Bar" --todo
			(
				spinner spn_value "Value"
				colorpicker cpl_color "Color"
				radiobuttons rdo_orient "orient" labels:#("#horizontal","#vertical")
				
				on RL_Progressbar open do
				(
					if newRollout.controls[newRollout.activeControl].value != undefined do spn_value.value = newRollout.controls[newRollout.activeControl].value
					if newRollout.controls[newRollout.activeControl].color != undefined do cpl_color.color = newRollout.controls[newRollout.activeControl].color
					if newRollout.controls[newRollout.activeControl].orient != undefined do
					(
						rdo_orient.state = case (newRollout.controls[newRollout.activeControl].orient as string) of
						(
							"horizontal" : 1
							"vertical" : 2
						)
					)
				)
				on spn_value changed val do
				(
					newRollout.controls[newRollout.activeControl].value = val
					RL_RolloutBuilder.addCustomUI()
				)
				on cpl_color changed col do
				(
					newRollout.controls[newRollout.activeControl].color = col
					RL_RolloutBuilder.addCustomUI()
				)
				on rdo_orient changed state do
				(
					case state of
					(
						1: (
							newRollout.controls[newRollout.activeControl].orient = #horizontal
							swap newRollout.controls[newRollout.activeControl].Width newRollout.controls[newRollout.activeControl].Height
						)
						2: (
							newRollout.controls[newRollout.activeControl].orient = #vertical
							swap newRollout.controls[newRollout.activeControl].Width newRollout.controls[newRollout.activeControl].Height
						)
					)
					RL_RolloutBuilder.updateEditUI()
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_Label "Label"
			(
				checkbox chk_style_sunkenEdge "Sunken Edge" --todo
				
				on RL_label open do
				(
					if newRollout.controls[newRollout.activeControl].style_sunkenEdge != undefined do chk_style_sunkenEdge.checked = newRollout.controls[newRollout.activeControl].style_sunkenEdge
				)
				on chk_style_sunkenEdge changed state do
				(
					newRollout.controls[newRollout.activeControl].style_sunkenEdge = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_Timer "Timer"
			(
				spinner spn_interval "Interval"
				checkbox chk_active "Active"
				
				on RL_Timer open do
				(
					if newRollout.controls[newRollout.activeControl].interval != undefined do spn_interval.value = newRollout.controls[newRollout.activeControl].interval
					if newRollout.controls[newRollout.activeControl].active != undefined do chk_active.checked = newRollout.controls[newRollout.activeControl].active
				)
				on spn_interval changed val do
				(
					newRollout.controls[newRollout.activeControl].interval = val
				)
				on chk_active changed state do
				(
					newRollout.controls[newRollout.activeControl].active = state
				)
			)
			Rollout RL_bitmap "Bitmap"
			(
				edittext edt_bitmap "Bitmap"
				edittext edt_filename "Filename"
				--todo
				--pickbutton for bitmap path
				
				on RL_bitmap open do
				(
					if newRollout.controls[newRollout.activeControl].bitmap != undefined do edt_bitmap.text = newRollout.controls[newRollout.activeControl].bitmap
					if newRollout.controls[newRollout.activeControl].filename != undefined do edt_filename.text = newRollout.controls[newRollout.activeControl].filename
				)
				on edt_bitmap entered text do
				(
					newRollout.controls[newRollout.activeControl].bitmap = text
					if text == "" do newRollout.controls[newRollout.activeControl].bitmap = undefined
					RL_RolloutBuilder.addCustomUI()
				)
				on edt_filename entered text do
				(
					newRollout.controls[newRollout.activeControl].filename = text
					if text == "" do newRollout.controls[newRollout.activeControl].filename = undefined
					RL_RolloutBuilder.addCustomUI()
				)
				
			)
			Rollout RL_button "Button"
			(
				checkbox chk_border "Border" checked:true
				listbox lbx_images "Images" height:4
				--todo
				--button btn_addPressedEventHandler "Add Pressed Event Handler"
				--dropdownlist ddl_
				
				on RL_button open do
				(
					if newRollout.controls[newRollout.activeControl].border != undefined do chk_border.checked = newRollout.controls[newRollout.activeControl].border
				)
				
				on chk_border changed state do
				(
					newRollout.controls[newRollout.activeControl].border = state
					RL_RolloutBuilder.addCustomUI()
				)
				
				on btn_addPressedEventHandler pressed do
				(
					ev = eventHandler event:#pressed args:#() code:"(\n\t--buttonpressed\n)"
					append newRollout.controls[newRollout.activeControl].eventHandlers ev
				)
			)
			Rollout RL_imgTag "ImgTag"
			(
				edittext edt_bitmap "Bitmap"
				--todo
				--opacity
				spinner spn_opacity "Opacity"
				--style
				--edittext edt_style "Style"
				radiobuttons rdo_style "Style" labels:#("#bmp_stretch", "#bmp_tile", "#bmp_center")
				--transparent
				colorpicker cpl_transparent "Transparent" color:(color 0 0 0)
				--todo
				on RL_imgTag open do
				(
					if newRollout.controls[newRollout.activeControl].bitmap != undefined do edt_bitmap.text = newRollout.controls[newRollout.activeControl].bitmap
					if newRollout.controls[newRollout.activeControl].opacity != undefined do spn_opacity.value = newRollout.controls[newRollout.activeControl].opacity
					if newRollout.controls[newRollout.activeControl].style != undefined do rdo.text = newRollout.controls[newRollout.activeControl].style
					if newRollout.controls[newRollout.activeControl].transparent != undefined do cpl_transparent.color = newRollout.controls[newRollout.activeControl].transparent
				)
				on edt_bitmap entered text do
				(
					newRollout.controls[newRollout.activeControl].bitmap = text
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_opacity changed val do
				(
					newRollout.controls[newRollout.activeControl].opacity = val
					RL_RolloutBuilder.addCustomUI()
				)
				on edt_style entered text do
				(
					newRollout.controls[newRollout.activeControl].style = text
					RL_RolloutBuilder.addCustomUI()
				)
				on cpl_transparent changed col do
				(
					newRollout.controls[newRollout.activeControl].transparent = col
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_checkbox "Checkbox"
			(
				checkbox chk_checked "Checkbed" --offset:[20,0]
				checkbox chk_useTriState "Use TriState" across:2
				spinner spn_triState  "TriState" range:[0,2,0] type:#integer
				
				on RL_checkbox open do
				(
					if newRollout.controls[newRollout.activeControl].checked != undefined do chk_checked.checked = newRollout.controls[newRollout.activeControl].checked
					if newRollout.controls[newRollout.activeControl].useTriState != undefined do chk_useTristate.checked = newRollout.controls[newRollout.activeControl].useTristate
					if newRollout.controls[newRollout.activeControl].tristate != undefined do spn_TriState.value = newRollout.controls[newRollout.activeControl].TriState
				)
				
				on chk_checked changed state do 
				(
					newRollout.controls[newRollout.activeControl].checked = state
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_useTriState changed state do
				(
					newRollout.controls[newRollout.activeControl].useTriState = state
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_triState changed val do 
				(
					newRollout.controls[newRollout.activeControl].triState = val
					RL_RolloutBuilder.addCustomUI()
				)
			)
			Rollout RL_colorpicker "Colorpicker"
			(
				colorpicker cpl_defaultColor "Color"  --offset:[20,0]
				checkbox chk_useFieldwidth "Use Field Width" across:2
				spinner spn_fieldWidth "" type:#integer range:[0,1e9,40] 
				checkbox chk_alpha "Alpha"
				checkbox chk_modal "Modal" --todo
				edittext edt_title "Title" labelOnTop:true
				
				on RL_colorpicker open do
				(
					if newRollout.controls[newRollout.activeControl].color != undefined do cpl_defaultColor.color = newRollout.controls[newRollout.activeControl].color
					if newRollout.controls[newRollout.activeControl].useFieldWidth != undefined do chk_useFieldWidth.checked = newRollout.controls[newRollout.activeControl].useFieldWidth
					if newRollout.controls[newRollout.activeControl].fieldWidth != undefined do spn_fieldWidth.value = newRollout.controls[newRollout.activeControl].fieldWidth
					if newRollout.controls[newRollout.activeControl].modal != undefined do chk_modal.checked = newRollout.controls[newRollout.activeControl].modal
					if newRollout.controls[newRollout.activeControl].alpha != undefined do chk_alpha.checked = newRollout.controls[newRollout.activeControl].alpha
					if newRollout.controls[newRollout.activeControl].title != undefined then edt_title.text = newRollout.controls[newRollout.activeControl].title else edt_title.text = "\"\""
				)
				
				on cpl_defaultcolor changed col do 
				(
					newRollout.controls[newRollout.activeControl].color = col
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_useFieldWidth changed state do
				(
					newRollout.controls[newRollout.activeControl].useFieldWidth = state
					if state then
					(
						newRollout.controls[newRollout.activeControl].fieldWidth = spn_fieldWidth.value
					)
					else
					(
						newRollout.controls[newRollout.activeControl].fieldWidth = undefined
					)
					RL_RolloutBuilder.addCustomUI()
				)
				on spn_fieldWidth changed val do
				(
					newRollout.controls[newRollout.activeControl].fieldWidth = val
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_modal changed state do
				(
					newRollout.controls[newRollout.activeControl].modal = state
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_alpha changed state do
				(
					newRollout.controls[newRollout.activeControl].alpha = state
					RL_RolloutBuilder.addCustomUI()
				)
				on edt_title entered text do
				(
					newRollout.controls[newRollout.activeControl].title = text
					if text == "" do newRollout.controls[newRollout.activeControl].title = undefined
					RL_RolloutBuilder.addCustomUI()
				)
				
			)
			Rollout RL_checkbutton "CheckButton"
			(
				colorpicker cpl_highlightColor "Highlight Color"
				checkbox chk_checked  "Checked"
				--todo
				--images
				on RL_Checkbutton open do
				(
					if newRollout.controls[newRollout.activeControl].highlightColor != undefined do cpl_highlightColor.color = newRollout.controls[newRollout.activeControl].highlightColor
					if newRollout.controls[newRollout.activeControl].checked != undefined do chk_checked.checked = newRollout.controls[newRollout.activeControl].checked
				)
				on cpl_highlightColor changed col do
				(
					newRollout.controls[newRollout.activeControl].highlightcolor = col
					RL_RolloutBuilder.addCustomUI()
				)
				on chk_checked changed state do
				(
					newRollout.controls[newRollout.activeControl].checked = state
					RL_RolloutBuilder.addCustomUI()
				)
			)
	--)


	try(destroydialog RL_RolloutBuilder)catch()
	rollout RL_RolloutBuilder "Interactive Rollout Builder" width:660
	(
		
		
		Rollout RL_RolloutParams "Rollout Params"
		(
			edittext edt_rolloutName "Rollout Name" align:#right fieldwidth:300
			edittext edt_rolloutTitle "Rollout Title" align:#right fieldwidth:300
			checkbox chk_getLiveSize "Update with resizing of test UI" across:2
			spinner spn_rolloutWidth "Rollout Width" type:#integer range:[1,4000,600]
			checkbox chk_specifyHeight "Specify Height" across:2
			spinner spn_rolloutHeight "Rollout Height" type:#integer range:[1,4000,600]
			
			colorpicker cpl_bgcolor "Background Color" across:2 modal:true
			colorpicker cpl_fgcolor "Foreground Color" modal:true
			
			--button btn_resetColors "Reset Colors"
			
			checkbox chk_useBitmap "Use Bitmap" across:2
			button btn_clear "Clear" align:#right width:80 tooltip:"Clear the backgroudn image from the rollout"
			edittext edt_bitmap "Bitmap" readonly:true across:2 width:280
			button btn_bitmap "Browse:" align:#right width:80 tooltip:"Browse for an image to load into the background of your rollout"
			
			dropdownlist ddl_bmpstyle "Bitmap Style" items:#(#bmp_center, #bmp_tile, #bmp_stretch)
			multilistBox mlbx_style items:#(#style_border, #style_titlebar, #style_toolwindow, #style_resizing, #style_minimizebox, #style_maximizebox, #style_sysmenu, #style_sunkenedge)
			
			checkbox chk_lockWidth "Lock Width" across:2
			checkbox chk_lockHeight "Lock Height"
			checkbox chk_enableEscape "Enable Escape" across:2
			checkbox chk_modal "Modal (not during editing)"
			--menu = undefined,
			
			--dropdownlist ddl_eventHandlers "Rollout Event Handlers:" items:#("open","close","resized")
			--button btn_addRolloutEventHandler "Add Rollout Event Handler" enabled:false width:370 tooltip:"Not currently functional"
			
			fn updateRolloutParams =
			(
				edt_rolloutName.text = newRollout.rolloutName
				edt_rolloutTitle.text = newRollout.rolloutTitle
				spn_rolloutHeight.value = newRollout.rolloutHeight
				spn_rolloutWidth.value = newRollout.rolloutWidth
				chk_specifyHeight.checked = newRollout.useHeight = spn_rolloutHeight.enabled
				chk_getLiveSize.checked = newRollout.getLiveSize
				
				if newRollout.bgcolor != undefined then cpl_bgcolor.color = newRollout.bgcolor else cpl_bgcolor.color = ((colorman.getcolor #background) * 0.45454545454 * 255)
				if newRollout.fgcolor != undefined then cpl_fgcolor.color = newRollout.fgcolor else cpl_fgcolor.color = (color 0 0 0)
				chk_useBitmap.checked = newRollout.useBitmap
				if newRollout.bitmap != undefined then edt_bitmap.text = newRollout.bitmap.filename else edt_bitmap.text = ""
				if newRollout.bmpStyle != undefined do ddl_bmpstyle.selection = finditem ddl_bmpstyle.items newRollout.bmpStyle
				
				
				--There is a strange bug in maxscript not evaluating the multilistbox items correctly....
				a = #(#style_border, #style_titlebar, #style_toolwindow, #style_resizing, #style_minimizebox, #style_maximizebox, #style_sysmenu, #style_sunkenedge)
				b = #{}
				for i = 1 to 8 do 
				(
					h = (finditem a newRollout.style[i])
					if h != 0 do
						b[h] = true
				)
				--only way I could find to handle the bug...
				try(mlbx_style.selection = b)catch()
				
				
				
				chk_lockWidth.checked = newRollout.lockWidth
				chk_lockHeight.checked = newRollout.lockHeight
				chk_enableEscape.checked = newRollout.doescapeEnable
				chk_modal.checked = newRollout.modal
			)
			
			on btn_bitmap pressed do
			(
				theFile = selectBitMap title:"Rolllout Background"
				if theFile != undefined do
				(
					newRollout.bitmap = theFile
					edt_bitmap.text = thefile.filename
					RL_RolloutBuilder.addCustomUI()
				)
			)
			on btn_clear pressed do
			(
				newRollout.bitmap = undefined
				edt_bitmap.text = ""
				RL_RolloutBuilder.addCustomUI()
			)
			on RL_RolloutParams open do
			(
				updateRolloutParams()
			)
			
			on edt_rolloutName entered text do
			(
				newRollout.rolloutName = text
				RL_RolloutBuilder.addCustomUI()
			)
			on edt_rolloutTitle entered text do
			(
				newRollout.rolloutTitle = text
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_rolloutWidth changed val do
			(
				newRollout.rolloutwidth = val
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_rolloutheight changed val do
			(
				newRollout.rolloutHeight = val
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_specifyHeight changed state do
			(
				newRollout.useHeight = spn_rolloutHeight.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_getLiveSize changed state do
			(
				newRollout.getLiveSize = state
			)
			on cpl_bgcolor changed col do
			(
				newRollout.bgcolor = col
				RL_RolloutBuilder.addCustomUI()
			)
			on cpl_fgcolor changed col do
			(
				newRollout.fgcolor = col
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_useBitmap changed state do
			(
				newRollout.useBitmap = state
				RL_RolloutBuilder.addCustomUI()
			)
			
			on chk_lockWidth changed state do 
			(
				newRollout.lockWidth = state
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_lockHeight changed state do 
			(
				newRollout.lockHeight = state
				RL_RolloutBuilder.addCustomUI()
			)
			
			on chk_enableEscape changed state do 
			(
				newRollout.doEscapeEnable = state
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_modal changed state do 
			(
				newRollout.modal = state
				
			)
			on ddl_bmpStyle selected sel do
			(
				newRollout.bmpStyle = ddl_bmpStyle.items[sel]
				RL_RolloutBuilder.addCustomUI()
			)
			on mlbx_style selected sel do
			(
				newRollout.style = for o in mlbx_style.selection collect mlbx_style.items[o]
				RL_RolloutBuilder.addCustomUI()
			)
			
		)
		
		Rollout RL_commonParams "Common UI Params"
		(
			label lbl_prop "Control Name" across:2 align:#left
			edittext edt_ControlName "" --width:145
			
			label lbl_a "UI Item Name" across:2 align:#left 
			edittext edt_UIname "" --width:145
			
			
			--colorpicker cpl_defaultColor "Default Color" offset:[20,0]
			--checkbox chk_checked "Default Checkbox" offset:[20,0]
			
			checkbox chk_enabled "Enabled" checked:true
			checkbox chk_useVisible "Visibility" across:2
			checkbox chk_visible "True" offset:[45,0]
			
			checkbox chk_across "Across" across:2 align:#left
			spinner spn_across "" range:[1,100,1] type:#integer fieldWidth:35.0
			checkbox chk_customWidth "Custom Width" across:2
			spinner spn_width "" type:#integer range:[0,1e9,100] fieldWidth:35.0
			checkbox chk_usePercentageWidth "% Width" across:2
			spinner spn_percentageWidth  range:[1,100,25] type:#float
			button btn_full "Full" width:50 across:3
			button btn_half "Half"  width:50
			button btn_auto "Auto"  width:50 enabled:false
			
			checkbox chk_customheight "Custom Height" across:2
			spinner spn_height "" type:#integer range:[0,1e9,100]
			checkbox chk_offset "Offset" across:3
			spinner spn_offsetX "X" type:#integer range:[-1e9,1e9,0] fieldWidth:35.0
			spinner spn_offsetY "Y" type:#integer range:[-1e9,1e9,0] fieldWidth:35.0
			checkbox chk_Pos "Pos" across:3
			spinner spn_PosX "X" type:#integer range:[-1e9,1e9,0] fieldWidth:35.0
			spinner spn_PosY "Y" type:#integer range:[-1e9,1e9,0] fieldWidth:35.0
			checkbox chk_align "Align" across:1 align:#left
			radiobuttons rdo_align "" labels:#("Left","Center","Right") columns:3 state:(
				Case newRollout.controls[newRollout.activeControl].align as string of 
				(
					"left" : 1
					"center" : 2
					"right" : 3
				)
			)
			
			edittext edt_tooltip "Tooltip:" align:#right labelonTop:true
			edittext edt_comment "Comment:"  align:#right labelonTop:true
			
			
			
			on edt_ControlName entered text do 
			(
				tokens = (filterstring text " :()[],./\\?!\"'")
				filteredstring = ""
				for o in tokens do append filteredString o
				
				edt_controlName.text = filteredString
				
				if filteredString != newRollout.controls[newRollout.activeControl].ControlName do
				(
					conflicts = (for o in newRollout.controls where o.ControlName == filteredstring collect o).count
					if conflicts == 0 then
					(
						newRollout.controls[newRollout.activeControl].ControlName = filteredstring 
						RL_RolloutBuilder.updateListBox()
						RL_RolloutBuilder.addCustomUI()
					)
					else
					(
						MessageBox "Control Name must be unique"
						edt_controlName.text = newRollout.controls[newRollout.activeControl].controlName
					)
				)
			)
			on edt_UIname entered text do
			(
				newRollout.controls[newRollout.activeControl].label = text
				RL_RolloutBuilder.updateListBox()
				RL_RolloutBuilder.addCustomUI()
			)
			
			on chk_enabled changed state do
			(
				newRollout.controls[newRollout.activeControl].enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_useVisible changed state do
			(
				newRollout.controls[newRollout.activeControl].useVisible = chk_visible.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_visible changed state do
			(
				newRollout.controls[newRollout.activeControl].visible = state
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_across changed state do 
			(
				newRollout.controls[newRollout.activeControl].useAcross = spn_across.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_across changed val do 
			(
				newRollout.controls[newRollout.activeControl].across = val
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_customWidth changed state do 
			(
				newRollout.controls[newRollout.activeControl].useWidth = spn_width.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_usePercentageWidth changed state do
			(
				newRollout.controls[newRollout.activeControl].usePercentageWidth = spn_percentageWidth.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_percentageWidth changed val do
			(
				newRollout.controls[newRollout.activeControl].percentageWidth = val
				RL_RolloutBuilder.addCustomUI()
			)
			on btn_full pressed do 
			(
				newRollout.controls[newRollout.activeControl].Width = spn_width.value = newRollout.rolloutWidth - 10
				RL_RolloutBuilder.addCustomUI()
			)
			on btn_half pressed do 
			(
				newRollout.controls[newRollout.activeControl].Width = spn_width.value = ((newRollout.rolloutWidth / 2) - 13)
				RL_RolloutBuilder.addCustomUI()
			)
			
			on spn_width changed val do 
			(
				newRollout.controls[newRollout.activeControl].width = val
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_customheight changed state do 
			(
				newRollout.controls[newRollout.activeControl].useHeight = spn_height.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_height changed val do 
			(
				newRollout.controls[newRollout.activeControl].height = val
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_offset changed state do 
			(
				newRollout.controls[newRollout.activeControl].useOffset = spn_offsetX.enabled = spn_offsetY.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_offsetX changed val do 
			(
				newRollout.controls[newRollout.activeControl].offset[1] = val
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_offsetY changed val do 
			(
				newRollout.controls[newRollout.activeControl].offset[2] = val
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_Pos changed state do 
			(
				newRollout.controls[newRollout.activeControl].usePos = spn_PosX.enabled = spn_PosY.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_PosX changed val do 
			(
				newRollout.controls[newRollout.activeControl].pos[1] = val
				RL_RolloutBuilder.addCustomUI()
			)
			on spn_PosY changed val do 
			(
				newRollout.controls[newRollout.activeControl].pos[2] = val
				RL_RolloutBuilder.addCustomUI()
			)
			on chk_align changed state do 
			(
				newRollout.controls[newRollout.activeControl].useAlign = rdo_align.enabled = state
				RL_RolloutBuilder.addCustomUI()
			)
			on rdo_align changed state do 
			(
				newRollout.controls[newRollout.activeControl].align = case state of
				(
					1: "left"
					2: "center"
					3: "right"
				)
				RL_RolloutBuilder.addCustomUI()
			)
			on edt_tooltip entered text do
			(
				text = checkString text
				newRollout.controls[newRollout.activeControl].tooltip = edt_tooltip.text = text
				RL_RolloutBuilder.addCustomUI()
			)
			on edt_comment entered text do
			(
				newRollout.controls[newRollout.activeControl].comment = text
			)
		)

		Rollout RL_LoadMaxscript "Load Maxscript" width:400
		(
			edittext edt_code "Code" height:100
			button btn_loadMaxscript "Load Maxscript - Incomplete Feature, may not work!" width:300 align:#right
			
			local isGroupOpen = false
			
			fn filterRollout theLine =
			(
				
				--print "we found our rollout header"
				sss = stringstream theLine
				(readToken sss)
				newRollout.rolloutName = (readToken sss)
				newRollout.rolloutTitle = (readToken sss)
				while (peekToken sss) != undefined do print (readToken sss)
			)

			fn filterControl type theLine =
			(
				newControl = UIcontrolstruct()
				--print ("we found a " + type)
				--newControl.controltype = type
				result = Case type of
				(
					"groupstart" : (
						isGroupOpen = true
						newControl.controlType = "groupstart"
						newControl.controlName = ("grp_" + ((for o in newRollout.controls where o.controltype == "groupstart" collect o).count + 1) as string)
						sss = stringstream theLine
						readToken sss
						newControl.label = readToken sss
						true
					)
					"groupend" : (
						false
					)
					"startBracket" : (
						false
					)
					"endBracket" : (
						if isGroupOpen then
						(
							isGroupOpen = false
							newControl.controlType = "groupend"
							newControl.controlName = ("grp_" + ((for o in newRollout.controls where o.controltype == "groupstart" collect o).count) as string)
							true
						)
						else
						false
						
					)
					default : (
						sss = stringstream theLine
						newControl.controlType = (readToken sss)
						newControl.controlName = (readToken sss)
						
						--todo how to find out if this control has a label or not
						--button btn_a "button"
						--checkbox chk_a checked:true
						--edittext edt_A "test" text:"test"
						--dropdownlist ddl_a "rad" items:#("1","2")
						--end todo
						
						
						--print "theLine"
						--print theLine
						--print ("*" + newControl.controlType + " " + newControl.controlName + " \"*")
						
						if matchpattern theLine pattern:("*" + newControl.controlType + " " + newControl.controlName + " \"*") do
						(
							newControl.label = (readToken sss)
						)
						
						while (peekToken sss) != undefined do 
						(
							
							arg = (readToken sss)
							--print arg
							if matchpattern arg pattern:"*:*" then
							(
								tokens = filterstring arg ":"
								--print (tokens[1] + " has a value of: " + tokens[2])
								
								--getpropnames newControl
								--index = finditem (for o in (getpropnames newControl) collect o as string) tokens[1]
								
								indexAr = (for n in (for o in (getpropnames newControl) collect o as string) where matchpattern n pattern:tokens[1] collect n)
								if indexAr.count != 0 do
								(	
									index = indexAr[1]
									
									setproperty newControl index (execute(tokens[2]))
									case index of
									(
										"width" : newControl.useWidth = true
										"height" : newControl.useHeight = true
										"offset" : newControl.useOffset = true
										"align" : newControl.useAlign = true
										"across" : newControl.useAcross = true
										"pos" : newControl.usePos = true
										"fieldwidth" : newControl.useFieldWidth = true
									)
								)
							)
						)
						true
					)
				)
				--get type
				--get name
				--get UI name
				--check for additional parameters
				--width,height,range,across,align,offset,text,bitmap,images, pos,items,labels, 
				--catch comments at the end of the line
				if result == true do append newRollout.controls newControl
			)

			fn filterHandler theLine =
			(
				--print "we found a change handler"
			)

			fn filterComment =
			(
				--print "we found a comment"
			)
			fn filterFunction =
			(
				--print "we found a function"
			)
			fn filterLocal =
			(
				--print "we found a local"
			)
			fn filterDotNetControl theLine =
			(
				newControl = dotNetControlStruct()
				sss = stringstream theLine
				newControl.dotnetType = (readToken sss)
				newControl.controlName = (readToken sss)
				newControl.dotnetPath = (readToken sss)
				
				while (peekToken sss) != undefined do 
				(
					arg = (readToken sss)
					--print arg
				)
				append newRollout.controls newControl
			)
			
			
			on RL_LoadMaxscript open do
			(
				edt_code.text = ss
				
				
			)
			
			on btn_loadMaxscript pressed do
			(
				newRollout = rolloutConstructor()
				
				local ss = edt_code.text as stringstream 
				seek ss 0

				while not eof ss do
				(
					theLine = readline ss

					--remove tabs
					theLine = trimLeft theLine

					Case of
					(
						(matchpattern theLine pattern:"--*") : filterComment()
						(matchpattern theLine pattern:"Rollout*") : filterRollout theLine
						(matchpattern theLine pattern: "on *") : filterHandler "handler"
						(matchpattern theLine pattern: "fn *") : filterFunction()
						(matchpattern theLine pattern: "local *") : filterLocal()
						
						(matchpattern theLine pattern:"label*") : filterControl "label" theLine
						(matchpattern theLine pattern:"spinner*") : filterControl "spinner" theLine
						(matchpattern theLine pattern:"colorpicker*") : filterControl "colorpicker" theLine
						(matchpattern theLine pattern: "checkbox*") : filterControl "checkbox" theLine
						(matchpattern theLine pattern:"button*") : filterControl "button" theLine
						(matchpattern theLine pattern:"checkbutton*") : filterControl "checkbutton" theLine
						(matchpattern theLine pattern:"materialbutton*") : filterControl "materialbutton" theLine
						(matchpattern theLine pattern:"mapbutton*") : filterControl "mapbutton" theLine
						(matchpattern theLine pattern: "dropdownlist*") : filterControl "dropdownlist" theLine
						(matchpattern theLine pattern:"listbox*") : filterControl "listbox" theLine
						(matchpattern theLine pattern:"multilistbox*") : filterControl "multilistbox" theLine
						(matchpattern theLine pattern:"combobox*") : filterControl "combobox" theLine
						(matchpattern theLine pattern:"angle*") : filterControl "angle" theLine
						(matchpattern theLine pattern:"slider*") : filterControl "slider" theLine
						(matchpattern theLine pattern:"edittext*") : filterControl "edittext" theLine
						(matchpattern theLine pattern:"groupbox*") : filterControl "groupbox" theLine
						(matchpattern theLine pattern:"bitmap*") : filterControl "bitmap" theLine --could this cause problems?
						(matchpattern theLine pattern:"radiobuttons*") : filterControl "radiobuttons" theLine
						(matchpattern theLine pattern:"imgTag*") : filterControl "imgTag" theLine
						(matchpattern theLine pattern:"subRollout*") : filterControl "subRollout" theLine
						
						(matchpattern theLine pattern:"group *") : filterControl "groupstart" theLine -- needs special protection
						(matchpattern theLine pattern:")*") : filterControl "endBracket" theLine
						
						(matchpattern theLine pattern:"dotNetControl *") : filterDotNetControl theLine
						
						
						default : (--catch anything else and add it as an item in the index so we can add it back
						)
					)
				)
				
				st = newRollout.controls
				
				RL_RolloutBuilder.updateListBox()
				RL_RolloutBuilder.updateEditUI()
				RL_RolloutParams.updateRolloutParams()
				RL_RolloutBuilder.addCustomUI()
				RL_RolloutBuilder.addControlUI()
			)
		)

		Rollout RL_RolloutCreator "Rollout Creator" width:410
		(
			listbox lbx_UIitems "Controls"  width:363 height:25 items:#()
			button btn_moveUp "Move Up"  across:4 offset:[-7,0] width:78 tooltip:"Move the selected control up in order of creation"
			button btn_moveDown "Move Down"  offset:[-5,0] width:78 tooltip:"Move the selected control down in order of creation"
			button btn_removeUiControl "Remove"  offset:[2,0] width:78 tooltip:"Remove the selected control from the rollout"
			button btn_Swap "Swap"  offset:[6,0] width:78 tooltip:"Swap Controls" enabled:false 
			
			button btn_Duplicate "Duplicate"  offset:[-7,0] width:78 across:4 tooltip:"Duplicate the Control with all custom properties"
			button btn_newUi "New UI" width:78 across:3 offset:[-5,0] tooltip:"Remove all controls and start afresh."
			button btn_update "Update UI" width:78 offset:[2,0]  tooltip:"Update the UI"
			button btn_buildUI "Build UI Code" width:78 offset:[6,0] tooltip:"Build the maxscript Code for this rollout so you can start making your own tool"
			
			button btn_LoadUI "Load UI" across:2 width:174 offset:[-6,0] tooltip:"Load a UI created with this tool."
			button btn_saveUI "Save UI" width:174 offset:[3,0] tooltip:"Save a UI from this tool"
			
			group "New Controls" 
			(
				button btn_addLabel "lbl"  across:9 width:29 height:30 tooltip:"Add Label"
				button btn_addButton "btn"  width:29 height:30 tooltip:"Add Button"
				button btn_addSpinner "spn"  width:29 height:30 tooltip:"Add Spinner"
				button btn_addCheckbox "chk"  width:29 height:30 tooltip:"Add CheckBox"
				button btn_addPickButton "pbt"  width:29 height:30 tooltip:"Add PickButton"
				button btn_addMapButton "map"  width:29 height:30 tooltip:"Add Map Button"
				button btn_addMaterialButton "mat"  width:29 height:30 tooltip:"Add Material Button"
				button btn_addListbox "lbx"  width:29 height:30 tooltip:"Add Listbox"
				button btn_addComboBox "cbo"  width:29 height:30 tooltip:"Add Combo Box"
				
				button btn_addDropdownList "ddl"   across:9 width:29 height:30 tooltip:"Add DropdownList"
				button btn_addMultiListBox "mlb"  width:29 height:30 tooltip:"Add MultiListBox"
				button btn_addhyperlink "hyp"  width:29 height:30 tooltip:"Add hyperlink"
				button btn_addProgressBar "pgB"  width:29 height:30 tooltip:"Add ProgressBar"
				
				button btn_addEdittext "edt" width:29 height:30 tooltip:"Add Edittext"
				button btn_addCheckButton "cbt"  width:29 height:30 tooltip:"Add Checkbutton"
				button btn_addSlider "sld"  width:29 height:30 tooltip:"Add Slider"
				button btn_addAngle "ang"  width:29 height:30 tooltip:"Add Angle"
				button btn_addBitmap "bmp"  width:29 height:30 tooltip:"Add Bitmap"
				
				button btn_addImgTag "imt"  across:9  width:29 height:30 tooltip:"Add ImgTag"
				
				button btn_addGroupBox "gbx"  width:29 height:30 tooltip:"Add Groupbox"
				button btn_addRadiobuttons "rdo"  width:29 height:30 tooltip:"Add Radiobuttons"
				button btn_addSubRollout "sub"  width:29 height:30 tooltip:"Add SubRollout"
				button btn_addColorpicker "cpl"  width:29 height:30 tooltip:"Add ColorPicker"
				button btn_addCurveControl "cc"  width:29 height:30 tooltip:"Add CurveControl"
				
				button btn_addA ""  width:29 height:30 tooltip:"" enabled:false
				button btn_addB ""  width:29 height:30 tooltip:"" enabled:false
				button btn_addGroup "grp"  width:29 height:30 tooltip:"Add Group"
			)
			
			label lbl_dw "v1.4 - Written by Dave Wortley - 2017"
			hyperlink lbl_blog "Visit My Blog: http://davewortley.wordpress.com" address:"http://davewortley.wordpress.com" align:#center
			hyperlink lbl_fb "or on Facebook: http://www.facebook.com/MaxMadeEasy" address:"http://www.facebook.com/MaxMadeEasy" align:#center
			
			
			--type, propName, UIName, value, posX, posY, width, height, offsetX, offsetY, align, across, rangeFrom, rangeTo
			--global st = #()
			
			--local st = ar_nodes[::HydragenRollout.s.activenode]
			local align = #("left","center","right")
			
			fn filterChars text =
			(
				chars = "\"#@\\"
			)
			
			
			
			--local alphabet = #("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
			
			
			
			on btn_LoadUI pressed do
			(
				theFIle = getOpenFilename types:"Data(*.dat)|*.dat|All|*.*|"
				
				if theFile != undefined do
				(
					
					f = openFile theFile
					newRollout = readValue f ignoreStringEscapes:false
					close f
					
					if newRollout.controls.count != 0 then
						newRollout.activeControl = 1
					else
						newRollout.activeControl = 0
					
					--literalise our data again
					for o in newRollout.controls where o.tooltip != undefined do o.tooltip = checkString o.tooltip
					for o in newRollout.controls where o.text != undefined do o.text = checkString o.text
					for o in newRollout.controls where o.address != undefined do o.address = checkString o.address
					for o in newRollout.controls where o.items != undefined do (for i = 1 to o.items.count do o.items[i] = checkString o.items[i])
					
					RL_RolloutBuilder.updateListBox()
					RL_RolloutBuilder.updateEditUI()
					RL_RolloutParams.updateRolloutParams()
					RL_RolloutBuilder.addCustomUI()
				)
			)
			
			on btn_saveUI pressed do
			(
				with printallelements on
				(
					newFile = getSaveFilename types:"Data(*.dat)|*.dat|All|*.*|"
					
					if newFile != undefined do
					(
						--f = stringstream ""
						--format "%" (newRollout as string) to:f
						f = createFile newFile 
						--f = openFile newFile mode:"r+"
						format "%" (newRollout as string) to:f
						close f
						--flush f
					)
				)
			)
			
			
			on RL_RolloutCreator open do
			(
				--local st = ar_nodes[::HydragenRollout.s.activenode]
				
				
				--edt_ControlName.text = "Var" + alphabet[st.count + 1]
				
		-- 					if st.UI.count != 0 do
		-- 					(
		-- 						hydraGenRollout.subright.RL_CustomNode.rolledup = true
		-- 						hydraGenRollout.subright.RL_CustomNodeScript.rolledup = true
		-- 					)
				
				--st = newRollout.controls
				
				if newRollout.controls.count != 0 then
					newRollout.activeControl = 1
				else
					newRollout.activeControl = 0
				
				RL_RolloutBuilder.updateListBox()
				RL_RolloutBuilder.updateEditUI()
				RL_RolloutParams.updateRolloutParams()
				RL_RolloutBuilder.addCustomUI()
				
				
				--addControlUI()
			)
			on RL_RolloutCreator close do
			(
				try(destroyDialog lastRollout)catch()
			)
				
			on btn_newUI pressed do
			(
				if queryBox "This will remove all UI Controls...\n\nContinue?..." title:"Rollout Builder" do
				(
					newRollout = rolloutConstructor rolloutName:"RL_Rollout" rolloutTitle:"Test Rollout" Rolloutwidth:330
					
					--st = newRollout.controls
					newRollout.activeControl = 0
					RL_RolloutCreator.lbx_UIItems.selection = 0
					
					RL_RolloutParams.updateRolloutParams()
					RL_RolloutBuilder.updateListBox()
					RL_RolloutBuilder.updateEditUI()
					RL_RolloutBuilder.addCustomUI()
					RL_RolloutBuilder.addControlUI()
					
					
					
				)
			)
			fn addUIControl type =
			(
				local UIcontrol = UIControlStruct controlType:type
				
				Case type of
				(
					"label" : (
						UIcontrol.label = "Label"
						UIcontrol.controlName = "lbl_"
					)
					"spinner" : (
						UIcontrol.controlType = "spinner"
						UIcontrol.type = "float"
						UIcontrol.label = "Spinner"
						UIcontrol.controlName = "spn_"
						UIcontrol.range = [0,100,1]
					)
					"integer" : (
						UIcontrol.controlType = "spinner"
						UIcontrol.type = "integer"
						UIcontrol.label = "Spinner"
						UIcontrol.controlName = "spn_"
						UIcontrol.range = [0,100,1]
					)
					"float" : (
						UIcontrol.controlType ="spinner"
						UIcontrol.type = "float"
						UIcontrol.label = "Spinner"
						UIcontrol.controlName = "spn_"
						UIcontrol.range = [0,100,1]
					)
					"colorpicker" : (
						UIcontrol.label = "Color"
						UIcontrol.controlName = "cpl_"
						UIcontrol.color = color 0 0 0
						
					)
					"checkbox" : (
						UIcontrol.label = "Checkbox"
						UIcontrol.controlName = "chk_"
						UIcontrol.checked = true
					)
					"worldUnits" : (
						UIcontrol.controltype = "spinner"
						UIcontrol.type = "worldUnits"
						UIcontrol.label = "Spinner"
						UIcontrol.controlName = "spn_"
						UIcontrol.range = [0,100,1]
					)
					"button" : (
						UIcontrol.label = "Button"
						UIcontrol.controlName = "btn_"
						UIcontrol.images = #()
						UIcontrol.useWidth = true
						UIcontrol.width = 150
					)
					"checkbutton" : (
						UIcontrol.label = "Check Button" 
						UIcontrol.controlName = "chkbtn_"
						UIcontrol.images = #()
						UIcontrol.state = false
						UIcontrol.useWidth = true
						UIcontrol.width = 150
					)
					"pickbutton" : (
						UIcontrol.label = "Pick Button"
						UIcontrol.controlName = "pbtn_"
						UIcontrol.images = #()
						UIcontrol.useWidth = true
						UIcontrol.width = 150
					)
					"materialbutton" : (
						UIcontrol.label = "Material Button"
						UIcontrol.controlName = "matbtn_"
						UIcontrol.useWidth = true
						UIcontrol.width = 150
					)
					"mapbutton" : (
						UIcontrol.label = "Map Button"
						UIcontrol.controlName = "mapbtn_"
						UIcontrol.useWidth = true
						UIcontrol.width = 150
					)
					"dropdownlist" : (
						UIcontrol.label = "Drop Down List"
						UIcontrol.controlName = "ddl_"
						UIcontrol.items = #()
					)
					"listbox" : (
						UIcontrol.label = "Listbox"
						UIcontrol.controlName = "lbx_"
						UIcontrol.items = #()
					)
					"multilistbox" : (
						UIcontrol.label = "Multi Listbox"
						UIcontrol.controlName = "mlbx_"
						UIcontrol.items = #()
					)
					"combobox" : (
						UIcontrol.label = "Combobox"
						UIcontrol.controlName = "cbo_"
						UIcontrol.items = #()
					)
					"angle" : (
						UIcontrol.label = "Angle"
						UIcontrol.controlName = "ang_"
					)
					"slider" : (
						UIcontrol.label = "Slider"
						UIcontrol.controlName = "sld_"
						UIcontrol.value = 50
					)
					"edittext" : (
						UIcontrol.label = "Edittext"
						UIcontrol.controlName = "edt_"
						Uicontrol.text = "Text"
					)
					"groupbox" : (
						UIcontrol.label = "Group Box"
						UIcontrol.controlName = "grp_"
					)
					"bitmap" : (
						UIcontrol.label = "Bitmap"
						UIcontrol.controlName = "bmp_"
					)
					"imgTag" : (
						UIcontrol.label = "Image Tag"
						UIcontrol.controlName = "img_"
					)
					"radiobuttons" : (
						UIcontrol.label = "Radiobuttons"
						UIcontrol.controlName = "rdo_"
						Uicontrol.labels = #("a","b","c")
					)
					"groupstart" : 
					(
						UIcontrol.label = "group"
						UIcontrol.controlName = "grp_"
						
						grps = (for o in newRollout.controls where o.controlType == "groupstart" collect (filterstring o.controlName "_")[2] as integer)
						local newGrpName = ""
						if grps.count != 0 then
						(
							grps = sort(grps)
							--tokens = filterstring grps[grps.count] "_"
							newGrpName = UIcontrol.controlName + (grps[grps.count] + 1) as string
						)
						else
						(
							newGrpName = "grp_1"
						)

						UIcontrol.controlName = newGrpName
						--UIcontrol.controlName = ""
					)
					"groupend" :
					(
						--UIcontrol.controlName = "Var" + alphabet[st.count]
						UIcontrol.controlName = "grp_"
						
						grps = (for o in newRollout.controls where o.controlType == "groupend" collect (filterstring o.controlName "_")[2] as integer)
						local newGrpName = ""
						if grps.count != 0 then
						(
							grps = sort(grps)
							--tokens = filterstring grps[grps.count] "_"
							newGrpName = UIcontrol.controlName + (grps[grps.count] + 1) as string
						)
						else
						(
							newGrpName = "grp_1"
						)
						UIcontrol.controlName = newGrpName
					)
					"subRollout" : (
						UIControl.label = ""
						UIcontrol.controlName = "sub_"
					)
					"hyperlink" : (
						UIControl.label = ""
						UIcontrol.controlName = "hyp_"
						UIControl.address = @"http://www.google.com"
					)
					"curveControl" : (
						UIControl.label = ""
						UIcontrol.controlName = "cc_"
					)
					"progressBar" : (
						UIControl.label = ""
						UIControl.controlName = "prog_"
					)
				)	
				
				if type != "groupstart" and type != "groupend" then
				(
					--UIcontrol.controlName += (((for o in newRollout.controls where o.controlType == UIcontrol.controlType collect o).count + 1) as string)
					names = (for o in newRollout.controls where o.controlType == UIcontrol.controlType collect o.controlName)
					
					if finditem names (UIcontrol.controlName + "1") == 0 then
					(
						UIcontrol.controlName += "1"
						print "a"
					)
					else
					(
						local newName = ""
						
						names = (for o in names where matchpattern o pattern:(UIcontrol.controlName + "*") collect (filterstring o "_")[2] as integer)
						
						if names.count != 0 then
						(
							names = sort(names)
							--tokens = filterstring names[names.count] "_"
							newName = UIcontrol.controlName + ((names[names.count]) + 1) as string
						)
						else
						(
							newName = (UIcontrol.controlName += "1")
						)
						UIcontrol.controlName = newName
					)
					
					lbx_UIItems.selection = (newRollout.activeControl + 1)
					insertitem UIcontrol newRollout.controls (newRollout.activeControl + 1)
					--addCustomUI()
					newRollout.activeControl = (newRollout.activeControl + 1)
				
				)
				else
				(
					lbx_UIItems.selection = (newRollout.controls.count)
					insertitem UIcontrol newRollout.controls (newRollout.controls.count + 1)
					--addCustomUI()
					newRollout.activeControl = (newRollout.controls.count - 1)
				)
				
				--updateListBox()ms.count
				
			)
			fn addControl type =
			(
				addUIControl type
				RL_RolloutBuilder.updateListBox()
				--newRollout.activeControl = lbx_UIItems.items.count
				RL_RolloutBuilder.updateEditUI()
				RL_RolloutBuilder.addControlUI()
				RL_RolloutBuilder.addCustomUI()
				--lbx_UIItems.selection = newRollout.controls.count
			)
			
			on btn_addLabel pressed do
			(
				addControl "label"
			)
			on btn_addSpinner pressed do
			(
				addControl "spinner"
			)
			on btn_addFloat pressed do
			(
				addControl "float"
			)
			on btn_addWorldUnit pressed do
			(
				addControl "worldUnits"
			)
			on btn_addColorpicker pressed do
			(
				addControl "colorpicker"
			)
			on btn_addCheckbox pressed do
			(
				addControl "checkbox"
			)
			on btn_addgroup pressed do
			(
				addUIControl "groupstart"
				addControl "groupend"
			)
			
			on btn_addbutton pressed do
			(
				addControl "button"
			)
			on btn_addpickbutton pressed do
			(
				addControl "pickbutton"
			)
			on btn_addcheckbutton pressed do
			(
				addControl "checkbutton"
			)
			on btn_addmaterialbutton pressed do
			(
				addControl "materialbutton"
			)
			on btn_addmapbutton pressed do
			(
				addControl "mapbutton"
			)
			on btn_addDropdownlist pressed do
			(
				addControl "dropdownlist"
			)
			on btn_addListbox pressed do
			(
				addControl "listbox"
			)
			on btn_addMultiListbox pressed do
			(
				addControl "multilistbox"
			)
			on btn_addCombobox pressed do
			(
				addControl "combobox"
			)
			on btn_addAngle pressed do
			(
				addControl "angle"
			)
			on btn_addSlider pressed do
			(
				addControl "slider"
			)
			on btn_addEdittext pressed do
			(
				addControl "edittext"
			)
			on btn_addGroupBox pressed do
			(
				addControl "groupbox"
			)
			on btn_addBitmap pressed do
			(
				addControl "bitmap"
			)
			on btn_addimgTag pressed do
			(
				addControl "imgTag"
			)
			on btn_addradiobuttons pressed do
			(
				addControl "radiobuttons"
			)
			on btn_addsubRollout pressed do
			(
				addControl "subRollout"
			)
			on btn_addhyperlink pressed do
			(
				addControl "hyperlink"
			)
			on btn_addCurveControl pressed do
			(
				addControl "curveControl"
			)
			on btn_addProgressBar pressed do
			(
				addControl "progressBar"
			)
			
			fn checkControlNameIsUnique theName =
			(
				if (for o in newRollout.controls where o.controlName == theName collect o).count != 0 then
				(
					checkControlNameIsUnique (theName += "_copy")
				)
				else
				(
					theName
				)
				
			)
			
			on btn_duplicate pressed do
			(
				if newRollout.activeControl != 0 do
				(
					append newRollout.controls (copy newRollout.controls[newRollout.activeControl])
					newRollout.activeControl = newRollout.controls.count
					
					newName = newRollout.controls[newRollout.activeControl].controlName
					
					newName = checkControlNameIsUnique newName
					newRollout.controls[newRollout.activeControl].controlName = newName
					
					
					RL_RolloutBuilder.updateEditUI()
					RL_RolloutBuilder.addCustomUI()
				)
			)
			on btn_moveUp pressed do
			(
				
				
				if newRollout.activeControl > 1 do
				(
					--check that groupstart is above group end
					if not ((newRollout.controls[newRollout.activeControl].controlType == "groupstart" or newRollout.controls[newRollout.activeControl].controlType == "groupend") and (newRollout.controls[newRollout.activeControl - 1].controlType == "groupstart" or newRollout.controls[newRollout.activeControl - 1].controlType == "groupend")) do
					(
						swap newRollout.controls[newRollout.activeControl] newRollout.controls[newRollout.activeControl - 1]
						newRollout.activeControl -= 1
						
						RL_RolloutCreator.lbx_UIItems.selection -= 1
						
						RL_RolloutBuilder.updateEditUI()
						RL_RolloutBuilder.addCustomUI()
						
						
					)
				)
				
			)
			on btn_moveDown pressed do
			(
				
				
				if newRollout.activeControl < lbx_UIitems.items.count do
				(
					--check that groupstart is above group end or groupstart
					if not ((newRollout.controls[newRollout.activeControl].controlType == "groupstart" or newRollout.controls[newRollout.activeControl].controlType == "groupend") and (newRollout.controls[newRollout.activeControl + 1].controlType == "groupstart" or newRollout.controls[newRollout.activeControl + 1].controlType == "groupend")) do
					(
						
						swap newRollout.controls[newRollout.activeControl] newRollout.controls[newRollout.activeControl + 1]
						newRollout.activeControl += 1
						
						RL_RolloutCreator.lbx_UIItems.selection += 1
						RL_RolloutBuilder.updateEditUI()
						RL_RolloutBuilder.addCustomUI()
					)
				)
			)
			on btn_removeUiControl pressed do
			(
					
				if newRollout.activeControl != 0 do
				(
					Case newRollout.controls[newRollout.activeControl].controlType of
					(
						"groupstart" : (
								--find groupend UI item and delete that too
								r = newRollout.controls[newRollout.activeControl].controlName
								deleteitem newRollout.controls newRollout.activeControl
								for i = newRollout.controls.count to 1 by -1 where newRollout.controls[i].controlType != "groupstart" and newRollout.controls[i].controlName == r do deleteitem newRollout.controls i
								
								
							)
						"groupend" : (
								--find groupend UI item and delete that too
								sel = newRollout.activeControl
								local var = newRollout.controls[sel].controlName
								deleteitem newRollout.controls sel
								for i = newRollout.controls.count to 1 by -1 where newRollout.controls[i].controlType != "groupend" and newRollout.controls[i].controlName == var do deleteitem newRollout.controls i
								newRollout.activeControl -= 1
								RL_RolloutCreator.lbx_UIItems.selection -= 1
							)
						default : deleteitem newRollout.controls newRollout.activeControl
					)
					
					
					newRollout.activeControl -= 1
					RL_RolloutCreator.lbx_UIItems.selection -= 1
					
					
					if newRollout.controls.count == 0 do
					(
						newRollout.activeControl = 0
						newRollout.controls.selection = 0
					)
					
					if RL_RolloutCreator.lbx_UIItems.selection == 0 and newRollout.controls.count > 1 do
					(
						newRollout.activeControl = 1
						RL_RolloutCreator.lbx_UIItems.selection = 1
					)
					
					RL_RolloutBuilder.updateEditUI()
					RL_RolloutBuilder.addCustomUI()
					RL_RolloutBuilder.addControlUI()
				)
			)
			
			on lbx_UIitems selected sel do
			(
				--addCustomUI()
				newRollout.activeControl = sel
				RL_RolloutBuilder.updateEditUI()
				RL_RolloutBuilder.addControlUI()
			)
			
			
			
			on btn_update pressed do RL_RolloutBuilder.addCustomUI()
			on btn_buildUI pressed do RL_RolloutBuilder.addCustomUI buildUICode:true
		)

		--CreateDialog RL_RolloutCreator
		--rolloutBuilder = newrolloutfloater "Rollout Creator" 400 600
		--addRollout RL_loadMaxscript rolloutBuilder
		--addRollout RL_RolloutCreator rolloutBuilder
		--addRollout RL_RolloutParams rolloutBuilder
		--addRollout RL_commonParams rolloutBuilder
		--RL_RolloutCreator.addControlUI()
		
		
		
		
		fn updateListBox =
			(
				RL_RolloutCreator.lbx_UIitems.items = for o in newRollout.controls collect (o.controlType + " - " + o.controlName + " - " + o.label)
				--todo Update this to show full code being generated
			)
		
		fn addControlUI =
			(
				if RL_RolloutBuilder != undefined do
				(
					if RL_RolloutBuilder.sub_right.rollouts[2] != undefined do
					(
						
						--removeRollout rolloutBuilder.rollouts[5] rolloutBuilder
						--RL_RolloutBuilder
						removeSubRollout RL_RolloutBuilder.sub_right RL_RolloutBuilder.sub_right.rollouts[2]
					)
					if newRollout.activeControl != 0 do
					(
						
						--print "debug"
						--print newRollout.controls[newRollout.activeControl].controlType
						
						RC = Case newRollout.controls[newRollout.activeControl].controlType of
						(
							"spinner" : RL_Spinner
							"checkbox" : RL_Checkbox
							"edittext" : RL_edittext
							"dropdownlist" : RL_dropdownlist
							"listbox" : RL_listbox
							"combobox" : RL_combobox
							"multilistbox" : RL_Multilistbox
							"bitmap" : RL_bitmap
							"imgTag" : RL_imgTag
							"button" : RL_button
							"radiobuttons" : RL_Radiobuttons
							"colorpicker" : RL_colorpicker
							"pickbutton" : RL_pickbutton
							"mapbutton" : RL_MapButton
							"materialbutton" : RL_MaterialButton
							"checkbutton" : RL_Checkbutton
							"hyperlink" : RL_Hyperlink
							"curvecontrol" : RL_CurveControl
							"subRollout" : RL_subRollout
							"slider" : RL_Slider
							"progressBar" : RL_ProgressBar
							"label" : RL_Label
							"angle" : RL_Angle
							"group" : RL_group
							"groupstart" : RL_group
							"groupend" : RL_group
							"groupbox" : RL_groupbox
							"hyperlink" : RL_hyperlink
							"curveControl" : RL_curveControl
							
						)
						addSubRollout RL_RolloutBuilder.sub_Right RC
					)
				)
			)
			fn updateEditUI =
			(
				RL_RolloutBuilder.updateListBox()
				--newRollout.activeControl = lbx_UIItems.items.count
				
				--local st = ar_nodes[::HydragenRollout.s.activenode]
				sel = newRollout.activeControl
				if sel != 0 and newRollout.controls[sel].ControlType != "groupstart" and newRollout.controls[sel].ControlType != "groupend" then
				(
					--sel = selected
					-- 1        2             3           4       5        6        7        8            9      10            11         12             13         14         15       16       17              18         19            20           21
					--type, propName, UIName, value, usepos, posX, posY, usewidth, width, useheight, height, useoffset, offsetX, offsetY, useAlgin, align, useAcross, across, rangeFrom, rangeTo, spinnerType
					
					
					--btn_update.enabled = true
					
					--update edit UI items
					RL_commonParams.edt_ControlName.text = newRollout.controls[sel].controlName
					RL_commonParams.edt_UIname.text = newRollout.controls[sel].label
					if newRollout.controls[sel].enabled != undefined do RL_commonParams.chk_enabled.checked = newRollout.controls[sel].enabled
					
					RL_commonParams.chk_useVisible.checked = RL_commonParams.chk_visible.enabled = newRollout.controls[sel].useVisible
					RL_commonParams.chk_visible.checked = newRollout.controls[sel].visible
					
					RL_commonParams.chk_across.checked = RL_commonParams.spn_across.enabled = newRollout.controls[sel].useAcross
					RL_commonParams.spn_across.value = newRollout.controls[sel].across
					RL_commonParams.chk_customWidth.checked = RL_commonParams.spn_width.enabled = newRollout.controls[sel].useWidth
					RL_commonParams.spn_width.value = newRollout.controls[sel].width
					
					RL_commonParams.chk_usePercentageWidth.checked = RL_commonParams.spn_percentageWidth.enabled = newRollout.controls[sel].usePercentageWidth
					RL_commonParams.spn_percentageWidth.value = newRollout.controls[sel].percentageWidth 
					
					RL_commonParams.chk_customheight.checked = RL_commonParams.spn_height.enabled = newRollout.controls[sel].useHeight
					RL_commonParams.spn_height.value = newRollout.controls[sel].height
					if newRollout.controls[sel].useOffset != undefined do
					(
						RL_commonParams.chk_offset.checked = RL_commonParams.spn_offsetX.enabled = RL_commonParams.spn_offsetY.enabled = newRollout.controls[sel].useOffset
						
					)
					RL_commonParams.spn_offsetX.value = newRollout.controls[sel].offset[1]
					RL_commonParams.spn_offsetY.value = newRollout.controls[sel].offset[2]
					if newRollout.controls[sel].usePos != undefined do
					(
						RL_commonParams.chk_Pos.checked = RL_commonParams.spn_PosX.enabled = RL_commonParams.spn_PosY.enabled = newRollout.controls[sel].usePos
						RL_commonParams.spn_PosX.value = newRollout.controls[sel].pos[1]
						RL_commonParams.spn_PosY.value = newRollout.controls[sel].pos[2]
					)
					RL_commonParams.chk_align.checked = RL_commonParams.rdo_align.enabled = newRollout.controls[sel].useAlign
					
					RL_commonparams.edt_tooltip.text = newRollout.controls[sel].tooltip
					RL_commonparams.edt_comment.text = newRollout.controls[sel].comment
					
					
					
					
					if newRollout.controls[sel].align != undefined do 
					(
						
						
						index = case (newRollout.controls[sel].align as string) of 
						(
							"left": 1
							"center": 2
							"right": 3
							#left : 1
							#center : 2
							#right : 3
						)
						
						try(RL_commonParams.rdo_align.state = index)catch() --todo bug here
						)
					--state
					
		-- 			if st[sel].controlType == "spinner" then
		-- 			(
		-- 				spn_from.enabled = true
		-- 				spn_to.enabled = true
		-- 				
		-- 				spn_from.value = st[sel].range[1]
		-- 				spn_to.value = st[sel].range[2]
		-- 			)
		-- 			else
		-- 			(
		-- 				spn_from.enabled = false
		-- 				spn_to.enabled = false
		-- 				
		-- 				spn_from.value = 0
		-- 				spn_to.value = 0
		-- 			)
						
					RL_commonParams.edt_ControlName.enabled = true
					RL_commonParams.edt_UIname.enabled = true
					RL_commonParams.chk_enabled.enabled = true
					RL_commonParams.btn_half.enabled = true
					RL_commonParams.btn_full.enabled = true
					RL_commonParams.chk_useVisible.enabled = true
					--RL_commonParams.chk_visible.enabled = true
					RL_commonParams.chk_across.enabled = true
					--RL_commonParams.spn_across.enabled = true
					RL_commonParams.chk_customWidth.enabled = true
					--RL_commonParams.spn_width.enabled = true
					RL_commonParams.chk_usePercentageWidth.enabled = true
					--RL_commonParams.spn_percentageWidth.enabled = true
					RL_commonParams.chk_customheight.enabled = true
					--RL_commonParams.spn_height.enabled = true
					RL_commonParams.chk_offset.enabled = true
					--RL_commonParams.spn_offsetX.enabled = true
					--RL_commonParams.spn_offsetY.enabled = true
					RL_commonParams.chk_Pos.enabled = true
					--RL_commonParams.spn_PosX.enabled = true
					--RL_commonParams.spn_PosY.enabled = true
					RL_commonParams.chk_align.enabled = true
					--RL_commonParams.rdo_align.enabled = true
					
					RL_commonParams.edt_tooltip.enabled = true
					RL_commonParams.edt_comment.enabled = true
					
					If finditem #("label", "listbox", "multilistbox", "hyperlink", "progressBar", "edittext", "angle", "bitmap", "groupbox", "subRollout", "colorpicker", "curveControl") newRollout.controls[sel].ControlType != 0 do RL_commonparams.edt_tooltip.enabled = false
					
				)
				else
				(
					RL_commonParams.chk_enabled.enabled = false
					RL_commonParams.chk_useVisible.enabled = false
					RL_commonParams.chk_visible.enabled = false
					RL_commonParams.btn_full.enabled = false
					RL_commonParams.btn_half.enabled = false
					RL_commonParams.edt_ControlName.enabled = false
					RL_commonParams.edt_UIname.enabled = false
					RL_commonParams.chk_across.enabled = false
					RL_commonParams.spn_across.enabled = false
					RL_commonParams.chk_customWidth.enabled = false
					RL_commonParams.spn_width.enabled = false
					RL_commonParams.chk_usePercentageWidth.enabled = false
					RL_commonParams.spn_percentageWidth.enabled = false
					RL_commonParams.chk_customheight.enabled = false
					RL_commonParams.spn_height.enabled = false
					RL_commonParams.chk_offset.enabled = false
					RL_commonParams.spn_offsetX.enabled = false
					RL_commonParams.spn_offsetY.enabled = false
					RL_commonParams.chk_Pos.enabled = false
					RL_commonParams.spn_PosX.enabled = false
					RL_commonParams.spn_PosY.enabled = false
					RL_commonParams.chk_align.enabled = false
					RL_commonParams.rdo_align.enabled = false
					RL_commonParams.edt_tooltip.enabled = false
					RL_commonParams.edt_comment.enabled = false
					--btn_update.enabled = false
					
					if sel != 0 and newRollout.controls[sel].controlType == "groupstart" do 
					(
						RL_CommonParams.edt_UIName.enabled = true
						RL_CommonParams.edt_UIName.text = newRollout.controls[sel].label
					)
				)
				--addCustomUI()
				--addControlUI()
			)
		
		fn buildParamStr ui buildUICode:false =
			(
				Controlparamstr = ""
				if ui.useAcross do append Controlparamstr (" across:" + ui.across as string)
				if ui.usePos do append Controlparamstr (" pos:" + ui.pos as string)
				if ui.useOffset do append Controlparamstr (" offset:" + ui.offset as string)
				if not ui.usePercentageWidth then
				(
					if ui.useWidth do append Controlparamstr (" width:" + ui.width as string)
				)
				else
				(
					if ui.usePercentageWidth do append Controlparamstr (" width:" + (newRollout.rolloutWidth / 100.0 * ui.percentageWidth) as string + " usePercentageWidth:true percentageWidth:" + ui.percentageWidth as string)
				)
				if ui.useHeight do append Controlparamstr (" height:" + ui.height as string)
				if ui.useAlign do append Controlparamstr (" align:#" + ui.align as string)
				
				if ui.enabled != undefined do append ControlparamStr (" enabled:" + ui.enabled as string)
				if ui.useVisible do append ControlParamStr (" visible:" + ui.visible as string)
				
				Case ui.controlType of
				(
					"label" :(
						if ui.style_sunkenedge != undefined do append Controlparamstr (" style_sunkenedge:" + ui.style_sunkenedge as string)
					)
					"button" : (
						if ui.border != undefined do append ControlParamStr (" border:" + ui.border as string)
					)
					"spinner" : (
						if ui.type as string == "float" do append Controlparamstr (" type:#float range:" + ui.range as string)
						if ui.type as string == "integer" do append Controlparamstr (" type:#integer range:" + ui.range as string)
						if ui.type as string == "worldUnits" do append Controlparamstr (" type:#worldUnits range:" + ui.range as string)
						if ui.useFieldWidth != undefined and ui.useFieldWidth do append Controlparamstr (" fieldWidth:" + ui.fieldwidth as string)
						if ui.indeterminate !=undefined do append Controlparamstr (" indeterminate:" + ui.indeterminate as string)
						if ui.controller != undefined do append Controlparamstr (" controller:" + ui.controller as string)
						if ui.setKeyBrackets != undefined do append Controlparamstr ( " setKeyBrackets:" + ui.setKeyBrackets as string)
						if ui.scale != undefined do append Controlparamstr (" scale:" + ui.scale as string)
					)
					"checkbox" : (
						if ui.checked != undefined do append Controlparamstr (" checked:" + ui.checked as string)
						if ui.useTristate != undefined and ui.useTriState and ui.TriState != undefined do append Controlparamstr (" triState:" + ui.tristate as string)
					)
					"pickbutton" : (
						if ui.message != undefined do append ControlparamStr (" message:" + ui.message as string)
						if ui.filter != undefined do append ControlparamStr (" filter:" + ui.filter as string)
						if ui.autoDisplay != undefined do append ControlparamStr (" autoDisplay:" + ui.autoDisplay as string)
					)
					"mapbutton" : (
						if ui.map != undefined do append ControlparamStr (" map:" + ui.map as string)
						if ui.border != undefined do append ControlparamStr (" border:" + ui.border as string)
					)
					"materialbutton" : (
						if ui.material != undefined do append ControlparamStr (" map:" + ui.material as string)
						if ui.border != undefined do append ControlparamStr (" border:" + ui.border as string)
					)
					"colorpicker" : (
						if ui.color != undefined do append Controlparamstr (" color:" + ui.color as string)
						if ui.useFieldWidth != undefined and ui.useFieldWidth do append ControlParamStr (" fieldWidth:" + ui.fieldWidth as string)
						if ui.modal != undefined do append ControlParamstr (" modal:" + ui.modal as string)
						if ui.title != undefined do append ControlParamStr (" title:" + ui.title as string)
						if ui.alpha != undefined do append ControlParamStr (" alpha:" + ui.alpha as string)
					)
					"multilistbox" : (
						if ui.items != undefined do append Controlparamstr (" items:" + ui.items as string)
						if ui.selection != undefined do append Controlparamstr (" selection:" + ui.selection as string)
					)
					"combobox" : (
						if ui.items != undefined do append Controlparamstr (" items:" + ui.items as string)
						if ui.selection != undefined do append Controlparamstr (" selection:" + ui.selection as string)
						if ui.text != undefined do append ControlparamStr (" text:" + ui.text as string)
					)
					"listbox" : (
						if ui.items != undefined do append Controlparamstr (" items:" + ui.items as string)
						if ui.selection != undefined do append Controlparamstr (" selection:" + ui.selection as string)
						if ui.readOnly != undefined do append Controlparamstr (" readOnly:" + ui.readOnly as string)
					)
					"dropdownlist" : (
						if ui.items != undefined do append ControlParamstr (" items:" + ui.items as string)
						if ui.selection != undefined do append Controlparamstr (" selection:" + ui.selection as string)
					)
					"radiobuttons" : (
						if ui.labels != undefined do append ControlParamstr (" labels:" + ui.labels as string)
						if ui.state != undefined do append ControlParamstr (" state:" + ui.state as string)
						if ui.usecolumns != undefined and ui.useColumns do append ControlParamstr (" columns:" + ui.columns as string)
						if ui.offsets != undefined do append ControlParamStr (" offsets:" + ui.offsets as string)
					)
					"edittext" : (
						if ui.labelonTop != undefined do append ControlParamStr (" labelOnTop:" + ui.labelonTop as string)
						if ui.text != undefined do append ControlParamStr (" text:\"" + ui.text + "\"")
						if ui.bold != undefined do append ControlParamStr (" bold:" + ui.bold as string)
						if ui.readOnly != undefined do append ControlParamStr (" readOnly:" + ui.readOnly as string)
						if ui.useFieldWidth != undefined and ui.useFieldWidth do append ControlParamStr (" fieldWidth:" + ui.fieldwidth as string)
					)
					"checkbutton" : (
						if ui.highlightColor != undefined do append ControlParamStr (" highlightColor:" + ui.highlightColor as string)
						if ui.checked != undefined do append ControlParamStr (" checked:" + ui.checked as string)
					)
					"subrollout" : (
						if ui.rollouts != undefined do append ControlParamStr (" rollouts:" + ui.rollouts as string)
					)
					"slider" : (
						if ui.range != undefined do append ControlParamStr (" range:" + ui.range as string)
						if ui.type != undefined do append ControlParamStr (" type:#" + ui.type as string)
						if ui.ticks != undefined do append ControlParamStr (" ticks:" + ui.ticks as string)
						if ui.orient != undefined do append ControlParamStr (" orient:#" + ui.orient as string)
						if ui.controller != undefined do append ControlParamStr (" controller:" + ui.controller as string)
					)
					"angle" : (
						if ui.color != undefined do append ControlParamStr (" color:" + ui.color as string)
						if ui.diameter != undefined do append ControlParamStr (" diameter:" + ui.diameter as string)
						if ui.degrees != undefined do append ControlParamStr (" degrees:" + ui.degrees as string)
						if ui.bitmap != undefined do append ControlParamStr (" bitmap:" + ui.bitmap as string)
						if ui.startDegree != undefined do append ControlParamStr (" startDegree:" + ui.startDegree as string)
						if ui.startRadians != undefined do append ControlParamStr (" startRadians:" + ui.startRadians as string)
						if ui.dir != undefined do append ControlParamStr (" dir:#" + ui.dir as string)
						if ui.range != undefined do append ControlParamStr (" range:" + ui.range as string)
					)
					"bitmap" : (
						if ui.bitmap != undefined do append ControlParamStr (" bitmap:" + ui.bitmap as string)
						if ui.filename != undefined do append ControlParamStr (" filename:" + ui.filename as string)
					)
					"imgTag" : (
						if ui.bitmap != undefined do append ControlParamStr (" bitmap:" + ui.bitmap as string)
						if ui.opacity != undefined do append ControlParamStr (" opacity:" + ui.opacity as string)
						if ui.style != undefined do append ControlParamStr (" style:" + ui.style as string)
						if ui.transparent != undefined do append ControlParamStr (" transparent:" + ui.transparent as string)
					)
					"hyperlink" : (
						if ui.address != undefined do append ControlParamStr (" address:@\"" + ui.address as string + "\"")
						if ui.hoverColor != undefined do append ControlParamStr (" hoverColor:" + ui.hoverColor as string)
						if ui.visitedColor != undefined do append ControlParamStr (" visitedColor:" + ui.visitedColor as string)
					)
					"curveControl" :(
						if ui.numCurves != undefined do append ControlParamStr (" numCurves:" + ui.numCurves as string)
						if ui.x_range != undefined do append ControlParamStr (" x_range:" + ui.x_range as string)
						if ui.y_range != undefined do append ControlParamStr (" y_range:" + ui.y_range as string)
						if ui.x_value != undefined do append ControlParamStr (" x_value:" + ui.x_value as string)
						if ui.zoomValues != undefined do append ControlParamStr (" zoomValues:" + ui.zoomValues as string)
						if ui.scrollValues != undefined do append ControlParamStr (" scrollValues:" + ui.scrollValues as string)
						if ui.commandMode != undefined do append ControlParamStr (" commandMode:#" + ui.commandMode as string)
						
						if ui.uiFlags != undefined do append ControlParamStr (" uiFlags:" + (for o in ui.uiFlags collect (o)) as string)
						if ui.rcmFlags != undefined do append ControlParamStr (" rcmFlags:" + (for o in ui.rcmFlags collect (o)) as string)
					
						if ui.asPopup != undefined do append ControlParamStr (" asPopup:" + ui.asPopup as string)
					)
					"progressBar" :(
						if ui.value != undefined do append ControlParamStr (" value:" + ui.value as string)
						if ui.color != undefined do append ControlParamStr (" color:" + ui.color as string)
						if ui.orient != undefined do append ControlParamStr (" orient:#" + ui.orient as string)
					)
					
				)
				
				
				if not buildUICode then
					append Controlparamstr( " tooltip:\"" + ui.tooltip + " - (" + ui.ControlName + ")\"")
				else
					if ui.tooltip != "" do append Controlparamstr( " tooltip:\"" + ui.tooltip + "\"")
				
				if ui.comment != "" do append Controlparamstr( " --" + ui.comment)
				
				Controlparamstr
			)
			
			fn addCustomUI buildUICode:false =
			(
				--local st = ar_nodes[::HydragenRollout.s.activenode]
				try(DestroyDialog RL_CustomUI)catch()
				try(DestroyDialog lastRollout)catch()
				--try(removesubrollout HydraGenRollout.subright RL_CustomNodeScript)catch()
				--try(removesubrollout ::HydraGenrollout.subright (for o in HydraGenrollout.subright.rollouts where o.name == "RL_HelpNode" collect o)[1])catch()
				global rci
				--[getdialogpos rolloutBuilder]
				
				if not newRollout.useHeight then
					rci = rolloutCreator newrollout.rolloutName newRollout.rolloutTitle width:newRollout.rolloutWidth 
				else
					rci = rolloutCreator newRollout.rolloutName newRollout.rolloutTitle width:newRollout.rolloutWidth  height:newRollout.rolloutHeight 
				
				rci.begin()
				--rci.addControl #button #myButton "My Button"
				--rci.addHandler #myButton #pressed filter:on codeStr:"MessageBox @Isn't this cool@ title:@Wow@"
				
				for i = 1 to newRollout.controls.count do
				(
					local ctrlLabel = newRollout.controls[i].controlName 
					local uiName = newRollout.controls[i].label
					
					Case newRollout.controls[i].controlType of
					(
						"label" : (
							rci.addControl #label ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
						)
						"spinner" : (
							rci.addControl #spinner ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"colorpicker" : (
							rci.addControl #colorpicker ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"checkbox" : (
							rci.addControl #checkbox ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"groupstart" :(
							rci.addText ("group @" + uiName + "@ (") filter:true
						)
						"groupend" :(
							rci.addText (")") filter:true
						)
						"button" : (
							rci.addControl #button ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"checkbutton" : (
							rci.addControl #checkbutton ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"pickbutton" : (
							rci.addControl #pickbutton ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"materialbutton" : (
							rci.addControl #materialbutton ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"mapbutton" : (
							rci.addControl #mapbutton ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"radiobuttons" : (
							rci.addControl #radiobuttons ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
						)
						"dropdownlist" : (
							rci.addControl #dropdownlist ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"listbox" : (
							rci.addControl #listbox ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"multilistbox" : (
							rci.addControl #multilistbox ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"combobox" : (
							rci.addControl #combobox ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"angle" : (
							rci.addControl #angle ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"slider" : (
							rci.addControl #slider ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"edittext" : (
							rci.addControl #edittext ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"groupbox" : (
							rci.addControl #groupbox ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"bitmap" : (
							rci.addControl #bitmap ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"imgTag" : (
							rci.addControl #imgTag ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
							--rci.addHandler uiName #changed paramStr:"val" codeStr:("ar_nodes[::HydragenRollout.s.activenode].UI[" + i as string + "][4] = val")
						)
						"subRollout" : ( 
							rci.addControl #subRollout ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
						)
						"hyperlink" : (
							rci.addControl #hyperlink ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
						)					
						"curveControl" : (
							rci.addControl #curveControl ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
						)
						"progressBar" : (
							rci.addControl #progressBar ctrlLabel uiName paramStr:(buildParamStr newRollout.controls[i] buildUICode:buildUICode)
						)
					)
				)
				
				fn makeResizeCode =
				(
					--rr = stringstream "local w = val[1]\n"
					--rr = stringstream ""
					--for o in newRollout.controls where o.usePercentageWidth do
					--(
						--format "%.width = (% / % * 100)\n" o.controlName o.percentageWidth newRollout.rolloutWidth to:rr
						
					--)
					
					--rr as string
					
					rr = stringstream ""
					
					format "RL_RolloutBuilder.sub_left.rollouts[2].spn_rolloutWidth.value = newRollout.rolloutWidth = val[1]\n" to:rr
					format "RL_RolloutBuilder.sub_left.rollouts[2].spn_rolloutHeight.value = newRollout.rolloutHeight = val[2]\n" to:rr
					
					
					rr as string
				)
				
				if not buildUICode and newRollout.getLiveSize do rci.addHandler newrollout.rolloutName #resized paramStr:"val" codeStr:(makeResizeCode()) filter:on
				
				global lastRollout = (rci.end())
				if RL_RolloutBuilder != undefined do mainPos = getDialogPos RL_RolloutBuilder
				
				
				rr = stringstream ""
				format "createDialog lastRollout " to:rr
				format "pos:% " ([mainPos.x + 665, mainPos.y] as string) to:rr
				if newRollout.style != undefined then format "style:% " (newRollout.style as string) to:rr else format "style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox, #style_resizing) " to:rr
				format "parent:% " (RL_RolloutBuilder.hwnd as string) to:rr
				if newRollout.lockWidth != undefined do format "lockWidth:% " newRollout.lockWidth to:rr
				if newRollout.lockHeight != undefined do format "lockHeight:% " newRollout.lockHeight to:rr
				if newRollout.modal != undefined do format "modal:% " newRollout.modal to:rr
				
				if newRollout.fgColor != undefined do format "fgColor:% " newRollout.fgColor to:rr
				if newRollout.bgColor != undefined do format "bgColor:% " newRollout.bgColor to:rr
				
				if newRollout.useBitmap and newRollout.bitmap != undefined do format "bitmap:(openBitmap @\"%\") " newRollout.bitmap.filename to:rr
				if newRollout.bmpStyle  != undefined do format "bmpstyle:(%) " newRollout.bmpStyle to:rr
				execute(rr as string)
				
				
				gc light:true
				--print rci
				--addsubRollout hydraGenRollout.subRight (rci.end())
				--addsubrollout hydraGenRollout.subRight RL_CustomNodeScript
				
				if buildUICode do
				(
					theRollout = newScript()
					format "try(destroydialog %)catch()\n" newRollout.rolloutName to:theRollout
					format "%\n" rci.str to:theRollout
					
					
					format "CreateDialog % " newRollout.rolloutName to:theRollout
					
					if newRollout.style != undefined do format "style:% " ((newRollout.style) as string) to:theRollout
					if newRollout.lockWidth != undefined do format "lockWidth:% " newRollout.lockWidth to:theRollout
					if newRollout.lockHeight != undefined do format "lockHeight:% " newRollout.lockHeight to:theRollout
					if newRollout.modal != undefined do format "modal:% " newRollout.modal to:theRollout
						
					if newRollout.fgColor != undefined do format "fgColor:% " newRollout.fgColor to:theRollout
					if newRollout.bgColor != undefined do format "bgColor:% " newRollout.bgColor to:theRollout
				)
				--lastRollout = newRollout.rolloutName
				--print "debug"
				--print (show rci)
				--print "end debug"
			)

		subRollout sub_left ""  across:2 width:410 height:611 align:#left
		subRollout sub_right ""  width:218 height:610 align:#right
		
		on RL_RolloutBuilder open do
		(
			addsubRollout sub_left RL_RolloutCreator 
			addsubRollout sub_left RL_RolloutParams
			addsubRollout sub_left RL_loadMaxscript
			
			addsubRollout sub_right RL_Commonparams
			
			addControlUI()
			updateEditUI()
		)
		
		on RL_RolloutBuilder resized val do
		(
			sub_left.height = (val[2] - 10)
			sub_right.height = (val[2] - 10)
		)
		
		on RL_RolloutBuilder moved val do
		(
			--setDialogPos (execute(newRollout.rolloutName)) [val.x + 665, val.y]
		)
		
		on RL_RolloutBuilder close do
		(
			DW_InteractiveRolloutBuilderPos = getDialogPos RL_RolloutBuilder
			
		)
	)

	CreateDialog RL_RolloutBuilder style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox, #style_resizing) lockwidth:true 
	
	if DW_InteractiveRolloutBuilderPos != undefined do 
	(
		setDialogPos RL_RolloutBuilder DW_InteractiveRolloutBuilderPos
		setDialogPos (execute(newRollout.rolloutName)) [DW_InteractiveRolloutBuilderPos.x + 665, DW_InteractiveRolloutBuilderPos.y]
		
		--Fix for the first run where maxscript doesn't want to use our custom height for some reason.
		if newRollout.useHeight do (execute(newRollout.rolloutName)).height = newRollout.rolloutHeight 
	)