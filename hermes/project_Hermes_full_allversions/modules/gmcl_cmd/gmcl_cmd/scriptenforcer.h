/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: scriptenforcer.h
	Purpose: Disable client-side scriptenforcer

	NOTE: Most code is useless, I'm just a faggot okay
*************************************************************/
#ifndef DONTUNLOAD_H
#define DONTUNLOAD_H

#include <iostream>
#include <fstream>
#include <algorithm>

#include "vmthook.h"
#include "IScriptEnforcer.h"

BOOL DataCompare( BYTE* pData, BYTE* bMask, char * szMask )
{
	for( ; *szMask; ++szMask, ++pData, ++bMask )
		if( *szMask == 'x' && *pData != *bMask )
			return FALSE;
 
	return ( *szMask == NULL );
}

DWORD FindPattern( DWORD dwAddress, DWORD dwLen, BYTE *bMask, char * szMask )
{
	for( DWORD i = 0; i < dwLen; i++ )
		if( DataCompare( (BYTE*)( dwAddress + i ), bMask, szMask ) )
			return (DWORD)( dwAddress + i );
 
	return 0;
}

#define SDKProtectedHook( c, x ) \
	MEMORY_BASIC_INFORMATION mb##x; \
	VirtualQuery( ( LPVOID )&c->##x, &mb##x, sizeof( mb##x ) ); \
	VirtualProtect( mb##x.BaseAddress, mb##x.RegionSize, PAGE_EXECUTE_READWRITE, &mb##x.Protect ); \
	c->##x = &new_##x; \
	VirtualProtect( mb##x.BaseAddress, mb##x.RegionSize, mb##x.Protect, NULL ); \
	FlushInstructionCache( GetCurrentProcess( ), ( LPCVOID )&c->##x, sizeof( DWORD ) );

ScriptEnforcer_VTable* GHookTable;

CVMTHook gIsActive;
bool __stdcall new_IsActive()
{
	return false; // hak da planet
}

bool DoDetour()
{
	if( !canDetour ) return false;

	HMODULE hClient = NULL;

	while( hClient == NULL )
	{
		hClient = GetModuleHandleA( "client.dll" );
		Sleep( 100 );
	}

	BYTE ScriptEnforcerSig[] = { 0x8B, 0x15, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x42, 0x44, 0x83, 0xC4, 0x18 };
	DWORD dwAddressOfScriptEnforcer = FindPattern((DWORD)GetModuleHandle("client.dll"), 0x00FFFFFF, ScriptEnforcerSig, "xx????xxxxxx" );

	if( dwAddressOfScriptEnforcer == NULL )
		return false;
	dwAddressOfScriptEnforcer += 2;

	IScriptEnforcer* pScriptEnforcer = (IScriptEnforcer*)*(DWORD*)dwAddressOfScriptEnforcer;
	PDWORD* pdwScriptEnforcer = (PDWORD*)pScriptEnforcer;

	while( pdwScriptEnforcer == NULL || *pdwScriptEnforcer == NULL )
	{
		Sleep(100);
	}
	
	GHookTable = ( ScriptEnforcer_VTable* ) *pdwScriptEnforcer;
	//SDKProtectedHook( GHookTable, IsActive );

	gIsActive.Hook( ( DWORD )&new_IsActive, ( PDWORD )pdwScriptEnforcer, 17 );
	return true;
}
#endif