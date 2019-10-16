/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/_createitem.lua
	Purpose: Create new GUI item
*************************************************************/

HERMES.menusystem = {}

local table = table.Copy( table )
local vgui = table.Copy( vgui )

local panel = nil

local NONE = ""

local GRAY = Color( 40, 40, 40 )
local DARKGRAY = Color( 50, 50, 50 )
local GREEN = Color( 89, 106, 69 )
local BLACK = Color( 0, 0, 0 )
local WHITE = Color( 255, 255, 255 )

HERMES:AddFile( "menu/checkbox.lua" )
HERMES:AddFile( "menu/numberbox.lua" )
//HERMES:AddFile( "menu/slider.lua" )
HERMES:AddFile( "menu/radar.lua" )
HERMES:AddFile( "menu/admins.lua" )
HERMES:AddFile( "menu/spectators.lua" )

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
local function Gradient( x, y, w, h )
	local col1, col2 = GRAY, BLACK
	for i = 1, h, 2 do
		local col = ( i / h )
		surface.SetDrawColor( ( col1.r * ( 1 - col ) ) + ( col2.r * col ), ( col1.g * ( 1 - col ) ) + ( col2.g * col ), ( col1.b * ( 1 - col ) ) + ( col2.b * col ), 255 )
		surface.DrawRect( x, y + i, w, 2 )
	end
end

local function Background( w, h, text )
	local x, y = 0, 0
	
	// Top
	Gradient( 0, 0, w, 21 )
	surface.SetDrawColor( DARKGRAY )
	surface.DrawOutlinedRect( y, x, w, 21 )
	
	// Bottom
	h = h - 21
	x = 21
	
	Gradient( 0, 21, w, h )
	surface.SetDrawColor( BLACK )
	surface.DrawOutlinedRect( y + 0, x + 0, w, h ) // oops put 'y' before 'x'
	surface.DrawOutlinedRect( y + 3, x + 3, w - 6, h - 6 )
	surface.DrawOutlinedRect( y + 4, x + 4, w - 8, h - 8 )
	
	surface.SetDrawColor( DARKGRAY )
	surface.DrawOutlinedRect( y + 1, x + 1, w - 2, h - 2 )
	surface.DrawOutlinedRect( y + 2, x + 2, w - 4, h - 4 )
	surface.DrawOutlinedRect( y + 3, x + 3, w - 6, h - 6 )
	
	draw.SimpleText( text, "TabLarge", 5, 3, WHITE, 0, 0 )
	
	surface.SetDrawColor( DARKGRAY )
	surface.DrawOutlinedRect( y + 1, x + 1, w - 2, h - 2 )
end

local function VGUIControl( w, h )
	Background( w, h, "Hermes v2" )
	
	surface.SetDrawColor( BLACK )
	surface.DrawOutlinedRect( 10, 55, 430, 285 )
end

/* --------------------
	:: Menu
*/ --------------------
function HERMES.Menu()
	local wid, tal = 450, 350
	
	panel = vgui.Create( "DFrame" )
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
			panel:SetVisible( false )
		end
	end
	
	local button = vgui.Create( "DButton" )
	button:SetParent( panel )
	button:SetSize( 7, 7 )
	button:SetPos( 435, ( 21 / 2 ) - 3 )
	button:SetText( "" )
	
	function button:Paint()
		local w, h = button:GetWide(), button:GetTall()
		
		surface.SetDrawColor( 60, 60, 60, 255 )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( BLACK )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	function button:DoClick()
		panel:SetVisible( false )
		HERMES:SetRadar( false )
		HERMES:SetAdminlist( false )
		HERMES:SetSpeclist( false )
	end
	
	local lists, dlist = {}, {}
	local a, tab = 0, 0
	
	for k, v in pairs( HERMES.menu.tabs ) do
		local button = CreateButton( k, 10 + tab, 32 )
		button:SetParent( panel )
		
		lists[v] = vgui.Create( "DPanelList" )
		lists[v]:SetPos( 11, 56 )
		lists[v]:SetParent( panel )
		lists[v]:SetSize( 428, 283 )
		lists[v]:EnableVerticalScrollbar( true )
		lists[v]:SetSpacing( 5 )
		lists[v].Paint = function() end
		lists[v]:SetVisible( false )
		
		function button:DoClick()
			for r, i in pairs( lists ) do
				lists[r]:SetVisible( false )
			end
			lists[v]:SetVisible( true )
		end
		
		local npos = 0
		for i, e in pairs( HERMES.menu.tabs[k] ) do
			local button = CreateButton( e, 5, 5 + npos )
			button:SetParent( lists[v] )
			
			dlist[e] = vgui.Create( "DPanelList" )
			dlist[e]:SetPos( 80, 5 )
			dlist[e]:SetParent( lists[v] )
			dlist[e]:SetSize( 428 - 80, 283 - 5 )
			dlist[e]:EnableVerticalScrollbar( true )
			dlist[e]:SetSpacing( 5 )
			dlist[e].Paint = function() end
			dlist[e]:SetVisible( false )
			
			function button:DoClick()
				for r, i in pairs( dlist ) do
					dlist[r]:SetVisible( false )
				end
				dlist[e]:SetVisible( true )
			end
			
			npos = npos + 30
		end
		tab = tab + 80
	end
	
	local function AddItem( item, typ )
		for k, v in pairs( dlist ) do
			if ( string.find( string.lower( k ), string.lower( typ ) ) ) then
				dlist[k]:AddItem( item )
			end
		end
	end
	
	for k, v in ipairs( HERMES.menu ) do
		if ( v.Type == "checkbox" ) then
			local checkbox = HERMES:CheckBox( v.Name, v.Desc )
			AddItem( checkbox, v.Menu )
		elseif ( v.Type == "multichoice" ) then
			//local multichoice = Hermes:MultiChoice( v.Name, v.Desc, v.ConVar, v.Contents, v.None )
			//AddItem( multichoice, v.Menu )
		elseif ( v.Type == "slider" ) then
			local slider = HERMES:NumberBox( v.Name, v.Desc )
			slider:SetMax( v.Max )
			slider:SetMin( v.Min )
			AddItem( slider, v.Menu )
		end
	end
end

local function ToggleMenu()
	if( !panel ) then HERMES.Menu() return end
	if( panel:IsVisible() ) then
		panel:SetVisible( false )
		HERMES:SetRadar( false )
		HERMES:SetAdminlist( false )
		HERMES:SetSpeclist( false )
	else
		panel:SetVisible( true )
		HERMES:SetRadar( true )
		HERMES:SetAdminlist( true )
		HERMES:SetSpeclist( true )
	end
end

HERMES:AddCommand( "+hermes_menu", ToggleMenu )
HERMES:AddCommand( "-hermes_menu", ToggleMenu )

function HERMES.Initialize()
	HERMES:SetRadar( false )
	HERMES:SetAdminlist( false )
	HERMES:SetSpeclist( false )
	HERMES.hermes.ForceVar( "_hermes_sv_cheats", 1 )
end
HERMES:AddHook( "Initialize", HERMES.Initialize )