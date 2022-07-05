try(destroydialog test)catch()
rollout test "test" width:200 height:100 (
    local ui_clientOffset = undefined

    checkbutton helpmode "?" tooltip:"help mode"

    timer tick_tock interval:250 active:true

    on tick_tock tick do (
        if ((helpmode.state) AND (ui_clientOffset != undefined)) then (
            local mouseClientPos = mouse.screenPos - (getDialogPos test) + ui_clientOffset
            
            local dialogPos = getDialogPos test
            local dialogBox = (Box2 dialogPos.x dialogPos.y test.width test.height)
            if (contains dialogBox mouse.screenPos) then (
                print "The mouse is inside the dialog's client area"
            )
            else (
                print "The mouse is outside the dialog's client area"
            )
        )
    )

    on test mousemove pos do (
        if (ui_cilentOffset == undefined) then ( ui_clientOffset = pos - (mouse.screenPos - (getDialogPos test)) )
    )
)
createDialog test