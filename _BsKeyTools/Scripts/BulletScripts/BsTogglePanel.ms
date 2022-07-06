try(destroydialog rolTogglePanel)catch()

Global toggleToolMouseState    = off
Global posToggleToolMouseMoved = [0,0]
global heightToggleClose       = 20
global heightToggleOpen        = 100
global widthToggleTools        = 300
rollout rolTogglePanel "rolTogglePanel" width:widthToggleTools height:heightToggleClose (

    local ui_clientOffset = undefined

    -- dotNetControl btn1 "button" pos:[0,0] width:widthToggleTools height:heightToggleClose

    timer timerTickTock interval:100 active:true

    -- on rolTogglePanel open do
    -- (
    --     btn1.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").flat
    --     btn1.Text = "A Flat DotNet Button!!"	
    --     btn1.TextAlign = (dotnetclass "system.drawing.contentalignment").MiddleCenter
    --     btn1.flatappearance.MouseoverBackColor = (dotnetclass"System.Drawing.color").yellow
    --     btn1.flatappearance.MousedownBackColor = (dotnetclass"System.Drawing.color").limegreen
    -- )

    on timerTickTock tick do (
        if (ui_clientOffset != undefined) then (
            local mouseClientPos = mouse.screenPos - (getDialogPos rolTogglePanel) + ui_clientOffset
            
            local dialogPos = getDialogPos rolTogglePanel
            local dialogBox = (Box2 dialogPos.x dialogPos.y rolTogglePanel.width rolTogglePanel.height)
            
            if (contains dialogBox mouse.screenPos) then (
                rolTogglePanel.height = heightToggleOpen
                -- print (rolTogglePanel.height as string)
                -- print (dialogBox as string + " // " + mouse.screenPos as string)
            )
            else (
                rolTogglePanel.height = heightToggleClose
                -- print (rolTogglePanel.height as string)
                -- print (dialogBox as string + " // " + mouse.screenPos as string)
            )
        )
    )

    on rolTogglePanel lbuttondown posMouse do
	(
		posToggleToolMouseMoved = posMouse
		toggleToolMouseState = on
        -- print (toggleToolMouseState as string)
	)
	
	on rolTogglePanel lbuttonup posMouse do
	(
		toggleToolMouseState = off
        -- print (toggleToolMouseState as string)
	)

    on rolTogglePanel mousemove pos do (
        if (ui_clientOffset == undefined) and (toggleToolMouseState == off) then ( ui_clientOffset = pos - (mouse.screenPos - (getDialogPos rolTogglePanel)) )
        if toggleToolMouseState == on then
		(
			SetDialogPos rolTogglePanel (mouse.screenpos - posToggleToolMouseMoved)
		)
    )

)
createDialog rolTogglePanel style:#()

-- rollout dnb "" width:323 height:114
-- (
--     dotNetControl btn1 "button" pos:[4,5] width:152 height:105
--     dotNetControl btn2 "button" pos:[164,5] width:152 height:105    
    
--     on dnb open do
--     (
--         btn1.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").flat
--         btn1.Text = "A Flat DotNet Button!!"	
--         btn1.TextAlign = (dotnetclass "system.drawing.contentalignment").bottomcenter
--         btn1.flatappearance.MouseoverBackColor = (dotnetclass"System.Drawing.color").yellow
--         btn1.flatappearance.MousedownBackColor = (dotnetclass"System.Drawing.color").limegreen
        
--         btn2.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").popup
--         btn2.Text = "A Popup DotNet Button!!"	
--         btn2.TextAlign = (dotnetclass "system.drawing.contentalignment").topcenter		
--     )
-- )
-- createdialog dnb