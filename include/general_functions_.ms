
fn ReadFixedString \
							&bstream: \
							&fixedLen: =
(
	if classof bstream == BinStream then
	(
		local str = ""
		for i = 1 to fixedLen do
		(
			str += bit.intAsChar (ReadByte bstream #unsigned)
		)
		return str
	)
)

fn readHalfFloat \
						&bstream: =
(
	if bstream != unsupplied then
	(
		if bstream != undefined then
		(
			if isKindOf bstream BinStream then
			(
				hf				= readshort bstream #unsigned
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
)

fn build_complete_filePath \									
									&attribVal: \
									&dirPath:	\
									&filePath: =
(
	if attribVal != undefined AND dirPath != undefined then
	(
		if iskindof attribVal string AND iskindof dirPath string then
		(
			if pathConfig.isLegalPath dirPath then
			(
				newfilePath = pathConfig.resolvePathSymbols (pathConfig.appendPath dirPath filePath)				
				
				filePath = newfilePath
				
				if doesfileexist filePath then
				(
					format "Built Complete FilePath: %\n" filePath
					return true;
				)
			)				
		)
	)
	return false;
)

fn build_binding_filePath \									
									&binding: \
									&dirPath: =
(
	if binding != undefined AND dirPath != undefined then
	(
		if iskindof binding string AND iskindof dirPath string then
		(
			if pathConfig.isLegalPath dirPath then
			(
				newfilePath = pathConfig.resolvePathSymbols (pathConfig.appendPath dirPath binding)
				filePath = newfilePath
				
				if doesfileexist filePath then
				(
					return filePath;
				)
			)				
		)
	)
	return "";
)

fn check_4_mtl_suffix \
								&filePath: =
(
	suffix = getFilenameType filePath
	
	if stricmp suffix ".mtl" != 0 then
	(
		filePath = (trimRight filePath ".") + ".mtl"
	)
)

--Checks if the header is CryXmlB in the .mtl, if so, then it is in Crytek Binary XML format
fn Binary_XML_check file =
(
	if file != undefined then
	(
		if doesfileexist File then
		(
			szSignature 	= "CryXmlB"
				
			--////////////// Open binary stream //////////////
			xbs 				= fopen file "rb"
			-------------------------------------------
			
			if classof xbs == BinStream then
			(				
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
			)
		)
	)	
	return false;
)

fn Binary_XML_custom_check \
											File: \
											type: =
(
	if File != undefined then
	(
		if doesfileexist File then
		(	
			szSignature 	= type
				
			--////////////// Open binary stream //////////////
			xbs 				= fopen File "rb"
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
		)
	)	
	return false;
)

fn Binary_CryTek_check File: =
(
	if File != undefined then
	(
		if doesfileexist File then
		(
			szSignature 	= "CryTek"
				
			--////////////// Open binary stream //////////////
			xbs 				= fopen File "rb"
			-------------------------------------------
				
			local fixedLen = 7
			thisHeader = ReadFixedString \
													bstream:	&xbs \
													fixedLen:	&fixedLen
				
			--////////////// Close binarystream //////////////
			fclose xbs
				
			if thisHeader == szSignature then
			(
				return true;
			)
		)
	)
	return false;
)

/*
fn getFilesRecursive \
							root: \
							specDir: \
							targetFile: =
(
	local rootLevels = ""
	local files_Found = #()	

	if doesfileexist  (pathConfig.ResolvePathSymbols (pathConfig.AppendPath sysInfo.windowsdir "\\Microsoft.NET\\Framework*")) then
	(
		if root != unsupplied then
		(
			if iskindof root string then
			(
				if pathConfig.islegalpath root then
				(
					if doesfileexist root then
					(
						if specDir != unsupplied then
						(
							if iskindof specDir  string then
							(
								rootLevels = pathConfig.resolvePathSymbols (root + "/" + specDir)
							)					
						)
						else
						(
							rootLevels = pathConfig.resolvePathSymbols (root + "/*")
						)
						
						try
						(
							SystemIO_SearchOption	 	= dotNetClass "System.IO.SearchOption"
							Directory 							= dotNetClass "System.IO.Directory"
							files_array 							= Directory.getFiles rootLevels "*.*" SystemIO_SearchOption.AllDirectories
								
							for f in files_array do
							(							
								if (stricmp (filenameFromPath  f) targetFile) == 0 then
								(
									Append files_Found f
								)
							)
						)
						catch print (getCurrentException())
					)
				)
			)
		)
	)
	else
	(
		if root != unsupplied then
		(
			if iskindof root string then
			(
				if pathConfig.islegalpath root then
				(
					if doesfileexist root then
					(
						if specDir != unsupplied then
						(
							if iskindof specDir  string then
							(
								rootLevels = pathConfig.resolvePathSymbols (root + "/" + specDir)
							)
						)
						else
						(
							rootLevels = pathConfig.resolvePathSymbols (root + "/*")
						)
						
						if pathConfig.isLegalPath rootLevels AND \
							doesfileexist rootLevels then
						(
							local dir_array = GetDirectories (pathConfig.resolvePathSymbols (rootLevels+"/*"))
						
							for d in dir_array do
							(
								join dir_array (GetDirectories (d+"/*"))
							)						
							
							for f in dir_array do
							(
								if targetFile != unsupplied then
								(
									if iskindof targetFile string then
									(
										fName = f + targetFile									
										
										if doesfileexist fName then
										(
											Append files_Found fName
										)
									)				
								)
								else
								(
									Append files_Found f
								)
							)
						)
					)
				)
			)
		)
	)
	
	return files_Found;
)
--*/

fn getFilesRecursive \
							root: \
							specDir: \
							targetFile: =
(
	local rootLevels = ""
	local files_Found = #()	


	if root != unsupplied then
	(
		if iskindof root string then
		(
			if pathConfig.islegalpath root then
			(
				if doesfileexist root then
				(
					if specDir != unsupplied then
					(
						if iskindof specDir  string then
						(
							rootLevels = pathConfig.resolvePathSymbols (root + "/" + specDir)
						)					
					)
					else
					(
						rootLevels = pathConfig.resolvePathSymbols (root + "/*")
					)
						
					try
					(
						SystemIO_SearchOption	 	= dotNetClass "System.IO.SearchOption"
						Directory 							= dotNetClass "System.IO.Directory"
						files_array 							= Directory.getFiles rootLevels "*.*" SystemIO_SearchOption.AllDirectories
							
						if files_array != undefined then
						(
							for f in files_array do
							(							
								if (stricmp (filenameFromPath  f) targetFile) == 0 then
								(
									Append files_Found f
								)
							)
						)
						else
						(
							for f in dir_array do
							(
								if targetFile != unsupplied then
								(
									if iskindof targetFile string then
									(
										fName = f + targetFile									
											
										if doesfileexist fName then
										(
											Append files_Found fName
										)
									)				
								)
								else
								(
									Append files_Found f
								)
							)
						)
					)
					catch print (getCurrentException())
				)
			)
		)
	)
	
	return files_Found;
)

fn fix_MaterialRef_refsPath \
										&texFile: \
										suffix: =
(
	if texFile != unsupplied then
	(
		if pathConfig.isLegalPath texFile then
		(
			if NOT doesfileexist texFile then
			(
				local _path 		= getFilenamePath texFile -- returns: "g:\subdir1\subdir2\"
				local _name 		= getFilenameFile texFile -- returns: "myImage"
				local _type 		= getFilenameType texFile -- returns: ".jpg"
				
				local temp_texFile 		= (pathConfig.resolvePathSymbols (pathConfig.appendPath _path _name))+suffix
				
				if doesfileexist temp_texFile then
				(
					texFile 		= temp_texFile
				)
			)				
		)
	)
)
	








