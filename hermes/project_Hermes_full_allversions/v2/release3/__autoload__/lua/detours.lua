/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: detours.lua
	Purpose: Hack protection
*************************************************************/
local ply, vars = HERMES.GetSelf, table.Copy( HERMES.vars )
local x, y = ScrW(), ScrH()

local detour = {}

/* --------------------
	:: Anti-screenshot
*/ --------------------
local fvars = {
	["r_drawparticles"] = { last = 1, off = 1 },
	["r_drawothermodels"] = { last = 1, off = 1 },
	["mat_fullbright"] = { last = 0, off = 0 },
}

local function __RELOAD__()
	HERMES._lock = false;
	for k, v in ipairs( fvars ) do
		HERMES.hermes.RunCommand( string.format( "_hermes_%s %c", k, v.last ) )
	end
end

local function __SHUTDOWN__()
	HERMES._lock = true;
	for k, v in ipairs( fvars ) do
		HERMES.hermes.RunCommand( string.format( "_hermes_%s %c", k, v.off ) )
		v.last = vars._GETNUMBER( string.format( "_hermes_%s", k ) )
	end
end

// Got to work on this some more...
render.ReadPixel = HERMES:Detour( render.ReadPixel, function( x, y )
	__SHUTDOWN__();
	local r, g, b = HERMES.detours[ render.ReadPixel ]( x, y );
	__RELOAD__();
	
	return r, g, b
end )

/* --------------------
	:: Unlock
*/ --------------------
local function Unlock()
	if( _G['rawset'] ) then
		vars._RAWSET( _G, "__metatable", nil )
		vars._RAWSET( hook, "__metatable", nil )
		vars._RAWSET( concommand, "__metatable", nil )
	end
	
	// worth a try
	_G['__metatable'] = nil;
	hook['__metatable'] = nil;
	concommand['__metatable'] = nil;
end
Unlock()

/* --------------------
	:: HERMES
*/ --------------------
local scopy = table.Copy( HERMES )

local function IsCallpath( info )
	if( !info ) then return true end
	if( info && string.find( info.short_src, "__autoload__" ) ) then
		return true
	end
	return false
end

local function ProtectTable()
	if( !rawget || !rawset ) then return end // its like we're allways having gay sex
	_G['HERMES'] = nil

	vars._SETMTABLE( _G,
		{
			__index = function( t, k )
				if( k == "HERMES" ) then
					if( IsCallpath( vars._DEBUG.getinfo( 2, "S" ) ) ) then
						return scopy
					end
				end
				return vars._RAWGET( t, k )
			end,
			
			__newindex = function( t, k, v )
				if( k == "HERMES" ) then
					if( !IsCallpath( vars._DEBUG.getinfo( 2, "S" ) ) ) then
						return
					end
				end
				return vars._RAWSET( t, k, v )
			end,
			
			__metatable = true,
		}
	)
end
ProtectTable()

/* --------------------
	:: Hook
*/ --------------------
local oldHookCall = hook.Call
local function IsValidCommand( ply, bind, press ) 
	if( HERMES.ccmds[bind:lower()] ) then
		return true
	end
	return false
end

local function CallHook( name, gm, ... )
	local args = {...}
	
	if( name == "PlayerBindPress" && !HERMES._lock && IsValidCommand( ... ) ) then return false end
	for k, e in pairs( HERMES['hooks'] ) do
		if( k == name ) then
			if( args == nil ) then
				ret = e()
			else
				ret = e( ... )
			end
			if( ret != nil ) then return ret end
		end
	end
	return vars['_HOOK'].Call( name, gm, ... )
end

hook = {}

vars._SETMTABLE( hook,
	{
		__index = function( t, k )
			if( k == "Call" ) then 
				return CallHook 	
			end
			return HERMES['vars']._HOOK[ k ]
		end,
		
		__newindex = function( t, k, v ) 
			if( k == "Call" ) then 
				if( v != CallHook ) then
					oldHookCall = v 
				end
				return
			end
			HERMES['vars']._HOOK[ k ] = v 
		end,
		
		__metatable = true,
	}
)

/* --------------------
	:: ConCommand
*/ --------------------
local oldConCommandRun = concommand.Run

local function RunCommand( ply, name, ... )
	local tbl = HERMES.ccmds[name]
	
	if( tbl ) then
		return tbl( ply, name, ... )
	end
	return vars['_CMD'].Run( ply, name, ... )
end

concommand = {}

vars._SETMTABLE( concommand,
	{
		__index = function( t, k )
			if( k == "Run" ) then 
				return RunCommand 	
			end
			return HERMES['vars']._CMD[ k ]
		end,
		
		__newindex = function( t, k, v ) 
			if( k == "Run" ) then 
				if( v != RunCommand ) then
					oldConCommandRun = v 
				end
				return
			end
			HERMES['vars']._CMD[ k ] = v 
		end,
		
		__metatable = true,
	}
)

/* --------------------
	:: cvars
*/ --------------------
cvars.OnConVarChanged = HERMES:Detour( cvars.OnConVarChanged, function( name, old, new )
	for k, v in pairs( HERMES.convar ) do
		if( string.find( name:lower(), v ) ) then
			return;
		end
	end
	return HERMES.detours[ cvars.OnConVarChanged ]( name, old, new )
end )

/* --------------------
	:: GetMeta
*/ --------------------
local GETMETA = vars._GLOB.getmetatable

local metas = {
	hooks = GETMETA( HERMES['vars']._oldHook ),
	concommands = GETMETA( HERMES['vars']._oldCon ),
	global = GETMETA( HERMES['vars']._oldG )
}

setmetatable = HERMES:Detour( setmetatable, function( meta, cont )
	if( meta == hook ) then
		metas.hooks = cont
	elseif( meta == concommand ) then
		metas.concommands = cont
	elseif( meta == _G ) then
		metas.global = cont
	else
		HERMES.detours[ setmetatable ]( meta, cont )
	end
	return meta
end )

getmetatable = HERMES:Detour( getmetatable, function( meta, ... )
	if( meta == hook ) then
		return metas.hooks
	elseif( meta == concommand ) then
		return metas.concommands
	elseif( meta == _G ) then
		return metas.global
	end
	return HERMES.detours[ getmetatable ]( meta, ... )
end )

debug['setmetatable'] = setmetatable
debug['getmetatable'] = getmetatable
/* --------------------
	:: Debug
*/ --------------------
debug.getinfo = HERMES:Detour( debug.getinfo, function( func, path )
	return HERMES.detours[ debug.getinfo ]( HERMES.detours[ func ] || func, path )
end )

/* --------------------
	:: Raw
*/ --------------------
rawequal = HERMES:Detour( rawequal, function( var1, var2 )
	if( HERMES.detours[ var1 ] && var1 == var2 ) then
		return true
	end
	return HERMES.detours[ rawequal ]( var1, var2 )
end )

rawset = HERMES:Detour( rawset, function( func, name, value )
	if( func == "hook" || func == "_G" || func == "concommand" ) then
		return
	end
	return HERMES.detours[ rawequal ]( func, name, value )
end )

/* --------------------
	:: CreateMaterial
*/ --------------------
CreateMaterial = HERMES:Detour( CreateMaterial, function( name, shader, info )
	return HERMES.detours[ CreateMaterial ]( name, shader, info )
end )


/* --------------------
	:: Global Library
*/ --------------------
local function GlobalDetour( func, ret )
	if( !func ) then return end
	_G[ func ] = HERMES:Detour( _G[ func ], function( ... )
		local args = {...}
		for _, i in pairs( args ) do
			for k, v in pairs( HERMES.convar ) do
				if( string.find( i:lower(), v ) ) then
					return ret != nil && ret || ""
				end
			end
		end
		return HERMES.detours[ _G[ func ] ]( ... )
	end )
end

detour.g = {
	{ func = "GetConVar", ret = nil },
	{ func = "ConVarExists", ret = false },
	{ func = "GetConVarNumber", ret = nil },
	{ func = "GetConVarString", ret = nil },
}

for k, v in pairs( detour.g ) do
	GlobalDetour( v.func, v.ret )
end

/*
RunConsoleCommand = HERMES:Detour( RunConsoleCommand, function( ... )
	local args = {...}
	for k, v in pairs( HERMES.convar ) do
		if( args[1] && string.find( args[1]:lower(), k ) ) then
			return
		end
	end
	return HERMES.detours[ RunConsoleCommand ]( ... )
end )

_R.Player.ConCommand = HERMES:Detour( _R.Player.ConCommand, function( ... )
	local args = {...}
	for k, v in pairs( HERMES.convar ) do
		if( args[1] && string.find( args[1]:lower(), k ) ) then
			return
		end
	end
	return HERMES.detours[ _R.Player.ConCommand ]( ... )
end )
*/

/* --------------------
	:: Files
*/ --------------------
local function FileDetour( func, ret )
	if( !func ) then return end
	file[ func ] = HERMES:Detour( file[ func ], function( ... )
		local args = {...}
		for _, i in pairs( args ) do
			for k, v in pairs( HERMES.files ) do
				if( type( i ) == "string" && string.find( i:lower(), k ) ) then
					return ret != nil && ret || ""
				end
			end
		end
		return HERMES.detours[ file[ func ] ]( ... )
	end )
end

detour.f = {
	{ func = "CreateDir", ret = nil },
	{ func = "Delete", ret = nil },
	{ func = "Read", ret = nil },
	{ func = "Exists", ret = false },
	{ func = "ExistsEx", ret = false },
	{ func = "Write", ret = nil },
	{ func = "Time", ret = 0 },
	{ func = "Size", ret = -1 },
	{ func = "Rename", ret = nil },
}

for k, v in pairs( detour.f ) do
	FileDetour( v.func, v.ret )
end

// Extra stuff that cannot be detoured with this function
file.Find = HERMES:Detour( file.Find, function( name )
	local find = HERMES.detours[ file.Find ]( name )
	for k, v in pairs( find ) do
		for u, e in pairs( HERMES.files ) do
			if ( string.find( string.lower( u ), v ) ) then
				find[ k ] = nil
			end
		end
	end
	return find
end )

file.FindInLua = HERMES:Detour( file.FindInLua, function( name )
	local find = HERMES.detours[ file.FindInLua ]( name )
	for k, v in pairs( find ) do
		for u, e in pairs( HERMES.files ) do
			if ( string.find( string.lower( u ), v ) ) then
				find[ k ] = nil
			end
		end
	end
	return find
end )

file.TFind = HERMES:Detour( file.TFind, function( name )
	return HERMES.detours[ file.TFind ]( name, function( name, folder, files )
		for k, v in pairs( folder ) do
			for u, e in pairs( HERMES.files ) do
				if ( string.find( string.lower( u ), v ) ) then
					folder[ k ] = nil
				end
			end
		end
		for k, v in pairs( files ) do
			for u, e in pairs( HERMES.files ) do
				if ( string.find( string.lower( u ), v ) ) then
					files[ k ] = nil
				end
			end
		end
		return call( path, folder, files )
	end )
end )