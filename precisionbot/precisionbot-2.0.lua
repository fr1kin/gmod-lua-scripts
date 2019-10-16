--[[-----------------------------------------------------------------------------
__________                       .__       .__             ___.           __   
\______   \_______   ____   ____ |__| _____|__| ____   ____\_ |__   _____/  |_ 
 |     ___/\_  __ \_/ __ \_/ ___\|  |/  ___/  |/  _ \ /    \| __ \ /  _ \   __\
 |    |     |  | \/\  ___/\  \___|  |\___ \|  (  <_> )   |  \ \_\ (  <_> )  |  
 |____|     |__|    \___  >\___  >__/____  >__|\____/|___|  /___  /\____/|__|   
                        \/     \/        \/               \/    \/    
---------------------------------------------------------------------------------
Current Version: 2.0

o Changelog:
	> Recreated whole code :D

o Credits:
	> fr1kin		- Creator.
	> Some other people who created scripts/modules.


COPYRIGHT (C) FR1KIN FAGGOT CO.
--]]-----------------------------------------------------------------------------

--[[
	Client Commands, Hooks...
	Desc: Main commands, hooks, and more.
--]]

if ( SERVER ) then return end

require( "scriptenforcer2" )

surface.CreateFont( "Arial", 13, 200, true, false, "ARIAL" )

timer.Simple( 1, function() RunConsoleCommand( "-jump" ) end )

local ply = LocalPlayer()
local max = 2048

local Roleplay = ( { "money_printer", "drug_lab", "drug", "microwave", "food", "gunlab", "spawned_shipment", "spawned_food", "spawned_weapon", "npc_shop" } )

local Roleplaydoller = ( { "models/props/cs_assault/money.mdl" } )

local Warnings = ( { "npc_grenade_frag", "crossbow_bolt", "rpg_missile", "grenade_ar2", "prop_combine_ball", "hunter_flechette", "ent_flashgrenade", "ent_explosivegrenade", "ent_smokegrenade" } )

local AllieNPC = ( { "npc_crow", "npc_monk", "npc_pigeon", "npc_seagull", "npc_alyx", "npc_barney", "npc_citizen", "npc_dog", "npc_kleiner", "npc_magnusson", "npc_eli", "npc_gman", "npc_citizen", "npc_mossman", "npc_citizen", "npc_citizen", "npc_vortigaunt", "npc_breen","npc_soldier", "npc_tank", "npc_tank_turrent" } )

local function CreateGUI( x, y, w, h, col)
    surface.SetDrawColor( col.r, col.g, col.b, col.a )
    surface.DrawRect( x, y, w, h )
end

local function HeadPos(ply)
    if ValidEntity(ply) then
        local hbone = ply:LookupBone("ValveBiped.Bip01_Head1")
        return ply:GetBonePosition(hbone)
    else return end
end

local function Visible(ply)
    local trace = {start = LocalPlayer():GetShootPos(),endpos = HeadPos(ply),filter = {LocalPlayer(), ply}}
    local tr = util.TraceLine(trace)
    if tr.Fraction == 1 then
        return true
    else
        return false
    end    
end

local function GetAdmin( e )
		if e:IsAdmin() and not e:IsSuperAdmin() then return ( " | Admin" )
		elseif e:IsSuperAdmin() then return ( " | Super Admin" )
		elseif not e:IsAdmin() and not e:IsSuperAdmin() then return ( "" ) 
	end
end

local function BadTargets(e)
	if !e:IsValid() then return false end
	if team.GetName(e:Team()) == "spectator" then return false end
	if team.GetName(e:Team()) == "Spectator" then return false end
	if team.GetName(e:Team()) == "spectators" then return false end
	if team.GetName(e:Team()) == "Spectator" then return false end
	if team.GetName(e:Team()) == "Spectating" then return false end
	if team.GetName(e:Team()) == "Dead Prisoners" then return false end
	if team.GetName(e:Team()) == "Dead Guards" then return false end
	return true
end

local function GoodTargets(e)
	if ( e == LocalPlayer() ) then return false end
	if ( !e:IsValid() ) || ( !e:IsPlayer() ) && ( !e:IsWeapon() ) && ( !e:IsNPC() ) && !table.HasValue( Roleplay, e:GetClass() ) && !table.HasValue( Roleplaydoller, e:GetModel() ) && !table.HasValue( Warnings, e:GetClass() ) then return false end
	if ( e:IsPlayer() && !e:Alive() ) || ( e:IsPlayer() && !BadTargets(e) ) then return false end
	if ( e:IsWeapon() && e:GetMoveType() == 0 ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == 0 ) then return false end
	//if ( e:GetPos() - LocalPlayer():GetPos() ):Length() >= 8000 && !Visible() then return false end
	return true
end

local function GoodChamTargets(e)
	if ( e == LocalPlayer() ) then return false end
	if ( !e:IsValid() ) || ( !e:IsPlayer() ) && ( !e:IsWeapon() ) && ( !e:IsNPC() ) then return false end
	if ( e:IsPlayer() && !e:Alive() ) || ( e:IsPlayer() && !BadTargets(e) ) then return false end
	if ( e:IsWeapon() && e:GetMoveType() ~= 0 ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == 0 ) then return false end
	return true
end


local function CreatePosition(e)

	local pos, max = e:OBBMaxs()
	
	if ( e:IsPlayer() ) then
		pos = e:GetPos():ToScreen()
		
		
	elseif ( e:IsNPC() || e:IsWeapon() ) then
		pos = e:GetPos():ToScreen()
		
	else
		pos = e:GetPos():ToScreen()
		
	end
	
	
	return pos
end
	
local function EntityColors(e)
	
	local col, boxcol, a, class = "", Color( 0, 255, 0, 255 ), 255, e:GetClass()
	
	if ( e:IsPlayer() ) then
		local tc = team.GetColor( e:Team() )
		col = Color( tc.r, tc.g, tc.b, a )
	
	elseif ( e:IsNPC() && !table.HasValue( AllieNPC, class ) ) then
		col = Color( 255, 0, 0, a )
		
	elseif ( e:IsWeapon() ) then
		col = Color( 255, 255, 255, a )
		
	elseif ( e:IsNPC() && table.HasValue( AllieNPC, class ) ) then
		col = Color( 0, 255, 0, a )
		
	else
		col = Color( 255, 127, 39, a )
		
	end
	
	return col, boxcol
end

local function RemoveUnnecessaryText(e)
	
	local replace = e:GetClass()
	local replacem = e:GetModel()
	
	replace = string.Replace( replace, "npc_", "" )
	replace = string.Replace( replace, "weapon_", "" )
	replace = string.Replace( replace, "_", " " )
	replace = string.Replace( replace, "spawned_", "" )
	replace = string.Replace( replace, "shipment_", "Shipment " )
	replace = string.Replace( replace, "dropped_", "" )
	replace = string.Replace( replace, "dropped_", "" )
	replace = string.Replace( replace, "smg_", "SMG " )
	replace = string.Replace( replace, "money_", "Money " )
	replace = string.Replace( replace, "prop_vehicle_", "" )
	replacem = string.Replace( replacem, "models/props/cs_assault/money.mdl", "Money" )
	
	local class = string.upper( replace )
	local model = string.upper( replacem )
	
	return class, model
end

local function PlayerInformation(e)

	local ttype, func, font, posx, posy, color, xalign, yalign
	local col, pos, class, model = EntityColors(e), CreatePosition(e), RemoveUnnecessaryText(e)
	local NAME, HEALTH, WEAPON, DISTANCE = 1, 1, 1, 1
	
		if ( e:IsPlayer() ) then
			ttype = draw.SimpleTextOutlined; func = e:Nick() .. GetAdmin(e); font = "ARIAL"; posx = pos.x; posy = pos.y; color = col; xalign = TEXT_ALIGN_CENTER; yalign = TEXT_ALIGN_BOTTOM;
		
		elseif ( e:IsNPC() || e:IsWeapon() ) then
			ttype = draw.SimpleText; func = class; font = "ARIAL"; posx = pos.x; posy = pos.y + 15; color = col; xalign = TEXT_ALIGN_CENTER; yalign = TEXT_ALIGN_CENTER;
			
		elseif ( table.HasValue( Roleplay, e:GetClass() ) ) then
			ttype = draw.SimpleText; func = class; font = "ARIAL"; posx = pos.x; posy = pos.y + 15; color = col; xalign = TEXT_ALIGN_CENTER; yalign = TEXT_ALIGN_CENTER;

		elseif ( table.HasValue( Roleplaydoller, e:GetModel() ) ) then
			ttype = draw.SimpleText; func = model; font = "ARIAL"; posx = pos.x; posy = pos.y + 15; color = col; xalign = TEXT_ALIGN_CENTER; yalign = TEXT_ALIGN_CENTER;
			
		elseif ( table.HasValue( Warnings, e:GetModel() ) ) then
			ttype = draw.SimpleText; func = "W: " .. class; font = "ARIAL"; posx = pos.x; posy = pos.y + 15; color = col; xalign = TEXT_ALIGN_CENTER; yalign = TEXT_ALIGN_CENTER;
			
		elseif ( string.find( e:GetClass(), "prop_vehicle_" ) ) then
			ttype = draw.SimpleText; func = class; font = "ARIAL"; posx = pos.x; posy = pos.y + 15; color = col; xalign = TEXT_ALIGN_CENTER; yalign = TEXT_ALIGN_CENTER;
			
		else
			ttype = draw.SimpleText; func = class; font = "ARIAL"; posx = pos.x; posy = pos.y + 15; color = col; xalign = TEXT_ALIGN_CENTER; yalign = TEXT_ALIGN_CENTER;
			
		end
			
		
	return ttype, func, font, posx, posy, color, xalign, yalign
	
end

local function DrawOptical(e)
	
	local col, boxcol = EntityColors(e)
	local OPTICAL, pos = 3, CreatePosition(e)
	
		if OPTICAL == 1 then
		
			surface.SetDrawColor( boxcol )
			
			surface.DrawLine(pos.x, pos.y - 5, pos.x, pos.y + 5)
			surface.DrawLine(pos.x - 5, pos.y, pos.x + 5, pos.y)
		
		elseif OPTICAL == 2  then
		
			draw.RoundedBox( 0, pos.x, pos.y, 5, 5, boxcol )
			
		elseif OPTICAL == 3 then
			
			local center = e:LocalToWorld(e:OBBCenter())
			local min,max = e:WorldSpaceAABB()
			local dim = max-min

			local front = e:GetForward()*(dim.y/2)
			local right = e:GetRight()*(dim.x/2)
			local top = e:GetUp()*(dim.z/2)
			local back = (e:GetForward()*-1)*(dim.y/2)
			local left = (e:GetRight()*-1)*(dim.x/2)
			local bottom = (e:GetUp()*-1)*(dim.z/2)
			local FRT = center+front+right+top
			local BLB = center+back+left+bottom
			local FLT = center+front+left+top
			local BRT = center+back+right+top
			local BLT = center+back+left+top
			local FRB = center+front+right+bottom
			local FLB = center+front+left+bottom
			local BRB = center+back+right+bottom

			FRT = FRT:ToScreen()
			BLB = BLB:ToScreen()
			FLT = FLT:ToScreen()
			BRT = BRT:ToScreen()
			BLT = BLT:ToScreen()
			FRB = FRB:ToScreen()
			FLB = FLB:ToScreen()
			BRB = BRB:ToScreen()

			local xmax = math.max(FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x)
			local xmin = math.min(FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x)
			local ymax = math.max(FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y)
			local ymin = math.min(FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y)

			surface.SetDrawColor( boxcol.r, boxcol.g, boxcol.b, 150 )

			surface.DrawLine(xmax,ymax,xmax,ymin)
			surface.DrawLine(xmax,ymin,xmin,ymin)
			surface.DrawLine(xmin,ymin,xmin,ymax)
			surface.DrawLine(xmin,ymax,xmax,ymax)
			
		end
	// return
end

local function DrawHealthBar(e)

if e:IsPlayer() then

	local col, normalhp, pos = EntityColors(e), 100, CreatePosition(e)

		if( e:Health() > normalhp ) then
			normalhp = e:Health()
		end
        
		local dmg, nor = normalhp / 4, e:Health() / 4

		pos.x = pos.x - ( dmg / 2 )
		pos.y = pos.y + 15
          
		CreateGUI( pos.x - 1, pos.y - 1, dmg + 2, 4 + 2, Color( 0, 0, 0, 255 ) )
		CreateGUI( pos.x, pos.y, nor, 4, col )
	end
end

function CreateNewMaterial()

   local BaseInfo = {
      ["$basetexture"] = "color/white",
      ["$model"]       = 1,
      ["$translucent"] = 1,
      ["$alpha"]       = 1,
      ["$nocull"]      = 1,
      ["$ignorez"]     = 1,
   }

   local mat = CreateMaterial( "material", "Wireframe", BaseInfo )

   return mat

end

--[[
	Extra Sensory Perception
	Desc: Draws infomation about the players name, health, weapon...
--]]

local function ESP()

	for k, e in pairs( ents.GetAll() ) do
	
		local ply = LocalPlayer()
		
		if GoodTargets(e) && e:IsValid() then
		
			local col, pos = EntityColors(e), CreatePosition(e)
			
			local ttype, func, font, posx, posy, color, xalign, yalign = PlayerInformation(e)
		
			ttype(
			func,
			font,
			posx,
			posy,
			color,
			xalign,
			yalign,
			1.0,
			Color( 0, 0, 0, 255 )
			)
			
			DrawOptical(e)
			DrawHealthBar(e)

		end
	end
end

--[[
	Visuals
	Desc: Draws lights, crosshair and more.
--]]

local function Visuals()

	local CROSSHAIR, x, y, g = 1, ScrW() / 2, ScrH() / 2, 5; local l = g + 15

	if CROSSHAIR >= 1 then
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawLine( x - l, y, x - g, y ); surface.DrawLine( x + l, y, x + g, y )
		surface.DrawLine( x, y - l, x, y - g ); surface.DrawLine( x, y + l, x, y + g )
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawLine(x, y - 5, x, y + 5)
		surface.DrawLine(x - 5, y, x + 5, y)
	end
end

--[[
	Chams
	Desc: Draws model(s) though the wall.
--]]

local function Chams()

	for k, e in pairs( ents.GetAll() ) do
	
		local ply = LocalPlayer()
		
		if GoodChamTargets(e) && e:IsValid() then
			
			if ( e:GetPos() - ply:GetPos() ):Length() <= max then
			
			cam.Start3D( EyePos(), EyeAngles() )
			
			local mat, col = CreateNewMaterial(), EntityColors(e)
			
			render.SuppressEngineLighting( true )
			
			render.SetColorModulation( 1/255 * col.r, 1/255 * col.g, 1/255 * col.b )
			
			SetMaterialOverride( mat )
			
			e:DrawModel()
			
			render.SuppressEngineLighting( false )
			
			render.SetColorModulation( 1, 1, 1 )
			
			SetMaterialOverride( 0 )
			
			e:DrawModel()
			
			end
		end
	end
end

--[[
	Other
	Desc: Bunnyhop, autopistol...
--]]

/*local done
function BHOP_ON()
	if input.IsKeyDown( KEY_SPACE ) then
		local ply = LocalPlayer()
		if !ply:IsOnGround() then
		RunConsoleCommand( "-jump" ); done = 0
		else
		RunConsoleCommand( "+jump" ); done = 1
	end
	if ply:IsOnGround() then
		if done == 0 then
			RunConsoleCommand( "-jump" ); done = 0
		end
	end	
end
end*/

--[[
	Adding Hooks
	Desc: Allows the functions to be drawn.
--]]
//hook.Add( "HUDPaint", "ESP", ESP )
hook.Add( "HUDPaint", "VISUALS", Visuals )
hook.Add( "RenderScreenspaceEffects", "CHAMS", Chams )
hook.Add( "Think", "BHOP", BHOP_ON )