UiRun = True
(--BEGIN
clearlistener()
/*PEROPERTIES-------------------------------------------------------------------------*/
	--CurrentSelections
	CurrentSelection = #()
	SelectedButtons=#()
	ButtonWrapperArray = #()

	CurrentSelectionTemp = #()
	ButtonWrapperArrayTemp = #()
	SelectedButtonsTemp = #()
	--Declare Ibutton Array For Store Every button creates at runtime
		ButtonArray = #()
	--Ibutton Array Index
		BtnArrayIndex =1
	--Ibutton Text Counter
		ICount = 1
	--Current Selected Button
		Current_Control
	--X Location Diff & Y Location Diff
	XDiff = #()
	YDiff = #()
	-- WorkType MoveResize / Move / Locked
	Worktype
 	--FormValues Fetch From Xml
		CharacterName=""
		Panel_Char_BackImagePath=""
		FormX=800
		FormY=600
	--Move Or Resize Class Dll Path
-- 	/*HOME   */  DllPath = @"D:\Projects\Dynamic UI\DotNet_Side\UiFramworkLibrary\UiFramworkLibrary\bin\Debug\UiFramworkLibrary.dll"
-- 	/*OFFICE */  DllPath = @"D:\Dynamic UI\DotNet_Side\UiFramworkLibrary\UiFramworkLibrary\bin\Debug\UiFramworkLibrary.dll"
-- 	/*Laptop */  DllPath = @"D:\Maxscript+Dotnet\Dynamic UI\DotNet_Side\UiFramworkLibrary\UiFramworkLibrary\bin\Debug\UiFramworkLibrary.dll"
	fn existFlie Fname = (getfiles Fname).count!=0
	MaxRoot = getDir #MaxRoot
	if existFlie ((getDir #scripts) + "\\BulletScripts\\Res" + "\UiFramworkLibrary.dll") then 
	(
		DllPath = (getDir #scripts) + "\\BulletScripts\\Res" + "\UiFramworkLibrary.dll"
	)
	else
	 (
		CurrentPath = sysinfo.currentdir
		print CurrentPath 
		if existFlie ("D:\Projects\Dynamic UI\DotNet_Side\UiFramworkLibrary\UiFramworkLibrary\bin\Debug" + "\UiFramworkLibrary.dll") then
			(
				copyfile "D:\Projects\Dynamic UI\DotNet_Side\UiFramworkLibrary\UiFramworkLibrary\bin\Debug" (Maxroot + "\UiFramworkLibrary.dll")
				DllPath = Maxroot + "\UiFramworkLibrary.dll"
			)
			else if existFlie (CurrentPath + "\UiFramworkLibrary.dll") then
			(
				copyfile (CurrentPath + "\UiFramworkLibrary.dll") (Maxroot + "\UiFramworkLibrary.dll")
				DllPath = Maxroot + "\UiFramworkLibrary.dll"
			)
			else if existFlie ("\UiFramworkLibrary.dll") then
			(
				copyfile ("\UiFramworkLibrary.dll") (Maxroot + "\UiFramworkLibrary.dll")
				DllPath = Maxroot + "\UiFramworkLibrary.dll"
			)
 		 else
			(
				Messagebox "Please Copy The UiFramworkLibrary.dll To Your 3dsmax Root Folder"
				exit
			)
	 )
	/*-- Main Dotnet Form ----------------------------------------------------------------------------------------------------------*/
		--Form = (dotNetObject "System.Windows.Forms.Form") 
		--dn = dotnet.loadAssembly @"C:\Program Files\Autodesk\3ds Max 2014\MaxCustomControls.dll"
		Form = dotNetObject "MaxCustomControls.MaxForm"
		thePtr = DotNetObject "System.IntPtr" (windows.getMAXHWND())
	-- 	MaxV = maxVersion() 
		try (theHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" thePtr)catch()
		
		--Keyboard Key Pressed Detection Con
		con = dotnetclass "system.windows.forms.control"

	/*-- Split Form -- Ribbons Contols FlowLayoutPanel --------------------------------------------*/
		SplitContainer = (dotNetObject "System.Windows.Forms.SplitContainer")
			SplitContainer.SplitterWidth = 3
			SplitContainer.SplitterDistance = 110
	/*-- Tools Buttons Container -- Ribbons Contols FlowLayoutPanel --------------------------------------------*/
		RibbonPanel = (dotNetObject "System.Windows.Forms.FlowLayoutPanel") --FlowLayoutPanel
		RibbonPanelBtnSizeX = 60
		RibbonPanelBtnSizeY = 60
	/*-- Buttons Property Panel Container -- FlowLayoutPanel --------------------------------------------*/
		--PropertiesPanel = (dotNetObject "System.Windows.Forms.Panel")
		--PropertyGrid = (dotnetobject "System.Windows.Forms.PropertyGrid" ---------------$$$
			
--formatProps PropertyGrid
/*METHODS----------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------ Dotnet Wrappers ------------------------------------------------------------------------------------------------------------------------------------*/
	fn formatProps sender option:#All= 
	(
		clearlistener()
		if classof sender == dotnetobject or classof sender == dotnetclass then 
		(
			if option==#All or option==#constructor do
			(
				format "\nConstructors =================================================================== : \n"
				dotnet.showConstructors sender
			)
			if option==#All or option==#properties do
			(
				format "\nPeroperties =====================================================================: \n"
				showproperties sender
			)
			if option==#All or option==#methods do
			(
				format "\nMethods =====================================================================: \n"
				showmethods sender
			)
			if option==#All or option==#events do
			(
				format "\nEvents =====================================================================: \n"
				showevents sender
			)
		)else (format "Not a DotnetObject or DotnetClass!:%\n" sender)
	)
	fn DnRect p:[0,0] s:[10,10] = ((dotnetobject "system.drawing.rectangle" p.x p.y s.x s.y))
	fn DnSize s:[10,10]=(return (dotNetObject "system.drawing.size" s.x s.y))
	fn DnPoint p:[0,0]=(dotNetObject "system.drawing.Point" p.x p.y)
	fn DnColorARGB a:255 r:255 g:255 b:255  = ((dotnetclass "system.drawing.color").fromArgb a r g b)
	fn DnColor C:[255,255,255] a:255 		= ((Dotnetclass "system.drawing.color").fromArgb a c.x c.y c.z)
	fn DnLoadBitmap FilePath Filename= (return((DotNetClass "system.drawing.bitmap").fromFile(FilePath+Filename)))
/*==============================================================================================================================*/
--Value Convertors-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
/*==============================================================================================================================*/
	--Convert The Dotnet Color Class ARGB To String Formated Value 
	--DnColorToCString / CStringToDnColor / DnLocationToString / StringToDnLocation /DnSizeToString /StringToDnSize
	
	fn DnColorToCString DnColor= 
	(
			CString =""
			CString+= (DnColor.a as string) + ","
			CString+= (DnColor.r as string) + ","
			CString+= (DnColor.g as string) + ","
			CString+= (DnColor.b as string)
			return CString
	)
	--Parse The String Formated Value To Dotnet Color Class ARGB Object 
	fn CStringToDnColor CString= 
	(
			ColorArray = filterString CString ","
			A = ColorArray[1] as integer
			R = ColorArray[2] as integer
			G = ColorArray[3] as integer
			B = ColorArray[4] as integer
			TempColor = DnColor C:[R,G,B] a:A
			return TempColor
	)
	--Location To String Ibutton.size.Width as string +","+Ibutton.size.Height as string
	fn DnLocationToString Location= 
	(
		LString = (Location.x as string ) + "," + (Location.y as string )
		return LString
	)
	--Parse The String Formated Value To Dotnet Point [x,y] Object 
	fn StringToDnLocation LString= 
	(
		if LString != undefined and LString!="" then
		(
			LArray = filterString LString ","
			x = LArray[1] as integer
			y = LArray[2] as integer
			Location = DnPoint p:[x,y]
			return Location
		)else
		(
			Location = DnPoint p:[50,50]
			return Location
		)
	)
	--Dn Size to String
	fn DnSizeToString DnSize= 
	(
		LString = (DnSize.Width as string ) + "," + (DnSize.Height as string )
		return LString
	)
	--Parse The String Formated Value To Dotnet Point [x,y] Object 
	fn StringToDnSize LString= 
	(
		LArray = filterString LString ","
 		x = LArray[1] as integer
 		y = LArray[2] as integer
		MySize = DnSize s:[x,y]
 		return MySize
	)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Form Control COLORS---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	RibbonPanel_BackColor = DnColor C:[150,150,150]
	PropertiesPanel_BackColor = DnColor C:[200,200,200]
	RibbonButtons_BackColor = DnColor C:[250,250,250]
	PanelChar_BackColor = DnColor C:[50,50,50]
--Buttons Initialize Function----------------------------------------------------------------------------------------
	fn ButtonInit RButton RBtnName BackColor SizeX:90 Sizey:60 = 
		(
			--RButton = dotNetObject "System.Windows.Forms.Button"
			RButton.size = dotNetObject "System.Drawing.Size" SizeX Sizey
			RButton.text = RBtnName
			RButton.location = dotNetObject "System.Drawing.Point" 0 0
			RButton.BackColor = BackColor
			RButton.Anchor = RButton.Anchor.top.left.right.bottom
			RButton.FlatStyle = RButton.FlatStyle.Flat
			RButton.Margin.all = 0
			--formatProps RButton.Margin
			--TempBtn = dotNetObject "System.Windows.Forms.Button"
			--formatProps TempBtn			
		)
--Screen Capture Methods----------------------------------------------------------------------------------------		

---------------------------- Load Dll Assembly On The Fly ------------------- We Can Change the Dll Without Need To Restart 3dsmax :) :) -----------------------
	fn LoadDllOntheFly DllPath ClassType= 
		(
			assemblypath = DllPath
			UIAssembly = (dotnetclass "System.Reflection.assembly").load ((dotnetclass "System.IO.File").ReadAllBytes assemblypath)
			DotNetType = UIAssembly.GetType (ClassType)
			ClassInstance = (dotnetclass "System.Activator").CreateInstance DotNetType
			gc() -- Deactivate Garbage Collector
			--clearlistener()
			Return ClassInstance
		)
	--Create an Instance Of Partial And Internal Classes
	Local ControlMoveAndResizeClass = LoadDllOntheFly DllPath "UiFramworkLibrary.ControlMoverOrResizer"
		Worktype = ControlMoveAndResizeClass.WorkType.MoveAndResize
		
-- 	Local MultipleMover = LoadDllOntheFly DllPath "UiFramworkLibrary.ControlMover"
-- 		formatProps ControlMoveAndResizeClass
	Local GraphicButton = LoadDllOntheFly DllPath "UiFramworkLibrary.GraphicButton"
	
	Local PropertyGrid = LoadDllOntheFly DllPath "UiFramworkLibrary.CustomPropertyGrid"
	-- 	formatProps ControlMoveAndResizeClass
		--formatProps GraphicButton
/*--Character Selection Panel -Ibuttons Container-------------------------------------------------------------------*/
		--Panel_Char = (dotNetObject "System.Windows.Forms.Panel")
		
		Local Panel_Char = LoadDllOntheFly DllPath "UiFramworkLibrary.CustomPanel"
		--Local Panel_Char_ImageBox = LoadDllOntheFly DllPath "UiFramworkLibrary.CustomImageBox"
		ControlMoveAndResizeClass.IContainer = Panel_Char
		
		Panel_Char_BackImagePath=""
-- 		formatProps Panel_Char_ImageBox
/*----------------------------------------------------------------------------*/
/*------------------Create Context Menu For Right Click--------------------------------------*/
/*-------------------------------------------------------------------------------------------------------------------------------------*/		
	/*RightClick Event Handlers -------------------------------------------------------*/
		fn Null = ()
		fn PickObj Sender Arg = 
			(
				--Sender is the Menu Item "Pick Object"-------------------------
				--Sender.Tag Is the Button we RightClicked at-----------------
				--pickObject count:#multiple forceListenerFocus:false
				--print "------------------------------------ Sender ------------------"
				--formatProps Sender
				--print Sender.tag.text
				--fn ObjFilter o = (superclassof o == Geometryclass)
				x = pickObject Prompt:"Pick Object" --filter:ObjFilter
				Obj = #()
				if x!=undefined do 
					(
						Appendifunique Obj x.name
						Ibutton = Sender.tag
						-- Convert Obj defenition To DotnetObject And Store It On Ibutton.Tag 
						Ibutton.tag = DotNetMxsValue Obj
						--formatProps Ibutton.tag
						print Ibutton.tag.value
						gc()
					)
			)
		fn PickMultiObj Sender Arg = 
			(
				--Sender is the Menu Item "Pick Object"-------------------------
				--Sender.Tag Is the Button we RightClicked at-----------------
				--pickObject count:#multiple forceListenerFocus:false
				--print "------------------------------------ Sender ------------------"
				--formatProps Sender
				--print Sender.tag.text
				Objs = #()
				Obj = pickObject Prompt:"Pick Multiple Objects" count:#multiple
				if (classof Obj)==array do 
					(
						for x in Obj do Appendifunique Objs x.name
						Ibutton = Sender.tag
						-- Convert Obj defenition To DotnetObject And Store It On Ibutton.Tag 
						Ibutton.tag = DotNetMxsValue Objs
						print Ibutton.tag.value
						--formatProps Ibutton.tag
						gc()
					)
			)
		-- STORE Button Data As A Struct To Copy And Past The Buttons Attributes
			struct CopyTo
			(
				ILocation = DnPoint p:[150,150],
				ISize = DnSize s:[30,30],
				IThickness = 5,
				
				IButtonTypeSrting = "Circle",
				IBorderColor = DnColor c:[255,255,255] a:255,
				IInsideColor= DnColor c:[0,0,0] a:255,
				ISelectColor= DnColor c:[0,255,0] a:255,
				ITextColor = DnColor c:[255,255,255] a:255,
				IGradAngle= 180,
				IRadius= 30,
				fn CopyToClipboard MButtonTypeSrting MLocation Msize MThickness MBorderColor MInsideColor MSelectColor MTextColor MGradAngle MRadius= 
					(
						this.ILocation = MLocation
						this.ISize = Msize
						this.IThickness = MThickness
						
						this.IBorderColor = MBorderColor
						this.IInsideColor = MInsideColor
						this.ISelectColor = MSelectColor
						this.ITextColor = MTextColor
						
						this.IGradAngle = MGradAngle
						this.IRadius = MRadius
						this.IButtonTypeSrting = MButtonTypeSrting
					),
				fn IPrint =
					(
						Format "LocationX :%    LocationY: % \n" this.ILocation.x this.ILocation.y
						Format "SizeX :%    SizeY: % \n" this.ISize.Width this.ISize.Height
						Format "Color R:% G:% B:% \n" this.IBorderColor.r this.IBorderColor.g this.IBorderColor.b
						Format "Thickness :% \n" this.IThickness
					)
			)--End Struct 
			MyCopyPaste = CopyTo()
	/*CopyToClipboard Event Handler---------------------------------------------------------------------------------------------------------------------------------------------------*/
		fn CopyToClipboard Sender Arg= 
			(
				Ibutton = Current_Control
				MyCopyPaste.CopyToClipboard IButton.ButtonTypeSrting IButton.Location IButton.Size IButton.Borderthick IButton.IBorderColors IButton.IInsideColors \
											IButton.ISelectedColor IButton.ITextColor IButton.GradientAngle IButton.Radius
				--MyCopyPaste.IPrint()
			)
	/*Paste ToClipboard Event Handler---------------------------------------------------------------------------------------------------------------------------------------------------*/			
		fn Paste Sender Arg= 
			(
				appendifunique SelectedButtons Current_Control
				for IButton in SelectedButtons do
				(
-- 					IButton = Current_Control
					--IButton.ButtonType = MyCopyPaste.IButtonType
					IButton.Size = MyCopyPaste.ISize
					IButton.Borderthick = MyCopyPaste.IThickness
					
					IButton.IBorderColors = MyCopyPaste.IBorderColor
						IButton.BackColor = MyCopyPaste.IBorderColor
					IButton.IInsideColors = MyCopyPaste.IInsideColor
						IButton.ForeColor = MyCopyPaste.IInsideColor
					IButton.ISelectedColor = MyCopyPaste.ISelectColor
					IButton.ITextColor = MyCopyPaste.ITextColor 
					
					IButton.GradientAngle = MyCopyPaste.IGradAngle
					IButton.Radius = MyCopyPaste.IRadius
					case MyCopyPaste.IButtonTypeSrting of
						(
							"Circle":(IButton.ButtonType = IButton.ButtonType.CircleButton;break)
							"Curve":(IButton.ButtonType = IButton.ButtonType.CurveButton;break)
							"HalfCircle":
							(
								IButton.ButtonType = IButton.ButtonType.HalfCircleButton;break
-- 								try
-- 									(
-- 										IButton.HCStartAngle =  HCStartAngle
-- 										IButton.HCSweepAngle = HCSweepAngle
-- 										IButton.HCThick = HCThick
-- 									)catch()
							)
							"Rectanlge":(IButton.ButtonType = IButton.ButtonType.RectanlgeButton;break)
							"RoundRectanlge":(IButton.ButtonType = IButton.ButtonType.RoundRectanlgeButton;break)
							default:(IButton.ButtonType = IButton.ButtonType.CircleButton;break)
						)
-- 					formatprops IButton
					IButton.Invalidate
					Current_Control.Invalidate
				)
			)
		fn PasteFromClipboardX Sender Arg= 
			(
				appendifunique SelectedButtons Current_Control
				for IButton in SelectedButtons do
				(
					IButton.Location.x = (SplitContainer.Panel1.Size.Width)-(MyCopyPaste.ILocation.x)--+(RibbonPanel.size.width)
				)
			)
		fn PasteFromClipboardY Sender Arg= 
			(
				--IButton = Current_Control
				appendifunique SelectedButtons Current_Control
				for IButton in SelectedButtons do
				(
					--IButton.Location.x = MyCopyPaste.ILocation.x
					IButton.Location.y = ((SplitContainer.Panel1.Size.Height)-(MyCopyPaste.ILocation.y))
				)
			)
		fn AlignX Sender Arg= 
			(
					appendifunique SelectedButtons Current_Control
					for IButton in SelectedButtons do
					(
						IButton.Location.x = MyCopyPaste.ILocation.x + (MyCopyPaste.ISize.Width/2) - (IButton.Size.Width/2)
					)
			)
		fn AlignY Sender Arg= 
			(
				appendifunique SelectedButtons Current_Control
				for IButton in SelectedButtons do
				(
					IButton.Location.y = MyCopyPaste.ILocation.y + (MyCopyPaste.ISize.Height/2) - (IButton.Size.Height/2)
				)
			)
		fn EvenDistanceX Sender Arg= 
			(
				NumberOfBtns = SelectedButtons.Count
				MinX = 100000;		MinY = 100000
				MaxX = 0  ; 		MaxY = 0 
				FirstXBtn; LastXBtn; FirstYBtn; LastYBtn
				--Counting Minimum and Maximum X & Y of All Selected Buttons
				for IButton in SelectedButtons do
				(
					if IButton.PositionX < MinX do MinX = IButton.PositionX --Min X
					if IButton.PositionX > MaxX do MaxX = IButton.PositionX --Max X
					if IButton.PositionY < MinY do MinY = IButton.PositionY --Min Y
					if IButton.PositionY > MaxY do MaxY = IButton.PositionY --Max Y
				)
				--Define First Button And Last Button on X Axis &&&& --Define First Button And Last Button on Y Axis
				for IButton in SelectedButtons do
				(
					if IButton.PositionX == MinX do FirstXBtn = IButton
					if IButton.PositionX == MaxX do LastXBtn = IButton
					if IButton.PositionY == MinY do FirstYBtn = IButton
					if IButton.PositionY == MaxY do LastYBtn = IButton
				)
				DifX = MaxX-MinX -- - FirstXBtn.ISizeWidth
				DifY = MaxY-MinY -- - FirstYBtn.ISizeHeight
-- 				format "MinX = % \nMaxX = % \nDifX = % \nMinY = % \nMaxY = % \nDifY = % \n" MinX MaxX DifX MinY MaxY DifY
				-- Positioning in X axis
				k = 1
				for IButton in SelectedButtons do
				(
					if (IButton != FirstXBtn) and (IButton != LastXBtn) do 
					(
						IButton.PositionX = MinX + ((DifX/(NumberOfBtns-1))*k) 
-- 						format "Ibutton.position = %\n" IButton.PositionX
						k=k+1
					)
				)
			)
			fn EvenDistanceY Sender Arg= 
			(
				NumberOfBtns = SelectedButtons.Count
				MinX = 100000;		MinY = 100000
				MaxX = 0  ; 		MaxY = 0 
				FirstXBtn; LastXBtn; FirstYBtn; LastYBtn
				
				--Counting Minimum and Maximum X & Y of All Selected Buttons
				for IButton in SelectedButtons do
				(
					if IButton.PositionX < MinX do MinX = IButton.PositionX --Min X
					if IButton.PositionX > MaxX do MaxX = IButton.PositionX --Max X
					
					if IButton.PositionY < MinY do MinY = IButton.PositionY --Min Y
					if IButton.PositionY > MaxY do MaxY = IButton.PositionY --Max Y
				)
				--Define First Button And Last Button on X Axis &&&& --Define First Button And Last Button on Y Axis
				for IButton in SelectedButtons do
				(
					if IButton.PositionX == MinX do FirstXBtn = IButton
					if IButton.PositionX == MaxX do LastXBtn = IButton
					
					if IButton.PositionY == MinY do FirstYBtn = IButton
					if IButton.PositionY == MaxY do LastYBtn = IButton
				)
				DifX = MaxX-MinX -- - FirstXBtn.ISizeWidth
				DifY = MaxY-MinY -- - FirstYBtn.ISizeHeight
				-- Positioning in X axis
				k = 1
				for IButton in SelectedButtons do
				(
					if (IButton != FirstYBtn) and (IButton != LastYBtn) do 
					(
						IButton.PositionY = MinY + ((DifY/(NumberOfBtns-1))*k)--+(IButton.ISizeHeight/2)
						k=k+1
					)
				)
			)
			fn MaxToMinScale Sender Arg= 
			(
				NumberOfBtns = SelectedButtons.Count
				MinX = 100000;		MinY = 100000
				MaxX = 0  ; 		MaxY = 0 
				FirstXBtn; LastXBtn; FirstYBtn; LastYBtn
				
				--Counting Minimum and Maximum X & Y of All Selected Buttons
				for IButton in SelectedButtons do
				(
					if IButton.ISizeWidth < MinX do MinX = IButton.ISizeWidth --Min Width
					if IButton.ISizeWidth > MaxX do MaxX = IButton.ISizeWidth --Max Width
					
					if IButton.ISizeHeight < MinY do MinY = IButton.ISizeHeight --Min Height
					if IButton.ISizeHeight > MaxY do MaxY = IButton.ISizeHeight --Max Height
				)
				--Define First Button And Last Button on X Axis &&&& --Define First Button And Last Button on Y Axis
				for IButton in SelectedButtons do
				(
					if IButton.ISizeWidth == MinX do FirstXBtn = IButton
					if IButton.ISizeWidth == MaxX do LastXBtn = IButton
					
					if IButton.ISizeHeight == MinY do FirstYBtn = IButton
					if IButton.ISizeHeight == MaxY do LastYBtn = IButton
				)
				DifX = MaxX-MinX -- - FirstXBtn.ISizeWidth
				DifY = MaxY-MinY -- - FirstYBtn.ISizeHeight
				-- Positioning in X axis
				k = 1
				for IButton in SelectedButtons do
				(
					if (IButton != FirstYBtn) and (IButton != LastYBtn) do 
					(
						IButton.ISizeWidth = MinX + ((DifX/(NumberOfBtns-1))*k) 
						IButton.ISizeHeight = MinY + ((DifY/(NumberOfBtns-1))*k) 
						k=k+1
					)
				)
			)
	/*Delete Control Event Handler---------------------------------------------------------------------------------------------------------------------------------------------------*/			
		fn DeleteMe Sender Arg= 
			(
				--yesNoCancelBox "Are You Sure !?"
				--queryBox  "queryBox"
				--messagebox "messagebox"
				if SelectedButtons.count < 2 then 
				(
					RemoveBox = queryBox "Are you Sure You want to Remove ?" beep:false 
					if RemoveBox == true then
					(
						Panel_Char.Controls.Remove(Current_Control)
						PropertyGrid.SelectedObject = Panel_Char.GetWrapper
						ICount-=1
					)
					else 
					(
						print "Cancle Remove"
					)
				)else
				(
					RemoveBox = queryBox "Are you Sure You want to Remove All Selected Buttons ?" beep:false 
					if RemoveBox == true then
					(
						for IButton in SelectedButtons do
						(
							Panel_Char.Controls.Remove(IButton)
							PropertyGrid.SelectedObject = Panel_Char.GetWrapper
							ICount-=1
						)
					)
					else
					(
						print "Cancle Remove"
					)
				)
			)
	/*Here I Create RightClick Menu  (ContextMenu)  -------------------------------------------------------*/	
		fn GetMenu IButton= 
		(
			Names = #("&Pick Object","&Pick Multiple Object","-","&Copy","Paste","-","&PasteMirror X","&PasteMirror Y","Align X","Align Y","EvenDistanceX","EvenDistanceY","MaxToMinScale","Delete Me")
			EventHandlers = #(PickObj,PickMultiObj,Null,CopyToClipboard,Paste,Null,PasteFromClipboardX,PasteFromClipboardY,AlignX,AlignY ,EvenDistanceX,EvenDistanceY,MaxToMinScale,DeleteMe)
			Events = #("Click","Click","Click","Click","Click","Click","Click","Click","Click","Click","Click","Click","Click","Click")
			cm = (dotnetobject "System.Windows.Forms.ContextMenu")

			for i= 1 to Names.count do
				(
					--Add menu items
					MI = cm.MenuItems.add names[i]
					-- i Store The Button Name On The Menu Items Tag 
					Mi.tag = IButton
					dotnet.addeventhandler mi events[i] EventHandlers[i]
					dotnet.setlifetimecontrol mi #dotnet
				)
			return cm
		)
/*----------------------------------------------------------------------------------------------------------------------------*/
/*------------------Add a Graphic Button To Form And Keep it To Button Array-------------------*/
/*---------------------------------------------------------------------------------------------------------------------*/
	fn AddButton IName ButtonType:"Circle" PosX:100 PosY:100 SizeX:50 SizeY:50 BorderThick:5  TextColor:undefined alphas:255 GradAngle:180 Tag:Undefined Radius:20 \
				       BorderColor:(dncolor c:[148,148,255] a:255) InsideColor:(dncolor c:[128,128,255] a:255) SelectColor:(dncolor c:[0,255,0] a:255) HCThick:15 HCSweepAngle:180 HCStartAngle:0 \
					   ItagScr:""=
		(
		--Declare One IButton /*---------------------------------------------------------------------------------------------------------------------------------------------------------*/
			IButton = LoadDllOntheFly DllPath "UiFramworkLibrary.GraphicButton" --IButton = dotnetobject "UiFramworkLibrary.GraphicButton"
			if IName!=undefined then IButton.text = (IName as String) else IButton.text = "B"
			IButton.IMaxScript = ItagScr as String
			IButton.size = dotNetObject "System.Drawing.Size" SizeX SizeY
			IButton.location = dotNetObject "System.Drawing.Point" PosX PosY
			IButton.MinimumSize = DnSize s:[20,20]
			IButton.IBorderColors = BorderColor--DnColor C:BorderColor a:alphas BackColor
			IButton.IInsideColors = InsideColor--DnColor C:InsideColor a:alphas ForeColor
			IButton.ISelectedColor = SelectColor--DnColor C:SelectColor a:alphas Appreience BorderColor
			IButton.ITextColor = TextColor --DnColor C:TextColor a:alphas
			IButton.BorderThick = BorderThick
			IButton.GradientAngle = GradAngle
			IButton.Radius = Radius
			case ButtonType of
			(
				"Circle":(IButton.ButtonType = IButton.ButtonType.CircleButton;break)
				"Curve":(IButton.ButtonType = IButton.ButtonType.CurveButton;break)
				"HalfCircle":
				(
					IButton.ButtonType = IButton.ButtonType.HalfCircleButton;break
					try
						(
							IButton.HCStartAngle =  HCStartAngle
							IButton.HCSweepAngle = HCSweepAngle
							IButton.HCThick = HCThick
						)catch()
				)
				"Rectanlge":(IButton.ButtonType = IButton.ButtonType.RectanlgeButton;break)
				"RoundRectanlge":(IButton.ButtonType = IButton.ButtonType.RoundRectanlgeButton;break)
				default:(IButton.ButtonType = IButton.ButtonType.CircleButton;break)
			)
			
			IButton.Tag = Tag
			
		--Set RightClick Menu/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/
			IButton.Contextmenu = GetMenu IButton
		-- Initialize Move And Resize For IButton/*--------------------------------------------------------------------------------------------------------------------------------*/
			ControlMoveAndResizeClass.Init IButton
			ControlMoveAndResizeClass.Worktype = Worktype
			append ButtonArray IButton
			BtnArrayIndex +=1
			return IButton
		)
-- COLORING Selected Controller in a container / Iselected is a array of Controls
		fn Selected_Controls_Color IContainer ISelected = 
		(
			for i = 0 to IContainer.controls.Count-1 do
			(	
				try 
					(
						IButton = Panel_Char.controls.item[i]
						Ibutton.IsSelected = False
					)
				catch()
			)
			for x in ISelected do
			(
				x.IsSelected = True
			)
		)
/*----------------------------------------------------------------------------*/
/*------------------EVENT HANDLERS--------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
/* "IButtons" are the Buttons we going toadd at runtime*/ 
	fn IButton_MouseDown Sender arg= 
	(
		/* Seperate LeftClick /Right Click /MiddleClick ----------------------------------------------------------------------*/
		case arg.Button of
		(
			(arg.Button.Left):
			(

				--formatprops sender
				--print (sender.Itag as string)
				sender.BringToFront()
				--PropertyGrid.SelectedObject = Sender.GetWrapper
				--format "\nX:% Y:%\nSX:% SY:%\n-----------" sender.location.x sender.location.y sender.size.Width (sender.size).Height 
				try (obj = (Sender.tag.value as array) )catch()

					--************ KeyBoard Check ************ ----------------
					--Check Keyboard CTRL Key is Pressed Or Not
					-- Keyboard Active Ctrl or Alt
					con = dotnetclass "system.windows.forms.control"
					--formatprops con.modifierKeys
					
					case (con.modifierKeys) of 
						(
							(con.modifierKeys.Control):
							(
								--Check If There is Group Selection In The Button 
								appendifunique SelectedButtons sender
								appendifunique ButtonWrapperArray sender.GetWrapper
								PropertyGrid.SelectedObjects = ButtonWrapperArray
								if obj != undefined do 
								(
									for x in obj do
										appendifunique CurrentSelection (getnodebyname x)
								)
								try 
									(
										undo on (select CurrentSelection )
									)
								catch()
								break;
							)
							--------------------------------------------------------------------------------
							(con.modifierKeys.Shift) :
							(
								--Check If There is Group Selection In The Button 
								appendifunique SelectedButtons sender
								appendifunique ButtonWrapperArray sender.GetWrapper
								if obj != undefined do 
								(
									for x in obj do
										appendifunique CurrentSelection (getnodebyname x)
								)
								print ButtonWrapperArray
								PropertyGrid.SelectedObjects = ButtonWrapperArray
								try (undo on (select CurrentSelection)) catch()
								break;
							)
							--------------------------------------------------------------------------------
							(con.modifierKeys.Alt):
							(
								removeBtnIndex = finditem SelectedButtons sender
								if removeBtnIndex!=0 do
									(
										deleteItem SelectedButtons removeBtnIndex
										deleteItem ButtonWrapperArray removeBtnIndex
									)
								if obj!=undefined then
								(
									for x in obj do
									(
										removeObjIndex = finditem CurrentSelection (getnodebyname x)
										if removeObjIndex!=0 do
										(
											undo on (deselect CurrentSelection)
											deleteItem CurrentSelection removeObjIndex 
										)
									)
								)else
								(
									if removeBtnIndex!=0 do
									(
										undo on (deselect CurrentSelection)
										try(deleteItem CurrentSelection removeBtnIndex) catch()
										try( deleteItem SelectedButtons removeBtnIndex) catch()
										try( deleteItem ButtonWrapperArray removeBtnIndex) catch()
									)
								)
								--removeWrapperIndex = finditem ButtonWrapperArray sender.GetWrapper
								--Finds the Button We Click In The Buttons Array
								--if removeObjIndex == 0 then Couldn't Find The Button / If !=0 its a Index Of Current Button Inside ButtonArray
								
								if CurrentSelection != undefined do 
									(
										undo on ( select CurrentSelection )
									)
								if ButtonWrapperArray[1] != Undefined do
									PropertyGrid.SelectedObjects = ButtonWrapperArray
								break;
							)
							--------------------------------------------------------------------------------
							(con.modifierKeys.None):
							(
								CurrentSelection=#()
								try (
										for x in obj do appendifunique CurrentSelection (getnodebyname x)
											(
												undo on (select CurrentSelection)
											)
									)catch(/*print (getcurrentexception())*/)
								SelectedButtonsTemp = SelectedButtons
								SelectedButtons = #()
								ButtonWrapperArray = #()
								appendifunique SelectedButtons sender
								appendifunique ButtonWrapperArray sender.GetWrapper
								PropertyGrid.SelectedObject = Sender.GetWrapper
								break;
							)
						)
				--- COLORING Selected Buttons Border
				Selected_Controls_Color Panel_Char SelectedButtons
				 --PropertyGrid.Hide()
-- 					SplitContainer.Panel2.hide()
-- 					SplitterDistance = 0	
				try (
						execute Sender.IMaxScript
						--print Sender.Itag
					)catch ()
			)
			------------- RightClick Event----------------
			(arg.Button.Right):
				(	--Set The Current_Control = Selected Button Witch User Right_Clicked On That Right Now -- I Used The Current_Control For RightClick Remove/Rename Event
					Sender.invalidate()
					Sender.Refresh()
					Current_Control = Sender
					--print Sender.tag
					--if Sender.tag !=undefined do Format "ButtonTag :%\n Tag.Value :%\n" Sender.tag Sender.tag.value
					--formatprops Current_Control
					--print "Right Click"
				)
			(arg.Button.Middle):(print "Middle Click")--;SplitContainer.Panel2.show();SplitterDistance = 50)--;formatProps arg.Button
			(arg.Button.XButton1):print "XButton1"
			(arg.Button.XButton2):print "XButton2"
		)
	)--End Fn
	
/* "IButtons" Mouse Up Event */ ------------------------------------------------------------------------------------------------------------
	fn IButton_MouseUp Sender arg= 
	(
		/* Seperate LeftClick /Right Click /MiddleClick ----------------------------------------------------------------------*/
		case arg.Button of
		(
			(arg.Button.Left):
			(
				--Check The Button Is Out Of Container or Not X axis
				if sender.location.x < (65-(Sender.size.width/2)) do sender.location.x = 65-(Sender.size.width/2)
				if 	sender.location.x > (Panel_Char.size.width - (Sender.size.width/2)) do sender.location.x = (Panel_Char.size.width - (Sender.size.width/2))
				
				--Check The Button Is Out Of Container or Not Y axis
				if sender.location.y < (-(Sender.size.height/2)) do sender.location.y = -(Sender.size.height/2)
				if 	sender.location.y > (Panel_Char.size.height - (Sender.size.height/2)) do sender.location.y = (Panel_Char.size.height - (Sender.size.height/2))
			)
		)
	)
/* "IButtons" Mouse Move Event */ ------------------------------------------------------------------------------------------------------------
-- 	fn IButton_MouseMove Sender arg= 
-- 	(
-- 		
-- 	)
-------------***********************************************************************************************
	/* "Panel_Char_MouseDown" are the Panel_Char Container Of All Conrols*/ 
	fn Panel_Char_MouseDown Sender arg= 
	(
		/* Seperate LeftClick /Right Click /MiddleClick ----------------------------------------------------------------------*/
		case arg.Button of
		(
			(arg.Button.Left):
			(
				try
				(
					
					CurrentSelectionTemp = CurrentSelection 
					SelectedButtonsTemp = SelectedButtons
					ButtonWrapperArrayTemp = ButtonWrapperArray
					
-- 					deselect CurrentSelection
-- 					CurrentSelection = #()
-- 					SelectedButtons = #()
-- 					ButtonWrapperArray = #()
					PropertyGrid.SelectedObjects = undefined
					PropertyGrid.SelectedObject = undefined
					Selected_Controls_Color Panel_Char SelectedButtons
				)catch()
			)
			------------- RightClick Event----------------
			(arg.Button.Right):(print "Right Click";/*PropertyGrid.SelectedObject = Panel_Char_ImageBox.GetWrapper*/)
			(arg.Button.Middle):(print "Middle Click";PropertyGrid.SelectedObject = Panel_Char.GetWrapper;formatprops PropertyGrid)--;formatProps arg.Button
			(arg.Button.XButton1):print "XButton1"
			(arg.Button.XButton2):print "XButton2"
		)
	)--End Fn
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/*============================================  Rectangle Selection OnMouseUp  ================================================/*\
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* "Panel_Char_MouseUp" When Rectangle Selection is Finished */
	--Sender is  UiFramworkLibrary.CustomPanel()
	fn Panel_Char_MouseUp Sender arg= 
	(
 		--Format "SelectedButtons : % \n" Panel_Char.SelectedButtons
		--formatprops Sender
		case arg.Button of
		(
			(arg.Button.Left):
			(
			con = dotnetclass "system.windows.forms.control"
			--formatprops con.modifierKeys
			case con.modifierKeys of 
			(
				(con.modifierKeys.Control):
				(
					CurrentSelection = CurrentSelectionTemp 
					SelectedButtons = SelectedButtonsTemp
					ButtonWrapperArray = ButtonWrapperArrayTemp
					try
					(
						RectSelectBtns = (Panel_Char.SelectedButtons as array)
						for btn in RectSelectBtns do 
							appendifunique SelectedButtons btn
						--Join SelectedButtons RectSelectBtns
						for x in SelectedButtons do
						(
							appendifunique ButtonWrapperArray x.GetWrapper
							Objs = x.tag.value
							for obj in Objs do
								appendifunique CurrentSelection (getnodebyname obj)
						)
						PropertyGrid.SelectedObject = undefined
						PropertyGrid.SelectedObjects = ButtonWrapperArray				
						undo on ( select CurrentSelection )
					)catch()
					break;
				)
				--------------------------------------------------------------------------------
				(con.modifierKeys.Shift) :
				(
					CurrentSelection = CurrentSelectionTemp 
					SelectedButtons = SelectedButtonsTemp
					ButtonWrapperArray = ButtonWrapperArrayTemp
					try
					(
						RectSelectBtns = (Panel_Char.SelectedButtons as array)
						Join SelectedButtons RectSelectBtns
						for x in SelectedButtons do
						(
							appendifunique ButtonWrapperArray x.GetWrapper
							Objs = x.tag.value
							for obj in Objs do
								appendifunique CurrentSelection (getnodebyname obj)
						)
						PropertyGrid.SelectedObject = undefined
						PropertyGrid.SelectedObjects = ButtonWrapperArray
						undo on (select CurrentSelection)
					)catch()
					break;
				)
				--------------------------------------------------------------------------------
				(con.modifierKeys.Alt):
					(
						RectSelectBtns = (Panel_Char.SelectedButtons as array)
						if RectSelectBtns.count < 1 do break;
							
						CurrentSelection = CurrentSelectionTemp 
						SelectedButtons = SelectedButtonsTemp
						ButtonWrapperArray = ButtonWrapperArrayTemp

						if RectSelectBtns.count > 0 do
						(
							for btn in RectSelectBtns do
							(
								BtnIndex = finditem SelectedButtons btn
								if BtnIndex!=0 do
									(
										try (Objs = btn.tag.value)Catch()
										if Objs!=undefined do
										(
											for obj in Objs do
												(
													ObjIndex = finditem CurrentSelection (getnodebyname obj)
													if ObjIndex!=0 do
														(
															undo on (deselect (getnodebyname obj))
															deleteItem CurrentSelection ObjIndex
														)
												)
										)
										deleteItem SelectedButtons BtnIndex
										deleteItem ButtonWrapperArray BtnIndex
									)
							)
						)
						try (
								undo on (select CurrentSelection)
								PropertyGrid.SelectedObject = undefined
								PropertyGrid.SelectedObjects = ButtonWrapperArray
							)catch()
						break;
					)
				--------------------------------------------------------------------------------
				(con.modifierKeys.None):
				(
					undo on (try (deselect CurrentSelection)catch())
					CurrentSelection = #()
					SelectedButtons = #()
					ButtonWrapperArray = #()

					RectSelectBtns = (Panel_Char.SelectedButtons as array)
					SelectedButtons =  RectSelectBtns
					for x in SelectedButtons do
						(
							append ButtonWrapperArray x.GetWrapper
							try (Objs = x.tag.value)Catch()
							if Objs != undefined do
								for obj in Objs do
									append CurrentSelection (getnodebyname obj)
						)
					undo on (try (select CurrentSelection)catch())
					PropertyGrid.SelectedObjects = ButtonWrapperArray
					break;
				)
			) --End Case Keyboard
			)
			(arg.Button.Right):break;
		)--End case arg.Button of
		Selected_Controls_Color Panel_Char SelectedButtons			
	)--End Fn
/* AddButton MouseDown Event Handler ----------------------------------------------------------------------*/
	fn BtnAdd_MouseDown sender arg = 
		(
			--print"Clicked"
			--IButton = AddButton (ICount as string) PosX:100 PosY:100 SizeX:50 SizeY:50 Color:[150,150,150]
-- 			IButton = AddButton IbuttonText PosX:IbuttonPos.X PosY:IbuttonPos.Y SizeX:IbuttonSize.X SizeY:IbuttonSize.Y tag:IbuttonTag BorderColor:IbuttonBackColor \
-- 												InsideColor:IbuttonForeColor SelectColor:IbuttonISelectedColor TextColor:IbuttonTextColor
			IButton = AddButton "" PosX:100 PosY:100 SizeX:50 SizeY:50 --BorderColor:[150,150,150]
			dotNet.addEventHandler IButton "MouseDown" IButton_MouseDown
			dotNet.addEventHandler IButton "MouseUp" IButton_MouseUp
-- 			dotNet.addEventHandler IButton "MouseMove" IButton_MouseMove
			Panel_Char.controls.add IButton
			IButton.BringToFront()
			dotnet.SetlifetimeControl IButton #dotNet 
			ICount+=1
		)
/* Save Button MouseDown Event Handler ----------------------------------------------------------------------*/
		-----------------------------------------	        -----------------------------------------------------------------------
		------------------------------------------ XML ---------------------------------------------------------------------------
		------------------------------------------         --------------------------------------------------------------------------------
		/* Save All the Controls Inside a Container------------------------------------------------------------------------------*/
		fn SaveControls_To_XmlFile IContainer filename: = 
		(
			if filename == unsupplied do filename = getSaveFilename caption:"Save Dummy List File" types:"Dummy List (.xml)|*.xml"
			(
				if filename != undefined do
				(
					if getfilenametype filename == "" do filename += ".xml"
					(
						--Create XmlDocument From Dotnet Xml Document Class 
						Doc = dotnetObject "system.xml.xmlDocument"	
						--formatProps Doc
						--Add Some Comments at Begging of The Xml File 
						Doc.AppendChild (Doc.CreateComment "Character Selector")
						Doc.AppendChild (Doc.CreateComment ("File: " + maxfilepath + maxfilename + " Creation Date: " + localtime)))
						Doc.AppendChild (Doc.CreateWhitespace "\n")
						--Create The First Element
						Doc.AppendChild (xnodes = doc.CreateElement "CharatcerInfoElement")
							xnodes.SetAttribute "CharacterName" "Character"--(nodes.count as string)
							xnodes.SetAttribute "FormX" (Form.Width as string)--(FormSize X)
							xnodes.SetAttribute "FormY" (Form.Height as string)--(FormSize Y)
							-- CHANGE THIS TO A GLOBAL BACKGROUND PATH OR SOMETHING
							xnodes.SetAttribute "BackgroundFilePath" (Panel_Char_BackImagePath as string)
							xnodes.SetAttribute "SpliterDistance" (SplitContainer.SplitterDistance as string)
							xnodes.SetAttribute "ImagePositionX" (Panel_Char.PositionX as string)
							xnodes.SetAttribute "ImagePositionY" (Panel_Char.PositionY as string)
							xnodes.SetAttribute "IimageWidth" (Panel_Char.Iwidth as string)
							xnodes.SetAttribute "IimageHeight" (Panel_Char.Iheight as string)
					--Loop Throgh All The Controls Of IContainer
						for i = 0 to (IContainer.controls.count-1 as integer) do 
						(
							--I Convert all the values of Ibuttons to string to save it in the Xml file as string
							--Convertors Functions : DnColorToCString / CStringToDnColor / DnLocationToString / StringToDnLocation /DnSizeToString /StringToDnSize
							Ibutton = IContainer.controls.Item[i]
							--IbuttonName = Ibutton.name as string
							IbuttonText= Ibutton.text as string
							IbuttonITagScript =Ibutton.IMaxScript as string ----------------$$$
							IbuttonPos = (DnLocationToString Ibutton.location) as string
							IbuttonSize = (DnSizeToString Ibutton.size) as string
							IbuttonBackColor = (DnColorToCString Ibutton.IBorderColors) as string
							IbuttonForeColor = (DnColorToCString Ibutton.IInsideColors) as string
							IbuttonTextColor = (DnColorToCString Ibutton.ITextColor) as string
							IbuttonISelectedColor = (DnColorToCString IButton.ISelectedColor) as string
							IbuttonType = IButton.ButtonTypeSrting as string
							IbuttonBorderThick = IButton.BorderThick as string
							IbuttonGradientAngle = IButton.GradientAngle as string
							IbuttonRadius = IButton.Radius as string
							IbuttonTag = (undefined) as string

							try(
							if Ibutton.tag != undefined Do
							(
								ObjArray = #()
								-- Making The Array of names of Objects inside Button.Tag
								if (classof (Ibutton.tag.value) == array)  then
									for i= 1 to Ibutton.tag.value.count do
										append ObjArray (Ibutton.tag.value[i])
								else
									append ObjArray (Ibutton.tag.value)
								-- Convert the Object Array to String and Pars it 
								-- Making Array Of Object Names As String
								ObjStr = ""
								for obj in ObjArray do
								(
									if obj != undefined do
										ObjStr += (obj as string) + "||"
								)
								ObjStr = trimright ObjStr "||"
								IbuttonTag = ObjStr
							)
							)catch()
							--Store each IButton as a Element and Set the attributes and values for that
							xnodes.AppendChild (xnode = doc.CreateElement "IButton")		
							--Convertors Functions : DnColorToCString / CStringToDnColor / DnLocationToString / StringToDnLocation /DnSizeToString /StringToDnSize
								xnode.SetAttribute "Text" 	   		IbuttonText				--Button.Text
								xnode.SetAttribute "Location" 		IbuttonPos				--Button.Location as string
								xnode.SetAttribute "Size"	   		IbuttonSize				--Button.Size as string
								xnode.SetAttribute "BackColor" 	   	IbuttonBackColor		--Button.BackColor as string
								xnode.SetAttribute "ForeColor"   	IbuttonForeColor		--Button.ForeColor as string
								xnode.SetAttribute "TextColor"    	IbuttonTextColor		--Button.TextColor as string
								xnode.SetAttribute "ISelectedColor" IbuttonISelectedColor	--Button.IsSelectedColor as string
								xnode.SetAttribute "ButtonType" 	IbuttonType				--Button.ButtonType as string
								xnode.SetAttribute "BorderThick" 	IbuttonBorderThick		--Button.ButtonType as string
								xnode.SetAttribute "GradientAngle" 	IbuttonGradientAngle	--Button.ButtonType as string
								xnode.SetAttribute "Radius" 		IbuttonRadius			--Button.ButtonType as string
								xnode.SetAttribute "Tag"  	   		IbuttonTag				--Button.Target Object "Tag" as string	
								xnode.SetAttribute "ITagScript" 	IbuttonITagScript  		--Script To Execute  ----------------$$$
							if IbuttonType == "HalfCircle" do 
							(
								try
								(
								xnode.SetAttribute "HCStartAngle" 	(IButton.HCStartAngle as string)			
								xnode.SetAttribute "HCSweepAngle" 	(IButton.HCSweepAngle as string)			
								xnode.SetAttribute "HCThick" 		(IButton.HCThick as string)		
								)catch()
							)
					)
					doc.Save filename
				)
			)			
			return filename
		)
/* -- Load All The buttons from xml and create buttons inside the container */
	fn PopulateControls_FromXml_To_Container IContainer filename: = 
		(
			if filename == unsupplied do filename = getOpenFilename caption:"Save Dummy List File" types:"Dummy List (.xml)|*.xml"
			(
				if filename != undefined then
				(
				if getfilenametype filename == "" do print"Select A File Please"--filename += ".xml"
					(
						--Create XmlDocument From Dotnet Xml Document Class 
						Doc = dotnetObject "system.xml.xmlDocument"	
						Doc.load (filename)
						IElements = Doc.DocumentElement
						-- Load Form Setting + Background	
						FormElement = IElements.Attributes
						for i = 0 to FormElement.Count-1 do 
						(
							Names = FormElement.ItemOf[i].Name
							case Names of 
								(
									"CharacterName":(
										CharacterName = (FormElement.ItemOf[i].Value) as string
-- 										Print CharacterName
										break
										)
									"BackgroundFilePath":(
										Panel_Char_BackImagePath = (FormElement.ItemOf[i].Value) as string
-- 										Print BackgroundFilePath
										break
										)
									"FormX":(
										FormX = (FormElement.ItemOf[i].Value) as integer
-- 										Print FormX
										break
										)
									"FormY":(
										FormY = (FormElement.ItemOf[i].Value) as integer
-- 										Print FormY
										break
										)
									"SpliterDistance":(
										SplitterDistance = (FormElement.ItemOf[i].Value) as integer
										break
										)
									"ImagePositionX":(
										Panel_Char.PositionX = (FormElement.ItemOf[i].Value) as integer
										break
										)
									"ImagePositionY":(
										Panel_Char.PositionY = (FormElement.ItemOf[i].Value) as integer
										break
										)
									"IimageWidth":(
										Panel_Char.Iwidth = (FormElement.ItemOf[i].Value) as integer
										break
										)
									"IimageHeight":(
										Panel_Char.IHeight = (FormElement.ItemOf[i].Value) as integer
										break
										)										
									Default:break
								)
							try ( 
									Form.Size = DnSize s:[FormX,FormY] 
									Form.Text = "HPK UI Layout"--CharacterName + " Framework UI "
									Bg = (dotnetclass "System.Drawing.Image").FromFile (Panel_Char_BackImagePath)
									Panel_Char.BackgroundImageLayout = Panel_Char.BackgroundImageLayout.None--.Center--Stretch
									Panel_Char.BackgroundImage = Bg
-- 									Panel_Char_ImageBox.Picture = Bg
									SplitContainer.SplitterDistance = SplitterDistance
								)catch()
							
							--Format "%: Name :%  Value:% \n" I IElements.Attributes.ItemOf[i].Name IElements.Attributes.ItemOf[i].value
						)
						IElements.Attributes.Count
						--Convertors Functions : DnColorToCString / CStringToDnColor / DnLocationToString / StringToDnLocation /DnSizeToString /StringToDnSize
						ChildNodes = IElements.ChildNodes
					--LOAD Buttons Data From XML And Add Theme To Container
						for i = 0 to ChildNodes.count-1 do
						(
							Ibutton = ChildNodes.ItemOf[i]
							IText = (Ibutton.GetAttribute "Text") as string
							ITagScript =(Ibutton.GetAttribute "ITagScript") as string
							IPos =  StringToDnLocation ((Ibutton.GetAttribute "Location")as string)
							ISize = StringToDnSize ((Ibutton.GetAttribute "Size") as string)
							IBackColor 	 = CStringToDnColor ((Ibutton.GetAttribute "BackColor")as string)
-- 							format "IBackColor R : % \n" ((CStringToDnColor ((Ibutton.GetAttribute "BackColor")as string)).r)							
							IForeColor 	 = CStringToDnColor ((Ibutton.GetAttribute "ForeColor")as string)
							ITextColor 	 = CStringToDnColor ((Ibutton.GetAttribute "TextColor")as string)
							ISelectedColor= CStringToDnColor ((Ibutton.GetAttribute "ISelectedColor")as string)
							
							IButtonType= Ibutton.GetAttribute "ButtonType" as string
							if IButtonType == "HalfCircle" do 
							(
								try
								(
									IHCStartAngle = Ibutton.GetAttribute "HCStartAngle" as integer			
									IHCSweepAngle = Ibutton.GetAttribute "HCSweepAngle"  as integer			
									IHCThick = Ibutton.GetAttribute "HCThick"  as integer
								)catch()
							)
							IGradientAngle= Ibutton.GetAttribute "GradientAngle" as integer
							IRadius= Ibutton.GetAttribute "Radius" as integer
							IBorderThick= Ibutton.GetAttribute "BorderThick" as integer
							
							ObjStr = Ibutton.GetAttribute "Tag" as string
							--Parsing Object Names Sring To An Names Array / filterString Makes an Array of string parts by " | | "
								NamesArray = filterString ObjStr "||"
							--Make Objects Array Get Objects By Name
								ObjArray =#()
							for x in NamesArray do
									appendifunique ObjArray x
							--Puting ObjectArray In Button Tag As Dotnet Maxscript Value		
							IbuttonTag =  dotnetmxsvalue (ObjArray)
						
							--format "I:% Text : % PosX:% PosY:% sizx:% sizey:% Tag:%\n" i IbuttonText IbuttonPosX IbuttonPosY IbuttonSizeX IbuttonSizeY IbuttonTag
							--AddButton IName ButtonType:"Circle" PosX:100 PosY:100 SizeX:50 SizeY:50 BorderColor:[0,0,255] InsideColor:[255,255,0] SelectColor:[0,255,0] TextColor:[0,0,0] alphas:255 GradAngle:180 Tag:Undefined =
							
							IButton = AddButton IText ButtonType:IButtonType PosX:IPos.x PosY:IPos.y SizeX:ISize.width SizeY:ISize.height tag:IbuttonTag BorderThick:IBorderThick Radius:IRadius \
												BorderColor:IBackColor InsideColor:IForeColor SelectColor:ISelectedColor TextColor:ITextColor HCThick:IHCThick HCSweepAngle:IHCSweepAngle HCStartAngle:IHCStartAngle \
												ITagScr:ITagScript
							
							dotNet.addEventHandler IButton "MouseDown" IButton_MouseDown
							dotNet.addEventHandler IButton "MouseUp" IButton_MouseUp
							Panel_Char.controls.add IButton
							IButton.BringToFront()
							dotnet.SetlifetimeControl IButton #dotNet 
							ICount+=1
						)			
					)
					return True
				)
				return false
			)
		)
/*-Return List of Controllers in a Container	-----------------------------------------------------------------------------------------------------------------------------------------------------	*/
	fn ListOfControls IContainer = 
		(
			ControlsArray = #()
			for i = 0 to (IContainer.controls.count-1 as integer) do 
			(
				Ibutton = IContainer.controls.Item[i]
				append ControlsArray Ibutton 
			)
			return ControlsArray
		)
/*Save Layout Button MouseDown Event Handler--------------------------------------------------------------*/
	fn BtnSave_MouseDown sender arg = 
		(
			SaveControls_To_XmlFile Panel_Char --filename:(sysinfo.currentdir+"\\XmlLayout.Xml")
			--File = getOpenFilename caption:"Open Dummy List File"
		)	
	fn DeleteAllControls IContainer = 
	(
		For i = 0 to IContainer.controls.count-1 do 
			(
				try
				(
					CurrentControl = IContainer.controls.Item[0]
					--Format "% : Name:%\n" i ((CurrentControl.text))
					IContainer.Controls.Remove(CurrentControl)
					
				)catch(/*print (getCurrentException())*/)
			)
			ICount = 0
	)	
/* Load Button MouseDown Event Handler ----------------------------------------------------------------------*/
	fn BtnLoad_MouseDown sender arg = 
	(
		--Set The PorpertyGrid To Panel Char Because We Are Goint To Remove All the Buttons
		if Panel_Char.Controls.Count > 0 then
		(
			RemoveBox = queryBox "Are you Sure You want to Remove All Controls ?" beep:false 
			if RemoveBox == true then
			(
				PropertyGrid.SelectedObject = Panel_Char.GetWrapper
				--Remove All The Current Controls And Background
				DeleteAllControls Panel_Char
				Panel_Char.BackgroundImage = undefined 
				--Panel_Char_ImageBox.Picture = undefined

				-- Load Controls From Xml
				Check = PopulateControls_FromXml_To_Container Panel_Char
			)else
			(
				Check = PopulateControls_FromXml_To_Container Panel_Char
			)
		)else
		(
				PropertyGrid.SelectedObject = Panel_Char.GetWrapper
				--Remove All The Current Controls And Background
				DeleteAllControls Panel_Char
				Panel_Char.BackgroundImage = undefined 
				--Panel_Char_ImageBox.Picture = undefined

				-- Load Controls From Xml
				Check = PopulateControls_FromXml_To_Container Panel_Char
		)
	)	
/**Capture Screen area and save to a vaible or file*/		
	fn BtnCapture_MouseDown sender arg = 
		(
			Imagefilename = getOpenFilename caption:"Load Background" types:("Png (.Png)|*.Png|Bitmap (.Bmp)|*.bmp|Jpeg (.Jpg)|*.jpg")
			if Imagefilename!=undefined do 
			(
				Panel_Char_BackImagePath = Imagefilename
				Bg = (dotnetclass "System.Drawing.Image").FromFile (Imagefilename)
 				Panel_Char.BackgroundImageLayout = Panel_Char.BackgroundImageLayout.None--.Center--Stretch
				Panel_Char.BackgroundImage = Bg
				try
				(
					Panel_Char.Iwidth = Panel_Char.ImageWidth
					Panel_Char.Iheight = Panel_Char.ImageHeight
				)catch()
				--Panel_Char_ImageBox.Picture = Bg

			)
		)	

/*Lock/Unlock Button 3State Button --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	fn BtnLock_MouseDown sender arg = 
		(
			BtnLock = sender as dotNetObject "System.Windows.Forms.Button"
			if (BtnLock.tag+1) < 4 then BtnLock.tag += 1 else BtnLock.tag = 1
			if BtnLock.tag == 1 then
			(
				BtnLock.Text = "移动\n缩放"
					ControlMoveAndResizeClass.WorkType = ControlMoveAndResizeClass.WorkType.MoveAndResize
					Worktype = ControlMoveAndResizeClass.WorkType
				BtnLock.backcolor = dncolor c:[255,255,255]
				Form.MaximumSize = dnsize s:[1920,1200]
				Form.MinimumSize = dnsize s:[500,500]
				
			)
			else if BtnLock.tag == 2 then
			(
				BtnLock.Text = "仅移动"
				BtnLock.backcolor = RibbonButtons_BackColor
					ControlMoveAndResizeClass.WorkType = ControlMoveAndResizeClass.WorkType.Move
					Worktype = ControlMoveAndResizeClass.WorkType
				BtnLock.backcolor = dncolor c:[0,255,0]
				Form.MaximumSize = dnsize s:[1920,1200]
				Form.MinimumSize = dnsize s:[500,500]
			)
			else if BtnLock.tag == 3 do
			(
				ControlMoveAndResizeClass.WorkType = ControlMoveAndResizeClass.WorkType.None
				Worktype = ControlMoveAndResizeClass.WorkType
				BtnLock.Text = "锁定"
				BtnLock.backcolor = dncolor c:[255,0,0]
				Form.MaximumSize = dnsize s:[Form.Size.width,Form.Size.height]
				Form.MinimumSize = dnsize s:[Form.Size.width,Form.Size.height]
			)
			--BtnLock.tag = not BtnLock.tag
		)
		
	/* Credit Button--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	fn BtnCredit_MouseDown sender arg = 
		(
			str  = "Created By : Hamed Pourkerman     Last Update: 08/09/2017 \n"
			str += "Hamed.Pourkerman@gmail.com\n"
			str	+= "www.Vimeo.com\HamedAdv\n"
			messagebox str
		)		
/*----------------------------------------------------------------------------*/
/*------------------Create and initialize UI -----------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
	fn InitUI = 
		(
			--ControlMoveAndResizeClass = LoadDllOntheFly DllPath	
	/*DotNet Form   -----------------------------------------------------------------------------------------------------------------------------------------------------------*/
			Form.Size = DnSize s:[FormX,FormY]
				--Form.topmost = true
			Form.MaximumSize = dnsize s:[1920,1200]
			Form.MinimumSize = dnsize s:[500,500]
			Form.Text = "HPK UI Layout  1.0"
	/*Split Form In 2 Panel   -----------------------------------------------------------------------------------------------------------------------------------------------------------*/			
			SplitContainer.Dock = RibbonPanel.Dock.Fill
			--formatProps SplitContainer
			Form.controls.add(SplitContainer)

			--formatprops SplitContainer.Panel1 
	/*Left Ribbon Panel  / FlowLayoutPanel  ----------------------------------------------------------------------------------------------------------------------------------*/
 			RibbonPanel.Anchor = RibbonPanel.Anchor.top.left 
 			RibbonPanel.Dock = RibbonPanel.Dock.Left
			--formatProps RibbonPanel
			--RibbonPanel.AutoSize = true
			RibbonPanel.Size = DnSize s:[65,520] 
			RibbonPanel.BackColor = RibbonPanel_BackColor
			RibbonPanel.TabIndex = 0
--			Form.controls.add(RibbonPanel)
			SplitContainer.Panel1.Controls.add(RibbonPanel)
			dotnet.SetlifetimeControl RibbonPanel #dotNet
	/*PropertyGrid Control ---------------------------------------------------------------------------------------------------------------------*/
			PropertyGrid.Anchor = PropertyGrid.Anchor.Top.Bottom.Left.Right	
			PropertyGrid.Dock = PropertyGrid.Dock.fill
			PropertyGrid.Autosize = false
			PropertyGrid.size = dnsize s:[220,700]
			PropertyGrid.BackColor = dncolor C:[0,0,255] --PropertiesPanel_BackColor
			SplitContainer.Panel2.Controls.add(PropertyGrid)
			formatprops SplitContainer.Panel2
			dotnet.SetlifetimeControl PropertyGrid #dotNet
	/*Create Add Button To TopRibbon  ------------------------------------------------------------------------------------------------------------------------------------*/
-- 			BtnAdd = dotNetObject "System.Windows.Forms.Button"
-- 			ButtonInit BtnAdd "Add Rect" RibbonButtons_BackColor SizeX:60 Sizey:60
	/*Create Add Round Button To TopRibbon  ------------------------------------------------------------------------------------------------------------------------------------*/			
			BtnAdd = LoadDllOntheFly DllPath "UiFramworkLibrary.GraphicButton"
			BtnAdd.size = dotNetObject "System.Drawing.Size" RibbonPanelBtnSizeX RibbonPanelBtnSizeY
			BtnAdd.text = ""
			BtnAdd.location = dotNetObject "System.Drawing.Point" 0 0
			BtnAdd.Anchor = BtnAdd.Anchor.top.left.right.bottom
			BtnAdd.IBordercolors = dnColor C:[140,140,255] a:255
			BtnAdd.IInsidecolors = dnColor C:[130,130,255] a:255
-- 			formatprops BtnAdd
	/*Create Save Button To TopRibbon  -----------------------------------------------------------------------------------------------------------------------------------*/		
			BtnSave = dotNetObject "System.Windows.Forms.Button"
			ButtonInit BtnSave "保存\r\n布局" RibbonButtons_BackColor SizeX:RibbonPanelBtnSizeX Sizey:RibbonPanelBtnSizeX
	/*Create Load Button To TopRibbon  -----------------------------------------------------------------------------------------------------------------------------------*/					
			BtnLoad = dotNetObject "System.Windows.Forms.Button"
			ButtonInit BtnLoad "加载\r\n布局" RibbonButtons_BackColor SizeX:RibbonPanelBtnSizeX Sizey:RibbonPanelBtnSizeX
	/*Create Snipping Button To TopRibbon  ------------------------------------------------------------------------------------------------------------------------------*/					
			BtnCapture = dotNetObject "System.Windows.Forms.Button"
			ButtonInit BtnCapture "选择\r\n图片" RibbonButtons_BackColor SizeX:RibbonPanelBtnSizeX Sizey:RibbonPanelBtnSizeX
	/*Create 3States LOCK Button To Ribbon  For Change the Move / FreeForm / Lock States------------------------------------------------------------------------------------------------------------------------------*/					
			BtnLock = dotNetObject "System.Windows.Forms.Button"
			ButtonInit BtnLock "移动\r\n缩放" RibbonButtons_BackColor SizeX:RibbonPanelBtnSizeX Sizey:RibbonPanelBtnSizeX
			BtnLock.tag = 1
	/*Create Credit Button ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/					
			BtnCredit = dotNetObject "System.Windows.Forms.Button"
			ButtonInit BtnCredit "关于" RibbonButtons_BackColor SizeX:RibbonPanelBtnSizeX Sizey:RibbonPanelBtnSizeX
			BtnCredit.Dock = BtnCredit.Dock.Bottom
			--BtnCredit.Margin.Top = 100
			--(dotnetclass "System.Windows.Forms.Padding") 0 100 0 0
			--formatprops BtnCredit.Margin
	/*Add Button Controls To  Container TopRibbon  FlowLayoutPanel ---------------------------------------------------------------------------------------------------------------------------------*/								
-- 			RibbonPanel.controls.add(BtnAdd)
			RibbonPanel.controls.add(BtnAdd)
			RibbonPanel.controls.add(BtnSave)
			RibbonPanel.controls.add(BtnLoad)
			RibbonPanel.controls.add(BtnCapture)
			RibbonPanel.controls.add(BtnLock)
			RibbonPanel.controls.add(BtnCredit)
-- 			dotNet.addEventHandler BtnAdd "MouseDown" BtnAdd_MouseDown
			dotNet.addEventHandler BtnAdd "MouseDown" BtnAdd_MouseDown
			dotNet.addEventHandler BtnSave "MouseDown" BtnSave_MouseDown
			dotNet.addEventHandler BtnLoad "MouseDown" BtnLoad_MouseDown
			dotNet.addEventHandler BtnCapture "MouseDown" BtnCapture_MouseDown
			dotNet.addEventHandler BtnLock "MouseDown" BtnLock_MouseDown
			dotNet.addEventHandler BtnCredit "MouseDown" BtnCredit_MouseDown
			
-- 			dotnet.SetlifetimeControl BtnAdd #dotNet
			dotnet.SetlifetimeControl BtnAdd #dotNet
			dotnet.SetlifetimeControl BtnSave #dotNet 
			dotnet.SetlifetimeControl BtnLoad #dotNet 
			dotnet.SetlifetimeControl BtnCapture #dotNet 
			dotnet.SetlifetimeControl BtnLock #dotNet 
			dotnet.SetlifetimeControl BtnCredit #dotNet 
	-- Credit Label------------------------
-- 			CreditLabel = dotNetObject "System.Windows.Forms.Label"
-- 			CreditLabel.text = "HPK"
-- 			CreditLabel.Autosize = true
-- 			CreditLabel.Location = DnPoint p:[65,1]
-- 			CreditLabel.ForeColor = DnColor c:[200,200,200]
-- 			Panel_Char.Controls.add(CreditLabel)
			--formatprops CreditLabel
-- 			dotnet.SetlifetimeControl CreditLabel #dotNet 
	/*Character Container  / Selector Panel  --------------------------------------------------------------------------------------------------------*/
 			Panel_Char.Anchor = Panel_Char.Anchor.Top.Bottom.Left.Right	
 			--Panel_Char.autoSize =true
			Panel_Char.Dock = Panel_Char.Dock.Fill
			Panel_Char.Location = DnPoint p:[154,0]
 			Panel_Char.Size = DnSize s:[400,680]
			
 			Panel_Char.BackColor = PanelChar_BackColor
 			--Form.controls.add(Panel_Char)
			
			SplitContainer.Panel1.Controls.add(Panel_Char)
			
			--Panel_Char.Controls.Add(Panel_Char_ImageBox)
-- 			Panel_Char_ImageBox.Enabled = false
			--Panel_Char_ImageBox.SendToBack
-- 			Panel_Char_ImageBox
				--formatprops Panel_Char
				--Panel_Char.SendToBack()
				--PropertiesPanel.BringToFront()
			dotNet.addEventHandler Panel_Char "MouseDown" Panel_Char_MouseDown
			dotNet.addEventHandler Panel_Char "MouseUp" Panel_Char_MouseUp
			dotnet.SetlifetimeControl Panel_Char #dotNet
			
			Form.Show(theHwnd)
			dotnet.SetlifetimeControl Form #dotNet 
			
			--Form.show() --show the Form with the Button
		)
	/*----------------------------------------------------------------------------*/
	/*------------------Main Program Function-------------------------------------*/
	/*-----------------------------------------------------------------------------------------------*/
	MainProgram = InitUI()

)/*END Program-----------------------------------------------------------------------------------------------*/




