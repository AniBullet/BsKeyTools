(
	rollout SkinCombineTool "Skin Combiner"
	(
		button btnCombineSkin "合并 Skin" align:#center width:120
		button btnDetachSkin "拆分 Skin" align:#center width:120
		--button combineSkinHelp "?" align:#center
		
		local createms
		
		--STORING FUNCTIONS WILL MAKE THEM FASTER IN LOOPS
		local p_getNumFaces = polyop.getNumFaces
		local p_getElementsUsingFace = polyop.getElementsUsingFace
		local p_getVertsUsingFace = polyop.getVertsUsingFace
		local p_deleteFaces = polyop.deleteFaces
		local m_cloneNodes = maxOps.cloneNodes
		local GetVertexWeightCount = skinOps.GetVertexWeightCount
		local GetVertexWeight = skinOps.GetVertexWeight
		local GetVertexWeightBoneID = skinOps.GetVertexWeightBoneID
		local GetNumberVertices = skinOps.GetNumberVertices
		local ReplaceVertexWeights = skinOps.ReplaceVertexWeights
		local SelectVertices = skinOps.SelectVertices
		local BakeSelectedVerts = skinOps.bakeSelectedVerts
		local RemoveZeroWeights = skinOps.RemoveZeroWeights
		local isWeightToolOpen = skinOps.isWeightToolOpen
		local closeWeightTool = skinOps.closeWeightTool
		local GetBoneName =skinOps.GetBoneName
		local GetNumberBones = skinOps.GetNumberBones
		local addbone = skinOps.addbone
		local invalidate = skinOps.invalidate

		--GETS ALL THE ELEMENTS IN AN OBJECT, RETURNS AN ARRAY of BITARRAYS
		--GETS THE INVERSE ELEMENTS, TO MAKE IT EASIER TO DELETE THE REST OF THE ELEMENTS
		fn getAllElements obj =
		(
			local faceArray,liveArray,elementList,faceCount

			elementList = #()

			faceCount = p_getNumFaces obj

			faceArray = #{1..faceCount}
			liveArray = #{1..faceCount}

			while not liveArray.isEmpty do
			(
				currentArray = liveArray as array
				newElement = p_getElementsUsingFace obj (currentArray[currentArray.count])
				append elementList (faceArray-newElement)
				liveArray = liveArray - newElement
				--format "LiveArray: %\n\tnewElement: %\n" liveArray newElement
			)

			elementList
		)

		fn detachElementsWithSkin obj =
		(
			elementsArray = getAllElements obj

			--BAKE AND REMOVE ZERO WEIGHTS ON THE SKIN
			objSkin = obj.skin
			modPanel.setCurrentObject objSkin
			SelectVertices objSkin (GetNumberVertices objSkin)
			bakeSelectedVerts objSkin
			objSkin.clearZeroLimit = 0.0
			RemoveZeroWeights objSkin

			--CREATE A BIT ARRAY TO INVERT FOR THE VERTICES
			faceCount = p_getNumFaces obj
			faceArray = #{1..faceCount}

			--STORE THE VERTEX WEIGHTS
			vertWeightsArray = #()

			for ele in elementsArray do
			(
				verts = p_getVertsUsingFace obj (faceArray - ele)
				vertsEle = #()

				for v in verts do
				(
					weights = #()
					_bones = #()

					wc = GetVertexWeightCount objSkin v

					for b = 1 to wc do
					(
						append weights (GetVertexWeight objSkin v b)
						append _bones (GetVertexWeightBoneID objSkin v b)
					)

					--format "Bones: %\nWeigths: %\n" _bones weights

					append vertsEle #(_bones,weights)
				)

				append vertWeightsArray vertsEle

			)

			--format "%\n" vertWeightsArray

			--CLONE AND FIX THE SKIN WEIGHTS
			for i = 1 to elementsArray.count do
			(
				--DUPE THE OBJECT
				m_cloneNodes obj newNodes:&newObjs
				p_deleteFaces newObjs[1] elementsArray[i]

				newObjSkin = newObjs[1].skin

				modPanel.setCurrentObject newObjSkin

				--LOAD THE VERTEX WEIGHTS
				vCount = (GetNumberVertices newObjSkin)
				--print vCount

				for v = 1 to vCount do
				(
					ReplaceVertexWeights newObjSkin v vertWeightsArray[i][v][1] vertWeightsArray[i][v][2]
					--format "Skin: %\nV: %\nWeights: %\nBones: %\n" newObjSkin v vertWeightsArray[i][v][1] vertWeightsArray[i][v][2]
				)
			)

			delete obj
		)
		
		fn combineSkin = 
		(
			clearlistener()
			max modify mode
			
			--INIT SOME VARIABLES
			local proceed = true
			local selObjs = getCurrentSelection()
			local selCount = selObjs.count
			
			--BONENAMEARRAY
			local NameArray = #()
			
			--ERROR CHECK
			if selection.count <= 1 do proceed = false
			for obj in selObjs while proceed == true do
			(
				if not isProperty obj #skin do
				(
					
					proceed = false
				)
			)
			
			if proceed do
			(
				--SAVE WEIGHTS
				createms = "" as stringstream
				local totalVerts = 0
				
				for obj in selObjs do
				(
					modPanel.setCurrentObject obj.skin
					
					if InstanceMgr.CanMakeModifiersUnique obj obj.skin do
					(
						InstanceMgr.MakeModifiersUnique obj obj.skin #individual
						invalidate obj.skin
					)
					
					local sk = obj.skin
					modPanel.setCurrentObject sk
					
					local bCount = GetNumberBones sk
					
					for b = 1 to bCount do
					(
						appendifUnique NameArray (GetBoneName sk b 1)
					)
					
					sort NameArray
					
					skinCount = GetNumberVertices sk
					
					sk.clearZeroLimit = 0.0
					RemoveZeroWeights sk
					
					for v = 1 to skinCount do
					(
						weights = #()
						_bones = #()
						
						weightCount = GetVertexWeightCount sk v
			
						for b = 1 to weightCount do
						(
							weight = GetVertexWeight sk v b
							_boneID = GetVertexWeightBoneID sk v b
							_bone = GetBoneName sk _boneID 1
							--_bone = "$'" + _bone + "'"	
								
							if weight != 0 do
							(
								append weights weight
								append _bones _bone
							)
						)
						
						--ADDING TOTAL VERTS MODIFIES THE VERTEX NUMBERS AS WE SAVE
						format "%\n%\n%\n" (v+totalVerts) weights _bones to:createms
					)
					
					totalVerts += skinCount
				)
				
				--COMBINE OBJECTS, VERT ORDER SHOULD CORESPOND TO SELECTION ORDER
				convertTo selObjs Editable_Poly
				local newObj = selObjs[1]
				select newObj
				
				for obj in selObjs where obj != newObj do
				(
					newObj.EditablePoly.attach obj newObj
				)

				--ADD A NEW SKIN MOD
				local newSkin = Skin()
				addmodifier newObj newSkin
				
				newSkin.filter_cross_sections = off
				newSkin.filter_vertices = on
				newSkin.showNoEnvelopes = on
				newSkin.wt_showGlobal = on
				newSkin.wt_activeVertexSet = 1
				newSkin.wt_showAffectedBones = on
				
				for i = 1 to NameArray.count do
				(
					addbone newSkin (getNodeByName NameArray[i]) 1
				)
				
				completeredraw()

				--GO TO THE BEGINING OF THE STREAM STREAM, AND COLLECT THE BONES
				seek createms 0
				
				--LOAD THE WEIGHTS
				while not eof createms do
				(
					boneIDarray = #()
					
					a = execute(readline createms)
					b = execute(readline createms)
					c = execute(readline createms)
					
					local bCount = c.count
					
					for i = 1 to bCount do
					(
						local BoneID = findItem NameArray c[i]
						
						if BoneID != 0 do
						(
							append boneIDarray BoneID
						)
					)
						
					ReplaceVertexWeights newSkin a boneIDarray b
				)
				
				--ns = newScript()
				--format "%\n" (createms as string) to:ns
			)
		)
		
		on combineSkinHelp pressed do messagebox  "Select several skinned meshes and this tool will combine them into one object and skin modifier." Title:"Help"

		on btnCombineSkin pressed do
		(
			--windows.sendmessage (windows.getmaxhwnd()) 0x000B 0 1
			
			--t = timeStamp()
				
			try(combineSkin())
			catch(format "\%n" (getcurrentexception()))
				
			--format "%\n" (t-timeStamp())
				
			--windows.sendmessage (windows.getmaxhwnd()) 0x000B 1 1
		)

		
		on btnDetachSkin pressed do
		(
			escapeEnable = true
			clearListener()
			holdMaxFile()

			processObjs = getCurrentSelection()

			windows.sendmessage (windows.getmaxhwnd()) 0x000B 0 1

			--ts = timeStamp()
			for obj in processObjs do with redraw off
			(
				try(detachElementsWithSkin obj)
				catch(format "Object: % failed to process. Could be frozen or hidden.\n" obj.name)
			)
			--format "%\n" (timeStamp()-ts)

			clearselection()

			windows.sendmessage (windows.getmaxhwnd()) 0x000B 1 1
		)

	)

	createDialog SkinCombineTool
)