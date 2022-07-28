/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-07-29 01:18:34
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
	struct signature_worm_3dsmax_crp_bscript (
		name = "[Worm.3dsmax.CRP.Bscript]",
		signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),				
		detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
		detect_string = "BScript",
		find = "execute CRP_BScript",
		find_file = "CRP_AScript = \"",
		remove_events = #(#ID_CRP_filePostOpen, #ID_CRP_filePostMerge, #ID_CRP_postImport, #ID_CRP_preRenderP, #ID_CRP_filePostOpenP, #ID_CRP_viewportChangeP),
		remove_globals = #(#CRP_BScript, #CRP_AScript, #CRP_WriteAScript),	
			
		slog = signature_log(),	

		fn detect = (
			s = "" as stringStream
			
			apropos detect_string to: s
			
			ms = MemStreamMgr.openString s
			size = ms.size()
			MemStreamMgr.close ms

			free s
			close s
					
			return size > 2400
		),
		
		fn forceDelFile f = (
			try(setFileAttribute f #readOnly false
			deleteFile f) catch()
		), 
		
		fn getInfectedFiles = (		
			
			dirs = #(#userStartupScripts, #startupScripts)
			files = #()
			
			for d in dirs do (
				ff = getFiles ((getDir d) + @"\*.ms")
				join files ff				
			)
						
			out = #()
			for f in files where getFileNameFile f != "0" do (				
				fs = openFile f
				if(fs == undefined) do (					
					try(close fs) catch()
					continue
				)
				if(skipToString  fs find != undefined) do append out f
				free fs
				close fs				
			)
						
			return out
		),
		
		fn createBlockFile = (
			d =  (getDir #startupScripts) + @"\"
			f = d + @"0.ms"
			try (
				fs = createFile f
				free fs
				close fs
				try(setFileAttribute f #readOnly true) catch()
			) catch()
		),
		
		fn protectFiles = (
			d =  (getDir #startupScripts) + @"\"
						
			for ff in getFiles (d + "*.ms") do try(setFileAttribute ff #readOnly true) catch()
		),
		
		fn fixInfectedFiles list = (
				verbose_level = slog.getVerboseLevel()

				if(verbose_level == 1 or verbose_level == 2) do (
					m = ("在以下文件中发现了CRP Bscript病毒！您要修复这些文件吗？") + "\n\n" 
					for f in list do m += f + "\n"
					q = queryBox m title: "Confirm?"
					if(not q) do return false
				)
				
				for f in list do
				(
					try (
						copyFile f (f + ".bak")
						
						content = ""
						
						try(setFileAttribute f #readOnly false) catch()
						fs = openFile f
						if(fs == undefined) do (
							try(close fs) catch()
							continue
						)
						
						seek fs 0
						exist = (skipToString fs find_file) != undefined
						
						if(exist) do (						
							pos = filePos fs
							seek fs 0
							content = readChars fs (pos - find_file.count)										
						)
						
						free fs
						close fs
						
						if(exist) do (
							if(deleteFile f) do (
								fs2 = createFile f
								
								format "%" content  to: fs2
								free fs2
								close fs2
							)					
						)
						
						try(setFileAttribute f #readOnly true) catch()
					) catch()
				)
				
			infectedFiles = getInfectedFiles()
				
			if(infectedFiles.count > 0 ) do (
				if(verbose_level == 1 or verbose_level == 2) do (
					m = ("以下文件尚未修复！要手动修复它们吗？") + "\n\n"
					for f in infectedFiles do m += f + "\n"
					
					q = queryBox m title: "Confirm?"
					if(not q) do return false
				
					shellLaunch ((getDir #startupScripts)) ""
				)
				if(verbose_level == 1 or verbose_level == 3) do (
					msg = name + "病毒已删除但没有从脚本自启文件夹移除!                                       " type: #warn
					slog.write msg
				)
				
				return false
			)
            if(verbose_level == 1 or verbose_level == 2) do (
				notification = "病毒已检测到并删除完成！请注意另存文件！                                                                      "
				messageBox (name + " "  + notification) title: "Notification!"
			)

			if(verbose_level == 1 or verbose_level == 3) do (
				msg = name + " 病毒已从下面路径移除： \"" + (maxFilePath + maxFileName) + "\""
				slog.write msg
			)

			return true
		),

		fn dispose = (
			for i in 1 to detect_events.count do (
				id = i as string				
				execute ("callbacks.removeScripts id: #" + signature + id)								
			)	
		),
		
		fn clr = (						
			for v in remove_globals do (
				try(if(persistents.isPersistent v) do persistents.remove v) catch()
				try(globalVars.remove v) catch()
			)
			
			for ev in remove_events do try(callbacks.removeScripts id: ev) catch()
					
			
			infectedFiles = getInfectedFiles()
			if(infectedFiles.count != 0) do  out = fixInfectedFiles(infectedFiles)
			
			protect_files = false
			if(protect_files) do protectFiles()
			
			return out
		),
		
		fn run = (	
			
			::CRP_Authorization = true				
			
			for i in 1 to detect_events.count do (
				id = i as string
				f = substituteString (getThisScriptFileName()) @"\" @"\\"
												
				execute ("callbacks.removeScripts id: #" + signature + id)
				execute ("callbacks.addScript #" + detect_events[i] as string + "  \" (fileIn @\\\"" + f + "\\\")  \" id: #" + signature)				
			)	
					
			status = false						
			status = clr()	
			createBlockFile()
			
			if(detect()) do (
				notification = "病毒已检测到并删除完成！请注意另存文件！                                                                      "			
				displayTempPrompt  (name + " "  + notification) 10000
			)				
		)
	)
	
	local signature = signature_worm_3dsmax_crp_bscript()
	signature.run()
)