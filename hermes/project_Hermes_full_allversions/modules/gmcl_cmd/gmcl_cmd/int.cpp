/*************************************************************
	   __ __                        
	  / // /___  ____ __ _  ___  ___
	 / _  // -_)/ __//  ' \/ -_)(_-<
	/_//_/ \__//_/  /_/_/_/\__//___/
	
	Name: int.cpp
	Purpose: Install module

	Alot of stolen code in this shit because im the best coder ever
*************************************************************/
#pragma once

#define GAME_DLL
#define CLIENT_DLL
#define WIN32_LEAN_AND_MEAN

#pragma comment(lib, "psapi.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "vstdlib.lib")
#pragma comment(lib, "tier0.lib")
#pragma comment(lib, "tier1.lib")
#pragma comment(lib, "psapi.lib")

#include <windows.h>

// Other stuff
#include "GMLuaModule.h"
#include "cdll_int.h"
#include "filesystem.h"

// Replicator
#include <convar.h>
#include <icvar.h>
#include <tier1.h>

// Nospread
#include <eiface.h>
#include <math.h>
#include <usercmd.h>
#include <checksum_md5.h>
#include <vstdlib/random.h>
#include "mathlib/vector.h"

// Dormant
#include <icliententity.h>
#include <icliententitylist.h>

// Nohands
#include <materialsystem/imaterial.h>
#include <materialsystem/imaterialsystem.h>

// Prediction
#include <inetchannelinfo.h>

#include <cbase.h>

#include <string.h>
#include <iostream>
#include <fstream>
#include <algorithm>

ILuaInterface* gLua;

CreateInterfaceFn g_pMaterialFactory = NULL;
CreateInterfaceFn g_pEngineFactory = NULL;
CreateInterfaceFn g_pClientFactory = NULL;
CreateInterfaceFn g_pFileFactory = NULL;
CreateInterfaceFn g_pStudioFactory = NULL;
CreateInterfaceFn g_pPhysicsFactory= NULL;
CreateInterfaceFn g_pVguiMat = NULL;
CreateInterfaceFn g_pVgui = NULL;

#include "int.h"

IMaterialSystem				*g_pMaterialSystem = NULL;
IClientEntityList			*g_pClientEntList = NULL;
INetChannelInfo				*g_pNetChannelInfo;
IVEngineClient				*g_pEngine = NULL;
IFileSystem					*g_pFileSystem = NULL;
ICvar						*g_pCVar = NULL;
IBaseClientDLL				*g_pClient = NULL;
IClientDLLSharedAppSystems	*g_pClientInterfaces = NULL;
IPrediction					*g_pPrediction = NULL;
IEngineSound				*g_pSound = NULL;
IGameEvent					*g_pGameEventManager = NULL;
IVModelRender				*g_pModelRender = NULL;
IVRenderView				*g_pRenderView = NULL;
IEngineTrace				*g_pEngineTrace = NULL;
IEngineVGui					*g_pEngineVGui = NULL;
IVEfx						*g_pEffects = NULL;
IVModelInfoClient			*g_pModelInfo = NULL;
IVDebugOverlay				*g_pDebugOverlay = NULL;
IStudioRender				*g_pStudioRender = NULL;
IPhysics					*g_pPhysics = NULL;
IPhysicsSurfaceProps		*g_pPhysicsSurfaceProps = NULL;
vgui::ISurface				*g_pSurface = NULL;
vgui::IPanel				*g_pPanel = NULL;
vgui::IVGui					*g_pVGui = NULL;
CGlobalVarsBase				*g_pGlobals = NULL;

IUniformRandomStream *random = NULL;

#include <shot_manipulator.h>

GMOD_MODULE( Init, Shutdown );

using namespace std;

/*--------------------
	:: Message 
--------------------*/
void HERMES::Msg( const tchar *text, const Color &col )
{
	ConColorMsg( col, "[HERMES]: " );
	ConColorMsg( Color( 255, 255, 255, 255 ), text );
}

LUA_FUNCTION( lua_Msg )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );
	gLua->CheckType( 2, GLua::TYPE_TABLE );

	const tchar* msg = gLua->GetString(1);

	ILuaObject* col = gLua->GetObject(2);
		int r = col->GetMemberInt("r");
		int g = col->GetMemberInt("g");
		int b = col->GetMemberInt("b");
	col->UnReference();

	Color textcol(r,g,b,255);

	ConColorMsg( textcol, msg );
	return 0;
}

/*********************
	:: Require
*********************/
LUA_FUNCTION( lua_Require )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );
	gLua->RunModule( gLua->GetString( 1 ) );

	return 0;
}

/*********************
	:: Include
*********************/
void RunString( string path, string data, bool shouldRun )
{
	gLua->RunString( path.c_str(), "", data.c_str(), shouldRun, true );
}

void Include( string name, bool inPath )
{
	string path = "__autoload__/";
	if( !inPath )
		path = "";
	path += name;

	FileHandle_t file = g_pFileSystem->Open(path.c_str(), "rb");

	if (!file)
		return;

	int size = g_pFileSystem->Size(file);

	char *buf = new char[size + 1];

	g_pFileSystem->Read(buf, size, file);
	g_pFileSystem->Close(file);

	buf[size] = 0;

	RunString( path, buf, true );

	delete[] buf;
	return;
}

LUA_FUNCTION( lua_Include )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );
	gLua->CheckType( 2, GLua::TYPE_BOOL );
	string name = gLua->GetString( 1 );
	bool inpath = gLua->GetBool( 2 );

	Include( name, inpath );

	return 0;
}

/*--------------------
	:: GetHitbox 
--------------------*/
//bool GetHitboxPosition ( int hitbox, Vector& origin, int index, QAngle& angles )

LUA_FUNCTION( lua_GetHitboxPosition )
{
	gLua->CheckType( 1, GLua::TYPE_NUMBER );
	gLua->CheckType( 2, GLua::TYPE_NUMBER );

	int iHitBox = gLua->GetNumber( 1 );
	int index = gLua->GetNumber( 2 );

	Vector retVec = Vector( 0, 0, 0 );

	gLua->Msg( "1" );
	if( iHitBox < 0 || iHitBox >= 20 )
	{
		gLua->Msg( "2" );
		gLua->PushNil();
		return 1;
	}
	matrix3x4_t pmatrix[MAXSTUDIOBONES];
	Vector vMin, vMax;
	IClientEntity* ClientEntity = g_pClientEntList->GetClientEntity( index );
	if ( ClientEntity == NULL )
	{
		gLua->Msg( "3" );
		gLua->PushNil();
		return 1;
	}
	if ( ClientEntity->IsDormant() )
	{
		gLua->Msg( "4" );
		gLua->PushNil();
		return 1;
	}
	const model_t * model;
	model = ClientEntity->GetModel();

	if( model )
	{
		studiohdr_t *pStudioHdr = g_pModelInfo->GetStudiomodel( model);
		if ( !pStudioHdr )
		{
			gLua->PushNil();
			gLua->Msg( "5" );
			return 1;
		}
		if( ClientEntity->SetupBones( pmatrix, 128, BONE_USED_BY_HITBOX, g_pGlobals->curtime) == false )
		{
			gLua->Msg( "6" );
			gLua->PushNil();
			return 1;
		}
		mstudiohitboxset_t *set = pStudioHdr->pHitboxSet( 0 );
		if ( !set )
		{
			gLua->Msg( "7" );
			gLua->PushNil();
			return 1;
		}
		mstudiobbox_t* pbox = NULL;
		pbox = pStudioHdr->pHitbox(iHitBox, 0);
		VectorTransform( pbox->bbmin, pmatrix[ pbox->bone ], vMin );
		VectorTransform( pbox->bbmax, pmatrix[ pbox->bone ], vMax );
		retVec = ( vMin + vMax ) * 0.5f;

		ILuaObject* vectorLib = gLua->GetGlobal( "Vector" );
			gLua->Push( vectorLib );
			gLua->Push( retVec.x );
			gLua->Push( retVec.y );
			gLua->Push( retVec.z );
		gLua->Call( 3, 1 );

		vectorLib->UnReference();

		ILuaObject* ret = gLua->GetReturn( 0 );

		if ( ret )
			gLua->Push( ret );
		else
			gLua->PushNil();

		ret->UnReference();
		return 1;
	}
	gLua->Msg( "8" );
	gLua->PushNil();
	return 1;
}

/*********************
	:: Replicator
*********************/
LUA_FUNCTION( lua_ReplicateVar )
{
	if ( !g_pCVar )
	{
		return 0;
	}

	gLua->CheckType(1, GLua::TYPE_STRING);
	gLua->CheckType(2, GLua::TYPE_STRING);
	gLua->CheckType(3, GLua::TYPE_NUMBER);
	gLua->CheckType(4, GLua::TYPE_STRING);

	const char* origCvarName =	gLua->GetString		(1);
	const char* newCvarName =	gLua->GetString		(2);
	int origFlags =				gLua->GetInteger	(3);
	const char* defaultValue =	gLua->GetString		(4);

	ConVar* pCvar = g_pCVar->FindVar( origCvarName );

	if (!pCvar)
	{
		return 0;
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
	
	ConColorMsg( Color( 0, 255, 0, 255 ), "[HERMES]: " );
	ConColorMsg( Color( 255, 255, 255, 255 ), "Replicated ConVar %s to %s\n", origCvarName, newCvarName );
	return 0;
}

/*--------------------
	:: ForceVar 
--------------------*/
void HERMES::ForceVar( const char* cvar, int value )
{
	ConVar *var = g_pCVar->FindVar( cvar );
	var->SetValue( value );
}

LUA_FUNCTION( lua_ForceVar )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );
	gLua->CheckType( 2, GLua::TYPE_NUMBER );

	const char* cvar = gLua->GetString(1);
	int value =	gLua->GetInteger(2);
	
	HERMES::ForceVar( cvar, value );
	return 0;
}

/*--------------------
	:: RunCommand 
--------------------*/
void HERMES::RunCommand( const char* cvar )
{
	g_pEngine->ClientCmd( cvar );
}

LUA_FUNCTION( lua_RunCommand )
{
	gLua->CheckType( 1, GLua::TYPE_STRING );

	const char* cvar = gLua->GetString(1);
	
	HERMES::RunCommand( cvar );
	return 0;
}

/*********************
	:: Nospread
*********************/
int VectorMetaRef = NULL;

ILuaObject* NewVectorObject( lua_State *L, Vector& vec )
{
	if( VectorMetaRef == NULL )
	{
		ILuaObject *VectorMeta = gLua->GetGlobal("Vector");
		VectorMeta->Push();
		VectorMetaRef = gLua->GetReference(-1, true);
		VectorMeta->UnReference();
	}

	gLua->PushReference(VectorMetaRef);

	if(gLua->GetType(-1) != GLua::TYPE_FUNCTION)
	{
		gLua->Push( gLua->GetGlobal( "Vector" ) );
	}

	gLua->Push(vec.x);
	gLua->Push(vec.y);
	gLua->Push(vec.z);
	gLua->Call(3, 1);
	return gLua->GetReturn( 0 );
}

void GMOD_PushVector( lua_State* L, Vector& vec )
{
	ILuaObject* obj = NewVectorObject( L, vec );
		gLua->Push( obj );
	obj->UnReference();
}

Vector *GMOD_GetVector( lua_State* L, int stackPos )
{
	return ( Vector* )( gLua->GetUserData( stackPos ) );
}

/*--------------------
	:: Nospread 
--------------------*/
int vseed = 0;
LUA_FUNCTION( lua_PredictSpread )
{
	gLua = Lua();

    gLua->CheckType( 1, GLua::TYPE_USERCMD );
    gLua->CheckType( 2, GLua::TYPE_VECTOR );
    gLua->CheckType( 3, GLua::TYPE_VECTOR );

	// Seed
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData(1) );

	unsigned int cmd2 = *( ( int* ) cmd + 1 );
	unsigned int seed = cmd->random_seed = MD5_PseudoRandom( cmd->command_number ) & 0x7fffffff;
	
	if( cmd2 != 0 )
		vseed = (int)seed;

	// Nospread
    RandomSeed( vseed & 255 );

	Vector vecForward = *(Vector*)(gLua->GetUserData(2));
	Vector vecRight;
	Vector vecUp;
	VectorVectors(vecForward, vecRight, vecUp);
	Vector &vecSpread = *(Vector*)(gLua->GetUserData(3));

	float x, y, z;
	do {
		x = RandomFloat(-1, 1) * 0.5 + RandomFloat(-1, 1) * 0.5;
		y = RandomFloat(-1, 1) * 0.5 + RandomFloat(-1, 1) * 0.5;
		z = x*x + y*y;
	} while (z > 1);

	Vector vecResult(0, 0, 0);
	vecResult = vecForward + x * vecSpread.x * vecRight + y * vecSpread.y * vecUp;

	ILuaObject* vectorLibrary = gLua->GetGlobal("Vector");
	gLua->Push(vectorLibrary);
	gLua->Push(vecResult.x);
	gLua->Push(vecResult.y);
	gLua->Push(vecResult.z);
	gLua->Call(3, 1);
	ILuaObject* ret = gLua->GetReturn(0);
	if (ret)
		gLua->Push(ret);
	else
		gLua->PushNil();
    return 1;
}

/*--------------------
	:: IsDormant 
--------------------*/
LUA_FUNCTION( lua_IsDormant )
{
	gLua->CheckType( 1, GLua::TYPE_NUMBER );

	int index = gLua->GetNumber( 1 );

	IClientEntity* pClientEntity = g_pClientEntList->GetClientEntity( index );
	
	if ( pClientEntity )
	{
		gLua->Push( pClientEntity->IsDormant() );
		return 1;
	}
	else
	{
		return 0;
	}
}

/*--------------------
	:: Fake Angles 
--------------------*/
void Normalize(Vector &vIn, Vector &vOut)
{
    float flLen = vIn.Length();
    if(flLen == 0)
    {
        vOut.Init(0, 0, 1);
        return;
    }
    flLen = 1 / flLen;
    vOut.Init(vIn.x * flLen, vIn.y * flLen, vIn.z * flLen);
}

// Didn't code this, k
LUA_FUNCTION( lua_FakeAngles )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	gLua->CheckType( 2, GLua::TYPE_NUMBER );
	gLua->CheckType( 3, GLua::TYPE_NUMBER );
	
	float p = gLua->GetNumber( 2 );
	float y = gLua->GetNumber( 3 );

	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );

	Vector vForward,vRight,vUp,aForward,aRight,aUp,nForward,nRight,nUp;
	QAngle Angles;

	float forward = cmd->forwardmove,right = cmd->sidemove,up = cmd->upmove;

	Angles.Init(0.0f,cmd->viewangles.y,0.0f);
	Angles.Init(0.0f,cmd->viewangles.x,0.0f);

	AngleVectors(Angles,&vForward,&vRight,&vUp);
	AngleVectors(cmd->viewangles,&vForward,&vRight,&vUp);

	QAngle fakeang = QAngle(
		p + float( rand() % 20 ),
		y + float( rand() % 40 ),
		-360.0f + float( rand() % 20 )
	);
	QAngle fake = QAngle( 0, 0, 0 );

	VectorCopy( QAngle( cmd->viewangles - fakeang ), fake );

	if( cmd->viewangles.Length() > 0 )
            cmd->viewangles = ( cmd->viewangles / cmd->viewangles.Length() ) * cmd->viewangles.Length();

	if( fakeang.Length() > 1 )
		fakeang = ( fakeang / fakeang.Length() ) * fakeang.Length();

	Vector viewforward,viewright,viewup;
	Vector aimforward,aimright,aimup;

	if( true )
		VectorCopy( QAngle( cmd->viewangles - fakeang ), fake );

	if( false )
		VectorCopy( QAngle( cmd->viewangles + fakeang), fake );

	if( cmd->viewangles.Length() > 0 )
		cmd->viewangles = ( cmd->viewangles / cmd->viewangles.Length() ) * cmd->viewangles.Length();

	AngleVectors( cmd->viewangles, &viewforward, &viewright, &viewup );

	if( cmd->viewangles.x = fake.x )
		while( cmd->viewangles.x < -180 )cmd->viewangles.x += 360;

	if( cmd->viewangles.x = fake.x )
		while( cmd->viewangles.x > 180 )cmd->viewangles.x -= 360;

	if( cmd->viewangles.y = fake.y )
		while( cmd->viewangles.y < -180 )cmd->viewangles.y += 360;

	if( cmd->viewangles.y = fake.y )
		while( cmd->viewangles.y > 180 )cmd->viewangles.y -= 360;

	if( cmd->viewangles.z = fake.z )
		while( cmd->viewangles.z < -180 )cmd->viewangles.z += 360;

	if( cmd->viewangles.z = fake.z )
		while( cmd->viewangles.z > 180 )cmd->viewangles.z -= 360;

	Angles.Init(0.0f,cmd->viewangles.x,0.0f);
	Angles.Init(0.0f,cmd->viewangles.y,0.0f);

	AngleVectors(Angles,&aForward,&aRight,&aUp);
	AngleVectors(cmd->viewangles,&aForward,&aRight,&aUp);

	Normalize(vForward,nForward);
	Normalize(vRight,nRight);
	Normalize(vUp,nUp);

	cmd->forwardmove = DotProduct(forward * nForward,aForward) + DotProduct(right * nRight,aForward) + DotProduct(up * nUp,aForward);
	cmd->sidemove = DotProduct(forward * nForward,aRight) + DotProduct(right * nRight,aRight) + DotProduct(up * nUp,aRight);
	cmd->upmove = DotProduct(forward * nForward,aUp) + DotProduct(right * nRight,aUp) + DotProduct(up * nUp,aUp);
	return 0;
}

/*--------------------
	:: Antiaim
--------------------*/
LUA_FUNCTION( lua_AntiAim )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	gLua->CheckType( 2, GLua::TYPE_NUMBER );
	
	float type = gLua->GetNumber( 2 );

	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );

	Vector viewforward, viewright, viewup, aimforward, aimright, aimup;
	QAngle qAimAngles;

	float forward = cmd->forwardmove;
	float right = cmd->sidemove;
	float up = cmd->upmove;

	qAimAngles.Init(0.0f,cmd->viewangles.x,0.0f);
	qAimAngles.Init(0.0f,cmd->viewangles.y,0.0f);

	AngleVectors(qAimAngles,&viewforward,&viewright,&viewup);
	AngleVectors(cmd->viewangles,&viewforward,&viewright,&viewup);

	if( type == 1 )
	{
		cmd->viewangles.x = 180;
		cmd->viewangles.y = ((vec_t)(rand()%210));
		cmd->viewangles.z = cmd->viewangles.z + 360;
	}
	else if( type == 2 )
	{
		cmd->viewangles.x = 180;
		cmd->viewangles.y = ((vec_t)(rand()%210));
		cmd->viewangles.z = cmd->viewangles.z + 360;
	}

	qAimAngles.Init(0.0f,cmd->viewangles.x,0.0f);
	qAimAngles.Init(0.0f,cmd->viewangles.y,0.0f);

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
	return 0;
}

/*--------------------
	:: SetAngles 
--------------------*/
LUA_FUNCTION( lua_SetViewAngles )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );
	gLua->CheckType( 2, GLua::TYPE_VECTOR );
	
	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );
	Vector *vec = ( Vector * )( gLua->GetUserData( 2 ) );
	
	cmd->viewangles.x = vec->x;
	cmd->viewangles.y = vec->y;
	cmd->viewangles.z = vec->z;

	return 0;
}

LUA_FUNCTION( lua_GetViewAngles )
{
	gLua->CheckType( 1, GLua::TYPE_USERCMD );

	CUserCmd *cmd = ( CUserCmd * )( gLua->GetUserData( 1 ) );

	ILuaObject* angleLib = gLua->GetGlobal( "Angle" );
		gLua->Push( angleLib );
		gLua->Push( cmd->viewangles.y );
		gLua->Push( cmd->viewangles.z );
		gLua->Push( cmd->viewangles.x );
	gLua->Call( 3, 1 );

	angleLib->UnReference();

	ILuaObject* ret = gLua->GetReturn( 0 );

	if ( ret )
		gLua->Push( ret );
	else
		gLua->PushNil();

	ret->UnReference();

	return 1;
}

/*--------------------
	:: Nohands 
--------------------*/
bool cssIN = false;
bool hl2IN = false;

IMaterial* css = NULL;
IMaterial* hl2 = NULL;

bool isLoaded = false;
void LoadMaterials()
{
	if( !isLoaded )
	{
		css = g_pMaterialSystem->FindMaterial( "models\\weapons\\v_models\\hands\\v_hands", "Model textures" );
		hl2 = g_pMaterialSystem->FindMaterial( "models\\weapons\\v_hand\\v_hand_sheet", "Model textures" );
		isLoaded = true;
	}
}

LUA_FUNCTION( lua_ToggleHands )
{
	LoadMaterials();
	if( css != NULL && !css->IsErrorMaterial() )
	{
		if( cssIN == false )
		{
			css->SetMaterialVarFlag( MATERIAL_VAR_NO_DRAW, true );
			cssIN = true;
		}
		else
		{
			css->SetMaterialVarFlag( MATERIAL_VAR_NO_DRAW, false );
			cssIN = false;
		}
		css->Release();
	}

	if( hl2 != NULL && !hl2->IsErrorMaterial() )
	{
		if( hl2IN == false )
		{
			hl2->SetMaterialVarFlag( MATERIAL_VAR_NO_DRAW, true );
			hl2IN = true;
		}
		else
		{
			hl2->SetMaterialVarFlag( MATERIAL_VAR_NO_DRAW, false );
			hl2IN = false;
		}
		hl2->Release();
	}

	return 0;
}

/*--------------------
	:: LagCompensation 
--------------------*/
LUA_FUNCTION( lua_LagCompensation )
{
	gLua->CheckType( 1, GLua::TYPE_VECTOR );
	gLua->CheckType( 2, GLua::TYPE_NUMBER );

	Vector &vOrigin = *(Vector*)gLua->GetUserData( 1 );

	static Vector vOldOrigin( 0, 0, 0 );
	static Vector vOldestOrigin( 0, 0, 0 );

	Vector vDeltaOrigin( 0, 0, 0 );
	Vector vPredicted( 0, 0, 0 );

	vDeltaOrigin = vOrigin - vOldestOrigin;
	vOldestOrigin = vOldOrigin;
	vOldOrigin = vOrigin;

	float flLatency = gLua->GetNumber( 2 );

	vDeltaOrigin[0] *= flLatency;
	vDeltaOrigin[1] *= flLatency;
	vDeltaOrigin[2] *= flLatency;

	vPredicted = vOrigin + vDeltaOrigin;

	ILuaObject* vectorLibrary = gLua->GetGlobal( "Vector" );
		gLua->Push( vectorLibrary );
		gLua->Push( vPredicted.x );
		gLua->Push( vPredicted.y );
		gLua->Push( vPredicted.z );
	gLua->Call( 3, 1 );

	vectorLibrary->UnReference();

	ILuaObject* ret = gLua->GetReturn( 0 );

	if ( ret )
		gLua->Push( ret );
	else
		gLua->PushNil();

	ret->UnReference();

	return 1;
}

/*--------------------
	:: InMenu 
--------------------*/
LUA_FUNCTION( lua_InMenu )
{
	gLua->Push( InMenu() );
	return 1;
}

/*--------------------
	:: VectorTransform 
--------------------*/
/*
void VectorTransform (float *in1, float in2[3][4], float *out) 
{ 
    out[0] = DotProduct(in1, in2[0]) + in2[0][3]; 
    out[1] = DotProduct(in1, in2[1]) + in2[1][3]; 
    out[2] = DotProduct(in1, in2[2]) + in2[2][3]; 
} 

LUA_FUNCTION( lua_GetHitboxPos )
{
	gLua->CheckType( 1, GLua::TYPE_NUMBER );
	gLua->CheckType( 2, GLua::TYPE_VECTOR );
	
	typedef float BoneMatrix_t[MAXSTUDIOBONES][3][4]; 
	BoneMatrix_t *pBoneMatrix = (BoneMatrix_t*)IEngineStudio.StudioGetBoneTransform(); 

}
*/

/********************
	:: Startup/Shutdown
*********************/
int Init( lua_State* L )
{
	gLua = Lua();

	gLua->Msg( "Loading...\n" );

	g_pMaterialFactory = Sys_GetFactory( "materialsystem.dll" );
	g_pMaterialSystem = (IMaterialSystem*)g_pMaterialFactory( MATERIAL_SYSTEM_INTERFACE_VERSION, NULL );

	g_pFileFactory = Sys_GetFactory( "filesystem_steam.dll" );
	g_pFileSystem = (IFileSystem*)g_pFileFactory( FILESYSTEM_INTERFACE_VERSION, NULL );

	g_pStudioFactory = Sys_GetFactory( "StudioRender.dll" );
	g_pStudioRender = (IStudioRender*)g_pStudioFactory( STUDIO_RENDER_INTERFACE_VERSION, NULL );

	g_pPhysicsFactory = Sys_GetFactory( "vphysics.dll" );
	g_pPhysics = (IPhysics*)g_pPhysicsFactory( VPHYSICS_INTERFACE_VERSION, NULL );
	g_pPhysicsSurfaceProps = (IPhysicsSurfaceProps*)g_pPhysicsFactory( VPHYSICS_SURFACEPROPS_INTERFACE_VERSION, NULL );

	g_pVguiMat = Sys_GetFactory( "vguimatsurface.dll" );
	g_pSurface = (vgui::ISurface*)g_pVguiMat( VGUI_SURFACE_INTERFACE_VERSION, NULL );

	g_pVgui = Sys_GetFactory( "vgui2.dll" );
	g_pPanel = (vgui::IPanel*)g_pVgui( VGUI_PANEL_INTERFACE_VERSION, NULL );
	g_pVGui = (vgui::IVGui*)g_pVgui( VGUI_IVGUI_INTERFACE_VERSION, NULL );

	g_pEngineFactory = Sys_GetFactory( "engine.dll" );

	// Engine
	g_pNetChannelInfo = (INetChannelInfo*)g_pEngineFactory( VENGINE_CLIENT_INTERFACE_VERSION, NULL);
	g_pEngine = (IVEngineClient*)g_pEngineFactory( VENGINE_CLIENT_INTERFACE_VERSION, NULL );
	random = (IUniformRandomStream *)g_pEngineFactory( VENGINE_SERVER_RANDOM_INTERFACE_VERSION, NULL );
	g_pSound = (IEngineSound *)g_pEngineFactory( IENGINESOUND_CLIENT_INTERFACE_VERSION, NULL );
	g_pGameEventManager = (IGameEvent *)g_pEngineFactory( INTERFACEVERSION_GAMEEVENTSMANAGER2, NULL );
	g_pModelRender = (IVModelRender *)g_pEngineFactory( VENGINE_HUDMODEL_INTERFACE_VERSION, NULL );
	g_pRenderView = (IVRenderView *)g_pEngineFactory( VENGINE_RENDERVIEW_INTERFACE_VERSION, NULL );
	g_pEngineTrace = (IEngineTrace *)g_pEngineFactory( INTERFACEVERSION_ENGINETRACE_CLIENT, NULL );
	g_pEngineVGui = (IEngineVGui *)g_pEngineFactory( VENGINE_VGUI_VERSION, NULL );
	g_pEffects = (IVEfx *)g_pEngineFactory( VENGINE_EFFECTS_INTERFACE_VERSION, NULL );
	g_pModelInfo = (IVModelInfoClient *)g_pEngineFactory( "VModelInfoClient005", NULL );
	g_pSound = (IEngineSound *)g_pEngineFactory( IENGINESOUND_CLIENT_INTERFACE_VERSION, NULL );
	g_pDebugOverlay = (IVDebugOverlay *)g_pEngineFactory( VDEBUG_OVERLAY_INTERFACE_VERSION, NULL );

	g_pClientFactory = Sys_GetFactory( "client.dll" );

	// Client
	g_pClientEntList = ( IClientEntityList* )g_pClientFactory( VCLIENTENTITYLIST_INTERFACE_VERSION, NULL );
	g_pClientInterfaces = (IClientDLLSharedAppSystems*)g_pClientFactory( CLIENT_DLL_SHARED_APPSYSTEMS, NULL );
	g_pPrediction = (IPrediction*)g_pClientFactory( VCLIENT_PREDICTION_INTERFACE_VERSION, NULL );
	g_pClient = (IBaseClientDLL*)g_pClientFactory( CLIENT_DLL_INTERFACE_VERSION, NULL );

	g_pGlobals = (CGlobalVarsBase*) *(PDWORD)(*(PDWORD)*(PDWORD)g_pClient + 0x39);

	g_pCVar = *(ICvar **)GetProcAddress( GetModuleHandleA( "client.dll" ), "cvar" );

	ILuaObject* cheat = gLua->GetNewTable();
		cheat->SetMember( "ReplicateVar", lua_ReplicateVar );
		cheat->SetMember( "ForceVar", lua_ForceVar );
		cheat->SetMember( "RunCommand", lua_RunCommand );
		cheat->SetMember( "PredictSpread", lua_PredictSpread );
		cheat->SetMember( "IsDormant", lua_IsDormant );
		cheat->SetMember( "ToggleHands", lua_ToggleHands );
		cheat->SetMember( "LagCompensation", lua_LagCompensation );
		cheat->SetMember( "FakeAngles", lua_FakeAngles );
		cheat->SetMember( "AntiAim", lua_AntiAim );
		cheat->SetMember( "Require", lua_Require );
		cheat->SetMember( "Include", lua_Include );
		cheat->SetMember( "InMenu", lua_InMenu );
		cheat->SetMember( "SetViewAngles", lua_SetViewAngles );
		cheat->SetMember( "GetViewAngles", lua_GetViewAngles );
		cheat->SetMember( "GetHitbox", lua_GetHitboxPosition );
		cheat->SetMember( "Msg", lua_Msg );
	gLua->SetGlobal( "cheat", cheat );
	cheat->UnReference();

	if( InMenu() ) 
	{
		Include( "lua_load.lua", true );
		canDetour = true;
		if( DoDetour() )
			HERMES::Msg( "Loaded scriptenforcer bypass\n", Color( 0, 255, 0, 255 ) );
	}
	else
	{
		Include( "lua/base.lua", true );
	}
	return 0;
}

int Shutdown( lua_State* L )
{
	if( css != NULL )
		css->Refresh();
	
	if( hl2 != NULL )
		hl2->Refresh();

	if ( VectorMetaRef )
    {
		gLua->FreeReference( VectorMetaRef );
	}
	return 0;
}