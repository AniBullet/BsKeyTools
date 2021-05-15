/***************************************************************

* LMA - Layer Manager Alternative
* Version: 1.0
* Written by: Matan Halberstadt
* Last updated at: 23/12/2020
* Contact: tzmtnh@gmail.com

****************************************************************/

(
	global g_LayerManagerAlternative
	if g_LayerManagerAlternative != undefined and g_LayerManagerAlternative.form != undefined then
		g_LayerManagerAlternative.form.Close()
	
	struct s_LayerManagerAlternative
	(
		version = 1.0,
		buttonNames = #("New", "Delete", "Add", "Select", "Highlight", "Hide", "Freeze"),
		buttonToolTips = #(
			"Create new layer (containing selected objects)",
			"Delete highlighted empty layers",
			"Add selected objects to highlighted layer",
			"Select highlighted objects and layers",
			"Highlight selected objects' layers",
			"Hide/Unhide all layers",
			"Freeze/Unfreeze all layers"
		),
		columnCaptions = #("Layers", "", "Hide", "Freeze", "Render", "Color", "Radiosity", "Box mode"),
		columnNames = #("Layers", "Current", "Hide", "Freeze", "Render", "Color", "Radiosity", "BoxMode"),
		cmsGroups = #(
			#("Rename", "Copy", "Paste", "Collapse All", "Expand All"),
			#("Create New Layer (add Selection)", "Delete", "Add Selected Objects"),
			#("Select", "Highlight Selected Objects' Layer", "Highlight All Layers"),
			#("Layer Properties...", "Object Properties..."),
			#("Show Columns")
		),
		cmsNames = #(
			#("Rename", "Copy", "Paste", "Collapse_All", "Expand_All"),
			#("Create_New_Layer", "Delete", "Add_Selected_Objects"),
			#("Select", "Highlight_Selected", "Highlight_All"),
			#("Layer_Properties", "Object_Properties"),
			#("Show_Columns")
		),
		columnWidth = #(150, 40, 40, 50, 50, 50, 60, 60),
		callbacksID = #layerManagerAlternativeCallbacks,
		
		form,
		mainWrapper,
		treeList,
		toolstrip,
		contextMenuStrip,
		refreshTimer,
		refreshRequests = 0,
		iniFile = (getDir #userScripts) + @"\LaterManagerAlternativeData.ini",
		
		fn returnFocus =
		(
			if not g_LayerManagerAlternative.mainWrapper.Focused then
				g_LayerManagerAlternative.mainWrapper.focus()
		),
		
		fn requestRefresh =
		(
			try this catch return ::g_LayerManagerAlternative.requestRefresh()
			
			refreshTimer.Stop()
			refreshTimer.Start()
			refreshRequests += 1
		),
		
		fn getColorDotNet colorKey =
		(
			local c = 255 * (colorMan.getColor colorKey)
			(dotnetclass "system.drawing.color").FromArgb c.x c.y c.z
		),
		
		fn colorMax2DotNet c =
		(
			(dotnetclass "system.drawing.color").FromArgb c.r c.g c.b
		),
		
		fn colorDotNet2Max c =
		(
			color c.r c.g c.b
		),
		
		fn unregisterCallbacks =
		(
			callbacks.removeScripts id:g_LayerManagerAlternative.callbacksID
		),
		
		fn registerCallbacks =
		(
			unregisterCallbacks()
			
			local script = "try g_LayerManagerAlternative.requestRefresh() catch ()"
			callbacks.addScript #layerCreated script id:callbacksID
			callbacks.addScript #layerDeleted script id:callbacksID
			callbacks.addScript #nodeLayerChanged script id:callbacksID
			callbacks.addScript #filePostOpen script id:callbacksID
			callbacks.addScript #systemPostReset script id:callbacksID
		),
		
		fn validateToolstrip =
		(
			local selectedNodes = for i = 1 to treeList.Selection.Count collect treeList.Selection.Item[i - 1]
			local canAdd = selectedNodes.count == 1
			
			for n in selectedNodes where n.Tag != undefined do (
				local ref = n.Tag.Value
				local isLayer = classof ref == MixinInterface
				local isDefaultLayer = ref == LayerManager.getlayer 0
				
				if not isLayer then
					canAdd = false
			)
			
			toolstrip.Items.Item[2].Enabled = canAdd
		),
		
		fn selectionChangedEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.selectionChangedEvent sender args
			validateToolstrip()
		),
		
		fn afterFocusNodeEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.afterFocusNodeEvent sender args
			
			local n = treeList.FocusedNode
			local ref = n.Tag.Value
			local column = treeList.FocusedColumn
			local isLayer = classof ref == MixinInterface
			local selectedNodes = for i = 1 to treeList.Selection.Count collect treeList.Selection.Item[i - 1]
			
			case column.Caption as name of (
				#color: (
					local title = if isLayer then "Layer color" else "Object color"
					local c = colorPickerDlg ref.wirecolor title alpha:false pos:[100,100]
					
					if c != undefined then (
						for o in selectedNodes do (
							o.setValue column.AbsoluteIndex (colorMax2DotNet c)
							o.Tag.Value.wirecolor = c
						)
					)
				)
			)
		),
		
		fn clickEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.clickEvent sender args
			
			local hitInfo = treeList.CalcHitInfo args.Location
			if hitInfo.Node != undefined then (
				if args.Button == args.Button.Right then (
					if not hitInfo.Node.Selected then
						treeList.Selection.Clear()
					
					treeList.FocusedNode = hitInfo.Node
					hitInfo.Node.Selected = true
					contextMenuStrip.Show (treeList.PointToScreen args.Location)
				)
			) else (
				treeList.Selection.Clear()
			)
		),
		
		fn doubleClickEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.doubleClickEvent sender args
			
			local n = treeList.FocusedNode
			local ref = n.Tag.Value
			local column = treeList.FocusedColumn
			
			case column.Caption as name of (
				#layers: (
					if LayerManager.getlayer 0 != ref then (
						column.OptionsColumn.AllowEdit = true
						treeList.appearance.FocusedCell.BackColor = colorMax2DotNet white
					)
				)
			)
		),
		
		fn editLeaveEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.editLeaveEvent sender args
			treeList.Columns.Item[0].OptionsColumn.AllowEdit = false
			treeList.appearance.FocusedCell.BackColor = getColorDotNet #itemHilight
		),
		
		fn getLayerNodes layer =
		(
			local layerNodes = #()
			layer.nodes &layerNodes
			layerNodes
		),
		
		fn refresh =
		(
			try this catch return ::g_LayerManagerAlternative.refresh()
			try this.refreshRequests catch return false
			
			--format "Refreshing (requests: %)\n" refreshRequests
			refreshRequests = 0
			refreshTimer.Stop()
			
			local layers = for i = 1 to LayerManager.count collect LayerManager.getLayer (i - 1)
			local focusedNodeRef = if treeList.FocusedNode == undefined then undefined else treeList.FocusedNode.Tag.Value
			local selectedNodesRefs = for i = 1 to treeList.Selection.Count collect treeList.Selection.Item[i - 1].Tag.Value
			local expandedNodesRefs = for i = 1 to treeList.Nodes.Count where treeList.Nodes.Item[i - 1].Expanded collect treeList.Nodes.Item[i - 1].Tag.Value
			
			treeList.Nodes.Clear()
			treeList.BeginUnboundLoad()
			
			for i = 1 to layers.count do (
				local layerName = layers[i].name
				if layerName == "0" then
					layerName += " (default)"
				
				local layerNode = treeList.AppendNode #(layerName, layers[i].current, layers[i].isHidden, layers[i].isFrozen, layers[i].renderable, colorMax2DotNet layers[i].wireColor, layers[i].isGIExcluded, layers[i].boxMode) -1
				layerNode.Tag = dotNetMXSValue layers[i]
				local layerNodes = getLayerNodes layers[i]
				
				for o in layerNodes where isValidNode o do (
					local objNode = treeList.AppendNode #(o.name, false, o.isHidden, o.isFrozen, o.renderable, colorMax2DotNet o.wireColor, o.isGIExcluded, o.boxMode) layerNode.id
					objNode.Tag = dotNetMXSValue o
					objNode.Selected = findItem selectedNodesRefs o > 0
					if focusedNodeRef == o then treeList.FocusedNode = objNode
				)
				
				if focusedNodeRef == layers[i] then treeList.FocusedNode = layerNode
				layerNode.Selected = findItem selectedNodesRefs layers[i] > 0
				layerNode.Expanded = findItem expandedNodesRefs layers[i] > 0
			)
			
			treeList.EndUnboundLoad()
			validateToolstrip()
		),
		
		fn getSelectedNodes =
		(
			local selectedNodes = for i = 1 to treeList.Selection.Count collect treeList.Selection.Item (i - 1)
			appendIfUnique selectedNodes treeList.FocusedNode
			selectedNodes
		),
		
		fn cellValueChangingEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.cellValueChangingEvent sender args
			
			local ref = args.Node.Tag.value
			local isLayer = classof ref == MixinInterface
			local selectedNodes = for i = 1 to treeList.Selection.Count collect treeList.Selection.Item[i - 1]
			local columnIndex = args.Column.AbsoluteIndex
			
			case args.Column.Name as name of (
				#layers: (
					if isLayer and LayerManager.getlayer 0 == ref then (
						treeList.BeginUpdate()
						args.Node.SetValue 0 "0 (default)"
						treeList.EndUpdate()
					) else if isLayer then
						ref.setname args.Value
					else
						ref.name = args.Value
				)
				
				#current: (
					treeList.BeginUpdate()
					if isLayer then (
						ref.current = true
						
						for i = 1 to treeList.Nodes.Count do (
							local n = treeList.Nodes.Item (i - 1)
							local ref = n.Tag.Value
							if classof ref == MixinInterface then
								n.SetValue columnIndex (n == args.Node)
						)
					) else
						args.Node.SetValue columnIndex false
					treeList.EndUpdate()
				)
				
				#hide: (
					for o in selectedNodes do (
						o.SetValue columnIndex args.Value
						o.Tag.Value.isHidden = args.Value
					)
				)
				
				#freeze: (
					for o in selectedNodes do (
						o.SetValue columnIndex args.Value
						o.Tag.Value.isFrozen = args.Value
					)
				)
				
				#render: (
					for o in selectedNodes do (
						o.SetValue columnIndex args.Value
						o.Tag.Value.renderable = args.Value
					)
				)
				
				#radiosity: (
					for o in selectedNodes do (
						o.SetValue columnIndex args.Value
						o.Tag.Value.isGIExcluded = args.Value
					)
				)
				
				#boxmode: (
					for o in selectedNodes do (
						o.SetValue columnIndex args.Value
						o.Tag.Value.boxMode = args.Value
					)
				)
			)
		),
		
		fn createNewLayer =
		(
			try this catch return ::g_LayerManagerAlternative.createNewLayer()
			
			local newLayer = LayerManager.newLayer()
			newLayer.current = true
			for o in selection do
				newLayer.addnode o
			requestRefresh()
		),
		
		fn deleteSelectedLayers =
		(
			try this catch return ::g_LayerManagerAlternative.deleteSelectedLayers()
			
			local selectedNodes = getSelectedNodes()
			local defaultLayer = LayerManager.getlayer 0
			for n in selectedNodes where classof n.Tag.Value == MixinInterface and n.Tag.Value != defaultLayer do (
				if n.Tag.Value.current then
					defaultLayer.current = true
				LayerManager.deleteLayerByName n.Tag.Value.Name
			)
			
			requestRefresh()
		),
		
		fn addObjectsToSelectedLayer =
		(
			try this catch return ::g_LayerManagerAlternative.addObjectsToSelectedLayer()
			
			local selectedNodes = getSelectedNodes()
			if selectedNodes.count != 1 or classof selectedNodes[1].Tag.Value != MixinInterface then return false
			local layer = selectedNodes[1].Tag.Value
			for o in selection do
				layer.addnode o
			
			requestRefresh()
		),
		
		fn selectObjectsInScene =
		(
			try this catch return ::g_LayerManagerAlternative.selectObjectsInScene()
			
			local objs = #()
			local selectedNodes = getSelectedNodes()
			
			for n in selectedNodes do (
				local ref = n.Tag.Value
				if classof ref == MixinInterface then (
					local layerNodes = getLayerNodes ref
					join objs layerNodes
				) else
					append objs ref
			)
			
			select (makeUniqueArray objs)
		),
		
		fn highlightSelectedObjectsLayers =
		(
			try this catch return ::g_LayerManagerAlternative.highlightSelectedObjectsLayers()
			
			local usedLayers = #()
			
			for o in selection do
				appendIfUnique usedLayers o.layer
			
			for i = 1 to treeList.Nodes.Count do (
				local n = treeList.Nodes.Item (i - 1)
				local ref = n.Tag.Value
				local state = classof ref == MixinInterface and findItem usedLayers ref > 0
				n.Selected = state
			)
		),
		
		fn buttonClickEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.buttonClickEvent sender args
			
			unregisterCallbacks()
			local selectedNodes = getSelectedNodes()
			
			case sender.Name as name of
			(
				#new: createNewLayer()
				
				#delete: deleteSelectedLayers()
				
				#add: addObjectsToSelectedLayer()
				
				#select: selectObjectsInScene()
				
				#highlight: highlightSelectedObjectsLayers()
				
				#hide: (
					local allHidden = true
					for i = 1 to treeList.Nodes.Count do (
						local n = treeList.Nodes.Item (i - 1)
						local ref = n.Tag.Value
						if classof ref == MixinInterface and not ref.isHidden then
							exit with allHidden = false
					)
					
					treeList.BeginUpdate()
					for i = 1 to treeList.Nodes.Count do (
						local n = treeList.Nodes.Item (i - 1)
						local ref = n.Tag.Value
						ref.isHidden = not allHidden
						n.SetValue 2 (not allHidden)
					)
					treeList.EndUpdate()
				)
				
				#freeze: (
					local allFrozen = true
					for i = 1 to treeList.Nodes.Count do (
						local n = treeList.Nodes.Item (i - 1)
						local ref = n.Tag.Value
						if classof ref == MixinInterface and not ref.isFrozen then
							exit with allFrozen = false
					)
					
					treeList.BeginUpdate()
					for i = 1 to treeList.Nodes.Count do (
						local n = treeList.Nodes.Item (i - 1)
						local ref = n.Tag.Value
						ref.isFrozen = not allFrozen
						n.SetValue 3 (not allFrozen)
					)
					treeList.EndUpdate()
				)
			)
			
			registerCallbacks()
		),
		
		fn afterExpandEvent sender args =
		(
			try this catch return ::g_LayerManagerAlternative.afterExpandEvent sender args
			
			treeList.BeginUpdate()
			for i = 1 to args.Node.Nodes.Count do (
				local n = args.Node.Nodes.Item[i - 1]
				local o = n.Tag.Value
				if n.Item[0] as name != o.name as name then
					n.SetValue 0 o.name
			)
			treeList.EndUpdate()
		),
		
		fn openDialog =
		(
			createDialog roll_LMA width:ROLL_SIZE.x height:ROLL_SIZE.y style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing)
		),
		
		fn getIconFromBitmap srcFileName iconName index =
		(
			local w = 16
			local h = w
			
			local iconsPath = getDir #userIcons + @"\LMA\"
			if not doesFileExist iconsPath then
				makeDir iconsPath
			
			local fileName = iconsPath + iconName + ".bmp"
			
			-- force refres - only works on first load because of some permission issue
			--if doesFileExist fileName do (
			--	deleteFile fileName
			--)
			
			if not doesFileExist fileName then (
				local iconsFile = getDir #ui + @"\icons\" + srcFileName + ".bmp"
				if not doesFileExist iconsFile then
					iconsFile = getDir #ui_ln + @"\icons\" + srcFileName + ".bmp"
				if not doesFileExist iconsFile then
					return undefined
				
				local tempBmp = openBitmap iconsFile
				local iconBmp = bitmap w h
				iconBmp.fileName = fileName
				pasteBitmap tempBmp iconBmp (box2 [w * (index - 1), 0] [w * index, h]) [0, 0]
				
				local replacePixel = #(color 255 0 255 0)
				for i = 0 to w - 1 do (
					for j = 0 to h - 1 do (
						local p = (getPixels iconBmp [i, j] 1)[1]
						if (p.a > 0.0001) then continue
						setPixels iconBmp [i, j] replacePixel
					)
				)
				
				close tempBmp
				save iconBmp
				close iconBmp
				free iconBmp
			)
			
			(dotNetClass "System.Drawing.image").FromFile fileName
		),
		
		fn cmsHighlightAllLayers sender args =
		(
			try this catch return ::g_LayerManagerAlternative.cmsHighlightAllLayers sender args
			for i = 1 to treeList.Nodes.Count do
				treeList.Nodes.Item[i - 1].Selected = true
		),
		
		fn cmsLayerProperties sender args =
		(
			try this catch return ::g_LayerManagerAlternative.cmsLayerProperties sender args
			local selectedNodes = for i = 1 to treeList.Selection.Count collect treeList.Selection.Item[i - 1]
			local layerList = for n in selectedNodes where classof n.Tag.Value == MixinInterface collect ILayerManager.getLayerObject n.Tag.Value.Name
			LayerManager.layerPropDialog &layerList
		),
		
		fn cmsObjectProperties sender args =
		(
			try this catch return ::g_LayerManagerAlternative.cmsObjectProperties sender args
			
			local selectedNodes = for i = 1 to treeList.Selection.Count collect treeList.Selection.Item[i - 1]
			local objectList = #()
			for n in selectedNodes do (
				local ref = n.Tag.Value
				if classof ref == MixinInterface then
					join objectList (getLayerNodes ref)
				else
					append objectList n.Tag.Value
			)
			
			with redraw off (
				local currentSelection = selection as array
				select (makeUniqueArray objectList)
				actionMan.executeAction 0 "40022"
				clearSelection()
				select currentSelection
			)
		),
		
		fn validateCMS sender args =
		(
			local enabledItems = #{4..7, 10..13, 16, 18}
			local v = (maxVersion())[1] / 1000 - 2
			
			enabledItems[8] = toolstrip.Items.Item[1].Enabled
			enabledItems[9] = toolstrip.Items.Item[2].Enabled
			enabledItems[15] = v > 14
			
			local n = sender.Items.Count
			for i = 1 to n do (
				local item = sender.Items.Item[i - 1]
				item.Enabled = enabledItems[i]
			)
			
			local showColumnsItem = sender.Items.Item[n - 1]
			for i = 1 to showColumnsItem.DropDownItems.Count do (
				local item = showColumnsItem.DropDownItems.Item[i - 1]
				item.Checked = item.Tag.Visible
			)
			
		),
		
		fn cmsExpandAll =
		(
			try this catch return ::g_LayerManagerAlternative.cmsExpandAll()
			treeList.ExpandAll()
		),
		
		fn cmsCollapseAll =
		(
			try this catch return ::g_LayerManagerAlternative.cmsCollapseAll()
			treeList.CollapseAll()
		),
		
		fn safaLoadProp category propName propClass defaultValue =
		(
			local val = execute (getINISetting iniFile category propName)
			if classOf val == propClass then
				val
			else
				defaultValue
		),
		
		fn saveProperties =
		(
			setINISetting iniFile "UI" "pos" ("[" + form.Location.x as string + "," + form.Location.y as string + "]")
			setINISetting iniFile "UI" "size" ("[" + form.Width as string + "," + form.Height as string + "]")
			
			for i = 1 to treeList.Columns.Count do (
				local column = treeList.Columns.Item[i - 1]
				local columnWidthProp = "column" + i as string + "_width"
				local columnVisibleProp = "column" + i as string + "_visible"
				setINISetting iniFile "UI" columnWidthProp (column.Width as string)
				setINISetting iniFile "UI" columnVisibleProp (column.Visible as string)
			)
		),
		
		fn loadProperties =
		(
			local pos = safaLoadProp "UI" "pos" point2 [0,0]
			local size = safaLoadProp "UI" "size" point2 [400,600]
			
			form.Location.x = pos.x
			form.Location.y = pos.y
			form.Width = size.x
			form.Height = size.y
			
			for i = 1 to treeList.Columns.Count do (
				local column = treeList.Columns.Item[i - 1]
				local columnWidthProp = "column" + i as string + "_width"
				local columnVisibleProp = "column" + i as string + "_visible"
				
				column.Width = safaLoadProp "UI" columnWidthProp integer columnWidth[i]
				column.Visible = safaLoadProp "UI" columnVisibleProp BooleanClass true
			)
		),
		
		fn columnToggleEvent sender args =
		(
			sender.Tag.Visible = not sender.Tag.Visible
		),
		
		fn initCMS =
		(
			contextMenuStrip = dotNetObject "System.Windows.Forms.ContextMenuStrip"
			contextMenuStrip.RenderMode = contextMenuStrip.RenderMode.Professional 
			contextMenuStrip.ShowCheckMargin = false
			contextMenuStrip.ShowImageMargin = false
			contextMenuStrip.BackColor = getColorDotNet #hilight
			contextMenuStrip.ForeColor = getColorDotNet #text
			
			local cmsEvents = #(
				#(undefined, undefined, undefined, cmsCollapseAll, cmsExpandAll),
				#(createNewLayer, deleteSelectedLayers, addObjectsToSelectedLayer),
				#(selectObjectsInScene, highlightSelectedObjectsLayers, cmsHighlightAllLayers),
				#(cmsLayerProperties, cmsObjectProperties),
				#()
			)
			
			local cmsItems = #()
			for i = 1 to cmsGroups.count do (
				if i > 1 then (
					local separator = dotNetObject "ToolStripSeparator"
					separator.Name = "Separator"
					append cmsItems separator
				)
				
				for j = 1 to cmsGroups[i].count do (
					local item = dotNetObject "ToolStripMenuItem"
					item.Name = cmsNames[i][j]
					item.Text = cmsGroups[i][j]
					item.Visible = true
					
					if cmsEvents[i][j] != undefined then
						dotNet.addEventHandler item "Click" cmsEvents[i][j]
					append cmsItems item
				)
			)
			
			local showColumnsItem = cmsItems[cmsItems.count]
			showColumnsItem.DropDown.BackColor = contextMenuStrip.BackColor
			showColumnsItem.DropDown.ForeColor = contextMenuStrip.ForeColor
			showColumnsItem.DropDown.RenderMode = showColumnsItem.DropDown.RenderMode.Professional
			showColumnsItem.DropDown.ShowCheckMargin = true
			showColumnsItem.DropDown.ShowImageMargin = false
			
			for i = 2 to treeList.Columns.Count do (
				local column = treeList.Columns.Item[i - 1]
				local item = dotNetObject "ToolStripMenuItem"
				item.Name = column.name
				item.Text = column.name
				item.Tag = column
				showColumnsItem.DropDownItems.Add item
				dotNet.addEventHandler item "Click" columnToggleEvent
			)
			
			contextMenuStrip.items.addRange cmsItems
			dotNet.addEventHandler contextMenuStrip "Opened" validateCMS
		),
		
		fn initIcons =
		(
			local srcFileName = "LayerManager_i"
			local imageList = dotNetObject "System.Windows.Forms.ImageList"
			local iconIndexes = #(1,2,3,4,5,8,9,10,11,12,13)
			
			for i = 1 to 13 do (
				local iconName = srcFileName + "_" + i as string
				local image = getIconFromBitmap srcFileName iconName i
				imageList.Images.Add image
			)
			
			imageList.TransparentColor = colorMax2DotNet (color 255 0 255 0)
			toolstrip.ImageList = imageList
			
			local indexes = #(0,9,1,3,7,11,12)
			for i = 1 to toolstrip.Items.Count do
				toolstrip.Items.Item[i - 1].ImageIndex = indexes[i]
		),
		
		fn done sender args =
		(
			try this catch return ::g_LayerManagerAlternative.done sender args
			
			saveProperties()
			unregisterCallbacks()
			
			form = undefined
			mainWrapper = undefined
			treeList = undefined
			toolstrip = undefined
			contextMenuStrip = undefined
			refreshTimer = undefined
			
			(dotNetClass "system.gc").Collect()
			gc light:true
		),
		
		fn init =
		(
			refreshTimer = dotnetobject "System.Windows.Forms.Timer"
			refreshTimer.Interval = 300
			dotnet.addEventHandler refreshTimer "Tick" refresh
			
			toolstrip = dotnetObject "System.Windows.Forms.ToolStrip"
			toolstrip.GripStyle = toolstrip.GripStyle.Hidden
			toolstrip.BackColor = getColorDotNet #background
			dotNet.addEventHandler toolstrip "MouseHover" returnFocus
			
			for i = 1 to buttonNames.count do (
				local button = dotNetObject "System.Windows.Forms.ToolStripButton"
				button.Name = buttonNames[i]
				button.ToolTipText = buttonToolTips[i]
				toolstrip.Items.Add button
				dotNet.addEventHandler button "Click" buttonClickEvent
				dotNet.setLifeTimeControl button #dotNet
			)
			
			local textEdit = dotNetObject "DevExpress.XtraEditors.Repository.RepositoryItemTextEdit"
			local checkboxEdit = dotNetObject "DevExpress.XtraEditors.Repository.RepositoryItemCheckEdit"
			local colorPickEdit = dotNetObject "DevExpress.XtraEditors.Repository.RepositoryItemColorEdit"
			
			colorPickEdit.ColorAlignment = colorPickEdit.ColorAlignment.Center
			textEdit.properties.enabled = true
			
			colorPickEdit.ShowDropDown = colorPickEdit.ShowDropDown.Never
			colorPickEdit.ShowCustomColors = false
			colorPickEdit.ShowSystemColors = false
			colorPickEdit.ShowWebColors = false
			colorPickEdit.ShowColorDialog = false
			
			dotNet.addEventHandler textEdit "Leave" editLeaveEvent
			
			treeList = dotNetObject "DevExpress.XtraTreeList.TreeList"
			treeList.Dock = treeList.Dock.Fill
			treeList.OptionsBehavior.editable = true
			treeList.OptionsSelection.MultiSelect = true
			treeList.OptionsView.ShowRoot = true
			treeList.OptionsView.ShowIndicator = false
			treeList.OptionsView.AutoWidth = false
			treeList.OptionsView.ShowHorzLines = false
			treeList.OptionsView.ShowVertLines = false
			treeList.OptionsView.ShowColumns = true
			treeList.OptionsView.ShowFocusedFrame = false
			treeList.TreeLineStyle = treeList.TreeLineStyle.None
		--	treeList.ContextMenuStrip = contextMenuStrip
			
			treeList.RepositoryItems.add textEdit
			treeList.RepositoryItems.add checkboxEdit
			treeList.RepositoryItems.add colorPickEdit
			
			treeList.Appearance.Row.BackColor = getColorDotNet #hilight
			treeList.Appearance.Row.ForeColor = getColorDotNet #text
			treeList.Appearance.Empty.BackColor = getColorDotNet #background  
 			treeList.Appearance.selectedRow.BackColor = getColorDotNet #itemHilight
 			treeList.Appearance.selectedRow.ForeColor = getColorDotNet #text
			treeList.Appearance.FocusedRow.BackColor = getColorDotNet #itemHilight
			treeList.Appearance.FocusedRow.ForeColor = getColorDotNet #text
			treeList.Appearance.FocusedCell.BackColor = getColorDotNet #itemHilight
			treeList.Appearance.FocusedCell.ForeColor = getColorDotNet #text
			
			dotNet.addEventHandler treeList "CellValueChanging" cellValueChangingEvent
			dotNet.addEventHandler treeList "AfterExpand" afterExpandEvent
			dotNet.addEventHandler treeList "AfterFocusNode" afterFocusNodeEvent
			dotNet.addEventHandler treeList "DoubleClick" doubleClickEvent
			dotNet.addEventHandler treeList "Click" clickEvent
			dotNet.addEventHandler treeList "SelectionChanged" selectionChangedEvent
			
			treeList.BeginUpdate()
			for i = 1 to columnNames.count do (
				local column = treeList.Columns.Add()
				column.visible = true
				column.Caption = columnCaptions[i]
				column.Name = columnNames[i]
				column.width = columnWidth[i]
				
				case i of
				(
					default: column.ColumnEdit = checkboxEdit
					1: (
						column.ColumnEdit = textEdit
						column.OptionsColumn.AllowEdit = false
					)
					6: column.ColumnEdit = colorPickEdit
				)
			)
			treeList.EndUpdate()
			
			mainWrapper = dotNetObject "System.Windows.Forms.ToolStripContainer"
			mainWrapper.Dock = mainWrapper.Dock.Fill
			mainWrapper.TopToolStripPanel.controls.add toolstrip
			mainWrapper.ContentPanel.controls.add treeList
			mainWrapper.BackColor = getColorDotNet #background
			
			form = dotNetObject "MaxCustomControls.MaxForm"
			form.size = dotNetObject "System.Drawing.Size" 500 700
			form.controls.add mainWrapper
			form.Text = "Layer Manager Alternative v" + version as string
			form.StartPosition = form.StartPosition.Manual
			loadProperties()
			
			dotNet.addEventHandler form "Closing" done
			
			initCMS()
			initIcons()
		--	requestRefresh()
			refresh()
			registerCallbacks()
			form.ShowModeless()
			
			OK
		),
		
		fn toggle =
		(
			if form == undefined then
				init()
			else
				form.Close()
		)
	)
	
	g_LayerManagerAlternative = s_LayerManagerAlternative()
	g_LayerManagerAlternative.init()
)