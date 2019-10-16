/*******************************************************
##     ## ######## ########  ########  ########  ######  
##     ## ##       ##     ## ##     ## ##       ##    ## 
##     ## ##       ##     ## ##     ## ##       ##       
######### ######   ########  ########  ######    ######  
##     ## ##       ##   ##   ##        ##             ## 
##     ## ##       ##    ##  ##        ##       ##    ## 
##     ## ######## ##     ## ##        ########  ###### 
********************************************************/

#ifndef __CVMTHOOK_H__
#define __CVMTHOOK_H__

#pragma once

#include <Windows.h>

class CVMTHook
{
public:
	DWORD Hook ( DWORD new_Function, PDWORD pClass, int index )
	{
		m_NewFunction = new_Function;
		m_FunctionIndex = index;
		m_ClassTable = *( PDWORD* )pClass;
		m_OriginalFunction = m_ClassTable[ m_FunctionIndex ];
		m_FunctionPointer = &m_ClassTable[ m_FunctionIndex ];
		ReHook();
		return FunctionAddress();
	}

	void UnHook ( void )
	{
		MEMORY_BASIC_INFORMATION mbi;
		VirtualQuery( ( LPVOID )m_FunctionPointer, &mbi, sizeof( mbi ) );
		VirtualProtect( ( LPVOID )mbi.BaseAddress, mbi.RegionSize, PAGE_EXECUTE_READWRITE, &mbi.Protect );
		m_ClassTable[ m_FunctionIndex ] = m_OriginalFunction;
		VirtualProtect( ( LPVOID )mbi.BaseAddress, mbi.RegionSize, mbi.Protect, NULL );
		FlushInstructionCache( GetCurrentProcess(), ( LPCVOID )m_FunctionPointer, sizeof( DWORD ) );
	}

	void ReHook ( void )
	{
		MEMORY_BASIC_INFORMATION mbi;
		VirtualQuery( ( LPVOID )m_FunctionPointer, &mbi, sizeof( mbi ) );
		VirtualProtect( ( LPVOID )mbi.BaseAddress, mbi.RegionSize, PAGE_EXECUTE_READWRITE, &mbi.Protect );
		m_ClassTable[ m_FunctionIndex ] = m_NewFunction;
		VirtualProtect( ( LPVOID )mbi.BaseAddress, mbi.RegionSize, mbi.Protect, NULL );
		FlushInstructionCache( GetCurrentProcess(), ( LPCVOID )m_FunctionPointer, sizeof( DWORD ) );
	}

	DWORD FunctionAddress ( void )
	{
		return m_OriginalFunction;
	}

private:
	// Member variables
	int m_FunctionIndex;
	PDWORD m_ClassTable;
	PDWORD m_FunctionPointer;
	DWORD m_NewFunction;
	DWORD m_OriginalFunction;
};
#endif // __CVMTHOOK_H__