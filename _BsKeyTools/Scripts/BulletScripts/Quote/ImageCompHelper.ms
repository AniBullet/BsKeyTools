try(destroyDialog ImageCompHelper.ro)catch()


struct ImageCompHelper (
	/***Creates lines in the active viewport that act as a visual guide for image composition.
	They are created as a render effect, so no camera is needed - Warren Wnuk
	Just check/uncheck the buttons to display the lines - Warren Wnuk
	Update 18/01/2021: Added common aspect ratios - Warren Wnuk
	Update 15/01/2021: Turned into a macroscript, Added pan controlls to golden spiral - Warren Wnuk
	Update 30/03/2020: Added zoom control of golden spiral - Warren Wnuk
	Update 27/03/2020: Added safe frame toggle, portrait mode button, and ability to unlock the golden spiral ratio - Warren Wnuk
	Update 25/03/2020: Make spirals work in portrait mode - Warren Wnuk
	Update 18/03/2020: Make spirals work at different aspect ratios - Warren Wnuk
	Update 06/03/2020: Fixed spiral button.  Fixed Golden Triangle to work at different aspects - Warren Wnuk
	
	Update 20/04/2013:	Added Golden Triangle (flip by rightclicking)
	Update 05/02/2013:	Buttons now change color instantly, changed coloring of lines from rgb array to gw.setColor so it works with Nitrous
	Update 20/12/2012:	Added the golden spiral (similar to Fibonacci spiral). Note: ImageCompHelper by nature is fixed to an aspect of 1:1.618
						Color selection now reflects instantly
	Update 21/10/2012:	Added option to pick custom colors
	Update 25/11/2010:	Fixed bug with non working playanimation-button. Added custom overlay options and did some UI changes.
	
	Written by Christoph Buelter 23.11.10
	www.cbuelter.de
	
	Updated by Warren Wnuk 18/01/21
	www.thefactioncgi.com	

	Updated by BulletS 02.04.2021
	https://www.anibullet.com/
	***/
	iniFile = (getDir #userscripts) + "\\" + "imageCompHelper.ini",
	iniProps = #("value", "color", "checked"),

	goldenRatio = 1.6180,
	inverseGoldenRatio = 0.618047,

	rectangles = #(),  -- Holds sub rectangles for golden spiral.
	spiralMode = 0,  -- Determine orientation of golden spiral.
	triangleMode = 0,  -- Determine orientation of golden triangle.
	unlock = 0,
	pl = 0,
	
	
	fn drawCircle origin radius1 radius2 startAngle endAngle step clr = (
		gw.setColor #line clr
		points = #()
		for i in startAngle to endAngle by step do (
			x = origin.x + radius1 * sin i
			y = origin.y + radius2 * cos i
			p = [x,y,0]
			append points p
			)

		for j=1 to (points.count-1) do (
			gw.wPolyline #(points[j], points[j+1]) false
		)
		

		
	),

	fn drawRectangle rect clr = (

		gw.setColor #line clr
		gw.wPolyline #(rect[1], rect[2], rect[3], rect[4]) true


	),

	
	fn calcSubRectangle rect blendFactor times mode = (
		/***Gets a rectangle, calculates a new one that is part of the old.
		ImageCompHelper fn does not return anything, but instead
		changes the 'rectangles' array.
		***/
	local winx = renderwidth
	local winy = renderheight
	local aspect = winx/winy as float
	
		while times > 0 do (
			
			if aspect >=1 then (
			case mode of (
				-- Choose order of vertices for calculation.
				-- Basically there are just two working modes (each twice).
				-- They however are different in creation order.
				0: (A = rect[1]; B = rect[2]; C = rect[3]; D = rect[4])
				1: (C = rect[1]; D = rect[2]; A = rect[3]; B = rect[4])
				2: (C = rect[1]; D = rect[2]; A = rect[3]; B = rect[4])
				3: (A = rect[1]; B = rect[2]; C = rect[3]; D = rect[4])
				)
			)
			
			if aspect <1 then (
			case mode of (
				-- Choose order of vertices for calculation.
				-- Basically there are just two working modes (each twice).
				-- They however are different in creation order.
				0: (A = rect[2]; B = rect[3]; C = rect[4]; D = rect[1])
				1: (C = rect[2]; D = rect[3]; A = rect[4]; B = rect[1])
				2: (C = rect[2]; D = rect[3]; A = rect[4]; B = rect[1])
				3: (A = rect[2]; B = rect[3]; C = rect[4]; D = rect[1])
				)
			)
			
			
			if aspect >=1 then (			
			eX = B.x + blendFactor * (C.x - B.x)
			eY = B.y + blendFactor * (C.y - B.y)

			fX = A.x + blendFactor * (D.x - A.x)
			fY = A.y + blendFactor * (D.y - A.y)

			E = [eX, eY, 0]			
			F = [fX, fY, 0]
			)
			
			if aspect <1 then (			
			eX = B.x + blendFactor * (C.x - B.x)
			eY = B.y + blendFactor * (C.y - B.y)

			fX = A.x + blendFactor * (D.x - A.x)
			fY = A.y + blendFactor * (D.y - A.y)

			E = [eX, eY, 0]			
			F = [fX, fY, 0]
			)
			
	if aspect >=1 then (
			-- Choose order for newRect.
			-- Create new rectangle with different
			-- vertex order, append and repeat.
			case ImageCompHelper.spiralMode of (
				0 : newRect = #(E,C,D,F)
				1 : newRect = #(E,C,D,F)
				2 : newRect = #(D,F,E,C)
				3 : newRect = #(D,F,E,C)
			)
		)
	if aspect <1 then (	
				-- Choose order for newRect.
			-- Create new rectangle with different
			-- vertex order, append and repeat.
			case ImageCompHelper.spiralMode of (
				0 : newRect = #(C,D,F,E)
				1 : newRect = #(C,D,F,E)
				2 : newRect = #(F,E,C,D)
				3 : newRect = #(F,E,C,D)
			)



		)

			append ImageCompHelper.rectangles newRect

			times -= 1

			if times > 0 do
				rect = newRect
		)
	),

	
	-- Golden spiral
	fn drawGoldenSpiral fieldX fieldY offsetX offsetY clr = (
		-- Setup
		
		gui = ImageCompHelper.ro
		
		local winx = renderwidth
		local winy = renderheight
		local aspect = winx/winy as float
		local sscale = (gui.spn_zoom.value+100)/100 as float  --scale factor for later
		local ShiftX = (((gui.spn_ShiftX.value as float) /100)*fieldx) as integer
		local ShiftY = (((gui.spn_ShiftY.value as float) /100)*fieldy) as integer
		
		
		if gui.ckb_unlock.checked==true do (

		if aspect >=1 then(
		local w = fieldX
		local h = fieldY
		)
		if aspect <1 then(
			local w=fieldx
			local h=fieldy 
		)

		)
		if gui.ckb_unlock.checked==false do (

		-- ImageCompHelper is for a locked aspect raio
		if aspect >=1 then(

			if fieldx <=fieldY *goldenratio then( --test if out of bounds
				local w = fieldX*sscale
				local h=(fieldx*sscale)*inversegoldenratio--locks aspect of spiral
			)
			
			if fieldx>fieldy*goldenratio then( --test if out of bounds
				local w = (fieldy*sscale)*goldenratio
				local h= (w)*inversegoldenratio --locks aspect of spiral
			)
		)
		
		
		if aspect <1 then(
			if fieldy<=fieldx*goldenratio then( --test if out of bounds
				local w=(fieldy*sscale)/goldenratio --locks aspect of spiral
				local h=fieldy*sscale

			)
			if fieldy>fieldx*goldenratio then( --test if out of bounds
				local h=(fieldx)/inversegoldenratio
				local w=(h)/goldenratio  --locks aspect of spiral

			)
	
		-- End
		)
	)
		local oriX = (fieldX / 2 - w / 2) +ShiftX -- Origin x
		local oriY = (fieldY / 2 - h / 2) +ShiftY-- Origin y


		-- 1 means 360 points are connected to
		-- draw a circle, 2 means 180 etc.
		local step = 1

		-- Calculation:

		-- Main rectangle
		if aspect >=1 then (
			append ImageCompHelper.rectangles #([oriX + offsetX, oriY + offsetY + h, 0], [oriX + offsetX, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY + h, 0])
			calcSubRectangle ImageCompHelper.rectangles[1] ImageCompHelper.inverseGoldenRatio 11 ImageCompHelper.spiralMode --11 recatngles normaly
		
		)
		
		if aspect <1 then (
			append ImageCompHelper.rectangles #([oriX + offsetX, oriY + offsetY + h, 0], [oriX + offsetX, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY + h, 0])
			calcSubRectangle ImageCompHelper.rectangles[1] ImageCompHelper.inverseGoldenRatio 11 ImageCompHelper.spiralMode --11 recatngles normaly
		)
		
		-- Look up starting orientation to draw circles correctly.
		local circleStart
		local originIndex
		local rotationDirection

		-- Note: Lots of experimentation behind these settings...
		if aspect >=1 then (
		case ImageCompHelper.spiralMode of (
			0 : (originIndex = 4; circleStart = 180; rotationDirection = 0)
			1 : (originIndex = 1; circleStart = 90; rotationDirection = 1)
			2 : (originIndex = 2; circleStart = 360; rotationDirection = 2)
			3 : (originIndex = 3; circleStart = 270; rotationDirection = 3)
		)
	)
		if aspect <1 then (
		case ImageCompHelper.spiralMode of (
			0 : (originIndex = 4; circleStart = 180; rotationDirection = 0) --works
			1 : (originIndex = 3; circleStart = 270; rotationDirection = 1) --works
			2 : (originIndex = 2; circleStart = 0; rotationDirection = 2)--works
			3 : (originIndex = 1; circleStart = 90; rotationDirection = 3)
		)
	)
		
		

		-- Draw:
		for k = 1 to ImageCompHelper.rectangles.count do (
			local r = ImageCompHelper.rectangles[k]

			-- Uncomment next line to only draw the spiral without rectangles:
			drawRectangle r ((clr)/ 1.5)

			
			-- All ImageCompHelper bit is to draw the spirals in different orientations and different aspect ratios - Waren Wnuk
			
			if k > 1 do (  -- No circle around main rectangle, so skip k==1
				local prevR = ImageCompHelper.rectangles[k-1]
				local nextR = ImageCompHelper.rectangles[k]
				local degrees = 90  -- Quarter circles is what we want

				if aspect >=1 then (
				-- CW or CCW drawing of circle.
				if rotationDirection == 0 then (
						if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance prevR[2] nextR[1]) (distance prevR[2] prevR[1])  circleStart (circleStart + degrees) step clr
						)
						if(mod k 2) !=0 then(
						drawCircle r[originindex] (distance prevR[2] prevR[1])  (distance prevR[2] nextR[1]) circleStart (circleStart + degrees) step clr
						)
					circleStart -= degrees  -- Decrease
	
					if circleStart <= 0 do circleStart = 360
				)
				
				if rotationDirection == 1 do (
					if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance nextR[1] prevR[4]) (distance prevR[2] prevR[1]) circleStart (circleStart + degrees) step clr
						)
					
						if(mod k 2) !=0 then(
						drawCircle r[originindex] (distance prevR[2] prevR[1]) (distance nextR[1] prevR[4]) circleStart (circleStart + degrees) step clr
						)

					circleStart += degrees  -- Increase
					if circleStart >= 360 do circleStart = 0
				)
				
				 if rotationDirection == 2 do (
					if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance prevR[4] nextR[3]) (distance prevR[2] prevR[1]) circleStart (circleStart + degrees) step clr
						)
					
						if(mod k 2) !=0 then(
						drawCircle r[originindex] (distance prevR[2] prevR[1]) (distance prevR[4] nextR[3]) circleStart (circleStart + degrees) step clr
						)

					circleStart -= degrees  -- Decrease
	
					if circleStart <= 0 do circleStart = 360
				)
				
				if rotationDirection == 3 do (
					if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance nextR[2] prevR[1]) (distance prevR[2] prevR[1]) circleStart (circleStart + degrees) step clr
						)
					
						if(mod k 2) !=0 then(
						drawCircle r[originindex] (distance prevR[2] prevR[1]) (distance nextR[2] prevR[1]) circleStart (circleStart + degrees) step clr
						)

					circleStart += degrees  -- Increase
					if circleStart >= 360 do circleStart = 0
				)
			)
				
				if aspect <1 then (
				-- CW or CCW drawing of circle.
				if rotationDirection == 0 then (
						if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance nextR[1] nextR[2]) (distance nextR[4] prevR[3])  circleStart (circleStart + degrees) step clr --works
						)
						if(mod k 2) !=0 then(
						drawCircle r[originindex] (distance nextR[4] prevR[3]) (distance nextR[1] nextR[2]) circleStart (circleStart + degrees) step clr --works
						
						)
					circleStart += degrees  -- Decrease
	
					if circleStart <= 0 do circleStart = 360
				)
				
				if rotationDirection == 1 do (
					if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance nextR[1] nextR[2]) (distance nextR[4] prevR[1]) circleStart (circleStart + degrees) step clr --working
						)
					
						if(mod k 2) !=0 then(
						drawCircle r[originindex] (distance nextR[4] prevR[1]) (distance nextR[1] nextR[2]) circleStart (circleStart + degrees) step clr --working
						)

					circleStart -= degrees  -- Increase
					if circleStart >= 360 do circleStart = 0
				)
				
				 if rotationDirection == 2 do (
					if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance nextR[1] nextR[2]) (distance nextR[2] prevR[1]) circleStart (circleStart + degrees) step clr --working
						)
					
						if(mod k 2) !=0 then(
						drawCircle r[originindex] (distance nextR[2] prevR[1]) (distance nextR[1] nextR[2])circleStart (circleStart + degrees) step clr --working
						)

					circleStart += degrees  -- Decrease
	
					if circleStart <= 0 do circleStart = 360
				)
				
				if rotationDirection == 3 do (
					if(mod k 2) ==0 then(
						drawCircle r[originindex] (distance nextR[1] nextR[2]) (distance nextR[1] prevR[2]) circleStart (circleStart + degrees) step clr --working
						)
					
						if(mod k 2) !=0 then(
						drawCircle r[originindex]  (distance nextR[1] prevR[2]) (distance nextR[1] nextR[2]) circleStart (circleStart + degrees) step clr --working
						)

					circleStart -= degrees  -- Increase
					if circleStart >= 360 do circleStart = 0
				)
			)
			
			
			)
		)

		-- Reset rectangles!
		ImageCompHelper.rectangles = #()
	),

	
	
	fn drawGoldenRatio fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		gldX = fieldX as float / ImageCompHelper.goldenRatio
		gldY = fieldY as float / ImageCompHelper.goldenRatio
		gw.wPolyline #([gldX+offsetX, 0+offsetY, 0], [gldX+offsetX, fieldY+offsetY-1, 0]) true
		gw.wPolyline #([fieldX-gldX+offsetX, 0+offsetY, 0], [fieldX-gldX+offsetX, fieldY+offsetY-1, 0]) true
		gw.wPolyline #([0+offsetX, gldY+offsetY, 0], [fieldX+offsetX-1, gldY+offsetY, 0]) true
		gw.wPolyline #([0+offsetX, fieldY-gldY+offsetY, 0], [fieldX+offsetX-1, fieldY-gldY+offsetY, 0]) true
	),

    fn drawGoldenTriangle fieldX fieldY offsetX offsetY clr = (
        -- Function by Enrico Gulloti, see:
        -- http://www.illusioncatalyst.com/mxs_files/geometryCalcs.html#getPointAlongLine
        fn getPointAlongLine &p3LinePoint_1 &p3LinePoint_2 fProp = (
            (p3LinePoint_1 + (p3LinePoint_2 - p3LinePoint_1) * fProp)
        )

        gw.setColor #line clr

        case triangleMode of (
            0 : (
                    dia1 = [0+offsetX, fieldY+offsetY, 0]
                    dia2 = [fieldX+offsetX, 0+offsetY, 0]
                    cor1 = [fieldX+offsetX, fieldY+offsetY, 0]
                    cor2 = [0+offsetX, 0+offsetY, 0]
                )
            1 : (
                    dia1 = [0+offsetX, 0+offsetY, 0]
                    dia2 = [fieldX+offsetX, fieldY+offsetY, 0]
                    cor1 = [fieldX+offsetX, 0+offsetY, 0]
                    cor2 = [0+offsetX, fieldY+offsetY, 0]
                )
        )
			--calculate correct intersection points for different aspect ratios by Warren Wnuk
			c1 = sqrt((renderwidth^2)+(renderheight^2))
			h1 = (renderheight*renderwidth)/c1
			c2= sqrt((renderwidth^2)-(h1^2))
			ratio= c2/c1
			
		
        gw.wPolyline #(dia1, dia2 ) true -- diagonal
        pt1 = getPointAlongLine dia1 dia2 ratio
        pt2 = getPointAlongLine dia1 dia2 (1-ratio)
        gw.wPolyline #(cor1, pt1) false
        gw.wPolyline #(cor2, pt2) false
    ),

	fn drawCross fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		b = fieldX / 2
		h = fieldY / 2
		gw.wPolyline #([b+offsetX, 0+offsetY, 0], [b+offsetX, fieldY+offsetY-1, 0]) true
		gw.wPolyline #([0+offsetX, h+offsetY, 0], [fieldX+offsetX-1, h+offsetY, 0]) true
	),

	fn drawCustomLines divX divY fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr

		if divX > 0 do (
			b = fieldX / (divX+1) as float
			for i=1 to divX do (
				gw.wPolyline #([i*b+offsetX, 0+offsetY, 0], [i*b+offsetX, fieldY+offsetY-1, 0]) true
			)
		)

		if divY > 0 do (
			h = fieldY / (divY+1) as float
			for i=1 to divY do (
				gw.wPolyline #([0+offsetX, i*h+offsetY, 0], [fieldX+offsetX-1, i*h+offsetY, 0]) true
			)
		)
	),

	fn drawThirds fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		b = fieldX / 3
		h = fieldY / 3
		gw.wPolyline #([b+offsetX, 0+offsetY, 0], [b+offsetX, 3*h+offsetY-1, 0]) true
		gw.wPolyline #([2*b+offsetX, 0+offsetY, 0], [2*b+offsetX, 3*h+offsetY-1, 0]) true
		gw.wPolyline #([0+offsetX, h+offsetY, 0], [3*b+offsetX-1, h+offsetY, 0]) true
		gw.wPolyline #([0+offsetX, 2*h+offsetY, 0], [3*b+offsetX-1, 2*h+offsetY, 0]) true
	),

	fn drawDiagonals  fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		gw.wPolyline #([0+offsetX, 0+offsetY, 0], [fieldX+offsetX, fieldY+offsetY, 0]) true
		gw.wPolyline #([0+offsetX, fieldY+offsetY, 0], [fieldX+offsetX, 0+offsetY, 0]) true
	),

	fn prepareAndDraw = (
		/***ImageCompHelper is the main execution function that lives in the callback.
		Note: It gets its input directly from the GUI, so changes are reflected instantly.
		***/
		main = ImageCompHelper
		gui = ImageCompHelper.ro

		if gui.ckb_thirds.checked or gui.ckb_golden.checked or \
		   gui.ckb_cross.checked or gui.ckb_diagonals.checked or \
		   gui.ckb_custom.checked or gui.ckb_spiral.checked or \
		   gui.ckb_triangle.checked do (

			
			--if not displaysafeframes do
/*
			if not displaysafeframes and gui.ckb_safe.checked do
				displaysafeframes = true
			if displaysafeframes and gui.ckb_safe.checked == false do
				displaysafeframes = false
*/
			--General calculation of drawing field:
			local winX = gw.getWinSizeX()
			local winY = gw.getWinSizeY()
			local winAspect = winX as float / winY as float
			local renAspect = renderWidth as float / renderHeight as float

			local offsetX = 0
			local offsetY = 0
			local fieldX = 0
			local fieldY = 0

			-- If width > height:
			if winAspect > renAspect then (
				fieldFactor = winY as float / renderHeight as float
				fieldY = winY
				fieldX = fieldFactor * renderWidth
				offsetX = (winX - fieldX)/2 + 1 --newline
				offsetY = (winY - fieldY)/2 + 1 


			)

			--If height > width:
			else (
				fieldFactor = winX as float / renderWidth as float
				fieldX = winX
				fieldY = fieldFactor * renderHeight
				offsetX = (winX - fieldX)/2 + 1
				offsetY = (winY - fieldY)/2 + 1  --newline


			)

			-- Draw:
			if gui.ckb_custom.checked do
				main.drawCustomLines gui.spn_XDivs.value gui.spn_YDivs.value fieldX fieldY offsetX offsetY gui.cp_custom.color

			if gui.ckb_spiral.checked do
				main.drawGoldenSpiral fieldX fieldY offsetX offsetY gui.cp_spiral.color

			if gui.ckb_golden.checked do
				main.drawGoldenRatio fieldX fieldY offsetX offsetY gui.cp_golden.color

			if gui.ckb_thirds.checked do
				main.drawThirds fieldX fieldY offsetX offsetY gui.cp_thirds.color

			if gui.ckb_diagonals.checked do
				main.drawDiagonals fieldX fieldY offsetX offsetY gui.cp_diagonals.color

			if gui.ckb_cross.checked do
				main.drawCross fieldX fieldY offsetX offsetY gui.cp_cross.color

			if gui.ckb_triangle.checked do
				main.drawGoldenTriangle fieldX fieldY offsetX offsetY gui.cp_triangle.color
			
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
			redrawViews()
		)
	),

	ro = rollout ro "构图辅助" width:112 height:445 (

		local self  -- Parent struct reference
		local colorDivisor = 1.5

		colorPicker cp_custom "" pos:[-1,56] width:23 height:22 color:(color 0 255 0)
		colorPicker cp_thirds "" pos:[-1,85] width:23 height:22 color:(color 255 255 0)
		colorPicker cp_diagonals "" pos:[-1,108] width:23 height:22 color:(color 255 0 0)
		colorPicker cp_golden "" pos:[-1,131] width:23 height:22 color:(color 255 110 0)
		colorPicker cp_spiral "" pos:[-1,177] width:23 height:22 color:(color 255 255 255)
		colorPicker cp_cross "" pos:[-1,200] width:23 height:22 color:(color 0 255 255)
		colorPicker cp_triangle "" pos:[-1,154] width:23 height:22 color:(color 0 255 175)

		checkbutton ckb_thirds "三分构图" pos:[23,85] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_golden "黄金分割" pos:[23,131] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_cross "十字交叉" pos:[23,200] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_diagonals "对角线式" pos:[23,108] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_triangle "黄金三角" pos:[23,154] width:88 height:22 toolTip:"右击翻转" checked:false
		checkbutton ckb_custom "自定义" pos:[23,56] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_spiral "黄金螺旋" pos:[23,177] width:88 height:22 toolTip:"右击翻转螺旋" checked:false
		

		
		GroupBox grp_custom "自定义:" pos:[1,0] width:110 height:82
		spinner spn_XDivs "X 段数:" pos:[27,16] width:80 height:16 range:[0,999,4] type:#integer scale:1
		spinner spn_YDivs "Y 段数:" pos:[27,34] width:80 height:16 range:[0,999,4] type:#integer scale:1

        button btn_cam "相机" pos:[1,225] width:62 height:28
        button btn_target "目标" pos:[65,225] width:46 height:28
		
		GroupBox grp_gsextra "黄金螺旋 设置:" pos:[1,255] width:110 height:75
		spinner spn_zoom "缩放" pos:[0,270] width:105 height:22 range:[-50,50,0] type:#integer
		spinner spn_ShiftX "偏移 X" pos:[0,290] width:105 heigh:22 range:[-100,100,0] type:#integer
		spinner spn_ShiftY "偏移 Y" pos:[0,310] width:105 heigh:22 range:[-100,100,0] type:#integer
		checkbutton ckb_unlock "解锁螺旋" pos:[1,332] width:110 height:22 toolTip:"解锁螺旋比" checked:false
		
		--GroupBox grp_misc "Misc:" pos:[1,355] width:112 height:30
		dropdownList drp_aspect "长宽比:" pos:[1,355] width:110 height:22 items:#("A4, A3", "1:1", "5:4", "4:3", "3:2", "16:9", "16:10", "1.85:1", "2:1", "2.35:1")
		--checkbutton ckb_portrait "Portrait" pos:[1,395] width:112 height:22 toolTip:"Portrait / Landscape Toggle"
		button btn_portrait "横向 / 纵向" pos:[1,395] width:110 height:22 toolTip: "长宽比切换" checked:false
		checkbutton ckb_safe "安全框" pos:[1,420] width:110 height:22 toolTip:"安全框" checked:true


		fn updateHighlightColors force:true = (
			/***When user changes color, update the checkboxes.***/
			ckb_golden.highlightColor = cp_golden.color / colorDivisor
			ckb_custom.highlightColor = cp_custom.color / colorDivisor
			ckb_cross.highlightColor = cp_cross.color / colorDivisor
			ckb_diagonals.highlightColor = cp_diagonals.color / colorDivisor
			ckb_thirds.highlightColor = cp_thirds.color / colorDivisor
			ckb_spiral.highlightColor = cp_spiral.color / colorDivisor 
			ckb_triangle.highlightColor = cp_triangle.color / colorDivisor
			


			-- Force update of GUI by flipping checkbox states twice:
			if force do (
				ckb_golden.checked = not ckb_golden.checked
				ckb_custom.checked = not ckb_custom.checked
				ckb_cross.checked = not ckb_cross.checked
				ckb_diagonals.checked = not ckb_diagonals.checked
				ckb_thirds.checked = not ckb_thirds.checked
				ckb_spiral.checked = not ckb_spiral.checked
				ckb_triangle.checked = not ckb_triangle.checked

				ckb_golden.checked = not ckb_golden.checked
				ckb_custom.checked = not ckb_custom.checked
				ckb_cross.checked = not ckb_cross.checked
				ckb_diagonals.checked = not ckb_diagonals.checked
				ckb_thirds.checked = not ckb_thirds.checked
				ckb_spiral.checked = not ckb_spiral.checked
				ckb_triangle.checked = not ckb_triangle.checked
				ckb_safe.checked = not ckb_triangle.checked

			)

			redrawViews()
		)

		on ro close do (
			self.unregisterCallbacks()
			self.rollout_to_INI()
		)

		on ckb_thirds changed theState do (
			updateHighlightColors()
		)

		on ckb_golden changed theState do (
			updateHighlightColors()
		)

		on ckb_cross changed theState do (
			updateHighlightColors()
		)

		on ckb_diagonals changed theState do (
			updateHighlightColors()
		)

		on ckb_custom changed theState do (
			updateHighlightColors()
		)

		on ckb_spiral changed theState do (
			updateHighlightColors()
		)

        on ckb_triangle changed theState do (
            updateHighlightColors()
        )

		on ckb_spiral rightclick do (
			self.spiralMode += 1
			if self.spiralMode > 3 do
				self.spiralMode = 0
			updateHighlightColors()
		)

        on ckb_triangle rightClick do (
            self.triangleMode += 1
            if self.triangleMode > 1 do
            	self.triangleMode = 0
            updateHighlightColors()
        )

		on cp_thirds changed clr do (
			updateHighlightColors()
		)

		on cp_golden changed clr do (
			updateHighlightColors()
		)

		on cp_cross changed clr do (
			updateHighlightColors()
		)

		on cp_diagonals changed clr do (
			updateHighlightColors()
		)

		on cp_custom changed clr do (
			updateHighlightColors()
		)

		on cp_spiral changed clr do (
			updateHighlightColors()
		)

        on cp_triangle changed clr do (
            updateHighlightColors()
        )

		on spn_XDivs changed theValue do (
			updateHighlightColors()
		)

		on spn_YDivs changed theValue do (
			updateHighlightColors()
		)

		on btn_cam pressed do (
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			max tti
			max modify mode
		)

		on btn_target pressed do (
			actionMan.executeAction 0 "40248"  -- Views: Select Viewport Node Target
			max tti
			max modify mode
		)
		
				
		on ckb_unlock changed theState do (
			updateHighlightColors()
		)
	
		on btn_portrait pressed do(
			if  rendImageAspectRatio >= 1 then(
				btn_portrait.text = "纵向"
				imagecomphelper.pl=1
				
			)
			else(
				btn_portrait.text = "横向"
				imagecomphelper.pl=0
			)
			local rwidth = renderwidth
			local rheight = renderheight
			renderwidth=rheight
			renderheight=rwidth
						
			renderSceneDialog.update() -- update dialog for changes to take effect
			redrawViews()
			)

		on ckb_safe changed thestate do(
			if not displaysafeframes and ckb_safe.checked do
				displaysafeframes = true
			if displaysafeframes and ckb_safe.checked == false do
				displaysafeframes = false
		)
	
		on drp_aspect selected i do(
			if imagecomphelper.pl == 0 then (
			aspect = #(1.414,1,1.25,1.333,1.5,1.7,1.6,1.85,2,2.35)
			)
			if imagecomphelper.pl == 1 then (
			aspect = #(0.707,1,0.8,0.75,0.66,0.5625,0.625,0.540,0.5,0.425)
			)
			rendImageAspectRatio = aspect[i]
			renderSceneDialog.update() -- update dialog for changes to take effect
			redrawViews()

		)
	),

    fn rollout_to_INI = (
        setINISetting ImageCompHelper.iniFile ImageCompHelper.ro.name "pos" ((getDialogPos ro) as String)
        for prop in ImageCompHelper.iniProps do
            for con in ImageCompHelper.ro.controls where isProperty con prop do
                setINISetting ImageCompHelper.iniFile con.name prop ((getProperty con prop) as String)
    ),

    fn rollout_from_INI = (
        pos = (getINISetting ImageCompHelper.iniFile ImageCompHelper.ro.name "pos")
        if pos != "" do (
            tokens = filterString pos "[],"
            pos = point2 (tokens[1] as float) (tokens[2] as float)
            setDialogPos ImageCompHelper.ro pos
        )
        for prop in ImageCompHelper.iniProps do
            for con in ImageCompHelper.ro.controls where isProperty con prop do (
                iniVal = getINISetting ImageCompHelper.iniFile con.name prop
                if iniVal != "" do (
                    cls = classof (getProperty con prop)
                    if cls == color then (
                        tokens = filterstring iniVal "() "
                        val = color (tokens[2] as float) (tokens[3] as float) (tokens[4] as float)
                    )
                    else
                        val = (getINISetting ImageCompHelper.iniFile con.name prop) as cls
                    setProperty con prop val
                )
            )
    ),

	fn registerCallbacks = (
		unregisterRedrawViewsCallback ImageCompHelper.prepareAndDraw
		registerRedrawViewsCallback ImageCompHelper.prepareAndDraw
	),

	fn unregisterCallbacks = (
		unregisterRedrawViewsCallback ImageCompHelper.prepareAndDraw
		completeRedraw()
	),

	fn show = (
		ImageCompHelper.registerCallbacks()
		createDialog ImageCompHelper.ro
		--cui.registerDialogBar ImageCompHelper.ro style: #(#cui_dock_verticle, #cui_floatable)
		ImageCompHelper.ro.self = ImageCompHelper
		ImageCompHelper.rollout_from_INI()
		ImageCompHelper.ro.updateHighlightColors()

		-- Force display of safeFrame on script startup:

		if not displaysafeframes do
			displaysafeframes = true
		redrawViews()
	)
)

Imagecomphelper=ImageCompHelper()
Imagecomphelper.show()