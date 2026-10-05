/*
 * @Description: 生成参考工具
 * @Author: Bullet.S
 * @Date: 2020-12-29 01:12:45
 * @LastEditors: Bullet.S
 * @LastEditTime: 2025-05-25 11:32:23
 * @Email: animator.bullet@foxmail.com
 */

try(destroydialog rolAddRefFolder)catch()
try(destroydialog rolRefTools)catch()

struct itemsFolder (name,dir)
Global iniPosRefTools
global iniLastRefFolder = (itemsFolder name:"" dir:"")
global iniRefFolder1    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniRefFolder2    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniRefFolder3    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniRefFolder4    = (itemsFolder name:"<＋＋＋>" dir:"")
global iniFilterRefName = #()

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
stLoadConfigAll.fnLoadConfigBsRefTools ()

global currentVersion = "0.1.2"
Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径

-- global spm = (dotNetclass "System.Net.ServicePointManager")
-- spm.SecurityProtocol = spm.SecurityProtocol.Tls12

global dotDrawingImage = dotNetclass "System.Drawing.Image"
global dotNetClipboard = DotNetclass "System.Windows.Forms.Clipboard"
Global SIOFile         = dotNetClass "System.IO.File"
Global SIODir          = dotNetClass "System.IO.Directory"
global dotnetWebClient = dotNetObject "System.Net.WebClient"

struct itemsFolder (name,dir)
global numCurrentPic = 1
global tempSavePath  = (getdir #temp) + @"\\tempReferencePic"

global dateTime = (dotNetClass "System.DateTime").Now
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
Global posMouMove       = [0,0]
global tempAddFolderID  = "0"
Global arrRefType       = #("静帧","动图","视频","剪切板")
global typePic          = #(".png",".jpg",".jpeg",".bmp")
global typeGif          = #(".gif")
global typeVedio        = #(".avi",".mp4",".mkv")
global arrAllRefFiles   = #()
global arrAllRefFolders = #()

fn fnDelFileDir targetDel =  --删除文件
(
	if (SIOFile.Exists targetDel == true) then ---判断是否存在文件
	(
		if getFileAttribute targetDel #readOnly == true or \
		getFileAttribute targetDel #hidden == true do --修改只读或者隐藏属性
		(
			setFileAttribute targetDel #readOnly false ; \
			setFileAttribute targetDel #hidden false
		)
		try (SIOFile.Delete(targetDel);(print ("已删除: "+ filenameFromPath targetDel)))
		catch (print ("删除失败: "+ filenameFromPath targetDel + ". 请尝试手动删除.");print "删除失败")
	)
)
fn fnDelFolder dirDel =
(
	if (SIODir.Exists dirDel) == true do
	(
		if getFileAttribute dirDel #readOnly == true or getFileAttribute dirDel #hidden == true do
		(
			setFileAttribute dirDel #readOnly false ; setFileAttribute dirDel #hidden false
		)
		try (SIODir.Delete(dirDel) true;(print ("已删除: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹")))
		catch (print ("删除失败: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹. 请尝试手动删除.");print "删除失败")
	)
)


fn fnSaveClipBoardPic =
(
    local arrTempFiles = #()
    local arrTempid = #(0)

    arrTempFiles = getFiles (tempSavePath + @"\\*.*")
    for i in arrTempFiles where arrTempFiles.count != 0 do
    (
        if (MatchPattern (getfilenameFile i) pattern:"*tempReferencePic*") then
        (
            tempid = (filterString (getfilenameFile i) "tempReferencePic")
            appendIfUnique arrTempid (tempid[tempid.count] as number)
            sort arrTempid
        )
    )
    tempImage = dotNetClipboard.GetImage()
    tempSaveImage = (tempSavePath + @"\\tempReferencePic" + \
    ((arrTempid[arrTempid.count] + 1) as string) +".png")
    if tempImage != undefined do 
    (
        tempImage.save tempSaveImage
        -- fnCreateRefPlane tempSaveImage
    )
)

fn fnCreateRefPlane filePath =  --获取剪切板的图片, 貌似只支持单个, 支持网络图片直接复制, 会在temp里面另存
(
    tempRefImage = dotDrawingImage.fromfile filePath 
    planeRef = plane width:tempRefImage.width length:tempRefImage.height lengthsegs:1 widthsegs:1 
	planeRef.rotation.x_rotation = 90
	planeRef.name = "planeReferencePic"
    bitmapRef = Bitmaptexture fileName:filePath
    planeRef.material = standard diffuseMap:(bitmapRef) showInViewport:true
	planeRef.material.name = "matReferencePic"
	enableHardwareMaterial planeRef.material true
	showHWTextureMap planeRef.material true
)

fn fnGetClipboardPic =
(
    
    if dotNetClipboard.ContainsFileDropList() do ---获取剪切板的本地图片, 可多个
    (
        arrRefPic = #()
		fileList = dotNetClipboard.GetFileDropList()
		print fileList
        for i = 0 to (fileList.count - 1) do (fnCreateRefPlane (fileList.item i))
        -- for i = 0 to (fileList.count - 1) do (append arrRefPic (fileList.item i))
    )
)

rcmenu RCmenuRefConfig
(
	local myMs = (getDir #Scripts)+ @"\\BulletScripts\\BsRefTools.ms"
    local startupPath = (getDir #StartupScripts)+ @"\\BsRefTools.ms"

	-- subMenu "更新"
	-- (
	-- 	menuItem mitemUpdate "一键更新"
	-- 	menuItem mItemForceUpdate "强制更新"
	-- )

	subMenu "工具栏按钮"
	(menuItem submConfigAddToolBar "添加"
	menuItem submConfigDelToolBar "去除")

    subMenu "更多功能"
	(menuItem submConfigHighDpi "设置高分辨率"
	menuItem submConfigCleanMat "清理并整理材质球"
	menuItem submConfigClearTempRef "清理参考图暂存目录"
	menuItem submConfigAutoLoad "是否自启"
	menuItem mItemUninstall "卸载")
    
    menuItem menuJoinGroup "🐧交流小群"
    menuItem menuBilibili "📺Bullet.S"

	fn addToolBarRefTools macro cat txt remove: false =
	(
		fn insertContent f data: "" find: "" rewrite: false =
		(						
			file = MemStreamMgr.openFile f
			size = file.size()
			MemStreamMgr.close file
					
			stream = openFile f mode:"r+"

			seek stream 0 
				
			if ((sysinfo.GetMaxLanguage())[3]=="CHS")  then 
			(
				mt = "\"主工具栏\""
			)
			else
			(
				mt = "\"Main Toolbar\""
			)	
			skipToString stream mt
					
			exist = (skipToString stream find) == undefined
			
			previousContent = ""
			
			findPos = filePos stream
			
			if(not exist) do
			(							
				if(rewrite) do 
				(
					pos = findPos - find.count
					seek stream	0
					previousContent += readChars stream (pos)					
				)
				
				pos = findPos - (if(rewrite) then 0 else find.count)
			
				seek stream pos
				
				previousContent += readChars stream (size - pos)
										
				if(rewrite) do pos = 0
				
				seek stream pos
					
							
				format data to: stream
				format previousContent to: stream
			)
			
			close stream
			
			return not exist
		)
		
		try
		(
			f = cui.getConfigFile() 
			
			cui.loadConfig f
			cui.saveConfigAs f
			cui.loadConfig f
			
			l = "<Item typeID=\"2\" type=\"CTB_MACROBUTTON\" width=\"0\" height=\"0\" controlID=\"0\" macroTypeID=\"3\" macroType=\"MB_TYPE_ACTION\" actionTableID=\"647394\" imageID=\"-1\" imageName=\"\" actionID=\"" + macro + "`_[" + cat + "]\" tip=\"" + txt + "\" label=\"" + txt + "\" />"
			delBtnLine = "<Item typeID=\"2\" type=\"CTB_MACROBUTTON\" width=\"61\" height=\"0\" controlID=\"0\" macroTypeID=\"3\" macroType=\"MB_TYPE_ACTION\" actionTableID=\"647394\" imageID=\"-1\" imageName=\"\" actionID=\"" + macro + "`_[" + cat + "]\" tip=\"" + txt + "\" label=\"" + txt + "\" />"
			if(remove) then
			(			
				insertContent f find: delBtnLine rewrite: true
			)
			else
			(		
				insertContent f find: "</Items>" data: ("\t\t" + l + "\n")			
			)
			cui.loadConfig f
			--cui.setConfigFile f
			cui.saveConfigAs f
			--cui.loadConfig f
				
		) catch(messageBox "请手动处理Toolbar!             \r\n" title: "错误!")
	)

	fn fnCleanRefPlaneAndMat =
	(
		TempMatArray = #()
		for i in Objects do	
		(
			if i.Material != undefined do 
			(if (FindItem TempMatArray i.Material) == 0 do
				append  TempMatArray i.material )
			if i.name == "planeReferencePic" do delete i
		)
		while  SceneMaterials.count > 0 do (deleteItem SceneMaterials 1)	
		for i in TempMatArray do append SceneMaterials i
		disableSceneRedraw()
		if scenematerials.count>0 and geometry.count>0 do
		(
			s = scenematerials.count
			x=int(s/24)---计算取整
			y=mod s 24 ---计算余数
			if k== undefined then k=1
			if k > x+2 do k=1
			if y>0 and k == x+1 then
			(
				for j=1 to 24 do
				(
					new_mat_name = (j+24*(k-1)) as string + " - Default"
					meditMaterials[j] = standard name:new_mat_name
				)
				for i = 1 to y do
				(
					meditMaterials[i] = sceneMaterials[i+24*(k-1)]
				)
				
			)else
			(
				for j=1 to 24 do
				(
					meditMaterials[j]=sceneMaterials[j+24*(k-1)]
				)
			)
			k=k+1
			print ("当前场景整理后包含" + s as string+"个材质。")
			if k==x+1 and y==0 do k=1
			if k==x+2 and y>0 do k=1
		)
		if scenematerials.count==0 do (pushPrompt ("本场景没有任何材质"))
		enableSceneRedraw()
	)

    on RCmenuRefConfig open do
	(
		if(SIOFile.Exists startupPath) then (submConfigAutoLoad.checked = true)
		else (submConfigAutoLoad.checked = false)
	)
	on submConfigAutoLoad picked do 
	(
		if (submConfigAutoLoad.checked == true) then 
		(
			fnDelFileDir startupPath
			(messagebox ("已取消自启: " + filenameFromPath startupPath \
				+ "        \r\n") beep:false title:"取消自启")
			submConfigAutoLoad.checked = false
		)
		else 
		(
			if (not (SIOFile.Exists startupPath)) do
			(
				SIOFile.Copy myMs startupPath
				(messagebox ("已打开自启: " + filenameFromPath startupPath \
				+ "        \r\n") beep:false title:"开启自启")
				submConfigAutoLoad.checked = true
			)
		)
	)
	on submConfigClearTempRef picked do 
	(
		fnDelFolder tempSavePath
		(messagebox ("清理temp完成,请按F11查看详情,若失败请手动处理~        ") \
			beep:false title:"清理参考缓存文件夹")
	)

	on submConfigAddToolBar picked do
	(
		addToolBarRefTools "BsRefTools" "BulletTools" "BsRefTools" remove: true
		addToolBarRefTools "BsRefTools" "BulletTools" "BsRefTools"
	)

	on submConfigDelToolBar picked do
	(
		addToolBarRefTools "BsRefTools" "BulletTools" "BsRefTools" remove: true
	)

	on submConfigHighDpi picked do 
	(
		-- NitrousGraphicsManager.SetProceduralTextureSizeLimit 4096 true
		NitrousGraphicsManager.SetTextureSizeLimit 4096 true
		NitrousGraphicsManager.SetBackgroundTextureSizeLimit 4096 true

		messagebox ("ViewportConfiguration-DisplayPerformance\r\n中的Maximum已设置为4096\r\n" + \
			"默认设置是1024,512,1024,可手动还原~                    ")
	)

	on submConfigCleanMat picked do with undo on
	(
		if (queryBox "是否彻底清理所有参考图并整理材质球？      \r\n" \
		title:"清理参考图" beep:false) then(fnCleanRefPlaneAndMat ())
	)

	-- on mitemUpdate picked do 
	-- (
	-- 	try(destroydialog rolAddRefFolder)catch()
	-- 	try(destroydialog rolRefTools)catch()
	-- 	fnCheckUpdate isForceUpdate:false
	-- 	fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BsRefTools.ms")
	-- )

	-- on mItemForceUpdate picked do 
	-- (
	-- 	try(destroydialog rolAddRefFolder)catch()
	-- 	try(destroydialog rolRefTools)catch()
	-- 	fnCheckUpdate isForceUpdate:true
	-- 	fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BsRefTools.ms")
	-- )

	on mItemUninstall picked do 
	(
		local deletFile1 = ((getDir #Scripts)+ @"\\BulletScripts\\BsRefTools.ms")
		local deletFile2 = ((getDir #Scripts)+ @"\\startup\\BsRefTools.ms")
		try(destroydialog rolAddRefFolder)catch()
		try(destroydialog rolRefTools)catch()
		try(fnDelFileDir deletFile1;fnDelFileDir deletFile2) catch()
		if (queryBox ("可能因为权限无法清除, 若删除失败请手动删除:          \r\n\r\n"+ deletFile1 + "\r\n" + deletFile2 + "                  ") title:"手动清除残留") then (ShellLaunch (getDir #Scripts) "")
		else (ShellLaunch (getDir #Scripts) "")
	)

	on menuJoinGroup picked do 
	(
		if (queryBox "是否加入个人分享交流群？\r\n\r\n(游戏，动画爱好者休闲吹水正能量分享群)\r\n\r\n子弹工具人(993590655)，确认可直接跳转链接~          \r\n        " \
		title:"加入交流群" beep:false) then
		(
		shellLaunch "https://jq.qq.com/?_wv=1027&k=hmeHhTwu" "")
	)

	on menuBilibili picked do 
	(shellLaunch "https://space.bilibili.com/2031113/lists/560782?type=season" "")
)

rollout rolPreviewRef ""
(
	dotNetControl dn_flp "flowlayoutpanel" pos:[0,30]
    dotNetControl btn_LengthDistance "System.Windows.Forms.button" pos:[0,30]
    
    button btnPrePic "←" width:30 height:20 pos:[5,5]
    button btnNextPic "→" width:30 height:20 pos:[40,5]

    slider sldRefFrame "" orient:#horizontal  ticks:0 range:[1,1,1] pos:[80,5] width:100

    fn fnOpenPic filePicPath =
    (
        rolPreviewRef.btn_LengthDistance.image = \
        (dotNetclass "System.Drawing.Image").fromfile filePicPath

        rolPreviewRef.title = getfilenamefile  filePicPath
        rolPreviewRef.width = rolPreviewRef.btn_LengthDistance.image.width
        rolPreviewRef.height = rolPreviewRef.btn_LengthDistance.image.height
        rolPreviewRef.btn_LengthDistance.width = rolPreviewRef.btn_LengthDistance.image.width
        rolPreviewRef.btn_LengthDistance.height = rolPreviewRef.btn_LengthDistance.image.height
        rolPreviewRef.dn_flp.width = rolPreviewRef.btn_LengthDistance.image.width
        rolPreviewRef.dn_flp.height = rolPreviewRef.btn_LengthDistance.image.height
    )

	on rolPreviewRef open do
	(
        fnSaveClipBoardPic ()

		btn_LengthDistance.margin =  dotnetobject "padding" 0
		btn_LengthDistance.FlatAppearance.BorderSize = 1
		btn_LengthDistance.flatstyle = (dotNetclass "FlatStyle").flat

		dn_flp.Controls.Clear()
		dn_flp.SuspendLayout()
		dn_flp.controls.addrange #(btn_LengthDistance)
        dn_flp.resumelayout()
        
        sldRefFrame.range = [1,arrRefPic.count,1]

        rolPreviewRef.btn_LengthDistance.width = 0
        rolPreviewRef.btn_LengthDistance.height = 0
        rolPreviewRef.dn_flp.width = 0
        rolPreviewRef.dn_flp.height = 0
    )

    on btnPrePic pressed do 
    (
        print numCurrentPic
        if ((arrRefPic.count != 0) and (arrRefPic[1] != undefined)) then 
        (
            case of
            (
                (numCurrentPic == 1):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic = arrRefPic.count)
                (numCurrentPic <= arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic -= 1)
                (numCurrentPic > arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic-1];numCurrentPic -= 1)
            )            
        )
        
    )

    on btnNextPic pressed do 
    (
        print numCurrentPic
        case of
        (
            (numCurrentPic == 1):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic += 1)
            (numCurrentPic < arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic += 1)
            (numCurrentPic == arrRefPic.count):(fnOpenPic arrRefPic[numCurrentPic];numCurrentPic = 1)
            (numCurrentPic > arrRefPic.count):(fnOpenPic arrRefPic[1];numCurrentPic = 1)
        )  
        
    )

    on sldRefFrame changed val do
    (
        fnOpenPic arrRefPic[val]
    )

)

rollout rolAddRefFolder "添加参考文件夹" width:340 height:80
(
	groupbox gbxAddDir "添加参考文件夹--(Tips:右击可重新添加)" width:330 height:70 pos:[5,5]
	
	edittext edtAddDirName "命名" pos:[10,25] fieldWidth:160 height:20 labelOnTop:false text:""
	button btnOpenDir "选择目录"  pos:[200,25] width:70 height:20 tooltip:"选择添加目录，默认打开当前文件目录"
	edittext edtDirStr "" pos:[5,50] fieldWidth:262 height:20 readOnly:true

	button btnAddItems "添加" width:55 height:45 pos:[275,25]

	on rolAddRefFolder open do 
	(
		if tempAddFolderID != "0" then (rolAddRefFolder.title += tempAddFolderID)
	)

	on btnOpenDir pressed do 
	(
		local dir = getSavePath caption:"请选择目录:" initialDir:(maxFilePath)
		if (dir != undefined) then
		(
			edtDirStr.text = dir
			edtAddDirName.text = getfilenamefile dir
		)
	)

	on edtAddDirName changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtAddDirName.text = tempText
	)

	on btnAddItems pressed do
	(
		if ((edtDirStr.text != "") and (edtAddDirName.text != "")) then
		(
			str = "iniRefFolder" + tempAddFolderID + " = itemsFolder name:\"<" + \
			edtAddDirName.text + ">\" dir:@\"" + edtDirStr.text +"\""
			str += "\r\nrolRefTools.btnRefDir" + tempAddFolderID + ".text = \"<" + edtAddDirName.text + ">\""
			execute str
			try(destroydialog rolAddRefFolder)catch()
			stSetConfigAll.fnSetConfigBsRefTools ()
		)
	)
)

rollout rolRefTools ("[参考工具]-BsRefTools_v" + currentVersion)  width:340 height:332
(
	groupbox grpMain "" \
	width:330 height:327 pos:[5,0]
	editText edtBrowseFolder "" text:"" labelOnTop:true align:#right \
	height:20 fieldWidth:210 pos:[70,12] readOnly:true 
	button btnLastFolder "↑" height:25 width:25 pos:[280,10] border:false \
	tooltip:"返回上层目录，也可右击文件或工具空白处"
	button btnOpenAddress "..." align:#right tooltip:"选择打开目录" \
	height:22 width:30 pos:[35,12] border:true
	button btnOpenCurrentDir "打开" tooltip:"打开当前文件夹" \
	height:25 width:25 pos:[305,10] border:false
	button btnRefreshFolder "R" align:#left border:true \
	height:22 width:25 pos:[10,12] tooltip:"左：刷新列表\r\n右：重置场景"
	
	label labelSearch "↓词缀筛选↓" width:70 height:25 pos:[15,65]	
	edittext edtFilterStr "" width:150 height:17 pos:[80,40] toolTip:"关键词筛选"
	button btnGetClipboardPic "获取剪切板图片" width:95 height:25 pos:[235,35] \
	border:false toolTip:"获取剪切板图片"
	button btnFilterPrefix "+常用词缀+" border:false \
	height:25 width:70 pos:[10,35] tooltip:"左：添加过滤\r\n右：取消过滤\r\n选中过滤列表\r\n右击删除条目"

	listBox ltbFilterPrefix "" align:#left selection:0 \
	height:6 width:70 pos:[10,85]
	radioButtons rdoFileType "" columns:arrRefType.count \
	pos:[90,65] labels:arrRefType
	listBox ltbFilesList "" align:#right selection:0 \
	height:16 width:245 pos:[85,85]

	button btnRefDir1 "" border:true \
	height:24 width:70 pos:[10,171] tooltip:"右击可重新添加"
	button btnRefDir2 "" border:true \
	height:24 width:70 pos:[10,197] tooltip:"右击可重新添加"
	button btnRefDir3 "" border:true \
	height:24 width:70 pos:[10,223] tooltip:"右击可重新添加"
	button btnRefDir4 "" border:true \
	height:24 width:70 pos:[10,249] tooltip:"右击可重新添加"
	button btnTempRefDir "<剪切缓存>" border:true \
	height:24 width:70 pos:[10,275] tooltip:"剪切板图片缓存目录"
	groupBox grpDate "" width:330 height:30 pos:[5,297]
	label lblCountTips "" height:15 width:80 pos:[15,307]
	label lblDateTime "" height:15 width:130 pos:[120,307] 
	HyperLink lnkLink "Bullet.S" color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor \
	pos:[255,307] address:"https://www.anibullet.com/"

-----------------------------------------------------------------------------
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
-------------------------------------↑ 文件排序方法 -------------------------------
	
	fn fnRefreshAddress =
	(
		if (iniLastRefFolder.dir != "") then edtBrowseFolder.text = iniLastRefFolder.dir
        else (edtBrowseFolder.text = "（打开目录）")
    )
    
    fn fnRefreshFilterItems =
	(
		local arrRefTempItems = #()
        if iniFilterRefName.count != 0 then
		(
            for i = iniFilterRefName.count to 1 by -1 do
            (
                append arrRefTempItems iniFilterRefName[i]
            )
        )
        rolRefTools.ltbFilterPrefix.items = arrRefTempItems
	)
	
	fn fnRefreshList strFilesDir =
	(
		arrAllRefFiles   = #()
		arrAllRefFolders = #()

		local arrFoldersName       = #()
		local arrFilesName         = #()
		local tempType             = #()
		local arrFilesBeforeFilter = #()

		case of 
		(
			(rdoFileType.state == 1):(tempType = typePic)
			(rdoFileType.state == 2):(tempType = typeGif)
			(rdoFileType.state == 3):(tempType = typeVideo)
			(rdoFileType.state == 4):(tempType = typePic)
			default:tempType = #(".*")
		)
		
		if strFilesDir != undefined then 
		(
			if ((strFilesDir != "") and (doesDirectoryExist strFilesDir)) then
			(
				local tempDir = GetDirectories (strFilesDir + "/*")
				for i in tempDir do 
				(
					append arrAllRefFolders (substring i 1 (i.count-1))
				)
				qsort arrAllRefFolders fnPseudoNaturalSort
				for t in tempType do
					(arrFilesBeforeFilter += getFiles (strFilesDir + @"\\*" + t))
				qsort arrFilesBeforeFilter fnPseudoNaturalSort
				if (rolRefTools.ltbFilterPrefix.selected != undefined) then
				(
					for i in arrFilesBeforeFilter do 
					(
						if (matchpattern (getfilenamefile i) \
						pattern:("*" + rolRefTools.ltbFilterPrefix.selected + "*")) then 
						(append arrAllRefFiles i)
					)
				)
				else 
				(
					if (rolRefTools.edtFilterStr.text == "") then
						(arrAllRefFiles = arrFilesBeforeFilter)
				)
				if (rolRefTools.edtFilterStr.text != "") then
				(
					searchStr = "*" + rolRefTools.edtFilterStr.text + "*"
					for i in arrFilesBeforeFilter do 
					(
						if (matchpattern (getfilenamefile i) \
						pattern:searchStr) then (append arrAllRefFiles i)
					)
				)
				else 
				(
					if (rolRefTools.ltbFilterPrefix.selected == undefined) then
						(arrAllRefFiles = arrFilesBeforeFilter)
				)
				
				for c in arrAllRefFolders where (arrAllRefFolders.count != 0) do  --获取文件夹名字,后面切换脚本类别和列表会用到
				(
					if(c != undefined) then \
					(append arrFoldersName ("📂 " + (getFilenameFile c)))
				)
				for c in arrAllRefFiles where (arrAllRefFiles.count != 0) do  --获取文件名字,后面切换脚本类别和列表会用到
				(
					if(c != undefined) then \
					(append arrFilesName ("📄 " + (filenameFromPath c)))
				)
				rolRefTools.ltbFilesList.items = arrFoldersName + arrFilesName
				rolRefTools.edtBrowseFolder.text = strFilesDir
			)
		)
		else messagebox "-------------------------------------\r\n文件夹可能已不存在\r\n\r\n请尝试刷新\r\n\r\n-------------------------------------"
		lblCountTips.text = "文件：" + arrAllRefFiles.count as string
		return rolRefTools.ltbFilesList.items
	)

	fn fnGetLastFolder strFolder =
	(
		local strLastFolder = ""
		if ((strFolder != "") and (doesDirectoryExist strFolder)) then
		(
			local arrFilterStr = filterstring strFolder @"\"
			for i = 1 to (arrFilterStr.count - 1) do (strLastFolder = strLastFolder  + arrFilterStr[i] + @"\\")
		)
		if (strLastFolder == "") then strLastFolder = strFolder
		return strLastFolder
	)

	fn fnOpenRefDir =
	(
		str = ""
		str += "tempAddFolderID	= \"" + tempAddFolderID + "\""
		str += "\r\ntry(destroydialog rolAddRefFolder)catch()\r\n"
		str += "createDialog rolAddRefFolder pos:mouse.screenpos"
		execute str
	)

	fn fnFreshRefDirText =
	(
		if (iniRefFolder1.name != "") then (btnRefDir1.text = iniRefFolder1.name) else (btnRefDir1.text = "<＋＋＋>")
		if (iniRefFolder2.name != "") then (btnRefDir2.text = iniRefFolder2.name) else (btnRefDir2.text = "<＋＋＋>")
		if (iniRefFolder3.name != "") then (btnRefDir3.text = iniRefFolder3.name) else (btnRefDir3.text = "<＋＋＋>")
		if (iniRefFolder4.name != "") then (btnRefDir4.text = iniRefFolder4.name) else (btnRefDir4.text = "<＋＋＋>")
	)

	fn fnRefreshDate =
	(
		local arrTime = (getLocalTime())
		local dayWeekID = (mod arrTime[3] 7) as integer
		lblDateTime.text = dateTime.Year as string + "/" + dateTime.Month as string + "/" \
		+ dateTime.Day as string + "  星期" + arrDayWeek[dayWeekID + 1] as string
	)

	on rolRefTools rbuttondown pos do 
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder
	)

    on rolRefTools open do 
    (
        btnRefreshFolder.images  = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,3,3,3,3,true,false)
        btnOpenCurrentDir.images = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,5,5,5,5,true,false)
		btnLastFolder.images     = #("MergeAnim_24i.bmp","MergeAnim_24i.bmp",4,1,1,1,1,false,true)
        stLoadConfigAll.fnLoadConfigBsRefTools ()  ---------------脚本位置等赋值
		stSetConfigAll.fnSetConfigBsRefTools ()  ----------------保存位置信息到ini文件
		fnRefreshFilterItems ()
		fnFreshRefDirText ()
		fnRefreshList iniLastRefFolder.dir
        ltbFilterPrefix.selection = 0
        fnRefreshDate ()
		-- RCmenuRefConfig.fnCheckVersion ()
    )

    on rolRefTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosRefTools   = (GetDialogPos rolRefTools)
		iniLastRefFolder.dir = edtBrowseFolder.text
		stSetConfigAll.fnSetConfigBsRefTools ()
	)
------------------------------------------------------------------------
	on btnRefDir1 pressed do 
	(
		tempAddFolderID = "1"
		if ((iniRefFolder1.dir != "") and ( iniRefFolder1.dir != undefined)) then (fnRefreshList iniRefFolder1.dir)
		else(fnOpenRefDir ())
	)

	on btnRefDir2 pressed do 
	(
		tempAddFolderID = "2"
		if ((iniRefFolder2.dir != "") and ( iniRefFolder2.dir != undefined)) then (fnRefreshList iniRefFolder2.dir)
		else(fnOpenRefDir ())
	)

	on btnRefDir3 pressed do 
	(
		tempAddFolderID = "3"
		if ((iniRefFolder3.dir != "") and ( iniRefFolder3.dir != undefined)) then (fnRefreshList iniRefFolder3.dir)
		else(fnOpenRefDir ())
	)

	on btnRefDir4 pressed do 
	(
		tempAddFolderID = "4"
		if ((iniRefFolder4.dir != "") and ( iniRefFolder4.dir != undefined)) then (fnRefreshList iniRefFolder4.dir)
		else(fnOpenRefDir ())
	)

	on btnRefDir1 rightclick do (tempAddFolderID = "1";fnOpenRefDir ())

	on btnRefDir2 rightclick do (tempAddFolderID = "2";fnOpenRefDir ())

	on btnRefDir3 rightclick do (tempAddFolderID = "3";fnOpenRefDir ())

	on btnRefDir4 rightclick do (tempAddFolderID = "4";fnOpenRefDir ())

	on btnRefreshFolder pressed do fnRefreshList edtBrowseFolder.text

	on btnLastFolder pressed do 
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder
	)

	on btnTempRefDir pressed do 
	(
		if (doesDirectoryExist tempSavePath == false) then
		(
			
			makeDir tempSavePath
			fnRefreshList tempSavePath
		)
		else fnRefreshList tempSavePath
	)

	on btnOpenAddress pressed do 
	(
		local dirOpened = ""
		dirOpened = getSavePath caption:"请选择参考文件夹路径:" initialDir:(maxFilePath)
		if (dirOpened != undefined) then
		(
			edtBrowseFolder.text = dirOpened
			fnRefreshList dirOpened
		)
	)

	on edtFilterStr changed textStr do 
	(
		rolRefTools.ltbFilterPrefix.selection = 0
		fnRefreshList edtBrowseFolder.text 
	)

	on btnFilterPrefix pressed do 
	(
		if edtFilterStr.text != "" then 
		(
			if (findItem iniFilterRefName edtFilterStr.text) != 0 then 
			(
				messagebox "-------------------------------------\r\n可能过滤词缀已存在~"
			)
			else
			(
				append iniFilterRefName edtFilterStr.text
				fnRefreshFilterItems ()
				rolRefTools.ltbFilterPrefix.selection = 1
			)
		)
	)

	on ltbFilterPrefix selected id do fnRefreshList edtBrowseFolder.text

	on ltbFilterPrefix rightclick id do
	(
		idDel = iniFilterRefName.count + 1 - id
		deleteItem iniFilterRefName idDel
		fnRefreshFilterItems ()
	)

	on ltbFilesList doubleClicked id do
	(
		if (doesDirectoryExist edtBrowseFolder.text) then
		(
			case of
			(
				((id <= arrAllRefFolders.count) and (id > 0)):
				(
					edtBrowseFolder.text = arrAllRefFolders[id]
					-- fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
				)
				(id > arrAllRefFolders.count):
				(
					local idFile = id - arrAllRefFolders.count
					case of 
					(
						(rdoFileType.state == 1):(fnCreateRefPlane arrAllRefFiles[idFile])
						(rdoFileType.state == 2):()
						(rdoFileType.state == 3):()
						(rdoFileType.state == 4):()
					)
				)
			)
			fnRefreshList edtBrowseFolder.text
		)
	)
	on ltbFilesList rightclick id do
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder
	)
)
if (iniPosRefTools != 0) then 
(Createdialog rolRefTools menu:RCmenuRefConfig fgcolor:myFgColor pos:iniPosRefTools)
else (Createdialog rolRefTools menu:RCmenuRefConfig fgcolor:myFgColor)
fnBsEnsureDialogVisible rolRefTools

------------------------toolbar----------------------------------------------------
macroScript BsRefTools
category:"_[BulletTools]"
buttonText:"BsRefTools"
toolTip:"参考工具"
(
	on execute do
	(
		fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BsRefTools.ms")
	)
)
----------------------------------------------------------------------------------