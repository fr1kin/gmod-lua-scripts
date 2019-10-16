/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: menusystem/list.lua
	Purpose: Friend/Entity list
*************************************************************/

local friend, entity = nil, nil

/* --------------------
	:: Friend list
*/ --------------------
function HERMES:Friendslist( parent )
	local combobox = vgui.Create( "DComboBox" )
	combobox:SetParent( parent )
	combobox:SetPos( 10 + 10, 15 + 10 )
	combobox:SetSize( 180, 250 )
	combobox:SetMultiple( false )
	
	local fcombobox = vgui.Create( "DComboBox" )
	fcombobox:SetParent( parent )
	fcombobox:SetPos( 10 + 10, 15 + 10 )
	fcombobox:SetSize( 180, 250 )
	fcombobox:SetMultiple( false )
	
	local function AddToList()
		combobox:Clear();
		fcombobox:Clear();
		
		local all, friends = HERMES:ReadList()
		for k, e in pairs( add ) do
			combobox2:AddItem( e:Nick() )
		end
		
		for k, e in pairs( rem ) do
			combobox1:AddItem( e:Nick() )
		end
	end
end