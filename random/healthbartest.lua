
function CreatePos( e )
	local ply = LocalPlayer()
	local center = e:LocalToWorld( e:OBBCenter() )
	local min, max = e:OBBMins(), e:OBBMaxs()
	local dim = max - min
	local z = max + min
	
	local frt	= ( e:GetForward() ) * ( dim.y / 2 )
	local rgt	= ( e:GetRight() ) * ( dim.x / 2 )
	local top	= ( e:GetUp() ) * ( dim.z / 2 )
	local bak	= ( e:GetForward() * -1 ) * ( dim.y / 2 )
	local lft	= ( e:GetRight() * -1 ) * ( dim.x / 2 )
	local btm	= ( e:GetUp() * -1 ) * ( dim.z / 2 )

	local s = 1
	local FRT 	= center + frt / s + rgt / s + top / s; FRT = FRT:ToScreen()
	local BLB 	= center + bak / s + lft / s + btm / s; BLB = BLB:ToScreen()
	local FLT	= center + frt / s + lft / s + top / s; FLT = FLT:ToScreen()
	local BRT 	= center + bak / s + rgt / s + top / s; BRT = BRT:ToScreen()
	local BLT 	= center + bak / s + lft / s + top / s; BLT = BLT:ToScreen()
	local FRB 	= center + frt / s + rgt / s + btm / s; FRB = FRB:ToScreen()
	local FLB 	= center + frt / s + lft / s + btm / s; FLB = FLB:ToScreen()
	local BRB 	= center + bak / s + rgt / s + btm / s; BRB = BRB:ToScreen()
	
	local z = 100
	if ( e:Health() <= 50 ) then z = 100 end
	local x, y = ( ( e:Health() / 100 ) ), 1
	if ( e:Health() <= 0 ) then x = 1 end
	local FRT3 	= center + frt + rgt + top / x; FRT3 = FRT3; FRT3 = FRT3:ToScreen()
	local BLB3 	= center + bak + lft + btm / x; BLB3 = BLB3; BLB3 = BLB3:ToScreen()
	local FLT3	= center + frt + lft + top / x; FLT3 = FLT3; FLT3 = FLT3:ToScreen()
	local BRT3 	= center + bak + rgt + top / x; BRT3 = BRT3; BRT3 = BRT3:ToScreen()
	local BLT3 	= center + bak + lft + top / x; BLT3 = BLT3; BLT3 = BLT3:ToScreen()
	local FRB3 	= center + frt + rgt + btm / x; FRB3 = FRB3; FRB3 = FRB3:ToScreen()
	local FLB3 	= center + frt + lft + btm / x; FLB3 = FLB3; FLB3 = FLB3:ToScreen()
	local BRB3 	= center + bak + rgt + btm / x; BRB3 = BRB3; BRB3 = BRB3:ToScreen()
	
	local x, y, z = 1.1, 0.9, 1
	local FRT2 	= center + frt / y + rgt / z + top / x; FRT2 = FRT2:ToScreen()
	local BLB2 	= center + bak / y + lft / z + btm / x; BLB2 = BLB2:ToScreen()
	local FLT2	= center + frt / y + lft / z + top / x; FLT2 = FLT2:ToScreen()
	local BRT2 	= center + bak / y + rgt / z + top / x; BRT2 = BRT2:ToScreen()
	local BLT2 	= center + bak / y + lft / z + top / x; BLT2 = BLT2:ToScreen()
	local FRB2 	= center + frt / y + rgt / z + btm / x; FRB2 = FRB2:ToScreen()
	local FLB2 	= center + frt / y + lft / z + btm / x; FLB2 = FLB2:ToScreen()
	local BRB2 	= center + bak / y + rgt / z + btm / x; BRB2 = BRB2:ToScreen()
	
	local maxX = math.max( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local minX = math.min( FRT.x,BLB.x,FLT.x,BRT.x,BLT.x,FRB.x,FLB.x,BRB.x )
	local maxY = math.max( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	local minY = math.min( FRT.y,BLB.y,FLT.y,BRT.y,BLT.y,FRB.y,FLB.y,BRB.y )
	
	local maxXhp = math.max( FRT3.x,BLB3.x,FLT3.x,BRT3.x,BLT3.x,FRB3.x,FLB3.x,BRB3.x )
	local minXhp = math.min( FRT3.x,BLB3.x,FLT3.x,BRT3.x,BLT3.x,FRB3.x,FLB3.x,BRB3.x )
	local maxYhp = math.max( FRT3.y,BLB3.y,FLT3.y,BRT3.y,BLT3.y,FRB3.y,FLB3.y,BRB3.y )
	local minYhp = math.min( FRT3.y,BLB3.y,FLT3.y,BRT3.y,BLT3.y,FRB3.y,FLB3.y,BRB3.y )
	
	local maxX2 = math.max( FRT2.x,BLB2.x,FLT2.x,BRT2.x,BLT2.x,FRB2.x,FLB2.x,BRB2.x )
	local minX2 = math.min( FRT2.x,BLB2.x,FLT2.x,BRT2.x,BLT2.x,FRB2.x,FLB2.x,BRB2.x )
	local maxY2 = math.max( FRT2.y,BLB2.y,FLT2.y,BRT2.y,BLT2.y,FRB2.y,FLB2.y,BRB2.y )
	local minY2 = math.min( FRT2.y,BLB2.y,FLT2.y,BRT2.y,BLT2.y,FRB2.y,FLB2.y,BRB2.y )
	
	return maxX, minX, maxY, minY, maxX2, minX2, maxY2, minY2, minYhp, maxYhp
end

function ESP()
	for k, e in pairs( player.GetAll() ) do
		if ( e:IsPlayer() && e:Alive() && e != LocalPlayer() ) then
			
			local maxX, minX, maxY, minY, maxX2, minX2, maxY2, minY2, minYhp, maxYhp = CreatePos( e )
			
			// Box
			surface.SetDrawColor( 0, 255, 0, 255 )
					
			surface.DrawLine( maxX, maxY, maxX, minY )
			surface.DrawLine( maxX, minY, minX, minY )
					
			surface.DrawLine( minX, minY, minX, maxY )
			surface.DrawLine( minX, maxY, maxX, maxY )
			
			// ESP
			draw.SimpleText( e:Nick(), "Default", maxX2, minY2, team.GetColor( e:Team() ), 4, 1 )
			draw.SimpleText( "H: " .. e:Health(), "Default", maxX2, minY2 + 10, team.GetColor( e:Team() ), 4, 1 )
			
			// Health bar
			local health = ( e:Health() ) / 2 
			
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawLine( minX - 1, minY, minX - 1, maxY )
			surface.DrawLine( minX - 6, minY, minX - 6, maxY )
			
			surface.DrawLine( minX - 6, minY, minX, minY )
			surface.DrawLine( minX - 6, maxY, minX, maxY )
			
			local pos, using = 2
			if ( e:Health() <= 49 ) then using = maxYhp else using = minYhp end
			for i = 1, 4 do
				surface.SetDrawColor( 0, 0, 0, 255 )
				surface.DrawLine( minX - pos, ( minY + 1 ), minX - pos, maxY )
				surface.SetDrawColor( team.GetColor( e:Team() ) )
				surface.DrawLine( minX - pos, ( minYhp + 1 ), minX - pos, maxY )
				pos = pos + 1
			end
	
			//surface.SetDrawColor( team.GetColor( e:Team() ) )
			//surface.DrawRect( minX2, minY2, 10, health )
		end
	end
end
hook.Add( "HUDPaint", "hudtest", ESP )