/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/radar.lua
	Purpose: Radar
*************************************************************/

local radar = nil

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
	Background( w, h, "Radar" )
end

/* --------------------
	:: Radar
*/ --------------------
local function Radar()
	radar = vgui.Create( "DFrame" )
	radar:SetSize( 250, 250 )
	
	local w, h = radar:GetWide(), radar:GetTall()
	radar:SetPos( xn - w - 10, yn - h - ( yn - h ) + 10 )
	radar:SetTitle( "" )
	radar:SetVisible( true )
	radar:SetDraggable( true )
	radar:ShowCloseButton( false )
	radar:MakePopup()
	
	local range = 10
	function radar:SetRange( int )
		range = int
	end
	
	function radar:Paint()
		VGUIControl( w, h )
		
		// Radar Function
		local ply = LocalPlayer()
		
		local radar = {}
		radar.h		= 250 - 32
		radar.w		= 250 - 12
		radar.org	= range * 100
		
		local x, y = ScrW() / 2, ScrH() / 2
		
		local hlfX, hlfY = ( w / 2 ), ( h / 2 ) + 10
		surface.SetDrawColor( DARKGRAY )
		surface.DrawLine( hlfX, hlfY - 95, hlfX, hlfY + 90 )
		surface.DrawLine( hlfX - 100, hlfY, hlfX + 100, hlfY )
		
		for k, e in ipairs( player.GetAll() ) do
			if( HERMES:FilterTargets( e, "radar" ) ) then
				local s = 6
				local color = HERMES:TargetColors( e )
				local plyfov = ply:GetFOV() / ( 70 / 1.13 )
				local zpos, npos = ply:GetPos().z - ( e:GetPos().z ), ( ply:GetPos() - e:GetPos() )
				
				npos:Rotate( Angle( 180, ( ply:EyeAngles().y ) * -1, -180 ) )
				local iY = npos.y * ( radar.h / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
				local iX = npos.x * ( radar.w / ( ( radar.org * ( plyfov  * ( ScrW() / ScrH() ) ) ) + zpos * ( plyfov  * (ScrW() / ScrH() ) ) ) )
				
				local pX = ( radar.w / 2 )
				local pY = ( radar.h / 2 )
				
				local posX = pX - iY - ( s / 2 ) + 6
				local posY = pY - iX - ( s / 2 ) + 26
					
				if ( iX < ( radar.h / 2 ) && iY < ( radar.w / 2 ) && iX > ( -radar.h / 2 ) && iY > ( -radar.w / 2 ) ) then
					local text = e:IsPlayer() && e:Nick() || e:GetClass()
					draw.RoundedBox( 0, posX, posY, s, s, color )
				end
			end
		end
	end
	
	radar:SetMouseInputEnabled( false )
	radar:SetKeyboardInputEnabled( false )
end

function HERMES:SetRadar( vis )
	if( !radar ) then Radar() end
	radar:SetMouseInputEnabled( vis || false )
	radar:SetKeyboardInputEnabled( vis || false )
end

function HERMES:GetRadar()
	return radar
end