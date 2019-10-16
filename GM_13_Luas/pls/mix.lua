local datas = {
	enums = {},
	globalfuncs = {},
	tables = {},
	tablefuncs = {},
	reg = {},
	regfuncs = {},
};

local dataforms = {
	["ee"] = datas.enums,
	["gg"] = datas.globalfuncs,
	["tt"] = datas.tables,
	["tf"] = datas.tablefuncs,
	["rr"] = datas.reg,
	["rf"] = datas.regfuncs,
};

local function ReadFile( str )
	local data = file.Read( str, "DATA" );
	if( data ) then
		local breakup = string.Explode( "\n", data );
		if( breakup ) then
			for i, name in pairs( breakup ) do
				if( name && name != nil && name != "" ) then
					local su = string.Explode( "[[:", name );
					if( su[1] && su[2] && dataforms[su[1]] ) then
						local lists = string.Explode( " ", su[2] );
						for idx, name in ipairs( lists ) do
							if( !table.HasValue( dataforms[su[1]], name ) ) then
								print( "added: " .. name .. " from " .. str );
								dataforms[su[1]][ #dataforms[su[1]] + 1 ] = name;
							end
						end
					end
				end
			end
		end
	end
end

ReadFile( "xml_data_client.txt" )
ReadFile( "xml_data_server.txt" )

local function writefiletotable( tbl )
	local str = "";
	for i, name in ipairs( tbl ) do
		str = str .. name .. " ";
	end
	str = str .. "\n\n";
	file.Append( "xml_data.txt", str );
end

writefiletotable( datas.enums );
writefiletotable( datas.globalfuncs );
writefiletotable( datas.tables );
writefiletotable( datas.tablefuncs );
writefiletotable( datas.reg );
writefiletotable( datas.regfuncs );










































