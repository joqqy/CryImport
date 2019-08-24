--joqqyhez@gmail.com


--//! Chunk type must fit into uint16.
struct ChunkTypes
(
	ChunkType_ANY = 0,

	ChunkType_Mesh 						= 0xCCCC1000, 				--//!< Was 0xCCCC0000 in chunk files with versions <= 0x745.
		--ChunkType_Mesh_OLD  					= 0xCCCC0000,
		ChunkType_Mesh_OLD  				= #(#(0),#(52428)),
	ChunkType_Helper 						= 0xCCCC0001,
	ChunkType_VertAnim 					= 0xCCCC0002,
	ChunkType_BoneAnim 					= 0xCCCC0003,
	ChunkType_GeomNameList 			= 0xCCCC0004, 				--obsolete
	ChunkType_BoneNameList 				= 0xCCCC0005,
	ChunkType_MtlList 						= 0xCCCC0006,   			--obsolete
	ChunkType_MRM 							= 0xCCCC0007,   			--obsolete
	ChunkType_SceneProps 				= 0xCCCC0008,				--obsolete
	ChunkType_Light 						= 0xCCCC0009,				--obsolete
	ChunkType_PatchMesh 				= 0xCCCC000A,   			--not implemented
	--ChunkType_Node 							= 0xCCCC000B,
	ChunkType_Node 						= #(#(11),#(52428)),
	ChunkType_Mtl 							= 0xCCCC000C,          		--obsolete
	ChunkType_Controller 					= 0xCCCC000D,
	--ChunkType_Timing 							= 0xCCCC000E,
	ChunkType_Timing 						= #(#(14),#(52428)),
	ChunkType_BoneMesh 					= 0xCCCC000F,
	ChunkType_BoneLightBinding 			= 0xCCCC0010, 				--obsolete. describes the lights binded to bones
	ChunkType_MeshMorphTarget 		= 0xCCCC0011,  				--describes a morph target of a mesh chunk
	ChunkType_BoneInitialPos 				= 0xCCCC0012,  				--describes the initial position (4x3 matrix) of each bone; just an array of 4x3 matrices
	ChunkType_SourceInfo 				= #(#(19),#(52428)), 	--describes the source from which the cgf was exported: source max file, machine and user
	--ChunkType_SourceInfo 					= 0xCCCC0013, 					--describes the source from which the cgf was exported: source max file, machine and user
	--ChunkType_MtlName 						= 0xCCCC0014, 					--material name
	ChunkType_MtlName 					= #(#(20),#(52428)), 	--material name
	ChunkType_ExportFlags 				= 0xCCCC0015, 				--Special export flags.
	--ChunkType_DataStream 					= 0xCCCC0016, 					--Stream data.
	ChunkType_DataStream 				= #(#(22),#(52428)), 	--0xCCCC0016, --Stream data.
	--ChunkType_MeshSubsets 					= 0xCCCC0017, 					--Array of mesh subsets.
	ChunkType_MeshSubsets 				= #(#(23),#(52428)), 	--0xCCCC0017, --Array of mesh subsets.
	ChunkType_MeshPhysicsData 		= 0xCCCC0018, 				--Physicalized mesh data.

	--//========================================
	--//Bonelist Chunk Header
	--//========================================
	--CryHeaders.h 1033		

	--// this structure describes the bone names
	--// it's followed by numEntities packed \0-terminated strings, the list terminated by double-\0
	--these are the new compiled chunks for characters
	--ChunkType_CompiledBones 					= 0xACDC0000, --ChunkType_CompiledBones = 0x2000,    //!< Was 0xACDC0000 in chunk files with versions <= 0x745.
	ChunkType_CompiledBones 				= #(#(0),#(44252)),
	ChunkType_CompiledPhysicalBones 		= 0xACDC0001,
	ChunkType_CompiledMorphTargets 		= 0xACDC0002,
	ChunkType_CompiledPhysicalProxies 	= 0xACDC0003,
	--ChunkType_CompiledIntFaces 					= 0xACDC0004,		--pie - the Int prob stands for "Internal" and these are probably used to compute the convex hull (we are not interested in that)
	ChunkType_CompiledIntFaces 			= #(#(4),#(44252)),
	--ChunkType_CompiledIntSkinVertices 			= 0xACDC0005,
	ChunkType_CompiledIntSkinVertices 	= #(#(5),#(44252)),
	ChunkType_CompiledExt2IntMap 		= 0xACDC0006,

	ChunkType_BreakablePhysics_OLD 		= 0xAAFC0000,		--//!< Was 0xAAFC0000 in chunk files with versions <= 0x745.
	ChunkType_BreakablePhysics 			= 0xAAFC3000,		
	ChunkType_FaceMap 						= 0xAAFC0001,		--//!< Obsolete.
	ChunkType_MotionParameters 			= 0xAAFC0002,
	ChunkType_FootPlantInfo 					= 0xAAFC0003,   	--//!< Obsolete.
	ChunkType_BonesBoxes 					= 0xAAFC0004,		--p used for collision
	ChunkType_FoliageInfo 					= 0xAAFC0005,
	ChunkType_Timestamp 						= 0xAAFC0006,
	ChunkType_GlobalAnimationHeaderCAF = 0xAAFC0007,
	ChunkType_GlobalAnimationHeaderAIM = 0xAAFC0008,
	
	ChunkType_BspTreeData 					= 0xAAFC0009
)


--it's always good to read the actual code in IStreamEngine.h file for any missing information.
/*
 * The idea is that the data loaded is ready for usage and ideally doesn't need further transformation,
 * therefore the client allocates the buffer (to avoid extra copy). All the data transformations should take place in the Resource Compiler. If you have to allocate a lot of small memory objects, you should revise this strategy in favor of one big allocation (again, that will be read directly from the compiled file).
 * Anyway, we can negotiate that the streaming engine allocates this memory.
 * In the end, it could make use of a memory pool, and copying data is not the bottleneck in our engine
 *
 * The client should take care of all fast operations. Looking up file size should be fast on the virtual
 * file system in a pak file, because the directory should be preloaded in memory
 */
--Also see IindexedMesh.h 852
--Also see VertexFormats.h 102
--Also see CGFLoader.cpp
struct ECgfStreamType
(
	CGF_STREAM_POSITIONS 			= #(#(),#()),			--0
	CGF_STREAM_NORMALS 			= #(),						--1
	CGF_STREAM_TEXCOORDS 		= #(),						--2
	CGF_STREAM_COLORS 				= #(#(),#()),			--3 	RGBA - rgb and alpha --see CGFSaver.cpp 1116 *m_pColor0* refers to this chunk
	
 	--RGBA - rgb and alpha --is this used for the detail bending? see http://docs.cryengine.com/display/SDKDOC2/Detail+Bending#DetailBending-3dsMaxSetup --See CGFSaver.cpp 804 *m_pColor1* refers to this chunk
	-- this ?? VertexFormats.h 216
	CGF_STREAM_COLORS2 			= #(#(),#()),			--4 	
	CGF_STREAM_INDICES 				= #(),						--5
	CGF_STREAM_TANGENTS 			= #(),						--6		--See datastream_chunk.py 15
	CGF_STREAM__DUMMY0 			= #(),  						--7		--//!< Used to be CGF_STREAM_SHCOEFFS, dummy is needed to keep existing assets loadable.
	CGF_STREAM__DUMMY1 			= #(),  						--8		--//!< Used to be CGF_STREAM_SHAPEDEFORMATION, dummy is needed to keep existing assets loadable.
	CGF_STREAM_BONEMAPPING 		= #(),						--9
	CGF_STREAM_FACEMAP 			= #(),						--10 	
	
	--Vertex Mapping. -LoadStreamChunk<int>(mesh, chunk, CGF_STREAM_VERT_MATS, CMesh::VERT_MATS); CGFLoader.cpp 3543 
	--VERT_MATS vertex format is SVF_P3S_C4B_T2S* m_pP3S_C4B_T2S; --see IindexedMesh.h 892:
	/***** See VertexFormats.h 192
	struct SVF_P3S_C4B_T2S
	{
		Vec3f16 xyz;
		UCol    color;
		Vec2f16 st;

		AUTO_STRUCT_INFO;
	};
	******/

	/*****
	struct UCol
	{
		union
		{
			uint32 dcolor;
			uint8  bcolor[4];

			struct { uint8 b, g, r, a; };
			struct { uint8 z, y, x, w; };
		};

		//! Get normal vector from unsigned 8bit integers (can't point up/down and is not normal).
		ILINE Vec3 GetN()
		{
			return Vec3
				   (
			  (bcolor[0] - 128.0f) / 127.5f,
			  (bcolor[1] - 128.0f) / 127.5f,
			  (bcolor[2] - 128.0f) / 127.5f
				   );
		}

		AUTO_STRUCT_INFO;
	};
	*****/	
	CGF_STREAM_VERT_MATS 		= #(),						--11 	*m_pVertMats* ??? see MeshCompiler.cpp 98
	
	
	CGF_STREAM_QTANGENTS 		= #(),						--12 	--Quaternions Tangents ref: http://www.crytek.com/download/izfrey_siggraph2011.pdf - Compressed Quaternion, 8 bytes - Quat = x, y, z ; Reflection Byte = s
	CGF_STREAM_SKINDATA 			= #(),						--13
	CGF_STREAM_PS3EDGEDATA 		= #(),						--14
	CGF_STREAM_P3S_C4B_T2S 		= #(),						--15 	--//!< Used to be CGF_STREAM_PS3EDGEDATA, dummy is needed to keep existing assets loadable.
		
	CGF_STREAM_POSITIONS_HFR 	= #(#(),#()),			--16 --Homefront Revolution Modified CryEngine (also contains texcoords in the same chunk)
	
	--//!< Extra stream. Does not have a stream ID in the CGF. Its data is saved at the end of the BONEMAPPING stream.
	--//P not implemented yet --SMeshBoneMapping_uint16* m_pExtraBoneMapping; //!< Bone indices and weights for bones 5 to 8. -see IindexedMesh.896
	EXTRABONEMAPPING					= #(),                       
	
	LAST_STREAM							= #()
)

-- StatObjPhys.cpp
-- Vec3                      Tangent, Bitangent, Normal, area;


-- CGFSaver.cpp
-- 		if (mesh.m_pTangents)
-- 		{
-- 			if (bUseQTangents)
-- 			{
-- 				std::vector<SMeshQTangents> qTangents(vertexCount);
-- 				MeshTangentsFrameToQTangents(
-- 				  &mesh.m_pTangents[0], sizeof(mesh.m_pTangents[0]), vertexCount,
-- 				  &qTangents[0], sizeof(qTangents[0]));
-- 				SwapEndian(&qTangents[0], vertexCount, bSwapEndian);
-- 				chunk.nStreamChunkID[CGF_STREAM_QTANGENTS] = SaveStreamDataChunk(&qTangents[0], CGF_STREAM_QTANGENTS, vertexCount, sizeof(SMeshQTangents), bSwapEndian);
-- 			}
-- 			else
-- 			{
-- 				SwapEndian(mesh.m_pTangents, vertexCount, bSwapEndian);
-- 				chunk.nStreamChunkID[CGF_STREAM_TANGENTS] = SaveStreamDataChunk(mesh.m_pTangents, CGF_STREAM_TANGENTS, vertexCount, sizeof(SMeshTangents), bSwapEndian);
-- 				SwapEndian(mesh.m_pTangents, vertexCount, bSwapEndian);
-- 			}
-- 		}

---///////////// CGFLoader.h 97 /////////////
-- 	//old chunks
-- 	bool   ReadBoneNameList( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool   ReadMorphTargets( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool   ReadBoneInitialPos( IChunkFile::ChunkDesc* pChunkDesc  );
-- 	bool   ReadBoneHierarchy( IChunkFile::ChunkDesc* pChunkDesc );
-- 	uint32 RecursiveBoneLoader( int nBoneParentIndex, int nBoneIndex );
-- 	bool   ReadBoneMesh( IChunkFile::ChunkDesc* pChunkDesc );

-- 	//new chunks
-- 	bool ReadCompiledBones( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool ReadCompiledPhysicalBones( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool ReadCompiledPhysicalProxies( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool ReadCompiledMorphTargets(  IChunkFile::ChunkDesc* pChunkDesc );

-- 	bool ReadCompiledIntFaces( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool ReadCompiledIntSkinVertice( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool ReadCompiledExt2IntMap( IChunkFile::ChunkDesc* pChunkDesc );
-- 	bool ReadCompiledBonesBoxes( IChunkFile::ChunkDesc* pChunkDesc );

-- 	bool ReadCompiledBreakablePhysics( IChunkFile::ChunkDesc* pChunkDesc );

struct CryVertex
(
	p = point3,                 --Vec3        //!< Position vector.
	n = point3                  --Vec3        //!< Normal vector.

-- 	AUTO_STRUCT_INFO;
)

struct CryFace
(
	v0, 			-- int	//!< Vertex indices.
	v1, 			-- int	//!< Vertex indices.
	v2, 			-- int	//!< Vertex indices.

	MatID		--int	//!< Material ID.

-- 	int & operator [] (int i)            {return (&v0)[i]; }
-- 	int operator   [] (int i) const      {return (&v0)[i]; }
-- 	bool           isDegenerate () const {return v0 == v1 || v1 == v2 || v2 == v0; }

-- 	AUTO_STRUCT_INFO;
)

struct CryUV
(
	u,			--float //!< Texture coordinates.
	v			--float //!< Texture coordinates.	
	
-- 	AUTO_STRUCT_INFO;
)

struct CrySkinVtx
(
	bVolumetric 	= 0, 				--int --not sure what this does
	idx 				= point4, 		--point4 -int
	w 					= point4, 		--point4 -float	
	M 					= matrix3 0 	--Matrix33 --I don't know what this is
)

--//////////////////////////////////////////////////////////////////////////
struct CryLink
(
	BoneID,	--int
	offset,	--Vec3
	Blending	--float

-- 	AUTO_STRUCT_INFO;
)

--For Vertex Colors
struct CryIRGB
(
	r, 		--unsigned char 
	g, 	--unsigned char 
	b 		--unsigned char 
)


struct FILE_HEADER
(
	Signature 				= "",
	_pad 						= 1,
	FileType 				= 0,
	Version 					= 0,
	ChunkTableOffset 	= 0
)

struct NAME_ENTITY
(
	name --char[64]
)

-- //////////////////////////////////////////////////////////////////////////
--//=======================================
--ChunkTable File Constants (P)
--//=======================================

struct CHUNK_TABLE_0744_0745
(	
	ChunkType					= #(#(),#()),
	ChunkVersion				= #(#(),#()),
	FileOffset					= #(#(),#()),
	ChunkID						= #(#(),#()),      --//new in version 0x0745
	ChunkPlusDescr_size 	= #()	
)

-- //////////////////////////////////////////////////////////////////////////
-- // Custom Attributes chunk description.
-- //////////////////////////////////////////////////////////////////////////


-- //!< Describes the source from which the cgf was exported: source max file, machine and user.
fn read_FILE_HEADER \
								&bstream: \
								&struct2fill: \
								global_Append: \
								&STAT: =
(
	if struct2fill != unsupplied then
	(
		if struct2fill != undefined then
		(
			--pad
			for i=1 to struct2fill._pad do
			(
				readlong		 bstream
				readshort 	bstream
			)
			
			struct2fill.Version 				= readshort bstream	
				readshort 							bstream --pad
			struct2fill.ChunkTableOffset 	= readlong bstream
			
			Append global_Append struct2fill
			
			return STAT 		= true;
		)		
	)
	
	STAT = false
)

struct CHUNKTABLE_FILE_CONSTANTS
(
	tableStart = 0, --uint
	nChunkTable_entries = 0
)

fn read_CHUNKTABLE_FILE_CONSTANTS \
														&bstream: \
														&struct2read: \														
														&struct2fill: \
														global_Append: \
														&STAT: =
(	
	if struct2read != undefined then
	(
		if struct2read != unsupplied then
		(
			fseek 	bstream 	struct2read.ChunkTableOffset 	#seek_set
			struct2fill.nChunkTable_entries 		= readlong bstream
			
			struct2fill.tableStart 					= ftell bstream
			
			Append 	global_Append 	struct2fill
			
			return STAT 	= true;
		)
	)
	
	STAT = false
)

struct SOURCE_INFO
(
	source = "", --char 116
		source_count = 116
)

fn read_SOURCE_INFO \
								&bstream: \
								&fileHeader: \
								&struct2read: \
								global_Append: =

(
	for i=1 to ::g_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
	(
		if struct2read.ChunkType[1][i] == 0x0013 AND \
			struct2read.ChunkType[2][i] == 0xCCCC then
		(
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
				
			struct2fill = SOURCE_INFO() --create struct			
			struct2fill.source = ReadFixedString \
															bstream:	&bstream \
															fixedLen:	&struct2fill.source_count --fill struct
			
			Append global_Append struct2fill
		)
	)	
)

struct RANGE_ENTITY
(
	_name 					= "", --char name[32]
		_name_count 		= 32,
	
	start 						= 0, --int
	end 						= 0 --int
)

-- //! Timing Chunk Header.
struct TIMING_CHUNK_DESC_0918
(
	chunkID					 			= 0, 
	
-- 	enum { VERSION = 0x0918 };

	_obsolete_SecsPerTick 			= 0,   	--//!< Always assumed to be 1/4800. --f32
	_obsolete_TicksPerFrame 		= 0, 		--//!< Always assumed to be 160. --int32

	global_range,     --//!< Specifies time range of the animation, expressed in 'ticks' (1/4800th of a second). --struct RANGE_ENTITY  (see above)

	_obsolete_SubRanges 			= 0 		--int32
)

-- //! Describes timing attributes of evenly sampled motion data. Used in .i_caf files.
struct TIMING_CHUNK_DESC_0919
(
	chunkID					 			= 0, 
	
-- 	enum { VERSION = 0x0919 };

	numberOfSamples 				= 0,      --//!< Shall be >= 1. --int32
	samplesPerSecond 				= 0,      --//!< Shall be > 0. --float
	startTimeInSeconds 				= 0		--float
)

fn read_ChunkTable_0744_0745 \
											&bstream: \
											&struct2read_A: \
											&struct2read_B: \
											&struct2fill: \
											global_Append: \
											&STAT: =
(	
	if struct2read_A != undefined then
	(
		if struct2read_A != unsupplied then
		(
			if struct2read_A.Version == 0x744 OR \
				struct2read_A.Version == 0x745 then
			(	
				fseek bstream struct2read_B.tableStart #SeekSet
				
				for i=1 to struct2read_B.nChunkTable_entries do
				(
					--format "-------------------Begin reading table 0x745 here: %\n" (ftell bstream)
					
					Append struct2fill.ChunkType[1] (readshort bstream #unsigned)
					Append struct2fill.ChunkType[2] (readshort bstream #unsigned)
					
					Append struct2fill.ChunkVersion[1] (readshort bstream #unsigned)
					Append struct2fill.ChunkVersion[2] (readshort bstream #unsigned)
					
					Append struct2fill.FileOffset[1] (readlong bstream) --the offset we will read normally (not divided in high and low)		
					
					--Note, the ID for the chunks is new for version 0x745 !
					if struct2read_A.Version == 0x745 then
					(
						Append struct2fill.ChunkID[1] (readlong bstream) --read normally	
					)
					
					Append struct2fill.ChunkPlusDescr_size (readlong bstream) --the whole chunk size, including the chunk description
				)
				
				Append global_Append struct2fill
				return STAT = true;
			)
		)
	)
	
	STAT = false
)

-- //========================================
-- //Material Chunk Header
-- //========================================

-- #define MTL_NAME_CHUNK_DESC_0800_MAX_SUB_MATERIALS (32)
struct MTL_NAME_CHUNK_DESC_0800
(
	type 									= 0x0014,		--confirm 0x0014
	version 								= 0x0800,	
	chunkID								= 0,
	
-- 	enum {VERSION = 0x0800};
-- 	enum EFlags
-- 	{
-- 		FLAG_MULTI_MATERIAL = 0x0001, //!< Have sub materials info.
-- 		FLAG_SUB_MATERIAL   = 0x0002, //!< This is sub material.
-- 		FLAG_SH_COEFFS      = 0x0004, //!< This material should get spherical harmonics coefficients computed.
-- 		FLAG_SH_2SIDED      = 0x0008, //!< This material will be used as 2 sided in the sh precomputation.
-- 		FLAG_SH_AMBIENT     = 0x0010, //!< This material will get an ambient sh term(to not shadow it entirely).
-- 	};	

	nFlags 								= 0,                   --//!< See EFlags.	--int
	nFlags2 								= 0, 					--int
	_name 								= "",                --//!< Material/shader name. char  name[128];
		_name_count 					= 128,
	nPhysicalizeType 					= 0,	--int
	nSubMaterials 						= 0, --int
	nSubMatChunkId 					= #(), --int   nSubMatChunkId[MTL_NAME_CHUNK_DESC_0800_MAX_SUB_MATERIALS];
		nSubMatChunkId_count 	= 32,
	nAdvancedDataChunkId 		= 0, --int
	sh_opacity 							= 0, --float
	reserve 								= #(), --int   reserve[32]
		reserve_count 				= 32
)

struct MTL_NAME_CHUNK_DESC_0802
(
	type 									= 0x0014,		--confirm 0x0014
	version 								= 0x0802, 	--check that it is 0x0802
	chunkID								= 0,
	
	_name 								= "", --char[128]
		_name_count 					= 128, --chars
	nSubmaterials 						= 0, --int,
	unknown 							= 0 --int(?) -padding probably	
	
	--cryinfo
	--// Data continues from here.
	--// 1) if nSubMaterials is 0, this is a single-material: we store physicalization type of the material (int32).
	--// 2) if nSubMaterials is not 0, this is a multi-material: we store nSubMaterials physicalization types (int32
	--//    value for each sub-material). After the physicalization types we store chain of ASCIIZ names of sub-materials.
)

fn read_MTL_NAME_CHUNK_DESC_0800 \
														&bstream: \
														&struct2fill: =
(
	struct2fill.nFlags 					= readlong bstream
	struct2fill.nFlags2 				= readlong bstream						
						
	struct2fill._name = ReadFixedString \
														bstream:	&bstream \
														fixedLen:	&struct2fill._name_count
						
	struct2fill.nPhysicalizeType 	= readlong bstream
	struct2fill.nSubMaterials 		= readlong bstream
						
	for i=1 to struct2fill.nSubMatChunkId_count do
	(
		Append struct2fill.nSubMatChunkId (readlong bstream)
	)
						
	struct2fill.nAdvancedDataChunkId 	= readlong bstream
	struct2fill.sh_opacity 					= readfloat bstream
						
	for i=1 to struct2fill.reserve_count do
	(
		readlong bstream
	)			
)

fn read_MTL_NAME_CHUNK_DESC_0802 \
														&bstream: \
														&struct2fill: =
(
	struct2fill._name = ReadFixedString \
														bstream:	&bstream \
														fixedLen:	&struct2fill._name_count
						
	struct2fill.nSubmaterials = readlong bstream
	struct2fill.unknown = readlong bstream
						
	--pad
	readlong bstream -- this is probably always 0xFFFFFF
)

--//////////////////////////////// Unused yet ///////////////////////////////

--See CryHeaders.h 754
-- //! Bonelist Chunk Header.
-- //! This structure describes the bone names.
-- //! It's followed by numEntities packed \0-terminated strings, the list terminated by double-\0.
struct BONENAMELIST_CHUNK_DESC_0745
(
-- 	enum {VERSION = 0x0745};
	numEntities = 0 --int
)

struct COMPILED_BONE_CHUNK_DESC_0800
(
-- 	enum {VERSION=0x0800};

	reserved 				= #(),  	--char reserved[32];
		reserved_length 	= 64 		--64 bytes chunk
)
--////////////////////////End of Unused yet /////////////////////////////////


--See CryHeaders.h 181
-- 	--//! The compatible between 32- and 64-bits structure.
-- struct CryBonePhysics_Comp
-- {
-- 	int nPhysGeom;            //!< Id of a separate mesh for this bone.
-- 	// additional joint parameters.
-- 	int   flags;
-- 	float min[3],max[3];
-- 	float spring_angle[3];
-- 	float spring_tension[3];
-- 	float damping[3];
-- 	float framemtx[3][3];

-- 	AUTO_STRUCT_INFO;
-- };

--0xACDC0000 See CryHeaders.h 254
struct CryBoneDescData_Comp
(
	_filePos							= 0, --pie
	
	chunkID							= 0,
	
	reserved 						= 32,		--char reserved[32];
	
	m_nControllerID 				= 0, 		--unsigned int --// unic id of bone (generated from bone name in the max)

	--// Physics info for different LOD.
	--// LOD 0 is the physics of alive body, LOD 1 is the physics of a dead body.	
	m_PhysInfo_length 			= 2,
	
	
	-- ////////////////// (struct) --CryBonePhysics_Comp m_PhysInfo[2]; //////////////////	
		nPhysGeom 				= 0, 		--int --// id of a separate mesh for this bone
		--// additional joint parameters
		flags 							= 0, 		--int
		
		_min_length 				= 3,
		_min 							= #(), 	--array of float
		
		_max_length 				= 3,
		_max 						= #(), 	--array of float
		
		spring_angle_length 		= 3,
		spring_angle 				= #(), 	--array of float
		
		spring_tension_length 	= 3,
		spring_tension 			= #(), 	--array of float
		
		damping_length 			= 3,
		damping 					= #(), 	--array of float
		
		framemtx_length 			= 3,
		framemtx 					= #(#(), #(), #()), --3D array of float --float framemtx[3][3]
	-- ///////////////////////////////////////////////////////////////////////////////////
		
	
	m_fMass 						= 0.0, 			--float
	
	m_DefaultW2B 				= Matrix3 1, 	--Matrix34 	--//!< Intitalpose matrix World2Bone. 	--set to identity matrix
	m_DefaultB2W 				= Matrix3 1, 	--Matrix34 	--//!< Intitalpose matrix Bone2World. 	--set to identity matrix
	
	--m_DefaultW2B 				= BigMatrix 4 4,
	--m_DefaultB2W 				= BigMatrix 4 4,	

	m_arrBoneName_length 	= 256,
	m_arrBoneName 				= "",

	m_nLimbId 						= 0, 				--int  --//!< Set by model state class.

	--//! This bone parent is this[m_nOffsetParent], 0 if the bone is root. Normally this is <= 0.
	m_nOffsetParent 				= 0, 				--int

	--// The whole hierarchy of bones is kept in one big array that belongs to the ModelState
	--// Each bone that has children has its own range of bone objects in that array,
	--// and this points to the beginning of that range and defines the number of bones.
	m_numChildren 				= 0, 				--unsigned  int
	
	--// the beginning of the subarray of children is at this[m_nOffsetChildren]
	--// this is 0 if there are no children
	m_nOffsetChildren 			= 0 				--int
)

--Here we read the mtl info
fn read_CHUNK_0x0014 \
									&bstream: \
									&fileHeader: \
									&struct2read: \
									&global_Append: =
(
	--for i=1 to struct2read.ChunkType[1].count do
	for i=1 to g_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
	(
		if struct2read.ChunkType[1][i] == 0x0014 AND \
			struct2read.ChunkType[2][i] == 0xCCCC then
		(		
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0800 then --if Ox0800
			(
				struct2fill = MTL_NAME_CHUNK_DESC_0800()
				
				A 	= readshort bstream #unsigned --should be 0x0014
				B 	= readshort bstream #unsigned --should be 0xCCCC
				C 	= readshort bstream --should be 0x0800				
					D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 	= readlong bstream #unsigned
				ID = 0
				
				if fileHeader.version == 0x0745 then
				(
					ID = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A == 0x0014 AND \
						B == 0xCCCC AND \			
						C == 0x0800 AND \
						ID == struct2read.ChunkID[1][i] AND \
						F == struct2read.FileOffset[1][i] then
					(	
						--Store the Chunk ID
						struct2fill.chunkID = ID
						
						read_MTL_NAME_CHUNK_DESC_0800 \
																			bstream:	&bstream \
																			struct2fill:	&struct2fill
					)
				)
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x0014 AND \
						B == 0xCCCC AND \			
						C == 0x0800 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						read_MTL_NAME_CHUNK_DESC_0800 \
																			bstream:	&bstream \
																			struct2fill:	&struct2fill
					)
				)
			)
			else if struct2read.ChunkVersion[1][i] == 0x0802 then --if 0x0802
			(
				struct2fill = MTL_NAME_CHUNK_DESC_0802()
				
				A 	= readshort bstream #unsigned --should be 0x0014
				B 	= readshort bstream #unsigned --should be 0xCCCC
				C 	= readshort bstream --should be 0x0802				
					D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 	= readlong bstream #unsigned
				ID = 0
				
				if fileHeader.version == 0x0745 then
				(
					ID = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A == 0x0014 AND \
						B == 0xCCCC AND \			
						C == 0x0802 AND \
						ID == struct2read.ChunkID[1][i] AND \
						F == struct2read.FileOffset[1][i] then
					(		
						--Store the Chunk ID
						struct2fill.chunkID = ID
						
						read_MTL_NAME_CHUNK_DESC_0802 \
																			bstream:	&bstream \
																			struct2fill:	&struct2fill
					)
				)
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x0014 AND \
						B == 0xCCCC AND \			
						C == 0x0802 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						read_MTL_NAME_CHUNK_DESC_0802 \
																			bstream:	&bstream \
																			struct2fill:	&struct2fill
					)
				)				
			)
			
			Append 		global_Append 	struct2fill
		)
	)
)

struct EXPORT_FLAGS_CHUNK_DESC --0x0013 
(
	chunkID									= 0,
	
-- 	enum {VERSION = 0x0001};
-- 	enum EFlags
-- 	{
-- 		MERGE_ALL_NODES          = 0x0001,
-- 		HAVE_AUTO_LODS           = 0x0002,
-- 		USE_CUSTOM_NORMALS       = 0x0004,
-- 		WANT_F32_VERTICES        = 0x0008,
-- 		EIGHT_WEIGHTS_PER_VERTEX = 0x0010,
-- 	};
-- 	enum ESrcFlags
-- 	{
-- 		FROM_MAX_EXPORTER = 0x0000,
-- 		FROM_COLLADA_XSI  = 0x1001,
-- 		FROM_COLLADA_MAX  = 0x1002,
-- 		FROM_COLLADA_MAYA = 0x1003,
-- 	};

	flags 										= 0,                 --//!< @see EFlags --uint
	rc_version 								= #(),         --//!< Resource compiler version. --unsigned int rc_version[4] --uint
		rc_version_count 				= 4,
	
	rc_version_string 					= "", --//!< Version as a string.    --char         rc_version_string[16]
		rc_version_string_count		= 16,
		
	assetAuthorTool 						= 0, --uint
	authorToolVersion 					= 0, --uint
	reserved 								= #(), 			--unsigned int reserved[30]
		reserved_count					= 30
	
)


fn fill_EXPORT_FLAGS_CHUNK_DESC \
													bstream \
													struct2fill =
(
	struct2fill.flags = readlong bstream #unsigned
	
	for i=1 to struct2fill.rc_version_count do
	(
		Append struct2fill.rc_version (readlong bstream #unsigned)
	)

	struct2fill.rc_version_string = ReadFixedString \
																	bstream:	&bstream \
																	fixedLen:	&struct2fill.rc_version_string_count
	
	struct2fill.assetAuthorTool = readlong bstream #unsigned
	struct2fill.authorToolVersion = readlong bstream #unsigned

	for i=1 to struct2fill.reserved_count do
	(
		readlong bstream #unsigned
	)	
)

fn read_EXPORT_FLAGS_CHUNK_DESC \
													&bstream: \
													&fileHeader: \
													&struct2read: \
													global_Append: =
(
	--for i=1 to struct2read.ChunkType[1].count do
	for i=1 to g_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
	(
		if struct2read.ChunkType[1][i] == 0x0015 AND \
			struct2read.ChunkType[2][i] == 0xCCCC then
		(
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0001 then --if Ox0001
			(
				struct2fill = EXPORT_FLAGS_CHUNK_DESC()
				
				A 	= readshort bstream #unsigned --should be 0x0015
				B 	= readshort bstream #unsigned --should be 0xCCCC
				C 	= readshort bstream --should be 0x0001				
					D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 	= readlong bstream #unsigned
				ID = 0
				
				if fileHeader.version == 0x0745 then
				(
					ID = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A == 0x0015 AND \
						B == 0xCCCC AND \			
						C == 0x0001 AND \
						ID == struct2read.ChunkID[1][i] AND \
						F == struct2read.FileOffset[1][i] then
					(	
						--Store the Chunk ID
						struct2fill.chunkID = ID
						
						fill_EXPORT_FLAGS_CHUNK_DESC \
																		bstream \
																		struct2fill
					)
				)
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x0015 AND \
						B == 0xCCCC AND \			
						C == 0x0001 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						fill_EXPORT_FLAGS_CHUNK_DESC \
																		bstream \
																		struct2fill
					)
				)
				
				Append 		global_Append 	struct2fill
			)			
		)
	)
)

-- //! Contain array of mesh subsets.
-- //! Each subset holds an info about material id, indices ranges etc...
struct MESH_PHYSICS_DATA_CHUNK_DESC_0800
(
	chunkID							= 0,
	
-- 	enum {VERSION = 0x0800};

	nDataSize 						= 0,          		--//!< Size of physical data at the end of the chunk. --int
	nFlags 							= 0,						--int
	nTetrahedraDataSize 		= 0,	--int
	nTetrahedraChunkId 		= 0, 	--//!< Chunk of physics Tetrahedra data. --int
	reserved 						= #(),				--int reserved[2]
		reserved_count 			= 2,

-- 	// Data starts here at the end of the chunk.
-- 	//char physicsData[nDataSize];
-- 	//char tetrahedraData[nTetrahedraDataSize];
	
	physicsData 					= "",
	tetrahedraData 				= ""
)

fn fill_MESH_PHYSICS_DATA_CHUNK_DESC \
															bstream \
															struct2fill =
(
	struct2fill.nDataSize 				= readlong bstream
	struct2fill.nFlags 						= readlong bstream
	struct2fill.nTetrahedraDataSize 	= readlong bstream
	struct2fill.nTetrahedraChunkId 	= readlong bstream
	
	for i=1 to struct2fill.reserved_count do
	(
		readlong bstream
	)
	
	struct2fill.physicsData 		= ReadFixedString \
																	bstream:	&bstream \
																	fixedLen:	&struct2fill.nDataSize
	
	struct2fill.tetrahedraData 	= ReadFixedString \
																	bstream:	&bstream \
																	fixedLen:	&struct2fill.nTetrahedraDataSize
)


-- ////////////////////////////////////////////////////////////////////////// see CryHeaders.h 99
-- enum EPhysicsGeomType
-- {
-- 	PHYS_GEOM_TYPE_NONE       = -1,
-- 	PHYS_GEOM_TYPE_DEFAULT    = 0x1000 + 0,
-- 	PHYS_GEOM_TYPE_NO_COLLIDE = 0x1000 + 1,
-- 	PHYS_GEOM_TYPE_OBSTRUCT   = 0x1000 + 2,

-- 	PHYS_GEOM_TYPE_DEFAULT_PROXY = 0x1000 + 0x100, //!< Default physicalization, but only proxy (NoDraw geometry).
-- };

--See CryHeaders.h 536
-- struct MTL_NAME_CHUNK_DESC_0802
-- {
-- 	enum {VERSION = 0x0802};

-- 	char name[128];                 //!< Material/shader name.
-- 	int  nSubMaterials;

-- 	// Data continues from here.
-- 	// 1) if nSubMaterials is 0, this is a single-material: we store physicalization type of the material (int32).
-- 	// 2) if nSubMaterials is not 0, this is a multi-material: we store nSubMaterials physicalization types (int32
-- 	//    value for each sub-material). After the physicalization types we store chain of ASCIIZ names of sub-materials.

-- 	AUTO_STRUCT_INFO;
-- };


--See CryHeaders.h 709
-- //! Contain array of mesh subsets.
-- //! Each subset holds an info about material id, indices ranges etc...
-- struct MESH_PHYSICS_DATA_CHUNK_DESC_0800
-- {
-- 	enum {VERSION = 0x0800};

-- 	int nDataSize;          //!< Size of physical data at the end of the chunk.
-- 	int nFlags;
-- 	int nTetrahedraDataSize;
-- 	int nTetrahedraChunkId; //!< Chunk of physics Tetrahedra data.
-- 	int reserved[2];

-- 	// Data starts here at the end of the chunk.
-- 	//char physicsData[nDataSize];
-- 	//char tetrahedraData[nTetrahedraDataSize];

-- 	AUTO_STRUCT_INFO;
-- };

fn read_MESH_PHYSICS_DATA_CHUNK_DESC_0800 \
																		&bstream: \
																		&fileHeader: \
																		&struct2read: \
																		global_Append: =
(
	--for i=1 to struct2read.ChunkType[1].count do
	for i=1 to g_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
	(
		if struct2read.ChunkType[1][i] == 0x0018 AND \
			struct2read.ChunkType[2][i] == 0xCCCC then
		(
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0800 then --if 0x0800
			(
				struct2fill = MESH_PHYSICS_DATA_CHUNK_DESC_0800()
				
				A 	= readshort bstream #unsigned --should be 0x0018
				B 	= readshort bstream #unsigned --should be 0xCCCC
				C 	= readshort bstream --should be 0x0800				
					D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 	= readlong bstream #unsigned
				ID = 0
				
				if fileHeader.version == 0x0745 then
				(
					ID = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A == 0x0018 AND \
						B == 0xCCCC AND \			
						C == 0x0800 AND \
						ID == struct2read.ChunkID[1][i] AND \
						F == struct2read.FileOffset[1][i] then
					(		
						--Store the Chunk ID
						struct2fill.chunkID = ID
						
						fill_MESH_PHYSICS_DATA_CHUNK_DESC \
																				bstream \
																				struct2fill
					)
				)
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x0018 AND \
						B == 0xCCCC AND \			
						C == 0x0800 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						fill_MESH_PHYSICS_DATA_CHUNK_DESC \
																				bstream \
																				struct2fill
					)
				)
				
				Append 		global_Append 	struct2fill
			)			
		)
	)
)

fn fill_RANGE_ENTITY \
								bstream \
								struct2fill =
(
	struct2fill._name = ReadFixedString \
													bstream:	&bstream \
													fixedLen:	&struct2fill._name_count
	
	struct2fill.start = readlong bstream
	struct2fill.end = readlong bstream
)

fn fill_TIMING_CHUNK_DESC_0918 \
												bstream \
												struct2fill =
(
	struct2fill._obsolete_SecsPerTick = readfloat bstream --f32	
	struct2fill._obsolete_TicksPerFrame = readlong bstream --int32
	
	struct2fill.global_range = RANGE_ENTITY()	
	fill_RANGE_ENTITY \
								bstream \
								struct2fill.global_range
	

	struct2fill._obsolete_SubRanges = ReadDouble bstream --int32	
)

fn fill_TIMING_CHUNK_DESC_0919 \
												bstream \
												struct2fill =
(
	struct2fill._obsolete_SecsPerTick = readfloat bstream --f32	
	struct2fill._obsolete_TicksPerFrame = readlong bstream --int32
	
	struct2fill.global_range = RANGE_ENTITY()	
	fill_RANGE_ENTITY \
								bstream \
								struct2fill.global_range
	

	struct2fill._obsolete_SubRanges = ReadDouble bstream --int32	
)

fn read_TIMING_CHUNK_DESC_0918 \
													&bstream: \
													&fileHeader: \
													&struct2read: 
													global_Append: =
(
	--for i=1 to struct2read.ChunkType[1].count do
	for i=1 to g_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
	(
		if struct2read.ChunkType[1][i] == 0x000E AND \
			struct2read.ChunkType[2][i] == 0xCCCC then
		(
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0918 then --if 0x0918
			(
				struct2fill = TIMING_CHUNK_DESC_0918()
				
				A 	= readshort bstream #unsigned --should be 0x000E
				B 	= readshort bstream #unsigned --should be 0xCCCC
				C 	= readshort bstream --should be 0x0918				
					D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 	= readlong bstream #unsigned
				ID = 0
				
				if fileHeader.version == 0x0745 then
				(
					ID = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A == 0x000E AND \
						B == 0xCCCC AND \			
						C == 0x0918 AND \
						ID == struct2read.ChunkID[1][i] AND \
						F == struct2read.FileOffset[1][i] then
					(	
						struct2fill.chunkID = ID
						
						fill_TIMING_CHUNK_DESC_0918 \
																	bstream \
																	struct2fill
					)
				)
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x000E AND \
						B == 0xCCCC AND \			
						C == 0x0918 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						fill_TIMING_CHUNK_DESC_0918 \
																	bstream \
																	struct2fill
					)
				)
			)
			else if struct2read.ChunkVersion[1][i] == 0x0919 then --if 0x0001
			(
				struct2fill = TIMING_CHUNK_DESC_0919()
				
				A 	= readshort bstream #unsigned --should be 0x000E
				B 	= readshort bstream #unsigned --should be 0xCCCC
				C 	= readshort bstream --should be 0x0919				
					D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 	= readlong bstream #unsigned
				ID = 0
				
				if fileHeader.version == 0x0745 then
				(
					ID = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A == 0x000E AND \
						B == 0xCCCC AND \			
						C == 0x0919 AND \
						ID == struct2read.ChunkID[1][i] AND \
						F == struct2read.FileOffset[1][i] then
					(		
						struct2fill.chunkID = ID
						
						fill_TIMING_CHUNK_DESC_0919 \
																	bstream \
																	struct2fill
					)
				)
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x000E AND \
						B == 0xCCCC AND \			
						C == 0x0919 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						fill_TIMING_CHUNK_DESC_0919 \
																	bstream \
																	struct2fill
					)
				)				
			)			
			Append 	global_Append struct2fill
		)
	)
)

--See CryHeaders.h 670
struct MeshSubset
(
	nFirstIndexId 			= 0,
	nNumIndices 			= 0,
	nFirstVertId 			= 0,
	nNumVerts 				= 0,
	nMatID 					= 0, --//!< Material sub-object Id.
	fRadius 					= 0, --float
	vCenter 					= point3 --float[3] point3,
-- 		unknown 				= 0 --int
)

--See CryHeaders.h 683
struct MeshBoneIDs
(
	numBoneIDs 				= 0, 		--uint32
	arrBoneIDs 					= #(),	--uint16
		arrBoneIDs_length 	= 0x80	
)

--See CryHeaders.h 691
struct MeshSubsetTexelDensity
(
	texelDensity = 0 --float
)

--Cryheaders.h 655
--This is used to read the Subset Chunk Desc at 0xCCCC0017
struct MESH_SUBSETS_CHUNK_DESC_0800
(
	chunkID 									= 0,
	
	type 											= 0x0017,
	version 										= 0x0800,
	
	nFlags 										= 0,
-- 	enum EFlags
-- 	{
-- 		SH_HAS_DECOMPR_MAT      			= 0x0001, //!< Obsolete.
-- 		BONEINDICES              				= 0x0002,
-- 		HAS_SUBSET_TEXEL_DENSITY 	= 0x0004,
-- 	};
	nCount 										= 0, --Meshcount
		reserved 								= 2, --int --pad
	
	----------------------------------HFR------------------------------------
	matrix_HFR									= matrix3 1, --HomeFront 2 - *HFR*
	point3_HFR									= point3 0 0 0,
	------------------------------End of HFR---------------------------------
	
	MeshSubsetsArr 							= #(),
	ChunkHeadersArr 							= #(),	
	
	MeshBoneIDs 								= 0, --if the mesh has bones, then this will be assigned the filled struct struct MeshBoneIDs (see the struct just above)
	MeshBoneSubsetsArr 					= #(),
	
	MeshSubsetTexelDensity 				= 0
	
)

----------------------------------------------
--//! Stream chunk contains data about a mesh data stream (positions, normals, etc...).
struct STREAM_DATA_CHUNK_DESC_0800
(
	chunkID								= 0,
	
	type 									= 0x0016,
	version 								= 0x0800,
	
	EFlags 								= #(), 			--Not implemented
	
	nFlags 								= 0,				--int
	nStreamType 						= 0,              --int //!< Stream type one of ECgfStreamType.
	nCount 								= 0,              --int //!< Number of elements.
	nElementSize 						= 0,              --int //!< Element Size.
	reserved 							= 2				--int

	--//! Data starts here at the end of the chunk.
	--//! char streamData[nCount*nElementSize];
)


-- //========================================
-- //Node Chunk Header
-- //========================================
--CryHeaders.h 586

--//! Compiled Mesh chunk -- that is the 0xCCCC0000
--WIP because I do not know what everything is here
-- //! Compiled Mesh chunk.
struct MESH_CHUNK_DESC_0801
(
-- 	//! Versions 0x0800 and 0x0801 are *exactly* the same.
-- 	//! Version number was increased from 0x0800 to 0x0801 just because
-- 	//! it was the only way to inform *old* (existing) executables that
-- 	//! NODE_CHUNK_DESC(!) chunk format was changed and cannot be read
-- 	//! by them (old CLoaderCGF::LoadNodeChunk() didn't check
-- 	//! NODE_CHUNK_DESC's version number).
-- 	enum {VERSION = 0x0801};
-- 	enum {COMPATIBLE_OLD_VERSION = 0x0800};

-- 	enum EFlags
-- 	{
-- 		MESH_IS_EMPTY           = 0x0001, //!< Empty mesh (no streams are saved).
-- 		HAS_TEX_MAPPING_DENSITY = 0x0002, //!< texMappingDensity contains a valid value.
-- 		HAS_EXTRA_WEIGHTS       = 0x0004, //!< The weight stream will have weights for influences 5-8.
-- 		HAS_FACE_AREA           = 0x0008, //!< geometricMeanFaceArea contains a valid value.
-- 	};

	nFlags 					= 0,             --//!< @see EFlags
	nFlags2 					= 0,

-- 	// Just for info.
	nVerts 					= 0,             --//!< Number of vertices.
	nIndices 				= 0,             --//!< Number of indices.
	nSubsets 				= 0,             --//!< Number of mesh subsets.

	nSubsetsChunkId 	= 0,             --//!< Chunk id of subsets. (Must be ChunkType_MeshSubsets) (pie-meaning, in the file table chunk, this id, is that of the 0xCCCC0017)
	nVertAnimID 			= 0,             --//!< id of the related vertAnim chunk if present. otherwise it is -1

-- 	//! ChunkIDs of data streams (Must be ChunkType_DataStream).
-- 	//! Index is one of ECgfStreamType values.
--	pie - meaning that, the values here, are the ChunkIDs of the table, and their position here in this Array, are the index of the
--	enum ECgfStreamType struct, see CryHeaders.h 78
	nStreamChunkID						= #(), 			--int nStreamChunkID[16];
		nStreamChunkID_count 		= 16,

-- 	//! Chunk IDs of physical mesh data. (Must be ChunkType_MeshPhysicsData).
	nPhysicsDataChunkId 				= #(), 			--int nPhysicsDataChunkId[4]
		nPhysicsDataChunkId_count 	= 4,

-- 	//! Bounding box of the mesh.
	bboxMin 								= point3, 		--Vec3 bboxMin --point3
	bboxMax 								= point3, 		--Vec3 bboxMax --point3

	texMappingDensity 					= 0, 		--float
	geometricMeanFaceArea 			= 0, 		--float
	reserved 								= #(), 	--int   reserved[31]
		reserved_count 					= 31
)

struct MESH_CHUNK_DESC_0745
(
-- 	//! Versions 0x0744 and 0x0745 are *exactly* the same.
-- 	//! Version number was increased from 0x0744 to 0x0745 just because
-- 	//! it was the only way to inform *old* (existing) executables that
-- 	//! NODE_CHUNK_DESC(!) chunk format was changed and cannot be read
-- 	//! by them (old CLoaderCGF::LoadNodeChunk() didn't check.
-- 	//! NODE_CHUNK_DESC's version number).
	
-- 	enum {VERSION = 0x0745};
-- 	enum {COMPATIBLE_OLD_VERSION = 0x0744};

-- 	enum EFlags1
-- 	{
-- 		FLAG1_BONE_INFO = 0x01,
-- 	};
-- 	enum EFlags2
-- 	{
-- 		FLAG2_HAS_VERTEX_COLOR = 0x01,
-- 		FLAG2_HAS_VERTEX_ALPHA = 0x02,
-- 		FLAG2_HAS_TOPOLOGY_IDS = 0x04,
-- 	};
	
	flags1 			= 0, --unsigned char 
	flags2 			= 0, --unsigned char
	nVerts 			= 0, --int
	nTVerts 			= 0, --int             --//!< Number of texture vertices (0 or nVerts).
	nFaces 			= 0, --int
	VertAnimID 	= 0 --int         --//!< Id of the related vertAnim chunk if present. otherwise it is -1.
)

struct NODE_CHUNK_DESC_0824
(
	
-- 	//! Versions 0x0823 and 0x0824 have exactly same layout.
-- 	//! The only difference between 0x0823 and 0x0824 is that some members.
-- 	//! are now named _obsoleteXXX_ and are not filled/used in 0x0824.
-- 	enum {VERSION = 0x0824};
-- 	enum {COMPATIBLE_OLD_VERSION = 0x0823};

	_name = "",	--char[64]

	ObjectID 	= 0,     		 	--//!< ID of this node's object chunk (if present). --int
	ParentID 	= 0,     			--//!< Chunk ID of the parent node's chunk. --int
	nChildren 	= 0,      		--//!< Number of child nodes. --int
	MatID 		= 0,      		--//!< Material chunk number. --int --pie-This is probably the number of 0xCCCC0014 instances in the chunk

	_obsoleteA_ 					= #(),  --//!< uint8 IsGroupHead; uint8 IsGroupMember; uint8 _padding_[2]. not used anymore. --uint8 _obsoleteA_[4] uint8
		_obsoleteA_count 		= 4,
	
	tm 								= matrix3 0,  --//!< Transformation matrix. -float tm[4][4]

	-----------------------------------------------
	pos 						= point3,   			--//!< Position component of the matrix, stored as Vec3. not used anymore. --float _obsoleteB_[3]
	_obsoleteB_count 	= 3,   		
	
	rot 						= quat 0 0 0 1,   --//!< Rotation component of the matrix, stored as CryQuat. not used anymore. --float _obsoleteC_[4]
	_obsoleteC_count 	= 4,  
	
	scl 						= point3,   			--//!< Scale component of the matrix, stored as Vec3. not used anymore. --float _obsoleteD_[3]
	_obsoleteD_count 	= 3, 
	------------------------------------------------

	pos_cont_id 					= 0,         	--//!< Position controller chunk id. --int
	rot_cont_id 					= 0,        	--//!< Rotation controller chunk id. --int
	scl_cont_id 					= 0,       	--//!< Scale controller chunk id. --int

	PropStrLen 						= 0         	--//!< Length of the property string. --int
)

struct FOLIAGE_INFO_CHUNK_DESC
(
-- 	enum {VERSION = 0x0001};

	nSpines 			= 0, --int
	nSpineVtx 		= 0, --int
	nSkinnedVtx 	= 0, --int
	nBoneIds 		= 0 --int
)

fn read_CGF_STREAM_POSITIONS \
												&bstream: \
												&struct2read: \
												&info_MeshSubset: \
												&StreamStruct2fill: =
(
	local game = ::cryImport.ddl_CryGame.selected
	
	if game == "Ryse" then
	(
		if struct2read.nStreamType == 0x00000000 then
		(
			if struct2read.nElementSize == 8 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (	readHalfFloat bstream:&bstream	)
					local y = (	readHalfFloat bstream:&bstream	)
					local z = (	readHalfFloat bstream:&bstream	)
															
					local w = (	readHalfFloat bstream:&bstream	) --Probably the MatID for the mesh with these vertices (but not sure)
															
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[2] w --this is always 1.0 so far in my tests (but what is it for?)
				)
			)
			else if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)					
					
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
				)
			)
		)
	)
	else if game == "Crysis" then
	(
		if struct2read.nStreamType == 0x00000000 then
		(
			if struct2read.nElementSize == 8 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (	readHalfFloat bstream:&bstream	)
					local y = (	readHalfFloat bstream:&bstream	)
					local z = (	readHalfFloat bstream:&bstream	)
															
					local w = (	readHalfFloat bstream:&bstream	) --Probably the MatID for the mesh with these vertices (but not sure)
															
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[2] w --this is always 1.0 so far in my tests (but what is it for?)
				)
			)
			if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)					
					
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
				)
			)
		)
	)	
	else if game == "HFR" then
	(
		if struct2read.nStreamType == 0x00000000 then		
		(
			if struct2read.nElementSize == 8 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (	readHalfFloat bstream:&bstream	)
					local y = (	readHalfFloat bstream:&bstream	)
					local z = (	readHalfFloat bstream:&bstream	)
															
					local w = (	readHalfFloat bstream:&bstream	) --Probably the MatID for the mesh with these vertices (but not sure)
															
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[2] w --this is always 1.0 so far in my tests (but what is it for?)
				)
			)
			else if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(					
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)
					
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
				)
			)
			else if struct2read.nElementSize == 16 then --HFR test
			(
				for v=1 to struct2read.nCount do
				(
					local x = (readfloat bstream)
					local y = (readfloat bstream)
													readlong bstream
					local z = (readfloat bstream)					
					
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
				)
			)
		)
		else 	if struct2read.nStreamType == 0x0000000F then --This is streamtype CGF_STREAM_P3S_C4B_T2S
		(
			if struct2read.nElementSize == 8 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (	readHalfFloat bstream:&bstream	)
					local y = (	readHalfFloat bstream:&bstream	)
					local z = (	readHalfFloat bstream:&bstream	)
															
					local w = (	readHalfFloat bstream:&bstream	) --Probably the MatID for the mesh with these vertices (but not sure)
															
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[2] w --this is always 1.0 so far in my tests (but what is it for?)
				)
			)
			else if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)					
					
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
				)
			)
			else if struct2read.nElementSize == 16 then --HFR test
			(
				for v=1 to struct2read.nCount do
				(		
					--Verts
					local x = (	readHalfFloat bstream:&bstream	) --pos
					local y = (	readHalfFloat bstream:&bstream	) --pos
					local z = (	readHalfFloat bstream:&bstream	) --pos
					local id = readshort bstream
				
					Append StreamStruct2fill.CGF_STREAM_POSITIONS_HFR[1] [x, y, z] --Custom StreamType for HFR

					--TexCoords
					local bgra = #()
					for i=1 to 4 do
					(
						Append bgra (readbyte bstream)
					)
					
					--UV
					local point_3 = point3				
					local u = (	readHalfFloat bstream:&bstream	) --bgra
					local v = (	readHalfFloat bstream:&bstream	) --bgra
					local w = 0					
					
					--UVW fix , we have to mirror the UVs vertically	
					local point_3 		= [u, (-v+1), w]

					Append StreamStruct2fill.CGF_STREAM_TEXCOORDS point_3
				)
			)
		)
	)
	else if game == "Armored Warfare" then
	(
		if struct2read.nStreamType == 0x00000000 then
		(
			if struct2read.nElementSize == 8 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (	readHalfFloat bstream:&bstream	)
					local y = (	readHalfFloat bstream:&bstream	)
					local z = (	readHalfFloat bstream:&bstream	)
															
					local w = (	readHalfFloat bstream:&bstream	) --Probably the MatID for the mesh with these vertices (but not sure)
															
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[2] w --this is always 1.0 so far in my tests (but what is it for?)
				)
			)
			else if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)					
					
					Append StreamStruct2fill.CGF_STREAM_POSITIONS[1] [x, y, z]
				)
			)
		)
	)
)

fn read_CGF_STREAM_NORMALS \
											&bstream: \
											&struct2read: \
											&info_MeshSubset: \
											&StreamStruct2fill: =
(
	local game = ::cryImport.ddl_CryGame.selected 
	
	if game == "Ryse" then
	(
		if struct2read.nStreamType == 0x00000001 then
		(
			if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)
					
					Append StreamStruct2fill.CGF_STREAM_NORMALS [x, y, z]			
				)
			)
		)
	)
	else if game == "HFR" then
	(
		if struct2read.nStreamType == 0x00000001 then
		(
			if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)
					
					Append StreamStruct2fill.CGF_STREAM_NORMALS [x, y, z]			
				)
			)
		)
	)
	else if game == "Armored Warfare" then
	(
		if struct2read.nStreamType == 0x00000001 then
		(
			if struct2read.nElementSize == 12 then
			(
				for v=1 to struct2read.nCount do
				(								
					local x = (readfloat bstream)
					local y = (readfloat bstream)
					local z = (readfloat bstream)
					
					Append StreamStruct2fill.CGF_STREAM_NORMALS [x, y, z]			
				)
			)
		)
	)
)

fn read_CGF_STREAM_TEXCOORDS \
													&bstream: \
													&struct2read: \
													&info_MeshSubset: \
													&StreamStruct2fill: =
(
	local game = ::cryImport.ddl_CryGame.selected 
	
	if game == "Ryse" then
	(
		if struct2read.nStreamType == 0x00000002 then
		(
			for v=1 to struct2read.nCount do
			(		
				local point_3 = point3
				
				local u = (readfloat bstream)
				local v = (readfloat bstream)
				local w = 0
				
				--UVW fix --for Ryse, we have to mirror the UVs vertically	
				if ::g_UVW_Flip_V OR (stricmp ::g_CryGame_dropDown_selection "Ryse") == 0 then
				(
					point_3 		= [u, (-v+1), w]
				)
				else
				(
					point_3 		= [u, v, w]
				)

				Append StreamStruct2fill.CGF_STREAM_TEXCOORDS point_3		
			)
		)
	)
	else if game == "Crysis" then
	(
		if struct2read.nStreamType == 0x00000002 then
		(
			for v=1 to struct2read.nCount do
			(		
				local point_3 = point3
				
				local u = (readfloat bstream)
				local v = (readfloat bstream)
				local w = 0
				
				--UVW fix --for Ryse, we have to mirror the UVs vertically	
				if ::g_UVW_Flip_V OR (stricmp ::g_CryGame_dropDown_selection "Ryse") == 0 then
				(
					point_3 		= [u, (-v+1), w]
				)
				else
				(
					point_3 		= [u, v, w]
				)

				Append StreamStruct2fill.CGF_STREAM_TEXCOORDS point_3		
			)
		)
	)
	else if game == "HFR" then
	(
		if struct2read.nStreamType == 0x00000002 then
		(
			for v=1 to struct2read.nCount do
			(		
				local point_3 = point3
				
				local u = (readfloat bstream)
				local v = (readfloat bstream)
				local w = 0
				
				--UVW fix --for Ryse, we have to mirror the UVs vertically	
				if ::g_UVW_Flip_V OR (stricmp ::g_CryGame_dropDown_selection "Ryse") == 0 then
				(
					point_3 		= [u, (-v+1), w]
				)
				else
				(
					point_3 		= [u, v, w]
				)

				Append StreamStruct2fill.CGF_STREAM_TEXCOORDS point_3		
			)
		)
	)
	else 	if game == "Armored Warfare" then
	(
		if struct2read.nStreamType == 0x00000002 then
		(
			for v=1 to struct2read.nCount do
			(		
				local point_3 = point3
				
				local u = (readfloat bstream)
				local v = (readfloat bstream)
				local w = 0
				
				--UVW fix --for Ryse, we have to mirror the UVs vertically	
				if ::g_UVW_Flip_V OR (stricmp ::g_CryGame_dropDown_selection "Ryse") == 0 then
				(
					point_3 		= [u, (-v+1), w]
				)
				else
				(
					point_3 		= [u, v, w]
				)

				Append StreamStruct2fill.CGF_STREAM_TEXCOORDS point_3		
			)
		)
	)
)

fn read_CGF_STREAM_INDICES \
											&bstream: \
											&struct2read: \
											&info_MeshSubset: \
											&StreamStruct2fill: =
(	
	local game = ::cryImport.ddl_CryGame.selected	
	
	if game == "Ryse" then
	(
		if struct2read.nStreamType == 0x00000005 then
		(		
			if ::rollout_Report.chk_Mesh_Report.state then
			(
				format "######### ftell bstream: %\n" (ftell bstream)
				format "#####################################\n"
				format "struct2read.nCount: %\n" struct2read.nCount
				format "#####################################\n"
			)
			
			local idx_offset = 1		
			if struct2read.nElementSize == 2 then --This is the size of each element to read
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(					
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					--We read them unsigned, because we can get the subset from the meshsubset description, and
					--thus we do not need to check the indices pos or negative sign to get the subsets
					--also it is much faster this way, to get the indices unsigned directly
					--if we need the unsigned indices in the future, we can always uncomment the below code snippet and get them
					local a 		= (readshort bstream #unsigned)+idx_offset
					local b 		= (readshort bstream #unsigned)+idx_offset
					local c 		= (readshort bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
-- 					
-- 					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
-- 					local a 		= (readshort bstream)+idx_offset
-- 					local b 		= (readshort bstream)+idx_offset
-- 					local c 		= (readshort bstream)+idx_offset	
-- 					
-- 					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
			else if struct2read.nElementSize == 4 then
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					local a 		= (readfloat bstream #unsigned)+idx_offset
					local b 		= (readfloat bstream #unsigned)+idx_offset
					local c 		= (readfloat bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
		)
	)
	else if game == "Crysis" then
	(
		if struct2read.nStreamType == 0x00000005 then
		(		
			if ::rollout_Report.chk_Mesh_Report.state then
			(
				format "######### ftell bstream: %\n" (ftell bstream)
				format "#####################################\n"
				format "struct2read.nCount: %\n" struct2read.nCount
				format "#####################################\n"
			)
			
			local idx_offset = 1		
			if struct2read.nElementSize == 2 then --This is the size of each element to read
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					local a 		= (readshort bstream #unsigned)+idx_offset
					local b 		= (readshort bstream #unsigned)+idx_offset
					local c 		= (readshort bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
			else if struct2read.nElementSize == 4 then
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					local a 		= (readfloat bstream #unsigned)+idx_offset
					local b 		= (readfloat bstream #unsigned)+idx_offset
					local c 		= (readfloat bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
		)
	)
	else if game == "HFR" then
	(
		if struct2read.nStreamType == 0x00000005 then
		(		
			if ::rollout_Report.chk_Mesh_Report.state then
			(
				format "######### ftell bstream: %\n" (ftell bstream)
				format "#####################################\n"
				format "struct2read.nCount: %\n" struct2read.nCount
				format "#####################################\n"
			)
			
			local idx_offset = 1		
			if struct2read.nElementSize == 2 then --This is the size of each element to read
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					local a 		= (readshort bstream #unsigned)+idx_offset
					local b 		= (readshort bstream #unsigned)+idx_offset
					local c 		= (readshort bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
			else if struct2read.nElementSize == 4 then
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					local a 		= (readfloat bstream #unsigned)+idx_offset
					local b 		= (readfloat bstream #unsigned)+idx_offset
					local c 		= (readfloat bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
		)
	)
	else if game == "Armored Warfare" then
	(
		if struct2read.nStreamType == 0x00000005 then
		(		
			if ::rollout_Report.chk_Mesh_Report.state then
			(
				format "######### ftell bstream: %\n" (ftell bstream)
				format "#####################################\n"
				format "struct2read.nCount: %\n" struct2read.nCount
				format "#####################################\n"
			)
			
			local idx_offset = 1		
			if struct2read.nElementSize == 2 then --This is the size of each element to read
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(					
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					--We read them unsigned, because we can get the subset from the meshsubset description, and
					--thus we do not need to check the indices pos or negative sign to get the subsets
					--also it is much faster this way, to get the indices unsigned directly
					--if we need the unsigned indices in the future, we can always uncomment the below code snippet and get them
					local a 		= (readshort bstream #unsigned)+idx_offset
					local b 		= (readshort bstream #unsigned)+idx_offset
					local c 		= (readshort bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
-- 					
-- 					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
-- 					local a 		= (readshort bstream)+idx_offset
-- 					local b 		= (readshort bstream)+idx_offset
-- 					local c 		= (readshort bstream)+idx_offset	
-- 					
-- 					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
			else if struct2read.nElementSize == 4 then
			(
				for v=1 to struct2read.nCount/3 do --this is the number of elements to read (3 for each face)
				(
					--Remember max index is 1-based (NOT zero based !) thus we need to add +1 to each index
					local a 		= (readfloat bstream #unsigned)+idx_offset
					local b 		= (readfloat bstream #unsigned)+idx_offset
					local c 		= (readfloat bstream #unsigned)+idx_offset	
					
					Append StreamStruct2fill.CGF_STREAM_INDICES [a,b,c]
				)
			)
		)
	)
)

--CGFLoader.cpp
-- 3405, 3529
-- bool CLoaderCGF::LoadCompiledMeshChunk( CNodeCGF* pNode,IChunkFile::ChunkDesc* pChunkDesc )

--TangentSpaceCalculation.cpp
--
--49
-- 	//! returns a orthogonal base (perpendicular and normalized)
-- 	void GetBase(const uint32 indwPos, float* outU, float* outV, float* outN);
-- #include "../../SDKs/TangentBasisComputation/mikkelsen/mikktspace.h"
-- CBase33 Base( Vec3(0,0,0), Vec3(0,0,0), vNormal );

--Tangent space per face
--Tangent space per vertex

fn read_CGF_STREAM_TANGENTS \
											&bstream: \
											&struct2read: \
											&info_MeshSubset: \
											&StreamStruct2fill: =
(
	--View the read tangents in the console with ***::_LOADEDm[1].g_ECgfStreamType[n].CGF_STREAM_TANGENTS***
	
	local game = ::cryImport.ddl_CryGame.selected 
	
	if game == "Ryse" then
	(
		if struct2read.nStreamType == 0x00000006 then
		(
			if struct2read.nElementSize == 0x00000010 then
			(
				for v=1 to struct2read.nCount do
				(	
					--Tangent and Bitangent for every vertex
					
					local T = point3
					local B = point3
					
					local t1 = readshort bstream
					local t2 = readshort bstream
					local t3 = readshort bstream
						local u4 = readshort bstream #unsigned --Area ? or sign reflection
					
					local b1 = readshort bstream 
					local b2 = readshort bstream
					local b3 = readshort bstream
						local v4 = readshort bstream #unsigned --Area ? or sign reflection
					
					T = [(t1/0xFFFF as float), (t2/0xFFFF as float),(t3/0xFFFF as float)]
					B = [(b1/0xFFFF as float), (b2/0xFFFF as float),(b3/0xFFFF as float)]
					
					Append StreamStruct2fill.CGF_STREAM_TANGENTS #(T , B)		
				)
			)
		)
	)
	else if game == "HFR" then
	(
		if struct2read.nStreamType == 0x00000006 then
		(
			if struct2read.nElementSize == 0x00000010 then
			(
				for v=1 to struct2read.nCount do
				(	
					--Tangent and Bitangent for every vertex
					
					local T = point3
					local B = point3
					
					local t1 = readshort bstream
					local t2 = readshort bstream
					local t3 = readshort bstream
						local u4 = readshort bstream #unsigned --Area ?
					
					local b1 = readshort bstream
					local b2 = readshort bstream
					local b3 = readshort bstream
						local v4 = readshort bstream #unsigned --Area ?
					
					T = [(t1/0xFFFF as float), (t2/0xFFFF as float),(t3/0xFFFF as float)]
					B = [(b1/0xFFFF as float), (b2/0xFFFF as float),(b3/0xFFFF as float)]
					
					Append StreamStruct2fill.CGF_STREAM_TANGENTS #(T , B)		
				)
			)
		)
	)
)

--Not Used
fn read_CGF_STREAM__DUMMY0 \
											&bstream: \
											&struct2read: \
											&info_MeshSubset: \
											&StreamStruct2fill: =
(
	--Put code here
)

--Not Used
fn read_CGF_STREAM__DUMMY1 \
											&bstream: \
											&struct2read: \
											&info_MeshSubset: \
											&StreamStruct2fill: =
(
	--Put code here
)

fn read_CGF_STREAM_COLORS \
										&bstream: \
										&struct2read: \
										&info_MeshSubset: \
										&StreamStruct2fill: =
(
	if struct2read.nStreamType == 0x00000003 then
	(
		if struct2read.nElementSize == 4 then
		(
			for v=1 to struct2read.nCount do
			(
				local r = readbyte bstream #unsigned 	--red
				local g = readbyte bstream #unsigned	--green
				local b = readbyte bstream #unsigned	--blue
				
				local a = readbyte bstream #unsigned	--alpha				

				local _color = color  r g b
				local _alpha = (a/255.0 as float) --must be float
															
				Append StreamStruct2fill.CGF_STREAM_COLORS[1] _color
				Append StreamStruct2fill.CGF_STREAM_COLORS[2] _alpha 		
			)
		)
	)
)

fn read_CGF_STREAM_COLORS2 \
										&bstream: \
										&struct2read: \
										&info_MeshSubset: \
										&StreamStruct2fill: =
(
	if struct2read.nStreamType == 0x00000004 then
	(
		if struct2read.nElementSize == 4 then
		(
			for v=1 to struct2read.nCount do
			(
				local r = readbyte bstream #unsigned 	--red
				local g = readbyte bstream #unsigned	--green
				local b = readbyte bstream #unsigned	--blue
				
				local a = readbyte bstream #unsigned	--alpha	
				
				local _color = color r g b
				local _alpha = (a/255.0 as float) --must be float
															
				Append StreamStruct2fill.CGF_STREAM_COLORS[1] _color
				Append StreamStruct2fill.CGF_STREAM_COLORS[2] _alpha			
			)
		)
	)
)

fn read_CGF_STREAM_BONEMAPPING \
													&bstream: \
													&struct2read: \
													&info_MeshSubset: \
													&StreamStruct2fill: =
(
	local game = ::cryImport.ddl_CryGame.selected
	
	if game == "Ryse" then
	(
		if struct2read.nStreamType == 0x00000009 then
		(
			--We will divide the weights below by this constant, to get a float
			local weight = 255.0
			
			for v=1 to struct2read.nCount do
			(
				--create struct instance
				inst_CrySkinVtx = CrySkinVtx()
				
				--We read the bone ids		
				local br 	= (readbyte bstream #unsigned)
				local bg 	= (readbyte bstream #unsigned)
				local bb 	= (readbyte bstream #unsigned)
				local ba 	= (readbyte bstream #unsigned)
				
				--We read the weights (and later divide them by 255.0 to get the real float weights)
				local wr 	= (readbyte bstream #unsigned)
				local wg 	= (readbyte bstream #unsigned)
				local wb 	= (readbyte bstream #unsigned)
				local wa 	= (readbyte bstream #unsigned)
				
				--We fill the struct point4 for ids, and point4 for weights
				inst_CrySkinVtx.idx 	= [br, bg, bb, ba]
				inst_CrySkinVtx.w	= [ \
													(wr/weight as float), \
													(wg/weight as float), \
													(wb/weight as float), \
													(wa/weight as float) \
												]
				
				--Append the final struct to ECgfStreamType
				Append 		StreamStruct2fill.CGF_STREAM_BONEMAPPING 		inst_CrySkinVtx
			)
		)
	)
	else 	if game == "HFR" then
	(
		if struct2read.nStreamType == 0x00000009 then
		(
			--We will divide the weights below by this constant, to get a float
			local weight = 255.0
			
			for v=1 to struct2read.nCount do
			(
				--create struct instance
				inst_CrySkinVtx = CrySkinVtx()
				
				--We read the bone ids		
				local br 		= (readbyte bstream #unsigned)
				local bg 	= (readbyte bstream #unsigned)
				local bb 	= (readbyte bstream #unsigned)
				local ba 	= (readbyte bstream #unsigned)
				
				--We read the weights (and later divide them by 255.0 to get the real float weights)
				local wr 	= (readbyte bstream #unsigned)
				local wg 	= (readbyte bstream #unsigned)
				local wb 	= (readbyte bstream #unsigned)
				local wa 	= (readbyte bstream #unsigned)
				
				--We fill the struct point4 for ids, and point4 for weights
				inst_CrySkinVtx.idx 	= [br, bg, bb, ba]
				inst_CrySkinVtx.w	= [ \
													(wr/weight as float), \
													(wg/weight as float), \
													(wb/weight as float), \
													(wa/weight as float) \
												]
				
				--Append the final struct to ECgfStreamType
				Append 		StreamStruct2fill.CGF_STREAM_BONEMAPPING 		inst_CrySkinVtx
			)
		)
	)
	else	if game == "Armored Warfare" then
	(
		if struct2read.nStreamType == 0x00000009 then
		(
			--We will divide the weights below by this constant, to get a float
			local weight = 255.0
			
			for v=1 to struct2read.nCount do
			(
				--create struct instance
				inst_CrySkinVtx = CrySkinVtx()
				
				--We read the bone ids		
				local br 		= (readbyte bstream #unsigned)
				local bg 	= (readbyte bstream #unsigned)
				local bb 	= (readbyte bstream #unsigned)
				local ba 	= (readbyte bstream #unsigned)
				
				--We read the weights (and later divide them by 255.0 to get the real float weights)
				local wr 	= (readbyte bstream #unsigned)
				local wg 	= (readbyte bstream #unsigned)
				local wb 	= (readbyte bstream #unsigned)
				local wa 	= (readbyte bstream #unsigned)
				
				--We fill the struct point4 for ids, and point4 for weights
				inst_CrySkinVtx.idx 	= [br, bg, bb, ba]
				inst_CrySkinVtx.w	= [ \
													(wr/weight as float), \
													(wg/weight as float), \
													(wb/weight as float), \
													(wa/weight as float) \
												]
				
				--Append the final struct to ECgfStreamType
				Append 		StreamStruct2fill.CGF_STREAM_BONEMAPPING 		inst_CrySkinVtx
			)
		)
	)
)

fn read_CGF_STREAM_FACEMAP =
(
	--Put code here
)

fn read_CGF_STREAM_VERT_MATS =
(
	--Put code here
)

fn read_CGF_STREAM_QTANGENTS \
													&bstream: \
													&struct2read: \
													&info_MeshSubset: \
													&StreamStruct2fill: =
(
	--View the read tangents in the console with ***::_LOADEDm[1].g_ECgfStreamType[n].CGF_STREAM_QTANGENTS***
	
-- 	q2m = ::_LOADEDm[1].g_ECgfStreamType[1].CGF_STREAM_QTANGENTS[1] as matrix3
-- 	normalize q2m.row3
	
	if struct2read.nStreamType == 0x0000000C then
	(
		if struct2read.nElementSize == 0x00000008 then
		(
			for v=1 to struct2read.nCount do
			(	
				local x 		= readshort bstream
				local y 		= readshort bstream
				local z 		= readshort bstream	
				local w 		= readshort bstream
				
				local quaternion = quat (x/32767.00) (y/32767.00) (z/32767.00) (w/32767.00)
				
				Append 		StreamStruct2fill.CGF_STREAM_QTANGENTS 		quaternion
			)
		)
	)	
)

fn read_CGF_STREAM_SKINDATA =
(
	--Put code here
)

fn read_CGF_STREAM_DUMMY2_ =
(
	--Put code here
)

fn read_CGF_STREAM_P3S_C4B_T2S =
(
	--Put code here
)



fn read_MESH_CHUNK_DESC_0801 \
												&bstream: \
												&struct2read: \
												&info_MeshSubset: \
												&Struct2fill: =
(		
-- 	enum EFlags
-- 	{
-- 		MESH_IS_EMPTY           				= 0x0001, //!< Empty mesh (no streams are saved).
-- 		HAS_TEX_MAPPING_DENSITY 		= 0x0002, //!< texMappingDensity contains a valid value.
-- 		HAS_EXTRA_WEIGHTS       			= 0x0004, //!< The weight stream will have weights for influences 5-8.
-- 		HAS_FACE_AREA           				= 0x0008, //!< geometricMeanFaceArea contains a valid value.
-- 	};						
							
	struct2fill.nFlags 					= readlong bstream --@see EFlags
	struct2fill.nFlags2 				= readlong bstream
							
	--Just for info.
	struct2fill.nVerts 					= readlong bstream --Number of vertices.
	struct2fill.nIndices 				= readlong bstream --Number of indices.
	struct2fill.nSubsets 				= readlong bstream --Number of mesh subsets.
							
	struct2fill.nSubsetsChunkId 	= readlong bstream --Chunk id of subsets. (Must be ChunkType_MeshSubsets)
	struct2fill.nVertAnimID 			= readlong bstream --id of the related vertAnim chunk if present. otherwise it is -1

-- 	ChunkIDs of data streams (Must be ChunkType_DataStream).
-- 	Index is one of ECgfStreamType values.
	for i=1 to struct2fill.nStreamChunkID_count do
	(
		Append struct2fill.nStreamChunkID (readlong bstream)
	)
							
	for i=1 to struct2fill.nPhysicsDataChunkId_count do
	(
		Append struct2fill.nPhysicsDataChunkId (readlong bstream)							
	)
							
	x = readfloat bstream
	y = readfloat bstream
	z = readfloat bstream
	struct2fill.bboxMin = [x,y,z]
							
	x = readfloat bstream
	y = readfloat bstream
	z = readfloat bstream
	struct2fill.bboxMax = [x,y,z]
							
	struct2fill.texMappingDensity 			= readfloat bstream
	struct2fill.geometricMeanFaceArea 	= readfloat bstream
							
	for i=1 to struct2fill.reserved_count do
	(
		readlong bstream
	)	
)

fn read_NODE_CHUNK_DESC_0824 \
												&bstream: \
												&struct2read: \
												&info_MeshSubset: \
												&Struct2fill: =
(
	--Fill in here
	local fixedLen = 64
	struct2fill._name 			= ReadFixedString \
																bstream:	&bstream \
																fixedLen:	&fixedLen
	
	struct2fill.ObjectID 		= readlong bstream
	struct2fill.ParentID 		= readlong bstream
	struct2fill.nChildren 		= readlong bstream
	struct2fill.MatID 			= readlong bstream
							
-- 	print struct2fill._name
							
	for i=1 to struct2fill._obsoleteA_count do
	(
		readbyte bstream #unsigned
	)
							
	---------Fill Matrix3---------
	x = readfloat bstream
	y = readfloat bstream
	z = readfloat bstream
	struct2fill.tm.row1 = [x,y,z]

	x = readfloat bstream
	y = readfloat bstream
	z = readfloat bstream
	struct2fill.tm.row2 = [x,y,z]

	x = readfloat bstream
	y = readfloat bstream
	z = readfloat bstream
	struct2fill.tm.row3 = [x,y,z]

	x = readfloat bstream
	y = readfloat bstream
	z = readfloat bstream
	struct2fill.tm.row4 = [x,y,z]
	--------------------------------
							
-- 	for i=1 to struct2fill._obsoleteB_count do
-- 	(
-- 		readfloat bstream
-- 	)
	struct2fill.pos = [(readfloat bstream), (readfloat bstream), (readfloat bstream)]
							
-- 	for i=1 to struct2fill._obsoleteC_count do
-- 	(
-- 		readfloat bstream
-- 	)
	struct2fill.rot = quat (readfloat bstream) (readfloat bstream) (readfloat bstream) (readfloat bstream)
							
-- 	for i=1 to struct2fill._obsoleteD_count do
-- 	(
-- 		readfloat bstream
-- 	)
	struct2fill.scl = [(readfloat bstream), (readfloat bstream), (readfloat bstream)]
							
	struct2fill.pos_cont_id 		= readlong bstream
	struct2fill.rot_cont_id 		= readlong bstream
	struct2fill.scl_cont_id 		= readlong bstream
							
	struct2fill.PropStrLen 		= readlong bstream
)

--Note --CryHeaders.h 754
-- //! Bonelist Chunk Header.
-- //! This structure describes the bone names.
-- //! It's followed by numEntities packed \0-terminated strings, the list terminated by double-\0.


fn read_STREAM_DATA_CHUNK_DESC_0800 \
															&bstream: \
															&fileHeader: \
															&struct2read: \															
															&info_MeshSubset: \
															IDX: \
															&IDx0017: \
															&inst_ECgfStreamType: =
(	
	--for i=IDX+1 to struct2read.ChunkType[1].count do
	for i=IDX+1 to g_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
	(
		if struct2read.ChunkType[1][i] == 0x0016 AND \	--0x0016
			struct2read.ChunkType[2][i] == 0xCCCC then
		(			
			--create runtime instance struct
			struct2fill = STREAM_DATA_CHUNK_DESC_0800()				
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
					
			if struct2read.ChunkVersion[1][i] == 0x0802 then --if Ox0800
			(
				--not implemented yet
			)
			else if struct2read.ChunkVersion[1][i] == 0x0800 then --if 0x0800
			(
				A 				= readshort bstream #unsigned --should be 0x0016
				B 				= readshort bstream #unsigned --should be 0xCCCC
				C 				= readshort bstream --should be 0x0800				
					D 			= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 				= readlong bstream #unsigned
				IDx0016 	= 0
				
				if ::rollout_Report.chk_Mesh_Report.state then
				(
					format "## A: %\n" A
					format "## B: %\n" B
					format "## C: %\n" C
					format "## F: %\n" F
					format "## IDx0016: %\n" IDx0016
				)
				
				if fileHeader.version == 0x0745 then
				(
					IDx0016 = readlong bstream --chunk ID --//new in version 0x0745
					
					format "## IDx0016: %\n" IDx0016					
										
					--confirm we are on the right chunk
					if  A 			== 0x0016 AND \
						B 			== 0xCCCC AND \			
						C 			== 0x0800 AND \
						IDx0016	== struct2read.ChunkID[1][i] AND \
						F 			== struct2read.FileOffset[1][i] then
					(
						struct2fill.chunkID			= IDx0016
						
						if ::rollout_Report.chk_Mesh_Report.state then
						(
							format "#### ftell bstream: %\n" (ftell bstream)
						)
						
-- 						if ::cryImport.ddl_CryGame.selected == "HFR" then
-- 						(
-- 							struct2fill.nStreamType 	= readlong bstream
-- 							struct2fill.nFlags 				= readlong bstream						
-- 						)
-- 						else if ::cryImport.ddl_CryGame.selected == "Ryse" then
-- 						(
							struct2fill.nFlags 				= readlong bstream
							struct2fill.nStreamType 	= readlong bstream
-- 						)

						struct2fill.nCount			 	= readlong bstream
						struct2fill.nElementSize	 	= readlong bstream
						
						for x=1 to struct2fill.reserved do
						(
							readlong bstream							
						)
								
						--read in CGF_STREAM_POSITIONS
						read_CGF_STREAM_POSITIONS \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType
						--CGF_STREAM_NORMALS
						read_CGF_STREAM_NORMALS  \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType
						--CGF_STREAM_TEXCOORDS
						read_CGF_STREAM_TEXCOORDS \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType
						 read_CGF_STREAM_COLORS \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType
																
						read_CGF_STREAM_COLORS2 \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType	
								
						--read in CGF_STREAM_INDICES
						read_CGF_STREAM_INDICES \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType		
						--CGF_STREAM_TANGENTS
						read_CGF_STREAM_TANGENTS \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType
						--read bonemapping
						read_CGF_STREAM_BONEMAPPING \
																		bstream:				&bstream \
																		struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																		info_MeshSubset:	&info_MeshSubset \ --not used for now
																		StreamStruct2fill:		&inst_ECgfStreamType						
						--read bonemapping
						read_CGF_STREAM_QTANGENTS \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType	
						

					)					
				)					
				else if fileHeader.version == 0x0744 then
				(
					IDx0016 = readlong bstream --chunk ID --//new in version 0x0745					
					format "## IDx0016: %\n" IDx0016
					
					format "ftell bstream: %\n" (ftell bstream)
					
					--confirm we are on the right chunk
					if  A == 0x0016 AND \
						B == 0xCCCC AND \			
						C == 0x0800 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						struct2fill.chunkID			= IDx0016
						
						if ::rollout_Report.chk_Mesh_Report.state then
						(
							format "#### ftell bstream: %\n" (ftell bstream)
						)
						
						struct2fill.nFlags 				= readlong bstream
						struct2fill.nStreamType 	= readlong bstream
						
						struct2fill.nCount			 	= readlong bstream
						struct2fill.nElementSize	 	= readlong bstream
						
						for x=1 to struct2fill.reserved do
						(
							readlong bstream
						)
						
						format "ftell bstream: %\n" (ftell bstream)
								
						--read in CGF_STREAM_POSITIONS
						read_CGF_STREAM_POSITIONS \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType
						--CGF_STREAM_NORMALS
						read_CGF_STREAM_NORMALS  \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType
						--CGF_STREAM_TEXCOORDS
						read_CGF_STREAM_TEXCOORDS \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType
						 read_CGF_STREAM_COLORS \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType
																
						read_CGF_STREAM_COLORS2 \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType	
								
						--read in CGF_STREAM_INDICES
						read_CGF_STREAM_INDICES \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType		
						--CGF_STREAM_TANGENTS
						read_CGF_STREAM_TANGENTS \
																bstream:				&bstream \
																struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																info_MeshSubset:	&info_MeshSubset \ --not used for now
																StreamStruct2fill:		&inst_ECgfStreamType
						--read bonemapping
						read_CGF_STREAM_BONEMAPPING \
																		bstream:				&bstream \
																		struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																		info_MeshSubset:	&info_MeshSubset \ --not used for now
																		StreamStruct2fill:		&inst_ECgfStreamType
						--read bonemapping
						read_CGF_STREAM_QTANGENTS \
																	bstream:				&bstream \
																	struct2read:			&struct2fill \ --this is the struct we just filled and we will read from it to know hom much to read
																	info_MeshSubset:	&info_MeshSubset \ --not used for now
																	StreamStruct2fill:		&inst_ECgfStreamType
					)
				)
			)					
			Append	 info_MeshSubset.ChunkHeadersArr 	struct2fill				
		)
		/* --this is not a stream chunk, we read in (after) read_CHUNK_0017 instead (see below function)
		else if struct2read.ChunkType[1][i] == 0x0000 AND \ --ChunkType_Mesh = 0x1000,   //!< Was 0xCCCC0000 in chunk files with versions <= 0x745.
		struct2read.ChunkType[2][i] == 0xCCCC then
		(	
			--For now we are just developing this for Ryse, but earlier versions of CryEngine might and can have all the chunks
			--in one single cgf file, thus we need to read these here as well, but for now, let's turn them OFF if the game is "Ryse"
			if (stricmp ::g_CryGame_dropDown_selection "Ryse") != 0 then  
			(
				struct2fill = MESH_CHUNK_DESC_0801()
				fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
				
				if struct2read.ChunkVersion[1][i] == 0x0800 OR \
					struct2read.ChunkVersion[1][i] == 0x0801 then --if 0x0823 or 0x0824
				(				
					A 				= readshort bstream #unsigned --should be 0x0000
					B 				= readshort bstream #unsigned --should be 0xCCCC
					C 				= readshort bstream --should be 0x0800 or 0x0801			
						D 			= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
					F 				= readlong bstream #unsigned
					IDx0000 	= 0					
					
					if fileHeader.version == 0x0745 then
					(	
						IDx0000 = readlong bstream --chunk ID --//new in version 0x0745		
						
						--confirm we are on the right chunk
						if  A 			== 0x0000 AND \
							B 			== 0xCCCC AND \			
							(C 		== 0x0800 OR C == 0x0801) AND \
							IDx0000 == struct2read.ChunkID[1][i] AND \
							F 			== struct2read.FileOffset[1][i] then
						(
							read_MESH_CHUNK_DESC_0801 \
																		bstream:				bstream \
																		struct2read:			struct2read \
																		info_MeshSubset:	info_MeshSubset \
																		Struct2fill:				Struct2fill
						)
					)					
					else if fileHeader.version == 0x0744 then
					(
						--confirm we are on the right chunk
						if  A == 0x0000 AND \
							B == 0xCCCC AND \			
							(C 		== 0x0800 OR C == 0x0801) AND \						
							F == struct2read.FileOffset[1][i] then
						(
							-- not implemented yet
						)
					)					
					Append 		::g_MESH_CHUNK_DESC_0801 		struct2fill					
				)
			)
		)
		--*/
		/* --this is not a stream chunk, we read in (after) read_CHUNK_0017 instead (see below function)
		else if struct2read.ChunkType[1][i] == 0x000B AND \ --0x000B --ChunkType_Mesh cryheaders.h 1086
		struct2read.ChunkType[2][i] == 0xCCCC then
		(	
			--For now we are just developing this for Ryse, but earlier versions of CryEngine might and can have all the chunks
			--in one single cgf file, thus we need to read these here as well, but for now, let's turn them OFF if the game is "Ryse"
			if (stricmp ::g_CryGame_dropDown_selection "Ryse") != 0 then  
			(
				struct2fill = NODE_CHUNK_DESC_0824()			
				fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
				
				if struct2read.ChunkVersion[1][i] == 0x0823 OR \
					struct2read.ChunkVersion[1][i] == 0x0824 then --if 0x0823 or 0x0824
				(			
					A 				= readshort bstream #unsigned --should be 0x000B
					B 				= readshort bstream #unsigned --should be 0xCCCC
					C 				= readshort bstream --should be 0x0823 or 0x0824			
						D 			= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
					F 				= readlong bstream #unsigned
					IDx000B 	= 0
							
					if fileHeader.version == 0x0745 then
					(
						IDx000B = readlong bstream --chunk ID --//new in version 0x0745
								
						--confirm we are on the right chunk
						if  A 			== 0x000B AND \
							B 			== 0xCCCC AND \			
							(C 		== 0x0823 OR C == 0x0824) AND \
							IDx000B == struct2read.ChunkID[1][i] AND \
							F 			== struct2read.FileOffset[1][i] then
						(
							read_NODE_CHUNK_DESC_0824 \
																		bstream:				bstream \
																		struct2read:			struct2read \
																		info_MeshSubset:	info_MeshSubset \
																		Struct2fill:				Struct2fill
						)
					)					
					else if fileHeader.version == 0x0744 then
					(
						--confirm we are on the right chunk
						if  A == 0x000B AND \
							B == 0xCCCC AND \			
							(C 		== 0x0823 OR C == 0x0824) AND \						
							F == struct2read.FileOffset[1][i] then
						(
							-- not implemented yet
						)
					)				
				)
				
				Append ::g_NODE_CHUNK_DESC_0824 struct2fill
			)
		)
		--*/
		else --End of Stream Subset
		(
-- 			format "End of Chunks\n"
		)
	)
)
----------------------------------------------


--Here we just read the bones as described in the 0xCCCC0017 - but that seems to be wrong, we need to read all of the bones in the 0xACDC000 first, then apply what we found there to the mesh 
--according to the info in the 0xCCCC0017 !

fn read_CryBoneDescData_Comp \	
											&bstream: \
											&struct2read: \
											&FileOffset: \
											&_filePos: \
											&ChunkSize: \											
													caller: \
													nodeCaller: \
													typeCaller: \
													currFileType: \
													&g_cryFile_m: \
													&inst_CDF_Model: \
													&inst_CDF_Attachment: \
													&inst_Sub_Meshes: =
(	
	if FileOffset < _filePos then
	(
		local boneChunkData_size 	= ChunkSize - (_filePos - FileOffset)		
		
		if (mod boneChunkData_size 584) == 0.0 then
		(
			local nboneChunks = ChunkSize/584
			format "============== nboneChunks: %==============\n" nboneChunks
			
			for idx=1 to nboneChunks do --we loop the number of subsets
			(
				struct2fill 				= CryBoneDescData_Comp()
										
				struct2Fill.chunkID 			= IDxACDC							
										
				--//!< Unique id of bone (generated from bone name).
				struct2fill.m_nControllerID = readlong bstream #unsigned																	
																				
				--struct CryBonePhysics_Comp
				--resetting the arrays as well
				struct2Fill._min 					= #()
				struct2Fill._max 					= #()
				struct2Fill.spring_angle 			= #()
				struct2Fill.spring_angle 			= #()
				struct2Fill.spring_tension 		= #()
				struct2Fill.damping 				= #()
				struct2Fill.framemtx 				= #(#(),#(),#())
				--------------------------------------
				for p=1 to struct2Fill.m_PhysInfo_length do
				(		
					struct2Fill.nPhysGeom = (readlong bstream)
						
					--// additional joint parameters
					struct2Fill.flags = (readlong bstream)			
						
					for n=1 to struct2Fill._min_length do
					(
						Append struct2Fill._min (readfloat bstream)
					)
						
					for n=1 to struct2Fill._max_length do
					(
						Append struct2Fill._max (readfloat bstream)
					)
						
					for n=1 to struct2Fill.spring_angle_length do
					(
						Append struct2Fill.spring_angle (readfloat bstream)
					)
							
					for n=1 to struct2Fill.spring_tension_length do
					(
						Append struct2Fill.spring_tension (readfloat bstream)
					)
						
					for n=1 to struct2Fill.damping_length do
					(
						Append struct2Fill.damping (readfloat bstream)
					)
						
					for n=1 to struct2Fill.framemtx_length do
					(
						for d=1 to struct2Fill.framemtx_length do
						(
							Append struct2Fill.framemtx[n] (readfloat bstream)
						)
					)
				)
				--------------------------------------

				struct2Fill.m_fMass = (readfloat bstream)																
					
				--REPORT+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				--format "                    Begin reading World2Bone Matrix34 ++++++++ __You are here:      %\n" (ftell bstream)						
				--read matrix34 values
				--//intitalpose matrix World2Bone
				rot_p3 = point3 0 0 0 --create a point3 for the 4th row
				--/////////////////////////////// Matrix World2Bone /////////////////////////////// 
				x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
				struct2Fill.m_DefaultW2B[1] = [x,y,z]		
					rot_p3.x = (readfloat bstream)		
					
				x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
				struct2Fill.m_DefaultW2B[2] = [x,y,z]		
					rot_p3.y = (readfloat bstream)		
					
				x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
				struct2Fill.m_DefaultW2B[3] = [x,y,z]			
					rot_p3.z = (readfloat bstream)		
					
				struct2Fill.m_DefaultW2B[4] = rot_p3
				--/////////////////////////////End of Matrix World2Bone ////////////////////////////																	
					
					
				--REPORT+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				--format "                    -----Begin reading Bone2World Matrix34 ++++++++ __You are here:      %\n" (ftell bstream)						
				--read matrix34 values
				--//intitalpose matrix Bone2World
				rot_p3 = point3 0 0 0 --create a point3 for the 4th row
				--/////////////////////////////// Matrix Bone2World /////////////////////////////// 
				x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
				struct2Fill.m_DefaultB2W[1] = [x,y,z]		
					rot_p3.x = (readfloat bstream)		
					
				x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
				struct2Fill.m_DefaultB2W[2] = [x,y,z]		
					rot_p3.y = (readfloat bstream)		
					
				x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
				struct2Fill.m_DefaultB2W[3] = [x,y,z]			
					rot_p3.z = (readfloat bstream)				
					
				struct2Fill.m_DefaultB2W[4] = rot_p3
				--/////////////////////////////End of Matrix Bone2World ////////////////////////////																	
					
					
				--REPORT+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				--format "                    Begin reading Bone Names ++++++++ __You are here:      %\n\n" (ftell bstream)						
				local _name 								= ""
				for x=1 to struct2Fill.m_arrBoneName_length do
				(
					_name 									+= (bit.intAsChar (readbyte bstream #unsigned))
				)
				struct2Fill.m_arrBoneName 			= _name
					
				struct2Fill.m_nLimbId 					= (readlong bstream) --// set by model state class
					
				--// this bone parent is this[m_nOffsetParent], 0 if the bone is root. Normally this is <= 0
				struct2Fill.m_nOffsetParent 			= (readlong bstream)
					
				--// The whole hierarchy of bones is kept in one big array that belongs to the ModelState
				--// Each bone that has children has its own range of bone objects in that array,
				--// and this points to the beginning of that range and defines the number of bones.
				struct2Fill.m_numChildren 				= (readlong bstream #unsigned)
					
				--// the beginning of the subarray of children is at this[m_nOffsetChildren]
				--// this is 0 if there are no children
				struct2Fill.m_nOffsetChildren 			= (readlong bstream)
					
				Append ::g_CryBoneDescData_Comp struct2fill	
			)
			
			--//////////////////////////////// Store the .chr skeleton /////////////////////////////////
			if 	caller 		== "CDF" AND \
				nodeCaller 	== "Model" then
			(
				if inst_CDF_Model != undefined then
				(
					inst_CDF_Model.CryBoneDescData_Comp 			= ::g_CryBoneDescData_Comp
				)
			)
			--/// Store the skin skeleton (same as .chr, but we store anyway - in case we don't load .chr) ///
			else if 	caller 		== "CDF" AND \
						nodeCaller 	== "Attachment" then
			(
				if inst_CDF_Attachment != undefined then
				(
					inst_CDF_Attachment.CryBoneDescData_Comp 	= ::g_CryBoneDescData_Comp
				)
			)
			else
			(
				inst_CDF_Model.CryBoneDescData_Comp 				= ::g_CryBoneDescData_Comp
				inst_CDF_Attachment.CryBoneDescData_Comp 		= ::g_CryBoneDescData_Comp
			)
			
			--Make a backup storage of the compiled bone description
			::g_stored_CryBoneDescData_Comp = deepCopy ::g_CryBoneDescData_Comp			
		)
		else
		(
			format "Count mismatch in 0xACDC0000 BoneChunk Data - Aborting Reading Bones\n!"
		)	
	)
)

fn read_Matrix \
					&bstream: \
					&matrix: \
					&struct2Fill: =
(
	--Declare
	local x = 0
	local y = 0
	local z = 0
	
	--/////////////////////////////// Matrix Bone2World /////////////////////////////// 
	x = (readfloat bstream); y = (readfloat bstream); z = (readfloat bstream)
	struct2Fill.matrix_HFR[1] = [x,y,z]
					
	x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
	struct2Fill.matrix_HFR[2] = [x,y,z]	
	
	x = (readfloat bstream);y = (readfloat bstream);z = (readfloat bstream)
	struct2Fill.matrix_HFR[3] = [x,y,z]
	--/////////////////////////////End of Matrix Reading ////////////////////////////		
)

fn read_MESH_SUBSETS_CHUNK_DESC_0800_v2 \
																	&bstream: \
																	&fileHeader: \
																	&struct2read: \
																	&struct2fill: \
																	i: \
																	&IDx0017: \
																	&inst_ECgfStreamType: =
(
	struct2fill.chunkID = IDx0017 -- store the chunkID
	--See CryHeaders.h 655
						
	struct2fill.nFlags = readlong bstream --It seems that for Ryse, 0x0006 seems to indicate that it has bone indices (but below it says 0x0002, maybe we must test for both
												
	--Probably:
-- 	--See CryHeaders.h 659
-- 	enum EFlags
-- 	{
-- 		SH_HAS_DECOMPR_MAT       = 0x0001, //!< Obsolete.
-- 		BONEINDICES              = 0x0002,
-- 		HAS_SUBSET_TEXEL_DENSITY = 0x0004,
-- 	};						

	struct2fill.nCount = readlong bstream
						
	--Reserved[2] int
	for x=1 to struct2fill.reserved do
	(
		readlong bstream
	)
	
	format "0xCCCC0017 We are att offset: %\n" (ftell bstream)
					
	for n=1 to struct2fill.nCount do
	(
		inst_MeshSubset = MeshSubset()

		inst_MeshSubset.nFirstIndexId 		= (readlong bstream)
		inst_MeshSubset.nNumIndices 		= (readlong bstream)
		inst_MeshSubset.nFirstVertId 		= (readlong bstream)
		inst_MeshSubset.nNumVerts 			= (readlong bstream)
							
		inst_MeshSubset.nMatID 				= (readlong bstream)
			
		-------------------------------------------------------------------------------------
		inst_MeshSubset.fRadius 				= (readfloat bstream)							
		-------------------------------------------------------------------------------------
		x	=(readfloat bstream)
		y	=(readfloat bstream)
		z	=(readfloat bstream)
		-------------------------------------------------------------------------------------
								
		inst_MeshSubset.vCenter = [x,y,z]							
							
		Append struct2fill.MeshSubsetsArr inst_MeshSubset
	)

	------------------------ If has bones ------------------------
	--It seems that for Ryse, 0x0006 seems to indicate that it has bone indices (but below it says 0x0002, maybe we must test for both
	--See CryHeaders.h 666
	--HFR check
	if ::cryImport.ddl_CryGame.selected == "HFR" then
	(
		local boneFlag 		= 0x00000006
		local boneFlag2 		= 0x00000016
		local boneFlag3		= 0x0000001E
-- 		local boneFlag4		= 0x00000014	--cga
		local boneFlag5		= 0x00000002 --Cabal2	
		-----------------------------------------------
		local staticFlag4		= 0x00000014	--cga
		local staticFlag 		= 0x00000004
		
		if 	struct2fill.nFlags == boneFlag 	OR \
			struct2fill.nFlags == boneFlag2 	OR \
			struct2fill.nFlags == boneFlag3 	OR \
-- 			struct2fill.nFlags == boneFlag4	OR
			struct2fill.nFlags == boneFlag5	then
		(
			for n=1 to struct2fill.nCount do --we loop n number of times (that is the number of subsets as given by nCount - a boneset for each submesh)
			(
				--Create struct
				local inst_MeshBoneIDs = MeshBoneIDs()

				inst_MeshBoneIDs.numBoneIDs = readlong bstream #unsigned
				--Each subset bone description chunk is 260 bytes long (4 + 256) former is uint32 numBonesIds, and the rest is uint16 bone IDs
				for b=1 to inst_MeshBoneIDs.arrBoneIDs_length do
				(
					id = readshort bstream #unsigned
					Append inst_MeshBoneIDs.arrBoneIDs id
				)
				
				Append 	struct2fill.MeshBoneSubsetsArr inst_MeshBoneIDs
			)			

			matrix = matrix3 1
				
			read_Matrix \
							bstream: 		&bstream \
							matrix: 			&matrix \
							struct2Fill: 		&struct2fill
			
			
		)-- End of reading bones ids
		else if 	struct2fill.nFlags == staticFlag  OR \
					struct2fill.nFlags == staticFlag4 then -- If has MeshSubsetTexelDensity
		(
			local point3_HFR 		= point3 0 0 0
			point3_HFR[1] 			= readfloat bstream
			point3_HFR[2] 			= readfloat bstream
			point3_HFR[3] 			= readfloat bstream
			struct2fill.point3_HFR 	= point3_HFR
		)
		else if struct2fill.nFlags == 0x00000002 then
		(
		)
	)
	else --default
	(
		local boneFlag 		= 0x00000006
		-----------------------------------------------
		local staticFlag 		= 0x00000004
		
		if struct2fill.nFlags == boneFlag then
		(
			for n=1 to struct2fill.nCount do --we loop n number of times (that is the number of subsets as given by nCount - a boneset for each submesh)
			(
				--Create struct
				local inst_MeshBoneIDs = MeshBoneIDs()

				inst_MeshBoneIDs.numBoneIDs = readlong bstream #unsigned
				--Each subset bone description chunk is 260 bytes long (4 + 256) former is uint32 numBonesIds, and the rest is uint16 bone IDs
				for b=1 to inst_MeshBoneIDs.arrBoneIDs_length do
				(
					id = readshort bstream #unsigned
					Append inst_MeshBoneIDs.arrBoneIDs id
				)
				
				Append 	struct2fill.MeshBoneSubsetsArr inst_MeshBoneIDs
			)			
		)-- End of reading bones ids
		else if struct2fill.nFlags == staticFlag then -- If has MeshSubsetTexelDensity
		(
			inst_MeshSubsetTexelDensity 					= MeshSubsetTexelDensity()
			inst_MeshSubsetTexelDensity.TexelDensity 	= readfloat bstream
			struct2fill.MeshSubsetTexelDensity 				= inst_MeshSubsetTexelDensity
			
		)
		else if struct2fill.nFlags == 0x00000002 then
		(
		)
	)
	------------------- End of reading MeshSubsetTexelDensity --------------------
	
	format "0xCCCC0017 We are att offset: %\n" (ftell bstream)
)

fn read_CHUNK_0017 \		
								&M_FILE_EXISTS_BOOL: \
								&M_TEST_BOOL: \
								caller: \
								nodeCaller: \
								typeCaller: \
								currFileType: \								
								&bstream: \
								&mtlFile: \
								&g_cryFile_m: \
								&fileHeader: \
								&struct2read: \
								&inst_CDF_Model: \
								&inst_CDF_Attachment: \
								&inst_Sub_Meshes: =
(
	--for i=1 to struct2read.ChunkType[1].count do
	for i=1 to g_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
	(
		if struct2read.ChunkType[1][i] == 0x0017 AND \
			struct2read.ChunkType[2][i] == 0xCCCC then
		(
			inst_ECgfStreamType = ECgfStreamType()---------
			struct2fill = MESH_SUBSETS_CHUNK_DESC_0800()
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0802 then --if Ox0800
			(
				--not implemented yet
			)
			else if struct2read.ChunkVersion[1][i] == 0x0800 OR \ -- see CryHeaders.h 557 why 0x0800 or 0x0801
						struct2read.ChunkVersion[1][i] == 0x0801 then --if 0x0800 or 0x0801
			(			
				A 			= readshort bstream #unsigned --should be 0x0017
				B 			= readshort bstream #unsigned --should be 0xCCCC
				C 			= readshort bstream --should be 0x0800 or 0x0801			
					D 		= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 			= readlong bstream #unsigned
				IDx0017	= 0
				
				if fileHeader.version == 0x0745 then
				(
					IDx0017 = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A 			== 0x0017 AND \
						B 			== 0xCCCC AND \			
						(C == 0x0800 OR C == 0x0801) AND \
						IDx0017 == struct2read.ChunkID[1][i] AND \
						F 			== struct2read.FileOffset[1][i] then
					(						
						if ::rollout_Report.chk_Mesh_Report.state then
						(
							format "######### ftell bstream : % ######## \n" (ftell bstream)
							format "IDx0017 \n" IDx0017
							format "inst_ECgfStreamType: %\n" inst_ECgfStreamType
						)
						
						read_MESH_SUBSETS_CHUNK_DESC_0800_v2 \
																						bstream:					&bstream \
																						fileHeader:					&fileHeader \
																						struct2read:				&struct2read \
																						struct2fill:					&struct2fill \
																						i:								i \
																						IDx0017:					&IDx0017 \
																						inst_ECgfStreamType:	&inst_ECgfStreamType						
					)					

					read_STREAM_DATA_CHUNK_DESC_0800 \																		
																			bstream:					&bstream \
																			fileHeader:					&fileHeader \
																			struct2read:				&struct2read \								
																			info_MeshSubset:		&struct2fill \
																			IDX:							i \
																			IDx0017:					&IDx0017 \
																			inst_ECgfStreamType:	&inst_ECgfStreamType
				)
				else if fileHeader.version == 0x0744 then
				(
					IDx0017 = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A == 0x0017 AND \
						B == 0xCCCC AND \			
						C == 0x0800 AND \						
						F == struct2read.FileOffset[1][i] then
					(
						if ::rollout_Report.chk_Mesh_Report.state then
						(
							format "######### ftell bstream : % ######## \n" (ftell bstream)
							format "IDx0017 \n" IDx0017
							format "inst_ECgfStreamType: %\n" inst_ECgfStreamType
						)
						
						format "0xCCCC0017 We are att offset: %\n" (ftell bstream)
						
						read_MESH_SUBSETS_CHUNK_DESC_0800_v2 \
																						bstream:					&bstream \
																						fileHeader:					&fileHeader \
																						struct2read:				&struct2read \
																						struct2fill:					&struct2fill \
																						i:								i \
																						IDx0017:					&IDx0017 \
																						inst_ECgfStreamType:	&inst_ECgfStreamType
					)
					
					read_STREAM_DATA_CHUNK_DESC_0800 \																		
																			bstream:					&bstream \
																			fileHeader:					&fileHeader \
																			struct2read:				&struct2read \								
																			info_MeshSubset:		&struct2fill \
																			IDX:							i \
																			IDx0017:					&IDx0017 \
																			inst_ECgfStreamType:	&inst_ECgfStreamType	
				)
			)
			if struct2read.ChunkVersion[1][i] == 0x0745 then --if Ox0745
			(
				format "not implemented yet \n"
				--To implement, see CryHeaders.h 555 --use the struct MESH_CHUNK_DESC_0745
			)
			
			Append 			::g_ECgfStreamType 									inst_ECgfStreamType
			Append 			::g_MESH_SUBSETS_CHUNK_DESC_0800 			struct2fill
		)
		else if struct2read.ChunkType[1][i] == 0x0000 AND \ --ChunkType_Mesh = 0x1000,   //!< Was 0xCCCC0000 in chunk files with versions <= 0x745.
		struct2read.ChunkType[2][i] == 0xCCCC then
		(
			struct2fill = MESH_CHUNK_DESC_0801()
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0800 OR \
				struct2read.ChunkVersion[1][i] == 0x0801 then --if 0x0823 or 0x0824
			(				
				A 				= readshort 	bstream 	#unsigned --should be 0x0000
				B 				= readshort 	bstream 	#unsigned --should be 0xCCCC
				C 				= readshort 	bstream 	--should be 0x0800 or 0x0801			
					D 			= readshort 	bstream 	--usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 				= readlong 		bstream 	#unsigned
				IDx0000 	= 0				
				
				if fileHeader.version == 0x0745 then
				(
					IDx0000 = readlong bstream --chunk ID --//new in version 0x0745
							
					--confirm we are on the right chunk
					if  A 			== 0x0000 AND \
						B 			== 0xCCCC AND \			
						(C 		== 0x0800 OR C == 0x0801) AND \
						IDx0000 == struct2read.ChunkID[1][i] AND \
						F 			== struct2read.FileOffset[1][i] then
					(
						read_MESH_CHUNK_DESC_0801 \
																	bstream:				&bstream \
																	struct2read:			&struct2read \
																	info_MeshSubset:	&info_MeshSubset \
																	Struct2fill:				&Struct2fill
					)					
				)					
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x0000 AND \
						B == 0xCCCC AND \			
						(C 		== 0x0800 OR C == 0x0801) AND \						
						F == struct2read.FileOffset[1][i] then
					(				
						print "not implemented yet"
					)
				)
				
				Append 		::g_MESH_CHUNK_DESC_0801 		struct2fill				
			)
		)
		else if struct2read.ChunkType[1][i] == 0x000B AND \ --node info 0xCCCC000B
					struct2read.ChunkType[2][i] == 0xCCCC then
		(						
			struct2fill = NODE_CHUNK_DESC_0824()			
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0823 OR \
				struct2read.ChunkVersion[1][i] == 0x0824 then --if 0x0823 or 0x0824
			(			
				A 				= readshort bstream #unsigned --should be 0x000B
				B 				= readshort bstream #unsigned --should be 0xCCCC
				C 				= readshort bstream --should be 0x0823 or 0x0824			
					D 			= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 				= readlong bstream #unsigned
				IDx000B 	= 0
						
				if fileHeader.version == 0x0745 then
				(
					IDx000B = readlong bstream --chunk ID --//new in version 0x0745
							
					--confirm we are on the right chunk
					if  A 			== 0x000B AND \
						B 			== 0xCCCC AND \			
						(C 		== 0x0823 OR C == 0x0824) AND \
						IDx000B == struct2read.ChunkID[1][i] AND \
						F 			== struct2read.FileOffset[1][i] then
					(	
						read_NODE_CHUNK_DESC_0824 \
																	bstream:		&bstream \
																	struct2read:	&struct2read \																		
																	Struct2fill:		&Struct2fill
					)
				)					
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x000B AND \
						B == 0xCCCC AND \			
						(C 		== 0x0823 OR C == 0x0824) AND \						
						F == struct2read.FileOffset[1][i] then
					(
						-- not implemented yet						
						print "node info 0xCCCC000B - not implemented - fileHeader.version == 0x0744"
					)
				)				
			)			
			Append ::g_NODE_CHUNK_DESC_0824 struct2fill
		)		
		else if (struct2read.ChunkType[1][i] == 0x0000 OR struct2read.ChunkType[1][i] == 0x2000 ) AND \ --0x0000 --//!< Was 0xACDC0000 in chunk files with versions <= 0x745.
					struct2read.ChunkType[2][i] == 0xACDC then
		(
			setINISetting 	::g_iniFile 	"boneinfo" "has_bones" 	"true"			
			
			--For now we are just developing this for Ryse, but earlier versions of CryEngine might and can have all the chunks
			--in one single cgf file, thus we need to read these here as well, but for now, let's turn them OFF if the game is "Ryse"
-- 			if (stricmp ::g_CryGame_dropDown_selection "Ryse") != 0 then  
-- 			(
				struct2fill 				= CryBoneDescData_Comp()
			
				fseek bstream struct2read.FileOffset[1][i] #seek_set

				if struct2read.ChunkVersion[1][i] == 0x0800 then \ --0x0800				
				(
					A 				= readshort bstream #unsigned 	--should be 0x0000 or 0x2000
					B 				= readshort bstream #unsigned 	--should be 0xACDC
					C 				= readshort bstream 				--should be 0x0800
						D 			= readshort bstream 				--usually 0x0000 unknown --we do not check for this as we do not know what it is
					F 				= readlong bstream #unsigned
					IDxACDC 	= 0
															
					if ::g_Read_Comp_cryBones_Report then
					(
						format "A: %\n" A
						format "B: %\n" B											
						format "C: %\n" C
						format "F: %\n" F
						format "IDxACDC: %\n" IDxACDC
					)
															
					if fileHeader.version == 0x0745 then
					(
						IDxACDC = readlong bstream --chunk ID --//new in version 0x0745
																
						--confirm we are on the right chunk
						if  (A == 0x0000 OR A == 0x2000) AND \
							B 			== 0xACDC AND \			
							C 			== 0x0800 AND \
							IDxACDC == struct2read.ChunkID[1][i] AND \
							F 			== struct2read.FileOffset[1][i] then
						(	
							fseek bstream struct2Fill.reserved #seek_cur
																	
							if ::g_Read_Comp_cryBones_Report then
							(
								format "We will now read the Compiled Crybones 0xACDC at fileposition: %\n" (ftell bstream)
							)
							
							local ChunkSize 		= struct2read.ChunkPlusDescr_size[i]
							local _filePos			= (ftell bstream)
							
							read_CryBoneDescData_Comp \
																	bstream:			&bstream \
																	struct2read:		&struct2read \																																	
																	FileOffset:			&F \	
																	_filePos: 			&_filePos \
																	ChunkSize:			&ChunkSize \						
																			caller: 							caller \
																			nodeCaller: 					nodeCaller \
																			typeCaller: 						typeCaller \
																			currFileType: 					currFileType	\
																			g_cryFile_m: 					&g_cryFile_m	\
																			inst_CDF_Model: 				&inst_CDF_Model	\
																			inst_CDF_Attachment: 		&inst_CDF_Attachment	\
																			inst_Sub_Meshes:			&inst_Sub_Meshes
							
							print "read_CHUNK_0017 ************* read_CryBoneDescData_Comp ************* "
																	
						)
					)					
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x0000 AND \
						B == 0xACDC AND \			
						C == 0x0000 AND \						
						F == struct2read.FileOffset[1][i] then
						(					
							print "0x0744 - code not implemented yet"
						)
					)				
				)
-- 			)
		)		
		else if struct2read.ChunkType[1][i] == 0x0005 AND \
					struct2read.ChunkType[2][i] == 0xAAFC then		
		(
			struct2fill = FOLIAGE_INFO_CHUNK_DESC()
			fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
			
			if struct2read.ChunkVersion[1][i] == 0x0001 then --if Ox0001
			(
				A 			= readshort bstream #unsigned --should be 0x0005
				B 			= readshort bstream #unsigned --should be 0xAAFC
				C 			= readshort bstream --should be 0x0001				
					D 		= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
				F 			= readlong bstream #unsigned
				IDx0005	= 0
				
				if fileHeader.version == 0x0745 then
				(
					IDx0005 = readlong bstream --chunk ID --//new in version 0x0745
					
					--confirm we are on the right chunk
					if  A 			== 0x0005 AND \
						B 			== 0xAAFC AND \			
						C 			== 0x0001 AND \
						IDx0005 == struct2read.ChunkID[1][i] AND \
						F 			== struct2read.FileOffset[1][i] then
					(						
						struct2fill.nSpines 		= readlong bstream
						struct2fill.nSpineVtx 	= readlong bstream
						struct2fill.nSkinnedVtx 	= readlong bstream
						struct2fill.nBoneIds 		= readlong bstream
					)				
				)
				else if fileHeader.version == 0x0744 then
				(
					--confirm we are on the right chunk
					if  A == 0x0005 AND \
						B == 0xAAFC AND \			
						C == 0x0001 AND \						
						F == struct2read.FileOffset[1][i] then
					(					
						format "not implemented yet \n"
					)
				)
			)			
			Append 		::g_FOLIAGE_INFO_CHUNK_DESC 		struct2fill
		)
	)
	
-- 	format "inst_CDF_Model.CryBoneDescData_Comp: %\n" inst_CDF_Model.CryBoneDescData_Comp
	
	--Initiate the Builders
	inst_init_Builders = init_Builders()
	inst_init_Builders.call_Builders \
											M_FILE_EXISTS_BOOL:		&M_FILE_EXISTS_BOOL \
											M_TEST_BOOL:				&M_TEST_BOOL \
											caller:							caller \
											nodeCaller:						nodeCaller \
											typeCaller:						typeCaller \
											currFileType:					currFileType \								
											struct2read:					&struct2read \
											mtlFile:							&mtlFile \
											g_cryFile_m:					&g_cryFile_m \
											inst_CDF_Model:				&inst_CDF_Model \
											inst_CDF_Attachment: 		&inst_CDF_Attachment \
											inst_Sub_Meshes: 			&inst_Sub_Meshes
)
