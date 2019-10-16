// I have to much time on my hands.
timer.Simple( 0.1, function()
	for i = 1, 1000 do
		Msg( "\n" )
	end
	print( [[
		   __ __                        
		  / // /___  ____ __ _  ___  ___
		 / _  // -_)/ __//  ' \/ -_)(_-<
		/_//_/ \__//_/  /_/_/_/\__//___/
	]] )
end )

local Crypt = {}
Crypt.alphabet = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
Crypt.key = {}
Crypt.code = "dongs"

-- Set Password here:
Crypt.password = { "h", "a", "c", "k" }

function Crypt.Random( key )
	local l = math.random( 65, 90 )
	
	local char = ""
	for i = 1, math.random( 5, 10 ) do
		char = char .. table.Random( Crypt.alphabet )
	end
	return char
end

function Crypt.SetKeys()
	for k, v in pairs( Crypt.alphabet ) do
		Crypt.key[ v ] = Crypt.Random( v )
	end
end
Crypt.SetKeys()

function Crypt.SetPassword()
	Crypt.code = ""
	for k, v in pairs( Crypt.password ) do
		for u, e in pairs( Crypt.key ) do
			if ( string.lower( v ) == string.lower( u ) ) then
				Crypt.code = Crypt.code .. e
			end
		end
	end
	return tostring( Crypt.code )
end

-- Print password
timer.Simple( 0.1, function()
	print( Crypt.SetPassword() )
end )