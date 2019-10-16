/*--------------------------------------------------
	PrecisionAim ALPHA - By fr1kin
	Most of the script is mine, but thanks to these guys I found out how to script these (also Garry's Mod Wiki)
	Credits: Eusion, Nautical, RabidToaster, Slob187, Assault_Trooper, Teta_Bonita, Mawman, RabidToaster, SiPlus, JetBoom, and s0beit.
--------------------------------------------------*/
if ( SERVER ) then return end

// CLIENT COMMANDS
local ClientCheatCommands = ( {
	f_aimbot		= 1.0,
	f_autoshoot		= 0.0,
	f_autowall		= 0.0,
	f_aimtarget		= 1.0,
	f_ff			= 1.0,
	f_bone			= 14.0,
	f_fov			= 360.0,
	f_smooth		= 0.0,

	f_name 			= 2.0,
	f_health		= 1.0,
	f_info			= 1.0,
	f_box			= 1.0,
	f_barrel		= 0.0,
	f_dismax		= 5000.0,
	f_entity		= 1.0,
	f_entityweapon	= 1.0,
	f_npc			= 1.0,

	f_crosshair 	= 5.0,
	f_chams			= 1.0,
	f_dlights		= 0.0,
	f_allplydlight	= 0.0,

	f_recoil	 	= 1.0,

	f_bhop		 	= 1.0,
	f_autopistol	= 1.0,
	f_bypass		= 1.0,
	f_antiafk		= 0.0,
	f_namesteal		= 0.0,
	f_meatspin		= 0.0,
	f_spam			= 0.0,
	f_stfu			= 0.0,

	f_radar			= 0.0,
	f_radar_x		= 0.0,
	f_radar_y		= 0.0,
	f_radar_r		= 0.0,
	f_radar_g		= 255.0,
	f_radar_b		= 0.0,
	f_radar_a		= 150.0,

	f_entitycol_r	= 0.0,
	f_entitycol_g	= 255.0,
	f_entitycol_b	= 0.0,
	f_entitycol_a	= 255.0,

	f_npc_r			= 255.0,
	f_npc_g			= 0.0,
	f_npc_b			= 0.0,
	f_npc_a			= 255.0,
} )

function CreateCommands()
	for key, value in pairs( ClientCheatCommands ) do
		CreateClientConVar( key, value, true, false )
	end
end

// DISABLED AIMING WEAPONS
local DisabledWeapons = ( {
	"weapon_physcannon",
	"weapon_physgun",
	"weapon_crowbar",
	"weapon_frag",
	"gmod_tool",
} )

// ROLEPLAY ENTITYS
local RolePlayEntitys = ( {
	"money_printer",
	"drug_lab",
	"drug",
	"microwave",
	"food",
	"gunlab",
	"spawned_shipment",
	"spawned_food",
	"spawned_weapon",
} )

// ROLEPLAY MONEY
local RPMoney = ( {
	"models/props/cs_assault/money.mdl",
} )

// WEAPON WARNINGS
local Warnings = ( {
	"npc_grenade_frag",
	"crossbow_bolt",
	"rpg_missile",
	"grenade_ar2",
	"prop_combine_ball",
	"hunter_flechette",
	"ent_flashgrenade",
	"ent_explosivegrenade",
	"ent_smokegrenade",
} )

// GET ADMIN TPYE
local function GetAdmin(v)
if v:IsAdmin() and not v:IsSuperAdmin() then return "Admin"
elseif v:IsSuperAdmin() then return "Super Admin"
elseif not v:IsAdmin() and not v:IsSuperAdmin() then return "User" 
end
end

// HEAD OFFSET BY EUSION
local HeadOffset = Vector(0,0,45)
local TargetHead = true
local function HeadPos(ent)
if ent:IsPlayer() then
if TargetHead then
return ent:GetAttachment(1).Pos + ent:GetAngles():Forward() * -4
else
if ent:Crouching() then
return ent:GetPos() + (HeadOffset * 0.586)
else
return ent:GetPos() + HeadOffset
end
end
else
return ent:GetPos() + HeadOffset
end
end

// VAILD
function EntityValid(v)
	if !v:IsValid() or !v:IsNPC() and !v:IsPlayer() or LocalPlayer() == v then return false end
	if v:IsPlayer() and !v:Alive() then return false end
	if v:IsPlayer() and string.find(string.lower(team.GetName(v:Team())), "spectator") then return false end
	if v:IsNPC() and v:GetMoveType() == 0 then return false end
	return true
end

// VISIBLE BY EUSION
local function Visible(v)
local trace = {start = LocalPlayer():GetShootPos(),endpos = HeadPos(v),filter = {LocalPlayer(), v}}
local tr = util.TraceLine(trace)
if tr.Fraction == 1 then
return true
else
return false
end	
end
		

// SCREEN
local x 			= ScrW() / 2.0
local y 			= ScrH() / 2.0

// MENU
local myname 		= "fr1kin"
local hackname    	= "[Precision Aim]"
local hackversion 	= "v1.1"
local message 		= "By"

// CROSSHAIR
local gap 			= 5
local length 		= gap + 15

// AIMING
local aiming    	= false
local autoshoot 	= false
local aimbone 		= 1
local aimtarget 	= GetConVarNumber( "f_aimtarget" )

// ALPHABET
local leetalphabet	= { "4", "8", "(", "|)", "3", "|=", "[_-", "|-|", "!", "-_7", "|<", "|_", "|v|", "0", "|>", "?", "|'", "5", "7", "|_|", "\/", "\/\/", "`|`", "``/_" } 

// TABLED
local allcolors 	= {}
local allmats		= {}

// COLORS
local black 		= Color(0, 0, 0, 255)
local white			= Color(255, 255, 255, 255)
local red			= Color(255, 0, 0, 255)
local green			= Color(0, 255, 0, 255)
local blue			= Color(0, 0, 255, 255)

// OTHER
local funcs			= {"ply", "ents", "ent", "k", "v", "_", "w", "h", "x", "y", "col"}
local alarm 		= Sound( "PrecisionAim/Alarm.mp3" )

// FONTS
surface.CreateFont("Coolvetica", 25, 800, true, false, "PRINT_FONT")
surface.CreateFont("Coolvetica", 15, 200, true, false, "PRINT_FONTXS")
surface.CreateFont("Arial", 30, 400, true, false, "ARIAL_L")
surface.CreateFont("Arial", 15, 200, true, false, "ARIAL_F")
surface.CreateFont("Arial", 10, 200, true, false, "ARIAL_S")

// CONSOLE MESSAGES
Msg(hackname .. " " .. message .. " " .. myname .. "\n")
Msg("NOTE: Precision Aim Loaded. \n")

hook.Add("Initialize", "RunCommands", CreateCommands) // CLIENT COMMAND
//__________ AIMBOT _________________________________________________________________________________________________________________________________________//
	



//__________ ESP ____________________________________________________________________________________________________________________________________________//

function DrawESP(ply)
for _, v in pairs(ents.GetAll()) do
		if (v:IsPlayer()) and (v:Alive() == true) and (v:EntIndex() != LocalPlayer():EntIndex()) then
			local pos = v:GetPos():ToScreen()
			local col = team.GetColor( v:Team() )
			local dis = math.floor(tostring(v:GetPos():Distance(LocalPlayer():GetShootPos())))
				
				// MAX DISTANCE UNTILL ESP NOT DRAWN.
				if dis <= GetConVarNumber("f_dismax") then
					
					// NAME ESP
					if GetConVarNumber( "f_name" ) == 1 then
							draw.SimpleText( v:Name(), "DefaultSmall", pos.x, pos.y, col, 3, 3 )
						end
						
					// HEALTH ESP
					if GetConVarNumber( "f_health" ) == 1 then
							draw.SimpleText( "HP: " .. v:Health(), "DefaultSmall", pos.x, pos.y + 10, col, 3, 3 )
						end
						
					// INFO ( DISTANCE )
					if GetConVarNumber("f_info") == 1 then
							local dis = math.floor(tostring(v:GetPos():Distance(LocalPlayer():GetShootPos())))
							if dis <= GetConVarNumber("f_dismax") then
							draw.SimpleText("D: " .. dis, "DefaultSmall", pos.x, pos.y + 20, col, 3, 3 )
						end
					end
					
					// INFO ( ACTIVE WEAPON )
					if GetConVarNumber("f_info") == 2 then
							if v:GetActiveWeapon():IsValid() then
							local wep = v:GetActiveWeapon():GetPrintName()
							local wep = string.Replace(wep, "#HL2_", "")
							local wep = string.Replace(wep, "#GMOD_", "")
							local wep = string.upper(wep)
							draw.SimpleText( "W: " .. wep, "DefaultSmall", pos.x, pos.y + 20, col, 3, 3 )
						end
					end
					
					// INFO ( ADMIN TYPE )
					if GetConVarNumber("f_info") == 3 then
							draw.SimpleText( GetAdmin(v), "DefaultSmall", pos.x, pos.y + 20, col, 3, 3 )
						end
						
					// INFO ( TEAM NAME )
					if GetConVarNumber("f_info") == 4 then
							draw.SimpleText( team.GetName(v:Team()), "DefaultSmall", pos.x, pos.y + 20, col, 3, 3 )
						end
						
					// BARREL
					if GetConVarNumber("f_barrel") == 1 then
							local AP = v:GetEyeTrace().HitPos:ToScreen()
							local HP = HeadPos(v):ToScreen()
							surface.SetDrawColor( col.r, col.g, col.b, 150 )
							surface.DrawLine(HP.x, HP.y, AP.x, AP.y)
						end
						
					// BOX ESP BY EUSION
					if GetConVarNumber("f_box") == 1 then
							local center = v:LocalToWorld(v:OBBCenter())
							local min,max = v:WorldSpaceAABB()
							local dim = max-min

							local front = v:GetForward()*(dim.y/2)
							local right = v:GetRight()*(dim.x/2)
							local top = v:GetUp()*(dim.z/2)
							local back = (v:GetForward()*-1)*(dim.y/2)
							local left = (v:GetRight()*-1)*(dim.x/2)
							local bottom = (v:GetUp()*-1)*(dim.z/2)
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

							surface.SetDrawColor(col.r, col.g, col.b, 100)

							surface.DrawLine(xmax,ymax,xmax,ymin)
							surface.DrawLine(xmax,ymin,xmin,ymin)
							surface.DrawLine(xmin,ymin,xmin,ymax)
							surface.DrawLine(xmin,ymax,xmax,ymax)
						end
				else
				
			// OVER MAX DISTANCE ( PRINTS NAME )
			if dis >= GetConVarNumber("f_dismax") then
				if GetConVarNumber("f_name") >= 1 then
						draw.SimpleText( v:Nick(), "DefaultSmall", pos.x, pos.y, col, 1, 1 )
					end
				end
			end
		end
	end
end
function DrawENTESP()
	for _, ent in pairs(ents.GetAll()) do
	if ent:IsValid() then
	local epos  = ent:GetPos():ToScreen()
	local class = ent:GetClass()
	local model = ent:GetModel()
	local dis = math.floor(tostring(ent:GetPos():Distance(LocalPlayer():GetShootPos())))
	local getcolors = Color( GetConVarNumber( "f_entitycol_r" ), GetConVarNumber( "f_entitycol_g" ), GetConVarNumber( "f_entitycol_b" ), GetConVarNumber( "f_entitycol_a" ) )
				
							// ENTITY NAME FIXES
							local EntityFix    = class
							local WeaponFix    = class
							local Warningfix   = class
							local Warningfix1  = string.Replace(Warningfix, "npc_", "")
							local Warningfix2  = string.Replace(Warningfix1, "_", " ")
							local WeaponFix1   = string.Replace(WeaponFix, "weapon_", "")
							local WeaponFix2   = string.Replace(WeaponFix1, "prop_vehicle_", "")
							local EntityFix1   = string.Replace(EntityFix, "spawned_", "")
							local EntityFix2   = string.Replace(EntityFix1, "shipment_", "Shipment ")
							local EntityFix3   = string.Replace(EntityFix2, "dropped_", "")
							local EntityFix4   = string.Replace(EntityFix3, "dropped_", "")
							local EntityFix5   = string.Replace(EntityFix4, "smg_", "SMG ")
							local EntityFix6   = string.Replace(EntityFix5, "money_", "Money ")
							local EntityFixer  = string.upper( EntityFix6 )
							local WeaponFixer  = string.upper( WeaponFix2 )
							local Warningfixer = string.upper( Warningfix2 )
				
							// ENTITY ESP
							if GetConVarNumber("f_entity") == 1 and table.HasValue( RolePlayEntitys, class) then
									draw.SimpleText(""..EntityFixer.."", "DefaultSmall", epos.x, epos.y, getcolors, 1 ,1)
								else
							end
							
							// ENTITY ESP
							if GetConVarNumber("f_entity") == 2 and table.HasValue( RolePlayEntitys, class) then
									draw.SimpleText(""..EntityFixer.."", "DefaultSmall", epos.x, epos.y + 10, getcolors, 1 ,1)
									surface.SetDrawColor( getcolors )
									surface.DrawOutlinedRect( epos.x - 12, epos.y - 20, 25, 25 )
								else
							end
						
							// MONEY ESP
							if GetConVarNumber("f_entity") >= 1 and table.HasValue( RPMoney, model ) then
								local Moneyfix = string.Replace(model, "models/props/cs_assault/money.mdl", "Money")
									draw.SimpleText(""..Moneyfix.."", "DefaultSmall", epos.x, epos.y + 10, getcolors, 1 ,1)
								else
							end
					
							// WEAPON AND VEHICLE ESP
							if GetConVarNumber("f_entityweapon") == 1 then 
								if ent:IsWeapon() and ent:GetMoveType() !=0 or string.find( class, "prop_vehicle_" ) then
									draw.SimpleText(""..WeaponFixer.."", "DefaultSmall", epos.x, epos.y, getcolors, 1, 1)
								else
							end
						end
							
							// WEAPON WARNINGS
								if GetConVarNumber("f_entityweapon") == 1 and table.HasValue( Warnings, class ) then
									draw.SimpleText( Warningfixer, "DefaultSmall", epos.x, epos.y, getcolors, 1, 1 )
									draw.SimpleText( "D: " .. dis, "DefaultSmall", epos.x, epos.y + 10, getcolors, 1, 1 )
										if dis <= 500 then
											draw.SimpleText( "!WARNING!", "DefaultSmall", epos.x, epos.y + 20, getcolors, 1, 1 )
										end
								end
							end
						end
					end

function DrawNPCESP()
	for _, ent in pairs(ents.GetAll()) do
	if ent:IsValid() then
	local class = ent:GetClass()
			local getcolors = Color( GetConVarNumber( "f_npc_r" ), GetConVarNumber( "f_npc_g" ), GetConVarNumber( "f_npc_b" ), GetConVarNumber( "f_npc_a" ) )
					
							// NPC NAME REMOVELS
							local Name = class
							local Name1 = string.Replace(Name, "npc_", "")
							local Name2 = string.Replace(Name1, "turret_floor", " ")
							local PName = string.upper( Name2 )
							if ent:IsNPC() and ent:IsValid() then
					
							// NPC NAME ONLY
							if GetConVarNumber( "f_npc" ) == 1 then
								local npos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Pelvis")):ToScreen()
									draw.SimpleText(""..PName.."", "DefaultSmall", npos.x, npos.y, getcolors, 1, 1)
								end
								
							// NPC NAME AND CROSS
							if GetConVarNumber( "f_npc" ) == 2 then
								local hpos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1")):ToScreen()
									draw.SimpleText(PName, "DefaultSmall", hpos.x, hpos.y + 20, getcolors, 1, 1)
									surface.SetDrawColor( getcolors )
									surface.DrawLine(hpos.x, hpos.y - 10, hpos.x, hpos.y + 10)
									surface.DrawLine(hpos.x - 10, hpos.y, hpos.x + 10, hpos.y)
								end
							end
						end
					end
				end
hook.Add( "HUDPaint", "PESPE", DrawENTESP ) // DRAW ENTITY ESP
hook.Add( "HUDPaint", "PESPN", DrawNPCESP ) // DRAW NPC ESP
hook.Add( "HUDPaint", "PESP", DrawESP )		// DRAW PLAYER ESP

//__________ VISUALS ________________________________________________________________________________________________________________________________________//
function DrawVisuals()
	for _, v in pairs(ents.GetAll()) do
	
	
		// CROSSHAIR ( GREEN + BLACK )
		if GetConVarNumber("f_crosshair") == 1 then
					surface.SetDrawColor( 0, 0, 0, 255 ) // Thanks to Garry's Mod Wiki.
					surface.DrawLine( x - length, y, x - gap, y )
					surface.DrawLine( x + length, y, x + gap, y )
					surface.DrawLine( x, y - length, x, y - gap )
					surface.DrawLine( x, y + length, x, y + gap )
					surface.SetDrawColor( 0, 255, 0, 255 )
					surface.DrawLine(x, y - 5, x, y + 5)
					surface.DrawLine(x - 5, y, x + 5, y)
				end
				
		// CROSSHAIR ( RED + WHITE )
		if GetConVarNumber("f_crosshair") == 2 then
					surface.SetDrawColor( 0, 255, 0, 255 )
					surface.DrawLine( x - length, y, x - gap, y )
					surface.DrawLine( x + length, y, x + gap, y )
					surface.DrawLine( x, y - length, x, y - gap )
					surface.DrawLine( x, y + length, x, y + gap )
					surface.SetDrawColor( 255, 0, 0, 255 )
					surface.DrawLine(x, y - 5, x, y + 5)
					surface.DrawLine(x - 5, y, x + 5, y)
				end
				
		// CROSSHAIR ( SMALL WHITE )
		if GetConVarNumber("f_crosshair") == 3 then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawLine(x, y - 5, x, y + 5)
					surface.DrawLine(x - 5, y, x + 5, y)
				end
				
		// CROSSHAIR ( ONLY RED )
		if GetConVarNumber("f_crosshair") == 4 then
					surface.SetDrawColor( 255, 0, 0, 255 )
					surface.DrawLine(x, y - 10, x, y + 10)
					surface.DrawLine(x - 10, y, x + 10, y)
				end
		// CROSSHAIR ( MIDDEL DOT )
		if GetConVarNumber("f_crosshair") == 5 then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawLine(x, y - 20, x, y + 20)
					surface.DrawLine(x - 20, y, x + 20, y)
					draw.RoundedBox( 1, x - 2, y - 2, 5, 5, Color(0, 255, 0, 255) )
				end
		// SELF DYNAMIC LIGHTS
		if GetConVarNumber("f_dlights") >= 1 then
					local dlight = DynamicLight(LocalPlayer():UserID())
					dlight.Pos = LocalPlayer():GetPos()
					dlight.r = 255
					dlight.g = 255
					dlight.b = 255
					dlight.Brightness = 2 
					dlight.Size = GetConVarNumber("f_dlights")
					dlight.Decay = 0 
					dlight.DieTime = CurTime() + 0.2
				end
				
		// ALL PLAYER DYNAMIC LIGHTS
			if (v:IsPlayer()) and (v:Alive() == true) and (v:EntIndex() != LocalPlayer():EntIndex()) then 
			local col = team.GetColor( v:Team() )
				if GetConVarNumber( "f_allplydlight" ) >= 1 then
					local dlight = DynamicLight(player.GetAll() and v ~= LocalPlayer())
					dlight.Pos = v:GetPos()
					dlight.r = col.r
					dlight.g = col.g
					dlight.b = col.b
					dlight.Brightness = 1
					dlight.Size = GetConVarNumber( "f_allplydlight" )
					dlight.Decay = 100
					dlight.DieTime = CurTime() + .1
				end
			end
		end
	end
	
// CHAMS ( WIREFRAME )
function Wireframe()
	for _, v in pairs( ents.GetAll() ) do
		local class = v:GetClass()
		local model = v:GetModel()
			if GetConVarNumber( "f_chams" ) == 1 then
					if EntityValid(v) then
							if v:IsPlayer() then
								local color = team.GetColor( v:Team() )
									// hlmv/debugmrmwireframe for a wireframe
									v:SetMaterial( "PrecisionAim/material" )
									v:SetColor( color.r, color.g, color.b, 255 )
							end
						end
							if v:IsNPC() then
									v:SetMaterial( "PrecisionAim/material" )
									v:SetColor( 255, 255, 255, 255 )
								end
							if v:IsWeapon() then
									v:SetMaterial( "PrecisionAim/material" )
									v:SetColor( 255, 0, 0, 255 )
							end
						end
					end
				end

	
hook.Add( "HUDPaint", "PVIS", DrawVisuals ) 	  // VISUALS
hook.Add( "RenderScene", "WiREFRAME", Wireframe ) // WIRE FRAME
if GetConVarNumber( "f_chams" ) == 0 then 		  // DISBALBE WIREFRAME 
	hook.Remove( "RenderScene", "WiREFRAME")
		for _,v in pairs(ents.GetAll()) do
			if EntityValid(v) then
				v:SetMaterial( "" )
				v:SetColor( 255, 255, 255, 255 )
			end
		end
	end
//__________ REMOVELS _______________________________________________________________________________________________________________________________________//
function DrawRemovels(cmd, y, p)

		// NO RECOIL
		/*if GetConVarNumber("f_recoil") == 1 then
				local wep = LocalPlayer():GetActiveWeapon()
						if wep.Primary then wep.Primary.Recoil = 0.0 end
						if wep.Secondary then wep.Secondary.Recoil = 0.0 end
					else return
				end
			end
hook.Add("CalcView", "PREM", DrawRemovels)*/
end

//__________ MISC ___________________________________________________________________________________________________________________________________________//
local ms = GetConVarNumber( "f_meatspin" )
function MiscStuff(v)
for _,v in pairs(player.GetAll()) do

	// ANTI AFK
	if GetConVarNumber( "f_antiafk" ) == 1 then
		local jump = LocalPlayer():ConCommand( "+jump; wait 2; -jump" )
			draw.SimpleTextOutlined("ANTI AFK ENABLED", "PRINT_FONTXS", x, y - 330, Color(255, 0, 0, 255), 1, 1, 2, Color(0, 0, 0, 255))
				timer.Create( "timer", 10, 2, jump, ply)
		end
		
	// NAME STEALER
	if GetConVarNumber( "f_namesteal" ) == 1 then
		if (v:IsPlayer()) and (v:EntIndex() != LocalPlayer():EntIndex()) then
			RunConsoleCommand( "setinfo", "name", table.Random(player.GetAll()):Nick() .. string.char( 03 ) )
		end
		
	// BLANK NAME
	if GetConVarNumber( "f_namesteal" ) == 2 then
			RunConsoleCommand( "setinfo", "name", "~ ~~")
		end
		
	// ANNOYING SHIT
	if GetConVarNumber( "f_meatspin" ) == 1 then
		local evil = LocalPlayer():ConCommand( "kill; say i love little boys :)!!!" )
			timer.Create( "evil", 1, 0, evil, ply)
		else
		end
		
	// STOP CONSOLE SPAMMING
	if GetConVarNumber( "f_stfu" ) == 1 then
			local stop = LocalPlayer():ConCommand( "clear" )
				timer.Create( "stfupls", .5, 0,stop )
			end
		end
	end
end
hook.Add("HUDPaint", "DRAWMISC", MiscStuff)

//__________ RADAR __________________________________________________________________________________________________________________________________________//
function DrawRadar()
	if GetConVarNumber( "f_radar" ) == 1 then
		// RADAR GUI
		local ply = LocalPlayer()
		local rx = GetConVarNumber( "f_radar_x") + 100
		local ry = GetConVarNumber( "f_radar_y") + 100
		draw.RoundedBox( 6, GetConVarNumber( "f_radar_x"), GetConVarNumber( "f_radar_y"), 200, 200, Color(GetConVarNumber( "f_radar_r"), GetConVarNumber( "f_radar_g"), GetConVarNumber( "f_radar_b"), GetConVarNumber( "f_radar_a")))
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine(rx, ry - 90, rx, ry + 90)
		surface.DrawLine(rx - 90, ry, rx + 90, ry)
							
					end
				end
hook.Add("HUDPaint", "Radar", DrawRadar)
		

//__________ GUI ____________________________________________________________________________________________________________________________________________//
function SDrawMenu()

local MainMenu = vgui.Create( "DFrame" )
	MainMenu:SetPos( x - MainMenu:GetWide() - 20, y - 380  )
	MainMenu:SetSize( 200, 800 )
	MainMenu:SetTitle( hackname .. " " .. hackversion )
	MainMenu:SetVisible( true )
	MainMenu:SetDraggable( true )
	MainMenu:ShowCloseButton( true )
	MainMenu:MakePopup()
	MainMenu.Paint = function()
		draw.RoundedBox( 4, 0, 0, MainMenu:GetWide(), MainMenu:GetTall(), Color( 0, 0, 0, 0 ) )
		draw.RoundedBox( 2, 2, 2, MainMenu:GetWide() - 4, 21, Color( 0, 0, 0, 0 ) )
	end
	
local AimbotList = vgui.Create( "DCollapsibleCategory", MainMenu )
	AimbotList:SetPos( 0, 20 )
	AimbotList:SetSize( 200, 50 )
	AimbotList:SetExpanded( 0 )
	AimbotList:SetLabel( "Main Settings" )
 
local Aimbotpage = vgui.Create( "DPanelList" )
	Aimbotpage:SetAutoSize( true )
	Aimbotpage:SetSpacing( 5 )
	Aimbotpage:EnableHorizontal( false )
	Aimbotpage:EnableVerticalScrollbar( true )
	AimbotList:SetContents( Aimbotpage )

// AIMBOT SETTINGS
local AimbotS = vgui.Create("DLabel" )
	AimbotS:SizeToContents()
	AimbotS:SetText( "Aimbot Settings:" )
	AimbotS:SetTextColor( Color(255, 0, 0, 255) )
	Aimbotpage:AddItem( AimbotS )

// AIMBOT
local Aimbot = vgui.Create( "DCheckBoxLabel" )
	Aimbot:SetPos( 10,50 )
	Aimbot:SetText( "Aimbot" )
	Aimbot:SetConVar( "f_aimbot" )
	Aimbot:SizeToContents()
	Aimbotpage:AddItem( Aimbot )
	
// AUTOSHOOT
local Autoshoot = vgui.Create( "DCheckBoxLabel" )
	Autoshoot:SetPos( 10,50 )
	Autoshoot:SetText( "Autoshoot" )
	Autoshoot:SetConVar( "f_autoshoot" )
	Autoshoot:SizeToContents()
	Aimbotpage:AddItem( Autoshoot )
	
// AUTOWALL
local Autowall = vgui.Create( "DCheckBoxLabel" )
	Autowall:SetPos( 10,50 )
	Autowall:SetText( "Autowall" )
	Autowall:SetConVar( "f_autowall" )
	Autowall:SizeToContents()
	Aimbotpage:AddItem( Autowall )
	
// FRIENDLY FIRE
local FriendlyFire = vgui.Create( "DCheckBoxLabel" )
	FriendlyFire:SetPos( 10,50 )
	FriendlyFire:SetText( "Friendly Fire" )
	FriendlyFire:SetConVar( "f_ff" )
	FriendlyFire:SizeToContents()
	Aimbotpage:AddItem( FriendlyFire )
	
// AIM TARGET
local Target = vgui.Create( "DNumSlider" )
	Target:SizeToContents()
	Target:SetText( "Aim Target" )
	Target:SetMin( 0 )
	Target:SetMax( 3 )
	Target:SetDecimals( 0 )
	Target:SetConVar( "f_aimtarget" )
	Aimbotpage:AddItem( Target )

// AIM SPOT
local Aimspot = vgui.Create( "DNumSlider" )
	Aimspot:SizeToContents()
	Aimspot:SetText( "Aim Spot" )
	Aimspot:SetMin( 0 )
	Aimspot:SetMax( 14 )
	Aimspot:SetDecimals( 0 )
	Aimspot:SetConVar( "f_bone" )
	Aimbotpage:AddItem( Aimspot )
	
// AIM FOV
local FOV = vgui.Create( "DNumSlider" )
	FOV:SizeToContents()
	FOV:SetText( "Feild of View" )
	FOV:SetMin( 0 )
	FOV:SetMax( 390 )
	FOV:SetDecimals( 0 )
	FOV:SetConVar( "f_fov" )
	Aimbotpage:AddItem( FOV )
	
// ESP SETTINGS
local ESP = vgui.Create("DLabel" )
	ESP:SizeToContents()
	ESP:SetText( "Extra Sensory Settings:" )
	ESP:SetTextColor( Color(255, 0, 0, 255) )
	Aimbotpage:AddItem( ESP )

// NAME
local Name = vgui.Create( "DCheckBoxLabel" )
	Name:SetPos( 10,50 )
	Name:SetText( "Name" )
	Name:SetConVar( "f_name" )
	Name:SizeToContents()
	Aimbotpage:AddItem( Name )
	
// HEALTH
local Health = vgui.Create( "DCheckBoxLabel" )
	Health:SetPos( 10,50 )
	Health:SetText( "Health" )
	Health:SetConVar( "f_health" )
	Health:SizeToContents()
	Aimbotpage:AddItem( Health )
	
// BOX
local Box = vgui.Create( "DCheckBoxLabel" )
	Box:SetPos( 10,50 )
	Box:SetText( "Box" )
	Box:SetConVar( "f_box" )
	Box:SizeToContents()
	Aimbotpage:AddItem( Box )
	
// ENTITY
local Sandbox = vgui.Create( "DCheckBoxLabel" )
	Sandbox:SetPos( 10,50 )
	Sandbox:SetText( "Sandbox Entity's" )
	Sandbox:SetConVar( "f_entityweapon" )
	Sandbox:SizeToContents()
	Aimbotpage:AddItem( Sandbox )
	
// RP ENTITY
local Roleplay = vgui.Create( "DCheckBoxLabel" )
	Roleplay:SetPos( 10,50 )
	Roleplay:SetText( "Roleplay Entity's" )
	Roleplay:SetConVar( "f_entity" )
	Roleplay:SizeToContents()
	Aimbotpage:AddItem( Roleplay )
	
// BARREL
local Barrel = vgui.Create( "DCheckBoxLabel" )
	Barrel:SetPos( 10,50 )
	Barrel:SetText( "Barrel" )
	Barrel:SetConVar( "f_barrel" )
	Barrel:SizeToContents()
	Aimbotpage:AddItem( Barrel )
	
// INFO
local Info = vgui.Create( "DNumSlider" )
	Info:SizeToContents()
	Info:SetText( "Player Info" )
	Info:SetMin( 0 )
	Info:SetMax( 4 )
	Info:SetDecimals( 0 )
	Info:SetConVar( "f_info" )
	Aimbotpage:AddItem( Info )
	
// NPC
local NPC = vgui.Create( "DNumSlider" )
	NPC:SizeToContents()
	NPC:SetText( "NPC ESP" )
	NPC:SetMin( 0 )
	NPC:SetMax( 2 )
	NPC:SetDecimals( 0 )
	NPC:SetConVar( "f_npc" )
	Aimbotpage:AddItem( NPC )
	
// VISUAL SETTINGS
local VIS = vgui.Create("DLabel" )
	VIS:SizeToContents()
	VIS:SetText( "Visual Settings:" )
	VIS:SetTextColor( Color(255, 0, 0, 255) )
	Aimbotpage:AddItem( VIS )

// CROSSHAIR
local Crosshair = vgui.Create( "DNumSlider" )
	Crosshair:SizeToContents()
	Crosshair:SetText( "Crosshair" )
	Crosshair:SetMin( 0 )
	Crosshair:SetMax( 5 )
	Crosshair:SetDecimals( 0 )
	Crosshair:SetConVar( "f_crosshair" )
	Aimbotpage:AddItem( Crosshair )
	
// DLIGHTS
local DLights = vgui.Create( "DNumSlider" )
	DLights:SizeToContents()
	DLights:SetText( "Self Dynamic Lights" )
	DLights:SetMin( 0 )
	DLights:SetMax( 1000 )
	DLights:SetDecimals( 0 )
	DLights:SetConVar( "f_dlights" )
	Aimbotpage:AddItem( DLights )
	
// ALL DLIGHTS
local DLightss = vgui.Create( "DNumSlider" )
	DLightss:SizeToContents()
	DLightss:SetText( "All Dynamic Lights" )
	DLightss:SetMin( 0 )
	DLightss:SetMax( 1000 )
	DLightss:SetDecimals( 0 )
	DLightss:SetConVar( "f_allplydlight" )
	Aimbotpage:AddItem( DLightss )
	
// CHAMS
local Chams = vgui.Create( "DNumSlider" )
	Chams:SizeToContents()
	Chams:SetText( "Chams" )
	Chams:SetMin( 0 )
	Chams:SetMax( 1 )
	Chams:SetDecimals( 0 )
	Chams:SetConVar( "f_chams" )
	Aimbotpage:AddItem( Chams )
	
// MISC SETTINGS
local VIS = vgui.Create( "DLabel" )
	VIS:SizeToContents()
	VIS:SetText( "Miscellaneous Settings:" )
	VIS:SetTextColor( Color(255, 0, 0, 255) )
	Aimbotpage:AddItem( VIS )
	
local Recoil = vgui.Create( "DCheckBoxLabel" )
	Recoil:SetPos( 10,50 )
	Recoil:SetText( "No Recoil" )
	Recoil:SetConVar( "f_recoil" )
	Recoil:SizeToContents()
	Aimbotpage:AddItem( Recoil )
	
local AntiAFK = vgui.Create( "DCheckBoxLabel" )
	AntiAFK:SetPos( 10,50 )
	AntiAFK:SetText( "Anti AFK" )
	AntiAFK:SetConVar( "f_antiafk" )
	AntiAFK:SizeToContents()
	Aimbotpage:AddItem( AntiAFK )
	
local tRadar = vgui.Create( "DCheckBoxLabel" )
	tRadar:SetPos( 10,50 )
	tRadar:SetText( "Radar" )
	tRadar:SetConVar( "f_radar" )
	tRadar:SizeToContents()
	Aimbotpage:AddItem( tRadar )
	
local NS = vgui.Create( "DCheckBoxLabel" )
	NS:SetPos( 10,50 )
	NS:SetText( "Name Stealer" )
	NS:SetConVar( "f_namesteal" )
	NS:SizeToContents()
	Aimbotpage:AddItem( NS )


end
concommand.Add("f_menuz", SDrawMenu)
//__________ GUI ____________________________________________________________________________________________________________________________________________//
function DrawMenu()
		
local xMenu = vgui.Create( "DFrame" )
		xMenu:SetPos( ScrW() / 4.5, ScrH() / 4.5 )
		xMenu:SetSize( 610, 340 )
		xMenu:SetTitle( hackname .. " " .. hackversion )
		xMenu:SetVisible( true )
		xMenu:SetDraggable( true )
		xMenu:ShowCloseButton( true )
		xMenu:MakePopup()
		
local xIteamSheet = vgui.Create( "DPropertySheet" )
		xIteamSheet:SetParent( xMenu )
		xIteamSheet:SetPos( 10, 30 )
		xIteamSheet:SetSize( 590, 300 )


//: Aimbot
local xAimList = vgui.Create( "DPanel", xIteamSheet )
	xAimList:SetSize( x-20, y-45 )
	
local xAimbot = vgui.Create("DLabel", xAimList )
	xAimbot:SetPos( 10, 10 )
	xAimbot:SetText( "Aimbot" )
	xAimbot:SetTextColor( Color(0, 0, 0, 255) )
		local xvAimbot = vgui.Create( "DNumberWang", xAimList )
		xvAimbot:SetPos( 500, 10 )
		xvAimbot:SetMin( 0 )
		xvAimbot:SetMax( 2 )
		xvAimbot:SetDecimals( 0 )
		xvAimbot:SetConVar( "f_aimbot" )
		
local xAutoshoot = vgui.Create("DLabel", xAimList )
	xAutoshoot:SetPos( 10, 40 )
	xAutoshoot:SetText( "Autoshoot" )
	xAutoshoot:SetTextColor( Color(0, 0, 0, 255) )
		local xvAutoshoot = vgui.Create( "DNumberWang", xAimList )
		xvAutoshoot:SetPos( 500, 40 )
		xvAutoshoot:SetMin( 0 )
		xvAutoshoot:SetMax( 1 )
		xvAutoshoot:SetDecimals( 0 )
		xvAutoshoot:SetConVar( "f_autoshoot" )
		
local xAutowall = vgui.Create("DLabel", xAimList )
	xAutowall:SetPos( 10, 70 )
	xAutowall:SetText( "Auto Wall" )
	xAutowall:SetTextColor( Color(0, 0, 0, 255) )
		local xvAutoWall = vgui.Create( "DNumberWang", xAimList )
		xvAutoWall:SetPos( 500, 70 )
		xvAutoWall:SetMin( 0 )
		xvAutoWall:SetMax( 1 )
		xvAutoWall:SetDecimals( 0 )
		xvAutoWall:SetConVar( "f_autowall" )
		
local xFF = vgui.Create("DLabel", xAimList )
	xFF:SetPos( 10, 100 )
	xFF:SetText( "Friendly Fire" )
	xFF:SetTextColor( Color(0, 0, 0, 255) )
		local xvFF = vgui.Create( "DNumberWang", xAimList )
		xvFF:SetPos( 500, 100 )
		xvFF:SetMin( 0 )
		xvFF:SetMax( 1 )
		xvFF:SetDecimals( 0 )
		xvFF:SetConVar( "f_ff" )

local xAim = vgui.Create("DLabel", xAimList )
	xAim:SetPos( 10, 130 )
	xAim:SetText( "Aim Targets" )
	xAim:SetTextColor( Color(0, 0, 0, 255) )
		local xvAim = vgui.Create( "DNumberWang", xAimList )
		xvAim:SetPos( 500, 130 )
		xvAim:SetMin( 0 )
		xvAim:SetMax( 3 )
		xvAim:SetDecimals( 0 )
		xvAim:SetConVar( "f_aimtarget" )
		
local xFOV = vgui.Create("DLabel", xAimList )
	xFOV:SetPos( 10, 160 )
	xFOV:SetText( "Field of View" )
	xFOV:SetTextColor( Color(0, 0, 0, 255) )
		local xvFOV = vgui.Create( "DNumberWang", xAimList )
		xvFOV:SetPos( 500, 160 )
		xvFOV:SetMin( 0 )
		xvFOV:SetMax( 360 )
		xvFOV:SetDecimals( 0 )
		xvFOV:SetConVar( "f_fov" )
		
local xBone = vgui.Create("DLabel", xAimList )
	xBone:SetPos( 10, 190 )
	xBone:SetText( "Target Bone" )
	xBone:SetTextColor( Color(0, 0, 0, 255) )
		local xvBone = vgui.Create( "DNumberWang", xAimList )
		xvBone:SetPos( 500, 190 )
		xvBone:SetMin( 0 )
		xvBone:SetMax( 14 )
		xvBone:SetDecimals( 0 )
		xvBone:SetConVar( "f_bone" )
		
local xSmooth = vgui.Create("DLabel", xAimList )
	xSmooth:SetPos( 10, 220 )
	xSmooth:SetText( "Smooth Aim" )
	xSmooth:SetTextColor( Color(0, 0, 0, 255) )
		local xvSmooth = vgui.Create( "DNumberWang", xAimList )
		xvSmooth:SetPos( 500, 220 )
		xvSmooth:SetMin( 0 )
		xvSmooth:SetMax( 10 )
		xvSmooth:SetDecimals( 0 )
		xvSmooth:SetConVar( "f_smooth" )
	
//: ESP
local xESPList = vgui.Create( "DPanel", xIteamSheet )
	xESPList:SetSize( x-20, y-45 )
	
local xName = vgui.Create("DLabel", xESPList )
	xName:SetPos( 10, 10 )
	xName:SetText( "Name" )
	xName:SetTextColor( Color(0, 0, 0, 255) )
		local xvName = vgui.Create( "DNumberWang", xESPList )
		xvName:SetPos( 500, 10 )
		xvName:SetMin( 0 )
		xvName:SetMax( 1 )
		xvName:SetDecimals( 0 )
		xvName:SetConVar( "f_name" )
	
local xHealth = vgui.Create("DLabel", xESPList )
	xHealth:SetPos( 10, 40 )
	xHealth:SetText( "Health" )
	xHealth:SetTextColor( Color(0, 0, 0, 255) )
		local xvHealth = vgui.Create( "DNumberWang", xESPList )
		xvHealth:SetPos( 500, 40 )
		xvHealth:SetMin( 0 )
		xvHealth:SetMax( 1 )
		xvHealth:SetDecimals( 0 )
		xvHealth:SetConVar( "f_health" )
	
local xWeapon = vgui.Create("DLabel", xESPList )
	xWeapon:SetPos( 10, 70 )
	xWeapon:SetText( "Info" )
	xWeapon:SetTextColor( Color(0, 0, 0, 255) )
		local xvWeapon = vgui.Create( "DNumberWang", xESPList )
		xvWeapon:SetPos( 500, 70 )
		xvWeapon:SetMin( 0 )
		xvWeapon:SetMax( 4 )
		xvWeapon:SetDecimals( 0 )
		xvWeapon:SetConVar( "f_info" )
	
local xBox = vgui.Create("DLabel", xESPList )
	xBox:SetPos( 10, 100 )
	xBox:SetText( "Optical" )
	xBox:SetTextColor( Color(0, 0, 0, 255) )
		local xvBox = vgui.Create( "DNumberWang", xESPList )
		xvBox:SetPos( 500, 100 )
		xvBox:SetMin( 0 )
		xvBox:SetMax( 1 )
		xvBox:SetDecimals( 0 )
		xvBox:SetConVar( "f_box" )
		
local xNPC = vgui.Create("DLabel", xESPList )
	xNPC:SetPos( 10, 130 )
	xNPC:SetText( "Include NPC's" )
	xNPC:SetTextColor( Color(0, 0, 0, 255) )
		local xvNPC = vgui.Create( "DNumberWang", xESPList )
		xvNPC:SetPos( 500, 130 )
		xvNPC:SetMin( 0 )
		xvNPC:SetMax( 2 )
		xvNPC:SetDecimals( 0 )
		xvNPC:SetConVar( "f_npc" )
		
local xEntity = vgui.Create("DLabel", xESPList )
	xEntity:SetPos( 10, 160 )
	xEntity:SetText( "Roleplay" )
	xEntity:SetTextColor( Color(0, 0, 0, 255) )
		local xvEntity = vgui.Create( "DNumberWang", xESPList )
		xvEntity:SetPos( 500, 160 )
		xvEntity:SetMin( 0 )
		xvEntity:SetMax( 2 )
		xvEntity:SetDecimals( 0 )
		xvEntity:SetConVar( "f_entity" )
		
local xWeapone = vgui.Create("DLabel", xESPList )
	xWeapone:SetPos( 10, 190 )
	xWeapone:SetText( "Sandbox" )
	xWeapone:SetTextColor( Color(0, 0, 0, 255) )
		local xvWeapone = vgui.Create( "DNumberWang", xESPList )
		xvWeapone:SetPos( 500, 190 )
		xvWeapone:SetMin( 0 )
		xvWeapone:SetMax( 1 )
		xvWeapone:SetDecimals( 0 )
		xvWeapone:SetConVar( "f_entityweapon" )

//: Visuals
local xVisList = vgui.Create( "DPanel", xIteamSheet )
	xVisList:SetSize( x-20, y-45 )
	
local xCrosshair = vgui.Create("DLabel", xVisList )
	xCrosshair:SetPos( 10, 10 )
	xCrosshair:SetText( "Crosshair" )
	xCrosshair:SetTextColor( Color(0, 0, 0, 255) )
		local xvCrosshair = vgui.Create( "DNumberWang", xVisList )
		xvCrosshair:SetPos( 500, 10 )
		xvCrosshair:SetMin( 0 )
		xvCrosshair:SetMax( 5 )
		xvCrosshair:SetDecimals( 0 )
		xvCrosshair:SetConVar( "f_crosshair" )
		
local xDL = vgui.Create("DLabel", xVisList )
	xDL:SetPos( 10, 40 )
	xDL:SetText( "Dynamic Lights" )
	xDL:SetTextColor( Color(0, 0, 0, 255) )
		local xvDL = vgui.Create( "DNumberWang", xVisList )
		xvDL:SetPos( 500, 40 )
		xvDL:SetMin( 0 )
		xvDL:SetMax( 1000 )
		xvDL:SetDecimals( 0 )
		xvDL:SetConVar( "f_dlights" )
		
local xDLS = vgui.Create("DLabel", xVisList )
	xDLS:SetPos( 10, 70 )
	xDLS:SetText( "All DLights" )
	xDLS:SetTextColor( Color(0, 0, 0, 255) )
		local xvDLS = vgui.Create( "DNumberWang", xVisList )
		xvDLS:SetPos( 500, 70 )
		xvDLS:SetMin( 0 )
		xvDLS:SetMax( 1 )
		xvDLS:SetDecimals( 0 )
		xvDLS:SetConVar( "f_allplydlight" )

local xCham = vgui.Create("DLabel", xVisList )
	xCham:SetPos( 10, 100 )
	xCham:SetText( "Cham" )
	xCham:SetTextColor( Color(0, 0, 0, 255) )
		local xvCham = vgui.Create( "DNumberWang", xVisList )
		xvCham:SetPos( 500, 100 )
		xvCham:SetMin( 0 )
		xvCham:SetMax( 2 )
		xvCham:SetDecimals( 0 )
		xvCham:SetConVar( "f_chams" )

local xBarrel = vgui.Create("DLabel", xVisList )
	xBarrel:SetPos( 10, 130 )
	xBarrel:SetText( "Barrel" )
	xBarrel:SetTextColor( Color(0, 0, 0, 255) )
		local xvBarrel = vgui.Create( "DNumberWang", xVisList )
		xvBarrel:SetPos( 500, 130 )
		xvBarrel:SetMin( 0 )
		xvBarrel:SetMax( 1 )
		xvBarrel:SetDecimals( 0 )
		xvBarrel:SetConVar( "f_barrel" )

//: Removels
local xRemList = vgui.Create( "DPanel", xIteamSheet )
	xRemList:SetSize( x-20, y-45 )
	
local xRecoil = vgui.Create("DLabel", xRemList )
	xRecoil:SetPos( 10, 10 )
	xRecoil:SetText( "No Recoil" )
	xRecoil:SetTextColor( Color(0, 0, 0, 255) )
		local xvRecoil = vgui.Create( "DNumberWang", xRemList )
		xvRecoil:SetPos( 500, 10 )
		xvRecoil:SetMin( 0 )
		xvRecoil:SetMax( 1 )
		xvRecoil:SetDecimals( 0 )
		xvRecoil:SetConVar( "f_recoil" )
		
//: Misc/Other
local xOthList = vgui.Create( "DPanel", xIteamSheet )
	xOthList:SetSize( x-20, y-45 )
	
local xAF = vgui.Create("DLabel", xOthList )
	xAF:SetPos( 10, 10 )
	xAF:SetText( "Anti AFK" )
	xAF:SetTextColor( Color(0, 0, 0, 255) )
		local xvAF = vgui.Create( "DNumberWang", xOthList )
		xvAF:SetPos( 500, 10 )
		xvAF:SetMin( 0 )
		xvAF:SetMax( 1 )
		xvAF:SetDecimals( 0 )
		xvAF:SetConVar( "f_antiafk" )

local AdminText = CreateClientConVar( "f_admintext", "Name here.", true, false)
local xNS = vgui.Create("DLabel", xOthList )
	xNS:SetPos( 10, 70 )
	xNS:SetText( "Name Stealer" )
	xNS:SetTextColor( Color(0, 0, 0, 255) )
		local xvNS = vgui.Create( "DNumberWang", xOthList )
		xvNS:SetPos( 500, 70 )
		xvNS:SetMin( 0 )
		xvNS:SetMax( 3 )
		xvNS:SetDecimals( 0 )
		xvNS:SetConVar( "f_namesteal" )
			local xSpamx = vgui.Create("DTextEntry", xOthList, "Message")  
			xSpamx:SetSize( 140, 20)  
			xSpamx:SetPos( 350, 70)  
			xSpamx:SetKeyboardInputEnabled( true )  
			xSpamx:SetEnabled( true )   
			xSpamx.MessageBox = AdminText:GetString()
			xSpamx:SetConVar( "f_admintext" )
			
		function ChangeName()
			if GetConVarNumber( "f_admintext" ) == 3 then
				RunConsoleCommand( "setinfo", "name", timer.Simple( 1, AdminText:GetString() ).."~ ~~" )
			end
		end
		hook.Add( "Think", "Admin", ChangeName)
		
local xM = vgui.Create("DLabel", xOthList )
	xM:SetPos( 10, 40 )
	xM:SetText( "Server Crash" )
	xM:SetTextColor( Color(0, 0, 0, 255) )
		local xvM = vgui.Create( "DNumberWang", xOthList )
		xvM:SetPos( 500, 40 )
		xvM:SetMin( 0 )
		xvM:SetMax( 1 )
		xvM:SetDecimals( 0 )
		xvM:SetConVar( "f_meatspin" )
		
local SpamText = CreateClientConVar( "f_spamtext", "Enter text here.", true, false)
local xMS = vgui.Create("DLabel", xOthList )
	xMS:SetPos( 10, 100 )
	xMS:SetText( "Spam" )
	xMS:SetTextColor( Color(0, 0, 0, 255) )
		local xvMS = vgui.Create( "DNumberWang", xOthList )
		xvMS:SetPos( 500, 100 )
		xvMS:SetMin( 0 )
		xvMS:SetMax( 1 )
		xvMS:SetDecimals( 0 )
		xvMS:SetConVar( "f_spam" )
			local xSpam = vgui.Create("DTextEntry", xOthList, "Message")  
			xSpam:SetSize( 140, 20)  
			xSpam:SetPos( 350, 100)  
			xSpam:SetKeyboardInputEnabled( true )  
			xSpam:SetEnabled( true )   
			xSpam.MessageBox = SpamText:GetString()
			xSpam:SetConVar( "f_spamtext" )
			
		function Spam()
			if GetConVarNumber( "f_spam" ) == 1 then
				timer.Create("spam", .5, 1, LocalPlayer():ConCommand( "say "..SpamText:GetString()))
			end
		end
	hook.Add("Think", "Spam", Spam)
		
//: Colors 
local xColList = vgui.Create( "DPanel", xIteamSheet )
	xColList:SetSize( x-20, y-45 )

// Entity Colors
local xEnt = vgui.Create("DLabel", xColList )
xEnt:SetPos( 80, 25 )
xEnt:SetText( "~ Entity ~" )
xEnt:SetTextColor( Color(0, 0, 0, 255) )

local xxRed = vgui.Create( "DNumSlider", xColList )
xxRed:SetPos( 10, 50 )
xxRed:SetWide( 200 )
xxRed:SetText( "" )
xxRed:SetMin( 0 )
xxRed:SetMax( 255 )
xxRed:SetDecimals( 0 )
xxRed:SetConVar( "f_entitycol_r" )
	local xRed = vgui.Create("DLabel", xColList )
	xRed:SetPos( 10, 50 )
	xRed:SetText( "Red" )
	xRed:SetTextColor( Color(0, 0, 0, 255) )
 
 local xxGreen = vgui.Create( "DNumSlider", xColList )
xxGreen:SetPos( 10, 100 )
xxGreen:SetWide( 200 )
xxGreen:SetText( "" )
xxGreen:SetMin( 0 )
xxGreen:SetMax( 255 )
xxGreen:SetDecimals( 0 )
xxGreen:SetConVar( "f_entitycol_g" )
	local xGreen = vgui.Create("DLabel", xColList )
	xGreen:SetPos( 10, 100 )
	xGreen:SetText( "Green" )
	xGreen:SetTextColor( Color(0, 0, 0, 255) )

 
 local xxBlue = vgui.Create( "DNumSlider", xColList )
xxBlue:SetPos( 10, 150 )
xxBlue:SetWide( 200 )
xxBlue:SetText( "" )
xxBlue:SetMin( 0 )
xxBlue:SetMax( 255 )
xxBlue:SetDecimals( 0 )
xxBlue:SetConVar( "f_entitycol_b" )
	local xBlue = vgui.Create("DLabel", xColList )
	xBlue:SetPos( 10, 150 )
	xBlue:SetText( "Blue" )
	xBlue:SetTextColor( Color(0, 0, 0, 255) )

local xxAlpha = vgui.Create( "DNumSlider", xColList )
xxAlpha:SetPos( 10, 200 )
xxAlpha:SetWide( 200 )
xxAlpha:SetText( "" )
xxAlpha:SetMin( 0 )
xxAlpha:SetMax( 255 )
xxAlpha:SetDecimals( 0 )
xxAlpha:SetConVar( "f_entitycol_a" )
	local xAlpha = vgui.Create("DLabel", xColList )
	xAlpha:SetPos( 10, 200 )
	xAlpha:SetText( "Alpha" )
	xAlpha:SetTextColor( Color(0, 0, 0, 255) )
	
// NPC Colors
local xNPC = vgui.Create("DLabel", xColList )
xNPC:SetPos( 450, 25 )
xNPC:SetText( "~ NPC ~" )
xNPC:SetTextColor( Color(0, 0, 0, 255) )

local xxxRed = vgui.Create( "DNumSlider", xColList )
xxxRed:SetPos( 370, 50 )
xxxRed:SetWide( 200 )
xxxRed:SetText( "" )
xxxRed:SetMin( 0 )
xxxRed:SetMax( 255 )
xxxRed:SetDecimals( 0 )
xxxRed:SetConVar( "f_npc_r" )
	local xxxxRed = vgui.Create("DLabel", xColList )
	xxxxRed:SetPos( 370, 50 )
	xxxxRed:SetText( "Red" )
	xxxxRed:SetTextColor( Color(0, 0, 0, 255) )
 
 local xxxGreen = vgui.Create( "DNumSlider", xColList )
xxxGreen:SetPos( 370, 100 )
xxxGreen:SetWide( 200 )
xxxGreen:SetText( "" )
xxxGreen:SetMin( 0 )
xxxGreen:SetMax( 255 )
xxxGreen:SetDecimals( 0 )
xxxGreen:SetConVar( "f_npc_g" )
	local xxxxGreen = vgui.Create("DLabel", xColList )
	xxxxGreen:SetPos( 370, 100 )
	xxxxGreen:SetText( "Green" )
	xxxxGreen:SetTextColor( Color(0, 0, 0, 255) )

 
 local xxxBlue = vgui.Create( "DNumSlider", xColList )
xxxBlue:SetPos( 370, 150 )
xxxBlue:SetWide( 200 )
xxxBlue:SetText( "" )
xxxBlue:SetMin( 0 )
xxxBlue:SetMax( 255 )
xxxBlue:SetDecimals( 0 )
xxxBlue:SetConVar( "f_npc_b" )
	local xxxxBlue = vgui.Create("DLabel", xColList )
	xxxxBlue:SetPos( 370, 150 )
	xxxxBlue:SetText( "Blue" )
	xxxxBlue:SetTextColor( Color(0, 0, 0, 255) )

local xxxAlpha = vgui.Create( "DNumSlider", xColList )
xxxAlpha:SetPos( 370, 200 )
xxxAlpha:SetWide( 200 )
xxxAlpha:SetText( "" )
xxxAlpha:SetMin( 0 )
xxxAlpha:SetMax( 255 )
xxxAlpha:SetDecimals( 0 )
xxxAlpha:SetConVar( "f_npc_a" )
	local xxxxAlpha = vgui.Create("DLabel", xColList )
	xxxxAlpha:SetPos( 370, 200 )
	xxxxAlpha:SetText( "Alpha" )
	xxxxAlpha:SetTextColor( Color(0, 0, 0, 255) )

//: Extra Settings
local xExtList = vgui.Create( "DPanel", xIteamSheet )
	xExtList:SetSize( x-20, y-45 )
	
local xDISMAX = vgui.Create( "DNumSlider", xExtList )
xDISMAX:SetPos( 10, 10 )
xDISMAX:SetSize( 560, 100 )
xDISMAX:SetText( "" )
xDISMAX:SetMin( 0 )
xDISMAX:SetMax( 20000 )
xDISMAX:SetDecimals( 0 )
xDISMAX:SetConVar( "f_dismax" )
	local xDISMAXL = vgui.Create("DLabel", xExtList )
	xDISMAXL:SetPos( 10, 10 )
	xDISMAXL:SetText( "Distance Max" )
	xDISMAXL:SetTextColor( Color(0, 0, 0, 255) )
	
//: Radar
local xRadList = vgui.Create( "DPanel", xIteamSheet )
	xRadList:SetSize( x-20, y-45 )
	
// Radar Color
local xRadar = vgui.Create("DLabel", xRadList )
xRadar:SetPos( 80, 25 )
xRadar:SetText( "~ Radar ~" )
xRadar:SetTextColor( Color(0, 0, 0, 255) )

local ccRed = vgui.Create( "DNumSlider", xRadList )
ccRed:SetPos( 10, 50 )
ccRed:SetWide( 200 )
ccRed:SetText( "" )
ccRed:SetMin( 0 )
ccRed:SetMax( 255 )
ccRed:SetDecimals( 0 )
ccRed:SetConVar( "f_radar_r" )
	local cRed = vgui.Create("DLabel", xRadList )
	cRed:SetPos( 10, 50 )
	cRed:SetText( "Red" )
	cRed:SetTextColor( Color(0, 0, 0, 255) )
 
 local ccGreen = vgui.Create( "DNumSlider", xRadList )
ccGreen:SetPos( 10, 100 )
ccGreen:SetWide( 200 )
ccGreen:SetText( "" )
ccGreen:SetMin( 0 )
ccGreen:SetMax( 255 )
ccGreen:SetDecimals( 0 )
ccGreen:SetConVar( "f_radar_g" )
	local cGreen = vgui.Create("DLabel", xRadList )
	cGreen:SetPos( 10, 100 )
	cGreen:SetText( "Green" )
	cGreen:SetTextColor( Color(0, 0, 0, 255) )

 
 local ccBlue = vgui.Create( "DNumSlider", xRadList )
ccBlue:SetPos( 10, 150 )
ccBlue:SetWide( 200 )
ccBlue:SetText( "" )
ccBlue:SetMin( 0 )
ccBlue:SetMax( 255 )
ccBlue:SetDecimals( 0 )
ccBlue:SetConVar( "f_radar_b" )
	local cBlue = vgui.Create("DLabel", xRadList )
	cBlue:SetPos( 10, 150 )
	cBlue:SetText( "Blue" )
	cBlue:SetTextColor( Color(0, 0, 0, 255) )

local ccAlpha = vgui.Create( "DNumSlider", xRadList )
ccAlpha:SetPos( 10, 200 )
ccAlpha:SetWide( 200 )
ccAlpha:SetText( "" )
ccAlpha:SetMin( 0 )
ccAlpha:SetMax( 255 )
ccAlpha:SetDecimals( 0 )
ccAlpha:SetConVar( "f_radar_a" )
	local cAlpha = vgui.Create("DLabel", xRadList )
	cAlpha:SetPos( 10, 200 )
	cAlpha:SetText( "Alpha" )
	cAlpha:SetTextColor( Color(0, 0, 0, 255) )
	
local ccX = vgui.Create( "DNumSlider", xRadList )
ccX:SetPos( 250, 150 )
ccX:SetWide( 200 )
ccX:SetText( "" )
ccX:SetMin( 0 )
ccX:SetMax( ScrW() )
ccX:SetDecimals( 0 )
ccX:SetConVar( "f_radar_x" )
	local cX = vgui.Create("DLabel", xRadList )
	cX:SetPos( 250, 150 )
	cX:SetText( "Radar X" )
	cX:SetTextColor( Color(0, 0, 0, 255) )
	
local ccY = vgui.Create( "DNumSlider", xRadList )
ccY:SetPos( 250, 200 )
ccY:SetWide( 200 )
ccY:SetText( "" )
ccY:SetMin( 0 )
ccY:SetMax( ScrH() )
ccY:SetDecimals( 0 )
ccY:SetConVar( "f_radar_y" )
	local cY = vgui.Create("DLabel", xRadList )
	cY:SetPos( 250, 200 )
	cY:SetText( "Radar Y" )
	cY:SetTextColor( Color(0, 0, 0, 255) )
	
local xRadar = vgui.Create( "DCheckBoxLabel", xRadList)
xRadar:SetPos( 250, 25 )
xRadar:SetText( "Radar" )
xRadar:SetConVar( "f_radar" )
xRadar:SetTextColor( Color(0, 0, 0, 255) )
xRadar:SizeToContents()

Msg(hackname .. " " .. message .. " " .. myname .. "\n")
xIteamSheet:AddSheet( "Aimbot", xAimList, "gui/silkicons/shield", false, false, "Automatic Aiming" )
xIteamSheet:AddSheet( "ESP", xESPList, "gui/silkicons/group", false, false, "Extra Sensory Perception" )
xIteamSheet:AddSheet( "Visuals", xVisList, "gui/silkicons/star", false, false, "Player Visuals, Chams, Crosshair..." )
xIteamSheet:AddSheet( "Removels", xRemList, "gui/silkicons/bomb", false, false, "No-Recoil." )
xIteamSheet:AddSheet( "Miscellaneous", xOthList, "gui/silkicons/plugin", false, false, "Other features..." )
xIteamSheet:AddSheet( "Colors", xColList, "gui/silkicons/wrench", false, false, "Ajust Colors with Entity's and NPC's." )
xIteamSheet:AddSheet( "Extra Settings", xExtList, "gui/silkicons/box", false, false, "Other Settings for features." )
xIteamSheet:AddSheet( "Radar", xRadList, "gui/silkicons/box", false, false, "Radar settings." )
end

concommand.Add("f_menu", DrawMenu)
local removePESP = CreateClientConVar( "h_remove_player_esp", 0, true, false )
local removePNPC = CreateClientConVar( "h_remove_npc_esp", 0, true, false )
local removePENT = CreateClientConVar( "h_remove_entity_esp", 0, true, false )
function removehooks()
if removePESP:GetInt() == 1 then
		hook.Remove( "HUDPaint", "PESP" )
	end
if removePNPC:GetInt() == 1 then
		hook.Remove( "HUDPaint", "PESPN" )
	end
if removePENT:GetInt() == 1 then
		hook.Remove( "HUDPaint", "PESPE" )
	end
end