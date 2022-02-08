-- CRP persistent global variable and callback removal script
-- version 1.0 - initial version of script
-- version 1.1 - added automated removal of CRP lines from startup script files
-- version 1.2 - when remove global variables also need to remove them from peristents

::CRP_Authorization = true -- turns off changes to scene by CRP script

fn test_for_CRP_in_startup_scripts =
(
	format "Testing for CRP in startup scripts\n"
	local startup_scripts = getfiles ((getDir #startupScripts) + @"\*.ms")
	local infected_startup_scripts = #()
	local searchFor = " CRP_AScript" + " = \""
	local searchFor_length = searchFor.count
	local terminatingString = " setINISetting  (getMAXIniFile()) \" MAXScript \" \" LoadSavePersistentGlobals \" \" 1 \"  "
	local terminatingStringOffset = 67
	for sf in startup_scripts do
	(
		local f = openfile sf
		local found_CRP = (skipToString f searchFor) != undefined
		close f
		if found_CRP do 
			append infected_startup_scripts sf
	)
	if (infected_startup_scripts.count != 0) do
	(
		local msg = "CRP global variables found in following startup scripts: "
		for fname in infected_startup_scripts do
			logsystem.logentry (msg + fname) warning:true
		msg = "CRP global variables found in following startup scripts.\n"
		msg += "Remove CRP-related lines from these files?\n"
		for fname in infected_startup_scripts do
			msg += ("  " + fname + "\n")
		local res = true
		if (not GetQuietMode()) do
			res = queryBox msg title:"CRP Scripts Found"
		if res do
		(
			-- collect files where there were errors processing the file
			local error_processing_file = #()
			-- remove the CRP related lines from the files, creating backup of each file
			for fname in infected_startup_scripts do
			(
				local f = undefined
				try f = openfile fname mode:"r"  -- try to open with read access....
				catch ()
				if f == undefined do
				(
					format "Warning: Unable to open file with read access: %\n" fname
					append error_processing_file fname
					continue
				)
				local fileContents = #()
				while not eof f do append fileContents (readline f)
				local startline = undefined
				for i = 1 to fileContents.count while (startline == undefined) do
				(
					local line = fileContents[i]
					if (substring line 1 searchFor_length) == searchFor do 
						startline = i
				)
				if startline == undefined do
				(
					format "Warning: Could not find beginning of CRP contents for file: %\n" fname
					append error_processing_file fname
					close f
					continue
				)
				local terminatingStringLine = startline+terminatingStringOffset
				if (terminatingStringLine > fileContents.count or fileContents[terminatingStringLine] != terminatingString) do
				(
					format "Warning: Could not find end of CRP contents for file: %\n" fname
					append error_processing_file fname
					close f
					continue
				)
				copyfile fname (fname + ".backup")
				-- reopen file with write access, delete contents
				close f
				f = undefined
				try f = openfile fname mode:"wt"  -- try to open with write access....
				catch ()
				if f == undefined do
				(
					format "Warning: Unable to open file with write access: %\n" fname
					append error_processing_file fname
					continue
				)
				for i = 1 to fileContents.count where (i < startline or i > terminatingStringLine) do
				(
					format "%\n" fileContents[i] to: f
				)
				close f
				format "Cleaned CRP-related lines from: %\n" fname
				logsystem.logentry ("Cleaned CRP-related lines from: " + fname) info:true
			)
			msg = "Unable to clean CRP-related lines from: "
			for fname in error_processing_file do
				logsystem.logentry (msg + fname) warning:true
			msg = "Cleaned " + (infected_startup_scripts.count - error_processing_file.count) as string + " of " + infected_startup_scripts.count as string + " files containing CRP-related lines\n"
			if error_processing_file.count != 0 then
				msg += "Recommend close 3ds Max, review and manually clean the script files that could not be cleaned, and restart 3ds Max."
			else
				msg += "Recommend close and restart 3ds Max."
			MessageBox msg title:"CRP Script File Processing"
		)
	)
)

fn test_for_CRP_globals =
(
	format "Testing for CRP persistent globals and callbacks\n"
	callbacks.removeScripts #animationRangeChange  id:#fix_CRP_startup
--	print "=========================================================================================================="
--	callbacks.show()
--	persistents.show()
--	print "=========================================================================================================="
	local the_CRP_globals = #(#CRP_AScript, #CRP_BScript, #CRP_WriteAScript, #CRP_WriteBScript)
	local found_CRP_global = false
	for g in the_CRP_globals while (not found_CRP_global) do found_CRP_global = globalVars.isGlobal g
	if found_CRP_global do
	(
		format "found CRP global variable(s). The following is a list of the CRP callbacks found:\n"
		local logFileName = @"$temp\CRP_callbacks.txt"
		openLog logFileName mode: "w" outputOnly:true
		local the_CRP_callback_ids = #(#ID_CRP_preRenderP, #ID_CRP_filePostOpenP, #ID_CRP_viewportChangeP, #ID_CRP_filePostOpen, #ID_CRP_filePostMerge, #ID_CRP_postImport)
		for id in the_CRP_callback_ids do
			callbacks.show id:id 		
		closelog()
		local found_CRP_callbacks = false
		local f = openfile logFileName
		while not eof f and not found_CRP_callbacks do
		(
			local l = readline f
			if l != "OK" do found_CRP_callbacks = true
		)
		close f
		deletefile logFileName
		local msg = "CRP global variables found.\nCRP callbacks "
		if not found_CRP_callbacks do msg += "not "
		msg += "found.\nThe presence of these global variables and callbacks\n"
		msg += "will cause data loss and improper operation of 3ds Max.\n"
		if found_CRP_callbacks do 
			msg += "The callbacks may have already resulted in all\nscene lights having been deleted.\n"
		msg += "\nRemove CRP global variables and callbacks?"
		local res = true
		if (not GetQuietMode()) do
			res = queryBox msg title:"CRP Callbacks Found"
		if res do
		(
			-- remove the callbacks
			for id in the_CRP_callback_ids do
				callbacks.removeScripts id:id 		
			-- remove the globals
			for g in the_CRP_globals do 
			(
				if (persistents.isPersistent g) do
					persistents.remove g
				globalVars.remove g
			)
			format "CRP global variables and callbacks removed\n"
		)
	)
)

fn test_for_CRP =
(
	test_for_CRP_globals()
	test_for_CRP_in_startup_scripts()
	ok
)

test_for_CRP()

callbacks.removeScripts id:#fix_CRP
callbacks.removeScripts id:#fix_CRP_startup
 -- #animationRangeChange notification fired after loading mxs persistents, but before the #filePostOpen notification is fired
callbacks.addScript #animationRangeChange "test_for_CRP_globals()" id:#fix_CRP
callbacks.addScript #mtlLibPostOpen "test_for_CRP_globals()" id:#fix_CRP_startup -- ensures run at least once at startup
callbacks.addScript #filePostMerge "test_for_CRP_globals()" id:#fix_CRP
