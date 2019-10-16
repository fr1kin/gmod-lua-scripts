require( 'herpes' );

local convars = {
	["sv_cheats"] = { "0", FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT },
	["host_timescale"] = { "1.0", FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT },
	["r_drawparticles"] = { "1", FCVAR_CLIENTDLL | FCVAR_CHEAT },
	["r_drawothermodels"] = { "1", FCVAR_CLIENTDLL | FCVAR_CHEAT },
	["sv_consistency"] = { "1", FCVAR_REPLICATED },
	["mat_fullbright"] = { "0", FCVAR_CHEAT },
	["sv_allow_voice_from_file"] = { "0", FCVAR_CHEAT },
	["voice_inputfromfile"] = { "0", FCVAR_CHEAT },
	["r_drawskybox"] = { "1", FCVAR_NONE },
	["r_3dsky"] = { "1", FCVAR_NONE },
}

local function CreateCommands()
	for k, v in pairs( convars ) do
		if ( ConVarExists( k ) && !ConVarExists( "____" .. k ) ) then
			local name, newName, flags, value = k, string.format( "____%s", k ), v[2], v[1];
			//_lua.ReplicateVar( name, newName, flags, value );
		end
	end
end

if( !MaxPlayers ) then
	CreateCommands();
end