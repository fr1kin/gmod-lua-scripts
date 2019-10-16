/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CReplicator.h
Purpose: Replicate cvar to avoid KAC and other anticheats.
------------------------------------------------------------*/
#pragma once

#ifndef ___REPLICATOR_FILE_
#define ___REPLICATOR_FILE_

#include "SDK.h"

namespace HERPES
{
	namespace Replicator
	{
		extern const char* ReplicateVar( const char* convar, const char* n_convar, const char* value, int flags );
		extern void LUAFUNCTION( ILuaObject* lua );
	}
}

#endif //_REPLICATOR_FILE_