/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: Interfaces.cpp
Purpose: All headers/libs/definitions required for the project.
------------------------------------------------------------*/

#include "SDK.h"

IMaterialSystem				*HERPES::Interfaces::m_pMaterialSystem;
IClientEntityList			*HERPES::Interfaces::m_pClientEntList;
IVEngineClient				*HERPES::Interfaces::m_pEngine;
IFileSystem					*HERPES::Interfaces::m_pFileSystem;
ICvar						*HERPES::Interfaces::m_pCVar;
IBaseClientDLL				*HERPES::Interfaces::m_pClient;
IClientDLLSharedAppSystems	*HERPES::Interfaces::m_pClientInterfaces;
IPrediction					*HERPES::Interfaces::m_pPrediction;
IEngineSound				*HERPES::Interfaces::m_pSound;
IGameEvent					*HERPES::Interfaces::m_pGameEventManager;
IVModelRender				*HERPES::Interfaces::m_pModelRender;
IVRenderView				*HERPES::Interfaces::m_pRenderView;
IEngineTrace				*HERPES::Interfaces::m_pEngineTrace;
IEngineVGui					*HERPES::Interfaces::m_pEngineVGui;
IVEfx						*HERPES::Interfaces::m_pEffects;
IVModelInfoClient			*HERPES::Interfaces::m_pModelInfo;
IVDebugOverlay				*HERPES::Interfaces::m_pDebugOverlay;
IStudioRender				*HERPES::Interfaces::m_pStudioRender;
IPhysics					*HERPES::Interfaces::m_pPhysics;
IPhysicsSurfaceProps		*HERPES::Interfaces::m_pPhysicsSurfaceProps;
vgui::ISurface				*HERPES::Interfaces::m_pSurface;
vgui::IPanel				*HERPES::Interfaces::m_pPanel;
IUniformRandomStream		*HERPES::Interfaces::m_pRandom;
CGlobalVarsBase				*HERPES::Interfaces::m_pGlobals;
IClientMode					*HERPES::Interfaces::m_pClientMode;
CInput						*HERPES::Interfaces::m_pInput;
ILuaInterface				*HERPES::Interfaces::Lua;

INetChannelInfo *HERPES::Interfaces::m_pNet()
{
	INetChannelInfo* pNet = NULL;
    
	DWORD* pdwEngineVMT = ( DWORD* )*( DWORD* )HERPES::Interfaces::m_pEngine;
	DWORD dwNetChannel = pdwEngineVMT[72];
    
	__asm
	{
		PUSHAD;
		CALL dwNetChannel;
		MOV pNet, EAX;
		POPAD;
	}
	
	return pNet;
}

void HERPES::DebugMessage( std::string msg, ... )
{
	std::string message = "[HERPES]: ";
	message.append( msg );

	OutputDebugStringA( message.c_str() );
}