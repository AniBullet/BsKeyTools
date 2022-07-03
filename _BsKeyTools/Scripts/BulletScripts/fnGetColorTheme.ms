global myFgColor
global myClickColor
global myCheckedColor
global BsDotBackColor
global BsDotForeColor
global BsDotFont
global dotColor = dotnetclass "System.Drawing.Color"

(
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

	local curColorThemeFile = colorMan.getFileName()
	local maxuiBgColor = (colorman.getcolor #background) * 255

	BsDotFont      = dotnetobject "System.Drawing.Font" "Roboto" 8
	BsDotBackColor = dotColor.FromArgb maxuiBgColor[1] maxuiBgColor[2] maxuiBgColor[3]
	BsDotForeColor = dotColor.FromArgb myFgColor.r myFgColor.g myFgColor.b
)