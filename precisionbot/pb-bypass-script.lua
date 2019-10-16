--[[ Bypass Script by fr1kin ]]--

local Hooks = {
	["Add_All_Hooks_Here"] = ["Hook_Type"],
	// Example
	["DrawMyESP"] = ["HUDPaint"],
}

local ConCommands = {
	["Add_All_Console_Commands_Here"],
	// Example
	["+Aimbot"],
}

local ClientCVars = {
	["Add_All_Client_Console_Commands_Here"],
	// Example
	["hack_enable_wallhack"],
}

local TextFiles = {
	["Add_All_Text_Files_Here"],
	// Example
	["Friends.txt"],
}

local Modules = {
	["Add_All_Modules_Here"],
	// Example
	["gmcl_deco"],
}

local LUAModules = {
	["Add_All_LUA_Modules_Here"],
	// Example (MUST BE IN AUTORUN/CLIENT)
	["hack.lua"],
}

local CVARBypasses = {
	["Add_All_CVars_Bypassed_Here"]	= ["Enter_Default_Number_Here"],
	// Example
	["sv_cheats"] = ["0"]
}

--[[ MAIN BYPASS SCRIPT ]]--

local OLD_GETCONVAR			= GetConVar
local OLD_GETCONVARNUMBER	= GetConVarNumber
local OLD_CONVAREXISTS		= ConVarExists
local OLD_HOOKADD			= hook.Add
local OLD_HOOKREMOVE		= hook.Remove
local OLD_CONADD			= concommand.Add
local OLD_CONREMOVE			= concommand.Remove
local OLD_FILEREAD			= file.Read
local OLD_FILEEXISTS		= file.Exists
local OLD_FILEEXISTEX		= file.ExistsEx
local OLD_FILEWRITE			= file.Write
local OLD_FILETIME			= file.Time
local OLD_FILESIZE			= file.Size
local OLD_FILEFIND			= file.Find
local OLD_FILEFINDINLUA		= file.FindInLua
local OLD_FILERENAME		= file.Rename
local OLD_FILETFIND			= file.TFind
local OLD_FILEISDIR			= file.IsDir
local OLD_FILECREATEDIR		= file.CreateDir
local OLD_FILEDELETE		= file.Delete

--[[ HOOKS ]]--
local HOOKS_ALPHABET = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "v" }
local HOOKS_RAN = table.Random( HOOKS_ALPHABET )

function hook.Add( hook, name, func )

end

function HOOK_RANDOMIZER( hook, name, func )

	local rA = math.random( 65, 116 )
	local rB = string.char( rA )
	
	return rB
end

function HOOK_FIND( hook, name, func )
	for name, func in pairs( Hooks ) do
		OLD_HOOKADD( name, HOOK_RANDOMIZER(), func )
	end
end