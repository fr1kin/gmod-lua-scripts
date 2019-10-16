local Setup = {}
Setup.Changelog = [[Hermes Changelog:
	================================
	3/4/2011 - Update:
	- Added: New 'ignore in vehicle' added to targeting.
	- Added: New 'ignore ghost' added to targeting.
	- Added: Radar now detects NPCs
	- Added: Spinner added to radar just for looks.
	- Added: General tab added in ESP for organization.
	- Added: New gradent added to the panels.
	- Fix: Attempted to reduce lag in visuals.
	- Fix: Namestealer using a unknown character.
	================================
]]

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
	
	if ( ConVarExists( "hermes_load" ) ) then button:SetDisabled( true ) end
end
timer.Simple( 0.01, function() Setup:CreateMenu() end )

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