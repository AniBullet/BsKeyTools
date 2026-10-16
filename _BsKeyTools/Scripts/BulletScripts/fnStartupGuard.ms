/*
 * @Description: 自启守护 —— 防止病毒（如 ShaDu）关闭 3dsMax 的 "Load Startup Scripts"
 * 原理：病毒把 3dsmax.ini [MAXScript] LoadStartupScripts 改成 0 后，下次启动所有自启脚本（含杀毒）都不会运行。
 *       本脚本在打开/合并/导入/重置/新建场景及退出 Max 时检查该值，被改动就改回 1 并提示。
 * 配置：BulletConfig.ini [BsCleanVirus] StartupGuard，缺省为开启；开关在杀毒工具(BsCleanVirus)界面
 * 加载：由杀毒自启脚本 BsCleanVirusStartup.ms 加载；独立于 fnSaveLoadConfig.ms，故自行拼配置路径
 * 提示：自动防护只用状态栏和日志，绝不弹窗打断用户
 */
global fnBsStartupGuardConfigFile
global fnBsStartupGuardLog
global fnBsStartupGuardIsEnabled
global fnBsStartupGuardSetEnabled
global fnBsStartupGuardCheck
global fnBsStartupGuardRegister
global fnBsStartupGuardUnregister

fn fnBsStartupGuardConfigFile =
(
	(getDir #maxData) + "\\BulletConfig.ini"
)

fn fnBsStartupGuardIsEnabled =
(
	local v = getINISetting (fnBsStartupGuardConfigFile()) "BsCleanVirus" "StartupGuard"
	-- 缺省开启，只有明确写了 false 才算关闭
	(toLower v) != "false"
)

fn fnBsStartupGuardSetEnabled state =
(
	-- 返回是否写入成功（回读确认）
	local cfg = fnBsStartupGuardConfigFile()
	local ok = (setINISetting cfg "BsCleanVirus" "StartupGuard" (state as string)) and \
		(fnBsStartupGuardIsEnabled()) == state
	if not ok do format "[BsCleanVirus] 自启守护：写入配置失败: %\n" cfg
	ok
)

fn fnBsStartupGuardLog msg =
(
	format "[BsCleanVirus] %\n" msg
	-- 同步写入杀毒日志，便于在杀毒工具的“扫描日志”中查看
	local logFile = (getDir #maxData) + "\\scanlog.ini"
	-- 时间戳格式需与 BsCleanVirus.ms / signature.*.mcr 中 signature_log.getTime 保持一致
	local t = #()
	for i in getLocalTime() do
	(
		local s = i as string
		if s.count < 2 do s = "0" + s
		append t s
	)
	local k = t[4] + "." + t[2] + "." + t[1] + " " + t[5] + ":" + t[6] + ":" + t[7]
	if not (setINISetting logFile "Warning" k msg) do
		format "[BsCleanVirus] 自启守护：写入日志失败: %\n" logFile
)

-- 检查并修复；evt 仅用于日志。返回 true 表示当前为开启状态
fn fnBsStartupGuardCheck evt =
(
	if not (fnBsStartupGuardIsEnabled()) do return false
	local maxIni = getMAXIniFile()
	local cur = getINISetting maxIni "MAXScript" "LoadStartupScripts"
	if cur == "1" do return true

	-- 没有该项（如新装 Max 尚未写入）不是病毒，只补写，不当作威胁
	if cur == "" do
	(
		if (setINISetting maxIni "MAXScript" "LoadStartupScripts" "1") and \
			(getINISetting maxIni "MAXScript" "LoadStartupScripts") == "1" then
			return true
		else
		(
			format "[BsCleanVirus] 自启守护：补写 LoadStartupScripts=1 失败: %\n" maxIni
			return false
		)
	)

	local msg = "自启守护：检测到 Max“加载启动脚本”被关闭(LoadStartupScripts=" + cur + "，触发: " + (evt as string) + ")，疑似病毒所致"
	-- 写入后回读确认，避免把未生效的写入汇报成已恢复
	if (setINISetting maxIni "MAXScript" "LoadStartupScripts" "1") and \
		(getINISetting maxIni "MAXScript" "LoadStartupScripts") == "1" then
	(
		fnBsStartupGuardLog (msg + "，已自动恢复开启。建议运行杀毒工具检查场景！")
		displayTempPrompt "[BsCleanVirus] 自启守护：Max“加载启动脚本”被关闭，已自动恢复，建议运行杀毒检查场景！" 10000
		true
	)
	else
	(
		fnBsStartupGuardLog (msg + "，自动恢复失败！请在 自定义 > 首选项 > MAXScript 中手动勾选“加载启动脚本”。ini: " + maxIni)
		displayTempPrompt "[BsCleanVirus] 自启守护：Max“加载启动脚本”被关闭且恢复失败！请到 首选项 > MAXScript 手动勾选" 15000
		false
	)
)

fn fnBsStartupGuardUnregister =
(
	try(callbacks.removeScripts id:#BsStartupGuard)catch(format "[BsCleanVirus] 自启守护：移除回调失败: %\n" (getCurrentException()))
)

fn fnBsStartupGuardRegister =
(
	fnBsStartupGuardUnregister()
	-- 覆盖病毒常见的触发时机；退出时再检查一次，处理会话中被改的情况
	local events = #(#filePostOpen, #filePostMerge, #postImport, #systemPostReset, #systemPostNew, #preSystemShutdown, #postSystemShutdown)
	local allOk = true
	for e in events do
	(
		local cmd = "if fnBsStartupGuardCheck != undefined do fnBsStartupGuardCheck #" + (e as string)
		try(callbacks.addScript e cmd id:#BsStartupGuard)
		catch
		(
			allOk = false
			format "[BsCleanVirus] 自启守护：注册回调 #% 失败: %\n" e (getCurrentException())
		)
	)
	allOk -- 返回是否全部注册成功
)

-- 启动时：开启则立即检查一次并注册回调
if (fnBsStartupGuardIsEnabled()) do
(
	fnBsStartupGuardCheck #startup
	fnBsStartupGuardRegister()
)
