// ########################################
// Name: timer.lua
// Purpose: Simple timer class that can be
// used other than the deafult class.
// ########################################

local dll = InitializeTable();

dll.Log( "[Lua]: timer.lua loading...\n" );

// Grab contents from other files.
local utils = dll.GetTableContents( "util" );

// Initialize main table.
local time = {};

time.funcs = {};

// Func: time:Create
// Purpose: Create a simple timer that waits a certain
// amount of time before function execution.
function time:Create( time, func )
	if( utils:IsNil( time, func ) ) then
		return NULL;
	end
	
	time.funcs[#time.funcs + 1] = { func, ( dll.curtime() + time ) };
	return 1;
end

// Purpose: Hook into think hook to keep track
// of the timer.
local function ThinkHook()
	if( utils:IsNil( time.funcs ) ) then
		return;
	end
	
	for i = 1, #time.funcs do
		local obj = time.funcs[i];
		if( utils:IsNil( obj ) ) then
			continue;
		end
		if( utils:IsNil( v[1], v[2] ) ) then
			continue;
		end
		
		if( dll.curtime() >= obj[2] ) then
			v[1]();
			time.funcs[i] = nil;
		end
	end
end

hooks:AddFunc( "Think", ThinkHook );