/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-02-11 19:00:17
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
				execute ("callbacks.addScript #" + detect_events[i] as string + "  \" (fileIn @\\\"" + f + "\\\")  \" id: #" + signature + id)				
			)	
				
			
			if(detect() == false) do (												
				return false
			)
						
			for f in getInfectedFiles() do deleteFile f
				
			findAgain = getInfectedFiles()
			if(findAgain.count != 0) do (
				print "Files not deleted! Please delete manually next files:"
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
			
			notification = "病毒已检测到并删除完成！"			
			displayTempPrompt  (name + " "  + notification) 10000

			messageBox (name + " "  + notification) title: "Notification!"

		)
	)
	
	local signature = signature_worm_3dsmax_alc_clb()
	signature.run()
)