--  <About & Info>
--  MaxScript: RescaleWU
--  Version: 1.0
--  Created: May.05.2006
--  Build on: 3dsMax8.0 SP2
--  Author: Oujian <Coo!Doggie>
--  E_Mail: Cooldoggie@vip.sina.com
--  Copyright (C) Hangzhou Wu Ji Cartoons Pte Ltd., All Rights Reserved.

--  Readme  --
--  This script is used to rescale world units same as MAX RescaleWorldUnits but real time.
--  The script window Locate center of MAX window after it's run.

-------------------------------------------------------------------------------------------
if (rol_RescaleWorldUnits != undefined and rol_RescaleWorldUnits.open == true) do
(
	DestroyDialog rol_RescaleWorldUnits;
)
--  <Start Script>
--  Variables  --
Global RescaleWU_ver = "1.20";

Global rescaleWU_sign = 0;
Global rescaleWU_temp = 1;
Global rescaleWU_selObj = #();
--  Functions  --
function fn_RWUselChangedObj size sel = /* Sent after the selection set has changed */
(
	local sel_cach
	sel_cach = selection as array;
	callbacks.removescripts id:#RWU_selection;

	if sel.state == 2 do 
	(
		if selection.count == 0 then
		(
			deSelect $*;
			select rescaleWU_selObj;
			rescaleWorldUnits (1/rescaleWU_temp) #selOnly;
			rescaleWU_selObj = #();
			deSelect $*;
		)
		else
		(
			deSelect $*;
			select rescaleWU_selObj;
			rescaleWorldUnits (1/rescaleWU_temp) #selOnly;
			deSelect $*;
			select sel_cach;
			rescaleWorldUnits size.value #selOnly;
			rescaleWU_selObj = sel_cach;
		)
	)

	txt = "spn_scale = rol_RescaleWorldUnits.spn_scale; \n";
	txt += "rdo_affect = rol_RescaleWorldUnits.rdo_affect; \n";
	txt += "if rol_RescaleWorldUnits.open == true do \n";
	txt += "fn_RWUselChangedObj spn_scale rdo_affect;";
	callbacks.addscript #selectionSetChanged txt \ 
	id:#RWU_selection persistent:false;	
)

function fn_RWUspnSetChanged size sel = /* Sent after the spinner:Scale Factor's value has changed */
(
	if sel.state == 1 then 
	(
		rescaleWorldUnits (1/rescaleWU_temp);
		rescaleWorldUnits size.value;
	)
	else 
	(
		rescaleWorldUnits (1/rescaleWU_temp) #selOnly;
		rescaleWorldUnits size.value #selOnly;
	)
	rescaleWU_temp = size.value;
	rescaleWU_selObj = selection as array;
	
)

function fn_RWUrdoSetChanged size sel = /* Sent after the radioButton has changed to Scene or Selection */
(
	if sel.state != rescaleWU_sign do 
	(
		if sel.state == 1 then 
		(
			rescaleWorldUnits (1/rescaleWU_temp) #selOnly;
			rescaleWorldUnits size.value;
		)
		else 
		(
			if selection.count != 0 then 
			(
				rescaleWorldUnits (1/rescaleWU_temp);
				rescaleWorldUnits size.value #selOnly;
			)
			else 
			(
				rescaleWorldUnits (1/rescaleWU_temp);
			)
		)
		rescaleWU_temp = size.value;
		rescaleWU_sign = sel.state;
		rescaleWU_selObj = selection as array;
	)
)

function fn_RWUcancelSetChanged size sel dia = /* Sent after click the button:Cancel,RescaleWU exit. */
(
	if sel.state == 1 then 
	(
		rescaleWorldUnits (1/rescaleWU_temp);
	)
	else 
	(
		rescaleWorldUnits (1/rescaleWU_temp) #selOnly;
	)
	rescaleWU_temp = 1;
	size.value = 1;
	rescaleWU_selObj = #();
	callbacks.removescripts id:#RWU_selection;
	DestroyDialog dia;
)

function fn_RWUdone size sel dia = /* Sent after click button:OK,RescaleWU done with all parameters reset.*/
(
	rescaleWU_temp = 1;
	-- size.value = 1;
	rescaleWU_selObj = selection as array;
)
--  Start Rollout --
rollout rol_RescaleWorldUnits ("蒙皮缩放 ver:" + RescaleWU_ver)
(
	checkbox chkBatch "是否批量处理？" pos:[10,35] width:100
    button btnGetFiles "选择处理路径" pos:[125,30] width:120 height:25 enabled:false border:true
    edittext edtDirPath "" pos:[0,5] fieldWidth:240 height:20 readOnly:true enabled:false
	spinner spn_scale "缩放系数" pos:[40,65] width:80 height:16 fieldWidth:50 range:[0.0001,10000,1] scale:0.01
	-- groupBox grp_affect "影响范围" pos:[90,65] width:240 height:40
	radioButtons rdo_affect "" pos:[145,67] labels:#("场景","所选物体") default:1 columns:1 width:220
	button btn_ok "执行" pos:[5,110] width:120 height:24
	button btn_cancel "取消" pos:[125,110] width:120 height:24
	label lblMe "miHoYo_Bullet.S" pos:[20,88] width:120 height:16

    local maxFiles = #()

    function GetFilesRecursive root pattern =
    (
        dir_array = GetDirectories (root+"\*")
        for d in dir_array do
            join dir_array (GetDirectories (d+"*"))    
        
        my_files = #()                
        for f in dir_array do
            join my_files (getFiles (f + pattern))
                
        my_files
    )

	on chkBatch changed state do 
	(
		btnGetFiles.enabled = state
		edtDirPath.enabled = state	
	)

    on btnGetFiles pressed do
    (
        local dir = getSavePath caption:"选择目录" initialDir:(maxFilePath)
        if dir != undefined do
        (
            maxFiles = #()
            maxFiles = getFiles (dir+"\*" + ".max")
            subFiles = GetFilesRecursive dir ("*.max")
            if subFiles.count != 0 then
            (
                msg = "所选路径包含子文件夹\r\n\r\n"
                msg += "请问是否包含子文件夹中的文件?                     "
                if queryBox  msg title:"找到子文件夹" do
                    join maxFiles subFiles
            )
            makeUniqueArray maxFiles
            edtDirPath.text = dir
        )
    )

	on rol_RescaleWorldUnits open do
	(
		rescaleWU_selObj = selection as array;
		rescaleWU_sign = rdo_affect.state;
		callbacks.removescripts id:#RWU_selection;

		txt = "spn_scale = rol_RescaleWorldUnits.spn_scale; \n";
		txt += "rdo_affect = rol_RescaleWorldUnits.rdo_affect; \n";
		txt += "if rol_RescaleWorldUnits.open == true do \n";
		txt += "fn_RWUselChangedObj spn_scale rdo_affect;";
		callbacks.addscript #selectionSetChanged txt \ 
		id:#RWU_selection persistent:false;
	)
	
	on rol_RescaleWorldUnits close do
	(
		fn_RWUcancelSetChanged spn_scale rdo_affect rol_RescaleWorldUnits;
		for obj in rescaleWU_selObj where (classof obj == BoneGeometry and obj.children.count == 0) do
		(
			obj.length = obj.length*val;
		)
		rescaleWU_sign = undefined;
		rescaleWU_temp = undefined;
		rescaleWU_selObj = undefined;
		fn_RWUcancelSetChanged = undefined;
		fn_RWUdone = undefined;
		fn_RWUrdoSetChanged = undefined;
		fn_RWUselChangedObj = undefined;
		fn_RWUspnSetChanged = undefined;
	)
	
	on spn_scale changed val do
	(
		fn_RWUspnSetChanged spn_scale rdo_affect;
	)
	
	on rdo_affect changed stat do
	(
		fn_RWUrdoSetChanged spn_scale rdo_affect;
	)
	
	on btn_ok pressed do 
	(
		if chkBatch.checked != false then
		(
			if maxFiles.count != 0 then 
			(
				for i in maxFiles where doesfileexist i do
				(
					resetMaxFile #noPrompt
					loadMaxFile i useFileUnits:true quiet:true
					fn_RWUspnSetChanged spn_scale rdo_affect
					local iScale = rol_RescaleWorldUnits.spn_scale.value
					fn_RWUdone spn_scale rdo_affect rol_RescaleWorldUnits;
					--version 1.01 add bone's length.
					for obj in objects where (classof obj == BoneGeometry and obj.children.count == 0) do
					(
						obj.length = obj.length*iScale;
					)
					savemaxfile  (maxFilePath + maxFileName)
				)
				messagebox "处理完成          "
			)
			else (messagebox "请重新添加待处理文件目录           ")
		)
        else
		(
			fn_RWUspnSetChanged spn_scale rdo_affect
			local iScale = rol_RescaleWorldUnits.spn_scale.value
			fn_RWUdone spn_scale rdo_affect rol_RescaleWorldUnits;
			--version 1.01 add bone's length.
			for obj in objects where (classof obj == BoneGeometry and obj.children.count == 0) do
			(
				obj.length = obj.length*iScale;
			)
			-- messagebox "处理完成          "
		)
	)
	
	on btn_cancel pressed do
	(
		fn_RWUcancelSetChanged spn_scale rdo_affect rol_RescaleWorldUnits;
		DestroyDialog rol_RescaleWorldUnits;
	)
)
--  End Rollout --
createdialog rol_RescaleWorldUnits 250 140
--  <End Script 0_o! ţ���̹�>