
local _enums = {};
local _enums__data = {};

local _global_funcs = {};
local _global_funcs__data = {};

local _tables = {};
local _tables__data = {};

local _table_funcs = {};
local _table_funcs__data = {};

local _registry = {};
local _registry__data = {};

local _registry = {};
local _registry_data = {};

local _registry_funcs = {};
local _registry_funcs__data = {};

local metadata = {
	"__eq",
	"__tostring",
	"__gc",
	"__mul",
	"__index",
	"__concat",
	"__newindex",
	"__add",
	"__sub",
	"__div",
	"__call",
	"__pow",
	"__unm",
	"__lt",
	"__le",
	"__mode",
	"__metatable",
}

local function GetData()
	for k, v in pairs( _G ) do
		if( !table.HasValue( metadata, name ) ) then
			if( type( v ) == "number" ) then
				_enums__data[k] = true;
				_enums[#_enums+1] = k;
			end
			if( type( v ) == "function" ) then
				_global_funcs__data[k] = true;
				_global_funcs[#_global_funcs+1] = k;
			end
			if( type( v ) == "table" && v != _G ) then
				_tables__data[k] = true;
				_tables[#_tables+1] = k;
				for name, val in pairs( v ) do
					if( type( val ) == "function" && !name:find( "models/" ) && (_table_funcs__data[name] == nil) && !table.HasValue( metadata, name ) ) then
						_table_funcs__data[name] = true;
						_table_funcs[#_table_funcs+1] = k .. "." .. name;
					end
				end
			end
		end
	end
	
	for k, v in pairs( debug.getregistry() ) do
		if( type( k ) == "string" && type( v ) == "table" && _registry_data[v] == nil ) then
			_registry_data[v] = true;
			_registry[#_registry + 1] = k;
			for name, value in pairs( v ) do
				if( type( value ) == "function" && _registry_funcs__data[value] == nil && !table.HasValue( metadata, name ) ) then
					_registry_funcs__data[value] = true;
					_registry_funcs[#_registry_funcs + 1] = name;
				end
			end
		end
	end
end

if( SERVER ) then
	GetData();
	local function writefiletotable( tbl, ex )
		local str = ex .. "[[:";
		for i, name in ipairs( tbl ) do
			str = str .. name .. " ";
		end
		str = str .. "\n";
		file.Append( "xml_data_server.txt", str );
	end
	writefiletotable( _enums, "ee" );
	writefiletotable( _global_funcs, "gg" );
	writefiletotable( _tables, "tt" );
	writefiletotable( _table_funcs, "tf" );
	writefiletotable( _registry, "rr" );
	writefiletotable( _registry_funcs, "rf" );
end

if( CLIENT ) then
	GetData();
	local function writefiletotable( tbl, ex )
		local str = ex .. "[[: ";
		for i, name in ipairs( tbl ) do
			str = str .. name .. " ";
		end
		str = str .. "\n\n";
		file.Append( "xml_data_client.txt", str );
	end
	writefiletotable( _enums, "ee" );
	writefiletotable( _global_funcs, "gg" );
	writefiletotable( _tables, "tt" );
	writefiletotable( _table_funcs, "tf" );
	writefiletotable( _registry, "rr" );
	writefiletotable( _registry_funcs, "rf" );
end

concommand.Add( "build_xml", function()
	print( "ENUMS: " );
	PrintTable( _enums );
	print( "GLOBAL FUNCS: " );
	PrintTable( _global_funcs );
	print( "TABLES: " );
	PrintTable( _tables );
	print( "TABLE FUNCS: " );
	PrintTable( _table_funcs );
	print( "REGISTRY: " );
	PrintTable( _registry );
	print( "REGISTRY FUNCS: " );
	PrintTable( _registry_funcs );
end )





























