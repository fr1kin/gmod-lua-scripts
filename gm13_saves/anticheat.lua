// Anticheat

local _type = type;
local _pairs = pairs;
local _ipairs = ipairs;
local _rawget = rawget;
local _rawset = rawset;
local _runstring = RunString;
local _runstringex = RunStringEx;
local _setmetatable = setmetatable;
local _getmetatable = getmetatable;

local _package = package;
local _debug = debug;

local META = {};

//####################
// Metatables

local META = {};

META.memb = {};

function META:Create( t, newmeta )
	if( self.memb[t] ) then
		return;
	end
	self.memb[t] = {
		old = _debug.getmetatable( t ) || {},
		new = newmeta,
	};
	
	_debug.setmetatable( t, newmeta );
end

// util functions

local function SAFE__setmetatable( tbl, new )
	_debug.setmetatable( tbl, new );
	meta[tbl] = {};
	meta[tbl]["index"] = {};
	meta[tbl]["newindex"] = {};
	_debug.setmetatable( tbl, new );
end

local detours = {};

local function SAFE__detour( member, name, old, new ) // shitty but WHATEVA
	detours[new] = old;
	detours[name] = new;
	_G[member][name] = function(...)
		local ret = new(...);
		if( ret ) then
			return ret;
		end
	end
end

// debug - these are all blocked for a reason...

local function META__getindex( tbl )
	if( meta[tbl] ) then
		local index = function() end
		for k, v in _ipairs( meta[tbl]["index"] ) do
			local oI = index;
			index = function(...) 
				v(...);
				oI(...);
			end
		end
		return index;
	end
	return nil;
end

local function META__getnewindex( tbl )
	if( meta[tbl] ) then
		local newindex = function() end
		for k, v in _ipairs( meta[tbl]["newindex"] ) do
			local oI = newindex;
			newindex = function(...) 
				v(...);
				oI(...);
			end
		end
		return newindex;
	end
	return nil;
end

// TODO: fix
function debug__getinfo( o, ... )
	local ret_func = o;
	if( o && _type( o ) == "number" ) then
		ret_func = o + 1
	elseif( detours[o] )
		ret_func = detours[o];
	end
	local info = _debug.getinfo( ret_func, ... );
	if( info == nil ) then
		return nil;
	end
	info.func = ret_func;
	return info;
end

function debug__getupvalue( func, ... )
	if( detours[func] ) then
		return nil, nil;
	end
	return _debug.getupvalue( func, ... );
end

function debug__setupvalue( func, ... )
	if( detours[func] ) then
		return nil;
	end
	return _debug.setupvalue( func, ... );
end

function debug__setmetatable( tbl, new )
	if( meta[tbl] ) then
		meta[tbl]["index"][#meta[tbl]["index"] + 1] = new.__index;
		meta[tbl]["newindex"][#meta[tbl]["newindex"] + 1] = new.__newindex;
		return new;
	end
	return _setmetatable( tbl, new );
end

function debug__getmetatable( tbl )
	local ret = _getmetatable[tbl];
	if( meta[tbl] ) then
		ret.__index = META__getindex( tbl );
		ret.__newindex = META__getnewindex( tbl );
		return ret;
	end
	return ret;
end

SAFE__detour( "debug", "getinfo", debug.getinfo, debug__getinfo );
SAFE__detour( "debug", "getupvalue", debug.getupvalue, debug__getupvalue );
SAFE__detour( "debug", "getupvalue", debug.getupvalue, debug__setupvalue );
SAFE__detour( "debug", "setmetatable", debug.setmetatable, debug__setmetatable );
SAFE__detour( "debug", "getmetatable", debug.getmetatable, debug__getmetatable );

// lua base

local metablock = {
	["__index"] = true,
	["__newindex"] = true,
	["__metatable"] = true,
};

function __rawset( t, i, v )
	if( metablock[i] ) then
		return nil;
	end
	MAIN__newindex( t, i, v );
	return _rawset( t, i, v );
end

function __rawget( t, i )
	if( metablock[i] ) then
		return nil;
	end
	MAIN__index( t, i );
	return _rawget( t, i );
end

function __setmetatable( tbl, new )
	if( meta[tbl] ) then
		meta[tbl]["index"][#meta[tbl]["index"] + 1] = new.__index;
		meta[tbl]["newindex"][#meta[tbl]["newindex"] + 1] = new.__newindex;
		return new;
	end
	return _setmetatable( tbl, new );
end

function __getmetatable( tbl )
	local ret = _getmetatable[tbl];
	if( meta[tbl] ) then
		ret.__index = META__getindex( tbl );
		ret.__newindex = META__getnewindex( tbl );
		return ret;
	end
	return ret;
end

SAFE__detour( "_G", "setmetatable", setmetatable, __setmetatable );
SAFE__detour( "_G", "getmetatable", getmetatable, __getmetatable );

// package

// script detection
