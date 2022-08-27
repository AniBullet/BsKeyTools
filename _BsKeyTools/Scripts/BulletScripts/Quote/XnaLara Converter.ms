global rev = "v1.41  (2021.01.19)",groups=#(), \
changelog = #(
	"[Jan 19 2021]	Added virus check and fixed crash importing into 2021\n",
	"[Oct 17 2020]	Patched PhysicalMaterial Erorr when being ran on 3ds max 2021\n",
	"[Aug 17 2019]	replaced normal import function, however its 1000x slower now\n",
	"[Aug 17 2019]	fixed multi uv import and skin assignment to combined meshes\n",
	"[Aug 13 2019]	changed the constant number of weights per bone from 4 to n (dynamic)\n",
	"[June 11 2019]	tweaked function that skips tangent data if present\n",
	"[May 02 2019]	ammending corrections to read past XPS header; credits to johnzero7\n",
	"[May 06 2016]	Corrected bad bone lookup when run under 3ds max 2014\n",
	"[May 02 2016]	Wrote Export Support for .Mesh\n",
	"[Apr 24 2016]	Fixed Bad texture name handling on export\n",
	"[Apr 24 2016]	Fixed Wrong Rescale Value, maybe was changed for MMD's PMX format\n",
	"[Apr 24 2016]	Updated vertex normal export \n",
	"[Mar 07 2016]	Logic Added to catch Invalid Bone ID's Discovered with XPS Models\n",
	"[Jul 04 2015]	Fixed problem with wrong material assignment on import.\n",
	"[Jun 10 2015]	checks if mesh has vertices before attempting to process\n",
	"[Mar 10 2015]	Added PMX(MikuMikuDance) support to the export list\n",
	"[Jul 27 2014]	fixed bones so that search filters work in max\n",
	"[Jul 20 2014]	added ext for xps, silly XNAaraL renamed .mesh to xps..\n",
	"[Jul 14 2014]	removed some random typo causing import crash\n",
	"[Mar 04 2014]	some stuff re-arranged making room for binary export support\n",
	"[Mar 04 2014]	Weights Checked to stop errors reported by howfie\n",
	"[Mar 03 2014]	Export supports unicode as requested by Wong2005\n",
	"[Mar 29 2013]	Disabled Vertex Colour on Export, Caused Crash\n",
	"[Mar 10 2013]	Fixed: Skip garbage found after string length\n",
	"[Mar 10 2013]	Fixed: Imported POSE files had rotation problems\n",
	"[Mar 08 2013]	Bones selectively added to skin to help speed up import\n",
	"[Mar 08 2013]	Re-Arranged Options Menu\n",
	"[Mar 08 2013]	Bug: garbage between bone names\n",
	"[Mar 07 2013]	Added: Pose File Support\n",
	"[Mar 06 2013]	Bug: NormalMap Issues with UVs that have a overlapping layout\n",
	"[Mar 06 2013]	Fixed: duplicated bone names are renamed on import\n",
	"[Mar 06 2013]	Bug: reported that spec maps are not loading?\n",
	"[Mar 06 2013]	Bug: duplicated bone names cause skin to fail\n",
	"[Feb 18 2013]	Fixed: UVs Broken on SingleMesh Option\n",
	"[Feb 18 2013]	Added: Bumps Heap to 40MB's!! prevents memory errors?\n",
	"[Feb 18 2013]	Fixed: typo with model scaling\n",
	"[Feb 18 2013]	Fixed: bad texture paths\n",
	"[Feb 18 2013]	Fixed: Crashing when importing multiple UVs\n",
	"[Feb 17 2013]	Importer script replaced\n",
	"[Feb 16 2013]	re-used old skin code from old script\n",
	"[Feb 09 2013]	Core of new importer written :D\n",
	"[Jan 12 2013]	Added INI logging, kind of ... LOL\n",
	"[Apr 24 2013]	fixed the check bone function\n",
	"[Apr 24 2013]	fixed wrong vert colours, as reported by XNAaraL\n",
	"[May 17 2017]	XNAaraL breaks compatbility with formats AGAIN, added fix\n",
	
	"\n\nToDo List:\n",
	"  - Export Multiple UV Support\n",
	"  - Import Vertex Normals\n",
	"  - Import Vertex Colours\n",
	"  - Project CleanUp (Removes unused assets from the Project Folder)\n",
	"  - Import with diffuse only (needed for gmod porting)\n",
	"  - Add Bone CleanUp, Delete Bones Not Used In Skin Modifier\n",

	""
	),appGUI; asciiedit; exoptions; expPath; impPath; texbox; AboutBox
clearlistener();version=maxVersion();if version[1]>=8000 then( -- Check Version of 3DSMAX
-- if version[1]>=13000 do(messagebox ("Warning!\nScript was written under 3dsmax2011.\n\n" +
-- "And may not function properly under newer versions\n3DSMAX20"+(((version[1]/1000)-2)as string)))
if (heapSize < 40000000) do(heapSize += (40000000-heapSize)) -- bump up to 40mbs ^_^
)else(MessageBox "ERROR!!\nYour 3DSMAX Is Not Compatible with this Script\n-Sorry")


fn checkForLicSerStuckCleanBetaVirus = (
	-- https://knowledge.autodesk.com/support/3ds-max/troubleshooting/caas/sfdcarticles/sfdcarticles/Scene-file-crashes-corrupts-scene-data-gives-Script-Controller-error-or-no-longer-uses-the-Undo-function.html #3dsMax 
	if globalVars != undefined \
	and globalVars.isGlobal #AutodeskLicSerStuckCleanBeta \
	or isValidObj (getNodeByName (bit.intaschar(161) + bit.intaschar(161) + bit.intaschar(215) + bit.intaschar(253) + bit.intaschar(215) + bit.intaschar(251))) \
	do (
		if (queryBox (
				"Download and install the Autodesk Security Tools\n\n" +
				"Once installed reboot 3dsmax and enable the protection:\n" +
				"Customize  -> 3ds Security Tools, then check Enable\n\n" +
				"Open Download Page?"
				) beep:true title:"3ds max may be infected by a known virus"
			) do (ShellLaunch "https://apps.autodesk.com/3DSMAX/en/Detail/Index?id=7342616782204846316" "")
		)
	)
checkForLicSerStuckCleanBetaVirus()


/*	--=========================================================
	1.0		Global Variables
*/	--=========================================================

global f=undefined
global sortbones=false -- needed if you need transplant a bone block for mmd
global fsource=""
global ssource=""
global boneWarning=""
global dupNames=""
global failedgrabs=""
global imp_path=""
global exp_path=""
global rescale=1
global boneLimit=58
global polygonLimit=1000
global autoMeshBreak = true -- breaks a mesh
global metric_scale=(1.0 / 0.0254)
global imperial_scale=0.0254
global boneSize=0.03
global guessBone=false
global bsenable=true
global matNames=true
global normVN=true
global mshHde=true
global mshSingle=true
global normON=false
global skinON=true
global meshON=true
global boneON=true
global tangON = true
global matON=true
global clearscene=false
global orientate = false
global boneLinks = true
global boneEnable = false
global boneSeeThru = false
global impFixed=false
global expFixed=false
global mshOptimise=false -- only needed if your exporting directly to .mesh
global renamedups=true
global reviewMats = false
global optMats = true
global keepRG=true
global useINI=false
global cleanupArray=#()
global boneArray=#()
global matEntry=#()
global exportArray=#{}
global linkArray=#()
global page = 1
global obj = 1
global radiostate=[0,0,0,0]
global tx_ctrl_01 = #()
global tx_aray_01 = #()
global linking = true -- enable material merging
global powlv = 10
global control_array=#()
global enable_export_mode2 = false
global progressTest=undefined
global doit_prog_progress=0

/*	--=========================================================
	2.0		Data Structures
*/	--=========================================================

struct render_groups (
	number=0,
	description="",
	alpha=false,
	shadows=false,
	textures=#(#diffuse,#spec,#light,#normal,#mask,#bump1,#bump2,#env,#illum),
	name=#(#id,#name,#power,#reflect,#bump1,#bump2,#null),
	support=1.00,
	static=false
	)
struct geo_data (
	faces=#(),
	vertices=#()
	)
struct mesh_data (
	name,
	matname,
	faces,
	vertices,
	matinfo
	)
struct vertex_data (
	position,
	normal,
	tangent,
	colour,
	channels,
	texture,
	texture1,
	texture2,
	texture3,
	boneids,
	weights
	)
struct material_data (
	name=#(),
	ambient=#(),
	diffuse=#(),
	specular=#(),
	opacity=#(),
	twoSides=#(),
	diffmap=#(),
	dirtmap=#(),
	specmap=#(),
	normmap=#(),
	bumpmap1=#(),
	bumpmap2=#(),
	maskmap=#(),
	envmap=#()
	)
struct xnalara_format (
	skeleton,
	mesh
	)
struct xnalara_skeleton (
	name = #(),
	parent = #(),
	position = #(),
	rotation = #()
	)
struct render_group (
	sum,
	id,
	name,
	power,
	u_tile,
	v_tile,
	cam1,
	cam2
	)
struct xnalara_mesh (
	render_group,
	textures,
	geometry
	)
struct xnalara_textures (
	uv_channel,
	filepath
	)
struct xnalara_geometry (
	position,
	normal,
	tangent,
	uvw,
	colour,
	weight,
	boneid,
	faces,
	mat
	)
struct xnalara_material (
	diffuseMap,
	occlusionMap,
	normalMap,
	SpecularMap,
	MaskingMap,
	bumpMap1,
	bumpMap2,
	reflectionMap
	)
struct xnalara_material_data (
	shaderid=0,
	name="",
	diffuse=white,
	ambient=white,
	specular=white,
	opacity=white,
	diffuseMap="",
	specularMap="",
	lightMap="",
	bumpMap="",
	envMap="",
	maskingMap="",
	detailMap1="",
	detailMap2="",
	detailMap1_scale=1.0,
	detailMap2_scale=1.0,
	isOpaque=true,
	isEmissive=false,
	isTwoSided=false,
	fn setMaterial mat = (
		shaderid=0
		name=mat.name
		diffuse=mat.diffuse
		ambient=mat.ambientm
		specular=mat.specular
		opacity=color \
			(mat.opacity / 100.0 * 255.0) \
			(mat.opacity / 100.0 * 255.0) \
			(mat.opacity / 100.0 * 255.0)
		diffuseMap=try(mat.diffuseMap.filename)catch("")
		specularMap=try(mat.specularLevelMap.filename)catch("")
		lightMap=try(mat.ambientMap.filename)catch("")
		if classOf mat.diffuseMap==RGB_Multiply do (
			diffuseMap=try(mat.diffuseMap.map1.filename)catch("") 
			lightMap=try(mat.diffuseMap.map2.filename)catch("")
			)
		case classOf mat.bumpMap of (
			(Bitmaptexture): (bumpMap=try(mat.bumpMap.filename)catch(""))
			(Normal_Bump): (
				bumpMap=try(mat.bumpMap.normal_map.filename)catch("")
				detailMap1=try(mat.bumpMap.bump_map.filename)catch("")
				detailMap1_scale=try(mat.bumpMap.bump_map.coords.u_tiling)catch(1.0)
				detailMap2_scale=try(mat.bumpMap.bump_map.coords.u_tiling)catch(1.0)
				maskingMap=try(mat.bumpMap.bump_map.mapList[2].mask.filename)catch("")
				if maskingMap=="" do maskingMap=try(mat.bumpMap.bump_map.mapList[2].mask.map1.filename)catch("")
				detailMap1=try(mat.diffuseMap.filename)catch("")
				detailMap2=try(mat.diffuseMap.filename)catch("")
				)
			default:(diffuseMap="missing.tga")
			)
		opacityMap=try(mat.opacityMap.filename)catch("")
		envMap=try(mat.reflectionMap.filename)catch("")
		if opacityMap!="" do isOpaque=false
		if mat.selfIllumAmount!=0 do 	isEmissive=true
		if mat.twoSided == on do isTwoSided=true
		)
	)
struct xnalara_pose (
	name,
	pos,
	rot,
	matrix
	)
struct bone_data (
	bName,
	parent,
	child,
	position
	)
struct vert_data (
	vPos,
	vNorm,
	vColour,
	vBone,
	vWeight
	)
struct matprops (
	objInfo,
	objName,
	checksum,
	layers,
	renderGroup,
	diffuseMap,
	occlusionMap,
	normalMap,
	SpecularMap,
	MaskingMap,
	bumpMap1,
	bumpMap2,
	reflectionMap,
	bumpScale1,
	bumpScale2,
	power,
	cam1,
	cam2
	)
struct bone_data(
	name,
	position,
	parent,child
	)
	
/*	--=========================================================
	3.0		Script Program Functions
*/	--=========================================================
fn ReadXNAaraLString &bstream fixedLen = (
	local length2 = 0, i = 1, letter = 0, isTerm = false, result = ""
	if fixedLen >= 128 do (
		length2 = readbyte bstream #unsigned
		fixedLen = (mod fixedLen 128) + (length2 * 128);
		)
	for i = 1 to fixedLen do (
		letter = readbyte bstream #unsigned
		if letter == 0 do (isTerm = true)
		if isTerm == false do (result += bit.IntAsChar letter)
		)
	result
	)
fn ReadFixedString bstream fixedLen = (
	local str = ""
	for i = 1 to fixedLen do (
		str += bit.intAsChar (ReadByte bstream #unsigned)
		)
	str
	)
fn getUnixTime millisec = (
	local secs = 0, mins = 0, hrs = 0, zone="am"
	hrs = (millisec / 3600000.0) as integer
	mins = ((millisec - (hrs * 3600000.0)) / 60000.0) as integer
	secs = ((millisec - (mins * 60000.0) - (hrs * 3600000.0)) / 1000.0) as integer
	if hrs>12 do (zone="pm";hrs-= 12)
	--format "h: %%\tm: %\ts: %\n" hrs zone mins secs
	[hrs,mins,secs]
	)
fn getFaceTangent tmesh tan1 tan2 vertexIndices textureIndices = (
	local i1=0,i2=0,i3=0,i4=0,i5=0,i6=0
	local v1=0,v2=0,v3=0,w1=0,w2=0,w3=0
	local x1=0,x2=0,y1=0,y2=0,z1=0,z2=0
	local s1=0,s2=0,t1=0,t2=0,r=0,sdir=0,tdir=0
	
    i1 = vertexIndices[1]
    i2 = vertexIndices[2]
    i3 = vertexIndices[3]
    i4 = textureIndices[1]
    i5 = textureIndices[2]
    i6 = textureIndices[3]
	
    v1 = getVert tmesh i1
    v2 = getVert tmesh i2
    v3 = getVert tmesh i3
	
    w1 = getTVert tmesh i4
    w2 = getTVert tmesh i5
    w3 = getTVert tmesh i6
	
    x1 = v2[1] - v1[1]
    x2 = v3[1] - v1[1]
    y1 = v2[2] - v1[2]
    y2 = v3[2] - v1[2]
    z1 = v2[3] - v1[3]
    z2 = v3[3] - v1[3]
	
    s1 = w2[1] - w1[1]
    s2 = w3[1] - w1[1]
    t1 = w2[2] - w1[2]
    t2 = w3[2] - w1[2]
	
    r = 1.0 / (s1 * t2 - s2 * t1)
	
    sdir = [((t2 * x1 - t1 * x2) * r),((t2 * y1 - t1 * y2) * r),((t2 * z1 - t1 * z2) * r)]
    tdir = [((s1 * x2 - s2 * x1) * r),((s1 * y2 - s2 * y1) * r),((s1 * z2 - s2 * z1) * r)]
	
    tan1[i1] += sdir
    tan1[i2] += sdir
    tan1[i3] += sdir
	
    tan2[i1] += tdir
    tan2[i2] += tdir
    tan2[i3] += tdir
	)
fn getFaceVertex t1 t2 normal = (
    -- Gram-Schmidt orthogonalize
	local tangent=[0,0,0], nmV=1.0, tang=[0,0,0]
	local nmR=false,nmG=false,nmS=false
    
	tangent=[0,0,0,-nmV]
    tang = (t1 - normal * (Dot normal t1))
	
    if nmR=true do tang[1]=-tang[1]
    if nmG=true do tang[2]=-tang[2]
    if nmS=true do tang=[tang[2],tang[1],tang[3]]
	
    tangent[1]=tang[1]
    tangent[2]=tang[2]
    tangent[3]=tang[3]
	
    -- Calculate handedness
    if (Dot (Cross normal t1) t2) >=0 do tangent[4] = nmV
	tangent
	)
fn vertex_sum p u n b w = (
	local s = [0,0,0], i = 1
	s+=p -- add position
	s+=u -- add texture coordinate
	s+=n -- add normal
-- 	for i = 1 to b.count do (
-- 		s+= [(b[i]),(b[i]),(b[i])]
-- 		)
-- 	for i = 1 to w.count do (
-- 		s[1] *= w[i]
-- 		s[2] *= w[i]
-- 		s[3] *= w[i]
-- 		)
	s = normalize s
	(s[1]+s[2]+s[3])
	)
fn ReadBElong fstream = (
	bit.swapBytes (bit.swapBytes (readlong fstream #unsigned) 1 4) 2 3
	)
fn ReadBEshort fstream = (
	(bit.swapBytes (readshort fstream #unsigned) 1 2)
	)

fn ReadBEfloat fstream = (
	bit.intAsFloat (bit.swapBytes (bit.swapBytes (readlong fstream #unsigned) 1 4) 2 3)
	)
fn swritelong stream long = (
	format "%%%%" \
		(bit.IntAsChar (bit.shift long -24)) \
		(bit.and (bit.shift long -8) 0xFF) \
		(bit.and (bit.shift long -16) 0xFF) \
		(bit.and (bit.shift long -24) 0xFF) \
		to:stream
	)

fn writeBEfloat fstream flt = (
	writelong fstream (bit.swapBytes (bit.swapBytes (bit.floatAsInt flt) 1 4) 2 3) #unsigned
	)

fn writeBEshort fstream num = (
	writeshort fstream (bit.swapBytes num 1 2) #unsigned
	)

fn writeBElong fstream num = (
	writelong fstream (bit.swapBytes (bit.swapBytes (num) 1 4) 2 3) #unsigned
	)

fn writeshortfloat fstream bscale flt = (
	flt = (flt*(pow 2 bscale))
	if flt>=(0xFFFF/2) do (
		flt+=0xFFFF
		)
	writeshort fstream (bit.swapBytes (flt as integer) 1 2) #unsigned
	)

fn writepadding fstream alignment = (
	for w = 1 to ((mod (alignment-(mod (ftell fstream) alignment)) alignment)+alignment) do (
		writebyte fstream 0
		)
	)

fn relativetoworld obj idx = ( -- realtive to world positions
	pos = obj.matrix[idx]
	par = obj.parent[idx]
	if par!=0 then (
		while par != 0 do (
			pos*= obj.matrix[par]
			par = obj.parent[par]
			)
		)
	else(
		-- pos*=(rotateX pos 90)
		)
	return pos
	)

fn worldtorelative obj idx = ( -- world to relative positions
	parArray = #()
	append parArray obj.matrix[idx]
	par = obj.parent[idx]
	while par!=0 do (
		append parArray obj.matrix[par]
		par = obj.parent[par]
		)
	-- par.parent[par.count]*=(rotateX pos -90) -- lefthand to righthand
	rel = matrix3 1
	for x = 1 to parArray.count do (
		cnt = parArray.count-(x-1)
		for y = 1 to cnt do (
			parArray[(cnt-(y-1))] *= inverse rel
			)
		rel = parArray[cnt]
		)
	return parArray[1]
	)

fn paddstring len instring = (
	instring=instring as string
	local str=""
	if instring.count <=len then (
		for i = 1 to (len-instring.count) do(
			str+="0"
			)
		str = (str+instring)
		)
	else (
		for i = 1 to len do(
			str+="0";str[i]=instring[i]
			)
		)
	str
	)

fn ifUniqueAppend &theArray theValue = (
	if (findItem theArray theValue)==0 do (
		append theArray theValue
		)
	)
fn uppercase instring = (
	local upper, lower, outstring
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lower="abcdefghijklmnopqrstuvwxyz"
	outstring=copy instring
	for i=1 to outstring.count do (
		j=findString lower outstring[i]
		if (j != undefined) do outstring[i]=upper[j]
		)
	outstring
	)
fn lowercase instring = (
	local upper, lower, outstring
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lower="abcdefghijklmnopqrstuvwxyz"
	outstring=copy instring
	for i=1 to outstring.count do (
		j=findString upper outstring[i]
		if (j != undefined) do outstring[i]=lower[j]
		)
	outstring
	)
fn grabchildren abone = (
	childArray = #()
	tempArray = #()
	for z = 1 to abone.children.count do (
		append tempArray abone.children[z]
		)
	while tempArray.count!=0 do (
		abone = tempArray[tempArray.count]
		append childArray abone
		deleteitem tempArray tempArray.count
		for z = 1 to abone.children.count do (
			append tempArray abone.children[z]
			)
		)
	return childArray
	)
fn matrix_lookat theZAxis theSource theTarget = (
-- http://msdn.microsoft.com/en-us/library/windows/desktop/bb205343%28v=vs.85%29.aspx
	zaxis = normalize (theSource.row4 - theTarget.row4)
	xaxis = normalize (cross theZAxis zaxis) -- zaxis default [0,0,1]
	yaxis = cross zaxis xaxis
	tfm = matrix3 1
	tfm.row1 = [xaxis.x,yaxis.x,zaxis.x]
	tfm.row2 = [xaxis.y,yaxis.y,zaxis.y]
	tfm.row3 = [xaxis.z,yaxis.z,zaxis.z]
	tfm.row4 = [(-dot xaxis theSource.position),(-dot yaxis theSource.position),(-dot zaxis theSource.position)]
	-- need to add 90 0 -90 ??!!? wtf Microsoft
	tfm*=(matrix3 [1.49807e-006,-1,0] [4.88762e-007,0,1] [-1,-1.49807e-006,4.88762e-007] [0,0,0])
	tfm = inverse tfm
	return tfm
	)
fn format_ini theini = (
	outfile = createFile theini
	format "; Settings for XnaLara Maxscript\n" to:outfile
	format "\n[%]\n" "General" to:outfile
	format "enable = %\n" false to:outfile
	format "scale = %\nin_scale = %\nout_scale = %\n" rescale metric_scale imperial_scale to: outfile
	format "inpath = %\nout_path = %\n" imp_path exp_path to:outfile
	format "bone_limit = %\nbone_size = %\n" boneLimit boneSize to:outfile
	format "\n[%]\n" "Import" to:outfile
	format "use_path = %\n" impFixed to:outfile
	format "single_mesh = %\n" true to:outfile
	format "auto_rename = %\n" true to:outfile
	format "preserve_mats = %\n"true to:outfile
	format "reorientate_bones = %\n"false to:outfile
	format "boneon_disalbed = %\n"false to:outfile
	format "showlinks = %\n"false to:outfile
	format "clear_scene = %\n"false to:outfile
	format "mesh = %\nnormals = %\nskin = %\nbones = %\nmats = %\n" meshON normON skinON boneON matON to:outfile
	format "unused_hide = %\nunused_skip = %\n" mshHde false to:outfile
	format "\n[%]\n" "Export" to:outfile
	format "use_path = %\n" expFixed to:outfile
	format "name_by_mat = %\n" matNames to:outfile
	format "selection_only = %\n" false to:outfile
	format "optimize_output = %\n" true to:outfile
	format "reparent_bones = %\n" false to:outfile
	format "bone_nubs = %\n" false to:outfile
	format "copy_textures = %\n" false to:outfile
	format "use_mat_editor = %\n" true to:outfile
	format "mat_warning = %\n" true to:outfile
	close outfile
	)
fn getRenderGroup str = (
	strArray = (render_group sum:0 id:0 name:(str as string) power:10 u_tile:0 v_tile:0 cam1:"" cam2:"")
	tempArray = filterString strArray.name "_"
	grpnum = tempArray[1] as integer
	if grpnum!=undefined and (finditem #{1..33} grpnum)!=0 do (
		strArray.id = grpnum
		if tempArray[2]!=undefined do (strArray.name = tempArray[2])
		if tempArray[3]!=undefined do (strArray.power = execute tempArray[3])
		if tempArray[4]!=undefined do (strArray.u_tile = execute tempArray[4])
		if tempArray[5]!=undefined do (strArray.v_tile = execute tempArray[5])
		if tempArray[6]!=undefined do (strArray.cam1 = tempArray[6])
		if tempArray[7]!=undefined do (strArray.cam2 = tempArray[7])
		)
	return strArray
	)
fn setRGmaterial mat_class id texArray layerArray file_path = (
	map1 = 0 -- Diffuse
	map2 = 0 -- Light
	map3 = 0 -- Normal
	map4 = 0 -- Specular
	map5 = 0 -- Mask
	map6 = 0 -- Detail1
	map7 = 0 -- Detail2
	map8 = 0 -- Env
	map9 = 0 -- Opacity
	if classof mat_class == StandardMaterial then (
		mat_class.specularLevel = 0
		mat_class.glossiness = 10
		case id of (
			01: (map1 = 1;map2 = 2;map3 = 3;map5 = 4;map6 = 5;map7 = 6;mat_class.specularLevel = 30)
			02: (map1 = 1;map2 = 2;map3 = 3;mat_class.specularLevel = 30)
			03: (map1 = 1;map2 = 2)
			04: (map1 = 1;map3 = 2;mat_class.specularLevel = 30)
			05: (map1 = 1)
			06: (map1 = 1;map3 = 2;map9 = 1;mat_class.specularLevel = 30)
			07: (map1 = 1;map9 = 1)
			08: (map1 = 1;map2 = 2;map3 = 3;map9 = 1;mat_class.specularLevel = 30)
			09: (map1 = 1;map2 = 2;map9 = 1)
			10: (map1 = 1;mat_class.selfIllumAmount = 100)
			11: (map1 = 1;map3 = 2;mat_class.specularLevel = 30)
			12: (map1 = 1;map3 = 2;map9 = 1;mat_class.specularLevel = 30)
			13: (map1 = 1;map3 = 2;mat_class.selfIllumAmount = 100)
			14: (map1 = 1;map3 = 2;mat_class.selfIllumAmount = 100;mat_class.specularLevel = 30)
			15: (map1 = 1;map3 = 2;map9 = 1;mat_class.selfIllumAmount = 100;mat_class.specularLevel = 30)
			16: (map1 = 1)
			17: (map1 = 1;map2 = 2)
			18: (map1 = 1;map9 = 1)
			19: (map1 = 1;map2 = 2;map9 = 1)
			20: (map1 = 1;map2 = 2;map3 = 3;map5 = 4;map6 = 5;map7 = 6;map9 = 1;mat_class.specularLevel = 30)
			21: (map1 = 1;map9 = 1;mat_class.selfIllumAmount = 100)
			22: (map1 = 1;map2 = 2;map3 = 3;map4 = 7;map5 = 4;map6 = 5;map7 = 6)
			23: (map1 = 1;map2 = 2;map3 = 3;map4 = 7;map5 = 4;map6 = 5;map7 = 6;map9 = 1)
			24: (map1 = 1;map2 = 2;map3 = 3;map4 = 7)
			25: (map1 = 1;map2 = 2;map3 = 3;map4 = 7;map9 = 1)
			26: (map1 = 1;map3 = 2;map8 = 3)
			27: (map1 = 1;map3 = 2;map8 = 3;map9 = 1)
			28: (map1 = 1;map3 = 2;map4 = 3;map5 = 4;map6 = 5;map8 = 6)
			29: (map1 = 1;map3 = 2;map4 = 3;map5 = 4;map6 = 5;map8 = 6;map9 = 1)
			default: (map1 = 1)
			)
		if map1!=0 and map1!=undefined do (
			if texArray[map1]!=undefined do (
				mat_class.diffuseMap = Bitmaptexture fileName:(file_path+texArray[map1])
				mat_class.diffuseMap.coords.mapChannel = layerArray[map1]
					if map9!=0 and map9!=undefined do (
						if texArray[map1]!=undefined do (
							mat_class.diffuseMap.monoOutput = 1
							mat_class.diffuseMap.alphaSource = 2
							mat_class.diffuseMap.preMultAlpha = on
							mat_class.opacityMap = Bitmaptexture fileName:(file_path+texArray[map9])
							mat_class.opacityMap.coords.mapChannel = layerArray[map9]
							mat_class.opacityMap.monoOutput = 1
							mat_class.opacityMap.alphaSource = 0
							mat_class.opacityMap.preMultAlpha = off
							)
						)
				if map2!=0 and map2!=undefined do (
					if texArray[map2]!=undefined do (
						mat_class.adTextureLock = on -- if you don't the material looks washed out
						mat_class.ambientMap = Bitmaptexture fileName:(file_path+texArray[map2])
						mat_class.ambientMap.coords.mapChannel = layerArray[map2]
						-- mat_class.diffuseMap = RGB_Multiply ()
						-- mat_class.diffuseMap.map1 = Bitmaptexture fileName:(file_path+texArray[map1])
						-- mat_class.diffuseMap.map2 = Bitmaptexture fileName:(file_path+texArray[map2])
						-- mat_class.diffuseMap.map1.coords.mapChannel = layerArray[map1]
						-- mat_class.diffuseMap.map2.coords.mapChannel = layerArray[map2]
						-- mat_class.diffuseMap.map1Enabled = true
						-- mat_class.diffuseMap.map2Enabled = true
						-- mat_class.diffuseMap.alphaFrom = 0
						)
					)
				)
			)
		if map3!=0 and map3!=undefined do (
			if texArray[map3]!=undefined do (
				mat_class.bumpMapEnable = on
				mat_class.bumpMapAmount = 100
				mat_class.bumpMap = Normal_Bump ()
				mat_class.bumpMap.normal_map = Bitmaptexture fileName:(file_path+texArray[map3])
				mat_class.bumpMap.normal_map.coords.mapChannel = layerArray[map3]
				mat_class.bumpMap.map1on = true
				if map5!=0 and map5!=undefined and map6!=0 and map6!=undefined and map7!=0 and map7!=undefined do (
					if texArray[map5]!=undefined  and texArray[map6]!=undefined and  texArray[map7]!=undefined do (
						mat_class.bumpMap.bump_map = CompositeTexturemap ()
						mat_class.bumpMap.bump_map.mapEnabled.count = 2
						mat_class.bumpMap.bump_map.mapList[1] = Mask ()
						mat_class.bumpMap.bump_map.mapList[2] = Mask ()
						mat_class.bumpMap.bump_map.mapList[1].map = Bitmaptexture fileName:(file_path+texArray[map5])
						mat_class.bumpMap.bump_map.mapList[2].map = Bitmaptexture fileName:(file_path+texArray[map5])
						mat_class.bumpMap.bump_map.mapList[1].map.coords.mapChannel = layerArray[map5]
						mat_class.bumpMap.bump_map.mapList[2].map.coords.mapChannel = layerArray[map5]
						mat_class.bumpMap.bump_map.mapList[1].map.alphaSource = 2
						mat_class.bumpMap.bump_map.mapList[2].map.alphaSource = 2
						mat_class.bumpMap.bump_map.mapList[1].maskInverted = off
						mat_class.bumpMap.bump_map.mapList[2].maskInverted = off
						mat_class.bumpMap.bump_map.mapList[1].Mask = RGB_Tint ()
						mat_class.bumpMap.bump_map.mapList[2].Mask = RGB_Tint ()
						mat_class.bumpMap.bump_map.mapList[1].mask.MAP1 = Bitmaptexture fileName:(file_path+texArray[map6])
						mat_class.bumpMap.bump_map.mapList[2].mask.MAP1 = Bitmaptexture fileName:(file_path+texArray[map7])
						mat_class.bumpMap.bump_map.mapList[1].mask.MAP1.coords.mapChannel = layerArray[map6]
						mat_class.bumpMap.bump_map.mapList[2].mask.MAP1.coords.mapChannel = layerArray[map7]
						mat_class.bumpMap.bump_map.mapList[1].mask.map1.alphaSource = 2
						mat_class.bumpMap.bump_map.mapList[2].mask.map1.alphaSource = 2
						mat_class.bumpMap.bump_map.mapList[1].mask.red = color 255 255 255
						mat_class.bumpMap.bump_map.mapList[2].mask.red = color 0 0 0
						mat_class.bumpMap.bump_map.mapList[1].mask.green = color 0 0 0
						mat_class.bumpMap.bump_map.mapList[2].mask.green = color 255 255 255
						mat_class.bumpMap.bump_map.mapList[1].mask.blue = color 0 0 0
						mat_class.bumpMap.bump_map.mapList[2].mask.blue = color 0 0 0
						)
					)
				)
			)
		if map4!=0 and map4!=undefined do (
			if texArray[map4]!=undefined do (
				mat_class.specularLevelMap = Bitmaptexture fileName:(file_path+texArray[map4])
				mat_class.specularLevelMap.coords.mapChannel = layerArray[map4]
				)
			)
		if map8!=0 and map8!=undefined do (
			if texArray[map8]!=undefined do (
				mat_class.reflectionMap = Bitmaptexture fileName:(file_path+texArray[map8])
				mat_class.reflectionMap.coords.mapChannel = layerArray[map8]
				)
			)
		)
	else if classof mat_class == PhysicalMaterial then (
		mat_class.roughness = 10
		case id of (
			01: (map1 = 1;map2 = 2;map3 = 3;map5 = 4;map6 = 5;map7 = 6;mat_class.roughness = 30)
			02: (map1 = 1;map2 = 2;map3 = 3;mat_class.roughness = 30)
			03: (map1 = 1;map2 = 2)
			04: (map1 = 1;map3 = 2;mat_class.roughness = 30)
			05: (map1 = 1)
			06: (map1 = 1;map3 = 2;map9 = 1;mat_class.roughness = 30)
			07: (map1 = 1;map9 = 1)
			08: (map1 = 1;map2 = 2;map3 = 3;map9 = 1;mat_class.roughness = 30)
			09: (map1 = 1;map2 = 2;map9 = 1)
			10: (map1 = 1;mat_class.selfIllumAmount = 100)
			11: (map1 = 1;map3 = 2;mat_class.roughness = 30)
			12: (map1 = 1;map3 = 2;map9 = 1;mat_class.roughness = 30)
			13: (map1 = 1;map3 = 2;mat_class.emission = 1)
			14: (map1 = 1;map3 = 2;mat_class.emission = 1;mat_class.roughness = 30)
			15: (map1 = 1;map3 = 2;map9 = 1;mat_class.emission = 1;mat_class.roughness = 30)
			16: (map1 = 1)
			17: (map1 = 1;map2 = 2)
			18: (map1 = 1;map9 = 1)
			19: (map1 = 1;map2 = 2;map9 = 1)
			20: (map1 = 1;map2 = 2;map3 = 3;map5 = 4;map6 = 5;map7 = 6;map9 = 1;mat_class.roughness = 30)
			21: (map1 = 1;map9 = 1;mat_class.emission = 1)
			22: (map1 = 1;map2 = 2;map3 = 3;map4 = 7;map5 = 4;map6 = 5;map7 = 6)
			23: (map1 = 1;map2 = 2;map3 = 3;map4 = 7;map5 = 4;map6 = 5;map7 = 6;map9 = 1)
			24: (map1 = 1;map2 = 2;map3 = 3;map4 = 7)
			25: (map1 = 1;map2 = 2;map3 = 3;map4 = 7;map9 = 1)
			26: (map1 = 1;map3 = 2;map8 = 3)
			27: (map1 = 1;map3 = 2;map8 = 3;map9 = 1)
			28: (map1 = 1;map3 = 2;map4 = 3;map5 = 4;map6 = 5;map8 = 6)
			29: (map1 = 1;map3 = 2;map4 = 3;map5 = 4;map6 = 5;map8 = 6;map9 = 1)
			default: (map1 = 1)
			)
		if map1!=0 and map1!=undefined do (
			if texArray[map1]!=undefined do (
				mat_class.base_color_map = Bitmaptexture fileName:(file_path+texArray[map1])
				mat_class.base_color_map.coords.mapChannel = layerArray[map1]
					if map9!=0 and map9!=undefined do (
						if texArray[map1]!=undefined do (
							mat_class.base_color_map.monoOutput = 1
							mat_class.base_color_map.alphaSource = 2
							mat_class.base_color_map.preMultAlpha = on
							mat_class.transparency_map = Bitmaptexture fileName:(file_path+texArray[map9])
							mat_class.transparency_map.coords.mapChannel = layerArray[map9]
							mat_class.transparency_map.monoOutput = 1
							mat_class.transparency_map.alphaSource = 0
							mat_class.transparency_map.preMultAlpha = off
							)
						)
				if map2!=0 and map2!=undefined do (
					if texArray[map2]!=undefined do (
						mat_class.base_weight_map = Bitmaptexture fileName:(file_path+texArray[map2])
						mat_class.base_weight_map.coords.mapChannel = layerArray[map2]
						-- mat_class.base_color_map = RGB_Multiply ()
						-- mat_class.base_color_map.map1 = Bitmaptexture fileName:(file_path+texArray[map1])
						-- mat_class.base_color_map.map2 = Bitmaptexture fileName:(file_path+texArray[map2])
						-- mat_class.base_color_map.map1.coords.mapChannel = layerArray[map1]
						-- mat_class.base_color_map.map2.coords.mapChannel = layerArray[map2]
						-- mat_class.base_color_map.map1Enabled = true
						-- mat_class.base_color_map.map2Enabled = true
						-- mat_class.base_color_map.alphaFrom = 0
						)
					)
				)
			)
		if map3!=0 and map3!=undefined do (
			if texArray[map3]!=undefined do (
				mat_class.bump_map = Normal_Bump ()
				mat_class.bump_map.normal_map = Bitmaptexture fileName:(file_path+texArray[map3])
				mat_class.bump_map.normal_map.coords.mapChannel = layerArray[map3]
				mat_class.bump_map.map1on = true
				if map5!=0 and map5!=undefined and map6!=0 and map6!=undefined and map7!=0 and map7!=undefined do (
					if texArray[map5]!=undefined  and texArray[map6]!=undefined and  texArray[map7]!=undefined do (
						mat_class.bump_map.bump_map = CompositeTexturemap ()
						mat_class.bump_map.bump_map.mapEnabled.count = 2
						mat_class.bump_map.bump_map.mapList[1] = Mask ()
						mat_class.bump_map.bump_map.mapList[2] = Mask ()
						mat_class.bump_map.bump_map.mapList[1].map = Bitmaptexture fileName:(file_path+texArray[map5])
						mat_class.bump_map.bump_map.mapList[2].map = Bitmaptexture fileName:(file_path+texArray[map5])
						mat_class.bump_map.bump_map.mapList[1].map.coords.mapChannel = layerArray[map5]
						mat_class.bump_map.bump_map.mapList[2].map.coords.mapChannel = layerArray[map5]
						mat_class.bump_map.bump_map.mapList[1].map.alphaSource = 2
						mat_class.bump_map.bump_map.mapList[2].map.alphaSource = 2
						mat_class.bump_map.bump_map.mapList[1].maskInverted = off
						mat_class.bump_map.bump_map.mapList[2].maskInverted = off
						mat_class.bump_map.bump_map.mapList[1].Mask = RGB_Tint ()
						mat_class.bump_map.bump_map.mapList[2].Mask = RGB_Tint ()
						mat_class.bump_map.bump_map.mapList[1].mask.MAP1 = Bitmaptexture fileName:(file_path+texArray[map6])
						mat_class.bump_map.bump_map.mapList[2].mask.MAP1 = Bitmaptexture fileName:(file_path+texArray[map7])
						mat_class.bump_map.bump_map.mapList[1].mask.MAP1.coords.mapChannel = layerArray[map6]
						mat_class.bump_map.bump_map.mapList[2].mask.MAP1.coords.mapChannel = layerArray[map7]
						mat_class.bump_map.bump_map.mapList[1].mask.map1.alphaSource = 2
						mat_class.bump_map.bump_map.mapList[2].mask.map1.alphaSource = 2
						mat_class.bump_map.bump_map.mapList[1].mask.red = color 255 255 255
						mat_class.bump_map.bump_map.mapList[2].mask.red = color 0 0 0
						mat_class.bump_map.bump_map.mapList[1].mask.green = color 0 0 0
						mat_class.bump_map.bump_map.mapList[2].mask.green = color 255 255 255
						mat_class.bump_map.bump_map.mapList[1].mask.blue = color 0 0 0
						mat_class.bump_map.bump_map.mapList[2].mask.blue = color 0 0 0
						)
					)
				)
			)
		if map4!=0 and map4!=undefined do (
			if texArray[map4]!=undefined do (
				mat_class.roughnessMap = Bitmaptexture fileName:(file_path+texArray[map4])
				mat_class.roughnessMap.coords.mapChannel = layerArray[map4]
				)
			)
		if map8!=0 and map8!=undefined do (
			if texArray[map8]!=undefined do (
				mat_class.metalness_map = Bitmaptexture fileName:(file_path+texArray[map8])
				mat_class.metalness_map.coords.mapChannel = layerArray[map8]
				)
			)
		)
	)
fn buildRenderGroups = (
	global groups
	groups[41] = render_groups()
	groups[01] = (render_groups description:("") number:01 shadows:true name:#(#id,#name,#power,#bump1,#bump2) textures:#(#diffuse,#light,#normal,#mask,#bump1,#bump2))
	groups[02] = (render_groups description:("") number:02 shadows:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#light,#normal))
	groups[03] = (render_groups description:("") number:03 shadows:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#light))
	groups[04] = (render_groups description:("") number:04 shadows:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal))
	groups[05] = (render_groups description:("") number:05 shadows:true name:#(#id,#name,#null,#null,#null) textures:#(#diffuse))
	groups[06] = (render_groups description:("") number:06 alpha:true shadows:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal))
	groups[07] = (render_groups description:("") number:07 alpha:true shadows:true name:#(#id,#name,#null,#null,#null) textures:#(#diffuse))
	groups[08] = (render_groups description:("") number:08 alpha:true shadows:true support:1.80 name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#light,#normal))
	groups[09] = (render_groups description:("") number:09 alpha:true shadows:true support:1.80 name:#(#id,#name,#null,#null,#null) textures:#(#diffuse,#light))
	groups[10] = (render_groups description:("") number:10 support:1.85 name:#(#id,#name,#null,#null,#null) textures:#(#diffuse))
	groups[11] = (render_groups description:("") number:11 shadows:true support:4.10 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal))
	groups[12] = (render_groups description:("") number:12 alpha:true shadows:true support:4.10 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal))
	groups[13] = (render_groups description:("") number:13 support:4.10 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse))
	groups[14] = (render_groups description:("") number:14 support:4.20 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal))
	groups[15] = (render_groups description:("") number:15 alpha:true support:4.20 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal))
	groups[16] = (render_groups description:("") number:16 shadows:true support:4.70 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse))
	groups[17] = (render_groups description:("") number:17 shadows:true support:4.70 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#light))
	groups[18] = (render_groups description:("") number:18 alpha:true shadows:true support:4.70 static:true name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#light))
	groups[19] = (render_groups description:("") number:19 alpha:true shadows:true support:5.60 static:true name:#(#id,#name,#power,#null,#null) textures:#())
	groups[20] = (render_groups description:("") number:20 alpha:true shadows:true support:7.80 name:#(#id,#name,#power,#bump1,#bump2) textures:#(#diffuse,#light,#normal,#mask,#bump1,#bump2))
	groups[21] = (render_groups description:("") number:21 alpha:true support:9.10 name:#(#id,#name,#null,#null,#null) textures:#(#diffuse))
	groups[22] = (render_groups description:("") number:22 shadows:true support:9.30 name:#(#id,#name,#power,#bump1,#bump2) textures:#(#diffuse,#light,#normal,#mask,#bump1,#bump2,#spec))
	groups[23] = (render_groups description:("") number:23 alpha:true shadows:true support:9.30 name:#(#id,#name,#power,#bump1,#bump2) textures:#(#diffuse,#light,#normal,#mask,#bump1,#bump2,#spec))
	groups[24] = (render_groups description:("") number:24 shadows:true support:9.42 name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#light,#normal,#spec))
	groups[25] = (render_groups description:("") number:25 alpha:true shadows:true support:9.42 name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#light,#normal,#spec))
	groups[26] = (render_groups description:("") number:26 support:9.50 name:#(#id,#name,#reflect,#null,#null) textures:#(#diffuse,#light,#env))
	groups[27] = (render_groups description:("") number:27 alpha:true support:9.55 name:#(#id,#name,#reflect,#null,#null) textures:#(#diffuse,#light,#env))
	groups[28] = (render_groups description:("") number:28 shadows:true support:9.60 name:#(#id,#name,#power,#reflect,#bump1) textures:#(#diffuse,#normal,#mask,#bump1,#bump2,#env))
	groups[29] = (render_groups description:("") number:29 alpha:true shadows:true support:9.60 name:#(#id,#name,#power,#reflect,#bump1) textures:#(#diffuse,#normal,#mask,#bump1,#bump2,#env))
	groups[30] = (render_groups description:("") number:30 shadows:true support:10.92 name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal,#illum))
	groups[31] = (render_groups description:("") number:31 alpha:true shadows:true support:10.92 name:#(#id,#name,#power,#null,#null) textures:#(#diffuse,#normal,#illum))
	groups[32] = (render_groups description:("") number:32 shadows:true support:10.94 name:#(#id,#name,#power) textures:#(#diffuse))
	groups[33] = (render_groups description:("") number:33 alpha:true shadows:true support:10.94 name:#(#id,#name,#power) textures:#(#diffuse))
	groups[34] = (render_groups description:("Reserved for test shader") number:34 alpha:true shadows:true support:10.94 name:#(#id,#name) textures:#(#diffuse))
	groups[35] = (render_groups description:("Reserved for test shader") number:35 alpha:true shadows:true support:10.94 name:#(#id,#name) textures:#(#diffuse))
	groups[36] = (render_groups description:("") number:36 shadows:true support:10.94 name:#(#id,#name,#power,#bump1,#null) textures:#(#diffuse,#normal,#bump1))
	groups[37] = (render_groups description:("") number:37 alpha:true shadows:true support:10.94 name:#(#id,#name,#power,#bump1,#null) textures:#(#diffuse,#normal,#bump1))
	groups[38] = (render_groups description:("") number:38 shadows:true support:10.94 name:#(#id,#name,#power) textures:#(#diffuse,#normal,#spec,#illum))
	groups[39] = (render_groups description:("") number:39 alpha:true shadows:true support:10.94 name:#(#id,#name,#power) textures:#(#diffuse,#normal,#spec,#illum))
	groups[40] = (render_groups description:("") number:40 shadows:true support:11.00 name:#(#id,#name,#power) textures:#(#diffuse,#normal,#spec))
	groups[41] = (render_groups description:("") number:41 alpha:true shadows:true support:11.00 name:#(#id,#name,#power) textures:#(#diffuse,#normal,#spec))
	groups
	)
fn checkbonename fstream count = (
	isgood = true
	if count!=undefined and count!=0 then (
		for chu = 1 to count do (
			if (readbyte fstream #unsigned)==0x00 do (
				isgood=false
				)
			)
		)
	else (
		isgood=false
		)
	return isgood
	)
fn close_enough2 float1 float2 power = (
	isclose = false
	power = (power as integer)
	float1 = (float1*power) as integer
	float2 = (float2*power) as integer
	if float1==float2 do (
		isclose=true
		)
	return isclose
	)
fn validatestrlength fstream = (
	b1 = readbyte fstream #unsigned
	b2 = readbyte fstream #unsigned
	if b2<=0x1F then ( -- extended count
		-- b1 += b2-- * 0x0100 -- wtf is yous
		)
	else (
		fseek fstream -1 #seek_cur
		)
	return b1
	)
fn validatebones fstream file_size = (
	format "Invaild Bone Count?\n   ...Analysing Data\n"
	bone_count=0xFFFF;pos=0;bone_search = true
	while bone_search==true and ((ftell fstream)+4)<=file_size do (
		fseek fstream pos #seek_set
		bone_count = abs (readlong fstream #unsigned)
		pos = (ftell fstream) - 3
		if bone_search==true and bone_count<=0xFFFF and bone_count!=0 then (
			validnames = true
			for bn = 1 to bone_count do (
				if validnames==true and ((ftell fstream)+1)<=file_size then (
					str_size = validatestrlength fstream
					if ((ftell fstream)+str_size+14)<=file_size then (
						validnames = checkbonename fstream str_size
						if (readshort fstream)>=bone_count do (
							validnames=false
							)
						fseek fstream 12 #seek_cur
						)
					else (
						bn=0xFFFF
						)
					)
				else (
					bn=0xFFFF
					)
				)
			if validnames == true then (
				bone_search = false
				)
			else (
				bone_count = 0x010000;fseek fstream pos #seek_set
				)
			)
		)
	if bone_search == true then (return -1)else(return (pos-1))
	)
fn validateWeight fstream count = (
	local pos = ftell fstream
	local valid = true, w = 1
	local cnt = 0.0, b = 1
	-- cycle through bone indicies, check they do not exceed the bone count
	for w = 1 to 4 do (
		if (readshort fstream #unsigned) >= count do (
			valid = false
			)
		)
	-- cycle through bone weights, check they do not exceed 1.0
	if valid do (
		for w = 1 to 4 do (
			cnt += readfloat fstream
			)
		--format "weight total: %\n" (abs (cnt - 1.0))
		--format "weight total remainder: %\n" (mod cnt 1.0)
		if cnt < 0.0 or (abs (cnt - 1.0)) > 0.001 do valid = false
		--if (close_enough2 cnt 1.0 10) == false do (
		--	valid=false
		--	)
		--format "are weights okay?: %\n" valid
		)
	
	-- seek back to where we started
	fseek fstream pos #seek_set
	return valid
	)
fn roundToMultiple numToRound multiple = (
	local remainder = mod numToRound multiple
	if remainder == 0 do (
		return numToRound
		)
	return (numToRound + multiple - remainder)
	)
fn skipTheCrap &f settingsLen = (
	local i = 1, ii = 1, b = -1
	local optInfo = 0
	local optcount = 0
	local optType = 0
	local items = 0
	local waste = 0
	local valuesRead = 0
	local hash = 0
	local poseBytes = ""
	local poseLenght = 0
	local emptyBytes = 0
	local readCount = 0
	local loopStart = 0
	local loopFinish = 0
	hash = readlong f #unsigned
	valuesRead += 1 * 4
	items = readlong f #unsigned
	valuesRead += 1 * 4
	for i = 1 to items do (
		optType = readlong f #unsigned
		valuesRead += 1 * 4
		optcount = readlong f #unsigned
		valuesRead += 1 * 4
		optInfo = readlong f #unsigned
		valuesRead += 1 * 4
		
		if optType == 0xFF then (
			if optcount > 0 do (
				for ii = 1 to optcount do (
					waste = readlong f #unsigned
					)
				)
			valuesRead += optcount * 2
			)
		else if optType == 2 then (
			if optcount > 0 do (
				for ii = 1 to (optcount * 2) do (
					waste = readlong f #unsigned
					)
				)
			valuesRead += optcount * 2 * 4
			)
		else if optType == 1 then (
			if optcount > 0 do (
				for ii = 1 to optInfo do (
					b = -1
					while b != 0x0A do (
						b = readbyte f #unsigned
						if b != 0x0A do (
							poseBytes += bit.IntAsChar b
							)
						)
					)
				)
			poseLenght = roundToMultiple optcount 4
			emptyBytes = poseLenght - optcount
			fseek f emptyBytes #seek_cur
			--poseString = bin_ops.decodeBytes(poseBytes)
			--bonesPose = read_ascii_xps.poseData(poseString)
			readCount = roundToMultiple optcount 4
			valuesRead += readCount
			)
		else (
			loopStart = (floor (valuesRead / 4.0)) as integer
			loopFinish = settingsLen
			for ii = loopStart to loopFinish - 1 do (
				waste = readlong f #unsigned
				)
			)
		)
	)
fn printblockpos bname badr = (
	str=((bit.intAsHex badr)as string)
	if str[str.count]=="L" do(
		str = substring str 1 (str.count-1)
		)
	format "% @ 0x%\n" bname (paddstring 8 (uppercase str))
	)
fn getpadding num alignment = (
	(mod (alignment-(mod num alignment)) alignment)+alignment
	)
fn roundnumber place num = (
	(floor (num * place))/place
	)
fn arrayofweights factor = (
	scaleArray=#()
	scaleArray[(factor+1)]=0
	cnt=0
	fscale=100/factor
	for x = 1 to (factor+1) do (
		scaleArray[x]=cnt
		cnt+=fscale
		)
	scaleArray
	)
fn getModifier mclass msh = (
	mmod = for o in msh.modifiers where (classof o) == mclass collect o
	)
fn strColor2color str = (
	local col=color 0 0 0,str0 = filterstring str "( )"
	if str0[1] == "color" or str0[1] == "Color" and str0.count >= 4 do (
		col = color (str0[2] as integer) (str0[3] as integer) (str0[4] as integer)
		)
	return col
	)
fn closestnumber numarray num = (
	tempArray=copy numarray #nomap
	find=findItem tempArray num
	if find==0 do (
		append tempArray num
		sort tempArray
		find=findItem tempArray num
		if find==1 do (
			find = 2
			)
		find-=1
		)
	tempArray[find]
	)
fn calcbounding meshin = (
	tempArray=#(meshin.min.x,meshin.min.y,meshin.min.z, \
	meshin.max.x,meshin.max.y,meshin.max.z)
	sort tempArray;num = tempArray[tempArray.count]
	cnt=0;bound = 1280
	while bound!=0 AND num<=bound do (
		if num<=bound do cnt+=1
		bound=bound/2
		)
	if cnt!=0 do (
		cnt-=1
		)
	cnt
	)
fn uniqueweights weight boneid count = (
	refArray=#()
	counter = 0
	for v = 1 to count do (
		tempArray=[0,0,0]
		tempArray[1]=weight[v][1] + boneid[v][1]
		tempArray[2]=weight[v][2] + boneid[v][2]
		tempArray[3]=weight[v][3] + boneid[v][3]
		find = findItem refArray tempArray
		if find==0 do (
			counter+=1	
			append refArray tempArray
			)
		)
	refArray=#()
	counter
	)
fn paddstring len instring = (
	local str="";if instring.count <=len then (
		for i = 1 to (len-instring.count) do(
			str+="0"
			)
		str = (str+instring)
		)
	else (
		for i = 1 to len do(
			str+="0"
			str[i]=instring[i]
			)
		)
	str
	)
fn getchecksum str = (
	local i,hash=0
	for i = 1 to str.count do (
		hash = (bit.CharAsInt str[i]) + (bit.shift hash 6) + (bit.shift hash 16) - hash
		)
	bit.intashex (bit.swapBytes (bit.swapBytes (hash) 1 4) 2 3)
	)
fn getchecksum0 str = (
	checksum = 0
	str = str as string
	for ch = 1 to str.count do (
		checksum = (bit.shift checksum 1) + (bit.shift ((bit.and checksum 1)) -15)
		checksum += bit.charAsInt str[ch]
		checksum = bit.and checksum 0xFFFF
		)
	return checksum
	)
fn getchecksum2 arrayofstuff index= (
	stringArray = #(
		(arrayofstuff.renderGroup[index] as string),
		arrayofstuff.diffuseMap[index],
		arrayofstuff.occlusionMap[index],
		arrayofstuff.normalMap[index],
		arrayofstuff.SpecularMap[index],
		arrayofstuff.MaskingMap[index],
		arrayofstuff.bumpMap1[index],
		arrayofstuff.bumpMap2[index],
		arrayofstuff.reflectionMap[index],
		(arrayofstuff.power[index] as string)
		)
	sum = ""
	for i = 1 to stringArray.count do (
		txtstr = stringArray[i]
		if txtstr=="" do (
			txtstr=(i as string)
			)
		for x = 1 to txtstr.count do (
			sum +=txtstr[x]
			)
		)
	sum
	)
fn getchecksum3 arrayofstuff index= (
	stringArray = #(
		(arrayofstuff.renderGroup[index] as string),
		arrayofstuff.diffuseMap[index],
		arrayofstuff.occlusionMap[index],
		arrayofstuff.normalMap[index],
		arrayofstuff.SpecularMap[index],
		arrayofstuff.MaskingMap[index],
		arrayofstuff.bumpMap1[index],
		arrayofstuff.bumpMap2[index],
		arrayofstuff.reflectionMap[index],
		(arrayofstuff.power[index] as string)
		)
	sum = 0 as float
	for i = 1 to stringArray.count do (
		str = 1
		txtstr = stringArray[i]
		if txtstr=="" do (
			txtstr=(i as string)
			)
		for x = 1 to txtstr.count do (
			str += (bit.charAsInt txtstr[x])*x
			)
		sum += str--/txtstr.count
		)
	sum
	)
fn renamedup aray newname = ( -- renames duplicated names
	namCount=1
	find=findItem aray newname
	if find!=0 do(
		while(findItem aray newname)!=0 do (
			namCount+=1
			newname=(newname+"("+(namCount as string)+")")
			)
		)
	newname
	)
fn stripname instring = (
	basestr="";pos=findString instring " (RG"
	if pos!=undefined then (
		for i = 1 to pos do (
			basestr+=instring[i]
			)
		basestr
		)
	else (
		instring
		)
	)
fn stripgroup instring = (
	basestr="";pos=findString instring " (RG"
	if pos!=undefined then (
		for i = (pos+4) to instring.count do (
			basestr+=instring[i]
			)
		basestr=execute (readDelimitedString (basestr as stringstream) ")")
		if basestr==undefined do (
			basestr=5
			)
		)
	else (
		basestr=5
		)
	return basestr
	)
fn writeINI fstream tag key var = (
	setINISetting fstream tag key (var as string)
	)
fn retrieveini src myini cat op = (
	val = execute (getINISetting myini cat op)
	if val!=undefined do (
		src=val
		)
	return src
	)
fn checkname str = ( -- removes special characters from names
	local str0=""
	for i = 1 to str.count do (
		if str[i]!="_" \
		and str[i]!="#" \
		and str[i]!=" " \
		and str[i]!="." \
		and str[i]!="/" \
		and str[i]!="_" \
		and str[i]!="\"" \
		and str[i]!="\\" \
		do (
			str0+=str[i]
			)
		)
	str0
	)
fn renamedup2 aray idx = ( -- renames duplicated names
	local namCount=1
	newname= aray[idx]+"("+(namCount as string)+")"
	find=findItem aray newname
	if find!=0 do(
		while(findItem aray newname)!=0 do (
			namCount+=1
			newname=aray[idx]+"("+(namCount as string)+")"
			)
		)
	newname
	)
fn calculateRenderGroup matArray = (
	local rg_number = "5"
	if matArray[3]==""then( -- Opaque
	if matArray[4]==""then( -- not illum
	if matArray[13]=="" then( -- no detail map / masks
	-- 5 	Diffuse Only.
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[14]=="" do rg_number="5"
	-- 3	Diffuse + Lightmap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[14]=="" do rg_number="3"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="24"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[14]=="" do(
	matArray[7]="dirt_null.tga"
	matArray[8]="norm_null.tga"
	rg_number="24")
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do(
	matArray[7]="dirt_null.tga"
	rg_number="24")
	-- 26 	 Diffuse + NormalMap + EnvMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]!="" do rg_number="26"
	-- 4	Diffuse + NormalMap + Spec
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="4"
	-- 2 	Diffuse + NormalMap + Spec + LightMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="2"
	)else( -- detail maps / masks
	-- 28 	 Diffuse + NormalMap + DetailMap + EnvMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]!="" do rg_number="28"
	-- 1 	 Diffuse + NormalMap + DetailMap + Spec + LightMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]!="" do rg_number="1"
	-- 22 Diffuse + NormalMap + DetailMap + SpecMap + LightMap 
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="22"
	))else(
	-- 10	 Diffuse Only, High Emssive.
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[9]=="" \ -- texDetail1
	and matArray[10]=="" \ -- texDetail2
	and matArray[11]=="" \ -- matBump1
	and matArray[12]=="" \ -- matBump2
	and matArray[13]==""  do rg_number="10")
	)else( -- Opacity
	if matArray[4]!="true"then( -- not illum
	if matArray[13]=="" then( -- no detail map / masks
	-- 5 	Diffuse Only.
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[14]=="" do rg_number="7"
	-- 3	Diffuse + Lightmap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[14]=="" do rg_number="9"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="25"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[14]=="" do(
	rg_number="25")
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do(
	matArray[7]="dirt_null.tga"
	rg_number="25")
	-- 26 	 Diffuse + NormalMap + EnvMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]!="" do rg_number="27"
	-- 4	Diffuse + NormalMap + Spec
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="6"
	-- 2 	Diffuse + NormalMap + Spec + LightMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="8"
	)else( -- detail maps / masks
	-- 28 	 Diffuse + NormalMap + DetailMap + EnvMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]!="" do rg_number="29"
	-- 1 	 Diffuse + NormalMap + DetailMap + Spec + LightMap
	if matArray[5]=="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]!="" do rg_number="20"
	-- 22 Diffuse + NormalMap + DetailMap + SpecMap + LightMap 
	if matArray[5]!="" \ -- texSpecMap
	and matArray[7]!="" \ -- texLight
	and matArray[8]!="" \ -- texBump
	and matArray[14]=="" do rg_number="23"
	))else(
	-- 10	 Diffuse Only, High Emssive.
	if matArray[2]!="" \ -- texDiffuse
	and matArray[5]=="" \ -- texSpecMap
	and matArray[7]=="" \ -- texLight
	and matArray[8]=="" \ -- texBump
	and matArray[9]=="" \ -- texDetail1
	and matArray[10]=="" \ -- texDetail2
	and matArray[11]=="" \ -- matBump1
	and matArray[12]=="" \ -- matBump2
	and matArray[13]=="" \ -- texMask
	and matArray[14]=="" do rg_number="21"))
	rg_number
	)
fn getMaterial_old msh matid = ( -- tries to sort a material into a correct render group
	local matArray=#();matArray[20]=""
	local matname = "mat"
	local dcol=color 255 255 255
	local acol=color 255 255 255
	local scol=color 255 255 255
	local opa = 100
	local twoSides = false
	local matslot=msh.material
	if classOf matslot==standardmaterial do (
		matslot=msh.material
		)
	if classOf matslot==Shell_Material do (
		matslot=msh.material.originalMaterial
		)
	if classOf matslot==multimaterial do (
		matslot=msh.material[matid]
		)
	if matslot!=undefined then (
		matname = matslot.name
		acol=matslot.ambient
		dcol=matslot.Diffuse
		scol=matslot.Specular
		if classOf matslot.diffuseMap==Bitmaptexture do (
			matArray[2]=filenameFromPath matslot.diffuseMap.filename
			)
		if classOf matslot.diffuseMap==RGB_Multiply do (
			matArray[2]=filenameFromPath matslot.diffuseMap.map1.filename
			matArray[7]=filenameFromPath matslot.diffuseMap.map2.filename
			)
		if classOf matslot.ambientMap==Bitmaptexture do (
			matArray[7]=filenameFromPath matslot.ambientMap.filename
			)
		if classOf matslot.opacityMap==Bitmaptexture \
		or matslot.opacity!=100 do (
			matArray[3]="true"
			)
		if classOf matslot.specularLevelMap==Bitmaptexture do (
			matArray[5]=filenameFromPath matslot.specularLevelMap.filename
			)
		if matslot.selfIllumAmount!=0 do (
			matArray[4]="true";matArray[6]=(matslot.specularLevel as string)
			)
		if classOf matslot.bumpMap==Bitmaptexture do (
			matArray[8]=filenameFromPath matslot.bumpMap.filename
			)
		if classOf matslot.reflectionMap==Bitmaptexture do (
			matArray[14]=filenameFromPath matslot.reflectionMap.filename
			)
		if classOf matslot.bumpMap==Normal_Bump do (
			if classOf matslot.bumpMap.normal_map==Bitmaptexture do (
				matArray[8]=filenameFromPath matslot.bumpMap.normal_map.filename
				)
			if classOf matslot.bumpMap.bump_map==Bitmaptexture do (
				matArray[9]=filenameFromPath matslot.bumpMap.bump_map.filename
				matArray[11]=(matslot.bumpMap.bump_map.coords.u_tiling) as string
				matArray[10]="norm_null.tga";matArray[13]="mask_null.tga"
				)
			if classOf matslot.bumpMap.bump_map==CompositeTexturemap do (
				if classOf matslot.bumpMap.bump_map.mapList[2]==Mask \
				AND classOf matslot.bumpMap.bump_map.mapList[3]==Mask do (
					if classOf matslot.bumpMap.bump_map.mapList[2].mask==Bitmaptexture \
					OR classOf matslot.bumpMap.bump_map.mapList[2].mask==RGB_Tint then (
						if classOf matslot.bumpMap.bump_map.mapList[2].mask==Bitmaptexture do (
							matArray[13]=matslot.bumpMap.bump_map.mapList[2].mask.filename
							)
						if classOf matslot.bumpMap.bump_map.mapList[2].mask==RGB_Tint do (
							matArray[13]=matslot.bumpMap.bump_map.mapList[2].mask.map1.filename
							)
						if classOf matslot.bumpMap.bump_map.mapList[2].map==Bitmaptexture \
						AND classOf matslot.bumpMap.bump_map.mapList[3].map==Bitmaptexture then (
							matArray[9]=matslot.bumpMap.bump_map.mapList[2].map.filename
							matArray[10]=matslot.bumpMap.bump_map.mapList[3].map.filename
							matArray[11]=(matslot.bumpMap.bump_map.mapList[2].map.u_tiling) as string
							matArray[12]=(matslot.bumpMap.bump_map.mapList[3].map.u_tiling) as string
							)
						else(
							matArray[9]="norm_null.tga";matArray[10]="norm_null.tga";matArray[11]="1";matArray[12]="1"
							)
						)
					)
				)
			)
		)
	else (
		messagebox "ERROR!!\nUnable To Read Material\n>>Only Standard and Multimaterials Are Supported<<"
		if matslot!=undefined then (
			matArray[3]=matslot.diffuse as string;matArray[6]=matslot.specularLevel as string
			)
		else(
			matArray[3]="diff_null.tga"
			)
		)
	matArray[15]=matname
	matArray[16]=acol as string
	matArray[17]=dcol as string
	matArray[18]=scol as string
	matArray[19]=opa as string
	matArray[20]=twoSides as string
	if matArray[3]!="diff_null.tga"do(
	if matArray[3]!="true"then( -- Opaque
	if matArray[4]!="true"then( -- not illum
	if matArray[13]==undefined then( -- no detail map / masks
	-- 5 	Diffuse Only.
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="5"
	-- 3	Diffuse + Lightmap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="3"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="24"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[14]=="" do(
	matArray[7]="dirt_null.tga"
	matArray[8]="norm_null.tga"
	matArray[1]="24")
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do(
	matArray[7]="dirt_null.tga"
	matArray[1]="24")
	-- 26 	 Diffuse + NormalMap + EnvMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]!="" do matArray[1]="26"
	-- 4	Diffuse + NormalMap + Spec
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="4"
	-- 2 	Diffuse + NormalMap + Spec + LightMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="2"
	)else( -- detail maps / masks
	-- 28 	 Diffuse + NormalMap + DetailMap + EnvMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]!="" do matArray[1]="28"
	-- 1 	 Diffuse + NormalMap + DetailMap + Spec + LightMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]!="" do matArray[1]="1"
	-- 22 Diffuse + NormalMap + DetailMap + SpecMap + LightMap 
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="22"
	))else(
	-- 10	 Diffuse Only, High Emssive.
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[9]==undefined \ -- texDetail1
	and matArray[10]==undefined \ -- texDetail2
	and matArray[11]==undefined \ -- matBump1
	and matArray[12]==undefined \ -- matBump2
	and matArray[13]==undefined  do matArray[1]="10")
	)else( -- Opacity
	if matArray[4]!="true"then( -- not illum
	if matArray[13]==undefined then( -- no detail map / masks
	-- 5 	Diffuse Only.
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="7"
	-- 3	Diffuse + Lightmap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="9"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="25"
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[14]=="" do(
	matArray[7]="dirt_null.tga"
	matArray[8]="norm_null.tga"
	matArray[1]="25")
	-- 24	Diffuse + NormalMap + SpecMap + LightMap
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do(
	matArray[7]="dirt_null.tga"
	matArray[1]="25")
	-- 26 	 Diffuse + NormalMap + EnvMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]!="" do matArray[1]="27"
	-- 4	Diffuse + NormalMap + Spec
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="6"
	-- 2 	Diffuse + NormalMap + Spec + LightMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="8"
	)else( -- detail maps / masks
	-- 28 	 Diffuse + NormalMap + DetailMap + EnvMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]!="" do matArray[1]="29"
	-- 1 	 Diffuse + NormalMap + DetailMap + Spec + LightMap
	if matArray[5]==undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]!="" do matArray[1]="20"
	-- 22 Diffuse + NormalMap + DetailMap + SpecMap + LightMap 
	if matArray[5]!=undefined \ -- texSpecMap
	and matArray[7]!=undefined \ -- texLight
	and matArray[8]!=undefined \ -- texBump
	and matArray[14]=="" do matArray[1]="23"
	))else(
	-- 10	 Diffuse Only, High Emssive.
	if matArray[2]!=undefined \ -- texDiffuse
	and matArray[5]==undefined \ -- texSpecMap
	and matArray[7]==undefined \ -- texLight
	and matArray[8]==undefined \ -- texBump
	and matArray[9]==undefined \ -- texDetail1
	and matArray[10]==undefined \ -- texDetail2
	and matArray[11]==undefined \ -- matBump1
	and matArray[12]==undefined \ -- matBump2
	and matArray[13]==undefined \ -- texMask
	and matArray[14]=="" do matArray[1]="21")))
	if matArray[1]==undefined do matArray[1]="5"
	if matArray[2]==undefined do matArray[2]=("diff_null.tga "+((matslot.Diffuse)as string))
	if matArray[6]==undefined do matArray[6]="100"
	if (matArray[6] as float)<=0 do matArray[6]="10" -- texSpec
	if matArray[3]==undefined do matArray[3]="" -- texOpacity
	if matArray[4]==undefined do matArray[4]="" -- texIllum
	if matArray[5]!=undefined do matArray[6]="100"
	if matArray[5]==undefined do matArray[5]="" -- texSpecMap
	if matArray[7]==undefined do matArray[7]="" -- texLight
	if matArray[8]==undefined do matArray[8]="" -- texBump
	if matArray[9]==undefined do matArray[9]="" -- texDetail1
	if matArray[10]==undefined do matArray[10]="" -- texDetail2
	if matArray[11]==undefined do matArray[11]="" -- matBump1
	if matArray[12]==undefined do matArray[12]="" -- matBump2
	if matArray[13]==undefined do matArray[13]="" -- texMask
	if matArray[14]==undefined then( matArray[14]="")else(matArray[6]=matslot.reflectionMapAmount) -- texReflect
	matArray
	)
fn getMaterial msh matid = ( -- tries to sort a material into a correct render group
	local matArray=#();matArray[20]=""
	local matname = "mat"
	local dcol=color 255 255 255
	local acol=color 255 255 255
	local scol=color 255 255 255
	local opa = 100
	local twoSides = false
	local matslot=msh.material
	if classOf matslot==Shell_Material do (
		matslot=msh.material.originalMaterial
		)
	if classOf matslot==multimaterial do (
		try(matslot=msh.material[matid])catch()
		)
	if classOf matslot==standardmaterial then (
		matArray[1]="5"
		if classOf matslot.diffuseMap==RGB_Multiply then (
			matArray[2]=filenameFromPath(try(matslot.diffuseMap.map1.filename)catch(""))
			matArray[7]=filenameFromPath(try(matslot.diffuseMap.map2.filename)catch(""))
			)
		else (
			matArray[2]=filenameFromPath(try(matslot.diffuseMap.filename)catch(""))
			matArray[7]=filenameFromPath(try(matslot.ambientMap.filename)catch(""))
			)
		matArray[3]=filenameFromPath(try(matslot.OpacityMap.filename)catch("missing.tga"))
		matArray[4]=filenameFromPath(try(matslot.selfillumMap.filename)catch(""))
		matArray[5]=filenameFromPath(try(matslot.specularLevelMap.filename)catch(""))
		matArray[6]=matslot.specularLevel as string
		matArray[8]=filenameFromPath(try(matslot.bumpMap.filename)catch(""))
		matArray[8]=filenameFromPath(try(matslot.bumpMap.normal_map.filename)catch(matArray[8]))
		matArray[9]=filenameFromPath(try(matslot.bumpMap.bump_map.filename)catch(""))
		matArray[10]=filenameFromPath(try(matslot.bumpMap.bump_map.mapList[3].map.filename)catch(""))
		matArray[11]=try(matslot.bumpMap.bump_map.coords.u_tiling)catch(1.0) as string
		matArray[11]=try(matslot.bumpMap.bump_map.mapList[2].map.u_tiling)catch(matArray[11]) as string
		matArray[12]=try(matslot.bumpMap.bump_map.mapList[3].map.u_tiling)catch(1.0) as string
		matArray[13]=filenameFromPath(try(matslot.bumpMap.bump_map.mapList[2].mask.map1.filename)catch(""))
		matArray[13]=filenameFromPath(try(matslot.bumpMap.bump_map.mapList[2].mask.filename)catch(matArray[13]))
		matArray[14]=filenameFromPath(try(matslot.reflectionMap.filename)catch(""))
		matArray[15]=matslot.name
		matArray[16]=matslot.ambient as string
		matArray[17]=matslot.Diffuse as string
		matArray[18]=matslot.Specular as string
		matArray[19]=matslot.Opacity as string
		matArray[20]=(if matslot.twoSided == on then true else false) as string
		matArray[1] = calculateRenderGroup(matArray)
		)
	else (
		for i = 1 to matArray.count do (
			matArray[i] = (
				case i of (
					01: ("5")
					03: ("missing.tga")
					06: ("10")
					11: ("1.0")
					12: ("1.0")
					15: ("mat_" + ((timestamp()) as string))
					16: ("(color 255 255 255)")
					17: ("(color 255 255 255)")
					18: ("(color 255 255 255)")
					19: ("100")
					default: ("")
					)
				)
			)
		)
	matArray
	)
fn maketext sfile p = ( -- makes a 8x8 tga anymm colour, usage: (maketext savefile pixelcolour)
	if (doesFileExist sfile)!="true" do ( -- don't overwrite if another file with the same name is present
		s = fopen sfile "ab"
		nullTex=#()
		texWidth=8
		texHeight=8
		nullTex[(texWidth*texHeight)]=[0,0,0,0]
		for i = 1 to nullTex.count do (
			nullTex[i]=[p.blue,p.green,p.red,255]
			) --alpha set to white
		writebyte s 0 -- size of ID field that follows 18 byte header (0 usually)
		writebyte s 0 -- type of colour map 0=none, 1=has palette
		writebyte s 2 -- type of image 0=none,1=indexed,2=rgb,3=grey,+8=rle packed
		writeshort s 0 -- first colour map entry in palette
		writeshort s 0 -- number of colours in palette
		writebyte s 0 -- number of bits per palette entry 15,16,24,32
		writeshort s 0 -- image x origin
		writeshort s 0 -- image y origin
		writeshort s texWidth -- image width in pixels
		writeshort s texHeight -- image height in pixels
		writebyte s 32 -- image bits per pixel 8,16,24,32
		writebyte s 0 -- image descriptor bits (vh flip bits)
		for x=1 to nullTex.count do (
			for y=1 to 4 do(
				writebyte s (nullTex[x][y] as integer)
				)
			);fclose s
		)
	)
fn tallyWeights weights = (
	local i,wt
	wt = 0
	for i = 1 to weights.count do (
		wt+=weights[i]
		)
	return wt
	)
fn balanceWeights accuracy weights = (
	local i,w,wt,wa,scaler
	scaler = (POW 10 accuracy) as float
	w = 1.0
	wt = 0
	for i = 1 to weights.count do (
		weights[i] = ((weights[i] * scaler) as integer)/scaler
		)
	wt = tallyWeights weights
	if wt != 1.0 do (
		if wt<1.0 then (
			wa = ((((1.0-wt)/weights.count) * scaler) as integer)/scaler
			for i = 1 to weights.count do (
				weights[i] += wa
				)
			)
		else (
		if wt<1.0 then (
			wa = ((((wt-1.0)/weights.count) * scaler) as integer)/scaler
			for i = 1 to weights.count do (
				weights[i] -= wa
				)
			)
		)
		wt=0
		wt = tallyWeights weights
		weights[1]+=1.0-wt
		)
	return weights
	)
fn limitWeights limit weights boneids = (
	local i,w,bw_tmp,bw_tmp2,bw_tmp3,i,pad
	pad = true
	w = #(#(),#())
	bw_tmp = copy weights #nomap
	bw_tmp2 = copy weights #nomap
	bw_tmp3 = copy boneids #nomap
	sort bw_tmp
	for i = 1 to limit do (
		if bw_tmp.count>0 do (
			find = findItem bw_tmp2 bw_tmp[(bw_tmp.count)]
			append w[1] bw_tmp2[find]
			append w[2] bw_tmp3[find]
			deleteItem bw_tmp bw_tmp.count
			deleteItem bw_tmp2 find
			deleteItem bw_tmp3 find
			)
		)
	if (tallyWeights weights)!=1.0 do (
		w[1] = balanceWeights 6 w[1]
		)
	if pad ==true and limit>weights.count do (
		for i = 1 to (limit-weights.count) do (
			append w[1] 0
			append w[2] 0
			)
		)
	return w
	)
fn pmxwritestring fstream str mode = (
	local i
	str = str as string
	case mode of (
		0x00:( -- UTF16
			writelong fstream (str.count*2) #unsigned
			for i = 1 to str.count do (
				writeshort fstream (bit.charAsInt str[i]) #unsigned
				)
			)
		0x01:( -- UTF8
			writelong fstream str.count #unsigned
			for i = 1 to str.count do (
				writebyte fstream (bit.charAsInt str[i]) #unsigned
				)
			)
		default:(print "unsupported text encoding")
		)
	)
fn xnalara_writestring fstream str = (
	local i
	writebyte fstream str.count #unsigned
	for i = 1 to str.count do (
		writebyte fstream (bit.charAsInt(str[i])) #unsigned
		)
	)
fn writepmxint fstream val type = (
	case type of (
		0x01: (
			writebyte fstream val #signed
			)
		0x02: (
			writeshort fstream val #signed
			)
		0x04: (
			writelong fstream val #signed
			)
		default: (
			writebyte fstream val #signed
			)
		)
	)
fn pmxWeightType weightarray = (
	local i,c=0
	for i = 1 to weightarray.count do (
		if weightarray[i]!=0 do (
			c+=1
			)
		)
	case c of (
		0x01:0x00
		0x02:0x01
		0x03:0x02
		0x04:0x02
		default:0x00
		)
	)
fn fetchBoneTail bonename = (
	local num = [0,0,0,0],arg = [0,0,0],newBone,i=1
	local bonenode = getNodeByName bonename exact:true ignoreCase:false all:false
	local allowable = #(BoneGeometry, Biped_Object)
	if bonenode!=undefined do (
		if finditem allowable (classof bonenode) > 0 then (
			undo off (
				with Animate Off (
					local parentBone  = selection[1]
					local parentTrans = parentBone.transform
					local parentPos   = parentTrans.translation
					local newbone
					with redraw off (
						newBone=dummy transform:bonenode.transform
						in coordSys Local move newBone [bonenode.length,0,0]
						num[2] = newBone.position.x
						num[3] = newBone.position.y
						num[4] = newBone.position.z
						delete newBone
						)
					redrawViews()
					)
				)
			for i = 1 to bonenode.children.count do (
				if (((distance (bonenode.children[i].position) ([(num[2]),(num[3]),(num[4])])) * 1000)as integer) == 0 do (
					num[1] = i
					)
				)
			)
		else (
			
			)
		)
	return num
	)
fn copyTexturesTo opath = (
	local r=0,failedgrabs="",assets = #(), mpath="",fpath=""
	ATSOps.refresh()
	ATSOps.getFiles &assets
	mpath=getFilenamePath assets[1]
	for r = 2 to assets.count do (
		if assets[r]!=undefined do (
			fpath=getFilenamePath assets[r]
			if mpath=="" and fpath!="" do mpath=fpath
			if fpath=="" do assets[r]=(mpath+assets[r])
			if (doesFileExist assets[r])==true then (
				copyFile  assets[r] (opath+"\\"+(filenameFromPath assets[r]))
				)
			else(
				failedgrabs+=((filenameFromPath assets[r])+"\n")
				)
			)
		)
	)
fn writeSceneData expFixed fpath mshScale enable_export_mode2 sortbones mshBySelection renamedups autoMeshBreak boneLimit mshAddRoot matNames nameMatsByTex reviewMats areTexturesCopied = (
	local fileOpened = false
	local return_state=false,file_state=false,i=0, x=0, y=0, p=0, f=0, c=0, d=0, getBone=#(), getMesh=#(), tmp=#()
	local staticMsh=#(), faceCount=0
	local boneBuffer = (bone_data name:#() position:#() parent:#() child:#())
	local obj=#(), m=undefined, nameArray=#(), dupNames="", namCount=0, newname= ""
	local skinPresent=false, PhyiqArray="", skinMod=undefined, boneWarning = ""
	local faceBuffer=#(), meshBuffer = (geo_data faces:#() vertices:#())
	local matBuffer = material_data(), vertCount=0, faceCount=0
	local meshBuffer = (mesh_data name:#() matname:#() faces:#() vertices:#() matinfo:#())
	local vertBuffer = (vertex_data position:#() normal:#() tangent:#() colour:#() texture1:#() texture2:#() texture3:#() boneids:#() weights:#())
	local tmesh=undefined, modMesh=undefined, uvwMesh=undefined, mat = undefined, modNorm= undefined, tvCount=0
	local UVLayers=0,UVIndex=0, vColors=0, cvert=white, num_verts=0, num_faces=0, weightBuffer=#(), boneIDBuffer=#()
	local vertex_bone_count=0, weightCollection=#(), boneidCollection=#(), bone_weight=1.0, bone_index=1, nw=#()
	local weight=1.0, boneid=1, b1=0, b2=0, b3=0, b4=0, find=0
	local vertCollection=#(), normCollection=#(), tvertCollection=#(), faceCollection=#(), boneCheck=#()
	local faceStart=1, faceCounter=0, count=0, boneLimitReached=false, matcrap =#()
	local findex=0, tindex=0, cindex=0, vert=[0,0,0], tvert=[0,0,0], tvert2=[0,0,0], cvert=white, norm=[0,0,0]
	local vertCull=0, tvertCull=0, normCull=0, vertIndex=1, nextvert=0, faceIndex=1, nextface=0
	local sext="", testname="", comment="", pmx_flags=#()
	local texCount=0, vert_count=0, wc=0, wr=0, matname="", idx=0, bflag=0, s=undefined
	local boneEnd=undefined, boneTarget=undefined, bidx=0, boneTarget=undefined
	local matName="", opath="", mpath="", out_file_str="", failedgrabs=""
	local assets = #(), cr=0, cg=0, cb=0, fa=0, fb=0, fc=0,txt="",vs=[0,0,0]
	local ssource="",out_file=undefined,matCollection=#(),tan1 =#(),tan2 =#(), tang=[0,0,0,0]
	local total_faces=0,boneMap = #(),numBones=0,foundAddRoot=false
	global doit_prog_progress
	
	if expFixed==false do (
		ssource = getSaveFileName \
		caption:"Save XnaLara ASCII Model File" \
		types: "Text File (*.ASCII)|*.mesh.ascii|PMX (*.PMX)|*.pmx|Binary File (*.MESH)|*.mesh|Wavefront Obj File (*.OBJ)|*.obj|All files (*.*)|*.*|"
		)
	if ssource!=""AND ssource!=undefined do (
		fileOpened=true
		try(
			if enable_export_mode2 == false then (
				out_file = createfile ssource
				)
			else (
				out_file = fopen ssource "wt"
				)
			)
		catch(
			fileOpened=false
			fclose out_file
			print "SHit"
			)
		if fileOpened==false do (
			messagebox "Error:\n\tFailed to Access File"
			Print "Aborted."
			)
		)
	if fileOpened then (
		return_state = true
		fpath=(getFilenamePath ssource)
		if (uppercase (getFilenameType ssource)) == ".PMX" do (
			autoMeshBreak = false
			)
		sext = uppercase(getFilenameType ssource) -- should be ".ascii"
		--if sext==".ASCII" then mshOptimise=false else mshOptimise=true
		if renamedups==true do ( -- make object names unique
			obj=objects;nameArray=#();dupNames="";namCount=0
			for i = 1 to obj.count do (
				newname=obj[i].name
				if findItem nameArray newname!=0 do (
					dupNames+=(newname+"\n")
					while (findItem nameArray newname) !=0 do(
						namCount+=1
						newname=obj[i].name+"("+(namCount as string)+")"
						)
					)
				append nameArray newname
				)
			for i = 1 to obj.count do obj[i].name=nameArray[i]
			)
		classesArr = #(BoneGeometry,Biped_Object,Dummy,IK_Chain_Object,Point)
		tmp = #()
		tmp=for o in objects where findItem classesArr (classof o) > 0 collect o.name
		
		classesArr = #(Editable_Mesh,Editable_Poly,PolyMeshObject)
		getMesh=case mshBySelection of (
			(true): for o in selection where findItem classesArr (classof o) > 0 and o.numverts > 0 collect o
			(false): for o in objects where findItem classesArr (classof o) > 0 and o.numverts > 0 collect o
			--#scene:
			--#selection:
			--#view:
			default:#()
			)
		setCommandPanelTaskMode #modify
		for o in getMesh do (
			faceCount+=o.numfaces
			i=0
			for x = 1 to o.modifiers.count do (
				skinMod = o.modifiers[x]
				if classOf skinMod==Skin then (
					i=x
					select o
					modPanel.setCurrentObject skinMod
					numBones = skinOps.GetNumberBones skinMod
					for i = 1 to numBones do (
						bone_name = skinOps.GetBoneName skinMod i 0
						x = findItem tmp bone_name
						if x==0 do (append tmp bone_name)
						)
					)
				else (
					if o.parent!=undefined then (
						x = findItem tmp o.parent.name
						if x==0 do (append tmp o.parent.name)
						)
					else (
						x = findItem tmp o.name
						if x==0 do (append tmp o.name)
						)
					)
				)
			if i==0 do (
				x = findItem tmp o.name
				if x==0 do (append tmp o.name)
				)
			)
		if sortbones == true do sort tmp
		boneBuffer = (bone_data name:#() position:#() parent:#() child:#())
		foundAddRoot=false
		for bone_name in tmp do (
			o = getNodeByName bone_name exact:true
			if o!=undefined then (
				p = -1
				if o.parent!=undefined do (
					p = (findItem tmp o.parent.name)-1
					)
				c = -1
-- 				if o.children!=undefined do (
-- 					c = (findItem tmp ((o.children[1]).name)) -1
-- 					)
				append boneBuffer.name bone_name
				append boneBuffer.position o.transform.row4
				append boneBuffer.parent p
				append boneBuffer.child c
				)
			else (
				append boneBuffer.name bone_name
				append boneBuffer.position [0,0,0]
				append boneBuffer.parent -1
				append boneBuffer.child 0
				)
			if bone_name=="root ground" do (
				foundAddRoot=true
				)
			)
		if mshAddRoot==true or foundAddRoot==false do ( -- Add a Root Bone
			find=findItem boneBuffer.name "root ground"
			if find==0 then ( -- Need to add Ground Root
				insertItem "root ground" boneBuffer.name 1
				insertItem [0,0,0] boneBuffer.position 1
				insertItem -2 boneBuffer.parent 1
				insertItem 0 boneBuffer.child 1
				for i = 1 to boneBuffer.name.count do(
					boneBuffer.parent[i]+=1
					)
				)
			else ( -- Reorder all bones to Ground Root (Not tested? dont know if this even works)
				if find!=1 then ( -- the Root needs to be moved back to top
					-- NOT WRITTEN -> would mean unlinking the root? not safe?
					)
				else ( -- reparent everything else to the top
					for i = 1 to boneBuffer.name.count do (
						if boneBuffer.parent[i]==-1 AND i!=find do (
							boneBuffer.parent[i]=0
							)
						)
					)
				)
			)
		if getMesh.count!=0 then (
			staticMsh=#()
			max modify mode
			--createDialog progressTest 200 60
			if getMesh.count!=0 do (
				meshBuffer = (geo_data faces:#() vertices:#())
				matBuffer = material_data()
				meshBuffer = (mesh_data name:#() matname:#() faces:#() vertices:#() matinfo:#())
				vertBuffer = (vertex_data position:#() normal:#() tangent:#() colour:#() texture1:#() texture2:#() texture3:#() boneids:#() weights:#())
				vertBuffer.position [(faceCount*3)] = [0,0,0]
				vertBuffer.normal [(faceCount*3)] = [0,0,0]
				vertBuffer.tangent [(faceCount*3)] = [0,0,0]
				vertBuffer.colour [(faceCount*3)] = [0,0,0]
				vertBuffer.texture1 [(faceCount*3)] = [0,0,0]
				vertBuffer.texture2 [(faceCount*3)] = [0,0,0]
				vertBuffer.texture3 [(faceCount*3)] = [0,0,0]
				vertBuffer.boneids [(faceCount*3)] = [0,0,0,0]
				vertBuffer.weights [(faceCount*3)] = [0,0,0,0]
				faceBuffer=#()
				faceBuffer[(faceCount*3)]=0
				)
			for m = 1 to getMesh.count do (
				total_faces += getMesh[m].numfaces
				)
			vertCount=0 -- Counts used to index through my arrays
			faceCount=0
			max modify mode
			for m = 1 to getMesh.count do ( --loop meshcount
				if isGroupMember getMesh[m]!=true then ( -- skip anything that's grouped. I couldn't figure out how to read the modifiers in the groups, and there can be groups inside
					--tmesh = snapshotAsMesh getMesh[m]
					tmesh = getMesh[m]
					select tmesh
					--convertTo tmesh TriMeshGeometry
					modMesh = Edit_Mesh () --mkes sure mesh is triMesh
					uvwMesh = Unwrap_UVW () --makes sure mesh has UVs !! fuck causes bad uv's >_<
					addModifier tmesh uvwMesh
					addModifier tmesh modMesh
					tvCount=getNumTVerts tmesh
					mat=tmesh.material
					--delete tmesh
					
					-- tmesh = snapshotAsMesh getMesh[m] -- no material access wtf
					UVLayers=1 -- should return 2, the 2nd channel is reserved for vertex colours
					UVIndex=0
					if (numMapsUsed tmesh)>=3 do (
						UVLayers=0 -- do a double check for vaild UV Channels
						for i = 1 to (numMapsUsed tmesh) do ( -- loop through each uv channel
							if meshop.getMapSupport tmesh i == true do UVLayers+=1
							)
						)
					if uvLayers>=3 do messagebox ("ERROR!!\n"+tmesh.name+" uses more then 2 UV Layers\n Script was not setup for more then 2\n\n-Sorry will Add Support in the future")
					
					vColors=getNumCPVVerts tmesh -- returns 0 if there are no colours stored
					cvert=(color 255 255 255) --white
					
					num_verts = tmesh.numverts 
					num_faces = tmesh.numfaces
					
					weightBuffer=#();weightBuffer[tmesh.numverts]=0.0
					boneIDBuffer=#();boneIDBuffer[tmesh.numverts]=0
					
					skin_bone_limit = false
					
					skinPresent=false
					skinMod=undefined
					if tmesh.modifiers.count!=0 then (
						for i = 1 to tmesh.modifiers.count do ( -- Get Skin Data
								if classOf tmesh.modifiers[i]==Skin do (
								skinPresent=true
								skinMod=tmesh.modifiers[i]
								)
							)
						if skinPresent==true then (
							modPanel.setCurrentObject skinMod
							skinOps.RemoveZeroWeights skinMod
							numBones = skinOps.GetNumberBones skinMod
							if autoMeshBreak == true do (
								if numBones>=boneLimit do (
									skin_bone_limit=true
									boneWarning+=(tmesh.name+"\n")
									)
								)
							boneMap = #()
							for i = 1 to numBones do (
								append boneMap (
									findItem boneBuffer.name (
										skinOps.GetBoneName skinMod i 0
										)
									)
								)
							for i = 1 to tmesh.numverts do (
								vertex_bone_count = skinOps.GetVertexWeightCount skinMod i -- #of weights per vert
								if vertex_bone_count!=0 then (
									weightCollection=#();weightCollection[vertex_bone_count]=0.0
									boneidCollection=#();boneidCollection[vertex_bone_count]=0
									for x = 1 to vertex_bone_count do (
										bone_weight = skinops.getvertexweight skinMod i x
										bone_index = boneMap[(skinOps.GetVertexWeightBoneID skinMod i x)]
										if bone_index==0 do (
											bone_index=1
											)
										weightCollection[x]=bone_weight
										boneidCollection[x]=bone_index
										)
									)
								else ( --dead weight found, nothing fancy just append weight to bone1
									weightCollection=#();weightCollection[1]=0.0
									boneidCollection=#();boneidCollection[1]=0
									bone_index = 1
									weightCollection[1]=1.0
									boneidCollection[1]=1
									)
								nw = limitWeights 4 weightCollection boneidCollection -- limits to four bones weights per vertex
								weightCollection = nw[1] -- updates arrays
								boneidCollection = nw[2]
								b1=boneidCollection[1]-1 -- convert to base 0
								b2=boneidCollection[2]-1
								b3=boneidCollection[3]-1
								b4=boneidCollection[4]-1
								if b1<0 do b1=0
								if b2<0 do b2=0
								if b3<0 do b3=0
								if b4<0 do b4=0
								boneIDBuffer[i]=[b1,b2,b3,b4]
								-- boneIDBuffer[i]=[(boneidCollection[1]),(boneidCollection[2]),(boneidCollection[3]),(boneidCollection[4])]
								weightBuffer[i]=[(weightCollection[1]),(weightCollection[2]),(weightCollection[3]),(weightCollection[4])]
								)
							)
						else (
							for x = 1 to tmesh.numverts do ( -- static mesh, fix skin info
								weightBuffer[x]=[1,0,0,0]
								if tmesh.parent!=undefined 
								then boneid=findItem boneBuffer.name tmesh.parent.name -- weight to a possible parent
								else boneid=findItem boneBuffer.name tmesh.name -- if no parent weight to scene root
								boneid-=1 -- convert to base 0
								if boneid<=0 do boneid=0 -- convert to base 0
								boneIDBuffer[x]=[boneid,0,0,0]
								)
							)
						)
					else (
						for x = 1 to tmesh.numverts do (
							weightBuffer[x]=[1,0,0,0]
							if tmesh.parent!=undefined 
							then boneid=findItem getBone tmesh.parent.name
							else boneid=findItem getBone tmesh.name
							boneid-=1 -- convert to base 0
							if boneid<=0 do boneid=0 -- convert to base 0
							boneIDBuffer[x]=[boneid,0,0,0]
							)
						)
					
					--modNorm = Edit_Normals ()
					--addModifier tmesh modNorm
					tan1 =#();tan1[(num_verts * 2)] = [0,0,0]
					tan2 =#();tan2[((num_verts * 2) + num_verts)] = [0,0,0]
					-- nom =#();nom[(num_verts)]=[0,0,0]
					for x = 1 to tan1.count do tan1[x]=[0,0,0]
					for x = 1 to tan2.count do tan2[x]=[0,0,0]
					-- for i = 1 to nom.count do nom[i]=[0,0,0]
					
					vertCollection=#() -- arrays reset on each mesh / material ID
-- 								normCollection=#()
-- 								tvertCollection=#()
					faceCollection=#()
					boneCheck=#()
					
					vertCollection[(num_faces*3)] = [0,0,0,0]
-- 								normCollection[(num_faces*3)] = [0,0,0]
-- 								tvertCollection[(num_faces*3)] = [0,0,0,0]
					faceCollection[num_faces] = [0,0]
					case (classOf mat) of ( -- If MultiMaterial, Sort Faces By IDs
						(Multimaterial): (
							for x = 1 to num_faces do (
								faceCollection[x]=[(getFaceMatId tmesh x),(tmesh.faces[x].index)]
								)
							fn sortFN v1 v2 = (
								local d=v1[1]-v2[1]
								case of (
									(d < 0.): -1
									(d > 0.): 1;default: 0
									)
								)
							qsort faceCollection sortFN
							)
						default: (
							for x = 1 to num_faces do (
								faceCollection[x]= [1,x]
								)
							)
						)
					
					faceStart=faceCollection[1][1]
					faceCounter=0
					count=0 -- count for resetable arrays	
					boneLimitReached=false	
					matCollection = #()
-- 								format "NUM FACES: %\n" num_faces
					for x = 1 to num_faces do (
						d=faceCollection[x][1]-faceStart -- Compares Current MatID vs the Last MatID
						if (findItem matCollection faceStart)==0 or boneLimitReached == true do ( -- Log Material Info If New
							append matCollection faceStart
							matcrap=getMaterial tmesh faceStart
							append meshBuffer.matinfo [(matcrap[1] as integer),(matcrap[6] as float),(matcrap[11] as float),(matcrap[12] as float)]
							append matBuffer.diffmap matcrap[2]
							append matBuffer.dirtmap matcrap[7]
							append matBuffer.specmap matcrap[5]
							append matBuffer.normmap matcrap[8]
							append matBuffer.bumpmap1 matcrap[9]
							append matBuffer.bumpmap2 matcrap[10]
							append matBuffer.maskmap matcrap[13]
							append matBuffer.envmap matcrap[14]
							
							append matBuffer.name (matcrap[15] as string)
							append matBuffer.ambient (strColor2color matcrap[16])
							append matBuffer.diffuse (strColor2color matcrap[17])
							append matBuffer.specular (strColor2color matcrap[18])
							append matBuffer.opacity (execute matcrap[19])
							append matBuffer.twoSides (execute matcrap[20])
							
							try (
								if matNames==true then (
									mshName=(checkname tmesh.material[faceStart].name)
									)
								else (
									mshName=checkname tmesh.name
									)
								find=findItem meshBuffer.name mshName
								if find!=0 do (
									mshName=renamedup2 meshBuffer.name find
									)
								append meshBuffer.name mshName
								append meshBuffer.matname mshName
								)
							catch (
								if matNames==true then (
									mshName=("Mat_"+(x as string)+"_"+(faceCollection[x][1] as string))
									)
								else (
									mshName=(checkname tmesh.name)
									)
								find=findItem meshBuffer.name mshName
								if find!=0 do (
									mshName=renamedup2 meshBuffer.name find
									)
								append meshBuffer.name mshName
								append meshBuffer.matname mshName
								)
							 -- suppose to ensure that the material name is correct, this is critical.. but not properly?
							
							)
						if d != 0 or boneLimitReached ==true do ( -- If material ID changes or loop completes append buffers and reset arrays
							vertCollection=#() -- reset arrays
-- 										normCollection=#()
-- 										tvertCollection=#()
							boneCheck=#()
							vertCollection[(num_faces*3)] = [0,0,0,0]
-- 										normCollection[(num_faces*3)] = [0,0,0]
-- 										tvertCollection[(num_faces*3)] = [0,0,0,0]
							append meshBuffer.faces (faceCounter) -- save counts, and reset shit
							--format "BOOKMARK: %\n" (faceCounter)
							append meshBuffer.vertices count
							faceStart=faceCollection[x][1]
							faceCounter=0
							count=0
							boneLimitReached = false -- reset break mesh point
							)
						faceCounter+=1
						findex=getFace tmesh faceCollection[x][2] -- gets face index of mesh
						tindex=getTVFace tmesh faceCollection[x][2] -- gets face index of texture coordinates
						getFaceTangent tmesh tan1 tan2 findex tindex
						if vColors!=0 do cindex=getVCFace tmesh faceCollection[x][2] -- gets face index of vertex colours
						-- t2index=getTVFace tmesh faceCollection[x][2] -- gets face for second UV channel (Fixed Channel)
						if mshOptimise==true then (
							for y = 1 to 3 do (
								vert=getVert tmesh findex[y]
								tvert=getTVert tmesh tindex[y]
								tvert2=getTVert tmesh tindex[y]
								cvert=color 255 255 255
								if vColors!=0 do cvert=getVertColor tmesh cindex[y]
								norm = getNormal tmesh findex[y]
								
								/*
								--norm=modNorm.GetNormal (modNorm.GetNormalID faceCollection[x][2] y)
								norm = (
									(
										(
											matrix3 [1,0,0] [0,1,0] [0,0,1] (
												modNorm.GetNormal (
													modNorm.GetNormalID faceCollection[x][2] y
													)
												)
										) * \
										(
											tmesh.transform * \
											(
												matrix3 [1,0,0] [0,1,0] [0,0,1] -tmesh.transform.row4
												)
											)
										).row4
									)
								*/
								tang = getFaceVertex tan1[(findex[y])] tan2[(findex[y])] norm
								
								vs = vertex_sum vert tvert norm boneIDBuffer[(findex[y])] weightBuffer[(findex[y])]
								
								vertCull=findItem vertCollection vs
-- 											tvertCull=findItem tvertCollection [tvert.x,tvert.y,0,(tindex[y])]
-- 											normCull=findItem normCollection norm
								
-- 											if vertCull!=0 do (
-- 												if normCollection[vertCull]!=norm do normCull=0
-- 												)
								
								if vertCull==0 then ( --not found
									count+=1
									vertCount+=1
									faceCount+=1
									vertCollection[count]=vs
-- 												tvertCollection[count]=[tvert.x,tvert.y,0,(tindex[y])]
									--normCollection[count]=norm
-- 												normCollection[count]=normalize (
-- 														((matrix3 [1,0,0] [0,1,0] [0,0,1] norm) * (tmesh.transform*(matrix3 [1,0,0] [0,1,0] [0,0,1] -tmesh.transform.row4))).row4
-- 														)
									
									vertBuffer.position[vertCount]=[vert.x,vert.y,vert.z,(findex[y])] -- Face ID is left, relates to the Skin Weight
									vertBuffer.texture1[vertCount]=[tvert.x,tvert.y,0]
									vertBuffer.colour[vertCount]=cvert
									vertBuffer.normal[vertCount]=norm
									vertBuffer.tangent[vertCount]=tang
									vertBuffer.boneids[vertCount]=boneIDBuffer[(findex[y])]
									vertBuffer.weights[vertCount]=weightBuffer[(findex[y])]
									
									faceBuffer[faceCount]=count
									--format "U:%\n" count
									if skin_bone_limit==true do ( -- if current object exceeds bone limit, start new mesh
										boneids=boneIDBuffer[(findex[y])]
										for b = 1 to 4 do (
											if (finditem boneCheck boneids[b])==0 do (
												append boneCheck boneids[b]
												)
											)
										if autoMeshBreak == true and faceBuffer.count>=polygonLimit do (
											boneLimitReached=true
											)
-- 													if autoMeshBreak == true and boneCheck.count>=boneLimit do (
-- 														boneLimitReached=true
-- 														)
										) -- note to self, need to copy any changes to this function to the unoptimized loop
									)
								else (
									faceCount+=1
									faceBuffer[faceCount]=vertCull
									--doit_prog_progress=100. * (faceCount / total_faces as float )
									--format "L:%\n" vertCull
									)
								)
							)
						else (
							for y = 1 to 3 do (
								vert=getVert tmesh findex[y]
								tvert=getTVert tmesh tindex[y]
								norm = getNormal tmesh findex[y]
								/*
								norm = (
									(
										(
											matrix3 [1,0,0] [0,1,0] [0,0,1] (
												modNorm.GetNormal (
													modNorm.GetNormalID faceCollection[x][2] y
													)
												)
										) * \
										(
											tmesh.transform * \
											(
												matrix3 [1,0,0] [0,1,0] [0,0,1] -tmesh.transform.row4
												)
											)
										).row4
									)
								*/
								tang = getFaceVertex tan1[(findex[y])] tan2[(findex[y])] norm
								
-- 											norm=modNorm.GetNormal (modNorm.GetNormalID faceCollection[x][2] y)
								count+=1
								faceCount+=1
								vertCount+=1
								vertBuffer.position[vertCount]=[vert.x,vert.y,vert.z,(findex[y])] -- Face ID is left, relates to the Skin Weight
								vertBuffer.texture1[vertCount]=[tvert.x,tvert.y,0]
								vertBuffer.normal[vertCount]=norm
								vertBuffer.tangent[vertCount]=tang
								vertBuffer.boneids[vertCount]=boneIDBuffer[(findex[y])]
								vertBuffer.weights[vertCount]=weightBuffer[(findex[y])]
								faceBuffer[faceCount]=count
								--doit_prog_progress=100. * (faceCount / total_faces as float )
								)
							)
						if mod x polygonLimit == 0 do (boneLimitReached=true)
						)
					--format "BOOKMARK: %\n" (faceCounter)
					append meshBuffer.faces (faceCounter) -- save counts, and reset shit
					append meshBuffer.vertices (count)
-- 								print "FACE BUFFER"
-- 								print faceBuffer
					--deleteModifier tmesh modNorm
					deleteModifier tmesh modMesh
					deleteModifier tmesh uvwMesh
					)
				else(
					MessageBox ("Warning\nGroups Not Supported Yet\n"+getMesh[m].name+"was Skipped")
					)
				)
			--destroydialog progressTest
			if getMesh.count!=0 do (
				case sext of ( -- EXPORT TYPES
					".ASCII": ( -- xnalara ASCII format
						vertIndex=1
						nextvert=0
						faceIndex=1
						nextface=0
						faceCounter=0
						format "% # bones\n" boneBuffer.name.count to:out_file
						for f = 1 to boneBuffer.name.count do (
							format "%\n" boneBuffer.name[f] to:out_file
							format "% # parent index\n" boneBuffer.parent[f] to:out_file
							format "% % %\n" \
								(boneBuffer.position[f][1]*mshScale) \
								(boneBuffer.position[f][3]*mshScale) \
								(boneBuffer.position[f][2]*-mshScale) to:out_file
							)
						format "% # meshes\n" meshBuffer.name.count to:out_file
						for f = 1 to meshBuffer.name.count do (
							nextvert+=meshBuffer.vertices[f]
							nextface+=meshBuffer.faces[f]
							 -- THE NAME IS CRITICAL !!
							txt = ""
							
							--print "groups"
							--print (meshBuffer.matinfo[f][1])
							for y in groups[(meshBuffer.matinfo[f][1])].name do (
								if txt !="" do txt += "_"
								txt+= (
									(
										case y of (
											#id: (meshBuffer.matinfo[f][1]as integer)
											#name: (meshBuffer.name[f])
											#power: (meshBuffer.matinfo[f][2]/100)
											#reflect: (meshBuffer.matinfo[f][2]/100)
											#bump1: meshBuffer.matinfo[f][3]
											#bump2: meshBuffer.matinfo[f][4]
											#null: "0"
											)
										) as string
									)
								)
							format "%\n" txt to:out_file
							format "% # uv layers\n" 1 to:out_file	-- Multiple UV channels not setup yet
							format "% # textures\n" (groups[(meshBuffer.matinfo[f][1])].textures.count) to:out_file
							matName=(matBuffer.diffmap[f] as stringstream)
							if (skipToString matName "diff_null.tga")==OK do (
								seek matName 21
								matName=(readChars matName (matBuffer.diffmap[f].count-21)) as stringstream
								cr=(readDelimitedString matName " ") as integer
								cg=(readDelimitedString matName " ") as integer
								cb=(readDelimitedString matName ")") as integer
								matBuffer.diffmap[f]=("diff_null_"+(meshBuffer.name[f] as string)+".tga")
								maketext (fpath+matBuffer.diffmap[f]) (color cr cg cb)
								)
							if matBuffer.diffmap[f] == "" do matBuffer.diffmap[f] = "missing.tga"
							if matBuffer.normmap[f] == "" do matBuffer.normmap[f] = "missing.tga"
							if matBuffer.specmap[f] == "" do matBuffer.specmap[f] = "missing.tga"
							if matBuffer.dirtmap[f] == "" do matBuffer.dirtmap[f] = "missing.tga"
							if matBuffer.envmap[f] == "" do matBuffer.envmap[f] = "missing.tga"
							if matBuffer.maskmap[f] == "" do matBuffer.maskmap[f] = "missing.tga"
							if matBuffer.bumpmap1[f] == "" do matBuffer.bumpmap1[f] = "missing.tga"
							if matBuffer.bumpmap2[f] == "" do matBuffer.bumpmap2[f] = "missing.tga"
							
							for y in groups[(meshBuffer.matinfo[f][1])].textures do (
								format "%\n% # uv layer index\n" (
									case y of (
										#diffuse: matBuffer.diffmap[f]
										#spec: matBuffer.specmap[f]
										#light: matBuffer.dirtmap[f]
										#normal: matBuffer.normmap[f]
										#mask: matBuffer.maskmap[f]
										#bump1: matBuffer.bumpmap1[f]
										#bump2: matBuffer.bumpmap2[f]
										#env: matBuffer.envmap[f]
										#illum: "missing.tga"
										default: "missing.tga"
										)
									) 0 to:out_file
								)
							format "% # vertices\n" meshBuffer.vertices[f] to:out_file
							--format "WHAT % %\n" vertIndex nextvert
							--print vertBuffer.position.count
							--print vertBuffer.position
							for i = vertIndex to nextvert do (
								format "% % %\n" (vertBuffer.position[i][1]*mshScale) (vertBuffer.position[i][3]*mshScale) (vertBuffer.position[i][2]*-mshScale) to:out_file
								if normVN==true then (
									norm=normalize [(vertBuffer.normal[i][1]),(vertBuffer.normal[i][3]),(-vertBuffer.normal[i][2])]
									format "% % %\n" norm.x norm.y norm.z to:out_file
									)
								else (
									format "% % %\n" vertBuffer.normal[i][1] vertBuffer.normal[i][3] vertBuffer.normal[i][2] to:out_file
									)
								format "% % % %\n" 255 255 255 255 to:out_file -- vertex colours not setup yet
								-- format "% % % %\n" (vertBuffer.colour[i].red as integer) (vertBuffer.colour[i].green as integer) (vertBuffer.colour[i].blue as integer) 0 to:out_file -- vertex colours not setup yet
								for y = 1 to 1 do ( -- needs UV layer count, net setup yet
									if y==1 do format "% %\n" vertBuffer.texture1[i][1] (vertBuffer.texture1[i][2]*-1) to:out_file
									if y==2 do format "% %\n" vertBuffer.texture2[i][1] (vertBuffer.texture2[i][2]*-1) to:out_file
									if y==3 do format "% %\n" vertBuffer.texture3[i][1] (vertBuffer.texture3[i][2]*-1) to:out_file
									)
								-- -- Vertex Tangents would go here
								format "% % % %\n" (vertBuffer.boneids[i][1]as integer) (vertBuffer.boneids[i][2]as integer) (vertBuffer.boneids[i][3]as integer) (vertBuffer.boneids[i][4]as integer) to:out_file
								format "% % % %\n" vertBuffer.weights[i][1] vertBuffer.weights[i][2] \
								vertBuffer.weights[i][3] vertBuffer.weights[i][4] to:out_file
								)
							--format "FACE BUFFER: %\n" faceBuffer.count
							format "% # faces\n" meshBuffer.faces[f] to:out_file
							--format "stride: %\n" (nextface-faceIndex+1)
							for i = faceIndex to nextface do (
								
								fa=faceBuffer[(faceCounter+1)]-1
								fb=faceBuffer[(faceCounter+2)]-1
								fc=faceBuffer[(faceCounter+3)]-1
								--format "% % %\t|\t% % %\n" fc fb fa (faceCounter+1) (faceCounter+2) (faceCounter+3)
								format "% % %\n" fc fb fa to:out_file
								faceCounter+=3
								)
							faceIndex+=meshBuffer.faces[f]
							vertIndex+=meshBuffer.vertices[f]
							) -- mesh loop
						
-- 											for x = 1 to matBuffer.diffmap.count do (
-- 												if matBuffer.dirtmap[x]=="dirt_null.tga" do maketext (fpath+"\\dirt_null.tga") (color 254 254 254)
-- 												if matBuffer.specmap[x]=="spec_null.tga" do maketext (fpath+"\\spec_null.tga") (color 50 50 50)
-- 												if matBuffer.normmap[x]=="norm_null.tga" do maketext (fpath+"\\norm_null.tga") (color 128 128 255)
-- 												if matBuffer.maskmap[x]=="mask_null.tga" do maketext (fpath+"\\mask_null.tga") (color 255 0 0)
-- 												if matBuffer.bumpmap1[x]=="bump1_null.tga" do maketext (fpath+"\\bump1_null.tga") (color 128 128 255)
-- 												if matBuffer.bumpmap2[x]=="bump2_null.tga" do maketext (fpath+"\\bump2_nul.tgal") (color 128 128 255)
-- 												)
						) -- end xnalara .mesh.ascii export
					".PMX": ( -- PMX format
						
						nameMatsByTex = false
						
						
						close out_file
						s = fopen ssource "wb"
						
						vertIndex=1
						nextvert=0
						faceIndex=1
						nextface=0
						faceCounter=0
						
						testname=maxFileName
						comment="Outputed from Xnalara Converter Script\n\tWritten by: mariokart64n\n"
						pmx_flags = #(0,0,4,1,1,2,1,1)
						writelong s 0x20584D50 #unsigned -- File Type "PMX "
						writefloat s 2.0 -- File Version
						writebyte s 0x08 #unsigned -- flag count, always 8
						writebyte s pmx_flags[1] #unsigned -- Encoding | 0: UTF16 1: UTF8 
						writebyte s pmx_flags[2] #unsigned -- Add UV number | 0 ~ 4 for more information vertex reference 
						writebyte s pmx_flags[3] #unsigned -- Index vertex size (Sizes can only be either 1,2,4)
						writebyte s pmx_flags[4] #unsigned -- Index texture size (Sizes can only be either 1,2,4)
						writebyte s pmx_flags[5] #unsigned -- Material Index size (Sizes can only be either 1,2,4)
						writebyte s pmx_flags[6] #unsigned -- Index bone size (Sizes can only be either 1,2,4)
						writebyte s pmx_flags[7] #unsigned -- Index morph size (Sizes can only be either 1,2,4)
						writebyte s pmx_flags[8] #unsigned -- Index rigid body size (Sizes can only be either 1,2,4)
						pmxwritestring s testname pmx_flags[1]
						pmxwritestring s testname pmx_flags[1]
						pmxwritestring s comment pmx_flags[1]
						pmxwritestring s comment pmx_flags[1]
						vert_count = 0
						for wr = 1 to meshBuffer.name.count do (
							vert_count += meshBuffer.vertices[wr]
							)
						writelong s vert_count #unsigned
						for wr = 1 to meshBuffer.name.count do (
							nextvert+=meshBuffer.vertices[wr]
							for i = vertIndex to nextvert do (
-- 													nw = ( -- limits to four bones weights per vertex
-- 														limitWeights 4 \
-- 															#(vertBuffer.weights[i][1],vertBuffer.weights[i][2],vertBuffer.weights[i][3],vertBuffer.weights[i][4]) \
-- 															#(vertBuffer.boneids[i][1],vertBuffer.boneids[i][2],vertBuffer.boneids[i][3],vertBuffer.boneids[i][4])
-- 														)
-- 													wc = (pmxWeightType nw[2]) -- 0 = 1 BoneWeight |  1 = 2 BoneWeights |  2 = 4 BoneWeights
-- 													nw = #(
-- 														#(vertBuffer.weights[i][1],vertBuffer.weights[i][2],vertBuffer.weights[i][3],vertBuffer.weights[i][4]), \
-- 														#(vertBuffer.boneids[i][1],vertBuffer.boneids[i][2],vertBuffer.boneids[i][3],vertBuffer.boneids[i][4])
-- 														)
								wc = 2
								writefloat s vertBuffer.position[i][1]
								writefloat s vertBuffer.position[i][3]
								writefloat s vertBuffer.position[i][2]
								writefloat s vertBuffer.normal[i][1]
								writefloat s vertBuffer.normal[i][3]
								writefloat s vertBuffer.normal[i][2]
								writefloat s vertBuffer.texture1[i][1] 
								writefloat s (vertBuffer.texture1[i][2]*-1)
								for x = 1 to pmx_flags[2] do (
									writefloat s 0.0
									writefloat s 0.0
									writefloat s 0.0
									writefloat s 0.0
									)
								writebyte s wc #unsigned
								case wc of (
									0x00: (
										writepmxint s (nw[2][1]-1) pmx_flags[6] -- bone id
										)
									0x01: (
										writepmxint s (nw[2][1]-1) pmx_flags[6] -- bone id
										writepmxint s (nw[2][2]-1) pmx_flags[6]
										writefloat s nw[1][1]
										)
									0x02: ( -- 4 bone weights per vertex
-- 															writepmxint s (nw[2][1]-1) pmx_flags[6] -- bone id
-- 															writepmxint s (nw[2][2]-1) pmx_flags[6]
-- 															writepmxint s (nw[2][3]-1) pmx_flags[6]
-- 															writepmxint s (nw[2][4]-1) pmx_flags[6]
-- 															writefloat s nw[1][1] -- weight
-- 															writefloat s nw[1][2]
-- 															writefloat s nw[1][3]
-- 															writefloat s nw[1][4]
										writepmxint s vertBuffer.boneids[i][1] pmx_flags[6] -- bone id
										writepmxint s vertBuffer.boneids[i][2] pmx_flags[6]
										writepmxint s vertBuffer.boneids[i][3] pmx_flags[6]
										writepmxint s vertBuffer.boneids[i][4] pmx_flags[6]
										writefloat s vertBuffer.weights[i][1] -- weight
										writefloat s vertBuffer.weights[i][2]
										writefloat s vertBuffer.weights[i][3]
										writefloat s vertBuffer.weights[i][4]
										)
									)
								writefloat s 1.0 -- line thickness
								)
							vertIndex+=meshBuffer.vertices[wr]
							)
							vertIndex = 0
							writelong s faceBuffer.count #unsigned
							for wr = 1 to meshBuffer.faces.count do (
								for i = 1 to meshBuffer.faces[wr] do (
									writepmxint s (faceBuffer[(faceCounter+1)]+vertIndex-1) pmx_flags[3]
									writepmxint s (faceBuffer[(faceCounter+3)]+vertIndex-1) pmx_flags[3]
									writepmxint s (faceBuffer[(faceCounter+2)]+vertIndex-1) pmx_flags[3]
									faceCounter+=3
									)
								vertIndex += meshBuffer.vertices[wr]
								)
						tmp=#()
						for wr = 1 to matBuffer.diffmap.count do (
							texname = matBuffer.diffmap[wr]
							if texname=="" do (
								texname = "missing" + (wr as string) + ".png"
								)
							if finditem tmp texname == 0 do (
								append tmp texname
								)
							)
						writelong s tmp.count
						for wr = 1 to tmp.count do (
							pmxwritestring s tmp[wr] pmx_flags[1]
							)
						writelong s matBuffer.diffmap.count
						for wr = 1 to matBuffer.diffmap.count do (
							matname =  "mat_"+(wr as string)
							if nameMatsByTex == true then (
								if matBuffer.diffmap[wr]!= "" do (
									matname =  "mat_"+(getFilenameFile matBuffer.diffmap[wr])
									)
								)
							else (
								if matBuffer.name[wr]!="" do (
									matname = matBuffer.name[wr]
									)
								)
							pmxwritestring s matname pmx_flags[1]
							pmxwritestring s matname pmx_flags[1]
							writefloat s (matBuffer.diffuse[wr].red / 255.0) -- Diffuse Colour
							writefloat s (matBuffer.diffuse[wr].green / 255.0)
							writefloat s (matBuffer.diffuse[wr].blue / 255.0)
							writefloat s (matBuffer.opacity[wr] / 100.0) -- Opacity
							writefloat s (matBuffer.specular[wr].red / 255.0) -- Specular Colour
							writefloat s (matBuffer.specular[wr].green / 255.0)
							writefloat s (matBuffer.specular[wr].blue / 255.0)
							writefloat s .5 -- Gloss
							writefloat s (matBuffer.ambient[wr].red / 255.0) -- Ambient Colour
							writefloat s (matBuffer.ambient[wr].green / 255.0)
							writefloat s (matBuffer.ambient[wr].blue / 255.0)
							writebyte s 0x0C -- render flags
							writefloat s 0.0 -- edge colour
							writefloat s 0.0
							writefloat s 0.0
							writefloat s 1.0
							writefloat s 1.0 -- edge thickness
							idx = finditem tmp matBuffer.diffmap[wr]
							if idx == 0 do (
								idx = finditem tmp ("missing" + (wr as string) + ".png")
								)
							writepmxint s (idx-1) pmx_flags[4] -- map 1 index
							writepmxint s -1 pmx_flags[4] -- map 2 index
							writebyte s 0x00 #unsigned -- sphere map flag
							writebyte s 0x01 #unsigned -- toon map flag
							writebyte s 0x00 #unsigned -- toon map index
							pmxwritestring s "- insert comments here -" pmx_flags[1] -- comment
							writelong s (meshBuffer.faces[wr]*3) #unsigned -- polygon count
							)
						writelong s boneBuffer.name.count
						for wr = 1 to boneBuffer.name.count do (
							pmxwritestring s boneBuffer.name[wr] pmx_flags[1]
							pmxwritestring s boneBuffer.name[wr] pmx_flags[1]
							
							writefloat s boneBuffer.position[wr][1]
							writefloat s boneBuffer.position[wr][3]
							writefloat s boneBuffer.position[wr][2]
							writepmxint s boneBuffer.parent[wr] pmx_flags[6]
							writelong s 0x00 #unsigned -- Layer
							bflag = 0
							boneEnd = fetchBoneTail boneBuffer.name[wr]
							bflag += 0x0002 -- Can Rotate
							bflag += 0x0004 -- Can Move
							bflag += 0x0008 -- Is Visible
							bflag += 0x0010 -- Is Used

-- 												bflag += 0x0020 -- IK
-- 												bflag += 0x0040 -- ???
-- 												bflag += 0x0080 -- Local grant | grantees 0:User deformation value / IK link / multiple grant 1:Local deformation of the parent
-- 												bflag += 0x0100 -- Grant rotation ?? contraint ??
-- 												bflag += 0x0200 -- Move grant ?? constraint?
-- 												bflag += 0x0400 -- Limit Axis Rotation
-- 												bflag += 0x0800 -- Local Axis
-- 												bflag += 0x1000 -- After the physical deformation
-- 												bflag += 0x2000 -- External parent deformation
-- 												bflag += 0x4000 -- ???
-- 												bflag += 0x8000 -- ???
							boneTarget = getNodeByName boneBuffer.name[wr] exact:true ignoreCase:false all:false
							if boneEnd[1] != 0 then (
								bidx = 1
								bflag += 0x0001 -- Bone End Destination t=bone index, f=relative corrdinate
								--boneTarget = getNodeByName boneBuffer.name[wr] exact:true ignoreCase:false all:false
								boneTarget = boneTarget.children[(boneEnd[1])]
								x=1;while x < boneBuffer.name.count do (
									if boneBuffer.name[x] == boneTarget.name do (
										bidx = x
										x+=boneBuffer.name.count -- break loop
										)
									x+=1
									)
								writeshort s bflag #unsigned -- bone flag
								writepmxint s (bidx-1) pmx_flags[6] -- end bone Index
								)
							else (
								writeshort s bflag #unsigned -- bone flag
									writefloat s (boneEnd[2]-boneBuffer.position[wr][1]) -- x
									writefloat s (boneEnd[4]-boneBuffer.position[wr][3]) -- z
									writefloat s (boneEnd[3]-boneBuffer.position[wr][2]) -- y
								)
							)
						writelong s 0 -- Morph Count, Section Removed.
						writelong s 2 --skips frames
						pmxwritestring s "Root" pmx_flags[1]
						pmxwritestring s "Root" pmx_flags[1]
						writebyte s 0x01 -- frame type
						writelong s 0x01 -- included
						writebyte s 0x00 -- target element
						writepmxint s 0 pmx_flags[6]
						pmxwritestring s "??" pmx_flags[1] -- 0x886860C5
						pmxwritestring s "Exp" pmx_flags[1]
						writebyte s 0x01 -- frame type
						writelong s 0x00 -- included
						writebyte s 0x00 -- target element
						writepmxint s 0 pmx_flags[6]
						writelong s 0 --skips rigid bodies
						writelong s 0 --skips joints
						writeshort s 0 --??
						fclose s
						)
					".OBJ": ( -- wavefront OBJ format
						vertIndex=1
						nextvert=0
						faceIndex=1
						nextface=0
						lastface=0
						faceCounter=0
						for f = 1 to meshBuffer.name.count do ( --dumps output as a wavefront OBJ format
							nextvert+=meshBuffer.vertices[f]
							format "# % vertices\n" meshBuffer.vertices[f] to:out_file
							for i = vertIndex to nextvert do (
								format "v % % %\n" (vertBuffer.position[i][1]*mshScale) (vertBuffer.position[i][3]*mshScale) (vertBuffer.position[i][2]*-mshScale) to:out_file
								)
							format "\n# % vertex normals\n" meshBuffer.vertices[f] to:out_file
							for i = vertIndex to nextvert do (
								norm=normalize [(vertBuffer.normal[i][1]*mshScale),(vertBuffer.normal[i][3]*mshScale),(vertBuffer.normal[i][2]*-mshScale)]
								format "vn % % %\n" norm.x norm.y norm.z to:out_file
								-- format "vn % % %\n" (vertBuffer.normal[i][1]*mshScale) (vertBuffer.normal[i][3]*mshScale) (vertBuffer.normal[i][2]*-mshScale) to:out_file	
								)
							format "\n# % texture coords\n" meshBuffer.vertices[f] to:out_file
							for i = vertIndex to nextvert do (
								format "vt % % 0.0\n" vertBuffer.texture1[i][1] vertBuffer.texture1[i][2] to:out_file
								)
							vertIndex+=meshBuffer.vertices[f]
							)
						print ("My Face Array has "+(faceBuffer.count as string)+" Entries")
						for f = 1 to meshBuffer.name.count do (
							format "\n# % faces\n" meshBuffer.faces[f] to:out_file
							format "g %\n" meshBuffer.name[f] to:out_file
							nextface+=meshBuffer.faces[f]
							print ("Currently Reading Set "+(f as string)+" from index "+(faceIndex as string)+" to "+(nextface as string)+"\n")
							for i = faceIndex to nextface do (
								fa=faceBuffer[(faceCounter+1)]+lastface
								fb=faceBuffer[(faceCounter+2)]+lastface
								fc=faceBuffer[(faceCounter+3)]+lastface
								format "f %/%/% %/%/% %/%/%\n" fa fa fa fb fb fb fc fc fc to:out_file
								faceCounter+=3
								)
							faceIndex+=meshBuffer.faces[f]
							lastface+=meshBuffer.vertices[f]
							)
						)
					".MESH": ( -- xnalara BINARY format
						close out_file
						
						s = fopen ssource "wb"
						fclose s
						s = fopen ssource "ab+"
						fseek s 0 #seek_set
						
						vertIndex=1
						nextvert=0
						faceIndex=1
						nextface=0
						faceCounter=0
						
						writelong s boneBuffer.name.count #unsigned
						for f = 1 to boneBuffer.name.count do (
							xnalara_writestring s boneBuffer.name[f]
							writeshort s boneBuffer.parent[f] #unsigned
							writefloat s (boneBuffer.position[f][1]*mshScale)
							writefloat s (boneBuffer.position[f][3]*mshScale)
							writefloat s (boneBuffer.position[f][2]*-mshScale)
							)
						fflush s
						writelong s meshBuffer.name.count #unsigned
						for f = 1 to meshBuffer.name.count do (
							nextvert+=meshBuffer.vertices[f]
							nextface+=meshBuffer.faces[f]
							txt = ""
							for y in groups[(meshBuffer.matinfo[f][1])].name do (
								if txt !="" do txt += "_"
								txt+= (
									(
										case y of (
											#id: (meshBuffer.matinfo[f][1]as integer)
											#name: (meshBuffer.name[f])
											#power: (meshBuffer.matinfo[f][2]/100)
											#reflect: (meshBuffer.matinfo[f][2]/100)
											#bump1: meshBuffer.matinfo[f][3]
											#bump2: meshBuffer.matinfo[f][4]
											#null: "0"
											)
										) as string
									)
								)
							xnalara_writestring s txt
							writelong s 1 #unsigned -- Multiple UV channels not setup yet
							writelong s (groups[(meshBuffer.matinfo[f][1])].textures.count) #unsigned -- texture count
							matName=(matBuffer.diffmap[f] as stringstream)
							if (skipToString matName "diff_null.tga")==OK do (
								seek matName 21
								matName=(readChars matName (matBuffer.diffmap[f].count-21)) as stringstream
								cr=(readDelimitedString matName " ") as integer
								cg=(readDelimitedString matName " ") as integer
								cb=(readDelimitedString matName ")") as integer
								matBuffer.diffmap[f]=("diff_null_"+(meshBuffer.name[f] as string)+".tga")
								maketext (fpath+matBuffer.diffmap[f]) (color cr cg cb)
								)
							if matBuffer.diffmap[f] == "" do matBuffer.diffmap[f] = "missing.tga"
							if matBuffer.normmap[f] == "" do matBuffer.normmap[f] = "missing.tga"
							if matBuffer.specmap[f] == "" do matBuffer.specmap[f] = "missing.tga"
							if matBuffer.dirtmap[f] == "" do matBuffer.dirtmap[f] = "missing.tga"
							if matBuffer.envmap[f] == "" do matBuffer.envmap[f] = "missing.tga"
							if matBuffer.maskmap[f] == "" do matBuffer.maskmap[f] = "missing.tga"
							if matBuffer.bumpmap1[f] == "" do matBuffer.bumpmap1[f] = "missing.tga"
							if matBuffer.bumpmap2[f] == "" do matBuffer.bumpmap2[f] = "missing.tga"
							
							for y in groups[(meshBuffer.matinfo[f][1])].textures do (
								xnalara_writestring(s)(
									case y of (
										#diffuse: matBuffer.diffmap[f]
										#spec: matBuffer.specmap[f]
										#light: matBuffer.dirtmap[f]
										#normal: matBuffer.normmap[f]
										#mask: matBuffer.maskmap[f]
										#bump1: matBuffer.bumpmap1[f]
										#bump2: matBuffer.bumpmap2[f]
										#env: matBuffer.envmap[f]
										#illum: "missing.tga"
										default: "missing.tga"
										)
									)
								writelong s 0 #unsigned -- UV Layer Index
								)
							fflush s
							writelong s meshBuffer.vertices[f] #unsigned
							for i = vertIndex to nextvert do (
								writefloat s (vertBuffer.position[i][1]*mshScale)
								writefloat s (vertBuffer.position[i][3]*mshScale)
								writefloat s (vertBuffer.position[i][2]*-mshScale)
								if normVN==true do (vertBuffer.normal[i] = normalize vertBuffer.normal[i])
								writefloat s vertBuffer.normal[i][1]
								writefloat s vertBuffer.normal[i][3]
								writefloat s -vertBuffer.normal[i][2]
								writebyte s 0xFF #unsigned -- vertex colours not setup yet
								writebyte s 0xFF #unsigned
								writebyte s 0xFF #unsigned
								writebyte s 0xFF #unsigned
								-- format "% % % %\n" (vertBuffer.colour[i].red as integer) (vertBuffer.colour[i].green as integer) (vertBuffer.colour[i].blue as integer) 0 to:out_file -- vertex colours not setup yet
								writefloat s vertBuffer.texture1[i][1] -- needs UV layer count, net setup yet
								writefloat s (vertBuffer.texture1[i][2]*-1)
								-- Vertex Tangents
								writefloat s vertBuffer.tangent[i][1]
								writefloat s vertBuffer.tangent[i][3]
								writefloat s -vertBuffer.tangent[i][2]
								writefloat s vertBuffer.tangent[i][4]
								
								writeshort s vertBuffer.boneids[i][1] #unsigned
								writeshort s vertBuffer.boneids[i][2] #unsigned
								writeshort s vertBuffer.boneids[i][3] #unsigned
								writeshort s vertBuffer.boneids[i][4] #unsigned
								
								writefloat s vertBuffer.weights[i][1]
								writefloat s vertBuffer.weights[i][2]
								writefloat s vertBuffer.weights[i][3]
								writefloat s vertBuffer.weights[i][4]
								fflush s
								)
							--format "FACE BUFFER: %\n" faceBuffer.count
							writelong s meshBuffer.faces[f] #unsigned
							--format "stride: %\n" (nextface-faceIndex+1)
							for i = faceIndex to nextface do (
								fa=faceBuffer[(faceCounter+1)]-1
								fb=faceBuffer[(faceCounter+2)]-1
								fc=faceBuffer[(faceCounter+3)]-1
								--format "% % %\t|\t% % %\n" fc fb fa (faceCounter+1) (faceCounter+2) (faceCounter+3)
								writelong s fc #unsigned
								writelong s fb #unsigned
								writelong s fa #unsigned
								faceCounter+=3
								)
							fflush s
							faceIndex+=meshBuffer.faces[f]
							vertIndex+=meshBuffer.vertices[f]
							) -- mesh loop
						fflush s
						fclose s
						)
					default: (
						Messagebox ("Error\n"+sext" Not supported?")
						)
					)
				)
			if enable_export_mode2 == false then (
				close out_file
				)
			else (
				fclose out_file
				)
			
			if doesFileExist (fpath+"\\MeshAsciiToBin.exe")==true do(
			DOSCommand ("MeshAsciiToBin.exe \""+ssource+"\""))
			
			if areTexturesCopied do (copyTexturesTo(fpath))
			if dupNames!="" do messagebox ("Warning!\nThe Following Objects Were Renamed\n\n"+dupNames)
			if boneWarning!="" do messagebox ("Warning!\nThe Following Meshes Exceed The "+(boneLimit as string)+" Bone Limit\n\n"+boneWarning)
			if failedgrabs!="" do(MessageBox ("WARNGING!\nFollowing Textures Failed to Copy\n\n"+failedgrabs))
			)
		else (
			messagebox "FAIL!!\nNothing In Selection Valid to Export"
			)
		)
	return_state
	)
iniFile = ((GetDir #plugcfg)+"\\xnalara_tool.ini")
-- close iniFile;close outfile;gc()
if (doesFileExist iniFile) == true then (
useINI=retrieveini useINI iniFile "General" "enable"
if useINI == true then (
imp_path=retrieveini imp_path iniFile "General" "in_path"
exp_path=retrieveini exp_path iniFile "General" "out_path"
rescale=retrieveini rescale iniFile "General" "scale"
boneLimit=retrieveini autoMeshBreak iniFile "General" "bone_limit_auto_break"
boneLimit=retrieveini boneLimit iniFile "General" "bone_limit"
metric_scale=retrieveini metric_scale iniFile "General" "in_scale"
imperial_scale=retrieveini imperial_scale iniFile "General" "out_scale"
boneSize=retrieveini boneSize iniFile "General" "bone_size"
clearscene=retrieveini clearscene iniFile "General" "clear_scene"
guessBone=false
bsenable=true

meshON=retrieveini meshON iniFile "Import" "mesh"
matON=retrieveini matON iniFile "Import" "mats"
boneON=retrieveini boneON iniFile "Import" "bones"
skinON=retrieveini skinON iniFile "Import" "skin"
normON=retrieveini normON iniFile "Import" "normals"
mshHde=retrieveini mshHde iniFile "Import" "unused_hide"
mshSingle=retrieveini mshSingle iniFile "Import" "single_mesh"
impFixed=retrieveini impFixed iniFile "Import" "use_path"
renamedups=retrieveini renamedups iniFile "Import" "auto_rename"
keepRG=retrieveini keepRG iniFile "Import" "preserve_mats"
orientate=retrieveini orientate iniFile "Import" "reorientate_bones"
boneLinks=retrieveini boneLinks iniFile "Import" "boneon_disalbed"
boneEnable=retrieveini boneEnable iniFile "Import" "showlinks"

matNames=retrieveini matNames iniFile "Export" "name_by_mat"
expFixed=retrieveini expFixed iniFile "Export" "use_path"
mshOptimise=retrieveini mshOptimise iniFile "Export" "optimize_output"
reviewMats=retrieveini reviewMats iniFile "Export" "use_mat_editor"
enable_export_mode2=retrieveini matNames iniFile "Export" "enable_export_mode2"

-- normVN=retrieveini normVN iniFile "Import" "normals"
normVN=true
)else(deleteFile iniFile;useINI=false)) else (
format_ini iniFile
)



matEntry = (matprops objInfo:#() objName:#() checksum:#() renderGroup:#() layers:#() diffuseMap:#() \
occlusionMap:#() normalMap:#() SpecularMap:#() MaskingMap:#() bumpMap1:#() bumpMap2:#() \
reflectionMap:#() bumpScale1:#() bumpScale2:#() power:#() cam1:#() cam2:#())

/*	--=========================================================
	5.1		Graphical Interface: Rollouts /  Events
*/	--=========================================================

try(destroyDialog appGUI)catch();try(destroyDialog exoptions)catch()
try(destroyDialog expPath)catch();try(destroyDialog impPath)catch()
try(destroyDialog texbox)catch();try(destroyDialog AboutBox)catch()
try(destroyDialog asciiedit)catch();try(MemStreamMgr.close f)catch()
try(destroydialog rg_mat_editor_prompt)catch()
try(destroydialog progressTest)catch()
rollout progressTest "Progress Test" (
	progressbar doit_prog color:red -- a red progress bar
	timer clock "testClock" interval:1000 --tick once a second
	on clock tick do (
		format "Time: %\n" doit_prog_progress
		doit_prog.value = doit_prog_progress
		)
	)
rollout appGUI "XNALara Converter" width:175 height:410 (
	button btn1 "IMPORT" pos:[16,8] width:120 height:32
	groupBox grp1 "Import Options" pos:[8,111] width:160 height:106
	editText edt1 "Scale:" pos:[10,88] width:86 height:16 bold:true text:(rescale as string)
	checkbox chk1 "Single mesh" pos:[24,129] width:128 height:17 checked:mshSingle
	checkbox chk2 "Hide Unused Bones" pos:[24,149] width:140 height:17 checked:mshHde
	checkbox chk3 "Vertex Normals (Slow)" pos:[24,169] width:128 height:17 enabled:true checked:false
	checkbox chk8 "Preserve Render Groups" pos:[24,189] width:138 height:17 enabled:true checked:true
	groupBox grp2 "Export Options" pos:[8,221] width:160 height:164
	checkbox chk9 "Optimize Vertices" pos:[24,239] width:128 height:17 checked:false
	checkbox chk4 "Selection Only" pos:[24,259] width:128 height:17
	checkbox chk5 "Reparent Bones" pos:[24,279] width:128 height:17
	checkbox chk6 "Copy Textures" pos:[24,299] width:128 height:17 enabled:true checked:false
	checkbox chk7 "Open Editor On Export" pos:[24,319] width:128 height:17 enabled:true checked:reviewMats
	dropdownlist ddl_exportto "XnaLara Version:" pos:[24,339] width:128 height:17 items:#("Original", "XNAaraL", "Daemon") enabled:false
	button btn3 "About" pos:[123,388] width:42 height:18
	label lbl2 "" pos:[11,390] width:98 height:17
	button btn1b "+" pos:[140,12] width:24 height:24
	button btn2 "EXPORT" pos:[16,48] width:120 height:32
	button btn2b "+" pos:[140,52] width:24 height:24
	button btn7 "Test" pos:[96,88] width:32 height:16
	button btn8 "Options" pos:[128,88] width:43 height:16
	local runtime=[0,0,0],return_state=false,logErrorWeights=""
	on appGUI open do (
		lbl2.caption=rev
		buildRenderGroups()
		ddl_exportto.selection = 1
		chk3.checked = normON
		)
	on chk1 changed theState do (
		mshSingle = theState;writeINI iniFile "Import" "single_mesh" theState
		)
	on chk2 changed theState do (
		mshHde = theState;writeINI iniFile "Import" "unused_hide" theState
		)
	on chk3 changed theState do (normON = theState)
	on edt1 entered txt do (
		if (txt as float)!=undefined do (
			if (txt as float)!=0 then (
				rescale=txt as float
				writeINI iniFile "General" "scale" txt
				)
			else (
				messagebox "Input Invalid\nNumber Must Be Larger Than 0"
				)
			)
		)
	on chk7 changed theState do (
		reviewMats=theState
		)
	on btn8 pressed do (
		try(
			destroyDialog exoptions
			)
		catch()
		createDialog exoptions
		)
	on btn1b pressed do (
		if fsource==undefined do (
			fsource=""
			)
		createDialog impPath
		)
	on btn2b pressed do (
		if ssource==undefined do (
			ssource=""
			)
		createDialog expPath
		)
	on btn1 pressed do ( -- IMPORT
		local mode=0
		if clearscene == true do (
			-- resetMaxFile #noprompt -- seems to be slower
			delete $*
			)
		fsource = GetOpenFileName \
			caption:"Select Xnalara File" \
			types: (
				"All Supported Formats (*.mesh, *xps, *.ascii)|*.MESH;*.XPS;*.ASCII|" + \
				"Binary File(*.mesh)|*.MESH|" + \
				"Text File(*.ascii)|*.ASCII|" + \
				"XNA Posing Studio (*.xps)|" + \	--XNAaraL's Plagiarism Studios
				"*.XPS|Pose File(*.pose)|*.POSE|" + \
				"All files (*.*)|*.*|"
				)
		if (fsource!=undefined) AND ((doesFileExist fsource)==true) then (
			fpath=getFilenamePath fsource
			fname=getFilenameFile fsource
			fsize=getFileSize fsource
			fext=uppercase (getFilenameType fsource)
			hasBoneRotations = false
			meshArray = (xnalara_format \
				skeleton:(xnalara_skeleton \
					name:#() \
					parent:#() \
					position:#() \
					rotation:#()) \
				mesh:(xnalara_mesh \
					render_group:#() \
					textures:(xnalara_textures \
						uv_channel:#() \
						filepath:#()) \
					geometry:(xnalara_geometry \
						position:#() \
						normal:#() \
						tangent:#() \
						uvw:#() \
						colour:#() \
						weight:#() \
						boneid:#() \
						faces:#() \
						mat:(xnalara_material \
							diffuseMap:#() \
							occlusionMap:#() \
							normalMap:#() \
							SpecularMap:#() \
							MaskingMap:#() \
							bumpMap1:#() \
							bumpMap2:#() \
							reflectionMap:#()
							)
						)
					)
				)
			poseArray = (xnalara_pose name:#() pos:#() rot:#() matrix:#())
			bonePallete = #()
			clearlistener()
			
			bone_count = 0
			if fext == ".MESH" or fext == ".XPS" then (
				f = fopen fsource "rb"
				bone_count = readlong f #unsigned
				/*
					Sadly version control was never initially established in the format spec.
					And as a result the format as evolved as the source was left open and
					recompiled by others. Or even ironically beinf adopted by others as a 
					royalty free format to transition 3D geometry
					
					XNAaraL's Contributions are mostly unknown he made various changes
					to the format every time he made a small update to his recompiled version
					of xnalara called Xna Posing Studios (XPS)
					I got the spec for XNAaraL format from johnzero7, find more on his github
					https://github.com/johnzero7
					
					id-daemon's contribution I assume is less dramtic to the spec just adding
					rotation param to the bone data. Presumably this just applied to the 
					.mesh.ascii format
					
					- mariokart64n
				*/
				
				isXNAaraL = false
				if bone_count==0x0004EEA0 do ( -- XPS ID
					-- check is bone count contain's XNAaraL signature
					isXNAaraL = true
					logErrorWeights = ""
					ver_major = readshort f #unsigned
					ver_minor = readshort f #unsigned
					XNAaraL = ReadXNAaraLString &f (readbyte f #unsigned)
					settingsLen = readlong f #unsigned
					compNetworkName = ReadXNAaraLString &f (readbyte f #unsigned)
					compUserName = ReadXNAaraLString &f (readbyte f #unsigned)
					fullFilename = ReadXNAaraLString &f (readbyte f #unsigned)
					--format "ver_major:\t%\tver_minor:\t%\n" ver_major ver_minor
					if ver_major <= 1 and ver_minor <= 12 then (
						fseek f (settingsLen * 4) #seek_cur
						)
					else (
						skipTheCrap &f settingsLen
						)
					--format "NewBoneCount @ 0x%\n" (bit.intAsHex((ftell f)as integer))
					boneCount = readlong f #unsigned
					--print boneCount
					if boneCount <= 0xFFFF do (
						bone_count = boneCount
						)
					)
				if bone_count <= 0xFFFF then (
					-- simple check to see if we don't have a retarded bone count..
					for i = 1 to bone_count do (
						meshArray.skeleton.name[i] = renamedup meshArray.skeleton.name (if isXNAaraL then (ReadXNAaraLString &f (readbyte f #unsigned)) else (ReadFixedString f (readbyte f #unsigned)))
						meshArray.skeleton.parent[i] = (readshort f)+1
						bone_position = ([(readfloat f),(readfloat f),(readfloat f)]*metric_scale*rescale)
						meshArray.skeleton.position[i] = [(bone_position[1]),(-bone_position[3]),(bone_position[2])]
						)
					if meshON == true do (
						mesh_count = readlong f #unsigned
						validateTangent = true
						for i = 1 to mesh_count do (
							meshArray.mesh.geometry.position[i]=#()
							meshArray.mesh.geometry.normal[i]=#()
							meshArray.mesh.geometry.tangent[i]=#()
							meshArray.mesh.geometry.uvw[i]=#()
							meshArray.mesh.geometry.colour[i]=#()
							meshArray.mesh.geometry.weight[i]=#()
							meshArray.mesh.geometry.boneid[i]=#()
							meshArray.mesh.geometry.faces[i]=#()
							bonePallete[i]=#()
							
							meshArray.mesh.render_group[i] = getRenderGroup (if isXNAaraL then (ReadXNAaraLString &f (readbyte f #unsigned)) else (ReadFixedString f (readbyte f #unsigned)))
							uvw_count=readlong f #unsigned
							meshArray.mesh.textures.filepath[i] = #()
							meshArray.mesh.textures.uv_channel[i] = #()
							for x = 1 to uvw_count do (meshArray.mesh.geometry.uvw[i][x] = #())
							for x = 1 to (readlong f #unsigned) do (
								meshArray.mesh.textures.filepath[i][x] = filenameFromPath (if isXNAaraL then (ReadXNAaraLString &f (readbyte f #unsigned)) else (ReadFixedString f (readbyte f #unsigned)))
								meshArray.mesh.textures.uv_channel[i][x] = (readlong f #unsigned)+1
								)
							for x = 1 to (readlong f #unsigned) do (
								vert_pos = [(readfloat f), (readfloat f), (readfloat f)] * metric_scale * rescale
								vert_nrm = [(readfloat f), (readfloat f), (readfloat f)]
								vert_clr = [(readbyte f #unsigned), (readbyte f #unsigned), (readbyte f #unsigned), (readbyte f #unsigned)] / 255.0
								for y = 1 to uvw_count do (
									meshArray.mesh.geometry.uvw[i][y][x] = [(readfloat f),(1+(-readfloat f)),0]
									)
								if validateTangent == true do (
									validateTangent = false
									if (validateWeight f bone_count) then (tangON=false) else (tangON=true)
									format "Tangent Present: %\n" tangON
									)
								if tangON == true do (
									for y = 1 to uvw_count do (
										meshArray.mesh.geometry.tangent[i][y] = [(readfloat f),(readfloat f),(readfloat f),(readfloat f)]
										)
									)
								if bone_count!=0 do (
									meshArray.mesh.geometry.boneid[i][x] = [readshort f #unsigned, readshort f #unsigned, readshort f #unsigned, readshort f #unsigned] + 1
									meshArray.mesh.geometry.weight[i][x] = [(readfloat f), (readfloat f), (readfloat f), (readfloat f)]
									for b = 1 to 4 do (
										if meshArray.mesh.geometry.boneid[i][x][b] > bone_count do (
											meshArray.mesh.geometry.boneid[i][x] = [1, 0, 0, 0]
											meshArray.mesh.geometry.weight[i][x] = [1.0, 0.0, 0.0, 0.0]
											logErrorWeights += "0x" + (bit.intAsHex((ftell f)as integer))
											logErrorWeights += "\tError:\n\tFile Contains Invalid Bone ID\n\tBoneID:(" + (meshArray.mesh.geometry.boneid[i][x][b] as string)
											logErrorWeights += ") was requested from the skeleton(BoneCount" + (bone_count as string) + ")\n" \
											)
										)
									for b = 1 to 4 do (
										ifUniqueAppend &bonePallete[i] meshArray.mesh.geometry.boneid[i][x][b]
										)
									)
								meshArray.mesh.geometry.position[i][x] = [(vert_pos[1]),(-vert_pos[3]),(vert_pos[2])]
								meshArray.mesh.geometry.normal[i][x] = [(vert_nrm[1]),(-vert_nrm[3]),(vert_nrm[2])]
								meshArray.mesh.geometry.colour[i][x] = [(vert_clr[1]),(-vert_clr[3]),(vert_clr[2])]
								)
-- 							for x in bonePallete[i] do (
-- 								if x > bone_count do (
-- 									format "Error:\n\tifUniqueAppend Function Contains Invalid Bone ID\n\tBoneID:(%) was requested from the skeleton(%)\n" \
-- 										x bone_count
-- 									)
-- 								)
							for x = 1 to (readlong f #unsigned) do (
								fa = readlong f #unsigned
								fb = readlong f #unsigned
								fc = readlong f #unsigned
								meshArray.mesh.geometry.faces[i][x] = [fa,fc,fb] + 1
								)
							)
						if logErrorWeights.count > 0 do (
							print logErrorWeights
							)
						)
					)
				else (
					messagebox "Error!\nFailed to Parse File"
					)
				format "Last Read @ 0x%\n" (bit.intAsHex((ftell f)as integer))
				fclose f
				)
			else if fext == ".ASCII" then (
				f = MemStreamMgr.openFile fsource
				bone_count=(readDelimitedString (f.readLine() as stringstream) " ") as integer
				for i = 1 to bone_count do (
					meshArray.skeleton.name[i] = renamedup meshArray.skeleton.name (f.readLine())
					meshArray.skeleton.parent[i] = ((readDelimitedString (f.readLine() as stringstream) " ") as integer)+1
					bone_position = filterstring (f.readLine()) " "
					--bone_position = (f.readLine()) as stringstream
					--bone_position = [(readDelimitedString bone_position " " as float), (readDelimitedString bone_position " " as float),(readDelimitedString bone_position "" as float)]
					meshArray.skeleton.position[i] = [0.0, 0.0, 0.0]
					meshArray.skeleton.rotation[i] = [0.0, 0.0, 0.0]
					if bone_position.count >= 3 do (
						meshArray.skeleton.position[i] = [(bone_position[1] as float), -(bone_position[3] as float), (bone_position[2] as float)] * metric_scale * rescale
						)
					if bone_position.count >= 6 do (
						meshArray.skeleton.rotation[i] = [(bone_position[4] as float), (-bone_position[6] as float), (bone_position[5] as float)]
						if hasBoneRotations == false do hasBoneRotations = true
						)
					if bone_position.count >= 7 do (
						meshArray.skeleton.rotation[i] = [(bone_position[4] as float), (-bone_position[6] as float), (bone_position[5] as float), (bone_position[7] as float)]
						if hasBoneRotations == false do hasBoneRotations = true
						)
					)
				if meshON == true do (
					meshCount=(readDelimitedString (f.readLine() as stringstream) " ") as integer
					for i = 1 to meshCount do (
						meshArray.mesh.geometry.position[i]=#()
						meshArray.mesh.geometry.normal[i]=#()
						meshArray.mesh.geometry.tangent[i]=#()
						meshArray.mesh.geometry.uvw[i]=#()
						meshArray.mesh.geometry.colour[i]=#()
						meshArray.mesh.geometry.weight[i]=#()
						meshArray.mesh.geometry.boneid[i]=#()
						meshArray.mesh.geometry.faces[i]=#()
						bonePallete[i]=#()
						
						meshArray.mesh.render_group[i] = getRenderGroup (f.readLine())
						uvw_count = (readDelimitedString (f.readLine() as stringstream) " ") as integer
						--format "mesh:\t%\tuvw_count:\t %\n" i uvw_count
						meshArray.mesh.textures.filepath[i] = #()
						meshArray.mesh.textures.uv_channel[i] = #()
						for x = 1 to ((readDelimitedString (f.readLine() as stringstream) " ") as integer) do (
							meshArray.mesh.textures.filepath[i][x] = filenameFromPath (f.readLine())
							meshArray.mesh.textures.uv_channel[i][x] = ((readDelimitedString (f.readLine() as stringstream) " ") as integer)+1
							)
						vert_cnt = try((readDelimitedString (f.readLine() as stringstream) " ") as integer)catch(0)
						if vert_cnt > 0 do (
							meshArray.mesh.geometry.position[i][vert_cnt] = [0.0, 0.0, 0.0]
							meshArray.mesh.geometry.normal[i][vert_cnt] = [0.0, 0.0, 0.0]
							meshArray.mesh.geometry.tangent[i][vert_cnt] = [0.0, 0.0, 0.0]
							meshArray.mesh.geometry.colour[i][vert_cnt] = [0.0, 0.0, 0.0, 0.0]
							meshArray.mesh.geometry.weight[i][vert_cnt] = #()
							meshArray.mesh.geometry.boneid[i][vert_cnt] = #()
							meshArray.mesh.geometry.uvw[i]=#()
							for x = 1 to uvw_count do (
								meshArray.mesh.geometry.uvw[i][x] = #()
								meshArray.mesh.geometry.uvw[i][x][vert_cnt] = [0.0, 0.0, 0.0]
								)
							for x = 1 to vert_cnt do (
								vert_pos = f.readLine() as stringstream
								vert_nrm = f.readLine() as stringstream
								vert_clr = f.readLine() as stringstream
								vert_pos = [(readDelimitedString vert_pos " " as float), (readDelimitedString vert_pos " " as float),(readDelimitedString vert_pos "" as float)]*metric_scale*rescale
								vert_nrm = [(readDelimitedString vert_nrm " " as float), (readDelimitedString vert_nrm " " as float),(readDelimitedString vert_nrm "" as float)]
								vert_clr = [(readDelimitedString vert_clr " " as float), (readDelimitedString vert_clr " " as float),(readDelimitedString vert_clr " " as float),(readDelimitedString vert_clr "" as float)]/255
								for y = 1 to uvw_count do (
									vert_uvw = f.readLine() as stringstream
									vert_uvw = [(readDelimitedString vert_uvw " " as float),(readDelimitedString vert_uvw "" as float)]
									meshArray.mesh.geometry.uvw[i][y][x] = [(vert_uvw[1]),(1+(-vert_uvw[2])),0]
									)
								meshArray.mesh.geometry.weight[i][x] = #()
								meshArray.mesh.geometry.boneid[i][x] = #()
								if bone_count > 0 do (
									vert_bi = f.readLine() as stringstream
									vert_bw = f.readLine() as stringstream
									
									-- Aug 13 2019
									--      Daemon's format adds any number of weights,
									--      this caused a crash in my importer...
									--      Added dynamic reading for weights to fix this issue
									es = false
									b = 1
									while es == false do (
										append meshArray.mesh.geometry.boneid[i][x] ((readDelimitedString vert_bi " " as integer) + 1)
										b += 1
										es = eof vert_bi
										)
									es = false
									b = 1
									while es == false do (
										append meshArray.mesh.geometry.weight[i][x] (readDelimitedString vert_bw " " as float)
										b += 1
										es = eof vert_bw
										)
									if meshArray.mesh.geometry.boneid[i][x].count == 0 do (
										meshArray.mesh.geometry.boneid[i][x] = #(1)
										)
									if meshArray.mesh.geometry.weight[i][x].count == 0 do (
										meshArray.mesh.geometry.weight[i][x] = #(1.0)
										)
									--meshArray.mesh.geometry.boneid[i][x] = [((readDelimitedString vert_bi " " as integer)+1),((readDelimitedString vert_bi " " as integer)+1),((readDelimitedString vert_bi " " as integer)+1),((readDelimitedString vert_bi "" as integer)+1)]
									--meshArray.mesh.geometry.weight[i][x] = [(readDelimitedString vert_bw " " as float),(readDelimitedString vert_bw " " as float),(readDelimitedString vert_bw " " as float),(readDelimitedString vert_bw "" as float)]
									for b = 1 to meshArray.mesh.geometry.boneid[i][x].count do (
										ifUniqueAppend &bonePallete[i] meshArray.mesh.geometry.boneid[i][x][b]
										)
									)
								meshArray.mesh.geometry.position[i][x] = [(vert_pos[1]),(-vert_pos[3]),(vert_pos[2])]
								meshArray.mesh.geometry.normal[i][x] = [(vert_nrm[1]),(-vert_nrm[3]),(vert_nrm[2])]
								meshArray.mesh.geometry.colour[i][x] = [(vert_clr[1]),(-vert_clr[3]),(vert_clr[2])]
								)
							)
						for x = 1 to ((readDelimitedString (f.readLine() as stringstream) " ") as integer) do (
							face = f.readLine() as stringstream
							fa = (readDelimitedString face " " as integer)+1
							fb = (readDelimitedString face " " as integer)+1
							fc = (readDelimitedString face "" as integer)+1
							meshArray.mesh.geometry.faces[i][x] = [fa,fc,fb]
							)
						)
					)
				MemStreamMgr.close f
				)
			else if fext == ".POSE" then (
				f=MemStreamMgr.openFile fsource
				
				i=0
				while (f.eos())==false do (
					i+=1
					str = f.readLine() as stringstream
					poseArray.name[i]=renamedup poseArray.name (readDelimitedString str ":")
					str = filterString (readDelimitedString str "") " "
					poseArray.pos[i]=[(execute str[4]),-(execute str[6]),(execute str[5])]*metric_scale*rescale
					poseArray.rot[i]=(eulerAngles (execute str[1]) -(execute str[3]) (execute str[2]))
					poseArray.matrix[i]=(matrix3 [1,0,0] [0,1,0] [0,0,1] poseArray.pos[i])
					)
				
				MemStreamMgr.close f
				)
			else (messagebox ((fext as string)+" Not Supported"))
			/*	OLD XPS IMPORT CODE
				".XPS":(
					f = fopen fsource "rb"
					bone_count = readlong f #unsigned
					
					
					mode = 0 -- this script wroks by seeking the bone list, and guess what? XNAaraL added in a dummy bone list.. so great time to skip it!
					
					case mode of (
						0: ( -- old versions, pre 2017 ?
							if bone_count>=0xFFFF do (
								pos = validatebones f fsize
								if pos!=-1 do (
									fseek f 0xA0 #seek_set
									bone_count = readlong f #unsigned
									)
								format "New Bone Count % @ 0x%\n" bone_count ((bit.intAsHex(pos))as string)
								)
							if bone_count<=0xFFFF then (
								for i = 1 to bone_count do (
									meshArray.skeleton.name[i] = renamedup meshArray.skeleton.name (ReadFixedString f (validatestrlength f))
									meshArray.skeleton.parent[i] = (readshort f)+1
									bone_position = ([(readfloat f),(readfloat f),(readfloat f)]*metric_scale*rescale)
									meshArray.skeleton.position[i] = [(bone_position[1]),(-bone_position[3]),(bone_position[2])]
									)
								if meshON == true do (
									mesh_count = readlong f #unsigned
									validateTangent = true
									for i = 1 to mesh_count do (
										meshArray.mesh.geometry.position[i]=#()
										meshArray.mesh.geometry.normal[i]=#()
										meshArray.mesh.geometry.tangent[i]=#()
										meshArray.mesh.geometry.uvw[i]=#()
										meshArray.mesh.geometry.colour[i]=#()
										meshArray.mesh.geometry.weight[i]=#()
										meshArray.mesh.geometry.boneid[i]=#()
										meshArray.mesh.geometry.faces[i]=#()
										bonePallete[i]=#()
										
										meshArray.mesh.render_group[i] = getRenderGroup (ReadFixedString f (validatestrlength f))
										uvw_count=readlong f #unsigned
										meshArray.mesh.textures.filepath[i] = #()
										meshArray.mesh.textures.uv_channel[i] = #()
										for x = 1 to uvw_count do (meshArray.mesh.geometry.uvw[i][x] = #())
										for x = 1 to (readlong f #unsigned) do (
											meshArray.mesh.textures.filepath[i][x] = filenameFromPath (ReadFixedString f (validatestrlength f))
											meshArray.mesh.textures.uv_channel[i][x] = (readlong f #unsigned)+1
											)
										for x = 1 to (readlong f #unsigned) do (
											vert_pos = [(readfloat f),(readfloat f),(readfloat f)]*metric_scale*rescale
											vert_nrm = [(readfloat f),(readfloat f),(readfloat f)]
											vert_clr = [(readbyte f #unsigned),(readbyte f #unsigned),(readbyte f #unsigned),(readbyte f #unsigned)]/255
											for y = 1 to uvw_count do (
												meshArray.mesh.geometry.uvw[i][y][x] = [(readfloat f),(1+(-readfloat f)),0]
												)
											if validateTangent == true do (
												validateTangent = false
												tangON = (validateWeight f bone_count)
												if tangON == true then(tangON=false)else(tangON=true)
												)
											if tangON == true do (
												for y = 1 to uvw_count do (
													meshArray.mesh.geometry.tangent[i][y] = [(readfloat f),(readfloat f),(readfloat f),(readfloat f)]
													)
												)
											if bone_count!=0 do (
												meshArray.mesh.geometry.boneid[i][x] = [(readshort f #unsigned+1),(readshort f #unsigned+1),(readshort f #unsigned+1),(readshort f #unsigned+1)]
												meshArray.mesh.geometry.weight[i][x] = [(readfloat f),(readfloat f),(readfloat f),(readfloat f)]
												for b = 1 to 4 do (
													bonePallete[i] = ifUniqueAppend bonePallete[i] meshArray.mesh.geometry.boneid[i][x][b]
													)
												)
											meshArray.mesh.geometry.position[i][x] = [(vert_pos[1]),(-vert_pos[3]),(vert_pos[2])]
											meshArray.mesh.geometry.normal[i][x] = [(vert_nrm[1]),(-vert_nrm[3]),(vert_nrm[2])]
											meshArray.mesh.geometry.colour[i][x] = [(vert_clr[1]),(-vert_clr[3]),(vert_clr[2])]
											)
										for x = 1 to (readlong f #unsigned) do (
											fa = readlong f #unsigned
											fb = readlong f #unsigned
											fc = readlong f #unsigned
											meshArray.mesh.geometry.faces[i][x] = [fa,fc,fb] + 1
											)
										)
									)
								)
							else (
								messagebox "Error!\nFailed to Parse File"
								)
							)
						1: (
							i = 0
							str = ""
							while str!="root ground" and (ftell f)<fsize do (
								while i!=0x72 and (ftell f)<fsize do (
									i  = readbyte f #unsigned
									)
								str  = "r" + (ReadFixedString f 10)
								fseek f -10 #seek_cur
								)
							if str == "root ground" then (
								fseek f -5 #seek_cur
								bone_count = readlong f #unsigned
								for i = 1 to bone_count do (
									str = ""
									i = 0
									while i!=0x0A do (
										i = readbyte f #unsigned
										if i != 0x0A do (
											str += bit.IntAsChar i
											)
										)
									)
								bone_count = 32323232
								if bone_count>=0xFFFF do (
									pos = validatebones f fsize
									if pos!=-1 do (
										fseek f 0xA0 #seek_set
										bone_count = readlong f #unsigned
										)
									format "New Bone Count % @ 0x%\n" bone_count ((bit.intAsHex(pos))as string)
									)
								for i = 1 to bone_count do (
									meshArray.skeleton.name[i] = renamedup meshArray.skeleton.name (ReadFixedString f (validatestrlength f))
									meshArray.skeleton.parent[i] = (readshort f)+1
									bone_position = ([(readfloat f),(readfloat f),(readfloat f)]*metric_scale*rescale)
									meshArray.skeleton.position[i] = [(bone_position[1]),(-bone_position[3]),(bone_position[2])]
									)
								if meshON == true do (
									mesh_count = readlong f #unsigned
									validateTangent = true
									for i = 1 to mesh_count do (
										meshArray.mesh.geometry.position[i]=#()
										meshArray.mesh.geometry.normal[i]=#()
										meshArray.mesh.geometry.tangent[i]=#()
										meshArray.mesh.geometry.uvw[i]=#()
										meshArray.mesh.geometry.colour[i]=#()
										meshArray.mesh.geometry.weight[i]=#()
										meshArray.mesh.geometry.boneid[i]=#()
										meshArray.mesh.geometry.faces[i]=#()
										bonePallete[i]=#()
										
										meshArray.mesh.render_group[i] = getRenderGroup (ReadFixedString f (validatestrlength f))
										uvw_count=readlong f #unsigned
										meshArray.mesh.textures.filepath[i] = #()
										meshArray.mesh.textures.uv_channel[i] = #()
										for x = 1 to uvw_count do (meshArray.mesh.geometry.uvw[i][x] = #())
										for x = 1 to (readlong f #unsigned) do (
											meshArray.mesh.textures.filepath[i][x] = filenameFromPath (ReadFixedString f (validatestrlength f))
											meshArray.mesh.textures.uv_channel[i][x] = (readlong f #unsigned)+1
											)
										for x = 1 to (readlong f #unsigned) do (
											vert_pos = [(readfloat f),(readfloat f),(readfloat f)]*metric_scale*rescale
											vert_nrm = [(readfloat f),(readfloat f),(readfloat f)]
											vert_clr = [(readbyte f #unsigned),(readbyte f #unsigned),(readbyte f #unsigned),(readbyte f #unsigned)]/255
											for y = 1 to uvw_count do (
												meshArray.mesh.geometry.uvw[i][y][x] = [(readfloat f),(1+(-readfloat f)),0]
												)
											if validateTangent == true do (
												validateTangent = false
												tangON = (validateWeight f bone_count)
												if tangON == true then(tangON=false)else(tangON=true)
												)
											if tangON == true do (
												for y = 1 to uvw_count do (
													meshArray.mesh.geometry.tangent[i][y] = [(readfloat f),(readfloat f),(readfloat f),(readfloat f)]
													)
												)
											if bone_count!=0 do (
												meshArray.mesh.geometry.boneid[i][x] = [(readshort f #unsigned+1),(readshort f #unsigned+1),(readshort f #unsigned+1),(readshort f #unsigned+1)]
												meshArray.mesh.geometry.weight[i][x] = [(readfloat f),(readfloat f),(readfloat f),(readfloat f)]
												for b = 1 to 4 do (
													bonePallete[i] = ifUniqueAppend bonePallete[i] meshArray.mesh.geometry.boneid[i][x][b]
													)
												)
											meshArray.mesh.geometry.position[i][x] = [(vert_pos[1]),(-vert_pos[3]),(vert_pos[2])]
											meshArray.mesh.geometry.normal[i][x] = [(vert_nrm[1]),(-vert_nrm[3]),(vert_nrm[2])]
											meshArray.mesh.geometry.colour[i][x] = [(vert_clr[1]),(-vert_clr[3]),(vert_clr[2])]
											)
										for x = 1 to (readlong f #unsigned) do (
											fa = readlong f #unsigned
											fb = readlong f #unsigned
											fc = readlong f #unsigned
											meshArray.mesh.geometry.faces[i][x] = [fa,fc,fb] + 1
											)
										)
									)
								)
							else (
								format "failed to find root ground"
								)
							)
						)
					format "Last Read @ 0x%\n" ((bit.intAsHex(ftell f))as string)
					fclose f
					)
				*/
			-- print meshArray
			if bone_count<=0xFFFF do (
				if boneON == true and bone_count > 0 do (
					layer_2 = layermanager.newLayerFromName "Bones"
					layer_3 = layermanager.newLayerFromName "Bones_Unused"
					layer_2 = LayerManager.getLayerFromName "Bones"
					layer_3 = LayerManager.getLayerFromName "Bones_Unused"
					bone_count = meshArray.skeleton.position.count
					boneArray = #()
					childArray = #()
					posArray = #()
					for i = 1 to bone_count do (
						childArray = copy meshArray.skeleton.parent #nomap
						posArray[i] = [0,0,0]
						find = findItem childArray i
						
						if find!=0 then (
							-- format "Name: %\n" meshArray.skeleton.name[i]
								posArray[i] = meshArray.skeleton.position[find]
							cnt=1;while find!=0 do (
								-- format "\t%\n" meshArray.skeleton.name[find]
								childArray[find]=-1
								find = findItem childArray i
								if find != 0 do (
									posArray[i] += meshArray.skeleton.position[find]
									cnt+=1
									)
								)
							posArray[i] = posArray[i] / cnt
							)
						else (
							if meshArray.skeleton.parent[i]!=0 then (
								posArray[i] = meshArray.skeleton.position[i]+((meshArray.skeleton.position[i]-meshArray.skeleton.position[(meshArray.skeleton.parent[i])]))
								)
							else (
								posArray[i] = meshArray.skeleton.position[i]+([0,0,0.3]*metric_scale*rescale)
								)
							)
						)
					bone_matrix = #()
					for i = 1 to bone_count do (
						b = getNodeByName meshArray.skeleton.name[i]
						if b == undefined do (
							-- bonSize=boneSize*metric_scale*rescale
							-- if guessBone==true do(
							-- if bsenable==true or boneSize==0 or boneSize==undefined do (bonSize=((distance startPos endPos)/100)*metric_scale*rescale))
							b = bonesys.createbone meshArray.skeleton.position[i] posArray[i] [0, 0, 1]
							-- b = bonesys.createbone meshArray.skeleton.position[i] (meshArray.skeleton.position[i]+[0,0,1]) [0,1,0]
							b.name  = meshArray.skeleton.name[i]
							b.width = b.height = 1
							b.sidefins = b.frontfin = b.backfin = off
							b.length = distance meshArray.skeleton.position[i] posArray[i]
							layer_2.addNode b
							if b.length<=1 do (b.length=1)
							if (findItem meshArray.skeleton.parent i)==0 do (b.length=2)
							if (meshArray.skeleton.parent[i])==0 do (b.length=2)
							if guessSize == true do (b.width = b.height = b.length/2;if b.width>=4 do (b.width = b.height = 2))
							if boneLinks == true do (b.showLinks = b.showLinksOnly = true)
							if boneEnable == false do (b.boneEnable=false)
							if boneSeeThru == true do (b.xray = on)
							if orientate == true do (b.transform = matrix_lookat [0,0,1] (matrix3 [1,0,0] [0,1,0] [0,0,1] meshArray.skeleton.position[i]) (matrix3 [1,0,0] [0,1,0] [0,0,1] posArray[i]))
							if mshHde==true do(if (skipToString ((meshArray.skeleton.name[i]) as stringstream) "unused")==OK do (layer_3.addNode b;hide b))
							
							if hasBoneRotations do (
-- 								append bone_matrix (
-- 									(eulerAngles \
-- 										(radToDeg meshArray.skeleton.rotation[i].x) \
-- 										(radToDeg meshArray.skeleton.rotation[i].y) \
-- 										(radToDeg meshArray.skeleton.rotation[i].z)) as matrix3
-- 									)
								append bone_matrix (
									(quat \
										(meshArray.skeleton.rotation[i][1]) \
										(meshArray.skeleton.rotation[i][2]) \
										(meshArray.skeleton.rotation[i][3]) \
										(meshArray.skeleton.rotation[i][4])) as matrix3
									)
								bone_matrix[bone_matrix.count] = inverse bone_matrix[bone_matrix.count]
-- 								bone_matrix[bone_matrix.count] = rotateY bone_matrix[bone_matrix.count] 90
-- 								bone_matrix[bone_matrix.count] = rotateZ bone_matrix[bone_matrix.count] 90
								bone_matrix[bone_matrix.count].row4 = meshArray.skeleton.position[i]
								b.transform = bone_matrix[bone_matrix.count]
								)
							)
						boneArray[i] = b
						)
					for i = 1 to bone_count do (
						boneArray[i].boneEnable = true
						if meshArray.skeleton.parent[i] !=0 do (
							--bone_transform = relativetoworld smdArray.skeleton.frame[1] smdArray.nodes i
							--boneArray[i].transform *= boneArray[(meshArray.skeleton.parent[i])].transform
							boneArray[i].parent = boneArray[(meshArray.skeleton.parent[i])]
							)
						)
					)
				if meshON == true do (
					layer_1 = layermanager.newLayerFromName "Meshes"
					layer_1 = LayerManager.getLayerFromName "Meshes"
					sumArray = #()
					tmp=#()
					id = 0
					mesh_count = meshArray.mesh.render_group.count
					if optMats == true then (
						for i = 1 to mesh_count do (
							tex_names = meshArray.mesh.render_group[i].id as string -- this is the group number
							for x = 1 to meshArray.mesh.textures.filepath[i].count do ( -- huh wtf i append the number as a string to the texture name lol
								tex_names+=meshArray.mesh.textures.filepath[i][x]
								)
							id = findItem tmp tex_names
							if id==0 then (
								append tmp tex_names
								append sumArray tmp.count
								meshArray.mesh.render_group[i].sum = tmp.count
								)
							else (
								meshArray.mesh.render_group[i].sum = id
								)
							)
						)
					else (
						for i = 1 to mesh_count do (
							meshArray.mesh.render_group[i].sum = i
							append sumArray i
							)
						)
					mat = multimaterial numsubs:mesh_count
					if mshSingle == false then (
						for i = 1 to mesh_count do (
							matid = findItem sumArray meshArray.mesh.render_group[i].sum
							setRGmaterial mat.materialList[matid] meshArray.mesh.render_group[i].id meshArray.mesh.textures.filepath[i] meshArray.mesh.textures.uv_channel[i] fpath
							matArray = #()
							for j = 1 to meshArray.mesh.geometry.faces[i].count do (
								matArray[j]=matid
								)
							msh = mesh \
								vertices:meshArray.mesh.geometry.position[i] \
								faces:meshArray.mesh.geometry.faces[i] \
								materialIDs:matArray
							msh.numTVerts = meshArray.mesh.geometry.position[i].count
							buildTVFaces msh
							layer_1.addNode msh
							msh.material = mat.materialList[matid]
							if (try(meshArray.mesh.render_group[i].name)catch("")) != "" do (
								msh.material.name = meshArray.mesh.render_group[i].name
								)
							msh.wirecolor = random (color 0 0 0) (color 255 255 255)
							if matON == true then (
								showTextureMap msh.material true
								)
							else (
								msh.material.materialList[matid].Diffuse = random (color 0 0 0) (color 255 255 255)
								)
							
							
							--for j = 1 to meshArray.mesh.geometry.faces[i].count do setTVFace msh j meshArray.mesh.geometry.faces[i][j]
							--meshop.setNumMaps msh (meshArray.mesh.geometry.uvw[i].count+1) keep:true
							for x = 1 to meshArray.mesh.geometry.uvw[i].count do (
								meshop.setMapSupport msh (x - 1) true
								meshop.defaultMapFaces msh x
								for j = 1 to meshArray.mesh.geometry.uvw[i][x].count do (
									meshOp.setMapVert msh x j meshArray.mesh.geometry.uvw[i][x][j]
									)
								-- update msh
								)
							
							
							
							if skinON==true and boneON==true and bone_count > 0 do (
								select msh 
								max modify mode
								skinMod = skin ()
								addModifier msh skinMod
								num_bones = bonePallete[i].count
								for x = 1 to num_bones do (
									if bonePallete[i][x]!=0 do (
										if x!=bonePallete[i].count
										then (skinOps.addbone skinMod boneArray[(bonePallete[i][x])] 0)
										else (skinOps.addbone skinMod boneArray[(bonePallete[i][x])] 1)
										)
									)
								boneIDMap = #()
								for x = 1 to num_bones do (
									boneNameIdx = findItem meshArray.skeleton.name (skinOps.GetBoneName skinMod x 0)
									if boneNameIdx == 0 do boneNameIdx = 1
									boneIDMap[x] = boneNameIdx
									)
								modPanel.setCurrentObject skinMod
								
								for x = 1 to meshArray.mesh.geometry.weight[i].count do (
									bi = #()
									wv = #()
									wt = 0.0
									for j = 1 to meshArray.mesh.geometry.boneid[i][x].count do (
										boneid = meshArray.mesh.geometry.boneid[i][x][j]
										weight = meshArray.mesh.geometry.weight[i][x][j]
										
										if weight > 0.0 do (
											if weight > 1.0 do weight = 1.0
											wt += weight
											b = findItem bi (findItem boneIDMap boneid)
											if b == 0 then (
												append bi (findItem boneIDMap boneid)
												append wv weight
												)
											else (
												wv[b] += weight
												)
											)
										)
									wv[1] += wt
-- 									if i == 1 and x < 10 do (
-- 										print bi
-- 										print wv
-- 										format "--\n"
-- 										)
									skinOps.ReplaceVertexWeights skinMod x bi wv
									)
								)
							
							if normON do (
								max modify mode
								select msh
								normMod = Edit_Normals()
								normMod.selectBy = 1
								normMod.displayLength = 0.50
								normMod.showHandles = on
								
								modPanel.setCurrentObject normMod
								addModifier msh normMod
								
								normMod.EditNormalsMod.SetSelection #{1..(normMod.GetNumNormals())}
								--normMod.EditNormalsMod.Break()
								normMod.EditNormalsMod.Reset()
								for x = 1 to normMod.EditNormalsMod.GetNumFaces() do (
									for j = 1 to 3 do (
										normMod.SetNormalID x j meshArray.mesh.geometry.faces[i][x][j]
										)
									)
								for x = 1 to meshArray.mesh.geometry.normal[i].count do (
									subobjectLevel = 1
									normMod.EditNormalsMod.SetNormal x meshArray.mesh.geometry.normal[i][x]
									subobjectLevel = 0
									)
								normMod.EditNormalsMod.MakeExplicit()
								enableSceneRedraw()
								)
							)
						)
					else (
						matArray = #()
						faceArray = #()
						faceadd = 0
						
						-- pre-pass find out how many uv channels before merging
						max_uv_channel_count = 0
						for i = 1 to mesh_count do (
							if meshArray.mesh.geometry.uvw[i].count > max_uv_channel_count do (
								max_uv_channel_count = meshArray.mesh.geometry.uvw[i].count
								)
							)
						
						for i = 1 to mesh_count do (
							if meshArray.mesh.geometry.uvw[i].count < max_uv_channel_count do (
								for z = meshArray.mesh.geometry.uvw[i].count to max_uv_channel_count do (
									append meshArray.mesh.geometry.uvw[i] (
										for j = 1 to meshArray.mesh.geometry.position[i].count collect ([0,0,0])
										)
									)
								)
							)
						
						
						for i = 1 to mesh_count do (
							matid = findItem sumArray meshArray.mesh.render_group[i].sum
							for j = 1 to meshArray.mesh.geometry.faces[i].count do (
								append matArray matid
								meshArray.mesh.geometry.faces[i][j] = meshArray.mesh.geometry.faces[i][j] + faceadd
								)
							faceadd+=meshArray.mesh.geometry.position[i].count
							join faceArray meshArray.mesh.geometry.faces[i]
							setRGmaterial mat.materialList[matid] meshArray.mesh.render_group[i].id meshArray.mesh.textures.filepath[i] meshArray.mesh.textures.uv_channel[i] fpath
							

							)
						for i = 2 to mesh_count do (
							join meshArray.mesh.geometry.position[1] meshArray.mesh.geometry.position[i]
							join meshArray.mesh.geometry.normal[1] meshArray.mesh.geometry.normal[i]
							join meshArray.mesh.geometry.colour[1] meshArray.mesh.geometry.colour[i]
							join meshArray.mesh.geometry.boneid[1] meshArray.mesh.geometry.boneid[i]
							join meshArray.mesh.geometry.weight[1] meshArray.mesh.geometry.weight[i]
							for z = 1 to max_uv_channel_count do (
								join meshArray.mesh.geometry.uvw[1][z] meshArray.mesh.geometry.uvw[i][z]
								)
							for z = 1 to bonePallete[i].count do (
								IfUniqueAppend &bonePallete[1] bonePallete[i][z]
								)
							)
						--uvw_count = 1;for i = 1 to mesh_count do (
						--	if meshArray.mesh.geometry.uvw[i].count>=uvw_count do (uvw_count=meshArray.mesh.geometry.uvw[i].count)
						--	)
						msh = mesh \
							vertices:meshArray.mesh.geometry.position[1] \
							faces:faceArray \
							materialIDs:matArray
						msh.numTVerts = meshArray.mesh.geometry.position[1].count
						buildTVFaces msh
						layer_1.addNode msh
						msh.material = mat
						msh.wirecolor = random (color 0 0 0) (color 255 255 255)
						if matON == true then (
							for j = 1 to mat.count do (
								if (try(meshArray.mesh.render_group[j].name)catch("")) != "" do (
									msh.material.materialList[j].name = meshArray.mesh.render_group[j].name
									)
								showTextureMap msh.material.materialList[j] true
								)
							)
						else (
							for j = 1 to mat.count do (
								msh.material.materialList[j].Diffuse = random (color 0 0 0) (color 255 255 255)
								)
							)
						-- for j = 1 to meshArray.mesh.geometry.position[1].count do (setNormal msh j meshArray.mesh.geometry.normal[1][j])
						--for j = 1 to faceArray.count do (
						--	setTVFace msh j faceArray[j]
						--	)
						--meshop.setNumMaps msh (uvw_count+1) keep:true
						
						
						-- August 17 2019
						-- Yeahh... I guess the previous import code to bring in UV's past channel 1
						-- was not working when I had just always assumed it did lol
						-- anyway on top of that I just patched this in and there is two line duplicates
						-- so this eventually should be piped into a single function...
						
						
						
						/*
						cnt=1
						for i = 1 to mesh_count do (
							meshop.setMapSupport msh (i - 1) true
							meshop.defaultMapFaces msh i
							for j = 1 to meshArray.mesh.geometry.uvw[i][1].count do (
								for x = 1 to uvw_count do (
									if x <= meshArray.mesh.geometry.uvw[i].count then (
										meshOp.setMapVert msh x cnt meshArray.mesh.geometry.uvw[i][x][j]
										)
									else(
										meshOp.setMapVert msh x cnt meshArray.mesh.geometry.uvw[i][1][j]
										)
									)
								cnt+=1
								)
							-- update msh
							)
							*/
						
						for x = 1 to max_uv_channel_count do (
							--meshop.setMapSupport msh (x - 1) true
							meshop.defaultMapFaces msh x
							for j = 1 to meshArray.mesh.geometry.uvw[1][x].count do (
								meshOp.setMapVert msh x j meshArray.mesh.geometry.uvw[1][x][j]
								)
							-- update msh
							)
							
							
							
							
						
						-- August 16 2019
						-- I was having alot of problems with the skins weights missing
						-- So I added a bunch of checks (causes a slight slow down of course)
						-- There are two duplicate skin functions one for combining mesh parts and one that doesnt
						-- I was too lazy to route them to the same function so i just copied one to the other
						-- seems fixed but might not.
						-- may need to look at putting everything to the same function no duplicated lines
						
						
						/*
						if skinON==true and boneON==true and bone_count > 0 do (
							select msh
							max modify mode
							skinMod = skin ()
							addModifier msh skinMod
							num_bones = bonePallete[1].count
							for x = 1 to num_bones do (
								if num_bones!=0 do (
									idx = boneArray[ (bonePallete[1][x]) ]
									if idx == undefined do (
										idx = boneArray[1]
										format "Error:\n\tBone Out of Range: %\n\tIndex(%) was Requested From Array(%)\n" \
											x (bonePallete[1][x] as integer) boneArray.count
										)
									if x < bonePallete[1].count then (
										skinOps.addbone skinMod idx 0
										)
									else (
										skinOps.addbone skinMod idx 1
										)
									)
								)
							boneIDMap = #()
							for x = 1 to num_bones do (
								boneNameIdx = findItem meshArray.skeleton.name (skinOps.GetBoneName skinMod x 0)
								if boneNameIdx==0 do (boneNameIdx=1);boneIDMap[x]=boneNameIdx
								)
							modPanel.setCurrentObject skinMod
							for x = 1 to meshArray.mesh.geometry.weight[1].count do (
								bi = #()
								wv = #()
								for j = 1 to meshArray.mesh.geometry.boneid[1][x].count do (
									boneid = meshArray.mesh.geometry.boneid[1][x][j]
									weight = meshArray.mesh.geometry.weight[1][x][j]
									if boneid<1 or boneid>=boneArray.count do (
										boneid = 1
-- 										format "Error:\n\tBoneID: (%) Out of Range from Array (%)\n" \
-- 											meshArray.mesh.geometry.boneid[1][x][j] boneIDMap.count
										)

									append bi (findItem boneIDMap boneid)
									append wv weight
									-- if bi[bi.count] == 0 do (format "%\n" boneid)
									)
								skinOps.ReplaceVertexWeights skinMod x bi wv
								)
							)
							*/
						if skinON==true and boneON==true and bone_count > 0 do (
							select msh 
							max modify mode
							skinMod = skin ()
							addModifier msh skinMod
							num_bones = bonePallete[1].count
							for x = 1 to num_bones do (
								if bonePallete[1][x]!=0 do (
									if x!=bonePallete[1].count
									then (skinOps.addbone skinMod boneArray[(bonePallete[1][x])] 0)
									else (skinOps.addbone skinMod boneArray[(bonePallete[1][x])] 1)
									)
								)
							boneIDMap = #()
							for x = 1 to num_bones do (
								boneNameIdx = findItem meshArray.skeleton.name (skinOps.GetBoneName skinMod x 0)
								if boneNameIdx == 0 do boneNameIdx = 1
								boneIDMap[x] = boneNameIdx
								)
							modPanel.setCurrentObject skinMod
							
							for x = 1 to meshArray.mesh.geometry.weight[1].count do (
								bi = #()
								wv = #()
								wt = 0.0
								for j = 1 to meshArray.mesh.geometry.boneid[1][x].count do (
									boneid = meshArray.mesh.geometry.boneid[1][x][j]
									weight = meshArray.mesh.geometry.weight[1][x][j]
									
									if weight > 0.0 do (
										if weight > 1.0 do weight = 1.0
										wt += weight
										b = findItem bi (findItem boneIDMap boneid)
										if b == 0 then (
											append bi (findItem boneIDMap boneid)
											append wv weight
											)
										else (
											wv[b] += weight
											)
										)
									)
								wv[1] += wt
								if i == 1 and x < 10 do (
									print bi
									print wv
									format "--\n"
									)
								skinOps.ReplaceVertexWeights skinMod x bi wv
								)
							)
						
						
						-- Aug 17 2019
						-- function was basically not working, replaced it
						/*
						if normON==true do (
							normMod = Edit_Normals()
							addModifier msh normMod
							completeredraw()
							normMod.displayLength = 0
							normSel = #{1..(normMod.GetNumNormals node:msh)}
							for j = 1 to normSel.count do (
								normSel[j]=true
								)
							normMod.EditNormalsMod.SetSelection normSel node:msh
							normMod.EditNormalsMod.Break ()
							subobjectLevel = 0
							)
							*/
						if normON do (
							max modify mode
							select msh
							normMod = Edit_Normals()
							normMod.selectBy = 1
							normMod.displayLength = 0.50
							normMod.showHandles = on
							
							modPanel.setCurrentObject normMod
							addModifier msh normMod
							
							normMod.EditNormalsMod.SetSelection #{1..(normMod.GetNumNormals())}
							--normMod.EditNormalsMod.Break()
							normMod.EditNormalsMod.Reset()
							for x = 1 to normMod.EditNormalsMod.GetNumFaces() do (
								for j = 1 to 3 do (
									normMod.SetNormalID x j faceArray[x][j]
									)
								)
							for x = 1 to meshArray.mesh.geometry.normal[1].count do (
								subobjectLevel = 1
								normMod.EditNormalsMod.SetNormal x meshArray.mesh.geometry.normal[1][x]
								subobjectLevel = 0
								)
							normMod.EditNormalsMod.MakeExplicit()
							enableSceneRedraw()
							)
						)
					)
				)
			if poseArray.name.count!=0 do (
				sliderTime+=1
				animate on (
					for i = 1 to poseArray.name.count do (
						b = getNodeByName poseArray.name[i] exact:true ignoreCase:false
						if b!=undefined do (
							at time sliderTime (
								b.position += poseArray.pos[i]
								in coordsys poseArray.matrix[i] rotate b poseArray.rot[i]
								)
							tfm = poseArray.rot[i] as matrix3
							poseArray.matrix[i]*=tfm
							b = grabchildren b
							for z = 1 to b.count do (
								find = findItem poseArray.name b[z].name
								if find!=0 do (
									poseArray.matrix[find]*=tfm
									)
								)
							)
						)
					)
				)
			Print "Done!"
			)
		else (
			Print "Aborted."
			)
		) -- Close Button for IMPORT
	on btn2 pressed do ( -- EXPORT
		st = timestamp() --get start time in milliseconds
		format "Start: %\n" st
		undo off (
			--with redraw off (
				return_state = writeSceneData \
					expFixed \
					fpath \
					(imperial_scale*rescale) \
					enable_export_mode2 \
					sortbones \
					chk4.checked \
					renamedups \
					autoMeshBreak \
					boneLimit \
					chk5.checked \
					matNames \
					nameMatsByTex \
					reviewMats \
					chk6.checked
				--)
			) -- undo renabled / redraw scene
		format "Ended: %\n" (timestamp())
		runtime = getUnixTime(timestamp() - st)
		format "Completed in: %\n" runtime
		if return_state == true do (
			if chk7.checked then (
				print (
					"DONE!\nOperation Completed in: "+ \
					((runtime[2] as integer) as string) +" mins, " + \
					((runtime[3] as integer) as string) + " secs"
					)
				try(
					createdialog rg_mat_editor_prompt style:#(#style_border)
					)
				catch(
					messagebox "Failed to Launch Editor"
					)
				)
			else (
				messagebox (
					"DONE!\nOperation Completed in: "+ \
					((runtime[2] as integer) as string) +" mins, " + \
					((runtime[3] as integer) as string) + " secs"
					)
				)
			)
		) -- Close Button for EXPORT
	on btn7 pressed do ( -- MAKES LARA OUT OF BOXES
		boxArray=#(
			[0.254551,0.0876954,0.060046], \
			[0.0945508,0.0876954,0.330046], \
			[0.104551,0.0976954,0.200046], \
			[0.134551,0.117695,0.430046], \
			[0.224551,0.267695,0.160046], \
			[0.134551,0.207695,0.160046], \
			[0.134551,0.187695,0.200046], \
			[0.0845509,0.247695,0.210046], \
			[0.0845509,0.0976954,0.210046], \
			[0.0945509,0.0776954,0.090046], \
			[0.0745509,0.0676954,0.260046], \
			[0.0745509,0.0676954,0.230046], \
			[0.174551,0.147695,0.210046], \
			[0.0345509,0.0376954,0.030046], \
			[0.0545509,0.0576954,0.160046], \
			[0.0345509,0.0376954,0.290046], \
			[0.0845509,0.0476954,0.190046], \
			[0.0145509,0.0276954,0.100046], \
			[0.0745509,0.0676954,0.230046], \
			[0.0845509,0.0476954,0.190046], \
			[0.0145509,0.0276954,0.100046], \
			[0.0745509,0.0676954,0.260046], \
			[0.0945508,0.0876954,0.330046], \
			[0.104551,0.0976954,0.200046], \
			[0.134551,0.117695,0.430046], \
			[0.254551,0.0876954,0.060046], \
			[0.0845509,0.0976954,0.210046]
			)
		boxRArray=#(
			(matrix3 [1,0,0] [0,1,0] [0,0,1] [0.0793198,-0.010345,0.0289477]), \
			(matrix3 [0.998291,0.00402233,-0.0583084] [0,0.997629,0.0688201] [0.058447,-0.0687025,0.995924] [0.0793198,0.0728021,0.0888846]), \
			(matrix3 [0.99964,-0.00607565,0.0261353] [0,0.974027,0.22643] [-0.0268322,-0.226348,0.973677] [0.0932135,0.0539341,0.414269]), \
			(matrix3 [0.998343,-0.000971137,-0.0575304] [-0.00072935,0.999564,-0.0295297] [0.057534,0.0295227,0.997907] [0.08057,0.0132125,0.607289]), \
			(matrix3 [1,0,0] [0,0.991,0.133862] [0,-0.133862,0.991] [0,0.0367434,0.920759]), \
			(matrix3 [1,0,0] [0,0.953763,0.30056] [0,-0.30056,0.953763] [0,0.0213415,1.0622]), \
			(matrix3 [1,0,0] [0,0.993587,-0.113071] [0,0.113071,0.993587] [0,-0.0249903,1.19146]), \
			(matrix3 [1,0,0] [0,0.963367,-0.268186] [0,0.268186,0.963367] [0,-0.00659302,1.31708]), \
			(matrix3 [0.906134,0.371979,-0.201379] [0.403865,-0.619279,0.67334] [0.125758,-0.691466,-0.711378] [0.0411788,0.028349,1.48025]), \
			(matrix3 [1,0,0] [0,0.975724,0.219006] [0,-0.219006,0.975724] [0,0.0318617,1.49969]), \
			(matrix3 [-0.0736742,-0.179888,-0.980924] [0,0.983597,-0.180378] [0.997282,-0.0132892,-0.0724657] [0.114549,0.046205,1.48057]), \
			(matrix3 [0.0187119,-0.0934365,-0.995449] [0,0.995624,-0.0934528] [0.999825,0.00174879,0.01863] [0.370913,0.046205,1.46186]), \
			(matrix3 [1,0,0] [0,0.984885,-0.17321] [0,0.17321,0.984885] [0,-0.00621914,1.55505]), \
			(matrix3 [1,0,0] [0,0.0225533,-0.999746] [0,0.999746,0.0225533] [0,0.107581,1.69746]), \
			(matrix3 [1,0,0] [0,0.0225533,-0.999746] [0,0.999746,0.0225533] [0,0.136552,1.69746]), \
			(matrix3 [1,0,0] [0,-0.0156453,-0.999878] [0,0.999878,-0.0156453] [0,0.296429,1.7016]), \
			(matrix3 [0.0187119,0,-0.999825] [0,1,0] [0.999825,0,0.0187119] [0.601963,0.0426722,1.46186]), \
			(matrix3 [-0.0671293,-0.00563515,-0.997728] [0.300064,0.953576,-0.0255747] [0.951554,-0.301099,-0.062322] [0.618918,0.00915422,1.45781]), \
			(matrix3 [0.0187118,0.0934364,0.995449] [3.42727e-007,0.995624,-0.0934527] [-0.999825,0.00174901,0.0186299] [-0.370913,0.046205,1.46186]), \
			(matrix3 [0.0187117,0,0.999825] [-1.75346e-007,1,0] [-0.999825,-1.74314e-007,0.0187117] [-0.601963,0.0426722,1.46186]), \
			(matrix3 [-0.067129,0.00563534,0.997728] [-0.300065,0.953576,-0.0255749] [-0.951554,-0.3011,-0.0623216] [-0.618918,0.00915425,1.45781]), \
			(matrix3 [-0.0736745,0.179888,0.980924] [-3.27826e-007,0.983597,-0.180378] [-0.997282,-0.0132896,-0.0724659] [-0.114549,0.046205,1.48057]), \
			(matrix3 [0.998291,-0.00402223,0.0583084] [0,0.997629,0.0688201] [-0.058447,-0.0687025,0.995924] [-0.0793198,0.0728021,0.0888846]), \
			(matrix3 [0.99964,0.00607574,-0.0261353] [-1.20141e-007,0.974027,0.22643] [0.0268322,-0.226348,0.973677] [-0.0932134,0.0539341,0.414269]), \
			(matrix3 [0.998343,0.000971044,0.0575306] [0.000729447,0.999564,-0.0295297] [-0.0575341,0.0295227,0.997907] [-0.08057,0.0132125,0.607289]), \
			(matrix3 [1,-3.01992e-007,0] [3.01992e-007,1,0] [0,0,1] [-0.0793198,-0.010345,0.0289477]), \
			(matrix3 [0.906134,-0.371979,0.201379] [-0.403865,-0.619279,0.67334] [-0.125758,-0.691467,-0.711378] [-0.0411788,0.028349,1.48025])
			)
		mscale=metric_scale*rescale
		undo off (
			with redraw off (
				msh=box length:(boxArray[1][1]*mscale) width:(boxArray[1][2]*mscale) height:(boxArray[1][3]*mscale)
				msh.transform=boxRArray[1];msh.position=(msh.position*mscale)
				msh.wirecolor = color 234 212 193
				convertTo msh TriMeshGeometry
				for x = 2 to boxArray.count do (
					obj=box length:(boxArray[x][1]*mscale) width:(boxArray[x][2]*mscale) height:(boxArray[x][3]*mscale)
					obj.transform=boxRArray[x];obj.position=(obj.position*mscale)
					convertTo obj TriMeshGeometry
					attach msh obj
					)
				msh.name="Lara Mannequin"
				)
			)
		)
	on btn3 pressed do(createDialog AboutBox)
	on appGUI close do (
		try(destroyDialog appGUI)catch();try(destroyDialog exoptions)catch()
		try(destroyDialog expPath)catch();try(destroyDialog impPath)catch()
		try(destroyDialog texbox)catch();try(destroyDialog AboutBox)catch()
		try(destroyDialog asciiedit)catch();try(MemStreamMgr.close f)catch()
		)
	)
rollout rg_mat_editor_prompt "Untitled" width:320 height:136 (
	label lbl1_rgp "Shaders have been set automatically and can be edited in the Render Group Material Editor." pos:[16,16] width:280 height:40 align:#left
	label lbl2_rgp "Open model in Render Group Material Editor?" pos:[16,56] width:280 height:19 align:#left
	button btn1_rgp "Yes" pos:[8,96] width:120 height:32 align:#left
	button btn2_rgp "No" pos:[200,96] width:112 height:32 align:#left
	groupBox grp1_rgp "Warning" pos:[8,0] width:304 height:88 align:#left
	on btn1_rgp pressed do (destroydialog rg_mat_editor_prompt;true)
	on btn2_rgp pressed do (destroydialog rg_mat_editor_prompt;false)
	on rg_mat_editor_prompt close do false
	)
rollout AboutBox "About..." width:363 height:229 (
	listBox ab_edt1 "" pos:[8,81] width:346 height:10 items:changelog
	label ab_bl1 "This started as practice to I/O writting in maxscript\n\nif you have problems be sure to PM me on the forums\nOr you can email me at:mario_kart64n@hotmail.com\n" pos:[18,12] width:329 height:61
	)
rollout exoptions "Extra Options" width:290 height:333 (
	groupBox option_grp3 "Scalable Options" pos:[10,185] width:270 height:64
	groupBox option_grp1 "Import Options" pos:[10,8] width:270 height:110
	groupBox option_grp2 "Export Options" pos:[10,122] width:270 height:61
	groupBox option_grp4 "Utilities" pos:[10,251] width:270 height:46
	checkbox op_chk11 "Optimize Faces" pos:[28,141] width:107 height:15 checked:mshOptimise
	checkbox opt_chk_save "Save Settings" pos:[184,303] width:97 height:17 checked:useINI
	button op_btn_close "Close" pos:[10,304] width:95 height:17
	editText op_edt33 "" pos:[177,204] width:50 height:16 enabled:bsenable text:(boneSize as string)
	label op_lbl33 "Bone Size" pos:[127,205] width:51 height:16
	editText op_edt34 "" pos:[177,224] width:50 height:16 text:(boneLimit as string)
	label op_lbl34 "Bone Limit" pos:[127,225] width:51 height:16
	editText op_edt31 "" pos:[72,202] width:50 height:16 text:(metric_scale as string)
	label op_lbl31 "IN<>CM" pos:[22,203] width:51 height:16
	editText op_edt32 "" pos:[72,222] width:50 height:16 text:(imperial_scale as string)
	label op_lbl32 "CM<>IN" pos:[22,223] width:51 height:16
	checkbox op_chk31 "" pos:[230,205] width:17 height:16 checked:guessBone
	label op_lbl35 "Auto" pos:[247,205] width:26 height:16
	checkbox op_chk32 "" pos:[231,224] width:16 height:16 checked:autoMeshBreak
	label op_lbl36 "Limit" pos:[248,224] width:26 height:16
	checkbox op_chk2 "Materials" pos:[28,43] width:107 height:15 checked:matON
	checkbox op_chk3 "Skeleton" pos:[28,60] width:107 height:15 checked:boneON
	checkbox op_chk4 "Weights" pos:[28,77] width:107 height:15 checked:skinON
	checkbox op_chk1 "Geometry" pos:[28,26] width:107 height:15 checked:meshON
	checkbox op_chk5 "Clear Scene" pos:[156,26] width:107 height:15 checked:clearscene
	checkbox op_chk6 "Reorientate Bones" pos:[156,43] width:107 height:15 checked:orientate
	checkbox op_chk7 "BoneOn Disabled" pos:[156,60] width:107 height:15 checked:boneEnable
	checkbox op_chk8 "Show Links" pos:[156,77] width:107 height:15 checked:boneLinks
	checkbox op_chk_combine_mats "Merge Materials" pos:[156,97] width:107 height:15 checked:optMats
	checkbox op_chk13 "Names From Mesh" pos:[156,139] width:107 height:15 checked:matNames
	checkbox op_chk_unicode "Unicode" pos:[156,138] width:107 height:15 checked:enable_export_mode2
	checkbox op_chk12 "Normalize Normals" pos:[28,158] width:107 height:15 checked:normVN
	button op_btn21 "SwapWeights" pos:[24,269] width:80 height:17
	button op_btn22 "Review Ascii" pos:[110,269] width:80 height:17
	
	on op_edt31 entered txt4 do (if (txt4 as float)!=undefined do metric_scale=(txt4 as float))
	on op_edt32 entered txt4 do (if (txt4 as float)!=undefined do imperial_scale=(txt4 as float))
	on op_edt34 entered txt4 do (if (txt4 as float)!=undefined do boneLimit=(txt4 as float))
	on op_chk32 changed theState do (autoMeshBreak=theState)
	on op_chk13 changed theState do (matNames=theState)
	on op_chk5 changed theState do (clearscene=theState)
	on op_chk1 changed theState do (meshON=theState)
	on op_chk2 changed theState do (matON=theState)
	on op_chk3 changed theState do (boneON=theState)
	on op_chk4 changed theState do (skinON=theState)
	on op_chk12 changed theState do (normVN=theState)
	on op_chk6 changed theState do (orientate=theState)
	on op_chk7 changed theState do (boneEnable=theState)
	on op_chk8 changed theState do (boneLinks=theState)
	on op_chk_combine_mats changed theState do (optMats=theState)
	on opt_chk_save changed theState do (useINI=theState)
	on op_chk_unicode changed theState do (enable_export_mode2=theState)
	on op_chk11 changed theState do (mshOptimise=theState)
	on op_chk31 changed theState do (
		if theState==false do (
			op_edt33.enabled=true
			bsenable=true
			guessBone=false
			)
		if theState==true do(
			op_edt33.enabled=false
			bsenable=false
			guessBone=true
			)
		)
	on exoptions close do (
		if opt_chk_save.checked == true then (
			format_ini iniFile
			writeINI iniFile "General" "enable" useINI
			writeINI iniFile "General" "in_scale" metric_scale
			writeINI iniFile "General" "out_scale" imperial_scale
			writeINI iniFile "General" "bone_limit" boneLimit
			writeINI iniFile "General" "bone_limit_auto_break" autoMeshBreak
			writeINI iniFile "General" "bone_size" boneSize
			writeINI iniFile "General" "clear_scene" clearscene
			writeINI iniFile "Import" "mesh" meshON
			writeINI iniFile "Import" "mats" matON
			writeINI iniFile "Import" "bones" boneON
			writeINI iniFile "Import" "skin" skinON
			writeINI iniFile "Import" "reorientate_bones" orientate
			writeINI iniFile "Import" "showlinks" boneLinks
			writeINI iniFile "Import" "boneon_disalbed" boneEnable
			writeINI iniFile "Export" "optimize_output" mshOptimise
			writeINI iniFile "Export" "name_by_mat" matNames
			writeINI iniFile "Export" "enable_export_mode2" enable_export_mode2
			)
		else (
			format_ini iniFile
			writeINI iniFile "General" "enable" useINI
			)
		)
	on op_edt33 entered txt4 do(
		if (txt4 as float)!=undefined do (
			boneSize=(txt4 as float)
			)
		)
	-- on op_btn22 pressed do
	on op_btn21 pressed do (
		objArray=#()
		weights=#()
		vertids=#()
		boneids=#()
		
		for o in selection where findItem #(Editable_Mesh,Editable_Poly,PolyMeshObject) (classof o) > 0 do append objArray o
		for o in selection where findItem #(BoneGeometry,Biped_Object,Dummy,IK_Chain_Object,Point) (classof o) > 0 do append objArray o
		
		if objArray.count == 3 then (
			SkinMod=undefined
			BoneOne=undefined
			BoneTwo=undefined
			for o in objArray[1].modifiers where classof o==Skin do SkinMod=o
			if SkinMod!=undefined then (
				max modify mode;select objArray[1]
				modPanel.setCurrentObject skinMod
				for i = 1 to (skinOps.GetNumberBones SkinMod) do (
					if (skinOps.GetBoneName SkinMod i 1)==objArray[2].name do BoneOne=i
					if (skinOps.GetBoneName SkinMod i 1)==objArray[3].name do BoneTwo=i
					)
				if BoneOne!=undefined AND BoneTwo!=undefined then (
					for i = 1 to objArray[1].numverts do (
						idx=false
						wv=#()
						bi=#()
						for x = 1 to (skinOps.GetVertexWeightCount skinMod i) do (
							bone_weight = skinops.getvertexweight skinMod i x
							bone_index = skinOps.GetVertexWeightBoneID skinMod i x
							if bone_index==BoneOne then (
								idx=true;append wv bone_weight;append bi BoneTwo
								)
							else (
								if bone_index==BoneTwo then (
									idx=true
									append wv bone_weight;append bi BoneOne
									)
								else(append wv bone_weight;append bi bone_index)
								)
							)
						if idx==true do(append weights wv;append boneids bi;append vertids i)
						)
					if weights.count!=0 do (
						for i = 1 to vertids.count do (
							skinOps.ReplaceVertexWeights SkinMod vertids[i] boneids[i] weights[i]
							)
						)
					)
				else(MessageBox "ERROR!!\n\nSelect Bones Were Not Found In Selected Mesh's Skin Modifier..")
				)
			else(MessageBox "ERROR!!\n\nA Skin Modifier Was Not Found!")
			)
		else(MessageBox "ERROR!!\n\nPlease Select 3 Objects\n- 1 Mesh\n- 2 Bones")
		)
	on op_btn_close pressed do(
		destroydialog exoptions
		)
	)
rollout expPath "Save to Fixed Path" width:303 height:69 ( --115
	editText edt2b_1 "Path: " pos:[9,8] width:282 height:16 text:ssource
	button btn2b_1 "Browse" pos:[225,29] width:63 height:21
	checkbox chk2b_1 "Use Fixed Path" pos:[48,27] width:126 height:20 checked:expFixed
	button btn2b_2 "Edit" pos:[24,73] width:63 height:21 visible:false
	button btn2b_3 "CleanUp" pos:[98,73] width:63 height:21 visible:false
	button btn2b_4 "Collect Textures" pos:[173,73] width:108 height:21 visible:false
	groupBox grp2b_1	"Extra Options" pos:[10,54] width:284 height:51 visible:false
	on chk2b_1 changed theState do expFixed=theState
	on edt2b_1 entered txt do ssource=txt
	on btn2b_1 pressed do (
		ssource = getSaveFileName \
		caption:"Save XnaLara ASCII Model File" \
		types: "Text(*.ascii)|*.ASCII|All files (*.*)|*.*|"
		if ssource!=undefined do edt2b_1.text=ssource
		)
	on btn2b_2 pressed do (
-- 		infoBuffer = (mesh_data mName:#() mVert:#() mFace:#() mUV:#() mTex:#())
-- 		boneBuffer = (bone_data bName:#() parent:#() child:#() position:#())
-- 		vertBuffer = (vert_data vPos:#() vNorm:#() vColour:#() vBone:#() vWeight:#())
-- 		uvwBuffer=#()
-- 		faceBuffer=#()
-- 		texBuffer=#()
-- 		if ssource!=""then (
-- 			testArray=#("1/2", "1/4", "1/8", "1/16")
-- 			append testArray "hello"
-- 			createDialog asciiedit
-- 			)
-- 		else(
-- 			MessageBox "Please Select a Ascii File First"
-- 			)
		)
	on btn2b_3 pressed do(MessageBox "Feature Not Implemented Yet")
	on btn2b_4 pressed do(MessageBox "Feature Not Implemented Yet")
	)
rollout impPath "Open from Fixed Path" width:303 height:69 (
	editText edt1b_1 "Path: " pos:[9,8] width:282 height:16 text:fsource
	button btn1b_1 "Browse" pos:[225,29] width:63 height:21
	checkbox chk1b_1 "Use Fixed Path" pos:[48,27] width:126 height:20 checked:impFixed
	on chk1b_1 changed theState do impFixed=theState
	on edt1b_1 entered txt do fsource=txt
	on btn1b_1 pressed do (
		fsource = GetOpenFileName \
			caption:"Select Xnalara File" \
			types: (
				"All Supported Formats (*.mesh, *xps, *.ascii)|*.MESH;*.XPS;*.ASCII|" + \
				"Binary File(*.mesh)|*.MESH|" + \
				"Text File(*.ascii)|*.ASCII|" + \
				"XNA Posing Studio (*.xps)|" + \	--XNAaraL's Plagiarism Studios
				"*.XPS|Pose File(*.pose)|*.POSE|" + \
				"All files (*.*)|*.*|"
				)
		if fsource!=undefined do edt1b_1.text=fsource
		)
	)
-- rollout asciiedit
rollout texbox "Texture Selector" width:271 height:82 (
	groupBox grp1tex "Texture Name" pos:[9,7] width:255 height:66
	editText edt1tex "" pos:[14,23] width:241 height:16 text:""
	button btn1tex "Close" pos:[73,44] width:107 height:21
	on texbox open do (
		if tx_aray_01[obj]!="" do(
		edt1tex.text = tx_aray_01[obj])
		)
	on edt1tex changed txt do (
		tx_ctrl_01.caption = txt;tx_aray_01[obj]=txt
		if linking==true do (
			for x = 1 to linkArray[page].count do (
				tx_aray_01[(linkArray[page][x])]=txt
				)
			)
		)
	on texbox lbuttondblclk val do (
		txt = GetOpenFileName \
		caption:"Open Texture File" \
		types: "TGA (*.tga)|*.tga|DDS (*.dds)|*.dds|PNG (*.png)|*.png|All Files (*.bmp)|*.bmp|All Files (*.*)|*.*|"
		if txt!= undefined do (
			edt1tex.text = filenameFromPath txt
			tx_aray_01[obj] = edt1tex.text
			tx_ctrl_01.caption = edt1tex.text
			if linking==true do(
				for x = 1 to linkArray[page].count do (
					tx_aray_01[(linkArray[page][x])] = edt1tex.text
					)
				)
			)
		)
	on btn1tex pressed do (
		destroydialog texbox
		)
	)
createDialog appGUI

