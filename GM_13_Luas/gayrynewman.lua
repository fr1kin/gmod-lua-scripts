/*
if( atesttable ) then
	atesttable = nil;
	_G.WHATISTHIS = nil;
end

local _R = debug.getregistry();

local g = {};
local r = {};

local metas = {};

local function Todo()
	print( "function created" );
end

local function Args(...)
	print( "works: ", unpack({...}) );
end

g.atesttable = {}
g.atesttable.anewvar = Todo;

g.atesttable.testert = {};
g.atesttable.testert.name = {};
g.atesttable.testert.name.hello = {};
g.atesttable.testert.name.hello.ngga = Args;

_G.WHATISTHIS = {
	"NIGGGGGGERS";
};

local function Loopers( start, save, parent )
	if( metas[start] ) then
		return;
	end
	metas[start] = true;
	local new = {};
	if( debug.getmetatable( start ) ) then
		new = debug.getmetatable( start );
	end
	local oldnewindex = new.__newindex || nil;
	function new:__newindex( t, k, v )
		if( t && k && type( k ) == "string" ) then
			local tbl = parent || save;
			if( tbl[k] && type( tbl[k] ) == "function" ) then
				tbl[k]();
				tbl[k] = true;
			end
			if( type( v ) == "table" ) then
				if( !tbl[k] ) then
					tbl[k] = {};
				end
				tbl = tbl[k];
				Loopers( v, tbl )
				local function loopthrough( loop, jtb )
					for name, obj in pairs( loop ) do
						local memb = jtb;
						if( memb[name] && type( memb[name] ) == "function" ) then
							memb[name]( obj );
							memb[name] = true;
						end
						if( type( obj ) == "table" ) then
							if( !memb[name] ) then
								memb[name] = {};
							end
							memb = memb[name];
							Loopers( obj, memb )
							loopthrough( obj, memb );
						else
							memb[name] = true;
						end
					end
				end
				loopthrough( v, tbl );
			else
				tbl[k] = true;
			end
		end
		if( oldnewindex ) then
			oldnewindex( t, k, v );
		else
			if( t && k && v && type( t ) == "table" && type( k ) == "string" ) then
				rawset( t, k, v );
			end
		end
	end
	debug.setmetatable( start, new );
end

local function SetMeta( tbl, save, parent, data )
	data = data || {};
	for k, v in pairs( tbl ) do
		if( type( v ) == "table" && !data[v] ) then
			local par = parent || save;
			if( !par[k] ) then
				par[k] = {};
			end
			par = par[k];
			data[tbl] = true;
			Loopers( v, save, par );
			SetMeta( v, save, par, data );
		end
	end
end

SetMeta( _G, g )
//SetMeta( _R, r )

atesttable = {}

atesttable.testert = { "niggas", "diggas", "figgas", name = { "FUCK U", { "canthis work" } } };

atesttable.testert.name["dick"] = "hacker" 

atesttable.niggarsa = "helo" 

concommand.Add( "createnew", function()
	atesttable.anewvar = "why helo teir i did not c u";
	atesttable.testert.name.hello = { ngga = "bitch" }
	
	//typetest( saves )
	print( "\nmetas\n" );
	PrintTable( metas );
	print( "_G\n" );
	PrintTable( g );
	print( "\n" );
	print( "_R\n" );
	PrintTable( r );
end )
*/

local pack = table.Copy( package );

print( _G.debug.getinfo );
print( _G.package.loaded.debug.getinfo );
print( _G.package.loaded._G.debug.getinfo );

_G.debug.getinfo = function( ... ) print( "noob" ) end;

print( _G.debug.getinfo );
print( _G.package.loaded.debug.getinfo );
print( _G.package.loaded._G.debug.getinfo );