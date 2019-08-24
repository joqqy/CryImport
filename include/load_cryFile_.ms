

fn load_cryFile \
						&M_FILE_EXISTS_BOOL: \
						&M_TEST_BOOL: \
						caller: \
						nodeCaller: \
						typeCaller: \
						currFileType: \
						&bstream: \
						&mtlFile: \ -----
						&g_cryFile_m: \ -----
						&inst_Sub_Meshes: \
						&inst_CDF_Model: \
						&inst_CDF_Attachment: \
						&inst_CDF_Modifiers: =
(	
	if bstream != unsupplied then
	(
		if bstream != undefined then
		(
			if iskindof bstream BinStream then
			(
				--------------------Constants-----------------------
				inst_ChunkTypes = ChunkTypes()

				---------------------------------------- Check that the file indeed has the "CryTek" header ----------------------------------------
				local inst_FILE_HEADER = FILE_HEADER()
-- 				inst_FILE_HEADER.Signature = ReadFixedString bstream ::g__CONST_SIGN_length	--this will be checked later, must be "CryTek"	--case sensitive	

				inst_FILE_HEADER.Signature = ReadFixedString \
																				bstream:bstream \
																				fixedLen:(::g__CONST_SIGN_length)		--this will be checked later, must be "CryTek"	--case sensitive
										
				
				--We do NOT use stricmp here because we want the comparison to be case sensitive - to keep it strongly strict
				if inst_FILE_HEADER.Signature == ::g_CryTek_string then
				(
					local STAT = false
					
					read_FILE_HEADER \
												bstream:			&bstream \
												struct2fill:			&inst_FILE_HEADER \
												global_Append:	::g_FILE_HEADER \
												STAT:				&STAT

					if STAT then
					(
						inst_CHUNKTABLE_FILE_CONSTANTS = CHUNKTABLE_FILE_CONSTANTS()
						read_CHUNKTABLE_FILE_CONSTANTS \
																			bstream:			&bstream \
																			struct2read:		&inst_FILE_HEADER \
																			struct2fill:			&inst_CHUNKTABLE_FILE_CONSTANTS \
																			global_Append: 	::g_CHUNKTABLE_FILE_CONSTANTS \
																			STAT:				&STAT						
						
						if STAT then
						(
-- 							--Can only be 1 (meaning there can only be one table in each CryFile - naturally)
							if ::g_CHUNKTABLE_FILE_CONSTANTS.count == 1 then
							(				
								--Read ChunkTable
								inst_CHUNKTABLE_0744_0745 = CHUNK_TABLE_0744_0745() --create instance of struct
								read_ChunkTable_0744_0745 \
																		bstream:			&bstream \
																		struct2read_A:	&inst_FILE_HEADER \
																		struct2read_B:	&inst_CHUNKTABLE_FILE_CONSTANTS \
																		struct2fill:			&inst_CHUNKTABLE_0744_0745 \
																		global_Append:	::g_CHUNKTABLE_0744_0745 \
																		STAT:				&STAT
								
-- 								format 		"inst_CHUNKTABLE_0744_0745 % \n" 		inst_CHUNKTABLE_0744_0745
-- 								format 		"STAT: %\n" 										STAT								
								
								if STAT then
								(									
									--Read Source Info
									--SOURCE_INFO() structs created runtime
									read_SOURCE_INFO \
																bstream:			&bstream \
																fileHeader:			&inst_FILE_HEADER \
																struct2read: 		&inst_CHUNKTABLE_0744_0745	\
																global_Append:	::g_SOURCE_INFO									
									
									--Read Export Flags
									--EXPORT_FLAGS_CHUNK_DESC() structs created runtime
									read_EXPORT_FLAGS_CHUNK_DESC \
																					bstream:			&bstream \
																					fileHeader:			&inst_FILE_HEADER \
																					struct2read:		&inst_CHUNKTABLE_0744_0745 \
																					global_Append:	::g_EXPORT_FLAGS_CHUNK_DESC

									
									--Read Timing Info
									--TIMING_CHUNK_DESC_0918(), TIMING_CHUNK_DESC_0919() and RANGE_ENTITY() created runtime
									read_TIMING_CHUNK_DESC_0918 \
																					bstream:			&bstream \
																					fileHeader:			&inst_FILE_HEADER \
																					struct2read:		&inst_CHUNKTABLE_0744_0745 \
																					global_Append:	::g_TIMING_CHUNK_DESC
									
									

									--Read material name
									--MTL_NAME_CHUNK_DESC_0802() created runtime
									read_CHUNK_0x0014 \
																bstream:			&bstream \
																fileHeader:			&inst_FILE_HEADER \
																struct2read:		&inst_CHUNKTABLE_0744_0745 \
																global_Append:	::g_MTL_NAME_CHUNK_DESC									
									
									--Physics description - CryHeaders.h 711
									read_MESH_PHYSICS_DATA_CHUNK_DESC_0800 \
																										bstream:			&bstream \
																										fileHeader:			&inst_FILE_HEADER \
																										struct2read:		&inst_CHUNKTABLE_0744_0745 \
																										global_Append:	::g_MESH_PHYSICS_DATA_CHUNK_DESC_0800
									
									--/*
									----------------------------------------------------------- Read Streams and Build Meshes ----------------------------------------------------------------
									--We read all the DataStreams (including Array of mesh subsets) in here, structs are created runtime
									inst_MESH_SUBSETS_CHUNK_DESC_0800 = MESH_SUBSETS_CHUNK_DESC_0800()
									read_CHUNK_0017 \
																M_FILE_EXISTS_BOOL:		&M_FILE_EXISTS_BOOL \
																M_TEST_BOOL:				&M_TEST_BOOL \
																caller:							caller \
																nodeCaller:						nodeCaller \
																typeCaller:						typeCaller \
																currFileType:					currFileType \
																bstream:						&bstream \
																mtlFile:							&mtlFile \
																g_cryFile_m:					&g_cryFile_m \
																fileHeader:						&inst_FILE_HEADER \
																struct2read:					&inst_CHUNKTABLE_0744_0745 \																
																inst_Sub_Meshes:			&inst_Sub_Meshes \
																inst_CDF_Model:				&inst_CDF_Model \
																inst_CDF_Attachment:		&inst_CDF_Attachment \
																inst_CDF_Modifiers:			&inst_CDF_Modifiers
									----------------------------------------------------------------------------------------------------------------------------------------------------------------
									--*/
								)
							)	
						)
						else
						(
							format "\n*****Failed to read Chunk Table - ABORTING!*****\n"
						)	
					)
					else
					(
						format "\n*****Failed to read File Header - ABORTING!*****\n"
					)
				)
				else
				(
					format "\n*****CryTek Signature check failed - ABORTING!*****\n"
				)
			)
			else
			(
				format "\n*****Binary Stream is invalid - ABORTING!*****\n"
			)
		)
		else
		(
			format "\n*****Binary Stream is undefined - ABORTING!*****\n"
		)
	)
	else
	(
		format "\n*****Binary Stream is unsupplied - ABORTING!*****\n"
	)
)