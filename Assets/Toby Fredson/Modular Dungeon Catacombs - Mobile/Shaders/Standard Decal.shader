// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Standard Decal"
{
	Properties
	{
		_TilingScale("Tiling Scale", Float) = 1
		_Color("Color", Color) = (1,1,1,0)
		[SingleLineTexture]_Albedo("Albedo", 2D) = "white" {}
		[Normal][SingleLineTexture]_Normal("Normal", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range( -3 , 3)) = 1
		[SingleLineTexture]_MetallicSmoothness("Metallic/Smoothness", 2D) = "white" {}
		_MetallicIntensity("Metallic Intensity", Range( 0 , 1)) = 0
		_SmoothnessIntensity("Smoothness Intensity", Range( 0 , 1)) = 0
		[SingleLineTexture]_AmbientOcclusion("Ambient Occlusion", 2D) = "white" {}
		_Float6("Ao Intensity", Range( 0 , 1)) = 0
		[SingleLineTexture]_HeightMap("HeightMap", 2D) = "white" {}
		_Parallax("Parallax", Range( 0 , 0.1)) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Dither("Dither", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float4 screenPosition;
		};

		uniform sampler2D _Normal;
		uniform float _TilingScale;
		uniform sampler2D _HeightMap;
		uniform float4 _HeightMap_ST;
		uniform float _Parallax;
		uniform float _NormalIntensity;
		uniform float4 _Color;
		uniform sampler2D _Albedo;
		uniform sampler2D _MetallicSmoothness;
		uniform float _MetallicIntensity;
		uniform float _SmoothnessIntensity;
		uniform sampler2D _AmbientOcclusion;
		uniform float _Float6;
		uniform float _Dither;
		uniform float _Cutoff = 0.5;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_TilingScale).xx;
			float2 uv_TexCoord23 = i.uv_texcoord * temp_cast_0;
			float2 uv_HeightMap = i.uv_texcoord * _HeightMap_ST.xy + _HeightMap_ST.zw;
			float2 Offset33 = ( ( tex2D( _HeightMap, uv_HeightMap ).r - 1 ) * i.viewDir.xy * _Parallax ) + uv_TexCoord23;
			float2 Offset43 = ( ( tex2D( _HeightMap, Offset33 ).r - 1 ) * i.viewDir.xy * _Parallax ) + Offset33;
			float2 Offset55 = ( ( tex2D( _HeightMap, Offset43 ).r - 1 ) * i.viewDir.xy * _Parallax ) + Offset43;
			float2 Offset67 = ( ( tex2D( _HeightMap, Offset55 ).r - 1 ) * i.viewDir.xy * _Parallax ) + Offset55;
			float2 Offset68 = Offset67;
			o.Normal = UnpackScaleNormal( tex2D( _Normal, Offset68 ), _NormalIntensity );
			float4 tex2DNode1 = tex2D( _Albedo, Offset68 );
			o.Albedo = ( _Color * tex2DNode1 ).rgb;
			float4 tex2DNode17 = tex2D( _MetallicSmoothness, Offset68 );
			o.Metallic = ( tex2DNode17.r * _MetallicIntensity );
			o.Smoothness = ( tex2DNode17.a * _SmoothnessIntensity );
			float4 tex2DNode7 = tex2D( _AmbientOcclusion, Offset68 );
			float saferPower21 = abs( tex2DNode7.g );
			o.Occlusion = pow( saferPower21 , _Float6 );
			o.Alpha = 1;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen9 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither9 = Dither8x8Bayer( fmod(clipScreen9.x, 8), fmod(clipScreen9.y, 8) );
			dither9 = step( dither9, tex2DNode1.a );
			float lerpResult10 = lerp( tex2DNode1.a , dither9 , _Dither);
			clip( lerpResult10 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18935
7;196;1906;823;1679.521;330.8902;1.638978;True;True
Node;AmplifyShaderEditor.RangedFloatNode;22;-1692.028,-208.0578;Float;False;Property;_TilingScale;Tiling Scale;0;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;25;-1784.028,236.5426;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1505.932,-220.4567;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-1912.028,108.5426;Float;False;Property;_Parallax;Parallax;11;0;Create;True;0;0;0;False;0;False;0;0.04;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;28;-1263.223,-267.6568;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;26;-1293.819,-17.45661;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;27;-1295.527,-47.05643;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;29;-958.9243,-268.6567;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;31;-944.5273,-70.25646;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-1235.326,-240.5575;Inherit;True;Property;_HeightMap;HeightMap;10;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;FLOAT2;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;32;-926.6182,-50.45667;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ParallaxMappingNode;33;-847.3252,-204.2575;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;34;-607.9191,-12.15662;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;35;-1283.52,10.24331;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;36;-584.9181,4.143417;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;38;-1300.82,238.343;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;37;-1299.326,214.744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;41;-961.2184,229.6433;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;39;-880.6193,31.84347;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;40;-1260.019,42.44405;Inherit;True;Property;_TextureSample1;Texture Sample 1;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;30;Auto;Texture2D;8;0;SAMPLER2D;FLOAT2;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;42;-968.3263,211.9439;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;43;-862.0223,65.44338;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;44;-1362.43,457.1436;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;45;-640.4181,239.4435;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;46;-1350.43,439.1436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;48;-1292.619,269.9434;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;47;-1309.52,492.1433;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;50;-1307.726,468.7437;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;49;-609.2192,261.5436;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;54;-971.1263,463.9439;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;52;-967.6194,484.5434;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;53;-883.0192,293.4435;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;51;-1263.366,295.0437;Inherit;True;Property;_TextureSample0;Texture Sample 0;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;30;Auto;Texture2D;8;0;SAMPLER2D;FLOAT2;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxMappingNode;55;-863.7692,319.643;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;56;-671.4182,505.3435;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;58;-1334.926,704.7433;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;57;-1342.721,732.9418;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;62;-1286.73,771.9433;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;60;-648.2181,537.1432;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;59;-1294.72,541.0431;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;61;-1280.73,751.9433;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;66;-958.7194,762.8422;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;65;-971.3274,739.9434;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;64;-894.9182,564.843;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;63;-1263.366,565.0432;Inherit;True;Property;_TextureSample3;Texture Sample 3;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;30;Auto;Texture2D;8;0;SAMPLER2D;FLOAT2;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxMappingNode;67;-865.3693,588.0426;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-459.8911,192.1378;Float;False;Offset;1;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-177.3043,-245.5502;Inherit;True;Property;_Albedo;Albedo;2;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-175.1865,45.22861;Inherit;True;Property;_MetallicSmoothness;Metallic/Smoothness;5;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-169.7724,646.248;Inherit;True;Property;_AmbientOcclusion;Ambient Occlusion;8;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;73;-506.2653,512.0844;Inherit;False;Property;_NormalIntensity;Normal Intensity;4;0;Create;True;0;0;0;False;0;False;1;1;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-155.4392,328.8806;Float;False;Property;_SmoothnessIntensity;Smoothness Intensity;7;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;71;-91.11337,-438.4511;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-154.5811,846.8521;Float;False;Property;_Float6;Ao Intensity;9;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;9;161.7053,-241.4099;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-158.8917,238.2638;Float;False;Property;_MetallicIntensity;Metallic Intensity;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-157.6532,-47.17485;Inherit;False;Property;_Dither;Dither;13;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;187.2042,268.348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;21;128.2495,769.3153;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;72;156.0191,-370.7694;Inherit;False;Darken;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;10;353.4654,-86.95654;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-170.8234,428.1613;Inherit;True;Property;_Normal;Normal;3;2;[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;192.2339,138.2278;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;187.4827,-511.9561;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;4;643.0065,-42.73741;Float;False;True;-1;2;;0;0;Standard;Tobyfredson/Standard Decal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;False;0;False;TransparentCutout;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;12;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;22;0
WireConnection;28;0;23;0
WireConnection;26;0;25;0
WireConnection;27;0;24;0
WireConnection;29;0;28;0
WireConnection;31;0;27;0
WireConnection;32;0;26;0
WireConnection;33;0;29;0
WireConnection;33;1;30;1
WireConnection;33;2;31;0
WireConnection;33;3;32;0
WireConnection;34;0;33;0
WireConnection;35;0;34;0
WireConnection;36;0;33;0
WireConnection;38;0;25;0
WireConnection;37;0;24;0
WireConnection;41;0;38;0
WireConnection;39;0;36;0
WireConnection;40;1;35;0
WireConnection;42;0;37;0
WireConnection;43;0;39;0
WireConnection;43;1;40;1
WireConnection;43;2;42;0
WireConnection;43;3;41;0
WireConnection;44;0;25;0
WireConnection;45;0;43;0
WireConnection;46;0;24;0
WireConnection;48;0;45;0
WireConnection;47;0;44;0
WireConnection;50;0;46;0
WireConnection;49;0;43;0
WireConnection;54;0;50;0
WireConnection;52;0;47;0
WireConnection;53;0;49;0
WireConnection;51;1;48;0
WireConnection;55;0;53;0
WireConnection;55;1;51;1
WireConnection;55;2;54;0
WireConnection;55;3;52;0
WireConnection;56;0;55;0
WireConnection;58;0;24;0
WireConnection;57;0;25;0
WireConnection;62;0;57;0
WireConnection;60;0;55;0
WireConnection;59;0;56;0
WireConnection;61;0;58;0
WireConnection;66;0;62;0
WireConnection;65;0;61;0
WireConnection;64;0;60;0
WireConnection;63;1;59;0
WireConnection;67;0;64;0
WireConnection;67;1;63;1
WireConnection;67;2;65;0
WireConnection;67;3;66;0
WireConnection;68;0;67;0
WireConnection;1;1;68;0
WireConnection;17;1;68;0
WireConnection;7;1;68;0
WireConnection;9;0;1;4
WireConnection;14;0;17;4
WireConnection;14;1;16;0
WireConnection;21;0;7;2
WireConnection;21;1;19;0
WireConnection;72;0;71;0
WireConnection;72;1;1;0
WireConnection;72;2;7;2
WireConnection;10;0;1;4
WireConnection;10;1;9;0
WireConnection;10;2;12;0
WireConnection;2;1;68;0
WireConnection;2;5;73;0
WireConnection;18;0;17;1
WireConnection;18;1;15;0
WireConnection;74;0;71;0
WireConnection;74;1;1;0
WireConnection;4;0;74;0
WireConnection;4;1;2;0
WireConnection;4;3;18;0
WireConnection;4;4;14;0
WireConnection;4;5;21;0
WireConnection;4;10;10;0
ASEEND*/
//CHKSM=B34DFE6CB9630C7CD97A3B7E0F741A3CB18CE890