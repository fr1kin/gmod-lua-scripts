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

local Hermes			= {}
Hermes.features			= {}
Hermes.commands			= {}
Hermes.convars			= {}
Hermes.hooks			= {}
Hermes.old				= {}
Hermes.create			= {}
Hermes.menuinfo			= {}
Hermes.friends			= {}
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

function Hermes:CreateClientConVar( cvar, val, tblname, desc, menutyp, min, max )
	local oldValue = val
	if ( type( val ) == "boolean" ) then
		val = val && 1 || 0
	end
	
	local fVar = "hermes_" .. cvar
	local info = { Name = tblname, CVar = fVar, Value = val, Min = min, Max = max, Type = type( oldValue ), Desc = desc, Menu = menutyp }

	local gVar = Hermes.old.cccv( "hermes_" .. cvar, val, true, false )
	if ( type( val ) == "number" || type( val ) == "boolean" ) then
		Hermes.features[ tblname ] = gVar:GetInt()
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

// Add convars
Hermes:CreateClientConVar( "aim_shoot", false, "autoshoot", "Autoshoot", "aim" )
Hermes:CreateClientConVar( "aim_trigger", false, "triggerbot", "Triggerbot", "aim" )
Hermes:CreateClientConVar( "aim_triggerkey", false, "triggerkey", "Triggerkey", "aim" )
Hermes:CreateClientConVar( "aim_nospread", false, "nospread", "Nospread", "aim" )
Hermes:CreateClientConVar( "aim_friendlyfire", false, "friendlyfire", "Friendly Fire", "aim" )
Hermes:CreateClientConVar( "aim_steam", false, "steam", "Target Steam  Friends", "aim" )
Hermes:CreateClientConVar( "aim_admin", false, "admins", "Target Admins", "aim" )
Hermes:CreateClientConVar( "aim_player", false, "players", "Target Players", "aim" )
Hermes:CreateClientConVar( "aim_npc", false, "npcs", "Target NPCs", "aim" )
Hermes:CreateClientConVar( "esp_player", true, "playeresp", "Players", "esp" )
Hermes:CreateClientConVar( "esp_npc", true, "npcesp", "NPCs", "esp" )
Hermes:CreateClientConVar( "esp_weapon", false, "weaponesp", "Weapons", "esp" )
Hermes:CreateClientConVar( "esp_showdead", false, "showdead", "Show Dead", "esp" )
Hermes:CreateClientConVar( "esp_box", true, "box", "2D Bounding Box", "esp" )
Hermes:CreateClientConVar( "esp_cross", true, "cross", "Visible Cross", "esp" )
Hermes:CreateClientConVar( "vis_xqz", true, "xqzwall", "XQZ Wallhack", "esp" )
Hermes:CreateClientConVar( "vis_cham", true, "chams", "Normal Chams", "esp" )
Hermes:CreateClientConVar( "vis_cross", true, "crosshair", "Crosshair", "esp" )
Hermes:CreateClientConVar( "misc_bhop", true, "bunnyhop", "Bunnyhop", "esp" )

Hermes:CreateClientConVar( "aim_triggerdistance", 0, "triggerdistance", "Triggerbot Distance", "aim", 0, 16384 )
Hermes:CreateClientConVar( "aim_fov", 180, "fov", "Field-of-view", "aim", 0, 180 )

//------------------------------
// Hooks:
//------------------------------
local oldCallHook = Hermes.old.hook.Call

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

function GetConVarNumber( cvar )
	Hermes.callpath = Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && ( Hermes.callpath == Hermes.set.path ) ) then return Hermes.old.cve( cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
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
// Max screen, so useless shit that you don't see is drawn.
function Hermes:OnScreen( e )
	local x, y, pos = ScrW(), ScrH(), e:LocalToWorld( e:OBBCenter() ):ToScreen()
	if ( pos.x > 0 && pos.y > 0 && pos.x < x && pos.y < y ) then
		return true
	end
	return false
end

// TTT traitor detector
Hermes.traitors = {}
Hermes.traitorsweps = { "weapon_ttt_c4", "weapon_ttt_knife", "weapon_ttt_phammer", "weapon_ttt_sipistol", "weapon_ttt_flaregun", "weapon_ttt_push", "weapon_ttt_radio", "weapon_ttt_teleport" }

function Hermes.GetTraitor()
	if ( !string.find( string.lower( GAMEMODE.Name ), "trouble in terror" ) ) then return end
	local ent, ply = player.GetAll(), LocalPlayer()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		if ( ValidEntity( e ) && e != ply ) then
			local weps = e:GetWeapons()
			for i = 1, table.Count( weps ) do
				local w = weps[i]
				if ( ValidEntity( w ) ) then
					if ( table.HasValue( Hermes.traitorsweps, w:GetClass() ) && !table.HasValue( Hermes.traitors, e:Nick() ) && !e:IsDetective() ) then
						table.insert( Hermes.traitors, e:Nick() )
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

// If an entity is a dead body we can detect it.
local function IsRagdoll( e )
	if ( ( e:GetClass() == "prop_ragdoll" ) || ( e:GetClass() == "class C_ClientRagdoll" ) ) then
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
		if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !IsRagdoll(e) || e == ply ) then return false end
		if ( e:IsPlayer() && Hermes:GetValue( Hermes.features.showdead, 0 ) && !e:Alive() || e:IsPlayer() && Hermes:GetValue( Hermes.features.showdead, 0 ) && e:Health() <= 0 ) then return false end
		if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		if ( e:IsWeapon() && e:GetMoveType() == MOVETYPE_NONE ) then return false end
		return true
	elseif ( use == false ) then
		if ( !ValidEntity( e ) ) then return false end
		if ( !Hermes:OnScreen(e) ) then return false end
		if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !IsRagdoll(e) || e == ply ) then return false end
		if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
		if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		if ( e:IsWeapon() && e:GetMoveType() != MOVETYPE_NONE ) then return false end
		return true
	end
	return true
end

// Target colors.
function Hermes:TargetColors( e )
	local col
	if ( e:IsPlayer() ) then
		if ( !table.HasValue( Hermes.traitors, e:Nick() ) ) then
			col = team.GetColor( e:Team() )
		elseif ( table.HasValue( Hermes.traitors, e:Nick() ) ) then
			col = Color( 255, 0, 0, 255 )
		end
	elseif ( e:IsNPC() ) then
		if ( !IsEnemyEntityName( e:GetClass() ) && !( e:GetClass() == "npc_metropolice" ) ) then
			col = Color( 0, 100, 0, 255 )
		elseif ( IsEnemyEntityName( e:GetClass() ) || ( e:GetClass() == "npc_metropolice" ) ) then
			col = Color( 230, 0, 0, 255 )
		end
	elseif ( e:IsWeapon() ) then
		col = Color( 215, 100, 0, 255 )
	elseif( IsRagdoll(e) ) then
		col = Color( 255, 255, 255, 255 )
	end
	return col
end

// Position of Players and NPCs.
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
	
	local d, v	= math.Round( e:GetPos():Distance( ply:GetShootPos() ) )
	v = d / 30
	pos = e:LocalToWorld( top + top ) + Vector( 0, 0, v + 10 )
	
	if ( e:IsWeapon() || IsRagdoll(e) ) then pos = e:LocalToWorld( e:OBBCenter() ) end
	
	local FRT 	= center + frt + rgt + top; FRT = FRT:ToScreen()
	local BLB 	= center + bak + lft + btm; BLB = BLB:ToScreen()
	local FLT	= center + frt + lft + top; FLT = FLT:ToScreen()
	local BRT 	= center + bak + rgt + top; BRT = BRT:ToScreen()
	local BLT 	= center + bak + lft + top; BLT = BLT:ToScreen()
	local FRB 	= center + frt + rgt + btm; FRB = FRB:ToScreen()
	local FLB 	= center + frt + lft + btm; FLB = FLB:ToScreen()
	local BRB 	= center + bak + rgt + btm; BRB = BRB:ToScreen()
	
	pos = pos:ToScreen()
	
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
	local pos = e:LocalToWorld( e:OBBCenter() )
	pos = Hermes:GetPos( e, "ValveBiped.Bip01_Head1" )
	
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
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	if ( !ValidEntity( e ) ) then return false end
	if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() ) || e == ply ) then return false end
	if ( e:IsPlayer() && Hermes:GetValue( Hermes.features.players, 0 ) ) then return false end
	if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
	if ( e:IsPlayer() && e:Team() == ply:Team() && Hermes:GetValue( Hermes.features.friendlyfire, 0 ) ) then return false end
	if ( e:IsPlayer() && ( e:GetFriendStatus() == "friend" ) && Hermes:GetValue( Hermes.features.steam, 0 ) ) then return false end
	if ( e:IsPlayer() && e:IsAdmin() && Hermes:GetValue( Hermes.features.admins, 0 ) ) then return false end
	if ( e:IsPlayer() && table.HasValue( Hermes.friends, e:Nick() ) ) then return false end
	if ( e:IsNPC() && Hermes:GetValue( Hermes.features.npcs, 0 ) ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
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

// Get the target
function Hermes:GetTarget()
	if ( !Hermes.set.aiming ) then return end
	local ent, ply, trace = ents.GetAll(), LocalPlayer(), Hermes:AimTrace()
	local tar = { 0, 0 }
	
	local myPos, myAng, myAngV = ply:EyePos(), ply:GetAimVector(), ply:GetAngles()
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
			if ( ValidEntity( e ) && Hermes:ValidTargets( e ) && Hermes:VisibleTarget( e ) ) then
				local ang = ( e:GetPos() - ply:GetShootPos() ):Angle()
				local angY = math.abs( math.NormalizeAngle( myAngV.y - ang.y ) )
				local angP = math.abs( math.NormalizeAngle( myAngV.p - ang.p ) )
				
				if ( angY < tonumber( Hermes.features.fov ) && angP < tonumber( Hermes.features.fov ) ) then
				local tarPos = e:EyePos()
			
				local info = ( tarPos-myPos ):Normalize()
				info = info - myAng
				info = info:Length()
				info = math.abs( info )
		
				if ( info < tar[2] || tar[1] == 0 ) then
					tar = { e, info }
				end
			end
		end
	end
	return tar[1]
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

// Build no-recoil fix
function Hermes.GetAngles( angle, ucmd )
	local ply, correct = LocalPlayer(), 1
	if ( zoom != 0 ) then correct = ( 1 - ( zoom / 100 ) ) end
	if !( IsValid( ply:GetActiveWeapon() ) && ( ply:GetActiveWeapon():GetClass() == "weapon_physgun" ) && ( ucmd:GetButtons() & IN_USE ) > 0 ) then
		angle.y = math.NormalizeAngle( angle.y + ( ucmd:GetMouseX() * -0.022 * correct ) )
		angle.p = math.Clamp( angle.p + ( ucmd:GetMouseY() * 0.022 * correct ), -89, 90 )
	end
end

// Aim at the target
function Hermes.Aim( ucmd )
	local ply = LocalPlayer()
	local tar = Hermes:GetTarget()
	
	Hermes.set.target = false
	cone = cone || 0
	
	local mouse = Angle( ucmd:GetMouseY() * Hermes.old.gcvn( "m_pitch" ), ucmd:GetMouseX() * -Hermes.old.gcvn("m_yaw") ) || Angle( 0, 0, 0 )
	//local mouse = strange_weapon && ucmd:GetViewAngles() || Angle( math.max( math.min(real_view.p+UCMD:GetMouseY()*sensitivity, 90), -90),real_view.y-UCMD:GetMouseX()*sensitivity,0)
	Hermes.set.angles = Hermes.set.angles + mouse
	
	Hermes.GetAngles( Hermes.set.angles, ucmd )
	
	ucmd:SetViewAngles( Hermes.set.angles )
	
	Hermes.Triggerbot()
	
	Hermes.set.fake = Angle( Hermes.set.angles.p, Hermes.set.angles.y, Hermes.set.angles.r )
	if ( Hermes.NospreadType( ucmd ) ) then
		if ( cone == 0 ) then end
		Hermes.set.fake = hack.CompensateWeaponSpread( ucmd, Vector( -cone, -cone, -cone ), Hermes.set.angles:Forward() ):Angle()
		ucmd:SetViewAngles( Hermes.set.fake )
	end
	
	if ( !Hermes.set.aiming ) then return end
	if ( tar == 0 ) then return end
	
	Hermes.set.target = true
	
	local aim, myPos, setView = Hermes:TargetLocation( tar ), ply:GetShootPos(), 0
	aim = aim + ( tar:GetVelocity() * 0.02 - ply:GetVelocity() * 0.05 ) + ( Vector( 0, 0, 0.0000000000000000001 ) )
	Hermes.set.angles = ( aim - myPos ):Angle()
	
	if ( Hermes.NospreadType( ucmd ) ) then
		setview = hack.CompensateWeaponSpread( ucmd, Vector( -cone, -cone, -cone ), Hermes.set.angles:Forward() ):Angle()
	else setview = Hermes.set.angles end
	
	setview.p = math.NormalizeAngle( setview.p )
	setview.y = math.NormalizeAngle( setview.y )
	
	ucmd:SetViewAngles( setview )
	
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
Hermes:AddCommand( "+hermes_aim", function() Hermes.set.aiming = true end )
Hermes:AddCommand( "-hermes_aim", function() Hermes.set.aiming = false Hermes.set.target = false end )

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
	local maxX, minX, maxY, minY, oPos = Hermes:CreatePos(e)
	
	if( e:Health() > normalhp ) then
		normalhp = e:Health()
	end
	
	local dmg, nor = normalhp / 4, e:Health() / 4
	
	oPos.x = oPos.x - ( dmg / 2 )
	oPos.y = oPos.y + 15
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( oPos.x, oPos.y, dmg, 4, col )
	
	surface.SetDrawColor( col.r, col.g, col.b, 255 )
	surface.DrawRect( oPos.x, oPos.y, nor, 4, col )
end

// Filter targets text and drawings.
function Hermes:TargetFilter( e )
	local text, box = "", false
	
	if ( ( Hermes:GetValue( Hermes.features.playeresp, 1 ) ) && e:IsPlayer() ) then
		box = true
		if ( e:Health() > 300 && e:Alive() ) then
			text = ( e:Nick() .. "\nHp: " .. e:Health() )
		else text = ( e:Nick() ), Hermes:HealthBar(e) end
		if ( !e:Alive() ) then text = e:Nick() .. "\n*DEAD*" end
		
	elseif ( ( Hermes:GetValue( Hermes.features.npcesp, 1 ) ) && e:IsNPC() ) then
		box = true
		text = ( e:GetClass() )
		
	elseif ( ( Hermes:GetValue( Hermes.features.weaponesp, 1 ) ) && e:IsWeapon() ) then
		box = false
		text = ( e:GetClass() )
		
	elseif ( IsRagdoll(e) ) then
		box = false
		text = ( "ragdoll" )
		
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
			
			if ( Hermes:GetValue( Hermes.features.box, 1 ) && box ) then
				surface.SetDrawColor( col.r, col.g, col.b, 255 )
				
				surface.DrawLine( maxX, maxY, maxX, minY )
				surface.DrawLine( maxX, minY, minX, minY )
					
				surface.DrawLine( minX, minY, minX, maxY )
				surface.DrawLine( minX, maxY, maxX, maxY )
			end
				
			Hermes:DrawText(
				text,
				"Default",
				pos.x,
				pos.y,
				color,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_TOP
			)
		end
	end
	
	if ( Hermes:GetValue( Hermes.features.crosshair, 1 ) ) then
		local g = 5; local s, x, y, l = 5, ( ScrW() / 2 ), ( ScrH() / 2 ), g + 15
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		surface.DrawLine( x - l, y, x - g, y )
		surface.DrawLine( x + l, y, x + g, y )
		
		surface.DrawLine( x, y - l, x, y - g )
		surface.DrawLine( x, y + l, x, y + g )
		
		surface.SetDrawColor( 255, 0, 0, 255 )
		
		surface.DrawLine( x, y - s, x, y + s )
		surface.DrawLine( x - s, y, x + s, y )
	end
end
Hermes:AddHook( "HUDPaint", Hermes.HUD )

//******************************
// Visuals
//******************************
function Hermes:CreateMaterial()
	
	local BaseInfo = {
		["$basetexture"] = "models/debug/debugwhite",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1,
		["$ignorez"]	 = 1
	}
   
   local mat = CreateMaterial( "hermes_mat", "VertexLitGeneric", BaseInfo )

   return mat

end

function Hermes.XQZ()
	local ent, ply = ents.GetAll(), LocalPlayer()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, false ) && Hermes:GetValue( Hermes.features.xqzwall, 1 ) ) then
			cam.Start3D( EyePos(), EyeAngles() )
				cam.IgnoreZ( true )
				e:DrawModel()
				cam.IgnoreZ( false )
			cam.End3D()
		end
	end
end

function Hermes.SetEntityMaterial()
	local ent, ply = ents.GetAll(), LocalPlayer()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, false ) && Hermes:GetValue( Hermes.features.chams, 1 ) ) then
			local mat, col = e:GetMaterial(), Hermes:TargetColors(e)
			
			e:SetMaterial( "hermes/living" )
			e:SetColor( col.r, col.g, col.b, 255 )
		else
			e:SetMaterial( "" )
			e:SetColor( 255, 255, 255, 255 )
		end
	end
end

function Hermes.OverrideMaterial()
	local ent, ply, c = ents.GetAll(), LocalPlayer(), ( 1 / 255 )
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, false ) && Hermes:GetValue( Hermes.features.chams, 1 ) ) then
			cam.Start3D( EyePos(), EyeAngles() )
				render.SuppressEngineLighting( false )
				render.SetColorModulation( 1, 1, 1 )
				e:SetMaterial( "" )
				e:DrawModel()
			cam.End3D()
		end
	end
end
Hermes:AddHook( "RenderScene", Hermes.SetEntityMaterial )

function Hermes.Effects()
	Hermes.XQZ()
	Hermes.OverrideMaterial()
end
Hermes:AddHook( "RenderScreenspaceEffects", Hermes.Effects )

//******************************
// Miscellaneous
//******************************
function Hermes.Bunnyhop()
	local ply = LocalPlayer()
	if ( Hermes:GetValue( Hermes.features.bunnyhop, 1 ) && input.IsKeyDown( KEY_SPACE ) ) then
		if ( ValidEntity( ply ) && ply:OnGround() ) then
			Hermes.old.rcc( "+jump" )
			timer.Create( "getping~~~", 0.1, 0, function() Hermes.old.rcc( "-jump" ) end )
		end
	end
end

function Hermes.Think()
	Hermes.Bunnyhop()
	Hermes.GetTraitor()
	Hermes.ConeThink()
end

Hermes:AddHook( "Think", Hermes.Think )

//******************************
// Menu VGUI
//******************************
// Pretty much the menu.
function Hermes.Menu()
	
	Hermes.set.panel = vgui.Create( "DFrame" )
	Hermes.set.panel:SetPos( ScrW() / 2 - 450 / 2, ScrH() / 2 - 350 / 2 )
	Hermes.set.panel:SetSize( 450, 350 )
	Hermes.set.panel:SetTitle( "Hermes :: Private Edition" )
	Hermes.set.panel:SetVisible( true )
	Hermes.set.panel:SetDraggable( true )
	Hermes.set.panel:ShowCloseButton( true )
	Hermes.set.panel:MakePopup()
	
	if ( !IsValid( Hermes.set.panel ) || Hermes.set.panel == nil ) then return end
	
	local propertypage = vgui.Create( "DPropertySheet" )
	propertypage:SetParent( Hermes.set.panel )
	propertypage:SetPos( 5, 25 )
	propertypage:SetSize( 440, 320 )
	
	local aim = vgui.Create( "DPanel", propertypage )
	local esp = vgui.Create( "DPanel", propertypage )
	local fri = vgui.Create( "DPanel", propertypage )
	
	local aimlist = vgui.Create( "DPanelList" )
	aimlist:SetPos( 10, 10 )
	aimlist:SetParent( aim )
	aimlist:SetSize( 440 - 15, 320 - 10 )
	aimlist:EnableVerticalScrollbar( true )
	aimlist:SetSpacing( 5 )
	aimlist.Paint = function() end
	
	local aimlistS = vgui.Create( "DPanelList" )
	aimlistS:SetPos( 150, 50 )
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
	esplistS:SetPos( 150, 10 )
	esplistS:SetParent( esp )
	esplistS:SetSize( 440 - 170, 320 - 10 )
	esplistS:EnableVerticalScrollbar( true )
	esplistS:SetSpacing( 5 )
	esplistS.Paint = function() end
	
	local label = vgui.Create( "DLabel" )
	label:SetParent( aim )
	label:SetPos( 150, 15 )
	label:SetWide( 100 )
	label:SetText( "Nospread: " )
	label:SetTextColor( Color( 0, 0, 0, 255 ) )
	
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
	// Friends list
	local combobox1
	function Hermes.AllPlayers()
		combobox1 = vgui.Create( "DComboBox" )
		combobox1:SetParent( fri )
		combobox1:SetPos( 10, 15 )
		combobox1:SetSize( 200, 230 )
		combobox1:SetMultiple( false )
		for k, e in pairs( player.GetAll() ) do
			if ( e != LocalPlayer() && !table.HasValue( Hermes.friends, e:Nick() ) ) then
				combobox1:AddItem( e:Nick() )
			end
		end
	end
	Hermes.AllPlayers()
	
	local combobox2
	function Hermes.OnlyFriends()
		combobox2 = vgui.Create( "DComboBox" )
		combobox2:SetParent( fri )
		combobox2:SetPos( 220, 15 )
		combobox2:SetSize( 200, 230 )
		combobox2:SetMultiple( false )
		for k, e in pairs( player.GetAll() ) do
			if ( table.HasValue( Hermes.friends, e:Nick() ) ) then
				combobox2:AddItem( e:Nick() )
			end
		end
	end
	Hermes.OnlyFriends()
	
		local button1 = vgui.Create( "DButton" )
	button1:SetParent( fri )
	button1:SetSize( 200, 20 )
	button1:SetPos( 10, 250 )
	button1:SetText( "Add" )
	button1.DoClick = function()
		if ( combobox1:GetSelectedItems() && combobox1:GetSelectedItems()[1] ) then
			for k, e in pairs( player.GetAll() ) do
				if ( e:Nick() == combobox1:GetSelectedItems()[1]:GetValue() ) then
					table.insert( Hermes.friends, e:Nick() )
				end
			end
		end
		Hermes.AllPlayers()
		Hermes.OnlyFriends()
	end
	
	local button2 = vgui.Create( "DButton" )
	button2:SetParent( fri )
	button2:SetSize( 200, 20 )
	button2:SetPos( 220, 250 )
	button2:SetText( "Remove" )
	button2.DoClick = function()
		if ( combobox2:GetSelectedItems() && combobox2:GetSelectedItems()[1] ) then
			for k, e in pairs( Hermes.friends ) do
				if ( e == combobox2:GetSelectedItems()[1]:GetValue() ) then
					table.remove( Hermes.friends, k )
				end
			end
		end
		Hermes.AllPlayers()
		Hermes.OnlyFriends()
	end
	// End of friends list
	
	for k, info in ipairs( Hermes.menuinfo ) do
		if ( info.CVar == "hermes_aim_nospread" ) then
		
		elseif ( info.Type == "boolean" ) then
			local checkbox = vgui.Create( "DCheckBoxLabel" )
			checkbox:SetText( info.Desc )
			checkbox:SetValue( GetConVarNumber( info.CVar ) )
			checkbox:SetTextColor( Color( 0, 0, 0, 255 ) )
			
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
			end
			
		elseif ( info.Type == "number" ) then
			local slider = vgui.Create( "DNumSlider" )
			slider:SetText( "" )
			slider:SetMax( info.Max || 1 )
			slider:SetMin( info.Min || 0 )
			slider:SetDecimals( 0 )
			slider:SetValue( GetConVarNumber( info.CVar ) )
			
			local label = vgui.Create( "DLabel" )
			label:SetParent( slider )
			label:SetWide( 200 )
			label:SetText( info.Desc )
			label:SetTextColor( Color( 0, 0, 0, 255 ) )
			
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
			end
		end
	end
	propertypage:AddSheet( "Aimbot", aim, "gui/silkicons/wrench", false, false, nil )
	propertypage:AddSheet( "ESP", esp, "gui/silkicons/group", false, false, nil )
	propertypage:AddSheet( "Friends List", fri, "gui/silkicons/star", false, false, nil )
end

Hermes:AddCommand( "hermes_menu", function() Hermes.Menu() end )