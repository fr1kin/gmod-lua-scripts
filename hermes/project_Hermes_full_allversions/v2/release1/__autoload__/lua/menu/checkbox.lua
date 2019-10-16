/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/checkbox.lua
	Purpose: Checkbox
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
	:: Checkbox
*/ --------------------
local CHECKBOX = {}
CHECKBOX.Text = nil
CHECKBOX.Font = nil
CHECKBOX.TextColor = nil
CHECKBOX.State = false
CHECKBOX.CVar = nil
CHECKBOX.GotCVar = false

/* --------------------
	:: Init
*/ --------------------
function CHECKBOX:Init()
	self.Text = NONE
	self.Font = "TabLarge"
	self.TextColor = WHITE
	self.CVar = ""
	
	self:SetSize( 350, 15 )
end

/* --------------------
	:: SetVar
*/ --------------------
function CHECKBOX:SetVar( var )
	self.CVar = var
end

function CHECKBOX:GetVar()
	return self.CVar
end

/* --------------------
	:: State
*/ --------------------
function CHECKBOX:SetState( var )
	self.State = tobool( var )
end

function CHECKBOX:GetState()
	return self.State
end

/* --------------------
	:: Text
*/ --------------------
function CHECKBOX:SetText( str )
	self.Text = str || NONE
end

function CHECKBOX:GetText()
	return self.Text
end

/* --------------------
	:: Font
*/ --------------------
function CHECKBOX:SetFont( str )
	self.Font = str
end

function CHECKBOX:GetFont()
	return self.Font
end

/* --------------------
	:: Font Color
*/ --------------------
function CHECKBOX:SetFontColor( col )
	self.TextColor = col || WHITE
end

function CHECKBOX:GetFontColor()
	return self.TextColor
end

/* --------------------
	:: Font Color
*/ --------------------
function CHECKBOX:OnMousePressed()
	self.State = !self.State
	HERMES:RunCommand( self.CVar, self.State == true && 1 || 0 )
end

/* --------------------
	:: Loadup
*/ --------------------
function CHECKBOX:Think()
	if( !self.CVar ) then return end
	if( !self.GotCVar ) then
		local cvar = HERMES:GetVarNumber( self.CVar )
		self.State = tobool( cvar )
		
		self.GotCVar = true
	end
end

/* --------------------
	:: PaintOver
*/ --------------------
function CHECKBOX:PaintOver()
	local w, h = 15, 15
	local len = string.len( self.Text )
	draw.SimpleText( self.Text, self.Font, 25, 0, self.TextColor, 0, 0 )
	
	local ORIGINAL = Color( 41, 41, 41, 255 )
	if( self.State ) then
		ORIGINAL = Color( 20, 80, 140, 255 )
	end
	
	surface.SetDrawColor( ORIGINAL )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, w, h )
	
	saves.len[string.gsub( self.Text, " ", "_" )] = len
end

// Create VGUI tool
vgui.Register( "HCheckbox", CHECKBOX )

/* --------------------
	:: Checkbox
*/ --------------------
function HERMES:CheckBox( var, str )
	local checkbox = vgui.Create( "HCheckbox" )
	checkbox:SetText( str )
	checkbox:SetVar( var )
	return checkbox
end
