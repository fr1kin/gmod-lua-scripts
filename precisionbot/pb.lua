if ( SERVER ) then return end
require( "antilag" )
//__________COMMANDS______________________________________________________________________________________________________________________________//
local ClientCheatCommands = ( {
	f_esp_name 				= 1.0,				// Name
	f_esp_health			= 1.0,				// Health
	f_esp_weapon			= 1.0,				// Weapon
	f_esp_distance			= 1.0,				// Distance
	f_esp_box				= 1.0,				// Box
	f_esp_max_distance		= 5000.0,			// Max Distance
	f_esp_self				= 1.0,				// Self Infomation
	f_esp_ent_sandbox		= 1.0,				// Sandbox entities.
	f_esp_color				= 0.0,				// Color: 0 = Team Color | 1 = Default Colors
	f_rem_recoil			= 1.0,				// No Recoil
	f_vis_crosshair			= 1.0,				// Crosshair
	f_vis_dynamiclights		= 1.0,				// Dynamic Lights
	f_vis_admin_list		= 1.0, 				// Admin List
	f_radar					= 1.0,				// Radar
	f_misc_autopistol		= 1.0,				// Autopistol
	f_misc_bunnyhop			= 1.0,				// Bunnyhop
	f_misc_bypass			= 1.0,				// Cheats, Consistancy...
	f_misc_speedhack		= 1.0,				// Speedhack
} )

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

local RPMoney = ( {
	"models/props/cs_assault/money.mdl",
} )

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

local x = ScrW() / 2
local y = ScrH() / 2

// CROSSHAIR
local cross 	= {}
cross.x			= x				  				// Centure screen.																DEF = x
cross.y			= y 			  				// Centure screen.																DEF = y
cross.tall		= 40					  		// Highth of the line.															DEF = 20
cross.wide		= 40					  		// Width of the line.															DEF = 20
cross.color		= Color( 0, 255, 0, 255 )		// Crosshair color.																DEF = Color( 0, 255, 0, 255 )
cross.dotcol	= Color( 255, 0, 0, 255 )		// Crosshair dot color.															DEF = Color( 255, 0, 0, 255 )
cross.xd		= cross.x - 2					// Crosshair dot - 2.															DEF = cross.x - 2
cross.yd		= cross.y - 2					// Crosshair dot - 2.															DEF = cross.y - 2

// DYNAMIC LIGHT
local dlights = {}
dlights.ssize	= 500							// Self dynamiclight size.														DEF = 200
dlights.asize	= 500							// Everyone dynamiclight size.													DEF = 500
dlights.all		= true							// Dynamiclights for everyone.													DEF = true
dlights.self	= false							// Dynamiclights for only you're self.											DEF = false

// RADAR
local radar 	= {}
radar.x 		= 800				  			// X postition of the radar.  													DEF = 10
radar.y			= 10					  		// Y postition of the radar.  													DEF = 10
radar.round		= 0						  		// The roundness of the radar.  												DEF = 0
radar.size 		= 200					  		// Size of radar.  																DEF = 200
radar.selfsize	= 5						  		// Your box size. 																DEF = 5
radar.selfround = 1						  		// Roundness of you're dot.														DEF = 1
radar.csize		= 90					  		// Centure line size.															DEF = 90
radar.col		= Color( 0, 255, 0, 50 ) 		// Body color.																	DEF = Color( 0, 255, 0, 150 )
radar.outcol	= Color( 0, 0, 0, 255 )	  		// Outline color.																DEF = Color( 0, 0, 0, 255 )
radar.selfcol	= Color( 0, 0, 255, 000 ) 		// Your color.																	DEF = Color( 0, 0, 255, 255 )
radar.radius	= 5000					  		// How far the radar will scan.													DEF = 5000
radar.plyname	= true					  		// Draws player's name.															DEF = false
radar.plydot	= true					  		// Draws a player dot on the position of the radar.								DEF = true
radar.plycol	= Color( 0, 0, 255, 255 ) 		// Color of the player's name and dot.											DEF = Color( 0, 0, 255, 255 )
radar.npcdot	= true					  		// Draws a NPC dot on the position of the radar.								DEF = true
radar.npccol	= Color( 0, 0, 255, 255 ) 		// Color of the NPC's name and dot.												DEF = Color( 0, 0, 255, 255 )
radar.enpcol	= Color( 255, 0, 0, 255 ) 		// Enemies color.																DEF = Color( 255, 0, 0, 255 )

// Self Infomation
local info 		= {}
info.name		= true							// Your name.																	DEF = true
info.health		= true							// Your health.																	DEF = true
info.weapon		= true							// Your weapon.																	DEF = true
info.class		= true							// Your class.																	DEF = true

function CreateCommands()
	for key, value in pairs( ClientCheatCommands ) do
		CreateClientConVar( key, value, true, false )
	end
end
		
local function GetAdmin(ent)
if ent:IsAdmin() and not ent:IsSuperAdmin() then return " | Admin"
elseif ent:IsSuperAdmin() then return " | Super Admin"
elseif not ent:IsAdmin() and not ent:IsSuperAdmin() then return "" 
end
end

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

local function Visible(ent)
local trace = {start = LocalPlayer():GetShootPos(),endpos = HeadPos(ent),filter = {LocalPlayer(), ent}}
local tr = util.TraceLine(trace)
if tr.Fraction == 1 then
return true
else
return false
end	
end

// Thanks to Azuleet, I will not sell this.
SetConvar( CreateConVar( "sv_scriptenforcer", "" ), 0 )
SetConvar( CreateConVar( "sv_cheats", "" ), 1 )
SetConvar( CreateConVar( "sv_consistancy", "" ), 0 )
SetConvar( CreateConVar( "sv_pure", "" ), 0 )

hook.Add( "Initialize", "RunCommands", CreateCommands )
//__________ESP___________________________________________________________________________________________________________________________________//
function DrawESP()
for _, ent in pairs(ents.GetAll()) do
	if ent:IsPlayer() and ent:Alive() == true and ent !=LocalPlayer() then
		local pos = ent:GetPos():ToScreen()
		local ply = LocalPlayer()
		local teamname = team.GetName( ent:Team() )
		local dis = math.floor(tostring(ent:GetPos():Distance(LocalPlayer():GetShootPos())))
		
	if ent:IsValid() then
	
	local col
		if GetConVarNumber( "f_esp_color" ) == 0 then
			local tc  = team.GetColor( ent:Team() )
			col = Color( tc.r, tc.g, tc.b, 255 )
		end
	if GetConVarNumber( "f_esp_color" ) == 1 then
		if ent:Team() == ply:Team() then
			col = Color( 255, 0, 0, 255 )
		elseif ent:Team() ~= ply:Team() then
			col = Color( 0, 255, 0, 255 )
		end
	end
					
				
				// MAX DISTANCE UNTILL ESP NOT DRAWN.
				if dis <= GetConVarNumber( "f_esp_max_distance" ) then

					// NAME ESP
					if GetConVarNumber( "f_esp_name" ) == 1 then
							draw.SimpleText( ent:Name() .. GetAdmin(ent) .. " | " .. teamname, "DefaultSmall", pos.x, pos.y, col, 3, 3 )
						end

					// HEALTH ESP
					if GetConVarNumber( "f_esp_health" ) == 1 then
							draw.SimpleText( "HP: " .. ent:Health(), "DefaultSmall", pos.x, pos.y + 10, col, 3, 3 )
						end

					// WEAPON ESP
					if GetConVarNumber("f_esp_weapon") == 1 then
							if ent:GetActiveWeapon():IsValid() then
							local wep = ent:GetActiveWeapon():GetPrintName()
							local wep = string.Replace( wep, "#HL2_", "" )
							local wep = string.Replace( wep, "#GMOD_", "" )
							local wep = string.upper( wep )
							draw.SimpleText( "W: " .. wep, "DefaultSmall", pos.x, pos.y + 20, col, 3, 3 )
						end
					end
					
					// DISTANCE ESP
					if GetConVarNumber("f_esp_distance") == 1 then
							local dis = math.floor(tostring(ent:GetPos():Distance(LocalPlayer():GetShootPos())))
							if dis <= GetConVarNumber("f_esp_max_distance") then
							draw.SimpleText("D: " .. dis, "DefaultSmall", pos.x, pos.y + 30, col, 3, 3 )
						end
					end
						
					// BOX ESP BY EUSION
					if GetConVarNumber("f_esp_box") == 1 then
							local center = ent:LocalToWorld(ent:OBBCenter())
							local min,max = ent:WorldSpaceAABB()
							local dim = max-min

							local front = ent:GetForward()*(dim.y/2)
							local right = ent:GetRight()*(dim.x/2)
							local top = ent:GetUp()*(dim.z/2)
							local back = (ent:GetForward()*-1)*(dim.y/2)
							local left = (ent:GetRight()*-1)*(dim.x/2)
							local bottom = (ent:GetUp()*-1)*(dim.z/2)
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

							surface.SetDrawColor(col.r, col.g, col.b, 150)

							surface.DrawLine(xmax,ymax,xmax,ymin)
							surface.DrawLine(xmax,ymin,xmin,ymin)
							surface.DrawLine(xmin,ymin,xmin,ymax)
							surface.DrawLine(xmin,ymax,xmax,ymax)
						end
				
			// OVER MAX DISTANCE ( PRINTS NAME )
			if dis >= GetConVarNumber( "f_esp_max_distance" ) then
				if GetConVarNumber("f_esp_name") >= 1 then
							draw.SimpleText( ent:Nick(), "DefaultSmall", pos.x, pos.y, col, 1, 1 )
						end
					end
				end
			end
		end
	end
end
hook.Add( "HUDPaint", "PlayerESP", DrawESP )
//__________VISUAL________________________________________________________________________________________________________________________________//
function Drawcrosshair()
	if GetConVarNumber( "f_vis_crosshair" ) == 1 then
		// GUI
			surface.SetDrawColor( cross.color )
			surface.DrawLine( cross.x, cross.y - cross.tall, cross.x, cross.y + cross.tall )
			surface.DrawLine( cross.x - cross.wide, cross.y, cross.x + cross.wide, cross.y )
			draw.RoundedBox( 1, cross.xd, cross.yd, 5, 5, cross.dotcol )
		end
	end
hook.Add( "HUDPaint", "Crosshair", Drawcrosshair )

function Drawdynamiclights()
	if GetConVarNumber( "f_vis_dynamiclights" ) == 1 then
	local ply = LocalPlayer()
	

		for _, v in pairs( player.GetAll() ) do
	local col
		if GetConVarNumber( "f_esp_color" ) == 0 then
			local tc  = team.GetColor( v:Team() )
			col = Color( tc.r, tc.g, tc.b, 255 )
		end
	if GetConVarNumber( "f_esp_color" ) == 1 then
		if v:Team() == ply:Team() then
			col = Color( 255, 0, 0, 255 )
		elseif v:Team() ~= ply:Team() then
			col = Color( 0, 255, 0, 255 )
		end
	end
	

				if dlights.self then
					local dlight = DynamicLight( LocalPlayer() )
					dlight.Pos = v:GetPos()
					dlight.r = 255
					dlight.g = 255
					dlight.b = 255
					dlight.Size = dlights.ssize
					dlight.Decay = 20
					dlight.DieTime = CurTime() + .1
				end
				if dlights.all then
				if ValidEntity(v) and v:Alive() and v !=LocalPlayer() then
					local dlight = DynamicLight( player.GetAll() )
					dlight.Pos = v:GetPos()
					dlight.r = col.r
					dlight.g = col.g
					dlight.b = col.b
					dlight.Size = dlights.asize
					dlight.Decay = 20
					dlight.DieTime = CurTime() + .1
				end
			end
		end
	end
end
hook.Add( "Think", "Dynamiclights", Drawdynamiclights )

function Selfinfo()
end
//__________REMOVELS______________________________________________________________________________________________________________________________//
function Norecoil()
	if GetConVarNumber("f_rem_recoil") == 1 then
		local wep = LocalPlayer():GetActiveWeapon()
			if wep.Primary then wep.Primary.Recoil = 0.0 end
			if wep.Secondary then wep.Secondary.Recoil = 0.0 end
	end
end
hook.Add("CalcView", "Recoil", Norecoil)

//__________OTHER STUFF___________________________________________________________________________________________________________________________//
	concommand.Add( "+bhop", function()
		hook.Add( "Tick", "Bunnyhop", function()
			local ply = LocalPlayer()
				if not ply:IsOnGround() then
					RunConsoleCommand( "-jump" )
				elseif ply:IsOnGround() then
					RunConsoleCommand( "+jump" )
				end
			end )
		end )
	concommand.Add( "-bhop", function()
		hook.Remove( "Tick", "Bunnyhop" )
	end )

concommand.Add( "+auto", function()
	hook.Add( "Tick", "Autopistol", function()
		local ply = LocalPlayer()
			RunConsoleCommand( "+attack" )
		end )
	end )

concommand.Add( "-auto", function()
	hook.Remove( "Tick", "Autopistol" )
end )

concommand.Add( "+speedhack", function()
	SetConvar( CreateConVar( "host_framerate", "" ), .3 )
end )
concommand.Add( "-speedhack", function()
	SetConvar( CreateConVar( "host_framerate", "" ), 0 )
end )
//__________RADAR_________________________________________________________________________________________________________________________________//
function Drawradar()
	if GetConVarNumber( "f_radar" ) == 1 then
	radar.half		= radar.size / 2		  // Divides the size by two to make a centured cross.
	radar.selfhalf	= radar.selfsize / 2	  // Divides the box size by 2 to centure it.
	radar.xm		= radar.x + radar.half	  // Center of radar. (x)
	radar.ym		= radar.y + radar.half	  // Center of radar. (y)
	radar.xo		= radar.x				  // Radar outline. (x)
	radar.yo		= radar.y				  // Radar outline. (y)

			draw.RoundedBox( radar.round, radar.x, radar.y, radar.size, radar.size, radar.col )
			surface.SetDrawColor( radar.outcol )
			surface.DrawLine( radar.xm, radar.ym - radar.csize, radar.xm, radar.ym + radar.csize )
			surface.DrawLine( radar.xm - radar.csize, radar.ym, radar.xm + radar.csize, radar.ym )
			surface.SetDrawColor( radar.outcol )
			surface.DrawLine( radar.xo, radar.yo, radar.xo, radar.yo + radar.size )
			surface.DrawLine( radar.xo + radar.size, radar.yo, radar.xo + radar.size, radar.yo + radar.size )
			surface.DrawLine( radar.xo, radar.yo, radar.xo + radar.size, radar.yo )
			surface.DrawLine( radar.xo, radar.yo + radar.size, radar.xo + radar.size, radar.yo + radar.size )
			draw.RoundedBox( radar.selfround, radar.xm - radar.selfhalf, radar.ym - radar.selfhalf, radar.selfsize, radar.selfsize, radar.selfcol )
			
		// Radar code thanks to Georg Schmid, I'm only good at creating GUI's n stuff.
			for _, v in pairs( player.GetAll() ) do
			local ply = LocalPlayer()
			

	local col
		if GetConVarNumber( "f_esp_color" ) == 0 then
			local tc  = team.GetColor( v:Team() )
			col = Color( tc.r, tc.g, tc.b, 255 )
		end
	if GetConVarNumber( "f_esp_color" ) == 1 then
		if v:Team() == ply:Team() then
			col = Color( 255, 0, 0, 255 )
		elseif v:Team() ~= ply:Team() then
			col = Color( 0, 255, 0, 255 )
		end
	end

				local cenx = radar.x + radar.size / 2
				local ceny = radar.y + radar.size / 2
				local tc = team.GetColor( v:Team() )
				local gpos = v:GetPos() - LocalPlayer():GetPos()
					if v:IsPlayer() and v:Alive() and v !=LocalPlayer() and gpos:Length() <= radar.radius then
						local pixx = gpos.x / radar.radius
						local pixy = gpos.y / radar.radius
							local root = math.sqrt( pixx * pixx + pixy * pixy )
							local find = math.Deg2Rad( math.Rad2Deg( math.atan2( pixx, pixy ) ) - math.Rad2Deg( math.atan2( LocalPlayer():GetAimVector().x, LocalPlayer():GetAimVector().y ) ) - 90)
								local pixx = math.cos( find ) * root
								local pixy = math.sin( find ) * root
									if radar.plydot then
										draw.RoundedBox( 1, cenx + pixx * radar.size / 2 - 0, ceny + pixy * radar.size / 2 - 4, 5, 5, col )
									end
									if radar.plyname then
										draw.SimpleText( v:Nick(), "DefaultSmall", cenx + pixx * radar.size / 2, ceny + pixy * radar.size / 2 - 10, col, 1, 1 )
											end
										end
									end
			for _, ent in pairs( ents.GetAll() ) do
				if ent:IsValid() then
				local cenx = radar.x + radar.size / 2
				local ceny = radar.y + radar.size / 2
				local gpos = ent:GetPos() - LocalPlayer():GetPos()
					if gpos:Length() <= radar.radius then
						local pixx = gpos.x / radar.radius
						local pixy = gpos.y / radar.radius
							local root = math.sqrt( pixx * pixx + pixy * pixy )
							local find = math.Deg2Rad( math.Rad2Deg( math.atan2( pixx, pixy ) ) - math.Rad2Deg( math.atan2( LocalPlayer():GetAimVector().x, LocalPlayer():GetAimVector().y ) ) - 90)
								local pixx = math.cos( find ) * root
								local pixy = math.sin( find ) * root
								if ent:IsNPC() then
								if radar.npcdot then
										draw.RoundedBox( 1, cenx + pixx * radar.size / 2 - 4, ceny + pixy * radar.size / 2 - 4, 4, 4, radar.npccol )
									end
								end
							end
						end
					end
				end
			end
hook.Add( "HUDPaint", "Radar", Drawradar )
//__________VGUI__________________________________________________________________________________________________________________________________//
function DrawMenu()
surface.CreateFont( "Coolvetica", 20, 400, true, false, "MAIN_FONT" )

local MainMenu = vgui.Create( "DFrame" )
MainMenu:SetPos( ScrW() / 4.5, ScrH() / 4.5 )
MainMenu:SetSize( 600, 350 )
MainMenu:SetTitle( "[Precision Bot] v1.3" )
MainMenu:SetVisible( true )
MainMenu:SetDraggable( true )
MainMenu:ShowCloseButton( true )
MainMenu:MakePopup()
MainMenu.Paint = function()
	draw.RoundedBox( 0, 0, 0, MainMenu:GetWide(), MainMenu:GetTall(), Color( 0, 0, 0, 230 ) )
	draw.RoundedBox( 0, 0, 0, MainMenu:GetWide() - 0, 21, Color( 0, 0, 0, 150 ) )
end

local HelloLabel = vgui.Create( "DLabel", MainMenu )
HelloLabel:SetPos( 260, 160 )
HelloLabel:SetText( "Welcome -----" )
HelloLabel:SizeToContents()
HelloLabel:SetTextColor( Color( 255, 0, 0, 255 ) )
HelloLabel:SetVisible( true )
HelloLabel:SetFont( "MAIN_FONT" )


// AIMBOT
local Aimbot = vgui.Create( "DCheckBoxLabel", MainMenu )
Aimbot:SetPos( 100, 50 )
Aimbot:SetText( "Aimbot" )
Aimbot:SetConVar( "" )
Aimbot:SetVisible( false )
Aimbot:SetValue( 1 )
Aimbot:SizeToContents()

local Autoshoot = vgui.Create( "DCheckBoxLabel", MainMenu )
Autoshoot:SetPos( 100, 70 )
Autoshoot:SetText( "Autoshoot" )
Autoshoot:SetConVar( "" )
Autoshoot:SetVisible( false )
Autoshoot:SizeToContents()

local Aimthur = vgui.Create( "DCheckBoxLabel", MainMenu )
Aimthur:SetPos( 100, 90 )
Aimthur:SetText( "Aimthur" )
Aimthur:SetConVar( "" )
Aimthur:SetVisible( false )
Aimthur:SizeToContents()

local Autoreload = vgui.Create( "DCheckBoxLabel", MainMenu )
Autoreload:SetPos( 100, 110 )
Autoreload:SetText( "Autoreload" )
Autoreload:SetConVar( "" )
Autoreload:SetVisible( false )
Autoreload:SetValue( 1 )
Autoreload:SizeToContents()

local Friendlyfire = vgui.Create( "DCheckBoxLabel", MainMenu )
Friendlyfire:SetPos( 100, 130 )
Friendlyfire:SetText( "Friendlyfire" )
Friendlyfire:SetConVar( "" )
Friendlyfire:SetVisible( false )
Friendlyfire:SizeToContents()

local Aimply = vgui.Create( "DCheckBoxLabel", MainMenu )
Aimply:SetPos( 100, 150 )
Aimply:SetText( "Target Players" )
Aimply:SetConVar( "" )
Aimply:SetVisible( false )
Aimply:SizeToContents()

local Aimnpc = vgui.Create( "DCheckBoxLabel", MainMenu )
Aimnpc:SetPos( 100, 170 )
Aimnpc:SetText( "Target NPCs" )
Aimnpc:SetConVar( "" )
Aimnpc:SetVisible( false )
Aimnpc:SizeToContents()

local Aimadmins = vgui.Create( "DCheckBoxLabel", MainMenu )
Aimadmins:SetPos( 200, 50 )
Aimadmins:SetText( "Target Admins" )
Aimadmins:SetConVar( "" )
Aimadmins:SetVisible( false )
Aimadmins:SizeToContents()

local Aimsteam = vgui.Create( "DCheckBoxLabel", MainMenu )
Aimsteam:SetPos( 200, 70 )
Aimsteam:SetText( "Target Steam Friends" )
Aimsteam:SetConVar( "" )
Aimsteam:SetVisible( false )
Aimsteam:SizeToContents()

local Aimrecoil = vgui.Create( "DCheckBoxLabel", MainMenu )
Aimrecoil:SetPos( 200, 90 )
Aimrecoil:SetText( "Remove Recoil" )
Aimrecoil:SetConVar( "" )
Aimrecoil:SetVisible( false )
Aimrecoil:SizeToContents()

local Showtarget = vgui.Create( "DCheckBoxLabel", MainMenu )
Showtarget:SetPos( 200, 110 )
Showtarget:SetText( "Print Target" )
Showtarget:SetConVar( "" )
Showtarget:SetVisible( false )
Showtarget:SizeToContents()

local FOV = vgui.Create( "DNumSlider", MainMenu )
FOV:SetPos( 100, 200 )
FOV:SetSize( 200, 200 )
FOV:SetText( "Field of View" )
FOV:SetMin( 0 )
FOV:SetMax( 360 )
FOV:SetVisible( false )
FOV:SetDecimals( 0 )
FOV:SetConVar( "" )

local Smooth = vgui.Create( "DNumSlider", MainMenu )
Smooth:SetPos( 100, 250 )
Smooth:SetSize( 200, 200 )
Smooth:SetText( "Smooth Aim" )
Smooth:SetMin( 0 )
Smooth:SetMax( 20 )
Smooth:SetVisible( false )
Smooth:SetDecimals( 0 )
Smooth:SetConVar( "" )

local Bone = vgui.Create( "DNumSlider", MainMenu )
Bone:SetPos( 350, 200 )
Bone:SetSize( 200, 200 )
Bone:SetText( "Target Bone" )
Bone:SetMin( 0 )
Bone:SetMax( 14 )
Bone:SetVisible( false )
Bone:SetDecimals( 0 )
Bone:SetConVar( "" )

local TargetDistance = vgui.Create( "DNumSlider", MainMenu )
TargetDistance:SetPos( 350, 250 )
TargetDistance:SetSize( 200, 200 )
TargetDistance:SetText( "Target Distance" )
TargetDistance:SetMin( 0 )
TargetDistance:SetMax( 5000 )
TargetDistance:SetVisible( false )
TargetDistance:SetDecimals( 0 )
TargetDistance:SetConVar( "" )

local EList = vgui.Create( "DComboBox", MainMenu )
EList:SetPos( 340, 50 )
EList:SetSize( 100, 140 )
EList:SetMultiple( false )
EList:SetVisible( false )
	local ELabel = vgui.Create( "DLabel", MainMenu )
	ELabel:SetPos( 360, 30 )
	ELabel:SetText( "- Enemies -" )
	ELabel:SizeToContents()
	ELabel:SetTextColor( Color( 255, 0, 0, 255 ) )
	ELabel:SetVisible( false )


local FList = vgui.Create( "DComboBox", MainMenu )
FList:SetPos( 470, 50 )
FList:SetSize( 100, 140 )
FList:SetMultiple( false )
FList:SetVisible( false )
	local FLabel = vgui.Create( "DLabel", MainMenu )
	FLabel:SetPos( 490, 30 )
	FLabel:SetText( "- Friends -" )
	FLabel:SizeToContents()
	FLabel:SetTextColor( Color( 255, 0, 0, 255 ) )
	FLabel:SetVisible( false )
	
local Aimby = vgui.Create( "DMultiChoice", MainMenu )
Aimby:SetPos( 200, 170 )
Aimby:SetSize( 130, 20 )
Aimby:SizeToContents()
Aimby:AddChoice( "Distance" )
Aimby:AddChoice( "Crosshair" )
Aimby:SetVisible( false )
	local ALabel = vgui.Create( "DLabel", MainMenu )
	ALabel:SetPos( 240, 150 )
	ALabel:SetText( "- Aimby -" )
	ALabel:SizeToContents()
	ALabel:SetTextColor( Color( 255, 0, 0, 255 ) )
	ALabel:SetVisible( false )



// ESP
local Name = vgui.Create( "DCheckBoxLabel", MainMenu )
Name:SetPos( 100, 50 )
Name:SetText( "Name" )
Name:SetConVar( "f_esp_name" )
Name:SetVisible( false )
Name:SizeToContents()

local Health = vgui.Create( "DCheckBoxLabel", MainMenu )
Health:SetPos( 100, 70 )
Health:SetText( "Health" )
Health:SetConVar( "f_esp_health" )
Health:SetVisible( false )
Health:SizeToContents()

local Weapon = vgui.Create( "DCheckBoxLabel", MainMenu )
Weapon:SetPos( 100, 90 )
Weapon:SetText( "Weapon" )
Weapon:SetConVar( "f_esp_weapon" )
Weapon:SetVisible( false )
Weapon:SizeToContents()

local Distance = vgui.Create( "DCheckBoxLabel", MainMenu )
Distance:SetPos( 100, 110 )
Distance:SetText( "Distance" )
Distance:SetConVar( "f_esp_distance" )
Distance:SetVisible( false )
Distance:SizeToContents()

local Box = vgui.Create( "DCheckBoxLabel", MainMenu )
Box:SetPos( 100, 130 )
Box:SetText( "Box" )
Box:SetConVar( "f_esp_box" )
Box:SetVisible( false )
Box:SizeToContents()

local NPC = vgui.Create( "DCheckBoxLabel", MainMenu )
NPC:SetPos( 100, 150 )
NPC:SetText( "Include NPC's" )
NPC:SetConVar( "" )
NPC:SetVisible( false )
NPC:SizeToContents()

local RP = vgui.Create( "DCheckBoxLabel", MainMenu )
RP:SetPos( 100, 170 )
RP:SetText( "Roleplay Entities" )
RP:SetConVar( "" )
RP:SetVisible( false )
RP:SizeToContents()

local SBOX = vgui.Create( "DCheckBoxLabel", MainMenu )
SBOX:SetPos( 100, 190 )
SBOX:SetText( "Sandbox Entities" )
SBOX:SetConVar( "" )
SBOX:SetVisible( false )
SBOX:SizeToContents()

local cPlayer = vgui.Create( "DCheckBoxLabel", MainMenu )
cPlayer:SetPos( 200, 70 )
cPlayer:SetText( "Include Players" )
cPlayer:SetConVar( "" )
cPlayer:SetVisible( false )
cPlayer:SizeToContents()

local cNPC = vgui.Create( "DCheckBoxLabel", MainMenu )
cNPC:SetPos( 200, 90 )
cNPC:SetText( "Include NPC's" )
cNPC:SetConVar( "" )
cNPC:SetVisible( false )
cNPC:SizeToContents()

local cWeapons = vgui.Create( "DCheckBoxLabel", MainMenu )
cWeapons:SetPos( 200, 110 )
cWeapons:SetText( "Include Weapons" )
cWeapons:SetConVar( "" )
cWeapons:SetVisible( false )
cWeapons:SizeToContents()

local cEntity = vgui.Create( "DCheckBoxLabel", MainMenu )
cEntity:SetPos( 200, 130 )
cEntity:SetText( "Include Entitys" )
cEntity:SetConVar( "" )
cEntity:SetVisible( false )
cEntity:SizeToContents()

local MaxDistance = vgui.Create( "DNumSlider", MainMenu )
MaxDistance:SetPos( 100, 259 )
MaxDistance:SetSize( 470, 200 )
MaxDistance:SetText( "Max Distance" )
MaxDistance:SetMin( 0 )
MaxDistance:SetMax( 10000 )
MaxDistance:SetVisible( false )
MaxDistance:SetDecimals( 0 )
MaxDistance:SetConVar( "f_esp_max_distance" )

local Chamtype = vgui.Create( "DMultiChoice", MainMenu )
Chamtype:SetPos( 200, 50 )
Chamtype:SetSize( 130, 20 )
Chamtype:SizeToContents()
Chamtype:AddChoice( "Soild" )
Chamtype:AddChoice( "Wireframe" )
Chamtype:AddChoice( "XQZ" )
Chamtype:SetVisible( false )
	local CLabel = vgui.Create( "DLabel", MainMenu )
	CLabel:SetPos( 230, 30 )
	CLabel:SetText( "- Cham type -" )
	CLabel:SizeToContents()
	CLabel:SetTextColor( Color( 255, 0, 0, 255 ) )
	CLabel:SetVisible( false )


local NList = vgui.Create( "DComboBox", MainMenu )
NList:SetPos( 340, 50 )
NList:SetSize( 100, 140 )
NList:SetMultiple( false )
NList:SetVisible( false )
	local NLabel = vgui.Create( "DLabel", MainMenu )
	NLabel:SetPos( 360, 30 )
	NLabel:SetText( "- Removed -" )
	NLabel:SizeToContents()
	NLabel:SetTextColor( Color( 255, 0, 0, 255 ) )
	NLabel:SetVisible( false )


local SList = vgui.Create( "DComboBox", MainMenu )
SList:SetPos( 470, 50 )
SList:SetSize( 100, 140 )
SList:SetMultiple( false )
SList:SetVisible( false )
	local SLabel = vgui.Create( "DLabel", MainMenu )
	SLabel:SetPos( 490, 30 )
	SLabel:SetText( "- Added -" )
	SLabel:SizeToContents()
	SLabel:SetTextColor( Color( 255, 0, 0, 255 ) )
	SLabel:SetVisible( false )
	
	
// OTHER

local Crosshair = vgui.Create( "DCheckBoxLabel", MainMenu )
Crosshair:SetPos( 100, 50 )
Crosshair:SetText( "Crosshair" )
Crosshair:SetConVar( "f_vis_crosshair" )
Crosshair:SetVisible( false )
Crosshair:SizeToContents()

local Bunnyhop = vgui.Create( "DCheckBoxLabel", MainMenu )
Bunnyhop:SetPos( 100, 70 )
Bunnyhop:SetText( "Bunny hop" )
Bunnyhop:SetConVar( "f_misc_bunnyhop" )
Bunnyhop:SetVisible( false )
Bunnyhop:SizeToContents()

local Autopistol = vgui.Create( "DCheckBoxLabel", MainMenu )
Autopistol:SetPos( 100, 90 )
Autopistol:SetText( "Autopistol" )
Autopistol:SetConVar( "" )
Autopistol:SetVisible( false )
Autopistol:SizeToContents()

local DynamicLights = vgui.Create( "DCheckBoxLabel", MainMenu )
DynamicLights:SetPos( 100, 110 )
DynamicLights:SetText( "Dynamic Lights" )
DynamicLights:SetConVar( "f_vis_dynamiclights" )
DynamicLights:SetVisible( false )
DynamicLights:SizeToContents()

local Radar = vgui.Create( "DCheckBoxLabel", MainMenu )
Radar:SetPos( 100, 130 )
Radar:SetText( "Radar" )
Radar:SetConVar( "f_radar" )
Radar:SetVisible( false )
Radar:SizeToContents()




// CUSTOM TABS
local AimImage = vgui.Create( "DImageButton", MainMenu )
AimImage:SetPos( 10, 50 )
AimImage:SetImage( "precisionbot/aimbot.vtf" )
AimImage:SizeToContents()
AimImage.DoClick = function()
	// Enabled
	Aimbot:SetVisible( true )
	Autoshoot:SetVisible( true )
	Aimthur:SetVisible( true )
	Autoreload:SetVisible( true )
	Friendlyfire:SetVisible( true )
	Aimply:SetVisible( true )
	Aimnpc:SetVisible( true )
	Aimadmins:SetVisible( true )
	Aimsteam:SetVisible( true )
	FOV:SetVisible( true )
	Smooth:SetVisible( true )
	Bone:SetVisible( true )
	TargetDistance:SetVisible( true )
	EList:SetVisible( true )
	FList:SetVisible( true )
	FLabel:SetVisible( true )
	ELabel:SetVisible( true )
	Aimby:SetVisible( true )
	ALabel:SetVisible( true )
	Aimrecoil:SetVisible( true )
	Showtarget:SetVisible( true )

	// Disabled
	Name:SetVisible( false )
	Health:SetVisible( false )
	Weapon:SetVisible( false )
	Distance:SetVisible( false )
	Box:SetVisible( false )
	NPC:SetVisible( false )
	RP:SetVisible( false )
	SBOX:SetVisible( false )
	NList:SetVisible( false )
	SList:SetVisible( false )
	NLabel:SetVisible( false )
	SLabel:SetVisible( false )
	Chamtype:SetVisible( false )
	CLabel:SetVisible( false )
	HelloLabel:SetVisible( false )
	MaxDistance:SetVisible( false )
	cPlayer:SetVisible( false )
	cNPC:SetVisible( false )
	cEntity:SetVisible( false )
	cWeapons:SetVisible( false )
	Crosshair:SetVisible( false )
	Bunnyhop:SetVisible( false )
	Autopistol:SetVisible( false )
	DynamicLights:SetVisible( false )
	Radar:SetVisible( false )
end

local ESPImage = vgui.Create( "DImageButton", MainMenu )
ESPImage:SetPos( 10, 150 )
ESPImage:SetImage( "precisionbot/esp.vtf" )
ESPImage:SizeToContents()
ESPImage.DoClick = function()
	// Enabled
	Name:SetVisible( true )
	Health:SetVisible( true )
	Weapon:SetVisible( true )
	Distance:SetVisible( true )
	Box:SetVisible( true )
	NPC:SetVisible( true )
	RP:SetVisible( true )
	SBOX:SetVisible( true )
	NList:SetVisible( true )
	SList:SetVisible( true )
	NLabel:SetVisible( true )
	SLabel:SetVisible( true )
	MaxDistance:SetVisible( true )
	Chamtype:SetVisible( true )
	CLabel:SetVisible( true )
	cPlayer:SetVisible( true )
	cNPC:SetVisible( true )
	cEntity:SetVisible( true )
	cWeapons:SetVisible( true )
	
	// Disabled
	Aimbot:SetVisible( false )
	Autoshoot:SetVisible( false )
	Aimthur:SetVisible( false )
	Autoreload:SetVisible( false )
	Friendlyfire:SetVisible( false )
	Aimply:SetVisible( false )
	Aimnpc:SetVisible( false )
	Aimadmins:SetVisible( false )
	Aimsteam:SetVisible( false )
	FOV:SetVisible( false )
	Smooth:SetVisible( false )
	Bone:SetVisible( false )
	TargetDistance:SetVisible( false )
	EList:SetVisible( false )
	FList:SetVisible( false )
	FLabel:SetVisible( false )
	ELabel:SetVisible( false )
	Aimby:SetVisible( false )
	ALabel:SetVisible( false )
	HelloLabel:SetVisible( false )
	Aimrecoil:SetVisible( false )
	Showtarget:SetVisible( false )
	Crosshair:SetVisible( false )
	Bunnyhop:SetVisible( false )
	Autopistol:SetVisible( false )
	DynamicLights:SetVisible( false )
	Radar:SetVisible( false )
end

local MisImage = vgui.Create( "DImageButton", MainMenu )
MisImage:SetPos( 10, 250 )
MisImage:SetImage( "precisionbot/misc.vtf" )
MisImage:SizeToContents()
MisImage.DoClick = function()
	// Enabled
	Crosshair:SetVisible( true )
	Bunnyhop:SetVisible( true )
	Autopistol:SetVisible( true )
	DynamicLights:SetVisible( true )
	Radar:SetVisible( true )
	
	// Disabled
	Aimbot:SetVisible( false )
	Autoshoot:SetVisible( false )
	Aimthur:SetVisible( false )
	Autoreload:SetVisible( false )
	Friendlyfire:SetVisible( false )
	Aimply:SetVisible( false )
	Aimnpc:SetVisible( false )
	Aimadmins:SetVisible( false )
	Aimsteam:SetVisible( false )
	FOV:SetVisible( false )
	Smooth:SetVisible( false )
	Bone:SetVisible( false )
	TargetDistance:SetVisible( false )
	EList:SetVisible( false )
	FList:SetVisible( false )
	FLabel:SetVisible( false )
	ELabel:SetVisible( false )
	Aimby:SetVisible( false )
	ALabel:SetVisible( false )
	HelloLabel:SetVisible( false )
	Aimrecoil:SetVisible( false )
	Showtarget:SetVisible( false )
	Name:SetVisible( false )
	Health:SetVisible( false )
	Weapon:SetVisible( false )
	Distance:SetVisible( false )
	Box:SetVisible( false )
	NPC:SetVisible( false )
	RP:SetVisible( false )
	SBOX:SetVisible( false )
	NList:SetVisible( false )
	SList:SetVisible( false )
	NLabel:SetVisible( false )
	SLabel:SetVisible( false )
	Chamtype:SetVisible( false )
	CLabel:SetVisible( false )
	HelloLabel:SetVisible( false )
	MaxDistance:SetVisible( false )
	cPlayer:SetVisible( false )
	cNPC:SetVisible( false )
	cEntity:SetVisible( false )
	cWeapons:SetVisible( false )
end
end
concommand.Add( "f_menu", DrawMenu )