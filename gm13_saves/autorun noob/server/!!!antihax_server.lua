// "I could write a better anti-cheat with my dick tied around my ball sack."

// Change this name for the love of god for both the client and the server.
local NET_MSG = "testname";

util.AddNetworkString( NET_MSG );

// Time of ban.
// FORMATED LIKE THIS Days:Hours:Minutes
local BAN_TIME = "7:00:00";

// Ban the player?
local BAN_ON_DETECT = true;

// Log bans and shit.
local LOG = true;
local LOG_NAME = "server_anticheat_bans";

// Inform admins when a player is banned and why.
local INFORM_ADMINS = true;

local AC_INVALID                = -1;
local AC_NOEXIST                = 0;
local AC_FORCEDCVAR             = 1;
local AC_FLAGS                  = 2;

local Reasons = {
        [AC_INVALID] = "wtf",
        [AC_NOEXIST] = "sv_allowcslua doesn't exist.",
        [AC_FORCEDCVAR] = "Forced sv_allowcslua to 1.",
        [AC_FLAGS] = "Removed flags on sv_allowcslua.",
}

local HasAlerted = {};

local function InformAdmins( m )
        if( INFORM_ADMINS == false ) then return; end
        if( HasAlerted[m] == true ) then return; end

        for k, v in pairs( player.GetAll() ) do
                if( v:IsAdmin() ) then
                        v:SendLua( "chat.AddText( Color( 255, 0, 0, 255 ), '[AntiCheat] ', Color( 255, 255, 255, 255 ), '" .. m .. "' )" )
                end
        end
        HasAlerted[m] = true;
end

local HasLogged = {};

local function Log( m )
        if( LOG == false ) then return; end
        if( HasLogged[m] == true ) then return; end

        local name = string.format( "%s.txt", LOG_NAME )
        if( file.Exists( name, "DATA" ) ) then
                file.Append( name, string.format( "%s\n", m ) );
        else
                file.Write( name, string.format( "%s\n", m ) );
        end

        HasLogged[m] = true;
end

local function GetTime()
        local time = 10080; // One week
        local info = string.Explode( ":", BAN_TIME );
        if( !info ) then
                return time;
        end
        local days, hours, minutes = info[1] || 0, info[2] || 0, info[3] || 0;

        time = 0;
        if( minutes != nil ) then
                time = minutes;
        end
        if( hours != nil ) then
                time = time + ( hours * 60 );
        end
        if( days != nil ) then
                time = time + ( days * 24 * 60 );
        end
        return time;
end

local function Ban( r, pl )
        if( GetConVarNumber( "sv_allowcslua" ) != 0 ) then
                InformAdmins( string.format( "Player %s will not be banned because sv_allowcslua is set to 1 on the server.", pl:Name() != nil && pl:Name() ) );
                return;
        end

        if( BAN_ON_DETECT == true ) then
                // pl:Ban( GetTime(), "Cheating" );
        end
        // pl:Kick( "Cheating" );

        local info = string.format( "Player %s [%s][%s] was caught cheating. Reason: %s", pl:Name() != nil && pl:Name() || "NULL", pl:SteamID() != nil && tostring( pl:SteamID() ) || "NULL", pl:IPAddress() != nil && tostring( pl:IPAddress() ) || "NULL", Reasons[r] || "NULL" );
        InformAdmins( info );
        Log( info );
end

net.Receive( NET_MSG, function( len, pl )
        local BAN_REASON = net.ReadInt( 32 );
        Ban( BAN_REASON, pl );
end )