macroScript BsScriptMenuConfig
category:"_[BsScriptMenu]"
buttonText:"BsScriptMenuConfig"
toolTip:"设置_BsScriptMenuConfig"
(
    try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BsScriptMenu.ms");try(createDialog rolBsScriptMenu)catch())
    catch(try(massagebox (getCurrentException()));catch();messagebox "打开 BsScriptMenu 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsScriptMenu")
)