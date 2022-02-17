(
	fn fnQuickSaveTempVer =
	(
		local nameCurrentFile = getFilenameFile maxFileName
		local arrTime = for i in (getLocalTime()) collect i as string
		local strNameSplit = "@Backup_"
		local fileSave = ""

		if (matchpattern nameCurrentFile pattern:("*" + strNameSplit + "*")) then
		(
			numSplitString = (findString (getFilenameFile maxFileName) "@Backup_")
			nameCurrentFile = replace nameCurrentFile numSplitString (nameCurrentFile.count - numSplitString + 1) ""
		)

		strNameSplit = strNameSplit + arrTime[2] + "_" + arrTime[4] + "_" + arrTime[5] + "h" + arrTime[6] + "m" + arrTime[7] + "s" + arrTime[8] + "ms"

		fileSave = maxFilePath + nameCurrentFile + strNameSplit + ".max"
		saveMaxFile fileSave
		messagebox ("已快速备份至：\r\n" + fileSave + "                                      ") 
	)

	if maxFilePath == "" then 
	(
		messagebox "------------------------------------\r\n当前场景未保存过,\r\n请先保存初始版本~"
		max file saveas
	)
	else fnQuickSaveTempVer ()
)