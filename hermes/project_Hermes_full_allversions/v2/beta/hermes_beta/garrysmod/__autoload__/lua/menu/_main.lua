/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/_createitem.lua
	Purpose: Create new GUI item
*************************************************************/

HERMES.menusystem = {}

local NONE = ""

local GRAY = Color( 68, 68, 68 )
local GREEN = Color( 89, 106, 69 )
local BLACK = Color( 0, 0, 0 )
local WHITE = Color( 255, 255, 255 )

HERMES:AddFile( "checkbox.lua" )
HERMES:AddFile( "numberbox.lua" )
HERMES:AddFile( "slider.lua" )

/* --------------------
	:: Button
*/ --------------------
local function CreateButton( text, x, y )
	local button = vgui.Create( "DButton" )
	button:SetParent( self )
	button:SetSize( 70, 20 )
	button:SetPos( x, y )
	button:SetText( NONE )
	
	function button:Paint()
		local ORIGINAL = Color( 41, 41, 41, 255 )
		if( button.Depressed ) then
			ORIGINAL = Color( 255, 201, 14, 255 )
		end
		
		local w, h = button:GetWide(), button:GetTall()
		
		surface.SetDrawColor( ORIGINAL )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		
		draw.SimpleText( text, "TabLarge", (w / 2) - 0.5, (h / 2) - 0.5, self.TextColor, 1, 1 )
	end
	return button
end

/* --------------------
	:: VGUI
*/ --------------------
local function VGUIControl( w, h )
	// Top
	local tw, th = w, 21
	surface.SetDrawColor( GREEN	)
	surface.DrawRect( 0, 0, tw, th )
	
	surface.SetDrawColor( BLACK )
	surface.DrawOutlinedRect( 0, 0, tw, th )
	
	// Bottom
	local bw, bh = w, h - 23
	surface.SetDrawColor( GRAY	)
	surface.DrawRect( 0, 23, bw, bh )
	
	surface.SetDrawColor( GREEN	)
	surface.DrawOutlinedRect( 1, 24, bw - 2, bh - 2 )
	surface.DrawOutlinedRect( 2, 25, bw - 4, bh - 4 )
	surface.DrawOutlinedRect( 3, 26, bw - 6, bh - 6 )
	
	surface.SetDrawColor( BLACK )
	surface.DrawOutlinedRect( 0, 23, bw, bh )
	surface.DrawOutlinedRect( 4, 27, bw - 8, bh - 8 )
	
	draw.SimpleText( "Hermes", "TabLarge", 5, ( th / 2 ) - 0.5, WHITE, 0, 1 )
end

/* --------------------
	:: Menu
*/ --------------------
function HERMES.Menu()
	local wid, tal = 450, 350
	
	local panel = vgui.Create( "DFrame" )
	panel:SetPos( ScrW() / 2 - wid / 2, ScrH() / 2 - tal / 2 )
	panel:SetSize( wid, tal )
	panel:SetTitle( "" )
	panel:SetVisible( true )
	panel:SetDraggable( true )
	panel:ShowCloseButton( false )
	panel:MakePopup()
	
	local w, h = panel:GetWide(), panel:GetTall()
	function panel:Paint()
		VGUIControl( w, h )
		if( HERMES['_lock'] == true ) then
			panel:Close()
		end
	end
	
	local button = vgui.Create( "DButton" )
	button:SetParent( panel )
	button:SetSize( 7, 7 )
	button:SetPos( 435, ( 21 / 2 ) - 3 )
	button:SetText( NONE )
	
	function button:Paint()
		local w, h = button:GetWide(), button:GetTall()
		surface.SetDrawColor( GREEN	)
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( BLACK )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	function button:DoClick()
		panel:Close()
	end
	
	local tab = 0
	for k, v in pairs( HERMES.menu.tabs ) do
		local button = CreateButton( k, 10 + tab, 35 )
		button:SetParent( panel )
		
		tab = tab + 80
	end
end

HERMES:AddCommand( "+hermes_menu", HERMES.Menu )