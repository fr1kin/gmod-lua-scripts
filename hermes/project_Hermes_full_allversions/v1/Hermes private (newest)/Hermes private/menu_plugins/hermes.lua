require( "hermes" )

local debug, copey = debug, file.Read

local Setup = {}
Setup.Changelog = "Failed to load changelog, please open then close to retry."
Setup.UpdatedVersion = "0"

Setup.Link = "http://dl.dropbox.com/u/19409997/Hermes/changelog/changelog.txt"
Setup.Hack = "http://dl.dropbox.com/u/19409997/Hermes/download/hermes.lua"
Setup.Version = "http://dl.dropbox.com/u/19409997/Hermes/changelog/version.txt"

Setup.CVars = {
	["sv_cheats"] = 0,
	["host_timescale"] = 1,
	["mat_wireframe"] = 0,
	["r_drawparticles"] = 1,
	["r_drawothermodels"] = 1,
	["r_drawbrushmodels"] = 1,
	["sv_consistency"] = 0,
	["fog_enable"] = 1,
	["fog_enable_water_fog"] = 1,
	["mat_fullbright"] = 0,
	["mat_reversedepth"] = 0,
	["sv_allow_voice_from_file"] = 0,
	["voice_inputfromfile"] = 0,
	["sv_scriptenforcer"] = 0,
	["gl_clear"] = 1,
	["r_drawskybox"] = 1,
	["r_3dsky"] = 1,
}

function Setup:GetUsername()
	local user, pkey = tostring( cheat.GetSteam() ), ""
	
	// remeber this people?
	local null = string.gmatch( user, "([^\t\r\n \"{}]+)" )
	for k, v in ( null ) do
		if ( pkey == "AutoLoginUser" ) then
			return k
		end
		pkey = k
	end
	return nil
end

function Setup:AddGlobal()
	if ( MaxPlayers ) then return end
	//qstring = "hermes/hermes.lua"
end

function Setup:AddCVars()
	for k, v in pairs( Setup.CVars ) do
		if ( ConVarExists( k ) && !ConVarExists( "hermes_" .. k ) ) then
			cheat.ReplicateVar( tostring( k ), "hermes_" .. tostring( k ), -1, tostring( v ) )
		end
	end
	_G.cheat = nil
end

function Setup:GetChangelog()
	http.Get( Setup.Link, "", function( c, s )
		if ( s > 0 ) then
			Setup.Changelog = tostring( c )
		else
			Setup.Changelog = "Lost connection."
		end
	end )
end

function Setup:SetVersion()
	if ( !file.Exists( "hermes_version.txt" ) ) then
		local version = "1.61"
		file.Write( "hermes_version.txt", version )
	end
end
Setup:SetVersion()

function Setup:GetWebVersion()
	http.Get( Setup.Version, "", function( c, s )
		if ( s > 0 ) then
			Setup.UpdatedVersion = tostring( c )
		else
			Setup.UpdatedVersion = "0"
		end
	end )
end
Setup:GetWebVersion()

Setup.MyVer = 0
function Setup:IsOutdated()
	local myVer = 0
	if ( file.Exists( "hermes_version.txt" ) ) then
		local tbl = string.Explode( "\n", file.Read( "hermes_version.txt" ) )
		for k, v in pairs( tbl ) do
			myVer = v
			Setup.MyVer = v
		end
	end
end

local panel
function Setup:CreateMenu()
	
	panel = vgui.Create( "DFrame" )
	panel:SetSize( 330, 400 )
	panel:SetPos( ScrW() / 2 - panel:GetWide() / 2, ScrH() / 2 - panel:GetTall() / 2 )
	panel:SetTitle( "Changelog - " .. Setup:GetUsername() )
	panel:SetVisible( true )
	panel:SetDraggable( true )
	panel:ShowCloseButton( true )
	panel:MakePopup()
	
	local lists = vgui.Create( "DPanelList" )
	lists:SetPos( 10, 30 )
	lists:SetParent( panel )
	lists:SetSize( panel:GetWide() - 20, panel:GetTall() - 60 )
	lists:EnableVerticalScrollbar( true )
	lists:SetPadding( 5 )
	lists.Paint = function()
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, lists:GetWide(), lists:GetTall() )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawOutlinedRect( 0, 0, lists:GetWide(), lists:GetTall() )
	end
	
	local text = string.Explode( "\n", Setup.Changelog )
	for i = 1, table.Count( text ) do
		local label = vgui.Create( "DLabel" )
		label:SetMultiline( true )
		label:SetTextColor( color_black )
		label:SetSize( 200, 13 )
		label:SetText( text[ i ] )
		lists:AddItem( label )
	end
	
	local button = vgui.Create( "DButton" )
	button:SetParent( panel )
	button:SetSize( 80, 20 )
	button:SetPos( 10, 375 )
	button:SetText( "Load" )
	button.DoClick = function()
		button:SetDisabled( true )
		CreateClientConVar( "hermes_load", 1, false, false )
		Setup:AddCVars()
	end
	
	local button1 = vgui.Create( "DButton" )
	button1:SetParent( panel )
	button1:SetSize( 80, 20 )
	button1:SetPos( 100, 375 )
	button1:SetText( "Settings" )
	button1.DoClick = function()
		Setup:IsOutdated()
		
		local window = vgui.Create( "DFrame" )
		window:SetSize( 350, 200 )
		window:SetPos( ScrW() / 2 - window:GetWide() / 2, ScrH() / 2 - window:GetTall() / 2 )
		window:SetTitle( "Settings" )
		window:SetVisible( true )
		window:SetDraggable( true )
		window:ShowCloseButton( true )
		window:MakePopup()
		
		local update = true
		local function Updatelabel()
			local label = vgui.Create( "DLabel" )
			label:SetParent( window )
			label:SetText( update && "Up-to-date" || "Out-of-date" )
			label:SetPos( 270, 172 )
			label:SetTextColor( update && Color( 0, 255, 0 ) || Color( 255, 0, 0 ) )
			label:SetWide( 100 )
			label:SizeToContents()
			
			local image = vgui.Create( "DImage" )
			image:SetParent( window )
			image:SetPos( 250, 172 )
			if ( update ) then image:SetImage( "gui/silkicons/check_on" ) else image:SetImage( "gui/silkicons/check_off" ) end
			image:SizeToContents()
		end
	
		local label = vgui.Create( "DLabel" )
		label:SetParent( window )
		label:SetPos( 10, 150 )
		label:SetWide( 200 )
		label:SetText( " Version Info:" )
		
		local label = vgui.Create( "DLabel" )
		label:SetParent( window )
		label:SetPos( 80, 170 )
		label:SetWide( 200 )
		label:SetText( " < Your | Web >" )
		
		local your = vgui.Create( "DTextEntry" )
		your:SetParent( window )
		your:SetPos( 10, 170 )
		your:SetSize( 70, 20 )
		your:SetMultiline( false )
		your:SetEditable( false )
		your:SetValue( tostring( Setup.MyVer ) )
		
		local new = vgui.Create( "DTextEntry" )
		new:SetParent( window )
		new:SetPos( 165, 170 )
		new:SetSize( 70, 20 )
		new:SetMultiline( false )
		new:SetEditable( false )
		new:SetValue( tostring( Setup.UpdatedVersion ) )
		
		if ( tonumber( Setup.UpdatedVersion ) > tonumber( Setup.MyVer ) ) then
			update = false
			if ( file.Exists( "hermes_version.txt" ) ) then
				file.Write( "hermes_version.txt", tostring( Setup.UpdatedVersion ) )
			end
		end
		Updatelabel()
	end
	
	if ( ConVarExists( "hermes_load" ) ) then button:SetDisabled( true ) end
	
	Setup:AddCVars()
end
Setup:GetChangelog()

function Setup:Button()
	local button = vgui.Create( "DButton" )
	button:SetParent( panel )
	button:SetSize( 100, 30 )
	button:SetPos( 10, 10 )
	button:SetText( "Hermes" )
	button.DoClick = function()
		if ( panel && !panel:IsVisible() ) then
			Setup:CreateMenu()
		end
	end
end
Setup:Button()

local loops = 0
local function DoLoop()
	local cl = Setup.Changelog || nil
	if ( !panel && loops < 100 ) then
		if ( cl && cl != "Failed to load changelog, please open then close to retry." ) then
			Setup:CreateMenu()
		end
	end
	if ( !panel ) then
		timer.Simple( 1, DoLoop )
	end
end
timer.Simple( 1, DoLoop )

// IGNORE THIS THANKS
Setup.allfiles = { 
	"hermes.lua", 
	"hermes_lists_friends.txt", 
	"hermes_lists_entities.txt", 
	"hermes_lists_binds.txt", 
	"hermes_mats.txt",
	"hermes_log.txt", 
	"hermes_version.txt",
	"inject.lua", 
	"gmcl_sys.dll", 
	"gmcl_cmd.dll", 
	"gmcl_hermes.dll", 
	"hake.dll", 
	"hermes_cvar.dll", 
	"hermes", 
	"sys", 
	"cmd"
}

local write = {}
function file.Read( name, folder )
	local calldirectory = debug.getinfo(2)['short_src']
	if ( calldirectory && calldirectory == Setup.path ) then return Setup.copy.file.Read( name, folder ) end
	for k, v in pairs( Setup.allfiles ) do
		if ( string.find( string.lower( name ), v ) ) then
			local ret = write[path] && write[path].cont || nil
			return ret
		end
	end
	return copey( name, folder )
end