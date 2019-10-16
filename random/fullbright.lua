function Fullbright()
	for k, e in pairs( e:GetMaterial
	cam.Start3D( EyePos(), EyeAngles() )
		render.SuppressEngineLighting( true )
		
	cam.End3D()
end
hook.Add( "RenderScreenspaceEffects", "test", Fullbright )