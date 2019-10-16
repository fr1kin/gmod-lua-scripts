local Setup = {}
Setup.Changelog = [[ SUN KISS ]]

Setup.Link = "http://dl.dropbox.com/u/19409997/Hermes/changelog/changelog.txt"
function Setup:GetChangelog()
	http.Get( Setup.Link, "", function( c, s )
		if ( s > 0 ) then
			Setup.Changelog = [[ c ]]
		else
			Setup.Changelog = "Lost connection."
		end
	end )
end

local panel
function Setup:CreateMenu()
	Setup:GetChangelog()
	
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
		
	local function SetLabel()
		Setup:GetChangelog()
		local text = string.Explode( "\n", Setup.Changelog || "Failed to connect." )
		for i = 1, table.Count( text ) do
			local label = vgui.Create( "DLabel" )
			label:SetMultiline( true )
			label:SetTextColor( color_black )
			label:SetSize( 200, 13 )
			label:SetText( text[ i ] )
			lists:AddItem( label )
		end
	end
	SetLabel()
	
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