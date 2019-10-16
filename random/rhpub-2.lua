--[[-------------------------------------]]--
--[[ ReflexHack Client-Side Cheat v1.0.0 ]]--
--[[            -=By fr1kin=-            ]]--
--[[-------------------------------------]]--

------------------------------| Main |------------------------------
//[Tab] Main { -- These are going to be used organize the list.
if ( SERVER ) then return end

local Aimbot = true
local Autoshoot = true
local AimBone = ( 14 )
local AimFOV = ( 360 )
local Name = CreateClientConVar("rh_name", 0, true, false)
local Health = CreateClientConVar("rh_health", 0, true, false)
local Weapon = CreateClientConVar("rh_weapon", 0, true, false)
local Armor = CreateClientConVar("rh_armor", 0, true, false)
local Class = CreateClientConVar("rh_class", 0, true, false)
local Box = CreateClientConVar("rh_box", 0, true, false)
local Admin = CreateClientConVar("rh_admin", 0, true, false)
local Entity = CreateClientConVar("rh_entity", 0, true, false)
local RPEntitys = {"money_printer", "drug_lab", "drug", "microwave", "food", "gunlab", "spawned_shipment", "spawned_food", "spawned_weapon"}
local NPC = true
local Crosshair = CreateClientConVar("rh_crosshair", 0, true, false)
local DLights = CreateClientConVar("rh_dlights", 0, true, false)
local Cham = true
local DrawFOV = true
local NoRecoil = true
local NoSpread = true
local BunnyHop = true
local Autopistol = true
local ToggleCOL = CreateClientConVar("rh_togglecolors", 0, true, false) -- toggles white/teamcolors

-- Admin
local function PlayerAdminSuper(v)
if v:IsAdmin() and not v:IsSuperAdmin() then return "Admin"
elseif v:IsSuperAdmin() then return "!Super Admin!"
elseif not v:IsAdmin() and not v:IsSuperAdmin() then return "Player"
end
end

-- Color
local function ToggleColorButton()
if ToggleCOL:GetInt() >= 1 then
Color(255, 255, 255, 255)
else
team.GetColor(v:Team())
end
end
-- Other
local w, h = ScrW() / 2, ScrH() / 2
//[Tab] Main }
-----------------------------| Aimbot |-----------------------------
//[Tab] Aimbot {
//[Tab] Aimbot }
-------------------------------| ESP |------------------------------
//[Tab] ESP {
local function RHESP()
for k,v in pairs(player.GetAll()) do
if (v:IsPlayer()) and (v:Alive()== true) and (v:IsValid()) then -- This is just making sure the object is a player and alive. If not the ESP will not enable for that player.
local pos = v:GetPos() + Vector(0, 0, -20) -- This sets a vector for the ESP point.
pos = pos:ToScreen()
	-- Admin ESP.
	if Admin:GetInt() >= 1 then
		draw.SimpleTextOutlined(PlayerAdminSuper(v), "DefaultSmall", pos.x, pos.y, Color(255, 0, 0, 255), 1, 1, 1, Color(0, 0, 0, 255))
	end
	-- Name ESP.
	if Name:GetInt() >= 1 then
		draw.SimpleTextOutlined("Name: "..v:Nick(), "DefaultSmall", pos.x, pos.y+10, team.GetColor(v:Team()), 1, 1, 1, Color(0, 0, 0, 255))
	end
	-- Weapon ESP
	if Weapon:GetInt() >= 1 then
	local GetWeapon = v:GetActiveWeapon():GetPrintName()
		draw.SimpleTextOutlined("Weapon: "..GetWeapon, "DefaultSmall", pos.x, pos.y+20, team.GetColor(v:Team()), 1, 1, 1, Color(0, 0, 0, 255))
		-- NOTE: theirs a error with this, i will fix it later for now dont enable it
	end
	-- Health ESP.
	if Health:GetInt() >= 1 then
		draw.SimpleTextOutlined("Health: "..v:Health(), "DefaultSmall", pos.x, pos.y+30, team.GetColor(v:Team()), 1, 1, 1, Color(0, 0, 0, 255))
	end
	-- Armor ESP.
	if Armor:GetInt() >= 1 then
		draw.SimpleTextOutlined("Armor: "..v:Armor(), "DefaultSmall", pos.x, pos.y+40, team.GetColor(v:Team()), 1, 1, 1, Color(0, 0, 0, 255))
	end
	-- Class ESP.
	local PlayerTeamName = team.GetName(v:Team())
	if Class:GetInt() >= 1 then
		draw.SimpleTextOutlined("Class: "..PlayerTeamName, "DefaultSmall", pos.x, pos.y+50, team.GetColor(v:Team()), 1, 1, 1, Color(0, 0, 0, 255))
	end
-- Box ESP. Note that I did not make this, all credits for the box esp goto Bloody Chef.
-- I might make my own code for this later on, but I hate math commands :(.
local Col = team.GetColor(v:Team())
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

surface.SetDrawColor(Col.r, Col.g, Col.b, 255)

surface.DrawLine(xmax,ymax,xmax,ymin)
surface.DrawLine(xmax,ymin,xmin,ymin)
surface.DrawLine(xmin,ymin,xmin,ymax)
surface.DrawLine(xmin,ymax,xmax,ymax)
-- Entity Esp (DarkRP)
if Entity:GetInt() >= 1 then
for _, ent in pairs(ents.GetAll()) do
if ValidEntity(ent) and (ent:GetClass() == RPEntitys) then
draw.SimpleTextOutlined("ENTITY", "DefaultSmall", pos.x, pos.y, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
else
end
end
end
end
end
end
end
hook.Add("HUDPaint", "RHESP", RHESP)
//[Tab] ESP }
-----------------------------| Visuals |----------------------------
//[Tab] Visuals {
local function RHVisuals()
-- Crosshair
if Crosshair:GetInt() >= 1 then
surface.SetDrawColor(0, 255, 0, 255)
surface.DrawLine(w, h - 5, w, h + 5)
surface.DrawLine(w - 5, h, w + 5, h)
end
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
end
end
hook.Add("HUDPaint", "RHVisuals", RHVisuals)
//[Tab] Visuals }
----------------------------| Removels |----------------------------
//[Tab] Removels {
//[Tab] Removels }
------------------------------| Menu |------------------------------
//[Tab] Menu {
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
RHCheckBoxESPName:SetPos( 10, 10 )
RHCheckBoxESPName:SetText( "Name" )
RHCheckBoxESPName:SetConVar( "rh_name" )
RHCheckBoxESPName:SetValue( 1 )
RHCheckBoxESPName:SizeToContents()

local RHCheckBoxESPHealth = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPHealth:SetPos( 10, 30 )
RHCheckBoxESPHealth:SetText( "Health" )
RHCheckBoxESPHealth:SetConVar( "rh_health" )
RHCheckBoxESPHealth:SetValue( 1 )
RHCheckBoxESPHealth:SizeToContents()

local RHCheckBoxESPWeapon = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPWeapon:SetPos( 10, 50 )
RHCheckBoxESPWeapon:SetText( "Weapon" )
RHCheckBoxESPWeapon:SetConVar( "rh_weapon" )
RHCheckBoxESPWeapon:SetValue( 1 )
RHCheckBoxESPWeapon:SizeToContents()

local RHCheckBoxESPClass = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPClass:SetPos( 10, 70 )
RHCheckBoxESPClass:SetText( "Class" )
RHCheckBoxESPClass:SetConVar( "rh_class" )
RHCheckBoxESPClass:SetValue( 1 )
RHCheckBoxESPClass:SizeToContents()

local RHCheckBoxESPArmor = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPArmor:SetPos( 10, 90 )
RHCheckBoxESPArmor:SetText( "Armor" )
RHCheckBoxESPArmor:SetConVar( "rh_armor" )
RHCheckBoxESPArmor:SetValue( 1 )
RHCheckBoxESPArmor:SizeToContents()

local RHCheckBoxESPBox = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPBox:SetPos( 10, 110 )
RHCheckBoxESPBox:SetText( "Box" )
RHCheckBoxESPBox:SetConVar( "rh_box" )
RHCheckBoxESPBox:SetValue( 1 )
RHCheckBoxESPBox:SizeToContents()

local RHCheckBoxESPAdmin = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPAdmin:SetPos( 10, 130 )
RHCheckBoxESPAdmin:SetText( "Admin" )
RHCheckBoxESPAdmin:SetConVar( "rh_admin" )
RHCheckBoxESPAdmin:SetValue( 1 )
RHCheckBoxESPAdmin:SizeToContents()

local RHCheckBoxESPEntity = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPEntity:SetPos( 10, 150 )
RHCheckBoxESPEntity:SetText( "Entity" )
RHCheckBoxESPEntity:SetConVar( "" )
RHCheckBoxESPEntity:SetValue( 1 )
RHCheckBoxESPEntity:SizeToContents()

local RHCheckBoxESPNPC = vgui.Create( "DCheckBoxLabel", UserESP )
RHCheckBoxESPNPC:SetPos( 10, 170 )
RHCheckBoxESPNPC:SetText( "NPC" )
RHCheckBoxESPNPC:SetConVar( "" )
RHCheckBoxESPNPC:SetValue( 1 )
RHCheckBoxESPNPC:SizeToContents()

local RHButtonToggleColor = vgui.Create( "DButton", UserESP )
RHButtonToggleColor:SetPos( 10, 200 )
RHButtonToggleColor:SetSize( 100, 30 )
RHButtonToggleColor:SetText( "Toggle Colors" )

local RHButtonToggleColor = vgui.Create( "DButton", UserESP )
RHButtonToggleColor:SetPos( 120, 200 )
RHButtonToggleColor:SetSize( 100, 30 )
RHButtonToggleColor:SetText( "Edit Positions" )

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

for k,v in pairs(player.GetAll()) do
InfoList:AddLine(v:Nick(), v:Health(), v:Armor(), PlayerAdminSuper(v))
end
-- Now to make sure all the stuff saves in the menu, it screws up if you don't do this :(.
PropertySheet:AddSheet( "Aimbot", UserAim, "gui/silkicons/user", false, false, "Aimbot system" )
PropertySheet:AddSheet( "ESP", UserESP, "gui/silkicons/user", false, false, "ESP system" )
PropertySheet:AddSheet( "Visuals", UserVis, "gui/silkicons/user", false, false, "Visual system" )
PropertySheet:AddSheet( "Removels",UserRem, "gui/silkicons/user", false, false, "Removel system" )
PropertySheet:AddSheet( "Misc", UserMisc, "gui/silkicons/user", false, false, "Other systems" )
PropertySheet:AddSheet( "Info Menu", UserInfo, "gui/silkicons/user", false, false, "Info on other players" )
end

-- Menu commands
concommand.Add("reflexhack_menu", RHMenu)
//[Tab] Menu.Close }