//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Cvar hiding plugin. Does not read from file, non-configurable.
//			For speedhacks? It simply works.
//
// Date:	02/10/2010 10:24AM
//			02/13/2010 01:52PM 
//				Moved cvar crap into CvarHider.cpp, which already existed in
//				another project. The main file sure does look empty without
//				the code contained in CvarHider.cpp now!
//
//				Also changed some strings into #defines in this header.
//				Just to test. 
//
//===========================================================================//

#include <engine/iserverplugin.h>

#define PLUGIN_NAME		"[MS] Cvar hider"
#define PLUGIN_LOAD		"[MS] Cvar hider plugin loaded\n"
#define PLUGIN_UNLOAD	"[MS] Cvar hider plugin unloaded\n"

class CEmptyServerPlugin: public IServerPluginCallbacks
{
public:
	CEmptyServerPlugin();
	~CEmptyServerPlugin();

	// IServerPluginCallbacks methods
	virtual bool			Load(	CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory );
	virtual void			Unload( void );
	virtual void			Pause( void ) {};
	virtual void			UnPause( void ) {};
	virtual const char     *GetPluginDescription( void );      
	virtual void			LevelInit( char const *pMapName ) {};
	virtual void			ServerActivate( edict_t *pEdictList, int edictCount, int clientMax ) {};
	virtual void			GameFrame( bool simulating );
	virtual void			LevelShutdown( void ) {};
	virtual void			ClientActive( edict_t *pEntity ) {};
	virtual void			ClientDisconnect( edict_t *pEntity ) {};
	virtual void			ClientPutInServer( edict_t *pEntity, char const *playername ) {};
	virtual void			SetCommandClient( int index ) {};
	virtual void			ClientSettingsChanged( edict_t *pEdict ) {};
	virtual PLUGIN_RESULT	ClientConnect( bool *bAllowConnect, edict_t *pEntity, const char *pszName, const char *pszAddress, char *reject, int maxrejectlen ) {return PLUGIN_CONTINUE;};
	virtual PLUGIN_RESULT	ClientCommand( edict_t *pEntity, const CCommand &args ) {return PLUGIN_CONTINUE;};
	virtual PLUGIN_RESULT	NetworkIDValidated( const char *pszUserName, const char *pszNetworkID ) {return PLUGIN_CONTINUE;};
	virtual void			OnQueryCvarValueFinished( QueryCvarCookie_t iCookie, edict_t *pPlayerEntity, EQueryCvarValueStatus eStatus, const char *pCvarName, const char *pCvarValue ) {};

	virtual void			OnEdictAllocated( edict_t *edict ) {};
	virtual void			OnEdictFreed( const edict_t *edict  ) {};	

	virtual void FireGameEvent( KeyValues * event );
	virtual int GetCommandIndex() { return 0; }
};