/*==================================================
Hermes
Credits: C0BRA, noPE, raBBish, Deco
==================================================*/
#define GAME_DLL
#define WIN32_LEAN_AND_MEAN
 
// Headers
//#include "captioncompiler/cbase.h"
//#include <interface.h>
#include <GMLuaModule.h>
#include <cdll_int.h>
#include <windows.h>
#include "icvar.h"
#include "convar.h"
#include <materialsystem/imaterial.h>
#include <materialsystem/imaterialsystem.h>
#include <tier0/dbg.h>
#include "color.h"
#include <vector>
#include <icliententity.h>
#include <icliententitylist.h>
#include <iostream>
#include <fstream>
#include <string>
#include <math.h>
#include <checksum_md5.h>
#include <shot_manipulator.h>
#include <usercmd.h>
#include <vstdlib\random.h>

/*
	vtf.lib
	tier0.lib
	tier1.lib
	tier2.lib
	tier3.lib
	matsys_controls.lib
	bitmap.lib
	choreoobjects.lib
	dmxloader.lib
	mathlib.lib
	nvtristrip.lib
	particles.lib
	raytrace.lib
	steam_api.lib
	vgui_controls.lib
	vmpi.lib
	vstdlib.lib
*/

#pragma comment(lib, "psapi.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "tier0.lib")
#pragma comment(lib, "tier1.lib")

// Vars
bool isLoaded = false;

// Nospread
IUniformRandomStream *random;

// gLua Setup
GMOD_MODULE( Init, Shutdown );
ILuaInterface* g_Lua;

// CVARs
IVEngineClient *gEngine = NULL;
ICvar *g_pCVar = NULL;

// Material system
IMaterialSystem *g_pMaterialSystem = NULL;

// Dormant shit
IClientEntityList *g_pClientEntList = NULL;

// ******************************
// NoSpread
// ******************************
// Copey from Hades
int VectorMetaRef = -1;

ILuaObject* NewVectorObject( lua_State *L, Vector& vec )
	{
		if(VectorMetaRef == NULL)
		{
		ILuaObject *VectorMeta = Lua()->GetGlobal("Vector");
		VectorMeta->Push();
		VectorMetaRef = Lua()->GetReference(-1, true);
		VectorMeta->UnReference();
	}

	Lua( )->PushReference(VectorMetaRef);

	if(Lua()->GetType(-1) != GLua::TYPE_FUNCTION)
	{
	Lua()->Push(Lua()->GetGlobal( "Vector" ) );
	}

	Lua( )->Push(vec.x);
	Lua( )->Push(vec.y);
	Lua( )->Push(vec.z);
	Lua( )->Call(3, 1);
	return Lua( )->GetReturn( 0 );
}

void PushVector( lua_State *L, Vector& vec )
{
	Lua( )->Push( NewVectorObject( L, vec ) );
}

Vector *GetVector( lua_State *L, int stackpos )
{
	return ( Vector* )( Lua( )->GetUserData( stackpos ) );
}

LUA_FUNCTION( PredictSeed )
{
	Lua( )->CheckType( 1, GLua::TYPE_USERCMD );
	CUserCmd *cmd = ( CUserCmd * )( Lua( )->GetUserData( ) );
	unsigned int seed = cmd->random_seed = MD5_PseudoRandom( cmd->command_number ) & 0x7fffffff;

	Lua( )->Push( ( float )( seed & 255 ) );
	return 1;
}

LUA_FUNCTION( Nospread )
{
	Lua( )->CheckType( 1, GLua::TYPE_NUMBER );
	Lua( )->CheckType( 2, GLua::TYPE_VECTOR );
	Lua( )->CheckType( 3, GLua::TYPE_VECTOR );
	
	RandomSeed( Lua( )->GetInteger( 1 ) );

	Vector *vecMod = GetVector( L, 2 );
	CShotManipulator shot( *vecMod );

	Vector *vecSpread = ( Vector* )( Lua( )->GetUserData( 3 ) );
	Vector predict = shot.ApplySpread( *vecSpread );

	PushVector( L, predict );
	return 1;
}

// ******************************
// GetSteam
// ******************************

// guess where I stole this
char steampath[MAX_PATH];
LUA_FUNCTION( GetSteam )
{
	HKEY hRegKey;

	if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, _T("Software\\Valve\\Steam"), 0, KEY_QUERY_VALUE, &hRegKey) == ERROR_SUCCESS)
	{
		DWORD dwLength = sizeof(steampath);
		DWORD rc=RegQueryValueEx(hRegKey, _T("InstallPath"), NULL, NULL, (BYTE*)steampath, &dwLength);
		RegCloseKey(hRegKey);
	} else {
		return 0;
	}

	char file[MAX_PATH];
	sprintf(file, "%s\\config\\SteamAppData.vdf", steampath);

	HANDLE hFile = CreateFileA(file, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

	if(hFile == INVALID_HANDLE_VALUE)
	{
		CloseHandle(hFile);
		return 0;
	}

	DWORD sz = GetFileSize(hFile, NULL);

	char *buff = new char[sz+1];
	memset(buff, 0, sz+1);

	DWORD dwBytesRead;
	ReadFile(hFile, buff, sz, &dwBytesRead, NULL);
	CloseHandle(hFile);

	Lua()->Push(buff);

	delete buff;
	return 1;
}

// ******************************
// Run command (RCC)
// ******************************
LUA_FUNCTION( RunCommand )
{
	g_Lua->CheckType( 1, GLua::TYPE_STRING );
	gEngine->ClientCmd_Unrestricted( g_Lua->GetString( 1 ) );
	return 0;
}

// ******************************
// Console
// ******************************
LUA_FUNCTION( ConsoleVisible )
{
	g_Lua->CheckType( 1, GLua::TYPE_BOOL );
	if ( !gEngine )
	{
		g_Lua->Push( false );
		return 1;
	}
	
	if( gEngine->Con_IsVisible() )
	{
		g_Lua->Push( true );
		return 1;
	}
	g_Lua->Push( false );
	return 1;
}

// ******************************
// ForceVar
// ******************************
LUA_FUNCTION( ForceVar )
{
	g_Lua->CheckType( 1, GLua::TYPE_STRING );
	g_Lua->CheckType( 2, GLua::TYPE_NUMBER );

	ConVar *var = g_pCVar->FindVar( Lua()->GetString( 1 ) );
	var->SetValue( g_Lua->GetNumber( 2 ) );
	return 0;
}

// ******************************
// IsDormant
// ******************************
LUA_FUNCTION( IsDormant )
{
	g_Lua->CheckType( 1, GLua::TYPE_NUMBER );

	int index = g_Lua->GetNumber( 1 );

	IClientEntity* pClientEntity = g_pClientEntList->GetClientEntity( index );
	
	if ( pClientEntity )
	{
		g_Lua->Push( pClientEntity->IsDormant() );
		return 1;
	}
	else
	{
		Error( "pClientEntity = NULL!" );
		return 0;
	}
}

// ******************************
// Color Message
// ******************************
LUA_FUNCTION( ColorMsg )
{
	g_Lua->CheckType( 1, GLua::TYPE_STRING );
	g_Lua->CheckType( 2, GLua::TYPE_TABLE );

	const char* msg = g_Lua->GetString(1);

	ILuaObject* col = g_Lua->GetObject(2);
		int r = col->GetMemberInt("r");
		int g = col->GetMemberInt("g");
		int b = col->GetMemberInt("b");
	col->UnReference();

	Color textcol(r,g,b,255);

	ConColorMsg( textcol, msg );
	return 0;
}

// ******************************
// World Transparency
// ******************************
LUA_FUNCTION( SetWorldTransparent )
{
	g_Lua->CheckType( 1, GLua::TYPE_NUMBER );

	if( !g_pMaterialSystem )
	{
		g_Lua->Push( false );
		return 1;
	}

	int var = g_Lua->GetNumber( 1 );
	int size = g_pMaterialSystem->GetNumMaterials();
    int list = g_pMaterialSystem->FirstMaterial();

	for ( list ; list < size ; list++ )
	{
		IMaterial* mats = g_pMaterialSystem->GetMaterial(list);
		
		if( !strcmp( mats->GetTextureGroupName(), "World textures" ) )
		{
			if ( var == 1 )
			{
				mats->AlphaModulate( 0.9f );
			}
			else if( var == 0 )
			{
				mats->AlphaModulate( 1.0f );
			}
		}
    }

	g_Lua->Push( true );
	return 1;
}

// ******************************
// Nohands
// ******************************
void ResetHands( IMaterial *Material )
{
	Material->SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, false );
	Material->SetMaterialVarFlag( MATERIAL_VAR_NO_DRAW, false );
	Material->SetMaterialVarFlag( MATERIAL_VAR_ZNEARER, false );
	Material->SetMaterialVarFlag( MATERIAL_VAR_WIREFRAME, false );
	Material->SetMaterialVarFlag( MATERIAL_VAR_FLAT, false );
}

LUA_FUNCTION( SetHands )
{
	g_Lua->CheckType( 1, GLua::TYPE_NUMBER );

	if( !g_pMaterialSystem )
	{
		g_Lua->Push( false );
		return 1;
	}

	int val = g_Lua->GetNumber( 1 );
	int size = g_pMaterialSystem->GetNumMaterials();
    int list = g_pMaterialSystem->FirstMaterial();
	
	for ( list ; list < size ; list++ )
	{
		IMaterial* mats = g_pMaterialSystem->GetMaterial(list);

		if( strstr( mats->GetName(), "hand" ) )
		{
			if( val == 0 )
			{
				ResetHands( mats );
			}
			else if ( val == 1 )
			{
				ResetHands( mats );
				mats->SetMaterialVarFlag( MATERIAL_VAR_NO_DRAW, true );
			}

			else if( val == 2 )
			{
				ResetHands( mats );
				mats->SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, true );
				mats->SetMaterialVarFlag( MATERIAL_VAR_ZNEARER, true );
				mats->SetMaterialVarFlag( MATERIAL_VAR_FLAT, true );
			}

			else if( val == 3 )
			{
				ResetHands( mats );
				mats->SetMaterialVarFlag( MATERIAL_VAR_WIREFRAME, true );
			}

			else if( val == 4 )
			{
				ResetHands( mats );
				mats->SetMaterialVarFlag( MATERIAL_VAR_WIREFRAME, true );
				mats->SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, true );
			}
		}
	}

	g_Lua->Push( true );
	return 1;
}

// ******************************
// Player XQZ Wallhack
// ******************************
LUA_FUNCTION( XQZ )
{
	g_Lua->CheckType( 1, GLua::TYPE_NUMBER );

	if( !g_pMaterialSystem )
	{
		g_Lua->Push( false );
		return 1;
	}

	int val = g_Lua->GetNumber( 1 );
	int size = g_pMaterialSystem->GetNumMaterials();
    int list = g_pMaterialSystem->FirstMaterial();
	
	for ( list ; list < size ; list++ )
	{
		IMaterial* mats = g_pMaterialSystem->GetMaterial(list);
		
		if( strstr( mats->GetName(),"player" ) ||
            strstr( mats->GetName(),"breen" ) ||
			strstr( mats->GetName(),"combine" ) ||
			strstr( mats->GetName(),"dog" ) ||
			strstr( mats->GetName(),"eli" ) ||
			strstr( mats->GetName(),"gman" ) ||
			strstr( mats->GetName(),"headcrab" ) ||
			strstr( mats->GetName(),"kleiner" ) ||
			strstr( mats->GetName(),"manhack" ) ||
			strstr( mats->GetName(),"police" ) ||
			strstr( mats->GetName(),"grigori" ) ||
			strstr( mats->GetName(),"monk" ) ||
			strstr( mats->GetName(),"humans" ) ||
			strstr( mats->GetName(),"mossman" ) ||
			strstr( mats->GetName(),"stalker" ) ||
			strstr( mats->GetName(),"vortigaunt" ) ||
			strstr( mats->GetName(),"zombie" ) ||
            strstr( mats->GetName(),"hostage" ) )
		{
			if ( val == 1 )
			{
				mats->SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, true );
				mats->SetMaterialVarFlag( MATERIAL_VAR_ZNEARER, true );
				mats->SetMaterialVarFlag( MATERIAL_VAR_FLAT, true );
			}
			else if( val == 0 )
			{
				mats->SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, false );
				mats->SetMaterialVarFlag( MATERIAL_VAR_ZNEARER, false );
				mats->SetMaterialVarFlag( MATERIAL_VAR_FLAT, false );
			}
		}
    }

	g_Lua->Push( true );
	return 1;
}

// ******************************
// ReplicateVar
// ******************************
LUA_FUNCTION( ReplicateVar ) // Thank you MS and thank you C0BRA
{
	g_Lua->CheckType(1, GLua::TYPE_STRING);
	g_Lua->CheckType(2, GLua::TYPE_STRING);
	g_Lua->CheckType(3, GLua::TYPE_NUMBER);
	g_Lua->CheckType(4, GLua::TYPE_STRING);

	const char* origCvarName =	g_Lua->GetString	(1);
	const char* newCvarName =	g_Lua->GetString	(2);
	int origFlags =				g_Lua->GetInteger	(3);
	const char* defaultValue =	g_Lua->GetString	(4);

	ConVar* pCvar = g_pCVar->FindVar( origCvarName );

	if (!pCvar)
	{
		g_Lua->Push(false);
		return 1;
	}

	if(origFlags < 0) 
		origFlags = pCvar->m_nFlags;

	ConVar* pNewVar = (ConVar*)malloc( sizeof ConVar );

	memcpy( pNewVar, pCvar,sizeof( ConVar ));
	pNewVar->m_pNext = 0;
	g_pCVar->RegisterConCommand( pNewVar );
	pCvar->m_pszName = new char[50];
	
	
	char tmp[50];
	Q_snprintf(tmp, sizeof(tmp), "%s", newCvarName);
	strcpy((char*)pCvar->m_pszName, tmp);
	pCvar->m_nFlags = FCVAR_NONE;

    ConVar* cv = new ConVar(origCvarName, defaultValue, origFlags, "Renamed");
	g_pCVar->RegisterConCommand(cv);
	
	ConColorMsg( Color( 0, 255, 0, 255 ), "[HERMES]: Renamed %s to %s\n", origCvarName, newCvarName);

	g_Lua->Push(true);
	return 1;
}
// ==============================
// Initialization
// ==============================
int Init( lua_State *L )
{
	/*if( isLoaded )
	{
		ConColorMsg( Color( 255, 0, 0, 255 ), "[HERMES]: gmcl_hermes.dll is already loaded!" );
		return 0;
	}*/

	// Run Command stuff
	CreateInterfaceFn engineFactory = Sys_GetFactory("engine.dll");

	if ( !engineFactory )
	{
		return 0;
	}

	gEngine = (IVEngineClient*)engineFactory(VENGINE_CLIENT_INTERFACE_VERSION, NULL);

	if ( !gEngine )
	{
		return 0;
	}

	// Material system stuff
	CreateInterfaceFn fnMaterialSystemFactory = Sys_GetFactory("materialsystem.dll");

	if ( !fnMaterialSystemFactory )
	{
		return 0;
	}

	g_pMaterialSystem = (IMaterialSystem*)fnMaterialSystemFactory( MATERIAL_SYSTEM_INTERFACE_VERSION, NULL );

	if ( !g_pMaterialSystem )
	{
		return 0;
	}

	// Entity shit
	CreateInterfaceFn g_ClientFactory = Sys_GetFactory( "client.dll" );

	if ( !g_ClientFactory )
	{
		return 0;
	}

	g_pClientEntList = ( IClientEntityList* ) g_ClientFactory( VCLIENTENTITYLIST_INTERFACE_VERSION, NULL );

	if ( !g_pClientEntList )
	{
		return 0;
	}

	g_pCVar = *(ICvar **)GetProcAddress( GetModuleHandleA( "client.dll" ), "cvar" );

	g_Lua = Lua();

	// Get Materials
	ILuaObject* cheat = g_Lua->GetNewTable();
		cheat->SetMember( "PredictSeed", PredictSeed );
		cheat->SetMember( "Nospread", Nospread );
		cheat->SetMember( "GetSteam", GetSteam );
		cheat->SetMember( "RunCommand", RunCommand );
		cheat->SetMember( "ConsoleVisible", ConsoleVisible );
		cheat->SetMember( "IsDormant", IsDormant );
		cheat->SetMember( "ForceVar", ForceVar );
		cheat->SetMember( "ReplicateVar", ReplicateVar );
		cheat->SetMember( "ColorMsg", ColorMsg );
		cheat->SetMember( "SetWorldTransparent", SetWorldTransparent );
		cheat->SetMember( "SetHands", SetHands );
		cheat->SetMember( "XQZ", XQZ );
	g_Lua->SetGlobal( "cheat", cheat );
	cheat->UnReference();

	isLoaded = true;

	return 0;
}

// ==============================
// Shutdown
// ==============================
int Shutdown( lua_State *L )
{
	if ( VectorMetaRef )
    {
		g_Lua->FreeReference( VectorMetaRef );
	}
	return 0;
}