try(DestroyDialog OP_EDITOR) catch()
rollout OP_EDITOR "选择面板生成器 | ObjectPicker" width:240 height:550
(
	global fileX = #()
	global bgPath
	global OP
	global OPTimer
	global OPselection = #()
	global OPselectionIND = #()
	global OPstartPos = [0.0,0.0]
	global anyButton = undefined
	global OPmouseCurs = dotnetclass "System.Windows.Forms.Cursor"
	global OPkoef = 1.0
	--------------------------------------------forMove
	global OP_p
	global OP_move = false
	global OPCtrlSave = #()
	global OPposSave = #()
	--------------------------------------------forUndo
	global OP_UNDO = #()
	global OP_UNDOcount = 20
	---------------------------------------------------------EVENTS
	fn OPresize win arg=
	(
		local koef = (win.MaxHeight*0.1)/(win.MaxWidth*0.1)
		win.Height =win.Width*koef
		OPkoef = win.Height/(win.MaxHeight*0.1)
		win.content.children.item[0].Width = (win.MaxWidth*0.1)*OPkoef
		win.content.children.item[0].Height = (win.MaxHeight*0.1)*OPkoef
		win.content.children.item[0].Margin = dotNetObject "System.Windows.Thickness" (win.Width *-0.5) (win.Height*-0.5) 0 0
		for i = 2 to win.content.children.count do
		(
			local bntOne = win.content.children.item[i-1].children.item[0]
			bntOne.Width = fileX[i][3]*OPkoef
			bntOne.Height = fileX[i][4]*OPkoef
			try 
			(
				if bntOne.radiusX != 0.0 then
				(
					bntOne.radiusX = (amin #( bntOne.Width,  bntOne.Height)) * 0.3
					bntOne.radiusY=  (amin #( bntOne.Width,  bntOne.Height)) * 0.3
				)
			)catch()
			bntOne.Margin = dotNetObject "System.Windows.Thickness" (-bntOne.Width*0.5) (-bntOne.Height*0.5) 0 0
			win.content.children.item[i-1].Margin = dotNetObject "System.Windows.Thickness" (fileX[i][1]*OPkoef) (fileX[i][2]*OPkoef) 0 0
			bntOne = win.content.children.item[i-1].children.item[1]
			bntOne.FontSize = fileX[i][12][3]*OPkoef
			bntOne.Margin = dotNetObject "System.Windows.Thickness" ((bntOne.ActualWidth * -0.5) + fileX[i][12][4]*OPkoef ) ((bntOne.ActualHeight * -0.5) + fileX[i][12][5]*OPkoef) 0 0
		)
	)
	fn OPClose win arg=
	(
		OPselection = #()
		OPselectionIND = #()
		OPTimer.Dispose()
		fileX = #()
	)
	fn clickBg =
	(-------------------------------CLICK start
		OPstartPos = OPmouseCurs.Position
		anyButton = #()
		for i = 2 to op.content.children.count do   
		(--traf??????
			if (op.content.children.item[i-1].children.item[0].IsMouseOver == true) do
			(
				anyButton = #(op.content.children.item[i-1].children.item[0], i)
			)
		)
		-----------------------------------------------------------------------------------------------------------------
		if anyButton.count != 0 then
		(--ak ANO
			if (keyboard.AltPressed) or (keyboard.controlPressed) then
			(
				if (keyboard.AltPressed) then
				(
					local found = (findItem OPselection anyButton[1])
					if (found != 0) then
					(
						try
						(
							deleteItem  OPselection found
							deleteItem  OPselectionIND found
						)catch()
					) else()
				)
				if (keyboard.controlPressed) then
				(
					appendifUnique OPselection anyButton[1]
					appendifUnique OPselectionIND anyButton[2]
				)
			)else
			(
				OPselection = #(anyButton[1])
				OPselectionIND = #(anyButton[2])
			)
		)else
		(--ak NIE
			if (keyboard.controlPressed) then () else
			( 
				OPselection=#()
				OPselectionIND = #()
			)
		)
		-----------------------------------------------------------------------------------------------------------------Fsetko Bez Okrajov potom Selekcia s Okrajmi
		for j= 1 to (op.content.children.count-1) do
		(
			op.content.children.item[j].children.item[0].StrokeThickness =0
		)
		for j= 1 to OPselection.count do
		(
			OPselection[j].StrokeThickness = 3
		)
		-----------------------------------------------------------------------------------------------
		if (OP_EDITOR.editBTN.checked != true) then
		(
			-----------------------------------------------------------------------------------------------selection
			deselect objects
			local newSel = #()
			for k = 1 to OPselection.count do
			(
				for j in fileX[OPselectionIND[k]][7] do
				(
					if ((getnodebyname j) != undefined) do (append newSel (getnodebyname j))
				)
			)
			try (select newSel) catch()
			-----------------------------------------------------------------------------------------------move
			if OP_EDITOR.chbM.checked then
			(
				OP_move = false
				OPCtrlSave = #()
				OPposSave = #()
				for i = 1 to OPselection.count do
				(
					OPCtrlSave[i] = #()
					OPposSave[i] = #()
					for j = 1 to fileX[OPselectionIND[i]][7].count do
					(
						try
						(
							OPCtrlSave[i][j] = #()
							OPposSave[i][j] = #()
							OPCtrlSave[i][j][1] = execute ("$" + fileX[OPselectionIND[i]][7][j] + fileX[OPselectionIND[i]][8])
							OPCtrlSave[i][j][2] = execute ("$" + fileX[OPselectionIND[i]][7][j] + fileX[OPselectionIND[i]][10])
							OPposSave[i][j][1] = (OPCtrlSave[i][j][1]).value
							OPposSave[i][j][2] = (OPCtrlSave[i][j][2]).value
						)catch()
					)
				)
			)
		)
		OPTimer.start()
	)
	fn moveBTN =
	(-------------------------------CLICK hold
		OP_p = OPmouseCurs.Position
		if (OP_EDITOR.editBTN.checked) then
		(--if EditMode
			for i = 1 to OPselection.count do
			(
				local newX = fileX[OPselectionIND[i]][1] * OPkoef + (OP_p.x - OPstartPos.x)
				local newY = fileX[OPselectionIND[i]][2] * OPkoef + (OP_p.y - OPstartPos.y)
				OPselection[i].parent.margin = dotNetObject "System.Windows.Thickness"  newX  newY  0 0
			)
		)else
		(--if no EditMode
			if OP_EDITOR.chbM.checked then
			(--if no EditMode and "MOVE" ON
				OP_move = true
				for i = 1 to OPselection.count do
				(
					for j = 1 to fileX[OPselectionIND[i]][7].count do
					(
						try
						(
							OPCtrlSave[i][j][1].value = OPposSave[i][j][1] + (OP_p.x - OPstartPos.x) * fileX[OPselectionIND[i]][9] 
							OPCtrlSave[i][j][2].value = OPposSave[i][j][2] +  (OP_p.y - OPstartPos.y) * fileX[OPselectionIND[i]][11] 
						)catch()
					)
				)
			)
		)
	)
	fn upBg =
	(-------------------------------CLICK end
		OPTimer.Stop()
		for i = 1 to OPselection.count do
		(
			fileX[OPselectionIND[i]][1] = ( OPselection[i].parent.margin.Left / OPkoef )
			fileX[OPselectionIND[i]][2] = ( OPselection[i].parent.margin.Top / OPkoef )
		)
		if (OP_EDITOR.chbM.checked and OP_move) then
		(--if no EditMode and "MOVE" ON
			for i = 1 to OPselection.count do
			(
				for j = 1 to fileX[OPselectionIND[i]][7].count do
				(
					try
					(
						insertItem #(OPCtrlSave, OPposSave) OP_UNDO 1
					)catch()
					OP_UNDO.count = OP_UNDOcount
				)
			)
		)
	)
	fn clickBtn btn arg=
	(
		if (OP_EDITOR.editBTN.checked) then
		(
			OP_EDITOR.sp01.value = btn.Width / OPkoef
			OP_EDITOR.sp02.value = btn.Height / OPkoef
			OP_EDITOR.cp.color = (color btn.Fill.Color.r  btn.Fill.Color.g btn.Fill.Color.b btn.Fill.Color.a)
			local found = undefined
			for i = 1 to (btn.parent.parent.children.count-1) do
			(
				if (btn.parent == btn.parent.parent.children.item[i]) do (found = i)
			)
			OP_EDITOR.et01.text = fileX[found+1][8]
			OP_EDITOR.sp03.value = fileX[found+1][9]
			OP_EDITOR.et02.text = fileX[found+1][10]
			OP_EDITOR.sp04.value = fileX[found+1][11]
			OP_EDITOR.etbtn.text = fileX[found+1][12][1]
			OP_EDITOR.cpTxt.color = fileX[found+1][12][2]
			OP_EDITOR.spBtn01.value = fileX[found+1][12][3]
			OP_EDITOR.spBtn02.value = fileX[found+1][12][4]
			OP_EDITOR.spBtn03.value = fileX[found+1][12][5]
		)else()
	)
	----------------------------------------------------------functions
	fn OPcreateWin bgPath=
	(
		local tokens = filterString bgPath "\\"
		fileX[1] = ""
		for i in tokens do (fileX[1] = fileX[1] + i  + "\\\\")
		fileX[1] = replace fileX[1] (fileX[1].count-1) 2 ""
		------------------------------------------------------------------------------------------------------------------------------ImageSource
		ImageSource = dotnetobject "System.Windows.Media.Imaging.BitmapImage"
		ImageSource.BeginInit()
		ImageSource.UriSource = dotnetobject "System.uri" bgPath
		ImageSource.EndInit()
		------------------------------------------------------------------------------------------------------------------------------bgRec
		bg = dotnetobject "System.Windows.Shapes.rectangle"
		bg.Width = ImageSource.PixelWidth
		bg.Height = ImageSource.PixelHeight
		bg.Fill = dotnetobject "System.Windows.Media.ImageBrush"
		bg.Fill.ImageSource = ImageSource
		------------------------------------------------------------------------------------------------------------------------------mainWin
		op = dotnetobject "System.Windows.Window"
		op.Width = ImageSource.PixelWidth
		op.Height = ImageSource.PixelHeight
		op.MaxWidth =10.0*op.Width
		op.MaxHeight = 10.0*op.Height
		op.WindowStyle = op.WindowStyle.SingleBorderWindow
		wih = dotnetobject "System.Windows.Interop.WindowInteropHelper" op
		wih.owner = dotnetobject "IntPtr" (windows.getmaxhwnd())
		op.Show()
		------------------------------------------------------------------------------------------------------------------------------Canvas
		cv = dotnetobject "System.Windows.Controls.Canvas"
		cv.Width = 1
		cv.Height = 1
		op.content = cv
		cv.Children.Add bg
		bg.Margin = dotNetObject "System.Windows.Thickness" (op.Width *-0.5) (op.Height*-0.5) 0 0
		------------------------------------------------------------------------------------------------------------------------------Timer
		opTimer = dotnetobject "System.Windows.Forms.Timer"
		opTimer.Interval = 50
		dotnet.removeAllEventHandlers opTimer
		dotnet.addEventHandler opTimer "Tick" moveBTN
 
		dotNet.removeAllEventHandlers op
		dotNet.addEventHandler op "SizeChanged" OPresize
		dotNet.addEventHandler op "Closed" OPClose
		dotNet.addEventHandler op "MouseDown" clickBg
		dotNet.addEventHandler op "MouseUp" upBg
	)
	fn OPaddBtn data win =
	(
		if data == undefined then
		(
			data = #(0,0,OP_EDITOR.sp01.value,OP_EDITOR.sp02.value,(OP_EDITOR.cp.color),(OP_EDITOR.ddl.selected),#(),OP_EDITOR.et01.text,OP_EDITOR.sp03.value,OP_EDITOR.et02.text,OP_EDITOR.sp04.value,#( OP_EDITOR.etbtn.text, OP_EDITOR.cpTxt.color, OP_EDITOR.spBtn01.value, OP_EDITOR.spBtn02.value, OP_EDITOR.spBtn03.value))
		)
		local btn
		if (data[6] == "box") do (btn = dotnetobject "System.Windows.Shapes.Rectangle")
		if (data[6] == "circle") do (btn = dotnetobject "System.Windows.Shapes.Ellipse")
		if (data[6] == "round") do
		(
			btn = dotnetobject "System.Windows.Shapes.Rectangle"
			btn.radiusX = (amin #( (data[3]*OPkoef),  (data[4]*OPkoef))) * 0.3
			btn.radiusY=  (amin #( (data[3]*OPkoef),  (data[4]*OPkoef))) * 0.3
		)
		btn.Width = data[3]*OPkoef
		btn.Height = data[4]*OPkoef
		btn.Stroke = dotnetobject "System.Windows.Media.SolidColorBrush"
		btn.Stroke.Color = btn.Stroke.Color.FromArgb 255 255 255 255
		btn.StrokeThickness = 0
		btn.Fill  = dotnetobject "System.Windows.Media.SolidColorBrush"
		btn.Fill.Color = btn.Fill.Color.FromArgb  (data[5].a) (data[5].r) (data[5].g) (data[5].b)
		btn.margin = dotNetObject "System.Windows.Thickness" (btn.Width*-0.5) (btn.Height*-0.5) 0 0
		local newCanvasNum = op.content.Children.Add (dotNetObject "System.Windows.Controls.Canvas")
		win.content.Children.item[newCanvasNum].margin = dotNetObject "System.Windows.Thickness" data[1] data[2] 0 0
		win.content.Children.item[newCanvasNum].Children.add btn
		dotNet.removeAllEventHandlers btn
		dotNet.addEventHandler btn "MouseDown" clickBTN
		dotNet.setLifetimeControl btn #dotnet
		--text
		local txt = dotNetObject "System.Windows.Controls.TextBlock"
		txt.IsHitTestVisible = false
		txt.Text = data[12][1]
		txt.Foreground = dotnetobject "System.Windows.Media.SolidColorBrush"
		txt.Foreground.Color = txt.Foreground.Color.FromArgb  (255) (data[12][2].r) (data[12][2].g) (data[12][2].b)
		txt.FontSize = data[12][3]*OPkoef
		win.content.Children.item[newCanvasNum].Children.add txt
		dotNet.setLifetimeControl txt #dotnet
		txt.margin = dotNetObject "System.Windows.Thickness" ((txt.ActualWidth * -0.5) + data[12][4]*OPkoef ) ((txt.ActualHeight * -0.5) + data[12][5]*OPkoef) 0 0
	)
	button selectBG "从电脑本地选择背景图片" pos:[0,0] width:((OP_EDITOR.width/3.0)*2) height:30 toolTip:"选择窗口背景的图像"
	button ScreenBG "截取视窗" pos:[(OP_EDITOR.width/3.0)*2,0] width:(OP_EDITOR.width/3.0) height:30 toolTip:"获取并保存视口并将其用作背景"
	checkbutton editBTN "激活编辑模式" pos:[0,30] width:(OP_EDITOR.width) height:50 checked:true toolTip:"打开编辑模式"
	button addBtn "添加按钮" pos:[0,80] width:((OP_EDITOR.width/3.0)*2) height:50 toolTip:"添加按钮"
	button remBtn "移除按钮" pos:[(OP_EDITOR.width/3.0)*2,80] width:(OP_EDITOR.width/3.0) height:50 toolTip:"移除按钮"
	button setSel "设置选择物体关联当前所选按钮" pos:[0,130] width:(OP_EDITOR.width) height:40 toolTip:"将所选对象关联到选择的按钮上"
	colorpicker cp pos:[-2,170] width:(OP_EDITOR.width) height:30 alpha:true
	dropdownlist ddl "" pos:[0,200] width:(OP_EDITOR.width) items:#("box", "circle","round") 
	spinner sp01 "按钮宽度" pos:[10,225] width:(OP_EDITOR.width*0.6) range:[10,2000,50] type:#integer
	spinner sp02 "按钮高度" pos:[10,245] width:(OP_EDITOR.width*0.6) range:[10,2000,50] type:#integer
	button btnSend "调整层级" pos:[OP_EDITOR.width*.67,225] width:(OP_EDITOR.width*.3) height:35 toolTip:"切换按钮显示层级"
	edittext etbtn "显示名称" pos:[5,270] width:(OP_EDITOR.width*0.7) text:"" --height:18 
	colorpicker cpTxt pos:[OP_EDITOR.width*0.73,270] width:(OP_EDITOR.width*0.24) height:20 alpha:false color:(color 255 255 255)
	spinner spBtn01 "大小" pos:[25,300] range:[5,200,25] type:#integer width:(OP_EDITOR.width*0.2) 
	spinner spBtn02 "水平" pos:[OP_EDITOR.width*0.4+5,300] range:[-2000,2000,0] type:#integer width:(OP_EDITOR.width*0.2) 
	spinner spBtn03 "垂直" pos:[OP_EDITOR.width*0.7+10,300] range:[-2000,2000,0] type:#integer width:(OP_EDITOR.width*0.2) 
	checkbox chbM "拖拽移动物体" pos:[10,OP_EDITOR.height - 200] toolTip:"拖拽按钮移动对象"
	button btnUndo "回退" pos:[OP_EDITOR.width/2,OP_EDITOR.height - 205] width:(OP_EDITOR.width/2.2) height:30 --visible:false
	edittext et01 "X 轴关联" pos:[5,OP_EDITOR.height - 165] width:(OP_EDITOR.width-90) height:20 labelOnTop:true text:".pos.controller.X_Position.controller" visible:false
	label l01 "系数 X:" pos:[OP_EDITOR.width-75,OP_EDITOR.height - 165] visible:false
	spinner sp03 "" pos:[OP_EDITOR.width-75,OP_EDITOR.height - 145] range:[-2000,2000,0.2] type:#float labelOnTop:true width:70 visible:false
	edittext et02 "Y 轴关联" pos:[5,OP_EDITOR.height - 120] width:(OP_EDITOR.width-90) height:20 labelOnTop:true text:".pos.controller.Z_Position.controller" visible:false
	label l02 "系数 Y:" pos:[OP_EDITOR.width-75,OP_EDITOR.height - 120] visible:false
	spinner sp04 "" pos:[OP_EDITOR.width-75,OP_EDITOR.height - 100] range:[-2000,2000,-0.2] type:#float labelOnTop:true width:70 visible:false
	button testX "测试表达式" pos:[0,(OP_EDITOR.height - 80)] width:(OP_EDITOR.width) height:30 visible:false
	button saveX "保存配置" pos:[0,(OP_EDITOR.height - 50)] width:(OP_EDITOR.width*0.5) height:50 
	button loadX "加载配置" pos:[(OP_EDITOR.width *0.5),(OP_EDITOR.height - 50)] width:(OP_EDITOR.width*0.5) height:50
	on OP_EDITOR open do
	(--on open
		options.PrintAllElements = true
		try (op.close())catch()
		op = undefined
	)
	on OP_EDITOR close do
	(--on close
 
	)
	on selectBG pressed do
	(--use image as bg
		bgPath = getOpenFileName()
		if bgPath != undefined then (OPcreateWin bgPath)else()
	)
	on ScreenBG pressed do
	(--create screen capture as bg
		OPscreen = gw.getViewportDib()
		OPscreen.filename = (getSaveFileName types:"imageFormats(*.jpg)|*.jpg")
		if OPscreen.filename != "" then
		(
			save OPscreen
			bgPath = OPscreen.filename
			OPcreateWin bgPath
		)
		close OPscreen
	)
	on editBTN changed state do
	(--edit mode on
		addBtn.visible = state
		remBtn.visible = state
		cp.visible = state
		ddl.visible = state
		sp01.visible = state
		sp02.visible = state
		btnSend.visible = state
		etbtn.visible = state
		cpTxt.visible = state
		spBtn01.visible = state
		spBtn02.visible = state
		spBtn03.visible = state
		setSel.visible = state
		if chbM.state == true then
		(
			et01.visible = state
			l01.visible = state
			sp03.visible = state
			et02.visible = state
			l02.visible = state
			sp04.visible = state
			testX.visible = state
		)
	)
	on addBtn pressed do
	(--add button
		if op != undefined then
		(
			OPaddBtn undefined op
			append fileX #(0,0,sp01.value/OPkoef,sp02.value/OPkoef,(OP_EDITOR.cp.color),(OP_EDITOR.ddl.selected),#(),(OP_EDITOR.et01.text),(OP_EDITOR.sp03.value),(OP_EDITOR.et02.text),(OP_EDITOR.sp04.value),#((OP_EDITOR.etbtn.text), (OP_EDITOR.cptxt.color), (OP_EDITOR.spBtn01.value/OPkoef), (OP_EDITOR.spBtn02.value/OPkoef), (OP_EDITOR.spBtn03.value/OPkoef)))
		)else()
	)
	on remBtn pressed do
	(--delete button
		if (OP_EDITOR.editBTN.checked) then
		(
			OPselectionIND = sort OPselectionIND
			for i in OPselection do (OPselection[1].parent.parent.children.remove OPselection[1].parent)
			for i = OPselectionIND.count to 1 by -1 do
			(
				deleteItem fileX OPselectionIND[i]
			)
		)
	)
	on cp changed c do
	(--button color
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				OPselection[i].fill.color= (dotNetClass "System.Windows.Media.Color").fromARGB c.a c.r c.g c.b
				for i = 1 to OPselection.count do
				(
					fileX[OPselectionIND[i]][5]=c
				)
			)
		)
	)
	on ddl selected shape do
	(--button shape
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				local btn
				local parentX = OPselection[i].parent
				local txt = dotNetObject "System.Windows.Controls.TextBlock"
				if (ddl.items[shape] == "box") do
				(
					btn = dotnetobject "System.Windows.Shapes.Rectangle"
				)
				if (ddl.items[shape] == "circle") do
				(
					btn = dotnetobject "System.Windows.Shapes.Ellipse"
				)
				if (ddl.items[shape] == "round") do
				(
					btn = dotnetobject "System.Windows.Shapes.Rectangle"
					btn.radiusX = (amin #(OPselection[i].Width, OPselection[i].height)) * 0.3
					btn.radiusY=  (amin #(OPselection[i].Width, OPselection[i].height)) * 0.3
				)
				btn.Width = OPselection[i].Width
				btn.Height = OPselection[i].Height
				btn.Stroke = OPselection[i].Stroke
				btn.StrokeThickness =  OPselection[i].StrokeThickness
				btn.Fill = OPselection[i].Fill
				btn.margin = OPselection[i].margin
				dotNet.removeAllEventHandlers OPselection[i]
				dotNet.addEventHandler btn "MouseDown" clickBTN
				txt.IsHitTestVisible = false
				txt.Text = parentX.children.item[1].Text
				txt.Foreground = parentX.children.item[1].Foreground
				txt.FontSize = parentX.children.item[1].FontSize
				txt.margin = parentX.children.item[1].margin
				parentX.children.add btn
				parentX.children.add txt
				parentX.children.Remove parentX.children.item[0]
				parentX.children.Remove parentX.children.item[0]
				OPselection[i] = parentX.children.item[0]
				fileX[OPselectionIND[i]][6] = ddl.items[shape]
			)
		)
	)
	on sp01 changed val do
	(--button sizeX
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				OPselection[i].Width = val * OPkoef 
				OPselection[i].margin = dotNetObject "System.Windows.Thickness" (-OPselection[i].Width * 0.5) (-OPselection[i].Height* 0.5) 0 0
				fileX[OPselectionIND[i]][3]= val
				try 
				(
					if OPselection[i].radiusX != 0.0 then
					(
						OPselection[i].radiusX = (amin #(OPselection[i].Width, OPselection[i].height)) * 0.3
						OPselection[i].radiusY=  (amin #(OPselection[i].Width, OPselection[i].height)) * 0.3
					)
				)catch()
			)
		)
	)
	on sp02 changed val do
	(--button sizeY
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				OPselection[i].Height = val * OPkoef
				OPselection[i].margin = dotNetObject "System.Windows.Thickness" (-OPselection[i].Width* 0.5) (-OPselection[i].Height * 0.5) 0 0
				fileX[OPselectionIND[i]][4]=val
				try 
				(
					if OPselection[i].radiusX != 0.0 then
					(
						OPselection[i].radiusX = (amin #(OPselection[i].Width, OPselection[i].height)) * 0.3
						OPselection[i].radiusY=  (amin #(OPselection[i].Width, OPselection[i].height)) * 0.3
					)
				)catch()
			)
		)
	)
	on  btnSend pressed do
	(------------------------------------------------------
		try
		(
			local arrN = #()
			local fileXN = #()
			-------------------------------------------------------------create arr of all buttons
			append arrN (copy op.content.children.item[0])
			append fileXN fileX[1]
			-------------------------------------------from arr take selected buttons into arrN 
			for i = 1 to OPselectionIND.count do
			(
				append arrN (copy op.content.children.item[OPselectionIND[i]-1])
				append fileXN fileX[OPselectionIND[i]]
			)
			sort OPselectionIND
			-----------------------------------------------------from arr delete selected buttons
			for i = OPselectionIND.count to 1 by-1 do
			(
				op.content.children.RemoveAt(OPselectionIND[i]-1)
				deleteItem fileX (OPselectionIND[i])
			)
			-------------------------------------------------------------------all but 1 from fileX
			for i = 2 to op.content.children.count do
			(
				append arrN (copy op.content.children.item[i-1])
				append fileXN fileX[i] 
			)
			for i = 2 to op.content.children.count do
			(
				op.content.children.RemoveAt(1)
				deleteItem fileX 2
			)
			op.content.children.clear()
			for i = 1 to arrN.count do
			(
				op.content.children.add arrN[i]
			)
			fileX = deepCopy fileXN
			free arrN
			free fileXN 
		)catch()
	)
	on etbtn changed val do
	(--button name
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				local bntOne = OPselection[i].parent.children.item[1]
				bntOne.Text = val
				bntOne.Margin = dotNetObject "System.Windows.Thickness" ((bntOne.ActualWidth * -0.5) + OP_EDITOR.spBtn02.value * OPkoef ) ((bntOne.ActualHeight * -0.5) + OP_EDITOR.spBtn03.value*OPkoef) 0 0
				fileX[OPselectionIND[i]][12][1]=val
			)
		)		
	)
	on cpTxt changed c do
	(--text color
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				OPselection[i].parent.children.item[1].Foreground.Color = (dotNetClass "System.Windows.Media.Color").fromARGB 255 c.r c.g c.b
 
				for i = 1 to OPselection.count do
				(
					fileX[OPselectionIND[i]][12][2]=c
				)
			)
		)
	)
	on spBtn01 changed val do
	(--button text fontsize
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				local bntOne = OPselection[i].parent.children.item[1]
				bntOne.FontSize = val*OPkoef
				bntOne.Margin = dotNetObject "System.Windows.Thickness" ((bntOne.ActualWidth * -0.5) + fileX[OPselectionIND[i]][12][4] * OPkoef ) ((bntOne.ActualHeight * -0.5) + fileX[OPselectionIND[i]][12][5] * OPkoef) 0 0
				fileX[OPselectionIND[i]][12][3]=val
			)
		)
	)
	on spBtn02 changed val do
	(--button text margin x
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				local bntOne = OPselection[i].parent.children.item[1]
				bntOne.Margin = dotNetObject "System.Windows.Thickness" ((bntOne.ActualWidth * -0.5) + val * OPkoef ) ((bntOne.ActualHeight * -0.5) + OP_EDITOR.spBtn03.value*OPkoef) 0 0
				--OPselection[i].parent.children.item[1].margin = dotNetObject "System.Windows.Thickness" (val * OPkoef) (OP_EDITOR.spBtn03.value * OPkoef) 0 0
				fileX[OPselectionIND[i]][12][4]= val
			)
		)
	)
	on spBtn03 changed val do
	(--button text margin y
				if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				local bntOne = OPselection[i].parent.children.item[1]
				bntOne.Margin = dotNetObject "System.Windows.Thickness" ((bntOne.ActualWidth * -0.5) + OP_EDITOR.spBtn02.value * OPkoef ) ((bntOne.ActualHeight * -0.5) + val*OPkoef) 0 0
				--OPselection[i].parent.children.item[1].margin = dotNetObject "System.Windows.Thickness" (OP_EDITOR.spBtn02.value * OPkoef) ( val * OPkoef) 0 0
				fileX[OPselectionIND[i]][12][5]= val
			)
		)
	)
	on chbM changed theState do
	(--show/Hide for move
		--btnUndo.visible = theState
		if editBTN.state ==true then
		(
			et01.visible = theState
			et02.visible  = theState
			sp03.visible = theState
			sp04.visible = theState
			l01.visible = theState
			l02.visible = theState
			testX.visible = theState
		)
	)
	on btnUndo pressed do
	(--try Undo changes
		try
		(
			for i = 1 to OPselection.count do
			(
				for j = 1 to fileX[OPselectionIND[i]][7].count do
				(
					OP_UNDO[1][1][i][j][1].value = OP_UNDO[1][2][i][j][1]
					OP_UNDO[1][1][i][j][2].value = OP_UNDO[1][2][i][j][2]
				)
			)
			deleteItem OP_UNDO 1
		)catch()
	)
	on setSel pressed do
	(--SetSelection
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				fileX[OPselectionIND[i]][7] = for i in Selection collect i.name
			)
		)
	)
	on et01 changed txt do
	(--button XpressionX
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				fileX[OPselectionIND[i]][8]= txt
			)
		)
	)
	on sp03 changed val do
	(--move koeficient X
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				fileX[OPselectionIND[i]][9]= val
			)
		)
	)
	on et02 changed txt do
	(--button XpressionY
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				fileX[OPselectionIND[i]][10]= txt
			)
		)
	)
	on sp04 changed val do
	(--move koeficient Y
		if (OP_EDITOR.editBTN.checked) then
		(
			for i = 1 to OPselection.count do
			(
				fileX[OPselectionIND[i]][11]= val
			)
		)
	)
	on testX pressed do
	(--try test and add controller to selected objects
		for i = 1 to OPselection.count do
		(
			for j = 1 to fileX[OPselectionIND[i]][7].count do
			(
				try
				(
					if (execute ("$" + fileX[OPselectionIND[i]][7][j] + fileX[OPselectionIND[i]][8]))==undefined then
					(
						try (execute ("$" + fileX[OPselectionIND[i]][7][j] + fileX[OPselectionIND[i]][8] + "= Bezier_Float()"))catch(messageBox "problemCreatingXController")
					)
				)catch(messageBox "problemX")
				try
				(
					if (execute ("$" + fileX[OPselectionIND[i]][7][j] + fileX[OPselectionIND[i]][10]))==undefined then
					(
						try (execute ("$" + fileX[OPselectionIND[i]][7][j] + fileX[OPselectionIND[i]][10] + "= Bezier_Float()"))catch(messageBox "problemCreatingYController")
					)
				)catch(messageBox "problemY")
			)
		)
	)
	on saveX pressed do
	(--save fileX
		out_name = getSaveFileName()
		if (out_name != undefined) then
		(
			out_file = createfile out_name
			print fileX to:out_file
			close out_file
		)
	)
	on loadX pressed do
	(--load fileX and create win 
		try
		(
			fileX = #()
			fs = openFile (getOpenFileName())
			while not eof fs do
			(
				append fileX (execute (readline fs))
			)
			close fs
			OPcreateWin fileX[1]
			OPkoef = 1.0
			for i = 2 to fileX.count do
			(
				OPaddBtn fileX[i] op
			)
			op.height = op.height-1
		)catch()
	)
)
createdialog  OP_EDITOR style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
--minimize OP window
--resize just after load to update text size and pos
--use lesser value from height or width for round edges and roundness set on 0.3
--bigger ADD and REM
--correct send back in multisellect