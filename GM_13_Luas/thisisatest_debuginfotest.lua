// no cheaters allowed

local g, r, p, m;

local dbg_info;

// ##############################
// Util functions

local _sm, _gm, _p = debug.setmetatable, debug.getmetatable, pairs;

local function util_copy( t, s )
	if (t == nil) then return nil end
	local copy = {}
	_sm(copy, _gm(t))
	for i,v in _p(t) do
		if ( !istable(v) ) then
			copy[i] = v
		else
			s = s or {}
			s[t] = copy
			if s[v] then
				copy[i] = s[v]
			else
				copy[i] = util_copy(v,s)
			end
		end
	end
	return copy
end

local function util_settable( fn, nf, p )
	p = p || _G;
	local brk = g.string.Explode( ".", str );
	if( brk == nil ) then
		return nil;
	end
	local func = parent;
	for i = 1, #brk do
		if( create && func[brk[i]] == nil && i != #brk ) then
			func[brk[i]] = {};
		elseif( create && func[brk[i]] == nil && i == #brk ) then
			func[brk[i]] = nf || {};
		end
		func = func[brk[i]];
	end
	return func;
end

local function util_getvar( fn, p )
	p = p || _G;
	local brk = g.string.Explode( ".", fn );
	if( brk == nil ) then
		return nil;
	end
	local main = p;
	for i = 1, #brk do
		if( main[brk[i]] == nil ) then
			break;
		end
		main = main[brk[i]];
	end
	return main;
end

local function util_count( tbl )
	local idx = 0;
	for k, v in g.pairs( tbl ) do
		idx = idx + 1;
	end
	return idx;
end

local function util_match( func1, func2 )
	if( func1 == nil && func2 == nil ) then
		return true;
	end
	if( func1 == nil || func2 == nil ) then
		return false;
	end
	if( g.tostring( func1 ) == g.tostring( func2 ) ) then
		return true;
	end
	if( g.rawequal( g.tostring( func1 ), g.tostring( func2 ) ) ) then
		return true;
	end
	return false;
end

local function util_randomseed()
	g.debug.sethook();
	g.math.randomseed( g.tonumber( g.CurTime() || 0 ) + ( g.tonumber( g.os.time() || 0 ) ) );
end

local function util_randomstring( n )
	util_randomseed();
	local str = "";
	for i = 0, ( n || g.math.random( 5, 25 ) ) do
		str = str .. ( g.string.char( g.math.random( 97, 122 ) ) || "n" );
	end
	return str;
end

local function util_loadlib( lib )
	_G[lib] = nil;
	package.loaded[lib] = nil;
	package.preload[lib] = nil;
	_MODULES[lib] = nil;
	local data = g.require( lib );
	if( data ) then return; end
	g[lib] = data;
	p[lib] = data;
	m[lib] = true;
end

do
	g = util_copy( _G );
	r = util_copy( _G.debug.getregistry() || {} );
	p = util_copy( _G.package.loaded );
	m = util_copy( _G._MODULES );
	
	dbg_info = g.debug.getinfo( 1 );
	
	util_loadlib( "hook" );
	util_loadlib( "concommand" );
	util_loadlib( "cvars" );
	util_loadlib( "timer" );
	util_loadlib( "usermessage" );
end

// ##############################
// Detours

local detours = {};
detours.funcs = {};

local function AddDetour( new, old )
	detours.funcs[new] = old;
end

local function ProtectVar( var )
	detours.funcs[var] = true;
end

ProtectVar( g );
ProtectVar( r );
ProtectVar( p );
ProtectVar( m );

// ##############################
// Blacklisting

local blacklist = {};

blacklist.list = {};

blacklist.metas = {
	[_G] = true,
	[debug.getregistry()] = true,
	[hook] = true,
	[concommand] = true,
	[cvars] = true,
	[package] = true,
	[debug] = true,
};

blacklist.metamethods = {
	["__metatable"] = true,
	["__index"] = true,
	["__newindex"] = true,
	["__eq"] = true,
	["__call"] = true,
}

// doing everything manually because fuck
local function UpdateBlacklist( new )
	blacklist:UpdateList( info );
end

// ##############################
// Whitelisting

local whitelisted = {};

// FULL path to the function that you want to allow access to.
local function AddToWhitelist( path )
	whitelisted[path] = true;
end

// ================================================================================
// Adding to the whitelist
// EXAMPLE:
// AddToWhitelist( "lua/autorun/playerfuck.lua" );


// ================================================================================

local function IsWhitelisted()
	g.debug.sethook();
	local dbginfo = g.debug.getinfo( 3 );
	if( dbginfo && dbginfo.short_src ) then
		return whitelisted[dbginfo.short_src] || false;
	end
	return false;
end

ProtectVar( whitelisted );
ProtectVar( IsWhitelisted );
ProtectVar( AddToWhitelist );

// ##############################
// Detours: Debug library

function debug.getupvalue( fn, upvalue )
	if( IsWhitelisted() ) then return g.debug.getupvalue( fn, upvalue ) end
	if( detours.funcs[fn] ) then
		fn = detours.funcs[fn];
	end
	local name, value = g.debug.getupvalue( fn, upvalue );
	if( detours.funcs[value] ) then
		return nil, nil;
	end
	return name, value;
end

AddDetour( debug.getupvalue, g.debug.getupvalue );

function debug.getlocal( fn, level )
	if( IsWhitelisted() ) then return g.debug.getlocal( fn, level ) end
	if( detours.funcs[fn] ) then
		fn = detours.funcs[fn];
	end
	local name, value = g.debug.getlocal( fn, level );
	if( detours.funcs[value] ) then
		return nil, nil;
	end
	return name, value;
end

AddDetour( debug.getlocal, g.debug.getlocal );

function debug.getinfo( fn, ... )
	if( IsWhitelisted() ) then return g.debug.getinfo( fn, ... ) end
	if( g.type( fn ) == "number" ) then
		fn = fn + 1;
	end
	if( detours.funcs[fn] ) then
		fn = detours.funcs[fn];
	end
	return g.debug.getinfo( fn, ... );
end

AddDetour( debug.getinfo, g.debug.getinfo );

function debug.setmetatable( tbl, new )
	if( IsWhitelisted() ) then return g.debug.setmetatable( tbl, new ) end
	return g.setmetatable( tbl, new );
end

AddDetour( debug.setmetatable, g.debug.setmetatable );

function debug.getmetatable( tbl )
	if( IsWhitelisted() ) then return g.debug.getmetatable( tbl ) end
	return g.getmetatable( tbl );
end

AddDetour( debug.getmetatable, g.debug.getmetatable );

function debug.getregistry()
	if( IsWhitelisted() ) then return g.debug.getregistry() end
	return util_copy( g.debug.getregistry() );
end

AddDetour( debug.getregistry, g.debug.getregistry );

// ##### hook library #####

function hook.GetTable()
	if( IsWhitelisted() ) then return g.hook.GetTable( tbl ) end
	return util_copy( g.hook.GetTable( tbl ) );
end

AddDetour( hook.GetTable, g.hook.GetTable );

// ##### concommand library #####

function concommand.GetTable()
	if( IsWhitelisted() ) then return g.concommand.GetTable( tbl ) end
	return util_copy( g.concommand.GetTable( tbl ) );
end

AddDetour( concommand.GetTable, g.concommand.GetTable );

// ##### global functions #####

function setmetatable( tbl, new )
	if( IsWhitelisted() ) then return g.setmetatable( tbl, new ) end
	if( blacklist.metas[tbl] ) then
		return nil;
	end
	return g.setmetatable( tbl, new );
end

AddDetour( setmetatable, g.setmetatable );

function getmetatable( tbl )
	if( IsWhitelisted() ) then return g.getmetatable( tbl ) end
	if( blacklist.metas[tbl] ) then
		return nil;
	end
	return g.getmetatable( tbl );
end

AddDetour( getmetatable, g.getmetatable );

function rawget( tbl, key )
	if( IsWhitelisted() ) then return g.rawget( tbl, key ) end
	if( blacklist.metamethods[key] ) then
		return nil;
	end
	return g.rawget( tbl, key );
end

AddDetour( rawget, g.rawget );

function rawset( tbl, key, value )
	if( IsWhitelisted() ) then return g.rawset( tbl, key, value ) end
	if( blacklist.metamethods[key] ) then
		return nil;
	end
	g.rawset( tbl, key, value );
end

AddDetour( rawset, g.rawset );

function require( tbl )
	if( IsWhitelisted() ) then return g.require( tbl ) end
	if( !p[tbl] ) then
		local req = g.require( tbl );
		if( req ) then
			p[tbl] = util_copy( req );
			return req;
		end
	end
	return _G[tbl] || nil;
end

AddDetour( require, g.require );

function include( path )
	if( IsWhitelisted() ) then
		local preG = util_copy( _G );
		g.include( path );
	end
end

AddDetour( include, g.include );

// ##### script detection #####

local dbg = util_copy( debug );

local cpy_blacklist = util_copy( blacklist.list );

function blacklist:UpdateList( gb, rg, new )
	blacklist.list["global"] = {
		["debug"] = {
			["getupvalue"] = gb.debug.getupvalue,
			["getlocal"] = gb.debug.getlocal,
			["getinfo"] = gb.debug.getinfo,
			["setmetatable"] = gb.debug.setmetatable,
			["getmetatable"] = gb.debug.getmetatable,
		},
		["hook"] = {
			["Add"] = gb.hook.Add,
			["Remove"] = gb.hook.Remove,
			["GetTable"] = gb.hook.GetTable,
			["Call"] = gb.hook.Call,
			["Run"] = gb.hook.Run,
		},
		["file"] = {
			["Exists"] = gb.file.Exists,
			["Write"] = gb.file.Write,
			["Append"] = gb.file.Append,
			["Time"] = gb.file.Time,
			["IsDir"] = gb.file.IsDir,
			["Size"] = gb.file.Size,
			["Read"] = gb.file.Read,
			["Delete"] = gb.file.Delete,
			["CreateDir"] = gb.file.CreateDir,
			["Find"] = gb.file.Find,
			["Open"] = gb.file.Open,
		},
		["concommand"] = {
			["Run"] = gb.concommand.Run,
			["Remove"] = gb.concommand.Remove,
			["AutoComplete"] = gb.concommand.AutoComplete,
			["GetTable"] = gb.concommand.GetTable,
			["Add"] = gb.concommand.Add,
		},
		["RunConsoleCommand"] = gb.RunConsoleCommand,
		["InjectConsoleCommand"] = gb.InjectConsoleCommand,
		["setmetatable"] = gb.setmetatable,
		["getmetatable"] = gb.getmetatable,
		["rawset"] = gb.rawset,
		["rawget"] = gb.rawget,
		["rawequal"] = gb.rawequal,
		["setfenv"] = gb.setfenv,
		["getfenv"] = gb.getfenv,
		["require"] = gb.require,
		["include"] = gb.include,
		["pcall"] = gb.pcall,
		["module"] = gb.module,
	},
	blacklist.list["registry"] = {
		["ConVar"] = {
			["GetInt"] = rg.ConVar.GetInt,
			["GetFloat"] = rg.ConVar.GetFloat,
			["GetBool"] = rg.ConVar.GetBool,
			["GetString"] = rg.ConVar.GetString,
			["GetName"] = rg.ConVar.Name,
		},
		["Player"] = {
			["ConCommand"] = rg.Player.ConCommand,
		},
	},
	blacklist.list["info"] = new["info"] || {
		["debug.getinfo"] = {
			["short_src"] = "[C]",
			["what"] = "C",
			["nups"] = 0,
			["locals"] = {},
			["upvalues"] = {},
			["type"] = "function",
		},
		["hook.Call"] = {
			["short_src"] = "lua/includes/modules/hook.lua",
			["what"] = "Lua",
			["nups"] = 4,
			["locals"] = {
				[1] = {
					["name"] = "name",
				},
				[2] = {
					["name"] = "gm",
				},
			},
			["upvalues"] = {
				[1] = {
					["name"] = "gmod",
					["value"] = "table",
				},
				[2] = {
					["name"] = "pairs",
					["value"] = "function",
				},
				[3] = {
					["name"] = "isstring",
					["value"] = "function",
				},
				[4] = {
					["name"] = "IsValid",
					["value"] = "function",
				},
			},
			["type"] = "function",
		},
		["hook.Run"] = {
			["short_src"] = "lua/includes/modules/hook.lua",
			["what"] = "Lua",
			["nups"] = 0,
			["locals"] = {
				[1] = {
					["name"] = "name",
				},
			},
			["upvalues"] = {},
			["type"] = "function",
		},
		["concommand.Run"] = {
			["short_src"] = "lua/includes/modules/concommand.lua",
			["what"] = "Lua",
			["nups"] = 2,
			["locals"] = {
				[1] = {
					["name"] = "player",
				},
				[2] = {
					["name"] = "command",
				},
				[3] = {
					["name"] = "arguments",
				},
				[4] = {
					["name"] = "args",
				},
			},
			["upvalues"] = {
				[1] = {
					["name"] = "string",
					["value"] = "table",
				},
				[2] = {
					["name"] = "CommandList",
					["value"] = "table",
				},
			},
			["type"] = "function",
		},
		["cvars.GetConVarCallbacks"] = {
			["short_src"] = "lua/includes/modules/cvars.lua",
			["what"] = "Lua",
			["nups"] = 1,
			["locals"] = {
				[1] = {
					["name"] = "name",
				},
				[2] = {
					["name"] = "CreateIfNotFound",
				},
			},
			["upvalues"] = {
				[1] = {
					["name"] = "ConVars",
					["value"] = "table",
				},
			},
			["type"] = "function",
		},
		["file.Read"] = {
			["short_src"] = "lua/includes/extensions/file.lua",
			["what"] = "Lua",
			["nups"] = 0,
			["locals"] = {
				[1] = {
					["name"] = "filename",
				},
				[2] = {
					["name"] = "path",
				},
			},
			["upvalues"] = {},
			["type"] = "function",
		},
		["file.Open"] = {
			["short_src"] = "[C]",
			["what"] = "C",
			["nups"] = 0,
			["locals"] = {},
			["upvalues"] = {},
			["type"] = "function",
		},
		["RunConsoleCommand"] = {
			["short_src"] = "[C]",
			["what"] = "C",
			["nups"] = 0,
			["locals"] = {},
			["upvalues"] = {},
			["type"] = "function",
		},
		["InjectConsoleCommand"] = {
			["short_src"] = "lua/includes/modules/concommand.lua",
			["what"] = "Lua",
			["nups"] = 0,
			["locals"] = {
				[1] = {
					["name"] = "player",
				},
				[2] = {
					["name"] = "command",
				},
				[3] = {
					["name"] = "arguments",
				},
				[4] = {
					["name"] = "args",
				},
			},
			["upvalues"] = {},
			["type"] = "function",
		},
	},
	blacklist.list["convars"] = {
		["sv_allowcslua"] = 0,
		["sv_cheats"] = 0,
		["host_timescale"] = 1,
		["host_framerate"] = 0,
		["r_drawothermodels"] = 1,
	},
	blacklist.list["metas"] = {
		["_G"] = ( new && new.metas ) && new.metas._G || false,
		["_R"] = ( new && new.metas ) && new.metas._R || false,
		["hook"] = ( new && new.metas ) && new.metas.hook || false,
		["concommand"] = ( new && new.metas ) && new.metas.concommand || false,
		["package"] = ( new && new.metas ) && new.metas.package || false,
		["file"] = ( new && new.metas ) && new.metas.file || false,
	},
	blacklist.list["size"] = {
		["debug"] = ( new && new.size ) && new.size.debug || 17,
		["hook"] = ( new && new.size ) && new.size.hook || 9,
		["concommand"] = ( new && new.size ) && new.size.concommand || 8,
		["cvars"] = ( new && new.size ) && new.size.cvars || 9,
		["file"] = ( new && new.size ) && new.size.file || 11,
	},
	cpy_blacklist = util_copy( blacklist.list );
end

blacklist:UpdateList( _G, g.debug.getregistry() );

local gates = {
	[1] = function( tab )
		local caught = {};
		for cvar, default in g.pairs( tab ) do
			local value = g.tonumber( default );
			if( !g.GetConVar( cvar ) ) then
				caught[cvar] = "dne";
				continue;
			end
			if( g.tonumber( g.GetConVarNumber( cvar ) ) != value ||
				g.tonumber( g.GetConVarString( cvar ) ) != value || 
				g.tonumber( r.ConVar.GetInt( g.GetConVar( cvar ) ) != value ) || 
				g.tonumber( r.ConVar.GetFloat( g.GetConVar( cvar ) ) != value ) || 
				g.tonumber( r.ConVar.GetString( g.GetConVar( cvar ) ) != value ) ) then
				caught[cvar] = "not default";
			end
		end
		local new_cvar = g.CreateConVar( util_randomstring(), 0, FCVAR_CHEAT );
		g.RunConsoleCommand( r.ConVar.GetName( new_cvar ), 1 );
		if( g.tonumber( g.GetConVarNumber( r.ConVar.GetName( new_cvar ) ) ) != 0 ||
			g.tonumber( r.ConVar.GetInt( new_cvar ) ) != 0 ) then
			caught["sv_cheats"] = "forced";
		end
		return caught;
	end,
	[2] = function( tab )
		local caught = {};
		local function ScanGlobal( tbl, parent, data )
			data = data || {};
			parent = parent || _G;
			for name, obj in g.pairs( tbl ) do
				if( type( obj ) == "table" && !data[obj] ) then
					data[obj] = true;
					ScanGlobal( obj, parent[name], data );
				else
					if( g.type( parent[name] ) != g.type( obj ) ) then
						caught[name] = "type";
					end
					if( g.type( parent[name] ) != "table" ) then
						if( !parent[name] ) then
							caught[name] = "nil";
							continue;
						end
						if( parent[name] != obj ) then
							caught[name] = "changed";
							continue;
						end
						if( !g.rawequal( parent[name], obj ) ) then
							caught[name] = "changed";
						end
					end
				end
			end
			return caught;
		end
		return ScanGlobal( tab );
	end,
	[3] = function( tab )
		local caught = {};
		local function ScanRegistry( tbl, parent, data )
			data = data || {};
			parent = parent || g.debug.getregistry();
			for name, obj in g.pairs( tbl ) do
				if( type( obj ) == "table" && !data[obj] ) then
					data[obj] = true;
					ScanRegistry( obj, parent[name], data );
				else
					if( g.type( parent[name] ) != g.type( obj ) ) then
						caught[name] = "type";
					end
					if( g.type( parent[name] ) != "table" ) then
						if( !parent[name] ) then
							caught[name] = "nil";
							continue;
						end
						if( parent[name] != obj ) then
							caught[name] = "changed";
							continue;
						end
						if( !g.rawequal( parent[name], obj ) ) then
							caught[name] = "changed";
						end
					end
				end
			end
			return caught;
		end
		return ScanRegistry( tab );
	end,
	[4] = function( tab )
		local caught = {};
		for name, number in g.pairs( tab ) do
			local tbl = _G[name];
			if( !tbl ) then
				caught[name] = "dne";
			end
			local idx = 0;
			for key, value in g.pairs( tbl ) do
				idx = idx + 1;
			end
			if( number != idx ) then
				caught[name] = "increased";
			end
		end
		return caught;
	end,
	[5] = function( tab )
		local caught = {};
		for name, shouldhavemeta in g.pairs( tab ) do
			if( name != "_R" ) then
				tbl = _G[name];
			else
				tbl = g.debug.getregistry();
			end
			if( !tbl ) then
				caught[name] = "dne";
			end
			local meta = g.debug.getmetatable( tbl );
			if( meta && ( shouldhavemeta == false ) ) then
				caught[name] = "has meta";
			end
			if( !meta && ( shouldhavemeta == true ) ) then
				caught[name] = "no meta";
			end
		end
		return caught;
	end,
	[6] = function( tab )
		local caught = {};
		for fn, data in g.pairs( tab ) do
			local func = util_getvar( fn );
			caught[fn] = {};
			if( func == nil ||
				func && g.type( func ) != "function" ) then
				caught[fn][#caught[fn]+1] = "dne or bad type";
				continue;
			end
			local info = dbg.getinfo( func );
			if( info == nil ||
				( info != nil ) && g.type( info ) != "table" ) then
				caught[fn][#caught[fn]+1] = "no info";
				continue;
			end
			if( info.short_src == nil ||
				( info.short_src != nil ) && g.type( info.short_src ) != "string" ||
				info.what == nil ||
				( info.what != nil ) && g.type( info.what ) != "string" ||
				info.nups == nil ||
				( info.nups != nil ) && g.type( info.nups ) != "number" ) then
				caught[fn][#caught[fn]+1] = "bad info data";
				continue;
			end
			if( util_match( info.short_src, data.short_src ) == false ) then
				caught[fn][#caught[fn]+1] = "bad src";
			end
			if( util_match( info.what, data.what ) == false ) then
				caught[fn][#caught[fn]+1] = "bad what";
			end
			if( util_match( info.nups, data.nups ) == false ) then
				caught[fn][#caught[fn]+1] = "bad nups";
			end
			if( util_match( info.type, g.type( func ) == false ) ) then
				caught[fn][#caught[fn]+1] = "bad type";
			end
			for index, pdata in g.pairs( data["locals"] ) do
				local n, v = dbg.getlocal( func, index );
				if( util_match( data["locals"][index]["name"], n ) == false ) then
					caught[fn][#caught[fn]+1] = "bad local";
				end
			end
			for index, pdata in g.pairs( data["upvalues"] ) do
				local n, v = dbg.getupvalue( func, index );
				if( util_match( pdata["name"], n ) == false ) then
					caught[fn][#caught[fn]+1] = "bad upvalue";
					continue;
				end
				if( util_match( pdata["value"], g.type( v ) ) == false ) then
					caught[fn][#caught[fn]+1] = "bad upvalue";
				end
			end
			local _i, num_locals = 1, 0;
			while( true ) do
				local n, v = dbg.getlocal( func, _i );
				if( n == nil ) then
					break;
				end
				num_locals = num_locals + 1;
				_i = _i + 1;
			end
			if( util_match( util_count( data["locals"] ), num_locals ) == false ) then
				caught[fn][#caught[fn]+1] = "bad local size";
			end
			local __i, num_upvalues = 1, 0;
			while( true ) do
				local n, v = dbg.getupvalue( func, __i );
				if( n == nil ) then
					break;
				end
				num_upvalues = num_upvalues + 1;
				__i = __i + 1;
			end
			if( util_match( util_count( data["upvalues"] ), num_upvalues ) == false ) then
				caught[fn][#caught[fn]+1] = "bad upvalue size";
			end
		end
		return caught;
	end,
};

local cpy_gates = util_copy( gates );

local toscan = {
	[1] = { 
		[1] = blacklist["convars"], 
		[2] = cpy_blacklist["convars"],
	},
	[2] = { 
		[1] = blacklist["global"], 
		[2] = cpy_blacklist["global"],
	},
	[3] = { 
		[1] = blacklist["registry"], 
		[2] = cpy_blacklist["registry"],
	},
	[4] = { 
		[1] = blacklist["size"], 
		[2] = cpy_blacklist["size"],
	},
	[5] = { 
		[1] = blacklist["metas"], 
		[2] = cpy_blacklist["metas"],
	},
	[5] = { 
		[1] = blacklist["metas"], 
		[2] = cpy_blacklist["metas"],
	},
	[6] = { 
		[1] = blacklist["info"], 
		[2] = cpy_blacklist["info"],
	},
};

// Full scan, should do only once.
local function FullScan()
	util_randomseed();
	local cb = {};
	for scan, todo in g.ipairs( gates ) do
		local tbl = toscan[scan][1];
		cb[scan] = todo( tbl );
	end
	return cb;
end

// Less processing power needed to do just a single scan.
local function RandomScan()
	util_randomseed();
	local doscan, which;
	while( true ) do
		doscan, which = g.math.random( 1, 6 ), g.math.random( 1, 2 );
		if( gates[doscan] && toscan[doscan] && toscan[doscan][which] ) then
			break;
		end
	end
	if( doscan && which ) then
		local tbl = toscan[doscan][which];
		return gates[doscan]( tbl );
	end
	return false;
end

concommand.Add( "full_scan", function()
	PrintTable( FullScan() );
end )

concommand.Add( "random_scan", function()
	PrintTable( RandomScan() );
end )


/*
local SCRIPTLOADED = {
	["SCRIPTNAME"] = true,
	["SCRIPTPATH"] = true,
};

MakeSafe( SCRIPTLOADED );

SetMeta( _G, 
	{
		__index = function( tab, key )
			if( SCRIPTLOADED[key] ) then
				
			end
			return g.rawget( tab, key );
		end,
		
		__newindex = function( tab, key, value )
			if( SCRIPTLOADED[key] ) then
				
			end
			g.rawset( tab, key, value );
		end,
		
		__newindex = true,
	}
);

local i = 1;
			local loc_name, loc_value;
			while( true ) do
				loc_name, loc_value = g.debug.getlocal( func, i );
				if( loc_name == nil ) then
					break;
				end
				if( data["locals"][i] && data["locals"][i]["name"] ) then
					if( Match( data["locals"][i]["name"], loc_name ) == false ) then
						caught[fn] = "bad local";
					end
				end
				i = i + 1;
			end
			for index, pdata in g.pairs( 
			i = 1;
			loc_name, loc_value = nil, nil;
			while( true ) do
				loc_name, loc_value = g.debug.getupvalue( func, i );
				if( loc_name == nil ) then
					break;
				end
				if( data["upvalues"][i] && data["upvalues"][i]["name"] ) then
					if( Match( data["upvalues"][i]["name"], loc_name ) == false ) then
						caught[fn] = "bad upvalue";
					end
					if( Match( data["upvalues"][i]["value"], g.type( loc_value ) ) == false ) then
						caught[fn] = "bad upvalue";
					end
				end
				i = i + 1;
			end
*/






















































