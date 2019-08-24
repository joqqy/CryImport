fn report =	
(
	-----------		-----------		-----------		-----------		-----------		-----------		-----------		-----------		-----------		-----------
	format "\n -------------::g_FILE_HEADER-------------:\n"
	print ::g_FILE_HEADER
	Append ::g_report ::g_FILE_HEADER
	
	format "\n -------------::g_CHUNKTABLE_FILE_CONSTANTS-------------:\n"
	print ::g_CHUNKTABLE_FILE_CONSTANTS
	Append ::g_report ::g_CHUNKTABLE_FILE_CONSTANTS
	
	-----------------------------------------------------------------------------
	format "\n -------------::g_CHUNKTABLE_0744_0745-------------:\n"
	print ::g_CHUNKTABLE_0744_0745
	Append ::g_report ::g_CHUNKTABLE_0744_0745
					
		format "\n -------------::g_CHUNKTABLE_0744_0745[i].ChunkType-------------: \n"
		print ::g_CHUNKTABLE_0744_0745[1].ChunkType
		Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkType
						
		format "\n -------------::g_CHUNKTABLE_0744_0745[i].ChunkVersion-------------: \n"
		print ::g_CHUNKTABLE_0744_0745[1].ChunkVersion
		Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkVersion
						
		format "\n -------------::g_CHUNKTABLE_0744_0745[i].FileOffset-------------: \n"
		print ::g_CHUNKTABLE_0744_0745[1].FileOffset
		Append ::g_report ::g_CHUNKTABLE_0744_0745[1].FileOffset
						
		format "\n -------------::g_CHUNKTABLE_0744_0745[i].ChunkID-------------: \n"
		print ::g_CHUNKTABLE_0744_0745[1].ChunkID
		Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkID
						
		format "\n -------------::g_CHUNKTABLE_0744_0745[i].ChunkPlusDescr_size-------------: \n"
		print ::g_CHUNKTABLE_0744_0745[1].ChunkPlusDescr_size
		Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkPlusDescr_size			
		-----------------------------------------------------------------------------
					
	format "\n -------------::g_MTL_NAME_CHUNK_DESC-------------:\n"
	print ::g_MTL_NAME_CHUNK_DESC
	Append ::g_report ::g_MTL_NAME_CHUNK_DESC
	
	format "\n -------------::g_MTL_NAME_CHUNK_DESC_0800-------------:\n"
	print ::g_MTL_NAME_CHUNK_DESC_0800
	Append ::g_report ::g_MTL_NAME_CHUNK_DESC_0800

	format "\n -------------::g_MESH_SUBSETS_CHUNK_DESC_0800-------------:\n"
	print ::g_MESH_SUBSETS_CHUNK_DESC_0800
	Append ::g_report ::g_MESH_SUBSETS_CHUNK_DESC_0800
					
	for s=1 to ::g_MESH_SUBSETS_CHUNK_DESC_0800.count do
	(
		format "\n -------------::g_MESH_SUBSETS_CHUNK_DESC_0800[s].MeshSubsetsArr-------------:\n"			
		print ::g_MESH_SUBSETS_CHUNK_DESC_0800[s].MeshSubsetsArr
		Append ::g_report ::g_MESH_SUBSETS_CHUNK_DESC_0800[s].MeshSubsetsArr
						
		format "\n -------------::g_MESH_SUBSETS_CHUNK_DESC_0800[s].ChunkHeadersArr-------------:\n"
		print ::g_MESH_SUBSETS_CHUNK_DESC_0800[s].ChunkHeadersArr
		Append ::g_report ::g_MESH_SUBSETS_CHUNK_DESC_0800[s].ChunkHeadersArr
	)			
					
	format "\n -------------::g_NODE_CHUNK_DESC_0824-------------:\n"
	print ::g_NODE_CHUNK_DESC_0824
	Append ::g_report ::g_NODE_CHUNK_DESC_0824
					
	format "\n -------------::g_MESH_CHUNK_DESC_0801-------------:\n"
	print ::g_MESH_CHUNK_DESC_0801
	Append ::g_report ::g_MESH_CHUNK_DESC_0801
					
	format "\n -------------::g_FOLIAGE_INFO_CHUNK_DESC-------------:\n"
	print ::g_FOLIAGE_INFO_CHUNK_DESC
	Append ::g_report ::g_FOLIAGE_INFO_CHUNK_DESC
	-----------		-----------		-----------		-----------		-----------		-----------		-----------		-----------		-----------		-----------
)

fn store_report =	
(
	if ::_LOADEDm != unsupplied then
	(
		try
		(
			-----------		-----------		-----------		-----------		-----------		-----------		-----------
			Append ::g_report ::g_FILE_HEADER
			Append ::g_report ::g_CHUNKTABLE_FILE_CONSTANTS
			-----------------------------------------------------------------------------
			Append ::g_report ::g_CHUNKTABLE_0744_0745					
			(
				Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkType
				Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkVersion
				Append ::g_report ::g_CHUNKTABLE_0744_0745[1].FileOffset
				Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkID
				Append ::g_report ::g_CHUNKTABLE_0744_0745[1].ChunkPlusDescr_size			
				-----------------------------------------------------------------------------	
			)	

			Append ::g_report ::g_MTL_NAME_CHUNK_DESC
			Append ::g_report ::g_MTL_NAME_CHUNK_DESC_0800
			Append ::g_report ::g_MESH_SUBSETS_CHUNK_DESC_0800
							
			for s=1 to ::g_MESH_SUBSETS_CHUNK_DESC_0800.count do
			(
				Append ::g_report ::g_MESH_SUBSETS_CHUNK_DESC_0800[s].MeshSubsetsArr
				Append ::g_report ::g_MESH_SUBSETS_CHUNK_DESC_0800[s].ChunkHeadersArr
			)

			Append ::g_report ::g_NODE_CHUNK_DESC_0824
			Append ::g_report ::g_MESH_CHUNK_DESC_0801
			Append ::g_report ::g_FOLIAGE_INFO_CHUNK_DESC
			-----------		-----------		-----------		-----------		-----------		-----------		-----------
		)
		catch
		(
			format "\n\n\n\n*** *** *** *** *** ***  Could not store report ***  *** *** *** *** *** ***\n"
			format "%" (getCurrentException())
			format "\n*** *** *** *** *** *** END OF Could not store report *** *** *** *** *** *** *** ***\n\n\n\n"
		)
	)
)