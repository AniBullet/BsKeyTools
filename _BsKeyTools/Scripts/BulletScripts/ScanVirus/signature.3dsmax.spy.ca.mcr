/*
[INFO] 

NAME = signature.3dsmax.spy.ca
VERSION = 1.0.0
AUTHOR = MastaMan
DEV = 3DGROUND
SITE=http://3dground.net

[SCRIPT]

*/

(
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
    
    struct signature_3dsmax_spy_ca (
        name = "[3dsmax.Spy.CA]",
        signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),
        detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
        find_ca_name = #(#Sound_GrayDeskUnderFourOldDriverGoPlane),
        bad_text = #("*safeSceneScriptExecutionEnabled*", "*System.Convert*"),
        
        slog = signature_log(),

        fn pattern v p = (
            return matchPattern (toLower (v as string)) pattern: (toLower (p as string))
        ),
            
        fn detect = (
			for i in custAttributes.getSceneDefs() do (					
				local id = try (findItem find_ca_name i.name) catch (0)
				if (id != 0) do return true
				
				local s = custAttributes.getDefSource  i
				
				for b in bad_text do (
					if (pattern s b) do return true
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
        
        fn removeCA names bad_text = (
            for nn in names do (
                for i in custattributes.getSceneDefs() do (
					local s = custAttributes.getDefSource i
					local isFoundBadText = false
					for b in bad_text do (
						if (pattern s b) do isFoundBadText = true
					)
					
					if (pattern i.name nn or isFoundBadText) do (						
						for ii in custAttributes.getDefInstances i do (							
							for o in refs.dependents ii do (
								custAttributes.delete o (custAttributes.getDef o 1)
							)
							try(custAttributes.deleteDef ii) catch()
						)
						
						try(custAttributes.deleteDef i) catch()
						
						local nn = "attributes \"Prune Scene Cleared Attribute\" (\n)"
						try (custAttributes.redefine i nn) catch ()						
					)
                )
            )
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
			   
            removeCA find_ca_name bad_text
			
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
    
    local signature = signature_3dsmax_spy_ca()
    signature.run()
)



