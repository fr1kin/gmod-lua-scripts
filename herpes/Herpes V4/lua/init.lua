// Herpes v4

local dll = InitializeTable();

dll.Log( "[Lua]: Including important files...\n" );

// Base files
dll.Include( "base/util.lua" );
dll.Include( "base/table.lua" );
//dll.Include( "base/timer.lua" );
//dll.Include( "base/ents.lua" );

// Detour files


dll.Log( "[Lua]: Successfully loaded every file!\n" );

dll.Kill();