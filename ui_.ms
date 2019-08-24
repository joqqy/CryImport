--joqqyhez@gmail.com

--/////////////////////////////////////////  Notes /////////////////////////////////////// 

-- C:\Program Files (x86)\Crytek\CRYENGINE Launcher\Crytek\CRYENGINE_5.0\Code\CryEngine\CryCommon\CryFile.h:
-- //////////////////////////////////////////////////////////////////////////
-- // Defines for CryEngine filetypes extensions.
-- //////////////////////////////////////////////////////////////////////////
-- #define CRY_GEOMETRY_FILE_EXT                   				 	"cgf"
-- #define CRY_SKEL_FILE_EXT                       			 			"chr" //will be a SKEL soon
-- #define CRY_SKIN_FILE_EXT                       			 			"skin"
-- #define CRY_CHARACTER_ANIMATION_FILE_EXT        			 "caf"
-- #define CRY_CHARACTER_DEFINITION_FILE_EXT        			"cdf"
-- #define CRY_CHARACTER_LIST_FILE_EXT             				 "cid"
-- #define CRY_ANIM_GEOMETRY_FILE_EXT              				 "cga"
-- #define CRY_ANIM_GEOMETRY_ANIMATION_FILE_EXT    		 "anm"
-- #define CRY_COMPILED_FILE_EXT                    					"(c)"
-- #define CRY_BINARY_XML_FILE_EXT                  					"binxml"
-- #define CRY_XML_FILE_EXT                         						"xml"
-- #define CRY_CHARACTER_PARAM_FILE_EXT            				 "chrparams"
-- #define CRY_GEOM_CACHE_FILE_EXT                  					"cax"

--////////////////////////////////////////////////////////////////////////////////////////

global g_scriptsDefault 		= getdir #scripts
global g_max_version 			= ((MaxVersion())[1])/1000

fn reset_max =
(
	----------------------------------------------------------------------
	resetMaxFile #noPrompt
	actionMan.executeAction 0 "40829" 			-- show statistics
	actionMan.executeAction -844228238 "12"  	-- Viewport Lighting and Shadows: High Quality
-- 	actionMan.executeAction -844228238 "15" 	-- DX Mode
	----------------------------------------------------------------------
	escapeEnable
	----------------------------------------------------------------------
	
	if GetQuietMode() then
	(
		SetQuietMode false --we want prompts enabled
	)
)

if  g_max_version >= 19 then --MAX 2017 or higher required
(
	clearlistener()
	
	Format "Max Version: %\n" g_max_version

	reset_max()

	--//////////////////////////////// Script Checker (Runs on Startup ////////////////////////////////
	--///////////////////////////////////////////////////////////////////////////////////////////////
	---------------------------------------- ini Global - hardcoded filename ----------------------------------------
	global g_iniFileName 				= "cryimport_v3.ini"
	global g_iniFile 						= (	pathConfig.ResolvePathSymbols (pathConfig.AppendPath 	sysInfo.tempdir	 g_iniFileName)	)
	
	--Create the ini file if it does not exist
	if NOT doesfileexist ::g_iniFile then
	(
		try
		(
			global ini = createFile ::g_iniFile
			close ini
		)
		catch
		(
			format "%" (getCurrentException())
		)
	)
	
	if doesfileexist ::g_iniFile then
	(
		-------------------------------------------------------------------------------------------------------------------
		global g_dirpath 				= "" -- Path to the GameSDK ( WITHOUT the slash \ or / )
		global g_scriptRoot 			= ""
		global g_includePath 		= ""	
		fn delete_ini =
		(
			if NOT deleteFile ::g_iniFile then
			(
				delIniSetting 	::g_iniFile 	"paths" "scriptRoot" 			::g_scriptRoot
				delIniSetting 	::g_iniFile 	"paths" "g_includePath" 	::g_includePath
			)
		)
		--/////////////////////////////////////////////////////////////////////////////////////////
		try
		(
			g_dirPath 					= getINISetting 	::g_iniFile 	"paths" 	"g_dirpath"
			g_scriptRoot 				= getINISetting 	::g_iniFile 	"paths" 	"scriptRoot"
			g_includePath 				= getINISetting 	::g_iniFile 	"paths" 	"g_includePath"
			
			setINISetting 	::g_iniFile 		"paths" 		"g_scriptsDefault" 		::g_scriptsDefault
		)
		catch
		(
			format "%" (getCurrentException())
		)
		--/////////////////////////////////////////////////////////////////////////////////////////
		
		
		g_dirpath 						= getINISetting 	g_iniFile 	"paths" "g_dirpath"	
		if g_dirpath == "" then
		(
			local set_dirPath = queryBox "You will now be asked to navigate to the root of your game folder (you will only do this once)...continue?"
			
			if set_dirPath then
			(
				::g_dirpath 		= getSavePath caption:"Choose the Root for the Game (example \GameSDK\Ryse)"					
				if ::g_dirpath != undefined AND pathConfig.isLegalPath g_dirpath then
				(
					setINISetting ::g_iniFile "paths" "g_dirpath" ::g_dirpath
				)
				else
				(
					::g_dirpath 			= ""
				)
			)
			else
			(
				::g_dirpath 			= ""
			)
		)
		-------------------------------------------------------------------------------------------------------------------

		if doesfileexist g_dirpath then
		(
			::g_scriptRoot 				= getINISetting 	::g_iniFile 	"paths" 	"scriptRoot"
			::g_includePath 				= getINISetting 	::g_iniFile 	"paths" 	"g_includePath"

			if ::g_scriptRoot == "" OR ::g_includePath == ""  then
			(
				local set_scriptPath = queryBox "Navigate to the folder which contains this script that you are just running(you will only do this once)...continue?" beep:true
				
				if set_scriptPath then
				(
					::g_scriptRoot 			= pathConfig.resolvePathSymbols ((getSavePath caption:"Choose Script Root Directory (the dir where you placed the scripts)" initialDir:sysinfo.currentDir))
					::g_includePath 			= pathConfig.resolvePathSymbols (::g_scriptRoot + "\\include")
					
					if ::g_scriptRoot != undefined AND ::g_includePath != undefined then
					(	
						if 	doesFileExist ::g_includePath AND \			
							doesFileExist (	pathConfig.resolvePathSymbols (::g_scriptRoot + "\\ui_.ms")	) then
						(
							setINISetting 	::g_iniFile 	"paths" "scriptRoot" 			::g_scriptRoot
							setINISetting 	::g_iniFile 	"paths" "g_includePath" 	::g_includePath
							
							messageBox "All set, you are now ready to go - all settings are saved" title:"Success" beep:false
						)
					)
					else
					(
						::g_scriptRoot 			= ""
						::g_includePath 			= ""
					)
				)
				else
				(
					::g_scriptRoot 			= ""
					::g_includePath 			= ""
				)
			)
		)
		--/////////////////////////////////////////////////////////////////////////////////////////////////
		--/////////////////////////////////////////////////////////////////////////////////////////////////


		--////////////////////// Preprocessing - Checks that our includes do indeed exist //////////////////////
		fn includes_Exist \
								&includeDir: \						
								&include_files: = --we pass a pointer here
		(
			if symbolicPaths.isPathName "$scripts" then
			(
			)
			else
			(
				return false;
			)
			
			local files = getFiles (includeDir + "*.*")
			
			for f in files do
			(
				local fname = filenamefrompath f --strip the filename from the path (so we get only the filename + its suffix)
					
				for inclF in include_files do
				(
					--At least one fail, will be enough to terminate the whole execution of this importer script
					if (stricmp fname inclF) != 0 then
					(
						--//////////// We do a few backup checks, to keep it less rigorous and more tolerant ////////////
						local deepCheck = findItem files fname
						if deepCheck != 0 then
						(
							continue;
						)
						else --even less rigorous
						(
							local backupCheck = (matchpattern inclF pattern:"*"+fname+"*")
							if backupCheck then
							(
								continue;
							)						
						)
						--Being more tolerant than the above is not desired
						--///////////////////////////////////////////////////////////////////////////////////////////
						
						------------------------------------------------ *** *** ***--------------------------------------------------
						--*** *** *** Every check failed and the script will not be able to continue, because reaching this point, will lead to dependencies loading failure! *** *** ***
						--*** *** *** This is serious, and will lead to a sure failure *** *** ***
						format "WARNING - We could not confirm the existence of the include files - execution will be aborted\n"
						return false;
						------------------------------------------------ *** *** ***--------------------------------------------------
					)
				)			
			)
			--if we came here, then all the include files are present, and we can include them
			return true;
		)
		--//////////////////////////////////////////////////////////////////////////////////////////////////


		if 	doesFileExist ::g_includePath AND \
			doesFileExist ( pathConfig.resolvePathSymbols (::g_scriptRoot + "\\ui_.ms") ) AND \
			(isDirectoryWriteable sysInfo.tempdir) then
		(
			try
			(				
				----------------------------------------------------
				--set the system script path to the chosen one (otherwise, the included files will not be found)
				if (setdir #scripts ::g_includePath)	then
				(
					----------------------------------------------------				
					format "----------------->::g_includePath: %\n" ::g_includePath
					format "-----------------> getdir #scripts: %\n" (getdir #scripts)
					--If we add more includes to our project (see include calls below), we must add them to this array as well
					local include_files = #(
													"HEADER_.ms", \
													"general_functions_.ms", \
													"build_resource_db_.ms", \
													"CryMat_XMLB_headers_.ms", \
													"CryMat_XMLB_.ms", \
													"CryMat_XML_headers_.ms", \
													"CryMat_XML_.ms", \
													"store_reports_.ms", \
													"cryxmlB_loader_.ms", \
													
													"skinwrap_.ms", \
													"create_bones_.ms", \
													"BUILDERS_.ms", \
													"init_Builders_.ms", \
													"load_cryHeaders_.ms", \
													"load_cryFile_.ms", \											
													"CAF_headers_.ms", \
													"load_CAF_.ms", \
													"load_chrparams_.ms", \
													"cryFile_btn_loader_.ms" \
												)	
												
					local FOUND_DEPENDENCIES = includes_Exist \
																					includeDir:		&::g_includePath \
																					include_files:	&include_files
						
					--Preprocessing - Checks that our includes do indeed exist		
					if FOUND_DEPENDENCIES AND \
						(getdir #scripts) == ::g_includePath  then
					(			
						--////////////////// Include //////////////////						
						include "HEADER_.ms"
						include "general_functions_.ms"
						include "build_resource_db_.ms"
						include "CryMat_XMLB_headers_.ms"
						include "CryMat_XML_headers_.ms"
						include "CryMat_XML_.ms"						
						include "CryMat_XMLB_.ms"
						include "store_reports_.ms"
						include "cryxmlB_loader_.ms"
						--////////////////////////////////////////////

						try
						(
							--/////// Destroy dialogs and rollout clauses if applicable ///////					
							if ::cryImport != undefined then
							(
								if iskindof ::cryImport RolloutClass then
								(
									DestroyDialog 			::cryImport
								)
							)
							if ::rollout_Tools != undefined then
							(
								if iskindof ::rollout_Tools RolloutClass then
								(
									DestroyDialog 			::rollout_Tools
								)
							)							
							if ::rollout_options != undefined then
							(
								if iskindof ::rollout_options RolloutClass then
								(
									DestroyDialog 			::rollout_options
								)
							)
							if ::rollout_Mesh_Options != undefined then
							(
								if iskindof ::rollout_Mesh_Options RolloutClass then
								(
									DestroyDialog 			::rollout_Mesh_Options
								)
							)							
							if ::rollout_Report != undefined then
							(
								if iskindof ::rollout_Report RolloutClass then
								(
									DestroyDialog 			::rollout_Report
								)
							)
							if ::rollout_animation != undefined then
							(
								if iskindof ::rollout_animation RolloutClass then
								(
									DestroyDialog 			::rollout_animation
								)
							)
							if ::rollout_About != undefined then
							(
								if iskindof ::rollout_About RolloutClass then
								(
									DestroyDialog 			::rollout_About
								)
							)
							if ::rollout_Alert != undefined then
							(
								if iskindof ::rollout_Alert RolloutClass then
								(
									DestroyDialog 			::rollout_Alert
								)
							)
							----------------------------The Rollout Floater ----------------------------
							if ::CRYOP != undefined then
							(
								if iskindof ::CRYOP RolloutFloater then
								(
									closeRolloutFloater  			::CRYOP
								)
							)
							--//// End of  Destroy dialogs and rollout clauses if applicable ////						
						)
						catch
						(
							format "\n*** *** *** *** *** *** Could not destroy dialogs *** *** *** *** *** ***\n"
							format "%" (getCurrentException())
							format "*** *** *** *** *** *** END OF Could not destroy dialogs *** *** *** *** *** *** ***\n"
						)

						rollout cryImport "Cryengine Importer" width:290 height:170 category:3
						(
							button 'btn_view_ini' "View ini" pos:[177,4] width:96 height:25 align:#left
							button 'btn_delete_ini' "del" pos:[152,4] width:25 height:25 align:#left tooltip:"Delete ini file" images:#((	(getdir #maxSysIcons) + "Dark\\Grips\\Cancel_24.png"	), (	(getdir #maxSysIcons) + "Dark\\Grips\\Cancel_24.png"	), 1, 1, 1, 1, 1, false)
							label 'lbl_version' "Cryengine Importer v 1.0" pos:[20,8] width:130 height:19 align:#left
							button 'btn_gameDir' "Set Game Directory (GameSDK)..." pos:[8,37] width:265 height:25 toolTip:"This must be the root of your GameSDK for example ...\GameSDK\Ryse (note - do this only if you want to change the dir, this should be set correctly already" align:#left
							button 'btn_Set_SkeletonListXML' "Set SkeletonList.xml..." pos:[8,62] width:265 height:25 toolTip:"This is done automatically - Default for example is ...\GameSDK\Ryse\Animations\SkeletonList.xml" align:#left
							label 'lbl_skeletonList_Loaded' "" pos:[11,90] width:150 height:17 align:#left
							button 'btn_print_SkeletonList' "Print Skeleton List" pos:[165,87] width:108 height:25 align:#left
							button 'btn_clearConsole' "Clear Console" pos:[165,112] width:108 height:25 align:#left
							
							checkbox 'chk_skip_chr' "Don't load .chr" pos:[13,115] width:120 height:19 enabled:true checked:true align:#left
							checkbox 'chk_Force_2_Base_Skeleton' "Force to Base Skeleton" pos:[13,135] width:150 height:19 enabled:true checked:true align:#left tooltip:"Recommended ON - but if you want to load multiple skeletons into a scene, then turn this off"
							checkbox 'chk_reset' "Reset before skin load" pos:[13,155] width:120 height:19 enabled:true checked:true align:#left	
							button 'btn_import' "LOAD CryFile..." pos:[8,118+60] width:265 height:40 toolTip:"Load CryFile (.cgf, .cgfm, .cga, .cgam, .chr, .chrm, .skin, .skinm)" align:#left
							button 'btn_Load_CDF' "LOAD Character Definition..." pos:[8,158+60] width:265 height:40 toolTip:"This loads the Character Definition File ( .cdf )" align:#left							
							
							checkbox 'chk_deleteISOvertices' "Delete Isolated Vertices" pos:[13,265] width:259 height:19 enabled:true checked:true align:#left							
							checkbox 'chk_Dont_Load_Skeleton' "Don't Load Skeleton" pos:[13,285] width:259 height:19 enabled:true checked:false align:#left
							checkbox 'chk_Skip_LOD_Materials' "Skip $Lod Materials" pos:[13,305] width:125 height:19 enabled:true checked:false align:#left
							checkbox 'chk_Skip_Proxy_Materials' "Skip Proxy Materials" pos:[150,305] width:252 height:19 enabled:false checked:false align:#left visible:false
							
							dropdownList 'ddl_CryGame' "CryEngine Game" pos:[8,340] width:265 height:40 items:#("Ryse", "Crysis(wip)", "Crysis 2(wip)", "Crysis 3(wip)", "Crysis Warhead(wip)", "Crysis Wars(wip)", "State of Decay(wip)", "HFR", "Armored Warfare") align:#left enabled:true selection:8
							
							--////////////////// Include //////////////////
							include "skinwrap_.ms"
							include "create_bones_.ms"
							include "BUILDERS_.ms"
							include "init_Builders_.ms"
							include "load_cryHeaders_.ms"
							include "load_cryFile_.ms"
								
							include "CAF_headers_.ms"
							include "load_CAF_.ms"
							include "load_chrparams_.ms"
							include "cryFile_btn_loader_.ms"
							--/////////////////////////////////////////////
							
							on cryImport open do
							(	
								update_dirPath \
														context:"global"
								
								if ::g_auto_resourcelist_array.count == 0 then
								(
									::g_auto_resourcelist_array = getFilesRecursive \
																									root:			(::g_dirPath) \
																									specDir:		"Levels" \
																									targetFile:	"auto_resourcelist.txt"
								)
								
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
								
								format "-----------------------------::g_scriptRoot: % -----------------------------\n" ::g_scriptRoot
								
								::g_CryGame_dropDown_selection 	= ddl_CryGame.items[ddl_CryGame.selection]
								::g_skip_Lod_Materials					= chk_skip_Lod_Materials.state
								::g_Dont_Load_Skeleton				= chk_Dont_Load_Skeleton.state
								::g_dirpath 									= getINISetting ::g_iniFile "paths" "g_dirpath"
								
								local skeleton_xml_path 				= ""
								
								--////////////////////////// Set SkeletonList.xml and also attempt to read it into an array ///////////////////////////
								if pathConfig.isLegalPath ::g_dirpath then
								(
									local skeleton_xml_path 		= pathConfig.appendPath 	::g_dirpath 		::g_SkeletonList_xml_NAME						
									
									if skeleton_xml_path != undefined then
									(
										format "Will try to find and read: %\n" skeleton_xml_path
										
										if doesfileexist skeleton_xml_path then
										(
											setINISetting 	::g_iniFile 	"paths" "SkeletonList" 	skeleton_xml_path					
											
											inst_xmlB_PROCESSOR = xmlB_PROCESSOR()
											--XML
											if (stricmp (getFilenameType skeleton_xml_path) ".xml") == 0 then
											(
												if Binary_XML_check skeleton_xml_path then
												(
													global g_inst_stored_SkeletonList_XML	= stored_SkeletonList_XML ()	
													format "Attempting to read: %\n" (getFilenameType skeleton_xml_path)
													inst_xmlB_PROCESSOR.cry_general_xmlB_ReaderV \
																														xmlBFile:					skeleton_xml_path \
																														inst_s_OPTIONS:		inst_s_OPTIONS \
																														type:						".xml"
													
													btn_print_SkeletonList.enabled = true
													skeleton_xml_path = ""
													::cryImport.lbl_skeletonList_Loaded.text = "Skeleton List has been loaded"
												)
												else
												(
													btn_print_SkeletonList.enabled = false
													format "This is not a valid xmlB file, aborting!: %\n" skeleton_xml_path
													::cryImport.lbl_skeletonList_Loaded.text = "Could not locate the Skeleton List"
												)
											)
											else
											(
												btn_print_SkeletonList.enabled = false
												format "The suffix of the SkeletonList is not .xml: %\n" skeleton_xml_path
												::cryImport.lbl_skeletonList_Loaded.text = "Could not locate the Skeleton List"
											)
										)
										else
										(
											btn_print_SkeletonList.enabled = false
											format "Cannot find: %\n" skeleton_xml_path
											::cryImport.lbl_skeletonList_Loaded.text = "Could not locate the Skeleton List"
										)
									)
									else
									(
										btn_print_SkeletonList.enabled = false
										format "Could not find: %\n" skeleton_xml_path
										::cryImport.lbl_skeletonList_Loaded.text = "Could not locate the Skeleton List"
									)			
								)
								--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
								
								format "g_skip_Lod_Materials: %\n" 							::g_skip_Lod_Materials
								format "\nGame selected: --------- % ---------\n" 		::g_CryGame_dropDown_selection
								format "Skeleton List Path: %\n" 								(pathConfig.appendPath ::g_dirpath ::g_SkeletonList_xml_NAME)
								format "g_Dont_Load_Skeleton: %\n" 							::g_Dont_Load_Skeleton
								format "======= GameSDK path: % =======\n" 			::g_dirpath
							)
							on cryImport close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
								gc()
							)
							on cryImport rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-cryImport.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+cryImport.height]
								)
							)				
							on btn_delete_ini pressed do
							(
								if (queryBox "This will delete your settings, are you sure you want to continue?") then
								(
									if (deleteFile ::g_iniFile) then
									(
										format "% deleted!\n" ::g_iniFile
									)
									else
									(
										format "Could not delete % \n" ::g_iniFile
									)
								)
							)
							on btn_gameDir pressed do
							(
								startDir = undefined							
								g_dirpath 			= getINISetting ::g_iniFile "paths" "g_dirpath"
							
								if pathConfig.isLegalPath g_dirpath then
								(
									startDir = g_dirpath
									::g_dirpath 		= getSavePath caption:"Choose Game directory" initialDir:startDir
								)
								else
								(
									::g_dirpath 		= getSavePath caption:"Choose Game directory"
								)
								--Reread Skeleton List
								if ::g_dirpath != undefined then
								(
									if pathConfig.isLegalPath g_dirpath  then
									(
										setINISetting ::g_iniFile "paths" "g_dirpath" ::g_dirpath
										
										--Set the gamedir for the currently selected game
										setINISetting 	::g_iniFile 	"gameDirs" 	::g_CryGame_dropDown_selection 	::g_dirpath
										
										local skeleton_xml_path 		= pathConfig.appendPath 	::g_dirpath 		::g_SkeletonList_xml_NAME
										
										if skeleton_xml_path != undefined then
										(
											format "Will try to find and read: %\n" skeleton_xml_path
											
											if doesfileexist skeleton_xml_path then
											(
												setINISetting 	::g_iniFile 	"paths" "SkeletonList" 	skeleton_xml_path					
												
												inst_xmlB_PROCESSOR = xmlB_PROCESSOR()
												--XML
												if (stricmp (getFilenameType skeleton_xml_path) ".xml") == 0 then
												(
													if Binary_XML_check skeleton_xml_path then
													(
														::g_inst_stored_SkeletonList_XML	= stored_SkeletonList_XML ()	
														format "Attempting to read: %\n" (getFilenameType skeleton_xml_path)
														inst_xmlB_PROCESSOR.cry_general_xmlB_ReaderV \
																															xmlBFile:					skeleton_xml_path \
																															inst_s_OPTIONS:		inst_s_OPTIONS \
																															type:						".xml"
														
														btn_print_SkeletonList.enabled = true
														skeleton_xml_path = ""
														::cryImport.lbl_skeletonList_Loaded.text = "Skeleton List has been loaded"
													)	
												)			
											)
											else
											(
												btn_print_SkeletonList.enabled = false
												::cryImport.lbl_skeletonList_Loaded.text = "Skeleton List could not be found"
											)
										)
									)
								)
								
							)
							on btn_Set_SkeletonListXML pressed do
							(
								startDir = undefined
								::g_dirpath = getINISetting ::g_iniFile "paths" "g_dirpath"
							
								if pathConfig.isLegalPath ::g_dirpath then
								(
									startDir = ::g_dirpath
									
									SkeletonList_xml_PATH = getOpenFileName \
									caption:"cgf/chr/cgfm Model File" \
									types:"CryTek Model File (*.xml)|*.xml" historyCategory:"CryTek ObjectPresets" initialDir:startDir
									
									if SkeletonList_xml_PATH != undefined then
									(
										if doesfileexist SkeletonList_xml_PATH then
										(
											setINISetting 	::g_iniFile 	"paths" "SkeletonList" 	SkeletonList_xml_PATH						
											::g_SkeletonList_xml_NAME = filenameFromPath SkeletonList_xml_PATH
										)
									)
								)
								else
								(
									::g_dirpath = getSavePath caption:"Choose Game directory"
									
									if ::g_dirpath != undefined AND pathConfig.isLegalPath g_dirpath then
									(
										setINISetting ::g_iniFile "paths" "g_dirpath" ::g_dirpath
										
										startDir = ::g_dirpath
										
										SkeletonList_xml_PATH = getOpenFileName \
										caption:"cgf/chr/cgfm Model File" \
										types:"CryTek Model File (*.xml)|*.xml" historyCategory:"CryTek ObjectPresets" initialDir:startDir
										
										if SkeletonList_xml_PATH != undefined then
										(
											if doesfileexist SkeletonList_xml_PATH then
											(
												setINISetting 	::g_iniFile 	"paths" "SkeletonList" 	SkeletonList_xml_PATH						
												::g_SkeletonList_xml_NAME = filenameFromPath SkeletonList_xml_PATH
											)					
										)
									)
								)
							)
							on btn_print_SkeletonList pressed do
							(								
								print_SkeletonList \
															SkeletonList:&::g_inst_stored_SkeletonList_XML	
							)
							on btn_clearConsole pressed do
							(
								clearlistener()
							)
							on btn_import pressed do
							(
								if GetQuietMode() == false then
								(
									SetQuietMode true --we want prompts enabled
								)
								
								get_game_dirPath()
								update_dirPath()
								
								if NOT (doesfileexist g_dirpath) then
								(
									confirm = yesNoCancelBox "You must choose a root game directory, do you want to do it now?" \
																		title:"WARNING" \
																		beep:true		
									if confirm == #yes then
									(
										::g_dirpath = getSavePath caption:"Choose Game directory"
										
										if ::g_dirpath != undefined AND pathConfig.isLegalPath g_dirpath then
										(
											setINISetting ::g_iniFile "paths" "g_dirpath" ::g_dirpath
											
											--Set the gamedir for the default selected game
											setINISetting ::g_iniFile "gameDirs" g_cryFile ddl_CryGame.items[ddl_CryGame.selection]
										)
									)
								)					
								else
								(
									g_cryFile = getOpenFileName \
									caption:"cgf/chr/cgfm Model File" \
									types:"CryTek Model File (*.cgf)|*.cgf|(*.cga)|*.cga|(*.cgam)|*.cgam|(*.cgfm)|*.cgfm|(*.chr)|*.chr|(*.cdf)|*.cdf|(*.skin)|*.skin|(*.skinm)|*.skinm|(*.chrm)|*.chrm|(*.caf)|*.caf|(*.img)|*.img|All (*.*)|*.*" \
									historyCategory:"CryTek ObjectPresets"
									
									if ddl_CryGame.selected == "Ryse" then
									(
										if g_cryFile != undefined then
										(
											if doesfileexist g_cryFile then
											(
												--Set the gamedir to the global as well -- See function in HEADER_.ms
												get_game_dirPath()
												
												if ((getFilenameType g_cryFile) == ".cgf") OR ((getFilenameType g_cryFile) == ".cgfm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														setINISetting 	::g_iniFile 	"boneinfo" "has_bones" 	"0"
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)					
												)
												if ((getFilenameType g_cryFile) == ".cga") OR ((getFilenameType g_cryFile) == ".cgam") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)	
												)	
												else if ((getFilenameType g_cryFile) == ".skin") OR ((getFilenameType g_cryFile) == ".skinm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)							
												)
												else if ((getFilenameType g_cryFile) == ".chr") OR ((getFilenameType g_cryFile) == ".chrm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)
												)
												else if ((getFilenameType g_cryFile) == ".skel") OR ((getFilenameType g_cryFile) == ".skelm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)
												)
												else if ((getFilenameType g_cryFile) == ".caf") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														cryFile_loader \
																			g_cryFile:	&g_cryFile \
																			caller:		(getFilenameType g_cryFile)
													)
												)
												else if ((getFilenameType g_cryFile) == ".img") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														cryFile_loader \
																			g_cryFile:	&g_cryFile \
																			caller:		(getFilenameType g_cryFile)
													)
												)
												else if (getFilenameType g_cryFile) == ".cdf" then
												(
													if  NOT (Binary_XML_check g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryXmlB file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryxmlB_loader \
																				g_MaterialRef_Bool: &g_MaterialRef_Bool
													)				
												)
											)
										)
									)
									else if ddl_CryGame.selected == "Crysis" then
									(
										if g_cryFile != undefined then
										(
											if doesfileexist g_cryFile then
											(
												--Set the gamedir to the global as well -- See function in HEADER_.ms
												get_game_dirPath()
												
												if ((getFilenameType g_cryFile) == ".cgf") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(			
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)					
												)
											)
										)
									)
									else if ddl_CryGame.selected == "HFR" then
									(
										if g_cryFile != undefined then
										(
											if doesfileexist g_cryFile then
											(
												--Set the gamedir to the global as well -- See function in HEADER_.ms
												get_game_dirPath()
												
												if ((getFilenameType g_cryFile) == ".cgf") OR ((getFilenameType g_cryFile) == ".cgfm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)	
												)
												if ((getFilenameType g_cryFile) == ".cga") OR ((getFilenameType g_cryFile) == ".cgam") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)	
												)	
												else if ((getFilenameType g_cryFile) == ".skin") OR ((getFilenameType g_cryFile) == ".skinm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)							
												)
												else if ((getFilenameType g_cryFile) == ".chr") OR ((getFilenameType g_cryFile) == ".chrm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)
												)
												else if ((getFilenameType g_cryFile) == ".skel") OR ((getFilenameType g_cryFile) == ".skelm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)
												)
												else if ((getFilenameType g_cryFile) == ".caf") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														cryFile_loader \
																			g_cryFile:	&g_cryFile \
																			caller:		(getFilenameType g_cryFile)
													)
												)
												else if ((getFilenameType g_cryFile) == ".img") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														cryFile_loader \
																			g_cryFile:	&g_cryFile \
																			caller:		(getFilenameType g_cryFile)
													)
												)
												else if (getFilenameType g_cryFile) == ".cdf" then
												(
													if  NOT (Binary_XML_check g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryXmlB file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														cryxmlB_loader \
																				g_MaterialRef_Bool: &g_MaterialRef_Bool
													)				
												)
											)	
										)
									)
									else if ddl_CryGame.selected == "Armored Warfare" then
									(
										if g_cryFile != undefined then
										(
											if doesfileexist g_cryFile then
											(
												--Set the gamedir to the global as well -- See function in HEADER_.ms
												get_game_dirPath()
												
												if ((getFilenameType g_cryFile) == ".cgf") OR ((getFilenameType g_cryFile) == ".cgfm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)	
												)	
												if ((getFilenameType g_cryFile) == ".cga") OR ((getFilenameType g_cryFile) == ".cgam") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)	
												)	
												else if ((getFilenameType g_cryFile) == ".skin") OR ((getFilenameType g_cryFile) == ".skinm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
														
														Reset_Arrays()								
														Reset_BoneNodes_arrays()

														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)							
												)
												else if ((getFilenameType g_cryFile) == ".chr") OR ((getFilenameType g_cryFile) == ".chrm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)
												)
												else if ((getFilenameType g_cryFile) == ".skel") OR ((getFilenameType g_cryFile) == ".skelm") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														---------------------------- Create Instance Structs ----------------------------
														--We start this storage here
														local inst_Sub_Meshes 			= Sub_Meshes()
														local inst_CDF_Attachment 		= CDF_Attachment() 	--create instance of Attachment nodes
														local inst_CDF_Modifiers			= CDF_Modifiers() 		--create instance of Modifiers nodes
														local inst_CDF_Model				= CDF_Model()
														--------------------------------------------------------------------------------------	
														
														cryFile_loader \
																			inst_Sub_Meshes: 			&inst_Sub_Meshes \
																			g_cryFile:						&g_cryFile \
																			inst_Sub_Meshes:			&inst_Sub_Meshes \
																			inst_CDF_Model:				&inst_CDF_Model \
																			inst_CDF_Attachment:		&inst_CDF_Attachment \
																			inst_CDF_Modifiers:			&inst_CDF_Modifiers
													)
												)
												else if ((getFilenameType g_cryFile) == ".caf") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														cryFile_loader \
																			g_cryFile:	&g_cryFile \
																			caller:		(getFilenameType g_cryFile)
													)
												)
												else if ((getFilenameType g_cryFile) == ".img") then
												(
													if  NOT (Binary_CryTek_check File:g_cryFile) then --if the xml file is not Crytek Binary XML
													(
														format "This is not a valid CryTek file, aborting!\n"
													)
													else
													(
														cryFile_loader \
																			g_cryFile:	&g_cryFile \
																			caller:		(getFilenameType g_cryFile)
													)
												)
												else if (getFilenameType g_cryFile) == ".cdf" then
												(
-- 													if  NOT (Binary_XML_check g_cryFile) then --if the xml file is not Crytek Binary XML
-- 													(
-- 														format "This is not a valid CryXmlB file, aborting!\n"
-- 													)
-- 													else
-- 													(
														if chk_reset.state then
														(
															reset_max()
														)
																	
														Reset_Arrays()								
														Reset_BoneNodes_arrays()
														
														cryxmlB_loader \
																				g_MaterialRef_Bool: &g_MaterialRef_Bool
-- 													)				
												)
											)	
										)
									)
								)
							)
							on btn_view_ini pressed do
							(
								try
								(
									ShellLaunch "notepad.exe" ::g_iniFile
								)
								catch()
							)
							on chk_reset changed arg do
							(
								format "% chk_reset\n" arg
							)
							on btn_Load_CDF pressed do
							(
								if GetQuietMode() == false then
								(
									SetQuietMode true --we want prompts enabled
								)
								
								::g_db_type = "mtl" --we set the default mtl library
							
								get_game_dirPath()
								update_dirPath()
								
								if ddl_CryGame.selected == "Armored Warfare" then
								(
									if doesfileexist g_dirpath then
									(
										g_cryFile = getOpenFileName \
										caption:"cgf/chr/cgfm Model File" \
										types:"CryTek Character Definition File (*.cdf)|*.cdf|(*.chrparams)|*.chrparams|(*.xml)|*.xml|All (*.*)|*.*" \
										historyCategory:"CryTek ObjectPresets"
										
										if g_cryFile != undefined then
										(			
											if doesfileexist g_cryFile then
											(
												if chk_reset.state then
												(
													reset_max()
												)
												
												Reset_Arrays()
												Reset_BoneNodes_arrays
												
												if (stricmp (getFilenameType g_cryFile) ".cdf" ) == 0 OR \
													(stricmp (getFilenameType g_cryFile) ".chrparams" ) == 0 then
												(
-- 													if  (Binary_XML_custom_check file:g_cryFile type:"CryXmlB") then --if the xml file is not Crytek Binary XML				
-- 													(
														cryFile_CDF_loader g_cryFile:	&g_cryFile
-- 													)
-- 													else
-- 													(
-- 														format "This is not a valid CryXmlB file, aborting!\n"
-- 													)
												)
												else
												(
													format "Seem that this is not a valid CDF file, aborting! \nIf you are trying to read an xmlB file, then use the button \"xmlB Reader...\" instead.\n"
												)
											)
										)
									)
								)
								else
								(
									if doesfileexist g_dirpath then
									(
										g_cryFile = getOpenFileName \
										caption:"cgf/chr/cgfm Model File" \
										types:"CryTek Character Definition File (*.cdf)|*.cdf|(*.chrparams)|*.chrparams|(*.xml)|*.xml|All (*.*)|*.*" \
										historyCategory:"CryTek ObjectPresets"
										
										if g_cryFile != undefined then
										(			
											if doesfileexist g_cryFile then
											(
												if chk_reset.state then
												(
													reset_max()
												)
												
												Reset_Arrays()
												Reset_BoneNodes_arrays
												
												if (stricmp (getFilenameType g_cryFile) ".cdf" ) == 0 OR \
													(stricmp (getFilenameType g_cryFile) ".chrparams" ) == 0 then
												(
													if  (Binary_XML_custom_check file:g_cryFile type:"CryXmlB") then --if the xml file is not Crytek Binary XML				
													(
														cryFile_CDF_loader g_cryFile:	&g_cryFile
													)
													else
													(
														format "This is not a valid CryXmlB file, aborting!\n"
													)
												)
												else
												(
													format "Seem that this is not a valid CDF file, aborting! \nIf you are trying to read an xmlB file, then use the button \"xmlB Reader...\" instead.\n"
												)
											)
										)
									)
								)
							)
							on chk_deleteISOvertices changed arg do
							(
								format "% chk_deleteISOvertices\n" arg
							)
							on chk_Dont_Load_Skeleton changed arg do
							(
								::g_Dont_Load_Skeleton = chk_Dont_Load_Skeleton.state
								
								format "% g_Dont_Load_Skeleton\n" 			::g_Dont_Load_Skeleton
							)
							on chk_Skip_LOD_Materials changed arg do
							(
								::g_skip_Lod_Materials = chk_Skip_LOD_Materials.state
								
								format "% g_skip_Lod_Materials\n" 			::g_skip_Lod_Materials
							)
							on ddl_CryGame selected arg do
							(
								::g_CryGame_dropDown_selection = ddl_CryGame.items[arg]
								
								if (getINISetting ::g_iniFile "gameDirs" ddl_CryGame.items[ddl_CryGame.selection]) != "" then --try to get the gamedir
								(
									::g_dirpath = getINISetting ::g_iniFile "gameDirs" ddl_CryGame.items[ddl_CryGame.selection]
									setINISetting ::g_iniFile "paths" "g_dirpath" ::g_dirpath --update the ini
								)
								
								format "% selected\n" ::g_CryGame_dropDown_selection
								format "% gameDir path: %\n" ::g_CryGame_dropDown_selection ::g_dirpath
							)
						)	
						
						rollout rollout_Tools "Tools" width:290 height:95 category:4
						(
							button 'btn_xmlB_Reader' "xmlB Reader..." pos:[8,10] width:133 height:25 toolTip:"Examine an xmlB file" align:#left
							button 'btn_CAF_reader' "CAF Reader..." pos:[142,35] width:133 height:25 enabled:false toolTip:"Not implemented yet" align:#left
							button 'btn_xml_Reader' "xml Reader..." pos:[8,35] width:133 height:25 toolTip:"Examine an xml file" align:#left	
							
							GroupBox 'grp_db_builder' "Create Database from CryTek Resource Lists" pos:[9,88] width:265 height:110 align:#left
							button 'btn_build_mtl_db' "Build .mtl db" pos:[20,110] width:121 height:25 toolTip:"Build an .mtl database" align:#left
							button 'btn_build_tif_db' "Build .tif db" pos:[142,110] width:121 height:25 toolTip:"Build a .tif database" align:#left
							button 'btn_build_dds_db' "Build .dds db" pos:[20,135] width:121 height:25 toolTip:"Build a .dds0 database" align:#left
							
							button 'btn_set_ResourceList' "Set Custom Resource List" pos:[20,160] width:217 height:25 align:#left
							checkButton 'ckb_use_custom_ResourceList' "" pos:[237,160] width:25 height:25 align:#left tooltip:"Check to use the custom Resource List" \
							images:#((	(getdir #maxSysIcons) + "Dark\\Grips\\Check_off_18.png"	), undefined, 1, 1, 1, 1, 1, false) highlightColor:[100, 100, 100]
							
							GroupBox 'grp_db_builder_scan' "Create Database Scanning Game Root" pos:[9,210] width:265 height:55 align:#left
							button 'btn_set_scanBuild' "Build SCAN DB" pos:[20,232] width:245 height:25 align:#left
							
							fn db_creation_ask \
														caller: \
														&db_type: =
							(	
								local db_filename = (db_type as string) +"_db.txt"
								
								local confirm = #no	
								if doesfileexist (pathConfig.resolvePathSymbols (pathConfig.AppendPath (pathConfig.AppendPath ::g_scriptRoot "\\db") db_filename)) then
								(
									confirm = yesNoCancelBox (db_filename + " already exists - continue?") \
																			title:"WARNING" \
																			beep:true
								)
								else
								(
									confirm = #yes
								)
								
								if confirm == #yes then
								(
									if caller == unsupplied then
									(
										::g_db_type = db_type
										inst_build_resource_db 			= build_resource_db() --create instance
										inst_build_resource_db.builder \
																					g_db_type: &::g_db_type
									)
									else if (stricmp caller "scan") == 0 then
									(										
										local confirm = #no	
										if  doesfileexist (pathConfig.resolvePathSymbols (pathConfig.AppendPath (pathConfig.AppendPath ::g_scriptRoot "\\db") "mtl_db.txt")) OR \
											doesfileexist (pathConfig.resolvePathSymbols (pathConfig.AppendPath (pathConfig.AppendPath ::g_scriptRoot "\\db") "dds_db.txt")) then
										(
											confirm = yesNoCancelBox (db_filename + " already exists - continue?") \
																					title:"WARNING" \
																					beep:true
										)
										
										if confirm == #yes then
										(
											inst_build_resource_db 			= build_resource_db() --create instance
											inst_build_resource_db.SCAN_builder()
										)
									)
								)
							)
							
							fn ckb_resourceList_control \
																	state: =
							(
								local image_off_arr = #((	(getdir #maxSysIcons) + "Dark\\Grips\\Check_off_18.png" ), undefined, 1, 1, 1, 1, 1, false)
								local image_on_arr = #((	(getdir #maxSysIcons) + "Dark\\Grips\\Check_18.png" ), undefined, 1, 1, 1, 1, 1, false)
										
								if state == off then
								(
									ckb_use_custom_ResourceList.images = image_off_arr
									ckb_use_custom_ResourceList.images = image_off_arr
								)
								else
								(
									ckb_use_custom_ResourceList.images = image_on_arr
									ckb_use_custom_ResourceList.images = image_on_arr
								)
							)
							
							on rollout_Tools open do
							(								
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)
							on rollout_Tools close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)
							on rollout_Tools rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_Tools.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_Tools.height]
								)
							)
							
							on btn_xmlB_Reader pressed do
							(
								g_dirpath = getINISetting ::g_iniFile "paths" "g_dirpath"
								
								if NOT (doesfileexist g_dirpath) then
								(
									confirm = yesNoCancelBox "You must choose a root game directory, do you want to do it now?" \
																		title:"WARNING" \
																		beep:true
								
									if confirm == #yes then
									(
										::g_dirpath = getSavePath caption:"Choose Game directory"
									)
								)
								
								g_cryFile = getOpenFileName \
								caption:"cgf/chr/cgfm Model File" \
								types:"CryTek MTL (*.mtl)|*.mtl|(*.xml)|*.xml|(*.cdf)|*.cdf|(*.chrparams)|*.chrparams| \
								All (*.*)|*.*" \
								historyCategory:"CryTek ObjectPresets"
								
								if ::g_cryFile != undefined AND doesfileexist g_cryFile then
								(
									local init_state 										= ::rollout_Report.chk_xmlB_Report_v2.state
									::rollout_Report.chk_xmlB_Report_v2.state 	= true --override
									::g_xmlB_Report_v2 									= ::rollout_Report.chk_xmlB_Report_v2.state
									-----------------------------------------------
									
									setINISetting ::g_iniFile "paths" "last_loaded" g_cryFile
									
									cryxmlB_loader \
														g_MaterialRef_Bool:		&g_MaterialRef_Bool \
									
									------------------------------------------------
									::rollout_Report.chk_xmlB_Report_v2.state 	= init_state --restore overriden value
									::g_xmlB_Report_v2 									= init_state
								)								
							)
							on btn_xml_Reader pressed do
							(
								g_dirpath = getINISetting ::g_iniFile "paths" "g_dirpath"
								
								if NOT (doesfileexist g_dirpath) then
								(
									confirm = yesNoCancelBox "You must choose a root game directory, do you want to do it now?" \
																		title:"WARNING" \
																		beep:true
								
									if confirm == #yes then
									(
										::g_dirpath = getSavePath caption:"Choose Game directory"
									)
								)
								
								g_cryFile = getOpenFileName \
								caption:"cgf/chr/cgfm Model File" \
								types:"CryTek MTL (*.mtl)|*.mtl|(*.xml)|*.xml|(*.cdf)|*.cdf|(*.chrparams)|*.chrparams|All (*.*)|*.*" \
								historyCategory:"CryTek ObjectPresets"
								
								if ::g_cryFile != undefined AND doesfileexist g_cryFile then
								(
									try
									(
										examine_XML \
														g_cryFile: &g_cryFile
									)
									catch()
								)								
							)
							on btn_CAF_reader pressed do
							(
								--Not implemented yet
							)							
							on btn_build_mtl_db pressed do
							(
								::g_db_type = "mtl"
								db_creation_ask \
														db_type: &::g_db_type
							)
							on btn_build_tif_db pressed do
							(
								::g_db_type = "tif"								
								db_creation_ask \
														db_type: &::g_db_type
							)
							on btn_build_dds_db pressed do
							(
								::g_db_type = "dds"
								db_creation_ask \
														db_type: &::g_db_type
							)	
							on btn_set_ResourceList pressed do
							(
								local list = getOpenFileName \
								caption:"Resource File" \
								types:"CryTek Resource List (*.txt)|*.txt|All (*.*)|*.*" \
								historyCategory:"CryTek ObjectPresets"
								
								if list != undefined then
								(
									if doesFileExist list then
									(
										if matchpattern list pattern:"*perlayer*" then
										(
											Appendifunique 		::inst_ResourceLists.perLayer 			list
										)
										else if matchpattern list pattern:"auto_*" then
										(
											Appendifunique 		::inst_ResourceLists.auto 					list
										)
										else if matchpattern list pattern:"*resourcelist*" then
										(
											Appendifunique		::inst_ResourceLists.resourceList 		list
										)
										
										--Report
										print inst_ResourceLists
										
										----------------------Activate the check button----------------------
										ckb_use_custom_ResourceList.checked = true
										
										ckb_resourceList_control \
																			state:ckb_use_custom_ResourceList.state
										----------------------------------------------------------------------------
									)
								)								
							)
							on ckb_use_custom_ResourceList changed state do
							(
								ckb_resourceList_control \
																	state:ckb_use_custom_ResourceList.state
							)
							on btn_set_scanBuild pressed do
							(
								db_creation_ask \
														caller: 		"scan"
							)	
						)	
						
						rollout rollout_options "Material Options" width:290 height:100 category:1
						(
							checkbox 'chk_BuildMaterial' "Build Material" pos:[15,5] width:265 height:16 checked:true align:#left
							
							checkbox 'chk_PhysicalMaterialTypes' "Use Physical Material Surface Types" pos:[15,30] width:265 height:16 checked:false align:#left
							checkbox 'chk_Physical_Material' "Physical Material" pos:[15,45] width:248 height:22 checked:true enabled:false toolTip:"If unchecked, Standard Material is used instead (NOT recommended, because it is still highly VIP - Keep it physical)" align:#left
							checkbox 'chk_UVW_Flip_V' "UVW - Flip V" pos:[15,65] width:107 height:16 checked:true align:#left		
							GroupBox 'grp_Options' "Texture Rename" pos:[9,90] width:265 height:55 align:#left
							checkbox 'chk_dds' "Rename .tif* to .dds" pos:[17,110] width:114 height:21 enabled:true checked:true align:#left
							spinner 'spn_Spec_Map_Amount' "Specular Map Output Amount: " pos:[15,155] width:112 height:16 enabled:false range:[-100,100,-17] type:#float scale:0.1 align:#left
							spinner 'spn_displacement_map_amt' "Displacement Map Amount: " pos:[15,175] width:112 height:16 enabled:false range:[-100,100,0.1] type:#float scale:0.1 align:#left
							checkbox 'chk_PhysMat_SSS' "Use Subsurface Scattering / Skin Shader" pos:[15,210] width:265 height:16 checked:false align:#left
							checkbox 'chk_deepSearch' "Use Deep Search" pos:[15,230] width:265 height:16 checked:false align:#left
							checkbox 'chk_quickMTL_Match' "Use Quick .mtl Match" pos:[15,250] width:265 height:16 checked:true align:#left
							checkbox 'chk_MaterialRef' "MaterialRef" pos:[15,270] width:265 height:16 checked:true align:#left
							
							on rollout_options open do
							(								
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
								
								::g_dds 						= chk_dds.state
								::g_Physical_Material	= chk_Physical_Material.state
								::g_UVW_Flip_V			= chk_UVW_Flip_V.state
								
								format "\n-----Material Options: -----\n"
								format "g_dds % \n" 										::g_dds
								format "g_Physical_Material % \n" 						::g_Physical_Material
								format "chk_UVW_Flip_V % \n" 							::g_UVW_Flip_V
								
								format "chk_PhysMat_SSS % \n" 						chk_PhysMat_SSS.state
								format "chk_deepSearch % \n" 							chk_deepSearch.state
								format "chk_quickMTL_Match % \n" 					chk_quickMTL_Match.state
								format "chk_MaterialRef % \n" 							chk_MaterialRef.state
								format "chk_BuildMaterial % \n" 							chk_BuildMaterial.state								
								
								if ::g_Physical_Material then
								(
									spn_Spec_Map_Amount.enabled 		= true
									spn_displacement_map_amt.enabled 	= true
								)
								else
								(
									spn_Spec_Map_Amount.enabled 		= false
									spn_displacement_map_amt.enabled 	= false
								)
								::inst_PHYS_MAT_ADJUST.spec_output_amount = spn_Spec_Map_Amount.value
								
								if chk_BuildMaterial.state then
								(
-- 									chk_Physical_Material.enabled 	= true
									grp_Options.enabled					= true
									chk_UVW_Flip_V.enabled 			= true
									chk_PhysMat_SSS.enabled 		= true
									chk_deepSearch.enabled 			= true
									chk_quickMTL_Match.enabled 	= true
									chk_dds.enabled						= true
									chk_MaterialRef.enabled			= true
									
									spn_Spec_Map_Amount .enabled 		= true
									spn_displacement_map_amt.enabled 	= true
								)
								else
								(
									chk_Physical_Material.enabled 	= false
									grp_Options.enabled					= false
									chk_UVW_Flip_V.enabled 			= false
									chk_PhysMat_SSS.enabled 		= false
									chk_deepSearch.enabled 			= false
									chk_quickMTL_Match.enabled 	= false
									chk_dds.enabled						= false
									chk_MaterialRef.enabled			= false
									
									spn_Spec_Map_Amount .enabled 		= false
									spn_displacement_map_amt.enabled 	= false
								)
							)
							on rollout_options close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)
							on rollout_options rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_options.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_options.height]
								)
							)
							on chk_Physical_Material changed arg do
							(
								::g_Physical_Material 										= chk_Physical_Material.state		
								format "Physical Material: %\n" 							::g_Physical_Material 
								
								if ::g_Physical_Material then
								(
									spn_Spec_Map_Amount.enabled 		= true
									chk_PhysMat_SSS.enabled 				= true
									spn_displacement_map_amt.enabled 	= true
								)
								else
								(
									spn_Spec_Map_Amount.enabled 		= false
									chk_PhysMat_SSS.enabled 				= false
									spn_displacement_map_amt.enabled 	= false
								)
								::inst_PHYS_MAT_ADJUST.spec_output_amount = spn_Spec_Map_Amount.value
							)
							on spn_Spec_Map_Amount changed arg do
							(
								::inst_PHYS_MAT_ADJUST.spec_output_amount = spn_Spec_Map_Amount.value
							)
							on chk_dds changed arg do
							(
								::g_dds 											= chk_dds.state		
								format "Treat .tiff as .dds: %\n" 		::g_dds
							)
							on chk_PhysMat_SSS changed arg do
							(
								format "chk_PhysMat_SSS: %\n" 		chk_PhysMat_SSS.state
							)
							on chk_UVW_Flip_V changed arg do
							(
								::g_UVW_Flip_V 								= chk_UVW_Flip_V.state		
								format "chk_UVW_Flip_V % \n" 			::g_UVW_Flip_V
							)
							on chk_deepSearch changed arg do
							(	
								format "chk_deepSearch % \n" arg
							)
							on chk_quickMTL_Match changed arg do
							(	
								format "chk_quickMTL_Match % \n" arg
							)
							on chk_MaterialRef changed arg do
							(	
								format "chk_MaterialRef % \n" arg
							)
							on chk_BuildMaterial changed arg do
							(
								format "chk_BuildMaterial % \n" arg
								
								if arg then
								(
-- 									chk_Physical_Material.enabled 	= true
									grp_Options.enabled					= true
									chk_UVW_Flip_V.enabled 			= true
									chk_PhysMat_SSS.enabled 		= true
									chk_deepSearch.enabled 			= true
									chk_quickMTL_Match.enabled 	= true
									chk_dds.enabled						= true
									chk_MaterialRef.enabled			= true
									
									spn_Spec_Map_Amount .enabled 		= true
									spn_displacement_map_amt.enabled 	= true

								)
								else
								(
									chk_Physical_Material.enabled 	= false
									grp_Options.enabled					= false
									chk_UVW_Flip_V.enabled 			= false
									chk_PhysMat_SSS.enabled 		= false
									chk_deepSearch.enabled 			= false
									chk_quickMTL_Match.enabled 	= false
									chk_dds.enabled						= false
									chk_MaterialRef.enabled			= false
									
									spn_Spec_Map_Amount .enabled 		= false
									spn_displacement_map_amt.enabled 	= false
								)	
							)
						)	
						
						rollout rollout_Mesh_Options "Mesh Options" width:290 height:120 category:2
						(
							checkbox 'chk_Vertex_Normals' "Vertex Normals" pos:[16,17] width:255 height:21 align:#left checked:true enabled:true
							checkbox 'chk_Vertex_Tangent_Normals' "Vertex Normals from Tangents" pos:[16,37] width:255 height:21 align:#left checked:true enabled:true
							checkbox 'chk_Vertex_Colors' "Vertex Colors" pos:[16,57] width:255 height:21 align:#left checked:true enabled:true							
							
							on rollout_Mesh_Options rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_Mesh_Options.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_Mesh_Options.height]
								)
							)
							on chk_Vertex_Normals changed arg do
							(
								format "chk_Vertex_Normals: %\n" 		chk_Vertex_Normals.state
							)
							on chk_Vertex_Colors changed arg do
							(
								format "chk_Vertex_Colors: %\n" 		chk_Vertex_Colors.state
							)
						)
						
						rollout rollout_Report "Report" width:290 height:150 category:9
						(
							checkbox 'chk_Mesh_Report' "Mesh Report" pos:[17,11] width:80 height:20 align:#left
							checkbox 'chk_xmlB_Report' "xmlB Report" pos:[17,31] width:78 height:20 checked:false align:#left
							checkbox 'chk_xmlB_Report_v2' "xmlB Report v2" pos:[17,50] width:110 height:20 checked:false align:#left
							checkbox 'chk_xmlB_Debug_Report' "xmlB Debug Report" pos:[17,69] width:113 height:20 align:#left
							checkbox 'chk_Build_Material_Report' "Build Material Report" pos:[17,89] width:122 height:18 enabled:true checked:false align:#left						
							checkbox 'chk_Read_Comp_cryBones_Report' "Read Compiled Crybones Report" pos:[17,107] width:175 height:20 align:#left
							checkbox 'chk_Create_Bones_Report' "Create Bones Report" pos:[17,127] width:175 height:20 checked:false align:#left	
							checkbox 'chk_CDF_Report' "CDF Report" pos:[17,147] width:175 height:20 checked:false align:#left
							checkbox 'chk_Anim_Report' "Animation Report" pos:[17,167] width:175 height:20 checked:false align:#left
							checkbox 'chk_Heuristic_Report' "Heuristic Report" pos:[17,187] width:175 height:20 checked:false align:#left
							checkbox 'chk_MaterialRef_Report' "MaterialRef Report" pos:[17,207] width:175 height:20 checked:false align:#left
							checkbox 'chk_NameMTLRef_Report' "MTLRef Report" pos:[17,227] width:175 height:20 checked:false align:#left
							checkbox 'chk_NametexRef_Report' "TEXRef Report" pos:[17,247] width:175 height:20 checked:false align:#left
							checkbox 'chk_BUILDER_Report' "BUILDER Report" pos:[17,267] width:175 height:20 checked:false align:#left
							checkbox 'chk_XML_Report' "XML Report" pos:[17,287] width:175 height:20 checked:false align:#left
							
							GroupBox 'grp_Store_Report' "Store Report" pos:[9,315] width:265 height:45 align:#left
							checkbox 'chk_Store_Report' "Store Report (not recommended)" pos:[17,335] width:175 height:20 checked:false align:#left
							
							on rollout_Report open do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
								
								::g_xmlB_Report_v2 							= chk_xmlB_Report_v2.state		
								::g_xmlB_Debug_Report 					= chk_xmlB_Debug_Report.state
								::g_Build_Material_Report 					= chk_Build_Material_Report.state
								::g_xmlB_Report 								= chk_xmlB_Report.state
								::g_Mesh_Report 								= chk_Mesh_Report.state
								::g_Read_Comp_cryBones_Report 		= chk_Read_Comp_cryBones_Report.state
								::g_Read_Create_Bones_Report 			= chk_Create_Bones_Report.state
								::g_CDF_Report 								= chk_CDF_Report.state			
								
								format "\n-----Report Options: -----\n"		
								format "g_xmlB_Report_v2 % \n" 						::g_xmlB_Report_v2
								format "g_xmlB_Debug_Report % \n" 					::g_xmlB_Debug_Report
								format "g_Build_Material_Report % \n" 					::g_Build_Material_Report
								format "g_xmlB_Report % \n" 								::g_xmlB_Report
								format "g_Mesh_Report % \n" 							::g_Mesh_Report
								format "g_Read_Comp_cryBones_Report % \n" 		::g_Read_Comp_cryBones_Report
								format "g_Read_Create_Bones_Report % \n" 		::g_Read_Create_Bones_Report
								format "g_CDF_Report % \n" 								::g_CDF_Report
								
								format "chk_Anim_Report % \n" 							chk_Anim_Report.state
								format "chk_Anim_Report % \n" 							chk_Heuristic_Report.state
								format "chk_MaterialRef_Report % \n" 					chk_MaterialRef_Report.state
								format "chk_NameMTLRef_Report % \n" 				chk_NameMTLRef_Report.state
								format "chk_NametexRef_Report % \n" 				chk_NametexRef_Report.state							
							)
							on rollout_Report close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)
							on rollout_Report rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_Report.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_Report.height]
								)
							)
							on chk_xmlB_Report_v2 changed arg do
							(
								::g_xmlB_Report_v2 = chk_xmlB_Report_v2.state		
								format "chk_xmlB_Report_v2: %\n" ::g_xmlB_Report_v2
							)
							on chk_xmlB_Debug_Report changed arg do
							(
								::g_xmlB_Debug_Report = chk_xmlB_Debug_Report.state		
								format "chk_xmlB_Debug_Report: %\n" ::g_xmlB_Debug_Report
							)
							on chk_Build_Material_Report changed arg do
							(
								::g_Build_Material_Report = chk_Build_Material_Report.state		
								format "chk_Build_Material_Report: %\n" ::g_Build_Material_Report
							)
							on chk_xmlB_Report changed arg do
							(
								::g_xmlB_Report = chk_xmlB_Report.state		
								format "chk_xmlB_Report: %\n" ::g_xmlB_Report
							)
							on chk_Mesh_Report changed arg do
							(
								::g_Mesh_Report = chk_Mesh_Report.state		
								format "chk_Mesh_Report: %\n" ::g_Mesh_Report
							)
							on chk_Read_Comp_cryBones_Report changed arg do
							(
								::g_chk_Comp_cryBones_Report = chk_Read_Comp_cryBones_Report.state		
								format "chk_Read_Comp_cryBones_Report: %\n" ::g_chk_Comp_cryBones_Report
							)
							on chk_Create_Bones_Report changed arg do
							(
								::g_Create_Bones_Report = chk_Create_Bones_Report.state		
								format "chk_Create_Bones_Report: %\n" ::g_Create_Bones_Report
							)
							on chk_CDF_Report changed arg do
							(
								::g_Create_Bones_Report = chk_Create_Bones_Report.state		
								format "chk_Create_Bones_Report: %\n" ::g_Create_Bones_Report
							)
							on chk_CDF_Report changed arg do
							(
								::g_CDF_Report = chk_CDF_Report.state		
								format "chk_Create_Bones_Report: %\n" ::g_CDF_Report
							)
							on chk_Anim_Report changed arg do
							(						
								format "chk_Anim_Report: %\n" arg
							)
							on chk_Heuristic_Report changed arg do
							(						
								format "chk_Heuristic_Report: %\n" arg
							)
							on chk_MaterialRef_Report changed arg do
							(						
								format "chk_MaterialRef_Report: %\n" arg
							)
							on chk_NameMTLRef_Report changed arg do
							(						
								format "chk_NameMTLRef_Report: %\n" arg
							)	
							on chk_NametexRef_Report changed arg do
							(						
								format "chk_NametexRef_Report: %\n" arg
							)	
							on chk_BUILDER_Report changed arg do
							(						
								format "chk_BUILDER_Report: %\n" arg
							)	
							on chk_XML_Report changed arg do
							(						
								format "chk_XML_Report: %\n" arg
							)
						)

						rollout rollout_animation "Animation" width:290 height:95 category:5
						(
							checkbox 'chk_Use_Skin_Wrap' "Use Skin_Wrap" pos:[16,17] width:255 height:21 align:#left checked:false enabled:false
							checkbox 'chk_Force_Skin_Translation' "Force Skin Translation" pos:[16,37] width:255 height:21 align:#left checked:false enabled:false
							checkbox 'chk_Force_Load_chrparams' "Load .chrparams" pos:[16,57] width:255 height:21 align:#left checked:false enabled:true	
							
							on rollout_animation open do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)
							on rollout_animation close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)
							on chk_Use_Skin_Wrap changed arg do
							(
								::g_Use_Skin_Wrap = chk_Use_Skin_Wrap.state		
								format "chk_Use_Skin_Wrap: %\n" ::g_Use_Skin_Wrap
							)
							on rollout_animation rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_animation.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_animation.height]
								)
							)
						)

						rollout rollout_About "About" width:290 height:50 category:10
						(
							label 'lbl_About' "joqqyhez@gmail.com  2016" pos:[14,13] width:263 height:19 align:#left
							label 'lbl_trademark' "CRYENGINE is a Trademark of Crytek GmbH" pos:[13,35] width:266 height:20 align:#left						
							
							on rollout_About open do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)	
							on rollout_About close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)						
							on rollout_About rolledUp state do
							(							
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_About.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_About.height]
								)
							)
						)

						rollout rollout_Alert "Alert" width:290 height:85 category:8
						(
							listBox 'lbx_Message_Alert' "Message Alert" pos:[12,20] width:267 height:7 align:#left						
							
							on rollout_Alert open do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)	
							on rollout_Alert close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)	
							on rollout_Alert rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_Alert.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_Alert.height]
								)
							)
						)
						
						rollout rollout_AnimationTracks "Animation Tracks" width:100 height:20 category:6
						(
							dropdownList 'ddl_Animation_Tracks' "Animation Tracks" pos:[8,20] width:265 height:30 items:#() align:#left
							
							on rollout_AnimationTracks open do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)
							on rollout_AnimationTracks close do
							(
								if (setdir #scripts ::g_scriptsDefault) then
								(
									format "Current Scripts Dir set to #scripts: %\n" (getdir #scripts)
								)
								else
								(
									format "Current #scripts dir: %\n" (getdir #scripts)
								)
							)	
							on rollout_AnimationTracks rolledUp state do
							(
								if NOT state then
								(
									--closed
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]-rollout_AnimationTracks.height]
								)
								else
								(
									--open
									CRYOP.size = [CRYOP.size[1], CRYOP.size[2]+rollout_AnimationTracks.height]
								)
							)
						)						

						--/////////////////////////////// Instanciate the rollouts ///////////////////////////////
						CRYOP = newRolloutFloater "CryEngine Importer v 1.0" 290 1325

						addRollout 			::rollout_options 				::CRYOP  rolledUp:true
						addRollout 			::rollout_Mesh_Options 		::CRYOP  rolledUp:true						
						addRollout 			::rollout_Report 				::CRYOP rolledUp:true
						addRollout 			::cryImport 					::CRYOP rolledUp:false
						addRollout 			::rollout_Tools		 			::CRYOP rolledUp:true
						addRollout 			::rollout_animation 			::CRYOP rolledUp:true
						-- addRollout 			::rollout_Alert 					::CRYOP rolledUp:false --set runtime instead inside CryMat_XML_.ms
						addRollout 			::rollout_About 				::CRYOP rolledUp:true					

						CreateDialog 		::cryImport 	rolledUp:false width:120 height:200		
						--//////////////////////////////////////////////////////////////////////////////////////
					)
					else
					(
-- 						delete_ini()
						MessageBox "Cannot find or load the include files, cannot continue, aborting!" title:"Startup Error" beep:false
					)
				)
				else
				(
-- 					delete_ini()
					format "Could not set the #scripts path - include files will not load - aborting!\n"
				)	
			)
			catch
			(
-- 				delete_ini()
				format "\n\n\n\n*** *** *** *** *** ***  Could not load include files ***  *** *** *** *** *** ***\n"
				format "%" (getCurrentException())
				format "\n*** *** *** *** *** *** END OF Could not load include files *** *** *** *** *** *** ***\n\n\n\n"
			)
		)
		else
		(
			delete_ini()
			MessageBox "Cannot find scriptpath, cannot continue, aborting!" title:"Startup Error" beep:false	
		)

		gc()
	)
	else
	(
		format "No ini file ( % ) found - aborting! (Make sure your user temp\n" ::g_iniFile
	)
)
else
(
	MessageBox "This script requires 3DS Max 2017 or higher!" title:"Startup Error" beep:true
)