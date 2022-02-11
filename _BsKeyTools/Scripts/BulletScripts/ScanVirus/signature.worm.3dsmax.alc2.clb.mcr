/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-02-11 19:00:44
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

(
	struct signature_worm_3dsmax_alc2_clb (
		name = "[Worm.3dsmax.ALC2.clb]",
		signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),					
		detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
		bad_variations = #("*cleanalpha*"),
		bad_names = #("RenderDialogSign", "", "", "", "×þ×ü", "¡¡×ý×û", "Rectangles135","×ú×ú","×þ×ú", "\x3000\xe813\xe811", "\xe814\xe812"),
		bad_files = #("vrdematclean*", "vrdestermatc*", "vrayimportinfo*"),
		bad_events = #(#RenderLicAlpha, #PhysXAlphaRBKSysInfo, #AutodeskLicAlpha, #RenderLicCleanAlpha, #PhysXCleanAlphaRBKSysInfo, #AutodeskLicCleanAlpha),
		bad_globals = #(#px_HiddenNodeCleanAlpha, #getNetUpdateCleanAlpha, #AutodeskLicSerStuckCleanAlpha, #px_SimulatorForModifyCleanAlpha, #px_SimulatorForStateCleanAlpha, #px_SimulatorSaveCleanAlpha, #physXCrtRbkInfoCleanAlpha, #checkLicSerSubCleanAlpha, #checkLicSerMainCleanAlpha, #CleanAlphabaseCC64enc, #CleanAlphabaseCC64dec, #runMainCleanAlpha, #PointNodeCleanAlpha),
		bad_functions = #(#px_SimulatorSaveCleanAlpha, #px_SimulatorForStateCleanAlpha, #px_SimulatorForModifyCleanAlpha, #PointNodeCleanAlpha, #checkLicSerSubCleanAlpha, #checkLicSerMainCleanAlpha, #CleanAlphabaseCC64enc, #CleanAlphabaseCC64dec, #runMainCleanAlpha, #px_SimulatorCbaCleanAlpha, #px_HiddenNodeCleanAlpha, #getNetUpdateCleanAlpha, #AutodeskLicSerStuckCleanAlpha),	
			
		fn pattern v p = (
			return matchPattern (toLower (v as string)) pattern: (toLower (p as string))
		),
		
		fn findIn a1 a2 = (
			out = #()
			
			for x in a1 do (
				for y in a2 where (pattern x y) do append out x
			)
			
			return out
		),
		
		fn getGlobals =
		(
			vars = globalVars.gather()	
			
			return findIn vars bad_variations
		),
			
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
		
		fn forceDelFile f = (
			try(setFileAttribute f #readOnly false) catch()
			return deleteFile (pathConfig.resolvePathSymbols f)
		), 
		
		fn getInfectedFiles = (
			dirs = #(#userStartupScripts, #startupScripts)
			out = #()
			files = #()
			for d in dirs do (		
				join files (getFiles ((getDir d) + @"\*.*"))
			)
			
			for f in files do (
				for bf in bad_files where (pattern (getFilenameFile f) bf) do append out f
			)
			
			return out
		),
		
		fn removeGlob a = (
			if(a == undefined) do return false
			
			for gg in a do (
				try(if(persistents.isPersistent gg) do persistents.remove gg) catch()
				try(globalVars.remove gg) catch()
			)
			
			return true
		),
		
		fn removeFunc a = (
			if(a == undefined) do return false
			
			for f in a do (
				execute ("fn " + (f as string) + "=(print \"Action \"" + (f as string) + "\" blocked by PruneScene!\")")
			)
			
			return true
		),
		
		fn removeHelpers = (
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
		),

		fn dispose = (
			for i in 1 to detect_events.count do (
				id = i as string				
				execute ("callbacks.removeScripts id: #" + signature + id)								
			)	
		),
		
		fn register = (
			for i in 1 to detect_events.count do (
				id = i as string
				f = substituteString (getThisScriptFileName()) @"\" @"\\"
												
				execute ("callbacks.removeScripts id: #" + signature + id)
				execute ("callbacks.addScript #" + detect_events[i] as string + "  \" (fileIn @\\\"" + f + "\\\")  \" id: #" + signature + id)				
			)				
		),
		
		fn run = (				
			register()
			if(detect() == false) do (												
				return false
			)
			
			for f in getInfectedFiles() do forceDelFile f
			
			findAgain = getInfectedFiles()
			if(findAgain.count != 0) do (
				print "Files not deleted! Please delete manually next files:"
				for f in findAgain do print f		
			)
			
			for ev in bad_events do try(callbacks.removeScripts id: ev) catch()
			
			removeFunc bad_functions
			removeGlob bad_globals
			removeGlob (getGlobals())				
			removeHelpers()
				
			ini = ((getDir #plugcfg) + @"\ExplorerConfig\SceneExplorer\DefaultModalSceneExplorer.ini")
			setIniSetting ini "Explorer" "Hidden" "true"
			setIniSetting ini "Explorer" "Frozen" "true"
			
			try(deleteFile ((getDir #renderassets) + @"\DefaultRendererExplorer.ini")) catch()
			
			notification = "病毒已检测到并删除完成！"			
			displayTempPrompt  (name + " "  + notification) 10000
			
			messageBox (name + " "  + notification) title: "Notification!"
		)
	)
	
	local signature = signature_worm_3dsmax_alc2_clb()
	signature.run()
)