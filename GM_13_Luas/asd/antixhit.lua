local function test()
	for k, v in pairs( ents.GetAll() ) do
		if( v && IsValid( v ) && v != LocalPlayer() && ( v:IsNPC() || v:IsPlayer() ) ) then
			if( v:IsPlayer() && v:Alive() == false ) then
				continue;
			end
			if( v:IsNPC() && v:GetMoveType() == 0 ) then
				continue;
			end
			local bonepos = v:GetBonePosition( v:LookupBone( "ValveBiped.Bip01_Head1" ) );
			local scn = bonepos:ToScreen();
			draw.SimpleText( "BONE", "Default", scn.x, scn.y, Color( 255, 255, 0, 255 ), 1, 1 );
		end
	end
end

hook.Add( "HUDPaint", "sas", test );