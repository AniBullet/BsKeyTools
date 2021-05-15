(
	global pathIcons = ((getDir #scripts) + "\\BulletScripts\\Res")
	-- 2.07
	global DTrajEdit_DTrajs = #()
	--if DTrajEdit_DTrajs == undefined then DTrajEdit_DTrajs = #()
	
	global DTrajEdit_Globals
	
	function DTrajEdit_UpdateRollout = () -- Proto
	
	global DTrajEdit_TMWatch_nNodeToUpdate = #()
	
	function DTrajEditGlobals_MeshOnly nNode =
	(
		SuperclassOf nNode == GeometryClass
	)
	
	global DTrajObject
	struct DTrajObject
	(
		szName,
		nSpline,
		nDot,
		nRoot,
		nParent,
		iFace,
		vSplineCol,
		vDotCol,
		bDot = false,
		bVis = false,
		iMin = animationrange.start,
		iMax = animationrange.end,
		
		function Move =
		(
			animButtonState = false
			if IsValidNode nRoot then
			(	
				select nRoot
				actionMan.executeAction 0 "50001"  -- Tools: Select and Move
			)
		),
		
		function Update_Attributes =
		(
			if IsValidNode nRoot and IsValidNode nDot and IsValidNode nSpline then
			(
				with animate off
				(
					if (isproperty nRoot "DTrajEdit_szName") then -- BackWard compatibility for 2.01
					(
						nRoot.DTrajEdit_szName = szName
						nRoot.DTrajEdit_nSpline = nSpline
						nRoot.DTrajEdit_nDot = nDot
						nRoot.DTrajEdit_bDot = bDot
						nRoot.DTrajEdit_bVis = bVis
						nRoot.DTrajEdit_iMin = iMin
						nRoot.DTrajEdit_iMax = iMax
					)
				)
			)
		),
		
		function Rename _szName =
		(
			szName = _szName
			Update_Attributes() -- Survivor Update
		),
		
		function ReRange _iMin _iMax =
		(
			if IsValidNode nSpline and IsValidNode nDot and IsValidNode nRoot then
			(
				iMin = _iMin
				iMax = _iMax
				
				local iTotal = _iMax - _iMin
				
				if iTotal > (numKnots nDot 1) then
				(
					local iOffset = iTotal - (numKnots nDot 1)
					for i = 1 to iOffset do
					(	
						addKnot nDot 1 #corner #line [0,0,0]
					)
					for i = 1 to (numKnots nDot 1) do
					(
						at time (i + iMin)
						(
							setKnotPoint nDot 1 i nRoot.pos
						)
					)
					updateshape nDot
				)
				else
				(
					local iOffset = (numKnots nDot 1) -  iTotal

					for i = iOffset to 1 by -1 do
					(	
						deleteKnot nDot 1 i
					)
					for i = 1 to (numKnots nDot 1) do
					(
						at time (i + iMin)
						(
							setKnotPoint nDot 1 i nRoot.pos
						)
					)
					updateshape nDot
				)
			)
			Update_Attributes() -- Survivor Update
		),
		
		function SplineCol _vCol =
		(
			if IsValidNode nSpline then
			(
				vSplineCol = _vCol
				nSpline.wirecolor = _vCol
			)
		),
		
		function DotCol _vCol =
		(
			if IsValidNode nDot then
			(
				vDotCol = _vCol
				nDot.wirecolor = _vCol
			)
		),
		
		function UpdateTraj =
		(
			if IsValidNode nSpline and IsValidNode nDot and IsValidNode nRoot then
			(
				for i = 1 to (numKnots nDot 1) do
				(
					at time (i + iMin)
					(
						setKnotPoint nDot 1 i nRoot.pos
					)
				)
				updateshape nDot
			)
		),
		
		function ToggleDisplay =
		(
			if IsValidNode nSpline and IsValidNode nDot then
			(
				if bVis then UpdateTraj()
				bVis = not(bVis)
				nSpline.IsHidden = bVis
				if not(bVis) then nDot.IsHidden = bDot
				DTrajEdit_Globals.UpdateBitmaps()
			)
			Update_Attributes() -- Survivor Update
		),
		
		function ToggleDot =
		(
			if IsValidNode nSpline and IsValidNode nDot then
			(
				if bDot then UpdateTraj()
				bDot = not(bDot)
				if not(bVis) then nDot.IsHidden = bDot
				DTrajEdit_Globals.UpdateBitmaps()
			)
			Update_Attributes() -- Survivor Update
		)
	)
	
	struct DTrajEdit_Globals_Struct
	(
		bmp_Background = openbitmap (pathIcons + "\DTools\DTrajEdit\BackGround.bmp"),
		bmp_Title = openbitmap (pathIcons + "\DTools\DTrajEdit\Title.bmp"),
		bmp_New = openbitmap (pathIcons + "\DTools\DTrajEdit\New_Poly.bmp"),
		bmp_New_Pivot = openbitmap (pathIcons + "\DTools\DTrajEdit\New_Pivot.bmp"),
		bmp_About = openbitmap (pathIcons + "\DTools\DTrajEdit\About.bmp"),
		bmp_Exit = openbitmap (pathIcons + "\DTools\DTrajEdit\Exit.bmp"),
		bmp_Display = openbitmap (pathIcons + "\DTools\DTrajEdit\Display.bmp"),
		bmp_DisplayAll = openbitmap (pathIcons + "\DTools\DTrajEdit\DisplayAll.bmp"),
		bmp_Display_ON = openbitmap (pathIcons + "\DTools\DTrajEdit\Display_ON.bmp"),
		bmp_DisplayAll_ON = openbitmap (pathIcons + "\DTools\DTrajEdit\DisplayAll_ON.bmp"),
		bmp_Delete = openbitmap (pathIcons + "\DTools\DTrajEdit\Delete.bmp"),
		bmp_Range= openbitmap (pathIcons + "\DTools\DTrajEdit\Range.bmp"),
		bmp_Dot = openbitmap (pathIcons + "\DTools\DTrajEdit\Dot.bmp"),
		bmp_Dot_ON = openbitmap (pathIcons + "\DTools\DTrajEdit\Dot_ON.bmp"),
		bmp_Move = openbitmap (pathIcons + "\DTools\DTrajEdit\Move.bmp"),
		
		WindowToCursorOffset = [0,0],
		
		function MoveWindow _rlWindow =
		(
			if WindowToCursorOffset != [0,0] then
			(
				SetDialogPos _rlWindow (mouse.pos + WindowToCursorOffset)
			)
		),

		function IsReadyToMove _rlWindow _pPos =
		(
			WindowToCursorOffset = ((GetDialogPos _rlWindow) - mouse.pos )
			setSysCur #move
		),

		function LetGoTheWindow =
		(
			WindowToCursorOffset = [0,0]
		),
			
		function GetDTrajLayer =
		(
			local laLayer = if LayerManager.getLayerFromName "DTrajEdit_Trajectories" == undefined then LayerManager.newLayerFromName "DTrajEdit_Trajectories" else LayerManager.getLayerFromName "DTrajEdit_Trajectories"
			laLayer.IsHidden = false
			return laLayer
		),
			
		function AddToDTrajLayer _nNodes =
		(
			local laLayer = GetDTrajLayer()
			if laLayer != undefined then
			(
				for nNode in _nNodes do
				(
					laLayer.addNode nNode
				)
			)
		),
		
		function NewTraj _bPivot =
		(
			local nParent
			if _bPivot then
			(
				if selection.count == 1 then
				(
					nParent = selection[1]
				)
			)
			else
			(
				nParent = pickobject filter:DTrajEditGlobals_MeshOnly
			)
			setWaitCursor()
				
			local vIntersection
			if IsValidNode nParent then
			(
				if not(_bPivot) then
				(
					local mNewModifier = Edit_Mesh()
					mNewModifier.name = "DTraj"
					addModifier nParent mNewModifier
					local vRay = (mapScreenToWorldRay mouse.pos)
					vIntersection = (intersectRayEx nParent vRay)
					deletemodifier nParent mNewModifier
				)
				iFace = (if vIntersection != undefined then vIntersection[2] else undefined)
				if _bPivot then iFace = 1
				if iFace != undefined then
				(
					nRoot = point name:(UniqueName "z_DTrajEdit_RootNode_") centermarker:off axistripod:off cross:off Box:off size:0.0 wirecolor:yellow transform:nParent.transform
					
					if _bPivot then
					(
						-- POSITION CONTROLLER
						nRoot.position.X_Position.controller.keyable = false
						nRoot.position.Y_Position.controller.keyable = false
						nRoot.position.Z_Position.controller.keyable = false
						nRoot.parent = nParent
						-- / POSITION CONTROLLER
					)
					else
					(
						-- ATTACHMENT CONTROLLER
						cAttach = Attachment node:nParent align:true
						addNewKey cAttach 0f
						local kKey = (AttachCtrl.getKey cAttach 1)
						kKey.face = if iFace > 2 then (iFace - 1) else iFace
						kKey.coord = (point2 vIntersection[3].x vIntersection[3].y)
						cList = position_list()
						cList.available.controller = cAttach
						cFreePos =  Position_XYZ()
						cFreePos.X_Position.controller.keyable = false
						cFreePos.Y_Position.controller.keyable = false
						cFreePos.Z_Position.controller.keyable = false
						cList.available.controller = cFreePos
						cList.active = 2
						nRoot.position.controller = cList
						-- / ATTACHMENT CONTROLLER
					)
					local nDot = SplineShape name:(UniqueName "z_DTrajEdit_SpacingDots_") vertexTicks:true wirecolor:green showfrozeningray:false
					local nSpline = reference nDot
					nSpline.vertexTicks = false
					nSpline.showfrozeningray = false
					nSpline.wirecolor = yellow
					nSpline.name = (UniqueName "z_DTrajEdit_Trajectory_")
					addNewSpline nDot
					for i = animationrange.start to animationrange.end do
					(
						at time i
						(
							addKnot nDot 1 #corner #line nRoot.pos
						)
					)
					updateShape nDot
						
					hide nRoot
					freeze nDot
					freeze nSpline
					
					-- Survivor Ready ( Anti Persistent Loss )
					
					DTrajEdit_Attributes = attributes "DTrajEdit_Attributes"
					(
						parameters main
						(
							DTrajEdit_szName type:#string
							DTrajEdit_nSpline type:#node
							DTrajEdit_nDot type:#node
							DTrajEdit_nParent type:#node
							DTrajEdit_bDot type:#boolean
							DTrajEdit_bVis type:#boolean
							DTrajEdit_iMin type:#integer
							DTrajEdit_iMax type:#integer
						)
					)
					CustAttributes.add nRoot DTrajEdit_Attributes
					----------------------------------------------
					
					AddToDTrajLayer #(nSpline,nDot,nRoot)
					
					local szNewName
					if _bPivot then szNewName = "'s Pivot Point" else szNewName = (" :: Face#" + (iFace as string))
					dTrajEdit_NewTrajectory = (DTrajObject szName:(nParent.name + szNewName) vSplineCol:nSpline.wirecolor vDotCol:nDot.wirecolor nRoot:nRoot iFace:iFace nSpline:nSpline nDot:nDot )
					dTrajEdit_NewTrajectory.Update_Attributes()
					dTrajEdit_NewTrajectory.UpdateTraj()
					append DTrajEdit_DTrajs dTrajEdit_NewTrajectory
					
					when transform nRoot changes handleAt:#redrawViews id:#DTrajTMWatch nNode do
					(
						if (finditem DTrajEdit_TMWatch_nNodeToUpdate nNode) == 0 then append DTrajEdit_TMWatch_nNodeToUpdate nNode
					)	
					
					DTrajEdit_UpdateRollout()
					gc()
					setArrowCursor()			
				)
			)
			else
			(
				if _bPivot then
				(
					messagebox "Be sure to pick ONE OBJECT..." title:"DTrajEdit"
				)
				else
				(
					messagebox "Be sure to pick an UNFROZEN MESH..." title:"DTrajEdit"
				)
			)
		),
		
		function DeleteTraj _i =
		(
			if IsValidNode DTrajEdit_DTrajs[_i].nRoot then delete DTrajEdit_DTrajs[_i].nRoot
			if IsValidNode DTrajEdit_DTrajs[_i].nSpline then delete DTrajEdit_DTrajs[_i].nSpline
			if IsValidNode DTrajEdit_DTrajs[_i].nDot then delete DTrajEdit_DTrajs[_i].nDot
			deleteitem DTrajEdit_DTrajs _i
			DTrajEdit_UpdateRollout()
		),
		
		function UpdateTM =
		(
			for j = 1 to DTrajEdit_TMWatch_nNodeToUpdate.count do
			(
				local iTraj
				for i = 1 to DTrajEdit_DTrajs.count do
				(
					if DTrajEdit_TMWatch_nNodeToUpdate[j] == DTrajEdit_DTrajs[i].nRoot then
					(
						iTraj = i
						exit()
					)
				)
				if iTraj != undefined then
				(
					if not(DTrajEdit_DTrajs[iTraj].bVis) then
					(
						DTrajEdit_DTrajs[iTraj].UpdateTraj()
					)
				)
			)
			DTrajEdit_TMWatch_nNodeToUpdate = #()
		),
		
		bDisplayAll = false,
		
		function ToggleDisplayAll =
		(
			bDisplayAll = not(bDisplayAll)
			for i = DTrajEdit_DTrajs.count to 1 by -1 do
			(
				if IsValidNode DTrajEdit_DTrajs[i].nSpline and IsValidNode DTrajEdit_DTrajs[i].nDot then
				(
					DTrajEdit_DTrajs[i].bVis = bDisplayAll
					DTrajEdit_DTrajs[i].nSpline.IsHidden = bDisplayAll
					if not(bDisplayAll) then
					(
						DTrajEdit_DTrajs[i].nDot.IsHidden = DTrajEdit_DTrajs[i].bDot
					)
					else
					(
						DTrajEdit_DTrajs[i].nDot.IsHidden = true
					)
					DTrajEdit_DTrajs[i].Update_Attributes()
				)
			)
			DTrajEdit_Globals.UpdateBitmaps()
		),
		
		function DisplayCheck =
		(
			try hideByCategory.shapes = false catch()
			DTrajEdit_Globals.GetDTrajLayer() --Resfresh Layers
			for i = 1 to DTrajEdit_DTrajs.count do
			(
				if IsValidNode DTrajEdit_DTrajs[i].nSpline and IsValidNode DTrajEdit_DTrajs[i].nDot and IsValidNode DTrajEdit_DTrajs[i].nRoot then
				(
					DTrajEdit_DTrajs[i].nSpline.IsHidden = DTrajEdit_DTrajs[i].bVis
					if DTrajEdit_DTrajs[i].bVis then
					(
						DTrajEdit_DTrajs[i].nDot.IsHidden = true
					)
					else
					(
						DTrajEdit_DTrajs[i].nDot.IsHidden = DTrajEdit_DTrajs[i].bDot
					)
					DTrajEdit_DTrajs[i].nSpline.IsFrozen = true
					DTrajEdit_DTrajs[i].nDot.IsFrozen = true
					DTrajEdit_DTrajs[i].nRoot.IsHidden = true
				)
			)
		),
		
		function UpdateBitmaps =
		(
			local iHidden = 0
			for i = 1 to DTrajEdit_DTrajs.count do
			(
				try
				(
					if not(DTrajEdit_DTrajs[i].bVis) then
					(
						execute ("DTrajEdit_Rollout.btn_Display" + i as string + ".images = #(DTrajEdit_Globals.bmp_Display, undefined, 1, 1, 1, 1, 1)")
					)
					else
					(
						execute ("DTrajEdit_Rollout.btn_Display" + i as string + ".images = #(DTrajEdit_Globals.bmp_Display_ON, undefined, 1, 1, 1, 1, 1)")
					)
					if not(DTrajEdit_DTrajs[i].bDot) then
					(
						execute ("DTrajEdit_Rollout.btn_Dot" + i as string + ".images = #(DTrajEdit_Globals.bmp_Dot, undefined, 1, 1, 1, 1, 1)")
					)
					else
					(
						execute ("DTrajEdit_Rollout.btn_Dot" + i as string + ".images = #(DTrajEdit_Globals.bmp_Dot_ON, undefined, 1, 1, 1, 1, 1)")
					)
					if DTrajEdit_DTrajs[i].bVis then iHidden += 1
					)
				catch()
			)
			
			if iHidden != DTrajEdit_DTrajs.count then bDisplayAll = false else bDisplayAll = true
			
			try
			(
				if not(bDisplayAll) then
				(
					execute ("DTrajEdit_Rollout.btn_DisplayAll.images = #(DTrajEdit_Globals.bmp_DisplayAll, undefined, 1, 1, 1, 1, 1)")
				)
				else
				(
					execute ("DTrajEdit_Rollout.btn_DisplayAll.images = #(DTrajEdit_Globals.bmp_DisplayAll_ON, undefined, 1, 1, 1, 1, 1)")
				)
			)
			catch()
		),

		function CallCheck =
		(
			callbacks.removeScripts id:#DTrajEdit_Callbacks
			callbacks.addScript #filePostOpen "DTrajEdit_Globals.CallReset()" id:#DTrajEdit_Callbacks
			callbacks.addScript #systemPostNew "DTrajEdit_Globals.CallReset()" id:#DTrajEdit_Callbacks
			callbacks.addScript #systemPostReset "DTrajEdit_Globals.CallReset()" id:#DTrajEdit_Callbacks
		),	
		
		function CheckForSurvivors =
		(
			DTrajEdit_DTrajs = #()
			local nRootNodes = for o in objects where (isproperty o "DTrajEdit_szName") collect o
			for i = 1 to nRootNodes.count do
			(
				if IsValidNode nRootNodes[i] and IsValidNode nRootNodes[i].DTrajEdit_nSpline and IsValidNode nRootNodes[i].DTrajEdit_nDot then
				(	
					append DTrajEdit_DTrajs (DTrajObject vSplineCol:nRootNodes[i].DTrajEdit_nSpline.wirecolor vDotCol:nRootNodes[i].DTrajEdit_nDot.wirecolor szName:nRootNodes[i].DTrajEdit_szName nSpline:nRootNodes[i].DTrajEdit_nSpline nDot:nRootNodes[i].DTrajEdit_nDot nRoot:nRootNodes[i] bDot:nRootNodes[i].DTrajEdit_bDot bVis:nRootNodes[i].DTrajEdit_bVis iMin:nRootNodes[i].DTrajEdit_iMin iMax:nRootNodes[i].DTrajEdit_iMax)
				)
			)
		),
		
		function CallReset =
		(
			callbacks.removeScripts id:#DTrajEdit_Callbacks
			deleteAllChangeHandlers  id:#DTrajTMWatch
			
			CheckForSurvivors()
			
			for i = 1 to DTrajEdit_DTrajs.count do
			(
				if IsValidNode DTrajEdit_DTrajs[i].nRoot then
				(
					when transform DTrajEdit_DTrajs[i].nRoot changes handleAt:#redrawViews id:#DTrajTMWatch nNode do
					(
						if (finditem DTrajEdit_TMWatch_nNodeToUpdate nNode) == 0 then append DTrajEdit_TMWatch_nNodeToUpdate nNode
					)	
				)
			)
			
			DTrajEdit_UpdateRollout()
			
			callbacks.addScript #nodeUnfreeze "DTrajEdit_Globals.DisplayCheck()" id:#DTrajEdit_Callbacks
			callbacks.addScript #nodefreeze "DTrajEdit_Globals.DisplayCheck()" id:#DTrajEdit_Callbacks
			callbacks.addScript #nodeUnhide "DTrajEdit_Globals.DisplayCheck()" id:#DTrajEdit_Callbacks
			callbacks.addScript #nodehide "DTrajEdit_Globals.DisplayCheck()" id:#DTrajEdit_Callbacks
			callbacks.addScript #filePreOpen "DTrajEdit_Globals.CallCheck()" id:#DTrajEdit_Callbacks
			callbacks.addScript #systemPreNew "DTrajEdit_Globals.CallCheck()" id:#DTrajEdit_Callbacks
			callbacks.addScript #systemPreReset "DTrajEdit_Globals.CallCheck()" id:#DTrajEdit_Callbacks
		)	
	)
	DTrajEdit_Globals = DTrajEdit_Globals_Struct()
		
	global DTrajEdit_Rollout
	function DTrajEdit_UpdateRollout =
	(
		local szExecute = "
			rollout DTrajEdit_Rollout \"\" width:244 height:70
	(
		bitmap bmp_Titlebmp pos:[-1,-1] width:255 height:44 bitmap:DTrajEdit_Globals.bmp_Title
		button btn_New \"\" pos:[113,4] width:34 height:17 images:#(DTrajEdit_Globals.bmp_New, undefined, 1, 1, 1, 1, 1) tooltip:\"NEW TRAJECTORY (Follows a POLYGON) :\nClick this button then pick a spot on an \nUNFROZEN MESH where you want your TRAJECTORY\"
		button btn_New_Pivot \"\" pos:[113,21] width:34 height:17 images:#(DTrajEdit_Globals.bmp_New_Pivot, undefined, 1, 1, 1, 1, 1) tooltip:\"NEW TRAJECTORY (Follows the PIVOT POINT) :\nSelect ONE OBJECT then click this button\"
		
		button btn_DisplayAll \"\" pos:[147,4] width:34 height:34 tooltip:\"HIDE ALL Trajectories\"
		button btn_About \"\" pos:[181,4] width:34 height:34 images:#(DTrajEdit_Globals.bmp_About, undefined, 1, 1, 1, 1, 1) tooltip:\"ABOUT\"
		button btn_Exit \"\" pos:[215,4] width:34 height:34 images:#(DTrajEdit_Globals.bmp_Exit, undefined, 1, 1, 1, 1, 1) tooltip:\"EXIT\"
		timer tm_clock interval:20 active:true
		
		on tm_clock tick do DTrajEdit_Globals.UpdateTM()
		
		on DTrajEdit_Rollout open do DTrajEdit_Globals.UpdateBitmaps()
		
		on DTrajEdit_Rollout mousemove pos do DTrajEdit_Globals.MoveWindow DTrajEdit_Rollout
		on DTrajEdit_Rollout lbuttondown pos do DTrajEdit_Globals.IsReadyToMove DTrajEdit_Rollout pos
		on DTrajEdit_Rollout lbuttonup pos do DTrajEdit_Globals.LetGoTheWindow()	
		
		on btn_About pressed do
		(
			messagebox \"DTrajEdit 2.07\nEricDLegare.com\n---------------------------------------------\nProgramming : Eric D Legare\nIcons: Simon Dubuc\n---------------------------------------------\" title:\"DTrajEdit\"
		)
		on btn_New pressed do DTrajEdit_Globals.NewTraj false
		on btn_New_Pivot pressed do DTrajEdit_Globals.NewTraj true
		
		on btn_DisplayAll pressed do DTrajEdit_Globals.ToggleDisplayAll()
		on btn_Exit pressed do
		(
			DTrajEdit_Globals = undefined
			DestroyDialog DTrajEdit_Rollout
			callbacks.removeScripts id:#DTrajEdit_Callbacks
			deleteAllChangeHandlers  id:#DTrajTMWatch
			gc()
		)
		
		"
		local vSpacing = 34
		local ArToDel = #()
		if DTrajEdit_DTrajs.count > 0 then
		(
			for i = DTrajEdit_DTrajs.count to 1 by -1 do
			(
				if DTrajEdit_DTrajs[i] == undefined then
				(	
					deleteitem DTrajEdit_DTrajs i
					continue
				)
				if not(IsValidNode DTrajEdit_DTrajs[i].nRoot) or not(IsValidNode DTrajEdit_DTrajs[i].nSpline) or not(IsValidNode DTrajEdit_DTrajs[i].nDot) then
				(
					if IsValidNode DTrajEdit_DTrajs[i].nRoot then delete DTrajEdit_DTrajs[i].nRoot
					if IsValidNode DTrajEdit_DTrajs[i].nSpline then delete DTrajEdit_DTrajs[i].nSpline
					if IsValidNode DTrajEdit_DTrajs[i].nDot then delete DTrajEdit_DTrajs[i].nDot
					deleteitem DTrajEdit_DTrajs i
				)
			)
			
			for i = DTrajEdit_DTrajs.count to 1 by -1 do
			(	
				if DTrajEdit_DTrajs[i] != undefined and IsValidNode DTrajEdit_DTrajs[i].nSpline and IsValidNode DTrajEdit_DTrajs[i].nDot and IsValidNode DTrajEdit_DTrajs[i].nRoot then
				(
					local vBackPos = ([-1,44+(vSpacing*(i-1))] as string) 
					local vNamePos = ([-3,44+(vSpacing*(i-1))] as string) 
					local vStartPos = ([202,44+(vSpacing*(i-1))] as string) 
					
					local vDotCol = ([89,61+(vSpacing*(i-1))] as string) 
					local vSplineCol = ([104,61+(vSpacing*(i-1))] as string) 
					local vMovePos = ([124,61+(vSpacing*(i-1))] as string) 
					local vDotPos = ([140,61+(vSpacing*(i-1))] as string) 
					local vDisplayPos = ([156,61+(vSpacing*(i-1))] as string) 
					local vDeletePos = ([172,61+(vSpacing*(i-1))] as string) 
					local vRangePos = ([188,61+(vSpacing*(i-1))] as string) 
					local vEndPos = ([202,61+(vSpacing*(i-1))] as string) 
					
					--szExecute += ("bitmap bmp_Spacer" + (i as string) + " pos:" + vBackPos + " width:255 height:43 \n")

					szExecute += ("edittext edt_Name" + (i as string) + " \"\" pos:" + vNamePos + " width:206 height:16 text:\"" + DTrajEdit_DTrajs[i].sZname + "\"\n")
					szExecute += ("on edt_Name" + (i as string) + " entered val do DTrajEdit_DTrajs[" + (i as string) + "].Rename val\n")
					szExecute += ("spinner spn_Start" + (i as string) + " \"\" pos:" + vStartPos + " width:52 height:16 type:#integer range:[-99999,99999," + (DTrajEdit_DTrajs[i].iMin as string) +"]\n")
					szExecute += ("spinner spn_End" + (i as string) + " \"\" pos:" + vEndPos + " width:52 height:16 type:#integer range:[-99999,99999," + (DTrajEdit_DTrajs[i].iMax as string) +"]\n")
					szExecute += ("on spn_Start" + (i as string) + " changed val do if (spn_End" + (i as string) + ".value - 1) <= val then spn_End" + (i as string) + ".value = (val + 2)\n")
					szExecute += ("on spn_End" + (i as string) + " changed val do if (spn_Start" + (i as string) + ".value + 1) >= val then spn_Start" + (i as string) + ".value = (val - 2)\n")
					szExecute += ("on spn_Start" + (i as string) + " entered do DTrajEdit_DTrajs[" + (i as string) + "].ReRange spn_Start" + (i as string) + ".value spn_End" + (i as string) + ".value\n")
					szExecute += ("on spn_End" + (i as string) + " entered do DTrajEdit_DTrajs[" + (i as string) + "].ReRange spn_Start" + (i as string) + ".value spn_End" + (i as string) + ".value\n")
					szExecute += ("button btn_Range" + (i as string) + " \"\" pos:" + vRangePos + " width:16 height:16 images:#(DTrajEdit_Globals.bmp_Range, undefined, 1, 1, 1, 1, 1)  tooltip:\"Reset the RANGE to the Active Time Segment\"")
					szExecute += ("on btn_Range" + (i as string) + " pressed do DTrajEdit_DTrajs[" + (i as string) + "].ReRange (spn_Start" + (i as string) + ".value = AnimationRange.Start) (spn_End" + (i as string) + ".value = AnimationRange.End)\n")
					
					szExecute += ("button btn_Move" + (i as string) + " \"\" pos:" + vMovePos + " width:16 height:16 images:#(DTrajEdit_Globals.bmp_Move, undefined, 1, 1, 1, 1, 1)  tooltip:\"MOVE ( Offset ) Trajectory\" \n")
					szExecute += ("on btn_Move" + (i as string) + " pressed do DTrajEdit_DTrajs[" + (i as string) + "].Move() \n")
					
					szExecute += ("button btn_Display" + (i as string) + " \"\" pos:" + vDisplayPos + " width:16 height:16 images:#(DTrajEdit_Globals.bmp_Display, undefined, 1, 1, 1, 1, 1) tooltip:\"HIDE Trajectory\" \n")
					szExecute += ("on btn_Display" + (i as string) + " pressed do DTrajEdit_DTrajs[" + (i as string) + "].ToggleDisplay() \n")
					
					szExecute += ("colorpicker col_Spline" + (i as string) + " \"\" pos:" + vSplineCol + " width:20 height:16 color:" + (DTrajEdit_DTrajs[i].vSplineCol as string) +" title:\"Trajectory\" \n")
					szExecute += ("on col_Spline" + (i as string) + " changed col do DTrajEdit_DTrajs[" + (i as string) + "].SplineCol col\n")

					szExecute += ("colorpicker col_Dot" + (i as string) + " \"\" pos:" + vDotCol + " width:20 height:16 color:" + (DTrajEdit_DTrajs[i].vDotCol as string) + " title:\"Spacing Dots\" \n")
					szExecute += ("on col_Dot" + (i as string) + " changed col do DTrajEdit_DTrajs[" + (i as string) + "].DotCol col\n")

					szExecute += ("button btn_Dot" + (i as string) + " \"\" pos:" + vDotPos + " width:16 height:16 tooltip:\"HIDE Spacing Dots\" \n")
					szExecute += ("on btn_Dot" + (i as string) + " pressed do DTrajEdit_DTrajs[" + (i as string) + "].ToggleDot() \n")

					szExecute += ("button btn_Delete" + (i as string) + " \"\" pos:" + vDeletePos + " width:16 height:16 images:#(DTrajEdit_Globals.bmp_Delete, undefined, 1, 1, 1, 1, 1)  tooltip:\"DELETE Trajectory\" \n")
					szExecute += ("on btn_Delete" + (i as string) + " pressed do DTrajEdit_Globals.DeleteTraj " + (i as string) + " \n")
		
					szExecute += "\n"
				)
			)
		)
		szExecute += ")"
		
		local vOriginalPos = if DTrajEdit_Rollout != undefined  then (GetDialogPos DTrajEdit_Rollout) else [0,0]
		try DestroyDialog DTrajEdit_Rollout catch()
		Execute szExecute
		
		if vOriginalPos != [0,0] then
		(
			CreateDialog DTrajEdit_Rollout 254 (43 + (DTrajEdit_DTrajs.count * vSpacing)) pos:vOriginalPos style:#(#style_border) bitmap:DTrajEdit_Globals.bmp_Background bmpstyle:#bmp_tile fgcolor:green
		)
		else
		(
			CreateDialog DTrajEdit_Rollout 254 (43 + (DTrajEdit_DTrajs.count * vSpacing)) style:#(#style_border) bitmap:DTrajEdit_Globals.bmp_Background bmpstyle:#bmp_tile fgcolor:green
		)
	)

	DTrajEdit_Globals.CallReset()
)