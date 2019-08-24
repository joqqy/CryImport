/* 
The information regarding all the resources of a level are stored in the resourcelist.txt and auto_resourcelist.txt.
These files are generated by an automatic testing system which loads each level and executes a prerecorded playthrough on it.
These resourcelist files are used during the build phase to generate the level paks. 
http://docs.cryengine.com/display/SDKDOC4/Streaming+System
*/

struct build_resource_db
(
	fn dotNet_readLines \
								&g_db_type: \
								&db_File: \
								&fstream: \
								&streamReader: \
								&auto_resourcelist: =
	(
		local mtl_Line = ""

		while mtl_Line != undefined do
		(
			mtl_Line = streamReader.ReadLine()
									
			if mtl_Line != undefined then
			(
				if  stricmp(getFilenameType mtl_Line) ("." + g_db_type) == 0 then
				(						
					format "%\n" mtl_Line to:fstream
				)
			)
		)
		StreamReader.Close() --Close dotNet stream
	),
	
	fn dotNet_readLines_dds0 \
										&g_db_type: \
										&db_File: \
										&fstream: \
										&streamReader: \
										&auto_resourcelist: =
	(
		local mtl_Line = ""

		while mtl_Line != undefined do
		(
			mtl_Line = streamReader.ReadLine()
									
			if mtl_Line != undefined then
			(
				if (matchpattern  mtl_Line pattern:("*" + "." + g_db_type)) then
				(						
					format "%\n" mtl_Line to:fstream
				)
			)
		)
		StreamReader.Close() --Close dotNet stream
	),
	
	fn dotNet_readLines_filtered \
											filterToken: \
											&g_db_type: \
											&db_File: \
											&fstream: \
											&streamReader: \
											&auto_resourcelist: =
	(
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
					
					if  stricmp(getFilenameType str) ("." + g_db_type) == 0 then
					(						
						format "%\n" str to:fstream
					)
				)
			)
		)
		StreamReader.Close() --Close dotNet stream
	),
	
	fn builder \
					&g_db_type: =
	(
		format "Attempting to create .% database, please wait...\n" g_db_type
		print ::g_auto_resourcelist_array
		
		if 	::g_db_type != "" then
		(
			if ::g_auto_resourcelist_array.count == 0 then
			(
				::g_auto_resourcelist_array = getFilesRecursive \
																					root:			(::g_dirPath) \
																					specDir:		"Levels" \
																					targetFile:	"auto_resourcelist.txt"
			)
			
			if (stricmp ::g_db_type "tif") == 0 then
			(
				if ::g_perlayerresourcelist_array.count == 0 then
				(
					::g_perlayerresourcelist_array = getFilesRecursive \
																					root:			(::g_dirPath) \
																					specDir:		"Levels" \
																					targetFile:	"perlayerresourcelist.txt"
				)
			)
		)
		
		local db_dir = pathConfig.resolvePathSymbols (::g_scriptRoot + "\\db")
		local db_name = g_db_type + "_db.txt"
		local db_File = pathConfig.resolvePathSymbols (pathConfig.AppendPath 	db_dir 	db_name)
		
		local resourceLists = #()	
		
		if 	(stricmp ::g_db_type "mtl") == 0 OR \
			(stricmp ::g_db_type "dds") == 0 then
		(
			resourceLists = ::g_auto_resourcelist_array	
		)
		else if (stricmp ::g_db_type "tif") == 0 then
		(
			resourceLists = ::g_perlayerresourcelist_array	
		)
		
		local fstream = openFile db_File mode:"wt" --open filestream - text mode --deletes file contents if it exists
		----------------------------------------							
		if fstream != undefined then
		(
			if 	doesFileExist db_dir AND \
				(isDirectoryWriteable sysInfo.tempdir) then
			(
				for i=1 to resourceLists.count do
				(
					local auto_resourcelist = resourceLists[i]
					
					if doesfileexist auto_resourcelist then
					(
						local StreamReader	 	= dotNetObject "System.IO.StreamReader" auto_resourcelist --open dotNet stream
						
						if StreamReader != undefined then
						(
							if (classof StreamReader) == dotNetObject then
							(
								if (stricmp g_db_type "mtl") == 0 then
								(
									local curr_Game = (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
									format "%%\n" "game;" curr_Game  to:fstream
									
									dotNet_readLines \
															g_db_type:				&g_db_type \
															db_File: 					&db_File \
															streamReader: 		&streamReader \
															fstream:					&fstream \
															auto_resourcelist: 	&auto_resourcelist
								)
								else if (stricmp g_db_type "dds") == 0 then
								(
									local curr_Game = (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
									format "%%\n" "game;" curr_Game  to:fstream
									
									dotNet_readLines_dds0 \
																	g_db_type:				&g_db_type \
																	db_File: 					&db_File \
																	streamReader: 		&streamReader \
																	fstream:					&fstream \
																	auto_resourcelist: 	&auto_resourcelist
								)
								else if (stricmp g_db_type "tif") == 0 then
								(
									local curr_Game = (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
									format "%%\n" "game;" curr_Game  to:fstream
									
									dotNet_readLines_filtered \
																		filterToken: 			";" \
																		g_db_type:				&g_db_type \
																		db_File: 					&db_File \
																		streamReader: 		&streamReader \
																		fstream:					&fstream \
																		auto_resourcelist: 	&auto_resourcelist
								)						
							)
						)
					)
				)
				
				if resourceLists.count > 0 then
				(
					format "Done building .% database\n " g_db_type
				)
				else
				(
					format "We could not find the database\n "
				)
			)
			else
			(
				format "Could not build .% database - Make sure you have write permission for %\n" g_db_type (::g_scriptRoot + "\\db") 
				------------------------------------------------------------------------------
				try
				(	
					DestroyDialog 		::rollout_Alert							
				)
				catch
				()
				rollout rollout_Alert "Alert" width:290 height:85 category:9
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
					on rollout_Alert open do
					(
						local arr = #()						
						Append arr "Could not create a database,"
						Append arr "because the directory is not writeable!"
						lbx_Message_Alert.items = arr
					)
					on rollout_Alert rolledUp state do
					(
						if NOT state then
						(
							--closed
							::CRYOP.size = [::CRYOP.size[1], ::CRYOP.size[2]-rollout_Alert.height]
						)
						else
						(
							--open
							::CRYOP.size = [::CRYOP.size[1], ::CRYOP.size[2]+rollout_Alert.height]
						)
					)
				)				
				AddRollout 		::rollout_Alert 			::CRYOP rolledUp:false						
				------------------------------------------------------------------------------	
			)
		)
		----------------------------------------
		close fstream --close filestream - text mode
		
		::g_db_type = ""
	),

	fn SCAN_builder =
	(
		format "Attempting to create SCAN database, please wait...\n"
		
		local db_dir 		= pathConfig.resolvePathSymbols (::g_scriptRoot + "\\db") --the database directory
		--the db files we will create
		local mtl_db 		= "mtl_db.txt" 
		local dds_db 		= "dds_db.txt"
		
		
		local db_arr = #()
		Append db_arr (pathConfig.resolvePathSymbols (pathConfig.AppendPath 	db_dir 	mtl_db))
		Append db_arr (pathConfig.resolvePathSymbols (pathConfig.AppendPath 	db_dir 	dds_db))
			
		print db_arr
		
		for f=1 to db_arr.count do
		(
			local FMask = "*.*"
			
			if (filterstring (filenameFromPath db_arr[f]) "_")[1] == "mtl" then
			(
				FMask = "*.mtl"
			)
			else if (filterstring (filenameFromPath db_arr[f]) "_")[1] == "dds" then
			(
				FMask = "*.dds"
			)
			format "FMask: %\n" FMask
			
			
			local fstream = openFile db_arr[f] mode:"wt" --open filestream - text mode --deletes file contents if it exists
			----------------------------------------
			if 	doesFileExist db_dir AND \
				(isDirectoryWriteable sysInfo.tempdir) then
			(
				local Directory	 		= dotNetClass 		"System.IO.Directory"
				local dir 					= dotNetObject  		"System.String"	::g_dirpath
				local type 					= dotNetObject 		"System.String" 	FMask
				local searchOption 		= dotNetClass 		"System.IO.SearchOption"
				
				local files_arr 						= Directory.GetFiles 	dir 	type		searchOption.AllDirectories
				
				local curr_Game = (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
				format "%%\n" "game;" curr_Game  to:fstream
				
				for x in files_arr do
				(
					suffix = getFilenameType x
					
					if (stricmp suffix (trimleft FMask "*")) == 0 then
					(					
						local rel_path 		= pathConfig.convertPathToRelativeTo x 	::g_dirpath	
						
						format "%\n" (trimleft rel_path ".\\") to:fstream
					)
				)
			)
			----------------------------------------
			close fstream --close filestream - text mode			
		)
	)	
)