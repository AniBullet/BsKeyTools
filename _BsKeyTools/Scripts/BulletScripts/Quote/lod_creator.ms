---------------------------------------------------------------------------------------
--
--	How to use the script: 
--	Enter the no. of LOD's to be generated.
--	Enter the vert % per LOD to be reduced.
--	Select mesh/es and hit 'Generate' button. 
--	Retains skin modifier on the LOD's
--
--	What does it do:
--	Generates LOD's for the selected geo. 
--
--	Created by Abhishek Subba.
--	Email:  born2animate@gmail.com
--
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

try (destroyDialog LODRollout) catch()

rollout LODRollout "LOD Creator_v1.1"
(
	--GUI
	group "（百分比越小，顶点数越少）"
	(
		label lab1 "- 输入创建的 LODs 数量 " align:#left;
		label lab2 "- 输入每个 LODs 优化后的顶点数占比 " align:#left;
		label lab3 "- 选择一个或多个 Mesh 并点击生成 " align:#left;
		label	lab4 "- 为选中物体生成 LODs " align:#left;
	)
	group ""
	(
		spinner LOD_count "LOD 数量:" range:[1,10,1] type:#integer across:2;
		spinner vert_perc "Vert %:" range:[5,100,10] type:#integer;
		progressbar obj_prog color:blue; 
		progressbar LOD_prog color:green; 
	)
	-- group ""
	-- (
		button genLOD_btn "创建生成 | Generate" width:240 height:30;
	-- )
	label lab5 "Created by Abhishek Subba";
	label lab6 "Email: born2animate@gmail.com";
	
	-- generate LOD function
	fn genLOD origGeo vertPer LODCount = 
	(
		-- variable declaration 
		geo = "geo";
		
		select origGeo;
		-- check for the geo type
		if( (classOf origGeo) == Editable_Poly) then
		(
			geo = "poly";
		)
		else
		(
			geo = "mesh";
		)
		
		undo on
		(
			-- LOD creation
			try
			(
				select origGeo;
				if(IsValidNode (getNodeByName (origGeo.name + "_LOD" + ( LODCount as string)))) then
				(
					messageBox ("物体 " + (origGeo.name + "_LOD" + ( LODCount as string)) + " 已经存在.\n脚本将会跳过这个 LOD.                 ");
				)
				else
				(
					maxOps.cloneNodes origGeo cloneType:#copy newNodes:&nnl
					nnl.name =origGeo.name + "_LOD" + ( LODCount as string);
					objLOD2 = getNodeByName (origGeo.name + "_LOD" + ( LODCount as string));
					select objLOD2;
					modPanel.setCurrentObject $.baseObject
					modPanel.addModToSelection (MultiRes ()) ui:on	
					objLOD2.MultiRes.vertexPercent = vertPer;
					objLOD2.MultiRes.generate = true;
					max select none;
					select objLOD2; 
					objLOD2.MultiRes.generate = true;
					modPanel.setCurrentObject $.modifiers[#MultiRes]
					if (geo == "poly" ) then 
					(
						modPanel.addModToSelection (Edit_Poly ()) ui:on
						MIndex = modPanel.getModifierIndex $ $.modifiers[#Edit_Poly]; 
						maxOps.CollapseNodeTo $ MIndex off						
					)
					else
					(
						modPanel.addModToSelection (Edit_Mesh ()) ui:on
						MIndex = modPanel.getModifierIndex $ $.modifiers[#Edit_Mesh]; 
						maxOps.CollapseNodeTo $ MIndex off
					)
					select origGeo;
				)
			)
			catch
			(
				messagebox "创建失败!!                ";
			)
		)
		return true;
	)
	
	on genLOD_btn pressed do
	(
		selObj = getCurrentselection();
		if(selObj.count < 1 ) then
		(
			messagebox "请选择一个 Mesh          ";
		)
		else
		(	
			try
			(
				lodCount = LOD_count.value;
				vPer = vert_perc.value;
				j = 0;			
				for obj in selObj do
				(
					j = j +1;
					obj_prog.value = 100.*j/selObj.count ; 
					
					-- checks if the selected object is a geo or not
					if( (classOf obj) != Editable_Poly and (classOf obj) != Editable_Mesh and (classOf obj) != PolyMeshObject) then 
					(
						messagebox (obj.name + " 不是几何体.\n 将被跳过                   ");
					)
					else
					(
						for i=1 to lodCount do
						(
							newVPer= vPer * i;
							--LOD function call
							--genLOD origGeo vertPer LODCount
							if(newVPer <=99) then
							(
							genLOD obj newVPer i;
							LOD_prog.value = 100.*i/lodCount 
							)
						)
					)
					LOD_prog.value = 0;
				)
				obj_prog.value = 0;
				messagebox "LOD's 已创建!!             ";
			)
			catch
			(
				messagebox "创建失败                  ";
			)
		)
	)
)

createdialog LODRollout 250 260 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
