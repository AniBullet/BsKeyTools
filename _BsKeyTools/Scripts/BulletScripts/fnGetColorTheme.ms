global myFgColor
global myClickColor
global myCheckedColor
global BsDotBackColor
global BsDotForeColor
global BsDotCheckColor
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

	BsDotFont       = dotnetobject "System.Drawing.Font" "Roboto" 8
	BsDotBackColor  = dotColor.FromArgb maxuiBgColor[1] maxuiBgColor[2] maxuiBgColor[3]
	BsDotForeColor  = dotColor.FromArgb myFgColor.r myFgColor.g myFgColor.b
	BsDotCheckColor = dotColor.FromArgb myCheckedColor.r myCheckedColor.g myCheckedColor.b
)


fn getFilesequenceFile f &base &digits = 
(
	f = getFilenameFile f
	base = trimRight f "0123456789"
	digits = subString f (base.count + 1) -1
)

fn fnPseudoNaturalSort a b =  --文件名排序新方法--https://forums.cgsociety.org/t/sorting-filenames/1219205/4
(
	a = a as string
	b = b as string
	getFilesequenceFile a &aBase &aDigits
	-- hackhackhack.  This pads a number with zeros to 6 digits without using a loop.
	-- things will fail if there's more digits.. 6 'seems' safe.
	aDigits = subString ((1000000 + (aDigits as integer)) as string) 2 -1
	getFilesequenceFile b &bBase &bDigits
	bDigits = subString ((1000000 + (bDigits as integer)) as string) 2 -1
	a = aBase + aDigits
	b = bBase + bDigits

	case of (
	(a == b): 0
	(a < b): -1
	(a > b): 1
	)
)