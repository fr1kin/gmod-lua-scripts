/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: traitor.lua
	Purpose: Traitor detector
*************************************************************/

local table = table.Copy( table )
local player = table.Copy( player )

local flagged = { "weapon_ttt_c4", "weapon_ttt_knife", "weapon_ttt_phammer", "weapon_ttt_sipistol", "weapon_ttt_flaregun", "weapon_ttt_push", "weapon_ttt_radio", "weapon_ttt_teleport" }

local traitors, entities = {}, {}
local getWeapons = _R.Player.GetWeapons

HERMES:AddSetting( "aim_ttt_traitor", false, "Traitor", "Targeting" )
HERMES:AddSetting( "aim_ttt_detective", false, "Detective", "Targeting" )

/* --------------------
	:: GetTraitors
*/ --------------------
local function IsTraitor( e )
	local ply = LocalPlayer()
	if( ( ply.IsTraitor && ply:IsTraitor() ) && ( e.IsTraitor && e:IsTraitor() ) ) then
		return true
	end
	return false
end

local function IsDetective( e )
	return ( e.IsDetective && e:IsDetective() )
end

function HERMES:GetTraitors()
	local ply = LocalPlayer()
	if( IsTraitor( ply ) ) then traitors = {} entities = {} return end
	if( HERMES.GetGamemode( "terror town", "terrortown" ) ) then
		for _, e in pairs( player.GetAll() ) do
			local weps = getWeapons( e )
			for _, w in pairs( weps ) do
				if( ValidEntity( w ) && table.HasValue( flagged, w:GetClass() ) && !traitors[e] && !entities[w] && !IsDetective( e ) ) then
					traitors[e] = true
					entities[w] = true
				end
			end
		end
	end
end

function HERMES:IsTraitor( e )
	return IsTraitor( e ) || ( traitors[e] && true || false )
end

function HERMES:TerrorColors( e )
	if( !HERMES.GetGamemode( "terror town", "terrortown" ) ) then return end
	if( HERMES:IsTraitor( e ) ) then
		return Color( 255, 0, 0, 255 )
	elseif( IsDetective( e ) ) then
		return Color( 0, 0, 255, 255 )
	else
		return Color( 0, 255, 0, 255 )
	end
	return
end

function HERMES:TerrorMode( e )
	if( !HERMES.GetGamemode( "terror town", "terrortown" ) ) then return end
	
	local ply = LocalPlayer()
	if( HERMES.item['traitor'] && IsTraitor( e ) ) then
		return true
	elseif( HERMES.item['detective'] && ( !IsTraitor( ply ) && IsDetective( e ) ) ) then
		return true
	end
	return false
end

usermessage.IncomingMessage = HERMES:Detour( usermessage.IncomingMessage, function( name, msg, ... )
	if( name == "ttt_role" ) then
		traitors = {}
		entities = {}
	end
	return HERMES.detours[ usermessage.IncomingMessage ]( name, msg, ... )
end )