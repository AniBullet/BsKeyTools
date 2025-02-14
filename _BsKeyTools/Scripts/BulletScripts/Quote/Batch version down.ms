---2024.04  Bullet.S
---纯汉化自用，无其他修改
(
	global Batch_Ver_down
    try(destroyDialog Batch_Ver_down)catch()
    rollout Batch_Ver_down "lil_Batch version Down 3.0_CHS"
    (
		local curMaxVersion = ((maxVersion())[1] / 1000)
		local openFileRoll = dotNetObject "System.Windows.Forms.OpenFileDialog"	
        local disableForeColor = (dotNetClass "System.Drawing.Color").white
        local maxFiles = #()   
		fn openInfoWebsite =
		(
  		  shellLaunch "https://blog.naver.com/trueb000/" ""
		)

	
		function VersionNums = 
		(
			longVersion = ((curMaxVersion - 2) + 2000) 
			for i = 0 to 3 collect (longVersion - (1 * i))
		)
		local versions = versionNums()
		
       
		button btn_getDir "选择（按文件夹）" width:175 height:30 pos:[25,25]
      		button btn_getFile "选择（按文件）" width:175  height:30 pos:[212,25] 
       		button btn_Clear "清除列表" width:175 height:30 pos:[400,25] 
		dotNetControl lv_Batch "system.windows.forms.listView" height:200 width:550 pos:[25,60]
		

		button btn_all "选择所有" pos:[365,270] width:90 height:25
		button btn_none "取消所有选择" pos:[460,270] width:90 height:25

		
		
		label lbl_saveToVersion "另存版本【官方仅支持3版本内】:" pos:[30,275] width:180
		dropdownList ddl_version "" pos:[210,273] width:96 height:40 items:(for v in versions collect v as string) 
		

	
		button bnt_saveAsPrevious "开始执行，另存Max文件（同目录带_v版本后缀）" width:505 height:38 pos:[50,315]
		progressBar progress value:0 color:red width:555 pos:[20,365]

				label myname2 "made by lil_jongyoon；CHS by Bullet.S" pos:[250,395] width:250


/*button infoButton "Info" pos:[190,390] width:105 height:25*/
        	
--  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&   리스트뷰의 너비르 정합니다 .&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
			
			  function AddColumns theLv columnsAr=
		(
			-- 새로운 열의 너비를 설정합니다.
			w=(theLv.width)+500
			
			-- columnsAr의 각 항목을 반복하여 열을 추가합니다.
			for x in columnsAr do
			(
				-- theLv 컨트롤에 새로운 열을 추가합니다.
				-- x는 열의 제목이나 데이터를 나타내며, w는 열의 너비입니다.
				theLv.columns.add x w
			)
		)
		
		
-- &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&   maxFiles 배열에 있는 각 파일 이름을 ListView 컨트롤에 아이템으로 추가합니다. &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		
		function PopulateListView theLv=
		(
			rows=#()
			
			-- maxFiles 배열에 있는 각 파일에 대해 반복합니다.
			for x=1 to maxFiles.count do
			(
				-- 현재 파일의 이름을 mapName 변수에 할당합니다.
				mapName = maxFiles[x]
				
				-- .NET의 ListView 아이템을 생성하고 현재 파일의 이름을 인자로 전달합니다.
				li = dotNetObject "System.Windows.Forms.ListViewItem" mapName
				
				-- 새로 생성된 아이템을 배열에 추가합니다.
				append rows li
			)
			
			-- ListView 컨트롤에 생성된 아이템들을  rows배열에 한 번에 추가합니다.
			theLv.items.addRange rows
		)		
		
		

--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& ListView 컨트롤을 초기화합니다.&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		
			function InitListView theLv=
			(            
				-- ListView 컨트롤의 모든 아이템을 제거합니다.
				theLv.clear()
				
				-- ListView 컨트롤의 헤더 스타일을 설정합니다.
				-- none: 헤더를 표시하지 않습니다.
				theLv.headerStyle = theLv.headerStyle.none
				
				-- ListView 컨트롤의 보기 모드를 설정합니다.
				-- details: 세부 정보 보기 모드를 사용합니다.
				theLv.view = (dotNetClass "system.windows.forms.view").details
				
				-- ListView 컨트롤에서 행 전체를 선택할 수 있도록 설정합니다.
				theLv.FullRowSelect = true
				
				-- ListView 컨트롤에서 여러 개의 아이템을 동시에 선택할 수 있도록 설정합니다.
				theLv.MultiSelect = true
				
				-- ListView 컨트롤에서 각 아이템 앞에 체크박스를 표시합니다.
				theLv.checkBoxes = true
				
				-- ListView 컨트롤의 배경색을 설정합니다.
				-- DimGray: 어두운 회색을 나타내는 색상입니다.
				theLv.backcolor = (dotNetClass "System.Drawing.Color").DimGray
				
				-- ListView 컨트롤의 전경색(글꼴 색상)을 설정합니다.
				-- lightGray: 밝은 회색을 나타내는 색상입니다.
				theLv.forecolor = (dotNetClass "System.Drawing.Color").lightGray
			)
			
			
					
-- &&&&&&&&&&&&&&&&&&&&&&&&&&&&& ListView를 다시 초기화하고 열을 추가하고 아이템을 채우는 함수입니다.&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
			
		function BatchListViewReIinit =
		(
			-- lv_Batch ListView를 초기화합니다.
			InitListView lv_Batch
			
			-- lv_Batch ListView에 하나의 빈 열을 추가합니다.
			AddColumns lv_Batch #("")    
			
			-- lv_Batch ListView에 아이템을 채웁니다.
			PopulateListView lv_Batch
		)
		
		
--*&&&&&&&&&&&&&&& ListView 컨트롤 내의 모든 아이템의 체크박스를 활성화하고, ListView의 전경색을 disableForeColor로 변경하는 함수입니다.&&&&&&&&&&&&&&&&&&&&&
		
		function TurnBatchLVchkBoxOn =
		(
			-- ListView 컨트롤의 모든 아이템에 대해 반복합니다.
			for i = 0 to lv_Batch.Items.count-1 do
				-- 현재 아이템의 체크박스를 활성화합니다.
				lv_Batch.Items.Item[i].checked = true
			
			-- ListView 컨트롤의 전경색을 disableForeColor로 설정합니다.
			lv_Batch.forecolor = disableForeColor
		)		
		
		
		
		
--&&&&&&&&&&&&&&&&&&&&&&&&&&  주어진 폴더를 탐색기를 사용하여 엽니다. &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		
		function OpenFolders folderToOpen =
		(
			-- 폴더 이름의 끝에 있는 슬래시를 제거합니다.
			local checkFolderName = substring folderToOpen 1 (folderToOpen.count-1)
			
			-- 만약 폴더 이름이 심볼릭 경로인 경우
			if (symbolicPaths.isPathName checkFolderName) then
			(
				-- 폴더 이름을 실제 경로로 변경합니다.
				folderToOpen = symbolicPaths.getPathValue checkFolderName
			)                
			
			-- 탐색기를 사용하여 폴더를 엽니다.
			shellLaunch "explorer.exe" folderToOpen
		)
				
--&&&&&&&&&&&&& 지정된 루트 폴더 아래에서 주어진 패턴에 일치하는 파일을 재귀적(자기참조) 으로 검색하여 반환하는 함수입니다.&&&&&&&&&&&&&&
		
		function GetFilesRecursive root pattern =
		(        
			-- root 폴더 아래의 모든 하위 폴더를 가져옵니다.
			dir_array = GetDirectories (root+"\*")
			
			-- 각 하위 폴더에 대해 재귀적(자기참조) 으로 하위 폴더를 가져옵니다.
			for d in dir_array do
				join dir_array (GetDirectories (d+"*"))    
			
			-- 모든 파일을 저장할 배열을 초기화합니다.
			my_files = #()                
			
			-- 각 하위 폴더에서 지정된 패턴과 일치하는 파일을 가져와서 배열에 추가합니다.
			for f in dir_array do
				join my_files (getFiles (f + pattern))
				
			-- 모든 파일을 포함하는 배열을 반환합니다.
			my_files
		)
		
		
		--&&&&&&&&&&&&&&&&& 여기서부터는 버튼과 함수 호출입니다 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		
		
		
		
			-- btn_getDir 버튼이 눌렸을 때 실행되는 이벤트 핸들러입니다.
			on btn_getDir pressed do
			(
				-- 사용자로부터 디렉토리를 선택합니다.
				dir = getSavePath caption:"Select the directory" initialDir:"$scenes"
				
				-- 사용자가 디렉토리를 선택한 경우
				if dir != undefined do
				(
					-- 검색할 파일의 유형을 지정합니다.
					fileType = ".max"
					
					-- 선택한 디렉토리 내의 모든 .max 파일을 가져옵니다.
					maxFiles = getFiles (dir+"\*" + fileType)
					
					-- 선택한 디렉토리 내의 모든 하위 폴더에서 .max 파일을 재귀적으로 가져옵니다.
					subFiles = GetFilesRecursive dir ("*" + fileType)
					
					-- 만약 하위 폴더에서 .max 파일이 발견된 경우
					if subFiles.count != 0 then
					(
						-- 사용자에게 하위 폴더의 파일을 포함할 것인지 묻습니다.
						msg = "所选文件夹包含子文件夹!\n\n"
						msg += "是否希望包含子文件夹所有文件?                                     "
						if queryBox msg title:"Sub-folders found" do
							-- 하위 폴더의 .max 파일을 현재 파일 리스트에 추가합니다.
							join maxFiles subFiles
					)
					
					-- 중복된 파일을 제거하여 유일한 파일만 남깁니다.
					makeUniqueArray maxFiles
					
					-- ListView 컨트롤에 파일 목록을 표시합니다.
					PopulateListView lv_Batch
					
					-- ListView 컨트롤 내의 모든 체크박스를 활성화합니다.
					TurnBatchLVchkBoxOn()
				)
			)
					
			
			
			-- btn_getFile 버튼이 눌렸을 때 실행되는 이벤트 핸들러입니다.
			on btn_getFile pressed do
			(
				-- 파일 대화 상자의 필터 인덱스를 설정합니다.(맥스로)
				openFileRoll.FilterIndex = 4
				
				-- 파일 대화 상자를 표시하고 사용자의 선택 결과를 가져옵니다.
				result = openFileRoll.showDialog()
				
				-- 결과를 문자열로 변환합니다.
				result.ToString() 
				
				-- 사용자가 "OK"를 선택한 경우
				if (result.Equals result.OK) do 
				(
					-- 선택한 파일 경로를 가져옵니다.
					filePath = (openFileRoll.fileNames)
					
					-- 선택한 파일을 현재 파일 리스트에 추가합니다.
					join maxFiles filePath
					
					-- 중복된 파일을 제거하여 유일한 파일만 남깁니다.
					makeUniqueArray maxFiles
					
					-- ListView 컨트롤을 다시 초기화하고 파일 목록을 업데이트합니다.
					BatchListViewReIinit()
					
					-- ListView 컨트롤 내의 모든 체크박스를 활성화합니다.
					TurnBatchLVchkBoxOn()
				)
			)
			
			
					
        on btn_Clear pressed do
        (
            maxFiles = #()
            BatchListViewReIinit()
        )
	
		
		
		on btn_all pressed do
		(
			for i = 0 to lv_Batch.Items.count-1 do lv_Batch.Items.Item[i].checked = true
		)
		
		on btn_none pressed do
		(
			for i = 0 to lv_Batch.Items.count-1 do lv_Batch.Items.Item[i].checked = false
		)
		
		
		
	/*		on btn_invert pressed do
		(
			for i = 0 to lv_Batch.Items.count-1 do lv_Batch.Items.Item[i].checked = not lv_Batch.Items.Item[i].checked
		)
		
		
		
		
	

        on lv_Batch MouseDown arg do
        (
            if arg.button==arg.button.middle then
            (                
                if (hitNode = lv_Batch.GetItemAt arg.x arg.y) != undefined do
                (
                    deleteItem maxFiles (hitNode.index+1)
                    BatchListViewReIinit()
                )                
            )
            if arg.button==arg.button.right then
            (                
                if (hitNode = lv_Batch.GetItemAt arg.x arg.y) != undefined do
                (
                    f = (hitNode.index+1)
                    folderToOpen = (getFilenamePath maxFiles[f])
                    OpenFolders folderToOpen
                )                
            )
        )
        
*/

		function SaveExportAsPrevious _export: =
		(
			_isMaxFile = 
			
			(
true

			)
		
			
			local fileCnt = (lv_Batch.Items.count - 1)
			
			local versionIndex = ddl_version.selected
			local versionN = ddl_version.selection
			setWaitCursor()
			suspendEditing()
			resetMaxFile #noPrompt


		local n = 0
		
			for i = 0 to fileCnt where (lv_Batch.Items.Item[i].checked == true) do with redraw off
			(
				if _isMaxFile then
					loadMaxFile maxFiles[i+1] quiet:true
				else
					importFile maxFiles[i+1] #noPrompt
				
				filePath = getFilenamePath maxFiles[i+1]
				
				if _export == false then
				(
					fileName = (getFilenameFile maxFiles[i+1]) + "_v" + (versionIndex as string)
					newName = filePath + "\\" + fileName + ".max"
					if versionN == 1 then
						saveMaxFile newName useNewFile:true quiet:true
					else
						saveMaxFile newName saveAsVersion:(versionIndex as integer ) useNewFile:true quiet:true
				)
				else
				(
					fileName = (getFilenameFile maxFiles[i+1])
					if chkBox_exportToFBX.checked do
					(
						newName = filePath + "\\" + fileName + ".fbx"
						exportFile newName #noPrompt 
					)
					if chkBox_exportToObj.checked do
					(
						newName = filePath + "\\" + fileName + ".obj"
						exportFile newName #noPrompt 
					)
					if chkBox_exportTo3ds.checked do
					(
						newName = filePath + "\\" + fileName + ".3ds"
						exportFile newName #noPrompt 
					)
				)
				resetMaxFile #noPrompt
				n = n+1
				progress.value = 100.0 * n / lv_Batch.CheckedItems.Count
				if curMaxVersion > 12 do
					windows.processPostedMessages()
			)
			completeRedraw()
			resumeEditing()
			setArrowCursor()
		)
		
		
		
		
		
		
		
		on bnt_saveAsPrevious pressed do
		(	
			SaveExportAsPrevious _export:false
			progress.color = green
		)
		

        
	
	
        on Batch_Ver_down open do
        ( 
			openFileRoll.title = "Select Files"
			openFileRoll.Multiselect = true
			openFileRoll.Filter = "OBJ (*.obj)|*.obj|FBX (*.fbx)|*.fbx|3DS (*.3ds)|*.3ds|MAX (*.max)|*.max"
			openFileRoll.FilterIndex = 1
			openFileRoll.RestoreDirectory = true	
			
            InitListView lv_Batch
            AddColumns lv_Batch #("Files")
        )
    )
    createdialog Batch_Ver_down width:600 height:420 
)