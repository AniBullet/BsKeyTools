try(destroydialog BsVportTools)catch()
try (callbacks.removeScripts #filePostOpen id:#UpdateBsVport) catch ()

global iniPosVportTools
global BsVportTools
global arrVportFilename
global arrVportValue

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false title:"BsVportTools")
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false title:"BsVportTools")
stLoadConfigAll.fnLoadConfigVportTools ()

rollout BsVportTools "BsVportTools_v1.0"
(
	MultiListBox mlbVportSet "" width:150 height:15 pos:[5,50]
	edittext edtAddVport "" width:95 height:17 pos:[0,30]
	button btnAddVportSet "" width:40 height:17 pos:[95,30] tooltip:"保存当前视角"
	button btnDelVportSet "" width:20 height:17 pos:[135,30] tooltip:"移除所选视角"
	button btnSaveVportINI "" width:30 height:20 pos:[75,5] tooltip:"保存导出"
	button btnLoadVportINI "" width:30 height:20 pos:[105,5] tooltip:"加载导入"
	button btnHelp "" width:20 height:20 pos:[135,5] tooltip:"点击打开视频帮助说明\r\n功能简述：保存当前视角参数\r\n(完全不影响文件本身，只存参数)"

	fn getFilesequenceFile f &base &digits = 
	(
		f = getFilenameFile f
		base = trimRight f "0123456789"
		digits = subString f (base.count + 1) -1
	)

	fn fnPseudoNaturalSort a b =  --文件名排序新方法--https://forums.cgsociety.org/t/sorting-filenames/1219205/4
	(
		a = a as string
		b = b as string
		getFilesequenceFile a &aBase &aDigits
		-- hackhackhack.  This pads a number with zeros to 6 digits without using a loop.
		-- things will fail if there's more digits.. 6 'seems' safe.
		aDigits = subString ((1000000 + (aDigits as integer)) as string) 2 -1
		getFilesequenceFile b &bBase &bDigits
		bDigits = subString ((1000000 + (bDigits as integer)) as string) 2 -1
		a = aBase + aDigits
		b = bBase + bDigits
	
		case of (
		(a == b): 0
		(a < b): -1
		(a > b): 1
		)
	)

	fn fnSaveVportFile pathINI = 
	(
		
	)
	
	fn fnLoadVportFile pathINI = 
	(
		
	)
	
	fn fnAddVport = 
	(
		
	)
	
	fn fnUpdateVportList = 
	(
		
	)

	on btnHelp pressed do 
	(shellLaunch "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" "")

	on BsVportTools open do
	(
		stLoadConfigAll.fnLoadConfigVportTools()  ---------------脚本位置等赋值
		stSetConfigAll.fnSetConfigVportTools()  ----------------保存位置信息到ini文件
		btnAddVportSet.images      = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,5,5,6,6,false,true)
		btnDelVportSet.images = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,7,7,8,8,false,true)
		btnSaveVportINI.images          = #("bip_general_i.bmp","bip_general_i.bmp",30,7,7,8,8,false,true)
		btnLoadVportINI.images          = #("bip_general_i.bmp","bip_general_i.bmp",30,5,5,6,6,false,true)
		btnHelp.images             = #("UVWUnwrapView_16i.bmp","UVWUnwrapView_16i.bmp",28,15,15,16,16,false,false)
		fnUpdateVportList()
	)

	on BsVportTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosVportTools   = (GetDialogPos BsVportTools)
        stSetConfigAll.fnSetConfigVportTools ()
	)

	on btnSaveVportINI pressed do
	(
		local save_path = getSaveFileName caption:"Save XML File " filename:".xml" types:"XML(*.xml)|*.xml|"
		if save_path != undefined then
		(
			fnSaveVportFile save_path
		)
	)	

	on btnLoadVportINI pressed do
	(
		local pathLoad = getOpenFileName caption:"Load XML File" types:"XML(*.xml)|*.xml|"
		if pathLoad != undefined then
		(
			local dataLoad = fnLoadVportFile pathLoad
			
			if dataLoad != undefined then
			(
				print (dataLoad as string)
				arrVportFilename = dataLoad[1]
				arrVportValue   = dataLoad[2]
				iniPosVportTools   = (GetDialogPos BsVportTools)
			)
		)
	)

	on mlbVportSet doubleClicked val do 
	(

	)	

	on mlbVportSet selectionEnd do
	(
	
	)

	on btnAddVportSet pressed do
	(

	)

	on btnDelVportSet pressed do undo "RemoveVportSet" on
	(

	)

)
if (iniPosVportTools != 0) then 
(Createdialog BsVportTools 160 260 fgcolor:myFgColor pos:iniPosVportTools style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
else (Createdialog BsVportTools 160 260 fgcolor:myFgColor style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))

callbacks.addScript #filePostOpen "fnUpdateVportList()" id:#UpdateBsVport