-- ProColor
-- Description: Simple Calculator for 3ds Max
-- Version: 0.8
-- Author: Markaelie
-- Created: December 30, 2014
-- Updated: September 29, 2020

global ProColorDialog
try (destroyDialog ProColorDialog)catch()

rollout ProColorDialog "ProColor v0.8.1"
(
	group "随机颜色"
	(
		radiobuttons RadRan labels:#("Geometry", "Selection", "All Objects") across:2
		Button DoRan "应用" tooltip:"应用到物体" width:70 height:40 align:#right
	)

	function fn_Random objs = for i in objs do i.wirecolor = random black white

	on DoRan pressed do with undo on
	(
		if RadRan.state == 1 then fn_Random geometry
		else if RadRan.state == 2 then
		(
			if selection.count > 0 then fn_Random selection
			else messagebox "请至少选择一个物体！    " beep:false
		)
		else fn_Random objects
	)

	group "随机灰色"
	(
		radiobuttons RanGray labels:#("Geometry", "Selection", "All Objects") across:2
		button DoGray "应用" tooltip:"应用到物体" width:70 height:40 align:#right
	)

	function fn_Gray objs =	for i in objs do i.wirecolor = white * random 0.2 0.8

	on DoGray pressed do with undo on
	(
		if RanGray.state == 1 then fn_Gray geometry
		else if RanGray.state == 2 then
		(
			if selection.count > 0 then	fn_Gray selection
			else messagebox "请至少选择一个物体！    " beep:false
		)
		else fn_Gray objects
	)
	
	group "选中物体渐变色"
	(
		colorpicker gcpl color:[32,64,122] width:77 height:25 align:#left across:2
		colorpicker gcpr color:[100,23,23] width:77 height:25 align:#right
	)
	
	fn apply_gradient = 
	(
		local domain = if selection.count == 0 then objects else selection
		local cnt = domain.count
		if cnt >= 2 then
		(
			local col1 = gcpl.color
			local col2 = gcpr.color
			local step = (col2 - col1) / (cnt - 1)
			for i = 1 to cnt do domain[i].wireColor = col1 + (i - 1) * step
		)
	)

	on gcpl changed val do apply_gradient()
	on gcpr changed val do apply_gradient()

	group "实时变换单色"
	(
		button btnClearMat "清除选中或所有材质" tooltip:"调节选中，否则全部。" width:150
		colorpicker rtcp "" width:152 height:20 color:[38,130,118]
		button convertBtn "颜色转换到材质球" tooltip:"调节选中，否则全部。" width:150 height:20
	)

	on btnClearMat pressed do with undo on
	(
		if selection.count > 0 then $.material = undefined
		else messagebox "请至少选择一个物体！    "
	)

	on rtcp changed new_col do with undo on
	(
		if selection.count > 0 then for obj in selection do selection.wirecolor = new_col
		else for obj in geometry do geometry.wirecolor = new_col
	)

	function fn_MatS objs =
	(
		for i in objs do
		(
			if superClassOf i == geometryClass then
			(
				myColor = i.wireColor
				i.material = standardMaterial showInViewport:true name: ("converted_with_ProColor_"+i.name)
				i.material.diffuse = (myColor)
			)
		)
	)

	function fn_MatP objs =
	(
		for i in objs do
		(
			if superClassOf i == geometryClass then
			(
				myColor = i.wireColor
				i.material = physicalMaterial showInViewport:true name: ("converted_with_ProColor_"+i.name)
				i.material.Base_Color = (myColor)
			)
		)
	)

	on convertBtn pressed do with undo on
	(
		if selection.count > 0 then
		(
			fn_MatS selection
		)
		else messagebox "请至少选择一个物体！    " beep:false
	)

	group "调节自发光"
	(
		edittext edtValue "自发光"  pos:[15,332] width:80 usePercentageWidth:true \
		percentageWidth:44.0 labelOnTop:false text:"100" bold:false readOnly:false --自发光数值
		button btnSet "应用"  pos:[100,331] width:60 height:18 tooltip:"调节选中，否则全部。"
		button btnSet0 "0"  pos:[15,355] width:70 height:15 tooltip:"调节选中，否则全部。"
		button btnSet100 "100"  pos:[90,355] width:70 height:15 tooltip:"调节选中，否则全部。"
		slider sldValue ""  pos:[15,375] align:#center range:[0,100,0] \
		type:#integer tooltip:"调节选中，否则全部。" width:160
	)

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


	hyperLink author "markaelie" address:"https://markaelie.github.io" pos:[10,420] \
	color:(color 255 255 255) hovercolor:(color 255 0 0) visitedcolor:(color 255 255 255) \			
	HyperLink lnkLink "Adapter: Bullet.S"
		color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor \
		address:"https://www.anibullet.com/post/6271.html" pos:[85,420]
)--rollout

createDialog ProColorDialog 180 440