//=========== Copyright © 1990-2010, HL-SDK, All rights reserved. ===========//
//
// Purpose: Factory list class definition
//
// $NoKeywords: $
//
//===========================================================================//

#pragma once
#include <interface.h>

class CFactoryList
{
public:
	CFactoryList(void);
	~CFactoryList(void);
	
	CreateInterfaceFn EngineFactory;
	CreateInterfaceFn ClientFactory;
	CreateInterfaceFn VGUIFactory;
	CreateInterfaceFn VGUI2Factory;
	CreateInterfaceFn MaterialFactory;
	CreateInterfaceFn StudioFactory;
};
