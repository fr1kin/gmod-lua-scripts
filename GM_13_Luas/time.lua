
local nigga = {};

local averages = {};

averages.tbl = {}

averages.notbl = {};

local g = _G;

nigga.g = _G;

concommand.Add( "time_test", function()
	Msg( "\n" );
	print( "===== time_test :: table" )
	local time = SysTime();
	nigga.g["hook"]["GetTable"]();
	print( SysTime() - time );
	averages.tbl[#averages.tbl + 1] = SysTime() - time;
	print( "===== time_test :: no table" )
	local time2 = SysTime();
	g["hook"]["GetTable"]();
	print( SysTime() - time2 );
	averages.notbl[#averages.notbl + 1] = SysTime() - time2;
end )

concommand.Add( "time_test2", function()
	Msg( "\n" );
	print( "===== time_test2 :: no table" )
	local time2 = SysTime();
	g["hook"]["GetTable"]();
	print( SysTime() - time2 );
	averages.notbl[#averages.notbl + 1] = SysTime() - time2;
	print( "===== time_test2 :: table" )
	local time = SysTime();
	nigga.g["hook"]["GetTable"]();
	print( SysTime() - time );
	averages.tbl[#averages.tbl + 1] = SysTime() - time;
end )

concommand.Add( "time_test_table", function()
	Msg( "\n" );
	print( "===== time_test_table :: table" )
	local time = SysTime();
	nigga.g["hook"]["GetTable"]();
	print( SysTime() - time );
	averages.tbl[#averages.tbl + 1] = SysTime() - time;
end )

concommand.Add( "time_test_notable", function()
	Msg( "\n" );
	print( "===== time_test_notable :: no table" )
	local time = SysTime();
	g["hook"]["GetTable"]();
	print( SysTime() - time );
	averages.notbl[#averages.notbl + 1] = SysTime() - time;
end )

concommand.Add( "time_list", function()
	print( "table: ", #averages.tbl );
	for i, val in pairs( averages.tbl ) do
		print( i, val );
	end
	
	print( "no table: ", #averages.notbl );
	for i, val in pairs( averages.notbl ) do
		print( i, val );
	end
end )

concommand.Add( "time_average", function()
	local cur = 0;
	for i, val in pairs( averages.tbl ) do
		cur = cur + val;
	end
	cur = cur / #averages.tbl;
	
	print( "table: ", cur );
	
	local cur = 0;
	for i, val in pairs( averages.notbl ) do
		cur = cur + val;
	end
	cur = cur / #averages.notbl;
	
	print( "no table: ", cur );
	
	averages.tbl = {};
	averages.notbl = {};
end )