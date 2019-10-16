#ifndef GMLUAMODULEEX_H
#define GMLUAMODULEEX_H

// GMod interface //

#include "GMLuaModule.h"

#define _META_BASE 5200

// Global macros //

// Meta tables (META_)

#define GET_META( index, name )					(name *)g_Lua->GetUserData( index )

#define PUSH_META( data, name ) \
	{ \
		if ( data ) \
		{ \
			ILuaObject *META__tbl = g_Lua->GetMetaTable( GET_META_NAME( name ), GET_META_ID( name ) ); \
			g_Lua->PushUserData( META__tbl, (void *)data); \
			META__tbl->UnReference(); \
		} \
		else \
		{ \
			g_Lua->PushNil(); \
		} \
	} \

#define PUSH_META_REF( data, ref ) \
	{ \
		if ( data ) \
		{ \
			g_Lua->PushReference( ref ); \
			ILuaObject *META__tbl = g_Lua->GetObject(); \
			g_Lua->Pop(); \
			g_Lua->PushUserData( META__tbl, (void *)data ); \
			META__tbl->UnReference(); \
		} \
		else \
		{ \
			g_Lua->PushNil(); \
		} \
	} \

#define PUSH_META_LOOKUP( data, name, id ) \
	{ \
		if ( data ) \
		{ \
			ILuaObject *META__tbl = g_Lua->GetMetaTable( name, id ); \
			g_Lua->PushUserData( META__tbl, (void *)data); \
			META__tbl->UnReference(); \
		} \
		else \
		{ \
			g_Lua->PushNil(); \
		} \
	} \

#define META_FUNCTION( meta, name )				LUA_FUNCTION( meta##__##name )

#define	META_ID( name, id )						const int META_##name##_id = _META_BASE + id; \
												const char *META_##name##_name = #name

#define EXT_META_FUNCTION( meta, name )			extern META_FUNCTION( meta, name )

#define EXT_META_ID( name, id )					extern const int META_##name##_id; \
												extern const char *META_##name##_name

#define GET_META_ID( name )						META_##name##_id
#define GET_META_NAME( name )					META_##name##_name

#define BEGIN_INDEX_REGISTRATION() \
	ILuaObject *META__index = g_Lua->GetNewTable()

#define _BEGIN_META_REGISTRATION( name ) \
	{ \
		ILuaObject *META__tbl = g_Lua->GetMetaTable( GET_META_NAME( name ), GET_META_ID( name ) )
		

#define BEGIN_META_REGISTRATION( name ) \
		_BEGIN_META_REGISTRATION( name ); \
		BEGIN_INDEX_REGISTRATION()

#define REG_META_FUNCTION( meta, name ) \
	META__index->SetMember( #name, meta##__##name )

#define REG_META_CALLBACK( meta, name ) \
	META__tbl->SetMember( #name, meta##__##name )

#define END_INDEX_REGISTRATION() \
		META__tbl->SetMember( "__index", META__index ); \
		META__index->UnReference()

#define _END_META_REGISTRATION() \
		META__tbl->UnReference(); \
	} \

#define END_META_REGISTRATION() \
		END_INDEX_REGISTRATION(); \
		META__tbl->UnReference(); \
	} \

#define BEGIN_META_GEXTENSION( name, id ) \
	{ \
		ILuaObject *META__tbl = g_Lua->GetMetaTable( name, id ); \

#define REG_META_GFUNCTION( meta, name ) \
	META__tbl->SetMember( #name, meta##__##name )

#define END_META_GEXTENSION( ) \
		META__tbl->UnReference(); \
	} \

// Enumerations

#define BEGIN_ENUM_REGISTRATION( name ) \
	{ \
		g_Lua->NewGlobalTable( #name ); \
		ILuaObject *ENUM__tbl = g_Lua->GetGlobal( #name )

#define REG_ENUM( name, value ) \
	ENUM__tbl->SetMember( #value, (float)value )

#define END_ENUM_REGISTRATION( ) \
		ENUM__tbl->UnReference(); \
	} \

// Globals (GLBL_)

#define GLBL_FUNCTION( name )				LUA_FUNCTION( _G__##name )

#define EXT_GLBL_FUNCTION( name )			extern GLBL_FUNCTION( name )

#define REG_GLBL_FUNCTION( name )		g_Lua->SetGlobal( #name, _G__##name )

#define _REG_GLBL_NUMBER( name, value ) \
	g_Lua->SetGlobal( name, (float)value )

#define REG_GLBL_NUMBER( name ) \
	_REG_GLBL_NUMBER( #name, (float)name )

#define _REG_GLBL_STRING( name, value ) \
	g_Lua->SetGlobal( name, (const char *)value )

#define REG_GLBL_STRING( name ) \
	_REG_GLBL_STRING( #name, (const char *)name )

// Global tables

#define BEGIN_GTABLE_REGISTRATION( name ) \
	g_Lua->NewGlobalTable( #name ); \
	{ \
		ILuaObject *__gtable = g_Lua->GetGlobal( #name )

#define REG_GTABLE_FUNCTION( t, name ) \
		__gtable->SetMember( #name, t##_##name ); \

#define END_GTABLE_REGISTRATION( ) \
		__gtable->UnReference(); \
	} \

// Util functions

inline void UTIL_CreateLuaReference( ILuaObject *obj, int *ref )
{
	if ( obj )
	{
		obj->Push();

		*ref = g_Lua->GetReference( -1, true );

		obj->UnReference();
	}
	else
	{
		*ref = -1;
	}
}

#endif // GMLUAMODULEEX_H