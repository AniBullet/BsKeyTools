try(destroydialog WindowBox)catch()
Struct LR_WindowBoxIconArrayStruct 
(		
    fn ConvertBase64StringToImage string filepath =
        (	
            if not doesfileexist filepath then
            (
            bytearr = (dotnetclass "system.convert").FromBase64String string
            memstream = dotnetobject "System.IO.MemoryStream" bytearr
            DecodedImg = (dotnetclass "system.drawing.image").fromstream memstream
            DecodedImg.Save filepath (dotnetclass "System.Drawing.Imaging.ImageFormat").png
            memstream.close()
            (dotnetclass "System.GC").Collect()
            true
            )
            else false
        ),			
    
        on create do 
        (
        AssetDir = (((getDir #scripts) + "\\BulletScripts\\Res") + "\\LoneRobot\\Assets\\Icons\\")			
        Base64Array = #("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABkSURBVDhPY2AYNGAqA4PBLHaG/yCMy1EweZBaDDUgyf85KWCMzRBC8gzICtANwSeH4hJsConWDDMJXQPMW7i8hjW8sBmCL3DxBii+gCXadqINoSgQKY5GQgmFkDwDxUl5wDIlAJDs1e2XYdTMAAAAAElFTkSuQmCC",
                                    "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAB+SURBVDhPY2DAAyztPf7jk8crB9IMwyQbgqyZbENAtlLkBbKcDdMEtHkTFm9sQpJHDVx0f4L46ADZOyjq0W2C+f3mnUf/kTHMAGzqwYGFbsOjpy//I2OcLsDmL5DiN28/oGB0AwglIryBSHIMka2B7IRElaRMUWbCmeKwBAYATcmjtayLrD4AAAAASUVORK5CYII=",
                                        "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAC6SURBVDhPrZNNCsJADEa790Su3HoKFdSN7QE8gmuXXsBTeBSh4H9ptaVSa+kQm4gfKgjT1MAj80HyyGacdqdLTXB4mWu+WNaGd0XQBFwgZ9QsXLD2d6QBAn9zpNY0BpxtgGC7D2R5tsqlv/K79PvNMxAcTuHHBZxtgCAIL6QBguickAYI4iSl3nBS4UrnbAME6TWj/sgjY4x0zk/Zb3gGguyWV4suDcaedM42QHAvCtIAQVka0vCXz/QAti/6k/G1yaEAAAAASUVORK5CYII=")

        if not doesfileexist AssetDir then makedir AssetDir				
        arrIconPath = #((AssetDir + "WBclose.png"),(AssetDir + "WBmove.png"),(AssetDir + "WBwin.png"))	
        for i = 1 to arrIconPath.count do ConvertBase64StringToImage Base64Array[i] arrIconPath[i]
        )--end create				
)-- end LR_WindowBoxIconArrayStruct 

Struct MonitorInfoStruct 
(
    MonitorOps,
    Primary,
    Secondary,
    Count,
    SecondMonitorPresent,
    PrimaryBounds,
    SecondaryBounds,
    PrimaryWorkingArea,
    SecondaryWorkingArea,
    
    on create do 
    (
    MonitorOps = (dotnetclass "System.Windows.Forms.Screen")		
    Count = MonitorOps.AllScreens.count
    SecondMonitorPresent = if Count > 1 then true else false
    Primary = MonitorOps.primaryscreen
    
    if Primary != undefined then 
        (
        PrimaryWorkingArea= [MonitorOps.primaryscreen.WorkingArea.Width,MonitorOps.primaryscreen.WorkingArea.Height]
        PrimaryBounds= [MonitorOps.primaryscreen.bounds.Width, MonitorOps.primaryscreen.bounds.Height]
        )
        
        If SecondMonitorPresent then 
        (
            Secondary = MonitorOps.AllScreens[1]
            SecondaryWorkingArea= [MonitorOps.AllScreens[1].WorkingArea.Width,MonitorOps.AllScreens[1].WorkingArea.Height]	
            SecondaryBounds= [MonitorOps.AllScreens[1].bounds.Width,MonitorOps.AllScreens[1].bounds.Height]			
        )
    )		
)	

-- build the icons, unless they already exist. 
LR_WindowBoxIconArrayStruct()	
rollout WindowBox "WindowBox【找回窗口】" width:520 height:0
(	
    local AssetDir = (((getDir #scripts) + "\\BulletScripts\\Res") + "\\LoneRobot\\Assets\\Icons\\")						
    local WindowIcon 
    local CloseIcon 
    local ResetIcon		
    local ColorClass = DotNetClass "System.Drawing.Color"
    local DataGridFont = dotNetObject "System.Drawing.Font" "Verdana" 9 ((dotNetClass "System.Drawing.FontStyle").regular)
    local HeaderFont = dotNetObject "System.Drawing.Font" "Verdana" 7 ((dotNetClass "System.Drawing.FontStyle").regular)
    local DataGridSizeMode= (dotnetclass "system.windows.forms.DatagridviewAutoSizeColumnMode")	
    local ResizeCol = dotnetclass "system.windows.forms.DataGridViewTriState"
    local ContAlign =  dotnetclass "System.Drawing.ContentAlignment"
    local CellBG = ColorClass.dimgray
    Local CellFG = ColorClass.white
    local WindowOps 
    local DialogList 
    local StrWindowList
    local arrWinSize 
    local arrWinPos 
    
    fn DialogWindowOpsClass = 
    (
        source = ""
        source += "Imports System.Runtime.InteropServices\n"
        source += "Imports System.Drawing\n"
        source += "Public Class DialogWindowOps\n"
        source += "Public Structure RECT\n"
        source += "Public left As Integer\n"
        source += "Public top As Integer\n"
        source += "Public right As Integer\n"
        source += "Public bottom As Integer\n"
        source += "Public ReadOnly Property Width() As Integer\n"
        source += "Get\n"
        source += "Return right - left\n"
        source += "End Get\n"
        source += "End Property\n"
        source += "Public ReadOnly Property Height() As Integer\n"
        source += "Get\n"
        source += "Return bottom - top\n"
        source += "End Get\n"
        source += "End Property\n"
        source += "End Structure\n"
        source += "Public Structure POINTAPI\n"
        source += "Public x As Integer\n"
        source += "Public y As Integer\n"
        source += "End Structure\n"
        source += "Public Structure WINDOWPLACEMENT\n"
        source += "Public Length As Integer\n"
        source += "Public flags As Integer\n"
        source += "Public showCmd As Integer\n"
        source += "Public ptMinPosition As POINTAPI\n"
        source += "Public ptMaxPosition As POINTAPI\n"
        source += "Public rcNormalPosition As RECT\n"
        source += "End Structure\n"
        source += "<DllImport(\"user32.dll\")> _\n"
        source += "Public Shared Function MoveWindow(ByVal hWnd As System.IntPtr, ByVal x As Integer, ByVal y As Integer, ByVal nWidth As Integer, ByVal nHeight As Integer, ByVal bRepaint As Boolean) As Boolean\n"
        source += "End Function\n"
        source += "<DllImport(\"user32.dll\")> _\n"
        source += "Public Shared Function GetWindowRect(ByVal hWnd As System.IntPtr, ByRef lpRect As RECT) As Boolean\n"
        source += "End Function\n"
        source += "<DllImport(\"user32.dll\")> _\n"
        source += "Public Shared Function GetWindowPlacement(ByVal hWnd As System.IntPtr, ByRef lpwndpl As WINDOWPLACEMENT) As Boolean\n"
        source += "End Function\n"
        source += "Public Function WindowSize(ByVal Hwnd As System.IntPtr) As System.Drawing.Size\n"
        source += "Dim LPRECT As RECT\n"
        source += "GetWindowRect(Hwnd, LPRECT)\n"
        source += "Dim WinSize As System.drawing.size = New System.drawing.size(LPRECT.Width, LPRECT.Height)\n"
        source += "Return WinSize\n"
        source += "End Function\n"
        source += "Public Function WindowPosition(ByVal Hwnd As System.IntPtr) As System.Drawing.Point\n"
        source += "Dim intRet As Integer\n"
        source += "Dim wpTemp As WINDOWPLACEMENT = New WINDOWPLACEMENT()\n"
        source += "wpTemp.Length = System.Runtime.InteropServices.Marshal.SizeOf(wpTemp)\n"
        source += "intRet = GetWindowPlacement(Hwnd, wpTemp)\n"
        source += "Dim WinPoint As System.drawing.point = New System.drawing.point(wpTemp.rcNormalPosition.left, wpTemp.rcNormalPosition.top)\n"
        source += "Return WinPoint\n"
        source += "End Function\n"
        source += "End Class"  

        VBProvider = dotnetobject "Microsoft.VisualBasic.VBCodeProvider"
        compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
        compilerParams.ReferencedAssemblies.add "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.drawing.dll"	
        compilerParams.GenerateInMemory = on
        compilerResults = VBProvider.CompileAssemblyFromSource compilerParams #(source)		
        -- this is very useful to debug your source code and check for referencing errors
            if (compilerResults.Errors.Count > 0 ) then
            (
                errs = stringstream ""
                for i = 0 to (compilerResults.Errors.Count-1) do
                (
                    err = compilerResults.Errors.Item[i]
                    format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line \											  
                                                            err.Column err.ErrorText to:errs 
                )
                MessageBox (errs as string) title: "编译VB代码时遇到的错误"
                return undefined
            ) 	
        return compilerResults.CompiledAssembly.CreateInstance "DialogWindowOps"
    )


    fn InitColumnProperties col coltext readonly colwidth fcolor bcolor autosize resizable divider:false=
    (
        Col.resizable = (dotnetclass "system.windows.forms.DataGridViewTriState").false
        Col.headerText = coltext
        Col.readOnly = readonly
        Col.width = colwidth
        Col.Defaultcellstyle.selectionbackcolor = colorclass.orangered
        Col.Defaultcellstyle.backcolor = bcolor			
        Col.Defaultcellstyle.forecolor =  fcolor
        Col.autosizemode = autosize
        Col.resizable = resizable
        Col.Defaultcellstyle.font = DataGridFont	
        if divider then Col.dividerwidth = 2
        return Col
    )
            
    fn InitDataGrid data =
    (
        if WindowBox.open then 
            (
            arrWinSize = #()
            arrWinPos = #()
            StrWindowList=#()
            -- Get Max Dialogs
            DialogList = for i in (windows.getChildrenHWND 0 parent:#max) where 
            UIAccessor.IsWindow i[1] and (not i[5] == "AdApplicationButton") and (not i[5] == "") collect i[1]
            StrWindowList= for i in DialogList collect (UIAccessor.GetWindowText i)	
            handleRenderOptionFloater = findItem StrWindowList ""					
            if not handleRenderOptionFloater == 0 then (deleteitem DialogList handleRenderOptionFloater;deleteitem StrWindowList handleRenderOptionFloater)					
        
                for i in DialogList do
                (
                    intptrHwnd = dotnetobject "System.Intptr" i					
                    append arrWinSize (WindowOps.windowsize intptrHwnd)
                    append arrWinPos (WindowOps.WindowPosition intptrHwnd)
                )	
            -- Get the Windows that aren't parented to the Max Session	
                for i in (windows.getChildrenHWND 0) where i[4] == "MXS_SciTEWindow" or i[4] == "NodeJoeMainWindow" do
                (
                    if i[4] == "MXS_SciTEWindow" then
                    (
                    insertitem "Maxscript Editor" StrWindowList 2
                    insertitem i[1] DialogList 2	
                    intptrHwnd = dotnetobject "System.Intptr" i[1]
                    insertitem (WindowOps.WindowPosition intptrHwnd) arrWinPos 2
                    insertitem (WindowOps.windowsize intptrHwnd) arrWinSize 2	
                    )
                    else
                    (
                        if sme != undefined and sme.isopen() then 
                        (	
                        insertitem i[1] DialogList 2
                        insertitem "Slate Material Editor" StrWindowList 2
                        intptrHwnd = dotnetobject "System.Intptr" i[1]
                        insertitem (WindowOps.WindowPosition intptrHwnd) arrWinPos 2
                        insertitem (WindowOps.windowsize intptrHwnd) arrWinSize 2
                        )
                    )
                                        
                )

            data.columns.clear()		
            
            local dgvImageCol = dotNetObject "System.Windows.Forms.DataGridViewImageColumn"
            InitColumnProperties dgvImageCol "" true	24 undefined CellBG DataGridSizeMode.none ResizeCol.false

            local dgvWindowCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvWindowCol "Window" true 260 CellFG CellBG DataGridSizeMode.fill ResizeCol.false divider:true
                        
            local dgvPosxCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvPosxCol  "Xpos" false 40 CellFG CellBG DataGridSizeMode.none ResizeCol.false 
                
            local dgvHbyCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvHbyCol "" true 14 CellFG CellBG DataGridSizeMode.none ResizeCol.false 
                        
            local dgvPosyCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvPosyCol "Ypos" false 40 CellFG CellBG DataGridSizeMode.none ResizeCol.false divider:true
                
            local dgvHWNDCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvHWNDCol "handle" true 80 CellFG CellBG DataGridSizeMode.none ResizeCol.false divider:true
                
            local dgvWidthCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvWidthCol  "w" false 40 CellFG CellBG DataGridSizeMode.none ResizeCol.false 
                
            local dgvbyCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvbyCol  "" true 14 CellFG CellBG DataGridSizeMode.none ResizeCol.false 
                        
            local dgvHeightCol = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
            InitColumnProperties dgvHeightCol "h" false 40 CellFG CellBG DataGridSizeMode.none ResizeCol.false divider:true
                
            local dgvResetCol = dotNetObject "System.Windows.Forms.DataGridViewImageColumn"
            InitColumnProperties dgvResetCol "" true 24 CellFG Colorclass.yellow DataGridSizeMode.none ResizeCol.false divider:true
            dgvResetCol.tooltiptext = "Set Dialog"			

            local xCol = dotNetObject "System.Windows.Forms.DataGridViewImageColumn"			
            InitColumnProperties xCol "" true 24 undefined CellBG DataGridSizeMode.none ResizeCol.false
            xcol.tooltiptext = "Press the X icon to close the dialog"				
                    
            data.columns.addrange #(dgvImageCol,dgvWindowCol,dgvPosxCol,dgvHbyCol,dgvPosyCol,dgvHWNDCol,dgvWidthCol,dgvbyCol,dgvHeightCol,dgvResetCol,xcol)
            
            CellStyle = dotnetobject "system.Windows.Forms.DataGridViewCellStyle"
            Cellstyle.font = HeaderFont
            
            data.multiselect = false
            data.Visible = true
            data.RowHeadersVisible = false			
            data.ColumnHeadersHeight = 16
            data.ColumnHeadersDefaultCellStyle = CellStyle
            data.cellborderstyle= (dotnetclass "System.Windows.Forms.DataGridViewCellBorderStyle").none
            data.AllowUserToAddRows = false
            data.AllowUserToDeleteRows = false
            data.AllowUserToOrderColumns = false
            --data.AllowUserToResizeColumns = true
            data.AllowUserToResizeRows = false
            data.ColumnHeadersHeightSizeMode = (dotnetclass "System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode").DisableResizing    
            data.EnableHeadersVisualStyles = False
            data.ColumnHeadersBorderStyle = (dotnetclass "System.Windows.Forms.DataGridViewHeaderBorderStyle").none	
        
            data.selectionmode = data.selectionmode.fullrowselect
            
            for o = 1 to DialogList.count do 
            (					
            Data.rows.add  #(WindowIcon, StrWindowList[o], arrWinPos[o].x,"x",arrWinPos[o].y,DialogList[o],arrWinSize[o].width,"x",arrWinSize[o].height,ResetIcon,CloseIcon)			
            (data.item 5 (o-1)).style.forecolor = if o == 1 then colorclass.chartreuse else colorclass.yellow
            )	

            WindowBox.height = 42+ (Data.Rows.GetRowsHeight ((dotnetclass "DataGridViewElementStates").Displayed))
            
            try -- setting the height cell value after the adjustment
            (
                intptrHwnd = dotnetobject "System.Intptr" DialogList[1]
                ((Data.rows.item [0]).cells.item 8).value = (WindowOps.windowsize intptrHwnd).height
            )
            catch()
            
        )			
    )
    
    dotNetControl ResizeColBanner "Label" pos:[0,0] width:520 height:24
    dotNetControl data "System.Windows.Forms.DataGridView" pos:[0,24] width:520 height:1000
            
    on WindowBox open do
    (	
        WindowOps = DialogWindowOpsClass() 
            
        WindowIcon =  (dotNetclass "System.Drawing.image").fromfile (AssetDir + @"WBwin.png")
        CloseIcon =   (dotNetclass "System.Drawing.image").fromfile (AssetDir + @"WBclose.png")
        ResetIcon =   (dotNetclass "System.Drawing.image").fromfile (AssetDir + @"WBmove.png")	

        ResizeColBanner.backcolor =  colorclass.fromargb 51 83 102
        ResizeColBanner.text = "双击左侧的窗口图标或右侧四方箭头图标可将窗口重置为屏幕左上方"
        ResizeColBanner.forecolor = colorclass.lightgray
        ResizeColBanner.textalign = ContAlign.middleleft
        ResizeColBanner.padding =dotNetobject "System.Windows.Forms.padding" 6 4 10 4		
        ResizeColBanner.font = dotNetObject "System.Drawing.Font" "Verdana" 9.0 ((dotNetClass "System.Drawing.FontStyle").bold)

        InitDataGrid data		
    )
        
    on data CellContentClick sender args do 
    (		
        --print args.rowIndex 
            case args.columnIndex of
            (
            5:(
                -- do  not include column header in click
                if args.RowIndex != -1 then	
                    (
                        if keyboard.controlpressed then
                        (
                        local StrHwnd =((((Data.rows.item [args.RowIndex]).cells.item 5).value) as string)
                        if querybox ("Window Handle - " + StrHwnd + "\n\nCopy this value to the clipboard?") title:"LoneRobot Tools" then
                        setclipboardText StrHwnd
                        )
                    )				
                )
            9:(
                if args.RowIndex != -1 then	
                    (
                        if ((Data.rows.item [args.RowIndex]).cells.item 1).value == "Slate Material Editor" then
                        (
                            if sme.isopen() then 
                            (
                                objsme =sme.GetMainframe()
                                local px = (((Data.rows.item [args.RowIndex]).cells.item 2).value) as integer
                                local py = (((Data.rows.item [args.RowIndex]).cells.item 4).value) as integer
                                local w = (((Data.rows.item [args.RowIndex]).cells.item 6).value) as integer
                                local h = (((Data.rows.item [args.RowIndex]).cells.item 8).value) as integer
                                objsme.position = [px,py]
                                objsme.size = [w,h]	
                            )										
                        )
                        else
                        (								
                        intptrHwnd = dotnetobject "System.Intptr" (((Data.rows.item [args.RowIndex]).cells.item 5).value as integer)
                        local px = (((Data.rows.item [args.RowIndex]).cells.item 2).value) as integer
                        local py = (((Data.rows.item [args.RowIndex]).cells.item 4).value) as integer
                        local w = (((Data.rows.item [args.RowIndex]).cells.item 6).value) as integer
                        local h = (((Data.rows.item [args.RowIndex]).cells.item 8).value) as integer
                        WindowOps.MoveWindow intptrHwnd px py w h true 
                        )							
                    InitDataGrid data		
                    )					
                )
            10:(
                if args.RowIndex != -1 then
                    (
                        if ((Data.rows.item [args.RowIndex]).cells.item 1).value == "Slate Material Editor" then
                        (
                            if sme.isopen() then sme.close()
                        )
                        else
                        (
                        UIAccessor.CloseDialog DialogList[args.RowIndex+1] 
                        )
                        completeRedraw()
                        InitDataGrid data		
                    )						
                )
                default:()
            )				
    )
        
    on data CellContentDoubleClick sender args do 
    (			
            case args.columnIndex of
            (
            0:(
                if args.RowIndex != -1 then	
                    (	
                        if ((Data.rows.item [args.RowIndex]).cells.item 1).value == "Slate Material Editor" then
                        (
                                if sme.isopen() then (sme.GetMainframe()).position = [0,0]
                        )
                        else
                        (									
                        intptrHwnd = dotnetobject "System.Intptr" (((Data.rows.item [args.RowIndex]).cells.item 5).value as integer)
                        local w = (((Data.rows.item [args.RowIndex]).cells.item 6).value) as integer
                        local h = (((Data.rows.item [args.RowIndex]).cells.item 8).value) as integer
                        WindowOps.MoveWindow intptrHwnd 0 0 w h true 
                        )
                    InitDataGrid data		
                    )					
                )
            default:()
            )				
    )

    on data CellEndEdit sender args do 
    (		
        if args.RowIndex != -1 then	
            ( 																
                intptrHwnd = dotnetobject "System.Intptr" (((Data.rows.item [args.RowIndex]).cells.item 5).value as integer)
                local px = (((Data.rows.item [args.RowIndex]).cells.item 2).value) as integer
                local py = (((Data.rows.item [args.RowIndex]).cells.item 4).value) as integer
                local w = (((Data.rows.item [args.RowIndex]).cells.item 6).value) as integer
                local h = (((Data.rows.item [args.RowIndex]).cells.item 8).value) as integer
                WindowOps.MoveWindow intptrHwnd px py w h true 
            )						
    )
)
    MonitorInfo = MonitorInfoStruct()
    
    if MonitorInfo != undefined then
    (		
    w = MonitorInfo.PrimaryWorkingArea.x
    h = MonitorInfo.PrimaryWorkingArea.y
    createdialog WindowBox style:#(#style_toolwindow,#style_sysmenu)
    posw = (w - WindowBox.width)/2
    posh = (h - WindowBox.Height)/2
    setdialogpos Windowbox [posw,posh]	
    )
    else createdialog WindowBox style:#(#style_toolwindow,#style_sysmenu)