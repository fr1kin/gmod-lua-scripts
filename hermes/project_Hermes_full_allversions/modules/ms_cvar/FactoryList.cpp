//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Factory list class implementation
//
// Notes: Not using Sys_GetFactory for no good reason... was having trouble
// 		  getting a few pointers.
//
// $NoKeywords: $
//
//===========================================================================//

#include "FactoryList.h"
#include <dbg.h>
#include <windows.h>

CFactoryList::CFactoryList(void)
{
	EngineFactory = Sys_GetFactory("engine.dll");
	Assert(EngineFactory);

	ClientFactory = Sys_GetFactory("client.dll");
	Assert(ClientFactory);

	VGUIFactory = Sys_GetFactory("vguimatsurface.dll");
	Assert(VGUIFactory);

	VGUI2Factory = Sys_GetFactory("vgui2.dll");
	Assert(VGUI2Factory);

	MaterialFactory = Sys_GetFactory("materialsystem.dll");
	Assert(MaterialFactory);

	StudioFactory = Sys_GetFactory("studiorender.dll");
	Assert(StudioFactory);
	/*
	EngineFactory = (CreateInterfaceFn)GetProcAddress(GetModuleHandleA("engine.dll"), "CreateInterface");
	Assert(EngineFactory);

	ClientFactory = (CreateInterfaceFn)GetProcAddress(GetModuleHandleA("client.dll"), "CreateInterface");
	Assert(ClientFactory);

	VGUIFactory = (CreateInterfaceFn)GetProcAddress(GetModuleHandleA("vguimatsurface.dll"), "CreateInterface");
	Assert(VGUIFactory);

	VGUI2Factory = (CreateInterfaceFn)GetProcAddress(GetModuleHandleA("vgui2.dll"), "CreateInterface");
	Assert(VGUI2Factory);
	
	MaterialFactory = (CreateInterfaceFn)GetProcAddress(GetModuleHandleA("materialsystem.dll"), "CreateInterface");
	Assert(MaterialFactory);

	StudioFactory = (CreateInterfaceFn)GetProcAddress(GetModuleHandleA("studiorender.dll"), "CreateInterface");
	Assert(StudioFactory);
	*/
	if (!EngineFactory || !ClientFactory || !VGUIFactory || !VGUIFactory || !MaterialFactory)
	{
		Warning("[MS] Missing factories!\n");
	}	
	
}


CFactoryList::~CFactoryList(void)
{
}
