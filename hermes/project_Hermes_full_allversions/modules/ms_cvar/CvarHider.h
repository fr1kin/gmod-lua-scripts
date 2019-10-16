//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Separate Cvar hiding to keep the main file clean.
//			http://forum.gamedeception.net/showthread.php?t=7555
//			^ of course P74R1CK did everything 5 years ago.
//
// Notes:	No one really calls this function outside of CvarHider.cpp
//			so no one really needs to include it.
//
//===========================================================================//
#pragma once

void HideCvar(const char* origCvarName, const char* defaultValue, int origFlags);