/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: other.lua
	Purpose: Contains other boring stuff
*************************************************************/

local table = table.Copy( table )
local timer = table.Copy( timer )
local hook = table.Copy( hook )
local input = table.Copy( input )

local SetButtons = _R.CUserCmd.SetButtons
local GetButtons = _R.CUserCmd.GetButtons

HERMES:AddTab( "Extra" )

HERMES:AddTabItem( "Extra", "Misc" )
HERMES:AddTabItem( "Extra", "Removals" )

HERMES:AddSetting( "misc_radar", true, "Radar", "Misc" )
HERMES:AddSetting( "misc_admins", true, "Adminlist", "Misc" )
HERMES:AddSetting( "misc_bhop", true, "Bunnyhop", "Misc" )
HERMES:AddSetting( "misc_autopistol", true, "Autopistol", "Misc" )
HERMES:AddSetting( "misc_speed", 2, "Speed", "Misc", 1, 10, false )
HERMES:AddSetting( "misc_rage", 2, "RadarRange", "Misc", 1, 200, false )

HERMES:AddSetting( "misc_nohands", false, "Nohands", "Removals" )
HERMES:AddSetting( "rem_particals", true, "Particles", "Removals" )
HERMES:AddSetting( "rem_fullbright", false, "Fullbright", "Removals" )

/* --------------------
	:: Bunnyhop
*/ --------------------
function HERMES:Bunnyhop( ucmd )
	local ply = LocalPlayer()
	if ( HERMES.item['bunnyhop'] && ucmd:KeyDown( IN_JUMP ) ) then
		if ( !ply:OnGround() ) then
			SetButtons( ucmd, GetButtons( ucmd ) - IN_JUMP )
		end
	end
end

/* --------------------
	:: Autopistol
*/ --------------------
local hl2 = { "gmod_tool", "weapon_pistol" }
function HERMES:Autopistol( ucmd )
	if( HERMES.GetGamemode( "terror town", "terrortown" ) ) then return end
	local ply = LocalPlayer() 
	
	local w = ply:GetActiveWeapon()
	if( ValidEntity( w ) && HERMES.item['autopistol'] && ( ( w.Primary && w.Primary.Automatic == false || w.Automatic == false ) || table.HasValue( hl2, w:GetClass() ) ) ) then
		if( input.IsMouseDown( MOUSE_LEFT ) ) then
			HERMES.hermes.RunCommand( "+attack" )
			timer.Simple( 0.05, function() HERMES.hermes.RunCommand( "-attack" ) end )
		end
	end
end

/* --------------------
	:: Antigag
*/ --------------------
function HERMES:Gag()
	local ply = LocalPlayer()
	if( Hermes.features['antigag'] ) then
		if ( ulx && ulx['gagUser'] ) then
			ulx['gagUser']( false )
			hook.Remove( "PlayerBindPress", "ULXGagForce" )
			timer.Destroy( "GagLocalPlayer" )
		end
		if ( evolve ) then
			ply:SetNWBool( "Muted", false )
		end
	end
end

/* --------------------
	:: Nohands
*/ --------------------
local int, load = 0, false
function HERMES:ToggleHands()
	local hands = HERMES.item['nohands'] && 1 || 0
	
	if( hands == 1 ) then
		if( int != 1 ) then
			HERMES.hermes.ToggleHands()
			load = true
			int = 1
		end
	else
		if( load && int != 0 ) then
			HERMES.hermes.ToggleHands()
			int = 0
		end
	end
end

/* --------------------
	:: Radar
*/ --------------------
function HERMES:ToggleRadar()
	local radar = HERMES:GetRadar()
	if( !HERMES.item['radar'] && radar:IsVisible() ) then
		radar:SetVisible( false )
	elseif( HERMES.item['radar'] && !radar:IsVisible() ) then
		radar:SetVisible( true )
	end
	radar:SetRange( HERMES.item['radarrange'] )
end

/* --------------------
	:: Adminlist
*/ --------------------
function HERMES:ToggleAdminlist()
	local admins = HERMES:GetAdminlist()
	if( !HERMES.item['adminlist'] && admins:IsVisible() ) then
		admins:SetVisible( false )
	elseif( HERMES.item['adminlist'] && !admins:IsVisible() ) then
		admins:SetVisible( true )
	end
end

/* --------------------
	:: Removals
*/ --------------------
function HERMES:Removals()
	local particels = HERMES.item['particles'] && "0" || "1"
	HERMES.hermes.RunCommand( "_hermes_r_drawparticles " .. particels )
	
	local fullbright = HERMES.item['fullbright'] && "1" || "0"
	HERMES.hermes.RunCommand( "_hermes_mat_fullbright " .. fullbright )
end

/* --------------------
	:: Speedhack
*/ --------------------
function HERMES.EnableSpeed()
	HERMES.hermes.ForceVar( "_hermes_host_timescale", HERMES.item['speed'] )
end

function HERMES.DisableSpeed()
	HERMES.hermes.ForceVar( "_hermes_host_timescale", 1.0 )
end

HERMES:AddCommand( "+hermes_speed", HERMES.EnableSpeed )
HERMES:AddCommand( "-hermes_speed", HERMES.DisableSpeed )

/* --------------------
	:: Think
*/ --------------------
function HERMES.Think()
	HERMES:ToggleHands();
	HERMES:GetTraitors();
	HERMES:ToggleRadar();
	HERMES:ToggleAdminlist();
	HERMES:Removals();
end
HERMES:AddHook( "Think", HERMES.Think )