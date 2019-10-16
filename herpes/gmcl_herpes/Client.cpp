/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: hook.cpp
Purpose: Hooking into game, CreateMove, HUD... SHIT YA KNOW
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

using namespace HERPES;

/*
	Sadly in Garry's Mod you cannot just inject a cheat, lua has to use the hooks to. So the only method
	that will work right now is using the lua hooks and then just from there just use C++. It will cause
	detection but I can fix that later on.
*/

// CreateMove Hook
void Hooks::CreateMove( CUserCmd *cmd )
{
	// CreateMove stuff
}

// HUDPaint Hook
void Hooks::HUDPaint()
{
	// HUD Shit stuff
}