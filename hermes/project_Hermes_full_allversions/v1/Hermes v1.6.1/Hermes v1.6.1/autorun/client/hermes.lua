/*------------------------------------------------------------------------------------------------------
   __ __                        
  / // /___  ____ __ _  ___  ___
 / _  // -_)/ __//  ' \/ -_)(_-<
/_//_/ \__//_/  /_/_/_/\__//___/
Hermes :: GMOD Edition

If you've leaked this then congrats
Creates to many people because I'm lazy as fuck and steal their codex.
*/------------------------------------------------------------------------------------------------------

if ( !CLIENT ) then return end
if ( !ConVarExists( "hermes_load" ) ) then return end
if ( Hermes ) then _G.Hermes = nil end -- niggherts

include( "includes/init.lua" )
include( "includes/extensions/table.lua" )

/*----------------------------------------
	Tables
	Desc: Local tables used to store data.
*/----------------------------------------
local Hermes 		= {}
Hermes.features		= {}
Hermes.menuitems	= {}
Hermes.commands		= {}
Hermes.hooks		= {}
Hermes.detours		= {}
Hermes.loaded		= {}
Hermes.files		= {}
Hermes.changedcvars = {}
Hermes.detours		= {}
Hermes.friends		= ( file.Exists( "hermes_lists_friends.txt" ) && KeyValuesToTable( file.Read( "hermes_lists_friends.txt" ) ) || {} )
Hermes.entities		= ( file.Exists( "hermes_lists_entities.txt" ) && KeyValuesToTable( file.Read( "hermes_lists_entities.txt" ) ) || {} )
Hermes.log			= ( file.Exists( "hermes_log.txt" ) && KeyValuesToTable( file.Read( "hermes_log.txt" ) ) || {} )
Hermes.binds		= ( file.Exists( "hermes_lists_binds.txt" ) && KeyValuesToTable( file.Read( "hermes_lists_binds.txt" ) ) || {} )

Hermes.func = {
	hooked = {}
}

Hermes.copy = {
	require = require,
	GetConVar = GetConVar,
	ConVarExists = ConVarExists,
	GetConVarNumber = GetConVarNumber,
	GetConVarString = GetConVarString,
	CreateClientConVar = CreateClientConVar,
	engineConsoleCommand = engineConsoleCommand,
	Global = table.Copy( _G ),
	hook = table.Copy( hook ),
	cvars = table.Copy( cvars ),
	file = table.Copy( file ),
	debug = table.Copy( debug ),
	sql = table.Copy( sql ),
	string = table.Copy( string ),
	draw = table.Copy( draw ),
	surface = table.Copy( surface ),
	GetInt = _R.ConVar.GetInt,
	GetBool = _R.ConVar.GetBool,
	ConCommand = _R.Player.ConCommand,
	Name = _R.Player.Name,
	Nick = _R.Player.Nick
}

Hermes.set = {
	aiming = false,
	target = nil,
	tar = nil,
	angles = Angle( 0, 0, 0 ),
	fakeang = Angle( 0, 0, 0 ),
	antiaimang = Angle( 0, 0, 0 ),
	trigger = false,
	oldtar = nil,
	shooting = false,
}

Hermes.getcvars = {}
Hermes.convars = {
	{ Item = "Aimbot", Setting = {
			{ Tab = "Aimbot", Items = {
					{ ConVar = "aimtype", Value = 1, Contents = { "Default", "Bone", "GetPos", "OBBCenter" }, Desc = "Aimtype:", Type = "multichoice", None = false },
					{ ConVar = "aimmode", Value = 1, Contents = { "Crosshair", "Distance", "Health" }, Desc = "Aimmode:", Type = "multichoice", None = false },
					{ ConVar = "autoshoot", Value = 1, Desc = "Autoshoot", Type = "checkbox" },
					{ ConVar = "silentaim", Value = 0, Desc = "Silent-aim", Type = "checkbox" },
					{ ConVar = "prediction", Value = 1, Desc = "Prediction", Type = "checkbox" },
					{ ConVar = "loscheck", Value = 1, Desc = "LOS Check", Type = "checkbox" },
					{ ConVar = "velocitychecks", Value = 1, Desc = "Velocity Checks", Type = "checkbox" },
					{ ConVar = "smoothaim", Value = 1, Desc = "Smooth-aim", Type = "checkbox" },
					{ ConVar = "holdtarget", Value = 0, Desc = "Hold Target", Type = "checkbox" },
					{ ConVar = "disableafterkill", Value = 0, Desc = "Disable-after-kill", Type = "checkbox" },
					{ ConVar = "offset", Value = 0, Desc = "Offset", Type = "slider", Max = 100, Min = -100 },
					{ ConVar = "fov", Value = 180, Desc = "Feild-of-view", Type = "slider", Max = 180, Min = 0 },
					{ ConVar = "smoothaimspeed", Value = 5, Desc = "Smooth-aim Speed", Type = "slider", Max = 10, Min = 0.1, Decimal = true },
					{ ConVar = "predicttar", Value = 45, Desc = "Prediction Player", Type = "slider", Max = 120, Min = 0 },
					{ ConVar = "predictply", Value = 45, Desc = "Prediction Self", Type = "slider", Max = 120, Min = 0 },
				}
			},
			
			{ Tab = "Targeting", Items = {
					{ ConVar = "friendslist", Value = 1, Desc = "Enable Friends-list", Type = "checkbox" },
					{ ConVar = "targetplayer", Value = 1, Desc = "Players", Type = "checkbox" },
					{ ConVar = "targetnpc", Value = 0, Desc = "NPCs", Type = "checkbox" },
					{ ConVar = "ignoreadmin", Value = 0, Desc = "Ignore Admins", Type = "checkbox" },
					{ ConVar = "ignoresteam", Value = 0, Desc = "Ignore Steam", Type = "checkbox" },
					{ ConVar = "ignoreteam", Value = 0, Desc = "Ignore Team", Type = "checkbox" },
					{ ConVar = "ignoretraitor", Value = 0, Desc = "Ignore Traitor", Type = "checkbox" },
					{ ConVar = "ignoreghost", Value = 0, Desc = "Ignore Ghost", Type = "checkbox" },
					{ ConVar = "ignorevehicle", Value = 0, Desc = "Ignore Players in Vehicles", Type = "checkbox" },
				}
			},
			
			{ Tab = "Triggerbot", Items = {
					{ ConVar = "triggerbot", Value = 0, Desc = "Triggerbot", Type = "checkbox" },
					{ ConVar = "triggerkey", Value = 0, Desc = "Trigger Key", Type = "checkbox" },
					{ ConVar = "triggernospread", Value = 0, Desc = "Trigger Nospread", Type = "checkbox" },
					{ ConVar = "triggerdistance", Value = 156, Desc = "Trigger Distance", Type = "slider", Min = 0, Max = 10000 },
				}
			},
			
			{ Tab = "HUD", Items = {
					{ ConVar = "toggle", Value = 1, Desc = "Toggle HUD", Type = "checkbox" },
					{ ConVar = "togglename", Value = 0, Desc = "Print Name", Type = "checkbox" },
				}
			},
			
			{ Tab = "Accuracy", Items = {
					{ ConVar = "nospread", Value = 1, Contents = { "Always", "In Attack" }, Desc = "Nospread:", Type = "multichoice", None = true },
					{ ConVar = "norecoil", Value = 0, Desc = "Norecoil", Type = "checkbox" },
					{ ConVar = "novisspread", Value = 1, Desc = "No-visual-spread", Type = "checkbox" },
				}
			},
		},
	
	Prefix = "aim_"
	},
	
	{ Item = "ESP", Setting = {
			{ Tab = "General", Items = {
					{ ConVar = "font", Value = 6, Contents = {}, Desc = "Font:", Type = "multichoice", None = false },
					{ ConVar = "enablefade", Value = 0, Desc = "Enable Fade", Type = "checkbox" },
					{ ConVar = "maxshow", Value = 10, Desc = "Max Entity Show", Type = "slider", Min = 1, Max = 50 },
					{ ConVar = "fadelength", Value = tonumber( ScrW() / 4 ), Desc = "Fade Length", Type = "slider", Min = 50, Max = 500 },
				}
			},
			
			{ Tab = "Players", Items = {
					{ ConVar = "optical", Value = 1, Contents = { "3D Box", "2D Box" }, Desc = "Optical:", Type = "multichoice", None = true },
					{ ConVar = "enable", Value = 0, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "enemyonly", Value = 0, Desc = "Enemy Only", Type = "checkbox" },
					{ ConVar = "name", Value = 1, Desc = "Name", Type = "checkbox" },
					{ ConVar = "health", Value = 1, Desc = "Health", Type = "checkbox" },
					{ ConVar = "weapon", Value = 0, Desc = "Weapon", Type = "checkbox" },
					{ ConVar = "friendsmark", Value = 0, Desc = "Friends ESP", Type = "checkbox" },
					{ ConVar = "adminlist", Value = 0, Desc = "Admin-list", Type = "checkbox" },
				}
			},
			
			{ Tab = "NPCs", Items = {
					{ ConVar = "enablen", Value = 1, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "boxn", Value = 1, Desc = "Box", Type = "checkbox" },
				}
			},
			
			{ Tab = "Entities", Items = {
					{ ConVar = "enablee", Value = 1, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "entityliste", Value = 1, Desc = "Enable Entity-list", Type = "checkbox" },
					{ ConVar = "weaponse", Value = 1, Desc = "Weapons", Type = "checkbox" },
					{ ConVar = "ragdollse", Value = 0, Desc = "Ragdolls", Type = "checkbox" },
					{ ConVar = "vehiclese", Value = 0, Desc = "Vehicles", Type = "checkbox" },
				}
			},
			
			{ Tab = "Chams", Items = {
					{ ConVar = "walltype", Value = 2, Contents = { "Solid", "Wireframe", "XQZ" }, Desc = "Material:", Type = "multichoice", None = true },
					{ ConVar = "fullbright", Value = 1, Desc = "Fullbright", Type = "checkbox" },
					{ ConVar = "visiblechams", Value = 0, Desc = "Visible Chams", Type = "checkbox" },
				}
			},
			
			{ Tab = "Proxy", Items = {
					{ ConVar = "proxy", Value = 0, Desc = "Proxy Models", Type = "checkbox" },
					{ ConVar = "proxyvalue", Value = 200, Desc = "Proxy Value", Type = "slider", Min = 0, Max = 255 },
				}
			},
		},
	
	Prefix = "esp_"
	},
	
	{ Item = "Misc", Setting = {
			{ Tab = "Misc", Items = {
					{ ConVar = "namesteal", Value = 0, Desc = "Name Stealer", Type = "checkbox" },
					{ ConVar = "bunnyhop", Value = 1, Desc = "Bunnyhop", Type = "checkbox" },
					{ ConVar = "autopistol", Value = 1, Desc = "Autopistol", Type = "checkbox" },
					{ ConVar = "ulxantigag", Value = 1, Desc = "Anti-gag", Type = "checkbox" },
					{ ConVar = "spoofname", Value = 0, Desc = "Spoof-name", Type = "checkbox" },
				}
			},
			
			{ Tab = "Crosshair", Items = {
					{ ConVar = "crosshairtype", Value = 1, Contents = { "Gap", "Filled" }, Desc = "Crosshair", Type = "multichoice", None = false },
					{ ConVar = "crosshair", Value = 1, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "crosshairgap", Value = 5, Desc = "Crosshair Gap", Type = "slider", Min = 1, Max = 100, Decimal = false },
					{ ConVar = "crosshairlength", Value = 5, Desc = "Crosshair Size", Type = "slider", Min = 1, Max = 100, Decimal = false },
				}
			},
			
			{ Tab = "Radar", Items = {
					{ ConVar = "radar", Value = 1, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "radarname", Value = 1, Desc = "Show Names", Type = "checkbox" },
					{ ConVar = "radarspin", Value = 1, Desc = "Spinner", Type = "checkbox" },
					{ ConVar = "radarradius", Value = 1, Desc = "Radar Radius", Type = "slider", Min = 1, Max = 16384, Decimal = false },
				}
			},
			
			{ Tab = "Globals", Items = {
					{ ConVar = "fullbrightg", Value = 0, Desc = "Fullbright", Type = "checkbox" },
					{ ConVar = "particles", Value = 0, Desc = "Particle Removal", Type = "checkbox" },
				}
			},
			
			{ Tab = "Speedhack", Items = {
					{ ConVar = "speedhack", Value = 1, Desc = "Speed-hack", Type = "checkbox" },
					{ ConVar = "speedhackspeed", Value = 1, Desc = "Speed-hack Value", Type = "slider", Min = 1, Max = 10, Decimal = true },
				}
			},
			
			{ Tab = "Zoom", Items = {
					{ ConVar = "zoom", Value = 0, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "zoomalways", Value = 0, Desc = "Always Zoom", Type = "checkbox" },
					{ ConVar = "zoomonaim", Value = 0, Desc = "On Aim", Type = "checkbox" },
					{ ConVar = "zoomontrigger", Value = 0, Desc = "On Trigger", Type = "checkbox" },
					{ ConVar = "zoomamount", Value = 1, Desc = "Zoom Amount", Type = "slider", Min = 0, Max = 10, Decimal = true },
				}
			},
			
			{ Tab = "AntiAim", Items = {
					{ ConVar = "antiaim", Value = 1, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "antiaimrandom", Value = 1, Desc = "Random Angles", Type = "checkbox" },
					{ ConVar = "antiaimduck", Value = 1, Desc = "Auto duck", Type = "checkbox" },
					{ ConVar = "antiaimp", Value = 360, Desc = "Angle P", Type = "slider", Min = 0, Max = 360 },
					{ ConVar = "antiaimy", Value = 360, Desc = "Angle Y", Type = "slider", Min = 0, Max = 360 },
					{ ConVar = "antiaimr", Value = 0, Desc = "Angle R", Type = "slider", Min = 0, Max = 360 },
				}
			},
		},
	
	Prefix = "misc_"
	},
}

Hermes.deathsequences = {
	[ "models/barnacle.mdl" ] = { 4, 15 },
	[ "models/antlion_guard.mdl" ] = { 44 },
	[ "models/hunter.mdl" ] = { 124, 125, 126, 127, 128 }
}

Hermes.bypassedvars = {
	{ ConVar = "gl_clear", Spoof = 0 },
	{ ConVar = "r_drawsky", Spoof = 1 },
	{ ConVar = "r_3dsky", Spoof = 1 },
}

Hermes.allfiles = { 
	"hermes.lua", 
	"hermes_lists_friends.txt", 
	"hermes_lists_entities.txt", 
	"hermes_lists_binds.txt", 
	"hermes_log.txt", 
	"inject.lua", 
	"gmcl_sys.dll", 
	"gmcl_cmd.dll", 
	"hake.dll", 
	"hermes_cvar.dll", 
	"hermes", 
	"sys", 
	"cmd"
}

Hermes.path = "lua\\autorun\\client\\hermes.lua"

-- Create 'files' table
Hermes.files = {}
for k, v in pairs( Hermes.allfiles ) do
	Hermes.files[ v ] = v
end

-- Other vars
local string = table.Copy( string )
local surface = table.Copy( surface )
local draw = table.Copy( draw )
local file = table.Copy( file )
local table = table.Copy( table )
local timer = table.Copy( timer )
local ents = table.Copy( ents ) 
local player = table.Copy( player ) 
local math = table.Copy( math ) 
local vgui = table.Copy( vgui )
local util = table.Copy( util )

/*----------------------------------------
	CVar Tables
	Desc: Add cvars to a table for easy use.
*/----------------------------------------
Hermes.repcvars = {
	"sv_cheats",
	"host_timescale",
	"mat_wireframe",
	"r_drawparticles",
	"r_drawothermodels",
	"r_drawbrushmodels",
	"sv_consistency",
	"fog_enable",
	"fog_enable_water_fog",
	"mat_fullbright",
	"mat_reversedepth",
	"sv_allow_voice_from_file",
	"voice_inputfromfile",
	"sv_scriptenforcer"
}

function Hermes.func:AddCVarsToTable()
	for k, v in pairs( Hermes.convars ) do
		for t, u in pairs( v.Setting ) do
			for m, n in pairs( u.Items ) do
				local endtext = string.gsub( u.Tab, " ", "" )
				endtext = string.gsub( u.Tab, "-", "" )
				endtext = "_" .. endtext
				
				local cvar = string.lower( tostring( "hermes_" .. v.Prefix .. n.ConVar .. endtext ) )
				Hermes.getcvars[ cvar ] = cvar
			end
		end
	end
	for r, p in pairs( Hermes.repcvars ) do
		local cvar = string.lower( tostring( "hermes_" .. p ) )
		Hermes.getcvars[ cvar ] = cvar
	end
end
Hermes.func:AddCVarsToTable()

function Hermes.func:AddClientVarsToTable()
	for k, v in pairs( Hermes.bypassedvars ) do
		Hermes.changedcvars[ v.ConVar ] = { v.Spoof }
	end
end
Hermes.func:AddClientVarsToTable()

-- Extra vars:
Hermes.getcvars[ "hermes_load" ] = "hermes_load"

//------------------------------
// Self name:
//------------------------------
Hermes.selfname = nil
Hermes.selfloop = true
local function GetMyName()
	if ( !Hermes.selfloop ) then return end
	local ply = LocalPlayer()
	if ( ply && ply:IsValid() ) then
		Hermes.selfname = ply:Nick()
		Hermes.selfloop = false
	end
	timer.Simple( 0.1, GetMyName )
end
timer.Simple( 0.1, GetMyName )

//------------------------------
// Detour:
//------------------------------
Hermes.metatable = { hook }

function Hermes:Detour( old, new )
	Hermes.detours[ new ] = old
	return new
end

Hermes:Detour( debug.getinfo, function( func, path )
	return Hermes.files[ debug.getinfo ]( Hermes.files[ func ] || func, path )
end )

Hermes:Detour( require, function( obj )
	return Hermes.files[ require ]( Hermes.files[ obj ] || obj )
end )

Hermes:Detour( setmetatable, function( obj )
	return Hermes.files[ setmetatable ]( Hermes.metatable[ obj ] || obj )
end )

//------------------------------
// Hooks:
//------------------------------
local oldCallHook = hook.Call

local function CallHook( name, gm, ... )
	if ( Hermes.hooks[ name ] ) then
		Hermes.copy.hook.Call( name, gm, unpack( arg ) )
		return Hermes.hooks[ name ]( unpack( arg ) )
	end
	return Hermes.copy.hook.Call( name, gm, unpack( arg ) )
end

hook = {}

// Set metatable for hooks
setmetatable( hook, 
	{ __index = function( t, k )
		if( k == "Call" ) then 
			return CallHook
		end
		return Hermes.copy.hook[ k ] end,
		
		__newindex = function( t, k, v ) 
			if( k == "Call" ) then 
				if( v != CallHook ) then 
					oldCallHook = v 
				end 
				return
			end
			Hermes.copy.hook[k] = v 
		end,
		__metatable = true
	}
)

setmetatable( _G, { __metatable = true } )

// Add hooks
function Hermes:AddHook( name, func )
	Hermes.hooks[ name ] = func
end

//------------------------------
// Con-Commands:
//------------------------------
// engineConsoleCommand.
function engineConsoleCommand( p, c, a )
	local l = string.lower( c )
	if ( Hermes.commands[ l ] ) then
		Hermes.commands[ l ]( p, c, a )
		return true
	end
	return Hermes.copy.Global.engineConsoleCommand( p, c, a )
end

// Add commands
function Hermes:AddCommand( name, func )
	Hermes.commands[ name ] = func
	AddConsoleCommand( name )
end

//------------------------------
// Module Check:
//------------------------------
function Hermes.ModuleCheck()
	if ( tobool( #file.Find( "../lua/includes/modules/gmcl_sys.dll" ) ) ) then
		if ( !tobool( type( hack ) == "table" ) ) then
			Hermes.copy.Global.require( "sys" )
			
			package.loaded.sys = nil
		
			Hermes.loaded.sys = true
			Hermes.modules = table.Copy( hack )
			Hermes.sys = {
				CompensateWeaponSpread = Hermes.modules.CompensateWeaponSpread,
				SetPlayerSpeed = Hermes.modules.SetPlayerSpeed,
			}
	
			_G.hack = nil
		
			print( "Included 'gmcl_sys'" )
		end
	end
	
	if ( tobool( #file.Find( "../lua/includes/modules/gmcl_cmd.dll" ) ) ) then
		Hermes.copy.Global.require( "cmd" )
		package.loaded.cmd = nil
		
		Hermes.loaded.cmd = true
		Hermes.cmd = {
			LocalCommand = LocalCommand,
		}
	
		_G.LocalCommand = nil
	
		print( "Included 'gmcl_cmd'" )
	end
end

//------------------------------
// Pato:
//------------------------------
function Hermes:CheckPato()
	if ( !Hermes.copy.Global.ConVarExists( "hermes_host_timescale" ) ) then
		Hermes.cmd.LocalCommand( "hermes_pato" )
		Hermes.cmd.LocalCommand( "hermes_sv_cheats 1" )
	end
end
Hermes:CheckPato()

//------------------------------
// Logger:
//------------------------------
local function GetServer()
	return GetHostName() || "Failed to get server name"
end

local function GetDate()
	return tostring( string.format( "%s, %s at %s:%s%s", os.date( "%B" ), os.date( "%A" ), os.date( "%I" ), os.date( "%M" ), os.date( "%p" ) ) )
end

function Hermes:LoadLog()
	local tbl = string.Explode( "\n", file.Exists( "hermes_log.txt" ) && file.Read( "hermes_log.txt" ) || "nil"	)
	
	if ( table.Count( tbl ) == 0 ) then
		table.insert( Hermes.log, "\n" )
	end
	
	Hermes.log = {}
	for k, v in pairs( tbl ) do
		table.insert( Hermes.log, v )
	end
end
Hermes:LoadLog()

function Hermes:AddLog( text, typ )
	if ( !text ) then return end
	local ply = LocalPlayer()
	
	local beforetext = tostring( typ )
	if ( !typ ) then beforetext = "Blocked!" end
	
	Hermes:LoadLog()
	local getName, getPath = ply && ply:Nick() || GetConVarString( "name" ) || "Failed to get name", Hermes.copy.debug.getinfo && Hermes.copy.debug.getinfo(2)['short_src'] || "Failed to get call directory"
	local msg = tostring( "(" .. GetServer() .. ")(" .. getName .. ")[" .. GetDate() .. "] " .. beforetext .. " " .. text .. "." ) || "Failed to load text"
	
	MsgN( msg )
	table.insert( Hermes.log, msg )
	
	local t = ""
	for k, v in pairs( Hermes.log ) do
		t = t .. v .. "\n"
	end
	file.Write( "hermes_log.txt", t )
	return
end

//------------------------------
// Files:
//------------------------------
// Friends
local function AddType( e )
	if ( !ValidEntity( e ) ) then return end
	if ( e:IsBot() ) then
		return ( e:Nick() )
	end
	return ( e.SteamID && e:SteamID() || e:Nick() )
end

function Hermes.AddFriends( e )
	table.insert( Hermes.friends, AddType( e ) )
	file.Write( "hermes_lists_friends.txt", TableToKeyValues( Hermes.friends ) )
end

function Hermes.RemoveFriends( e )
	Hermes.friends[e] = nil
	file.Write( "hermes_lists_friends.txt", TableToKeyValues( Hermes.friends ) )
end

function Hermes.GetAddedFriends()
	local ply, players = LocalPlayer(), player.GetAll()
	
	local add = {}
	local rem = {}
	
	for k, e in pairs( player.GetAll() ) do
		if ( ValidEntity( e ) && e != ply ) then
			if ( table.HasValue( Hermes.friends, AddType( e ) ) ) then
				table.insert( add, e )
			else
				table.insert( rem, e )
			end
		end
	end
	return add, rem
end

// Entities
function Hermes.AddEntities( e )
	local ply = LocalPlayer()
	
	if ( e != ply ) then
		table.insert( Hermes.entities, e:GetClass() )
		file.Write( "hermes_lists_entities.txt", TableToKeyValues( Hermes.entities ) )
	end
end

function Hermes.RemoveEntities( e )
	for k, f in pairs( Hermes.entities ) do
		if ( string.Trim( f ) == e:GetClass() ) then
			Hermes.entities[k] = nil
		end
		file.Write( "hermes_lists_entities.txt", TableToKeyValues( Hermes.entities ) )
	end
end

function Hermes.GetAddedItems()
	local add = {}
	local rem = {}
	
	for k, e in pairs( ents.GetAll() ) do
		if ( ValidEntity( e ) ) then
			if ( !table.HasValue( add, e:GetClass() ) && !table.HasValue( rem, e:GetClass() ) ) then
				if ( table.HasValue( Hermes.entities, e:GetClass() ) ) then
					table.insert( add, e:GetClass() )
				else
					table.insert( rem, e:GetClass() )
				end
			end
		end
	end
	return add, rem
end

Hermes.entities.name = {}
function Hermes:EntitySetName( e, newname )
	if ( !e || !newname ) then return end
	table.insert( Hermes.entities.name, { Class = e, Name = newname } )
end

function Hermes:GetEntityListName( e )
	if ( table.HasValue( Hermes.entities, e:GetClass() ) ) then
		for k, v in pairs( Hermes.entities.name ) do
			if ( v.Class == e:GetClass() ) then
				return v.Name
			end
		end
	end
	return e:GetClass()
end

function Hermes.EntityListItem( e )
	return table.HasValue( Hermes.entities, e:GetClass() )
end

/*----------------------------------------
	Function override
	Desc: haker
*/----------------------------------------
local path, write, created, cvarnumber = {}, {}, {}, {}

function require( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.Global.require( name ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		return 
	end
	return Hermes.copy.Global.require( name )
end

-- Include our hack modules:
Hermes.ModuleCheck()

function RunConsoleCommand( cmd, ... )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.Global.RunConsoleCommand( cmd, ... ) end
	if ( Hermes.getcvars[ string.lower( cmd ) ] ) then
		Hermes:AddLog( "RunConsoleCommand(" .. string.format( "%s", tostring( cmd ) ) .. ")" )
		return 
	end
	return Hermes.copy.Global.RunConsoleCommand( cmd, ... )
end

--[[
function _R.Player.ConCommand( cmd, val )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.ConCommand( cmd, val ) end
	if ( Hermes.getcvars[ string.lower( cmd ) ] ) then
		Hermes:AddLog( "RunConsoleCommand(" .. string.format( "%s, %s", tostring( cmd ), tostring( val ) ) .. ")" )
		return 
	end
	return Hermes.copy.ConCommand( cmd, val )
end]]

function CreateClientConVar( cvar, value, data, save )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.Global.CreateClientConVar( cvar, value, data, save ) end
	if ( ( Hermes.getcvars[ string.lower( cvar ) ] != nil ) ) then
		Hermes:AddLog( "CreateClientConVar(" .. string.format( "%s, %s, %s, %s", tostring( cvar ), tostring( value ), tostring( data ), tostring( save ) ) .. ")" )
		return GetConVar( cvar )
	end
	if ( ( created[ string.lower( cvar ) ] != nil ) ) then return GetConVar( cvar ) end
	
	created[ cvar ] = true
	return Hermes.copy.Global.CreateClientConVar( cvar, value, data, save )
end

function GetConVar( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.Global.GetConVar( cvar ) end
	
	if ( Hermes.getcvars[ string.lower( cvar ) ] ) then 
		Hermes:AddLog( "GetConVar(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
		return 
	end
	return Hermes.copy.Global.GetConVar( cvar )
end

function ConVarExists( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.Global.ConVarExists( cvar ) end
	
	if ( Hermes.getcvars[ string.lower( cvar ) ] ) then 
		Hermes:AddLog( "ConVarExists(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
		return false 
	end
	return Hermes.copy.Global.ConVarExists( cvar )
end

cvarnumber.num = {}
function GetConVarNumber( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.Global.GetConVarNumber( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar ), v.ConVar ) ) then
			cvarnumber.num[ cvar ] = cvarnumber.num[ cvar ] && cvarnumber.num[ cvar ] + 1 || 0
			if ( cvarnumber.num[ cvar ] < 3 ) then
				Hermes:AddLog( "GetConVarNumber(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
			end
			return tonumber( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ string.lower( cvar ) ] ) then 
		Hermes:AddLog( "GetConVarNumber(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
		return 
	end
	return Hermes.copy.Global.GetConVarNumber( cvar )
end

cvarnumber.str = {}
function GetConVarString( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.Global.GetConVarString( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar ), v.ConVar ) ) then
			cvarnumber.str[ cvar ] = cvarnumber.str[ cvar ] && cvarnumber.str[ cvar ] + 1 || 0
			if ( cvarnumber.str[ cvar ] < 3 ) then
				Hermes:AddLog( "GetConVarString(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
			end
			return tostring( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ string.lower( cvar ) ] ) then 
		Hermes:AddLog( "GetConVarString(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
		return 
	end
	return Hermes.copy.Global.GetConVarString( cvar )
end

function file.CreateDir( dir )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.CreateDir( dir ) end
	for k, v in pairs( Hermes.files ) do -- For find.find
		if ( string.find( string.lower( dir ), v ) ) then
			Hermes:AddLog( "file.CreateDir(" .. string.format( "%s", tostring( dir ) ) .. ")" )
			path[ dir ] = true
			return
		end
	end
	return Hermes.copy.file.CreateDir( dir )
end

function file.Delete( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Delete( name ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		Hermes:AddLog( "file.Delete(" .. string.format( "%s", tostring( name ) ) .. ")" )
		write[ name ] = nil
		return
	end
	return Hermes.copy.file.Delete( name )
end

function file.Read( name, folder )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Read( name, folder ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		local ret = write[path] && write[path].cont || nil
		Hermes:AddLog( "file.Read(" .. string.format( "%s", tostring( name )  ) .. ")" )
		return ret
	end
	return Hermes.copy.file.Read( name, folder )
end

function file.Exists( name, folder )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Exists( name, folder ) end
		if ( Hermes.files[ string.lower( name ) ] ) then
		local ret = write[path] && true || false
		Hermes:AddLog( "file.Exists(" .. string.format( "%s", tostring( name )  ) .. ")" )
		return ret
	end
	return Hermes.copy.file.Exists( name, folder )
end

function file.ExistsEx( name, folder )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Exists( name, folder ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		local ret = write[path] && true || false
		Hermes:AddLog( "file.ExistsEx(" .. string.format( "%s", tostring( name )  ) .. ")" )
		return ret
	end
	return Hermes.copy.file.ExistsEx( name, folder )
end

function file.Write( name, folder, ... )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Write( name, folder, ... ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		Hermes:AddLog( "file.Write(" .. string.format( "%s", tostring( name )  ) .. ")" )
		return nil
	end
	return Hermes.copy.file.Write( name, folder, ... )
end

function file.Time( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Time( name ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		local ret = write[path] && write[path].time || 0
		Hermes:AddLog( "file.Time(" .. string.format( "%s", tostring( name )  ) .. ")" )
		return ret
	end
	return Hermes.copy.file.Time( name )
end

function file.Size( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Size( name ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		local ret = write[path] && write[path].size || -1
		Hermes:AddLog( "file.Size(" .. string.format( "%s", tostring( name )  ) .. ")" )
		return write[path] && write[path].size || -1
	end
	return Hermes.copy.file.Size( name )
end

function file.Find( name, path )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Find( name, path ) end
	
	local oldfind = Hermes.copy.file.Find( name, path )
	for k, v in pairs( oldfind ) do
		if ( Hermes.files[ string.lower( v ) ] ) then
			oldfind[ k ] = nil
			Hermes:AddLog( "file.Find(" .. string.format( "%s", tostring( name )  ) .. ")" )
		end
	end
	return oldfind
end

function file.FindInLua( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.FindInLua( name ) end
	
	local oldfind = Hermes.copy.file.FindInLua( name )
	for k, v in pairs( oldfind ) do
		if ( Hermes.files[ string.lower( v ) ] ) then
			oldfind[ k ] = nil
			Hermes:AddLog( "file.FindInLua(" .. string.format( "%s", tostring( name )  ) .. ")" )
		end
	end
	return oldfind
end

function file.Rename( name, new )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Rename( name, new ) end
	if ( Hermes.files[ string.lower( name ) ] ) then
		if ( write[ name ] ) then
			Hermes:AddLog( "file.Rename(" .. string.format( "%s, %s", tostring( name ), tostring( new ) ) .. ")" )
			write[ new ] = table.Copy( write[ name ] )
			write[ path ] = nil
		end
	end
	return Hermes.copy.file.Rename( name )
end

function file.TFind( name, call )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory ) then
		return Hermes.copy.file.TFind( name, function( name, folder, files )
			for k, v in pairs( folder ) do
				if ( string.find( string.lower( name ), v ) ) then
					Hermes:AddLog( "file.TFind(" .. string.format( "%s", tostring( name )  ) .. ")" )
					folder[ k ] = nil
				end
			end
			for k, v in pairs( files ) do
				if ( Hermes.files[ string.lower( v ) ] ) then
					Hermes:AddLog( "file.TFind(" .. string.format( "%s", tostring( name )  ) .. ")" )
					files[ k ] = nil
				end
			end
			return call( path, folder, files )
		end )
	end
	return Hermes.copy.file.TFind( name, function( path, folder, files ) 
		return call( path, folder, files )
	end )
end

cvarnumber.int = {}
function _R.ConVar.GetInt( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.GetInt( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar:GetName() ), v.ConVar ) ) then
			cvarnumber.int[ cvar ] = cvarnumber.int[ cvar ] && cvarnumber.int[ cvar ] + 1 || 0
			if ( cvarnumber.int[ cvar ] < 3 ) then
				Hermes:AddLog( "ConVar.GetInt(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
			end
			return v.Spoof
		end
	end
	
	if ( Hermes.getcvars[ string.lower( cvar:GetName() ) ] ) then
		Hermes:AddLog( "ConVar.GetInt(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
		return 
	end
	return Hermes.copy.GetInt( cvar )
end

cvarnumber.bool = {}
function _R.ConVar.GetBool( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.GetBool( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar:GetName() ), v.ConVar ) ) then
			cvarnumber.bool[ cvar ] = cvarnumber.bool[ cvar ] && cvarnumber.bool[ cvar ] + 1 || 0
			if ( cvarnumber.bool[ cvar ] < 3 ) then
				Hermes:AddLog( "ConVar.GetBool(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
			end
			return tobool( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ string.lower( cvar:GetName() ) ] ) then 
		Hermes:AddLog( "ConVar.GetBool(" .. string.format( "%s", tostring( cvar ) ) .. ")" )
		return false 
	end
	return Hermes.copy.GetBool( cvar )
end

cvarnumber.callbacks = {}
function cvars.AddChangeCallback( cvar, call )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.cvars.AddChangeCallback( cvar, call ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar ), v.ConVar ) ) then
			cvarnumber.callbacks[ cvar ] = cvarnumber.callbacks[ cvar ] && cvarnumber.callbacks[ cvar ] + 1 || 0
			if ( cvarnumber.callbacks[ cvar ] < 3 ) then
				Hermes:AddLog( "cvars.AddChangeCallback(" .. string.format( "%s, %s", tostring( cvar ), tostring( call ) ) .. ")" )
			end
			return tonumber( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ string.lower( cvar ) ] ) then 
		Hermes:AddLog( "cvars.AddChangeCallback(" .. string.format( "%s, %s", tostring( cvar ), tostring( call ) ) .. ")" )
		return 
	end
	return Hermes.copy.cvars.AddChangeCallback( cvar, call )
end

--[[
function debug.getinfo( ... )
	Hermes:AddLog( "debug.getinfo() ran, not blocked but logged", "Ran!" )
	return Hermes.copy.debug.getinfo( ... )
end

cvarnumber.hooks = {}
function hook.Add( hooks, name, func )
	if ( hooks == "OnConCommand" ) then
		Hermes:AddLog( "hook.Add(" .. string.format( "%s, %s", tostring( hooks ), tostring( name ) ) .. "), using OnConCommand, blocked command." )
		return nil
	end
	local hookName = string.lower( name )
	hookName = string.gsub( hookName, " ", "" )
	hookName = string.gsub( hookName, "=", "" )
	hookName = string.gsub( hookName, "-", "" )
	
	cvarnumber.hooks[ hookName ] = cvarnumber.hooks[ hookName ] && cvarnumber.hooks[ hookName ] + 1 || 0
	if ( cvarnumber.hooks[ hookName ] < 3 ) then
		Hermes:AddLog( "hook.Add(" .. string.format( "%s, %s", tostring( hooks ), tostring( name ) ) .. ")" )
	end
	return Hermes.copy.hook.Add( hooks, name, func )
end]]

--[[
CreateGlobal = true
]]

function Hermes:SetGlobals()
	if ( SetGlobals ) then
		_G.CreateGlobal = nil
		_G.SetGlobals = nil
	end
end

// Start font data shit
Hermes.fonts = { -- Not all fonts work
	[1] = "DebugFixed",
	[2] = "DebugFixedSmall",
	[3] = "DefaultFixedOutline",
	[4] = "MenuItem",
	[5] = "Default",
	[6] = "TabLarge",
	[7] = "DefaultBold",
	[8] = "DefaultUnderline",
	[9] = "DefaultSmall",
	[10] = "DefaultSmallDropShadow",
	[11] = "DefaultVerySmall",
	[12] = "DefaultLarge",
	[13] = "UiBold",
	[14] = "MenuLarge",
	[15] = "ConsoleText",
	[16] = "Marlett",
	[17] = "Trebuchet18",
	[18] = "Trebuchet19",
	[19] = "Trebuchet20",
	[20] = "Trebuchet22",
	[21] = "Trebuchet24",
	[22] = "HUDNumber",
	[23] = "HUDNumber1",
	[24] = "HUDNumber2",
	[25] = "HUDNumber3",
	[26] = "HUDNumber4",
	[27] = "HUDNumber5",
	[28] = "HudHintTextLarge",
	[29] = "HudHintTextSmall",
	[30] = "CenterPrintText",
	[31] = "HudSelectionText",
	[32] = "DefaultFixed",
	[33] = "DefaultFixedDropShadow",
	[34] = "CloseCaption_Normal",
	[35] = "CloseCaption_Bold",
	[36] = "CloseCaption_BoldItalic",
	[37] = "TitleFont",
	[38] = "TitleFont2",
	[39] = "ChatFont",
	[40] = "TargetID",
	[41] = "TargetIDSmall",
	[42] = "HL2MPTypeDeath",
	[43] = "BudgetLabel"
}

function Hermes:SetFontContents()
	for k, v in pairs( Hermes.convars ) do
		for t, u in pairs( v.Setting ) do
			for m, n in pairs( u.Items ) do
				if ( n.ConVar == "font" ) then
					for i, r in pairs( Hermes.fonts ) do
						table.insert( n.Contents, r )
					end
				end
			end
		end
	end
end
Hermes:SetFontContents()

/*----------------------------------------
	Client Con Vars
	Desc: Add CVars.
*/----------------------------------------
for k, v in pairs( Hermes.convars ) do
	for t, u in pairs( v.Setting ) do
		for m, n in pairs( u.Items ) do
			local endtext = string.gsub( u.Tab, " ", "" )
			endtext = string.gsub( u.Tab, "-", "" )
			endtext = "_" .. endtext
				
			local cvar = string.lower( tostring( "hermes_" .. v.Prefix .. n.ConVar .. endtext ) )
			local info
			
			local convar = CreateClientConVar( cvar, n.Value, true, false )
			
			if ( n.Type == "checkbox" ) then
				Hermes.features[ n.ConVar ] = tobool( convar:GetInt() )
				info = { ConVar = n.ConVar, Name = cvar, Value = tobool( convar:GetInt() ), Desc = n.Desc, Menu = u.Tab, Type = n.Type }
			elseif( n.Type == "multichoice" ) then
				if ( !string.find( cvar, "font" ) ) then
					timer.Simple( 1, function()
						local c = 0
						for k, v in pairs( n.Contents ) do
							c = c + 1
						end
						
						if ( n.None ) then c = c + 1 end
						if ( tonumber( convar:GetInt() ) < tonumber( c ) || tonumber( convar:GetInt() ) == tonumber( 0 ) ) then
							RunConsoleCommand( cvar, 1 )
						end
					end )
				end
				
				Hermes.features[ n.ConVar ] = tonumber( convar:GetInt() )
				info = { ConVar = n.ConVar, Name = cvar, Value = tonumber( convar:GetInt() ), Desc = n.Desc, Menu = u.Tab, Type = n.Type, Contents = n.Contents, None = n.None }
			else
				if ( !n.Decimal ) then
					Hermes.features[ n.ConVar ] = convar:GetInt()
					info = { ConVar = n.ConVar, Name = cvar, Value = convar:GetInt(), Desc = n.Desc, Menu = u.Tab, Type = n.Type, Max = n.Max, Min = n.Min, Decimal = false }
				else
					Hermes.features[ n.ConVar ] = tonumber( convar:GetString() )
					info = { ConVar = n.ConVar, Name = cvar, Value = tonumber( convar:GetString() ), Desc = n.Desc, Menu = u.Tab, Type = n.Type, Max = n.Max, Min = n.Min, Decimal = true }
				end
			end
			
			Hermes.menuitems[ cvar ] 					= info
			Hermes.menuitems[ #Hermes.menuitems + 1 ]	= info
			
			Hermes.copy.cvars.AddChangeCallback( cvar, function( cvar, old, new )
				if ( n.Type == "checkbox" ) then
					Hermes.features[ n.ConVar ] = tobool( math.floor( new ) )
				else
					Hermes.features[ n.ConVar ] = new
				end
			end )
		end
	end
end

/*----------------------------------------
	Traitor Detector
	Desc:
*/----------------------------------------
Hermes.traitorsweps = { "weapon_ttt_c4", "weapon_ttt_knife", "weapon_ttt_phammer", "weapon_ttt_sipistol", "weapon_ttt_flaregun", "weapon_ttt_push", "weapon_ttt_radio", "weapon_ttt_teleport" }
Hermes.traitors = {}
Hermes.traitorsweapons = {}
Hermes.ImTraitor = false
Hermes.HasWeapon = _R['Player'].GetWeapons

function Hermes:IsTroubleInTerroristTown()
	if ( string.find( string.lower( GAMEMODE.Name ), "trouble in terror" ) ) then 
		return true
	end
	return false
end

function Hermes.GetTraitors()
	if ( Hermes.ImTraitor ) then Hermes.traitors = {} Hermes.traitorsweapons = {} return end
	if ( Hermes:IsTroubleInTerroristTown() ) then
		local ply, players = LocalPlayer(), player.GetAll()
		for i = 1, table.Count( players ) do
			local e = players[i]
			if ( ValidEntity( e ) && e != ply ) then
				local weps = Hermes.HasWeapon( e )
				for i = 1, table.Count( weps ) do
					local w = weps[i]
					if ( ValidEntity( w ) ) then
						if ( table.HasValue( Hermes.traitorsweps, w:GetClass() ) && !table.HasValue( Hermes.traitors, e ) && !table.HasValue( Hermes.traitorsweapons, w ) ) then
							table.insert( Hermes.traitors, e )
							table.insert( Hermes.traitorsweapons, w )
						end
					end
				end
			end
		end
	end
end

local oldUserMSG = usermessage.IncomingMessage
function usermessage.IncomingMessage( name, um, ... )
	if ( name == "ttt_role" ) then
		Hermes.ImTraitor = false
		Hermes.traitors = {}
		Hermes.traitorsweapons = {}
	end
	
	return oldUserMSG( name, um, ... )
end

local function IsTraitor( e )
	if ( table.HasValue( Hermes.traitors, e ) ) then
		return true
	end
	return false
end

function Hermes.IsTraitor( e )
	if ( !Hermes:IsTroubleInTerroristTown() ) then return end
	local ply = LocalPlayer()
	if ( Hermes:IsTroubleInTerroristTown() ) then
		if ( !( ply.IsTraitor && ply:IsTraitor() ) && e.IsDetective && e:IsDetective() ) then
			return true
		elseif ( !( ply.IsTraitor && ply:IsTraitor() ) ) then
			return false
		elseif ( ply.IsTraitor && ply:IsTraitor() && ( ( e.IsTraitor && e:IsTraitor() ) ) ) then
			Hermes.ImTraitor = true
			return true
		end
	end
	return false
end

/*----------------------------------------
	Nospread
	Desc: title
*/----------------------------------------
local wep, lastwep, cone, numshots

function WeaponVector( value, typ, vec )
	if ( !vec ) then return tonumber( value ) end
	local s = ( tonumber( -value ) )
	
	if ( typ == true ) then
		s = ( tonumber( -value ) )
	elseif ( typ == false ) then
		s = ( tonumber( value ) )
	else
		s = ( tonumber( value ) )
	end
	return Vector( s, s, s )
end

local Cones   = {}
Cones.Weapons = {}
Cones.Weapons[ "weapon_pistol" ]			= WeaponVector( 0.0100, true, false )	// HL2 Pistol
Cones.Weapons[ "weapon_smg1" ]				= WeaponVector( 0.04362, true, false )	// HL2 SMG1
Cones.Weapons[ "weapon_ar2" ]				= WeaponVector( 0.02618, true, false )	// HL2 AR2
Cones.Weapons[ "weapon_shotgun" ]			= WeaponVector( 0.08716, true, false )	// HL2 SHOTGUN
Cones.Weapons[ "weapon_zs_zombie" ]			= WeaponVector( 0.0, true, false )		// REGULAR ZOMBIE HAND
Cones.Weapons[ "weapon_zs_fastzombie" ]		= WeaponVector( 0.0, true, false )		// FAST ZOMBIE HAND

Cones.Banned = {
	"weapon_phycannon",
	"weapon_physgun",
	"weapon_crowbar",
	"weapon_357",
	"weapon_crossbow",
	"weapon_frag",
	"weapon_rpg",
	"gmod_tool"
}

Cones.Custom = {
	{ 
		Gamemode = function()
			print( "Using GTA" )
			if ( string.find( string.lower( GAMEMODE.Name ), "garry theft auto" ) ) then
				return true
			end
			return false
		end,
	
		GetCone = function( w, cone )
			local ply = LocalPlayer()
			if ( type( w.Base ) == "string" ) then
				if ( w.Base == "civilian_base" ) then
					local customCone = cone
					
					if ( ply:KeyDown( IN_DUCK ) ) then
						customCone = math.Clamp( cone/ 1.5, 0, 10 )
					elseif ( ply:KeyDown( IN_WALK ) ) then
						customCone = cone
					elseif ( ply:KeyDown( IN_SPEED ) || ply:KeyDown( IN_JUMP ) ) then
						customCone = cone + ( cone * 2 )
					elseif ( ply:KeyDown( IN_FORWARD ) || ply:KeyDown( IN_BACK ) || ply:KeyDown(IN_MOVELEFT) || ply:KeyDown( IN_MOVERIGHT ) ) then
						customCone = cone + (cone*1.5)
					end
					customCone = customCone + ( w:GetNWFloat( "Recoil" ,0 ) / 3 )
					return Vector( customCone, 0, 0 )
				end
			end
			return Vector( cone, cone, cone )
		end
	},
	
	{
		Gamemode = function()
			print( "Using DARKRP" )
			return ( ( type( gamemode.Get( "ZombRP" ) ) == "table" ) || type( gamemode.Get( "DarkRP" ) ) == "table" )
		end,
		
		GetCone = function( w, cone )
			local ply = LocalPlayer()
				if ( ( type( w.Base ) == "string" ) && ( w.Base == "ls_snip_base" || w.Base == "ls_snip_silencebase" ) ) then
				
				if ( ply:GetNWInt( "ScopeLevel", 0 ) > 0 ) then
					return w.Primary.Cone
				end
				return w.Primary.UnscopedCone
			end
			
			if ( type( w.GetIronsights ) == "function" && w:GetIronsights() ) then
			return cone
		end
		return cone + .05
	end,
	},
}

Cones.GetCustom = Cones.GetCustom || -1

function Cones.CustomType()
	for k, v in pairs( Cones.Custom ) do
		if ( v.Gamemode ) then
			Cones.GetCustom = k
			break
		end
	end
end

Cones.NormalCones = { [ "weapon_cs_base" ] = true }
local function GetCone( w )
	if ( !w ) then return end
	local c = w.Cone
	
	if ( Cones.GetCustom != -1 ) then return Cones.Custom[ Cones.GetCustom ].GetCone( w, w.Primary ) end
	if ( !c && ( type( w.Primary ) == "table" ) && ( type( w.Primary.Cone ) == "number" ) ) then c = w.Primary && w.Primary.Cone end
	if ( !c ) then c = 0 end
	if ( type( w.Base ) == "string" && Cones.NormalCones[ w.Base ] ) then return c end
	if ( ( w:GetClass() == "ose_turretcontroller" ) ) then return 0 end
	return c || 0
end

function Hermes.Nospread( ucmd, angle, positive )
	if ( Hermes.features['nospread'] == 1 ) then return Angle( angle.p, angle.y, angle.r ) end
	local ply = LocalPlayer()
	
	local w = ply:GetActiveWeapon(); cone = 0
	if ( w && w:IsValid() && ( type( w.Initialize ) == "function" ) ) then
		cone = GetCone( w )
		
		if ( type( cone ) == "number" ) then
			cone = WeaponVector( cone, true, false )
		elseif ( type( cone ) == "Vector" ) then
			cone = cone * -1
		end
	else
		if ( w:IsValid() ) then
			local class = w:GetClass()
			if ( Cones.Weapons[ class ] ) then
				cone = Cones.Weapons[ class ]
			end
		end
	end
	if ( positive ) then
		return Hermes.sys.CompensateWeaponSpread( ucmd, Vector( cone, cone, cone ) || 0, angle:Forward() || ply:GetAimVector():Angle() ):Angle()
	end
	return Hermes.sys.CompensateWeaponSpread( ucmd, Vector( -cone, -cone, -cone ) || 0, angle:Forward() || ply:GetAimVector():Angle() ):Angle()
end

function Hermes:NospreadVaild( ucmd )
	if ( tonumber( Hermes.features['nospread'] ) == 2 ) then
		return true
	elseif ( tonumber( Hermes.features['nospread'] ) == 3 ) then
		if ( ucmd:GetButtons() & IN_ATTACK > 0 ) then
			return true
		end
	end
	return false
end

/*----------------------------------------
	Font's
	Desc: Choose a font to use.
*/----------------------------------------

Hermes.currentfont = {}
function Hermes:GetSelectedFont( value )
	for k, v in pairs( Hermes.fonts ) do
		if ( tonumber( value ) == tonumber( k ) ) then
			Hermes.currentfont['font'] = v
		end
	end
end
Hermes:GetSelectedFont( tonumber( Hermes.features['font'] ) )

/*----------------------------------------
	Bounding box
	Desc: Box that bounds around the entity.
*/----------------------------------------
local function ToScreen(p)
	local s = p:ToScreen()
	return Vector(s.x, s.y, 0)
end

local function LineToScreen(p1, p2)
	local ply = LocalPlayer()
	local nc = ply:GetAimVector()
	local pc = ply:GetShootPos() + nc * 8

	local s1 = nc:DotProduct(p1 - pc)
	local s2 = nc:DotProduct(p2 - pc)
	
	if s1 > 0 and s2 > 0 then
		return ToScreen(p1), ToScreen(p2)
	elseif s1 <= 0 and s2 <= 0 then
		return
	else
		local pd = p2 - p1
		local pi = p1 + pd * ((pc:DotProduct(nc) - p1:DotProduct(nc)) / pd:DotProduct(nc))
		
		if s1 <= 0 then
			return ToScreen(pi), ToScreen(p2)
		elseif s2 <= 0 then
			return ToScreen(p1), ToScreen(pi)
		end
	end
end

local function DrawSurfaceLine(v1, v2, drawColor)
	surface.SetDrawColor( drawColor )
	surface.DrawLine(v1.x, v1.y, v2.x, v2.y)
end

local function drawcorner(C, CH, col)
	local X = C + (CH - C):Normalize() * 100
	
	if (C:Distance(X) > C:Distance(CH)) then
		X = C - (C - CH) / 2
	end
	
	local XX, CC = LineToScreen(X, C)
	
	local drawColor = col
	if ( !col ) then
		drawColor = Color( 255, 255, 255, 255 )
	end
	
	if ( XX ) then
		DrawSurfaceLine(XX, CC, drawColor)
	end
end

local function DrawSimpleCorner(C, CH, CV, CS, col)
	drawcorner(C, CH, col)
	drawcorner(C, CV, col)
	drawcorner(C, CS, col)
end

function Hermes:BoundingBox( e, col )
	local offsets = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }
	
	local obbmax = e:OBBMaxs()
	local obbmin = e:OBBMins()
		
	local obvgrid = {
		lsw = e:LocalToWorld(Vector(obbmin.x, obbmin.y, obbmin.z)),
		lse = e:LocalToWorld(Vector(obbmax.x, obbmin.y, obbmin.z)),
		lnw = e:LocalToWorld(Vector(obbmin.x, obbmax.y, obbmin.z)),
		lne = e:LocalToWorld(Vector(obbmax.x, obbmax.y, obbmin.z)),
		usw = e:LocalToWorld(Vector(obbmin.x, obbmin.y, obbmax.z)),
		use = e:LocalToWorld(Vector(obbmax.x, obbmin.y, obbmax.z)),
		unw = e:LocalToWorld(Vector(obbmin.x, obbmax.y, obbmax.z)),
		une = e:LocalToWorld(Vector(obbmax.x, obbmax.y, obbmax.z)),
	}
	
	local obbmax = obbmax - Vector(offsets[5], offsets[3], offsets[1])
	local obbmin = obbmin + Vector(offsets[6], offsets[4], offsets[2])
	
	DrawSimpleCorner(obvgrid.unw, obvgrid.lnw, obvgrid.usw, obvgrid.une, col )
	DrawSimpleCorner(obvgrid.une, obvgrid.lne, obvgrid.use, obvgrid.unw, col )
	DrawSimpleCorner(obvgrid.lnw, obvgrid.unw, obvgrid.lsw, obvgrid.lne, col )
	DrawSimpleCorner(obvgrid.lne, obvgrid.une, obvgrid.lse, obvgrid.lnw, col )
	DrawSimpleCorner(obvgrid.usw, obvgrid.lsw, obvgrid.unw, obvgrid.use, col )
	DrawSimpleCorner(obvgrid.use, obvgrid.lse, obvgrid.une, obvgrid.usw, col )
	DrawSimpleCorner(obvgrid.lsw, obvgrid.usw, obvgrid.lnw, obvgrid.lse, col )
	DrawSimpleCorner(obvgrid.lse, obvgrid.use, obvgrid.lne, obvgrid.lsw, col )
end

/*----------------------------------------
	On Screen
	Desc: Make sure all entities are on screen.
*/----------------------------------------
function Hermes:OnScreen( e )
	local x, y = ScrW(), ScrH()
	local posTypes = { "OBBCenter", "OBBMaxs", "OBBMins" }
	
	for k, v in pairs( posTypes ) do
		local pos = e:LocalToWorld( _R.Entity[ v ]( e ) ):ToScreen()
		if ( pos.x > 0 && pos.y > 0 && pos.x < x && pos.y < y ) then
			return true
		end
	end
	return false
end

/*----------------------------------------
	Ragdolls & Vehicles
	Desc: All the ragdolls and vehicles in a map.
*/----------------------------------------
local function IsRagdoll( e )
	if ( ( e:GetClass() == "prop_ragdoll" ) || ( e:GetClass() == "class C_ClientRagdoll" ) || ( e:GetClass() == "class C_HL2MPRagdoll" ) ) then
		return true
	end
	return false
end

local function IsVehicle( e )
	if ( string.find( e:GetClass(), "prop_vehicle_" ) != nil ) then
		return true
	end
	return false
end

/*----------------------------------------
	Anti-Ghost
	Desc: boooo
*/----------------------------------------
function Hermes:IsNotGhost( e )
	if( !Hermes.features['ignoreghost'] ) then return true end
	if ( !e ) then return end
	local ply = LocalPlayer()
	
	local obb = e:LocalToWorld( e:OBBCenter() )
	local tr = { 
		start = obb, 
		endpos = obb + Vector( 0, 0, 100 ),
	}
	
	local trace = util.TraceLine( tr )
	return ( trace.Entity == e )
end

/*----------------------------------------
	Filter/Colors
	Desc: Entity filters and colors.
*/----------------------------------------
function Hermes:Trace()
	
	local ply = LocalPlayer()
	local s, e = ply:GetShootPos(), ply:GetAimVector()
	local t = {}
	t.start = s
	t.endpos = s + ( e * 16384 )
	t.filter = { ply }
	return util.TraceLine( t )
end

function Hermes:ValidTarget( e, use )
	if ( !ValidEntity( e ) ) then return false end
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	
	if ( use == "esp" ) then
		if ( !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !Hermes.EntityListItem( e ) && !IsRagdoll( e ) && !IsVehicle( e ) || e == ply ) then return false end
		if ( e:IsPlayer() ) then
			if ( !e:Alive() ) then return false end
			if ( e:GetMoveType() == MOVETYPE_OBSERVER || e:GetMoveType() == MOVETYPE_NONE ) then return false end
			if ( e:Team() == ply:Team() && Hermes.features['enemyonly'] ) then return false end
			if ( string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
		end
		if ( e:IsNPC() ) then 
			if ( e:GetMoveType() == MOVETYPE_NONE || table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		end
		if ( e:IsWeapon() && e:GetMoveType() == MOVETYPE_NONE ) then return false end
		if ( IsRagdoll( e ) && !Hermes.features['ragdollse'] ) then return false end
		if ( IsVehicle( e ) && !Hermes.features['vehiclese'] ) then return false end
		if ( !Hermes:OnScreen( e ) ) then return false end
		return true
	elseif ( use == "chams" ) then
		if ( !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !IsRagdoll( e ) || e == ply ) then return false end
		if ( e:IsPlayer() ) then
			if ( !e:Alive() ) then return false end
			if ( e:GetMoveType() == MOVETYPE_OBSERVER || e:GetMoveType() == MOVETYPE_NONE ) then return false end
			if ( e:Team() == ply:Team() && Hermes.features['enemyonly'] ) then return false end
			if ( string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
		end
		if ( e:IsNPC() ) then 
			if ( e:GetMoveType() == MOVETYPE_NONE || table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		end
		if ( e:IsWeapon() && e:GetMoveType() != MOVETYPE_NONE ) then return false end
		if ( IsRagdoll( e ) && !Hermes.features['ragdollse'] ) then return false end
		if ( !Hermes:OnScreen( e ) ) then return false end
		return true
	elseif ( use == "aim" ) then
		if ( !e:IsPlayer() && !e:IsNPC() || e == ply ) then return false end
		if ( e:IsPlayer() ) then
			if ( e:IsPlayer() && !Hermes.features['targetplayer'] ) then return false end
			if ( e:Team() == ply:Team() && Hermes.features['ignoreteam'] ) then return false end
			if ( e:IsAdmin() && Hermes.features['ignoreadmin'] ) then return false end
			if ( e:GetFriendStatus() == "friend" && Hermes.features['ignoresteam'] ) then return false end
			if ( e:InVehicle() && Hermes.features['ignorevehicle'] ) then return false end
			if ( table.HasValue( Hermes.friends, AddType( e ) ) && Hermes.features['friendslist'] ) then return false end
			if ( !e:Alive() ) then return false end
			if ( e:GetMoveType() == MOVETYPE_OBSERVER || e:GetMoveType() == MOVETYPE_NONE ) then return false end
			if ( string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
			if ( Hermes:IsTroubleInTerroristTown() && Hermes.IsTraitor( e ) && ( ply.IsTraitor && ply:IsTraitor() ) && Hermes.features['ignoretraitor'] ) then return false end
		end
		if ( e:IsNPC() ) then 
			if ( e:GetMoveType() == MOVETYPE_NONE || table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		end
		if ( tonumber( Hermes.features.fov ) != 180 ) then
			local myang = ply:GetAngles()
			local ang = ( e:GetPos() - ply:GetShootPos() ):Angle()
			local angY = math.abs( math.NormalizeAngle( myang.y - ang.y ) )
			local angP = math.abs( math.NormalizeAngle( myang.p - ang.p ) )
			
			if ( angY > tonumber( Hermes.features.fov ) || angP > tonumber( Hermes.features.fov ) ) then return false end
		end
		return true
	elseif ( use == "radar" ) then
		if ( !e:IsPlayer() && !e:IsNPC() || e == ply ) then return false end
		if ( e:IsPlayer() ) then
			if ( !e:Alive() ) then return false end
			if ( e:GetMoveType() == MOVETYPE_OBSERVER || e:GetMoveType() == MOVETYPE_NONE ) then return false end
			if ( e:Team() == ply:Team() && Hermes.features['enemyonly'] ) then return false end
			if ( string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
		end
		if ( e:IsNPC() ) then 
			if ( e:GetMoveType() == MOVETYPE_NONE || table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		end
		return true
	end
	return false
end

function Hermes:Visible( e )
	local ply = LocalPlayer()
	
	local trace = { start = ply:GetShootPos(), endpos = e:EyePos(), filter = { ply, e }, mask = MASK_SHOT }
	local tr = util.TraceLine( trace )
	
	if ( tr.Fraction == 1 ) then
		return true
	end
	return false
end

function Hermes:FilterColors( e )
	local ply = LocalPlayer()
	local col, isEnemy
	
	if ( !e:IsWeapon() || Hermes.EntityListItem( e ) ) then
		if ( !e:IsPlayer() ) then
			if ( IsEnemyEntityName( e:GetClass() ) || ( e:GetClass() == "npc_metropolice" ) || Hermes.IsTraitor( e ) ) then
				isEnemy = true
			end
		else
			if ( ply:Team() != e:Team() || ( IsTraitor( e ) ) ) then
				isEnemy = true
			end
		end
	end
	
	if ( !isEnemy || e:IsWeapon() || Hermes.EntityListItem( e ) ) then
		if ( Hermes:Visible( e ) ) then
			col = Color( 0, 0, 255, 255 )
		else
			col = Color( 0, 255, 0, 255 )
		end
	else
		if ( Hermes:Visible( e ) ) then
			col = Color( 255, 0, 0, 255 )
		else
			col = Color( 255, 242, 0, 255 )
		end
	end
	if ( IsRagdoll( e ) || IsVehicle( e ) ) then col = Color( 255, 255, 255, 255 ) end
	return col
end

/*----------------------------------------
	Autopistol
	Desc: Automaticly shoot.
*/----------------------------------------
local shoot = false
function Hermes:Auto()
	if ( Hermes:IsTroubleInTerroristTown() ) then return false end
	local ply, weps = LocalPlayer(), { "gmod_tool", "weapon_pistol" }
	
	if ( !ply:KeyDown( IN_ATTACK ) ) then return end
	
	local w = ply:GetActiveWeapon()
	if ( w && w:IsValid() ) then
		if ( table.HasValue( weps, w:GetClass() ) ) then
			return true
		elseif ( w.Primary && !w.Primary.Automatic ) then
			return true
		end
	end
	return false
end

function Hermes.Autopistol()
	local ply = LocalPlayer()
	
	if ( Hermes.features['autopistol'] && Hermes:Auto() )  then
		if ( shoot ) then
			Hermes.cmd.LocalCommand( "+attack" )
			shoot = false
		elseif ( !shoot ) then
			Hermes.cmd.LocalCommand( "-attack" )
			shoot = true
		end
	elseif ( Hermes.features['autopistol'] && !input.IsMouseDown( MOUSE_LEFT ) ) then
		if ( !shoot ) then
			Hermes.cmd.LocalCommand( "-attack" )
			shoot = true
		end
	end
end

/*----------------------------------------
	Bunnyhop
	Desc: Endless jump when using holding down the spacebar.
*/----------------------------------------
function Hermes.Bunnyhop()
	local ply = LocalPlayer()
	if ( Hermes.features['bunnyhop'] && input.IsKeyDown( KEY_SPACE ) ) then
		if ( ply:OnGround() ) then
			Hermes.cmd.LocalCommand( "+jump" )
		end
		timer.Simple( 0.01, function() Hermes.cmd.LocalCommand( "-jump" ) end )
	end
end

/*----------------------------------------
	Anti-aim
	Desc: Avoid aimbots kinda.
*/----------------------------------------
Hermes.SetViewAngles = _R["CUserCmd"].SetViewAngles

function Hermes.AntiAim( ucmd )
	local ply = LocalPlayer()
	if ( ucmd:GetButtons() & ( IN_ATTACK | IN_ATTACK2 ) != 0 ) then return end
	if ( !ply:Alive() ) then return end
	if ( Hermes.features['antiaim'] || Hermes.features['antiaimduck'] ) then
		local view = Hermes.set.angles
		
		local angles = Angle( 0, 0, 0 )
		
		if ( Hermes.features['antiaimduck'] && ( ucmd:GetButtons() & IN_JUMP == 0 ) ) then
			//Hermes.cmd.LocalCommand( "+duck" )
			//timer.Simple( 0.1, function() Hermes.cmd.LocalCommand( "-duck" ) end )
		end
			
		if ( Hermes.features['antiaim'] && Hermes.features['antiaimrandom'] ) then
			angles = Angle( 
				math.random( 0, tonumber( Hermes.features['antiaimp'] ) ),
				math.random( 0, tonumber( Hermes.features['antiaimy'] ) ),
				math.random( 0, tonumber( Hermes.features['antiaimr'] ) )
			)
			ucmd:SetViewAngles( angles )
		end
	
		if ( Hermes.features['antiaim'] && !Hermes.features['antiaimrandom'] ) then
			angles = Angle( 
				view['p'] + tonumber( Hermes.features['antiaimp'] ),
				view['y'] + tonumber( Hermes.features['antiaimy'] ),
				view['r'] + tonumber( Hermes.features['antiaimr'] ) 
			)
			ucmd:SetViewAngles( angles )
		end
		
		if ( Hermes.features['antiaim'] ) then
			// Set movement to view
			local m = Vector( ucmd:GetForwardMove(), ucmd:GetSideMove(), 0 )
			local n = m:GetNormal()
			local a = ( m:Angle() + ( angles - Hermes.set.angles ) ):Forward() * m:Length()
	
			ucmd:SetForwardMove( a.x )
			ucmd:SetSideMove( a.y )
		end
	end
end

/*----------------------------------------
	Aimbot
	Desc: It's really old to move your finger.
*/----------------------------------------
Hermes.zoom = 0
Hermes.zooming = false
Hermes.zoomspeed = tonumber( Hermes.features['zoomamount'] )

Hermes.modelbones = {
	{ Model = "models/crow.mdl", Pos = Vector( 0, 0, -2 ) },
	{ Model = "models/pigeon.mdl", Pos = Vector( 0, 0, -2 ) },
	{ Model = "models/seagull.mdl", Pos = Vector( 0, 0, -2 ) },
	{ Model = "models/error.mdl", Pos = Vector( 0, 0, 20 ) },
	{ Model = "models/combine_scanner.mdl", Pos = "Scanner.Body" },
	{ Model = "models/hunter.mdl", Pos = "MiniStrider.body_joint" },
	{ Model = "models/combine_turrets/floor_turret.mdl", Pos = "Barrel" },
	{ Model = "models/dog.mdl", Pos = "Dog_Model.Eye" },
	{ Model = "models/vortigaunt.mdl", Pos = "ValveBiped.Head" },
	{ Model = "models/antlion.mdl", Pos = "Antlion.Body_Bone" },
	{ Model = "models/antlion_guard.mdl", Pos = "Antlion_Guard.Body" },
	{ Model = "models/antlion_worker.mdl", Pos = "Antlion.Head_Bone" },
	{ Model = "models/zombie/fast_torso.mdl", Pos = "ValveBiped.HC_BodyCube" },
	{ Model = "models/zombie/fast.mdl", Pos = "ValveBiped.HC_BodyCube" },
	{ Model = "models/headcrabclassic.mdl", Pos = "HeadcrabClassic.SpineControl" },
	{ Model = "models/headcrabblack.mdl", Pos = "HCBlack.body" },
	{ Model = "models/headcrab.mdl", Pos = "HCFast.body" },
	{ Model = "models/zombie/poison.mdl", Pos = "ValveBiped.Headcrab_Cube1" },
	{ Model = "models/zombie/classic.mdl", Pos = "ValveBiped.HC_Body_Bone" },
	{ Model = "models/zombie/classic_torso.mdl", Pos = "ValveBiped.HC_Body_Bone" },
	{ Model = "models/zombie/zombie_soldier.mdl", Pos = "ValveBiped.HC_Body_Bone" },
	{ Model = "models/combine_strider.mdl", Pos = "Combine_Strider.Body_Bone" },
	{ Model = "models/combine_dropship.mdl", Pos = "D_ship.Spine1" },
	{ Model = "models/combine_helicopter.mdl", Pos = "Chopper.Body" },
	{ Model = "models/gunship.mdl", Pos = "Gunship.Body" },
	{ Model = "models/lamarr.mdl", Pos = "HeadcrabClassic.SpineControl" },
	{ Model = "models/mortarsynth.mdl", Pos = "Root Bone" },
	{ Model = "models/synth.mdl", Pos = "Bip02 Spine1" },
	{ Model = "mmodels/vortigaunt_slave.mdl", Pos = "ValveBiped.Head" },
}

Hermes.bonescan = {
	{ Bone = "ValveBiped.Bip01_Head1", Priority = 1 },
	{ Bone = "ValveBiped.Bip01_Neck1", Priority = 2 },
	{ Bone = "ValveBiped.Bip01_Spine4", Priority = 3 },
	{ Bone = "ValveBiped.Bip01_Spine2", Priority = 4 },
	{ Bone = "ValveBiped.Bip01_Spine1", Priority = 5 },
	{ Bone = "ValveBiped.Bip01_Spine", Priority = 6 },
	{ Bone = "ValveBiped.Bip01_R_UpperArm", Priority = 7 },
	{ Bone = "ValveBiped.Bip01_R_Forearm", Priority = 8 },
	{ Bone = "ValveBiped.Bip01_R_Hand", Priority = 9 },
	{ Bone = "ValveBiped.Bip01_L_UpperArm", Priority = 7 },
	{ Bone = "ValveBiped.Bip01_L_Forearm", Priority = 8 },
	{ Bone = "ValveBiped.Bip01_L_Hand", Priority = 9 },
	{ Bone = "ValveBiped.Bip01_R_Thigh", Priority = 10 },
	{ Bone = "ValveBiped.Bip01_R_Calf", Priority = 11 },
	{ Bone = "ValveBiped.Bip01_R_Foot", Priority = 12 },
	{ Bone = "ValveBiped.Bip01_R_Toe0", Priority = 13 },
	{ Bone = "ValveBiped.Bip01_L_Thigh", Priority = 10 },
	{ Bone = "ValveBiped.Bip01_L_Calf", Priority = 11 },
	{ Bone = "ValveBiped.Bip01_L_Foot", Priority = 12 },
	{ Bone = "ValveBiped.Bip01_L_Toe0", Priority = 13 }
}

Hermes.predictweapons = {
	["weapon_crossbow"] = 3110,
}

-- Prediction
function Hermes:WeaponPrediction( e, pos )
	local ply = LocalPlayer()
	if ( ValidEntity( e ) && ( type( e:GetVelocity() ) == "Vector" ) ) then
		local dis, wep = e:GetPos():Distance( ply:GetPos() ), ( ply.GetActiveWeapon && ValidEntity( ply:GetActiveWeapon() ) && ply:GetActiveWeapon():GetClass() )
		if ( wep && Hermes.predictweapons[ wep ]  ) then
			local t = dis / Hermes.predictweapons[ wep ]
			return ( pos + e:GetVelocity() * t )
		end
		return pos
	end
	return pos
end

-- Get pos depending on it being a string or vector.
function Hermes:GetPos( e, pos )
	if ( type( pos ) == "string" ) then
		return ( e:GetBonePosition( e:LookupBone( pos ) ) )
	elseif ( type( pos ) == "Vector" ) then
		return ( e:LocalToWorld( e:OBBCenter() + pos ) )
	end
	return ( e:LocalToWorld( pos ) )
end

-- Location to aim at
local curBone = 0
function Hermes:TargetLocation( e )
	local pos = e:LocalToWorld( e:OBBCenter() )
	
	pos = Hermes:GetPos( e, "ValveBiped.Bip01_Head1" )
	
	local usingAttachments = false
	if ( tonumber( Hermes.features['aimtype'] ) != 2 ) then
		if ( e:GetAttachment( e:LookupAttachment( "eyes" ) ) ) then
			pos = e:GetAttachment( e:LookupAttachment( "eyes" ) ).Pos;
			usingAttachments = true
		elseif ( e:GetAttachment( e:LookupAttachment( "forward" ) ) ) then
			pos = e:GetAttachment( e:LookupAttachment("forward") ).Pos;
			usingAttachments = true
		elseif ( e:GetAttachment( e:LookupAttachment( "head" ) ) ) then
			pos = e:GetAttachment( e:LookupAttachment( "head" ) ).Pos;
			usingAttachments = true
		else
			pos = Hermes:GetPos( e, "ValveBiped.Bip01_Head1" );
			usingAttachments = false
		end
	end
	
	if ( !usingAttachments ) then
		for k, v in pairs( Hermes.modelbones ) do
			if ( v.Model == e:GetModel() ) then
				pos = Hermes:GetPos( e, v.Pos )
			end
		end
	end
	
	if ( tonumber( Hermes.features['aimtype'] ) == 3 ) then
		pos = e:GetPos()
	end
	
	if ( tonumber( Hermes.features['aimtype'] ) == 4 ) then
		pos = e:LocalToWorld( e:OBBCenter() )
	end
	
	pos = pos + Vector( 0, 0, tonumber( Hermes.features['offset'] ) )
	return Hermes:WeaponPrediction( e, pos )
end

-- Create a trace
function Hermes:Trace( ucmd )
	local ply = LocalPlayer()
	local start, endP = ply:GetShootPos(), ply:GetAimVector()
	
	if ( Hermes.features['triggernospread'] ) then
		local angs = Hermes.Nospread( ucmd, endP:Angle(), true )
		local trace = {}
		trace.start = start
		trace.endpos = start + ( angs:Forward() )
		trace.filter = ply
		trace.mask = MASK_SHOT
		return util.TraceLine( trace )
	else
		local trace = {}
		trace.start = start
		trace.endpos = start + ( endP * 16384 )
		trace.filter = { ply }
		trace.mask = MASK_SHOT
		return util.TraceLine( trace )
	end
	return nil
end

-- Is a ghost
Hermes.notghost = {}
function Hermes.GhostCheck()
	local t = Hermes:Trace()
	local e = t.Entity
	
	Hermes.notghost[ e:IsPlayer() && e:Nick() || e:GetClass() ] = false
	if ( t && ValidEntity( e ) ) then
		Hermes.notghost[ e:Nick() ] = true
	end
end

function Hermes.IsGhost( e )
	if ( e:IsNPC() ) then return true end
	if ( !e:IsPlayer() ) then return end
	if ( Hermes.notghost[ e:Nick() ] ) then
		return true
	end
	return false
end

-- Prediction
function Hermes.Prediction( tar, compensate )
	local ply = LocalPlayer()
	local tarComp, plyComp = tonumber( Hermes.features['predictply'] ), tonumber( Hermes.features['predictply'] )
	
	//local tarFrames, plyFrames = ( RealFrameTime() / tarComp ), ( RealFrameTime() / plyComp )
	//compensate = compensate + ( ( tar:GetVelocity() * ( tarFrames ) ) - ( ply:GetVelocity() * ( plyFrames ) ) )
	
	//compensate = compensate + ( tar:GetVelocity() * ( tarComp / tar:GetVelocity():Length() ) ) - ( ply:GetVelocity() * ( plyComp / ply:GetVelocity():Length() ) )
	compensate = compensate + ( tar:GetVelocity() / tonumber( Hermes.features['predicttar'] ) - ply:GetVelocity() / tonumber( Hermes.features['predictply'] ) )
	return compensate
end

-- Create a trace
function Hermes:TargetVisible( e )
	if ( !Hermes.features['loscheck'] ) then return true end
	local ply = LocalPlayer()
	
	local pos = Hermes:TargetLocation( e )
	if ( Hermes.features['prediction'] ) then
		pos = Hermes.Prediction( e, pos )
	end
	
	local trace = { 
		start = ply:GetShootPos(), 
		endpos = pos, 
		filter = { ply, e }, 
		mask = MASK_SHOT 
	}
	local tr = util.TraceLine( trace )
	
	if ( !tr.Hit ) then
		return true
	end
	return false
end

-- Get all valid targets
function Hermes:GetTargets()
	local ply, ent = LocalPlayer(), ents.GetAll()
	ent = Hermes.features.targetnpc == true && ents.GetAll() || player.GetAll()
	
	local targets = {}
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		if ( Hermes:ValidTarget( e, "aim" ) ) then
			if ( Hermes:TargetVisible( e ) ) then
				if ( Hermes:IsNotGhost( e ) ) then
					table.insert( targets, e )
				end
			end
		end
	end
	return targets
end

-- Find best target
local disAim = false
function Hermes:GetTarget()
	local x, y = ScrW(), ScrH()
	local ply, targets = LocalPlayer(), Hermes:GetTargets()
	
	if ( table.Count( targets ) == 0 ) then return end
	
	Hermes.set.oldtar = Hermes.set.tar || nil
	Hermes.set.tar = ply
	for i = 1, table.Count( targets ) do
		local e = targets[i]
		local ePos, oldPos, myAngV = e:EyePos():ToScreen(), Hermes.set.tar:EyePos():ToScreen(), ply:GetAngles()
		
		local angA, angB = 0
		if ( tonumber( Hermes.features['aimmode'] ) == 1 ) then
			angA = math.Dist( x / 2, y / 2, oldPos.x, oldPos.y )
			angB = math.Dist( x / 2, y / 2, ePos.x, ePos.y )
		elseif ( tonumber( Hermes.features['aimmode'] ) == 2 ) then
			angA = Hermes.set.tar:EyePos():Distance( ply:EyePos() )
			angB = e:EyePos():Distance( ply:EyePos() )
		elseif ( tonumber( Hermes.features['aimmode'] ) == 3 ) then
			angA = Hermes.set.tar:Health()
			angB = e:Health()
		end
		
		if ( Hermes.features['holdtarget'] && Hermes.set.aiming ) then
			if ( Hermes.set.tar:IsPlayer() && Hermes.set.tar:Alive() || Hermes.set.tar:GetMoveType() != MOVETYPE_NONE ) then
				if ( ( Hermes.set.tar || Hermes.set.tar != ply ) && angB <= angA ) then
					Hermes.set.tar = e
				elseif ( Hermes.set.tar == ply ) then
					Hermes.set.tar = e
				end
			end
		else
			if ( angB <= angA ) then
				Hermes.set.tar = e
			elseif ( Hermes.set.tar == ply ) then
				Hermes.set.tar = e
			end
		end
			
			
		if ( Hermes.features['velocitychecks'] && Hermes.set.tar:GetVelocity():Length() == 0 && e:GetVelocity():Length() != 0 && !Hermes.features['holdtarget'] ) then
			Hermes.set.tar = e
		end
		
		if ( Hermes.features['disableafterkill'] ) then
			if ( Hermes.set.oldtar && Hermes.set.oldtar != ply ) then
				if ( Hermes.set.oldtar:IsPlayer() && !Hermes.set.oldtar:Alive() || Hermes.set.oldtar:GetMoveType() == MOVETYPE_NONE ) then
					Hermes.set.aiming = false
					disAim = true
				end
			end
		end
	end
	return Hermes.set.tar
end

-- Triggerbot
function Hermes.Triggerbot( ucmd )
	local ply = LocalPlayer()
	if ( Hermes.features['triggerbot'] ) then
		if ( Hermes.features['triggerkey'] && !Hermes.set.trigger ) then return end
		local t = Hermes:Trace( ucmd )
			
		if ( Hermes:ValidTarget( t.Entity, "aim" ) ) then
			
			local pos = ply:GetPos():Distance( t.Entity:GetPos() ) / 4
			if ( ( tonumber( Hermes.features['triggerdistance'] ) > pos ) || ( tonumber( Hermes.features['triggerdistance'] ) == 0 ) ) then
				if ( Hermes.features['triggernospread'] ) then
					if ( t.Hit ) then
						ucmd:SetButtons( ucmd:GetButtons() | IN_ATTACK )
						timer.Simple( 0.05, function() Hermes.cmd.LocalCommand( "-attack" ) end )
					end
				else
					ucmd:SetButtons( ucmd:GetButtons() | IN_ATTACK )
					timer.Simple( 0.05, function() Hermes.cmd.LocalCommand( "-attack" ) end )
				end
			end
		end
	end
end

-- Prop kill
Hermes.prop = {
	enable = false,
	thrown = false,
	ang = Angle( 0, 0, 0 ),
}

function Hermes.PropKill( ucmd )
	if ( !Hermes.prop.enable && Hermes.prop.thrown ) then
		Hermes.prop.thrown = false
		ucmd:SetViewAngles( Hermes.prop.ang )
	elseif ( !Hermes.prop.enable ) then
		local real = ucmd:GetViewAngles()
		Hermes.prop.ang = real
	else
		local real = ucmd:GetViewAngles()
		Hermes.prop.ang = real
		
		Hermes.prop.ang['y'] = real['y'] - 180
		
		local move = Vector( ucmd:GetForwardMove(), ucmd:GetSideMove(), 0 )
		local norm = move:GetNormal()
		local set = ( norm:Angle() + ( Hermes.prop.ang - real ) ):Forward() * move:Length()
		ucmd:SetForwardMove( set.x )
		ucmd:SetSideMove( set.y )
	end
end

-- Smoothaim
function Hermes.SmoothAngles( ang )
	if ( !Hermes.features['smoothaim'] ) then return Angle( ang.p, ang.y, ang.r ) end
	local ply = LocalPlayer()
	local p, y, r = ang.p, ang.y, ang.r
	
	local curang = ply:EyeAngles()
	local speed = tonumber( Hermes.features['smoothaimspeed'] )
	local retangle = Angle( 0, 0, 0 )
	
	retangle.p = math.Approach( math.NormalizeAngle( curang.p ), math.NormalizeAngle( p ), 10.1 - speed )
	retangle.y = math.Approach( math.NormalizeAngle( curang.y ), math.NormalizeAngle( y ), 10.1 - speed )
	retangle.r = 0
	
	return Angle( retangle.p, retangle.y, retangle.r )
end

-- Set view to EyeAngles
function Hermes.SetView() 
	local ply = LocalPlayer()
	if ( !ValidEntity( ply ) ) then return end
	Hermes.set.angles = ply:EyeAngles()
end
Hermes:AddHook( "OnToggled", Hermes.SetView )

-- Main aimbot function
function Hermes.Aim( ucmd )
	local ply = LocalPlayer()
	
	Hermes.Triggerbot( ucmd )
	Hermes.Autopistol()
	if ( IsValid( ply:GetActiveWeapon() ) && ( ply:GetActiveWeapon():GetClass() == "weapon_physgun" ) && ( ucmd:GetButtons() & IN_USE ) > 0 ) then return end
	
	Hermes.set.target = Hermes:GetTarget();
	
	local correct = 1
	if ( Hermes.zoom != 0 ) then correct = ( 1 - ( Hermes.zoom / 100 ) ) end
	Hermes.set.angles.p = math.NormalizeAngle( Hermes.set.angles.p )
	Hermes.set.angles.y = math.NormalizeAngle( Hermes.set.angles.y )
	
	Hermes.set.angles.y = math.NormalizeAngle( Hermes.set.angles.y + ( ucmd:GetMouseX() * -0.022 * correct ) )
	Hermes.set.angles.p = math.Clamp( Hermes.set.angles.p + ( ucmd:GetMouseY() * 0.022 * correct ), -89, 90 )
	
	if ( Hermes.features['norecoil'] && !Hermes.set.aiming ) then
		ucmd:SetViewAngles( Hermes.set.angles )
	end
	
	Hermes.set.fakeang = Hermes.set.angles
	if ( Hermes:NospreadVaild( ucmd ) ) then
		Hermes.set.fakeang = Hermes.Nospread( ucmd, Hermes.set.angles )
		Hermes.set.fakeang.p = math.NormalizeAngle( Hermes.set.fakeang.p )
		Hermes.set.fakeang.y = math.NormalizeAngle( Hermes.set.fakeang.y )
		ucmd:SetViewAngles( Hermes.set.fakeang )
	end
	
	Hermes.AntiAim( ucmd )
	Hermes.PropKill( ucmd )
	
	if ( !Hermes.set.aiming ) then return end
	if ( !ply:Alive() ) then return end
	if ( Hermes.set.target == nil || Hermes.set.target == ply ) then return end
	
	local tar = Hermes.set.target
	local compensate = Hermes:TargetLocation( tar )
	
	if ( Hermes.features['prediction'] ) then
		compensate = Hermes.Prediction( tar, compensate )
	end
	
	local angles = ""
	if ( Hermes.features['silentaim'] ) then
		local fake = ( compensate - ply:GetShootPos() ):Angle()
		fake = Hermes.SmoothAngles( fake )
		angles = Hermes:NospreadVaild( ucmd ) && Hermes.Nospread( ucmd, fake ) || fake
	else
		Hermes.set.angles = ( compensate - ply:GetShootPos() ):Angle()
		Hermes.set.angles = Hermes.SmoothAngles( Hermes.set.angles )
		angles = Hermes:NospreadVaild( ucmd ) && Hermes.Nospread( ucmd, Hermes.set.angles ) || Hermes.set.angles
	end

	angles.p = math.NormalizeAngle( angles.p )
	angles.y = math.NormalizeAngle( angles.y )
	angles.r = 0
	
	ucmd:SetViewAngles( angles )
	
	if ( Hermes.features['silentaim'] ) then
		local move = Vector( ucmd:GetForwardMove(), ucmd:GetSideMove(), 0 )
		local norm = move:GetNormal()
		local set = ( norm:Angle() + ( angles - Hermes.set.angles ) ):Forward() * move:Length()
		ucmd:SetForwardMove( set.x )
		ucmd:SetSideMove( set.y )
	end
	
	local w = ply:GetActiveWeapon()
	if ( Hermes.features['autoshoot'] && !Hermes.set['shooting'] ) then
		Hermes.cmd.LocalCommand( "+attack" )
		Hermes.set['shooting'] = true
		timer.Simple( ( w && w.Primary ) && w.Primary.Delay || 0.05, function() Hermes.cmd.LocalCommand( "-attack" ); Hermes.set['shooting'] = false end )
	end
end
Hermes:AddHook( "CreateMove", Hermes.Aim )

-- Remove recoil and create zoom hack
function Hermes.NoRecoil( ply, origin, angles, FOV )
	local ply, zoomFOV = LocalPlayer(), FOV
	local w = ply:GetActiveWeapon()
	
	-- Zoom
	Hermes.zooming = false
	if ( Hermes.features['zoomalways'] ) then Hermes.zooming = true end
	if ( Hermes.features['zoomonaim'] && Hermes.set.aiming ) then Hermes.zooming = true end
	if ( Hermes.features['zoomontrigger'] && Hermes.set.trigger ) then Hermes.zooming = true end
	
	Hermes.zoomspeed = tonumber( Hermes.features['zoomamount'] )
		
	if ( Hermes.features['zoom'] && Hermes.zooming ) then
		zoomFOV = ( 90 / ( 1 + ( 1 * Hermes.zoomspeed ) ) )
	else zoomFOV = FOV end
	
	if ( Hermes.features['norecoil'] ) then
		-- Norecoil
		if ( w && ( w.Primary && w.Primary != 0 ) ) then
			w.OldRecoil = w.Recoil || ( w.Primary && w.Primary.Recoil )
			w.Recoil = 0
			w.Primary.Recoil = 0
		end
		
		-- No visual recoil
		if ( !Hermes.features['novisspread'] ) then
			local view = GAMEMODE:CalcView( ply, origin, Hermes.set.angles, zoomFOV ) || {}
			view.angles = Hermes.set.angles
			view.angles.r = 0
			view.fov = zoomFOV
			return view
		elseif ( Hermes.features['novisspread'] ) then
			local view = GAMEMODE:CalcView( ply, origin, angles, zoomFOV ) || {}
			view.angles = Hermes.set.angles
			view.angles.r = 0
			view.fov = zoomFOV
			return view
		end
	end
	
	-- Reset default recoil
	if ( !Hermes.features['norecoil'] && w && ( w.Primary && w.Primary == 0 ) && w.OldRecoil ) then
		w.Recoil = w.OldRecoil
		w.Primary.Recoil = w.OldRecoil
	end
	return GAMEMODE:CalcView( ply, origin, angles, zoomFOV )
end
Hermes:AddHook( "CalcView", Hermes.NoRecoil )

-- Add commands
function Hermes.Aiming()
	if ( disAim ) then return end
	if ( !Hermes.set.aiming ) then
		Hermes.set.aiming = true
		Hermes.set.target = nil
	end
end

function Hermes.AimingOFF()
	disAim = false
	if ( Hermes.set.aiming ) then
		Hermes.set.aiming = false
		Hermes.set.target = nil
	end
end

function Hermes.Trigger()
	if ( !Hermes.set.trigger ) then
		Hermes.set.trigger = true
	end
end

function Hermes.TriggerOFF()
	if ( Hermes.set.trigger ) then
		Hermes.set.trigger = false
	end
end

function Hermes.PropKill()
	if ( !Hermes.prop.enable ) then
		Hermes.prop.enable = true
	end
end

function Hermes.PropKillOFF()
	if ( Hermes.prop.enable ) then
		Hermes.prop.enable = false
	end
end

/*----------------------------------------
	Aim HUD
	Desc: Aimbot HUD.
*/----------------------------------------
function Hermes.ToggleHUD()
	local ply = LocalPlayer()
	
	local tar, text, col = Hermes.set.target, nil, nil
	
	if ( Hermes.set.aiming && tar && tar != ply ) then
		text = "Locked"; col = Color( 255, 0, 0, 255 )
	elseif ( Hermes.set.aiming ) then
		text = "Scanning..."; col = Color( 0, 255, 0, 255 )
	end
	
	if ( Hermes.features['toggle'] && Hermes.set.aiming ) then
		draw.SimpleText( text, "ScoreboardText", ( ScrW() / 2 ), ( ScrH() / 2 ) + 20, col, 1, 1 )
	end
	
	if ( Hermes.features['togglename'] && tar && Hermes.set.aiming ) then
		local text = tar:IsPlayer() && tar:Nick() || tar:GetClass()
		if ( tar != ply ) then
			draw.SimpleText( text, "ScoreboardText", ( ScrW() / 2 ), ( ScrH() / 2 ) + 40, col, 1, 1 )
		end
	end
end

/*----------------------------------------
	Adminlist
	Desc: Displays all the admins on the server.
*/----------------------------------------
function Hermes:IsAdmin( e )
	
	if ( e.IsAdmin && e:IsAdmin() ) then 
		return true
	elseif ( e.IsSuperAdmin && e:IsSuperAdmin() ) then 
		return true
	end
	return false
end

function Hermes:GetAdminType( e )

	local ply = LocalPlayer()
	
	if ( e:IsAdmin() && !e:IsSuperAdmin() ) then
		return "Admin"
	elseif ( e:IsSuperAdmin() ) then
		return "Super Admin"
	end
	return ""
end

Hermes.admins = {}
Hermes.adminlisttall = 0
function Hermes:Adminlist()
	if ( !Hermes.features['adminlist'] ) then return end
	Hermes.admins = {}
	
	local admin, adminnum, x, y = "", 0, ScrW(), ScrH()
	for k, e in ipairs( player.GetAll() ) do
		if ( e:IsPlayer() && Hermes:IsAdmin( e ) ) then
			admin = ( admin .. e:Nick() .. " [" .. Hermes:GetAdminType( e ) .. "]" .. "\n" )
			adminnum = adminnum + 1
		end
	end
		
	local wide, tall = 300, ( adminnum * 20 ) + 20
	local posX, posY = x / 2 + ( wide - wide ) + 300, y / 2 + ( tall + tall ) - 400
		
	if ( adminnum == 0 ) then
		admin = ""
		admin = ( "\nThere are no admins on right now" )
		wide, tall = 300, 40
	end
	
	local numb = string.Explode( "\n", admin )
	for k, v in pairs( numb ) do
		table.insert( Hermes.admins, v )
	end
	Hermes.adminlisttall = tall
end

/*----------------------------------------
	Health bar
	Desc: Displays the players HP.
*/----------------------------------------
function Hermes:CreatePos( e )
	local ply = LocalPlayer()
	local center = e:LocalToWorld( e:OBBCenter() )
	local min, max = e:OBBMins(), e:OBBMaxs()
	local dim = max - min
	local z = max + min
	
	local frt	= ( e:GetForward() ) * ( dim.y / 2 )
	local rgt	= ( e:GetRight() ) * ( dim.x / 2 )
	local top	= ( e:GetUp() ) * ( dim.z / 2 )
	local bak	= ( e:GetForward() * -1 ) * ( dim.y / 2 )
	local lft	= ( e:GetRight() * -1 ) * ( dim.x / 2 )
	local btm	= ( e:GetUp() * -1 ) * ( dim.z / 2 )
	
	local FRT 	= center + frt + rgt + top; FRT = FRT:ToScreen()
	local BLB 	= center + bak + lft + btm; BLB = BLB:ToScreen()
	local FLT	= center + frt + lft + top; FLT = FLT:ToScreen()
	local BRT 	= center + bak + rgt + top; BRT = BRT:ToScreen()
	local BLT 	= center + bak + lft + top; BLT = BLT:ToScreen()
	local FRB 	= center + frt + rgt + btm; FRB = FRB:ToScreen()
	local FLB 	= center + frt + lft + btm; FLB = FLB:ToScreen()
	local BRB 	= center + bak + rgt + btm; BRB = BRB:ToScreen()
	
	local maxX = math.max( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local minX = math.min( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local maxY = math.max( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	local minY = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	
	return maxX, minX, maxY, minY
end

function Hermes:DrawRect( x, y, w, h, col )
    surface.SetDrawColor( col.r, col.g, col.b, col.a )
    surface.DrawRect( x, y, w, h )
end

/*----------------------------------------
	ESP
	Desc: Prints shit on your screen.
*/----------------------------------------

function Hermes:Filter( e )
	local ply = LocalPlayer()
	
	local maxX, minX, maxY, minY = Hermes:CreatePos( e )
	local col = Hermes:FilterColors( e )
	local text, box, posX, posY, Xalign, Yalign = "", false, maxX, minY, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
	
	if ( e:IsNPC() && Hermes.features['enablen'] ) then
		if ( Hermes.features['boxn'] ) then
			box = true
		end
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		local data = e:GetClass()
		data = string.gsub( data, "npc_", "" )
		data = string.gsub( data, "monster_", "" )
		data = string.gsub( data, "_", "" )
		
		text = data
	elseif ( e:IsPlayer() && Hermes.features['enable'] ) then
		if ( tonumber( Hermes.features['optical'] ) != 1 ) then
			box = true
		end
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		local isFriend, friInfo = Hermes.features['friendsmark'] && e:GetFriendStatus() == "friend", ""
		if ( isFriend ) then friInfo = " *Friend*" end
		
		local added = 0
		if ( Hermes.features['name'] ) then
			if ( friInfo != "" ) then
				text = friInfo
				added = added + 1
				posY = posY - ( surface.GetTextSize( text ) + 1 )
			end
			
			text = text .. "\n" .. e:Nick()
			added = added + 1
			
			if ( added == 1 ) then
				text = e:Nick()
			end
		end
		
		if ( Hermes.features['health'] ) then
			text = text .. "\nHp: " .. e:Health()
			added = added + 1
			posY = posY - 13
			
			if ( added == 1 ) then
				text = "Hp: " .. e:Health()
			end
		end
		
		if ( Hermes.features['weapon'] ) then
			local wep = "NONE"
			if ( e:GetActiveWeapon():IsValid() ) then
				wep = e:GetActiveWeapon():GetPrintName()
			
				wep = string.gsub( wep, "#HL2_", "" )
				wep = string.gsub( wep, "#GMOD_", "" )
				wep = string.gsub( wep, "_", " " )
			end
			
			text = text .. "\nW: " .. wep
			added = added + 1
			posY = posY - 13
			
			if ( added == 1 ) then
				text = "W: " .. wep
			end
		end
		
	elseif ( e:IsWeapon() && Hermes.features['weaponse'] && Hermes.features['enablee'] ) then
		box = true
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		local data = e:GetClass()
		data = string.gsub( data, "weapon_", "" )
		data = string.gsub( data, "cs_", "" )
		data = string.gsub( data, "zm_", "" )
		data = string.gsub( data, "ttt_", "" )
		data = string.gsub( data, "weapon_", "" )
		data = string.gsub( data, "css_", "" )
		data = string.gsub( data, "real_", "" )
		data = string.gsub( data, "mad_", "" )
		data = string.gsub( data, "_", "" )
		text = data
		
	elseif ( Hermes.EntityListItem( e ) && Hermes.features['entityliste'] && Hermes.features['enablee'] ) then
		box = true
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		text = e:GetClass()
		
	elseif ( IsRagdoll( e ) && Hermes.features['enablee'] ) then
		box = false
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		text = "Ragdoll"
		
	elseif ( IsVehicle( e ) && Hermes.features['enablee'] ) then
		box = false
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		text = "Vehicle"
	end
	return text, box, col, posX, posY, maxX, minX, maxY, minY, Xalign, Yalign
end


-- This will be a entity filter, due to the fact esp lags.
function Hermes:GetEntities( typ )
	local targets = {}
	
	local ent, targets = ( Hermes.features['weaponse'] || Hermes.features['enablen'] ) && true || false, {}
	if ( ent ) then
		for k, e in ipairs( ents.GetAll() ) do
			if ( !e:IsPlayer() ) then
				if ( Hermes:ValidTarget( e, typ ) ) then
					table.insert( targets, e )
				end
			end
		end
	end
	for k, e in ipairs( player.GetAll() ) do
		if ( e:IsPlayer() ) then
			if ( Hermes:ValidTarget( e, typ ) ) then
				table.insert( targets, e )
			end
		end
	end
	
	if ( table.Count( targets ) > 1 ) then
		return targets
	end
	return ( table.Count( targets ) == 0 ) && {} || targets
end

function Hermes.HUD()
	local ply = LocalPlayer()
	
	local ent, entnum = Hermes:GetEntities( "esp" ), 0
	for k, e in pairs( ent ) do
		local text, box, col, posX, posY, maxX, minX, maxY, minY, Xalign, Yalign = Hermes:Filter( e )
		local textLength, pos = string.Explode( "\n", text ), 0
		
		local len = ( Vector( ( maxX + minX ) / 2, minY, 0 ) - Vector( ScrW() / 2, ScrH() / 2, 0 ) ):Length()
		local a = ( 1 - math.Clamp( len / tonumber( Hermes.features['fadelength'] ), 0, 1 ) ) * 255
			
		if ( e:IsPlayer() && box ) then
			if ( tonumber( Hermes.features['optical'] ) == 2 ) then
				Hermes:BoundingBox( e, Color( col.r, col.g, col.b, 255 ) )
			elseif ( tonumber( Hermes.features['optical'] ) == 3 ) then
				surface.SetDrawColor( Color( col.r, col.g, col.b, 255 ) )
				
				local int = 0
				for i = 1, 1 do
					surface.DrawLine( maxX + int, maxY - int, maxX + int, minY - int )
					surface.DrawLine( maxX - int, minY + int, minX - int, minY + int )
					
					surface.DrawLine( minX - int, minY + int, minX - int, maxY + int )
					surface.DrawLine( minX + int, maxY - int, maxX + int, maxY - int )
					int = int + 1
				end
			end
		end
		
		if ( !e:IsPlayer() && box ) then
			surface.SetDrawColor( Color( col.r, col.g, col.b, 255 ) )
			
			surface.DrawLine( maxX, maxY, maxX, minY )
			surface.DrawLine( maxX, minY, minX, minY )
			
			surface.DrawLine( minX, minY, minX, maxY )
			surface.DrawLine( minX, maxY, maxX, maxY )
		end
			
		if ( !Hermes.features['enablefade'] || a > 0 && ( entnum < tonumber( Hermes.features['maxshow'] ) ) ) then
			for i = 1, table.Count( textLength ) do
				a = Hermes.features['enablefade'] && a || 255
				draw.SimpleText(
					textLength[ i ],
					Hermes.currentfont['font'],
					posX,
					posY + pos,
					Color( col.r, col.g, col.b, a ),
					Xalign,
					Yalign
				)
				pos = pos + 12
			end
		end
		entnum = entnum + 1
	end
	
	if ( Hermes.features['crosshair'] ) then
		local g = tonumber( Hermes.features['crosshairgap'] )
		local x, y, l = ( ScrW() / 2 ), ( ScrH() / 2 ), g + tonumber( Hermes.features['crosshairlength'] )
		if ( tonumber( Hermes.features['crosshairtype'] ) == 2 ) then l = tonumber( Hermes.features['crosshairlength'] ) end
		
		// Inner
		if ( tonumber( Hermes.features['crosshairtype'] ) == 2 ) then
			surface.SetDrawColor( 255, 0, 0, 255 )
			
			surface.DrawLine( x, y - g, x, y + g )
			surface.DrawLine( x - g, y, x + g, y )
		end
		
		// Outer
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		surface.DrawLine( x - l, y, x - g, y )
		surface.DrawLine( x + l, y, x + g, y )
		
		surface.DrawLine( x, y - l, x, y - g )
		surface.DrawLine( x, y + l, x, y + g )
	end
	Hermes.ToggleHUD()
end
Hermes:AddHook( "HUDPaint", Hermes.HUD )

/*----------------------------------------
	Proxy
	Desc: Makes all models transparent.
*/----------------------------------------
function Hermes.Proxy()
	if ( !Hermes.features['proxy'] ) then return end
	local ply, c = LocalPlayer(), ( 1 / 255 )
	
	for k, e in pairs( ents.GetAll() ) do
		if ( ValidEntity( e ) && !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() ) then
			if ( Hermes.features['proxy'] ) then
				e:SetColor( 255, 255, 255, tonumber( Hermes.features['proxyvalue'] ) )
			else
				e:SetColor( 255, 255, 255, 255 )
			end
		end
	end
end

/*----------------------------------------
	Chams
	Desc: Nice D3D-style or XQZ chams.
*/----------------------------------------
function Hermes:CreateMaterial()
	local BaseInfo = {
		["$basetexture"] = "models/debug/debugwhite",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1,
		["$ignorez"]	 = 1
	}
	
	local solid = CreateMaterial( "hermes_createmat_solid", "VertexLitGeneric", BaseInfo )
	local wire = CreateMaterial( "hermes_createmat_wireframe", "Wireframe", BaseInfo )
	
	return solid, wire
end

function Hermes:FilterColorsChams( e )
	local ply = LocalPlayer()
	
	local isVis, notVis
	local isEnemy
	
	if ( !e:IsWeapon() ) then
		if ( !e:IsPlayer() ) then
			if ( IsEnemyEntityName( e:GetClass() ) || ( e:GetClass() == "npc_metropolice" ) || Hermes.IsTraitor( e ) ) then
				isEnemy = true
			end
		else
			if ( ply:Team() != e:Team() || ( IsTraitor( e ) ) ) then
				isEnemy = true
			end
		end
		
		if ( !isEnemy ) then
			isVis = Color( 0, 0, 255, 255 )
			notVis = Color( 0, 255, 0, 255 )
		else
			isVis = Color( 255, 0, 0, 255 )
			notVis = Color( 255, 242, 0, 255 )
		end
	end
	if ( e:IsWeapon() ) then isVis = Color( 255, 255, 255, 255 ); notVis = Color( 255, 255, 255, 255 ) end
	if ( IsRagdoll( e ) || IsVehicle( e ) ) then isVis = Color( 255, 255, 255, 255 ); notVis = Color( 255, 255, 255, 255 ) end
	return isVis, notVis
end

local solidMat, wireMat = Hermes:CreateMaterial()
function Hermes.Chams()
	local ply, c = LocalPlayer(), ( 1 / 255 )
	local ent = Hermes:GetEntities( "chams" )
	for k, e in ipairs( ent ) do
		if ( tonumber( Hermes.features['walltype'] ) != 4 ) then
			local mat = tonumber( Hermes.features['walltype'] ) == 3 && wireMat || solidMat
			local isVis, notVis = Hermes:FilterColorsChams( e )
			cam.Start3D( EyePos(), EyeAngles() )
				render.SuppressEngineLighting( tobool( Hermes.features['fullbright'] ) )
				render.SetColorModulation( ( notVis.r * c ), ( notVis.g * c ), ( notVis.b * c ) )
				SetMaterialOverride( mat )
				e:DrawModel()
				render.SuppressEngineLighting( false )
				if ( ( tonumber( Hermes.features['walltype'] ) != 1 ) || Hermes.features['visiblechams'] ) then
					render.SetColorModulation( ( isVis.r * c ), ( isVis.g * c ), ( isVis.b * c ) )
				else
					render.SetColorModulation( 1, 1, 1 )
				end
				SetMaterialOverride()
				e:DrawModel()
			cam.End3D()
		else
			cam.Start3D( EyePos(), EyeAngles() )
				cam.IgnoreZ( true )
				render.SuppressEngineLighting( tobool( Hermes.features['fullbright'] ) )
				e:DrawModel()
				cam.IgnoreZ( false )
				render.SuppressEngineLighting( false )
			cam.End3D()
		end
	end
end

function Hermes.RenderScreenspaceEffects()
	Hermes.Chams()
	Hermes.Proxy()
end
Hermes:AddHook( "RenderScreenspaceEffects", Hermes.RenderScreenspaceEffects )

function Hermes.SeconedChams()
	local mat = "hermes/living"
	if ( tonumber( Hermes.features['walltype'] ) == 3 ) then
		mat = "hermes/wireframe"
	end
	for k, e in ipairs( ents.GetAll() ) do
		if ( Hermes:ValidTarget( e, "chams" ) ) then
			if ( ( tonumber( Hermes.features['walltype'] ) != 4 ) && Hermes.features['visiblechams'] ) then
				local isVis, notVis = Hermes:FilterColorsChams( e )
				e:SetMaterial( mat )
				e:SetColor( isVis )
			else
				e:SetMaterial( "" )
				e:SetColor( 255, 255, 255, 255 )
			end
		end
	end
end
Hermes:AddHook( "RenderScene", Hermes.SeconedChams )

/*----------------------------------------
	Speedhack
	Desc: Makes you go faster than everyone.
*/----------------------------------------
function Hermes.SpeedHack()
	if ( Hermes.features['speedhack'] ) then
		RunConsoleCommand( "hermes_host_timescale", tonumber( Hermes.features['speedhackspeed'] ) )
	end
end

function Hermes.SpeedHackOFF()
	RunConsoleCommand( "hermes_host_timescale", 1.0 )
end

/*----------------------------------------
	Globals
	Desc: No-sky, fullbright...
*/----------------------------------------
function Hermes.Nosky()
	local vars = {
		{ Table = "fullbrightg", ON = "hermes_mat_fullbright 1", OFF = "hermes_mat_fullbright 0" },
		{ Table = "particles", ON = "hermes_r_drawparticles  0", OFF = "hermes_r_drawparticles  1" },
	}
	
	for k, v in ipairs( vars ) do
		if ( Hermes.features[ v.Table ] ) then
			Hermes.cmd.LocalCommand( v.ON )
		else
			Hermes.cmd.LocalCommand( v.OFF )
		end
	end
end

/*----------------------------------------
	Anti-gag
	Desc: ULX anti-gag, ye seth found dis out n all.
*/----------------------------------------
function Hermes.UnGag()
	if ( ulx && ulx['gagUser'] ) then
		if ( Hermes.features['ulxantigag'] ) then
			ulx['gagUser']( false )
		end
	end
end

/*----------------------------------------
	Name Stealer
	Desc: Steal peoples names.
*/----------------------------------------
function Hermes.NameSteal()
	local ply = LocalPlayer()
	
	local e = player.GetAll()[ math.random( 1, #player.GetAll() ) ]
	if ( Hermes.features['namesteal'] ) then
		if ( !e:IsAdmin() && e != ply ) then
			Hermes.cmd.LocalCommand( "name " .. e:Nick() .. "~ ~~" ) //" "
		end
	end
end

/*----------------------------------------
	Think
	Desc: Think hooks
*/----------------------------------------
function Hermes.Think()
	Hermes.GetTraitors()
	Hermes.NameSteal()
	Hermes.Nosky()
	Hermes.Bunnyhop()
	Hermes:Adminlist()
	Hermes.UnGag()
	//Hermes:SetGlobals()
end

Hermes:AddHook( "Think", Hermes.Think )

/*----------------------------------------
	Binding
	Desc: Binding function
*/----------------------------------------
Hermes.keys = {}
Hermes.keys["None"] = KEY_NONE
Hermes.keys["0"] = KEY_0
Hermes.keys["1"] = KEY_1
Hermes.keys["2"] = KEY_2
Hermes.keys["3"] = KEY_3
Hermes.keys["4"] = KEY_4
Hermes.keys["5"] = KEY_5
Hermes.keys["6"] = KEY_6
Hermes.keys["7"] = KEY_7
Hermes.keys["8"] = KEY_8
Hermes.keys["9"] = KEY_9
Hermes.keys["A"] = KEY_A
Hermes.keys["B"] = KEY_B
Hermes.keys["C"] = KEY_C
Hermes.keys["D"] = KEY_D
Hermes.keys["E"] = KEY_E
Hermes.keys["F"] = KEY_F
Hermes.keys["G"] = KEY_G
Hermes.keys["H"] = KEY_H
Hermes.keys["I"] = KEY_I
Hermes.keys["J"] = KEY_J
Hermes.keys["K"] = KEY_K
Hermes.keys["L"] = KEY_L
Hermes.keys["M"] = KEY_M
Hermes.keys["N"] = KEY_N
Hermes.keys["O"] = KEY_O
Hermes.keys["P"] = KEY_P
Hermes.keys["Q"] = KEY_Q
Hermes.keys["R"] = KEY_R
Hermes.keys["S"] = KEY_S
Hermes.keys["T"] = KEY_T
Hermes.keys["U"] = KEY_U
Hermes.keys["V"] = KEY_V
Hermes.keys["W"] = KEY_W
Hermes.keys["X"] = KEY_X
Hermes.keys["Y"] = KEY_Y
Hermes.keys["Z"] = KEY_Z
Hermes.keys["Alt"] = KEY_LALT
Hermes.keys["Shift"] = KEY_LSHIFT
Hermes.keys["Insert"] = KEY_INSERT
Hermes.keys["Delete"] = KEY_DELETE
Hermes.keys["Home"] = KEY_HOME
Hermes.keys["End"] = KEY_END

Hermes.mouse = {}
Hermes.mouse["Mouse left"] = MOUSE_LEFT
Hermes.mouse["Mouse right"] = MOUSE_RIGHT
Hermes.mouse["Mouse middle"] = MOUSE_MIDDLE

Hermes.mousekeys = { MOUSE_RIGHT, MOUSE_LEFT, MOUSE_MIDDLE }
Hermes.bindfunctions = { "Menu", "Aiming", "Trigger", "SpeedHack", "PropKill" }

local function IsKeyorMouse( key )
	for k, v in pairs( Hermes.mousekeys ) do
		if ( tonumber( key ) == tonumber( v ) ) then
			return "mouse"
		end
	end
	return "key"
end

function Hermes:SaveBinds()
	local str = ""
	for k, v in pairs( Hermes.binds ) do
		str = str .. k .. "-" .. v .. "\n"
	end
	
	file.Write( "hermes_lists_binds.txt", str )
end

function Hermes:LoadBinds()
	local vbinds = string.Explode( "\n", file.Exists( "hermes_lists_binds.txt" ) && file.Read( "hermes_lists_binds.txt" ) || "missing" )
	
	Hermes.binds = {}
	for k, v in pairs( vbinds ) do
		local skip = string.Explode( "-", v )
		if ( skip && ( skip[ 2 ] ) ) then
			Hermes.binds[ skip[ 1 ] ] = skip[ 2 ]
		end
	end
end
Hermes:LoadBinds()

function Hermes:SetKey( key, cmd, dochecks )
	if ( dochecks && Hermes.binds[ cmd ] ) then return end -- Already exists
	if ( !key || !cmd ) then return end
	
	for k, v in pairs( Hermes.keys ) do
		local tblkey = string.lower( k )
		if ( tblkey == string.lower( key ) ) then
			Hermes.binds[ cmd ] = v
		end
	end
	
	for k, v in pairs( Hermes.mouse ) do
		local tblkey = string.lower( k )
		if ( tblkey == string.lower( key ) ) then
			Hermes.binds[ cmd ] = v
		end
	end
	Hermes:SaveBinds()
end

Hermes.presstimes = {}
function Hermes:RemoveFunctionFromBind( cmd )
	if ( !cmd ) then return end
	if ( Hermes.binds[ cmd ] ) then
		Hermes.binds[ cmd ] = nil
		if ( Hermes.presstimes[ cmd ] ) then
			Hermes.presstimes[ cmd ] = nil
		end
	end
	Hermes:SaveBinds()
end

if ( !Hermes.binds['Menu'] ) then Hermes:SetKey( "insert", "Menu", true ) end -- Default

function Hermes:Bind()
	Hermes:LoadBinds()
	for k, v in pairs( Hermes.binds ) do
		local keytype = IsKeyorMouse( v )
		if ( keytype == "key" ) then
			if ( input.IsKeyDown( v ) ) then
				if ( !( Hermes.presstimes[ k ] && Hermes.presstimes[ k ] > CurTime() ) ) then
					Hermes[ k ]()
					Hermes.presstimes[ k ] = CurTime() + 0.25
				end
			else
				if ( Hermes[ k .. "OFF" ] ) then
					Hermes[ k .. "OFF" ]()
				end
			end
		elseif( keytype == "mouse" ) then
			if ( input.IsMouseDown( v ) ) then
				if ( !( Hermes.presstimes[ k ] && Hermes.presstimes[ k ] > CurTime() ) ) then
					Hermes[ k ]()
					Hermes.presstimes[ k ] = CurTime() + 0.25
				end
			else
				if ( Hermes[ k .. "OFF" ] ) then
					Hermes[ k .. "OFF" ]()
				end
			end
		end
	end
end

local function OnKeyPressed()
	Hermes:Bind()
	timer.Simple( 0.0001, OnKeyPressed )
end
timer.Simple( 0.01, OnKeyPressed )

// This is part of CelSius old derma skin, it works well and looks extremly nice.
function Hermes:Background( x, y, w, h, col1, col2 )
	for i = 1, h, 3 do
		local col = ( i / h )
		surface.SetDrawColor( ( col1.r * ( 1 - col ) ) + ( col2.r * col ), ( col1.g * ( 1 - col ) ) + ( col2.g * col ), ( col1.b * ( 1 - col ) ) + ( col2.b * col ), ( ( col * 2 ) + 3 ) * 50 )
		surface.DrawRect( x, y + i, w, 3 )
	end 
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( x, y, w, h )
end

/*----------------------------------------
	Menu
	Desc: A cool menu
*/----------------------------------------
Hermes.colors = {
	Background = Color( 0, 0, 0, 150 ),
	Outline = Color( 0, 0, 0, 255 )
}

function Hermes:MultiChoice( name, desc, cvar, contents, none )
	local multichoice = vgui.Create( "DMultiChoice" )
	multichoice:SetParent( mis )
	multichoice:SetPos( 210, 15 )
	multichoice:SetSize( 210, 20 )
	multichoice:SetEditable( false )
	
	if ( none ) then multichoice:AddChoice( "None" ) end
	for k, v in pairs( contents ) do
		multichoice:AddChoice( v )
	end
	
	if ( string.find( string.lower( name ), "font" ) ) then
		multichoice:ChooseOptionID( tonumber( GetConVarNumber( name ) + 1 ) )
	else
		multichoice:ChooseOptionID( tonumber( GetConVarNumber( name ) ) )
	end
	
	multichoice.change = 0
	multichoice.OnSelect = function( index, value, data )
		if ( multichoice.change < CurTime() ) then
			multichoice.change = CurTime() + 0.1
			if ( string.find( string.lower( name ), "font" ) ) then
				Hermes:GetSelectedFont( value - 1 ) -- For some reason it's adding 1, prob because '0' isn't valid in DMultiChoice.
				RunConsoleCommand( name, value - 1 )
			else
				RunConsoleCommand( name, value )
			end
		end
	end
	return multichoice
end

function Hermes:CheckBox( cvar, desc )
	local checkbox = vgui.Create( "DCheckBoxLabel" )
	checkbox:SetText( desc )
	checkbox:SetValue( GetConVarNumber( cvar ) )
	//checkbox:SetTextColor( Color( 0, 0, 0, 255 ) )
		
	checkbox.change = 0
	checkbox.OnChange = function()
		if ( checkbox.change < CurTime() ) then
			checkbox.change = CurTime() + 0.1
			checkbox:SetValue( tobool( checkbox:GetChecked() && 1 || 0 ) )
			RunConsoleCommand( cvar, checkbox:GetChecked() && 1 || 0 )
		end
	end
			
	cvars.AddChangeCallback( cvar, function( cvar, old, new ) 
		if ( checkbox.change < CurTime() ) then
			checkbox.change = CurTime() + 0.1
			checkbox:SetValue( tobool( new ) )
		end
	end )
	
	return checkbox
end

function Hermes:NumSlider( cvar, value, desc, max, min, deci )
	local slider = vgui.Create( "DNumSlider" )
	slider:SetText( "" )
	slider:SetMax( max || 1 )
	slider:SetMin( min || 0 )
	
	if ( deci ) then
		slider:SetDecimals( 1 )
	else
		slider:SetDecimals( 0 )
	end
	
	slider:SetValue( Hermes.features[ value ] )
	
	local label = vgui.Create( "DLabel" )
	label:SetParent( slider )
	label:SetWide( 200 )
	label:SetText( desc )
	//label:SetTextColor( Color( 0, 0, 0, 255 ) )
	
	slider.change = 0
	slider.ValueChanged = function( self, new )
		if ( slider.change < CurTime() ) then
			slider.change = CurTime() + 0.1
			slider:SetValue( new )
			RunConsoleCommand( cvar, new )
		end
	end
			
	cvars.AddChangeCallback( cvar, function( cvar, old, new ) 
		if ( slider.change < CurTime() ) then
			slider.change = CurTime() + 0.1
			slider:SetValue( new )
		end
	end )
	return slider
end

Hermes.radar = nil
Hermes.adminlist = nil

local lineTime, linePos = 0, 0
function Hermes.ExtraGUI()
	local xn, yn, x, y = ScrW(), ScrH(), ScrW() / 2, ScrH() / 2
	
	Hermes['radar'] = vgui.Create( "DFrame" )
	Hermes['radar']:SetSize( 250, 250 )
	
	local radarW, radarH = Hermes['radar']:GetWide(), Hermes['radar']:GetTall()
	Hermes['radar']:SetPos( xn - radarW - 10, yn - radarH - ( yn - radarH ) + 10 )
	Hermes['radar']:SetTitle( "Radar" )
	Hermes['radar']:SetVisible( true )
	Hermes['radar']:SetDraggable( true )
	Hermes['radar']:ShowCloseButton( false )
	Hermes['radar']:MakePopup()
	
	Hermes['radar'].Paint = function()
		Hermes:Background( 0, 0, radarW, radarH, Color( 0, 0, 0 ), Color( 0, 0, 0 ) )
		
		// Radar Function
		local ply = LocalPlayer()
		
		local radar = {}
		radar.h		= 250
		radar.w		= 250
		radar.org	= tonumber( Hermes.features['radarradius'] )
		
		local x, y = ScrW() / 2, ScrH() / 2
		
		local half = radarH / 2
		local xm = half
		local ym = half
		
		// Moving line
		if ( Hermes.features['radarspin'] ) then
			local speed = 2
			local x1,y1 = math.cos( RealTime() * speed ), math.sin( RealTime() * speed )
			local x2,y2 = math.cos( RealTime() * speed + math.pi / 2 ), math.sin( RealTime() * speed + math.pi / 2 )
			local iR, oR = 0, 100
			
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawLine( xm + ( x1 * iR ), ym + ( y1 * iR ), xm + ( x1 * oR ), ym + ( y1 * oR ) )
		end
		
		surface.DrawLine( xm, ym - 100, xm, ym + 100 )
		surface.DrawLine( xm - 100, ym, xm + 100, ym )
		
		local ent = Hermes:GetEntities( "radar" )
		for k, e in ipairs( ent ) do		
			local s = 6
			local color = Hermes:FilterColors( e )
			local plyfov = ply:GetFOV() / ( 70 / 1.13 )
			local zpos, npos = ply:GetPos().z - ( e:GetPos().z ), ( ply:GetPos() - e:GetPos() )
			
			npos:Rotate( Angle( 180, ( ply:EyeAngles().y ) * -1, -180 ) )
			local iY = npos.y * ( radar.h / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
			local iX = npos.x * ( radar.w / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
			
			local pX = ( radar.w / 2 )
			local pY = ( radar.h / 2 )
			
			local posX = pX - iY - ( s / 2 )
			local posY = pY - iX - ( s / 2 )
				
			if ( iX < ( radar.h / 2 ) && iY < ( radar.w / 2 ) && iX > ( -radar.h / 2 ) && iY > ( -radar.w / 2 ) ) then
				local text = e:IsPlayer() && e:Nick() || e:GetClass()
				draw.RoundedBox( s, posX, posY, s, s, color )
				if ( Hermes.features['radarname'] ) then
					draw.SimpleText( text, "DefaultSmall", posX, posY - 6, color, 1, 1 )
				end
			end
		end
	end
	Hermes['radar']:SetMouseInputEnabled( false )
	Hermes['radar']:SetKeyboardInputEnabled( false )
	
	// Adminlist
	Hermes['adminlist'] = vgui.Create( "DFrame" )
	Hermes['adminlist']:SetSize( 250, 1000 )
	
	local aW, aH, x, y = Hermes['adminlist']:GetWide(), Hermes.adminlisttall, ScrW() / 2, ScrH() / 2
	
	Hermes['adminlist']:SetPos( xn - aW - 10, yn -  aH - ( yn - aH ) + 270 )
	Hermes['adminlist']:SetTitle( "Admins" )
	Hermes['adminlist']:SetVisible( true )
	Hermes['adminlist']:SetDraggable( true )
	Hermes['adminlist']:ShowCloseButton( false )
	Hermes['adminlist']:MakePopup()
	Hermes['adminlist'].Paint = function()
		Hermes:Background( 0, 0, 250, Hermes.adminlisttall, Color( 0, 0, 0 ), Color( 0, 0, 0 ) )
		
		local pos = 17
		for i = 1, table.Count( Hermes.admins ) do
			draw.SimpleText(
				Hermes.admins[ i ],
				"Default",
				20,
				pos,
				Color( 0, 255, 0, 255 ),
				0,
				0
			)
			pos = pos + 12
		end
	end
	
	Hermes['adminlist']:SetMouseInputEnabled( false )
	Hermes['adminlist']:SetKeyboardInputEnabled( false )
end

local menuValid = true
function Hermes.OpenExtraGUI()
	if ( menuValid ) then
		Hermes.ExtraGUI()
		menuValid = false
	end
end

function Hermes.Binds( binds )
	local combobox
	local function BindList()
		combobox = vgui.Create( "DComboBox" )
		combobox:SetParent( binds )
		combobox:SetPos( 10 + 10, 15 + 10 )
		combobox:SetSize( 200 - 20, 230 )
		combobox:SetMultiple( false )
	end
	BindList()
	
	local function AddBinds()
		combobox:Clear()
		for k, v in pairs( Hermes.bindfunctions ) do
			combobox:AddItem( v )
		end
	end
	AddBinds()
	
	local keyname = vgui.Create( "DTextEntry" )
	keyname:SetParent( binds )
	keyname:SetPos( 260, 25 )
	keyname:SetSize( 150, 20 )
	keyname:SetEditable( false )
	
	local bindkey = vgui.Create( "DTextEntry" )
	bindkey:SetParent( binds )
	bindkey:SetPos( 260, 55 )
	bindkey:SetSize( 150, 20 )
	bindkey:SetEditable( false )
	
	local bindlist = vgui.Create( "DMultiChoice" )
	bindlist:SetParent( binds )
	bindlist:SetPos( 260, 85 )
	bindlist:SetWidth( 150 )
	bindlist.TextEntry:SetEditable( false )
	
	function bindlist:OnSelect( index, value, data )
		if ( bindkey:GetValue() == "" || keyname:GetValue() == "" ) then return end
		local cmd = keyname:GetValue()
		if ( Hermes.binds[ cmd ] ) then
			Hermes:RemoveFunctionFromBind( cmd )
		end
		Hermes:SetKey( value, cmd, false )
	end
	
	for k, v in pairs( Hermes.keys ) do
		bindlist:AddChoice( k )
	end
	
	for k, v in pairs( Hermes.mouse ) do
		bindlist:AddChoice( k )
	end
	
	local oldSelect = combobox.SelectItem
	function combobox.SelectItem( self, item, multi )
		local text = item:GetValue()
		keyname:SetValue( text )
		bindlist:SetText( "" )
		
		local curkey = nil
		for u, e in pairs( Hermes.binds ) do
			for m, n in pairs( Hermes.keys ) do
				if ( tonumber( e ) == tonumber( n ) ) then
					if ( string.lower( text ) == string.lower( u ) ) then
						curkey = m
					end
				end
			end
			for m, n in pairs( Hermes.mouse ) do
				if ( tonumber( e ) == tonumber( n ) ) then
					if ( string.lower( text ) == string.lower( u ) ) then
						curkey = m
					end
				end
			end
			bindkey:SetValue( curkey || "No key bound" )
		end
		oldSelect( self, item, multi )
	end
	
	local label = vgui.Create( "DLabel" )
	label:SetParent( binds )
	label:SetPos( 210, 25 )
	label:SetWide( 200 )
	label:SetText( "Function: " )
	
	local label = vgui.Create( "DLabel" )
	label:SetParent( binds )
	label:SetPos( 210, 55 )
	label:SetWide( 200 )
	label:SetText( "Key: " )
	
	local label = vgui.Create( "DLabel" )
	label:SetParent( binds )
	label:SetPos( 210, 85 )
	label:SetWide( 50 )
	label:SetText( "Set Key: " )
end

function Hermes.System( friends, entity )
	// Friends list
	local combobox1
	function Hermes.AllPlayers()
		combobox1 = vgui.Create( "DComboBox" )
		combobox1:SetParent( friends )
		combobox1:SetPos( 10 + 10, 15 + 10 )
		combobox1:SetSize( 200 - 20, 230 - 20 )
		combobox1:SetMultiple( false )
	end
	Hermes.AllPlayers()
	
	local combobox2
	function Hermes.OnlyFriends()
		combobox2 = vgui.Create( "DComboBox" )
		combobox2:SetParent( friends )
		combobox2:SetPos( 220 + 10, 15 + 10 )
		combobox2:SetSize( 200 - 20, 230 - 20 )
		combobox2:SetMultiple( false )
	end
	Hermes.OnlyFriends()
	
	function Hermes.AddFriendsToList()
		combobox1:Clear()
		combobox2:Clear()
		
		local add, rem = Hermes.GetAddedFriends()
		for k, e in pairs( add ) do
			combobox2:AddItem( e:Nick() )
		end
		
		for k, e in pairs( rem ) do
			combobox1:AddItem( e:Nick() )
		end
	end
	Hermes.AddFriendsToList()
	
	local button1 = vgui.Create( "DButton" )
	button1:SetParent( friends )
	button1:SetSize( 160, 20 )
	button1:SetPos( 30, 240 )
	button1:SetText( "Add" )
	button1.DoClick = function()
		if ( combobox1:GetSelectedItems() && combobox1:GetSelectedItems()[1] ) then
			for k, e in pairs( player.GetAll() ) do
				if ( ValidEntity( e ) && e:Nick() == combobox1:GetSelectedItems()[1]:GetValue() ) then
					Hermes.AddFriends( e )
				end
			end
		end
		Hermes.AddFriendsToList()
	end
	
	local button2 = vgui.Create( "DButton" )
	button2:SetParent( friends )
	button2:SetSize( 160, 20 )
	button2:SetPos( 240, 240 )
	button2:SetText( "Remove" )
	button2.DoClick = function()
		if ( combobox2:GetSelectedItems() && combobox2:GetSelectedItems()[1] ) then
			for k, e in pairs( Hermes.friends ) do
				for u, v in pairs( player.GetAll() ) do
					if ( v:IsBot() ) then
						if ( e == combobox2:GetSelectedItems()[1]:GetValue() ) then
							Hermes.friends[ k ] = nil
						end
					else
						if ( e == v:SteamID() ) then
							if ( v:Nick() == combobox2:GetSelectedItems()[1]:GetValue() ) then
								Hermes.friends[ k ] = nil
							end
						end
					end
				end
			end
		end
		Hermes.AddFriendsToList()
		file.Write( "hermes_lists_friends.txt", TableToKeyValues( Hermes.friends ) )
	end
	// End of friends list
	
	// Entities list
	local combobox3
	function Hermes.AllEntities()
		combobox3 = vgui.Create( "DComboBox" )
		combobox3:SetParent( entity )
		combobox3:SetPos( 10 + 10, 15 + 10 )
		combobox3:SetSize( 200 - 20, 230 - 20 )
		combobox3:SetMultiple( false )
	end
	Hermes.AllEntities()
	
	local combobox4
	function Hermes.OnlyListed()
		combobox4 = vgui.Create( "DComboBox" )
		combobox4:SetParent( entity )
		combobox4:SetPos( 220 + 10, 15 + 10 )
		combobox4:SetSize( 200 - 20, 230 - 20 )
		combobox4:SetMultiple( false )
	end
	Hermes.OnlyListed()
	
	function Hermes.AddEntitiesToList()
		combobox3:Clear()
		combobox4:Clear()
		
		local add, rem = Hermes.GetAddedItems()
		for k, e in ipairs( add ) do
			local c = combobox4:AddItem( e )
		end
		
		for k, e in ipairs( rem ) do
			local c = combobox3:AddItem( e )
		end
	end
	Hermes.AddEntitiesToList()
	
	local button3 = vgui.Create( "DButton" )
	button3:SetParent( entity )
	button3:SetSize( 160, 20 )
	button3:SetPos( 30, 240 )
	button3:SetText( "Add" )
	button3.DoClick = function()
		if ( combobox3:GetSelectedItems() && combobox3:GetSelectedItems()[1] ) then
			for a, b in pairs( combobox3:GetSelectedItems() ) do
				for k, e in pairs( ents.GetAll() ) do
					if ( ValidEntity( e ) && e:GetClass() == combobox3:GetSelectedItems()[1]:GetValue() ) then
						Hermes.AddEntities( e )
					end
				end
			end
		end
		Hermes.AddEntitiesToList()
	end
	
	local button4 = vgui.Create( "DButton" )
	button4:SetParent( entity )
	button4:SetSize( 160, 20 )
	button4:SetPos( 240, 240 )
	button4:SetText( "Remove" )
	button4.DoClick = function()
		if ( combobox4:GetSelectedItems() && combobox4:GetSelectedItems()[1] ) then
			for a, b in pairs( combobox4:GetSelectedItems() ) do
				for k, e in pairs( Hermes.entities ) do
					if ( e == combobox4:GetSelectedItems()[1]:GetValue() ) then
						Hermes.entities[k] = nil
					end
				end
			end
		end
		Hermes.AddEntitiesToList()
		file.Write( "hermes_lists_entities.txt", TableToKeyValues( Hermes.entities ) )
	end
	// End of entities list
end

Hermes.panelopen = false
Hermes.panel = nil
function Hermes.VGUIMenu()
	Hermes.OpenExtraGUI()
	
	Hermes.panel = vgui.Create( "DFrame" )
	Hermes.panel:SetPos( ScrW() / 2 - 450 / 2, ScrH() / 2 - 350 / 2 )
	Hermes.panel:SetSize( 450, 350 )
	Hermes.panel:SetTitle( "Hermes" )
	Hermes.panel:SetVisible( true )
	Hermes.panel:SetDraggable( true )
	Hermes.panel:ShowCloseButton( true )
	Hermes.panel:MakePopup()
	Hermes.panel.Close = function()
		Hermes.panelopen = false
		Hermes.panel:SetVisible( false )
	end
	
	Hermes.panel.Paint = function()
		local w, h = Hermes.panel:GetWide(), Hermes.panel:GetTall()
		Hermes:Background( 0, 0, w, h, Color( 0, 0, 0 ), Color( 0, 0, 0 ) )
	end
	
	Hermes.panelopen = true
	if ( !Hermes.panel:IsVisible() || Hermes.panel == nil ) then return end
	local panel = Hermes.panel
	
	local Include = {
		{ Tab = "Aimbot", Icon = "gui/silkicons/wrench", Contents = {
				{ [1] = "Aimbot" },
				{ [2] = "Triggerbot" },
				{ [3] = "Targeting" },
				{ [4] = "Accuracy" },
				{ [5] = "HUD" },
			}
		},
		
		{ Tab = "ESP", Icon = "gui/silkicons/world", Contents = {
				{ [6] = "General" },
				{ [7] = "Players" },
				{ [8] = "NPCs" },
				{ [9] = "Entities" },
				{ [10] = "Chams" },
				{ [11] = "Proxy" },
			}
		},
		
		{ Tab = "Miscellaneous", Icon = "gui/silkicons/plugin", Contents = {
				{ [12] = "Miscellaneous" },
				{ [13] = "Crosshair" },
				{ [14] = "Radar" },
				{ [15] = "Globals" },
				{ [16] = "Speedhack" },
				{ [17] = "Zoom" },
				{ [18] = "AntiAim" },
			}
		},
		
		{ Tab = "Friends", Icon = "gui/silkicons/group", Contents = nil },
		{ Tab = "Entities", Icon = "gui/silkicons/star", Contents = nil },
		{ Tab = "Binds", Icon = "gui/silkicons/bomb", Contents = nil },
	}
	
	local lists, collapsiblecategory, categorylist, dlist = {}, {}, {}, {}
	for k, v in ipairs( Include ) do
		lists[ v.Tab ] = vgui.Create( "DPanelList" )
		lists[ v.Tab ]:SetPos( 10, 60 )
		lists[ v.Tab ]:SetParent( panel )
		lists[ v.Tab ]:SetSize( 440 - 15, 320 - 40 )
		lists[ v.Tab ]:EnableVerticalScrollbar( true )
		lists[ v.Tab ]:SetSpacing( 5 )
		lists[ v.Tab ].Paint = function() end
	end
	
	Hermes.System( lists['Friends'], lists['Entities'] )
	Hermes.Binds( lists['Binds'] )
	
	local bpos, dbutton, a = 0, {}, 1
	for k, v in ipairs( Include ) do
		local function DoPaint( txt, txtcol )
			local w, h = dbutton[ v.Tab ]:GetWide(), dbutton[ v.Tab ]:GetTall()
			// Main
			draw.RoundedBox( 0, 0, 0, w, h, Hermes.colors.Background )
			
			// Outline
			surface.SetDrawColor( Hermes.colors.Outline )
			surface.DrawOutlinedRect( 0, 0, w, h )
			
			if ( txtcol ) then
				draw.SimpleText( txt, "Default", 70 / 2, ( 20 / 2 ) - 1, txtcol, 1, 1 )
			end
		end
		
		dbutton[ v.Tab ] = vgui.Create( "DButton" )
		dbutton[ v.Tab ]:SetParent( panel )
		dbutton[ v.Tab ]:SetSize( 70, 20 )
		dbutton[ v.Tab ]:SetPos( 7 + bpos, 30 )
		dbutton[ v.Tab ]:SetText( v.Tab )
		dbutton[ v.Tab ].Paint = function() DoPaint( v.Tab, nil ) end
		dbutton[ v.Tab ].DoClick = function()
			for e, i in ipairs( Include ) do
				lists[ i.Tab ]:SetVisible( false )
				dbutton[ i.Tab ]:SetText( i.Tab )
				dbutton[ i.Tab ].Paint = function() DoPaint( i.Tab, nil ) end
			end
			lists[ v.Tab ]:SetVisible( true )
			dbutton[ v.Tab ]:SetText( "" )
			dbutton[ v.Tab ].Paint = function() DoPaint( v.Tab, Color( 255, 201, 14 ) ) end
		end
		bpos = bpos + 74
		
		lists[ v.Tab ]:SetVisible( v.Tab == "Aimbot" && true || false )
		if ( v.Tab == "Aimbot" ) then
			dbutton[ v.Tab ]:SetText( "" )
			dbutton[ v.Tab ].Paint = function() DoPaint( v.Tab, Color( 255, 201, 14 ) ) end
		end
		if ( v.Contents ) then
			for t, e in ipairs( v.Contents ) do
				collapsiblecategory[ e[ a ] ] = vgui.Create( "DCollapsibleCategory" )
				collapsiblecategory[ e[ a ] ]:SetParent( panel )
				collapsiblecategory[ e[ a ] ]:SetExpanded( 0 )
				collapsiblecategory[ e[ a ] ]:SetLabel( e[ a ] || "" )
				
				categorylist[ e[ a ] ] = vgui.Create( "DPanelList" )
				categorylist[ e[ a ] ]:SetAutoSize( true )
				categorylist[ e[ a ] ]:SetSpacing( 5 )
				categorylist[ e[ a ] ]:EnableHorizontal( false )
				categorylist[ e[ a ] ]:EnableVerticalScrollbar( true )
				categorylist[ e[ a ] ].Paint = function() end
				
				table.insert( dlist, { Name = e[ a ] } )
				
				collapsiblecategory[ e[ a ] ]:SetContents( categorylist[ e[ a ] ] )
				
				lists[ v.Tab ]:AddItem( collapsiblecategory[ e[ a ] ] )
				a = a + 1
			end
		end
	end
		
	local function AddItem( item, typ )
		for k, v in ipairs( dlist ) do
			if ( string.find( string.lower( v.Name ), string.lower( typ ) ) ) then
				categorylist[ v.Name ]:AddItem( item )
			end
		end
	end

	for k, v in ipairs( Hermes.menuitems ) do
		if ( v.Type == "checkbox" ) then
			local checkbox = Hermes:CheckBox( v.Name, v.Desc )
			AddItem( checkbox, v.Menu )
		elseif ( v.Type == "multichoice" ) then
			local multichoice = Hermes:MultiChoice( v.Name, v.Desc, v.ConVar, v.Contents, v.None )
			AddItem( multichoice, v.Menu )
		elseif ( v.Type == "slider" ) then
			local slider = Hermes:NumSlider( v.Name, v.ConVar, v.Desc, v.Max || 1, v.Min || 0, v.Decimal )
			AddItem( slider, v.Menu )
		end
	end
end

function Hermes.Menu()
	if ( !Hermes.panelopen ) then
		Hermes.VGUIMenu()
	end
end

local function ExtraLoop()
	if ( !menuValid ) then
		if ( Hermes.panel && Hermes.panel:IsVisible() ) then
			Hermes['radar']:SetMouseInputEnabled( true )
			Hermes['radar']:SetKeyboardInputEnabled( true )
			Hermes['adminlist']:SetMouseInputEnabled( true )
			Hermes['adminlist']:SetKeyboardInputEnabled( true )
		else
			Hermes['radar']:SetMouseInputEnabled( false )
			Hermes['radar']:SetKeyboardInputEnabled( false )
			Hermes['adminlist']:SetMouseInputEnabled( false )
			Hermes['adminlist']:SetKeyboardInputEnabled( false )
		end
		if ( Hermes.features['radar'] ) then
			Hermes['radar']:SetVisible( true )
		else
			Hermes['radar']:SetVisible( false )
		end
		if ( Hermes.features['adminlist'] ) then
			Hermes['adminlist']:SetVisible( true )
		else
			Hermes['adminlist']:SetVisible( false )
		end
	end
	timer.Simple( 0.1, ExtraLoop )
end
timer.Simple( 0.1, ExtraLoop )