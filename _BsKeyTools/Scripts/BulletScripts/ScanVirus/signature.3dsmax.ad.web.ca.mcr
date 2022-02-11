/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-02-11 18:58:12
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
    struct signature_3dsmax_ad_web_ca (
        name = "[AD.3dsmax.Web.CA]",
        signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),
        detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
        find_ca_name = #(#example, #example1),
        bad_text = #("3dsmj.com", "3d.znzmo.com"),

        fn pattern v p = (
            return matchPattern (toLower (v as string)) pattern: (toLower (p as string))
        ),
            
        fn detect = (
            w = #(rootScene, rootNode)
            cc = 0
            for i in w do cc += custAttributes.count i
            if(cc == 0) do return false
            
            for f in w do (
                c = custAttributes.count f
                for i in 1 to c do (
                    local ca = custAttributes.getDef f 1
                    if(findItem find_ca_name ca.name != 0) do (
                        return true
                    )
                )
            )
            
            return false
        ),
        
        fn forceDelFile f = (
            try(setFileAttribute f #readOnly false
            deleteFile f) catch()
        ), 
            
        fn dispose = (
            for i in 1 to detect_events.count do (
                id = i as string
                execute ("callbacks.removeScripts id: #" + signature + id)
            )
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
        
        fn removeText txt = (
            toDelete = #()
            for i in objects where classOf i == Text and not isDeleted i and isValidNode i do (
                for t in txt where (findString i.text t) != undefined do append toDelete i
            )
            
            try(delete toDelete) catch()
        ),
        
        fn run = (
			displayTempPrompt  ("安全！未检测到病毒！") 10000
			
            for i in 1 to detect_events.count do (
                id = i as string
                f = substituteString (getThisScriptFileName()) @"\" @"\\"
                                                
                execute ("callbacks.removeScripts id: #" + signature + id)
                execute ("callbacks.addScript #" + detect_events[i] as string + "  \" (fileIn @\\\"" + f + "\\\")  \" id: #" + signature + id)
            )
            
            if(detect() == false) do (
                return false
            )
            
            removeCA find_ca_name
            removeText bad_text
        
			notification = "病毒已检测到并删除完成！"			
			displayTempPrompt  (name + " "  + notification) 10000
        )
    )
    
    local signature = signature_3dsmax_ad_web_ca()
    signature.run()
)