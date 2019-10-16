/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: chams.lua
	Purpose: Draw player model through wall
*************************************************************/

HERMES:AddTabItem( "ESP", "Wallhack" )

HERMES:AddSetting( "esp_chams", true, "Chams", "Wallhack" )
HERMES:AddSetting( "esp_xqz", true, "XQZ", "Wallhack" )

local MATERIAL = {}
/* --------------------
	:: Chams
*/ --------------------
function HERMES:Chams()
	local ply, c = LocalPlayer(), ( 1 / 255 )
	cam.Start3D( EyePos(), EyeAngles() )
	for k, e in ipairs( player.GetAll() ) do
		if( HERMES:FilterTargets( e, "esp" ) && !( HERMES.item["xqz"] ) && !HERMES.IsDormant( e ) ) then
			local col = HERMES:TargetColors( e )
			render.SuppressEngineLighting( true )
			render.SetColorModulation( ( col.r * c ), ( col.g * c ), ( col.b * c ) )
			SetMaterialOverride( HERMES.mats['solid'] )
			e:DrawModel()
			render.SuppressEngineLighting( false )
			render.SetColorModulation( 1, 1, 1 )
			SetMaterialOverride()
			e:DrawModel()
		end
	end
	cam.End3D()
end

function HERMES:XQZ()
	local ply, c = LocalPlayer(), ( 1 / 255 )
	cam.Start3D( EyePos(), EyeAngles() )
	for k, e in ipairs( player.GetAll() ) do
		if( HERMES:FilterTargets( e, "esp" ) && HERMES.item["xqz"] && !HERMES.IsDormant( e ) ) then
			cam.IgnoreZ( true )
			render.SuppressEngineLighting( true )
			e:DrawModel()
			cam.IgnoreZ( false )
			render.SuppressEngineLighting( false )
		end
	end
	cam.End3D()
end

/* --------------------
	:: Chams
*/ --------------------
function HERMES.RenderScreenspaceEffects()
	if( HERMES.item["chams"] ) then
		HERMES:Chams();
	end
	
	if( HERMES.item["xqz"] ) then
		HERMES:XQZ();
	end
end
HERMES:AddHook( "RenderScreenspaceEffects", HERMES.RenderScreenspaceEffects )