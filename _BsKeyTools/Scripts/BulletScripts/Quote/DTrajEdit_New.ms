-- 名称：轨迹插件终极版重置版
-- 作者:东见云
-- 版本：v1.0
-- 3dsmax：2014+
-- 功能：动画轨迹
-- 联系方式：yun7928903@163.com

i=1
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

-----播放开关用
global yunTrajEdit_DTrajs_play
if yunTrajEdit_DTrajs_play == undefined do yunTrajEdit_DTrajs_play = #()


-----关键帧显隐用
global yunTrajEdit_DTrajs_keyVis
if yunTrajEdit_DTrajs_keyVis == undefined do yunTrajEdit_DTrajs_keyVis = #()


-----开始颜色用
global yunTrajEdit_DTrajs_colStart
if yunTrajEdit_DTrajs_colStart == undefined do yunTrajEdit_DTrajs_colStart = #()


-----结束颜色用
global yunTrajEdit_DTrajs_colEnd
if yunTrajEdit_DTrajs_colEnd == undefined do yunTrajEdit_DTrajs_colEnd = #()

-----渐变颜色开关用
global yunTrajEdit_DTrajs_isGradual
if yunTrajEdit_DTrajs_isGradual == undefined do yunTrajEdit_DTrajs_isGradual = #()
 


----获取选择的帧
selKeyArray = #()  ---初始化不可少
fn getAnimProp_yunEdit obj =
(   
try 
(
	local keytest  = #()
	if classof obj != SubAnim then
	( selKeyArray = #() )
	if classof obj ==Biped_Object  then
	(	
		if (obj.controller != undefined) do
		(
			cs_Bone =  (for o in objects where classOf o == Biped_Object  OR (try(classOf o.transform.controller == BipSlave_Control)catch(false)) collect o)	
			if obj.name==(cs_Bone[1].controller.rootName) then 				
			(
				for k in obj.controller[1].keys do	(appendIfUnique  selKeyArray k.time)
				for k in obj.controller[2].keys do	(appendIfUnique  selKeyArray k.time)
				for k in obj.controller[3].keys do	(appendIfUnique  selKeyArray k.time)			
			)
			else if (keyTest = obj.controller.keys) != undefined and keyTest.count > 0 do
			(
				keytest = obj.controller.keys
				for k in 1 to keyTest.count  do ( appendIfUnique  selKeyArray keytest[k].time )
			)
		)
	)
	---非bip物体
	else 
	(
		--迭代至最底层
		if obj.numSubs > 0 then ( for i = 1 to obj.numSubs do ( getAnimProp_yunEdit obj[i] ) )
		---最底层
		else
		(
			if (obj.controller != undefined) do
			(	
				keytest = obj.keys	
				if keyTest!= undefined and keyTest.count > 0 do
				(	for k in 1 to keyTest.count  do ( appendIfUnique  selKeyArray keytest[k].time )) 
			)
		)
	)	
	
		sort selKeyArray
		makeUniqueArray  selKeyArray
)
catch()

	return selKeyArray	
)


fn HSV_to_RGB hsv = 
(
	hsv /= 255
	h = hsv.x*6
	i = h as integer
	k = if (mod i 2) == 1 then (h-i) else (1-h+i)
	m = hsv.z*(1-hsv.y)
	n = hsv.z*(1-hsv.y*k)
	case i of
	(
			1: [n, hsv.z, m]*255
			2: [m, hsv.z, n]*255
			3: [m, n, hsv.z]*255
			4: [n, m, hsv.z]*255
			5: [hsv.z, m, n]*255
	  default: [hsv.z, n, m]*255
	)
)
----场景内物体是否存在检查函数
function yunTrajEdit_CheckExsitError  = 
(
	for i in  yunTrajEdit_DTrajs do 
	(	
		if (isvalidnode i)==false do 
		(
			yunTrajEdit_DTrajs = #()
			yunTrajEdit_DTrajs_dot = #()
			yunTrajEdit_DTrajs_vis = #()
			yunTrajEdit_DTrajs_timeLong = #()
			yunTrajEdit_DTrajs_play = #()
			yunTrajEdit_DTrajs_keyVis = #()
			yunTrajEdit_DTrajs_colStart = #()
			yunTrajEdit_DTrajs_colEnd = #()
			yunTrajEdit_DTrajs_isGradual = #()

		)
	)
)
yunTrajEdit_CheckExsitError()

---如果有不相等就都归零
if yunTrajEdit_DTrajs.count!=yunTrajEdit_DTrajs_dot.count or
yunTrajEdit_DTrajs_dot.count!=yunTrajEdit_DTrajs_vis.count or 
yunTrajEdit_DTrajs_vis.count!=yunTrajEdit_DTrajs_timeLong.count or 
yunTrajEdit_DTrajs_timeLong.count!=yunTrajEdit_DTrajs_play.count or 
yunTrajEdit_DTrajs_play.count!=yunTrajEdit_DTrajs_keyVis.count or 
yunTrajEdit_DTrajs_keyVis.count!=yunTrajEdit_DTrajs_colStart.count or 
yunTrajEdit_DTrajs_colStart.count!=yunTrajEdit_DTrajs_colEnd.count or 
yunTrajEdit_DTrajs_colEnd.count!=yunTrajEdit_DTrajs_isGradual.count do

(
	yunTrajEdit_DTrajs = #()
	yunTrajEdit_DTrajs_dot = #()
	yunTrajEdit_DTrajs_vis = #()
	yunTrajEdit_DTrajs_timeLong = #()
	yunTrajEdit_DTrajs_play =  #()
	yunTrajEdit_DTrajs_keyVis = #()
	yunTrajEdit_DTrajs_colStart = #()
	yunTrajEdit_DTrajs_colEnd = #()
	yunTrajEdit_DTrajs_isGradual = #()

)

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
				yunTrajedit_rollout.width = 37+40
				yunTrajedit_rollout.height = 40
			)
		)
		catch()
	),
	----新建轨迹
	function NewTraj _bPivot =
	(			
		local nParent	
		----分类型用的暂时无用
		if _bPivot do
		(
			---检查是否选择了一个物体
			if selection.count == 1 then   
			(
				nParent = selection[1]
			)				
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
			append yunTrajEdit_DTrajs_timeLong true
			append yunTrajEdit_DTrajs_play false
			append yunTrajEdit_DTrajs_keyVis true				
			append yunTrajEdit_DTrajs_colStart red
			append yunTrajEdit_DTrajs_colEnd green				
			append yunTrajEdit_DTrajs_isGradual true
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
			deleteItem yunTrajEdit_DTrajs_play  _i 
			deleteItem yunTrajEdit_DTrajs_keyVis  _i 
			deleteItem yunTrajEdit_DTrajs_colStart  _i 
			deleteItem yunTrajEdit_DTrajs_colEnd  _i 
			deleteItem yunTrajEdit_DTrajs_isGradual  _i 
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
	),
	---切换关键帧显隐
	function ToggleKeyVis  _i =
	(
		try
		(					
			if (not yunTrajEdit_DTrajs_keyVis[_i]) then
			(
				execute ("yunTrajEdit_Rollout.btn_Move" + _i as string + ".images = #(yunTrajEdit_Globals.bmp_Move, undefined, 1, 1, 1, 1, 1)")
				yunTrajEdit_DTrajs_keyVis[_i] = true
			)
			else
			(
				execute ("yunTrajEdit_Rollout.btn_Move" + _i as string + ".images = #(yunTrajEdit_Globals.bmp_Move, undefined, 4, 1, 1, 1, 1)")
				yunTrajEdit_DTrajs_keyVis[_i] = false
			)
		)			
		catch()
	)	
)


------生成轨迹函数  物体 显示 开点 开始色 结束色 开始帧数 结束帧数 点形状 播放是否显示 关键帧开关 是否颜色渐变
fn yunMotionPathCallBackFn  obj vis isdot col_Start  col_End tStart tEnd dotShape isPlay keyVis isGradual =
(
	--是否播放
	playCheck = true  --默认画曲线
	if isPlay and isAnimPlaying() then (playCheck = false )  ---隐藏被勾选切在播放就不画了
	
	--if vis and  not isAnimPlaying()  do
	---画轨迹
	if vis and   playCheck  do
	if vis   do
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
			arrColorA_reverse = #()
			
			if isGradual then		--渐变
			(
				rd = col_Start.red/framesA.count  
				gd = col_Start.green /framesA.count
				bd = col_Start.blue /framesA.count
				ad = 255/framesA.count
				for vT = 1 to  framesA.count do 
				(
					at time  framesA[vT](append arrA  obj.transform.pos)
					col = (color (col_Start.red - rd*vT ) (col_Start.green - gd*vT ) (col_Start.blue - bd*vT ) )				
					col.alpha = (col_Start.alpha - ad*vT )
					col.alpha = 255
					append arrColorA   col			
				)	
				
				arrColorA_reverse = for i = arrColorA.count to 1 by -1 collect arrColorA[i]
			)
			else
			(
				for vT in framesA do (at time  vT (append arrA  obj.transform.pos;append arrColorA_reverse col_Start ))
			)			
			----------------------------------------------------
			arrB = #()
			arrColorB = #()
			
			if isGradual then		--渐变
			(
				rd = col_End.red/framesB.count  
				gd = col_End.green /framesB.count
				bd = col_End.blue /framesB.count				
				for vT = 1 to  framesB.count do 
				(
					at time  framesB[vT]	(append arrB  obj.transform.pos	)
					append arrColorB  (color (col_End.red - rd*vT ) (col_End.green - gd*vT ) (col_End.blue - bd*vT ))	
				)
			)
			else
			(
				for vT in framesB do (at time  vT	(append arrB  obj.transform.pos;append arrColorB col_End)	)			
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
					(dotShape=="hollowBox"): gw.wMarker arrA[i] #hollowBox color:arrColorA_reverse[i]
					(dotShape=="plusSign"): gw.wMarker arrA[i] #plusSign color:arrColorA_reverse[i]
					(dotShape=="asterisk"): gw.wMarker arrA[i] #asterisk color:arrColorA_reverse[i]
					(dotShape=="xMarker"): gw.wMarker arrA[i] #xMarker color:arrColorA_reverse[i]
					(dotShape=="bigBox"): gw.wMarker arrA[i] #bigBox color:arrColorA_reverse[i]
					(dotShape=="circle"): gw.wMarker arrA[i] #circle color:arrColorA_reverse[i]
					(dotShape=="triangle"): gw.wMarker arrA[i] #triangle color:arrColorA_reverse[i]
					(dotShape=="diamond"): gw.wMarker arrA[i] #diamond color:arrColorA_reverse[i]
					(dotShape=="smallHollowBox"): gw.wMarker arrA[i] #smallHollowBox color:arrColorA_reverse[i]
					(dotShape=="smallCircle"): gw.wMarker arrA[i] #smallCircle color:arrColorA_reverse[i]
					(dotShape=="smallTriangle"): gw.wMarker arrA[i] #smallTriangle color:arrColorA_reverse[i]
					default: gw.wMarker arrA[i] #smallDiamond       color:arrColorA_reverse[i]
				)
			)
			else (gw.wMarker arrA[i] #point  color:arrColorA_reverse[i])
		)
		gw.wPolyline arrA false  rgb:arrColorA_reverse	
		
		----生成后半段
		for i = 1 to arrB.count do
		(
			arrB[i] = gw.wTransPoint arrB[i] 
			if isdot then 
			( 
				case of
				(
					(dotShape=="hollowBox"): gw.wMarker arrB[i] #hollowBox  color:arrColorB[i] 
					(dotShape=="plusSign"): gw.wMarker arrB[i] #plusSign color:arrColorB[i] 
					(dotShape=="asterisk"): gw.wMarker arrB[i] #asterisk color:arrColorB[i] 
					(dotShape=="xMarker"): gw.wMarker arrB[i] #xMarker color:arrColorB[i] 
					(dotShape=="bigBox"): gw.wMarker arrB[i] #bigBox 	color:arrColorB[i] 
					(dotShape=="circle"): gw.wMarker arrB[i] #circle color:arrColorB[i] 
					(dotShape=="triangle"): gw.wMarker arrB[i] #triangle color:arrColorB[i] 
					(dotShape=="diamond"): gw.wMarker arrB[i] #diamond color:arrColorB[i] 
					(dotShape=="smallHollowBox"): gw.wMarker arrB[i] #smallHollowBox color:arrColorB[i] 
					(dotShape=="smallCircle"): gw.wMarker arrB[i] #smallCircle color:arrColorB[i] 
					(dotShape=="smallTriangle"): gw.wMarker arrB[i] #smallTriangle color:arrColorB[i] 
					default: gw.wMarker arrB[i] #smallDiamond       color:arrColorB[i] 
				)
-- 				gw.wMarker arrB[i]  #hollowBox       color:col_End
			)	
			else(  	gw.wMarker arrB[i]  #point  color:arrColorB[i] )
		)
		gw.wPolyline arrB false  rgb:arrColorB
		
			
		---关键帧显示   obj = $
		if keyVis then	
		(
			keyArray = getAnimProp_yunEdit  obj			
			keyA_num = for i in keyArray where 
				( 
				((i as string )as integer )> tStart and 	((i as string )as integer )< tend 				
				)collect ((i as string )as integer)
			arrK = #()
			arrColorK = #()
			for vT in keyA_num do 
			(
			at time  vT 
				(				
					append arrK  obj.transform.pos
					append arrColorK white				
				)
			)	
			gw.setTransform (matrix3 1)	
			
			for i = 1 to arrK.count do
			(
				arrK[i] = gw.wTransPoint arrK[i] 
	 			--if isdot then 
				( 	
				gw.wtext  arrK[i] (keyA_num[i] as string) color:yellow		
				gw.wMarker arrK[i] #xMarker  color:white
				)	
				
			)
			--gw.wPolyline arrK false  rgb:arrColorK
		)
		
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
		

		-----检查结束开启轨迹   i = 1
		for i = yunTrajEdit_DTrajs.count to 1 by -1 do
		(			
			col_start = Execute ("yunTrajedit_rollout.col_Dot" + (i as string) + ".color")
			col_end = Execute ("yunTrajedit_rollout.col_Spline" + (i as string) + ".color")
			
			tStart = Execute ("yunTrajedit_rollout.spn_Start" + (i as string) + ".value")
			tEnd = Execute ("yunTrajedit_rollout.spn_End" + (i as string) + ".value")
			if yunTrajEdit_DTrajs_dot.count > 0 do ( isdot = yunTrajEdit_DTrajs_dot[i] )			
			if yunTrajEdit_DTrajs_vis.count > 0 do ( vis = yunTrajEdit_DTrajs_vis[i] )
			if yunTrajEdit_DTrajs_Play.count > 0 do ( isPlay = yunTrajEdit_DTrajs_Play[i] )
			if yunTrajEdit_DTrajs_keyVis.count> 0 do ( keyVis = yunTrajEdit_DTrajs_keyVis[i] )			
			if yunTrajEdit_DTrajs_isGradual.count> 0 do ( isGradual = yunTrajEdit_DTrajs_isGradual[i] )
			

			if yunTrajEdit_DTrajs[i] != undefined and
			col_start != undefined	and
			col_end != undefined and 
			tStart != undefined and 
			tEnd != undefined and
			vis != undefined and
			dotShape != undefined and
			isPlay != undefined and
			keyVis != undefined and
			isGradual != undefined and
			isdot != undefined do			
			(	
				----核心画轨迹代码
				try ((yunMotionPathCallBackFn   yunTrajEdit_DTrajs[i] vis  isdot col_start col_end tStart tEnd dotShape isPlay keyVis isGradual)) catch()
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
	button btn_DisplayAll \"\" pos:[1,4] width:34 height:34 tooltip:\"1，左键大小如意\n2，右键开关轨迹显示\n3，shift+左键开关实时更新轨迹长度\n（关闭则按时间轴长度显示）\n4，ctrl+左键开关显示关键帧数\n5,alt+左键开关颜色渐变\"
	---logo图标
	bitmap bmp_Titlebmp pos:[35,1] width:255 height:40 bitmap:yunTrajEdit_Globals.bmp_Title
	---关于按钮
	button btn_About \"\" pos:[152,4] width:34 height:34 images:#(yunTrajEdit_Globals.bmp_About, undefined, 1, 1, 1, 1, 1) tooltip:\"左键关于信息，右键随机轨迹颜色\"

	
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
		try (yun_refreshDT_byTime_new_fn())	 catch ()
		
	)
	--退出窗口功能
	on btn_Exit pressed do
	(
		try(unRegisterTimeCallback yun_refreshDT_byTime_new_fn)catch()
		try unregisterRedrawViewsCallback yunMotionPathCallBackFn_exc catch()
		yunTrajEdit_Globals.UpdateBitmaps()
		yunTrajEdit_Globals = undefined

		DestroyDialog yunTrajedit_rollout



		gc()  ---内存管理
		
		
	)
	---关于按钮功能
	on btn_About pressed do
	(
		messagebox \"DtraijEdit 2.07    轨迹插件重写版\nEricDLegare.com\nProgramming:Eric D Legare   /   东见云\nIcons：Simon Dubuc\n---------联系方式-----------\nyun7928903@163.com
		\"

	)
	on btn_About rightClick do
	(
		print \"随机颜色\"
		for i=1 to yunTrajEdit_DTrajs_colEnd.count do
		(
				bufferColorA = HSV_to_RGB [(random 0 255),(random 90 255),255] as color
				bufferColorB =  HSV_to_RGB [(random 0 255),(random 90 255),255]  as color
				execute (\"yunTrajedit_rollout.col_Dot\"+i as string+\".color = bufferColorA\")
				execute (\"yunTrajedit_rollout.col_Spline\"+i as string+\".color = bufferColorB\")
				yunTrajEdit_DTrajs_colStart[i] = bufferColorB
				yunTrajEdit_DTrajs_colEnd[i] = bufferColorB
		)		
	)
	------切换界面大小
	on btn_DisplayAll pressed do
	(
		if keyboard.shiftPressed then
		(
		    i=1
			for i = 1 to 	yunTrajEdit_DTrajs_timeLong.count do 
			(
				yunTrajEdit_DTrajs_timeLong[i] = not yunTrajEdit_DTrajs_timeLong[i]
				execute (\"yunTrajedit_rollout.time_FBONOff\"+(i as string)+\".state = yunTrajEdit_DTrajs_timeLong[i]\")
				if not yunTrajEdit_DTrajs_timeLong[i] then
				(execute (\"yunTrajedit_rollout.btn_Range\"+(i as string)+\".pressed()\"))
				try (yun_refreshDT_byTime_new_fn())	 catch ()
			)
		
		)
		else if  keyboard.controlPressed then
		(
			for i = 1 to 	yunTrajEdit_DTrajs_timeLong.count do 
			(
				(execute (\"yunTrajedit_rollout.btn_Move\"+(i as string)+\".pressed()\"))
				try (yun_refreshDT_byTime_new_fn())	 catch ()
			)
		)
		else if  keyboard.altPressed then
		(
			for i = 1 to 	yunTrajEdit_DTrajs_timeLong.count do 
			(
				
				execute (\"yunTrajedit_rollout.isGradual\"+(i as string)+\".checked = not yunTrajedit_rollout.isGradual\"+(i as string)+\".checked\")
				execute (\"yunTrajEdit_DTrajs_isGradual[\"+(i as string)+\"] = yunTrajedit_rollout.isGradual\"+(i as string)+\".checked\")
				try (yun_refreshDT_byTime_new_fn())	 catch ()
			)
		)
		else (yunTrajEdit_Globals.ToggleDisplayAll())
	)
	
	on btn_DisplayAll rightClick do
	(
		for i = 1 to 	yunTrajEdit_DTrajs_vis.count do (yunTrajEdit_Globals.ToggleDisplay  i)
	)
	
	
	on btn_New_Pivot pressed do (yunTrajEdit_Globals.NewTraj true;yun_refreshDT_byTime_new_fn())
	
	
	
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
				local vtimeFB = ([52,61+(vSpacing*(i-1))] as string) 	
				local vtimeFBOnOff = ([2,61+(vSpacing*(i-1))] as string)
				---播放复选框位置
				local vplayFBOnOff = ([19,61+(vSpacing*(i-1))] as string)

				
				-----------------
				local vColGradual = ([36,61+(vSpacing*(i-1))] as string) 
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
				szExecute += ("colorpicker col_Spline" + (i as string) + " \"\" pos:" + vSplineCol + " width:20 height:16 color:" + "yunTrajEdit_DTrajs_colStart[" + (i as string)+"]" +" title:\"Trajectory\" \n")
				szExecute += ("on col_Spline" + (i as string) + " changed new_col do (yunTrajEdit_DTrajs_colStart[" + (i as string)+"] =  new_col)")				
				szExecute += "\n"
				
				----经过前颜色	
				szExecute += ("colorpicker col_Dot" + (i as string) + " \"\" pos:" + vDotCol + " width:20 height:16 color:" + "yunTrajEdit_DTrajs_colEnd[" + (i as string)+"]" + " title:\"Spacing Dots\" \n")
				szExecute += ("on col_Dot" + (i as string) + " changed new_col do (yunTrajEdit_DTrajs_colEnd[" + (i as string)+"] =  new_col)")	
				szExecute += "\n"
				
				----是否启用颜色渐变  i =1 
				szExecute += ("checkbox isGradual" + (i as string) + " \"\" pos:" + vColGradual + " width:16 height:16 checked:" + (yunTrajEdit_DTrajs_isGradual[i] as string)+ "  tooltip:\"开关颜色渐变\" \n")

				szExecute +=  ("on isGradual" + (i as string) + " changed theState do (				
				yunTrajEdit_DTrajs_isGradual["+ (i as string)+"] = theState
				if theState do 
				(	try (yun_refreshDT_byTime_new_fn())	 catch ())
				)\n")
				
				szExecute += "\n"
				
				-- 修改添加帧范围选项
				szExecute += ("spinner time_FB" + (i as string) + " \"\" pos:" + vtimeFB + " width:42 height:16 type:#integer range:[1,999,20]\n")					
				szExecute += ("on time_FB" + (i as string) + " changed val do (
				yunTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked = true
				yunTrajEdit_DTrajs_timeLong["+ (i as string)+"] = yunTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked 
				yun_refreshDT_byTime_new_fn()
				) \n")					
					
				szExecute += ("checkbox time_FBONOff" + (i as string) + " \"\" pos:" + vtimeFBOnOff + " width:16 height:16 checked:" + (yunTrajEdit_DTrajs_timeLong[i] as string)+ "  tooltip:\"开关实时刷新轨迹长度\" \n")
				szExecute += ("on time_FBONOff" + (i as string) + " changed theState do (				
				yunTrajEdit_DTrajs_timeLong["+ (i as string)+"] = theState
				if theState do 
				(	try (yun_refreshDT_byTime_new_fn())	 catch ())
				)\n")
				
				----是否在播放是隐藏  i =1 
				szExecute += ("checkbox play_FBONOff" + (i as string) + " \"\" pos:" + vplayFBOnOff + " width:16 height:16 checked:" + (yunTrajEdit_DTrajs_play[i] as string)+ "  tooltip:\"开关在播放时隐藏已保证帧率\" \n")
				szExecute += ("on play_FBONOff" + (i as string) + " changed theState do (				
				yunTrajEdit_DTrajs_play["+ (i as string)+"] = theState			
				)\n")
				szExecute += "\n"
				----------
				
				----修改为关键帧开关 (原先移动移动轨迹)
				szExecute += ("button btn_Move" + (i as string) + " \"\" pos:" + vMovePos + " width:16 height:16 images:#(yunTrajEdit_Globals.bmp_Move, undefined, 1, 1, 1, 1, 1)  tooltip:\"是否显示关键帧数\" \n")
				
				szExecute += ("on btn_Move" + (i as string) + " pressed do yunTrajEdit_Globals.ToggleKeyVis " + (i as string)+"  \n")
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
