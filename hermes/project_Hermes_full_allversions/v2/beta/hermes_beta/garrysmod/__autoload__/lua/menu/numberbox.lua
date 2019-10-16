/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/numberbox.lua
	Purpose: Numberbox
*************************************************************/

local NONE = ""

local LEFT = 0
local RIGHT = 1

local WHITE = Color( 255, 255, 255 )
local BLACK = Color( 0, 0, 0 )
local RED = Color( 255, 0, 0 )
local BLUE = Color( 0, 255, 0 )
local GREEN = Color( 0, 0, 255 )

local saves = {
	len = {},
}

/* --------------------
	:: Slider
*/ --------------------
local NUMBERBOX = {}
NUMBERBOX.Text = nil
NUMBERBOX.Font = nil
NUMBERBOX.TextColor = nil
NUMBERBOX.Int = nil
NUMBERBOX.Max = nil
NUMBERBOX.Min = nil

NUMBERBOX.AddButton = nil
NUMBERBOX.SubButton = nil

/* --------------------
	:: Init
*/ --------------------
function NUMBERBOX:Init()
	self.Text = NONE
	self.Font = "TabLarge"
	self.TextColor = WHITE
	self.Int = 0
	self.Max = 1
	self.Min = 0
	
	self:SetSize( 350, 15 )
	
	// AddButton
	self.AddButton = vgui.Create( "DButton" )
	self.AddButton:SetParent( self )
	self.AddButton:SetSize( 15, 15 )
	self.AddButton:SetPos( 0, 0 )
	self.AddButton:SetText( NONE )
	
	function self.AddButton.DoClick()
		if( self.Int == self.Max ) then return end
		self.Int = self.Int + 1
	end
	
	function self.AddButton.Paint()
		local ORIGINAL = Color( 0, 0, 0, 0 )
		if( self.AddButton.Depressed ) then
			ORIGINAL = Color( 20, 80, 140, 255 )
		end
		
		local w, h = 15, 15
		surface.SetDrawColor( ORIGINAL )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		
		draw.SimpleText( "+", self.Font, (w / 2) - 0.5, (h / 2) - 0.5, self.TextColor, 1, 1 )
	end
	
	// SubButton
	self.SubButton = vgui.Create( "DButton" )
	self.SubButton:SetParent( self )
	self.SubButton:SetSize( 15, 15 )
	self.SubButton:SetPos( 51, 0 )
	self.SubButton:SetText( NONE )
	
	function self.SubButton.DoClick()
		if( self.Int == self.Min ) then return end
		self.Int = self.Int - 1
	end
	
	function self.SubButton.Paint()
		local ORIGINAL = Color( 0, 0, 0, 0 )
		if( self.SubButton.Depressed ) then
			ORIGINAL = Color( 20, 80, 140, 255 )
		end
		
		local w, h = 15, 15
		surface.SetDrawColor( ORIGINAL )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		
		draw.SimpleText( "-", self.Font, (w / 2) - 0.5, (h / 2) - 0.5, self.TextColor, 1, 1 )
	end
end

/* --------------------
	:: Max
*/ --------------------
function NUMBERBOX:SetMax( int )
	self.Max = int || 1
end

function NUMBERBOX:GetMax()
	return self.Max
end

/* --------------------
	:: Min
*/ --------------------
function NUMBERBOX:SetMin( int )
	self.Min = int || 0
end

function NUMBERBOX:GetMin()
	return self.Min
end

/* --------------------
	:: Text
*/ --------------------
function NUMBERBOX:SetText( str )
	self.Text = str || NONE
end

function NUMBERBOX:GetText()
	return self.Text
end

/* --------------------
	:: Font
*/ --------------------
function NUMBERBOX:SetFont( str )
	self.Font = str
end

function NUMBERBOX:GetFont()
	return self.Font
end

/* --------------------
	:: Font Color
*/ --------------------
function NUMBERBOX:SetFontColor( col )
	self.TextColor = col || WHITE
end

function NUMBERBOX:GetFontColor()
	return self.TextColor
end

/* --------------------
	:: PaintOver
*/ --------------------
function NUMBERBOX:PaintOver()
	local w, h = 15, 15
	local len = string.len( self.Text )
	draw.SimpleText( self.Text, self.Font, 73, 0, self.TextColor, 0, 0 )
	draw.SimpleText( string.format( "(%s)", tostring( self.Int ) ), self.Font, 33, 0, self.TextColor, 1, 0 )
	
	saves.len[string.gsub( self.Text, " ", "_" )] = len
end

// Create VGUI tool
vgui.Register( "HNumberbox", NUMBERBOX )

/* --------------------
	:: NUMBERBOX
*/ --------------------
function HERMES:NumberBox( var, str, help )
	local numberbox = vgui.Create( "HNumberbox" )
	numberbox:SetText( str )
	return numberbox
end
