///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// Planar Reflections Probe for Unity's Built-in Render Pipeline             //
//                                                                           //
// Author: Rafael Bordoni                                                    //
// Date: January 25, 2022                                                    //
// Email: rafaelbordoni00@gmail.com                                          //
// Repository: https://github.com/eldskald/planar-reflections-unity          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

#if !defined(PLANAR_REFLECTIONS_INCLUDED)
#define PLANAR_REFLECTIONS_INCLUDED

// Planar reflections shader sampler. Make sure to include this file in
// all your shaders that need planar reflections. You need to enable one of
// either _PRID_ONE, _PRID_TWO, _PRID_THREE or _PRID_FOUR, and only one of
// these. They represent the texture ID you'll use, so if you set the probe to
// target ID 1, enable _PRID_ONE, if the probe is set to target ID 2, enable
// _PRID_TWO and so forth. You can also notice we're inverting the horizontal
// coordinates, this has to be done in order for the reflections to be aligned,
// think of it like that how in the mirrored world everything is also flipped.
// I would prefer to do it on the C# script but it looks like it's impossible
// on Unity, for all I've dug around the only way to flip a texture is on the
// shader by sampling it with flipped UV coordinates.

#if defined(_PRID_ONE)
    sampler2D _PlanarReflectionsTex1;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.x = 1 - uv.x;
        return tex2D(_PlanarReflectionsTex1, uv);
    }

#elif defined(_PRID_TWO)
    sampler2D _PlanarReflectionsTex2;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.x = 1 - uv.x;
        return tex2D(_PlanarReflectionsTex2, uv);
    }

#elif defined(_PRID_THREE)
    sampler2D _PlanarReflectionsTex3;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.x = 1 - uv.x;
        return tex2D(_PlanarReflectionsTex3, uv);
    }

#elif defined(_PRID_FOUR)
    sampler2D _PlanarReflectionsTex4;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.x = 1 - uv.x;
        return tex2D(_PlanarReflectionsTex4, uv);
    }
#endif

#endif