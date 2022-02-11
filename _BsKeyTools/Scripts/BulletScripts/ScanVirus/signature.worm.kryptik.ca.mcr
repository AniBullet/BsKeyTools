/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-02-11 19:02:58
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
	struct signature_worm_3dsmax_kryptik_ca (
		name = "[Worm.3dsmax.Kryptik.CA]",
		signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),				
		detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
		remove_events = #(#PtPreAc),
		remove_globals = #(#GetMultiLineTemp, #EditTriObjectPs, #GetResolute),
		find_ca_name = #("Anim Tracks", "Anim Tracks", "Anim Tracks", "Anim Tracks", "AnimTracks", #AnimTracks),
		remove_files = #(),
		
		fn pattern v p = (
			return matchPattern (toLower (v as string)) pattern: (toLower (p as string))
		),			
			
		fn detect = (
			return (try(TrackViewNodes.AnimLayerControlManager.AnimTracks.ParamName) catch(undefined)) != undefined
		),
		
		fn forceDelFile f = (
			try(setFileAttribute f #readOnly false) catch()
			return deleteFile (pathConfig.resolvePathSymbols f)
		), 
		
		fn getInfectedFiles = (
			dirs = #(#userStartupScripts, #startupScripts)
			out = #()
			for d in dirs do 
			(		
				files = getFiles ((getDir d) + @"\*.*")
				for find in remove_files do (
					for f in files where (findString (toLower f) (toLower find) != undefined) do append out f
				)
			)
			
			return out
		),
		
		fn removeGlobal g = (
			try(if(persistents.isPersistent g) do persistents.remove g) catch()
			try(globalVars.remove g) catch()
		),
		
		fn removeCA names = (
            for nn in names do (
                for i in custattributes.getSceneDefs() where pattern i.name nn do (
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
			
			for f in getInfectedFiles() do forceDelFile f
			for ev in remove_events do try(callbacks.removeScripts id: ev) catch()
			for g in remove_globals do removeGlobal g
				
			removeCA find_ca_name
			
			notification = simpleLngMgr.getTranslate "~SIGNATURE_DETECTED_AND_REMOVED~"			
			displayTempPrompt  (name + " "  + notification) 10000
			
			messageBox (name + " "  + notification) title: "Notification!"			
		)
	)
	
	local signature = signature_worm_3dsmax_kryptik_ca()
	signature.run()
)