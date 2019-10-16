
/*
local __old = GetConVarNumber;
function GetConVarNumber( c )
	print( "C IS", c );
	if( c == "gay" ) then
		return 123123;
	end
	return __old( c );
end
*/

CreateClientConVar( "gay", 100, false, false );

local hacker = GetConVarNumber( "gay" )

if( hacker != 100 ) then
	print( "hacker", hacker )
else
	print( "Not hacker", hacker )
end