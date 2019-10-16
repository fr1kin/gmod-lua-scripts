local target = nil;
local function Penis()
	if( !target || target && !ValidEntity( target ) || target && !target:Alive() ) then
		target = nil
	end
	
	for k, v in pairs( player.GetAll() ) do
		if( v:IsValid() &&
			v:Alive() &&
			v:GetMoveType() != MOVETYPE_NONE &&
			v != LocalPlayer() ) then
			
			local org = v:GetPos();
			local min = v:OBBMins();
			local max = v:OBBMaxs();
			debugoverlay.Box( org, min, max, 0.02, Color( 255, 255, 255, 0 ), false )
			debugoverlay.Text( v:GetPos() + Vector( 0, 0, 50 ), v:Nick(), 0.01 );
			
			if( target == nil ) then
				target = v
			end
			
			if( target == v && input.IsKeyDown( KEY_F ) ) then
				local pos = ( v:GetPos() + Vector( 0, 0, 50 ) ):ToScreen();
				input.SetCursorPos( pos.x, pos.y )
				target = v;
			end
		end
	end
	timer.Simple( 0.01, Penis )
end
Penis()