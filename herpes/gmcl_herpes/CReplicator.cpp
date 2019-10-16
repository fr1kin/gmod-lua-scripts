/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CReplicator.cpp
Purpose: Replicate cvar to avoid KAC and other anticheats.
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

using namespace HERPES;

const char* HERPES::Replicator::ReplicateVar( const char* convar, const char* n_convar, const char* value, int flags )
{
	ConVar* pCvar = HERPES::Interfaces::m_pCVar->FindVar( convar );

	if ( !pCvar )
	{
		return NULL;
	}
	ConVar* pNewVar = (ConVar*)malloc( sizeof ConVar );

	memcpy( pNewVar, pCvar,sizeof( ConVar ));
	pNewVar->m_pNext = 0;
	HERPES::Interfaces::m_pCVar->RegisterConCommand( pNewVar );
	pCvar->m_pszName = new char[50];
	
	char tmp[50];
	Q_snprintf( tmp, sizeof(tmp), "__%s", convar );

	strcpy((char*)pCvar->m_pszName, tmp);
	pCvar->m_nFlags = FCVAR_NONE;

	HERPES::DebugMessage( "Created new ConVar" );

	ConVar* replicated = new ConVar( convar, value, flags, "" );

	return pCvar->m_pszName;
}

LUA_FUNCTION( lua_ReplicateVar )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_STRING );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_STRING );
	Interfaces::Lua->CheckType( 3, GLua::TYPE_NUMBER );
	Interfaces::Lua->CheckType( 4, GLua::TYPE_STRING );

	const char* convar				=	Interfaces::Lua->GetString(1);
	const char* n_convar			=	Interfaces::Lua->GetString(2);
	int			flags				=	Interfaces::Lua->GetInteger(3);
	const char* value				=	Interfaces::Lua->GetString(4);

	HERPES::Replicator::ReplicateVar( convar, n_convar, value, flags );
	return 0;
}

void HERPES::Replicator::LUAFUNCTION( ILuaObject* lua )
{
	static bool ran = false;
	if( ran )
		return;

	lua->SetMember( "ReplicateVar", lua_ReplicateVar );

	ran = true;
}