try(destroydialog ::Test_OuterRollout) catch()
(
/***Creates lines in the active viewport that act as a visual guide for image composition.
	
	V2.55
	
	Update 20/07/2021 - Add new comp method (diagonals connecting rule of thirds)
	Update 26/05/2021 - remembers rollup states
	Update 26/05/2021 - Re-wrote UI with subrollouts to allow more flexibility for future development.
	ToDo:
	)
	Add common lenses	
	lock the overlay to a viewport (if possible)
	
	Based on script by Christoph Buelter
	
	By Warren Wnuk of the Faction CGI
	warren@thefactioncgi.com
	www.thefactioncgi.com
	
	Updated by BulletS 07.2022
	https://www.anibullet.com/

***/	


local iniFile = (getDir #userscripts) + "\\" + "imageCompHelper2.ini"
local iniProps = #("value", "color", "checked")
local goldenRatio = 1.6180
local inverseGoldenRatio = 0.618047
local rectangles = #()  -- Holds sub rectangles for golden spiral.
local spiralMode = 0  -- Determine orientation of golden spiral.
local triangleMode = 0 -- Determine orientation of golden triangle.
local unlock = 0
local pl = 0
local aspect = #(1.414,1,1.25,1.333,1.5,1.7,1.6,1.37,1.85,2,2.35,2.39,2.76)
local aspectItems  = #("A4, A3", "1:1", "5:4", "4:3", "3:2", "16:9", "16:10", "1.37:1","1.85:1", "2:1", "2.35:1",  "2.39:1", "2.76:1")	

----------------
-- Functions --
----------------

---------------------------
-- Read from INI file --
---------------------------
fn rollout_from_INI = 
	(
		tmpaspect = (getINISetting iniFile "aspect" "aspect")
		tmpaspectitems =(getINISetting iniFile "aspect" "aspectitems")
		
		if tmpaspect != "" and tmpaspectitems !="" do 
			(
				aspect = execute tmpaspect
				aspectitems = execute tmpaspectitems
				::Test_OuterRollout.Test_frame.SubRollout2.drp_aspect.items = aspectItems
			)
		if tmpaspect == "" and tmpaspectitems =="" do 
			(
				::Test_OuterRollout.Test_frame.SubRollout2.drp_aspect.items = aspectItems
			)
			
		pos = (getINISetting iniFile Test_OuterRollout.name "pos")
        if pos != "" do (
            tokens = filterString pos "[],"
            pos = point2 (tokens[1] as float) (tokens[2] as float)
            setDialogPos Test_OuterRollout pos
        )
		
		for roll in Test_OuterRollout.test_frame.rollouts do
		(
			inival = (GetINISetting iniFile "Rollout States" (roll as string))
			if inival !="" then
				(
					roll.open = execute inival 
				)
			else
				(
					roll.open = true
				)					
		)
		
		
        for prop in iniProps do
			(
            for con in Test_OuterRollout.test_frame.SubRollout1.controls where isProperty con prop do 
				(
                iniVal = getINISetting iniFile con.name prop
                if iniVal != "" do (
                    cls = classof (getProperty con prop)
                    if cls == color then (
                        tokens = filterstring iniVal "() "
                        val = color (tokens[2] as float) (tokens[3] as float) (tokens[4] as float)
                    )
                    else
                        val = (getINISetting iniFile con.name prop) as cls
                    setProperty con prop val
					)
				)
				
			for con in Test_OuterRollout.test_frame.SubRollout2.controls where isProperty con prop do (
                iniVal = getINISetting iniFile con.name prop
                if iniVal != "" then 
					(
					cls = classof (getProperty con prop)	
					val = (getINISetting iniFile con.name prop) as cls
                    setProperty con prop val
					)
				)
				
 			for con in Test_OuterRollout.test_frame.SubRollout3.controls where isProperty con prop do (
                 iniVal = getINISetting iniFile con.name prop
                 if iniVal != "" then 
 					(
					cls = classof (getProperty con prop)	
 					val = (getINISetting iniFile con.name prop) as cls
                     --setProperty con prop val
					)

				)
			)
	)

---------------------------
-- Composition Guides --
---------------------------
	
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
	)

	fn drawRectangle rect clr = (
		gw.setColor #line clr
		gw.wPolyline #(rect[1], rect[2], rect[3], rect[4]) true
	)

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
			case spiralMode of (
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
			case spiralMode of (
				0 : newRect = #(C,D,F,E)
				1 : newRect = #(C,D,F,E)
				2 : newRect = #(F,E,C,D)
				3 : newRect = #(F,E,C,D)
			)

		)
			append rectangles newRect
			times -= 1
			if times > 0 do
				rect = newRect
		)
	)

	
	-- Golden spiral
	fn drawGoldenSpiral fieldX fieldY offsetX offsetY clr = (
		-- Setup
		
		gui = Test_OuterRollout.test_frame.SubRollout1
		
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
		) -- End
		
		
		if aspect <1 then(
			if fieldy<=fieldx*goldenratio then( --test if out of bounds
				local w=(fieldy*sscale)/goldenratio --locks aspect of spiral
				local h=fieldy*sscale
			)
			if fieldy>fieldx*goldenratio then( --test if out of bounds
				local h=(fieldx*sscale)/inversegoldenratio
				local w=(h)/goldenratio  --locks aspect of spiral
			)
		) -- End
	)
		local oriX = (fieldX / 2 - w / 2) +ShiftX -- Origin x
		local oriY = (fieldY / 2 - h / 2) +ShiftY-- Origin y


		-- 1 means 360 points are connected to
		-- draw a circle, 2 means 180 etc.
		local step = 1

		-- Calculation:

		-- Main rectangle
		if aspect >=1 then (
			append rectangles #([oriX + offsetX, oriY + offsetY + h, 0], [oriX + offsetX, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY + h, 0])
			calcSubRectangle rectangles[1] inverseGoldenRatio 11 spiralMode --11 recatngles normaly
		)
		
		if aspect <1 then (
			append rectangles #([oriX + offsetX, oriY + offsetY + h, 0], [oriX + offsetX, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY, 0], [oriX + offsetX + w, oriY + offsetY + h, 0])
			calcSubRectangle rectangles[1] inverseGoldenRatio 11 spiralMode --11 recatngles normaly
		)
		
		-- Look up starting orientation to draw circles correctly.
		local circleStart
		local originIndex
		local rotationDirection

		-- Note: Lots of experimentation behind these settings...
		if aspect >=1 then (
		case spiralMode of (
			0 : (originIndex = 4; circleStart = 180; rotationDirection = 0)
			1 : (originIndex = 1; circleStart = 90; rotationDirection = 1)
			2 : (originIndex = 2; circleStart = 360; rotationDirection = 2)
			3 : (originIndex = 3; circleStart = 270; rotationDirection = 3)
		)
	)
		if aspect <1 then (
		case spiralMode of (
			0 : (originIndex = 4; circleStart = 180; rotationDirection = 0) --works
			1 : (originIndex = 3; circleStart = 270; rotationDirection = 1) --works
			2 : (originIndex = 2; circleStart = 0; rotationDirection = 2)--works
			3 : (originIndex = 1; circleStart = 90; rotationDirection = 3)
		)
	)
		
		

		-- Draw:
		for k = 1 to rectangles.count do (
			local r = rectangles[k]

			-- Uncomment next line to only draw the spiral without rectangles:
			rectclr = white
			drawRectangle r (rectclr/3)--((clr)/ 3)

			-- All ImageCompHelper bit is to draw the spirals in different orientations and different aspect ratios - Waren Wnuk
			
			if k > 1 do (  -- No circle around main rectangle, so skip k==1
				local prevR = rectangles[k-1]
				local nextR = rectangles[k]
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
		rectangles = #()
	)



	fn drawGoldenRatio fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		gldX = fieldX as float / goldenRatio
		gldY = fieldY as float / goldenRatio
		gw.wPolyline #([gldX+offsetX, 0+offsetY, 0], [gldX+offsetX, fieldY+offsetY-1, 0]) true
		gw.wPolyline #([fieldX-gldX+offsetX, 0+offsetY, 0], [fieldX-gldX+offsetX, fieldY+offsetY-1, 0]) true
		gw.wPolyline #([0+offsetX, gldY+offsetY, 0], [fieldX+offsetX-1, gldY+offsetY, 0]) true
		gw.wPolyline #([0+offsetX, fieldY-gldY+offsetY, 0], [fieldX+offsetX-1, fieldY-gldY+offsetY, 0]) true
	)

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
    )

	fn drawCross fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		b = fieldX / 2
		h = fieldY / 2
		gw.wPolyline #([b+offsetX, 0+offsetY, 0], [b+offsetX, fieldY+offsetY-1, 0]) true
		gw.wPolyline #([0+offsetX, h+offsetY, 0], [fieldX+offsetX-1, h+offsetY, 0]) true
	)

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
	)

	fn drawThirds fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		b = fieldX / 3
		h = fieldY / 3
		gw.wPolyline #([b+offsetX, 0+offsetY, 0], [b+offsetX, 3*h+offsetY-1, 0]) true
		gw.wPolyline #([2*b+offsetX, 0+offsetY, 0], [2*b+offsetX, 3*h+offsetY-1, 0]) true
		gw.wPolyline #([0+offsetX, h+offsetY, 0], [3*b+offsetX-1, h+offsetY, 0]) true
		gw.wPolyline #([0+offsetX, 2*h+offsetY, 0], [3*b+offsetX-1, 2*h+offsetY, 0]) true
	)
	
		fn drawDiagthirds fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		b = fieldX / 3
		h = fieldY / 3
		gw.wPolyline #([b+offsetX, 0+offsetY, 0], [fieldx+offsetX, 3*h+offsetY-1, 0]) true
		gw.wPolyline #([2*b+offsetX, 0+offsetY, 0], [0+offsetX, 3*h+offsetY-1, 0]) true
		gw.wPolyline #([0+offsetX, 0+offsetY, 0], [2*b+offsetX, 3*h+offsetY-1, 0]) true
		gw.wPolyline #([fieldx+offsetX, 0+offsetY, 0], [b+offsetX, 3*h+offsetY-1, 0]) true
	)
	

	fn drawDiagonals  fieldX fieldY offsetX offsetY clr = (
		gw.setColor #line clr
		gw.wPolyline #([0+offsetX, 0+offsetY, 0], [fieldX+offsetX, fieldY+offsetY, 0]) true
		gw.wPolyline #([0+offsetX, fieldY+offsetY, 0], [fieldX+offsetX, 0+offsetY, 0]) true
	)

	fn prepareAndDraw = (
		/***ImageCompHelper is the main execution function that lives in the callback.
		Note: It gets its input directly from the GUI, so changes are reflected instantly.
		***/
		--main = this
		gui = Test_OuterRollout.test_frame.SubRollout1
		if gui.ckb_thirds.checked or gui.ckb_golden.checked or \
		   gui.ckb_cross.checked or gui.ckb_diagonals.checked or \
		   gui.ckb_custom.checked or gui.ckb_spiral.checked or \
		   gui.ckb_triangle.checked or gui.ckb_diagthirds.checked do (
			
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
				drawCustomLines gui.spn_XDivs.value gui.spn_YDivs.value fieldX fieldY offsetX offsetY gui.cp_custom.color

			if gui.ckb_spiral.checked do
				drawGoldenSpiral fieldX fieldY offsetX offsetY gui.cp_spiral.color

			if gui.ckb_golden.checked do
				drawGoldenRatio fieldX fieldY offsetX offsetY gui.cp_golden.color

			if gui.ckb_thirds.checked do
				drawThirds fieldX fieldY offsetX offsetY gui.cp_thirds.color

			if gui.ckb_diagonals.checked do
				drawDiagonals fieldX fieldY offsetX offsetY gui.cp_diagonals.color

			if gui.ckb_cross.checked do
				drawCross fieldX fieldY offsetX offsetY gui.cp_cross.color

			if gui.ckb_triangle.checked do
				drawGoldenTriangle fieldX fieldY offsetX offsetY gui.cp_triangle.color
			
			if gui.ckb_diagthirds.checked do
				drawdiagThirds fieldX fieldY offsetX offsetY gui.cp_diagthirds.color
			
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
			redrawViews()
		)
	)
--------------------------
-- Register Callbacks --
--------------------------

	fn registerCallbacks = (
		unregisterRedrawViewsCallback prepareAndDraw
		registerRedrawViewsCallback prepareAndDraw
	)

	fn unregisterCallbacks = (
		unregisterRedrawViewsCallback prepareAndDraw
		completeRedraw()
	)
	
--------------------	
-- Main Rollout --
--------------------	
	
rollout Test_OuterRollout "构图辅助_v1.1"  width:140 height:883
(
	local updating = if updating != undefined then updating else on
	
	subrollout test_frame "test_frame" pos: [5,5] width:130 height:873
	
	local vsize_ui = #(Test_OuterRollout, test_frame)
	local shift_ui = #()
	
	fn updateRolloutSize vshift = if not Test_OuterRollout.updating do
	(
		vsize_ui.height += vshift
		shift_ui.pos.y += vshift
	)
	
--------------------------
-- Write to INI file --
--------------------------
fn rollout_to_INI = 
	(
		setINISetting iniFile "aspect" "aspect" (aspect as string)
		setINISetting iniFile "aspect" "aspectitems" (aspectitems as string)
		setINISetting iniFile Test_OuterRollout.name "pos" ((getDialogPos Test_OuterRollout) as String)
        
		for roll in Test_OuterRollout.test_frame.rollouts do
		(
			val = roll.open as string
			SetINISetting iniFile "Rollout States" (roll as string) val
		)
		
		
		for prop in iniProps do
		(
            for con in Test_OuterRollout.test_frame.SubRollout1.controls where isProperty con prop do
				(    
				setINISetting iniFile con.name prop ((getProperty con prop) as String)
				)
			 for con in Test_OuterRollout.test_frame.SubRollout2.controls where isProperty con prop do
				(    
				setINISetting iniFile con.name prop ((getProperty con prop) as String)
				)
			for con in Test_OuterRollout.test_frame.SubRollout3.controls where isProperty con prop do
				(    
				setINISetting iniFile con.name prop ((getProperty con prop) as String)
				)
		)
	)	

	on Test_OuterRollout close do
		(

			unregisterCallbacks()
			rollout_to_INI()
		)
		
	on Test_OuterRollout open do
	(
	)

)

-------------------
-- Subrollout 1 --
-------------------

rollout SubRollout1 "构图样式" width:140 height:384
(
		--local main_rol = Test_OuterRollout
		local colorDivisor = 1.5

		GroupBox grp_custom "自定义:" pos:[1,0] width:112 height:52
		spinner spn_XDivs "X 段数:" pos:[27,15] width:80 height:16 range:[0,999,4] type:#integer scale:1
		spinner spn_YDivs "Y 段数:" pos:[27,33] width:80 height:16 range:[0,999,4] type:#integer scale:1
	
		colorPicker cp_custom "" pos:[-1,54] width:23 height:22 color:(color 0 255 0)
		colorPicker cp_thirds "" pos:[-1,77] width:23 height:22 color:(color 255 255 0)
		colorPicker cp_diagonals "" pos:[-1,100] width:23 height:22 color:(color 255 0 0)
		colorPicker cp_golden "" pos:[-1,123] width:23 height:22 color:(color 255 110 0)
		colorPicker cp_spiral "" pos:[-1,169] width:23 height:22 color:(color 255 255 255)
		colorPicker cp_cross "" pos:[-1,192] width:23 height:22 color:(color 0 175 255)
		colorPicker cp_triangle "" pos:[-1,146] width:23 height:22 color:(color 0 255 175)
		colorPicker cp_diagthirds "" pos:[-1,213] width:23 height:22 color:(color 255 0 255)

		checkbutton ckb_thirds "三分构图" pos:[23,77] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_golden "黄金分割" pos:[23,123] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_cross "十字交叉" pos:[23,192] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_diagonals "对角线式" pos:[23,100] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_triangle "黄金三角" pos:[23,146] width:88 height:22 toolTip:"右击翻转" checked:false
		checkbutton ckb_custom "自定义" pos:[23,54] width:88 height:22 toolTip:"" checked:false
		checkbutton ckb_spiral "黄金螺旋" pos:[23,169] width:88 height:22 toolTip:"右击翻转螺旋" checked:false
		checkbutton ckb_diagthirds "对角线三分" pos:[23,215] width:88 height:22 toolTip:"" checked:false

		GroupBox grp_gsextra "黄金螺旋 设置:" pos:[1,243] width:112 height:95
		spinner spn_zoom "缩放" pos:[1,258] width:100 height:22 range:[-50,50,0] type:#integer
		spinner spn_ShiftX "偏移 X" pos:[1,276] width:100 heigh:22 range:[-100,100,0] type:#integer
		spinner spn_ShiftY "偏移 Y" pos:[1,294] width:100 heigh:22 range:[-100,100,0] type:#integer
		checkbutton ckb_unlock "解锁螺旋" pos:[3,313] width:106 height:22 toolTip:"解锁螺旋比" checked:false	
		
		GroupBox grp_misc "杂项:" pos:[1,338] width:112 height:40
		checkbutton ckb_safe "安全框" pos:[3,353] width:106 height:22 toolTip:"安全框" checked:false


	
	fn updateHighlightColors force:true = (
			/***When user changes color, update the checkboxes.***/
			ckb_golden.highlightColor = cp_golden.color / colorDivisor
			ckb_custom.highlightColor = cp_custom.color / colorDivisor
			ckb_cross.highlightColor = cp_cross.color / colorDivisor
			ckb_diagonals.highlightColor = cp_diagonals.color / colorDivisor
			ckb_thirds.highlightColor = cp_thirds.color / colorDivisor
			ckb_spiral.highlightColor = cp_spiral.color / colorDivisor 
			ckb_triangle.highlightColor = cp_triangle.color / colorDivisor
			ckb_diagthirds.highlightColor = cp_diagthirds.color / colorDivisor
			
			-- Force update of GUI by flipping checkbox states twice:
			if force do (
				ckb_golden.checked = not ckb_golden.checked
				ckb_custom.checked = not ckb_custom.checked
				ckb_cross.checked = not ckb_cross.checked
				ckb_diagonals.checked = not ckb_diagonals.checked
				ckb_thirds.checked = not ckb_thirds.checked
				ckb_spiral.checked = not ckb_spiral.checked
				ckb_triangle.checked = not ckb_triangle.checked
				ckb_diagthirds.checked = not ckb_diagthirds.checked

				ckb_golden.checked = not ckb_golden.checked
				ckb_custom.checked = not ckb_custom.checked
				ckb_cross.checked = not ckb_cross.checked
				ckb_diagonals.checked = not ckb_diagonals.checked
				ckb_thirds.checked = not ckb_thirds.checked
				ckb_spiral.checked = not ckb_spiral.checked
				ckb_triangle.checked = not ckb_triangle.checked
				ckb_diagthirds.checked = not ckb_diagthirds.checked
				--ckb_safe.checked = not ckb_triangle.checked

			)
			redrawViews()
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
		
		on ckb_diagthirds changed theState do (
            updateHighlightColors()
        )

		on ckb_spiral rightclick do (
			spiralMode += 1
			if spiralMode > 3 do
				spiralMode = 0
			updateHighlightColors()
		)

        on ckb_triangle rightClick do (
            triangleMode += 1
            if triangleMode > 1 do
            	triangleMode = 0
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
		
		on cp_diagthirds changed clr do (
			updateHighlightColors()
		)

		on spn_XDivs changed theValue do (
			updateHighlightColors()
		)

		on spn_YDivs changed theValue do (
			updateHighlightColors()
		)
		
		on ckb_unlock changed theState do (
			updateHighlightColors()
		)
		
		on ckb_safe changed thestate do(
			if not displaysafeframes and ckb_safe.checked do
				displaysafeframes = true
			if displaysafeframes and ckb_safe.checked == false do
				displaysafeframes = false
		)
		
	on SubRollout1 rolledup state do 
	(
		vshift = (if state then 1 else -1) * SubRollout1.height
		Test_OuterRollout.updateRolloutSize vshift
	)

)

-------------------
-- Subrollout 2 --
-------------------

rollout SubRollout2 "长宽比" width:140 height:242 
(
		--local main_rol = Test_OuterRollout
	
		GroupBox grp_asp "长宽比:" pos:[1,0] width:112 height:236
		combobox drp_aspect  pos:[5,20] width:75 height:8
		
		button btn_up "↑" pos:[85,60] Width:20 toolTip:"上移所选比例"
		button btn_down "↓" pos:[85,90] Width:20 toolTip:"下移所选比例"
		
		spinner sp_x "" Width:35	pos:[15,145]
		spinner sp_y ":" Width:40	pos:[55,145]
		
		label lb_info ""

		button btn_add "增 " pos:[3,185] Width:30 height:22 toolTip: "添加自定义比例"
		button btn_del "删 " pos:[35,185] Width:26 height:22 toolTip: "删除自定义比例"
		button btn_res "重置 " pos:[62,185] Width:47 height:22 toolTip: "重置比例样式"
		button btn_portrait "横向 / 纵向" pos:[3,210] width:106 height:22 toolTip: "长宽比切换" checked:false
	
	
	on drp_aspect selected i do
		(
			if pl == 0 then (
			rendImageAspectRatio = aspect[i]
			)
			if pl == 1 then (
			rendImageAspectRatio = (1/aspect[i])
			)
			--rendImageAspectRatio = aspect[i]
			renderSceneDialog.update() -- update dialog for changes to take effect
			redrawViews()
		)
	
	on btn_add pressed do
		(
		
		if (sp_x.value - floor sp_x.value) == 0 then sp_x_tmp = sp_x.value as integer else sp_x_tmp = sp_x.value
		if (sp_y.value - floor sp_y.value) == 0 then sp_y_tmp = sp_y.value as integer else sp_y_tmp = sp_y.value
		CARName = sp_x_tmp as string + ":" + sp_y_tmp as string
		CAR = sp_x.value / sp_y.value
		temp_array = aspectItems
		temp_array2 = aspect
		insertItem (CARname as string) temp_array 1	
		insertItem Car temp_array2 1
		aspect = temp_array2
		aspectItems = temp_array	
		drp_aspect.items = aspectItems	
		lb_info.text = "已添加 "+ (CARname as string)
	
		if pl == 0 then
			(
				rendImageAspectRatio = CAR
			)
			
		if pl == 1 then
			(
				rendImageAspectRatio = 1/CAR
			)
			
		renderSceneDialog.update() -- update dialog for changes to take effect
		redrawViews()
		)
		
	on btn_del pressed do
		(
			--if finditem MaspectItems drp_aspect.selected != 0  do
			--(
			--lb_info.text = "Can't delete defaults"
			--)
			--if finditem MaspectItems drp_aspect.selected == 0  do
			--(	
			
			lb_info.text = "已删除: "+ drp_aspect.selected  as string
				
			aspectItems = deleteItem aspectItems drp_aspect.selection
			aspect = deleteItem aspect drp_aspect.selection
			drp_aspect.items = aspectItems	

			if pl == 0 then
				(
					rendImageAspectRatio = aspect[1]
				)
			
			if pl == 1 then
				(
					rendImageAspectRatio = 1/aspect[1]
				)
			
			renderSceneDialog.update() -- update dialog for changes to take effect
			redrawViews()
		)
		
		
		
	on btn_res pressed do
		(
			aspect = #(1.414,1,1.25,1.333,1.5,1.7,1.6,1.37,1.85,2,2.35,2.39,2.76)
			aspectItems = #("A4, A3", "1:1", "5:4", "4:3", "3:2", "16:9", "16:10", "1.37:1","1.85:1", "2:1", "2.35:1", "2.39:1", "2.76:1")
			drp_aspect.items = aspectItems
			sp_x.value = 0
			sp_y.value = 0
			lb_info.text = "重置比例列表"
		
			if pl == 0 then
				(
					rendImageAspectRatio = aspect[1]
				)
			
			if pl == 1 then
				(
					rendImageAspectRatio = 1/aspect[1]
				)
			
		renderSceneDialog.update() -- update dialog for changes to take effect
		redrawViews()
		)
	
	on btn_up pressed do
		(

		mtmp1 = (aspectItems [drp_aspect.selection])	
		mtmp2 = (aspect [drp_aspect.selection])
			
		pos = drp_aspect.selection-1
	
			
		if pos >=1 do
			(
				aspect = deleteItem aspect drp_aspect.selection
				aspectItems = deleteItem aspectItems drp_aspect.selection

				insertItem mtmp1 aspectItems pos
				insertItem mtmp2 aspect pos
		
				drp_aspect.items = aspectItems
				drp_aspect.selection = pos
				lb_info.text = (drp_aspect.selected as string) + " 已移动"
			)
		
		if pos < 1 do
			(
				pos = drp_aspect.selection
				lb_info.text = "已在列表最高"
				drp_aspect.items = aspectItems
				drp_aspect.selection = pos
			)
		
		)	

	on btn_down pressed do
		(
			
		mtmp1 = (aspectItems [drp_aspect.selection])	
		mtmp2 = (aspect [drp_aspect.selection])
		
		pos = drp_aspect.selection+1
		
		if pos <= drp_aspect.items.count do
			(
				aspectItems = deleteItem aspectItems drp_aspect.selection
				aspect = deleteItem aspect drp_aspect.selection
		
				insertItem mtmp1 aspectItems pos
				insertItem mtmp2 aspect pos
		
				drp_aspect.items =aspectItems
				drp_aspect.selection = pos
				lb_info.text = (drp_aspect.selected as string) + " 已移动"
			)
		
		if pos > drp_aspect.items.count do
			(
				pos = drp_aspect.selection
				lb_info.text = "已在列表最低"
				drp_aspect.items = aspectItems
				drp_aspect.selection = pos
			)
		)
	
	on btn_portrait pressed do
		(
			if  rendImageAspectRatio >= 1 then(
				btn_portrait.text = "Portrait"
				pl=1
				
			)
			else(
				btn_portrait.text = "Landscape"
				pl=0
			)
			local rwidth = renderwidth
			local rheight = renderheight
			renderwidth=rheight
			renderheight=rwidth
						
			renderSceneDialog.update() -- update dialog for changes to take effect
			redrawViews()
		)
	
	on SubRollout2 rolledup state do 
	(
		vshift = (if state then 1 else -1) * SubRollout2.height
		Test_OuterRollout.updateRolloutSize vshift
	)
	
)

-------------------
-- Subrollout 3 --
-------------------

rollout SubRollout3 "相机" width:140 height:165
(	
		GroupBox grp_cam "相机:" pos:[1,0] width:112 height:164
		
		label lb_cam "" pos:[57,20]
	
		button btn_cam "相机" pos:[3,40] width:56 height:28
        button btn_target "目标" pos:[61,40] width:50 height:28
	
		button btn_1 "24" pos:[3,70] width:35 height:28
		button btn_2 "28" pos:[40,70] width:35 height:28
		button btn_3 "35" pos:[77,70] width:35 height:28
		button btn_4 "45" pos:[3,100] width:35 height:28
		button btn_5 "50" pos:[40,100] width:35 height:28
		button btn_6 "85" pos:[77,100] width:35 height:28
		button btn_7 "90" pos:[3,130] width:35 height:28
		button btn_8 "135" pos:[40,130] width:35 height:28
		button btn_9 "200" pos:[77,130] width:35 height:28
		
	on btn_cam pressed do 
	(
		if viewport.getType() == #view_camera then
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			max tti
			max modify mode
			selectedcam = $.name
			lb_cam.text = selectedcam
		)
		else (messagebox "请先进入相机视图！                                         " title:"构图辅助")
	)

		on btn_target pressed do 
		(
			if viewport.getType() == #view_camera then
			(
				actionMan.executeAction 0 "40248"  -- Views: Select Viewport Node Target
				max tti
				max modify mode
			)
			else (messagebox "请先进入相机视图！                                         " title:"构图辅助")
		)

		on btn_1 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "24mm"
			lens = 24
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
			-- if classof $ == CoronaCam then $.focallength = lens
			-- if classof $ == VRayPhysicalCamera then $.focal_length = lens
			-- if classof $ == physical then $.focal_length_mm = lens
			-- else print "no" --viewport.setfov 84.683
			
		)
		
		on btn_2 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "28mm"
			lens = 28
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)

		on btn_3 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "35mm"
			lens = 35
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)
		
		on btn_4 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "45mm"
			lens = 45
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)
		
		on btn_5 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "50mm"
			lens = 50
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)

		on btn_6 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "85mm"
			lens = 85
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)

		on btn_7 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "90mm"
			lens = 90
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)

		on btn_8 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "135mm"
			lens = 135
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)
		
		on btn_9 pressed do 
		(
			actionMan.executeAction 0 "40247"  -- Views: Select Viewport Node
			lb_cam.text = "200mm"
			lens = 200
			case (classof $) of
			(
				CoronaCam:$.focallength = lens
				VRayPhysicalCamera:$.focal_length = lens
				physical:$.focal_length_mm = lens
				Freecamera:$.fov = lens
				Targetcamera:$.fov = lens
				default:print "构图辅助:不支持的相机类型"
			)
		)
		
	on SubRollout3 rolledup state do 
	(
		vshift = (if state then 1 else -1) * SubRollout3.height
		Test_OuterRollout.updateRolloutSize vshift
	)
)

-------------------------
-- Startup Function --
-------------------------




fn show = (
try(destroydialog ::Test_OuterRollout) catch()
registerCallbacks()
createDialog Test_OuterRollout style:#(#style_titlebar, #style_border, #style_sysmenu)
addSubRollout Test_OuterRollout.test_frame SubRollout1
addSubRollout Test_OuterRollout.test_frame SubRollout2
addSubRollout Test_OuterRollout.test_frame SubRollout3
Test_OuterRollout.height = 883
Test_OuterRollout.test_frame.height = 873
Test_OuterRollout.updating = off
rollout_from_INI()
Test_OuterRollout.test_frame.SubRollout1.updateHighlightColors()
--Test_OuterRollout.test_frame.SubRollout3.lb_cam.text = "info"
displaysafeframes = true
SubRollout1.ckb_safe.checked = displaysafeframes
)

show()
)