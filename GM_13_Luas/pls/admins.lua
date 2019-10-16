require( "replicator" );

local factor =CreateClientConVar( "shitty_factor", 5, false, false );

concommand.Add('+noob1', function()
GetConVar('sv_cheats'):SetValue(1)
GetConVar('host_timescale'):SetValue(factor:GetFloat())

end)

concommand.Add('-noob1', function()
GetConVar('host_timescale'):SetValue(1)
end )

concommand.Add('admen_list', function()
	for k, v in pairs( player.GetAll() ) do
		if( v:IsAdmin() ) then
			print( v:Nick(), "is admin" );
		end
	end
end )