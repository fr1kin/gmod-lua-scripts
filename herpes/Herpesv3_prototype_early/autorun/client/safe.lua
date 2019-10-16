
local function build_write( tbl, fname, tab, tabbing )
	tab = tab || {};
	tabbing = tabbing || 0;
	if( file.Exists( fname ) == false ) then
		file.Write( fname, "" );
	end
	local f_write = "";
	for k, v in pairs( tbl ) do
		f_write = tostring( string.rep( "\t", tabbing ) )
		if( type( v ) == "table" && !tab[v] ) then
			tab[v] = true;
			f_write = f_write .. tostring( k ) .. ":\n";
			file.Append( fname, f_write );
			build_write( v, fname, tab, tabbing + 1 )
		else
			f_write = f_write .. tostring( k ) .. " = " .. tostring( v ) .. "\n";
			file.Append( fname, f_write );
		end
	end
end

local function dumpToFile( tbl, frcname )
	local name = "dumps/" .. frcname .. ".txt";
	
	if( name == "null" ) then
		return;
	end
	
	if( type( tbl ) == "table" ) then
		build_write( tbl, name )
	end
end

local function dumpLargeFile( tbl )
	local add = 0;
	local last = {};
	
	for k, v in pairs( tbl ) do
		if( type( v ) == "table" ) then
			local fn = tostring( k ) .. "_" .. tostring( add )
			dumpToFile( v, fn );
			add = add + 1;
		else
			last[k]=v;
		end
	end
	dumpToFile( last, "_g_default" );
end

