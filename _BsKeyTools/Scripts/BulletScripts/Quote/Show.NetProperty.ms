/*
Show .Net Property
v2.04
by Alexander Kramer (Track)
www.3d-kstudio.com
3dkstudio@gmail.com

v2.04
Adds support for 3ds Max 2008

v2.08
Adds Search TextBox
Fixes issues with garbage collection (only in max 2010)
*/
if NetPropertyForm != undefined then  try(NetPropertyForm.Close())catch()
 (

local iniFile = (getFilenamePath (getSourceFileName())) + "ShowDotNetProperty.ini"
local NotesFile = (getFilenamePath (getSourceFileName())) + "DotNetNotes.rtf"

if not doesFileExist iniFile then
	(
		new_ini = createFile iniFile
		format "[Assembly]\n" to:new_ini
		format "system.xml.dll=\n" to:new_ini
		format "System=\n" to:new_ini
		format "System.Data=\n" to:new_ini
		format "System.Windows.Forms=\n" to:new_ini
		format "System.Drawing=\n" to:new_ini
		format "System.Management=\n" to:new_ini
		format "[FavoritObject]\n" to:new_ini
		format "System.Windows.Forms.Form=\n" to:new_ini
		format "[Interface]\n" to:new_ini
		format "Size=[448,172]\n" to:new_ini
		format "Location=[50, 100]\n" to:new_ini
		format "AssemblySaveText=System.Windows.Forms\n" to:new_ini
		format "AssemblyObjectSaveText=System.Windows.Forms.TreeView\n" to:new_ini
		format "FavorObjectSaveText=System.Windows.Forms.DataGridView\n" to:new_ini
		format "SearchSaveText=\n" to:new_ini
		close new_ini
	)

local TitleText = "Show .Net Property v2.20 by Alex Kramer (Track)"

local Assembly = sort (getinisetting iniFile "Assembly")
local FavoritObjects = sort (getinisetting iniFile "FavoritObject")
local DotNetObjectsFromAssembly = #()
local FillListArray = #()

local formSize = execute (getinisetting iniFile "Interface" "Size")
local formLocation = execute (getinisetting iniFile "Interface" "Location")

local print_to_listener = false				-----------Not Used in Inteface
local dnObject

local FindTrue=false							-----------Disable printing to RichTextBox when Searching process is Started
local FindPropString=stringStream "\n"

local AllpropString=stringStream "\n"
local propString=stringStream "\n"
local methodsString=stringStream "\n"
local eventsString=stringStream "\n"
local constString=stringStream "\n"

local	dnToolTip = dotNetObject "ToolTip"
local	DockStyle=DotNetClass "System.Windows.Forms.DockStyle"
local	FlatStyle=DotNetClass "System.Windows.Forms.FlatStyle"

local AssemblyComboBox		---List of .NET Framework Class Library.
local NetObjectsComboBox	---List of .NET Objects

local AddFavorButton
local AddAssemblyButton

local AssemblyRadioButton
local FavorRadioButton
local NetObjectsRadioButton
local NetClassRadioButton
local AllObjectsRadioButton


local TextBoxArray=#()
local PropertyTextBox
local TextBoxMethods
local TextBoxEvents
local TextBoxConstructors
local TextBoxNotes
local TextBoxSearchResult

local FilterFindTextBox
local dn_tabs
local TabSearchResult

local AssemblySaveText=(getinisetting iniFile "Interface" "AssemblySaveText")
local AssemblyObjectSaveText=(getinisetting iniFile "Interface" "AssemblyObjectSaveText")
local FavorObjectSaveText=(getinisetting iniFile "Interface" "FavorObjectSaveText")
local SearchSaveText=(getinisetting iniFile "Interface" "SearchSaveText")
local SearchSaveTextArray=(getinisetting iniFile "SearchSaveTextArray")

local fromTextBoxShow = false
local MyDotNetName


fn Test dnObject =
	(
	AllpropString=stringStream "\n"
	propString=stringStream "\n"
	methodsString=stringStream "\n"
	eventsString=stringStream "\n"
	constString=stringStream "\n"

	try showProperties dnObject to:propString catch()
	try showMethods dnObject to:methodsString	catch()
	try showEvents dnObject to:eventsString	catch()
	try dotNet.showConstructors dnObject to:constString	catch()

-- 	format "%\n" dnObject --to:propString
	dnName=(filterstring (dnObject as string) ":")
	if not FindTrue then format "% \"%\"\n" dnName[1]  dnName[2]

	format (propString as string) to:AllpropString
	format (methodsString as string) to:AllpropString
	format (eventsString as string) to:AllpropString
	format (constString as string) to:AllpropString

	if print_to_listener then
		(
			clearListener()
			format "%\n" (AllpropString as string)
			actionMan.executeAction 0 "40472"  --Open MAXScript Listener
		)
-- 	else if not FindTrue then tabSelected()
	else if not FindTrue then
		(
			TextBoxArray[1].Text=propString as string
			TextBoxArray[2].Text=methodsString as string
			TextBoxArray[3].Text=eventsString as string
			TextBoxArray[4].Text=constString as string
		)
	)

NetPropertyForm = dotNetObject "MaxCustomControls.MaxForm"

NetPropertyForm.Size = dotNetObject "System.Drawing.Size" formSize[1] formSize[2]
NetPropertyForm.MinimumSize=dotNetObject "System.Drawing.Size" 448 172
NetPropertyForm.Text=TitleText

	PrintButton=dotNetObject "System.Windows.Forms.Button"
	PrintButton.FlatStyle=FlatStyle.System
	PrintButton.Width=40
	PrintButton.Height=22
	PrintButton.Location=dotNetObject "System.Drawing.Point" 270 26
	PrintButton.Text="Print"
dnToolTip.SetToolTip PrintButton "Print Properties"

GetSubClassesButton=dotNetObject "System.Windows.Forms.Button"
GetSubClassesButton.FlatStyle=FlatStyle.System
GetSubClassesButton.Width=30
GetSubClassesButton.Height=22
GetSubClassesButton.Location=dotNetObject "System.Drawing.Point" 312 26
GetSubClassesButton.Text="Get"
dnToolTip.SetToolTip GetSubClassesButton "Get Dependents"

	LoadAssemblyButton=dotNetObject "System.Windows.Forms.Button"
	LoadAssemblyButton.FlatStyle=FlatStyle.System
	LoadAssemblyButton.Width=72
	LoadAssemblyButton.Height=22
	LoadAssemblyButton.Location=dotNetObject "System.Drawing.Point" 270 3
	LoadAssemblyButton.Text="Load"
dnToolTip.SetToolTip LoadAssemblyButton "Load Assembly"

fn AddRangeFunction netObject maxArray = for i in 1 to maxArray.count do netObject.Items.Add (dotNetObject "System.String" maxArray[i])

fn FillObjectsList =
	(
	NetObjectsComboBox.Items.Clear()
	FillListArray=#()
	case of
			(
			(AssemblyRadioButton.Checked) :
				(
				FavorObjectSaveText=NetObjectsComboBox.Text
				case of
					(
						(NetObjectsRadioButton.Checked) : FillListArray=for objName in DotNetObjectsFromAssembly where (try(dotNetObject objName;true)catch(false)) collect objName
						(NetClassRadioButton.Checked) : FillListArray=for objName in DotNetObjectsFromAssembly where (try(dotNetObject objName;false)catch(true)) collect objName
						(AllObjectsRadioButton.Checked) : FillListArray=DotNetObjectsFromAssembly
					)
				NetObjectsComboBox.Text=AssemblyObjectSaveText
				)
			(FavorRadioButton.Checked) :
				(
				AssemblyObjectSaveText=NetObjectsComboBox.Text
				case of
					(
						(NetObjectsRadioButton.Checked) : FillListArray=for objName in FavoritObjects where (try(dotNetObject objName;true)catch(false)) collect objName
						(NetClassRadioButton.Checked) : FillListArray=for objName in FavoritObjects where (try(dotNetObject objName;false)catch(true)) collect objName
						(AllObjectsRadioButton.Checked) : FillListArray=FavoritObjects
					)
				NetObjectsComboBox.Text=FavorObjectSaveText
				)
			)
-- 		NetObjectsComboBox.Items.AddRange FillListArray
		AddRangeFunction NetObjectsComboBox FillListArray
	)

fn LoadAssembly AsMName=
	(
		clearListener()
		r=dotnet.loadAssembly AsMName
		if r!=undefined then
		(
			AssemblyArray=r.GetExportedTypes()
			DotNetObjectsFromAssembly=for aSM in AssemblyArray collect aSM.FullName
-- 			print DotNetObjectsFromAssembly
			AssemblyRadioButton.Checked=true
			if not FindTrue then FillObjectsList()
		)
	else format "%\n" "Undefined Assembly"
	)

fn LoadAssemblyClick = if AssemblyComboBox.Text!="" then LoadAssembly AssemblyComboBox.Text

dotNet.addEventHandler LoadAssemblyButton "Click" LoadAssemblyClick

fn test_text_Pressed =
	(
		dnObject= undefined
		local MyDotNet = dotNetObject
		if not fromTextBoxShow then MyDotNetName = NetObjectsComboBox.Text
		if MyDotNetName!="" then try(dnObject= MyDotNet MyDotNetName)catch(dnObject= dotNetClass MyDotNetName)

		fromTextBoxShow=false
	)

fn PrintProperties forNullObject:false=(
	AllpropString=stringStream "\n"
	propString=stringStream "\n"
	methodsString=stringStream "\n"
	eventsString=stringStream "\n"
	constString=stringStream "\n"
-- 		PropertyTextBox.Clear()
	if forNullObject and NullObject !=undefined then (
		Txt = (filterString (NullObject as string)":")[2]
		NetObjectsComboBox.Text = Txt
		Test NullObject
		)
	else	if try (classof (myNetObject = execute NetObjectsComboBox.Text)==dotNetObject )catch(false) then(
-- 		Txt = (filterString (NullObject as string)":")[2]
-- 		NetObjectsComboBox.Text = Txt
		Test myNetObject
		)
		else
		(
		test_text_Pressed()
	if dnObject!=undefined then try(Test dnObject)
		catch(
			format "\n%\n" ("Runtime error: No constructor found which matched argument list");
			print (getCurrentException())
			undefined
		)
	)
	)

fn  GetSubClasses =(
		FindTrue=true
		PrintProperties()
		seek AllpropString 0
		propArray=#()
		while not (eof AllpropString) do
		(
			join propArray (filterString (readLine AllpropString) " :()<>,&")
		)
		propArray=makeUniqueArray propArray
		SubClassArray=for t in propArray where t!="name" and t!=".Name" and (try(dotnetClass t!=undefined)catch(false)) collect t
-- 		clearListener()
-- 		print SubClassArray
		if SubClassArray.count!=0 then
		(
			FavorObjectSaveText=NetObjectsComboBox.Text
			NetClassRadioButton.Checked=true
			NetObjectsComboBox.Items.Clear()
-- 			NetObjectsComboBox.Items.AddRange SubClassArray
			AddRangeFunction NetObjectsComboBox SubClassArray
		)
	FindTrue=false
	)

fn PrintPropertiesMouse e = (
	PrintProperties forNullObject:(e.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Right)
	)
dotNet.addEventHandler PrintButton "MouseDown" PrintPropertiesMouse
dotNet.addEventHandler GetSubClassesButton "Click" GetSubClasses

fn Add_pressed e arg =
	(
	case e of
		(
		(AddAssemblyButton) :
			(
			if AssemblyComboBox.Text !="" and findItem Assembly AssemblyComboBox.Text==0 then
				(
					append Assembly AssemblyComboBox.Text
					Assembly=sort Assembly
					for i in Assembly do setinisetting iniFile "Assembly" (i as string) ""
					AssemblyComboBox.Items.Add (dotNetObject "System.String" AssemblyComboBox.Text)
				)
			)
		(AddFavorButton) :
			(
			if NetObjectsComboBox.Text !="" and findItem FavoritObjects NetObjectsComboBox.Text==0 then
				(
					append FavoritObjects NetObjectsComboBox.Text
					FavoritObjects=sort FavoritObjects
					for i in FavoritObjects do setinisetting iniFile "FavoritObject" (i as string) ""
					if findItem FillListArray NetObjectsComboBox.Text==0 then NetObjectsComboBox.Items.Add (dotNetObject "System.String" NetObjectsComboBox.Text)
				)
			)
		)
	)--Add_pressed

	AddFavorButton=dotNetObject "System.Windows.Forms.Button"
	AddFavorButton.FlatStyle=FlatStyle.System
	AddFavorButton.Width=12
	AddFavorButton.Height=22
	AddFavorButton.Location=dotNetObject "System.Drawing.Point" 258 26
	AddFavorButton.Text="+"
	dnToolTip.SetToolTip AddFavorButton "Save to Favorite List"
dotNet.addEventHandler AddFavorButton "Click" Add_pressed

AddAssemblyButton=dotNetObject "System.Windows.Forms.Button"
AddAssemblyButton.FlatStyle=FlatStyle.System
AddAssemblyButton.Width=12
AddAssemblyButton.Height=22
AddAssemblyButton.UseCompatibleTextRendering=true
AddAssemblyButton.Location=dotNetObject "System.Drawing.Point" 258 3
AddAssemblyButton.Text="+"
dnToolTip.SetToolTip AddAssemblyButton "Save to Assembly List"
dotNet.addEventHandler AddAssemblyButton "Click" Add_pressed

	FindButton=dotNetObject "System.Windows.Forms.Button"
	FindButton.FlatStyle=FlatStyle.System
	FindButton.Width=30
	FindButton.Height=22
	FindButton.Location=dotNetObject "System.Drawing.Point" 312 50
	FindButton.Text="Find"
dnToolTip.SetToolTip FindButton "Find in Selected Assembly Name\nPress Shift-key for search in all Assembly in list"

FilterButton=dotNetObject "System.Windows.Forms.Button"
FilterButton.FlatStyle=FlatStyle.System
FilterButton.Width=40
FilterButton.Height=22
FilterButton.Location=dotNetObject "System.Drawing.Point" 270 50
FilterButton.Text="Filter"

fn FilterButtonClick=
	(
	FillObjectsList()
	if FilterFindTextBox.text !="" then
		(
		FillListArray=for txt in FillListArray where matchpattern txt pattern:("*"+FilterFindTextBox.text+"*") ignoreCase:true collect txt
		NetObjectsComboBox.Items.Clear()
-- 		NetObjectsComboBox.Items.AddRange FillListArray
		AddRangeFunction NetObjectsComboBox FillListArray
		)
	)
dotNet.addEventHandler FilterButton "Click" FilterButtonClick

fn FindClick=(
		if FilterFindTextBox.Text.count>1 then(
			searchString=("*"+FilterFindTextBox.text+"*")
			FindTrue=true
			FindPropString=stringStream "\n"
			if keyboard.shiftPressed then AssemblySearchArray=Assembly
				else AssemblySearchArray = #(AssemblyComboBox.Text)
			for AsMName in AssemblySearchArray do
			(
				LoadAssembly AsMName
				k=0
				for txt in DotNetObjectsFromAssembly do
				(
					fromTextBoxShow=true
					MyDotNetName=txt
					PrintProperties()
					seek AllpropString 0
					n=0
					while not (eof AllpropString) do
					(
						txtLine=readLine AllpropString
						if matchPattern txtLine pattern:searchString ignoreCase:true then (
							if k ==0 then format "\n=========== % ================\n" AsMName to:FindPropString
							if n ==0 then format "\n---------- % ----------\n" txt to:FindPropString
							format "%\n" txtLine to:FindPropString
							k+=1
							n+=1
						)
					)
				if n==1 then format "\n\n" to:FindPropString
				)
			if k==1 then format "\n============================================================\n" to:FindPropString
			)
-- 		format (FindPropString as string)
		if filePos FindPropString !=0 then (
			if dn_tabs.TabCount == 5 then dn_tabs.TabPages.Add TabSearchResult
			dn_tabs.SelectedTab = TabSearchResult
			TextBoxSearchResult.Text=FindPropString as string
			appendIfUnique SearchSaveTextArray FilterFindTextBox.Text
			)else messageBox "Not Found!"
		FindTrue=false
		)
	)
dotNet.addEventHandler FindButton "Click" FindClick

local AutoCompleteString=dotNetObject "System.Windows.Forms.AutoCompleteStringCollection"
AutoCompleteCustomString=copy SearchSaveTextArray #noMap
AutoCompleteArray=for dotName in FavoritObjects collect (filterstring dotName ".")
AutoCompleteArray=for dotName in AutoCompleteArray collect dotName[dotName.count]
join AutoCompleteCustomString AutoCompleteArray
AutoCompleteString.AddRange AutoCompleteCustomString

FilterFindTextBox=dotNetObject "MaxCustomControls.MaxTextBox"
FilterFindTextBox.Width=108
FilterFindTextBox.Location=dotNetObject "System.Drawing.Point" 144 50
FilterFindTextBox.AllowDrop=true
FilterFindTextBox.AutoCompleteSource=FilterFindTextBox.AutoCompleteSource.CustomSource
FilterFindTextBox.AutoCompleteMode=FilterFindTextBox.AutoCompleteMode.Suggest
FilterFindTextBox.AutoCompleteCustomSource=AutoCompleteString
FilterFindTextBox.Text=SearchSaveText


------------------------------------------------START	MSDN-GROUPBOX
(
	btn_web_class=dotNetObject "System.Windows.Forms.Button"
	btn_web_class.FlatStyle=FlatStyle.System
	btn_web_class.Size=dotNetObject "System.Drawing.Size" 43 22
	btn_web_class.Location=dotNetObject "System.Drawing.Point" 4 9
	btn_web_class.Text="Msdn"
	dnToolTip.SetToolTip btn_web_class "Class web page"

btn_web_Members=dotNetObject "System.Windows.Forms.Button"
btn_web_Members.FlatStyle=FlatStyle.System
btn_web_Members.Size=btn_web_class.Size
btn_web_Members.Location=dotNetObject "System.Drawing.Point" 48 9
btn_web_Members.Text="Memb"
dnToolTip.SetToolTip btn_web_Members "Members web page"

	btn_web_Constructors=dotNetObject "System.Windows.Forms.Button"
	btn_web_Constructors.FlatStyle=FlatStyle.System
	btn_web_Constructors.Size=btn_web_class.Size
	btn_web_Constructors.Location=dotNetObject "System.Drawing.Point" 4 32
	btn_web_Constructors.Text="Const"
	dnToolTip.SetToolTip btn_web_Constructors "Constructors web page"

btn_web_Methods=dotNetObject "System.Windows.Forms.Button"
btn_web_Methods.FlatStyle=FlatStyle.System
btn_web_Methods.Size=btn_web_class.Size
btn_web_Methods.Location=dotNetObject "System.Drawing.Point" 48 32
btn_web_Methods.Text="Meth"
dnToolTip.SetToolTip btn_web_Methods "Methods web page"

	btn_web_Property=dotNetObject "System.Windows.Forms.Button"
	btn_web_Property.FlatStyle=FlatStyle.System
	btn_web_Property.Size=btn_web_class.Size
	btn_web_Property.Location=dotNetObject "System.Drawing.Point" 4 53
	btn_web_Property.Text= "Prop"
	dnToolTip.SetToolTip btn_web_Property "Properties web page"

btn_web_Events=dotNetObject "System.Windows.Forms.Button"
btn_web_Events.FlatStyle=FlatStyle.System
btn_web_Events.Size=btn_web_class.Size
btn_web_Events.Location=dotNetObject "System.Drawing.Point" 48 53
btn_web_Events.Text="Event"
dnToolTip.SetToolTip btn_web_Events "Events web page"

	fn openWebPage e arg =(
		test_text_Pressed()
-- 		format "%\n" dnObject
-- 		(dotNet.getType "gc").tostring()
		local page=""
		case e of
		(
			btn_web_class : page=""
			btn_web_Members : page="_members"
			btn_web_Constructors : page="Constructors"
			btn_web_Methods : page="_Methods"
			btn_web_Property : page="_properties"
			btn_web_Events : page="_Events"
		)
		lang = "en-us"
		if (sysinfo.getLanguage())[3]=="Russian" then lang = "ru-ru"
		if dnObject!=undefined then (
			if page=="Constructors" then (txt_arr=filterstring (dnObject as string) ":."; page ="."+(txt_arr[txt_arr.count]))
			ShellLaunch ("http://msdn.microsoft.com/" + lang + "/library/"+ ((filterstring (dnObject as string) ":")[2]) + page + ".aspx")""
		)
	)
	dotNet.addEventHandler btn_web_class "Click" openWebPage --""
	dotNet.addEventHandler btn_web_Members "Click" openWebPage --"_members"
	dotNet.addEventHandler btn_web_Constructors "Click" openWebPage --"Constructors"
	dotNet.addEventHandler btn_web_Methods "Click" openWebPage --"_Methods"
	dotNet.addEventHandler btn_web_Property "Click" openWebPage --"_properties"
	dotNet.addEventHandler btn_web_Events "Click" openWebPage --"_Events"

MsdnGroupBox=dotNetObject "System.Windows.Forms.GroupBox"
MsdnGroupBox.Size=dotNetObject "System.Drawing.Size" 95 78
MsdnGroupBox.Location=dotNetObject "System.Drawing.Point" 344 -4
MsdnGroupBox.Controls.Add btn_web_class
MsdnGroupBox.Controls.Add btn_web_Members
MsdnGroupBox.Controls.Add btn_web_Constructors
MsdnGroupBox.Controls.Add btn_web_Methods
MsdnGroupBox.Controls.Add btn_web_Property
MsdnGroupBox.Controls.Add btn_web_Events
)
------------------------------------------------END	MSDN-GROUPBOX

AssemblyComboBox=dotNetObject "System.Windows.Forms.ComboBox"
(dotnetclass "System.gc").SuppressFinalize AssemblyComboBox
(dotnetclass "System.gc").KeepAlive  AssemblyComboBox
-- AssemblyComboBox=dotNetObject "System.Windows.Forms.TextBox"
-- AssemblyComboBox=(dotNetObject "System.Windows.Forms.ToolStripComboBox").ComboBox
AssemblyComboBox.Width=250
AssemblyComboBox.DropDownWidth=400
AssemblyComboBox.Location=dotNetObject "System.Drawing.Point" 4 8
AssemblyComboBox.MaxDropDownItems=40
AssemblyComboBox.Sorted=true
AssemblyComboBox.AutoCompleteMode=AssemblyComboBox.AutoCompleteMode.Suggest
AssemblyComboBox.AutoCompleteSource=AssemblyComboBox.AutoCompleteSource.ListItems
AssemblyComboBox.Text=AssemblySaveText
AddRangeFunction AssemblyComboBox Assembly
-- AssemblyComboBox.Items.AddRange Assembly

	NetObjectsComboBox=dotNetObject "System.Windows.Forms.ComboBox"
(dotnetclass "System.gc").SuppressFinalize NetObjectsComboBox
(dotnetclass "System.gc").KeepAlive NetObjectsComboBox
-- 	NetObjectsComboBox=(dotNetObject "System.Windows.Forms.ToolStripComboBox").ComboBox
	NetObjectsComboBox.Width=250
	NetObjectsComboBox.DropDownWidth=400
	NetObjectsComboBox.Location=dotNetObject "System.Drawing.Point" 4 32
	NetObjectsComboBox.MaxDropDownItems=40
	NetObjectsComboBox.Sorted=true
	NetObjectsComboBox.AutoCompleteMode=NetObjectsComboBox.AutoCompleteMode.Suggest
	NetObjectsComboBox.AutoCompleteSource=NetObjectsComboBox.AutoCompleteSource.ListItems
	NetObjectsComboBox.Text=FavorObjectSaveText
-- 	NetObjectsComboBox.Items.AddRange FavoritObjects
	AddRangeFunction NetObjectsComboBox FavoritObjects

AssemblyRadioButton=dotNetObject "System.Windows.Forms.RadioButton"
AssemblyRadioButton.Width=71
AssemblyRadioButton.Location=dotNetObject "System.Drawing.Point" 4 52
AssemblyRadioButton.Checked=false
AssemblyRadioButton.Text="Assembly"
dotNet.addEventHandler AssemblyRadioButton "Click" FillObjectsList

	FavorRadioButton=dotNetObject "System.Windows.Forms.RadioButton"
	FavorRadioButton.Location=dotNetObject "System.Drawing.Point" 75 52
	FavorRadioButton.Checked=true
	FavorRadioButton.Text="Favorities"
	dotNet.addEventHandler FavorRadioButton "Click" FillObjectsList

AssemblyGroupBox=dotNetObject "System.Windows.Forms.GroupBox"
AssemblyGroupBox.Size=dotNetObject "System.Drawing.Size" 256 78
AssemblyGroupBox.Location=dotNetObject "System.Drawing.Point" 0 -4
AssemblyGroupBox.Controls.Add AssemblyComboBox
AssemblyGroupBox.Controls.Add NetObjectsComboBox
AssemblyGroupBox.Controls.Add AssemblyRadioButton
AssemblyGroupBox.Controls.Add FavorRadioButton

if (maxversion())[1]>11000 then (
		dotNet.setLifetimeControl AssemblyComboBox #dotnet
		dotNet.setLifetimeControl NetObjectsComboBox #dotnet
	)

-----------------------Filter by Class

	NetObjectsRadioButton=dotNetObject "System.Windows.Forms.RadioButton"
	NetObjectsRadioButton.Height=15
	NetObjectsRadioButton.Width=73
	NetObjectsRadioButton.Location=dotNetObject "System.Drawing.Point" 4 9
	NetObjectsRadioButton.Checked=false
	NetObjectsRadioButton.Text="NetObject"
	dotNet.addEventHandler NetObjectsRadioButton "Click" FillObjectsList

NetClassRadioButton=dotNetObject "System.Windows.Forms.RadioButton"
NetClassRadioButton.Width=74
NetClassRadioButton.Height=15
NetClassRadioButton.Location=dotNetObject "System.Drawing.Point" 75 9
NetClassRadioButton.Checked=false
NetClassRadioButton.Text="NetClass"
dotNet.addEventHandler NetClassRadioButton "Click" FillObjectsList

	AllObjectsRadioButton=dotNetObject "System.Windows.Forms.RadioButton"
	AllObjectsRadioButton.Height=15
	AllObjectsRadioButton.Width=35
	AllObjectsRadioButton.Location=dotNetObject "System.Drawing.Point" 150 9
	AllObjectsRadioButton.Checked=true
	AllObjectsRadioButton.Text="All"
	dotNet.addEventHandler AllObjectsRadioButton "Click" FillObjectsList


FilterGroupBox=dotNetObject "System.Windows.Forms.GroupBox"
FilterGroupBox.Size=dotNetObject "System.Drawing.Size" 256 28
FilterGroupBox.Location=dotNetObject "System.Drawing.Point" 0 72
FilterGroupBox.Controls.Add NetClassRadioButton
FilterGroupBox.Controls.Add NetObjectsRadioButton
FilterGroupBox.Controls.Add AllObjectsRadioButton

-----------------------Filter by Class	----end


dotNetPanel=dotNetObject "System.Windows.Forms.Panel"
dotNetPanel.Dock=DockStyle.Top
dotNetPanel.Height=100

dotNetPanel.Controls.Add GetSubClassesButton
dotNetPanel.Controls.Add PrintButton
dotNetPanel.Controls.Add AddFavorButton

dotNetPanel.Controls.Add AddAssemblyButton
dotNetPanel.Controls.Add LoadAssemblyButton

dotNetPanel.Controls.Add FindButton
dotNetPanel.Controls.Add FilterButton
dotNetPanel.Controls.Add FilterFindTextBox

dotNetPanel.Controls.Add MsdnGroupBox

dotNetPanel.Controls.Add AssemblyGroupBox
dotNetPanel.Controls.Add FilterGroupBox


contextMenu = dotNetObject "System.Windows.Forms.ContextMenuStrip"
contextMenu.RenderMode = contextMenu.RenderMode.Professional
contextMenu.ShowCheckMargin=true
contextMenu.ShowImageMargin=false

ShowPropItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Show Properties"
ExecuteItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Execute"

AddNotesItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Add to Notes"
MsdnItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Go to Msdn Site"
SearchInternetItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Search on Internet"
CopyItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Copy"
CopyDotNetObjectItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Copy as dotNetObject"
CopyDotNetClassItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Copy as dotNetClass"
PasteItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Paste"
ClearItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Clear"
SaveItem=dotNetObject "System.Windows.Forms.ToolStripMenuItem" "Save"

contextMenu.Items.Add ShowPropItem
contextMenu.Items.Add ExecuteItem
contextMenu.Items.Add AddNotesItem
contextMenu.Items.Add (dotNetObject "System.Windows.Forms.ToolStripSeparator")

contextMenu.Items.Add MsdnItem
contextMenu.Items.Add SearchInternetItem
contextMenu.Items.Add (dotNetObject "System.Windows.Forms.ToolStripSeparator")
contextMenu.Items.Add CopyItem
contextMenu.Items.Add CopyDotNetObjectItem
contextMenu.Items.Add CopyDotNetClassItem
contextMenu.Items.Add PasteItem
contextMenu.Items.Add ClearItem
contextMenu.Items.Add SaveItem

fn contextMenuClick sender args =
   (
	myTextBox=TextBoxArray[dn_tabs.SelectedIndex+1]
	poorText=" :;\,></-="
	txtArr=filterstring myTextBox.SelectedText poorText
	global txt=""
	for t in txtArr do txt+=t
     case args.ClickedItem.Text of
     (
 	 "Show Properties":
		(
			NetObjectsComboBox.Text=txt
			PrintProperties()
		)
	 "Execute":
		(
-- 			print myTextBox.SelectedText
			txt=stringstream myTextBox.SelectedText
			try execute txt catch(print(getCurrentException()))
		)
	"Add to Notes":
		(
			TextBoxNotes.AppendText myTextBox.SelectedText
		)
 	 "Go to Msdn Site":
		(
			fromTextBoxShow = true
			MyDotNetName=txt
			openWebPage btn_web_class (dotNetObject "System.EventArgs")
		)
 	 "Search on Internet":(ShellLaunch ("http://www.google.com/search?ie=UTF-8&oe=UTF-8&sourceid=navclient&gfns=1&q="+myTextBox.SelectedText)"")
 	 "Copy": setclipboardText myTextBox.SelectedText

 	 "Copy as dotNetObject": setclipboardText ("dotNetObject \"" +txt + "\"")
 	 "Copy as dotNetClass": setclipboardText ("dotNetClass \"" +txt + "\"")

 	 "Paste": myTextBox.Paste()
 	 "Clear": myTextBox.Clear()
 	 "Save":
		 (
			 if dn_tabs.SelectedIndex==4 then TextBoxNotes.SaveFile NotesFile
				 else (
					myText=NetObjectsComboBox.text
					if dn_tabs.SelectedIndex==5 then myText=FilterFindTextBox.Text
					file = getSaveFileName filename:((getFilenamePath (getSourceFileName()))+myText+"_"+myTextBox.name+".rtf")
					if file !=undefined and file !="" then myTextBox.SaveFile file
				 )
		 )
     )
   )


dotnet.addeventhandler contextMenu "ItemClicked" contextMenuClick

fn contextMenuOpen e arg=(
		AddNotesItem.enabled= dn_tabs.SelectedIndex!=4
-- 		e.Items.Item[1].Visible= dn_tabs.SelectedIndex!=4

	)

dotnet.addeventhandler contextMenu "Opening" contextMenuOpen


fn CreateRichTextBox RichTextBox=(
		RichTextBox.Dock=DockStyle.Fill
	-- 	RichTextBox.AutoWordSelection=true
		RichTextBox.WordWrap=false
		RichTextBox.EnableAutoDragDrop=true
		RichTextBox.RichTextShortcutsEnabled =true
		RichTextBox.HideSelection=false
		RichTextBox.ContextMenuStrip = contextMenu
	)

	PropertyTextBox=dotNetObject "System.Windows.Forms.RichTextBox"
	PropertyTextBox.Name="ShowProperties.rtf"
-- 	PropertyTextBox=dotNetObject "MaxCustomControls.MaxTextBox"

	TextBoxMethods=dotNetObject "System.Windows.Forms.RichTextBox"
	TextBoxMethods.name="Methods.rtf"
	TextBoxEvents=dotNetObject "System.Windows.Forms.RichTextBox"
	TextBoxEvents.name="Events.rtf"
	TextBoxConstructors=dotNetObject "System.Windows.Forms.RichTextBox"
	TextBoxConstructors.name="Constructors.rtf"
	TextBoxNotes=dotNetObject "System.Windows.Forms.RichTextBox"
	TextBoxSearchResult=dotNetObject "System.Windows.Forms.RichTextBox"
	TextBoxSearchResult.name="SearchResult.rtf"

TextBoxArray=#(PropertyTextBox,TextBoxMethods,TextBoxEvents,TextBoxConstructors,TextBoxNotes,TextBoxSearchResult)

for txt_box in TextBoxArray do CreateRichTextBox txt_box
if not doesFileExist NotesFile then TextBoxNotes.SaveFile NotesFile

TextBoxNotes.LoadFile NotesFile

dn_tabs=dotNetObject "System.Windows.Forms.TabControl"
dn_tabs.Dock=DockStyle.Fill
dn_tabs.Multiline = true
dn_tabs.ShowToolTips=true
dn_tabs.Cursor=(dotnetclass "System.Windows.Forms.Cursors").Hand

TabProperties=dotNetObject "System.Windows.Forms.TabPage" "Properties"
TabMethods=dotNetObject "System.Windows.Forms.TabPage" "Methods"
TabEvents=dotNetObject "System.Windows.Forms.TabPage" "Events"
TabConstructors=dotNetObject "System.Windows.Forms.TabPage" "Constructors"
TabNotes=dotNetObject "System.Windows.Forms.TabPage" "Notes"
-- TabIniFile=dotNetObject "System.Windows.Forms.TabPage" "Ini-file"
TabSearchResult=dotNetObject "System.Windows.Forms.TabPage" "Search Result"

tabPageArray=#(TabProperties,TabMethods,TabEvents,TabConstructors,TabNotes/* ,TabSearchResult,TabIniFile */)

for i in 1 to tabPageArray.count do tabPageArray[i].Controls.Add TextBoxArray[i]
TabSearchResult.Controls.Add TextBoxSearchResult

dn_tabs.TabPages.AddRange tabPageArray

StatusStrip=dotNetObject "System.Windows.Forms.StatusStrip"
StatusStrip.RenderMode=StatusStrip.RenderMode.Professional

local Padding=dotnetObject "Padding" 0 0 0 0

ToolStripTextBox=dotNetObject "MaxCustomControls.MaxToolStripTextBox" "Search"
ToolStripTextBox.AutoCompleteSource=FilterFindTextBox.AutoCompleteSource.CustomSource
ToolStripTextBox.AutoCompleteMode=FilterFindTextBox.AutoCompleteMode.Suggest
ToolStripTextBox.AutoCompleteCustomSource=AutoCompleteString
ToolStripTextBox.TextBox.MaximumSize=dotnetobject "System.Drawing.Size" 100 16
ToolStripTextBox.TextBox.Location=dotnetobject "System.Drawing.Point" 8 2
Padding.Left=8
ToolStripTextBox.Padding=Padding
ToolStripTextBox.Owner=StatusStrip

btn_find = dotNetObject "System.Windows.Forms.ToolStripButton" "Find"
btn_find.DisplayStyle = btn_find.DisplayStyle.Text
btn_find.Owner = StatusStrip

RichTextBoxFinds=dotNetClass "System.Windows.Forms.RichTextBoxFinds"
fn TextBoxSearch =
	(
		myTextBox=TextBoxArray[dn_tabs.SelectedIndex+1]
-- 		print ToolStripTextBox.text
		if myTextBox!=TextBoxNotes then
		(
				selText=myTextBox.SelectedText
				selTextStart=myTextBox.SelectionStart
				myTextBox.SelectAll()
				myTextBox.SelectionBackColor =  (dotNetClass "System.Drawing.Color").white
				myTextBox.DeselectAll()
				local n=1
				local txtLength=myTextBox.TextLength
				if ToolStripTextBox.text !="" then
					(
						for i in 1 to txtLength where i==n/*  while n<=txtLength  */do(
						myTextBox.Find ToolStripTextBox.text n -1 RichTextBoxFinds.None
						myTextBox.SelectionBackColor =  (dotNetClass "System.Drawing.Color").Yellow
						n=myTextBox.SelectionStart+myTextBox.SelectionLength
						)
					)
			if selText !="" then myTextBox.Find selText selTextStart -1 RichTextBoxFinds.MatchCase
				else myTextBox.DeselectAll()
			myTextBox.SelectionBackColor =  (dotNetClass "System.Drawing.Color").white
		)
	)
dotNet.addEventHandler ToolStripTextBox "TextChanged" TextBoxSearch
dotNet.addEventHandler btn_find "Click" TextBoxSearch

LinkLabel=dotNetObject "System.Windows.Forms.toolStripStatusLabel"
LinkLabel.Text="http://3d-kstudio.com"
LinkLabel.TextAlign=LinkLabel.TextAlign.MiddleRight
tSize = (dotnetclass "TextRenderer").MeasureText LinkLabel.Text LinkLabel.Font

LinkLabel.isLink=true
LinkLabel.Owner=StatusStrip
LinkLabel.LinkBehavior=LinkLabel.LinkBehavior.HoverUnderline

fn LinkClicked = ShellLaunch "http://3d-kstudio.com" ""
dotNet.addEventHandler LinkLabel "Click" LinkClicked

fn NetPropertyFormClose=(
		TextBoxNotes.SaveFile NotesFile

		if NetPropertyForm.WindowState != (dotNetClass "System.Windows.Forms.FormWindowState").Normal then
		(
			DialogPos = [NetPropertyForm.RestoreBounds.Location.x,NetPropertyForm.RestoreBounds.Location.y]
			DialogWidth = NetPropertyForm.RestoreBounds.Width
			DialogHeight = NetPropertyForm.RestoreBounds.Height
		)
		else
		(
			DialogPos = [NetPropertyForm.Location.x,NetPropertyForm.Location.y]
			DialogWidth = NetPropertyForm.Width
			DialogHeight = NetPropertyForm.Height
		)

		setinisetting iniFile "Interface" "Size" ([DialogWidth,DialogHeight] as string)
		setinisetting iniFile "Interface" "Location" (DialogPos as string)

		if AssemblyRadioButton.Checked then AssemblyObjectSaveText=NetObjectsComboBox.Text
		if FavorRadioButton.Checked then FavorObjectSaveText=NetObjectsComboBox.Text

		setinisetting iniFile "Interface" "AssemblySaveText" AssemblyComboBox.Text
		setinisetting iniFile "Interface" "AssemblyObjectSaveText" AssemblyObjectSaveText
		setinisetting iniFile "Interface" "FavorObjectSaveText" FavorObjectSaveText
		if FilterFindTextBox.Text!="" then setinisetting iniFile "Interface" "SearchSaveText" FilterFindTextBox.Text
		for i in SearchSaveTextArray do setinisetting iniFile "SearchSaveTextArray" (i as string) ""

		for txt_box in TextBoxArray do (
				txt_box.ClearUndo()
				txt_box.Dispose()
			)
		(dotnetclass "System.gc").ReRegisterForFinalize NetObjectsComboBox
		(dotnetclass "System.gc").ReRegisterForFinalize AssemblyComboBox
		NetObjectsComboBox.Dispose()
		AssemblyComboBox.Dispose()
		NetPropertyForm.Dispose()
		(dotnetclass "System.gc").collect()
		gc()
-- 		gc light:true
	)

	NetPropertyForm.Controls.Add dn_tabs
	NetPropertyForm.Controls.Add dotNetPanel
	NetPropertyForm.Controls.Add StatusStrip
	NetPropertyForm.StartPosition=NetPropertyForm.StartPosition.Manual
	NetPropertyForm.Location=dotNetObject "System.Drawing.Point" formLocation[1] formLocation[2]

fn NetPropertyFormSizeChanged = (
-- 	Padding.Left=((NetPropertyForm.Width-tSize.Width-200)/2)
	Padding.Left=((NetPropertyForm.Width-tSize.Width-300)/2)
	LinkLabel.Padding=Padding
)
NetPropertyFormSizeChanged()

	dotNet.addEventHandler NetPropertyForm "SizeChanged" NetPropertyFormSizeChanged
	dotNet.addEventHandler NetPropertyForm "Closed" NetPropertyFormClose

	NetPropertyForm.ShowInTaskBar=true
	NetPropertyForm.ShowModeless()

	(dotnetclass "System.gc").collect()
)
