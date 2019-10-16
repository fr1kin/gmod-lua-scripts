//-------------------------
// SysHack.dll
// NO-SPREAD & SPEEDHACK
//-------------------------
local wep, lastwep, cone, numshots

require( "syshack" )
local nospread = hack.CompensateWeaponSpread
hack = nil
_G.hack.CompensateWeaponSpread = nil

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
CustomCones.Weapons[ "weapon_pistol" ]			= WeaponVector( 0.0100, true, false )	// HL2 Pistol
CustomCones.Weapons[ "weapon_smg1" ]			= WeaponVector( 0.04362, true, false )	// HL2 SMG1
CustomCones.Weapons[ "weapon_ar2" ]				= WeaponVector( 0.02618, true, false )	// HL2 AR2
CustomCones.Weapons[ "weapon_shotgun" ]			= WeaponVector( 0.08716, true, false )	// HL2 SHOTGUN
CustomCones.Weapons[ "weapon_zs_zombie" ]		= WeaponVector( 0.0100, true, false )	// REGULAR ZOMBIE HAND
CustomCones.Weapons[ "weapon_zs_fastzombie" ]	= WeaponVector( 0.04362, true, false )	// FAST ZOMBIE HAND

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

function ConeThink()
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
			for c, s in pairs( cones.Weapon ) do
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
			else automatic = GetCone(weptable, "Automatic") end
				
			if ( weptable && weptable.Primary ) then end
				
		else
			cone = 0
			automatic = true
		end
	end
end
hook.Add( "Think", "Namehere", ConeThink )