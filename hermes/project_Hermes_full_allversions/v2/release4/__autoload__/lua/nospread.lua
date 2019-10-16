/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: nospread.lua
	Purpose: Nospread
*************************************************************/

local CONE = {}
HERMES.bullet = {}

HERMES:AddSetting( "aim_spread", true, "Spread", "Accuracy" )

/* --------------------
	:: HL2 Nospread
*/ --------------------
local function WeaponVector( value, typ, vec )
	if ( !vec ) then return tonumber( value ) end
	local s = ( tonumber( value ) )
	if ( typ == true ) then
		s = ( tonumber( -value ) )
	end
	return Vector( s, s, s )
end

CONE.weapon = {}
CONE.weapon["weapon_pistol"]			= WeaponVector( 0.0100, true, true )	// HL2 Pistol
CONE.weapon["weapon_smg1"]				= WeaponVector( 0.04362, true, true )	// HL2 SMG1
CONE.weapon["weapon_ar2"]				= WeaponVector( 0.02618, true, true )	// HL2 AR2
CONE.weapon["weapon_shotgun"]			= WeaponVector( 0.08716, true, true )	// HL2 SHOTGUN
CONE.weapon["weapon_zs_zombie"]			= WeaponVector( 0.0, true, true )		// REGULAR ZOMBIE HAND
CONE.weapon["weapon_zs_fastzombie"]		= WeaponVector( 0.0, true, true )		// FAST ZOMBIE HAND

/* --------------------
	:: Firebullets
*/ --------------------
_R.Entity.FireBullets = HERMES:Detour( _R.Entity.FireBullets, function( e, bullet )
	local w = LocalPlayer():GetActiveWeapon()
	HERMES.bullet[w:GetClass()] = bullet.Spread
	return HERMES.detours[ _R.Entity.FireBullets ]( e, bullet )
end )

/* --------------------
	:: Data Nospread
*/ --------------------

/* --------------------
	:: PredictSpread
*/ --------------------
function HERMES:PredictSpread( ucmd, angle )
	local ply = LocalPlayer()
	local w = ply:GetActiveWeapon()
	if ( w && w:IsValid() ) then
		local class = w:GetClass()
		if ( !CONE.weapon[class] ) then
			if ( HERMES.bullet[class] ) then
				local ang = angle:Forward() || ( ply:GetAimVector():Angle() ):Forward()
				local conevec = Vector( 0, 0, 0 ) - HERMES.bullet[class] || Vector( 0, 0, 0 )
				return HERMES.hermes.PredictSpread( ucmd, ang, conevec ):Angle()
			end
		else
			local ang = angle:Forward() || ply:GetAimVector():Angle()
			local conevec = CONE.weapon[class]
			return HERMES.hermes.PredictSpread( ucmd, ang, conevec ):Angle()
		end
	end
	return angle
end