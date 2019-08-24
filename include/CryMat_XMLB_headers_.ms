--see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\CryCommon\IMaterial.h
-- in Cryengine 5 source code
-- //////////////////////////////////////////////////////////////////////////
-- // Description:
-- //    IMaterial is an interface to the material object, SShaderItem host which is a combination of IShader and SShaderInputResources.
-- //    Material bind together rendering algorithm (Shader) and resources needed to render this shader, textures, colors, etc...
-- //    All materials except for pure sub material childs have a unique name which directly represent .mtl file on disk.
-- //    Ex: "Materials/Fire/Burn"
-- //    Materials can be created by Sandbox MaterialEditor.
-- //////////////////////////////////////////////////////////////////////////

struct EMaterialFlags
(
	MTL_FLAG_WIRE                      				= 0x0001,   --//!< Use wire frame rendering for this material.
	MTL_FLAG_2SIDED                    				= 0x0002,   --//!< Use 2 Sided rendering for this material.
	MTL_FLAG_ADDITIVE                  				= 0x0004,   --//!< Use Additive blending for this material.
	MTL_FLAG_DETAIL_DECAL              			= 0x0008,   --//!< Massive decal technique.
	MTL_FLAG_LIGHTING                 				= 0x0010,   --//!< Should lighting be applied on this material.
	MTL_FLAG_NOSHADOW                  			= 0x0020,   --//!< Material do not cast shadows.
	MTL_FLAG_ALWAYS_USED               			= 0x0040,   --//!< When set forces material to be export even if not explicitly used.
	MTL_FLAG_PURE_CHILD                				= 0x0080,   --//!< Not shared sub material, sub material unique to his parent multi material.
	MTL_FLAG_MULTI_SUBMTL              			= 0x0100,   --//!< This material is a multi sub material.
	MTL_FLAG_NOPHYSICALIZE             			= 0x0200,   --//!< Should not physicalize this material.
	MTL_FLAG_NODRAW                    				= 0x0400,   --//!< Do not render this material.
	MTL_FLAG_NOPREVIEW                 			= 0x0800,   --//!< Cannot preview the material.
	MTL_FLAG_NOTINSTANCED              			= 0x1000,   --//!< Do not instantiate this material.
	MTL_FLAG_COLLISION_PROXY           			= 0x2000,   --//!< This material is the collision proxy.
	MTL_FLAG_SCATTER                   				= 0x4000,   --//!< Use scattering for this material.
	MTL_FLAG_REQUIRE_FORWARD_RENDERING 	= 0x8000,   --//!< This material has to be rendered in foward rendering passes (alpha/additive blended).
	MTL_FLAG_NON_REMOVABLE             			= 0x10000,  --//!< Material with this flag once created are never removed from material manager (Used for decal materials, this flag should not be saved).
	MTL_FLAG_HIDEONBREAK               			= 0x20000,  --//!< Non-physicalized subsets with such materials will be removed after the object breaks.
	MTL_FLAG_UIMATERIAL                				= 0x40000,  --//!< Used for UI in Editor. Don't need show it DB.
	MTL_64BIT_SHADERGENMASK            			= 0x80000,  --//!< ShaderGen mask is remapped.
	MTL_FLAG_RAYCAST_PROXY             			= 0x100000,
	MTL_FLAG_REQUIRE_NEAREST_CUBEMAP   	= 0x200000, --//!< Materials with alpha blending requires special processing for shadows.
	MTL_FLAG_CONSOLE_MAT               			= 0x400000,
	MTL_FLAG_DELETE_PENDING            			= 0x800000, --//!< Internal use only.
	MTL_FLAG_BLEND_TERRAIN             			= 0x1000000
)
/*
--Bitmasking
For example, let's say we have MtlFlags = "525440"
In HEX, this is 0x80480
Which is the sum of the EMaterialFlags
0x80000 + 0x0400 + 0x0080 (see above)

MTL_64BIT_SHADERGENMASK        	= 0x80000
MTL_FLAG_NODRAW                    		= 0x0400,   //!< Do not render this material.
MTL_FLAG_PURE_CHILD                		= 0x0080,
--*/

--///////////////////////////////////////////////////////////////////////////
--see: C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\RenderDll\Common\Shaders\ShaderCore.cpp
--see: ShaderParse.cpp 392, 491
--see: Renderer.cpp 1469
struct MaskGenFlags
(
	--// Store original values since common material flags where introduced
	ALPHAGLOW 								= #("0x2", "ALPHAGLOW" ), 										--uint64
	ALPHAMASK_DETAILMAP 				= #("0x4", "ALPHAMASK_DETAILMAP" 	),						--uint64
	ANISO_SPECULAR 						= #("0x8", "ANISO_SPECULAR" ), 								--(uint64)

	BILINEAR_FP16 							= #("0x10", "BILINEAR_FP16" ), 									--(uint64)
	BUMP_DIFFUSE 							= #("0x20", "BUMP_DIFFUSE"), 									--(uint64)
	CHARACTER_DECAL 						= #("0x40", "CHARACTER_DECAL"), 							--(uint64)

	CUSTOM_SPECULAR 						= #("0x400", "CUSTOM_SPECULAR" ), 							--(uint64)
	DECAL 										= #("0x800", "DECAL" ), 											--(uint64)

	DETAIL_BENDING 							= #("0x1000", "DETAIL_BENDING"), 							--(uint64)
	DETAIL_BUMP_MAPPING 				= #("0x2000", "DETAIL_BUMP_MAPPING"), 					--(uint64)
	DISABLE_RAIN_PASS 					= #("0x4000", "DISABLE_RAIN_PASS" ), 						--(uint64)

	ENVIRONMENT_MAP 						= #("0x10000", "ENVIRONMENT_MAP"), 						--(uint64)
	EYE_OVERLAY 							= #("0x20000", "EYE_OVERLAY" ), 								--(uint64)
	GLOSS_DIFFUSEALPHA 					= #("0x40000", "GLOSS_DIFFUSEALPHA"),					--(uint64)
	GLOSS_MAP 								= #("0x80000", "GLOSS_MAP" ), 								--(uint64)

	GRADIENT_COLORING 					= #("0x100000", "GRADIENT_COLORING"), 					--(uint64)
	GRASS 										= #("0x200000", "GRASS"), 										--(uint64)
	IRIS 											= #("0x400000", "IRIS"), 											--(uint64)
	LEAVES 										= #("0x800000", "LEAVES"), 										--(uint64)

	NANOSUIT_EFFECTS 					= #("0x1000000", "NANOSUIT_EFFECTS"), 					--(uint64)
	OFFSET_BUMP_MAPPING 				= #("0x2000000", "OFFSET_BUMP_MAPPING"), 				--(uint64)
	PARALLAX_OCCLUSION_MAPPING 	= #("0x8000000", "PARALLAX_OCCLUSION_MAPPING"), 	--(uint64)

	REALTIME_MIRROR_REFLECTION 		= #("0x10000000", "REALTIME_MIRROR_REFLECTION"), 	--(uint64)
	REFRACTION_MAP 						= #("0x20000000", "REFRACTION_MAP"), 					--(uint64)
	RIM_LIGHTING 							= #("0x40000000", "RIM_LIGHTING"), 							--(uint64)
	SPECULARPOW_GLOSSALPHA 			= #("0x80000000", "SPECULARPOW_GLOSSALPHA"),		--(uint64)

	TEMP_TERRAIN 							= #("0x200000000", "TEMP_TERRAIN" ), 						--(uint64) ULL
	TEMP_VEGETATION 						= #("0x400000000", "TEMP_VEGETATION" ), 				--(uint64) ULL
	TERRAINHEIGHTADAPTION 			= #("0x800000000", "TERRAINHEIGHTADAPTION"), 		--(uint64) ULL

	TWO_SIDED_SORTING 					= #("0x1000000000", "TWO_SIDED_SORTING" ), 			--(uint64) ULL
	VERTCOLORS 								= #("0x2000000000", "VERTCOLORS"), 						--(uint64) ULL
	WIND_BENDING 							= #("0x4000000000", "WIND_BENDING"), 						--(uint64) ULL
	WRINKLE_BLENDING 						= #("0x8000000000", "WRINKLE_BLENDING") 				--(uint64) ULL
)

struct tex_tokens
(
	diff_tkn 		= 	"*_dif*",
	spec_tkn 	= 	"*_spec*",
	ddn_tkn		= "*_ddn*",
	ddna_tkn	= "*_ddna*"
)
	

------CDF structs------
struct CDF_Attribs
(
	nTagString 		= "",
	idx				= 0,
	attribName 		= #(),
	attribVal 		= #()	
)
--------------------------

struct CHRPARAMS_Attribs
(
	nodeID			= 0,
	nTagString 		= "",
	attribName 		= #(),
	attribVal 		= #()
)

struct matParams
(	
	nTagString 							= "",
	matNodeCounter_REF			= 0,
	
	matIDX								= 0,
	subM									= 0,
	
	matNodeCounter 					= 0,	
	MaterialRef_node_counter 		= 0,
	matNodeCounter_MAT			= 0,
	
	i										= 0,
	
	MaterialRef_Bool					= false,
	caller									= false
)

struct materialAttribs
(
	nTagString 		= "",
	
	matNodeCounter 							= 0,
	matNodeCounter_REF					= 0,
	MaterialRef_node_counter				= 0,
	matNodeCounter_MAT					= 0,
	
	_Name_ 					= #(),
	_Shader_ 				= #(),
						
	_MtlFlags_ 				= #(),
	_MtlFlags_arr 			= #(),
	
	_GenMask_ 			= #(),
	_GenMask_arr			= #(),
						
	_StringGenMask_ 	= #(),
	_SurfaceType_ 		= #(),
	_MatTemplate_ 		= #(),
	_Diffuse_ 				= #(),
	_Specular_ 			= #(),
	_Emissive_ 				= #(),
	_Shininess_ 			= #(),
	_Opacity_ 				= #(),
	_LayerAct_ 			= #(),
	
	MaterialRef_Bool					= false,
	caller									= false
)

struct MaterialRefAttribs
(
	nTagString 							= "",
	
	matNodeCounter_REF			= 0,	
	MaterialRef_node_counter 		= 0,
	matNodeCounter 					= 0,
	matNodeCounter_MAT			= 0,
	
	_NameRef_ 						= #(),
	
	MaterialRef_Bool					= false,
	caller									= false
)

struct textureAttribs
(
	_Map_ 						= #(),
	_File_ 						= #(),
	
	_TexType_ 				= #(),
	_IsTileU_ 					= #(),
	_IsTileV_					= #()

)	

struct publicParamsAttribs
(
	_BlendFalloff_ 				= #(),
	_BlendLayer2Tiling_ 		= #(),
	
	_SSSIndex_ 				= #(),
	_BlendMaskTiling_ 		= #(),
	_BlendFactor_				= #(),
	
	_BlendLayer2Specular_ 	= #(),
	_IndirectColor_ 			= #()
)

struct s_OPTIONS
(
	chk_dds 					= false,
		chk_dds_string 		= ".dds"
)	

struct xmlB_struct
(
	nodeDepth 		= 		0,
	nTagString 		= 		"",
	attribName 		= 		#(),
	attribVal			= 		#()
)

struct _Node
(
	nTagStringOffset 			= 0,  	--uint32 --offset in CBinaryXmlData::pStringData
		nTagString					= "",
	nContentStringOffset 		= 0,   	--uint32 --offset in CBinaryXmlData::pStringData
	nAttributeCount 				= 0,		--uint16
	nChildCount 					= 0,		--uint16
	nParentIndex 					= 0, 		--uint32(p?) -1 prob means root node	--NodeIndex 	 	typedef uint32 NodeIndex;  // note: only uint32 or uint16 are supported
	nFirstAttributeIndex 			= 0,  	--uint32(p?)				--NodeIndex 		typedef uint32 NodeIndex;  // note: only uint32 or uint16 are supported
	nFirstChildIndex				= 0,		--uint32(p?)				--NodeIndex 		typedef uint32 NodeIndex;  // note: only uint32 or uint16 are supported
		
	Pad 								= 1 		--int32(p?) (1 readlong)	--Pad<sizeof(uint32) - sizeof(NodeIndex)> reserved_for_alignment; 
)

struct Attribute
(
	nKeyStringOffset 			= 0,        		--uint32 --offset in CBinaryXmlData::pStringData
	nValueStringOffset 		= 0      		--uint32 --offset in CBinaryXmlData::pStringData
)

struct BinaryFileHeader
(
	szSignature 				= "", 		--char [8]
	nXMLSize 					= 0, 		--uint32
	nNodeTablePosition 		= 0, 		--uint32
	nNodeCount 				= 0,		--uint32
	nAttributeTablePosition = 0, 		--uint32
	nAttributeCount 			= 0, 		--uint32
	nChildTablePosition 		= 0, 		--uint32
	nChildCount 				= 0, 		--uint32
	nStringDataPosition 		= 0,		--uint32
	nStringDataSize			= 0, 		--uint32
	
	----------- HFR --------------------
	u1A							= 0,
	u2A							= 0,
	u3A							= 0,
	u_A_TablePosition		= 0,
	u_B_TablePosition		= 0,
	u_C_TablePosition		= 0,
	u_D_TablePosition		= 0,
	u_D_TableCount			= 0
)


struct attrib_child_indices
(
	nFirstAttributeIndex 		= 0,
	nFirstChildIndex 			= 0,
	
	nFirstAttribute_val 		= "",
	nFirstChild_val 			= ""
)

struct stored_SkeletonList_XML
(
	_Name 	= #(),
	_File		= #()
)

fn print_SkeletonList \
								&SkeletonList: =
(
	if SkeletonList != undefined then
	(
		if SkeletonList._File.count > 0 then
		(
			for i=1 to SkeletonList._File.count do
			(
				format "\n"				
				format "_Name: %\n" 	SkeletonList._Name[i]
				format "_File: %\n" 		SkeletonList._File[i]
				format "\n"
			)
		)
		else
		(
			format "\n"
			format "*** There is no Skeleton List to print out! ***\n"			
			format "\n"
		)
	)
)



