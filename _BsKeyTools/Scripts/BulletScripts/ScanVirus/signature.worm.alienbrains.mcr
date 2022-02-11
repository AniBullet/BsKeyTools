/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-02-11 19:02:10
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
	struct signature_worm_alienbrains (
		name = "[Worm.3dsmax.alienbrains]",
		signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),				
		tempDir = sysInfo.tempDir,
		maxRoot = getDir #maxRoot,
		detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
		remove_ca = #("TVProperty", "NodeProperty"),
		remove_events = #(#PropertyParameters),
		remove_globals = #(#ThePropParameterNodes, #TheFilePropParameters),
		remove_files = #(tempDir + "Local_temp.ms", tempDir + "Local_temp.mse", maxRoot + @"\mscprop.dll", maxRoot + @"\stdplugs\PropertyParametersLocal.mse"),	
		
		fn pattern v p = (
			return matchPattern (toLower (v as string)) pattern: (toLower (p as string))
		),			
			
		fn detect = (
			try(TrackViewNodes.TVProperty.PropParameterLocal = "") catch(return false)
			return true
		),
		
		fn forceDelFile f = (
			try(setFileAttribute f #readOnly false) catch()
			return deleteFile (pathConfig.resolvePathSymbols f)
		), 
		
		fn removeGlobal g = (
			try(if(persistents.isPersistent g) do persistents.remove g) catch()
			try(globalVars.remove g) catch()
		),
		
		fn removeAttribs attrs: #() = (
			for attr in attrs do (
				for i in custattributes.getSceneDefs() where pattern i ("*" + attr + "*") do (			
					for ii in custAttributes.getDefInstances i do ( 
						for o in refs.dependents ii do (
							custAttributes.delete o (custAttributes.getDef o 1)
						)
						try(custAttributes.deleteDef ii) catch()
					)
					
					try(custAttributes.deleteDef i) catch()
				)
			)
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
			
			removeAttribs attrs: remove_ca
			for f in remove_files do forceDelFile f			
			for ev in remove_events do try(callbacks.removeScripts id: ev) catch()
			for g in remove_globals do removeGlobal g
					
			notification = "病毒已检测到并删除完成！"			
			displayTempPrompt  (name + " "  + notification) 10000
			
			messageBox (name + " "  + notification) title: "Notification!"
						
		)
	)
	
	local signature = signature_worm_alienbrains()
	signature.run()
)