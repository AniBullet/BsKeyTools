-- 自启守护：防止病毒关闭 Load Startup Scripts 导致插件和杀毒无法自启（不弹窗）
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnStartupGuard.ms"))
catch(format "[BsCleanVirus] 加载自启守护失败(fnStartupGuard.ms): %\n" (getCurrentException()))
(
	for f in getFiles (((getDir #scripts) + "\\BulletScripts\\ScanVirus\\")+ "signature.*.mcr") do
    (
        try(FileIn f)
        catch
        (
            -- 启动时不弹窗打断用户：只在侦听器记录原因、状态栏提示
            format "[BsCleanVirus] 加载杀毒特征失败: % - %\n" (filenameFromPath f) (getCurrentException())
            displayTempPrompt ("[BsCleanVirus] 加载杀毒特征失败：" + (filenameFromPath f) + "，详见 MAXScript 侦听器，可尝试重新安装") 15000
        )
    )
) 