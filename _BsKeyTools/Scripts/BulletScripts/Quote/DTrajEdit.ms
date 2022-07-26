-- 名称：轨迹插件终极版重置版
-- 作者:东见云
-- 版本：v1.0
-- 3dsmax：2014+
-- 功能：动画轨迹
-- 联系方式：yun7928903@163.com


---尝试关闭回调
try(unRegisterTimeCallback yun_refreshDT_byTime_new_fn)catch()
try unregisterRedrawViewsCallback yunMotionPathCallBackFn_exc catch()
----尝试关闭界面
try DestroyDialog  yunTrajedit_rollout catch ()
	
function yunTrajEdit_UpdateRollout = () -- Proto放报错初始化	
---定义所有轨迹	
global yunTrajEdit_DTrajs  
if yunTrajEdit_DTrajs == undefined do yunTrajEdit_DTrajs = #()
-----轨迹点标显隐用
global yunTrajEdit_DTrajs_dot 
if yunTrajEdit_DTrajs_dot == undefined do yunTrajEdit_DTrajs_dot = #()
-----轨迹显隐用
global yunTrajEdit_DTrajs_vis
if yunTrajEdit_DTrajs_vis == undefined do yunTrajEdit_DTrajs_vis = #()
-----实时开关用
global yunTrajEdit_DTrajs_timeLong
if yunTrajEdit_DTrajs_timeLong == undefined do yunTrajEdit_DTrajs_timeLong = #()





----场景内物体是否存在检查函数
function yunTrajEdit_CheckExsitError  = 
(
	for i in  yunTrajEdit_DTrajs do 
	(	
		if (isvalidnode i)==false do 
		(yunTrajEdit_DTrajs = #();yunTrajEdit_DTrajs_dot = #();yunTrajEdit_DTrajs_vis = #();yunTrajEdit_DTrajs_timeLong = #() )
	)
)
yunTrajEdit_CheckExsitError()
if yunTrajEdit_DTrajs.count!=yunTrajEdit_DTrajs_dot.count or
yunTrajEdit_DTrajs_dot.count!=yunTrajEdit_DTrajs_vis.count or 
yunTrajEdit_DTrajs_vis.count!=yunTrajEdit_DTrajs_timeLong.count do
(yunTrajEdit_DTrajs = #();yunTrajEdit_DTrajs_dot = #();yunTrajEdit_DTrajs_vis = #();yunTrajEdit_DTrajs_timeLong = #() )

------实时改变函数
Fn yun_refreshDT_byTime_new_fn  = 
(	
	if yunTrajEdit_DTrajs_timeLong.count > 0 then
	(
		for i = yunTrajEdit_DTrajs_timeLong.count to 1 by -1 do
		(	
			if yunTrajEdit_DTrajs_timeLong[i] do
			(
				execute ("yunTrajEdit_Rollout.spn_Start"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame - yunTrajEdit_Rollout.time_FB"+ (i as string)+".value")
				execute ("yunTrajEdit_Rollout.spn_End"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame + yunTrajEdit_Rollout.time_FB"+ (i as string)+".value")	
			)
		)
	)
			
)



-----点标性状控制
KeyP_shape = #("hollowBox","plusSign","asterisk","xMarker","bigBox","circle","triangle","diamond","smallHollowBox","smallCircle","smallTriangle")
global dotShape = "smallDiamond"
---实例变量
global yunTrajEdit_Globals	
-- 图标位置
global pathIcons = ((getDir #scripts) + "\\BulletScripts\\Res")

-----封装处
(
----实例结构
struct yunTrajEdit_Globals_Struct
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
	
	
	
	---切大小界面 图标
	bDisplayAll = false,
	function ToggleDisplayAll =
	(
		bDisplayAll = not(bDisplayAll)		
		yunTrajEdit_Globals.UpdateBitmaps()
	),
	---切大小界面  + 刷新图标
	function UpdateBitmaps =
	(
		--bDisplayAll = not(bDisplayAll)
		try
		(
			if not(bDisplayAll) then
			(
				execute ("yunTrajedit_rollout.btn_DisplayAll.images = #(yunTrajEdit_Globals.bmp_DisplayAll, undefined, 1, 1, 1, 1, 1)")
				yunTrajedit_rollout.width = 254
				if yunTrajEdit_DTrajs.count > 0 do
				(yunTrajedit_rollout.height = 43+34*(yunTrajEdit_DTrajs.count))
			--yunTrajedit_rollout.height = 40
			)
			else
			(
				execute ("yunTrajedit_rollout.btn_DisplayAll.images = #(yunTrajEdit_Globals.bmp_DisplayAll_ON, undefined, 1, 1, 1, 1, 1)")
				yunTrajedit_rollout.width = 37
				yunTrajedit_rollout.height = 40
			)
		)
		catch()
	),
	----新建轨迹
	function NewTraj _bPivot =
	(			
		local nParent	
		----分类型用 的，暂时无用
		if _bPivot do
		(
			---检查是否选择了一个物体
			if selection.count == 1 then   
			(
				nParent = selection[1]
			)
-- 				else (messagebox "来选一个嘛..." title:"yunTrajEdit")
		)			
		setWaitCursor()				
		
		
		-----真正创建轨迹
		if IsValidNode nParent then
		(
			
			if (findItem yunTrajEdit_DTrajs nParent)== 0 do
			(
			appendIfUnique yunTrajEdit_DTrajs nParent
			append yunTrajEdit_DTrajs_dot true
			append yunTrajEdit_DTrajs_vis true
			append yunTrajEdit_DTrajs_timeLong false
			)
			
		)
		else
		(
		messagebox "来选一个嘛...  ." title:"yunTrajEdit"				
		)
		----界面重生
		yunTrajEdit_UpdateRollout()
	),
	---删除轨迹
	function DeleteTraj _i =
	(
		if IsValidNode yunTrajEdit_DTrajs[_i] do 
		(	
			deleteitem yunTrajEdit_DTrajs _i
			deleteItem yunTrajEdit_DTrajs_dot  _i
			deleteItem yunTrajEdit_DTrajs_vis  _i
			deleteItem yunTrajEdit_DTrajs_timeLong  _i 
		)		
		yunTrajEdit_UpdateRollout()
	),
	---切换点标显隐
	function ToggleDot  _i =
	(
		try
		(					
			if (not yunTrajEdit_DTrajs_dot[_i]) then
			(
				execute ("yunTrajEdit_Rollout.btn_Dot" + _i as string + ".images = #(yunTrajEdit_Globals.bmp_Dot, undefined, 1, 1, 1, 1, 1)")
				yunTrajEdit_DTrajs_dot[_i] = true
			)
			else
			(
				execute ("yunTrajEdit_Rollout.btn_Dot" + _i as string + ".images = #(yunTrajEdit_Globals.bmp_Dot_ON, undefined, 1, 1, 1, 1, 1)")
				yunTrajEdit_DTrajs_dot[_i] = false
			)
		)			
		catch()
	),
	---切换轨迹显隐
	function ToggleDisplay _i=
	(
		try
		(					
			if (not yunTrajEdit_DTrajs_vis[_i]) then
			(
				execute ("yunTrajEdit_Rollout.btn_Display" + _i as string + ".images = #(yunTrajEdit_Globals.bmp_Display, undefined, 1, 1, 1, 1, 1)")
				yunTrajEdit_DTrajs_vis[_i] = true
			)
			else
			(
				execute ("yunTrajEdit_Rollout.btn_Display" + _i as string + ".images = #(yunTrajEdit_Globals.bmp_Display_ON, undefined, 1, 1, 1, 1, 1)")
				yunTrajEdit_DTrajs_vis[_i] = false
			)
		)			
		catch()
	)
)


------生成轨迹函数
fn yunMotionPathCallBackFn  obj vis isdot col_Start  col_End tStart tEnd dotShape =
(
	if vis and  not isAnimPlaying()  do
	(	
	
		---获取数据 
		(	
			if  ((currentTime as string) as integer) > tStart and
			((currentTime as string) as integer)  < tEnd then
			(tNow = (currentTime as string) as integer)			
			else (tNow = tStart+1 )
			
			framesA = #()
			for i = tStart to tNow do append framesA i
			framesB = #()
			for i = tNow to tEnd do append framesB i
				
			----------------------------------------------------
			arrA = #()  --帧数
			arrColorA = #()   --颜色
			for vT in framesA do 
			(
			at time  vT 
				(				
					append arrA  obj.transform.pos
					append arrColorA col_Start 	
					
				)
			)	
			----------------------------------------------------
			arrB = #()
			arrColorB = #()
			for vT in framesB do 
			(
			at time  vT 
				(				
					append arrB  obj.transform.pos
					append arrColorB col_End
					
				)
			)
		)
		
		-- reset
		gw.setTransform(Matrix3 1)		
		--生成前半段
		for i = 1 to arrA.count do
		(			
			arrA[i] = gw.wTransPoint arrA[i] 
			if isdot then 
			( 
				case of
				(
					(dotShape=="hollowBox"): gw.wMarker arrA[i] #hollowBox color:col_Start
					(dotShape=="plusSign"): gw.wMarker arrA[i] #plusSign color:col_Start
					(dotShape=="asterisk"): gw.wMarker arrA[i] #asterisk color:col_Start
					(dotShape=="xMarker"): gw.wMarker arrA[i] #xMarker color:col_Start
					(dotShape=="bigBox"): gw.wMarker arrA[i] #bigBox color:col_Start
					(dotShape=="circle"): gw.wMarker arrA[i] #circle color:col_Start
					(dotShape=="triangle"): gw.wMarker arrA[i] #triangle color:col_Start
					(dotShape=="diamond"): gw.wMarker arrA[i] #diamond color:col_Start
					(dotShape=="smallHollowBox"): gw.wMarker arrA[i] #smallHollowBox color:col_Start
					(dotShape=="smallCircle"): gw.wMarker arrA[i] #smallCircle color:col_Start
					(dotShape=="smallTriangle"): gw.wMarker arrA[i] #smallTriangle color:col_Start
					default: gw.wMarker arrA[i] #smallDiamond       color:col_Start
				)
			)
			else (gw.wMarker arrA[i] #point  color:col_Start)
		)
			gw.wPolyline arrA false  rgb:arrColorA			
		----生成后半段
		for i = 1 to arrB.count do
		(
			arrB[i] = gw.wTransPoint arrB[i] 
			if isdot then 
			( 
				case of
				(
					(dotShape=="hollowBox"): gw.wMarker arrB[i] #hollowBox  color:col_End
					(dotShape=="plusSign"): gw.wMarker arrB[i] #plusSign color:col_End
					(dotShape=="asterisk"): gw.wMarker arrB[i] #asterisk color:col_End
					(dotShape=="xMarker"): gw.wMarker arrB[i] #xMarker color:col_End
					(dotShape=="bigBox"): gw.wMarker arrB[i] #bigBox 	color:col_End
					(dotShape=="circle"): gw.wMarker arrB[i] #circle color:col_End
					(dotShape=="triangle"): gw.wMarker arrB[i] #triangle color:col_End
					(dotShape=="diamond"): gw.wMarker arrB[i] #diamond color:col_End
					(dotShape=="smallHollowBox"): gw.wMarker arrB[i] #smallHollowBox color:col_End
					(dotShape=="smallCircle"): gw.wMarker arrB[i] #smallCircle color:col_End
					(dotShape=="smallTriangle"): gw.wMarker arrB[i] #smallTriangle color:col_End
					default: gw.wMarker arrB[i] #smallDiamond       color:col_End
				)
-- 				gw.wMarker arrB[i]  #hollowBox       color:col_End
			)	
			else(  	gw.wMarker arrB[i]  #point  color:col_End )
		)
		gw.wPolyline arrB false  rgb:arrColorB
		
		at time (currentTime) (posRescue=  obj.transform.pos)
		gw.wMarker posRescue #smallDiamond color:col_End


		
		-- Update the viewports	 
		gw.enlargeUpdateRect #whole 
		gw.updateScreen()
	)
)
function yunMotionPathCallBackFn_exc =
(
	----放报错判断
	if yunTrajEdit_DTrajs.count > 0 do
	(
		----全局变量整理
		yunTrajEdit_CheckExsitError()
		

		-----检查结束开启轨迹
		for i = yunTrajEdit_DTrajs.count to 1 by -1 do
		(			
			col_start = Execute ("yunTrajedit_rollout.col_Dot" + (i as string) + ".color")
			col_end = Execute ("yunTrajedit_rollout.col_Spline" + (i as string) + ".color")
			tStart = Execute ("yunTrajedit_rollout.spn_Start" + (i as string) + ".value")
			tEnd = Execute ("yunTrajedit_rollout.spn_End" + (i as string) + ".value")
			if yunTrajEdit_DTrajs_dot.count > 0 do ( isdot = yunTrajEdit_DTrajs_dot[i] )
			if yunTrajEdit_DTrajs_vis.count > 0 do ( vis = yunTrajEdit_DTrajs_vis[i] )
			
			if yunTrajEdit_DTrajs[i] != undefined and
			col_start != undefined	and
			col_end != undefined and 
			tStart != undefined and 
			tStart != undefined and
			vis != undefined and
			dotShape != undefined and
			dotShape != undefined and	
			isdot != undefined do			
			(	
				(yunMotionPathCallBackFn   yunTrajEdit_DTrajs[i] vis  isdot col_start col_end tStart tEnd dotShape)
			)
		)
	)
)
------生成轨迹函数结束e


------实时改变函数
Fn yun_refreshDT_byTime_new_fn  = 
(	
	if yunTrajEdit_DTrajs_timeLong.count > 0 then
	(
		for i = yunTrajEdit_DTrajs_timeLong.count to 1 by -1 do
		(	
			if yunTrajEdit_DTrajs_timeLong[i] do
			(
				execute ("yunTrajEdit_Rollout.spn_Start"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame - yunTrajEdit_Rollout.time_FB"+ (i as string)+".value")
				execute ("yunTrajEdit_Rollout.spn_End"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame + yunTrajEdit_Rollout.time_FB"+ (i as string)+".value")	
			)
		)
	)
			
)




---实例化
(yunTrajEdit_Globals = yunTrajEdit_Globals_Struct())

-----界面出生函数
global yunTrajEdit_Rollout
function yunTrajEdit_UpdateRollout =
(	
	
	
	
	local szExecute = "
	rollout yunTrajedit_rollout \"\" width:254 height:40
	(\n
	--bDisplayAll = false
	---开关按钮
	button btn_DisplayAll \"\" pos:[1,4] width:34 height:34 tooltip:\"大小如意\"
	---logo图标
	bitmap bmp_Titlebmp pos:[35,1] width:255 height:40 bitmap:yunTrajEdit_Globals.bmp_Title
	---关于按钮
	button btn_About \"\" pos:[152,4] width:34 height:34 images:#(yunTrajEdit_Globals.bmp_About, undefined, 1, 1, 1, 1, 1) tooltip:\"ABOUT\"

	
	---新建轨迹
	button btn_New \"\" pos:[186,4] width:34 height:17 images:#(yunTrajEdit_Globals.bmp_New, undefined, 1, 1, 1, 1, 1) tooltip:\"左键改变点标形状，右键恢复默认\"
	button btn_New_Pivot \"\" pos:[186,21] width:34 height:17 images:#(yunTrajEdit_Globals.bmp_New_Pivot, undefined, 1, 1, 1, 1, 1) tooltip:\"新建轨迹\"
	
	---退出按钮
	button btn_Exit \"\" pos:[220,4] width:34 height:34 images:#(yunTrajEdit_Globals.bmp_Exit, undefined, 1, 1, 1, 1, 1) tooltip:\"EXIT\"
	-- 窗口移动功能
	on yunTrajedit_rollout mousemove pos do yunTrajEdit_Globals.MoveWindow yunTrajedit_rollout
	on yunTrajedit_rollout lbuttondown pos do yunTrajEdit_Globals.IsReadyToMove yunTrajedit_rollout pos
	on yunTrajedit_rollout lbuttonup pos do yunTrajEdit_Globals.LetGoTheWindow()	
	
	----改变点标形状功能
	on btn_New pressed do
	(
		if dotShape == \"smallDiamond\" do (dotShape = \"hollowBox\")
		if (findItem KeyP_shape dotShape)!= 0 do 
		(	
			if (findItem KeyP_shape dotShape)==KeyP_shape.count then 
			(
				dotShape=KeyP_shape[1]
				
			)
			else 
			(
				index = (findItem KeyP_shape dotShape) +1
				dotShape = KeyP_shape[index]
			)
		)
	)
	on btn_New rightClick  do
	(
		dotShape = \"smallDiamond\"
	)
	----打开界面是刷新图标
	on yunTrajedit_rollout open do 
	(
		yunTrajEdit_Globals.UpdateBitmaps()
		try unregisterRedrawViewsCallback yunMotionPathCallBackFn_exc catch()
		registerRedrawViewsCallback yunMotionPathCallBackFn_exc

		try(unRegisterTimeCallback yun_refreshDT_byTime_new_fn)catch()		
		try (registerTimeCallback yun_refreshDT_byTime_new_fn) catch ()
		
	)
	--退出窗口功能
	on btn_Exit pressed do
	(
		try(unRegisterTimeCallback yun_refreshDT_byTime_new_fn)catch()
		try unregisterRedrawViewsCallback yunMotionPathCallBackFn_exc catch()
		yunTrajEdit_Globals = undefined
		DestroyDialog yunTrajedit_rollout

		gc()  ---内存管理
		yunTrajEdit_Globals.UpdateBitmaps()
		
	)
	---关于按钮功能
	on btn_About pressed do
	(
		messagebox \"DtraijEdit 2.07    轨迹插件重写版\nEricDLegare.com\nProgramming:Eric D Legare   /   东见云\nIcons：Simon Dubuc\n---------联系方式-----------\nyun7928903@163.com
		\"

	)
	------切换界面大小
	on btn_DisplayAll pressed do
	(
		yunTrajEdit_Globals.ToggleDisplayAll()
	)
	on btn_New_Pivot pressed do yunTrajEdit_Globals.NewTraj true
	
	
	
	"
	----加轨迹后新建的界面
	local vSpacing = 34

	if yunTrajEdit_DTrajs.count > 0 do
	(
		yunTrajEdit_CheckExsitError()
		for i = yunTrajEdit_DTrajs.count to 1 by -1 do
		(
			if IsValidNode yunTrajEdit_DTrajs[i] do   ----真实存在
			(
				
				---帧范位置控制
				local vStartPos = ([202,44+(vSpacing*(i-1))] as string) 
				local vEndPos = ([202,61+(vSpacing*(i-1))] as string)  	
			
				local vDotCol = ([89,61+(vSpacing*(i-1))] as string) 
					
				--修改！！！！！！
				local vtimeFB = ([39,61+(vSpacing*(i-1))] as string) 	
				local vtimeFBOnOff = ([3,61+(vSpacing*(i-1))] as string)

				
				-----------------
					
				local vSplineCol = ([104,61+(vSpacing*(i-1))] as string) 
				local vMovePos = ([124,61+(vSpacing*(i-1))] as string) 
				local vDotPos = ([140,61+(vSpacing*(i-1))] as string) 
				local vDisplayPos = ([156,61+(vSpacing*(i-1))] as string) 
				local vDeletePos = ([172,61+(vSpacing*(i-1))] as string) 
				local vRangePos = ([188,61+(vSpacing*(i-1))] as string) 
											
						
					
				---标头
				local vNamePos = ([-3,44+(vSpacing*(i-1))] as string)				
				szExecute += ("edittext edt_Name" + (i as string) + " \"\" pos:" + vNamePos + " width:206 height:16 text:\"" + yunTrajEdit_DTrajs[i].name + "\"\n")						
				szExecute += ("on edt_Name" + (i as string) + " entered val do yunTrajEdit_DTrajs[" + (i as string) + "].name val\n")	
				szExecute += "\n"	
				---轨迹长度范围	
				szExecute += ("spinner spn_Start" + (i as string) + " \"\" pos:" + vStartPos + " width:52 height:16 type:#integer range:[-99999,99999," + (((animationRange.start as string) as integer) as string) +"]\n")
				szExecute += ("spinner spn_End" +   (i as string) + " \"\" pos:" + vEndPos +   " width:52 height:16 type:#integer range:[-99999,99999," + (((animationRange.end   as string) as integer) as string) +"]\n")
				szExecute += ("on spn_Start" + (i as string) + " changed val do 
				(
					if (spn_End" + (i as string) + ".value - 1) <= val then spn_End" + (i as string) + ".value = (val + 2)
					yunTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked = false
					yunTrajEdit_DTrajs_timeLong["+ (i as string)+"] = false
				)\n")
				
				szExecute += ("on spn_End" + (i as string) + " changed val do 
				(
					if (spn_Start" + (i as string) + ".value + 1) >= val then spn_Start" + (i as string) + ".value = (val - 2)
					yunTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked = false
					yunTrajEdit_DTrajs_timeLong["+ (i as string)+"] = false
				)\n")
				szExecute += "\n"
				
				----填充当前时间到帧范围
				szExecute += ("button btn_Range" + (i as string) + " \"\" pos:" + vRangePos + " width:16 height:16 images:#(yunTrajEdit_Globals.bmp_Range, undefined, 1, 1, 1, 1, 1)  tooltip:\"Reset the RANGE to the Active Time Segment\"\n")
				szExecute += ("on btn_Range" + (i as string) + " pressed do ( spn_Start" + (i as string)+".value=((animationRange.start as string) as integer);spn_End" + (i as string)+".value=((animationRange.end as string) as integer))\n")

				----删除轨迹
				szExecute += ("button btn_Delete" + (i as string) + " \"\" pos:" + vDeletePos + " width:16 height:16 images:#(yunTrajEdit_Globals.bmp_Delete, undefined, 1, 1, 1, 1, 1)  tooltip:\"DELETE Trajectory\" \n")
				szExecute += ("on btn_Delete" + (i as string) + " pressed do yunTrajEdit_Globals.DeleteTraj " + (i as string) + " \n")
				szExecute += "\n"

				----隐藏轨迹
				szExecute += ("button btn_Display" + (i as string) + " \"\" pos:" + vDisplayPos + " width:16 height:16  tooltip:\"隐藏轨迹\" \n")
				szExecute += ("on btn_Display" + (i as string) + " pressed do yunTrajEdit_Globals.ToggleDisplay " + (i as string)+"  \n")
				szExecute += "\n"
				
				----隐藏点标
				szExecute += ("button btn_Dot" + (i as string) + " \"\" pos:" + vDotPos + " width:16 height:16 tooltip:\"隐藏点标记\" \n")
				szExecute += ("on btn_Dot" + (i as string) + " pressed do yunTrajEdit_Globals.ToggleDot " + (i as string)+"  \n")
				szExecute += "\n"
				
				----经过后颜色
				szExecute += ("colorpicker col_Spline" + (i as string) + " \"\" pos:" + vSplineCol + " width:20 height:16 color:" + "green" +" title:\"Trajectory\" \n")
				szExecute += "\n"
				
				----经过前颜色	
				szExecute += ("colorpicker col_Dot" + (i as string) + " \"\" pos:" + vDotCol + " width:20 height:16 color:" + "red" + " title:\"Spacing Dots\" \n")
				szExecute += "\n"
				
				-- 修改添加帧范围选项
				szExecute += ("spinner time_FB" + (i as string) + " \"\" pos:" + vtimeFB + " width:52 height:16 type:#integer range:[1,999,10]\n")					
				szExecute += ("on time_FB" + (i as string) + " changed val do (
				yunTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked = true
				yunTrajEdit_DTrajs_timeLong["+ (i as string)+"] = yunTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked 
				yun_refreshDT_byTime_new_fn()
				) \n")					
					
				szExecute += ("checkbox time_FBONOff" + (i as string) + " \"\" pos:" + vtimeFBOnOff + " width:16 height:16 checked:" + (yunTrajEdit_DTrajs_timeLong[i] as string)+ "  tooltip:\"开关是否实时刷新轨迹长度\" \n")
				szExecute += ("on time_FBONOff" + (i as string) + " changed theState do (
				
				yunTrajEdit_DTrajs_timeLong["+ (i as string)+"] = theState
				if theState do 
				(	try (yun_refreshDT_byTime_new_fn())	 catch ())
				)\n")
				szExecute += "\n"
				----------
				
				----移动轨迹
				szExecute += ("button btn_Move" + (i as string) + " \"\" pos:" + vMovePos + " width:16 height:16 images:#(yunTrajEdit_Globals.bmp_Move, undefined, 1, 1, 1, 1, 1)  tooltip:\"偏移功能待添加\" \n")
				szExecute += "\n"
				-------根据当前帧实时刷新帧范围

				
				szExecute += "\n"
				
				
			)
		)
		
	)
	szExecute += ")"


	local vOriginalPos = if yunTrajedit_rollout != undefined  then (GetDialogPos yunTrajedit_rollout) else [0,0]
	
	
	----尝试关闭界面
	try DestroyDialog  yunTrajedit_rollout catch ()
	
	
	Execute szExecute
	
	
	if vOriginalPos != [0,0] then
		(	createDialog  yunTrajedit_rollout 205 (43 + (yunTrajEdit_DTrajs.count * vSpacing)) pos:vOriginalPos style:#(#style_border) bitmap:yunTrajEdit_Globals.bmp_Background bmpstyle:#bmp_tile fgcolor:green	)
	else
		(	createDialog  yunTrajedit_rollout 205 (43 + (yunTrajEdit_DTrajs.count * vSpacing)) style:#(#style_border) bitmap:yunTrajEdit_Globals.bmp_Background bmpstyle:#bmp_tile fgcolor:green )
	
			
	----轨迹和点标处理
	if yunTrajEdit_DTrajs.count > 0 do
	(
		
		for i = yunTrajEdit_DTrajs.count to 1 by -1 do
		(
			try
			(					
				if  yunTrajEdit_DTrajs_dot[i]  then
				(
					execute ("yunTrajEdit_Rollout.btn_Dot" + i as string + ".images = #(yunTrajEdit_Globals.bmp_Dot, undefined, 1, 1, 1, 1, 1)")
					
				)
				else
				(
					execute ("yunTrajEdit_Rollout.btn_Dot" + i as string + ".images = #(yunTrajEdit_Globals.bmp_Dot_ON, undefined, 1, 1, 1, 1, 1)")
				)
			)			
			catch()			
			try
			(					
				if yunTrajEdit_DTrajs_vis[i]  then
				(
					execute ("yunTrajEdit_Rollout.btn_Display" + i as string + ".images = #(yunTrajEdit_Globals.bmp_Display, undefined, 1, 1, 1, 1, 1)")
				)
				else
				(
					execute ("yunTrajEdit_Rollout.btn_Display" + i as string + ".images = #(yunTrajEdit_Globals.bmp_Display_ON, undefined, 1, 1, 1, 1, 1)")
				)
			)			
			catch()
		)
	)
	----------图标处理结束-----
	

-- 	setDialogPos yunTrajedit_rollout [247,225]
			
-- 	return szExecute
)

yunTrajEdit_UpdateRollout()

)
