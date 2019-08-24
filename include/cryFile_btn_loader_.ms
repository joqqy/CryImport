
struct CDF_Model
(
	n_File 							= "",
	n_Material 						= "",
	CryBoneDescData_Comp 	= #()
)

struct CDF_Attachment
(
	n_File		 		= "",
	n_Material 			= "",
	n_Type 				= "",
	n_AName 			= "",							
	n_Binding 			= "",
	n_LodDistances 	= "",
	n_Flags			 	= "",
	
	---HFR---
	n_BoneName		= "",
	n_Rotation			= "",
	n_Position			= "",
	
	CryBoneDescData_Comp 	= #()
)

struct CDF_Modifiers
(
	n_node				= "",
	n_value				= "",
	
	fn _set \
			&nTagString: \
			&attribName: \
			&attribVal: =
	(
		if (stricmp attribName "value" == 0) then
		(
			n_node			= nTagString
			n_value			= attribVal
		)
	)
)

fn set_ini_Settings \
							&g_cryFile: \
							&g_cryFile_m: =
(
	if g_cryFile != unsupplied AND g_cryFile_m != unsupplied then
	(
		
		--////////////////////////////////// fileType1 /////////////////////////////////////	
		--//////////////////////////////////////////////////////////////////////////////////
		if doesfileexist g_cryFile then
		(
			setINISetting 	::g_iniFile 	"fileType" 	"fileType1" 	(getFilenameType g_cryFile) --we will use this for loading the material xmlB
			
			setINISetting 	::g_iniFile 	"paths" ("g_cryFile"+(getFilenameType g_cryFile)) 		g_cryFile
			setINISetting 	::g_iniFile 	"paths" ("first_loaded") 											g_cryFile --we will use this for loading the material xmlB
			setINISetting 	::g_iniFile 	"paths" ("last_loaded") 												g_cryFile --we will use this for loading the material xmlB
			setINISetting 	::g_iniFile 	"fileType" ("fileType1") 												(getFilenameType g_cryFile) --we will use this for loading the material xmlB
		)
		else
		(
			setINISetting 	::g_iniFile 	"fileType" 	"fileType1" 	"" --we will use this for loading the material xmlB

			setINISetting 	::g_iniFile 	"paths" ("g_cryFile"+(getFilenameType g_cryFile)) 		""
			setINISetting 	::g_iniFile 	"paths" ("first_loaded") 											""
			setINISetting 	::g_iniFile 	"fileType" ("fileType1") 												""
		)
		--//////////////////////////////////////////////////////////////////////////////////
		--//////////////////////////////////////////////////////////////////////////////////
		
		
		
		
		--////////////////////////////////// fileType2 /////////////////////////////////////
		--//////////////////////////////////////////////////////////////////////////////////
		if doesfileexist g_cryFile_m then
		(
			setINISetting 	::g_iniFile 	"fileType" 	"fileType2" 	(getFilenameType g_cryFile_m) --we will use this for loading the material xmlB
			
			setINISetting 	::g_iniFile 	"paths" 		("g_cryFile"+(getFilenameType g_cryFile_m)) 		g_cryFile_m
			setINISetting 	::g_iniFile 	"paths" 		("last_loaded") 												g_cryFile_m --we will use this for loading the material xmlB		
			setINISetting 	::g_iniFile 	"fileType" 	("fileType2") 													(getFilenameType g_cryFile_m) --we will use this for loading the material xmlB
		)
		else
		(
			setINISetting 	::g_iniFile 	"fileType" 	"fileType2" 	"" --we will use this for loading the material xmlB

			setINISetting 	::g_iniFile 	"paths" 		("g_cryFile"+(getFilenameType g_cryFile_m)) 		""			
			setINISetting 	::g_iniFile 	"fileType" 	("fileType2") 													""
		)
		--//////////////////////////////////////////////////////////////////////////////////
		--//////////////////////////////////////////////////////////////////////////////////
		
		
	)
)

fn store_Report =
(
	if ::rollout_Report.chk_Store_Report.state then --default is off
	(
		--Just for info
		try
		(			
			----------	----------	----------	----------	----------
			store_report ()	
			if ::g_Mesh_Report then ( report() )
			----------	----------	----------	----------	----------
		)
		catch()	
	)
)

fn cryFile_loader \
						caller: \
						nodeCaller: \
						typeCaller: \
						Binding_BOOL: \						
						&g_cryFile: \
						&mtlFile: \ --for CDF Material
						&assetName_From_CDF: \
						&inst_Sub_Meshes: \
						&inst_CDF_Model: \
						&inst_CDF_Attachment: \
						&inst_CDF_Modifiers: =
(	
	if 	caller == "CAF" OR \
		caller == ".caf" then
	(
		CAF_read \
						caller:caller \
						g_cryFile:g_cryFile
		
	)
	else if 	caller == "IMG" OR \
				caller == ".img" then
	(
		CAF_read \
						caller:caller \
						g_cryFile:g_cryFile
	)	
	else if caller == "CDF" then --if called from a CDF
	(
		local M_TEST_BOOL 				= false
		local M_FILE_EXISTS_BOOL 		= false
		
		Reset_Arrays()
		
		--The other filepaths - we later check if they do indeed exist
		local g_cryFile_m 					= (g_cryFile as string) + "m"
		local g_cryFile_chrparams 		= (g_cryFile as string) + "params"	
		
		set_ini_Settings \
								g_cryFile: 		&g_cryFile \
								g_cryFile_m:	&g_cryFile_m
		(
			------------------------------------------------------- Some Extra backup info -------------------------------------------------------
			inst_Sub_Meshes._Material									= mtlFile
			inst_Sub_Meshes.File											= g_cryFile
			inst_Sub_Meshes.File_m										= g_cryFile_m
			
			--We reset some of the properties of the struct ( but we leave the CA_SKIN_counter untouched, because we want to keep track of the index of the loadable skins in each CDF 		
			inst_Sub_Meshes.nStream										= #()
			inst_Sub_Meshes.nCount										= #()	
			inst_Sub_Meshes.subMeshes 									= #()
			inst_Sub_Meshes.SKINBONES_FROM_0xCCCC0017 		= #()
			------------------------------------------------------------------------------------------------------------------------------------------
		)
		
-- 		if caller != "CDF" then
-- 		(
			--Why do we increment the CA_SKIN_counter here? We found no CA_SKIN?
			--Well, because the old CryEngine used .chr for character etc (not CDF) thus some files are still legacy and incrementing
			--here we force treating this as a legacy character file	
			--we set it to 1 because obviously we are loading from a *single file*!
			-------------------------------------------------------------------------------------------
			inst_Sub_Meshes.CA_SKIN_counter = 1
			-------------------------------------------------------------------------------------------
-- 		)

		-------------------------- FileType1 --------------------------
		if doesfileexist g_cryFile then
		(
			--Report
			format "loading: %\n" g_cryFile			
			
			load_global_arrays()			
			--///////////////////////////////////////////////////////////////////////////////////
			--///////////////////////////////////////////////////////////////////////////////////
	 		try
	 		(
				g_bs = fopen g_cryFile "rb" --open binary stream
				--------------------------------------------------------------------------------------------------
				-- see load_cryFile_.ms
				load_cryFile \	
									M_FILE_EXISTS_BOOL:		&M_FILE_EXISTS_BOOL \
									M_TEST_BOOL:				&M_TEST_BOOL \
									caller:							caller \
									nodeCaller:						nodeCaller \
									typeCaller:						typeCaller \
									currFileType: 					(getFilenameType inst_Sub_Meshes.File) \
									bstream:						&g_bs \
									mtlFile:							&mtlFile \
									g_cryFile_m:					&g_cryFile \
									inst_Sub_Meshes:			&inst_Sub_Meshes \
									inst_CDF_Model:				&inst_CDF_Model \
									inst_CDF_Attachment:		&inst_CDF_Attachment \
									inst_CDF_Modifiers:			&inst_CDF_Modifiers
				--------------------------------------------------------------------------------------------------
				fclose g_bs	--Close & Flush Binary Stream
	 		)
	 		catch
	 		(
	 			format "\n\n\n\n*** *** *** *** *** ***  load_cryFile ERROR *** *** *** *** *** ***\n"
	 			format "%" (getCurrentException())
	 			format "\n*** *** *** *** *** *** END load_cryFile ERROR *** *** *** *** *** *** ***\n\n\n\n"
	 		)
			--///////////////////////////////////////////////////////////////////////////////////
			--///////////////////////////////////////////////////////////////////////////////////			
		)
		
		-------------------------- FileType2 --------------------------	
		--Now we attempt to load the mesh version of the file above - in Ryse(at least), the file suffixes have an *m* added to the suffix		
		if doesfileexist g_cryFile_m then
		(
			M_TEST_BOOL 				= true
			M_FILE_EXISTS_BOOL 		= true
				
-- 			if caller != "CDF" then
-- 			(
				--Why do we increment the CA_SKIN_counter here? We found no CA_SKIN?
				--Well, because the old CryEngine used .chr for character etc (not CDF) thus some files are still legacy and incrementing
				--here we force treating this as a legacy character file	
				--we set it to 1 because obviously we are loading from a *single file*!
				-------------------------------------------------------------------------------------------
				inst_Sub_Meshes.CA_SKIN_counter = 1
				-------------------------------------------------------------------------------------------
-- 			)
			
			--Report
			format "loading: %\n" g_cryFile_m
			
			load_global_arrays()			
			--///////////////////////////////////////////////////////////////////////////////////
			--///////////////////////////////////////////////////////////////////////////////////
			try
			(
				g_bs = fopen g_cryFile_m "rb" --open binary stream
				--------------------------------------------------------------------------------------------------
				load_cryFile \
									M_FILE_EXISTS_BOOL:		&M_FILE_EXISTS_BOOL \
									M_TEST_BOOL:				&M_TEST_BOOL \
									caller:							caller \
									nodeCaller:						nodeCaller \
									typeCaller:						typeCaller \
									currFileType: 					(getFilenameType g_cryFile_m) \
									bstream:						&g_bs \
									mtlFile:							&mtlFile \
									g_cryFile_m:					&g_cryFile_m \
									inst_Sub_Meshes:			&inst_Sub_Meshes \
									inst_CDF_Model:				&inst_CDF_Model \
									inst_CDF_Attachment:		&inst_CDF_Attachment \
									inst_CDF_Modifiers:			&inst_CDF_Modifiers
				--------------------------------------------------------------------------------------------------
				fclose g_bs	--Close & Flush Binary Stream
			)
			catch
			(
				format "\n\n\n\n*** *** *** *** *** ***  load_cryFile ERROR *** *** *** *** *** ***\n"
				format "%" (getCurrentException())
				format "\n*** *** *** *** *** *** END load_cryFile ERROR *** *** *** *** *** *** ***\n\n\n\n"
			)			
			--///////////////////////////////////////////////////////////////////////////////////
			--///////////////////////////////////////////////////////////////////////////////////			
		)			
		store_Report()	
		
		
		
		if ::rollout_animation.chk_Force_Load_chrparams.state then
		(
			------------------ Try to read *.charparams if it exists (we read it here, but will use it later when and if we process the .caf ------------------		
			if doesfileexist g_cryFile_chrparams then
			(
				::g_inst_CHRPARAMS_Attribs 			= #() --reset global array
				
				format "g_cryFile_chrparams: %\n" g_cryFile_chrparams
				
				inst_xmlB_PROCESSOR = xmlB_PROCESSOR()
				inst_xmlB_PROCESSOR.cry_CDF_xmlB_ASSETS_loader_ReaderV \
																									CDF_File:				&g_cryFile_chrparams \
																									inst_s_OPTIONS:		&inst_s_OPTIONS \
																									type:						(getFilenameType g_cryFile_chrparams)
			)
		)		
		store_Report()
	)	
	else --if file loaded directly
	(
		local M_TEST_BOOL 				= false
		local M_FILE_EXISTS_BOOL 		= false
		
		Reset_Arrays()
		
		--The other filepaths - we later check if they do indeed exist
		local g_cryFile_m 					= (g_cryFile as string) + "m"
		local g_cryFile_chrparams 		= (g_cryFile as string) + "params"
		
		set_ini_Settings \
								g_cryFile: 		&g_cryFile \
								g_cryFile_m:	&g_cryFile_m
		(
			------------------------------------------------------- Some Extra backup info -------------------------------------------------------
			inst_Sub_Meshes._Material									= mtlFile
			inst_Sub_Meshes.File											= g_cryFile
			inst_Sub_Meshes.File_m										= g_cryFile_m
			
			--We reset some of the properties of the struct ( but we leave the CA_SKIN_counter untouched, because we want to keep track of the index of the loadable skins in each CDF 
			inst_Sub_Meshes.nStream										= #()
			inst_Sub_Meshes.nCount										= #()	
			inst_Sub_Meshes.subMeshes 									= #()
			inst_Sub_Meshes.SKINBONES_FROM_0xCCCC0017 		= #()
		)
		
-- 		if caller != "CDF" then
-- 		(
			--Why do we increment the CA_SKIN_counter here? We found no CA_SKIN?
			--Well, because the old CryEngine used .chr for character etc (not CDF) thus some files are still legacy and incrementing
			--here we force treating this as a legacy character file	
			--we set it to 1 because obviously we are loading from a *single file*!
			-------------------------------------------------------------------------------------------
			inst_Sub_Meshes.CA_SKIN_counter = 1
			-------------------------------------------------------------------------------------------
-- 		)
		
		--Report
		format "loading: %\n" g_cryFile
		
		load_global_arrays()			
		--///////////////////////////////////////////////////////////////////////////////////
		--///////////////////////////////////////////////////////////////////////////////////		
		try
		(
			g_bs = fopen g_cryFile "rb" --open binary stream
			--------------------------------------------------------------------------------------------------
			load_cryFile \	
								M_FILE_EXISTS_BOOL:		&M_FILE_EXISTS_BOOL \
								M_TEST_BOOL:				&M_TEST_BOOL \
								caller:							caller \
								nodeCaller:						nodeCaller \
								typeCaller:						typeCaller \
								currFileType: 					(getFilenameType g_cryFile) \
								bstream:						&g_bs \
								mtlFile:							&mtlFile \ -----
								g_cryFile_m:					&g_cryFile \ -----
								inst_Sub_Meshes:			&inst_Sub_Meshes \
								inst_CDF_Model:				&inst_CDF_Model \
								inst_CDF_Attachment:		&inst_CDF_Attachment \
								inst_CDF_Modifiers:			&inst_CDF_Modifiers
			--------------------------------------------------------------------------------------------------
			fclose g_bs	--Close & Flush Binary Stream
		)
		catch
		(
			format "\n\n\n\n*** *** *** *** *** ***  load_cryFile ERROR *** *** *** *** *** ***\n"
			format "%" (getCurrentException())
			format "\n*** *** *** *** *** *** END load_cryFile ERROR *** *** *** *** *** *** ***\n\n\n\n"
		)		
		--///////////////////////////////////////////////////////////////////////////////////
		--///////////////////////////////////////////////////////////////////////////////////
		
		
		--Try to execute this in the Builders		
		--Now we attempt to load the mesh version of the file above - in Ryse(at least), the file suffixes have an *m* added to the suffix		
		if doesfileexist g_cryFile_m then
		(
			M_TEST_BOOL 				= true
			M_FILE_EXISTS_BOOL 		= true
			
			(
				--We reset some of the properties of the struct ( but we leave the CA_SKIN_counter untouched, because we want to keep track of the index of the loadable skins in each CDF 
				inst_Sub_Meshes.nStream										= #()
				inst_Sub_Meshes.nCount										= #()	
				inst_Sub_Meshes.subMeshes 									= #()
				inst_Sub_Meshes.SKINBONES_FROM_0xCCCC0017 		= #()
			)

-- 			if caller != "CDF" then
-- 			(
				--Why do we increment the CA_SKIN_counter here? We found no CA_SKIN?
				--Well, because the old CryEngine used .chr for character etc (not CDF) thus some files are still legacy and incrementing
				--here we force treating this as a legacy character file	
				--we set it to 1 because obviously we are loading from a *single file*!
				-------------------------------------------------------------------------------------------
				inst_Sub_Meshes.CA_SKIN_counter = 1
				-------------------------------------------------------------------------------------------
-- 			)	
			
			--Report
			format "loading: %\n" g_cryFile_m
			
			load_global_arrays()
			--///////////////////////////////////////////////////////////////////////////////////
			--///////////////////////////////////////////////////////////////////////////////////			
			try
			(
				g_bs = fopen g_cryFile_m "rb" --open binary stream
				--------------------------------------------------------------------------------------------------
				load_cryFile \
									M_FILE_EXISTS_BOOL:		&M_FILE_EXISTS_BOOL \
									M_TEST_BOOL:				&M_TEST_BOOL \
									caller:							caller \
									nodeCaller:						nodeCaller \
									typeCaller:						typeCaller \
									currFileType: 					(getFilenameType g_cryFile_m) \
									bstream:						&g_bs \
									mtlFile:							&mtlFile \
									g_cryFile_m:					&g_cryFile_m \ ----
									inst_Sub_Meshes:			&inst_Sub_Meshes \
									inst_CDF_Model:				&inst_CDF_Model \
									inst_CDF_Attachment:		&inst_CDF_Attachment \
									inst_CDF_Modifiers:			&inst_CDF_Modifiers
				--------------------------------------------------------------------------------------------------
				fclose g_bs	--Close & Flush Binary Stream
			)
			catch
			(
				format "\n\n\n\n*** *** *** *** *** ***  load_cryFile ERROR *** *** *** *** *** ***\n"
				format "%" (getCurrentException())
				format "\n*** *** *** *** *** *** END load_cryFile ERROR *** *** *** *** *** *** ***\n\n\n\n"
			)			
			--///////////////////////////////////////////////////////////////////////////////////
			--///////////////////////////////////////////////////////////////////////////////////	
		)			
		store_Report()


		
		if ::rollout_animation.chk_Force_Load_chrparams.state then
		(
			------------------ Try to read *.charparams if it exists (we read it here, but will use it later when and if we process the .caf ------------------		
			if doesfileexist g_cryFile_chrparams then
			(
				::g_inst_CHRPARAMS_Attribs 			= #() --reset global array
				
				format "g_cryFile_chrparams: %\n" g_cryFile_chrparams
				
				inst_xmlB_PROCESSOR = xmlB_PROCESSOR()
				inst_xmlB_PROCESSOR.cry_CDF_xmlB_ASSETS_loader_ReaderV \
																									CDF_File:				&g_cryFile_chrparams \
																									inst_s_OPTIONS:		&inst_s_OPTIONS \
																									type:						(getFilenameType g_cryFile_chrparams)
			)
		)		
		store_Report()
	)
)

--Highly WIP - this is more of placeholder for now
fn cryFile_Crysis_loader \	
								g_cryFile: \
								caller: \
								mtlFile: \
								assetName_From_CDF: =
(
	--Put code here
)

fn mtlName_deepCheck \
									&_Material_: =
(
	if _Material_ != unsupplied then
	(
		if _Material_ != undefined then
		(
			if NOT doesfileexist _Material_ then
			(
				check_4_mtl_suffix \
											filePath:&_Material_
				
				local newMtlBuild 		= ""
				local finalMtlPath 		= ""
								
				local mtlDir 				= getFilenamePath _Material_					
				local stringFiltered 		= filterString (filenameFromPath _Material_) "_"
								
				for i=1 to stringFiltered.count do
				(
					subS 					= stringFiltered[i]
									
					if ((stricmp subS "mat.mtl") == 0) OR \
						(matchpattern subS pattern:"*_mat") then
					(
						newMtlBuild = ""
						for s=1 to stringFiltered.count do
						(
							if s != i then
							(
								newMtlBuild += stringFiltered[s] 
							)
						)
					)
				)		
					
				finalMtlPath = pathConfig.ResolvePathSymbols (pathConfig.AppendPath mtlDir (newMtlBuild + ".mtl"))				
				
				if doesfileexist finalMtlPath then
				(
					_Material_ = finalMtlPath
				)				
			)
		)
	)
)

fn Load_CDF_Model \
							&inst_s_OPTIONS: \
							&g_cryFile: \
							&nodeIsolation_arr: \
							&inst_Sub_Meshes: \
							&inst_CDF_Model: \
							&inst_CDF_Attachment: \
							&inst_CDF_Modifiers: =
(
	if inst_CDF_Model != undefined then
	(	
		inst_Sub_Meshes.CA_SKIN_counter = 1 --??? --So that we can load the Model file, because the Model file does not count the CA_SKIN or CA_BONE --but this is hacky
		
		if  NOT (Binary_CryTek_check File:inst_CDF_Model.n_File) then --if the xml file is not Crytek Binary XML
		(
			if ::g_CDF_Report then ( format "This is not a valid CryTek file, aborting!\n" ) --report
		)
		else
		(
			if ::g_CDF_Report then ( format "We will now attempt to load _File_: % ...\n" inst_CDF_Model.n_File )	--report
			
			if doesfileexist inst_CDF_Model.n_Material then
			(
				if (Binary_XML_check inst_CDF_Model.n_Material) then
				(
					cryFile_loader \
										caller:							"CDF" \
										nodeCaller:						"Model" \
										g_cryFile:						&inst_CDF_Model.n_File \										
										mtlFile:							&inst_CDF_Model.n_Material \
										inst_Sub_Meshes:			&inst_Sub_Meshes \
										inst_CDF_Model:				&inst_CDF_Model \
										inst_CDF_Attachment:		&inst_CDF_Attachment \
										inst_CDF_Modifiers:			&inst_CDF_Modifiers
				)
				else --Same, but we keep it separated to facilitate changes later should we need them
				(
					cryFile_loader \
										caller:							"CDF" \
										nodeCaller:						"Model" \
										g_cryFile:						&inst_CDF_Model.n_File \										
										mtlFile:							&inst_CDF_Model.n_Material \
										inst_Sub_Meshes:			&inst_Sub_Meshes \
										inst_CDF_Model:				&inst_CDF_Model \
										inst_CDF_Attachment:		&inst_CDF_Attachment \
										inst_CDF_Modifiers:			&inst_CDF_Modifiers
				)
			)
			else
			(
				cryFile_loader \
									caller:							"CDF" \
									nodeCaller:						"Model" \									
									g_cryFile:						&inst_CDF_Model.n_File \									
									inst_Sub_Meshes:			&inst_Sub_Meshes \
									inst_CDF_Model:				&inst_CDF_Model \
									inst_CDF_Attachment:		&inst_CDF_Attachment \
									inst_CDF_Modifiers:			&inst_CDF_Modifiers
			)
		)
		--//////////////////////////////////////////////////////////////////////////////////////////////
	)
	else
	(
		format " ## Inside *inst_CDF_Mode* is ***UNDEFINED***\n"
	)
)

fn CDF_Type_Loader \
								typeCaller: \
								&inst_s_OPTIONS: \
								&g_cryFile: \
								&nodeIsolation_arr: \
								&inst_Sub_Meshes: \
								&inst_CDF_Model: \
								&inst_CDF_Attachment: \
								&inst_CDF_Modifiers: = 
(
		format "inst_CDF_Attachment.n_type: %\n" 			inst_CDF_Attachment.n_type
		format "inst_CDF_Attachment.n_Material: %\n" 	inst_CDF_Attachment.n_Material		
	
		--////////////////////// Load Model Node Attachment( of type *CA_SKIN* or *CA_BONE* ) //////////////////////
		if  NOT (Binary_CryTek_check File:inst_CDF_Attachment.n_Binding) then --if the xml file is not Crytek Binary XML
		(
			if ::g_CDF_Report then ( format "This is not a valid CryTek file, aborting!\n" ) --report
		)
		else
		(
			if ::g_CDF_Report then ( format "We will now attempt to load _File_: % ...\n" inst_CDF_Attachment.n_Binding )	--report
			
			if doesfileexist inst_CDF_Attachment.n_Material then
			(
				if (Binary_XML_check inst_CDF_Attachment.n_Material) then
				(
					cryFile_loader \					
										caller:							"CDF" \
										nodeCaller:						"Attachment" \
										typeCaller:						typeCaller \
										g_cryFile:						&inst_CDF_Attachment.n_Binding \										
										mtlFile:							&inst_CDF_Attachment.n_Material \
										inst_Sub_Meshes:			&inst_Sub_Meshes \
										inst_CDF_Model:				&inst_CDF_Model \
										inst_CDF_Attachment:		&inst_CDF_Attachment \
										inst_CDF_Modifiers:			&inst_CDF_Modifiers
				)
			)
			else --No material found, we use the info inside the 0x00000014 to locate it through our CryMat search
			(
				cryFile_loader \
									caller:							"CDF" \
									nodeCaller:						"Attachment" \
									typeCaller:						typeCaller \
									g_cryFile:						&inst_CDF_Attachment.n_Binding \									
									inst_Sub_Meshes:			&inst_Sub_Meshes \
									inst_CDF_Model:				&inst_CDF_Model \
									inst_CDF_Attachment:		&inst_CDF_Attachment \
									inst_CDF_Modifiers:			&inst_CDF_Modifiers
			)
		)
		--//////////////////////////////////////////////////////////////////////////////////////////////
)

fn Load_CDF_Attachment  \
								typeCaller: \
								&inst_s_OPTIONS: \
								&g_cryFile: \
								&nodeIsolation_arr: \
								&inst_Sub_Meshes: \
								&inst_CDF_Model: \
								&inst_CDF_Attachment: \
								&inst_CDF_Modifiers: =
(
	--/*
	--//!-- NOTE
	--Note, we load the chr last ( IF - the .chr is legacy or for some reason, the user opts to load the .chr
	--which for newer cryfile version, is just a helper and proxy
	--however for legacy .chr it should be loaded, because that IS the character!
	--See the caller of this function *LOAD_CDF_ASSETS*
	--//!-- NOTE
	
	if inst_CDF_Attachment.n_type == "CA_SKIN" then --possibly redundant, because this check is already made earlier
	(
		CDF_Type_Loader \
								typeCaller:						typeCaller \
								inst_s_OPTIONS:				&inst_s_OPTIONS \
								g_cryFile:						&g_cryFile \										
								nodeIsolation_arr:			&nodeIsolation_arr \
								inst_Sub_Meshes:			&inst_Sub_Meshes \
								inst_CDF_Model:				&inst_CDF_Model \
								inst_CDF_Attachment:		&inst_CDF_Attachment \
								inst_CDF_Modifiers:			&inst_CDF_Modifiers
	)
	else 	if inst_CDF_Attachment.n_type == "CA_BONE" then
	(
		CDF_Type_Loader \
								typeCaller:						typeCaller \
								inst_s_OPTIONS:				&inst_s_OPTIONS \
								g_cryFile:						&g_cryFile \										
								nodeIsolation_arr:			&nodeIsolation_arr \
								inst_Sub_Meshes:			&inst_Sub_Meshes \
								inst_CDF_Model:				&inst_CDF_Model \
								inst_CDF_Attachment:		&inst_CDF_Attachment \
								inst_CDF_Modifiers:			&inst_CDF_Modifiers
	)
)

fn ISOLATED_CDF_NODE_LOADER \
												&inst_s_OPTIONS: \
												&g_cryFile: \
												&nodeIsolation_arr: \
												&inst_Sub_Meshes: \
												&inst_CDF_Model: \
												&inst_CDF_Attachment: \
												&inst_CDF_Modifiers: =
(
	print "// ** // ** // ** // ** // ** // ** // ** // ** // ** // "
	format "Isolated Node (all nodes), just before reading:\n"
	print nodeIsolation_arr
	print "// ** // ** // ** // ** // ** // ** // ** // ** // ** // "
	
	-------------------- Counters --------------------
	local AttachmentList_count 		= 0
	local Attachment_count			= 0
	local Modifiers_count 				= 0
	local Element_count					= 0	
	
	--------------------Predeclare--------------------
	local _File_Name 				= ""
	local _File_							= ""
		
	local _Material_Name 			= ""
	local _Material_ 					= ""
		
	local _Type_Name 				= ""
	local _Type_						= ""
					
	local _AName_Name				= ""
	local _AName_ 					= ""					
		
	local _Binding_Name				= ""
	local _Binding_					= ""
					
	local _LodDistances_Name 	= ""
	local _LodDistances_ 			= ""
				
	local _Flags_Name 				= ""
	local _Flags_ 						= ""
	
	---------------------- HFR ----------------------
	local _BoneName_Name 		= ""
	local _BoneName_ 				= ""
	
	local _Rotation_Name 			= ""
	local _Rotation_ 					= ""
	
	local _Position_Name 			= ""
	local _Position_ 					= ""
	-----------------------------------------------------
	
	local entered_Model 			= false
	local entered_Attachment 	= false
	
	for i=1 to nodeIsolation_arr.count do
	(
		local nTagString					= nodeIsolation_arr[i].nTagString
		
		if ::g_CDF_Report then ( format "\nCDF nTagString: %\n" nTagString ) --report		
		
		for x=1 to nodeIsolation_arr[i].attribName.count do
		(
			--------------------------------------------------------------------------------------------
			local attribName				= nodeIsolation_arr[i].attribName[x]
			local attribVal					= nodeIsolation_arr[i].attribVal[x]
			--------------------------------------------------------------------------------------------
			
			if ::g_CDF_Report then ( format "\t% = %\n" 	attribName		attribVal ) --report
			
			if stricmp nTagString "Model" == 0 then
			(
				entered_Model = true
				
				case of
				(
					(stricmp attribName "File" == 0):
					(
						_File_Name		= attribName
						_File_			= attribVal	
						
						--We reference the filePath and the path will be updated if a valid file and if the file exists
						build_complete_filePath \
														attribVal:attribVal \
														dirPath:(::g_dirPath) \
														filePath:&_File_ --Note this is a reference and will update the g_cryFile above					

						inst_CDF_Model.n_File = _File_
					)
					(stricmp attribName "Material" == 0):
					(
						_Material_Name		= attribName
						_Material_				= attribVal
						
						--We reference the filePath and the path will be updated if a valid file and if the file exists
						build_complete_filePath \
														attribVal:attribVal \
														dirPath:(::g_dirPath) \
														filePath:&_Material_ --Note this is a reference and will update the g_cryFile above
						
						mtlName_deepCheck \
													_Material_:&_Material_
						
						inst_CDF_Model.n_Material = _Material_
					)
				)
			)			
			else if stricmp nTagString "AttachmentList" == 0 then
			(	
				entered_Model = false
				AttachmentList_count += 1
			)
			else if stricmp nTagString "Attachment" == 0 then
			(
				entered_Attachment = true
				Attachment_count += 1
				
				case of
				(
					(stricmp attribName "Type" == 0):
					(
						_Type_Name									= attribName
						_Type_											= attribVal						
						inst_CDF_Attachment.n_Type 		= _Type_
						
						if (stricmp _Type_ "CA_SKIN") == 0 then
						(
							-------------------------------------------------------------------------------------------
							inst_Sub_Meshes.CA_SKIN_counter += 1
							-------------------------------------------------------------------------------------------
						)
						else if (stricmp _Type_ "CA_BONE") == 0 then
						(
							-------------------------------------------------------------------------------------------
							inst_Sub_Meshes.CA_BONE_counter += 1
							-------------------------------------------------------------------------------------------
						)
						
						if ::g_CDF_Report then ( format "\tType: % = %\n"	_Type_Name	_Type_ ) --report
					)
					(stricmp attribName "AName" == 0):
					(
						_AName_Name									= attribName
						_AName_										= attribVal
						inst_CDF_Attachment.n_AName 			= _AName_
						
						::g_AName = attribVal
						
						if ::g_CDF_Report then ( format "\tAName: % = %\n"	_AName_Name		_AName_ ) --report
					)
					(stricmp attribName "Binding" == 0):
					(
						_Binding_Name									= attribName
						_Binding_											= attribVal
						inst_CDF_Attachment.n_Binding 				= _Binding_
						
						--------------------------------------------Test-----------------------------------------------							
						inst_Sub_Meshes.Binding_BOOL 				= true
						-----------------------------------------------------------------------------------------------
						
						if ::g_CDF_Report then ( format "\tBinding: % = %\n"	_Binding_Name	_Binding_ ) --report
						
						--We reference the filePath and the path will be updated if a valid file and if the file exists
						build_complete_filePath \
														attribVal:attribVal \
														dirPath:(::g_dirPath) \
														filePath:&_Binding_ --Note this is a reference and will update the g_cryFile above

						inst_CDF_Attachment.n_Binding    	= _Binding_
						inst_Sub_Meshes.Binding 				= _Binding_ --for info						
					)
					(stricmp attribName "Material" == 0):
					(
						_Material_Name									= attribName
						_Material_											= attribVal
						
						check_4_mtl_suffix filePath:&_Material_
						
						--We reference the filePath and the path will be updated if a valid file and if the file exists
						build_complete_filePath \
														attribVal:attribVal \
														dirPath:(::g_dirPath) \
														filePath:&_Material_ --Note this is a reference and will update the g_cryFile above

						mtlName_deepCheck \
													_Material_:&_Material_
														
														
						inst_CDF_Attachment.n_Material 			= _Material_
						inst_Sub_Meshes._Material					= _Material_ --for info
					)
					(stricmp attribName "LodDistances" == 0):
					(
						_LodDistances_Name								= attribName
						_LodDistances_										= attribVal	
						inst_CDF_Attachment.n_LodDistances			= _LodDistances_
						
						
						if ::g_CDF_Report then ( format "\tLodDistances: % = %\n"	_LodDistances_Name	_LodDistances_ ) --report
					)
					(stricmp attribName "Flags" == 0):
					(
						_Flags_Name										= attribName
						_Flags_												= attribVal		
						inst_CDF_Attachment.n_Flags				= _Flags_
						
						if ::g_CDF_Report then ( format "\tFlags: % = %\n"	_Flags_Name	_Flags_ ) --report
					)
					(stricmp attribName "Rotation" == 0):
					(
						_Rotation_Name										= attribName
						_Rotation_												= attribVal	
						inst_CDF_Attachment.n_Rotation				= _Rotation_
						
						if ::g_CDF_Report then ( format "\tFlags: % = %\n"	_Flags_Name	_Flags_ ) --report
					)
					(stricmp attribName "Position" == 0):
					(
						_Position_Name										= attribName
						_Position_												= attribVal
						inst_CDF_Attachment.n_Position					= _Position_
						
						if ::g_CDF_Report then ( format "\tFlags: % = %\n"	_Flags_Name	_Flags_ ) --report
					)
					(stricmp attribName "BoneName" == 0):
					(
						_BoneName_Name									= attribName
						_BoneName_											= attribVal	
						inst_CDF_Attachment.n_BoneName				= _BoneName_
						
						if ::g_CDF_Report then ( format "\tFlags: % = %\n"	_Flags_Name	_Flags_ ) --report
					)
					default:
					(									
					)
				)			
			)
			--HFR
			else if stricmp nTagString "Modifiers" == 0 then
			(
				Modifiers_count += 1
			)
			else if stricmp nTagString "Element" == 0 then
			(
				Element_count += 1
			)
			else if stricmp nTagString "enabled" then
			(				
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal

			)
			else if stricmp nTagString "guidHiPart" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "guidLoPart" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "sourceNode" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "name" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "crc32" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "targetVector" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "weight" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "draw" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "aimVector" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "length" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "stiffness" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "damping" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "forceMovementMultiplier" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "gravity" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "limitAngle" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "limitRotationAngles" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "limitPlane0" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "limitPlane1" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "drivenNode" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "originNode" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "originOffset" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "targetNode" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "targetOffset" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "upVector" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "upNode" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "upOffset" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
			else if stricmp nTagString "version" then
			(
				inst_CDF_Modifiers._set \
												nTagString: 		&nTagString \
												attribName: 		&attribName \
												attribVal:			&attribVal
			)
		)
	)
	
	if entered_Model then
	(
		Load_CDF_Model \
								inst_s_OPTIONS:				&inst_s_OPTIONS \
								g_cryFile:						&g_cryFile \				
								nodeIsolation_arr:			&nodeIsolation_arr \
								inst_Sub_Meshes:			&inst_Sub_Meshes \
								inst_CDF_Model:				&inst_CDF_Model \
								inst_CDF_Attachment:		&inst_CDF_Attachment \
								inst_CDF_Modifiers:			&inst_CDF_Modifiers
	)
	else if entered_Attachment then
	(
		if (stricmp _Type_ "CA_SKIN") == 0  then
		(
			Load_CDF_Attachment \
											typeCaller:						"CA_SKIN" \
											inst_s_OPTIONS:				&inst_s_OPTIONS \
											g_cryFile:						&g_cryFile \
											nodeIsolation_arr:			&nodeIsolation_arr \
											inst_Sub_Meshes:			&inst_Sub_Meshes \
											inst_CDF_Model:				&inst_CDF_Model \
											inst_CDF_Attachment:		&inst_CDF_Attachment \
											inst_CDF_Modifiers:			&inst_CDF_Modifiers
		)
		else if (stricmp _Type_ "CA_BONE") == 0 then
		(
			Load_CDF_Attachment \
											typeCaller:						"CA_BONE" \
											inst_s_OPTIONS:				&inst_s_OPTIONS \
											g_cryFile:						&g_cryFile \
											nodeIsolation_arr:			&nodeIsolation_arr \
											inst_Sub_Meshes:			&inst_Sub_Meshes \
											inst_CDF_Model:				&inst_CDF_Model \
											inst_CDF_Attachment:		&inst_CDF_Attachment \
											inst_CDF_Modifiers:			&inst_CDF_Modifiers
		)
	)
-- 	
	entered_Model 			= false
	entered_Attachment 	= false
)

fn LOAD_CDF_ASSETS \								
								&inst_Sub_Meshes: \
								&inst_xmlB_PROCESSOR: \
								&g_cryFile: \
								&inst_s_OPTIONS: =
(
	inst_xmlB_PROCESSOR.cry_CDF_xmlB_ASSETS_loader_ReaderV \
																						CDF_File:				&g_cryFile \
																						inst_s_OPTIONS:		&inst_s_OPTIONS \
																						type:						(getFilenameType g_cryFile)	

	--We create it here because there should only be one model node for each CDF
	inst_CDF_Model				= CDF_Model() 		--create instance of Modifiers nodes - this is probably always .chr file (which is just a helper and proxy)
	
	if ::g_inst_CDF_Attribs.count > 0 then
	(
		format "We have successfully filled the ::g_inst_CDF_Attribs!\n"
		format "We are now ready to load the assets from the .cdf file...\n\n"
		
		local uniqueNodes_arr = #()
		for i=1 to ::g_inst_CDF_Attribs.count do
		(
			--Model Node will be = 0, and so will all its associated attributes
			--However, "Attachment" nodes are more than one, and will have different idx's
			local idx							= ::g_inst_CDF_Attribs[i].idx
			
			AppendifUnique uniqueNodes_arr idx
		)		
		print uniqueNodes_arr
				
		for i=1 to uniqueNodes_arr.count do
		(
			local nodeIsolation_arr = #()				
			local uIDX					= uniqueNodes_arr[i]
				
			for ii=1 to ::g_inst_CDF_Attribs.count do
			(
				if uIDX == ::g_inst_CDF_Attribs[ii].idx do
				(
					Append nodeIsolation_arr ::g_inst_CDF_Attribs[ii]
				)
			)
			
			---------------------------- Create Instance Structs ----------------------------
			inst_CDF_Attachment 		= CDF_Attachment() 	--create a new instance of Attachment nodes
			inst_CDF_Modifiers			= CDF_Modifiers() 		--create a new instance of Modifiers nodes	
			
-- 			*inst_Sub_Meshes* is/was already created inside *cryFile_CDF_loader* (see function below)
			--------------------------------------------------------------------------------------	
			
			ISOLATED_CDF_NODE_LOADER \
														inst_s_OPTIONS:				&inst_s_OPTIONS \
														g_cryFile:						&g_cryFile \										
														nodeIsolation_arr:			&nodeIsolation_arr \
														inst_Sub_Meshes:			&inst_Sub_Meshes \
														inst_CDF_Model:				&inst_CDF_Model \
														inst_CDF_Attachment:		&inst_CDF_Attachment \
														inst_CDF_Modifiers:			&inst_CDF_Modifiers
		)	
	)
)

fn cryFile_CDF_loader \
								&g_cryFile: =
(	
	get_game_dirPath()

	if ::g_dirpath != undefined then
	(
		if pathConfig.isLegalPath ::g_dirpath then
		(
			if g_cryFile != undefined then
			(
				if doesfileexist g_cryFile then
				(
					Reset_Arrays()					
					
					--//////////////////////////////////////////////////////////////////////////////////
					setINISetting 	::g_iniFile 	"paths" ("g_cryFile"+(getFilenameType g_cryFile)) 	::g_cryFile
					
					if (stricmp (getFilenameType g_cryFile) ".cdf") == 0 then
					(
						setINISetting 	::g_iniFile 	"paths" ("CDF_load") 										::g_cryFile --we will use this for loading the material xmlB
					)
					else if (stricmp (getFilenameType g_cryFile) ".chrparams") == 0 then
					(
						setINISetting 	::g_iniFile 	"paths" ("CHRPARAMS_load") 								::g_cryFile --we will use this for loading the material xmlB
					)
					
					inst_s_OPTIONS = s_OPTIONS()	--create instance			
					if ::g_dds then
					(
						inst_s_OPTIONS.chk_dds = ::g_dds 		
					)

					inst_xmlB_PROCESSOR = xmlB_PROCESSOR()
					
					if ::g_xmlB_Report 						then 	( inst_xmlB_PROCESSOR.report 							= true )				
					if ::g_xmlB_Debug_Report				then 	( inst_xmlB_PROCESSOR.xmlB_Debug_Report 		= true )
					if ::g_Build_Material_Report 			then 	( inst_xmlB_PROCESSOR.Build_Material_Report 		= true )	
					if ::g_skip_Lod_Materials				then 	( inst_xmlB_PROCESSOR.skip_Lod_Materials 			= true )	
					if ::g_xmlB_Report_v2					then 	( inst_xmlB_PROCESSOR.xmlB_Report_v2 				= true )
					
					--CDF
					if 	(stricmp (getFilenameType g_cryFile) ".cdf" ) == 0 OR \
						(stricmp (getFilenameType g_cryFile) ".chrparams" ) == 0 then --Character Definition File .cdf or .chrparams
					(
						--We start this storage here
						local inst_Sub_Meshes 		= Sub_Meshes()		
						
						----------------------------------- Load CDF Assets -----------------------------------
						LOAD_CDF_ASSETS \													
													inst_Sub_Meshes:			&inst_Sub_Meshes \
													inst_xmlB_PROCESSOR:		&inst_xmlB_PROCESSOR \
													g_cryFile:						&::g_cryFile \
													inst_s_OPTIONS:				&inst_s_OPTIONS													
						-------------------------------------------------------------------------------------------				
					)					
				)
			)
		)
	)	
)
