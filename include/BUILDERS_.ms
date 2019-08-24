
struct sset
(
	_set 		= 0,
		
	_end 		= #(),
	_start 	= #()
)

struct assetTypes
(
	g_cryFile		= "",
	last_Loaded 	= "",
	first_Loaded 	= "",
	fileType1 		= "",
	fileType2 		= ""
)

struct Mesh_Bone_Parent
(
	m_nControllerID 	= undefined,
	msh					= undefined
)

struct BUILDERS
(
	
	fn verbose_Mesh_Info \
									&_LOADED:	\
									&_LOADEDm: \
									&nstream: \
									&inst_Sub_Meshes: =
	(
		--////////////////////////////////// Export Flags if present //////////////////////////////////
 		--//////////////////////////////////////////////////////////////////////////
 		--// Custom Attributes chunk description.
 		--//////////////////////////////////////////////////////////////////////////
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_EXPORT_FLAGS_CHUNK_DESC[1] != undefined then
		(
			if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_EXPORT_FLAGS_CHUNK_DESC[1].flags == 0x0001 then
			(
				format "MERGE_ALL_NODES, see CryHeaders.h 1220\n"
			)
			else if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_EXPORT_FLAGS_CHUNK_DESC[1].flags == 0x0002 then
			(
				format "HAVE_AUTO_LODS, see CryHeaders.h 1220\n"
			)
			else if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_EXPORT_FLAGS_CHUNK_DESC[1].flags == 0x0004 then
			(
				format "USE_CUSTOM_NORMALS, see CryHeaders.h 1220\n"
			)
			else if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_EXPORT_FLAGS_CHUNK_DESC[1].flags == 0x0008 then
			(
				format "WANT_F32_VERTICES, see CryHeaders.h 1220\n"
			)
			else if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_EXPORT_FLAGS_CHUNK_DESC[1].flags == 0x0010 then
			(
				format "EIGHT_WEIGHTS_PER_VERTEX, see CryHeaders.h 1220\n"
			)
		)
		
		
		--////////////////////////////////// MESH_CHUNK_DESC_0801 //////////////////////////////////
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nFlags == 0x01 then
		(
			format "FLAG1_BONE_INFO, see CryHeaders.h 587\n"
		)
			
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nFlags2 == 0x01 then
		(
			format "MESH_IS_EMPTY, see CryHeaders.h 587\n"
		)
		else if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nFlags2 == 0x02 then
		(
			format "HAS_TEX_MAPPING_DENSITY, see CryHeaders.h 587\n"
		)
		else if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nFlags2 == 0x04 then
		(
			format "HAS_EXTRA_WEIGHTS, see CryHeaders.h 587\n"
		)
		else if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nFlags2 == 0x08 then
		(
			format "HAS_FACE_AREA, see CryHeaders.h 587\n"
		)
		
		format "nStreamChunkID: %\n" _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID
	),
	
	fn delete_iso_vertices \
									&msh: =
	(
		--////////////////////// Delete isolated vertices for static assets if chosen by the user //////////////////////
		if ::cryImport.chk_deleteISOvertices.state then
		(
			if 	isvalidNode msh AND \
			(classof msh) == Editable_Mesh then
			(
				format "Deleting isolated vertices...Please Wait...\n"
				meshop.deleteIsoVerts msh
			)
		)
	),
	
	fn sortObjects_to_layers \
										&msh: =
	(
		if (matchpattern msh.name pattern:"*proxy*") then
		(
			proxyLayer 						= "proxy"
			
			if (LayerManager.getLayerFromName proxyLayer) != undefined then
			(
				if classof (LayerManager.getLayerFromName proxyLayer) == MixinInterface then --if the layer already exists
				(
					theLayer = LayerManager.getLayerFromName proxyLayer		
					if isValidNode msh then
					(
						theLayer.addNode msh
					)	
				)
			)
			else
			(
				local newLayer				= LayerManager.newLayerFromName proxyLayer --create a new layer
				if isValidNode msh then
				(
					newLayer.addNode msh
				)	
				newLayer.ishidden = true
			)
		)
		else if (matchpattern msh.name pattern:"*remain*")  then
		(
			destructiblesLayer 		= "destructibles"
			
			
			if (LayerManager.getLayerFromName destructiblesLayer) != undefined then --if the layer already exists
			(
				if classof (LayerManager.getLayerFromName destructiblesLayer) == MixinInterface then
				(
					theLayer = LayerManager.getLayerFromName destructiblesLayer	
					if isValidNode msh then
					(
						theLayer.addNode msh
					)	
				)
			)
			else
			(
				local newLayer				= LayerManager.newLayerFromName destructiblesLayer --create a new layer
				if isValidNode msh then
				(
					newLayer.addNode msh
				)	
				newLayer.ishidden = true
			)
		)
		else if (matchpattern msh.name pattern:"*$LOD*")  then
		(
			LOD_Layer 		= "LODs"			
			
			if (LayerManager.getLayerFromName LOD_Layer) != undefined then --if the layer already exists
			(
				if classof (LayerManager.getLayerFromName LOD_Layer) == MixinInterface then
				(
					theLayer = LayerManager.getLayerFromName LOD_Layer	
					if isValidNode msh then
					(
						theLayer.addNode msh
					)	
				)
			)
			else
			(
				local newLayer				= LayerManager.newLayerFromName LOD_Layer --create a new layer
				if isValidNode msh then
				(
					newLayer.addNode msh
				)	
				newLayer.ishidden = true
			)
		)
	),

	--Unused
	fn get_meshSubSets_idx \
										&_LOADED: \
										&_LOADEDm: \
										&nstream: \
										&nCount: \
										&inst_assetTypes: \
										&nFirstIndexId: \
										&nNumIndices: \ 
										&nFirstVertId: \
										&nNumVerts: \
										&nMatID: \
										&faces: \
										&verts: \
										&normals: \
										&UV: \
										&msh:  \								
										&subSet: \
										&inst_Sub_Meshes: =
	(	
		if inst_Sub_Meshes.CA_SKIN_counter > 0 then 
		(
			idx_faceSets = #()
			
			for s=1 to _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType.count do
			(
				inst_sset = sset()
				inst_sset._set = s
				
				if 	_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[1] > 0 AND \ --we check that there are indeed CGF_STREAM_POSITIONS
					_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[6] > 0 then --we check that there are indeed CGF_STREAM_INDICES
				(				
					local curr_TargetSign = true --if false, then we will look for positive signs --we start with looking for negative signs
					
					--We look for the sign of the third index for each triangle
					--/*
					for i=1 to _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES.count do
					(
						local a = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i][1]
						local b = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i][2]	
						local c = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i][3]		

						if curr_TargetSign then --we search for negative 3rd index
						(
							if a >= 1 AND b >= 1 AND c <= 0 then
							(
								curr_TargetSign = false
								Append inst_sset._end i --end of subset
								if i < _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES.count then
								(
									a = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i+1][1]
									b = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i+1][2]	
									c = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i+1][3]
									
									if a <= 0 AND b <= 0 AND c >= 1 then
									(
										Append inst_sset._start (i+1) --start of next subset
										continue;
									)
								)
							)
						)
						else --we search for positive 3rd index
						(
							if a >= 1 AND b >= 1 AND c >= 1 then
							(
								curr_TargetSign = true
								Append inst_sset._end (i-1) --end of subset
								Append inst_sset._start i --end of subset
	-- 							if i < _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES.count then
	-- 							(
	-- 								a = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i+1][1]
	-- 								b = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i+1][2]	
	-- 								c = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES[i+1][3]
	-- 								
	-- 								if a >= 1 AND b >= 1 AND c <= 0 then
	-- 								(
	-- 									Append inst_sset._start (i+1) --start of next subset
	-- 									continue;
	-- 								)
	-- 							)
							)
						)
					)
					--*/
				)
				
				Append idx_faceSets inst_sset
			)
			
			print "############################################"
			print idx_faceSets
			print "############################################"
		)

		return idx_faceSets;
	),

	--Here we construct the subarray subSet which we will supply to BUILDER so that it can build the mesh subsets
	fn get_subSet_arrays \
									&_LOADED: \
									&_LOADEDm: \
									&nstream: \
									&nCount: \
									&inst_assetTypes: \
									&nFirstIndexId: \
									&nNumIndices: \ 
									&nFirstVertId: \
									&nNumVerts: \
									&nMatID: \
									&faces: \
									&verts: \
									&normals: \
									&UV: \
									&msh:  \								
									&subSet: \
									&inst_Sub_Meshes: =
	(	
		verbose_Mesh_Info \
									_LOADED:							&_LOADED \
									_LOADEDm:							&_LOADEDm \
									nstream:							&nstream \
									inst_Sub_Meshes:				&inst_Sub_Meshes
		
		local indices 	= #()
		local vertices 	= #()
		local matIDs	= #()
		local _tverts	= #()

		local matID_offset = 1
		
		if ::g_CryGame_dropDown_selection == "HFR" then
		(
			--Static Assets
			if 	(stricmp inst_assetTypes.fileType1 ".cgf") == 0 OR
				(stricmp inst_assetTypes.fileType2 ".cgfm") == 0 then
			(
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
				
				if ::rollout_Report.chk_BUILDER_Report.state then
				(
					format	"\n"
					format 	"nFirstIndexId: %\n" 	nFirstIndexId
					format 	"nNumIndices: %\n" 		nNumIndices
					format 	"nFirstVertId: %\n" 		nFirstVertId
					format 	"nNumVerts: %\n" 		nNumVerts
					format 	"nMatID: %\n" 			nMatID
					format	"\n"
					
					format "subSet[1]: %\n" subSet[1]
					format "subSet[2]: %\n" subSet[2]
					format "subSet[3]: %\n" subSet[3] 
				)
				
			)
			--Skin Assets
			else if 	(stricmp inst_assetTypes.fileType1 ".cga") == 0 OR \
						(stricmp inst_assetTypes.fileType2 ".cgam") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						

						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces	
						
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
			)
			--Skin Assets
			else if 	(stricmp inst_assetTypes.fileType1 ".skin") == 0 OR \
						(stricmp inst_assetTypes.fileType2 ".skinm") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						

						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces	
						
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 							--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices			
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
			)
			else if 	(stricmp inst_assetTypes.fileType1 ".chr") == 0 OR \
						(stricmp inst_assetTypes.fileType2 ".chrm") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
			)
		)
		else if ::g_CryGame_dropDown_selection == "Armored Warfare" then
		(
			--Static Assets
			if 	(stricmp inst_assetTypes.fileType1 ".cgf") == 0 OR
				(stricmp inst_assetTypes.fileType2 ".cgfm") == 0 then
			(
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
	-- 			Append 	subSet 	faces 	--subset faces
				-----------------------------------2--------------------------------------
	-- 	 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------			
				Append 	subSet	matIDs	--matIDs matching the subset faces count
	-- 			Append 	subSet	UV	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
				
				if ::rollout_Report.chk_BUILDER_Report.state then
				(
					format	"\n"
					format 	"nFirstIndexId: %\n" 	nFirstIndexId
					format 	"nNumIndices: %\n" 		nNumIndices
					format 	"nFirstVertId: %\n" 		nFirstVertId
					format 	"nNumVerts: %\n" 		nNumVerts
					format 	"nMatID: %\n" 			nMatID
					format	"\n"
					
					format "subSet[1]: %\n" subSet[1]
					format "subSet[2]: %\n" subSet[2]
					format "subSet[3]: %\n" subSet[3] 
				)
				
			)
			--Skin Assets
			else if 	(stricmp inst_assetTypes.fileType1 ".cga") == 0 OR \
						(stricmp inst_assetTypes.fileType2 ".cgam") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						

						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces	
						
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
			)
			--Skin Assets
			else if 	(stricmp inst_assetTypes.fileType1 ".skin") == 0 OR \
						(stricmp inst_assetTypes.fileType2 ".skinm") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						

						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces	
						
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
			)
			else if 	(stricmp inst_assetTypes.fileType1 ".chr") == 0 OR \
						(stricmp inst_assetTypes.fileType2 ".chrm") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------	
			)
		)
		else
		(
			--Static Assets
			if 	(stricmp inst_assetTypes.fileType1 ".cgf") == 0 AND
				(stricmp inst_assetTypes.fileType2 ".cgfm") == 0 then
			(
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
				
				if ::rollout_Report.chk_BUILDER_Report.state then
				(
					format	"\n"
					format 	"nFirstIndexId: %\n" 	nFirstIndexId
					format 	"nNumIndices: %\n" 		nNumIndices
					format 	"nFirstVertId: %\n" 		nFirstVertId
					format 	"nNumVerts: %\n" 		nNumVerts
					format 	"nMatID: %\n" 			nMatID
					format	"\n"
					
					format "subSet[1]: %\n" subSet[1]
					format "subSet[2]: %\n" subSet[2]
					format "subSet[3]: %\n" subSet[3] 
				)
				
			)
			--Skin Assets
			else if 	(stricmp inst_assetTypes.fileType1 ".cga") == 0 AND \
						(stricmp inst_assetTypes.fileType2 ".cgam") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						

						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces	
						
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
			)
			--Skin Assets
			else if 	(stricmp inst_assetTypes.fileType1 ".skin") == 0 AND \
						(stricmp inst_assetTypes.fileType2 ".skinm") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						

						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces	
						
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------
			)
			else if 	(stricmp inst_assetTypes.fileType1 ".chr") == 0 AND \
						(stricmp inst_assetTypes.fileType2 ".chrm") == 0 then
			(					
				if nFirstIndexId == 0 then
				(
					nFirstIndexId = 3
					
					for i=(nFirstIndexId/3) to (nNumIndices/3) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)	
				)
				else
				(
					for i=(nFirstIndexId/3) to ((nFirstIndexId/3)+(nNumIndices/3)) do
					(
						Append	 	indices 	faces[i]
						Append 		matIDs	(nMatID+matID_offset) 	--create an array of same matid for all the faces		
						Append 		_tverts	UV[i] 			--unused
					)
				)
				
				/* --unused
				for i=nFirstVertId+1 to nFirstVertId+nNumVerts do
				(
					Append vertices verts[i]
				)
				--*/
			
				-----------------------------------1--------------------------------------
				Append 	subSet 	indices 	--subset faces
				-----------------------------------2--------------------------------------
		-- 		Append 	subSet 	vertices 	--subset vertices --unused
				Append 	subSet 	verts 		--all vertices
				-----------------------------------3--------------------------------------
				Append 	subSet	matIDs	--matIDs matching the subset faces count
				-----------------------------------4--------------------------------------
				Append 	subSet 	_tverts 	--unused
				-------------------------------------------------------------------------	
			)
		)
	),

	fn translate_mesh \
								&matrix: \
								&msh: \
								&m_nControllerID: =
	(										
		local theTransform 		= msh.transform
		theTransform.row4 		= matrix.row4
		msh.transform 			= theTransform	
		
		inst_Mesh_Bone_Parent 								= Mesh_Bone_Parent()	
		inst_Mesh_Bone_Parent.m_nControllerID 			= m_nControllerID
		inst_Mesh_Bone_Parent.msh 							= msh	
		Append 			::Mesh_Bone_Parent_arr 			inst_Mesh_Bone_Parent
	),

	fn determine_parentBone \
										&nstream: \
										&msh: \
										&AName: =
	(
		if ::g_stored_CryBoneDescData_Comp != undefined then
	-- 	if ::inst_LOADED._skin[nStream] != undefined then
		(
			if iskindof ::g_stored_CryBoneDescData_Comp Array then
	-- 		if ::inst_LOADED._skin[nStream].g_CryBoneDescData_Comp != undefined then
			(
				local g_CryBoneDescData_Comp 	= ::g_stored_CryBoneDescData_Comp
	-- 			local g_CryBoneDescData_Comp 	= ::inst_LOADED._skin[nStream].g_CryBoneDescData_Comp
				
				for x=1 to g_CryBoneDescData_Comp.count do --need crybonesdata here
				(
					local m_nControllerID		= g_CryBoneDescData_Comp[x].m_nControllerID
					local m_arrBoneName 		= g_CryBoneDescData_Comp[x].m_arrBoneName
					local m_DefaultB2W			= g_CryBoneDescData_Comp[x].m_DefaultB2W
								
					if m_arrBoneName != undefined then
					(
						if iskindof m_DefaultB2W  Matrix3 then
						(
							--We will add more A_SKIN AName if and as we identify them
							
							case of
							(
								(stricmp AName "body" == 0):
								(
									if matchpattern m_arrBoneName pattern:"*Spine2" then
									(
										translate_mesh \
																matrix: 				&m_DefaultB2W \
																msh: 					&msh \
																m_nControllerID: 	&m_nControllerID
									)										
								)
								(stricmp AName "head" == 0):
								(
									if matchpattern m_arrBoneName pattern:"*Head" then
									(
										translate_mesh \
																matrix: 				&m_DefaultB2W \
																msh: 					&msh \
																m_nControllerID: 	&m_nControllerID
									)
								)	
								(stricmp AName "head_extras" == 0):
								(
									if 	matchpattern m_arrBoneName pattern:"*Head" then
									(
										translate_mesh \
																matrix: 				&m_DefaultB2W \
																msh: 					&msh \
																m_nControllerID: 	&m_nControllerID
									)
								)
								(stricmp AName "hair" == 0):
								(
									if 	matchpattern m_arrBoneName pattern:"*Head" then
									(
										translate_mesh \
																matrix: 				&m_DefaultB2W \
																msh: 					&msh \
																m_nControllerID: 	&m_nControllerID
									)
								)
								(stricmp AName "hair_b" == 0):
								(
									if 	matchpattern m_arrBoneName pattern:"*Head" then
									(
										translate_mesh \
																matrix: 				&m_DefaultB2W \
																msh: 					&msh \
																m_nControllerID: 	&m_nControllerID
									)
								)
								(stricmp AName "hair_a" == 0):
								(
									if 	matchpattern m_arrBoneName pattern:"*Head" then
									(
										translate_mesh \
																matrix: 				&m_DefaultB2W \
																msh: 					&msh \
																m_nControllerID: 	&m_nControllerID
									)
								)
								default:
								()
							)
						)
					)
				)
			)
		)
	),

	fn translate_Mesh2Bone_byMeshName \
														&nstream: \
														&msh: =
	(
		--Translate the mesh if we can match it to a Biped Bone	
		local MeshName_filtered = filterstring msh.name "_"					
						
		for i=1 to MeshName_filtered.count do
		(		
			local AName = MeshName_filtered[i]
			
			determine_parentBone \
												nstream: 		&nstream \
												msh: 		&msh \
												AName:	&AName
		)
	),

	fn translate_Mesh2Bone \
										&nstream: \
										&msh: \
										&AName: =
	(
		determine_parentBone \
											nstream: 		&nstream \
											msh: 		&msh \
											AName:	&AName
	),

	fn translator \
						&nstream: \
						&msh: \
						&inst_CDF_Attachment: =
	(		
		if iskindof msh Editable_Mesh then
		(
			---------------------------Translate mesh 2 bone-----------------------------
			if inst_CDF_Attachment != unsupplied then
			(
				if inst_CDF_Attachment != undefined then
				(
					--print inst_CDF_Attachment.n_AName
														
					if inst_CDF_Attachment.n_AName != "" then
					(
						local AName 							=  inst_CDF_Attachment.n_AName
																	
						if AName != undefined then
						(
							translate_Mesh2Bone \
															nstream:			&nstream \
															msh: 					&msh \
															AName: 				&AName
						)
					)
					else
					(
						translate_Mesh2Bone_byMeshName \
																		nstream: 	&nstream \
																		msh: 			&msh
					)
				)
			)
			else
			(
				translate_Mesh2Bone_byMeshName \
																	nstream: 	&nstream \
																	msh: 			&msh
			)
			--------------------------------------------------------------------------------
		)		
	),
	
	fn node_Start_Orientation \
										&_LOADED: \
										&_LOADEDm: \
										&inst_Sub_Meshes: \	
										&nstream: \
										&msh: =
	(
		--pos*0.01
		
		format "pos: %\n" _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].pos
		
		if 	isvalidNode msh AND \
			(classof msh) == Editable_Mesh then
		(
			-- setNormal <mesh> <vert_index_integer> <point3>
			if classof _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].pos == point3 then --we check that there are indeed CGF_STREAM_COLORS
			(
				move msh (_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].pos*0.01)
			)
			
			-- setNormal <mesh> <vert_index_integer> <point3>
			if classof _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].rot == Quat then --we check that there are indeed CGF_STREAM_COLORS
			(
				_angle 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].rot.angle
				_axis 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].rot.axis
				rotate msh (angleAxis _angle _axis)
			)
			
			/*
			-- setNormal <mesh> <vert_index_integer> <point3>
			if classof _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].scl == point3 then --we check that there are indeed CGF_STREAM_COLORS
			(
				scale msh (_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].scl)
			)
			--*/
		)
	),

	fn Force_Skin_Translation \
										nstream: \
										nCount: \
										&msh: =
	(
		if msh != unsupplied then
		(
			if msh != undefined then
			(
				msh.transform.row4 = [0,0,0]
				
				/*
				for b=1 to ::g_stored_CryBoneDescData_Comp.count do
				(
					if (stricmp ::g_stored_CryBoneDescData_Comp[b].m_arrBoneName "Bip01 Spine2") == 0 then
					(
						local m_DefaultB2W = ::g_stored_CryBoneDescData_Comp[b].m_DefaultB2W
												
						--Translate the skin meshes to the skeleton
	-- 					local bboxMin 						= ::g_MESH_CHUNK_DESC_0801[1].bboxMin --unused
	-- 					local bboxMax 					= ::g_MESH_CHUNK_DESC_0801[1].bboxMax --unused
	-- 					local vCenter 						= ::g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[nCount].vCenter --unused
	-- 					local tm								= ::g_NODE_CHUNK_DESC_0824[1].tm --unused
	-- 					local matrix_HFR 					= ::g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].matrix_HFR --unused
						local theTransform 				= msh.transform							
												
						theTransform.row4 				= m_DefaultB2W.row4
						msh.transform 					= theTransform
												
	-- 					if ::rollout_Report.chk_BUILDER_Report.state then
	-- 					(
	-- 						format"\n"
	-- 						print "||||||||||||||||||||||||||||||||||"
	-- 						format "vCenter: %\n" 				vCenter
	-- 						format "tm: %\n" 					tm
	-- 						format "vCenter*tm: %\n" 		(vCenter*tm)
	-- 						format "\n"
	-- 						format "bboxMin: % \n" 			bboxMin
	-- 						format "bboxMax: % \n" 			bboxMax
	-- 						print "||||||||||||||||||||||||||||||||||"
	-- 						format"\n"
	-- 					)
					)
				)
				--*/
			)
		)
	),
	
	fn set_QTangents \
							&_LOADED: \
							&_LOADEDm: \
							&inst_Sub_Meshes: \	
							&nstream: \
							&nNumVerts: \
							&QTangents: \
							&msh: =
	(
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[13] > 0 then --we check that there are indeed CGF_STREAM_COLORS
		(
			local NumVerts 		= getNumVerts msh
			
			if QTangents.count <= NumVerts then	
			(
				for v=1 to QTangents.count do
				(
					local q  			= QTangents[v]
					
					if q.w < 0 then
					(
						q = -q
					)
						
					local q2m 		= q as Matrix3
					local n_q2m 	= normalize q2m.row3
					
					setNormal msh v n_q2m
				)
			)
		)
	),

	fn set_Normals \
						&_LOADED: \
						&_LOADEDm: \
						&inst_Sub_Meshes: \	
						&nstream: \
						&nNumVerts: \
						&normals: \
						&msh: =
	(
		format "Setting Vertex Normals... \n"
		
		-- 	setNormal <mesh> <vert_index_integer> <point3>
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[2] > 0 then --we check that there are indeed CGF_STREAM_COLORS
		(
			local NumVerts 		= getNumVerts msh
			
			if normals.count <= NumVerts then	
			(
				for v=1 to normals.count do
				(
					setNormal msh v normals[v]
				)
			)
		)
		
	),
	
	fn set_Tangent_Normal \
									&_LOADED: \
									&_LOADEDm: \
									&inst_Sub_Meshes: \	
									&nstream: \
									&nNumVerts: \
									&TANGENTS: \
									&msh: =
	(
		format "Setting Vertex Normals from Tangents... \n"
		
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[7] > 0 then --we check that there are indeed CGF_STREAM_COLORS
		(
			local NumVerts 		= getNumVerts msh
			
			if TANGENTS.count <= NumVerts then	
			(
				for v=1 to TANGENTS.count do
				(
					local t  			= TANGENTS[v][1]
					local b			= TANGENTS[v][2]					
					local N			= normalize (cross t b)
					
					setNormal msh v N
				)
			)
		)
	),

	fn set_VertColors \
							&_LOADED: \
							&_LOADEDm: \
							&inst_Sub_Meshes: \
							&nstream: \
							&subSet: \
							&UV: \
							&colors: \
							&colors2: \
							&msh: =
	(
		--Not sure why there are two color streams
		--maybe one is legacy for the dirt, which is now inferior to blend material
		--I am not sure, need to research this further		
		
		local game = (::cryImport.ddl_CryGame.items[::cryImport.ddl_CryGame.selection])
		
		---------------------------------------------- Set Vert Colors ----------------------------------------------
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[4] > 0 then --we check that there are indeed CGF_STREAM_COLORS
		(
			format "Setting Vertex Colors... \n"
				
			local NumVerts 		= getNumVerts msh
-- 		 	local vertList 			= #{1..NumVerts}
			
			if colors[1].count <= NumVerts then
			(		
				for v=1 to colors[1].count do
				(
					---Vertex Colors
					meshop.setVertColor 	msh 		0 		v colors[1][v] --vertex colors are at channel 0

					--Vertex Alpha
					meshop.setVertAlpha 	msh 		-2 	v colors[2][v]
					--essentially a copy of the alpha (because we cannot cycle to -2 in mapchannels in vertex color map - map -1 (illum) and -2(Alpha) are not accessible in the map channels of the material, so we copy it to channel 3
					meshop.setVertAlpha 	msh 		3 		v colors[2][v]					
				)
			)
		)
		--------------------------------------------------------------------------------------------------------------------
		
		/* --We do not know what CGF_STREAM_COLORS2 are for now -- perhaps vegetation bending stuff
		---------------------------------------------- Set Vert Colors2 Illum - Likely for Bending Vegetation ----------------------------------------------
		if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[5] > 0 then --we check that there are indeed CGF_STREAM_COLORS2
		(
			format "Setting Vertex Colors2... \n"
				
			local NumVerts 		= getNumVerts msh
-- 		 	local vertList 			= #{1..NumVerts}
												
			
			if colors2[1].count <= NumVerts then	
			(
				for v=1 to colors2[1].count do
				(						
					---Vertex Colors
					meshop.setVertColor 	msh 	0 	v 	colors2[1][v]  --vertex colors are at channel 0

					--Vertex Alpha
					meshop.setVertAlpha 	msh 	-2  v 	colors2[2][v]
					--essentially a copy of the alpha (because we cannot cycle to -2 in mapchannels in vertex color map - map -1 (illum) and -2(Alpha) are not accessible in the map channels of the material, so we copy it to channel 4
					meshop.setVertAlpha 	msh 	4 	v 	colors2[2][v] 
				)				
			)
		)
		--------------------------------------------------------------------------------------------------------------------
		--*/
	),

	fn set_texCoords \
							&_LOADED: \
							&_LOADEDm: \
							&inst_Sub_Meshes: \
							&nstream: \
							&nFirstVertId: \
							&nNumVerts: \
							&subSet: \
							&UV: \
							&colors: \
							&colors2: \
							&msh: =
	(
		--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		format "================= We will now attempt to set the UVs... =================\n"						

		------------------UVs------------------
		setNumTVerts 	msh  UV.count
		buildTVFaces 		msh
										
	-- 	--for x=1 to  UV.count do
		for x=nFirstVertId+1 to  nFirstVertId+nNumVerts do
		(
			setTVert 		msh 		x 		UV[x]
		)
						
		for x=1 to subSet[1].count do
		(
			setTVFace 		msh 		x 		subSet[1][x]
		)
		------------------------------------------
		--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		if ::rollout_Mesh_Options.chk_Vertex_Colors.state then
		(	
			set_VertColors \	
								_LOADED: 					&_LOADED \
								_LOADEDm:				 	& _LOADEDm \			
								inst_Sub_Meshes: 		&inst_Sub_Meshes \
								nstream: 					&nstream\
								verts: 						&subSet[2] \
								colors: 						&colors \
								colors2: 					&colors2 \
								msh:							&msh
		)
	),

	fn name_sort_Mesh \								
								&nstream: \
								&inst_Sub_Meshes: \
								&msh: =
	(
		if msh != unsupplied then
		(
			if msh != undefined then
			(	
				if (classof msh) == Editable_mesh then
				(
					if isValidNode msh then
					(
						-------------------------------- Name the mesh --------------------------------
						if ::g_assetName_From_CDF != "" then
						(
							msh.name = ::g_assetName_From_CDF  --name the mesh
						)
						else
						(
							msh.name = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream]._name  --name the mesh
						)
						-----------------------------------------------------------------------------------
									
						--////////////////////// Handle Main/Remain meshes used for Destroyable Objects. //////////////////////
						if (stricmp ((_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream]._name) as string) "main") == 0 then
						(
							--// put code here
							--//////////////////////////////////////////////////////////////////////////
							--// Handle Main/Remain meshes used for Destroyable Objects. See StatObjLoad.cpp 1034			
							--If no node is named remain, then all pieces other than main will be destruction pieces!
							--//////////////////////////////////////////////////////////////////////////	
							format "There is a *main* mesh present, that means the *remain* meshes are the destructibles \n"
						)						

-- 						--////////////////////// Delete isolated vertices for static assets if chosen by the user //////////////////////
-- 						if ::cryImport.chk_deleteISOvertices.state then
-- 						(
-- 							meshop.deleteIsoVerts msh
-- 						)
		
						--// Store the mesh node
						Append 		inst_Sub_Meshes.subMeshes 		msh
						
						--// Sort the built meshes into appropriate layers
						sortObjects_to_layers \
														msh:&msh
						------------------------------------------------------
						--Just zoom in so we can see the object better
						max tool zoomextents	
					)
				)
			)
		)
	),

	--CGFLoader.cpp
	-- mesh.m_bbox = AABB(bboxMin,bboxMax);
	-- http://help.autodesk.com/view/3DSMAX/2016/ENU/?guid=__files_GUID_D1D7EB56_A370_4B07_99B4_BC779FB87CAF_htm
	fn set_AABB \
						bboxMin: \
						bboxMax: \
						&msh: =
	(
		local AABB  = #()
		
		if isValidNode msh then
		(
			AABB = nodeLocalBoundingBox msh	
			return AABB;
		)
		return AABB;
	),


	--We need the arrays for the submeshes - this will get us these
	fn BUILDER \
					&_LOADED: \
					&_LOADEDm: \
					&nstream: \
					&nCount: \
					&inst_assetTypes: \
					&nFirstIndexId: \
					&nNumIndices: \
					&nFirstVertId: \
					&nNumVerts: \
					&nMatID: \
					&vCenter: \
					&tm: \
					&faces: \
					&verts: \
					&normals: \
					&TANGENTS: \
					&QTangents: \
					&UV: \
					&colors: \
					&colors2: \
					&msh: \
					&inst_Sub_Meshes: \
					&inst_CDF_Attachment: \
					pos_stream_id: =
	(		
		local subSet 	= #()
		
		get_subSet_arrays \
									_LOADED: 				&_LOADED \
									_LOADEDm: 			&_LOADEDm \
									nstream:				&nstream \
									nCount:					&nCount \
									inst_assetTypes:		&inst_assetTypes \
									nFirstIndexId: 			&nFirstIndexId \
									nNumIndices: 			&nNumIndices \ 
									nFirstVertId: 			&nFirstVertId \
									nNumVerts: 			&nNumVerts \
									nMatID:					&nMatID \
									faces: 					&faces \
									verts:					&verts \
									normals:					&normals \
									UV:						&UV \
									msh:						&msh \								
									subSet:					&subSet	\
									inst_Sub_Meshes:	&inst_Sub_Meshes

		if ::rollout_Report.chk_BUILDER_Report.state then
		(
			format "subSet[1]: %\n" subSet[1]
			format "subSet[2]: %\n" subSet[2]
			format "subSet[3]: %\n" subSet[3]
		)
		
		if subSet != undefined then
		(
			if iskindof subSet Array then
			(
				if 	subSet[1] != undefined AND \
					subSet[2] != undefined	then
				(
					--Static Assets
					if 	(stricmp inst_assetTypes.fileType1 ".cgf") == 0 AND
						(stricmp inst_assetTypes.fileType2 ".cgfm") == 0 then
					(
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3]  -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10						
							
							--------------Build UVs--------------							
							if msh != undefined then
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh 
									)
								)
							)	
							-------------------------------------------------------------------------------
						)
						else
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".cga") == 0 AND \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".cgam") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10
							
							--------------Build UVs---------------- 							
							if msh != undefined then
							(								
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(		
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh 
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".skin") == 0 AND \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".skinm") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10
							
							--------------Build UVs--------------
							if msh != undefined then
							(								
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS	
								(
									if classof msh == Editable_Mesh then
									(	
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh 
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".chr") == 0 AND \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".chrm") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10
							
							--------------Build UVs--------------
							if msh != undefined then							
							(								
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS	
								(
									if classof msh == Editable_Mesh then
									(	
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh 
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
						)
					)
					
					-----------------------------------------------------
					name_sort_Mesh \
												nstream: 				&nstream \
												inst_Sub_Meshes: 	&inst_Sub_Meshes \
												msh:						&msh			
					-----------------------------------------------------
				)
			)
		)	
	),


	--We need the arrays for the submeshes - this will get us these
	fn BUILDER_HFR \
							&_LOADED: \
							&_LOADEDm: \
							&nstream: \
							&nCount: \
							&inst_assetTypes: \
							&nFirstIndexId: \
							&nNumIndices: \
							&nFirstVertId: \
							&nNumVerts: \
							&nMatID: \
							&vCenter: \
							&tm: \
							&faces: \
							&verts: \
							&normals: \
							&TANGENTS: \
							&QTangents: \
							&UV: \
							&colors: \
							&colors2: \
							&msh: \
							&inst_Sub_Meshes: \
							&inst_CDF_Attachment: \
							pos_stream_id: =
	(
		local subSet 	= #()
		
		get_subSet_arrays \
									_LOADED:				&_LOADED \
									_LOADEDm:				&_LOADEDm \
									nstream:				&nstream \
									nCount:					&nCount \
									inst_assetTypes:		&inst_assetTypes \
									nFirstIndexId: 			&nFirstIndexId \
									nNumIndices: 			&nNumIndices \ 
									nFirstVertId: 			&nFirstVertId \
									nNumVerts: 			&nNumVerts \
									nMatID:					&nMatID \
									faces: 					&faces \
									verts:					&verts \
									UV:						&UV \
									msh:						&msh \								
									subSet:					&subSet \
									inst_Sub_Meshes:	&inst_Sub_Meshes
		
		if ::rollout_Report.chk_BUILDER_Report.state then
		(
			format "subSet[1]: %\n" subSet[1]
			format "subSet[2]: %\n" subSet[2]
			format "subSet[3]: %\n" subSet[3]	
		)
		
		if subSet != undefined then
		(
			if iskindof subSet Array then
			(
				if 	subSet[1] != undefined AND \
					subSet[2] != undefined	then
				(
					--Static Assets
					if 	(stricmp inst_assetTypes.fileType1 ".cgf") == 0 AND
						(stricmp inst_assetTypes.fileType2 ".cgfm") == 0 then
					(
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3]  -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------						
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10
							
							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:			nstream \
																nCount: 			nCount \
																msh: 					&msh
							)						
							
							--------------Build UVs--------------
							--notice the index here is 16 rather than 3 - it is because the UVs in Homefront Revolution is in the Vertchunk, 
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[pos_stream_id] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh 
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
							
							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:	nstream \
																nCount: 	nCount \
																msh: 			&msh
							)	
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".cga") == 0 OR \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".cgam") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10

							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:	nstream \
																nCount: 	nCount \
																msh: 			&msh
							)
							
							--------------Build UVs--------------
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[pos_stream_id] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh  
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)						
							----------------------------------------
							
							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:	nstream \
																nCount: 	nCount \
																msh: 			&msh
							)
						)
					)
					else if (stricmp inst_assetTypes.fileType1 ".skin") == 0 OR \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".skinm") == 0 then
					(
						if subSet[3] != undefined /* AND subSet[2].count != 0 */	then
						(						
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10

							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:	nstream \
																nCount: 	nCount \
																msh: 			&msh
							)
							
							--------------Build UVs--------------
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[pos_stream_id] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				& _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
-- 										if... --pseudo
-- 										(
-- 											set_QTangents \
-- 																	_LOADED: 				&_LOADED \
-- 																	_LOADEDm:				& _LOADEDm \
-- 																	inst_Sub_Meshes: 	&inst_Sub_Meshes \
-- 																	nstream: 				&nstream \
-- 																	nNumVerts: 			&nNumVerts \
-- 																	QTangents: 			&QTangents \
-- 																	msh: 						&msh
-- 										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh  
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)						
							----------------------------------------
							
							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:	nstream \
																nCount: 	nCount \
																msh: 			&msh
							)
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".chr") == 0 OR \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".chrm") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--Sets the number of vertex data channels available
							meshop.setNumVDataChannels msh 10
							
							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:	nstream \
																nCount: 	nCount \
																msh: 			&msh
							)
							
							--------------Build UVs--------------
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[pos_stream_id] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh   									
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
							
							if ::rollout_Animation.chk_Force_Skin_Translation.state then
							(
								Force_Skin_Translation \
																nstream:	nstream \
																nCount: 	nCount \
																msh: 			&msh
							)
						)
					)
					
					-----------------------------------------------------
					name_sort_Mesh \
												nstream: 				&nstream \
												inst_Sub_Meshes: 	&inst_Sub_Meshes \
												msh:						&msh	
					-----------------------------------------------------				
				)
			)
		)	
		
		/*** --OBSOLETE !!!
		if NOT ::rollout_Animation.chk_Force_Skin_Translation.state then
		(
			--Translate Meshes to their parent bone
			for i=1 to inst_Sub_Meshes.subMeshes.count do
			(
				local msh = inst_Sub_Meshes.subMeshes[i]					
				---------------------------------------------------------------------------------------------
				translator \
								nstream: 							&nstream \
								msh: 									&msh \
								inst_CDF_Attachment:			&inst_CDF_Attachment
				---------------------------------------------------------------------------------------------
			)
		)
		--***/
	),

	--We need the arrays for the submeshes - this will get us these
	fn BUILDER_Armored_Warfare \
											&_LOADED: \
											& _LOADEDm: \
											&nstream: \
											&nCount: \
											&inst_assetTypes: \
											&nFirstIndexId: \
											&nNumIndices: \
											&nFirstVertId: \
											&nNumVerts: \
											&nMatID: \
											&vCenter: \
											&tm: \
											&faces: \
											&verts: \
											&normals: \
											&TANGENTS: \
											&QTangents: \
											&UV: \
											&colors: \
											&colors2: \
											&msh: \
											&inst_Sub_Meshes: \
											&inst_CDF_Attachment: \
											pos_stream_id: =
	(
		local subSet 	= #()
		
		get_subSet_arrays \
									_LOADED: 				&_LOADED \
									_LOADEDm: 			&_LOADEDm \
									nstream:				&nstream \
									nCount:					&nCount \
									inst_assetTypes:		&inst_assetTypes \
									nFirstIndexId: 			&nFirstIndexId \
									nNumIndices: 			&nNumIndices \ 
									nFirstVertId: 			&nFirstVertId \
									nNumVerts: 			&nNumVerts \
									nMatID:					&nMatID \
									faces: 					&faces \
									verts:					&verts \
									UV:						&UV \
									msh:						&msh \								
									subSet:					&subSet	\
									inst_Sub_Meshes:	&inst_Sub_Meshes
		
		if ::rollout_Report.chk_BUILDER_Report.state then
		(
			format "subSet[1]: %\n" subSet[1]
			format "subSet[2]: %\n" subSet[2]
			format "subSet[3]: %\n" subSet[3]
		)	
		
		if subSet != undefined then
		(
			if iskindof subSet Array then
			(
				if 	subSet[1] != undefined AND \
					subSet[2] != undefined	then
				(
					--Static Assets
					if 	(stricmp inst_assetTypes.fileType1 ".cgf") == 0 OR
						(stricmp inst_assetTypes.fileType2 ".cgfm") == 0 then
					(
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3]  -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--------------Build UVs--------------
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										if ::rollout_Mesh_Options.chk_Vertex_Tangent_Normals.state then
										(
											--Set Vertex Normals from Tangents
											set_Tangent_Normal \
																		_LOADED: 				&_LOADED \
																		_LOADEDm:				& _LOADEDm \
																		inst_Sub_Meshes: 	&inst_Sub_Meshes \
																		nstream: 				&nstream \
																		nNumVerts: 			&nNumVerts \
																		TANGENTS:				&TANGENTS \
																		msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh   
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".cga") == 0 OR \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".cgam") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--------------Build UVs--------------
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh    
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".skin") == 0 OR \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".skinm") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--------------Build UVs--------------
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh    
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ 	-- subset faces
												vertices:		subSet[2]  		-- All vertices (no subset here)
							----------------------------------------
						)
					)
					else if 	(stricmp inst_assetTypes.fileType1 ".chr") == 0 OR \ --------------skin assets
								(stricmp inst_assetTypes.fileType2 ".chrm") == 0 then
					(	
						if subSet[3] != undefined	then
						(
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2] \ -- All vertices (no subset here)
												materialIDS:	subSet[3] \ -- matIDs (same ID for all the subset faces, and matches the faces.count/subSet[1].count
							----------------------------------------
							
							--------------Build UVs--------------
							if msh != undefined then							
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[3] > 0 then --we check that there are indeed CGF_STREAM_TEXCOORDS
								(
									if classof msh == Editable_Mesh then
									(
										if ::rollout_Mesh_Options.chk_Vertex_Normals.state then
										(
											--Set Vertex Normals
											set_Normals \
																_LOADED: 				&_LOADED \
																_LOADEDm:				 & _LOADEDm \
																inst_Sub_Meshes: 	&inst_Sub_Meshes \
																nstream: 				&nstream \
																nNumVerts: 			&nNumVerts \
																normals:					&normals \
																msh: 						&msh
										)
										
										--sets the tex coords and vertex colors
										set_texCoords \		
															_LOADED: 				&_LOADED \
															_LOADEDm:				& _LOADEDm \
															inst_Sub_Meshes: 	&inst_Sub_Meshes \
															nstream: 				&nstream \
															nFirstVertId: 			&nFirstVertId \
															nNumVerts: 			&nNumVerts \
															subSet: 					&subSet \
															UV: 						&UV \
															colors: 					&colors \
															colors2: 				&colors2 \
															msh: 						&msh   
									)
								)
							)		
							-------------------------------------------------------------------------------	
						)
						else
						(
							format "*** Warning - we could not find any texture coordinates! ***\n"
							--------------Build Mesh--------------
							msh = mesh \
												faces:			subSet[1] \ -- subset faces
												vertices:		subSet[2]  -- All vertices (no subset here)
							----------------------------------------
						)
					)
					
					-----------------------------------------------------				
					name_sort_Mesh \
												nstream: 				&nstream \
												inst_Sub_Meshes: 	&inst_Sub_Meshes \
												msh:						&msh					
					-----------------------------------------------------				
				)
			)
		)	
	),

	fn Build_Material 	\
							&_LOADED: \
							&_LOADEDm: \
							currFileType: \
							&bstream: \
							&mtlFile: \
							&g_cryFile_m: \
							&inst_Sub_Meshes: \
							&inst_CDF_Model: \
							&inst_CDF_Attachment: \
							&inst_CDF_Modifiers: =
	(
		if ::rollout_Options.chk_BuildMaterial.state then
		(
			if 	mtlFile != undefined OR \
				mtlFile != unsupplied then
			(
				--Note, for .cgf(m) we do not supply a g_cryFile, because the .mtl name will be loaded from within the .cgfm file, from the chunk 0xCCCC0014
				--on the other hand, if we were loading from a Character Definition File (.cdf) then we would supply the file we read from within the .cdf

				cryxmlB_loader \
									_LOADED: 						&_LOADED \
									_LOADEDm: 					&_LOADEDm \
									currFileType: 					currFileType \
									inst_Sub_Meshes: 			&inst_Sub_Meshes \
									inst_CDF_Attachment:		&inst_CDF_Attachment \
									inst_CDF_Model: 				&inst_CDF_Model \
									inst_CDF_Modifiers:			&inst_CDF_Modifiers
			)
			else
			(				
				if doesfileexist (mtlFile as string) then
				(
					cryxmlB_loader \
											_LOADED: 						&_LOADED \
											_LOADEDm: 					&_LOADEDm \
											currFileType: 					currFileType \
											inst_Sub_Meshes: 			&inst_Sub_Meshes \
											inst_CDF_Attachment:		&inst_CDF_Attachment \
											inst_CDF_Model: 				&inst_CDF_Model \	
											inst_CDF_Modifiers:			&inst_CDF_Modifiers \
											mtlFile:							&mtlFile
				)					
			)				
		)
	),

	fn Build_Skeleton \
							&_LOADED: \
							&_LOADEDm: \
							caller: \
							nodeCaller: \
							typeCaller: \
							pos_stream_id: \						
							nstream: \
							nCount: \
							&inst_Sub_Meshes: \
							&inst_CDF_Model: \
							&inst_CDF_Attachment: \
							&CryBoneDescData_Comp: =
	(
		--//////////////////////////////////// Build Bones ////////////////////////////////////	
		if NOT ::g_Dont_Load_Skeleton then
		(
			if inst_Sub_Meshes.subMeshes.count > 0 then --if there are any built skin meshes to skin at all
			(
				inst_create_bones = create_bones() --create struct
				if ::g_Create_Bones_Report then ( inst_create_bones.Create_Bones_Report = true )
						
				inst_skinwrap = skinwrap()
				
				inst_create_bones.CONSTRUCT_BONES \
																		_LOADED:						&_LOADED \
																		_LOADEDm:						&_LOADEDm \
																		caller: 							caller	\
																		nodeCaller: 					nodeCaller \
																		typeCaller: 						typeCaller \
																		pos_stream_id: 				pos_stream_id \																	
																		nstream:						&nstream \
																		nCount:							nCount \
																		inst_Sub_Meshes:			&inst_Sub_Meshes \
																		inst_CDF_Model:				&inst_CDF_Model \
																		inst_CDF_Attachment: 		&inst_CDF_Attachment	\
																		CryBoneDescData_Comp: 	&CryBoneDescData_Comp \
																		inst_skinwrap: 				&inst_skinwrap
						
				--Skinwrap Option
				if ::rollout_Animation.chk_Use_Skin_Wrap.state then
				(
					inst_skinwrap.build_targetMesh()
					inst_skinwrap.skinwrap_skin \
															targetMesh: 	&inst_skinwrap.targetMesh \
															sources: 		&inst_skinwrap.sources
				)
			)
		)
		--/////////////////////////////////////////////////////////////////////////////////
	),
	
	fn GET_CryBoneDescData_Comp \
												&_LOADED: \
												&_LOADEDm: \
												caller: \
												nodeCaller: \
												typeCaller: \
												&pos_stream_id: \						
												&nstream: \
												nCount: \
												&inst_Sub_Meshes: \
												&inst_CDF_Model: \
												&inst_CDF_Attachment: =
	(
		local CryBoneDescData_Comp = unsupplied		
		
		--//////////////////////////////// Store the .chr skeleton /////////////////////////////////
		if 	caller 		== "CDF" AND \
			nodeCaller 	== "Model" then
		(
			if inst_CDF_Model != undefined then
			(
				CryBoneDescData_Comp = inst_CDF_Model.CryBoneDescData_Comp
			)
		)
		--/// Store the skin skeleton (same as .chr, but we store anyway - in case we don't load .chr) ///
		else if 	caller 		== "CDF" AND \
					nodeCaller 	== "Attachment" then
		(
			if inst_CDF_Attachment != undefined then
			(
				CryBoneDescData_Comp = inst_CDF_Attachment.CryBoneDescData_Comp
			)
		)
		else --Backup
		(
			if inst_CDF_Model != undefined then
			(
				CryBoneDescData_Comp = inst_CDF_Model.CryBoneDescData_Comp
			)
		)
		--/////////////////////////////////////////////////////////////////////////////////////////
		
-- 		format "CryBoneDescData_Comp: %\n" CryBoneDescData_Comp
		
		if CryBoneDescData_Comp != undefined then
		(
			Build_Skeleton \
								_LOADED: 						&_LOADED \
								_LOADEDm: 					&_LOADEDm \
								caller: 							caller	\
								nodeCaller: 					nodeCaller \
								typeCaller: 						typeCaller \
								pos_stream_id:				&pos_stream_id \ 	--pass as pointer (remember to de-reference at the destination)										
								nStream:						&nStream \ 			--pass as pointer (remember to de-reference at the destination)
								nCount:							n \ 								
								inst_Sub_Meshes: 			&inst_Sub_Meshes \
								inst_CDF_Model:				&inst_CDF_Model \
								inst_CDF_Attachment: 		&inst_CDF_Attachment \
								CryBoneDescData_Comp: 	&CryBoneDescData_Comp
		)
	),

	
	fn link_CA_BONE_toParent \
										&_LOADED: \
										&_LOADEDm: \
										caller: \
										nodeCaller: \
										typeCaller: \
										pos_stream_id: \						
										nstream: \
										nCount: \
										&inst_Sub_Meshes: \
										&inst_CDF_Model: \
										&inst_CDF_Attachment: =
	(
		local existsBone = getNodeByName \
															inst_CDF_Attachment.n_BoneName \
															exact:true \
															ignoreCase:true
		if existsBone != undefined then
		(
			if isValidNode existsBone then
			(
				for x=1 to inst_Sub_Meshes.subMeshes.count do
				(					
					if isValidNode inst_Sub_Meshes.subMeshes[x] then
					(
						inst_Sub_Meshes.subMeshes[x].parent = existsBone
					)
				)
			)
		)
	),

	--/////////////////////////////////// MESH BUILDER ///////////////////////////////////
	--//! Subset of mesh is a continuous range of vertices and indices that share same material. see IIndexedMesh.h 620
	fn BUILD_MESH \	
							&_LOADED: \
							&_LOADEDm: \
							caller: \
							nodeCaller: \
							typeCaller: \
							currFileType: \
							Export_EFlags: \
							&info_MeshSubset: \						
							&mtlFile: \
							&g_cryFile_m: \
							&inst_CDF_Model: \
							&inst_CDF_Attachment: \
							&inst_Sub_Meshes: =
	(
		--CA_SKIN_counter refers to the number of binding CA_SKIN in the CDF
		
		local inst_assetTypes						= assetTypes()
		
		inst_assetTypes.g_cryFile					= ::g_cryFile
		inst_assetTypes.last_Loaded 				= getINISetting 	::g_iniFile 	"paths" 		"last_loaded"
		inst_assetTypes.first_Loaded 			= getINISetting 	::g_iniFile 	"paths" 		"first_loaded"
		inst_assetTypes.fileType1 				= getINISetting 	::g_iniFile 	"fileType" 	"fileType1"
		inst_assetTypes.fileType2 				= getINISetting 	::g_iniFile 	"fileType" 	"fileType2"
		
		if ::rollout_Report.chk_BUILDER_Report.state then
		(
			format "-----------------------------> g_cryFile: %\n" 			inst_assetTypes.g_cryFile
			format "-----------------------------> first_Loaded: %\n" 	inst_assetTypes.last_Loaded						
			format "-----------------------------> last_Loaded: %\n" 		inst_assetTypes.first_Loaded
			format "-----------------------------> fileType1: %\n" 		inst_assetTypes.fileType1					
			format "-----------------------------> fileType2: %\n" 		inst_assetTypes.fileType2		
		)		

		if inst_Sub_Meshes.CA_SKIN_counter > 0 then
		(
			if _LOADEDm != unsupplied then
			(
				if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
				(
					-- ::g_ECgfStreamType.count do --equals the number of sets, because there is a corresponding collection of streams for every set! (essentially each of the 0x00000017 and its associated sets of 0x00000016 chunks)
					for nStream=1 to _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType.count do --equals the number of sets, because there is a collection of streams for every set! (essentially the number of 0x00000017 and its associated 0x00000016 chunks
					(
						format "g_cryFile_m: %\n" g_cryFile_m
						
						-------------------------------------------------------------
						inst_Sub_Meshes.nStream 		= nStream
						-------------------------------------------------------------
						
						if 	_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[1] > 0 AND \ --we check that there are indeed CGF_STREAM_POSITIONS --the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
							_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[6] > 0 then --we check that there are indeed CGF_STREAM_INDICES		--the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
						(
							local tm						= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].tm
							local ObjectID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ObjectID
							local ParentID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ParentID
							
							local pos_stream_id		= 1				
							local nCount = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].nCount
							
							if ::rollout_Report.chk_BUILDER_Report.state then
							(
								format "*** ### *** ### *** nCount: % *** ### *** ### ***\n" nCount
							)
							------------------------------------------------------------------------------
							
							for n=1 to nCount do
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr.count == nCount then --!!!!!!
								(
									local nFirstIndexId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstIndexId
									local nNumIndices 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumIndices
									local nFirstVertId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstVertId
									local nNumVerts 			= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumVerts
									local nMatID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nMatID
									local vCenter				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].vCenter
									
									msh = unsupplied						
									
									-------------------------------------------------------------						
									Append		inst_Sub_Meshes.nCount		n
									-------------------------------------------------------------
									
									BUILDER	\	
													_LOADED: 							&_LOADED \
													_LOADEDm: 						&_LOADEDm \
													Export_EFlags:					Export_EFlags \
													nStream:							&nStream \
													nCount:								&nCount \
													inst_assetTypes:					&inst_assetTypes \
													nFirstIndexId: 						&nFirstIndexId \
													nNumIndices: 						&nNumIndices \ 
													nFirstVertId: 						&nFirstVertId \
													nNumVerts: 						&nNumVerts \
													nMatID:								&nMatID \
													vCenter:							&vCenter \
													tm:									&tm \											
													faces: 								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES \
													verts:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_POSITIONS[1] \
													normals:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_NORMALS \
													Tangents:							&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TANGENTS \
													QTangents: 						&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_QTANGENTS \
													UV:									&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TEXCOORDS \
													colors:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS \
													colors2:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS2 \
													msh:									&msh \
													inst_Sub_Meshes:				&inst_Sub_Meshes \
													inst_CDF_Attachment: 			&inst_CDF_Attachment \
													pos_stream_id:					pos_stream_id
								)
							)
							------------------------------------------------------------------------------
						)
						
						if ::rollout_Options.chk_BuildMaterial.state then
						(
							---------------------------------- Build Material ---------------------------------
							Build_Material 	\
												_LOADED: 						&_LOADED \
												_LOADEDm: 					&_LOADEDm \
												currFileType: 					currFileType \
												bstream: 						&bstream \
												mtlFile: 							&mtlFile \
												g_cryFile_m: 					&g_cryFile_m \
												inst_Sub_Meshes: 			&inst_Sub_Meshes \
												inst_CDF_Model: 				&inst_CDF_Model \
												inst_CDF_Attachment: 		&inst_CDF_Attachment \
												inst_CDF_Modifiers:			&inst_CDF_Modifiers
						)
						
						---------------------------------- Build Skeleton ---------------------------------
						if NOT ::cryImport.chk_Dont_Load_Skeleton.state then
						(
							local nFlags = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].nFlags	

							if nFlags == 0x00000006 then --has bones
							(
								GET_CryBoneDescData_Comp \
																		_LOADED: 					&_LOADED \
																		_LOADEDm: 				&_LOADEDm \
																		caller: 						caller	\
																		nodeCaller: 				nodeCaller \
																		typeCaller: 					typeCaller \
																		pos_stream_id:			&pos_stream_id \ 	--pass as pointer (remember to dereference at the destination)										
																		nStream:					&nStream \ 			--pass as pointer (remember to dereference at the destination)
																		nCount:						n \ 								
																		inst_Sub_Meshes: 		&inst_Sub_Meshes \
																		inst_CDF_Model:			&inst_CDF_Model \
																		inst_CDF_Attachment: 	&inst_CDF_Attachment
							)
							else if nFlags == 0x00000004 then --static
							(
								--////////////////////// Delete isolated vertices for static assets if chosen by the user //////////////////////
								delete_iso_vertices \
															msh: &msh
							)
							
							if (stricmp (typeCaller as string) "CA_BONE") == 0 then
							(
								link_CA_BONE_toParent \
																_LOADED: 					&_LOADED \
																_LOADEDm: 				&_LOADEDm \
																caller: 						caller	\
																nodeCaller: 				nodeCaller \
																typeCaller: 					typeCaller \
																pos_stream_id:			&pos_stream_id \ 	--pass as pointer (remember to dereference at the destination)										
																nStream:					&nStream \ 			--pass as pointer (remember to dereference at the destination)
																nCount:						n \ 								
																inst_Sub_Meshes: 		&inst_Sub_Meshes \
																inst_CDF_Model:			&inst_CDF_Model \
																inst_CDF_Attachment: 	&inst_CDF_Attachment
							)	
						)						
					)
				)
				else
				(
					format "No ECgfStreamType load! \n"
				)
			)
		)	
		else
		(
			format "***Failed to load mesh!*** No meshes to build\n"
		)		
	),
	--///////////////////////////////// END OF MESH BUILDER /////////////////////////////////

	--/////////////////////////////////// MESH BUILDER ///////////////////////////////////
	--//! Subset of mesh is a continuous range of vertices and indices that share same material. see IIndexedMesh.h 620
	fn BUILD_MESH_HFR \
								&_LOADED: \
								&_LOADEDm: \
								caller: \
								nodeCaller: \
								typeCaller: \
								currFileType: \
								Export_EFlags: \
								&info_MeshSubset: \						
								&mtlFile: \
								&g_cryFile_m: \
								&inst_CDF_Model: \
								&inst_CDF_Attachment: \
								&inst_Sub_Meshes: =
	(
		--Note
-- 		File			== inst_Sub_Meshes.CA_SKIN_counter (corresponds to each file, loading from one file directly, this is always 1, but if from a CDF, this can be any positive number)
-- 			Sets					== nStream (same as the number of 0x00000017)
-- 				SubSets						== nCount (number of subsets for each nStream)
		

		local inst_assetTypes						= assetTypes()
		
		inst_assetTypes.g_cryFile					= ::g_cryFile
		inst_assetTypes.last_Loaded 				= getINISetting 	::g_iniFile 	"paths" 		"last_loaded"
		inst_assetTypes.first_Loaded 			= getINISetting 	::g_iniFile 	"paths" 		"first_loaded"
		inst_assetTypes.fileType1 				= getINISetting 	::g_iniFile 	"fileType" 	"fileType1"
		inst_assetTypes.fileType2 				= getINISetting 	::g_iniFile 	"fileType" 	"fileType2"
		
		if ::rollout_Report.chk_BUILDER_Report.state then
		(
			format "-----------------------------> g_cryFile: %\n" 			inst_assetTypes.g_cryFile
			format "-----------------------------> first_Loaded: %\n" 	inst_assetTypes.last_Loaded						
			format "-----------------------------> last_Loaded: %\n" 		inst_assetTypes.first_Loaded
			format "-----------------------------> fileType1: %\n" 		inst_assetTypes.fileType1					
			format "-----------------------------> fileType2: %\n" 		inst_assetTypes.fileType2
		)		

		if inst_Sub_Meshes.CA_SKIN_counter > 0 then 
		(
			if _LOADEDm != unsupplied then
			(
				if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then	--Here is the problem, why is this undefined???!!!!-- 
				(
					for nStream=1 to _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType.count do
					(
						-------------------------------------------------------------
						inst_Sub_Meshes.nStream 		= nStream
						-------------------------------------------------------------
						
						if 	_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[16] > 0 AND \ --we check that there are indeed CGF_STREAM_POSITIONS --the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
							_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[6] > 0 then --we check that there are indeed CGF_STREAM_INDICES		--the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
						(
							local tm						= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].tm
							local ObjectID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ObjectID
							local ParentID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ParentID
							
							local pos_stream_id		= 16
							
							local nCount = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].nCount
							
							if ::rollout_Report.chk_BUILDER_Report.state then
							(
								format "*** ### *** ### *** nCount: % *** ### *** ### ***\n" nCount
							)
							
							------------------------------------------------------------------------------
							for n=1 to nCount do
							(
								--The MeshSubsetArr which describes the subset chunks must ofcourse be equal to the nCount description in the -- both in the 0x00000017 chunk
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr.count == nCount then --!!!!!!
								(
									local nFirstIndexId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstIndexId
									local nNumIndices 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumIndices
									local nFirstVertId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstVertId
									local nNumVerts 			= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumVerts
									local nMatID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nMatID
									local vCenter				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].vCenter
									
									msh = unsupplied
									
									BUILDER_HFR	\	
														Export_EFlags:					Export_EFlags \
														nstream:							&nstream \
														nCount:								&nCount \
														inst_assetTypes:					&inst_assetTypes \
														nFirstIndexId: 						&nFirstIndexId \
														nNumIndices: 						&nNumIndices \ 
														nFirstVertId: 						&nFirstVertId \
														nNumVerts: 						&nNumVerts \
														nMatID:								&nMatID \
														vCenter:							&vCenter \
														tm:									&tm \
														_LOADED:							&_LOADED \
														_LOADEDm:							&_LOADEDm \
														faces: 								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES \
														verts:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_POSITIONS_HFR[1] \
														normals:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_NORMALS \
														Tangents:							&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TANGENTS \
														QTangents: 						&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_QTANGENTS \
														UV:									&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TEXCOORDS \
														colors:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS \
														colors2:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS2 \
														msh:									&msh \
														inst_Sub_Meshes:				&inst_Sub_Meshes \
														inst_CDF_Attachment: 			&inst_CDF_Attachment \
														pos_stream_id:					pos_stream_id
														
									node_Start_Orientation \
																	_LOADED:							&_LOADED \
																	_LOADEDm:							&_LOADEDm \
																	inst_Sub_Meshes:				&inst_Sub_Meshes \	
																	nstream:							&nstream \
																	msh:									&msh

								)				
							)				
							------------------------------------------------------------------------------
						)
						else 	if 	_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[1] > 0 AND \ --we check that there are indeed CGF_STREAM_POSITIONS --the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
									_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[6] > 0 then --we check that there are indeed CGF_STREAM_INDICES		--the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
						(
							local tm						= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].tm
							local ObjectID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ObjectID
							local ParentID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ParentID

							local pos_stream_id		= 1
							
							local nCount = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].nCount
							
							if ::rollout_Report.chk_BUILDER_Report.state then
							(
								format "*** ### *** ### *** nCount: % *** ### *** ### ***\n" nCount
							)
							
							------------------------------------------------------------------------------
							for n=1 to nCount do
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr.count == nCount then --!!!!!!
								(
									local nFirstIndexId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstIndexId
									local nNumIndices 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumIndices
									local nFirstVertId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstVertId
									local nNumVerts 			= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumVerts
									local nMatID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nMatID
									local vCenter				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].vCenter
									
									msh = unsupplied
									
									BUILDER_HFR	\	
														Export_EFlags:					Export_EFlags \
														nstream:							&nstream \
														nCount:								&nCount \
														inst_assetTypes:					&inst_assetTypes \
														nFirstIndexId: 						&nFirstIndexId \
														nNumIndices: 						&nNumIndices \ 
														nFirstVertId: 						&nFirstVertId \
														nNumVerts: 						&nNumVerts \
														nMatID:								&nMatID \
														vCenter:							&vCenter \
														tm:									&tm \
														_LOADED:							&_LOADED \
														_LOADEDm:							&_LOADEDm \
														faces: 								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES \
														verts:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_POSITIONS[1] \
														normals:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_NORMALS \
														Tangents:							&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TANGENTS \
														QTangents: 						&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_QTANGENTS \
														UV:									&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TEXCOORDS \
														colors:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS \
														colors2:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS2 \
														msh:									&msh \
														inst_Sub_Meshes:				&inst_Sub_Meshes \
														 inst_CDF_Attachment: 		&inst_CDF_Attachment \
														pos_stream_id:					pos_stream_id		

									node_Start_Orientation \
																	_LOADED:							&_LOADED \
																	_LOADEDm:							&_LOADEDm \
																	inst_Sub_Meshes:				&inst_Sub_Meshes \	
																	nstream:							&nstream \
																	msh:									&msh


								)				
							)				
							------------------------------------------------------------------------------
						)
						
						if ::rollout_Options.chk_BuildMaterial.state then
						(
							---------------------------------- Build Material ---------------------------------
							Build_Material 	\
												_LOADED: 						&_LOADED \
												_LOADEDm: 					&_LOADEDm \
												currFileType: 					currFileType \
												bstream: 						&bstream \
												mtlFile: 							&mtlFile \
												g_cryFile_m: 					&g_cryFile_m \
												inst_Sub_Meshes: 			&inst_Sub_Meshes \
												inst_CDF_Model: 				&inst_CDF_Model \
												inst_CDF_Attachment: 		&inst_CDF_Attachment \
												inst_CDF_Modifiers:			&inst_CDF_Modifiers
						)
						
						---------------------------------- Build Skeleton ---------------------------------
						if NOT ::cryImport.chk_Dont_Load_Skeleton.state then
						(
							local nFlags = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].nFlags					

							if 		nFlags == 0x00000006 OR \
									nFlags == 0x00000016 OR \
									nFlags == 0x0000001E OR \
									nFlags == 0x00000002 then --Cabal2
							(
								GET_CryBoneDescData_Comp \	
																		_LOADED: 					&_LOADED \
																		_LOADEDm: 				&_LOADEDm \
																		pos_stream_id:			&pos_stream_id \ 	--pass as pointer (remember to dereference at the destination)										
																		caller: 						caller \
																		nodeCaller: 				nodeCaller \
																		typeCaller:					typeCaller \
																		nStream:					&nStream \ 			--pass as pointer (remember to dereference at the destination)
																		nCount:						n \ 
																		inst_Sub_Meshes: 		&inst_Sub_Meshes \
																		inst_CDF_Model:			&inst_CDF_Model \
																		inst_CDF_Attachment: 	&inst_CDF_Attachment
							)
							else if nFlags == 0x00000004 then --static
							(
								--////////////////////// Delete isolated vertices for static assets if chosen by the user //////////////////////
								delete_iso_vertices \
															msh: &msh
							)
							
							if (stricmp (typeCaller as string) "CA_BONE") == 0 then
							(
								link_CA_BONE_toParent \
																_LOADED: 					&_LOADED \
																_LOADEDm: 				&_LOADEDm \
																caller: 						caller	\
																nodeCaller: 				nodeCaller \
																typeCaller: 					typeCaller \
																pos_stream_id:			&pos_stream_id \ 	--pass as pointer (remember to dereference at the destination)										
																nStream:					&nStream \ 			--pass as pointer (remember to dereference at the destination)
																nCount:						n \ 								
																inst_Sub_Meshes: 		&inst_Sub_Meshes \
																inst_CDF_Model:			&inst_CDF_Model \
																inst_CDF_Attachment: 	&inst_CDF_Attachment
							)
						)
						
					)
				)	
			)	
		)	
		else
		(
			format "***Failed to load mesh!*** No meshes to build\n"
		)		
	),
	--///////////////////////////////// END OF MESH BUILDER /////////////////////////////////

	--/////////////////////////////////// MESH BUILDER ///////////////////////////////////
	--//! Subset of mesh is a continuous range of vertices and indices that share same material. see IIndexedMesh.h 620
	fn BUILD_Armored_Warfare \
										&_LOADED: \
										&_LOADEDm: \
										caller: \
										nodeCaller: \
										typeCaller: \
										currFileType: \
										Export_EFlags: \
										&info_MeshSubset: \						
										&mtlFile: \
										&g_cryFile_m: \
										&inst_CDF_Model: \
										&inst_CDF_Attachment: \
										&inst_Sub_Meshes: =
	(	
		local inst_assetTypes						= assetTypes()
		
		inst_assetTypes.g_cryFile					= ::g_cryFile
		inst_assetTypes.last_Loaded 				= getINISetting 	::g_iniFile 	"paths" 		"last_loaded"
		inst_assetTypes.first_Loaded 			= getINISetting 	::g_iniFile 	"paths" 		"first_loaded"
		inst_assetTypes.fileType1 				= getINISetting 	::g_iniFile 	"fileType" 	"fileType1"
		inst_assetTypes.fileType2 				= getINISetting 	::g_iniFile 	"fileType" 	"fileType2"
		
		if ::rollout_Report.chk_BUILDER_Report.state then
		(
			format "-----------------------------> g_cryFile: %\n" 			inst_assetTypes.g_cryFile
			format "-----------------------------> first_Loaded: %\n" 	inst_assetTypes.last_Loaded						
			format "-----------------------------> last_Loaded: %\n" 		inst_assetTypes.first_Loaded
			format "-----------------------------> fileType1: %\n" 		inst_assetTypes.fileType1					
			format "-----------------------------> fileType2: %\n" 		inst_assetTypes.fileType2
		)		

		if inst_Sub_Meshes.CA_SKIN_counter > 0 then 
		(
			if _LOADEDm != unsupplied then
			(
				if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
				(
					for nStream=1 to _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType.count do
					(			
						-------------------------------------------------------------
						inst_Sub_Meshes.nStream 		= nStream
						-------------------------------------------------------------
						
						if 	_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[1] > 0 AND \ --we check that there are indeed CGF_STREAM_POSITIONS --the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
							_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[nStream].nStreamChunkID[6] > 0 then --we check that there are indeed CGF_STREAM_INDICES		--the index reflects ECgfStreamType, the pos is located at 1, and the value tells us which chunID it is
						(
							local tm						= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].tm
							local ObjectID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ObjectID
							local ParentID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_NODE_CHUNK_DESC_0824[nStream].ParentID
							
							local pos_stream_id		= 1
							
							local nCount = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].nCount
							
							if ::rollout_Report.chk_BUILDER_Report.state then
							(
								format "*** ### *** ### *** nCount: % *** ### *** ### ***\n" nCount
							)
							------------------------------------------------------------------------------				

							for n=1 to nCount do
							(
								if _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr.count == nCount then
								(
									local nFirstIndexId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstIndexId
									local nNumIndices 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumIndices
									local nFirstVertId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nFirstVertId
									local nNumVerts 			= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nNumVerts
									local nMatID				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].nMatID
									local vCenter				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].MeshSubsetsArr[n].vCenter
									
									msh = unsupplied
									
									BUILDER_Armored_Warfare	\	
																		_LOADED: 							&_LOADED \
																		_LOADEDm: 						&_LOADEDm \
																		Export_EFlags:					Export_EFlags \
																		nstream:							&nstream \
																		nCount:								&nCount \
																		inst_assetTypes:					&inst_assetTypes \
																		nFirstIndexId: 						&nFirstIndexId \
																		nNumIndices: 						&nNumIndices \ 
																		nFirstVertId: 						&nFirstVertId \
																		nNumVerts: 						&nNumVerts \
																		nMatID:								&nMatID \
																		vCenter:							&vCenter \
																		tm:									&tm \
																		faces: 								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_INDICES \
																		verts:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_POSITIONS[1] \
																		normals:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_NORMALS \
																		Tangents:							&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TANGENTS \
																		QTangents: 						&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_QTANGENTS \
																		UV:									&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_TEXCOORDS \
																		colors:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS \
																		colors2:								&_LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[nStream].CGF_STREAM_COLORS2 \
																		msh:									&msh \
																		inst_Sub_Meshes:				&inst_Sub_Meshes \
																		inst_CDF_Attachment: 			&inst_CDF_Attachment	\
																		pos_stream_id:					pos_stream_id
								)				
							)				
							------------------------------------------------------------------------------
						)
						
						if ::rollout_Options.chk_BuildMaterial.state then
						(
							---------------------------------- Build Material ---------------------------------
							Build_Material 	\
												_LOADED: 						&_LOADED \
												_LOADEDm: 					&_LOADEDm \
												currFileType: 					currFileType \
												bstream: 						&bstream \
												mtlFile: 							&mtlFile \
												g_cryFile_m: 					&g_cryFile_m \
												inst_Sub_Meshes: 			&inst_Sub_Meshes \
												inst_CDF_Model: 				&inst_CDF_Model \
												inst_CDF_Attachment: 		&inst_CDF_Attachment \
												inst_CDF_Modifiers:			&inst_CDF_Modifiers
						)
						
						---------------------------------- Build Skeleton ---------------------------------
						if NOT ::cryImport.chk_Dont_Load_Skeleton.state then
						(
							local nFlags = ::g_MESH_SUBSETS_CHUNK_DESC_0800[nStream].nFlags
							
							if nFlags == 0x00000006 then --has bones
							(					
								Build_Skeleton \
													_LOADED: 					&_LOADED \
													_LOADEDm: 				&_LOADEDm \
													caller: 						caller	\
													nodeCaller: 				nodeCaller \
													typeCaller: 					typeCaller \
													pos_stream_id:			&pos_stream_id \ 	--pass as pointer (remember to dereference at the destination)										
													nStream:					&nStream \ 			--pass as pointer (remember to dereference at the destination)
													nCount:						n \ 								
													inst_Sub_Meshes: 		&inst_Sub_Meshes \
													inst_CDF_Model:			&inst_CDF_Model \
													inst_CDF_Attachment: 	&inst_CDF_Attachment
							)
							else if nFlags == 0x00000004 then --static
							(
								--////////////////////// Delete isolated vertices for static assets if chosen by the user //////////////////////
								delete_iso_vertices \
															msh: &msh
							)
							
							if (stricmp (typeCaller as string) "CA_BONE") == 0 then
							(
								link_CA_BONE_toParent \
																_LOADED: 					&_LOADED \
																_LOADEDm: 				&_LOADEDm \
																caller: 						caller	\
																nodeCaller: 				nodeCaller \
																typeCaller: 					typeCaller \
																pos_stream_id:			&pos_stream_id \ 	--pass as pointer (remember to dereference at the destination)										
																nStream:					&nStream \ 			--pass as pointer (remember to dereference at the destination)
																nCount:						n \ 								
																inst_Sub_Meshes: 		&inst_Sub_Meshes \
																inst_CDF_Model:			&inst_CDF_Model \
																inst_CDF_Attachment: 	&inst_CDF_Attachment
							)
						)
					)
				)
			)
		)	
		else
		(
			format "***Failed to load mesh!*** No meshes to build\n"
		)	
	),
	--///////////////////////////////// END OF MESH BUILDER /////////////////////////////////

	--/////////////////////////////////// MESH BUILDER /////////////////////////////////// --WIP
	fn BUILD_MESH_Crysis \
									&_LOADED: \
									&_LOADEDm: \
									caller: \
									nodeCaller: \
									currFileType: \
									Export_EFlags: \
									&info_MeshSubset: \
									&info_ECgfStreamType: \
									&mtlFile: \
									&g_cryFile_m: \
									&inst_Sub_Meshes: =
	(	
		if 	info_ECgfStreamType != undefined AND \
			info_MeshSubset != undefined then
		(
			if (::g_ECgfStreamType.count == ::g_MESH_SUBSETS_CHUNK_DESC_0800.count) then
			(
				local built_HaveMeshNamed_Main = false
				
				for nStream=1 to ::g_ECgfStreamType.count do
				(
					--------------Build Mesh--------------
					msh = mesh \
										vertices:	::g_ECgfStreamType[nStream].CGF_STREAM_POSITIONS[1] \				
										faces:		::g_ECgfStreamType[nStream].CGF_STREAM_INDICES
					----------------------------------------	
				)
			)
		)
	)
	--///////////////////////////////// END OF MESH BUILDER /////////////////////////////////
)