/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: material.lua
	Purpose: Creates materials
*************************************************************/
local CreateMaterial = CreateMaterial

/* --------------------
	:: Create Material
*/ --------------------
function HERMES:CreateMaterial( name, shader )
	if( HERMES.mats[name:lower()] ) then return end
	local info = {
		["$basetexture"] = "models/debug/debugwhite",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1,
		["$ignorez"]	 = 1
	}
	
	local mat = CreateMaterial( string.format( "_%s_%s", "hermes", name:lower() ), shader, info )
	HERMES.mats[name:lower()] = mat
end

HERMES:CreateMaterial( "solid", "VertexLitGeneric" )
HERMES:CreateMaterial( "wireframe", "Wireframe" )