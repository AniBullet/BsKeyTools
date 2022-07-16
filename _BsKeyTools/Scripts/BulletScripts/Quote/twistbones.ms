/*TWISTBONES

Version 1.7
Author: Felix Joleanes
web:    www.joleanes.com
email:  felix@joleanes.com

utilidad para crear automaticamente los twistbones (TBs) de todas las extremidades
para un biped standard de max
la utilidad crea un TB principal con un rotation_script controller necesario para su funcionamiento
y varios TBs extras con orientation constraints desde el TB Principal hacia la extremidad respectiva, con
pesos respectivos a su posicion en la jerarquia de TBs


Modificacion version 1.6:
Se mejoro la ecuacion que halla el valor de compensacion el eje x para evitar el flipping del gimbal lock
ahora ya no existen los flipping que tenia la anterior version en siertos angulos, y ademas el hombro
mantiene una ubicacion mas correcta

Modificacion version 1.7:
el valor de rotacion del TB que evita heredar la rotacion del eje x de la extremidad ahora se halla
por medio de la construccion del quaternion de rotacion, de esta forma el resultado ser� m�s preciso.
*/

-- 用于自动创建所有肢体的扭骨 (TB) 的实用程序
-- 对于标准最大 Biped
-- 该实用程序创建一个主 TB，其中包含运行所需的 rotation_script 控制器
-- 和几个额外的 TB，从主 TB 到各自的末端有方向限制，
-- 各自在 TB 层级中的位置权重
-- 修改版本 1.6：
-- 改进了求x轴偏移值的公式，避免云台锁定翻转
-- 现在不再有以前版本在某些角度的翻转，还有肩膀
-- 保持更正确的位置

-- 修改版本 1.7：
-- 现在找到了避免继承肢体x轴旋转的TB旋转值
-- 通过旋转四元数的构造，这样结果会更精确。


-- macroScript twistbones
-- 	category:"Custom tools"
-- 	icon:#("Radiosity", 3)
-- (
try(destroydialog TBPersiana)catch()
rollout TBPersiana "Twist Bones_v1.8"
(
--Aqui se define la funcion que desarrolla todos los procedimientos necesarios para crear los twistbones
--tomando como argumento un arreglo n con cuatro variables definiendo la cantidad de twistbones por cada extremidad
--n=#(nBrazo,nAntebrazo,nMuslo,nPantorrilla)
--realiza esto tomando todos los bipedos de la escena

--这里定义了开发所有必要程序来创建扭骨的函数
--将数组 n 作为参数，其中包含四个变量，定义每个肢体的扭骨数量
--n=#(nArm,n前臂,n大腿,n小腿)
--通过获取场景中的所有 Biped 来完成此操作

function TBSetFunction n=
(
  --establesco algunas variables
  bipRoots=#()--arrreglo donde guardo todos los bips seleccionados de la escena
  bipLimbs=#()--arreglo que utilizo en un bucle para conocer que parte del bipedo esta siendo usada para crear los twistbones
  --se definen las variables que utilizare en la funcion biped.getNode para obtener la instancia respectiva al objeto siendo 
  --procesado, ademas defino una bandera que dice si se trata de una operacion inversa al algoritmo estandar usado en el hombro,
  --es falso si se trata del antebrazo o la pantorrilla.

  --设置一些变量
  -- bipRoots=#()--array 我保存场景中所有选定的哔声
  -- bipLimbs=#()--array 我在一个循环中使用来知道 Biped 的哪个部分被用来创建扭骨
  --我将在 biped.getNode 函数中使用的变量来获取对象的相应实例
  --已处理，我还定义了一个标志，表示它是否是肩部使用的标准算法的逆运算，
--如果是前臂或小腿则为假。

  bipLimbs[1]=#(#larm,2,n[1],1," L UpperArm")
  bipLimbs[2]=#(#rarm,2,n[1],1," R UpperArm")
  bipLimbs[3]=#(#larm,3,n[2],2," L ForeArm")
  bipLimbs[4]=#(#rarm,3,n[2],2," R ForeArm")
  bipLimbs[5]=#(#lleg,1,n[3],3," L Thigh")
  bipLimbs[6]=#(#rleg,1,n[3],3," R Thigh")
  bipLimbs[7]=#(#lleg,2,n[4],4," L Calf")
  bipLimbs[8]=#(#rleg,2,n[4],4," R Calf")
  
  --Las TBExpression son las expreciones de los script controllers de los TBs principales
  --una para cada par de extremidades (brazos, antebrazos...etc)
  
  --La Expresion A es para el Brazo-Hombro.
  --ya que el TB principal de esta zona esta vinculado al Brazo, este tendra 
  --que heredar solo los valores de rotacion en los ejes Y y Z del brazo, y el 
  --eje X lo heredara del hombro a partir de la ecuacion definida en el valor X del script controller
  --en el controlador no podemos dejar simplemente X en -X para compensar la rotacion,
  -- ya que existiria un flip en el TB superados los 90 o -90 grados con respecto al hombro sobre el eje Y,
  --debido a la falta de compesacion del gimbal Lock generados entre el eje X y Z.
  --para mejorar esto, utilizo el eje Z para compensar al eje X a travez con Y como multiplicador 
  --para que Z solo actue en X en angulos donde se necesite esta compensacion. asi no solo se evita el flip, 
  --si no que tambien el TB adopta posiciones adecuadas segun la rotacion del brazo, y cambios graduales
  --entre estas posiciones. Tambien se define un divisor en este resultado para ajustar los valores de compensacion
  --en los angulos adecuados

  --TBExpressions是主TB的脚本控制器的表达式
  --每对四肢一个（手臂、前臂……等）
  
  --Expression A 是 Arm-Shoulder。
  --由于该区域的主TB与Arm相关联，因此将有
  --只继承手臂的Y轴和Z轴的旋转值，而
  --X 轴将从肩部继承自脚本控制器的 X 值中定义的方程
--在控制器中，我们不能只将 X 留在 -X 中以补偿旋转，
  --因为 TB 相对于 Y 轴上的肩部会有超过 90 或 -90 度的翻转，
  --由于X轴和Z轴之间产生的云台锁定没有补偿。
  --为了改善这一点，我使用 Z 轴通过 Y 偏移 X 轴作为乘数
  --所以 Z 只在需要补偿的角度作用在 X 上。这样不仅可以避免翻转，
--而且TB也会根据手臂的旋转采取适当的姿势，并逐渐变化
  --在这些位置之间。在这个结果上还定义了一个除数来调整偏移值
  --直角

  TBExpressionA="try(
TM=Limb.transform*inverse Limb.parent.transform
vector=normalize (cross TM.row1 [1,0,0])
angle=acos (normalize TM.row1).x
(quat angle vector)*inverse TM.rotation)
catch((quat 0 0 0 1))"
  
  --La expresion B es para el AnteBrazo-mano, Ba para la mano derecha y Bb para la izquierda
  --el sistema es muy similar al del brazo-hombro, solo que aqui el valor de x es multiplicado por -1
  --esto ya que en este caso no se trata de bloquear la rotacion heredada, si no adquirir la rotacion
  --de otro nodo, ademas se utiliza un offset de 90 grados para retrasar el flipping de los TBs extra

  --B 表示前臂，Ba 表示右手，Bb 表示左手
  --该系统与臂肩系统非常相似，只是这里x的值乘以-1
  --this 因为在这种情况下，它不是阻止继承的旋转，而是获取旋转
  --从另一个节点，加上一个90度的偏移，用来延迟额外TB的翻转

  TBExpressionBa="try(
TM=(matrix3 [1,0,0] [0,0,-1] [0,1,0] [0,0,0])*Limb.transform*inverse Limb.parent.transform
vector=normalize (cross TM.row1 [1,0,0])
angle=acos (normalize TM.row1).x
TM.rotation*(quat -angle vector))
catch((quat 0 0 0 1))"
  TBExpressionBb="try(
TM=(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0])*Limb.transform*inverse Limb.parent.transform
vector=normalize (cross TM.row1 [1,0,0])
angle=acos (normalize TM.row1).x
TM.rotation*(quat -angle vector))
catch((quat 0 0 0 1))"

  
  --La expresion C es para la Pierna-Pelvis.
  --esta expresion es practicamente la misma del Brazo-Hombro, pero ya que
  --la orientacion neutral de la pierna con respecto a la pelvis es 180 grados
  --distinta a la del brazo-hombro, se debe rotar sobre el eje Z 180 grados
  --antes de ejecutar el calculo del valor de compensacion en X, y luego rotarlos
  --de nuevo en direccion opuesta para dejarlo en la posicion original

  --表达式 C 用于腿骨盆。
  --这个表达实际上与 Arm-Shoulder 相同，但由于
  --腿相对于骨盆的中立方向是180度
  --与臂肩不同，必须绕Z轴旋转180度
  --在计算 X 上的偏移值之前，然后旋转它们
  --再次以相反的方向将其留在原来的位置

  TBExpressionC="try(
TM=Limb.transform*inverse Limb.parent.transform
vector=normalize (cross -TM.row1 [1,0,0])
angle=acos -(normalize TM.row1).x
(quat 0 1 0 0)*(quat angle vector)*inverse TM.rotation)
catch((quat 0 0 0 1))"
  
  TBExpressionD="try(
TM=Limb.transform*inverse Limb.parent.transform
vector=normalize (cross TM.row1 [1,0,0])
angle=acos (normalize TM.row1).x
TM.rotation*(quat -angle vector))
catch((quat 0 0 0 1))"

  
  --Las TBExtraExpression son las expreciones de los script controllers de los TBs extras
  --una para las extremidades primarias (brazos,muslos) y otra para las extremidades
  --secudarias (antebrazos,pantorrillas)
  
  --en esta expresion se obtiene la orientacion de la extremidad con respecto al
  --TB. Junto con un valor apropiado en el weight de este controlador, se logra
  --un valor intermedio entre la extremidad y el TB. para todos los Tbs extras en la
  --cadena se utiliza el mismo weight(el cual depende del numero de Tbs extra), 
  --ya que al estar vinculado un TB extra al otro este primero acumula las rotaciones
  --de todos los anteriores mas la suya y de esta forma se aproxima cada ves mas
  --a la orientacion de la extremidad.
  --Esto es lo mismo que tener un orientation constraint con pesos relativos
  --a la posicion de los TBs extra en la cadena, pero con el metodo de scripts, 
  --si son muchos huesos extra, todos tendran referencia a un mismo controlador, 
  --lo cual a mi parecer es mas optimo que tener un controlador de orientacion 
  --distinto por cada TB extra con sus propios pesos.

  --TBExtraExpression是额外TB的脚本控制器的表达式
  --一个用于主要四肢（手臂、大腿），一个用于四肢
  --次要部位（前臂、小腿）
  
  --在这个表达式中，我们获得了肢体相对于
  --结核病。再加上该控制器重量的适当值，可实现
  --四肢和肺结核之间的中间值。对于所有额外的 Tb
--chain 使用相同的权重（这取决于额外 Tbs 的数量），
  --由于一个额外的 TB 链接到另一个，它首先累积旋转
  --在所有以前的加上他的，这样他每次都更接近
  --到四肢的方向。
  --这与具有相对权重的方向约束相同
  --到链中额外TB的位置，但是使用脚本方法，
--如果有很多额外的骨骼，它们都会引用同一个控制器，
  --在我看来，这比使用方向控制器更理想
  --每个额外的 TB 都有自己的权重不同。

  TBExtraExpressionA="try(
(Limb.transform*inverse LimbParent.transform).rotation
)catch((quat 0 0 0 1))"
  
  --este es similar al anterior pero aqui el script obtiene el valor del controlador
  --del TB principal en vez del valor de la rotacion de la extremidad con respecto al TB

  --这与上一个类似，但这里脚本获取控制器的值
  --主 TB 的值，而不是肢体相对于 TB 的旋转值

  TBExtraExpressionB="try(dependson TB
TB.rotation.controller[1].value
)catch((quat 0 0 0 1))"

  --en este bucle hallo todos los bips raices y los almaceno en el arreglo bipRoots
  --在这个循环中，我找到所有根哔哔声并将它们存储在 bipRoots 数组中

for i in selection do
(
  if (classof i.controller==BipSlave_Control) then
  (
		if (finditem bipRoots i.controller.rootnode)==0 then
    append bipRoots i.controller.rootnode
  )
  else if (classof i.controller==Vertical_Horizontal_Turn) then
  (
    if (finditem bipRoots i)==0 then
    append bipRoots i
  )
)
  
  --aqui empieza el bucle en donde se crean los TBs en todos los bipeds de la escena
  --arrancando con un "undo on" para encerrar todas los procesos en una sola operacion que se pueda deshacer
  --facilmente

--这里开始循环，在场景中的所有 Biped 中创建 TB
  --以“undo on”开头，将所有进程包含在一个可撤销的操作中
  --容易地

  for i in bipRoots do
  (
    --bucle que corre a travez de todas las extremidades donde se crean los TBs
    RLegAux=biped.getNode i #Rleg link:1
    LLegAux=biped.getNode i #Lleg link:1
    PelvisAux=biped.getNode i #pelvis
    
    RLegAux.parent=LLegAux.parent=PelvisAux

    for k in bipLimbs do
    (
      if (k[3]>0) then
      (
        Limb=biped.getNode i k[1] link:k[2] --obtengo la instancia de la extremidad a partir de las dos primeras variables del arreglo actual
        distanceVar=(distance limb limb.Children[1]) --longitud de la extremidad
        
        --defino algunas variables 
        TBExpression=""
        ControllerLimb=Limb
        weightVar=100
        --se decide cual sera la expresion del script que va a tener la extremidad actual
        --ademas de su cantidad de influencia (weight), y sus variables limb y limbparent
        case k[4] of
        (
          1:(TBExpression=TBExpressionA)
          2:(
            if k[1]==#larm then TBExpression=TBExpressionBb else TBExpression=TBExpressionBa
          ControllerLimb=Limb.children[1]
          weightVar=100/k[3]
            )
          3:(TBExpression=TBExpressionC)
          4:(
            TBExpression=TBExpressionD
          ControllerLimb=Limb.children[1]
          weightVar=100/k[3]
            )
        )
      
      --creo el TB principal, defino su nombre, su padre, sus caracteristicas geometricas, y le asigno su script controller
      --respectivo, con sus variables respectivas
        TwistBone=BoneSys.createBone Limb.transform.position Limb.transform.position [0,0,1] 
        TwistBone.name   = "Bone"+k[5]+" Twist"
        TwistBone.parent = Limb
        TwistBone.Length = distanceVar/k[3]
        TwistBone.Width  = distanceVar/8
        TwistBone.Height = TwistBone.Width
        TwistBone.taper  = 0
        TwistBone.rotation.controller = Rotation_List()
        TwistBone.rotation.controller[1].controller = rotation_script()
        TwistBone.rotation.controller[1].AddNode "Limb" ControllerLimb
        TwistBone.rotation.controller[1].SetExpression TBExpression
        TwistBone.rotation.controller.weight[1] = weightVar
        TwistBone.boxmode = true
      
        --creo el script controller que van a tener las rotaciones de los TBs extras,
        --es distinto el de los brazos y muslos al de los antebrazos, pantorrillas
        TBExtraController=rotation_script()
        case of
        (
          (k[4]==1 or k[4]==3):(
                                TBExtraController.AddNode "Limb" Limb 
                                TBExtraController.AddNode "LimbParent" TwistBone 
                                TBExtraController.setExpression TBExtraExpressionA
                    )
          (k[4]==2 or k[4]==4):(
                                TBExtraController.AddNode "TB" TwistBone
                                TBExtraController.setExpression TBExtraExpressionB
                    )
        )
        PrevTBE=TwistBone
        --el bucle donde se crean los TBs extras
          --por cada uno se define una posicion, el padre (el TB extra anterior, y si es el primero, se utiliza el TB principal) 
        --caracteristicas geometricas, y se le asigna a cada uno como rotation controller el TBExtraController
        for j=2 to k[3] do
        (
          TwistBoneExtra=BoneSys.createBone [0,0,0] [1,0,0] [0,0,1] 
          matAux=matrix3 1
          matAux.position=[(distanceVar/k[3]),0,0]
          TwistBoneExtra.transform=matAux*PrevTBE.transform
          TwistBoneExtra.name=TwistBone.name+((j-1) as string)
          TwistBoneExtra.parent=PrevTBE
          TwistBoneExtra.Length=distanceVar/k[3]
            TwistBoneExtra.Width=PrevTBE.Width
            TwistBoneExtra.Height=PrevTBE.Height
          TwistBoneExtra.taper=0
          TwistBoneExtra.rotation.controller=Rotation_List()
          TwistBoneExtra.rotation.controller[1].controller=TBExtraController
          TwistBoneExtra.rotation.controller.weight[1]=100/k[3]
          PrevTBE=TwistBoneExtra
        )
      )
    )
  )
  )
  --Aqui ya empiezo a crear los controles graficos de la utilidad
  --empezando con los spinner que definen cuantos TBs deberia tener cada extremidad
  group "数量设置 / Twist Bones"
  (
    spinner TBUpperArms "大臂 / UpperArms: " type:#integer range:[0,999999999,3] fieldwidth:30
    spinner TBForeArms "小臂 / ForeArms: " type:#integer range:[0,999999999,3] fieldwidth:30
    spinner TBThighs "大腿 / Thighs: " type:#integer range:[0,999999999,3] fieldwidth:30
    spinner TBCalves "小腿 / Calves: " type:#integer range:[0,999999999,3] fieldwidth:30
  )
  --boton para crear los TBs
  group "创建 Twist / Create Twist"
  (
    button TBSet "设置 Twist / Set TwisBones"
  )

  label lblTips "作者: Joleanes  修改: Bullet.S"
  
  on TBSet pressed do --evento que se ejecuta cuando opriman el boton
  (
    n=#(TBUpperArms.value,TBForeArms.value,TBThighs.value,TBCalves.value) --el arreglo que dice la cantidad de TBs por cada extremidad
    undo on TBSetFunction n -- llamado a la funcion
    messagebox "创建 Twist 成功，请勿多次点击，否则将创建多份重复 Twist Bone！                                                   "
  )
)

createDialog TBPersiana 180 185
-- )