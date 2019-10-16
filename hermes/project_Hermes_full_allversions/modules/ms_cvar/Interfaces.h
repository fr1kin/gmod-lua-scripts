//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Interface list class definition
//
// $NoKeywords: $
//
//===========================================================================//

#pragma once
#include <tier3/tier3.h>
#include <cdll_int.h>
#include <icliententitylist.h>
#include <iprediction.h>
#include "FactoryList.h"

class CInterfaces
{
public:
	CInterfaces( CFactoryList* pFactoryList );
	~CInterfaces(void);

	//---From tier1
	ICvar* 						m_pCvar;

	//---From tier2
	IFileSystem* 				m_pFullFileSystem;
	IMaterialSystem* 			m_pMaterialSystem;
	//IInputSystem* 				m_pInputSystem;
	//INetworkSystem* 			m_pNetworkSystem;
	//IDebugTextureInfo* 			m_pMaterialSystemDebugTextureInfo;
	//IVBAllocTracker* 			m_VBAllocTracker;
	//IColorCorrectionSystem* 	m_pColorCorrection;
	//IP4* 						m_pP4;
	//IMdlLib* 					m_pMdllib;
	//IQueuedLoader* 				m_pQueuedLoader;
	//IMaterialSystemHardwareConfig* m_pMaterialSystemHardwareConfig;

	//---From tier3
	IStudioRender* 				m_pStudiorender;
	//IMatSystemSurface* 			m_pMatSystemSurface;
	vgui::ISurface* 			m_pVGuiSurface;
	vgui::IPanel* 				m_pVGuiPanel;
	//ISoundEmitterSystemBase* 	m_pSoundEmitterSystem;
	//vgui::IInput* 				m_pVGuiInput;
	//vgui::IVGui* 				m_pVGui;
	//vgui::ILocalize* 			m_pVGuiLocalize;
	//vgui::ISchemeManager* 		m_pVGuiSchemeManager;
	//vgui::ISystem* 				m_pVGuiSystem;
	//IDataCache* 				m_pDataCache;
	//IMDLCache* 					m_pMDLCache;
	//IAvi* 						m_pAVI;
	//IBik* 						m_pBIK;
	//IDmeMakefileUtils* 			m_pDmeMakefileUtils;
	//IPhysicsCollision* 			m_pPhysicsCollision;

	//---Misc
	IVEngineClient*				m_pEngineClient;
	IPrediction*				m_pPrediction;
	IBaseClientDLL*				m_pClient;
	IClientEntityList* 			m_pClientEntList;
};

