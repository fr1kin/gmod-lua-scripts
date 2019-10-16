/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CExtra.h
Purpose: Extras.
------------------------------------------------------------*/
#pragma once

#ifndef ___EXTRA_FILE_
#define ___EXTRA_FILE_

#include "SDK.h"

namespace HERPES
{
	namespace Extras
	{
		extern void ForceVar( const char* cvar, int value );
		extern void RunCommand( const char* cvar );
		extern bool IsDormant( int index );
		void AntiAim( CUserCmd* cmd );
		extern void LUAFUNCTION( ILuaObject* lua );
		void PredictOrigin( Vector &org );
	}
}

#endif