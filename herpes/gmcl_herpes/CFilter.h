/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CFilter.h
Purpose: Filter players (alot less laggy in C++).
------------------------------------------------------------*/
#pragma once

#ifndef ___FILTER_FILE_
#define ___FILTER_FILE_

#include "SDK.h"

namespace HERPES
{
	namespace Filter
	{
		extern int GetAimTarget();
		extern Vector PredictTarget( int idx );
	}
}

#endif