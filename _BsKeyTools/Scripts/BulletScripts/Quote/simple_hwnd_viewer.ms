
-- Simple hWnd Viewer
-- by Pixamoon
-- www.pixamoon.com
-- pixamoon@gmail.com
-- v0.14

(
	fn CreateInstance_User32_Functions =
	(
		local s  = ""
		s += "using System;\n"
		s += "using System.Runtime.InteropServices;\n"
		s += "public class User32_Functions\n"
		s += "{\n"
		s += "	[DllImport(\"user32.dll\")]\n"
		s += "	public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, int wParam, System.Text.StringBuilder lParam);\n"
		s += "	[DllImport(\"user32.dll\")]\n"
		s += "	public static extern IntPtr WindowFromPoint(System.Drawing.Point aPoint);\n" -- add below "System.Drawing.dll"
		s += "}\n"

		local csharpProvider = dotNetObject "Microsoft.CSharp.CSharpCodeProvider"
		local compilerParams = dotNetObject "System.CodeDom.Compiler.CompilerParameters"
		compilerParams.GenerateInMemory = true
		compilerParams.ReferencedAssemblies.Add "System.dll"
		compilerParams.ReferencedAssemblies.Add "System.Drawing.dll"
		local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(s)
		compilerResults.CompiledAssembly.CreateInstance "User32_Functions"
	)
	if NOT isKindOf ::px_User32 dotNetObject do ::px_User32 = CreateInstance_User32_Functions()
	
	
	fn getListBoxItemText hWnd i = 
	(
		local txt = ""
		local LB_GETTEXT = 0x189
		local LB_GETTEXTLEN = 0x18A
		
		local len = windows.sendmessage hWnd LB_GETTEXTLEN i 0
		
		if len > 0 then (
			local str = dotnetObject "System.Text.StringBuilder" len
			
			px_User32.SendMessage (dotNetObject "System.IntPtr" hWnd) LB_GETTEXT i str
			
			txt = str.tostring()
		)

		return txt
	)
	
	try(destroyDialog ::hWndInstector) catch()
	
	rollout hWndInstector " Simple hWnd Viewer" width:400 height:700
	(
		local me = hWndInstector
		local PxmHL = color 0 150 200
		local lastTxt1 = ""
		local lastTxt2 = ""
		editText edt1 "" pos:[4,40] width:(me.width-8) height:(me.height-225) align:#left
		editText edt2 "" pos:[4,me.height-150] width:(me.width-8) height:119 align:#left
		label lbl1 "hWnd under mouse:" pos:[12,21] width:150 height:11 align:#left
		label lbl2 "ListBox Items:" pos:[12,me.height-165] width:120 height:11 align:#left
		
		label lb_Esc "[Esc] to Stop" pos:[10, me.height-20] align:#left
		button bn_Resume "Resume" pos:[10, me.height+20] width:60
		hyperLink Pixamoon "by Pixamoon" align:#right address:"http://www.pixamoon.com" pos:[me.width-70, me.height-20] Color:PxmHL VisitedColor:PxmHL
		
		timer tm1 interval:100 active:true
		
		on tm1 tick do (
		
			tm1.active = false
			
			local str = stringStream ""
			local txt = ""
			local txt2 = ""
			
			try(
				local mPos 	= (dotnetClass "System.Windows.Forms.Control").MousePosition
				
				local hwnd 	= px_User32.WindowFromPoint mPos
				local title 		= UIAccessor.GetWindowText 			hwnd
				local cls 		= UIAccessor.GetWindowClassName 	hwnd
				
				--format "%\n" (classof hWnd) to:str
				--format "Mouse pos: [%, %]\n" mPos.x mPos.y to:str
				--format "============ under mouse info ============ \n" to:str
				format "hWnd: %\n" hwnd to:str
				format "Text: %\n" title to:str
				format "Class: %\n" cls to:str
				
				
				local chwnd  = hwnd
				
				for i = 1 to 8 do (
					
					local phWnd 	= UIAccessor.GetParentWindow 			chwnd 
					local pTitle 	= UIAccessor.GetWindowText 			phWnd
					local pCls 		= UIAccessor.GetWindowClassName 	phWnd
					
					if phWnd == 0 do exit
					
					format "-----------------------------------------\n" to:str
					format "Parent% hWnd: %\n" i phWnd to:str
					format "Parent% text: %\n"	i pTitle to:str
					format "Parent% class: %\n" i pCls to:str
					
					chwnd  = phwnd
					
				)
				
				txt = str as string
				
				-- get infor form ListBox:
				
				if cls == "ListBox" do 
					for i = 0 to 100 do (
						local ItemTxt = getListBoxItemText hWnd i
						if itemTxt != "" then txt2 += ItemTxt as string + "\n" else exit
					)
				
			)catch(txt = (getcurrentException()) as string)
				
			-- protection against text flickering
			if txt != lastTxt1 then edt1.text = txt
			lastTxt1 = txt
			
			if txt2 != lastTxt2 then edt2.text = txt2
			lastTxt2 = txt2
			
			if keyboard.escPressed then (
				
				lb_Esc.pos 			= [10, me.height+20]
				bn_resume.pos 	= [4, me.height-25]
			)
			else
				tm1.active = true
		)
		
		on bn_Resume pressed do (
			lb_Esc.pos 			= [10, me.height-20]
			bn_resume.pos 	= [10, me.height+20]
			tm1.active = true
		)
	
	)
	
	createDialog ::hWndInstector
	
)
