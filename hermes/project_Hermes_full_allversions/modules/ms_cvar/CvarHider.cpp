//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Separate Cvar hiding to keep the main file clean.
//			http://forum.gamedeception.net/showthread.php?t=7555
//			^ of course P74R1CK did everything 5 years ago.
//
// $NoKeywords: $
//
//===========================================================================//

#include "CvarHider.h"

#include <tier1/tier1.h>
#include <icvar.h>

void HideCvar(const char* origCvarName, const char* defaultValue, int origFlags)
{
	ConVar* pCvar = g_pCVar->FindVar( origCvarName );
	if (!pCvar)
	{
		Msg("[MS] ERROR: Could not find cvar %s\n", origCvarName);
		return;
	}
	ConVar* pNewVar = (ConVar*)malloc( sizeof ConVar ); 	//Create new convar pNewVar

	memcpy( pNewVar, pCvar,sizeof( ConVar ));			//Copy old var into new var
	pNewVar->m_pNext = 0;								//Link new var?
	g_pCVar->RegisterConCommand( pNewVar );				//register new var
	pCvar->m_pszName = new char[50];					//rename old var
	
	char tmp[50];
	Q_snprintf(tmp, sizeof(tmp), "ms_%s", origCvarName);//rename to ms_[origCvarName]

	strcpy((char*)pCvar->m_pszName, tmp);				//LOL UNINITIALIZED MEMORY IS LAME
	pCvar->m_nFlags = FCVAR_NONE;						//eh...

	new ConVar(origCvarName, defaultValue, origFlags, "BYPASSED CVAR"); // lol

	Msg("[MS] Successfully created cvar bypass %s from %s\n", tmp, origCvarName);
}

CON_COMMAND( ms_pato, "Attempts to copy some cvars" )
{
	static bool g_bRan = false;
	if (g_bRan)
		return;
		
	HideCvar("sv_cheats", "0", FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT);
	HideCvar("host_timescale", "1.0", FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_CHEAT);
	HideCvar("mat_wireframe", "0", FCVAR_CHEAT);
	HideCvar("r_drawparticles", "1", FCVAR_CLIENTDLL | FCVAR_CHEAT);
	HideCvar("r_drawothermodels", "1", FCVAR_CLIENTDLL | FCVAR_CHEAT);
	HideCvar("r_drawbrushmodels", "1", FCVAR_CHEAT);
	HideCvar("sv_consistency", "1", FCVAR_REPLICATED);
	HideCvar("fog_enable", "1", FCVAR_CLIENTDLL | FCVAR_CHEAT);
	HideCvar("fog_enable_water_fog", "1", FCVAR_CHEAT);
	HideCvar("mat_fullbright", "0", FCVAR_CHEAT);
	HideCvar("mat_luxels", "0", FCVAR_CHEAT);
	HideCvar("mat_reversedepth", "0", FCVAR_CHEAT);

	HideCvar("sv_allow_voice_from_file", "1", FCVAR_REPLICATED);
	HideCvar("voice_inputfromfile", "0", FCVAR_NONE);
	
	g_bRan = true;
}