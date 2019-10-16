//: ====================================================================================================
//: fr1kin's Hack - Simple Aimbot and more, EXTREMLY OLLLLLLLLLD
//: ====================================================================================================

/*----------------------------------------
	Name: Console / LUA CMD's
	Desc: Console commands for LUA.
----------------------------------------*/
if ( SERVER ) then return end

//: Name:
local Name = CreateClientConVar("f_name", 0, true, false)
	local NameX = CreateClientConVar("f_namex", 0, true, false)
	local NameY = CreateClientConVar("f_namey", 0, true, false)

//: Health:
local Health = CreateClientConVar("f_health", 0, true, false)
	local HealthX = CreateClientConVar("f_healthx", 0, true, false)
	local HealthY = CreateClientConVar("f_healthy", 0, true, false)
	
//: Weapon:
local Weapon = CreateClientConVar("f_health", 0, true, false)
	local WeaponX = CreateClientConVar("f_weaponx", 0, true, false)
	local WeaponY = CreateClientConVar("f_weapony", 0, true, false)

//: Extra Sensory Perception Misc:
local Box = CreateClientConVar("f_box", 0, true, false)
local HeadMarker = CreateClientConVar("f_headmarker", 0, true, false)

//: Radar:
local Radar = CreateClientConVar("f_radar", 0, true, false)
	local RadarX = CreateClientConVar("f_radarx", 0, true, false)
	local RadarY = CreateClientConVar("f_radary", 0, true, false)
	local RadarR = CreateClientConVar("f_radarr", 0, true, false)
	local RadarG = CreateClientConVar("f_radarg", 0, true, false)
	local RadarB = CreateClientConVar("f_radarb", 0, true, false)
	local RadarA = CreateClientConVar("f_radara", 255, true, false)
	
//: Misc:
local x = ScrW() / 2.0
local y = ScrH() / 2.0
local funcs = {"ply", "ents", "k", "v", "_"}

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

/*----------------------------------------
	Name: Aimbot
	Desc: Aims at a player(s) automaticly.
----------------------------------------*/
/*----------------------------------------
	Name: ESP
	Desc: Draws info on players/npcs.
----------------------------------------*/
local function DrawESP()
for _,v in pairs(ents.GetAll()) do
if (v:IsPlayer()) and (v:Alive() == true) and ( v != LocalPlayer() ) then
	local pos = v:GetPos() + Vector(0, 0, -20)
	pos = pos:ToScreen()
local pos1 = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1")):ToScreen()

//: Name - Displays the player(s) name.
if Name:GetInt() >= 1 then
	draw.SimpleText(v:Nick(), "DefaultSmall", pos.x, pos.y, team.GetColor(v:Team()), 1, 1)
end

//: Health - Displays the player(s) health on a bar. PLACE HOLDER
if Health:GetInt() >= 1 then
	draw.SimpleText("+"..v:Health(), "DefaultSmall", pos.x, pos.y+10, team.GetColor(v:Team()), 1, 1)
end

//: Head Mark - Points the the head.
if HeadMarker:GetInt() >= 1 then
local Col = team.GetColor(v:Team())
local AP = v:GetEyeTrace().HitPos:ToScreen()
local HP = HeadPos(v):ToScreen()
surface.SetDrawColor(Col.r, Col.g, Col.b, 255)
surface.DrawLine(HP.x, HP.y, AP.x, AP.y)
surface.SetDrawColor(team.GetColor(v:Team()))
surface.DrawRect(pos1.x, pos1.y, 2, 2)
end

//: Box - Draws a box around the player(s). I did not make this.
if Box:GetInt() >= 1 then
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

surface.SetDrawColor(team.GetColor(v:Team()))

surface.DrawLine(xmax,ymax,xmax,ymin)
surface.DrawLine(xmax,ymin,xmin,ymin)
surface.DrawLine(xmin,ymin,xmin,ymax)
surface.DrawLine(xmin,ymax,xmax,ymax)
end
end
end
end
hook.Add("HUDPaint", "hook", DrawESP)
/*----------------------------------------
	Name: Menu
	Desc: Main Menu for the script.
----------------------------------------*/
local function VisableMenu()
//: Radar - Overview of the map in 2D.

local xRadar = vgui.Create( "DFrame" )
xRadar:SetPos( 50,50 )
xRadar:SetSize( 170, 400 )
xRadar:SetTitle( "Radar" )
xRadar:SetVisible( true )
xRadar:SetDraggable( true )
xRadar:ShowCloseButton( true )
xRadar:MakePopup()
xRadar.Paint = function()
	draw.RoundedBox(4, 0, 0, xRadar:GetWide(), xRadar:GetTall(), Color(GetConVarNumber("f_radarr"), GetConVarNumber("f_radarg"), GetConVarNumber("f_radarb"), GetConVarNumber("f_radara")))
	draw.RoundedBox(4, 0, 0, xRadar:GetWide(), 21, Color(GetConVarNumber("f_radarr"), GetConVarNumber("f_radarg"), GetConVarNumber("f_radarb"), GetConVarNumber("f_radara")))
end

local xRadarX = vgui.Create( "DNumSlider", xRadar )
xRadarX:SetPos( 10, 25 )
xRadarX:SetSize( 150, 100 )
xRadarX:SetText( "Radar X" )
xRadarX:SetMin( 0 )
xRadarX:SetMax( ScrW() )
xRadarX:SetDecimals( 0 )
xRadarX:SetConVar( "f_radarx" )

local xRadarY = vgui.Create( "DNumSlider", xRadar )
xRadarY:SetPos( 10, 75 )
xRadarY:SetSize( 150, 100 )
xRadarY:SetText( "Radar Y" )
xRadarY:SetMin( 0 )
xRadarY:SetMax( ScrH() )
xRadarY:SetDecimals( 0 )
xRadarY:SetConVar( "f_radary" )

local xRadarR = vgui.Create( "DNumSlider", xRadar )
xRadarR:SetPos( 10, 125 )
xRadarR:SetSize( 150, 100 )
xRadarR:SetText( "Radar Red" )
xRadarR:SetMin( 0 )
xRadarR:SetMax( 255 )
xRadarR:SetDecimals( 0 )
xRadarR:SetConVar( "f_radarr" )

local xRadarG = vgui.Create( "DNumSlider", xRadar )
xRadarG:SetPos( 10, 175 )
xRadarG:SetSize( 150, 100 )
xRadarG:SetText( "Radar Green" )
xRadarG:SetMin( 0 )
xRadarG:SetMax( 255 )
xRadarG:SetDecimals( 0 )
xRadarG:SetConVar( "f_radarg" )

local xRadarB = vgui.Create( "DNumSlider", xRadar )
xRadarB:SetPos( 10, 225 )
xRadarB:SetSize( 150, 100 )
xRadarB:SetText( "Radar Blue" )
xRadarB:SetMin( 0 )
xRadarB:SetMax( 255 )
xRadarB:SetDecimals( 0 )
xRadarB:SetConVar( "f_radarb" )

local xRadarA = vgui.Create( "DNumSlider", xRadar )
xRadarA:SetPos( 10, 275 )
xRadarA:SetSize( 150, 100 )
xRadarA:SetText( "Radar Alpha" )
xRadarA:SetMin( 0 )
xRadarA:SetMax( 255 )
xRadarA:SetDecimals( 0 )
xRadarA:SetConVar( "f_radara" )

end

local function stuff()
draw.RoundedBox( 6, GetConVarNumber("f_radarx"), GetConVarNumber("f_radary"), 200, 200, Color( GetConVarNumber("f_radarr"), GetConVarNumber("f_radarg"), GetConVarNumber("f_radarb"), GetConVarNumber("f_radara") ) )
end
hook.Add("HUDPaint", "hai", stuff)
concommand.Add("f_menu", VisableMenu)