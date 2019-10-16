// Herpes V3

// jewish bullshit hack noob hlh copypastens rip gd thread stealer 1992

// do something stupid
local ___h = nil;
if( _G['HERPES'] ) then
	___h = table.Copy( _G['HERPES'] );
end

// Some tables and copies
local HERPES 		= {};
HERPES['detours'] 	= {};
HERPES['hooks']		= {};
HERPES['meta'] 		= {};
HERPES['setting']	= {};
HERPES['key']		= {};

local ___g = table.Copy( _G );

// do it all over again
//include( 'includes/init.lua' )

// Some detourz
function HERPES:Detour( old, new )
	HERPES['detours'][new] = old;
	return new;
end

local oldPrint = print;

local __lua = {};
local bModuleLoaded = false;

_G.require = HERPES:Detour( _G.require, function( binary )
	if( ( binary:lower() == "herpes" ) && !bModuleLoaded ) then
		local ac_lua = nil;
		local c_lua = nil;
		
		if( _lua ) then
			ac_lua = _lua;
		end
		
		HERPES.detours[_G.require]( binary );
		
		c_lua = _lua;
		
		_lua = nil;
		__lua = c_lua;
		
		if( ac_lua ) then
			_lua = ac_lua;
		end
		
		bModuleLoaded = true;
		return true;
	elseif( ( binary:lower() == "herpes" ) && bModuleLoaded ) then
		oldPrint( "Attempted to load gmcl_herpes.dll again..." );
		return false;
	end
	return HERPES.detours[_G.require]( binary );
end )

// local copies = larger phallus
local __i 		= include;
local __r 		= require;
local __t		= table;
local __s		= surface;
local __d		= debug;
local __tm 		= team;
local __f		= file;
local __ti		= timer;
local __str		= string;
local __dr		= draw;
local __in		= input;
local __m		= math;
local __u 		= util;
local __c		= cam;
local __re		= render;
local __v		= vgui;

// key binding and hook locking
local __lock 	= false;
HERPES['__aim'] = false;
HERPES['__tar'] = nil;
HERPES['__menu'] = false;
HERPES['__ang'] = Angle( 0, 0, 0 );

// colors
local COLORS = {
	Red 	= Color( 255, 0, 0, 255 ),
	Green 	= Color( 0, 255, 0, 255 ),
	Blue 	= Color( 0, 0, 255, 255 ),
	White 	= Color( 255, 255, 255, 255 ),
	Black 	= Color( 0, 0, 0, 255 ),
};

__r( 'herpes' ); //0x02 0x06 0xA6 0xCEC2DAD9 0xCFD80000 (hashed)

local plInfo = {};
local ply = nil;

// copy globals again (???)
local copy, c = __t.Copy( _G ), {};

// Copy meta table shit
function HERPES:CopyMeta( meta )
	if( HERPES['meta'][meta] ) then return HERPES['meta'][meta] end
	HERPES['meta'][meta] = __t.Copy( _R[meta] );
	return HERPES['meta'][meta];
end

function HERPES:Execute()
	c.Player 	= HERPES:CopyMeta( "Player" );
	c.Entity 	= HERPES:CopyMeta( "Entity" );
	c.CUserCmd 	= HERPES:CopyMeta( "CUserCmd" );
	c.Angle 	= HERPES:CopyMeta( "Angle" );
	c.Vector 	= HERPES:CopyMeta( "Vector" );
	
	// and what is this for again?
	//for k, v in pairs( _G ) do
	//	_G[v] = ___g[v];
	//end
	
	local function GetLocal()
		if( copy['LocalPlayer']():IsValid() ) then
			ply = copy['LocalPlayer']();
			return;
		end
		if( !ply ) then
			__ti.Simple( 0.01, GetLocal );
		end
	end
	GetLocal();
end

// Hooking
hook.Call = HERPES:Detour( hook.Call, function( name, gm, ... )
	local args = {...}
	for k, e in copy['pairs']( HERPES['hooks'] ) do
		if( ( __lock == false ) && k == name ) then
			if( args == nil ) then
				ret = e()
			else
				ret = e( ... )
			end
			if( ret != nil ) then return ret end
		end
	end
	return copy['hook']['Call']( name, gm, ... );
end )

function HERPES:AddHook( name, func )
	HERPES['hooks'][name] = func;
	return;
end

// Setting saving
local function WriteFile()
	for k, v in copy['pairs']( HERPES['setting'] ) do
		str = __str.format( "%s=%s\n", k, v );
	end
	__f.Write( "gmod_cvars", str );
end

local ___s = {}
function HERPES:Setting( name, value, min, max, help )
	HERPES['setting'][name] = { value, min, max, help };
	
	/*
	if( __f.Exists( "gmod_cvars" ) ) then
		local c, str = __str.Explode( "\n", __f.Read( "gmod_cvars" ) ), "";
		for k, v in copy['pairs']( c ) do
			c = __str.Explode( "=", v );
			HERPES['setting'][c[1] || "NULL"] = c[2] || 0;
		end
	end
	
	// like using addchangecallback but not as gay
	local function __cvar()
		local _v, _s = HERPES['setting'][name], ___s[name];
		if( !_s || _s != _v ) then
			___s[name] = HERPES['setting'][name];
			WriteFile();
		end
		__ti.Simple( 0.1, __cvar );
	end
	__cvar();
	*/
end

// KeyEvent
local __kp = {};
function HERPES:AssignKey( key, func )
	HERPES['key'][key] = func;
	return;
end

function HERPES.KeyEvent()
	for k, v in copy['pairs']( HERPES['key'] ) do
		if( __in.IsKeyDown( k ) ) then
			HERPES[v] = true;
		else
			HERPES[v] = false;
		end
	end
	HERPES.Console();
end

HERPES:AssignKey( KEY_INSERT, "__menu" );
HERPES:AssignKey( KEY_F, "__aim" );

HERPES:Execute();

// graydon legit config BEGIN
// name, value, min, max, desc
HERPES:Setting( "aim_autoshoot", 1, 0, 1, "Shoot when locked target" );
HERPES:Setting( "aim_autowall", 1, 0, 1, "Detect penetrable walls (madcow only)" );
HERPES:Setting( "aim_team", 1, 0, 1, "Aim at team members" );
HERPES:Setting( "aim_steam", 0, 0, 1, "Aim at steam friend" );
HERPES:Setting( "esp_enable", 1, 0, 1, "Turn ESP on" );
HERPES:Setting( "esp_wallhack", 1, 0, 1, "Turn wallhack on" );
HERPES:Setting( "esp_xray", 0, 0, 1, "Make all props transparent" );
HERPES:Setting( "esp_barrel", 0, 0, 1, "Turn barrelhack on" );
HERPES:Setting( "esp_lights", 0, 0, 1, "Dynamic lights below players" );
HERPES:Setting( "misc_antiaim", 0, 0, 1, "Avoid other aimbots" );
HERPES:Setting( "misc_class", 0, 0, 1, "Show classname of view entity" );

local bones = {}
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

local function GetPosType( e, pos )
	if( copy['type']( pos ) == "string" ) then
		return c.Entity['GetBonePosition']( e, c.Entity['LookupBone']( e, pos ) );
	elseif( copy['type']( pos ) == "Vector" ) then
		return c.Entity['LocalToWorld']( e, c.Entity['OBBCenter']( e ) + pos );
	end
	return ( c.Entity['LocalToWorld']( e, pos ) )
end

/*
local vec_x = CreateClientConVar( "__vec_x", "0", false, false );
local vec_y = CreateClientConVar( "__vec_y", "0", false, false );
local vec_z = CreateClientConVar( "__vec_z", "0", false, false );
*/

local eye_model_fix = {
	["models/player/phoenix.mdl"] 				= Vector( -3, 0, 4 ),
	["models/player/arctic.mdl"] 				= Vector( -3, 0, 1 ),
	["models/player/guerilla.mdl"] 				= Vector( -3, 0, 5 ),
	["models/player/classic.mdl"] 				= Vector( 6, 0, 0 ),
	["models/player/urban.mbl"]					= Vector( 0, -2, 3 ),
	["models/player/gasmask.mdl"]				= Vector( 0, -2, 3 ),
	["models/player/riot.mdl"]					= Vector( 0, -2, 3 ),
	["models/player/swat.mdl"]					= Vector( 0, -2, 3 ),
	["models/player/leet.mdl"]					= Vector( 0, -2, 3 ),
	["models/player/zombie_soldier.mdl"] 		= Vector( 0, -4, 0 ),
	["models/player/combine_super_soldier.mdl"]	= Vector( 0, -4, 1 ),
	["models/player/charple01.mdl"]				= Vector( 3, 2, 0 ),
	["models/breen.mdl"] 						= Vector( 0, -2, 0 ),
	["models/player/charple01.mdl"]				= Vector( 0, -3, 0 ),
	["models/player/gman_high.mdl"]				= Vector( 0, -3, 0 ),
	["models/player/dod_american.mdl"] 			= Vector( -2, 0, 0 ),
	["models/alyx.mdl"]							= Vector( 0, -2, 0 ),
	["models/humans/group03/male_03.mdl"] 		= Vector( 0, 3, 0 ),
	["models/humans/group01/male_03.mdl"] 		= Vector( -3, 0, 0 ),
};

local attachments = { 
	"eyes",
	"head",
	"forward",
};

function HERPES:HeadPos( e )
	for k, v in copy['pairs']( attachments ) do
		local att = c.Entity['GetAttachment']( e, c.Entity['LookupAttachment']( e, v ) );
		if( att ) then
			//print( e:GetModel(), k, v[1].x, v[1].y, v[1].z )
			return att['Pos'] + ( v == "eyes" && eye_model_fix[e:GetModel()] || Vector( 0, 0, 0 ) );
		end
	end
	
	local model = c.Entity['GetModel']( e );
	if( bones[model] ) then
		return GetPosType( e, bones[model] );
	end
	
	return GetPosType( e, "ValveBiped.Bip01_Head1" );
end

// HUDPaint

// XRay Hack
local props = {
	"prop_physics",
	"prop_door_rotating",
	"func_breakable_surf",
	"func_door_rotating",
	"func_door",
};

local xrayents = {};

local function xray()
	if( copy['tonumber']( HERPES['setting']['esp_xray'][1] ) == 1 ) then
		for k, v in copy.pairs( props ) do
			local _ent = ents.FindByClass( v );
			if( _ent ) then
				for index, ent in copy.pairs( _ent ) do
					ent:SetColor( 255, 255, 255, 170 );
					xrayents[ent] = index;
				end
			end
		end
	else
		if( xrayents ) then
			for k, v in copy.pairs( xrayents ) do
				if( ValidEntity( k ) ) then
					k:SetColor( 255, 255, 255, 255 );
				end
				xrayents[k] = nil;
			end
		end
	end
end

// pastebin.com/cZCHYrKv I DID IT BEFORE HADES RELEASE SEE!!!
// also ignore my spelling errors im not the best germany
local skeleton = {
	{ "ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1" },
	{ "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine4" },
	{ "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine2" },
	{ "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1" },
	{ "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine" },
	{ "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Pelvis" },
	{ "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_L_UpperArm" },
	{ "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm" },
	{ "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand" },
	{ "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_R_UpperArm" },
	{ "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm" },
	{ "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand" },
	{ "ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_L_Thigh" },
	{ "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf" },
	{ "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Foot" },
	{ "ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_L_Toe0" },
	{ "ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_R_Thigh" },
	{ "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf" },
	{ "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Foot" },
	{ "ValveBiped.Bip01_R_Foot", "ValveBiped.Bip01_R_Toe0" },
}

local function drawSkeleton( e )
	if ( c.Entity['IsPlayer']( e ) ) then return end
	
	for k, v in pairs( skeleton ) do
		local spos = c.Vector['ToScreen']( c.Entity['GetBonePosition']( e, c.Entity['LookupBone']( e, v[1] ) ) );
		local epos = c.Vector['ToScreen']( c.Entity['GetBonePosition']( e, c.Entity['LookupBone']( e, v[2] ) ) );
		
		__s.SetDrawColor( 255, 255, 255, 255 )
		__s.DrawLine( spos.x, spos.y, epos.x, epos.y )
	end
end

HERPES.laser = {};

function HERPES:CreateLaserObject( name )
	if( HERPES.laser[name:lower()] ) then return HERPES.laser[name:lower()] end
	
	local color = copy.Color( 0, 255, 0, 255 );
	local info = {
		["$basetexture"]	= "sprites/laser",
		["$additive"]		= 1,
		["$translucent"]	= 1,
		["$vertexcolor"]	= 1,
		["$color"]			= __str.format( "{%c %c %c}", color.r, color.g, color.b ),
	}
	
	local mat = copy.CreateMaterial( __str.format( "_%s_%s_%s", "HERPES", "laser", name:lower() ), "UnlitGeneric", info )
	HERPES.laser[name:lower()] = mat
	return mat
end

function HERPES.HUDPaint()
	xray();
	
	if( copy['tonumber']( HERPES['setting']['esp_enable'][1] ) == 0 ) then
		return;
	end
	
	local x, y, color
	local mon, nom;
	local h, w;
	local bot, top;
	local pos, hitPos;
	local mat;
	
	for k, v in copy['pairs']( copy['player']['GetAll']() ) do
		if( v && ( v == ply ||
			!c.Player['Alive']( v ) ||
			c.Entity['GetMoveType']( v ) == MOVETYPE_NONE ) ) then
			continue;
		end
		
		// directly from s0beits base hook (connecting headpos to abs orgin isn't the best method for boxens esp) 
		nom = c.Entity['GetPos']( v );
		mon = nom + copy['Vector']( 0, 0, 70 );
		
		bot = c.Vector['ToScreen']( nom );
		top = c.Vector['ToScreen']( mon );
		
		if( bot['visible'] && top['visible'] ) then
			h = ( bot['y'] - top['y'] );
			w = h / 6;
			
			//drawSkeleton( v ); // SHIT
			
			__s.SetDrawColor( COLORS.Green ); 
			__s.DrawOutlinedRect( top['x'] - w, top['y'], w * 2, ( bot.y - top.y ) );
			
			x 		= ( top['x'] + w ) + 1;
			y 		= top['y'] - 2;
			
			color 	= __tm.GetColor( c.Player['Team']( v ) );
			color.a = 255;
			
			if( plInfo[v] && plInfo[v].IsSpawnProtected == true ) then
				__dr.SimpleText( "SPAWN PROTECTED", "DefaultSmallDropShadow", x, y + 24, COLORS.Red, 0, 0 );
			end
			
			__dr.SimpleText( c.Player['Nick']( v ), "DefaultSmallDropShadow", x, y, color, 0, 0 );
			__dr.SimpleText( __str.format( "Hp:%i", c.Entity['Health']( v ) ), "DefaultSmallDropShadow", x, y + 12, color, 0, 0 );
			
			if( copy['tonumber']( HERPES['setting']['esp_barrel'][1] ) == 1 ) then
				mat = HERPES:CreateLaserObject( "$$green" );
				pos, hitPos = HERPES:HeadPos( v ), c.Player['GetEyeTrace']( v ).HitPos;
				__c.Start3D( copy.EyePos(), copy.EyeAngles() )
					__re.SetMaterial( mat );
					__re.DrawBeam( pos, hitPos, 5, 0, 0, COLORS.Green );
				__c.End3D()
			end
		end
	end
	
	if( copy['tonumber']( HERPES['setting']['misc_class'][1] ) == 1 ) then
		local trc = ply:GetEyeTrace();
		if( trc && trc.Entity && ValidEntity( trc.Entity ) ) then
			local ent = trc.Entity;
			local pos = c.Vector['ToScreen']( c.Entity['LocalToWorld']( ent, c.Entity['OBBCenter']( ent ) ) );
			
			local str = c.Entity['GetClass']( ent );
			if( ent.Health && ( ent:Health() || 0 ) != 0 ) then
				/*local percent_hp = ent:Health() / ( plInfo[ent].SpawnHealth || 100 );
				percent_hp = math.Round( percent_hp * 100 );*/
				local percent_hp = ent:Health();
				str = __str.format( "%s (%i)", str, percent_hp );
			end
			__dr.SimpleText( str, "TabLarge", pos.x, pos.y, COLORS.Green, 1, 1 );
		end
	end
end
HERPES:AddHook( "HUDPaint", HERPES.HUDPaint );

// XQZ
function HERPES.RenderScreenspaceEffects()
	if( copy['tonumber']( HERPES['setting']['esp_wallhack'][1] ) == 0 ) then
		return;
	end
	
	__c.Start3D( copy['EyePos'](), copy['EyeAngles']() )
	for k, v in copy['pairs']( copy['player']['GetAll']() ) do
		if( v && ( v == ply ||
			!c.Player['Alive']( v ) ||
			c.Entity['GetMoveType']( v ) == MOVETYPE_NONE ) ) then
			continue;
		end
		
		__c.IgnoreZ( true );
			__re.SuppressEngineLighting( true );
			c.Entity['DrawModel']( v );
		__c.IgnoreZ( false );
		__re.SuppressEngineLighting( false );
	end
	__c.End3D();
end
HERPES:AddHook( "RenderScreenspaceEffects", HERPES.RenderScreenspaceEffects );

// Nospread
HERPES.bullet = {}

local function WeaponVector( value, typ, vec )
	if ( !vec ) then return copy["tonumber"]( value ) end
	local s = ( copy["tonumber"]( value ) )
	if ( typ == true ) then
		s = ( copy["tonumber"]( -value ) )
	end
	return copy["Vector"]( s, s, s )
end

local CONE = {}

CONE.weapon = {}
CONE.weapon["weapon_pistol"]			= WeaponVector( 0.0100, true, true )	// HL2 Pistol
CONE.weapon["weapon_smg1"]				= WeaponVector( 0.04362, true, true )	// HL2 SMG1
CONE.weapon["weapon_ar2"]				= WeaponVector( 0.02618, true, true )	// HL2 AR2
CONE.weapon["weapon_shotgun"]			= WeaponVector( 0.08716, true, true )	// HL2 SHOTGUN
CONE.weapon["weapon_zs_zombie"]			= WeaponVector( 0.0, true, true )		// REGULAR ZOMBIE HAND
CONE.weapon["weapon_zs_fastzombie"]		= WeaponVector( 0.0, true, true )		// FAST ZOMBIE HAND

// noPE showed me this (before turbobot release)
_R.Entity.FireBullets = HERPES:Detour( _R.Entity.FireBullets, function( e, bullet )
	local w = c.Player["GetActiveWeapon"]( ply );
	HERPES.bullet[c.Entity["GetClass"]( w )] = bullet.Spread;
	return HERPES.detours[ _R.Entity.FireBullets ]( e, bullet );
end )

// data method (for gamemodes that use cones that change when jumping, walking...)
local DATA = {
	["gta_base"] = function( cone )
		local pl = copy['LocalPlayer']();
		local VELOCITY = c.Vector["Length"]( c.Entity["GetVelocity"]( pl ) );
		if( c.Player["KeyDown"]( pl, IN_SPEED ) && VELOCITY != 0 ) then
			return cone * 2.5;
		elseif( c.Player["KeyDown"]( pl, IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT ) ) then
			if( c.Player["KeyDown"]( pl, IN_DUCK | IN_WALK ) ) then
				cone = math.Clamp( cone * 1.5, 0, 10 );
			end
			return cone * 2.0;
		elseif( c.Player["KeyDown"]( pl, IN_DUCK ) || ( c.Player["KeyDown"]( pl, IN_WALK ) && VELOCITY != 0 ) ) then
			return math.Clamp( cone / 1.2, 0, 10 );
		end
		return cone || 0;
	end,
	["sniper_base"] = function( cone )
		local pl = copy['LocalPlayer']();
		if( c.Player["KeyDown"]( pl, IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT ) ) then
			return cone * 2.5
		elseif( c.Player["KeyDown"]( pl, IN_DUCK | IN_WALK ) ) then
			return math.Clamp( cone / 2.5, 0, 10 )
		end
		return cone || 0;
	end,
	["firearm_base"] = function( cone )
		local pl = copy['LocalPlayer']();
		if( c.Player["KeyDown"]( pl, IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT ) ) then
			return cone * 1.5
		elseif( c.Player["KeyDown"]( pl, IN_DUCK | IN_WALK ) ) then
			return math.Clamp( cone / 2, 0, 10 )
		end
		return cone || 0;
	end,
	["as_swep_base"] = function( cone )
		local pl = copy['LocalPlayer']();
		local w = c.Player["GetActiveWeapon"]( pl );
		if( w ) then
			return cone / ( w:GetAccuracyModifier() );
		end
		return cone || 0;
	end,
}

function HERPES:PredictSpread( ucmd, angle )
	local w = c.Player["GetActiveWeapon"]( ply );
	if ( w && c.Entity["IsValid"]( w ) ) then
		local class = c.Entity["GetClass"]( w );
		if ( !CONE.weapon[class] ) then
			if ( HERPES.bullet[class] ) then
				local ang = c.Angle["Forward"]( angle ) || c.Vector["Forward"]( c.Vector["Angle"]( c.Player["GetAimVector"] ) );
				local conevec = Vector( 0, 0, 0 ) - HERPES.bullet[class] || Vector( 0, 0, 0 )
				return c.Vector["Angle"]( __lua.Nospread( ucmd, ang, conevec ) )
			end
		else
			local ang = c.Angle["Forward"]( angle ) || c.Vector["Forward"]( c.Vector["Angle"]( c.Player["GetAimVector"] ) );
			local conevec = CONE.weapon[class]
			
			local ret = c.Vector["Angle"]( __lua.Nospread( ucmd, ang, conevec ) )
			return ret - c.Player['GetPunchAngle']( ply );
		end
	end
	return angle
end

// Aimbot

// Check if player is dead or alive
local function CheckLifeState( pl )
	if( !pl:IsPlayer() ) then
		
		local bCreated = false;
		if( !plInfo[pl] ) then
			plInfo[pl] = {};
			
			plInfo[pl].SpawnHealth 		= 0.0;
			
			// Entity has just passed this table, so it was just spawned.
			bCreated = true;
		end
		
		if( bCreated ) then
			plInfo[pl].SpawnHealth = pl.Health && pl:Health() || 0;
		end
		
		return;
	end
	
	// Init varaibles if they didn't exist before
	if( !plInfo[pl] ) then
		plInfo[pl] = {};
		
		// Varaibles
		plInfo[pl].IsAlive 				= false;
		plInfo[pl].DiedThisFrame 		= false;
		plInfo[pl].SpawnedThisFrame 	= false;
		plInfo[pl].IsSpawnProtected		= false;
		
		plInfo[pl].SpawnHealth			= 0.0;
		
		plInfo[pl].LF = {}
		plInfo[pl].LF.IsAlive			= false;
	end
	
	// Restor these back to normal as they only are true for ONE frame
	plInfo[pl].DiedThisFrame 	= false;
	plInfo[pl].SpawnedThisFrame = false;
	
	// Normal check
	plInfo[pl].IsAlive = c.Player['Alive']( pl );
	
	// Player is DEAD and was ALIVE last frame.
	if( ( plInfo[pl].IsAlive == false ) && ( plInfo[pl].LF.IsAlive == true ) ) then
		plInfo[pl].DiedThisFrame = true;
	end
	
	// Player is ALIVE and was DEAD last frame.
	if( ( plInfo[pl].IsAlive == true ) && ( plInfo[pl].LF.IsAlive == false ) ) then
		plInfo[pl].SpawnedThisFrame = true;
		plInfo[pl].SpawnHealth = pl:Health() || 100;
	end
	
	// Check if the player has spawn protection
	if( plInfo[pl].SpawnedThisFrame && ( ( GAMEMODE.Name ):lower() ):find( "stronghold" ) ) then
		local bShouldProtect, spawners = true, copy.ents.FindByClass( "sent_spawnpoint" ) || nil;
		if( spawners ) then
			for m, n in copy.pairs( spawners ) do
				local entDist = c.Vector['Distance']( c.Entity['LocalToWorld']( n, c.Entity['OBBCenter']( n ) ), c.Entity['LocalToWorld']( pl, c.Entity['OBBCenter']( pl ) ) );
				if( entDist < 45 ) then
					bShouldProtect = false;
				end
			end
		end
		if( bShouldProtect ) then
			plInfo[pl].IsSpawnProtected = true;
			timer.Simple( 4, function()
				plInfo[pl].IsSpawnProtected = false;
			end )
		end
	end
	
	// Save data for this frame
	plInfo[pl].LF.IsAlive = c.Player['Alive']( pl );
end

// C0BRA's prediction (im really lazy atm)
HERPES.LastPositions = {}

local function GetPlayerPos( pl, def )
	local tbl = HERPES.LastPositions[pl] or {}
	
	tbl.pos = tbl.pos or def or c.Entity['GetPos']( pl )
	
	local realtime = copy.RealTime()
	if(tbl.rt != realtime) then
		tbl.rt = realtime
		tbl.pos = def or c.Entity['GetPos']( pl )
	end
	
	HERPES.LastPositions[pl] = tbl
	
	return tbl.pos
end

function HERPES:Prediction( e, pos )
	return pos + (
		( GetPlayerPos( e, pos) - pos )
		- ( c.Entity['GetVelocity']( ply ) / 45 )
	)
end

local BASE = {
	["weapon_mad_base"] = function( dist, dmg ) // madcow base
		local damageMultiplier = {
			[MAT_CONCRETE] = 0.3,
			[MAT_WOOD] = 0.8,
			[MAT_PLASTIC] = 0.8,
			[MAT_GLASS] = 0.8,
			[MAT_FLESH] = 0.9,
			[MAT_ALIENFLESH] = 0.9,
			[MAT_METAL] = 0,
			[MAT_SAND] = 0,
			["DEFAULT"] = 0.5
		};
		return damageMultiplier;
	end,
	
	["weapon_mad_base_sniper"] = function( dist, dmg ) // madcow base sniper
		local damageMultiplier = {
			[MAT_CONCRETE] = 0.3,
			[MAT_WOOD] = 0.8,
			[MAT_PLASTIC] = 0.8,
			[MAT_GLASS] = 0.8,
			[MAT_FLESH] = 0.9,
			[MAT_ALIENFLESH] = 0.9,
			[MAT_METAL] = 0,
			[MAT_SAND] = 0,
			["DEFAULT"] = 0.5
		};
		return damageMultiplier;
	end,
}

function HERPES:CanPenitrate( pLocal, vStart, vEnd ) // Madcow weapons
	if( copy.tonumber( HERPES['setting']['aim_autowall'][1] ) == 0 ) then
		return false;
	end
	local vecStart, vecEnd = vStart, vEnd;
	
	local w = c.Player["GetActiveWeapon"]( pLocal );
	if( !w ) then return false end
	
	if( !w['Base'] ) then return false end
	if( !BASE[w['Base']] ) then return false end
	
	local flDist 		= 0.0;
	local flDamage 		= ( w['Primary'] && w['Primary']['Damage'] || 0 );
	
	local flDamageMulti = BASE[w['Base']]( flDist, flDamage );
	
	return __lua.CanPenitrate( 4, vStart, vEnd, flDamage, flDamageMulti );
end

function HERPES:IsVisible( e )
	local pos = HERPES:HeadPos( e )
	pos = HERPES:Prediction( e, pos )
	
	local trace = { 
		start = c.Player['GetShootPos']( ply ), 
		endpos = pos, 
		filter = { ply, e }, 
		mask = MASK_SHOT
	}
	local tr = __u.TraceLine( trace );
	
	if( tr['Fraction'] == 1.0 ) then
		return true;
	end
	return HERPES:CanPenitrate( ply, trace.start, trace.endpos );
end

function HERPES:AquireTarget()
	if( pTar && pTar != nil && ( c.Player['Alive']( pTar ) &&
		c.Entity['GetMoveType']( pTar ) != MOVETYPE_OBSERVER && 
		c.Entity['GetMoveType']( pTar ) != MOVETYPE_NONE &&
		HERPES:IsVisible( pTar ) ) ) then
		return pTar;
	end
	
	local tar = { 0, 0 };
	local ang, pos = c.Player['GetAimVector']( ply ), c.Entity['EyePos']( ply );
	
	if( plInfo[ply] && plInfo[ply].IsSpawnProtected == true ) then
		return nil;
	end
	
	for k, v in copy['pairs']( copy['player']['GetAll']() ) do
		if( v && ( v == ply ||
			__lua.IsDormant( c.Entity["EntIndex"]( v ) ) ||
			!c.Player['Alive']( v ) ||
			c.Entity['GetMoveType']( v ) == MOVETYPE_OBSERVER || 
			c.Entity['GetMoveType']( v ) == MOVETYPE_NONE ||
			( ( copy['tonumber']( HERPES['setting']['aim_steam'][1] ) == 0 ) && c.Player['GetFriendStatus']( v ) == "friend" ) ||
			( ( copy['tonumber']( HERPES['setting']['aim_team'][1] ) == 0 ) && ( __tm.GetName( c.Player['Team']( ply ) ) == __tm.GetName( c.Player['Team']( v ) ) ) ) ||
			__tm.GetName( c.Player['Team']( v ) ):lower():find( "spec" ) ||
			!HERPES:IsVisible( v ) ) ) then
			continue;
		end
		
		if( plInfo[v] && plInfo[v].IsSpawnProtected == true && ( ( GAMEMODE.Name ):lower() ):find( "stronghold" ) ) then
			continue;
		end
		
		local tarPos = c.Entity['EyePos']( v )
		local difr = c.Vector['Normalize']( tarPos - pos );
		difr = difr - ang;
		difr = c.Vector["Length"]( difr );
		difr = __m.abs( difr );
		if( difr < tar[2] || tar[1] == 0 ) then
			tar = { v, difr };
		end
	end
	return tar[1] || nil;
end

local pTar = nil;
function HERPES.Think()
	for k, v in copy['pairs']( copy['player']['GetAll']() ) do
		if( v && copy.ValidEntity( v ) ) then
			CheckLifeState( v );
			
			if( !c.Entity['IsPlayer']( v ) ) then
				continue;
			end
			
			if( v && ( !c.Player['Alive']( v ) ||
				__lua.IsDormant( c.Entity["EntIndex"]( v ) ) ||
				c.Entity['GetMoveType']( v ) == MOVETYPE_NONE ) ) then
				continue;
			end
			
			if( copy.tonumber( HERPES['setting']['esp_lights'][1] ) == 1 ) then
				local light = copy.DynamicLight( c.Entity["EntIndex"]( v ) )
				if( light ) then
					light.Pos			= c.Entity['GetPos']( v ) + Vector( 0, 0, 50 );
					light.r 			= 255;
					light.g 			= 255;
					light.b 			= 255;
					light.Brightness 	= 1;
					light.Size 			= 400;
					light.Decay 		= 400 * 5;
					light.DieTime 		= copy.CurTime() + 1;
					light.Style 		= 0;
				end
			end
		end
	end
	
	if( HERPES['__aim'] ) then
		pTar = HERPES:AquireTarget();
	else
		pTar = nil;
	end
	HERPES.KeyEvent();
end

HERPES:AddHook( "Think", HERPES.Think );

function HERPES.OnToggled()
	if( !copy["ValidEntity"]( ply ) ) then return end
	HERPES['__ang'] = c.Entity["EyeAngles"]( ply )
end
//HERPES:AddHook( "OnToggled", HERPES.OnToggled )

local bInAttack = false;

function HERPES.CreateMove( ucmd )
	if( copy.tonumber( HERPES['setting']['misc_antiaim'][1] ) == 1 &&
		( c.CUserCmd['GetButtons']( ucmd ) & IN_ATTACK == 0 ) &&
		c.Player['Alive']( ply ) ) then
		
		local angle = copy.Angle(
			-181, 						// pitch
			HERPES['__ang'].y, 			// yaw
			0		 					// roll
		)
		
		c.CUserCmd['SetViewAngles']( ucmd, angle );
		
		local m = copy.Vector( c.CUserCmd['GetForwardMove']( ucmd ), c.CUserCmd['GetSideMove']( ucmd ), 0 );
		local n = c.Vector['GetNormal']( m );
		local a = c.Angle['Forward']( c.Vector['Angle']( m ) + ( angle - HERPES['__ang'] ) ) * c.Vector['Length']( m );
		
		c.CUserCmd['SetForwardMove']( ucmd, a.x )
		c.CUserCmd['SetSideMove']( ucmd, -a.y )
	end
	
	if( !HERPES['__aim'] ) then HERPES['__tar'] = nil return end
	local tar = pTar;
	
	HERPES['__tar'] = false;
	
	if( !tar ) then return; end
	if( tar == 0 ) then return; end
	
	HERPES['__tar'] = true;
	
	local head = HERPES:Prediction( tar, HERPES:HeadPos( tar ) );
	HERPES['__ang'] = c.Vector['Angle']( head - c.Player['GetShootPos']( ply ) );
	
	head = HERPES:PredictSpread( ucmd, HERPES['__ang'] )
	
	head['p'] = __m.NormalizeAngle( head['p'] );
	head['y'] = __m.NormalizeAngle( head['y'] );
	head['r'] = 0;
	
	c.Player['SetEyeAngles']( ply, head );
	c.CUserCmd['SetViewAngles']( ucmd, head );
	
	if( copy.tonumber( HERPES['setting']['aim_autoshoot'][1] ) == 1 && !bInAttack ) then
		bInAttack = true;
		__lua.RunCommand( "+attack" );
		//c.CUserCmd['SetButtons']( ucmd, c.CUserCmd['GetButtons']( ucmd ) | IN_ATTACK );
		local w = c.Player["GetActiveWeapon"]( ply );
		__ti.Simple( ( w && w.Primary ) && w.Primary.Delay || 0.05, function()
			__lua.RunCommand( "-attack" );
			bInAttack = false;
		end )
	end
end

HERPES:AddHook( "CreateMove", HERPES.CreateMove );

// Recoil
function HERPES.CalcView( ply, orig, ang, FOV )
	if( HERPES['__aim'] && HERPES['__tar'] == true ) then
		local view = GAMEMODE:CalcView( ply, orig, HERPES['__ang'], FOV ) || {}
			view.angles = HERPES['__ang']
			view.angles.r = 0
		return view
	end
	return GAMEMODE:CalcView( ply, orig, ang, FOV )
end
HERPES:AddHook( "CalcView", HERPES.CalcView );

// NoRecoil
_R.Player.SetEyeAngles = HERPES:Detour( _R.Player.SetEyeAngles, function( self, a )
	local src = __d.getinfo( 3, 'S' )[ 'short_src' ]
	if( ( src:lower() ):find( "weapon" ) && HERPES['__aim'] && HERPES['__tar'] == true ) then
		return;
	end
	return HERPES.detours[_R.Player.SetEyeAngles]( self, a );
end )

// Remove Effects
util.Effect = HERPES:Detour( util.Effect, function( effect, data, ... )
	if( effect == "effect_mad_shotgunsmoke" || 
		effect == "effect_mad_gunsmoke" ||
		effect == "effect_mad_shell_pistol" ||
		effect == "effect_mad_shell_rifle" ||
		effect == "effect_mad_shell_shotgun" ||
		effect == "effect_mad_firehit"
		) then
		return;
	end
	return HERPES.detours[ util.Effect ]( effect, data, ... )
end )

// dev console
local help = [[
	Herpes V3 Dev Console
	Press DELETE to close the console
	Commands:
	cvars - list all cvars
	clear - clear all content
	players - list all players
]]

local function IsAdmin( e )
	if( !( c.Player['IsSuperAdmin'] && c.Player['IsSuperAdmin']( e ) ) && c.Player['IsAdmin'] && c.Player['IsAdmin']( e ) ) then 
		return { true, "Admin" }
	elseif( c.Player['IsSuperAdmin'] && c.Player['IsSuperAdmin']( e ) ) then 
		return { true, "Super Admin" }
	elseif( e.EV_IsOwner || e.EV_IsSuperAdmin || e.EV_IsAdmin || e.EV_IsRespected ) then
		if e:EV_IsOwner() then
			return { true, "Owner" }
		elseif e:EV_IsSuperAdmin() then
			return { true, "Super Admin" }
		elseif e:EV_IsAdmin() then
			return { true, "Admin" }
		elseif e:EV_IsRespected() then
			return { true, "Respected" }
		end
	elseif( e.IsRespected && e:IsRespected() ) then
		return { true, "Respected" }
	end
	return { false, "Guest" }
end

local panel = nil;
local SPACE = " "

local function CreateObject( name, info, value, min, max )
	if( name == nil ||
		info == nil ||
		value == nil ||
		min == nil ||
		max == nil ) then
		return;
	end
	
	if( min == 0 && max == 1 ) then
		local checkbox = __v.Create( "DCheckBoxLabel" );
		checkbox:SetText( __str.format( "%s - %s", name, info ) );
		checkbox:SetValue( copy.tonumber( value ) == 1 && true || false );
		checkbox:SizeToContents();
		
		checkbox.curtime = 0
		checkbox.OnChange = function()
			if( checkbox.curtime < CurTime() ) then 
				checkbox.curtime = CurTime() + 0.1
				checkbox:SetValue( checkbox:GetChecked() && true || false )
				HERPES['setting'][name][1] = ( checkbox:GetChecked() && 1 || 0 );
			end
		end
		
		return checkbox;
	end
end

function HERPES.Console()
	if( !HERPES['__menu'] ) then
		return;
	end
	
	if( panel != nil ) then
		panel:SetVisible( true );
		return;
	end
	
	panel = __v.Create( "DFrame" );
	panel:SetPos( 10, 10 );
	panel:SetSize( 350, 450 );
	panel:SetTitle( "console" );
	panel:SetVisible( true );
	panel:SetDraggable( true );
	panel:ShowCloseButton( true );
	panel:MakePopup();
	
	panel.Close = function()
		panel:SetVisible( false );
	end
	
	local lists, _derma;
	local function __console()
		lists = __v.Create( "DPanelList" );
		lists:SetPos( 10, 30 );
		lists:SetParent( panel );
		lists:SetSize( 330, 380 );
		lists:EnableVerticalScrollbar( true );
		lists:SetPadding( 5 );
		lists.Paint = function()
			__s.SetDrawColor( 255, 255, 255, 255 );
			__s.DrawRect( 0, 0, lists:GetWide(), lists:GetTall() );
			
			__s.SetDrawColor( 0, 0, 0, 255 );
			__s.DrawOutlinedRect( 0, 0, lists:GetWide(), lists:GetTall() );
		end
	end
	__console()
	
	local function _________startup()
		local text = __str.Explode( "\n", help )
		for i = 1, __t.Count( text ) do
			local startup = __v.Create( "DLabel" )
			startup:SetMultiline( true )
			startup:SetTextColor( color_black )
			startup:SetSize( 200, 13 )
			startup:SetText( text[i] )
			lists:AddItem( startup )
		end
	end
	
	local function _________derma()
		_derma = __v.Create( "DPanelList" );
		_derma:SetPos( 10, 10 );
		_derma:SetParent( panel );
		_derma:SetSize( 310, 340 / 3 );
		_derma:EnableVerticalScrollbar( true );
		_derma:SetPadding( 5 );
		_derma.Paint = function()
			__s.SetDrawColor( 127, 127, 127, 255 );
			__s.DrawRect( 0, 0, _derma:GetWide(), _derma:GetTall() );
			
			__s.SetDrawColor( 0, 0, 0, 255 );
			__s.DrawOutlinedRect( 0, 0, _derma:GetWide(), _derma:GetTall() );
		end
		lists:AddItem( _derma )
	end
	
	local function _________buildderma()
		for k, v in copy['pairs']( HERPES['setting'] ) do
			local cbox = CreateObject( k, v[4], v[1], v[2], v[3] );
			_derma:AddItem( cbox );
		end
	end
	
	local function _________cvars()
		for k, v in copy['pairs']( HERPES['setting'] ) do
			local startup = __v.Create( "DLabel" )
			startup:SetMultiline( true )
			startup:SetTextColor( color_black )
			startup:SetSize( 200, 13 )
			startup:SetText( __str.format( "%s (%i) - %s (%i - %i)", k, v[1], v[4], v[2], v[3] ) )
			lists:AddItem( startup )
		end
	end
	
	local function ________printadmins()
		for k, v in copy.pairs( copy['player']['GetAll']() ) do
			if( copy.ValidEntity( v ) ) then
				local startup = __v.Create( "DLabel" )
				startup:SetMultiline( true )
				startup:SetTextColor( IsAdmin( v )[1] && copy.Color( 255, 0, 0, 255 ) || color_black )
				startup:SetSize( 200, 13 )
				startup:SetText( __str.format( "%s - %s", c.Player['Nick']( v ), IsAdmin( v )[2] ) )
				lists:AddItem( startup )
			end
		end
	end
	
	_________derma();
	_________buildderma();
	_________startup();
	
	local commandentry = __v.Create( "DTextEntry" )
	commandentry:SetParent( panel )
	commandentry:SetPos( 10, 420 )
	commandentry:SetSize( 250, 20 )
	
	local button = __v.Create( "DButton" )
	button:SetParent( panel )
	button:SetText( "Submit" )
	button:SetPos( 270, 420 )
	button:SetSize( 70, 20 )
	
	local function sayShit( what )
		commandentry:SetText( "" );
		
		local msg = __v.Create( "DLabel" )
		msg:SetMultiline( true )
		msg:SetTextColor( color_black )
		msg:SetSize( 200, 13 )
		msg:SetText( what )
		lists:AddItem( msg )
	end
	
	local function doEntry( name, value )
		commandentry:SetText( SPACE );
		
		sayShit( __str.format( "%s has changed to %i", name, value ) )
	end
	
	local function detectInput()
		if( !commandentry || commandentry:GetValue() == "" || commandentry:GetValue() == nil ) then
			sayShit( "Error - commandentry" );
			return;
		end
		
		local text = commandentry:GetValue();
		
		if( text == "cvars" ) then
			sayShit( "" );
			_________cvars();
			return;
		elseif( text == "clear" ) then
			sayShit( "" );
			lists:Clear( true );
			_derma:Clear( true );
			_________derma();
			_________buildderma();
			_________startup();
			return;
		elseif( text == "players" ) then
			sayShit( "" );
			________printadmins();
			return;
		end
		
		if( text ) then
			local bkn = __str.Explode( " ", text );
			if( HERPES['setting'][ bkn[1] ] && bkn[2] ) then
				local cvarOld = HERPES['setting'][ bkn[1] ];
				HERPES['setting'][ bkn[1] ] = { bkn[2], cvarOld[2], cvarOld[3], cvarOld[4] }
				
				doEntry( bkn[1], bkn[2] )
				return;
			end
			sayShit( "Error - Args" );
			return;
		end
		
		commandentry:SetText( "" );
		sayShit( "Error - text not valid" );
	end
	
	button.DoClick = function()
		detectInput();
	end
	
	button.Think = function()
		if( panel:IsVisible() ) then
			if( __in.IsKeyDown( KEY_ENTER ) ) then
				if( !commandentry || commandentry:GetValue() == "" || commandentry:GetValue() == nil ) then
					return;
				end
				detectInput();
			end
			if( __in.IsKeyDown( KEY_DELETE ) ) then
				panel:SetVisible( false );
			end
		end
	end
end

// Start new menu
local MENU = {};



















































//
