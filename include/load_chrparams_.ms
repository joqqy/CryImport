
fn isolated_CHRPARAMS_Attribs \
											isolated_Node: =
(	
	if isolated_Node.count == 2 then
	(
		for i=1 to isolated_Node.count do
		(
			attribName 		= isolated_Node[i][1]
			attribVal		 	= isolated_Node[i][2]
			
			--i==1 because "name" should always come before "path"
			if (stricmp attribName "name") == 0 AND \
				i == 1 then
			(
				case of
				(
					--If we discover more tokens, then we will add them, but these are all I have found so far.
					--In newer versions of CryEngine, I think the .caf files will be deprecated, but they are still used as ***on-demand assets***
					
					( stricmp attribVal "$TracksDatabase" == 0)	:
					(
						TracksDatabase 			= isolated_Node[i+1][2]
						TracksDatabase_path 	= pathConfig.resolvePathSymbols (pathConfig.AppendPath ::g_dirPath TracksDatabase) --build full path
						format "TracksDatabase_path ($TracksDatabase): %\n" TracksDatabase_path						
					)
					( stricmp attribVal "#filepath" == 0):
					(
						filepath 			= isolated_Node[i+1][2]
						filepath_path 	= pathConfig.resolvePathSymbols (pathConfig.AppendPath ::g_dirPath filepath) --build full path
						format "filepath_path (#filepath): %\n" filepath_path
					)
					( stricmp attribVal "$AnimEventDatabase" == 0):
					(
						AnimEventDatabase 			= isolated_Node[i+1][2]
						AnimEventDatabase_path 	= pathConfig.resolvePathSymbols (pathConfig.AppendPath ::g_dirPath AnimEventDatabase) --build full path
						format "AnimEventDatabase_path ($AnimEventDatabase): %\n" AnimEventDatabase_path
					)
					( stricmp attribVal "\x2A" == 0): -- \x2A == *
					(
						CAF_pattern 			= isolated_Node[i+1][2]						
						format "CAF_pattern: %\n" CAF_pattern
					)
					default:
					(
						CAF_File 			= isolated_Node[i+1][2]
						CAF_File_path 	= pathConfig.resolvePathSymbols (pathConfig.AppendPath ::g_dirPath CAF_File) --build full path
						format "CAF_File_path: %\n" CAF_File_path
					)					
				)
			)
		)
	)
	
)

fn populate_Animation_Tracks =
(
	local arr 			= #()
	local chrParams 	= ::g_inst_CHRPARAMS_Attribs	
	local unique_nodeIDs = #()
				
	for i=1 to chrParams.count do
	(
		local nodeID = 0		
		nodeID = chrParams[i].nodeID		
		AppendifUnique unique_nodeIDs nodeID
	)
	
	for i=1 to unique_nodeIDs.count do
	(			
		local UnodeID = unique_nodeIDs[i]		
		local isolated_Node = #()
		local nTagString = ""
		
		if ::rollout_Report.chk_Anim_Report.state then ( print "//////////////////////////////////////////////\n" ) --report
		for idx=1 to chrParams.count do
		(
			if chrParams[idx].nodeID == UnodeID then
			(
				local attribName 		= chrParams[idx].attribName[1]
				local attribVal			= chrParams[idx].attribVal[1]
				
				nTagString 				= chrParams[idx].nTagString
				
				Append isolated_Node #(attribName, attribVal)
				
				if ::rollout_Report.chk_Anim_Report.state then --report
				(				
					print chrParams[idx].nodeID
					print chrParams[idx].nTagString
					print chrParams[idx].attribName[1]
					print chrParams[idx].attribVal[1]
				)				
			)
		)
		if ::rollout_Report.chk_Anim_Report.state then ( print "\n" ) --report
		
		if (stricmp nTagString "Animation") == 0 then
		(
			print "//////////////////////////////////////////////\n"		
			isolated_CHRPARAMS_Attribs \
													isolated_Node:isolated_Node
			print "\n"
		)
	)	
)

fn load_CHRPARAMS_into_List =
(
	------------------------------------------------------------------------------
	try
	(
		RemoveRollout  	::rollout_AnimationTracks 		::CRYOP			
	)
	catch
	()
	rollout rollout_AnimationTracks "Animation Tracks" width:290 height:20 category:5
	(
		dropdownList 'ddl_Animation_Tracks' "Animation Tracks" pos:[8,20] width:265 height:30 items:#() align:#left
			
		on rollout_AnimationTracks open do
		(
			populate_Animation_Tracks ()
				
-- 			ddl_Animation_Tracks.items = populate_Animation_Tracks()
		)
	)				
	AddRollout  	::rollout_AnimationTracks 		::CRYOP rolledUp:true		
	------------------------------------------------------------------------------
)

fn CAF_read \
					caller: \
					g_cryFile: =
(
	load_global_CAF_arrays()	
	-----------------------------------------------------------------------------------
	inst_GAHCAF_PROCESSOR = GAHCAF_PROCESSOR()
	inst_GAHCAF_PROCESSOR.load_CAF \
													caller:caller \
													CAF_file:g_cryFile
	-----------------------------------------------------------------------------------
	store_global_CAF_arrays \
										fileType:(getFilenameType g_cryFile)
	set_CAF_states \
							type:(getFilenameType g_cryFile)
)