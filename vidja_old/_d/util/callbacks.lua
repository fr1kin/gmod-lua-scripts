//
--[[
	callbacks.lua
]]

local meta = {};

function meta:__index(tab, key)

end

function meta:__newindex(tab, name, value)
	if(isTable(value)) then
		debug.setmetatable(value, meta);
	end
	rawset(callback(tab, name, value));
end

setmetatable(_G,{
	__newindex = function(t,k,v)
		if(k=="hook") then
			setmetatable(v, {
				__newindex = function(_t, _k,_v)
					if(_k == "Call") then
						local oldCall = _v;

						rawset(_G, "callFunc", function(...) end);

						local function newfunc(...)
							//stuff
							local ret = callFunc(...);
								if(ret != nil) then
									return ret;
								end
								return oldCall(...);
							end
						end
						_v = newfunc;
					end
					rawset(_t,_k,_v);
				end,
			})
		end
		rawset(t,k,v);
	end,
})