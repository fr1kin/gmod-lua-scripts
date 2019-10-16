#include "stdafx.h"
#include <windows.h>
#include "App.h"

CAppTools GApp;

string CAppTools::GetFileExtension( string file )
{
	return GetAfterLast( file, "." );
}

string CAppTools::GetAfterLast( string haystack, string needle )
{
	size_t lastof = haystack.find_last_of( needle );

	if( lastof != string::npos )
	{
		return haystack.substr( lastof + needle.length() );
	}

	return haystack;
}

string CAppTools::GetToLast( string haystack, string needle )
{
	size_t lastof = haystack.find_last_of( needle );

	if( lastof != string::npos )
	{
		return haystack.substr( 0, lastof );
	}

	return haystack;
}

char* CAppTools::GetDirectoryFileA( char *szFile )
{
	static char path[ MAX_PATH ];

	memset( path, 0, MAX_PATH );

	strcat_s( path, MAX_PATH, m_LocalDirectory );

	strcat_s( path, MAX_PATH, szFile );

	return path;
}

wchar_t* CAppTools::GetDirectoryFileW( wchar_t *szFile )
{
	char szFilename[ MAX_PATH ] = { 0 };

	wcstombs( szFilename, szFile, MAX_PATH );

	char *szDirectoryFile = GetDirectoryFileA( szFilename );

	static wchar_t szDirectoryFileW[ MAX_PATH ] = { 0 };

	mbstowcs( szDirectoryFileW, szDirectoryFile, MAX_PATH );

	return szDirectoryFileW;
}

void CAppTools::AddToLogFileA( char *szFile, char *szLog, ... )
{
	va_list va_alist;
	
	char logbuf[ 1024 ] = { 0 };
	
	FILE * fp;

	va_start( va_alist, szLog );
	
	_vsnprintf( logbuf + strlen( logbuf ), 
		sizeof( logbuf ) - strlen( logbuf ), 
		szLog, va_alist);

	va_end( va_alist );

	char pszPath[ MAX_PATH ] = { 0 };

	strcat_s( pszPath, MAX_PATH, m_LocalDirectory );

	strcat_s( pszPath, MAX_PATH, szFile );

	if ( ( fp = fopen ( pszPath, "a" ) ) != NULL )
	{
		fprintf( fp, "%s\n", logbuf );
		fclose( fp );
	}
}

void CAppTools::AddToLogFileW( wchar_t *szFile, wchar_t *szLog, ... )
{
	return; //Removed
}

void CAppTools::BaseUponModule( HMODULE hModule )
{
	m_LocalModule = hModule;

	memset( m_LocalDirectory, 0, MAX_PATH );

	if( GetModuleFileNameA( hModule, m_LocalDirectory, MAX_PATH ) != 0 )
	{
		for( int i = ( int )strlen( m_LocalDirectory ); i > 0; i-- )
		{
			if( m_LocalDirectory[ i ] == '\\' )
			{
				m_LocalDirectory[ i + 1 ] = 0;

				break;
			}
		}
	}
}