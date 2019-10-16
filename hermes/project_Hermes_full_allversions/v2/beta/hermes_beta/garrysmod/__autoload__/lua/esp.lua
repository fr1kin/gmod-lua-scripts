/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: esp.lua
	Purpose: Visuals
*************************************************************/

local table = table.Copy( table )
local string = table.Copy( string )
local surface = table.Copy( surface )
local draw = table.Copy( draw )

local ply = HERMES.GetSelf
local x, y = ScrW(), ScrH()

local WHITE = Color( 255, 255, 255 )
local BLACK = Color( 0, 0, 0 )
local RED = Color( 255, 0, 0 )
local BLUE = Color( 0, 255, 0 )
local GREEN = Color( 0, 0, 255 )

local LookupBone = _R.Entity.LookupBone
local GetBonePosition = _R.Entity.GetBonePosition

HERMES:AddTab( "ESP" )
HERMES:AddTabItem( "ESP", "Player" )
HERMES:AddTabItem( "ESP", "NPC" )
HERMES:AddTabItem( "ESP", "Visuals" )

HERMES:AddSetting( "esp_players", true, "Players", "Player" )
HERMES:AddSetting( "esp_optical", true, "Optical", "Player" )
HERMES:AddSetting( "esp_far", true, "Far", "Player" )
HERMES:AddSetting( "esp_skeleton", false, "Skeleton", "Player" )
HERMES:AddSetting( "esp_bar", false, "DynamicBar", "Player" )
HERMES:AddSetting( "esp_warnings", false, "LOSWarnings", "Player" )
HERMES:AddSetting( "esp_npcs", false, "NPCs", "NPC" )

HERMES:AddSetting( "vis_cross", true, "Crosshair", "Visuals" )
HERMES:AddSetting( "vis_color", true, "Color", "Visuals" )

local function NormalAngle( ang, ang2 )
	return math.abs( math.NormalizeAngle( ang - ang2 ) )
end
/* --------------------
	:: Crosshair
*/ --------------------
function HERMES:Crosshair()
	if( !HERMES.item['crosshair'] ) then return end
	local x, y = x / 2, y / 2
	
	// Asb's crosshair
	surface.SetDrawColor( BLACK )
	surface.DrawRect( x - 1, y - 3, 3, 7 )
	surface.DrawRect( x - 3, y - 1, 7, 3 )
	
	surface.SetDrawColor( RED )
	surface.DrawLine( x, y - 2, x, y + 2.75 )
	surface.DrawLine( x - 2, y, x + 2.75, y )
end

/* --------------------
	:: Coordinates
*/ --------------------
function HERMES:GetCoordinates( e, bar )
	bar = bar || false
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
	
	local num = ( !bar && HERMES.IsDormant( e ) ) && 2 || 1
	if( bar ) then
		num = ( 100 / e:Health() )
		if ( e:Health() <= 0 ) then 
			num = 0.1
		end
	end
	local FRT 	= center + frt + rgt + top / num; FRT = FRT:ToScreen()
	local BLB 	= center + bak + lft + btm / num; BLB = BLB:ToScreen()
	local FLT	= center + frt + lft + top / num; FLT = FLT:ToScreen()
	local BRT 	= center + bak + rgt + top / num; BRT = BRT:ToScreen()
	local BLT 	= center + bak + lft + top / num; BLT = BLT:ToScreen()
	local FRB 	= center + frt + rgt + btm / num; FRB = FRB:ToScreen()
	local FLB 	= center + frt + lft + btm / num; FLB = FLB:ToScreen()
	local BRB 	= center + bak + rgt + btm / num; BRB = BRB:ToScreen()
	
	local maxX = math.max( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local minX = math.min( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local maxY = math.max( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	local minY = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	
	return maxX, minX, maxY, minY
end

function HERMES:Static( e )
	local maxs, mins, center = e:OBBMaxs(), e:OBBMins(), e:OBBCenter()
end

/* --------------------
	:: On Screen
*/ --------------------
function HERMES:OnScreen( e )
	local x, y = ScrW(), ScrH()
	local posTypes = { "OBBCenter", "OBBMaxs", "OBBMins" }
	
	for k, v in pairs( posTypes ) do
		local pos = e:LocalToWorld( _R.Entity[ v ]( e ) ):ToScreen()
		if ( pos.x > 0 && pos.y > 0 && pos.x < x && pos.y < y ) then
			return true
		end
	end
	return false
end

/* --------------------
	:: Filter Targets
*/ --------------------
function HERMES:FilterTargets( e, mode )
	local ply = LocalPlayer()
	if( !e || e && !ValidEntity( e ) ) then return false end
	if( mode:lower() == "esp" ) then
		if( !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() || e == ply ) then return false end
		if( !HERMES:OnScreen( e ) ) then return false end
		if( e:IsNPC() && !HERMES.item['npcs'] ) then return false end
		if( ( e:IsNPC() || e:IsWeapon() ) && e:GetMoveType() == MOVETYPE_NONE ) then return false end
		if( e:IsPlayer() ) then
			if( !HERMES.item['players'] ) then return false end
			if( !HERMES.item['far'] && HERMES.IsDormant( e ) ) then return false end
			if( !e:Alive() || e:Health() < 0 ) then return false end
			if( e:GetMoveType() == MOVETYPE_OBSERVER || e:GetMoveType() == MOVETYPE_NONE ) then return false end
			if( string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
		end
		return true
	elseif( mode:lower() == "aim" ) then
		if( !e:IsPlayer() && !e:IsNPC() || e == ply ) then return false end
		if( e:IsNPC() && !HERMES.item['npcs'] ) then return false end
		if( e:IsNPC() && e:GetMoveType() == MOVETYPE_NONE ) then return false end
		if( e:IsPlayer() ) then
			if( HERMES.IsDormant( e ) ) then return false end
			if( !e:Alive() || e:Health() < 0 ) then return false end
			if( e:GetMoveType() == MOVETYPE_OBSERVER || e:GetMoveType() == MOVETYPE_NONE ) then return false end
			if( string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
			if( HERMES:TerrorMode( e ) ) then return false end
			if( e:GetFriendStatus() == "friend" && HERMES.item['steam'] ) then return false end
			if( e:Team() == ply:Team() && HERMES.item['team'] ) then return false end
		end
		if ( tonumber( HERMES.item['fov'] ) != 180 ) then
			local myang = ply:GetAngles()
			local ang = ( e:GetPos() - ply:GetShootPos() ):Angle()
			local angY = math.abs( math.NormalizeAngle( myang.y - ang.y ) )
			local angP = math.abs( math.NormalizeAngle( myang.p - ang.p ) )
			
			if ( angY > tonumber( HERMES.item['fov'] ) || angP > tonumber( HERMES.item['fov'] ) ) then return false end
		end
		return true
	end
	return false
end

/* --------------------
	:: Colors
*/ --------------------
function HERMES:TargetColors( e )
	if( e:IsPlayer() ) then
		if( HERMES:TerrorColors( e ) ) then
			return HERMES:TerrorColors( e )
		end
		return team.GetColor( e:Team() ) || WHITE
	elseif( e:IsNPC() ) then
		return WHITE
	end
	return WHITE
end

/* --------------------
	:: Get Targets
*/ --------------------
function HERMES:GetTargets( e )
	if( HERMES:FilterTargets( e, "esp" ) ) then
		if( e:IsPlayer() ) then
			return true, { e:Nick(), "H: " .. e:Health() }, HERMES:TargetColors( e )
		elseif( e:IsNPC() ) then
			return true, { e:GetClass() }, HERMES:TargetColors( e )
		end
		return nil
	end
	return nil
end

/* --------------------
	:: Warnings
*/ --------------------
function HERMES:Warnings()
	if( !HERMES.item['loswarnings'] ) then return end
	local ply = LocalPlayer()
	
	local x, y = ScrW() / 2, ScrH() / 2
	local pos, aimvec, size = ply:GetPos(), ply:GetAimVector(), ( math.min( ScrW(), ScrH() ) * 1 ) / 2
	for k, e in ipairs( player.GetAll() ) do
		if ( e != ply && !HERMES:OnScreen( e ) && e:Alive() ) then
			local offset = ( pos - e:GetPos() )
			local rad = math.Deg2Rad( math.Rad2Deg( math.atan2( offset.x, offset.y ) ) - math.Rad2Deg( math.atan2( aimvec.x, aimvec.y ) ) - 90 )
			local cos, sin = math.cos( rad ) * -size, math.sin( rad ) * -size
			local posX, posY = x + cos, y + sin
			
			local poly = { {}, {}, {} }
			poly[1]["x"] = posX
			poly[1]["y"] = posY
			poly[1]["u"] = posX
			poly[1]["v"] = posY
			
			poly[2]["x"] = posX + 10
			poly[2]["y"] = posY - 10
			poly[2]["u"] = posX
			poly[2]["v"] = posY
			
			poly[3]["x"] = posX + 10
			poly[3]["y"] = posY + 10
			poly[3]["u"] = posX
			poly[3]["v"] = posY
			
			surface.SetDrawColor( HERMES:TargetColors( e ) )
			surface.DrawPoly( poly )
		end
	end
end

/* --------------------
	:: Vertical HPBar
*/ --------------------
function HERMES:VerticalBar( e, col )
	if( !HERMES.item['dynamicbar'] ) then return end
	if( !e:IsPlayer() ) then return end
	local maxX, minX, maxY, minY = HERMES:GetCoordinates( e )
	local hpmaxX, hpminX, hpmaxY, hpminY = HERMES:GetCoordinates( e, true )
	
	local health = e:Health() / 2//( e:Health() > 50 && 2 || 4 ) 
	surface.SetDrawColor( BLACK )
	surface.DrawLine( minX - 1, minY, minX - 1, maxY )
	surface.DrawLine( minX - 6, minY, minX - 6, maxY )
	
	surface.DrawLine( minX - 6, minY, minX, minY )
	surface.DrawLine( minX - 6, maxY, minX, maxY )
	
	local pos, using = 2
	if ( e:Health() <= 49 ) then using = hpmaxY else using = hpminY end
	for i = 1, 4 do
		surface.SetDrawColor( BLACK )
		surface.DrawLine( minX - pos, ( minY + 1 ), minX - pos, maxY )
		surface.SetDrawColor( col )
		surface.DrawLine( minX - pos, ( hpminY + 1 ), minX - pos, maxY )
		pos = pos + 1
	end
end

/* --------------------
	:: Skeleton
*/ --------------------
local skeleton = {
	{ S = "ValveBiped.Bip01_Head1", E = "ValveBiped.Bip01_Neck1" },
	{ S = "ValveBiped.Bip01_Neck1", E = "ValveBiped.Bip01_Spine4" },
	{ S = "ValveBiped.Bip01_Spine4", E = "ValveBiped.Bip01_Spine2" },
	{ S = "ValveBiped.Bip01_Spine2", E = "ValveBiped.Bip01_Spine1" },
	{ S = "ValveBiped.Bip01_Spine1", E = "ValveBiped.Bip01_Spine" },
	{ S = "ValveBiped.Bip01_Spine", E = "ValveBiped.Bip01_Pelvis" },
	{ S = "ValveBiped.Bip01_Spine2", E = "ValveBiped.Bip01_L_UpperArm" },
	{ S = "ValveBiped.Bip01_L_UpperArm", E = "ValveBiped.Bip01_L_Forearm" },
	{ S = "ValveBiped.Bip01_L_Forearm", E = "ValveBiped.Bip01_L_Hand" },
	{ S = "ValveBiped.Bip01_Spine2", E = "ValveBiped.Bip01_R_UpperArm" },
	{ S = "ValveBiped.Bip01_R_UpperArm", E = "ValveBiped.Bip01_R_Forearm" },
	{ S = "ValveBiped.Bip01_R_Forearm", E = "ValveBiped.Bip01_R_Hand" },
	{ S = "ValveBiped.Bip01_Pelvis", E = "ValveBiped.Bip01_L_Thigh" },
	{ S = "ValveBiped.Bip01_L_Thigh", E = "ValveBiped.Bip01_L_Calf" },
	{ S = "ValveBiped.Bip01_L_Calf", E = "ValveBiped.Bip01_L_Foot" },
	{ S = "ValveBiped.Bip01_L_Foot", E = "ValveBiped.Bip01_L_Toe0" },
	{ S = "ValveBiped.Bip01_Pelvis", E = "ValveBiped.Bip01_R_Thigh" },
	{ S = "ValveBiped.Bip01_R_Thigh", E = "ValveBiped.Bip01_R_Calf" },
	{ S = "ValveBiped.Bip01_R_Calf", E = "ValveBiped.Bip01_R_Foot" },
	{ S = "ValveBiped.Bip01_R_Foot", E = "ValveBiped.Bip01_R_Toe0" },
}

function HERMES:Skeleton( e )
	if ( !HERMES.item['skeleton'] ) then return end
	if ( !e:IsPlayer() ) then return end
	
	for k, v in pairs( skeleton ) do
		local spos, epos = GetBonePosition( e, LookupBone( e, v.S ) ):ToScreen(), GetBonePosition( e, LookupBone( e, v.E ) ):ToScreen()
		
		surface.SetDrawColor( WHITE )
		surface.DrawLine( spos.x, spos.y, epos.x, epos.y )
	end
end

/* --------------------
	:: HUD
*/ --------------------
local function ShouldDraw( e, use )
	if( use == "text" ) then
		if( HERMES.item['far'] && HERMES.IsDormant( e ) ) then return false end
		return true
	elseif( use == "optical" ) then
		if( HERMES.item['far'] && !HERMES.IsDormant( e ) ) then return false end
		if( HERMES.item['optical'] && !HERMES.IsDormant( e ) ) then return false end
		return true
	end
end

function HERMES:HUD()
	for k, e in ipairs( ents.GetAll() ) do
		local valid, text, color = HERMES:GetTargets( e )
		if( valid == true ) then
			local maxX, minX, maxY, minY = HERMES:GetCoordinates( e )
			
			// HPBar
			HERMES:VerticalBar( e, color )
			
			// Box ESP
			if( ShouldDraw( e, "optical" ) ) then
				surface.SetDrawColor( color )
				
				surface.DrawLine( maxX, maxY, maxX, minY )
				surface.DrawLine( maxX, minY, minX, minY )
				
				surface.DrawLine( minX, minY, minX, maxY )
				surface.DrawLine( minX, maxY, maxX, maxY )
			end
			
			if( ShouldDraw( e, "text" ) ) then
				// Text ESP
				local posX, posY, pos = ( minX + maxX ) / 2, minY, 0
				if( e:IsPlayer() ) then
					posX, posY = maxX + 3, minY + 3
				end
				
				HERMES:Skeleton( e )
				
				for _, i in ipairs( text ) do
					draw.SimpleText(
						i,
						"DefaultSmallDropShadow",
						posX,
						posY + pos,
						color,
						e:IsPlayer() && TEXT_ALIGN_BOTTOM || TEXT_ALIGN_CENTER,
						e:IsPlayer() && TEXT_ALIGN_CENTER || TEXT_ALIGN_BOTTOM
					)
					pos = pos + 10
				end
			end
		end
	end
end

/* --------------------
	:: HUDPaint
*/ --------------------
function HERMES.HUDPaint()
	if( HERMES['_lock'] == true ) then return end
	HERMES._canshoot = true;
	HERMES:HUD();
	HERMES:Warnings();
	HERMES:Crosshair();
end
HERMES:AddHook( "HUDPaint", HERMES.HUDPaint )