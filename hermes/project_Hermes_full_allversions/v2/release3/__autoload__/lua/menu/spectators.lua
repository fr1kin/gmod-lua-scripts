/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/spectators.lua
	Purpose: Spectatorlist
*************************************************************/

local table = table.Copy( table )
local vgui = table.Copy( vgui )

local spectators = nil

local NONE = ""

local GRAY = Color( 40, 40, 40 )
local DARKGRAY = Color( 50, 50, 50 )
local GREEN = Color( 89, 106, 69 )
local BLACK = Color( 0, 0, 0 )
local WHITE = Color( 255, 255, 255 )

local xn, yn, x, y = ScrW(), ScrH(), ScrW() / 2, ScrH() / 2

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
	Background( w, h, "Spectators" )
end

/* --------------------
	:: GetSpectators
*/ --------------------
local function GetSpectators()
	local ply, specs = LocalPlayer(), {}
	for k, e in ipairs( player.GetAll() ) do
		local isSpectator = e:GetObserverTarget() == ply && true || false
		if( isSpectator ) then
			specs[e] = true
		end
	end
	
	local size = 40
	for k, v in pairs( specs ) do
		size = size + 15
	end
	return size, specs
end

/* --------------------
	:: Spectatorlist
*/ --------------------
local function Spectatorlist()
	spectators = vgui.Create( "DFrame" )
	spectators:SetSize( 250, 40 )
	
	local w, h, x, y = spectators:GetWide(), spectators:GetTall(), ScrW() / 2, ScrH() / 2
	spectators:SetPos( 20, 20 )
	spectators:SetTitle( "" )
	spectators:SetVisible( true )
	spectators:SetDraggable( true )
	spectators:ShowCloseButton( false )
	spectators:MakePopup()
	
	function spectators:Paint()
		local high, spec = GetSpectators()
		
		spectators:SetSize( 250, high )
		VGUIControl( w, high )
		
		local pos = 30
		for k, v in pairs( spec ) do
			draw.SimpleText(
				k:Nick(),
				"Default",
				10,
				pos,
				Color( 0, 255, 0, 255 ),
				0,
				0
			)
			pos = pos + 12
		end
	end
	
	spectators:SetMouseInputEnabled( false )
	spectators:SetKeyboardInputEnabled( false )
end

function HERMES:SetSpeclist( vis )
	if( !spectators ) then Spectatorlist() end
	spectators:SetMouseInputEnabled( vis || false )
	spectators:SetKeyboardInputEnabled( vis || false )
end

function HERMES:GetSpeclist()
	return spectators
end