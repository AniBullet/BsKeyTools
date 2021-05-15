--------------------------------------------------------------------------------------------------------
						--silhouette
--------------------------------------------------------------------------------------------------------
global store_amb--=color 0 0 0
global store_tint--=color 255 255 255
if (ambientColor==color 0 0 0) and (lightTintColor==color 0 0 0) then 
(
	ambientColor = store_amb
	lightTintColor = store_tint
	redrawViews()
) 
else 
(
	store_amb=ambientColor
	store_tint=lightTintColor
	ambientColor=color 0 0 0
	lightTintColor=color 0 0 0
	redrawViews()
)
deletekeys ambientColorController #allKeys
deletekeys lightTintColorController #allKeys