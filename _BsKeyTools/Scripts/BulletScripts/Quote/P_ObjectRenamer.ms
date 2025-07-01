--BulletS汉化及修改 2021.02
try(destroydialog P_ObjectRenamer)catch()
global P_ObjectRenamer;
(
local Dir_=(getdir #vpost)+"\\P_ObjectRenamer\\Rename_Tool_Preset\\"
local Dir2_=(getdir #vpost)+"\\P_ObjectRenamer\\Rename_List\\"
local obj_list=#();
local obj_list_Original_sort=#()
local obj_namelist=#()
local Rename_file_Arr
local textbox_color=(DotNetClass "System.Drawing.Color").FromArgb 60 60 60
local textbox_textcolor=(DotNetClass "System.Drawing.Color").FromArgb 255 255 255
local selected_list=#()
local preview_mode=true

fn YN_Messagebox _text=
(
   -- setup dotnet classes / objects
   local mb = dotNetClass "System.Windows.Forms.MessageBox"
   local buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
   local icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
   local defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
   local dialogResult = dotNetClass "System.Windows.Forms.DialogResult"
   local result = mb.show _text "Quit" buttons.YesNo icons.Information defaultButton.Button3
   
   -- evaluate result of messageBox (which button has been pressed by the user)
   if ( result == dialogResult.Yes ) then
   (
      return #Yes
   )
   else if ( result == dialogResult.No ) then
   (
      return #No
   )
   
)
   
fn directory_check_and_make path_ =
(
   if (doesDirectoryExist  path_)==false do 
   (makeDir path_)
)

fn defColor r g b = ((dotNetClass "System.Drawing.Color").FromArgb r g b)
local maxBC = defColor 60 60 60, maxFC = defColor 200 200 200
   

fn Dialog_modal text1 text2=
(
   theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" text2
   theobj.text =text1

   DialogResult = theObj.Showmodal()
   if (dotnet.compareenums theObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)) == false do (return false)
   return theobj.InstanceName 
)

fn regex_escape str =
(
    local specials = "\\.^$|?*+()[]{}"
    local result = ""
    for i = 1 to str.count do
    (
        if findString specials str[i] != undefined then
            result += "\\"
        result += str[i]
    )
    result
)

fn replace_with_pattern txt pattern replacetext=
(
   pattern = regex_escape pattern
   for i=1 to 20 do
   (
      a=findstring pattern "*"
      if (a==undefined) do (exit)
      pattern=replace pattern a 1 ".+"
   )
   for i=1 to 20 do
   (
      a=findstring pattern "?"
      if (a==undefined) do (exit)
      pattern=replace pattern a 1 "."
   )
   
   rgx = dotnetObject "System.Text.RegularExpressions.Regex" pattern
   return (rgx.Replace txt replacetext)
)

fn AddColumns theLv columnsAr =
(
   for i in 1 to columnsAr.count do theLv.columns.add columnsAr[i] 0
)

      

function check_Selected num=
(
   for i in selected_list do
   (
      if i==num do
      (
         return true
      )
   )
   return false
)

function update_preset=
(
   list_=getFiles (Dir_+"*.txt")
   list2_=#()
   for i in list_ do
   (
      append list2_ (getFilenameFile i)
   )
   P_ObjectRenamer.ddl_Preset.items= list2_
)


function nsort a b=
(
   local aa=#(a[2],b[2])
   sort aa
   if aa[1]==a[2] do (return -1)
   return 1
)   

function update_ mode:"default" refresh_:#false=
(
   
   local number_count, interval_ , digit;
   local Result_list1=obj_namelist
   local Result_list2=#()
   local edit_name_text=P_ObjectRenamer.edt_Edit_Name.text
   local found_N=(findString edit_name_text "[N]")
   
   number_count=P_ObjectRenamer.spn_First_Number.value-P_ObjectRenamer.spn_Interval.value
   interval_=P_ObjectRenamer.spn_Interval.value
   digit=P_ObjectRenamer.spn_Digit.value
   if refresh_==#true do
   (
      selected_list=#()
   )
   if mode=="Rename_List" do
   (
      for i=1 to Result_list1.count do
      (
         for ii in Rename_file_Arr do
         (
            if ii[1]==Result_list1[i] do
            (
               P_ObjectRenamer.lv.items.item[i-1].Subitems.Item[1].text=ii[2]
            )
         )
      )
   P_ObjectRenamer.lv.Update()
      return true
   )

   local rows=#()
   if refresh_==#true do
   (
      for i=1 to Result_list1.count do
      (
        a=dotNetObject "ListViewItem" Result_list1[i]
        a.subitems.add ("Preview X")
        append rows a
      )
   P_ObjectRenamer.lv.items.clear()
   P_ObjectRenamer.lv.items.addRange rows
   P_ObjectRenamer.lv.Update()
   )
  if preview_mode==false do (return false)
   
   for i=1 to Result_list1.count do
   (
      text_=edit_name_text
      if (P_ObjectRenamer.chk_Select_Item_Only.state==true) and (not (check_Selected i)) do
      (
         append Result_list2 obj_namelist[i]
         continue
      )
      for i3=1 to 30 do
      (
         found_N=(findString text_ "[N]")
         if (found_N!=undefined) then 
         (
            text_=replace text_ found_N 3 obj_namelist[i]
         )
         else (exit)
      )
      
      for i3=1 to 30 do
      (
         found_N=(findString text_ "[Y]")
         if (found_N!=undefined) then 
         (
            text_=replace text_ found_N 3 (((getLocalTime())[1]) as string)
         )
         else (exit)
      )
      
      for i3=1 to 30 do
      (
         found_N=(findString text_ "[M]")
         if (found_N!=undefined) then 
         (
            text_=replace text_ found_N 3 (((getLocalTime())[2]) as string)
         )
         else (exit)
      )
      
      for i3=1 to 30 do
      (
         found_N=(findString text_ "[D]")
         if (found_N!=undefined) then 
         (
            text_=replace text_ found_N 3 (((getLocalTime())[4]) as string)
         )
         else (exit)
      )
      
      for i3=1 to 30 do
      (
         found_N=(findString text_ "[T]")
         if (found_N!=undefined) then 
         (
            text_=replace text_ found_N 3 (((getLocalTime())[5]) as string)+":"+(((getLocalTime())[6]) as string)
         )
         else (exit)
      )
      
      for i3=1 to 30 do
      (
         found_C=(findString text_ "[C]")
         if (found_C!=undefined) then 
         (
            C_=number_count+interval_
            C_=C_ as string
            if (C_.count<digit) do
            (
               R_=C_
               for ii=1 to (digit-C_.count) do
               (
                  R_="0"+R_
               )
               C_=R_
            )
            text_=replace text_ found_C 3 C_
         )
         else (exit)
      )
      
      
      for i3=1 to 30 do
      (
         found_N=(findString text_ "[N")
         if (found_N!=undefined) then 
         (
            found_NN=findstring text_ "]"
            if (found_NN!=undefined) then 
            (
               range_text=substring text_ (found_N+2) (found_NN-found_N-2)
               range_arr=(FilterString range_text "~") 
               
               if range_arr.count==2 then
               (
                  if ((range_arr[1] as integer)==undefined) or ((range_arr[2] as integer)==undefined) then
                  (text_="<Error>  "+obj_namelist[i]; exit)
                  else
                  (
                     if ((range_arr[1] as integer)<1) do (text_="<Error>  "+obj_namelist[i]; exit)
                     if ((range_arr[2] as integer)>=(range_arr[1] as integer)) then
                     (
                        substring_original_name=substring obj_namelist[i] (range_arr[1] as integer) ((range_arr[2] as integer)-(range_arr[1] as integer)+1)
                        text_=replace text_ found_N (found_NN-found_N+1) substring_original_name
                     )
                     else if ((range_arr[2] as integer)<1) then
                     (
                        substring_original_name=substring obj_namelist[i] (range_arr[1] as integer) (obj_namelist[i].count+(range_arr[2] as integer)-(range_arr[1] as integer)+1)
                        text_=(replace text_ found_N (found_NN-found_N+1) substring_original_name)
                         if (obj_namelist[i]==text_) or (text_=="") do (text_="Error"; exit)
                     )
                     else
                     (text_="Error"; exit)
                  )
               )
               else if range_arr.count==1 then
               (
                  if ((range_arr[1] as integer)==undefined) then
                  (text_="<Error>  "+obj_namelist[i]; exit)
                  else 
                  (
                     if ((range_arr[1] as integer)<1) do (text_="<Error>  "+obj_namelist[i]; exit)
                     substring_original_name=substring obj_namelist[i] (range_arr[1] as integer) 1
                     text_=replace text_ found_N (found_NN-found_N+1) substring_original_name
                  )
               )
               else 
               (text_="<Error>  "+obj_namelist[i]; exit)               
            )
            else (exit)
         )
         else (exit)
      )
      local from_=P_ObjectRenamer.edt_From.text
      
      if (from_!="") do
      (
         text_=replace_with_pattern text_ from_ (P_ObjectRenamer.edt_To.text)
      )
      
      
     E5=text_
     
     
      case P_ObjectRenamer.ddl_Upper.selection  of
      (
         1:()
         2:(E5= toUpper E5)
         4:(a=E5[1]; a=(toUpper a); E5=a+(tolower (substring E5 2 E5.count) ))
         3:(
            E5= tolower E5
            a=E5[1]; a=(toUpper a); E5=a+(tolower (substring E5 2 E5.count) )
            for i=1 to (E5.count-1) do
            (
               if (E5[i]==" ") or (E5[i]==".") or (E5[i]=="_") or (E5[i]=="-") do 
               (
                  b=(substring E5 1 i)+(toUpper (E5[i+1]))+(substring E5 (i+2) (E5.count))
                  E5=b
               )
            )
            )
         5:(E5= toLower E5)
         7:(a=E5[1]; a=(toLower a); E5=a+(toUpper (substring E5 2 E5.count) ))
         6:(
            E5= toUpper E5
            a=E5[1]; a=(toLower a); E5=a+(toUpper (substring E5 2 E5.count) )
            for i=1 to (E5.count-1) do
            (
               if (E5[i]==" ") or (E5[i]==".") or (E5[i]=="_") or (E5[i]=="-") do 
               (
                  b=(substring E5 1 i)+(toLower (E5[i+1]))+(substring E5 (i+2) (E5.count))
                  E5=b
               )
            )
            )
         default:()
      )
         
     
     text_=E5
     
     
     
     /*
      if (P_ObjectRenamer.rdo_Upper_Lower.state==1) then
      (
         text_= toUpper text_
      )
      else if (P_ObjectRenamer.rdo_Upper_Lower.state==2) then
      (
         text_= toLower text_
      )
      */
      number_count+=interval_
      append Result_list2 text_
   )
   rows=#()
   --P_ObjectRenamer.lbx2.items=Result_list2
   if refresh_==#true do
   (
      for i=1 to Result_list2.count do
      (
        a=dotNetObject "ListViewItem" Result_list1[i]
        a.subitems.add (Result_list2[i])
        append rows a
      )
   P_ObjectRenamer.lv.items.clear()
   P_ObjectRenamer.lv.items.addRange rows
   P_ObjectRenamer.lv.Update()
   return 0
   )
   if preview_mode==false do (return false)
   for i=1 to Result_list2.count do
   (
   P_ObjectRenamer.lv.items.item[i-1].Subitems.Item[1].text=Result_list2[i]
   )
   P_ObjectRenamer.lv.Update()

   
   
)

fn Select_load=
(
   obj_list=#()
   obj_namelist=#()
   for i in $selection do
   (
      append obj_list #(i,i.name)
   )
   obj_list_Original_sort=deepcopy obj_list
)


function refresh=
(
   obj_namelist=#()
   if P_ObjectRenamer.radio_Sort.state==2 then
   (qsort obj_list nsort)
   else 
   (
      obj_list=deepcopy obj_list_Original_sort
   )
   for i in obj_list do
   (
      try
      (
      append obj_namelist (i[1].name)
      )catch()
   )
   --P_ObjectRenamer.lbx1.items=obj_namelist
   --update_()
)
   


directory_check_and_make ((getdir #vpost)+"\\P_ObjectRenamer")
directory_check_and_make Dir_
directory_check_and_make Dir2_

if (doesFileExist (Dir_+"Default.txt"))==false do
(
   text_="[N]\n1\n1\n1\n\n\n3\nfalse\nfalse"
   save_file=createfile (Dir_+"Default.txt")
   format text_ to:save_file
   close save_file
)

rollout P_ObjectRenamer "超级重命名工具_v1.4" width:696 height:512
(
   
   label 'Lb_sortby' "排序依据" pos:[466,56] width:80 height:16 align:#left
   multilistbox 'lbx1' "" pos:[1008,8] width:220 height:38  align:#left
   multilistbox 'lbx2' "" pos:[1228,8] width:220 height:38  align:#left
   dotNetControl 'lv' "system.windows.forms.listView" pos:[8,8] width:440 height:480 Enable:false align:#left
   label 'Creator' "Author by P_MAN" pos:[12,493] width:100 height:16 align:#left
   hyperLink 'Homepage' "https://aksmfakt132.wixsite.com/pman" address:"https://aksmfakt132.wixsite.com/pman" pos:[110,493]  visitedColor:white
   hyperLink 'email' "aksmfakt132@gmail.com" address:"mailto:aksmfakt132@gmail.com" pos:[310,493] visitedColor:white
   
   button 'Onload' "加载选择物体" pos:[456,8] width:180 height:40 align:#left
   button 'Preview_btn' "预览" pos:[636,8] width:50 height:40 align:#left
   radiobuttons 'radio_Sort' "" pos:[556,56] width:162 height:16 labels:#("选择", "字母") columns:2 align:#left default:2
   
   
   GroupBox 'grp_Rename_List' "使用重命名列表" pos:[456,80] width:232 height:72 align:#left
   button 'btn_New_List' "新建列表" pos:[464,96] width:104 height:48 align:#left
   button 'btn_Load_List' "加载列表" pos:[576,96] width:104 height:48 align:#left
   
   
   GroupBox 'grp_Rename_Tool' "重命名工具" pos:[456,160] width:232 height:296 align:#left
   dropDownList 'ddl_Preset' "" pos:[464,176] width:115 height:22 align:#left
   button 'btn_Preset_Save' "保存" pos:[584,176] width:48 height:24 align:#left
   button 'btn_Preset_Delete' "删除" pos:[632,176] width:48 height:24 align:#left
   
   label 'lbl0' "编辑命名" pos:[464,200] width:64 height:16 align:#left
   button 'Orignal_name_btn' "原命名/[N]" pos:[620,238] width:64 height:16 align:#left
   dotNetControl edt_Edit_Name "TextBox" pos:[460,216] width:224 height:24
   label 'lbl1' "[N] : 原始命名" pos:[464,240] width:120 height:16 align:#left
   label 'lbl2' "[Na~b]/[Na~-b] : 范围  [Y][M][D][T] : 时间" pos:[464,256] width:220 height:16 align:#left
   label 'lbl3' "[C] : 计数" pos:[464,272] width:56 height:16 align:#left
   spinner 'spn_First_Number' "" pos:[560,272] width:40 height:16 range:[0,1000,1] align:#left type:#integer
   spinner 'spn_Interval' "" pos:[600,272] width:40 height:16 range:[1,100,1] align:#left type:#integer
   spinner 'spn_Digit' "" pos:[640,272] width:40 height:16 range:[1,4,1] align:#left type:#integer
   label 'lbl4' "- 第一位 / 间隔 / 数位" pos:[552,288] width:152 height:16 align:#left
   label 'lbl5' "------------------------------------------------------" pos:[464,304] width:216 height:16 align:#left
   
   label 'lbl6' "替换命名                            通配符 : ? *" pos:[464,320] width:220 height:16 align:#left
   label 'lbl7' "源词缀" pos:[464,339] width:50 height:16 align:#left
   --edittext 'edt_From' "" pos:[496,336] width:184 height:1 align:#left
   dotNetControl edt_From "TextBox" pos:[510,336] width:170 height:24 align:#left
   label 'lbl8' "替换为" pos:[464,362] width:50 height:16 align:#left
   --edittext 'edt_To' "" pos:[496,360] width:184 height:1 align:#left
   dotNetControl edt_To "TextBox" pos:[510,360] width:170 height:24 align:#left
   label 'lbl9' "------------------------------------------------------" pos:[464,384] width:216 height:16 align:#left
   
   label 'lbl10' "设置" pos:[464,400] width:120 height:30 align:#left
   dropDownList 'ddl_Upper' "" pos:[564,396] width:120 height:30 align:#left items:#("默认","UPPER_A","Upper_B","Upper_c","lower_a","lOWER_b","lOWER_C")
   --radiobuttons 'rdo_Upper_Lower' "" pos:[1464,396] width:160 height:30 labels:#("Uppercase", "Lowercase","None") columns:3 align:#left default:3
   checkbox 'chk_Unique_Name' "命名唯一 (Preview X)" pos:[464,420] width:138 height:16 align:#left
   checkbox 'chk_Select_Item_Only' "仅列表选择项" pos:[464,436] width:108 height:16 align:#left
   
   
   button 'btn_Reset' "重置设置" pos:[456,464] width:72 height:40 align:#left
   button 'btn_Apply' "执行" pos:[536,464] width:152 height:40 align:#left
   
   
   
   on P_ObjectRenamer open do
   (
      edt_Edit_Name.TEXT="[N]"
      Select_load()
      refresh()
      update_ refresh_:#true
      update_preset()
      lv.backcolor = maxBC ; lv.forecolor = maxFC
      lv.view = (dotNetClass "View").details
      lv.FullRowSelect=true
      lv.HideSelection = false ; 
      AddColumns lv #("原命名", "新命名")
      lv.columns.item[0].width=218
      lv.columns.item[1].width=218
      edt_Edit_Name.backcolor=textbox_color
      edt_Edit_Name.forecolor=textbox_textcolor
      edt_From.backcolor=textbox_color
      edt_From.forecolor=textbox_textcolor
      edt_To.backcolor=textbox_color
      edt_To.forecolor=textbox_textcolor
      
   )
   
   
   on Onload pressed do
   (
      Select_load()
      refresh()
      update_ refresh_:#true
   )
   
   on Preview_btn pressed do
   (
     preview_mode = not(preview_mode)
      update_ refresh_:#true
   )
      
   on radio_Sort changed arg do
   (
      refresh()
      update_ refresh_:#true
   )
   
   on lv Mouseup do
   (
      selected_list=#()
      for i =1 to  lv.SelectedItems.count do
      (
         append selected_list ((lv.SelectedItems.item[i-1].index)+1)
      )
     if (Onload.enabled==true) do
     (
        update_ ()
     )
  )
   
   
   
   on btn_New_List pressed do
   (
      filename_=Dialog_modal "Rename List name" ""
      if (filename_==false) do 
      (
         return false
      )
      text_="/////////////////////How To Use/////////////////////\n"+
            "Old name and New Name are separated using '==>'\n"+
            "\n"+
            "Example:\n"+
            "Old Name==>New Name\n"+
            "this is Too long Old name==>This is Too long New name\n"+
            "Box001==>New_Named_Box001\n"+
            "Plane001==>New_Named_Plane001\n\n"+
            "///////////////////////////////////////////////////////\n\n"

      save_file=createfile (Dir2_+filename_+".txt")
      format text_ to:save_file
      close save_file
      shellLaunch   (Dir2_+filename_+".txt") ""
      
      update_ ()
   )
   
   on btn_New_List rightclick do
   (
      doscommand ("explorer " + Dir2_)
   )
   
   on btn_Load_List pressed do
   (
      New_Script=getOpenFileName caption:"Open A List File:" types:"Text(*.txt)|*.txt;" filename:Dir2_
      if (New_Script==undefined) do (return 0)
      
      file=openfile New_Script mode:"r"
      Rename_file_Arr=#()
      
      while not eof file do
      (
         l=readline file
         ll=FilterString l "==>"
         if ll.count==2 do
         (
            append Rename_file_Arr ll
         )
      )
      close file
      btn_Load_List.text="Load List\n["+(getFilenameFile New_Script)+"]"
      
      update_ mode:"Rename_List"
      
      Onload.enabled=false
      radio_Sort.enabled=false
      btn_New_List.enabled=false
      btn_Preset_Save.enabled=false
      btn_Preset_Delete.enabled=false
      lbl0.enabled=false
      lbl1.enabled=false
      lbl2.enabled=false
      lbl3.enabled=false
      lbl4.enabled=false
      lbl5.enabled=false
      lbl6.enabled=false
      lbl7.enabled=false
      lbl8.enabled=false
      lbl9.enabled=false
      ddl_Preset.enabled=false
      edt_Edit_Name.enabled=false
     edt_Edit_Name.text="[N]"
      spn_First_Number.enabled=false
      spn_Interval.enabled=false
      spn_Digit.enabled=false
      edt_From.enabled=false
     edt_From.text=""
      edt_To.enabled=false
     edt_To.text=""
     ddl_Upper.selection=1
     ddl_Upper.enabled=false
      --rdo_Upper_Lower.enabled=false
     --rdo_Upper_Lower.state=3
      chk_Unique_Name.enabled=false
     chk_Unique_Name.state=false
      chk_Select_Item_Only.enabled=false
     chk_Select_Item_Only.state=false
   )
   
   on btn_Load_List rightclick do
   (
      doscommand ("explorer " + Dir2_)
   )
   
   on ddl_Preset selected arg do
   (
      filename=Dir_+(ddl_Preset.selected)+".txt"
      file=openfile filename mode:"r"
      filearr=#()
      while not eof file do
      (
         l=readline file
         append filearr l
      )
      close file
      
      edt_Edit_Name.text=filearr[1] as string
      spn_First_Number.value=(filearr[2]) as integer
      spn_Interval.value=(filearr[3]) as integer
      spn_Digit.value=(filearr[4]) as integer
      edt_From.text=filearr[5] as string
      edt_To.text=filearr[6] as string
	  ddl_Upper.selection=filearr[7] as integer
      --rdo_Upper_Lower.state=(filearr[7]) as integer
      chk_Unique_Name.state=false
      if filearr[8]=="true" do chk_Unique_Name.state=true
      chk_Select_Item_Only.state=false
      if filearr[8]=="true" do chk_Select_Item_Only.state=true
         
      update_()
   )
   
   on btn_Preset_Save pressed do
   (
      filename_=Dialog_modal "Preset name" ""
      if (filename_==false) do 
      (
         return false
      )
      
      text_=(edt_Edit_Name.text)+"\n"+(spn_First_Number.value as string)+"\n"+(spn_Interval.value as string)+"\n"+(spn_Digit.value as string)+"\n"+(edt_From.text)+"\n"+(edt_To.text)+"\n"+
                           (ddl_Upper.selection as string)+"\n"+(chk_Unique_Name.state as string)+"\n"+(chk_Select_Item_Only.state as string)
      save_file=createfile (Dir_+filename_+".txt")
      format text_ to:save_file
      close save_file
      
      update_preset()
      ddl_Preset.selection=(ddl_Preset.items.count)
   )
   
   on btn_Preset_Delete pressed do
   (
      current_selection=ddl_Preset.selection
      filename=Dir_+(ddl_Preset.selected)+".txt"
      try(deletefile filename) catch()
      update_preset()
      ddl_Preset.selection=current_selection-1
      update_()
   )
   
   on Orignal_name_btn pressed do 
   (
      if edt_Edit_Name.text=="[N]" and (lv.SelectedItems.count!=0) then 
      (
         edt_Edit_Name.text=(lv.SelectedItems.item[0].text); update_()
         /*
         a=(cbx_bm.selection as array); 
         if a.count==0 do (return false)
         Edit_Rename.text=(getFilenameFile (arrPaths[a[1]]))
         update_preview()*/
      )
      else (edt_Edit_Name.text="[N]"; update_())
   )
   
   on spn_First_Number changed arg do
   (
      update_()
   )
   
   on spn_Interval changed arg do
   (
      update_()
   )
   
   on spn_Digit changed arg do
   (
      update_()
   )
   
   on edt_Edit_Name Keydown  arg do
   (
      update_()
   )
   
   on edt_From Keydown  arg do
   (
      update_()
   )
   
   on edt_To Keydown  arg do
   (
      update_()
   )
   
   on edt_Edit_Name Keyup  arg do
   (
      update_()
   )
   
   on edt_From Keyup  arg do
   (
      update_()
   )
   
   on edt_To Keyup  arg do
   (
      update_()
   )
   
   on chk_Select_Item_Only changed arg do
   (
      update_()
   )
   
   on ddl_Upper selected  arg do
   (
      update_()
   )
   /*
   on rdo_Upper_Lower changed arg do
   (
      update_()
   )
   */
   
   
   on btn_Reset pressed do
   (   
      btn_Load_List.text="Load List"
      
      edt_Edit_Name.text="[N]"
      spn_First_Number.value=1
      spn_Interval.value=1
      spn_Digit.value=1
      edt_From.text=""
      edt_To.text=""
     ddl_Upper.selection=1
      --rdo_Upper_Lower.state=3
      chk_Unique_Name.state=false
      chk_Select_Item_Only.state=false
         
      Onload.enabled=true
      radio_Sort.enabled=true
      btn_New_List.enabled=true
      btn_Preset_Save.enabled=true
      btn_Preset_Delete.enabled=true
      lbl0.enabled=true
      lbl1.enabled=true
      lbl2.enabled=true
      lbl3.enabled=true
      lbl4.enabled=true
      lbl5.enabled=true
      lbl6.enabled=true
      lbl7.enabled=true
      lbl8.enabled=true
      lbl9.enabled=true
      ddl_Preset.enabled=true
      edt_Edit_Name.enabled=true
      spn_First_Number.enabled=true
      spn_Interval.enabled=true
      spn_Digit.enabled=true
      edt_From.enabled=true
      edt_To.enabled=true
     ddl_Upper.enabled=true
      --rdo_Upper_Lower.enabled=true
      chk_Unique_Name.enabled=true
      chk_Select_Item_Only.enabled=true
      
     update_ ()
   )
   
   on btn_Apply pressed do
   (
     pre_= preview_mode 
     preview_mode =true
	
	   selected_arr=#()
     -- if btn_Preset_Delete.enabled==false and (btn_Load_List.enabled==true) do (update_ refresh_:#true)
    --if btn_Preset_Delete.enabled==true do (update_ refresh_:#true)
      error_count=0
      missing_count=0
      
      for i=1 to obj_list.count do
      (
         if ((findstring (P_ObjectRenamer.lv.items.item[i-1].Subitems.Item[1].text) "<Error>")==undefined) do
         (
            try
            (
               obj_list[i][1].name=P_ObjectRenamer.lv.items.item[i-1].Subitems.Item[1].text
               if (chk_Unique_Name.state==true) do 
               (
                  obj_list[i][1].name=P_ObjectRenamer.lv.items.item[i-1].Subitems.Item[1].text
               )
            ) catch()
         )
      )
      
      Messagebox "Rename Success"
     
      refresh()
      update_ refresh_:#true
      preview_mode=pre_
      update_ refresh_:#true
   )
)



CreateDialog P_ObjectRenamer

)






