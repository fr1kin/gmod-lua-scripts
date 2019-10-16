/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: autowall.lua
	Purpose: Detect penetrable surfaces
*************************************************************/

local table = table.Copy( table )
local util = table.Copy( util )

HERMES:AddSetting( "aim_awall", true, "Autowall", "General" )

local base = {}

/* --------------------
	:: Trace
*/ --------------------
local function CreateEyeTrace()
	local ply = LocalPlayer()
	local eyetr = ply:GetEyeTrace()
	return eyetr || nil
end

/* --------------------
	:: SWEP Bases
*/ --------------------
function base.MADCOW( w, trc )
	local ply = LocalPlayer()
	local shell = {
		{ a = "AirboatGun", n = 18 },
		{ a = "Gravity", n = 8 },
		{ a = "AlyxGun", n = 12 },
		{ a = "Battery", n = 14 },
		{ a = "StriderMinigun", n = 20 },
		{ a = "SniperPenetratedRound", n = 16 },
		{ a = "CombineCannon", n = 20 },
	}
	
	local max = 16
	for k, v in pairs( shell ) do
		if( w.Primary['Ammo'] == v.a ) then
			max = v.n
		end
	end
	
	local function CreateTrace( tr )
		if( ( tr.MatType == MAT_METAL && w.Ricochet ) || ( tr.MatType == MAT_SAND ) || ( tr.Entity:IsPlayer() ) ) then return false end
		local dir = tr.Normal * max
		
		if( tr.MatType == MAT_GLASS || tr.MatType == MAT_PLASTIC || tr.MatType == MAT_WOOD || tr.MatType == MAT_FLESH || tr.MatType == MAT_ALIENFLESH ) then
			dir = tr.Normal * ( max * 2 )
		end
		
		local trace = {
			endpos = tr.HitPos,
			start = tr.HitPos + dir,
			mask = MASK_SHOT,
			filter = { ply },
		}
		local t = util.TraceLine( trace )
		
		if( t.StartSolid || t.Fraction >= 1.0 || tr.Fraction <= 0.0) then return false end
		return true
	end
	return CreateTrace( trc )
end

function base.GTA( w, tr )
	local ply = LocalPlayer()
	local dir = tr.Normal * ( w.GetPenetrationDistance && w:GetPenetrationDistance( tr.MatType ) || 0 )
	
	local trace = {
		endpos = tr.HitPos,
		start = tr.HitPos + dir,
		mask = MASK_SHOT,
		filter = { ply },
	}
	local t = util.TraceLine( trace ) 
	
	if( t.StartSolid || t.Fraction >= 1.0 || tr.Fraction <= 0.0 ) then return false end
	return true
end

function base.SNIPERWARS( w, tr )
	local ply = LocalPlayer()
	if ( w:GetClass() != "sniper_railgun" ) then return false end
	if( t.HitSky ) then return false end
	
	local pdir = t.Normal * self.PenetrationDist
	
	local trace = {
		start = t.HitPos + t.Normal,
		endpos = trace.start + pdir,
		mask = MASK_SOLID + CONTENTS_HITBOX,
	}
	
	if( util.PointContents( trace.endpos ) != 0 ) then return false end
	local t = util.TraceLine( trace ) 
	
	if( !t.StartSolid ) then return false end
	if( t.FractionLeftSolid == 1 || t.FractionLeftSolid == 0 ) then return false end
	
	return true
end

/* --------------------
	:: Autowall
*/ --------------------
local bases = {
	{ base = "MADCOW", items = { "weapon_mad_base", "weapon_mad_base_sniper" }, bounce = 3 },
	{ base = "GTA", items = { "gta_base", "as_swep_base" }, bounce = 3 },
	{ base = "SNIPERWARS", items = { "sniper_base" }, bounce = 3 },
}

function HERMES:IsPenetrable( tr )
	if( !HERMES.item['autowall'] ) then return false end
	if( !tr ) then return false end
	local ply = LocalPlayer()
	local w = ply:GetActiveWeapon()
	
	local u = nil
	for k, v in pairs( bases ) do
		for _, i in pairs( v.items ) do
			if( HERMES.GetBase( i ) ) then
				u = v.base || nil
			end
		end
	end
	
	if( !u ) then return false end
	if( base[u] ) then
		return base[u]( w, tr )
	end
	return false
end