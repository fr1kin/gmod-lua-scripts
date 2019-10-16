// dumb
local function FUNC_NULL()
	return;
end

concommand.Add( "test_debug_callbacks", function()
	local iNum = 1;
	local bGotNil = false;
	while( bGotNil == false ) do
		local ret = debug.getinfo(iNum);
		if( ret == nil ) then
			bGotNil = true;
			MsgN( string.format( "\nReturn Number #%i is nil, ignoring...\n", iNum ) );
		else
			MsgN( string.format( "\nReturn Number #%i:", iNum ) );
			PrintTable( ret );
			
			iNum = iNum + 1;
		end
	end
	
	local dbg_test = {
		include || FUNC_NULL,
		require || FUNC_NULL,
		debug.getinfo || FUNC_NULL,
		hook.Call || FUNC_NULL,
	}
	
	for k, v in pairs( dbg_test ) do
		local ret = debug.getinfo(v);
		if( ret == nil ) then
			MsgN( string.format( "\nFunction #%i is nil.\n", k ) );
		else
			MsgN( string.format( "\nReturn Function #%i:", k ) );
			PrintTable( ret );
		end
	end
end )




