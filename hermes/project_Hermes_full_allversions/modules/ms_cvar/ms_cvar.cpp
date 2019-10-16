//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Cvar hiding plugin. Does not read from file, non-configurable.
//			For speedhacks? It simply works.
//
// Date:	02/10/2010 10:24AM
//
// $NoKeywords: $
//
//===========================================================================//

#include <tier1/tier1.h>
#include <tier2/tier2.h>
#include <tier3/tier3.h>
#include <icvar.h>

#include "ms_cvar.h"

#include "tier0/memdbgon.h"

CEmptyServerPlugin g_EmtpyServerPlugin;
EXPOSE_SINGLE_INTERFACE_GLOBALVAR(CEmptyServerPlugin, IServerPluginCallbacks, INTERFACEVERSION_ISERVERPLUGINCALLBACKS, g_EmtpyServerPlugin );


bool CEmptyServerPlugin::Load(	CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory )
{	
	ConnectTier1Libraries(&interfaceFactory, 1);
	ConnectTier2Libraries(&interfaceFactory, 1);
	ConnectTier3Libraries(&interfaceFactory, 1);
	
	g_pCVar = (ICvar*)interfaceFactory(CVAR_INTERFACE_VERSION, NULL); //This is needed to register cvars and concommands
		
	MathLib_Init( 2.2f, 2.2f, 0.0f, 2.0f );
	ConVar_Register( 0 );

	Msg(PLUGIN_LOAD);
	return true;
}

void CEmptyServerPlugin::Unload( void )
{
	ConVar_Unregister( );
	DisconnectTier3Libraries( );
	DisconnectTier2Libraries( );
	DisconnectTier1Libraries( );

	Msg(PLUGIN_UNLOAD);
}

void CEmptyServerPlugin::GameFrame( bool simulating ){}
void CEmptyServerPlugin::FireGameEvent(class KeyValues* ){}
const char* CEmptyServerPlugin::GetPluginDescription( void ){return PLUGIN_NAME;}

CEmptyServerPlugin::CEmptyServerPlugin(){}
CEmptyServerPlugin::~CEmptyServerPlugin(){}