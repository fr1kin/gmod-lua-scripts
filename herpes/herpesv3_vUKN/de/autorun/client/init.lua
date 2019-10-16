/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: name it
Purpose: fyak you lua
------------------------------------------------------------*/

local ___h = {};
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
include( 'includes/init.lua' )
include( 'includes/extensions/table.lua' )

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
local __u 		= util

local __lock 	= false;
HERPES['__aim'] = false;
HERPES['__menu'] = false;
HERPES['__ang'] = Angle( 0, 0, 0 );

__r( 'herpes' );

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
	
	for k, v in pairs( _G ) do
		_G[v] = ___g[v];
	end
end

// Some detour
function HERPES:Detour( old, new )
	HERPES['detours'][new] = old;
	return new;
end

// Hooking
function hook.Call( name, gm, ... )
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
end

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
	HERPES['setting'][name] = value;
	if( __f.Exists( "gmod_cvars" ) ) then
		local c, str = __str.Explode( "\n", __f.Read( "gmod_cvars" ) ), "";
		for k, v in copy['pairs']( c ) do
			c = __str.Explode( "=", v );
			HERPES['setting'][c[1] || "NULL"] = c[2] || 0;
		end
	end
	local function __cvar()
		local _v, _s = HERPES['setting'][name], ___s[name];
		if( !_s || _s != _v ) then
			___s[name] = HERPES['setting'][name];
			WriteFile();
		end
		__ti.Simple( 0.1, __cvar );
	end
	__cvar();
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

HERPES:AddHook( "Think", HERPES.KeyEvent );

// Reset data
HERPES:Execute();

HERPES:Setting( "aim_team", 1, 0, 1, "Automaticly shoot when aiming" );
HERPES:Setting( "esp_steam", 1, 0, 1, "Ignore steam friends" );
HERPES:Setting( "esp_enable", 1, 0, 1, "Turn ESP on" );

// HUDPaint
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

function HERPES.HUDPaint()
	local pl = copy['LocalPlayer']();
	for k, v in copy['pairs']( copy['player']['GetAll']() ) do
		if( !v ) then continue; end
		if( v == pl ) then continue; end
		if( !c.Player['Alive']( v ) ) then continue; end
		
		local mon, nom;
		nom = c.Entity['GetPos']( v );
		mon = nom + copy['Vector']( 0, 0, 70 );
		
		local h, w;
		local bot, top = c.Vector['ToScreen']( nom ), c.Vector['ToScreen']( mon );
		if( bot['visible'] && top['visible'] ) then
			h = ( bot['y'] - top['y'] );
			w = h / 6;
			
			//drawSkeleton( v ); // SHIT
			
			__s.SetDrawColor( 0, 255, 0, 255 ); 
			__s.DrawOutlinedRect( top['x'] - w, top['y'], w * 2, ( bot.y - top.y ) );
			
			local x, y, color = ( top['x'] + w ) + 1, top['y'] - 2, __tm.GetColor( c.Player['Team']( v ) );
			__dr.SimpleText( c.Player['Nick']( v ), "DefaultSmallDropShadow", x, y, color, 0, 0 );
			__dr.SimpleText( __str.format( "Hp:%i", c.Entity['Health']( v ) ), "DefaultSmallDropShadow", x, y + 12, color, 0, 0 );
		end
	end
end
HERPES:AddHook( "HUDPaint", HERPES.HUDPaint );

// XQZ
function HERPES.RenderScreenspaceEffects()
	cam.Start3D( copy['EyePos'](), copy['EyeAngles']() )
	for k, v in copy['pairs']( copy['player']['GetAll']() ) do
		if( !v ) then continue; end
		if( v == pl ) then continue; end
		if( !c.Player['Alive']( v ) ) then continue; end
		
		cam.IgnoreZ( true );
			render.SuppressEngineLighting( true );
			c.Entity['DrawModel']( v );
		cam.IgnoreZ( false );
		render.SuppressEngineLighting( false );
	end
	cam.End3D();
end
HERPES:AddHook( "RenderScreenspaceEffects", HERPES.RenderScreenspaceEffects );

// Nospread
HERPES.bullet = {}

local function WeaponVector( value, typ, vec )
	if ( !vec ) then return tonumber( value ) end
	local s = ( tonumber( value ) )
	if ( typ == true ) then
		s = ( tonumber( -value ) )
	end
	return Vector( s, s, s )
end

local CONE = {}

CONE.weapon = {}
CONE.weapon["weapon_pistol"]			= WeaponVector( 0.0100, true, true )	// HL2 Pistol
CONE.weapon["weapon_smg1"]				= WeaponVector( 0.04362, true, true )	// HL2 SMG1
CONE.weapon["weapon_ar2"]				= WeaponVector( 0.02618, true, true )	// HL2 AR2
CONE.weapon["weapon_shotgun"]			= WeaponVector( 0.08716, true, true )	// HL2 SHOTGUN
CONE.weapon["weapon_zs_zombie"]			= WeaponVector( 0.0, true, true )		// REGULAR ZOMBIE HAND
CONE.weapon["weapon_zs_fastzombie"]		= WeaponVector( 0.0, true, true )		// FAST ZOMBIE HAND

_R.Entity.FireBullets = HERPES:Detour( _R.Entity.FireBullets, function( e, bullet )
	local w = LocalPlayer():GetActiveWeapon()
	HERPES.bullet[w:GetClass()] = bullet.Spread
	return HERPES.detours[ _R.Entity.FireBullets ]( e, bullet )
end )

function HERPES:PredictSpread( ucmd, angle )
	local ply = LocalPlayer()
	local w = ply:GetActiveWeapon()
	if ( w && w:IsValid() ) then
		local class = w:GetClass()
		if ( !CONE.weapon[class] ) then
			if ( HERPES.bullet[class] ) then
				local ang = angle:Forward() || ( ply:GetAimVector():Angle() ):Forward()
				local conevec = Vector( 0, 0, 0 ) - HERPES.bullet[class] || Vector( 0, 0, 0 )
				return _lua.Nospread( ucmd, ang, conevec ):Angle()
			end
		else
			local ang = angle:Forward() || ply:GetAimVector():Angle()
			local conevec = CONE.weapon[class]
			return _lua.Nospread( ucmd, ang, conevec ):Angle()
		end
	end
	return angle
end

// Aimbot
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
		return c.Entity['LocalToWorld']( e, c.Vector['OBBCenter']( e ) + pos );
	end
	return ( c.Entity['LocalToWorld']( e, pos ) )
end

local attachments = { "eyes", "forward", "head" };
function HERPES:HeadPos( e )
	for k, v in copy['pairs']( attachments ) do
		local att = c.Entity['GetAttachment']( e, c.Entity['LookupAttachment']( e, v ) );
		if( att ) then
			return att['Pos'];
		end
	end
	
	local model = c.Entity['GetModel']( e );
	if( bones[model] ) then
		return GetPosType( e, bones[model] );
	end
	
	return GetPosType( e, "ValveBiped.Bip01_Head1" );
end

function HERPES:Prediction( e, pos )
	local pl = copy['LocalPlayer']();
	local tarFrames, plyFrames = ( copy['RealFrameTime']() / 25 ), ( copy['RealFrameTime']() / 66 );
	return pos + ( ( c.Entity['GetVelocity']( e ) * ( tarFrames ) ) - ( c.Entity['GetVelocity']( e ) * ( plyFrames ) ) );
end

function HERPES:IsVisible( e )
	local pl = copy['LocalPlayer']();
	
	local pos = HERPES:HeadPos( e )
	pos = HERPES:Prediction( e, pos )
	
	local trace = { 
		start = c.Player['GetShootPos']( pl ), 
		endpos = pos, 
		filter = { pl, e }, 
		mask = MASK_SHOT
	}
	local tr = __u.TraceLine( trace );
	
	if( !tr.Hit ) then
		return true;
	end
	return false;
end

function HERPES:AquireTarget()
	local pl, tar = copy['LocalPlayer'](), { 0, 0 };
	local ang, pos = c.Player['GetAimVector']( pl ), c.Entity['EyePos']( pl );
	for k, v in copy['pairs']( copy['player']['GetAll']() ) do
		if( !v ) then continue; end
		if( v == pl ) then continue; end
		if( !c.Player['Alive']( v ) ) then continue; end
		if( !HERPES:IsVisible( v ) ) then continue; end
		
		local tarPos = c.Entity['EyePos']( v )
		local difr = c.Vector['Normalize']( tarPos - pos );
		difr = difr - ang
		difr = difr:Length()
		difr = __m.abs( difr )
		if( difr < tar[2] or tar[1] == 0 ) then
			tar = { v, difr }
		end
	end
	return tar[1] || nil;
end

function HERPES.CreateMove( ucmd )
	if( !HERPES['__aim'] ) then return end
	local pl, tar = copy['LocalPlayer'](), HERPES:AquireTarget();
	
	HERPES['__ang'] = c.CUserCmd['GetViewAngles']( ucmd );
	
	HERPES['__ang']['p'] = __m.NormalizeAngle( HERPES['__ang']['p'] );
	HERPES['__ang']['y'] = __m.NormalizeAngle( HERPES['__ang']['y'] );
	HERPES['__ang']['r'] = 0;
	
	HERPES['__ang'].y = math.NormalizeAngle( HERPES['__ang'].y + ( c.CUserCmd['GetMouseX']( ucmd ) * -0.022 * 1 ) );
	HERPES['__ang'].p = math.Clamp( HERPES['__ang'].p + ( c.CUserCmd['GetMouseY']( ucmd ) * 0.022 * 1 ), -89, 90 );
	
	if( !tar ) then return end
	if( tar == 0 ) then return end
	
	local head = HERPES:Prediction( tar, HERPES:HeadPos( tar ) );
	HERPES['__ang'] = c.Vector['Angle']( head - c.Player['GetShootPos']( pl ) );
	
	head = HERPES:PredictSpread( ucmd, HERPES['__ang'] )
	
	head['p'] = __m.NormalizeAngle( head['p'] );
	head['y'] = __m.NormalizeAngle( head['y'] );
	head['r'] = 0;
	
	c.Player['SetEyeAngles']( pl, head );
	c.CUserCmd['SetViewAngles']( ucmd, head );
end

HERPES:AddHook( "CreateMove", HERPES.CreateMove );

// Recoil
function HERPES.CalcView( ply, orig, ang, FOV )
	return ( HERPES['__aim'] && { origin = orig, angles = HERPES['__ang'] } || { orgin = orig, angles = ang } );
end
HERPES:AddHook( "CalcView", HERPES.CalcView );

// dev console
local help = [[
	most cmd's start with aim_, esp_, or misc_
	extras: cls (clear)
	/h = help
	/a = max/min
	
	usage: "aim_shoot 1" to turn on,
	aim_shoot /h to see help.
	
	also ur gaye
]]

local panel = nil;
function HERPES.Console()
	if( !HERPES['__menu'] ) then
		return;
	end
	
	if( panel != nil ) then
		panel:SetVisible( true );
		return;
	end
	
	panel = vgui.Create( "DFrame" );
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
	
	local lists;
	local function __console()
		lists = vgui.Create( "DPanelList" );
		lists:SetPos( 10, 30 );
		lists:SetParent( panel );
		lists:SetSize( 330, 380 );
		lists:EnableVerticalScrollbar( true );
		lists:SetPadding( 5 );
		lists.Paint = function()
			surface.SetDrawColor( 255, 255, 255, 255 );
			surface.DrawRect( 0, 0, lists:GetWide(), lists:GetTall() );
			
			surface.SetDrawColor( 0, 0, 0, 255 );
			surface.DrawOutlinedRect( 0, 0, lists:GetWide(), lists:GetTall() );
		end
	end
	__console()
	
	local text = string.Explode( "\n", help )
	for i = 1, table.Count( text ) do
		local startup = vgui.Create( "DLabel" )
		startup:SetMultiline( true )
		startup:SetTextColor( color_black )
		startup:SetSize( 200, 13 )
		startup:SetText( text[i] )
		lists:AddItem( startup )
	end
	
	local commandentry = vgui.Create( "DTextEntry" )
	commandentry:SetParent( panel )
	commandentry:SetPos( 10, 420 )
	commandentry:SetSize( 250, 20 )
	
	local button = vgui.Create( "DButton" )
	button:SetParent( panel )
	button:SetText( "Submit" )
	button:SetPos( 270, 420 )
	button:SetSize( 70, 20 )
	
	local function detectInput()
		local text = commandentry:GetValue()
		
		
	end
end