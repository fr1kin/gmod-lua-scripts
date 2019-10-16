--[[

	~ coded by seth ~
]]

//include( 'includes/init.lua' )
local draw = table.Copy(draw)
local surface = table.Copy(surface)
local team = table.Copy(team)
local col = _G.Color

local Enabled = CreateClientConVar("xhit_esp_bb", 1, true, false)
local boxtype = CreateClientConVar("xhit_esp_bbt",1)

local barrel = CreateClientConVar("xhit_esp_barrel",0)


function Penis( )
	if( barrel:GetBool() ) then
		cam.Start3D( EyePos(), EyeAngles() )
			for k, pl in pairs( player.GetAll() ) do
				if pl && IsValid( pl ) && ( pl:IsPlayer() && pl:Alive() || !pl:IsPlayer() && pl:GetMoveType() != 0 || false ) && pl != LocalPlayer() then
					local color = Color( 255, 255, 255, 255 );
					if( pl:IsPlayer() ) then
						local tr = pl:GetEyeTrace();
						color = team.GetColor( pl:Team() );
						color.a = 255;
						render.DrawLine( pl:GetShootPos(), tr.HitPos, color, true );
					end
					
					//render.DrawBox( Vector position, Angle angles, Vector mins, Vector maxs, Color color, boolean writeZ )
					//render.SetMaterial( Material( "models/debug/debugwhite" ) );
					//render.DrawWireframeBox( pl:GetPos(), pl:GetAngles(), pl:OBBMins(), pl:OBBMaxs(), color, false );
				end
			end
		cam.End3D()
	end
end
hook.Add( "RenderScreenspaceEffects", "Penis", Penis )


surface.CreateFont("DefaultSmallDropShadow", {
		font	= "Tahoma",
		size	= 16,
		weight	= 500,
		shadow	= true,
	}
)	

local function halfbox()
	if boxtype:GetInt() == 1 then return 2
elseif boxtype:GetInt() == 2 then return 4
	end
	return 2
end


local TRANS = col(0,0,0,255)

local nb = {
	"spawned_money",
	"spawned_weapon",
};

local function rpesp()
//if GAMEMODE.Name == 'PostNukeRP' or prp:GetBool() then
for k, ent in pairs(ents.FindByClass('base_item')) do
if IsValid(ent) then

GAMEMODE.DayZ_Items = GAMEMODE.DayZ_Items or {}

if (ent:GetNWString("Class")) and ent:GetNWString("Class") then
if (GAMEMODE.DayZ_Items[ent:GetNWString("Class")].IDName) then

local pos = (ent:GetPos():ToScreen())
draw.SimpleText(GAMEMODE.DayZ_Items[ent:GetNWString("Class")].IDName, "default" ,pos.x, pos.y, Color(0,255,0,255), 1 )
end
end
end
end
end
hook.Add('PostRenderVGUI','rpesp',rpesp)

local function DrawESP()
	
	
	local x,y,color
	local mon,nom
	local h,w
	local bot,top
	local sx,sy
	local size = 5
	
	/*
	for k, v in pairs(ents.GetAll()) do 
		if IsValid(v) then
			if v:GetMoveType() == MOVETYPE_NONE then continue; end
			if type(v) == 'weapon' or type(v) == 'Weapon' or v:GetClass() == 'spawned_weapon' or 
				table.HasValue(nb,v:GetClass()) then
				if not v:GetOwner():IsPlayer() && !table.HasValue(LocalPlayer():GetTable().Pocket || {}, v) then
					local pos = (v:GetPos():ToScreen())
					draw.SimpleText(v:GetClass(), "DefaultSmallDropShadow" ,pos.x, pos.y, Color(40,255,0,240), 1 )
				end
			end
		end
	end
	*/
	
	for k,v in pairs( player.GetAll() ) do
		if not IsValid(v) or not v:Alive() or v == LocalPlayer() then
			continue
		end
		if v:Team() == TEAM_SPECTATOR or v:GetMoveType() == MOVETYPE_OBSERVER then
			continue
		end
		
		local tCol = team.GetColor( v:Team() )
		
		tCol.a = 255;
		
		nom = v:GetPos()
		mon = nom + Vector( 0, 0, v:OBBMaxs().z )
		
		bot = nom:ToScreen()
		top = mon:ToScreen()
		
		if( !bot || !top ) then
			continue;
		end
		
		h = ( bot.y - top.y )
		w = h;
		
		sx,sy = 0,0;
		
		
		// Top left
		sx = ( top.x - ( w / halfbox() ) )
		//sx = ( top.x - ( w / 4 ) )
		sy = top.y;
		
		surface.SetDrawColor(TRANS)
		
		surface.DrawRect( sx - 1, sy - 1, size + 2, 3 )
		surface.DrawRect( sx - 1, sy - 1, 3, size + 2 )
		
		surface.SetDrawColor(tCol)
		//surface.SetDrawColor(Color(255,255,45))
		surface.DrawLine( sx, sy, sx + size, sy )
		surface.DrawLine( sx, sy, sx, sy + size )
		
		// Top right
		sx = ( top.x + ( w / halfbox() ) )
		//sx = ( top.x + ( w / 4 ) )
		sy = top.y;
		
		surface.SetDrawColor(TRANS)
		
		surface.DrawRect( sx - size, sy - 1, size + 2, 3 )
		surface.DrawRect( sx - 1, sy - 1, 3, size + 2 )
		
		
		surface.SetDrawColor(tCol)
		//surface.SetDrawColor(Color(255,255,45))
		surface.DrawLine( sx, sy, sx - size, sy )
		surface.DrawLine( sx, sy, sx, sy + size )
		
		//Bottom left
		sx = ( bot.x - ( w / halfbox() ) )
		//sx = ( bot.x - ( w / 4 ) )
		sy = bot.y;
		
		surface.SetDrawColor(TRANS)
		
		surface.DrawRect( sx - 1, sy - 1, size + 2, 3 )
		surface.DrawRect( sx - 1, sy - size, 3, size + 2 )
		
		surface.SetDrawColor(tCol)
		//surface.SetDrawColor(Color(255,255,45))
		surface.DrawLine( sx, sy, sx + size, sy )
		surface.DrawLine( sx, sy, sx, sy - size )
		
		//Bottom right
		sx = ( bot.x + ( w / halfbox() ) )
		//sx = ( bot.x + ( w / 4 ) )
		sy = bot.y;
		
		surface.SetDrawColor(TRANS)
		
		surface.DrawRect( sx - size, sy - 1, size + 2, 3)
		surface.DrawRect( sx - 1, sy - size, 3, size + 2)
		
		surface.SetDrawColor(tCol)
		//surface.SetDrawColor(Color(255,255,45))
		surface.DrawLine( sx, sy, sx - size, sy )
		surface.DrawLine( sx, sy, sx, sy - size )
		
	
		
		local posX = top.x
		local posY = top.y - 20

		//draw.SimpleText(v:Nick()..' ('..v:Health()..')', "DefaultSmallDropShadow" ,posX, posY, col(team.GetColor(v:Team()).r,team.GetColor(v:Team()).g,team.GetColor(v:Team()).b,255), 1 )
		local isadmin = v:IsAdmin() && "!" || ""
		draw.SimpleText(v:Nick()..' ('..v:Health()..')' .. isadmin, "DefaultSmallDropShadow" ,posX, posY, tCol, 1 )
end
end

hook.Add("PostRenderVGUI", "ESP", DrawESP)

concommand.Add('lolz', function()
hook.Remove("PostRenderVGUI", "ESP")
end)

local function Crosshair( ) //ASB
		x = ScrW() / 2
		y = ScrH() / 2
		surface.SetDrawColor( Color(0,0,0) );
		surface.DrawRect( x - 1, y - 4, 3, 9 );
		surface.DrawRect( x - 4, y - 1, 9, 3 );
		
		
		surface.SetDrawColor( Color(255,0,0))
	
		surface.DrawLine( x, y - 2, x, y + 2.75 );
		surface.DrawLine( x - 2, y, x + 2.75, y );
	end
hook.Add('HUDPaint','fdsf', Crosshair)