(
	for f in getFiles (((getDir #scripts) + "\\BulletScripts\\ScanVirus\\")+ "signature.*.mcr") do
    (
        try(FileIn f)
        catch(try(massagebox (getCurrentException()));catch();messagebox "加载杀毒失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false)
    )
) 