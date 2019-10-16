
local ENV = {};

ENV = table.Copy( _G );

ENV.VERSION = 0.1;

print( "ENV:", ENV ); 
print( "GLOBAL:", _G ); 

setfenv( 0, ENV );

// *********************************
// setfenv on function
// *********************************

// Level 0 = Global
// Level 1 = This script file
--[[
function atestfunction()
	print( "Testing everything..." );
	print( "Current ENV: ", getfenv(1) );
	local cpy = table.Copy( getfenv(1) );
	cpy.howmuchwood = 10;
	setfenv( 1, cpy );
	if( _G ) then
		print( "I still have access!" );
	else
		print( "I dont have access!" );
	end
	if( lvltwo ) then
		print( "This is here" );
	else
		print( "Crap" );
	end
	if( howmuchwood ) then
		print( "I can give ", howmuchwood );
	else
		print( "I cant give" );
	end
	function anothertestfunction()
		print( "Round two: ", getfenv(2) );
		if( howmuchwood ) then
			print( "(lvl2) I can give ", howmuchwood );
		else
			print( "(lvl2) I cant give" );
		end
	end
	anothertestfunction();
end

atestfunction();

local newenv = {};
newenv = table.Copy( _G );
newenv.print = function(...) print( "[The Hacker]: ", ... ) end
newenv.lvltwo = true;

print( "NEW ENV: ", newenv );

setfenv( atestfunction, newenv );

atestfunction();

if( lvltwo ) then
	print( "Level 2 (Outside) exists" );
else
	print( "Level 2 (Outside) does not exist" );
end

if( howmuchwood ) then
	print( "None" );
end
]]
// *********************************
// Loading filez
// *********************************

local function CopySandBoxEnvirnment( env )
	local NEW_ENV = {};
	debug.setmetatable( NEW_ENV, { __index = _G } );
	return NEW_ENV;
end

local function LoadFile( f )
	local oEnv = getfenv(0);
	setfenv( 0, CopySandBoxEnvirnment( oEnv ) );
	include( f );
	local ret = getfenv(0);
	setfenv( 0, oEnv );
	return ret;
end

local STUFF = LoadFile( "test_file02.lua" );

PrintTable( STUFF );
if( STUFF.HELLO ) then
	print( "Hello" );
else
	print( "not hello" );
end


// *********************************

print( "Global env: ", _G );
print( "Current env (0): ", getfenv(0) );
print( "Current env (1): ", getfenv(1) );
print( "VERSION: ", VERSION );
print( "_G.VERSION: ", _G.VERSION );


































