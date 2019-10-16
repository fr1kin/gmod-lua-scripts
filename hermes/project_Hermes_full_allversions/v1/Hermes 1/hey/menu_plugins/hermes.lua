//include( "hermes" )
require( "hermes" )

local Setup = {}
Setup.Changelog = "Failed to load changelog, please open then close to retry."
Setup.UpdatedVersion = "0"

Setup.Link = "http://dl.dropbox.com/u/19409997/Hermes/changelog/changelog.txt"
Setup.Hack = "http://dl.dropbox.com/u/19409997/Hermes/download/hermes.lua"
Setup.Version = "http://dl.dropbox.com/u/19409997/Hermes/changelog/version.txt"

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

function Setup:IsOutdated()
	local myVer = 0
	if ( file.Exists( "hermes_version.txt" ) ) then
		local tbl = string.Explode( "\n", file.Read( "hermes_version.txt" ) )
		for k, v in pairs( tbl ) do
			myVer = v
		end
	end
	
	if ( tonumber( Setup.UpdatedVersion ) > tonumber( myVer ) ) then
		return true
	else
		file.Write( "hermes_version.txt", tostring( myVer ) )
	end
	return false
end

local panel
function Setup:CreateMenu()
	
	panel = vgui.Create( "DFrame" )
	panel:SetSize( 330, 400 )
	panel:SetPos( ScrW() / 2 - panel:GetWide() / 2, ScrH() / 2 - panel:GetTall() / 2 )
	panel:SetTitle( "Changelog" )
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
	end
	
	local button1 = vgui.Create( "DButton" )
	button1:SetParent( panel )
	button1:SetSize( 80, 20 )
	button1:SetPos( 100, 375 )
	button1:SetText( "Update" )
	button1.DoClick = function()
		local minwindow = vgui.Create( "DFrame" )
		minwindow:SetSize( 350, 70 )
		minwindow:SetPos( ScrW() / 2 - minwindow:GetWide() / 2, ScrH() / 2 - minwindow:GetTall() / 2 )
		minwindow:SetTitle( "Update URL" )
		minwindow:SetVisible( true )
		minwindow:SetDraggable( true )
		minwindow:ShowCloseButton( true )
		minwindow:MakePopup()
		
		local textbox = vgui.Create( "TextEntry" )
		textbox:SetParent( minwindow )
		textbox:SetMultiline( true )
		textbox:SetSize( 330, 20 )
		textbox:SetPos( 5, ( 70 / 2 ) )
		textbox:SetText( tostring( Setup.Hack ) )
	end
	
	if ( ConVarExists( "hermes_load" ) ) then button:SetDisabled( true ) end
	if ( !Setup:IsOutdated() ) then button1:SetDisabled( true ) end
end
Setup:GetChangelog()

function Setup:Button()
	local button = vgui.Create( "DButton" )
	button:SetParent( panel )
	button:SetSize( 100, 30 )
	button:SetPos( 10, 10 )
	button:SetText( "Changelog" )
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