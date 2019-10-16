// Herpes v5
// by fr1kin

local hack = {};

local g;
local _p;

local function Create( t )
	if( g == nil ) then
		g = {};
	end
	if( t != nil ) then
		g[t] = {};
	end
	return g;
end

local function Set( t, v )
	if( g == nil ) then
		g = {};
	end
	if( g[t] == nil ) then
		g[t] = {};
	end
	if( _p == nil ) then
		_p = {};
	end
	local pairs = ( g != nil && g.pairs != nil ) && g.pairs || pairs;
	for k, v in pairs( v ) do
		if( !_p[v] ) then
			g[t][k] = v;
			_p[v] = true;
		end
	end
end

// util functions
// ####################

Create( "utils" );

do
	// Simple type functions that will be useful later.
	
	local g = Create();
	
	local _type = type;
	local function type( o )
		return ( g != nil && g.type != nil ) && g.type( o ) || _type( o );
	end
	
	function g.isNil( o )
		return ( o == nil );
	end
	function g.isAngle( o )
		return ( type( o ) == "Angle" );
	end
	function g.isBool( o )
		return ( type( o ) == "boolean" );
	end
	function g.isEntity( o )
		return ( type( o ) == "Entity" );
	end
	function g.isFunction( o )
		return ( type( o ) == "function" );
	end
	function g.isNPC( o )
		return ( type( o ) == "NPC" );
	end
	function g.isNumber( o )
		return ( type( o ) == "number" );
	end
	function g.isPanel( o )
		return ( type( o ) == "Panel" );
	end
	function g.isPlayer( o )
		return ( type( o ) == "Player" );
	end
	function g.isString( o )
		return ( type( o ) == "string" );
	end
	function g.isTable( o )
		return ( type( o ) == "table" );
	end
	function g.isVector( o )
		return ( type( o ) == "Vector" );
	end
	
	Set( "utils", g );
end

do
	// Table related functions.
	
	local g = Create();
	
	local _setmetatable = setmetatable;
	local function setmetatable( t, c )
		return ( g != nil && g.setmetatable != nil ) && g.setmetatable( t, c ) || _setmetatable( t, c );
	end
	
	local _setmetatable = getmetatable;
	local function getmetatable( t )
		return ( g != nil && g.getmetatable != nil ) && g.getmetatable( t ) || _setmetatable( t );
	end
	
	local _pairs = pairs;
	local function pairs( t )
		return ( g != nil && g.pairs != nil ) && g.pairs( t ) || _pairs( t );
	end
	
	function g.Copy( t, _data )
		if( g.isTable( t ) ) then
			local c = {};
			setmetatable( c, getmetatable( t ) );
			for name, object in pairs( t ) do
				if( g.isTable( object ) ) then
					_data = _data || {};
					_data[ t ] = c;
					if( _data[ object ] ) then
						c[ name ] = _data[ object ];
					else
						c[ name ] = Copy( object, _data );
					end
				else
					c[ name ] = object;
				end
			end
		end
		return nil;
	end
	function g.SizeOf( t )
		if( g.isTable( t ) ) then
			local s = 0;
			for k, v in pairs( t ) do
				s = s + 1;
			end
			return 1;
		end
		return nil;
	end
	
	Set( "utils", g );
end

do
	// Other functions.
	
	local g = Create();
	
	function g.Call( f, m )
		if( g.isTable( m ) ) then
			
		end
	end
end

// global copy
// ####################

Create( "_G" );
Create( "_R" );

do
	// Copy the _G table.
	
	Set( "_G", Copy( _G ) );
	Set( "_R", Copy( debug.getregistry() ) );
end