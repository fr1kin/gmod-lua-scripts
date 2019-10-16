/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: int.h
	Purpose: Stuff
*************************************************************/
bool canDetour = false;
#include "scriptenforcer.h"

#include <cdll_client_int.h>
#include <mathlib\mathlib.h>
#include <iclientmode.h>
#include <iefx.h>
#include <engine\IEngineSound.h>
#include <ienginevgui.h>
#include <engine\ivdebugoverlay.h>
#include <vgui\ISurface.h>
#include <iprediction.h>
#include <igameevents.h>
#include <vgui\IVGui.h>
#include <input.h>
#include <con_nprint.h>
#include <game_controls\commandmenu.h>
#include <in_buttons.h>
#include <vphysics_interface.h>
#include <ivrenderview.h>
#include <engine\IEngineTrace.h>

bool InMenu()
{
	ILuaObject *maxply = gLua->GetGlobal( "MaxPlayers" );
	bool ret = maxply->isNil();
	maxply->UnReference();

	return ret;
}

namespace HERMES
{
	void ReplicateVar( const char* cvar, const char* def, int flags, const char* newname );
	void RunCommand( const char* cvar );
	void ForceVar( const char* cvar, int value );
	void Int( ILuaObject* cheat );
	void Msg( const tchar *text, const Color &col );
	void Include( std::string path );
}

#define CALL_HOOK(gLua, name) \
	ILuaObject *hookT = gLua->GetGlobal("hook");\
		ILuaObject *hookM = hookT->GetMember("Call");\
			hookM->Push();\
			\
			gLua->Push(name);\
			gLua->PushNil();\
			\
			gLua_Menu->Call(2, 1);\
		hookM->UnReference();\
	hookT->UnReference();