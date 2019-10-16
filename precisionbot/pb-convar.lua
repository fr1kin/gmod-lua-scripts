function PB:CreateClientConVar( cvar, val, max, min, tblname, dec )
	local ply, bool, addCvar = LocalPlayer(), false, CreateClientConVar( "pb_" .. cvar, val, true, false )
	if ( type( val ) == "boolean" ) then
		val = ( val && 1 || 0 ); bool = true
	end
	
	if ( bool ) then
		PB.Features[tblname] = util.tobool( addCvar:GetInt() )
	elseif ( type( val ) == "number" ) then
		if ( !dec ) then
			PB.Features[tblname] = addCvar:GetInt()
		else
			PB.Features[tblname] = tonumber( addCvar:GetString() )
		end
	elseif ( type( val ) == "string" ) then
		PB.Features[tblname] = addCvar:GetString()
	end
	
	table.insert( PB.ConVars, cvar )
	
	cvars.AddChangeCallback( cvar , function( cvar, old, new )
		if booltype then
			PB.Features[tblname] = util.tobool( math.floor( new ) )
		else
			PB.Features[tblname] = new
		end
	end )
	
	return addCvar
end