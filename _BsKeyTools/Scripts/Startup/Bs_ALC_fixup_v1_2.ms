-- ALC persistent global variable and callback removal script
-- version 1.0
-- version 1.1 - remove #fix_ALC_startup callbacks when evaluated
-- version 1.2 - when remove global variables also need to remove them from peristents

fn test_for_ALC_startup_scripts =
(
	format "Testing for ALC startup scripts\n"
	local ALC_startup_scripts = #()
	local ALC_scripts = #(@"$userStartupScripts\vrdematcleanbeta.ms", @"$userStartupScripts\vrdematcleanbeta.mse", @"$userStartupScripts\vrdematcleanbeta.msex")
	for f in ALC_scripts do
	(
		if doesFileExist f do
			append ALC_startup_scripts (pathconfig.resolvePathSymbols  f)
	)
	if (ALC_startup_scripts.count != 0) do
	(
		local msg = "Following ALC startup scripts found.\n"
		msg += "Note that these files may have their Hidden and System file attributes set, and not be visible in Explorer.\n"
		for f in ALC_startup_scripts do
			msg += ("   " + f + "\n")
		msg += "\nRemove these files?"
		local res = true
		if (not GetQuietMode()) do
			res = queryBox msg title:"ALC Scripts Found"
		if res do
		(
			-- remove the files
			for f in ALC_startup_scripts do
				deleteFile f
			format "ALC scripts removed\n"
		)
	)
)

fn test_for_ALC_globals =
(
	format "Testing for ALC persistent globals and callbacks\n"
	callbacks.removeScripts #animationRangeChange  id:#fix_ALC_startup
--	print "=========================================================================================================="
--	callbacks.show()
--	persistents.show()
--	print "=========================================================================================================="
	local the_ALC_globals = #(#physXCrtRbkInfoCleanBeta, #checkLicSerSubCleanBeta, #checkLicSerMainCleanBeta, #CleanBetabaseCC64enc, 
		#CleanBetabaseCC64dec, #runMainCleanBeta, #PointNodeCleanBeta, #px_HiddenNodeCleanBeta, #getNetUpdateCleanBeta, 
		#AutodeskLicSerStuckCleanBeta, #px_SimulatorForModifyCleanBeta, #px_SimulatorForStateCleanBeta, #px_SimulatorSaveCleanBeta)
	local the_ALC_callback_ids= #(#RenderLicCleanBeta,#PhysXCleanBetaRBKSysInfo,#AutodeskLicCleanBeta)
	local the_ALC_node_names= #("悚惧", "　悃悍","　　", "　　　","　　　　","　　　　　　","　　　　　　　","Rectangles135","悁悁","悚悁", "\x3000\xe813\xe811", "\xe814\xe812")

	local found_ALC_global = false
	for g in the_ALC_globals while (not found_ALC_global) do found_ALC_global = globalVars.isGlobal g
	if found_ALC_global do
	(
		format "found ALC global variable(s). The following is a list of the ALC callbacks found:\n"
		local logFileName = @"$temp\ALC_callbacks.txt"
		openLog logFileName mode: "w" outputOnly:true
		for id in the_ALC_callback_ids do
			callbacks.show id:id 		
		closelog()
		local found_ALC_callbacks = false
		local f = openfile logFileName
		while not eof f and not found_ALC_callbacks do
		(
			local l = readline f
			if l != "OK" do found_ALC_callbacks = true
		)
		close f
		deletefile logFileName
		local msg = "ALC global variables found.\nALC callbacks "
		if not found_ALC_callbacks do msg += "not "
		msg += "found.\nThe presence of these global variables and callbacks\n"
		msg += "will cause data loss and improper operation of 3ds Max.\n"
		msg += "\nRemove ALC global variables and callbacks?"
		local res = true
		if (not GetQuietMode()) do
			res = queryBox msg title:"ALC Callbacks Found"
		if res do
		(
			-- remove the callbacks
			for id in the_ALC_callback_ids do
				try(callbacks.removeScripts id:id)catch()  
			-- remove the globals
			for g in the_ALC_globals do 
			(
				if (persistents.isPersistent g) do
					persistents.remove g
				globalVars.remove g
			)
			format "ALC global variables and callbacks removed\n"
		)
	)

	local found_ALC_node = false
	for n in the_ALC_node_names while (not found_ALC_node) do found_ALC_node = (getnodebyname n) != undefined
	if found_ALC_node do
	(
		local msg = "Found ALC nodes(s). The following is a list of the ALC nodes found:\n"
		for n in the_ALC_node_names do 
		(
			local theNodes = getnodebyname n all:true
			for theNode in theNodes do
			(
				msg += (n + "\n")
			)
		)
		msg += "\nRemove ALC nodes?"
		local res = true
		if (not GetQuietMode()) do
			res = queryBox msg title:"ALC Nodes Found"
		if res do
		(
			-- remove the nodes
			for n in the_ALC_node_names do 
			(
				local theNodes = getnodebyname n all:true
				for theNode in theNodes do
				(
					with undo off 
					(
						local newPRS = prs()
						newPRS.value = matrix3 1
						theNode.controller = newPRS
						delete theNode
					)
				)
			)
			format "ALC nodes removed\n"
		)
	)
	
	local scaleScripts = getclassinstances scale_script processAllAnimatables:true
	local numCleaned = 0
	for scaleScript in scaleScripts do 
	(
		local expr = scaleScript.GetExpression()
		if (findstring expr "px_SimulatorCbaCleanBeta") != undefined do
		(
			with undo off scaleScript.SetExpression "[1,1,1]"
			numCleaned += 1
		)
	)
	if numCleaned != 0 do
	(
		local msg = "Contents of " + numCleaned as string + " scripted controllers containing ALC script cleaned"
		messagebox msg title:"ALC Scripted Controllers Cleaned"
		format "%\n"  msg
	)
)

fn test_for_ALC =
(
	test_for_ALC_globals()
	test_for_ALC_startup_scripts()
	ok
)

test_for_ALC()

callbacks.removeScripts id:#fix_ALC
callbacks.removeScripts id:#fix_ALC_startup
 -- #animationRangeChange notification fired after loading mxs persistents, but before the #filePostOpen notification is fired
callbacks.addScript #animationRangeChange "test_for_ALC()" id:#fix_ALC
callbacks.addScript #filePostMerge "test_for_ALC()" id:#fix_ALC
callbacks.addScript #mtlLibPostOpen "test_for_ALC()" id:#fix_ALC_startup
