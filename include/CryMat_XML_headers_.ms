struct xmlStruct
(
	isRoot 				= false,	
	
	rootName 			= undefined,
	
	nodeName 			= undefined,
		numChildren 	= 0,
		children 			= #(),
	
	parentName 		= undefined,
	
	attribs 				= #(#(),#()),	
	
	depth 				= 0,
	idx 					= 0,
	parentIDX 			= #()
)