

--0xACDC0000 See CryHeaders.h 302
struct BONE_ENTITY
(
	BoneID 			= 0,		--int
	ParentID 		= 0,		--int   
	nChildren 		= 0,		--int

	--// Id of controller (CRC32 From name of bone).
	ControllerID 	= 0, --unsigned int
	
	prop 				= #(), --array of char
	prop_length 	= 32,
	
	phys 				= #(), --Compiled Physical Bones --see chunktype 0xACDC0001 --see CryHeaders_info.h 69
	
	_bone			= unsupplied --pie
)

struct create_bones
(
	Create_Bones_Report							= false,
	BONEIDS_ARR_FROM_MESHSUBSET 		= #(),
	SKINBONES_ARRAY								= #(),
	
	fn link_Mesh_2_ParentBone =
	(
		for i=1 to ::Mesh_Bone_Parent_arr.count do
		(
			local m_nControllerID = ::Mesh_Bone_Parent_arr[i].m_nControllerID
			
			for x=1 to ::g_BONES_ARRAY.count do
			(
				local ControllerID = ::g_BONES_ARRAY[x].ControllerID
				
				if m_nControllerID == ControllerID then
				(
					::Mesh_Bone_Parent_arr[i].msh.parent = ::g_BONES_ARRAY[x]._bone
				)
			)	
		)
	),
	
	fn SET_VERT_WEIGHTS \
									pos_stream_id: \									
									&nStream: \
									nCount: \
									&inst_CDF_Model: \
									&inst_CDF_Attachment: \
									&inst_Sub_Meshes: \
									&_LOADED: \
									&_LOADEDm: \
									&CryBoneDescData_Comp: \
									&inst_skinwrap: =
	(
		--//! For skinning, every vertex has 4 bones and 4 weights.
		--// see IIndexedMesh.h 597
		
		--See RenderMesh.cpp 1467 for skinning data character
		--// if weight is zero set bone ID to zero as the bone has no influence anyway,
		--// this will fix some issue with incorrectly exported models (e.g. system freezes on ATI cards when access invalid bones)		
		-- for skinning vegetation see 1416
		
		local nCount 			= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].nCount
		local MeshSubset 	= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].MeshSubsetsArr
		--Array, containing a struct per vertex, see CryHeaders.h 135
		local CrySkinVtx		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_ECgfStreamType[(*nStream)].CGF_STREAM_BONEMAPPING		

		if ::rollout_Report.chk_Create_Bones_Report.state then
		(
			format "*******************	::inst_Sub_Meshes.subMeshes.count: %\n" 		inst_Sub_Meshes.subMeshes.count
			format "*******************	nCount: %\n" 												nCount
			format "*******************	CrySkinVtx: %\n" 										CrySkinVtx
			format "*******************	CrySkinVtx: %\n" 										CrySkinVtx
		)		
		
		--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if nCount == inst_Sub_Meshes.subMeshes.count then
		(
			if ::rollout_Report.chk_Create_Bones_Report.state then
			(
				format "*******************	(*pos_stream_id): %\n" 		(*pos_stream_id)
				format "*******************	nCount: %\n" 						nCount
			)
	
			------------------------Game specific nStreamChunkID - modified versions of CryEngine can have different (added enumerations)------------------------			
			local nStreamChunkID_INDICES 	= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[(*nStream)].nStreamChunkID[6] --CGF_STREAM_INDICES
			local nStreamChunkID_POS 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[(*nStream)].nStreamChunkID[(*pos_stream_id)] --CGF_STREAM_POSITIONS			
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
			if 	nStreamChunkID_POS > 0 AND \ --we check that there are indeed CGF_STREAM_POSITIONS
				nStreamChunkID_INDICES > 0 then --we check that there are indeed CGF_STREAM_INDICES
			(			
				local nCount = ::g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].nCount
						
				if nCount == inst_Sub_Meshes.subMeshes.count then
				(
					for n=1 to nCount do
					(
						if ::g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].MeshSubsetsArr.count == ::g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].nCount then
						(
							local nFirstVertId 		= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].MeshSubsetsArr[n].nFirstVertId
							local nNumVerts 			= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].MeshSubsetsArr[n].nNumVerts

							-------------------------------
							clearSelection() --deselect everything
							-------------------------------
										
							local theMesh 	= inst_Sub_Meshes.subMeshes[n].mesh
									
							if ::rollout_Animation.chk_Use_Skin_Wrap.state then
							(
								if inst_skinwrap != unsupplied then
								(
									-- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- //
									Append inst_skinwrap.sources inst_Sub_Meshes.subMeshes[n] -- for skinwrap
									-- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- //
								)
							)
									
							if 	iskindof inst_Sub_Meshes.subMeshes[n] Editable_Mesh AND 
								isValidNode inst_Sub_Meshes.subMeshes[n] then
							(
								--nVerts = getNumVerts theMesh	--<------- the nVerts (the vert count for each current mesh)
								local theSkin 		= inst_Sub_Meshes.subMeshes[n].modifiers[1]									
											
								-------------------------------
								select inst_Sub_Meshes.subMeshes[n] --select only the current looped mesh
								max modify mode --enter modify mode (we must do that inorder to add weights to the skin modifier)
								modPanel.setCurrentObject theSkin --we must set the current skin in the modpanel, else we can't add weights
											
								--// REPORT (a check to see that the modpanel is active and the current modifier is the skin (which we will add weights to)
								local checkmod = modPanel.getCurrentObject()				
								if Create_Bones_Report then ( format "CURRENT: %\n" checkmod )	
								-------------------------------
											
								if iskindof checkmod Skin then
								(
									local nBones = skinOps.GetNumberBones theSkin
												
									if nBones > 0 then
									(
										if Create_Bones_Report then
										(
											---------------	---------------	---------------	---------------	
											format 	"nFirstVertId = %\n" 	nFirstVertId
											format 	"nNumVerts = %\n" 		nNumVerts					
											---------------	---------------	---------------	---------------
										)
											
										--// REPORT
										format "CURRENTLY APPLYING WEIGHTS TO: % Please Wait...\n" inst_Sub_Meshes.subMeshes[n].name
													
										for v=nFirstVertId+1 to ((nFirstVertId)+nNumVerts) do --loop the size of nNumVerts as described in the MeshSubset info (also not, max is not zero based, so we have to add +1 to "v")	
										(
											local BonesIDs_x_4 		= #()
											local Weights_x_4 		= #()
													
											if CrySkinVtx[v] != undefined then
											(
												i=4						
												while i > 0 do --apply weights backwards, because the zero weights (Representing IDs of 1 in our script) come last in the cgf/chr and they are applied, the last bones are reapplied the wrong value of zero.
												(	
													if CrySkinVtx[v].idx[i] != undefined then
													(
														local bonesIDs = CrySkinVtx[v].idx[i]+1 --our max bones start at 1 and not zero, therefor we must add +1 --the CrySkinVtx structs
																	
														if bonesIDs <= nBones then --Note, that if we do not constrain it like this, we could get a boneID out of range (not sure if these are blending modes, perhaps to previous submesh, so we leave them out for now,)
														(									   --This constraint does not seem to affect the weight mapping (these might be blending bones of some sort)
															Append   (BonesIDs_x_4)   (bonesIDs)
																					
															--add 4 weights to array
															Append   (Weights_x_4)   (CrySkinVtx[v].w[i]) --the CrySkinVtx structs							
														)
																		
														i -= 1
													)
												)
																		
												skinOps.SetVertexWeights theSkin (v) (BonesIDs_x_4) (Weights_x_4)
											)
													
											free BonesIDs_x_4
											free Weights_x_4
										)
									)
								)
							)
						)
					)
				)						
			)
		)
		--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
	),
	
	fn SET_VERT_WEIGHTS_TO_ZERO \
													pos_stream_id: \													
													&nStream: \
													nCount: \
													&inst_CDF_Model: \
													&inst_CDF_Attachment: \
													&inst_Sub_Meshes: \
													&_LOADED: \
													&_LOADEDm:  \
													&CryBoneDescData_Comp: \
													&inst_skinwrap: =
	(
		--//! For skinning, every vertex has 4 bones and 4 weights.
		
		--/////////////////////////   Zero out all weights first for all vertices and all meshes  /////////////////////////
		for m=1 to inst_Sub_Meshes.subMeshes.count do
		(
			if inst_Sub_Meshes.subMeshes[m] != undefined then
			(
				if 	iskindof inst_Sub_Meshes.subMeshes[m] Editable_Mesh AND 
					isValidNode inst_Sub_Meshes.subMeshes[m] then
				(			
					-------------------------------
					clearSelection() --deselect everything
					-------------------------------			
					
					local theMesh 				= inst_Sub_Meshes.subMeshes[m].mesh		
					local nVerts 					= getnumverts inst_Sub_Meshes.subMeshes[m].baseobject.mesh	--<------- the nVerts (the vert count for each current mesh)
					local theSkin 					= inst_Sub_Meshes.subMeshes[m].modifiers[1]
					local faceID 					= getFaceMatID theMesh 1 --// get the faceIDs of the current mesh
					
					-------------------------------
					select inst_Sub_Meshes.subMeshes[m] --select only the current looped mesh
					max modify mode --enter modify mode (we must do that inorder to add weights to the skin modifier)
					modPanel.setCurrentObject theSkin --we must set the current skin in the modpanel, else we can't add weights
					
					--// REPORT (a check to see that the modpanel is active and the current modifier is the skin (which we will add weights to)
					local checkmod = modPanel.getCurrentObject()			
					if Create_Bones_Report then ( format "CURRENT: %\n" checkmod )			
					-------------------------------
					
					if iskindof checkmod Skin then
					(
						local nBones = skinOps.GetNumberBones theSkin
						
						if nBones > 0 then
						(
							--//---------------------This is the array for applying zero weights before adding the real weights---------------------
							local BoneIDIndex = #() --this is the index with the correct BoneIDs NOTE (id-1 because max ids are not zero based)
							for n=1 to nBones do
							(
								Append BoneIDIndex (skinOps.GetBoneIDByListID theSkin n)	
							)
							
							--// fill an array with zero weights to reflect the size of the array that contains the bones for the current skin
							local zeroWeights = #()
							for x=1 to BoneIDIndex.count do
							(
								Append zeroWeights (0.0 as float)
							)
							
							if Create_Bones_Report then
							(
								format 		"nVerts: %\n" 		nVerts
								format 		"nBones: %\n" 	nBones
							)
							
							format "CURRENTLY ZEROING OUT VERTICES Please Wait...\n"			
							--/////////////////////   First apply zero weights to ALL verts in current looped mesh   /////////////////////
							--loop the size of nNumVerts as described in the MeshSubset info --all verts for all meshes (the above loop should be used instead)
							for v=1 to nVerts do 
							(
								--remove current weights (zero them out, we want to start with no weights) -- temp off
								skinOps.ReplaceVertexWeights theSkin (v) (BoneIDIndex) (zeroWeights)
							)
							--------------------------------------------
						)
					)
				)
			)
		)	
		
		try
		(
			-----------------------------------Now we set the real weights--------------------------------------
			SET_VERT_WEIGHTS \
											pos_stream_id: 					pos_stream_id \											
											nStream:							&nStream \
											nCount: 							nCount \
											inst_CDF_Model:					&inst_CDF_Model \
											inst_CDF_Attachment:			&inst_CDF_Attachment \
											inst_Sub_Meshes:				&inst_Sub_Meshes \
											_LOADED:							&_LOADED \
											_LOADEDm:							&_LOADEDm \
											CryBoneDescData_Comp:		&CryBoneDescData_Comp \
											inst_skinwrap: 					&inst_skinwrap
		)
		catch
		(
			format "\n\n\n\n*** *** *** *** *** *** *** SET_VERT_WEIGHTS ERROR *** *** *** *** *** *** *** ***\n"
			format "%" (getCurrentException())
			format "\n*** *** *** *** *** *** END OF SET_VERT_WEIGHTS ERROR *** *** *** *** *** *** *** ***\n\n\n\n"
		)
	),
	
	fn ADD_BONES_2_SKIN \
									pos_stream_id: \									
									&nStream: \
									&inst_CDF_Model: \
									&inst_CDF_Attachment: \
									&inst_Sub_Meshes: \
									nCount: \									
									&_LOADED: \
									&_LOADEDm: \
									&CryBoneDescData_Comp: \	
									&inst_skinwrap: =
	(
		max modify mode
		
		if inst_Sub_Meshes.subMeshes.count > 0 then
		(
			for m=1 to inst_Sub_Meshes.subMeshes.count do
			(				
				local msh = inst_Sub_Meshes.subMeshes[m]
				
				for _mod in msh.modifiers do
				(
					if classof _mod == skin then
					(
						theSkin = _mod
						modPanel.setCurrentObject theSkin
						
						if inst_Sub_Meshes.SKINBONES_FROM_0xCCCC0017[m] != undefined then
						(
							for i=1 to inst_Sub_Meshes.SKINBONES_FROM_0xCCCC0017[m].count do
							(
								local _bone = inst_Sub_Meshes.SKINBONES_FROM_0xCCCC0017[m][i]
								skinOps.addbone theSkin _bone 1
							)
						)
					)
				)				
			)
			
			SET_VERT_WEIGHTS_TO_ZERO \
														pos_stream_id: 				pos_stream_id \														
														nStream:						&nStream \
														nCount: 						nCount \
														inst_CDF_Model:				&inst_CDF_Model \
														inst_CDF_Attachment:		&inst_CDF_Attachment \
														inst_Sub_Meshes:			&inst_Sub_Meshes \
														_LOADED:						&_LOADED \
														_LOADEDm:						&_LOADEDm \
														CryBoneDescData_Comp:	&CryBoneDescData_Comp \
														inst_skinwrap: 				&inst_skinwrap
		)
	),	
	
	fn GET_0xCCCC0017_SUBSET_BONES \
														pos_stream_id: \														
														&nStream: \
														nCount: \
														&inst_CDF_Model: \
														&inst_CDF_Attachment: \
														&inst_Sub_Meshes: \
														&_LOADED: \
														&_LOADEDm: \
														&CryBoneDescData_Comp: \
														&inst_skinwrap: =
	( 
		format "----------------------->pointer nStream: %\n" (*nStream)
		
		--we will store the bones to apply to the skin (these bones are the ids listed in 0xCCCC0017 (note the id from the table in 0xCCCC0017  must be = id+1)
		--so we will have to match the id+1 to the corresponding 1 based index in ::g_BONES_ARRAY !
		--/*
		if inst_Sub_Meshes != unsupplied then
		(
			if inst_Sub_Meshes.CA_SKIN_counter != undefined then
			(
				if inst_Sub_Meshes.CA_SKIN_counter > 0 then
				(
-- 					local CryBoneDescData_Comp 		= _LOADED[inst_Sub_Meshes.CA_SKIN_counter].g_CryBoneDescData_Comp --num bone subsets		
					local MeshBoneSubsetsArr 				= _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_SUBSETS_CHUNK_DESC_0800[(*nStream)].MeshBoneSubsetsArr					
					
					for i=1 to MeshBoneSubsetsArr.count do
					(
						local skinBones_per_Subset = #()
							
						local numBoneIDs 	= MeshBoneSubsetsArr[i].numBoneIDs
						
						format "----------------------->numBoneIDs: %\n" numBoneIDs
							
						for idx=1 to numBoneIDs do
						(
							local theID		= MeshBoneSubsetsArr[i].arrBoneIDs[idx]	
								
							for x=1 to ::g_BONES_ARRAY.count do
							(			
								if x == (theID+1) then --as we wrote above, the id from the 0xCCCC0017 must be incremented with 1, because max is 1 based, whilst CryEngine uses 0 based indices
								(
									Appendifunique 		skinBones_per_Subset											::g_BONES_ARRAY[x]._bone
								)
							)
						)
							
						Append		inst_Sub_Meshes.SKINBONES_FROM_0xCCCC0017		skinBones_per_Subset
							
						if ::rollout_Report.chk_Create_Bones_Report.state then
						(
							format "\n"
							print "*** /// *** /// *** /// *** /// ***"	
							print skinBones_per_Subset
							print "*** /// *** /// *** /// *** /// ***"
							format "\n"	
						)
					)
				
					ADD_BONES_2_SKIN \
												pos_stream_id: 				pos_stream_id \												
												nStream:						&nStream \
												nCount: 						nCount \
												inst_CDF_Model:				&inst_CDF_Model \
												inst_CDF_Attachment:		&inst_CDF_Attachment \
												inst_Sub_Meshes:			&inst_Sub_Meshes \
												_LOADED:						&_LOADED \
												_LOADEDm:						&_LOADEDm \
												CryBoneDescData_Comp:	&CryBoneDescData_Comp \
												inst_skinwrap: 				&inst_skinwrap			
				)
			)
		)
		--*/
	),
	
	----Add skin modifier to all SubMeshes
	fn ADD_SKIN_MODIFIER \
									&_LOADED: \
									&_LOADEDm: \
									caller: \
									nodeCaller: \
									typeCaller: \	
									pos_stream_id: \									
									&nStream: \
									nCount: \
									&inst_Sub_Meshes: \
									&inst_CDF_Model: \
									&inst_CDF_Attachment: \
									&CryBoneDescData_Comp: \
									&inst_skinwrap: =
	(
		for m=1 to inst_Sub_Meshes.subMeshes.count do
		(
			local theMesh = inst_Sub_Meshes.subMeshes[m]
			
			if 	iskindof theMesh Editable_mesh AND 
				isValidNode theMesh then
			(
				clearselection()
				max modify mode
				select theMesh
				modPanel.addModToSelection (Skin()) ui:on
			)
		)
		
		GET_0xCCCC0017_SUBSET_BONES \
														pos_stream_id: 				pos_stream_id \														
														nStream:						&nStream \
														nCount:							nCount \
														inst_CDF_Model:				&inst_CDF_Model \
														inst_CDF_Attachment:		&inst_CDF_Attachment \
														inst_Sub_Meshes:			&inst_Sub_Meshes \
														_LOADED:						&_LOADED \
														_LOADEDm:						&_LOADEDm \
														CryBoneDescData_Comp:	&CryBoneDescData_Comp \
														inst_skinwrap: 				&inst_skinwrap
	),
	
	fn BONE_CONSTRUCTOR \	
										idx: \
										&CryBoneDescData_Comp: \
										BoneParentID: \
										m_nOffsetParent: \
										m_arrBoneName: \
										&existsBone:undefined =
	(		
		if existsBone == undefined then --bone does not exists, we build a new bone
		(
			local matrixW2B 					= CryBoneDescData_Comp[idx].m_DefaultW2B
			local matrixB2W 					= CryBoneDescData_Comp[idx].m_DefaultB2W
			
			-------------------------------Rotate Joints-----------------------------			
			storeB2W 					= copy matrixB2W
			storedTrans 				= matrixB2W.translationpart
			
			translate 	matrixB2W ((inverse matrixB2W)*matrixB2W).translationpart --translate to origin
			
			rotate 		matrixB2W ((inverse storeB2W).rotationpart) --rotate with quaternion to reset
			in coordsys storeB2W
				rotate 		matrixB2W (matrixW2B.rotationpart) --set the final rotation by quaternion
			
			matrixB2W.translation = storedTrans --translate back
			-------------------------------------------------------------------------------
			
			
			local boneLength 				= 0.07	
			local startPos 					= matrixB2W[4]
			local endPos 						= (matrixB2W[4]) + (boneLength*(normalize matrixB2W[1]))
			local zAxis 							= (normalize matrixB2W[3])	
										
			local newbone;
			local rootMatrix = matrix3 1 --unused				


			if m_nOffsetParent == 0 then --root
			(
				--	--newBone = bonesys.createbone	       tfm.row4     (tfm.row4 + 0.01 * (normalize tfm.row1))      (normalize tfm.row3)
				newbone = BoneSys.createBone			(startPos) \
																	(endPos)  \
																	(zAxis)
											
				rootMatrix = getNodeTM  newbone --unused
			)
			else
			(
				local matrixParent = CryBoneDescData_Comp[BoneParentID+1].m_DefaultB2W

				newbone = BoneSys.createBone		(startPos) \
																(endPos)  \
																(zAxis)
			)
				
			newBone.name 							= m_arrBoneName --+ "(" + BoneParentIDName + ")"	
				---------------------------------------------------------------------------
				newBone.length 							= 0	--.07 --shaded meshbone (can be set to zero)
				newBone.width 							= 0	--.01 --shaded meshbone (can be set to zero)
				newBone.height 							= 0	--.01 --shaded meshbone (can be set to zero)
						---------------------------------------------------------------------------
			newBone.wirecolor 						= yellow
			newbone.showlinks 						= true
			newBone.setBoneEnable 					false 0
			newBone.pos.controller 				= TCB_position ()
			newBone.rotation.controller 			= TCB_rotation ()
										
			-----------------------------------------Fill the runtime BONE_ENTITY-----------------------------------------------
			inst_BONE_ENTITY = BONE_ENTITY() --create instance of BONE_ENTITY
										
			inst_BONE_ENTITY.BoneID 			= i
			inst_BONE_ENTITY.ParentID 			= BoneParentID
			inst_BONE_ENTITY.nChildren 			= m_numChildren
			inst_BONE_ENTITY.ControllerID 		= m_nControllerID
										
			inst_BONE_ENTITY._bone 				= newBone
			-----------------------------------------------------------------------------------------------------------------------------
			
			Append ::g_BONES_ARRAY inst_BONE_ENTITY					
			if BoneParentID != 0 then
			(					
				newBone.parent = ::g_BONES_ARRAY[BoneParentID+1]._bone			
			)
				
			return newBone;
		)
		else --bone already exists
		(
			local matrixW2B 					= CryBoneDescData_Comp[idx].m_DefaultW2B
			local matrixB2W 					= CryBoneDescData_Comp[idx].m_DefaultB2W
				rotate matrixW2B (quat 0 0 0 1)
			local boneLength 				= 0.07	
			local startPos 					= matrixB2W[4]
			local endPos 						= (matrixB2W[4]) + (boneLength*(normalize matrixB2W[1]))
			local zAxis 							= (normalize matrixB2W[3])	
										
			local newbone;
			local rootMatrix = matrix3 1

			newBone = existsBone
				
			-----------------------------------------Fill the runtime BONE_ENTITY-----------------------------------------------
			inst_BONE_ENTITY = BONE_ENTITY() --create instance of BONE_ENTITY
										
			inst_BONE_ENTITY.BoneID 			= i
			inst_BONE_ENTITY.ParentID 			= BoneParentID
			inst_BONE_ENTITY.nChildren 			= m_numChildren
			inst_BONE_ENTITY.ControllerID 		= m_nControllerID
										
			inst_BONE_ENTITY._bone 				= newBone
			-----------------------------------------------------------------------------------------------------------------------------
				
			Append ::g_BONES_ARRAY inst_BONE_ENTITY					
			if BoneParentID != 0 then
			(					
				newBone.parent = ::g_BONES_ARRAY[BoneParentID+1]._bone			
			)

			return newBone;	
		)
	),

	--This function is for now called in load_cryHeaders_.ms last inside the function: *read_firstData*
	fn CONSTRUCT_BONES \
									&_LOADED: \
									&_LOADEDm: \
									caller: \
									nodeCaller: \
									typeCaller: \
									pos_stream_id: \									
									&nstream:	\
									nCount: \
									&inst_CDF_Model: \
									&inst_CDF_Attachment: \
									&inst_Sub_Meshes: \
									&CryBoneDescData_Comp: \
									&inst_skinwrap: =
	(
		--Are there any constant bone names?
		--This seems to imply it:
		--See CGFLoader.cpp 1668
		/***
		//------------------------------------------------------------------------------------------
		//----     use the old chunks to initialize the bone structure  ----------------------------
		//------------------------------------------------------------------------------------------
		static const char* const arrLimbNames[] =
		{
			"L UpperArm",
			"R UpperArm",
			"L Thigh",
			"R Thigh"
		};
		***/
		
		
		if Create_Bones_Report then
		(
			format "We are now inside *%*\n" CONSTRUCT_BONES
		)
		
		if _LOADED != unsupplied then
		(
			if _LOADED != undefined then
			(
				if _LOADEDm != undefined then
				(
					local nFlags = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[(*nStream)].nFlags
					local nFlags2 = _LOADEDm[inst_Sub_Meshes.CA_SKIN_counter].g_MESH_CHUNK_DESC_0801[(*nStream)].nFlags2
					
					format "nFlags: %\n" nFlags
					format "nFlags2: %\n" nFlags2
						
					if nFlags == 0x0001 OR nFlags2 == 0x0001 then
					(
						format "Empty mesh (no streams are saved). \n"
					)
					else if nFlags == 0x0002 OR nFlags2 == 0x0002 then
					(
						format "texMappingDensity contains a valid value. \n"
					)
					else if nFlags == 0x0004 OR nFlags2 == 0x0004 then
					(
						format "The weight stream will have weights for influences 5-8. \n"
					)
					else if nFlags == 0x0008 OR nFlags2 == 0x0008 then
					(
						format "geometricMeanFaceArea contains a valid value. \n"
					)
				)
				
				--/*
				if Create_Bones_Report then
				(
					format "---------------nStream: % ---------------\n" 															(*nStream)
					format "---------------_LOADED[(*nStream)]: % ---------------\n"										_LOADED[inst_Sub_Meshes.CA_SKIN_counter]
					format "---------------_LOADED[(*nStream)].g_CryBoneDescData_Comp: % ---------------\n" 	_LOADED[inst_Sub_Meshes.CA_SKIN_counter].g_CryBoneDescData_Comp
					
					format "_LOADEDm[(*nStream)].g_MESH_CHUNK_DESC_0801.nFlags: %\n" nFlags
					format "_LOADEDm[(*nStream)].g_MESH_CHUNK_DESC_0801.nFlags: %\n" nFlags2
				)				
				
-- 				if _LOADED[inst_Sub_Meshes.CA_SKIN_counter] != undefined then
-- 				(
					--local g_CryBoneDescData_Comp = ::_LOADED[1].g_CryBoneDescData_Comp --num bone subsets
		-- 			local g_CryBoneDescData_Comp = _LOADED[(*nStream)].g_CryBoneDescData_Comp --num bone subsets
-- 										local g_CryBoneDescData_Comp = _LOADED[inst_Sub_Meshes.CA_SKIN_counter].g_CryBoneDescData_Comp --num bone subsets --test off ???
					
					local COM = undefined	
					
					if CryBoneDescData_Comp != unsupplied then
					(
						if CryBoneDescData_Comp != undefined then
						(
							if Create_Bones_Report then
							(
								format 	"============ 	g_CryBoneDescData_Comp.count: 	%   ============\n" 		g_CryBoneDescData_Comp.count
							)
									
							for i=1 to CryBoneDescData_Comp.count do
							(
								local m_arrBoneName 			= CryBoneDescData_Comp[i].m_arrBoneName
								local m_nControllerID			= CryBoneDescData_Comp[i].m_nControllerID
									
								local boneDuplicate				= false


								if ::cryImport.chk_Force_2_Base_Skeleton.state then
								(
									--Search by name to see if the node does already exist --returns the bone if the node is already present
									local existsBone = getNodeByName m_arrBoneName exact:true ignoreCase:true
										
									if existsBone == undefined then
									(
										local m_nOffsetParent 			= CryBoneDescData_Comp[i].m_nOffsetParent --//! This bone parent is this[m_nOffsetParent], 0 if the bone is root. Normally this is <= 0.
										local m_nOffsetChildren 		= CryBoneDescData_Comp[i].m_nOffsetChildren
										local m_numChildren 			= CryBoneDescData_Comp[i].m_numChildren --//! This is 0 if there are no children.

										if Create_Bones_Report then
										(
											format "\n--i: %--------m_nOffsetParent: % ------m_nOffsetChildren: %-----m_numChildren: %--\n" i m_nOffsetParent m_nOffsetChildren m_numChildren
											format "m_arrBoneName: %\n" m_arrBoneName 
										)
														
										--ParentID
										local BoneParentIDName 		= CryBoneDescData_Comp[i+(m_nOffsetParent)].m_arrBoneName
										local BoneParentID 				= (i-1)+(m_nOffsetParent) --CryLink BoneID - m_nOffsetParent (note i-1 since max arrays are not zero based)
													
										if Create_Bones_Report then
										(					
											format 		"BoneParentIDName: %\n" 	BoneParentIDName				
											format 		"\t\t BoneParentID: %\n" 		BoneParentID
										)
													
										if m_nOffsetChildren != 0 then
										(			
											--ChildrenID
											local BoneChildrenIDName 	= CryBoneDescData_Comp[i+(m_nOffsetChildren)].m_arrBoneName
											local BoneChildrenID 			= (i-1)+(m_nOffsetChildren) --CryLink BoneID - m_nOffsetParent (note i-1 since max arrays are not zero based)
															
											if Create_Bones_Report then
											(				
												format "\t\t\tBoneChildrenIDName: %\n" BoneChildrenIDName
												format "\t\t\t\t\t BoneChildrenIDName: %\n" BoneChildrenID 
											)
										)
										else
										(
											if Create_Bones_Report then
											(				
												format "\t\t\tThere are no children for *%* \n" BoneParentIDName
											)
										)
											
										--Construct the Bone
										newBone = BONE_CONSTRUCTOR \	
																					idx:									i \
																					CryBoneDescData_Comp: 		&CryBoneDescData_Comp \
																					BoneParentID: 					BoneParentID \
																					m_nOffsetParent: 				m_nOffsetParent \
																					m_arrBoneName: 					m_arrBoneName \
																					existsBone:							&existsBone
													
										if m_nOffsetParent == 0 then
										(
											if Create_Bones_Report then
											(
												print m_arrBoneName
												print m_numChildren
												print m_nOffsetChildren
												print BoneParentID
											)
											COM = newBone
										)				
										else if BoneParentID == 0 then
										(
											if Create_Bones_Report then
											(
												print m_arrBoneName
												print BoneParentID
											)
											newBone.parent = COM
										)							
									)
									else
									(
										if 	isValidNode existsBone then								
										(
											if (classof existsBone) == BoneGeometry then
											(
												local m_nOffsetParent 			= CryBoneDescData_Comp[i].m_nOffsetParent --//! This bone parent is this[m_nOffsetParent], 0 if the bone is root. Normally this is <= 0.
												local m_nOffsetChildren 		= CryBoneDescData_Comp[i].m_nOffsetChildren
												local m_numChildren 			= CryBoneDescData_Comp[i].m_numChildren --//! This is 0 if there are no children.

												if Create_Bones_Report then
												(
													format "\n--i: %--------m_nOffsetParent: % ------m_nOffsetChildren: %-----m_numChildren: %--\n" i m_nOffsetParent m_nOffsetChildren m_numChildren
													format "m_arrBoneName: %\n" m_arrBoneName 
												)
															
												--ParentID
												local BoneParentIDName 		= CryBoneDescData_Comp[i+(m_nOffsetParent)].m_arrBoneName
												local BoneParentID 				= (i-1)+(m_nOffsetParent) --CryLink BoneID - m_nOffsetParent (note i-1 since max arrays are not zero based)
														
												if Create_Bones_Report then
												(					
													format 		"BoneParentIDName: %\n" 	BoneParentIDName				
													format 		"\t\t BoneParentID: %\n" 		BoneParentID
												)
														
												if m_nOffsetChildren != 0 then
												(			
													--ChildrenID
													local BoneChildrenIDName 	= CryBoneDescData_Comp[i+(m_nOffsetChildren)].m_arrBoneName
													local BoneChildrenID 			= (i-1)+(m_nOffsetChildren) --CryLink BoneID - m_nOffsetParent (note i-1 since max arrays are not zero based)
																
													if Create_Bones_Report then
													(				
														format "\t\t\tBoneChildrenIDName: %\n" BoneChildrenIDName
														format "\t\t\t\t\t BoneChildrenIDName: %\n" BoneChildrenID 
													)
												)
												else
												(
													if Create_Bones_Report then
													(				
														format "\t\t\tThere are no children for *%* \n" BoneParentIDName
													)
												)
													
												newBone = BONE_CONSTRUCTOR \	
																							idx:									i \
																							CryBoneDescData_Comp: 		&CryBoneDescData_Comp \
																							BoneParentID: 					BoneParentID \
																							m_nOffsetParent: 				m_nOffsetParent \
																							m_arrBoneName: 					m_arrBoneName \
																							existsBone:							&existsBone
														
												if m_nOffsetParent == 0 then
												(
													if Create_Bones_Report then
													(
														print m_arrBoneName
														print m_numChildren
														print m_nOffsetChildren
														print BoneParentID
													)
													COM = newBone
												)				
												else if BoneParentID == 0 then
												(
													if Create_Bones_Report then
													(
														print m_arrBoneName
														print BoneParentID
													)
													newBone.parent = COM
												)
											)	
										)
									)
								)
								else
								(										
									local m_nOffsetParent 			= CryBoneDescData_Comp[i].m_nOffsetParent --//! This bone parent is this[m_nOffsetParent], 0 if the bone is root. Normally this is <= 0.
									local m_nOffsetChildren 		= CryBoneDescData_Comp[i].m_nOffsetChildren
									local m_numChildren 			= CryBoneDescData_Comp[i].m_numChildren --//! This is 0 if there are no children.

									if Create_Bones_Report then
									(
										format "\n--i: %--------m_nOffsetParent: % ------m_nOffsetChildren: %-----m_numChildren: %--\n" i m_nOffsetParent m_nOffsetChildren m_numChildren
										format "m_arrBoneName: %\n" m_arrBoneName 
									)
													
									--ParentID
									local BoneParentIDName 		= CryBoneDescData_Comp[i+(m_nOffsetParent)].m_arrBoneName
									local BoneParentID 				= (i-1)+(m_nOffsetParent) --CryLink BoneID - m_nOffsetParent (note i-1 since max arrays are not zero based)
												
									if Create_Bones_Report then
									(					
										format 		"BoneParentIDName: %\n" 	BoneParentIDName				
										format 		"\t\t BoneParentID: %\n" 		BoneParentID
									)
												
									if m_nOffsetChildren != 0 then
									(			
										--ChildrenID
										local BoneChildrenIDName 	= CryBoneDescData_Comp[i+(m_nOffsetChildren)].m_arrBoneName
										local BoneChildrenID 			= (i-1)+(m_nOffsetChildren) --CryLink BoneID - m_nOffsetParent (note i-1 since max arrays are not zero based)
														
										if Create_Bones_Report then
										(				
											format "\t\t\tBoneChildrenIDName: %\n" BoneChildrenIDName
											format "\t\t\t\t\t BoneChildrenIDName: %\n" BoneChildrenID 
										)
									)
									else
									(
										if Create_Bones_Report then
										(				
											format "\t\t\tThere are no children for *%* \n" BoneParentIDName
										)
									)
											
									newBone = BONE_CONSTRUCTOR \
																				idx:									i \
																				CryBoneDescData_Comp: 		&CryBoneDescData_Comp \
																				BoneParentID: 					BoneParentID \
																				m_nOffsetParent: 				m_nOffsetParent \
																				m_arrBoneName: 					m_arrBoneName			
												
									if m_nOffsetParent == 0 then
									(
										if Create_Bones_Report then
										(
											print m_arrBoneName
											print m_numChildren
											print m_nOffsetChildren
											print BoneParentID
										)
										COM = newBone
									)				
									else if BoneParentID == 0 then
									(
										if Create_Bones_Report then
										(
											print m_arrBoneName
											print BoneParentID
										)
										newBone.parent = COM
									)							
								)
							)
					
							::g_BONES_ARRAY_OLD = deepcopy ::g_BONES_ARRAY							

							ADD_SKIN_MODIFIER \
															_LOADED:						&_LOADED \
															_LOADEDm:						&_LOADEDm \
															caller: 							caller	\
															nodeCaller: 					nodeCaller \
															typeCaller: 						typeCaller \
															pos_stream_id: 				pos_stream_id \												
															nStream:						&nStream \
															nCount:							nCount \
															inst_Sub_Meshes:			&inst_Sub_Meshes \
															inst_CDF_Model:				&inst_CDF_Model \
															inst_CDF_Attachment: 		&inst_CDF_Attachment \
															CryBoneDescData_Comp:	&CryBoneDescData_Comp \
															inst_skinwrap: 				&inst_skinwrap
						)
					)
					--*/
-- 				)
			)
		)		
	)
)