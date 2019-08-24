
struct xmlB_PROCESSOR
(
	report 						= false,
	xmlB_Debug_Report 		= false,
	Build_Material_Report 	= false,
	skip_Lod_Materials 		= false,
	xmlB_Report_v2			= false,	
	
	fn ret_CHUNK_DESC \
								currFileType: \
								&inst_Sub_Meshes: \
								nStream: \ --not needed here (?)
								&MTL_NAME_CHUNK_DESC: =
	(
		if 	currFileType 							!= unsupplied AND \
			inst_Sub_Meshes 					!= unsupplied AND \
			MTL_NAME_CHUNK_DESC 			!= unsupplied then
		(
			if iskindof currFileType string then
			(
				case of
				(
					(stricmp currFileType ".cgf" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					(stricmp currFileType ".cgfm" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					(stricmp currFileType ".cga" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					(stricmp currFileType ".cgam" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					(stricmp currFileType ".skin" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					(stricmp currFileType ".skinm" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					(stricmp currFileType ".chr" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADED[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					(stricmp currFileType ".chrm" == 0):
					(
						if MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
							MTL_NAME_CHUNK_DESC = ::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC
					)
					default:
					(
						MTL_NAME_CHUNK_DESC = unsupplied
					)
				)
			)
		)
	),
	
	fn confirm_DB \						
						lineCount: \
						line2Check: \
						&PASS_BOOL: =
	(
		if lineCount == 1 then
		(
			local curr_Game 		= (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
			local check_game 	= filterString line2Check ";"
			
			if check_game.count == 2 then
			(
				if check_game[1] == "game" then
				(
					if check_game[2] == curr_Game then
					(
						update_dirPath()
						PASS_BOOL = true
					)
					else
					(
						exit;
					)
				)
			)
		)
	),
	
	fn simplest_mtl_search \
									&foundMTL: =
	(
		local dir 					= getFilenamePath 	::g_cryFile --returns: "g:\subdir1\subdir2\"
		local file 					= getFilenameFile 	::g_cryFile
		local suffix 				= ".mtl"								
		local testMTL_path 		= pathConfig.ResolvePathSymbols (pathConfig.AppendPath dir (file + suffix))

		if doesfileexist testMTL_path then
		(
			foundMTL = true
			::g_xml_Path = testMTL_path									
		)
	),
	
	fn quick_mtl_by_NodeName \
											&matID: \ --actual face matID, not material desc chunkID like the others below
											&foundMTL: \
											&_Name_: =											
	(	
		::g_NameMTL = #(#(),#())
		
		local dir = getINISetting 	g_iniFile 	"xmlB_paths" ".mtl"	
		
		if doesfileexist dir then
		(
			local files = getfiles (pathConfig.resolvePathSymbols  ((getFilenamePath dir) + "\\*.mtl"))
			
			if iskindof files Array then
			(
				for f in files do
				(
					if matchpattern f pattern:("*" + (_Name_ as string) + ".mtl") == true then
					(
						::g_xml_Path = f
						foundMTL = true;
						
						Appendifunique ::g_NameMTL[1] matID
						Appendifunique ::g_NameMTL[2] f
						
						exit; --No need to continue once we've found the matching .mtl
					)
				)
			)
		)
	),
	
	--////////////////////////////////////////////////////////////////
	fn quick_mtl_match \
								&foundMTL: \
								&MTL_NAME_CHUNK_DESC: \
								&matID: =
	(
		if NOT foundMTL then
		(
			if MTL_NAME_CHUNK_DESC[matID] != undefined then
			(
				format  "-------------------------------------------------------------------------- MTL_NAME_CHUNK_DESC[matID]: %\n" MTL_NAME_CHUNK_DESC[matID]		
			
				local mtlTest 			= (MTL_NAME_CHUNK_DESC[matID]._name + ".mtl")
				local mtlTestPath 	= pathConfig.ResolvePathSymbols (pathConfig.AppendPath (getFilenamePath ::g_cryFile) mtlTest)
							
				if doesfileexist mtlTestPath then
				(
					::g_xml_Path = mtlTestPath
					
					if ::g_xmlB_Debug_Report then
					(
						------	------	------	------	------	------	------	------	------	------	------	------	------
						format "### Quick MTL search ### ---------------------> Found .mtl match: %\n" ::g_xml_Path
						------	------	------	------	------	------	------	------	------	------	------	------	------
					)
					
					foundMTL = true;													
					exit; --No need to continue once we've found the matching .mtl	
				)
			)
		)
	),
	
	--If every check fails to locate the texture, then do a heuristic
	fn mtl_heuristic =
	(
		local fileName 				= (	filenameFromPath 	::g_cryfile	) --stripped of path
		local dir							= (	getFilenamePath 		::g_cryfile	) --only the dir (without the filename)
		local fileName_noSuffix 	= (	getFilenameFile  		::g_cryfile	) --raw filename without the suffix
		
		if ::rollout_Report.chk_Heuristic_Report.state then
		(
			format "### ### ### fileName: %\n" 				fileName
			format "### ### ### dir: %\n" 						dir
			format "### ### ### fileName_noSuffix: %\n"  	fileName_noSuffix
		)
				
		if doesfileexist dir then
		(
			filesArr = getFiles (dir + "*.mtl")
					
			if filesArr != undefined then
			(
				for f in filesArr do
				(
					local dirFile 		= filenameFromPath f --stripped of path
					
					dirFile_filtered = filterString dirFile "_"
					
					for s=1 to dirFile_filtered.count do
					(						
						arr_Select_filter = #()
						
						if 	(matchpattern dirFile_filtered[s] pattern:"mp") != true AND 
							(matchpattern dirFile_filtered[s] pattern:"*.mtl") != true AND
							dirFile_filtered[s].count > 1 then
						(
							if ::rollout_Report.chk_Heuristic_Report.state then
							(
								format "### ### ###-------------------------------- dirFile_filtered[s]: %\n" dirFile_filtered[s]
							)
							
							Append arr_Select_filter dirFile_filtered[s]
						)
						
						if ::rollout_Report.chk_Heuristic_Report.state then
						(
							format "### ### ###-------------------------------- arr_Select_filter: %\n" arr_Select_filter
						)
						
						for ss in arr_Select_filter do
						(
							if ::rollout_Report.chk_Heuristic_Report.state then
							(
								format "### ### ### ss: %\n" ss
							)
							
							if matchpattern fileName pattern:("*"+ss+"*") then
							(
								if ::rollout_Report.chk_Heuristic_Report.state then
								(
									format "### ### ### f: %\n" f
									format "### ### ### dirFile: %\n"  dirFile
								)
								
								if doesfileexist f then
								(
									::g_xml_Path = f
									
									if ::rollout_Report.chk_Heuristic_Report.state then
									(										
										format "---------------------> Found Heuristic .mtl match: %\n" ::g_xml_Path
									)																			
									exit; --No need to continue once we've found the matching .mtl	
								)
							)
						)						
					)					
				)
			)
		)
	),
	
	fn process_mtl_Line \
								&meshName: \
								&foundMTL: \
								&g_xml_Path: \
								&db_File: \
								&MTL_NAME_CHUNK_DESC: \
								&matID: \
								&mtl_Line: =
	(
		if MTL_NAME_CHUNK_DESC[matID] != undefined then
		(
			-----------------------------------------------------
			if NOT (matchpattern MTL_NAME_CHUNK_DESC[matID]._name pattern:"Material #*") then
			(
				if (matchpattern MTL_NAME_CHUNK_DESC[matID]._name pattern:"*/*") then
				(
					if matchpattern mtl_Line pattern:(MTL_NAME_CHUNK_DESC[matID]._name+"*") then
					(
						local mat_DESCR_name = MTL_NAME_CHUNK_DESC[matID]._name											
						check_4_mtl_suffix filePath:&mat_DESCR_name
																							
						if (stricmp mtl_Line mat_DESCR_name) == 0 then --returns undefined if there is no string match (case insensitive)
						(
							::g_xml_Path = pathConfig.ResolvePathSymbols (pathConfig.AppendPath ::g_dirPath mtl_Line) -- The full path to the .mtl (XML) file
																
							if doesfileexist ::g_xml_Path then
							(	
								if ::g_xmlB_Debug_Report then
								(
									format "######################-----------> Found .mtl match: %\n" ::g_xml_Path
								)
														
								foundMTL = true;
								exit; --No need to continue once we've found the matching .mtl
							)
						)								
					)
				)		
				else --no slashes in the descr name
				(
					if 	NOT (matchpattern mtl_Line pattern:"*$*") AND
						NOT (matchpattern mtl_Line pattern:"*\%*") then
					(
						local mat_DESCR_name 						= MTL_NAME_CHUNK_DESC[matID]._name
						local mat_DESCR_name_suffix 				= mat_DESCR_name
						check_4_mtl_suffix filePath:&mat_DESCR_name_suffix
																				
						if (matchpattern mtl_Line pattern:("*"+mat_DESCR_name_suffix)) then
						(
							if (stricmp (getFilenameType mtl_Line) ".mtl") == 0 then
							(
								::g_xml_Path = pathConfig.ResolvePathSymbols (pathConfig.AppendPath ::g_dirPath mtl_Line) -- The full path to the .mtl (XML) file	
																
								if doesfileexist ::g_xml_Path then
								(
									if ::g_xmlB_Debug_Report then
									(
										format "######################-----------> Found .mtl match: %\n" ::g_xml_Path
									)

									foundMTL = true;												
									exit; --No need to continue once we've found the matching .mtl	
								)
							)										
						)
						else if (matchpattern mtl_Line pattern:("*"+mat_DESCR_name)) then
						(
							if (stricmp (getFilenameType mtl_Line) ".mtl") == 0 then
							(
								::g_xml_Path = pathConfig.ResolvePathSymbols (pathConfig.AppendPath ::g_dirPath mtl_Line) -- The full path to the .mtl (XML) file	

								if doesfileexist ::g_xml_Path then
								(
									if ::g_xmlB_Debug_Report then
									(
										format "######################-----------> Found .mtl match: %\n" ::g_xml_Path
									)
															
									foundMTL = true;													
									exit; --No need to continue once we've found the matching .mtl	
								)
							)
						)
					)
				)
			)
		)
	),
	
	fn process_meshName \
								&meshName: \
								&foundMTL: \
								&g_xml_Path: \
								&db_File: \
								&MTL_NAME_CHUNK_DESC: \
								&matID: \
								&mtl_Line: =
	(
		local mat_DESCR_name 						= meshName
		local mat_DESCR_name_suffix 				= mat_DESCR_name
		check_4_mtl_suffix \
									filePath:		&mat_DESCR_name_suffix
																			
		if (matchpattern mtl_Line pattern:("*"+mat_DESCR_name_suffix)) then
		(
			if (stricmp (getFilenameType mtl_Line) ".mtl") == 0 then
			(
				::g_xml_Path = pathConfig.ResolvePathSymbols (pathConfig.AppendPath ::g_dirPath mtl_Line) -- The full path to the .mtl (XML) file	
																
				if doesfileexist ::g_xml_Path then
				(
					if ::g_xmlB_Debug_Report then
					(
						format "######################-----------> Found .mtl match: %\n" ::g_xml_Path
					)

					foundMTL = true;												
					exit; --No need to continue once we've found the matching .mtl	
				)
			)										
		)
		else if (matchpattern mtl_Line pattern:("*"+mat_DESCR_name)) then
		(
			if (stricmp (getFilenameType mtl_Line) ".mtl") == 0 then
			(
				::g_xml_Path = pathConfig.ResolvePathSymbols (pathConfig.AppendPath ::g_dirPath mtl_Line) -- The full path to the .mtl (XML) file	

				if doesfileexist ::g_xml_Path then
				(
					if ::g_xmlB_Debug_Report then
					(
						format "######################-----------> Found .mtl match: %\n" ::g_xml_Path
					)
														
					foundMTL = true;													
					exit; --No need to continue once we've found the matching .mtl	
				)
			)
		)
	),
	
	fn dotNet_readLines_filtered \
											&meshName: \
											&foundMTL: \
											&g_xml_Path: \											
											&MTL_NAME_CHUNK_DESC: \
											&matID: \											
											&g_db_type: \
											&db_File: \
											filterToken: \
											&fstream: = --not used for now
	(		
		local StreamReader	 	= dotNetObject "System.IO.StreamReader" db_File --open dotNet stream
		local mtl_Line = ""

		while mtl_Line != undefined do
		(
			mtl_Line = streamReader.ReadLine()
									
			if mtl_Line != undefined then
			(
				local mtl_Line_filtered = filterstring mtl_Line filterToken
				
				if mtl_Line_filtered.count == 2 then
				(
					local str = mtl_Line_filtered[2]
					
					if NOT matchpattern str pattern:"*$*" then
					(					
						if  stricmp (getFilenameType str) ("." + g_db_type) == 0 then
						(		
							if meshName == unsupplied then
							(
								process_mtl_Line \
														meshName: 						&meshName \
														foundMTL: 							&foundMTL \
														g_xml_Path:						&g_xml_Path \
														db_File: 								&db_File \
														MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
														matID: 								&matID \
														mtl_Line:							&mtl_Line
							)
							else --we try to search by the meshName instead
							(
								process_meshName \
															meshName: 						&meshName \
															foundMTL: 							&foundMTL \
															g_xml_Path:						&g_xml_Path \
															db_File: 								&db_File \
															MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
															matID: 								&matID \
															mtl_Line:							&mtl_Line
							)
						)
					)
				)
			)
		)
		StreamReader.Close() --Close dotNet stream
	),
	
	fn search_db \	
						&meshName: \
						&foundMTL: \
						&g_xml_Path: \
						&db_File: \
						&MTL_NAME_CHUNK_DESC: \
						&matID: =
	(
		format "db_File -----> %\n" db_File
		
		if NOT foundMTL then
		(
			if NOT doesfileexist ::g_xml_Path then
			(
				---------------------------------------- Quick Try if chosen --------------------------------------------
				if ::rollout_options.chk_quickMTL_Match.state then
				(
					quick_mtl_match \
											foundMTL:							&foundMTL \
											MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
											matID:								&matID
				)
				-------------------------------------------------------------------------------------------------------------
				
				if NOT ::rollout_Tools.ckb_use_custom_ResourceList.state then
				(
					if doesfileexist db_File then
					(
						local lineCount 		= 0
						local PASS_BOOL 	= false
						
						local StreamReader	 	= dotNetObject "System.IO.StreamReader" db_File --open dotNet stream			
						local mtl_Line = ""
						
						while mtl_Line != undefined do
						(
							lineCount +=1
							mtl_Line = streamReader.ReadLine()
												
							if mtl_Line != undefined then
							(
								if classof mtl_Line == String then
								(
									confirm_DB \
													lineCount: 		lineCount \
													line2Check: 	mtl_Line \
													PASS_BOOL: 	&PASS_BOOL
									
									if PASS_BOOL then
									(
										if meshName == unsupplied then
										(
											process_mtl_Line \
																	meshName: 						&meshName \
																	foundMTL: 							&foundMTL \
																	g_xml_Path:						&g_xml_Path \
																	db_File: 								&db_File \
																	MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
																	matID: 								&matID \
																	mtl_Line:							&mtl_Line
										)
										else --we try to search by the meshName instead
										(
											process_meshName \
																		meshName: 						&meshName \
																		foundMTL: 							&foundMTL \
																		g_xml_Path:						&g_xml_Path \
																		db_File: 								&db_File \
																		MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
																		matID: 								&matID \
																		mtl_Line:							&mtl_Line
										)
									)									

								)
							)
						)
						StreamReader.Close() --Close dotNet stream
						
-- 						backup_Process \
-- 												meshName: 						&meshName \
-- 												foundMTL: 							&foundMTL \
-- 												g_xml_Path:						&g_xml_Path \
-- 												db_File: 								&db_File \
-- 												MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
-- 												matID: 								&matID \
-- 												mtl_Line:							&mtl_Line
					)
				)
				else
				(
					local g_db_type = "mtl"
					
					if inst_ResourceLists != undefined then
					(
						for i=1 to inst_ResourceLists.perLayer.count do
						(
							if doesfileexist inst_ResourceLists.perLayer[i] then
							(
								local db_File =  inst_ResourceLists.perLayer[i]
								
								format "Inside perlayer \n"
								
								dotNet_readLines_filtered \
																	meshName: 						&meshName \
																	foundMTL: 							&foundMTL \
																	g_xml_Path: 						&g_xml_Path \											
																	MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
																	matID: 								&matID \											
																	g_db_type: 						&g_db_type \
																	db_File: 								&db_File \
																	filterToken: 						";"
							)
						)
						
						for i=1 to inst_ResourceLists.auto.count do
						(
							if doesfileexist inst_ResourceLists.auto[i] then
							(
								local db_File =  inst_ResourceLists.auto[i]
								
								format "Inside auto \n"
								
								dotNet_readLines_filtered \
																	meshName: 						&meshName \
																	foundMTL: 							&foundMTL \
																	g_xml_Path: 						&g_xml_Path \											
																	MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
																	matID: 								&matID \											
																	g_db_type: 						&g_db_type \
																	db_File: 								&db_File \
																	filterToken: 						";"
							)
						)
						
						for i=1 to inst_ResourceLists.resourceList.count do
						(
							if doesfileexist inst_ResourceLists.resourceList[i] then
							(
								local db_File =  inst_ResourceLists.resourceList[i]
								
								format "Inside resourceList \n"
								
								dotNet_readLines_filtered \
																	meshName: 						&meshName \
																	foundMTL: 							&foundMTL \
																	g_xml_Path: 						&g_xml_Path \											
																	MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
																	matID: 								&matID \											
																	g_db_type: 						&g_db_type \
																	db_File: 								&db_File \
																	filterToken: 						";"
							)
						)
					)
				)
			)
		)
	),
	
	fn backup_Process \
								&meshName: \
								&foundMTL: \
								&g_xml_Path: \
								&db_File: \
								&MTL_NAME_CHUNK_DESC: \
								&matID: \
								&mtl_Line: =
	(
		--We found nothing - search the other 0x00000014 if present
		if NOT doesfileexist ::g_xml_Path  then --Material names that have # in them, are probably errors in the naming, try to look for the material instead based on it's mesh name!
		(
			for id=1 to MTL_NAME_CHUNK_DESC.count do
			(
				if id != matID then --we don't want to test the matid, because we already did, and found nothing, that is why we are here!
				(			
					--Recurse
					search_db \									
									foundMTL:								&foundMTL \
									g_xml_Path:							&::g_xml_Path \
									db_File: 									&db_File \
									MTL_NAME_CHUNK_DESC:			&MTL_NAME_CHUNK_DESC \
									matID:									&id
				)
			)
		)

		--We found nothing - try to search using the mesh name
		if NOT doesfileexist ::g_xml_Path  then --Material names that have # in them, are probably errors in the naming, try to look for the material instead based on it's mesh name!
		(
			for id=1 to MTL_NAME_CHUNK_DESC.count do
			(
				if id != matID then --we don't want to test the matid, because we already did, and found nothing, that is why we are here!
				(
					--Recurse
					search_db \	
									meshName:								&::g_cryfile \
									foundMTL:								&foundMTL \
									g_xml_Path:							&::g_xml_Path \
									db_File: 									&db_File \
									MTL_NAME_CHUNK_DESC:			&MTL_NAME_CHUNK_DESC \
									matID:									&id
				)
			)
		)
	),
	
	fn search_Resource_Lists \
										&meshName: \
										&g_xml_Path: \
										&auto_resourcelist: \
										&mtl_Line: \
										&foundMTL: \
										&MTL_NAME_CHUNK_DESC: \
										&matID: =
	(
		--We do a last try to find the .mtl (usually .chr, if they have a non path name in 0xCCCC0014 without the .mtl then it is very possible that this is the .mtl name
		--And doing it here, before the loop has ended, will enable us to possibly find the .mtl much faster, and simply exit if we have a positive match!
		--Thus we can avoid looping all the asset resource files if we find a quick match! - if we are lucky
		
		if NOT foundMTL then
		(
			if NOT doesfileexist ::g_xml_Path then
			(
				---------------------------------------- Quick Try if chosen --------------------------------------------
				if ::rollout_options.chk_quickMTL_Match.state then
				(
					quick_mtl_match \
											foundMTL:							&foundMTL \
											MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
											matID:								&matID
				)
				-------------------------------------------------------------------------------------------------------------
				
				if meshName == unsupplied then
				(
					process_mtl_Line \
											meshName: 						&meshName \
											foundMTL: 							&foundMTL \
											g_xml_Path:						&g_xml_Path \
											db_File: 								&db_File \
											MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
											matID: 								&matID \
											mtl_Line:							&mtl_Line					
				)
				else
				(
					process_meshName \
												meshName: 						&meshName \
												foundMTL: 							&foundMTL \
												g_xml_Path:						&g_xml_Path \
												db_File: 								&db_File \
												MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
												matID: 								&matID \
												mtl_Line:							&mtl_Line
				)
			)
			
			backup_Process \
									meshName: 						&meshName \
									foundMTL: 							&foundMTL \
									g_xml_Path:						&g_xml_Path \
									db_File: 								&db_File \
									MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
									matID: 								&matID \
									mtl_Line:							&mtl_Line
		)
	),
	
	fn search_db_texRef \
								&foundMTL: \
								&filePath: \
								&db_File: \
								&mtl_Line: \
								&idx: =
	(		
		local lineCount 		= 0
		local PASS_BOOL 	= false
		
		if doesfileexist db_File then
		(
			local StreamReader	 	= dotNetObject "System.IO.StreamReader" db_File --open dotNet stream
			
			if mtl_Line != unsupplied then
			(
				if mtl_Line != undefined then
				(				
					------------------------------------------------------------------
					local mtl_ReadLine = ""				
					while mtl_ReadLine != undefined do
					(
						lineCount += 1
						mtl_ReadLine = streamReader.ReadLine()						

						if mtl_ReadLine != undefined then
						(
							if iskindof mtl_ReadLine string then
							(								
								if mtl_ReadLine != "" then
								(									
									confirm_DB \
													lineCount: 		lineCount \
													line2Check: 	mtl_ReadLine \
													PASS_BOOL: 	&PASS_BOOL

									if PASS_BOOL then
									(									
										if matchpattern mtl_ReadLine pattern:("*"+mtl_Line+".mtl") then
										(							
											check_4_mtl_suffix filePath:&mtl_ReadLine									
											filePath = pathConfig.ResolvePathSymbols (pathConfig.AppendPath ::g_dirPath mtl_ReadLine) -- The full path to the .mtl (XML) file
																
											if doesfileexist filePath then
											(	
												if ::rollout_Report.chk_NameMTLRef_Report.state then
												(
													format "---------------------> Found .mtl match: %\n" filePath
												)
														
												foundMTL = true;
												exit; --No need to continue once we've found the matching .mtl
											)							
										)
									)
									
								)								
							)
						)
					)
					------------------------------------------------------------------
					
				)
			)
			StreamReader.Close() --Close dotNet stream
		)
	),
	
	fn dds0_to_dds \
							&texPath: =
	(
		if (getFilenameType texPath) == ".0" then
		(
			texPath = substring texPath 1 (texPath.count-2)
		)
	),
	
	fn search_db_NOmtl_texRef \
											&db_File: \
											&mtl_Line: \
											&idx: =
	(
		local lineCount 		= 0
		local PASS_BOOL 	= false		
		
		arr_idx = #()
		arr_tex = #()
		
		if doesfileexist db_File then
		(
			local StreamReader	 	= dotNetObject "System.IO.StreamReader" db_File --open dotNet stream
			
			if mtl_Line != unsupplied then
			(
				if mtl_Line != undefined then
				(				
					------------------------------------------------------------------
					local tex_ReadLine 	= ""				
					while tex_ReadLine != undefined do
					(
						lineCount += 1
						tex_ReadLine = streamReader.ReadLine()						

						if tex_ReadLine != undefined then
						(
							if iskindof tex_ReadLine string then
							(
								if tex_ReadLine != "" then
								(
									confirm_DB \
													lineCount: 		lineCount \
													line2Check: 	tex_ReadLine \
													PASS_BOOL: 	&PASS_BOOL
									
									if PASS_BOOL then
									(
										local pattern = ("*"+mtl_Line+"*")
										if (matchpattern tex_ReadLine pattern:pattern) then
										(
											local texPath = pathConfig.ResolvePathSymbols (pathConfig.AppendPath ::g_dirPath tex_ReadLine) -- The full path to the .mtl (XML) file
											dds0_to_dds \
																texPath: &texPath
																
											if doesfileexist texPath then
											(	
												if ::rollout_Report.chk_NametexRef_Report.state then
												(
													format "---------------------> Found .mtl match: %\n" texPath
												)
												
												Append ::g_TEXRef_array #(idx, texPath)						
											)							
										)
									)
									
								)
							)
						)
					)
					------------------------------------------------------------------					
				)
			)
			StreamReader.Close() --Close dotNet stream
		)
		
		--Make unique array
		for i=1 to g_TEXRef_array.count do
		(
			Append arr_idx ::g_TEXRef_array[i][1]
			AppendifUnique arr_tex ::g_TEXRef_array[i][2]
		)

		::g_TEXRef_array = #()
		for i=1 to arr_tex.count do
		(
			Append ::g_TEXRef_array #(arr_idx[i], arr_tex[i])
		)

	),
	
	fn dotNet_readLines \
								&matID: \
								&g_xml_Path: \
								&auto_resourcelist: \
								&mtl_Line: \
								&foundMTL: \
								&MTL_NAME_CHUNK_DESC: \
								&streamReader: =
	( 
		while mtl_Line != undefined do
		(
			mtl_Line = streamReader.ReadLine()
								
			if mtl_Line != undefined then
			(
-- 				for matid=1 to MTL_NAME_CHUNK_DESC.count do							
-- 				(
					search_Resource_Lists \
													g_xml_Path:							&g_xml_Path \
													auto_resourcelist:					&auto_resourcelist \
													mtl_Line:								&mtl_Line \
													foundMTL:								&foundMTL \
													MTL_NAME_CHUNK_DESC:			&MTL_NAME_CHUNK_DESC \
													matID:									&matID
-- 				)
			)
		)
		StreamReader.Close()
	),
	
	fn maxScript_readLines \
									&matID: \
									&g_xml_Path: \
									&auto_resourcelist: \
									&mtl_Line: \
									&foundMTL: \
									&MTL_NAME_CHUNK_DESC: =
	(
		if auto_resourcelist != unsupplied then
		(
			if auto_resourcelist != undefined then
			(
				if doesfileexist auto_resourcelist then
				(
					RF = openFile auto_resourcelist
					--------------------------------------------------
					while 	NOT 	eof RF 		AND
								NOT 	foundMTL 	do
					(						
						local mtl_Line 	= (readLine RF)
											
						if mtl_Line != undefined then
						(
-- 							for i=1 to MTL_NAME_CHUNK_DESC.count do							
-- 							(
								search_Resource_Lists \
																g_xml_Path:						&g_xml_Path \
																auto_resourcelist:				&auto_resourcelist \
																mtl_Line:							&mtl_Line \
																foundMTL:							&foundMTL \
																MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
																matID:								&matID
-- 							)
						)								
					)
					--------------------------------------------------
					flush RF
					close RF
					free RF
				)
			)
		)
	),
	--////////////////////////////////////////////////////////////////	

	
	fn mtl_emptyTexSlot_v2 \
										&filePath: \										
										&matNodeCounter: \
										&mtl_Line: \
										&inst_s_OPTIONS: =
	(
		local db_dir = pathConfig.resolvePathSymbols (::g_scriptRoot + "\\db")
		local db_name = ::g_db_type + "_db.txt"
		local db_File = pathConfig.resolvePathSymbols (pathConfig.AppendPath 	db_dir 	db_name)
					
		local foundMTL = false
		
		if ::g_db_type != "" then
		(
			if NOT doesfileexist db_File then
			(
				inst_build_resource_db 			= build_resource_db() --create instance
				inst_build_resource_db.builder \
															g_db_type: &::g_db_type
			)
		)
		
		if doesfileexist db_File then --if the database .txt file exists
		(			
			-- Entering this causes a problem in .cga --or takes too long to execute, maybe because the database is for Ryse rather than Homefront
			-- which means it has to search ALL the files because it never gets a match, thus taking too long to execute
			-- Should we try to build game specific databases? (we will put in *game;<current game>* in the first line, and check the game before starting the search!)
			-- Now we have tested this, and it seems to be the problem indeed!!!
			search_db_texRef \
									foundMTL:				&foundMTL \				
									filePath:					&filePath \
									db_File: 					&db_File \
									mtl_Line:				&mtl_Line \										
									idx:						&matNodeCounter
		)
	),
	
	fn NOmtl_emptyTexSlot_v2 \									
										&matNodeCounter: \
										&mtl_Line: \
										&inst_s_OPTIONS: =
	(
		::g_db_type = "dds"
		local db_dir = pathConfig.resolvePathSymbols (::g_scriptRoot + "\\db")
		local db_name = ::g_db_type + "_db.txt"
		local db_File = pathConfig.resolvePathSymbols (pathConfig.AppendPath 	db_dir 	db_name)

		if ::g_db_type != "" then
		(
			if NOT doesfileexist db_File then
			(			
				inst_build_resource_db 			= build_resource_db() --create instance
				inst_build_resource_db.builder \
															g_db_type: &::g_db_type
			)
		)
		
		if doesfileexist db_File then --if the database .txt file exists
		(		
			-- Entering this causes a problem in .cga --or takes too long to execute, maybe because the database is for Ryse rather than Homefront
			-- which means it has to search ALL the files because it never gets a match, thus taking too long to execute
			-- Should we try to build game specific databases? (we will put in *game;<current game>* in the first line, and check the game before starting the search!)
			-- Now we have tested this, and it seems to be the problem indeed!!!
			search_db_NOmtl_texRef \
												db_File: 					&db_File \
												mtl_Line:				&mtl_Line \										
			 									idx:						&matNodeCounter
		)

	),
	
	----------------------XML Binary Headers----------------------
	xmlB_arr = #( \
						#(), \ 	--Binary XML header		[1]
						#(), \	--node structs			[2]
						#(), \ 	--child index				[3]
						#()  \	--attrib_child_indices	[4]
					 ),
					
	szSignature = "CryXmlB",	--case sensitive
	
					 
					 
	fn ReadFixedString \
								&bstream: \
								&fixedLen: =
	(
		local str = ""
		for i = 1 to fixedLen do
		(
			str += bit.intAsChar (ReadByte bstream #unsigned)
		)
		return str;
	),
	
	fn readHalfFloat \
							&fstream: =
	(
		if fstream != unsupplied then
		(
			if fstream != undefined then
			(
				if isKindOf fstream BinStream then
				(
					hf				= readshort fstream #unsigned
					sign 			= bit.get hf 16
					exponent 	= (bit.shift (bit.and hf (bit.hexasint "7C00")) -10) as integer - 16
					fraction 		= bit.and hf (bit.hexasint "03FF")
					
					if sign==true then
					(
						sign = 1
					)
					else
					(
						sign = 0
					)
					
					exponentF = exponent + 127
					
					outputAsFloat = bit.or (bit.or (bit.shift fraction 13) \
					(bit.shift exponentF 23)) (bit.shift sign 31)
					
					return bit.intasfloat outputasfloat*2;
				)
			)
		)
	),	
	
	--Checks if the header is CryXmlB in the .mtl, if so, then it is in Crytek Binary XML format
	fn Binary_XML_check _file =
	(
		szSignature 	= "CryXmlB"
		
		--////////////// Open binary stream //////////////
		xbs 				= fopen _file "rb"
		-------------------------------------------
		
			local fixedLen = 8
			thisHeader = ReadFixedString \
													bstream:	&xbs \
													fixedLen:	&fixedLen
		
		--////////////// Close binarystream //////////////
		fclose xbs
		
		if thisHeader == szSignature then
		(
			return true;
		)
		else
		(
			return false;
		)
	),
	
	--XMLBinaryHeaders.h---------------------
	fn read_BinaryFileHeader \
										&bstream: \
										&struct2fill: \
										&signature2check: =
	(
		--if the signature is "CryXmlB", then we can proceed
		if struct2fill.szSignature == signature2check then
		(
			format "Correct signature, we continue parsing...\n\n"	
			
			if ::g_CryGame_dropDown_selection == "HFR" then
			(
				struct2fill.nXMLSize 						= readshort bstream #unsigned
					readshort bstream
			)
			else
			(
				struct2fill.nXMLSize 						= readlong bstream #unsigned
			)
			
			struct2fill.nNodeTablePosition 		= readlong bstream #unsigned		
			struct2fill.nNodeCount 					= readlong bstream #unsigned		
			struct2fill.nAttributeTablePosition 	= readlong bstream #unsigned
			struct2fill.nAttributeCount 			= readlong bstream #unsigned
			struct2fill.nChildTablePosition			= readlong bstream #unsigned
			struct2fill.nChildCount 					= readlong bstream #unsigned
			struct2fill.nStringDataPosition 		= readlong bstream #unsigned
			struct2fill.nStringDataSize 				= readlong bstream #unsigned
			
			if ::g_CryGame_dropDown_selection == "HFR" then
			(
				-------------------- HFR --------------------
				struct2fill.u1A 								= readbyte bstream #unsigned
				struct2fill.u2A 								= readshort bstream #unsigned
				struct2fill.u3A 								= readbyte bstream #unsigned
				struct2fill.u_A_TablePosition			= readlong bstream #unsigned
				struct2fill.u_B_TablePosition			= readlong bstream #unsigned
				struct2fill.u_C_TablePosition			= readlong bstream #unsigned
				struct2fill.u_D_TablePosition			= readlong bstream #unsigned
				struct2fill.u_D_TableCount				= readlong bstream #unsigned
			)
			
			--Append header to array
			Append xmlB_arr[1] struct2fill
		)
		else
		(
			format "Wrong signature. Signature must be %. We cannot continue - aborting!" signature2check
			return false;
		)
	),	
	
	fn read_Node \
						&bstream: \
						&struct2read: =
	(
		fseek bstream struct2read.nNodeTablePosition #seek_set
		
		for i=1 to struct2read.nNodeCount do
		(
			--create struct instance
			struct2fill = _Node()
			
			struct2fill.nTagStringOffset 			= readlong 	bstream #unsigned		
			struct2fill.nContentStringOffset 		= readlong 	bstream #unsigned	

			if ::g_CryGame_dropDown_selection == "HFR" then
			(
				struct2fill.nAttributeCount 			= readlong bstream #unsigned
				struct2fill.nChildCount 					= readlong bstream #unsigned
			)
			else
			(
				struct2fill.nAttributeCount 			= readshort bstream #unsigned		
				struct2fill.nChildCount 					= readshort bstream #unsigned
			)
			
			---------------------------------- Nodeindices ----------------------------------
			struct2fill.nParentIndex 				= readlong bstream #unsigned	
			struct2fill.nFirstAttributeIndex 		= readlong bstream #unsigned
			struct2fill.nFirstChildIndex 				= readlong bstream #unsigned			
			
			if ::g_CryGame_dropDown_selection != "HFR" then
			(
				--pad
				for i=1 to struct2fill.Pad do
				(
					readlong bstream
				)
			)

			--Append all the node structs to the array
			Append xmlB_arr[2] struct2fill
		)
	),	
	
	fn read_nChildTable \
								&bstream: \
								&struct2read: =
	(
		fseek bstream struct2read.nChildTablePosition #seek_set
		
		for i=1 to struct2read.nChildCount do
		(
			childIndex = readlong bstream #unsigned
			
			Append xmlB_arr[3] childIndex
		)	
	),	
	
	fn read_nTagString \
								&bstream: \
								&struct2read: =
	(	
		for i=1 to xmlB_arr[2].count do
		(
			fseek bstream (struct2read.nStringDataPosition + xmlB_arr[2][i].nTagStringOffset)  #seek_set		
		
			xmlB_arr[2][i].nTagString = ReadString bstream
		)
	),
	
	fn read_nAttributeTable \
										&bstream: \
										&struct2read: =
	(
		fseek bstream struct2read.nAttributeTablePosition #seek_set
		
		for i=1 to struct2read.nAttributeCount do
		(
			struct2fill = attrib_child_indices()
			
			--These are the offsets from where we read the strings, starting from the nStringDataPosition offset (last chunk of the file)
			struct2fill.nFirstAttributeIndex 	= 		(readlong bstream #unsigned)
			struct2fill.nFirstChildIndex 			= 		(readlong bstream #unsigned)	
			
			Append xmlB_arr[4] struct2fill
		)
		
		for i=1 to struct2read.nAttributeCount do
		(
			fseek bstream struct2read.nStringDataPosition #seek_set		
				fseek bstream xmlB_arr[4][i].nFirstAttributeIndex #seek_cur
					xmlB_arr[4][i].nFirstAttribute_val = ReadString bstream
			
			fseek bstream struct2read.nStringDataPosition #seek_set
				fseek bstream xmlB_arr[4][i].nFirstChildIndex #seek_cur
					xmlB_arr[4][i].nFirstChild_val = ReadString bstream
		)
	),	
	
	fn debug_xmlB_arr \
								&xmlArr: =
	(	
		---------	---------	---------	---------	---------	---------	---------	---------	---------	---------	---------
		(
			format "\n\n\n REPORT - remember all indices are zero based (must be converted to 1 based in max\n\n"
			format "---------------------------This is the header table info-------------------------------\n\n"
			for i=1 to xmlArr[1].count do
			(
				format "struct2fill.nXMLSize: % \n"		 																				xmlArr[1][i].nXMLSize
				format "struct2fill.nNodeTablePosition: % \n"																			xmlArr[1][i].nNodeTablePosition
				format "struct2fill.nNodeCount: % \n" 																					xmlArr[1][i].nNodeCount
				format "struct2fill.nAttributeTablePosition: % \n"																	xmlArr[1][i].nAttributeTablePosition
				format "struct2fill.nAttributeCount: % \n" 																			xmlArr[1][i].nAttributeCount
				format "struct2fill.nChildTablePosition: % \n" 																		xmlArr[1][i].nChildTablePosition
				format "struct2fill.nChildCount: % (Root NOT included-so these are the children for the root)\n" 	xmlArr[1][i].nChildCount
				format "struct2fill.nStringDataPosition: % \n"																			xmlArr[1][i].nStringDataPosition
				format "struct2fill.nStringDataSize: % \n" 																			xmlArr[1][i].nStringDataSize
			)
			format "-------------------------------------------------------------------------------------\n\n\n"

			format "-----------These are the children (the node with nParentIndex: -1 is the root node)-----------\n\n"
			for i=1 to xmlArr[2].count do
			(
				tab = "\t" --for children
				
				if xmlArr[2][i].nFirstChildIndex == 0 AND xmlArr[2][i].nParentIndex == -1 then --Root
				(
					tab = ""
				)
				-------------------------
				format "%\t struct2fill.nTagStringOffset: %\n" 				tab xmlArr[2][i].nTagStringOffset
					format "%\t struct2fill.nTagString: <%>\n" 				tab xmlArr[2][i].nTagString
				format "%\t struct2fill.nContentStringOffset: %\n" 		tab xmlArr[2][i].nContentStringOffset
				format "%\t struct2fill.nAttributeCount: %\n" 				tab xmlArr[2][i].nAttributeCount
				format "%\t struct2fill.nChildCount: %   (this is the count from xmlArr[3][i] <---this val counts these nodes from the starting node (see last for each of these nodes) \n" 				tab xmlArr[2][i].nChildCount
				format "%\t struct2fill.nParentIndex: %\n" 					tab xmlArr[2][i].nParentIndex
				format "%\t struct2fill.nFirstAttributeIndex: %\n" 			tab xmlArr[2][i].nFirstAttributeIndex
				format "%\t struct2fill.nFirstChildIndex: %   (xmlArr[3][i] <---this val, points to the starting node in these nodes (children to the root) here) \n" 			tab xmlArr[2][i].nFirstChildIndex
				-------------------------
				format "\n"
			)	
			format "------------------------------------------------------------------------------------------\n\n\n"


			format "-----------These are the childrens to the root (i.e. the root is not included here!)-----------\n\n"
			for i=1 to xmlArr[3].count do
			(
				format "nFirstChildIndex %: \n" xmlArr[3][i]
			)
			format "------------------------------------------------------------------------------------------\n\n\n"
			
			for i=1 to xmlArr[4].count do
			(
				format 	"nFirstAttributeIndex %: \n" 			xmlArr[4][i].nFirstAttributeIndex
					format 	"\t nFirstAttribute_val %: \n" 		xmlArr[4][i].nFirstAttribute_val
				--format "\n"
				
				format 	"nFirstChildIndex %: \n" 				xmlArr[4][i].nFirstChildIndex	
					format 	"\t nFirstChild_val %: \n" 				xmlArr[4][i].nFirstChild_val
				format "\n"
				
			)
			
			format "END OF REPORT\n\n\n"
		)
		---------	---------	---------	---------	---------	---------	---------	---------	---------	---------	---------
	),	
	
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
			else
			(
				---------------------------------------------------------------
				if GenMask.count > min then
				(
					GenMask = substring GenMask 2 GenMask.count --strip the first char
				)
				GenMaskINT  		= set_GenMask_64bits \
																		GenMask:&GenMask
				---------------------------------------------------------------
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
	
	fn loop_attribs \
						&xmlB: \
						&stringNode: \
						&stringName: \
						&stringVal: =
	(
		for i=1 to xmlB.count do
		(
			if xmlB[i].nTagString == stringNode then
			(
				idx = finditem xmlB[i].attribVal stringVal
				
				if idx != 0 then
				(
					idx = finditem xmlB[i].attribName stringName
						
					if idx != 0 then
					(
						return xmlB[i].attribVal[idx];
					)					
				)				
			)				
		)	
		return 0;
	),
	
	fn get_Material_attribs  \
										&xmlB: \
										&stringNode: \
										&stringName: =
	(
		for i=1 to xmlB.count do
		(
			if xmlB[i].nTagString == stringNode then
			(
				idx = finditem xmlB[i].attribName stringName
				
				if idx != 0 then
				(
					return xmlB[i].attribVal[idx];				
				)				
			)				
		)	
		return 0;
	),
	
	fn get_specif_attrib  \
									&xmlBNode: \
									&stringNode: \
									&stringName: =
	(
		idx = finditem xmlBNode.attribName stringName
				
		if idx != 0 then
		(
			return xmlBNode.attribVal[idx];				
		)
		return 0;
	),
	
	fn get_StringGenMask \
									&xmlB: \
									&stringNode: \
									&stringName: =
	(	
		if xmlB != undefined then
		(
			if iskindof xmlB array then
			(
				for i=1 to xmlB.count do
				(
					if xmlB[i].nTagString == stringNode then
					(
						idx = finditem xmlB[i].attribName stringName
						
						if idx != 0 then
						(
							attribVal = xmlB[i].attribVal[idx]
							
							--Filter the value
							if matchpattern  attribVal pattern:"*%*" then
							(
								mat_StringGenMask_arr 	= #()										
								mat_StringGenMask_arr 	= filterstring attribVal "%"
								
								return mat_StringGenMask_arr;
							)					
						)
					)				
				)
			)
		)
		return 0;
	),
	
	fn getThis_StringGenMask \
										&attribVal: =
	(
		if attribVal != undefined then
		(
			if iskindof attribVal string then
			(
				--Filter the value
				if matchpattern attribVal pattern:"*%*" then
				(
					mat_StringGenMask_arr 	= #()										
					mat_StringGenMask_arr 	= filterstring attribVal "%"
								
					return mat_StringGenMask_arr;
				)
			)
		)
		return 0;
	),
	
	fn existThis_StringGenMask \
											&attribVal: \
											thisString: =
	(
		--Filter the value
		if attribVal != unsupplied then
		(
			if attribVal != undefined then
			(
				if iskindof attribVal string then
				(
					if matchpattern  attribVal pattern:"*%*" then
					(
						mat_StringGenMask_arr 	= #()										
						mat_StringGenMask_arr 	= filterstring attribVal "%"
						
						for i=1 to mat_StringGenMask_arr.count do
						(
							if (stricmp mat_StringGenMask_arr[i] (thisString as string)) == 0 then
							(
								return true;
							)
						)
					)
				)
			)
		)
		return false;
	),	
	
	
	--////////////////////////////////////// STORE ATTRIBS //////////////////////////////////////
	fn xmlB_storeAttribs_v3 \										
										&matNodeCounter_REF: \
										&g_xmlB_Parsed: \
										&matNodeCounter: \
										&matNodeCounter_MAT: \
										&Attachment_node_counter: \
										&MaterialRef_node_counter: \
										&theMat: \
										&compositeMat: \
										&matIDX: \
										&nodeType: \
										&attribName: \
										&attribVal: =
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
								int_MtlFlags 							= (_MtlFlags_ as integer)
								arr_MtlFlags 							= get_MtlFlags \
																									int_MtlFlags:				&int_MtlFlags \
																									inst_EMaterialFlags:		&inst_EMaterialFlags \
																									noDraw:						&noDraw					
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
						Append 		::g_xmlB_Parsed[2] inst_materialAttribs
					)
					
					else if entered_Textures then
					(		
						--not implemented
					)
					
					else if entered_Texture then
					(
						Append 		::g_xmlB_Parsed[3] inst_textureAttribs
					)
					
					else if entered_TexMod then
					(	
						--not implemented
					)
					
					else if entered_PublicParams then
					(
						Append 		::g_xmlB_Parsed[4] inst_publicParamsAttribs
					)
					
					else if entered_MaterialRef then
					(		
						Append 		::g_xmlB_Parsed[5] inst_MaterialRefAttribs							
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
	--/////////////////////////////// END OF STORE ATTRIBS ////////////////////////////////
	
	
	
	
	--////////////////////////////////////// GET ATTRIBS //////////////////////////////////////
	fn getAttributes_xmlB \
									&matNodeCounter_REF: \		
									&matNodeCounter: \
									&matNodeCounter_MAT: \
									&Attachment_node_counter: \
									&MaterialRef_node_counter: \
									&theMat: \
									&compositeMat: \
									matIDX: \
									&nTagString: \
									&tab: \
									&xmlArr: \
									&nFirstAttributeIndex: \
									&nAttributeCount:\
									=
	(
		local nodeType 				= ""	

		if nTagString != undefined then
		(
			if iskindof nTagString string then
			(
				if 	(stricmp nTagString "Material") == 0 then
				(					
					nodeType 					= nTagString
					
					matNodeCounter 			+= 1  --Bot mat and ref nodes
					matNodeCounter_MAT 	+=1 --only mat nodes

					---------------- Reset Array ----------------
					g_xmlB_Parsed			=	#(
														#(), 	-- 1
														#(), 	-- 2
														#(), 	-- 3
														#(), 	-- 4
														#() 	-- 5 MaterialRef
													 )

					if ::g_xmlB_Report_v2 then
					(
						print "--------------------------- Following are the attributes of a Material Node ---------------------------"
					)
				)				
				else if (stricmp nTagString "MaterialRef") == 0 then
				(
					nodeType 								= nTagString
					
					matNodeCounter 						+= 1  --Bot mat and ref nodes
					MaterialRef_node_counter 			+= 1	--only ref nodes

					---------------- Reset Array ----------------
					g_xmlB_Parsed			=	#(
														#(), 	-- 1
														#(), 	-- 2
														#(), 	-- 3
														#(), 	-- 4
														#() 	-- 5 MaterialRef
													 )
					
					if ::rollout_Report.chk_MaterialRef_Report.state then
					(
						format "########## MaterialRef_node_counter % ##########\n" 	MaterialRef_node_counter
						print "------------------------- Following are the attributes of a MaterialRef Node -------------------------"
					)
				)				
				else if (stricmp nTagString "Textures") == 0 then
				(
					if ::g_xmlB_Report_v2 then
					(
						print "--------------------------- Following are the attributes of a Textures Node ---------------------------"
					)
					nodeType = nTagString
				)
				else if (stricmp nTagString "Texture") == 0 then
				(
					if ::g_xmlB_Report_v2 then
					(
						print "--------------------------- Following are the attributes of a Texture Node ---------------------------"
					)
					nodeType = nTagString
				)
				else if (stricmp nTagString "TexMod") == 0 then
				(
					if ::g_xmlB_Report_v2 then
					(
						print "--------------------------- Following are the attributes of a TexMod Node ---------------------------"
					)
					nodeType = nTagString
				)
				else if (stricmp nTagString "PublicParams") == 0 then
				(
					if ::g_xmlB_Report_v2 then
					(
						print "------------------------- Following are the attributes of a PublicParams Node -------------------------"
					)
					nodeType = nTagString
				)
				
				tab +=1
				
				for x=(nFirstAttributeIndex+1) to (nFirstAttributeIndex+nAttributeCount) do
				(					
					attribName 		= xmlArr[4][x].nFirstAttribute_val
					attribVal 		= xmlArr[4][x].nFirstChild_val
					
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "% = %\n" attribName attribVal
					)
					
					xmlB_storeAttribs_v3 \
													g_xmlB_Parsed:					&g_xmlB_Parsed \
													matNodeCounter_REF:			&matNodeCounter_REF \													
													matNodeCounter:					&matNodeCounter \
													matNodeCounter_MAT: 		&matNodeCounter_MAT \
													MaterialRef_node_counter: 	&MaterialRef_node_counter \
													theMat:								&theMat \
													compositeMat:					&compositeMat \
													matIDX:								&matIDX \
													nodeType:							&nodeType \
													attribName:						&attribName \
													attribVal:							&attribVal
				)
			)
		)
		
		tab -= 1 --NEW
	),
	
	fn getAttributes_cdf_xmlB \										
										SkeletonList_Bool: \
										&inst_s_OPTIONS: \ 
										&matNodeCounter: \
										&Attachment_node_counter: \
										&theMat: \
										&compositeMat: \
										matIDX: \
										&nTagString: \
										&tab: \
										&xmlArr: \
										&nFirstAttributeIndex: \
										&nAttributeCount: \
										type: =
	(		
		local nodeType 				= ""	
		
		if SkeletonList_Bool != unsupplied then
		(
			if SkeletonList_Bool != undefined then
			(
				if SkeletonList_Bool then
				(
					if ::g_xmlB_Report_v2 then
					(
						format "\ngetAttributes_cdf_xmlB============== This is a SkeletonList File ============== \n"
					)
					
					if (stricmp (nTagString as string) "SkeletonList") == 0 then
					(
						if ::g_xmlB_Report_v2 then
						(
							print "getAttributes_cdf_xmlB---------------- Following are the attributes of a SkeletonList Node ----------------"
						)
						nodeType = nTagString
					)

					tab +=1		
					for x=(nFirstAttributeIndex+1) to (nFirstAttributeIndex+nAttributeCount) do
					(
						attribName 		= xmlArr[4][x].nFirstAttribute_val
						attribVal 		= xmlArr[4][x].nFirstChild_val			
						
						if ::g_xmlB_Report_v2 then
						(
							for t=1 to tab do ( format "\t" )
							format "% = %\n" attribName attribVal					
						)
						
						xmlB_storeAttribs_v3 \														
														g_xmlB_Parsed:					&g_xmlB_Parsed \
														matNodeCounter:					&matNodeCounter \
														MaterialRef_node_counter: 	&MaterialRef_node_counter \
														theMat:								&theMat \
														compositeMat:					&compositeMat \
														matIDX:								&matIDX \
														nodeType:							&nodeType \
														attribName:						&attribName \
														attribVal:							&attribVal	
					)
				)
			)
		)
		else
		(
			if (stricmp (nTagString as string) "CharacterDefinition") == 0 then
			(
				if ::g_xmlB_Report_v2 then
				(
					print "getAttributes_cdf_xmlB--------------------------- Following are the attributes of a CharacterDefinition Node ---------------------------"
				)
				nodeType = nTagString
				
				matNodeCounter += 1				
				
				::g_cdf_xmlB_Parsed		=	#(
														#(), 	-- 1
														#(), 	-- 2
														#(), 	-- 3
														#(), 	-- 4
														#() 	-- 5 MaterialRef	
													)
			)			
			else if (stricmp (nTagString as string) "Model") == 0 then
			(
				if ::g_xmlB_Report_v2 then
				(
					print "getAttributes_cdf_xmlB--------------------------- Following are the attributes of a Model Node ---------------------------"
				)
				nodeType = nTagString				
				
				for x=(nFirstAttributeIndex+1) to (nFirstAttributeIndex+nAttributeCount) do
				(
					attribName 		= xmlArr[4][x].nFirstAttribute_val
					attribVal 		= xmlArr[4][x].nFirstChild_val			
					
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "% = %\n" attribName attribVal
					)
					
					xmlB_storeAttribs_v3 \													 
													g_xmlB_Parsed:		&g_xmlB_Parsed \
													matNodeCounter:		&matNodeCounter \
													theMat:					&theMat \
													compositeMat:		&compositeMat \
													matIDX:					&matIDX \
													nodeType:				&nodeType \
													attribName:			&attribName \
													attribVal:				&attribVal
				)	
				
			)
			else if (stricmp (nTagString as string) "AttachmentList") == 0 then
			(
				if ::g_xmlB_Report_v2 then
				(
					print "getAttributes_cdf_xmlB--------------------------- Following are the attributes of a AttachmentList Node ---------------------------"
				)
				nodeType = nTagString
			)		
			else if (stricmp (nTagString as string) "Attachment") == 0 then
			(
				if ::g_xmlB_Report_v2 then
				(
					print "getAttributes_cdf_xmlB--------------------------- Following are the attributes of a Attachment Node ---------------------------"
				)
				nodeType = nTagString			
			)			
			
			tab +=1	
			for x=(nFirstAttributeIndex+1) to (nFirstAttributeIndex+nAttributeCount) do
			(				
				if x > 0 then --NEW HFR
				(					
					if xmlArr[4][x] != undefined then
					(
						attribName 		= xmlArr[4][x].nFirstAttribute_val
						attribVal 		= xmlArr[4][x].nFirstChild_val
						
						if ::g_xmlB_Report_v2 then
						(
							for t=1 to tab do ( format "\t" )
							format "% = %\n" attribName attribVal
						)
						
						if (stricmp (attribName as string) "Material") == 0 then
						(
							local matFile = ::g_dirpath + "/" + attribVal
							local matFile = pathConfig.resolvePathSymbols matFile
							
							if ::g_xmlB_Report_v2 then
							(
								format "\n\n========= CDF PARSING, WE HAVE FOUND MATERIAL: % \n" attribVal
								format "\n\n========= matFile: % \n" matFile
							)
						)				
						else if (attribName as string) == "File" then
						(					
							--// Put code here
						)
						else if (attribName as string) == "Type" then
						(
							--// Put code here
						)
						else if (attribName as string) == "AName" then
						(
							--// Put code here
						)
						else if (attribName as string) == "Binding" then
						(
							--// Put code here
						)
						else if (attribName as string) == "Flags" then
						(
							--// Put code here
						)	
					)					
				)
			)
			
		)
		
		tab -= 1 --NEW
	),	
	
	fn getAttributes_LOAD_ASSETS_CDF_xmlB \
																&inst_s_OPTIONS: \ 
																&matNodeCounter: \
																&Attachment_node_counter: \
																&Anim_Node_Counter: \
																&theMat: \
																&compositeMat: \
																matIDX: \
																&nTagString: \
																&tab: \
																&xmlArr: \
																&nFirstAttributeIndex: \
																&nAttributeCount: \
																type: =
	(
		if ::g_xmlB_Report_v2 then
		(
			format "----We are now inside ***getAttributes_LOAD_ASSETS_CDF_xmlB*** ----\n"
		)
		
		local nodeType 				= ""		
		
		if type != unsupplied then
		(
			if iskindof type string then
			(
				if (stricmp type ".cdf") == 0 then
				(
					if (stricmp nTagString "CharacterDefinition") == 0 then
					(
						if ::g_xmlB_Report_v2 then
						(
							print "--------------------------- Following are the attributes of a CharacterDefinition Node ---------------------------"
						)
						nodeType = nTagString
						
						matNodeCounter += 1				
						
						::g_cdf_xmlB_Parsed		=	#(
																#(), 	-- 1
																#(), 	-- 2
																#(), 	-- 3
																#(), 	-- 4
																#() 	-- 5 MaterialRef
															)
					)
					else if (stricmp nTagString "Model") == 0 then
					(
						if ::g_xmlB_Report_v2 then
						(
							print "--------------------------- Following are the attributes of a Model Node ---------------------------"
						)
						
						nodeType = nTagString
					)
					else if (stricmp nTagString "AttachmentList") == 0 then
					(
						if ::g_xmlB_Report_v2 then
						(
							print "--------------------------- Following are the attributes of a AttachmentList Node ---------------------------"
						)
						
						nodeType = nTagString
					)		
					else if (stricmp nTagString "Attachment") == 0 then
					(
						if ::g_xmlB_Report_v2 then
						(
							print "--------------------------- Following are the attributes of a Attachment Node ---------------------------"
						)
						
						nodeType = nTagString
					)
				)
				else if (stricmp type ".chrparams") == 0 then
				(
					if (stricmp nTagString "AnimationList") == 0 then
					(
						if ::g_xmlB_Report_v2 then
						(
							print "--------------------------- Following are the attributes of a AnimationList Node ---------------------------"
						)
						
						nodeType 				= nTagString				
						matNodeCounter 		+= 1
					)
					else if (stricmp nTagString "Animation") == 0 then
					(
						if ::g_xmlB_Report_v2 then
						(
							print "--------------------------- Following are the attributes of an Animation Node ---------------------------"
						)
						
						nodeType 				= nTagString
						if ::g_xmlB_Report_v2 then
						(
							format "++++++++++++++++++ Anim_Node_Counter: %" Anim_Node_Counter
						)
					)
				)

				tab +=1	
				----------------------------------------------------------------------------------------------------------
				for x=(nFirstAttributeIndex+1) to (nFirstAttributeIndex+nAttributeCount) do
				(
					attribName 		= xmlArr[4][x].nFirstAttribute_val
					attribVal 		= xmlArr[4][x].nFirstChild_val			
					
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "% = %\n" attribName attribVal
					)
					
					CDF_storeAttribs_v3 \
													type:									&type \
													g_xmlB_Parsed:					&g_xmlB_Parsed \
													matNodeCounter:					&matNodeCounter \
													Attachment_node_counter: 	&Attachment_node_counter \
													Anim_Node_Counter:			&Anim_Node_Counter \
													theMat:								&theMat \
													compositeMat:					&compositeMat \
													matIDX:								&matIDX \
													nodeType:							&nodeType \
													attribName:						&attribName \
													attribVal:							&attribVal
					
					
					if (stricmp attribName "Material") == 0 then
					(
					)
					else if attribName == "File" then
					(
						--// Put code here
					)
					else if attribName == "Type" then
					(
						--// Put code here
					)
					else if attribName == "AName" then
					(
						--// Put code here
					)
					else if attribName == "Binding" then
					(
						--// Put code here
					)
					else if attribName == "Flags" then
					(
						--// Put code here
					)			
				)
				----------------------------------------------------------------------------------------------------------
			)
		)
		
		tab -= 1 --NEW
	),
	--/////////////////////////////// END OF GET ATTRIBS ////////////////////////////////
	
	
	--////////////////////////////////////// RECURSE //////////////////////////////////////
	fn recurse_LOAD_ASSETS_CDF_xmlB \
														&inst_s_OPTIONS: \ 
														&matNodeCounter: \
														&Attachment_node_counter: \
														&Anim_Node_Counter: \
														&theMat: \
														&compositeMat: \
														matIDX: \
														&tab: \
														&arr: \
														&xmlArr: \
														&nFirstAttributeIndex: \
														&nAttributeCount: \
														i: \
														&nTagString: \
														&nChildCount: \
														&nParentIndex: \
														&nFirstChildIndex: \
														type: =

	(
		if ::g_xmlB_Report_v2 then
		(
			format "--------------------+++we are inside recurse_cdf_xmlB+++-------------------\n"
		)

		for x=1 to arr.count do
		(
			if nParentIndex == x-i then
			(
				tab +=1
				
				for k=(nFirstChildIndex+1) to (nFirstChildIndex+nChildCount) do
				(
					nTagString  			= arr[k][1]
					nChildCount 			= arr[k][2]
					nParentIndex 			= arr[k][3]
					nFirstChildIndex 		= arr[k][4]
					nFirstAttributeIndex 	= arr[k][5]
					nAttributeCount 		= arr[k][6]
						
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "%\n" 		arr[k][1]
					)
						
					getAttributes_LOAD_ASSETS_CDF_xmlB \
																			inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																			matNodeCounter:					&matNodeCounter \
																			Attachment_node_counter: 	&Attachment_node_counter \
																			Anim_Node_Counter: 			&Anim_Node_Counter \
																			theMat:								&theMat \
																			compositeMat:					&compositeMat \
																			matIDX:								matIDX \
																			nTagString:						&nTagString \
																			tab:									&tab \
																			xmlArr:								&xmlArr \											
																			nFirstAttributeIndex:			&nFirstAttributeIndex \
																			nAttributeCount:					&nAttributeCount
						
					recurse_LOAD_ASSETS_CDF_xmlB \
																	inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																	matNodeCounter:					&matNodeCounter \
																	Attachment_node_counter: 	&Attachment_node_counter \
																	Anim_Node_Counter: 			&Anim_Node_Counter \
																	theMat:								&theMat \
																	compositeMat:					&compositeMat \
																	matIDX:								matIDX \
																	tab:									&tab \
																	arr:									&arr \
																	xmlArr:								&xmlArr \
																	nFirstAttributeIndex:			&nFirstAttributeIndex \
																	nAttributeCount:					&nAttributeCount \
																	i:										i \
																	nTagString:						&nTagString \
																	nChildCount:						&nChildCount \
																	nParentIndex:						&nParentIndex \
																	nFirstChildIndex:					&nFirstChildIndex
					i+=1					
				)
				tab -=1
			)			
		)
	),	
	
	fn recurse_xmlB \
							&matNodeCounter: \
							&matNodeCounter_MAT: \
							&matNodeCounter_REF: \
							&Attachment_node_counter: \
							&MaterialRef_node_counter: \
							&type: \
							&theMat: \
							&compositeMat: \
							matIDX: \
							&tab: \
							&arr: \
							&xmlArr: \
							&nFirstAttributeIndex: \
							&nAttributeCount: \
							i: \
							&nTagString: \
							&nChildCount: \
							&nParentIndex: \
							&nFirstChildIndex: =

	(
		if ::g_xmlB_Report_v2 then
		(
			format "--------------------we are inside recurse_xmlB -------------------\n"
		)

		for x=1 to arr.count do
		(
			if nParentIndex == x-i then
			(
				tab +=1
				
				for k=(nFirstChildIndex+1) to (nFirstChildIndex+nChildCount) do
				(
					nTagString  			= arr[k][1]
					nChildCount 			= arr[k][2]
					nParentIndex 			= arr[k][3]
					nFirstChildIndex 		= arr[k][4]
					nFirstAttributeIndex 	= arr[k][5]
					nAttributeCount 		= arr[k][6]
					
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "%\n" 		arr[k][1]
					)

					getAttributes_xmlB \	
												matNodeCounter_MAT: 		&matNodeCounter_MAT \
												matNodeCounter_REF:			&matNodeCounter_REF \
												matNodeCounter:					&matNodeCounter \
												MaterialRef_node_counter: 	&MaterialRef_node_counter \
												theMat:								&theMat \
												compositeMat:					&compositeMat \
												matIDX:								matIDX \
												nTagString:						&nTagString \
												tab:									&tab \
												xmlArr:								&xmlArr \											
												nFirstAttributeIndex:			&nFirstAttributeIndex \
												nAttributeCount:					&nAttributeCount
					

					recurse_xmlB \	
										matNodeCounter_MAT: 		&matNodeCounter_MAT \
										matNodeCounter_REF:			&matNodeCounter_REF \					
										matNodeCounter:					&matNodeCounter \
										MaterialRef_node_counter: 	&MaterialRef_node_counter \
										theMat:								&theMat \
										compositeMat:					&compositeMat \
										matIDX:								matIDX \
										tab:									&tab \
										arr:									&arr \
										xmlArr:								&xmlArr \
										nFirstAttributeIndex:			&nFirstAttributeIndex \
										nAttributeCount:					&nAttributeCount \
										i:										i \
										nTagString:						&nTagString \
										nChildCount:						&nChildCount \
										nParentIndex:						&nParentIndex \
										nFirstChildIndex:					&nFirstChildIndex
					
					i+=1										
				)
				tab -=1
			)
		)
	),
	
	fn recurse_cdf_xmlB \								
								SkeletonList_Bool: \
								&inst_s_OPTIONS: \ 
								&matNodeCounter: \
								&Attachment_node_counter: \
								&theMat: \
								&compositeMat: \
								matIDX: \
								&tab: \
								&arr: \
								&xmlArr: \
								&nFirstAttributeIndex: \
								&nAttributeCount: \
								i: \
								&nTagString: \
								&nChildCount: \
								&nParentIndex: \
								&nFirstChildIndex: \
								type: =

	(
		if ::g_xmlB_Report_v2 then
		(
			format "--------------------we are inside recurse_cdf_xmlB-------------------\n"		
		)

		for x=1 to arr.count do
		(
			if nParentIndex == x-i then
			(
				tab +=1
				
				for k=(nFirstChildIndex+1) to (nFirstChildIndex+nChildCount) do
				(
					nTagString  			= arr[k][1]
					nChildCount 			= arr[k][2]
					nParentIndex 			= arr[k][3]
					nFirstChildIndex 		= arr[k][4]
					nFirstAttributeIndex 	= arr[k][5]
					nAttributeCount 		= arr[k][6]
					
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "%\n" 		arr[k][1]
					)
					
					getAttributes_cdf_xmlB \													
													SkeletonList_Bool:				SkeletonList_Bool \
													inst_s_OPTIONS:					&inst_s_OPTIONS \ 
													matNodeCounter:					&matNodeCounter \
													Attachment_node_counter:	&Attachment_node_counter \
													theMat:								&theMat \
													compositeMat:					&compositeMat \
													matIDX:								matIDX \
													nTagString:						&nTagString \
													tab:									&tab \
													xmlArr:								&xmlArr \											
													nFirstAttributeIndex:			&nFirstAttributeIndex \
													nAttributeCount:					&nAttributeCount
					
					recurse_cdf_xmlB \											
											SkeletonList_Bool:				SkeletonList_Bool \
											inst_s_OPTIONS:					&inst_s_OPTIONS \ 
											matNodeCounter:					&matNodeCounter \
											Attachment_node_counter:	&Attachment_node_counter \
											theMat:								&theMat \
											compositeMat:					&compositeMat \
											matIDX:								matIDX \
											tab:									&tab \
											arr:									&arr \
											xmlArr:								&xmlArr \
											nFirstAttributeIndex:			&nFirstAttributeIndex \
											nAttributeCount:					&nAttributeCount \
											i:										i \
											nTagString:						&nTagString \
											nChildCount:						&nChildCount \
											nParentIndex:						&nParentIndex \
											nFirstChildIndex:					&nFirstChildIndex
					i+=1					
				)
				tab -=1
			)			
		)
	),
	--/////////////////////////////// END OF RECURSE ////////////////////////////////
	
	
	
	--////////////////////////////////////// LOOP ATTRIBS //////////////////////////////////////
	fn loop_xmlB_Attribs \	
									&matNodeCounter_MAT: \
									&matNodeCounter_REF: \								
									&inst_s_OPTIONS: \ 
									&matNodeCounter: \
									&Attachment_node_counter: \
									&MaterialRef_node_counter: \
									&theMat: \
									matIDX: \
									&tab: \
									&arr: \
									&xmlArr: \
									&nFirstAttributeIndex: \
									&nAttributeCount: \
									i: \
									&nTagString: \
									&nChildCount: \
									&nParentIndex: \
									&nFirstChildIndex: \
									type: =	
	(
		nFirstAttributeIndex 		= xmlArr[2][1].nFirstAttributeIndex
		nAttributeCount 			= xmlArr[2][1].nAttributeCount					
					
		if ::g_xmlB_Report_v2 then
		(
			for t=1 to tab do ( format "\t" )
			format "%\n" nTagString
		)
					
		getAttributes_xmlB \
									matNodeCounter:							&matNodeCounter \
									matNodeCounter_MAT: 				&matNodeCounter_MAT \
									matNodeCounter_REF:					&matNodeCounter_REF \
									type:											type \									
									Attachment_node_counter:			&Attachment_node_counter \
									MaterialRef_node_counter: 			&MaterialRef_node_counter \
									theMat:										&theMat \
									compositeMat:							&compositeMat \
									matIDX:										matIDX \
									nTagString:								&nTagString \
									tab:											&tab \
									xmlArr:										&xmlArr \											
									nFirstAttributeIndex:					&nFirstAttributeIndex \
									nAttributeCount:							&nAttributeCount
					
					
		------------------------------- Read xmlB Nodes -------------------------------
		nChildCount 		= xmlArr[1][1].nChildCount		
					
		arr = #() --Fill this temporary array first, from the childNode index xmlArr[3]
					
		for x=1 to nChildCount do
		(
			nFirstChildIndex 		= xmlArr[3][x] --ChildNodeIndex pointing to the nodes in xmlArr[2]	
			idx 						= nFirstChildIndex+1
						
			nTagString 						= xmlArr[2][idx].nTagString
			nChildCount 					= xmlArr[2][idx].nChildCount
			nParentIndex 					= xmlArr[2][idx].nParentIndex
			nFirstChildIndex 				= xmlArr[2][idx].nFirstChildIndex
			nFirstAttributeIndex 			= xmlArr[2][idx].nFirstAttributeIndex
			nAttributeCount 				= xmlArr[2][idx].nAttributeCount
						
			Append arr #(nTagString, nChildCount, nParentIndex, nFirstChildIndex, nFirstAttributeIndex, nAttributeCount)
		)

		for c=1 to arr.count do
		(
			--Get the variables from the recently filled temporary array
			nTagString  		= arr[c][1]
			nChildCount 		= arr[c][2]
			nParentIndex 		= arr[c][3]
			nFirstChildIndex 	= arr[c][4]
						
			if nParentIndex == 0 then
			(
				tab +=1				
				if ::g_xmlB_Report_v2 then
				(
					format "%\n" 	nTagString
				)
				
				if nChildCount > 0 then
				(
					-------------------
					for i=nFirstChildIndex+1 to nFirstChildIndex+nChildCount do
					(
						nTagString  			= arr[i][1]
						nChildCount 			= arr[i][2]
						nParentIndex 			= arr[i][3]
						nFirstChildIndex 		= arr[i][4]
						nFirstAttributeIndex 	= arr[i][5]
						nAttributeCount 		= arr[i][6]
								
						if ::g_xmlB_Report_v2 then
						(
							format "\t%\n" 	arr[i][1]	
						)						

						getAttributes_xmlB \	
													matNodeCounter_MAT: 				&matNodeCounter_MAT \
													matNodeCounter_REF:					&matNodeCounter_REF \
													type:											type \
													matNodeCounter:							&matNodeCounter \
													Attachment_node_counter:			&Attachment_node_counter \
													MaterialRef_node_counter: 			&MaterialRef_node_counter \
													theMat:										&theMat \
													compositeMat:							&compositeMat \
													matIDX:										matIDX \
													nTagString:								&nTagString \
													tab:											&tab \
													xmlArr:										&xmlArr \											
													nFirstAttributeIndex:					&nFirstAttributeIndex \
													nAttributeCount:							&nAttributeCount

						recurse_xmlB \	
											matNodeCounter:							&matNodeCounter \
											matNodeCounter_MAT: 				&matNodeCounter_MAT \
											matNodeCounter_REF:					&matNodeCounter_REF \
											type:											type \											
											Attachment_node_counter:			&Attachment_node_counter \
											MaterialRef_node_counter: 			&MaterialRef_node_counter \
											theMat:										&theMat \
											compositeMat:							&compositeMat \
											matIDX:										matIDX \
											tab:											&tab \
											arr:											&arr \
											xmlArr:										&xmlArr \
											nFirstAttributeIndex:					&nFirstAttributeIndex \
											nAttributeCount:							&nAttributeCount \
											i:												i \
											nTagString:								&nTagString \
											nChildCount:								&nChildCount \
											nParentIndex:								&nParentIndex \
											nFirstChildIndex:							&nFirstChildIndex
						i+=1	

						Append 		::g_xmlB_MatNodesSet 					::g_xmlB_Parsed
					)					
				)				
				else
				(
					local nodeType 					= arr[c][1]
								
					local nAttributeCount 			= arr[c][6]
					local nFirstAttributeIndex		= arr[c][5]+1
								
					for xx=0 to nAttributeCount-1 do
					(
						local attribName 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstAttribute_val
						local attribVal 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstChild_val
									
						if ::g_xmlB_Report_v2 then
						(
							format "% = %\n" 	attribName 		attribVal
						)
						
						xmlB_storeAttribs_v3 \
														matNodeCounter:							&matNodeCounter \
														matNodeCounter_MAT: 				&matNodeCounter_MAT \
														matNodeCounter_REF:					&matNodeCounter_REF \						
														type:											&type \
														g_xmlB_Parsed:							&g_xmlB_Parsed \														
														Attachment_node_counter:			&Attachment_node_counter \
														MaterialRef_node_counter: 			&MaterialRef_node_counter \
														theMat:										&theMat \
														compositeMat:							&compositeMat \
														matIDX:										&matIDX \
														nodeType:									&nodeType \
														attribName:								&attribName \
														attribVal:									&attribVal									
					)

					Append 		::g_xmlB_MatNodesSet 					::g_xmlB_Parsed
				)
			)
		)
	),
	
	fn LOAD_ASSETS_CDF_loopAttribs \
													&inst_s_OPTIONS: \ 
													&matNodeCounter:	\
													&Attachment_node_counter: \
													&Anim_Node_Counter: \
													&theMat: \
													matIDX: \
													&tab: \
													&arr: \
													&xmlArr: \
													&nFirstAttributeIndex: \
													&nAttributeCount: \
													i: \
													&nTagString: \
													&nChildCount: \
													&nParentIndex: \
													&nFirstChildIndex: \
													type: =	
	(		
		getAttributes_LOAD_ASSETS_CDF_xmlB \
																inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																matNodeCounter:					&matNodeCounter \
																Attachment_node_counter: 	&Attachment_node_counter \
																Anim_Node_Counter: 			&Anim_Node_Counter \
																theMat:								&theMat \
																matIDX:								matIDX \
																nTagString:						&nTagString \
																tab:									&tab \
																xmlArr:								&xmlArr \											
																nFirstAttributeIndex:			&nFirstAttributeIndex \
																nAttributeCount:					&nAttributeCount \
																type:									type
					
					
		------------------------------- Read xmlB Nodes -------------------------------
		nChildCount 		= xmlArr[1][1].nChildCount
					
		arr = #() --Fill this temporary array first, from the childNode index xmlArr[3]
					
		for x=1 to nChildCount do
		(
			nFirstChildIndex 		= xmlArr[3][x] --ChildNodeIndex pointing to the nodes in xmlArr[2]	
			idx 						= nFirstChildIndex+1
						
			nTagString 						= xmlArr[2][idx].nTagString
			nChildCount 					= xmlArr[2][idx].nChildCount
			nParentIndex 					= xmlArr[2][idx].nParentIndex
			nFirstChildIndex 				= xmlArr[2][idx].nFirstChildIndex
			nFirstAttributeIndex 			= xmlArr[2][idx].nFirstAttributeIndex
			nAttributeCount 				= xmlArr[2][idx].nAttributeCount
						
			Append arr #(nTagString, nChildCount, nParentIndex, nFirstChildIndex, nFirstAttributeIndex, nAttributeCount, x)
		)					

		for c=1 to arr.count do
		(
			--Get the variables from the recently filled temporary array
			nTagString  		= arr[c][1]
			nChildCount 		= arr[c][2]
			nParentIndex 		= arr[c][3]
			nFirstChildIndex 	= arr[c][4]
						
			if nParentIndex == 0 then
			(
				tab +=1				
				if ::g_xmlB_Report_v2 then
				(
					format "%\n" 	nTagString
				)
				
				if nChildCount > 0 then
				(
					for i=(nFirstChildIndex+1) to (nFirstChildIndex+nChildCount) do
					(
						nTagString  			= arr[i][1]
						nChildCount 			= arr[i][2]
						nParentIndex 			= arr[i][3]
						nFirstChildIndex 		= arr[i][4]
						nFirstAttributeIndex 	= arr[i][5]
						nAttributeCount 		= arr[i][6]	
									
						if ::g_xmlB_Report_v2 then
						(
							format "\t%\n" 	arr[i][1]	
						)
						
						if (stricmp nTagString "Attachment") == 0 then
						(
							Attachment_node_counter += 1
						)
						else if (stricmp nTagString "Animation") == 0 then
						(
							Anim_Node_Counter 	+= 1
						)
						
						getAttributes_LOAD_ASSETS_CDF_xmlB \
																				inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																				matNodeCounter:					&matNodeCounter \
																				Attachment_node_counter: 	&Attachment_node_counter \
																				Anim_Node_Counter: 			&Anim_Node_Counter \
																				theMat:								&theMat \
																				matIDX:								matIDX \
																				nTagString:						&nTagString \
																				tab:									&tab \
																				xmlArr:								&xmlArr \											
																				nFirstAttributeIndex:			&nFirstAttributeIndex \
																				nAttributeCount:					&nAttributeCount \
																				type:									type								

						recurse_LOAD_ASSETS_CDF_xmlB \
																		inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																		matNodeCounter:					&matNodeCounter \
																		Anim_Node_Counter: 			&Anim_Node_Counter \
																		theMat:								&theMat \
																		matIDX:								matIDX \
																		tab:									&tab \
																		arr:									&arr \
																		xmlArr:								&xmlArr \
																		nFirstAttributeIndex:			&nFirstAttributeIndex \
																		nAttributeCount:					&nAttributeCount \
																		i:										i \
																		nTagString:						&nTagString \
																		nChildCount:						&nChildCount \
																		nParentIndex:						&nParentIndex \
																		nFirstChildIndex:					&nFirstChildIndex \
																		type:									type								
						i+=1

 						--Store all the children (<Material>) to the <SubMaterials> node
						Append ::g_cdf_xmlB_MatNodesSet ::g_cdf_xmlB_Parsed
					)								
				)
				else
				(
					local nodeType					= arr[c][1]
								
					--We add +1 to the index, because Cryengine is zero based, but max is 1 based
					-- (if the childcount is > 0 (as in the first condition above) then we add the 1 inside the gettAttributes function instead)
					local nFirstAttributeIndex		= arr[c][5]+1 
					local nAttributeCount 			= arr[c][6]
								
					--Store all the children (<Material>) to the <SubMaterials> node
					Append ::g_cdf_xmlB_MatNodesSet ::g_cdf_xmlB_Parsed
										
					for xx=0 to nAttributeCount-1 do
					(
						local attribName 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstAttribute_val
						local attribVal 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstChild_val							
											
						if ::g_xmlB_Report_v2 then
						(
							format "% = %\n" 	attribName 		attribVal
						)						
												
						CDF_storeAttribs_v3 \
														type:									&type \
														g_xmlB_Parsed:					&g_xmlB_Parsed \
														matNodeCounter:					&matNodeCounter \
														Attachment_node_counter: 	&Attachment_node_counter \
														Anim_Node_Counter: 			&Anim_Node_Counter \
														theMat:								&theMat \
														compositeMat:					&compositeMat \
														matIDX:								&matIDX \
														nodeType:							&nodeType \
														attribName:						&attribName \
														attribVal:							&attribVal						
					)
					
					--Store all the children (<Material>) to the <SubMaterials> node
					Append ::g_cdf_xmlB_MatNodesSet ::g_cdf_xmlB_Parsed
				)				
			)
		)
	),
	--////////////////////////////////// END OF LOOP ATTRIBS //////////////////////////////////
	
	
	
	
	--////////////////////////////////////// PARSERS //////////////////////////////////////
	fn parse_xmlB_v3 \
								&matNodeCounter_MAT: \
								&matNodeCounter_REF: \		
								type: \
								&matNodeCounter: \
								&Attachment_node_counter: \
								&MaterialRef_node_counter: \
								theMat: \
								&compositeMat: \
								&xmlArr: \
								&uniqueIDs: \
								matIDX: \								
								&inst_s_OPTIONS: \								
								subMats: =
	(
		local nTagString 						= ""
		local nChildCount 					= 0
		local nParentIndex 					= 0
		local nFirstChildIndex 				= 0
		local nFirstAttributeIndex 			= 0
		local nAttributeCount 				= 0
		
		local nNodeCount 					= 0
		local tab								= 0
		
		local arr									= #()
		
		local idx									= 0
		
		if xmlArr[1].count > 0 then
		(
			--------------------------- Read Rot Material Node ---------------------------
			nNodeCount 		= xmlArr[1][1].nNodeCount
			tab					= 0
			
			if xmlArr[2].count > 0 then
			(
				nTagString		= xmlArr[2][1].nTagString 
				
				if xmlArr[2][1].nParentIndex == -1 AND (stricmp xmlArr[2][1].nTagString "Material") == 0 then --if indeed root node
				(
					loop_xmlB_Attribs \	
												matNodeCounter:							&matNodeCounter \
												matNodeCounter_MAT: 				&matNodeCounter_MAT \
												matNodeCounter_REF:					&matNodeCounter_REF \												
												Attachment_node_counter:			&Attachment_node_counter \
												MaterialRef_node_counter:			&MaterialRef_node_counter \
												inst_s_OPTIONS:							&inst_s_OPTIONS \ 
												theMat:										&theMat \
												matIDX:										matIDX \
												tab:											&tab \
												arr:											&arr \
												xmlArr:										&xmlArr \
												nFirstAttributeIndex:					&nFirstAttributeIndex \
												nAttributeCount:							&nAttributeCount \
												i:												i \
												nTagString:								&nTagString \
												nChildCount:								&nChildCount \
												nParentIndex:								&nParentIndex \
												nFirstChildIndex:							&nFirstChildIndex \
												type:											type
				)
			)
		)
	),
	
	fn loop_Attribs_cdf_xmlB_v3 \
											&inst_s_OPTIONS:	\ 
											&matNodeCounter:	 \
											&Attachment_node_counter: \
											&theMat: \
											matIDX: \
											&tab: \
											&arr: \
											&xmlArr: \
											&nFirstAttributeIndex: \
											&nAttributeCount: \
											i: \
											&nTagString: \
											&nChildCount: \
											&nParentIndex: \
											&nFirstChildIndex: \
											type: =
	(
		if xmlArr[1].count > 0 then
		(
			--------------------------- Read Rot Material Node ---------------------------
			nNodeCount 		= xmlArr[1][1].nNodeCount
			tab					= 0
			
			if xmlArr[2].count > 0 then
			(
				nTagString		= xmlArr[2][1].nTagString 
				
-- 				if xmlArr[2][1].nParentIndex == -1 AND (stricmp xmlArr[2][1].nTagString "CharacterDefinition") == 0 then --if indeed root node
-- 				(
					nFirstAttributeIndex 		= xmlArr[2][1].nFirstAttributeIndex
					nAttributeCount 			= xmlArr[2][1].nAttributeCount					
					
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "%\n" nTagString
					)
					
					getAttributes_cdf_xmlB \													
													inst_s_OPTIONS:					&inst_s_OPTIONS \ 
													matNodeCounter:					&matNodeCounter \
													Attachment_node_counter:	&Attachment_node_counter \
													theMat:								&theMat \
													matIDX:								matIDX \
													nTagString:						&nTagString \
													tab:									&tab \
													xmlArr:								&xmlArr \											
													nFirstAttributeIndex:			&nFirstAttributeIndex \
													nAttributeCount:					&nAttributeCount \
													type:									type
					
					
					------------------------------- Read xmlB Nodes -------------------------------
					nChildCount 		= xmlArr[1][1].nChildCount
					
					arr = #() --Fill this temporary array first, from the childNode index xmlArr[3]
					
					for x=1 to nChildCount do
					(
						nFirstChildIndex 				= xmlArr[3][x] --ChildNodeIndex pointing to the nodes in xmlArr[2]	
						idx 								= nFirstChildIndex+1
						
						nTagString 						= xmlArr[2][idx].nTagString
						nChildCount 					= xmlArr[2][idx].nChildCount
						nParentIndex 					= xmlArr[2][idx].nParentIndex
						nFirstChildIndex 				= xmlArr[2][idx].nFirstChildIndex
						nFirstAttributeIndex 			= xmlArr[2][idx].nFirstAttributeIndex
						nAttributeCount 				= xmlArr[2][idx].nAttributeCount
						
						Append arr #(nTagString, nChildCount, nParentIndex, nFirstChildIndex, nFirstAttributeIndex, nAttributeCount)
					)

					for c=1 to arr.count do
					(
						--Get the variables from the recently filled temporary array
						nTagString  		= arr[c][1]
						nChildCount 		= arr[c][2]
						nParentIndex 		= arr[c][3]
						nFirstChildIndex 	= arr[c][4]
						
-- 						print "##################################################"
-- 						format "nTagString: %\n"  		nTagString
-- 						format "nChildCount: %\n" 		nChildCount
-- 						format "nParentIndex: %\n" 		nParentIndex
-- 						format "nFirstChildIndex: %\n" 	nFirstChildIndex
-- 						print "##################################################"
						
						if nParentIndex == 0 then
						(
							tab +=1				
							if ::g_xmlB_Report_v2 then
							(
								format "%\n" 	nTagString
							)
							
							if nChildCount > 0 then
							(
								for i=(nFirstChildIndex+1) to (nFirstChildIndex+nChildCount) do
								(
									nTagString  			= arr[i][1]
									nChildCount 			= arr[i][2]
									nParentIndex 			= arr[i][3]
									nFirstChildIndex 		= arr[i][4]
									nFirstAttributeIndex 	= arr[i][5]
									nAttributeCount 		= arr[i][6]	
										
									if ::g_xmlB_Report_v2 then
									(
										format "\t%\n" 	arr[i][1]	
									)
										
									getAttributes_cdf_xmlB \																	
																	inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																	matNodeCounter:					&matNodeCounter \
																	Attachment_node_counter:	&Attachment_node_counter \
																	theMat:								&theMat \
																	matIDX:								matIDX \
																	nTagString:						&nTagString \
																	tab:									&tab \
																	xmlArr:								&xmlArr \											
																	nFirstAttributeIndex:			&nFirstAttributeIndex \
																	nAttributeCount:					&nAttributeCount \
																	type:									type						

									recurse_cdf_xmlB \															
															inst_s_OPTIONS:					&inst_s_OPTIONS \ 
															matNodeCounter:					&matNodeCounter \
															Attachment_node_counter:	&Attachment_node_counter \
															theMat:								&theMat \
															matIDX:								matIDX \
															tab:									&tab \
															arr:									&arr \
															xmlArr:								&xmlArr \
															nFirstAttributeIndex:			&nFirstAttributeIndex \
															nAttributeCount:					&nAttributeCount \
															i:										i \
															nTagString:						&nTagString \
															nChildCount:						&nChildCount \
															nParentIndex:						&nParentIndex \
															nFirstChildIndex:					&nFirstChildIndex \
															type:									type								
									i+=1

									--Store all the children (<Material>) to the <SubMaterials> node
									Append ::g_cdf_xmlB_MatNodesSet ::g_cdf_xmlB_Parsed
								)
							)
							else
							(
								local nodeType 					= arr[c][1]
								
								local nAttributeCount 			= arr[c][6]
								local nFirstAttributeIndex		= arr[c][5]+1
								
								for xx=0 to nAttributeCount-1 do
								(
									if xmlArr[4][nFirstAttributeIndex+xx] != undefined then
									(
										local attribName 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstAttribute_val --FIX
										local attribVal 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstChild_val
										if ::g_xmlB_Report_v2 then
										(
											format "% = %\n" 	attribName 		attribVal
										)									

										xmlB_storeAttribs_v3 \																	
																		type:									&type \
																		g_xmlB_Parsed:					&g_xmlB_Parsed \
																		matNodeCounter:					&matNodeCounter \
																		Attachment_node_counter:	&Attachment_node_counter \																	
																		theMat:								&theMat \
																		compositeMat:					&compositeMat \
																		matIDX:								&matIDX \
																		nodeType:							&nodeType \
																		attribName:						&attribName \
																		attribVal:							&attribVal	
									)
								)								
 								--Store all the children (<Material>) to the <SubMaterials> node
								Append 		::g_cdf_xmlB_MatNodesSet 		::g_cdf_xmlB_Parsed
							)
						)
					)
-- 				)
			)
		)
	),
	
	fn parse_cdf_xmlB_v3 \
									SkeletonList_Bool: \
									&matNodeCounter: \
									&Attachment_node_counter: \
									&theMat: \
									&compositeMat: \
									&xmlArr: \
									&uniqueIDs: \
									matIDX: \
									&inst_s_OPTIONS: \
									&subMats: \
									type: =
	(		
		local nTagString 						= ""
		local nChildCount 					= 0
		local nParentIndex 					= 0
		local nFirstChildIndex 				= 0
		local nFirstAttributeIndex 			= 0
		local nAttributeCount 				= 0
		
		local nNodeCount 					= 0
		local tab								= 0
		
		local arr									= #()
		
		local idx									= 0
		
		loop_Attribs_cdf_xmlB_v3 \
											inst_s_OPTIONS:					&inst_s_OPTIONS	\ 
											matNodeCounter:					&matNodeCounter	 \
											Attachment_node_counter:	&Attachment_node_counter \
											theMat:								&theMat \
											matIDX:								matIDX \
											tab:									&tab \
											arr:									&arr \
											xmlArr:								&xmlArr \
											nFirstAttributeIndex:			&nFirstAttributeIndex \
											nAttributeCount:					&nAttributeCount \
											i:										i \
											nTagString:						&nTagString \
											nChildCount:						&nChildCount \
											nParentIndex:						&nParentIndex \
											nFirstChildIndex:					&nFirstChildIndex \
											type:									type
	),
		
	fn parse_LOAD_ASSETS_CDF_xmlB_v3 \			
														&matNodeCounter: \
														&Attachment_node_counter: \
														&Anim_Node_Counter: \
														&theMat: \
														&compositeMat: \
														&xmlArr: \
														&uniqueIDs: \
														matIDX: \
														&inst_s_OPTIONS: \
														&subMats: \
														type: =
	(
		local nTagString 						= ""
		local nChildCount 					= 0
		local nParentIndex 					= 0
		local nFirstChildIndex 				= 0
		local nFirstAttributeIndex 			= 0
		local nAttributeCount 				= 0
		
		local nNodeCount 					= 0
		local tab								= 0
		
		local arr									= #()
		
		local idx									= 0
		
		if xmlArr[1].count > 0 then
		(
			--------------------------- Read Rot Material Node ---------------------------
			nNodeCount 		= xmlArr[1][1].nNodeCount
			tab					= 0
			
			if xmlArr[2].count > 0 then
			(
				nTagString		= xmlArr[2][1].nTagString 
				
				if ::g_xmlB_Report_v2 then
				(
					print nTagString
					format "xmlArr[2][1].nParentIndex: %\n" xmlArr[2][1].nParentIndex
				)
				
				--the CDF
				if xmlArr[2][1].nParentIndex == -1 AND (stricmp xmlArr[2][1].nTagString "CharacterDefinition") == 0 then --if indeed root node
				(
					print "******************* CharacterDefinition *******************"
					
					LOAD_ASSETS_CDF_loopAttribs \
																inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																matNodeCounter:					&matNodeCounter \
																Attachment_node_counter:	&Attachment_node_counter \
																Anim_Node_Counter: 			&Anim_Node_Counter \
																theMat:								&theMat \
																matIDX:								matIDX \
																tab:									&tab \
																arr:									&arr \
																xmlArr:								&xmlArr \
																nFirstAttributeIndex:			&nFirstAttributeIndex \
																nAttributeCount:					&nAttributeCount \
																i:										i \
																nTagString:						&nTagString \
																nChildCount:						&nChildCount \
																nParentIndex:						&nParentIndex \
																nFirstChildIndex:					&nFirstChildIndex \
																type:									type
				)
				--the Animation params ( the .chrparams file - .chrparams file has the same name as the character file to which it refers.)
				--see doc http://docs.cryengine.com/display/SDKDOC2/Art+Asset+File+Types#ArtAssetFileTypes-AnimationAssets
				else if xmlArr[2][1].nParentIndex == -1 AND (stricmp xmlArr[2][1].nTagString "Params") == 0 then --if indeed root node 
				(
					print "******************* Params *******************"
					
					LOAD_ASSETS_CDF_loopAttribs \
																inst_s_OPTIONS:					&inst_s_OPTIONS \ 
																matNodeCounter:					&matNodeCounter \
																Attachment_node_counter:	&Attachment_node_counter \
																Anim_Node_Counter: 			&Anim_Node_Counter \
																theMat:								&theMat \
																matIDX:								matIDX \
																tab:									&tab \
																arr:									&arr \
																xmlArr:								&xmlArr \
																nFirstAttributeIndex:			&nFirstAttributeIndex \
																nAttributeCount:					&nAttributeCount \
																i:										i \
																nTagString:						&nTagString \
																nChildCount:						&nChildCount \
																nParentIndex:						&nParentIndex \
																nFirstChildIndex:					&nFirstChildIndex \
																type:									type
				)
			)
		)
	),	
	
	fn parse_SkeletonList_xmlB_v3 \
												SkeletonList_Bool: \
												&matNodeCounter: \
												&Attachment_node_counter: \
												&theMat: \
												&compositeMat: \
												&xmlArr: \
												&uniqueIDs: \
												matIDX: \												
												&inst_s_OPTIONS: \
												&subMats: \
												type: =
	(
		local nTagString 						= ""
		local nChildCount 					= 0
		local nParentIndex 					= 0
		local nFirstChildIndex 				= 0
		local nFirstAttributeIndex 			= 0
		local nAttributeCount 				= 0
		
		local nNodeCount 					= 0
		local tab								= 0
		
		local arr									= #()
		
		local idx									= 0
		
		if xmlArr[1].count > 0 then
		(
			--------------------------- Read Rot Material Node ---------------------------
			nNodeCount 		= xmlArr[1][1].nNodeCount
			tab					= 0
			
			if xmlArr[2].count > 0 then
			(
				nTagString		= xmlArr[2][1].nTagString 
				
				if xmlArr[2][1].nParentIndex == -1 AND (stricmp xmlArr[2][1].nTagString "SkeletonList") == 0 then --if indeed root node
				(
					print "++++++++++++++++++++++++++++ we are in parse_SkeletonList_xmlB_v3 +++++++++++++++++++++++++++++++"					
					
					nFirstAttributeIndex 		= xmlArr[2][1].nFirstAttributeIndex
					nAttributeCount 			= xmlArr[2][1].nAttributeCount					
					
					if ::g_xmlB_Report_v2 then
					(
						for t=1 to tab do ( format "\t" )
						format "%\n" nTagString
					)
					
					getAttributes_cdf_xmlB \													
													SkeletonList_Bool: 				SkeletonList_Bool \
													inst_s_OPTIONS:					&inst_s_OPTIONS \ 
													matNodeCounter:					&matNodeCounter \
													Attachment_node_counter:	&Attachment_node_counter \
													theMat:								&theMat \
													matIDX:								matIDX \
													nTagString:						&nTagString \
													tab:									&tab \
													xmlArr:								&xmlArr \											
													nFirstAttributeIndex:			&nFirstAttributeIndex \
													nAttributeCount:					&nAttributeCount \
													type:									type
					
					
					------------------------------- Read xmlB Nodes -------------------------------
					nChildCount 		= xmlArr[1][1].nChildCount
					
					arr = #() --Fill this temporary array first, from the childNode index xmlArr[3]
					
					if ::g_xmlB_Report_v2 then
					(
						print nChildCount
					)
					
					for x=1 to nChildCount do
					(
						nFirstChildIndex 				= xmlArr[3][x] --ChildNodeIndex pointing to the nodes in xmlArr[2]	
						idx 								= nFirstChildIndex+1
						
						nTagString 						= xmlArr[2][idx].nTagString
						nChildCount 					= xmlArr[2][idx].nChildCount
						nParentIndex 					= xmlArr[2][idx].nParentIndex
						nFirstChildIndex 				= xmlArr[2][idx].nFirstChildIndex
						nFirstAttributeIndex 			= xmlArr[2][idx].nFirstAttributeIndex
						nAttributeCount 				= xmlArr[2][idx].nAttributeCount
						
						Append arr #(nTagString, nChildCount, nParentIndex, nFirstChildIndex, nFirstAttributeIndex, nAttributeCount, x)
					)
					
					for x=1 to arr.count do
					(
						local nodeType					= arr[x][1] --unused for this SkeletonList for now
						
						local nAttributeCount 			= arr[x][6]
						local nFirstAttributeIndex		= arr[x][5]+1
						
						for xx=0 to nAttributeCount-1 do
						(
							local attribName 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstAttribute_val
							local attribVal 		= xmlArr[4][nFirstAttributeIndex+xx].nFirstChild_val						

							--Store in the struct
							Append ::g_inst_stored_SkeletonList_XML._Name	attribName
							Append ::g_inst_stored_SkeletonList_XML._File		attribVal
						)
					)
					
				)
			)
			
			if ::g_xmlB_Report_v2 then
			(
				for t=1 to tab do ( format "\t" )
				format "Done reading the SkeletonList\n"
			)
		)
	),
	--////////////////////////////////////// END OF PARSERS //////////////////////////////////////
	
	
	
	--////////////////////////////////////// TEXTURE BUILDERS //////////////////////////////////////
	fn fix_tex_path \
							&_File_: \
							&inst_s_OPTIONS: \
							=
	(
		-------------------- Construct the correct filepath (because the paths are relative) for the _File_ --------------------
		local texFile = ""
		
		if _File_ != unsupplied then
		(		
			if _File_ != undefined then
			(
				if _File_ != "" then
				(
					local dirPath = ::g_dirpath --we assign the global dirpath to another local variable (because we may want to change it if conditions below warrant it)
									
					if inst_s_OPTIONS.chk_dds then
					(
						--Construct text path
						texName 	= 	((getFileNameFile _File_) + inst_s_OPTIONS.chk_dds_string)
										
						---------------------------- Some of the texture paths in the .mtl have the GameRyse as the parent leaf, but GameRyse is already a top
						--leaf on our ::g_dirpath, so we have to check for it, and strip it to avoid a duplicate "GameRyse" and hence an invalid path
						parentLeaf 		= pathConfig.stripPathToTopParent _File_
						topLeaf 			= pathConfig.stripPathToLeaf ::g_dirpath
						if (stricmp parentLeaf topLeaf) == 0 then
						(
							dirPath = pathConfig.removePathLeaf dirPath
						)
										
						texDir 		= (getFilenamePath _File_)
						texFile		= pathConfig.appendPath (pathConfig.appendPath dirPath texDir) texName
						texFile 		= pathConfig.resolvePathSymbols texFile
					)
					else
					(
						texFile 		= 	pathConfig.resolvePathSymbols ( pathConfig.appendPath dirPath _File_ )
					)
					
					return texFile;
				)
			)
		)
		else
		(
			return texFile = "File Missing"
		)
		------------------------------------------------------------------------------------------------------------------------------------
		return texFile = "File Missing"
	),
	
	fn apply_compositeTexture \
											mapType: \
											texFile: \
											compositeMat: \
											BLENDLAYER: \
											_Opacity_: =
	(
		
		for i=1 to compositeMat.materialList.count do
		(
			if compositeMat.materialList[i] == undefined then
			(
				if (stricmp (mapType as string) "Diffuse") == 0 then
				(					
					compositeMat.materialList[i]												= Standardmaterial ()						
					compositeMat.materialList[i].diffusemap								= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
					compositeMat.materialList[i].opacityMap.alphaSource 			= 0
					compositeMat.materialList[i].opacityMap.monoOutput 			= 1
				)
				if BLENDLAYER then
				(
					compositeMat.materialList[i]												= PhysicalMaterial ()						
					compositeMat.materialList[i].base_color_map						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
					compositeMat.materialList[i].base_color_map.alphaSource 		= 0
					compositeMat.materialList[i].base_color_map.monoOutput 		= 1
					compositeMat.materialList[i].amount									= _Opacity_*100
					
				)
				else if (stricmp (mapType as string) "Normalmap") == 0 then
				(
					if compositeMat.materialList[matIDX].bumpmap == undefined then
					(
						compositeMat.materialList[matIDX].bumpmap 	= Normal_bump()
					)
					
					compositeMat.materialList[matIDX].bumpmap.normal_map 					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
					compositeMat.materialList[matIDX].bumpmap.normal_map.alphasource 	= 2
				)
				else if (stricmp (mapType as string) "Bumpmap") == 0 then
				(
					if compositeMat.materialList[matIDX].bumpmap == undefined then
					(
						compositeMat.materialList[matIDX].bumpmap 	= Normal_bump()
					)
					
					compositeMat.materialList[matIDX].bumpmap.normal_map 					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
					compositeMat.materialList[matIDX].bumpmap.normal_map.alphasource 	= 2
				)
			)
		)		
	),
	
	fn set_texType_tokens \
									&inst_tex_tokens: =
-- 								&diff_tkn: \
-- 								&spec_tkn: \
-- 								&ddn_tkn: \
-- 								&ddna_tkn: =
	(
		local game = (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
		
		case of
		(
			(game == "Ryse"):
			(
				inst_tex_tokens.diff_tkn 		= 	"*_dif*"
				inst_tex_tokens.spec_tkn 		= 	"*_spec*"
				inst_tex_tokens.ddn_tkn		= "*_ddn*"
				inst_tex_tokens.ddna_tkn		= "*_ddna*"
			)
			(game == "HFR"):
			(
				inst_tex_tokens.diff_tkn 		= 	"*_dif*"
				inst_tex_tokens.spec_tkn 		= 	"*_spec*"
				inst_tex_tokens.ddn_tkn		= "*_ddn*"
				inst_tex_tokens.ddna_tkn		= "*_ddna*"
			)
			(game == "Armored Warfare"):
			(
				inst_tex_tokens.diff_tkn 		= 	"*_d*"
				inst_tex_tokens.spec_tkn 		= 	"*_s*"
				inst_tex_tokens.ddn_tkn		= "*_ddn*"
				inst_tex_tokens.ddna_tkn		= "*_ddna*"
			)
			default:
			(
				inst_tex_tokens.diff_tkn 		= 	"*_dif*"
				inst_tex_tokens.spec_tkn 		= 	"*_spec*"
				inst_tex_tokens.ddn_tkn		= "*_ddn*"
				inst_tex_tokens.ddna_tkn		= "*_ddna*"
			)
		)
	),
	
	fn apply_Physical_Material_Texture \
														mapType: \
														&texFile: \
														&theMat: \
														BLENDLAYER: \
														&_Name_: \
														&matIDX: \
														_Opacity_:  \
														&inst_tex_tokens: =
	(
		set_texType_tokens \
									inst_tex_tokens: &inst_tex_tokens		
		
		if (stricmp (mapType as string) "Diffuse") == 0 then
		(
			theMat.materialList[matIDX].base_color_map								= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			theMat.materialList[matIDX].base_color_map.alphaSource 				= 0
			theMat.materialList[matIDX].base_color_map.monoOutput 				= 1
		)
		if (stricmp (mapType as string) "Detail") == 0 then
		(
		)
		if (stricmp (mapType as string) "Decal") == 0 then
		(
		)
		if (stricmp (mapType as string) "SubSurface") == 0 then
		(
		)
		else if (stricmp (mapType as string) "Custom") == 0 then
		(
			theMat.materialList[matIDX].coat_color_map								= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			theMat.materialList[matIDX].coat_color_map.alphaSource 				= 0
			theMat.materialList[matIDX].coat_color_map.monoOutput 				= 1
		)
		else if (stricmp (mapType as string) "Normalmap") == 0 then
		(
			if theMat.materialList[matIDX].bump_map == undefined then
			(
				theMat.materialList[matIDX].bump_map 									= Normal_bump()
			)
					
			theMat.materialList[matIDX].bump_map.normal_map 						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			
			--If has alpha
			if (matchpattern texFile pattern:inst_tex_tokens.ddna_tkn) then
			(
				theMat.materialList[matIDX].bump_map.normal_map.alphasource 		= 2
			)
		)
		else if (stricmp (mapType as string) "Bumpmap") == 0 then
		(
			if theMat.materialList[matIDX].bump_map == undefined then
			(
				theMat.materialList[matIDX].bump_map 									= Normal_bump()
			)
					
			theMat.materialList[matIDX].bump_map.normal_map 						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			
			--If has alpha
			if (matchpattern texFile pattern:inst_tex_tokens.ddna_tkn) then
			(
				theMat.materialList[matIDX].bump_map.normal_map.alphasource 		= 2
			)
		)
		else if (stricmp (mapType as string) "[1] Custom") == 0 then
		(
			if theMat.materialList[matIDX].coat_bump_map == undefined then
			(
				theMat.materialList[matIDX].coat_bump_map 									= Normal_bump()
			)
					
			theMat.materialList[matIDX].coat_bump_map						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			
			--If has alpha
			if (matchpattern texFile pattern:inst_tex_tokens.ddna_tkn) then
			(				
				theMat.materialList[matIDX].coat_bump_map.alphasource 		= 2
			)
		)
		
		if BLENDLAYER then
		(
			theMat.materialList[matIDX].cutout_map									= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			theMat.materialList[matIDX].cutout_map.alphaSource 				= 0
			theMat.materialList[matIDX].cutout_map.monoOutput 				= 1
 			--theMat.materialList[matIDX].coating 												= 1 --not sure what values are the best here, so turned off (meaning set to default) for now
			--theMat.materialList[matIDX].coat_ior											= 1.1 --not sure what values are the best here, so turned off (meaning set to default) for now
		)		
	),	

	--If every check fails to locate the texture, then do a heuristic
	fn texFail_heuristic \	
								mapType: \
								&texFile: \
								&theMat: \
								&matIDX: \
								BLENDLAYER: \
								&_Name_: \
								&_StringGenMask_: \
								&inst_tex_tokens: =
	(
		local fileName 				= (	filenameFromPath 	::g_cryfile	) --stripped of path
		local dir							= (	getFilenamePath 		::g_cryfile	) --only the dir (without the filename)
		local fileName_noSuffix 	= (	getFilenameFile  		::g_cryfile	) --raw filename without the suffix
		
		set_texType_tokens \
									inst_tex_tokens: &inst_tex_tokens
			
		if doesfileexist dir then
		(
			filesArr = getFiles (dir + "*.dds")
				
			if filesArr != undefined then
			(
				for f in filesArr do
				(
					local dirFile 		= filenameFromPath f --stripped of path
	
					if matchPattern dirFile pattern:("*"+fileName_noSuffix+"*") then
					(
						if	(	matchpattern 	dirFile 	pattern:	inst_tex_tokens.diff_tkn	) then
						(
							if ::rollout_Report.chk_Heuristic_Report.state then
							(
								format "### ### ### f: %\n" f
								format "### ### ### dirFile: %\n"  dirFile
							)

							if doesfileexist f then
							(
								texFile = f
								
								for m=1 to theMat.names.count do
								(
									if (stricmp fileName_noSuffix theMat.names[m]) == 0 then
									(
										theMat.materialList[m].base_color_map 					= Bitmaptexture filename:texFile	
										theMat.materialList[m].base_color_map.alphaSource 	= 2
										theMat.materialList[m].showInViewport 					= on	
											
										if Build_Material_Report then
										(
											format "Inside texFail_heuristic ---> ========== map diffuse: % ==========\n" texFile
										)

										------ Check for DECAL ------
										if 	(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"DECAL"			) == true OR
											(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"BLENDLAYER"	) == true OR
											(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"VERTCOLORS"	) == true then
										(
											if (matchpattern texFile pattern:"*_decal*") then
											(	
												apply_Physical_Material_Texture \
																								mapType:				"Diffuse" \
																								texFile:					&texFile \																		
																								theMat:					&theMat \
																								matIDX:					&matIDX \
																								BLENDLAYER:			true \
																								_Name_:				&_Name_ \
																								inst_tex_tokens: 		&inst_tex_tokens
											)
											else if (matchpattern (_Name_ as string) pattern:"*leaks*") then
											(
												apply_Physical_Material_Texture \
																								mapType:				"Diffuse" \
																								texFile:					&texFile \																		
																								theMat:					&theMat \
																								matIDX:					&matIDX \
																								BLENDLAYER:			true \
																								_Name_:				&_Name_ \
																								inst_tex_tokens: 		&inst_tex_tokens
											)
										)
									)									
								)								
							)							
						)					
					)					
				)
			)
		)
	),
	
	fn build_Texture \
							&theMat: \
							&compositeMat: \
							&texFile: \
							_Map_: \							
							&_StringGenMask_: \
							matIDX: \
							_Opacity_: \
							&inst_tex_tokens: =
	(
		--////////////////////////////////////////////////////////////////////////////////
		--See Texture Types
		-- http://docs.cryengine.com/display/SDKDOC2/Textures+Types
		
 		--It is important to use the correct suffix names for your textures as CRYENGINE and the Resource Compiler need this information in order to render textures and compile them correctly.
 		--If you're finding random issues occurring with textures, double check that you have named your textures correctly as listed above.
		--////////////////////////////////////////////////////////////////////////////////
		
		set_texType_tokens \
									inst_tex_tokens: &inst_tex_tokens
		
		--////////////////////////////////// Diffuse Map ////////////////////////////////////						
		if (stricmp (_Map_ as string) "Diffuse") == 0 then
		(							
-- 			if (matchpattern texFile pattern:"*_diff*") OR \
			if	(matchpattern 	texFile 	pattern:inst_tex_tokens.diff_tkn) then
			(				
				local texfile = (pathConfig.resolvePathSymbols texFile)	
				
				theMat.materialList[matIDX].diffusemap 					= Bitmaptexture filename:texFile
				theMat.materialList[matIDX].diffusemap.alphaSource 	= 2
				theMat.materialList[matIDX].showInViewport 			= on		

				if Build_Material_Report then
				(
					format "========== map diffuse: % ==========\n" texFile
				)

				------ Check for DECAL ------
				if (existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL") == true then
				(
					if (matchpattern texFile pattern:"*_decal*") then
					(	
						apply_compositeTexture \
															mapType:			"Diffuse" \
															texFile:				texFile \
															compositeMat:	compositeMat
					)
				)
			)
			else if (matchpattern texFile pattern:"*_dirty_*") then
			(
				apply_compositeTexture \
													mapType:			"Diffuse" \
													texFile:				texFile \
													compositeMat:	compositeMat
			)			
			else if (matchpattern texFile pattern:"*_dirt_diff*") then
			(
				apply_compositeTexture \
													mapType:			"Diffuse" \
													texFile:				texFile \
													compositeMat:	compositeMat
			)
			else if (matchpattern texFile pattern:"*_dirty_diff*") then
			(
				apply_compositeTexture \
													mapType:			"Diffuse" \
													texFile:				texFile \
													compositeMat:	compositeMat
			)
			else if (matchpattern texFile pattern:"*_dirt_a_mask*") then
			(
				apply_compositeTexture \
													mapType:			"Diffuse" \
													texFile:				texFile \
													compositeMat:	compositeMat
			)
			else if (matchpattern texFile pattern:"*_dirty_mask*") then
			(
				apply_compositeTexture \
													mapType:			"Diffuse" \
													texFile:				texFile \
													compositeMat:	compositeMat
			)
			else if (matchpattern texFile pattern:"*_dirt*_*_mask*") then
			(
				apply_compositeTexture \
													mapType:			"Diffuse" \
													texFile:				texFile \
													compositeMat:	compositeMat
			)
			--In some cases, we have seen diffuse textures without the *_diff or _dif extensions, so we have to somehow deal with this
			--So for now, the most proper way is to check whether the texture has any _spec _ddna _ddn etc
			--and if it doesn't then we will assume it is a diffuse texture and apply it as such
			else
			(
				if 	NOT (matchpattern texFile pattern:	inst_tex_tokens.ddn_tkn		) AND \
					NOT (matchpattern texFile pattern:	"*_displ*"	) AND \
					NOT (matchpattern texFile pattern:	"*_detail*"	) AND \
					NOT (matchpattern texFile pattern:	inst_tex_tokens.spec_tkn	) then
				(
				
					local texfile = (pathConfig.resolvePathSymbols texFile)	
					
					theMat.materialList[matIDX].diffusemap 					= Bitmaptexture filename:texfile	
					theMat.materialList[matIDX].diffusemap.alphaSource 	= 2
					theMat.materialList[matIDX].showInViewport 			= on		

					if Build_Material_Report then
					(
						format "========== map diffuse: % ==========\n" texfile
					)						
														
					------ Check for DECAL ------
					if (existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL") == true then
					(
						if (matchpattern texFile pattern:"*_decal*") then
						(	
							apply_compositeTexture \
																mapType:			"Diffuse" \
																texFile:				texFile \
																compositeMat:	compositeMat
						)
					)
				)
			)
		)
		
		--////////////////////////////////// Specular Map ////////////////////////////////////
		if (stricmp (_Map_ as string) "Specular") == 0 then
		(
			if (matchpattern texFile 	pattern:inst_tex_tokens.spec_tkn) then
			(
				theMat.materialList[matIDX].specularLevelMap 						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				theMat.materialList[matIDX].specularLevelMap.alphaSource 	= 2
			)
		)
		------------------------------------------------------------------------------------------------------

		
		--////////////////////////////////// Normalmap Map ////////////////////////////////////
		if (stricmp (_Map_ as string) "Normalmap") == 0 then
		(
-- 			if (matchpattern texFile pattern:"*_ddna*") OR \ 
			if	(matchpattern texFile pattern:inst_tex_tokens.ddn_tkn) then
			(
				if theMat.materialList[matIDX].bumpmap == undefined then
				(
					theMat.materialList[matIDX].bumpmap 	= Normal_bump()
				)
				theMat.materialList[matIDX].bumpmap.normal_map 					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				theMat.materialList[matIDX].bumpmap.normal_map.alphasource 	= 2	
			)
			
			------ Check for DECAL ------
			if (existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL") == true then
			(
				if (matchpattern texFile pattern:"*_decal_ddn*") then
				(
					apply_compositeTexture \
														mapType:			"Normalmap" \
														texFile:				texFile \
														compositeMat:	compositeMat
				)
			)
		)
		--------------------------------------------------------------------------------------------------------


		--////////////////////////////////// Bumpmap Map ////////////////////////////////////
		if (stricmp (_Map_ as string) "Bumpmap") == 0 then
		(
-- 			if (matchpattern texFile pattern:"*_ddna*")  OR \ 
			if	(matchpattern texFile pattern:inst_tex_tokens.ddn_tkn) then 
			(
				if theMat.materialList[matIDX].bumpmap == undefined then
				(
					theMat.materialList[matIDX].bumpmap 	= Normal_bump()
				)
				theMat.materialList[matIDX].bumpmap.normal_map 					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				theMat.materialList[matIDX].bumpmap.normal_map.alphasource 	= 2
			)
			
			------ Check for DECAL ------
			if (existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL") == true then
			(
				if (matchpattern texFile pattern:"*_decal_ddn*") then
				(
					apply_compositeTexture \
														mapType:"Normalmap" \
														texFile:texFile \
														compositeMat:compositeMat
				)
			)
		)
		--------------------------------------------------------------------------------------------------------							


		--////////////////////////////////// Opacity Map ////////////////////////////////////
		if (stricmp (_Opacity_ as string) "Opacity") == 0 then
		(
			theMat.materialList[matIDX].opacityMap 						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			theMat.materialList[matIDX].opacityMap.alphaSource 	= 0
			theMat.materialList[matIDX].opacityMap.monoOutput 	= 1
		)
		------------------------------------------------------------------------------------------------------
		
		--////////////////////////////////// Displacement Map ////////////////////////////////////
		if (stricmp (_Map_ as string) "Heightmap") == 0 then
		(
			if (matchpattern texFile pattern:"*_displ*") then 
			(
				if theMat.materialList[matIDX].displacementMap == undefined then
				(
					theMat.materialList[matIDX].displacementMap 	= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				)
			)
		)
		--------------------------------------------------------------------------------------------------------		
		
		
		--////////////////////////////////// Detail Map ////////////////////////////////////
		if (stricmp (_Map_ as string) "Detail") == 0 then
		(
			if (matchpattern texFile pattern:"*_detail*") then 
			(
				if theMat.materialList[matIDX].bumpmap == undefined then
				(
					theMat.materialList[matIDX].bumpmap 	= Normal_bump()
				)
				theMat.materialList[matIDX].bumpmap.bump_map  					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				theMat.materialList[matIDX].bumpmap.normal_map.alphasource 	= 2
			)
		)
		--------------------------------------------------------------------------------------------------------
		
		------- DETAIL_BUMP_MAPPING -------						
		if 	(	existThis_StringGenMask attribVal:&_StringGenMask_ 	thisString:"DETAIL_BUMP_MAPPING"	) 	== true OR \
			(	existThis_StringGenMask attribVal:&_StringGenMask_ 	thisString:"DETAIL_MAPPING"			) 	== true then
		(
			if theMat.materialList[matIDX].bumpmap == undefined then
			(																				
				theMat.materialList[matIDX].bumpmap 	= Normal_bump()																	
			)																
			theMat.materialList[matIDX].bumpmap.bump_map 						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			theMat.materialList[matIDX].bumpmap.bump_map.alphasource 	= 2
		)
										
		if (existThis_StringGenMask attribVal:(&_StringGenMask_ as string) thisString:"BLENDLAYER") == true then						
		(
			if (stricmp (_Opacity_ as string) "Opacity") == 0 then							
			(
				if isKindOF _Opacity_ integer then
				(
					apply_compositeTexture \
														mapType:			"Normalmap" \
														texFile:				texFile \
														compositeMat:	compositeMat \
														BLENDLAYER:		true
				)
			)
		)
		
		if ::g_xmlB_Report_v2 then
		(
			format "\n\n\n"
		)							
	),
	
	fn build_Physical_Texture \
										&theMat: \
										&compositeMat: \ --deprecated
										&texFile: \
										_Map_: \							
										&_StringGenMask_: \
										&matIDX: \
										_Opacity_: \
										_Name_: \
										&inst_tex_tokens: =
	(		
		local BLENDLAYER = false
		
		if ::rollout_Report.chk_MaterialRef_Report.state then
		(
			format "\n\nInside build_Physical_Texture --> texFile: %	\n" 			texFile
			format  "Inside build_Physical_Texture -->  _Map_: %\n" 				_Map_
			format  "Inside build_Physical_Texture -->  matIDX: %\n" 				matIDX			
		)
		
		--////////////////////////////////////////////////////////////////////////////////
		--See Texture Types
		-- http://docs.cryengine.com/display/SDKDOC2/Textures+Types
		
 		--It is important to use the correct suffix names for your textures as CRYENGINE and the Resource Compiler need this information in order to render textures and compile them correctly.
 		--If you're finding random issues occurring with textures, double check that you have named your textures correctly as listed above.
		--////////////////////////////////////////////////////////////////////////////////
		
		set_texType_tokens \
									inst_tex_tokens: &inst_tex_tokens
		
		--////////////////////////////////// Diffuse Map ////////////////////////////////////						
		if 	(stricmp (_Map_ as string) "Diffuse") == 0 then --safe
		(
			if	(matchpattern texFile pattern:	inst_tex_tokens.diff_tkn	) then			
			(
				local texFile = (pathConfig.resolvePathSymbols texFile)
			
				if doesfileexist texFile then
				(
					theMat.materialList[matIDX].base_color_map 					= Bitmaptexture filename:texFile	
					theMat.materialList[matIDX].base_color_map.alphaSource 	= 2
					theMat.materialList[matIDX].showInViewport 					= on		

					if Build_Material_Report then
					(
						format "========== map diffuse: % ==========\n" texFile
					)

					------ Check for DECAL ------
					if 	(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"DECAL"			) == true OR
						(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"BLENDLAYER"	) == true OR
						(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"VERTCOLORS"	) == true then
					(
						if (matchpattern texFile pattern:"*_decal*") then
						(	
							apply_Physical_Material_Texture \
																			mapType:			"Diffuse" \
																			texFile:				&texFile \																		
																			theMat:				&theMat \
																			matIDX:				&matIDX \
																			BLENDLAYER:		true \
																			_Name_:			&_Name_ \
																			inst_tex_tokens:	&inst_tex_tokens
						)
						else if (matchpattern (_Name_ as string) pattern:"*leaks*") then
						(
							apply_Physical_Material_Texture \
																			mapType:			"Diffuse" \
																			texFile:				&texFile \																		
																			theMat:				&theMat \
																			matIDX:				&matIDX \
																			BLENDLAYER:		true \
																			_Name_:			&_Name_ \
																			inst_tex_tokens:	&inst_tex_tokens
						)
					)
				)
			)
			
			else if (matchpattern texFile pattern:"*_dirty_*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:			"Diffuse" \
																texFile:				&texFile \
																theMat:				&theMat \
																matIDX:				&matIDX \
																BLENDLAYER:		true \
																_Name_:			&_Name_ \
																inst_tex_tokens:	&inst_tex_tokens
			)			
			else if (matchpattern texFile pattern:"*_dirt_diff*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:			"Diffuse" \
																texFile:				&texFile \
																theMat:				&theMat \
																matIDX:				&matIDX \
																BLENDLAYER:		true \
																_Name_:			&_Name_ \
																inst_tex_tokens:	&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirty_diff*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:			"Diffuse" \
																texFile:				&texFile \
																theMat:				&theMat \
																matIDX:				&matIDX \
																BLENDLAYER:		true \
																_Name_:			&_Name_ \
																inst_tex_tokens:	&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirt_a_mask*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:			"Diffuse" \
																texFile:				&texFile \
																theMat:				&theMat \
																matIDX:				&matIDX \
																BLENDLAYER:		true \
																_Name_:			&_Name_ \
																inst_tex_tokens:	&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirty_mask*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:			"Diffuse" \
																texFile:				&texFile \
																theMat:				&theMat \
																matIDX:				&matIDX \
																BLENDLAYER:		true \
																_Name_:			&_Name_ \
																inst_tex_tokens:	&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirt*_*_mask*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:			"Diffuse" \
																texFile:				&texFile \
																theMat:				&theMat \
																matIDX:				&matIDX \
																BLENDLAYER:		true \
																_Name_:			&_Name_ \
																inst_tex_tokens:	&inst_tex_tokens
																
			)			
			--In some cases (I don't know why, maybe some kind of bug or error by an artist), we have seen diffuse textures without the *_diff or _dif extensions, so we have to somehow deal with this
			--So for now, the most proper way is to check whether the texture has any _spec _ddna _ddn etc
			--and if it doesn't then we will assume it is a diffuse texture and apply it as such
			else --safe
			(
				if 	NOT (matchpattern texFile pattern:	inst_tex_tokens.ddn_tkn	) AND \
					NOT (matchpattern texFile pattern:	"*_displ*"	) AND \
					NOT (matchpattern texFile pattern:	"*_detail*"	) AND \
					NOT (matchpattern texFile pattern:	"*_tran*"	) AND \
					NOT (matchpattern texFile pattern:	inst_tex_tokens.spec_tkn	) then
				(
					local texFile = (pathConfig.resolvePathSymbols texFile)
			
					if doesfileexist texFile then
					(			
						theMat.materialList[matIDX].base_color_map 					= Bitmaptexture filename:texFile	
						theMat.materialList[matIDX].base_color_map.alphaSource 	= 2
						theMat.materialList[matIDX].showInViewport 					= on		

						if Build_Material_Report then
						(
							format "========== map diffuse: % ==========\n" texFile
						)

						------ Check for DECAL ------
						if 	(	existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL"			) == true OR
							(	existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"BLENDLAYER"	) == true OR
							(	existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"VERTCOLORS"	) == true  then
						(
							if (matchpattern texFile pattern:"*_decal*") then
							(	
								apply_Physical_Material_Texture \
																				mapType:				"Diffuse" \
																				texFile:					&texFile \																		
																				theMat:					&theMat \
																				matIDX:					&matIDX \
																				BLENDLAYER:			true \
																				_Name_:				&_Name_ \
																				inst_tex_tokens:		&inst_tex_tokens
																				
							)
							else if (matchpattern (_Name_ as string) pattern:"*leaks*") then
							(
								apply_Physical_Material_Texture \
																				mapType:				"Diffuse" \
																				texFile:					&texFile \																		
																				theMat:					&theMat \
																				matIDX:					&matIDX \
																				BLENDLAYER:			true \
																				_Name_:				&_Name_ \
																				inst_tex_tokens:		&inst_tex_tokens
																				
																				
							)
						)
					)
				)
			)						
			
			
			--Do a heuristic check to at least do something if no texture is found
			if NOT doesfileexist ((pathConfig.resolvePathSymbols texFile)) then --safe
			(				
				texFail_heuristic \	
										mapType:				"Diffuse" \
										texFile:					&texFile \
										theMat:					&theMat \
										matIDX:					&matIDX \
										BLENDLAYER:			true \
										_Name_:				&_Name \
										_StringGenMask_:	&_StringGenMask_ \
										inst_tex_tokens:		&inst_tex_tokens
										
			)
		)		
		
		--////////////////////////////////// Opacity Map //////////////////////////////////// --safe
		if (stricmp (_Map_ as string) "SubSurface") == 0 then
		(
			--Put code here			
		)
		
		if (stricmp (_Map_ as string) "Custom") == 0 then
		(
			if	(matchpattern texFile pattern:	inst_tex_tokens.diff_tkn	) then			
			(
				local texFile = (pathConfig.resolvePathSymbols texFile)
			
				if doesfileexist texFile then
				(
					theMat.materialList[matIDX].coat_color_map 					= Bitmaptexture filename:texFile	
					theMat.materialList[matIDX].coat_color_map.alphaSource 	= 2
					theMat.materialList[matIDX].showInViewport 					= on		

					if Build_Material_Report then
					(
						format "========== map diffuse: % ==========\n" texFile
					)

					------ Check for DECAL ------
					if 	(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"DECAL"			) == true OR
						(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"BLENDLAYER"	) == true OR
						(existThis_StringGenMask 	attribVal:	&_StringGenMask_ thisString:	"VERTCOLORS"	) == true then
					(
						if (matchpattern texFile pattern:"*_decal*") then
						(	
							apply_Physical_Material_Texture \
																			mapType:				"Custom" \
																			texFile:					&texFile \																		
																			theMat:					&theMat \
																			matIDX:					&matIDX \
																			BLENDLAYER:			true \
																			_Name_:				&_Name_ \
																			inst_tex_tokens:		&inst_tex_tokens
																			
						)
						else if (matchpattern (_Name_ as string) pattern:"*leaks*") then
						(
							apply_Physical_Material_Texture \
																			mapType:				"Custom" \
																			texFile:					&texFile \																		
																			theMat:					&theMat \
																			matIDX:					&matIDX \
																			BLENDLAYER:			true \
																			_Name_:				&_Name_ \
																			inst_tex_tokens:		&inst_tex_tokens
																			
						)
					)
				)
			)
			else if (matchpattern texFile pattern:"*_dirty_*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:				"Custom" \
																texFile:					&texFile \
																theMat:					&theMat \
																matIDX:					&matIDX \
																BLENDLAYER:			true \
																_Name_:				&_Name_ \
																inst_tex_tokens:		&inst_tex_tokens
																
			)			
			else if (matchpattern texFile pattern:"*_dirt_diff*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:				"Custom" \
																texFile:					&texFile \
																theMat:					&theMat \
																matIDX:					&matIDX \
																BLENDLAYER:			true \
																_Name_:				&_Name_ \
																inst_tex_tokens:		&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirty_diff*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:				"Custom" \
																texFile:					&texFile \
																theMat:					&theMat \
																matIDX:					&matIDX \
																BLENDLAYER:			true \
																_Name_:				&_Name_ \
																inst_tex_tokens:		&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirt_a_mask*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:				"Custom" \
																texFile:					&texFile \
																theMat:					&theMat \
																matIDX:					&matIDX \
																BLENDLAYER:			true \
																_Name_:				&_Name_ \
																inst_tex_tokens:		&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirty_mask*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:				"Custom" \
																texFile:					&texFile \
																theMat:					&theMat \
																matIDX:					&matIDX \
																BLENDLAYER:			true \
																_Name_:				&_Name_ \
																inst_tex_tokens:		&inst_tex_tokens
																
			)
			else if (matchpattern texFile pattern:"*_dirt*_*_mask*") then --safe
			(
				apply_Physical_Material_Texture \
																mapType:				"Custom" \
																texFile:					&texFile \
																theMat:					&theMat \
																matIDX:					&matIDX \
																BLENDLAYER:			true \
																_Name_:				&_Name_ \
																inst_tex_tokens:		&inst_tex_tokens
																
			)
			
			--In some cases (I don't know why, maybe some kind of bug or error by an artist), we have seen diffuse textures without the *_diff or _dif extensions, so we have to somehow deal with this
			--So for now, the most proper way is to check whether the texture has any _spec _ddna _ddn etc
			--and if it doesn't then we will assume it is a diffuse texture and apply it as such
			else
			(
				if 	NOT (matchpattern texFile pattern:	inst_tex_tokens.ddn_tkn	) AND \
					NOT (matchpattern texFile pattern:	"*_displ*"	) AND \
					NOT (matchpattern texFile pattern:	"*_detail*"	) AND \
					NOT (matchpattern texFile pattern:	"*_tran*"	) AND \
					NOT (matchpattern texFile pattern:	inst_tex_tokens.spec_tkn	) then
				(
					local texFile = (pathConfig.resolvePathSymbols texFile)
			
					if doesfileexist texFile then
					(			
						theMat.materialList[matIDX].base_color_map 					= Bitmaptexture filename:texFile	
						theMat.materialList[matIDX].base_color_map.alphaSource 	= 2
						theMat.materialList[matIDX].showInViewport 					= on		

						if Build_Material_Report then
						(
							format "========== map Custom: % ==========\n" texFile
						)

						------ Check for DECAL ------
						if 	(	existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL"			) == true OR
							(	existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"BLENDLAYER"	) == true OR
							(	existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"VERTCOLORS"	) == true  then
						(
							if (matchpattern texFile pattern:"*_decal*") then
							(	
								apply_Physical_Material_Texture \
																				mapType:				"Custom" \
																				texFile:					&texFile \																		
																				theMat:					&theMat \
																				matIDX:					&matIDX \
																				BLENDLAYER:			true \
																				_Name_:				&_Name_ \
																				inst_tex_tokens:		&inst_tex_tokens
																				
							)
							else if (matchpattern (_Name_ as string) pattern:"*leaks*") then
							(
								apply_Physical_Material_Texture \
																				mapType:				"Custom" \
																				texFile:					&texFile \																		
																				theMat:					&theMat \
																				matIDX:					&matIDX \
																				BLENDLAYER:			true \
																				_Name_:				&_Name_ \
																				inst_tex_tokens:		&inst_tex_tokens
																				
							)
						)
					)
				)
			)
			
			--Do a heuristic check to at least do something if no texture is found --safe
			if NOT doesfileexist ((pathConfig.resolvePathSymbols texFile)) then
			(				
				texFail_heuristic \	
										mapType:				"Custom" \
										texFile:					&texFile \
										theMat:					&theMat \
										matIDX:					&matIDX \
										BLENDLAYER:			true \
										_Name_:				&_Name \
										_StringGenMask_:	&_StringGenMask_ \
										inst_tex_tokens:		&inst_tex_tokens
										
			)	
		)
		--////////////////////////////////// Specular Map ////////////////////////////////////--safe
		if (stricmp (_Map_ as string) "Specular") == 0 then
		(
			if (matchpattern texFile pattern:inst_tex_tokens.spec_tkn) then
			(
				theMat.materialList[matIDX].roughness_map 								= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				theMat.materialList[matIDX].roughness_map.alphaSource 				= 2
				
				--Adjustments
				theMat.materialList[matIDX].roughness_map.output.output_amount 	= ::inst_PHYS_MAT_ADJUST.spec_output_amount
			)
		)
		------------------------------------------------------------------------------------------------------
			
		--////////////////////////////////// Normalmap Map //////////////////////////////////// --safe
		if 	(stricmp (_Map_ as string) "Normalmap") == 0 then			
		(
			if	(matchpattern texFile pattern:inst_tex_tokens.ddn_tkn) then
			(
				if theMat.materialList[matIDX].bump_map == undefined then
				(
					theMat.materialList[matIDX].bump_map 	= Normal_bump()
				)
				theMat.materialList[matIDX].bump_map.normal_map 					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				
				if (matchpattern texFile pattern:inst_tex_tokens.ddna_tkn) then
				(
					theMat.materialList[matIDX].bump_map.normal_map.alphasource 	= 2
				)					
			)
			
			------ Check for DECAL ------
			if (existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL") == true then
			(
				if (matchpattern texFile pattern:"*_decal_ddn*") then
				(
					apply_Physical_Material_Texture \
																	mapType:				"Normalmap" \
																	texFile:					&texFile \
																	theMat:					&theMat \
																	matIDX:					&matIDX \
																	BLENDLAYER:			true \
																	inst_tex_tokens:		&inst_tex_tokens
																	
				)
			)
		)
		--------------------------------------------------------------------------------------------------------
		
		if (stricmp (_Map_ as string) "[1] Custom") == 0 then --safe
		(
			if	(matchpattern texFile pattern:inst_tex_tokens.ddn_tkn) then
			(
				if theMat.materialList[matIDX].coat_bump_map == undefined then
				(
					theMat.materialList[matIDX].coat_bump_map 	= Normal_bump ()
				)
				else
				(
					theMat.materialList[matIDX].coat_bump_map 					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
					
					--If has alpha
					if (matchpattern texFile pattern:inst_tex_tokens.ddna_tkn) then
					(
						theMat.materialList[matIDX].coat_bump_map.alphasource 	= 2
					)
					
				)					
			)			
			
			------ Check for DECAL ------
			if (existThis_StringGenMask attribVal:&_StringGenMask_ thisString:"DECAL") == true then
			(
				if (matchpattern texFile pattern:"*_decal_ddn*") then
				(
					apply_Physical_Material_Texture \
																	mapType:				"[1] Custom" \
																	texFile:					&texFile \
																	theMat:					&theMat \
																	matIDX:					&matIDX \
																	BLENDLAYER:			true \
																	inst_tex_tokens:		&inst_tex_tokens
																	
				)
			)
		)	
			
		--////////////////////////////////// Opacity Map //////////////////////////////////// --safe
		if (stricmp (_Opacity_ as string) "Opacity") == 0 then
		(
			if (matchpattern texFile pattern:"*_mask*") then
			(
				--Put code here
			)
			
			theMat.materialList[matIDX].trans_color_map 						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			theMat.materialList[matIDX].trans_color_map.alphaSource 		= 0
			theMat.materialList[matIDX].trans_color_map.monoOutput 		= 1
		)
		------------------------------------------------------------------------------------------------------
		
		--////////////////////////////////// Displacement Map //////////////////////////////////// --safe
		if 	(stricmp (_Map_ as string) "Heightmap") == 0 OR \
			(stricmp (_Map_ as string) "SubSurface") == 0 then 
		(
			if (matchpattern texFile pattern:"*_displ*") then 
			(
				if theMat.materialList[matIDX].displacement_map == undefined then
				(
					theMat.materialList[matIDX].displacement_map 			= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
					theMat.materialList[matIDX].displacement_map_amt 		= ::rollout_options.spn_displacement_map_amt.value
				)
			)
		)
		--------------------------------------------------------------------------------------------------------		
		
		--////////////////////////////////// Detail Map //////////////////////////////////// --safe
		if (stricmp (_Map_ as string) "Detail") == 0 then
		(
			if (matchpattern texFile pattern:"*_detail*") then 
			(
				if theMat.materialList[matIDX].coat_bump_map == undefined then
				(
					theMat.materialList[matIDX].coat_bump_map 	= Normal_bump()
				)
				theMat.materialList[matIDX].coat_bump_map  					= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
				
				--If has alpha
				if (matchpattern texFile pattern:inst_tex_tokens.ddna_tkn) then
				(
					theMat.materialList[matIDX].coat_bump_map.alphasource 	= 2
				)
				
			)
		)
		--------------------------------------------------------------------------------------------------------		
							
		------- DETAIL_BUMP_MAPPING -------	unsafe but now safe, the problem was we had to do *_StringGenMask_ * ---> (_StringGenMask_  as string)
		if 	(	existThis_StringGenMask 		attribVal:(&_StringGenMask_ as string) 	thisString:"DETAIL_BUMP_MAPPING"		) OR \
			(	existThis_StringGenMask 		attribVal:(&_StringGenMask_ as string) 	thisString:"DETAIL_MAPPING"				) then
		(
			if theMat.materialList[matIDX].coat_bump_map == undefined then
			(																				
				theMat.materialList[matIDX].coat_bump_map 	= Normal_bump()																	
			)																
			theMat.materialList[matIDX].coat_bump_map 						= Bitmaptexture filename:(pathConfig.resolvePathSymbols texFile)
			
			--If has alpha
			if (matchpattern texFile pattern:inst_tex_tokens.ddna_tkn) then
			(
				theMat.materialList[matIDX].coat_bump_map.alphasource 	= 2
			)
		)
										
		if (existThis_StringGenMask attribVal:(&_StringGenMask_ as string) thisString:"BLENDLAYER") == true then --safe				
		(
			if (stricmp (_Opacity_ as string) "Opacity") == 0 then							
			(
				if isKindOF _Opacity_ integer then
				(
					apply_Physical_Material_Texture \
																	mapType:				"Normalmap" \
																	texFile:					&texFile \
																	theMat:					&theMat \
																	matIDX:					&matIDX \
																	BLENDLAYER:			true \
																	inst_tex_tokens:		&inst_tex_tokens
																	
				)
			)
		)		
	),
	
	fn set_surfaceType_standard \
											matIDX: \		
											&_SurfaceType_: \
											&theMat: =
	(
		--Set Surface Types if defined
		if (stricmp (_SurfaceType_ as string)  "mat_metal" ) == 0 then
		(
			--// Put code here
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_marble" ) == 0 then
		(		
			--// Put code here			
		)
	),
	
	fn traverse_matNodeSet_standard \
													&matNodeSet: \
													&uniqueIDs: \
													&matIDX: \
													&MaterialRef_node_counter: \
													&theMat: \
													&inst_s_OPTIONS: \
													&iMesh: \
													&m: \
													&inst_tex_tokens: =
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
		local _GenMask_ 				= ""
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
		
		for i=1 to  matNodeSet[m][2].count do
		(
			if matNodeSet[m][2][i]._Name_[2]  != undefined then
			(
				_Name_name 					= matNodeSet[m][2][i]._Name_[1]
				_Name_ 							= matNodeSet[m][2][i]._Name_[2]						
			)
					
			if matNodeSet[m][2][i]._Shader_[2]  != undefined then
			(
				_Shader_name 				= matNodeSet[m][2][i]._Shader_[1]
				_Shader_ 						= matNodeSet[m][2][i]._Shader_[2]						
			)
					
			if matNodeSet[m][2][i]._MtlFlags_[2]  != undefined then
			(
				_MtlFlags_name 				= matNodeSet[m][2][i]._MtlFlags_[1]
				_MtlFlags_ 						= matNodeSet[m][2][i]._MtlFlags_[2]
				_MtlFlags_arr					= matNodeSet[m][2][i]._MtlFlags_arr
						
				if ::g_Build_Material_Report then
				(
					format "\n_MtlFlags_arr:\n"
					print _MtlFlags_arr
				)						
			)
					
			if matNodeSet[m][2][i]._GenMask_[2]  != undefined then
			(
				_GenMask_name 				= matNodeSet[m][2][i]._GenMask_[1]
				_GenMask_ 					= matNodeSet[m][2][i]._GenMask_[2]
				_GenMask_arr					= matNodeSet[m][2][i]._GenMask_arr
						
				if ::g_Build_Material_Report then
				(
					format "\n_GenMask_arr:\n"
					print _GenMask_arr
				)
			)
					
			if matNodeSet[m][2][i]._StringGenMask_[2]  != undefined then
			(
				_StringGenMask_name 		= matNodeSet[m][2][i]._StringGenMask_[1]
				_StringGenMask_ 			= matNodeSet[m][2][i]._StringGenMask_[2]
						
				if ::g_Build_Material_Report then
				(
					format "\n_StringGenMask_:\n"
					print _StringGenMask_
				)
			)

			if matNodeSet[m][2][i]._SurfaceType_[2]  != undefined then
			(
				_SurfaceType_name 		= matNodeSet[m][2][i]._SurfaceType_[1]
				_SurfaceType_ 				= matNodeSet[m][2][i]._SurfaceType_[2]
			)
					
			if matNodeSet[m][2][i]._MatTemplate_[2]  != undefined then
			(
				_MatTemplate_name 		= matNodeSet[m][2][i]._MatTemplate_[1]
				_MatTemplate_ 				= matNodeSet[m][2][i]._MatTemplate_[2]
			)
					
			if matNodeSet[m][2][i]._Diffuse_[2]  != undefined then
			(
				_Diffuse_name 				= matNodeSet[m][2][i]._Diffuse_[1]
				_Diffuse_ 						= matNodeSet[m][2][i]._Diffuse_[2]
			)
					
			if matNodeSet[m][2][i]._Specular_[2]  != undefined then
			(
				_Specular_name 				= matNodeSet[m][2][i]._Specular_[1]
				_Specular_ 					= matNodeSet[m][2][i]._Specular_[2]
			)
					
			if matNodeSet[m][2][i]._Emissive_[2]  != undefined then
			(
				_Emissive_name 				= matNodeSet[m][2][i]._Emissive_[1]
				_Emissive_ 						= matNodeSet[m][2][i]._Emissive_[2]
			)
					
			if matNodeSet[m][2][i]._Shininess_[2]  != undefined then
			(
				_Shininess_name 				= matNodeSet[m][2][i]._Shininess_[1]
				_Shininess_ 					= matNodeSet[m][2][i]._Shininess_[2]
			)
					
			if matNodeSet[m][2][i]._Opacity_[2]  != undefined then
			(
				_Opacity_name 				= matNodeSet[m][2][i]._Opacity_[1]
				_Opacity_ 						= matNodeSet[m][2][i]._Opacity_[2]
			)
					
			if matNodeSet[m][2][i]._LayerAct_[2]  != undefined then
			(
				_LayerAct_name 				= matNodeSet[m][2][i]._LayerAct_[1]
				_LayerAct_ 					= matNodeSet[m][2][i]._LayerAct_[2]
			)					

					
			--//////////////////////////////////////////////////////////////////////////
			--Now that we have all the attribs stored for the current matIDX (current meshID), we can finalise the material construction
			if _Name_ != undefined then --Material
			(
				if (stricmp (_Name_ as string) "Proxy") != 0 then
				(						
					if (stricmp (_Shader_ as string)"Nodraw") != 0 then
					(
						if (stricmp (_Shader_ as string) "Illum") == 0 then
						(
							--/////////////////////////////// Name the material id lists ///////////////////////////////
							theMat.names[matIDX] = _Name_
									
							--Also name the physical proxy --Material ID 1 should always be the Proxy Material.
							-- See http://docs.cryengine.com/display/SDKDOC2/Basic+Asset+Setup+and+Export+out+of+Max									
							--theMat.names[1] = "Proxy"
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set diffuse color ////////////////////////////////////
							mult = 255
							if (stricmp (_Diffuse_name as string) "Diffuse") == 0 then
							(
								local Diffuse_arr = filterstring _Diffuse_ ","				

								--convert the array string values to Float
								if Diffuse_arr.count == 3 then
								(
									for s=1 to Diffuse_arr.count do
									(
										Diffuse_arr[s] = Diffuse_arr[s] as Float --this must be Float
									)
									theMat.materialList[matIDX].diffuse = color (Diffuse_arr[1]*mult) (Diffuse_arr[2]*mult) (Diffuse_arr[3]*mult)
								)
							)
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set glossiness ////////////////////////////////////
							mult = 255
							local glossiness_arr = filterstring _Specular_ ","
							if glossiness_arr.count == 3 then
							(
								--convert the array string values to Float
								for s=1 to glossiness_arr.count do
								(																	
									glossiness_arr[s] = glossiness_arr[s] as Float --this must be Float						
								)
								theMat.materialList[matIDX].specular = ((glossiness_arr[1]*mult)+(glossiness_arr[2]*mult)+(glossiness_arr[3]*mult))/3
							)
							--------------------------------------------------------------------------------------------------------

							--////////////////////////////////// Set Emissive ////////////////////////////////////
							mult = 255	
							if _Emissive_ != "" then
							(
								local Emissive_arr = filterstring _Emissive_ ","
																															
								--convert the array string values to Float
								if Emissive_arr.count == 3 then
								(										
									for s=1 to Emissive_arr.count do
									(																
										Emissive_arr[s] = Emissive_arr[s] as Float --this must be Float					
									)
																				
									if Emissive_arr[1] > 0 AND Emissive_arr[2] > 0 AND Emissive_arr[3] > 0 then
									(												
										theMat.materialList[matIDX].useSelfIllumColor 	= on
										theMat.materialList[matIDX].selfIllumColor 		= color (Emissive_arr[1]*mult) (Emissive_arr[2]*mult) (Emissive_arr[3]*mult)
									)
								)
							)
							--------------------------------------------------------------------------------------------------------
						)
						if (stricmp (_Shader_ as string) "metal") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "HumanSkin") == 0 then
						(
							--/////////////////////////////// Name the material id lists ///////////////////////////////
							theMat.names[matIDX] = _Name_
									
							--Also name the physical proxy --Material ID 1 should always be the Proxy Material.
							-- See http://docs.cryengine.com/display/SDKDOC2/Basic+Asset+Setup+and+Export+out+of+Max									
							--theMat.names[1] = "Proxy"
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set diffuse color ////////////////////////////////////
							mult = 255
							if (stricmp (_Diffuse_name as string) "Diffuse") == 0 then
							(
								local Diffuse_arr = filterstring _Diffuse_ ","				

								--convert the array string values to Float
								if Diffuse_arr.count == 3 then
								(
									for s=1 to Diffuse_arr.count do
									(
										Diffuse_arr[s] = Diffuse_arr[s] as Float --this must be Float
									)
									theMat.materialList[matIDX].Diffuse = color (Diffuse_arr[1]*mult) (Diffuse_arr[2]*mult) (Diffuse_arr[3]*mult)
								)
							)
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set glossiness ////////////////////////////////////
							mult = 255
							local glossiness_arr = filterstring _Specular_ ","
							if glossiness_arr.count == 3 then
							(
								--convert the array string values to Float
								for s=1 to glossiness_arr.count do
								(																	
									glossiness_arr[s] = glossiness_arr[s] as Float --this must be Float						
								)
								theMat.materialList[matIDX].specular = ((glossiness_arr[1]*mult)+(glossiness_arr[2]*mult)+(glossiness_arr[3]*mult))/3
							)
							--------------------------------------------------------------------------------------------------------

							--////////////////////////////////// Set Emissive ////////////////////////////////////
							mult = 255	
							if _Emissive_ != "" then
							(
								local Emissive_arr = filterstring _Emissive_ ","
																															
								--convert the array string values to Float
								if Emissive_arr.count == 3 then
								(										
									for s=1 to Emissive_arr.count do
									(																
										Emissive_arr[s] = Emissive_arr[s] as Float --this must be Float					
									)
																				
									if Emissive_arr[1] > 0 AND Emissive_arr[2] > 0 AND Emissive_arr[3] > 0 then
									(												
										theMat.materialList[matIDX].useSelfIllumColor 	= on
										theMat.materialList[matIDX].selfIllumColor 		= color (Emissive_arr[1]*mult) (Emissive_arr[2]*mult) (Emissive_arr[3]*mult)
									)
								)
							)
							--------------------------------------------------------------------------------------------------------
						)
						if (stricmp (_Shader_ as string) "Hair") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Glass") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "GeometryBeam") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Eye") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "DistanceClouds") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Common.Cloud") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "LightBeam.LightBeam") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Particles") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "ReferenceImage") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "TemplBeamProc") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Terrain.Layer") == 0 then
						(
							--see: ShaderParse.cpp 509
							-- 	uint64 CShaderMan::mfGetRemapedShaderMaskGen( const char* szName, uint64 nMaskGen, bool bFixup )
							-- {
							-- 	if (!nMaskGen)
							-- 		return 0;
									
							-- 	uint64 nMaskGenRemaped = 0;
							-- 	string szShaderName    = PathUtil::GetFileName(szName);// some shaders might be using concatenated names (eg: terrain.layer), get only first name
							-- 	szShaderName.MakeUpper();
							-- 	ShaderMapNameFlagsItor pShaderRmp = m_pShadersGlobalFlags.find( szShaderName.c_str());
						)
						if (stricmp (_Shader_ as string) "Vegetation") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "VolumeObject") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Waterfall") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Water") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Watervolume") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Nodraw") == 0 then
						(
						)
					)
				)
			)
			--//////////////////////////////////////////////////////////////////////////						
		)
				
		for i=1 to  matNodeSet[m][3].count do --Textures
		(					
			if matNodeSet[m][3][i]._Map_[2]  != undefined then
			(					
				_Map_name 					= matNodeSet[m][3][i]._Map_[1]
				_Map_ 							= matNodeSet[m][3][i]._Map_[2]
			)					
			else if matNodeSet[m][3][i]._File_[2]  != undefined then
			(
				_File_name 					= matNodeSet[m][3][i]._File_[1]
				_File_ 							= matNodeSet[m][3][i]._File_[2]
			)
					
			if matNodeSet[m][3][i]._TexType_[2]  != undefined then
			(
				_TexType_name 				= matNodeSet[m][3][i]._TexType_[1]
				_TexType_ 					= matNodeSet[m][3][i]._TexType_[2]
			)
					
			if matNodeSet[m][3][i]._IsTileU_[2]  != undefined then
			(
				_IsTileU_name 				= matNodeSet[m][3][i]._IsTileU_[1]
				_IsTileU_ 						= matNodeSet[m][3][i]._IsTileU_[2]
			)
					
			if matNodeSet[m][3][i]._IsTileV_[2]  != undefined then
			(
				_IsTileV_name 				= matNodeSet[m][3][i]._IsTileV_[1]
				_IsTileV_ 						= matNodeSet[m][3][i]._IsTileV_[2]
			)					
					
			--//////////////////////////////////////////////////////////////////////////
			--///////////////////////// Texture Node Attribs --////////////////////////
			if _File_ != undefined then
			(
				if pathConfig.isLegalPath _File_ then
				(	
					if _Map_ != undefined then
					(								
						texFile = fix_tex_path \
														_File_:				&_File_ \
														inst_s_OPTIONS:	&inst_s_OPTIONS
								
						--------------------------------------------------------------------------------------------------------------------
						if ::rollout_Report.chk_MaterialRef_Report.state then
						(
							format "*** ### ***    texFile: %    *** ### ***\n" texFile	
						)
						--Change path to *.dds (should be .tif, but we do not have the tif files)
						fix_MaterialRef_refsPath \
														texFile:&texFile \
														suffix:inst_s_OPTIONS.chk_dds_string
								
						if ::rollout_Report.chk_MaterialRef_Report.state then
						(
							format "File Path changed with function fix_MaterialRef_refsPath*** ### ***   texFile: %    *** ### ***\n" 	texFile						
							format "*** ### ***   MaterialRef_node_counter	: %    *** ### ***\n"														MaterialRef_node_counter
						)
						--------------------------------------------------------------------------------------------------------------------
								
						if texFile != undefined then
						(
							if doesfileexist texFile then
							(
								build_Texture \
													theMat:										&theMat \																	
													texFile:										&texFile \
													_Map_:										_Map_ \													
													_StringGenMask_:						&_StringGenMask_ \
													matIDX:										&matIDX \
													_Opacity_:									_Opacity_ \
													_Name_:									_Name_
							)
						)
					)
				)				
			)
		)
		--////////////////////////////////////////////////////////////////////////////				

		for i=1 to  matNodeSet[m][4].count do --PublicParams
		(
			if matNodeSet[m][4][i]._BlendFalloff_[2]  != undefined then
			(
				_BlendFalloff_name 			= matNodeSet[m][4][i]._BlendFalloff_[1]
				_BlendFalloff_ 					= matNodeSet[m][4][i]._BlendFalloff_[2]
			)
					
			if matNodeSet[m][4][i]._BlendLayer2Tiling_[2]  != undefined then
			(
				_BlendLayer2Tiling_name 	= matNodeSet[m][4][i]._BlendLayer2Tiling_[1]
				_BlendLayer2Tiling_ 			= matNodeSet[m][4][i]._BlendLayer2Tiling_[2]
			)
					
			if matNodeSet[m][4][i]._SSSIndex_[2]  != undefined then
			(
				_SSSIndex_name 			= matNodeSet[m][4][i]._SSSIndex_[1]
				_SSSIndex_ 					= matNodeSet[m][4][i]._SSSIndex_[2]
			)
					
			if matNodeSet[m][4][i]._BlendMaskTiling_[2]  != undefined then
			(
				_BlendMaskTiling_name 	= matNodeSet[m][4][i]._BlendMaskTiling_[1]
				_BlendMaskTiling_ 			= matNodeSet[m][4][i]._BlendMaskTiling_[2]
			)
					
			if matNodeSet[m][4][i]._BlendFactor_[2]  != undefined then
			(
				_BlendFactor_name 			= matNodeSet[m][4][i]._BlendFactor_[1]
				_BlendFactor_ 				= matNodeSet[m][4][i]._BlendFactor_[2]
			)
					
			if matNodeSet[m][4][i]._BlendLayer2Specular_[2]  != undefined then
			(
				_BlendLayer2Specular_name 	= matNodeSet[m][4][i]._BlendLayer2Specular_[1]
				_BlendLayer2Specular_			= matNodeSet[m][4][i]._BlendLayer2Specular_[2]
			)
					
			if matNodeSet[m][4][i]._IndirectColor_[2]  != undefined then
			(
				_IndirectColor_name 			= matNodeSet[m][4][i]._IndirectColor_[1]
				_IndirectColor_					= matNodeSet[m][4][i]._IndirectColor_[2]
			)
		)
		
		--Set Surface Types if defined
		set_surfaceType_standard \
											matIDX: 			matIDX \
											_SurfaceType_:	&_SurfaceType_ \
											theMat:				&theMat
	),
	
	fn build_Material_v3 \ --for now, standard material option is turned off
								&matNodeSet: \
								type: \
								&uniqueIDs: \
								&matIDX: \
								&matNodeCounter_MAT: \
								&MaterialRef_node_counter: \
								&theMat: \
								&inst_s_OPTIONS: \
								&iMesh: \
								&inst_tex_tokens: =
	(
		--We need to rewrite this
		
		/*
		if ::g_Build_Material_Report then
		(
			print "\n -------we are inside build_Physical_Material_v3-------\n"
		)		
		
		if ::g_MaterialRef_Bool then
		(
			local offset 	= 0
			
			mat 		= ::g_MaterialRef_MatNodesSet
			for m=1 to mat.count do --this count is the exact <Material> nodes (children to the <SubMaterials> ) in the xmlB .mtl
			(
				if ::g_Build_Material_Report then
				(	
					format "uniqueIDs: %\n" 									uniqueIDs				
					format "m: %\n" 												m			
					format "matIDX: %\n" 										matIDX				
				)
				
				if (::g_curr_MaterialRef_node_counter+offset) == uniqueIDs then --we only want to store the correct corresponding info in the xmlB .mtl, to the actual meshID
				(
					traverse_matNodeSet_standard \
																matNodeSet:								&mat \
																uniqueIDs:									&uniqueIDs \
																matIDX:										&matIDX \
																MaterialRef_node_counter: 			&MaterialRef_node_counter \
																theMat: 									&theMat	\
																inst_s_OPTIONS: 						&inst_s_OPTIONS \
																iMesh:										&iMesh \
																m:												&m
				)
			)
		)
		else
		(
			local offset 	= 0
			
			mat 		= ::g_xmlB_MatNodesSet
			for m=1 to mat.count do --this count is the exact <Material> nodes (children to the <SubMaterials> ) in the xmlB .mtl
			(
				if ::g_Build_Material_Report then
				(
					format "uniqueIDs: %\n" 									uniqueIDs				
					format "m: %\n" 												m			
					format "matIDX: %\n" 										matIDX				
				)
				
				if (m+offset) == uniqueIDs then --we only want to store the correct corresponding info in the xmlB .mtl, to the actual meshID
				(
					traverse_matNodeSet_standard \
															matNodeSet:								&mat \
															uniqueIDs:									&uniqueIDs \
															matIDX:										&matIDX \
															MaterialRef_node_counter: 			&MaterialRef_node_counter \
															theMat: 									&theMat	\
															inst_s_OPTIONS: 						&inst_s_OPTIONS \
															iMesh:										&iMesh \
															m:												&m
				)
			)
		)
		--*/
	),
	
	fn set_surfaceType_physical \ 
											matIDX: \
											&_SurfaceType_: \
											&theMat: =
	(
		--Set Surface Types if defined
		if (stricmp (_SurfaceType_ as string)  "mat_metal" ) == 0 then
		(
			if ::rollout_Report.chk_Build_Material_Report.state then
			(
				format "####### _SurfaceType_: % #######\n" _SurfaceType_
			)

			theMat.materialList[matIDX].base_color 								= color 236.13 178.755 133.62 255
			theMat.materialList[matIDX].sss_scatter_color 						= color 255 127.5 63.75 255
			theMat.materialList[matIDX].metalness 								= 1
										
			theMat.materialList[matIDX].coat_affect_color 						= 0
			theMat.materialList[matIDX].coat_ior 									= 1.5
			theMat.materialList[matIDX].coat_roughness 						= 0.0
			theMat.materialList[matIDX].coat_affect_roughness 				= 0.0
			theMat.materialList[matIDX].sss_depth 								= 10

			
			theMat.materialList[matIDX].roughness_map 						= Noise ()
				theMat.materialList[matIDX].roughness_map.type 				= 2
				theMat.materialList[matIDX].roughness_map.thresholdHigh 	= 0.62
				theMat.materialList[matIDX].roughness_map.size 				= 63.5
				theMat.materialList[matIDX].roughness_map.color1 			= color 113 113 113
				theMat.materialList[matIDX].roughness_map.color2 			= color 44 44 44
										
			theMat.materialList[matIDX].roughness 								= 0.12
			theMat.materialList[matIDX].trans_ior 									= 1.52			
			
			theMat.materialList[matIDX].aniso_mode 								= 0
			theMat.materialList[matIDX].anisotropy 								= 1
			theMat.materialList[matIDX].anisoangle 								= 0
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_marble" ) == 0 then
		(
			if ::rollout_Report.chk_Build_Material_Report.state then
			(
				format "####### _SurfaceType_: % #######\n" _SurfaceType_
			)
			
			theMat.materialList[matIDX].base_color 								=  color 127.5 127.5 127.5 255
			theMat.materialList[matIDX].diff_roughness 							= 1
			theMat.materialList[matIDX].metalness 								= 0
			
			theMat.materialList[matIDX].coat_ior 									= 1.5
			theMat.materialList[matIDX].coat_roughness 						= 0.0
			theMat.materialList[matIDX].coat_affect_color 						= 0.5
			theMat.materialList[matIDX].coat_affect_roughness 				= 0.5
			
			theMat.materialList[matIDX].roughness  								= 0.36
			theMat.materialList[matIDX].reflectivity 								= 0.5
			theMat.materialList[matIDX].trans_ior 									= 1.4
			theMat.materialList[matIDX].trans_roughness 						= 1
			theMat.materialList[matIDX].sss_depth 								= 10
			
			theMat.materialList[matIDX].brdf_mode 								= on
			theMat.materialList[matIDX].brdf_low 									= 0.2
			theMat.materialList[matIDX].brdf_high 								= 1
			theMat.materialList[matIDX].brdf_curve 								= 5
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_concrete" ) == 0 then
		(
			if ::rollout_Report.chk_Build_Material_Report.state then
			(
				format "####### _SurfaceType_: % #######\n" _SurfaceType_
			)
			
			theMat.materialList[matIDX].base_color 								=  color 127.5 127.5 127.5 255
			theMat.materialList[matIDX].diff_roughness 							= 1
			theMat.materialList[matIDX].metalness 								= 0
			
			theMat.materialList[matIDX].coat_ior 									= 1.5
			theMat.materialList[matIDX].coat_roughness 						= 0.0
			theMat.materialList[matIDX].coat_affect_color 						= 0.5
			theMat.materialList[matIDX].coat_affect_roughness 				= 0.5
			
			theMat.materialList[matIDX].trans_roughness_lock 				= off
			theMat.materialList[matIDX].trans_roughness 						= 1
			
			theMat.materialList[matIDX].roughness  								= 0.456
			theMat.materialList[matIDX].reflectivity 								= 0.5
			theMat.materialList[matIDX].trans_ior 									= 1.4
			
			theMat.materialList[matIDX].brdf_mode 								= off
			theMat.materialList[matIDX].brdf_low 									= 0.2
			theMat.materialList[matIDX].brdf_high 								= 1
			theMat.materialList[matIDX].brdf_curve 								= 5
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_wood_solid" ) == 0 then
		(
			if ::rollout_Report.chk_Build_Material_Report.state then
			(
				format "####### _SurfaceType_: % #######\n" _SurfaceType_
			)
			
			theMat.materialList[matIDX].base_color 								=  color 163 146 108 255
			theMat.materialList[matIDX].diff_roughness 							= 1
			theMat.materialList[matIDX].metalness 								= 0
			
			theMat.materialList[matIDX].coat_ior 									= 1.5
			theMat.materialList[matIDX].coat_roughness 						= 0.0
			theMat.materialList[matIDX].coat_affect_color 						= 0.5
			theMat.materialList[matIDX].coat_affect_roughness 				= 0.5
			
			theMat.materialList[matIDX].trans_roughness_lock 				= off
			theMat.materialList[matIDX].trans_roughness 						= 1	
			
			theMat.materialList[matIDX].roughness  								= 0.646
			theMat.materialList[matIDX].reflectivity 								= 0.5
			theMat.materialList[matIDX].trans_ior 									= 1.4			
			
			theMat.materialList[matIDX].brdf_mode 								= on
			theMat.materialList[matIDX].brdf_low 									= 0.2
			theMat.materialList[matIDX].brdf_high 								= 1
			theMat.materialList[matIDX].brdf_curve 								= 5
		)	
		else if (stricmp (_SurfaceType_ as string)  "mat_flesh" ) == 0 then
		(
			if ::rollout_Report.chk_Build_Material_Report.state then
			(
				format "####### _SurfaceType_: % #######\n" _SurfaceType_
			)
			
			if 	::rollout_options.chk_PhysMat_SSS.state AND \
				::rollout_options.chk_Physical_Material.state then
			(			
				theMat.materialList[matIDX].base_weight 							= 0.7
				theMat.materialList[matIDX].metalness 								= 0
				theMat.materialList[matIDX].roughness  								= 0.33
				theMat.materialList[matIDX].trans_ior 									= 1.33
				theMat.materialList[matIDX].scattering 								= 0.69
				theMat.materialList[matIDX].sss_scale 								= 1	
				theMat.materialList[matIDX].sss_scatter_color 						= color 255 127.5 63.75 255
				theMat.materialList[matIDX].sss_color 								= color 243 220 126 255
				theMat.materialList[matIDX].sss_depth 								= 10
				
				
				theMat.materialList[matIDX].base_color 								=  color 163 146 108 255
				theMat.materialList[matIDX].diff_roughness 							= 1
				
				theMat.materialList[matIDX].coating 									= 0
				theMat.materialList[matIDX].coat_ior 									= 1.5
				theMat.materialList[matIDX].coat_roughness 						= 0.0
				
				theMat.materialList[matIDX].coat_affect_color 						= 0.0
				theMat.materialList[matIDX].coat_affect_roughness 				= 0.0
				
				theMat.materialList[matIDX].trans_roughness_lock 				= on					
				
				theMat.materialList[matIDX].reflectivity 								= 0.5					
				
				theMat.materialList[matIDX].brdf_mode 								= on
				theMat.materialList[matIDX].brdf_low 									= 0.05
				theMat.materialList[matIDX].brdf_high 								= 1
				theMat.materialList[matIDX].brdf_curve 								= 5
				
				theMat.materialList[matIDX].aniso_mode 								= 0
				theMat.materialList[matIDX].anisotropy 								= 1
				theMat.materialList[matIDX].anisoangle 								= 0
			)
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_flesh_human" ) == 0 then
		(
			if ::rollout_Report.chk_Build_Material_Report.state then
			(
				format "####### _SurfaceType_: % #######\n" _SurfaceType_
			)
			
			if 	::rollout_options.chk_PhysMat_SSS.state AND \
				::rollout_options.chk_Physical_Material.state then
			(			
				theMat.materialList[matIDX].base_weight 							= 0.7
				theMat.materialList[matIDX].metalness 								= 0
				theMat.materialList[matIDX].roughness  								= 0.33
				theMat.materialList[matIDX].trans_ior 									= 1.33
				theMat.materialList[matIDX].scattering 								= 0.69
				theMat.materialList[matIDX].sss_scale 								= 1	
				theMat.materialList[matIDX].sss_scatter_color 						= color 255 127.5 63.75 255
				theMat.materialList[matIDX].sss_color 								= color 243 220 126 255
				theMat.materialList[matIDX].sss_depth 								= 10
				
				
				theMat.materialList[matIDX].base_color 								=  color 163 146 108 255
				theMat.materialList[matIDX].diff_roughness 							= 1
				
				theMat.materialList[matIDX].coating 									= 0
				theMat.materialList[matIDX].coat_ior 									= 1.5
				theMat.materialList[matIDX].coat_roughness 						= 0.0
				
				theMat.materialList[matIDX].coat_affect_color 						= 0.0
				theMat.materialList[matIDX].coat_affect_roughness 				= 0.0
				
				theMat.materialList[matIDX].trans_roughness_lock 				= on					
				
				theMat.materialList[matIDX].reflectivity 								= 0.5					
				
				theMat.materialList[matIDX].brdf_mode 								= on
				theMat.materialList[matIDX].brdf_low 									= 0.05
				theMat.materialList[matIDX].brdf_high 								= 1
				theMat.materialList[matIDX].brdf_curve 								= 5
				
				theMat.materialList[matIDX].aniso_mode 								= 0
				theMat.materialList[matIDX].anisotropy 								= 1
				theMat.materialList[matIDX].anisoangle 								= 0
			)
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_wood_thin" ) == 0 then
		(
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_fabric" ) == 0 then
		(
			if theMat.materialList[matIDX].roughness_map != undefined then
			(
				theMat.materialList[matIDX].roughness_map.output.output_amount 	= -25
			)			
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_wood_breakable" ) == 0 then
		(
		)	
		else if (stricmp (_SurfaceType_ as string)  "mat_rock_dusty" ) == 0 then
		(
		)
		else if (stricmp (_SurfaceType_ as string)  "mat_feathers" ) == 0 then
		(
		)		
	),	
	
	fn traverse_matNodeSet_physical \
													&matNodeSet: \
													&uniqueIDs: \
													&matIDX: \
													&MaterialRef_node_counter: \
													&theMat: \
													&inst_s_OPTIONS: \
													&iMesh: \
													&m: \
													&inst_tex_tokens: =
	(
		-------------- Material Attribs var declaration --------------
		local _Name_name 				= ""
		local _Name_						= ""
		
			local _NameRef_name 			= ""
			local _NameRef_					= ""
				local caller							= false
				local MaterialRef_Bool 			= false
					
		local _Shader_name				= ""
		local _Shader_ 					= ""					
		
		local _MtlFlags_name			= ""
		local _MtlFlags_					= ""
		local _MtlFlags_arr 				= #()
					
		local _GenMask_name 			= ""
		local _GenMask_ 				= ""
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
		
		for i=1 to  matNodeSet[m][2].count do
		(			
			MaterialRef_Bool 								= matNodeSet[m][2][i].MaterialRef_Bool 
			
			if matNodeSet[m][2][i]._Name_[2]  != undefined then
			(
				_Name_name 					= matNodeSet[m][2][i]._Name_[1]
				_Name_ 							= matNodeSet[m][2][i]._Name_[2]						
			)
					
			if matNodeSet[m][2][i]._Shader_[2]  != undefined then
			(
				_Shader_name 				= matNodeSet[m][2][i]._Shader_[1]
				_Shader_ 						= matNodeSet[m][2][i]._Shader_[2]						
			)
					
			if matNodeSet[m][2][i]._MtlFlags_[2]  != undefined then
			(
				_MtlFlags_name 				= matNodeSet[m][2][i]._MtlFlags_[1]
				_MtlFlags_ 						= matNodeSet[m][2][i]._MtlFlags_[2]
				_MtlFlags_arr					= matNodeSet[m][2][i]._MtlFlags_arr
						
				if ::g_Build_Material_Report then
				(
					format "\n_MtlFlags_arr:\n"
					print _MtlFlags_arr
				)						
			)
					
			if matNodeSet[m][2][i]._GenMask_[2]  != undefined then
			(
				_GenMask_name 				= matNodeSet[m][2][i]._GenMask_[1]
				_GenMask_ 					= matNodeSet[m][2][i]._GenMask_[2]
				_GenMask_arr					= matNodeSet[m][2][i]._GenMask_arr
						
				if ::g_Build_Material_Report then
				(
					format "\n_GenMask_arr:\n"
					print _GenMask_arr
				)
			)
					
			if matNodeSet[m][2][i]._StringGenMask_[2]  != undefined then
			(
				_StringGenMask_name 		= matNodeSet[m][2][i]._StringGenMask_[1]
				_StringGenMask_ 			= matNodeSet[m][2][i]._StringGenMask_[2]
						
				if ::g_Build_Material_Report then
				(
					format "\n_StringGenMask_:\n"
					print _StringGenMask_
				)
			)

			if matNodeSet[m][2][i]._SurfaceType_[2]  != undefined then
			(
				_SurfaceType_name 		= matNodeSet[m][2][i]._SurfaceType_[1]
				_SurfaceType_ 				= matNodeSet[m][2][i]._SurfaceType_[2]
			)
					
			if matNodeSet[m][2][i]._MatTemplate_[2]  != undefined then
			(
				_MatTemplate_name 		= matNodeSet[m][2][i]._MatTemplate_[1]
				_MatTemplate_ 				= matNodeSet[m][2][i]._MatTemplate_[2]
			)
					
			if matNodeSet[m][2][i]._Diffuse_[2]  != undefined then
			(
				_Diffuse_name 				= matNodeSet[m][2][i]._Diffuse_[1]
				_Diffuse_ 						= matNodeSet[m][2][i]._Diffuse_[2]
			)
					
			if matNodeSet[m][2][i]._Specular_[2]  != undefined then
			(
				_Specular_name 				= matNodeSet[m][2][i]._Specular_[1]
				_Specular_ 					= matNodeSet[m][2][i]._Specular_[2]
			)
					
			if matNodeSet[m][2][i]._Emissive_[2]  != undefined then
			(
				_Emissive_name 				= matNodeSet[m][2][i]._Emissive_[1]
				_Emissive_ 						= matNodeSet[m][2][i]._Emissive_[2]
			)
					
			if matNodeSet[m][2][i]._Shininess_[2]  != undefined then
			(
				_Shininess_name 				= matNodeSet[m][2][i]._Shininess_[1]
				_Shininess_ 					= matNodeSet[m][2][i]._Shininess_[2]
			)
					
			if matNodeSet[m][2][i]._Opacity_[2]  != undefined then
			(
				_Opacity_name 				= matNodeSet[m][2][i]._Opacity_[1]
				_Opacity_ 						= matNodeSet[m][2][i]._Opacity_[2]
			)
					
			if matNodeSet[m][2][i]._LayerAct_[2]  != undefined then
			(
				_LayerAct_name 				= matNodeSet[m][2][i]._LayerAct_[1]
				_LayerAct_ 					= matNodeSet[m][2][i]._LayerAct_[2]
			)					

					
			--//////////////////////////////////////////////////////////////////////////
			--Now that we have all the attribs stored for the current matIDX (current meshID), we can finalise the material construction
			if _Name_ != undefined then --Material
			(
				if (stricmp (_Name_ as string) "Proxy") != 0 then
				(						
					if (stricmp (_Shader_ as string) "Nodraw") != 0 then
					(
						if (stricmp (_Shader_ as string) "Illum") == 0 then
						(
							--/////////////////////////////// Name the material id lists ///////////////////////////////
							theMat.names[matIDX] = _Name_
									
							--Also name the physical proxy --Material ID 1 should always be the Proxy Material - But that is not always the case, some artists sometimes put it in the last id
							-- See http://docs.cryengine.com/display/SDKDOC2/Basic+Asset+Setup+and+Export+out+of+Max									
							--theMat.names[1] = "Proxy"
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set diffuse color ////////////////////////////////////
							mult = 255
							if (stricmp (_Diffuse_name as string) "Diffuse") == 0 then
							(
								local Diffuse_arr = filterstring _Diffuse_ ","				

								--convert the array string values to Float
								if Diffuse_arr.count == 3 then
								(
									for s=1 to Diffuse_arr.count do
									(
										Diffuse_arr[s] = Diffuse_arr[s] as Float --this must be Float
									)
									theMat.materialList[matIDX].base_color = color (Diffuse_arr[1]*mult) (Diffuse_arr[2]*mult) (Diffuse_arr[3]*mult)
								)
							)
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set glossiness ////////////////////////////////////
							mult = 255
							local glossiness_arr = filterstring _Specular_ ","
							if glossiness_arr.count == 3 then
							(
								--convert the array string values to Float
								for s=1 to glossiness_arr.count do
								(																	
									glossiness_arr[s] = glossiness_arr[s] as Float --this must be Float						
								)
								theMat.materialList[matIDX].roughness = ((glossiness_arr[1]*mult)+(glossiness_arr[2]*mult)+(glossiness_arr[3]*mult))/3
							)
							--------------------------------------------------------------------------------------------------------

							--////////////////////////////////// Set Emissive ////////////////////////////////////
							mult = 255	
							if _Emissive_ != "" then
							(
								local Emissive_arr = filterstring _Emissive_ ","
																															
								--convert the array string values to Float
								if Emissive_arr.count == 3 then
								(										
									for s=1 to Emissive_arr.count do
									(																
										Emissive_arr[s] = Emissive_arr[s] as Float --this must be Float					
									)
																				
									if Emissive_arr[1] > 0 AND Emissive_arr[2] > 0 AND Emissive_arr[3] > 0 then
									(												
										theMat.materialList[matIDX].emission 		= ((Emissive_arr[1]*mult)+ (Emissive_arr[2]*mult)+ (Emissive_arr[3]*mult))/3
									)
								)
							)
							--------------------------------------------------------------------------------------------------------
						)
						if (stricmp (_Shader_ as string) "metal") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "HumanSkin") == 0 then
						(
							--/////////////////////////////// Name the material id lists ///////////////////////////////
							theMat.names[matIDX] = _Name_
									
							--Also name the physical proxy --Material ID 1 should always be the Proxy Material.
							-- See http://docs.cryengine.com/display/SDKDOC2/Basic+Asset+Setup+and+Export+out+of+Max									
							--theMat.names[1] = "Proxy"
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set diffuse color ////////////////////////////////////
							mult = 255
							if (stricmp (_Diffuse_name as string) "Diffuse") == 0 then
							(
								local Diffuse_arr = filterstring _Diffuse_ ","				

								--convert the array string values to Float
								if Diffuse_arr.count == 3 then
								(
									for s=1 to Diffuse_arr.count do
									(
										Diffuse_arr[s] = Diffuse_arr[s] as Float --this must be Float
									)
									theMat.materialList[matIDX].base_color = color (Diffuse_arr[1]*mult) (Diffuse_arr[2]*mult) (Diffuse_arr[3]*mult)
								)
							)
							--------------------------------------------------------------------------------------------------------
									
							--////////////////////////////////// Set glossiness ////////////////////////////////////
							mult = 255
							local glossiness_arr = filterstring _Specular_ ","
							if glossiness_arr.count == 3 then
							(
								--convert the array string values to Float
								for s=1 to glossiness_arr.count do
								(																	
									glossiness_arr[s] = glossiness_arr[s] as Float --this must be Float						
								)
								theMat.materialList[matIDX].roughness = ((glossiness_arr[1]*mult)+(glossiness_arr[2]*mult)+(glossiness_arr[3]*mult))/3
							)
							--------------------------------------------------------------------------------------------------------

							--////////////////////////////////// Set Emissive ////////////////////////////////////
							mult = 255	
							if _Emissive_ != "" then
							(
								local Emissive_arr = filterstring _Emissive_ ","
																															
								--convert the array string values to Float
								if Emissive_arr.count == 3 then
								(										
									for s=1 to Emissive_arr.count do
									(																
										Emissive_arr[s] = Emissive_arr[s] as Float --this must be Float					
									)
																				
									if Emissive_arr[1] > 0 AND Emissive_arr[2] > 0 AND Emissive_arr[3] > 0 then
									(												
										theMat.materialList[matIDX].emission 		= ((Emissive_arr[1]*mult)+ (Emissive_arr[2]*mult)+ (Emissive_arr[3]*mult))/3
									)
								)
							)
							--------------------------------------------------------------------------------------------------------
						)
						if (stricmp (_Shader_ as string) "Hair") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Glass") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "GeometryBeam") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Eye") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "DistanceClouds") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Common.Cloud") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "LightBeam.LightBeam") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Particles") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "ReferenceImage") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "TemplBeamProc") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Terrain.Layer") == 0 then
						(
							--see: ShaderParse.cpp 509
							-- 	uint64 CShaderMan::mfGetRemapedShaderMaskGen( const char* szName, uint64 nMaskGen, bool bFixup )
							-- {
							-- 	if (!nMaskGen)
							-- 		return 0;
									
							-- 	uint64 nMaskGenRemaped = 0;
							-- 	string szShaderName    = PathUtil::GetFileName(szName);// some shaders might be using concatenated names (eg: terrain.layer), get only first name
							-- 	szShaderName.MakeUpper();
							-- 	ShaderMapNameFlagsItor pShaderRmp = m_pShadersGlobalFlags.find( szShaderName.c_str());
						)
						if (stricmp (_Shader_ as string) "Vegetation") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "VolumeObject") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Waterfall") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Water") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Watervolume") == 0 then
						(
						)
						if (stricmp (_Shader_ as string) "Nodraw") == 0 then
						(
						)
					)
					else
					(
						theMat.names[matIDX] = _Name_
					)
				)
				else
				(
					theMat.names[matIDX] = _Name_
				)
			)
			--//////////////////////////////////////////////////////////////////////////						
		)
				
		for i=1 to  matNodeSet[m][3].count do --Textures
		(					
			if matNodeSet[m][3][i]._Map_[2]  != undefined then
			(					
				_Map_name 					= matNodeSet[m][3][i]._Map_[1]
				_Map_ 							= matNodeSet[m][3][i]._Map_[2]
			)					
			else if matNodeSet[m][3][i]._File_[2]  != undefined then
			(
				_File_name 					= matNodeSet[m][3][i]._File_[1]
				_File_ 							= matNodeSet[m][3][i]._File_[2]
			)
					
			if matNodeSet[m][3][i]._TexType_[2]  != undefined then
			(
				_TexType_name 				= matNodeSet[m][3][i]._TexType_[1]
				_TexType_ 					= matNodeSet[m][3][i]._TexType_[2]
			)
					
			if matNodeSet[m][3][i]._IsTileU_[2]  != undefined then
			(
				_IsTileU_name 				= matNodeSet[m][3][i]._IsTileU_[1]
				_IsTileU_ 						= matNodeSet[m][3][i]._IsTileU_[2]
			)
					
			if matNodeSet[m][3][i]._IsTileV_[2]  != undefined then
			(
				_IsTileV_name 				= matNodeSet[m][3][i]._IsTileV_[1]
				_IsTileV_ 						= matNodeSet[m][3][i]._IsTileV_[2]
			)					
					
			--//////////////////////////////////////////////////////////////////////////
			--///////////////////////// Texture Node Attribs --////////////////////////
			if _File_ != undefined then
			(				
				if pathConfig.isLegalPath _File_ then
				(	
					if _Map_ != undefined then
					(								
						texFile = fix_tex_path \
														_File_:				&_File_ \
														inst_s_OPTIONS:	&inst_s_OPTIONS
									
						--------------------------------------------------------------------------------------------------------------------
						if ::rollout_Report.chk_MaterialRef_Report.state then
						(
							format "*** ### ***    texFile: %    *** ### ***\n" texFile	
						)
						if 	::rollout_Report.chk_Build_Material_Report.state OR \
							::rollout_Report.chk_xmlB_Report_v2.state then
						(
							format "*** ### ***   texFile: %    *** ### ***\n" 	texFile															
						)
							
						--Change path to *.dds (should be .tif, but we do not have the tif files)
						fix_MaterialRef_refsPath \
														texFile:&texFile \
														suffix:inst_s_OPTIONS.chk_dds_string
									
						if ::rollout_Report.chk_MaterialRef_Report.state then
						(
							format "File Path changed with function fix_MaterialRef_refsPath*** ### ***   texFile: %    *** ### ***\n" 	texFile
							format "*** ### ***   matNodeSet[m][3][i].g_curr_MaterialRef_node_counter	: %    *** ### ***\n" 			matNodeSet[m][3][i].g_curr_MaterialRef_node_counter
							format "*** ### ***   MaterialRef_node_counter	: %    *** ### ***\n"														MaterialRef_node_counter
						)
							
						if 	::rollout_Report.chk_Build_Material_Report.state OR \
							::rollout_Report.chk_xmlB_Report_v2.state then
						(
							format "File Path changed *** ### ***   texFile: %    *** ### ***\n" 	texFile							
						)
						--------------------------------------------------------------------------------------------------------------------

						if texFile != undefined then
						(
							if doesfileexist texFile then
							(
								build_Physical_Texture \
																theMat:										&theMat \																	
																texFile:										&texFile \
																_Map_:										_Map_ \													
																_StringGenMask_:						&_StringGenMask_ \
																matIDX:										&matIDX \
																_Opacity_:									_Opacity_ \
																_Name_:									_Name_ \
																inst_tex_tokens:							&inst_tex_tokens
							)
						)
					)
				)
			)
		)
		--For texRef
		if 	matNodeSet[m][3].count == 0 then
		(
			caller = true
		)
		--////////////////////////////////////////////////////////////////////////////				

		for i=1 to  matNodeSet[m][4].count do --PublicParams
		(
			if matNodeSet[m][4][i]._BlendFalloff_[2]  != undefined then
			(
				_BlendFalloff_name 			= matNodeSet[m][4][i]._BlendFalloff_[1]
				_BlendFalloff_ 					= matNodeSet[m][4][i]._BlendFalloff_[2]
			)
					
			if matNodeSet[m][4][i]._BlendLayer2Tiling_[2]  != undefined then
			(
				_BlendLayer2Tiling_name 	= matNodeSet[m][4][i]._BlendLayer2Tiling_[1]
				_BlendLayer2Tiling_ 			= matNodeSet[m][4][i]._BlendLayer2Tiling_[2]
			)
					
			if matNodeSet[m][4][i]._SSSIndex_[2]  != undefined then
			(
				_SSSIndex_name 			= matNodeSet[m][4][i]._SSSIndex_[1]
				_SSSIndex_ 					= matNodeSet[m][4][i]._SSSIndex_[2]
			)
					
			if matNodeSet[m][4][i]._BlendMaskTiling_[2]  != undefined then
			(
				_BlendMaskTiling_name 	= matNodeSet[m][4][i]._BlendMaskTiling_[1]
				_BlendMaskTiling_ 			= matNodeSet[m][4][i]._BlendMaskTiling_[2]
			)
					
			if matNodeSet[m][4][i]._BlendFactor_[2]  != undefined then
			(
				_BlendFactor_name 			= matNodeSet[m][4][i]._BlendFactor_[1]
				_BlendFactor_ 				= matNodeSet[m][4][i]._BlendFactor_[2]
			)
					
			if matNodeSet[m][4][i]._BlendLayer2Specular_[2]  != undefined then
			(
				_BlendLayer2Specular_name 	= matNodeSet[m][4][i]._BlendLayer2Specular_[1]
				_BlendLayer2Specular_			= matNodeSet[m][4][i]._BlendLayer2Specular_[2]
			)
					
			if matNodeSet[m][4][i]._IndirectColor_[2]  != undefined then
			(
				_IndirectColor_name 			= matNodeSet[m][4][i]._IndirectColor_[1]
				_IndirectColor_					= matNodeSet[m][4][i]._IndirectColor_[2]
			)
		)
		
		if ::rollout_Options.chk_PhysicalMaterialTypes.state then
		(
			--Set Surface Types if defined --like copper, metal, stone, marble etc parameters
			set_surfaceType_physical \
												matIDX: 			matIDX \
												_SurfaceType_:	&_SurfaceType_ \
												theMat:				&theMat
		)			

		--/*
		if (NOT MaterialRef_Bool) AND \
			caller then
		(			
			--If the asset is an LOD, then we will override the chk_deepSearch and do a deep search
			local first_Loaded 			= getINISetting 		::g_iniFile 			"paths" 		"first_loaded"
			local last_Loaded 			= getINISetting 		::g_iniFile 			"paths" 		"last_loaded"			
			local LOD_1 					= matchpattern 		first_Loaded 		pattern:"*LOD*"
			local LOD_2 					= matchpattern 		last_Loaded 		pattern:"*LOD*"
			
			if 	::rollout_options.chk_deepSearch.state OR \
				(LOD_1 AND LOD_2) then
			(
				local foundMTL = false			
				quick_mtl_by_NodeName \
												matID: 			&uniqueIDs \
												foundMTL: 		&foundMTL \
												_Name_: 		&_Name_
				
				if NOT foundMTL then
				(
					if _File_ == "" then
					(	
						if _Name_ != undefined then
						(
							if 	(stricmp 	(_Shader_ as string) 	"Nodraw"			) 		!= 0 		AND \				
								(stricmp 	(_Name_ as string) 		"proxy"				) 		!= 0 		AND \
								(stricmp 	(_Name_ as string) 		"phys"				) 		!= 0 		AND \
								(stricmp 	(_Name_ as string) 		""						) 		!= 0 		AND \
								(stricmp 	(_Name_ as string) 		"shadow_proxy"	) 		!= 0 		AND \
								(stricmp 	(_Name_ as string) 		"lod"					) 		!= 0 		then
							(
								local filePath = ""						
								mtl_emptyTexSlot_v2 \
																filePath:					&filePath \
																matNodeCounter: 	&m \
																mtl_Line:				&_Name_ \
																inst_s_OPTIONS: 	&inst_s_OPTIONS
								
								if doesfileexist filePath then
								(
									Append ::g_MTLRef_array #(m, filePath)					
								)				
								else --We found no matching .mtl, so we try to find the textures that the name references directly
								(					
									NOmtl_emptyTexSlot_v2 \
																	matNodeCounter: 	&m \ 
																	mtl_Line:				&_Name_ \
																	inst_s_OPTIONS: 	&inst_s_OPTIONS					
										
									for i=1 to ::g_TEXRef_array.count do
									(						
										local texFile = ::g_TEXRef_array[i][2]
										
										if ::rollout_options.chk_deepSearch.state then
										(
											format "**##** deepSearch ##**## texFile: % ##**##**##**\n" 		texFile
										)
										
										--We will test all the grabbed textures in ::g_TEXRef_array for these map types
										local Map_Test_arr = #(
																			"Diffuse",
																			"Specular",
																			"Normalmap",
																			"Bumpmap",
																			"Opacity",
																			"Heightmap",
																			"Detail"
																		)
												
										for m=1 to Map_Test_arr.count do
										(
											build_Physical_Texture \
																			theMat:										&theMat \																	
																			texFile:										&texFile \
																			_Map_:										Map_Test_arr[m] \													
																			_StringGenMask_:						&_StringGenMask_ \
																			matIDX:										&matIDX \
																			_Opacity_:									_Opacity_ \
																			_Name_:									_Name_ \
																			inst_tex_tokens:							&inst_tex_tokens
										)								
									)							
								)
							)
						)
					)
				)
			)
		)
		--*/	
	),
	
	fn build_Physical_Material_v3 \
											&matNodeSet: \
											type: \
											&matNodeCounter: \
											&matNodeCounter_MAT: \
											&matNodeCounter_REF: \
											&MaterialRef_node_counter: \
											&uniqueIDs: \
											&matIDX: \											
											&theMat: \
											&inst_s_OPTIONS: \
											&iMesh: \
											&inst_tex_tokens: =
	(		
		for m=1 to matNodeSet.count do --this count is the exact <Material> nodes (children to the <SubMaterials> ) in the xmlB .mtl
		(
			if matNodeCounter == uniqueIDs then --we only want to store the correct corresponding info in the xmlB .mtl, to the actual meshID
			(
				traverse_matNodeSet_physical \
															matNodeSet:								&matNodeSet \															
															uniqueIDs:									&uniqueIDs \
															matIDX:										&matIDX \
															MaterialRef_node_counter: 			&MaterialRef_node_counter \
															theMat: 									&theMat	\
															inst_s_OPTIONS: 						&inst_s_OPTIONS \
															iMesh:										&iMesh \
															m:												&m \
															inst_tex_tokens:							&inst_tex_tokens				
			)
		)
	),	
	
	fn set_Physical_vars \
									&theMat: =
	(
		if ::g_Physical_Material then
		(
			ourRenderer 							= ART_Renderer()
			renderers.current						= ourRenderer		
			renderers.production					= ourRenderer			
			renderers.activeShade				= ourRenderer
			renderers.medit_locked				= false --We leave the medit renderer to Scanline, because it is much faster
			ourRenderer.enable_noise_filter  	= true
					
			for p=1 to theMat.materialList.count do
			(
				theMat.materialList[p] 							= PhysicalMaterial ()
				theMat.materialList[p].material_mode		= 1 --sets Advanced mode (default is 0)
			)
		)
	),
	--////////////////////////////////////// END OF TEXTURE BUILDERS //////////////////////////////////////
	
	fn material_Builder  \
								&_LOADED: \
								&_LOADEDm: \
								&matNodeSet: \
								type:	\
								&matNodeCounter: \
								&matNodeCounter_MAT: \
								&matNodeCounter_REF: \
								&uniqueIDs: \ 								--the real actual id
								&matIDX: \								 	--the id of the sub material index list
								&MaterialRef_node_counter: \
								&theMat: \
								&compositeMat: \
								&iMesh: \								
								&MTL_NAME_CHUNK_DESC: \
								&inst_s_OPTIONS: \
								&inst_tex_tokens: =
	(
		for matIDX=1 to theMat.materialIDList.count do --we loop each id in our multimaterial
		(
			---------- Finally construct the material, either Standard or Physical ----------
			if NOT ::g_Physical_Material then
			(
				build_Material_v3 \										
										matNodeSet:								&matNodeSet \
										type:											type \
										matNodeCounter:							&matNodeCounter \
										matNodeCounter_MAT:					&matNodeCounter_MAT \
										matNodeCounter_REF:					&matNodeCounter_REF \
										uniqueIDs:									&theMat.materialIDList[matIDX] \ 	--<-------- the real actual id
										matIDX:										&matIDX \								 	--the id of the sub material index list
										MaterialRef_node_counter:			&MaterialRef_node_counter \
										theMat:										&theMat \
										compositeMat:							&compositeMat \
										inst_s_OPTIONS:							&inst_s_OPTIONS \
										iMesh:										&iMesh \
										inst_tex_tokens:							&inst_tex_tokens
			)
			else
			(
				build_Physical_Material_v3 \													
													matNodeSet:								&matNodeSet \
													type:											type \
													matNodeCounter:							&matNodeCounter \
													matNodeCounter_MAT:					&matNodeCounter_MAT \
													matNodeCounter_REF:					&matNodeCounter_REF \
													uniqueIDs:									&theMat.materialIDList[matIDX] \ 	--<-------- the real actual id
													matIDX:										&matIDX \								 	--the id of the sub material index list
													MaterialRef_node_counter:			&MaterialRef_node_counter \
													theMat:										&theMat \
													compositeMat:							&compositeMat \
													inst_s_OPTIONS:							&inst_s_OPTIONS \
													iMesh:										&iMesh \
													inst_tex_tokens:							&inst_tex_tokens
			)
		)
	),	
	
	fn extract_from_Material \		
										&_LOADED: \
										&_LOADEDm: \		
										&matNodeSet: \
										&parsed: \
										&uniqueIDs: \ 								--the real actual id
										&matIDX: \								 	--the id of the sub material index list
										&MaterialRef_node_counter: \
										&theMat: \
										&compositeMat: \
										&inst_s_OPTIONS: \
										&iMesh: \
										&MTL_NAME_CHUNK_DESC: \
										&inst_Sub_Meshes: \
										&inst_tex_tokens: =
	(
		local mat = deepCopy matNodeSet
		
		for m=1 to mat.count do
		(
			for i=1 to  mat[m][2].count do --Textures
			(
				local matNodeCounter_MAT							= mat[m][2][i].matNodeCounter_MAT --freeze the counter for a regular material
				local matNodeCounter									= mat[m][2][i].matNodeCounter
				local nTagString											= mat[m][2][i].nTagString
				local _Name_name 										= mat[m][2][i]._Name_[1]
				local _Name_												= mat[m][2][i]._Name_[2]				
				
				if (stricmp nTagString "Material") == 0 then
				(
					matNodeSet_proxy = #()
					
					Append matNodeSet_proxy mat[m]

					if ::rollout_Report.chk_MaterialRef_Report.state then
					(
						format "\n***************** matNodeCounter: % *****************\n" 			matNodeCounter
						format "\n***************** matNodeCounter_MAT: % *****************\n" 	matNodeCounter_MAT
						format "\n***************** matNodeCounter_REF: % *****************\n" 		matNodeCounter_REF
						for x in matNodeSet do print x				
					)
					
					material_Builder \
											_LOADED: 									&_LOADED \
											_LOADEDm: 								&_LOADEDm \
											matNodeSet:								&matNodeSet_proxy \
											matNodeCounter_MAT:					&matNodeCounter_MAT \
											matNodeCounter:							&matNodeCounter \																							
											uniqueIDs:									&theMat.materialIDList[matIDX] \ 	--the real actual id
											matIDX:										&matIDX \								 	--the id of the sub material index list
											theMat:										&theMat \
											compositeMat:							&compositeMat \
											inst_s_OPTIONS:							&inst_s_OPTIONS \
											iMesh:										&iMesh \
											MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
											inst_tex_tokens:							&inst_tex_tokens
					
				)
			)
		)
	),
	
	fn extract_from_MaterialRef \			
											&_LOADED: \
											&_LOADEDm: \
											&matNodeSet: \
											&parsed: \
											&uniqueIDs: \ 								--the real actual id
											&matIDX: \								 	--the id of the sub material index list
											&MaterialRef_node_counter: \
											&theMat: \
											&compositeMat: \
											&inst_s_OPTIONS: \
											&iMesh: \
											&MTL_NAME_CHUNK_DESC: \
											&inst_Sub_Meshes: \
											&inst_tex_tokens: =
	(		
		local mat = deepCopy matNodeSet
		
		for m=1 to mat.count do
		(
			for i=1 to  mat[m][2].count do --Textures
			(
				if ::rollout_Report.chk_MaterialRef_Report.state then
				(
					print "--------------------------------------------------------------\n"
					format "mat[m][5][i]._NameRef_[2]	: %\n" mat[m][5][i]._NameRef_[2]	
				)

				local matNodeCounter									= mat[m][2][i].matNodeCounter
				local matNodeCounter_MAT							= mat[m][2][i].matNodeCounter_MAT --freeze the counter for a regular material
				local matNodeCounter_REF							= mat[m][2][i].MaterialRef_node_counter --freeze the counter for a REF
				
				local nTagString											= mat[m][2][i].nTagString
				local _NameRef_name 									= mat[m][2][i]._Name_[1]
				local _NameRef_											= mat[m][2][i]._Name_[2]

				if (stricmp nTagString "MaterialRef") == 0 then
				(
					------------------------------------Build .mtl path------------------------------------
					local filePath 				= _NameRef_						
					
					check_4_mtl_suffix \
												filePath:		&filePath						
					
					build_complete_filePath \									
													attribVal:		&_NameRef_ \
													dirPath:			&::g_dirPath \
													filePath:			&filePath --Note this is a reference and will update the g_cryFile above
					-----------------------------------------------------------------------------------------

					if ::rollout_Report.chk_MaterialRef_Report.state then
					(
						format "\n###################################################\n"
						format "######	_NameRef_: %	\n" 	_NameRef_
						format "######	filePath: % \n" 		filePath
						format "###################################################\n"
					)				
					
					if doesfileexist filePath then --this is the .mtl file
					(
						----Reset Array----
						parsed					=	#(
															#(), 	-- 1
															#(), 	-- 2
															#(), 	-- 3
															#(), 	-- 4
															#() 	-- 5 MaterialRef
														)
						
						matNodeSet			= #()
						----------------------
						
						inst_xmlB_PROCESSOR 		= xmlB_PROCESSOR() --create struct instance					
						--Let's now parse the .mtl file that the MaterialRef pointed to
						inst_xmlB_PROCESSOR.cry_xmlB_ReaderV \
																				_LOADED: 									&_LOADED \
																				_LOADEDm: 								&_LOADEDm \
																				matNodeCounter_MAT:					&matNodeCounter_MAT \
																				matNodeCounter_REF:					&matNodeCounter_REF \
																				inst_s_OPTIONS:							&inst_s_OPTIONS \
																				MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
																				type:											(getFilenameType filePath) \
																				mtl_File:										&filePath \
																				inst_Sub_Meshes:						&inst_Sub_Meshes
						
						if ::rollout_Report.chk_MaterialRef_Report.state then
						(
							format "\n***************** matNodeCounter: % *****************\n" matNodeCounter
							format "\n***************** matNodeCounter_MAT: % *****************\n" matNodeCounter_MAT
							format "\n***************** matNodeCounter_REF: % *****************\n" matNodeCounter_REF
							for x in matNodeSet do print x				
						)							
						
						material_Builder \
													matNodeSet:								&matNodeSet \
													matNodeCounter:							&matNodeCounter \
													matNodeCounter_MAT:					&matNodeCounter_MAT \
													matNodeCounter_REF:					&matNodeCounter_REF \
													uniqueIDs:									&theMat.materialIDList[matIDX] \ 	--the real actual id
													matIDX:										&matIDX \								 	--the id of the sub material index list
													theMat:										&theMat \
													compositeMat:							&compositeMat \
													inst_s_OPTIONS:							&inst_s_OPTIONS \
													iMesh:										&iMesh \
													MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
													inst_tex_tokens:							&inst_tex_tokens
					)					
				)
			)
		)
	),
	
	fn extract_from_Material_NodeName \											
													&matNodeSet: \
													&parsed: \
													&uniqueIDs: \ 								--the real actual id
													&matIDX: \								 	--the id of the sub material index list
													&MaterialRef_node_counter: \
													&theMat: \
													&compositeMat: \
													&inst_s_OPTIONS: \
													&iMesh: \
													&MTL_NAME_CHUNK_DESC: \
													&inst_Sub_Meshes: \
													&inst_tex_tokens: =
	(
		if ::g_NameMTL != undefined then
		(
			if iskindof ::g_NameMTL Array then
			(
				if ::g_NameMTL.count == 2 then
				(
					local mat 	= ::g_NameMTL[2]
					local id		= ::g_NameMTL[1]
					
					for i=1 to mat.count do
					(
						local matNodeCounter		= id[i]
						local filePath					= mat[i]
						
						if matNodeCounter != undefined then
						(
							if filePath != undefined then
							(
								if doesfileexist (filePath as string) then --this is the .mtl file
								(
									matNodeSet			= #()
									----------------------
											
									inst_xmlB_PROCESSOR 		= xmlB_PROCESSOR() --create struct instance					
									--Let's now parse the .mtl file that the MaterialRef pointed to
									inst_xmlB_PROCESSOR.cry_xmlB_ReaderV \
																							_LOADED: 									&_LOADED \
																							_LOADEDm: 								&_LOADEDm \
																							inst_s_OPTIONS:							&inst_s_OPTIONS \
																							MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
																							type:											(getFilenameType filePath) \
																							mtl_File:										&filePath \
																							inst_Sub_Meshes:						&inst_Sub_Meshes
											
									if ::rollout_Report.chk_MaterialRef_Report.state then
									(
										format "\n***************** matNodeCounter: % *****************\n" matNodeCounter
										for x in matNodeSet do print x				
									)							
											
									material_Builder \
															matNodeSet:								&matNodeSet \
															matNodeCounter:							&matNodeCounter \
															uniqueIDs:									&theMat.materialIDList[matIDX] \ 	--the real actual id
															matIDX:										&matIDX \								 	--the id of the sub material index list
															theMat:										&theMat \
															inst_s_OPTIONS:							&inst_s_OPTIONS \
															iMesh:										&iMesh \
															MTL_NAME_CHUNK_DESC:				&MTL_NAME_CHUNK_DESC \
															inst_tex_tokens:							&inst_tex_tokens
								)
							)
						)			
					)
				)
			)
		)
	),
	
	fn parse_XML \
						&matNodeCounter: \
						&matNodeCounter_REF: \
						&xml_file: =							
	(
		--///////////////////////////// Read XML ////////////////////////////////
		str_read_xml = read_xml()
		str_read_xml.report = false --for formatting the print arr -- just for readability
									
		--Parsing the xml (.mtl)
		local xml_arr =  str_read_xml.main \
														caller:							(getFilenameType xml_file) \
														matNodeCounter: 			&matNodeCounter \
														matNodeCounter_REF: 		&matNodeCounter_REF \
														xmlPath: 						&xml_file \
														xml_arr: 						&str_read_xml._xml
									
		--Processing/analysing the parsed xml
-- 		inst_xml_PROCESSOR = xml_PROCESSOR()
-- 		inst_xml_PROCESSOR.printNodes \
-- 													xml_arr: &xml_arr
		--////////////////////////////////////////////////////////////////////////
	),
	
	fn parse_CDF_XML \
							&Anim_Node_Counter: \
							&Attachment_node_counter: \
							&matNodeCounter: \
							&matNodeCounter_REF: \
							&xml_file: =							
	(		
		--///////////////////////////// Read XML ////////////////////////////////
		str_read_xml = read_xml()
		str_read_xml.report = true --for formatting the print arr -- just for readability
									
		--Parsing the xml (.mtl)
		local xml_arr =  str_read_xml.main \
														caller:									(getFilenameType xml_file) \
														Anim_Node_Counter:				&Anim_Node_Counter \
														Attachment_node_counter:		&Attachment_node_counter \
														matNodeCounter: 					&matNodeCounter \
														matNodeCounter_REF: 				&matNodeCounter_REF \
														xmlPath: 								&xml_file \
														xml_arr: 								&str_read_xml._xml
									
		--Processing/analysing the parsed xml
		inst_xml_PROCESSOR = xml_PROCESSOR()
		inst_xml_PROCESSOR.printNodes \
													xml_arr: &xml_arr
		--////////////////////////////////////////////////////////////////////////		
	),
	
	fn MATERIAL_PROCESSOR \
										&_LOADED: \
										&_LOADEDm: \
										&matNodeSet: \
										&parsed: \
										&uniqueIDs: \
										&matIDX: \
										&theMat: \
										&compositeMat: \
										&iMesh: \
										&inst_s_OPTIONS: \
										&MTL_NAME_CHUNK_DESC: \
										&inst_Sub_Meshes: \
										&inst_tex_tokens: =
	(		
		if ::rollout_Options.chk_BuildMaterial.state then
		(
			extract_from_Material \
											_LOADED: 							&_LOADED \
											_LOADEDm: 						&_LOADEDm \
											matNodeSet:						&matNodeSet \
											parsed:								&parsed \
											uniqueIDs: 							&uniqueIDs \ 	--the real actual id
											matIDX: 							&matIDX \								 	--the id of the sub material index list
											theMat: 							&theMat \
											compositeMat: 					&compositeMat \
											iMesh: 								&iMesh \
											inst_s_OPTIONS:					&inst_s_OPTIONS \
											MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
											inst_Sub_Meshes:				&inst_Sub_Meshes \
											inst_tex_tokens:					&inst_tex_tokens
											
			----------------------------------- We parse the MaterialRef matNodeSet (it might or might not be empty) -----------------------------------
			if ::rollout_Options.chk_MaterialRef.state then
			(
				extract_from_MaterialRef \
													_LOADED: 							&_LOADED \
													_LOADEDm: 						&_LOADEDm \
													matNodeSet:						&matNodeSet \
													parsed:								&parsed \
													uniqueIDs: 							&uniqueIDs \ 	--the real actual id
													matIDX: 							&matIDX \								 	--the id of the sub material index list
													theMat: 							&theMat \
													compositeMat: 					&compositeMat \
													iMesh: 								&iMesh \
													inst_s_OPTIONS:					&inst_s_OPTIONS \
													MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
													inst_Sub_Meshes:				&inst_Sub_Meshes \
													inst_tex_tokens:					&inst_tex_tokens
			)
											
			if ::rollout_Options.chk_deepSearch.state then
			(					
				extract_from_Material_NodeName \
																matNodeSet:						&matNodeSet \
																parsed:								&parsed \
																uniqueIDs: 							&uniqueIDs \ 	--the real actual id
																matIDX: 							&matIDX \								 	--the id of the sub material index list
																theMat: 							&theMat \
																compositeMat: 					&compositeMat \
																iMesh: 								&iMesh \
																inst_s_OPTIONS:					&inst_s_OPTIONS \
																MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
																inst_Sub_Meshes:				&inst_Sub_Meshes \
																inst_tex_tokens:					&inst_tex_tokens
			)
		)
										
		--/////////////////// Assign the built material to all the built meshes ////////////////////
		--////////////////////////////////////////////////////////////////////////////////
		for e_mesh in inst_Sub_Meshes.subMeshes do
		(
			if classof e_mesh == Editable_Mesh then
			(
				e_mesh.material = theMat
			)
		)
		--////////////////////////////////////////////////////////////////////////////////
		--////////////////////////////////////////////////////////////////////////////////
	),
	
	fn INNER_MATERIAL_CONSTRUCTOR \	
														&_LOADED: \
														&_LOADEDm: \
														&inst_Sub_Meshes: \
														&nStream: \
														&matNodeCounter_REF: \
														&xmlArr: \
														&inst_s_OPTIONS: \
														&xmlB: \
														subMats: \
														&MTL_NAME_CHUNK_DESC: \
														&mtlName: =
	(
		local uniqueIDs = #()			
		
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
		(
			if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)] != undefined then
			(
				if MTL_NAME_CHUNK_DESC != false then
				(
					if MTL_NAME_CHUNK_DESC[(*nStream)] != undefined then
					(
						--MTL_NAME_CHUNK_DESC -either MTL_NAME_CHUNK_DESC_0800 or MTL_NAME_CHUNK_DESC_0802 ---***see version ***
						local type 						= MTL_NAME_CHUNK_DESC[(*nStream)].type
						local version 					= MTL_NAME_CHUNK_DESC[(*nStream)].version
						local _name 					= MTL_NAME_CHUNK_DESC[(*nStream)]._name
						local nSubMaterials 			= MTL_NAME_CHUNK_DESC[(*nStream)].nSubMaterials
						
						format "\n"
						format "MTL_NAME_CHUNK_DESC[(*nStream)] \n"
						format "type: %\n" 						type
						format "version: %\n" 					version
						format "_name: %\n" 					_name
						format "nSubMaterials: %\n" 			nSubMaterials
						format "\n"
						

						if  inst_Sub_Meshes.subMeshes[(*nStream)] != undefined then
						(
							theMesh =  inst_Sub_Meshes.subMeshes[(*nStream)]
								
							--predeclare the Material
							local theMat 				= theMesh.material 
							local compositeMat 		= theMesh.material
								
							--there would be no use in continuing if our mesh is invalid (what are we supposed to apply the material on)
							if 	IsValidNode theMesh AND \
								(classof theMesh) == Editable_Mesh then
							(
								--We only do this if we haven't assigned a material already
								-- If the mesh texturing process is MaterialRef then the mesh will only be applied a material ONCE
								-- So if there is already a material present, then this is skipped over
								if 	theMat 				== undefined AND \ 
									compositeMat 		== undefined then
								(
									--See CryHeaders.h 507 for MTL_NAME_CHUNK_DESC_0800 or MTL_NAME_CHUNK_DESC_0802
									--below we have so far just implemented MTL_NAME_CHUNK_DESC_0802 enum {VERSION = 0x0802}	
									if nSubMaterials == 0 then --means a single material
									(
										--theMat = standardMaterial
										theMat 								= multimaterial  numsubs:( nSubMaterials +1 )

										set_Physical_vars \
																theMat:&theMat

										if NOT ::g_Physical_Material then
										(
											compositeMat					= compositeMaterial baseMaterial:( theMat )
										)
											
										theMesh.material 				=	theMat 		--Apply the material to the mesh
										medit.OkMtlForScene 				theMat 		--call this method to avoid duplicate names.				
										medit.PutMtlToMtlEditor 			theMat 		inst_Sub_Meshes.CA_SKIN_counter --add it to the #subM slot							

										--Name the medit slot
										meditMaterials[inst_Sub_Meshes.CA_SKIN_counter].name = (_name as string)

										theMat.materialList[1].showInViewport 			= on
									)
									else if nSubMaterials <= ::g_MAX_SUB_MATERIALS AND nSubMaterials > 0  then
									(
										--see http://docs.cryengine.com/display/SDKDOC2/Basic+Asset+Setup+and+Export+out+of+Max
	-- 									theMat 									= multimaterial  numsubs:(uniqueIDs.count)										
										--CryHeaders.h 543
										theMat 									= multimaterial  numsubs:(nSubMaterials) --test ???
											
										set_Physical_vars \													
																theMat:&theMat

										if NOT ::g_Physical_Material then
										(
											compositeMat						= compositeMaterial baseMaterial:( theMat )
										)
											
										theMesh.material 					=	theMat 		--Apply the material to the mesh
										medit.OkMtlForScene 					theMat 		--call this method to avoid duplicate names.
										medit.PutMtlToMtlEditor 				theMat 		inst_Sub_Meshes.CA_SKIN_counter --add it to the #subM slot							
											
										--Name the medit slot
										meditMaterials[inst_Sub_Meshes.CA_SKIN_counter].name = (_name as string)

										theMat.materialList[1].showInViewport 			= on
									)
								)

								if theMat != undefined then
								(
									inst_tex_tokens = tex_tokens()
									
									if ::XMLB_BOOL then
									(
										--Preload attributes
										local matNodeCounter 							= -1
										local Attachment_node_counter 			= 0
										local MaterialRef_node_counter				= 0
										local matNodeCounter_MAT 					= 0
										
										---------------------------------- We parse the main .mtl ----------------------------------
										parse_xmlB_v3 \
															matNodeCounter_MAT:			&matNodeCounter_MAT \
															matNodeCounter_REF:			&matNodeCounter_REF \				
															type:									type \
															matNodeCounter:					&matNodeCounter \
															Attachment_node_counter:	&Attachment_node_counter \
															MaterialRef_node_counter:	&MaterialRef_node_counter \
															xmlArr:								&xmlArr \
															uniqueIDs:							&uniqueIDs \
															matIDX:								matIDX \											
															inst_s_OPTIONS:					&inst_s_OPTIONS \
															theMat:								&theMat \
															compositeMat:					&compositeMat \
															subMats:							subMats	
										
										MATERIAL_PROCESSOR \
																		_LOADED: 							&_LOADED \
																		_LOADEDm: 						&_LOADEDm \
																		matNodeSet:						&::g_xmlB_MatNodesSet \
																		parsed:								&::g_xmlB_Parsed \
																		uniqueIDs: 							&theMat.materialIDList[matIDX] \
																		matIDX: 							&matIDX \
																		theMat: 							&theMat \
																		compositeMat: 					&compositeMat \
																		iMesh: 								&iMesh \
																		inst_s_OPTIONS: 				&inst_s_OPTIONS \
																		MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
																		inst_Sub_Meshes: 				&inst_Sub_Meshes \
																		inst_tex_tokens:					&inst_tex_tokens
									)
									else
									(
										--Preload attributes
										local matNodeCounter 							= 0 --here this is 0, for xmlB this is -1 (see above)
										local Attachment_node_counter 			= 0
										local MaterialRef_node_counter				= 0
										local matNodeCounter_MAT 					= 0
										
										parse_XML \
														matNodeCounter: 			&matNodeCounter \
														matNodeCounter_REF: 		&matNodeCounter_REF \
														xml_file: 						&::g_xml_path										
										
										MATERIAL_PROCESSOR \
																		_LOADED: 							&_LOADED \
																		_LOADEDm: 						&_LOADEDm \
																		matNodeSet:						&::g_xml_MatNodesSet \
																		parsed:								&::g_xml_Parsed \
																		uniqueIDs: 							&theMat.materialIDList[matIDX] \
																		matIDX: 							&matIDX \
																		theMat: 							&theMat \
																		compositeMat: 					&compositeMat \
																		iMesh: 								&iMesh \
																		inst_s_OPTIONS: 				&inst_s_OPTIONS \
																		MTL_NAME_CHUNK_DESC: 	&MTL_NAME_CHUNK_DESC \
																		inst_Sub_Meshes: 				&inst_Sub_Meshes \
																		inst_tex_tokens:					&inst_tex_tokens
									)
								)
							)
						)
					)
				)
			)
		)
	),
	
	--////////////////////////////////////// MATERIAL CONSTRUCTOR entry //////////////////////////////////////
	fn construct_Material \	
									&_LOADED: \
									&_LOADEDm: \
									currFileType: \
									&inst_Sub_Meshes: \
									&inst_CDF_Model: \
									&inst_CDF_Attachment: \
									&inst_CDF_Modifiers: \
									nStream: \
									matID: \
									&matNodeCounter_MAT: \
									&matNodeCounter_REF: \		
									&xmlArr: \
									&inst_s_OPTIONS: \
									&xmlB: =
	(
		/*
 		Material ID 1 should always be the Physical Proxy Material. Since
 		you're in Material ID 1, select from the scroll down menu Crytek
 		Shader. Another box will open beneath it. Please click on the box
 		where it says Physicalize and select from the scroll down menu
 		Physical Proxy (No Draw). Go now into the color settings and set the
 		color to red and the opacity to 50%. That way it's easy to see through
 		the proxy and clearly set it apart from the mesh. Rename the material
 		proxy.
 		http://docs.cryengine.com/display/SDKDOC2/Basic+Asset+Setup+and+Export+out+of+Max
		--*/
		
		--Number of <SubMaterials> nodes in the xmlB as described in the 0xCCCC0014) (after the 128 bytes name chunk)
		local subMats 					= unsupplied
		local chunkID_0xCCCC0014	= unsupplied
		local mtlVersion					= unsupplied
		local mtlName						= ""	
		
		local MTL_NAME_CHUNK_DESC = #()
		ret_CHUNK_DESC \
								currFileType:							currFileType \
								inst_Sub_Meshes:					&inst_Sub_Meshes \
								MTL_NAME_CHUNK_DESC:			&MTL_NAME_CHUNK_DESC
		
		
		if MTL_NAME_CHUNK_DESC != unsupplied then
		(			
			if MTL_NAME_CHUNK_DESC != undefined then
			(
				INNER_MATERIAL_CONSTRUCTOR \	
															_LOADED: 							&_LOADED \
															_LOADEDm: 						&_LOADEDm \
															currFileType:						currFileType \
															inst_Sub_Meshes: 				&inst_Sub_Meshes \
															nStream:							&nStream \
															matID: 								&matID \
															matNodeCounter_REF:			&matNodeCounter_REF \				
															xmlArr:								&xmlArr \
															inst_s_OPTIONS:					&inst_s_OPTIONS \
															xmlB:									&xmlB \
															subMats:							subMats \
															MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
															mtlName:							&mtlName
			)
		)
		else
		(
			Format "##### MTL_NAME_CHUNK_DESC seems to be undefined, this is an exception and should not happen, it should have been ***unsupplied*** if invalid #####\n"
		)		
	),
	--////////////////////////////////// END OF MATERIAL CONSTRUCTOR entry //////////////////////////////////
	
	
	
	
	--///////////////////////////////////// PARSE STARTERS /////////////////////////////////////
	fn parse_general_xmlB \
									&_LOADED: \
									&_LOADEDm: \
									currFileType: \
									&SkeletonList_Bool: \
									&xmlArr: \
									&inst_s_OPTIONS: \
									type: =
	(
		--Preload attributes
		local matNodeCounter 					= 0
		local Attachment_node_counter 	= 0
		
		parse_cdf_xmlB_v3 \
									type:									type \
									SkeletonList_Bool:				SkeletonList_Bool \
									matNodeCounter:					&matNodeCounter \
									Attachment_node_counter:	&Attachment_node_counter \
									xmlArr:								&xmlArr \
									uniqueIDs:							&uniqueIDs \
									matIDX:								matIDX \
									inst_s_OPTIONS:					&inst_s_OPTIONS \
									theMat:								&theMat \
									compositeMat:					&compositeMat \
									subMats:							&subMats
	),
	
	fn parse_SkeletonList_xmlB \
										&_LOADED: \
										&_LOADEDm: \
										currFileType: \
										SkeletonList_Bool: \
										&xmlArr: \
										&inst_s_OPTIONS: \
										type: =
	(	
		--Preload attributes
		local matNodeCounter 					= 0
		local Attachment_node_counter 	= 0
		
		parse_SkeletonList_xmlB_v3 \
												type:										type \
												SkeletonList_Bool:					SkeletonList_Bool \
												matNodeCounter:						&matNodeCounter \
												Attachment_node_counter:		&Attachment_node_counter \
												xmlArr:									&xmlArr \
												uniqueIDs:								&uniqueIDs \
												matIDX:									matIDX \												
												inst_s_OPTIONS:						&inst_s_OPTIONS \
												theMat:									&theMat \
												compositeMat:						&compositeMat \
												subMats:								&subMats		
	),
	
	fn parse_cdf_loader_xmlB \
										&_LOADED: \
										&_LOADEDm: \
										currFileType: \
										&xmlArr: \
										&inst_s_OPTIONS: \
										type: =
	(
		--Preload attributes
		local matNodeCounter 					= 0	
		local Attachment_node_counter 	= 0
		
		parse_cdf_xmlB_v3 \
									matNodeCounter:					&matNodeCounter \
									Attachment_node_counter:	&Attachment_node_counter \
									xmlArr:								&xmlArr \
									uniqueIDs:							&uniqueIDs \
									matIDX:								matIDX \
									inst_s_OPTIONS:					&inst_s_OPTIONS \
									theMat:								&theMat \
									compositeMat:					&compositeMat \
									subMats:							&subMats \
									type:									type
	),	

	fn parse_LOAD_ASSETS_CDF_xmlB \													
													&xmlArr: \
													&inst_s_OPTIONS: \
													type: =
	(
		if 	::XMLB_BOOL AND \
			xmlArr != unsupplied then
		(
			--Preload attributes
			local matNodeCounter 					= 0
			local Attachment_node_counter 	= 0
			local Anim_Node_Counter 				= 0		
			
			parse_LOAD_ASSETS_CDF_xmlB_v3 \
															matNodeCounter:					&matNodeCounter \
															Attachment_node_counter: 	&Attachment_node_counter \
															Anim_Node_Counter:			&Anim_Node_Counter \
															xmlArr:								&xmlArr \
															uniqueIDs:							&uniqueIDs \
															matIDX:								matIDX \
															inst_s_OPTIONS:					&inst_s_OPTIONS \
															theMat:								&theMat \
															compositeMat:					&compositeMat \
															subMats:							&subMats \
															type:									type
		)
		else
		(
			format "CDF XML is loaded in the caller of this function\n"			
		)
	),	
	--////////////////////////////////// END OF PARSE STARTERS //////////////////////////////////
	
	
	
	
	--/////////////////////////////// LOAD MATERIAL CONSTRUCTOR ///////////////////////////////
	fn parse_xmlB \
						&_LOADED: \
						&_LOADEDm: \
						currFileType: \
						&inst_Sub_Meshes: \
						&inst_CDF_Model: \
						&inst_CDF_Attachment: \
						&inst_CDF_Modifiers: \
						&matNodeCounter_MAT: \
						&matNodeCounter_REF: \
						&xmlArr: \
						&inst_s_OPTIONS: =
	(
		--For each file, there are n Sets
		--For each n Set, there is potentially a separate 0x00000014 material file (as defined by the  *g_NODE_CHUNK_DESC_0824[nStream].matID*)
		--it is very rare to have a separate 0x00000014 material file for each set, but it is possible, so we have to loop with respect to that possibility
		--the *nStream* is the n Set
		--*inst_Sub_Meshes.CA_SKIN_counter* is the n File
		-- *inst_Sub_Meshes.subMeshes* are the subsets for each n Set
		
		-- Assuming we are on the right file *::_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter]* we then...
		-- ...go into the correct n Set
		
		for nStream=1 to _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824.count do
		(
			if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream] != undefined then
			(
				--the matID is the index id to the *MTL_NAME_CHUNK_DESC* -- which contains the 0x00000014 chunk des
				--remember we may have to check for the version of the struct, which is either 0x0800 or 0x0802
				--see CryHeaders.h 510
				local matID 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].matID
				local _name 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream]._name
				
				construct_Material \
											_LOADED: 							&_LOADED \
											_LOADEDm: 						&_LOADEDm \
											currFileType: 						currFileType \
											inst_Sub_Meshes: 				&inst_Sub_Meshes \
											inst_CDF_Attachment:			&inst_CDF_Attachment \
											inst_CDF_Model: 					&inst_CDF_Model \
											inst_CDF_Modifiers:				&inst_CDF_Modifiers \
											nStream:							&nStream \
											matID:								&matID \
											matNodeCounter_MAT:			&matNodeCounter_MAT \
											matNodeCounter_REF:			&matNodeCounter_REF \
											xmlArr:								&xmlArr \
											inst_s_OPTIONS:					&inst_s_OPTIONS
			)
		)
	),
	--///////////////////////////////// END OF LOAD MATERIAL CONSTRUCTOR /////////////////////
	
	
	fn xmlB_readers \
							&bstream: \
							&inst_BinaryFileHeader: =
	(
		read_Node \
						bstream:		&bstream \
						struct2read:	&inst_BinaryFileHeader
					
		read_nChildTable \
								bstream:		&bstream \
								struct2read:	&inst_BinaryFileHeader
					
		read_nAttributeTable \
										bstream:		&bstream \
										struct2read:	&inst_BinaryFileHeader
					
		read_nTagString \
								bstream:		&bstream \
								struct2read:	&inst_BinaryFileHeader
	),	
	
	--///////////////////////////////////// CRYXMLB READERS /////////////////////////////////////
	fn cry_general_xmlB_ReaderV \
											&_LOADED: \
											&_LOADEDm: \
											currFileType: \
											&inst_Sub_Meshes: \
											&inst_CDF_Model: \
											&inst_CDF_Attachment: \
											&inst_CDF_Modifiers: \
											&xmlBFile: \
											&inst_s_OPTIONS: \
											type: =
	(
		format "We are now inside the cry_general_xmlB_ReaderV...\n"
		
		xmlB_arr = #( \
							#(), \ 	--Binary XML header		[1]
							#(), \	--node structs			[2]
							#(), \ 	--child index				[3]
							#()  \	--attrib_child_indices	[4]
						)
		
		if doesfileexist xmlBFile then
		(
			if  (Binary_XML_check xmlBFile) then --if the xml file is not Crytek Binary XML
			(
				format "The XML file is in Crytek Binary XML format...\n"
				
				if (xmlBFile != undefined) then
				(		
					if (doesfileexist xmlBFile) then
					(
						setINISetting ::g_iniFile "xmlB_paths" (getFilenameType xmlBFile) xmlBFile --temp
					
						--////////////// Open binary stream //////////////
						xbs = fopen xmlBFile "rb"
						-------------------------------------------
						
						if xbs != undefined then
						(
							if iskindof xbs BinStream then
							(
								inst_BinaryFileHeader 					= BinaryFileHeader()
								local fixedLen = 8
								inst_BinaryFileHeader.szSignature 	= ReadFixedString \
																											bstream:	&xbs \
																											fixedLen:	&fixedLen

								------		------		------		------		------		------		------		------		------		------		------		------		------
								format "inst_BinaryFileHeader.szSignature: %\n" inst_BinaryFileHeader.szSignature
								------		------		------		------		------		------		------		------		------		------		------		------		------
				
								read_BinaryFileHeader \
															bstream:				&xbs \
															struct2fill:				&inst_BinaryFileHeader \
															signature2check:		&szSignature
								
								if inst_BinaryFileHeader.szSignature == ::g_CryXmlB_string then
								(
									xmlB_readers \
														bstream:					&xbs \
														inst_BinaryFileHeader:	&inst_BinaryFileHeader					
					
									ftell xbs
									--////////////// Close binarystream //////////////
									fclose xbs
									
									if ::g_xmlB_Debug_Report then
									(
										debug_xmlB_arr \
																xmlArr:&xmlB_arr
									)
									
									format "(getFilenameType xmlBFile): % \n" (getFilenameType xmlBFile)
									format "type: % \n" type 
									
									
									-------------------------------------------------------------------------------------
									if (getFilenameType xmlBFile) == type AND \ --double check --Here, we will try to load the Assets from the Character Definition File (.cdf)
										type == ".cdf" then
									(
										parse_cdf_loader_xmlB \
																		_LOADED:				&_LOADED \
																		_LOADEDm:				&_LOADEDm \
																		currFileType: 			currFileType \
																		xmlArr:					&xmlB_arr \
																		inst_s_OPTIONS:		&inst_s_OPTIONS \
																		type:						type
									)						
									else if (getFilenameType xmlBFile) == type AND \  --double check
										type == ".mtl" then
									(										
										parse_general_xmlB \
																_LOADED:				&_LOADED \
																_LOADEDm:				&_LOADEDm \
																currFileType: 			currFileType \
																xmlArr:					&xmlB_arr \
																inst_s_OPTIONS:		&inst_s_OPTIONS \
																type:						type
									)
									else if (getFilenameType xmlBFile) == type AND \  --double check
										type == ".xml" AND \
										(matchpattern xmlBFile pattern:("*"+g_SkeletonList_xml_NAME+"*")) then
									(
										parse_SkeletonList_xmlB \
																			_LOADED:				&_LOADED \
																			_LOADEDm:				&_LOADEDm \
																			currFileType: 			currFileType \
																			SkeletonList_Bool:	true \
																			xmlArr:					&xmlB_arr \
																			inst_s_OPTIONS:		&inst_s_OPTIONS \
																			type:						type
									)
									else if (getFilenameType xmlBFile) == type AND \  --double check
										type == ".chrparams" then
									(
										
										parse_cdf_loader_xmlB \
																		_LOADED:				&_LOADED \
																		_LOADEDm:				&_LOADEDm \
																		currFileType: 			currFileType \
																		xmlArr:					&xmlB_arr \
																		inst_s_OPTIONS:		&inst_s_OPTIONS \
																		type:						type							
									)						
									-------------------------------------------------------------------------------------
								)
							)
							else
							(
								format "Cannot make BinStream from: % , aborting!\n" ::g_xml_path
							)
						)
					)
				)
			)
			else
			(
-- 				::XMLB_BOOL = false
-- 				
-- 				if (stricmp (getFilenameType CDF_File) type) == 0 AND \ --double check --Here, we will try to load the Assets from the Character Definition File (.cdf)
-- 					(stricmp type ".cdf") == 0 then
-- 				(
-- 					format "% is in CDF  is in XML format\n" ::g_xml_path
-- 									
-- 					parse_LOAD_ASSETS_CDF_xmlB \																				
-- 																inst_s_OPTIONS:		&inst_s_OPTIONS \
-- 																type:						type
-- 				)
			)
		)		
	),
	
	-----------------------------------------xmlB Reader -----------------------------------------
	fn cry_CDF_xmlB_ASSETS_loader_ReaderV \
																&CDF_File: \
																&inst_s_OPTIONS: \
																type: =
	(
		format "We are now inside the cry_general_xmlB_ReaderV...\n"		
		
		xmlB_arr = #( \
							#(), \ 	--Binary XML header		[1]
							#(), \	--node structs			[2]
							#(), \ 	--child index				[3]
							#()  \	--attrib_child_indices	[4]
						)
		
		if doesfileexist CDF_File then
		(
			if (Binary_XML_custom_check file:CDF_File type:"CryXmlB") then --if the xml file is not Crytek Binary XML			
			(
				::XMLB_BOOL = true
				
				format "The XML file is in Crytek Binary XML format...\n"
				
				if (CDF_File != undefined) then
				(		
					if (doesfileexist CDF_File) then
					(
						setINISetting ::g_iniFile "xmlB_paths" (getFilenameType CDF_File) CDF_File --temp
					
						--////////////// Open binary stream //////////////
						xbs = fopen CDF_File "rb"
						-------------------------------------------
						
						if xbs != undefined then
						(
							if iskindof xbs BinStream then
							(
								inst_BinaryFileHeader 					= BinaryFileHeader()
								local fixedLen = 8
								inst_BinaryFileHeader.szSignature 	= ReadFixedString \
																											bstream:	&xbs \
																											fixedLen:	&fixedLen

								------	------	------	------	------	------	------	------	------	------	------	------	------	------	------
								format "inst_BinaryFileHeader.szSignature: %\n" inst_BinaryFileHeader.szSignature
								------	------	------	------	------	------	------	------	------	------	------	------	------	------	------
				
								read_BinaryFileHeader \
															bstream:				&xbs \
															struct2fill:				&inst_BinaryFileHeader \
															signature2check:		&inst_BinaryFileHeader.szSignature
								
								if inst_BinaryFileHeader.szSignature == ::g_CryXmlB_string then
								(
									xmlB_readers \
														bstream:					&xbs \
														inst_BinaryFileHeader:	&inst_BinaryFileHeader	
					
					
									ftell xbs
									--////////////// Close binarystream //////////////
									fclose xbs
									
									if ::g_xmlB_Debug_Report then
									(
										debug_xmlB_arr \
																xmlArr:&xmlB_arr
										
										format "(getFilenameType CDF_File): % \n" (getFilenameType CDF_File)
										format "type: % \n" type
									)
									
									-------------------------------------------------------------------------------------
									if (stricmp (getFilenameType CDF_File) type) == 0 AND \ --double check --Here, we will try to load the Assets from the Character Definition File (.cdf)
										(stricmp type ".cdf") == 0 then
									(
										format "% is in CDF  is in XMLB format\n" ::g_xml_path
										
										parse_LOAD_ASSETS_CDF_xmlB \
																					xmlArr:					&xmlB_arr \
																					inst_s_OPTIONS:		&inst_s_OPTIONS \
																					type:						type
									)
									else if (stricmp (getFilenameType CDF_File) type) == 0 AND \ --double check --Here, we will try to load the Assets from the Character Definition File (.cdf)
											(stricmp type ".chrparams") == 0 then
									(
										format "% is in CDF  is in XMLB format\n" ::g_xml_path
										
										parse_LOAD_ASSETS_CDF_xmlB \
																					xmlArr:					&xmlB_arr \
																					inst_s_OPTIONS:		&inst_s_OPTIONS \
																					type:						type
									)
									-------------------------------------------------------------------------------------
								)
							)
							else
							(
								format "Cannot create BinStream from: % , aborting!\n" CDF_File
							)
						)
					)
				)
			)
			else --try ordinary XML
			(
				if (stricmp (getFilenameType CDF_File) type) == 0 AND \ --double check --Here, we will try to load the Assets from the Character Definition File (.cdf)
					(stricmp type ".cdf") == 0 then
				(
					format "% is in CDF  is in XML format\n" CDF_File
									
-- 					parse_LOAD_ASSETS_CDF_xmlB \																				
-- 																inst_s_OPTIONS:		&inst_s_OPTIONS \
-- 																type:						type
					
					--Preload attributes
					local matNodeCounter 					= 0
					local Attachment_node_counter 	= 0
					local Anim_Node_Counter 				= 0
					
					 ::XMLB_BOOL = false
					parse_CDF_XML \
											matNodeCounter:					&matNodeCounter \
											Attachment_node_counter: 	&Attachment_node_counter \
											Anim_Node_Counter:			&Anim_Node_Counter \
											xml_file:								&CDF_File
				)		
			)			
		)		
	),

	fn cry_xmlB_ReaderV  \
									&_LOADED: \
									&_LOADEDm: \
									currFileType: \
									&inst_Sub_Meshes: \
									&inst_CDF_Model: \
									&inst_CDF_Attachment: \
									&inst_CDF_Modifiers: \
									&matNodeCounter_MAT: \
									&matNodeCounter_REF: \
									&MTL_NAME_CHUNK_DESC: \
									&inst_s_OPTIONS: \
									&cdf_File: \
									&mtl_File: \
									&chrparams_File: \
									type: =
	(
		for nStream=1 to _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824.count do
		(
			if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream] != undefined then
			(
				--the matID is the index id to the *MTL_NAME_CHUNK_DESC* -- which contains the 0x00000014 chunk des
				--remember we may have to check for the version of the struct, which is either 0x0800 or 0x0802
				--see CryHeaders.h 510
				local matID = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].matID
				
				/*
				--For some reason, statue_lion_winged_01 matid pointed to matID 2, which is *material #13*
				--but the first material, is the correct one! maybe when prefixed with # then the material should not be counted???
				-- # should be avoided in material names, and it is possible it is an artist error
				format "\n"
				format "g_NODE_CHUNK_DESC_0824[nStream]: %\n" _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream]
				format "g_NODE_CHUNK_DESC_0824[nStream]: %\n" _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MTL_NAME_CHUNK_DESC[matID]
				format "\n"
				--*/
				
				------	------	------	------	------	------	------	------
				format "Attempting to apply Textures, Please Wait..."
				format "g_cryFile: %\n" g_cryFile
				------	------	------	------	------	------	------	------
				
				if ::g_xmlB_Debug_Report do
				(
					print "#########	###########"
					print "#########	###########"
					format "mtl_File: % \n" mtl_File
					format "cdf_File: % \n" cdf_File
					print "#########	###########"
					print "#########	###########"
				)
				
				--------------- search .mtl for matching path and to set it to g_xml_Path --------------
				get_game_dirPath()
				local gamesdk_path 	= ::g_dirpath  + "\\"
				local g_xml_Path 		= ""
				
				if 	cdf_File 		== unsupplied AND \
					mtl_File 		== unsupplied then
				(
					if MTL_NAME_CHUNK_DESC != undefined then
					(
						if MTL_NAME_CHUNK_DESC != unsupplied then
						(
							if matID > 0 then
							(
								local db_dir 				= pathConfig.resolvePathSymbols (::g_scriptRoot + "\\db")
								local db_name 			= ::g_db_type + "_db.txt"
								local db_File 				= pathConfig.resolvePathSymbols (pathConfig.AppendPath 	db_dir 	db_name)
								local foundMTL 			= false
								
								if NOT doesfileexist db_File then
								(
									if ::g_db_type != "" then
									(
										inst_build_resource_db 			= build_resource_db() --create instance
										inst_build_resource_db.builder \
																					g_db_type: &::g_db_type
									)
								)
								else if doesfileexist db_File then
								(
									search_db \									
													foundMTL:								&foundMTL \
													g_xml_Path:							&g_xml_Path \
													db_File: 									&db_File \
													MTL_NAME_CHUNK_DESC:			&MTL_NAME_CHUNK_DESC \
													matID:									&matID
									
								)
								else -- This is a slower backup method in case there is no way to create the db ***This is a last resort, and not a good one***
								(							
									if ::g_auto_resourcelist_array.count == 0 then
									(
										::g_auto_resourcelist_array = getFilesRecursive \
																										root:			(::g_dirPath) \
																										specDir:		"Levels" \
																										targetFile:	"auto_resourcelist.txt"
									)		
										
									for r=1 to ::g_auto_resourcelist_array.count do
									(
										local foundMTL = false
											
										if doesfileexist ::g_auto_resourcelist_array[r] then
										(
											local auto_resourcelist = ::g_auto_resourcelist_array[r]

											local StreamReader	 	= dotNetObject "System.IO.StreamReader" auto_resourcelist
											local mtl_Line 			= ""
											local foundMTL 			= false
											local dot_NET 			= false										

											if StreamReader != undefined then
											(
												if (classof StreamReader) == dotNetObject then
												(
													dot_NET = true;
														
													if dot_NET then
													(
														format "*** dotNET ***\n"
														dotNet_readLines \
																				g_xml_Path:						&g_xml_Path \
																				auto_resourcelist:				&auto_resourcelist \
																				mtl_Line:							&mtl_Line \
																				foundMTL:							&foundMTL \
																				MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC \
																				StreamReader:					&StreamReader
													)
													else
													(
														dot_NET = false;
														
														format "*** MaxScript ***\n"
														maxScript_readLines \
																					g_xml_Path:						&g_xml_Path \
																					auto_resourcelist:				&auto_resourcelist \
																					mtl_Line:							&mtl_Line \
																					foundMTL:							&foundMTL \
																					MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC
													)									
												)
											)
										)
											
										if foundMTL then
										(
											exit;
										)
									)							
								)	
							)
						)
					)
					else
					(
						format "\nNo 0xCCCC0014 material description chunk found\n"
					)
				)
				else
				(
					if cdf_File != unsupplied then
					(
						if cdf_File != undefined then
						(
							if doesfileexist cdf_File then
							(
								::g_xml_Path = cdf_File
							)
						)
					)			
					if mtl_File != unsupplied then
					(
						if mtl_File != undefined then
						(
							if doesfileexist mtl_File then
							(
								::g_xml_Path = mtl_File
							)
						)
					)
				)
			)
		)
		
		
		
		if NOT doesfileexist ::g_xml_Path OR \
			::g_xml_Path == undefined then
		(			
			simplest_mtl_search \
										foundMTL: &foundMTL
			
			if NOT doesfileexist ::g_xml_Path OR \
			::g_xml_Path == undefined then
			(
				--let's try to find the mtl by heruistic method				
				mtl_heuristic()				
			
				if NOT doesfileexist ::g_xml_Path OR \
				::g_xml_Path == undefined then
				(
					local db_dir 				= pathConfig.resolvePathSymbols (::g_scriptRoot + "\\db")
					local db_name 			= ::g_db_type + "_db.txt"
					local db_File 				= pathConfig.resolvePathSymbols (pathConfig.AppendPath 	db_dir 	db_name)
					local foundMTL 			= false	
					
					if ::g_auto_resourcelist_array.count == 0 then
					(
						::g_auto_resourcelist_array = getFilesRecursive \
																						root:			(::g_dirPath) \
																						specDir:		"Levels" \
																						targetFile:	"auto_resourcelist.txt"
					)		
									
					for r=1 to ::g_auto_resourcelist_array.count do
					(
						local foundMTL = false
										
						if doesfileexist ::g_auto_resourcelist_array[r] then
						(
							local auto_resourcelist = ::g_auto_resourcelist_array[r]

							local StreamReader	 	= dotNetObject "System.IO.StreamReader" auto_resourcelist
							local mtl_Line 			= ""
							local foundMTL 			= false
							local dot_NET 			= false										

							if StreamReader != undefined then
							(
								if (classof StreamReader) == dotNetObject then
								(
									dot_NET = true;
													
									if dot_NET then
									(
										format "*** dotNET ***\n"
										dotNet_readLines \
																g_xml_Path:							&g_xml_Path \
																auto_resourcelist:					&auto_resourcelist \
																mtl_Line:								&mtl_Line \
																foundMTL:								&foundMTL \
																MTL_NAME_CHUNK_DESC:			&MTL_NAME_CHUNK_DESC \
																StreamReader:						&StreamReader
									)
									else
									(
										dot_NET = false;
													
										format "*** MaxScript ***\n"
										maxScript_readLines \
																	g_xml_Path:						&g_xml_Path \
																	auto_resourcelist:				&auto_resourcelist \
																	mtl_Line:							&mtl_Line \
																	foundMTL:							&foundMTL \
																	MTL_NAME_CHUNK_DESC:		&MTL_NAME_CHUNK_DESC
									)									
								)
							)
						)									
						if foundMTL then
						(						
							exit;
						)
					)
				)			
			)
		)
		
		
		format "========#### ::g_xml_Path: % ####========\n" ::g_xml_Path		
		if doesFileExist ::g_xml_Path then
		(
			xmlB_arr = #( \
								#(), \ 	--Binary XML header		[1]
								#(), \	--node structs			[2]
								#(), \ 	--child index				[3]
								#()  \	--attrib_child_indices	[4]
							 )
							 
			if  (Binary_XML_check ::g_xml_Path) then --Crytek Binary xmlB
			(
				::XMLB_BOOL = true
				
				format "The XML file is in Crytek Binary XML format...\n"				
				
				if ::g_xml_path != undefined then
				(
					if doesfileexist ::g_xml_path then
					(
						setINISetting ::g_iniFile "paths" "g_xml_path" ::g_xml_path --temp
						
						--////////////// Open binary stream //////////////
						xbs = fopen ::g_xml_path "rb"
						-------------------------------------------
						
						if xbs != undefined then
						(
							if iskindof xbs BinStream then
							(
								inst_BinaryFileHeader = BinaryFileHeader()
								local fixedLen = 8
								inst_BinaryFileHeader.szSignature = ReadFixedString \
																										bstream:	&xbs \
																										fixedLen:	&fixedLen
				
								if rollout_Report.chk_xmlB_Report_v2.state then
								(
									------	------	------	------	------	------	------	------	------	------	------	------	------	------	------
									format "inst_BinaryFileHeader.szSignature: %\n" inst_BinaryFileHeader.szSignature
									------	------	------	------	------	------	------	------	------	------	------	------	------	------	------
								)
								
								read_BinaryFileHeader \
																bstream:				&xbs \
																struct2fill:				&inst_BinaryFileHeader \
																signature2check:		&inst_BinaryFileHeader.szSignature
								
								if inst_BinaryFileHeader.szSignature == ::g_CryXmlB_string then
								(									
									xmlB_readers \
														bstream:					&xbs \
														inst_BinaryFileHeader:	&inst_BinaryFileHeader					
					
									ftell xbs
									--////////////// Close binarystream //////////////
									fclose xbs
									
									if ::g_xmlB_Debug_Report do
									(
										debug_xmlB_arr \
																xmlArr:	&xmlB_arr
									)
									
									case of
									(
										(type == ".cdf"):				(Append ::inst_xmlB_LOADED._cdf xmlB_arr)
										(type == ".mtl"):				(Append ::inst_xmlB_LOADED._mtl xmlB_arr)
										(type == ".chr"):				(Append ::inst_xmlB_LOADED._chr xmlB_arr)
										(type == ".cgf"):				(Append ::inst_xmlB_LOADED._cgf xmlB_arr)
										(type == ".skin"):			(Append ::inst_xmlB_LOADED._skin xmlB_arr)
										(type == ".chrparam"):		(Append ::inst_xmlB_LOADED._chrparam xmlB_arr)
										
										default:							(Append ::inst_xmlB_LOADED._default xmlB_arr)
									)
									
									parse_xmlB \	
													_LOADED: 						&_LOADED \
													_LOADEDm: 					&_LOADEDm \
													currFileType: 					currFileType \
													inst_Sub_Meshes:			&inst_Sub_Meshes \
													inst_CDF_Model:				&inst_CDF_Model \
													inst_CDF_Attachment:		&inst_CDF_Attachment \
													inst_CDF_Modifiers:			&inst_CDF_Modifiers \
													matNodeCounter_MAT:		&matNodeCounter_MAT \
													matNodeCounter_REF:		&matNodeCounter_REF \
													xmlArr:							&xmlB_arr \
													inst_s_OPTIONS:				&inst_s_OPTIONS
								)
							)
							else
							(
								format "Cannot make BinStream from: % , aborting!\n" ::g_xml_path
							)
						)
						else
						(
							format "Cannot make BinStream from: %  is undefined - aborting!\n" ::g_xml_path
						)
					)
				)
			)
			else --try ordinary XML
			(
				format "The XML file is in XML format...\n"	
				
				::XMLB_BOOL = false				
				parse_xmlB \	
								_LOADED: 						&_LOADED \
								_LOADEDm: 					&_LOADEDm \
								currFileType: 					currFileType \
								inst_Sub_Meshes:			&inst_Sub_Meshes \
								inst_CDF_Model:				&inst_CDF_Model \
								inst_CDF_Attachment:		&inst_CDF_Attachment \
								inst_CDF_Modifiers:			&inst_CDF_Modifiers \
								matNodeCounter_MAT:		&matNodeCounter_MAT \
								matNodeCounter_REF:		&matNodeCounter_REF \
								xmlArr:							&xmlB_arr \
								inst_s_OPTIONS:				&inst_s_OPTIONS
			)
		)
	)
	--////////////////////////////////// END OF CRYXMLB READERS //////////////////////////////////	
)
