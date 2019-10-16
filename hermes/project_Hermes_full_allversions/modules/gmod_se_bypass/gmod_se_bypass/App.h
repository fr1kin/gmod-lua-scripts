#ifndef __APPTOOLS_HEADER__
#define __APPTOOLS_HEADER__

#include <windows.h>
#include <string>

using namespace std;

class CAppTools
{
public:
	string		GetFileExtension( string file );
	string		GetAfterLast( string haystack, string needle );
	string		GetToLast( string haystack, string needle );

	char*		GetDirectoryFileA( char *szFile );
	wchar_t*	GetDirectoryFileW( wchar_t *szFile );
	void		AddToLogFileA( char *szFile, char *szLog, ... );
	void		AddToLogFileW( wchar_t *szFile, wchar_t *szLog, ... );
	void		BaseUponModule( HMODULE hModule );

	HMODULE		GetLocalModule(){ return m_LocalModule; }

	HMODULE		m_LocalModule;
	char		m_LocalDirectory[ 320 ];
};

extern CAppTools GApp;

#endif