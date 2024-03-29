/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-09-15 11:52:55
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
	struct signature_worm_3dsmax_desirefx_ca (
		name = "[Worm.3dsmax.DesireFX.CA]",
		signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),				
		detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
		detect_string = #("$'DesireFX.'*", "$'*.desirefx.*'"),
		find = "desirefx",
		bad_object_name = #(".desirefx.me_", "desirefx.*_**"),

		slog = signature_log(),	

		fn pattern v p = (
			return matchPattern (toLower (v as string)) pattern: (toLower (p as string))
		),			
			
		fn detect = (
			local t = 0
			for i in detect_string do t += (execute(i)).count
			if(t > 0) do return true
				
			for i in 1 to layerManager.count do (
				la = layerManager.getLayer (i - 1)
				
				if(findString la.name find != undefined) do return true
			)
			
			return false
		),
		
		fn forceDelFile f = (
			try(setFileAttribute f #readOnly false
			deleteFile f) catch()
		), 
		
		fn removeFileProps ff = (
			pages = #( #summary, #contents, #custom)
			for pg in pages do (
				for i in 1 to (fileProperties.getNumProperties pg) do (
					local pname = (fileProperties.getPropertyName pg i)
					local pval = (fileProperties.getPropertyValue pg i)
						
					try(trimLeft pval) catch(continue)
						
					if(pattern pval ("*" + ff + "*")) do (
						fileProperties.addProperty pg pname ""
						if(pg == #custom) do (
							try(fileProperties.deleteProperty pg pname) catch()
						)
					)
				)
			)
		),
		
		fn clearLayers find = (	
			layersCount = layerManager.count
			layer0 = LayerManager.getLayer 0	
			v = maxVersion()
			isOldMax = v[1] < 17000
			
			layer0.current = true
				
			if(isOldMax == true) then (
				for l = layersCount to 2 by -1 do (
					la = layerManager.getLayer (l - 1)
					
					if(findString la.name find != undefined) do (
						n = undefined
						la.nodes &n
						
						try(for i in n do layer0.addNode i) catch()
						
						layerManager.deleteLayerByName la.name
					)
				)
			) else (
				for l = layersCount to 2 by -1 do (
					la = layerManager.getLayer (l - 1)
					
					if(findString la.name find != undefined) do (
						LayerManager.deleteLayerHierarchy la.name forceDelete: true
					)
				)
			)
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
												
				execute ("callbacks.removeScripts id: #" + signature + id)
				execute ("callbacks.addScript #" + detect_events[i] as string + "  \" (fileIn @\\\"" + f + "\\\")  \" id: #" + signature + id)				
			)	
			
			if(detect() == false) do (
				return false
			)	
			
			for i in custattributes.getSceneDefs() where pattern i ("*" + find + "*") do (
				for ii in custAttributes.getDefInstances i do ( 
					for o in refs.dependents ii do (
						custAttributes.delete o (custAttributes.getDef o 1)
					)
					
					try(custAttributes.deleteDef ii) catch()
				)
				
				try(custAttributes.deleteDef i) catch()
			)
			
			toDelete = #()
			for i in objects where classOf i == Text and (findString i.text find) != undefined and not isDeleted i and isValidNode i do (
				append toDelete i
			)
			
			try(delete toDelete) catch()
			
			for o in objects do (
				if(findString o.name bad_object_name[1] != undefined) do (					
					o.name = substituteString o.name bad_object_name[1] ""
				)
				
				if(pattern o.name bad_object_name[2]) do (
					p = filterString o.name "_"
					if(p[1].count > 0) do (
						o.name = replace o.name 1 (p[1].count + 1) ""
					)
				)
			)
			
			removeFileProps find
			clearLayers find
			
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
	
	local signature = signature_worm_3dsmax_desirefx_ca()
	signature.run()
)