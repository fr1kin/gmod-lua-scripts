local hooks = {}; -- custom hooks
local oldHookCall = hook.Call;
local hookTypes = {};
local gmTypes = {};
print( "original: ", hook.Call );
function hook.Call(name, gm, ...)
	local args = {...};
	hookTypes[name] = true;
	gmTypes[name] = true;
	if(hooks[name]) then
		if(args == nil) then
			print(name, "1" );
			hooks[name].func();
		else
			print(name, "1r" );
			return hooks[name].func(unpack(args));
		end
	end
	return oldHookCall(name, gm, ...);
end

local detourfunc = hook.Call;

concommand.Add("print_hooks", function()
	PrintTable(hookTypes);
	print("\n\ngmTypes\n");
	PrintTable(gmTypes);
	print( "current: ", hook.Call );
	print( "original: ", oldHookCall );
	print( "detour: ", detourfunc );
	if(hook.Call == detourfunc) then
		print("hookcallisdetourfunc");
	end
end )

print( "copy: ", oldHookCall );
print( "current: ", hook.Call );

hooks["Think"] = { func_name = "hookname", func = function() print("spam") end }
