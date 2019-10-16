
local function createMat(mat)
	return CreateMaterial(
					tostring(util.CRC(mat:GetString("$basetexture"))), 
					"LightmappedGeneric",
					{
						["$basetexture"] = mat:GetString("$basetexture"),
						["translucent"] = 1,
						["alpha"] = 0.9
					});
end

local function toggleTransparency(alpha)
	for _, mat in pairs(game.GetWorld():GetMaterials()) do
		
	end
end

local oldNetReceive = net.Receive;
function net.Receive(name, func)
	return oldNetReceive(name, function(...)
		print(unpack({...}));
		func(...);
	end)
end