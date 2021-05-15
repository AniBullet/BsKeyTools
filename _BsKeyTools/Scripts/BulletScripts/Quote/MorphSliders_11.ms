macroScript MorphSliders category:"Tools" tooltip:"Morph Sliders" Icon:#("bobomacro",5)

(

------------------------------------------

--MorphSliders MACROSCRIPT v 1.1
--Created:5/9/99
--Edited:8/4/99
--by Borislav Petrov
--bobo@email.archlab.tuwien.ac.at
--http://gfxcentral.com/bobo/
------------------------------------------

---------------------------------------------------------------------------------
--NEW IN VERSION 1.1
--
--*Implemented correct Minimum and Maximum Limits (see Morpher Global Parameters)
--
--*Increased Interactivity by hooking the Morph Sliders Spinner/Slider to the
--respective spinner in the Morpher, and vice-versa. Changing any of them will
--update the others without the need to change time.
--
---------------------------------------------------------------------------------



------------------------------------------------------------------------------
--USER PREFERENCES BELLOW (a.k.a. Jamie's Variables)
------------------------------------------------------------------------------
--Increase this value to allow LONGER FLOATERS for higher res. monitors!
local max_height = 960
------------------------------------------------------------------------------
--Increase/decrease this value to change the SIZE of the channel name fields!
global add_text_width = 100
------------------------------------------------------------------------------





global ms_work_node

global nf

local rl

local go_on = true






sel_array = selection



if sel_array.count > 1 then 

	(

	messagebox "选中物体太多。\n请选择一个物体\n并且带 Morpher 修改器" title:"MorphSliders"

	go_on = false

	)

	

if sel_array.count == 0 then

	(

	messagebox "没有选中物体。\n请选择一个物体\n并且带 Morpher 修改器" title:"MorphSliders"

	go_on = false

	)	

if sel_array.count == 1 then

	(

	try 

	(

	a = sel_array[1].morpher

	)

	catch

	(

	messagebox "请选择一个带 Morpher 修改器的物体！" title:"MorphSliders"

	go_on = false

	)



	)--end if



if go_on then

(
used_channels = #()

ms_work_node = sel_array[1]
if ms_work_node.morpher.Use_Limits == 1 then
(
spin_min = ms_work_node.morpher.spinner_Minimum
spin_max = ms_work_node.morpher.spinner_Maximum
)
else
(
spin_min = -999
spin_max = 999
)


for i = 1 to 100 do if findstring (ms_work_node.morpher[i] as string) "empty" == undefined then append used_channels i 



nf_height = (used_channels.count*24+60)

if nf_height> max_height then nf_height = max_height



if nf!= undefined then closerolloutfloater nf

nf = newrolloutfloater "Bobo's MorphSliders    修改：Bullet.S" (440+add_text_width) nf_height 20 50


v_counter = -1


txt = "rollout ms_main \"MorphSliders - ["+ ms_work_node.name +"]\" (\n"

for i in used_channels do

(
v_counter += 1

target_name = ms_work_node.morpher[i] as string

start_name = findstring target_name "__"

end_name = findstring target_name "___"

final_name = substring target_name (start_name+2) (end_name-start_name-2)

txt +="spinner mspinner_"+i as string+ " range:["+spin_min as string+","+spin_max as string+","+ms_work_node.morpher[i].value as string+"] fieldwidth:40 across:4 pos:[1,("+v_counter as string+"*25+10)]  \n"

txt +="slider mslider_"+i as string+ " range:["+spin_min as string+","+spin_max as string+","+ms_work_node.morpher[i].value as string+ "] width:200 pos:[55,("+v_counter as string+"*25+7)]  \n"

txt +="edittext mstext_"+i as string+ " text:\""+ final_name+"\"  fieldwidth:(130+"+add_text_width as string+") pos:[250,("+v_counter as string+"*25+10)]  \n"

txt +="button mslabel_"+i as string+ "\""+ i as string+"\"  width:26 height:19 tooltip:\""+ final_name +"\"  pos:[440+"+add_text_width as string +"-54,("+v_counter as string+"*25+9)]  \n"

txt +="on mslider_"+i as string+ " changed val do (\n"

txt +="ms_work_node.morpher["+i as string+"].value = val \n"

txt +="mspinner_"+i as string+ ".value = val \n"
txt +="SliderTime +=0)\n"

txt +="on mspinner_"+i as string+ " changed val do (\n"

txt +="ms_work_node.morpher["+i as string+"].value = val \n"

txt +="mslider_"+i as string+ ".value = val \n"
txt +="SliderTime +=0 )\n"

txt +="on mslabel_"+i as string+" pressed do (\n"
txt +="try (select ($"+final_name+"))catch() )\n"
)

txt +=")"

rl = execute txt



addrollout rl nf



txt = "fn update_slider = (\n"

for i in used_channels do

(

txt +="ms_main.mspinner_"+i as string+ ".value = ms_work_node.morpher["+i as string+"].value \n"

txt +="ms_main.mslider_"+i as string+ ".value = ms_work_node.morpher["+i as string+"].value \n"

)

txt +=") \n"

update_sl = execute txt



registertimecallback update_sl

deleteAllChangeHandlers id:#morph_sliders

when parameters (ms_work_node.morpher) changes HandleAt:#RedrawViews id:#morph_sliders do 
(
update_sl()
)




)--end go_on

)--end script
