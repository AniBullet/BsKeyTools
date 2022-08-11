global myFgColor
global myClickColor
global myCheckedColor
global BsDotBackColor
global BsDotForeColor
global BsDotFont
global dotColor = dotnetclass "System.Drawing.Color"

(
	local curColorThemeFile = colorMan.getFileName()
	local maxuiBgColor = (colorman.getcolor #background) * 255
	
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
			case maxuiBgColor of 
			(
				([68,68,68]):
				(
					myFgColor    = (color 165 222 228)
					myClickColor = (color 0 92 175)
					myCheckedColor = (color 30 136 168)
				)
				([186,186,186]):
				(
					myFgColor    = (color 28 89 177)
					myClickColor = (color 0 139 139)
					myCheckedColor = (color 152 227 213)
				)
				default:
				(
					myFgColor    = (color 165 222 228)
					myClickColor = (color 0 92 175)
					myCheckedColor = (color 30 136 168)
				)
			)
		)
	)
	else
	(
		case maxuiBgColor of 
		(
			([68,68,68]):
			(
				myFgColor    = (color 165 222 228)
				myClickColor = (color 0 92 175)
				myCheckedColor = (color 30 136 168)
			)
			([186,186,186]):
			(
				myFgColor    = (color 28 89 177)
				myClickColor = (color 0 139 139)
				myCheckedColor = (color 152 227 213)
			)
			default:
			(
				myFgColor    = (color 165 222 228)
				myClickColor = (color 0 92 175)
				myCheckedColor = (color 30 136 168)
			)
		)
	)
	----获取当前主题是深色还是浅色,来更改文字颜色 fnGetColorTheme.ms

	BsDotFont      = dotnetobject "System.Drawing.Font" "Roboto" 8
	BsDotBackColor = dotColor.FromArgb maxuiBgColor[1] maxuiBgColor[2] maxuiBgColor[3]
	BsDotForeColor = dotColor.FromArgb myFgColor.r myFgColor.g myFgColor.b
)