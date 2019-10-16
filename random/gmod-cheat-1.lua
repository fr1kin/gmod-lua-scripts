// valve anticheat coded by gabe newman

local g, r, _bkup;
local _p, _t = pairs, type;

local function IsNil( o ) 		return ( o == nil ) 				end
local function IsAngle( o ) 	return ( _t( o ) == "Angle" ) 		end
local function IsBool( o ) 		return ( _t( o ) == "boolean" )		end
local function IsEnt( o ) 		return ( _t( o ) == "Entity" ) 		end
local function IsFunction( o ) 	return ( _t( o ) == "function" )	end
local function IsNPC( o ) 		return ( _t( o ) == "NPC" ) 		end
local function IsNumber( o ) 	return ( _t( o ) == "number" ) 		end
local function IsPanel( o )		return ( _t( o ) == "Panel" ) 		end
local function IsPlayer( o ) 	return ( _t( o ) == "Player" ) 		end
local function IsString( o ) 	return ( _t( o ) == "string" ) 		end
local function IsTable( o ) 	return ( _t( o ) == "table" ) 		end
local function IsVec( o ) 		return ( _t( o ) == "Vector" ) 		end

local hack = {
	log = {},
	registry = {
		CVar = {},
		Hook = {},
		Player = {},
		Entity = {},
	},
	global = {},
};

function hack:Log( msg, ... )
	self.log[#self.log + 1] = g.string.format( msg, g.unpack( {...} ) );
end

function hack:Copy( o )
	if( IsTable( o ) ) then
		local c = {};
		for name, object in _p( o ) do
			if( IsTable( object ) ) then
				_data = _data || {};
				_data[ object ] = c;
				if( _data[ object ] ) then
					c[ name ] = _data[ object ];
				else
					c[ name ] = CopyTable( object, _data );
				end
			else
				c[ name ] = object;
			end
		end
		return c;
	else
		local copy = o;
		return copy;
	end
	return nil;
end

function hack:Match( ob1, ob2 )
	if( IsNil( ob1 ) && IsNil( ob2 ) ) then
		return true;
	end
	if( IsNil( ob1 ) && !IsNil( ob2 ) ) then
		return false;
	end
	if( !IsNil( ob1 ) && IsNil( ob2 ) ) then
		return false;
	end
	if( g.rawequal && g.rawequal( ob1, ob2 ) ) then
		return true;
	end
	if( ob1 == obj2 ) then
		return true;
	end
	return false;
end

do
	g = hack:Copy( _G );
	r = hack:Copy( _G.debug.getregistry() );
	
	_bkup = {
		g = hack:Copy( g );
		r = hack:Copy( r );
	};
	
	function g.pairs( tbl )
		if( IsTable( tbl ) ) then
			return _bkup.g.pairs( hack:Copy( tbl ) );
		end
		return {};
	end
	function g.ipairs( tbl )
		if( IsTable( tbl ) ) then
			return _bkup.g.ipairs( hack:Copy( tbl ) );
		end
		return {};
	end
	function g.type( o )
		return _bkup.g.type( hack:Copy( o ) );
	end
	if( g.table ) then
		function g.table.Copy( tbl )
			return hack:Copy( tbl );
		end
	end
end

hack:Log( "Loaded at %s", g.tostring( g.os.date( "%D at %H", g.os.time() ) ) );

// Hooking

function hack:SetupHook( hn )
	if( self.hooks[hn] ) then
		return;
	end
	self.hooks[hn] = {};
	self.hooks[hn].Hooks = {};
	self.hooks[hn].paused = false;
	function self.hooks[hn]["Add"]( hfn, func )
		self.Hooks[hfn] = func;
		hack:Log( "Added hook %s to %s", hfn, hn );
	end
	function self.hooks[hn]["Remove"]( obj )
		local hfn = "NULL";
		if( IsString( obj ) ) then
			if( self.Hooks[obj] ) then
				self.Hooks[obj] = nil;
				hfn = obj;
			end
		elseif( IsFunction( obj ) ) then
			for name, func in g.pairs( self.Hooks ) do
				if( func == obj ) then
					self.Hooks[name] = nil;
					hfn = name;
				end
			end
		else
			hack:Log( "Failed to remove hook in %s with given data", hn );
			return;
		end
		hack:Log( "Removed hook %s from %s", hfn, hn );
	end
end

function hack:RemoveHook( hn )
	if( self.hooks[hn] ) then
		self.hooks[hn] = nil;
		hack:Log( "Removed hook %s", hn );
	end
end

function hack:PauseHook( hn )
	if( self.hooks[hn] ) then
		self.hooks[hn].paused = true;
		hack:Log( "Paused hook %s", hn );
	end
end

function hack:UnpauseHook( hn )
	if( self.hooks[hn] ) then
		self.hooks[hn].paused = false;
		hack:Log( "Unpaused hook %s", hn );
	end
end

function hack:PanicHooks()
	for hn, data in g.pairs( self.hooks ) do
		self:PauseHook( hn );
	end
end

function hack:ResumeHooks()
	for hn, data in g.pairs( self.hooks ) do
		self:PauseHook( hn );
	end
end

function hack:CallHooks( hn, ... )
	if( !self.hooks[hn] ) then
		return;
	end
	local ret = nil;
	for name, func in g.pairs( self.hooks[hn] ) do
		local tret = func( g.unpack( {...} ) );
		if( tret != nil && ret == nil ) then
			ret = tret;
		end
	end
	if( ret ) then
		return ret;
	end
end

// Binding

function hack:BindKey( name, var, key, toggle, dopress, dorelease )
	if( self.binds[key] ) then
		self.binds[key] = {};
	end
	hack:Log( "Bound variable %s to key %i", name, key );
	self.binds[key].name = name;
	self.binds[key].var = var;
	self.binds[key].toggled = false;
	self.binds[key].cantoggle = true;
	self.binds[key].nextpress = 0;
	function self.binds[key]["IncrementDelay"]( time )
		self.binds[key].nextpress = g.CurTime() + ( time || 0.15 );
	end
	function self.binds[key]["KeyPressed"]()
		if( !self.cantoggle ) then
			return;
		end
		if( toggle != nil && toggle == true ) then
			if( g.CurTime() >= self.nextpress ) then
				self.toggled = !self.toggled;
				self.cantoggle = false;
				self:IncrementDelay();
			end
		else
			if( g.CurTime() >= self.nextpress ) then
				self.var = dopress || true;
				self.cantoggle = false;
				self:IncrementDelay();
			end
		end
	end
	function self.binds[key]["KeyReleased"]()
		if( toggle != nil && toggle == true ) then
			self.cantoggle = true;
		else
			self.var = dorelease || false;
			self.cantoggle = true;
		end
	end
end

function hack:UnbindKey( obj )
	if( IsNumber( obj ) ) then
		hack:Log( "Unbound variable %s from key %i", self.binds[obj].name, obj );
		self.binds[obj] = nil;
	elseif( IsString( obj ) ) then
		for key, data in g.pairs( self.binds ) do
			if( data.name == obj ) then
				hack:Log( "Unbound variable %s from key %i", data.name, key );
				self.binds[key] = nil;
				break;
			end
		end
	end
end

function hack:KeyInput()
	for key, data in g.pairs( self.binds ) do
		if( g.input.IsKeyDown( key ) ) then
			data:KeyPressed();
		else
			data:KeyReleased();
		end
	end
end

// Vars

function hack:AddVar( cvar, val, desc )
	if( self.cvars[cvar] ) then
		return;
	end
	self.cvars[cvar] = {
		value = val,
		desc = desc,
	};
	function self.cvars[cvar]["GetValue"]()
		return self.value;
	end
	function self.cvars[cvar]["GetBool"]()
		return g.tobool( self.value ) || false;
	end
	function self.cvars[cvar]["GetDesc"]()
		return self.desc;
	end
	function self.cvars[cvar]["SetValue"]( new )
		self.value = new;
	end
end

function hack:RemoveVar( cvar )
	if( self.cvars[cvar] ) then
		self.cvars[cvar] = nil;
	end
end

function hack:GetVar( var )
	if( self.cvars[var] ) then
		return self.cvars[var];
	end
	return {};
end

// Hook events

local HOOKCALL 		= nil;
local HOOKFUNC		= nil;
local HOOKEDFUNC	= nil;
local HOOKUPVALUE 	= 0;

local function detour_CallHook( name, gm, ... )
	g.debug.sethook();
	local ret = hack:CallHooks( name );
	local ret_temp = HOOKCALL( name, gm, ... );
	if( ret == nil ) then
		ret = ret_temp;
	end
	if( ret != nil ) then
		return ret;
	end
end

local function GetCurrentHookCall()
	return g.rawget( "hook", "Call" ) || hook.Call || nil;
end

local function NewHookFunc()
	local func = detour_CallHook;
	HOOKFUNC = detour_CallHook;
end

NewHookFunc();

function hack:HasDetour()
	local HF = GetCurrentHookCall();
	if( HF != nil ) then
		if( HF == HOOKFUNC ) then
			return true;
		end
		if( HOOKUPVALUE && HOOKUPVALUE != 0 ) then
			local name, value = g.debug.getupvalue( HF, HOOKUPVALUE );
			if( name ) then
				if( value == HOOKFUNC ) then
					return true;
				end
			end
		end
		local btrig = false;
		local n, v;
		local i = 1;
		while( true ) do
			n, v = g.debug.getupvalue( HF, i );
			if( n == nil ) then
				break;
			end
			if( v == HOOKFUNC ) then
				btrig = true;
				HOOKUPVALUE = i;
				break;
			end
			i = i + 1;
		end
		return btrig;
	end
	return false;
end

function hack:DetourHookCall()
	if( self:HasDetour() == false ) then
		HOOKCALL = GetCurrentHookCall();
		NewHookFunc();
		g.rawset( "hook", "Call", HOOKFUNC );
		if( GetCurrentHookCall() != HOOKFUNC ) then
			local meta = g.debug.getmetatable( hook );
			if( meta ) then
				g.debug.setmetatable( hook, {} );
			end
			_G.hook.Call = HOOKFUNC;
			if( meta ) then
				g.debug.setmetatable( hook, meta );
			end
		end
	end
end

// Entity Data

do
	local ENT_LIST = {};
	local function NewEntityType( name, func )
		ENT_LIST[name] = func;
	end
	hack.NewEntityType = NewEntityType;
end

do
	local function CreateNewEntity()
	
	end
end
local ENT_TYPES = {
	["Player"] = function( pl )
		local data = hack.entdata[pl];
		if( Name && IsFunction( Name ) ) then
			data.Name = g.tostring( Name( pl ) );
		end
		if( Health && IsFunction( Health ) ) then
			data.Health = g.tonumber( Health( pl ) );
		end
		if( GetActiveWeapon && IsFunction( GetActiveWeapon ) ) then
			local w = GetActiveWeapon( pl );
			if( w && IsValid( w ) ) then
				data.Weapon = g.tostring( w:GetPrintName() || "NULL" );
			end
		end
		if( r.Player.Alive && IsFunction( r.Player.Alive ) ) then
			data.Alive = r.Player.Alive( pl );
		end
		if( r.Player.IsAdmin && IsFunction( r.Player.IsAdmin ) ) then
			data.IsAdmin 	= r.Player.IsAdmin( pl );
			data.Rank		= "Admin";
		end
		if( r.Entity.GetMoveType && IsFunction( r.Entity.GetMoveType ) ) then
			data.Movetype = r.Entity.GetMoveType( pl );
		end
		if( r.Entity.EntIndex && IsFunction( r.Entity.EntIndex ) ) then
			data.Index = r.Entity.EntIndex( pl );
		end
		function data:IsAlive()
			if( self.Alive == false ) then return false; end
			if( self.Health >= 0 ) then return false; end
			return true;
		end
		function data:IsValidTarget()
			if( self:IsAlive() == false ) then return false; end
			if( self.Movetype == -1 || self.Movetype == 0 || self.Movetype == 10 ) then return false; end
			return true;
		end
	end,
	["NPC"] = function( npc )
		local data = hack.entdata[npc];
		if( r.Entity.GetClass && IsFunction( r.Entity.GetClass ) ) then
			data.Name = g.tostring( r.Entity.GetClass( npc ) );
		end
		if( r.Entity.GetMoveType && IsFunction( r.Entity.GetMoveType ) ) then
			data.Movetype = r.Entity.GetMoveType( npc );
		end
		if( r.Entity.EntIndex && IsFunction( r.Entity.EntIndex ) ) then
			data.Index = r.Entity.EntIndex( npc );
		end
		function data:IsAlive()
			if( self.Movetype == 0 ) then return false; end
			return true;
		end
		function data:IsValidTarget()
			if( self:IsAlive() == false ) then return false; end
			if( self.Movetype == -1 || self.Movetype == 0 || self.Movetype == 10 ) then return false; end
			return true;
		end
	end,
	["Entity"] = function( ent )
		local data = hack.entdata[ent];
		if( r.Entity.GetClass && IsFunction( r.Entity.GetClass ) ) then
			data.Name = g.tostring( r.Entity.GetClass( ent ) );
		end
		if( r.Entity.GetMoveType && IsFunction( r.Entity.GetMoveType ) ) then
			data.Movetype = r.Entity.GetMoveType( ent );
		end
		if( r.Entity.EntIndex && IsFunction( r.Entity.EntIndex ) ) then
			data.Index = r.Entity.EntIndex( ent );
		end
		function data:IsAlive()
			if( self.Movetype == 0 ) then return false; end
			return true;
		end
		function data:IsValidTarget()
			if( self:IsAlive() == false ) then return false; end
			if( self.Movetype == -1 || self.Movetype == 0 || self.Movetype == 10 ) then return false; end
			return true;
		end
	end,
};

function hack:CollectData( ent )
	if( !self.entdata[ent] ) then
		self.entdata[ent] 					= {};
		self.entdata[ent].Name				= "NULL";
		self.entdata[ent].Health			= -1;
		self.entdata[ent].Weapon			= "NULL";
		self.entdata[ent].Alive				= false;
		self.entdata[ent].IsAdmin			= false;
		self.entdata[ent].Rank				= "NULL";
		self.entdata[ent].Movetype			= -1;
		self.entdata[ent].Index				= -1;
	end
end






























































