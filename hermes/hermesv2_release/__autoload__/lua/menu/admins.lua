/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/admins.lua
	Purpose: Adminlist
*************************************************************/

local table = table.Copy( table )
local vgui = table.Copy( vgui )

local admin = nil

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
	Background( w, h, "Admins" )
end

/* --------------------
	:: GetAdmins
*/ --------------------
local function GetAdmins()
	local admins = {}
	for k, e in ipairs( player.GetAll() ) do
		local isAdmin = HERMES:IsAdmin( e )
		if( isAdmin[1] == true ) then
			admins[e] = isAdmin[2]
		end
	end
	
	local size = 40
	for k, v in pairs( admins ) do
		size = size + 15
	end
	return size, admins
end

/* --------------------
	:: Adminlist
*/ --------------------
local function Adminlist()
	admin = vgui.Create( "DFrame" )
	admin:SetSize( 250, 40 )
	
	local w, h, x, y = admin:GetWide(), admin:GetTall(), ScrW() / 2, ScrH() / 2
	admin:SetPos( ScrW() - w - 10, ScrH() -  h - ( ScrH() - h ) + 270 )
	admin:SetTitle( "" )
	admin:SetVisible( true )
	admin:SetDraggable( true )
	admin:ShowCloseButton( false )
	admin:MakePopup()
	
	function admin:Paint()
		local high, admins = GetAdmins()
		
		admin:SetSize( 250, high )
		VGUIControl( w, high )
		
		local pos = 30
		for k, v in pairs( admins ) do
			draw.SimpleText(
				string.format( "%s [%s]", k:Nick(), v ),
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
	
	admin:SetMouseInputEnabled( false )
	admin:SetKeyboardInputEnabled( false )
end

function HERMES:SetAdminlist( vis )
	if( !admin ) then Adminlist() end
	admin:SetMouseInputEnabled( vis || false )
	admin:SetKeyboardInputEnabled( vis || false )
end

function HERMES:GetAdminlist()
	return admin
end