/*------------------------------------------------------------------------------------------------------
   __ __                        
  / // /___  ____ __ _  ___  ___
 / _  // -_)/ __//  ' \/ -_)(_-<
/_//_/ \__//_/  /_/_/_/\__//___/
Hermes :: Private Edition
*/------------------------------------------------------------------------------------------------------
if !( CLIENT ) then return end

//******************************
// Tables, Hooks, Commands...
//******************************
//------------------------------
// Tables:
//------------------------------
require( "sys" )
package.loaded.sys = nil

local Hermes			= {}
Hermes.features			= {}
Hermes.commands			= {}
Hermes.convars			= {}
Hermes.hooks			= {}
Hermes.old				= {}
Hermes.create			= {}
Hermes.menuinfo			= {}
Hermes.friends			= ( file.Exists("hermes_lists_friends.txt") && KeyValuesToTable( file.Read( "hermes_lists_friends.txt" ) ) || {} )
Hermes.entities			= ( file.Exists("hermes_lists_entities.txt") && KeyValuesToTable( file.Read( "hermes_lists_entities.txt" ) ) || {} )
Hermes.files			= { "hermes", "hermes_load" }

Hermes.old.gcv			= GetConVar
Hermes.old.cve			= ConVarExists
Hermes.old.gcvn			= GetConVarNumber
Hermes.old.gcvs			= GetConVarString
Hermes.old.cccv			= CreateClientConVar
Hermes.old.ecc			= engineConsoleCommand
Hermes.old.acc			= AddConsoleCommand
Hermes.old.rcc			= RunConsoleCommand
Hermes.old.print		= print
Hermes.old.hook			= table.Copy( hook )
Hermes.old.concommand	= table.Copy( concommand )
Hermes.old.cvars		= table.Copy( cvars )
Hermes.old.file			= table.Copy( file )
Hermes.old.debug		= table.Copy( debug )
Hermes.old.pcc			= _R.Player.ConCommand
Hermes.old.cint			= _R.ConVar.GetInt
Hermes.old.cbool		= _R.ConVar.GetBool
Hermes.old.setmetatable = setmetatable
Hermes.old.getmetatable = getmetatable
Hermes.old.gmeta		= getmetatable( _G )
Hermes.old.hookmeta		= getmetatable( hook )

Hermes.set = {
	aiming = false,
	trigger = false,
	panel = nil,
	tar = nil,
	killed = false,
	angles = Angle( 0, 0, 0 ),
	fake = Angle( 0, 0, 0 ),
	target = false,
	recoil = false,
	path = "lua\\autorun\\client\\hermes.lua",
	usepath = {}
}

Hermes.deathsequences = {
	[ "models/barnacle.mdl" ] = { 4, 15 },
	[ "models/antlion_guard.mdl" ] = { 44 },
	[ "models/hunter.mdl" ] = { 124, 125, 126, 127, 128 }
}

//------------------------------
// ConVars:
//------------------------------
// Basic function that adds the cvars
function Hermes:ToBool( v )
	return math.floor( v ) == 1
end

function Hermes:CreateClientConVar( cvar, val, tblname, desc, menutyp, min, max, deci )
	local oldValue = val
	if ( type( val ) == "boolean" ) then
		val = val && 1 || 0
	end
	
	local fVar = "hermes_" .. cvar
	local info = { Name = tblname, CVar = fVar, Value = val, Min = min, Max = max, Type = type( oldValue ), Desc = desc, Menu = menutyp, Decimal = deci }

	local gVar = Hermes.old.cccv( "hermes_" .. cvar, val, true, false )
	if ( type( val ) == "number" || type( val ) == "boolean" ) then
		if ( !deci ) then
			Hermes.features[ tblname ] = gVar:GetInt()
		else
			Hermes.features[ tblname ] = tonumber( gVar:GetString() )
		end
	elseif ( type( val ) == "string" ) then
		Hermes.features[ tblname ] = gVar:GetString()
	end
	
	table.insert( Hermes.convars, cvar )
	
	Hermes.menuinfo[ cvar ] = info
	Hermes.menuinfo[ #Hermes.menuinfo + 1 ] = info
	
	cvars.AddChangeCallback( "hermes_" .. cvar, function( cvar, old, new ) 
		Hermes.features[ tblname ] = new
	end )
	return gVar
end

// You have to use tonumber to get convar numbers and that looks messy and ugly.
function Hermes:GetValue( tbl, val )
	if ( tonumber( tbl ) == val ) then
		return true
	end
	return false
end

// Checkboxes
Hermes:CreateClientConVar( "aim_shoot", false, "autoshoot", "Autoshoot", "aim" )
Hermes:CreateClientConVar( "aim_trigger", false, "triggerbot", "Triggerbot", "aim" )
Hermes:CreateClientConVar( "aim_triggerkey", false, "triggerkey", "Triggerkey", "aim" )
Hermes:CreateClientConVar( "aim_afterkill", false, "afterkill", "Disable After Kill", "aim" )
Hermes:CreateClientConVar( "aim_enablesmooth", false, "enablesmooth", "Smooth-aim", "aim" )
Hermes:CreateClientConVar( "aim_nospread", 1, "nospread", "Nospread", "aim" )
Hermes:CreateClientConVar( "aim_mode", 1, "mode", "Aim Mode", "aim" )
Hermes:CreateClientConVar( "aim_friendlyfire", false, "friendlyfire", "Friendly Fire", "aim" )
Hermes:CreateClientConVar( "aim_steam", false, "steam", "Target Steam  Friends", "aim" )
Hermes:CreateClientConVar( "aim_admin", false, "admins", "Target Admins", "aim" )
Hermes:CreateClientConVar( "aim_player", false, "players", "Target Players", "aim" )
Hermes:CreateClientConVar( "aim_vehicleaim", false, "vehicleaim", "Vehicle Aim", "aim" )
Hermes:CreateClientConVar( "aim_npc", false, "npcs", "Target NPCs", "aim" )
Hermes:CreateClientConVar( "aim_info", false, "info", "Aim Info", "aim" )

Hermes:CreateClientConVar( "esp_player", true, "playeresp", "Players", "esp" )
Hermes:CreateClientConVar( "esp_npc", true, "npcesp", "NPCs", "esp" )
Hermes:CreateClientConVar( "esp_weapon", false, "weaponesp", "Weapons", "esp" )
Hermes:CreateClientConVar( "esp_ragdoll", false, "ragdollesp", "Ragdolls", "esp" )
Hermes:CreateClientConVar( "esp_vehicle", false, "vehicleesp", "Vehicles", "esp" )
Hermes:CreateClientConVar( "esp_tttammo", false, "tttammo", "Ammoboxes", "esp" )
Hermes:CreateClientConVar( "esp_cross", true, "cross", "Visible Cross", "esp" )
Hermes:CreateClientConVar( "esp_showdead", false, "showdead", "Show Dead", "esp" )
Hermes:CreateClientConVar( "esp_otherpos", false, "otherpos", "Change Position", "esp" )
Hermes:CreateClientConVar( "esp_marker", false, "marker", "Marker", "esp" )

Hermes:CreateClientConVar( "vis_cham", true, "chams", "Normal Chams", "esp" )
Hermes:CreateClientConVar( "vis_xray", true, "xray", "Proxy Models", "esp" )
Hermes:CreateClientConVar( "vis_xrayxqz", true, "xrayxqz", "Proxy XQZ", "esp" )
Hermes:CreateClientConVar( "vis_cross", true, "crosshair", "Crosshair", "misc" )

Hermes:CreateClientConVar( "misc_speedhackenabled", false, "speedhack", "Speedhack", "misc" )
Hermes:CreateClientConVar( "misc_bhop", true, "bunnyhop", "Bunnyhop", "misc" )
Hermes:CreateClientConVar( "misc_autopistol", true, "autopistol", "Autopistol", "misc" )
Hermes:CreateClientConVar( "misc_radar", false, "radar", "Radar", "misc" )
Hermes:CreateClientConVar( "misc_adminlist", false, "adminlist", "Admin-list", "misc" )

// Sliders
Hermes:CreateClientConVar( "aim_triggerdistance", 0, "triggerdistance", "Triggerbot Distance", "aim", 0, 16384, false )
Hermes:CreateClientConVar( "aim_fov", 180, "fov", "Field-of-view", "aim", 0, 180, false )
Hermes:CreateClientConVar( "aim_smooth", 0.1, "smooth", "Smooth-aim", "aim", 0.1, 10, true )

Hermes:CreateClientConVar( "esp_maxespdis", 0, "maxespdis", "Maximum ESP Distance", "esp", 0, 16384, false )
Hermes:CreateClientConVar( "esp_maxchamdis", 0, "maxchamdis", "Maximum Cham Distance", "esp", 0, 16384, false )
Hermes:CreateClientConVar( "esp_trans", 255, "esptrans", "ESP Transparency", "esp", 0, 255, false )
Hermes:CreateClientConVar( "vis_transview", 255, "viewtrans", "Proxy Transparency", "esp", 0, 255, false )

Hermes:CreateClientConVar( "misc_radarradius", 1, "radarradius", "Radar Radius", "misc", 0, 16384, false )
Hermes:CreateClientConVar( "misc_speedhack", 1, "speedhackspeed", "Speedhack Amount", "misc", 2, 10, false )

//------------------------------
// Hooks:
//------------------------------
local oldCallHook = hook.Call

local function CallHook( name, gm, ... )
	if( Hermes.hooks[ name ] ) then
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

setmetatable( _G, { __metatable = true } )

// Add hooks
function Hermes:AddHook( name, func )
	Hermes.hooks[ name ] = func
end

//------------------------------
// Con-Commands:
//------------------------------
// engineConsoleCommand, it's a better and safer way to add console commands.
function engineConsoleCommand( p, c, a )
	local l = string.lower( c )
	if ( Hermes.commands[ l ] ) then
		Hermes.commands[ l ]( p, c, a )
		return true
	end
	return Hermes.old.ecc( p, c, a )
end

// Add commands
function Hermes:AddCommand( name, func )
	Hermes.commands[ name ] = func
	Hermes.old.acc( name )
end

//------------------------------
// Files:
//------------------------------
// Friends
function Hermes.AddFriends( e )
	table.insert( Hermes.friends, e:Nick() )
	file.Write( "hermes_lists_friends.txt", TableToKeyValues( Hermes.friends ) )
end

function Hermes.RemoveFriends( e )
	Hermes.friends[k] = nil
	file.Write( "hermes_lists_friends.txt", TableToKeyValues( Hermes.friends ) )
end

function Hermes.GetAddedFriends()
	local ply, players = LocalPlayer(), player.GetAll()
	
	local add = {}
	local rem = {}
	
	for k, e in pairs( player.GetAll() ) do
		if ( ValidEntity( e ) && e != ply ) then
			if ( table.HasValue( Hermes.friends, e:Nick() ) ) then
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
	
	if ( ValidEntity( e ) && e != ply ) then
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
		if ( ValidEntity( e ) && !table.HasValue( add, e:GetClass() ) && !table.HasValue( rem, e:GetClass() ) ) then
			if ( table.HasValue( Hermes.entities, e:GetClass() ) ) then
				table.insert( add, e:GetClass() )
			else
				table.insert( rem, e:GetClass() )
			end
		end
	end
	return add, rem
end

//------------------------------
// Function override:
//------------------------------
function GetConVar( cvar )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && ( Hermes.callpath == Hermes.set.path ) ) then return Hermes.old.gcv( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	return Hermes.old.gcv( cvar )
end

function ConVarExists( cvar )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && ( Hermes.callpath == Hermes.set.path ) ) then return Hermes.old.cve( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	if ( string.find( string.lower( cvar ), "sv_cheats" ) ) then return 0 end
	if ( string.find( string.lower( cvar ), "host_timescale" ) ) then return 1 end
	return Hermes.old.cve( cvar )
end

function GetConVarNumber( cvar )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && ( Hermes.callpath == Hermes.set.path ) ) then return Hermes.old.gcvn( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	if ( string.find( string.lower( cvar ), "sv_cheats" ) ) then return 0 end
	if ( string.find( string.lower( cvar ), "host_timescale" ) ) then return 1 end
	return Hermes.old.gcvn( cvar )
end

function GetConVarString( cvar )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && ( Hermes.callpath == Hermes.set.path ) ) then return Hermes.old.gcvs( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	if ( string.find( string.lower( cvar ), "sv_cheats" ) ) then return 0 end
	if ( string.find( string.lower( cvar ), "host_timescale" ) ) then return 1 end
	return Hermes.old.gcvs( cvar )
end

--[[
function file.Read( path, bool )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.file.Read( path, bool ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return Hermes.set.usepath[path] && Hermes.set.usepath[path].cont || nil
		end
	end
	return Hermes.old.file.Read( path, bool )
end

function file.Exists( path, bool )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.file.Exists( path, bool ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return Hermes.set.usepath[path] && true || false
		end
	end
	return Hermes.old.file.Exists( path, bool )
end

function file.Size( path )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.file.Size( path ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return Hermes.set.usepath[path] && Hermes.set.usepath[path].size || -1
		end
	end
	return Hermes.old.file.Size( path )
end

function file.Time( path )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.file.Time( path ) end
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return Hermes.set.usepath[path] && Hermes.set.usepath[path].time || 0
		end
	end
	return Hermes.old.file.Time( path )
end

function file.Find( path, bool )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.file.Find( path, bool ) end
	local o = Hermes.old.file.Find( path, bool )
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( path ), v ) ) then
			table.remove( o, k )
		end
	end
	return Hermes.old.file.Find( path, bool )
end

function file.FindInLua( path )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.file.Find( path ) end
	local o = Hermes.old.file.FindInLua( path )
	for k, v in pairs( Hermes.files ) do
		if ( string.find( string.lower( path ), v ) ) then
			table.remove( o, k )
		end
	end
	return Hermes.old.file.Find( path )
end]]

function _R.ConVar.GetInt( cvar )
	Hermes.callpath	= Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.cint( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar:GetName() ), v ) ) then
			return
		end
	end
	if ( string.find( string.lower( cvar:GetName() ), "sv_cheats" ) ) then return 0 end
	if ( string.find( string.lower( cvar:GetName() ), "host_timescale" ) ) then return 1 end
	return Hermes.old.cint( cvar )
end

function _R.ConVar.GetBool( cvar )
	Hermes.callpath	= Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.cbool( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar:GetName() ), v ) ) then
			return
		end
	end
	if ( string.find( string.lower( cvar:GetName() ), "sv_cheats" ) ) then return false end
	return Hermes.old.cbool( cvar )
end

function debug.getinfo( thread, func )
	Hermes.callpath	= Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.debug.getinfo( thread, func ) end
	return {}
end

//------------------------------
// Meta tables:
//------------------------------
function setmetatable( t, m )
	Hermes.callpath	= Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.setmetatable( t, m ) end
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
	Hermes.callpath	= Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.getmetatable( t ) end
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
// Fonts, Colors and Filters:
//------------------------------
// Console text.
function Hermes:ConsoleMessage( msg )
	return MsgN( "[Hermes]: " .. msg )
end

// Max screen, so useless shit that you don't see is drawn.
function Hermes:OnScreen( e )
	local x, y, pos, pos2, pos3 = ScrW(), ScrH(), e:LocalToWorld( e:OBBMaxs() ):ToScreen(), e:LocalToWorld( e:OBBMins() ):ToScreen(), e:LocalToWorld( e:OBBCenter() ):ToScreen()
	if ( pos.x > 0 && pos.y > 0 && pos.x < x && pos.y < y || pos2.x > 0 && pos2.y > 0 && pos2.x < x && pos2.y < y || pos3.x > 0 && pos3.y > 0 && pos3.x < x && pos3.y < y ) then
		return true
	end
	return false
end

// TTT traitor detector
Hermes.traitors = {}
Hermes.senttext = false
Hermes.traitorsweps = { "weapon_ttt_c4", "weapon_ttt_knife", "weapon_ttt_phammer", "weapon_ttt_sipistol", "weapon_ttt_flaregun", "weapon_ttt_push", "weapon_ttt_radio", "weapon_ttt_teleport" }
Hermes.getweapons = _R['Player'].GetWeapons
function Hermes.GetTraitor()
	if ( !string.find( string.lower( GAMEMODE.Name ), "trouble in terror" ) ) then return end //trouble in terror
	local ent, ply = player.GetAll(), LocalPlayer()
	
	if ( !Hermes.senttext ) then
		Hermes:ConsoleMessage( "Trouble in Terrorist Town gamemode detected, using traitor detection method..." )
		Hermes.senttext = true
	end
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		if ( ValidEntity( e ) && e != ply ) then
			local weps = Hermes.getweapons( e )
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

local oldUserMSG = usermessage.IncomingMessage
function usermessage.IncomingMessage( name, um, ... )
	if ( name == "ttt_role" ) then
		Hermes.traitors = {}
	end
	
	return oldUserMSG( name, um, ... )
end
	
// TTT ammoboxes
Hermes.TTTAmmo = {
	"item_ammo_revolver_ttt",
	"item_ammo_357_ttt",
	"item_box_buckshot_ttt",
	"item_ammo_pistol_ttt",
}

// If an entity is a dead body we can detect it.
local function IsRagdoll( e )
	if ( ( e:GetClass() == "prop_ragdoll" ) || ( e:GetClass() == "class C_ClientRagdoll" ) || ( e:GetClass() == "class C_HL2MPRagdoll" ) ) then
		return true
	end
	return false
end

// If it's a vehicle.
local function IsVehicle( e )
	if ( string.find( e:GetClass(), "prop_vehicle_" ) != nil ) then
		return true
	end
	return false
end

// Entities that are allowed to draw.
function Hermes:FilterEntities( e, use )
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	if ( use == true ) then
		if ( !ValidEntity( e ) ) then return false end
		if ( !Hermes:OnScreen(e) ) then return false end
		if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !IsRagdoll(e) && !IsVehicle( e ) && !table.HasValue( Hermes.entities, e:GetClass() ) && !table.HasValue( Hermes.TTTAmmo, e:GetClass() ) || e == ply ) then return false end
		if ( e:IsPlayer() && Hermes:GetValue( Hermes.features.showdead, 0 ) && !e:Alive() || e:IsPlayer() && Hermes:GetValue( Hermes.features.showdead, 0 ) && e:Health() <= 0 ) then return false end
		if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
		if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		if ( e:IsWeapon() && e:GetMoveType() == MOVETYPE_NONE ) then return false end
		if ( !Hermes:GetValue( Hermes.features.maxespdis, 0 ) && math.Round( e:GetPos():Distance( ply:GetShootPos() ) ) > tonumber( Hermes.features.maxespdis ) ) then return false end
		return true
	elseif ( use == false ) then
		if ( !ValidEntity( e ) ) then return false end
		if ( e:GetMoveType() == MOVETYPE_NONE ) then return false end
		if ( !Hermes:OnScreen(e) ) then return false end
		if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !IsRagdoll(e) || e == ply ) then return false end
		if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
		if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
		if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		if ( e:IsWeapon() && e:GetMoveType() != MOVETYPE_NONE ) then return false end
		if ( !Hermes:GetValue( Hermes.features.maxchamdis, 0 ) && math.Round( e:GetPos():Distance( ply:GetShootPos() ) ) > tonumber( Hermes.features.maxchamdis ) ) then return false end
		return true
	end
	return true
end

function Hermes:FilterRadarEntities( e )
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	if ( !ValidEntity( e ) ) then return false end
	if ( e:GetMoveType() == MOVETYPE_NONE ) then return false end
	if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() || e == ply ) then return false end
	if ( e:IsPlayer() && Hermes:GetValue( Hermes.features.showdead, 0 ) && !e:Alive() || e:IsPlayer() && Hermes:GetValue( Hermes.features.showdead, 0 ) && e:Health() <= 0 ) then return false end
	if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
	return true
end

// If a player is an admin:
function Hermes:IsAdmin( e )
	if ( e:IsAdmin() ) then 
		return true
	elseif ( e:IsSuperAdmin() ) then 
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

// Target colors.
function Hermes:TargetColors( e )
	local col
	
	local a = tonumber( Hermes.features.esptrans )
	if ( e:IsPlayer() ) then
		if ( !table.HasValue( Hermes.traitors, e ) ) then
			local tc = team.GetColor( e:Team() )
			col = Color( tc.r, tc.g, tc.b, a )
		elseif ( table.HasValue( Hermes.traitors, e ) ) then
			col = Color( 255, 0, 0, a )
		end
	elseif ( e:IsNPC() ) then
		if ( !IsEnemyEntityName( e:GetClass() ) && !( e:GetClass() == "npc_metropolice" ) ) then
			col = Color( 0, 100, 0, a )
		elseif ( IsEnemyEntityName( e:GetClass() ) || ( e:GetClass() == "npc_metropolice" ) ) then
			col = Color( 230, 0, 0, a )
		end
	elseif ( e:IsWeapon() ) then
		col = Color( 215, 100, 0, a )
	elseif ( IsRagdoll(e) ) then
		col = Color( 255, 255, 255, a )
	elseif ( IsVehicle(e) ) then
		col = Color( 128, 64, 0, a )
	elseif ( table.HasValue( Hermes.entities, e:GetClass() ) ) then
		col = Color( 64, 0, 128, a )
	elseif ( table.HasValue( Hermes.TTTAmmo, e:GetClass() ) ) then
		col = Color( 0, 255, 255, a )
	end
	return col
end

// Position of Players and NPCs. otherpos
local hppos = ""
function Hermes:CreatePos( e )
	local ply, pos = LocalPlayer(), ""
	local col = Hermes:TargetColors( e )
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
	
	local d, v, t, a = math.Round( e:GetPos():Distance( ply:GetShootPos() ) )
	if ( e:IsPlayer() ) then v = d / 20 else v = d / 40 end
	
	a = 10
	if ( e:IsPlayer() && table.HasValue( Hermes.traitors, e ) ) then 
		v = d / 10
		a = 0
	end
		
	t = d / 35
	
	if ( Hermes:GetValue( Hermes.features.otherpos, 0 ) ) then
		pos = e:LocalToWorld( top + top ) + Vector( 0, 0, v + a )
		hppos = e:LocalToWorld( top + top ) + Vector( 0, 0, t + 10 )
	else
		pos = e:LocalToWorld( e:OBBMaxs() ) + Vector( 0, 0, v + a )
		hppos = e:LocalToWorld( e:OBBMaxs() ) + Vector( 0, 0, t + 10 )
	end
	
	if ( e:IsWeapon() || IsRagdoll(e) || IsVehicle(e) || table.HasValue( Hermes.entities, e:GetClass() ) ) then pos = e:LocalToWorld( e:OBBCenter() ) end
	
	local FRT 	= center + frt + rgt + top; FRT = FRT:ToScreen()
	local BLB 	= center + bak + lft + btm; BLB = BLB:ToScreen()
	local FLT	= center + frt + lft + top; FLT = FLT:ToScreen()
	local BRT 	= center + bak + rgt + top; BRT = BRT:ToScreen()
	local BLT 	= center + bak + lft + top; BLT = BLT:ToScreen()
	local FRB 	= center + frt + rgt + btm; FRB = FRB:ToScreen()
	local FLB 	= center + frt + lft + btm; FLB = FLB:ToScreen()
	local BRB 	= center + bak + rgt + btm; BRB = BRB:ToScreen()
	
	pos = pos:ToScreen()
	hppos = hppos:ToScreen()
	
	local maxX = math.max( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local minX = math.min( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local maxY = math.max( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y)
	local minY = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	
	return maxX, minX, maxY, minY, pos
end

// draw.DrawText with yalign.
function Hermes:DrawText( text, font, x, y, colour, xalign, yalign )
	if ( font == nil ) then font = "Default" end
	if ( x == nil ) then x = 0 end
	if ( y == nil ) then y = 0 end
	
	local curX, curY, curString = x, y, ""
	
	surface.SetFont( font )
	local sizeX, lineHeight = surface.GetTextSize( "\n" )
	
	for i = 1, string.len( text ) do
		local ch = string.sub( text, i, i )
		if ( ch == "\n" ) then
			if ( string.len( curString ) > 0 ) then
				draw.SimpleText( curString, font, curX, curY, colour, xalign, yalign )
			end
			
			curY, curX, curString = curY + ( lineHeight / 2 ), x, ""
			
		elseif ( ch == "\t" ) then
			if ( string.len( curString ) > 0 ) then
				draw.SimpleText( curString, font, curX, curY, colour, xalign, yalign )
			end
			local tmpSizeX,tmpSizeY = surface.GetTextSize( curString )
			curX = math.ceil( ( curX + tmpSizeX ) / 50 ) * 50
			curString = ""
		else
			curString = curString .. ch
		end
	end	
	if ( string.len( curString ) > 0 ) then
		draw.SimpleText( curString, font, curX, curY, colour, xalign, yalign )
	end
end

//******************************
// Aimbot
//******************************
// Zoom
local zoom, zoomnum = 0, 0

local function ZoomIn() 
	zoomnum = zoomnum + 1 
end
local function ZoomOut() 
	zoomnum = zoomnum - 1 
end

Hermes:AddCommand( "+hermes_zoomin", ZoomIn )
Hermes:AddCommand( "-hermes_zoomin", ZoomOut )

Hermes:AddCommand( "+hermes_zoomout", ZoomOut )
Hermes:AddCommand( "-hermes_zoomout", ZoomIn )

// Nospread module, syshack.dll.
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

local CustomCones 	= {}
CustomCones.Weapons = {}
CustomCones.Weapons[ "weapon_pistol" ]			= { cone = WeaponVector( 0.0100, true, false ) }	// HL2 Pistol
CustomCones.Weapons[ "weapon_smg1" ]			= { cone = WeaponVector( 0.04362, true, false ) }	// HL2 SMG1
CustomCones.Weapons[ "weapon_ar2" ]				= { cone = WeaponVector( 0.02618, true, false ) }	// HL2 AR2
CustomCones.Weapons[ "weapon_shotgun" ]			= { cone = WeaponVector( 0.08716, true, false ) }	// HL2 SHOTGUN
CustomCones.Weapons[ "weapon_zs_zombie" ]		= { cone = WeaponVector( 0.0100, true, false ) }	// REGULAR ZOMBIE HAND
CustomCones.Weapons[ "weapon_zs_fastzombie" ]	= { cone = WeaponVector( 0.04362, true, false ) }	// FAST ZOMBIE HAND

local function GetCone( typ, v, i )
	local ply = LocalPlayer()
		if !( typ ) then return "NULL" end
		if ( typ[v] ) then return typ[v] end
		
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
			
		if ( wep && wep:IsValid() ) then
			local weptable = wep:GetTable()
				
			function weptable:ViewModelDrawn()
				if ( WinIsOn && OnViewModelRender ) then
					OnViewModelRender()
				end
			end
					
			local override = {}
			for c, s in pairs( CustomCones.Weapons ) do
				if ( string.match( string.lower( wep:GetClass() ), c ) ) then
					override = s
					break
				end
			end
			
			cone = ( override.cone || tonumber( GetCone( weptable, "Cone" ) ) || 0 )
			numshots = ( override.numshots || tonumber( GetCone( weptable, "NumShots" ) ) || 0 )
				
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

// Nospread type.
function Hermes.NospreadType( ucmd )
	if ( Hermes:GetValue( Hermes.features.nospread, 1 ) ) then return end
	if ( Hermes:GetValue( Hermes.features.nospread, 2 ) ) then
		if ( Hermes.set.aiming ) then
			return true
		end
	elseif ( Hermes:GetValue( Hermes.features.nospread, 3 ) ) then
		if ( Hermes.set.target ) then
			return true
		end
	elseif ( Hermes:GetValue( Hermes.features.nospread, 4 ) ) then
		if ( ucmd:GetButtons() & IN_ATTACK > 0 ) then
			return true
		end
	elseif ( Hermes:GetValue( Hermes.features.nospread, 5 ) ) then
		return true
	end
	return false
end

// Simple way to add bones or vectors.
function Hermes:GetPos( e, pos )
	if ( type( pos ) == "string" ) then
		return ( e:GetBonePosition( e:LookupBone( pos ) ) )
	elseif ( type( pos ) == "Vector" ) then
		return ( e:LocalToWorld( pos ) )
	end
	return ( e:LocalToWorld( pos ) )
end

// Weapon prediction
Hermes.PredictWeapons = {
		["weapon_crossbow"] = 3110,
	}

function Hermes:WeaponPrediction( e, pos )
	local ply = LocalPlayer()
	if ( ValidEntity( e ) && ( type( e:GetVelocity() ) == "Vector" ) ) then
		local dis, wep = e:GetPos():Distance( ply:GetPos() ), ( ply.GetActiveWeapon && ValidEntity( ply:GetActiveWeapon() ) && ply:GetActiveWeapon():GetClass() )
		if ( wep && Hermes.PredictWeapons[ wep ]  ) then
			local t = dis / Hermes.PredictWeapons[ wep ]
			return ( pos + e:GetVelocity() * t )
		end
		return pos
	end
	return pos
end

// Aimspot when aiming.
function Hermes:TargetLocation( e )
	if ( !ValidEntity( e ) ) then return false end
	local pos, vec = e:LocalToWorld( e:OBBCenter() ), false
	
	pos = Hermes:GetPos( e, "ValveBiped.Bip01_Head1" )
	
	if ( e:IsPlayer() ) then
		pos = e:GetAttachment( e:LookupAttachment( "eyes" ) ).Pos; vec = true
		if ( ( e:GetAttachment( e:LookupAttachment( "forward" ) ) ) ) then
			pos = e:GetAttachment( e:LookupAttachment( "forward" ) ).Pos
		elseif ( pos != 0 ) then
			pos = Hermes:GetPos( e, "ValveBiped.Bip01_Head1" )
		end
	end
	
	local m = e:GetModel()
	if ( m == "models/crow.mdl" || m == "models/pigeon.mdl" ) then 	pos = Hermes:GetPos( e, Vector( 0, 0, 5 ) ) end
	if ( m == "models/seagull.mdl" ) then 							pos = Hermes:GetPos( e, Vector( 0, 0, 6 ) ) end
	if ( m == "models/combine_scanner.mdl" ) then 					pos = Hermes:GetPos( e, "Scanner.Body" ) end
	if ( m == "models/hunter.mdl" ) then 							pos = Hermes:GetPos( e, "MiniStrider.body_joint" ) end
	if ( m == "models/combine_turrets/floor_turret.mdl" ) then		pos = Hermes:GetPos( e, "Barrel" ) end
	if ( m == "models/dog.mdl" ) then 								pos = Hermes:GetPos( e, "Dog_Model.Eye" ) end
	if ( m == "models/vortigaunt.mdl" ) then 						pos = Hermes:GetPos( e, "ValveBiped.Head" ) end
	if ( m == "models/antlion.mdl" ) then 							pos = Hermes:GetPos( e, "Antlion.Body_Bone" ) end
	if ( m == "models/antlion_guard.mdl" ) then 					pos = Hermes:GetPos( e, "Antlion_Guard.Body" ) end
	if ( m == "models/antlion_worker.mdl" ) then 					pos = Hermes:GetPos( e, "Antlion.Head_Bone" ) end
	if ( m == "models/zombie/fast_torso.mdl" ) then 				pos = Hermes:GetPos( e, "ValveBiped.HC_BodyCube" ) end
	if ( m == "models/zombie/fast.mdl" ) then 						pos = Hermes:GetPos( e, "ValveBiped.HC_BodyCube" ) end
	if ( m == "models/headcrabclassic.mdl" ) then 					pos = Hermes:GetPos( e, "HeadcrabClassic.SpineControl" ) end
	if ( m == "models/headcrabblack.mdl" ) then 					pos = Hermes:GetPos( e, "HCBlack.body" ) end
	if ( m == "models/headcrab.mdl" ) then 							pos = Hermes:GetPos( e, "HCFast.body" ) end
	if ( m == "models/zombie/poison.mdl" ) then 					pos = Hermes:GetPos( e, "ValveBiped.Headcrab_Cube1" ) end
	if ( m == "models/zombie/classic.mdl" ) then 					pos = Hermes:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/zombie/classic_torso.mdl" ) then 				pos = Hermes:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/zombie/zombie_soldier.mdl" ) then				pos = Hermes:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/combine_strider.mdl" ) then 					pos = Hermes:GetPos( e, "Combine_Strider.Body_Bone" ) end
	if ( m == "models/combine_dropship.mdl" ) then 					pos = Hermes:GetPos( e, "D_ship.Spine1" ) end
	if ( m == "models/combine_helicopter.mdl" ) then 				pos = Hermes:GetPos( e, "Chopper.Body" ) end
	if ( m == "models/gunship.mdl" ) then 							pos = Hermes:GetPos( e, "Gunship.Body" ) end
	if ( m == "models/lamarr.mdl" ) then 							pos = Hermes:GetPos( e, "HeadcrabClassic.SpineControl" ) end
	if ( m == "models/mortarsynth.mdl" ) then 						pos = Hermes:GetPos( e, "Root Bone" ) end
	if ( m == "models/synth.mdl" ) then 							pos = Hermes:GetPos( e, "Bip02 Spine1" ) end
	if ( m == "mmodels/vortigaunt_slave.mdl" ) then 				pos = Hermes:GetPos( e, "ValveBiped.Head" ) end
	
	return Hermes:WeaponPrediction( e, pos )
end

// Allow only these entities to be targeted.
function Hermes:ValidTargets( e )
	if ( !ValidEntity( e ) ) then return false end
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	if ( e:GetMoveType() == MOVETYPE_NONE ) then return false end
	if ( ply:InVehicle() ) then return false end
	if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() ) ) then return false end
	if ( e:IsPlayer() && Hermes:GetValue( Hermes.features.players, 0 ) ) then return false end
	if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
	if ( e:IsPlayer() && e:Team() == ply:Team() && Hermes:GetValue( Hermes.features.friendlyfire, 0 ) ) then return false end
	if ( e:IsPlayer() && ( e:GetFriendStatus() == "friend" ) && Hermes:GetValue( Hermes.features.steam, 0 ) ) then return false end
	if ( e:IsPlayer() && e:IsAdmin() && Hermes:GetValue( Hermes.features.admins, 0 ) ) then return false end
	if ( e:IsPlayer() && table.HasValue( Hermes.friends, e:Nick() ) ) then return false end
	if ( e:IsPlayer() && e:InVehicle() && Hermes:GetValue( Hermes.features.vehicleaim, 0 ) ) then return false end
	if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	if ( e:IsNPC() && Hermes:GetValue( Hermes.features.npcs, 0 ) ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
	return true
end

function Hermes.DeadTarget( e )
	if ( !ValidEntity( e ) ) then return end
	if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE ) then return false end
	return true
end

// Get my shoot trace
function Hermes:AimTrace()
	local ply = LocalPlayer()
	local start, endP = ply:GetShootPos(), ply:GetAimVector()
	
	local trace = {}
	trace.start = start
	trace.endpos = start + ( endP * 16384 )
	trace.filter = { ply }
	
	return util.TraceLine( trace )	
end

// Make sure the target is visible.
function Hermes:VisibleTarget( e )
	if ( !ValidEntity( e ) ) then return false end
	
	local ply, loc = LocalPlayer(), Hermes:TargetLocation( e )
	
	local etrace = {
		start = ply:GetShootPos(),
		endpos = loc,
		filter = { ply, e }
	}
	local trace = util.TraceLine( etrace )
	
	if ( trace.Fraction == 1 ) then
		return true
	end
	return false
end

// Insert into table.
function Hermes.MakeSureAllTargetsAreValid()
	local targets = {}
	
	local ent
	if ( Hermes:GetValue( Hermes.features.npcs, 0 ) ) then
		ent = player.GetAll()
	else ent = ents.GetAll() end
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		if ( ValidEntity( e ) && Hermes:ValidTargets( e ) && Hermes:VisibleTarget( e ) ) then
			table.insert( targets, e )
		end
	end
	return targets
end

// Get the target
local tar, target = nil

function Hermes:GetTarget()
	local x, y = ScrW(), ScrH()
	if ( !Hermes.set.aiming ) then return end
	local targets = Hermes.MakeSureAllTargetsAreValid()
	local ent, ply, trace = targets, LocalPlayer(), Hermes:AimTrace()
	
	local myPos, myAng, myAngV = ply:EyePos(), ply:GetAimVector(), ply:GetAngles()
	
	tar = nil
	if ( !Hermes:ValidTargets( tar ) || !Hermes:VisibleTarget( tar ) ) then
		tar = LocalPlayer()
		
		for i = 1, table.Count( ent ) do
			local e = ent[i]
		
				local ang = ( e:GetPos() - ply:GetShootPos() ):Angle()
				local angY = math.abs( math.NormalizeAngle( myAngV.y - ang.y ) )
				local angP = math.abs( math.NormalizeAngle( myAngV.p - ang.p ) )
			
				local angA, angB = 0
			
					if ( angY < tonumber( Hermes.features.fov ) && angP < tonumber( Hermes.features.fov ) ) then
				local ePos, oldPos = e:EyePos():ToScreen(), tar:EyePos():ToScreen()
				
				if ( Hermes:GetValue( Hermes.features.mode, 1 ) ) then
					angA = math.Dist( x / 2, y / 2, oldPos.x, oldPos.y )
					angB = math.Dist( x / 2, y / 2, ePos.x, ePos.y )
				elseif ( Hermes:GetValue( Hermes.features.mode, 2 ) ) then
					angA = tar:EyePos():Distance( ply:EyePos() )
					angB = e:EyePos():Distance( ply:EyePos() )
				elseif ( Hermes:GetValue( Hermes.features.mode, 3 ) ) then
					angA = tar:Health()
					angB = e:Health()
				elseif ( Hermes:GetValue( Hermes.features.mode, 4 ) ) then
					if ( e:IsPlayer() ) then
						local domath1 = ( ( ( ply:EyePos() - tar:GetShootPos() ):GetNormal() ):Angle() ) - tar:EyeAngles()
						local domath2 = ( ( ( ply:EyePos() - e:GetShootPos() ):GetNormal() ):Angle() ) - e:EyeAngles()
						angA = ( ( math.abs( domath1.p / 2 ) + math.abs( domath1.y ) ) - 540 * -1 )
						angB = ( ( math.abs( domath2.p / 2 ) + math.abs( domath2.y ) ) - 540 * -1 )
					else
						angA = 1
						angB = 5
					end
				end
				
				if ( angB <= angA ) then
					tar = e
				elseif ( tar == ply ) then
					tar = e
				end
			end
		end
	end
	return tar
end

// Trigger bot
function Hermes.Triggerbot()
	local ply = LocalPlayer()
	if ( Hermes:GetValue( Hermes.features.triggerbot, 1 ) ) then
	if ( Hermes:GetValue( Hermes.features.triggerkey, 1 ) && !Hermes.set.trigger ) then return end
	
		local trace = Hermes:AimTrace()
		
		if ( ValidEntity( trace.Entity ) && Hermes:ValidTargets( trace.Entity ) ) then
		
			local pos = ply:GetPos():Distance( trace.Entity:GetPos() )
			if ( ( tonumber( Hermes.features.triggerdistance ) > pos ) || ( Hermes:GetValue( Hermes.features.triggerdistance, 0 ) ) ) then
				Hermes.old.rcc( "+attack" )
				timer.Simple( 0.1, function() Hermes.old.rcc( "-attack" ) end )
			end
		end
	end
end

// Stole from fappy cuz I black
function Hermes.SmoothAngles( ang )
	if ( Hermes:GetValue( Hermes.features.enablesmooth, 0 ) ) then return ang end
	local ply = LocalPlayer()
	local p, y, r = ang.p, ang.y, ang.r
	
	local curang = ply:EyeAngles()
	local speed = tonumber( Hermes.features.smooth )
	local retangle = Angle( 0, 0, 0 )
	
	retangle.p = math.Approach( math.NormalizeAngle( curang.p ), math.NormalizeAngle( p ), speed )
	retangle.y = math.Approach( math.NormalizeAngle( curang.y ), math.NormalizeAngle( y ), speed )
	retangle.r = 0
	
	return Angle( retangle.p, retangle.y, retangle.r )
end

// Build no-recoil fix
function Hermes.GetAngles( angle, ucmd )
	local ply, correct = LocalPlayer(), 1
	if ( zoom != 0 ) then correct = ( 1 - ( zoom / 100 ) ) end
	if !( IsValid( ply:GetActiveWeapon() ) && ( ply:GetActiveWeapon():GetClass() == "weapon_physgun" ) && ( ucmd:GetButtons() & IN_USE ) > 0 ) then
		angle.y = math.NormalizeAngle( angle.y + ( ucmd:GetMouseX() * -0.022 * correct ) )
		angle.p = math.Clamp( angle.p + ( ucmd:GetMouseY() * 0.022 * correct ), -89, 90 )
	end
end

// Bunnyhop
local jump = false

function Hermes.AllowBunnyhop()
	local ply = LocalPlayer()
	if ( ply:KeyDown( IN_JUMP ) ) then
		return true
	end
	return false
end

function Hermes.Bunnyhop()
	local ply = LocalPlayer()
	if ( Hermes:GetValue( Hermes.features.bunnyhop, 1 ) && input.IsKeyDown( KEY_SPACE ) && Hermes.AllowBunnyhop() ) then
		if ( !jump ) then
			Hermes.old.rcc( "+jump" )
			jump = true
		elseif ( jump ) then
			Hermes.old.rcc( "-jump" )
			jump = false
		end
	elseif ( Hermes:GetValue( Hermes.features.bunnyhop, 1 ) && input.IsKeyDown( KEY_SPACE ) ) then
		if ( !jump ) then
			Hermes.old.rcc( "-jump" )
			jump = true
		end
	end
end

// Autopistol
local shoot = false

function Hermes.AutomaticWeapon()
	if ( string.find( string.lower( GAMEMODE.Name ), "trouble in terror" ) ) then return false end
	local ply, weps = LocalPlayer(), { "gmod_tool", "weapon_pistol" }
	
	if ( !ValidEntity( ply ) || !ply:Alive() || !ply:GetActiveWeapon():IsValid() ) then return false end
	if ( !ply:KeyDown( IN_ATTACK ) ) then return false end
	
	local wep = ply:GetActiveWeapon()
	if ( table.HasValue( weps, wep:GetClass() ) ) then
		return true
	elseif ( wep.Primary && !wep.Primary.Automatic ) then
		return true
	end
	return false
end

function Hermes.Autopistol()
	local ply = LocalPlayer()
	
	if ( Hermes:GetValue( Hermes.features.autopistol, 1 ) && input.IsMouseDown( MOUSE_LEFT ) && Hermes.AutomaticWeapon( ucmd ) ) then
		Hermes.old.rcc( "+attack" )
		timer.Simple( 0.0001, function() Hermes.old.rcc( "-attack" ) end )
	end
end

// Autoreload
local reloadtime = 0

function Hermes.Autoreload()
	local ply = LocalPlayer()
	
	if ( ply:GetActiveWeapon() && reloadtime - CurTime() <= 0 ) then
		if ( ValidEntity( ply ) && ply:Alive() && ply:GetActiveWeapon():IsValid() ) then
			local ammo = ply:GetActiveWeapon():Clip1()
			
			if ( ammo == 0 ) then
				time = CurTime() + 4
				Hermes.old.rcc( "+reload" )
				timer.Simple( 0.01, function() Hermes.old.rcc( "-reload" ) end )
			end
		end
	end
end

// Aimbot HUD
function Hermes.AimHUD()
	if ( Hermes.set.aiming && !Hermes.set.target ) then
		draw.SimpleText( "Scanning...", "ScoreboardText", ( ScrW() / 2 ), ( ScrH() / 2 ) + 40, Color( 255, 0, 0, 255 ), 1, 1 )
	elseif ( Hermes.set.target ) then
		draw.SimpleText( "Target Locked", "ScoreboardText", ( ScrW() / 2 ), ( ScrH() / 2 ) + 40, Color( 0, 255, 0, 255 ), 1, 1 )
	end
	
	if ( Hermes:GetValue( Hermes.features.info, 1 ) ) then
		local aiming, triggerbot, autoshoot = Hermes.set.aiming, tobool( Hermes.features.triggerbot ), tobool( Hermes.features.autoshoot )
		local aimtext, trigtext, autotext, nospread
		
		if ( aiming ) then
			aimtext = "Enabled"
		else aimtext = "Disabled" end
		
		if ( triggerbot ) then
			trigtext = "Enabled"
		else trigtext = "Disabled" end
		
		if ( autoshoot ) then
			autotext = "Enabled"
		else autotext = "Disabled" end
		
		if ( Hermes:GetValue( Hermes.features.nospread, 1 ) ) then
			nospread = "Disabled"
		elseif ( Hermes:GetValue( Hermes.features.nospread, 2 ) ) then
			nospread = "When Aiming"
		elseif ( Hermes:GetValue( Hermes.features.nospread, 3 ) ) then
			nospread = "On Target Lock"
		elseif ( Hermes:GetValue( Hermes.features.nospread, 4 ) ) then
			nospread = "In Attack"
		elseif ( Hermes:GetValue( Hermes.features.nospread, 5 ) ) then
			nospread = "Allways"
		end
		
		draw.RoundedBox( 0, ( ScrW() / 2 ) - 100, 5, 200, 85, Color( 255, 0, 0, 100 ) )
		
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawOutlinedRect( ( ScrW() / 2 ) - 100, 5, 200, 85 )
		
		draw.SimpleText( "Aiming: " .. aimtext, "ScoreboardText", ( ScrW() / 2 ), 15, Color( 255, 255, 255, 255 ), 1, 1 )
		draw.SimpleText( "Nospread: " .. nospread, "ScoreboardText", ( ScrW() / 2 ), 35, Color( 255, 255, 255, 255 ), 1, 1 )
		draw.SimpleText( "Autoshoot: " .. autotext, "ScoreboardText", ( ScrW() / 2 ), 55, Color( 255, 255, 255, 255 ), 1, 1 )
		draw.SimpleText( "Triggerbot: " .. trigtext, "ScoreboardText", ( ScrW() / 2 ), 75, Color( 255, 255, 255, 255 ), 1, 1 )
	end
end

// Aim at the target
function Hermes.Aim( ucmd )
	local ply = LocalPlayer()
	target = Hermes:GetTarget()
	
	Hermes.set.target = false
	cone = cone || 0
	
	local mouse = Angle( ucmd:GetMouseY() * Hermes.old.gcvn( "m_pitch" ), ucmd:GetMouseX() * -Hermes.old.gcvn("m_yaw") ) || Angle( 0, 0, 0 )
	Hermes.set.angles = Hermes.set.angles + mouse
	
	Hermes.set.angles.p = math.NormalizeAngle( Hermes.set.angles.p )
	Hermes.set.angles.y = math.NormalizeAngle( Hermes.set.angles.y )
	
	Hermes.GetAngles( Hermes.set.angles, ucmd )
	ucmd:SetViewAngles( Hermes.set.angles )
	
	Hermes.Triggerbot()
	Hermes.Bunnyhop()
	Hermes.Autopistol()
	Hermes.Autoreload()
	
	Hermes.set.fake = Angle( Hermes.set.angles.p, Hermes.set.angles.y, Hermes.set.angles.r )
	if ( Hermes.NospreadType( ucmd ) ) then
		if ( cone == 0 ) then end
		Hermes.set.fake = hack.CompensateWeaponSpread( ucmd, Vector( -cone, -cone, -cone ), Hermes.set.angles:Forward() ):Angle()
		ucmd:SetViewAngles( Hermes.set.fake )
	end
	
	if ( !Hermes.set.aiming ) then return end
	if ( target == nil || target == ply ) then return end
	
	local aim, myPos, setView = Hermes:TargetLocation( target ), ply:GetShootPos(), 0
	aim = aim + ( target:GetVelocity() / 45 - ply:GetVelocity() / 45 )
	Hermes.set.angles = ( aim - myPos ):Angle()
	
	Hermes.set.angles = Hermes.SmoothAngles( Hermes.set.angles )
	
	if ( Hermes.NospreadType( ucmd ) ) then
		setview = hack.CompensateWeaponSpread( ucmd, Vector( -cone, -cone, -cone ), Hermes.set.angles:Forward() ):Angle()
	else setview = Hermes.set.angles end
	
	setview.p = math.NormalizeAngle( setview.p )
	setview.y = math.NormalizeAngle( setview.y )
	setview.r = math.NormalizeAngle( setview.r )
	
	ucmd:SetViewAngles( setview )
	
	Hermes.set.target = true
	
	if ( Hermes:GetValue( Hermes.features.autoshoot, 1 ) && !Hermes:GetValue( Hermes.features.triggerbot, 1 ) ) then
		Hermes.old.rcc( "+attack" )
		timer.Simple( 0.1, function() Hermes.old.rcc( "-attack" ) end )
	end
end
Hermes:AddHook( "CreateMove", Hermes.Aim )

// Recoil removal
function Hermes.NoRecoil( ply, origin, angles, FOV )
	local ply, zoomFOV = LocalPlayer(), FOV
	local wep = ply:GetActiveWeapon()
	
	// SWEP no-recoil.
	if ( wep.Primary ) then wep.Primary.Recoil = 0 end
	if ( wep.Secondary ) then wep.Secondary.Recoil = 0 end
	
	// Zoom view
	zoom = math.Clamp( zoom + ( zoomnum * 140 * FrameTime() ), 0, 80 )
	
	if ( zoom > 0 ) then
		zoomFOV = 90 - zoom
	else zoomFOV = FOV end
	
	// No visual recoil.
	local view = GAMEMODE:CalcView( ply, origin, Hermes.set.angles, zoomFOV ) || {}
	view.angles = Hermes.set.angles
	view.angles.r = 0
	view.fov = zoomFOV
	return view
end
Hermes:AddHook( "CalcView", Hermes.NoRecoil )

// Add console commands
Hermes:AddCommand( "+hermes_aim", function() Hermes.set.aiming = true target = nil end )
Hermes:AddCommand( "-hermes_aim", function() Hermes.set.aiming = false Hermes.set.target = false target = nil end )

Hermes:AddCommand( "+hermes_trigger", function() Hermes.set.trigger = true end )
Hermes:AddCommand( "-hermes_trigger", function() Hermes.set.trigger = false end )

//******************************
// HUD
//******************************

// Colors for targets that are visible.
function Hermes:VisibleColors( e )
	if ( !ValidEntity( e ) ) then return false end
	if ( Hermes:VisibleTarget( e ) ) then
		local col = Color( 0, 255, 0, 255 )
		return col
	end
	local col = Color( 0, 0, 255, 255 )
	return col
end

// A health bar for players.
function Hermes:HealthBar( e )
	if ( e:IsPlayer() && e:Health() > 300 || !e:Alive() ) then return end
	
	local col, normalhp = Hermes:TargetColors(e), 100
	Hermes:CreatePos( e )
	
	if( e:Health() > normalhp ) then
		normalhp = e:Health()
	end
	
	local dmg, nor = normalhp / 4, e:Health() / 4
	
	hppos.x = hppos.x - ( dmg / 2 )
	hppos.y = hppos.y + 15
	
	if ( Hermes:GetValue( Hermes.features.otherpos, 1 ) ) then
		hppos.x = hppos.x + 15
	end
	
	surface.SetDrawColor( 0, 0, 0, col.a )
	surface.DrawRect( hppos.x, hppos.y, dmg, 4, col )
	
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	surface.DrawRect( hppos.x, hppos.y, nor, 4, col )
end

// Current weapon.
function Hermes.GetActiveWeapon( e ) // Removed due to shittyness, rifk.
	if ( !e:GetActiveWeapon():IsValid() ) then return "None" end
	local wep = e:GetActiveWeapon():GetPrintName()
	wep = string.Replace( wep, "#HL2_", "" )
	wep = string.Replace( wep, "#GMOD_", "" )
	wep = string.Replace( wep, "_", " " )
	wep = string.lower( wep )
	return wep
end

// Filter targets text and drawings.
function Hermes:TargetFilter( e )
	local text, box = "", false
	
	if ( ( Hermes:GetValue( Hermes.features.playeresp, 1 ) ) && e:IsPlayer() ) then
		box = true
		
		if ( e:Health() > 300 && e:Alive() ) then
			text = ( e:Nick() .. "\nHp: " .. e:Health() .. "\nW: " .. Hermes.GetActiveWeapon( e ) )
		else text = ( e:Nick() .. "\nW: " .. Hermes.GetActiveWeapon( e ) ), Hermes:HealthBar(e) end
		if ( !e:Alive() ) then text = e:Nick() .. "\n*DEAD*" end
		
		if ( table.HasValue( Hermes.traitors, e ) ) then 
			text = ( text .. "\n*TRAITOR*" )
		end
		
	elseif ( ( Hermes:GetValue( Hermes.features.npcesp, 1 ) ) && e:IsNPC() ) then
		box = true
		text = ( e:GetClass() )
		
	elseif ( ( Hermes:GetValue( Hermes.features.weaponesp, 1 ) ) && e:IsWeapon() ) then
		box = false
		text = ( e:GetClass() )
		
	elseif ( ( Hermes:GetValue( Hermes.features.ragdollesp, 1 ) ) && IsRagdoll(e) ) then
		box = false
		text = ( "Ragdoll" )
		
	elseif ( ( Hermes:GetValue( Hermes.features.vehicleesp, 1 ) ) && IsVehicle(e) ) then
		box = false
		text = ( "Vehicle" )
		
	elseif ( table.HasValue( Hermes.entities, e:GetClass() ) ) then
		box = false
		text = ( e:GetClass() )
		
	elseif ( ( Hermes:GetValue( Hermes.features.tttammo, 1 ) ) && table.HasValue( Hermes.TTTAmmo, e:GetClass() ) ) then
		local class = e:GetClass()
		class = string.Replace( class, "item_ammo_revolver_ttt", "revolver ammo" )
		class = string.Replace( class, "item_ammo_357_ttt", "357 ammo" )
		class = string.Replace( class, "item_box_buckshot_ttt", "shotgun ammo" )
		class = string.Replace( class, "item_ammo_pistol_ttt", "pistol ammo" )
		
		box = false
		text = ( class )
		
	end
	
	local maxX, minX, maxY, minY, pos = Hermes:CreatePos( e )
	local col = Hermes:TargetColors(e)
	return text, box, col, maxX, minX, maxY, minY, pos
end

// HUD such as ESP, the crosshair...
function Hermes.HUD()
	local ent, ply = ents.GetAll(), LocalPlayer()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ( ValidEntity( e ) ) && ( Hermes:FilterEntities( e, true ) && !e:IsWeapon() ) && ( Hermes:GetValue( Hermes.features.cross, 1 ) ) ) then
			local s, cpos, col = 5, Hermes:TargetLocation( e ), Hermes:VisibleColors( e ); cpos = cpos:ToScreen()
			surface.SetDrawColor( col.r, col.g, col.b, 255 )
				
			surface.DrawLine( cpos.x, cpos.y - s, cpos.x, cpos.y + s )
			surface.DrawLine( cpos.x - s, cpos.y, cpos.x + s, cpos.y )
		end
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, true ) ) then
			local text, box, col, maxX, minX, maxY, minY, pos = Hermes:TargetFilter(e)
			local color = Color( col.r, col.g, col.b, 255 )
			
			local r, l = TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
			if ( Hermes:GetValue( Hermes.features.otherpos, 0 ) ) then
				r = TEXT_ALIGN_CENTER
				l = TEXT_ALIGN_TOP
			else
				r = TEXT_ALIGN_LEFT
				l = TEXT_ALIGN_TOP
			end
			
			if ( Hermes:GetValue( Hermes.features.marker, 2 ) && box ) then
				surface.SetDrawColor( col )
				
				surface.DrawLine( maxX, maxY, maxX, minY )
				surface.DrawLine( maxX, minY, minX, minY )
					
				surface.DrawLine( minX, minY, minX, maxY )
				surface.DrawLine( minX, maxY, maxX, maxY )
				
			elseif ( Hermes:GetValue( Hermes.features.marker, 3 ) && box ) then
				local hPos, s = e:EyePos():ToScreen(), 5
				surface.SetDrawColor( col )
		
				surface.DrawLine( hPos.x, hPos.y - s, hPos.x, hPos.y + s )
				surface.DrawLine( hPos.x - s, hPos.y, hPos.x + s, hPos.y )
			end
				
			Hermes:DrawText(
				text,
				"Default",
				pos.x,
				pos.y,
				col,
				r,
				l
			)
		end
	end
	
	if ( Hermes:GetValue( Hermes.features.crosshair, 2 ) ) then
		local g = 5; local s, x, y, l = 5, ( ScrW() / 2 ), ( ScrH() / 2 ), g + 15
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		surface.DrawLine( x - l, y, x - g, y )
		surface.DrawLine( x + l, y, x + g, y )
		
		surface.DrawLine( x, y - l, x, y - g )
		surface.DrawLine( x, y + l, x, y + g )
		
		surface.SetDrawColor( 255, 0, 0, 255 )
		
		surface.DrawLine( x, y - s, x, y + s )
		surface.DrawLine( x - s, y, x + s, y )
	
	elseif ( Hermes:GetValue( Hermes.features.crosshair, 3 ) ) then
		local g = 5; local s, x, y, l = 5, ( ScrW() / 2 ), ( ScrH() / 2 ), g + 15
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		surface.DrawLine( x - l, y, x - g, y )
		surface.DrawLine( x + l, y, x + g, y )
		
		surface.DrawLine( x, y - l, x, y - g )
		surface.DrawLine( x, y + l, x, y + g )
		
	elseif ( Hermes:GetValue( Hermes.features.crosshair, 4 ) ) then
		local s, x, y = 10, ( ScrW() / 2 ), ( ScrH() / 2 )
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		surface.DrawLine( x, y - s, x, y + s )
		surface.DrawLine( x - s, y, x + s, y )
		
	elseif ( Hermes:GetValue( Hermes.features.crosshair, 5 ) ) then
		local s, x, y = 10, ScrW() / 2, ScrH() / 2
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		surface.DrawLine( x - 20, y - 20, x + 20, y + 20 )
		surface.DrawLine( x - 20, y + 20, x + 20, y - 20)
	end
	
	Hermes.AimHUD()
end
Hermes:AddHook( "HUDPaint", Hermes.HUD )

//******************************
// Visuals
//******************************
// Create a custom material internally.
function Hermes:CreateMaterial()
	
	local BaseInfo = {
		["$basetexture"] = "models/debug/debugwhite",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1,
		["$ignorez"]	 = 1
	}
	
	local mat
	if ( Hermes:GetValue( Hermes.features.chams, 2 ) ) then
		mat = CreateMaterial( "hermes_mat", "VertexLitGeneric", BaseInfo )
	elseif ( Hermes:GetValue( Hermes.features.chams, 3 ) ) then
		mat = CreateMaterial( "hermes_matw", "Wireframe", BaseInfo )
	end
	
	return mat
	
end

// Make sure the convars are enabled.
function Hermes.ChamConVars( e )
	if ( e:IsPlayer() && Hermes:GetValue( Hermes.features.playeresp, 0 ) ) then return false end
	if ( e:IsNPC() && Hermes:GetValue( Hermes.features.npcesp, 0 ) ) then return false end
	if ( e:IsWeapon() && Hermes:GetValue( Hermes.features.weaponesp, 0 ) ) then return false end
	if ( IsRagdoll(e) && Hermes:GetValue( Hermes.features.ragdollesp, 0 ) ) then return false end
	return true
end

// Basic XQZ wallhack.
function Hermes.XQZ()
	local ent, ply = ents.GetAll(), LocalPlayer()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, false ) && Hermes.ChamConVars( e ) && Hermes:GetValue( Hermes.features.chams, 4 ) ) then
			cam.Start3D( EyePos(), EyeAngles() )
				cam.IgnoreZ( true )
				e:DrawModel()
				cam.IgnoreZ( false )
			cam.End3D()
		end
	end
end

// Normal chams.
function Hermes.OverrideMaterial()
	if ( Hermes:GetValue( Hermes.features.chams, 1 ) ) then return end
	local ent, ply, c = ents.GetAll(), LocalPlayer(), ( 1 / 255 )
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, false ) && Hermes.ChamConVars( e ) ) then
			cam.Start3D( EyePos(), EyeAngles() )
				local mat = Hermes:CreateMaterial()
				local col = Hermes:TargetColors(e)
				render.SuppressEngineLighting( true )
				render.SetColorModulation( ( col.r * c ), ( col.g * c ), ( col.b * c ) )
				SetMaterialOverride( mat )
				e:SetModelScale( Vector( 1.1, 1.1, 1 ) )
				e:DrawModel()
				render.SuppressEngineLighting( false )
				render.SetColorModulation( 1, 1, 1 )
				SetMaterialOverride()
				e:SetModelScale( Vector( 1, 1, 1 ) )
				e:DrawModel()
			cam.End3D()
		end
	end
end

// Model transparency.
function Hermes.XRay()
	local ent, ply, c = ents.GetAll(), LocalPlayer(), ( 1 / 255 )
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ValidEntity( e ) && ( string.sub( ( e:GetModel() || "" ), -3 ) == "mdl" ) ) then
			if ( Hermes:GetValue( Hermes.features.xray, 1 ) ) then
				e:SetColor( 255, 255, 255, tonumber( Hermes.features.viewtrans ) )
			else
				e:SetColor( 255, 255, 255, 255 )
			end
		end
		
		if ( ValidEntity( e ) && ( e:GetClass() == "prop_physics" ) ) then
			if ( Hermes:GetValue( Hermes.features.xrayxqz, 1 ) ) then
				cam.Start3D( EyePos(), EyeAngles() )
					cam.IgnoreZ( true )
					e:DrawModel()
					cam.IgnoreZ( false )
				cam.End3D()
			end
		end
	end
end

// Fullbright
function Hermes.Fullbright()
	DrawBloom( 
		0,		-- Darken
		0.75,	-- Multiply
		3,		-- sizeX
		3,		-- sizeY
		2,		-- Passes
		3,		-- Color
		255,	-- Red
		255,	-- Green
		255 	-- Blue
	)
end

// Apply the hooks.
function Hermes.Effects()
	Hermes.XQZ()
	Hermes.OverrideMaterial()
	Hermes.XRay()
	//Hermes.Fullbright()
end
Hermes:AddHook( "RenderScreenspaceEffects", Hermes.Effects )

//******************************
// Miscellaneous
//******************************

// Apply think hooks.
function Hermes.Think()
	Hermes.GetTraitor()
	Hermes.ConeThink()
end

Hermes:AddHook( "Think", Hermes.Think )

// Simple background.
function Hermes.Background( parent )
	local image = vgui.Create( "DImage", parent )
	image:SetMaterial( Material( "hermes/background.vtf" ) )
	image:SetPos( 0, 0 )
	image:SetSize( 440, 320 )
end

// Change a cvar value to zero.
function Hermes.Change( cvar )
	if ( ConVarExists( cvar ) && GetConVarNumber( cvar ) < 0 ) then
		RunConsoleCommand( cvar, 1 )
	end
end

// Speedhack amount.
function Hermes.EnabledSpeed()
	if ( Hermes:GetValue( Hermes.features.speedhack, 1 ) ) then
		hack.SetPlayerSpeed( tonumber( Hermes.features.speedhackspeed ) )
	end
end

// Disable speedhack.
function Hermes.DisableSpeed()
	hack.SetPlayerSpeed( 1 )
end

// Create concommands.
Hermes:AddCommand( "+hermes_speed", function() Hermes.EnabledSpeed() end )
Hermes:AddCommand( "-hermes_speed", function() Hermes.DisableSpeed() end )

//******************************
// Menu VGUI
//******************************
// VGUI such as radars.
local menu_radar = nil
local menu_admin = nil

function Hermes.ExtraVGUI()
	local xn, yn, x, y = ScrW(), ScrH(), ScrW() / 2, ScrH() / 2
	
	local radar = vgui.Create( "DFrame" )
	radar:SetSize( 250, 250 )
	
	local radarW, radarH = radar:GetWide(), radar:GetTall()
	radar:SetPos( xn - radarW - 10, yn - radarH - ( yn - radarH ) + 10 )
	radar:SetTitle( "Hermes :: Radar" )
	radar:SetVisible( true )
	radar:SetDraggable( true )
	radar:ShowCloseButton( false )
	radar:MakePopup()
	
	radar.Paint = function()
		// Main
		draw.RoundedBox( 0, 0, 0, radarW, radarH, Color( 255, 0, 0, 100 ) )
		
		// Outline
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawOutlinedRect( 0, 0, radarW, radarH )
		
		// Radar Function
		local ply = LocalPlayer()
		
		local radar = {}
		radar.h		= 300
		radar.w		= 300
		radar.org	= tonumber( Hermes.features.radarradius )
		
		local x, y = ScrW() / 2, ScrH() / 2
		
		local half = radarH / 2
		local xm = half
		local ym = half
		
		surface.DrawLine( xm, ym - 100, xm, ym + 100 )
		surface.DrawLine( xm - 100, ym, xm + 100, ym )
		
		local players = ents.GetAll()
			for i = 1, table.Count( players ) do
			local e = players[i]
			
			if ( ( ValidEntity( e ) ) && ( Hermes:FilterRadarEntities( e ) ) ) then
				
				local s = 6
				local col = Hermes:TargetColors(e)
				local color = Color( col.r, col.g, col.b, col.a )
				local plyfov = ply:GetFOV() / ( 70 / 1.13 )
				local zpos, npos = ply:GetPos().z - ( e:GetPos().z ), ( ply:GetPos() - e:GetPos() )
				
				npos:Rotate( Angle( 180, ( ply:EyeAngles().y ) * -1, -180 ) )
				local iY = npos.y * ( radar.h / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
				local iX = npos.x * ( radar.w / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
				
				
				local pX = ( radar.w / 2 )
				local pY = ( radar.h / 2 )
				
				local posX = pX - iY - ( s / 2 )
				local posY = pY - iX - ( s / 2 )
				
				local text = e:GetClass()
				
				if ( e:IsPlayer() ) then 
					text = e:Nick() .. " ["..e:Health().."]"
				end
				
				if iX < ( radar.h / 2 ) && iY < ( radar.w / 2 ) && iX > ( -radar.h / 2 ) && iY > ( -radar.w / 2 ) then
				
					draw.RoundedBox( s, posX, posY, s, s, color )
					Hermes:DrawText(
						text,
						"DefaultSmall",
						pX - iY - 4,
						pY - iX - 15 - ( s / 2 ),
						color,
						1,
						TEXT_ALIGN_TOP
					)
				end
			end
		end
	end
	
	radar:SetMouseInputEnabled( false )
	radar:SetKeyboardInputEnabled( false )
	
	menu_radar = radar
	
	----------| Admin List |-----------------------------------------------------------------------------------------------
	local admins, adminnum = "", 0
	
	for k, e in pairs( player.GetAll() ) do
		if ( Hermes:IsAdmin(e) ) then
			admins = ( admins .. "\n" .. e:Nick() .. " [" .. Hermes:GetAdminType(e) .. "]" )
			adminnum = adminnum + 1
		end
	end
	
	local wide, tall = 250, ( adminnum * 20 ) + 20
	local posX, posY = ( wide - 75 ), tall + 250
		
	if ( adminnum == 0 ) then
		admins = ( "\nThere are no admins on right now" )
		wide, tall = 250, 40
	end
	
	timer.Create( "FindAdmins", 0.1, 0, function()
		admins = ""
		adminnum = 0
		for k, e in pairs( player.GetAll() ) do
			if ( Hermes:IsAdmin(e) ) then
				admins = ( admins .. "\n" .. e:Nick() .. " [" .. Hermes:GetAdminType(e) .. "]" )
				adminnum = adminnum + 1
			end
		end
		
		wide, tall = 250, ( adminnum * 20 ) + 20
		posX, posY = ( wide - 75 ), tall + 250
		
		if ( adminnum == 0 ) then
			admins = ( "\nThere are no admins on right now" )
			wide, tall = 250, 40
		end
	end )
	
	local adminlist = vgui.Create( "DFrame" )
	adminlist:SetSize( 250, 1000 )
	
	local aW, aH, x, y = adminlist:GetWide(), tall, ScrW() / 2, ScrH() / 2
	
	adminlist:SetPos( 10, 90 )
	adminlist:SetTitle( "Hermes :: Admins" )
	adminlist:SetVisible( true )
	adminlist:SetDraggable( true )
	adminlist:ShowCloseButton( false )
	adminlist:MakePopup()
	adminlist.Paint = function()
		draw.RoundedBox( 0, 0, 0, 250, tall, Color( 255, 0, 0, 100 ) )
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawOutlinedRect( 0, 0, 250, tall )
		
			Hermes:DrawText(
				admins,
				"Default",
				20,
				8,
				Color( 255, 255, 255, 255 ),
				0,
				0 
			)
	end
	
	adminlist:SetMouseInputEnabled( false )
	adminlist:SetKeyboardInputEnabled( false )
	
	menu_admin = adminlist
end

// Make sure this only runs once.
local n = 0
function Hermes.AllowVGUI()
	n = n + 1
	if ( n == 1 ) then
		Hermes.ExtraVGUI()
		n = n - 9999999999999999999 // I hope I don't open the menu 9999999999999999999 times!
	end
end

// Pretty much the menu.
function Hermes.Menu()
	Hermes.AllowVGUI()
	
	Hermes.set.panel = vgui.Create( "DFrame" )
	Hermes.set.panel:SetPos( ScrW() / 2 - 450 / 2, ScrH() / 2 - 350 / 2 )
	Hermes.set.panel:SetSize( 450, 350 )
	Hermes.set.panel:SetTitle( "Hermes :: Settings" )
	Hermes.set.panel:SetVisible( true )
	Hermes.set.panel:SetDraggable( true )
	Hermes.set.panel:ShowCloseButton( true )
	Hermes.set.panel:MakePopup()
	
	Hermes.set.panel.Paint = function()
		// Main
		draw.RoundedBox( 0, 0, 0, 450, 350, Color( 255, 0, 0, 100 ) )
		
		// Outline
		surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
		surface.DrawOutlinedRect( 0, 0, 450, 350 )
		
		// Top
		draw.RoundedBox( 4, 2, 2, 450 - 4, 21, Color( 0, 0, 0, 230 ) )
	end
	
	if ( !IsValid( Hermes.set.panel ) || Hermes.set.panel == nil ) then return end
	
	local propertypage = vgui.Create( "DPropertySheet" )
	propertypage:SetParent( Hermes.set.panel )
	propertypage:SetPos( 5, 25 )
	propertypage:SetSize( 440, 320 )
	
	local aim = vgui.Create( "DPanel", propertypage )
	local esp = vgui.Create( "DPanel", propertypage )
	local mis = vgui.Create( "DPanel", propertypage )
	local fri = vgui.Create( "DPanel", propertypage )
	local ety = vgui.Create( "DPanel", propertypage )
	
	Hermes.Background( aim )
	Hermes.Background( esp )
	Hermes.Background( mis )
	Hermes.Background( fri )
	Hermes.Background( ety )
	
	local aimlist = vgui.Create( "DPanelList" )
	aimlist:SetPos( 10, 10 )
	aimlist:SetParent( aim )
	aimlist:SetSize( 440 - 15, 320 - 10 )
	aimlist:EnableVerticalScrollbar( true )
	aimlist:SetSpacing( 5 )
	aimlist.Paint = function() end
	
	local aimlistS = vgui.Create( "DPanelList" )
	aimlistS:SetPos( 150, 80 )
	aimlistS:SetParent( aim )
	aimlistS:SetSize( 440 - 170, 320 - 50 )
	aimlistS:EnableVerticalScrollbar( true )
	aimlistS:SetSpacing( 5 )
	aimlistS.Paint = function() end
	
	local esplist = vgui.Create( "DPanelList" )
	esplist:SetPos( 10, 10 )
	esplist:SetParent( esp )
	esplist:SetSize( 440 - 15, 320 - 10 )
	esplist:EnableVerticalScrollbar( true )
	esplist:SetSpacing( 5 )
	esplist.Paint = function() end
	
	local esplistS = vgui.Create( "DPanelList" )
	esplistS:SetPos( 150, 80 )
	esplistS:SetParent( esp )
	esplistS:SetSize( 440 - 170, 320 - 10 )
	esplistS:EnableVerticalScrollbar( true )
	esplistS:SetSpacing( 5 )
	esplistS.Paint = function() end
	
	local misclist = vgui.Create( "DPanelList" )
	misclist:SetPos( 10, 10 )
	misclist:SetParent( mis )
	misclist:SetSize( 440 - 15, 320 - 10 )
	misclist:EnableVerticalScrollbar( true )
	misclist:SetSpacing( 5 )
	misclist.Paint = function() end
	
	local misclistS = vgui.Create( "DPanelList" )
	misclistS:SetPos( 150, 80 )
	misclistS:SetParent( mis )
	misclistS:SetSize( 440 - 170, 320 - 10 )
	misclistS:EnableVerticalScrollbar( true )
	misclistS:SetSpacing( 5 )
	misclistS.Paint = function() end
	
	// Nospread type
	local label = vgui.Create( "DLabel" )
	label:SetParent( aim )
	label:SetPos( 150, 15 )
	label:SetWide( 100 )
	label:SetText( "Nospread:" )
	label:SetTextColor( Color( 255, 255, 255, 255 ) )
	
	Hermes.Change( "hermes_aim_nospread" )
	
	local multichoice = vgui.Create( "DMultiChoice" )
	multichoice:SetParent( aim )
	multichoice:SetPos( 210, 15 )
	multichoice:SetSize( 210, 20 )
	multichoice:SetEditable( false )
	multichoice:AddChoice( "OFF" )
	multichoice:AddChoice( "When Aiming" )
	multichoice:AddChoice( "On Target Lock" )
	multichoice:AddChoice( "In Attack" )
	multichoice:AddChoice( "Allways" )
	multichoice:ChooseOptionID( tonumber( Hermes.features.nospread ) )
	multichoice.OnSelect = function( index, value, data )
		RunConsoleCommand( "hermes_aim_nospread", value )
	end
	
	// Aim mode
	local label = vgui.Create( "DLabel" )
	label:SetParent( aim )
	label:SetPos( 150, 50 )
	label:SetWide( 100 )
	label:SetText( "Aimmode:" )
	label:SetTextColor( Color( 255, 255, 255, 255 ) )
	
	Hermes.Change( "hermes_aim_mode" )
	
	local multichoice = vgui.Create( "DMultiChoice" )
	multichoice:SetParent( aim )
	multichoice:SetPos( 210, 50 )
	multichoice:SetSize( 210, 20 )
	multichoice:SetEditable( false )
	multichoice:AddChoice( "Crosshair" )
	multichoice:AddChoice( "Distance" )
	multichoice:AddChoice( "Health" )
	multichoice:AddChoice( "Deadliest" )
	multichoice:ChooseOptionID( tonumber( Hermes.features.mode ) )
	multichoice.OnSelect = function( index, value, data )
		RunConsoleCommand( "hermes_aim_mode", value )
	end
	
	// Chams
	local label = vgui.Create( "DLabel" )
	label:SetParent( esp )
	label:SetPos( 150, 15 )
	label:SetWide( 100 )
	label:SetText( "Material:" )
	label:SetTextColor( Color( 255, 255, 255, 255 ) )
	
	Hermes.Change( "hermes_vis_cham" )
	
	local multichoice1 = vgui.Create( "DMultiChoice" )
	multichoice1:SetParent( esp )
	multichoice1:SetPos( 210, 15 )
	multichoice1:SetSize( 210, 20 )
	multichoice1:SetEditable( false )
	multichoice1:AddChoice( "None" )
	multichoice1:AddChoice( "Solid" )
	multichoice1:AddChoice( "Wireframe" )
	multichoice1:AddChoice( "XQZ" )
	multichoice1:ChooseOptionID( tonumber( Hermes.features.chams ) )
	multichoice1.OnSelect = function( index, value, data )
		RunConsoleCommand( "hermes_vis_cham", value )
	end
	
	// ESP Marker
	local label = vgui.Create( "DLabel" )
	label:SetParent( esp )
	label:SetPos( 150, 50 )
	label:SetWide( 100 )
	label:SetText( "Optical:" )
	label:SetTextColor( Color( 255, 255, 255, 255 ) )
	
	Hermes.Change( "hermes_esp_marker" )
	
	local multichoice1 = vgui.Create( "DMultiChoice" )
	multichoice1:SetParent( esp )
	multichoice1:SetPos( 210, 50 )
	multichoice1:SetSize( 210, 20 )
	multichoice1:SetEditable( false )
	multichoice1:AddChoice( "None" )
	multichoice1:AddChoice( "Box" )
	multichoice1:AddChoice( "Cross" )
	multichoice1:ChooseOptionID( tonumber( Hermes.features.marker ) )
	multichoice1.OnSelect = function( index, value, data )
		RunConsoleCommand( "hermes_esp_marker", value )
	end
	
	// Crosshair
	local label = vgui.Create( "DLabel" )
	label:SetParent( mis )
	label:SetPos( 150, 15 )
	label:SetWide( 100 )
	label:SetText( "Crosshair:" )
	label:SetTextColor( Color( 255, 255, 255, 255 ) )
	
	Hermes.Change( "hermes_vis_cross" )
	
	local multichoice1 = vgui.Create( "DMultiChoice" )
	multichoice1:SetParent( mis )
	multichoice1:SetPos( 210, 15 )
	multichoice1:SetSize( 210, 20 )
	multichoice1:SetEditable( false )
	multichoice1:AddChoice( "None" )
	multichoice1:AddChoice( "Default" )
	multichoice1:AddChoice( "Counter-Strike" )
	multichoice1:AddChoice( "Normal Cross" )
	multichoice1:AddChoice( "Advanced Cross" )
	multichoice1:ChooseOptionID( tonumber( Hermes.features.crosshair ) )
	multichoice1.OnSelect = function( index, value, data )
		RunConsoleCommand( "hermes_vis_cross", value )
	end
	
	// Friends list
	local combobox1
	function Hermes.AllPlayers()
		combobox1 = vgui.Create( "DComboBox" )
		combobox1:SetParent( fri )
		combobox1:SetPos( 10 + 10, 15 + 10 )
		combobox1:SetSize( 200 - 20, 230 - 20 )
		combobox1:SetMultiple( false )
	end
	Hermes.AllPlayers()
	
	local combobox2
	function Hermes.OnlyFriends()
		combobox2 = vgui.Create( "DComboBox" )
		combobox2:SetParent( fri )
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
	button1:SetParent( fri )
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
	button2:SetParent( fri )
	button2:SetSize( 160, 20 )
	button2:SetPos( 240, 240 )
	button2:SetText( "Remove" )
	button2.DoClick = function()
		if ( combobox2:GetSelectedItems() && combobox2:GetSelectedItems()[1] ) then
			for k, e in pairs( Hermes.friends ) do
				if ( e == combobox2:GetSelectedItems()[1]:GetValue() ) then
					Hermes.friends[k] = nil
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
		combobox3:SetParent( ety )
		combobox3:SetPos( 10 + 10, 15 + 10 )
		combobox3:SetSize( 200 - 20, 230 - 20 )
		combobox3:SetMultiple( false )
	end
	Hermes.AllEntities()
	
	local combobox4
	function Hermes.OnlyListed()
		combobox4 = vgui.Create( "DComboBox" )
		combobox4:SetParent( ety )
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
	button3:SetParent( ety )
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
	button4:SetParent( ety )
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
	
	for k, info in ipairs( Hermes.menuinfo ) do
		if ( info.CVar == "hermes_aim_nospread" || info.CVar == "hermes_vis_cham" || info.CVar == "hermes_aim_mode" || info.CVar == "hermes_vis_cross" || info.CVar == "hermes_esp_marker" ) then
		
		elseif ( info.Type == "boolean" ) then
			local checkbox = vgui.Create( "DCheckBoxLabel" )
			checkbox:SetText( info.Desc )
			checkbox:SetValue( GetConVarNumber( info.CVar ) )
			checkbox:SetTextColor( Color( 255, 255, 255, 255 ) )
			
			checkbox.change = 0
			checkbox.OnChange = function()
				if ( checkbox.change < CurTime() ) then
					checkbox.change = CurTime() + 0.1
					checkbox:SetValue( Hermes:ToBool( checkbox:GetChecked() && 1 || 0 ) )
					Hermes.old.rcc( info.CVar, checkbox:GetChecked() && 1 || 0 )
				end
			end
			
			cvars.AddChangeCallback( info.CVar, function( cvar, old, new ) 
				if ( checkbox.change < CurTime() ) then
					checkbox.change = CurTime() + 0.1
					checkbox:SetValue( Hermes:ToBool( new ) )
				end
			end )
			
			if ( info.Menu == "aim" ) then
				aimlist:AddItem( checkbox )
			elseif ( info.Menu == "esp" ) then
				esplist:AddItem( checkbox )
			elseif ( info.Menu == "misc" ) then
				misclist:AddItem( checkbox )
			end
			
		elseif ( info.Type == "number" ) then
			local slider = vgui.Create( "DNumSlider" )
			
			if ( info.Decimal ) then
				slider:SetDecimals( 1 )
			else slider:SetDecimals( 0 ) end
			
			slider:SetText( "" )
			slider:SetMax( info.Max || 1 )
			slider:SetMin( info.Min || 0 )
			slider:SetDecimals( 0 )
			slider:SetValue( GetConVarNumber( info.CVar ) )
			
			local label = vgui.Create( "DLabel" )
			label:SetParent( slider )
			label:SetWide( 200 )
			label:SetText( info.Desc )
			label:SetTextColor( Color( 255, 255, 255, 255 ) )
			
			slider.change = 0
			slider.ValueChanged = function( self, new )
				if ( slider.change < CurTime() ) then
					slider.change = CurTime() + 0.1
					slider:SetValue( new )
					Hermes.old.rcc( info.CVar, new )
				end
			end
			
			cvars.AddChangeCallback( info.CVar, function( cvar, old, new ) 
				if ( slider.change < CurTime() ) then
					slider.change = CurTime() + 0.1
					slider:SetValue( new )
				end
			end )
			
			if ( info.Menu == "aim" ) then
				aimlistS:AddItem( slider )
			elseif ( info.Menu == "esp" ) then
				esplistS:AddItem( slider )
			elseif ( info.Menu == "misc" ) then
				misclistS:AddItem( slider )
			end
		end
	end
	propertypage:AddSheet( "Aimbot", aim, "gui/silkicons/wrench", false, false, nil )
	propertypage:AddSheet( "ESP", esp, "gui/silkicons/world", false, false, nil )
	propertypage:AddSheet( "Miscellaneous", mis, "gui/silkicons/plugin", false, false, nil )
	propertypage:AddSheet( "Friends List", fri, "gui/silkicons/group", false, false, nil )
	propertypage:AddSheet( "Entities List", ety, "gui/silkicons/star", false, false, nil )
end

// Add extra VGUI
 function Hermes.LastFunction()
	if ( n == 0 ) then return end
	if ( Hermes.set.panel && Hermes.set.panel:IsVisible() ) then
		menu_radar:SetMouseInputEnabled( true )
		menu_radar:SetKeyboardInputEnabled( true )
		menu_admin:SetMouseInputEnabled( true )
		menu_admin:SetKeyboardInputEnabled( true )
	else
		menu_radar:SetMouseInputEnabled( false )
		menu_radar:SetKeyboardInputEnabled( false )
		menu_admin:SetMouseInputEnabled( false )
		menu_admin:SetKeyboardInputEnabled( false )
	end
	if ( Hermes:GetValue( Hermes.features.radar, 1 ) ) then
		menu_radar:SetVisible( true )
	else
		menu_radar:SetVisible( false )
	end
	if ( Hermes:GetValue( Hermes.features.adminlist, 1 ) ) then
		menu_admin:SetVisible( true )
	else
		menu_admin:SetVisible( false )
	end
end

timer.Create( "~~~~~simple", 0.01, 0, function() Hermes.LastFunction() end )
Hermes:AddCommand( "hermes_menu", function() Hermes.Menu() end )