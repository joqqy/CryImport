


struct GAHCAF_PROCESSOR
(
	-------- CAF --------
	fn fill_CAF_struct \
							bstream: \
							&struct2Fill: =
	(
		struct2Fill.m_flags 						= readlong bstream #unsigned
		
		struct2Fill.m_FilePath 					= ReadFixedString \
																					bstream:	&bstream \
																					fixedLen:	&struct2Fill.FILEPATH_SIZE
		
		struct2Fill.m_FilePathCRC32 			= readlong bstream #unsigned
		struct2Fill.m_FilePathDBACRC32 		= readlong bstream #unsigned

		struct2Fill.m_LHeelStart 				= readfloat bstream
		struct2Fill.m_LHeelEnd 					= readfloat bstream

		struct2Fill.m_LToe0Start 				= readfloat bstream
		struct2Fill.m_LToe0End 				= readfloat bstream

		struct2Fill.m_RHeelStart 				= readfloat bstream
		struct2Fill.m_RHeelEnd 					= readfloat bstream

		struct2Fill.m_RToe0Start 				= readfloat bstream
		struct2Fill.m_RToe0End 				= readfloat bstream							

		struct2Fill.m_fStartSec 				= readfloat bstream
		struct2Fill.m_fEndSec 					= readfloat bstream
		struct2Fill.m_fTotalDuration 			= readfloat bstream
		struct2Fill.m_nControllers 				= readlong bstream #unsigned

		
		--Vec3
		struct2Fill.T_StartLocation				= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
		--QuatT
		struct2Fill.m_StartLocation.x 			= readfloat bstream
		struct2Fill.m_StartLocation.y 			= readfloat bstream
		struct2Fill.m_StartLocation.z 			= readfloat bstream
		struct2Fill.m_StartLocation.w 		= readfloat bstream
		
		--Vec3
		struct2Fill.m_LastLocatorKey			= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
		--QuatT
		struct2Fill.m_LastLocatorKey.x 		= readfloat bstream
		struct2Fill.m_LastLocatorKey.y 		= readfloat bstream
		struct2Fill.m_LastLocatorKey.z 		= readfloat bstream
		struct2Fill.m_LastLocatorKey.w 		= readfloat bstream

		--Vec3
		struct2Fill.m_vVelocity	= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
		
		struct2Fill.m_fDistance 					= readfloat bstream
		struct2Fill.m_fSpeed 					= readfloat bstream							
		struct2Fill.m_fSlope 						= readfloat bstream
		struct2Fill.m_fTurnSpeed 				= readfloat bstream
		struct2Fill.m_fAssetTurn 				= readfloat bstream
	),
	
	fn get_CAF_infoFrom_CHUNK_GAHCAF_INFO \
																bstream: \
																struct2Read: \
																&struct2Fill: =
	(
		m_flags 							= readlong bstream #unsigned
		
		m_FilePath 						= ReadFixedString \
																		bstream:	&bstream \
																		fixedLen:	&struct2Fill.FILEPATH_SIZE
		
		m_FilePathCRC32 			= readlong bstream #unsigned
		m_FilePathDBACRC32 		= readlong bstream #unsigned
		
		/*		
		m_LHeelStart 					= readfloat bstream
		m_LHeelEnd 					= readfloat bstream
							
		m_LToe0Start 				= readfloat bstream
		m_LToe0End 					= readfloat bstream
							
		m_RHeelStart 					= readfloat bstream
		m_RHeelEnd 					= readfloat bstream
							
		m_RToe0Start 				= readfloat bstream
		m_RToe0End 					= readfloat bstream
							
							
		m_fStartSec 					= readfloat bstream
		m_fEndSec 					= readfloat bstream
		m_fTotalDuration 			= readfloat bstream
		m_nControllers 				= readlong bstream #unsigned --This is the number of bones/controllers							
		
		--Vec3
		T_StartLocation				= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
		--QuatT
		m_StartLocation.x 			= readfloat bstream
		m_StartLocation.y 			= readfloat bstream
		m_StartLocation.z 			= readfloat bstream
		m_StartLocation.w 			= readfloat bstream
		
		--Vec3
		m_LastLocatorKey			= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
		--QuatT
		m_LastLocatorKey.x 		= readfloat bstream
		m_LastLocatorKey.y 		= readfloat bstream
		m_LastLocatorKey.z 		= readfloat bstream
		m_LastLocatorKey.w 		= readfloat bstream
							
		--Vec3
		m_vVelocity					= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
							
		m_fDistance 					= readfloat bstream
		m_fSpeed 						= readfloat bstream							
		m_fSlope 						= readfloat bstream
		m_fTurnSpeed 				= readfloat bstream
		m_fAssetTurn 					= readfloat bstream
		--*/
	),
	
		-------- MotionParams905 --------
	fn fill_CAF_MotionParams905 \
											bstream: \
											&struct2Fill: =
	(
		struct2Fill.m_nAssetFlags 						= readlong bstream #unsigned
		struct2Fill.m_nCompression 					= readlong bstream #unsigned
		
		struct2Fill.m_nTicksPerFrame 					= readlong bstream		--//!< Unused (always assumed to be 1).
		struct2Fill.m_fSecsPerTick 					= readfloat bstream		--//!< Unused (always assumed to be 1/30).
		
		struct2Fill.m_nStart 								= readlong bstream
		struct2Fill.m_nEnd 								= readlong bstream
		
		struct2Fill.m_fMoveSpeed 						= readfloat bstream
		struct2Fill.m_fTurnSpeed 						= readfloat bstream
		struct2Fill.m_fAssetTurn 						= readfloat bstream
		struct2Fill.m_fDistance 							= readfloat bstream
		struct2Fill.m_fSlope 								= readfloat bstream
		
		--Vec3
		struct2Fill.T_StartLocation						= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
		--QuatT
		struct2Fill.m_StartLocation.x 					= readfloat bstream
		struct2Fill.m_StartLocation.y 					= readfloat bstream
		struct2Fill.m_StartLocation.z 					= readfloat bstream
		struct2Fill.m_StartLocation.w 				= readfloat bstream
		
		--Vec3
		struct2Fill.T_EndLocation						= point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
		--QuatT
		struct2Fill.m_EndLocation.x 					= readfloat bstream
		struct2Fill.m_EndLocation.y 					= readfloat bstream
		struct2Fill.m_EndLocation.z 					= readfloat bstream
		struct2Fill.m_EndLocation.w 					= readfloat bstream
		
		
		
		struct2Fill.m_LHeelStart 						= readfloat bstream
		struct2Fill.m_LHeelEnd 							= readfloat bstream
							
		struct2Fill.m_LToe0Start 						= readfloat bstream
		struct2Fill.m_LToe0End 						= readfloat bstream
							
		struct2Fill.m_RHeelStart 						= readfloat bstream
		struct2Fill.m_RHeelEnd 							= readfloat bstream
							
		struct2Fill.m_RToe0Start 						= readfloat bstream
		struct2Fill.m_RToe0End 						= readfloat bstream
	),
	
	fn fill_CONTROLLER_CHUNK_DESC_0829 \
															bstream: \
															&struct2Fill: =
	(
		--TODO
-- 		--We must fix the fill_CONTROLLER_CHUNK_DESC_0829 to read the correct specifed number of keys etc, now it doesn't take that into consideration!!!!
		
-- 		--enum { VERSION = 0x0829 };

-- 		--enum { eKeyTimeRotation = 0, eKeyTimePosition = 1 };
		
		--CONTROLLER ID
		struct2Fill.nControllerId 				= readlong bstream #unsigned 	--uint32      --//!< Unique controller ID (crc32 of the bone name).		
		

		struct2Fill.numRotationKeys 			= readshort bstream #unsigned 	--uint16    --//!< Number of rotation keys stored within this chunk.
		struct2Fill.numPositionKeys 			= readshort bstream #unsigned 	--uint16    --//!< Number of position keys stored within this chunk.
		
		struct2Fill.RotationFormat 				= readbyte bstream #unsigned 	--uint8     --//!< Format identifier of the rotation value keys (see: ECompressionInformation enumeration type).
		struct2Fill.RotationTimeFormat 		= readbyte bstream #unsigned	--uint8 	--//!< Format identifier of the rotation time keys (see: EKeyTimesFormat enumeration type).
		struct2Fill.PositionFormat 				= readbyte bstream #unsigned	--uint8     --//!< Format identifier of the position value keys (see: ECompressionInformation enumeration type).
		
		struct2Fill.PositionKeysInfo 			= readbyte bstream #unsigned	--uint8   	--//!< Specifies which time key array is used by the position component (eKeyTimeRotation, eKeyTimePosition).
		struct2Fill.PositionTimeFormat 		= readbyte bstream #unsigned	--uint8 	--//!< Format of identifier the position time keys (see: EKeyTimesFormat enumeration type). May not be used depending on the value of PositionKeysInfo.
		struct2Fill.TracksAligned 				= readbyte bstream #unsigned	--uint8     --//!< If set to nonzero, signals that all key arrays are padded to a 4-byte boundary.
	),
	
	fn read_CHUNK_GAHCAF \
									bstream: \
									fileHeader: \
									struct2read: =
	(
		for i=1 to ::g_CAF_CHUNKTABLE_FILE_CONSTANTS[1].nChunkTable_entries do
		(
			if struct2read.ChunkType[1][i] == 0x0007 AND \
				struct2read.ChunkType[2][i] == 0xAAFC then
			(
				fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
				
				if struct2read.ChunkVersion[1][i] == 0x0971 then --if Ox0971
				(
					local struct2Fill = CHUNK_GAHCAF_INFO()
					
					local A 	= readshort bstream #unsigned --should be 0x0007
					local B 	= readshort bstream #unsigned --should be 0xAAFC
					local C 	= readshort bstream --should be 0x0971				
						local D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
					local F 	= readlong bstream #unsigned
					local ID = 0
					
					if fileHeader.version == 0x0745 then
					(
						ID = readlong bstream --chunk ID --//new in version 0x0745
						
						--confirm we are on the right chunk
						if  A == 0x0007 AND \
							B == 0xAAFC AND \			
							C == 0x0971 AND \
							ID == struct2read.ChunkID[1][i] AND \
							F == struct2read.FileOffset[1][i] then
						(
							--Store the Chunk ID
							struct2fill.chunkID = ID
							
							fill_CAF_struct \
													bstream:bstream \
													struct2Fill:&struct2Fill
							
							Append 		::g_CHUNK_GAHCAF_INFO	 	struct2Fill
						)
					)					
				)
			)
			else if struct2read.ChunkType[1][i] == 0x0002 AND \
				struct2read.ChunkType[2][i] == 0xAAFC then
			(
				fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
				
				if struct2read.ChunkVersion[1][i] == 0x0925 then --if 0x0925
				(
					local struct2Fill = MotionParams905()
					
					local A 	= readshort bstream #unsigned --should be 0x0002
					local B 	= readshort bstream #unsigned --should be 0xAAFC
					local C 	= readshort bstream --should be 0x0925				
						local D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
					local F 	= readlong bstream #unsigned
					local ID = 0
					
					if fileHeader.version == 0x0745 then
					(
						ID = readlong bstream --chunk ID --//new in version 0x0745
						
						--confirm we are on the right chunk
						if  A == 0x0002 AND \
							B == 0xAAFC AND \			
							C == 0x0925 AND \
							ID == struct2read.ChunkID[1][i] AND \
							F == struct2read.FileOffset[1][i] then
						(
							--Store the Chunk ID
							struct2fill.chunkID = ID
							
							fill_CAF_MotionParams905 \
																bstream:bstream \
																struct2Fill:&struct2Fill
							
							Append 		::g_MotionParams905 	struct2Fill
						)
					)					
				)
				
			)
			else if struct2read.ChunkType[1][i] == 0x0009 AND \
				struct2read.ChunkType[2][i] == 0xAAFC then
			(
				fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
				
				if struct2read.ChunkVersion[1][i] == 0x0001 then --if 0x0829
				(
					local struct2Fill = ChunkType_BspTreeData()
					
					local A 	= readshort bstream #unsigned --should be 0x0009
					local B 	= readshort bstream #unsigned --should be 0xAAFC
					local C 	= readshort bstream --should be 0x0001				
						local D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
					local F 	= readlong bstream #unsigned
					local ID = 0
					
					if fileHeader.version == 0x0745 then
					(
						ID = readlong bstream --chunk ID --//new in version 0x0745
						
						--confirm we are on the right chunk
						if  A == 0x0009 AND \
							B == 0xAAFC AND \			
							C == 0x0001 AND \
							ID == struct2read.ChunkID[1][i] AND \
							F == struct2read.FileOffset[1][i] then
						(							
							--Store the Chunk ID
							struct2fill.chunkID = ID
							
							struct2Fill.vec3_a = point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
							struct2Fill.vec3_b = point3 (readfloat bstream) (readfloat bstream) (readfloat bstream)
							
							Append 		::g_ChunkType_BspTreeData 	struct2Fill
						)
					)
				)
			)
			else if struct2read.ChunkType[1][i] == 0x000D AND \
				struct2read.ChunkType[2][i] == 0xCCCC then
			(
				fseek bstream struct2read.FileOffset[1][i] #seek_set --jump to offset
				
				if struct2read.ChunkVersion[1][i] == 0x0829 then --if 0x0829
				(
					local struct2Fill = CONTROLLER_CHUNK_DESC_0829()
					
					local A 	= readshort bstream #unsigned --should be 0x000D
					local B 	= readshort bstream #unsigned --should be 0xCCCC
					local C 	= readshort bstream --should be 0x0829				
						local D 	= readshort bstream --usually 0x0000 unknown --we do not check for this as we do not know what it is
					local F 	= readlong bstream #unsigned
					local ID = 0
					
					if fileHeader.version == 0x0745 then
					(
						ID = readlong bstream --chunk ID --//new in version 0x0745
						
						--confirm we are on the right chunk
						if  A == 0x000D AND \
							B == 0xCCCC AND \			
							C == 0x0829 AND \
							ID == struct2read.ChunkID[1][i] AND \
							F == struct2read.FileOffset[1][i] then
						(							
							--Store the Chunk ID
							struct2fill.chunkID = ID
							
							fill_CONTROLLER_CHUNK_DESC_0829 \
																				bstream:		bstream \
																				struct2Fill:		&struct2Fill
							
							Append 		::g_CONTROLLER_CHUNK_DESC_0829 	struct2Fill
						)
					)
				)
			)
			
		)
	),
	
	fn read_CHUNK_GAHCAF_INFO \
												caller: \
												bstream: \
												global_Append: =
	(
		if bstream != undefined then
		(
			if bstream != unsupplied then
			(
				if iskindof bstream BinStream then
				(		
					--Put code in here
					print "We are inside the read_CHUNK_GAHCAF_INFO\n"
					
					--------------------Constants-----------------------
					inst_ChunkTypes = ChunkTypes()

					---------------------------------------- Check that the file indeed has the "CryTek" header ----------------------------------------
					local inst_FILE_HEADER = FILE_HEADER()
					
					inst_FILE_HEADER.Signature = ReadFixedString \
																					bstream:	&bstream \
																					fixedLen:	&(::g__CONST_SIGN_length)	--this will be checked later, must be "CryTek"				
					
					--We do NOT use stricmp here because we want the comparison to be case sensitive - to keep it strongly strict
					if inst_FILE_HEADER.Signature == ::g_CryTek_string then
					(
						local STAT = true
						
						read_FILE_HEADER \
													bstream:			bstream \
													struct2fill:			&inst_FILE_HEADER \
													global_Append:	::g_CAF_FILE_HEADER \
													STAT:				&STAT
						
						if STAT then
						(
							local inst_CHUNKTABLE_FILE_CONSTANTS = CHUNKTABLE_FILE_CONSTANTS()
							read_CHUNKTABLE_FILE_CONSTANTS \
																				bstream:			bstream \
																				struct2read:		inst_FILE_HEADER \
																				struct2fill:			&inst_CHUNKTABLE_FILE_CONSTANTS \
																				global_Append: 	::g_CAF_CHUNKTABLE_FILE_CONSTANTS \
																				STAT:				&STAT
							
							if STAT then
							(
								--Can only be 1 (meaning there can only be one table in each CryFile - naturally)
								if ::g_CHUNKTABLE_FILE_CONSTANTS.count == 1 then
								(				
									--Read ChunkTable
									inst_CHUNKTABLE_0744_0745 = CHUNK_TABLE_0744_0745() --create instance of struct
									read_ChunkTable_0744_0745 \
																			bstream:			bstream \
																			struct2read_A:	inst_FILE_HEADER \
																			struct2read_B:	inst_CHUNKTABLE_FILE_CONSTANTS \
																			struct2fill:			&inst_CHUNKTABLE_0744_0745 \
																			global_Append:	::g_CAF_CHUNKTABLE_0744_0745 \
																			STAT:				&STAT
									if STAT then
									(
										format "STAT: %\n" STAT
										
										read_CHUNK_GAHCAF \
																		bstream:		bstream \
																		fileHeader:		inst_FILE_HEADER \
																		struct2read:	inst_CHUNKTABLE_0744_0745
									)									
								)
							)							
						)						
					)
					else
					(
						format "***Signature Check Failed - Cannot create BinStream - Aborting CAF reading***\n"
					)					
				)
				else
				(
					format "***This is not a BinStream - Aborting CAF reading***\n"
				)
			)
			else
			(
				format "***BinStream is unsupplied - Aborting CAF reading***\n"
			)
		)
		else
		(
			format "***BinStream is undefined - Aborting CAF reading***\n"
		)
	),
	
	fn load_CAF \
						caller: \
						CAF_file: =
	(
		if CAF_file != undefined then
		(
			if CAF_file != unsupplied then
			(
				-----------------------------------Load--------------------------------------
				bstream = fopen CAF_file "rb" --open binary stream

				--//////////////////////////
				if caller == "IMG" OR \
					caller == ".img" then
				(
					read_CHUNK_GAHCAF_INFO \
															caller:		caller \
															bstream:	bstream	
				)
				else if caller == "CAF" OR \
					caller == ".caf" then
				(
					read_CHUNK_GAHCAF_INFO \
															caller:		caller \
															bstream:	bstream	
				)
				--//////////////////////////						
				
				--------------------------------End of Load---------------------------------
				fclose bstream	--Close & Flush Binary Stream
			)
		)
	)
	
)