/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: Interfaces.h
Purpose: All headers/libs/definitions required for the project.
------------------------------------------------------------*/
#pragma once

#ifndef _INCLUDE_FILE_
#define _INCLUDE_FILE_

#include "SDK.h"

// Interfaces
namespace HERPES
{
	extern void GetInterfaces( void );
	extern void DebugMessage( std::string msg, ... );
	
	class Interfaces
	{
	public:
		static IMaterialSystem				*m_pMaterialSystem;
		static IClientEntityList			*m_pClientEntList;
		static IVEngineClient				*m_pEngine;
		static IFileSystem					*m_pFileSystem;
		static ICvar						*m_pCVar;
		static IBaseClientDLL				*m_pClient;
		static IClientDLLSharedAppSystems	*m_pClientInterfaces;
		static IPrediction					*m_pPrediction;
		static IEngineSound					*m_pSound;
		static IGameEvent					*m_pGameEventManager;
		static IVModelRender				*m_pModelRender;
		static IVRenderView					*m_pRenderView;
		static IEngineTrace					*m_pEngineTrace;
		static IEngineVGui					*m_pEngineVGui;
		static IVEfx						*m_pEffects;
		static IVModelInfoClient			*m_pModelInfo;
		static IVDebugOverlay				*m_pDebugOverlay;
		static IStudioRender				*m_pStudioRender;
		static IPhysics						*m_pPhysics;
		static IPhysicsSurfaceProps			*m_pPhysicsSurfaceProps;
		static vgui::ISurface				*m_pSurface;
		static vgui::IPanel					*m_pPanel;
		static IUniformRandomStream			*m_pRandom;
		static CGlobalVarsBase				*m_pGlobals;
		static IClientMode					*m_pClientMode;
		static CInput						*m_pInput;
		static INetChannelInfo				*m_pNet();
		static ILuaInterface				*Lua;
	};
}

#endif