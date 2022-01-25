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
// _PRID_TWO and so forth. You can also notice we're inverting the vertical
// coordinates, this has to be done in order for the reflections to be aligned
// with what's being reflected, try removing these lines and see what happens.
// Ideally, I would like to do this on the probe script but Unity doesn't let
// us, we can't flip the render texture or the camera, we could rotate the
// camera upside down but that isn't the same as flipping it vertically, we
// would need to flip the texture horizontally if we turned the camera upside
// down. In the end, I tried the simplest math I could do on the probe C# code
// and flipped whatever direction needed to be flipped here.

#if defined(_PRID_ONE)
    sampler2D _PlanarReflectionsTex1;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.y = 1 - uv.y;
        return tex2D(_PlanarReflectionsTex1, uv);
    }

#elif defined(_PRID_TWO)
    sampler2D _PlanarReflectionsTex2;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.y = 1 - uv.y;
        return tex2D(_PlanarReflectionsTex2, uv);
    }

#elif defined(_PRID_THREE)
    sampler2D _PlanarReflectionsTex3;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.y = 1 - uv.y;
        return tex2D(_PlanarReflectionsTex3, uv);
    }

#elif defined(_PRID_FOUR)
    sampler2D _PlanarReflectionsTex4;
    fixed4 SamplePlanarReflections (float4 screenUV) {
        float2 uv = screenUV.xy / screenUV.w;
        uv.y = 1 - uv.y;
        return tex2D(_PlanarReflectionsTex4, uv);
    }
#endif

#endif