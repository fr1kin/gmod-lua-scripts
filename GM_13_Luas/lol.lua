
local G = _G;

include "nm.lua"
include "admins.lua"

if not package.loaded.dickwrap then require('dickwrap') MsgC(Color(0,255,0),'\nrequired dickwrap\n') end

local shitff = CreateClientConVar('xhit_aim_steam',0,true,false) 
local novisrec = CreateClientConVar('xhit_aim_calcview',0,true,false)
local aimadmin = CreateClientConVar('xhit_aim_admins',0,true,false)
local aimteam = CreateClientConVar('xhit_aim_team',0,true,false)
local xhitvis = CreateClientConVar('xhit_vis',1,true,false)
local xhitfff = CreateClientConVar('xhit_temp',1,true,false)
local xhitst = CreateClientConVar('xhit_speedstop',1,true,false)
local shitstid = CreateClientConVar('xhit_aim_stid','STEAM_0:0:19768725')
local aimnpc = CreateClientConVar('xhit_aim_npc',0, false, false)


local offsetz = CreateClientConVar( "xhit_offset_z", 0, true, false )
local offsety = CreateClientConVar( "xhit_offset_y", 0, true, false )
local offsetx = CreateClientConVar( "xhit_offset_x", 0, true, false )

local ent = {};

ent.npcs = {};

ent.plys = {};
ent.weps = {};
ent.npcs = {};

ent.ply = NULL;

ent.LastPositions = {}

ent.admin = {
	[1] = "IsSuperAdmin",
	[2] = "IsAdmin",
	[3] = "EV_IsOwner",
	[4] = "EV_IsSuperAdmin",
	[5] = "EV_IsAdmin",
	[6] = "EV_IsRespected",
	[7] = "IsRespected",
}

local stids = {}

concommand.Add('xhit_add', function()

		if LocalPlayer():GetEyeTrace().Entity:IsPlayer() then
		table.insert(stids,LocalPlayer():GetEyeTrace().Entity:SteamID())

		chat.AddText(Color(0,255,0),'Added '.. LocalPlayer():GetEyeTrace().Entity:Nick() .. ' (' .. LocalPlayer():GetEyeTrace().Entity:SteamID() .. ') to filter')
		end
	--end
end)

concommand.Add('xhit_remove', function()

		if LocalPlayer():GetEyeTrace().Entity:IsPlayer() then
		stids[LocalPlayer():GetEyeTrace().Entity:SteamID()] = nil

		chat.AddText(Color(0,255,0),'Removed '.. LocalPlayer():GetEyeTrace().Entity:Nick() .. ' (' .. LocalPlayer():GetEyeTrace().Entity:SteamID() .. ') from filter')
		end

end)

/*
local bones = {};
bones["models/combine_scanner.mdl"] = "Scanner.Body"
bones["models/hunter.mdl"] = "MiniStrider.body_joint"
bones["models/combine_turrets/floor_turret.mdl"] = "Barrel"
bones["models/dog.mdl"] = "Dog_Model.Eye"
bones["models/vortigaunt.mdl"] = "ValveBiped.Head"
bones["models/antlion.mdl"] = "Antlion.Body_Bone"
bones["models/antlion_guard.mdl"] = "Antlion_Guard.Body"
bones["models/antlion_worker.mdl"] = "Antlion.Head_Bone"
bones["models/zombie/fast_torso.mdl"] = "ValveBiped.HC_BodyCube"
bones["models/zombie/fast.mdl"] = "ValveBiped.HC_BodyCube"
bones["models/headcrabclassic.mdl"] = "HeadcrabClassic.SpineControl"
bones["models/headcrabblack.mdl"] = "HCBlack.body"
bones["models/headcrab.mdl"] = "HCFast.body"
bones["models/zombie/poison.mdl"] = "ValveBiped.Headcrab_Cube1"
bones["models/zombie/classic.mdl"] = "ValveBiped.HC_Body_Bone"
bones["models/zombie/classic_torso.mdl"] = "ValveBiped.HC_Body_Bone"
bones["models/zombie/zombie_soldier.mdl"] = "ValveBiped.HC_Body_Bone"
bones["models/combine_strider.mdl"] = "Combine_Strider.Body_Bone"
bones["models/combine_dropship.mdl"] = "D_ship.Spine1"
bones["models/combine_helicopter.mdl"] = "Chopper.Body"
bones["models/gunship.mdl"] = "Gunship.Body"
bones["models/lamarr.mdl"] = "HeadcrabClassic.SpineControl"
bones["models/mortarsynth.mdl"] = "Root Bone"
bones["models/synth.mdl"] = "Bip02 Spine1"
bones["mmodels/vortigaunt_slave.mdl"] = "ValveBiped.Head"
*/
local function GetWeaponVector( value )
	local s = -value;
	return G.Vector( s, s, s ) 


end

local function GetWeaponVector2( value )
	local s = -value;
	return G.Vector( s, s, 0 );
end

local CONE = {};

CONE["weapon_pistol"] = GetWeaponVector( 0.0100 );
CONE["weapon_smg1"] = GetWeaponVector( 0.04362 );
CONE["weapon_ar2"]	= GetWeaponVector( 0.02618 );
CONE["weapon_shotgun"] = GetWeaponVector( 0.08716 );
CONE["weapon_zs_zombie"] = GetWeaponVector( 0.0 );
CONE["weapon_zs_fastzombie"] = GetWeaponVector( 0.0 );
// DarkRP spread is fucking stupid
--CONE["weapon_cs_base2"] = Shit.GetWeaponVector(0.02)
/*
CONE["weapon_fiveseven2"] = GetWeaponVector2(0.03 + .05)
CONE["weapon_deagle2"] = GetWeaponVector2(0.01 + .05) --0.01
CONE["weapon_glock2"] = GetWeaponVector2(0.1 + .05)
CONE["weapon_ak472"] = GetWeaponVector2(0.002 + .05) 
CONE["weapon_p2282"] = GetWeaponVector2(0.04 + .05)
CONE["weapon_mac102"] = GetWeaponVector2(0.02 + .05)
CONE["weapon_mp52"] = GetWeaponVector2(0.005 + .05)
CONE["weapon_m42"] = GetWeaponVector2(0.03 + .05)


// ttt
CONE["weapon_zm_sledge"] = GetWeaponVector2(0.09)
CONE["weapon_zm_rifle"] = GetWeaponVector2(0.005)
CONE["weapon_zm_pistol"] = GetWeaponVector2(0.02)
CONE["weapon_zm_mac10"] = GetWeaponVector2(0.03)
CONE["weapon_ttt_sipistol"] = GetWeaponVector2(0.02)
CONE["weapon_ttt_m16"] = GetWeaponVector2(0.018)
CONE["weapon_ttt_glock"] = GetWeaponVector2(0.028)
CONE["weapon_zm_revolver"] = GetWeaponVector2(0.02)
CONE["weapon_ttt_mp5"] = GetWeaponVector2(0.03)
CONE["weapon_ttt_famas"] = GetWeaponVector2(0.025)
CONE["weapon_ttt_sg552"] = GetWeaponVector2(0.0)
CONE["weapon_ttt_aug"] = GetWeaponVector2(0.02)
CONE["weapon_ttt_p90"] = GetWeaponVector2(0.02)
CONE["weapon_gxysv_galil"] = GetWeaponVector2(0.055)
CONE["weapon_gxysv_aug"] = GetWeaponVector2(0.03)
CONE["weapon_gxysv_p90"] = GetWeaponVector2(0.04)
CONE["weapon_mp5navy"] = GetWeaponVector2(0.019)
CONE["weapon_sig552"] = GetWeaponVector2(0.02)
CONE["weapon_ti_p90"] = GetWeaponVector2(0.07)


// real css



CONE["weapon_real_cs_desert_eagle"] = GetWeaponVector2(0.014 )
CONE["weapon_real_cs_five-seven"] = GetWeaponVector2( 0.011)
CONE["weapon_real_cs_glock"] = GetWeaponVector2( 0.014)
CONE["weapon_real_cs_usp"] = GetWeaponVector2(0.0155)
CONE["weapon_real_cs_p228"] = GetWeaponVector2( 0.0125)
CONE["weapon_real_cs_p90"] = GetWeaponVector2(0.013 )
CONE["weapon_real_cs_mp5a5"] = GetWeaponVector2(0.007 )
CONE["weapon_real_cs_mac10"] = GetWeaponVector2(0.024 )
CONE["weapon_real_cs_ump_45"] = GetWeaponVector2(0.019 )
CONE["weapon_real_cs_tmp"] = GetWeaponVector2(0.028 )
CONE["weapon_real_cs_admin_weapon"] = GetWeaponVector2(0.01 )
CONE["weapon_real_cs_m4a1"] = GetWeaponVector2(0.012 )
CONE["weapon_real_cs_g3sg1"] = GetWeaponVector2(0.0035 )
CONE["weapon_real_cs_galil"] = GetWeaponVector2(0.017 )
CONE["weapon_real_cs_m249"] = GetWeaponVector2( 0.015)
CONE["weapon_real_cs_ak47"] = GetWeaponVector2(0.023 )
CONE["weapon_real_cs_awp"] = GetWeaponVector2(0.0001 )
CONE["weapon_real_cs_sg552"] = GetWeaponVector2( 0.007)
CONE["weapon_real_cs_sg550"] = GetWeaponVector2(0.0035 )
CONE["weapon_real_cs_famas"] = GetWeaponVector2(0.015 )
CONE["weapon_real_cs_m249"] = GetWeaponVector2(0.015)
CONE["weapon_real_cs_aug"] = GetWeaponVector2(0.0007)
CONE["weapon_real_cs_glock18"] = GetWeaponVector2( 0.014)
// css

//timer.Create('conecheck',1,0, function()


CONE["weapon_deagle"] = GetWeaponVector2(0.02 )
CONE["weapon_fiveseven"] = GetWeaponVector2(0.02 )
CONE["weapon_p90"] = GetWeaponVector2( 0.02)
CONE["weapon_ump45"] = GetWeaponVector2( 0.02)
CONE["weapon_mp5"] = GetWeaponVector2(0.01 )
CONE["weapon_tmp"] = GetWeaponVector2( 0.04)
CONE["weapon_famas"] = GetWeaponVector2(0.02 )
CONE["weapon_ak47"] = GetWeaponVector2( 0.02)
CONE["weapon_m4"] = GetWeaponVector2( 0.02)
CONE["weapon_para"] = GetWeaponVector2( 0.05)
CONE["weapon_sg552"] = GetWeaponVector2( 0.02)
CONE["weapon_galil"] = GetWeaponVector2( 0.02)
CONE["weapon_aug"] = GetWeaponVector2( 0.02)
CONE["weapon_glock"] = GetWeaponVector2( 0.03)

CONE["weapon_mad_galil"] = GetWeaponVector2( 0.017)
CONE["weapon_mad_357"] = GetWeaponVector2( 0.0125)
CONE["weapon_mad_glock"] = GetWeaponVector2( .014)
CONE["weapon_mad_p228"] = GetWeaponVector2( 0.0125)
CONE["weapon_mad_sg552"] = GetWeaponVector2( 0.007)
CONE["weapon_mad_sg550"] = GetWeaponVector2( 0.00075)
CONE["weapon_mad_scout"] = GetWeaponVector2(0.005)
CONE["weapon_mad_famas"] = GetWeaponVector2(0.015)




//CONE["weapon_sh_ak47"] = GetWeaponVector2(0.008)
CONE["weapon_sh_ak47"] = GetWeaponVector2(0.005)
CONE["weapon_sh_m4a2"] = GetWeaponVector2(0.005)
CONE["weapon_sh_m249"] = GetWeaponVector2(0.007)
CONE["weapon_sh_tmp"] = GetWeaponVector2(0.008)
CONE["weapon_sh_mp5a4"] = GetWeaponVector2(0.007)
CONE["weapon_sh_p228"] = GetWeaponVector2(0.01)
CONE["weapon_sh_famas"] = GetWeaponVector2(0.005)
CONE["weapon_sh_galil"] = GetWeaponVector2(0.003)
CONE["weapon_sh_deagle"] = GetWeaponVector2(0.01)
CONE["weapon_sh_usp"] = GetWeaponVector2(0.01)
CONE["weapon_mad_ak47"] = GetWeaponVector2(0.027)


CONE["weapon_sh_mac11-380"] = GetWeaponVector2(0.006)
CONE["weapon_sh_glock18"] = GetWeaponVector2(0.01)
CONE["weapon_sh_five-seven"] = GetWeaponVector2(0.01)
CONE["weapon_mad_deagle"] = GetWeaponVector2(0.02)
CONE["weapon_fas_sr25"] = GetWeaponVector2(0.005)
CONE["weapon_fas_m9"] = GetWeaponVector2(0.021)
CONE["weapon_fas_mp5"] = GetWeaponVector2(0.01)
CONE["weapon_fas_m4a1"] = GetWeaponVector2(0.005)
CONE["weapon_fas_m4carb"] = GetWeaponVector2(0.005)


CONE["weapon_tmp2"] = GetWeaponVector2(0.022)
*/
local _R = G.debug.getregistry();

local BULLET = {};

local oldBullets = _R.Entity.FireBullets;

function _R.Entity.FireBullets( ent, bulletinfo )
	local wep = G.LocalPlayer():GetActiveWeapon();
	BULLET[wep:GetClass()] = bulletinfo.Spread;
	return oldBullets( ent, bulletinfo );
end

local function PredictSpread( ucmd, angl )
	local wep = G.LocalPlayer():GetActiveWeapon();
	if( wep && G.IsValid( wep ) ) then
		if( !CONE[wep:GetClass()] ) then
			if( BULLET[wep:GetClass()] ) then
				local ang = angl:Forward() || ( ( G.LocalPlayer():GetAimVector() ):Angle() ):Forward();
				local conevec = G.Vector( 0, 0, 0 ) - BULLET[wep:GetClass()] || Vector( 0, 0, 0 );
				return( dickwrap.Predict( ucmd, ang, conevec ) ):Angle();
			end
		else
			ang = angl:Forward() || ( ( G.LocalPlayer():GetAimVector() ):Angle() ):Forward();
			conevec = CONE[wep:GetClass()];
			return( dickwrap.Predict( ucmd, ang, conevec ) ):Angle();
		end
	end
	return angl;
end

function ent:IsValidTarget( pl )
	if( !pl ) then return false; end
	if( G.IsValid( pl ) == false ) then return false; end
	
	if( pl == ( G.LocalPlayer() ) ) then return false; end
	if( ent.plys[pl].Alive == false || pl:Health( ) <= 0 ) then return false; end
	if( pl:GetMoveType( ) == MOVETYPE_OBSERVER || pl:GetMoveType( ) == MOVETYPE_NONE ) then return false; end
	if( ( G.team.GetName( pl:Team( ) ):lower():find( "spectat" ) ) == true ) then return false; end
	return true;
end

CreateClientConVar( "xhit_aim_predict", 1, false, false );

local function GetPlayerPos( pl, def )
	if( GetConVarNumber( "xhit_aim_predict" ) == 0 ) then
		return def;
	end
	local tbl = ent.LastPositions[pl] or {}
	
	tbl.pos = tbl.pos or def or pl:GetPos( )
	
	local realtime = G.RealTime()
	if(tbl.rt != realtime) then
		tbl.rt = realtime
		tbl.pos = def or pl:GetPos( )
	end
	
	ent.LastPositions[pl] = tbl
	
	return tbl.pos
end

function ent:GetHeadPos( entity )
	if( !entity || entity && !G.IsValid( entity ) ) then
		return Vector( NULL, NULL, NULL );
	end
	
	local att = entity:GetAttachment( entity:LookupAttachment( "head" ) );
	//if( att ) then
	if( att && att.Pos ) then

		return att.Pos;
	end
	
	local model = entity:GetModel( );
	if( bones[model] ) then
		return entity:GetBonePosition( entity:LookupBone( bones[model] ) );
	end
	
	return entity:GetBonePosition( entity:LookupBone( "ValveBiped.Bip01_Head1" ) );
end

local Aimspots = {
		"eyes",
		"forward",
		"head",
}
	
local Bones = {
		["head"] = "ValveBiped.Bip01_Head1",
		["neck"] = "ValveBiped.Bip01_Neck1",

}

do
	 function ent:GetHeadPos2( entity )
		local angP = entity:EyeAngles().p || 0;
		if( angP > 89 || angP < -89 ) then
			return GetPlayerPos( entity, ( entity:LocalToWorld( entity:OBBCenter() ) ) );
		end
		for _, v in pairs( Aimspots ) do
			pos = entity:GetAttachment( entity:LookupAttachment( v ) );
			if( pos && pos.Pos ) then
				local predict = GetPlayerPos( entity, pos.Pos );
				return predict;
			end
		end
		return GetPlayerPos( entity, ( entity:LocalToWorld( entity:OBBCenter() ) ) );
	end
end

function ent:IsVisible( entity, pos )
	//pos = pos || ent:GetHeadPos( entity );
	pos = pos || ent:GetHeadPos2( entity );
	local ply = G.LocalPlayer();
	local trace = {
		start = ply:GetShootPos( ply ), 
		endpos = pos, 
		filter = { ply, entity }, 
		mask = MASK_SHOT
	};
	
	local tr = G.util.TraceLine( trace );
	
	if( tr.Fraction == 1.0 ) then
		return true;
	end
	return false;
end

function ent:IsAdmin( pl )
	local R = G.debug.getregistry();
	for k, v in G.pairs( ent.admin ) do
		if( ( R.Player[v] && R.Player[v]( pl ) == true ) ) then
			return true;
		end
	end
	return false;
end

function ent:GetPlayers()
	return ent.plys;
end

function ent:GetNPCS()
	return ent.npcs;
end

function ent:GetEnts()
	local tbl = {};
	for k, v in pairs( ent.plys ) do
		tbl[k] = v;
	end
	for k, v in pairs( ent.npcs ) do
		tbl[k] = v;
	end
	return tbl;
end

function ent:GetInfo( entity )
	if( ent.plys[ entity ] ) then
		return ent.plys[ entity ];
	elseif( ent.weps[ entity ] ) then
		return ent.weps[ entity ];
	end
	return nil;
end

function ent:SetInfo( entity, info, value )
	if( ent.plys[ entity ] ) then
		if( info != nil && ent.plys[ entity ][ info ] ) then
			ent.plys[ entity ][ info ] = value;
		elseif( info == nil && ent.plys[ entity ] ) then
			ent.plys[ entity ] = value;
		end
		return;
	elseif( ent.npcs[ entity ] ) then
		if( info != nil && ent.npcs[ entity ][ info ] ) then
			ent.npcs[ entity ][ info ] = value;
		elseif( info == nil && ent.npcs[ entity ] ) then
			ent.npcs[ entity ] = value;
		end
		return;
	end
	return nil;
end

local trace, tr;
	local function GetVisibleTarget( self, ent )
		trace = {
			start = G.LocalPlayer():GetShootPos(),
			//endpos = self:GetHeadPos( ent ),
			endpos = self:GetHeadPos2( ent ),
			filter = { ent, G.LocalPlayer() },
			mask = MASK_SHOT
		};
		tr = G.util.TraceLine( trace );
		return( tr.Fraction == 1.0 && true ) || false;
	end


function ent.PlayerFilter( pl )
	if( pl == nil ) then
		return NULL;
	end
	if( G.IsValid( pl ) == false ) then
		return NULL;
	end
	if( !pl:IsPlayer() ) then return NULL; end
	
	local ply = G.LocalPlayer();
	
	if( !ent.plys[pl] ) then
		ent.plys[pl]					= {};
		
		ent.plys[pl].IsVisible			= false;
		ent.plys[pl].ValidTarget		= false;
		ent.plys[pl].SpawnProtection	= false;
		ent.plys[pl].JustSpawned		= false;
		
		ent.plys[pl].IsAdmin			= false;
		ent.plys[pl].IsFriend			= false;
		ent.plys[pl].IsTeammate			= false;
		ent.plys[pl].IsDormant			= false;
		
		ent.plys[pl].Alive				= false;
		ent.plys[pl].LastAlive			= false;
		
		ent.plys[pl].Name				= NULL;
		ent.plys[pl].Health				= NULL;
		ent.plys[pl].Weapon				= NULL;
		ent.plys[pl].HeadPos			= NULL;
	end
	
	ent.plys[pl].Alive				= pl:Alive( ) || false;
	
	//ent.plys[pl].HeadPos			= ent:GetHeadPos( pl ) || NULL
	ent.plys[pl].HeadPos			= ent:GetHeadPos2( pl ) || NULL
	
	ent.plys[pl].IsVisible			= ent:IsVisible( pl );
	ent.plys[pl].ValidTarget		= ent:IsValidTarget( pl );
	
	ent.plys[pl].JustSpawned		= false;
	
	ent.plys[pl].IsAdmin			= ent:IsAdmin( pl );
	ent.plys[pl].IsFriend 			= pl:GetFriendStatus( ) == "friend";
	ent.plys[pl].IsTeammate			= G.team.GetName( ply:Team( ) ) == G.team.GetName( pl:Team( ) );
	ent.plys[pl].IsDormant			= false;
	
	if( ent.plys[pl].Alive == true && ent.plys[pl].LastAlive ) then
		ent.plys[pl].JustSpawned	= true;
	end
	
	ent.plys[pl].Name				= pl:Name( ) || "NULL";
	ent.plys[pl].Health				= pl:Health( ) || NULL;
	ent.plys[pl].Weapon				= pl:GetActiveWeapon( ) || "NULL";
	
	ent.plys[pl].LastAlive			= ent.plys[pl].Alive;
end

function ent:IsValidNPCTarget( pl )
	if( !pl ) then return false; end
	if( G.IsValid( pl ) == false ) then return false; end
	if( pl:GetMoveType( ) == MOVETYPE_NONE ) then return false; end
	return true;
end

function ent.NPCFilter( npc )
	if( npc == nil ) then
		return NULL;
	end
	if( G.IsValid( npc ) == false ) then
		return NULL;
	end
	if( !npc:IsNPC() ) then return NULL; end
	
	if( !ent.npcs[npc] ) then
		ent.npcs[npc]					= {};
		
		ent.npcs[npc].IsVisible			= false;
		ent.npcs[npc].ValidTarget		= false;
		ent.npcs[npc].SpawnProtection	= false;
		ent.npcs[npc].JustSpawned		= false;
		
		ent.npcs[npc].IsAdmin			= false;
		ent.npcs[npc].IsFriend			= false;
		ent.npcs[npc].IsTeammate		= false;
		ent.npcs[npc].IsDormant			= false;
		
		ent.npcs[npc].Alive				= false;
		ent.npcs[npc].LastAlive			= false;
		
		ent.npcs[npc].Name				= NULL;
		ent.npcs[npc].Health			= NULL;
		ent.npcs[npc].Weapon			= NULL;
		ent.npcs[npc].HeadPos			= NULL;
	end
	
	ent.npcs[npc].Alive				= npc:GetMoveType( ) != MOVETYPE_NONE;
	
	ent.npcs[npc].HeadPos			= ent:GetHeadPos2( npc ) || NULL
	
	ent.npcs[npc].IsVisible			= ent:IsVisible( npc );
	ent.npcs[npc].ValidTarget		= ent:IsValidNPCTarget( npc );
	
	ent.npcs[npc].JustSpawned		= false;
	
	ent.npcs[npc].IsAdmin			= false;
	ent.npcs[npc].IsFriend 			= false;
	ent.npcs[npc].IsTeammate		= false;
	ent.npcs[npc].IsDormant			= false;
	
	ent.npcs[npc].Name				= npc:GetClass() || "NULL";
	ent.npcs[npc].Health			= NULL;
	ent.npcs[npc].Weapon			= "NULL";
	
	ent.npcs[npc].LastAlive			= ent.npcs[npc].Alive;
end

function ent.WeaponFilter( w )
	if( w == nil ) then
		return NULL;
	end
	
	if( G.IsValid( w ) == false ) then
		return NULL;
	end
	
	if( !ent.weps[w] ) then
		ent.weps[w]			= {};
		
		ent.weps[w].Delay 		= 0.05;
		ent.weps[w].NextShot 	= 0.00;
		ent.weps[w].Clip1		= NULL;
		ent.weps[w].Clip2		= NULL;
	end
	
	ent.weps[w].Delay 		= w.Primary && w.Primary.Delay || w.Delay;
	
	if( ent.weps[w].Delay == nil ) then
		ent.weps[w].Delay = 0.05;
	end
	
	ent.weps[w].Clip1		= w.Clip1 && w:Clip1( );
	ent.weps[w].Clip2		= w.Clip2 && w:Clip2( );
end

function ent.Think()
	ent.plys = {};
	ent.npcs = {};
	local tbl = aimnpc:GetInt() == 1 && G.ents.GetAll() || G.player.GetAll();
	for k, v in G.pairs( tbl ) do
		ent.PlayerFilter( v );
		ent.NPCFilter( v );
	end
end

local aim = {};
 
local info = {
        lastwep = nil;
        nextshot = 0.00;
}
 
aim.info = {
        hastarget = false,
        target = nil,
        lastwep = nil,
        angle = Angle( 0, 0, 0 ),
        silent = Vector( 0, 0, 0 ),
};
 
aim.hl2 = {
        "weapon_pistol",
        "weapon_357",
        "weapon_smg1",
        "weapon_ar2",
        "weapon_shotgun",
        "weapon_crossbow",
        "weapon_frag",
        "weapon_rpg",
};
 
local aiming = false;
 
// Return current target
function aim:GetTarget()
        return aim.info.target;
end
 
// HL2 weapon norecoil
function aim:HL2PunchFix( ply, ucmd )
        local punch = ucmd:GetViewAngles() - ply:GetPunchAngle();
       
        punch = aim:NormalizeAngle( punch );
       
        ucmd:SetViewAngles( punch );
end
 
// Clamp angles if invalid
function aim:NormalizeAngle( angle )
        angle.p = G.math.NormalizeAngle( angle.p );
        angle.y = G.math.NormalizeAngle( angle.y );
        angle.r = 0;
        return angle;
end
 
// Correct movement to view angles (Credits to RabidToaster)
function aim:CorrectMovement( ucmd, angle )
        local m = G.Vector( ucmd:GetForwardMove(), ucmd:GetSideMove(), 0 );
        local n = ( m ):GetNormal();
        local a = ( ( m ):Angle() + ( angle - aim.info.angle ) ):Forward() * ( m ):Length();
       
        ucmd:SetForwardMove( a.x );
        ucmd:SetSideMove( a.y );
end

local function SubtractVectors( vec_1, vec_2 )
	local ret = Vector( 0, 0, 0 ) 
	ret.x = vec_1.x - vec_2.x
	ret.y = vec_1.y - vec_2.y
	ret.z = vec_1.z - vec_2.z
	return ret;
end

local function NormalizeVector( vec )
	local ret = Vector( 0, 0, 0 );
	local length = vec:Length();
	ret.x = vec.x / length;
	ret.y = vec.y / length;
	ret.z = vec.z / length;
	return ret;
end
 

function aim:PredictPos(  ent, vec ) //eat this speedhackers
		plFrames = RealFrameTime() / 66 || 0
		tarFrames = RealFrameTime() / 25 || 0
		plVelocity = LocalPlayer():GetVelocity()  || Vector( 0, 0, 0 )


		tarVelocity = ent:GetVelocity()  || Vector( 0, 0, 0 )


		return( vec + ( tarVelocity * ( tarFrames ) - ( plVelocity * ( plFrames ) ) ) )  || Vector( 0, 0, 0 )

end
 
function aim:FindTarget()
        local ply = G.LocalPlayer();
       
        local tar = { 0, 0 };
        local ang, pos = ply:GetAimVector(), ply:EyePos();
       
        aim.info.target = nil;
       
        for entity, info in G.pairs( ent:GetEnts() ) do
                if( !entity || entity && G.IsValid( entity ) == false ) then
                        ent:SetInfo( entity, nil, nil );
                        continue;
                end
                if( info.ValidTarget && info.IsVisible && info.IsFriend == false && info.IsDormant == false ) then
                        local tarPos = entity:EyePos();
                        local difr = NormalizeVector( tarPos - pos );
						
                        difr = ( difr - ang );
                        difr = difr:Length();
                        difr = G.math.abs( difr );
                       
                        if( difr < tar[2] || tar[1] == 0 ) then
                                tar = { entity, difr };
                        end
                end
        end
        return tar[1] || 0;
end

local OLD_ANGS = Angle( 0, 0, 0 );
local calcviewang = nil;

local lastshoot = 0;

CreateClientConVar( "xhit_aim_autoshootdelay", 0.05, false, false );

function aim:autoshoot(ucmd)
	if( SysTime() > lastshoot ) then
		lastshoot = SysTime() + GetConVarNumber( "xhit_aim_autoshootdelay" );
		ucmd:SetButtons( bit.bor( ucmd:GetButtons( ), IN_ATTACK ) );
	end
end
 
function aim:Aimbot( ucmd )
        local ply = G.LocalPlayer();
       
		OLD_ANGS = OLD_ANGS + Angle( ucmd:GetMouseY() * GetConVarNumber( "m_pitch" ), ucmd:GetMouseX() * -GetConVarNumber("m_yaw"), 0 ) || Angle( 0, 0, 0 )

		OLD_ANGS = aim:NormalizeAngle( OLD_ANGS );

		OLD_ANGS.y = math.NormalizeAngle( OLD_ANGS.y + ( ucmd:GetMouseX() * -0.022 * 1 ) )
		OLD_ANGS.p = math.Clamp( OLD_ANGS.p + ( ucmd:GetMouseY() * 0.022 * 1 ), -89, 90 )

		calcviewang = OLD_ANGS;
	   
	   ucmd:SetViewAngles( OLD_ANGS );
	   
	   if( ucmd:KeyDown( IN_ATTACK ) ) then
		   local fake_angs = PredictSpread( ucmd, OLD_ANGS );
		   
		   fake_angs = aim:NormalizeAngle( fake_angs );
		   
		   ucmd:SetViewAngles( fake_angs );
		  end
	   
        if( !ply ) then
                return;
        end
       
        local w = ply:GetActiveWeapon( );
       
        if( w == nil || w && G.IsValid( w ) == false ) then
                return;
        end
       
        if( aim.hl2[w:GetClass( )] ) then
                aim:HL2PunchFix( ply, ucmd );
        end
       
        if( aiming == false ) then
                return;
        end
		
		if( aim.info.target == nil ) then
				return;
		end
	   
		if( G.type( aim.info.target ) == "number" ) then
				return;
		end
			
			
		if( aim.info.target:IsPlayer() ) then
			if aim.info.target:GetColor().a == 200  then return false end
			if !shitff:GetBool() and aim.info.target:GetFriendStatus() == "friend"  then
			//continue
			return 
			end
			if aim.info.target:SteamID() == shitstid:GetString() then //continue
			return 
			end
			if table.HasValue(stids,aim.info.target) and xhitfff:GetBool() then 
			return
			end
			
			if not aimteam:GetBool() and aim.info.target:Team() == LocalPlayer():Team() then
			return
			end
		end
	   
		local angles = ent:GetHeadPos2( aim.info.target ); //1
		//angles = aim:PredictPos( aim.info.target, angles );
		//angles = self:PredictTargetPosition( aim.info.target, angles );
	   angles = aim:PredictPos( aim.info.target, angles );
		angles = ( angles - ply:GetShootPos( ) ):Angle();
		
		angles = aim:NormalizeAngle( angles );
		
		 OLD_ANGS = angles;
		 
		angles = PredictSpread( ucmd, angles );
	   
		angles = aim:NormalizeAngle( angles );
	   
		ucmd:SetViewAngles( angles );
		//RunConsoleCommand('-speed')
		//RunConsoleCommand('-noob1')
		aim:autoshoot(ucmd)
		//ucmd:SetButtons( bit.bor( ucmd:GetButtons( ), IN_ATTACK ) );
end
 
function aim.CreateMove( ucmd )
        aim:Aimbot( ucmd );
end
 
function aim.Think()
        if( aiming == true ) then
                aim.info.target = aim:FindTarget();
        else
                aim.info.target = nil;
        end
end

local function novisrecoil(ply,origin,angles,fov)
	if novisrec:GetBool() then
	local view = {} 
	view.origin = origin;
	view.angles = calcviewang
	view.fov = GetConVarNumber('fov_desired')
		
	return view
	end
	return GAMEMODE:CalcView(ply,origin,angles,fov);
end

hook.Add('CalcView','novisrecoil', novisrecoil)

CreateClientConVar( "xhit_aim_antiaim", 0, false, false );

hook.Add( "CreateMove", "Niggers", function( ucmd )
	aim.CreateMove( ucmd );
	local ply = LocalPlayer()
	if( GetConVarNumber( "xhit_aim_antiaim" ) == 1 &&
		ply:Alive() ) then
		
		local angle = Angle( 0, 0, 0 );
		local vecViewAngles = ucmd:GetViewAngles();
		local flDiff = -90 - vecViewAngles.p;
		
		if( ucmd:KeyDown( IN_ATTACK ) ) then
			angle.p = ( vecViewAngles.p + ( flDiff * 2 ) );
		else
			angle.p = -181;
		end
		
		angle.y = vecViewAngles.y + 180;
		angle.r = 0;
		
		ucmd:SetViewAngles( angle );
		
		local m = Vector( ucmd:GetForwardMove(), ucmd:GetSideMove(), 0 );
		local n = ( m ):GetNormal();
		local a = ( ( m ):Angle() + ( angle - OLD_ANGS ) ):Forward() * ( m ):Length();
		
		ucmd:SetForwardMove( a.x );
		ucmd:SetSideMove( -a.y );
	end
end )

hook.Add( "Think", "Niggas", function()	
	ent.Think();
	aim.Think();
end )
 
concommand.Add( "+aimbot", function()
	aiming = true;
end )

concommand.Add( "-aimbot", function()
	aiming = false;
end )

_R = debug.getregistry()

local ban = _R.Player.SetViewAngles

_R.Player.SetEyeAngles = function( self, a )
--print(debug.getinfo(2).short_src)
local dbgsrc = debug.getinfo( 3, 'S' )[ 'short_src' ]
if dbgsrc:lower():find( 'weapon' ) then
--if debug.getinfo(2).short_src:lower():find('weapon') then
return
end
return ban( self, a )
end 
_R = debug.getregistry()

