// ########################################
// Name: util.lua
// Purpose: Some basic useful functions that
// can be used in lua.
// ########################################

local dll = InitializeTable();

dll.Log( "[Lua]: util.lua loading...\n" );

local utils = {};

local ff = {};

function utils.TestFunc( add )
	ff[ add ] = "fag";
end

function utils.GetFF()
	return ff;
end

function utils.IsNil( ... )
	local args = {...};
	for k, v in pairs( args ) do
		local arg = args[i];
		if( arg == nil ) then
			return true;
		end
	end
	return false;
end

function utils.Compare( obj1, obj2 )
	return ( obj1 == obj2 );
end

function utils.Format( msg, ... )
	local args, msgRet = {...}, msg;
	for i = 0, #args do
		local arg = args[i];
		string.gsub( msgRet, "%s", arg );
	end
end

function utils.DebugMsg( col, msg, ... )
	local args = {...} || NULL;
	dll.Log( col, self.Format( msg, args ) );
end

dll.AddFunc( "util", "IsNil", utils.IsNil );
dll.AddFunc( "util", "Compare", utils.Compare );
dll.AddFunc( "util", "Format", utils.Format );
dll.AddFunc( "util", "DebugMsg", utils.DebugMsg );

dll.AddFunc( "util", "TestFunc", utils.TestFunc );
dll.AddFunc( "util", "GetFF", utils.GetFF );