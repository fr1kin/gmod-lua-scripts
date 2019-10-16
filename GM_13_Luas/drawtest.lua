/*
function Penis( )
	cam.Start3D( EyePos(), EyeAngles() )
		for k, pl in pairs( player.GetAll() ) do
			if pl && IsValid( pl ) && pl:Alive() && pl != LocalPlayer() then
				local tr = pl:GetEyeTrace();
				local color = team.GetColor( pl:Team() );
				render.DrawLine( pl:GetShootPos(), tr.HitPos, color, true );
			end
		end
	cam.End3D()
end
hook.Add( "RenderScreenspaceEffects", "Penis", Penis )
*/

local red = Color( 255, 0, 0, 255 );
local green = Color( 0, 255, 0, 255 );
local blue = Color( 0, 0, 255, 255 );
local yellow = Color( 255, 255, 0, 255 );

local function FormatMessage( color, msg, str, indent )
	//Msg( string.rep ("\t", indent) )
	//MsgC( color || red, msg .. "\n" );
	str = str .. string.rep ("\t", indent) .. msg .. "\n";
	return str;
end

local function PrintInfo( name )
	local tab = _G[name]
	if( !tab ) then print( "failed" ) return; end
	local full = "";
	local function scan( tbl, data, indent )
		data = data || {};
		indent = indent || 0;
		for k, v in pairs( tbl ) do
			if( type( v ) == "table" && !data[v] ) then
				local num = 0;
				for p, n in pairs( v ) do
					num = num + 1;
				end
				full = FormatMessage( red, k, full, indent );
				full = FormatMessage( yellow, "type : " .. tostring( type( v ) || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "size : " .. tostring( table.Count( v ) || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "first size only : " .. tostring( num || "NULL" ), full, indent + 1 );
				if( debug.getmetatable( v ) ) then
					full = FormatMessage( yellow, "has metatable", full, indent + 1 );
				else
					full = FormatMessage( yellow, "no metatable", full, indent + 1 );
				end
				data[v] = true;
				scan( v, data, indent + 2 );
			else
				local info = ( v && type( v ) == "function" ) && debug.getinfo( v ) || {};
				full = FormatMessage( red, k, full, indent  );
				full = FormatMessage( yellow, "source: " .. tostring( info.source || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "short_src: " .. tostring( info.short_src || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "what : " .. tostring( info.what || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "namewhat  : " .. tostring( info.namewhat || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "nups : " .. tostring( info.nups  || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "func : " .. tostring( info.func || "NULL" ), full, indent + 1 );
				full = FormatMessage( yellow, "type : " .. tostring( type( v ) || "NULL" ), full, indent + 1 );
				
				local name, value = nil, nil;
				local infostr = "";
				local index = 1;
				if( type( v ) == "function" ) then
					while( true ) do
						name, value = debug.getlocal( v, index );
						if( name == nil ) then
							break;
						end
						infostr = infostr .. " (" .. index .. ")" .. "[name="..(name || "NULL") .. "][value=" .. (value || "NULL") .. "]";
						index = index + 1;
					end
				end
				full = FormatMessage( yellow, "locals : " .. tostring( infostr || "NULL" ), full, indent + 1 );
				
				local name, value = nil, nil;
				local infostr = "";
				local index = 1;
				if( type( v ) == "function" ) then
					while( true ) do
						name, value = debug.getupvalue( v, index );
						if( name == nil ) then
							break;
						end
						local valstr = tostring( value );
						if( type( value ) == "table" ) then
							valstr = "{";
							for key, val in pairs( value ) do
								valstr = valstr .. string.rep ("\t", indent + 2) .. tostring( key ) .. " = " .. tostring( val ) .. "\n";
							end
							valstr = valstr .. "}";
						end
						infostr = infostr .. " (" .. index .. ")" .. "[name="..(name || "NULL") .. "][value=" .. (valstr || "NULL") .. "]";
						index = index + 1;
					end
				end
				full = FormatMessage( yellow, "upvalues: " .. tostring( infostr || "NULL" ), full, indent + 1 );
			end
		end
	end
	if( type( tab ) == "table" ) then
		local num = 0;
		for k, v in pairs( tab ) do
			num = num + 1;
		end
		full = FormatMessage( red, name, full, 0  );
		full = FormatMessage( yellow, "type : " .. tostring( type( tab ) || "NULL" ), full, 2 );
		full = FormatMessage( yellow, "size : " .. tostring( table.Count( tab ) || "NULL" ), full, 2 );
		full = FormatMessage( yellow, "first size only : " .. tostring( num || "NULL" ), full, 2 );
		if( debug.getmetatable( tab ) ) then
			full = FormatMessage( yellow, "has metatable", full, 2 );
		else
			full = FormatMessage( yellow, "no metatable", full, 2 );
		end
		scan( tab );
	elseif( type( tab ) == "function" ) then
		local info = ( tab && type( tab ) == "function" ) && debug.getinfo( tab ) || {};
		local indent = 0;
		full = FormatMessage( red, name, full, indent  );
		full = FormatMessage( yellow, "source: " .. tostring( info.source || "NULL" ), full, indent + 1 );
		full = FormatMessage( yellow, "short_src: " .. tostring( info.short_src || "NULL" ), full, indent + 1 );
		full = FormatMessage( yellow, "what : " .. tostring( info.what || "NULL" ), full, indent + 1 );
		full = FormatMessage( yellow, "namewhat  : " .. tostring( info.namewhat || "NULL" ), full, indent + 1 );
		full = FormatMessage( yellow, "nups : " .. tostring( info.nups  || "NULL" ), full, indent + 1 );
		full = FormatMessage( yellow, "func : " .. tostring( info.func || "NULL" ), full, indent + 1 );
		full = FormatMessage( yellow, "type : " .. tostring( type( tab ) || "NULL" ), full, indent + 1 );
		
		local name, value = nil, nil;
		local infostr = "";
		local index = 1;
		if( type( tab ) == "function" ) then
			while( true ) do
				name, value = debug.getlocal( tab, index );
				if( name == nil ) then
					break;
				end
				infostr = infostr .. " (" .. index .. ")" .. "[name="..(name || "NULL") .. "][value=" .. (value || "NULL") .. "]";
				index = index + 1;
			end
		end
		full = FormatMessage( yellow, "locals : " .. tostring( infostr || "NULL" ), full, indent + 1 );
		
		local name, value = nil, nil;
		local infostr = "";
		local index = 1;
		if( type( tab ) == "function" ) then
			while( true ) do
				name, value = debug.getupvalue( tab, index );
				if( name == nil ) then
					break;
				end
				local valstr = tostring( value );
				if( type( value ) == "table" ) then
					valstr = "{";
					for key, val in pairs( value ) do
						valstr = valstr .. string.rep("\t", indent + 2) .. tostring( key ) .. " = " .. tostring( val ) .. "\n";
					end
					valstr = valstr .. "}";
				end
				infostr = infostr .. " (" .. index .. ")" .. "[name="..(name || "NULL") .. "][value=" .. (valstr || "NULL") .. "]";
				index = index + 1;
			end
		end
		full = FormatMessage( yellow, "upvalues: " .. tostring( infostr || "NULL" ), full, indent + 1 );
	end
	
	file.Write( name .. ".txt", full );
end

PrintInfo( "hook" );

PrintInfo( "concommand" );

PrintInfo( "debug" );

PrintInfo( "file" );

PrintInfo( "cvars" );

//PrintInfo( "InjectConsoleCommand" );

/*
hook

Call	=	function: 0x24a39120
Run	=	function: 0x24a1bd20
_M:
		Call	=	function: 0x24a39120
		Run	=	function: 0x24a1bd20
		_M	=	table: 0x24a3a418
		Remove	=	function: 0x24a1bd00
		GetTable	=	function: 0x24a385c8
		_NAME	=	hook
		Add	=	function: 0x24a1bc58
		_PACKAGE	=	
		Hooks:
				
Remove	=	function: 0x24a1bd00
GetTable	=	function: 0x24a385c8
_NAME	=	hook
Add	=	function: 0x24a1bc58
_PACKAGE	=	
Hooks	=	table: 0x24a3a440
Size: 	9



concommand

Run	=	function: 0x1bb6ec88
_M:
		Run	=	function: 0x1bb6ec88
		_M	=	table: 0x1bb6eb20
		Remove	=	function: 0x1bb6ec60
		AutoComplete	=	function: 0x1bb6eca8
		_NAME	=	concommand
		GetTable	=	function: 0x1bb6eb98
		Add	=	function: 0x1bb6ebf8
		_PACKAGE	=	
Remove	=	function: 0x1bb6ec60
AutoComplete	=	function: 0x1bb6eca8
_NAME	=	concommand
GetTable	=	function: 0x1bb6eb98
Add	=	function: 0x1bb6ebf8
_PACKAGE	=	
Size: 	8



debug

setupvalue	=	function: builtin#129
getregistry	=	function: builtin#120
traceback	=	function: builtin#135
setlocal	=	function: builtin#127
Trace	=	function: 0x1bb6cd10
getfenv	=	function: builtin#123
getlocal	=	function: builtin#126
upvaluejoin	=	function: builtin#131
getupvalue	=	function: builtin#128
setfenv	=	function: builtin#124
setmetatable	=	function: builtin#122
sethook	=	function: builtin#132
gethook	=	function: builtin#133
debug	=	function: builtin#134
getmetatable	=	function: builtin#121
getinfo	=	function: builtin#125
upvalueid	=	function: builtin#130
Size: 	17



file

Exists	=	function: 0x249e5270
Write	=	function: 0x24a80f88
Append	=	function: 0x24a4d990
Time	=	function: 0x249e53b0
IsDir	=	function: 0x249e52b0
Size	=	function: 0x249e53f0
Read	=	function: 0x24a93450
Delete	=	function: 0x249e5330
CreateDir	=	function: 0x249e5370
Find	=	function: 0x249e52f0
Open	=	function: 0x249e5430
Size: 	11



cvar

GetConVarCallbacks	=	function: 0x24a6dfa0
OnConVarChanged	=	function: 0x24a6dfe0
Number	=	function: 0x24a478b0
_M:
		GetConVarCallbacks	=	function: 0x24a6dfa0
		OnConVarChanged	=	function: 0x24a6dfe0
		Number	=	function: 0x24a478b0
		_M	=	table: 0x24a6e0f8
		String	=	function: 0x24a6df58
		_NAME	=	cvars
		Bool	=	function: 0x24a479c0
		_PACKAGE	=	
		AddChangeCallback	=	function: 0x24a6e020
String	=	function: 0x24a6df58
_NAME	=	cvars
Bool	=	function: 0x24a479c0
_PACKAGE	=	
AddChangeCallback	=	function: 0x24a6e020
Size: 	9

*/

/*
StartPos	=	-1190.875000 -1475.125000 -79.875000
HitNoDraw	=	false
HitBox	=	0
HitNonWorld	=	false
HitGroup	=	0
HitPos	=	-2815.968750 -1156.734985 -130.895508
FractionLeftSolid	=	0
StartSolid	=	false
Hit	=	true
HitWorld	=	true
SurfaceProps	=	35
Normal	=	-0.980877 0.192175 -0.030795
HitSky	=	false
MatType	=	67
PhysicsBone	=	0
HitTexture	=	BRICK/BRICKWALL003A_CONSTRUCT
HitNormal	=	1.000000 0.000000 0.000000
Entity	=	Entity [0][worldspawn]
Fraction	=	0.050560776144266
StartPos	=	-1190.875000 -1475.125000 -79.875000
HitNoDraw	=	false
*/