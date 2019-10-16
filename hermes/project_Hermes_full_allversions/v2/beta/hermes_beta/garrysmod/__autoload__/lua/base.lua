/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: base.lua
	Purpose: Hack base for hooks, binds, and more.
*************************************************************/
if ( !CLIENT ) then return end

local table = table.Copy( table )
local cvars = table.Copy( cvars )
local string = table.Copy( string )
local file = table.Copy( file )
local sql = table.Copy( sql )

local require = require
local include = include
local tobool = tobool
local type = type

HERMES = {
	keys = {},
	log = {},
	sqls = {},
	item = {},
	hooks = {},
	detours = {},
	convar = {},
	binds = {},
	files = {},
	menu = {},
	mats = {},
	ccmds = {},
	copy = {},
	
	_lock = false,
	_canshoot = false,
}

/* --------------------
	:: Copy
*/ --------------------
local vars = {
	_GLOB = table.Copy( _G ),
	_CCCV = CreateClientConVar,
	_CMD = table.Copy( concommand ),
	_DEBUG = table.Copy( debug ),
	_FILE = table.Copy( file ),
	_HOOK = table.Copy( hook ),
	_GETVAR = GetConVar,
	_GETNUMBER = GetConVarNumber,
	_GETSTRING = GetConVarString,
	_VAREXISTS = ConVarExists,
	_SETMTABLE = setmetatable,
	_RAWSET = rawset,
	_RAWGET = rawget,
	_oldG = table.Copy( _G ),
	_oldCon = table.Copy( concommand ),
	_oldHook = table.Copy( hook ),
}

HERMES.include = include

local function GetMeta( meta )
	return table.Copy( _R[ meta ] || {} )
end

HERMES.copy['Angle'] = GetMeta( "Angle" )
HERMES.copy['CUserCmd'] = GetMeta( "CUserCmd" )
HERMES.copy['Entity'] = GetMeta( "Entity" )
HERMES.copy['Player'] = GetMeta( "Player" )
HERMES.copy['Vector'] = GetMeta( "Vector" )

/* --------------------
	:: Files
*/ --------------------
function HERMES:Msg( str, col )
	HERMES.hermes.Msg( "[HERMES]: ", col )
	HERMES.hermes.Msg( str .. "\n", Color( 255, 255, 255, 255 ) )
end

function HERMES:AddFile( name )
	if( !name ) then return end
	if( !HERMES.files[ name ] ) then
		HERMES.files[ name ] = true
		if( name != "base.lua" && string.find( name, ".lua" ) ) then
			HERMES:Msg( string.format( "Loading %s...", name ), Color( 0, 255, 0, 255 ) )
			HERMES.hermes.Include( "lua/" .. name, true )
		end
	end
end

/* --------------------
	:: Modules
*/ --------------------
function HERMES:AddModule( name, copy )
	if( !name || HERMES[ name ] ) then return end
	local fname = string.format( "../lua/includes/modules/gmcl_%s.dll", name )
	if( tobool( #file.Find( fname ) ) ) then
		//require( name )
		package.loaded[ name ] = nil
		HERMES[name] = table.Copy( _G[copy] )
		_G[copy] = nil
	end
end

HERMES:AddModule( "hermes", "cheat" )
HERMES:AddFile( "gmcl_hermes.dll" )

HERMES:AddFile( "base.lua" )

/* --------------------
	:: Detours
*/ --------------------
function HERMES:Detour( old, new )
	HERMES.detours[ new ] = old
	return new
end

/* --------------------
	:: SQL
*/ --------------------
function HERMES:SqlTable( name, ... )
	if( !name ) then return "Missing name" end
	if( !sql.TableExists( name ) ) then
		local args, str = {...}, {}
		for i = 1, table.Count( args ) do
			str[i] = args[i]
		end
		
		if( str && str[2] ) then
			local query = string.format( "CREATE TABLE %s ( %s int, %s varchar(255) )", name, str[1], str[2] )
			sql.Query( query )
			if( !sql.TableExists( name ) ) then
				return "Query has failed to be created"
			end
			return
		end
		return "Missing argument(s)"
	end
	return "Table already exists!"
end

function HERMES:SqlExists( name )
	if( !name ) then return end
	if( sql.TableExists( name ) ) then
		return true
	end
	return false
end

/* --------------------
	:: ConVar
*/ --------------------
local function RandomString( l )
	if( !l || l && l == 0 ) then return end
	local str = ""
	for i = 1, l do
		local s = string.char( math.random( 97, 122 ) )
		str = str .. s
	end
	return str || ""
end

local function ChangeValue( v )
	if( type( v ) == "boolean" ) then
		return v == true && 1 || 0
	elseif( type( v ) == "table" ) then
		return 2
	end
	return v
end

local function Menutype( v )
	if( type( v ) == "table" ) then
		return "multichoice"
	elseif( type( v ) == "number" ) then
		return "slider"
	elseif( type( v ) == "boolean" ) then
		return "checkbox"
	end
end

CreateClientConVar = HERMES:Detour( CreateClientConVar, function( cvar, val, save, def )
	if( HERMES.convar[name] ) then return end
	return HERMES.detours[ CreateClientConVar ]( cvar, val, save, def )
end )

HERMES.menu.tabs = {}

function HERMES:AddTab( name )
	if( !name || name && HERMES.menu.tabs[name] ) then return end
	HERMES.menu.tabs[ name ] = {}
end

function HERMES:AddTabItem( tab, name )
	if( !tab || tab && !HERMES.menu.tabs[tab] ) then return end
	table.insert( HERMES.menu.tabs[tab], name )
end

local saves = {}

function HERMES:AddSetting( name, value, desc, menu, ... )
	if( !name || !desc || !menu ) then return end
	if( !HERMES.convar[name] ) then
		local cvar, mtype = string.format( "_%s_%s", "hermes", name:lower() ), Menutype( value )
		value = ChangeValue( value )
		
		local convar, val, min, max, deci = vars._VAREXISTS( cvar ) && vars._GETVAR( cvar ) || vars._CCCV( cvar, value, true, false ), 0, nil, nil, nil
		if( mtype == "checkbox" ) then
			val = tobool( convar:GetInt() )
		elseif( mtype == "slider" || mtype == "multichoice" ) then
			val = tonumber( convar:GetString() )
			if( mtype == "slider" ) then
				local args = {...}
				min, max, deci = args[1] || nil, args[2] || nil, args[3] || nil
			end
		end
		
		HERMES.item[desc:lower()] = val
		HERMES.menu[desc:lower()] = { Name = cvar, ConVar = convar:GetName(), Value = val, Desc = desc, Menu = menu, Max = max, Min = min, Decimal = deci }
		
		local function Callbacks()
			if( mtype == "checkbox" ) then
				local new = tobool( math.floor( vars._GETNUMBER( cvar ) ) )
				if( !saves[desc:lower()] || new != saves[desc:lower()] ) then
					HERMES.item[desc:lower()] = new
					saves[desc:lower()] = new
				end
			elseif( mtype == "slider" ) then
				local new = tonumber( vars._GETNUMBER( cvar ) )
				if( !saves[desc:lower()] || new != saves[desc:lower()] ) then
					HERMES.item[desc:lower()] = new
					saves[desc:lower()] = new
				end
			else
				local new = vars._GETSTRING( cvar )
				if( !saves[desc:lower()] || new != saves[desc:lower()] ) then
					HERMES.item[desc:lower()] = new
					saves[desc:lower()] = new
				end
			end
			timer.Simple( 0.1, Callbacks )
		end
		Callbacks()
		
		HERMES.convar[name] = cvar
	end
end

// Add extra cvars...
HERMES.convar["sv_cheats"] = "_hermes_sv_cheats"
HERMES.convar["host_timescale"] = "_hermes_host_timescale"
HERMES.convar["r_drawparticles"] = "_hermes_r_drawparticles"
HERMES.convar["r_drawothermodels"] = "_hermes_r_drawothermodels"
HERMES.convar["sv_consistency"] = "_hermes_sv_consistency"
HERMES.convar["mat_fullbright"] = "_hermes_mat_fullbright"
HERMES.convar["sv_allow_voice_from_file"] = "_hermes_sv_allow_voice_from_file"
HERMES.convar["voice_inputfromfile"] = "_hermes_voice_inputfromfile"

function HERMES:GetVarNumber( var )
	local cvar = string.format( "_%s_%s", "hermes", HERMES.convar[var:lower()] )
	return vars._GETNUMBER( cvar )
end

function HERMES:GetVarString( var )
	local cvar = string.format( "_%s_%s", "hermes", HERMES.convar[var:lower()] )
	return vars._GETSTRING( cvar )
end

function HERMES:VarExists( var )
	local cvar = string.format( "_%s_%s", "hermes", HERMES.convar[var:lower()] )
	return vars._VAREXISTS( cvar )
end

function HERMES:RunCommand( var, val )
	val = tostring( val )
	local cvar = string.format( "_%s_%s %s", "hermes", HERMES.convar[var:lower()], val )
	return HERMES.hermes.RunCommand( cvar )
end

/* --------------------
	:: Hooks
*/ --------------------
function HERMES:AddHook( name, func )
	if( !name || !func ) then return end
	HERMES.hooks[ name ] = func
end

/* --------------------
	:: ConCommands
*/ --------------------
function HERMES:AddCommand( name, func )
	HERMES.ccmds[name] = func
	AddConsoleCommand( name )
end

/* --------------------
	:: Binds
*/ --------------------
function HERMES:Bind( key, func, checkexist )
	if( !key || !func ) then return end
	if( checkexist && HERMES.binds[ func ] ) then return end
	if( HERMES:SqlExists( "hermes_binds" ) ) then
		if( HERMES.binds[ func ] ) then
			HERMES:Unbind( func )
		end
		
		for i = 1, table.Count( HERMES.keys ) do
			if ( tkey:lower() == key:lower() ) then
				HERMES.binds[ func ] = v
			end
		end
	end
end

function HERMES:Unbind( func )
	if ( !func ) then return end
	if( HERMES:SqlExists( "hermes_binds" ) && HERMES.binds[ func ] ) then
		HERMES.binds[ func ] = nil
	end
end

/* --------------------
	:: Extra functions
*/ --------------------
local function GetGamemode( ... )
	local args, gt1, gt2 = { ... }, GAMEMODE && GAMEMODE.Name || "nil", GetConVarString( "sv_gamemode" )
	if ( type( args ) != "table" ) then return end
	
	local sf, sl, n = string.find, string.lower, 0
	for k, v in pairs( args ) do
		if ( ( type( v ) == "string" ) && ( sf( sl( gt1 ), v ) || sf( sl( gt2 ), v ) ) ) then
			n = n + 1
		end
	end
	return ( n != 0 && true || false )
end

local function IsGamemode( ... )
	return GetGamemode( ... )
end

local function GetBase( ... )
	local ply = LocalPlayer()
	
	local w = ply:GetActiveWeapon()
	if ( !ply || !w ) then return false end
	local args = { ... }
	
	for k, v in pairs( args ) do
		if ( w.Base && w.Base == v ) then
			return true
		end
	end
	return false
end

local function GetSelf()
	return LocalPlayer()
end

local function IsDormant( e )
	if( !HERMES['hermes']  ) then return false end
	if( !HERMES['hermes'].IsDormant ) then return false end
	if( !e:IsPlayer() ) then return false end
	local index = e:EntIndex()
	return HERMES.hermes.IsDormant( index )
end

local function GetCallPaths( copy )
	local ret, cpath = {}, "__autoload__\\lua"
	for k, v in pairs( copy.files ) do
		if( string.find( k:lower(), ".lua" ) ) then
			local f = string.gsub( k, "/", "\\" )
			table.insert( ret, string.format( "%s\\%s", cpath, f ) )
		end
	end
	return ret || nil
end

local function CopyTable( var )
	if( !var ) then return end
	var = table.Copy( var )
end

HERMES.GetGamemode = GetGamemode
HERMES.CopyTable = CopyTable
HERMES.IsDormant = IsDormant
HERMES.GetBase = GetBase
HERMES.GetSelf = GetSelf
HERMES.GetCallPaths = GetCallPaths

HERMES.vars = table.Copy( vars )

/* --------------------
	:: Add Files
*/ --------------------
HERMES:AddFile( "nospread.lua" )
HERMES:AddFile( "traitor.lua" )
HERMES:AddFile( "aimbot.lua" )
HERMES:AddFile( "other.lua" )
HERMES:AddFile( "esp.lua" )
HERMES:AddFile( "trigger.lua" )
HERMES:AddFile( "material.lua" )
HERMES:AddFile( "chams.lua" )
HERMES:AddFile( "autowall.lua" )
HERMES:AddFile( "menu/_main.lua" )
HERMES:AddFile( "detours.lua" )

local _backup = table.Copy( HERMES )

/* --------------------
	:: BACKUP
*/ --------------------
local function __reload()
	if( !HERMES ) then
		HERMES = _backup
	end
	timer.Simple( 10, __reload )
end
__reload()