/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CScriptEnforcer.cpp
Purpose: SE bypass.
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

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

CVMTHook gIsActive;
bool __stdcall new_IsActive()
{
	return false;
}

bool HERPES::ScriptEnforcer::DETOUR()
{
	HMODULE hClient = NULL;

	while( hClient == NULL )
	{
		hClient = GetModuleHandleA( "client.dll" );
		Sleep( 100 );
	}
	
	PBYTE ScriptEnforcerSig = (PBYTE)"\x8B\x15\x00\x00\x00\x00\x8B\x42\x44\x83\xC4\x18\xB9\x00\x00\x00\x00\xFF\xD0";
	DWORD dwAddressOfScriptEnforcer = FindPattern((DWORD)GetModuleHandle("client.dll"), 0x00FFFFFF, ScriptEnforcerSig, "xx????xxxxxxx????xx" );

	if( dwAddressOfScriptEnforcer == NULL )
		return false;
	dwAddressOfScriptEnforcer += 2;

	IScriptEnforcer* pScriptEnforcer = (IScriptEnforcer*)*(DWORD*)dwAddressOfScriptEnforcer;
	PDWORD* pdwScriptEnforcer = (PDWORD*)pScriptEnforcer;

	while( pdwScriptEnforcer == NULL || *pdwScriptEnforcer == NULL )
	{
		Sleep(100);
	}

	char buffer[100];

	sprintf( buffer, "Offset: 0x%X 0x%X\nAddress: 0x%X", dwAddressOfScriptEnforcer, pdwScriptEnforcer, (DWORD)hClient + dwAddressOfScriptEnforcer );

	ConColorMsg( GREEN, buffer );

	gIsActive.Hook( ( DWORD )&new_IsActive, ( PDWORD )pdwScriptEnforcer, 17 );
	return true;
}