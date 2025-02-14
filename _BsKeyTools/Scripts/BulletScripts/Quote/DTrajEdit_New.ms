-- coding: utf-8
(
	global BipFastAssembly = undefined
	--bip加速模块
	--不同版本autodest.max.dll的适配
	--大于max2010小于max2022、大于等于max2022，小于等于max2018  C#跑maxscript函数需要的形参不一样
	--max2016还有FPVlalue内存回收问题，需要转存FPVlalue
	if (maxVersion())[1] >= 21000 and  (maxVersion())[1] < 24000 then
	(
		strVersionDiff = "g.ExecuteMAXScriptScript(MXS_script, true, v, true);"
		strVersionDiff_deffer = "g.ExecuteMAXScriptScript(MXS_script, true, vv, true);"
		strVersionDiff_communicate = "g.ExecuteMAXScriptScript(MXS_script, true, null, true);"
		strVersionDiff_setNobipBones = "g.ExecuteMAXScriptScript(script, true, null, true);"
	)
	else if (maxVersion())[1] >= 24000  then
	(
		strVersionDiff = "g.ExecuteMAXScriptScript(MXS_script,0, true, v, true);"
		strVersionDiff_deffer = "g.ExecuteMAXScriptScript(MXS_script,0, true, vv, true);"
		strVersionDiff_communicate = "g.ExecuteMAXScriptScript(MXS_script,0, true, null, true);"
		strVersionDiff_setNobipBones = "g.ExecuteMAXScriptScript(script,0, true, null, true);"
	)
	else 
	(
		strVersionDiff = "g.ExecuteMAXScriptScript(MXS_script, true, v);"
		strVersionDiff_deffer = "g.ExecuteMAXScriptScript(MXS_script, true, vv);"
		strVersionDiff_communicate = "g.ExecuteMAXScriptScript(MXS_script, true, null);"
		strVersionDiff_setNobipBones = "g.ExecuteMAXScriptScript(script, true, null);"
	
	)
	--max2022开始弃用了 IBipMaster12改为" + bip_sdk_VarName+ " 
	if (maxVersion())[1] >= 24000  then
	(
		bip_sdk_Varclass = "IIBipDriver12"
		bip_sdk_VarName = "IBipDriver12"
		bip_sdk_GetFunction = "GetBipDriver12Interface"
	)
	else
	(
		bip_sdk_Varclass = "IIBipMaster12"
		bip_sdk_VarName = "IBipMaster12"
		bip_sdk_GetFunction = "GetBipMaster12Interface"
	)
	
	--max2016的单独处理,FPVlaue返回的Ntab里存的IInode在max2016中必须用IntPtr指针拿到
	if   (maxVersion())[1] == 18000  then 
	(
		global ValueFormMaxBackToC = "
					for (int i = 0; i < v.NTab.Count; i++)
					{ 
						IntPtr ptr = new IntPtr(i);
						bipedBones.Add(v.NTab[ptr]); 
					}"     
	)
	else
	(
		global ValueFormMaxBackToC = "
					for (int i = 0; i < v.NTab.Count; i++)
					{ bipedBones.Add(v.NTab[i]); }"
			 
	)
	
	
	global CSharpCodeSourceBipFast ="
    using System.Collections.Generic;
    using Autodesk.Max;
    using System.IO;
    using System.Threading.Tasks;
    using System;
	
	namespace bipedSetTM
	{
		public class SetTM_test
		{
			internal static readonly IGlobal g = GlobalInterface.Instance;
			internal static readonly IInterface13 ip = g.COREInterface13;
	
			//获取所有的bip
			public static List<IINode> GetBipAll()
			{
				string MXS_script = \"for o in objects where isKindOf o Biped_Object collect o\";
				List<IINode> bipedBones = new List<IINode>();
				IFPValue v = g.FPValue.Create();
				" + strVersionDiff + "
				" + ValueFormMaxBackToC + "
				return bipedBones.Count > 0 ? bipedBones : null;
			}
	
			public static " + bip_sdk_Varclass + " GetBipMaster(IINode inputBip)
			{
				try
				{
					" + bip_sdk_Varclass + " bipMaster = g." + bip_sdk_VarName+ "." + bip_sdk_GetFunction + "(inputBip.TMController);  
					return bipMaster;
				}
				catch
				{
					return null;
				}
			}
	   
			public static List<" + bip_sdk_Varclass + "> GetBipCOMAndMaster()
			{
				string MXS_script = \"for o in objects where isKindOf o Biped_Object collect o\";
				List<IINode> bipedBones = new List<IINode>();
				IFPValue v = g.FPValue.Create();
				" + strVersionDiff + "
				"+ ValueFormMaxBackToC +"
				
	
				if (bipedBones.Count == 0)
				{
					return null;
				}
				List<" + bip_sdk_Varclass + "> uniqueBipMasters = new List<" + bip_sdk_Varclass + ">();	
				foreach (IINode node in bipedBones)
				{
					" + bip_sdk_Varclass + " bipMaster = GetBipMaster(node);
					if (bipMaster != null)
					{
						bool isUnique = true;
						if (bipMaster != null && !uniqueBipMasters.Exists(existingBipMaster => existingBipMaster.RootName == bipMaster.RootName))
						{
							uniqueBipMasters.Add(bipMaster);
						}
					}
				}
				MXS_script = \"print \\\"\" +\"-->场景内有\" + uniqueBipMasters.Count.ToString() + \"套bip骨架\\\"\";				
				" + strVersionDiff_communicate + "				
				return uniqueBipMasters;
			}
	
			/*
			infileName暴力粘贴选择的要粘贴的动画
			pasteOffset 是帧偏移
			frame_arrayl是传入的帧数数组，根据逐帧和关键帧模式变化            
			loopTime是暴力粘贴精度熟悉，就是要粘贴几次
			AC模式传入前在frame_arraylmax里处理        
			*/
			public static string pastAnimationEveryFrame(string inFileName, int pasteOffset, string frame_arrayl, int loopTime)
			{
				if (!File.Exists(inFileName))
				{
					return \"姿势文件不存在: \" + inFileName;
				}
				List<IINode> allBip = GetBipAll();
				List<" + bip_sdk_Varclass + "> allBipCOM = GetBipCOMAndMaster();
				List<string> MXS_scripts_notBIP = new List<string>();
			
				//删除
				string MXS_script = \"\";
				char separator = '|';
				// 使用Split方法按照指定的分隔符分割字符串
				string[] parts = frame_arrayl.Split(separator);
				// 创建一个List<int>来存储转换后的整数
				List<int> intList = new List<int>();
				foreach (string part in parts)
				{
					// 检查分割后的元素是否为空
					if (!string.IsNullOrEmpty(part))
					{
						// 将非空字符串元素转换为整数并添加到列表中
						intList.Add(int.Parse(part));
					}
				}
				int[] intFrameArray = intList.ToArray();
	
				string[] allTexts = File.ReadAllLines(inFileName);
	
				//开启所有bip骨架的加速函数
				if (allBipCOM != null)
				{
					foreach (" + bip_sdk_Varclass + " bipMaster in allBipCOM)
					{
						bipMaster.StartSettingBipedKeys();
					}
				}
				
				for (int n = 0; n < intFrameArray.Length; n++)
				{
					int m = intFrameArray[n];
					if (ip.SelNodeCount < 1)
					{
						return  \"没有选中任何节点\";
					}
					for (int i = 0; i < ip.SelNodeCount; i++)
					{
						IINode node = ip.GetSelNode(i);
						IMatrix3 finalTM = g.Matrix3.Create();
						string targetString = \"<\" + (m + pasteOffset).ToString() + \"f>|\" + node.NodeName + \"|\";
						//读取行信息
						string str_line = FindLineContaining(allTexts, targetString);
						if (str_line == null)
						{ continue; }
						string[] partss = str_line.Split(separator);
						if (partss.Length <= 1) { continue; }
						string result = partss[partss.Length - 1];
						//去掉“ = ”                        
						result = result.Replace(\"=\", \"\");
	
						// 判断是maya还是max姿势
						string[] checkTM = result.Split('#');
						if (checkTM.Length > 1)
						{
							// maya记录的矩阵转化成max矩阵
							MXS_script = \"(\" + checkTM[1] + \" * (matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])  ) as string\";
							IFPValue vv = g.FPValue.Create();
							" + strVersionDiff_deffer + "
														
							result = vv.S;
						}
	
						MXS_script = \"at time \" + m.ToString() + \"f ($'\" + node.NodeName + \"'.transform = \" + result + \")\";
	
						int frame2tick = (m * g.TicksPerFrame);
						/////bip 骨骼                       
						if (allBip != null && allBip.Contains(node))
						{
							MXS_script = result;   //重载变量，不能删
							//字符转矩阵
							IFPValue v = g.FPValue.Create();
							" + strVersionDiff + "
							finalTM = v.M;
							if (finalTM == null) { continue; }
	
							" + bip_sdk_Varclass + " bipMasterEach = GetBipMaster(node);
							int id = 0;
							int link = 0;
							bool getBipBoneIdLink = bipMasterEach.GetIdLink(node, ref id, ref link);
							if (getBipBoneIdLink)
							{
								bipMasterEach.SetBipedTM(frame2tick, finalTM, id, link);
							}
						}
						//记录矩阵,not_BIP
						else
						{
							string MXS_script_notBIP = \"at time \" + m.ToString() + \"f ($'\" + node.NodeName + \"'.transform = \" + result + \")\";
							MXS_scripts_notBIP.Add(MXS_script_notBIP);
						}
					}
				}
				//关闭所有bip骨架的加速函数
				if (allBipCOM != null)
				{
					foreach (" + bip_sdk_Varclass + " bipMaster in allBipCOM)
					{
						bipMaster.StopSettingBipedKeys();
					}
				}
				//非bip物体吸附n边
				int currentLoop = 0;
				while (currentLoop <= loopTime)
				{
					foreach (string script in MXS_scripts_notBIP)
					{
						" + strVersionDiff_setNobipBones + "					
					}
					currentLoop++;
				}
				return \"粘贴完成\";
			}
	
			//并行
			static string FindLineContaining(string[] lines, string target)
			{
				object lockObject = new object();
				string foundLine = null;
				Parallel.For(1, lines.Length, (i, state) =>
				{
					if (lines[i].Contains(target))
					{
						lock (lockObject)
						{
							foundLine = lines[i];
							state.Stop();
						}
					}
				});
				return foundLine;
			}
		}
	}
	"
	try
	(
		CSharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		CompilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

		CompilerParams.ReferencedAssemblies.Add("System.dll")
		CompilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll")
		CompilerParams.ReferencedAssemblies.Add("System.IO.dll")
		CompilerParams.ReferencedAssemblies.Add("System.Threading.Tasks.dll")
		compilerParams.ReferencedAssemblies.Add((getdir #maxroot) + @"Autodesk.Max.dll");	
		CompilerParams.GenerateExecutable = false
		CompilerParams.GenerateInMemory = true

		CompilerResults = CSharpProvider.CompileAssemblyFromSource CompilerParams #(CSharpCodeSourceBipFast)
		WinAssembly = CompilerResults.CompiledAssembly
		BipFastAssembly =  WinAssembly.CreateInstance "bipedSetTM.SetTM_test"
		-- showMethods  BipFastAssembly
		-- BipFastAssembly.GetBipAll()	

	)
	catch(print ("动态编译失败！！无法使用快速粘贴功能"))

	----获取写入选择的帧	
	fn getAnimProp_yunEdit obj =(    ----获取选择的帧
		keytest  = #()
		if selKeyArray==undefined then(selKeyArray = #())	
		if obj!=undefined then
		(	
			if classof obj ==Biped_Object  then
			(
				
				if (obj.controller != undefined) do
				(	
					cs_Bone =  (for o in objects where classOf o == Biped_Object  OR (try(classOf o.transform.controller == BipSlave_Control)catch(false)) collect o)	
					bipeRoot = (getNodeByName cs_Bone[1].controller.rootName)	
					bipCtr = bipeRoot.controller  
					layerCount = biped.numLayers bipCtr				
					--layerCount>0有层的情况
					for i=0 to layerCount do(
						biped.setCurrentLayer bipCtr i
						if obj.name==(cs_Bone[1].controller.rootName) then 				
						(
							
							for k in obj.controller[1].keys do
							(appendIfUnique  selKeyArray k.time)
							for k in obj.controller[2].keys do
							(appendIfUnique  selKeyArray k.time)
							for k in obj.controller[3].keys do
							(appendIfUnique  selKeyArray k.time)
						
						)
						else if (keyTest = obj.controller.keys) != undefined and keyTest.count > 0 do
						(
							keytest = obj.controller.keys
							for k in 1 to keyTest.count  do (
								appendIfUnique  selKeyArray keytest[k].time
							)
						)
						
					) 
				)				
				
			)	
			else (
				if obj.numSubs > 0 then	(
					for i = 1 to obj.numSubs do(
						buffer = getAnimProp_yunEdit obj[i]
						join selKeyArray buffer
						makeUniqueArray  buffer
					)
				)		
				else		(			
					if (obj.controller != undefined) do	(
						if (keyTest = obj.keys) != undefined and keyTest.count > 0 do
						(
							keytest = obj.keys
							--print ("<-----"+ obj as string)
							for k in 1 to keyTest.count  do	(						
								appendIfUnique  selKeyArray keytest[k].time
							)					
						)
						--return undefined
						
					)
					
					
				)
			)
			
			sort selKeyArray
			selKeyArray = makeUniqueArray  selKeyArray
			return selKeyArray	
		
		)
	
	)
	
	fn getKeyframeFromIni objs  fileName = ( -- 读取关键帧数据  
		preferences.fileProperties.useUnicodeForLegacyFiles = true
		frameCount = getINISetting fileName obj.name
		keyFF = #()
		for i  in frameCount do 	(
			append keyFF ((getINISetting fileName obj.name i) as time)	
		)
		return keyFF
	)
	
	
	fn exprotFbxforMayaToXdic = (
		try (makeDir @"D:/tools/Maya\AnimLibrary/Characters") catch()
	
		-- 设置 FBX 导出参数
		FBXExporterSetParam "Animation" true
		FbxExporterSetParam "BakeAnimation" true
		FBXExporterSetParam "ASCII" false
		FBXExporterSetParam "FileVersion" "FBX201600"
	
		-- 指定要导出的文件路径
		outputFile = @"D:/tools/Maya/AnimLibrary/Characters/maxFbxAnim.fbx"
	
		-- 导出 FBX 文件
		exportFile  outputFile #noPrompt selectedOnly:true using:FBXEXP 
	
		fileName = "D:/tools/Maya\AnimLibrary/Characters/maxKeyFrameInfo.ini"
	
		if not doesFileExist fileName then(   
			createFile fileName		
			try(close fileName)catch()
		)
		-- try (makeDir filePath) catch()
		sel = selection as array
		--写入测试
		setIniForceUTF16Default false
		for i in sel do(			-- 	i = sel[1]
		-- 	delIniSetting fileName i.name
			keyInfo = getAnimProp_yunEdit i	
			keyInfo_str = "("
			for i = 1 to keyInfo.count do      (
				keyInfo_str += (keyInfo[i] as string)
				if i != keyInfo.count then
				keyInfo_str += ", "
			)
			keyInfo_str += ")"
	
			buffer = substituteString (keyInfo_str as string) "f" ""
			keyInfoRemoveChar = substituteString buffer "#" ""
			setINISetting fileName  i.name  "Keys:" keyInfoRemoveChar forceUTF16:false  
		)
		-- 读出测试
	)
	
	fn cptoolsSetAnimRange = 	----适配值帧范围
	(
		str = cptools.testListAni.selected
		if str != undefined then 
		(
			buffer = filterString str "("
			rangeA =  filterString  buffer[2] ")"
			rangeB =   filterString   rangeA[1] "-"
			animationRange=interval (rangeB[1] as time)  (rangeB[2] as time )
		)
	)
	-----maxscript natural numeric sort自然数字排序
	fn getSHLWAPI = 
	(
		source =  "using System;\n"
		source += "using System.Runtime.InteropServices;\n"
		source += "class SHLWAPI\n"
		source += "{\n"
		source += "	[DllImport(\"shlwapi.dll\", CharSet = CharSet.Auto)]\n"
		source += "	public static extern int StrCmpLogicalW(string lpszStr, string lpszComp);\n"
		source += "}\n"
	
		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
					
		compilerParams.GenerateInMemory = on
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
		compilerResults.CompiledAssembly.CreateInstance "SHLWAPI"
	)
	struct myCoolDialogs
	(
		 labelStr,
	 
		 stringQuery = rollout stringQuery "输入命名"
		 (
			 local returnStr
		 
			 label lblHeader
			 editText etInput text:"_pose"
	 
			 fn launch label: =
			 (
				 destroyDialog myCoolDialogs.stringQuery
				 if label != unsupplied then
					 myCoolDialogs.labelStr = label
				 else myCoolDialogs.labelStr = "Enter some text:"
				 createDialog myCoolDialogs.stringQuery modal:true
				 returnStr -- only put it here if the dialog is modal
			 )
	 
			 on stringQuery open do
			 (
				 lblHeader.text = myCoolDialogs.labelStr
				 setFocus etInput
			 )
	 
			 on etInput entered str do
			 (
				 destroyDialog myCoolDialogs.stringQuery
				 returnStr = str
				 --cptools.rloading.pressed()
				
				)
			 
			on stringQuery close do 
			(
				destroyDialog myCoolDialogs.stringQuery
				 
				returnStr = "未命名_pose"
				--cptools.rloading.pressed()
			
			 )	
		 )
	)	
	fn MakeThumbnail_copy =(
		grab_bmp = gw.getViewportDib()
		croppedScreenGrab = bitmap grab_bmp.height grab_bmp.height 
		pasteBitmap grab_bmp croppedScreenGrab [((grab_bmp.width - grab_bmp.height)/2)+1,1] [0,0]  -- paste the orginal image to the tempImage, this results in a cropped image widh same height as width
		outputMap  = bitmap 170 170
		copy croppedScreenGrab outputMap 	
		close grab_bmp
		close croppedScreenGrab
	
		gc light:true
		if cptools.testList.visible  then   ---pose模式
		(	if cptools.testList.selected!=undefined then (outputMap.filename =((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp"))
		else 
		(	if cptools.testListAni.selected!=undefined then (outputMap.filename =((GetDir #export)+ "\\cptools_data\\")+cptools.testListAni.selected+".bmp"))
		save outputMap quiet:true--Save it to file
		outputMap
	)
	struct vpSave_copy (
		tmMatrix,
		screenGrab,
		vpType,
		
		fn saveTM =(
			try(
				vpType = viewport.getType()
				tmMatrix = getViewTM()
			)catch()
		),
		fn getTM =(
			try(
				viewport.setType vpType
				viewport.setTM tmMatrix
			)catch()
		),
		fn setScreenGrab =(
			try (screenGrab = (MakeThumbnail_copy();))catch()
		)
	)
	cptools_P1	
	(
		global stime           = animationrange.start
		global etime           = animationrange.end
		global start_frame     = animationrange.start
		global end_frame       = animationrange.end
		global selectundefined = 0
	
		global name_lag             
		global removeFromList_lag  
		global rloading_lag         
		global rb_sel_a_lag        
		global rb_sel_b_lag         
		global ac_lag              
		global addToList_lag       
		global pastepose_lag        
		global ABbutton_lag        
		global  obj_r_lag          
		global  obj_xyz_lag        
		global  obj_tcb_lag        
		global  paste_offset_lag    
		global paste_offset_b_lag   
		global lnk1_lag             
		global wayneCheckBox_lag    
		global ac_tooltip_a_lag     
		global ac_tooltip_b_lag    
		global ABbutton_tooltip_a_lag 
		global ABbutton_tooltip_b_lag
		global messagebox_a_lag   
		global messagebox_b_lag    
		global messagebox_c_lag     
		global messagebox_d_lag     
		global messagebox_e_lag     
		global messagebox_f_lag     
		global messagebox_a_title_lag
		global format_a_lag         
		global format_b_lag       
		global format_c_lag        
		global Accuracy_offset_lag 
		global Accuracy_offset_b_lag 
		global obj_r_b_lag           
		global wcb_lag            
		global rfl_lag             
		global language_a_lag     
		global language_b_lag      
	)
	--global frame_options   = false
	fn china = (
		name_lag             = "暴力帧拷贝粘贴V1.19" 
		removeFromList_lag   = "按住ctrl删除所有pose；单击打删除当前集"
		rloading_lag         = "更新列表：将列表内容更新至最新"
		rb_sel_a_lag         ="姿态"
		rb_sel_b_lag         ="动作"
		ac_lag               ="帧数范围：开始到结束"
		addToList_lag        = "拷贝帧"
		pastepose_lag        =  "粘贴帧" 
		ABbutton_lag         = "逐帧拷贝：在此模式下拷贝帧将以逐帧方式进行拷贝操作"
		obj_r_lag           = "重置变换：把变换重置为XYZ属性，重置后将无法保留原始动画信息"
		obj_xyz_lag         ="转换XYZ：把选择对象转换为XYZ属性"
		obj_tcb_lag         ="转换TCB：把选择对象转换为TCB属性"
		paste_offset_lag    =  "偏移 " 
		paste_offset_b_lag   ="偏移粘贴：输入帧数，粘贴帧将于（开始帧数+偏移帧数）往下粘贴动作"
		lnk1_lag             = " " 
		wayneCheckBox_lag    = "保留拷贝：勾选该项，下次开启将保留本次拷贝的姿态和动作"
		ac_tooltip_a_lag     = "帧数范围：开始到结束"
		ac_tooltip_b_lag     = "帧数范围：自定义开始结束"
		ABbutton_tooltip_a_lag ="关键帧拷贝：在此模式下拷贝帧将以选中所有对象在时间条中有帧的位置进行拷贝操作"
		ABbutton_tooltip_b_lag ="逐帧拷贝：在此模式下拷贝帧将以逐帧方式进行拷贝操作" 
		messagebox_a_lag     = "请选择至少一个物体"
		messagebox_b_lag     = "时间范围错误"
		messagebox_c_lag     ="未找到选择Pose，请更新列表"
		messagebox_d_lag     = "未找到选择Animation，请更新列表"
		messagebox_e_lag     = "场景中无物体在姿态集中"
		messagebox_f_lag     = "选择中有部分未被记录姿态"
		messagebox_a_title_lag = "提示"
		format_a_lag         = "已取消\n"
		format_b_lag         = "完成\n"
		format_c_lag         = "进度"
		Accuracy_offset_lag  = "精度"
		Accuracy_offset_b_lag  = "精度：通过精度数值进行重复粘贴以达到最准确的效果（数值越大用时越长）"
		obj_r_b_lag            = "П"
		wcb_lag              = "ü"
		rfl_lag              = "×"
		language_a_lag       = "中"
		language_b_lag       = "语言:当前是中文"
	)
	fn english = (
		name_lag             = "CopyPasteKey V1.19" 
		removeFromList_lag   = "Delete the selection sets: click to delete the current selection in the list of collection"
		rloading_lag         = "Update list: update to the latest list"
		rb_sel_a_lag         = "Pose"
		rb_sel_b_lag         = "Motion"
		ac_lag               = "Range of frames: start to finish"
		addToList_lag        = "Copy"
		pastepose_lag        = "Paste" 
		ABbutton_lag         = "Frame by frame copy: in this mode copy frame will copy operation on the basis of frame by frame"
		obj_r_lag           = "Reset to reset the transformation: the transformation XYZ properties, after the reset will not be able to retain the original animation information"
		obj_xyz_lag         = "Convert XYZ: convert a selection object to XYZ properties"
		obj_tcb_lag         = "Convert TCB: convert a selection object to TCB properties"
		paste_offset_lag    = "Offset " 
		paste_offset_b_lag   = "Offset paste: input frames, paste the frame will be (start frames + offset frames) to paste action"
		lnk1_lag             = "" 
		wayneCheckBox_lag    = "Keep a copy: check the, the next time will keep the copy of gestures and movements"
		ac_tooltip_a_lag     = "Range of frames: start to end"
		ac_tooltip_b_lag     = "Range of frames: custom start end"
		ABbutton_tooltip_a_lag ="key by key copy: in this mode will copy the frame to select all objects in the time of the frame position for copy operation"
		ABbutton_tooltip_b_lag ="Frame by frame copy: in this mode copy frame will copy operation on the basis of frame by frame" 
		messagebox_a_lag     = "Please select at least one object"
		messagebox_b_lag     = "Time range error"
		messagebox_c_lag     = "Choose the Pose is not found, please update the list"
		messagebox_d_lag     = "Choose the Animation is not found, please update the list"
		messagebox_e_lag     = "Concentration in attitude no object in the scene"
		messagebox_f_lag     = "Choose some have not been recorded in posture"
		messagebox_a_title_lag = "Prompt"
		format_a_lag         = "cancel\n"
		format_b_lag         = "finish\n"
		format_c_lag         = "Schedule"
		Accuracy_offset_lag  = " Acc "
		Accuracy_offset_b_lag  = "Accuracy: through repeated precision numerical paste in order to achieve the most accurate results (the larger the value when the long)"
		obj_r_b_lag          = "Res"
		wcb_lag              = "U"
		rfl_lag              = "X"
		language_a_lag       = "En"
		language_b_lag       = "Language: the current is in English"
	)
	---------------------------------------------------------------------------------------------打开文件加载
	
	makeDir  ((GetDir #export)+ "\\cptools_data\\")------创建路径
	makeDir  ((GetDir #export)+ "\\cptools_data\\localMode\\")------创建路径
	tempdata = ((GetDir #export)+"\\cptools_data\\"+"temp.ini")-----指定文件
	testPath = doesFileExist tempdata------检测文件是否存在
	if testPath == true then (
	open_tempdata   = openFile tempdata------打开temp文件
	skip_tmepdata   = skiptostring open_tempdata "Language = "
	if skip_tmepdata ==ok then (
		read_tempdata = readLine open_tempdata 
		en_ch = read_tempdata as booleanClass
		if en_ch  == true then (english()) else (china())
		) else (china())
	close open_tempdata
	)else (china())
	-----------------------------------------------------------------------------------------------------------------
	
	rollout cpToolsPicWin "缩略图"(
		button yunCopyImgBtn "--------" width:180 height:170 offset:[0,0]
		button yunCopyImgBtnGet "更新"  offset:[0,0]
		on cpToolsPicWin open do(
		cptools_P1 = vpSave_copy()
		)	
		on yunCopyImgBtnGet pressed do (cptools_P1.saveTM() ; cptools_P1.setScreenGrab() ; yunCopyImgBtn.images = #(cptools_P1.screengrab, undefined, 1,1,1,1,1) )
	)
	rollout cpToolsMaster "cpToolsMaster" height:220 width: 230	(
	  subrollout cpToolsParent1 "cpToolsParent1"
	  subrollout cpToolsParent2 "cpToolsParent2"	
	)
	rollout cptools name_lag  (
		Group   "Main"  (
			dropdownlist testList items:#() tooltip:"select pose"  across: 3 width:135 enabled:true visible:true
			button removeFromList ""  height:20 width:20 offset:[59,0] toolTip:removeFromList_lag
			button rloading       " R" height:20 width:20 offset:[22,0] toolTip:rloading_lag
	
	
				
				
			radioButtons rb_sel "" width:88 height:15 labels:#(rb_sel_a_lag ,rb_sel_b_lag ) offset:[-45,0]  
			button ac "A" width:18 height:16 offset:[18,-20] enabled:false toolTip:ac_lag
			spinner Accuracy_offset "         " range:[1,10, 3] type:#integer  width:40 offset:[40,-19]  toolTip: Accuracy_offset_b_lag enabled:true
			spinner spn_start  "" range:[-99999,99999, stime]     fieldwidth:37 across: 2 offset:[-40,0] type:#integer  enabled:false
			spinner spn_end "To " range:[-99999,99999, etime]  fieldwidth:37	 offset:[-60,0] type:#integer  enabled:false
			button addToList "" width:92 offset:[-19,0]  toolTip:"按ctrl单击可自由命名;按alt单击可覆盖"
			button pastepose "" width:58 height:42 offset:[61,-47] toolTip:"如果左键加速版粘贴报错\n可以使用右键旧版慢速粘贴\nlocal模式的粘贴也需要用右键"
			button ABbutton   "S" width:20   offset:[-77,-26] toolTip:ABbutton_lag  enabled:false
	
		)
	
		Group "Setting" (
			button obj_r   ""    width:32 height:18 offset:[-4,0] across:4  toolTip:obj_r_lag
			button obj_xyz "XYZ"  width:32 height:18 offset:[-9,0]   toolTip:obj_xyz_lag
			button obj_tcb "TCB"  width:32 height:18 offset:[-21,0] toolTip:obj_tcb_lag
	
			spinner paste_offset  "           " range:[-99999,99999, 0] type:#integer  width:90 offset:[-18,1]  toolTip:paste_offset_b_lag  enabled:false align:#center
		)	
	
		HyperLink lnk1 "                        " align:#center color:(color 150 150 150) hovercolor:(color 100 100 100)  width:1 visitedcolor:(color 150 150 150) address:"http://www.cgwayne.com/" 
		dropdownlist testListAni items:#() tooltip:"select pose" width:135 enabled:true visible:false offset:[0,-171] 
		checkbox wayneCheckBox "" offset:[-5,127] toolTip:wayneCheckBox_lag
		checkbox localModeCheckBox "local" offset:[35,-20] toolTip:"本地轴向模式"
		checkbox timeRangeCheckBox "帧" offset:[85,-20] toolTip:"自动到帧数范围"
	
		button language_btn ""  offset:[85,-18]  width:20 height:15 toolTip:language_b_lag
		button picShow "图"  offset:[60,-19]  width:20 height:15 toolTip:"打开或关闭缩略图"
		progressbar    doit_prog  offset:[-9,0]    width:190 height:8    color:red 
	
		on localModeCheckBox  changed theState do (	cptools.rloading.pressed ()	)
		on timeRangeCheckBox  changed theState do 	(	
			if theState do (try(cptoolsSetAnimRange ()) catch()	)	)
	
	
	
		on language_btn pressed  do (
			if language_btn.text =="En"  then 
			(
				china()
				language_btn.text = language_a_lag
				----------------------------------------------记录状态
				hold_CB = wayneCheckBox.checked
				hold_RB = rb_sel.state
				hold_ST = spn_start.value
				hold_ED = spn_end.value
				hold_AC = ac.text
				hold_AO = Accuracy_offset.value
				hold_AB = ABbutton.text
				hold_PO = paste_offset.value
				hold_SE = spn_start.enabled    
				hold_EE = spn_end.enabled       	
				hold_AE = ac.enabled
				hold_BE = ABbutton.enabled
				hold_PA = paste_offset.enabled
				hold_TP = testList.visible
				hold_TA = testListAni.visible 
				
				wayneCheckBox.checked = true
				postest = getDialogpos cptools
				destroyDialog cptools
				createDialog cptools  200 210 pos:postest
				-----------------------------------------------恢复状态		
				wayneCheckBox.checked  = hold_CB
				rb_sel.state           = hold_RB
				spn_start.value        = hold_ST
				spn_end.value          = hold_ED
				ac.text                = hold_AC
				Accuracy_offset.value  = hold_AO 
				ABbutton.text          = hold_AB
				paste_offset.value	   = hold_PO
				spn_start.enabled      = hold_SE 
				spn_end.enabled        = hold_EE
				ac.enabled 		       = hold_AE
				ABbutton.enabled   	   = hold_BE
				paste_offset.enabled   = hold_PA 
				testList.visible       = hold_TP
				testListAni.visible    = hold_TA 
				
			)else(
				english()
				language_btn.text = language_a_lag
				----------------------------------------------记录状态
				hold_CB = wayneCheckBox.checked
				hold_RB = rb_sel.state
				hold_ST = spn_start.value
				hold_ED = spn_end.value
				hold_AC = ac.text
				hold_AO = Accuracy_offset.value
				hold_AB = ABbutton.text
				hold_PO = paste_offset.value			
				hold_SE = spn_start.enabled    
				hold_EE = spn_end.enabled       	
				hold_AE = ac.enabled
				hold_BE = ABbutton.enabled
				hold_PA = paste_offset.enabled
				hold_TP = testList.visible
				hold_TA = testListAni.visible 
				
				wayneCheckBox.checked = true
				postest = getDialogpos cptools
				destroyDialog cptools
				createDialog cptools  200 210 pos:postest
				-----------------------------------------------恢复状态		
				wayneCheckBox.checked  = hold_CB
				rb_sel.state           = hold_RB
				spn_start.value        = hold_ST
				spn_end.value          = hold_ED
				ac.text                = hold_AC
				Accuracy_offset.value  = hold_AO 
				ABbutton.text          = hold_AB
				paste_offset.value	   = hold_PO
				spn_start.enabled      = hold_SE 
				spn_end.enabled        = hold_EE
				ac.enabled 		       = hold_AE
				ABbutton.enabled   	   = hold_BE
				paste_offset.enabled   = hold_PA 
				testList.visible       = hold_TP
				testListAni.visible    = hold_TA 
			)	
		)
		on cptools open do 
		(
			removeFromList.text  = rfl_lag
			Accuracy_offset.text = Accuracy_offset_lag
			addToList.text       = addToList_lag
			pastepose.text       = pastepose_lag
			obj_r.text           = obj_r_b_lag
			paste_offset.text    = paste_offset_lag
			wayneCheckBox.text   = wcb_lag
			language_btn.text    = language_a_lag
			lnk1.text            = lnk1_lag
			---------------------------------------------------------------------------------------------打开文件加载
			makeDir  ((GetDir #export)+ "\\cptools_data\\")------创建路径
			tempdata_another = ((GetDir #export)+"\\cptools_data\\"+"temp.ini")-----指定文件
			testPath_another = doesFileExist tempdata_another------检测文件是否存在
			if testPath_another == true do (
			open_tempdata_another   = openFile tempdata_another------打开temp文件
			skiptostring open_tempdata_another "wayneCheckBox.checked ="
			readChar open_tempdata_another
			read_tmepdata_another   = readLine open_tempdata_another 
			if read_tmepdata_another != undefined do wayneCheckBox.checked = read_tmepdata_another as booleanClass
			close open_tempdata_another
			)
			----------------------------------------------------------------------------------------------------------
			---------------------------------------获得文件列表
			file_name_array = getFiles ((GetDir #export)+"\\cptools_data\\"+"*Pose*.bps")
	
			for Fe in file_name_array do
			(
			Bip_FilesName=getFilenameFile Fe
			testList.items = append testList.items (Bip_FilesName as string)
			)
	
			file_name_array = getFiles ((GetDir #export)+"\\cptools_data\\"+"Animation*.bps")
	
			for Fe in file_name_array do
			(
			Bip_FilesName=getFilenameFile Fe
			testListAni.items = append testListAni.items (Bip_FilesName as string)
			)
			rloading.pressed()
	
	
		)	
		on rloading pressed do (
			---先清除列表
			if cptools.testList.items.count > 0 and cptools.testList.selection > 0 then 
			(
			cptools.testList.items = #() 
			)
				
			if cptools.testListAni.items.count > 0 and cptools.testListAni.selection > 0 then
			(
			cptools.testListAni.items = #()
			)
			
			----是否开启本地模式 pose模式
			if cptools.localModeCheckBox.checked==false then(
				file_name_array = getFiles ((GetDir #export)+"\\cptools_data\\"+"*Pose*.bps")
				
			) else (
				file_name_array = getFiles ((GetDir #export)+"\\cptools_data\\localMode\\"+"*Pose*.bps")	
			)
	
			----收集ini文件到下拉列表里 POSE
			itemArray = #()
			for Fe in file_name_array do
			(
			Bip_FilesName=getFilenameFile Fe	
			append itemArray (Bip_FilesName as string)	
			)
			
			---自然数字排序
			if ::SHLWAPI == undefined do SHLWAPI = getSHLWAPI()
			qsort itemArray SHLWAPI.StrCmpLogicalW 
			
			cptools.testList.items = itemArray
			cptools.testList.selection = cptools.testList.items.count
			
			----是否开启本地模式  动画模式
			if cptools.localModeCheckBox.checked==false then(
			file_name_array = getFiles ((GetDir #export)+"\\cptools_data\\"+"Animation*.bps")
			) else (
				file_name_array = getFiles ((GetDir #export)+"\\cptools_data\\localMode\\"+"*Animation*.bps")	
			)
			
			----收集ini文件到下拉列表里 ANIM
			itemArray_ani = #()
			for Fe in file_name_array do
			(
			Bip_FilesName=getFilenameFile Fe
			append itemArray_ani (Bip_FilesName as string)	
	
			)	
				---自然数字排序
			if ::SHLWAPI == undefined do SHLWAPI = getSHLWAPI()
			qsort itemArray_ani SHLWAPI.StrCmpLogicalW 
			
			cptools.testListAni.items  = itemArray_ani
			cptools.testListAni.selection = cptools.testListAni.items.count
		)
		on cptools close do (
			--if wayneCheckBox.checked == false then(for f in getFiles ((GetDir #export)+ "\\cptools_data\\"+"*.bps") do deleteFile f)
			---------------------------------------------------------------------------------------------退出文件加载
			
			makeDir  ((GetDir #export)+ "\\cptools_data\\")------创建路径
			tempdata_another = ((GetDir #export)+"\\cptools_data\\"+"temp.ini")-----指定文件
			create_tempdata_another = createfile tempdata_another
			if wayneCheckBox.checked == true then formatdata = "wayneCheckBox.checked = true" else formatdata = "wayneCheckBox.checked = false"
			if language_btn.text  == "En" then forlagdata = "Language = true" else  forlagdata = "Language = false" 
			format  "%\n" formatdata to:create_tempdata_another 
			format  "%\n" forlagdata to:create_tempdata_another 
			close create_tempdata_another
			----------------------------------------------------------------------------------------------------------
		)	
		on ac pressed do (
			if ac.text =="C"  then 
			(
				ac.text = "A"
				spn_start.enabled       = false
				spn_end.enabled         = false
				ac.tooltip              = ac_tooltip_a_lag
			)else(
				ac.text                 = "C"
				spn_start.enabled       = true
				spn_end.enabled         = true
				ac.tooltip              = ac_tooltip_b_lag
			)	
		)
		on rb_sel changed stat do(
			case stat of	(
				1:
				(
					testList.visible        = true
					testListAni.visible     = false
					----------------------------------
					ac.enabled              = false
					spn_start.enabled       = false
					spn_end.enabled         = false
					paste_offset.enabled    = false
					ABbutton.enabled        = false
					----------------------------------
				)
				2:
				(
					testList.visible        = false
					testListAni.visible     = true
					----------------------------------
					ac.enabled              = true
					paste_offset.enabled    = true
					----------------------------------
					ABbutton.enabled        = true
					----------------------------------
					if ac.text =="C" then ( spn_start.enabled = true; spn_end.enabled = true)else (spn_start.enabled = false; spn_end.enabled = false)
				)
			)
			
		)
		on ABbutton pressed do (
			if ABbutton.text =="S"  then (ABbutton.text = "K" ;ABbutton.tooltip = ABbutton_tooltip_a_lag )else(ABbutton.text = "S" ;ABbutton.tooltip =ABbutton_tooltip_b_lag)	
		)
		-----###记录
		on addToList pressed do (
			with undo "addList" on 		(
				if(rb_sel.state==1)then			----##pose记录
				(
					if(selection.count == 0 )then(messagebox messagebox_a_lag   title:messagebox_a_title_lag beep:false )
					else(	
						-----------------------------------------手动输入----------------------------------------------
						struct myCoolDialogs (
							labelStr,				
							stringQuery = rollout stringQuery "输入命名"
							(
								local returnStr						
								label lblHeader
								editText etInput text:"_pose"					
								fn launch label: =
								(
									destroyDialog myCoolDialogs.stringQuery
									if label != unsupplied then
										myCoolDialogs.labelStr = label
									else myCoolDialogs.labelStr = "Enter some text:"
									createDialog myCoolDialogs.stringQuery modal:true
									returnStr -- only put it here if the dialog is modal
								)					
								on stringQuery open do
								(
									lblHeader.text = myCoolDialogs.labelStr
									setFocus etInput
								)					
								on etInput entered str do
								(
									destroyDialog myCoolDialogs.stringQuery
									returnStr = str
									--cptools.rloading.pressed()
									
									)
								
								on stringQuery close do 
								(
									destroyDialog myCoolDialogs.stringQuery
									
									returnStr = "未命名_pose"
									--cptools.rloading.pressed()
								
								)							
							)
						)					
						if keyboard.controlPressed then (
							myCoolDialogs = myCoolDialogs() -- as there are variables, an instance is needed
							result = myCoolDialogs.stringQuery.launch label:"回车确认命名"
							-----------------------------------------手动输入--------------------------------------							
							testList.items = append testList.items (result+ (testList.items.count+1) as string +" ("+ ((currentTime as integer)/TicksPerFrame)  as string +")")
							testList.selection = testList.items.count
							---------------------------------------------------------------------------------------
							tabtxt   = testList.selection
							if cptools.localModeCheckBox.checked==false then(	
								out_name = ((GetDir #export)+"\\cptools_data\\"+ result +tabtxt as string +" ("+ ((currentTime as integer)/TicksPerFrame) as string +")"+".bps")
							) else (
								out_name = ((GetDir #export)+"\\cptools_data\\localMode\\"+ result +tabtxt as string +" ("+ ((currentTime as integer)/TicksPerFrame) as string +")"+".bps")	
							)
							
							out_file = createfile out_name
						)
						else if keyboard.altPressed then (						
							--testList.items = append testList.items ("Pose "+ (testList.items.count+1) as string +" ("+ ((currentTime as integer)/TicksPerFrame)  as string +")")
							--testList.selection = testList.items.count
						
							tabtxt   = testList.selected						
							if cptools.localModeCheckBox.checked==false then(	
								out_name = ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")
							)  else (
								out_name = ((GetDir #export)+"\\cptools_data\\localMode\\"+ tabtxt as string +".bps")	
							)
								try(deleteFile out_name)catch()
								out_file = createfile out_name
								print "覆盖命名\n"
						)                  
						else (
							
							testList.items = append testList.items ("Pose "+ (testList.items.count+1) as string +" ("+ ((currentTime as integer)/TicksPerFrame)  as string +")")
							testList.selection = testList.items.count
							tabtxt   = testList.selection	
							
							if cptools.localModeCheckBox.checked==false then(	
								out_name = ((GetDir #export)+"\\cptools_data\\Pose "+ tabtxt as string +" ("+ ((currentTime as integer)/TicksPerFrame) as string +")"+".bps")
							)  else (
								out_name = ((GetDir #export)+"\\cptools_data\\localMode\\Pose "+ tabtxt as string +" ("+ ((currentTime as integer)/TicksPerFrame) as string +")"+".bps")	
							)
								out_file = createfile out_name
						)
						-------------------------------------将选择重新排序
						sort_array =#()
						temp_sort_file = selection as array
						sort_file = sort(for i in temp_sort_file collect i.name)
	
						for i=1 to sort_file.count do 
						(
						format "%|" sort_file[i] to: out_file -- 添加一个选择集
						)
						format "\n"  to:out_file
	
						for i =1 to sort_file.count do 
						(
						obj =getnodebyname sort_file[i] 
						append sort_array obj
						)
						select sort_array
						-----------------------------------------
						k=1
						for o in selection do
						(
							if keyboard.escPressed do 
							(
								format format_a_lag
								exit
							)
						doit_prog.value = 100.*k/selection.count
						if selection.count !=0 then 	(
							if cptools.localModeCheckBox.checked then(	
								if 	o.parent==undefined then (messageBox "local坐标模式请不要选择根骨节      .")
								else (
									theCoords=o.transform * (inverse o.parent.transform)
									format "$'%'.transform = %\n" o.name theCoords to:out_file
								)
							) else (
								format "$'%'.transform = %\n"  o.name o.transform to:out_file
							)
						)
						k=k+1
						--format (format_c_lag + ":(%/100)  \n")  doit_prog.value
						if doit_prog.value == 100 do (format format_b_lag )
						)
						doit_prog.value = 0
	
						close out_file
	
						--format "You selected '%'!\n" testList.selection
					)	
				)
				----####动画记录
				else
				(
					if(selection.count == 0 )then(messagebox messagebox_a_lag title:messagebox_a_title_lag beep:false )
					else
					(
						if (end_frame<=start_frame)then(messagebox messagebox_b_lag title:messagebox_a_title_lag beep:false )
						else
						(	
							if ac.text =="C" then ( start_frame = spn_start.value;end_frame = spn_end.value)
							else (start_frame = animationrange.start;end_frame = animationrange.end)	
								
							testListAni.items = append testListAni.items ("Animation "+ (testListAni.items.count+1) as string +"-"+(ABbutton.text) as string +" ("+ (start_frame) as string + "-" + (end_frame) as string+")" )
							testListAni.selection = testListAni.items.count
							tabtxt   = testListAni.selection
							----确定保存文件本地ini
							if cptools.localModeCheckBox.checked==false then
							(
								out_name = ((GetDir #export)+"\\cptools_data\\Animation "+ tabtxt as string +"-"+(ABbutton.text) as string +" ("+ (start_frame) as string + "-" + (end_frame) as string+")"+".bps")
							) 
							else 
							(		
								out_name = ((GetDir #export)+"\\cptools_data\\localMode\\Animation "+ tabtxt as string +"-"+(ABbutton.text) as string +" ("+ (start_frame) as string + "-" + (end_frame) as string+")"+".bps")
							)
							out_file = createfile out_name
							tempstime = animationrange.start
							tempetime = animationrange.end
							--适配了时间轴，方便后边判断用
							animationRange = interval start_frame end_frame--time
							-------------------------------------将选择重新排序
							sort_array =#()
							temp_sort_file = selection as array
							sort_file = sort(for i in temp_sort_file collect i.name)
							for i=1 to sort_file.count do 
							(	format "%|" sort_file[i] to: out_file	)  -- 添加一个选择集			
							format "\n"  to:out_file
							for i =1 to sort_file.count do 
							(
								obj =getnodebyname sort_file[i] 
								append sort_array obj
							)
							select sort_array
							oriTime = sliderTime
							----------------------------------------
							if ABbutton.text =="S" then   -----###逐帧模式
							(
								for i=animationrange.start to animationrange.end do
								(
									if keyboard.escPressed do 
									(
										format format_a_lag
										exit
									)
									doit_prog.value = 100.*i/animationrange.end
									--slidertime = i
									at time i
									(
										for o in selection do
										(
											if selection.count !=0 then 	(
												-----本地模式
												if cptools.localModeCheckBox.checked then
												(
													if 	o.parent==undefined then (messageBox "local坐标模式请不要选择根骨节      .")
													else 
													(
														theCoords=o.transform * (inverse o.parent.transform)
														format  "<%>|%| = %\n" i o.name theCoords to:out_file
													)
												) 
												else 
												(	format  "<%>|%| = %\n" i o.name o.transform to:out_file	)
											)
										)
										--format  (format_c_lag + ":(%/100)  \n")   doit_prog.value
										if doit_prog.value == 100 do (format format_b_lag)
									)
								)
								doit_prog.value = 0
								--恢复time函数防止biped骨骼异样bug
								sliderTime =  animationrange.start
								at time animationrange.start()
							)
							else			---###关键帧模式
							(
								slidertime = animationrange.start
								a = slidertime
								frame_data = #()
								seek out_file #eof
								orgFilePos = filePos out_file
								format "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n"  to:out_file
								---------------------------------------------------------------关键帧对象位置信息写入
								disableSceneRedraw()		----关闭视图刷新加速
								suspendEditing()
								do
								(							
									if keyboard.escPressed do 
									(
										format format_a_lag
										exit
									)
									append frame_data a		
									a_lost = a	
									---选择的物体里执行		
									for o in selection do
									(
										if selection.count !=0 then    
										(
											---本地模式
											if cptools.localModeCheckBox.checked then
											(
												if 	o.parent==undefined then (messageBox "local坐标模式请不要选择根骨节      .")
												else 
												(											
													theCoords=o.transform * (inverse o.parent.transform)
													format  "<%>|%| = %\n" a o.name theCoords to:out_file			---a 是关键帧数，在dowhere循环里得
												)
											) 
											else 
											( format  "<%>|%| = %\n" a o.name o.transform to:out_file	)	---a 是关键帧数，在dowhere循环里得
											
									)
									)
									a = trackbar.getnextkeytime()
									doit_prog.value = 100.*a_lost/(animationrange.end-animationrange.start)
									if a!=undefined and a > animationrange.start and  a <= animationrange.end  then 
									(slidertime = a	)
									else (  Exit  )							
									--format  (format_c_lag + ":(%/100)  \n")   doit_prog.value							
									if doit_prog.value == 100 do (format format_b_lag)	
								
								)
								while a > animationrange.start	and a > a_lost 
								resumeEditing()	
								enableSceneRedraw()	
								----------------------------------------------------------------关键帧对象位置信息写入  End
								doit_prog.value = 100
								format format_b_lag
								doit_prog.value = 0
								seek out_file orgFilePos 
								--------------------------------------------------------------关键帧写入文件
								format "frame:" to: out_file
								for i=1 to frame_data.count do (  format "%|" frame_data[i] to: out_file) 
								format "\n"  to:out_file
								--------------------------------------------------------------关键帧写入文件 End
							)
							close out_file
							sliderTime = oriTime 
							animationRange = interval tempstime tempetime
						)
	
					)
				)
	
	
				cptools_P1.saveTM() ;
				cptools_P1.setScreenGrab() ;
				try( cpToolsPicWin.yunCopyImgBtn.images = #(cptools_P1.screengrab, undefined, 1,1,1,1,1) )catch()
			)
		)
	
		on addToList  rightClick do (
			
			exprotFbxforMayaToXdic()
		)
		on removeFromList pressed do (
	
			if keyboard.controlPressed then (	
				if cptools.localModeCheckBox.checked==false then(	
					folderPath  = ((GetDir #export)+"\\cptools_data\\")
				)else (
					folderPath  = ((GetDir #export)+"\\cptools_data\\localMode\\")
				)
				
				-- 要删除的文件类型
				fileType = ".bps";
				filesToDelete = getFiles (folderPath + "*" + fileType);
				for file in filesToDelete do (try (deleteFile file);catch())
				fileType = ".bmp";
				filesToDelete = getFiles (folderPath + "*" + fileType);
				for file in filesToDelete do (try (deleteFile file);catch())
			)	
			else if (rb_sel.state==1) then (   --判断是pose模式还是动画模式
				if testList.items.count > 0 and testList.selection > 0 then (				
					tabtxt  = testList.selected
					
					if cptools.localModeCheckBox.checked==false then(	
						delete_name  = ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")
					)else (
						delete_name  = ((GetDir #export)+"\\cptools_data\\localMode\\"+ tabtxt as string +".bps")
					)
					delete_file  = deleteFile delete_name 
					if delete_file == undefined do ( messagebox messagebox_c_lag  beep:false Title:messagebox_a_title_lag  Return 0 )
					testList.items = deleteItem testList.items testList.selection
					testList.selection = testList.items.count
				)
			)else(
				if testListAni.items.count > 0 and testListAni.selection > 0 then(
					tabtxt  = testListAni.selected
					--print tabtxt	
					if cptools.localModeCheckBox.checked==false then(	
						delete_name = ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")
					)else (
						delete_name  = ((GetDir #export)+"\\cptools_data\\localMode\\"+ tabtxt as string +".bps")
					)	
						
					delete_file = deletefile delete_name
					if delete_file == undefined do ( messagebox messagebox_d_lag  beep:false Title:messagebox_a_title_lag Return 0 )
					--print delete_name 
					--print delete_file 
					testListAni.items = deleteItem testListAni.items testListAni.selection
					testListAni.selection = testListAni.items.count
				)
			)
			rloading.pressed()
	
		)
		----------------------------------------------选择pose中添加物体
		on testList selected i do 
		(
			tabtxt = testList.items[i]
			if cptools.localModeCheckBox.checked==false then(	
				in_sel = ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")
			) else (
				in_sel = ((GetDir #export)+"\\cptools_data\\localMode\\"+ tabtxt as string +".bps")
			)
	
			in_file = openFile in_sel
			if in_file == undefined do  ( messagebox messagebox_c_lag beep:false Title:messagebox_a_title_lag Return 0 )
	
			seek in_file 0
			ss = readLine in_file
			tokens = filterString ss "|"
			arrayl=#()
	
			for i =1 to tokens.count do 	(
				obj =getnodebyname tokens[i] 
				if obj != undefined do append arrayl obj
			)
			if arrayl.count !=0 then select arrayl else  ( messagebox messagebox_e_lag beep:false Title:messagebox_a_title_lag )
			close in_file
			
			-- 刷图
			if cptools.testList.visible  then   ---pose模式
			(
				if cptools.testList.selected!=undefined then
				(
					picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")
					if picSelName!=undefined then
					(
					versionCheck = maxVersion();if versionCheck[1]<17000 then (freeSceneBitmaps() ; gc light:on;free  picSelName;picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")) else (forceReloadBitmapFile  picSelName);cpToolsPicWin.yunCopyImgBtn.images = #(picSelName, undefined, 1,1,1,1,1)
					)
					else (cpToolsPicWin.yunCopyImgBtn.images =#("enss_tools_16i.bmp", undefined,13, 3, 3,3,3, true))
				)
			)
			else(         --动画模式
				if cptools.testListAni.selected!=undefined then
				(
					picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testListAni.selected+".bmp")
					if picSelName!=undefined then
					(
					versionCheck = maxVersion();if versionCheck[1]<17000 then (freeSceneBitmaps() ; gc light:on;free  picSelName;picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")) else (forceReloadBitmapFile  picSelName);cpToolsPicWin.yunCopyImgBtn.images = #(picSelName, undefined, 1,1,1,1,1)
					)
					else (cpToolsPicWin.yunCopyImgBtn.images =#("enss_tools_16i.bmp", undefined,13, 3, 3,3,3, true))
				)
			)
		)
		------------------
		on testListAni selected i do  
		(
			tabtxt = testListAni.items[i]			
			if cptools.localModeCheckBox.checked==false then(	
					in_sel = ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")
			)else (
				in_sel = ((GetDir #export)+"\\cptools_data\\localMode\\"+ tabtxt as string +".bps")	
			)
	
			in_file = openFile in_sel
			if in_file == undefined do ( messagebox messagebox_d_lag beep:false Title:messagebox_a_title_lag Return 0 )
	
			seek in_file 0
			ss = readLine in_file
			tokens = filterString ss "|"
			arrayl=#()
			for i =1 to tokens.count do 
			(
			obj =getnodebyname tokens[i] 
			if obj != undefined do append arrayl obj
			)
			if arrayl.count !=0 then select arrayl else  ( messagebox messagebox_e_lag beep:false Title:messagebox_a_title_lag )
			close in_file
	
			---刷图
			if cptools.testList.visible  then   ---pose模式
				(
					if cptools.testList.selected!=undefined then
					(
						picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")
						if picSelName!=undefined then
						(
						versionCheck = maxVersion();if versionCheck[1]<17000 then (freeSceneBitmaps() ; gc light:on;free  picSelName;picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")) else (forceReloadBitmapFile  picSelName);cpToolsPicWin.yunCopyImgBtn.images = #(picSelName, undefined, 1,1,1,1,1)
						)
						else (cpToolsPicWin.yunCopyImgBtn.images =#("enss_tools_16i.bmp", undefined,13, 3, 3,3,3, true))
					)
				)
				else
				(         --动画模式
					if cptools.testListAni.selected!=undefined then
					(
						picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testListAni.selected+".bmp")
						if picSelName!=undefined then
						(
						versionCheck = maxVersion();if versionCheck[1]<17000 then (freeSceneBitmaps() ; gc light:on;free  picSelName;picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")) else (forceReloadBitmapFile  picSelName);cpToolsPicWin.yunCopyImgBtn.images = #(picSelName, undefined, 1,1,1,1,1)
						)
						else (cpToolsPicWin.yunCopyImgBtn.images =#("enss_tools_16i.bmp", undefined,13, 3, 3,3,3, true))
					)
				)
			if cptools.timeRangeCheckBox.state do (try(cptoolsSetAnimRange ())	catch())
	
		)
		-----------------------暴力粘贴-------------------------------------------------------------------------------------------------------------------------------------------------------
		on pastepose rightclick  do 
		(
			cptools.pastepose_rightclicked()
		)

		fn pastepose_rightclicked  =
		(	
			start_time = timeStamp()
			-------------------------------------将选择重新排序
			sort_array =#()
			temp_sort_file = selection as array
			sort_file = sort(for i in temp_sort_file collect i.name)
			for i =1 to sort_file.count do 		
			(
				obj =getnodebyname sort_file[i] 
				append sort_array obj
			)
			select sort_array
			selectundefined = 0
			with undo "pasteList" on         
			(
				for sec = 1 to Accuracy_offset.value do  --精度，循环次数。3次
				(	
					---######pose粘贴	
					if(cptools.rb_sel.state==1)then
					(
						---有保存的姿势且选择了
						if cptools.testList.items.count > 0 and testList.selection > 0 then
						(	
							tabtxt  = cptools.testList.selected	  	--选择的物体		
							if cptools.localModeCheckBox.checked==false then	---非本地模式	
							(	in_name =  ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")	) 
							---本地模式
							else   (in_name =  ((GetDir #export)+"\\cptools_data\\localMode\\"+ tabtxt as string +".bps")	) 
							
							in_file = openFile in_name
							---如果没有怎提示选择pose
							if in_file == undefined  do  ( messagebox messagebox_c_lag  beep:false Title:messagebox_a_title_lag  Return 0 )
							--with animate on
							--( 	
							seek in_file 0
							skipToNextLine in_file
							orgFilePos = filePos in_file
							---当前选择循环
							for i=1 to selection.count do  
							(--takes every selected object and...			
								--print i
								if keyboard.escPressed do	(format format_a_lag;exit)		---esc退出
								doit_prog.value = 100.*i/selection.count	
								o=selection[i]
								seek in_file orgFilePos 
								a= skiptostring in_file ((o.name)+"'.transform")			---定位到物体名字的地方		
								
								if a==undefined then ( selectundefined =selectundefined+1 ) 		---是否定位成功（是否记录过数据），然后加1，selectundefined是存放有多少个未记录物体
								else(
									skiptostring in_file "="   ----再次定位到=号之后
									ss = readLine in_file ---as stringStream 	记录下矩阵数据
																
									--判断是maya还是max姿势							
									checkTM = filterString ss "#"
									if checkTM.count > 1 then	( 																
										---maya记录的矩阵转化成max矩阵
										mayaTM = execute checkTM[2]								
										ss = (mayaTM *(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0]))	as string															
									)
									ex_tran = "$"+"'"+o.name+"'"+".transform="+ ss			---处理成脚本				
									-----写入本地姿势pose			
									if cptools.localModeCheckBox.checked then 		---本地模式粘贴
									(
										--字符转成矩阵
										fn deserializeMatrix3 str =
										(
											local p = filterString str ","
											local row1 = [p[1] as float, p[2] as float, p[3] as float]
											local row2 = [p[4] as float, p[5] as float, p[6] as float]
											local row3 = [p[7] as float, p[8] as float, p[9] as float]
											local row4 = [p[10] as float, p[11] as float, p[12] as float]
											return matrix3 row1 row2 row3 row4
										)
										str =ss
										str=substituteString   str "(matrix3" ""
										str=substituteString   str ")" ""
										str=substituteString   str "] [" ","
										str=substituteString   str "]" ""
										str=substituteString   str "[" ""
										theCoords_str2Mat = deserializeMatrix3 str
										----写入旋转和位移
										if classof o != Biped_Object then		---非bip本地
										(
											rotLocal = theCoords_str2Mat.rotationPart
											rotLocal.w=0-rotLocal.w
											in coordsys  parent  o.scale = theCoords_str2Mat.scalePart 	----局部缩放支持
											in coordsys  parent  o.rotation = rotLocal 
											in coordsys  parent  o.pos = theCoords_str2Mat[4]
										)
										else	---bip本地								
										(									
											back2WorldTM = theCoords_str2Mat*( o.parent.transform)									
											Biped.setTransform o #rotation  back2WorldTM.rotationPart	 true
											--	Biped.setTransform o #pos back2WorldTM[4] true	
										)
									)						
									else (	execute ex_tran	 )		---非本地模式粘贴
									--------------------------------------------------------写入结束									
									--format (format_c_lag + ":(%/100)  \n")   doit_prog.value
									if doit_prog.value == 100 do (format format_b_lag)	
								)
							)
							doit_prog.value = 0
							--)
							close in_file
						)
						if selectundefined != 0 then
						(
							strmessage = "选择中有"+ selectundefined as string +"个对象未记录Pose" 
							--strmessage = messagebox_f_lag
							messagebox strmessage   title:messagebox_a_title_lag beep:false
						)
					)
					---动画粘贴
					else
					(
						if testListAni.items.count > 0 and testListAni.selection > 0 then			---是否显示了物体
						(	
							if(selection.count == 0 )then(messagebox messagebox_a_lag  title:messagebox_a_title_lag beep:false )			---是否有选择
							else
							(	
								---帧数范围是当前还是自定义的	  C自定，A自动	
								if ac.text =="C" then ( start_frame = spn_start.value+ paste_offset.value;end_frame = spn_end.value+ paste_offset.value)
								else (start_frame = animationrange.start+ paste_offset.value;end_frame = animationrange.end+ paste_offset.value)
								
								if (start_frame>=end_frame)then(messagebox messagebox_b_lag title:messagebox_a_title_lag beep:false )
								else		---时间范围没错
								(    
									tabtxt  = testListAni.selected
									---获取文本，本地非本地
									if cptools.localModeCheckBox.checked==false then
									(	in_name =  ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")	) 
									else (	in_name =  ((GetDir #export)+"\\cptools_data\\localMode\\"+ tabtxt as string +".bps") )				
							
									in_file = openFile in_name			---是否选择
									if in_file == undefined do (messagebox messagebox_d_lag beep:false Title:messagebox_a_title_lag Return 0 )
	
									tempstime = animationrange.start
									tempetime = animationrange.end
									animationRange = interval (start_frame) (end_frame)--time 记录下时间范围以后方便恢复
									------------判断S还是K，要开始粘贴了
									s_or_k =  filterstring tabtxt "S"
									oriTime = sliderTime
									with animate on
									( 
										if s_or_k.count != 1 then 	----###逐帧模式
										(	
											for m=animationrange.start to animationrange.end do   ---帧
											(
												if keyboard.escPressed do 		---esc退出
												(
													format format_a_lag
													exit
												)
												
												doit_prog.value = 100.*m/animationrange.end	---进度条
												
												--sliderTime = m
												at time m
												(
													seek in_file 0 
													
													skipToNextLine in_file	
													
													skiptostring in_file ("<"+((m-paste_offset.value) as String)+">")   ----定位到帧数标签 ，这里有计算帧数偏移
													
													orgFilePos = filePos in_file
													for i=1 to selection.count do --takes every selected object and...m每个选择的物体
													(
														if keyboard.escPressed do 
														(
															format format_a_lag
															exit
														)
														o=selection[i]
														seek in_file orgFilePos 			
														a = skiptostring in_file ("|"+(o.name)+"|") ---定位到字符流	
														if a==undefined then ( selectundefined =selectundefined+1 )		---记录未记录物体
														else
														(	
															skiptostring in_file "="			---定位到=号后
															ss = readLine in_file ---as stringStream	读取到矩阵
															
															--判断是maya还是max姿势							
															checkTM = filterString ss "#"
															if checkTM.count > 1 then	( 																
																---maya记录的矩阵转化成max矩阵
																mayaTM = execute checkTM[2]								
																ss = (mayaTM *(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0]))	as string                                                        
															)
															ex_tran = "$"+"'"+o.name+"'"+".transform="+ ss			--转成脚本				
															if cptools.localModeCheckBox.checked then 
															(
																-----写入本地姿势pose
																--字符转成矩阵
																fn deserializeMatrix3 str =
																(
																	local p = filterString str ","
																	local row1 = [p[1] as float, p[2] as float, p[3] as float]
																	local row2 = [p[4] as float, p[5] as float, p[6] as float]
																	local row3 = [p[7] as float, p[8] as float, p[9] as float]
																	local row4 = [p[10] as float, p[11] as float, p[12] as float]
																	return matrix3 row1 row2 row3 row4
																)
																str =ss
																str=substituteString   str "(matrix3" ""
																str=substituteString   str ")" ""
																str=substituteString   str "] [" ","
																str=substituteString   str "]" ""
																str=substituteString   str "[" ""
																theCoords_str2Mat = deserializeMatrix3 str
																----写入旋转和位移
																if classof o != Biped_Object then		---非bip本地
																(
																	rotLocal = theCoords_str2Mat.rotationPart
																	rotLocal.w=0-rotLocal.w
																	in coordsys  parent  o.scale = theCoords_str2Mat.scalePart 	----局部缩放支持
																	in coordsys  parent  o.rotation = rotLocal 
																	in coordsys  parent  o.pos = theCoords_str2Mat[4]
																)
																else	---bip本地								
																(									
																	back2WorldTM = theCoords_str2Mat*( o.parent.transform)									
																	Biped.setTransform o #rotation  back2WorldTM.rotationPart	 true
																-- 	Biped.setTransform o #pos back2WorldTM[4] true	
																)
															)											
															else (	execute ex_tran	)
															--readDelimitedString in_file "end"
															--------------------------------------------------------写入结束	
														)	
													)
													--format (format_c_lag + ":(%/100)  \n")  doit_prog.value
													if doit_prog.value == 100 do (format format_b_lag )
												)	---end at time
											)
											doit_prog.value = 0
										)
										---###关键帧模式
										else
										(
											seek in_file 0
											skipToNextLine in_file
											skiptostring in_file "frame:"
											ss  = readLine in_file
											frame_array_filter = filterString ss "|"
											frame_arrayl =#()
											-----加上偏移的时间数组后边要加所以这里要减
											for k =1 to frame_array_filter.count do 
											(
												if frame_array_filter[k] as time >= animationrange.start-paste_offset.value and  frame_array_filter[k] as time <= animationrange.end-paste_offset.value do
												(
													append frame_arrayl frame_array_filter[k] 
													--sort frame_arrayl
												)
											)
											--macros.run "Animation Tools" "DeleteSelectedAnimation"
											---逐帧的循环
											for m=1 to frame_arrayl.count do
											(
												if keyboard.escPressed do 	(format format_a_lag;exit)
												doit_prog.value = 100.*m/frame_arrayl.count
												--sliderTime = frame_arrayl[m] as time + paste_offset.value
												at time (frame_arrayl[m] as time + paste_offset.value)		
												(
													seek in_file 0															
													skipToNextLine in_file						
													skiptostring in_file ("<"+( frame_arrayl[m] as String)+">")		
													orgFilePos = filePos in_file
													--所有选择物体的循环
													for i=1 to selection.count do 
													(--takes every selected object and...				
														if keyboard.escPressed do 	(format format_a_lag;exit)
														o=selection[i]
														seek in_file orgFilePos 					
														a = skiptostring in_file ("|"+(o.name)+"|")
														if a==undefined then ( selectundefined =selectundefined+1 )else
														(	
															skiptostring in_file "="
															ss = readLine in_file ---as stringStream
	
															--判断是maya还是max姿势							
															checkTM = filterString ss "#"
															if checkTM.count > 1 then	( 																
																---maya记录的矩阵转化成max矩阵
																mayaTM = execute checkTM[2]								
																ss = (mayaTM *(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0]))	as string                                                        
															)
	
															ex_tran = "$"+"'"+o.name+"'"+".transform="+ ss					
															if cptools.localModeCheckBox.checked then 
															(				
																-----写入本地姿势pose
																--字符转成矩阵
																fn deserializeMatrix3 str =	
																(
																	local p = filterString str ","
																	local row1 = [p[1] as float, p[2] as float, p[3] as float]
																	local row2 = [p[4] as float, p[5] as float, p[6] as float]
																	local row3 = [p[7] as float, p[8] as float, p[9] as float]
																	local row4 = [p[10] as float, p[11] as float, p[12] as float]
																	return matrix3 row1 row2 row3 row4
																)
																str =ss
																str=substituteString   str "(matrix3" ""
																str=substituteString   str ")" ""
																str=substituteString   str "] [" ","
																str=substituteString   str "]" ""
																str=substituteString   str "[" ""
																theCoords_str2Mat = deserializeMatrix3 str
																----写入旋转和位移
																if classof o != Biped_Object then		---非bip本地
																(
																	rotLocal = theCoords_str2Mat.rotationPart
																	rotLocal.w=0-rotLocal.w
																	in coordsys  parent  o.scale = theCoords_str2Mat.scalePart 	----局部缩放支持
																	in coordsys  parent  o.rotation = rotLocal 
																	in coordsys  parent  o.pos = theCoords_str2Mat[4]
																)
																else	---bip本地								
																(									
																	back2WorldTM = theCoords_str2Mat*( o.parent.transform)									
																	Biped.setTransform o #rotation  back2WorldTM.rotationPart	 true
																--Biped.setTransform o #pos back2WorldTM[4] true	
																)
															)													
															else(execute ex_tran)
															--------------------------------------------------------写入结束
															--readDelimitedString in_file "end"
														)
													)
													--format (format_c_lag + ":(%/100)  \n")   doit_prog.value
													if doit_prog.value == 100 do (format format_b_lag)
												)
											)
											doit_prog.value = 0
										)
										
										sliderTime =  animationrange.start
										at time animationrange.start()
									)
									
									close in_file
									sliderTime = oriTime 
									
									animationRange = interval tempstime tempetime
								)	
							)
						)	
					)
					sec = sec + 1
					sec = sec + 1
				)---end of 次数3次
				----报错
				if selectundefined != 0 then
				(
					selectundefined = selectundefined/(spn_end.value-spn_start.value)
					--strmessage = "选择中有"+ selectundefined as string +"个对象未记录Pose" 
					strmessage = messagebox_f_lag
					messagebox strmessage   title:messagebox_a_title_lag beep:false
					selectundefined = 0
				)
			)
			end_time = timeStamp()
			run_time = end_time - start_time
			print ("粘贴耗时：" + (run_time * 3) as string )
		)
		
		--C#加速粘贴
		on pastepose  pressed do 
		(	
			if cptools.testList.visible  then   ---pose模式
			(
				cptools.pastepose_rightclicked()
			)
			else
			(		
				max create mode                
				start_time = timeStamp()
				tabtxt  = cptools.testListAni.selected
				in_name = ((GetDir #export)+"\\cptools_data\\"+ tabtxt as string +".bps")
				if  cptools.ac.text =="C" then ( start_frame =  cptools.spn_start.value+  cptools.paste_offset.value;end_frame =  cptools.spn_end.value+  cptools.paste_offset.value)
				else (start_frame = animationrange.start+  cptools.paste_offset.value;end_frame = animationrange.end+  cptools.paste_offset.value)
				animationRange = interval (start_frame) (end_frame)
				s_or_k =  filterstring tabtxt "S"
				frame_arrayl =#()
	
				if s_or_k.count != 1 then 	----###逐帧模式
				(
					for i = start_frame-cptools.paste_offset.value to end_frame-cptools.paste_offset.value do
					( 
						append frame_arrayl (i.frame as integer)
						sort frame_arrayl
					)
				)
				else
				(
					if keyboard.shiftPressed do
					(
						gc()
						gc()
						CSharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
						CompilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	
						CompilerParams.ReferencedAssemblies.Add("System.dll")
						CompilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll")
						CompilerParams.ReferencedAssemblies.Add("System.IO.dll")
						CompilerParams.ReferencedAssemblies.Add("System.Threading.Tasks.dll")
						compilerParams.ReferencedAssemblies.Add((getdir #maxroot) + @"Autodesk.Max.dll");	
						CompilerParams.GenerateExecutable = false
						CompilerParams.GenerateInMemory = false
	
						global CompilerResults = CSharpProvider.CompileAssemblyFromSource CompilerParams #(CSharpCodeSourceBipFast)
						WinAssembly = CompilerResults.CompiledAssembly
						BipFastAssembly = undefined
						BipFastAssembly =  WinAssembly.CreateInstance "bipedSetTM.SetTM_test"	
						print "重新编译一次~"					
					)
					in_file = openFile in_name	
					seek in_file 0
					skipToNextLine in_file
					skiptostring in_file "frame:"
					ss  = readLine in_file
					frame_array_filter = filterString ss "|"
					-----加上偏移的时间数组后边要加所以这里要减
					for k =1 to frame_array_filter.count do 
					(
						if frame_array_filter[k] as time >= animationrange.start-cptools.paste_offset.value and 
							frame_array_filter[k] as time <= animationrange.end-cptools.paste_offset.value do
						(
							append frame_arrayl ((frame_array_filter[k]as time ).frame as integer )
							sort frame_arrayl
						)
					)
				)
				frame_array = ""
				for i in frame_arrayl do (frame_array += i as string + "|")
				pasteOffset = cptools.paste_offset.value
				-- print "----->"
				-- print in_name; ;print pasteOffset;; print frame_array; print cptools.Accuracy_offset.value;
				-- print BipFastAssembly;
				-- showMethods BipFastAssembly;
				try
				(
					with undo "pasteList" on     
					(
						animate on
						(
							if BipFastAssembly!= undefined and selection.count > 0 do
							(BipFastAssembly.pastAnimationEveryFrame in_name pasteOffset frame_array cptools.Accuracy_offset.value)                   
						)            
					)
				)
				catch
				(
					print "加速失败!!!"
					messageBox "试下按shift+单击\n\nshift+单击无效可尝试重新打开插件\n确保场景中有物体在姿态集中\n\n再不行。。。\n可以右键单击用原版的功能粘贴动画"
				)
				
				end_time = timeStamp()
				run_time = end_time - start_time
				print ("粘贴耗时：" + (run_time * 3) as string )
			)
			at time sliderTime
			ForceCompleteRedraw()
			
		)
		---------------------------------------------------------------------------------------
		on obj_r pressed do (
			for o in selection do
			(
			o.controller = transform_script ()   
			o.controller = prs()
			)
		)
		on obj_xyz pressed do (
			for o in selection do
			(
			o.position.controller =Position_XYZ()
			o.rotation.controller =Euler_XYZ()
			)
		)
		on obj_tcb pressed do (
			for o in selection do
			(
			o.position.controller =TCB_Position()
			o.rotation.controller =TCB_Rotation()
			)
		)
	
		on picShow pressed do (
			if cpToolsMaster.width<300 then  ( cpToolsMaster.width =410	)
			else ( cpToolsMaster.width =200	)
	
		)
		-- on picShow rightClick do  (cpToolsMaster.width =  200 )
	) 
	-- createDialog cptools  200 330
	-- bgcolor:[0,0,0] 
	createdialog cpToolsMaster	
	fn MakeThumbnail_copy =	(
		grab_bmp = gw.getViewportDib()
		croppedScreenGrab = bitmap grab_bmp.height grab_bmp.height 
		pasteBitmap grab_bmp croppedScreenGrab [((grab_bmp.width - grab_bmp.height)/2)+1,1] [0,0]  -- paste the orginal image to the tempImage, this results in a cropped image widh same height as width
		outputMap  = bitmap 170 170
		copy croppedScreenGrab outputMap 	
		close grab_bmp
		close croppedScreenGrab
		
		gc light:true
		if cptools.testList.visible  then   ---pose模式
		(	if cptools.testList.selected!=undefined then (outputMap.filename =((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp"))
		else 
		(	if cptools.testListAni.selected!=undefined then (outputMap.filename =((GetDir #export)+ "\\cptools_data\\")+cptools.testListAni.selected+".bmp"))
		save outputMap quiet:true --Save it to file
		outputMap
	)
	AddSubRollout cpToolsMaster.cpToolsParent1 cptools
	AddSubRollout cpToolsMaster.cpToolsParent2 cpToolsPicWin
	cpToolsMaster.cpToolsParent1.pos = [0,0]
	cpToolsMaster.cpToolsParent1.height = 240
	cpToolsMaster.cpToolsParent1.width = 200
	cpToolsMaster.cpToolsParent2.pos = [210,0]
	cpToolsMaster.cpToolsParent2.height = 240
	-- cpToolsMaster.width =  410
	cpToolsMaster.height = 240
	cpToolsMaster.width =  200
	
	-- 刷图
	if cptools.testList.visible  then  ( ---pose模式
	
		if cptools.testList.selected!=undefined then
		(
			picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")
			if picSelName!=undefined then
			(
			versionCheck = maxVersion();if versionCheck[1]<17000 then (freeSceneBitmaps() ; gc light:on;free  picSelName;picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")) else (forceReloadBitmapFile  picSelName);cpToolsPicWin.yunCopyImgBtn.images = #(picSelName, undefined, 1,1,1,1,1)
			)
			else (cpToolsPicWin.yunCopyImgBtn.images =#("enss_tools_16i.bmp", undefined,13, 3, 3,3,3, true))
		)
	)
	else(         --动画模式
		if cptools.testListAni.selected!=undefined then
		(
			picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testListAni.selected+".bmp")
			if picSelName!=undefined then
			(
			versionCheck = maxVersion();if versionCheck[1]<17000 then (freeSceneBitmaps() ; gc light:on;free  picSelName;picSelName =openBitmap  (((GetDir #export)+ "\\cptools_data\\")+cptools.testList.selected+".bmp")) else (forceReloadBitmapFile  picSelName);cpToolsPicWin.yunCopyImgBtn.images = #(picSelName, undefined, 1,1,1,1,1)
			)
			else (cpToolsPicWin.yunCopyImgBtn.images =#("enss_tools_16i.bmp", undefined,13, 3, 3,3,3, true))
		)
	)
	)
	
	