/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: aimbot.lua
	Purpose: Aim at people
*************************************************************/
local copy = table.Copy( HERMES.copy )

local x, y = ScrW(), ScrH()
local aiming, target, delay = false, nil, 0
local viewangles, shooting = Angle( 0, 0, 0 ), false

HERMES:AddTab( "Aimbot" )
HERMES:AddTabItem( "Aimbot", "General" )
HERMES:AddTabItem( "Aimbot", "Targeting" )
HERMES:AddTabItem( "Aimbot", "Accuracy" )

HERMES:AddSetting( "aim_shoot", true, "Autoshoot", "General" )
HERMES:AddSetting( "aim_prediction", false, "Prediction", "General" )
HERMES:AddSetting( "aim_recoil", true, "Norecoil", "Accuracy" )
HERMES:AddSetting( "aim_visrecoil", true, "NoVisRecoil", "Accuracy" )
HERMES:AddSetting( "aim_npcs", false, "NPC", "Targeting" )
HERMES:AddSetting( "aim_friendlynpcs", false, "FriendlyNPCs", "Targeting" )
HERMES:AddSetting( "aim_steam", false, "Steam", "Targeting" )
HERMES:AddSetting( "aim_team", false, "Team", "Targeting" )
HERMES:AddSetting( "aim_fakeangle", true, "FakeAngle", "General" )
HERMES:AddSetting( "aim_awall", true, "Autowall", "General" )

HERMES:AddSetting( "aim_antiaim", 0, "AntiAim", "General", 0, 2, false )
HERMES:AddSetting( "aim_fov", 180, "FOV", "General", 1, 180, false )
HERMES:AddSetting( "aim_smooth", 0, "Smoothaim", "General", 0, 50, false )

/* --------------------
	:: Angle Junk
*/ --------------------
local function NormalizeAngle( ang, roll )
	ang.p = math.NormalizeAngle( ang.p )
	ang.y = math.NormalizeAngle( ang.y )
	ang.r = roll && math.NormalizeAngle( ang.r ) || 0
	return ang
end

local function ClampAngle( ucmd, ang )
	ang.y = math.NormalizeAngle( ang.y + ( ucmd:GetMouseX() * -0.022 * 1 ) )
	ang.p = math.Clamp( ang.p + ( ucmd:GetMouseY() * 0.022 * 1 ), -89, 90 )
	return ang
end

/* --------------------
	:: FakeAngles
*/ --------------------
function HERMES:FakeAngles( ucmd )
	if( !HERMES.item['fakeangle'] ) then return end
	if( ucmd:KeyDown( IN_ATTACK | IN_ATTACK2 ) || aiming ) then return end
	
	HERMES.hermes.FakeAngles( ucmd, 205, 180 )
end

/* --------------------
	:: AntiAim
*/ --------------------
function HERMES:AntiAim( ucmd )
	if( HERMES.item['antiaim'] == 0 ) then return end
	if( ucmd:KeyDown( IN_ATTACK | IN_ATTACK2 ) || aiming ) then return end
	
	local int = HERMES.item['antiaim']
	HERMES.hermes.AntiAim( ucmd, int )
end

/* --------------------
	:: GetAngles
*/ --------------------
function HERMES:GetView()
	local ply = LocalPlayer()
	if( !ValidEntity( ply ) ) then return end
	viewangles = ply:EyeAngles()
end

/* --------------------
	:: GetPos
*/ --------------------
HERMES.bones = {}
HERMES.bones["models/combine_scanner.mdl"] = "Scanner.Body"
HERMES.bones["models/hunter.mdl"] = "MiniStrider.body_joint"
HERMES.bones["models/combine_turrets/floor_turret.mdl"] = "Barrel"
HERMES.bones["models/dog.mdl"] = "Dog_Model.Eye"
HERMES.bones["models/vortigaunt.mdl"] = "ValveBiped.Head"
HERMES.bones["models/antlion.mdl"] = "Antlion.Body_Bone"
HERMES.bones["models/antlion_guard.mdl"] = "Antlion_Guard.Body"
HERMES.bones["models/antlion_worker.mdl"] = "Antlion.Head_Bone"
HERMES.bones["models/zombie/fast_torso.mdl"] = "ValveBiped.HC_BodyCube"
HERMES.bones["models/zombie/fast.mdl"] = "ValveBiped.HC_BodyCube"
HERMES.bones["models/headcrabclassic.mdl"] = "HeadcrabClassic.SpineControl"
HERMES.bones["models/headcrabblack.mdl"] = "HCBlack.body"
HERMES.bones["models/headcrab.mdl"] = "HCFast.body"
HERMES.bones["models/zombie/poison.mdl"] = "ValveBiped.Headcrab_Cube1"
HERMES.bones["models/zombie/classic.mdl"] = "ValveBiped.HC_Body_Bone"
HERMES.bones["models/zombie/classic_torso.mdl"] = "ValveBiped.HC_Body_Bone"
HERMES.bones["models/zombie/zombie_soldier.mdl"] = "ValveBiped.HC_Body_Bone"
HERMES.bones["models/combine_strider.mdl"] = "Combine_Strider.Body_Bone"
HERMES.bones["models/combine_dropship.mdl"] = "D_ship.Spine1"
HERMES.bones["models/combine_helicopter.mdl"] = "Chopper.Body"
HERMES.bones["models/gunship.mdl"] = "Gunship.Body"
HERMES.bones["models/lamarr.mdl"] = "HeadcrabClassic.SpineControl"
HERMES.bones["models/mortarsynth.mdl"] = "Root Bone"
HERMES.bones["models/synth.mdl"] = "Bip02 Spine1"
HERMES.bones["mmodels/vortigaunt_slave.mdl"] = "ValveBiped.Head"

HERMES.friends = {}
HERMES.friends["npc_monk"] = true
HERMES.friends["npc_crow"] = true
HERMES.friends["npc_seagull"] = true
HERMES.friends["npc_pigeon"] = true
HERMES.friends["npc_alex"] = true
HERMES.friends["npc_barney"] = true
HERMES.friends["npc_citizen"] = true
HERMES.friends["npc_kleiner"] = true
HERMES.friends["npc_magnusson"] = true
HERMES.friends["npc_eli"] = true
HERMES.friends["npc_gman"] = true
HERMES.friends["npc_mossman"] = true
HERMES.friends["npc_vortigaunt"] = true
HERMES.friends["npc_breen"] = true
HERMES.friends["monser_barney"] = true
HERMES.friends["monser_scientist"] = true


HERMES.predictweapons = {
	["weapon_crossbow"] = 3110,
}

-- Prediction
function HERMES:WeaponPrediction( e, pos )
	local ply = LocalPlayer()
	if ( ValidEntity( e ) && ( type( e:GetVelocity() ) == "Vector" ) ) then
		local dis, wep = e:GetPos():Distance( ply:GetPos() ), ( ply.GetActiveWeapon && ValidEntity( ply:GetActiveWeapon() ) && ply:GetActiveWeapon():GetClass() )
		if ( wep && HERMES.predictweapons[ wep ]  ) then
			local t = dis / HERMES.predictweapons[ wep ]
			return ( pos + e:GetVelocity() * t )
		end
		return pos
	end
	return pos
end

-- Get pos depending on it being a string or vector.
function HERMES:GetPosType( e, pos )
	if ( type( pos ) == "string" ) then
		return ( e:GetBonePosition( e:LookupBone( pos ) ) )
	elseif ( type( pos ) == "Vector" ) then
		return ( e:LocalToWorld( e:OBBCenter() + pos ) )
	end
	return ( e:LocalToWorld( pos ) )
end

function HERMES:GetPos( e )
	local pos = HERMES:GetPosType( e, "ValveBiped.Bip01_Head1" )
	
	local usingAttachments = false
	if ( e:GetAttachment( e:LookupAttachment( "eyes" ) ) ) then
		pos = e:GetAttachment( e:LookupAttachment( "eyes" ) ).Pos;
		usingAttachments = true
	elseif ( e:GetAttachment( e:LookupAttachment( "forward" ) ) ) then
		pos = e:GetAttachment( e:LookupAttachment("forward") ).Pos;
		usingAttachments = true
	elseif ( e:GetAttachment( e:LookupAttachment( "head" ) ) ) then
		pos = e:GetAttachment( e:LookupAttachment( "head" ) ).Pos;
		usingAttachments = true
	else
		pos = HERMES:GetPosType( e, "ValveBiped.Bip01_Head1" );
		usingAttachments = false
	end
	
	if ( !usingAttachments ) then
		if( HERMES.bones[e:GetModel()] ) then
			pos = HERMES:GetPosType( e, HERMES.bones[e:GetModel()] );
		end
	end
	return HERMES:WeaponPrediction( e, pos )
end

/* --------------------
	:: Smooth aim
*/ --------------------
function HERMES:Smoothaim( ang )
	if( HERMES.item['smoothaim'] == 0 ) then return ang end
	local speed, ply = RealFrameTime() / ( HERMES.item['smoothaim'] / 50 ), LocalPlayer()
	local angl = LerpAngle( speed, ply:EyeAngles(), ang )
	return Angle( angl.p, angl.y, 0 )
end

/* --------------------
	:: Prediction
*/ --------------------
function HERMES:Prediction( tar, compensate )
	local ply = LocalPlayer()
	if( HERMES.item['prediction'] ) then
		local tarFrames, plyFrames = ( RealFrameTime() / 25 ), ( RealFrameTime() / 66 )
		return compensate + ( ( tar:GetVelocity() * ( tarFrames ) ) - ( ply:GetVelocity() * ( plyFrames ) ) )
	end
	return compensate
end

/* --------------------
	:: IsVisible
*/ --------------------
function HERMES:IsVisible( e )
	local ply = LocalPlayer()
	
	local pos = HERMES:GetPos( e )
	pos = HERMES:Prediction( e, pos )
	
	local trace = { 
		start = ply:GetShootPos(), 
		endpos = pos, 
		filter = { ply, e }, 
		mask = MASK_SHOT
	}
	local tr = util.TraceLine( trace )
	
	if( HERMES:IsPenetrable( tr ) ) then return true end
	
	if( !tr.Hit ) then
		return true
	end
	return false
end

/* --------------------
	:: GetAimTarget
*/ --------------------
function HERMES:GetAimTargets()
	local ret, ent = {}, HERMES.item['npc'] && ents.GetAll() || player.GetAll()
	for k, e in ipairs( ent ) do
		if( HERMES:FilterTargets( e, "aim" ) && HERMES:IsVisible( e ) ) then
			table.insert( ret, e )
		end
	end
	return ret
end

/* --------------------
	:: FilterAimTargets
*/ --------------------
function HERMES:FilterAimTargets()
	if( HERMES:FilterTargets( target, "aim" ) && HERMES:IsVisible( target ) ) then return target else target = nil end
	local targets, ply = HERMES.item['npc'] && ents.GetAll() || player.GetAll(), LocalPlayer()
	local tar, pos, ang = { 0, 0 }, ply:EyePos(), ply:GetAimVector()
	for k, e in ipairs( targets ) do
		if( HERMES:FilterTargets( e, "aim" ) && HERMES:IsVisible( e ) ) then
			local eyepos = e:EyePos()
			local difr = ( eyepos - pos ):Normalize()
			difr = difr - ang
			difr = difr:Length()
			difr = math.abs( difr )
			if( difr < tar[2] || tar[1] == 0 ) then
				tar = { e, difr }
			end	
		end
	end
	return ( tar[1] != 0 && tar[1] != ply ) && tar[1] || nil
end

/* --------------------
	:: Aimbot
*/ --------------------
local SetAngles = _R["CUserCmd"].SetViewAngles //HERMES.hermes.SetViewAngles

function HERMES:Aimbot( ucmd )
	local ply = LocalPlayer()
	
	viewangles = NormalizeAngle( viewangles )
	viewangles = ClampAngle( ucmd, viewangles )
	
	local inSpread = false
	if( HERMES.item['spread'] && ucmd:KeyDown( IN_ATTACK ) ) then
		local ang = HERMES:PredictSpread( ucmd, viewangles )
		ang = NormalizeAngle( ang )
		
		SetAngles( ucmd, ang )
		inSpread = true
	end
	
	if( HERMES.item['norecoil'] && !inSpread ) then
		SetAngles( ucmd, viewangles )
	end
	
	HERMES:AntiAim( ucmd )
	HERMES:FakeAngles( ucmd )
	
	if( !aiming ) then return end
	
	local tar = HERMES:FilterAimTargets()
	if( !tar ) then return end
	
	target = tar
	
	local compensate = HERMES:GetPos( tar )
	compensate = HERMES:Prediction( tar, compensate )
	
	viewangles = ( compensate - ply:GetShootPos() ):Angle()
	viewangles = HERMES:Smoothaim( viewangles )
	local ang = HERMES.item['spread'] && HERMES:PredictSpread( ucmd, viewangles ) || viewangles
	ang = NormalizeAngle( ang )
	
	SetAngles( ucmd, ang )
	
	local w = ply:GetActiveWeapon()
	if ( HERMES.item['autoshoot'] && !shooting ) then
		HERMES.hermes.RunCommand( "+attack" )
		shooting = true
		timer.Simple( ( w && w.Primary ) && w.Primary.Delay || 0.05, function() HERMES.hermes.RunCommand( "-attack" ); shooting = false end )
	end
end

HERMES:AddCommand( "+hermes_aim", function() aiming = true end )
HERMES:AddCommand( "-hermes_aim", function() aiming = false target = nil end )

/* --------------------
	:: CalcView
*/ --------------------
function HERMES.CalcView( ply, origin, angles, FOV )
	local ply = LocalPlayer()
	local w = ply:GetActiveWeapon()
	
	if( HERMES.item['novisrecoil'] ) then
		local view = GAMEMODE:CalcView( ply, origin, viewangles, FOV ) || {}
			view.angles = viewangles
			view.angles.r = 0
		return view
	end
	return GAMEMODE:CalcView( ply, origin, angles, FOV )
end

/* --------------------
	:: Global Vars
*/ --------------------
function HERMES:Globals()
	HERMES.aiming = aiming
	HERMES.viewangles = viewangles
end

/* --------------------
	:: OnToggled
*/ --------------------
function HERMES.OnToggled()
	HERMES:GetView();
end
HERMES:AddHook( "OnToggled", HERMES.OnToggled )

/* --------------------
	:: CreateMove
*/ --------------------
function HERMES.CreateMove( ucmd )
	HERMES:Aimbot( ucmd );
	HERMES:Bunnyhop( ucmd );
	HERMES:Autopistol( ucmd );
	HERMES:Triggerbot( ucmd )
	HERMES:Globals();
end
HERMES:AddHook( "CreateMove", HERMES.CreateMove )

/* --------------------
	:: CalcView
*/ --------------------
HERMES:AddHook( "CalcView", HERMES.CalcView )