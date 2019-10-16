// NOSPREAD - By fr1kin
// Module by Deco

require( "deco" )
package.loaded.deco = nil

function WeaponVector( value, typ )
	local s = ( -value )
	
	if ( typ == true ) then
		s = ( -value )
	elseif ( typ == false ) then
		s = ( value )
	else
		s = ( value )
	end
	return Vector( s, s, s )
end

local GetPrediciton, PredictSpread = hl2_ucmd_getprediciton, hl2_shotmanip
local currentseed, cmd2, seed = currentseed || 0, 0, 0
local w, vecCone, valCone = "", Vector( 0, 0, 0 ), Vector( 0, 0, 0 )

_G.hl2_shotmanip			= nil
_G.hl2_ucmd_getprediciton	= nil

local CustomCones 	= {}
CustomCones.Weapons = {}
CustomCones.Weapons[ "weapon_pistol" ]		= WeaponVector( 0.0100, true )	// HL2 Pistol
CustomCones.Weapons[ "weapon_smg1" ]		= WeaponVector( 0.04362, true )	// HL2 SMG1
CustomCones.Weapons[ "weapon_ar2" ]			= WeaponVector( 0.02618, true )	// HL2 AR2
CustomCones.Weapons[ "weapon_shotgun" ]		= WeaponVector( 0.08716, true )	// HL2 SHOTGUN

local NormalCones = { [ "weapon_cs_base" ] = true }

function GetCone( wep )
	local c = wep.Cone
	
	if ( !c && ( type( wep.Primary ) == "table" ) && ( type( wep.Primary.Cone ) == "number" ) ) then c = wep.Primary.Cone end
	if ( !c ) then c = 0 end
	if ( type( wep.Base ) == "string" && NormalCones[ wep.Base ] ) then return c end
	if ( ( wep:GetClass() == "ose_turretcontroller" ) ) then return 0 end
	return c || 0
end

function PB.Nospread( comd, angle )
	local ply = LocalPlayer()
	
	cmd2, seed = GetPrediciton( comd )
	if ( cmd2 != 0 ) then currentseed = seed end
	
	local w = ply:GetActiveWeapon(); vecCone = Vector( 0, 0, 0 )
	if ( w && w:IsValid() && ( type( w.Initialize ) == "function" ) ) then
		valCone = GetCone( w )
			
		if ( type( valCone ) == "number" ) then
			vecCone = Vector( -valCone, -valCone, -valCone )
			
		elseif ( type( valCone ) == "Vector" ) then
			vecCone = valCone * -1
				
		end
	else
		if ( w:IsValid() ) then
			local class = w:GetClass()
				if ( CustomCones.Weapons[ class ] ) then
					vecCone = CustomCones.Weapons[ class ] 
				end
			end
		end
	return PredictSpread( currentseed || 0, ( angle || ply:GetAimVector():Angle() ):Forward(), vecCone ):Angle()
end


















// OLD ONE
local PredictSpread = function() end
local mysetupmove = function() end
local Check = function() end

local CL = LocalPlayer()

local NoSpreadHere=false
if #file.Find("../lua/includes/modules/gmcl_deco.dll")>=1 then
NoSpreadHere=true
// ANTI SPREAD SCRIPT
function AmmoCheck()
	local ply = LocalPlayer()
		if ply && ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() then
		local wep = ply:GetActiveWeapon()
			if !wep then return -1 end
			if wep:Clip1() == 0 then
				return false
			end
		return true	
	end
end

local DEGREES1	= Vector( 0.00873, 0.00873, 0.00873 )
local DEGREES2	= Vector( 0.01745, 0.01745, 0.01745 )
local DEGREES3	= Vector( 0.02618, 0.02618, 0.02618 )
local DEGREES4	= Vector( 0.03490, 0.03490, 0.03490 )
local DEGREES5	= Vector( 0.04362, 0.04362, 0.04362 )
local DEGREES6	= Vector( 0.05234, 0.05234, 0.05234 )
local DEGREES7	= Vector( 0.06105, 0.06105, 0.06105 )
local DEGREES8	= Vector( 0.06976, 0.06976, 0.06976 )
local DEGREES9	= Vector( 0.07846, 0.07846, 0.07846 )
local DEGREES10	= Vector( 0.08716, 0.08716, 0.08716 )
local DEGREES15	= Vector( 0.13053, 0.13053, 0.13053 )
local DEGREES20	= Vector( 0.17365, 0.17365, 0.17365 )
local AUTOAIM2	= Vector( 0.0348994967025, 0.0348994967025, 0.0348994967025 )
local AUTOAIM5	= Vector( 0.08715574274766, 0.08715574274766, 0.08715574274766 )
local AUTOAIM8	= Vector( 0.1391731009601, 0.1391731009601, 0.1391731009601 )
local AUTOAIM10	= Vector( 0.1736481776669, 0.1736481776669, 0.1736481776669 )
local AUTOAIM20	= Vector( 0.3490658503989, 0.3490658503989, 0.3490658503989 )

function HL2Cone(wep)
	
	local ply, time = LocalPlayer(), 0
	local cmd = ply:GetCurrentCommand()
	local conVal = conVal || -1
	
		if ( wep:GetClass() == "weapon_pistol" ) then
			coneVal = DEGREES1
		elseif ( wep:GetClass() == "weapon_357" ) then
			coneVal = AUTOAIM5
		elseif ( wep:GetClass() == "weapon_smg1" ) then
			coneVal = DEGREES5
		elseif ( wep:GetClass() == "weapon_ar2" ) then
			coneVal = AUTOAIM5
		elseif ( wep:GetClass() == "weapon_shotgun" ) then
			coneVal = DEGREES10
		end
			if ( wep:GetClass() == "weapon_pistol" ) then
				if ( cmd:GetButtons() & IN_ATTACK ) then
					timer.Create( "Conetimer", 1, 0, function()
						time = time + 1
					end )
					timer.Stop( "Conetimer" )
					timer.Start( "Conetimer" )
					conVal = DEGREES1
				elseif ( cmd:GetButtons() & IN_ATTACK  ) && ( time <= 4 ) then
					timer.Stop( "Conetimer" )
					conVal = DEGREES6
				elseif !( cmd:GetButtons() & IN_ATTACK  ) || ( AmmoCheck() ) then
					timer.Stop( "Conetimer" )
					conVal = DEGREES1
					time = "" // Reset our timer, we don't want the cone value to be off.
				elseif ( time <= 5 ) then
					timer.Stop( "Conetimer" )
					time = ""
				end
			end
	if conVal != -1 then
		return conVal
	end
	return 0
end

local MoveSpeed = 1

mysetupmove = function(objPl, move)
	if move then
		MoveSpeed = (move:GetVelocity():Length())/move:GetMaxSpeed()
	end
end

local ID_GAMETYPE = ID_GAMETYPE or -1
local GameTypes = {
	{check=function ()
		return string.find(GAMEMODE.Name,"Garry Theft Auto") ~= nil
	end,getcone=function (wep,cone)
		if type(wep.Base) == "string" then
			if wep.Base == "civilian_base" then
				local scale = cone
				if CL:KeyDown(IN_DUCK) then
					scale = math.Clamp(cone/1.5,0,10)
				elseif CL:KeyDown(IN_WALK) then
					scale = cone
				elseif (CL:KeyDown(IN_SPEED) or CL:KeyDown(IN_JUMP)) then
					scale = cone + (cone*2)
				elseif (CL:KeyDown(IN_FORWARD) or CL:KeyDown(IN_BACK) or CL:KeyDown(IN_MOVELEFT) or CL:KeyDown(IN_MOVERIGHT)) then
					scale = cone + (cone*1.5)
				end
				scale = scale + (wep:GetNWFloat("Recoil",0)/3)
				return Vector(scale,0,0)
			end
		end
		return Vector(cone,cone,cone)
	end},
	{check=function ()
		return type(TEAM_ZOMBIE) == "number" and type(TEAM_SURVIVORS) == "number" and string.find(GAMEMODE.Name,"Zombie Survival") ~= nil and type(NUM_WAVES) == "number"
	end,getcone=function (wep,cone)
		if wep:GetNetworkedBool("Ironsights",false) then
			if CL:Crouching() then
				return wep.ConeIronCrouching or cone
			end
			return wep.ConeIron or cone
		elseif 25 < LocalPlayer():GetVelocity():Length() then
			return wep.ConeMoving or cone
		elseif CL:Crouching() then
			return wep.ConeCrouching or cone
		end
		return cone
	end},
	{check=function ()
		return type(TEAM_ZOMBIE) == "number" and type(TEAM_SURVIVORS) == "number" and string.find(GAMEMODE.Name,"Zombie Survival") ~= nil
	end,getcone=function (wep,cone)
		if CL:GetVelocity():Length() > 25 then
			return wep.ConeMoving or cone
		elseif CL:Crouching() then
			return wep.ConeCrouching or cone
		end
		return cone
	end},
	{check=function ()
		return type(gamemode.Get("ZombRP")) == "table" or type(gamemode.Get("DarkRP")) == "table"
	end,getcone=function (wep, cone)
		if type(wep.Base) == "string" and (wep.Base == "ls_snip_base" or wep.Base == "ls_snip_silencebase") then
			if CL:GetNWInt( "ScopeLevel", 0 ) > 0 then 
				print("using scopecone")
				return wep.Primary.Cone
			end
			print("using unscoped cone")
			return wep.Primary.UnscopedCone
		end
		if type(wep.GetIronsights) == "function" and wep:GetIronsights() then
			return cone
		end
		return cone
	end},
	{check=function ()
		return (GAMEMODE.Data == "falloutmod" and type(Music) == "table")
	end,getcone=function(wep,cone)
		if wep.Primary then
			local LastShootTime = wep.Weapon:GetNetworkedFloat( "LastShootTime", 0 ) 
			local lastshootmod = math.Clamp(wep.LastFireMax + 1 - math.Clamp( (CurTime() - LastShootTime) * wep.LastFireModifier, 0.0, wep.LastFireMax ), 1.0,wep.LastFireMaxMod) 
			local accuracy = wep.Primary.Accuracy
			if CL:IsMoving() then accuracy = accuracy * wep.MoveModifier end
			if wep.Weapon:GetNetworkedBool( "Ironsights", false ) then accuracy = accuracy * 0.75 end
			accuracy = accuracy * ((16-(Skills.Marksman or 1))/11)
			if CL:KeyDown(IN_DUCK) then
				return accuracy*wep.CrouchModifier*lastshootmod
			else
				return accuracy*lastshootmod
			end
		end
	end}
}
Check = function()
	for k, v in pairs(GameTypes) do
		if v.check() then
			ID_GAMETYPE = k
			break
		end
	end
end

local tblNormalConeWepBases = {
	["weapon_cs_base"] = true
}
local function GetCone(wep)
	local cone = wep.Cone
	if not cone and type(wep.Primary) == "table" and type(wep.Primary.Cone) == "number" then
		cone = wep.Primary.Cone
	end
	if not cone then cone = 0 end
	--CHeck if wep is HL2 then return corresponding cone
	if type(wep.Base) == "string" and tblNormalConeWepBases[wep.Base] then return cone end
	if wep:GetClass() == "ose_turretcontroller" then return 0 end
	if ID_GAMETYPE ~= -1 then return GameTypes[ID_GAMETYPE].getcone(wep,cone) end
	return cone or 0
end

require("deco")
package.loaded.deco = nil

local nospread = hl2_shotmanip
local prediction = hl2_ucmd_getprediciton

_G.hl2_shotmanip = nil
_G.hl2_ucmd_getprediciton = nil
local currentseed, cmd2, seed = currentseed or 0, 0, 0
local wep, vecCone, valCone
PredictSpread = function(cmd,aimAngle)
	cmd2, seed = prediction(cmd)
	if cmd2 ~= 0 then
		currentseed = seed
	end
	wep = LocalPlayer():GetActiveWeapon()
	vecCone = Vector(0,0,0)
	if wep and wep:IsValid() and type(wep.Initialize) == "function" then
		valCone = GetCone(wep)
		if type(valCone) == "number" then
			vecCone = Vector(-valCone,-valCone,-valCone)
		elseif type(valCone) == "Vector" then
			vecCone = -1*valCone
		end
	end
	return nospread(currentseed or 0, (aimAngle or CL:GetAimVector():Angle()):Forward(), vecCone):Angle()
end

require("deco")
package.loaded.deco = nil

local nospread = hl2_shotmanip
local prediction = hl2_ucmd_getprediciton

CONFIGDECO = {}
CONFIGDECO.weapons = {}

CONFIGDECO.weapons["weapon_smg1"]        = Vector( -0.04362, -0.04362, -0.04362 )
CONFIGDECO.weapons["weapon_pistol"]      = Vector( -0.0100, -0.0100, -0.0100 )
CONFIGDECO.weapons["weapon_ar2"] = Vector( -0.02618, -0.02618, -0.02618 )
CONFIGDECO.weapons["weapon_shotgun"] = Vector( -0.08716, -0.08716, -0.08716 )
//CONFIGDECO.weapons["weapon_357"] = Vector( -0.0348994967025, -0.0348994967025, -0.0348994967025 )
 

local currentseed, cmd2, seed = currentseed or 0, 0, 0
local wep, vecCone, valCone
PredictSpread = function(cmd,aimAngle)
        cmd2, seed = prediction(cmd)
        if cmd2 ~= 0 then
                currentseed = seed
        end
        wep = LocalPlayer():GetActiveWeapon()
        vecCone = Vector(0,0,0)
        if wep and wep:IsValid() and type(wep.Initialize) == "function" then
                valCone = GetCone(wep)
                if type(valCone) == "number" then
                        vecCone = Vector(-valCone,-valCone,-valCone)
                elseif type(valCone) == "Vector" then
                        vecCone = -1*valCone
                end
				else
				if wep:IsValid() then
					local hl2ns = wep:GetClass()
                        if( CONFIGDECO.weapons[hl2ns] ) then vecCone = CONFIGDECO.weapons[hl2ns] end
					end
				end
        
        return nospread(currentseed or 0, (aimAngle or CL:GetAimVector():Angle()):Forward(), vecCone):Angle()
end
//END OF ANTI SPREAD SCRIPT
end





















// victors method
function ReturnSeed(weapon) //get the seed
	local Normalseed = {["weapon_cs_base"] = true} //normal css weapons
	local cone = weapon.Cone
	
	if !cone && type(weapon.Primary) == "table" && type(weapon.Primary.Cone) == "number" then
		cone = weapon.Primary && weapon.Primary.Cone end
	if !cone then cone = 0 end //sweps
	
	// the filter
	if type(weapon.Base) == "string" and Normalseed[weapon.Base] then return cone end //normal
	if weapon:GetClass() == "ose_turretcontroller" then return 0 end //wut
    
	
	return cone or 0
end


		
require("decz")

CONFIGDECO = {} //hl2 weapon predef cones
CONFIGDECO.weapons = {}
CONFIGDECO.weapons["weapon_smg1"]        = Vector( -0.04362, -0.04362, -0.04362 )
CONFIGDECO.weapons["weapon_pistol"]      = Vector( -0.0100, -0.0100, -0.0100 )
CONFIGDECO.weapons["weapon_ar2"]         = Vector( -0.02618, -0.02618, -0.02618 )
CONFIGDECO.weapons["weapon_shotgun"]     = Vector( -0.08716, -0.08716, -0.08716 )

local seedinVector = Vector( 0, 0, 0 )
local seedinValue = Vector( 0, 0, 0 )
local currentseed, cmd2, seed = currentseed or 0, 0, 0

 function DuckNospread( cmd, aimAngle )
   
        cmd2, seed = hl2_ucmd_getprediciton(cmd)
		if( cmd2 != 0 ) then currentseed =  seed end
        
		local weapon = LocalPlayer():GetActiveWeapon()
		
        if weapon:IsValid() then 
	 if type(weapon.Initialize) == "function" then 
               //checking if the cones are given in a value or in a vector 
                //turn it in to a vector
			   seedinValue = ReturnSeed(weapon)
			   if type(seedinValue) == "number" then 
                        seedinVector = Vector(-seedinValue,-seedinValue,-seedinValue)
                
			   elseif type(seedinValue) == "Vector" then 
                        seedinVector = -1*seedinValue
                end
				
				else
// checking if its a hl2 weapon and seting the seed to it's predefined seed. It wouldnt work when i did this in ReturnSeed(                    
					if( CONFIGDECO.weapons[weapon:GetClass()] ) then seedinVector = CONFIGDECO.weapons[weapon:GetClass()] end
                end
           end
     return hl2_shotmanip(currentseed or 0, (aimAngle or LocalPlayer():GetAimVector():Angle()):Forward(), seedinVector):Angle()  //magic
end