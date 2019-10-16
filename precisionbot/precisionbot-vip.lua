/*------------------------------------------------------------------------------------------------------
 ____  ____  ____  ___  ____  ___  ____  _____  _  _  ____  _____  ____ 
(  _ \(  _ \( ___)/ __)(_  _)/ __)(_  _)(  _  )( \( )(  _ \(  _  )(_  _)
 )___/ )   / )__)( (__  _)(_ \__ \ _)(_  )(_)(  )  (  ) _ < )(_)(   )(  
(__)  (_)\_)(____)\___)(____)(___/(____)(_____)(_)\_)(____/(_____) (__) 
OLD VIP HACK CODED BY FR1KIN, SOME SCRIPTS REMOVED
VERY OLD PRIVATE HACK BUT WILL DO FOR YOU ALL OKAY
*/------------------------------------------------------------------------------------------------------
if !( CLIENT ) then return end
//if !( ConVarExists( "pb_load" ) ) then return end

/*--------------------------------------------------
	Main Code
	Desc: Hooks, Concommands...
*/--------------------------------------------------

if !( CLIENT ) then return end

local Name = ( "Precisionbot v3" )

// We can now create are localized things to make things faster and look
// neater and faster.

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

// Let's create the tables which will hold all of our commands, hooks
// and files, so it's easy to add/remove them when it comes to protection.

local PB	= {}
PB.Commands = {}
PB.CVars	= {}
PB.ConVars	= {}
PB.Hooks	= {}
PB.Files	= {}
PB.Log		= {}

PB.Friends	= {}
PB.Faggots	= {}
PB.Features = {}

// [OLD] Copy basic fuctions
local OLD		= {}
OLD.hook		= {}
OLD.timer		= {}
OLD.cvars		= {}
OLD.file		= {}
OLD.debug		= {}
OLD.usermessage	= {}
OLD.sql			= {}
OLD.Other		= {}

// Copy
OLD.GetConVar					= GetConVar
OLD.GetConVarString				= GetConVarString
OLD.GetConVarNumber				= GetConVarNumber
OLD.ConVarExists				= ConVarExists
OLD.hook.Add					= hook.Add
OLD.hook.Remove					= hook.Remove
OLD.hook.Call					= hook.Call
OLD.timer.Simple				= timer.Simple
OLD.timer.Create				= timer.Create
OLD.timer.Start					= timer.Start
OLD.cvars.AddChangeCallback		= cvars.AddChangeCallback
OLD.file.CreateDir				= file.CreateDir
OLD.file.Delete					= file.Delete
OLD.file.Exists					= file.Exists
OLD.file.ExistsEx				= file.ExistsEx
OLD.file.Find					= file.Find
OLD.file.FindDir				= file.FindDir
OLD.file.FindInLua				= file.FindInLua
OLD.file.IsDir					= file.IsDir
OLD.file.Read					= file.Read
OLD.file.Rename					= file.Rename
OLD.file.Size					= file.Size
OLD.file.TFind					= file.TFind
OLD.file.Time					= file.Time
OLD.file.Write					= file.Write
OLD.debug.getinfo				= debug.getinfo
OLD.debug.getupvalue			= debug.getupvalue
OLD.sql.TableExists				= sql.TableExists
OLD.usermessage.IncomingMessage = usermessage.IncomingMessage
OLD.Other.GetInt				= _R.ConVar.GetInt
OLD.Other.GetBool				= _R.ConVar.GetBool
OLD.Other.GetString				= _R.ConVar.GetString
OLD.Other.ConCommand			= _R.Player.ConCommand
OLD.Other.RunConsoleCommand		= RunConsoleCommand

// To make it easy when making a message lets create a command that will do it
// automaticly for us, so it's cleaner and stuff.

function PB:AddLogReport( data )
	local t = data
	table.insert( PB.Log, t )
	return;
end

function PB:ConsoleMessage( msg )
	return MsgN( "[" .. string.upper( Name ) .. "]: " .. msg )
end

function PB:ChatMessage( msg )
	local message, ply = msg, LocalPlayer()
	return ply:PrintMessage( HUD_PRINTTALK, "[" .. string.upper( Name ) .. "]: " .. message )
end

function PB.GetCVarNumber( cvar )
	return timer.Simple( 0.25, function() GetConVarNumber( cvar ) end )
end

// So we created our tables but have to add stuff to them, a simple way is
// to just create functions that get there name and add them automaticly.
// I'll have to thank Fapadar for the convar function, made things easy.

function PB:AddConCommand( name, func )
	table.insert( PB.Commands, name )
	return concommand.Add( name, func ), PB:ConsoleMessage( "Added ConCommand: " .. name )
end

function PB:AddFile( name, data )
	table.insert( PB.Files, name )
	return PB:ConsoleMessage( "Added File: " .. name )
end

function PB:AddConVar( convar, str, save, data )
	table.insert( PB.ConVars, "pb_" .. convar )
	return CreateClientConVar( "pb_" .. convar, str, save, data ), PB:ConsoleMessage( "Added ConVar: pb_" .. convar .. " [" .. str .. "]" )
end
table.insert( PB.ConVars, "pb_load" )

function PB:AddNormalHook( typ, name, func )
	table.insert( PB.Hooks, name )
	return hook.Add( typ, name, func ), PB:ConsoleMessage( "[ADDED] Hook: " .. name .. " ["..typ.."]" )
end

function PB:AddHook( typ, func )

	local ran, msg = "", notes
	
	for i = 1, 20 do
		ran = ran .. string.char( math.random( 65 , 117 ) )
	end
	
	if ( msg == "" ) then msg = "<none>" end
	
	table.insert( PB.Hooks, ran )
	
	return hook.Add( typ, ran, func ), PB:ConsoleMessage( "Added Hook: " .. ran .. " ["..typ.."]" )
end

function PB:CreateClientConVar( cvar, val, tblname, dec )
	local ply, bool = LocalPlayer(), false
	if ( type( val ) == "boolean" ) then
		val = ( val && 1 || 0 ); bool = true
	end
	
	local addCvar = CreateClientConVar( "pb_" .. cvar, val, true, false )
	
	if ( bool ) then
		PB.Features[tblname] = util.tobool( addCvar:GetInt() )
	elseif ( type( val ) == "number" ) then
		if ( !dec ) then
			PB.Features[tblname] = addCvar:GetInt()
		else
			PB.Features[tblname] = tonumber( addCvar:GetString() )
		end
	elseif ( type( val ) == "string" ) then
		PB.Features[tblname] = addCvar:GetString()
	end
	
	table.insert( PB.ConVars, cvar )
	
	cvars.AddChangeCallback( cvar , function( cvar, old, new )
		if booltype then
			PB.Features[tblname] = util.tobool( math.floor( new ) )
		else
			PB.Features[tblname] = new
		end
	end )
	
	return addCvar
end

// Extra CVar(s)
table.insert( PB.ConVars, "pb_allow" )

// Now we can add our commands and stuff, everthing is localized due
// to GetConVarNumber causing lag because it does a cheacks every frame.

// Aimbot
local AimAuto			= PB:AddConVar( "aim_auto", "0", true, false )
local AimAutoshoot		= PB:AddConVar( "aim_autoshoot", "1", true, false )
local AimFriendlyFire	= PB:AddConVar( "aim_friendlyfire", "1", true, false )
local AimSteam			= PB:AddConVar( "aim_steamfriends", "1", true, false )
local AimSpot			= PB:AddConVar( "aim_spot", "14", true, false )
local AimMode			= PB:AddConVar( "aim_mode", "1", true, false )
local AimFov			= PB:AddConVar( "aim_fov", "360", true, false )
local AimThrogh			= PB:AddConVar( "aim_throgh", "0", true, false )
local AimPlayer			= PB:AddConVar( "aim_player", "1", true, false )
local AimNpc			= PB:AddConVar( "aim_npc", "0", true, false )
local AimType			= PB:AddConVar( "aim_type", "1", true, false )
local AimSilent 		= PB:AddConVar( "aim_silent", "1", true, false )
local AimOffset 		= PB:AddConVar( "aim_offset", "75", true, false )

// ESP
local EspEnabled		= PB:AddConVar( "esp_enabled", "1", true, false )
local EspName			= PB:AddConVar( "esp_name", "1", true, false )
local EspHealth			= PB:AddConVar( "esp_health", "1", true, false )
local EspWeapon			= PB:AddConVar( "esp_weapon", "1", true, false )
local EspBox			= PB:AddConVar( "esp_box", "1", true, false )
local EspBoxW			= PB:AddConVar( "esp_box_wide", "1", true, false )
local EspBoxH			= PB:AddConVar( "esp_box_tall", "2.2", true, false )
local EspNpc			= PB:AddConVar( "esp_npc", "0", true, false )
local EspEntity			= PB:AddConVar( "esp_entity", "0", true, false )
local EspPlayer			= PB:AddConVar( "esp_player", "1", true, false )
local EspPos			= PB:AddConVar( "esp_pos", "0", true, false )

// Visuals
local VisCross			= PB:AddConVar( "vis_cross", "1", true, false )
local VisLights			= PB:AddConVar( "vis_lights", "0", true, false )
local VisChams			= PB:AddConVar( "vis_chams", "0", true, false )
local VisChamsFB		= PB:AddConVar( "vis_chams_fullbright", "0", true, false )
local VisXQZ			= PB:AddConVar( "vis_xqz", "1", true, false )
local VisBarrel			= PB:AddConVar( "vis_barrel", "0", true, false )
local VisAimline		= PB:AddConVar( "vis_aimline", "0", true, false )
local VisAdminlist		= PB:AddConVar( "vis_adminlist", "1", true, false )
local VisInfobox		= PB:AddConVar( "vis_infobox", "0", true, false )
local VisRadar			= PB:AddConVar( "vis_radar", "0", true, false )
local VisRadarType		= PB:AddConVar( "vis_radar_type", "1", true, false )

// Removels
local RemRecoil			= PB:AddConVar( "rem_recoil", "1", true, false )
local RemSpread			= PB:AddConVar( "rem_spread", "1", true, false )
local RemSpreadCon		= PB:AddConVar( "rem_spread_constant", "1", true, false )
local RemSky			= PB:AddConVar( "rem_sky", "0", true, false )
local RemHands			= PB:AddConVar( "rem_hands", "1", true, false )

// Miscellaneous
local MiscBhop			= PB:AddConVar( "misc_bhop", "1", true, false )
local MiscAutopistol	= PB:AddConVar( "misc_autopistol", "1", true, false )
local MiscSpeedVal		= PB:AddConVar( "misc_speedvalue", "2", true, false )
local MiscSpinbot		= PB:AddConVar( "misc_spinbot", "0", true, false )

// To start lets check the log system.
local Released = true

// This is how we are going to tell if a player is an admin so we can add them to 
// the list, there are two ways we have to do this, boolen and string format.

function PB:IsAdmin(e)
	
	if ( e:IsAdmin() ) then 
		return true
	
	elseif ( e:IsSuperAdmin() ) then 
		return true
	
	elseif ( e:IsUserGroup( "Admin" ) || e:IsUserGroup( "admin" ) ) then
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
		
	elseif ( e:IsUserGroup( "Admin" ) || e:IsUserGroup( "admin" ) ) then
		return "Admin"
	
	end
	
	return ""
end

// Here is a huge list of our tables, they contain most of the main code that will 
// be used to defind entities in the world.

local Bones = {

		Head		= "ValveBiped.Bip01_Head1",
		Neck		= "ValveBiped.Bip01_Neck1",
		Spine		= "ValveBiped.Bip01_Spine2",
		Spine1		= "ValveBiped.Bip01_Spine3",
		Spine2		= "ValveBiped.Bip01_Spine4",
		Ass			= "ValveBiped.Bip01_Pelvis",
		RForearm	= "ValveBiped.Bip01_R_Forearm",
		RHand		= "ValveBiped.Bip01_R_Hand",
		LForearm	= "ValveBiped.Bip01_L_Forearm",
		LHand		= "ValveBiped.Bip01_L_Hand",
		RCalf		= "ValveBiped.Bip01_R_Calf",
		RFoot		= "ValveBiped.Bip01_R_Foot",
		LCalf		= "ValveBiped.Bip01_L_Calf",
		LFoot		= "ValveBiped.Bip01_L_Foot"
		
	}

local ServerValues = {

		sv_cheats			= 0,
		sv_consistency 		= 1,
		mat_fullbright		= 0,
		mat_wireframe		= 0,
		r_drawothermodels	= 1
		
	}

local Block = {

		"dick",
		"cock",
		"suck",
		"retard",
		"faggot",
		"fucks",
		"gay",
		"homo",
		"hobo",
		"menu",
		"sex",
		"cool",
		"d1ck",
		"c0ck"
		
	}
		

local Teams = {

		"Dead Guards",
		"Dead Prisoners"
		
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
	
local Allies = { 

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
	
local TraitorWeapons = {

		"weapon_ttt_c4",
		"weapon_ttt_flaregun",
		"weapon_ttt_knife",
		"weapon_ttt_phammer",
		"weapon_ttt_push",
		"weapon_ttt_radio",
		"weapon_ttt_sipistol",
		
	}
	
local DetectiveWeapons = {

		"weapon_ttt_defuser",
		"weapon_ttt_beacon",
		"weapon_ttt_binoculars",
		"weapon_ttt_health_station",
		"weapon_ttt_wtester",
		"weapon_ttt_stungun",
		"weapon_ttt_cse",
		
	}
	
local BadCMDs = {
	"kill",
	"disconnect"
}
	
// Detect vehicles on the map.

function PB.IsVehicle( e )
	
	local ply = LocalPlayer()
	
	if ( string.find( e:GetClass(), "prop_vehicle_" ) && ply:GetMoveType() ~= 0 ) then
		return true
	end
	return false
end

// Lets make sure our targets our on our screen.

function PB:OnScreen( e )

	local x, y = ScrW(), ScrH()
	
	local pos = e:GetPos():ToScreen()
	
	if !( pos.x < 0 || pos.y < 0 ) then
		return true
	else 
		return false
	end
end

// Find the gamemode, useful for server that have custom shit.

function ServerGamemodeIs( name )
	local _hN = GetConVarString( "hostname" )
	if ( string.find( string.lower( GAMEMODE.Name ), name ) ) then
		//PB:ChatMessage( "This server, " .. _hN .. ", is using the gamemode '" .. GAMEMODE.Name "'. Loading gamemode functions..." )
		return true
	end
	return false
end

// Makes sure the target is visible.

function PB:Visible( e )

	local ply = LocalPlayer()
	
    local visible = {
	
			start = ply:GetShootPos(),
			endpos = "ValveBiped.Bip01_Head1",
			filter = { ply, e }
			
		}

	local trace = util.TraceLine( visible )
	
	if trace.Fraction == 1 then
		return true
    end
    return false  
end


// We will now define our targets, this will depend on the users settings but
// of cource we got to disable and do valid checks!

function PB:TeamName( name )
	local str = ""
	
	for _, e in pairs( player.GetAll() ) do
		str = string.find( string.lower( team.GetName( e:Team() ) ), name )
	end
	
	return str
end

function PB:BadTargets( e )
	
	local ply = LocalPlayer()
	
	if ( e:IsPlayer() && PB:TeamName( "spec" ) ) then return false end
	
	for k, v in pairs( Teams ) do
		if ( e:IsPlayer() && PB:TeamName( v ) ) then return false end
	end
	
	return true
end

function PB:DoChecks( e )

	local ply, val = LocalPlayer(), 0
	
	if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	
	if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() || e == ply ) then return false end
	if ( e:IsPlayer() && !e:Alive() ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == 0 ) then return false end
	if ( e:IsWeapon() && e:GetMoveType() == 0 ) then return false end
	
	return true
	
end

function PB:DoChecksRadar( e )

	local ply, val = LocalPlayer(), 0
	
	if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	
	if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() || e == ply ) then return false end
	if ( e:IsPlayer() && !e:Alive() ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == 0 ) then return false end
	if ( e:IsWeapon() && e:GetMoveType() == 0 ) then return false end
	
	return true
	
end

function PB:DoChecksCham( e )

	local ply, val = LocalPlayer(), 0
	
	if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	
	if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() && !e:IsWeapon() && !PB.IsVehicle(e) || e == ply ) then return false end
	if ( e:IsPlayer() && !e:Alive() ) then return false end
	if ( e:IsNPC() && e:GetMoveType() == 0 ) then return false end
	if ( e:IsWeapon() && e:GetMoveType() ~= 0 ) then return false end
	if ( e:IsPlayer() && !EspPlayer:GetBool() ) then return false end
	if ( e:IsNPC() && !EspNpc:GetBool() ) then return false end
	if ( e:IsWeapon() && !EspEntity:GetBool() ) then return false end
	
	return true
	
end

function PB:SelfIsValid()
	local p = LocalPlayer()
	
	if ( !p:IsPlayer() ) then return false end
	if ( p:IsPlayer() && !p:Alive() ) then return false end
	return true
end
	

// Before we set our colors we must detect serton gamemodes that don't have team colors
// in this it will be mainly TTT.

function PB.HasWeapon( tbl )
	local ply = LocalPlayer()
	for k, e in pairs( player.GetAll() ) do
		if ( e != ply ) then
			for v, wep in pairs( e:GetWeapons() || {} ) do
				if table.HasValue( tbl, e:GetClass() ) then
					return true
				end
			end
		end
	end
	return false
end

local ttt_col = Color( 0, 255, 0, 255 )
timer.Create( "TTT_TIMER", 0.25, 0, function()
	local ttt_col = Color( 0, 255, 0, 255 )
	
	if ( PB.HasWeapon( TraitorWeapons ) && !PB.HasWeapon( DetectiveWeapons ) ) then
		ttt_col = Color( 255, 0, 0, 255 )
	elseif ( !PB.HasWeapon( TraitorWeapons ) && PB.HasWeapon( DetectiveWeapons ) ) then
		ttt_col = Color( 0, 0, 255, 255 )
	else
		ttt_col = Color( 0, 255, 0, 255 )
	end
end )
		
// After we are done with that we can start creating our hack, first thing is to get
// all the entities and give them a color, it's going to be needed below.

function PB:SetColors( e )

	local ply, class, model = LocalPlayer(), e:GetClass(), e:GetModel()
	local col
	
	if ( e:IsPlayer() && ServerGamemodeIs( "trouble in terrorist town" ) ) then
		col = ttt_col

	elseif ( e:IsPlayer() && table.HasValue( PB.Faggots, e:Nick() ) ) then
		local r, g, b = math.random( 255 ), math.random( 255 ), math.random( 255 )
		col = Color( r, g, b, 255 )
		
	elseif ( e:IsPlayer() && !table.HasValue( PB.Faggots, e:Nick() ) ) then
		col = team.GetColor( e:Team() )
	
	elseif ( e:IsNPC() && !table.HasValue( Allies, class ) ) then
		col = Color( 255, 0, 0, 255 )
		
	elseif ( e:IsNPC() && table.HasValue( Allies, class ) ) then
		col = Color( 0, 255, 0, 255 )
	
	elseif ( e:IsWeapon() || PB.IsVehicle(e) ) then
		col = Color( 255, 128, 0, 255 )
		
	else
		
		col = Color( 255, 255, 255, 255 )
		
	end
	
	return col
end

// This is going to be our material inside the hack, it's going to be pure lua so
// I don't have to use all the other shitty materials.

function PB:CreateMaterial()
	
	local BaseInfo = {
		["$basetexture"] = "color/white",
		["$model"]       = 1,
		["$translucent"] = 1,
		["$alpha"]       = 1,
		["$nocull"]      = 1
	}
   
   local mat = CreateMaterial( "vh_mat", "VertexLitGeneric", BaseInfo )

   return mat

end

// This will get cvars that I want to check, like sv_cheats or sv_scriptenforcer.

function PB:CheckScriptEnforcer()
	if ( GetConVarNumber( "sv_scriptenforcer" ) == 1 ) then
		return "[ON]"
	elseif ( GetConVarNumber( "sv_scriptenforcer" ) == 2 ) then
		return "[ON]"
	end
	return "[OFF]"
end

function PB:CheckCheats()
	if ( GetConVarNumber( "sv_cheats" ) != 0 ) then
		return "[ON]"
	end
	return "[OFF]"
end

// Allows you to find things without having extremly long messy parts of code that 
// make you think of shit.

function PB:FindFile( name )
	if ( #file.Find( name ) ) >= 1 then
		return true
	end
	return false
end

// Too create out positions we are going to have to create vectors, then based off
// of of that we can finish this.

function PB:CreateVectors( e )
	
	local ply = LocalPlayer()
	local h, v = EspBoxW:GetInt(), EspBoxH:GetInt()
	
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
	
	local pos, n, div = e:LocalToWorld( btm - btm * 1.5 ), 0, 0
	local dis, name, health, weapon = math.Round( e:GetPos():Distance( ply:GetShootPos() ) ), EspName:GetBool(), EspHealth:GetBool(), EspWeapon:GetBool()
	
	if ( div ~= 30 ) then
		if ( name ) then div = div + 10 else div = div - 10 end
		if ( health ) then div = div + 10 else div = div - 10 end
		if ( weapon ) then div = div + 10 else div = div - 10 end
	end
	
	if ( e:IsPlayer() ) then n = dis / div else n = 0 end
	
	if ( EspPos:GetBool() ) then
		pos = e:LocalToWorld( top + top + Vector( 0, 0, n ) )
	else
		pos = e:LocalToWorld( btm - btm * 1.5 )
	end
	
	local eye, hed
	if ( e:IsPlayer() ) then
		eye = ( e:GetEyeTrace().HitPos )
		hed = ( e:EyePos() )
	end
	
	local FRT 	= center + frt + rgt / h + top / v; FRT = FRT:ToScreen()
	local BLB 	= center + bak + lft / h + btm / v; BLB = BLB:ToScreen()
	local FLT	= center + frt + lft / h + top / v; FLT = FLT:ToScreen()
	local BRT 	= center + bak + rgt / h + top / v; BRT = BRT:ToScreen()
	local BLT 	= center + bak + lft / h + top / v; BLT = BLT:ToScreen()
	local FRB 	= center + frt + rgt / h + btm / v; FRB = FRB:ToScreen()
	local FLB 	= center + frt + lft / h + btm / v; FLB = FLB:ToScreen()
	local BRB 	= center + bak + rgt / h + btm / v; BRB = BRB:ToScreen()
	
	pos = pos:ToScreen()
	
	local maxX = math.max( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local minX = math.min( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local maxY = math.max( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y)
	local minY = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	
	return maxX, minX, maxY, minY, pos, eye, hed
end

// This will be the real ESP code, it's seperated from the rest of the code to
// provide easy editing, and also recude the lag levels in games.

function PB:CreateTargets( e )

	local ply = LocalPlayer()
	
	local maxX, minX, maxY, minY, pos, eye, hed = PB:CreateVectors(e)
			
	local class, model, s = e:GetClass(), e:GetModel(), "\n"
	local col = PB:SetColors(e)
			
	local text, Box = "", false
		
	if ( e:IsPlayer() && EspPlayer:GetBool() ) then
		
		Box = true
	
		if ( EspName:GetBool() ) then
			text = text .. e:Nick()
		end
		
		if ( EspHealth:GetBool() ) then
			text = text .. "\nHP: " .. e:Health()
		end
			
		if ( EspWeapon:GetBool() && e:GetActiveWeapon():IsValid() ) then
			
			local wep = e:GetActiveWeapon():GetPrintName()
			
			wep = string.Replace( wep, "#HL2_", "" )
			wep = string.Replace( wep, "#GMOD_", "" )
			wep = string.Replace( wep, "_", " " )
			
			wep = string.lower( wep )
			
			text = text .. "\nW: " .. wep
		end
	end
	
	if ( e:IsNPC() ) then
	
		if ( EspNpc:GetBool() ) then
				
			Box = true

			local npc = class
			
			npc = string.Replace( npc, "npc_", "" )
			npc = string.Replace( npc, "_", "" )
			
			npc = string.lower( npc )
			
			text = text .. npc
		end
	end
	
	if ( e:IsWeapon() ) then
		
		if ( EspEntity:GetBool() ) then
		
			Box = false
			local ent = class
			
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
		end
	end
	
	local c_col  = col
	local c_maxX = maxX
	local c_minX = minX
	local c_maxY = maxY
	local c_minY = minY
	local c_pos = pos
	local c_eye  = eye
	local c_head = hed
			
	return text, Box, c_col, c_maxX, c_minX, c_maxY, c_minY, c_pos, c_eye, c_head
end

// This will take the bones from the table above and create the 
// aim spot convar. Also I'd have too thank RabidToaster for the
// model/bone script due to tables screwing with me.

function PB:GetPos( e, pos )
	if ( type( pos ) == "string" ) then
		return ( e:GetBonePosition( e:LookupBone( pos ) ) )
	elseif ( type( pos ) == "Vector" ) then
		return ( e:LocalToWorld( Vector( pos ) ) )
	end
	return ( e:LocalToWorld( e:OBBCenter() ) )
end

function PB:GenerateSpot( e )
	
	local val = math.Clamp( AimSpot:GetInt(), 1, 14 )
	
	local spt = e:LocalToWorld( e:OBBCenter() )
	
	// Main Player Bones:
	if ( AimSpot:GetInt() == 1 ) then spt = PB:GetPos( e, Bones.Head ) end
	if ( AimSpot:GetInt() == 2 ) then spt = PB:GetPos( e, Bones.Neck ) end
	if ( AimSpot:GetInt() == 3 ) then spt = PB:GetPos( e, Bones.Spine ) end
	if ( AimSpot:GetInt() == 4 ) then spt = PB:GetPos( e, Bones.Spine1 ) end
	if ( AimSpot:GetInt() == 5 ) then spt = PB:GetPos( e, Bones.Spine2 ) end
	if ( AimSpot:GetInt() == 6 ) then spt = PB:GetPos( e, Bones.Ass ) end
	if ( AimSpot:GetInt() == 7 ) then spt = PB:GetPos( e, Bones.RForearm ) end
	if ( AimSpot:GetInt() == 8 ) then spt = PB:GetPos( e, Bones.RHand ) end
	if ( AimSpot:GetInt() == 9 ) then spt = PB:GetPos( e, Bones.LForearm ) end
	if ( AimSpot:GetInt() == 10 ) then spt = PB:GetPos( e, Bones.LHand ) end
	if ( AimSpot:GetInt() == 11 ) then spt = PB:GetPos( e, Bones.RCalf ) end
	if ( AimSpot:GetInt() == 12 ) then spt = PB:GetPos( e, Bones.RFoot ) end
	if ( AimSpot:GetInt() == 13 ) then spt = PB:GetPos( e, Bones.LCalf ) end
	if ( AimSpot:GetInt() == 14 ) then spt = PB:GetPos( e, Bones.LFoot ) end
	
	// Model Targets:
	local m = e:GetModel()
	if ( m == "models/crow.mdl" || m == "models/pigeon.mdl" ) then spt = PB:GetPos( e, Vector( 0, 0, 5 ) ) end
	if ( m == "models/seagull.mdl" ) then spt = PB:GetPos( e, Vector( 0, 0, 6 ) ) end
	if ( m == "models/combine_scanner.mdl" ) then spt = PB:GetPos( e, "Scanner.Body" ) end
	if ( m == "models/hunter.mdl" ) then spt = PB:GetPos( e, "MiniStrider.body_joint" ) end
	if ( m == "models/combine_turrets/floor_turret.mdl" ) then spt = PB:GetPos( e, "Barrel" ) end
	if ( m == "models/dog.mdl" ) then spt = PB:GetPos( e, "Dog_Model.Eye" ) end
	if ( m == "models/vortigaunt.mdl" ) then spt = PB:GetPos( e, "ValveBiped.Head" ) end
	if ( m == "models/antlion.mdl" ) then spt = PB:GetPos( e, "Antlion.Body_Bone" ) end
	if ( m == "models/antlion_guard.mdl" ) then spt = PB:GetPos( e, "Antlion_Guard.Body" ) end
	if ( m == "models/antlion_worker.mdl" ) then spt = PB:GetPos( e, "Antlion.Head_Bone" ) end
	if ( m == "models/zombie/fast_torso.mdl" ) then spt = PB:GetPos( e, "ValveBiped.HC_BodyCube" ) end
	if ( m == "models/zombie/fast.mdl" ) then spt = PB:GetPos( e, "ValveBiped.HC_BodyCube" ) end
	if ( m == "models/headcrabclassic.mdl" ) then spt = PB:GetPos( e, "HeadcrabClassic.SpineControl" ) end
	if ( m == "models/headcrabblack.mdl" ) then spt = PB:GetPos( e, "HCBlack.body" ) end
	if ( m == "models/headcrab.mdl" ) then spt = PB:GetPos( e, "HCFast.body" ) end
	if ( m == "models/zombie/poison.mdl" ) then spt = PB:GetPos( e, "ValveBiped.Headcrab_Cube1" ) end
	if ( m == "models/zombie/classic.mdl" ) then spt = PB:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/zombie/classic_torso.mdl" ) then spt = PB:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/zombie/zombie_soldier.mdl" ) then spt = PB:GetPos( e, "ValveBiped.HC_Body_Bone" ) end
	if ( m == "models/combine_strider.mdl" ) then spt = PB:GetPos( e, "Combine_Strider.Body_Bone" ) end
	if ( m == "models/combine_dropship.mdl" ) then spt = PB:GetPos( e, "D_ship.Spine1" ) end
	if ( m == "models/combine_helicopter.mdl" ) then spt = PB:GetPos( e, "Chopper.Body" ) end
	if ( m == "models/gunship.mdl" ) then spt = PB:GetPos( e, "Gunship.Body" ) end
	if ( m == "models/lamarr.mdl" ) then spt = PB:GetPos( e, "HeadcrabClassic.SpineControl" ) end
	if ( m == "models/mortarsynth.mdl" ) then spt = PB:GetPos( e, "Root Bone" ) end
	if ( m == "models/synth.mdl" ) then spt = PB:GetPos( e, "Bip02 Spine1" ) end
	if ( m == "mmodels/vortigaunt_slave.mdl" ) then spt = PB:GetPos( e, "ValveBiped.Head" ) end
	
	return spt
end

// I'm going to make a new function of this value so I don't have 
// to use surface.SetDrawColor.

function PB.DrawOutlinedRect( x, y, w, h, col )
	surface.SetDrawColor( col )
	surface.DrawOutlinedRect( x, y, w, h )
end

// Really Garry, why does this only have xalign.
function PB.DrawText( text, font, x, y, colour, xalign, yalign )

	if (font == nil) then font = "Default" end
	if (x == nil) then x = 0 end
	if (y == nil) then y = 0 end
	
	local curX = x
	local curY = y
	local curString = ""
	
	surface.SetFont(font)
	local sizeX, lineHeight = surface.GetTextSize("\n")
	
	for i=1, string.len(text) do
		local ch = string.sub(text,i,i)
		if (ch == "\n") then
			if (string.len(curString) > 0) then
				draw.SimpleText(curString, font, curX, curY, colour, xalign, yalign)
			end
			
			curY = curY + (lineHeight/2)
			curX = x
			curString = ""
		elseif (ch == "\t") then
			if (string.len(curString) > 0) then
				draw.SimpleText(curString, font, curX, curY, colour, xalign, yalign)
			end
			local tmpSizeX,tmpSizeY =  surface.GetTextSize(curString)
			curX = math.ceil( (curX + tmpSizeX) / 50 ) * 50
			curString = ""
		else
			curString = curString .. ch
		end
	end	
	if (string.len(curString) > 0) then
		draw.SimpleText(curString, font, curX, curY, colour, xalign, yalign)
	end
end

/*--------------------------------------------------
	Aimbot
	Desc: Automaticaim setting, aims for you so you
	don't have to move your mouse 2 inches or more
	because thats way to much work!
*/--------------------------------------------------

function PB:IsVisible(e)

	if ( AimThrogh:GetBool() ) then return false end
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

local ViewAngle = Angle( 0, 0, 0 )
local Aiming = false

function PB:GetShootTrace()
	local ply = LocalPlayer()
		local s, e = ply:GetShootPos(), ply:GetAimVector()
		local t = {}
		t.start = s
		t.endpos = s + ( e * 16384 )
		t.filter = { ply }
	return util.TraceLine(t)
end

local function ValidTarget( e )
	local ply = LocalPlayer()
	
	if ( !ValidEntity( e ) ) then return false end
	if ( e:GetMoveType() == MOVETYPE_NONE ) then return false end
	
	if ( !e:IsValid() || !e:IsPlayer() && !e:IsNPC() || e == ply ) then return false end
	
	if ( e:IsPlayer() && !AimPlayer:GetBool() ) then return false end
	if ( e:IsPlayer() && table.HasValue( PB.Friends, e:Nick() ) ) then return false end
	if ( e:IsPlayer() && !AimFriendlyFire:GetBool() && ply:Team() == e:Team() ) then return false end
	if ( e:IsPlayer() && e:GetMoveType() == MOVETYPE_OBSERVER ) then return false end
	if ( e:IsPlayer() && !e:Alive() ) then return false end
	
	if ( e:IsNPC() && AimNpc:GetBool() ) then return false end
	return true
end

local tar = nil
local ON = false
local correctView = Angle( 0, 0, 0 )
local silent = Angle( 0, 0, 0 )
local view = Angle( 0, 0, 0 )
local spinangle = Angle( 0, 0, 0 )
local stop = 0xFFFF - IN_JUMP

local offset = ( AimOffset:GetInt() )

local SetViewAngles = _R["CUserCmd"].SetViewAngles

function PB.Bot( u )

		local ply = LocalPlayer()
		
		local mouse = Angle(u:GetMouseY() * GetConVarNumber("m_pitch"), u:GetMouseX() * -GetConVarNumber("m_yaw")) or Angle(0,0,0)
        correctView = correctView + mouse
		correctView.p = math.NormalizeAngle( correctView.p )
		correctView.y = math.NormalizeAngle( correctView.y )
		
		if ( RemSpreadCon:GetBool() ) then
			view = PB.Nospread( u, correctView )
		else
			view = correctView
		end
		
		view.p = math.NormalizeAngle( view.p )
		view.y = math.NormalizeAngle( view.y )
		
		SetViewAngles( u, view )
		
		/*
		if ( AimSilent:GetBool() ) then
			silent = correctView
			silent.p = math.NormalizeAngle( silent.p )
			silent.y = math.NormalizeAngle( silent.y )
			viewAng = silent
		else
			viewAng = view
		end
		*/
		
		if ( MiscBhop:GetBool() && !ply:InVehicle() && ( u:GetButtons() & IN_JUMP ) > 0 ) then
			if ply:IsOnGround() then
				u:SetButtons( u:GetButtons() | IN_JUMP )
			else
				u:SetButtons( u:GetButtons() & stop )
			end
		end
		
		if ( MiscSpinbot:GetBool() && ( u:GetButtons() & ( IN_ATTACK | IN_ATTACK2 ) ) == 0 ) then
			local myview = u:GetViewAngles()
				
			spinangle.y = spinangle.y + 20
			SetViewAngles(u, spinangle)

			local diff = math.Deg2Rad(math.NormalizeAngle(spinangle.y - myview.y))
				
			local absf = math.Clamp(u:GetForwardMove(), -1, 1)
			local abss = math.Clamp(u:GetSideMove(), -1, 1)
		
			u:SetForwardMove(-1000 * math.sin(diff) * abss)
			u:SetSideMove(1000 * math.sin(diff) * absf)
		end
		
		if ( !Aiming ) then return end
		
		// stolen untill i become better okay
		local t = PB:GetShootTrace()
		if ( !ValidTarget(tar) || !PB:IsVisible(tar) || util.IsValidProp( t.Entity:GetModel() ) ) then
			tar = nil
			ON = false
			local f, o, a, t, b = AimFov:GetInt(), { p, y }
			for k, e in pairs( ents.GetAll() ) do
				if ( ValidTarget(e) && PB:IsVisible(e) ) then
					b = PB:GenerateSpot( e )
					
					a, t = ply:GetAimVector():Angle(), (b - ply:GetShootPos()):Angle()
					o.p, o.y = math.abs(math.NormalizeAngle(a.p - t.p)), math.abs(math.NormalizeAngle(a.y - t.y))
					
					if ( !tar || e:Health() > tar:Health() ) && ( o.p <= f && o.y <= f ) then tar = e end
				end
			end
		end
		
		if ( !ValidEntity(tar) || !Aiming ) then return end
		local setAng = PB:GenerateSpot( tar )
		local myPos = ply:GetShootPos()
		
		setAng = setAng + ( tar:GetVelocity() / 45 - ply:GetVelocity() / 45 )
		
		local ang = ( setAng-myPos ):Angle()
		
		ang.p = math.NormalizeAngle( ang.p )
		ang.y = math.NormalizeAngle( ang.y )
		ang.r = 0
		
		SetViewAngles( u, ang )
		
		if ( Aiming && tar != nil && AimAutoshoot:GetBool() ) then
			RunConsoleCommand( "+attack" )
			timer.Simple( 0.01, function() RunConsoleCommand( "-attack" ) end )
		elseif ( ( !Aiming && tar == nil || tar == nil || !Aiming ) && !AimAutoshoot:GetBool() ) then
			RunConsoleCommand( "-attack" )
		end
	end
	
	function PB.AimHUD()
		local ply = LocalPlayer()
		for k, e in pairs( ents.GetAll() ) do
			if ( tar != nil && e == tar ) then
				local spot = PB:GenerateSpot( e ) + ( tar:GetVelocity() / 45 - ply:GetVelocity() / 45 )
				local pos = spot:ToScreen()
				draw.RoundedBox( 0, pos.x - 2, pos.y - 2, 4, 4, Color( 255, 0, 0, 255 ) )
			end
		end
	end

	function PB.On()
		Aiming = true
	end
	
	function PB.Off()
		Aiming = false
		tar = nil
		ON = false
	end
	
	function PB.NoRecoil( u, o )
		if ( !RemRecoil:GetBool() ) then return end
			local ply = LocalPlayer()
			local w = ply:GetActiveWeapon()
			
			if ( w.Primary ) then w.Primary.Recoil = 0.0 end
			if ( w.Secondary ) then w.Secondary.Recoil = 0.0 end
		return { origin = o, angles = correctView }
	end
	
	PB:AddConCommand( "+pb_aim", PB.On )
	PB:AddConCommand( "-pb_aim", PB.Off )
	PB:AddHook( "CreateMove", PB.Bot )
	PB:AddHook( "HUDPaint", PB.AimHUD )
	PB:AddHook( "CalcView", PB.NoRecoil )
/*--------------------------------------------------
	Extra Sensory Perception
	Desc: This is the part where it hooks up and draws
	all the shit on the screen.
*/--------------------------------------------------

function PB.Extrasensory()

	local ply = LocalPlayer()
	
		for k, e in pairs( ents.GetAll() ) do
	
			if ( ValidEntity( e ) && PB:DoChecks( e ) && EspEnabled:GetBool() ) then
		
			local text, Box, c_col, c_maxX, c_minX, c_maxY, c_minY, c_pos, c_eye, c_head = PB:CreateTargets( e )
			
			local color, l = Color( c_col.r, c_col.g, c_col.b, 255 ), 4
			
			if ( EspPos:GetBool() ) then 
				l = 4 //TEXT_ALIGN_BOTTOM
			else 
				l = 3 //TEXT_ALIGN_TOP
			end
			
			PB.DrawText(
				text,
				"DefaultSmall",
				c_pos.x,
				c_pos.y,
				color,
				1,
				l
			)
			
			if ( EspBox:GetBool() && Box ) then
			
				surface.SetDrawColor( c_col.r, c_col.g, c_col.b, 255 )

				surface.DrawLine( c_maxX, c_maxY, c_maxX, c_minY )
				surface.DrawLine( c_maxX, c_minY, c_minX, c_minY )
			
				surface.DrawLine( c_minX, c_minY, c_minX, c_maxY )
				surface.DrawLine( c_minX, c_maxY, c_maxX, c_maxY )
			end
			
			if ( e:IsPlayer() && VisBarrel:GetBool() ) then
			
				//local s, e, x = 5 / 2, 4 / 2, 2 / 2
				//local startPos, endPos = e:LocalToWorld( c_head ):ToScreen(), e:LocalToWorld( c_eye ):ToScreen()
				
				local s = 50
				local t1 = e:LocalToWorld( ( c_eye ) )
				local t2 = e:LocalToWorld( ( c_head / -s )  )

				local mat = Material( "cable/redlaser" )
				
				cam.Start3D( EyePos(), EyeAngles() )
					render.SetMaterial( mat )
					render.DrawBeam( t1, t2, 5, 0, 0, color )
				cam.End3D()
				//surface.SetDrawColor( c_col.r, c_col.g, c_col.b, 255 )
				//surface.DrawLine( c_head.x, c_head.y, c_eye.x, c_eye.y )
			end
		end
	end
	
	// Since kids love to sell shit they didn't make and make videos
	// with things like "my 'private' gmod hack" I have to add this but
	// if you are smart you will know how to fix this. Note: this was planned to be a compiled DLL.
	local g, b = Color( 255, 242, 0, 255 ), Color( 0, 0, 0, 255 )
	if ( Released ) then
		draw.SimpleTextOutlined( Name .. " by fr1kin", "Default", 10, 10, g, 0, 0, 1, b )
	end
end

PB:AddHook( "HUDPaint", PB.Extrasensory )

/*--------------------------------------------------
	XQZ Wallhack
	Desc: This will show the player model 
	through the wall if enabled.
*/--------------------------------------------------

function PB.Walls()

	local ply, fullbright = LocalPlayer(), false
	
	for k, e in pairs( ents.GetAll() ) do
		if ( ValidEntity( e ) && PB:DoChecksCham( e ) ) then
		
		local col, mat, c = PB:SetColors(e), PB:CreateMaterial(), ( 1 / 255 )
		
			cam.Start3D( EyePos(), EyeAngles() )
			
				if ( VisChams:GetBool() ) then 
					render.SetColorModulation( c * col.r, c * col.g, c * col.b )
					e:DrawModel()
				end
				
				if ( VisChamsFB:GetBool() ) then
					render.SuppressEngineLighting( true )
				end
			
				if ( VisXQZ:GetBool() ) then
					cam.IgnoreZ( true )
					e:DrawModel()
					render.SuppressEngineLighting( false )
					cam.IgnoreZ( false )
				end
			
			cam.End3D()
		end
	end
end

PB:AddHook( "RenderScreenspaceEffects", PB.Walls )


/*--------------------------------------------------
	Visuals
	Desc: Crosshair, player lights...
*/--------------------------------------------------

function PB.Visuals()

	local ply = LocalPlayer()
	local x, y = ScrW() / 2, ScrH() / 2
	
	// Crosshair
	if ( VisCross:GetBool() ) then
		
		local s = 10
		local g = 5; local l = g + 10
		
		/*
		// Inner Cross
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawLine( x, y - s, x, y + s )
		surface.DrawLine( x - s, y, x + s, y )
		
		// Top & Bottom
		surface.DrawLine( x - s, y - s, x - s, y + 1 )
		surface.DrawLine( x + s, y + s, x + s, y - 1 )
		
		// Left & Right
		surface.DrawLine( x - s, y + s, x + 1, y + s )
		surface.DrawLine( x + s, y - s, x - 1, y - s )
		*/
		
		// Inside
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawLine( x, y - s, x, y + s )
		surface.DrawLine( x - s, y, x + s, y )
		
		// Outside
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawLine( x - l, y, x - g, y ); surface.DrawLine( x + l, y, x + g, y )
		surface.DrawLine( x, y - l, x, y - g ); surface.DrawLine( x, y + l, x, y + g )
	end
	
	// Dynamic Lights
	for k, e in pairs( ents.GetAll() ) do
		if ( VisLights:GetBool() && PB:DoChecksCham(e) && PB:Visible(e) && !e:IsWeapon() ) then

			local light, col = DynamicLight( e:EntIndex() ), PB:SetColors( e )
			
			if ( light ) then
				
				light.Pos = e:GetPos() + Vector( 0, 0, 10 )
				light.r = col.r
				light.g = col.g
				light.b = col.b
				light.Brightness = 7
				light.Decay = 100 * 5
				light.Size = 100
				light.DieTime = CurTime() + 1
			end
		end
	end
end
PB:AddHook( "HUDPaint", PB.Visuals )

/*--------------------------------------------------
	Removals
	Desc: Remove shit you don't like at all.
*/--------------------------------------------------
/* REMOVED */

/*--------------------------------------------------
	Menu
	Desc: Visual menu.
*/--------------------------------------------------

// Radar -------------------------------------------

local RRadar, AAdminList, IInfoMenu

function OtherVGUI()
	
	
	// Radar ----------------------------------------------------------------------
	local Radar = vgui.Create( "DFrame" )
	Radar:SetSize( 300, 300 )
	
	local rW, rH, x, y = Radar:GetWide(), Radar:GetTall(), ScrW() / 2, ScrH() / 2
	
	local sW, sH = ScrW(), ScrH()
	Radar:SetPos( sW - rW - 10, sH - rH - ( sH - rH ) + 10 )
	Radar:SetTitle( Name .. " - Radar" )
	Radar:SetVisible( true )
	Radar:SetDraggable( true )
	Radar:ShowCloseButton( false )
	Radar:MakePopup()
	Radar.Paint = function()
		draw.RoundedBox( 0, 0, 0, rW, rH, Color( 0, 0, 0, 100 ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, rW, rH )
		
		local ply = LocalPlayer()
		
		local radar = {}
		radar.h		= 300
		radar.w		= 300
		radar.org	= 5000
		
		local x, y = ScrW() / 2, ScrH() / 2
		
		local half = rH / 2
		local xm = half
		local ym = half
		
		surface.DrawLine( xm, ym - 100, xm, ym + 100 )
		surface.DrawLine( xm - 100, ym, xm + 100, ym )
		
		for k, e in pairs( ents.GetAll() ) do
			if ( PB:DoChecksRadar(e) ) then
				
				local s = 6
				local col = PB:SetColors(e)
				local color = Color( col.r, col.g, col.b, 255 )
				local plyfov = ply:GetFOV() / ( 70 / 1.13 )
				local zpos, npos = ply:GetPos().z - ( e:GetPos().z ), ( ply:GetPos() - e:GetPos() )
				
				npos:Rotate( Angle( 180, ( ply:EyeAngles().y ) * -1, -180 ) )
				local iY = npos.y * ( radar.h / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
				local iX = npos.x * ( radar.w / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
				
				
				local pX = ( radar.w / 2 )
				local pY = ( radar.h / 2 )
				
				local posX = pX - iY - ( s / 2 )
				local posY = pY - iX - ( s / 2 )
				
				local text = e:GetClass()
				
				if ( e:IsPlayer() ) then 
					text = e:Nick() .. " ["..e:Health().."]"
				end
				
				if iX < ( radar.h / 2 ) && iY < ( radar.w / 2 ) && iX > ( -radar.h / 2 ) && iY > ( -radar.w / 2 ) then
				
					draw.RoundedBox( s, posX, posY, s, s, color )
					PB.DrawText(
						text,
						"DefaultSmall",
						pX - iY - 4,
						pY - iX - 15 - ( s / 2 ),
						color,
						1,
						TEXT_ALIGN_TOP
					)
				end
			end
		end
	end

	Radar:SetMouseInputEnabled( false )
	Radar:SetKeyboardInputEnabled( false )
	
	RRadar = Radar
	
	// Admin List ----------------------------------------------------------------------
	
	//local admins, adminnum, wide, tall, posX, posY = PB.FunctionAdminlist()
	
	local admins, adminnum = "", 0
	
	for k, e in pairs( player.GetAll() ) do
		if ( PB:IsAdmin(e) ) then
			admins = ( admins .. "\n" .. e:Nick() .. " [" .. PB:GetAdminType(e) .. "]" )
			adminnum = adminnum + 1
		end
	end
	
	local wide, tall = 300, ( adminnum * 20 ) + 20
	local posX, posY = ( wide - 75 ), tall + 300
		
	if ( adminnum == 0 ) then
		admins = ( "\nThere are no admins on right now" )
		wide, tall = 300, 40
	end
	
	timer.Create( "FindAdmins", 3, 0, function()
		admins = ""
		adminnum = 0
		for k, e in pairs( player.GetAll() ) do
			if ( PB:IsAdmin(e) ) then
				admins = ( admins .. "\n" .. e:Nick() .. " [" .. PB:GetAdminType(e) .. "]" )
				adminnum = adminnum + 1
			end
		end
		
		wide, tall = 300, ( adminnum * 20 ) + 20
		posX, posY = ( wide - 75 ), tall + 300
		
		if ( adminnum == 0 ) then
			admins = ( "\nThere are no admins on right now" )
			wide, tall = 300, 40
		end
	end )
	
	local AdminList = vgui.Create( "DFrame" )
	AdminList:SetSize( 300, 1000 )
	
	local aW, aH, x, y = AdminList:GetWide(), tall, ScrW() / 2, ScrH() / 2
	
	AdminList:SetPos( 10, 90 )
	AdminList:SetTitle( Name .. " - Admin(s)" )
	AdminList:SetVisible( true )
	AdminList:SetDraggable( true )
	AdminList:ShowCloseButton( false )
	AdminList:MakePopup()
	AdminList.Paint = function()
		draw.RoundedBox( 0, 0, 0, 300, tall, Color( 0, 0, 0, 100 ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, 300, tall )
		
			PB.DrawText(
				admins,
				"Default",
				20,
				8,
				Color( 0, 255, 0, 255 ),
				0,
				0 
			)
	end
	
	AAdminList = AdminList
	
	AAdminList:SetMouseInputEnabled( false )
	AAdminList:SetKeyboardInputEnabled( false )
	
	// Info Menu ----------------------------------------------------------------------
	
	local ply = LocalPlayer()
	
	local se = GetConVarNumber( "sv_scriptenforcer" )
	local ch = GetConVarNumber( "sv_cheats" )
	local info = ""
	
	// Text
	info = info .. "\nCheats: [" .. ch .. "]"
	info = info .. "\nScriptenforcer: [" .. se .. "]"
	
	timer.Create( "InfoTimer", 3, 0, function()
		se = GetConVarNumber( "sv_scriptenforcer" )
		ch = GetConVarNumber( "sv_cheats" )
		info = ""
		info = info .. "\nCheats: [" .. ch .. "]"
		info = info .. "\nScriptenforcer: [" .. se .. "]"
	end )
		
	local InfoMenu = vgui.Create( "DFrame" )
	InfoMenu:SetSize( 300, 60 )
	
	local iW, iH, x, y = InfoMenu:GetWide(), InfoMenu:GetTall(), ScrW() / 2, ScrH() / 2
	
	InfoMenu:SetPos( 10, 20 )
	InfoMenu:SetTitle( Name .. " - Info Menu" )
	InfoMenu:SetVisible( true )
	InfoMenu:SetDraggable( true )
	InfoMenu:ShowCloseButton( false )
	InfoMenu:MakePopup()
	InfoMenu.Paint = function()
		draw.RoundedBox( 0, 0, 0, iW, iH, Color( 0, 0, 0, 100 ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, iW, iH )
		
		PB.DrawText(
				info,
				"Default",
				20,
				8,
				Color( 0, 255, 0, 255 ),
				0,
				0 
			)
	end
	
	IInfoMenu = InfoMenu
end
	
// -------------------------------------------------

local n = 0
function OpenVGUI()
	n = n + 1
	if ( n == 1 ) then
		OtherVGUI()
		n = n - 9999999999999999999 // I hope I don't open the menu 9999999999999999999 times!
	end
end

local Menu

function Menu( )

	OpenVGUI()

	local MMenu = vgui.Create( "DFrame" )
	MMenu:SetSize( 500, 300 )
	
	local mW, mH, x, y = MMenu:GetWide(), MMenu:GetTall(), ScrW() / 2, ScrH() / 2
	
	MMenu:SetPos( x - mW / 2, y - mH / 2 )
	MMenu:SetTitle( Name )
	MMenu:SetVisible( true )
	MMenu:SetDraggable( true )
	MMenu:ShowCloseButton( false )
	MMenu:MakePopup()
	MMenu.Paint = function()
		draw.RoundedBox( 0, 0, 0, mW, mH, Color( 0, 0, 0, 100 ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, mW , mH )
		surface.DrawOutlinedRect( 100, 25, mW, mH )
	end
	Menu = MMenu
	
	RRadar:SetMouseInputEnabled( true )
	RRadar:SetKeyboardInputEnabled( true )
	AAdminList:SetMouseInputEnabled( true )
	AAdminList:SetKeyboardInputEnabled( true )
	IInfoMenu:SetMouseInputEnabled( true )
	IInfoMenu:SetKeyboardInputEnabled( true )
	
	-------------------------------------------------------------------------------------
	-- Aimbot Settings:
	-------------------------------------------------------------------------------------
	
	local adCheckbox1 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox1:SetParent( MMenu )
		adCheckbox1:SetPos( 110, 35 )
		adCheckbox1:SetText( "Autoaim" )
		adCheckbox1:SetConVar( "pb_aim_auto" )
		adCheckbox1:SizeToContents()
		adCheckbox1:SetVisible( true )
		
	local adCheckbox2 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox2:SetParent( MMenu )
		adCheckbox2:SetPos( 110, 35 + 20 )
		adCheckbox2:SetText( "Autoshoot" )
		adCheckbox2:SetConVar( "pb_aim_autoshoot" )
		adCheckbox2:SizeToContents()
		adCheckbox2:SetVisible( true )
		
	local adCheckbox3 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox3:SetParent( MMenu )
		adCheckbox3:SetPos( 110, 35 + 40 )
		adCheckbox3:SetText( "Aimthrogh" )
		adCheckbox3:SetConVar( "" )
		adCheckbox3:SizeToContents()
		adCheckbox3:SetVisible( true )
		
	local adCheckbox4 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox4:SetParent( MMenu )
		adCheckbox4:SetPos( 110, 35 + 60 )
		adCheckbox4:SetText( "Autowall" )
		adCheckbox4:SetConVar( "" )
		adCheckbox4:SizeToContents()
		adCheckbox4:SetVisible( true )
		
	local adCheckbox5 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox5:SetParent( MMenu )
		adCheckbox5:SetPos( 110, 35 + 80 )
		adCheckbox5:SetText( "Friendlyfire" )
		adCheckbox5:SetConVar( "pb_aim_friendlyfire" )
		adCheckbox5:SizeToContents()
		adCheckbox5:SetVisible( true )
		
	local adCheckbox6 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox6:SetParent( MMenu )
		adCheckbox6:SetPos( 110, 35 + 100 )
		adCheckbox6:SetText( "Silent Aim" )
		adCheckbox6:SetConVar( "pb_aim_silent" )
		adCheckbox6:SizeToContents()
		adCheckbox6:SetVisible( true )
		
	local adCheckbox7 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox7:SetParent( MMenu )
		adCheckbox7:SetPos( 110, 35 + 120 )
		adCheckbox7:SetText( "Target Admins" )
		adCheckbox7:SetConVar( "" )
		adCheckbox7:SizeToContents()
		adCheckbox7:SetVisible( true )
		
	local adCheckbox8 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox8:SetParent( MMenu )
		adCheckbox8:SetPos( 110, 35 + 140 )
		adCheckbox8:SetText( "Target Players" )
		adCheckbox8:SetConVar( "pb_aim_player" )
		adCheckbox8:SizeToContents()
		adCheckbox8:SetVisible( true )
		
	local adCheckbox9 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox9:SetParent( MMenu )
		adCheckbox9:SetPos( 110, 35 + 160 )
		adCheckbox9:SetText( "Target NPCs" )
		adCheckbox9:SetConVar( "pb_aim_npc" )
		adCheckbox9:SizeToContents()
		adCheckbox9:SetVisible( true )
		
	local adCheckbox10 = vgui.Create( "DCheckBoxLabel" )
		adCheckbox10:SetParent( MMenu )
		adCheckbox10:SetPos( 110, 35 + 180 )
		adCheckbox10:SetText( "Ignore Steam Friends" )
		adCheckbox10:SetConVar( "pb_aim_steamfriends" )
		adCheckbox10:SizeToContents()
		adCheckbox10:SetVisible( true )
		
	local adSlider1 = vgui.Create( "DNumSlider" )
		adSlider1:SetParent( MMenu )
		adSlider1:SetPos( 250, 195 )
		adSlider1:SetSize( 230, 50 )
		adSlider1:SetText( "Field-of-view" )
		adSlider1:SetMin( 0 )
		adSlider1:SetMax( 360 )
		adSlider1:SetDecimals( 0 )
		adSlider1:SetConVar( "pb_aim_fov" )
		adSlider1:SetVisible( true )
		
	local adSlider2 = vgui.Create( "DNumSlider" )
		adSlider2:SetParent( MMenu )
		adSlider2:SetPos( 250, 150 )
		adSlider2:SetSize( 230, 50 )
		adSlider2:SetText( "Smoothaim" )
		adSlider2:SetMin( 0 )
		adSlider2:SetMax( 20 )
		adSlider2:SetDecimals( 0 )
		adSlider2:SetConVar( "" )
		adSlider2:SetVisible( true )
		
	local adSlider3 = vgui.Create( "DNumSlider" )
		adSlider3:SetParent( MMenu )
		adSlider3:SetPos( 250, 105 )
		adSlider3:SetSize( 230, 50 )
		adSlider3:SetText( "Bone" )
		adSlider3:SetMin( 0 )
		adSlider3:SetMax( 14 )
		adSlider3:SetDecimals( 0 )
		adSlider3:SetConVar( "pb_aim_spot" )
		adSlider3:SetVisible( true )
		
	local adSlider4 = vgui.Create( "DNumSlider" )
		adSlider4:SetParent( MMenu )
		adSlider4:SetPos( 250, 60 )
		adSlider4:SetSize( 230, 50 )
		adSlider4:SetText( "Offset" )
		adSlider4:SetMin( 0 )
		adSlider4:SetMax( 150 )
		adSlider4:SetDecimals( 0 )
		adSlider4:SetConVar( "pb_aim_offset" )
		adSlider4:SetVisible( true )
	
	-------------------------------------------------------------------------------------
	-- ESP Settings:
	-------------------------------------------------------------------------------------
	
	local edCheckbox1 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox1:SetParent( MMenu )
		edCheckbox1:SetPos( 110, 35 )
		edCheckbox1:SetText( "Enabled" )
		edCheckbox1:SetConVar( "pb_esp_enabled" )
		edCheckbox1:SizeToContents()
		edCheckbox1:SetVisible( false )
		
	local edCheckbox2 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox2:SetParent( MMenu )
		edCheckbox2:SetPos( 110, 35 + 20 )
		edCheckbox2:SetText( "Name" )
		edCheckbox2:SetConVar( "pb_esp_name" )
		edCheckbox2:SizeToContents()
		edCheckbox2:SetVisible( false )
		
	local edCheckbox3 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox3:SetParent( MMenu )
		edCheckbox3:SetPos( 110, 35 + 40 )
		edCheckbox3:SetText( "Health" )
		edCheckbox3:SetConVar( "pb_esp_health" )
		edCheckbox3:SizeToContents()
		edCheckbox3:SetVisible( false )
		
	local edCheckbox4 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox4:SetParent( MMenu )
		edCheckbox4:SetPos( 110, 35 + 60 )
		edCheckbox4:SetText( "Weapon" )
		edCheckbox4:SetConVar( "pb_esp_weapon" )
		edCheckbox4:SizeToContents()
		edCheckbox4:SetVisible( false )
		
	local edCheckbox5 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox5:SetParent( MMenu )
		edCheckbox5:SetPos( 110, 35 + 80 )
		edCheckbox5:SetText( "Include NPCs" )
		edCheckbox5:SetConVar( "pb_esp_npc" )
		edCheckbox5:SizeToContents()
		edCheckbox5:SetVisible( false )
		
	local edCheckbox6 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox6:SetParent( MMenu )
		edCheckbox6:SetPos( 110, 35 + 100 )
		edCheckbox6:SetText( "Include Players" )
		edCheckbox6:SetConVar( "pb_esp_player" )
		edCheckbox6:SizeToContents()
		edCheckbox6:SetVisible( false )
		
	local edCheckbox7 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox7:SetParent( MMenu )
		edCheckbox7:SetPos( 110, 35 + 120 )
		edCheckbox7:SetText( "Include Entities" )
		edCheckbox7:SetConVar( "pb_esp_entity" )
		edCheckbox7:SizeToContents()
		edCheckbox7:SetVisible( false )
		
	local edCheckbox8 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox8:SetParent( MMenu )
		edCheckbox8:SetPos( 110, 35 + 140 )
		edCheckbox8:SetText( "2D Bounding Box" )
		edCheckbox8:SetConVar( "pb_esp_box" )
		edCheckbox8:SizeToContents()
		edCheckbox8:SetVisible( false )
		
	local edCheckbox9 = vgui.Create( "DCheckBoxLabel" )
		edCheckbox9:SetParent( MMenu )
		edCheckbox9:SetPos( 110, 35 + 160 )
		edCheckbox9:SetText( "Change Position" )
		edCheckbox9:SetConVar( "pb_esp_pos" )
		edCheckbox9:SizeToContents()
		edCheckbox9:SetVisible( false )
		
	local edSlider1 = vgui.Create( "DNumSlider" )
		edSlider1:SetParent( MMenu )
		edSlider1:SetPos( 250, 195 )
		edSlider1:SetSize( 230, 50 )
		edSlider1:SetText( "Box Width" )
		edSlider1:SetMin( 1 )
		edSlider1:SetMax( 10 )
		edSlider1:SetDecimals( 1 )
		edSlider1:SetConVar( "pb_esp_box_wide" )
		edSlider1:SetVisible( false )
		
	local edSlider2 = vgui.Create( "DNumSlider" )
		edSlider2:SetParent( MMenu )
		edSlider2:SetPos( 250, 150 )
		edSlider2:SetSize( 230, 50 )
		edSlider2:SetText( "Box Hight" )
		edSlider2:SetMin( 1 )
		edSlider2:SetMax( 10 )
		edSlider2:SetDecimals( 1 )
		edSlider2:SetConVar( "pb_esp_box_tall" )
		edSlider2:SetVisible( false )
		
	-------------------------------------------------------------------------------------
	-- Visual Settings:
	-------------------------------------------------------------------------------------
	
	local vdCheckbox1 = vgui.Create( "DCheckBoxLabel" )
		vdCheckbox1:SetParent( MMenu )
		vdCheckbox1:SetPos( 110, 35 )
		vdCheckbox1:SetText( "Crosshair" )
		vdCheckbox1:SetConVar( "pb_vis_cross" )
		vdCheckbox1:SizeToContents()
		vdCheckbox1:SetVisible( false )
		
	local vdCheckbox2 = vgui.Create( "DCheckBoxLabel" )
		vdCheckbox2:SetParent( MMenu )
		vdCheckbox2:SetPos( 110, 35 + 20 )
		vdCheckbox2:SetText( "Dynamic Lights" )
		vdCheckbox2:SetConVar( "pb_vis_lights" )
		vdCheckbox2:SizeToContents()
		vdCheckbox2:SetVisible( false )
		
	local vdCheckbox3 = vgui.Create( "DCheckBoxLabel" )
		vdCheckbox3:SetParent( MMenu )
		vdCheckbox3:SetPos( 110, 35 + 40 )
		vdCheckbox3:SetText( "XQZ WallHack" )
		vdCheckbox3:SetConVar( "pb_vis_xqz" )
		vdCheckbox3:SizeToContents()
		vdCheckbox3:SetVisible( false )
		
	local vdCheckbox4 = vgui.Create( "DCheckBoxLabel" )
		vdCheckbox4:SetParent( MMenu )
		vdCheckbox4:SetPos( 110, 35 + 60 )
		vdCheckbox4:SetText( "Colored Models" )
		vdCheckbox4:SetConVar( "pb_vis_chams" )
		vdCheckbox4:SizeToContents()
		vdCheckbox4:SetVisible( false )
		
	local vdCheckbox5 = vgui.Create( "DCheckBoxLabel" )
		vdCheckbox5:SetParent( MMenu )
		vdCheckbox5:SetPos( 110, 35 + 80 )
		vdCheckbox5:SetText( "Colored Models Full Bright" )
		vdCheckbox5:SetConVar( "pb_vis_chams_fullbright" )
		vdCheckbox5:SizeToContents()
		vdCheckbox5:SetVisible( false )
		
	local vdCheckbox6 = vgui.Create( "DCheckBoxLabel" )
		vdCheckbox6:SetParent( MMenu )
		vdCheckbox6:SetPos( 110, 35 + 100 )
		vdCheckbox6:SetText( "Barrel" )
		vdCheckbox6:SetConVar( "pb_vis_barrel" )
		vdCheckbox6:SizeToContents()
		vdCheckbox6:SetVisible( false )
		
	local vdButton1 = vgui.Create( "DButton" )
		vdButton1:SetParent( MMenu )
		vdButton1:SetText( "Radar" )
		vdButton1:SetPos( 400, 35 )
		vdButton1:SetSize( 90, 25 )
		vdButton1:SetVisible( false )
		vdButton1.DoClick = function()
			D = !D
			
			if ( D ) then
				RRadar:SetVisible( true )
				PB:ChatMessage( "Enabled Radar" )
			else
				RRadar:SetVisible( false )
				PB:ChatMessage( "Disabled Radar" )
			end
		end
		
	local vdButton2 = vgui.Create( "DButton" )
		vdButton2:SetParent( MMenu )
		vdButton2:SetText( "Adminlist" )
		vdButton2:SetPos( 400, 35 + 30 )
		vdButton2:SetSize( 90, 25 )
		vdButton2:SetVisible( false )
		vdButton2.DoClick = function()
			D = !D
			
			if ( D ) then
				AAdminList:SetVisible( true )
				PB:ChatMessage( "Enabled Adminlist" )
			else
				AAdminList:SetVisible( false )
				PB:ChatMessage( "Disable Adminlist" )
			end
		end
		
	-------------------------------------------------------------------------------------
	-- Removal Settings:
	-------------------------------------------------------------------------------------
	
	local rdCheckbox1 = vgui.Create( "DCheckBoxLabel" )
		rdCheckbox1:SetParent( MMenu )
		rdCheckbox1:SetPos( 110, 35 )
		rdCheckbox1:SetText( "Norecoil" )
		rdCheckbox1:SetConVar( "pb_rem_recoil" )
		rdCheckbox1:SizeToContents()
		rdCheckbox1:SetVisible( false )
		
	local rdCheckbox2 = vgui.Create( "DCheckBoxLabel" )
		rdCheckbox2:SetParent( MMenu )
		rdCheckbox2:SetPos( 110, 35 + 20 )
		rdCheckbox2:SetText( "Nospread" )
		rdCheckbox2:SetConVar( "pb_rem_spread" )
		rdCheckbox2:SizeToContents()
		rdCheckbox2:SetVisible( false )
		
	local rdCheckbox3 = vgui.Create( "DCheckBoxLabel" )
		rdCheckbox3:SetParent( MMenu )
		rdCheckbox3:SetPos( 110, 35 + 40 )
		rdCheckbox3:SetText( "Allways Nospread" )
		rdCheckbox3:SetConVar( "pb_rem_spread_constant" )
		rdCheckbox3:SizeToContents()
		rdCheckbox3:SetVisible( false )
		
	-------------------------------------------------------------------------------------
	-- Misc Settings:
	-------------------------------------------------------------------------------------
	
	local mdCheckbox1 = vgui.Create( "DCheckBoxLabel" )
		mdCheckbox1:SetParent( MMenu )
		mdCheckbox1:SetPos( 110, 35 )
		mdCheckbox1:SetText( "Bunnyhop" )
		mdCheckbox1:SetConVar( "pb_misc_bhop" )
		mdCheckbox1:SizeToContents()
		mdCheckbox1:SetVisible( false )
		
	local mdCheckbox2 = vgui.Create( "DCheckBoxLabel" )
		mdCheckbox2:SetParent( MMenu )
		mdCheckbox2:SetPos( 110, 35 + 20 )
		mdCheckbox2:SetText( "Autopistol" )
		mdCheckbox2:SetConVar( "pb_misc_autopistol" )
		mdCheckbox2:SizeToContents()
		mdCheckbox2:SetVisible( false )
	
	local curName = "OFF"
	local mdButton1 = vgui.Create( "DButton" )
		mdButton1:SetParent( MMenu )
		mdButton1:SetText( "Cheats [" .. curName .. "]" )
		mdButton1:SetPos( 400, 35 )
		mdButton1:SetSize( 90, 25 )
		mdButton1:SetVisible( false )
		mdButton1.DoClick = function()
			D = !D
			
			if ( D ) then
				
				ForceCVar( "sv_cheats", 1, true )
				mdButton1:SetText( "Cheats [ON]" )
				curName = "ON"
				PB:ChatMessage( "Bypassed Cheats" )
			else
				ForceCVar( "sv_cheats", 0, true )
				mdButton1:SetText( "Cheats [OFF]" )
				curName = "OFF"
				PB:ChatMessage( "Disabled Cheat Bypass" )
			end
		end
		
	local mdButton2 = vgui.Create( "DButton" )
		mdButton2:SetParent( MMenu )
		mdButton2:SetText( "Allow HLDJ/HLSS" )
		mdButton2:SetPos( 400, 35 + 30 ) // lazy omg
		mdButton2:SetSize( 90, 25 )
		mdButton2:SetVisible( false )
		mdButton2.DoClick = function()
			D = !D
			
			if ( D ) then
				
				ForceCVar( "sv_allow_voice_from_file", 1, true )
				PB:ChatMessage( "Enabled HLDJ/HLSS" )
			else
				ForceCVar( "sv_allow_voice_from_file", 0, true )
				PB:ChatMessage( "Disabled HLDJ/HLSS" )
			end
		end
		
	local mdSlider1 = vgui.Create( "DNumSlider" )
		mdSlider1:SetParent( MMenu )
		mdSlider1:SetPos( 250, 195 )
		mdSlider1:SetSize( 230, 50 )
		mdSlider1:SetText( "Speedvalue" )
		mdSlider1:SetMin( 0 )
		mdSlider1:SetMax( 1 )
		mdSlider1:SetDecimals( 1 )
		mdSlider1:SetConVar( "pb_misc_speedvalue" )
		mdSlider1:SetVisible( false )
		
	-------------------------------------------------------------------------------------
	-- List Settings:
	-------------------------------------------------------------------------------------
	local v = 0
	function TheirNumber()
		e:Nick()
		v = v + 1
		return v
	end
	
	local ply = LocalPlayer()
	local dListView = vgui.Create( "DListView" )
		dListView:SetParent( MMenu )
		dListView:SetPos( 110, 35 )
		dListView:SetSize( 370, 250 )
		dListView:SetMultiSelect( false )
		dListView:AddColumn( "Name" )
		dListView:AddColumn( "Friend" )
		dListView:AddColumn( "Faggot" )
		dListView:SetVisible( false )
		
	function dList()
		
		local friend, fag = false, false
		
		for k, e in pairs( player.GetAll() ) do
		
			if ( e == ply ) then
			else
			
			if ( table.HasValue( PB.Friends, e:Nick() ) ) then
				friend = true
			else
				friend = false
			end
			
			if ( table.HasValue( PB.Faggots, e:Nick() ) ) then
				fag = true
			else
				fag = false
			end
			
			local mText, tabletype, val = "Unknown", table.remove, 0
			
			if ( friend ) then mText = "Remove" else mText = "Add" end
			if ( friend ) then tabletype = table.remove val = 0 else tabletype = table.insert val = 1 end
			
			dListView.DoDoubleClick = function( parent, index, list )
				local dMinilist = DermaMenu()
					dMinilist:AddOption( "Add to Friends", function() table.insert( PB.Friends, list:GetValue( 1 ) ) end )
					dMinilist:AddOption( "Add to Faggots", function() table.insert( PB.Faggots, list:GetValue( 1 ) ) end )
					dMinilist:AddOption( "Clear Friends", function() PB.Friends = {} end )
					dMinilist:AddOption( "Clear Faggots", function() PB.Faggots = {} end )
					dMinilist:Open()
				end
			
			
			local text, faggot = "Unknown", "Unknown"
			if ( friend ) then text = "Friend" else text = "Enemy" end
			if ( fag ) then faggot = "Yes" else faggot = "No" end
			
			dListView:AddLine( e:Nick(), text, faggot )
		end
	end
end
	
	dList()
		
	-------------------------------------------------------------------------------------
	-- VGUI Buttons: Note: This was the only way to do this ):
	-------------------------------------------------------------------------------------
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "Aimbot" )
		dButton:SetPos( 5, 30 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( true )
			adCheckbox2:SetVisible( true )
			adCheckbox3:SetVisible( true )
			adCheckbox4:SetVisible( true )
			adCheckbox5:SetVisible( true )
			adCheckbox6:SetVisible( true )
			adCheckbox7:SetVisible( true )
			adCheckbox8:SetVisible( true )
			adCheckbox9:SetVisible( true )
			adCheckbox10:SetVisible( true )
			adSlider1:SetVisible( true )
			adSlider2:SetVisible( true )
			adSlider3:SetVisible( true )
			adSlider4:SetVisible( true )
			edCheckbox1:SetVisible( false )
			edCheckbox2:SetVisible( false )
			edCheckbox3:SetVisible( false )
			edCheckbox4:SetVisible( false )
			edCheckbox5:SetVisible( false )
			edCheckbox6:SetVisible( false )
			edCheckbox7:SetVisible( false )
			edCheckbox8:SetVisible( false )
			edCheckbox9:SetVisible( false )
			edSlider1:SetVisible( false )
			edSlider2:SetVisible( false )
			vdCheckbox1:SetVisible( false )
			vdCheckbox2:SetVisible( false )
			vdCheckbox3:SetVisible( false )
			vdCheckbox4:SetVisible( false )
			vdCheckbox5:SetVisible( false )
			vdCheckbox6:SetVisible( false )
			vdButton1:SetVisible( false )
			vdButton2:SetVisible( false )
			rdCheckbox1:SetVisible( false )
			rdCheckbox2:SetVisible( false )
			rdCheckbox3:SetVisible( false )
			mdCheckbox1:SetVisible( false )
			mdCheckbox2:SetVisible( false )
			mdSlider1:SetVisible( false )
			dListView:SetVisible( false )
			mdButton2:SetVisible( false )
		end
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "ESP" )
		dButton:SetPos( 5, 60 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( false )
			adCheckbox2:SetVisible( false )
			adCheckbox3:SetVisible( false )
			adCheckbox4:SetVisible( false )
			adCheckbox5:SetVisible( false )
			adCheckbox6:SetVisible( false )
			adCheckbox7:SetVisible( false )
			adCheckbox8:SetVisible( false )
			adCheckbox9:SetVisible( false )
			adCheckbox10:SetVisible( false )
			adSlider1:SetVisible( false )
			adSlider2:SetVisible( false )
			adSlider3:SetVisible( false )
			adSlider4:SetVisible( false )
			edCheckbox1:SetVisible( true )
			edCheckbox2:SetVisible( true )
			edCheckbox3:SetVisible( true )
			edCheckbox4:SetVisible( true )
			edCheckbox5:SetVisible( true )
			edCheckbox6:SetVisible( true )
			edCheckbox7:SetVisible( true )
			edCheckbox8:SetVisible( true )
			edCheckbox9:SetVisible( true )
			edSlider1:SetVisible( true )
			edSlider2:SetVisible( true )
			vdCheckbox1:SetVisible( false )
			vdCheckbox2:SetVisible( false )
			vdCheckbox3:SetVisible( false )
			vdCheckbox4:SetVisible( false )
			vdCheckbox5:SetVisible( false )
			vdCheckbox6:SetVisible( false )
			vdButton1:SetVisible( false )
			vdButton2:SetVisible( false )
			rdCheckbox1:SetVisible( false )
			rdCheckbox2:SetVisible( false )
			rdCheckbox3:SetVisible( false )
			mdCheckbox1:SetVisible( false )
			mdCheckbox2:SetVisible( false )
			mdButton1:SetVisible( false )
			mdSlider1:SetVisible( false )
			dListView:SetVisible( false )
			mdButton2:SetVisible( false )
		end
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "Visuals" )
		dButton:SetPos( 5, 90 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( false )
			adCheckbox2:SetVisible( false )
			adCheckbox3:SetVisible( false )
			adCheckbox4:SetVisible( false )
			adCheckbox5:SetVisible( false )
			adCheckbox6:SetVisible( false )
			adCheckbox7:SetVisible( false )
			adCheckbox8:SetVisible( false )
			adCheckbox9:SetVisible( false )
			adCheckbox10:SetVisible( false )
			adSlider1:SetVisible( false )
			adSlider2:SetVisible( false )
			adSlider3:SetVisible( false )
			adSlider4:SetVisible( false )
			edCheckbox1:SetVisible( false )
			edCheckbox2:SetVisible( false )
			edCheckbox3:SetVisible( false )
			edCheckbox4:SetVisible( false )
			edCheckbox5:SetVisible( false )
			edCheckbox6:SetVisible( false )
			edCheckbox7:SetVisible( false )
			edCheckbox8:SetVisible( false )
			edCheckbox9:SetVisible( false )
			edSlider1:SetVisible( false )
			edSlider2:SetVisible( false )
			vdCheckbox1:SetVisible( true )
			vdCheckbox2:SetVisible( true )
			vdCheckbox3:SetVisible( true )
			vdCheckbox4:SetVisible( true )
			vdCheckbox5:SetVisible( true )
			vdCheckbox6:SetVisible( true )
			vdButton1:SetVisible( true )
			vdButton2:SetVisible( true )
			rdCheckbox1:SetVisible( false )
			rdCheckbox2:SetVisible( false )
			rdCheckbox3:SetVisible( false )
			mdCheckbox1:SetVisible( false )
			mdCheckbox2:SetVisible( false )
			mdButton1:SetVisible( false )
			mdSlider1:SetVisible( false )
			dListView:SetVisible( false )
			mdButton2:SetVisible( false )
		end
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "Removals" )
		dButton:SetPos( 5, 120 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( false )
			adCheckbox2:SetVisible( false )
			adCheckbox3:SetVisible( false )
			adCheckbox4:SetVisible( false )
			adCheckbox5:SetVisible( false )
			adCheckbox6:SetVisible( false )
			adCheckbox7:SetVisible( false )
			adCheckbox8:SetVisible( false )
			adCheckbox9:SetVisible( false )
			adCheckbox10:SetVisible( false )
			adSlider1:SetVisible( false )
			adSlider2:SetVisible( false )
			adSlider3:SetVisible( false )
			adSlider4:SetVisible( false )
			edCheckbox1:SetVisible( false )
			edCheckbox2:SetVisible( false )
			edCheckbox3:SetVisible( false )
			edCheckbox4:SetVisible( false )
			edCheckbox5:SetVisible( false )
			edCheckbox6:SetVisible( false )
			edCheckbox7:SetVisible( false )
			edCheckbox8:SetVisible( false )
			edCheckbox9:SetVisible( false )
			edSlider1:SetVisible( false )
			edSlider2:SetVisible( false )
			vdCheckbox1:SetVisible( false )
			vdCheckbox2:SetVisible( false )
			vdCheckbox3:SetVisible( false )
			vdCheckbox4:SetVisible( false )
			vdCheckbox5:SetVisible( false )
			vdCheckbox6:SetVisible( false )
			vdButton1:SetVisible( false )
			vdButton2:SetVisible( false )
			rdCheckbox1:SetVisible( true )
			rdCheckbox2:SetVisible( true )
			rdCheckbox3:SetVisible( true )
			mdCheckbox1:SetVisible( false )
			mdCheckbox2:SetVisible( false )
			mdButton1:SetVisible( false )
			mdSlider1:SetVisible( false )
			dListView:SetVisible( false )
			mdButton2:SetVisible( false )
		end
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "Miscellaneous" )
		dButton:SetPos( 5, 150 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( false )
			adCheckbox2:SetVisible( false )
			adCheckbox3:SetVisible( false )
			adCheckbox4:SetVisible( false )
			adCheckbox5:SetVisible( false )
			adCheckbox6:SetVisible( false )
			adCheckbox7:SetVisible( false )
			adCheckbox8:SetVisible( false )
			adCheckbox9:SetVisible( false )
			adCheckbox10:SetVisible( false )
			adSlider1:SetVisible( false )
			adSlider2:SetVisible( false )
			adSlider3:SetVisible( false )
			adSlider4:SetVisible( false )
			edCheckbox1:SetVisible( false )
			edCheckbox2:SetVisible( false )
			edCheckbox3:SetVisible( false )
			edCheckbox4:SetVisible( false )
			edCheckbox5:SetVisible( false )
			edCheckbox6:SetVisible( false )
			edCheckbox7:SetVisible( false )
			edCheckbox8:SetVisible( false )
			edCheckbox9:SetVisible( false )
			edSlider1:SetVisible( false )
			edSlider2:SetVisible( false )
			vdCheckbox1:SetVisible( false )
			vdCheckbox2:SetVisible( false )
			vdCheckbox3:SetVisible( false )
			vdCheckbox4:SetVisible( false )
			vdCheckbox5:SetVisible( false )
			vdCheckbox6:SetVisible( false )
			vdButton1:SetVisible( false )
			vdButton2:SetVisible( false )
			rdCheckbox1:SetVisible( false )
			rdCheckbox2:SetVisible( false )
			rdCheckbox3:SetVisible( false )
			mdCheckbox1:SetVisible( true )
			mdCheckbox2:SetVisible( true )
			mdButton1:SetVisible( true )
			mdSlider1:SetVisible( true )
			mdButton2:SetVisible( true )
			dListView:SetVisible( false )
		end
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "Logger" )
		dButton:SetPos( 5, 180 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( false )
			adCheckbox2:SetVisible( false )
			adCheckbox3:SetVisible( false )
			adCheckbox4:SetVisible( false )
			adCheckbox5:SetVisible( false )
			adCheckbox6:SetVisible( false )
			adCheckbox7:SetVisible( false )
			adCheckbox8:SetVisible( false )
			adCheckbox9:SetVisible( false )
			adCheckbox10:SetVisible( false )
			adSlider1:SetVisible( false )
			adSlider2:SetVisible( false )
			adSlider3:SetVisible( false )
			adSlider4:SetVisible( false )
			edCheckbox1:SetVisible( false )
			edCheckbox2:SetVisible( false )
			edCheckbox3:SetVisible( false )
			edCheckbox4:SetVisible( false )
			edCheckbox5:SetVisible( false )
			edCheckbox6:SetVisible( false )
			edCheckbox7:SetVisible( false )
			edCheckbox8:SetVisible( false )
			edCheckbox9:SetVisible( false )
			edSlider1:SetVisible( false )
			edSlider2:SetVisible( false )
			vdCheckbox1:SetVisible( false )
			vdCheckbox2:SetVisible( false )
			vdCheckbox3:SetVisible( false )
			vdCheckbox4:SetVisible( false )
			vdCheckbox5:SetVisible( false )
			vdCheckbox6:SetVisible( false )
			vdButton1:SetVisible( false )
			vdButton2:SetVisible( false )
			rdCheckbox1:SetVisible( false )
			rdCheckbox2:SetVisible( false )
			rdCheckbox3:SetVisible( false )
			mdCheckbox1:SetVisible( false )
			mdCheckbox2:SetVisible( false )
			mdButton1:SetVisible( false )
			mdSlider1:SetVisible( false )
			mdButton2:SetVisible( false )
			dListView:SetVisible( false )
		end
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "Colors" )
		dButton:SetPos( 5, 210 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( false )
			adCheckbox2:SetVisible( false )
			adCheckbox3:SetVisible( false )
			adCheckbox4:SetVisible( false )
			adCheckbox5:SetVisible( false )
			adCheckbox6:SetVisible( false )
			adCheckbox7:SetVisible( false )
			adCheckbox8:SetVisible( false )
			adCheckbox9:SetVisible( false )
			adCheckbox10:SetVisible( false )
			adSlider1:SetVisible( false )
			adSlider2:SetVisible( false )
			adSlider3:SetVisible( false )
			adSlider4:SetVisible( false )
			edCheckbox1:SetVisible( false )
			edCheckbox2:SetVisible( false )
			edCheckbox3:SetVisible( false )
			edCheckbox4:SetVisible( false )
			edCheckbox5:SetVisible( false )
			edCheckbox6:SetVisible( false )
			edCheckbox7:SetVisible( false )
			edCheckbox8:SetVisible( false )
			edCheckbox9:SetVisible( false )
			edSlider1:SetVisible( false )
			edSlider2:SetVisible( false )
			vdCheckbox1:SetVisible( false )
			vdCheckbox2:SetVisible( false )
			vdCheckbox3:SetVisible( false )
			vdCheckbox4:SetVisible( false )
			vdCheckbox5:SetVisible( false )
			vdCheckbox6:SetVisible( false )
			vdButton1:SetVisible( false )
			vdButton2:SetVisible( false )
			rdCheckbox1:SetVisible( false )
			rdCheckbox2:SetVisible( false )
			rdCheckbox3:SetVisible( false )
			mdCheckbox1:SetVisible( false )
			mdCheckbox2:SetVisible( false )
			mdButton1:SetVisible( false )
			mdSlider1:SetVisible( false )
			mdButton2:SetVisible( false )
			dListView:SetVisible( false )
		end
		
	local dButton = vgui.Create( "DButton" )
		dButton:SetParent( MMenu )
		dButton:SetText( "List" )
		dButton:SetPos( 5, 240 )
		dButton:SetSize( 90, 25 )
		dButton.DoClick = function()
			adCheckbox1:SetVisible( false )
			adCheckbox2:SetVisible( false )
			adCheckbox3:SetVisible( false )
			adCheckbox4:SetVisible( false )
			adCheckbox5:SetVisible( false )
			adCheckbox6:SetVisible( false )
			adCheckbox7:SetVisible( false )
			adCheckbox8:SetVisible( false )
			adCheckbox9:SetVisible( false )
			adCheckbox10:SetVisible( false )
			adSlider1:SetVisible( false )
			adSlider2:SetVisible( false )
			adSlider3:SetVisible( false )
			adSlider4:SetVisible( false )
			edCheckbox1:SetVisible( false )
			edCheckbox2:SetVisible( false )
			edCheckbox3:SetVisible( false )
			edCheckbox4:SetVisible( false )
			edCheckbox5:SetVisible( false )
			edCheckbox6:SetVisible( false )
			edCheckbox7:SetVisible( false )
			edCheckbox8:SetVisible( false )
			edCheckbox9:SetVisible( false )
			edSlider1:SetVisible( false )
			edSlider2:SetVisible( false )
			vdCheckbox1:SetVisible( false )
			vdCheckbox2:SetVisible( false )
			vdCheckbox3:SetVisible( false )
			vdCheckbox4:SetVisible( false )
			vdCheckbox5:SetVisible( false )
			vdCheckbox6:SetVisible( false )
			vdButton1:SetVisible( false )
			vdButton2:SetVisible( false )
			rdCheckbox1:SetVisible( false )
			rdCheckbox2:SetVisible( false )
			rdCheckbox3:SetVisible( false )
			mdCheckbox1:SetVisible( false )
			mdCheckbox2:SetVisible( false )
			mdButton1:SetVisible( false )
			mdSlider1:SetVisible( false )
			mdButton2:SetVisible( false )
			dListView:SetVisible( true )
		end
		
end

PB:AddConCommand( "+pb_menu", Menu )
PB:AddConCommand( "-pb_menu", function()
	Menu:SetVisible( false )
	RRadar:SetMouseInputEnabled( false )
	RRadar:SetKeyboardInputEnabled( false )
	AAdminList:SetMouseInputEnabled( false )
	AAdminList:SetKeyboardInputEnabled( false )
	IInfoMenu:SetMouseInputEnabled( false )
	IInfoMenu:SetKeyboardInputEnabled( false )
 end )
 
RunConsoleCommand( "+pb_menu" )
RunConsoleCommand( "-pb_menu" )

/*--------------------------------------------------
	Protection
	Desc: Stop the faggots.
*/--------------------------------------------------

local old_filecdir = file.CreateDir
local old_filedel = file.Delete
local old_fileexist = file.Exists
local old_fileexistex = file.ExistsEx
local old_filefind = file.Find
local old_filefinddir = file.FindDir
local old_filefindil = file.FindInLua
local old_fileisdir = file.IsDir
local old_fileread = file.Read
local old_filerename = file.Rename
local old_filesize = file.Size
local old_filetfind = file.TFind
local old_filetime = file.Time
local old_filewrite = file.Write
local old_dbginfo = debug.getinfo
local old_dbginfo = debug.getupvalue
local old_cve = ConVarExists
local old_gcv = GetConVar
local old_gcvn = GetConVarNumber
local old_gcvs = GetConVarString
local old_rcc = RunConsoleCommand
local old_hookadd = hook.Add
local old_hookrem = hook.Remove
local old_ccadd = concommand.Add
local old_ccrem = concommand.Remove
local old_cvaracc = cvars.AddChangeCallback
local old_cvargcvc = cvars.GetConVarCallbacks
local old_cvarchange = cvars.OnConVarChanged
local old_require = require
local old_eccommand = engineConsoleCommand

/*
function RunConsoleCommand( cmd, val )

	local ply = LocalPlayer()

	for k, v in pairs( Block ) do
		if string.find( string.lower( val ), v ) then
			return nil, PB:ConsoleMessage( "Blocked - ('" .. val .. "') Reason: tried to run the word: ('" .. v  .. "') (a blocked string) " )
		end
	end
	
	for k, v in pairs( BadCMDs ) do
		if string.find( string.lower( cmd ), "kill" ) then 
			return nil, PB:ConsoleMessage( "Blocked - ('" .. cmd .. "') Reason: Tried to run ('" .. v .. "') (a blocked command)." )
		end
	end
	
	if string.find( string.lower( cmd ), "say" ) then
		return nil, PB:ConsoleMessage( "Blocked - ('" .. cmd .. "') Reason: Tried to run ('say') (a blocked command)." )
	end
	
	return old_rcc( cmd, val )
end
*/

function ConVarExists( cvar )

	for k, v in pairs( PB.ConVars ) do
		if string.find( string.lower( v ), cvar ) then
			return false,
			PB:ConsoleMessage( "Spoofed - " .. cvar .. " | ConVarExists" )
		end
	end
	
	return old_cve( cvar )
end

function GetConVar( cvar )

	for k, v in pairs( PB.ConVars ) do
		if string.find( string.lower( v ), cvar ) then
			return PB:ConsoleMessage( "Spoofed - " .. cvar .. " | GetConVar" ) 
		end
	end
	
	return old_gcv( cvar )
end

function GetConVarNumber( cvar )
	
		for k, v in pairs( PB.ConVars ) do
			if string.find( string.lower( v ), cvar ) then
				return PB:ConsoleMessage( "Spoofed - " .. cvar .. " | GetConVarNumber" ) 
			end
		end
	
	if string.find( string.lower( "sv_cheats" ), cvar ) then return 0 end
	if string.find( string.lower( "host_framerate" ), cvar ) then return 1 end
	if string.find( string.lower( "sv_allow_voice_from_file" ), cvar ) then return 0 end
	
	return old_gcvn( cvar )
end

function GetConVarString( cvar )

	if string.find( string.lower( "sv_cheats" ), cvar ) then return 0 end
	if string.find( string.lower( "host_framerate" ), cvar ) then return 1 end
	if string.find( string.lower( "sv_allow_voice_from_file" ), cvar ) then return 0 end
	
	return old_gcvs( cvar )
end

function hook.Add( typ, name, func )

	for k, v in pairs( PB.Hooks ) do
		if string.find( string.lower( v ), typ ) && string.find( string.lower( v ), name ) then
			return nil, PB:ConsoleMessage( "Faked - " .. name .. " | Hook.Add" ), MsgN( "[ADDED] Hook: " .. name )
		end
	end
	
	if ( name == "FlashEffect" ) then return nil end
	if ( name == "ulx_blind" ) then return nil end
	if ( name == "Drugged" ) then return nil end
	if ( name == "durgz_alcohol_high" ) then return nil end
	if ( name == "durgz_cigarette_high" ) then return nil end
	if ( name == "durgz_cocaine_high" ) then return nil end
	if ( name == "durgz_heroine_high" ) then return nil end
	if ( name == "durgz_heroine_notice" ) then return nil end
	if ( name == "durgz_lsd_high" ) then return nil end
	if ( name == "durgz_mushroom_high" ) then return nil end
	if ( name == "durgz_mushroom_awesomeface" ) then return nil end
	if ( name == "durgz_weed_high" ) then return nil end
	if ( name == "StunEffect" ) then return nil end
	
	return old_hookadd( typ, name, func ), PB:ConsoleMessage( "[ADDED] Hook: " .. name .. " [" .. typ .. "]" )
end

function hook.Remove( typ, name )

	for k, v in pairs( PB.Hooks ) do
		if string.find( string.lower( v ), typ ) && string.find( string.lower( v ), name ) then
			return nil, PB:ConsoleMessage( "Faked - " .. name .. " | Hook.Remove" ) 
		end
	end
	
	return old_hookrem( typ, name ), PB:ConsoleMessage( "[REMOVED] Hook: " .. name )
end

function concommand.Add( name, func, auto, help )

	for k, v in pairs( PB.Commands ) do
		if string.find( string.lower( v ), name ) then
			return nil, PB:ConsoleMessage( "Protected - " .. name .. " | ConCommand.Add" ) 
		end
	end
	
	return old_ccadd( name, func, auto, help )
end

function concommand.Remove( name )

	for k, v in pairs( PB.Commands ) do
		if string.find( string.lower( v ), name ) then
			return nil, PB:ConsoleMessage( "Protected - " .. name .. " | ConCommand.Remove" ) 
		end
	end
	
	return old_ccrem( name )
end

function cvars.AddChangeCallback( cvar, call )

	for k, v in pairs( PB.ConVars ) do
		if string.find( string.lower( v ), cvar ) then
			return PB:ConsoleMessage( "Spoofed - " .. cvar .. " | cvars.AddChangeCallback" )
		end
	end
	
	if string.find( string.lower( "sv_cheats" ), cvar ) then return 0 end
	if string.find( string.lower( "host_framerate" ), cvar ) then return 1 end
	if string.find( string.lower( "sv_allow_voice_from_file" ), cvar ) then return 0 end
	
	return old_cvaracc( cvar, call )
end

/*
function cvars.GetConVarCallbacks( str, bool )

	for k, v in pairs( PB.ConVars ) do
		if string.find( string.lower( v ), str ) then
			return; PB:ConsoleMessage( "Spoofed - " .. str .. " | cvars.GetConVarCallbacks" )
		end
	end
	
	if string.find( string.lower( "sv_cheats" ), str ) then return 0 end
	if string.find( string.lower( "host_framerate" ), str ) then return 1 end
	
	return old_cvargcvc( str, bool )
end

function cvars.OnConVarChanged( name, old, new )

	for k, v in pairs( PB.ConVars ) do
		if string.find( string.lower( v ), name ) then
			return PB:ConsoleMessage( "Spoofed - " .. name .. " | cvars.OnConVarChanged" )
		end
	end
	
	if string.find( string.lower( "sv_cheats" ), name ) then return 0 end
	if string.find( string.lower( "host_framerate" ), name ) then return 1 end
	
	return old_cvarchange( name, old, new )
end
*/