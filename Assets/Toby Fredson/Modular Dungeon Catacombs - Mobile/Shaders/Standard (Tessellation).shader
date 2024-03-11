// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Standard (Tessellation)"
{
	Properties
	{
		_AlbedoMap("Albedo Map", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Float) = 1
		_MetallicMap("Metallic Map", 2D) = "black" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_SmoothnessMap("Smoothness Map", 2D) = "gray" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_MetallicAoGloss("Metallic/Ao/Gloss", 2D) = "white" {}
		_Ao("Ao", Range( 0 , 1)) = 1
		_DisplacementMap("Displacement Map", 2D) = "gray" {}
		_DisplacementStrengh("Displacement Strengh", Range( 0 , 1)) = 0
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 3.4
		_TessMin( "Tess Min Distance", Float ) = 2
		_TessMax( "Tess Max Distance", Float ) = 23
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows noinstancing vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _DisplacementMap;
		uniform float4 _DisplacementMap_ST;
		uniform float _DisplacementStrengh;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _NormalIntensity;
		uniform sampler2D _AlbedoMap;
		uniform float4 _AlbedoMap_ST;
		uniform sampler2D _MetallicMap;
		uniform float4 _MetallicMap_ST;
		uniform float _Metallic;
		uniform sampler2D _SmoothnessMap;
		uniform float4 _SmoothnessMap_ST;
		uniform float _Smoothness;
		uniform sampler2D _MetallicAoGloss;
		uniform float4 _MetallicAoGloss_ST;
		uniform float _Ao;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;
		uniform float _TessPhongStrength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_DisplacementMap = v.texcoord * _DisplacementMap_ST.xy + _DisplacementMap_ST.zw;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( tex2Dlod( _DisplacementMap, float4( uv_DisplacementMap, 0, 1.0) ) * float4( ase_vertexNormal , 0.0 ) ) * _DisplacementStrengh ).rgb;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalIntensity );
			float2 uv_AlbedoMap = i.uv_texcoord * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
			o.Albedo = tex2D( _AlbedoMap, uv_AlbedoMap ).rgb;
			float2 uv_MetallicMap = i.uv_texcoord * _MetallicMap_ST.xy + _MetallicMap_ST.zw;
			o.Metallic = ( tex2D( _MetallicMap, uv_MetallicMap ).r * _Metallic );
			float2 uv_SmoothnessMap = i.uv_texcoord * _SmoothnessMap_ST.xy + _SmoothnessMap_ST.zw;
			o.Smoothness = ( tex2D( _SmoothnessMap, uv_SmoothnessMap ).a * _Smoothness );
			float2 uv_MetallicAoGloss = i.uv_texcoord * _MetallicAoGloss_ST.xy + _MetallicAoGloss_ST.zw;
			o.Occlusion = pow( tex2D( _MetallicAoGloss, uv_MetallicAoGloss ).g , _Ao );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18301
7;29;1906;1004;1696.387;-908.1176;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;26;-986.8733,1103.359;Inherit;False;816.1258;404.0984;Tessellation;5;22;24;21;25;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;25;-936.8733,1153.359;Inherit;True;Property;_DisplacementMap;Displacement Map;9;0;Create;True;0;0;False;0;False;-1;None;9789d23040cb1fb45ad60392430c3c15;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;21;-835.7617,1349.086;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1;-690.3149,402.2376;Float;False;Property;_Metallic;Metallic;4;0;Create;False;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-695.9668,685.2483;Float;False;Property;_Smoothness;Smoothness;6;0;Create;False;0;0;False;0;False;0;0.22;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-601.4055,1378.89;Float;False;Property;_DisplacementStrengh;Displacement Strengh;10;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-696.8148,176.8379;Inherit;True;Property;_MetallicMap;Metallic Map;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-899.2328,10.03476;Inherit;False;Property;_NormalIntensity;Normal Intensity;2;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-687.1671,793.2432;Inherit;True;Property;_MetallicAoGloss;Metallic/Ao/Gloss;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-590.8732,1271.359;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-691.6533,1021.934;Float;False;Property;_Ao;Ao;8;0;Create;False;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-697.043,484.8011;Inherit;True;Property;_SmoothnessMap;Smoothness Map;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-681.4891,-245.515;Inherit;True;Property;_AlbedoMap;Albedo Map;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-322.1116,1279.149;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-365.1706,293.4035;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-355.3069,518.2079;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-690.2142,-37.18824;Inherit;True;Property;_NormalMap;Normal Map;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;8;-333.9241,909.5585;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;41.27105,380.3865;Float;False;True;-1;6;;0;0;Standard;Tobyfredson/Standard (Tessellation);False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;3.4;2;23;True;0;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;11;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;25;0
WireConnection;23;1;21;0
WireConnection;22;0;23;0
WireConnection;22;1;24;0
WireConnection;9;0;2;1
WireConnection;9;1;1;0
WireConnection;7;0;3;4
WireConnection;7;1;4;0
WireConnection;11;5;12;0
WireConnection;8;0;6;2
WireConnection;8;1;5;0
WireConnection;0;0;10;0
WireConnection;0;1;11;0
WireConnection;0;3;9;0
WireConnection;0;4;7;0
WireConnection;0;5;8;0
WireConnection;0;11;22;0
ASEEND*/
//CHKSM=BF71A2E4CFC8251303323611BE2A4A662FA2676A