global myFgColor
global myClickColor
global myCheckedColor

curColorThemeFile = colorMan.getFileName()
if (curColorThemeFile != undefined) then
(
	if (matchpattern curColorThemeFile pattern:"*light*") then
	(
		myFgColor    = (color 28 89 177)
		myClickColor = (color 0 139 139)
		myCheckedColor = (color 152 227 213)
	)
	else
	(
		myFgColor    = (color 0 255 92)
		myClickColor = (color 0 255 127)
		myCheckedColor = (color 10 140 120)
	)
)
else
(
	myFgColor    = (color 0 255 92)
	myClickColor = (color 0 255 127)
	myCheckedColor = (color 10 140 120)
)
----获取当前主题是深色还是浅色,来更改文字颜色 fnGetColorTheme.ms