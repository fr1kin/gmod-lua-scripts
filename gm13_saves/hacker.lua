/*
local _R = debug.getregistry();

local oldfire = _R.Entity.FireBullets;
function _R.Entity.FireBullets( bullet, a )
	print( bullet )
	PrintTable( a )
	return oldfire( bullet, a );
end

local function IsInGlobals( o, _d, _s )
	_d = _d || {};
	for k, v in pairs( _s || _G ) do
		if( istable( v ) && !_d[v] ) then
			_d[v] = true;
			if( IsInGlobals( o, _d, v ) ) then
				return true;
			end
		else
			if( v == o ) then
				return true;
			end
		end
	end
	return false;
end

print( IsInGlobals( _R.Entity.FireBullets ) );

print( IsInGlobals( IsValid ) );
*/
/*
local on = {};

local function AddThis( funccy, new )
	local fagitt = "fasfa";
	on[fagitt] = true;
	local function _new(...)
		print( "test: ", fagitt );
		if( on[fagitt] == true ) then
			return new(...);
		end
		return funccy(...);
	end
	_G["faggotface"] = _new;
end

function faggotface()
	return "FAG"
end

print( faggotface() );

local function newthingy()
	return "notfag sorey"
end

AddThis( faggotface, newthingy )

print( faggotface() );

concommand.Add( "thetest", function()
	print( faggotface() );
end )
*/




/*
local function CorrectSlashes( str )
	str = string.gsub( str, "//", "/" );
	str = string.gsub( str, "\\", "/" );
	return str;
end

local dirs_to_data = {
	["DATA"] = "",
	["GAME"] = "data/",
	["MOD"] = "data/",
}

function Add( name, contents )
	if( string.sub( name, -4 ) != ".txt" ) then
		name = name .. ".txt";
	end
	local folders = string.Explode( "/", CorrectSlashes( name ) );
	if( #folders > 1 ) then
		file.CreateDir( folders[#folders-1] );
		name = folders[#folders-1] .. "/" .. folders[#folders];
	end
	print( "data/" .. name, folders[#folders] )
end

local PATHS = {
	["LUA"] = "lua/",
	["DATA"] = "data/",
}

local lfiles = {};
local ldirec = {};

local tdirec = {}
local tfiles = {};

function IsBlacklisted( name, _path, _only )
	if( !isstring( name ) && !isstring( _path ) ) then
		return false;
	end
	// Files are not case sensitive, so I can just make it all lower case to ease matching.
	name = string.lower( name );
	// If a path is chosen edit it into the name.
	if( PATHS[_path] ) then
		name = PATHS[_path] .. name;
	end
	// Break the folders apart and correct the slashes.
	local list_folders = string.Explode( "/", CorrectSlashes( name ) );
	// Here I can find out the folder they are searching in.
	local findpath = name;
	if( list_folders && #list_folders > 1 ) then // There is more than 1 object in this table.
		findpath = string.gsub( name, "/" .. list_folders[#list_folders], "" ); // EX: data/folder/test.txt -> data/folder
	end
	// This is a file, so we can finally check after all that shit.
	// File is blacklisted, time to spoof shit.
	if( lfiles[name] ) then
		return true;
	end
	if( ldirec[name] ) then
		return true;
	end
	// Everything passing is fine.
	return false;
end

function ToFullPath( name, path )
	name = string.lower( name );
	// If a path is chosen edit it into the name.
	if( PATHS[path] ) then
		name = PATHS[path] .. name;
	end
	return name;
end

function GiveSpoofName( name, s_name )
	if( !isstring( name ) || !isstring( s_name ) ) then
		return "pi";
	end
	local newname, index = nil, 1
	while( true ) do
		newname = string.gsub( s_name, ".txt", "" );
		newname = tostring( newname .. "_" .. index .. ".txt" );
		if( !file.Exists( newname, "DATA" ) ) then
			break;
		end
		index = index + 1;
	end
	name = string.gsub( name, s_name, newname );
	return newname, name;
end

function Write( name, content )
	if( IsBlacklisted( name, "DATA" ) ) then
		while( true ) do
			name = string.lower( name );
			local folders = string.Explode( "/", CorrectSlashes( name ) );
			if( folders == nil ) then
				break;
			end
			if( !istable( folders ) ) then
				break;
			end
			if( #folders > 2 ) then
				break;
			end
			
			local fullpath = ToFullPath( name, "DATA" );
			local file_name = folders[#folders];
			local spoof_name, full_spoof_path = GiveSpoofName( fullpath, file_name );
			
			// File created
			tfiles[fullpath] = spoof_name;
			
			// Folder exists.
			if( folders && #folders > 1 ) then
				print( "folder made", string.gsub( fullpath, "/" .. file_name, "") );
				tdirec[string.gsub( fullpath, "/" .. file_name, "")] = true;
			end
			
			name = string.gsub( name, file_name, spoof_name );
			print( name );
			break;
		end
	end
	return "returned: " ..name .. " [arg2] " .. content
end

concommand.Add( "debug_stringtest", function()
	local folder = "hacker.txt";
	lfiles["data/"..folder] = true;
	
	print( file.Time( "lolasdas.txt", "DATA" ) );
	print( Write( folder, "lol" ) );
end )
*/
/*
function f (v)
  test = v  -- assign to global variable test
end -- function f

local myenv = {}  -- my local environment table
setfenv (f, myenv)  -- change environment for function f
f (42)  -- call f with new environment

print (test) --> nil  (global test was not changed)
print (myenv.test)  --> 42  (test inside myenv was changed)
*/

local function GetAllFilesInFolder( folder, collected, dir )
	dir = dir || "";
	collected = collected || {};
	local files, folders = file.Find( dir .. folder .. "*", "GAME" );
	if( files || folders ) then
		for k, v in pairs( files ) do
			if( !collected[v] ) then
				collected[v] = true;
				continue;
			end
			local index = 1;
			while( true ) do
				if( !collected[v .. "_" .. tostring(index)] ) then
					collected[v .. "_" .. tostring(index)] = true;
					break;
				end
				index = index + 1;
			end
		end
		for k, v in pairs( folders ) do
			local more, newindex = GetAllFilesInFolder( v .. "/", collected, ( dir .. folder ) );
		end
		return collected;
	end
	return {};
end

//GetAllFilesInFolder( "lua" )
PrintTable( GetAllFilesInFolder( "lua/" ) )

/*
function FSPOOF:IsBlacklisted( name, _path, _only )
	if( !IsString( name ) || !IsString( _path ) ) then
		return false;
	end
	// Files are not case sensitive, so I can just make it all lower case to ease matching.
	name = g.string.lower( name );
	// If a path is chosen edit it into the name.
	if( PATHS[_path] ) then
		name = PATHS[_path] .. name;
	end
	// Break the folders apart and correct the slashes.
	local list_folders = ExplodeString( "/", CorrectSlashes( name ) );
	// Here I can find out the folder they are searching in.
	local findpath = name;
	if( list_folders && #list_folders > 1 ) then // There is more than 1 object in this table.
		findpath = g.string.gsub( name, "/" .. list_folders[#list_folders], "" ); // EX: data/folder/test.txt -> data/folder
	end
	local isfile = ( _only == "file" ) && true || ( _only == "folder" ) && false || nil;
	if( IsNil( isfile ) ) then
		// You can end folders with the .txt extention so this will prevent confusion.
		local files, folders = g.file.Find( findpath .. "/*", "GAME" );
		if( files && folders ) then
			for i = 1, #files do
				if( files[i] == list_folders[#list_folders] ) then
					isfile = true;
				end
			end
			for i = 1, #folders do
				if( folders[i] == list_folders[#list_folders] ) then
					isfile = false;
				end
			end
		end
	end
	// This is a file, so we can finally check after all that shit.
	if( isfile == true ) then
		// Has someone else created this file?
		if( self.files[name] ) then
			return false;
		end
		// Protected?
		if( PROTECT.files[name] ) then
			return true;
		end
	elseif( isfile == false ) then
		// Has someone else created this folder?
		if( self.dirs[name] ) then
			return false;
		end
		// Protected?
		if( PROTECT.direc[name] ) then
			return true;
		end
	end
	// Everything passing is fine.
	return false;
end
*/




















/*
local org_hook = table.Copy( hook );
local old_hook = table.Copy( hook );

local old_gettable = old_hook.GetTable;

local function TestDetour()
	print( "Test" );
	return old_gettable();
end

old_hook.GetTable = TestDetour;

rawset( hook, "GetTable", TestDetour );


concommand.Add( "debug_hooksize", function()
	print( "########## hook size ##########" );
	print( "HOOK: ", #hook );
	PrintTable( hook );
end )

concommand.Add( "debug_hookcall", function()
	print( "Calling hook..." );
	local pfin = hook.GetTable();
end )
*/

/*
local function GetInfo( func, temp, toscan, memb )
	temp = temp || {};
	memb = memb || { "_G" };
	for k, v in pairs( toscan || _G ) do
		if( type( v ) == "table" && !temp[v] ) then
			temp[v] = true;
			local n = GetInfo( func, temp, v, memb );
			if( n ) then
				memb[#memb + 1 || 0] = k;
				return n;
			end
		else
			if( v == func ) then
				return {
					name = k,			// Name of the function
					func = v,			// Index of the function (usally the function itself)
					memberof = memb,	// Members of the function
				};
			end
		end
	end
	return nil;
end

_G.niggars = {};

function niggars:GayAss()
	print( "niggas" );
end

local members = {};

function Add( old, new )
	members[new] = old;
	
	local info = GetInfo( old );
	
	local dir = _G;
	for i = 2, #info.memberof do
		dir = dir[info.memberof[i]];
	end
	
	if( dir && dir[info.name] ) then
		rawset( dir, info.name, new );
	end
end

local function Nigga()
	print( "works" );
end

niggars:GayAss()

Add( niggars.GayAss, Nigga );

niggars:GayAss()
*/

/*
local debugCheck = {};

local function Hide( name, objects )
	debugCheck[name] = {};
	for k, v in pairs( objects ) do
		debugCheck[name][v] = true;
	end
end

Hide( "GetConVarNumber", { "gay" } );

local function debugHook( ... )
	local args = {...};
	
	local info = debug.getinfo( 2 );
	if( info && info.name && debugCheck[info.name] ) then
		print( "hello" );
		local name, value, index = 0, 0, 1;
		while( true ) do
			name, value = debug.getlocal( 2, index );
			print( name, value );
			if( name == nil || value == nil ) then 
				break; 
			end
			if( debugCheck[info.name][value] ) then
				debug.setlocal( 2, index, "some other variable depending on the type" );
			end
			index = index + 1;
		end
		debug.sethook();
	end
end

debug.sethook( debugHook, "c", 0 );

include( "test2.lua" );
*/

/*
local function Hook( ... )
	local args = {...};
	
	local name = debug.getinfo (2, "n").name;
	
	if( name == "GetConVarNumber" ) then
		PrintTable( debug.getinfo(2) );
		local func = debug.getinfo(2).func;
		
		print( "## UPVALUES ##" )
		local i = 1;
		while( true ) do
			local n, v = debug.getupvalue( func, i );
			if( n == nil || v == nil ) then
				break;
			end
			print( func, n, v )
			i = i + 1;
		end
		
		print( "## LOCALS ##" )
		i = 1;
		while( true ) do
			local n, v = debug.getlocal( 2, i );
			if( n == nil || v == nil ) then
				break;
			end
			print( func, n, v )
			//print( "test...", debug.setlocal( 2, i, "you are gay" ) );
			i = i + 1;
		end
		
		print( "END" );
		debug.sethook();
	end
end
*/


/*
debug.setmetatable( _G, {
		__index = function( t, k )
			if( k == "SCRIPTNAME" || k == "SCRIPTPATH" ) then
				local i = 1;
				while( true ) do
					local info = debug.getinfo(i);
					if( !info ) then break; end
					print( "\n#################### INDEX ####################\n LEVEL = ", i, "\n" );
					PrintTable( info );
					i = i + 1;
				end
			end
		end,
		__newindex = function( t, k, v )
			if( k == "SCRIPTNAME" || k == "SCRIPTPATH" ) then
				local i = 1;
				while( true ) do
					local info = debug.getinfo(i);
					if( !info ) then break; end
					print( "\n#################### NEWINDEX ####################\n LEVEL = ", i, "\n" );
					PrintTable( info );
					i = i + 1;
				end
			end
		end,
	}
)
*/

/*
local ignore = {
	["SuperDOFWindow"] = true,
	["g_ClientSaveDupe"] = true,
}

local log = false;

local fag = hook;

function fag.GetTable()
	return fag._M.Hooks;
end

print( "function: ", fag.GetTable );

local old = hook;

old.GetTable = fag.GetTable;

hook = nil;

debug.setmetatable( _G, {
		__index = function( t, k )
			if( !ignore[k] && log ) then
				print( "__index: ", k );
			end
			if( k == "hook" ) then
				return old;
			end
			return rawget( t, k );
		end,
		
		__newindex = function( t, k, v )
			if( !ignore[k] && log ) then
				print( "__newindex: ", k, v );
			end
			rawset( t, k, v )
		end,
		
		__metatable = true,
	}
)

--[[
for k, v in pairs( old ) do
	hook[k] = v;
end
]]
concommand.Add( "toggle_logging", function()
	log = !log;
end )



concommand.Add( "test_func", function()
	print( "\n############### RUNSTRING ###############\n" );
	RunString( "print( 'test' ) " );
	print( "\n############### RUNSTRINGEX ###############\n" );
	RunStringEx( "print( 'test' ) ", "nigga" );
end )
*/