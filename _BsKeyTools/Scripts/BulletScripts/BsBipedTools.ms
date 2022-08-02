--TODO：BipedTools 新做
messagebox "CS 选择工具 重构中...暂时可右键打开老版本                        " title:"BsKeyTools"
try(Form1.close())catch()
	
Form1 = dotNetObject "MaxCustomControls.MaxForm"
button1 = dotNetObject "System.Windows.Forms.Button"
button2 = dotNetObject "System.Windows.Forms.Button"
button3 = dotNetObject "System.Windows.Forms.Button"
button4 = dotNetObject "System.Windows.Forms.Button"
listBox1 = dotNetObject "System.Windows.Forms.ListBox"
trackBar1 = dotNetObject "System.Windows.Forms.TrackBar"
numericUpDown1 = dotNetObject "System.Windows.Forms.NumericUpDown"
checkedListBox1 = dotNetObject "System.Windows.Forms.CheckedListBox"
-- button1
button1.BackColor = (dotNetClass "System.Drawing.Color").Black
button1.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
button1.ForeColor = (dotNetClass "System.Drawing.Color").Coral
button1.Location = dotNetObject "System.Drawing.Point" 12 12
button1.Name = "button1"
button1.Size = dotNetObject "System.Drawing.Size" 107 45
button1.TabIndex = 0
button1.Text = "button1"
button1.UseVisualStyleBackColor = False
-- button2
button2.BackColor = (dotNetClass "System.Drawing.Color").Black
button2.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
button2.ForeColor = (dotNetClass "System.Drawing.Color").Coral
button2.Location = dotNetObject "System.Drawing.Point" 12 65
button2.Name = "button2"
button2.Size = dotNetObject "System.Drawing.Size" 107 45
button2.TabIndex = 1
button2.Text = "button2"
button2.UseVisualStyleBackColor = False
-- button3
button3.BackColor = (dotNetClass "System.Drawing.Color").Black
button3.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
button3.ForeColor = (dotNetClass "System.Drawing.Color").Coral
button3.Location = dotNetObject "System.Drawing.Point" 12 118
button3.Name = "button3"
button3.Size = dotNetObject "System.Drawing.Size" 107 45
button3.TabIndex = 2
button3.Text = "button3"
button3.UseVisualStyleBackColor = False
-- button4
button4.BackColor = (dotNetClass "System.Drawing.Color").Black
button4.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
button4.ForeColor = (dotNetClass "System.Drawing.Color").Coral
button4.Location = dotNetObject "System.Drawing.Point" 12 171
button4.Name = "button4"
button4.Size = dotNetObject "System.Drawing.Size" 107 45
button4.TabIndex = 3
button4.Text = "button4"
button4.UseVisualStyleBackColor = False
-- listBox1
listBox1.BackColor = (dotNetClass "System.Drawing.Color").Black
listBox1.ForeColor = (dotNetClass "System.Drawing.Color").Yellow
listBox1.FormattingEnabled = True
listBox1.ItemHeight = 12
listBox1.Items.Add("111")
listBox1.Items.Add("222")
listBox1.Items.Add("333")
listBox1.Items.Add("444")
listBox1.Items.Add("555")
listBox1.Items.Add("666")
listBox1.Items.Add("777")
listBox1.Location = dotNetObject "System.Drawing.Point" 125 12
listBox1.Name = "listBox1"
listBox1.Size = dotNetObject "System.Drawing.Size" 120 208
listBox1.TabIndex = 4
-- trackBar1
trackBar1.BackColor = (dotNetClass "System.Drawing.Color").Black
trackBar1.Location = dotNetObject "System.Drawing.Point" 12 223
trackBar1.Name = "trackBar1"
trackBar1.Size = dotNetObject "System.Drawing.Size" 360 45
trackBar1.TabIndex = 5
-- numericUpDown1
numericUpDown1.BackColor = (dotNetClass "System.Drawing.Color").Black
numericUpDown1.ForeColor = (dotNetClass "System.Drawing.Color").YellowGreen
numericUpDown1.Location = dotNetObject "System.Drawing.Point" 252 13
numericUpDown1.Name = "numericUpDown1"
numericUpDown1.Size = dotNetObject "System.Drawing.Size" 120 21
numericUpDown1.TabIndex = 6
-- checkedListBox1
checkedListBox1.BackColor = (dotNetClass "System.Drawing.Color").Black
checkedListBox1.ForeColor = (dotNetClass "System.Drawing.Color").Aqua
checkedListBox1.FormattingEnabled = True
checkedListBox1.Items.Add("1")
checkedListBox1.Items.Add("2")
checkedListBox1.Items.Add("3")
checkedListBox1.Items.Add("4")
checkedListBox1.Items.Add("5")
checkedListBox1.Items.Add("6")
checkedListBox1.Location = dotNetObject "System.Drawing.Point" 252 41
checkedListBox1.Name = "checkedListBox1"
checkedListBox1.Size = dotNetObject "System.Drawing.Size" 120 180
checkedListBox1.TabIndex = 7
-- Form1
Form1.BackColor = (dotNetClass "System.Drawing.Color").LightPink
Form1.ClientSize = dotNetObject "System.Drawing.Size" 383 281
Form1.Controls.Add(checkedListBox1)
Form1.Controls.Add(numericUpDown1)
Form1.Controls.Add(trackBar1)
Form1.Controls.Add(listBox1)
Form1.Controls.Add(button4)
Form1.Controls.Add(button3)
Form1.Controls.Add(button2)
Form1.Controls.Add(button1)
Form1.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").SizableToolWindow
Form1.Name = "Form1"
Form1.Opacity = 0.5
Form1.ShowIcon = False
Form1.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").CenterScreen
Form1.Text = "Form1"
Form1.TransparencyKey = (dotNetClass "System.Drawing.Color").LightPink
Form1.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").None
-- Form1.Show()
thePtr = DotNetObject "System.IntPtr" (windows.getMAXHWND())
theHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" thePtr
Form1.Show(theHwnd)

global mouseOffsetBipedTools = [0,0]
global stateDraggingBipedTools = 0

fn fnMouseDown dotObject evnt =
(
    mouseOffsetBipedTools[1] = mouse.screenPos.x - Form1.left
    mouseOffsetBipedTools[2] = mouse.screenPos.y - Form1.top
    global stateDraggingBipedTools=1
)
dotnet.addEventHandler Form1 "MouseDown" fnMouseDown

fn fnMouseMove dotObject evnt =
(
    if stateDraggingBipedTools==1 then
    (
    local FormPos = #()
    local NewPos = #()  
    FormPos[1] = Form1.left
    FormPos[2] = Form1.top
        
    NewPos[1] = mouse.screenpos.x - mouseOffsetBipedTools[1]
    NewPos[2] = mouse.screenpos.y - mouseOffsetBipedTools[2]
    
    Form1.left = NewPos[1]
    Form1.top = NewPos[2]
    )
)
dotnet.addEventHandler Form1 "MouseMove" fnMouseMove

fn lbl_AssetIDUp dotObject evnt =
(
    global stateDraggingBipedTools=0
)
dotnet.addEventHandler Form1 "MouseUp" lbl_AssetIDUp