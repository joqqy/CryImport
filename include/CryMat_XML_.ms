
struct read_xml
(
	str_xmlStruct,
	report 					= false,
	
	xmldoc,
	docEle,
	rootName 				= undefined,
	
	rootChildrenIDX 		= 0,
	rootChildrenIDX_2 	= 0,
	
	rootIDX 					= undefined,
	depth 					= 0,
	idx 						= 0,
	depthArr 				= #(),
	numRecurse 			= 0,
	
	_xml_template 		= #(),
	_xml 						= #(),	
	
	attribName,
	attribValue,
	
	attribN,
	attribV,
	
	-------------------Fix bit for GenMask and flags -- Maxscript messes with the bits for the (uint64) ULL, we fix that with these functions ------------------------
	fn set_GenMask_64bits
									&GenMask: =
	(
		if GenMask != undefined then
		(
			if isKindOF GenMask string then
			(
				bitArr=#()
				for i=1 to GenMask.count do
				(
					_int = (("0x" + GenMask[i]) as integer)
					
					x=4
					while x > 0 do
					(
						insertItem (bit.get _int x) bitArr 1
						x-=1
					)
				)
				-- for i in bitArr do print i
				GenMask64 = ("0x" + GenMask) as integer64

				i=bitArr.count
				while i > 0 do
				(
					GenMask64 = bit.set GenMask64 i bitArr[i]
					i-=1
				)
				
				return GenMask64;
			)
		)
		else
		(	
			return 0;
		)
	),
	
	fn set_Flag_64bits \
								&Flag: =
	(
		if Flag != undefined then
		(
			if isKindOF Flag string then
			(
				Flag = Substring Flag 3 Flag.count
		
				bitArr=#()
				for i=1 to Flag.count do
				(
					_int = (Flag[i] as integer)
					
					x=4
					while x > 0 do
					(
						insertItem (bit.get _int x) bitArr 1
						x-=1
					)
				)
				-- for i in bitArr do print i
				Flag64 = Flag as integer64

				i=bitArr.count
				while i > 0 do
				(
					Flag64 = bit.set Flag64 i bitArr[i]
					i-=1
				)
				
				return Flag64;
			)
		)
		else
		(
			return 0;
		)
	),
	
	fn get_MtlFlags \
							&int_MtlFlags: \
							&inst_EMaterialFlags: \
							&noDraw: =
	(
		--array to fill
		arr = #()
		
		if inst_EMaterialFlags == unsupplied then
		(
			--Enum struct instance
			inst_EMaterialFlags = EMaterialFlags()
		)
		
		--noDraw == false
		
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_BLEND_TERRAIN then
		(
			_NAME 				= "MTL_FLAG_BLEND_TERRAIN"
			EMaterialFlag 		= inst_EMaterialFlags.MTL_FLAG_BLEND_TERRAIN
			int_MtlFlags 		= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_DELETE_PENDING then
		(
			_NAME 				= "MTL_FLAG_DELETE_PENDING"
			EMaterialFlag 		= inst_EMaterialFlags.MTL_FLAG_DELETE_PENDING
			int_MtlFlags 		= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_CONSOLE_MAT then
		(
			_NAME 				= "MTL_FLAG_CONSOLE_MAT"
			EMaterialFlag 		= inst_EMaterialFlags.MTL_FLAG_CONSOLE_MAT
			int_MtlFlags 		= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_REQUIRE_NEAREST_CUBEMAP then
		(
			_NAME 				= "MTL_FLAG_REQUIRE_NEAREST_CUBEMAP"
			EMaterialFlag 		= inst_EMaterialFlags.MTL_FLAG_REQUIRE_NEAREST_CUBEMAP
			int_MtlFlags 		= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_RAYCAST_PROXY then
		(
			_NAME 				= "MTL_FLAG_RAYCAST_PROXY"
			EMaterialFlag 		= inst_EMaterialFlags.MTL_FLAG_RAYCAST_PROXY
			int_MtlFlags 		= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		if int_MtlFlags >= inst_EMaterialFlags.MTL_64BIT_SHADERGENMASK then
		(
			_NAME 			= "MTL_64BIT_SHADERGENMASK"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_64BIT_SHADERGENMASK
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)		
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_UIMATERIAL then
		(
			_NAME 			= "MTL_FLAG_UIMATERIAL"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_UIMATERIAL
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_HIDEONBREAK then
		(
			_NAME 			= "MTL_FLAG_HIDEONBREAK"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_HIDEONBREAK
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_NON_REMOVABLE then
		(
			_NAME 			= "MTL_FLAG_NON_REMOVABLE"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_NON_REMOVABLE
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_REQUIRE_FORWARD_RENDERING then
		(
			_NAME 			= "MTL_FLAG_REQUIRE_FORWARD_RENDERING"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_REQUIRE_FORWARD_RENDERING
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_SCATTER then
		(
			_NAME 			= "MTL_FLAG_SCATTER"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_SCATTER
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_COLLISION_PROXY then
		(
			_NAME 			= "MTL_FLAG_COLLISION_PROXY"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_COLLISION_PROXY
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_NOTINSTANCED then
		(
			_NAME 			= "MTL_FLAG_NOTINSTANCED"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_NOTINSTANCED
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_NOPREVIEW then
		(
			_NAME 			= "MTL_FLAG_NOPREVIEW"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_NOPREVIEW
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_NODRAW then
		(
			_NAME 			= "MTL_FLAG_NODRAW"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_NODRAW
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
			noDraw = true
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_NOPHYSICALIZE then
		(
			_NAME 			= "MTL_FLAG_NOPHYSICALIZE"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_NOPHYSICALIZE
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_MULTI_SUBMTL then
		(
			_NAME 			= "MTL_FLAG_MULTI_SUBMTL"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_MULTI_SUBMTL
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_PURE_CHILD then
		(
			_NAME 			= "MTL_FLAG_PURE_CHILD"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_PURE_CHILD
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_ALWAYS_USED then
		(
			_NAME 			= "MTL_FLAG_ALWAYS_USED"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_ALWAYS_USED
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_NOSHADOW then
		(
			_NAME 			= "MTL_FLAG_NOSHADOW"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_NOSHADOW
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_LIGHTING then
		(
			_NAME 			= "MTL_FLAG_LIGHTING"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_LIGHTING
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_DETAIL_DECAL then
		(
			_NAME 			= "MTL_FLAG_DETAIL_DECAL"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_DETAIL_DECAL
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_ADDITIVE then
		(
			_NAME 			= "MTL_FLAG_ADDITIVE"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_ADDITIVE
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_2SIDED then
		(			
			_NAME 			= "MTL_FLAG_2SIDED"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_2SIDED
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)	
		if int_MtlFlags >= inst_EMaterialFlags.MTL_FLAG_WIRE then
		(
			_NAME 			= "MTL_FLAG_WIRE"
			EMaterialFlag 	= inst_EMaterialFlags.MTL_FLAG_WIRE
			int_MtlFlags 	= int_MtlFlags - EMaterialFlag
			------------------------------------------------
			Append arr #(EMaterialFlag, _NAME)
		)
		
		return arr;
	),
	
	fn GenMask_2_MaskGen \
										&GenMask: \
										&inst_MaskGenFlags: =
	(
		--array to fill
		arr = #()
		
		if inst_MaskGenFlags == unsupplied then
		(
			--Enum struct instance
			inst_MaskGenFlags = MaskGenFlags()
		)
		
		GenMaskINT =set_GenMask_64bits \
														GenMask:&GenMask		
		
		--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		--From here, according to (ShaderCore.cpp 745) we must use UInt64 ULL (so we use our bit fix function to get the correct type)
		--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 		see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\CryCommon\IMaterial.h
-- 		see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\RenderDll\Common\Shaders\ShaderCore.cpp
-- 		see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\CryCommon\IShader.h
-- 		see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\CryCommon\MaterialHelpers.cpp
-- 		see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\RenderDll\XRenderD3D9\D3DHWShaderCompiling.cpp
-- 		see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\RenderDll\Common\Shaders\ShaderParse.cpp
-- 		see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\RenderDll\Common\Renderer.h
-- 		in Cryengine 5 source code
-- 		//////////////////////////////////////////////////////////////////////////
-- 		// Description:
-- 		//    IMaterial is an interface to the material object, SShaderItem host which is a combination of IShader and SShaderInputResources.
-- 		//    Material bind together rendering algorithm (Shader) and resources needed to render this shader, textures, colors, etc...
-- 		//    All materials except for pure sub material childs have a unique name which directly represent .mtl file on disk.
-- 		//    Ex: "Materials/Fire/Burn"
-- 		//    Materials can be created by Sandbox MaterialEditor.
-- 		//////////////////////////////////////////////////////////////////////////	
		min = 1		
		if GenMaskINT != undefined then
		(
			if GenMaskINT >= (set_Flag_64bits Flag:&inst_MaskGenFlags.WRINKLE_BLENDING[1]) then
			(	
				if GenMask != undefined then
				(				
					---------------------------------------------------------------
					if GenMask.count > min then
					(
						GenMask = substring GenMask 2 GenMask.count
					)
					GenMaskINT  		= set_GenMask_64bits \
																			GenMask:&GenMask
					---------------------------------------------------------------
					Append arr #(inst_MaskGenFlags.WRINKLE_BLENDING[1], inst_MaskGenFlags.WRINKLE_BLENDING[2])
				)
			)
			else
			(
				if GenMask != undefined then
				(	
					---------------------------------------------------------------
					if GenMask.count > min then
					(
						GenMask = substring GenMask 2 GenMask.count --strip the first char
					)
					GenMaskINT  		= set_GenMask_64bits \
																			GenMask:&GenMask
					---------------------------------------------------------------
				)
			) --we strip the first char due to precision limits in Maxscript
						
			
			--Now, with the first byte stripped, we can use integer64 comparisons
			if GenMaskINT >= (set_Flag_64bits Flag:&inst_MaskGenFlags.WIND_BENDING[1]) then
			(
				GenMaskINT = GenMaskINT - (set_Flag_64bits Flag:&inst_MaskGenFlags.WIND_BENDING[1])
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.WIND_BENDING[1], inst_MaskGenFlags.WIND_BENDING[2])
			)
			
			if GenMaskINT >= (set_Flag_64bits Flag:&inst_MaskGenFlags.VERTCOLORS[1]) then
			(
				GenMaskINT = GenMaskINT - (set_Flag_64bits Flag:&inst_MaskGenFlags.VERTCOLORS[1])
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.VERTCOLORS[1], inst_MaskGenFlags.VERTCOLORS[2])
			)
			
			if GenMaskINT >= (set_Flag_64bits Flag:&inst_MaskGenFlags.TWO_SIDED_SORTING[1]) then
			(
				GenMaskINT = GenMaskINT - (set_Flag_64bits Flag:&inst_MaskGenFlags.TWO_SIDED_SORTING[1])
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.TWO_SIDED_SORTING[1], inst_MaskGenFlags.TWO_SIDED_SORTING[2])
			)
			
			if GenMaskINT >= (set_Flag_64bits Flag:&inst_MaskGenFlags.TERRAINHEIGHTADAPTION[1]) then
			(
				GenMaskINT = GenMaskINT - (set_Flag_64bits Flag:&inst_MaskGenFlags.TERRAINHEIGHTADAPTION[1])
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.TERRAINHEIGHTADAPTION[1], inst_MaskGenFlags.TERRAINHEIGHTADAPTION[2])
			)
			
			if GenMaskINT >= (set_Flag_64bits Flag:&inst_MaskGenFlags.TEMP_VEGETATION[1]) then
			(
				GenMaskINT = GenMaskINT - (set_Flag_64bits Flag:&inst_MaskGenFlags.TEMP_VEGETATION[1])
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.TEMP_VEGETATION[1], inst_MaskGenFlags.TEMP_VEGETATION[2])
			)
			
			if GenMaskINT >= (set_Flag_64bits Flag:&inst_MaskGenFlags.TEMP_TERRAIN[1]) then
			(
				GenMaskINT = GenMaskINT - (set_Flag_64bits Flag:&inst_MaskGenFlags.TEMP_TERRAIN[1])
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.TEMP_TERRAIN[1], inst_MaskGenFlags.TEMP_TERRAIN[2])
			)
			
			
			
			--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			--From here, the Cryengine source code (ShaderCore.cpp 745) switches from UInt64 ULL to UInt64 - so we do too
			--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			if GenMaskINT >= (inst_MaskGenFlags.SPECULARPOW_GLOSSALPHA[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.SPECULARPOW_GLOSSALPHA[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.SPECULARPOW_GLOSSALPHA[1], inst_MaskGenFlags.SPECULARPOW_GLOSSALPHA[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.RIM_LIGHTING[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.RIM_LIGHTING[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.RIM_LIGHTING[1], inst_MaskGenFlags.RIM_LIGHTING[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.REFRACTION_MAP[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.REFRACTION_MAP[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.REFRACTION_MAP[1], inst_MaskGenFlags.REFRACTION_MAP[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.REALTIME_MIRROR_REFLECTION[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.REALTIME_MIRROR_REFLECTION[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.REALTIME_MIRROR_REFLECTION[1], inst_MaskGenFlags.REALTIME_MIRROR_REFLECTION[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.PARALLAX_OCCLUSION_MAPPING[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.PARALLAX_OCCLUSION_MAPPING[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.PARALLAX_OCCLUSION_MAPPING[1], inst_MaskGenFlags.PARALLAX_OCCLUSION_MAPPING[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.OFFSET_BUMP_MAPPING[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.OFFSET_BUMP_MAPPING[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.OFFSET_BUMP_MAPPING[1], inst_MaskGenFlags.OFFSET_BUMP_MAPPING[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.NANOSUIT_EFFECTS[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.NANOSUIT_EFFECTS[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.NANOSUIT_EFFECTS[1], inst_MaskGenFlags.NANOSUIT_EFFECTS[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.LEAVES[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.LEAVES[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.LEAVES[1], inst_MaskGenFlags.LEAVES[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.IRIS[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.IRIS[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.IRIS[1], inst_MaskGenFlags.IRIS[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.GRASS[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.GRASS[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.GRASS[1], inst_MaskGenFlags.GRASS[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.GRADIENT_COLORING[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.GRADIENT_COLORING[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.GRADIENT_COLORING[1], inst_MaskGenFlags.GRADIENT_COLORING[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.GLOSS_MAP[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.GLOSS_MAP[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.GLOSS_MAP[1], inst_MaskGenFlags.GLOSS_MAP[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.GLOSS_DIFFUSEALPHA[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.GLOSS_DIFFUSEALPHA[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.GLOSS_DIFFUSEALPHA[1], inst_MaskGenFlags.GLOSS_DIFFUSEALPHA[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.EYE_OVERLAY[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.EYE_OVERLAY[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.EYE_OVERLAY[1], inst_MaskGenFlags.EYE_OVERLAY[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.ENVIRONMENT_MAP[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.ENVIRONMENT_MAP[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.ENVIRONMENT_MAP[1], inst_MaskGenFlags.ENVIRONMENT_MAP[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.DISABLE_RAIN_PASS[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.DISABLE_RAIN_PASS[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.DISABLE_RAIN_PASS[1], inst_MaskGenFlags.DISABLE_RAIN_PASS[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.DETAIL_BUMP_MAPPING[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.DETAIL_BUMP_MAPPING[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.DETAIL_BUMP_MAPPING[1], inst_MaskGenFlags.DETAIL_BUMP_MAPPING[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.DETAIL_BENDING[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.DETAIL_BENDING[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.DETAIL_BENDING[1], inst_MaskGenFlags.DETAIL_BENDING[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.DECAL[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.DECAL[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.DECAL[1], inst_MaskGenFlags.DECAL[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.CUSTOM_SPECULAR[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.CUSTOM_SPECULAR[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.CUSTOM_SPECULAR[1], inst_MaskGenFlags.CUSTOM_SPECULAR[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.CHARACTER_DECAL[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.CHARACTER_DECAL[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.CHARACTER_DECAL[1], inst_MaskGenFlags.CHARACTER_DECAL[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.BUMP_DIFFUSE[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.BUMP_DIFFUSE[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.BUMP_DIFFUSE[1], inst_MaskGenFlags.BUMP_DIFFUSE[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.BILINEAR_FP16[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.BILINEAR_FP16[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.BILINEAR_FP16[1], inst_MaskGenFlags.BILINEAR_FP16[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.ANISO_SPECULAR[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.ANISO_SPECULAR[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.ANISO_SPECULAR[1], inst_MaskGenFlags.ANISO_SPECULAR[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.ALPHAMASK_DETAILMAP[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.ALPHAMASK_DETAILMAP[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.ALPHAMASK_DETAILMAP[1], inst_MaskGenFlags.ALPHAMASK_DETAILMAP[2])
			)
			
			if GenMaskINT >= (inst_MaskGenFlags.ALPHAGLOW[1] as Integer64) then
			(
				GenMaskINT = GenMaskINT - (inst_MaskGenFlags.ALPHAGLOW[1] as Integer64)
				--------------------------------------------------------------------------------------------------------------------------
				Append arr #(inst_MaskGenFlags.ALPHAGLOW[1], inst_MaskGenFlags.ALPHAGLOW[2])
			)
		)
		
		return arr;
	),
	
	--////////////////////////////////////// STORE ATTRIBS //////////////////////////////////////
	fn xmlB_storeAttribs_v3 \		
										&nodeType: \
										&matNodeCounter: \
										&attribName: \
										&attribVal: \
										&matNodeCounter_REF: \
										&g_xml_Parsed: \ --name should probably be changed to g_xml_parsed										
										&matNodeCounter_MAT: \
										&Attachment_node_counter: \
										&MaterialRef_node_counter: \
										&theMat: \
										&compositeMat: \
										&matIDX: =									

	(
		if nodeType != unsupplied then
		(
			if nodeType != undefined then
			(
				if iskindof nodeType string then
				(
					-------------- Material Attribs var declaration --------------
					local _Name_name 				= ""
					local _Name_						= ""
					
					local _NameRef_name 			= ""
					local _NameRef_					= ""
								
					local _Shader_name				= ""
					local _Shader_ 					= ""					
					
					local _MtlFlags_name			= ""
					local _MtlFlags_					= ""
					local _MtlFlags_arr 				= #()
								
					local _GenMask_name 			= ""
					local _GenMask_ 					= ""
					local _GenMask_arr 				= #()

					local _StringGenMask_name 	= ""
					local _StringGenMask_ 			= ""
							
					local _SurfaceType_name 	= ""
					local _SurfaceType_ 			= ""
								
					local _MatTemplate_name 	= ""
					local _MatTemplate_ 			= ""

					local _Diffuse_name 			= ""
					local _Diffuse_ 					= ""
								
					local _Specular_name 			= ""
					local _Specular_ 					= ""						
								
					local _Emissive_name 			= ""
					local _Emissive_ 					= ""
								
					local _Shininess_name 			= ""
					local _Shininess_ 				= ""
								
					local _Opacity_name			= ""
					local _Opacity_ 					= ""
								
					local _LayerAct_name 			= ""
					local _LayerAct_ 				= ""
					
					-------------- Texture Attribs var declaration --------------
					local _Map_name 				= ""
					local _Map_ 						= ""
								
					local _File_name  				= ""
					local _File_ 						= ""
									
					local _TexType_name  			= ""	
					local _TexType_ 					= ""
								
					local _IsTileU_name  			= ""
					local _IsTileU_ 					= ""
								
					local _IsTileV_name 			= ""
					local _IsTileV_					= ""
								
								
					-------------- publicParamsAttribs Attribs var declaration --------------
					local _BlendFalloff_name 				= ""
					local _BlendFalloff_ 						= ""
								
					local _BlendLayer2Tiling_name  		= ""
					local _BlendLayer2Tiling_ 				= ""
									
					local _SSSIndex_name  				= ""
					local _SSSIndex_ 						= ""
								
					local _BlendMaskTiling_name  		= ""
					local _BlendMaskTiling_ 				= ""
								
					local _BlendFactor_name 				= ""
					local _BlendFactor_						= ""
								
					local _BlendLayer2Specular_name 	= ""
					local _BlendLayer2Specular_			= ""
								
					local _IndirectColor_name 			= ""
					local _IndirectColor_					= ""
					
					
					local inst_matParams					= matParams()
					local inst_materialAttribs 				= materialAttribs()
					local inst_textureAttribs 				= textureAttribs()
					local inst_publicParamsAttribs 		= publicParamsAttribs()
					local inst_MaterialRefAttribs			= MaterialRefAttribs()

					--//////////////////////////////////////////////////////////////////////////////////////////////
					--///////////////////////////// First we store all the needed attribs //////////////////////////////
					--//////////////////////////////////////////////////////////////////////////////////////////////
					
					local entered_Material 				= false
					local entered_Textures 			= false
					local entered_Texture 				= false
					local entered_TexMod				= false
					local entered_PublicParams 		= false
					local entered_MaterialRef			= false
					
					--Report
-- 					format "attribVal: %\n" attribVal
					
-- 					if 	(stricmp (nodeType as string) "Material") == 0 then 
					if 	(stricmp (nodeType as string) "Material") == 0 OR \
						(stricmp (nodeType as string) "MaterialRef") == 0 then
					(
						entered_Material 											= true
						entered_MaterialRef										= true
						inst_materialAttribs.nTagString 						= nodeType
						inst_materialAttribs.matNodeCounter 				= matNodeCounter
						inst_materialAttribs.MaterialRef_node_counter 	= MaterialRef_node_counter
						inst_materialAttribs.matNodeCounter_REF 		= matNodeCounter_REF
						inst_materialAttribs.matNodeCounter_MAT		= matNodeCounter_MAT
						
						----------------------------- Store Material Attributes -----------------------------
						case of
						(
							(stricmp attribName "Name" == 0):
							(
								_Name_name							= attribName
								_Name_									= attribVal	
								inst_materialAttribs._Name_ 		= #(attribName, attribVal)
							)
							(stricmp attribName "Shader" == 0):
							(
								_Shader_name							= attribName
								_Shader_								= attribVal
								inst_materialAttribs._Shader_ 	= #(attribName, attribVal)
							)				
							(stricmp attribName "MtlFlags" == 0):
							(
								_MtlFlags_name 						= attribName
								_MtlFlags_								= attribVal
								
								inst_EMaterialFlags 					= EMaterialFlags()
								
								if int_MtlFlags != undefined then
								(
									int_MtlFlags 							= (_MtlFlags_ as integer)
									arr_MtlFlags 							= get_MtlFlags \
																										int_MtlFlags:				&int_MtlFlags \
																										inst_EMaterialFlags:		&inst_EMaterialFlags \
																										noDraw:						&noDraw		
								)
								
								if _MtlFlags_ != undefined then
								(
									if ::g_xmlB_Report_v2 then
									(
										format "\n arr_MtlFlags:\n"
										print arr_MtlFlags
									)
									
									inst_materialAttribs._MtlFlags_arr			= arr_MtlFlags
									inst_materialAttribs._MtlFlags_ 				= #(attribName, attribVal)
								)
							)
							(stricmp attribName "GenMask" == 0):
							(
								_GenMask_name 						= attribName
								_GenMask_								= attribVal
								
								inst_MaskGenFlags 					= MaskGenFlags()
								arr_MaskGen 							= GenMask_2_MaskGen \
																											GenMask:				&_GenMask_ \
																											inst_MaskGenFlags:	&inst_MaskGenFlags
								if _GenMask_ != undefined then
								(
									if ::g_xmlB_Report_v2 then
									(
										format "\n arr_MaskGen:\n"
										print arr_MaskGen
									)
									
									inst_materialAttribs._GenMask_ 			= #(attribName, attribVal)
									inst_materialAttribs._GenMask_arr 		= arr_MaskGen
								)
							)
							(stricmp attribName "StringGenMask" == 0):
							(
								_StringGenMask_name							= attribName
								_StringGenMask_									= attribVal	
								inst_materialAttribs._StringGenMask_ 		= #(attribName, attribVal)
								
								if ::g_xmlB_Report_v2 then
								(
									format "\n _StringGenMask_:\n"
									print _StringGenMask_
								)
							)
							(stricmp attribName "SurfaceType" == 0):
							(
								_SurfaceType_name								= attribName
								_SurfaceType_									= attribVal	
								inst_materialAttribs._SurfaceType_ 		= #(attribName, attribVal)
							)
							(stricmp attribName "MatTemplate" == 0):
							(
								_MatTemplate_name								= attribName
								_MatTemplate_									= attribVal	
								inst_materialAttribs._MatTemplate_ 		= #(attribName, attribVal)
							)
							(stricmp attribName "Diffuse" == 0):
							(
								_Diffuse_name										= attribName
								_Diffuse_											= attribVal	
								inst_materialAttribs._Diffuse_ 				= #(attribName, attribVal)
							)
							(stricmp attribName "Specular" == 0):
							(
								_Specular_name									= attribName
								_Specular_											= attribVal	
								inst_materialAttribs._Specular_ 				= #(attribName, attribVal)
							)
							(stricmp attribName "Emissive" == 0):
							(
								_Emissive_name									= attribName
								_Emissive_											= attribVal	
								inst_materialAttribs._Emissive_ 				= #(attribName, attribVal)
							)
							(stricmp attribName "Shininess" == 0):
							(
								_Shininess_name									= attribName
								_Shininess_											= attribVal	
								inst_materialAttribs._Shininess_ 				= #(attribName, attribVal)
							)
							(stricmp attribName "Opacity" == 0):
							(
								_Opacity_name									= attribName
								_Opacity_											= attribVal	
								inst_materialAttribs._Opacity_ 				= #(attribName, attribVal)
							)
							(stricmp attribName "LayerAct" == 0):
							(
								_LayerAct_name									= attribName
								_LayerAct_											= attribVal	
								inst_materialAttribs._LayerAct_ 				= #(attribName, attribVal)
							)
						)
					)
					/*
					else if (stricmp (nodeType as string) "MaterialRef") == 0 then
					(
						entered_MaterialRef 				= true
						inst_MaterialRefAttribs.nTagString = nodeType

						case of
						(
							--We get every Ref Material .mtl in here - every .mtl will be parsed later...
							(stricmp attribName "Name" == 0):
							(
								inst_MaterialRefAttribs.MaterialRef_node_counter 				= MaterialRef_node_counter
								inst_MaterialRefAttribs.matNodeCounter 							= matNodeCounter
								
								inst_MaterialRefAttribs.MaterialRef_Bool							= true ---extra
								inst_materialAttribs.MaterialRef_Bool								= true ---extra
								
								
								_NameRef_name															= attribName
								_NameRef_																	= attribVal
								inst_MaterialRefAttribs._NameRef_ 									= #(attribName, attribVal)
								
								
								--------------------------We check if there is indeed an .mtl file, and not just an empty MaterialRef-------------------------
								------------------------------------Build .mtl path------------------------------------
								local filePath 				= _NameRef_						
								
								check_4_mtl_suffix \
															filePath:		&filePath						
								
								build_complete_filePath \									
																attribVal:		&_NameRef_ \
																dirPath:			&::g_dirPath \
																filePath:			&filePath --Note this is a reference and will update the g_cryFile above
								-----------------------------------------------------------------------------------------								
								if doesfileexist filePath then --We found a valid .mtl file
								(
									inst_MaterialRefAttribs.MaterialRef_Bool							= true ---extra
								)			
								else
								(
									inst_MaterialRefAttribs.MaterialRef_Bool							= false ---extra
								)							
								----------------------------------------------------------------------------------------------------------------------------------------								
								
								
								if ::rollout_Report.chk_MaterialRef_Report.state then
								(
									format "########################## ### ## #  _NameRef_: %\n" 						_NameRef_
									format "########################## ### ## #  MaterialRef_node_counter: %\n" 	MaterialRef_node_counter
									
									print inst_MaterialRefAttribs
								)
							)
						)						
					)
					--*/
					else if (stricmp (nodeType as string) "Textures") == 0 then
					(						
						entered_Textures = true
						--not implemented
					)
					else if (stricmp (nodeType as string) "Texture") == 0 then
					(						
						entered_Texture = true
						
						case of
						(
							(stricmp attribName "Map" == 0):
							(
								_Map_name										= attribName
								_Map_												= attribVal	
								inst_textureAttribs._Map_ 						= #(attribName, attribVal)
							)
							(stricmp attribName "File" == 0):
							(
								_File_name											= attribName
								_File_												= attribVal	
								inst_textureAttribs._File_ 						= #(attribName, attribVal)
							)
							(stricmp attribName "TexType" == 0):
							(
								_TexType_name									= attribName
								_TexType_											= attribVal	
								inst_textureAttribs._TexType_ 				= #(attribName, attribVal)
							)
							(stricmp attribName "IsTileU" == 0):
							(
								_IsTileU_name										= attribName
								_IsTileU_											= attribVal	
								inst_textureAttribs._IsTileU_ 					= #(attribName, attribVal)
							)
							(stricmp attribName "IsTileV" == 0):
							(
								_IsTileV_name										= attribName
								_IsTileV_											= attribVal	
								inst_textureAttribs._IsTileV_ 					= #(attribName, attribVal)
							)
						)
					)
					else if (stricmp (nodeType as string) "TexMod") == 0 then
					(						
						entered_TexMod = true
						--not implemented
					)
					else if (stricmp (nodeType as string) "PublicParams") == 0 then
					(
						entered_PublicParams = true
						
						case of
						(
							(stricmp attribName "BlendFalloff" == 0):
							(
								_BlendFalloff_name												= attribName
								_BlendFalloff_														= attribVal	
								inst_publicParamsAttribs._BlendFalloff_ 					= #(attribName, attribVal)
							)
							(stricmp attribName "BlendLayer2Tiling" == 0):
							(
								_BlendLayer2Tiling_name										= attribName
								_BlendLayer2Tiling_												= attribVal	
								inst_publicParamsAttribs._BlendLayer2Tiling_ 			= #(attribName, attribVal)
							)
							(stricmp attribName "SSSIndex" == 0):
							(
								_SSSIndex_name													= attribName
								_SSSIndex_														= attribVal	
								inst_publicParamsAttribs._SSSIndex_ 						= #(attribName, attribVal)
							)
							(stricmp attribName "BlendMaskTiling" == 0):
							(
								_BlendMaskTiling_name											= attribName
								_BlendMaskTiling_												= attribVal	
								inst_publicParamsAttribs._BlendMaskTiling_ 				= #(attribName, attribVal)
							)
							(stricmp attribName "BlendFactor" == 0):
							(
								_BlendFactor_name												= attribName
								_BlendFactor_														= attribVal	
								inst_publicParamsAttribs._BlendFactor_ 					= #(attribName, attribVal)
							)
							(stricmp attribName "BlendLayer2Specular" == 0):
							(
								_BlendLayer2Specular_name									= attribName
								_BlendLayer2Specular_											= attribVal	
								inst_publicParamsAttribs._BlendLayer2Specular_ 		= #(attribName, attribVal)
							)
							(stricmp attribName "IndirectColor" == 0):
							(
								_IndirectColor_name												= attribName
								_IndirectColor_													= attribVal	
								inst_publicParamsAttribs._IndirectColor_ 					= #(attribName, attribVal)
							)
						)
					)
					
					--------------------------------------Store Counters -------------------------------------------
					if matNodeCounter_REF != unsupplied then
					(
						if matNodeCounter_REF != undefined then
						(							
							inst_MaterialRefAttribs.matNodeCounter_REF 		= matNodeCounter_REF
							inst_matParams.matNodeCounter_REF 					= matNodeCounter_REF
						)
					)
					
					inst_matParams.nTagString 								= nodeType
					inst_matParams.matIDX 									= matIDX
					inst_matParams.matNodeCounter 						= matNodeCounter
					inst_matParams.MaterialRef_node_counter 			= MaterialRef_node_counter
					inst_matParams.matNodeCounter_MAT					= matNodeCounter_MAT
					--////////////////////////////////////////////// End of struct filling ////////////////////////////////////////////////
					
					if entered_Material then
					(
						Append 		::g_xml_Parsed[2] inst_materialAttribs
					)
					
					else if entered_Textures then
					(		
						--not implemented
					)
					
					else if entered_Texture then
					(
						Append 		::g_xml_Parsed[3] inst_textureAttribs
					)
					
					else if entered_TexMod then
					(	
						--not implemented
					)
					
					else if entered_PublicParams then
					(
						Append 		::g_xml_Parsed[4] inst_publicParamsAttribs
					)
					
					else if entered_MaterialRef then
					(		
						Append 		::g_xml_Parsed[5] inst_MaterialRefAttribs							
					)
					
					entered_Material 				= false
					entered_Textures 			= false
					entered_Texture 				= false
					entered_TexMod				= false
					entered_PublicParams 		= false
					entered_MaterialRef			= false
				)
			)				
		)
	),
	
	fn CDF_storeAttribs_v3 \
										&type: \
										&g_xmlB_Parsed: \
										&matNodeCounter: \
										&Attachment_node_counter: \
										&Anim_Node_Counter: \
										&theMat: \
										&compositeMat: \
										&matIDX: \
										&nodeType: \
										&attribName: \
										&attribVal: =
	(		
		if ::g_xmlB_Report_v2 then
		(
			format		"\n ----***We are now inside CDF_storeAttribs_v3***----\n"
			format 		"nodeType: % \n" 							nodeType
			format 		"Attachment_node_counter: % \n" 		Attachment_node_counter
			format 		"Anim_Node_Counter: % \n" 				Anim_Node_Counter
		)
		
		if type != unsupplied then
		(
			if type != undefined then
			(
				if iskindof type string then
				(					
					if nodetype != unsupplied then
					(
						if nodetype != undefined then
						(
							if iskindof nodetype string then
							(
								if (stricmp (type as string) ".cdf") == 0 then
								(
									-------------- Material Attribs var declaration --------------
									local _File_name 					= ""
									local _File_							= ""
									
									local _Material_name 			= ""
									local _Material_ 					= ""
									
									local _Type_name 				= ""
									local _Type_						= ""
												
									local _AName_name				= ""
									local _AName_ 					= ""					
									
									local _Binding_name				= ""
									local _Binding_					= ""
												
									local _LodDistances_name 	= ""
									local _LodDistances_ 			= ""

									local _StringGenMask_name 	= ""
									local _StringGenMask_ 			= ""
											
									local _Flags_name 				= ""
									local _Flags_ 						= ""
									
									
									---------------------- HFR ----------------------
									local _BoneName_Name 		= ""
									local _BoneName_ 				= ""
									
									local _Rotation_Name 			= ""
									local _Rotation_ 					= ""
									
									local _Position_Name 			= ""
									local _Position_ 					= ""
									-----------------------------------------------------
									
									
									local inst_CDF_Attribs = CDF_Attribs()
									inst_CDF_Attribs.idx						= Attachment_node_counter
									
									if nodeType != undefined then
									(
										if iskindof nodeType string then
										(
											inst_CDF_Attribs.nTagString 	= nodeType
										)
									)
									else
									(
										format "Warning, cdf node could not be established!\n"
									)	
									
									case of
									(
										(stricmp attribName "File" == 0):
										(
											_File_name											= attribName
											_File_												= attribVal
											
											Append inst_CDF_Attribs.attribName		_File_name
											Append inst_CDF_Attribs.attribVal			_File_
										)
										(stricmp attribName "Material" == 0):
										(
											_Material_name									= attribName
											_Material_											= attribVal
											
											Append inst_CDF_Attribs.attribName		_Material_name
											Append inst_CDF_Attribs.attribVal			_Material_
										)
										(stricmp attribName "Type" == 0):
										(
											_Type_name										= attribName
											_Type_												= attribVal
											
											Append inst_CDF_Attribs.attribName		_Type_name
											Append inst_CDF_Attribs.attribVal			_Type_
										)
										(stricmp attribName "AName" == 0):
										(
											_AName_name										= attribName
											_AName_											= attribVal
											
											Append inst_CDF_Attribs.attribName		_AName_name
											Append inst_CDF_Attribs.attribVal			_AName_
										)
										(stricmp attribName "Binding" == 0):
										(
											_Binding_name										= attribName
											_Binding_											= attribVal
											
											Append inst_CDF_Attribs.attribName		_Binding_name
											Append inst_CDF_Attribs.attribVal			_Binding_
										)
										(stricmp attribName "LodDistances" == 0):
										(
											_LodDistances_name							= attribName
											_LodDistances_									= attribVal
											
											Append inst_CDF_Attribs.attribName		_LodDistances_name
											Append inst_CDF_Attribs.attribVal			_LodDistances_
										)
										(stricmp attribName "Flags" == 0):
										(
											_Flags_name										= attribName
											_Flags_												= attribVal
											
											Append inst_CDF_Attribs.attribName		_Flags_name
											Append inst_CDF_Attribs.attribVal			_Flags_
										)
										(stricmp attribName "BoneName" == 0):
										(
											_Flags_name										= attribName
											_Flags_												= attribVal
											
											Append inst_CDF_Attribs.attribName		_Flags_name
											Append inst_CDF_Attribs.attribVal			_Flags_
										)
										(stricmp attribName "Rotation" == 0):
										(
											_Flags_name										= attribName
											_Flags_												= attribVal
											
											Append inst_CDF_Attribs.attribName		_Flags_name
											Append inst_CDF_Attribs.attribVal			_Flags_
										)
										(stricmp attribName "Position" == 0):
										(
											_Flags_name										= attribName
											_Flags_												= attribVal
											
											Append inst_CDF_Attribs.attribName		_Flags_name
											Append inst_CDF_Attribs.attribVal			_Flags_
										)
									)
									Append ::g_inst_CDF_Attribs inst_CDF_Attribs
								)
								else if (stricmp (type as string) ".chrparams") == 0 then
								(
									local _Name_name 			= ""
									local _Name_					= ""
									
									local _path_name 			= ""
									local _path_ 					= ""
									
									
									local inst_CHRPARAMS_Attribs 			= CHRPARAMS_Attribs()
									inst_CHRPARAMS_Attribs.nodeID 		= Anim_Node_Counter
									
									if nodeType != undefined then
									(
										if iskindof nodeType string then
										(
											inst_CHRPARAMS_Attribs.nTagString = nodeType
										)
									)
									else
									(
										format "Warning, cdf node could not be established!\n"
									)
									
									case of
									(
										(stricmp attribName "Name" == 0):
										(					
											_Name_name												= attribName
											_Name_														= attribVal					
											
											Append inst_CHRPARAMS_Attribs.attribName		_Name_name
											Append inst_CHRPARAMS_Attribs.attribVal		_Name_
										)
										(stricmp attribName "Path" == 0):
										(
											_Path_name												= attribName
											_Path_														= attribVal
											
											Append inst_CHRPARAMS_Attribs.attribName		_Path_name
											Append inst_CHRPARAMS_Attribs.attribVal		_Path_
										)				
									)
									Append 		::g_inst_CHRPARAMS_Attribs 		inst_CHRPARAMS_Attribs			
								)
							)
						)
					)
					else
					(
						format "Warning, nodeType node could not be established!\n"
					)
				)
				else
				(
					format "Warning, Type node could not be established!\n"
				)
			)
		)
	),
	
	--format indents for tree level
	fn format_tabs depth =
	(
		for i=1 to depth do format "\t" 
	),
	
	fn get_Nested_def \
								&theNode: =
	(
		local attribN 		= undefined
		local attribV 		= undefined		
		
		for n=0 to theNode.attributes.count-1 do
		(
			attribN 				= theNode.attributes.itemof[n].name
			attribV 				= theNode.attributes.itemof[n].value
			
			local rootP 				= ::g_dirpath
			
			local refPath 				= pathConfig.resolvePathSymbols (pathConfig.appendpath rootP attribV) --construct the final path
			
			if ::rollout_Report.chk_XML_Report.state then
			(			
				format "attribN: %\n" attribN
				format "attribV: %\n" attribV
			)
			
			--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
			if attribN == "definition" AND (doesfileexist refPath) then
			(
				if (doesfileexist refPath) then
				(
					local arrDef 						= #() --reset array
			
					str_read_xml 				= read_xml()
					str_read_xml.report 		= true
			
					--read definition
					arrDef = str_read_xml.main \
															xmlPath: 	&refPath \
															xml_arr: 	&str_read_xml._xml
					
					--format "attribV:% \n" refPath
					--Append VARIANT_MESH_REFERENCE_array arrDef
				)
			)
			--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//			
		)		
	),
	
	fn store_XML_attribs \
									&nodeType: \
									&matNodeCounter: \
									&attribName: \
									&attribVal: \
									&matNodeCounter_REF: \
									&g_xml_Parsed: \									
									&matNodeCounter_MAT: \
									&Attachment_node_counter: \
									&MaterialRef_node_counter: \
									&theMat: \
									&compositeMat: \
									&matIDX: =
	(
		-------------------------------------- Test ---------------------------------------
		if 	(stricmp nodeType "Material") == 0 then
		(
			---------------- Reset Array ----------------
			g_xml_Parsed			=	#(
												#(), \	-- 1
												#(), \	-- 2
												#(), 	\-- 3
												#(), 	\-- 4
												#() 	\-- 5 MaterialRef
												)

			if ::g_xmlB_Report_v2 then
			(
				print "--------------------------- Following are the attributes of a Material Node ---------------------------"
			)
		)				
		else if (stricmp nodeType "MaterialRef") == 0 then
		(
			---------------- Reset Array ----------------
			g_xml_Parsed			=	#(
												#(), 	-- 1
												#(), 	-- 2
												#(), 	-- 3
												#(), 	-- 4
												#() 	-- 5 MaterialRef
												)													
					
			if ::rollout_Report.chk_MaterialRef_Report.state then
			(
				print "------------------------- Following are the attributes of a MaterialRef Node -------------------------"
			)
		)				
		else if (stricmp nodeType "Textures") == 0 then
		(
			if ::g_xmlB_Report_v2 then
			(
				print "--------------------------- Following are the attributes of a Textures Node ---------------------------"
			)					
		)
		else if (stricmp nodeType "Texture") == 0 then
		(
			if ::g_xmlB_Report_v2 then
			(
				print "--------------------------- Following are the attributes of a Texture Node ---------------------------"
			)					
		)
		else if (stricmp nodeType "TexMod") == 0 then
		(
			if ::g_xmlB_Report_v2 then
			(
				print "--------------------------- Following are the attributes of a TexMod Node ---------------------------"
			)					
		)
		else if (stricmp nodeType "PublicParams") == 0 then
		(
			if ::g_xmlB_Report_v2 then
			(
				print "------------------------- Following are the attributes of a PublicParams Node -------------------------"
			)
		)
		
-- 		print matNodeCounter
		
		xmlB_storeAttribs_v3 \
									nodeType:									&nodeType \
									matNodeCounter:							&matNodeCounter \
									attribName:								&attribName \
									attribVal:									&attribVal \
									matNodeCounter_MAT: 				&matNodeCounter_MAT \
									matNodeCounter_REF:					&matNodeCounter_REF \						
									type:											&type \
									g_xml_Parsed:								&g_xml_Parsed \														
									Attachment_node_counter:			&Attachment_node_counter \
									MaterialRef_node_counter: 			&MaterialRef_node_counter \
									theMat:										&theMat \
									compositeMat:							&compositeMat \
									matIDX:										&matIDX \
			
		Append 	::g_xml_MatNodesSet 	::g_xml_Parsed
		--------------------------------------------------------------------------------------		
	),
	
	--get the attributes
	fn get_Attribs \
						caller: \
						&Attachment_node_counter: \
						&Anim_Node_Counter: \
						&nodeType: \
						&matNodeCounter: \
						&matNodeCounter_REF: \
						&theNode:  \
						&xml_arr: =
	(
		local attribName 			= undefined
		local attribValue 			= undefined
		
		for n=0 to theNode.attributes.count-1 do
		(
			attribName 				= theNode.attributes.itemof[n].name
			attribValue 				= theNode.attributes.itemof[n].value
			
			if (stricmp caller ".mtl") == 0 then
			(
				--------------- .mtl XML ---------------
				store_XML_attribs \
											nodeType:									&nodeType \
											matNodeCounter:							&matNodeCounter \
											attribName:								&attribName \
											attribVal:									&attribValue \
											matNodeCounter_MAT: 				&matNodeCounter_MAT \
											matNodeCounter_REF:					&matNodeCounter_REF \						
											type:											&type \
											g_xml_Parsed:								&g_xml_Parsed \														
											Attachment_node_counter:			&Attachment_node_counter \
											MaterialRef_node_counter: 			&MaterialRef_node_counter \
											theMat:										&theMat \
											compositeMat:							&compositeMat \
											matIDX:										&matIDX \
			)
			else if (stricmp caller ".cdf") == 0 then
			(
					CDF_storeAttribs_v3 \
													type:									&caller \
													g_xmlB_Parsed:					&g_xmlB_Parsed \
													matNodeCounter:					&matNodeCounter \
													Attachment_node_counter: 	&Attachment_node_counter \
													Anim_Node_Counter:			&Anim_Node_Counter \
													theMat:								&theMat \
													compositeMat:					&compositeMat \
													matIDX:								&matIDX \
													nodeType:							&nodeType \
													attribName:						&attribName \
													attribVal:							&attribValue
			)
			
			
			
			Append 		str_xmlStruct.attribs[1] 		attribName
			Append 		str_xmlStruct.attribs[2] 		attribValue
			
			if ::rollout_Report.chk_XML_Report.state then
			(
				----------------depth format
				format_tabs depth
				format " --m_attribName: %\n" attribName
				----------------depth format
				format_tabs depth
				format " --m_attribValue: %\n" attribValue
			)
		)
	),
	
	--recurse function
	fn recurse \
					caller: \
					&Attachment_node_counter: \
					&Anim_Node_Counter: \
					&matNodeCounter: \
					&matNodeCounter_REF: \
					&children: \
					&xml_arr: =
	(
		numRecurse += 1		
		
		----------------depth add
		depth += 1										
		
		local children 				= children.childnodes	
		
		local childNum2 			= undefined --the count of the child
		local childName 			= undefined
		local parentNode 		= undefined
		local parentName 		= undefined
		
		for x=0 to children.count-1 do
		(			
			------------------------------------------------------------------------------------
			if x == 0 then
			(
				rootChildrenIDX_2 += 1
			)
			------------------------------------------------------------------------------------
			
			local child 					= children.itemof[x]
			local childNum2 			= children.itemof[x].childnodes.count --the count of the child
			local childName 			= child.name
			local parentNode 		= child.parentNode
			local parentName 		= child.parentNode.name
			
			----array append----
			str_xmlStruct 							= xmlStruct() --create instance
				str_xmlStruct.rootName 		= rootName
				str_xmlStruct.numChildren 	= childNum2
				str_xmlStruct.nodeName 		= childName
				str_xmlStruct.parentName 	= parentName
				str_xmlStruct.depth 				= depth
			
			
			
			----------------------------------------------------------
			local nodeType = childName
			
			if (stricmp caller ".mtl") == 0 then
			(
				if (stricmp childName "Material") == 0 then
				(
					matNodeCounter 			+= 1  
				)
				else if (stricmp nodeType "MaterialRef") == 0 then
				(
					matNodeCounter_REF 	+= 1
				)
			)
			else if (stricmp caller ".cdf") == 0 then
			(
				if (stricmp childName "Model") == 0 then --???
				(
					matNodeCounter 			+= 1
-- 					matNodeCounter_REF 	+= 1
				)
			)
			
			/*
			--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
			if childName == "VARIANT_MESH_REFERENCE" then
			(
				--get attribs
				get_Nested_def \												
										theNode: &child
			)
			--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
			--*/

			
				Append str_xmlStruct.parentIDX rootIDX --always zero, this is the root index
					Append str_xmlStruct.parentIDX idx --children directly under root
						Append str_xmlStruct.parentIDX rootChildrenIDX
							if depth > 2 then
							(
								Append str_xmlStruct.parentIDX (rootChildrenIDX_2) --idx
								Append str_xmlStruct.parentIDX (x+1) --children count
							)			
			
			if ::rollout_Report.chk_XML_Report.state then
			(
				----------------depth format
				format_tabs depth
				format "\n"
				
				--print tree index level
				format_tabs depth
				
				for d=1 to depth do
				(				
					format "%." str_xmlStruct.parentIDX[d]					
				)				

				--format the name of the node
				format "%. Name: %\t(parent: %)\n" (x+1) childName parentName
			)
	
			--get attribs
			get_Attribs \
							caller: 								caller \
							Attachment_node_counter: 	&Attachment_node_counter	\
							Anim_Node_Counter: 			&Anim_Node_Counter	\
							nodeType:							&nodeType \
							matNodeCounter:					&matNodeCounter \
							matNodeCounter_REF:			&matNodeCounter_REF \
							theNode: 							&child \ 
							xml_arr: 							&xml_arr		
			
			Append xml_arr str_xmlStruct
			
			--the recurse 2
			recurse \
						caller: 								caller \
						Attachment_node_counter: 	&Attachment_node_counter	\
						Anim_Node_Counter: 			&Anim_Node_Counter	\
						nodeType:							&nodeType \
						matNodeCounter:					&matNodeCounter \
						matNodeCounter_REF:			&matNodeCounter_REF \
						children: 							&child \
						xml_arr: 							&xml_arr			

		)
		----------------depth substract
		depth -= 1
	),
	
	fn csharp_assembly \
								&xmlPath: =
	(
		if NOT Binary_XML_check xmlPath then
		(		
			--------------------------------Create the dotNet xmlDoc----------------------------
			--Load the xml assemply
			dotNet.loadAssembly "system.xml"
			
			--Create an xml document object.
			local xmldoc = dotnetobject "System.XML.XMLDocument"

			--This is the Root of the XML
			if template != "" then
			(
				xmldoc.Load xmlPath
			)
			return xmldoc.documentElement
		)
		else
		(
			format "Not a valid XML File - this is an xmlB (binary XML) file! - use the binary reader instead \n"
		)
	),
	
	fn main \
				caller: \
				&Attachment_node_counter: \
				&Anim_Node_Counter: \
				&matNodeCounter: \
				&matNodeCounter_REF: \
				&xmlPath: \
				&xml_arr: =
	(
		if NOT Binary_XML_check xmlPath then
		(
			local docEle = csharp_assembly \
														xmlPath: &xmlPath
			
			--read the root and get inside the xml to read the rest via the recurse function
			if docEle !=undefined then
			(
				xml_arr = #()			
				
				local rootIDX = 0
				local rootName = ""-----
				
				if ::rollout_Report.chk_XML_Report.state then
				(
					rootName = docEle.name
					format "%. Root: %\n" rootIDX rootName --->>>
				)
				
					---- array append ( this is the root - only one ofcourse) ----
					str_xmlStruct 						= xmlStruct()
						str_xmlStruct.rootName 	= rootName
						str_xmlStruct.isRoot 		= true
						Append 		str_xmlStruct.parentIDX 		rootIDX
					Append 		xml_arr 		str_xmlStruct
				
				--first pass the root to get its children (if there arent any children to the root, we cannot go in here)
				if docEle.childnodes.count > 0 then
				(
					----------------depthadd
					depth += 1
					
					--recurse through each of the root children -- it will go as deep as it needs to
					for n=0 to docEle.childnodes.count-1 do
					(
						child 				= docEle.childnodes.itemof[n]
						childName 		= child.name
						
						if ::rollout_Report.chk_XML_Report.state then
						(
							--REPORT
							----------------depth format
							format_tabs depth
							format "\n"
							----------------depth format
							format_tabs depth
							format "%.%. Name: %\n" rootIDX (n+1) childName --->>>
						)						
						
						if (stricmp caller ".mtl") == 0 then
						(
							if 	(stricmp childName "Material") 					== 0 OR \
								(stricmp childName "SubMaterials") 				== 0 then
							(							
								idx += 1
								
								----array append----
								str_xmlStruct 							= xmlStruct()
									str_xmlStruct.nodeName 		= childName
									str_xmlStruct.numChildren 	= docEle.childnodes.count						
									Append 		str_xmlStruct.children 		childName						
									str_xmlStruct.parentName 	= child.parentNode.name
									str_xmlStruct.depth 				= depth
								
									Append str_xmlStruct.parentIDX rootIDX
									Append str_xmlStruct.parentIDX idx
								
									if rootChildrenIDX > 0 then
									(
										Append str_xmlStruct.parentIDX rootChildrenIDX
									)

									--get attribs
									get_Attribs \	
													caller: 								caller \
													nodeType:							&childName \													
													Attachment_node_counter: 	&Attachment_node_counter	\
													Anim_Node_Counter: 			&Anim_Node_Counter	\
													matNodeCounter:					&matNodeCounter \
													matNodeCounter_REF:			&matNodeCounter_REF \	
													theNode: 							&child \ 
													xml_arr: 							&xml_arr					

								Append xml_arr str_xmlStruct
								
								rootChildrenIDX += 1 --the index of the children directly under the Root
								
								recurse \
											caller: 								caller \
											Attachment_node_counter: 	&Attachment_node_counter	\
											Anim_Node_Counter: 			&Anim_Node_Counter	\
											matNodeCounter:					&matNodeCounter \
											matNodeCounter_REF:			&matNodeCounter_REF \
											children: 							&child \
											xml_arr: 							&xml_arr
							)
						)
						else if (stricmp caller ".cdf") == 0 then
						(
							idx += 1
								
							----array append----
							str_xmlStruct 							= xmlStruct()
							str_xmlStruct.nodeName 		= childName
							str_xmlStruct.numChildren 	= docEle.childnodes.count						
							Append 		str_xmlStruct.children 		childName						
							str_xmlStruct.parentName 	= child.parentNode.name
							str_xmlStruct.depth 				= depth
								
							Append str_xmlStruct.parentIDX rootIDX
							Append str_xmlStruct.parentIDX idx
								
							if rootChildrenIDX > 0 then
							(
								Append str_xmlStruct.parentIDX rootChildrenIDX
							)

							--get attribs
							get_Attribs \		
											caller: 								caller \
											nodeType:							&childName \											
											Attachment_node_counter: 	&Attachment_node_counter	\
											Anim_Node_Counter: 			&Anim_Node_Counter	\
											matNodeCounter:					&matNodeCounter \
											matNodeCounter_REF:			&matNodeCounter_REF \	
											theNode: 							&child \ 
											xml_arr: 							&xml_arr						

							Append xml_arr str_xmlStruct
								
							rootChildrenIDX += 1 --the index of the children directly under the Root
								
							recurse \
										caller: 								caller \
										Attachment_node_counter: 	&Attachment_node_counter	\
										Anim_Node_Counter: 			&Anim_Node_Counter	\
										matNodeCounter:					&matNodeCounter \
										matNodeCounter_REF:			&matNodeCounter_REF \
										children: 							&child \
										xml_arr: 							&xml_arr

						)
					)
					depth -= 1
				)				
				
			)
			
			return xml_arr;
		)
		else
		(
			format "Not a valid XML File - this is an xmlB (binary XML) file! - use the binary reader instead \n"
			return xml_arr = #();
		)
	)
)

struct xml_PROCESSOR
(	
	--format indents for tree level
	fn format_tabs depth: =
	(
		for i=1 to depth do format "\t" 
	),	
	
	fn printNodes \
						&xml_arr: =
	(
		for i=1 to xml_arr.count do
		(
			format_tabs depth:xml_arr[i].depth
				
			if (stricmp (xml_arr[i].parentName as string) "Material") == 0 then
			(
				print xml_arr[i]
			)
		)
	)
)

--///////////////// Tool -- just a reader, not critical /////////////////
fn examine_XML \
						&g_cryFile: =
(
	setINISetting 		::g_iniFile 		"paths" "last_loaded" 		g_cryFile
	setINISetting 		::g_iniFile 		"xml_paths" ".mtl" 			g_cryFile
									
	--///////////////////////////// Read XML ////////////////////////////////
	local init_state = ::rollout_Report.chk_XML_Report.state
	::rollout_Report.chk_XML_Report.state = true --override
									
	str_read_xml = read_xml()
	str_read_xml.report = true --for formatting the print arr -- just for readability
									
	--Preload attributes
	local matNodeCounter 					= 0
	local matNodeCounter_REF 			= 0
									
	--Parsing the xml (.mtl)
	local xml_arr =  str_read_xml.main \
													caller:							(getFilenameType g_cryFile) \
													matNodeCounter: 			&matNodeCounter \ 			--right here, we just provide this as dummies, because they are required
													matNodeCounter_REF: 		&matNodeCounter_REF \ 	--right here, we just provide this as dummies, because they are required
													xmlPath: 						&g_cryFile \
													xml_arr: 						&str_read_xml._xml
									
	--Processing/analysing the parsed xml
	inst_xml_PROCESSOR = xml_PROCESSOR()
	inst_xml_PROCESSOR.printNodes \
												xml_arr: &xml_arr
																				
	::rollout_Report.chk_XML_Report.state = init_state --restore the overridden value
	--////////////////////////////////////////////////////////////////////////
)





