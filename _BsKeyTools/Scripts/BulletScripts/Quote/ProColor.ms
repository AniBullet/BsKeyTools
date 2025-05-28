-- WireColor Pro
-- Author: markulie
-- Description: Object color randomization, instance sync, gradients, and material control for 3ds Max.
-- Version: 1.24
-- Created: December 30, 2014
-- Updated: August 24, 2023
-- Website: https://github.com/markulie
-- Download: https://github.com/markulie/WireColorPro
-- Modified：Bullet.S 2025.05

global rolProColor  
try ( destroyDialog rolProColor ) catch()   

gc()   

rollout rolProColor "WireColor Pro v1.24" width:260 height:380
( 
	button btnAbout "?" pos:[rolProColor.width - 40,0] height:16 width:20
	button btnClose "X" pos:[rolProColor.width - 20,0] height:16 width:20
	label lblTitle "调色工具_v1.24_Mod" pos:[5,3]
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	groupBox gpbType "" pos:[5,25] width:250 height:145

	radiobuttons radObject "类型" pos:[20,40] labels:#( "几何体", "形状", "所有组", "所有物体", "选择物体" ) 
	radiobuttons radColor "配色" pos:[130,45] columns:2 labels:#( "粉彩", "灰白", "毒彩" , "黏土" , "淡彩", "深沉" , "荧彩", "随机") 
	checkButton chkIsInstance "相关实例" pos:[20,140] height:20 width:80 tooltip:"启用后，相关实例\r\n(如复制出的Instance)\r\n也会保持一致的颜色。" height:  30 align:#left 
	checkbutton btnRandom ">> 随机颜色 <<" pos:[120,130] height:30 width:125 border:false checked:true 

	groupBox gpbGradient "渐变" pos:[5,180] width:170 height:45
	colorpicker cpGradient1 pos:[15,200] color:  [58, 122, 205] width:70 height:15 align:#left 
	colorpicker cpGradient2 pos:[95,200] color:  [139, 49, 165] width:70 height:15 align:#right

	groupBox gpbRealTime "实时" pos:[185,180] width:70 height:45
	colorpicker cp "" pos:[195,200] width:50 height:15 color:  [119, 95, 192] align:#center

	groupBox gpbMaterial "材质" pos:[5,230] width:250 height:60
	radiobuttons radMaterial pos:[15,250] labels:#( "标准", "物理" ) columns:1
	button btnConverter "转换" pos:[70,250] width:50 height:30 tooltip:"Convert WireColor to Material" width:70 height:30

	radiobuttons radErase pos:[140,250] labels:#( "选择", "所有" )  columns:1 
	Button btnErase "清除" pos:[195,250] width:50 height:30 tooltip:"Assign to objects" width:70 height:30
	hyperLink author "markulie" pos:[15,360] address:"https://markulie.github.io" color:(color 255 255 255) hovercolor:(color 255 0 0) visitedcolor:(color 255 255 255)
-----------------------------------------------------------------------------------------------------------------------------------------

	edittext edtValue "\"卡通色\""  pos:[10,302] width:85 usePercentageWidth:true  \
	percentageWidth:44.0 labelOnTop:false text:"100" bold:false readOnly:false --自发光数值
	button btnSet "应用自发光"  pos:[180,300] width:75 height:20 tooltip:"调节选中，否则全部。\r\n需要先有材质!\r\n且非一致色彩模式!" 
	button btnSet0 "0"  pos:[105,300] width:25 height:20 tooltip:"调节选中，否则全部。" 
	button btnSet100 "100"  pos:[140,300] width:30 height:20 tooltip:"调节选中，否则全部。" 
	slider sldValue ""  pos:[10,320] align:#center range:[0,100,0]  \
	type:#integer tooltip:"调节选中，否则全部。" width:255 

	HyperLink lnkLink "Mod: Bullet.S" color:(color 255 255 255) hovercolor:(color 255 0 0) visitedcolor:(color 255 255 255) \
	address:"https://space.bilibili.com/2031113/lists/560782" pos:[165,360]

---------------------------------------------------------------------------------------------------------------------------------------------------------
	fn getRandomColor =  
	(  
		local randomColor = blue  
		if radColor.state == 1 then  
		(  
			randomColor.hue = random 0 255  
			randomColor.saturation = 120  
			randomColor.value = random 150 240  
		)  
		else if radColor.state == 2 then       
		(  
			randomColor = white * random 0.2 0.8  
		)  
		else if radColor.state == 3 then  
		(  
			randomColor.hue = random 0 255  
			randomColor.saturation = 255  
		)
		else if radColor.state == 4 then  
		(  	
			local r = random 5 30	
			randomColor = color (r*6) (r*2) r
		)
		else if radColor.state == 5 then       
		(  
			randomColor.hue = random 0 255  
			randomColor.saturation = 30  
			-- randomColor.value = 180
		)
		else if radColor.state == 6 then  
		(  
			randomColor.hue = random 0 255 
			randomColor.saturation = 90  
			randomColor.value = 90 
		)  
		else if radColor.state == 7 then  
		(  	
			randomColor.hue = random 40 140  
			randomColor.saturation = 255  
			randomColor.value = 255
		)
		else if radColor.state == 8 then  
		(  
			randomColor = random black white  
		)
		return randomColor  
	)  

	on btnRandom changed state do  
	(  
		btnRandom.state = true
		with undo on
		(	
			if radObject.state == 1 then  
			(  
				for i in geometry do  
				(  
					InstanceMgr.GetInstances i &instArray  
					if chkIsInstance.checked then  
					(  
						instArray.wirecolor = getRandomColor()   
					)  
					else  
					(  
						i.wirecolor = getRandomColor()   
					)  
				)  
			) 
			else if radObject.state == 2 then  
			(  
				for i in shapes do  
				(  
					InstanceMgr.GetInstances i &instArray  
					if chkIsInstance.checked then  
					(  
						instArray.wirecolor = getRandomColor()   
					)  
					else  
					(  
						i.wirecolor = getRandomColor()   
					)  
				)  
			)
			else if radObject.state == 3 then  
			(  
				allGroups = for obj in objects where isGroupHead obj collect obj  
				if allGroups.count == 0 then  
				(  
					messageBox "There are no groups in the scene."  
				)  
				else  
				(  
					fn changeInstancesRandom group =  
					(  
						local randomColor = getRandomColor()   
						for i in group do  
						(  
							InstanceMgr.GetInstances i &instArray  
							instArray.wirecolor = randomColor	
						)
					) 
					fn changeWireColorRandom group =  
					(  
						local randomColor = getRandomColor()   
						for i in group do  
						(
							i.wirecolor = randomColor  
						)
					)
					
					if chkIsInstance.checked then
					(
						for group in allGroups do  
						(  
							changeInstancesRandom group  
						)
					)
					for group in allGroups do  
					(  
						changeWireColorRandom group  
					)						
				)  
			) 
			else if radObject.state == 4 then  
			(  
				for i in objects do  
				(  
					InstanceMgr.GetInstances i &instArray  
					if chkIsInstance.checked then  
					(  
						instArray.wirecolor = getRandomColor()   
					)  
					else  
					(  
						i.wirecolor = getRandomColor()   
					)  
				)  
			)  				
			else if radObject.state == 5 then  
			(  
				if selection.count < 1 then messagebox "Please select at least one object"  
				else  
				(  
					for i in selection do  
					(  
						InstanceMgr.GetInstances i &instArray  
						if chkIsInstance.checked then  
						(  
							instArray.wirecolor = getRandomColor()   
						)  
						else  
						(  
							i.wirecolor = getRandomColor()   
						)  
					)  
				)  
			) 
		)
		redrawviews()   
	)  
	fn FnGradient =  
	(  
		local domain = if selection.count == 0 then objects else selection  
		local cnt = domain.count  
		if cnt >= 2 then  
		(  
			local col1 = cpGradient1.color  
			local col2 = cpGradient2.color  
			local step = ( col2 - col1 ) / ( cnt - 1 )  
			for i = 1 to cnt do domain[i].wireColor = col1 + ( i - 1 ) * step  
		)  
		redrawviews()   
	)  

	on cpGradient1 changed val do FnGradient()   
	on cpGradient2 changed val do FnGradient()   

	on cp changed newColor do  
	(  
		if selection.count > 0 then  
		(  
			for obj in selection do  
			(  
				selection.wirecolor = newColor  
			)  
		)  
		else  
		(  
			for obj in geometry do  
			(  
				geometry.wirecolor = newColor  
			)  
		)  
	)  

	fn FnMatS objs =  
	(  
		for i in objs do  
		(  
			if superClassOf i == geometryClass then  
			(  
				newColor = i.wireColor  
				i.material = standardMaterial showInViewport:true name:  ( "WireColor Pro - " + i.name )  
				i.material.diffuse = newColor  
			)  
		)  
		redrawviews()   
	)  

	fn FnMatP objs =  
	(  
		for i in objs do  
		(  
			if superClassOf i == geometryClass then  
			(  
				newColor = i.wireColor  
				i.material = physicalMaterial showInViewport:true name:  ( "WireColor Pro - " + i.name )  
				i.material.Base_Color = newColor  
			)  
		)  
		redrawviews()   
	)  

	on btnConverter pressed do  
	(  
		if selection.count < 1 then  
		(  
			messagebox "Please select at least one object"  
		)  
		else  
		(  
			if radMaterial.state == 1 then  
			(  
				FnMatS selection  
			)  
			else if radMaterial.state == 2 then  
			(  
				FnMatP selection  
			)  
		)  
	)  
	on btnErase pressed do  
	(  
		if radErase.state == 1 then  
		(  
			if selection.count < 1 then  
			(  
				messagebox "Please select at least one object"  
			)  
			else  
			(  
				$.material = undefined  
			)  
		)  
		else  
		(  
			if geometry.count < 1 then  
			(  
				messagebox "You have no geometry objects"  
			)  
			else  
			(  
				geometry.material = undefined  
			)  
		)  
	)  

	-- End  

	local selfValue = 100
	local arrSelObj = #()


	fn jugdeSel =
	(
		if (selection.count == 0) then
		(
			arrSelObj = #()
			for i in objects do (append arrSelObj i)
		)
		else
		(
			arrSelObj = #()
			for i in selection do (append arrSelObj i)
		)
	)

	fn fnSetSelfIllumAmount arrSelObj val = 
	(
		for i in arrSelObj do
		(
			if (classof i.mat == Multimaterial) do  
			(
				for s = 1 to i.mat.materialList.count do  i.mat.materialList[s].selfIllumAmount = val
			)
			if (classof i.mat == Standardmaterial) do 
			(
				i.mat.selfIllumAmount = val
			)
		)
	)

	on edtValue entered val do
	(
		jugdeSel ()
		if ((val != ".") and (val as integer != undefined) and (val != "") and (val as integer <= 100) and (val as integer >= 0)) then
		(
			sldValue.value = (val as integer)
		)
	)

	on sldValue changed val do (jugdeSel ();fnSetSelfIllumAmount arrSelObj val;edtValue.text = val as string)

	on btnSet pressed do 
	(
		jugdeSel ()
		if ((edtValue.text != ".") and (edtValue.text as integer != undefined) and (edtValue.text != "") and (edtValue.text as integer <= 100) and (edtValue.text as integer >= 0)) then
		(
			fnSetSelfIllumAmount arrSelObj (edtValue.text as integer)
			sldValue.value = (edtValue.text as integer)
		)
		else messagebox "-------------------------\r\n请输入0-100的整数数值\r\n"
	)
	on btnSet0 pressed do (jugdeSel ();fnSetSelfIllumAmount arrSelObj 0;sldValue.value = 0;edtValue.text = "0")

	on btnSet100 pressed do (jugdeSel ();fnSetSelfIllumAmount arrSelObj 100;sldValue.value = 100;edtValue.text = "100")
	
	on rolProColor mbuttondown pos do 
	(
		try (destroydialog rolProColor) catch ()
	)
	
	on rolProColor lbuttondown posMou do
	(
		setSysCur #move
		offsetBsBoxMan = posMou
		dragStateBsBoxMan = on
	)
	
	on rolProColor lbuttonup posMou do
	(
		dragStateBsBoxMan = off
	)
	
	on rolProColor mouseMove pos do
	(
		if dragStateBsBoxMan == on then
		(
			SetDialogPos rolProColor (mouse.screenpos - offsetBsBoxMan)
		)
	)

	on btnAbout pressed do 
	(
		shellLaunch "https://space.bilibili.com/2031113/lists/560782" ""
	)

	on btnClose pressed do 
	(
		try (destroydialog rolProColor) catch ()
	)
)
createDialog rolProColor style:#()
