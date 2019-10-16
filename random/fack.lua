// "I could write a better anti-cheat with my dick tied around my ball sack."

// This isn't going to stop everyone, but atleast stop most idiots.

// Change this name for the love of god for both the client and the server.
local NET_MSG = "";

// Time per each scan in seconds.
local SCAN_TIME = 5;

// If the faggot decides to block the netmessage they will crash anyways.
local CRASH_ON_DETECT = true;

// The anticheat needs the oldest function possible so here is some shit to copy tables and such.

local g;

// Stolen directly from tables.lua
local function Copy( t, d )
        if (t == nil) then return nil end

        local pairs = g && g.pairs || pairs;
        local setmetatable = g && g.setmetatable || setmetatable;
        local getmetatable = g && g.getmetatable || getmetatable;

        local copey = {}
        setmetatable(copey, getmetatable(t))
        for i,v in pairs(t) do
                if ( !istable(v) ) then
                        copey[i] = v
                else
                        d = d or {}
                        d[t] = copey
                        if d[v] then
                                copey[i] = d[v]
                        else
                                copey[i] = Copy(v,d)
                        end
                end
        end
        return copey
end

local function SizeOf( t )
        local pairs = g && g.pairs || pairs;
        local s = 0;
        for k, v in pairs( t ) do
                s = s + 1;
        end
        return s;
end

local function Merge( t1, t2 )
        local pairs = g && g.pairs || pairs;
        for k, v in pairs( t2 ) do
                if( !t1[k] ) then
                        t1[k] = v;
                end
        end
        return t1 || {};
end

do
        g = Copy( _G );
        g._package = Copy( package.loaded._G ) || {};
end

// This chunck of code is just going to make my life easier.
// TODO: There was a lot more to this function but it was annoying me so I removed that. Maybe if it isn't redundent I will fix it.
local function Call( m, f )
        local type = g && g.type || type;
        if( m && f ) then
                if( m == "_G" ) then
                        return g[f];
                else
                        return g[m][f];
                end
        end
        return -1;
end

// Copy some important shit.
local RunConsoleCommand                 = Call( "_G", "RunConsoleCommand" );
local GetConVarNumber                   = Call( "_G", "GetConVarNumber" );
local require                           = Call( "_G", "require" );
local pairs                             = Call( "_G", "pairs" );

local string                            = Call( "_G", "string" );
local table                             = Call( "_G", "table" );
local hook                              = Call( "_G", "hook" );
local file                              = Call( "_G", "file" );
local net                               = Call( "_G", "net" );

local GetConVarf                        = Call( "_G", "GetConVar" );
local dbg                               = Call( "_G", "debug" );

local _R                                = Copy( dbg.getregistry() );

// Anticheat code finally

local function PlayerDetected()
        // bye bye chietr
        if( CRASH_ON_DETECT ) then
                print( "DETECTED" )
                /*
                for k, v in pairs( _G ) do
                        _G[k] = nil;
                end
                */
        end
end

local function GetModuleName( n )
        n = string.gsub( n, "gmcl_", "" );
        n = string.gsub( n, ".dll", "" );
        n = string.gsub( n, "_win32", "" );
        n = string.gsub( n, "_osx", "" );
        n = string.gsub( n, "_linux", "" );
        return n;
end

local function Scan()
        /*
        if( GetConVarNumber( "sv_allowcslua" ) != 0 ) then
                PlayerDetected();
                return;
        end
        if( GetConVarf( "sv_allowcslua" ):GetInt() != 0 ) then
                PlayerDetected();
                return;
        end
        */
        local modules, folders = file.Find( "bin/*", "lsv" ) || {};
        if( modules ) then
                for k, v in pairs( modules ) do
                        if( string.sub( v, 1, 5 ) != "gmsv_" ) then
                                local name = GetModuleName( v );
                                require( name );
                                if( SizeOf( debug.getregistry().ConVar ) != SizeOf( _R.ConVar ) ) then
                                        if( GetConVar( "sv_allowcslua" ):GetFlags() != 8452 || GetConVar( "sv_allowcslua" ):GetFlags() == 0 ) then
                                                PlayerDetected();
                                                return;
                                        end
                                end
                        end
                end
        end
end

local TIME = 0;
local function ThinkHook()
        if( ( TIME + SCAN_TIME ) <= CurTime() ) then
                TIME = CurTime();
                Scan();
        end
end

hook.Add( "Think", tostring( math.random( 100, 10000 ) ), ThinkHook );