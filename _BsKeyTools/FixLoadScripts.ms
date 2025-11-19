if(setinisetting (getMAXIniFile()) "MAXScript" "LoadStartupScripts" "1") then
(
    messagebox "修复启动加载脚本成功！\r\n\r\n请重新启动 3dsMax ！                             "
)
else
(
    messagebox "修复启动加载脚本失败！\r\n\r\n请手动设置启动加载脚本！\r\n\r\n打开 max 设置，找到 MAXScript 标签，\r\n\r\n勾选 Load Startup Scripts ！\r\n\r\n然后重启 3dsMax ！                                           "
)