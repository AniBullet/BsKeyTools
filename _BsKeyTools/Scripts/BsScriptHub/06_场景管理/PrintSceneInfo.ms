/*
    PrintSceneInfo - 场景信息统计
    Author: Bullet.S
*/

try (
    totalFaces = 0
    geoCount = 0
    
    for o in objects where superClassOf o == GeometryClass do (
        geoCount += 1
        if canConvertTo o Editable_Mesh then (
            local tempMesh = snapshotAsMesh o
            totalFaces += tempMesh.numFaces
            delete tempMesh
        )
    )
    
    info = "=== 场景统计 ===\n"
    info += "对象总数: " + objects.count as string + "\n"
    info += "几何体数: " + geoCount as string + "\n"
    info += "总面数: " + totalFaces as string + "\n"
    info += "材质数: " + sceneMaterials.count as string + "\n"
    
    format "%\n" info
    messageBox info title:"场景信息"
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"PrintSceneInfo"
)

