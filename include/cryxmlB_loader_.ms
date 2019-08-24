--joqqyhez@gmail.com

fn cryxmlB_loader \
							&_LOADED: \
							&_LOADEDm: \
							currFileType: \
							caller: \
							g_cryFile: \
							&mtlFile: \
							&inst_Sub_Meshes: \
							&inst_CDF_Model: \
							&inst_CDF_Attachment: \
							&inst_CDF_Modifiers: =
(
	get_game_dirPath()
	update_dirPath()
	
	if ::g_dirpath != undefined then
	(
		if pathConfig.isLegalPath ::g_dirpath then
		(
			g_cryFile = getINISetting ::g_iniFile "paths" "last_loaded"--The last file we loaded ???
			
			if g_cryFile != undefined then 
			(
				if doesfileexist g_cryFile then
				(
					inst_s_OPTIONS = s_OPTIONS()	--create instance
					
					if ::g_dds then
					(
						inst_s_OPTIONS.chk_dds = ::g_dds 		
					)

					inst_xmlB_PROCESSOR = xmlB_PROCESSOR() --create struct instance
					
					local MTL_NAME_CHUNK_DESC = #() --we set to 0, because we will pass this as a & reference					
					inst_xmlB_PROCESSOR.ret_CHUNK_DESC \ 
																			currFileType:								currFileType \
																			inst_Sub_Meshes:						&inst_Sub_Meshes \
																			MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC

					print "||||||||||||||||||||||||||||||||||||||||"
					print "||||||||||||||||||||||||||||||||||||||||"
					format "MTL_NAME_CHUNK_DESC: %\n" MTL_NAME_CHUNK_DESC
					print "||||||||||||||||||||||||||||||||||||||||"
					print "||||||||||||||||||||||||||||||||||||||||"

					
					if ::g_xmlB_Report 						then 	( inst_xmlB_PROCESSOR.report 							= true )
					if ::g_xmlB_Debug_Report				then 	( inst_xmlB_PROCESSOR.xmlB_Debug_Report 		= true )
					if ::g_Build_Material_Report 			then 	( inst_xmlB_PROCESSOR.Build_Material_Report 		= true )
					if ::g_skip_Lod_Materials				then 	( inst_xmlB_PROCESSOR.skip_Lod_Materials 			= true )
					if ::g_xmlB_Report_v2					then 	( inst_xmlB_PROCESSOR.xmlB_Report_v2 				= true )	

					try
					(					
						--CGFM
						if 	(getFilenameType g_cryFile) == ".cgf" OR \
							(getFilenameType g_cryFile) == ".cgfm" then
						(
							------------------------------ Process xmlB .mtl Material and Textures ------------------------------				
							inst_xmlB_PROCESSOR.cry_xmlB_ReaderV \		
																					_LOADED:									&_LOADED \
																					_LOADEDm:									&_LOADEDm \
																					currFileType:								currFileType \
																					inst_Sub_Meshes:						&inst_Sub_Meshes \
																					inst_CDF_Model:							&inst_CDF_Model \
																					inst_CDF_Attachment:					&inst_CDF_Attachment \
																					inst_CDF_Modifiers:						&inst_CDF_Modifiers \
																					g_curr_MaterialRef_node_counter:	&g_curr_MaterialRef_node_counter \																				
																					inst_s_OPTIONS:							&inst_s_OPTIONS \
																					MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
																					type:											".cgf" \
																					mtl_File:										&mtlFile
						)
						--CGAM
						if 	(getFilenameType g_cryFile) == ".cga" OR \
							(getFilenameType g_cryFile) == ".cgam" then
						(
							------------------------------ Process xmlB .mtl Material and Textures ------------------------------				
							inst_xmlB_PROCESSOR.cry_xmlB_ReaderV \
																					_LOADED:									&_LOADED \
																					_LOADEDm:									&_LOADEDm \
																					currFileType:								currFileType \
																					inst_Sub_Meshes:						&inst_Sub_Meshes \
																					inst_CDF_Model:							&inst_CDF_Model \
																					inst_CDF_Attachment:					&inst_CDF_Attachment \
																					inst_CDF_Modifiers:						&inst_CDF_Modifiers \
																					g_curr_MaterialRef_node_counter:	&g_curr_MaterialRef_node_counter \																				
																					inst_s_OPTIONS:							&inst_s_OPTIONS \
																					MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
																					type:											".cgf" \
																					mtl_File:										&mtlFile
						)
						--SKINM
						else if 	(getFilenameType g_cryFile) == ".skin" OR \
									(getFilenameType g_cryFile) == ".skinm" then
						(
							------------------------------ Process xmlB .mtl Material and Textures ------------------------------
							inst_xmlB_PROCESSOR.cry_xmlB_ReaderV \
																					_LOADED:									&_LOADED \
																					_LOADEDm:									&_LOADEDm \
																					currFileType:								currFileType \
																					inst_Sub_Meshes:						&inst_Sub_Meshes \
																					inst_CDF_Model:							&inst_CDF_Model \
																					inst_CDF_Attachment:					&inst_CDF_Attachment \
																					inst_CDF_Modifiers:						&inst_CDF_Modifiers \
																					g_curr_MaterialRef_node_counter:	&g_curr_MaterialRef_node_counter \
																					inst_s_OPTIONS:							&inst_s_OPTIONS \
																					MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
																					type:											".skin" \
																					mtl_File:										&mtlFile
						)
						--CHRM
						else if 	(getFilenameType g_cryFile) == ".chr" OR \
									(getFilenameType g_cryFile) == ".chrm" then
						(				
							------------------------------ Process xmlB .mtl Material and Textures ------------------------------
							inst_xmlB_PROCESSOR.cry_xmlB_ReaderV \	
																					_LOADED:									&_LOADED \
																					_LOADEDm:									&_LOADEDm \
																					currFileType:								currFileType \
																					inst_Sub_Meshes:						&inst_Sub_Meshes \
																					inst_CDF_Model:							&inst_CDF_Model \
																					inst_CDF_Attachment:					&inst_CDF_Attachment \
																					inst_CDF_Modifiers:						&inst_CDF_Modifiers \
																					g_curr_MaterialRef_node_counter:	&g_curr_MaterialRef_node_counter \
																					inst_s_OPTIONS:							&inst_s_OPTIONS \
																					MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
																					type:											".chr" \
																					mtl_File:										&mtlFile				
						)
						--CHRPARAMS
						else if (getFilenameType g_cryFile) == ".chrparams" then
						(		
							if (Binary_XML_custom_check File:g_cryFile type:"CryXmlB") then --if binary xml
							(
								inst_xmlB_PROCESSOR.cry_general_xmlB_ReaderV \
																									_LOADED:							&_LOADED \
																									_LOADEDm:							&_LOADEDm \
																									currFileType:						currFileType \
																									inst_Sub_Meshes:				&inst_Sub_Meshes \
																									inst_CDF_Model:					&inst_CDF_Model \
																									inst_CDF_Attachment:			&inst_CDF_Attachment \
																									inst_CDF_Modifiers:				&inst_CDF_Modifiers \
																									xmlBFile:								&g_cryFile \
																									inst_s_OPTIONS:					&inst_s_OPTIONS \
																									type:									".chrparams"
							)
							else
							(
							)
						)
						--CDF
						else if (getFilenameType g_cryFile) == ".cdf" then
						(
							if (Binary_XML_custom_check File:g_cryFile type:"CryXmlB") then --if binary xml
							(
								inst_xmlB_PROCESSOR.cry_general_xmlB_ReaderV \
																									_LOADED:							&_LOADED \
																									_LOADEDm:							&_LOADEDm \
																									currFileType:						currFileType \
																									inst_Sub_Meshes:				&inst_Sub_Meshes \
																									inst_CDF_Model:					&inst_CDF_Model \
																									inst_CDF_Attachment:			&inst_CDF_Attachment \
																									inst_CDF_Modifiers:				&inst_CDF_Modifiers \
																									xmlBFile:								&g_cryFile \
																									inst_s_OPTIONS:					&inst_s_OPTIONS \
																									type:									".cdf"
							)
							else
							(
								inst_xmlB_PROCESSOR.cry_general_xmlB_ReaderV \
																									_LOADED:							&_LOADED \
																									_LOADEDm:							&_LOADEDm \
																									currFileType:						currFileType \
																									inst_Sub_Meshes:				&inst_Sub_Meshes \
																									inst_CDF_Model:					&inst_CDF_Model \
																									inst_CDF_Attachment:			&inst_CDF_Attachment \
																									inst_CDF_Modifiers:				&inst_CDF_Modifiers \
																									xmlBFile:								&g_cryFile \
																									inst_s_OPTIONS:					&inst_s_OPTIONS \
																									type:									".cdf"
							)
						)
						--MTL
						else if (getFilenameType g_cryFile) == ".mtl" then
						(
							if (Binary_XML_custom_check File:g_cryFile type:"CryXmlB") then --if binary xml
							(
								inst_xmlB_PROCESSOR.cry_general_xmlB_ReaderV \
																									_LOADED:							&_LOADED \
																									_LOADEDm:							&_LOADEDm \
																									currFileType:						currFileType \
																									inst_Sub_Meshes:				&inst_Sub_Meshes \
																									inst_CDF_Model:					&inst_CDF_Model \
																									inst_CDF_Attachment:			&inst_CDF_Attachment \
																									inst_CDF_Modifiers:				&inst_CDF_Modifiers \
																									xmlBFile:								&g_cryFile \
																									inst_s_OPTIONS:					&inst_s_OPTIONS \
																									type:									".mtl"
							)
							else
							(
								examine_XML \
														g_cryFile: &g_cryFile
							)
						)
						--XML
						else if (getFilenameType g_cryFile) == ".xml" then
						(
							if (Binary_XML_custom_check File:g_cryFile type:"CryXmlB") then --if binary xml
							(
								inst_xmlB_PROCESSOR.cry_general_xmlB_ReaderV \
																									_LOADED:							&_LOADED \
																									_LOADEDm:							&_LOADEDm \
																									currFileType:						currFileType \
																									inst_Sub_Meshes:				&inst_Sub_Meshes \
																									inst_CDF_Model:					&inst_CDF_Model \
																									inst_CDF_Attachment:			&inst_CDF_Attachment \
																									inst_CDF_Modifiers:				&inst_CDF_Modifiers \
																									xmlBFile:								&g_cryFile \
																									inst_s_OPTIONS:					&inst_s_OPTIONS \
																									type:									".xml"
							)
							else
							(
							)
						)
					)
					catch
					(
						format "\n\n\n\n*** *** *** *** *** *** *** cryxmlB_loader 		ERROR *** *** *** *** *** *** *** ***\n"
						format "%" (getCurrentException())
						format "\n*** *** *** *** *** *** END OF 	cryxmlB_loader 	ERROR *** *** *** *** *** *** *** ***\n\n\n\n"	
					)
				)
			)			
		)
	)	
)
