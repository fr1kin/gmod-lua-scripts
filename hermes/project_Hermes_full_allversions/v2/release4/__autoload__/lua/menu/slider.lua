/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/slider.lua
	Purpose: Slider
*************************************************************/

local table = table.Copy( table )
local vgui = table.Copy( vgui )

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
local SLIDER = {}
SLIDER.Text = nil
SLIDER.Font = nil
SLIDER.TextColor = nil
SLIDER.Int = nil
SLIDER.Max = nil
SLIDER.Min = nil

SLIDER.X = nil

/* --------------------
	:: Init
*/ --------------------
function SLIDER:Init()
	self.Text = NONE
	self.Font = "TabLarge"
	self.TextColor = WHITE
	self.Int = 0
	self.Max = 1
	self.Min = 0
	self.X = 5
	
	self:SetSize( 350, 15 )
end

/* --------------------
	:: Max
*/ --------------------
function SLIDER:SetMax( int )
	self.Max = int || 1
end

function SLIDER:GetMax()
	return self.Max
end

/* --------------------
	:: Min
*/ --------------------
function SLIDER:SetMin( int )
	self.Min = int || 0
end

function SLIDER:GetMin()
	return self.Min
end

/* --------------------
	:: Text
*/ --------------------
function SLIDER:SetText( str )
	self.Text = str || NONE
end

function SLIDER:GetText()
	return self.Text
end

/* --------------------
	:: Font
*/ --------------------
function SLIDER:SetFont( str )
	self.Font = str
end

function SLIDER:GetFont()
	return self.Font
end

/* --------------------
	:: Font Color
*/ --------------------
function SLIDER:SetFontColor( col )
	self.TextColor = col || WHITE
end

function SLIDER:GetFontColor()
	return self.TextColor
end

/* --------------------
	:: PaintOver
*/ --------------------
function SLIDER:PaintOver()
	local w, h = 200, 15
	local len = string.len( self.Text )
	draw.SimpleText( self.Text, self.Font, 73, 0, self.TextColor, 0, 0 )
	draw.SimpleText( string.format( "(%s)", tostring( self.Int ) ), self.Font, 33, 0, self.TextColor, 1, 0 )
	
	// Main
	surface.SetDrawColor( 20, 80, 140, 255 )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, w, h )
	
	/*
	// Knob
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( 0, 0, 5, 14 )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, 5, 14 )
	*/
	
	saves.len[string.gsub( self.Text, " ", "_" )] = len
end

// Create VGUI tool
vgui.Register( "HSlider", SLIDER )

/* --------------------
	:: SLIDER
*/ --------------------
function HERMES:Slider( var, str, help )
	local slider = vgui.Create( "HSlider" )
	slider:SetText( str )
	return slider
end