--joqqyhez@gmail.com

struct init_Builders
(
	fn prepare_DATA \	
							&M_FILE_EXISTS_BOOL: \
							&M_TEST_BOOL: \
							caller: \
							nodeCaller: \
							typeCaller: \
							currFileType: \								
							&struct2read: \
							&mtlFile: \
							&g_cryFile_m: \
							&inst_CDF_Model: \
							&inst_CDF_Attachment: \
							&inst_Sub_Meshes: =
	(
		local Export_EFlags = 0
		
		--Export Flags
		if ::inst_LOADED != undefined then
		(
			if ::inst_LOADED._skin != undefined then
			(
				if ::inst_LOADED._skin.count > 0 then
				(
					if ::inst_LOADED._skin[1].g_EXPORT_FLAGS_CHUNK_DESC != undefined then
					(
						Export_EFlags = ::inst_LOADED._skin[1].g_EXPORT_FLAGS_CHUNK_DESC[1].flags						

						format "Export Flag: %\n" ::inst_LOADED._skin[1].g_EXPORT_FLAGS_CHUNK_DESC
					)
				)
			)
		)

		local fileType1 		= getINISetting 	::g_iniFile 	"fileType" 	"fileType1"	
		local fileType2 		= getINISetting 	::g_iniFile 	"fileType" 	"fileType2"	
		
		if ::rollout_Report.chk_BUILDER_Report.state then
		(	
			format 	"currFileType: %\n" 		currFileType
			format 	"fileType1: %\n" 			fileType1
			format 	"fileType2: %\n" 			fileType2
		)
		
		--Prepare the LOADED arrays
		store_global_arrays \
									currFileType: 	currFileType \								
									fileType1:		fileType1 \
									fileType2:		fileType2	
		set_modelStates \
								currFileType: 	currFileType \							
								fileType1:		fileType1 \
								fileType2:		fileType2		
		
		if 	(stricmp currFileType ".skin") == 0 OR \
			(stricmp currFileType ".cgf") == 0 OR \
			(stricmp currFileType ".chr") == 0 OR \
			(stricmp currFileType ".cga") == 0 then
		(
			inst_Sub_Meshes._LOADED 		= ::_LOADED
		)
		else if	(stricmp currFileType ".skinm") == 0 OR \
					(stricmp currFileType ".cgfm") == 0 OR \
					(stricmp currFileType ".chrm") == 0 OR \
					(stricmp currFileType ".cgam") == 0 then
		(
			inst_Sub_Meshes._LOADEDm 		= ::_LOADEDm
		)
	),
	
	fn call_Builders \	
						&M_FILE_EXISTS_BOOL: \
						&M_TEST_BOOL: \
						caller: \
						nodeCaller: \
						typeCaller: \
						currFileType: \								
						&struct2read: \
						&mtlFile: \
						&g_cryFile_m: \
						&inst_CDF_Model: \
						&inst_CDF_Attachment: \
						&inst_Sub_Meshes: =
	(		
		prepare_DATA \	
							M_FILE_EXISTS_BOOL: 	&M_FILE_EXISTS_BOOL \
							M_TEST_BOOL: 				&M_TEST_BOOL \
							caller: 							caller \
							nodeCaller: 					nodeCaller \
							typeCaller: 						typeCaller \
							currFileType: 					currFileType \								
							struct2read: 					&struct2read \
							mtlFile: 							&mtlFile \
							g_cryFile_m: 					&g_cryFile_m \
							inst_CDF_Model: 				&inst_CDF_Model \
							inst_CDF_Attachment: 		&inst_CDF_Attachment \
							inst_Sub_Meshes: 			&inst_Sub_Meshes
		
		
		local PASS_BOOL = false
	
		if 	M_FILE_EXISTS_BOOL then
		(
			if M_TEST_BOOL then
			(
				PASS_BOOL = true
				
-- 				format "---------------inst_Sub_Meshes._LOADED: % ---------------\n"		inst_Sub_Meshes._LOADED
-- 				format "---------------inst_Sub_Meshes._LOADEDm: % ---------------\n"	inst_Sub_Meshes._LOADEDm
			)
		)
		else
		(
			PASS_BOOL = true
			
-- 			format "---------------inst_Sub_Meshes._LOADED: % ---------------\n"		inst_Sub_Meshes._LOADED
-- 			format "---------------inst_Sub_Meshes._LOADEDm: % ---------------\n"	inst_Sub_Meshes._LOADEDm
		)
		
-- 		format "---------------::_LOADED[inst_Sub_Meshes.CA_SKIN_counter]: % ---------------\n"		::_LOADED[inst_Sub_Meshes.CA_SKIN_counter]
-- 		format "---------------::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter]: % ---------------\n"	::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter]
				
		
		
		
		--/*		
		try
		(
			local game = ::cryImport.ddl_CryGame.selected
			
			local inst_BUILDERS = BUILDERS() --create instance of class	
			if game == "Ryse" then
			(
			--//////////////////// Build the Meshes ////////////////////
				inst_BUILDERS.BUILD_MESH \									
													_LOADED:							&::_LOADED \
													_LOADEDm:							&::_LOADEDm \
													caller:								caller \
													nodeCaller:							nodeCaller \
													typeCaller:							typeCaller \													
													currFileType:						currFileType \
													Export_EFlags:					Export_EFlags \
													info_MeshSubset:				&struct2read \
													mtlFile:								&mtlFile \
													g_cryFile_m:						&g_cryFile_m \
													inst_CDF_Model:					&inst_CDF_Model \
													inst_CDF_Attachment: 			&inst_CDF_Attachment \
													inst_Sub_Meshes: 				&inst_Sub_Meshes
				--/////////////////////////////////////////////////////////
			)
			else if game == "Crysis" then
			(
				--//////////////////// Build the Meshes ////////////////////
				inst_BUILDERS.BUILD_MESH_Crysis \ 
															_LOADED:							&::_LOADED \
															_LOADEDm:							&::_LOADEDm \
															caller:								caller \
															nodeCaller:							nodeCaller \
															typeCaller:							typeCaller \
															currFileType:						currFileType \
															Export_EFlags:					Export_EFlags \
															info_MeshSubset:				&struct2read \
															mtlFile:								&mtlFile \
															g_cryFile_m:						&g_cryFile_m \
															inst_CDF_Model:					&inst_CDF_Model \
															inst_CDF_Attachment: 			&inst_CDF_Attachment \
															inst_Sub_Meshes: 				&inst_Sub_Meshes
			--/////////////////////////////////////////////////////////
			)
			else if game == "HFR" then
			(
				--//////////////////// Build the Meshes ////////////////////
				inst_BUILDERS.BUILD_MESH_HFR \ 
															_LOADED:							&::_LOADED \
															_LOADEDm:							&::_LOADEDm \
															caller:								caller \
															nodeCaller:							nodeCaller \
															typeCaller:							typeCaller \
															currFileType:						currFileType \
															Export_EFlags:					Export_EFlags \
															info_MeshSubset:				&struct2read \
															mtlFile:								&mtlFile \
															g_cryFile_m:						&g_cryFile_m \
															inst_CDF_Model:					&inst_CDF_Model \
															inst_CDF_Attachment: 			&inst_CDF_Attachment \
															inst_Sub_Meshes: 				&inst_Sub_Meshes
				--/////////////////////////////////////////////////////////
			)
			else if game == "Armored Warfare" then
			(
				--//////////////////// Build the Meshes ////////////////////
				inst_BUILDERS.BUILD_Armored_Warfare \ 
																	_LOADED:							&::_LOADED \
																	_LOADEDm:							&::_LOADEDm \
																	caller:								caller \
																	nodeCaller:							nodeCaller \
																	typeCaller:							typeCaller \
																	currFileType:						currFileType \
																	Export_EFlags:					Export_EFlags \
																	info_MeshSubset:				&struct2read \
																	mtlFile:								&mtlFile \
																	g_cryFile_m:						&g_cryFile_m \
																	inst_CDF_Model:					&inst_CDF_Model \
																	inst_CDF_Attachment: 			&inst_CDF_Attachment \
																	inst_Sub_Meshes: 				&inst_Sub_Meshes
				--/////////////////////////////////////////////////////////
			)				
		)
		catch
		(
			format "\n\n\n\n*** *** *** *** *** *** *** BUILD_MESH ERROR *** *** *** *** *** *** *** ***\n"
			format "%" (getCurrentException())
			format "\n*** *** *** *** *** *** END OF BUILD_MESH ERROR *** *** *** *** *** *** *** ***\n\n\n\n"		
		)	
		--*/		
	)
)