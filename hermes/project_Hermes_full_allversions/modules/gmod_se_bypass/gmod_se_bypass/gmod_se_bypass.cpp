#include "stdafx.h"

#define NO_SDK

#include "secretheaders\\GMLuaModule.h"

#define SDKProtectedHook( c, x ) \
	MEMORY_BASIC_INFORMATION mb##x; \
	VirtualQuery( ( LPVOID )&c->##x, &mb##x, sizeof( mb##x ) ); \
	VirtualProtect( mb##x.BaseAddress, mb##x.RegionSize, PAGE_EXECUTE_READWRITE, &mb##x.Protect ); \
	c->##x = &new_##x; \
	VirtualProtect( mb##x.BaseAddress, mb##x.RegionSize, mb##x.Protect, NULL ); \
	FlushInstructionCache( GetCurrentProcess( ), ( LPCVOID )&c->##x, sizeof( DWORD ) );

ScriptEnforcer_VTable* GHookTable;

bool __stdcall new_IsActive()
{
	// IsActive being false allows us to run anything, any time

	return false;
}

bool __stdcall new_ScriptAllowed( char* strScript, unsigned char* data, int size, unsigned char* u1 )
{
	// You don't _need_ to hook this i assume, but i do anyway, whatever bro

	return true;
}

DWORD WINAPI lpBufferThread( LPVOID lpParam )
{
	HMODULE hClient = NULL;

	while( hClient == NULL )
	{
		hClient = GetModuleHandleA( "client.dll" );

		Sleep( 100 );
	}

	GApp.AddToLogFileA( "hook.log", "client.dll (0x%X)", hClient );

	CDetour det;

	//DWORD FindPattern( DWORD dwAddress, DWORD dwLen, BYTE *bMask, char* szMask );

	DWORD dwAddressOfScriptEnforcer = det.FindPattern( 
		( DWORD ) hClient, 0xFFFFFFFF, 
		( BYTE* ) "\x8B\x15\x00\x00\x00\x00\x8B\x42\x44\x83\xC4\x18", 
		( CHAR* ) "xx????xxxxxx" );

	if( dwAddressOfScriptEnforcer == NULL )
	{
		GApp.AddToLogFileA( "hook.log", "Unable to obtain address to ScriptEnforcer, dying..." );

		return 0;
	}

	dwAddressOfScriptEnforcer += 2;

	IScriptEnforcer* pScriptEnforcer = ( IScriptEnforcer* ) *( DWORD* ) dwAddressOfScriptEnforcer;

	GApp.AddToLogFileA( "hook.log", "pScriptEnforcer = (0x%X)", pScriptEnforcer );

	PDWORD* pdwScriptEnforcer = ( PDWORD* ) pScriptEnforcer;

	while( pdwScriptEnforcer == NULL || *pdwScriptEnforcer == NULL )
	{
		Sleep( 100 );
	}

	GApp.AddToLogFileA( "hook.log", "*pdwScriptEnforcer = (0x%X)", *pdwScriptEnforcer );

	GHookTable = ( ScriptEnforcer_VTable* ) *pdwScriptEnforcer;

	SDKProtectedHook( GHookTable, IsActive );
	SDKProtectedHook( GHookTable, ScriptAllowed );

	GApp.AddToLogFileA( "hook.log", "ScriptEnforcer hook complete!" );

	return 0;
}

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	if( ul_reason_for_call == DLL_PROCESS_ATTACH )
	{
		GApp.BaseUponModule( hModule );
		GApp.AddToLogFileA( "hook.log", "Added module.." );

		CreateThread( 0, 0, lpBufferThread, 0, 0, 0 );
	}

    return TRUE;
}