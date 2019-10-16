/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: chams.lua
	Purpose: Draw player model through wall
*************************************************************/

HERMES:AddSetting( "esp_chams", true, "Chams", "Wallhack" )
HERMES:AddSetting( "esp_xqz", true, "XQZ", "Wallhack" )

local MATERIAL = {}
local IN_WALL = false

/* --------------------
	:: Chams
*/ --------------------
function HERMES:Chams( )
	local ply, c = LocalPlayer(), ( 1 / 255 )
	IN_WALL = true
	
	MATERIAL = {}
	for k, e in ipairs( player.GetAll() ) do
		if( HERMES:FilterTargets( e, "esp" ) && !( HERMES.item["xqz"] ) && !HERMES.IsDormant( e ) ) then
			if( MATERIAL[e] ) then
				e:SetMaterial( "" )
			end
			MATERIAL[e] = k
			local col = HERMES:TargetColors( e )
			cam.Start3D( EyePos(), EyeAngles() )
				render.SuppressEngineLighting( true )
				render.SetColorModulation( ( col.r * c ), ( col.g * c ), ( col.b * c ) )
				SetMaterialOverride( HERMES.mats['solid'] )
				e:DrawModel()
				render.SuppressEngineLighting( false )
				//render.SetColorModulation( ( 255 * c ), ( 255 * c ), ( 255 * c ) )
				render.SetColorModulation( 1, 1, 1 )
				SetMaterialOverride()
				//e:SetMaterial( "models/debug/debugwhite" )
				e:DrawModel()
			cam.End3D()
		end
	end
end

function HERMES:XQZ()
	local ply, c = LocalPlayer(), ( 1 / 255 )
	for k, e in ipairs( player.GetAll() ) do
		if( HERMES:FilterTargets( e, "esp" ) && HERMES.item["xqz"] && !HERMES.IsDormant( e ) ) then
			cam.Start3D( EyePos(), EyeAngles() )
				cam.IgnoreZ( true )
				render.SuppressEngineLighting( true )
				e:DrawModel()
				cam.IgnoreZ( false )
				render.SuppressEngineLighting( false )
			cam.End3D()
		end
	end
end

/* --------------------
	:: Chams
*/ --------------------
function HERMES.RenderScreenspaceEffects()
	if( HERMES['_lock'] == true ) then return end
	if( HERMES.item["chams"] ) then
		HERMES:Chams();
	else
		if( IN_WALL ) then
			for k, e in ipairs( player.GetAll() ) do
				e:SetMaterial( "" )
			end
			IN_WALL = false
		end
	end
	
	if( HERMES.item["xqz"] ) then
		HERMES:XQZ();
	end
end
HERMES:AddHook( "RenderScreenspaceEffects", HERMES.RenderScreenspaceEffects )