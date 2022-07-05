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
                test.height = 40
                print (test.height as string)
                print (dialogBox as string + " // " + mouse.screenPos as string)
            )
            else (
                test.height = 100
                print (test.height as string)
                print (dialogBox as string + " // " + mouse.screenPos as string)
            )
        )
    )

    on test mousemove pos do (
        if (ui_cilentOffset == undefined) then ( ui_clientOffset = pos - (mouse.screenPos - (getDialogPos test)) )
    )
)
createDialog test