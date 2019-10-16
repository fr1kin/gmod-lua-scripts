// Test
require( "hake" ) -- Rename the module

-- Concommand
concommand.Add( "run_ns_test", function()
	if ( Nospread ) then
		print( "This does exist!" )
	else
		print( "Nope is doesn't exist..." )
	end
end )

function WeaponVector( value, typ )
	local s = ( -value )
	
	if ( typ == true ) then
		s = ( -value )
	elseif ( typ == false ) then
		s = ( value )
	else
		s = ( value )
	end
	return Vector( s, s, s )
end

local currentseed, cmd2, seed = currentseed || 0, 0, 0
local w, vecCone, valCone = "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 )

local CustomCones 	= {}
CustomCones.Weapons = {}
CustomCones.Weapons[ "weapon_pistol" ]		= WeaponVector( 0.0100, true )	// HL2 Pistol
CustomCones.Weapons[ "weapon_smg1" ]		= WeaponVector( 0.04362, true )	// HL2 SMG1
CustomCones.Weapons[ "weapon_ar2" ]			= WeaponVector( 0.02618, true )	// HL2 AR2
CustomCones.Weapons[ "weapon_shotgun" ]		= WeaponVector( 0.08716, true )	// HL2 SHOTGUN

local NormalCones = { [ "weapon_cs_base" ] = true }

function GetCone( wep )
	local c = wep.Cone
	
	if ( !c && ( type( wep.Primary ) == "table" ) && ( type( wep.Primary.Cone ) == "number" ) ) then c = wep.Primary.Cone end
	if ( !c ) then c = 0 end
	if ( type( wep.Base ) == "string" && NormalCones[ wep.Base ] ) then return c end
	if ( ( wep:GetClass() == "ose_turretcontroller" ) ) then return 0 end
	return c || 0
end

function DoNospread( ucmd, angle )
	local ply = LocalPlayer()
	
	cmd2, seed = GetPrediction( ucmd )
	if ( cmd2 != 0 ) then currentseed = seed end
	
	local w = ply:GetActiveWeapon(); vecCone = Vector( 0, 0, 0 )
	if ( w && w:IsValid() && ( type( w.Initialize ) == "function" ) ) then
		valCone = GetCone( w )
			
		if ( type( valCone ) == "number" ) then
			vecCone = Vector( -valCone, -valCone, -valCone )
			
		elseif ( type( valCone ) == "Vector" ) then
			vecCone = valCone * -1
				
		end
	else
		if ( w:IsValid() ) then
			local class = w:GetClass()
				if ( CustomCones.Weapons[ class ] ) then
					vecCone = CustomCones.Weapons[ class ] 
				end
			end
		end
	return Nospread( currentseed || 0, ( angle || ply:GetAimVector():Angle() ):Forward(), vecCone ):Angle()
end


local angles = Angle( 0, 0, 0 )

function GetView()
	local ply = LocalPlayer()
	if ( !ValidEntity( ply ) ) then return end
	angles = ply:EyeAngles()
end
hook.Add( "OnToggled", "dGetViewAngles", GetView )

function CreateMove( ucmd )

	angles.p = math.NormalizeAngle( angles.p )
	angles.y = math.NormalizeAngle( angles.y )
	
	local correct = 1
	angles.y = math.NormalizeAngle( angles.y + ( ucmd:GetMouseX() * -0.022 * correct ) )
	angles.p = math.Clamp( angles.p + ( ucmd:GetMouseY() * 0.022 * correct ), -89, 90 )
	ucmd:SetViewAngles( angles )
	
	if ( ucmd:GetButtons() & IN_ATTACK > 0 ) then
		local fakeang = DoNospread( ucmd, angles )
		fakeang.p = math.NormalizeAngle( fakeang.p )
		fakeang.y = math.NormalizeAngle( fakeang.y )
		ucmd:SetViewAngles( fakeang )
	end
end
hook.Add( "CreateMove", "dNospread", CreateMove )

function CalcView( ply, origin, angles, FOV )
	local ply = LocalPlayer()
	local w = ply:GetActiveWeapon()
	
	if ( w.Primary ) then w.Primary.Recoil = 0 end
	if ( w.Secondary ) then w.Secondary.Recoil = 0 end
	
	local view = GAMEMODE:CalcView( ply, origin, angles, zoomFOV ) || {}
	view.angles = angles
	view.angles.r = 0
	view.fov = zoomFOV
	return view
end