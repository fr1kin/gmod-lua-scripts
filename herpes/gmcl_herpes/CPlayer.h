/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CPlayer.h
Purpose: Get player info (health, weapon, shit...)
------------------------------------------------------------*/
#pragma once

#ifndef _CPLAYER_FILE_
#define _CPLAYER_FILE_

#include "SDK.h"

namespace HERPES
{
	namespace Player
	{
		extern C_BaseEntity* GetBaseEntity( int i );
		extern bool Check( int i );
		extern CBaseEntity* GetEntityByIndex( int i );
		extern CBaseEntity* GetLocalEntity();
	}
}

#endif