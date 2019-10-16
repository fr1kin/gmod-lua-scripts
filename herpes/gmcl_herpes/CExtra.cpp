/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CExtra.cpp
Purpose: Extras.
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

using namespace HERPES;

void Extras::ForceVar( const char* cvar, int value )
{
	ConVar *var = HERPES::Interfaces::m_pCVar->FindVar( cvar );
	var->SetValue( value );
}

void Extras::RunCommand( const char* cvar )
{
	Interfaces::m_pEngine->ClientCmd( cvar );
}

bool Extras::IsDormant( int index )
{
	IClientEntity* pClientEntity = Interfaces::m_pClientEntList->GetClientEntity( index );
	if( pClientEntity )
	{
		if( pClientEntity->IsDormant() )
			return true;
	}
	return false;
}

LUA_FUNCTION( lua_ForceVar )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_STRING );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_NUMBER );

	const char* cvar	= Interfaces::Lua->GetString(1);
	int value			= Interfaces::Lua->GetInteger(2);
	
	Extras::ForceVar( cvar, value );
	return 0;
}

LUA_FUNCTION( lua_RunCommand )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_STRING );

	const char* cvar = Interfaces::Lua->GetString(1);
	
	Extras::RunCommand( cvar );
	return 0;
}

LUA_FUNCTION( lua_IsDormant )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_NUMBER );

	int index = Interfaces::Lua->GetNumber( 1 );
	Interfaces::Lua->Push( Extras::IsDormant( index ) );

	return 1;
}

void Extras::LUAFUNCTION( ILuaObject* lua )
{
	static bool ran = false;
	if( ran )
		return;

	lua->SetMember( "ForceVar", lua_ForceVar );
	lua->SetMember( "RunCommand", lua_RunCommand );
	lua->SetMember( "IsDormant", lua_IsDormant );

	ran = true;
}

void Normalize( Vector &vIn, Vector &vOut )
{
    float flLen = vIn.Length();
    if( flLen == 0 )
    {
        vOut.Init( 0, 0, 1 );
        return;
    }
    flLen = 1 / flLen;
    vOut.Init( vIn.x * flLen, vIn.y * flLen, vIn.z * flLen );
}

void Extras::AntiAim( CUserCmd* cmd )
{
	Vector viewforward, viewright, viewup, aimforward, aimright, aimup;
	QAngle qAimAngles;

	float forward = cmd->forwardmove;
	float right = cmd->sidemove;
	float up = cmd->upmove;

	qAimAngles.Init(0.0f,cmd->viewangles.x,0.0f);
	qAimAngles.Init(0.0f,cmd->viewangles.y,0.0f);

	AngleVectors( qAimAngles,&viewforward,&viewright,&viewup );
	AngleVectors( cmd->viewangles,&viewforward,&viewright,&viewup );

	float diff = 90.0f - cmd->viewangles.x;

	if( cmd->buttons & IN_ATTACK )
		cmd->viewangles.x += ( diff * 2 );
	else
		cmd->viewangles.x = 180.0f;

	cmd->viewangles.y -= 180.0f;
	cmd->viewangles.z = fmod( -360.0, cmd->random_seed );
	
	qAimAngles.Init( 0.0f,cmd->viewangles.x,0.0f );
	qAimAngles.Init( 0.0f,cmd->viewangles.y,0.0f );

	AngleVectors(qAimAngles,&aimforward,&aimright,&aimup);
	AngleVectors(cmd->viewangles,&aimforward,&aimright,&aimup);

	Vector vForwardNorm;
	Vector vRightNorm;
	Vector vUpNorm;

	Normalize(viewforward,vForwardNorm);
	Normalize(viewright,vRightNorm);
	Normalize(viewup,vUpNorm);

	cmd->forwardmove = DotProduct(forward * vForwardNorm,aimforward) + DotProduct(right * vRightNorm,aimforward) + DotProduct(up * vUpNorm, aimforward);
	cmd->sidemove = DotProduct(forward * vForwardNorm,aimright) + DotProduct(right * vRightNorm,aimright) + DotProduct(up * vUpNorm,aimright);
	cmd->upmove = DotProduct(forward * vForwardNorm,aimup) +DotProduct(right * vRightNorm,aimforward) +DotProduct(up * vUpNorm,aimforward);
}

// ph0ne's
static Vector oldlocal( 0, 0, 0 ), oldestlocal( 0, 0, 0 ), oldorg( 0, 0, 0 ), oldestorg( 0, 0, 0 );

void Extras::PredictOrigin( Vector& org )
{
	oldlocal = org;
 
	Vector delta = org - oldestlocal; // delta from last known position
	Vector next = ( org + delta ) - org; // predicted delta
 
	org += ( delta + next ); // now we have the correct predicted position
 
	oldestlocal = oldlocal;
}