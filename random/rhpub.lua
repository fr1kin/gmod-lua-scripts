/*____________________________________________________________
Scripter: fr1kin
Detections: Script Enforcer + Thirdparty anti-cheats
Shoutouts: Thatguy, Chadywady, Eusion
____________________________________________________________*/

/*____________________________________________________________
Main Code
____________________________________________________________*/
if ( SERVER ) then return end

-- Aimbot Commands: ========================================================================================================================

local Aimbot = true
local Autoshoot = true
local AimBone = ( 14 )
local AimFOV = ( 360 )

--  ========================================================================================================================================

-- ESP Commands: ===========================================================================================================================

-- Player:
local Name = CreateClientConVar("rh_name", 0, true, false)
local Health = CreateClientConVar("rh_health", 0, true, false)
local Weapon = CreateClientConVar("rh_weapon", 0, true, false)
local Armor = CreateClientConVar("rh_armor", 0, true, false)
local Class = CreateClientConVar("rh_class", 0, true, false)
local Box = CreateClientConVar("rh_box", 0, true, false)
local Admin = CreateClientConVar("rh_admin", 0, true, false)

-- NPC:
local NPC = CreateClientConVar("rh_npc", 0, true, false)
local NPCName = CreateClientConVar("rh_npcname", 0, true, false)
local NPCHeadM = CreateClientConVar("rh_npcheadmarker", 0, true, false)

-- Entity:
local Entity = CreateClientConVar("rh_entity", 0, true, false)
local RPEntitys = {"money_printer", "drug_lab", "drug", "microwave", "food", "gunlab", "spawned_shipment", "spawned_food", "spawned_weapon"}

-- Yourself:
local MyInfoName = CreateClientConVar("rh_myinfoname", 0, true, false)
local MyInfoHP = CreateClientConVar("rh_myinfohp", 0, true, false)
local MyInfoWeapon = CreateClientConVar("rh_myinfoweapon", 0, true, false)

-- Visual Commands:  ========================================================================================================================

local Crosshair = CreateClientConVar("rh_crosshair", 0, true, false)
local DLights = CreateClientConVar("rh_dlights", 0, true, false)
local Cham = true
local DrawFOV = true

--  =========================================================================================================================================

-- Removel Commands: ========================================================================================================================

local NoRecoil = true
local NoSpread = true

--  =========================================================================================================================================

-- Misc Commands:  ==========================================================================================================================

local BunnyHop = true
local Autopistol = true
local ToggleCOL = CreateClientConVar("rh_togglecolors", 0, true, false) -- toggles white/teamcolors

--  =========================================================================================================================================

-- Admin Function: ==========================================================================================================================
local function PlayerAdminSuper(v)
if v:IsAdmin() and not v:IsSuperAdmin() then return "*Admin*"
elseif v:IsSuperAdmin() then return "*Super Admin*"
elseif not v:IsAdmin() and not v:IsSuperAdmin() then return "Player" 
end
end
-- ==========================================================================================================================================

-- Toggle Color: ============================================================================================================================
local function ToggleColorButton()
if ToggleCOL:GetInt() >= 1 then
Color(255, 255, 255, 255)
if ToggleCOL:GetInt() <= 0 then
team.GetColor(v:Team())
end
end
end
-- ==========================================================================================================================================

-- Misc Commands: ===========================================================================================================================
-- Screen:
local w, h = ScrW() / 2, ScrH() / 2

-- Fonts:
surface.CreateFont( "Coolvetica", 28, 400, true, false, "INFO_TEXT" )

-- Colors:
local rBlack = Color(0, 0, 0, 255)
local rPurple = Color(234, 4, 217, 255)

-- Other:
-- ==========================================================================================================================================
/*____________________________________________________________
Aimbot Code
____________________________________________________________*/
/*____________________________________________________________
ESP Code
____________________________________________________________*/
local function RHESP_Player()
for k,v in pairs(player.GetAll()) do
-- Commands:
-- Fix:
if v:GetActiveWeapon():IsValid() then

-- CMD's:
local rTeamColor = team.GetColor(v:Team())
local rTeamName = team.GetName(v:Team())
local rGetWeapon = v:GetActiveWeapon():GetPrintName()
local rPlayer = v:IsPlayer()
local rAlive = v:Alive()
-- Now we start:
if (rPlayer) and (v:Alive()== true) and (v:IsValid()) then
local pos = v:GetPos() + Vector(0, 0, -20)
pos = pos:ToScreen()
-- Player ESP: ===============================================================================================================================
	-- Admin ESP:
	if Admin:GetInt() >= 1 then
		draw.SimpleTextOutlined(PlayerAdminSuper(v), "DefaultSmall", pos.x, pos.y, Color(255, 0, 0, 255), 1, 1, 1, rBlack)
	end
	-- Name ESP:
	if Name:GetInt() >= 1 then
		draw.SimpleTextOutlined("Name: "..v:Nick(), "DefaultSmall", pos.x, pos.y+10, rTeamColor, 1, 1, 1, rBlack)
	end
	-- Weapon ESP:
	if Weapon:GetInt() >= 1 then
		draw.SimpleTextOutlined("Weapon: ".. rGetWeapon, "DefaultSmall", pos.x, pos.y+20, rTeamColor, 1, 1, 1, rBlack)
	end
	-- Health ESP:
	if Health:GetInt() >= 1 then
		draw.SimpleTextOutlined("Health: "..v:Health(), "DefaultSmall", pos.x, pos.y+30, rTeamColor, 1, 1, 1, rBlack)
	end
	-- Armor ESP:
	if Armor:GetInt() >= 1 then
		draw.SimpleTextOutlined("Armor: "..v:Armor(), "DefaultSmall", pos.x, pos.y+40, rTeamColor, 1, 1, 1, rBlack)
	end
	-- Class ESP:
	if Class:GetInt() >= 1 then
		draw.SimpleTextOutlined("Class: "..rTeamName, "DefaultSmall", pos.x, pos.y+50, rTeamColor, 1, 1, 1, rBlack)
	end
-- Box ESP. I DID NOT MAKE THIS IMA RECODE IT LATER.
local center = v:LocalToWorld(v:OBBCenter())
local min,max = v:WorldSpaceAABB()
local dim = max-min
if Box:GetInt() >= 1 then
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

surface.SetDrawColor(rTeamColor.r, rTeamColor.g, rTeamColor.b, 255)

surface.DrawLine(xmax,ymax,xmax,ymin)
surface.DrawLine(xmax,ymin,xmin,ymin)
surface.DrawLine(xmin,ymin,xmin,ymax)
surface.DrawLine(xmin,ymax,xmax,ymax)
end
end
end
end
end
-- Player ESP End: ===========================================================================================================================

-- MyInfo ESP: ===============================================================================================================================
local function RHESP_Self()
-- Commands:
local rSelf = LocalPlayer()
-- Now we start:
	if MyInfoName:GetInt() >= 1 then
		draw.SimpleTextOutlined("Your Name: ".. rSelf:Nick(), "INFO_TEXT", w, h+390, Color(255, 0, 0, 255), 1, 1, 2, Color(0, 0, 0, 255))
	end
	if MyInfoHP:GetInt() >= 1 then
		draw.SimpleTextOutlined("Your Health: ".. rSelf:Health(), "INFO_TEXT", w, h+420, Color(255, 0, 0, 255), 1, 1, 2, Color(0, 0, 0, 255))
	end
	if MyInfoWeapon:GetInt() >= 1 then
		draw.SimpleTextOutlined("Your Weapon: ".. rSelf:GetActiveWeapon():GetPrintName(), "INFO_TEXT", w, h+450, Color(255, 0, 0, 255), 1, 1, 2, Color(0, 0, 0, 255))
	end
end
-- MyInfo ESP End: ==========================================================================================================================

-- NPC ESP: =================================================================================================================================
local function RHESP_NPC()
for _, v in pairs(ents.GetAll()) do
-- Now we start:
if (v:IsNPC()) and (v:IsValid()) then
local pos1 = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1")):ToScreen() -- thanks nbot guy
-- NPC ESP:
	-- Draw Text:
	if NPC:GetInt() >= 1 then
		draw.SimpleTextOutlined("!NPC!", "DefaultSmall", pos1.x, pos1.y+20, rPurple, 1, 1, 1, rBlack)
	end
	-- Name:
	if NPCName:GetInt() >= 1 then
		draw.SimpleTextOutlined(v:GetClass(), "DefaultSmall", pos1.x, pos1.y+30, rPurple, 1, 1, 1, rBlack)
	end
	-- Head Marker:
	if NPCHeadM:GetInt() >= 1 then
	surface.SetDrawColor(rPurple)
	surface.DrawLine(pos1.x, pos1.y - 10, pos1.x, pos1.y + 10)
	surface.DrawLine(pos1.x - 10, pos1.y, pos1.x + 10, pos1.y)
	end
end
end
end
-- NPC ESP End: =============================================================================================================================

-- Entity ESP: ==============================================================================================================================
local function RHESP_Entity()
for _, v in pairs(ents.GetAll()) do
-- Entity ESP:
	if Entity:GetInt() >= 1 then

end
end
end
-- Entity ESP End: ==========================================================================================================================
hook.Add("HUDPaint", "RHESPply", RHESP_Player)
hook.Add("HUDPaint", "RHESPself", RHESP_Self)
hook.Add("HUDPaint", "RHESPnpc", RHESP_NPC)
hook.Add("HUDPaint", "RHESPentity", RHESP_Entity)
/*____________________________________________________________
Visual Code
____________________________________________________________*/
local function RHVisuals()
-- Crosshair
if Crosshair:GetInt() >= 1 then
surface.SetDrawColor(0, 255, 0, 255)
surface.DrawLine(w, h - 5, w, h + 5)
surface.DrawLine(w - 5, h, w + 5, h)
end
-- Dynamic Lights
if DLights:GetInt() >= 1 then -- I want to add them for all players but it lag you like shit. NOTE this will also lag when your in part light and part dark.
local self = LocalPlayer()
local ddlights = DynamicLight(self:IsValid())
ddlights.Pos = self:GetPos()
ddlights.r = 255
ddlights.g = 255
ddlights.b = 255
ddlights.Brightness = 1
ddlights.Size = 500
ddlights.Decay = 0
ddlights.DieTime = CurTime() + .1
-- Admin List
end
end
hook.Add("HUDPaint", "RHVisuals", RHVisuals)
/*____________________________________________________________
Removel Code
____________________________________________________________*/
/*____________________________________________________________
Menu Code
____________________________________________________________*/
local function RHMenu()

local RHHackMenu = vgui.Create( "DFrame" )
RHHackMenu:SetPos( 400, 350  )
RHHackMenu:SetSize( 500, 300 )
RHHackMenu:SetTitle( "ReflexHack v1.0.0 - Menu" )
RHHackMenu:SetVisible( true )
RHHackMenu:SetDraggable( true )
RHHackMenu:ShowCloseButton( true )
RHHackMenu:MakePopup()
local w = RHHackMenu:GetWide()
local h =  RHHackMenu:GetTall()

local PropertySheet = vgui.Create( "DPropertySheet" )
PropertySheet:SetParent( RHHackMenu )
PropertySheet:SetPos( 5, 25 )
PropertySheet:SetSize( 490, 270 )

-- Aimbot
local UserAim = vgui.Create( "DPanel", PropertySheet )
UserAim:SetSize( w-20, h-45 )
UserAim.Paint = function()
end

local RHCheckBoxAimbot = vgui.Create( "DCheckBoxLabel", UserAim )
RHCheckBoxAimbot:SetPos( 10, 10 )
RHCheckBoxAimbot:SetText( "Aimbot" )
RHCheckBoxAimbot:SetConVar( "" )
RHCheckBoxAimbot:SetValue( 1 )
RHCheckBoxAimbot:SizeToContents()

local RHCheckBoxAutoshoot = vgui.Create( "DCheckBoxLabel", UserAim )
RHCheckBoxAutoshoot:SetPos( 10, 30 )
RHCheckBoxAutoshoot:SetText( "Autoshoot" )
RHCheckBoxAutoshoot:SetConVar( "" )
RHCheckBoxAutoshoot:SetValue( 1 )
RHCheckBoxAutoshoot:SizeToContents()

local RHCheckBoxTrigger = vgui.Create( "DCheckBoxLabel", UserAim )
RHCheckBoxTrigger:SetPos( 10, 50 )
RHCheckBoxTrigger:SetText( "Triggerbot" )
RHCheckBoxTrigger:SetConVar( "" )
RHCheckBoxTrigger:SetValue( 1 )
RHCheckBoxTrigger:SizeToContents()

local RHCheckBoxAimbotWeapon = vgui.Create( "DCheckBoxLabel", UserAim )
RHCheckBoxAimbotWeapon:SetPos( 10, 70 )
RHCheckBoxAimbotWeapon:SetText( "All Weapons" )
RHCheckBoxAimbotWeapon:SetConVar( "" )
RHCheckBoxAimbotWeapon:SetValue( 1 )
RHCheckBoxAimbotWeapon:SizeToContents()

local RHCheckBoxAimbotPlayer = vgui.Create( "DCheckBoxLabel", UserAim )
RHCheckBoxAimbotPlayer:SetPos( 10, 90 )
RHCheckBoxAimbotPlayer:SetText( "Aim at Players" )
RHCheckBoxAimbotPlayer:SetConVar( "" )
RHCheckBoxAimbotPlayer:SetValue( 1 )
RHCheckBoxAimbotPlayer:SizeToContents()

local RHCheckBoxAimbotNPC = vgui.Create( "DCheckBoxLabel", UserAim )
RHCheckBoxAimbotNPC:SetPos( 10, 110 )
RHCheckBoxAimbotNPC:SetText( "Aim at NPC's" )
RHCheckBoxAimbotNPC:SetConVar( "" )
RHCheckBoxAimbotNPC:SetValue( 1 )
RHCheckBoxAimbotNPC:SizeToContents()

local RHCheckBoxAimbotRE = vgui.Create( "DCheckBoxLabel", UserAim )
RHCheckBoxAimbotRE:SetPos( 10, 130 )
RHCheckBoxAimbotRE:SetText( "Disable on Reload" )
RHCheckBoxAimbotRE:SetConVar( "" )
RHCheckBoxAimbotRE:SetValue( 1 )
RHCheckBoxAimbotRE:SizeToContents()


local RHSliderBone = vgui.Create( "DNumSlider", UserAim )
RHSliderBone:SetPos( 10, 150 )
RHSliderBone:SetSize( 450, 200 )
RHSliderBone:SetText( "Aim Bone" )
RHSliderBone:SetMin( 0 )
RHSliderBone:SetMax( 14 )
RHSliderBone:SetDecimals( 0 )
RHSliderBone:SetConVar( "" )

local RHSliderFOV = vgui.Create( "DNumSlider", UserAim )
RHSliderFOV:SetPos( 10, 200 )
RHSliderFOV:SetSize( 450, 200 )
RHSliderFOV:SetText( "Field of View" )
RHSliderFOV:SetMin( 0 )
RHSliderFOV:SetMax( 360 )
RHSliderFOV:SetDecimals( 0 )
RHSliderFOV:SetConVar( "" )

-- ESP
local UserESP = vgui.Create( "DPanel", PropertySheet )
UserESP:SetSize( w-20, h-45 )
UserESP.Paint = function()
end

local RHCheckBoxESPName = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPName:SetPos( 10, 30 )
RHCheckBoxESPName:SetText( "Name" )
RHCheckBoxESPName:SetConVar( "rh_name" )
RHCheckBoxESPName:SetValue( 1 )
RHCheckBoxESPName:SizeToContents()

local RHCheckBoxESPHealth = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPHealth:SetPos( 10, 50 )
RHCheckBoxESPHealth:SetText( "Health" )
RHCheckBoxESPHealth:SetConVar( "rh_health" )
RHCheckBoxESPHealth:SetValue( 1 )
RHCheckBoxESPHealth:SizeToContents()

local RHCheckBoxESPWeapon = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPWeapon:SetPos( 10, 70 )
RHCheckBoxESPWeapon:SetText( "Weapon" )
RHCheckBoxESPWeapon:SetConVar( "rh_weapon" )
RHCheckBoxESPWeapon:SetValue( 1 )
RHCheckBoxESPWeapon:SizeToContents()

local RHCheckBoxESPClass = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPClass:SetPos( 10, 90 )
RHCheckBoxESPClass:SetText( "Class" )
RHCheckBoxESPClass:SetConVar( "rh_class" )
RHCheckBoxESPClass:SetValue( 1 )
RHCheckBoxESPClass:SizeToContents()

local RHCheckBoxESPArmor = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPArmor:SetPos( 10, 110 )
RHCheckBoxESPArmor:SetText( "Armor" )
RHCheckBoxESPArmor:SetConVar( "rh_armor" )
RHCheckBoxESPArmor:SetValue( 1 )
RHCheckBoxESPArmor:SizeToContents()

local RHCheckBoxESPBox = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPBox:SetPos( 10, 130 )
RHCheckBoxESPBox:SetText( "Box" )
RHCheckBoxESPBox:SetConVar( "rh_box" )
RHCheckBoxESPBox:SetValue( 1 )
RHCheckBoxESPBox:SizeToContents()

local RHCheckBoxESPAdmin = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPAdmin:SetPos( 10, 150 )
RHCheckBoxESPAdmin:SetText( "Admin" )
RHCheckBoxESPAdmin:SetConVar( "rh_admin" )
RHCheckBoxESPAdmin:SetValue( 1 )
RHCheckBoxESPAdmin:SizeToContents()

local RHCheckBoxESPEntity = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPEntity:SetPos( 120, 30 )
RHCheckBoxESPEntity:SetText( "All Entity's" )
RHCheckBoxESPEntity:SetConVar( "" )
RHCheckBoxESPEntity:SetValue( 1 )
RHCheckBoxESPEntity:SizeToContents()

local RHCheckBoxESPRolePlay = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPRolePlay:SetPos( 120, 50 )
RHCheckBoxESPRolePlay:SetText( "Roleplay" )
RHCheckBoxESPRolePlay:SetConVar( "" )
RHCheckBoxESPRolePlay:SetValue( 1 )
RHCheckBoxESPRolePlay:SizeToContents()

local RHCheckBoxESPWeaponS = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPWeaponS:SetPos( 120, 70 )
RHCheckBoxESPWeaponS:SetText( "Show Weapon" )
RHCheckBoxESPWeaponS:SetConVar( "" )
RHCheckBoxESPWeaponS:SetValue( 1 )
RHCheckBoxESPWeaponS:SizeToContents()

local RHCheckBoxESPV = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPV:SetPos( 120, 90 )
RHCheckBoxESPV:SetText( "Vehicals" )
RHCheckBoxESPV:SetConVar( "" )
RHCheckBoxESPV:SetValue( 1 )
RHCheckBoxESPV:SizeToContents()

local RHCheckBoxESPNPC = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPNPC:SetPos( 220, 30 )
RHCheckBoxESPNPC:SetText( "NPC Text" )
RHCheckBoxESPNPC:SetConVar( "rh_npc" )
RHCheckBoxESPNPC:SetValue( 1 )
RHCheckBoxESPNPC:SizeToContents()

local RHCheckBoxESPNPCN = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPNPCN:SetPos( 220, 50 )
RHCheckBoxESPNPCN:SetText( "Name" )
RHCheckBoxESPNPCN:SetConVar( "rh_npcname" )
RHCheckBoxESPNPCN:SetValue( 1 )
RHCheckBoxESPNPCN:SizeToContents()

local RHCheckBoxESPNPCM = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPNPCM:SetPos( 220, 70 )
RHCheckBoxESPNPCM:SetText( "Head Marker" )
RHCheckBoxESPNPCM:SetConVar( "rh_npcheadmarker" )
RHCheckBoxESPNPCM:SetValue( 1 )
RHCheckBoxESPNPCM:SizeToContents()

local RHButtonToggleColor = vgui.Create( "DButton", UserESP )
RHButtonToggleColor:SetPos( 10, 200 )
RHButtonToggleColor:SetSize( 100, 30 )
RHButtonToggleColor:SetText( "Toggle Colors" )

local RHButtonTogglePOS = vgui.Create( "DButton", UserESP )
RHButtonTogglePOS:SetPos( 120, 200 )
RHButtonTogglePOS:SetSize( 100, 30 )
RHButtonTogglePOS:SetText( "Edit Positions" )

local RHCheckBoxESPUNAME = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPUNAME:SetPos( 320, 30 )
RHCheckBoxESPUNAME:SetText( "Your Name" )
RHCheckBoxESPUNAME:SetConVar( "rh_myinfoname" )
RHCheckBoxESPUNAME:SetValue( 1 )
RHCheckBoxESPUNAME:SizeToContents()

local RHCheckBoxESPUHP = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPUHP:SetPos( 320, 50 )
RHCheckBoxESPUHP:SetText( "Your Health" )
RHCheckBoxESPUHP:SetConVar( "rh_myinfohp" )
RHCheckBoxESPUHP:SetValue( 1 )
RHCheckBoxESPUHP:SizeToContents()

local RHCheckBoxESPUW = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPUW:SetPos( 320, 70 )
RHCheckBoxESPUW:SetText( "Your Weapon" )
RHCheckBoxESPUW:SetConVar( "rh_myinfoweapon" )
RHCheckBoxESPUW:SetValue( 1 )
RHCheckBoxESPUW:SizeToContents()

local RHPlayerO = vgui.Create( "Label", UserESP )
RHPlayerO:SetPos( 10, -10 )
RHPlayerO:SetSize( 140, 40 )
RHPlayerO:SetText( "Player Settings:" )

local RHEntityO = vgui.Create( "Label", UserESP )
RHEntityO:SetPos( 220, -10 )
RHEntityO:SetSize( 140, 40 )
RHEntityO:SetText( "NPC Settings:" )

local RHNPC = vgui.Create( "Label", UserESP )
RHNPC:SetPos( 120, -10 )
RHNPC:SetSize( 140, 40 )
RHNPC:SetText( "Entity Settings:" )

local RHMY = vgui.Create( "Label", UserESP )
RHMY:SetPos( 320, -10 )
RHMY:SetSize( 140, 40 )
RHMY:SetText( "My Settings:" )


-- Visuals
local UserVis = vgui.Create( "DPanel", PropertySheet )
UserVis:SetSize( w-20, h-45 )
UserVis.Paint = function()
end

local RHCheckBoxVisCross = vgui.Create( "DCheckBoxLabel", UserVis )
RHCheckBoxVisCross:SetPos( 10, 10 )
RHCheckBoxVisCross:SetText( "Crosshair" )
RHCheckBoxVisCross:SetConVar( "rh_crosshair" )
RHCheckBoxVisCross:SetValue( 1 )
RHCheckBoxVisCross:SizeToContents()

local RHCheckBoxVisDLight = vgui.Create( "DCheckBoxLabel", UserVis )
RHCheckBoxVisDLight:SetPos( 10,30 )
RHCheckBoxVisDLight:SetText( "Dynamic Light" )
RHCheckBoxVisDLight:SetConVar( "rh_dlights" )
RHCheckBoxVisDLight:SetValue( 1 )
RHCheckBoxVisDLight:SizeToContents()

local RHSliderDLIGHT = vgui.Create( "DNumSlider", UserVis )
RHSliderDLIGHT:SetPos( 10, 50 )
RHSliderDLIGHT:SetSize( 450, 200 )
RHSliderDLIGHT:SetText( "Dynamic Lights Radios" )
RHSliderDLIGHT:SetMin( 0 )
RHSliderDLIGHT:SetMax( 500 )
RHSliderDLIGHT:SetDecimals( 0 )
RHSliderDLIGHT:SetConVar( "" )

local RHCheckBoxVisCham = vgui.Create( "DCheckBoxLabel", UserVis )
RHCheckBoxVisCham:SetPos( 10,100 )
RHCheckBoxVisCham:SetText( "Chams" )
RHCheckBoxVisCham:SetConVar( "" )
RHCheckBoxVisCham:SetValue( 1 )
RHCheckBoxVisCham:SizeToContents()

local RHCheckBoxVisFOV = vgui.Create( "DCheckBoxLabel", UserVis )
RHCheckBoxVisFOV:SetPos( 10,120 )
RHCheckBoxVisFOV:SetText( "Draw Field of View" )
RHCheckBoxVisFOV:SetConVar( "" )
RHCheckBoxVisFOV:SetValue( 1 )
RHCheckBoxVisFOV:SizeToContents()

-- Removels
local UserRem = vgui.Create( "DPanel", PropertySheet )
UserRem:SetSize( w-20, h-45 )
UserRem.Paint = function()
end

local RHCheckBoxRemRecoil = vgui.Create( "DCheckBoxLabel", UserRem )
RHCheckBoxRemRecoil:SetPos( 10,10 )
RHCheckBoxRemRecoil:SetText( "No-Recoil" )
RHCheckBoxRemRecoil:SetConVar( "" )
RHCheckBoxRemRecoil:SetValue( 1 )
RHCheckBoxRemRecoil:SizeToContents()

local RHCheckBoxRemSpread = vgui.Create( "DCheckBoxLabel", UserRem )
RHCheckBoxRemSpread:SetPos( 10,30 )
RHCheckBoxRemSpread:SetText( "No-Spread" )
RHCheckBoxRemSpread:SetConVar( "" )
RHCheckBoxRemSpread:SetValue( 1 )
RHCheckBoxRemSpread:SizeToContents()


-- Misc
local UserMisc = vgui.Create( "DPanel", PropertySheet )
UserMisc:SetSize( w-20, h-45 )
UserMisc.Paint = function()
end

local RHCheckBoxMiscBHOP = vgui.Create( "DCheckBoxLabel", UserMisc )
RHCheckBoxMiscBHOP:SetPos( 10,10 )
RHCheckBoxMiscBHOP:SetText( "Bunnyhop" )
RHCheckBoxMiscBHOP:SetConVar( "" )
RHCheckBoxMiscBHOP:SetValue( 1 )
RHCheckBoxMiscBHOP:SizeToContents()

local RHCheckBoxMiscAP = vgui.Create( "DCheckBoxLabel", UserMisc )
RHCheckBoxMiscAP:SetPos( 10,30 )
RHCheckBoxMiscAP:SetText( "Autopistol" )
RHCheckBoxMiscAP:SetConVar( "" )
RHCheckBoxMiscAP:SetValue( 1 )
RHCheckBoxMiscAP:SizeToContents()

local RHCheckBoxMiscAR = vgui.Create( "DCheckBoxLabel", UserMisc )
RHCheckBoxMiscAR:SetPos( 10,50 )
RHCheckBoxMiscAR:SetText( "Autoreload" )
RHCheckBoxMiscAR:SetConVar( "" )
RHCheckBoxMiscAR:SetValue( 1 )
RHCheckBoxMiscAR:SizeToContents()

local RHCheckBoxMiscNS = vgui.Create( "DCheckBoxLabel", UserMisc )
RHCheckBoxMiscNS:SetPos( 10,70 )
RHCheckBoxMiscNS:SetText( "Name Stealer" )
RHCheckBoxMiscNS:SetConVar( "" )
RHCheckBoxMiscNS:SetValue( 1 )
RHCheckBoxMiscNS:SizeToContents()

-- Info Menu
local UserInfo = vgui.Create( "DPanel", PropertySheet )
UserMisc:SetSize( w-20, h-45 )
UserMisc.Paint = function()
end

local InfoList = vgui.Create("DListView", UserInfo)
InfoList:SetParent(UserInfo)
InfoList:SetPos(10, 10)
InfoList:SetSize(455, 215)
InfoList:SetMultiSelect(false)
InfoList:AddColumn("Name")
InfoList:AddColumn("Health")
InfoList:AddColumn("Armor")
InfoList:AddColumn("Admin")
-- Admin
local function InfoAdmin(v)
if v:IsAdmin() and not v:IsSuperAdmin() then return "Admin"
elseif v:IsSuperAdmin() then return "Super Admin"
elseif not v:IsAdmin() and not v:IsSuperAdmin() then return "Not Admin" 
end
end

for k,v in pairs(player.GetAll()) do
InfoList:AddLine(v:Nick(), v:Health(), v:Armor(), InfoAdmin(v))
end
-- Now to make sure all the stuff saves in the menu, it screws up if you don't do this :(.

-- Stuff I don't like

PropertySheet:AddSheet( "Aimbot", UserAim, "gui/silkicons/user", false, false, "Aimbot system" )
PropertySheet:AddSheet( "ESP", UserESP, "gui/silkicons/user", false, false, "ESP system" )
PropertySheet:AddSheet( "Visuals", UserVis, "gui/silkicons/user", false, false, "Visual system" )
PropertySheet:AddSheet( "Removels",UserRem, "gui/silkicons/user", false, false, "Removel system" )
PropertySheet:AddSheet( "Misc", UserMisc, "gui/silkicons/user", false, false, "Other systems" )
PropertySheet:AddSheet( "Info Menu", UserInfo, "gui/silkicons/user", false, false, "Info on other players" )
end

-- Menu commands
concommand.Add("reflexhack_menu", RHMenu)