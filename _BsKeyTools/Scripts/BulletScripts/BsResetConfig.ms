Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
(
    local msg = "即将把配置文件：\r\n\r\n" + BulletConfig + "\r\n\r\n清空重置，包含自定义脚本和界面按钮顺序配置，\r\n\r\n是否继续？                                                                                                   "
    if (doesFileExist BulletConfig) then (
        if (queryBox msg title:"确认操作") then 
        (
            if (queryBox "是否打开配置文件目录？（配置文件：BulletConfig.ini）\r\n\r\n【另存或替换此文件可手动处理备份或导入脚本配置】                                                     " \
		    title:"配置文件" beep:false) then (shellLaunch (getFilenamePath BulletConfig) "")

            try(cui.UnRegisterDialogBar rolBsKeyTools) catch()
            try(destroydialog rolBsKeyTools)catch()
            try(destroydialog rolFnKeys)catch()
            try(destroydialog rolAddMyScripts)catch()
            try(destroydialog rolCustomFps)catch()
            try(destroydialog rolCustomBtn)catch()

            local f = createFile BulletConfig
            close f

            messageBox "处理完成！配置已重置，\r\n\r\n即将重新打开 BsKeyTools 插件。                                                " title:"完成"
            
            try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms");isRolloutOffScreen rolBsKeyTools)
            catch(messagebox "打开 BulletKeyTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
        )
        else 
        (
            messageBox "重置配置失败，请检查权限或文件是否被占用。                                       " title:"错误"
        )
    ) else (
        messageBox "未找到配置文件：\n" + BulletConfig + "                                                              " title:"未找到文件"
    )
)