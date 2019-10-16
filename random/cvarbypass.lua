local CVARS = {
	{ CVar = "sv_cheats", Info = "Enables client cheats" },
	{ CVar = "host_timescale", Info = "Changes timescale, for speedhacks." },
	{ CVar = "mat_wireframe", Info = "Sets the world into a full wireframe." },
	{ CVar = "r_drawparticles", Info = "Enables particals." },
	{ CVar = "r_drawothermodels", Info = "Draws models method." },
	{ CVar = "r_drawbrushmodels", Info = "Draws brush models" },
	{ CVar = "sv_consistency", Info = "Enables file enforcement." },
	{ CVar = "fog_enable", Info = "Draws world fog." },
	{ CVar = "fog_enable_water_fog", Info = "Draws fog in water." },
	{ CVar = "mat_fullbright", Info = "Brightens the world to the default value." },
	{ CVar = "mat_reversedepth", Info = "A proxy type thing." },
	{ CVar = "sv_allow_voice_from_file", Info = "Allows sounds in files." },
	{ CVar = "voice_inputfromfile", Info = "Allow voice from files." },
	{ CVar = "sv_scriptenforcer", Info = "Enforce scripts from loading." }
}

local help = [[****************************************
	help - Show this message
	showcmds - Shows valid commands.
	clear - Clear the console box.
	force - Forces to run a value even if it's not in the list.
	concommand - Use commands that don't have numbers.
	****************************************
	]]
	
local text = "Hermes Console\n" .. help

local function ShowConsoleMenuThing()
	local panel = vgui.Create( "DFrame" )
	panel:SetPos( ScrW() / 2 - 350 / 2, ScrH() / 2 - 450 / 2 )
	panel:SetSize( 350, 450 )
	panel:SetTitle( "Console" )
	panel:SetVisible( true )
	panel:SetDraggable( true )
	panel:ShowCloseButton( true )
	panel:MakePopup()
	
	local textentry
	function dConsole()
		textentry = vgui.Create( "DTextEntry" )
		textentry:SetParent( panel )
		textentry:SetPos( 10, 30 )
		textentry:SetValue( text )
		textentry:SetSize( 330, 380 )
		textentry:SetMultiline( true )
		textentry:SetEditable( false )
	end
	dConsole()
	
	function SetText( newMsg, useColor )
		textentry:SetTextColor( Color( useColor.r, useColor.g, useColor.b, 255 ) )
		text = text .. ( newMsg .. "\n" )
		dConsole()
	end
	
	function Clear()
		text = "Hermes Console\n"
		dConsole()
	end
	
	local commandentry
	function dCommand()
		commandentry = vgui.Create( "DTextEntry" )
		commandentry:SetParent( panel )
		commandentry:SetPos( 10, 420 )
		commandentry:SetSize( 250, 20 )
	end
	dCommand()
	
	function DoFunctions()
		if ( commandentry && commandentry:GetValue() != "" ) then
			local getString = string.Explode( " ", commandentry:GetValue() )
			if ( getString[1] && getString[2] && ConVarExists( "hermes_" .. getString[1] ) ) then
				RunConsoleCommand( "hermes_" .. getString[1], getString[2] )
				SetText( "Set '" .. getString[1] .. "' to the value '" .. getString[2] .. "'.", Color( 0, 255, 0, 255 ) )
			elseif ( getString[1] && getString[2] && getString[1] == "force" && ConVarExists( getString[2] ) ) then
				if ( getString[3] == nil ) then
					SetText( "Missing number value for '" .. getString[2] .. "'!", Color( 0, 255, 0, 255 ) )
				else
					RunConsoleCommand( getString[2], getString[3] )
					SetText( "Forced '" .. getString[2] .. "' to the value '" .. getString[3] .. "'.", Color( 0, 255, 0, 255 ) )
				end
			elseif ( getString[1] && getString[1] == "help" ) then
				SetText( help, Color( 0, 255, 0, 255 ) )
			elseif ( getString[1] && getString[1] == "showcmds" ) then
				for k, v in pairs( CVARS ) do
					SetText( v.CVar .. " - " .. v.Info, Color( 0, 255, 0, 255 ) )
				end
			elseif ( getString[1] && getString[1] == "clear" ) then
				Clear()
			elseif ( getString[1] && ConVarExists( getString[1] ) ) then
				SetText( "Command '" .. getString[1] .. "' is valid, but not in the cvar list!", Color( 255, 0, 0, 255 ) )
			elseif ( getString[1] && getString[2] && getString[1] == "concommand" ) then
				RunConsoleCommand( getString[2] )
				SetText( "ConCommand '" .. getString[2] .. "' was executed.", Color( 255, 0, 0, 255 ) )
				else SetText( "Command '" .. getString[1] .. "' isn't valid!", Color( 255, 0, 0, 255 ) );
			end
			else SetText( "Need to enter a value in the textbox!", Color( 0, 255, 0, 255 ) );
		end
		commandentry:SetText( "" )
	end
	
	timer.Create( "repeat", 0.01, 0, function()
		if ( panel:IsVisible() && commandentry && commandentry:GetValue() != "" ) then
			local getString = string.Explode( " ", commandentry:GetValue() )
			if ( getString[1] && input.IsKeyDown( KEY_ENTER ) ) then
				DoFunctions()
			end
		end
	end )
	
	local button = vgui.Create( "DButton" )
	button:SetParent( panel )
	button:SetText( "Insert" )
	button:SetPos( 270, 420 )
	button:SetSize( 70, 20 )
	
	button.DoClick = function()
		DoFunctions()
	end
end
concommand.Add( "openconsole", ShowConsoleMenuThing )