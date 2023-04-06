Shader "Custom/Water" {

    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _FoamColor ("Foam Color", Color) = (1,1,1,1)

        [Header(Foam)]
        _FoamSize ("Foam Size", Range(0, 1)) = 0.4
        _FoamDisplacement ("Foam Displacement", Range(0, 1)) = 0.6
        _FoamNoiseTex ("Noise Texture", 2D) = "black" {}

        [Header(Reflections)]
        _Reflectivity ("Reflectivity", Range(0, 1)) = 0.5
        _FresnelPower ("Fresnel Power", Range(1, 5)) = 5
        [KeywordEnum(One, Two, Three, Four)]
            _PRID ("Planar Refl. ID", Float) = 0

    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 200

        CGPROGRAM
    
        #pragma surface surf Standard fullforwardshadows alpha:premul
        #pragma target 3.0

        // To enable planar reflections, enable _PRID_ONE, if the probe's
        // targeting ID 1, _PRID_TWO if it's targeting ID 2 and so on. I'm
        // using a multicompile with a KeywordEnum to make it flexible.
        #pragma multi_compile _PRID_ONE _PRID_TWO _PRID_THREE _PRID_FOUR
        #include "PlanarReflections.cginc"

        struct Input {
            float2 uv_FoamNoiseTex;
            float4 screenPos;
            float3 viewDir;
        };

        fixed4 _Color;
        fixed4 _FoamColor;
        half _FoamSize;
        half _FoamDisplacement;
        sampler2D _FoamNoiseTex;
        half _Reflectivity;
        half _FresnelPower;

        sampler2D _CameraDepthTexture;
        float4 _CameraDepthTexture_TexelSize;

        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o) {

            // We're not using these for still waters.
            o.Metallic = 0;
            o.Smoothness = 0;
            o.Normal = float3(0, 0, 1);

            // Sample depth to detect intersections and apply foam.
            float zDepth = LinearEyeDepth(tex2Dproj(
            _CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos)));
            float zPos = IN.screenPos.w;
            float zDiff = zDepth - zPos;

            // Sample noise to add to the depth and animated foam.
            float2 noisePan = _Time.y * 0.05;
            half noise = tex2D(_FoamNoiseTex, IN.uv_FoamNoiseTex + noisePan).x;
            noise += tex2D(_FoamNoiseTex, IN.uv_FoamNoiseTex - noisePan).x;
            half foamDispl = (noise - 1) * _FoamDisplacement;

            // foam = 1 if there is foam, foam = 0 otherwise.
            half foam = zDiff < 0 ? 1 : (zDiff + foamDispl) * 2;
            foam = 1 - step(_FoamSize, foam);

            // Let's calculate reflectivity based on foam and Fresnel.
            half refl = _Reflectivity;
            half cos = saturate(dot(o.Normal, normalize(IN.viewDir)));
            refl += (1 - _Reflectivity) * pow(1 - cos, _FresnelPower);

            // Paint the pixel according to the foam read.
            o.Albedo = lerp(_Color.rgb * (1 - refl), _FoamColor.rgb, foam);
            o.Alpha = lerp(_Color.a, _FoamColor.a, foam);

            // Sample the planar reflections and paint the pixel with it.
            o.Emission = SamplePlanarReflections(IN.screenPos) * refl;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
