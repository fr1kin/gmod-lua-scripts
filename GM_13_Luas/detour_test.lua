
local _R = debug.getregistry();

local playermeta = _R.Player;

local concommandrun = playermeta.ConCommand;

local convarmeta = _R.ConVar;

local getint = convarmeta.GetInt;

// Test global detours

local oldsmt = setmetatable;

setmetatable = function(...)
	print( "i am here to cheat and eat your fun" );
	return oldsmt(...)
end 

local oldfileexists = file.Exists;

file.Exists = function(...)
	print( "i am here to cheat and eat your fun" );
	return oldfileexists(...)
end

local oldinfo = debug.getinfo;

debug.getinfo = function(...)
	print( "i am here to cheat and eat your fun" );
	return oldinfo(...)
end

//debug.getupvalue = nil;

// Test registry detours

function playermeta.ConCommand( ... )
	print( "i am here to cheat and eat your fun" );
	return concommandrun(...)
end

function convarmeta.GetInt( ... )
	print( "i am here to cheat and eat your fun" );
	return getint(...)
end

// Test increased counts

cvars.GaySexIWantToCheat = "sethbot version 1.0"

// Test metatable shit

debug.setmetatable( _G, { __index = function(...) return rawget(...) end } )

debug.setmetatable( debug.getregistry(), { __index = function(...) return rawget(...) end } )

debug.setmetatable( hook, { __index = function(...) return rawget(...) end } )