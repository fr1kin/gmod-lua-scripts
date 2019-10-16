// ########################################
// Name: util.lua
// Purpose: Table functions that are clean
// and specialized for this hack alone.
// ########################################

local dll = InitializeTable();

dll.Log( "[Lua]: table.lua loading...\n" );

local tables = {};

local utils = dll.GetTable( "utils" );

if( !utils ) then
	dll.Log( "Hi" );
end

dll.Log( #utils.GetFF() .. "Yeah" );

utils.AddFunc( 1 );
utils.AddFunc( 2 );
utils.AddFunc( 3 );

dll.Log( #utils.GetFF() .. "YEHAH HFUCKING REDM" );

local tblLocalCopy = {};
local tblPreCopy = {};
local tblRCopy = {};

for i = 0, #_G do
	local obj = _G[i];
	tblLocalCopy[i] = obj;
end

for i = 0, #_R do
	local obj = _R[i];
	tblRCopy[i] = obj;
end

function tables.Globals()
	return tblLocalCopy;
end

function tables.Meta()
	return tblRCopy;
end

function tables.CopyTable( tbl, new )
	new = new || false;
	
	if( utils.IsNil( tbl ) ) then 
		return NULL; 
	end
	
	if( tblPreCopy[tbl] ) then
		return tblPreCopy[tbl] || NULL;
	end
	
	local tblStack = {};
	
	if( new == true ) then
		tblStack = tblLocalCopy[tbl];
	else
		for i = 0, #tbl do
			local obj = tbl[i];
			tblStack[i] = obj;
		end
	end
	return ( #tblStack > 0 ) && tblStack || NULL;
end

function tables.GetTable( tbl )
	if( utils.IsNil( tbl ) ) then 
		return NULL; 
	end
	return self.CopyTable( tbl, true );
end

dll.AddFunc( "tables", "Globals", tables.Globals );
dll.AddFunc( "tables", "CopyTable", tables.CopyTable );
dll.AddFunc( "tables", "GetTable", tables.GetTable );