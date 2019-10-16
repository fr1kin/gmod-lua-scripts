//
--[[
	utils.lua
]]

local reg = debug.getregistry;

function isNil(o) 		return o == nil; 				end
function isAngle(o) 	return type(o) == "Angle"; 		end
function isBool(o) 		return type(o) == "boolean"; 	end
function isEntity(o) 	return type(o) == "Entity"; 	end
function isFunction(o) 	return type(o) == "function"; 	end
function isNPC(o) 		return type(o) == "NPC"; 		end
function isNumber(o) 	return type(o) == "number"; 	end
function isPanel(o) 	return type(o) == "Panel"; 		end
function isPlayer(o) 	return type(o) == "Player"; 	end
function isString(o) 	return type(o) == "string"; 	end
function isTable(o) 	return type(o) == "table"; 		end
function isVector(o) 	return type(o) == "Vector"; 	end

function copyObj(o, meta, _scanned)
	meta = meta or false;
	_scanned = _scanned or {};
	local cpy = o;
	if(isTable(o)) then
		cpy = {};
		if(not _scanned[o]) then
			_scanned[o] = cpy;
			debug.setmetatable(cpy, debug.getmetatable(o));
			for key, value in pairs(o) do
				cpy[key] = copyObj(o, meta, _scanned);
			end
		else
			cpy = _scanned[o];
		end
	end
	return cpy;
end