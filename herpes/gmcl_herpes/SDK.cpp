/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: SDK.cpp
Purpose: Main header, includes additional files/libs.
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

GMOD_MODULE( Init, Shutdown );

// Create Interfaces
CreateInterfaceFn	m_pMaterialFactory;
CreateInterfaceFn	m_pEngineFactory;
CreateInterfaceFn	m_pClientFactory;
CreateInterfaceFn	m_pFileFactory;
CreateInterfaceFn	m_pStudioFactory;
CreateInterfaceFn	m_pPhysicsFactory;
CreateInterfaceFn	m_pVgui;
CreateInterfaceFn	m_pVguiMat;

using namespace HERPES;

void HERPES::GetInterfaces( void )
{
	m_pClientFactory							= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("client.dll"), "CreateInterface" );
	m_pEngineFactory							= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("engine.dll"), "CreateInterface" );
	m_pPhysicsFactory							= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("vphysics.dll"), "CreateInterface" );
	m_pStudioFactory							= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("StudioRender.dll"), "CreateInterface" );
	m_pMaterialFactory							= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("MaterialSystem.dll"), "CreateInterface" );
	m_pVgui										= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("vguimatsurface.dll"), "CreateInterface" );
	m_pVguiMat									= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("vgui2.dll"), "CreateInterface" );
	m_pFileFactory								= ( CreateInterfaceFn )GetProcAddress( GetModuleHandleA("FileSystem_Steam.dll"), "CreateInterface" );
	
	// Hook them
	HERPES::Interfaces::m_pMaterialSystem		= (IMaterialSystem*)			m_pMaterialFactory( "VMaterialSystem080", NULL );
	HERPES::Interfaces::m_pStudioRender			= (IStudioRender*)				m_pStudioFactory( STUDIO_RENDER_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pPhysics				= (IPhysics*)					m_pPhysicsFactory( VPHYSICS_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pPhysicsSurfaceProps	= (IPhysicsSurfaceProps*)		m_pPhysicsFactory( VPHYSICS_SURFACEPROPS_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pSurface				= (vgui::ISurface*)				m_pVgui( VGUI_SURFACE_INTERFACE_VERSION, NULL);
	HERPES::Interfaces::m_pEngine				= (IVEngineClient*)				m_pEngineFactory( VENGINE_CLIENT_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pRandom				= (IUniformRandomStream *)		m_pEngineFactory( VENGINE_SERVER_RANDOM_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pSound				= (IEngineSound *)				m_pEngineFactory( IENGINESOUND_CLIENT_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pGameEventManager		= (IGameEvent *)				m_pEngineFactory( INTERFACEVERSION_GAMEEVENTSMANAGER2, NULL );
	HERPES::Interfaces::m_pModelRender			= (IVModelRender *)				m_pEngineFactory( VENGINE_HUDMODEL_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pRenderView			= (IVRenderView *)				m_pEngineFactory( VENGINE_RENDERVIEW_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pEngineTrace			= (IEngineTrace *)				m_pEngineFactory( INTERFACEVERSION_ENGINETRACE_CLIENT, NULL );
	HERPES::Interfaces::m_pEngineVGui			= (IEngineVGui *)				m_pEngineFactory( VENGINE_VGUI_VERSION, NULL );
	HERPES::Interfaces::m_pEffects				= (IVEfx *)						m_pEngineFactory( VENGINE_EFFECTS_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pModelInfo			= (IVModelInfoClient *)			m_pEngineFactory( "VModelInfoClient005", NULL );
	HERPES::Interfaces::m_pSound				= (IEngineSound *)				m_pEngineFactory( IENGINESOUND_CLIENT_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pDebugOverlay			= (IVDebugOverlay *)			m_pEngineFactory( VDEBUG_OVERLAY_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pClientEntList		= ( IClientEntityList* )		m_pClientFactory( VCLIENTENTITYLIST_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pClientInterfaces		= (IClientDLLSharedAppSystems*)	m_pClientFactory( CLIENT_DLL_SHARED_APPSYSTEMS, NULL );
	HERPES::Interfaces::m_pPrediction			= (IPrediction*)				m_pClientFactory( VCLIENT_PREDICTION_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pClient				= (IBaseClientDLL*)				m_pClientFactory( "VClient16", NULL );
	HERPES::Interfaces::m_pPanel				= (vgui::IPanel*)				m_pVguiMat( VGUI_PANEL_INTERFACE_VERSION, NULL );
	HERPES::Interfaces::m_pFileSystem			= (IFileSystem*)				m_pFileFactory( "VFileSystem019", NULL );
	
	HERPES::Interfaces::m_pCVar					= *(ICvar **)GetProcAddress(GetModuleHandleA("client.dll"), "cvar");

	//HERPES::Interfaces::m_pGlobals = **(CGlobalVarsBase***)( ( *( PDWORD* )HERPES::Interfaces::m_pClient )[ 11 ] + 0x2 );
	//ASSERT( HERPES::Interfaces::m_pGlobals );
}

// fuak
LUA_FUNCTION( lua_AntiAim )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_USERCMD );

	CUserCmd* cmd = (CUserCmd*)Interfaces::Lua->GetUserData( 1 );
	Extras::AntiAim( cmd );

	return 0;
}

LUA_FUNCTION( lua_PredictTarget )
{
	Interfaces::Lua->CheckType( 2, GLua::TYPE_VECTOR );

	Vector Org = *(Vector*)Interfaces::Lua->GetUserData( 2 );

	Extras::PredictOrigin( Org );

	ILuaObject* vectorLibrary = Interfaces::Lua->GetGlobal( "Vector" );
	Interfaces::Lua->Push( vectorLibrary );
	Interfaces::Lua->Push( Org.x );
	Interfaces::Lua->Push( Org.y );
	Interfaces::Lua->Push( Org.z );
	Interfaces::Lua->Call( 3, 1 );

	ILuaObject* ret = Interfaces::Lua->GetReturn(0);
	if ( ret )
		Interfaces::Lua->Push(ret);
	else
		Interfaces::Lua->PushNil();

    return 1;
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

LUA_FUNCTION( lua_ForceInternalVar )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_STRING );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_NUMBER );

	const char* czCvar	= Interfaces::Lua->GetString( 1 );
	float flValue		= Interfaces::Lua->GetInteger( 2 );

	ConVar *pConVar		= Interfaces::m_pCVar->FindVar( czCvar );

	if( pConVar )
	{
		pConVar->m_nValue = (int)flValue;
		pConVar->m_fValue = flValue;
	}

	return 0;
}

LUA_FUNCTION( lua_SetFlags )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_STRING );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_NUMBER );

	const char* czCvar	= Interfaces::Lua->GetString( 1 );
	int iFlags			= Interfaces::Lua->GetInteger( 2 );

	ConVar *pConVar		= Interfaces::m_pCVar->FindVar( czCvar );

	if( pConVar )
	{
		pConVar->m_nFlags = iFlags;
	}

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

LUA_FUNCTION( lua_ReplicateVar )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_STRING );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_STRING );
	Interfaces::Lua->CheckType( 3, GLua::TYPE_NUMBER );
	Interfaces::Lua->CheckType( 4, GLua::TYPE_STRING );

	const char* convar				=	Interfaces::Lua->GetString(1);
	const char* n_convar			=	Interfaces::Lua->GetString(2);
	int			flags				=	Interfaces::Lua->GetInteger(3);
	const char* value				=	Interfaces::Lua->GetString(4);

	HERPES::Replicator::ReplicateVar( convar, n_convar, value, flags );
	return 0;
}

LUA_FUNCTION( lua_SetTick )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_USERCMD );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_NUMBER );

	CUserCmd *cmd = ( CUserCmd * )( Interfaces::Lua->GetUserData( 1 ) );
	int number = Interfaces::Lua->GetNumber( 2 );

	int TC = cmd->tick_count;
	cmd->tick_count = number;

	Interfaces::Lua->PushValue( TC );
	return 1;
}

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

LUA_FUNCTION( lua_VectorMA )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_VECTOR );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_NUMBER );
	Interfaces::Lua->CheckType( 3, GLua::TYPE_VECTOR );

	Vector start = *(Vector*)Interfaces::Lua->GetUserData( 1 );
	float scale = Interfaces::Lua->GetNumber( 2 );
	Vector dir = *(Vector*)Interfaces::Lua->GetUserData( 3 );

	Vector out( 0, 0, 0 );

	VectorMA( start, scale, dir, out );

	ILuaObject* vectorLibrary = Interfaces::Lua->GetGlobal( "Vector" );
	Interfaces::Lua->Push( vectorLibrary );
	Interfaces::Lua->Push( out.x );
	Interfaces::Lua->Push( out.y );
	Interfaces::Lua->Push( out.z );
	Interfaces::Lua->Call( 3, 1 );

	ILuaObject* ret = Interfaces::Lua->GetReturn(0);
	if ( ret )
		Interfaces::Lua->Push(ret);
	else
		Interfaces::Lua->PushNil();

	return 1;
}

LUA_FUNCTION( lua_VectorLength )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_VECTOR );

	Vector in = *(Vector*)Interfaces::Lua->GetUserData( 1 );

	float out = 0.0f;

	out = VectorLength( in );

	Interfaces::Lua->Push( out );

	return 1;
}

LUA_FUNCTION( lua_VectorDivide )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_VECTOR );
	Interfaces::Lua->CheckType( 2, GLua::TYPE_NUMBER );

	Vector dir = *(Vector*)Interfaces::Lua->GetUserData( 1 );
	float length = Interfaces::Lua->GetNumber( 2 );
	
	Vector out( 0, 0, 0 );

	VectorDivide( dir, length, out );

	ILuaObject* vectorLibrary = Interfaces::Lua->GetGlobal( "Vector" );
	Interfaces::Lua->Push( vectorLibrary );
	Interfaces::Lua->Push( out.x );
	Interfaces::Lua->Push( out.y );
	Interfaces::Lua->Push( out.z );
	Interfaces::Lua->Call( 3, 1 );

	ILuaObject* ret = Interfaces::Lua->GetReturn(0);
	if ( ret )
		Interfaces::Lua->Push(ret);
	else
		Interfaces::Lua->PushNil();

	return 1;
}

float GetDamageModifier( int iMaterial )
{
        float flDamageModifier = 0.5f;
 
        switch( iMaterial )
        {
                case CHAR_TEX_CONCRETE:
                {
                        flDamageModifier = 0.3f;
                        break;
                }
                case CHAR_TEX_PLASTIC:
                {
                        flDamageModifier = 0.8f;
                        break;
                }
                case CHAR_TEX_GLASS:
                {
                        flDamageModifier = 0.8f;
                        break;
                }
                case CHAR_TEX_FLESH:
                {
                        flDamageModifier = 0.9f;
                        break;
                }
                case CHAR_TEX_WOOD:
                {
                        flDamageModifier = 0.8f;
                        break;
                }
				case CHAR_TEX_ALIENFLESH:
                {
                        flDamageModifier = 0.9f;
                        break;
                }
				case CHAR_TEX_METAL:
                {
                        flDamageModifier = 0.0f;
                        break;
                }
				case CHAR_TEX_SAND:
                {
                        flDamageModifier = 0.0f;
                        break;
                }
                default:
                {
                        flDamageModifier = 0.5f;
                        break;
                }
        }
       
        return flDamageModifier;
}

bool CanPenitrate( int iPenetration, float flDamage, Vector vStart, Vector vEnd, ILuaObject *dmgMulti )
{
	if( !dmgMulti )
		return false;

	Vector vecStart, vecEnd, vecDir, vecLeng, vecDirNormal;
	float flLength, flTemp, flDamageMulti;

	VectorCopy( vStart, vecStart );
	VectorCopy( vEnd, vecEnd );

	VectorSubtract( vEnd, vStart, vecDir );
	flLength = VectorLength( vecDir );

	if( flLength <= 0 )
		return false;

	VectorDivide( vecDir, flLength, vecDirNormal );

	trace_t tr;
	Ray_t ray;

	int qPenetration = iPenetration;
	
	do
	{
		VectorMA( vecStart, 8.0, vecDirNormal, vecEnd );
		
		ray.Init( vecStart, vecEnd );
		Interfaces::m_pEngineTrace->TraceRay( ray, MASK_SHOT, NULL, &tr );

		if( tr.fraction != 1.0f )
		{
			vecLeng = vecEnd - vStart;
			flTemp = VectorLength( vecLeng );
			
			if( flTemp >= flLength )
			{
				if( flDamage > 1 )
					return true;
			}
			
			surfacedata_t *pSurface = Interfaces::m_pPhysicsSurfaceProps->GetSurfaceData( tr.surface.surfaceProps );
			flDamageMulti = GetDamageModifier( static_cast< int >( pSurface->game.material ) );

			flDamage *=  flDamageMulti;
			qPenetration--;
		}
		VectorCopy( vecEnd, vecStart );
	} while( qPenetration != 0 && flDamage > 0.0f );
	
	return false;
}

LUA_FUNCTION( lua_CanPenitrate )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_NUMBER ); // Penetration
	Interfaces::Lua->CheckType( 2, GLua::TYPE_VECTOR ); // Start
	Interfaces::Lua->CheckType( 3, GLua::TYPE_VECTOR ); // End
	Interfaces::Lua->CheckType( 4, GLua::TYPE_NUMBER ); // Damage
	Interfaces::Lua->CheckType( 5, GLua::TYPE_TABLE );  // Damage Multiplyer

	float iPenetration		= (float)Interfaces::Lua->GetNumber( 1 );
	float flDamage			= (float)Interfaces::Lua->GetNumber( 4 );

	Vector &vStart			= *(Vector*)Interfaces::Lua->GetUserData( 2 );
	Vector &vEnd			= *(Vector*)Interfaces::Lua->GetUserData( 3 );
	
	ILuaObject *dmgMulti	= Interfaces::Lua->GetObject( 5 );

	Interfaces::Lua->Push( CanPenitrate( iPenetration, flDamage, vStart, vEnd, dmgMulti ) );
	dmgMulti->UnReference();

	return 1;
}

LUA_FUNCTION( lua_RandomSeed )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_USERCMD );

	CUserCmd *cmd = ( CUserCmd * )( Interfaces::Lua->GetUserData( 1 ) );

	int iPush = cmd->random_seed;
	Msg( "%i", iPush );
	Interfaces::Lua->PushValue( (int)iPush );

	return 1;
}

LUA_FUNCTION( lua_EyeAngles )
{
	Interfaces::Lua->CheckType( 1, GLua::TYPE_USERCMD );

	CUserCmd *cmd = ( CUserCmd * )( Interfaces::Lua->GetUserData( 1 ) );

	int iPush = cmd->random_seed;
	Msg( "%i", iPush );
	Interfaces::Lua->PushValue( (int)iPush );

	return 1;
}

// Install
int Init( lua_State* L )
{
	HERPES::Interfaces::Lua = Lua();

	HERPES::DebugMessage( "Loading Module..." );

	ConVar_Register( 0 );
	HERPES::GetInterfaces();

	ILuaObject* herpes = HERPES::Interfaces::Lua->GetNewTable();
		herpes->SetMember( "ForceVar", lua_ForceVar );
		herpes->SetMember( "ForceInternalVar", lua_ForceInternalVar );
		herpes->SetMember( "SetFlags", lua_SetFlags );
		herpes->SetMember( "SetTick", lua_SetTick );
		herpes->SetMember( "RandomSeed", lua_RandomSeed );
		herpes->SetMember( "RunCommand", lua_RunCommand );
		herpes->SetMember( "IsDormant", lua_IsDormant );
		herpes->SetMember( "ReplicateVar", lua_ReplicateVar );
		herpes->SetMember( "Nospread", lua_Nospread );
		herpes->SetMember( "VectorMA", lua_VectorMA );
		herpes->SetMember( "VectorLength", lua_VectorLength );
		herpes->SetMember( "VectorDivide", lua_VectorDivide );
		herpes->SetMember( "CanPenitrate", lua_CanPenitrate );
		herpes->SetMember( "AntiAim", lua_AntiAim );
		herpes->SetMember( "PredictTarget", lua_PredictTarget );
	HERPES::Interfaces::Lua->SetGlobal( "_lua", herpes );
	herpes->UnReference();

	ILuaObject *maxply = HERPES::Interfaces::Lua->GetGlobal( "MaxPlayers" );
	if( maxply->isNil() )
	{
		HERPES::DebugMessage( "Detouring ScriptEnforcer..." );
		HERPES::ScriptEnforcer::DETOUR();
	}

	return 0;
}

// Shutdown
int Shutdown( lua_State* L )
{
	return 0;
}