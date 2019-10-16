//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Interface list class implementation
//
// $NoKeywords: $
//
//===========================================================================//

#include "Interfaces.h"
#include <filesystem.h>
#include <materialsystem/imaterialsystem.h>
#include <VGuiMatSurface/IMatSystemSurface.h>
#include <inputsystem/iinputsystem.h>
#include <istudiorender.h>
#include <vgui/IPanel.h>
#include <vgui/ISurface.h>
#include <SoundEmitterSystem/isoundemittersystembase.h>


CInterfaces::CInterfaces( CFactoryList* pFactoryList )
{
	//m_pCvar 						= (ICvar*)pFactoryList->EngineFactory(CVAR_INTERFACE_VERSION, NULL);
	//Assert(m_pCvar);

	//m_pFullFileSystem 				= (IFileSystem*)pFactoryList->EngineFactory(FILESYSTEM_INTERFACE_VERSION, NULL);
	//Assert(m_pFullFileSystem);

	m_pMaterialSystem 				= (IMaterialSystem*)pFactoryList->MaterialFactory(MATERIAL_SYSTEM_INTERFACE_VERSION, NULL);
	Assert(m_pMaterialSystem);

	//m_pInputSystem 					= (IInputSystem*)enginefactory(INPUTSYSTEM_INTERFACE_VERSION, NULL);
	//Assert(m_pInputSystem);

	//--------------------------------------------------------------

	m_pStudiorender					= (IStudioRender*)pFactoryList->StudioFactory(STUDIO_RENDER_INTERFACE_VERSION, NULL);
	Assert(m_pStudiorender);

	m_pVGuiSurface					= (vgui::ISurface*)pFactoryList->VGUI2Factory(VGUI_SURFACE_INTERFACE_VERSION, NULL);
	Assert(m_pVGuiSurface);

	//m_pMatSystemSurface 			= (IMatSystemSurface*)m_pVGuiSurface->QueryInterface(MAT_SYSTEM_SURFACE_INTERFACE_VERSION);
	//Assert(m_pMatSystemSurface);
	
	m_pVGuiPanel 					= (vgui::IPanel*)pFactoryList->VGUI2Factory(VGUI_PANEL_INTERFACE_VERSION, NULL);
	Assert(m_pVGuiPanel);

	//m_pSoundEmitterSystem 			= (ISoundEmitterSystemBase*)pFactoryList->ClientFactory(SOUNDEMITTERSYSTEM_INTERFACE_VERSION, NULL);
	//Assert(m_pSoundEmitterSystem);
	
	//--------------------------------------------------------------

	m_pEngineClient 						= (IVEngineClient*)pFactoryList->EngineFactory(VENGINE_CLIENT_INTERFACE_VERSION, NULL);
	Assert(m_pEngineClient);

	m_pPrediction 							= (IPrediction*)pFactoryList->ClientFactory(VCLIENT_PREDICTION_INTERFACE_VERSION, NULL);
	Assert(m_pPrediction);

	m_pClient 								= (IBaseClientDLL*)pFactoryList->ClientFactory(CLIENT_DLL_INTERFACE_VERSION, NULL);
	Assert(m_pClient);

	m_pClientEntList 						= (IClientEntityList*)pFactoryList->ClientFactory(VCLIENTENTITYLIST_INTERFACE_VERSION, NULL);
	Assert(m_pClientEntList);
}


CInterfaces::~CInterfaces(void)
{
}
