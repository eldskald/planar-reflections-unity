// Made with Amplify Shader Editor v1.9.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PlanarGround"
{
	Properties
	{
		[HDR]_AlbedoColor("AlbedoColor", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		[Normal]_Normal("Normal", 2D) = "white" {}
		_Metallicness("Metallicness", Range( 0 , 1)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_NormalScale("NormalScale", Range( 0 , 1)) = 1
		[KeywordEnum(One,Two,Three,Four)] _PRID("_PRID", Float) = 1
		_ReflectionIntensity("ReflectionIntensity", Range( 0 , 1)) = 0
		_ReflectionMask("ReflectionMask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma multi_compile _PRID_ONE _PRID_TWO _PRID_THREE _PRID_FOUR
		#include "PlanarReflections.cginc"
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _Normal;
		uniform half4 _Normal_ST;
		uniform half _NormalScale;
		uniform sampler2D _Albedo;
		uniform half4 _Albedo_ST;
		uniform half4 _AlbedoColor;
		uniform half _ReflectionIntensity;
		uniform sampler2D _ReflectionMask;
		uniform float4 _ReflectionMask_ST;
		uniform half _Metallicness;
		uniform half _Smoothness;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline half4 MyCustomExpression11( half4 In0 )
		{
			return SamplePlanarReflections(In0);
		}


		void StochasticTiling( float2 UV, out float2 UV1, out float2 UV2, out float2 UV3, out float W1, out float W2, out float W3 )
		{
			float2 vertex1, vertex2, vertex3;
			// Scaling of the input
			float2 uv = UV * 3.464; // 2 * sqrt (3)
			// Skew input space into simplex triangle grid
			const float2x2 gridToSkewedGrid = float2x2( 1.0, 0.0, -0.57735027, 1.15470054 );
			float2 skewedCoord = mul( gridToSkewedGrid, uv );
			// Compute local triangle vertex IDs and local barycentric coordinates
			int2 baseId = int2( floor( skewedCoord ) );
			float3 temp = float3( frac( skewedCoord ), 0 );
			temp.z = 1.0 - temp.x - temp.y;
			if ( temp.z > 0.0 )
			{
				W1 = temp.z;
				W2 = temp.y;
				W3 = temp.x;
				vertex1 = baseId;
				vertex2 = baseId + int2( 0, 1 );
				vertex3 = baseId + int2( 1, 0 );
			}
			else
			{
				W1 = -temp.z;
				W2 = 1.0 - temp.y;
				W3 = 1.0 - temp.x;
				vertex1 = baseId + int2( 1, 1 );
				vertex2 = baseId + int2( 1, 0 );
				vertex3 = baseId + int2( 0, 1 );
			}
			UV1 = UV + frac( sin( mul( float2x2( 127.1, 311.7, 269.5, 183.3 ), vertex1 ) ) * 43758.5453 );
			UV2 = UV + frac( sin( mul( float2x2( 127.1, 311.7, 269.5, 183.3 ), vertex2 ) ) * 43758.5453 );
			UV3 = UV + frac( sin( mul( float2x2( 127.1, 311.7, 269.5, 183.3 ), vertex3 ) ) * 43758.5453 );
			return;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			half3 tex2DNode3 = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale );
			o.Normal = tex2DNode3;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			o.Albedo = ( tex2D( _Albedo, uv_Albedo ) * _AlbedoColor ).rgb;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			half4 In011 = ( ase_grabScreenPos + half4( tex2DNode3 , 0.0 ) );
			half4 localMyCustomExpression11 = MyCustomExpression11( In011 );
			half localStochasticTiling2_g1 = ( 0.0 );
			float2 uv_ReflectionMask = i.uv_texcoord * _ReflectionMask_ST.xy + _ReflectionMask_ST.zw;
			half2 Input_UV145_g1 = uv_ReflectionMask;
			half2 UV2_g1 = Input_UV145_g1;
			half2 UV12_g1 = float2( 0,0 );
			half2 UV22_g1 = float2( 0,0 );
			half2 UV32_g1 = float2( 0,0 );
			half W12_g1 = 0.0;
			half W22_g1 = 0.0;
			half W32_g1 = 0.0;
			StochasticTiling( UV2_g1 , UV12_g1 , UV22_g1 , UV32_g1 , W12_g1 , W22_g1 , W32_g1 );
			half2 temp_output_10_0_g1 = ddx( Input_UV145_g1 );
			half2 temp_output_12_0_g1 = ddy( Input_UV145_g1 );
			half4 Output_2D293_g1 = ( ( tex2D( _ReflectionMask, UV12_g1, temp_output_10_0_g1, temp_output_12_0_g1 ) * W12_g1 ) + ( tex2D( _ReflectionMask, UV22_g1, temp_output_10_0_g1, temp_output_12_0_g1 ) * W22_g1 ) + ( tex2D( _ReflectionMask, UV32_g1, temp_output_10_0_g1, temp_output_12_0_g1 ) * W32_g1 ) );
			half4 temp_output_27_0 = Output_2D293_g1;
			o.Emission = ( localMyCustomExpression11 * _ReflectionIntensity * temp_output_27_0 ).xyz;
			o.Metallic = ( temp_output_27_0 * _Metallicness ).r;
			o.Smoothness = ( _Smoothness * temp_output_27_0 ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19100
Node;AmplifyShaderEditor.TexturePropertyNode;1;-743,-276.5;Inherit;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;0;False;0;False;None;33229150f0164ba4bb0c1b1733e9646a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;5;-447,-9.5;Inherit;False;Property;_Metallicness;Metallicness;3;0;Create;True;0;0;0;False;0;False;0.5;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-743,477.5;Inherit;False;Property;_NormalScale;NormalScale;5;0;Create;True;0;0;0;False;0;False;1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-857,220.5;Inherit;True;Property;_Normal;Normal;2;1;[Normal];Create;True;0;0;0;False;0;False;None;5c35e42a3810f7f4aba27e6d2d6ee241;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.StaticSwitch;9;-792,-492.5;Inherit;False;Property;_PRID;_PRID;6;0;Create;True;0;0;0;True;0;False;1;1;0;True;_PRID_ONE;KeywordEnum;4;One;Two;Three;Four;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-524,226.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-191.6643,-316.1321;Inherit;False;Property;_ReflectionIntensity;ReflectionIntensity;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;120.3357,-481.1321;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;12;-616.6643,-772.1321;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;21;-621.334,-581.645;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-369.334,-525.645;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-1149.334,-58.64502;Inherit;True;Property;_ReflectionMask;ReflectionMask;8;0;Create;True;0;0;0;False;0;False;None;428a5f0f3bba4444c814fba1d0363cf7;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;4;-389,-212.5;Inherit;True;Property;_TextureSample1;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;11;-174.6643,-565.1321;Inherit;False;SamplePlanarReflections(In0);4;Create;1;True;In0;FLOAT4;1,0,0,0;In;;Half;False;My Custom Expression;True;False;0;;False;1;0;FLOAT4;1,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-478,106.5;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;305,0;Half;False;True;-1;2;ASEMaterialInspector;0;0;Standard;PlanarGround;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;1;Include;PlanarReflections.cginc;False;;Custom;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;34.66602,138.355;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;39.66602,-6.64502;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;27;-809.334,-52.64502;Inherit;False;Procedural Sample;-1;;1;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;126.666,-123.645;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;30;-138.334,-69.64502;Inherit;False;Property;_AlbedoColor;AlbedoColor;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;3;0;2;0
WireConnection;3;5;7;0
WireConnection;3;7;2;1
WireConnection;13;0;11;0
WireConnection;13;1;14;0
WireConnection;13;2;27;0
WireConnection;22;0;21;0
WireConnection;22;1;3;0
WireConnection;4;0;1;0
WireConnection;4;7;1;1
WireConnection;11;0;22;0
WireConnection;0;0;29;0
WireConnection;0;1;3;0
WireConnection;0;2;13;0
WireConnection;0;3;28;0
WireConnection;0;4;26;0
WireConnection;26;0;6;0
WireConnection;26;1;27;0
WireConnection;28;0;27;0
WireConnection;28;1;5;0
WireConnection;27;82;23;0
WireConnection;27;74;23;1
WireConnection;29;0;4;0
WireConnection;29;1;30;0
ASEEND*/
//CHKSM=46B0ED010006C64A2CF0951C3B4DA24ADCDE355C