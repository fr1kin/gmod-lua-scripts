/*------------------------------------------------------------
_|    _|  _|_|_|_|  _|_|_|    _|_|_|    _|_|_|_|    _|_|_|  
_|    _|  _|        _|    _|  _|    _|  _|        _|        
_|_|_|_|  _|_|_|    _|_|_|    _|_|_|    _|_|_|      _|_|    
_|    _|  _|        _|    _|  _|        _|              _|  
_|    _|  _|_|_|_|  _|    _|  _|        _|_|_|_|  _|_|_|    

Name: CAutoWall.cpp
Purpose: Shoot through walls.
------------------------------------------------------------*/
#pragma once

#include "SDK.h"

using namespace HERPES;

/*
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

bool CanPenitrate( int iPenetration, float flDamage, Vector vStart, Vector vEnd )
{
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
		VectorMA( vecStart, 10.0, vecDirNormal, vecEnd );
		
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

			flDamage = flDamage * flDamageMulti;

			qPenetration--;
		}
		VectorCopy( vecEnd, vecStart );
	} while( qPenetration != 0 && flDamage > 0.0f );
	
	return false;
}
*/