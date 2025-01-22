--Maxscript
--author:Joe
--E-Mail:738746223@qq.com
--99U:199505

try(destroyDialog copy_mirror_transform)catch()
rollout copy_mirror_transform "动画镜像工具3.3" width:280 height:340
(
	group "设置镜像轴：(轴对象的局部坐标系)" (
				radiobuttons radioAxis ""  labels:#("X", "XY", "Y", "YZ", "Z", "ZX") columns:2 align:#left across:2 --align:#left
				radiobuttons mirrorFlip "翻转"  labels:#("Y", "Z","X") default:1 align:#right --offset:[-20,-68] --columns:2

				radiobuttons mirror_type "" labels:#("动画", "姿势") default:2

				--label lab_01 "" --占位
		)

	group "对称轴对象 默认为原点" (
				button bt_Axis "拾取"  width:215 height:30 tooltip:"设置为选中对象" align:#cneter --offset:[0,1]

	)

	group "动画" (

				button bt_copy_select_A "复制"  width:106 height:24 toolTip:"复制选中控制器动画" across:2 align:#left
				button bt_mirror_select_A "黏贴"  width:106 height:24 toolTip:"镜像黏贴动画" align:#right


				label lab_02 "建议满帧复制镜像"
	)
	group ""
	(
		button btn_self "自我镜像"  width:215 height:24
		button btn_reset_sel "还原选择对象动画"  width:105 height:24 across:2 align:#left
		button btn_dele "清除所有帮助物体" width:105 height:24 align:#right
	)

	HyperLink lbl_01 "帮助" address:"https://sundaybox.cc/pages/062dc1/"  align:#center
	-----------------------------------------------------------------------------
	local AxisNode,copy_form,paste_to
	-----------------------------------------------------------------------------
	fn mirrorMatrixFn
				--axis:"x"  --Axis to mirror over
				--flip:"z"  --Axis to flip
				tm:(matrix3 1)  --Matrix to mirror
				pivotTm:(matrix3 1) --Matrix to mirror around
	=
	(
			fn FetchReflection_flip axis_ =
			(

				case axis_ of (

				3: [-1,1,1]  -- x    reflect in YZ plane
				2: [1,-1,1]  -- y    in ZX plane
				1: [1,1,-1]  -- z    in XY plane
				)

			)
		 fn FetchReflection a =
		 (

				_axis = [1,1,1]
				if  (a <= 2 or a == 6 ) do  _axis.x = (-1)
				if  (a >= 2 and a<= 4 ) do _axis.y = (-1)
				if (a >= 4 ) do _axis.z = (-1)
				return _axis
		 )
		aReflection = scalematrix (FetchReflection radioAxis.state)


		fReflection = scalematrix (FetchReflection_flip mirrorFlip.state)

		fReflection * (tm * (inverse pivotTm)) * aReflection * pivotTm

	)
	fn getkeys_array a_ =
	(
		local Keys_arrays = #()
		pos_time = for i in a_.pos.controller.keys collect i.time ;join Keys_arrays pos_time
		rotation_time = for i in a_.rotation.controller.keys collect i.time ;join Keys_arrays rotation_time
		scale_time = for i in a_.scale.controller.keys collect i.time ;join Keys_arrays scale_time
		Keys_arrays = makeUniqueArray Keys_arrays
		Keys_arrays
	)
	fn sethelp args  =
	(
		local temp_p = undefined
		local thefind = findString args.name "Mirr_help"
		if thefind == undefined then
		(
			local thekeys = getkeys_array args
			temp_p = getNodeByName ( "Mirr_help_"+ args.name)

			if not (isValidNode temp_p ) do (
				temp_p = point name:( "Mirr_help_"+ args.name)
			)
			animate on
			(
					for t in thekeys do
					(
							at time t (temp_p.transform = args.transform )
					)
			)
			setTransformLockFlags temp_p #{1,2,3,4,5,6,7,8,9}
		)else(
			temp_p = args
		)
		temp_p
	)


	fn mirror_Three a_ b_ c_=
	(
		if b_ == undefined then (
			flippedTM = mirrorMatrixFn pivotTm:(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0]) tm:a_.transform
		)
		else(
			flippedTM = mirrorMatrixFn pivotTm:b_.transform tm:a_.transform
		)
		c_.transform = flippedTM
		--format "%\r\n" flippedTM
	)
	fn mirror_pose a_ b_ c_ =
	(
		animate on--off
		(
			mirror_Three a_ b_ c_
		)
	)
	fn mirror_anim a_ b_ c_ =
	(
			keys_array = getkeys_array a_
			animate on
			(
				for t in keys_array do
				(
					at time t (mirror_Three a_ b_ c_)
				)
			)
	)

	-----------------------------------------------------------------------------
			on bt_Axis pressed do--选择基准轴对象
			(
					if selection.count != 0 do
					(
							AxisNode = selection[1]
							bt_Axis.text = AxisNode.name
					)
			)
			on bt_copy_select_A pressed do --复制
			(
					if selection.count != 0 do
					(
							copy_form = selection as array
					)
			)
			on bt_mirror_select_A pressed do --黏贴
			(
					if selection.count != 0 do
					(
						if not(IsValidNode AxisNode) do (AxisNode = undefined ;bt_Axis.text = "原点")
							paste_to = selection as array

							/*local help_anim = #()
							for i in paste_to do
							(
								local temp_p = sethelp i
								append help_anim temp_p
							)*/
							if mirror_type.state == 1 then
							(
								undo "add mirror anim" on
								(
									for i=1 to copy_form.count do
									(
										try (
												mirror_anim copy_form[i] AxisNode paste_to[i]
												print(copy_form[i].name )
												print(paste_to[i].name )

											)catch(
												format " % 镜像黏贴 % 出错\r\n " copy_form[i].name  paste_to[i].name
												--messageBox "请重新复制"
											)
									)
								)
							)
							else
							(
								undo "add mirror pose" on
								(
									for i=1 to copy_form.count do
									(
										try (mirror_pose copy_form[i] AxisNode paste_to[i])catch(
											--messageBox "请重新复制"
											format " % 镜像黏贴 % 出错\r\n " copy_form[i].name  paste_to[i].name
										)
									)
								)

							)
					)
			)

		on btn_self pressed do
		(
			--先保存好动画
			local paste_to = selection as array
			local help_anim = #()
			for i in selection do
			(
				local temp_p = sethelp i
				append help_anim temp_p
			)
			if not(IsValidNode AxisNode) do (AxisNode = undefined ;bt_Axis.text = "原点")
							if mirror_type.state == 1 then
							(
								undo "add_mirror_01" on
								(
									for i=1 to help_anim.count do
									(
										try (
												mirror_anim help_anim[i] AxisNode paste_to[i]
											)catch(
												format " % 镜像黏贴 % 出错\r\n " help_anim[i].name  paste_to[i].name
											)
									)
								)
							)
							else
							(
								undo "add_mirror_02" on
								(
									for i=1 to help_anim.count do
									(
										try (mirror_pose help_anim[i] AxisNode paste_to[i])catch
										(
											format " % 镜像黏贴 % 出错\r\n " help_anim[i].name  paste_to[i].name
										)
									)
								)
							)
		)
		on btn_reset_sel pressed do
		(
			for i in selection do
			(
				local temp_p = getNodeByName ( "Mirr_help_"+ i.name)
				if isValidNode temp_p then
				(
					local keys_array = getkeys_array temp_p
					undo "add_mirror_03" on
					(
						animate on
						(
							for t in keys_array do
							(
								at time t (i.transform = temp_p.transform)
							)
						)
					)
				)else(
					format "没有发现动画备份对象: % \r\n " ( "Mirr_help_"+ i.name)
				)

			)
		)
		on btn_dele pressed do
		(
			local temp_p = #()
			for i in objects do
			(
				thefind = findString i.name "Mirr_help"
				if thefind != undefined do (
					append temp_p i
				)
			)try (delete temp_p)catch()
		)
)
createDialog copy_mirror_transform