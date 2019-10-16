
local hasloaded = false;

setmetatable( package.loaded, {
	__newindex = function( t,k,v )
		if( k == "notification" && hasloaded == false ) then
			hasloaded = true;
			lualoadfile( "client\\luastartup\\nm.lua" );
		end
		rawset( t,k,v );
	end,
})