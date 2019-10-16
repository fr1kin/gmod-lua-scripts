/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: SDK.h
Purpose: All headers/libs/definitions required for the project.
------------------------------------------------------------*/
#pragma once

#ifndef ___SDK_FILE_
#define ___SDK_FILE_

#define GAME_DLL
#define CLIENT_DLL
#define WIN32_LEAN_AND_MEAN

#pragma warning( disable : 4311 )
#pragma warning( disable : 4312 )
#pragma warning( disable : 4541 )
#pragma warning( disable : 4267 )
#pragma warning( disable : 4183 )

#pragma comment( lib, "tier0.lib" )
#pragma comment( lib, "tier1.lib" )
#pragma comment( lib, "tier2.lib" )
#pragma comment( lib, "tier3.lib" )
#pragma comment( lib, "vgui_controls.lib" )
#pragma comment( lib, "mathlib.lib" )
#pragma comment( lib, "vstdlib.lib" )

// Headers
#include <windows.h>
#include <string>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <vector>
#include <map>
#include <sstream>

#include "vmthook.h"

#include <boost/lexical_cast.hpp>
#include <boost/format.hpp>

#include "GMLuaModule.h"
#include "IScriptEnforcer.h"

#include <cdll_int.h>
#include <filesystem.h>
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
#include <vgui/ilocalize.h>
#include <engine\IEngineTrace.h>
#include <convar.h>
#include <icvar.h>
#include <tier1.h>
#include <eiface.h>
#include <math.h>
#include <usercmd.h>
#include <checksum_md5.h>
#include <vstdlib/random.h>
#include <mathlib/vector.h>
#include <icliententity.h>
#include <icliententitylist.h>
#include <materialsystem/imaterial.h>
#include <materialsystem/imaterialsystem.h>
#include <materialsystem/imaterialvar.h>
#include <inetchannelinfo.h>
#include <cdll_int.h>
#include <cdll_client_int.h>
#include <tier1/tier1.h>
#include <tier2/tier2.h>
#include <tier3/tier3.h>
#include <interface.h>
#include <mathlib\mathlib.h>
#include <cbase.h>
#include <decals.h>

#include <steam/isteamclient.h>
#include <steam/isteamfriends.h>

// Colors
#define WHITE		Color( 255, 255, 255, 255 )
#define BLACK		Color( 0, 0, 0, 255 )
#define RED			Color( 255, 0, 0, 255 )
#define GREEN		Color( 0, 255, 0, 255 )
#define BLUE		Color( 0, 0, 255, 255 )
#define YELLOW		Color( 255, 255, 0, 255 )

#include "Interfaces.h"
#include "Client.h"

#include "Detours.h"
#include "CScriptEnforcer.h"

#include "CPlayer.h"
#include "CAutoWall.h"
#include "CFilter.h"
#include "CReplicator.h"
#include "CNospread.h"
#include "CExtra.h"

#endif