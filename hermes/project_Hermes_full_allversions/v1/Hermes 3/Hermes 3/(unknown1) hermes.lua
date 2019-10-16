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
local Hermes			= {}
Hermes.features			= {}
Hermes.commands			= {}
Hermes.convars			= {}
Hermes.hooks			= {}
Hermes.old				= {}
Hermes.create			= {}
Hermes.files			= { "hermes" }

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

Hermes.set = {
	aiming = false,
	angles = Angle( 0, 0, 0 ),
	view = {},
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

function Hermes:CreateClientConVar( cvar, val, tblname )
	local gVar = Hermes.old.cccv( "hermes_" .. cvar, val, true, false )
	
	if ( type( val ) == "number" ) then
		Hermes.features[ tblname ] = gVar:GetInt()
	elseif ( type( val ) == "string" ) then
		Hermes.features[ tblname ] = gVar:GetString()
	end
	
	table.insert( Hermes.convars, cvar )
	
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
Hermes:CreateClientConVar( "aim_shoot", 0, "autoshoot" )
Hermes:CreateClientConVar( "aim_trigger", 0, "triggerbot" )
Hermes:CreateClientConVar( "aim_fov", 180, "fov" )
Hermes:CreateClientConVar( "esp_player", 1, "playeresp" )
Hermes:CreateClientConVar( "esp_npc", 1, "npcesp" )
Hermes:CreateClientConVar( "esp_weapon", 0, "weaponesp" )
Hermes:CreateClientConVar( "vis_xqz", 1, "xqzwall" )
Hermes:CreateClientConVar( "vis_cross", 1, "crosshair" )
Hermes:CreateClientConVar( "misc_bhop", 1, "bunnyhop" )

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
end

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

function _R.Player.ConCommand( ply, cvar )
	Hermes.callpath	= Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.pcc( ply, cvar ) end
	for k, v in pairs( Hermes.convars ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	return Hermes.old.pcc( ply, cvar )
end

function debug.getinfo( thread, func )
	Hermes.callpath	= Hermes.old.debug.getinfo(2)['short_src']
	if ( Hermes.callpath && Hermes.callpath == Hermes.set.path ) then return Hermes.old.debug.getinfo( thread, func ) end
	return {}
end

//------------------------------
// Fonts, Colors and Filters:
//------------------------------
// Max screen, so useless shit that you don't see is drawn.
function Hermes:OnScreen( e )
	local x, y, pos = ScrW(), ScrH(), e:GetPos():ToScreen()
	if ( pos.x > 0 && pos.y > 0 && pos.x < x && pos.y < y ) then
		return true
	end
	return false
end

// TTT traitor detector
Hermes.traitors = {}
Hermes.traitorsweps = { "weapon_ttt_c4", "weapon_ttt_knife", "weapon_ttt_phammer", "weapon_ttt_sipistol", "weapon_ttt_flaregun", "weapon_ttt_push", "weapon_ttt_radio", "weapon_ttt_teleport" }

function Hermes.GetTraitor()
	if !( GAMEMODE || GAMEMODE.Name || string.find( GAMEMODE.Name, "Trouble in Terror" ) ) then return end
	local ent, ply = player.GetAll(), LocalPlayer()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		if ( ValidEntity( e ) && e != ply ) then
			local weps = e:GetWeapons()
			for i = 1, table.Count( weps ) do
				local w = weps[i]
				if ( table.HasValue( Hermes.traitorsweps, w:GetClass() ) && !table.HasValue( Hermes.traitors, e:Nick() ) && !e:IsDetective() ) then
					table.insert( Hermes.traitors, e:Nick() )
				end
			end
		end
	end
end
Hermes:AddHook( "Think", Hermes.GetTraitor )

local oldUserMSG = usermessage.IncomingMessage
function usermessage.IncomingMessage( name, um, ... )
	if ( name == "ttt_role" ) then
		for k , v in pairs( Hermes.traitors ) do
			Hermes.traitors = {}
		end
	end
	
	return oldUserMSG( name, um, ... )
end

// Entities that are allowed to draw.
function Hermes:FilterEntities( e, use )
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	if ( use == true ) then
		if ( !ValidEntity( e ) ) then return false end
		if ( !Hermes:OnScreen(e) ) then return false end
		if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() || e == ply ) then return false end
		if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
		if ( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE || e:IsNPC() && table.HasValue( Hermes.deathsequences[ model ] || {}, e:GetSequence() ) ) then return false end
		if ( e:IsWeapon() && e:GetMoveType() == MOVETYPE_NONE ) then return false end
		return true
	elseif ( use == false ) then
		if ( !ValidEntity( e ) ) then return false end
		if ( !Hermes:OnScreen(e) ) then return false end
		if ( !( e:IsValid() || e:IsPlayer() && e:IsNPC() && e:IsWeapon() ) || e == ply ) then return false end
		if ( e:IsPlayer() && !e:Alive() || e:Health() <= 0 ) then return false end
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
		if ( !IsEnemyEntityName( e:GetClass() ) ) then
			col = Color( 0, 100, 0, 255 )
		elseif ( IsEnemyEntityName( e:GetClass() ) || ( e:GetClass() == "npc_metropolice" ) ) then
			col = Color( 230, 0, 0, 255 )
		end
	elseif ( e:IsWeapon() ) then
		col = Color( 215, 100, 0, 255 )
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
	
	if ( e:IsWeapon() ) then pos = e:LocalToWorld( e:OBBCenter() ) end
	
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
// Simple way to add bones or vectors.
function Hermes:GetPos( e, pos )
	if ( type( pos ) == "string" ) then
		return ( e:GetBonePosition( e:LookupBone( pos ) ) )
	elseif ( type( pos ) == "Vector" ) then
		return ( e:LocalToWorld( pos ) )
	end
	return ( e:LocalToWorld( pos ) )
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
	
	return pos
end

// Allow only these entities to be targeted.
function Hermes:ValidTargets( e )
	local ply, model = LocalPlayer(), string.lower( e:GetModel() || "" )
	if ( !ValidEntity( e ) ) then return false end
	if ( !e:IsValid() || ( !e:IsPlayer() && !e:IsNPC() ) || e == ply ) then return false end
	if ( e:IsPlayer() && !e:Alive() || e:IsPlayer() && e:Health() <= 0 ) then return false end
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
	if ( !Hermes.set.aiming ) then return end
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
		
		local ang = ( e:GetPos() - ply:GetShootPos() ):Angle()
		local angY = math.abs( math.NormalizeAngle( myAngV.y - ang.y ) )
		local angP = math.abs( math.NormalizeAngle( myAngV.p - ang.p ) )
		
		if ( angY < tonumber( Hermes.features.fov ) && angP < tonumber( Hermes.features.fov ) ) then
			if ( ValidEntity( e ) && Hermes:ValidTargets( e ) && Hermes:VisibleTarget( e ) && !util.IsValidProp( trace.Entity:GetModel() ) ) then
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

// Aim at the target
function Hermes.Aim( ucmd )
	local ply = LocalPlayer()
	local tar = Hermes:GetTarget()
	
	local mouse = Angle( ucmd:GetMouseY() * Hermes.old.gcvn( "m_pitch" ), ucmd:GetMouseX() * -Hermes.old.gcvn("m_yaw") ) || Angle( 0, 0, 0 )
	Hermes.set.angles = Hermes.set.angles + mouse
	Hermes.set.angles.y = math.NormalizeAngle( Hermes.set.angles.y + ( ucmd:GetMouseX() * -0.022 * 1 ) )
	Hermes.set.angles.p = math.Clamp( Hermes.set.angles.p + ( ucmd:GetMouseY() * 0.022 * 1 ), -89, 90 )
	
	ucmd:SetViewAngles( Hermes.set.angles )
	
	if ( Hermes:GetValue( Hermes.features.triggerbot, 1 ) ) then
		local trace = Hermes:AimTrace()
		
		if ( ValidEntity( trace.Entity ) && Hermes:ValidTargets( trace.Entity ) ) then
			Hermes.old.rcc( "+attack" )
			timer.Simple( 0.1, function() Hermes.old.rcc( "-attack" ) end )
		end
	end
	
	if ( !Hermes.set.aiming ) then return end
	if ( tar == 0 ) then return end
	
	Hermes.set.target = true
	
	local aim, myPos = Hermes:TargetLocation( tar ), ply:GetShootPos()
	aim = aim + ( tar:GetVelocity() / 45 - ply:GetVelocity() / 45 )
	
	Hermes.set.angles = ( aim - myPos ):Angle()
	
	Hermes.set.angles.p = math.NormalizeAngle( Hermes.set.angles.p )
	Hermes.set.angles.y = math.NormalizeAngle( Hermes.set.angles.y )
	
	ucmd:SetViewAngles( Hermes.set.angles )
	
	if ( Hermes:GetValue( Hermes.features.autoshoot, 1 ) && !Hermes:GetValue( Hermes.features.triggerbot, 1 ) ) then
		Hermes.old.rcc( "+attack" )
		timer.Simple( 0.1, function() Hermes.old.rcc( "-attack" ) end )
	end
end
Hermes:AddHook( "CreateMove", Hermes.Aim )


// Recoil removal
function Hermes.NoRecoil( ply, origin, angles, FOV )
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	// SWEP no-recoil.
	if ( wep.Primary ) then wep.Primary.Recoil = 0 end
	if ( wep.Secondary ) then wep.Secondary.Recoil = 0 end
	
	// No visual recoil.
	local view = GAMEMODE:CalcView( ply, origin, Hermes.set.angles, FOV ) || {}
	view.angles = Hermes.set.angles
	view.angles.r = 0
	return view
end
Hermes:AddHook( "CalcView", Hermes.NoRecoil )


// Add console commands
Hermes:AddCommand( "+hermes_aim", function() Hermes.set.aiming = true end )
Hermes:AddCommand( "-hermes_aim", function() Hermes.set.aiming = false Hermes.set.target = false end )

//******************************
// HUD
//******************************

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
		if ( e:Health() > 300 ) then
			text = ( e:Nick() .. "\nHp: " .. e:Health() )
		else text = ( e:Nick() ), Hermes:HealthBar(e) end
		
	elseif ( ( Hermes:GetValue( Hermes.features.npcesp, 1 ) ) && e:IsNPC() ) then
		box = true
		text = ( e:GetClass() )
		
	elseif ( ( Hermes:GetValue( Hermes.features.weaponesp, 1 ) ) && e:IsWeapon() ) then
		box = false
		text = ( e:GetClass() )
		
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
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, true ) ) then
			local text, box, col, maxX, minX, maxY, minY, pos = Hermes:TargetFilter(e)
			local color = Color( col.r, col.g, col.b, 255 ) 
			
			if ( box ) then
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
function Hermes.XQZ()
	local ent, ply = ents.GetAll(), LocalPlayer()
	
	for i = 1, table.Count( ent ) do
		local e = ent[i]
		
		if ( ValidEntity( e ) && Hermes:FilterEntities( e, false ) && Hermes:GetValue( Hermes.features.xqzwall, 1 ) ) then
			cam.Start3D( EyePos(), EyeAngles() )
				cam.IgnoreZ( true )
				render.SuppressEngineLighting( true )
				e:DrawModel()
				render.SuppressEngineLighting( false )
				cam.IgnoreZ( false )
			cam.End3D()
		end
	end
end
Hermes:AddHook( "RenderScreenspaceEffects", Hermes.XQZ )

//******************************
// Miscellaneous
//******************************
function Hermes.Think()
	local ply = LocalPlayer()
	local curWep = ply:GetActiveWeapon():GetClass()
	if ( Hermes:GetValue( Hermes.features.bunnyhop, 1 ) && input.IsKeyDown( KEY_SPACE ) ) then
		if ( ValidEntity( ply ) && ply:OnGround() ) then
			Hermes.old.rcc( "+jump" )
			timer.Create( "getping~~~", 0.1, 0, function() Hermes.old.rcc( "-jump" ) end )
		end
	end
end
Hermes:AddHook( "Think", Hermes.Think )