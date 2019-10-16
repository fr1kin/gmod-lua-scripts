--[[
	Herpes.lua
	Tyler | (STEAM_0:0:40143824)
	===DStream===
]]

--
/*
	Herpes public by fr1kin
	youre moter is $ 2 bich suck
*/

// change this to anything you want nerd
local file_name = "dump";

local hack = { };

hack.logs = {};

hack.hookcallbacks = {};

hack.hooks = {
	added = {};
	attached = {};
};

local ply = nil;
local G, R = table.Copy( _G ), table.Copy( _R );

function hack:Log( msg )
	self.logs[msg] = true;
	G.MsgN( G.string.format( "[Herpes]: %s", msg ) );
end

function hack:IsInGlobals( func, tbl, scanned )
	scanned = scanned || {};
	for name, object in G.pairs( tbl ) do
		if( name == func ) then
			return true;
		end
		if( G.type( object ) == "table" && !scanned[name] ) then
			scanned[name] = true;
			local lib = self:IsInGlobals( func, object, scanned );
			if( lib == true ) then
				return true;
			end
		end
	end
end

function hack:LoadLibrary( lib )
	if( self:IsInGlobals( lib, _G ) == true ) then
		return;
	end
	G.require( lib );
	G[lib] = _G[lib];
	self:Log( G.string.format( "Loaded library %s.", lib ) );
end

function hack:FindSafeTable( name )
	if( G.package.loaded[name] ) then
		return G.package.loaded[name];
	elseif( _G[name] ) then
		if( _G[name]._M ) then
			return _G[name]._M;
		end
	end
	return _G[name] || {};
end

function hack:LocalPlayerValid()
	if( ply == nil || ply && G.IsValid( ply ) == false ) then
		ply = G.LocalPlayer();
	end
	return ( ply != nil && G.IsValid( ply ) ) && true || false;
end

function hack:IsGmod13()
	// SOMEONE WILL PROBABLY FUCK WITH THIS
	return net != nil;
end

G = hack:FindSafeTable( "_G" );

hack:LoadLibrary( "hook" );
hack:LoadLibrary( "draw" );
hack:LoadLibrary( "team" );
hack:LoadLibrary( "timer" );
hack:LoadLibrary( "weapons" );
hack:LoadLibrary( "gamemode" );

// Hooking

function hack:RunHook( _hook, _name )
	local htable = G.hook.GetTable();
	if( htable[_hook] == nil ) then
		return NULL;
	end
	for name, func in G.pairs( htable[_hook] ) do
		if( _name == name ) then
			func();
		end
	end
end

function hack:IsHookResponding( _hook, _name )
	if( self.hookcallbacks[_hook] == nil ) then
		return false;
	end
	self.hookcallbacks[_hook] = false;
	self:RunHook( _hook, _name );
	return self.hookcallbacks[_hook];
end

function hack:IsInHookTable( _hook )
	if( G.hook.GetTable == nil ) then
		return NULL;
	end
	local htable = G.hook.GetTable();
	if( G.type( htable ) != "table" ) then
		return NULL;
	end
	return htable[_hook] && true || false;
end

function hack:AttatchToHook( _func, _hook )
	if( self:IsInHookTable( _hook ) == false ) then
		return NULL;
	end
	local htable = G.hook.GetTable();
	for name, tbl in G.pairs( htable ) do
		if( _hook != name ) then
			continue;
		end
		for hname, hfunc in G.pairs( tbl ) do
			local function newFunction(...)
				self.hookcallbacks[_hook] = true;
				_func(...);
				hfunc(...);
			end
			
			self.hookcallbacks[_hook] = false;
			
			G.hook.Remove( _hook, hname );
			G.hook.Add( _hook, hname, newFunction );
			
			if( self:IsHookResponding( _hook, hname ) ) then
				self:Log( G.string.format( "Hook %s responded, successfully hooked into %s", _hook, hname ) );
				self.hooks.attached[_hook] = { hname, hfunc };
				return hname;
			end
			self:Log( G.string.format( "Hook %s failed to responded, retrying...", _hook ) );
		end
	end
	self:Log( G.string.format( "Failed to attach hook into %s.", _hook ) );
	return NULL;
end

function hack:DetachHook( _hook, _name )
	if( self.hooks.attached[_hook] == nil ) then
		return NULL;
	end
	local info = self.hooks.attached[_hook];
	if( info[2] ) then
		G.hook.Remove( _hook, _name );
		G.hook.Add( _hook, _name, info[2] );
		
		self.hooks.attached[_hook] = nil;
		self:Log( G.string.format( "Detached function in %s from hook %s.", _name, _hook ) );
		return true;
	end
	self:Log( G.string.format( "Failed to detach function in %s from hook %s.", _name, _hook ) );
	return false;
end

function hack:DefaultHook( _hook, _func )
	local random = G.math.random( 1, 1000 );
	G.hook.Add( _hook, random, _func );
	self:Log( G.string.format( "Added unsafe hook to %s.", _hook ) );
	return random;
end

function hack:CheckHook( _hook, _name )
	if( self.hooks.attached[_hook] == nil ) then
		return NULL;
	end
	if( self.hooks.added[_hook] == nil ) then
		return NULL;
	end
	
	local info = self.hooks.added[_hook];
	
	if( self:IsHookResponding( _hook, _name ) == false ) then
		self:AddHook( _hook, _name, info[3] );
	end
	return;
end

function hack:CheckHooking()
	for k, v in G.pairs( hack.hooks.added ) do
		hack:CheckHook( k, v[2] );
	end
end

function hack:AddHook( _hook, _name, _func, _noatt )
	_noatt = _noatt || false;
	local name = "NONE";
	local attachedhook = true;
	
	local name = NULL;
	if( _noatt == false ) then
		name = self:AttatchToHook( _func, _hook );
	end
	if( name == NULL ) then
		name = self:DefaultHook( _hook, _func );
		attachedhook = false;
	end
	self.hooks.added[_hook] = { name, _name, _func, attachedhook };
end

function hack:RemoveHook( _hook, _name )
	if( self.hooks.added[_hook] == nil ) then
		return NULL;
	end
	for k, v in G.pairs( self.hooks.added ) do
		if( _name == v[2] ) then
			if( v[4] ) then
				self:DetachHook( _hook, v[1] );
			else
				G.hook.Remove( _hook, v[1] );
			end
			self.hooks.added[k] = nil;
			
			self:Log( G.string.format( "Removed hook %s", _hook ) );
			return;
		end
	end
	self:Log( G.string.format( "Failed to remove hook %s", _hook ) );
end

// CVars

hack.convars = {};

function hack:FindFile()
	// Maybe I will do something intresting later.
	return G.string.format( "%s.txt", file_name );
end

hack.usefile = hack:FindFile();

function hack:ReadFile()
	if( G.file.Read( self.usefile ) == "" ) then
		return;
	end
	
	local data = G.file.Read( self.usefile );
	if( !data ) then
		return;
	end
	
	local expand = G.string.Explode( "\n", data );
	
	local sep = "";
	for k, v in G.pairs( expand ) do
		sep = G.string.Explode( "=", v );
		if( sep[1] && self.convars[ sep[1] ] ) then
			if( sep[1] && sep[2] ) then
				self.convars[sep[1]].value = sep[2];
			end
		else
			if( sep[1] && sep[2] ) then
				self:AddCVar( sep[1], sep[2] );
			end
		end
	end
end

function hack:Write()
	local write = "";
	for k, v in G.pairs( self.convars ) do
		if( k && v && v.value ) then
			write = write .. G.string.format( "%s=%i\n", k, tonumber( v.value ) );
		end
	end
	G.file.Write( hack.usefile, write );
end

function hack:AddCVar( name, value, help, max, min )
	if( self.convars[name] ) then
		self.convars[name].help = help;
		self.convars[name].max = max;
		self.convars[name].min = min;
		return;
	end
	local max = max || 1;
	local min = min || 0;
	local help = help || "None.";
	
	local info = {
		value = value,
		help = help,
		max = max,
		min = min
	};
	
	self.convars[name] = info;
end

do
	local info = {};
	local cvar;
	local function GetCVar( self, name )
		if( self.convars[name] == nil ) then
			return NULL;
		end
		cvar = self.convars[name];
		if( !info[name] ) then
			info[name] = {};
			info[name].GetBool = function()
				return G.tonumber( cvar.value ) == 1 && true || false;
			end
			info[name].GetInt = function()
				return G.tonumber( cvar.value );
			end
			info[name].GetHelp = function()
				return G.tostring( cvar.help );
			end
			info[name].GetMax = function()
				return G.tonumber( cvar.max );
			end
			info[name].GetMin = function()
				return G.tonumber( cvar.min );
			end
		end
		return info[name];
	end
	local function SetCVar( self, name, value )
		if( self.convars[name] == nil ) then
			return NULL;
		end
		self.convars[name].value = G.tonumber( value );
		self:Write();
	end
	hack.GetCVar = GetCVar;
	hack.SetCVar = SetCVar;
end

// ConCommands

hack.commands = {};
hack.cmdtoggle = {};

hack.force = {};
hack._toggle = {};

hack._wait = {};

function hack:AddCommand( command, key )
	hack[command] = false;
	self.commands[command] = key;
end

function hack:GetCommand( command )
	if( hack[command] == nil ) then
		return nil;
	end
	return hack[command];
end

function hack:SetCommand( command, new )
	if( hack[command] == nil ) then
		return;
	end
	hack[command] = new;
	hack.force[command] = true;
end

function hack:AddToggle( command, func )
	self.cmdtoggle[command] = func;
end

function hack:CommandCall()
	if( G.vgui.CursorVisible() == true ) then
		return;
	end
	for k, v in G.pairs( self.commands ) do
		if( G.input.IsKeyDown( v ) ) then
			hack[k] = true;
			if( hack.force[k] != nil && hack.force[k] == true ) then
				hack[k] = false;
			end
		else
			if( hack.force[k] ) then
				hack.force[k] = nil;
			end
			hack[k] = false;
		end
	end
	for cmd, func in G.pairs( self.cmdtoggle ) do
		if( hack._wait[cmd] == nil ) then
			hack._wait[cmd] = 0;
		end
		if( G.input.IsKeyDown( v ) && G.CurTime() >= hack._wait[cmd] && hack._toggle[cmd] == nil ) then
			func();
			hack._wait[cmd] = G.CurTime() + 1;
		else
			if( hack._toggle[cmd] ) then
				hack._toggle[cmd] = nil;
			end
		end
	end
end

// Wallhack

hack.colors = {
	white = G.Color( 255, 255, 255, 255 ),
	black = G.Color( 0, 0, 0, 255 ),
	red = G.Color( 255, 0, 0, 255 ),
	green = G.Color( 0, 255, 0, 255 ),
	purple = G.Color( 163, 73, 164, 255 ),
};

hack.admin = {
	"IsSuperAdmin",
	"IsAdmin",
	"EV_IsOwner",
	"EV_IsSuperAdmin",
	"EV_IsAdmin",
	"EV_IsRespected",
	"IsRespected",
}

hack.entity = {};

local vector_null = G.Vector( NULL, NULL, NULL );

hack:AddCVar( "esp_enable", 1, "Enable Esp" );
hack:AddCVar( "esp_npc", 1, "NPC Esp" );
hack:AddCVar( "esp_wallhack", 1, "Wallhack" );

function hack:IsValidEntity( ent )
	if( ent == nil ) then return false; end
	if( G.IsValid( ent ) == false ) then return false; end
	if( R.Entity.GetMoveType( ent ) == MOVETYPE_NONE ) then return false; end
	if( ent:IsPlayer() ) then
		if( R.Player.Alive( ent ) == false ) then return false; end
		if( R.Entity.Health( ent ) <= 0 ) then return false; end
		return true;
	end
	if( ent:IsNPC() ) then
		return true;
	end
	return false;
end

function hack:ValidDrawEntity( ent )
	if( self:LocalPlayerValid() == false ) then
		return false;
	end
	if( ent == nil ) then return false; end
	if( G.IsValid( ent ) == false ) then return false; end
	if( ent == ply ) then return false; end
	if( ent:IsNPC() && self:GetCVar( "esp_npc" ):GetBool() == false ) then return false; end
	return true;
end

function hack:IsValidAimTarget( ent )
	if( self:LocalPlayerValid() == false ) then
		return false;
	end
	if( self:IsValidEntity( ent ) == false ) then return false; end
	if( R.Entity.GetMoveType( ent ) == MOVETYPE_OBSERVER ) then return false; end
	if( hack:IsVisible( ent ) == false ) then return false; end
	if( ent:IsPlayer() ) then
		if( R.Player.GetObserverMode( ent ) != OBS_MODE_NONE ) then return false; end
		if( G.team.GetName( R.Player.Team( ply ) ):lower():find( "spect" ) ) then return false; end
		if( self:GetCVar( "aim_steam" ):GetBool() == true && R.Player.GetFriendStatus( ent ) == "friend" ) then return false; end
		if( self:GetCVar( "aim_team" ):GetBool() == true && R.Player.Team( ent ) == R.Player.Team( ply ) ) then return false; end
		return true;
	end
	if( ent:IsNPC() ) then
		if( self:GetCVar( "aim_npc" ):GetBool() == true ) then return false; end
		return true;
	end
	return false;
end

function hack:IsAdmin( ent )
	for _, typ in G.pairs( self.admin ) do
		// use _R just incase the hack had run before the script
		if( _R.Player[typ] && _R.Player[typ]( ent ) ) then
			return true;
		elseif( _R.Entity[typ] && _R.Entity[typ]( ent ) ) then
			return true;
		end
	end
	return false;
end

do
	local vecBot, vecTop;
	local function GetCoords( self, ent )
		if( ent == nil ) then
			return vector_null, vector_null;
		end
		vecBot = R.Entity.GetPos( ent );
		vecTop = vecBot + Vector( 0, 0, R.Entity.OBBMaxs( ent ).z );
		return R.Vector.ToScreen( vecBot ), R.Vector.ToScreen( vecTop );
	end
	hack.GetCoords = GetCoords;
end

do
	local teamcolor;
	local function GetColor( self, ent )
		teamcolor = ent:IsPlayer() && G.team.GetColor( R.Player.Team( ent ) ) || self.colors.red;
		teamcolor.a = 255;
		return teamcolor;
	end
	local function GetBoxColor( self, ent )
		if( self.target == ent ) then
			return self.colors.white;
		end
		if( ent:IsPlayer() ) then
			if( R.Player.GetFriendStatus( ent ) == "friend" ) then
				return self.colors.purple;
			elseif( self:IsAdmin( ent ) ) then
				return self.colors.red;
			end
		end
		return self.colors.green;
	end
	hack.GetColor = GetColor;
	hack.GetBoxColor = GetBoxColor;
end

// TANK YOU DICK JOHNSON GMOD13 IS GAY AS FUCK
G.surface.CreateFont( "Arial", 13, 700, false, false, "ESPFont" );

do
	local color, top, bot, name, hp, w, h, x, y, spos;
	local SCREEN_TOP, SCREEN_BOTTOM, SCREEN_LEFT, SCREEN_RIGHT = 0, 1, 2, 3;
	local function FindScreenSide( x, y, w, h )
		x = G.math.Round( x );
		y = G.math.Round( y );
		if( x == 0 ) then
			return SCREEN_LEFT;
		elseif( y == 0 ) then
			return SCREEN_TOP;
		elseif( x == G.ScrW() - w ) then
			return SCREEN_RIGHT;
		elseif( y == G.ScrH() - h ) then
			return SCREEN_BOTTOM;
		end
		return -1;
	end
	local function DrawShadowText( text, font, x, y, color, xa, ya )
		G.draw.SimpleText( text, font, x + 1, y + 1, hack.colors.black, xa, ya );
		G.draw.SimpleText( text, font, x, y, color, xa, ya );
	end
	local function Esp( self )
		if( self:GetCVar( "esp_enable" ):GetBool() == false ) then
			return;
		end
		for index, ent in G.pairs( self.entity ) do
			if( self:ValidDrawEntity( ent ) == false ) then
				continue;
			end
			bot, top = self:GetCoords( ent );
			if( top.visible && bot.visible ) then
				h = ( bot.y - top.y );
				w = h / 3;
				
				color = self:GetBoxColor( ent );
				name = ent:IsPlayer() && R.Player.Name( ent ) || R.Entity.GetClass( ent );
				
				G.surface.SetDrawColor( color );
				G.surface.DrawOutlinedRect( ( top.x - ( w / 2 ) ), ( top.y ), w, ( bot.y - top.y ) );
				
				color = self:GetColor( ent );
				x = top.x + ( w / 2 ) + 1;
				y = top.y - 2;
				
				DrawShadowText( name, "ESPFont", x, y, color, 0, 0 );
				
				if( ent:IsPlayer() == false ) then
					continue;
				end
				
				hp = R.Entity.Health( ent );
				if( hp <= 100 ) then
					color = G.Color( 255, hp * 2.55, hp * 2.55, 255 ); // thanks stgn
				else
					color = self.colors.white;
				end
				
				DrawShadowText( hp, "ESPFont", x, y + 12, color, 0, 0 );
			end
		end
	end
	hack.Esp = Esp;
end

do
	local function WallHack( self )
		G.cam.Start3D( G.EyePos(), G.EyeAngles() );
			for index, ent in G.pairs( self.entity ) do
				if( ent == nil || ent != nil && G.IsValid( ent ) == false ) then
					continue;
				end
				if( self:ValidDrawEntity( ent ) == false ) then
					R.Entity.SetNoDraw( ent, false );
					R.Entity.SetRenderMode( ent, RENDERMODE_NORMAL );
					R.Entity.DrawModel( ent );
					continue;
				end
				if( self:GetCVar( "esp_wallhack" ):GetBool() == true && self:GetCVar( "esp_enable" ):GetBool() == true ) then
					G.cam.IgnoreZ( true );
					if( ent:IsPlayer() == false ) then
						R.Entity.SetNoDraw( ent, false );
					end
					R.Entity.SetRenderMode( ent, RENDERMODE_NORMAL );
				end
				R.Entity.DrawModel( ent );
				
				G.cam.IgnoreZ( false );
				if( ent:IsPlayer() == false ) then
					R.Entity.SetNoDraw( ent, true );
				end
				R.Entity.SetRenderMode( ent, RENDERMODE_NONE );
				
				R.Entity.DrawModel( ent );
			end
		G.cam.End3D();
	end
	hack.WallHack = WallHack;
end

// Aimbot

hack.hl2 = {
	["weapon_pistol"] = true,
	["weapon_357"] = true,
	["weapon_smg1"] = true,
	["weapon_ar2"] = true,
	["weapon_shotgun"] = true
};

hack.attachments = {
	"head",
	"forward",
	"eyes",
};

hack.angle = G.Angle( 0, 0, 0 );
hack.target = nil;
hack.locked = false;

hack:AddCommand( "aiming", KEY_F );

hack:AddCVar( "aim_shoot", 1, "Autoshoot" );
hack:AddCVar( "aim_steam", 1, "Ignore steam friend" );
hack:AddCVar( "aim_team", 0, "Ignore teammates" );
hack:AddCVar( "aim_npc", 1, "Ignore NPCs" );
hack:AddCVar( "aim_recoil", 1, "Norecoil" );
hack:AddCVar( "aim_prediction", 1, "Prediction" );
hack:AddCVar( "aim_hold", 0, "Hold target" );
hack:AddCVar( "aim_drop", 0, "Disable after kill" );

hack:AddCVar( "mis_bhop", 1, "Bunnyhop" );

do
	local pos;
	local function GetHitPos( self, ent )
		if( ent == nil ) then return; end
		if( G.IsValid( ent ) == false ) then return; end
		for k, att in pairs( self.attachments ) do
			pos = R.Entity.GetAttachment( ent, R.Entity.LookupAttachment( ent, att ) );
			if( pos ) then
				return pos.Pos;
			end
		end
		return R.Entity.GetBonePosition( ent, R.Entity.LookupBone( ent, "ValveBiped.Bip01_Head1" ) ) || R.Entity.LocalToWorld( ent, R.Entity.OBBCenter( ent ) );
	end
	hack.GetHitPos = GetHitPos;
end

do
	local trace, tr;
	local function IsVisible( self, ent )
		if( self:LocalPlayerValid() == false ) then
			return false;
		end
		trace = {
			start = R.Player.GetShootPos( ply ),
			endpos = self:GetHitPos( ent ),
			filter = { ply, ent },
			mask = MASK_SHOT
		};
		tr = G.util.TraceLine( trace );
		if( tr == nil ) then return false; end
		return tr.Fraction == 1 && true || false;
	end
	hack.IsVisible = IsVisible;
end

do
	local entPos, selfPos, selfAng, bdist;
	local function FindTarget( self, ent, cur_dist )
		cur_dist = cur_dist || 0;
		if( self:LocalPlayerValid() == false ) then
			return nil;
		end
		if( self:IsValidAimTarget( ent ) == false ) then
			return nil;
		end
		entPos, selfPos, selfAng = R.Entity.EyePos( ent ), R.Entity.EyePos( ply ), R.Player.GetAimVector( ply );
		bdist = G.math.abs( R.Vector.Length( R.Vector.Normalize( entPos - selfPos ) - selfAng ) ) || 0;
		if( bdist < cur_dist || cur_dist == 0 ) then
			return true, bdist;
		end
		return false, 0;
	end
	hack.FindTarget = FindTarget;
end

do
	local lpos = {};
	local rpos;
	local function RecordPos( ent, pos )
		if( !lpos[ent] ) then
			lpos[ent] = {};
			lpos[ent].pos = pos;
			lpos[ent].rt = G.RealTime();
		end
		if( lpos[ent].rt != G.RealTime() ) then
			lpos[ent].pos = pos;
		end
		return lpos[ent].pos;
	end
	local function PredictTarget( self, ent, pos )
		if( self:GetCVar( "aim_prediction" ):GetBool() == false ) then
			return pos;
		end
		rpos = lpos[ent] && lpos[ent].pos || nil;
		RecordPos( ent, pos );
		if( rpos == nil ) then
			return pos;
		end
		return pos + ( rpos - pos ) / 25
	end
	hack.PredictTarget = PredictTarget;
end

do
	local wep, angle;
	local function CorrectRecoil( self, ucmd )
		if( self:GetCVar( "aim_recoil" ):GetBool() == false ) then
			return;
		end
		wep = R.Player.GetActiveWeapon( ply );
		if( !wep || wep && G.IsValid( wep ) == false ) then
			return nil;
		end
		wep = G.tostring( wep:GetClass() );
		if( self.hl2[wep] ) then
			angle = R.CUserCmd.GetViewAngles( ucmd ) - R.Player.GetPunchAngle( ply );
			R.CUserCmd.SetViewAngles( ucmd, angle );
		end
	end
	hack.CorrectRecoil = CorrectRecoil;
end

do
	local tar, angles, lastshoot;
	local function Aimbot( self, ucmd )
		ply = G.LocalPlayer();
		self.locked = false;
		if( ply == nil || ply && G.IsValid( ply ) == false ) then
			return;
		end
		if( self:GetCVar( "mis_bhop" ):GetBool() == true && R.Entity.GetMoveType( ply ) != MOVETYPE_LADDER && R.CUserCmd.KeyDown( ucmd, IN_JUMP ) && R.Entity.OnGround( ply ) == false ) then
			R.CUserCmd.SetButtons( ucmd, R.CUserCmd.GetButtons( ucmd ) - IN_JUMP );
		end
		if( lastshoot == nil ) then
			lastshoot = 0;
		end
		if( R.Player.Alive( ply ) == false ) then
			return;
		end
		if( self:GetCommand( "aiming" ) == false ) then
			return;
		end
		if( self.target == nil ) then
			return;
		end
		angles = self:GetHitPos( self.target ) || vector_null;
		if( angles == vector_null ) then
			return;
		end
		angles = self:PredictTarget( self.target, angles );
		angles = R.Vector.Angle( angles - R.Player.GetShootPos( ply ) );
		
		angles.p = G.math.NormalizeAngle( angles.p );
		angles.y = G.math.NormalizeAngle( angles.y );
		angles.r = 0.00;
		
		R.CUserCmd.SetViewAngles( ucmd, angles );
		
		self.angle = R.CUserCmd.GetViewAngles( ucmd );
		self.locked = true;
		
		self:CorrectRecoil( ucmd );
		
		if( self:GetCVar( "aim_shoot" ):GetBool() == true && G.SysTime() >= lastshoot ) then
			lastshoot = G.SysTime() + 0.1;
			R.CUserCmd.SetButtons( ucmd, R.CUserCmd.GetButtons( ucmd ) | IN_ATTACK );
		end
	end
	hack.Aimbot = Aimbot;
end

// Misc

do
	local tar, dist, b, d, dosearch;
	local function GetEntities( self )
		self.entity = {};
		self.target = nil;
		dist = 0;
		dosearch = true;
		if( self:GetCVar( "aim_hold" ):GetBool() == false && self:GetCVar( "aim_drop" ):GetBool() == false ) then
			tar = nil;
		end
		if( tar != nil && ( self:GetCVar( "aim_hold" ):GetBool() == true ) ) then
			if( G.IsValid( tar ) && self:IsValidEntity( tar ) ) then
				dosearch = false;
			else
				if( self:GetCVar( "aim_drop" ):GetBool() == true ) then
					self:SetCommand( "aiming", false );
				end
				tar = nil;
			end
		end
		for k, v in G.pairs( G.ents.GetAll() ) do
			if( self:IsValidEntity( v ) ) then
				self.entity[k] = v;
				if( self:GetCommand( "aiming" ) == false ) then
					tar = nil;
					continue;
				end
				if( v == ply || dosearch == false ) then
					continue;
				end
				if( tar != nil && ( self:GetCVar( "aim_drop" ):GetBool() == true ) ) then
					if( G.IsValid( tar ) == false || self:IsValidEntity( tar ) == false ) then
						self:SetCommand( "aiming", false );
						tar = nil;
						continue;
					end
				end
				b, d = self:FindTarget( v, dist );
				if( b == true ) then	
					tar = v;
					dist = d;
				end
			end
		end
		if( self:GetCommand( "aiming" ) == true ) then
			if( self:GetCVar( "aim_drop" ):GetBool() == true && self:GetCVar( "aim_hold" ):GetBool() == false ) then
				if( tar && self:IsValidAimTarget( tar ) == false ) then
					tar = nil;
					self:SetCommand( "aiming", false );
					return;
				end
			end
			if( self:IsValidEntity( tar ) ) then
				self.target = tar;
			end
		end
	end
	hack.GetEntities = GetEntities;
end

// Menu
hack.keys = {
	[KEY_A] = "A",
	[KEY_B] = "B",
	[KEY_C] = "C",
	[KEY_D] = "D",
	[KEY_E] = "E",
	[KEY_F] = "F",
	[KEY_G] = "G",
	[KEY_H] = "H",
	[KEY_I] = "I",
	[KEY_J] = "J",
	[KEY_K] = "K",
	[KEY_L] = "L",
	[KEY_M] = "M",
	[KEY_N] = "N",
	[KEY_O] = "O",
	[KEY_P] = "P",
	[KEY_Q] = "Q",
	[KEY_R] = "R",
	[KEY_S] = "S",
	[KEY_T] = "T",
	[KEY_U] = "U",
	[KEY_V] = "V",
	[KEY_W] = "W",
	[KEY_X] = "X",
	[KEY_Y] = "Y",
	[KEY_Z] = "Z",
	[KEY_INSERT] = "Insert",
	[KEY_DELETE] = "Delete",
	[KEY_HOME] = "Home",
};

hack.blocked = {
	["con_enable"] = true,
	["sv_cheats"] = true,
	["_restart"] = true,
	["exec"] = true,
	["condump"] = true,
	["connect"] = true,
	["bind"] = true,
	["BindToggle"] = true,
	["alias"] = true,
	["ent_fire"] = true,
	["ent_setname"] = true,
	["sensitivity"] = true,
	["name"] = true,
	["r_aspect"] = true,
	["quit"] = true,
	["exit"] = true,
	["lua_run"] = true,
	["lua_run_cl"] = true,
	["lua_open"] = true,
	["lua_cookieclear"] = true,
	["lua_showerrors_cl"] = true,
	["lua_showerrors_sv"] = true,
	["lua_openscript"] = true,
	["lua_openscript_cl"] = true,
	["lua_redownload"] = true,
	["sent_reload"] = true,
	["sent_reload_cl"] = true,
	["swep_reload"] = true,
	["rcon_password"] = true,
	["test_RandomChance"] = true,
	["plugin_load"] = true,
}

function hack:SetBind( command, key )
	self.commands[command] = key;
end

function hack:ReadBindFile()
	if( G.file.Read( "binds.txt" ) == "" ) then
		return;
	end
	
	local data = G.file.Read( "binds.txt" );
	if( !data ) then
		return;
	end
	
	local expand = G.string.Explode( "\n", data );
	
	local sep = "";
	for k, v in G.pairs( expand ) do
		sep = G.string.Explode( "=", v );
		if( sep[1] && self.commands[ sep[1] ] ) then
			if( sep[1] && sep[2] ) then
				self.commands[sep[1]] = G.tonumber( sep[2] );
			end
		end
	end
end

function hack:WriteBindFile()
	local write = "";
	for k, v in G.pairs( self.commands ) do
		if( k && v ) then
			write = write .. G.string.format( "%s=%i\n", k, v );
		end
	end
	G.file.Write( "binds.txt", write );
end

// Menu

hack:AddCommand( "menu", KEY_INSERT );

do
	local menu, propsheet, info, button, label;
	local commandbox, bindbox;
	local panels = {};
	local tabs = {
		["aim_"] = { "Aimbot", "gui/silkicons/wrench" },
		["esp_"] = { "Extra Sensory", "gui/silkicons/group"	},
		["mis_"] = { "Misc", "gui/silkicons/plugin" }
	};
	local function DrawLayout( self )
		if( menu == nil ) then
			menu = G.vgui.Create( "DFrame" );
			R.Panel.SetSize( menu, 550, 330 );
			R.Panel.SetPos( menu, ( G.ScrW() / 2 ) - 550 / 2, ( G.ScrH() / 2 ) - 330 / 2 );
			R.Panel.MakePopup( menu );
			
			menu:SetDraggable( true );
			menu:SetTitle( "Herpes Public" );
			
			menu.Close = function()
				menu:SetVisible( false );
			end
			
			propsheet = G.vgui.Create( "DPropertySheet" )
			R.Panel.SetParent( propsheet, menu );
			R.Panel.SetSize( propsheet, 530, 290 );
			R.Panel.SetPos( propsheet, 10, 30 );
		end
		for k, v in G.pairs( self.convars ) do
			info = self:GetCVar( k );
			if( tabs[ G.string.sub( k, 1, 4 ) ] ) then
				local n = tabs[ G.string.sub( k, 1, 4 ) ];
				if( panels[ n[1] ] == nil ) then
					panels[ n[1] ] = G.vgui.Create( "DPanel" );
					panels[ n[1] ].index = 10;
				end
				local cb = G.vgui.Create( "DCheckBoxLabel" )
				cb:SetText( info:GetHelp() );
				cb:SetValue( info:GetInt() );
				cb:SetTextColor( self.colors.black );
				cb:SetPos( 10, panels[ n[1] ].index );
				cb:SetSize( 500, 20 );
				cb:SetParent( panels[ n[1] ] );
				
				function cb:OnChange()
					hack:SetCVar( k, cb:GetChecked() && 1 || 0 );
				end
				
				panels[ n[1] ].index = panels[ n[1] ].index + 20;
			end
		end
		
		// Binds - yeah i know its messy
		panels[ "Binds" ] = G.vgui.Create( "DPanel" );
		
		label = G.vgui.Create( "DLabel" );
		label:SetParent( panels["Binds"] );
		label:SetText( "Bind function:" );
		label:SetPos( 10, 10 );
		label:SetWide( 200 );
		label:SetTextColor( self.colors.black );
		
		label = G.vgui.Create( "DLabel" );
		label:SetParent( panels["Binds"] );
		label:SetText( "to key" );
		label:SetPos( 205, 10 );
		label:SetWide( 200 );
		label:SetTextColor( self.colors.black );
		
		commandbox = G.vgui.Create( self:IsGmod13() == false && "DMultiChoice" || "DComboBox" );
		commandbox:SetParent( panels["Binds"] );
		commandbox:SetPos( 85, 10 );
		commandbox:SetSize( 110, 21 );
		
		bindbox = G.vgui.Create( self:IsGmod13() == false && "DMultiChoice" || "DComboBox" );
		bindbox:SetParent( panels["Binds"] );
		bindbox:SetPos( 240, 10 );
		bindbox:SetSize( 110, 21 );
		
		for k, v in G.pairs( self.commands ) do
			commandbox:AddChoice( k );
		end
		for k, v in G.pairs( self.keys ) do
			bindbox:AddChoice( v );
		end
		
		local cmdselect, bindselect = nil, nil;
		function commandbox:OnSelect( index, value, data )
			if( !hack.commands[value] ) then
				return;
			end
			
			cmdselect = value;
			for k, v in G.pairs( hack.keys ) do
				if( k == hack.commands[value] ) then
					bindbox:ChooseOption( v );
					bindselect = v;
					break;
				end
			end
		end
		
		function bindbox:OnSelect( index, value, data )
			bindselect = value;
		end
		
		button = G.vgui.Create( "DButton" );
		button:SetParent( panels["Binds"] );
		button:SetSize( 85, 21 );
		button:SetPos( 10, 40 );
		button:SetText( "Bind" );
		
		function button:DoClick() 
			if( cmdselect && bindselect ) then
				if( !hack.commands[cmdselect] ) then
					return;
				end
				for k, v in G.pairs( hack.keys ) do
					if( v == bindselect ) then
						// retard prevention life line 2012
						for cmd, key in G.pairs( hack.commands ) do
							if( key == k ) then
								G.MsgN( "Retard" );
								return;
							end
						end
						hack.commands[cmdselect] = k;
						hack:Log( G.string.format( "Bound function %s to key %s", cmdselect, bindselect ) );
						hack:WriteBindFile();
						break;
					end
				end
			end
		end
		for k, v in G.pairs( panels ) do
			propsheet:AddSheet( k, v, nil, false, false, nil );
		end
	end
	local function MenuPopup( self )
		if( self:GetCommand( "menu" ) == true ) then
			if( menu == nil ) then
				DrawLayout( self );
				return;
			end
			menu:SetVisible( true );
		end
	end
	hack.MenuPopup = MenuPopup;
end

// Hooks

local function CreateMove( ucmd )
	if( ucmd == nil ) then
		return;
	end
	hack:Aimbot( ucmd );
end

local function CalcView( pl, orig, ang, FOV )
	if( GAMEMODE ) then
		if( hack.locked == false || hack:GetCVar( "aim_recoil" ):GetBool() == false ) then
			return GAMEMODE:CalcView( ply, orig, ang, FOV );
		end
		local view = GAMEMODE:CalcView( ply, orig, hack.angle, FOV ) || {}
			view.angles = hack.angle;
			view.angles.r = 0;
		return view;
	end
	return { player = pl, origin = orig, angles = ang, fov = FOV };
end

local function HUDPaint()
	hack:Esp();
end

local function RenderScreenspaceEffects()
	hack:WallHack();
end

local function Think()
	hack:GetEntities();
	hack:CommandCall();
	hack:MenuPopup();
end

hack:AddHook( "CreateMove", "CreateMove", CreateMove );
hack:AddHook( "CalcView", "CalcView", CalcView );
hack:AddHook( "HUDPaint", "HUDPaint", HUDPaint );
hack:AddHook( "RenderScreenspaceEffects", "RenderScreenspaceEffects", RenderScreenspaceEffects );
hack:AddHook( "Think", "Think", Think );

// Read last loaded file
hack:ReadFile();
hack:ReadBindFile();