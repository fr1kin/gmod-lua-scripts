// Prop log

local fn = "log.txt";

local function PlayerSpawnedProp( pl, model, ent )
	for k, v in pairs( player.GetAll() ) do
		if( v:IsSuperAdmin() ) then
			//local msg = pl:Nick() .. "Spawned model"
			//v:SendLua( "if file.Exists( \"log.txt\" ) == false then file.Create( \"log.txt\", '" .. msg .. "' ) else file.Append( \"log.txt\", '" .. msg .. "' ) end" )
			//print( "if file.Exists( \"log.txt\" ) == false then file.Create( \"log.txt\", '" .. msg .. "' ) else file.Append( \"log.txt\", '" .. msg .. "' ) end" )
		end
	end
end
hook.Add( "PlayerSpawnedProp", "PlayerSpawnedProp", PlayerSpawnedProp );