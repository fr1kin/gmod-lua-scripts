/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name:
	Purpose:
*************************************************************/

local table = table.Copy( table )
local util = table.Copy( util )
local timer = table.Copy( timer )

HERMES:AddTabItem( "Aimbot", "Triggerbot" )

HERMES:AddSetting( "aim_trig_trigger", false, "Triggerbot", "Triggerbot" )
HERMES:AddSetting( "aim_trig_nospread", false, "Trigger-nospread", "Triggerbot" )

/* --------------------
	:: GetTrace
*/ --------------------
function HERMES:ViewTrace()
	local ply = LocalPlayer()
	local start, endP = ply:GetShootPos(), ply:GetAimVector()
	
	local trace = {}
	trace.start = start
	trace.endpos = start + ( endP * 16384 )
	trace.filter = { ply }
	trace.mask = MASK_SHOT
	
	return util.TraceLine( trace )
end

/* --------------------
	:: Triggerbot
*/ --------------------
function HERMES:Triggerbot( ucmd )
	if( !HERMES.item['triggerbot'] ) then return end
	
	local e = LocalPlayer():GetEyeTrace()
	if( HERMES:FilterTargets( e.Entity, "aim" ) ) then
		ucmd:SetButtons( ucmd:GetButtons() | IN_ATTACK )
		timer.Simple( 0.05, function() HERMES.hermes.RunCommand( "-attack" ) end )
	end
end