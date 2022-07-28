/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-07-29 01:18:20
 * @Email: animator.bullet@foxmail.com
 */
-- --ALC betaclenaer
-- (globalVars.isGlobal #AutodeskLicSerStuckCleanBeta)
-- --ADSL bscript
-- (globalVars.isGlobal #ADSL_BScript)
-- --CRP bscript
-- (globalVars.isGlobal #CRP_BScript)
-- --ALC2 alpha
-- (globalVars.isGlobal #AutodeskLicSerStuckCleanAlpha)
-- --PhysXPluginMfx
-- (globalVars.isGlobal #physXCrtRbkInfoCleanBeta)
-- --ALC3 alpha
-- (globalVars.isGlobal #AutodeskLicSerStuckAlpha)
-- --Alienbrains
-- (try(TrackViewNodes.TVProperty.PropParameterLocal.count >= 0) catch(false))
-- --Kryptik
-- ((try(TrackViewNodes.AnimLayerControlManager.AnimTracks.ParamName) catch(undefined)) != undefined)

/*
[INFO] 

AUTHOR = MastaMan
DEV = 3DGROUND
SITE=http://3dground.net
MODIFY = Bullet.S
SITE = anibullet.com

[SCRIPT]

*/
struct signature_log (
	fn getLogFile = (
		d = execute ("@\"" + (getDir #maxData) + "\\scanlog.ini\"")
		return d
	), 
	
	fn getVerboseLevel = (
		ini = getLogFile()
		v = getIniSetting ini "SETTINGS" "VERBOSELEVEL"
		if(v == "") do return 1
		return try(v as integer) catch(1)
	),
	
	fn setVerboseLevel lvl = (
		ini = getLogFile()
		setIniSetting ini "SETTINGS" "VERBOSELEVEL" (lvl as string)
	),
	
	fn getLogType type = (
		return case type of (
			#threat: "Threat"
			#warn: "Warning"
			default: "Default"
		)
	),
	
	fn getTime = (
		t = #()
		for i in getLocalTime() do (
			s = (i as string)
			if(s.count < 2) do s = "0" + s
			append t s
		)
		
		return t[4] + "." + t[2] + "." + t[1] + " " + t[5] + ":" + t[6] + ":" + t[7]
	),
	
	fn write msg type: #threat = (
		ini = getLogFile()
		
		s = getLogType type
		k = getTime()
		
		setIniSetting ini s k msg
	),
	
	fn get type: #threat = (
		ini = getLogFile()
		s = getLogType type
		
		out = #()
		
		for i in (getIniSetting ini s) do (
			tmp = #()
			tmp[1] = i
			tmp[2] = s
			tmp[3] = (getIniSetting ini s i)
			append out tmp
		)
		
		return out
	),
	
	fn getAll = (
		out = #()
		ini = getLogFile()
		
		for i in (getIniSetting ini) where i != "SETTINGS" do (
							
			for ii in (getIniSetting ini i) do (
				tmp = #()
				tmp[1] = ii
				tmp[2] = i
				tmp[3] = (getIniSetting ini i ii)

				append out tmp
			)
		)
		
		return out
	),
	
	fn clearAll = (
		out = #()
		ini = getLogFile()
		
		for i in (getIniSetting ini) where i != "SETTINGS" do (
			delIniSetting ini i
		)
	)
)

(
	struct signature_worm_3dsmax_alc_clb (
		name = "[Worm.3dsmax.ALC.clb]",
		signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),		
		find = "cleanbeta",
		detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
		bad_names = #("×þ×ü", "¡¡×ý×û", "Rectangles135","×ú×ú","×þ×ú", "\x3000\xe813\xe811", "\xe814\xe812"),
		fn getGlobals =
		(
			vars = globalVars.gather()	
			found = for v in vars where (findString (toLower (v as string)) find != undefined) collect v
		),

		slog = signature_log(),
			
		fn detect = (
			found = getGlobals()
			
			for h in helpers where classOf h == Point do (
				size = 0
				try(size = h.scale.controller.script.count) catch(size = 0)
				
				if(size > 4000) do return true
				
				for n in bad_names where h.name == n do return true
			)
			
						
			if(found == undefined) do return false
			return found.count != 0 
		),
		
		fn getInfectedFiles = (
			dirs = #(#userStartupScripts, #startupScripts)
			out = #()
			for d in dirs do 
			(		
				files = getFiles ((getDir d) + @"\*.*")
				for f in files where (findString (toLower f) find != undefined) do append out f
			)
			
			return out
		),

		fn dispose = (
			for i in 1 to detect_events.count do (
				id = i as string				
				execute ("callbacks.removeScripts id: #" + signature + id)								
			)	
		),
		
		fn run = (	
			
			for i in 1 to detect_events.count do (
				id = i as string
				f = substituteString (getThisScriptFileName()) @"\" @"\\"
				--f = substituteString f @"\\\\" @"\\\\\\\\\"
								
				execute ("callbacks.removeScripts id: #" + signature + id)
				execute ("callbacks.addScript #" + detect_events[i] as string + "  \" (fileIn @\\\"" + f + "\\\")  \" id: #" + signature)				
			)	
				
			
			if(detect() == false) do (												
				return false
			)
						
			for f in getInfectedFiles() do deleteFile f
				
			findAgain = getInfectedFiles()
			if(findAgain.count != 0) do (
				print "文件没有被删除，请手动删除:											"
				for f in findAgain do print f		
			)
			
			events = #(#RenderLicCleanBeta,#PhysXCleanBetaRBKSysInfo, #AutodeskLicCleanBeta, #AutodeskLicences,#PhysXCreateRBKSysInfo,#RenderLicences,#AutodeskLicAlpha,#PhysXAlphaRBKSysInfo,#RenderLicAlpha,#AutodeskLicCleanAlpha,#PhysXCleanAlphaRBKSysInfo,#RenderLicCleanAlpha)	
			for ev in events do try(callbacks.removeScripts id: ev) catch()
			
			glob = #(#checkLicSerSubCleanBeta,  #CleanBetabaseCC64enc, #physXCrtRbkInfoCleanBeta, #CleanBetabaseCC64dec, #runMainCleanBeta, #PointNodeCleanBeta, #px_HiddenNodeCleanBeta, #getNetUpdateCleanBeta, #AutodeskLicSerStuckCleanBeta, #px_SimulatorForModifyCleanBeta, #checkLicSerMainCleanBeta, #px_SimulatorForStateCleanBeta, #px_SimulatorSaveCleanBeta)
			for gg in glob do (
				try(if(persistents.isPersistent gg) do persistents.remove gg) catch()
				try(globalVars.remove gg) catch()
			)
					
			toDelete = #()
			
			for o in (helpers as array) where not isDeleted o and classOf o == Point do
			(	
				size = 0
				try(size = o.scale.controller.script.count) catch(size = 0)
				
				isDel = false
				
				if(size > 4000) do isDel = true
				for n in bad_names where o.name == n do isDel = true
				
				if(isDel) do (
					try (o.name = uniqueName "_____alc") catch()
					append toDelete o
				)				
			)	
			
			try(delete toDelete) catch()
				
			ini = ((getDir #plugcfg) + @"\ExplorerConfig\SceneExplorer\DefaultModalSceneExplorer.ini")
			setIniSetting ini "Explorer" "Hidden" "true"
			setIniSetting ini "Explorer" "Frozen" "true"
			
			globals = getGlobals()			
			if(globals != undefined) do for g in globals do globalVars.remove g
			
			notification = "病毒已检测到并删除完成！请注意另存文件！                                                                      "			
			displayTempPrompt  (name + " "  + notification) 10000

			verbose_level = slog.getVerboseLevel()
			if(verbose_level == 1 or verbose_level == 2) do (
				messageBox (name + " "  + notification) title: "Notification!"
			)

			if(verbose_level == 1 or verbose_level == 3) do (
				msg = name + " 病毒已从下面路径移除： \"" + (maxFilePath + maxFileName) + "\""
				slog.write msg
			)
		)
	)
	
	local signature = signature_worm_3dsmax_alc_clb()
	signature.run()
)