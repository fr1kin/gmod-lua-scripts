local Setup = {}
Setup.cheat = table.Copy( cheat )

Setup.CVars = {
	["sv_cheats"] = { org = "0", flags = FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT },
	["host_timescale"] = { org = "1.0", flags = FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT },
	["r_drawparticles"] = { org = "1", flags = FCVAR_CLIENTDLL | FCVAR_CHEAT },
	["r_drawothermodels"] = { org = "1", flags = FCVAR_CLIENTDLL | FCVAR_CHEAT },
	["sv_consistency"] = { org = "1", flags = FCVAR_REPLICATED },
	["mat_fullbright"] = { org = "0", flags = FCVAR_CHEAT },
	["sv_allow_voice_from_file"] = { org = "0", flags = FCVAR_CHEAT },
	["voice_inputfromfile"] = { org = "0", flags = FCVAR_CHEAT },
}

function Setup:AddCVars()
	if ( MaxPlayers ) then return end
	for k, v in pairs( Setup.CVars ) do
		if ( ConVarExists( k ) && !ConVarExists( "_hermes_" .. k ) ) then
			local name, newName, flags, value = k, string.format( "_hermes_%s", k ), v.flags, v.org
			Setup.cheat.ReplicateVar( name, newName, flags, value )
			CreateConVar( name, value, flags )
		end
	end
end

Setup:AddCVars()