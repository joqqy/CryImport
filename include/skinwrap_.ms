

struct skinwrap
(
	targetMesh 	= #(),
	sources 			= #(),
	
-- 	fn addMat \
-- 					&msh: \
-- 					&MatIDs: = 
-- 	(
-- 		local msh.material = multimaterial()	
-- 		local nSubs = MatIDs.count	
-- 		local msh.material.numsubs = nSubs
-- 				
-- 		--// change the IDs to reflect those described in the cgf mesh subset
-- 		--// (note we have already read those IDs and stored them into the array used here again, so no need to use the mesh subset struct to find out the IDs)
-- 		for i=1 to msh.material.numsubs do
-- 		(
-- 			msh.mat.materialIDList[i] = MatIDs[i]+1 --Note, we have to add +1 here because IDs in Max start at 1  !!
-- 		)
-- 	),
	
	fn build_targetMesh =
	(
		if ::g_BUILT_MESHES.count > 1 then
		(
			if isvalidnode ::g_BUILT_MESHES[1] then
			(
				if iskindof ::g_BUILT_MESHES[1] Editable_Mesh then
				(
					local targetMesh = ::g_BUILT_MESHES[1]
					------------------------------------------------------------
					for i=2 to ::g_BUILT_MESHES.count do
					(
						attach targetMesh ::g_BUILT_MESHES[i]						
					)
					-------------------------------------------------------------
					return targetMesh;
				)				
			)
		)
	),
	
	fn skinwrap_skin \
							&targetMesh: \
							&sources: \
							&MatIDs: =
	(
		if sources != unsupplied then
		(
			if sources.count > 1 then --what is the use to proceed if there is only 1 mesh?
			(
				------------------------- SkinWrap -------------------------
				for msh in targetMesh do
				(
					local TheskinWrap 				= Skin_Wrap ()
					TheskinWrap.meshList  sources
					
					select msh
					max modify mode
					modPanel.addModToSelection TheskinWrap ui:on		
					
					msh.modifiers[1].ConvertToSkin true
					
					for i in sources do
					(
						delete i
					)
					
-- 					----------------------------------------------------------------------
-- 					addMat \
-- 								msh: 			&msh \
-- 								MatIDs: 		&MatIDs
-- 					-----------------------------------------------------------------------
				)
				--------------------------------------------------------------
			)
		)
	)	
)