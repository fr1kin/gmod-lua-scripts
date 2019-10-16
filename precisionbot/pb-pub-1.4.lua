/*
Precisionbot v1.4
-----------------
Changelog:
-----------------
Proofing methods.
Hiding hooks.
New menu.
-----------------
Credits:
-----------------
RabidToaster Hiding Hooks
kolbybrooks  Hook Script
AzuiSleet    ConVar Bypasser ( Module )
Eusion       Box Script
Deco         No-Spread ( Module )
*/

local PB = {}
local Hooks = {}

// ********************
// Main Functions:
// ********************

// Required - These are the modules used in this cheat; I didn't make them.
require( "commands" )
require( "deco" )

// Commands - Console commands.
CreateClientConVar( "pb_disable", "0", true, false )
CreateClientConVar( "pb_esp_name", "0", true, false )
CreateClientConVar( "pb_esp_health", "0", true, false )
CreateClientConVar( "pb_esp_weapon", "0", true, false )
CreateClientConVar( "pb_esp_distance", "0", true, false )
CreateClientConVar( "pb_esp_box", "0", true, false )
CreateClientConVar( "pb_esp_entity_rp", "0", true, false )
CreateClientConVar( "pb_esp_color", "0", true, false )
CreateClientConVar( "pb_esp_npc", "0", true, false )
CreateClientConVar( "pb_esp_max", "5000", true, false )
CreateClientConVar( "pb_vis_crosshair", "1", true, false )
CreateClientConVar( "pb_vis_dynamiclights", "0", true, false )
CreateClientConVar( "pb_misc_bypass", "1", true, false )
CreateClientConVar( "pb_misc_radar", "1", true, false )
CreateClientConVar( "pb_misc_radar_r", "0", true, false )
CreateClientConVar( "pb_misc_radar_g", "255", true, false )
CreateClientConVar( "pb_misc_radar_b", "0", true, false )
CreateClientConVar( "pb_misc_radar_a", "50", true, false )
CreateClientConVar( "pb_misc_radar_x", "10", true, false )
CreateClientConVar( "pb_misc_radar_y", "10", true, false )

// LUA Commands - To make this easy.
local ply	   = LocalPlayer()
local e		   = ent
local x 	   = ScrW() / 2
local y 	   = ScrH() / 2

// Fonts - Main fonts used in the cheat. You must download visitor2 for this to work.
surface.CreateFont( "Visitor TT2 BRK", 10, 200, true, false, "VISITOR2" )


// Hooking - Servers will block your hooks if you don't do this. I'm going to recode this later, but I'm not sure if its doing anything right now.
function Random()
	local j, r = 0, ""

	for i = 1, math.random(3, 19) do
		j = math.random(65, 116)
		if ( j > 90 && j < 97 ) then j = j + 6 end
		r = r .. string.char(j)
	end
	return r
end

function NewHook( h, f )
	local n = Random()
	Hooks[n] = h
	hook.Add( h, n, f )
end

// Get Admin - Finds the current admins then then prints what level of admin they are.
function GetAdmin( e )
		if e:IsAdmin() and not e:IsSuperAdmin() then return ( " | Admin" )
		elseif e:IsSuperAdmin() then return ( " | Super Admin" )
		elseif not e:IsAdmin() and not e:IsSuperAdmin() then return ( "" ) 
	end
end

// ********************
// Extra Sensory:
// ********************
function PB.Display( e )
	for _, e in pairs(ents.GetAll()) do
		local ply	= LocalPlayer()
		if ( e:IsPlayer() && e:Alive() == true ) && ( e ~=ply ) then
			local pos	= e:GetPos():ToScreen()
			local tn	= team.GetName( e:Team() )
			local tc	= team.GetColor( e:Team() )
			local dis	= math.floor( tostring( e:GetPos():Distance( ply:GetShootPos() ) ) )
			
			if e:IsValid() then // I had to run this because the script was breaking.
			
			// If the player(s) are in this distance then it will draw everything below.
			if dis <= GetConVarNumber( "pb_esp_max" ) then
			
			// Extra sensory color type, if you want it to be based off their team color or allies/enemyies.
			local col
				if ( GetConVarNumber( "pb_esp_color" ) == 0 ) then
						col = Color( tc.r, tc.g, tc.b, 255 )
					end
				if ( GetConVarNumber( "pb_esp_color" ) == 1 ) then
					if e:Team() == ply:Team() then
						col = Color( 0, 255, 0, 255 )
					elseif e:Team() ~= ply:Team() then
						col = Color( 255, 0, 0, 255 )
					end
				end
				
			// Real Extra sensory code.
				if ( GetConVarNumber( "pb_esp_name" ) == 1 ) then
					draw.SimpleText( e:Nick() .. " | " .. tn .. GetAdmin( e ), "VISITOR2", pos.x, pos.y, col, 0, 2 )
				end
				
				if ( GetConVarNumber( "pb_esp_health" ) == 1 ) then
					draw.SimpleText( "HP: " .. e:Health(), "VISITOR2", pos.x, pos.y + 10, col, 0, 2 )
				end
				
				if ( GetConVarNumber( "pb_esp_weapon" ) == 1 ) then
					if e:GetActiveWeapon():IsValid() then
					local wep = e:GetActiveWeapon():GetPrintName()
					local wep = string.Replace( wep, "#HL2_", "" )
					local wep = string.Replace( wep, "#GMOD_", "" )
					local wep = string.upper( wep )
					draw.SimpleText( "W: " .. wep, "VISITOR2", pos.x , pos.y + 20, col, 0, 2 )
				end
			end
					
				if ( GetConVarNumber( "pb_esp_box" ) == 1 ) then
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

					surface.SetDrawColor(col.r, col.g, col.b, 150)

					surface.DrawLine(xmax,ymax,xmax,ymin)
					surface.DrawLine(xmax,ymin,xmin,ymin)
					surface.DrawLine(xmin,ymin,xmin,ymax)
					surface.DrawLine(xmin,ymax,xmax,ymax)
					end

				if dis >= GetConVarNumber( "pb_esp_max" ) then
					if ( GetConVarNumber( "pb_esp_name" ) == 1 ) then
							draw.SimpleText( e:Nick() .. " | " .. tn .. GetAdmin( e ), "VISITOR2", pos.x, pos.y, col, 1, 1 )
						end
					end
				end
			end
		end
	end
end
NewHook( "HUDPaint", PB.Display )

// ********************
// Visuals:
// ********************
function Drawcrosshair()
	if GetConVarNumber( "pb_vis_crosshair" ) == 1 then
	local cross 	= {}
	cross.x			= x				  				// Centure screen.																DEF = x
	cross.y			= y 			  				// Centure screen.																DEF = y
	cross.tall		= 40					  		// Highth of the line.															DEF = 20
	cross.wide		= 40					  		// Width of the line.															DEF = 20
	cross.color		= Color( 0, 255, 0, 255 )		// Crosshair color.																DEF = Color( 0, 255, 0, 255 )
	cross.dotcol	= Color( 255, 0, 0, 255 )		// Crosshair dot color.															DEF = Color( 255, 0, 0, 255 )
	cross.xd		= cross.x - 2					// Crosshair dot - 2.															DEF = cross.x - 2
	cross.yd		= cross.y - 2					// Crosshair dot - 2.															DEF = cross.y - 2

		// GUI
			surface.SetDrawColor( cross.color )
			surface.DrawLine( cross.x, cross.y - cross.tall, cross.x, cross.y + cross.tall )
			surface.DrawLine( cross.x - cross.wide, cross.y, cross.x + cross.wide, cross.y )
			draw.RoundedBox( 1, cross.xd, cross.yd, 5, 5, cross.dotcol )
		end
	end
NewHook( "HUDPaint", Drawcrosshair )

function Drawdynamiclights()
	if GetConVarNumber( "pb_vis_dynamiclights" ) == 1 then
	local dlights = {}
	dlights.ssize	= 500							// Self dynamiclight size.														DEF = 200
	dlights.asize	= 500							// Everyone dynamiclight size.													DEF = 500
	dlights.all		= true							// Dynamiclights for everyone.													DEF = true
	dlights.self	= false							// Dynamiclights for only you're self.											DEF = fals
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
NewHook( "HUDPaint", Drawdynamiclights )

// ********************
// Radar:
// ********************
function Drawradar()
	if GetConVarNumber( "pb_misc_radar" ) == 1 then
	
	local radar 	= {}
	radar.x 		= GetConVarNumber( "pb_misc_radar_x" )		  // X postition of the radar.  													DEF = 10
	radar.y			= GetConVarNumber( "pb_misc_radar_y" )		  // Y postition of the radar.  													DEF = 10
	radar.round		= 0						  					  // The roundness of the radar.  												DEF = 0
	radar.size 		= 200					  					  // Size of radar.  																DEF = 200
	radar.selfsize	= 5						  					  // Your box size. 																DEF = 5
	radar.selfround = 1						  					  // Roundness of you're dot.														DEF = 1
	radar.csize		= 90					  					  // Centure line size.															DEF = 90
	red				= GetConVarNumber( "pb_misc_radar_r" )	  	  // Redcolor																		DEF =
	green			= GetConVarNumber( "pb_misc_radar_g" )	 	  // Greencolor																	DEF =
	blue			= GetConVarNumber( "pb_misc_radar_b" )	  	  // Bluecolor																	DEF =
	alpha			= GetConVarNumber( "pb_misc_radar_a" )	  	  // Alphacolor																	DEF =
	radar.col		= Color( red, green, blue, alpha ) 			  // Radar Color
	radar.outcol	= Color( 0, 0, 0, 255 )	  					  // Outline color.																DEF = Color( 0, 0, 0, 255 )
	radar.selfcol	= Color( 0, 0, 255, 000 ) 					  // Your color.																	DEF = Color( 0, 0, 255, 255 )
	radar.radius	= 5000					  					  // How far the radar will scan.													DEF = 5000
	radar.plyname	= true					  					  // Draws player's name.															DEF = false
	radar.plydot	= true					  					  // Draws a player dot on the position of the radar.								DEF = true
	radar.plycol	= Color( 0, 0, 255, 255 ) 					  // Color of the player's name and dot.											DEF = Color( 0, 0, 255, 255 )
	radar.npcdot	= true					  					  // Draws a NPC dot on the position of the radar.								DEF = true
	radar.npccol	= Color( 0, 0, 255, 255 ) 					  // Color of the NPC's name and dot.												DEF = Color( 0, 0, 255, 255 )
	radar.enpcol	= Color( 255, 0, 0, 255 ) 					  // Enemies color.																DEF = Color( 255, 0, 0, 255 )
	radar.half		= radar.size / 2		  					  // Divides the size by two to make a centured cross.
	radar.selfhalf	= radar.selfsize / 2	 			 		  // Divides the box size by 2 to centure it.
	radar.xm		= radar.x + radar.half	  					  // Center of radar. (x)
	radar.ym		= radar.y + radar.half	  					  // Center of radar. (y)
	radar.xo		= radar.x				  					  // Radar outline. (x)
	radar.yo		= radar.y				  					  // Radar outline. (y)
  
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
			
		// Radar code thanks to Georg Schmid; I'm only good at creating GUI's n stuff.
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
NewHook( "HUDPaint", Drawradar )

// ********************
// Miscellaneous:
// ********************

// Bunnyhop - Allows you to jump constantly. Note this will not work if a server blocks hooks.
concommand.Add( "+bhop", function()
	hook.Add( "Tick", " ~Bunnyhop", function()
		local ply = LocalPlayer()
			if not ply:IsOnGround() then
				RunConsoleCommand( "-jump" )
			elseif ply:IsOnGround() then
				RunConsoleCommand( "+jump" )
			end
		end )
	end )
concommand.Add( "-bhop", function()
	hook.Remove( "Tick", " ~Bunnyhop" )
end )

// Bypasser - Lets you bypass cheats, consistancy, and pure.
SetConvar( CreateConVar( "sv_cheats", "" ), 1 )
SetConvar( CreateConVar( "sv_consistancy", "" ), 0 )
SetConvar( CreateConVar( "sv_pure", "" ), 0 )

// Speed Hack
concommand.Add( "+speedhack", function()
	SetConvar( CreateConVar( "host_framerate", "" ), .2 )
end )
concommand.Add( "-speedhack", function()
	SetConvar( CreateConVar( "host_framerate", "" ), 0 )
end )


// Hook Removels - Removes some hooks that will mess your screen up.
hook.Remove( "HUDPaint", "ulx_blind" );
hook.Remove("RenderScreenspaceEffects", "Drugged");
hook.Remove("RenderScreenspaceEffects", "durgz_alcohol_high", DoAlcohol);
hook.Remove("RenderScreenspaceEffects", "durgz_cigarette_high", DoCigarettePP);
hook.Remove("RenderScreenspaceEffects", "durgz_cocaine_high", DoCocaine);
hook.Remove("RenderScreenspaceEffects", "durgz_heroine_high", DoHeroine);
hook.Remove("HUDPaint", "durgz_heroine_notice", HeroinNotice);
hook.Remove("RenderScreenspaceEffects", "durgz_lsd_high", DoLSD);
hook.Remove("RenderScreenspaceEffects", "durgz_mushroom_high", DoMushrooms);
hook.Remove("HUDPaint", "durgz_mushroom_awesomeface", DoMushroomsFace);
hook.Remove("RenderScreenspaceEffects", "durgz_weed_high", DoWeed);
hook.Remove("HUDPaint", "FlashEffect", FlashEffect);
hook.Remove("RenderScreenspaceEffects", "StunEffect", StunEffect);
hook.Remove("HUDPaint", "durgz_cigarette_msg", DoCigarette)
hook.Remove("RenderScreenspaceEffects", "durgz_pcp_high", DoPCP)

// ********************
// Menu VGUI:
// ********************

local function DrawMenu()
		
local xMenu = vgui.Create( "DFrame" )
		xMenu:SetPos( ScrW() / 4.5, ScrH() / 4.5 )
		xMenu:SetSize( 610, 340 )
		xMenu:SetTitle( "[Precisionbot] v1.4" )
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
		xvAimbot:SetConVar( "" )
		
local xAutoshoot = vgui.Create("DLabel", xAimList )
	xAutoshoot:SetPos( 10, 40 )
	xAutoshoot:SetText( "Autoshoot" )
	xAutoshoot:SetTextColor( Color(0, 0, 0, 255) )
		local xvAutoshoot = vgui.Create( "DNumberWang", xAimList )
		xvAutoshoot:SetPos( 500, 40 )
		xvAutoshoot:SetMin( 0 )
		xvAutoshoot:SetMax( 1 )
		xvAutoshoot:SetDecimals( 0 )
		xvAutoshoot:SetConVar( "" )
		
local xAutowall = vgui.Create("DLabel", xAimList )
	xAutowall:SetPos( 10, 70 )
	xAutowall:SetText( "Auto Wall" )
	xAutowall:SetTextColor( Color(0, 0, 0, 255) )
		local xvAutoWall = vgui.Create( "DNumberWang", xAimList )
		xvAutoWall:SetPos( 500, 70 )
		xvAutoWall:SetMin( 0 )
		xvAutoWall:SetMax( 1 )
		xvAutoWall:SetDecimals( 0 )
		xvAutoWall:SetConVar( "" )
		
local xFF = vgui.Create("DLabel", xAimList )
	xFF:SetPos( 10, 100 )
	xFF:SetText( "Friendly Fire" )
	xFF:SetTextColor( Color(0, 0, 0, 255) )
		local xvFF = vgui.Create( "DNumberWang", xAimList )
		xvFF:SetPos( 500, 100 )
		xvFF:SetMin( 0 )
		xvFF:SetMax( 1 )
		xvFF:SetDecimals( 0 )
		xvFF:SetConVar( "" )

local xAim = vgui.Create("DLabel", xAimList )
	xAim:SetPos( 10, 130 )
	xAim:SetText( "Aim Targets" )
	xAim:SetTextColor( Color(0, 0, 0, 255) )
		local xvAim = vgui.Create( "DNumberWang", xAimList )
		xvAim:SetPos( 500, 130 )
		xvAim:SetMin( 0 )
		xvAim:SetMax( 3 )
		xvAim:SetDecimals( 0 )
		xvAim:SetConVar( "" )
		
local xFOV = vgui.Create("DLabel", xAimList )
	xFOV:SetPos( 10, 160 )
	xFOV:SetText( "Field of View" )
	xFOV:SetTextColor( Color(0, 0, 0, 255) )
		local xvFOV = vgui.Create( "DNumberWang", xAimList )
		xvFOV:SetPos( 500, 160 )
		xvFOV:SetMin( 0 )
		xvFOV:SetMax( 360 )
		xvFOV:SetDecimals( 0 )
		xvFOV:SetConVar( "" )
		
local xBone = vgui.Create("DLabel", xAimList )
	xBone:SetPos( 10, 190 )
	xBone:SetText( "Target Bone" )
	xBone:SetTextColor( Color(0, 0, 0, 255) )
		local xvBone = vgui.Create( "DNumberWang", xAimList )
		xvBone:SetPos( 500, 190 )
		xvBone:SetMin( 0 )
		xvBone:SetMax( 14 )
		xvBone:SetDecimals( 0 )
		xvBone:SetConVar( "" )
		
local xSmooth = vgui.Create("DLabel", xAimList )
	xSmooth:SetPos( 10, 220 )
	xSmooth:SetText( "Smooth Aim" )
	xSmooth:SetTextColor( Color(0, 0, 0, 255) )
		local xvSmooth = vgui.Create( "DNumberWang", xAimList )
		xvSmooth:SetPos( 500, 220 )
		xvSmooth:SetMin( 0 )
		xvSmooth:SetMax( 10 )
		xvSmooth:SetDecimals( 0 )
		xvSmooth:SetConVar( "" )
	
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
		xvName:SetConVar( "" )
	
local xHealth = vgui.Create("DLabel", xESPList )
	xHealth:SetPos( 10, 40 )
	xHealth:SetText( "Health" )
	xHealth:SetTextColor( Color(0, 0, 0, 255) )
		local xvHealth = vgui.Create( "DNumberWang", xESPList )
		xvHealth:SetPos( 500, 40 )
		xvHealth:SetMin( 0 )
		xvHealth:SetMax( 1 )
		xvHealth:SetDecimals( 0 )
		xvHealth:SetConVar( "" )
	
local xWeapon = vgui.Create("DLabel", xESPList )
	xWeapon:SetPos( 10, 70 )
	xWeapon:SetText( "Info" )
	xWeapon:SetTextColor( Color(0, 0, 0, 255) )
		local xvWeapon = vgui.Create( "DNumberWang", xESPList )
		xvWeapon:SetPos( 500, 70 )
		xvWeapon:SetMin( 0 )
		xvWeapon:SetMax( 4 )
		xvWeapon:SetDecimals( 0 )
		xvWeapon:SetConVar( "" )
	
local xBox = vgui.Create("DLabel", xESPList )
	xBox:SetPos( 10, 100 )
	xBox:SetText( "Optical" )
	xBox:SetTextColor( Color(0, 0, 0, 255) )
		local xvBox = vgui.Create( "DNumberWang", xESPList )
		xvBox:SetPos( 500, 100 )
		xvBox:SetMin( 0 )
		xvBox:SetMax( 1 )
		xvBox:SetDecimals( 0 )
		xvBox:SetConVar( "" )
		
local xNPC = vgui.Create("DLabel", xESPList )
	xNPC:SetPos( 10, 130 )
	xNPC:SetText( "Include NPC's" )
	xNPC:SetTextColor( Color(0, 0, 0, 255) )
		local xvNPC = vgui.Create( "DNumberWang", xESPList )
		xvNPC:SetPos( 500, 130 )
		xvNPC:SetMin( 0 )
		xvNPC:SetMax( 2 )
		xvNPC:SetDecimals( 0 )
		xvNPC:SetConVar( "" )
		
local xEntity = vgui.Create("DLabel", xESPList )
	xEntity:SetPos( 10, 160 )
	xEntity:SetText( "Roleplay" )
	xEntity:SetTextColor( Color(0, 0, 0, 255) )
		local xvEntity = vgui.Create( "DNumberWang", xESPList )
		xvEntity:SetPos( 500, 160 )
		xvEntity:SetMin( 0 )
		xvEntity:SetMax( 2 )
		xvEntity:SetDecimals( 0 )
		xvEntity:SetConVar( "" )
		
local xWeapone = vgui.Create("DLabel", xESPList )
	xWeapone:SetPos( 10, 190 )
	xWeapone:SetText( "Sandbox" )
	xWeapone:SetTextColor( Color(0, 0, 0, 255) )
		local xvWeapone = vgui.Create( "DNumberWang", xESPList )
		xvWeapone:SetPos( 500, 190 )
		xvWeapone:SetMin( 0 )
		xvWeapone:SetMax( 1 )
		xvWeapone:SetDecimals( 0 )
		xvWeapone:SetConVar( "" )

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
		xvCrosshair:SetConVar( "" )
		
local xDL = vgui.Create("DLabel", xVisList )
	xDL:SetPos( 10, 40 )
	xDL:SetText( "Dynamic Lights" )
	xDL:SetTextColor( Color(0, 0, 0, 255) )
		local xvDL = vgui.Create( "DNumberWang", xVisList )
		xvDL:SetPos( 500, 40 )
		xvDL:SetMin( 0 )
		xvDL:SetMax( 1000 )
		xvDL:SetDecimals( 0 )
		xvDL:SetConVar( "" )
		
local xDLS = vgui.Create("DLabel", xVisList )
	xDLS:SetPos( 10, 70 )
	xDLS:SetText( "All DLights" )
	xDLS:SetTextColor( Color(0, 0, 0, 255) )
		local xvDLS = vgui.Create( "DNumberWang", xVisList )
		xvDLS:SetPos( 500, 70 )
		xvDLS:SetMin( 0 )
		xvDLS:SetMax( 1 )
		xvDLS:SetDecimals( 0 )
		xvDLS:SetConVar( "" )

local xCham = vgui.Create("DLabel", xVisList )
	xCham:SetPos( 10, 100 )
	xCham:SetText( "Cham" )
	xCham:SetTextColor( Color(0, 0, 0, 255) )
		local xvCham = vgui.Create( "DNumberWang", xVisList )
		xvCham:SetPos( 500, 100 )
		xvCham:SetMin( 0 )
		xvCham:SetMax( 2 )
		xvCham:SetDecimals( 0 )
		xvCham:SetConVar( "" )

local xBarrel = vgui.Create("DLabel", xVisList )
	xBarrel:SetPos( 10, 130 )
	xBarrel:SetText( "Barrel" )
	xBarrel:SetTextColor( Color(0, 0, 0, 255) )
		local xvBarrel = vgui.Create( "DNumberWang", xVisList )
		xvBarrel:SetPos( 500, 130 )
		xvBarrel:SetMin( 0 )
		xvBarrel:SetMax( 1 )
		xvBarrel:SetDecimals( 0 )
		xvBarrel:SetConVar( "" )

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
		xvRecoil:SetConVar( "" )
		
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
		xvAF:SetConVar( "" )

local xNS = vgui.Create("DLabel", xOthList )
	xNS:SetPos( 10, 70 )
	xNS:SetText( "Name Stealer" )
	xNS:SetTextColor( Color(0, 0, 0, 255) )
		local xvNS = vgui.Create( "DNumberWang", xOthList )
		xvNS:SetPos( 500, 70 )
		xvNS:SetMin( 0 )
		xvNS:SetMax( 2 )
		xvNS:SetDecimals( 0 )
		xvNS:SetConVar( "f_namesteal" )
		
local xM = vgui.Create("DLabel", xOthList )
	xM:SetPos( 10, 40 )
	xM:SetText( "Server Crash" )
	xM:SetTextColor( Color(0, 0, 0, 255) )
		local xvM = vgui.Create( "DNumberWang", xOthList )
		xvM:SetPos( 500, 40 )
		xvM:SetMin( 0 )
		xvM:SetMax( 1 )
		xvM:SetDecimals( 0 )
		xvM:SetConVar( "" )
		
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
		xvMS:SetConVar( "" )
			local xSpam = vgui.Create("DTextEntry", xOthList, "Message")  
			xSpam:SetSize( 140, 20)  
			xSpam:SetPos( 350, 100)  
			xSpam:SetKeyboardInputEnabled( true )  
			xSpam:SetEnabled( true )   
			xSpam.MessageBox = SpamText:GetString()
			xSpam:SetConVar( "" )
		
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
xxGreen:SetConVar( "" )
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
xxAlpha:SetConVar( "" )
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
xxxRed:SetConVar( "" )
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
xxxGreen:SetConVar( "" )
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
xxxBlue:SetConVar( "" )
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
xxxAlpha:SetConVar( "" )
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
xDISMAX:SetConVar( "" )
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
ccRed:SetConVar( "pb_misc_radar_r" )
	local cRed = vgui.Create("DLabel", xRadList )
	cRed:SetPos( 10, 50 )
	cRed:SetText( "Red" )
	cRed:SetTextColor( Color(0, 0, 0, 255) )
 
 local ccGreen = vgui.Create( "DNumSlider", xRadList )
ccGreen:SetPos( 10, 100 )
ccGreen:SetWide( 200 )
ccGreen:SetText( "pb_misc_radar_g" )
ccGreen:SetMin( 0 )
ccGreen:SetMax( 255 )
ccGreen:SetDecimals( 0 )
ccGreen:SetConVar( "" )
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
ccBlue:SetConVar( "pb_misc_radar_b" )
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
ccAlpha:SetConVar( "pb_misc_radar_a" )
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
ccX:SetConVar( "pb_misc_radar_x" )
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
ccY:SetConVar( "pb_misc_radar_y" )
	local cY = vgui.Create("DLabel", xRadList )
	cY:SetPos( 250, 200 )
	cY:SetText( "Radar Y" )
	cY:SetTextColor( Color(0, 0, 0, 255) )
	
local xRadar = vgui.Create( "DCheckBoxLabel", xRadList)
xRadar:SetPos( 250, 25 )
xRadar:SetText( "Radar" )
xRadar:SetConVar( "pb_misc_radar" )
xRadar:SetTextColor( Color(0, 0, 0, 255) )
xRadar:SizeToContents()

xIteamSheet:AddSheet( "Aimbot", xAimList, "gui/silkicons/shield", false, false, "Automatic Aiming" )
xIteamSheet:AddSheet( "ESP", xESPList, "gui/silkicons/group", false, false, "Extra Sensory Perception" )
xIteamSheet:AddSheet( "Visuals", xVisList, "gui/silkicons/star", false, false, "Player Visuals, Chams, Crosshair..." )
xIteamSheet:AddSheet( "Removels", xRemList, "gui/silkicons/bomb", false, false, "No-Recoil." )
xIteamSheet:AddSheet( "Miscellaneous", xOthList, "gui/silkicons/plugin", false, false, "Other features..." )
xIteamSheet:AddSheet( "Colors", xColList, "gui/silkicons/wrench", false, false, "Ajust Colors with Entity's and NPC's." )
xIteamSheet:AddSheet( "Extra Settings", xExtList, "gui/silkicons/box", false, false, "Other Settings for features." )
xIteamSheet:AddSheet( "Radar", xRadList, "gui/silkicons/box", false, false, "Radar settings." )
end
concommand.Add( "pb_menu", DrawMenu )