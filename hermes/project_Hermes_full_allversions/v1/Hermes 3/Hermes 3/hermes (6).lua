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
Hermes.ips			= ( file.Exists( "hermes_lists_ips.txt" ) && KeyValuesToTable( file.Read( "hermes_lists_ips.txt" ) ) || {} )

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
	hook = table.Copy( hook ),
	cvars = table.Copy( cvars ),
	file = table.Copy( file ),
	debug = table.Copy( debug ),
	sql = table.Copy( sql ),
	string = table.Copy( string ),
	GetInt = _R.ConVar.GetInt,
	GetBool = _R.ConVar.GetBool
}

Hermes.set = {
	aiming = false,
	target = nil,
	tar = nil,
	angles = Angle( 0, 0, 0 ),
	fakeang = Angle( 0, 0, 0 ),
	antiaimang = Angle( 0, 0, 0 ),
	trigger = false,
}

Hermes.getcvars = {}
Hermes.convars = {
	{ Item = "Aimbot", Setting = {
			{ Tab = "Aimbot", Items = {
					{ ConVar = "autoshoot", Value = 1, Desc = "Autoshoot", Type = "checkbox" },
					{ ConVar = "silentaim", Value = 0, Desc = "Silent-aim", Type = "checkbox" },
					{ ConVar = "prediction", Value = 1, Desc = "Prediction", Type = "checkbox" },
					{ ConVar = "vectorstyle", Value = 1, Desc = "Vector Style", Type = "checkbox" },
					{ ConVar = "obbtargeting", Value = 1, Desc = "OBB Targeting", Type = "checkbox" },
					{ ConVar = "velocitychecks", Value = 1, Desc = "Velocity Checks", Type = "checkbox" },
					{ ConVar = "smoothaim", Value = 1, Desc = "Smooth-aim", Type = "checkbox" },
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
				}
			},
			
			{ Tab = "Triggerbot", Items = {
					{ ConVar = "triggerbot", Value = 0, Desc = "Triggerbot", Type = "checkbox" },
					{ ConVar = "triggerkey", Value = 0, Desc = "Trigger Key", Type = "checkbox" },
					{ ConVar = "triggerdistance", Value = 156, Desc = "Trigger Distance", Type = "slider", Min = 0, Max = 10000 },
				}
			},
			
			{ Tab = "HUD", Items = {
					{ ConVar = "toggle", Value = 1, Desc = "Toggle HUD", Type = "checkbox" },
					{ ConVar = "togglename", Value = 0, Desc = "Print Name", Type = "checkbox" },
					{ ConVar = "ignorelist", Value = 0, Desc = "Ignore-list", Type = "checkbox" },
				}
			},
			
			{ Tab = "Accuracy", Items = {
					{ ConVar = "norecoil", Value = 1, Desc = "Norecoil", Type = "checkbox" },
					{ ConVar = "nospread", Value = 0, Desc = "Nospread", Type = "checkbox" },
					{ ConVar = "constantnospread", Value = 0, Desc = "Constant Nospread", Type = "checkbox" },
				}
			},
		},
	
	Prefix = "aim_"
	},
	
	{ Item = "ESP", Setting = {
			{ Tab = "Players", Items = {
					{ ConVar = "enable", Value = 0, Desc = "Enable", Type = "checkbox" },
					{ ConVar = "enemyonly", Value = 0, Desc = "Enemy Only", Type = "checkbox" },
					{ ConVar = "name", Value = 1, Desc = "Name", Type = "checkbox" },
					{ ConVar = "health", Value = 1, Desc = "Health", Type = "checkbox" },
					{ ConVar = "weapon", Value = 0, Desc = "Weapon", Type = "checkbox" },
					{ ConVar = "box", Value = 0, Desc = "Box", Type = "checkbox" },
					{ ConVar = "adminlist", Value = 0, Desc = "Admin-list", Type = "checkbox" },
					{ ConVar = "ttthud", Value = 0, Desc = "Terror-town HUD", Type = "checkbox" },
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
					{ ConVar = "fullbright", Value = 1, Desc = "Fullbright", Type = "checkbox" },
					{ ConVar = "wireframe", Value = 0, Desc = "Wireframe", Type = "checkbox" },
					{ ConVar = "visiblechams", Value = 0, Desc = "Visible Chams", Type = "checkbox" },
					{ ConVar = "xqz", Value = 0, Desc = "XQZ", Type = "checkbox" },
				}
			},
			
			{ Tab = "Proxy", Items = {
					{ ConVar = "proxy", Value = 0, Desc = "Proxy Models", Type = "checkbox" },
					{ ConVar = "proxymdls", Value = 0, Desc = "Only MDLs", Type = "checkbox" },
					{ ConVar = "proxyvalue", Value = 200, Desc = "Proxy Value", Type = "slider", Min = 0, Max = 255 },
				}
			},
		},
	
	Prefix = "esp_"
	},
	
	{ Item = "Misc", Setting = {
			{ Tab = "Misc", Items = {
					{ ConVar = "crosshair", Value = 1, Desc = "Crosshair", Type = "checkbox" },
					{ ConVar = "namesteal", Value = 0, Desc = "Name Stealer", Type = "checkbox" },
					{ ConVar = "bunnyhop", Value = 1, Desc = "Bunnyhop", Type = "checkbox" },
					{ ConVar = "autopistol", Value = 1, Desc = "Autopistol", Type = "checkbox" },
					{ ConVar = "ulxantigag", Value = 1, Desc = "Anti-gag", Type = "checkbox" },
				}
			},
			
			{ Tab = "Globals", Items = {
					{ ConVar = "nosky", Value = 1, Desc = "No-sky", Type = "checkbox" },
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

Hermes.files = { "gmcl_sys", "gmcl_proxy", "hake", "gmcl_cmd", "hermes_cvar", "hermes_bypass", "hermes" }
Hermes.path = "lua\\includes\\enum\\hermes.lua"

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
				
				local cvar = string.lower( tostring( "Hermes_" .. v.Prefix .. n.ConVar .. endtext ) )
				Hermes.getcvars[ cvar ] = cvar
			end
		end
	end
	for r, p in pairs( Hermes.repcvars ) do
		local cvar = string.lower( tostring( "Hermes_" .. p ) )
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

//------------------------------
// Metatables:
//------------------------------
--[[
local function CopyMetatable( meta )
	return table.Copy( _R[ meta ] || {} )
end
]]
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
	return Hermes.copy.engineConsoleCommand( p, c, a )
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
			require( "sys" )
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
		require( "cmd" )
		package.loaded.cmd = nil
		
		Hermes.loaded.cmd = true
		Hermes.cmd = {
			LocalCommand = LocalCommand,
		}
	
		_G.LocalCommand = nil
	
		print( "Included 'gmcl_cmd'" )
	end
end
Hermes.ModuleCheck()

//------------------------------
// Pato:
//------------------------------
function Hermes:CheckPato()
	if ( !Hermes.copy.ConVarExists( "hermes_host_timescale" ) ) then
		Hermes.cmd.LocalCommand( "hermes_pato" )
		Hermes.cmd.LocalCommand( "hermes_sv_cheats 1" )
	end
end
Hermes:CheckPato()

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

local oldhook = hook.Add
function hook.Add( hooks, name, func )
	if ( hooks == "OnConCommand" ) then
		MsgN( "The fuck not this shit" )
		return nil
	end
	return oldhook( hooks, name, func )
end

/*----------------------------------------
	Function override
	Desc: Stop blacklist/whitelist.
*/----------------------------------------
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

local path, write, created = {}, {}, {}

function CreateClientConVar( cvar, value, data, save )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.CreateClientConVar( cvar, value, data, save ) end
	if ( ( created[ cvar ] != nil ) || ( Hermes.getcvars[ cvar ] != nil ) ) then
		return GetConVar( cvar )
	end
	
	created[ cvar ] = true
	return Hermes.copy.CreateClientConVar( cvar, value, data, save )
end

function GetConVar( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.GetConVar( cvar ) end
	
	if ( Hermes.getcvars[ cvar ] ) then return end
	return Hermes.copy.GetConVar( cvar )
end

function ConVarExists( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.ConVarExists( cvar ) end
	
	if ( Hermes.getcvars[ cvar ] ) then return false end
	return Hermes.copy.ConVarExists( cvar )
end

function GetConVarNumber( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.GetConVarNumber( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar ), v.ConVar ) ) then
			return tonumber( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ cvar ] ) then return end
	return Hermes.copy.GetConVarNumber( cvar )
end

function GetConVarString( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.GetConVarString( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar ), v.ConVar ) ) then
			return tostring( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ cvar ] ) then return end
	return Hermes.copy.GetConVarString( cvar )
end

function file.CreateDir( dir )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.CreateDir( dir ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( dir ), v ) ) then
			path[ dir ] = true
			return
		end
	end
	return Hermes.copy.file.CreateDir( dir )
end

function file.Delete( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Delete( name ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			write[ name ] = nil
			return
		end
	end
	return Hermes.copy.file.Delete( name )
end

function file.Read( name, folder )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Read( name, folder ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && write[path].cont || nil
		end
	end
	return Hermes.copy.file.Read( name, folder )
end

function file.Exists( name, folder )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Exists( name, folder ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && true || false
		end
	end
	return Hermes.copy.file.Exists( name, folder )
end

function file.ExistsEx( name, folder )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Exists( name, folder ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && true || false
		end
	end
	return Hermes.copy.file.ExistsEx( name, folder )
end

function file.Write( name, folder, ... )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Write( name, folder, ... ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return nil
		end
	end
	return Hermes.copy.file.Write( name, folder, ... )
end

function file.Time( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Time( name ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && write[path].time || 0
		end
	end
	return Hermes.copy.file.Time( name )
end

function file.Size( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Size( name ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && write[path].size || -1
		end
	end
	return Hermes.copy.file.Size( name )
end

function file.Find( name, path )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Find( name, path ) end
	
	local oldfind = Hermes.copy.file.Find( name, path )
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			if ( !write[ v ] ) then
				oldfind[ k ] = nil
				return
			end
		end
	end
	return Hermes.copy.file.Find( name, path )
end

function file.FindInLua( name )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.FindInLua( name ) end
	
	local oldfind = Hermes.copy.file.FindInLua( name )
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			oldfind[ k ] = nil
		end
	end
	return Hermes.copy.file.FindInLua( name )
end

function file.Rename( name, new )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.file.Rename( name, new ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			if ( write[ name ] ) then
				write[ new ] = table.Copy( write[ name ] )
				write[ path ] = nil
			end
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
					folder[ k ] = nil
				end
			end
			for k, v in pairs( files ) do
				if ( string.find( string.lower( name ), Hermes.files[ name ] ) ) then
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

function _R.ConVar.GetInt( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.GetInt( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar:GetName() ), v.ConVar ) ) then
			return tobool( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ cvar:GetName() ] ) then return end
	return Hermes.copy.GetInt( cvar )
end

function _R.ConVar.GetBool( cvar )
	local calldirectory = Hermes.copy.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.path ) then return Hermes.copy.GetBool( cvar ) end
	for k, v in pairs( Hermes.bypassedvars ) do
		if ( string.find( string.lower( cvar:GetName() ), v.ConVar ) ) then
			return tobool( v.Spoof )
		end
	end
	
	if ( Hermes.getcvars[ cvar:GetName() ] ) then return false end
	return Hermes.copy.GetBool( cvar )
end

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
				
			local cvar = string.lower( tostring( "Hermes_" .. v.Prefix .. n.ConVar .. endtext ) )
			local info
			
			local convar = CreateClientConVar( cvar, n.Value, true, false )
			
			if ( n.Type == "checkbox" ) then
				Hermes.features[ n.ConVar ] = tobool( convar:GetInt() )
				info = { ConVar = n.ConVar, Name = cvar, Value = tobool( convar:GetInt() ), Desc = n.Desc, Menu = u.Tab, Type = n.Type }
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
Hermes.HasWeapon = _R['Player'].GetWeapons

function Hermes:IsTroubleInTerroristTown()
	if ( string.find( string.lower( GAMEMODE.Name ), "trouble in terror" ) ) then 
		return true
	end
	return false
end

function Hermes.GetTraitors()
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
			Hermes.traitors = {} -- No need for this if I'm the traitor.
			Hermes.traitorsweapons = {}
			return true
		end
	end
	return false
end

/*----------------------------------------
	Nospread
	Desc: Seeds spread to zero.
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

function Hermes.Nospread( ucmd, angle )
	if ( !Hermes.features.nospread ) then return Angle( angle.p, angle.y, angle.r ) end
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
	return Hermes.sys.CompensateWeaponSpread( ucmd, Vector( -cone, -cone, -cone ) || 0, angle:Forward() || ply:GetAimVector():Angle() ):Angle()
end

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
			if ( table.HasValue( Hermes.friends, AddType( e ) ) && Hermes.features['friendslist'] ) then return false end
			if ( !e:Alive() ) then return false end
			if ( e:GetMoveType() == MOVETYPE_OBSERVER || e:GetMoveType() == MOVETYPE_NONE ) then return false end
			if ( string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
			if ( Hermes:IsTroubleInTerroristTown() && Hermes.IsTraitor( e ) && ( ply.IsTraitor && ply:IsTraitor() ) && Hermes.features['ignoretraitor'] ) then return false end
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
	
	local trace = { start = ply:GetShootPos(), endpos = e:EyePos(), filter = { ply, e }, mask = 1174421507 }
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
			Hermes.cmd.LocalCommand( "+duck" )
			timer.Simple( 0.1, function() Hermes.cmd.LocalCommand( "-duck" ) end )
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
	
	if ( !usingAttachments ) then
		for k, v in pairs( Hermes.modelbones ) do
			if ( v.Model == e:GetModel() ) then
				pos = Hermes:GetPos( e, v.Pos )
			end
		end
	end
	
	if ( Hermes.features['vectorstyle'] ) then
		pos = e:GetPos()
	end
	
	if ( Hermes.features['obbtargeting'] ) then
		pos = e:LocalToWorld( e:OBBCenter() )
	end
	
	pos = pos + Vector( 0, 0, tonumber( Hermes.features['offset'] ) )
	return Hermes:WeaponPrediction( e, pos )
end

-- Create a trace
function Hermes:Trace()
	local ply = LocalPlayer()
	local start, endP = ply:GetShootPos(), ply:GetAimVector()
	
	local trace = {}
	trace.start = start
	trace.endpos = start + ( endP * 16384 )
	trace.filter = { ply }
	trace.mask = MASK_SHOT //1174421507 
	
	return util.TraceLine( trace )
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

-- Create a trace
function Hermes:TargetVisible( e )
	local ply = LocalPlayer()
	
	local pos = Hermes:TargetLocation( e )
	if ( Hermes.features['prediction'] ) then
		pos = pos + ( e:GetVelocity() / tonumber( Hermes.features['predicttar'] ) - ply:GetVelocity() / tonumber( Hermes.features['predictply'] ) )
	end
	
	local trace = { 
		start = ply:GetShootPos(), 
		endpos = pos, 
		filter = { ply, e }, 
		mask = MASK_SHOT //1174421507 
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
				table.insert( targets, e )
			end
		end
	end
	return targets
end

-- Find best target
function Hermes:GetTarget()
	local x, y = ScrW(), ScrH()
	local ply, targets = LocalPlayer(), Hermes:GetTargets()
	
	if ( table.Count( targets ) == 0 ) then return end
	
	Hermes.set.tar = ply
	for i = 1, table.Count( targets ) do
		local e = targets[i]
		
		local ePos, oldPos, myAngV = e:EyePos():ToScreen(), Hermes.set.tar:EyePos():ToScreen(), ply:GetAngles()
		
		local angle = ( e:GetPos() - ply:GetShootPos() ):Angle()
		local angleY = math.abs( math.NormalizeAngle( myAngV.y - angle.y ) )
		local angleP = math.abs( math.NormalizeAngle( myAngV.p - angle.p ) )
		
		if ( angleY < tonumber( Hermes.features.fov ) && angleP < tonumber( Hermes.features.fov ) ) then
		
			local angA, angB = 0
			angA = math.Dist( x / 2, y / 2, oldPos.x, oldPos.y )
			angB = math.Dist( x / 2, y / 2, ePos.x, ePos.y )
			

			if ( angB <= angA ) then
				Hermes.set.tar = e
			elseif ( Hermes.set.tar == ply ) then
				Hermes.set.tar = e
			end
			
			if ( Hermes.features['velocitychecks'] && Hermes.set.tar:GetVelocity():Length() == 0 && e:GetVelocity():Length() != 0 ) then
				Hermes.set.tar = e
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
	
		local t = Hermes:Trace()
		
		if ( Hermes:ValidTarget( t.Entity, "aim" ) ) then
		
		local pos = ply:GetPos():Distance( t.Entity:GetPos() ) / 4
		if ( ( tonumber( Hermes.features['triggerdistance'] ) > pos ) || ( tonumber( Hermes.features['triggerdistance'] ) == 0 ) ) then
				ucmd:SetButtons( ucmd:GetButtons() | IN_ATTACK )
				timer.Simple( 0.1, function() Hermes.cmd.LocalCommand( "-attack" ) end )
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
	
	if ( !Hermes.set.aiming ) then
		ucmd:SetViewAngles( Hermes.set.angles )
	end
	
	Hermes.set.fakeang = Hermes.set.angles
	if ( Hermes.features['constantnospread'] && ( ucmd:GetButtons() & IN_ATTACK > 0 ) ) then
		Hermes.set.fakeang = Hermes.Nospread( ucmd, Hermes.set.angles )
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
		compensate = compensate + ( tar:GetVelocity() / tonumber( Hermes.features['predicttar'] ) - ply:GetVelocity() / tonumber( Hermes.features['predictply'] ) )
	end
	
	local angles = ""
	if ( Hermes.features['silentaim'] ) then
		local fake = ( compensate - ply:GetShootPos() ):Angle()
		fake = Hermes.SmoothAngles( fake )
		angles = Hermes.Nospread( ucmd, fake )
	else
		Hermes.set.angles = ( compensate - ply:GetShootPos() ):Angle()
		Hermes.set.angles = Hermes.SmoothAngles( Hermes.set.angles )
		angles = Hermes.Nospread( ucmd, Hermes.set.angles )
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
	
	if ( Hermes.features['autoshoot'] ) then
		Hermes.cmd.LocalCommand( "+attack" )
		timer.Simple( 0.01, function() Hermes.cmd.LocalCommand( "-attack" ) end )
	end
end
Hermes:AddHook( "CreateMove", Hermes.Aim )

-- Remove recoil and create zoom hack
function Hermes.NoRecoil( ply, origin, angles, FOV )
	if ( !Hermes.features['norecoil'] ) then return end
	local ply, zoomFOV = LocalPlayer(), FOV
	local wep = ply:GetActiveWeapon()
	
	if ( wep.Primary ) then wep.Primary.Recoil = 0 end
	if ( wep.Secondary ) then wep.Secondary.Recoil = 0 end
	
	Hermes.zooming = false
	if ( Hermes.features['zoomalways'] ) then Hermes.zooming = true end
	if ( Hermes.features['zoomonaim'] && Hermes.set.aiming ) then Hermes.zooming = true end
	if ( Hermes.features['zoomontrigger'] && Hermes.set.trigger ) then Hermes.zooming = true end
	
	Hermes.zoomspeed = tonumber( Hermes.features['zoomamount'] )
	
	if ( Hermes.features['zoom'] && Hermes.zooming ) then
		zoomFOV = ( 90 / ( 1 + ( 1 * Hermes.zoomspeed ) ) )
	else zoomFOV = FOV end
	
	if ( Hermes.prop.enable ) then
		zoomFOV = Hermes.prop.ang
	end
	
	local view = GAMEMODE:CalcView( ply, origin, Hermes.set.angles, zoomFOV ) || {}
	view.angles = Hermes.set.angles
	view.angles.r = 0
	view.fov = zoomFOV
	return view
end
Hermes:AddHook( "CalcView", Hermes.NoRecoil )

-- Add commands
Hermes:AddCommand( "+hermes_aim", function() Hermes.set.aiming = true; Hermes.set.target = nil end )
Hermes:AddCommand( "-hermes_aim", function() Hermes.set.aiming = false; Hermes.set.target = nil end )

Hermes:AddCommand( "+hermes_trigger", function() Hermes.set.trigger = true end )
Hermes:AddCommand( "-hermes_trigger", function() Hermes.set.trigger = false end )

Hermes:AddCommand( "+hermes_propkill", function() Hermes.prop.enable = true end )
Hermes:AddCommand( "-hermes_propkill", function() Hermes.prop.enable = false; Hermes.prop.thrown = true end )

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

function Hermes.Ignorelist()
	if ( !Hermes.features['ignorelist'] ) then return end
	
	local ply, text, textnum = LocalPlayer(), "Ignore-list: ", 0
	for k, e in ipairs( player.GetAll() ) do
		if ( e == ply ) then
		elseif ( e:GetFriendStatus() == "friend" && Hermes.features['ignoresteam'] ) then
			text = text .. e:Nick() .. "\n"
			textnum = textnum + 1
		elseif ( e:Team() == ply:Team() && Hermes.features['ignoreteam'] ) then
			text = text .. e:Nick() .. "\n"
			textnum = textnum + 1
		elseif ( e:IsAdmin() && Hermes.features['ignoreadmin'] ) then
			text = text .. e:Nick() .. "\n"
			textnum = textnum + 1
		elseif ( table.HasValue( Hermes.friends, AddType( e ) ) && Hermes.features['friendslist'] ) then
			text = text .. e:Nick() .. "\n"
			textnum = textnum + 1
		end
	end
	
	if ( textnum == 0 ) then
		text = "Ignore-list: Not ignoring anything."
	end
	
	local num, pos = string.Explode( "\n", text ), 0
	for i = 1, table.Count( num ) do
		draw.SimpleText(
			num[ i ],
			"TabLarge",
			100,
			100 + pos,
			Color( 255, 255, 255, 255 ),
			0,
			0
		)
		pos = pos + 12
	end
end

/*----------------------------------------
	Adminlist
	Desc: Displays all the admins on the server.
*/----------------------------------------
function Hermes:IsAdmin(e)
	
	if ( e.IsAdmin && e:IsAdmin() ) then 
		return true
	elseif ( e.IsSuperAdmin && e:IsSuperAdmin() ) then 
		return true
	end
	return false
end

function Hermes:GetAdminType(e)

	local ply = LocalPlayer()
	
	if ( e:IsAdmin() && !e:IsSuperAdmin() ) then
		return "Admin"
	elseif ( e:IsSuperAdmin() ) then
		return "Super Admin"
	end
	return ""
end

function Hermes:Adminlist()
	if ( !Hermes.features['adminlist'] ) then return end
	
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
		
	draw.RoundedBox( 0, posX - ( wide / 2 ), posY - 10, 300, tall, Color( 0, 0, 0, 150 ) )
	
	admin = "Admins: " .. admin
	local num, pos = string.Explode( "\n", admin ), 0
	for i = 1, table.Count( num ) do
		draw.SimpleText(
			num[ i ],
			"Default",
			posX,
			posY + pos,
			Color( 0, 255, 0, 255 ),
			1,
			1
		)
		pos = pos + 12
	end
end

/*----------------------------------------
	Terror-town HUD
	Desc: Displays traitors and detectives.
*/----------------------------------------
function Hermes.TerrorTownHUD()
	if ( !Hermes:IsTroubleInTerroristTown() ) then return end
	if ( !Hermes.features['ttthud'] ) then return end
	
	local t, d, tn, dn = "", "", 0, 0
	
	for k, e in ipairs( player.GetAll() ) do
		if ( e.IsDetective && e:IsDetective() ) then d = d .. e:Nick() .. ", "; dn = dn + 1 end
		if ( ( e.IsTraitor && e:IsTraitor() ) || IsTraitor( e ) ) then t = t .. e:Nick() .. ", "; tn = tn + 1 end
	end
	
	if ( dn == 0 ) then d = "No detectives." end
	if ( tn == 0 ) then t = "No traitors detected yet." end
	
	draw.SimpleText(
		"Traitors: " .. t,
		"TabLarge",
		100,
		20,
		Color( 255, 0, 0, 255 ),
		0,
		0
	)
	
	draw.SimpleText(
		"Detectives: " .. d,
		"TabLarge",
		100,
		35,
		Color( 0, 0, 255, 255 ),
		0,
		0
	)
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

function Hermes:HealthBar( e )
	if ( e:IsPlayer() && ( e:Health() > 300 || !e:Alive() ) ) then return end
	local pos = e:GetPos()
	
	local col
	if ( e:Health() > 50 ) then
		col = Color( 255, 242, 0, 255 )
	elseif ( e:Health() > 20 ) then
		col = Color( 255, 0, 0, 255 )
	else
		col = Color( 0, 255, 0, 255 )
	end
	
	local normalhp = 100
	
	if( e:Health() > normalhp ) then
		normalhp = e:Health()
	end
	
	local dmg, nor = normalhp / 4, e:Health() / 4
	
	pos.x = pos.x - ( dmg / 2 )
	pos.y = pos.y + 15
	
	Hermes:DrawRect( pos.x - 1, pos.y - 1, dmg + 2, 4 + 2, Color( 0, 0, 0, 255 ) )
	Hermes:DrawRect( pos.x, pos.y, nor, 4, col )
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
		if ( Hermes.features['box'] ) then
			box = true
		end
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		local added = 0
		if ( Hermes.features['name'] ) then
			text = text .. e:Nick()
			added = added + 1
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

function Hermes.HUD()
	local ply = LocalPlayer()
	
	for k, e in ipairs( ents.GetAll() ) do
		// Entities
		if ( Hermes:ValidTarget( e, "esp" ) && !e:IsPlayer() ) then
			local text, box, col, posX, posY, maxX, minX, maxY, minY, Xalign, Yalign = Hermes:Filter( e )
			
			if ( ( e:IsPlayer() || e:IsNPC() ) && box ) then
				Hermes:BoundingBox( e, col )
			elseif ( box ) then
				surface.SetDrawColor( col )
				
				surface.DrawLine( maxX, maxY, maxX, minY )
				surface.DrawLine( maxX, minY, minX, minY )
				
				surface.DrawLine( minX, minY, minX, maxY )
				surface.DrawLine( minX, maxY, maxX, maxY )
			end
			
			local textLength, pos = string.Explode( "\n", text ), 0
			
			for i = 1, table.Count( textLength ) do
				draw.SimpleText(
					textLength[ i ],
					"TabLarge",
					posX,
					posY + pos,
					col,
					Xalign,
					Yalign
				)
				pos = pos + 12
			end
		end
	end
	
	for k, e in ipairs( ents.GetAll() ) do
		// Player
		if ( Hermes:ValidTarget( e, "esp" ) && e:IsPlayer() ) then
			local text, box, col, posX, posY, maxX, minX, maxY, minY, Xalign, Yalign = Hermes:Filter( e )
			
			if ( ( e:IsPlayer() || e:IsNPC() ) && box ) then
				Hermes:BoundingBox( e, col )
			elseif ( box ) then
				surface.SetDrawColor( col )
				
				surface.DrawLine( maxX, maxY, maxX, minY )
				surface.DrawLine( maxX, minY, minX, minY )
				
				surface.DrawLine( minX, minY, minX, maxY )
				surface.DrawLine( minX, maxY, maxX, maxY )
			end
			
			local textLength, pos = string.Explode( "\n", text ), 0
			
			for i = 1, table.Count( textLength ) do
				draw.SimpleText(
					textLength[ i ],
					"TabLarge",
					posX,
					posY + pos,
					col,
					Xalign,
					Yalign
				)
				pos = pos + 12
			end
		end
	end
	
	if ( Hermes.features['crosshair'] ) then
		local g = 5; local s, x, y, l = 5, ( ScrW() / 2 ), ( ScrH() / 2 ), g + 15
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		surface.DrawLine( x - l, y, x - g, y )
		surface.DrawLine( x + l, y, x + g, y )
		
		surface.DrawLine( x, y - l, x, y - g )
		surface.DrawLine( x, y + l, x, y + g )
	end
	
	Hermes.TerrorTownHUD()
	Hermes.Ignorelist()
	Hermes:Adminlist()
	Hermes.ToggleHUD()
end
Hermes:AddHook( "HUDPaint", Hermes.HUD )

/*----------------------------------------
	Proxy
	Desc: Makes all models transparent.
*/----------------------------------------
function Hermes.Proxy()
	local ent, ply, c = ents.GetAll(), LocalPlayer(), ( 1 / 255 )
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		if ( ValidEntity( e ) && !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() ) then
			if ( Hermes.features['proxymdls'] && ( string.sub( ( e:GetModel() || "" ), -3 ) == "mdl" ) ) then
				if ( Hermes.features['proxy'] ) then
					e:SetColor( 255, 255, 255, tonumber( Hermes.features['proxyvalue'] ) )
				else
					e:SetColor( 255, 255, 255, 255 )
				end
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
	
	local mat = CreateMaterial( "hermes_createmat_solid", "VertexLitGeneric", BaseInfo )
	if ( Hermes.features['wireframe'] ) then
		mat = CreateMaterial( "hermes_createmat_wireframe", "Wireframe", BaseInfo )
	end
	
	return mat
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

function Hermes.Chams()
	local ply, c = LocalPlayer(), ( 1 / 255 )
	local mat = Hermes:CreateMaterial()
	
	for k, e in ipairs( ents.GetAll() ) do
		if ( Hermes:ValidTarget( e, "chams" ) ) then
			if ( !Hermes.features.xqz ) then
				local isVis, notVis = Hermes:FilterColorsChams( e )
				cam.Start3D( EyePos(), EyeAngles() )
					render.SuppressEngineLighting( tobool( Hermes.features['fullbright'] ) )
					render.SetColorModulation( ( notVis.r * c ), ( notVis.g * c ), ( notVis.b * c ) )
					SetMaterialOverride( mat )
					e:DrawModel()
					render.SuppressEngineLighting( false )
					if ( Hermes.features['visiblechams'] ) then
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
end

function Hermes.RenderScreenspaceEffects()
	Hermes.Chams()
	Hermes.Proxy()
end
Hermes:AddHook( "RenderScreenspaceEffects", Hermes.RenderScreenspaceEffects )

function Hermes.SeconedChams()
	local mat = "hermes/living"
	if ( Hermes.features['wireframe'] ) then
		mat = "hermes/wireframe"
	end
	for k, e in ipairs( ents.GetAll() ) do
		if ( Hermes:ValidTarget( e, "chams" ) ) then
			if ( !Hermes.features['xqz'] && Hermes.features['visiblechams'] ) then
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
function Hermes.EnabledSpeed()
	if ( Hermes.features['speedhack'] ) then
		RunConsoleCommand( "hermes_host_timescale", tonumber( Hermes.features['speedhackspeed'] ) )
	end
end

function Hermes.DisableSpeed()
	RunConsoleCommand( "hermes_host_timescale", 1.0 )
end

Hermes:AddCommand( "+hermes_speed", function() Hermes.EnabledSpeed() end )
Hermes:AddCommand( "-hermes_speed", function() Hermes.DisableSpeed() end )

/*----------------------------------------
	Globals
	Desc: No-sky, fullbright...
*/----------------------------------------
function Hermes.Nosky()
	local vars = {
		{ Table = "nosky", ON = "gl_clear 1; r_skybox 0; r_3dsky 0", OFF = "r_skybox 1; r_3dsky 1" },
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
	Desc: ULX anti-gag, create by seth but simple so yeah.
*/----------------------------------------
function Hermes.Tick()
	if ( ulx && ulx['gagUser'] ) then
		if ( Hermes.features['ulxantigag'] ) then
			ulx['gagUser']( false )
		end
	end
end
Hermes:AddHook( "Tick", Hermes.Tick )

/*----------------------------------------
	IP Address logger
	Desc: Logs all IP's from joing players.
*/----------------------------------------
--[[
function Hermes.IPLogger( name, ip )
	Hermes.ips[ string.gsub( name, "=", "" ) ] = ip
	
	-- Get SteamID
	local steamid = "none"
	for k, e in pairs( player.GetAll() ) do
		if ( !e:IsBot() && ( e:Nick() == name ) ) then
			steamid = ( e.SteamID && e:SteamID() || "none" )
		end
	end
	
	local str = ""
	for k, v in pairs( Hermes.ips ) do
		str = str .. k .. "=" .. v .. "=" .. steamid .. "\n"
	end
	file.Write( "hermes_lists_ips.txt", str )
	
	MsgN( "[Hermes]: Logged ip '" .. tostring( ip ) .. "' from player '" .. tostring( name ) .. "'." )
end
Hermes:AddHook( "PlayerConnect", Hermes.IPLogger )

Hermes.steamid = {}
function Hermes.LoadIPs()
	local info = string.Explode( "\n", file.Read( "hermes_lists_ips.txt" ) || "" )
	
	Hermes.ips = {}
	for k, v in pairs( info ) do
		local str = string.Explode( "=", v )
		if ( str && table.getn( str ) == 3 ) then
			Hermes.ips[ str[1] ] = str[2]
			if ( str[3] ) then
				Hermes.steamid[ str[1] ] = str[3]
			end
		end
	end
end
Hermes.LoadIPs()
]]
/*----------------------------------------
	Name Stealer
	Desc: Steal peoples names.
*/----------------------------------------
function Hermes.NameSteal()
	local ply = LocalPlayer()
	
	local e = player.GetAll()[ math.random( 1, #player.GetAll() ) ]
	if ( Hermes.features['namesteal'] ) then
		if ( !e:IsAdmin() && e != ply ) then
			Hermes.cmd.LocalCommand( "name " .. e:Nick() .. "~ ~~" )
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
end

Hermes:AddHook( "Think", Hermes.Think )

/*----------------------------------------
	Menu
	Desc: A cool menu
*/----------------------------------------
function Hermes:CheckBox( cvar, desc )
	local checkbox = vgui.Create( "DCheckBoxLabel" )
	checkbox:SetText( desc )
	checkbox:SetValue( GetConVarNumber( cvar ) )
	checkbox:SetTextColor( Color( 0, 0, 0, 255 ) )
		
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
	label:SetTextColor( Color( 0, 0, 0, 255 ) )
			
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

--[[function Hermes.IPLoggerMenu( ipparent )
	Hermes.LoadIPs()
	-- Main
	local ipmenu = nil
	local function IP()
		ipmenu = vgui.Create( "DListView" )
		ipmenu:SetParent( ipparent )
		ipmenu:SetPos( 10, 10 )
		ipmenu:SetSize( 450 - 40, 350 - 110 )
		ipmenu:SetMultiSelect( false )
	
		ipmenu:AddColumn( "Name" )
		ipmenu:AddColumn( "IP Address" )
	
		for k, v in pairs( Hermes.ips ) do
			ipmenu:AddLine( k, v )
		end
	end
	IP()
	
	-- Double click
	ipmenu.DoDoubleClick = function( parent, index, lists )
		local panel = vgui.Create( "DFrame" )
		panel:SetPos( ScrW() / 2 - 300 / 2, ScrH() / 2 - 200 / 2 )
		panel:SetSize( 300, 200 )
		panel:SetTitle( "Search for player '" .. lists:GetValue( 1 ) .. "'" )
		panel:SetVisible( true )
		panel:SetDraggable( true )
		panel:ShowCloseButton( true )
		panel:MakePopup()
		
		local searchlist = vgui.Create( "DListView" )
		searchlist:SetParent( panel )
		searchlist:SetPos( 10, 30 )
		searchlist:SetSize( 300 - 20, 200 - 45 )
		searchlist:SetMultiSelect( false )
		
		searchlist:AddColumn( "Name" )
		searchlist:AddColumn( "IP Address" )
		
		local added = {}
		for k, v in pairs( Hermes.ips ) do
			for u, e in pairs( Hermes.steamid ) do
				if ( e == e && !table.HasValue( added, k ) ) then
					searchlist:AddLine( k, v )
					table.insert( added, k )
				end
			end
		end
	end
	
	-- Textbox
	local textbox = vgui.Create( "TextEntry" )
	textbox:SetParent( ipparent )
	textbox:SetSize( 330, 20 ) 
	textbox:SetPos( 90, 350 - 90 )
	
	-- Button
	local button = vgui.Create( "DButton" )
	button:SetParent( ipparent )
	button:SetText( "Search" )
	button:SetSize( 70, 20 )
	button:SetPos( 10, 350 - 90 )
	
	button.DoClick = function()
		if ( textbox && textbox:GetValue() == "" ) then MsgN( "No text!" ) return end
		local panel = vgui.Create( "DFrame" )
		panel:SetPos( ScrW() / 2 - 300 / 2, ScrH() / 2 - 200 / 2 )
		panel:SetSize( 300, 200 )
		panel:SetTitle( "Search for '" .. textbox:GetValue() .. "'" )
		panel:SetVisible( true )
		panel:SetDraggable( true )
		panel:ShowCloseButton( true )
		panel:MakePopup()
		
		local searchlist = vgui.Create( "DListView" )
		searchlist:SetParent( panel )
		searchlist:SetPos( 10, 30 )
		searchlist:SetSize( 300 - 20, 200 - 45 )
		searchlist:SetMultiSelect( false )
		
		searchlist:AddColumn( "Name" )
		searchlist:AddColumn( "IP Address" )
		
		for k, v in pairs( Hermes.ips ) do
			if ( string.find( string.lower( k ), string.lower( textbox:GetValue() ) ) ) then
				searchlist:AddLine( k, v )
			end
		end
	end
end]]
	
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

function Hermes.Menu()
	local panel = vgui.Create( "DFrame" )
	panel:SetPos( ScrW() / 2 - 450 / 2, ScrH() / 2 - 350 / 2 )
	panel:SetSize( 450, 350 )
	panel:SetTitle( "Hermes" )
	panel:SetVisible( true )
	panel:SetDraggable( true )
	panel:ShowCloseButton( true )
	panel:MakePopup()
	panel.Close = function()
		panel:SetVisible( false )
	end
	
	if ( !panel:IsVisible() || panel == nil ) then return end
	
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
				{ [6] = "Players" },
				{ [7] = "NPCs" },
				{ [8] = "Entities" },
				{ [9] = "Chams" },
				{ [10] = "Proxy" },
			}
		},
		
		{ Tab = "Miscellaneous", Icon = "gui/silkicons/plugin", Contents = {
				{ [11] = "Miscellaneous" },
				{ [12] = "Globals" },
				{ [13] = "Speedhack" },
				{ [14] = "Zoom" },
				{ [15] = "AntiAim" },
			}
		},
	}
	
	local propertysheet = vgui.Create( "DPropertySheet" )
	propertysheet:SetParent( panel )
	propertysheet:SetPos( 5, 30 )
	propertysheet:SetSize( 440, 315 )
	
	local friends = vgui.Create( "DPanel", propertysheet )
	local entity = vgui.Create( "DPanel", propertysheet )
	//local ipparent = vgui.Create( "DPanel", propertysheet )
	
	Hermes.System( friends, entity )
	//Hermes.IPLoggerMenu( ipparent )
	
	local lists, collapsiblecategory, categorylist, dlist = {}, {}, {}, {}
	for k, v in ipairs( Include ) do
		lists[ v.Tab ] = vgui.Create( "DPanelList" )
		lists[ v.Tab ]:SetPos( 10, 30 )
		lists[ v.Tab ]:SetParent( panel )
		lists[ v.Tab ]:SetSize( 440 - 15, 320 - 10 )
		lists[ v.Tab ]:EnableVerticalScrollbar( true )
		lists[ v.Tab ]:SetSpacing( 5 )
		lists[ v.Tab ].Paint = function() end
	end
	
	local a = 1
	for k, v in ipairs( Include ) do
		propertysheet:AddSheet( v.Tab, lists[ v.Tab ], v.Icon, false, false, nil )
		
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
		elseif ( v.Type == "slider" ) then
			local slider = Hermes:NumSlider( v.Name, v.ConVar, v.Desc, v.Max || 1, v.Min || 0, v.Decimal )
			AddItem( slider, v.Menu )
		end
	end
	
	propertysheet:AddSheet( "Friends List", friends, "gui/silkicons/group", false, false, nil )
	propertysheet:AddSheet( "Entities List", entity, "gui/silkicons/star", false, false, nil )
	--propertysheet:AddSheet( "IP Logger", ipparent, "gui/silkicons/bomb", false, false, nil )
end
Hermes:AddCommand( "hermes_menu", function() Hermes.Menu() end )