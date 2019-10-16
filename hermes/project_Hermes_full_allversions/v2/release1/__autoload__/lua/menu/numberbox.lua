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
NUMBERBOX.CVar = nil
NUMBERBOX.GotCVar = false

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
	self.CVar = ""
	
	self:SetSize( 350, 15 )
	
	// AddButton
	self.AddButton = vgui.Create( "DButton" )
	self.AddButton:SetParent( self )
	self.AddButton:SetSize( 15, 15 )
	self.AddButton:SetPos( 51, 0 )
	self.AddButton:SetText( NONE )
	
	local function AddSub()
		HERMES:RunCommand( self.CVar, self.Int )
	end
	
	local addPass, addOnce = 0, false
	function self.AddButton.Paint()
		local ORIGINAL = Color( 41, 41, 41, 255 )
		if( self.AddButton.Depressed ) then
			ORIGINAL = Color( 20, 80, 140, 255 )
			
			if( !addOnce && ( self.Int != self.Max ) ) then self.Int = self.Int + 1; addOnce = true; AddSub() end
			if( addPass > 10 && ( self.Int != self.Max ) ) then
				self.Int = self.Int + 1
				AddSub()
			end
			addPass = addPass + 1
		else
			addOnce = false
			addPass = 0
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
	self.SubButton:SetPos( 0, 0 )
	self.SubButton:SetText( NONE )
	
	local subPass, subOnce = 0, false
	function self.SubButton.Paint()
		local ORIGINAL = Color( 41, 41, 41, 255 )
		if( self.SubButton.Depressed ) then
			ORIGINAL = Color( 20, 80, 140, 255 )
			
			if( !subOnce && ( self.Int != self.Min ) ) then self.Int = self.Int - 1; subOnce = true; AddSub() end
			if( subPass > 10 && ( self.Int != self.Min ) ) then
				self.Int = self.Int - 1
				AddSub()
			end
			subPass = subPass + 1
		else
			subOnce = false
			subPass = 0
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
	:: SetVar
*/ --------------------
function NUMBERBOX:SetVar( var )
	self.CVar = var
end

function NUMBERBOX:GetVar()
	return self.CVar
end

/* --------------------
	:: Loadup
*/ --------------------
function NUMBERBOX:Think()
	if( !self.CVar ) then return end
	if( !self.GotCVar ) then
		local cvar = HERMES:GetVarNumber( self.CVar )
		self.Int = cvar
		
		self.GotCVar = true
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
function HERMES:NumberBox( var, str )
	local numberbox = vgui.Create( "HNumberbox" )
	numberbox:SetText( str )
	numberbox:SetVar( var )
	return numberbox
end
