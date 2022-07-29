try(destroydialog rolBsCameraTools)catch()
rollout rolBsCameraTools "" width:430 height:450
(
	label lblTitle "[相机工具] BsCameraTools_v1.0 只是框架还没做"  align:#left
	edittext edtInputText "命名"  offset:[0,6] width:165 height:17 text:"Text"
	button btnAdd "添加输入"  offset:[10,-22] width:70 height:17
	button btnDel "删除选择"  offset:[90,-22] width:70 height:17
	button btnRefresh "刷新"  offset:[170,-22] width:70 height:17
	multiListBox mlbxClass ""  offset:[0,5] width:165 height:20 items:#()
	multiListBox mlbxViewportShot ""  offset:[175,-272] width:230 height:20 items:#()
	GroupBox grpTools "Group Box"  width:405 height:112
)
createdialog rolBsCameraTools