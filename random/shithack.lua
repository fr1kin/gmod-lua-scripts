//LOL CODED IN 5 MINUTES BY FR1KIN, THIS IS SHIT BTW
local aim, tar, target = false, nil, nil

function Visible(ply)
local trace = {start = LocalPlayer():GetShootPos(),endpos = ply:GetBonePosition( ply:LookupBone( "ValveBiped.Bip01_Head1" ) ),filter = {LocalPlayer(), ply}}
local tr = util.TraceLine(trace)
if tr.Fraction == 1 then
return true
else
return false
end	
end

function FindAllTargets()
	tar = LocalPlayer()
	for k, v in pairs( ents.GetAll() ) do
		if ( ValidEntity( v ) && ( v:IsPlayer() && v:Alive() || v:IsNPC() && v:GetMoveType() != 0 ) && Visible( v ) ) then
			local oP, tP = v:EyePos():ToScreen(), tar:EyePos():ToScreen()
			local a = math.Dist( ScrW() / 2, ScrH() / 2, oP.x, oP.y )
			local b = math.Dist( ScrW() / 2, ScrH() / 2, tP.x, tP.y )
			if ( b <= a ) then
				tar = v
			elseif ( target == LocalPlayer() ) then
				tar = v
			end
		end
	end
	return tar
end

function Aimbot( ucmd )
	target = FindAllTargets()
	
	if ( !aim ) then return end
	if ( target == nil || target == LocalPlayer() ) then return end
	
	local view = target:GetBonePosition( target:LookupBone( "ValveBiped.Bip01_Head1" ) )
	view = view + ( target:GetVelocity() / 45 + LocalPlayer():GetVelocity() / 45 )
	
	local angle = ( view - LocalPlayer():GetShootPos() ):Angle()
	
	angle.p = math.NormalizeAngle( angle.p )
	angle.y = math.NormalizeAngle( angle.y )
	
	angle.r = 0
	
	ucmd:SetViewAngles( angle )
	
	if ( aiming && target != nil || target != LocalPlayer() ) then
		RunConsoleCommand( "+attack" )
		timer.Simple( 0.1, function() RunConsoleCommand( "-attack" ) end )
	end
end
hook.Add( "CreateMove", "AINGNJD", Aimbot )

concommand.Add( "+aimbot", function() aim = true target = nil end )
concommand.Add( "-aimbot", function() aim = false target = nil end )

function ESP()
	for k, v in pairs( ents.GetAll() ) do
		if ( v:IsPlayer() && v:Alive() && v != LocalPlayer() ) then
			local pos = ( v:LocalToWorld( v:OBBCenter() ) - Vector( 0, 0, 15 ) ):ToScreen()
			draw.SimpleText( v:Nick() .. " | hp: " .. v:Health(), "Default", pos.x, pos.y, team.GetColor( v:Team() ), 0, 0 )
			
			local pos = v:LocalToWorld( v:OBBCenter() ):ToScreen()
			draw.RoundedBox( 0, pos.x, pos.y, 5, 5, Color( 0, 255, 0, 255 ) )
		elseif ( v:IsPlayer() && !v:Alive() && v != LocalPlayer() ) then
			local pos = ( v:LocalToWorld( v:OBBCenter() ) - Vector( 0, 0, 15 ) ):ToScreen()
			draw.SimpleText( v:Nick() .. " | *DEAD*", "Default", pos.x, pos.y, Color( 0, 0, 0, 255 ), 0, 0 )
			
			local pos = v:LocalToWorld( v:OBBCenter() ):ToScreen()
			draw.RoundedBox( 0, pos.x, pos.y, 5, 5, Color( 0, 0, 0, 255 ) )
		elseif ( v:IsNPC() && v:GetMoveType() != 0 ) then
			local pos = v:LocalToWorld( v:OBBCenter() ):ToScreen()
			draw.RoundedBox( 0, pos.x, pos.y, 5, 5, Color( 0, 255, 0, 255 ) )
		elseif ( ValidEntity( v ) && v:GetMoveType() != 0 ) then
			local pos = v:LocalToWorld( v:OBBCenter() ):ToScreen()
			draw.SimpleText( v:GetClass(), "Default", pos.x, pos.y, Color( 0, 0, 255, 255 ), 0, 0 )
		end
	end
end
hook.Add( "HUDPaint", "SFDFDGGDG", ESP )