if ( SERVER ) then return end

--[[-----------------------------------------------------------------------------
__________                       .__       .__             ___.           __   
\______   \_______   ____   ____ |__| _____|__| ____   ____\_ |__   _____/  |_ 
 |     ___/\_  __ \_/ __ \_/ ___\|  |/  ___/  |/  _ \ /    \| __ \ /  _ \   __\
 |    |     |  | \/\  ___/\  \___|  |\___ \|  (  <_> )   |  \ \_\ (  <_> )  |  
 |____|     |__|    \___  >\___  >__/____  >__|\____/|___|  /___  /\____/|__|   
                        \/     \/        \/               \/    \/    
---------------------------------------------------------------------------------
Current Version: 2.1

o Changelog:
	> Added New Anti-Cheat Protection
	> Added Fade Effect
	> Detects Traitors [ REMOVED untill I can get it to fully work ]

o Credits:
	> fr1kin		- Creator.
	> Some other people who created scripts/modules.
	> SUPER special thanks to Fapadar.

COPYRIGHT © FR1KIN FAGGOT CO.

OLD MAN!!!: http://steamcommunity.com/id/elderrambo/
OLD MANS IP: 174.27.187.122:27005
OLD MANS STEAM ID SO I CAN STALK HIM: STEAM_0:0:18474975 58:17 121 0 active


# userid name uniqueid connected ping loss state
# 2085 "fr1kin" STEAM_0:1:24332877 32:01 63 0 active
# 2081 "/b/lackup" STEAM_0:1:29638659 55:17 88 0 active
# 2087 "???ev??ed??" STEAM_0:0:25706804 10:50 101 0 active
# 2083 "Beaker" STEAM_0:0:26578586 47:21 73 0 active
# 2072 "Old Man Cricky Crocets" STEAM_0:0:18474975  1:17:17 128 0 active -- its him
# 2089 "Timmy Turners Dad" STEAM_0:1:14844372 03:13 87 0 active
# 2011 "Hidden Dimsum | Drygonfire ??" STEAM_0:1:2116819  3:51:00 109 0 active
# 2064 "cashews" STEAM_0:0:12864702  1:59:38 122 0 active
# 2065 "superkurl" STEAM_0:0:2496288  1:59:19 115 0 active
# 2057 "[NPC]Waffles" STEAM_0:1:28044710  2:25:40 109 0 active
# 2084 "Roy Campbell" STEAM_0:1:11601857 35:47 66 0 active

--]]-----------------------------------------------------------------------------


--<<---------------------------------->>--
--<< WARNING!!!: EXTREMELY MESSY CODE >>--
--<<---------------------------------->>--

--[[
	Client Commands, Hooks...
	Desc: Main commands, hooks, and more.
--]]

local PB = {}
PB.ConCommands	= {}
PB.Commands		= {}
PB.Hooks		= {}

local ply, def_col, ver = LocalPlayer(), Color( 255, 255, 255, 255 ), " v2.1 "
local msg = ( "|--------------------|" )

local SetAngles = Vector( 0, 0, 0 )
local Aimangle = Vector( 0, 0, 0 )
local angles = Angle(0,0,0)
local aiming = false
local text

require("deco")
MsgN( "\nPrecisionbot" .. ver .. "loaded!\n" )

surface.CreateFont( "Arial", 25, 400, true, false, "PB_FONT" )

local Message = {
		( "\n\n\n\n Precisionbot" .. ver .. "Loading...\n" ),
		( "--------------------------------------------\n" ),
	}
	
local Classes = {

		( "money_printer" ),
		( "drug_lab" ),
		( "drug" ),
		( "microwave" ),
		( "food" ),
		( "gunlab" ),
		( "spawned_shipment" ),
		( "spawned_food" ),
		( "spawned_weapon" ),
		( "npc_shop" ),
		( "money_tree" )
		
	}
	
local Models = {

		( "models/props/cs_assault/money.mdl" ),
		
	}

local Warnings = { 

		( "npc_grenade_frag" ),
		( "crossbow_bolt" ),
		( "roleplayg_missile" ),
		( "grenade_ar2" ),
		( "prop_combine_ball" ),
		( "hunter_flechette" ),
		( "ent_flashgrenade" ),
		( "ent_explosivegrenade" ),
		( "ent_smokegrenade" )
		
	}
	
local AllieNPC = { 

		( "npc_crow" ),
		( "npc_monk" ),
		( "npc_pigeon" ),
		( "npc_seagull" ),
		( "npc_alyx" ),
		( "npc_barney" ),
		( "npc_citizen" ),
		( "npc_dog" ),
		( "npc_kleiner" ),
		( "npc_magnusson" ),
		( "npc_eli" ),
		( "npc_gman" ),
		( "npc_citizen" ),
		( "npc_mossman" ),
		( "npc_citizen" ),
		( "npc_citizen" ),
		( "npc_vortigaunt" ),
		( "npc_breen" ),
		( "npc_soldier" ),
		( "npc_tank" ),
		( "npc_tank_turrent" )
	
	}
	
local Traitors = {

		( "weapon_ttt_c4" ),
		( "weapon_ttt_sipistol" ),
		( "weapon_ttt_flaregun" ),
		( "weapon_ttt_phammer" ),
		( "weapon_ttt_knife" )
		
}

local Bones = {

		Head	= "ValveBiped.Bip01_Head1",
		Spine	= "ValveBiped.Bip01_Spine4",
		Spine2	= "ValveBiped.Bip01_Spine2",
		Pelvis	= "ValveBiped.Bip01_Pelvis",
	}

function PB:AddConVar( convar, val, save, data )
	table.insert( PB.Commands, convar )
	return CreateClientConVar( convar, val, save, data ), MsgN( "\n[ADDED] Client Command: " .. convar )
end

function PB:AddConCommand( name, func )
	table.insert( PB.ConCommands, name )
	return concommand.Add( name, func ), MsgN( "\n[ADDED] ConCommand: " .. name )
end

function PB:AddHook( typ, func )

	local ran = ""
	
	for i = 1, 20 do
		ran = ran .. string.char( math.random( 65 , 117 ) )
	end
	
	table.insert( PB.Hooks, ran )
	
	return hook.Add( typ, ran, func ), MsgN( "\n[ADDED] Hook: " .. ran ) // .. "/n[HOOK " .. ran .. "] Function: " .. func
	
end

-- List of all the console commands:
local AIM_Enabled			= PB:AddConVar( "pb_aim_enabled", "1", true, false )
local AIM_FF				= PB:AddConVar( "pb_aim_friendlyfire", "1", true, false )
local AIM_Autoshoot			= PB:AddConVar( "pb_aim_shoot", "0", true, false )
local AIM_FOV				= PB:AddConVar( "pb_aim_fov", "0", true, false )
local AIM_Bone				= PB:AddConVar( "pb_aim_bone", "Head", true, false )
local AIM_Mode				= PB:AddConVar( "pb_aim_mode", "Players & NPC's", true, false )
local AIM_Vec				= PB:AddConVar( "pb_aim_allowvector", "0", true, false )
local AIM_Vecx				= PB:AddConVar( "pb_aim_vectorx", "0", true, false )
local AIM_Vecy				= PB:AddConVar( "pb_aim_vectory", "0", true, false )
local AIM_Vecz				= PB:AddConVar( "pb_aim_vectorz", "0", true, false )
local AIM_Norecoil			= PB:AddConVar( "pb_aim_norecoil", "1", true, false )
local AIM_NoSpread			= PB:AddConVar( "pb_aim_nospread", "1", true, false )

local ESP_Enabled			= PB:AddConVar( "pb_esp_enabled", "1", true, false )
local ESP_Name				= PB:AddConVar( "pb_esp_name", "1", true, false )
local ESP_Health			= PB:AddConVar( "pb_esp_health", "1", true, false )
local ESP_Box				= PB:AddConVar( "pb_esp_box", "1", true, false )
local ESP_Barrel			= PB:AddConVar( "pb_esp_barrel", "1", true, false )
local ESP_NPC				= PB:AddConVar( "pb_esp_npc", "1", true, false )
local ESP_Entity			= PB:AddConVar( "pb_esp_entity", "0", true, false )
local ESP_Dead				= PB:AddConVar( "pb_esp_showdead", "0", true, false )
local ESP_Outlined			= PB:AddConVar( "pb_esp_outline", "0", true, false )
local ESP_Visibility		= PB:AddConVar( "pb_esp_visibility", "1", true, false )
local ESP_Teamcolor			= PB:AddConVar( "pb_esp_teamcolor", "1", true, false )

local VIS_Lights			= PB:AddConVar( "pb_vis_lights", "1", true, false )
local VIS_LightsRange		= PB:AddConVar( "pb_vis_lights_range", "30", true, false )
local VIS_Chams				= PB:AddConVar( "pb_vis_chams", "1", true, false )
local VIS_ChamsMaterial		= PB:AddConVar( "pb_vis_chams_material", "XQZ", true, false )
local VIS_ChamsPlayer		= PB:AddConVar( "pb_vis_chams_player", "1", true, false )
local VIS_ChamsNPC			= PB:AddConVar( "pb_vis_chams_npc", "0", true, false )
local VIS_ChamsWeapon		= PB:AddConVar( "pb_vis_chams_weapon", "1", true, false )
local VIS_ChamsRagdoll		= PB:AddConVar( "pb_vis_chams_ragdoll", "0", true, false )
local VIS_ChamsFullbright	= PB:AddConVar( "pb_vis_chams_fullbright", "0", true, false )
local VIS_CrossBasic		= PB:AddConVar( "pb_vis_crossbasic", "1", true, false )
local VIS_CrossNormal		= PB:AddConVar( "pb_vis_crossnormal", "1", true, false )
local VIS_CrossAdvanced		= PB:AddConVar( "pb_vis_crossadvanced", "1", true, false )
local VIS_CrossAnimation	= PB:AddConVar( "pb_vis_crossanimation", "0", true, false )
local VIS_DrawFOV			= PB:AddConVar( "pb_vis_drawfov", "0", true, false )

local MIS_BHop				= PB:AddConVar( "pb_misc_bhop", "1", true, false )
local MIS_360View			= PB:AddConVar( "pb_misc_360view", "0", true, false )

local COL_ESP_Visibler		= PB:AddConVar( "pb_col_esp_barrelr", "0", true, false )
local COL_ESP_Visibleg		= PB:AddConVar( "pb_col_esp_barrelg", "255", true, false )
local COL_ESP_Visibleb		= PB:AddConVar( "pb_col_esp_barrelg", "0", true, false )
local COL_ESP_nVisibler		= PB:AddConVar( "pb_col_esp_barrelr", "0", true, false )
local COL_ESP_nVisibleg		= PB:AddConVar( "pb_col_esp_barrelg", "0", true, false )
local COL_ESP_nVisibleb		= PB:AddConVar( "pb_col_esp_barrelg", "255", true, false )

function TestTeams()
	for k, e in pairs( player.GetAll() ) do
		if e:IsPlayer() then
			print( "\n" .. e:Nick() .. " = " .. team.GetName(e:Team()) .. "\n" )
		end
	end
end
PB:AddConCommand( "pb_team_test", TestTeams )

function GetGameMode( val )
	if ( string.find( GAMEMODE.Name, val ) ) then
		return true
	end
	return false
end

function CreateBonePosition(e)
	local Bone, b = AIM_Bone:GetInt(), ""
	
	if AIM_Bone:GetString() == "Head" then
		b = e:GetBonePosition(e:LookupBone( Bones.Head ) )
		
	elseif AIM_Bone:GetString() == "Spine" then
		b = e:GetBonePosition(e:LookupBone( Bones.Spine) )
		
	elseif AIM_Bone:GetString() == "Middle Body" then
		b = e:GetBonePosition(e:LookupBone( Bones.Spine2 ) )

	elseif AIM_Bone:GetString() == "Pelvis" then
		b = e:GetBonePosition(e:LookupBone( Bones.Pelvis ) )

	end
	
	//if ( !b && AIM_Bone:GetBool() ) then b = e:LocalToWorld(e:OBBCenter()) end
	
	//if e:IsNPC() && e:GetClass() == "npc_zombie" then b = "ValveBiped.HC_Body_Bone" end
	
	
	return b
end

function BadTargets(e) // Use string.find? lol
	if !e:IsValid() then return false end
	if team.GetName(e:Team()) == "spectator" then return false end
	if team.GetName(e:Team()) == "Spectator" then return false end
	if team.GetName(e:Team()) == "spectators" then return false end
	if team.GetName(e:Team()) == "Spectator" then return false end
	if team.GetName(e:Team()) == "Spectating" then return false end
	if team.GetName(e:Team()) == "Dead Prisoners" then return false end
	if team.GetName(e:Team()) == "Dead Guards" then return false end
	if team.GetName(e:Team()) == "Spectators" then return false end
	return true
end

function GoodTargets(e)
		
		if ( e == LocalPlayer() ) then return false end
		if ( !e:IsValid() ) || ( !e:IsPlayer() ) && ( !e:IsWeapon() ) && ( !e:IsNPC() ) && !table.HasValue( Classes, e:GetClass() ) && !table.HasValue( Models, e:GetModel() ) && !table.HasValue( Warnings, e:GetClass() ) then return false end
		if ( e:IsPlayer() && ESP_Dead:GetBool() == false && !e:Alive() ) then return end
		if ( e:IsPlayer() && !BadTargets(e) ) then return false end
		if ( e:IsWeapon() && e:GetMoveType() == 0 ) then return false end
		if ( e:IsNPC() && e:GetMoveType() == 0 ) then return false end
		if ( e:IsNPC() && ESP_NPC:GetBool() == false ) then return false end
		if ( e:IsWeapon() && ESP_Entity:GetBool() == false ) then return false end
		if ( e:IsWeapon() && table.HasValue( Classes, e:GetClass() ) && table.HasValue( Models, e:GetModel() ) && table.HasValue( Warnings, e:GetClass() ) && ESP_Entity:GetBool() == false ) then return false end
		if ( e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	return true
end

function GoodTargetsChams(e)
		
		if ( e == LocalPlayer() ) then return false end
		if ( !e:IsValid() ) || ( !e:IsPlayer() ) && ( !e:IsWeapon() ) && ( !e:IsNPC() ) && e:GetClass() != "prop_ragdoll" && e:GetClass() != "class C_ClientRagdoll" then return false end
		if ( e:IsPlayer() && !e:Alive() ) || ( e:IsPlayer() && !BadTargets(e) ) then return false end
		if ( e:IsPlayer() && !BadTargets(e) ) then return false end
		if ( e:IsWeapon() && e:GetMoveType() ~= 0 ) then return false end
		if ( e:IsNPC() && e:GetMoveType() == 0 ) then return false end
		if ( e:IsPlayer() && VIS_ChamsPlayer:GetBool() == false ) then return false end
		if ( e:IsNPC() && VIS_ChamsNPC:GetBool() == false ) then return false end
		if ( e:IsWeapon() && VIS_ChamsWeapon:GetBool() == false ) then return false end
		if ( e:GetClass() == "prop_ragdoll" || e:GetClass() == "class C_ClientRagdoll" && VIS_ChamsRagdoll:GetBool() == false ) then return false end
		if ( e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	return true
end

function Visible(e)
    local trace = { start = LocalPlayer():GetShootPos(), endpos = CreateBonePosition(e), filter = { LocalPlayer(), e } }
    local tr = util.TraceLine(trace)
    if tr.Fraction == 1 then
        return true
    else
        return false
    end    
end

function CreateGUI( x, y, w, h, col)
    surface.SetDrawColor( col.r, col.g, col.b, col.a )
    surface.DrawRect( x, y, w, h )
end

function FindTraitors(e) // Doesn't work?
	for k, e in pairs( e:GetWeapons() || {} ) do
		for i = 1, #Traitors do
			if e:GetClass() == Traitors[i] then
				col = Color( 255, 0, 0, 255 )
			else
				local tc = team.GetColor( e:Team() )
				col = Color( tc.r, tc.g, tc.b, a )
				return col
			end
		end
	end
end

function TargetInformation(e)
	
	local col, boxcol, text, alpha, class, model, outline, pos, def_pos, def_text = "", "", "", 255, e:GetClass(), e:GetModel(), false, "", e:GetPos():ToScreen(), e:GetClass()
	
		if ( e:IsPlayer() && e:IsValid() ) then
		
			local tc = team.GetColor( e:Team() )
		
			pos = e:GetPos() + Vector( 0, 0, -10 ); pos = pos:ToScreen()
		
			col = Color( tc.r, tc.g, tc.b, a )
		
			if ESP_Name:GetBool() then
				text = e:Nick()
			else
				text = ""
			end
			
			if ESP_Outlined:GetBool() then
				outlined = true
			else
				outlined = false
			end
		
		elseif ( e:IsNPC() && e:IsValid() ) then
		
			local npc_color, npc_text
			
			npc_text = class
			
			npc_text = string.Replace( npc_text, "npc_", "" )
			npc_text = string.Replace( npc_text, "_", "" )
			
			npc_text = string.upper( npc_text )
			
				
			if ( e:IsNPC() && !table.HasValue( AllieNPC, class ) && e:IsValid() ) then npc_color = Color( 255, 0, 0, a ) end
			if ( e:IsNPC() && table.HasValue( AllieNPC, class ) && e:IsValid() ) then npc_color = Color( 0, 255, 0, a ) end
				
		
			pos = e:GetPos() + Vector( 0, 0, -5 ); pos = pos:ToScreen()
			
			col = npc_color
			
			if ESP_NPC:GetBool() then
				text = npc_text
			else
				text = ""
			end
			
			outlined = false
			
		
		elseif ( e:IsWeapon() && e:IsValid() ) then
		
			local wep_color, wep_text
			
			wep_text = class
			
			wep_text = string.Replace( wep_text, "weapon_", "" )
			wep_text = string.Replace( wep_text, "ttt_", "" )
			wep_text = string.Replace( wep_text, "zm_", "" )
			wep_text = string.Replace( wep_text, "_", "" )
			
			wep_color = Color( 255, 127, 39, a )
			
			wep_text = string.upper( wep_text )
			
			pos = e:GetPos() + Vector( 0, 0, -10 ); pos = pos:ToScreen()
			
			col = wep_color
			
			if ESP_Entity:GetBool() then
				text = wep_text
			else
				text = ""
			end
			
			outlined = false
			
		
		elseif ( table.HasValue( Classes, class ) ) then
		
			local ent_color, ent_text
		
			ent_text = class
		
			ent_text = string.Replace( ent_text, "spawned_", "" )
			ent_text = string.Replace( ent_text, "shipment_", "Shipment " )
			ent_text = string.Replace( ent_text, "dropped_", "" )
			ent_text = string.Replace( ent_text, "dropped_", "" )
			ent_text = string.Replace( ent_text, "smg_", "SMG " )
			ent_text = string.Replace( ent_text, "money_", "Money " )
			
			ent_text = string.upper( ent_text )
		
			col = Color( 0, 0, 255, a )
		
			pos = e:GetPos() + Vector( 0, 0, -5 ); pos = pos:ToScreen()
			
			if ESP_Entity:GetBool() then
				text = ent_text
			else
				text = ""
			end
		
			outlined = false
			
		
		elseif ( table.HasValue( Models, model )  ) then
	
			if GetGameMode( "Trouble in Terrorist Town" ) then
				table.remove( Models, "models/props/cs_assault/money.mdl" )
			end
			
			local model_color, model_text
		
			model_text = model
			
			model_text = string.Replace( model_text, "models/props/cs_assault/money.mdl", "Money" )
			
			model_text = string.upper( model_text )
		
			col = Color( 64, 0, 128, a )
		
			pos = e:GetPos() + Vector( 0, 0, -5 ); pos = pos:ToScreen()
		
			if ESP_Entity:GetBool() then
				text = model_text
			else
				text = ""
			end
		
			outlined = false
		
		else
			
			col, pos, text, outlined = "", "", "", false
		
	end
	
	if ESP_Teamcolor:GetBool() then
	
		if e:IsPlayer() then boxcol = team.GetColor( e:Team() ) else boxcol = col end
		
	else
		if ESP_Visibility:GetBool() then
			if GoodTargets(e) && Visible(e) then
		
				boxcol = Color( 0, 255, 0, a )
		
			elseif GoodTargets(e) && !Visible(e) then
		
				boxcol = Color( 0, 0, 255, a )
		
			end
		else
	
			boxcol = Color( 0, 255, 0, a )
		
		end
	end
		
	
	if ESP_Box:GetBool() then
		
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

		surface.SetDrawColor( boxcol.r, boxcol.g, boxcol.b, 255 )

		surface.DrawLine(xmax,ymax,xmax,ymin)
		surface.DrawLine(xmax,ymin,xmin,ymin)
		surface.DrawLine(xmin,ymin,xmin,ymax)
		surface.DrawLine(xmin,ymax,xmax,ymax)
	end
		
		if ESP_Barrel:GetBool() && e:IsPlayer() && e:Alive() then
		
			local eyetrace = e:GetEyeTrace().HitPos:ToScreen()
			
			local head = e:EyePos():ToScreen()
		
			surface.SetDrawColor( boxcol.r, boxcol.g, boxcol.b, 255 )
			
			surface.DrawLine( head.x, head.y, eyetrace.x, eyetrace.y )
			
		end
		
	if ESP_Health:GetBool() && e:IsPlayer() && e:IsValid() && e:Health() > 0 then

	local normalhp = 100

		if( e:Health() > normalhp ) then
			normalhp = e:Health()
		end
        
		local dmg, nor, hpos = normalhp / 4, e:Health() / 4, e:GetPos() + Vector( 0, 0, 0 ); hpos = hpos:ToScreen()
		
		local tc = team.GetColor( e:Team() )
			
		col = Color( tc.r, tc.g, tc.b, a )
		
		local pos = e:GetPos() + Vector( 0, 0, -10 ); pos = pos:ToScreen()
		
		local posy
		
		if ( ESP_Name:GetBool() == false ) then
			posy = pos.y + 0
		else
			posy = pos.y + 10
		end

		hpos.x = pos.x - ( dmg / 2 )
		hpos.y = posy
		
		local sub, size
		
		if ESP_Outlined:GetBool() then
			sub = 1
			size = 2
		else
			sub = 0
			size = 0
		end
          
		CreateGUI( hpos.x - sub, hpos.y - sub, dmg + size, 4 + size, Color( 0, 0, 0, 255 ) )
		CreateGUI( hpos.x, hpos.y, nor, 4, col )
		
	end
		
		return col, boxcol, text, pos, outlined
	
end

function CreateNewMaterial()

	local letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
	local r = table.Random( letters )
	
	local BaseInfo = {
		["$basetexture"] = "color/white",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1,
		["$ignorez"]     = 1,
	}

   local wireframe = CreateMaterial( "wireframe_" .. r, "Wireframe", BaseInfo )
   
   local solid = CreateMaterial( "solid_" .. r, "VertexLitGeneric", BaseInfo )

   return wireframe, solid

end

--[[
	Nospread
	Desc: I better become a better coder.
--]]
require("deco")
local PredictSpread = function() end
local mysetupmove = function() end
local Check = function() end

local CL = LocalPlayer()

local NoSpreadHere=false
if #file.Find("../lua/includes/modules/gmcl_deco.dll")>=1 then
NoSpreadHere=true
// ANTI SPREAD SCRIPT

local MoveSpeed = 1

mysetupmove = function(objPl, move)
	if move then
		MoveSpeed = (move:GetVelocity():Length())/move:GetMaxSpeed()
	end
end

local ID_GAMETYPE = ID_GAMETYPE or -1
local GameTypes = {
	{check=function ()
		return string.find(GAMEMODE.Name,"Garry Theft Auto") ~= nil
	end,getcone=function (wep,cone)
		if type(wep.Base) == "string" then
			if wep.Base == "civilian_base" then
				local scale = cone
				if CL:KeyDown(IN_DUCK) then
					scale = math.Clamp(cone/1.5,0,10)
				elseif CL:KeyDown(IN_WALK) then
					scale = cone
				elseif (CL:KeyDown(IN_SPEED) or CL:KeyDown(IN_JUMP)) then
					scale = cone + (cone*2)
				elseif (CL:KeyDown(IN_FORWARD) or CL:KeyDown(IN_BACK) or CL:KeyDown(IN_MOVELEFT) or CL:KeyDown(IN_MOVERIGHT)) then
					scale = cone + (cone*1.5)
				end
				scale = scale + (wep:GetNWFloat("Recoil",0)/3)
				return Vector(scale,0,0)
			end
		end
		return Vector(cone,cone,cone)
	end},
	{check=function ()
		return type(TEAM_ZOMBIE) == "number" and type(TEAM_SURVIVORS) == "number" and string.find(GAMEMODE.Name,"Zombie Survival") ~= nil and type(NUM_WAVES) == "number"
	end,getcone=function (wep,cone)
		if wep:GetNetworkedBool("Ironsights",false) then
			if CL:Crouching() then
				return wep.ConeIronCrouching or cone
			end
			return wep.ConeIron or cone
		elseif 25 < LocalPlayer():GetVelocity():Length() then
			return wep.ConeMoving or cone
		elseif CL:Crouching() then
			return wep.ConeCrouching or cone
		end
		return cone
	end},
	{check=function ()
		return type(TEAM_ZOMBIE) == "number" and type(TEAM_SURVIVORS) == "number" and string.find(GAMEMODE.Name,"Zombie Survival") ~= nil
	end,getcone=function (wep,cone)
		if CL:GetVelocity():Length() > 25 then
			return wep.ConeMoving or cone
		elseif CL:Crouching() then
			return wep.ConeCrouching or cone
		end
		return cone
	end},
	{check=function ()
		return type(gamemode.Get("ZombRP")) == "table" or type(gamemode.Get("DarkRP")) == "table"
	end,getcone=function (wep, cone)
		if type(wep.Base) == "string" and (wep.Base == "ls_snip_base" or wep.Base == "ls_snip_silencebase") then
			if CL:GetNWInt( "ScopeLevel", 0 ) > 0 then 
				print("using scopecone")
				return wep.Primary.Cone
			end
			print("using unscoped cone")
			return wep.Primary.UnscopedCone
		end
		if type(wep.GetIronsights) == "function" and wep:GetIronsights() then
			return cone
		end
		return cone + .05
	end},
	{check=function ()
		return (GAMEMODE.Data == "falloutmod" and type(Music) == "table")
	end,getcone=function(wep,cone)
		if wep.Primary then
			local LastShootTime = wep.Weapon:GetNetworkedFloat( "LastShootTime", 0 ) 
			local lastshootmod = math.Clamp(wep.LastFireMax + 1 - math.Clamp( (CurTime() - LastShootTime) * wep.LastFireModifier, 0.0, wep.LastFireMax ), 1.0,wep.LastFireMaxMod) 
			local accuracy = wep.Primary.Accuracy
			if CL:IsMoving() then accuracy = accuracy * wep.MoveModifier end
			if wep.Weapon:GetNetworkedBool( "Ironsights", false ) then accuracy = accuracy * 0.75 end
			accuracy = accuracy * ((16-(Skills.Marksman or 1))/11)
			if CL:KeyDown(IN_DUCK) then
				return accuracy*wep.CrouchModifier*lastshootmod
			else
				return accuracy*lastshootmod
			end
		end
	end}
}
Check = function()
	for k, v in pairs(GameTypes) do
		if v.check() then
			ID_GAMETYPE = k
			break
		end
	end
end

local tblNormalConeWepBases = {
	["weapon_cs_base"] = true
}
local function GetCone(wep)
	local cone = wep.Cone
	if not cone and type(wep.Primary) == "table" and type(wep.Primary.Cone) == "number" then
		cone = wep.Primary.Cone
	end
	if not cone then cone = 0 end
	--CHeck if wep is HL2 then return corresponding cone
	if type(wep.Base) == "string" and tblNormalConeWepBases[wep.Base] then return cone end
	if wep:GetClass() == "ose_turretcontroller" then return 0 end
	if ID_GAMETYPE ~= -1 then return GameTypes[ID_GAMETYPE].getcone(wep,cone) end
	return cone or 0
end

require("deco")
package.loaded.deco = nil

local nospread = hl2_shotmanip
local prediction = hl2_ucmd_getprediciton

_G.hl2_shotmanip = nil
_G.hl2_ucmd_getprediciton = nil
local currentseed, cmd2, seed = currentseed or 0, 0, 0
local wep, vecCone, valCone
PredictSpread = function(cmd,aimAngle)
	cmd2, seed = prediction(cmd)
	if cmd2 ~= 0 then
		currentseed = seed
	end
	wep = LocalPlayer():GetActiveWeapon()
	vecCone = Vector(0,0,0)
	if wep and wep:IsValid() and type(wep.Initialize) == "function" then
		valCone = GetCone(wep)
		if type(valCone) == "number" then
			vecCone = Vector(-valCone,-valCone,-valCone)
		elseif type(valCone) == "Vector" then
			vecCone = -1*valCone
		end
	end
	return nospread(currentseed or 0, (aimAngle or CL:GetAimVector():Angle()):Forward(), vecCone):Angle()
end
//END OF ANTI SPREAD SCRIPT
end
require("deco")

--[[
	Aimbot
	Desc: Because we are Americans. THANKS ASSAULT_TROOPER
--]]

local SetAngles = _R["CUserCmd"].SetViewAngles

function Mode(e)

	local ply = LocalPlayer()
	
	if !Visible(e) then return false end
	
	if e == ply then return false end
	
	if AIM_FF:GetInt() == 0 then
		if e:IsPlayer() && e:Team() == ply:Team() then return false end
	end
	
	if !e:IsValid() || !e:IsNPC() && !e:IsPlayer() || e == ply then return end
	
	if ( e:GetMoveType() == MOVETYPE_OBSERVER ) then return end
	
	if AIM_Mode:GetString() == "Players & NPC's" then
	
		if !e:IsValid() || !e:IsPlayer() && !e:IsNPC() then return false end
		if e:GetMoveType() == 0 then return false end
		if e:Alive() == false then return false end
		
	elseif AIM_Mode:GetString() == "Players" then
	
		if !e:IsValid() || !e:IsPlayer() then return false end
		if e:Alive() == false then return false end
	
	elseif AIM_Mode:GetString() == "NPC's" then
		
		if !e:IsValid() || !e:IsNPC() then return false end
		if e:GetMoveType() == 0 then return false end
	
	end
	
		
	return true
end

function AmmoCheck(UCMD)
	
	local ply = LocalPlayer()
	
		if ply && ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() then
	
		local wep = ply:GetActiveWeapon()
	
			if !wep then return -1 end
			
			if wep:Clip1() == 0 then
				
				return false
				
			else
			
			return true	
		end
	end
	
		if ( UCMD:GetButtons() & IN_RELOAD > 0 ) then
		
		return false
		
	else
	
		return true
	end
end

local pos, ang, tar, fov, cur_angle_y, cur_angle_p
local enabled = false

function PB.Aimbot(UCMD)

// You have to call this before or else it will fuck up the norecoil.
SetAngles = UCMD:GetViewAngles()

local targ

if enabled then

	local ply = LocalPlayer()
	
	local x, y = ScrW() / 2, ScrH() / 2
	
	pos, ang, tar, fov = ply:EyePos(), ply:GetAimVector(), { 0, 0 }, 360
	
	for k, e in pairs( ents.GetAll() ) do
	
		if Mode(e) && AmmoCheck() && AIM_Enabled:GetBool() then 
		
		local tarpos, self_ang = e:EyePos(), ply:GetAngles()
		local cur_angle = ( e:GetPos() - ply:GetPos() ):Angle()
		cur_angle_y = math.abs(math.NormalizeAngle( self_ang.y - cur_angle.y ) )
		cur_angle_p = math.abs(math.NormalizeAngle( self_ang.p - cur_angle.p ) )
		
			local find = ( tarpos - pos ):Normalize()
		
			find = find - ang
			find = find:Length()
			find = math.abs( find )
		
			if find < tar[2] or tar[1] == 0 then
		
				tar = { e, find }		
		
				targ = tar[1]

	if targ == 0 then return end
		
		if cur_angle_y < AIM_FOV:GetInt() && cur_angle_p < AIM_FOV:GetInt() || AIM_FOV:GetInt() == 0 then
		
		local vel = targ:GetVelocity() || Aimangle
				
		local vector, Nospread
				
		if AIM_Vec:GetBool() then
				
			vector = Vector( AIM_Vecx:GetInt(), AIM_Vecy:GetInt(), AIM_Vecz:GetInt() )
					
		else
					
			vector = Vector( 0, 0, 0 )
					
		end
				
		SetAngles = ( ( CreateBonePosition( targ ) + vector ) - ply:GetShootPos() ):Angle()
					
		if AIM_NoSpread:GetBool() then
					
			Nospread = PredictSpread( UCMD, SetAngles )
			Nospread.p = math.NormalizeAngle( Nospread.p )
			Nospread.y = math.NormalizeAngle( Nospread.y )
			
		else
			
			Nospread = SetAngles
				
		end
			
		local trace = ply:GetEyeTrace()

		UCMD:SetViewAngles( Nospread )
		end		
	end
end
end
end
end


function PB.Aiming()
	enabled = true
	MsgN( "Aiming Enabled" )
end

function PB.AimingOff()
	enabled = false
	MsgN( "Aiming Disabled" )
end


--[[
	Extra Sensory Perception
	Desc: Draws info about entities. ( Name, Health, Box )
--]]
function DrawText(e)
	
	for k, e in pairs( ents.GetAll() ) do
	
	local ply, dead = LocalPlayer(), true
		
		if ESP_Enabled:GetBool() && GoodTargets(e) && e:IsValid() then
		
		local col, boxcol, text, pos, outlined = TargetInformation(e)
		
			if outlined == true then
				draw_style = draw.SimpleTextOutlined
			else
				draw_style = draw.SimpleText
			end
		
		draw_style(
			text,
			"Default",
			pos.x,
			pos.y,
			col,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1,
			Color( 0, 0, 0, 255 )
			)
		end
	end
	
	local x, y = ScrW() / 2, ScrH() / 2
	local x2, y2 = ScrW() / 2 + 5, ScrH() / 2 + 5
	local x3, y3 = ScrW() / 2 - 5, ScrH() / 2 - 5
	local x4, y4 = ScrW() / 2 + 5, ScrH() / 2 - 5
	local x5, y5 = ScrW() / 2 - 5, ScrH() / 2 + 5
	
	local  g = 5; local l = g + 10
	
	if VIS_CrossAdvanced:GetBool() then
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawLine( x2 + 20, y2 + 20, x2, y2 )
		surface.DrawLine( x3 - 20, y3 - 20, x3, y3 )
		surface.DrawLine( x5, y5, x5 - 20, y5 + 20)
		surface.DrawLine( x4, y4, x4 + 20, y4 - 20 )
	end
	
	if VIS_CrossNormal:GetBool() then
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawLine( x - l, y, x - g, y ); surface.DrawLine( x + l, y, x + g, y )
		surface.DrawLine( x, y - l, x, y - g ); surface.DrawLine( x, y + l, x, y + g )
	end
	
	if VIS_CrossBasic:GetBool() then
	
		local cross = {}
		cross.x			= ScrW() / 2	
		cross.y			= ScrH() / 2
		cross.tall		= 5
		cross.wide		= 5
		
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawLine( cross.x, cross.y - cross.tall, cross.x, cross.y + cross.tall )
		surface.DrawLine( cross.x - cross.wide, cross.y, cross.x + cross.wide, cross.y )
	end
	
	if VIS_CrossAnimation:GetBool() then
		surface.DrawCircle( x, y, math.sin( CurTime() * 0.5 ) * 80, Color( 255, 0, 0, 255 )  )
	end
end

--[[
	Chams
	Desc: Makes the entities model visible through walls.
--]]

function Chams()
	
	for k, e in pairs( ents.GetAll() ) do
	
		local ply = LocalPlayer()
		
		if VIS_Chams:GetBool() && GoodTargetsChams(e) then
		
			if ( e:IsWeapon() && table.HasValue( Classes, e:GetClass() ) && table.HasValue( Models, e:GetModel() ) && table.HasValue( Warnings, e:GetClass() ) && ESP_Entity:GetBool() == false ) then end
			
			if e:IsValid() then
			
				local solid, wireframe = CreateNewMaterial()
				
				local mat, fullbright
				
				if VIS_ChamsMaterial:GetString() == "Wireframe" then 
				
					mat = solid
					
				elseif VIS_ChamsMaterial:GetString() == "Solid" then 
			
					mat = wireframe
					
				else
					
					mat = nil
					
				end
		
				
				local c, col = ( 1/255 ), ""
				
				local class = e:GetClass()
				
				if ( e:IsPlayer() && e:IsValid() ) then
					local tc = team.GetColor( e:Team() )
					col = Color( tc.r, tc.g, tc.b, a )
	
				elseif ( e:IsNPC() && !table.HasValue( AllieNPC, class ) && e:IsValid() ) then
					col = Color( 255, 0, 0, a )
		
				elseif ( e:IsWeapon() && e:IsValid() ) then
					col = Color( 255, 255, 255, a )
		
				elseif ( e:IsNPC() && table.HasValue( AllieNPC, class ) && e:IsValid() ) then
					col = Color( 0, 255, 0, a )
					
				elseif ( e:GetClass() == "prop_ragdoll" || e:GetClass() == "class C_ClientRagdoll" ) then
					col = Color( 255, 242, 0, a )
		
				else
					col = Color( 255, 127, 39, a )
					
				end
				
				if VIS_ChamsFullbright:GetBool() then
					
					fullbright = true
				
				else
					
					fullbright = false
					
				end
				
				if VIS_ChamsMaterial:GetString() == "XQZ" then
				
					cam.Start3D( EyePos(), EyeAngles() )
		
					render.SuppressEngineLighting( fullbright )
				
					cam.IgnoreZ( true )
		
					e:DrawModel()
		
					render.SuppressEngineLighting( false )
				
					cam.IgnoreZ( false )
				
					cam.End3D()
					
				elseif VIS_ChamsMaterial:GetString() == "Solid" || VIS_ChamsMaterial:GetString() == "Wireframe" then
				
					cam.Start3D( EyePos(), EyeAngles() )
					
					render.SuppressEngineLighting( fullbright )
					
					render.SetColorModulation((c*col.r), (c*col.g), (c*col.b))
					
					SetMaterialOverride( mat )
					
					e:DrawModel()
					
					render.SuppressEngineLighting( false )
					
					render.SetColorModulation( 1, 1, 1 )
					
					SetMaterialOverride( 0 )
					
					e:DrawModel()
					
					cam.End3D()
					
				end
			end
		end
	end
end

--[[
	Dynamic Lights
	Desc: Draws a light around the entity(s).
--]]
function DLights()

	for k, e in pairs( ents.GetAll() ) do
	
		local ply = LocalPlayer()
		
		if VIS_Lights:GetBool() && GoodTargetsChams(e) && !e:IsWeapon() && e ~= ply then
		
			local light = DynamicLight( e:EntIndex() ) 
			
				if ( light ) then 
				
				local bright, size, col = "", "", TargetInformation(e)
				
				if e:IsPlayer() then bright = 9 else bright = 7 end
				
				if e:IsPlayer() then size = VIS_LightsRange:GetInt() else size = 100 end
				
				light.Pos = e:GetPos() + Vector( 0, 0, 10 )
				
				light.r = col.r
				
				light.g = col.g
				
				light.b = col.b
				
				light.Brightness = bright
				
				light.Decay = size * 5
				
				light.Size = size
				
				light.DieTime = CurTime() + 1
				
			end
		end
	end
end

// Thanks Eusion for the great idea :)!
local x = 0
local y = 0
function PB.CustomAngle( UCMD )

	local ply = LocalPlayer()
	
	if MIS_360View:GetBool() && targ != true then
			
		if ply:KeyDown( IN_USE ) then return end
		
		x = x + ( UCMD:GetMouseX() / ( ply:GetInfo("sensitivity") * 8 ) )
		y = y + ( UCMD:GetMouseY() / ( ply:GetInfo("sensitivity") * 8 ) )
		
		UCMD:SetViewAngles( Angle( y, -x, 0 ) )
		return true
	end
end

function PB.Norecoil( )

	local ply = LocalPlayer()
	
	local wep = ply:GetActiveWeapon()
	
	wep.OldRecoil = wep.Recoil || wep.Primary && wep.Primary.Recoil
	
	if AIM_Norecoil:GetBool() then
	
			if wep.Primary then wep.Primary.Recoil = 0.0 end
		
			if wep.Secondary then wep.Secondary.Recoil = 0.0 end
			
		local fov = AIM_FOV:GetInt()
		
		return { origin = fov, angles = SetAngles }
		
	else
	
		wep.Recoil = wep.OldRecoil
	end
end

function PB.DrawFOV()

	local x, y = ScrW() / 2, ScrH() / 2
	
	local fov = AIM_FOV:GetInt()
	
	if fov < 40  && VIS_DrawFOV:GetBool() then
	
		surface.DrawCircle( x, y, fov * 13, Color( 255, 255, 255, 255 ) )
		
	end
end

--[[
	Bunnyhop
	Desc: Jump over and over again just by holding down the key.
--]]
local jump = false
function Bunnyhop()

  if MIS_BHop:GetBool() then
  
	local ply = LocalPlayer()
	
	if input.IsKeyDown( KEY_SPACE ) then
	
		local ply = LocalPlayer()
		
			if !ply:IsOnGround() then
				RunConsoleCommand( "-jump" ) 
				jump = true
			elseif ply:IsOnGround() then
				RunConsoleCommand( "+jump" ) 
				jump = false
			end
			
			if jump then
				RunConsoleCommand( "-jump" )
				jump = true
			end
		end
	end	
end

function ReloadVectors()
	RunConsoleCommand( "pb_aim_vectorx", 0 ); MsgN( "[Precisionbot] Set pb_aim_vectorx to 0" )
	RunConsoleCommand( "pb_aim_vectory", 0 ); MsgN( "[Precisionbot] Set pb_aim_vectory to 0" )
	RunConsoleCommand( "pb_aim_vectorz", 0 ); MsgN( "[Precisionbot] Set pb_aim_vectorz to 0" )
end

--[[
	Hooks, Concommands
	Desc:
--]]

PB:AddHook( "HUDPaint", DrawText )
PB:AddHook( "RenderScreenspaceEffects", Chams )
PB:AddHook( "Think", DLights )
PB:AddHook( "Think", Bunnyhop )
PB:AddHook( "CreateMove", PB.Aimbot )
PB:AddHook( "CreateMove", PB.CustomAngle )
PB:AddHook( "CalcView", PB.Norecoil )
PB:AddHook( "HUDPaint", PB.DrawFOV )

PB:AddConCommand( "+pb_aim", PB.Aiming )
PB:AddConCommand( "-pb_aim", PB.AimingOff )
PB:AddConCommand( "pb_aim_vec_reload", ReloadVectors )

--[[
	Menu
	Desc:
--]]
local Menu
function Menu()

	local x, y = ScrW() / 2, ScrH() / 2
	
	local Panel = vgui.Create( "DPropertySheet" )
		Panel:SetParent( menu )
		Panel:SetPos( x - 500 / 2, y - 300 / 2)
		Panel:SetSize( 500, 300 )
		Panel:MakePopup()
		Menu = Panel
	
	local Aimpanel = vgui.Create( "DPanelList", Panel )
	local Esppanel = vgui.Create( "DPanelList", Panel )
	local Vispanel = vgui.Create( "DPanelList", Panel )
	local Miscpanel = vgui.Create( "DPanelList", Panel )
	
	---- Aimbot
	
	local Text = vgui.Create("DLabel")
		Text:SetText( "Aimbot Settings: " )
		Text:SetParent( Aimpanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 0 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
	-- Aim
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Enabled" )
		Checkbox:SetParent( Aimpanel )
		Checkbox:SetPos( 10, 20 )
		Checkbox:SetConVar( "pb_aim_enabled" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Friendly Fire" )
		Checkbox:SetParent( Aimpanel )
		Checkbox:SetPos( 10, 40 )
		Checkbox:SetConVar( "pb_aim_friendlyfire" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Autoshoot" )
		Checkbox:SetParent( Aimpanel )
		Checkbox:SetPos( 10, 60 )
		Checkbox:SetConVar( "pb_aim_shoot" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Norecoil" )
		Checkbox:SetParent( Aimpanel )
		Checkbox:SetPos( 10, 80 )
		Checkbox:SetConVar( "pb_aim_norecoil" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Nospread" )
		Checkbox:SetParent( Aimpanel )
		Checkbox:SetPos( 10, 100 )
		Checkbox:SetConVar( "pb_aim_nospread" )
		Checkbox:SizeToContents()
		
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Allow Vector Adjustments" )
		Checkbox:SetParent( Aimpanel )
		Checkbox:SetPos( 10, 120 )
		Checkbox:SetConVar( "pb_aim_allowvector" )
		Checkbox:SizeToContents()
		
	local List = vgui.Create( "DMultiChoice" )
		List:SetPos( 260, 20 )
		List:SetParent( Aimpanel )
		List:SetSize( 220, 20 )
		List:AddChoice( "Head" )
		List:AddChoice( "Spine" )
		List:AddChoice( "Middle Body" )
		List:AddChoice( "Pelvis" )
		List:SetConVar( "pb_aim_bone" )
		
			local Text = vgui.Create("DLabel")
				Text:SetText( "Aimspot:" )
				Text:SetParent( Aimpanel )
				Text:SetWide( 200 )
				Text:SetPos( 260, 0 )
				Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
		
	local List = vgui.Create( "DMultiChoice" )
		List:SetPos( 260, 70 )
		List:SetParent( Aimpanel )
		List:SetSize( 220, 20 )
		List:AddChoice( "Players & NPC's" )
		List:AddChoice( "Players" )
		List:AddChoice( "NPC's" )
		List:SetConVar( "pb_aim_mode" )
		
			local Text = vgui.Create("DLabel")
				Text:SetText( "Targets:" )
				Text:SetParent( Aimpanel )
				Text:SetWide( 200 )
				Text:SetPos( 260, 50 )
				Text:SetTextColor( Color( 255, 0, 0, 255 ) )
				
	local NumberSlider = vgui.Create( "DNumSlider" )
		NumberSlider:SetPos( 10, 140 )
		NumberSlider:SetParent( Aimpanel )
		NumberSlider:SetWide( 220 )
		NumberSlider:SetText( "Vector X" )
		NumberSlider:SetMin( -200 )
		NumberSlider:SetMax( 200 )
		NumberSlider:SetDecimals( 1 )
		NumberSlider:SetConVar( "pb_aim_vectorx" )
		
	local NumberSlider = vgui.Create( "DNumSlider" )
		NumberSlider:SetPos( 10, 180 )
		NumberSlider:SetParent( Aimpanel )
		NumberSlider:SetWide( 220 )
		NumberSlider:SetText( "Vector Z" )
		NumberSlider:SetMin( -200 )
		NumberSlider:SetMax( 200 )
		NumberSlider:SetDecimals( 1 )
		NumberSlider:SetConVar( "pb_aim_vectory" )
		
	local NumberSlider = vgui.Create( "DNumSlider" )
		NumberSlider:SetPos( 10, 220 )
		NumberSlider:SetParent( Aimpanel )
		NumberSlider:SetWide( 220 )
		NumberSlider:SetText( "Vector Y" )
		NumberSlider:SetMin( -200 )
		NumberSlider:SetMax( 200 )
		NumberSlider:SetDecimals( 1 )
		NumberSlider:SetConVar( "pb_aim_vectorz" )
		
	local NumberSlider = vgui.Create( "DNumSlider" )
		NumberSlider:SetPos( 260, 220 )
		NumberSlider:SetParent( Aimpanel )
		NumberSlider:SetWide( 220 )
		NumberSlider:SetText( "Field of View" )
		NumberSlider:SetMin( 1 )
		NumberSlider:SetMax( 180 )
		NumberSlider:SetDecimals( 0 )
		NumberSlider:SetConVar( "pb_aim_fov" )
		
	---- ESP
	local Text = vgui.Create("DLabel")
		Text:SetText( "Player Information: " )
		Text:SetParent( Esppanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 0 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
	local Text = vgui.Create("DLabel")
		Text:SetText( "Entity Information: " )
		Text:SetParent( Esppanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 80 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
	local Text = vgui.Create("DLabel")
		Text:SetText( "Extra Settings: " )
		Text:SetParent( Esppanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 140 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
	
	-- Players
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Name" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 20 )
		Checkbox:SetConVar( "pb_esp_name" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Health" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 40 )
		Checkbox:SetConVar( "pb_esp_health" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Show Dead" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 60 )
		Checkbox:SetConVar( "pb_esp_showdead" )
		Checkbox:SizeToContents()
		
	-- Entities
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Show NPC's" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 100 )
		Checkbox:SetConVar( "pb_esp_npc" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Show Entities" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 120 )
		Checkbox:SetConVar( "pb_esp_entity" )
		Checkbox:SizeToContents()
		
	-- Extra
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Bounding Box" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 160 )
		Checkbox:SetConVar( "pb_esp_box" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Barrel" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 180 )
		Checkbox:SetConVar( "pb_esp_barrel" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Outline Text" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 200 )
		Checkbox:SetConVar( "pb_esp_outline" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Visibility Checks" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 220 )
		Checkbox:SetConVar( "pb_esp_visibility" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Team Color" )
		Checkbox:SetParent( Esppanel )
		Checkbox:SetPos( 10, 240 )
		Checkbox:SetConVar( "pb_esp_teamcolor" )
		Checkbox:SizeToContents()
		
	---- Visuals
	
	local Text = vgui.Create("DLabel")
		Text:SetText( "Crosshair: " )
		Text:SetParent( Vispanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 0 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
	local Text = vgui.Create("DLabel")
		Text:SetText( "Dynamic Lights: " )
		Text:SetParent( Vispanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 100 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
	local Text = vgui.Create("DLabel")
		Text:SetText( "Extra Settings: " )
		Text:SetParent( Vispanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 180 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
	local Text = vgui.Create("DLabel")
		Text:SetText( "Cham Settings: " )
		Text:SetParent( Vispanel )
		Text:SetWide( 200 )
		Text:SetPos( 260, 0 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )

		
	-- Crosshair
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Basic" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 10, 20 )
		Checkbox:SetConVar( "pb_vis_crossbasic" )
		Checkbox:SizeToContents()
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Normal" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 10, 40 )
		Checkbox:SetConVar( "pb_vis_crossnormal" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Advanced" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 10, 60 )
		Checkbox:SetConVar( "pb_vis_crossadvanced" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Animation" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 10, 80 )
		Checkbox:SetConVar( "pb_vis_crossanimation" )
		Checkbox:SizeToContents()
	
	-- Dynamic Lights
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Enabled" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 10, 120 )
		Checkbox:SetConVar( "pb_vis_lights" )
		Checkbox:SizeToContents()
		
	local NumberSlider = vgui.Create( "DNumSlider" )
		NumberSlider:SetPos( 10, 140 )
		NumberSlider:SetParent( Vispanel )
		NumberSlider:SetWide( 200 )
		NumberSlider:SetText( "Dynamic Light Range" )
		NumberSlider:SetMin( 20 )
		NumberSlider:SetMax( 100 )
		NumberSlider:SetDecimals( 0 )
		NumberSlider:SetConVar( "pb_vis_lights_range" )
		
	-- Extra
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Draw FOV" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 10, 200 )
		Checkbox:SetConVar( "pb_vis_drawfov" )
		Checkbox:SizeToContents()
		
	-- Chams
	
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Enabled" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 260, 50 )
		Checkbox:SetConVar( "pb_vis_chams" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Players" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 260, 70 )
		Checkbox:SetConVar( "pb_vis_chams_player" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "NPC's" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 260, 90 )
		Checkbox:SetConVar( "pb_vis_chams_npc" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Weapons" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 260, 110 )
		Checkbox:SetConVar( "pb_vis_chams_weapon" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Ragdolls" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 260, 130 )
		Checkbox:SetConVar( "pb_vis_chams_ragdoll" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Fullbright" )
		Checkbox:SetParent( Vispanel )
		Checkbox:SetPos( 260, 150 )
		Checkbox:SetConVar( "pb_vis_chams_fullbright" )
		Checkbox:SizeToContents()
	
	local cList = vgui.Create( "DMultiChoice" )
		cList:SetPos( 260, 20 )
		cList:SetParent( Vispanel )
		cList:SetSize( 220, 20 )
		cList:AddChoice( "Solid" )
		cList:AddChoice( "Wireframe" )
		cList:AddChoice( "XQZ" )
		cList:SetConVar( "pb_vis_chams_material" )
		
		---- Miscellaneous
		
	local Text = vgui.Create("DLabel")
		Text:SetText( "Miscellaneous Scripts: " )
		Text:SetParent( Miscpanel )
		Text:SetWide( 200 )
		Text:SetPos( 10, 0 )
		Text:SetTextColor( Color( 255, 0, 0, 255 ) )
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "Bunnyhop" )
		Checkbox:SetParent( Miscpanel )
		Checkbox:SetPos( 10, 20 )
		Checkbox:SetConVar( "pb_misc_bhop" )
		Checkbox:SizeToContents()
		
	local Checkbox = vgui.Create( "DCheckBoxLabel" )
		Checkbox:SetText( "360 View (Requires norecoil disable tell fixed)" )
		Checkbox:SetParent( Miscpanel )
		Checkbox:SetPos( 10, 40 )
		Checkbox:SetConVar( "pb_misc_360view" )
		Checkbox:SizeToContents()

	Panel:AddSheet( "Aimbot", Aimpanel, "gui/silkicons/wrench", false, false, "Automatic Aiming" )
	Panel:AddSheet( "ESP", Esppanel, "gui/silkicons/group", false, false, "Extra Sensory Perception" )
	Panel:AddSheet( "Visuals", Vispanel, "gui/silkicons/star", false, false, "Chams, Dynamic Lights..." )
	Panel:AddSheet( "Miscellaneous", Miscpanel, "gui/silkicons/plugin", false, false, "Miscellaneous" )
		
end

PB:AddConCommand( "+pb_menu", Menu )
PB:AddConCommand( "-pb_menu", function() 
	Menu:SetVisible( false )
end )

--[[
	Security
	Desc: Makes sure anti-cheats can't detect our hack.
--]]
/*local OLD_ENGINECCOMMAND	= engineConsoleCommand
local OLD_GETCONVAR			= GetConVar
local OLD_GETCONVARNUMBER	= GetConVarNumber
local OLD_CONVAREXISTS		= ConVarExists
local OLD_HOOKADD			= hook.Add
local OLD_HOOKREMOVE		= hook.Remove
local OLD_HOOKCALL			= hook.Call
local OLD_CONADD			= concommand.Add
local OLD_CONREMOVE			= concommand.Remove
local OLD_FILEREAD			= file.Read
local OLD_FILEEXISTS		= file.Exists
local OLD_FILEEXISTEX		= file.ExistsEx
local OLD_FILEWRITE			= file.Write
local OLD_FILETIME			= file.Time
local OLD_FILESIZE			= file.Size
local OLD_FILEFIND			= file.Find
local OLD_FILEFINDINLUA		= file.FindInLua
local OLD_FILERENAME		= file.Rename
local OLD_FILETFIND			= file.TFind
local OLD_FILEISDIR			= file.IsDir
local OLD_FILECREATEDIR		= file.CreateDir
local OLD_FILEDELETE		= file.Delete
local OLD_ADDCCBACKS		= cvars.AddChangeCallback
local OLD_GETCVARCBACKS		= cvars.GetConVarCallBacks
local OLD_ONCONCARCHANGE	= cvars.OnConVarChanged

function GetConVar( var )
	for k, cmd in pairs( PB.Commands ) do
		if string.find(string.lower( var ), cmd ) then return end
		return OLD_GETCONVAR( var )
	end
end

function GetConVarNumber( var )
	for k, cmd in pairs( PB.Commands ) do
		if var == cmd then return end
		return OLD_GETCONVARNUMBER( var )
	end
end

function ConVarExists( var )
	for k, cmd in pairs( PB.Commands ) do
		if var == string.find(string.lower( var ), cmd ) then return end
		return OLD_CONVAREXISTS( var )
	end
end

/*function hook.Add( typ, name, func )
	for k, cmd in pairs( PB.Hooks ) do
		if string.find(string.lower( name ), cmd ) then return end
		return OLD_HOOKADD( typ, name, func )
	end
end

function hook.Add( typ, name, func )
	for k, cmd in pairs( PB.Hooks ) do
		if string.find(string.lower( name ), cmd ) then return end
		return OLD_HOOKREMOVE( typ, name, func )
	end
end

// Now we need to test and see if the convar overide worked.

local msg = ( "|--------------------|" )

MsgN( msg )
MsgN( GetConVarNumber( "sbox_maxnpcs" ) )
MsgN( GetConVarNumber( "pb_esp_name" ) )
MsgN( msg )*/