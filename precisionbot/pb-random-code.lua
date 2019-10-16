function VH.CreateTargets( e )

	Targets = {}

	local ply = LocalPlayer()
	
	for k, e in pairs( ents.GetAll() ) do
	
		local v = {}
		v.text  = {}
	
		if ( ValidEntity( e ) && VH:DoChecks( e ) && EspEnabled:GetBool() && e ~= ply ) then
	
			local axX, inX, axY, inY, osX, osY = VH:CreateVectors(e)
			local vecs = { axX, inX, axY, inY, osX, osY }
			local maxX, minX, maxY, minY, posX, posY = unpack( vecs )
			
			local class, model, s = e:GetClass(), e:GetModel(), "\n"
			local col = VH:SetColors(e)
			
			local text
		
			if ( e:IsPlayer() ) then
	
				if ( EspName:GetBool() ) then
					table.insert( v.text, e:Nick() )
					text = text .. e:Nick()
				end
		
				if ( EspHealth:GetBool() ) then
					table.insert( v.text, "\nHP: " .. e:Health() )
					text = text .. "\nHP: " .. e:Health()
				end
			
				if ( EspWeapon:GetBool() && e:GetActiveWeapon():IsValid() ) then
			
					local wep = e:GetActiveWeapon():GetPrintName()
				
					wep = string.Replace( wep, "#HL2_", "" )
					wep = string.Replace( wep, "#GMOD_", "" )
					wep = string.Replace( wep, "_", "" )
			
					wep = string.lower( wep )
			
					table.insert( v.text, "\nW: " .. wep )
					text = text .. "\nW: " .. wep
				end
			end
	
			if ( e:IsNPC() ) then
	
				if ( EspNpc:GetBool() ) then
				
					local npc = class
			
					npc = string.Replace( npc, "npc_", "" )
					npc = string.Replace( npc, "_", "" )
			
					npc = string.lower( npc )
			
					table.insert( v.text, npc )
					text = text .. npc
				end
			end
	
			if ( e:IsWeapon() ) then
		
				if ( EspEntity:GetBool() ) then
		
					local ent = class
			
					ent = string.Replace( ent, "weapon_", "" )
					ent = string.Replace( ent, "ttt_", "" )
					ent = string.Replace( ent, "zm_", "" )
					ent = string.Replace( ent, "_", "" )
			
					ent = string.lower( ent )
			
					table.insert( v.text, ent )
					text = text .. ent
				end
			end
			
			v.col  = col
			v.maxX = maxX
			v.minX = minX
			v.maxY = maxY
			v.minY = minY
			v.posX = ToScreen( posX )
			v.posY = ToScreen( posY )
		
			table.insert( Targets, v )
			
			return text
		end
	end
end

VH:AddHook( "Think", VH.CreateTargets )

/*-------------------------
	Extra Sensory Perception
	Desc: This is the part where it hooks up and draws
	all the shit on the screen.
*/-------------------------

function VH.Extrasensory()

	local ply = LocalPlayer()
	
	for k, e in pairs( Targets ) do

		local text = string.Implode( "", e.text )
			
		draw.DrawText(
			text,
			"DefaultSmall",
			e.posX.x,
			e.posY.y,
			e.col,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP
		)
			
		surface.SetDrawColor( e.col.r, e.col.g, e.col.b, 255 )

		surface.DrawLine( e.maxX, e.maxY, e.maxX, e.minY )
		surface.DrawLine( e.maxX, e.minY, e.minX, e.minY )
			
		surface.DrawLine( e.minX, e.minY, e.minX, e.maxY )
		surface.DrawLine( e.minX, e.maxY, e.maxX, e.maxY )
	end
end

VH:AddHook( "HUDPaint", VH.Extrasensory )