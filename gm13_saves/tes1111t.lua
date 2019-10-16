
local G = _G;

local ent = {};

ent.npcs = {};

ent.plys = {};
ent.npcs = {};
ent.weps = {};

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

function ent:IsValidTarget( pl )
	if( !pl ) then return false; end
	if( G.IsValid( pl ) == false ) then return false; end
	
	if( pl == ( G.LocalPlayer() ) ) then return false; end
	if( ent.plys[pl].Alive == false || pl:Health( ) <= 0 ) then return false; end
	if( pl:GetMoveType( ) == MOVETYPE_OBSERVER || pl:GetMoveType( ) == MOVETYPE_NONE ) then return false; end
	if( ( G.team.GetName( pl:Team( ) ):lower():find( "spectat" ) ) == true ) then return false; end
	return true;
end

local function GetPlayerPos( pl, def )
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
	if( att ) then
		return att.Pos;
	end
	
	local model = entity:GetModel( );
	if( bones[model] ) then
		return entity:GetBonePosition( entity:LookupBone( bones[model] ) );
	end
	
	return entity:GetBonePosition( entity:LookupBone( "ValveBiped.Bip01_Head1" ) );
end

function ent:IsVisible( entity, pos )
	pos = pos || ent:GetHeadPos( entity );
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
	elseif( ent.weps[ entity ] ) then
		ent.weps[ entity ][ info ] = value;
		return;
	end
	return nil;
end

function ent.PlayerFilter( pl )
	if( pl == nil ) then
		return NULL;
	end
	if( G.IsValid( pl ) == false ) then
		return NULL;
	end
	
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
	
	ent.plys[pl].HeadPos			= ent:GetHeadPos( pl );
	
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
	for k, v in G.pairs( G.player.GetAll() ) do
		ent.PlayerFilter( v );
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
	local ret = Vector( 0, 0, 0 );
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
 
// Lag and velocity prediction (Thanks ph0ne)
function aim:PredictPos( entity, vector )
        return vector;
end
 
function aim:FindTarget()
        local ply = G.LocalPlayer();
       
        local tar = { 0, 0 };
        local ang, pos = ply:GetAimVector(), ply:EyePos();
       
        aim.info.target = nil;
       
        for entity, info in G.pairs( ent:GetPlayers() ) do
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
 
function aim:Aimbot( ucmd )
        local ply = G.LocalPlayer();
       
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
	   
		local angles = ent:GetHeadPos( aim.info.target );
		angles = aim:PredictPos( aim.info.target, angles );
	   
		angles = ( angles - ply:GetShootPos( ) ):Angle();
	   
		angles = aim:NormalizeAngle( angles );
	   
		ucmd:SetViewAngles( angles );
		ucmd:SetButtons( bit.bor( ucmd:GetButtons( ), IN_ATTACK ) );
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

hook.Add( "CreateMove", "Niggers", function( ucmd )
	aim.CreateMove( ucmd );
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