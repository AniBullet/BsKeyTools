(
	macroScript BulletKeyTools
	category:"_[BulletTools]"
	buttonText:"BsKeyTools"
	toolTip:"BsKeyTools"
	-- icon:#("VCRControls", 25)
	(
		on execute do
		(
			try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms"))
			catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
		)
	)
)