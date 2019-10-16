if !( CLIENT ) then return end

/*------------------------------------------------------------------------------------------------------
 ____  ____  ____  ___  ____  ___  ____  _____  _  _  ____  _____  ____ 
(  _ \(  _ \( ___)/ __)(_  _)/ __)(_  _)(  _  )( \( )(  _ \(  _  )(_  _)
 )___/ )   / )__)( (__  _)(_ \__ \ _)(_  )(_)(  )  (  ) _ < )(_)(   )(  
(__)  (_)\_)(____)\___)(____)(___/(____)(_____)(_)\_)(____/(_____) (__) 
Precisionbot v1.3 Public

by fr1kin, also credits to:
kolbybrooks
Flapadar
Seth
*/------------------------------------------------------------------------------------------------------

local concommand 			= concommand
local cvars 				= cvars
local debug 				= debug
local ents 					= ents
local file					= file
local hook 					= hook
local math 					= math
local spawnmenu				= spawnmenu
local string 				= string
local surface 				= surface
local table 				= table
local timer 				= timer
local util 					= util
local vgui 					= vgui

local Angle 				= Angle
local CreateClientConVar 	= CreateClientConVar
local CurTime 				= CurTime
local ErrorNoHalt			= ErrorNoHalt
local FrameTime 			= FrameTime
local GetConVarString 		= GetConVarString
local GetViewEntity 		= GetViewEntity
local include 				= include
local ipairs 				= ipairs
local LocalPlayer 			= LocalPlayer
local pairs 				= pairs
local pcall 				= pcall
local print 				= print
local RunConsoleCommand 	= RunConsoleCommand
local ScrH 					= ScrH
local ScrW 					= ScrW
local tonumber 				= tonumber
local type 					= type
local unpack 				= unpack
local ValidEntity 			= ValidEntity
local Vector 				= Vector

local PB	= {}
PB.OLD		= {}

PB.Commands = {}
PB.Files 	= { "pb_pub", "pb_wireframemat", "pb_solid_mat" } // Add the the files you use into here, example: PB.Files = { "pb_pub", "other_script" }
PB.Path		= {}
PB.Timers	= {}
PB.Friends	= {}
PB.Entities	= {}

PB.CVars = {
	aim_shoot = 0,
	aim_friends = 0,
	aim_steam = 0,
	aim_fov = 360,
	aim_recoil = 1,
	aim_distance = 0,
	aim_player = 1,
	aim_info = 0,
	aim_npc = 0,
	aim_reload = 1,
	esp_player = 1,
	esp_npc = 1,
	esp_weapon = 0,
	esp_entity = 0,
	esp_aimspot = 0,
	esp_wallhack = 1,
	esp_barrel = 0,
	esp_dead = 1,
	misc_cross = 0,
	misc_admin = 0,
	misc_bhop = 1,
	misc_auto = 0,
}

PB.PredictWeapons = {
		["weapon_crossbow"] = 3110,
	}

PB.Hooks = {}
PB.SVARS = {}

PB.OLD.GCV			= GetConVar
PB.OLD.CVE			= ConVarExists
PB.OLD.GCVN			= GetConVarNumber
PB.OLD.GCVS			= GetConVarString
PB.OLD.CCCV			= CreateClientConVar
PB.OLD.RCC			= RunConsoleCommand
PB.OLD.ECC			= engineConsoleCommand
PB.OLD.ACC			= AddConsoleCommand
PB.OLD.hook			= table.Copy( hook )
PB.OLD.concommand	= table.Copy( concommand )
PB.OLD.cvars		= table.Copy( cvars )
PB.OLD.file			= table.Copy( file )
PB.OLD.debug		= table.Copy( debug )
PB.OLD.timer		= table.Copy( timer )
PB.OLD.PCC			= _R.Player.ConCommand
PB.OLD.CINT			= _R.ConVar.GetInt
PB.OLD.CBOOL		= _R.ConVar.GetBool

PB.Aiming	= false
PB.Auto		= true
PB.Target	= nil
PB.FilePath	= "lua\\autorun\\client\\pb_pub.lua"
PB.Version	= "1.3"
PB.Prefix	= "pb_"
PB.Angles	= Angle( 0, 0, 0 )
PB.AimAng	= Angle( 0, 0, 0 )
PB.Viewfix	= Angle( 0, 0, 0 )

function PB:Msg( msg )
	return MsgN( "[PB]: " .. msg )
end

// Later if I care about this I will change the method I add hooks.
function PB:AddHook( typ, func )
	local ran = ""
	for i = 1, math.random( 5, 30 ) do
		ran = ran .. string.char( math.random( 65, 117 ) )
	end
	table.insert( PB.Hooks, ran )
	return PB.OLD.hook.Add( typ, ran, func )
end

function PB:AddCommand( name, func )
	table.insert( PB.Commands, name )
	return PB.OLD.concommand.Add( name, func )
end

function PB:CreateTimer( name, time, reps, func )
	table.insert( PB.Timers, name )
	return PB.OLD.timer.Create( name, time, reps, func )
end

function PB.SetUp()
	for k, v in pairs( PB.CVars ) do
		table.insert( PB.SVARS, PB.Prefix .. k )
		PB.OLD.CCCV( PB.Prefix .. k, v, true, false )
	end
end
table.insert( PB.SVARS, "pb_load" )

function PB:GetValue( cvar, val )
	if ( PB.OLD.GCVN( PB.Prefix .. cvar ) == val ) then
		return true
	end
	return false
end

function PB:GetConVarNumber( cvar )
	return PB.OLD.GCVN( string.lower( PB.Prefix .. cvar ) )
end

function PB:DrawText( text, font, x, y, colour, xalign, yalign )

	if ( font == nil ) then font = "Default" end
	if ( x == nil ) then x = 0 end
	if ( y == nil ) then y = 0 end
	
	local curX, curY, curString = x, y, ""
	
	surface.SetFont( font )
	local sizeX, lineHeight = surface.GetTextSize( "\n" )
	
	for i = 1, string.len( text ) do
		local ch = string.sub( text, i, i )
		if ( ch == "\n" ) then
			if ( string.len( curString ) > 0 ) then
				draw.SimpleText( curString, font, curX, curY, colour, xalign, yalign )
			end
			
			curY, curX, curString = curY + ( lineHeight / 2 ), x, ""
			
		elseif ( ch == "\t" ) then
			if ( string.len( curString ) > 0 ) then
				draw.SimpleText( curString, font, curX, curY, colour, xalign, yalign )
			end
			local tmpSizeX,tmpSizeY = surface.GetTextSize( curString )
			curX = math.ceil( ( curX + tmpSizeX ) / 50 ) * 50
			curString = ""
		else
			curString = curString .. ch
		end
	end	
	if ( string.len( curString ) > 0 ) then
		draw.SimpleText( curString, font, curX, curY, colour, xalign, yalign )
	end
end

function PB:NormalText( text, posX, posY, bold, boldlevel, r, g, b, lA, rA )
	if ( bold == true ) then
		return draw.SimpleTextOutlined( text, "Default", posX, posY, Color( r, g, b, 255 ), lA, rA, boldlevel, Color( 0, 0, 0, 255 ) )
	elseif ( bold == false ) then
		return draw.SimpleText( text, "Default", posX, posY, Color( r, g, b, 255 ), lA, rA )
	end
	return draw.SimpleText( text, "Default", posX, posY, Color( r, g, b, 255 ), lA, rA )
end

function PB:IsAdmin(e)
	
	if ( e:IsAdmin() ) then 
		return true
	elseif ( e:IsSuperAdmin() ) then 
		return true
	end
	return false
end

function PB:GetAdminType(e)

	local ply = LocalPlayer()
	
	if ( e:IsAdmin() && !e:IsSuperAdmin() ) then
		return "Admin"
	elseif ( e:IsSuperAdmin() ) then
		return "Super Admin"
	end
	return ""
end

function PB:CreateMaterial()
	
	local BaseInfo = {
		["$basetexture"] = "models/debug/debugwhite",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1,
		["$ignorez"]	 = 1
	}
   
   local mat = CreateMaterial( "pb_wireframemat", "Wireframe", BaseInfo )
   //local mat = CreateMaterial( "pb_solid_mat", "VertexLitGeneric", BaseInfo )

   return mat

end

--[[--------------------------------------
Everything below here is the hack code.
--]]--------------------------------------

function PB:IsValid( e, typ )
	local ply = LocalPlayer()
	if ( typ == true ) then
		if ( !ValidEntity( e ) ) then return false end
		if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !table.HasValue( PB.Entities, e:GetClass() ) || e == ply ) then return false end
		if ( e:IsPlayer() && ( PB:GetValue( "esp_dead", 0 ) && !e:Alive() ) && !string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
		if ( e:IsNPC() && ( e:GetMoveType() == 0 ) ) then return false end
		if ( e:IsWeapon() && ( e:GetMoveType() == 0 ) ) then return false end
		return true
	elseif ( typ == false ) then
		if ( !ValidEntity( e ) ) then return false end
		if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() || e == ply ) then return false end
		if ( e:IsPlayer() && !e:Alive() && !string.find( string.lower( team.GetName( e:Team() ) ), "spec" ) ) then return false end
		if ( e:IsNPC() && ( e:GetMoveType() == 0 ) ) then return false end
		if ( e:IsWeapon() && ( e:GetMoveType() == 0 ) ) then return false end
		return true
	end
	return true
end

function PB:GayClasses( e )
	if ( e:GetClass() == "viewmodel" ) then return false end
	if ( e:GetClass() == "player" ) then return false end
	return true
end

function PB:ConVarEnabled( e )
	if ( PB:GetValue( "esp_wallhack", 0 ) ) then return false end
	if ( e:IsPlayer() && PB:GetValue( "esp_player", 0 ) ) then return false end
	if ( e:IsNPC() && PB:GetValue( "esp_npc", 0 ) ) then return false end
	if ( e:IsWeapon() && PB:GetValue( "esp_weapon", 0 ) ) then return false end
	return true
end

function PB:CreatePos( e )
	local ply, pos = LocalPlayer(), ""
	local col = PB:SetColors( e )
	local center = e:LocalToWorld( e:OBBCenter() )
	local min, max = e:OBBMins(), e:OBBMaxs()
	local dim = max - min
	local z = max + min
	
	local frt	= ( e:GetForward() ) * ( dim.y / 2 )
	local rgt	= ( e:GetRight() ) * ( dim.x / 2 )
	local top	= ( e:GetUp() ) * ( dim.z / 2 )
	local bak	= ( e:GetForward() * -1 ) * ( dim.y / 2 )
	local lft	= ( e:GetRight() * -1 ) * ( dim.x / 2 )
	local btm	= ( e:GetUp() * -1 ) * ( dim.z / 2 )
	
	local d, v	= math.Round( e:GetPos():Distance( ply:GetShootPos() ) )
	if ( e:IsPlayer() ) then v = d / 30 else v = 0 end
	pos = e:LocalToWorld( e:OBBMaxs() ) + Vector( 0, 0, v )
	
	if ( table.HasValue( PB.Entities, e:GetClass() ) ) then
		pos = e:LocalToWorld( e:OBBCenter() )
	end
	
	local FRT 	= center + frt + rgt + top; FRT = FRT:ToScreen()
	local BLB 	= center + bak + lft + btm; BLB = BLB:ToScreen()
	local FLT	= center + frt + lft + top; FLT = FLT:ToScreen()
	local BRT 	= center + bak + rgt + top; BRT = BRT:ToScreen()
	local BLT 	= center + bak + lft + top; BLT = BLT:ToScreen()
	local FRB 	= center + frt + rgt + btm; FRB = FRB:ToScreen()
	local FLB 	= center + frt + lft + btm; FLB = FLB:ToScreen()
	local BRB 	= center + bak + rgt + btm; BRB = BRB:ToScreen()
	
	pos = pos:ToScreen()
	
	local maxX = math.max( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local minX = math.min( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local maxY = math.max( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y)
	local minY = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	
	return maxX, minX, maxY, minY, pos
end

function PB:SetColors( e )

	local ply, class, model = LocalPlayer(), e:GetClass(), e:GetModel()
	local col

	if ( e:IsPlayer() ) then
		col = team.GetColor( e:Team() )
	elseif ( e:IsNPC() ) then
		col = Color( 255, 0, 0, 255 )
	elseif ( e:IsWeapon() ) then
		col = Color( 255, 128, 0, 255 )
	elseif ( table.HasValue( PB.Entities, e:GetClass() ) ) then
		col = Color( 0, 255, 0, 255 )
	else
		col = Color( 255, 255, 255, 255 )
	end
	
	return col
end

function PB:DrawRect( x, y, w, h, col )
    surface.SetDrawColor( col.r, col.g, col.b, col.a )
    surface.DrawRect( x, y, w, h )
end

function PB:Ammo()
	local ply = LocalPlayer()
		if ( ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ply:GetActiveWeapon():GetClass() == "weapon_crossbow" ) then return true end
		if ply && ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() then
		local wep = ply:GetActiveWeapon()
		if !wep then return -1 end
		if wep:Clip1() == 0 then
			return false
		end
	end
	return true	
end

function PB:GetPos( e, pos )
	if ( type( pos ) == "string" ) then
		return ( e:GetBonePosition( e:LookupBone( pos ) ) )
	elseif ( type( pos ) == "Vector" ) then
		return ( e:LocalToWorld( pos ) )
	end
	return ( e:LocalToWorld( pos ) )
end

function PB:WeaponPrediction( e, pos )
	local ply = LocalPlayer()
	if ( ValidEntity( e ) && ( type( e:GetVelocity() ) == "Vector" ) ) then
		local dis, wep = e:GetPos():Distance( ply:GetPos() ), ( ply.GetActiveWeapon && ValidEntity( ply:GetActiveWeapon() ) && ply:GetActiveWeapon():GetClass() )
		if ( wep && PB.PredictWeapons[ wep ]  ) then
			local t = dis / PB.PredictWeapons[ wep ]
			return ( pos + e:GetVelocity() * t )
		end
		return pos
	end
	return pos
end

function PB:GenerateSpot( e )
	local spt = e:LocalToWorld( e:OBBCenter() )
	spt = PB:GetPos( e, "ValveBiped.Bip01_Head1" )
	
	local m = e:GetModel()
	if ( m == "models/crow.mdl" || m == "models/pigeon.mdl" ) then 	spt = PB:GetPos( e, Vector( 0, 0, 5 ) ) end
	if ( m == "models/seagull.mdl" ) then 							spt = PB:GetPos( e, Vector( 0, 0, 6 ) ) end
	if ( m == "models/combine_scanner.mdl" ) then 					spt = PB:GetPos( e, "Scanner.Body" ) end
	if ( m == "models/hunter.mdl" ) then 							spt = PB:GetPos( e, "MiniStrider.body_joint" ) end
	if ( m == "models/combine_turrets/floor_turret.mdl" ) then		spt = PB:GetPos( e, "Barrel" ) end
	if ( m == "models/dog.mdl" ) then 								spt = PB:GetPos( e, "Dog_Model.Eye" ) end
	if ( m == "models/vortigaunt.mdl" ) then 						spt = PB:GetPos( e, "ValveBiped.Head" ) end
	if ( m == "models/antlion.mdl" ) then 							spt = PB:GetPos( e, "Antlion.Body_Bone" ) end
	if ( m == "models/antlion_guard.mdl" ) then 					spt = PB:GetPos( e, "Antlion_Guard.Body" ) end
	if ( m == "models/antlion_worker.mdl" ) then 					spt = PB:GetPos( e, "Antlion.Head_Bone" ) end
	if ( m == "models/zombie/fast_torso.mdl" ) then 				spt = PB:GetPos( e, "ValveBiped.HC_BodyCube" ) end
	if ( m == "models/zombie/fast.mdl" ) then 						spt = PB:GetPos( e, "ValveBiped.HC_BodyCube" ) end
	if ( m == "models/headcrabclassic.mdl" ) then 					spt = PB:GetPos( e, "HeadcrabClassic.SpineControl" ) end
	if ( m == "models/headcrabblack.mdl" ) then 					spt = PB:GetPos( e, "HCBlack.body" ) end
	if ( m == "models/headcrab.mdl" ) then 							spt = PB:GetPos( e, "HCFast.body" ) end
	if ( m == "models/zombie/poison.mdl" ) then 					spt = PB:GetPos( e, "ValveBiped.Headcrab_Cube1" ) end
	if ( m == "models/zombie/classic.mdl" ) then 					spt = PB:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/zombie/classic_torso.mdl" ) then 				spt = PB:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/zombie/zombie_soldier.mdl" ) then				spt = PB:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/combine_strider.mdl" ) then 					spt = PB:GetPos( e, "Combine_Strider.Body_Bone" ) end
	if ( m == "models/combine_dropship.mdl" ) then 					spt = PB:GetPos( e, "D_ship.Spine1" ) end
	if ( m == "models/combine_helicopter.mdl" ) then 				spt = PB:GetPos( e, "Chopper.Body" ) end
	if ( m == "models/gunship.mdl" ) then 							spt = PB:GetPos( e, "Gunship.Body" ) end
	if ( m == "models/lamarr.mdl" ) then 							spt = PB:GetPos( e, "HeadcrabClassic.SpineControl" ) end
	if ( m == "models/mortarsynth.mdl" ) then 						spt = PB:GetPos( e, "Root Bone" ) end
	if ( m == "models/synth.mdl" ) then 							spt = PB:GetPos( e, "Bip02 Spine1" ) end
	if ( m == "mmodels/vortigaunt_slave.mdl" ) then 				spt = PB:GetPos( e, "ValveBiped.Head" ) end
	
	return PB:WeaponPrediction( e, spt )
end

function PB:IsVisible( e )
	if ( !ValidEntity(e) ) then return false end
	
	local ply, spt = LocalPlayer(), PB:GenerateSpot(e)
	
    local visible = {

			start = ply:GetShootPos(),
			endpos = spt,
			filter = { ply, e }

		}

	local trace = util.TraceLine( visible )
	
	if trace.Fraction == 1 then
		return true
    end
    return false 
end

local hp = false
function PB:HealthBar( e )
	if ( e:IsPlayer() && e:Health() > 300 || !e:Alive() ) then return end
	
	local col, normalhp = PB:SetColors(e), 100
	local maxX, minX, maxY, minY, oPos = PB:CreatePos(e)
	
	if( e:Health() > normalhp ) then
		normalhp = e:Health()
	end
	
	local dmg, nor = normalhp / 4, e:Health() / 4
	
	oPos.x = oPos.x - ( dmg / 2 )
	oPos.y = oPos.y + 15
	
	PB:DrawRect( oPos.x - 1, oPos.y - 1, dmg + 2, 4 + 2, Color( 0, 0, 0, 255 ) )
	PB:DrawRect( oPos.x, oPos.y, nor, 4, col )
end

function PB:GetActiveWeapon( e ) // Removed due to shittyness, rifk.
	if ( !e:GetActiveWeapon():IsValid() ) then return "None" end
	local wep = e:GetActiveWeapon():GetPrintName()
	wep = string.Replace( wep, "#HL2_", "" )
	wep = string.Replace( wep, "#GMOD_", "" )
	wep = string.Replace( wep, "_", " " )
	wep = string.lower( wep )
	return wep
end

function PB:CreateDrawings( e )
	local ply = LocalPlayer()
	local text, box = "", false
	local maxX, minX, maxY, minY, pos = PB:CreatePos(e)
	
	if ( e:IsPlayer() && PB:GetValue( "esp_player", 1 ) ) then
		if ( e:Health() > 300 ) then hp = false else hp = true end
		
		box = true
		if ( !hp ) then text = text .. e:Nick() .. "\nHp: " .. e:Health() else text = text .. e:Nick() PB:HealthBar( e ) end
		if ( PB:GetValue( "esp_dead", 1 ) && !e:Alive() ) then text = text .. "\n*DEAD*" else text = text end
	elseif ( e:IsNPC() && PB:GetValue( "esp_npc", 1 ) ) then
		box = true
		local npc = e:GetClass()
		npc = string.Replace( npc, "npc_", "" )
		npc = string.Replace( npc, "_", "" )
		npc = string.upper( npc )
		text = text .. npc
	elseif ( e:IsWeapon() && PB:GetValue( "esp_weapon", 1 ) ) then
		box = false
		local ent = e:GetClass()
		ent = string.Replace( ent, "weapon_", "" )
		ent = string.Replace( ent, "ttt_", "" )
		ent = string.Replace( ent, "zm_", "" )
		ent = string.Replace( ent, "cs_", "" )
		ent = string.Replace( ent, "css_", "" )
		ent = string.Replace( ent, "real_", "" )
		ent = string.Replace( ent, "mad_", "" )
		ent = string.Replace( ent, "_", " " )
		ent = string.lower( ent )
		text = text .. ent
	elseif ( PB:GetValue( "esp_entity", 1 ) && table.HasValue( PB.Entities, e:GetClass() ) ) then
		box = false
		local class
		if ( e:GetClass() == "prop_physics" ) then class = e:GetModel() else class = e:GetClass() end
		text = text .. class
	end
	local col = PB:SetColors(e)
	
	return text, box, maxX, minX, maxY, minY, pos, col
end

function PB:ValidAimTarget( e )
	local ply = LocalPlayer()
	
	if ( !ValidEntity( e ) ) then return false end
	if ( e:IsNPC() && !util.IsValidModel( e:GetModel() || "" ) ) then return false end
	if ( e:GetMoveType() == MOVETYPE_NONE ) then return false end
	if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() || e == ply ) then return false end
	if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	if ( e:IsPlayer() && !e:Alive() ) then return false end
	if ( e:IsPlayer() && PB:GetValue( "aim_steam", 1 ) && ( e:GetFriendStatus() == "friend" ) ) then return false end
	if ( e:IsPlayer() && PB:GetValue( "aim_friends", 1 ) && ( e:Team() == ply:Team() ) ) then return false end
	if ( e:IsPlayer() && table.HasValue( PB.Friends, e:Nick() ) ) then return false end
	if ( e:IsPlayer() && PB:GetValue( "aim_player", 0 ) ) then return false end
	if ( e:IsNPC() && PB:GetValue( "aim_npc", 0 ) ) then return false end
	return true
end
	
function PB.Aimbot( ucmd )
	local ply 	= LocalPlayer()
	local m 	= Angle( ucmd:GetMouseY() * PB.OLD.GCVN( "m_pitch" ), ucmd:GetMouseX() * -PB.OLD.GCVN("m_yaw") ) || Angle( 0, 0, 0 )
	PB.Viewfix 	= ucmd:GetViewAngles()
	PB.AimAng 	= PB.AimAng + m
	
	// I'm not good at making aimbots, so I stealz one.
	if ( PB.Aiming ) then
	
		if ( !PB:ValidAimTarget(PB.Target) || !PB:IsVisible(PB.Target) ) then
			PB.Target = nil
			local f, o, a, t, b = PB:GetConVarNumber( "aim_fov" ), { p, y }
			for k, e in pairs( ents.GetAll() ) do
				if ( PB:ValidAimTarget(e) && PB:IsVisible(e) ) then
					local tP, oP = math.Round( e:GetPos():Distance( ply:GetPos() ) ), math.Round( ply:GetPos():Distance( e:GetPos() ) )
					b = PB:GenerateSpot(e)
					
					a, t = ply:GetAimVector():Angle(), (b - ply:GetShootPos()):Angle()
					o.p, o.y = math.abs(math.NormalizeAngle(a.p - t.p)) / 2, math.abs(math.NormalizeAngle(a.y - t.y)) / 2
					
					if ( !PB.Target || tP > oP ) && ( o.p <= f && o.y <= f ) then PB.Target = e end
				end
			end
		end
		
		// Autoshoot
		if ( PB.Aiming && PB.Target != nil && PB:GetValue( "aim_shoot", 1 ) && PB.Auto ) then
			PB.OLD.RCC( "+attack" )
			timer.Simple( 0.1, function() PB.OLD.RCC( "-attack" ) end )
		end
		
		if ( !PB:Ammo() && PB:GetValue( "aim_reload", 1 ) ) then PB.OLD.RCC( "+reload" ) timer.Simple( 0.25, function() PB.OLD.RCC( "-reload" ) end ) end
		
		if ( !ValidEntity(PB.Target) || !PB.Aiming ) then return end
		local comp, myPos = PB:GenerateSpot(PB.Target), ply:GetShootPos()
		comp = comp + ( PB.Target:GetVelocity() / 45 - ply:GetVelocity() / 45 )
		
		local ang = ( comp-myPos ):Angle()
		ang.p = math.NormalizeAngle( ang.p )
		ang.y = math.NormalizeAngle( ang.y )
		
		ang.r = 0
		
		PB.AimAng 	= ang
		PB.Viewfix 	= ang
	end
	
	PB.AimAng.r	= 0
	PB.Angles 	= PB.AimAng
	PB.Angles.p	= math.NormalizeAngle( PB.Angles.p )
	PB.Angles.y	= math.NormalizeAngle( PB.Angles.y )
	PB.Angles.y = math.NormalizeAngle( PB.Angles.y + ( ucmd:GetMouseX() * -0.022 * 1 ) )
	PB.Angles.p = math.Clamp( PB.Angles.p + ( ucmd:GetMouseY() * 0.022 * 1 ), -89, 90 )
	ucmd:SetViewAngles( PB.Angles )
	
	if ( !PB:Ammo() && !PB.Aiming && PB:GetValue( "aim_reload", 1 ) ) then PB.OLD.RCC( "+reload" ) timer.Simple( 0.25, function() PB.OLD.RCC( "-reload" ) end ) end
end

PB:AddCommand( "+" .. PB.Prefix .. "aim", function() PB.Aiming = true end )
PB:AddCommand( "-" .. PB.Prefix .. "aim", function() PB.Aiming = false PB.Target = nil end )

function PB.Norecoil( ucmd )
	local wep = LocalPlayer():GetActiveWeapon()
	if ( PB:GetValue( "aim_recoil", 1 ) && !PB.Aiming ) then
		if ( wep.Primary ) then wep.Primary.Recoil = 0 end
		return { origin = 90, angles = PB.Angles }
	elseif ( PB:GetValue( "aim_recoil", 1 ) && PB.Aiming && PB.Target != nil  ) then
		if ( wep.Primary ) then wep.Primary.Recoil = 0 end
		return { origin = 90, angles = PB.Angles }
	elseif ( PB:GetValue( "aim_recoil", 1 ) && PB.Aiming && PB.Target == nil ) then
		if ( wep.Primary ) then wep.Primary.Recoil = 0 end
		return { origin = 90, angles = PB.Viewfix }
	end
	return
end

function PB.CreateESP()
	local ply = LocalPlayer()
	for k, e in pairs( ents.GetAll() ) do
		if ( PB:IsValid( e, true ) ) then
			local text, box, maxX, minX, maxY, minY, pos, col = PB:CreateDrawings(e)
			local color = Color( col.r, col.g, col.b, 255 )
			
			if ( box ) then
				surface.SetDrawColor( color )

				surface.DrawLine( maxX, maxY, maxX, minY )
				surface.DrawLine( maxX, minY, minX, minY )
			
				surface.DrawLine( minX, minY, minX, maxY )
				surface.DrawLine( minX, maxY, maxX, maxY )
			end
			
			PB:DrawText( 
				text,
				"DefaultSmall",
				pos.x,
				pos.y,
				color,
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_TOP
			)
		end
	end
	
	if ( PB:GetValue( "misc_cross", 1 ) ) then
		local g = 5
		local s, x, y, l = 10, ( ScrW() / 2 ), ( ScrH() / 2 ), g + 15
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawLine( x - l, y, x - g, y )
		surface.DrawLine( x + l, y, x + g, y )
		surface.DrawLine( x, y - l, x, y - g )
		surface.DrawLine( x, y + l, x, y + g )

		//surface.DrawLine( x - 20, y - 20, x + 20, y + 20 )
		//surface.DrawLine( x - 20, y + 20, x + 20, y - 20)
	end
	
	if ( PB:GetValue( "esp_barrel", 1 ) ) then
		for k, e in pairs( player.GetAll() ) do
			if ( e != ply && e:Alive() ) then
				local headPos, hitPos, col = e:GetBonePosition( e:LookupBone( "ValveBiped.Bip01_Head1" ) ), e:GetEyeTrace().HitPos, team.GetColor( e:Team() )
				cam.Start3D( EyePos(), EyeAngles() )
					cam.IgnoreZ( false )
					render.SetMaterial( Material( "cable/redlaser.vmt" ) )
					render.DrawBeam( headPos, hitPos, 5, 0, 0, Color( col.r, col.g, col.b, 255 ) )
				cam.End3D()
			end
		end
	end
	
	if ( PB:GetValue( "esp_aimspot", 1 ) ) then
		for k, e in pairs( ents.GetAll() ) do
			if ( PB.Target != nil && e == PB.Target && PB.Aiming ) then
				local bone = PB:GenerateSpot(PB.Target) + ( PB.Target:GetVelocity() / 45 - ply:GetVelocity() / 45 )
				local pos = bone:ToScreen()
				draw.RoundedBox( 0, pos.x - 2, pos.y - 2, 4, 4, Color( 255, 0, 0, 255 ) )
			end
		end
	end
	
	if ( PB:GetValue( "misc_admin", 1 ) ) then
	local admin, adminnum, x, y = "", 0, ScrW(), ScrH()
		for k, e in pairs( player.GetAll() ) do
			if ( e:IsPlayer() && PB:IsAdmin(e) ) then
				admin = ( admin .. e:Nick() .. " [" .. PB:GetAdminType(e) .. "]" .. "\n" )
				adminnum = adminnum + 1
			end
		end
		
		local wide, tall = 300, ( adminnum * 20 ) + 20
		local posX, posY = x / 2 + ( wide - wide ) + 300, y / 2 + ( tall + tall ) - 400
		
		if ( adminnum == 0 ) then
			admin = ""
			admin = ( "\nThere are no admins on right now" )
			wide, tall = 300, 40
		end
		
		draw.RoundedBox( 6, posX - ( wide / 2 ), posY - 10, 300, tall, Color( 0, 0, 0, 150 ) )
		PB:DrawText(
			"Admins: " .. admin,
			"Default",
			posX,
			posY,
			Color( 0, 255, 0, 255 ),
			1,
			1
		)
	end
	
	if ( PB:GetValue( "aim_info", 1 ) ) then // Sorry got a little MESSY
	local x, y = ScrW(), ScrH()
	local text, aiming, r, g, w, rw = "", "", 0, 0, 0, 100
		for k, e in pairs( ents.GetAll() ) do
			if ( e == PB.Target && ValidEntity( e ) && e:IsPlayer() ) then text = e:Nick()
			elseif ( e == PB.Target && ValidEntity( e ) && e:IsNPC() ) then text = e:GetClass()
			elseif ( e == PB.Target && e:IsPlayer() && ( e:Nick() == "<none>" ) ) then text = "<none>(Player)"
			elseif ( PB.Target == nil ) then text = "<none>" end
			if ( PB.Aiming ) then aiming = "TRUE" r = 0 g = 255 else aiming = "FALSE" r = 255 g = 0 end
			
			if ( e == PB.Target && ValidEntity( e ) ) then w = ( string.len( text ) * 10 ) end
			if ( w > 100 ) then rw = w else rw = 100 end
		end
		draw.RoundedBox( 6, ( x / 2 ) - 510, ( y / 2 ) - 340, rw, 40, Color( 0, 0, 0, 150 ) )
		PB:NormalText( "Aiming: ", ( x / 2 ) - 500, ( y / 2 ) - 335, false, 1, 255, 255, 255, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		PB:NormalText( "Target: " .. text, ( x / 2 ) - 500, ( y / 2 ) - 320, false, 1, 255, 255, 255, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		PB:NormalText( aiming, ( x / 2 ) - 460, ( y / 2 ) - 335, false, 1, r, g, 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end
end

function PB.Wireframe()
	local ply, c = LocalPlayer(), ( 1 / 255 )
	for k, e in pairs( ents.GetAll() ) do
		if ( PB:IsValid( e, false ) && PB:ConVarEnabled(e) && !e:IsWeapon() ) then
			cam.Start3D( EyePos(), EyeAngles() )
				local mat, col = PB:CreateMaterial(), PB:SetColors(e)
				render.SuppressEngineLighting( true )
				render.SetColorModulation( ( col.r * c ), ( col.g * c ), ( col.b * c ) )
				SetMaterialOverride( mat )
				e:DrawModel()
				render.SuppressEngineLighting( false )
				render.SetColorModulation( 1, 1, 1 )
				SetMaterialOverride()
				e:DrawModel()
			cam.End3D()
		end
	end
end

local shoot = false

PB.Banned = {
	"weapon_phycannon",
	"weapon_physgun"
}

function PB.ThinkFunctions()
	local ply = LocalPlayer()
	local curWep = ply:GetActiveWeapon():GetClass()
	if ( PB:GetValue( "misc_bhop", 1 ) && input.IsKeyDown( KEY_SPACE ) ) then
		if ( ply:OnGround() ) then
			PB.OLD.RCC( "+jump" )
			PB:CreateTimer( "BHOP", 0.1, 0, function() PB.OLD.RCC( "-jump" ) end )
		end
	end
	if ( PB:GetValue( "misc_auto", 1 ) && input.IsMouseDown( MOUSE_LEFT ) && !table.HasValue( PB.Banned, curWep ) ) then // No more autoclickers or just spamming the left mouse button anymore!
		if ( shoot ) then
			PB.OLD.RCC( "-attack" )
			shoot = false
		elseif ( !shoot ) then
			PB.OLD.RCC( "+attack" )
			shoot = true
		end
	elseif ( PB:GetValue( "misc_auto", 1 ) && !input.IsMouseDown( MOUSE_LEFT ) ) then
		if ( shoot ) then
			PB.OLD.RCC( "-attack" )
			shoot = false
		end
	end
end

PB:AddHook( "CreateMove", PB.Aimbot )
PB:AddHook( "CalcView", PB.Norecoil )
PB:AddHook( "HUDPaint", PB.CreateESP )
PB:AddHook( "Initialize", PB.SetUp )
PB:AddHook( "Think", PB.ThinkFunctions )
PB:AddHook( "RenderScreenspaceEffects", PB.Wireframe )

// Menu
local Menu

function PB:AddOptionCheckbox( text, cvar, parent, amt )
	local checkbox = vgui.Create( "DCheckBoxLabel" )
	checkbox:SetPos( 10, amt )
	checkbox:SetText( text )
	checkbox:SetConVar( PB.Prefix .. cvar )
	checkbox:SetParent( parent )
	checkbox:SetTextColor( Color( 0, 0, 0, 255 ) )
	checkbox:SizeToContents()
end

function PB:AddOptionSlider( text, cvar, parent, min, max, posX, posY )
	local slider = vgui.Create( "DNumSlider" )
	slider:SetParent( parent )
	slider:SetPos( posX, posY )
	slider:SetSize( 200, 70 )
	slider:SetText( "" )
	slider:SetMin( min )
	slider:SetMax( max )
	slider:SetDecimals( 0 )
	slider:SetConVar( PB.Prefix .. cvar )
		local label = vgui.Create( "DLabel" )
		label:SetParent( parent )
		label:SetText( text )
		label:SetPos( posX, posY )
		label:SetWide( 100 )
		label:SetTextColor( Color( 0, 0, 0 ) )
		label:SizeToContents()
end

function PB:AddOptionLabel( text, posX, posY, parent, r, g, b )
	local label = vgui.Create( "DLabel" )
	label:SetParent( parent )
	label:SetText( text )
	label:SetPos( posX, posY )
	label:SetWide( 100 )
	label:SetTextColor( Color( r, g, b ) )
	label:SizeToContents()
end

function PB.Menu()
	local ply = LocalPlayer()
	
	local panel = vgui.Create( "DFrame" )
	panel:SetPos( ScrW() / 2 - 400 / 2, ScrH() / 2 - 300 / 2 )
	panel:SetSize( 400, 300 )
	panel:SetTitle( "Precisionbot v" .. PB.Version )
	panel:SetVisible( true )
	panel:SetDraggable( true )
	panel:ShowCloseButton( true )
	panel:MakePopup()
	Menu = panel
	
	local propsheet = vgui.Create( "DPropertySheet" )
	propsheet:SetParent( panel )
	propsheet:SetPos( 10, 30 )
	propsheet:SetSize( 380, 260 )
	
	local aim = vgui.Create( "DPanel", propsheet )
	local esp = vgui.Create( "DPanel", propsheet )
	local misc = vgui.Create( "DPanel", propsheet )
	local frds = vgui.Create( "DPanel", propsheet )
	local entz = vgui.Create( "DPanel", propsheet ) // ents
	
	PB:AddOptionCheckbox( "Autoshoot", "aim_shoot", aim, 10 )
	PB:AddOptionCheckbox( "Ignore Friends", "aim_steam", aim, 30 )
	PB:AddOptionCheckbox( "Ignore Team", "aim_friends", aim, 50 )
	PB:AddOptionCheckbox( "No-recoil", "aim_recoil", aim, 70 )
	PB:AddOptionCheckbox( "Target Players", "aim_player", aim, 90 )
	PB:AddOptionCheckbox( "Target NPC's", "aim_npc", aim, 110 )
	PB:AddOptionCheckbox( "Auto Reload", "aim_reload", aim, 130 )
	PB:AddOptionCheckbox( "Aim Info", "aim_info", aim, 150 )
	PB:AddOptionSlider( "Field-of-View", "aim_fov", aim, 0, 180, 150, 10 )
	//PB:AddOptionSlider( "Aim Distance", "aim_distance", aim, 0, 16384, 150, 50 )
	
	PB:AddOptionLabel( "Player Options: ", 10, 5, esp, 255, 0, 0 )
	PB:AddOptionCheckbox( "Players", "esp_player", esp, 20 )
	PB:AddOptionCheckbox( "Barrel", "esp_barrel", esp, 40 )
	PB:AddOptionCheckbox( "Show Dead", "esp_dead", esp, 60 )
	PB:AddOptionLabel( "Entity Options: ", 10, 80, esp, 255, 0, 0 )
	PB:AddOptionCheckbox( "NPC", "esp_npc", esp, 100 )
	PB:AddOptionCheckbox( "Weapons", "esp_weapon", esp, 120 )
	PB:AddOptionCheckbox( "Chams", "esp_wallhack", esp, 140 )
	PB:AddOptionCheckbox( "Show Aimspot", "esp_aimspot", esp, 160 )
	PB:AddOptionCheckbox( "Entities", "esp_entity", esp, 180 )
	
	PB:AddOptionCheckbox( "Crosshair", "misc_cross", misc, 10 )
	PB:AddOptionCheckbox( "Adminlist", "misc_admin", misc, 30 )
	PB:AddOptionCheckbox( "Bunnyhop", "misc_bhop", misc, 50 )
	PB:AddOptionCheckbox( "Autopistol", "misc_auto", misc, 70 )
	
	// Friends list
	
	local combobox1
	function PB.AllPlayers()
		combobox1 = vgui.Create( "DComboBox" )
		combobox1:SetParent( frds )
		combobox1:SetPos( 10, 10 )
		combobox1:SetSize( 150, 180 )
		combobox1:SetMultiple( false )
		for k, e in pairs( player.GetAll() ) do
			if ( e != LocalPlayer() && !table.HasValue( PB.Friends, e:Nick() ) ) then
				combobox1:AddItem( e:Nick() )
			end
		end
	end
	PB.AllPlayers()
	
	local combobox2
	function PB.OnlyFriends()
		combobox2 = vgui.Create( "DComboBox" )
		combobox2:SetParent( frds )
		combobox2:SetPos( 200, 10 )
		combobox2:SetSize( 150, 180 )
		combobox2:SetMultiple( false )
		for k, e in pairs( player.GetAll() ) do
			if ( table.HasValue( PB.Friends, e:Nick() ) ) then
				combobox2:AddItem( e:Nick() )
			end
		end
	end
	PB.OnlyFriends()
	
		local button1 = vgui.Create( "DButton" )
	button1:SetParent( frds )
	button1:SetSize( 150, 20 )
	button1:SetPos( 10, 200 )
	button1:SetText( "Add" )
	button1.DoClick = function()
		if ( combobox1:GetSelectedItems() && combobox1:GetSelectedItems()[1] ) then
			for k, e in pairs( player.GetAll() ) do
				if ( e:Nick() == combobox1:GetSelectedItems()[1]:GetValue() ) then
					table.insert( PB.Friends, e:Nick() )
				end
			end
		end
		PB.AllPlayers()
		PB.OnlyFriends()
	end
	
	local button2 = vgui.Create( "DButton" )
	button2:SetParent( frds )
	button2:SetSize( 150, 20 )
	button2:SetPos( 200, 200 )
	button2:SetText( "Remove" )
	button2.DoClick = function()
		if ( combobox2:GetSelectedItems() && combobox2:GetSelectedItems()[1] ) then
			for k, e in pairs( PB.Friends ) do
				if ( e == combobox2:GetSelectedItems()[1]:GetValue() ) then
					table.remove( PB.Friends, k )
				end
			end
		end
		PB.AllPlayers()
		PB.OnlyFriends()
	end
	
	PB.AllEntities = {}
	function PB.Exists()
		for k, e in pairs( ents.GetAll() ) do
			if ( !table.HasValue( PB.Entities, e:GetClass() ) ) then
				if ( !PB:GayClasses(e) ) then
					table.insert( PB.AllEntities, e:GetClass() )
				end
			end
		end
	end
	
	// Entity list
	local combobox3
	function PB.AllEntities()
		combobox3 = vgui.Create( "DComboBox" )
		combobox3:SetParent( entz )
		combobox3:SetPos( 10, 10 )
		combobox3:SetSize( 150, 180 )
		combobox3:SetMultiple( false )
		for k, e in pairs( ents.GetAll() ) do
			if ( ValidEntity( e ) && !table.HasValue( PB.Entities, e:GetClass() ) && PB:GayClasses(e) ) then
				combobox3:AddItem( e:GetClass() )
			end
		end
	end
	PB.AllEntities()
	
	local combobox4
	function PB.OnlyListed()
		combobox4 = vgui.Create( "DComboBox" )
		combobox4:SetParent( entz )
		combobox4:SetPos( 200, 10 )
		combobox4:SetSize( 150, 180 )
		combobox4:SetMultiple( false )
		for k, e in pairs( ents.GetAll() ) do
			if ( ValidEntity( e ) && table.HasValue( PB.Entities, e:GetClass() ) ) then
				combobox4:AddItem( e:GetClass() )
			end
		end
	end
	PB.OnlyListed()
	
		local button3 = vgui.Create( "DButton" )
	button3:SetParent( entz )
	button3:SetSize( 150, 20 )
	button3:SetPos( 10, 200 )
	button3:SetText( "Add" )
	button3.DoClick = function()
		if ( !combobox3:GetSelectedItems() && !combobox3:GetSelectedItems()[1] ) then ply:ChatPrint( "You need to select an item!" ) end
		for k, e in pairs( ents.GetAll() ) do
			if ( e:GetClass() == combobox3:GetSelectedItems()[1]:GetValue() ) then
				table.insert( PB.Entities, e:GetClass() )
				ply:ChatPrint( "Added entity: " .. e:GetClass() )
			end
		end
	PB.AllEntities()
	PB.OnlyListed()
	end
	
	local button4 = vgui.Create( "DButton" )
	button4:SetParent( entz )
	button4:SetSize( 150, 20 )
	button4:SetPos( 200, 200 )
	button4:SetText( "Remove" )
	button4.DoClick = function()
		if ( !combobox4:GetSelectedItems() && !combobox4:GetSelectedItems()[1] ) then ply:ChatPrint( "You need to select an item!" ) end
		for k, e in pairs( PB.Entities ) do
			if ( e == combobox4:GetSelectedItems()[1]:GetValue() ) then
				table.remove( PB.Entities, k )
				ply:ChatPrint( "Removed entity: " .. combobox4:GetSelectedItems()[1]:GetValue() )
			end
		end
	PB.AllEntities()
	PB.OnlyListed()
	end
	
	propsheet:AddSheet( "Aimbot", aim, nil, false, false, nil )
	propsheet:AddSheet( "ESP", esp, nil, false, false, nil )
	propsheet:AddSheet( "Misc", misc, nil, false, false, nil )
	propsheet:AddSheet( "Friends", frds, nil, false, false, nil )
	propsheet:AddSheet( "Entities", entz, nil, false, false, nil )
end
PB:AddCommand( "pb_menu", PB.Menu )

function RunConsoleCommand( cmd, ... )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.RCC( cmd, ... ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cmd ), v ) ) then
			return
		end
	end
	return PB.OLD.RCC( cmd, ... )
end

function CreateClientConVar( cvar, val, save, data )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.CCCV( cvar, val, save, data ) end
	local done = {}
	if ( done[cvar] != nil && PB.SVARS[cvar] != nil ) then
		return PB.OLD.GCV( cvar )
	end
	done[cvar] = true
	return PB.OLD.CCCV( cvar, val, save, data )
end

function GetConVar( cvar )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.GCV( cvar ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	return PB.OLD.GCV( cvar )
end

function ConVarExists( cvar )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.CVE( cvar ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return false
		end
	end
	return PB.OLD.CVE( cvar )
end

function GetConVarNumber( cvar )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.GCVN( cvar ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	return PB.OLD.GCVN( cvar )
end

function GetConVarString( cvar )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.GCVS( cvar ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	return PB.OLD.GCVS( cvar )
end

function file.Read( path, bool )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.file.Read( path, bool ) end
	for k, v in pairs( PB.Files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return PB.Path[path] && PB.Path[path].cont || nil
		end
	end
	return PB.OLD.file.Read( path, bool )
end

function file.Exists( path, bool )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.file.Exists( path, bool ) end
	for k, v in pairs( PB.Files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return PB.Path[path] && true || false
		end
	end
	return PB.OLD.file.Exists( path, bool )
end

function file.Size( path )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.file.Size( path ) end
	for k, v in pairs( PB.Files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return PB.Path[path] && PB.Path[path].size || -1
		end
	end
	return PB.OLD.file.Size( path )
end

function file.Time( path )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.file.Time( path ) end
	for k, v in pairs( PB.Files ) do
		if ( string.find( string.lower( path ), v ) ) then
			return PB.Path[path] && PB.Path[path].time || 0
		end
	end
	return PB.OLD.file.Time( path )
end

function file.Find( path, bool )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	local o = PB.OLD.file.Find( path, bool )
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.file.Find( path, bool ) end
	for k, v in pairs( PB.Files ) do
		if ( string.find( string.lower( path ), v ) ) then
			table.remove( o, k )
		end
	end
	return PB.OLD.file.Find( path, bool )
end

function file.FindInLua( path )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	local o = PB.OLD.file.FindInLua( path )
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.file.FindInLua( path ) end
	for k, v in pairs( PB.Files ) do
		if ( string.find( string.lower( path ), v ) ) then
			table.remove( o, k )
		end
	end
	return PB.OLD.file.FindInLua( path )
end

function hook.Add( typ, name, func )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.hook.Add( typ, name, func ) end
	for k, v in pairs( PB.Hooks ) do
		if ( string.find( string.lower( name ), v ) ) then
			return nil
		end
	end
	return PB.OLD.hook.Add( typ, name, func )
end

function hook.Remove( typ, name, func )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.hook.Remove( typ, name, func ) end
	for k, v in pairs( PB.Hooks ) do
		if ( string.find( string.lower( name ), v ) ) then
			return nil
		end
	end
	return PB.OLD.hook.Remove( typ, name, func )
end

table.insert( PB.Commands, "pb_load" )
function concommand.Add( name, func )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.concommand.Add( name, func ) end
	for k, v in pairs( PB.Commands ) do
		if ( string.find( string.lower( name ), v ) ) then
			return nil
		end
	end
	return 
	PB.OLD.concommand.Add( name, func )
end

function concommand.Remove( name )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.concommand.Remove( name ) end
	for k, v in pairs( PB.Commands ) do
		if ( string.find( string.lower( name ), v ) ) then
			return nil
		end
	end
	return 
	PB.OLD.concommand.Remove( name )
end

function cvars.AddChangeCallback( penis, coolass )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.cvars.AddChangeCallback( penis, coolass ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( penis ), v ) ) then
			return
		end
	end
	return PB.OLD.cvars.AddChangeCallback( penis, coolass )
end

/*
function engineConsoleCommand( ply, cvar, args )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.ECC( ply, cvar, args ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar ), k ) ) then
			return false
		end
	end
	return PB.OLD.ECC( ply, cvar, args )
end
*/

function _R.ConVar.GetInt( cvar )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.CINT( cvar ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar:GetName() ), v ) ) then
			return
		end
	end
	return PB.OLD.CINT( cvar )
end

function _R.ConVar.GetBool( cvar )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.CBOOL( cvar ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar:GetName() ), v ) ) then
			return
		end
	end
	return PB.OLD.CBOOL( cvar )
end

function _R.Player.ConCommand( ply, cvar )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.PCC( ply, cvar ) end
	for k, v in pairs( PB.SVARS ) do
		if ( string.find( string.lower( cvar ), v ) ) then
			return
		end
	end
	return PB.OLD.PCC( ply, cvar )
end

function debug.getinfo( thread, func )
	PB.CallPath	= PB.OLD.debug.getinfo(2)['short_src']
	if ( PB.CallPath && PB.CallPath == PB.FilePath ) then return PB.OLD.debug.getinfo( thread, func ) end
	return {}
end