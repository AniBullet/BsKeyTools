struct stLangManager 
(
	fileDefaultLang = "ENG",
	strFileFormat = @".lng",	
	strLangPath = (getFileNamePath (getThisScriptFileName())) + "//Lang//",
	defaultFile = strLangPath + fileDefaultLang + strFileFormat,
	fileConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\""),
	fn fnGetLang strToolName = (		
		local strSetWord = getIniSetting fileConfig strToolName "LANG"			
		local fileLang = strLangPath + strSetWord + strFileFormat			
		if(strSetWord == "") do return defaultFile
			
		return fileLang
	),
	lang = fnGetLang(),
	fn fnTranslateStr strToolName strSetWord = (
		local fileLang = fnGetLang strToolName
		local o = getIniSetting fileLang strToolName strSetWord
		if(o == "") do return strSetWord
		
		o = substituteString o " || " "\n\n"
		o = substituteString o " | " "\n"
		return o
	),
	fn fnTranslateAll rolTarget = (
		for i in 1 to rolTarget.controls.count do (
			local ctrlFromRollout = rolTarget.controls[i]
			local isCaptionExist = ctrlFromRollout.caption[1] == "~"
			local isTextExist = try(ctrlFromRollout.text[1] == "~") catch(false)
			local isTagExist = try(ctrlFromRollout.tag[1] == "~") catch(false)
			
			if(isCaptionExist) do (
				ctrlFromRollout.caption = fnTranslateStr (ctrlFromRollout.caption)
			)
			if(isTextExist ) do (
				ctrlFromRollout.text = fnTranslateStr (ctrlFromRollout.text)
			)
			if(isTagExist) do (
				ctrlFromRollout.text = fnTranslateStr (ctrlFromRollout.tag)
			)
		)
	)
)