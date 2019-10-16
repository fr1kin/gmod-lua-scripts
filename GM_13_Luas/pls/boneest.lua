
local function GetHighestBone( pl )
	local pos = Vector( 0, 0, 0 );
	local bestbone = 0;
	local mins, maxs = pl:OBBMins(), pl:OBBMaxs();
	debugoverlay.Box( pl:GetPos(), mins, maxs, FrameTime(), Color( 0, 255, 0, 60 ), false );
	mins.x = mins.x / 2;
	mins.y = mins.y / 2;
	maxs.x = maxs.x / 2;
	maxs.y = maxs.y / 2;
	print( "vel: ", pl:GetVelocity() );
	for i = 0, pl:GetBoneCount() do
		local bpos = pl:GetBonePosition( i );
		if( bpos ) then
			bpos = pl:WorldToLocal( bpos );
			if( ( bpos.z > pos.z ) &&
				( bpos.y > mins.y ) &&
				( bpos.x > mins.x ) &&
				( bpos.x < maxs.x ) &&
				( bpos.y < maxs.y )
				) then
				pos = bpos;
				bestbone = i;
			end
		end
	end
	return pl:GetBonePosition( bestbone );
end

local function test()
	for k, v in pairs( ents.GetAll() ) do
		if( v && IsValid( v ) && v != LocalPlayer() && ( v:IsNPC() || v:IsPlayer() ) ) then
			if( v:IsPlayer() && v:Alive() == false ) then
				continue;
			end
			if( v:IsNPC() && v:GetMoveType() == 0 ) then
				continue;
			end
			local bonepos = GetHighestBone( v );
			local scn = bonepos:ToScreen();
			draw.SimpleText( "BONE", "Default", scn.x, scn.y, Color( 255, 255, 0, 255 ), 1, 1 );
		end
	end
end

hook.Add( "HUDPaint", "sas", test );