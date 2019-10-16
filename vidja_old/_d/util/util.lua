// UTIL functions

local g, r;

local type, pairs, setmetatable, getmetatable = type, pairs, setmetatable, getmetatable;

local function IsNil( o ) 		return ( o == nil ) 					end
local function IsAngle( o ) 	return ( type( o ) == "Angle" ) 		end
local function IsBool( o ) 		return ( type( o ) == "boolean" )		end
local function IsEnt( o ) 		return ( type( o ) == "Entity" ) 		end
local function IsFunction( o ) 	return ( type( o ) == "function" )		end
local function IsNPC( o ) 		return ( type( o ) == "NPC" ) 			end
local function IsNumber( o ) 	return ( type( o ) == "number" ) 		end
local function IsPanel( o )		return ( type( o ) == "Panel" ) 		end
local function IsPlayer( o ) 	return ( type( o ) == "Player" ) 		end
local function IsString( o ) 	return ( type( o ) == "string" ) 		end
local function IsTable( o ) 	return ( type( o ) == "table" ) 		end
local function IsVec( o ) 		return ( type( o ) == "Vector" ) 		end

if( !IsTable( vidja ) ) then
	vidja = {};
end

// Type functions

vidja.IsNil			= IsNil;
vidja.IsAngle		= IsAngle;
vidja.IsBool		= IsBool;
vidja.IsEnt			= IsEnt;
vidja.IsFunction	= IsFunction;
vidja.IsNPC			= IsNPC;
vidja.IsNumber		= IsNumber;
vidja.IsPanel		= IsPanel;
vidja.IsPlayer		= IsPlayer;
vidja.IsString		= IsString;
vidja.IsTable		= IsTable;
vidja.IsVec			= IsVec;

// Module functions

vidja.mod			= MOD_GetTable();
MOD_GetTable 		= nil;

// Copying

function vidja:Copy( o, r, d )
	if( IsTable( o ) && IsNil( d[o] ) ) then
		if( !IsTable( r ) ) then r = {}; end
		if( !IsTable( d ) ) then d = {}; end
		d[o] = true;
		setmetatable( r, getmetatable( o ) );
		for key, value in pairs( o ) do
			r[key] = self:Copy( value, r, d );
		end
		return r;
	end
	return o;
end

do
	vidja:Copy( _G, g );
	vidja:Copy( debug.getregistry(), r );
end

vidja.g 			= g;
vidja.r				= r;

// UTIL functions

function vidja:SetupRandomSeed()
	g.math.randomseed( g.os.time() * 33.3333 );
end

function vidja:RandomString( min, max )
	self:SetupRandomSeed();
	local str, char, idx;
	for i = 0, g.math.random( min || 1, max || 10 ) do
		while( IsNil( char ) ) do
			idx = g.math.random( 65, 122 );
			if( idx >= 91 && idx <= 96 ) then
				continue;
			end
			char = g.string.char( idx );
		end
		str = ( str || "" ) .. char;
	end
	return str;
end

// Environment setup

function vidja:SetupEnvironment()
	local ENV 		= vidja.g;
	ENV.r			= vidja.r;
	ENV.vidja 		= vidja;
	ENV.IsNil		= IsNil;
	ENV.IsAngle		= IsAngle;
	ENV.IsBool		= IsBool;
	ENV.IsEnt		= IsEnt;
	ENV.IsFunction	= IsFunction;
	ENV.IsNPC		= IsNPC;
	ENV.IsNumber	= IsNumber;
	ENV.IsPanel		= IsPanel;
	ENV.IsPlayer	= IsPlayer;
	ENV.IsString	= IsString;
	ENV.IsTable		= IsTable;
	ENV.IsVec		= IsVec;
	g.setfenv( 2, ENV );
end





































































