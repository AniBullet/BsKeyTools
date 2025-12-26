/*
	BsFnKeys - 批量滑动帧切换工具 v2.0 (集成Z轴检查)
	
	功能：
	- 批量设置Biped手脚的关键帧类型（固定/滑动/自由）
	- 支持Z轴高度过滤，只处理低于阈值的关键帧
	- 自动IKFK：根据Z轴高度自动设置滑动/自由关键帧
	
	作者：Bullet.S
	优化：一方狂三
	日期：2019.05.28
*/

try(destroydialog rolFnKeys)catch()

rollout rolFnKeys "批量滑动帧切换 v2.0 (集成Z轴检查)" width:280 height:220
(
	group ""
	(
		checkbox chkLHand "左手" pos:[96,20]  width:50 height:20 color:Blue
		checkbox chkRHand "右手" pos:[24,20] width:50 height:20 color:Green
		checkbox chkLFoot "左脚" pos:[96,55]  width:50 height:20 color:Blue checked:true
		checkbox chkRFoot "右脚" pos:[24,55] width:50 height:20 color:Green checked:true
		button btnPlanted "固定关键帧" pos:[184,20] width:80 height:25 toolTip:"Set Planted Key"
		button btnSliding "滑动关键帧" pos:[184,50] width:80 height:25 toolTip:"Set Sliding Key"
		button btnFree "自由关键帧" pos:[184,80] width:80 height:25 toolTip:"Set Free Key"
		
		checkbox chkZFilter "启用Z轴过滤" pos:[24,92] width:120 height:20 checked:true color:Red
		spinner spnZThreshold "Z轴高度:" pos:[24,115] width:120 range:[0,1000,22] type:#float fieldWidth:50 scale:0.01
		button btnCheckZ "检查Z轴位移" pos:[184,110] width:80 height:25 toolTip:"Check Z Position"
		
		button btnAutoIKFK "自动IKFK" pos:[184,175] width:80 height:25 
		
		label lblInfo "脚部Z轴位移小于阈值的关键帧将被处理" pos:[24,140] width:240 height:16 color:Gray
		label lblMe "[2019.05.28]  Bullet.S" pos:[24,170] width:120 height:16 color:Green
		label lbl02 "自动IKFK：一方狂三" pos:[24,190] width:150 height:16 color:Green
	)
	
	-- Z轴位移检查函数
	Fn fnCheckZPosition = 
	(
		if selection.count == 0 then
		(
			return false
		)
				
		local minZ = 1000000.0  -- 初始化一个很大的值
		local hasValidZ = false
		
		for i = 1 to selection.count do
		(
			obj = selection[i]
			zPos = obj.transform.translation.z          
			-- 记录最小的Z轴位移值
			if zPos < minZ then
			(
				minZ = zPos
				hasValidZ = true
			)
		)
		
		-- 如果找到了有效的Z轴位移值，更新到阈值输入框
		if hasValidZ then
		(
			spnZThreshold.value = minZ
		)       
		return true
	)
	
	-- 检查指定脚部骨骼所有关键帧的Z轴位移并返回符合条件的关键帧数组
	Fn fnGetValidKeyframes legObj footName threshold = 
	(
		local validKeyframes = #()
		local k = numKeys legObj.controller
		
		-- 获取脚部骨骼对象
		local footObj = getNodeByName footName
		if footObj == undefined then
		(
			print ("错误: 找不到脚部骨骼 " + footName)
			return validKeyframes
		)
				
		for i=1 to k do
		(
			local t = (biped.getkey legObj.controller i).time
			-- 设置时间轴到关键帧
			slidertime = t
			-- 获取脚部骨骼在当前帧的Z轴位移
			local zPos = footObj.transform.translation.z
						
			if zPos < threshold then
			(
				append validKeyframes t
			)
			else
			(
				print ("  ? 超过阈值，将被跳过")
			)
		)
		return validKeyframes
	)
	
	-- 设置关键帧类型的主函数 (集成Z轴过滤)
	Fn fnSetKeyType keyType = 
	(
		sliderTime = animationRange.start
		for obj in selection where ((classof obj.baseObject == Biped_Object) \
		and (biped.getCurrentLayer obj.controller == 0)) do
		(
			bipCtrl = obj.controller
			
			-- 处理左手
			if chkLHand.checked then 
			(
				sel_obj1 = (biped.getNode bipCtrl #larm)
				k = numKeys sel_obj1.controller
				for i=1 to k do
				(
					t = (biped.getkey sel_obj1.controller i).time
					slidertime = t
					with animate on
					(
						case of
						(
							(keyType == 1):(biped.SetPlantedKey sel_obj1)
							(keyType == 2):(biped.SetSlidingKey sel_obj1)
							(keyType == 3):(biped.SetFreeKey sel_obj1)
						)
					)
				)
			)
			
			-- 处理右手
			if chkRHand.checked then 
			(
				sel_obj2 = (biped.getNode bipCtrl #rarm)
				k = numKeys sel_obj2.controller
				for i=1 to k do
				(
					t = (biped.getkey sel_obj2.controller i).time
					slidertime = t
					with animate on
					(
						case of
						(
							(keyType == 1):(biped.SetPlantedKey sel_obj2)
							(keyType == 2):(biped.SetSlidingKey sel_obj2)
							(keyType == 3):(biped.SetFreeKey sel_obj2)
						)
					)
				)
			)
			
			-- 处理左脚 (集成Z轴过滤)
			if chkLFoot.checked then 
			(
				sel_obj3 = (biped.getNode bipCtrl #lleg)
				
				-- 如果启用Z轴过滤，先获取符合条件的关键帧
				local keyframesToProcess = #()
				if chkZFilter.checked then
				(
					keyframesToProcess = fnGetValidKeyframes sel_obj3 "Bip001 L Foot" spnZThreshold.value
				)
				else
				(
					-- 如果不启用过滤，处理所有关键帧
					k = numKeys sel_obj3.controller
					for i=1 to k do
					(
						append keyframesToProcess (biped.getkey sel_obj3.controller i).time
					)
				)
				
				-- 处理符合条件的关键帧
				for t in keyframesToProcess do
				(
					slidertime = t
					with animate on
					(
						case of
						(
							(keyType == 1):(biped.SetPlantedKey sel_obj3)
							(keyType == 2):(biped.SetSlidingKey sel_obj3)
							(keyType == 3):(biped.SetFreeKey sel_obj3)
						)
					)
				)
			)
			
			-- 处理右脚 (集成Z轴过滤)
			if chkRFoot.checked then 
			(
				sel_obj4 = (biped.getNode bipCtrl #rleg)
				
				-- 如果启用Z轴过滤，先获取符合条件的关键帧
				local keyframesToProcess = #()
				if chkZFilter.checked then
				(
					keyframesToProcess = fnGetValidKeyframes sel_obj4 "Bip001 R Foot" spnZThreshold.value
				)
				else
				(
					-- 如果不启用过滤，处理所有关键帧
					k = numKeys sel_obj4.controller
					for i=1 to k do
					(
						append keyframesToProcess (biped.getkey sel_obj4.controller i).time
					)
				)
				
				-- 处理符合条件的关键帧
				for t in keyframesToProcess do
				(
					slidertime = t
					with animate on
					(
						case of
						(
							(keyType == 1):(biped.SetPlantedKey sel_obj4)
							(keyType == 2):(biped.SetSlidingKey sel_obj4)
							(keyType == 3):(biped.SetFreeKey sel_obj4)
						)
					)
				)
			)
		)
	)
	
	-- 检查Biped关键帧Z轴高度的函数
	fn fnCheckBipedKeyframesZ = 
	(
		if selection.count == 0 then
		(
			print "请先选择Biped骨骼！"
			return false
		)
		
		print "========== 检查骨骼Z轴高度 =========="
		
		for obj in selection do
		(
			local keyCount = numKeys obj.controller
			print ("骨骼 '" + obj.name + "' 关键帧数量: " + (keyCount as string))
			
			for i = 1 to keyCount do
			(
				local t = getKeyTime obj.controller i
				sliderTime = t
				local zPos = obj.transform.translation.z
				print ("  帧 " + (t.frame as string) + ": Z轴高度 = " + (zPos as string))
			)
			print "----------"
		)
		
		return true
	)
	
	fn fnAutoIKFKByHeight thresholdHeight = 
	(
		if selection.count == 0 then
		(
			messageBox "请先选择Biped手部或脚部骨骼!" title:"提示"
			return false
		)
		
		print ("开始自动IKFK处理，阈值: " + (thresholdHeight as string))
		
		for obj in selection do
		(
			local keyCount = numKeys obj.controller
			print ("骨骼 '" + obj.name + "' 关键帧数量: " + (keyCount as string))
			
			for i = 1 to keyCount do
			(
				local t = getKeyTime obj.controller i
				sliderTime = t
				local zPos = obj.transform.translation.z
				
				print ("  帧 " + (t.frame as string) + ": Z轴高度 = " + (zPos as string) + ", 阈值 = " + (thresholdHeight as string))
				
				with animate on
				(
					if zPos <= thresholdHeight then
					(
						biped.setSlidingKey obj  -- 小于等于阈值：IK滑动关键帧
						print ("  -> 设置为滑动关键帧 (IK)")
					)
					else
					(
						biped.setFreeKey obj     -- 大于阈值：FK自由关键帧
						print ("  -> 设置为自由关键帧 (FK)")
					)
				)
			)
		)
		
		print "自动IKFK处理完成！"
		return true
	)

	on rolFnKeys open do
	(
		chkZFilter.checked = false
	)

	-- 按钮事件处理
	on btnPlanted pressed do
	(
		fnSetKeyType 1
	)
	
	on btnSliding pressed do
	(
		fnSetKeyType 2
	)
	
	on btnFree pressed do
	(
		fnSetKeyType 3
	)
	
	-- Z轴检查按钮事件
	on btnCheckZ pressed do
	(
		fnCheckZPosition()
	)
	
	on btnAutoIKFK pressed do
	(
		fnCheckBipedKeyframesZ()
		fnAutoIKFKByHeight spnZThreshold.value
	)
)

CreateDialog rolFnKeys

