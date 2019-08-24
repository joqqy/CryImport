
--/////////////////////////// CAF Headers ///////////////////////////


struct MotionParams905
(
	chunkID							= 0,
	
	m_nAssetFlags 				= 0, --uint32 
	m_nCompression 				= 0, --uint32 

	m_nTicksPerFrame 			= 0, --int32   --//!< Unused (always assumed to be 1).
	m_fSecsPerTick 				= 0, --f32    --//!< Unused (always assumed to be 1/30).
	m_nStart 						= 0, --int32 
	m_nEnd 							= 0, --int32 

	m_fMoveSpeed 				= 0, --f32
	m_fTurnSpeed 				= 0, --f32
	m_fAssetTurn 					= 0, --f32
	m_fDistance 					= 0, --f32
	m_fSlope 						= 0, --f32

	
	m_StartLocation 				= quat 0 0 0 0, --QuatT --quaternion with Translation vector  (translation vector below)
		T_StartLocation				= point3,
	
	m_EndLocation		 		= quat 0 0 0 0, --QuatT --quaternion with Translation vector (translation vector below)
		T_EndLocation					= point3,

	
	m_LHeelStart 					= 0, --f32
	m_LHeelEnd 					= 0, --f32
	
	m_LToe0Start 				= 0, --f32
	m_LToe0End 					= 0, --f32
	
	m_RHeelStart 					= 0, --f32
	m_RHeelEnd 					= 0, --f32
	
	m_RToe0Start 				= 0, --f32
	m_RToe0End 					= 0 --f32

-- 	MotionParams905()
-- 	{
-- 		m_nAssetFlags    = 0;
-- 		m_nCompression   = -1;
-- 		m_nTicksPerFrame = 0;
-- 		m_fSecsPerTick   = 0;
-- 		m_nStart         = 0;
-- 		m_nEnd           = 0;

-- 		m_fMoveSpeed = -1;
-- 		m_fTurnSpeed = -1;
-- 		m_fAssetTurn = -1;
-- 		m_fDistance  = -1;
-- 		m_fSlope     = -1;

-- 		m_LHeelStart = -1;
-- 		m_LHeelEnd   = -1;
-- 		m_LToe0Start = -1;
-- 		m_LToe0End   = -1;
-- 		m_RHeelStart = -1;
-- 		m_RHeelEnd   = -1;
-- 		m_RToe0Start = -1;
-- 		m_RToe0End   = -1;

-- 		m_StartLocation.SetIdentity();
-- 		m_EndLocation.SetIdentity();
-- 	}
)

struct CHUNK_GAHCAF_INFO
(
-- 	enum {VERSION = 0x0971};
-- 	enum {FILEPATH_SIZE = 256};
	
	chunkID								= 0,

	m_Flags 							= 0, 	--uint32 
	m_FilePath 							= "", --char string m_FilePath[FILEPATH_SIZE]
			FILEPATH_SIZE 			= 256,
	
	m_FilePathCRC32 				= 0, 	--uint32 
	m_FilePathDBACRC32 			= 0, 	--uint32 

	m_LHeelStart 						= 0, --f32
	m_LHeelEnd 						= 0, --f32
	
	m_LToe0Start 					= 0, --f32
	m_LToe0End 						= 0, --f32
	
	m_RHeelStart 						= 0, --f32
	m_RHeelEnd 						= 0, --f32
	
	m_RToe0Start 					= 0, --f32
	m_RToe0End 						= 0, --f32	
	

	m_fStartSec 						= 0, --f32         --//!< Asset-feature: Start time in seconds.
	m_fEndSec 						= 0, --f32           --//!< Asset-feature: End time in seconds.
	m_fTotalDuration 				= 0, --f32    --//!< Asset-feature: asset-feature: total duration in seconds.
	m_nControllers 					= 0, 	--uint32 

	m_StartLocation 					= quat 0 0 0 0,      --//!< Locator information. --QuatT  --QuatT --quaternion with Translation vector  (translation vector below)
		T_m_StartLocation				= point3,
	
	m_LastLocatorKey 				= quat 0 0 0 0,     --//!< Locator information. --QuatT  --QuatT --quaternion with Translation vector  (translation vector below)
		T_LastLocatorKey				= point3,

	m_vVelocity 						= point3,           --//!< Asset-feature: the velocity vector for this asset.
	m_fDistance 						= 0, --f32           --//!< Asset-feature: the absolute distance this objects is moving.
	m_fSpeed 							= 0, --f32              --//!< Asset-feature: speed (meters in second).
	m_fSlope 							= 0, --f32              --//!< Asset-feature: uphill-downhill measured in degrees.
	m_fTurnSpeed 					= 0, --f32          --//!< Asset-feature: turning speed per second.
	m_fAssetTurn 						= 0 --f32          --//!< Asset-feature: radiant between first and last frame.
)

--It looks like two Vec3's
struct ChunkType_BspTreeData
(
	chunkID			= 0,
	
	vec3_a 			= point3,
	vec3_b 			= point3
)

--See CryHeaders.h 983
-- //! Compressed PQ animation controller chunk (position + scale). Used in .caf files.
-- //! The chunk payload has the following structure:
-- //! - rotation value keys.
-- //! - rotation time keys.
-- //! - position value keys.
-- //! - position time keys (optional).
-- //! The number of keys and their binary representations are specified by this descriptor.
struct CONTROLLER_CHUNK_DESC_0829
(
-- 	enum { VERSION = 0x0829 };

-- 	enum { eKeyTimeRotation = 0, eKeyTimePosition = 1 };

	chunkID									= 0,
	
	nControllerId 							= 0, 	--uint32    --//!< Unique controller ID (crc32 of the bone name).

	numRotationKeys 					= 0, 	--uint16    --//!< Number of rotation keys stored within this chunk.
	numPositionKeys 						= 0, 	--uint16    --//!< Number of position keys stored within this chunk.
	
	RotationFormat 						= 0, 	--uint8     --//!< Format identifier of the rotation value keys (see: ECompressionInformation enumeration type).
	RotationTimeFormat 					= 0,	--uint8 	--//!< Format identifier of the rotation time keys (see: EKeyTimesFormat enumeration type).
	PositionFormat 						= 0,	--uint8     --//!< Format identifier of the position value keys (see: ECompressionInformation enumeration type).
	PositionKeysInfo 						= 0,	--uint8   	--//!< Specifies which time key array is used by the position component (eKeyTimeRotation, eKeyTimePosition).
	PositionTimeFormat 					= 0,	--uint8 	--//!< Format of identifier the position time keys (see: EKeyTimesFormat enumeration type). May not be used depending on the value of PositionKeysInfo.
	
	TracksAligned 							= 0	--uint8     --//!< If set to nonzero, signals that all key arrays are padded to a 4-byte boundary.

-- 	AUTO_STRUCT_INFO;
)





