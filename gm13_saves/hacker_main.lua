
local STRING = [[
	Hello All I Am The Sole Creator Of The Smash Hit Crtiically Acclaimed And Definitely DeVestating Gayry Mod ThirTeen Cheat Which Is On Sale Right Now For Fourty United States Dollars Via PayPal But Thats Not All This Site Is About This Site Contains My Very Own BioGraphy My Very Own Lua PortFolio Thats Right I Am Looking For Work Once More You Can Hire The Most Critically Acclaimed Lua Coder In The History Of Gayry Mod If You Are Willing To Put Up The Big Bucks In ReTurn So Go Ahead And Check Out The Other Sections Of This Soon To Be Definitely Critically Acclaimed Site That I Have Just Put ToGether At Like Four Ante Meridiem On A School Night I Am Also Looking To Start My Very Own Smash Hit Career As A Model So Check Out My New Modeling Page If You Would Like To Hire Me I Have Been Told That I Am Quite The Looker And Based On How Much I Bang The Bone With The Hoes It Has To Be True
Never tell your password to anyone.?????????????
]]

local function EncryptAndCompress( str )
	local chars = string.Explode( "", str );
	local char, byte, ret;
	for i = 0, #chars do
		if( !chars[i] ) then
			continue;
		end
		byte = string.format( "%X", tostring( string.byte( chars[i] ) ) ) .. "";
		ret = ( ret || "" ) .. byte .. "/";
	end
	ret = string.reverse( ret );
	return util.Compress( ret );
end

local function DecompressAndDecrypt( str )
	str = util.Decompress( str );
	str = string.reverse( str );
	local chars = string.Explode( "/", str );
	local char, ret;
	for i = 1, #chars do
		if( !chars[i] || chars[i] == nil || chars[i] ==  ""	) then
			continue;
		end
		char = string.char( ( tonumber( chars[i], 16 ) || "" ) );
		ret = ( ret || "" ) .. char;
	end
	return ret;
end

local encrypt = EncryptAndCompress( STRING );

file.Write( "compresstest.txt", encrypt );
file.Write( "compresstest_noencrpy.txt", util.Compress( STRING ) );
file.Write( "normal.txt", STRING );

concommand.Add( "read_file", function()
	file.Write( "decompress.txt", DecompressAndDecrypt( file.Read( "compresstest.txt", "DATA" ) ) );
end )

/*
local gccount, gccount2 = gcinfo(), collectgarbage("count");

print( gccount, gccount2 );

collectgarbage();
print( collectgarbage("count") );

local save = {};
local detour = {};
local function Detour( old, new )
	detour[new] = old;
	return new;
end

local oldest = nil;
local function GetCallFunction( f )
	local func = debug.getinfo( f );
	if( !detour[f] ) then
		detour[f] = oldest;
	end
end

function TestFunction( m )
	print( "[O]", "This is a test", m );
end

oldest = TestFunction;

TestFunction = Detour( TestFunction, function( m )
	GetCallFunction( TestFunction );
	print( "[1]", "Detoured" );
	detour[TestFunction]( m );
end )

TestFunction( "Test" )

local oldFunc = TestFunction;
function TestFunction( m )
	print( "Test 2" );
	return oldFunc( m );
end

save[TestFunction] = "NEwnew";

TestFunction( "Test Again" )

local oldFuncs = TestFunction;
function TestFunction( m )
	print( "Test 3" );
	return oldFuncs( m );
end

save[TestFunction] = "NEwnew2";

TestFunction( "Test Again 2" )

print( gccount, gcinfo(), gcinfo() - gccount );
/*
local _R = debug.getregistry();

local oldfire = _R.Entity.FireBullets;
function _R.Entity.FireBullets( bullet, a )
	print( bullet )
	PrintTable( a )
	return oldfire( bullet, a );
end


local function IsInGlobals( o, _d, _s )
	_d = _d || {};
	for k, v in pairs( _s || _G ) do
		if( istable( v ) && !_d[v] ) then
			_d[v] = true;
			if( IsInGlobals( o, _d, v ) ) then
				return true;
			end
		else
			if( v == o ) then
				return true;
			end
		end
	end
	return false;
end

print( IsInGlobals( _R.Entity.FireBullets ) );

print( IsInGlobals( IsValid ) );
*/
/*
local on = {};

local function AddThis( funccy, new )
	local fagitt = "fasfa";
	on[fagitt] = true;
	local function _new(...)
		print( "test: ", fagitt );
		if( on[fagitt] == true ) then
			return new(...);
		end
		return funccy(...);
	end
	_G["faggotface"] = _new;
end

function faggotface()
	return "FAG"
end

print( faggotface() );

local function newthingy()
	return "notfag sorey"
end

AddThis( faggotface, newthingy )

print( faggotface() );

concommand.Add( "thetest", function()
	print( faggotface() );
end )
*/




/*
local function CorrectSlashes( str )
	str = string.gsub( str, "//", "/" );
	str = string.gsub( str, "\\", "/" );
	return str;
end

local dirs_to_data = {
	["DATA"] = "",
	["GAME"] = "data/",
	["MOD"] = "data/",
}

function Add( name, contents )
	if( string.sub( name, -4 ) != ".txt" ) then
		name = name .. ".txt";
	end
	local folders = string.Explode( "/", CorrectSlashes( name ) );
	if( #folders > 1 ) then
		file.CreateDir( folders[#folders-1] );
		name = folders[#folders-1] .. "/" .. folders[#folders];
	end
	print( "data/" .. name, folders[#folders] )
end

local PATHS = {
	["LUA"] = "lua/",
	["DATA"] = "data/",
}

local lfiles = {};
local ldirec = {};

local tdirec = {}
local tfiles = {};

function IsBlacklisted( name, _path, _only )
	if( !isstring( name ) && !isstring( _path ) ) then
		return false;
	end
	// Files are not case sensitive, so I can just make it all lower case to ease matching.
	name = string.lower( name );
	// If a path is chosen edit it into the name.
	if( PATHS[_path] ) then
		name = PATHS[_path] .. name;
	end
	// Break the folders apart and correct the slashes.
	local list_folders = string.Explode( "/", CorrectSlashes( name ) );
	// Here I can find out the folder they are searching in.
	local findpath = name;
	if( list_folders && #list_folders > 1 ) then // There is more than 1 object in this table.
		findpath = string.gsub( name, "/" .. list_folders[#list_folders], "" ); // EX: data/folder/test.txt -> data/folder
	end
	// This is a file, so we can finally check after all that shit.
	// File is blacklisted, time to spoof shit.
	if( lfiles[name] ) then
		return true;
	end
	if( ldirec[name] ) then
		return true;
	end
	// Everything passing is fine.
	return false;
end

function ToFullPath( name, path )
	name = string.lower( name );
	// If a path is chosen edit it into the name.
	if( PATHS[path] ) then
		name = PATHS[path] .. name;
	end
	return name;
end

function GiveSpoofName( name, s_name )
	if( !isstring( name ) || !isstring( s_name ) ) then
		return "pi";
	end
	local newname, index = nil, 1
	while( true ) do
		newname = string.gsub( s_name, ".txt", "" );
		newname = tostring( newname .. "_" .. index .. ".txt" );
		if( !file.Exists( newname, "DATA" ) ) then
			break;
		end
		index = index + 1;
	end
	name = string.gsub( name, s_name, newname );
	return newname, name;
end

function Write( name, content )
	if( IsBlacklisted( name, "DATA" ) ) then
		while( true ) do
			name = string.lower( name );
			local folders = string.Explode( "/", CorrectSlashes( name ) );
			if( folders == nil ) then
				break;
			end
			if( !istable( folders ) ) then
				break;
			end
			if( #folders > 2 ) then
				break;
			end
			
			local fullpath = ToFullPath( name, "DATA" );
			local file_name = folders[#folders];
			local spoof_name, full_spoof_path = GiveSpoofName( fullpath, file_name );
			
			// File created
			tfiles[fullpath] = spoof_name;
			
			// Folder exists.
			if( folders && #folders > 1 ) then
				print( "folder made", string.gsub( fullpath, "/" .. file_name, "") );
				tdirec[string.gsub( fullpath, "/" .. file_name, "")] = true;
			end
			
			name = string.gsub( name, file_name, spoof_name );
			print( name );
			break;
		end
	end
	return "returned: " ..name .. " [arg2] " .. content
end

concommand.Add( "debug_stringtest", function()
	local folder = "hacker.txt";
	lfiles["data/"..folder] = true;
	
	print( file.Time( "lolasdas.txt", "DATA" ) );
	print( Write( folder, "lol" ) );
end )
*/
/*
function f (v)
  test = v  -- assign to global variable test
end -- function f

local myenv = {}  -- my local environment table
setfenv (f, myenv)  -- change environment for function f
f (42)  -- call f with new environment

print (test) --> nil  (global test was not changed)
print (myenv.test)  --> 42  (test inside myenv was changed)
*/
/*
local ignorethisshit = {
["lua/dmodelpanel.lua"] = true,
["lua/getmaps.lua"] = true,
["lua/diconlayout.lua"] = true,
["lua/autorun/server/tf2_spy_solider.lua"] = true,
["lua/player_color.lua"] = true,
["lua/matselect.lua"] = true,
["lua/includes/icon_progress.lua"] = true,
["lua/includes/extensions/entity.lua"] = true,
["lua/autorun/admin_functions.lua"] = true,
["lua/imagecheckbox.lua"] = true,
["lua/dnotify.lua"] = true,
["lua/color_modify.lua"] = true,
["lua/fingervar.lua"] = true,
["lua/game_css.lua"] = true,
["lua/autorun/holster.lua"] = true,
["lua/drive_sandbox.lua"] = true,
["lua/menu_save.lua"] = true,
["lua/dalphabar.lua"] = true,
["lua/dpropertysheet.lua"] = true,
["lua/includes/properties.lua"] = true,
["lua/includes/vgui_showlayout.lua"] = true,
["lua/dcombobox.lua"] = true,
["lua/dhtmlcontrols.lua"] = true,
["lua/dtree_node.lua"] = true,
["lua/dcolormixer.lua"] = true,
["lua/includes/workshop_files.lua"] = true,
["lua/drive_noclip.lua"] = true,
["lua/player_weapon_color.lua"] = true,
["lua/autorun/keep_upright.lua"] = true,
["lua/derma_gwen.lua"] = true,
["lua/widget_base.lua"] = true,
["lua/weapon_sounds_fas2.lua"] = true,
["lua/dbutton.lua"] = true,
["lua/menu.lua"] = true,
["lua/game_ep2.lua"] = true,
["lua/super_dof.lua"] = true,
["lua/weapons/_temp/cl_init.lua"] = true,
["lua/includes/player_manager.lua"] = true,
["lua/autorun/drive.lua"] = true,
["lua/dlistview_column.lua"] = true,
["lua/dpanellist.lua"] = true,
["lua/dcolumnsheet.lua"] = true,
["lua/weapons/_temp/shared.lua"] = true,
["lua/menu/mount/workshop.lua"] = true,
["lua/autorun/npc_scale.lua"] = true,
["lua/weapons/_temp/init.lua"] = true,
["lua/autorun/demo_recording.lua"] = true,
["lua/autorun/server/valvebiped.lua"] = true,
["lua/contextbase.lua"] = true,
["lua/weapons/init.lua"] = true,
["lua/ddragbase.lua"] = true,
["lua/menu/mount.lua"] = true,
["lua/dlabelurl.lua"] = true,
["lua/dlistlayout.lua"] = true,
["lua/developer_functions.lua"] = true,
["lua/widget_bones.lua"] = true,
["lua/menu/mount/addon_rocket.lua"] = true,
["lua/utilities_menu.lua"] = true,
["lua/autorun/remove.lua"] = true,
["lua/menu_dupe.lua"] = true,
["lua/dcolorbutton.lua"] = true,
["lua/dpaneloverlay.lua"] = true,
["lua/dexpandbutton.lua"] = true,
["lua/includes/tooltips.lua"] = true,
["lua/includes/saverestore.lua"] = true,
["lua/dmenuoption.lua"] = true,
["lua/dverticaldivider.lua"] = true,
["lua/includes/extensions/client/selections.lua"] = true,
["lua/dhorizontaldivider.lua"] = true,
["lua/includes/model_database.lua"] = true,
["lua/autorun/server/tf2_heavy.lua"] = true,
["lua/slidebar.lua"] = true,
["lua/includes/entity_creation_helpers.lua"] = true,
["lua/derma_example.lua"] = true,
["lua/entities/cl_init.lua"] = true,
["lua/autorun/persist.lua"] = true,
["lua/sharpen.lua"] = true,
["lua/motion_blur.lua"] = true,
["lua/progressbar.lua"] = true,
["lua/includes/construct.lua"] = true,
["lua/includes/extensions/panel.lua"] = true,
["lua/m96revolver.lua"] = true,
["lua/dslider.lua"] = true,
["lua/includes/extensions/client/animation.lua"] = true,
["lua/base_npcs.lua"] = true,
["lua/dtree_node_button.lua"] = true,
["lua/dcategorycollapse.lua"] = true,
["lua/autorun/editentity.lua"] = true,
["lua/dlabeleditable.lua"] = true,
["lua/includes/killicon.lua"] = true,
["lua/dcategorylist.lua"] = true,
["lua/material.lua"] = true,
["lua/dlistview_line.lua"] = true,
["lua/includes/entity_filters.lua"] = true,
["lua/util.lua"] = true,
["lua/dimage.lua"] = true,
["lua/dkillicon.lua"] = true,
["lua/dgrid.lua"] = true,
["lua/dimagebutton.lua"] = true,
["lua/fingerposer.lua"] = true,
["lua/autorun/gravity.lua"] = true,
["lua/autorun/server/tf2_pyro_demo.lua"] = true,
["lua/stereoscopy.lua"] = true,
["lua/dpanelselect.lua"] = true,
["lua/includes/constraint.lua"] = true,
["lua/includes/player_auth.lua"] = true,
["lua/bokeh_dof.lua"] = true,
["lua/dbubblecontainer.lua"] = true,
["lua/drive_base.lua"] = true,
["lua/derma_utils.lua"] = true,
["lua/test.lua"] = true,
["lua/drgbpicker.lua"] = true,
["lua/includes/weapons.lua"] = true,
["lua/flechette_gun.lua"] = true,
["lua/includes/extensions/globals.lua"] = true,
["lua/sky_paint.lua"] = true,
["lua/dtree.lua"] = true,
["lua/dsprite.lua"] = true,
["lua/vgui_panellist.lua"] = true,
["lua/includes/net.lua"] = true,
["lua/includes/extensions/worldpicker.lua"] = true,
["lua/weapons/cl_init.lua"] = true,
["lua/spawnicon.lua"] = true,
["lua/autorun/collisions.lua"] = true,
["lua/prop_vectorcolor.lua"] = true,
["lua/prop_generic.lua"] = true,
["lua/dmenuoptioncvar.lua"] = true,
["lua/prop_float.lua"] = true,
["lua/dmenu.lua"] = true,
["lua/includes/halo.lua"] = true,
["lua/autorun/ai_options.lua"] = true,
["lua/prop_boolean.lua"] = true,
["lua/dpanel.lua"] = true,
["lua/dvscrollbar.lua"] = true,
["lua/autorun/server/eli.lua"] = true,
["lua/includes/hook.lua"] = true,
["lua/dlistbox.lua"] = true,
["lua/widget_arrow.lua"] = true,
["lua/default.lua"] = true,
["lua/includes/javascript_util.lua"] = true,
["lua/includes/effects.lua"] = true,
["lua/dnumberscratch.lua"] = true,
["lua/includes/cvars.lua"] = true,
["lua/includes/cookie.lua"] = true,
["lua/dbinder.lua"] = true,
["lua/dshape.lua"] = true,
["lua/includes/concommand.lua"] = true,
["lua/dprogress.lua"] = true,
["lua/dframe.lua"] = true,
["lua/dentityproperties.lua"] = true,
["lua/includes/extensions/client/scriptedpanels.lua"] = true,
["lua/game_hl2.lua"] = true,
["lua/includes/physics.lua"] = true,
["lua/functiondump.lua"] = true,
["lua/includes/controlpanel.lua"] = true,
["lua/includes/extensions/client/dragdrop.lua"] = true,
["lua/overlay.lua"] = true,
["lua/video.lua"] = true,
["lua/dcheckbox.lua"] = true,
["lua/autorun/display_options.lua"] = true,
["lua/includes/ai_task.lua"] = true,
["lua/dmodelselectmulti.lua"] = true,
["lua/includes/extensions/render.lua"] = true,
["lua/includes/extensions/player.lua"] = true,
["lua/dfilebrowser.lua"] = true,
["lua/includes/list.lua"] = true,
["lua/autorun/bone_manipulate.lua"] = true,
["lua/dlabel.lua"] = true,
["lua/includes/util.lua"] = true,
["lua/dtilelayout.lua"] = true,
["lua/includes/baseclass.lua"] = true,
["lua/dtextentry.lua"] = true,
["lua/autorun/statue.lua"] = true,
["lua/motionsensor.lua"] = true,
["lua/background.lua"] = true,
["lua/autorun/gm_demo.lua"] = true,
["lua/includes/game.lua"] = true,
["lua/includes/cleanup.lua"] = true,
["lua/includes/constraints.lua"] = true,
["lua/dadjustablemodelpanel.lua"] = true,
["lua/includes/debug.lua"] = true,
["lua/autorun/kinect_controller.lua"] = true,
["lua/dcolorcube.lua"] = true,
["lua/menu_addon.lua"] = true,
["lua/dhtml.lua"] = true,
["lua/entities/shared.lua"] = true,
["lua/entities/init.lua"] = true,
["lua/diconbrowser.lua"] = true,
["lua/includes/motionsensor.lua"] = true,
["lua/autorun/server/tf2_medic.lua"] = true,
["lua/dcolorcombo.lua"] = true,
["lua/toytown.lua"] = true,
["lua/loading.lua"] = true,
["lua/includes/gamemode.lua"] = true,
["lua/includes/team.lua"] = true,
["lua/includes/spawnmenu.lua"] = true,
["lua/effects/init.lua"] = true,
["lua/errors.lua"] = true,
["lua/derma_menus.lua"] = true,
["lua/dcolorpalette.lua"] = true,
["lua/includes/duplicator.lua"] = true,
["lua/dnumberwang.lua"] = true,
["lua/includes/notification.lua"] = true,
["lua/demo_to_video.lua"] = true,
["lua/autorun/server/tf2_sniper.lua"] = true,
["lua/autorun/server/tf2_scout.lua"] = true,
["lua/includes/ai_schedule.lua"] = true,
["lua/includes/string.lua"] = true,
["lua/sobel.lua"] = true,
["lua/widget_axis.lua"] = true,
["lua/send.txt"] = true,
["lua/menu_demo.lua"] = true,
["lua/includes/numpad.lua"] = true,
["lua/includes/entity.lua"] = true,
["lua/dev_server_test.lua"] = true,
["lua/derma_animation.lua"] = true,
["lua/propselect.lua"] = true,
["lua/vgui_base.lua"] = true,
["lua/frame_blend.lua"] = true,
["lua/weapons/shared.lua"] = true,
["lua/widget_disc.lua"] = true,
["lua/weapon_sounds_fas1.lua"] = true,
["lua/sim_shared_fas.lua"] = true,
["lua/bloom.lua"] = true,
["lua/base_vehicles.lua"] = true,
["lua/game_dod.lua"] = true,
["lua/includes/drive.lua"] = true,
["lua/autorun/sim_menu_updated.lua"] = true,
["lua/includes/http.lua"] = true,
["lua/dlistview.lua"] = true,
["lua/includes/draw.lua"] = true,
["lua/includes/search.lua"] = true,
["lua/derma.lua"] = true,
["lua/dmenubar.lua"] = true,
["lua/dof.lua"] = true,
["lua/init_menu.lua"] = true,
["lua/includes/undo.lua"] = true,
["lua/includes/widget.lua"] = true,
["lua/includes/client.lua"] = true,
["lua/includes/player.lua"] = true,
["lua/includes/sql.lua"] = true,
["lua/init.lua"] = true,
["lua/dnumslider.lua"] = true,
["lua/autorun/server/tf2_engineer.lua"] = true,
["lua/dform.lua"] = true,
["lua/dscrollbargrip.lua"] = true,
["lua/sunbeams.lua"] = true,
["lua/autorun/server/css.lua"] = true,
["lua/includes/usermessage.lua"] = true,
["lua/includes/matproxy.lua"] = true,
["lua/dsizetocontents.lua"] = true,
["lua/includes/angle.lua"] = true,
["lua/sent_ball.lua"] = true,
["lua/dscrollpanel.lua"] = true,
["lua/includes/timer.lua"] = true,
["lua/dnumpad.lua"] = true,
["lua/dproperties.lua"] = true,
["lua/includes/file.lua"] = true,
["lua/includes/ents.lua"] = true,
["lua/includes/menubar.lua"] = true,
["lua/includes/math.lua"] = true,
["lua/includes/presets.lua"] = true,
["lua/ddrawer.lua"] = true,
["lua/properties.lua"] = true,
["lua/includes/markup.lua"] = true,
["lua/includes/table.lua"] = true,
["lua/dhorizontalscroller.lua"] = true,
["lua/autorun/ignite.lua"] = true,
["lua/mainmenu.lua"] = true,
["lua/includes/scripted_ents.lua"] = true,
["lua/dmodelselect.lua"] = true,
["lua/texturize.lua"] = true,
["lua/includes/vector.lua"] = true,
["lua/gmsave.lua"] = true,
["lua/menubar.lua"] = true,
["lua/dtooltip.lua"] = true,
}


local function GetAllFilesInFolder( folder, collected, dir )
	dir = dir || "";
	collected = collected || {};
	local files, folders = file.Find( dir .. folder .. "*", "GAME" );
	if( files || folders ) then
		for k, v in pairs( files ) do
			local temp = dir;
			if( dir == "" ) then
				temp = folder;
			end
			if( ignorethisshit[temp .. v] ) then
				continue;
			end
			if( !collected[temp .. v] ) then
				collected[temp .. v] = true;
				continue;
			end
		end
		for k, v in pairs( folders ) do
			local more, newindex = GetAllFilesInFolder( v .. "/", collected, ( dir .. folder ) );
		end
		return collected;
	end
	return {};
end

//GetAllFilesInFolder( "lua" )
PrintTable( GetAllFilesInFolder( "lua/" ) );
/*
local form = GetAllFilesInFolder( "lua/" )
/*
print( "local ignorethisshit = {" )
for k, v in pairs( form ) do
	print( "[" .. [["]] .. k .. [["]] .. "] = true," );
end

print( "}" );
/*
function FSPOOF:IsBlacklisted( name, _path, _only )
	if( !IsString( name ) || !IsString( _path ) ) then
		return false;
	end
	// Files are not case sensitive, so I can just make it all lower case to ease matching.
	name = g.string.lower( name );
	// If a path is chosen edit it into the name.
	if( PATHS[_path] ) then
		name = PATHS[_path] .. name;
	end
	// Break the folders apart and correct the slashes.
	local list_folders = ExplodeString( "/", CorrectSlashes( name ) );
	// Here I can find out the folder they are searching in.
	local findpath = name;
	if( list_folders && #list_folders > 1 ) then // There is more than 1 object in this table.
		findpath = g.string.gsub( name, "/" .. list_folders[#list_folders], "" ); // EX: data/folder/test.txt -> data/folder
	end
	local isfile = ( _only == "file" ) && true || ( _only == "folder" ) && false || nil;
	if( IsNil( isfile ) ) then
		// You can end folders with the .txt extention so this will prevent confusion.
		local files, folders = g.file.Find( findpath .. "/*", "GAME" );
		if( files && folders ) then
			for i = 1, #files do
				if( files[i] == list_folders[#list_folders] ) then
					isfile = true;
				end
			end
			for i = 1, #folders do
				if( folders[i] == list_folders[#list_folders] ) then
					isfile = false;
				end
			end
		end
	end
	// This is a file, so we can finally check after all that shit.
	if( isfile == true ) then
		// Has someone else created this file?
		if( self.files[name] ) then
			return false;
		end
		// Protected?
		if( PROTECT.files[name] ) then
			return true;
		end
	elseif( isfile == false ) then
		// Has someone else created this folder?
		if( self.dirs[name] ) then
			return false;
		end
		// Protected?
		if( PROTECT.direc[name] ) then
			return true;
		end
	end
	// Everything passing is fine.
	return false;
end
*/




















/*
local org_hook = table.Copy( hook );
local old_hook = table.Copy( hook );

local old_gettable = old_hook.GetTable;

local function TestDetour()
	print( "Test" );
	return old_gettable();
end

old_hook.GetTable = TestDetour;

rawset( hook, "GetTable", TestDetour );


concommand.Add( "debug_hooksize", function()
	print( "########## hook size ##########" );
	print( "HOOK: ", #hook );
	PrintTable( hook );
end )

concommand.Add( "debug_hookcall", function()
	print( "Calling hook..." );
	local pfin = hook.GetTable();
end )
*/

/*
local function GetInfo( func, temp, toscan, memb )
	temp = temp || {};
	memb = memb || { "_G" };
	for k, v in pairs( toscan || _G ) do
		if( type( v ) == "table" && !temp[v] ) then
			temp[v] = true;
			local n = GetInfo( func, temp, v, memb );
			if( n ) then
				memb[#memb + 1 || 0] = k;
				return n;
			end
		else
			if( v == func ) then
				return {
					name = k,			// Name of the function
					func = v,			// Index of the function (usally the function itself)
					memberof = memb,	// Members of the function
				};
			end
		end
	end
	return nil;
end

_G.niggars = {};

function niggars:GayAss()
	print( "niggas" );
end

local members = {};

function Add( old, new )
	members[new] = old;
	
	local info = GetInfo( old );
	
	local dir = _G;
	for i = 2, #info.memberof do
		dir = dir[info.memberof[i]];
	end
	
	if( dir && dir[info.name] ) then
		rawset( dir, info.name, new );
	end
end

local function Nigga()
	print( "works" );
end

niggars:GayAss()

Add( niggars.GayAss, Nigga );

niggars:GayAss()
*/

/*
local debugCheck = {};

local function Hide( name, objects )
	debugCheck[name] = {};
	for k, v in pairs( objects ) do
		debugCheck[name][v] = true;
	end
end

Hide( "GetConVarNumber", { "gay" } );

local function debugHook( ... )
	local args = {...};
	
	local info = debug.getinfo( 2 );
	if( info && info.name && debugCheck[info.name] ) then
		print( "hello" );
		local name, value, index = 0, 0, 1;
		while( true ) do
			name, value = debug.getlocal( 2, index );
			print( name, value );
			if( name == nil || value == nil ) then 
				break; 
			end
			if( debugCheck[info.name][value] ) then
				debug.setlocal( 2, index, "some other variable depending on the type" );
			end
			index = index + 1;
		end
		debug.sethook();
	end
end

debug.sethook( debugHook, "c", 0 );

include( "test2.lua" );
*/

/*
local function Hook( ... )
	local args = {...};
	
	local name = debug.getinfo (2, "n").name;
	
	if( name == "GetConVarNumber" ) then
		PrintTable( debug.getinfo(2) );
		local func = debug.getinfo(2).func;
		
		print( "## UPVALUES ##" )
		local i = 1;
		while( true ) do
			local n, v = debug.getupvalue( func, i );
			if( n == nil || v == nil ) then
				break;
			end
			print( func, n, v )
			i = i + 1;
		end
		
		print( "## LOCALS ##" )
		i = 1;
		while( true ) do
			local n, v = debug.getlocal( 2, i );
			if( n == nil || v == nil ) then
				break;
			end
			print( func, n, v )
			//print( "test...", debug.setlocal( 2, i, "you are gay" ) );
			i = i + 1;
		end
		
		print( "END" );
		debug.sethook();
	end
end
*/


/*
debug.setmetatable( _G, {
		__index = function( t, k )
			if( k == "SCRIPTNAME" || k == "SCRIPTPATH" ) then
				local i = 1;
				while( true ) do
					local info = debug.getinfo(i);
					if( !info ) then break; end
					print( "\n#################### INDEX ####################\n LEVEL = ", i, "\n" );
					PrintTable( info );
					i = i + 1;
				end
			end
		end,
		__newindex = function( t, k, v )
			if( k == "SCRIPTNAME" || k == "SCRIPTPATH" ) then
				local i = 1;
				while( true ) do
					local info = debug.getinfo(i);
					if( !info ) then break; end
					print( "\n#################### NEWINDEX ####################\n LEVEL = ", i, "\n" );
					PrintTable( info );
					i = i + 1;
				end
			end
		end,
	}
)
*/

/*
local ignore = {
	["SuperDOFWindow"] = true,
	["g_ClientSaveDupe"] = true,
}

local log = false;

local fag = hook;

function fag.GetTable()
	return fag._M.Hooks;
end

print( "function: ", fag.GetTable );

local old = hook;

old.GetTable = fag.GetTable;

hook = nil;

debug.setmetatable( _G, {
		__index = function( t, k )
			if( !ignore[k] && log ) then
				print( "__index: ", k );
			end
			if( k == "hook" ) then
				return old;
			end
			return rawget( t, k );
		end,
		
		__newindex = function( t, k, v )
			if( !ignore[k] && log ) then
				print( "__newindex: ", k, v );
			end
			rawset( t, k, v )
		end,
		
		__metatable = true,
	}
)

--[[
for k, v in pairs( old ) do
	hook[k] = v;
end
]]
concommand.Add( "toggle_logging", function()
	log = !log;
end )



concommand.Add( "test_func", function()
	print( "\n############### RUNSTRING ###############\n" );
	RunString( "print( 'test' ) " );
	print( "\n############### RUNSTRINGEX ###############\n" );
	RunStringEx( "print( 'test' ) ", "nigga" );
end )
*/