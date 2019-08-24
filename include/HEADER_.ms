--////////////////////////////////////////////////////////////////////////////////////
fn get_game_dirPath =
(
	if g_cryFile == unsupplied then
	(
		if (getINISetting ::g_iniFile "gameDirs" ::g_CryGame_dropDown_selection) != "" then --try to get the gamedir
		(			
			::g_dirpath = getINISetting ::g_iniFile "gameDirs" ::g_CryGame_dropDown_selection
		)
		else --if gamedir is empty
		(
			::g_dirpath = getINISetting ::g_iniFile "paths" "g_dirpath"
		)
	)
		
	if ::g_dirpath == "" then
	(
		confirm = yesNoCancelBox "You must choose a root game directory, do you want to do it now?" \
												title:"WARNING" \
												beep:true		
		if confirm == #yes then
		(
			::g_dirpath = getSavePath caption:"Choose Game directory"
		)
	)
)

fn update_dirPath \
						context:"global" =
(	
-- 	if context == "global" then
-- 	(
		local curr_Game 	= (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
		local gameDir		= (getINISetting ::g_iniFile "gameDirs" curr_Game) 
-- 	)
-- 	else if context == "local" then
-- 	(
-- 		local curr_Game 	= ddl_CryGame.items[ddl_CryGame.selection]
-- 		gameDir		= (getINISetting ::g_iniFile "gameDirs" curr_Game) 
-- 	)
	
	if doesfileexist gameDir then
	(		
		setINISetting ::g_iniFile "paths" "g_dirpath" gameDir
		::g_dirpath = gameDir
	)
)
--////////////////////////////////////////////////////////////////////////////////////
struct ResourceLists
(
	perLayer 		= #(),
	auto				= #(),
	resourceList	= #()
)
global inst_ResourceLists = ResourceLists() --we create a global
--////////////////////////////////////////////////////////////////////////////////////
struct TYPES
(
	--These will be set to the arrays, but here declared as simply 0
	g_ChunkTypes 												= 0,
	g_FILE_HEADER 												= 0,
	g_CHUNKTABLE_FILE_CONSTANTS 						= 0,
	g_CHUNKTABLE_0744_0745 								= 0,	
	g_SOURCE_INFO 												= 0,
	g_EXPORT_FLAGS_CHUNK_DESC 						= 0,
	g_TIMING_CHUNK_DESC 									= 0,

	g_MTL_NAME_CHUNK_DESC								= 0,
	
	g_MESH_SUBSETS_CHUNK_DESC_0800 				= 0,
	g_ECgfStreamType 											= 0,
	g_NODE_CHUNK_DESC_0824 								= 0,
	g_MESH_CHUNK_DESC_0801 								= 0,
	g_FOLIAGE_INFO_CHUNK_DESC 							= 0,
	g_MESH_PHYSICS_DATA_CHUNK_DESC_0800 		= 0,
	g_CryBoneDescData_Comp									= 0,
	g_BONE_ENTITY												= 0
)
--///////////////////////////////////	Globals	///////////////////////////////////	
global g_CryTek_magic							= 118082953114179
global g_CryTek_string 						= "CryTek"

global XMLB_BOOL								= true
global g_CryXmlB_magic 						= 48378511893504
global g_CryXmlB_string						= "CryXmlB"

global g__CONST_SIGN_length 				= 6 -- must be "CryTek" --case sensitive
global g_SkeletonList_xml_NAME 			= "Animations\\SkeletonList.xml"

global g_bs 										= undefined
global g_fname 									= ""
global g_cryFile 									= ""
global g_cryFile_m								= ""
	
global g_xml_path 								= "" --getINISetting g_iniFile "paths" "g_xml_path"

global g_auto_resourcelist_array 			= #()
global g_perlayerresourcelist_array			= #()
global g_db_type 								= 	"mtl"
global g_caller									= ""

--/* Warning - very slow for many bones in scene
-----------------------------------------------------------------------------------------
global g_deleted_nodes		=				#()
global g_deleted_meshes		=				#()

callbacks.removeScripts #nodePreDelete
------------CallBacks-----------
if g_deleted_nodes.count == 0 then
(
	--Register Callback
	callbacks.addScript #nodePreDelete " if (iskindof (callbacks.notificationParam()) BoneGeometry) then ( Append ::g_deleted_nodes (callbacks.notificationParam()).name ) " id:#bones
)
else
(
	callbacks.removeScripts #nodePreDelete id:#bones
)

if g_deleted_meshes.count == 0 then
(
	callbacks.addScript #nodePreDelete " if (iskindof (callbacks.notificationParam()) Editable_Mesh) then ( Append ::g_deleted_meshes (callbacks.notificationParam()).name ) " id:#meshes
)
else
(
	callbacks.removeScripts #nodePreDelete id:#meshes
)
-----------------------------------
-----------------------------------------------------------------------------------------
--*/

struct Sub_Meshes
(
	CA_SKIN_counter							= 0,
	CA_BONE_counter						= 0,
	
	File											= "",
		_LOADED								= #(),
	File_m										= "",
		_LOADEDm								= #(),
	
	Binding_BOOL								= false,	
	Binding										= "",	
	_Material									= "",
	
	nStream										= #(),
	nCount										= #(),	
	subMeshes 									= #(),
	SKINBONES_FROM_0xCCCC0017 		= #()
)


--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
-- global g_storedBones								= #() --for mesh2bone translation-this is temp and we will free it when done
global g_stored_CryBoneDescData_Comp 	= #() --for mesh2bone translation-this is temp and we will free it when done
--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

global Mesh_Bone_Parent_arr				=	#()

global g_test 										=	#(
																#(), 	-- 1
																#(), 	-- 2
																#(), 	-- 3
																#(), 	-- 4
																#() 	-- 5 MaterialRef
															)
															
--//------------------------------------------------------------------------------------
global g_xmlB_Parsed							=	#(
																#(), 	-- 1
																#(), 	-- 2
																#(), 	-- 3
																#(), 	-- 4
																#() 	-- 5 MaterialRef
															)
												
global g_xmlB_MatNodesSet					= #()
															
															
															
global g_xml_Parsed							=	#(
																#(), 	-- 1
																#(), 	-- 2
																#(), 	-- 3
																#(), 	-- 4
																#() 	-- 5 MaterialRef
															)
												
global g_xml_MatNodesSet					= #()
--//------------------------------------------------------------------------------------


--//------------------------------------------------------------------------------------
global g_cdf_xmlB_Parsed						=	#(
																#(), 	-- 1
																#(), 	-- 2
																#(), 	-- 3
																#(), 	-- 4
																#() 	-- 5 MaterialRef
															)
	
global g_cdf_xmlB_MatNodesSet 			= #()
--//------------------------------------------------------------------------------------


--//------------------------------------------------------------------------------------
global g_curr_MaterialRef_node_counter 	= 0
global g_MaterialRef_Parsed					=	#(
																#(), 	-- 1
																#(), 	-- 2
																#(), 	-- 3
																#(), 	-- 4
																#() 	-- 5 MaterialRef
															)
global g_MaterialRef_MatNodesSet			= #()
--//------------------------------------------------------------------------------------


--//------------------------------------------------------------------------------------
global g_MTLRef_array							= #()
global g_TEXRef_array							= #()	
--//------------------------------------------------------------------------------------

global g_NameMTL								= #(#(),#())


--Bones related
global g_BONES_ARRAY						= #()
global g_BONES_ARRAY_OLD					= #()

global g_CryGame_dropDown_selection 	= ""
												
global g_report									= #()										

------------------------------------------------------------------------	
global g_dds										= true --//--
global g_Dont_Load_Skeleton				= false
global g_skip_Lod_Materials 					= false
global g_UVW_Flip_V							= true --//--												
------------------------------------------------------------------------												
global g_xmlB_Report_v2						= false	
global g_xmlB_Debug_Report 				= false
global g_Build_Material_Report 				= false
global g_xmlB_Report							= false
global g_Mesh_Report							= false
global g_Read_Comp_cryBones_Report 	= false
global g_Create_Bones_Report				= false
global g_CDF_Report							= false
global g_Use_Skin_Wrap						= false
------------------------------------------------------------------------

--//////////////////////////////////////////////////////
global g_inst_CDF_Attribs 					= #()
global g_inst_CHRPARAMS_Attribs 			= #()

global g_assetName_From_CDF				= ""
global g_AName									= ""


--/////////////////// Global Options ////////////////////
global g_Physical_Material					= false
												
--///////////////////////////// Material Constants ////////////////////////////////////
global g_MAX_SUB_MATERIALS 				= 128

struct LOADED
(
	_cgf 			= #(),
	_cgfm 		= #(),
	
	_cga			= #(),
	_cgam		= #(),
	
	_skin 		= #(),
	_skinm 		= #(),
	
	_chr 			= #(),
	_chrm 		= #()	
)

struct LOADED_CAF
(
	_caf			= #(),
	_img			= #()
)

struct xmlB_LOADED
(
	_cgf			= #(),
	_mtl			= #(),
	_skin			= #(),
	_chr			= #(),
	_cdf			= #(),
	_chrparams	= #(),
	_default		= #()
)

------------------- Must follow the above structs, not before -------------------
global inst_LOADED 			= LOADED()
global inst_xmlB_LOADED 		= xmlB_LOADED()
global inst_LOADED_CAF		= LOADED_CAF()

global _LOADED 					= unsupplied
global _LOADEDm 				= unsupplied
global _LOADED_CAF			= unsupplied
global _LOADED_IMG			= unsupplied

--////////////////////////////////	End of Globals	////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////


fn load_global_arrays =
(
	---------CGF Loader array containers---------
	global g_ChunkTypes												= #() --new
	global g_FILE_HEADER												= #() --new
	global g_CHUNKTABLE_FILE_CONSTANTS						= #() --number of table entries (as well as the start of the first chunk entry)				
	global g_CHUNKTABLE_0744_0745								= #() --new	

	global g_SOURCE_INFO											= #() --Source Info
	global g_EXPORT_FLAGS_CHUNK_DESC						= #() --//!< Describes the source from which the cgf was exported: source max file, machine and user.
	
	global g_TIMING_CHUNK_DESC									= #() --//! Timing Chunk Header. TIMING_CHUNK_DESC_0918 and TIMING_CHUNK_DESC_0919

	global g_MTL_NAME_CHUNK_DESC								= #()
					
	global g_MESH_SUBSETS_CHUNK_DESC_0800 				= #() --each 0x0017 Mesh subset description is in here .MeshSubsetsArr contains the Subsets, it can be one, or more
	global g_ECgfStreamType 										= #() --the inst_ECgfStreamType streams
	
	global g_NODE_CHUNK_DESC_0824 							= #() --Node Chunk Header CryHeaders.h 1086
	global g_MESH_CHUNK_DESC_0801 							= #() --Compiled Mesh chunk. (info)
	
	global g_FOLIAGE_INFO_CHUNK_DESC							= #()
	global g_MESH_PHYSICS_DATA_CHUNK_DESC_0800		= #()
	
	global g_CryBoneDescData_Comp								= #()
	
	global g_BONE_ENTITY												= #()	
	---------------End of CGF Loader--------------
)

fn store_global_arrays \
								currFileType: \
								fileType1: \
								fileType2: =
(
	-----------------Store loaded information-----------------
	::inst_LOADED 			= LOADED() --test ??? (this will make new _LOADED _LOADEDm for each file - otherwise, they are all stacked in the same array)
	local inst_TYPES 		= TYPES()
	
	inst_TYPES.g_ChunkTypes													= ::g_ChunkTypes
	inst_TYPES.g_FILE_HEADER												= ::g_FILE_HEADER
	inst_TYPES.g_CHUNKTABLE_FILE_CONSTANTS						= ::g_CHUNKTABLE_FILE_CONSTANTS
	inst_TYPES.g_CHUNKTABLE_0744_0745								= ::g_CHUNKTABLE_0744_0745	
	
	inst_TYPES.g_SOURCE_INFO												= ::g_SOURCE_INFO
	inst_TYPES.g_EXPORT_FLAGS_CHUNK_DESC							= ::g_EXPORT_FLAGS_CHUNK_DESC
	
	inst_TYPES.g_TIMING_CHUNK_DESC									= ::g_TIMING_CHUNK_DESC

	inst_TYPES.g_MTL_NAME_CHUNK_DESC								= ::g_MTL_NAME_CHUNK_DESC	
	
	inst_TYPES.g_MESH_SUBSETS_CHUNK_DESC_0800					= ::g_MESH_SUBSETS_CHUNK_DESC_0800
	
	inst_TYPES.g_ECgfStreamType											= ::g_ECgfStreamType
	
	inst_TYPES.g_NODE_CHUNK_DESC_0824								= ::g_NODE_CHUNK_DESC_0824
	inst_TYPES.g_MESH_CHUNK_DESC_0801								= ::g_MESH_CHUNK_DESC_0801
	
	inst_TYPES.g_FOLIAGE_INFO_CHUNK_DESC							= ::g_FOLIAGE_INFO_CHUNK_DESC
	inst_TYPES.g_MESH_PHYSICS_DATA_CHUNK_DESC_0800		= ::g_MESH_PHYSICS_DATA_CHUNK_DESC_0800
	
	inst_TYPES.g_CryBoneDescData_Comp									= ::g_CryBoneDescData_Comp
	
	inst_TYPES.g_BONE_ENTITY												= ::g_BONE_ENTITY
	
	if  fileType1 		!= 	unsupplied AND \
		fileType2 		!= 	unsupplied AND \
		currFileType 	!= 	unsupplied then
	(
		case of
		(
			(currFileType == ".cgf"):
			(			
				Append 	::inst_LOADED._cgf			inst_TYPES
			)
			(currFileType == ".cga"):
			(			
				Append 	::inst_LOADED._cga			inst_TYPES
			)
			(currFileType == ".chr"):
			(
				Append 	::inst_LOADED._chr			inst_TYPES
			)
			(currFileType == ".skin"):
			(
				Append 	::inst_LOADED._skin			inst_TYPES
			)
			(currFileType == ".cgfm"):
			(			
				Append 	::inst_LOADED._cgfm		inst_TYPES
			)
			(currFileType == ".cgam"):
			(			
				Append 	::inst_LOADED._cgam		inst_TYPES
			)
			(currFileType == ".chrm"):
			(
				Append 	::inst_LOADED._chrm		inst_TYPES
			)
			(currFileType == ".skinm"):
			(
				Append 	::inst_LOADED._skinm		inst_TYPES
			)
			default:()		
		)
	)
-- 	--------------End of Store loaded information--------------
)

fn set_modelStates 	\
							currFileType: \
							fileType1: \
							fileType2: =
(
	if  fileType1 		!= 	unsupplied AND \
		fileType2 		!= 	unsupplied AND \
		currFileType 	!= 	unsupplied then
	(	
		case of
		(
			(fileType1 == ".cgf" AND fileType2 == ""):
			(			
				::_LOADED 				=  ::inst_LOADED._cgf
				::_LOADEDm 			=  ::inst_LOADED._cgf
			)
			(fileType1 == ".cga" AND fileType2 == ""):
			(			
				::_LOADED 				=  ::inst_LOADED._cga
				::_LOADEDm 			=  ::inst_LOADED._cga
			)
			(fileType1 == ".chr" AND fileType2 == ""):
			(
				::_LOADED 				=  ::inst_LOADED._chr
				::_LOADEDm 			=  ::inst_LOADED._chr
			)
			(fileType1 == ".skin" AND fileType2 == ""):
			(
				::_LOADED 				=  ::inst_LOADED._skin
				::_LOADEDm 			=  ::inst_LOADED._skin
			)
			(fileType1 == ".cgf" AND fileType2 == ".cgfm"):
			(			
				::_LOADED 				=  ::inst_LOADED._cgf
				::_LOADEDm 			=  ::inst_LOADED._cgfm
			)
			(fileType1 == ".cga" AND fileType2 == ".cgam"):
			(			
				::_LOADED 				=  ::inst_LOADED._cga
				::_LOADEDm 			=  ::inst_LOADED._cgam
			)
			(fileType1 == ".chr" AND fileType2 == ".chrm"):
			(
				::_LOADED 				=  ::inst_LOADED._chr
				::_LOADEDm 			=  ::inst_LOADED._chrm
			)
			(fileType1 == ".skin" AND fileType2 == ".skinm"):
			(
				::_LOADED 				=  ::inst_LOADED._skin
				::_LOADEDm 			=  ::inst_LOADED._skinm
			)		
			default: ()	
		)
	)
)


--///////////////// CAF globals and containers /////////////////
struct CAF_TYPES
(
	--Animation
	g_CAF_FILE_HEADER														= #(),
	g_CAF_CHUNKTABLE_FILE_CONSTANTS							= #(),
	g_CAF_CHUNKTABLE_0744_0745										= #(),
	g_CHUNK_GAHCAF_INFO												= #(),
	g_MotionParams905														= #(),
	g_ChunkType_BspTreeData											= #(),
	g_CONTROLLER_CHUNK_DESC_0829									= #()
)

fn load_global_CAF_arrays =
(
	---------CAF Loader array containers---------
	global g_CAF_FILE_HEADER											= #()
	global g_CAF_CHUNKTABLE_FILE_CONSTANTS					= #()
	global g_CAF_CHUNKTABLE_0744_0745							= #()
	global g_CHUNK_GAHCAF_INFO										= #()
	global g_MotionParams905											= #()
	global g_ChunkType_BspTreeData									= #()
	global g_CONTROLLER_CHUNK_DESC_0829						= #()
	---------------End of CAF Loader--------------
)
fn store_global_CAF_arrays \
										fileType: =
(	
	-----------------Store loaded information-----------------
	local inst_CAF_TYPES = CAF_TYPES()
	
	inst_CAF_TYPES.g_CAF_FILE_HEADER								= g_CAF_FILE_HEADER
	inst_CAF_TYPES.g_CAF_CHUNKTABLE_FILE_CONSTANTS		= g_CAF_CHUNKTABLE_FILE_CONSTANTS	
	inst_CAF_TYPES.g_CAF_CHUNKTABLE_0744_0745				= g_CAF_CHUNKTABLE_0744_0745
	inst_CAF_TYPES.g_CHUNK_GAHCAF_INFO							= g_CHUNK_GAHCAF_INFO
	inst_CAF_TYPES.g_MotionParams905								= g_MotionParams905
	inst_CAF_TYPES.g_ChunkType_BspTreeData						= g_ChunkType_BspTreeData
	inst_CAF_TYPES.g_CONTROLLER_CHUNK_DESC_0829			= g_CONTROLLER_CHUNK_DESC_0829
	
	if fileType != unsupplied then
	(
		case of
		(
			(fileType == ".caf")			:		(Append 	::inst_LOADED_CAF._caf			inst_CAF_TYPES)
			default:()		
		)
		case of
		(
			(fileType == ".img")			:		(Append 	::inst_LOADED_CAF._img			inst_CAF_TYPES)
			default:()		
		)
	)
	--------------End of Store loaded information--------------
)

fn set_CAF_states \
							type: =
(
	case of
	(
		(type == ".caf"):
		(			
			::_LOADED_CAF 		=  ::inst_LOADED_CAF._caf
		)
		(type == ".img"):
		(
			::_LOADED_IMG 		=  ::inst_LOADED_CAF._img
		)
		default: ()
	)
)
--/////////////// End of CAF globals and containers /////////////



struct PHYS_MAT_ADJUST
(
	spec_output_amount = 0	
)

global inst_PHYS_MAT_ADJUST = PHYS_MAT_ADJUST()

--Reset Arrays--
fn Reset_Arrays =
(	
	::_LOADED 						= unsupplied
	::_LOADEDm 					= unsupplied
	
	::g_caller									= ""

	--//------------------------------------------------------------------------------------
	::g_xmlB_Parsed							=	#(
																#(), 	-- 1
																#(), 	-- 2
																#(), 	-- 3
																#(), 	-- 4
																#() 	-- 5 MaterialRef
															)
																					
	::g_xmlB_MatNodesSet					= #()
	--//------------------------------------------------------------------------------------


	--//------------------------------------------------------------------------------------
	::g_cdf_xmlB_Parsed						=	#(
															#(), 	-- 1
															#(), 	-- 2
															#(), 	-- 3
															#(), 	-- 4
															#() 	-- 5 MaterialRef
														)
										
	::g_cdf_xmlB_MatNodesSet 			= #()
	--//------------------------------------------------------------------------------------


	--//------------------------------------------------------------------------------------
	::g_curr_MaterialRef_node_counter 	= 0
	::g_MaterialRef_Bool						= false
	::g_MaterialRef_Parsed					=	#(
															#(), 	-- 1
															#(), 	-- 2
															#(), 	-- 3
															#(), 	-- 4
															#() 	-- 5 MaterialRef
														)
	::g_MaterialRef_MatNodesSet			= #()
	--//------------------------------------------------------------------------------------


	--//------------------------------------------------------------------------------------
	::g_MTLRef_array							= #()
																							
	::g_NameMTLRef_Parsed				=	#(
															#(), 	-- 1
															#(), 	-- 2
															#(), 	-- 3
															#(), 	-- 4
															#() 	-- 5 MaterialRef
														)
	::g_NameMTLRef_MatNodesSet		= #()
																								
	::g_TEXRef_array							= #()	
	--//------------------------------------------------------------------------------------
	load_global_arrays()
	::g_xml_path = ""

														
	g_NameMTL								= #(#(),#())
		
	
	-----------------------------------------------------------------------------------------
	--//------------------------------------------------------------------------------------
	::g_MTLRef_array							= #()
	::g_TEXRef_array							= #()	
	--//------------------------------------------------------------------------------------

	::g_NameMTL								= #(#(),#())
													
	::g_report									= #()

	::g_AName									= ""
		
	::Mesh_Bone_Parent_arr				=	#()
	::g_BONES_ARRAY						= 	#()		


	if 	::g_deleted_nodes.count > 0 then
	(
		load_global_arrays()
		::g_BONES_ARRAY_OLD				= 	#()
		::g_deleted_nodes					= 	#()

		::inst_LOADED 						= LOADED()
		::inst_xmlB_LOADED 					= xmlB_LOADED()
		::inst_LOADED_CAF					= LOADED_CAF()
	)
	if ::g_deleted_meshes.count > 0 then
	(
		load_global_arrays()
		::g_BUILT_MESHES					= #()
		::g_BUILT_MESHES_sset			= #()
		
		::inst_LOADED 						= LOADED()
		::inst_xmlB_LOADED 					= xmlB_LOADED()
		::inst_LOADED_CAF					= LOADED_CAF()
		
		::g_deleted_meshes					= #()
	)
)

fn Reset_BoneNodes_arrays =
(
	::g_BONES_ARRAY						= 	#()
	::g_BONES_ARRAY_OLD					= 	#()	

	if ::g_deleted_meshes.count > 0 then
	(
		::inst_LOADED 						= LOADED()
		::inst_xmlB_LOADED 					= xmlB_LOADED()
		::inst_LOADED_CAF					= LOADED_CAF()
	)

	::Mesh_Bone_Parent_arr				=	#()
)

