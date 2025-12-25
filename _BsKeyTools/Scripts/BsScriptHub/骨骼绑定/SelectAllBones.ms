/*
    SelectAllBones - 选择所有骨骼
    Author: Bullet.S
*/

try (
    bones = for o in objects where (
        classOf o == BoneGeometry or 
        classOf o == Biped_Object or
        (classOf o).categories[1] == "CAT Objects"
    ) collect o
    
    if bones.count == 0 then (
        messageBox "场景中没有找到骨骼" title:"SelectAllBones"
    ) else (
        select bones
        format "已选择 % 个骨骼\n" bones.count
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"SelectAllBones"
)

