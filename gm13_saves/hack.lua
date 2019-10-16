
/*
local function Hook( ... )
	local args = {...};
	
	local name = debug.getinfo (2, "n").name;
	
	if( name == "GetConVarNumber" ) then
		PrintTable( debug.getinfo(2) );
		local func = debug.getinfo(2).func;
		
		print( "## UPVALUES ##" )
		local i = 1;
		while( true ) do
			local n, v = debug.getupvalue( func, i );
			if( n == nil || v == nil ) then
				break;
			end
			print( func, n, v )
			i = i + 1;
		end
		
		print( "## LOCALS ##" )
		i = 1;
		while( true ) do
			local n, v = debug.getlocal( 2, i );
			if( n == nil || v == nil ) then
				break;
			end
			print( func, n, v )
			//print( "test...", debug.setlocal( 2, i, "you are gay" ) );
			i = i + 1;
		end
		
		print( "END" );
		debug.sethook();
	end
end
*/


/*
debug.setmetatable( _G, {
		__index = function( t, k )
			if( k == "SCRIPTNAME" || k == "SCRIPTPATH" ) then
				local i = 1;
				while( true ) do
					local info = debug.getinfo(i);
					if( !info ) then break; end
					print( "\n#################### INDEX ####################\n LEVEL = ", i, "\n" );
					PrintTable( info );
					i = i + 1;
				end
			end
		end,
		__newindex = function( t, k, v )
			if( k == "SCRIPTNAME" || k == "SCRIPTPATH" ) then
				local i = 1;
				while( true ) do
					local info = debug.getinfo(i);
					if( !info ) then break; end
					print( "\n#################### NEWINDEX ####################\n LEVEL = ", i, "\n" );
					PrintTable( info );
					i = i + 1;
				end
			end
		end,
	}
)
*/

local ignore = {
	["SuperDOFWindow"] = true,
	["g_ClientSaveDupe"] = true,
}

setmetatable( _G.hook, {
		__index = function( t, k )
			if( !ignore[k] ) then
				print( "__index: ", k );
			end
		end,
		
		__newindex = function( t, k, v )
			if( !ignore[k] ) then
				print( "__newindex: ", k, v );
			end
		end,
		
		__metatable = true,
	}
)

setmetatable( _G.debug, {
		__index = function( t, k )
			if( !ignore[k] ) then
				print( "__index: ", k );
			end
		end,
		
		__newindex = function( t, k, v )
			if( !ignore[k] ) then
				print( "__newindex: ", k, v );
			end
		end,
		
		__metatable = true,
	}
)

concommand.Add( "test_hook", function()
	print( "DEBUG \n" );
	print( debug );
	print( debug.getmetatable( debug ) || { "INVALID" } );
	print( "HOOK \n" );
	print( hook );
	print( debug.getmetatable( hook ) || { "INVALID" } );
end )



concommand.Add( "test_func", function()
	print( "\n############### RUNSTRING ###############\n" );
	RunString( "print( 'test' ) " );
	print( "\n############### RUNSTRINGEX ###############\n" );
	RunStringEx( "print( 'test' ) ", "nigga" );
end )

/*
local debugCheck = {};

local function Hide( name, objects )
	debugCheck[name] = {};
	for k, v in pairs( objects ) do
		debugCheck[name][v] = true;
	end
end

Hide( "GetConVarNumber", { "gay" } );

local function debugHook( ... )
	local args = {...};
	
	local info = debug.getinfo( 2 );
	if( info && info.name && debugCheck[info.name] ) then
		print( "hello" );
		local name, value, index = 0, 0, 1;
		while( true ) do
			name, value = debug.getlocal( 2, index );
			print( name, value );
			if( name == nil || value == nil ) then 
				break; 
			end
			if( debugCheck[info.name][value] ) then
				debug.setlocal( 2, index, "some other variable depending on the type" );
			end
			index = index + 1;
		end
		debug.sethook();
	end
end

debug.sethook( debugHook, "c", 0 );

include( "test2.lua" );
*/