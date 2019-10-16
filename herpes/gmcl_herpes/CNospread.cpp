/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CNospread.h
Purpose: NOSPREAD.
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

using namespace HERPES;

LUA_FUNCTION( lua_Nospread )
{
    Interfaces::Lua->CheckType( 1, GLua::TYPE_USERCMD );
    Interfaces::Lua->CheckType( 2, GLua::TYPE_VECTOR );
    Interfaces::Lua->CheckType( 3, GLua::TYPE_VECTOR );

	// Seed
	CUserCmd *cmd = ( CUserCmd * )( Interfaces::Lua->GetUserData(1) );

	unsigned int cmd2 = *( ( int* ) cmd + 1 );
	unsigned int seed = cmd->random_seed = MD5_PseudoRandom( cmd->command_number ) & 0x7fffffff;
	
	static int vseed = 0;
	if( cmd2 != 0 )
		vseed = (int)seed;

	// Nospread
    RandomSeed( vseed & 255 );

	Vector vecForward = *( Vector* )( Interfaces::Lua->GetUserData( 2 ) );
	Vector vecRight;
	Vector vecUp;

	VectorVectors (vecForward, vecRight, vecUp );
	Vector &vecSpread = *( Vector* )( Interfaces::Lua->GetUserData( 3 ) );

	float x, y, z;
	do {
		x = RandomFloat(-1, 1) * 0.5 + RandomFloat(-1, 1) * 0.5;
		y = RandomFloat(-1, 1) * 0.5 + RandomFloat(-1, 1) * 0.5;
		z = x*x + y*y;
	} while (z > 1);

	Vector vecResult(0, 0, 0);
	vecResult = vecForward + x * vecSpread.x * vecRight + y * vecSpread.y * vecUp;

	ILuaObject* vectorLibrary = Interfaces::Lua->GetGlobal( "Vector" );
	Interfaces::Lua->Push( vectorLibrary );
	Interfaces::Lua->Push( vecResult.x );
	Interfaces::Lua->Push( vecResult.y );
	Interfaces::Lua->Push( vecResult.z );
	Interfaces::Lua->Call( 3, 1 );

	ILuaObject* ret = Interfaces::Lua->GetReturn(0);
	if ( ret )
		Interfaces::Lua->Push(ret);
	else
		Interfaces::Lua->PushNil();

    return 1;
}

void Nospread::LUAFUNCTION( ILuaObject* lua )
{
	static bool ran = false;
	if( ran )
		return;

	lua->SetMember( "Nospread", lua_Nospread );

	ran = true;
}