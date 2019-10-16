// anticheat

// Message to the server and client (CHANGE THIS MAKE SURE CLIENT AND SERVER HAVE THE SAME NAME)
local NET_MESSAGE = "test";

// Time a client has to respond (in seconds).
local NET_RESPOND_TIME = 60;

// Messages sent to the server, change the numbers to anything.
local NET_INFO = {
	[4356] = "ping",
	[6737] = "scan",
	[4367] = "ranscript",
	[7862] = "auto",
	[0987] = "harvest",
};

util.AddNetworkString( NET_MESSAGE );

local AC = {
	plys = {},
	RESPONDS = {},
};

do
	AC.netinfo = {};
	for index, msg in pairs( NET_INFO ) do
		AC.netinfo[msg] = index;
	end
end

local function random( min, max )
	math.randomseed( CurTime() + ( ( type( table.Count( player.GetAll() ) ) == "number" ) && table.Count( player.GetAll() ) || 33 ) );
	return math.random( min, max );
end

// ------------------------------------------------------------------------------------------
// Kick/ban system

function AC:BanPlayer( pl, reason, time )
	
end

// ------------------------------------------------------------------------------------------
// Client and server connection.

function AC:IsValid( pl )
	if( pl == nil ) then return false; end
	if( IsValid( pl ) == false && !table.HasValue( player.GetAll(), pl ) ) then 
		self.plys[pl] = nil;
		return false; 
	end
	if( self.plys[pl] == nil ) then
		self:InitPlayer( pl );
		return false;
	end
	return true;
end

function AC:RefreshSentDataForPlayer( pl )
	if( self:IsValid( pl ) == false ) then return; end
	self.plys[pl].mdata = {};
	self.plys[pl].mdata.REQUEST = 0;
	self.plys[pl].mdata.SENT = false;
	self.plys[pl].mdata.TIME = 0;
end

function AC:CanSendMessageToPlayer( pl )
	if( self:IsValid( pl ) == false ) then return false; end
	if( self.plys[pl].mdata.SENT == true ) then // There is already a message sent and waiting to have a reply.
		return false;
	end
	return true;
end

function AC:SendRequestToPlayer( pl, msg )
	if( self:IsValid( pl ) == false ) then return; end
	if( self:CanSendMessageToPlayer( pl ) ) then return; end
	self.plys[pl].RESPONDED = false;
	net.Start( NET_MESSAGE );
		net.WriteInt( msg, 32 );
	net.Send( pl );
	self.plys[pl].mdata.REQUEST	= msg;
	self.plys[pl].mdata.SENT 	= true;
	self.plys[pl].mdata.TIME	= CurTime() + 1;
end

function AC:GotMessageFromPlayer( pl, sent )
	if( self:IsValid( pl ) == false ) then return; end
	if( self.plys[pl].mdata.REQUEST == sent ) then
		self:RefreshSentDataForPlayer( pl );
		self.plys[pl].RESPONDED = true;
	end
end

function AC:HasFailedToRespond( pl )
	if( self:IsValid( pl ) == false ) then return false; end
	if( self.plys[pl].RESPONDED == true ) then return false; end
	if( self.plys[pl].mdata.SENT ) then
		if( ( self.plys[pl].mdata.TIME + NET_RESPOND_TIME ) < CurTime() ) then
			self.plys[pl].RESPONDED = false;
			self.plys[pl].RESPOND_FAILED = true;
			return true;
		end
	end
	return false;
end

// ------------------------------------------------------------------------------------------
// Send messages to clients

local NEXT_PING_SCAN = 0;

function AC:GetAllPlayers()
	local plys = {};
	for pl, data in pairs( self.plys ) do
		if( self:IsValid( pl ) == false ) then
			continue;
		end
		plys[pl] = data;
	end
	return plys;
end

function AC:GetRandomPlayers( min, max, amt )
	min = min || 1;
	max = max || 3;
	amt = amt || 3;
	local i = 0;
	local plys = {};
	if( table.Count( self.plys ) > amt ) then
		amt = table.Count( self.plys );
	end
	while( i < amt ) do
		if( i >= amt ) then
			break;
		end
		for pl, data in pairs( self.plys ) do
			if( self:IsValid( pl ) == false ) then
				continue;
			end
			if( i >= amt ) then
				break;
			end
			if( random( min, max ) == 2 && self:CanSendMessageToPlayer( pl ) ) then
				i = i + 1;
				plys[pl] = data;
			end
		end
	end
	return plys;
end

function AC:DispatchMessages()
	if( NEXT_SCAN <= CurTime() ) then
		for pl, data in pairs( self:GetAllPlayers() ) do
			
		end
		NEXT_SCAN = CurTime() + random( 60, 180 );
	end
end

function AC:CheckPlayer()
	for pl, data in pairs( self:GetAllPlayers() ) do
		if( self:HasFailedToRespond( pl ) ) then
			self:BanPlayer( pl, "Client has failed to respond to ping (possible blocking net message).", "30m" );
		end
		if( MAX_BAD_RESPONDS != 0 && pl.NUM_BAD_RESPONDS > MAX_BAD_RESPONDS ) then
			self:BanPlayer( pl, "Client has sent too many invalid net messages (attempted exploit?).", "2h" );
		end
	end
end

// ------------------------------------------------------------------------------------------
// Receive messages from clients

function AC:ReceiveMessageFromPlayer( pl, sent_type, data )
	if( self:IsValid( pl ) ) then
		if( NET_INFO && ( sent_type != nil ) && ( data != nil ) && NET_INFO[sent_type] ) then
			self:GotMessageFromPlayer( pl, sent_type );
			local func = self["RESPONDS"][NET_INFO[sent_type] || "INVALID"];
			if( func ) then
				func( pl, data );
			end
		else
			self.plys[pl].NUM_BAD_RESPONDS = self.plys[pl].NUM_BAD_RESPONDS + 1;
		end
	end
end

// ------------------------------------------------------------------------------------------
// Sending reqests to clients from the server.

function AC:PingPlayer( pl )
	self:SendRequestToPlayer( pl, self.netinfo["ping"] );
end

// ------------------------------------------------------------------------------------------
// Server responses to each net message sent by the client.

function AC["RESPONDS"]["INVALID"]( pl, data )
	if( self:IsValid( pl ) == false ) then return false; end
	self.plys[pl].NUM_BAD_RESPONDS = self.plys[pl].NUM_BAD_RESPONDS + 1;
end

function AC["RESPONDS"]["ping"]( pl, data )
	if( self:IsValid( pl ) == false ) then return false; end
	self.plys[pl].PING_SUCCESS = true;
	self:SendRequestToPlayer( pl, self.netinfo["scan"] );
end

// ------------------------------------------------------------------------------------------
// Game hooks

function AC:InitPlayer( pl )
	if( self.plys[pl] == nil ) then
		self.plys[pl] = {};
		setmetatable( self.plys[pl], { // Prevent errors when trying to access data that doesn't exist on the table.
				__index = function( tbl, index )
					if( rawget( tbl, index ) == nil ) then
						rawset( tbl, index, 0 );
					end
					return rawget( tbl, index );
				end,
				__newindex = function( tbl, index, key )
					rawset( tbl, index, key );
				end,
			}
		)
	end
	self:RefreshSentDataForPlayer( pl );
end

function AC:Think()
	
end

function AC:OnConnect( pl, ip )
	self:InitPlayer( pl );
	self.plys[pl].mdata 			= {};
	self.plys[pl].PING_SUCCESS 		= false;
	self.plys[pl].SPAWNED 			= false;
	self.plys[pl].RESPONDED			= false;
	self.plys[pl].RESPOND_FAILED	= false;
	self.plys[pl].NUM_BAD_RESPONDS	= 0;
end

function AC:OnSpawn( pl )
	if( self.plys[pl] == nil ) then
		self.plys[pl] = {};
	end
	self.plys[pl].SPAWNED = true;
	self:RefreshSentDataForPlayer( pl );
	self:PingPlayer( pl );
end

function AC:OnDisconnect( pl )
	self.plys[pl] = nil;
end

hook.Add( "Think", "ac__pl_think", AC.Think );
hook.Add( "PlayerConnect", "ac__pl_connect", AC.OnConnect );
hook.Add( "PlayerInitialSpawn", "ac__pl_spawn", AC.OnSpawn );
hook.Add( "PlayerDisconnected", "ac__pl_disconnect", AC.OnDisconnect );

// ------------------------------------------------------------------------------------------
// Net receiving.

net.Receive( NET_MESSAGE, function( len, pl )
	local msgtype = net.ReadInt( 32 );
	local data = net.ReadInt( 32 );
	AC:ReceiveMessageFromPlayer( pl, msgtype, data )
end )



















































