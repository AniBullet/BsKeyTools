/*
 * @Description: CleanVirus
 * @Author: Bullet.S
 * @Date: 2022-02-08 16:37:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2026-11-15 12:00:00
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
-- --Alienbrains / MSCPROP.DLL（Autodesk 官方命名）
-- (try(TrackViewNodes.TVProperty.PropParameterLocal.count >= 0) catch(false))
-- callbacks.show id:#PropertyParameters
-- --Kryptik
-- ((try(TrackViewNodes.AnimLayerControlManager.AnimTracks.ParamName) catch(undefined)) != undefined)

/*
[INFO]

AUTHOR = MastaMan
DEV = 3DGROUND
SITE=http://3dground.net
MODIFY = Bullet.S
SITE = anibullet.com

[NOTE]
MSCPROP.DLL 变种（Autodesk 2026-01 文章）：
- 环境：<Max根目录>\mscprop.dll、<Max根目录>\stdplugs\PropertyParametersLocal.mse、
        %TEMP%\Local_temp.ms、%TEMP%\Local_temp.mse；
        回调 id:#PropertyParameters（脚本 FN_PropertyParameters ...）
- 场景：TrackViewNodes 上的 TVProperty 自定义属性
环境感染和场景感染分开检测：任一命中都清理，场景干净时也会清理环境。

[SCRIPT]

*/

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

(
	struct signature_worm_alienbrains (
		name = "[Worm.3dsmax.alienbrains / MSCPROP]",
		signature = (substituteString (getFileNameFile (getThisScriptFileName())) "." "_"),
		tempDir = sysInfo.tempDir,
		maxRoot = getDir #maxRoot,
		detect_events = #(#filePostOpen, #systemPostReset, #filePostMerge),
		remove_ca = #("TVProperty", "NodeProperty"),
		remove_events = #(#PropertyParameters),
		remove_globals = #(#FN_PropertyParameters, #DeletePorpNode_bol, #ThePropParameterNodes, #TheFilePropParameters),
		remove_files = #(
			pathConfig.appendPath sysInfo.tempDir "Local_temp.ms",
			pathConfig.appendPath sysInfo.tempDir "Local_temp.mse",
			pathConfig.appendPath (getDir #maxRoot) "mscprop.dll",
			pathConfig.appendPath (getDir #maxRoot) @"stdplugs\PropertyParametersLocal.mse"
		),

		slog = signature_log(),

		fn pattern v p = (
			return matchPattern (toLower (v as string)) pattern: (toLower (p as string))
		),

		------------------------------------------------------------------
		-- 检测（只读，不修改场景/环境）
		------------------------------------------------------------------
		fn hasSceneCA = (
			if (try(TrackViewNodes.TVProperty) catch(undefined)) != undefined do return true
			for d in custAttributes.getSceneDefs() do (
				for attr in remove_ca where pattern d.name attr do return true
			)
			return false
		),

		fn hasCallbacks = (
			local ss = stringStream ""
			try (
				callbacks.show id:remove_events[1] to:ss
			) catch (
				format "% callbacks.show 失败，回调检测跳过：%\n" name (getCurrentException())
				return false
			)
			return (findString (ss as string) (remove_events[1] as string)) != undefined
		),

		fn getFoundGlobals = (
			return for g in remove_globals where (globalVars.isGlobal g) collect g
		),

		fn getFoundFiles = (
			return for f in remove_files where (doesFileExist f) collect f
		),

		fn detectEnv = (
			return (hasCallbacks()) or ((getFoundGlobals()).count > 0) or ((getFoundFiles()).count > 0)
		),

		------------------------------------------------------------------
		-- 清理
		------------------------------------------------------------------
		fn forceDelFile f = (
			try(setFileAttribute f #readOnly false) catch()
			try(deleteFile (pathConfig.resolvePathSymbols f)) catch()
			return not (doesFileExist f)
		),

		fn removeGlobal g = (
			try(if(persistents.isPersistent g) do persistents.remove g) catch()
			try(globalVars.remove g) catch()
		),

		fn removeAttribs attrs: #() = (
			-- 先清 TrackViewNodes 上直接挂的实例
			for i = (custAttributes.count TrackViewNodes) to 1 by -1 do (
				local def = custAttributes.getDef TrackViewNodes i
				if def != undefined do (
					for attr in attrs where pattern def.name attr do (
						try(TrackViewNodes.TVProperty.PropParameterLocal = "") catch()
						try(custAttributes.delete TrackViewNodes i) catch(format "% 删除 TrackViewNodes 自定义属性失败：%\n" name (getCurrentException()))
						exit
					)
				)
			)
			-- 再清场景中其它对象上的实例与定义
			for attr in attrs do (
				for d in custAttributes.getSceneDefs() where pattern d.name attr do (
					for inst in custAttributes.getDefInstances d do (
						for o in refs.dependents inst do (
							try(custAttributes.delete o d) catch()
						)
					)
					try(custAttributes.deleteDef d) catch(format "% 删除自定义属性定义 % 失败：%\n" name d.name (getCurrentException()))
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

			local sceneHit = hasSceneCA()
			local envHit = detectEnv()
			if (not sceneHit) and (not envHit) do return false

			-- 清理顺序：先断开回调和全局，防止病毒在清理过程中回写
			for ev in remove_events do try(callbacks.removeScripts id: ev) catch()
			for g in remove_globals do removeGlobal g
			removeAttribs attrs: remove_ca
			local failedFiles = for f in remove_files where (doesFileExist f) and (not (forceDelFile f)) collect f

			-- 复查残留
			local residual = #()
			if hasSceneCA() do append residual "场景自定义属性 TVProperty"
			if hasCallbacks() do append residual "回调 #PropertyParameters"
			for g in getFoundGlobals() do append residual ("全局变量 " + (g as string))
			for f in failedFiles do append residual ("文件 " + f)

			local infectLoc = case of (
				(sceneHit and envHit): "场景 + Max 环境"
				sceneHit: "场景"
				default: "Max 环境（当前场景未写入）"
			)
			local fileName = maxFilePath + maxFileName
			if fileName == "" do fileName = "未保存场景"

			local notification
			if residual.count == 0 then (
				notification = "病毒已检测到并删除完成（" + infectLoc + "）！请注意另存文件！"
			) else (
				notification = "病毒已检测到（" + infectLoc + "），但以下项目清理失败，请以管理员身份运行 Max 或手动删除：\n"
				for r in residual do notification += "\n  " + r
			)
			displayTempPrompt (name + " " + notification) 10000

			verbose_level = slog.getVerboseLevel()
			if residual.count > 0 or verbose_level == 1 or verbose_level == 2 do (
				messageBox (name + " " + notification + "                                        ") title: "Notification!"
			)

			if(verbose_level == 1 or verbose_level == 3) do (
				msg = name + "病毒已从下面路径移除（" + infectLoc + "）： \"" + fileName + "\""
				slog.write msg
			)
			if residual.count > 0 do (
				local warnMsg = name + "清理不完整，残留："
				for r in residual do warnMsg += " [" + r + "]"
				slog.write warnMsg type:#warn
			)
		)
	)

	local signature = signature_worm_alienbrains()
	signature.run()
)
