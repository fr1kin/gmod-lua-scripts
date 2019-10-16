print( "Creating random shit" );

//PrintTable( _G );

if( _G.hook ) then
	print( "hi _G" );
end

if( hook ) then
	print( "hi" );
end

local pt = print;
function print(...)
	pt(...);
end

HELLO = 1;
GOODBYE = 2;

CYA = 3;

HEY = {
	LOL = 2,
	WOW = "!!!",
};