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
Global RescaleWU_ver = "1.00";

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
	size.value = 1;
	rescaleWU_selObj = selection as array;
)
--  Start Rollout --
rollout rol_RescaleWorldUnits ("RescaleWorldUnits ver:" + RescaleWU_ver) width:168 height:104
(
	spinner spn_scale "Scale Factor" pos:[8,8] width:152 height:16 fieldWidth:82 range:[0.0001,10000,1] scale:0.01
	groupBox grp_affect "Affect" pos:[7,24] width:153 height:40
	radioButtons rdo_affect "" pos:[18,40] labels:#("Scene","Selection") default:1 columns:2
	button btn_ok "OK" pos:[8,72] width:72 height:24
	button btn_cancel "Cancel" pos:[88,72] width:72 height:24

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
		local iScale = rol_RescaleWorldUnits.spn_scale.value
		fn_RWUdone spn_scale rdo_affect rol_RescaleWorldUnits;
		--version 1.01 add bone's length.
		for obj in objects where (classof obj == BoneGeometry and obj.children.count == 0) do
		(
			obj.length = obj.length*iScale;
		)
		DestroyDialog rol_RescaleWorldUnits;
	)
	
	on btn_cancel pressed do
	(
		fn_RWUcancelSetChanged spn_scale rdo_affect rol_RescaleWorldUnits;
		DestroyDialog rol_RescaleWorldUnits;
	)
)
--  End Rollout --
createdialog rol_RescaleWorldUnits 168 104
--  <End Script 0_o! ţ���̹�>