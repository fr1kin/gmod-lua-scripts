/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: hook.h
Purpose: Hooking into game, CreateMove, HUD... STUFF YA KNOW
------------------------------------------------------------*/
#pragma once

#ifndef ___HOOK_FILE_
#define ___HOOK_FILE_

#include "SDK.h"

namespace HERPES
{
	namespace Hooks
	{
		extern void Hook( void );
		extern void CreateMove( CUserCmd *cmd );
		extern void HUDPaint();
		extern int __stdcall Init( CreateInterfaceFn appSysFactory, CreateInterfaceFn physicsFactory, CGlobalVarsBase *pGlobals );
	}
}

#endif