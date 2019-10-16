/*------------------------------------------------------------------------------------------------------
   __ __                        
  / // /___  ____ __ _  ___  ___
 / _  // -_)/ __//  ' \/ -_)(_-<
/_//_/ \__//_/  /_/_/_/\__//___/
Hermes :: GMOD Edition
*/------------------------------------------------------------------------------------------------------
if !( CLIENT ) then return end

MsgN( [[_
       / /\
      / / /
     / / /   _
    /_/ /   / /\
    \ \ \  / /  \
     \ \ \/ / /\ \
  _   \ \ \/ /\ \ \
/_/\   \_\  /  \ \ \
\ \ \  / /  \   \_\/  
 \ \ \/ / /\ \ 
  \ \ \/ /\ \ \
   \ \  /  \ \ \
    \_\/   / / /
          / / /
         /_/ /
         \_\/
Hermes Loaded
]] )

//------------------------------
// Tables:
//------------------------------

local Hermes 					= {}
Hermes.features					= {}
Hermes.commands					= {}
Hermes.hooks					= {}
Hermes.old						= {}
Hermes.getallcvars				= {}
Hermes.loaded					= {}
Hermes.detours					= {}
Hermes.binarymodules			= {}
Hermes.metatables				= {}

Hermes.old.GetConVar			= GetConVar
Hermes.old.ConVarExists			= ConVarExists
Hermes.old.GetConVarNumber		= GetConVarNumber
Hermes.old.GetConVarString		= GetConVarString
Hermes.old.engineConsoleCommand = engineConsoleCommand
Hermes.old.require				= require
Hermes.old.CreateClientConVar 	= CreateClientConVar
Hermes.old.GetConVar			= GetConVar
Hermes.old.hook					= table.Copy( hook )
Hermes.old.cvars				= table.Copy( cvars )
Hermes.old.file					= table.Copy( file )
Hermes.old.debug				= table.Copy( debug )
Hermes.old.ConCommand			= _R.Player.ConCommand
Hermes.old.GetAngles			= _R.Player.GetAngles
Hermes.old.GetInt				= _R.ConVar.GetInt
Hermes.old.GetBool				= _R.ConVar.GetBool
Hermes.old.setmetatable 		= setmetatable
Hermes.old.getmetatable 		= getmetatable

Hermes.files					= { "gmcl_sys", "hermes_cvar", "hermes_mat_solid", "hermes_mat_wireframe", "hermes" }
Hermes.friends					= ( file.Exists( "hermes_lists_friends.txt" ) && KeyValuesToTable( file.Read( "hermes_lists_friends.txt" ) ) || {} )
Hermes.entities					= ( file.Exists( "hermes_lists_entities.txt" ) && KeyValuesToTable( file.Read( "hermes_lists_entities.txt" ) ) || {} )

Hermes.set = {
	targets = {},
	aiming = false,
	target = nil,
	tar = nil,
	angles = Angle( 0, 0, 0 ),
	fakeang = Angle( 0, 0, 0 ),
	path = "lua\\autorun\\client\\hermes.lua",
}

Hermes.deathsequences = {
	[ "models/barnacle.mdl" ] = { 4, 15 },
	[ "models/antlion_guard.mdl" ] = { 44 },
	[ "models/hunter.mdl" ] = { 124, 125, 126, 127, 128 }
}

Hermes.convars = {
	-- AIMBOT
	{ Name = "aim_aimbot_shoot", Value = 1, Desc = "Autoshoot", Type = "checkbox", Table = "autoshoot" },
	{ Name = "aim_triggerbot_trigger", Value = 0, Desc = "Triggerbot", Type = "checkbox", Table = "triggerbot" },
	{ Name = "aim_triggerbot_triggerkey", Value = 0, Desc = "Triggerbot Key", Type = "checkbox", Table = "triggerbotkey" },
	{ Name = "aim_triggerbot_triggerdistance", Value = 0, Desc = "Triggerbot Distance", Type = "slider", Table = "triggerbotdistance", Max = 10000, Min = 0 },
	{ Name = "aim_accuracy_recoil", Value = 1, Desc = "No-recoil", Type = "checkbox", Table = "norecoil" },
	{ Name = "aim_accuracy_spread", Value = 1, Desc = "No-spread", Type = "checkbox", Table = "nospread" },
	{ Name = "aim_accuracy_spread_constant", Value = 1, Desc = "Constant No-spread", Type = "checkbox", Table = "constantnospread" },
	{ Name = "aim_target_friendlyfire", Value = 0, Desc = "Friendly-fire", Type = "checkbox", Table = "friendlyfire" },
	{ Name = "aim_target_ignore_steam", Value = 0, Desc = "Ignore-steam", Type = "checkbox", Table = "ignoresteam" },
	{ Name = "aim_target_ignore_admins", Value = 0, Desc = "Ignore-admins", Type = "checkbox", Table = "ignoreadmins" },
	{ Name = "aim_target_player", Value = 1, Desc = "Target Players", Type = "checkbox", Table = "aimplayer" },
	{ Name = "aim_target_npc", Value = 1, Desc = "Target NPCs", Type = "checkbox", Table = "aimnpc" },
	{ Name = "aim_aimbot_disableafterkill", Value = 1, Desc = "Disable-after-kill", Type = "checkbox", Table = "disableafterkill" },
	{ Name = "aim_aimbot_silent", Value = 0, Desc = "Silent-aim", Type = "checkbox", Table = "silentaim" },
	{ Name = "aim_aimbot_aimline", Value = 0, Desc = "Aim-line", Type = "checkbox", Table = "aimline" },
	{ Name = "aim_aimbot_drawfov", Value = 0, Desc = "Draw-fov", Type = "checkbox", Table = "drawfov" },
	{ Name = "aim_aimbot_autoswitch", Value = 0, Desc = "Auto-switch", Type = "checkbox", Table = "autoswitch" },
	{ Name = "aim_aimbot_marktarget", Value = 0, Desc = "Mark-target", Type = "checkbox", Table = "marktarget" },
	{ Name = "aim_aimbot_togglehud", Value = 1, Desc = "Toggle HUD", Type = "checkbox", Table = "togglehud" },
	{ Name = "aim_aimbot_bonescan", Value = 0, Desc = "Bonescan", Type = "checkbox", Table = "bonescan" },
	{ Name = "aim_aimbot_visiblechecks", Value = 0, Desc = "Visible Checks", Type = "checkbox", Table = "visiblechecks" },
	{ Name = "aim_aimbot_prediction", Value = 1, Desc = "Prediction", Type = "checkbox", Table = "prediction" },
	{ Name = "aim_aimbot_vector", Value = 0, Desc = "Vectorbot", Type = "checkbox", Table = "vectorbot" },
	{ Name = "aim_aimbot_fov", Value = 20, Desc = "Field-of-view", Type = "slider", Table = "fov", Max = 360, Min = 0 },
	{ Name = "aim_aimbot_maxdistance", Value = 0, Desc = "Max-distance", Type = "slider", Table = "maxdistance", Max = 10000, Min = 0 },
	{ Name = "aim_aimbot_vector_offset", Value = 20, Desc = "Vectorbot Offset", Type = "slider", Table = "vectorbotoffset", Max = 50, Min = -50 },
	{ Name = "aim_aimbot_mode", Value = 1, Desc = "Aimmode", Type = "multichoice", Table = "mode" },
	
	-- ESP
	{ Name = "esp_players_enabled", Value = 1, Desc = "Enabled", Type = "checkbox", Table = "espplayer" },
	{ Name = "esp_players_enemyonly", Value = 1, Desc = "Enemy Only", Type = "checkbox", Table = "espplayerenemyonly" },
	{ Name = "esp_players_minteamesp", Value = 1, Desc = "Minimum Team ESP", Type = "checkbox", Table = "espplayerteamesp" },
	{ Name = "esp_players_name", Value = 1, Desc = "Name", Type = "checkbox", Table = "espplayername" },
	{ Name = "esp_players_health", Value = 1, Desc = "Health", Type = "checkbox", Table = "espplayerhealth" },
	{ Name = "esp_players_healthbar", Value = 0, Desc = "Healthbar", Type = "checkbox", Table = "espplayerhealthbar" },
	{ Name = "esp_players_weapon", Value = 0, Desc = "Weapon", Type = "checkbox", Table = "espplayerweapon" },
	{ Name = "esp_players_distance", Value = 0, Desc = "Distance", Type = "checkbox", Table = "espplayerdistance" },
	{ Name = "esp_players_box", Value = 0, Desc = "Box", Type = "checkbox", Table = "espplayerbox" },
	{ Name = "esp_players_skeleton", Value = 1, Desc = "Skeleton", Type = "checkbox", Table = "espplayerskeleton" },
	{ Name = "esp_players_barrel", Value = 1, Desc = "Barrel-hack", Type = "checkbox", Table = "espplayerbarrel" },
	{ Name = "esp_npcs_enabled", Value = 1, Desc = "Enabled", Type = "checkbox", Table = "espnpc" },
	{ Name = "esp_npcs_box", Value = 1, Desc = "Box", Type = "checkbox", Table = "espnpcbox" },
	{ Name = "esp_entities_enabled", Value = 0, Desc = "Enabled", Type = "checkbox", Table = "espentity" },
	{ Name = "esp_entities_weapons", Value = 1, Desc = "Weapons", Type = "checkbox", Table = "espentityweapon" },
	{ Name = "esp_entities_ragdolls", Value = 0, Desc = "Ragdolls", Type = "checkbox", Table = "espentityragdoll" },
	{ Name = "esp_entities_vehicles", Value = 0, Desc = "Vehicles", Type = "checkbox", Table = "espentityvehicle" },
	{ Name = "esp_entities_ammoboxes", Value = 0, Desc = "Ammo-boxes", Type = "checkbox", Table = "espentityammobox" },
	{ Name = "esp_entities_warnings", Value = 0, Desc = "Warnings", Type = "checkbox", Table = "espentitywarning" },
	{ Name = "esp_entities_box", Value = 0, Desc = "Box", Type = "checkbox", Table = "espentitybox" },
	{ Name = "esp_col_npc_e", Value = "255 0 0 255", Desc = "Enemy Color", Type = "color", Table = "enemyesp", MenuUse = NULL },
	{ Name = "esp_col_npc_a", Value = "0 255 0 255", Desc = "Alli Color", Type = "color", Table = "alliesp", MenuUse = NULL },
	{ Name = "esp_chams_enabled", Value = 1, Desc = "Enabled", Type = "checkbox", Table = "chamon" },
	{ Name = "esp_chams_players", Value = 1, Desc = "Players", Type = "checkbox", Table = "champlayer" },
	{ Name = "esp_chams_npcs", Value = 0, Desc = "NPCs", Type = "checkbox", Table = "chamnpc" },
	{ Name = "esp_chams_weapons", Value = 0, Desc = "Weapons", Type = "checkbox", Table = "chamweapon" },
	{ Name = "esp_chams_fullbright", Value = 0, Desc = "Fullbright", Type = "checkbox", Table = "chamfullbright" },
	{ Name = "esp_chams_proxy", Value = 0, Desc = "Proxy", Type = "checkbox", Table = "champroxy" },
	
	-- OTHER
	{ Name = "mis_misc_bhop", Value = 1, Desc = "Bunnyhop", Type = "checkbox", Table = "bunnyhop" },
	{ Name = "mis_misc_cross", Value = 1, Desc = "Crosshair", Type = "checkbox", Table = "crosshair" },
	{ Name = "mis_misc_speed", Value = 0, Desc = "Speedhack", Type = "checkbox", Table = "speedhack" },
	{ Name = "mis_misc_debug", Value = 1, Desc = "Debug Messages", Type = "checkbox", Table = "debug" },
	{ Name = "mis_misc_speedhackspeed", Value = 3, Desc = "Speed Amount", Type = "slider", Table = "speedhackspeed", Max = 10, Min = 2 },
}

//------------------------------
// Hooks:
//------------------------------
local oldCallHook = hook.Call

local function CallHook( name, gm, ... )
	if ( Hermes.hooks[ name ] ) then
		Hermes.old.hook.Call( name, gm, unpack( arg ) )
		return Hermes.hooks[ name ]( unpack( arg ) )
	end
	return Hermes.old.hook.Call( name, gm, unpack( arg ) )
end

hook = {}

// Set metatable for hooks
setmetatable( hook, 
	{ __index = function( t, k )
		if( k == "Call" ) then 
			return CallHook
		end
		return Hermes.old.hook[ k ] end,
		
		__newindex = function( t, k, v ) 
			if( k == "Call" ) then 
				if( v != CallHook ) then 
					oldCallHook = v 
				end 
				return
			end
			Hermes.old.hook[k] = v 
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
	return Hermes.old.engineConsoleCommand( p, c, a )
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
end
Hermes.ModuleCheck()

//------------------------------
// CVar Override:
//------------------------------
function Hermes:RequiredMessage( msg )
	return MsgN( "[Hermes]: " .. msg )
end

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

local path, write, created = {}, {}, {}

function GetConVar( cvar )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.GetConVar( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v.Name ) ) then
			return
		end
	end
	return Hermes.old.GetConVar( cvar )
end

function ConVarExists( cvar )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.ConVarExists( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v.Name ) ) then
			return false
		end
	end
	return Hermes.old.ConVarExists( cvar )
end

function GetConVarNumber( cvar )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.GetConVarNumber( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v.Name ) ) then
			return
		end
	end
	return Hermes.old.GetConVarNumber( cvar )
end

function GetConVarString( cvar )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.GetConVarString( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v.Name ) ) then
			return
		end
	end
	return Hermes.old.GetConVarString( cvar )
end

function file.CreateDir( dir )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.CreateDir( dir ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( dir ), v ) ) then
			path[ dir ] = true
			return
		end
	end
	return Hermes.old.file.CreateDir( dir )
end

function file.Delete( name )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Delete( name ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			write[ name ] = nil
			return
		end
	end
	return Hermes.old.file.Delete( name )
end

function file.Read( name, folder )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Read( name, folder ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && write[path].cont || nil
		end
	end
	return Hermes.old.file.Read( name, folder )
end

function file.Exists( name, folder )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Exists( name, folder ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && true || false
		end
	end
	return Hermes.old.file.Exists( name, folder )
end

function file.ExistsEx( name, folder )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Exists( name, folder ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && true || false
		end
	end
	return Hermes.old.file.ExistsEx( name, folder )
end

function file.Write( name, folder, ... )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Write( name, folder, ... ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return nil
		end
	end
	return Hermes.old.file.Write( name, folder, ... )
end

function file.Time( name )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Time( name ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && write[path].time || 0
		end
	end
	return Hermes.old.file.Time( name )
end

function file.Size( name )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Size( name ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			return write[path] && write[path].size || -1
		end
	end
	return Hermes.old.file.Size( name )
end

function file.Find( name, path )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Find( name, path ) end
	
	local oldfind = Hermes.old.file.Find( name, path )
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			if ( !write[ v ] ) then
				oldfind[ k ] = nil
			end
		end
	end
	return Hermes.old.file.Find( name, path )
end

function file.FindInLua( name )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.FindInLua( name ) end
	
	local oldfind = Hermes.old.file.FindInLua( name )
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			oldfind[ k ] = nil
		end
	end
	return Hermes.old.file.FindInLua( name )
end

function file.Rename( name, new )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.file.Rename( name, new ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( name ), v ) ) then
			if ( write[ name ] ) then
				write[ new ] = table.Copy( write[ name ] )
				write[ path ] = nil
			end
		end
	end
	return Hermes.old.file.Rename( name )
end

function file.TFind( name, call )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory ) then
		return Hermes.old.file.TFind( name, function( name, folder, files )
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
	return Hermes.old.file.TFind( name, function( path, folder, files ) 
		return call( path, folder, files )
	end )
end

function _R.ConVar.GetInt( cvar )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.GetInt( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar:GetName() ), v.Name ) ) then
			return nil
		end
	end
	return Hermes.old.GetInt( cvar )
end

function _R.ConVar.GetBool( cvar )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.GetBool( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar:GetName() ), v.Name ) ) then
			return false
		end
	end
	return Hermes.old.GetBool( cvar )
end

Hermes.loadedmodules = {}
function require( obj )
	table.insert( Hermes.loadedmodules, obj )
	return Hermes.old.require( obj )
end

Hermes:AddCommand( "hermes_loadedmodules", function()
	local text = ""
	for k, v in pairs( Hermes.loadedmodules ) do
		text = text .. tostring( v )
	end
	Hermes:RequiredMessage( "Added Module - " .. tostring( text )  )
end )
//------------------------------
// Metatable Override:
//------------------------------
Hermes.old.gmeta		= getmetatable( _G )
Hermes.old.hookmeta		= getmetatable( hook )

function setmetatable( t, m )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.setmetatable( t, m ) end
	if ( t == _G ) then
		return Hermes.old.gmeta
	elseif ( t == hook ) then
		return Hermes.old.hookmeta
	else
		return Hermes.old.setmetatable( t, m )
	end
	return t
end

function getmetatable( t )
	local calldirectory = Hermes.old.debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Hermes.set.path ) then return Hermes.old.getmetatable( t ) end
	if ( t == _G ) then
		return Hermes.old.gmeta
	elseif ( t == hook ) then
		return Hermes.old.hookmeta
	else
		return Hermes.old.getmetatable( t )
	end
end

debug.setmetatable = setmetatable
debug.getmetatable = getmetatable

//------------------------------
// Add Client Console Variables:
//------------------------------
Hermes.allcvarsadded = {}
for k, v in pairs( Hermes.convars ) do
	local cvar, name = CreateClientConVar( "hermes_" .. v.Name, v.Value, true, false ), ( "hermes_" .. v.Name )
	local info
	
	local menuItem = string.Explode( "_", tostring( v.Name ) )
	local tab = menuItem[2]
	
	if ( v.Type == "checkbox" ) then
		Hermes.features[ v.Table ] = tobool( cvar:GetInt() )
		info = { Name = name, Value = v.Value, Desc = v.Desc, Type = tab, Menu = v.Type }
	elseif ( v.Type == "slider" ) then
		Hermes.features[ v.Table ] = cvar:GetInt()
		info = { Name = name, Value = v.Value, Desc = v.Desc, Type = tab, Menu = v.Type, Max = v.Max, Min = v.Min }
	elseif ( v.Type == "multichoice" ) then
		print( "THIS" )
		Hermes.features[ v.Table ] = cvar:GetInt()
		info = { Name = name, Value = v.Value, Desc = v.Desc, Type = tab, Menu = v.Type, Item = v.Items }
	elseif ( v.Type == "color" ) then
		Hermes.features[ v.Table ] = tostring( cvar:GetString() )
		info = { Name = name, Value = v.Value, Desc = v.Desc, Type = tab, Menu = v.Type }
	end
		
	table.insert( Hermes.allcvarsadded, v.Name )
	
	Hermes.getallcvars[ name ] 						= info
	Hermes.getallcvars[ #Hermes.getallcvars + 1 ]	= info
	Hermes.old.cvars.AddChangeCallback( name, function( cvar, old, new )
		if ( v.Type == "checkbox" ) then
			Hermes.features[ v.Table ] = tobool( math.floor( new ) )
		else
			Hermes.features[ v.Table ] = new
		end
	end )
	print( "Added: '" .. name .. "' with the value '" .. cvar:GetInt() .. "'."  )
end

print( "You have '" .. table.Count( Hermes.allcvarsadded ) .. "' cvars added" )

function Hermes:SetValue( tbl, value )
	if ( Hermes.features[ tbl ] ) then
		Hermes.features[ tbl ] = tonumber( value )
	end
end

function Hermes:SetBool( tbl, value )
	if ( Hermes.features[ tbl ] ) then
		Hermes.features[ tbl ] = tobool( math.floor( value ) )
	end
end

function Hermes:GetColor( cvar )
	if ( ConVarExists( cvar ) ) then
		local col = string.Explode( " ", GetConVarString( cvar ) )
		return Color( col[1], col[2], col[3], col[4] )
	end
	return Color( 0, 0, 0, 255 )
end

function Hermes:Msg( msg )
	if ( !Hermes.features.debug ) then return end
	local message = tostring( msg )
	return MsgN( "[Hermes]: " .. message )
end

//------------------------------
// Traitor Detector:
//------------------------------
Hermes.traitorsweps = { "weapon_ttt_c4", "weapon_ttt_knife", "weapon_ttt_phammer", "weapon_ttt_sipistol", "weapon_ttt_flaregun", "weapon_ttt_push", "weapon_ttt_radio", "weapon_ttt_teleport" }
Hermes.tttmsg = false
Hermes.traitors = {}
Hermes.HasWeapon = _R['Player'].GetWeapons

function Hermes:IsTroubleInTerroristTown()
	if ( string.find( string.lower( GAMEMODE.Name ), "trouble in terror" ) ) then 
		return true
	end
	return false
end

function Hermes.GetTraitors()
	if ( Hermes:IsTroubleInTerroristTown() ) then
		if ( !Hermes.tttmsg ) then
			Hermes:RequiredMessage( "Trouble in Terrorist Town gamemode detected, using traitor detection method..." )
			Hermes.tttmsg = true
		end
		
		local ply, players = LocalPlayer(), player.GetAll()
		for i = 1, table.Count( players ) do
			local e = players[i]
			if ( ValidEntity( e ) && e != ply ) then
				local weps = Hermes.HasWeapon( e )
				for i = 1, table.Count( weps ) do
					local w = weps[i]
					if ( ValidEntity( w ) ) then
						if ( table.HasValue( Hermes.traitorsweps, w:GetClass() ) && !table.HasValue( Hermes.traitors, e ) ) then
							table.insert( Hermes.traitors, e )
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
	end
	
	return oldUserMSG( name, um, ... )
end

function IsTraitor( e )
	if ( table.HasValue( Hermes.traitors, e ) ) then
		return true
	end
	return false
end

//------------------------------
// Nospread:
//------------------------------
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
Cones.Weapons[ "weapon_pistol" ]			= { cone = WeaponVector( 0.0100, true, false ) }	// HL2 Pistol
Cones.Weapons[ "weapon_smg1" ]				= { cone = WeaponVector( 0.04362, true, false ) }	// HL2 SMG1
Cones.Weapons[ "weapon_ar2" ]				= { cone = WeaponVector( 0.02618, true, false ) }	// HL2 AR2
Cones.Weapons[ "weapon_shotgun" ]			= { cone = WeaponVector( 0.08716, true, false ) }	// HL2 SHOTGUN
Cones.Weapons[ "weapon_zs_zombie" ]			= { cone = WeaponVector( 0.0, true, false ) }		// REGULAR ZOMBIE HAND
Cones.Weapons[ "weapon_zs_fastzombie" ]		= { cone = WeaponVector( 0.0, true, false ) }		// FAST ZOMBIE HAND

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

local function GetCone( typ, v, i )
	local ply = LocalPlayer()
		if !( typ ) then return "NULL" end
		if ( typ[v] ) then return typ[v] end
		
		if ( Cones.GetCustom != -1 ) then
			return Cones.Custom[ Cones.GetCustom ].GetCone( typ, typ[ 'Primary' .. v ] )
		end
		if ( typ.Primary && typ.Primary[ v ] ) then
			return typ.Primary[ v ]
        end
		if ( typ[ "Primary" .. v ] ) then
			return typ[ "Primary" .. v ]
		end
		if ( typ[ "data" ] ) then
			for _, e in pairs( typ[ "data" ] ) do
				if ( ( type( e ) == "table" ) && e[ v ] ) then return e[v] end
			end
        end
        if ( typ.BaseClass && ( i || 0 ) < 10 ) then
			return GetCone( typ.BaseClass, v, ( i || 0 ) + 1 )
        end
	return nil
end

function Hermes.ConeThink()
	local ply = LocalPlayer()
	if ( !ValidEntity( ply ) || !ply:IsPlayer() ) then return end
	
	wep = ply:GetActiveWeapon()
		
	if !( wep ) then return end
		
	if ( wep != lastwep ) then
		lastwep = wep
		
		if ( wep && wep:IsValid() && table.HasValue( Cones.Banned, wep:GetClass() ) ) then
			cone = 0
			automatic = true
			
		elseif ( !wep || !wep:IsValid() || !wep && !wep:IsValid() ) then
			cone = 0
			automatic = true
			
		elseif ( wep && wep:IsValid() ) then
			local weptable = wep:GetTable()
				
			function weptable:ViewModelDrawn()
				if ( WinIsOn && OnViewModelRender ) then
					OnViewModelRender()
				end
			end
					
			local override = {}
			for c, s in pairs( Cones.Weapons ) do
				if ( string.match( string.lower( wep:GetClass() ), c ) ) then
					override = s
					break
				end
			end
			
			cone = ( override.cone || tonumber( GetCone( weptable, "Cone" ) ) || 0 )
			numshots = ( override.numshots || tonumber( GetCone( weptable, "NumShots" ) ) || 0 )
			
			if ( cone == nil || cone == 0 ) then
				cone = wep.Cone
			end
				
			inverse_vm_yaw = weptable.Base
			inverse_vm_pitch = override.inverse_vm_pitch
			strange_weapon = override.no_rapid
			muzzle = wep:LookupAttachment( "muzzle" )
				
			if ( override.automatic != nil ) then
				automatic = override.automatic
			else automatic = GetCone( weptable, "Automatic" ) end
				
			if ( weptable && weptable.Primary ) then end
			
		else
			cone = 0
			automatic = true
		end
	end
end

function Hermes.SeedSpread( ucmd, angle )
	Hermes.ConeThink()
	
	if ( cone == 0 ) then return end
	if ( Hermes.loaded.sys && Hermes.features.nospread ) then
		angle.p, angle.y = math.NormalizeAngle( angle.p ), math.NormalizeAngle( angle.y )
		
		local tCone = tonumber( cone )
		return Hermes.sys.CompensateWeaponSpread( ucmd, Vector( -tCone, -tCone, -tCone ), angle:Forward() ):Angle()
	end
	return angle
end

//------------------------------
// Entities Colors:
//------------------------------
local warnings = {
	"npc_grenade_frag",
	"crossbow_bolt",
	"roleplayg_missile",
	"grenade_ar2",
	"prop_combine_ball",
	"hunter_flechette",
	"ent_flashgrenade",
	"ent_explosivegrenade",
	"ent_smokegrenade"
}

local ammo = {
	"item_ammo_revolver_ttt",
	"item_ammo_357_ttt",
	"item_box_buckshot_ttt",
	"item_ammo_pistol_ttt",
}

local function IsAmmobox( e )
	if ( table.HasValue( ammo, e:GetClass() ) ) then
		return true
	end
	return false
end

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

local function IsWarning( e )
	if ( table.HasValue( warnings, e:GetClass() ) ) then
		return true
	end
	return false
end

function Hermes:OnScreen( e )
	local x, y, pos, pos2, pos3 = ScrW(), ScrH(), e:LocalToWorld( e:OBBMaxs() ):ToScreen(), e:LocalToWorld( e:OBBMins() ):ToScreen(), e:LocalToWorld( e:OBBCenter() ):ToScreen()
	if ( pos.x > 0 && pos.y > 0 && pos.x < x && pos.y < y || pos2.x > 0 && pos2.y > 0 && pos2.x < x && pos2.y < y || pos3.x > 0 && pos3.y > 0 && pos3.x < x && pos3.y < y ) then
		return true
	end
	return false
end

local drawText = surface.DrawText

--[[
Hermes.hasplayername = {}
function surface.DrawText( text )
	local ply = string.lower( LocalPlayer():Nick() )
	
	if ( string.find( string.lower( text ), ply ) ) then
		MsgN( "Text Found!" )
		return drawText( text )
	end
	return drawText( text )
end]]

//------------------------------
// Entity Colors:
//------------------------------
function Hermes:FilterColors( e )
	local col
	if ( e:IsPlayer() ) then
		if ( Hermes.features.marktarget && e == Hermes.set.target ) then
			col = Color( 255, 62, 158, 255 )
		elseif ( !IsTraitor( e ) ) then
			local tc = team.GetColor( e:Team() )
			col = Color( tc.r, tc.g, tc.b, 255 )
		elseif ( IsTraitor( e ) ) then
			col = Color( 255, 0, 0, 255 )
		end
	elseif ( e:IsNPC() ) then
		if ( !IsEnemyEntityName( e:GetClass() ) && !( e:GetClass() == "npc_metropolice" ) ) then
			col = Hermes:GetColor( "hermes_esp_col_npc_a" )
		elseif ( IsEnemyEntityName( e:GetClass() ) || ( e:GetClass() == "npc_metropolice" ) ) then
			col = Hermes:GetColor( "hermes_esp_col_npc_e" )
		end
	elseif ( e:IsWeapon() ) then
		if ( e:GetMoveType() == MOVETYPE_NONE ) then
			col = Color( 255, 255, 255, 255 )
		elseif ( e:GetMoveType() != MOVETYPE_NONE ) then
			col = Color( 215, 100, 0, 255 )
		end
	elseif ( IsAmmobox( e ) ) then
		col = Color( 0, 255, 255, 255 )
	elseif ( IsRagdoll( e ) ) then
		col = Color( 255, 255, 255, 255 )
	elseif ( IsVehicle( e ) ) then
		col = Color( 0, 128, 255, 255 )
	elseif ( IsWarning( e ) ) then
		col = Color( 128, 0, 0, 255 )
	end
	return col
end

//------------------------------
// Valid Entity:
//------------------------------
function Hermes:EnabledVar( e, typ )
	if ( !ValidEntity( e ) ) then return false end
	
	local ply = LocalPlayer()
	if ( typ == "aim" ) then
		if ( !e:IsPlayer() && !e:IsNPC() ) then return false end
		if ( e:IsPlayer() && !Hermes.features.aimplayer ) then return false end
		if ( e:IsNPC() && !Hermes.features.aimnpc ) then return false end
		if ( e:IsPlayer() ) then
			if ( !Hermes.features.friendlyfire && ply:Team() == e:Team() ) then return false end
			if ( Hermes.features.ignoresteam && e:GetFriendStatus() == "friend" ) then return false end
			if ( Hermes.features.ignoreadmins && ( e:IsAdmin() || e:IsSuperAdmin() ) ) then return false end
		end
		return true
	elseif ( typ == "other" ) then
		if ( !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !IsAmmobox( e ) && !IsRagdoll( e ) && !IsVehicle( e ) && !IsWarning( e ) ) then return false end
		if ( !Hermes:OnScreen( e ) ) then return false end
		if ( e:IsPlayer() && !Hermes.features.espplayer || e:IsPlayer() && ( Hermes.features.espplayerenemyonly || Hermes.features.espplayerteamesp ) && e:Team() == ply:Team() ) then return false end
		if ( e:IsNPC() && !Hermes.features.espnpc ) then return false end
		if ( e:IsWeapon() && !Hermes.features.espentityweapon ) then return false end
		if ( IsAmmobox( e ) && !Hermes.features.espentityammobox ) then return false end
		if ( IsRagdoll( e ) && !Hermes.features.espentityragdoll ) then return false end
		if ( IsVehicle( e ) && !Hermes.features.espentityvehicle ) then return false end
		if ( IsWarning( e ) && !Hermes.features.espentitywarning ) then return false end
		return true
	elseif ( typ == "cham" ) then
		if ( !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() ) then return false end
		if ( !Hermes:OnScreen( e ) ) then return false end
		if ( e:IsPlayer() && !Hermes.features.champlayer || e:IsPlayer() && ( Hermes.features.espplayerenemyonly || Hermes.features.espplayerteamesp ) && e:Team() == ply:Team() ) then return false end
		if ( e:IsNPC() && !Hermes.features.chamnpc ) then return false end
		if ( e:IsWeapon() && !Hermes.features.chamweapon ) then return false end
		return true
	end
	return false
end
		
function Hermes:ValidEntity( e, typ )
	if ( !ValidEntity( e ) ) then return false end
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	
	if ( typ == "aim" ) then
		if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() ) ) then return false end
		if ( !Hermes:EnabledVar( e, "aim" ) ) then return false end
		if ( e:IsPlayer() ) then if ( ( !e:Alive() || e:Health() <= 0 ) || ( e:GetMoveType() == MOVETYPE_OBSERVER ) ) then return false end end
		if ( e:IsNPC() ) then if ( ( e:GetMoveType() == MOVETYPE_NONE ) || ( table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) ) then return false end end
		return true
	elseif ( typ == "esp" ) then
		if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !IsAmmobox( e ) && !IsRagdoll( e ) && !IsVehicle( e ) && !IsWarning( e ) ) || ( e == ply ) ) then return false end
		if ( !Hermes:EnabledVar( e, "other" ) ) then return false end
		if ( e:IsPlayer() ) then if ( ( !e:Alive() || e:Health() <= 0 ) || ( e:GetMoveType() == MOVETYPE_OBSERVER ) ) then return false end end
		if ( e:IsNPC() ) then if ( ( e:GetMoveType() == MOVETYPE_NONE ) || ( table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) ) then return false end end
		if ( e:IsWeapon() && ( e:GetMoveType() == MOVETYPE_NONE ) ) then return false end
		return true
	elseif ( typ == "cham" ) then
		if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() ) || ( e == ply ) ) then return false end
		if ( !Hermes:EnabledVar( e, "cham" ) ) then return false end
		if ( e:IsPlayer() ) then if ( ( !e:Alive() || e:Health() <= 0 ) || ( e:GetMoveType() == MOVETYPE_OBSERVER ) ) then return false end end
		if ( e:IsNPC() ) then if ( ( e:GetMoveType() == MOVETYPE_NONE ) || ( table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) ) then return false end end
		if ( e:IsWeapon() && ( e:GetMoveType() != MOVETYPE_NONE ) ) then return false end
		return true
	elseif ( typ == "radar" ) then
		if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() ) ) then return false end
		if ( !Hermes:EnabledVar( e, "other" ) ) then return false end
		if ( e:IsPlayer() ) then if ( ( !e:Alive() || e:Health() <= 0 ) || ( e:GetMoveType() == MOVETYPE_OBSERVER ) ) then return false end end
		if ( e:IsNPC() ) then if ( ( e:GetMoveType() == MOVETYPE_NONE ) || ( table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) ) then return false end end
	end
	return false
end

function Hermes:DrawCircle( rad ) -- GMod wiki stuff here
	local center = Vector( ScrW() / 2, ScrH() / 2, 0 )
	local scale = Vector( rad, rad, 0 )
	local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
	surface.SetDrawColor( 255, 255, 255, 255 )
 
	for a = 0, 360 - segmentdist, segmentdist do
		surface.DrawLine( center.x + math.cos( math.rad( a ) ) * scale.x, center.y - math.sin( math.rad( a ) ) * scale.y, center.x + math.cos( math.rad( a + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( a + segmentdist ) ) * scale.y )
	end
end

//------------------------------
// Aim position:
//------------------------------
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

function Hermes:GetPos( e, pos )
	if ( type( pos ) == "string" ) then
		return ( e:GetBonePosition( e:LookupBone( pos ) ) )
	elseif ( type( pos ) == "Vector" ) then
		return ( e:LocalToWorld( e:OBBCenter() + pos ) )
	end
	return ( e:LocalToWorld( pos ) )
end

function Hermes:ValidModel( e )
	for k, v in pairs( Hermes.modelbones ) do
		if ( v.Model == e:GetModel() ) then
			return true
		end
	end
	return false
end

local curBone = 0
function Hermes:TargetLocation( e )
	local pos = e:LocalToWorld( e:OBBCenter() )
	
	pos = Hermes:GetPos( e, "ValveBiped.Bip01_Head1" )
	
	local usingAttachments = false
	if ( e:GetAttachment( e:LookupAttachment( "eyes" ) ) ) then
		pos = e:GetAttachment( e:LookupAttachment( "eyes" ) ).Pos; Hermes:Msg( e:GetClass() .. " is using 'eyes'" )
		usingAttachments = true
	elseif ( e:GetAttachment( e:LookupAttachment( "forward" ) ) ) then
		pos = e:GetAttachment( e:LookupAttachment("forward") ).Pos; Hermes:Msg( e:GetClass() .. " is using 'forward'" )
		usingAttachments = true
	elseif ( e:GetAttachment( e:LookupAttachment( "head" ) ) ) then
		pos = e:GetAttachment( e:LookupAttachment( "head" ) ).Pos; Hermes:Msg( e:GetClass() .. " is using 'head'" )
		usingAttachments = true
	else
		pos = Hermes:GetPos( e, "ValveBiped.Bip01_Head1" ); Hermes:Msg( e:GetClass() .. " is using a other bone" )
		usingAttachments = false
	end
	
	local bones, aimspot = {}, {}
	if ( Hermes.features.bonescan ) then
		for k, v in pairs( Hermes.bonescan ) do
			local name = ( string.gsub( v.Bone, ".", "" ) )
			bones[ name ] = v.Bone
			bones[ v.Priority ] = v.Priority
			
			table.insert( aimspot, { Bone = bones[ name ], Priority = bones[ v.Priority ] } )
		end
	end
	
	if ( Hermes.features.bonescan ) then
		for k, v in pairs( aimspot ) do
			if ( v.Priority > curBone ) then
				pos = Hermes:GetPos( e, v.Bone )
				curBone = v.Priority
			end
		end
	end
	
	if ( !usingAttachments ) then
		for k, v in pairs( Hermes.modelbones ) do
			if ( v.Model == e:GetModel() ) then
				pos = Hermes:GetPos( e, v.Pos )
			end
		end
	end
	
	if ( Hermes.features.vectorbot ) then
		pos = e:LocalToWorld( ( e:OBBCenter() + Vector( 0, 0, e:OBBCenter().z ) ) + Vector( 0, 0, tonumber( Hermes.features.vectorbotoffset ) ) )
	end
	
	return Hermes:WeaponPrediction( e, pos )
end
	

//------------------------------
// Find Targets:
//------------------------------

function Hermes:SelfTrace()
	local ply = LocalPlayer()
	local start, endP = ply:GetShootPos(), ply:GetAimVector()
	
	local trace = {}
	trace.start = start
	trace.endpos = start + ( endP * 16384 )
	trace.filter = { ply }
	
	return util.TraceLine( trace )
end

Hermes.visibleplayers = {}
function Hermes:Visible( e )
	local ply, usingBone = LocalPlayer(), false
	local btrace, btr = {}, {}
	
	Hermes.visibleplayers = {}
	if ( ( Hermes.features.bonescan || Hermes.features.visiblechecks ) ) then
		for k, v in pairs( Hermes.bonescan ) do
			if ( v.Bone ) then
				local name = string.gsub( v.Bone, ".", "" )
				btrace[ name ] = { start = ply:GetShootPos(), endpos = Hermes:GetPos( e, v.Bone ), filter = { ply, e }, mask = 1174421507 }
				btr[ name ] = util.TraceLine( btrace[ name ] )
				
				usingBone = true
				
				if ( btr[ name ].Fraction == 1 ) then
					return true
				end
			end
		end
	end
	
	local trace = { start = ply:GetShootPos(), endpos = Hermes:TargetLocation( e ), filter = { ply, e }, mask = 1174421507 }
	local tr = util.TraceLine( trace )
	
	if ( tr.Fraction == 1 && !usingBone ) then
		return true
	end
	return false
end

function Hermes:GetTargets()
	local ply, ent = LocalPlayer(), ents.GetAll()
	
	ent = Hermes.features.aimnpc == true && ents.GetAll() || player.GetAll()
	Hermes.set.targets = {}
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		if ( Hermes:ValidEntity( e, "aim" ) && Hermes:Visible( e ) ) then
			table.insert( Hermes.set.targets, e )
		end
	end
	return Hermes.set.targets
end

function Hermes.Triggerbot()
	local ply = LocalPlayer()
	if ( Hermes.features.triggerbot ) then
	if ( Hermes.features.triggerbotkey && !input.IsKeyDown( KEY_E ) ) then return end
	
		local trace = Hermes:SelfTrace()
		
		if ( Hermes:ValidEntity( trace.Entity, "aim" ) ) then
		
		local pos = ply:GetPos():Distance( trace.Entity:GetPos() ) / 4
		if ( ( tonumber( Hermes.features.triggerbotdistance ) > pos ) || ( Hermes.features.triggerbotdistance == 0 ) ) then
				RunConsoleCommand( "+attack" )
				timer.Simple( 0.1, function() RunConsoleCommand( "-attack" ) end )
			end
		end
	end
end

Hermes.SwitchWeapons = {}

local reloadtime, ran, shouldRun = 0, false, true
function Hermes:Autoswitch()
	if ( !Hermes.features.autoswitch ) then return end
	local ply = LocalPlayer()
	
	if ( ply:GetActiveWeapon() && reloadtime - CurTime() <= 0 ) then
		if ( ValidEntity( ply ) && ply:Alive() && ply:GetActiveWeapon():IsValid() ) then
			local ammo, wepClass = ply:GetActiveWeapon():Clip1(), ply:GetActiveWeapon():GetClass()
			
			if ( !Hermes.SwitchWeapons[ wepClass ] ) then
				shouldRun = false
				
				if ( ammo != 0 ) then
					Hermes.SwitchWeapons[ wepClass ] = true
				end
				return
			end
			
			if ( Hermes.SwitchWeapons[ wepClass ] && ammo == 0 ) then
				if ( !ran ) then
					RunConsoleCommand( "invnext" );
					RunConsoleCommand( "+attack" );
					ran = true;
				end
				
				timer.Simple( 0.01, function() 
					Hermes.SwitchWeapons[ wepClass ] = false;
					RunConsoleCommand( "-attack" );
					ran = false; 
				end )
			end
		end
	end
end

local oldTarget; local foundTarget = false
function Hermes:GetTarget()
	local x, y = ScrW(), ScrH()
	local ply, targets = LocalPlayer(), Hermes:GetTargets()
	
	if ( table.Count( targets ) == 0 ) then return end
	
	Hermes.set.tar = ply
	for i = 1, table.Count( targets ) do
		local e = targets[i]
		
		local angA, angB = 0
		local ePos, oldPos, myAngV = e:EyePos():ToScreen(), Hermes.set.tar:EyePos():ToScreen(), ply:GetAngles()
		local dis = math.floor( tonumber( e:GetPos():Distance( ply:GetShootPos() ) ) / 4 )
		
		local angle = ( e:GetPos() - ply:GetShootPos() ):Angle()
		local angleY = math.abs( math.NormalizeAngle( myAngV.y - angle.y ) )
		local angleP = math.abs( math.NormalizeAngle( myAngV.p - angle.p ) )
			
		if ( ( ( tonumber( Hermes.features.maxdistance ) > dis ) || ( tonumber( Hermes.features.maxdistance ) == 0 ) ) && ( angleY < tonumber( Hermes.features.fov ) && angleP < tonumber( Hermes.features.fov ) ) ) then
		
			if ( Hermes.features.mode == 1 ) then
				angA = math.Dist( x / 2, y / 2, oldPos.x, oldPos.y )
				angB = math.Dist( x / 2, y / 2, ePos.x, ePos.y )
			elseif ( Hermes.features.mode == 2 ) then
				angA = Hermes.set.tar:EyePos():Distance( ply:EyePos() )
				angB = e:EyePos():Distance( ply:EyePos() )
			elseif ( Hermes.features.mode == 3 ) then
				angA = Hermes.set.tar:Health()
				angB = e:Health()
			end
			
			if ( Hermes.features.disableafterkill ) then
				if ( angB <= angA ) then
					if ( !foundTarget ) then
						oldTarget = e
						foundTarget = true
					end
				elseif ( Hermes.set.tar == ply ) then
					if ( !foundTarget ) then
						oldTarget = e
						foundTarget = true
					end
				end
				
				if ( !oldTarget:Alive() ) then
					print( "dead" )
					Hermes.set.aiming = false
					foundTarget = false
					return oldTarget
				end
				return oldTarget
			end
			
			if ( !Hermes.features.disableafterkill ) then
				if ( angB <= angA ) then
					Hermes.set.tar = e
				elseif ( Hermes.set.tar == ply ) then
					Hermes.set.tar = e
				end
			end
		end
	end
	return Hermes.set.tar
end

function Hermes.SetView() 
	local ply = LocalPlayer()
	if ( !ValidEntity( ply ) ) then return end
	Hermes.set.angles = ply:EyeAngles()
end
Hermes:AddHook( "OnToggled", Hermes.SetView )

function Hermes:ToggleHUD()
	if ( !Hermes.features.togglehud ) then return end
	local tar = Hermes.set.tar || Hermes.set.target
	
	local text, col = nil, nil
	if ( Hermes.set.aiming && tar != LocalPlayer() ) then
		text = "Locked"; col = Color( 255, 0, 0, 255 )
	elseif ( Hermes.set.aiming ) then
		text = "Scanning..."; col = Color( 0, 255, 0, 255 )
	end
	
	if ( text != nil && col != nil ) then
		draw.SimpleText( text, "ScoreboardText", ( ScrW() / 2 ), ( ScrH() / 2 ) + 20, col, 1, 1 )
		
		if ( tar != LocalPlayer() ) then
			local target = tar:IsPlayer() && tar:Nick() || tar:GetClass()
			draw.SimpleText( target, "ScoreboardText", ( ScrW() / 2 ), ( ScrH() / 2 ) + 40, col, 1, 1 )
		end
	end
end

function Hermes:View()
	return Hermes.set.angles * 1
end

function Hermes.Aim( ucmd )
	local ply = LocalPlayer()
	if ( IsValid( ply:GetActiveWeapon() ) && ( ply:GetActiveWeapon():GetClass() == "weapon_physgun" ) && ( ucmd:GetButtons() & IN_USE ) > 0 ) then return end
	
	Hermes.Triggerbot()
	Hermes:Autoswitch()
	
	local newAngles
	Hermes.set.target = Hermes:GetTarget();
	
	Hermes.set.angles.p = math.NormalizeAngle( Hermes.set.angles.p )
	Hermes.set.angles.y = math.NormalizeAngle( Hermes.set.angles.y )
	
	Hermes.set.angles.p = math.Clamp( Hermes.set.angles.p + ( ucmd:GetMouseY() * 0.022 ), -89, 89 )
	Hermes.set.angles.y = math.NormalizeAngle( Hermes.set.angles.y + ( ucmd:GetMouseX() * 0.022 * -1 ) )
	
	if ( !ply:Alive() ) then Hermes.set.aiming = false end
	if ( !Hermes.set.aiming ) then
		ucmd:SetViewAngles( Hermes.set.angles )
	end
	
	Hermes.set.fakeang = Hermes.set.angles
	if ( Hermes.features.nospread && Hermes.features.constantnospread && ( ucmd:GetButtons() & IN_ATTACK > 0 ) ) then
		Hermes.set.fakeang = Hermes.SeedSpread( ucmd, Hermes.set.angles )
		ucmd:SetViewAngles( Hermes.set.fakeang )
	end
	
	if ( !Hermes.set.aiming ) then return end
	if ( Hermes.set.target == nil || Hermes.set.target == ply ) then return end
	
	local compensate = Hermes:TargetLocation( Hermes.set.target )
	
	if ( Hermes.features.prediction ) then
		compensate = compensate + ( Hermes.set.target:GetVelocity() / 45 - ply:GetVelocity() / 45 )
	end
	
	if ( Hermes.features.silentaim ) then
		local fakeAngle = ( compensate - ply:GetShootPos() ):Angle()
		newAngles = Hermes.SeedSpread( ucmd, fakeAngle )
		
	elseif( !Hermes:TargetLocation( Hermes.set.target ).visible || !Hermes.features.silentaim ) then
		Hermes.set.angles = ( compensate - ply:GetShootPos() ):Angle()
		newAngles = Hermes.SeedSpread( ucmd, Hermes.set.angles )
	end
	
	newAngles.p = math.NormalizeAngle( newAngles.p )
	newAngles.y = math.NormalizeAngle( newAngles.y )
	
	newAngles.r = 0
	
	ucmd:SetViewAngles( newAngles )
	
	if ( Hermes.features.autoshoot ) then
		RunConsoleCommand( "+attack" )
		timer.Simple( 0.01, function() RunConsoleCommand( "-attack" ) end )
	end
end
Hermes:AddHook( "CreateMove", Hermes.Aim )

function Hermes.NoRecoil( ply, origin, angles, FOV )
	if ( !Hermes.features.norecoil ) then return end
	
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	if ( wep.Primary ) then wep.Primary.Recoil = 0 end
	if ( wep.Secondary ) then wep.Secondary.Recoil = 0 end
	
	local view = GAMEMODE:CalcView( ply, origin, Hermes.set.angles, FOV ) || {}
	view.angles = Hermes.set.angles
	view.angles.r = 0
	view.fov = FOV
	return view
end
Hermes:AddHook( "CalcView", Hermes.NoRecoil )

Hermes:AddCommand( "+hermes_aim", function() Hermes.set.aiming = true; Hermes.set.target = nil; end )
Hermes:AddCommand( "-hermes_aim", function() Hermes.set.aiming = false; Hermes.set.target = nil; end )

//------------------------------
// ESP:
//------------------------------
Hermes.skeleton = {
	// Main body
	{ S = "ValveBiped.Bip01_Head1", E = "ValveBiped.Bip01_Neck1" },
	{ S = "ValveBiped.Bip01_Neck1", E = "ValveBiped.Bip01_Spine4" },
	{ S = "ValveBiped.Bip01_Spine4", E = "ValveBiped.Bip01_Spine2" },
	{ S = "ValveBiped.Bip01_Spine2", E = "ValveBiped.Bip01_Spine1" },
	{ S = "ValveBiped.Bip01_Spine1", E = "ValveBiped.Bip01_Spine" },
	{ S = "ValveBiped.Bip01_Spine", E = "ValveBiped.Bip01_Pelvis" },
	
	// Left Arm
	{ S = "ValveBiped.Bip01_Spine2", E = "ValveBiped.Bip01_L_UpperArm" },
	{ S = "ValveBiped.Bip01_L_UpperArm", E = "ValveBiped.Bip01_L_Forearm" },
	{ S = "ValveBiped.Bip01_L_Forearm", E = "ValveBiped.Bip01_L_Hand" },
	
	// Right Arm
	{ S = "ValveBiped.Bip01_Spine2", E = "ValveBiped.Bip01_R_UpperArm" },
	{ S = "ValveBiped.Bip01_R_UpperArm", E = "ValveBiped.Bip01_R_Forearm" },
	{ S = "ValveBiped.Bip01_R_Forearm", E = "ValveBiped.Bip01_R_Hand" },
	
	// Left leg
	{ S = "ValveBiped.Bip01_Pelvis", E = "ValveBiped.Bip01_L_Thigh" },
	{ S = "ValveBiped.Bip01_L_Thigh", E = "ValveBiped.Bip01_L_Calf" },
	{ S = "ValveBiped.Bip01_L_Calf", E = "ValveBiped.Bip01_L_Foot" },
	{ S = "ValveBiped.Bip01_L_Foot", E = "ValveBiped.Bip01_L_Toe0" },
	
	// Right leg
	{ S = "ValveBiped.Bip01_Pelvis", E = "ValveBiped.Bip01_R_Thigh" },
	{ S = "ValveBiped.Bip01_R_Thigh", E = "ValveBiped.Bip01_R_Calf" },
	{ S = "ValveBiped.Bip01_R_Calf", E = "ValveBiped.Bip01_R_Foot" },
	{ S = "ValveBiped.Bip01_R_Foot", E = "ValveBiped.Bip01_R_Toe0" },
}

function Hermes:Skeleton( e )
	if ( !e:IsPlayer() || e:IsPlayer() && !Hermes.features.espplayerskeleton ) then return end
	
	for k, v in pairs( Hermes.skeleton ) do
		local sPos, ePos = e:GetBonePosition( e:LookupBone( v.S ) ):ToScreen(), e:GetBonePosition( e:LookupBone( v.E ) ):ToScreen()
		
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawLine( sPos.x, sPos.y, ePos.x, ePos.y )
	end
end

function Hermes:BarrelHack( e )
	if ( !e:IsPlayer() || e:IsPlayer() && !Hermes.features.espplayerbarrel ) then return end
	
	local headPos, hitPos, col = e:EyePos():ToScreen(), e:GetEyeTrace().HitPos, team.GetColor( e:Team() )
	// nawpie: What will happen? Too much processing power used on barrelhack
	surface.SetDrawColor( 0, 255, 0, 255 )
	surface.DrawLine( headPos.x, headPos.y, hitPos.x, hitPos.y )
end

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

function Hermes:HalfPos( e )
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
	
	local FRT 	= center + frt / 2 + rgt / 2 + top / 4; FRT = FRT:ToScreen()
	local BLB 	= center + bak / 2 + lft / 2 + btm / 4; BLB = BLB:ToScreen()
	local FLT	= center + frt / 2 + lft / 2 + top / 4; FLT = FLT:ToScreen()
	local BRT 	= center + bak / 2 + rgt / 2 + top / 4; BRT = BRT:ToScreen()
	local BLT 	= center + bak / 2 + lft / 2 + top / 4; BLT = BLT:ToScreen()
	local FRB 	= center + frt / 2 + rgt / 2 + btm / 4; FRB = FRB:ToScreen()
	local FLB 	= center + frt / 2 + lft / 2 + btm / 4; FLB = FLB:ToScreen()
	local BRB 	= center + bak / 2 + rgt / 2 + btm / 4; BRB = BRB:ToScreen()
	
	local maxX = math.max( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local minX = math.min( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local maxY = math.max( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	local minY = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	
	return maxX, minX, maxY, minY
end

function Hermes:MinESP( e, col )
	if ( !e:IsPlayer() || e:IsPlayer() && !Hermes.features.espplayerteamesp && e:Team() == ply:Team() ) then return end--																																																																																																																															;;;;;;;screw this u suck :P -- I'll keep your message because I'm fucking scared now you little bitch :)))))).
	local maxX, minX, maxY, minY = Hermes:HalfPos( e )
	
	surface.SetDrawColor( 0, 255, 0, 255 )
	
	surface.DrawLine( maxX, maxY, maxX, minY )
	surface.DrawLine( maxX, minY, minX, minY )
	
	surface.DrawLine( minX, minY, minX, maxY )
	surface.DrawLine( minX, maxY, maxX, maxY )
	
	draw.SimpleText(
		e:Nick(),
		"Default",
		maxX + 1,
		minY + 3,
		col,
		TEXT_ALIGN_BOTTOM,
		TEXT_ALIGN_CENTER
	)
	
end

function Hermes:HPBar( e, col )
	if ( !e:IsPlayer() || e:IsPlayer() && !Hermes.features.espplayerhealthbar ) then return end
	
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
	
	local x = ( 100 / e:Health() )
	if ( e:Health() <= 0 ) then x = 1 end
	local FRT 	= center + frt + rgt + top / x; FRT = FRT; FRT = FRT:ToScreen()
	local BLB 	= center + bak + lft + btm / x; BLB = BLB; BLB = BLB:ToScreen()
	local FLT	= center + frt + lft + top / x; FLT = FLT; FLT = FLT:ToScreen()
	local BRT 	= center + bak + rgt + top / x; BRT = BRT; BRT = BRT:ToScreen()
	local BLT 	= center + bak + lft + top / x; BLT = BLT; BLT = BLT:ToScreen()
	local FRB 	= center + frt + rgt + btm / x; FRB = FRB; FRB = FRB:ToScreen()
	local FLB 	= center + frt + lft + btm / x; FLB = FLB; FLB = FLB:ToScreen()
	local BRB 	= center + bak + rgt + btm / x; BRB = BRB; BRB = BRB:ToScreen()
	
	local minYhp = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	local maxX, minX, maxY, minY = Hermes:CreatePos( e )
	
	// Outline
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawLine( minX - 1, minY, minX - 1, maxY )
	surface.DrawLine( minX - 6, minY, minX - 6, maxY )
			
	surface.DrawLine( minX - 6, minY, minX, minY )
	surface.DrawLine( minX - 6, maxY, minX, maxY )
	
	// Inner
	local pos = 2
	for i = 1, 4 do
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine( minX - pos, ( minY + 1 ), minX - pos, maxY )
		surface.SetDrawColor( col )
		surface.DrawLine( minX - pos, ( minYhp + 1 ), minX - pos, maxY )
		pos = pos + 1
	end
end

function Hermes:Filter( e )
	local ply = LocalPlayer()
	
	local maxX, minX, maxY, minY = Hermes:CreatePos( e )
	local col = Hermes:FilterColors( e )
	local text, box, posX, posY, Xalign, Yalign = "", "", false, maxX, minY, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
	
	if ( e:IsNPC() ) then
		if ( Hermes.features.espnpcbox ) then
			box = true
		else box = false end
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		local data = e:GetClass()
		data = string.gsub( data, "npc_", "" )
		data = string.gsub( data, "monster_", "" )
		data = string.gsub( data, "_", "" )
		
		text = data
		
	elseif ( e:IsWeapon() ) then
		if ( Hermes.features.espentitybox ) then
			box = true
		else box = false end
		
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
		
	elseif ( IsAmmobox( e ) ) then
		if ( Hermes.features.espentitybox ) then
			box = true
		else box = false end
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		local data = e:GetClass()
		data = string.gsub( data, "item_ammo_revolver_ttt", "Revolver Ammo" )
		data = string.gsub( data, "item_ammo_357_ttt", "357 Ammo" )
		data = string.gsub( data, "item_box_buckshot_ttt", "Shotgun Ammo" )
		data = string.gsub( data, "item_ammo_pistol_ttt", "Pistol Ammo" )
		
		text = data
		
	elseif ( IsRagdoll( e ) ) then
		box = false
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		text = "Ragdoll" 
		
	elseif ( IsVehicle( e ) ) then
		if ( Hermes.features.espentitybox ) then
			box = true
		else box = false end
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		text = "Vehicle"
		
	elseif ( IsWarning( e ) ) then
		if ( Hermes.features.espentitybox ) then
			box = true
		else box = false end
		
		posX, posY = ( minX + maxX ) / 2, minY
		Xalign, Yalign = TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		
		local data = e:GetClass()
		data = string.gsub( data, "npc_grenade_frag", "Frag" )
		data = string.gsub( data, "crossbow_bolt", "Bolt" )
		data = string.gsub( data, "roleplayg_missile", "Missile" )
		data = string.gsub( data, "grenade_ar2", "AR2 Grenade" )
		data = string.gsub( data, "prop_combine_ball", "Combine Ball" )
		data = string.gsub( data, "hunter_flechette", "Flechette" )
		data = string.gsub( data, "npc_grenade_frag", "Frag" )
		data = string.gsub( data, "ent_flashgrenade", "Flashbang" )
		data = string.gsub( data, "ent_explosivegrenade", "Grenade" )
		data = string.gsub( data, "ent_smokegrenade", "Smokebomb" )
		
		text = data
		
		local distance = math.floor( tonumber( e:GetPos():Distance( ply:GetShootPos() ) ) / 4 )
		if ( distance < 300 ) then
			text = data .. "\nD: " .. distance
			posY = posY - 12
		end
		
	elseif ( e:IsPlayer() ) then
		if ( Hermes.features.espplayerbox ) then
			box = true
		else box = false end
		
		posX, posY = maxX + 1, minY + 3
		Xalign, Yalign = TEXT_ALIGN_BOTTOM, TEXT_ALIGN_CENTER
		
		local added = 0
		if ( Hermes.features.espplayername ) then
			text = text .. e:Nick()
			added = added + 1
		end
		
		if ( Hermes.features.espplayerhealth ) then
			text = text .. "\nHp: " .. e:Health()
			added = added + 1
			
			if ( added == 1 ) then
				text = "Hp: " .. e:Health()
			end
		end
		
		if ( Hermes.features.espplayerweapon ) then
			local wep = "NONE"
			if ( e:GetActiveWeapon():IsValid() ) then
				wep = e:GetActiveWeapon():GetPrintName()
			
				wep = string.gsub( wep, "#HL2_", "" )
				wep = string.gsub( wep, "#GMOD_", "" )
				wep = string.gsub( wep, "_", " " )
			end
			
			text = text .. "\nW: " .. wep
			added = added + 1
			
			if ( added == 1 ) then
				text = "W: " .. wep
			end
		end
		
		if ( Hermes.features.espplayerdistance ) then
			
			local dis = math.floor( tonumber( e:GetPos():Distance( ply:GetShootPos() ) ) / 4 )
			text = text .. "\nD: " .. dis
			added = added + 1
			
			if ( added == 1 ) then
				text = "D: " .. dis
			end
		end
	end
	return text, box, col, posX, posY, maxX, minX, maxY, minY, Xalign, Yalign
end

function Hermes.HUD()
	local ply, ent = LocalPlayer(), ents.GetAll()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( Hermes:ValidEntity( e, "esp" ) ) then
		
			local text, box, col, posX, posY, maxX, minX, maxY, minY, Xalign, Yalign = Hermes:Filter( e )
		
			if ( box ) then
				surface.SetDrawColor( col )
					
				surface.DrawLine( maxX, maxY, maxX, minY )
				surface.DrawLine( maxX, minY, minX, minY )
					
				surface.DrawLine( minX, minY, minX, maxY )
				surface.DrawLine( minX, maxY, maxX, maxY )
			end
			
			local textLength, pos = string.Explode( "\n", text ), 0
			
			for i = 1, table.Count( textLength ) do
				draw.SimpleTextOutlined(
					textLength[ i ],
					"DefaultSmall",
					posX,
					posY + pos,
					Color( 0, 255, 0, 255 ),
					Xalign,
					Yalign,
					1,
					Color( 0, 0, 0, 255 )
				)
				pos = pos + 12
			end
				
			Hermes:HPBar( e, col )
			Hermes:BarrelHack( e )
			
			Hermes:Skeleton( e )
			
			if ( Hermes.features.aimline ) then
				if ( e == Hermes.set.target ) then
					local tr = e:EyePos():ToScreen()
				
					surface.SetDrawColor( 255, 242, 0, 255 )
					surface.DrawLine( ScrW() / 2, ScrH() / 2, tr.x, tr.y )
				end
			end
		end
	end
	
	local players = player.GetAll()
	for i = 1, table.Count( players ) do
		local e = players[i]
		if ( e:IsPlayer() && e:Alive() && e:Team() == ply:Team() && e != ply && Hermes.features.espplayerteamesp ) then
			local col = Hermes:FilterColors( e )
			
			Hermes:Skeleton( e )
			Hermes:MinESP( e, col )
		end
	end
	
	if ( Hermes.features.crosshair ) then
		local x, y = ScrW() / 2, ScrH() / 2
		
		local sX, sY = 5, 5
		surface.SetDrawColor( 255, 242, 0, 255 )
		surface.DrawLine( x, y - sY, x, y + sY )
		surface.DrawLine( x - sX, y, x + sX, y )
	end
	
	if ( Hermes.features.drawfov && tonumber( Hermes.features.fov ) < 40 ) then
		local size = ( math.sqrt( ( ScrW() ^ 2 ) + ( ScrH() ^ 2 ) ) * 0.5 )
		Hermes:DrawCircle( ( size * tonumber( Hermes.features.fov ) / 45 ) - 45 )
	end
	
	Hermes:ToggleHUD()
end
Hermes:AddHook( "HUDPaint", Hermes.HUD )

//------------------------------
// Chams:
//------------------------------
function Hermes:CreateMaterial()
	local BaseInfo = {
		["$basetexture"] = "models/debug/debugwhite",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1,
		["$ignorez"]	 = 1
	}
	
	local mat = CreateMaterial( "hermes_setmat_solid", "VertexLitGeneric", BaseInfo )
	return mat
end

function Hermes.Chams()
	local ply, ent, c = LocalPlayer(), ents.GetAll(), ( 1 / 255 )
	
	for i = 1, table.Count( ent ) do
		local e = ent[ i ]
		
		if ( Hermes:ValidEntity( e, "cham" ) ) then
			local mat, col = Hermes:CreateMaterial(), Hermes:FilterColors( e )
			cam.Start3D( EyePos(), EyeAngles() )
				if ( Hermes.features.chamfullbright ) then
					render.SuppressEngineLighting( true )
				else render.SuppressEngineLighting( false ) end
				if ( Hermes.features.champroxy ) then
					render.SetBlend( 0.5 )
				else render.SetBlend( 1 ) end
				render.SetColorModulation( ( col.r * c ), ( col.g * c ), ( col.b * c ) )
				SetMaterialOverride( mat )
				e:DrawModel()
				render.SuppressEngineLighting( false )
				render.SetBlend( 1 )
				render.SetColorModulation( 1, 1, 1 )
				SetMaterialOverride()
				e:DrawModel()
			cam.End3D()
		end
	end
end
Hermes:AddHook( "RenderScreenspaceEffects", Hermes.Chams )
//------------------------------
// Misc:
//------------------------------
function Hermes.Bunnyhop()
	local ply = LocalPlayer()
	if ( Hermes.features.bunnyhop && input.IsKeyDown( KEY_SPACE ) ) then
		if ( ply:OnGround() ) then
			RunConsoleCommand( "+jump" )
		end
		timer.Simple( 0.01, function() RunConsoleCommand( "-jump" ) end )
	end
end

--[[
Hermes.keyPressed, Hermes.isAFK = 0, false

local function DoAFKChecks()
	if ( Hermes.keyPressed > 0 ) then
		Hermes.isAFK = true
	end
	Hermes.keyPressed = 0
	
	timer.Simple( 5, DoAFKChecks )
end
timer.Simple( 5, DoAFKChecks )

function Hermes.KeyPressed()
	Hermes.keyPressed = Hermes.keyPressed + 1
end
Hermes:AddHook( "KeyPress", Hermes.KeyPressed )

local function AntiAFKKick()
	local ply, isAFK = LocalPlayer(), tobool( Hermes.isAFK )
	
	if ( isAFK ) then
		Hermes:RequiredMessage( "You're AFK, changing angles and pressing keys to avoid being kicked..." )
			
		// View Angles
		local myAng, defAng, subAng = ply:GetAngles(), Vector( 0, 0, 0 ), Vector( 0, 0, 0.1 )
		local setAng, setoldAng = ( myAng - subAng ):Angle(), ( myAng - defAng ):Angle()
		ply:SetEyeAngles( setAng )
		timer.Simple( 0.1, function() ply:SetEyeAngles( setoldAng ) end )
			
		// Keys
		RunConsoleCommand( "+jump" )
		timer.Simple( 0.1, function() RunConsoleCommand( "-jump" ) end )
	end
	
	timer.Simple( 5, AntiAFKKick )
end
timer.Simple( 5, AntiAFKKick )]]

function Hermes.Admins()
	MsgN( "[----------| Admins |--------------------]" )
	for k, e in pairs( player.GetAll() ) do
		if ( e:IsAdmin() ) then
			MsgN( e:Nick() )
		end
	end
	MsgN( "[----------------------------------------]" )
end

function Hermes.EnabledSpeed()
	if ( Hermes.features.speedhack ) then
		RunConsoleCommand( "hermes_host_timescale", tonumber( Hermes.features.speedhackspeed ) )
	end
end

function Hermes.DisableSpeed()
	RunConsoleCommand( "hermes_host_timescale", 1.0 )
end

Hermes:AddCommand( "+hermes_speed", function() Hermes.EnabledSpeed() end )
Hermes:AddCommand( "-hermes_speed", function() Hermes.DisableSpeed() end )

Hermes:AddCommand( "hermes_admins", function() Hermes.Admins() end )

function Hermes.Think()
	//Hermes.ConeThink()
	Hermes.Bunnyhop()
	Hermes.GetTraitors()
end

Hermes:AddHook( "Think", Hermes.Think )

//------------------------------
// Menu:
//------------------------------
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

function Hermes:NumSlider( cvar, desc, max, min )
	local slider = vgui.Create( "DNumSlider" )
	slider:SetDecimals( 0 )
	slider:SetText( "" )
	slider:SetMax( max || 1 )
	slider:SetMin( min || 0 )
	slider:SetDecimals( 0 )
	slider:SetValue( GetConVarNumber( cvar ) )
			
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

--[[
function Hermes:MultiChoice( cvar, tbl, items )
	local multichoice = vgui.Create( "DMultiChoice" )
	multichoice:SetEditable( false )
	
	local l = 1
	for k, v in pairs( Hermes.convars ) do
		if ( v.Name == cvar ) then
			for t, e in pairs( v.Items ) do
				multichoice:AddChoice( e[ l ] || "NULL" )
				l = l + 1
			end
		end
	end
	
	multichoice:ChooseOptionID( tonumber( Hermes.features[ tbl ] ) )
	multichoice.OnSelect = function( index, value, data )
		RunConsoleCommand( cvar, value )
	end
	return multichoice
end]]

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
			}
		},
		
		{ Tab = "ESP", Icon = "gui/silkicons/world", Contents = {
				{ [5] = "Players" },
				{ [6] = "NPCs" },
				{ [7] = "Entities" },
				{ [8] = "Chams" },
			}
		},
		
		{ Tab = "Miscellaneous", Icon = "gui/silkicons/plugin", Contents = {
				{ [9] = "Miscellaneous" },
			}
		},
	}
	
	local propertysheet = vgui.Create( "DPropertySheet" )
	propertysheet:SetParent( panel )
	propertysheet:SetPos( 5, 30 )
	propertysheet:SetSize( 440, 315 )
	
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
			if ( string.find( string.lower( v.Name ), typ ) ) then
				categorylist[ v.Name ]:AddItem( item )
			end
		end
	end
	
	for k, v in ipairs( Hermes.getallcvars ) do
		if ( v.Menu == "checkbox" ) then
			local checkbox = Hermes:CheckBox( v.Name, v.Desc )
			AddItem( checkbox, v.Type )
		elseif ( v.Menu == "slider" ) then
			local slider = Hermes:NumSlider( v.Name, v.Desc, v.Max, v.Min )
			AddItem( slider, v.Type )
		end
	end
end
Hermes:AddCommand( "hermes_menu", function() Hermes.Menu() end )