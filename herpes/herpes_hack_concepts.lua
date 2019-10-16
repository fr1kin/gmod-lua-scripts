// Sample

local hack = {};

hack.hooks = {};
hack.keys = {};
hack.log = {};
hack.vars = {
	aiming = false,
	target = nil,
};

// IsNil - Check if something is nil
// v - object to be checking
function hack:IsNil( ... )
	local args = {...};
	for k, v in pairs( args ) do
		local arg = args[i];
		if( arg == nil ) then
			return true;
		end
	end
	return false;
end

// HasMatch - Two values are the same
// v - Value
function hack:HasMatch( v1, v2 )
	if( self:IsNil( v1, v2 ) ) then
		return false;
	end
	if( v1 == v2 ) then
		return true;
	end
	return false;
end

// Log - Logging stuff to console/text file.
// m - Message
function hack:Log( m )
	if( self:IsNil( m ) ) then
		return NULL;
	end
	MsgN( string.format( "[hack] %s", m ) );
	self.log[text] = 1;
end

// hookfunc - Hooking
// h - Hook name
// f - Function name
function hack:hookfunc( h, f )
	if( self:IsNil( h, f ) ) then
		return NULL;
	end
	
	local hooks, bHasHook = hook.GetTable(), false;
	for k, v in pairs( hooks ) do
		if( self:IsNil( k, v ) ) then
			continue;
		end
		if( self:HasMatch( h, k ) == false ) then
			continue;
		end
		
		local funcToUse, ind = NULL, NULL;
		
		while( self:IsNil( funcToUse ) || funcToUse == NULL || ind <= #v ) do
			funcToUse = table.Random( v );
			ind = ind + 1;
		end
		
		local name, func = NULL, NULL;
		
		for i, n in pairs( v ) do
			if( self:HasMatch( i, funcToUse ) || self:HasMatch( n, funcToUse ) ) then
				name, func = i, n;
			end
		end
		
		if( self:IsNil( name, func ) ) then
			return NULL;
		end
		
		local function shortFunc( ... )
			f();
			funcToUse[1]();
		end
		
		bHasHook = true;
		
		hook.Remove( name, k );
		hook.Add( k, name, shortFunc );
		
		self:Log( string.format( "Attached %s hook to function %s", h, name ) );
		
		return 1;
	end
	
	if( bHasHook == false ) then
		local s = NULL;
		for i, math.random( 5, 35 ) do
			s = tostring( s .. i );
		end
		
		hook.Add( h, s, f );
		
		self:Log( string.format( "Created new hook %s for function %s", s, f ) );
		
		return NULL;
	end
	return NULL;
end

local function HookFunc( func )
	_G[func] = function( args )
		MsgN( string.format( "Ran %s", func ) );
		return func();
	end
end