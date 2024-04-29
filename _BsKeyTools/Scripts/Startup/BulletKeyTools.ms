try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms");fnCheckRolloutPos rolBsKeyTools)
catch(messagebox "打开 BulletKeyTools.ms 失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false title:"BsKeyTools")
--新增检查窗口是否超出max所在区域