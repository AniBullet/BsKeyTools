/*
https://obaidaviz.gumroad.com/l/vzOPnx
- You Can Add New Import Extension to Import List By Adding it to "BIC_Import_arr"
- to Add New Export Extension You Need to Add it to "BIC_Export_arr" And Add its Class to "FindExporterClass" Function

V 2.1 :
- Saving Material Library to Lower Version was not Working Properly . Fixed .
Important Notes :
- to do Material Library Converting you need Max Version that can open this Material Libraries .
- to Save Material Library to Lower Version You Need to do 2 Covnert with 2 Different Max Versions 
  1 - Run the Script on [Higher Max Version] - Add Matlib Path and do Convert as Following : (Input : Open - MAT ------- Output : Save Max - Lower Version)
  2 - Run the Script on [Lower Max Version] - Add Matlib Path and do Convert as Following : (Input : Open - MAX------- Output : Save Mat - Current Version)
  
V 2.2 :
- Add Checkbox to convert poly objects to mesh when using max 2021+ and saving max files to previous versions , OR the poly objects may get vertex distortion .
*/

try(if BatchImportConvert != undefined do destroyDialog BatchImportConvert)catch()
global BatchImportConvert, BICDefault

if BICDefault == undefined or BICDefault.count != 18 do BICDefault = #(true,false,0,false,0,false,1,1,1,1,4,false,true,unsupplied)
	
rollout BatchImportConvert "批量转换_BatchImportConvert_2.2" width:325 height:355
(
	local import_path, BIC_max_path, BIC_file_tag, BIC_SepDir, BIC_new_name, import_folders = #(), arr_import_files = #(), BIC_Scripts = #(),
	BIC_Import_arr_EXT, BIC_Subfolders_state = true, save_prv_state = false,
	BIC_inIdx, BIC_outIdx, BIC_TotalNumber, _user32, DXFClass, BIC_InEXT = ".max", BIC_OutEXT, BIC_timer = 0, BIC_timerStr = "",
	BIC_Prv_arr = #("JPG","BMP","PNG","TGA","TIF"),
	BIC_Input_arr = #("Import","Open"),
	BIC_Import_arr = #("All","FBX","3DS","OBJ","SKP","DWG","DXF","DWF","AI","STL","ABC","SAT","DAE","IGS","W3D","FLT","ASE"),
	BIC_Open_arr = #("MAX","MAT"),
	BIC_Output_arr = #("Save as","Export"), BIC_Output_arr_MAX = #("Save as", "Export", "Save Mat"), BIC_Output_arr_MAT = #("Save as"),
	BIC_Saveas_arr = for i = 0 to 3 collect ("20" + (((maxversion())[1]/1000)-2-i) as string),
	BIC_Export_arr = #("FBX","3DS","OBJ","DWG","DXF","DWF","AI","STL","ABC","SAT","DAE","IGS","W3D","FLT","ASE"),
	ExClasses = exporterPlugin.classes
--( UI
	groupbox 'g1' "       保存预览  " pos:[5,5] width:315 height:45
	checkbox 'save_prv' "" pos:[10,5] width:15 height:15
	checkbox 'cstm_prv' "" pos:[15,27] width:15 height:15 tooltip:"自定义预览图分辨率"
	spinner 'prv_width' "Width : " pos:[40,27] fieldWidth:45 type:#integer range:[0,2000,0]
	spinner 'prv_height' "Height : " pos:[140,27] fieldWidth:45 type:#integer range:[0,2000,0]
	dropdownList 'prv_type' ""  pos:[252,22] width:60 items:BIC_Prv_arr
	
	groupbox 'g2' "  输入  " pos:[5,55] width:155 height:45
	dropdownList 'List_Input' ""  pos:[12,73] width:65 items:BIC_Input_arr
	label 'open_lbl' ":" pos:[82,75] width:5 height:20
	dropdownList 'List_Input_Type' ""  pos:[92,73] width:60 items:BIC_Import_arr
	
	groupbox 'g3' "  输出  " pos:[165,55] width:155 height:45
	dropdownList 'List_Output' ""  pos:[172,73] width:75 items:BIC_Output_arr
	label 'save_lbl' ":" pos:[250,75] width:5 height:20
	dropdownList 'List_Output_Type' ""  pos:[258,73] width:55 items:BIC_Saveas_arr
	checkbox 'out_sep' "  输出到单独的文件夹" pos:[5,110]
	label 'out_label' "(文件夹名:" pos:[160,110] visible:false
	label 'out_path' "MAX) ." pos:[220,110] visible:false
	checkbox 'chk_2021' "" pos:[305,110] tooltip:"将所有多边形对象转换为网格\n仅在将 2021+ 保存到以前\n时才有效，以避免顶点变形。"
	
	groupbox 'g4a' "  输入路径  " pos:[5,130] width:315 height:45
	checkbutton 'sub_folders' "S" pos:[10,148] width:20 height:20 tooltip:"搜索子文件夹"
	edittext 'BIC_path' "" pos:[30,150] fieldWidth:255 readonly:true
	button 'browse' "..." pos:[295,148] width:20 height:20 tooltip:"浏览"
	
	groupbox 'g4' "  输出前，脚本预处理  " pos:[5,180] width:315 height:45
	checkbox 'BIC_Sc_on' "" pos:[150,180] width:20 tooltip:"打开/关闭脚本选项"
	button 'CSpath' "C" pos:[10,198] width:20 height:20 tooltip:"清除脚本列表" enabled:false
	edittext 'Spath' "" pos:[30,200] fieldWidth:205 readonly:true enabled:false
	edittext 'Sorder' "" pos:[240,200] fieldWidth:45 tooltip:"脚本执行顺序" enabled:false
	button 'Sbrowse' "..." pos:[295,198] width:20 height:20 tooltip:"浏览" enabled:false
	
	button 'start_convert' "转换" pos:[5,230] width:315 height:30
	
	-- groupbox 'g5' "" pos:[0,270] width:325 height:1
	label 'lbl_1' "状态 : 设置路径 ..." pos:[6,275] width:128
	label 'lbl_2' "| 总 :" pos:[145,275] width:45
	label 'lbl_2a' "-" pos:[190,275] width:30
	label 'lbl_3' "| 过 :" pos:[235,275] width:55
	label 'lbl_3a' "-" pos:[295,275] width:30
	-- groupbox 'g6' "" pos:[0,295] width:325 height:1
	label 'lbl_4' "输入文件" pos:[6,305] width:60
	label 'lbl_4a' ": ----------------------------------------------------------" pos:[65,305] align:#left
	label 'lbl_5' "输出文件" pos:[6,330] width:60
	label 'lbl_5a' ": ----------------------------------------------------------" pos:[65,330] align:#left
--)
--( FUNCTIONS
	fn CreateUser32Assembly = (
		source = "using System;"
		source += "using System.Runtime.InteropServices;"
		source += "class User32"
		source += "{"
		source += "	[DllImport(\"user32.dll\")]"
		source += "	static extern bool RedrawWindow(IntPtr hWnd, IntPtr lprcUpdate, IntPtr hrgnUpdate, uint flags);"
		source += "	static uint FULL_REDRAW = 0x0185;"
		source += "	public bool RedrawAllWindow(Int32 hWnd) { return RedrawWindow((IntPtr)hWnd, IntPtr.Zero, IntPtr.Zero, FULL_REDRAW); }"
		source += "}"
		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		compilerParams.ReferencedAssemblies.AddRange #("System.dll")
		compilerParams.GenerateInMemory = on
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
		User32Assembly = compilerResults.compiledAssembly
		_user32 = User32Assembly.CreateInstance "User32"
	)
	fn FindExporterClass = (
		local str , idx = 0
		case List_Output.selection of (
			1 : str = "FBXEXP"                    --FBX
			2 : str = "3D_StudioExporterPlugin"   --3DS
			3 : str = "ObjExp"                    --OBJ
			4 : str = "DWG_ExportExporterPlugin"  --DWG
			5 : str = "DWG_Export"                --DXF
			6 : str = "DWF_Exporter"			  --DWF
			7 : str = "Adobe_Illustrator"		  --AI
			8 : str = "STL_Export"		          --STL
			9 : str = "Alembic_Export"		      --ABC
			10 : str = "ACIS_SAT"				  --SAT
			11 : str = "DAEEXP"					  --DAE
			12 : str = "IGES_Export"			  --IGS
			13 : str = "SW3D_Exp"				  --W3D
			14 : str = "OpenFltExport"			  --FLT
			15 : str = "AsciiExp"				  --ASE
		)
		for i = 1 to ExClasses.count do (
			if ExClasses[i] as string == str do idx = i
		)
		idx
	)
	fn CheckNameLength n c = (
		local newName = ""
		if n.count > c then newName = "... " + (substring n (n.count-c) (n.count)) else newName = n
		newName
	)
	fn Check_2021_Poly2Mesh = (
		local state = ((maxVersion())[1] >= 23000) and (List_Output.selected == "Save as") and ((List_Output_Type.selected as integer) < 2021)
		if state do (
			for obj in objects do (
				local cstate = false
				case of (
					(isKindOf obj PolyMeshObject):(cstate = true)
					(isKindOf obj Editable_Poly):(cstate = true)
					(iskindof obj.baseobject Editable_Poly):(cstate = true)
					(try(findstring (obj.modifiers as string) "Edit Poly:Edit Poly" != undefined)catch(false)):(cstate = true)
				)
				if cstate do convertToMesh obj
			)
		)
	)
	--( Material Library Open/Save
	fn GetMtlLib matLibPath: lowerVersion: = ( ---- Thanks to barigazy (https://forums.cgsociety.org/t/example-save-material-library-file-for-lower-max-version/1584874)
		local result = false, matLib, filename
		filename = getFilenamePath matLibPath + BIC_SepDir + getFilenameFile matLibPath --- BIC_SepDir if (Output to Separat Folders) is checked
		if (matLib = loadTempMaterialLibrary matLibPath) != undefined then (
			mtlDataCA = attributes mtlData (
				parameters libs (
					mtls type:#materialTab tabSize:0 tabSizeVariable:on; maps type:#texturemapTab tabSize:0 tabSizeVariable:on
				)
			)
			if (custattributes.add rootnode mtlDataCA) do (
				for m in matLib do (	
					case superclassof m of (
						material : append rootnode.mtlData.mtls m
						textureMap : append rootnode.mtlData.maps m
					)
				)
			)
			local tempMaxFile = filename + "_" + lowerVersion + ".max"
			result = saveMaxFile tempMaxFile saveAsVersion:(lowerVersion as integer)
		)
		else (messageBox "Failed to Load :" + matLibPath)
		result
	)
	fn SaveMtlLib f = ( ---- Thanks to barigazy (https://forums.cgsociety.org/t/example-save-material-library-file-for-lower-max-version/1584874)
		local state = loadMaxFile f quiet:true
		if state and (isProperty rootnode #mtlData) do (
			local newMatLibFilename = getFilenamePath f + getFilenameFile f + BIC_file_tag + ".mat"
			if (saveMaterialLibrary newMatLibFilename) do (
				matLib = loadTempMaterialLibrary newMatLibFilename
				if matLib.count != 0 do (for i = matLib.count to 1 by -1 do deleteItem matLib i)
				if rootnode.mtlData.mtls.count > 0 do (for mtl in rootnode.mtlData.mtls do append matLib mtl)
				if rootnode.mtlData.maps.count > 0 do for map in rootnode.mtlData.maps do append matLib map
				saveTempMaterialLibrary matLib newMatLibFilename
			)
		)
	)
	--)
	--( Grab Viewport
	fn BIC_PrepareView = (
		if viewport.GetType() != #view_persp_user do viewport.SetType #view_persp_user
		if viewport.numViews > 1 do (max tool maximize)
		viewport.setTM (matrix3 [0.707107,0.353553,-0.612372] [-0.707107,0.353553,-0.612372] [0,0.866025,0.5] [0,0,-250])
		max zoomext sel all
		viewport.setGridVisibility (viewport.activeViewport) false  -- Turn off Grid
		displaySafeFrames = false
		actionMan.executeAction -844228238 "13"  -- Viewport Lighting and Shadows: Standard
		actionMan.executeAction 0 "63566"  -- Views: Default Shading
		if (viewport.getShowEdgeFaces()) do actionMan.executeAction 0 "369"
		---Turn Statistics off  ---- Thanks to Swordslayer (http://www.scriptspot.com/forums/3ds-max/general-scripting/hiding-statistics-panel)
		local table = for i = 1 to actionMan.numActionTables where (actionMan.getActionTable i).name == "Main UI" do exit with actionMan.getActionTable i
		local checked = for i = 1 to table.numActionItems where (item = table.getActionItem i; item.getMenuText &aiMenuText; aiMenuText == "Show Statistics Toggle") do exit with item.isChecked
		if checked do actionMan.executeAction 0 "40829"
		----------
	)
	fn BIC_CreatePreview file x y = (
		local bm , dib
		local size = [x,y]
		BIC_PrepareView()
		clearSelection()
		redrawViews()
		dib = gw.getViewportDib()
		if size.x == 0 or size.y == 0 then (
			size = getViewSize()
	     	bm = bitmap size.x size.y filename:file
	    	copy dib bm
		)
		else (
			local ratio, t_ratio, tmp_bm, posX
			ratio = size.x/(size.y as float)
			t_ratio = dib.height/(size.y as float)
			tmp_bm = bitmap (dib.width/t_ratio) size.y
			copy dib tmp_bm
			posX = (tmp_bm.width - (tmp_bm.height)*ratio)/2
			bm = bitmap size.x size.y filename:file
			pasteBitmap tmp_bm bm (box2 posX 0 size.x size.y) [0,0]--[(abs(tmp_bm.width-size.x)/2),0]
			close tmp_bm ; tmp_bm = undefined
		)
		save bm
		close bm ; close dib
		bm = undefined ; dib = undefined
		gc()
	)
	--)
	--( Collect Folders/Files
	fn BIC_GetFoldersRecursively root arr = (
		append arr root
		f = GetDirectories (root+"/*")
		for i in f do BIC_GetFoldersRecursively i arr
	)
	fn BIC_GetFiles root ext arr = (
		f = getFiles (root + "*" + ext)
		for i in f do appendIfUnique arr i
	)
	--)
	fn BIC_CheckReady = (
		if BIC_TotalNumber == undefined then (lbl_1.text = "状态 : 设置路径 ..." ; lbl_2a.text = "-" ; start_convert.enabled = false)
		else (
			if BIC_TotalNumber != 0 then (lbl_1.text = "点击转换执行 ..." ; lbl_2a.text = BIC_TotalNumber as string ; start_convert.enabled = true)
	     	else (lbl_1.text = "没有文件转换 ..." ; lbl_2a.text = "-" ; start_convert.enabled = false)
		)
		lbl_3a.text = "-"
	)
	fn BIC_CheckFiles = (
		local sst, mat_state = false ; BIC_SepDir = ""
		import_folders = #(); arr_import_files = #()
		--- Check Input
		case List_Input.selection of (
			1:(BIC_inIdx = 1) --- Input : Import
			2:( --- Input : Open
				case List_Input_Type.selection of (
					1:(BIC_inIdx = 2 ; BIC_InEXT = ".max") --- Input : Open Max File
					2:(BIC_inIdx = 3 ; BIC_InEXT = ".mat") --- Input : Open Material Library
				)
			)
		)
		--- Check Output
		BIC_file_tag = ""
		case List_Output.selection of (
			1:( --- Output : Save as Max File
				BIC_file_tag = "_" + BIC_Saveas_arr[List_Output_Type.selection]
				if BIC_inIdx == 2 do ( -- Max to Lower Version
					BIC_SepDir += "MAX\\" ; BIC_OutEXT = ".max" ; BIC_outIdx = 2
				)
				if BIC_inIdx == 3 do ( -- Mat to Max
					BIC_SepDir += "Max4Matlibs\\" ; BIC_OutEXT = ".max" ; BIC_outIdx = 2 ; mat_state = true
				)
			)
			2:( --- Output : Export
				BIC_SepDir += BIC_Export_arr[List_Output_Type.selection] + "\\"
				BIC_outIdx = 1 ; BIC_OutEXT = "." + toLower BIC_Export_arr[List_Output_Type.selection]
			)
			3:( --- Output : Save as Material Library
				BIC_SepDir += "MAT\\" ; BIC_OutEXT = ".mat" ; BIC_outIdx = 3 ; mat_state = true
			)
		)
		/**Mat File should be Converted to (Lower Version Max File) THEN Converting this Max File to Mat File By Running the Script in Lower Version of Max and Do Convert Max to Mat**/
		--- Disable Save Preview with Mat Files and Privent Mat to Mat Convert
		if mat_state then (
			save_prv_state = save_prv.checked = cstm_prv.checked = cstm_prv.enabled = prv_type.enabled = prv_width.enabled = prv_height.enabled = false
			if BIC_inIdx == 3 do (List_Output.items = #("Save Max") ; List_Output_Type.items = BIC_Saveas_arr)
			if BIC_outIdx == 3 do List_Output_Type.items = #("20" + (((maxversion())[1]/1000)-2) as string)
		)
		else (
			if save_prv_state do (save_prv.checked = cstm_prv.enabled = prv_type.enabled = true ; save_prv_state = false)
		)
		---- Show Label with Output Folder Name
		if out_sep.state then (
	      	local str = toUpper (trimLeft BIC_InEXT ".")
			if BIC_inIdx == 3 do str = "Max4Matlibs"
	     	out_path.text = " " + str + " ) ."
	     	out_label.visible = out_path.visible = true
		)
		else (out_label.visible = out_path.visible = false ; BIC_SepDir = "")
		
		---- Collect Array of Input Files if Path Exist
		if try(doesFileExist import_path)catch(false) do (
			BIC_TotalNumber = 0
			if BIC_Subfolders_state then BIC_GetFoldersRecursively import_path import_folders else append import_folders import_path
			for f in import_folders do (
				local import_files = #()
				
				if out_sep.state then BIC_max_path = f + BIC_SepDir else BIC_max_path = f
					
				if List_Input_Type.selected == "All" then (for i in BIC_Import_arr_EXT do BIC_GetFiles f i import_files)
				else BIC_GetFiles f BIC_InEXT import_files
				
				if import_files.count != 0 do (
			    	for i = import_files.count to 1 by -1 where import_files[i] != undefined do (
		  	         	BIC_new_name = BIC_max_path + getFilenameFile import_files[i] + BIC_file_tag + BIC_OutEXT
			     		if doesFileExist BIC_new_name do (
							deleteitem import_files i ; print (BIC_new_name + " already xist !")
						)
			     	)
			    	BIC_TotalNumber += import_files.count
			     	append arr_import_files (#(BIC_max_path, import_files))
				)
			)
		)
	)
	fn BIC_Import_Export f p indx outdx = (
		local state = false
		case indx of ( ---- INPUT
			1:( ---- import
	    		resetMaxFile #noprompt
				state = importFile f #noPrompt
			)
			2:( ---- load max
				state = loadMaxFile f useFileUnits:true quiet:true
			)
			3:( ---- load mat
	    		resetMaxFile #noprompt
				GetMtlLib matLibPath:f lowerVersion:(List_Output_Type.selected)
			)
		)
		if state then (
			if BIC_Sc_on.state and BIC_Scripts.count != 0 do (
				for s = 1 to BIC_Scripts.count where doesFileExist BIC_Scripts[s] do try(filein BIC_Scripts[s])catch(
					format "... Script Run Error\nScript:%\nFile:%\n" BIC_Scripts[s] f
				)
			)
			case outdx of ( ---- OUTPUT
		    	1:( ---- export
					if save_prv.state and not doesFileExist p do BIC_CreatePreview p prv_width.value prv_height.value
					local idx = FindExporterClass()
		    		if idx != 0 do exportFile BIC_new_name #noPrompt using:ExClasses[idx]
				)
				2:( ---- save max
					if save_prv.state and not doesFileExist p do BIC_CreatePreview p prv_width.value prv_height.value
					if chk_2021.state do Check_2021_Poly2Mesh()
					saveMaxFile BIC_new_name saveAsVersion:((List_Output_Type.selected) as integer) clearNeedSaveFlag:true quiet:true
				)
				3:( ---- save mat
					SaveMtlLib f
				)
			)
		)
		else (if indx != 3 do print ("无法打开 : " + f))
		try(_user32.RedrawAllWindow (windows.getchildhwnd 0 BatchImportConvert.title)[1])catch()
	)
	fn BIC_Convert = (
		local FileSaved = 0, make_folder , st = timestamp()
		BIC_CheckFiles() ; lbl_1.text = "转换中 ..."
		setWaitCursor() ; SetQuietMode true
		for i = 1 to arr_import_files.count do (
			local pth = arr_import_files[i][1], arr = arr_import_files[i][2]
	    	try(makeDir pth ; make_folder = true)catch(make_folder = false)
			if make_folder do (
				for i = arr.count to 1 by -1 where arr[i] != undefined do (
					if BIC_inIdx == 1 and List_Input_Type.selected == "All" then ( --- Get String for Output File Label 
						BIC_new_name = pth + getFilenameFile arr[i] + "_" + (trimLeft (getFilenameType arr[i]) ".") + BIC_OutEXT
					)
					else (
-- 						if BIC_inIdx == 3 do BIC_InEXT = ".max"
						BIC_new_name = pth + getFilenameFile arr[i] + BIC_file_tag + BIC_OutEXT
					)
					if doesFileExist BIC_new_name then (deleteitem arr i ; print (BIC_new_name + " already xist !"))
					else (
			    		local P_name = getFilenamePath BIC_new_name + getFilenameFile BIC_new_name + "." + (toLower prv_type.selected)
				      	BIC_Import_Export arr[i] P_name BIC_inIdx BIC_outIdx
				     	lbl_3a.text = (FileSaved + 1) as string
				    	lbl_4a.text = ": " + CheckNameLength arr[i] 40
				     	lbl_5a.text = ": " + CheckNameLength BIC_new_name 40
				    	FileSaved += 1
			     	)
				)
			)
		)
		if arr_import_files.count != 0 do resetMaxFile #noprompt
		local tm = (timestamp()-st)/60000.0, str
		if tm > 0.02 then (
			local ts
			local ti = tm as integer; if ti > 10 then ts = "0"+ti as string else ts = ti as string
			if tm >= 1 then str = ("Done in : "+ ts + ":" + (((tm-ti)*60) as string)+" Minutes") else (
				str = ("Done in : "+"00:"+ (((tm*60) as integer) as string)+" Seconds")
			)
		); else str = "Done ."
		setArrowCursor() ; SetQuietMode false
		lbl_1.text = str
	)
	fn BIC_GetSetValues get:true = (
		if get then (
			save_prv.checked = prv_type.enabled = BICDefault[1] ; cstm_prv.checked = BICDefault[2] ; prv_width.value = BICDefault[3]
			prv_width.enabled = BICDefault[4] ; prv_height.value = BICDefault[5] ; prv_height.enabled = BICDefault[6] ; prv_type.selection = BICDefault[7]
			List_Input.selection = BICDefault[8] ; List_Input_Type.selection = BICDefault[9] ; List_Output.selection = BICDefault[10]
			List_Output_Type.selection = BICDefault[11] ; out_sep.checked = BICDefault[12] ; sub_folders.checked = BICDefault[13]
			/**(GetDialogPos BatchImportConvert) = BICDefault[14]**/
			if BICDefault.count == 18 do (
				List_Input.items = BICDefault[15]; List_Input_Type.items = BICDefault[16]; List_Output.items = BICDefault[17]; List_Output_Type.items = BICDefault[18]
			)
		)
		else (
	    	BICDefault = #(save_prv.checked,cstm_prv.checked,prv_width.value,prv_width.enabled,prv_height.value,prv_height.enabled,prv_type.selection,
				List_Input.selection,List_Input_Type.selection,List_Output.selection,List_Output_Type.selection,out_sep.checked,sub_folders.checked,
				(GetDialogPos BatchImportConvert),List_Input.items,List_Input_Type.items,List_Output.items,List_Output_Type.items)
		)
	)
--)
--( BTNS
	--( Preview Btns
	on save_prv changed state do (
		if BIC_inIdx == 3 then (
			save_prv.state = off ; messageBox "No Preview Generating with Mat File"
		)
		else (
			if state then cstm_prv.enabled = prv_type.enabled = true else (
				cstm_prv.checked = cstm_prv.enabled = prv_type.enabled = prv_width.enabled = prv_height.enabled = false
			)
		)
	)
	on cstm_prv changed state do (
		if state then prv_width.enabled = prv_height.enabled = true else prv_width.enabled = prv_height.enabled = false
	)
	--)
	--( Input Btns
	on List_Input selected idx do (
		if idx == 1 then List_Input_Type.items = BIC_Import_arr else List_Input_Type.items = #("MAX","MAT")
		List_Input_Type.selection = 1 ; BIC_CheckFiles() ; BIC_CheckReady()
	)
	on List_Input_Type selected idx do (
		case of (
			(List_Input_Type.selected == "MAX"):(List_Output.items = BIC_Output_arr_MAX)
			(List_Input_Type.selected == "MAT"):(List_Output.items = BIC_Output_arr_MAT)
	 		default:(List_Output.items = BIC_Output_arr)
		)
-- 		if List_Input_Type.selected == "Mat" then List_Output.items = #("Save as") else List_Output.items = BIC_Output_arr
		List_Output_Type.items = BIC_Saveas_arr ; List_Output.selection = List_Output_Type.selection = 1
		BIC_CheckFiles() ;  ; BIC_CheckReady()
	)
	--)
	--( Output Btns
	on List_Output selected idx do (
-- 		List_Output_Type.items = #("20" + ((((maxversion())[1]/1000)-2) as string)) --- Need Check
-- 		if idx == 1 then List_Output_Type.items = BIC_Saveas_arr else List_Output_Type.items = BIC_Export_arr
		case idx of (
	 		1:(List_Output_Type.items = BIC_Saveas_arr)
			2:(List_Output_Type.items = BIC_Export_arr)
			3:(List_Output_Type.items = #("20" + (((maxversion())[1]/1000)-2) as string))
		)
		List_Output_Type.selection = 1 ; BIC_CheckFiles() ; BIC_CheckReady()
	)
	on List_Output_Type selected item do (BIC_CheckFiles() ; BIC_CheckReady())
	on out_sep changed state do (BIC_CheckFiles() ; BIC_CheckReady())
	--)
	--( Path Btns
	on sub_folders changed state do (
		if state then BIC_Subfolders_state = true else BIC_Subfolders_state = false
		if import_path != undefined do (BIC_CheckFiles() ; BIC_CheckReady())
	)
	on browse pressed do (
		import_path = getSavePath()
		if import_path != undefined do (
			if import_path[import_path.count] != "\\" do import_path = import_path + "\\"
			BIC_path.text = import_path ; BIC_CheckFiles() ; BIC_CheckReady()
		)
	)
	--)
	--( Scripts Btns
	on BIC_Sc_on changed state do (
		if state then (CSpath.enabled = Spath.enabled = Sorder.enabled = Sbrowse.enabled = true)
		else (CSpath.enabled = Spath.enabled = Sorder.enabled = Sbrowse.enabled = false)
	)
	on CSpath pressed do (
		if queryBox "清除脚本列表 ?" do (BIC_Scripts = #() ; Spath.text = Sorder.text = "")
	)
	on Sorder entered txt do (
		if BIC_Scripts.count != 0 then (
			local arr = #() ; Spath.text = ""
			for i = 1 to txt.count do (
				local n = try(execute txt[i])catch(undefined)
				if classof n == Integer do (
					append arr BIC_Scripts[n]
		         	Spath.text += i as string + " : " + pathConfig.stripPathToLeaf BIC_Scripts[n] + "||"
				)
			)
			BIC_Scripts = arr
		)
		else Sorder.text = ""
	)
	on Sbrowse pressed do (
		local dlg = dotnetObject "OpenFileDialog"
		dlg.title = "Select Script Files"
		dlg.multiselect = on
		dlg.filter = "Script Files |*.ms;*.mse"
		if (dlg.showDialog() == (dotnetClass "DialogResult").Ok) then (
			local files = dlg.FileNames
			dlg.dispose()
			local n = BIC_Scripts.count
			for i = 1 to files.count do (
				appendIfUnique BIC_Scripts files[i]
				Spath.text += (n+i) as string + " : " + pathConfig.stripPathToLeaf files[i] + "||"
				Sorder.text += (n+i) as string
			)
		)
		else dlg.dispose()
	)
	--)
	on chk_2021 changed state do (
		if (maxVersion())[1] < 23000 do (
			chk_2021.checked = false ; messageBox "No need ! , This option work only with max 2021+"
		)
	)
	on start_convert pressed do 
	(
		if chk_2021.state then 
		(
			if (queryBox "勾选了转换多边形，\r\n\r\n（2021+不勾会导致顶点变形）\r\n\r\n此勾选会破坏 Skin 建议备份，\r\n\r\n确定继续？                                                              "title:"确定转换？" beep:false) then (checkForSave() ; BIC_Convert())
		)
		else (if CheckForSave() then (BIC_Convert()))
	)
--)
	on BatchImportConvert open do (
		if (maxVersion())[1] >= 23000 do chk_2021.checked = true
		BIC_Import_arr_EXT = for i = 2 to BIC_Import_arr.count collect ("." + toLower BIC_Import_arr[i])
		BIC_GetSetValues() ; BIC_CheckFiles() ; BIC_CheckReady()
		try(CreateUser32Assembly();_user32.RedrawAllWindow (windows.getchildhwnd 0 BatchImportConvert.title)[1])catch()
	)
	on BatchImportConvert close do (BIC_GetSetValues get:false)
)
createDialog BatchImportConvert pos:BICDefault[14] style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
clearlistener()