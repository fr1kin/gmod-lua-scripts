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

HERMES:AddSetting( "misc_bhop", true, "Bunnyhop", "Misc" )
HERMES:AddSetting( "misc_autopistol", true, "Autopistol", "Misc" )
HERMES:AddSetting( "misc_nohands", false, "Nohands", "Misc" )
HERMES:AddSetting( "misc_speed", 2, "Speed", "Misc" )

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
		if( input.IsMouseDown( MOUSE_LEFT ) && HERMES._canshoot ) then
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
			//HERMES.hermes.ToggleHands()
			load = true
			int = 1
		end
	else
		if( load && int != 0 ) then
			//HERMES.hermes.ToggleHands()
			int = 0
		end
	end
end

/* --------------------
	:: Speedhack
*/ --------------------
/*
local function IncreaseSpeed()
	HERMES.hermes.RunCommand( "_hermes_host_timescale " .. HERMES.item['speed'] )
end

local function Disable()
	HERMES.hermes.RunCommand( "_hermes_host_timescale 0" )
end

HERMES:AddCommand( "+hermes_speed", IncreaseSpeed )
HERMES:AddCommand( "-hermes_speed", Disable )
*/
/* --------------------
	:: _canshoot
*/ --------------------
local _loop = 0
function HERMES:canshoot()
	if( _loop == 5 ) then
		HERMES._canshoot = false;
		_loop = 0;
	end
	_loop = _loop + 1
end

/* --------------------
	:: Think
*/ --------------------
function HERMES.Think()
	if( HERMES['_lock'] == true ) then return end
	HERMES:canshoot();
	HERMES:ToggleHands();
	HERMES:GetTraitors();
end
HERMES:AddHook( "Think", HERMES.Think )