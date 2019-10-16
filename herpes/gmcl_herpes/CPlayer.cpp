/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CPlayer.cpp
Purpose: Get player info (health, weapon, shit...)
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

using namespace HERPES;

// Base Entity
C_BaseEntity* Player::GetBaseEntity( int i )
{
	IClientEntity* pEnt = Interfaces::m_pClientEntList->GetClientEntity( i );
	if(! pEnt || pEnt->IsDormant() )
		return NULL;
			
	return pEnt->GetBaseEntity();
}

// Check if valid
bool Player::Check( int Index )
{
	C_BaseEntity* pBaseEnt = Player::GetBaseEntity( Index );
			
	if(! pBaseEnt )
		return false;
	if( pBaseEnt->IsDormant() || !pBaseEnt->IsAlive() )
		return false;

	return ( pBaseEnt->index != Interfaces::m_pEngine->GetLocalPlayer() );
}

// Index
CBaseEntity* Player::GetEntityByIndex( int i )
{
	if( Interfaces::m_pClientEntList == NULL ) return NULL;

	IClientEntity *pClient = Interfaces::m_pClientEntList->GetClientEntity( i );

	if( pClient == NULL ) return NULL;

	return pClient->GetBaseEntity();
}

// Local Player
CBaseEntity* Player::GetLocalEntity()
{
	if( Interfaces::m_pEngine == NULL ) return NULL;

	return GetEntityByIndex( Interfaces::m_pEngine->GetLocalPlayer() );
}