// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Tree Bark Foliage Wind"
{
	Properties
	{
		[NoScaleOffset][SingleLineTexture]_AlbedoMap("Albedo Map", 2D) = "white" {}
		[NoScaleOffset][Normal][SingleLineTexture]_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range( -3 , 3)) = 1
		[NoScaleOffset][SingleLineTexture]_MaskMap("Mask Map", 2D) = "white" {}
		_Float6("Ambient Occlusion", Range( 0 , 1)) = 0
		_Float4("Metallic", Range( 0 , 1)) = 0
		_Float5("Smoothness", Range( 0 , 1)) = 0
		_Tiling("Tiling", Vector) = (1,1,0,0)
		_Offset("Offset", Vector) = (1,1,0,0)
		[Toggle(_VERTEXAOONOFF_ON)] _VertexAoOnOff("Vertex Ao (On/Off)", Float) = 1
		_VertexAointensity("Vertex Ao intensity", Range( 0 , 1)) = 0
		_WorldFrequency("World Frequency", Range( 0 , 1)) = 1
		_WindDirection("Wind Direction", Range( 1.54 , 1.6)) = 1
		_BendAmount("Bend Amount", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature_local _VERTEXAOONOFF_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform float _WindDirection;
		uniform float _WorldFrequency;
		uniform float _BendAmount;
		uniform sampler2D _NormalMap;
		uniform float2 _Tiling;
		uniform float2 _Offset;
		uniform float _NormalIntensity;
		uniform sampler2D _AlbedoMap;
		uniform sampler2D _MaskMap;
		uniform float _Float4;
		uniform float _Float5;
		uniform float _Float6;
		uniform float _VertexAointensity;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 _Vector0 = float3(0,0,0);
			float4 temp_cast_0 = (_Vector0.y).xxxx;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 transform138 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float4 appendResult128 = (float4(( ( ase_vertex3Pos.y * cos( ( ( ( transform138.x + transform138.z ) * _WorldFrequency ) + _Time.y ) ) ) * _BendAmount ) , _Vector0.y , 0.0 , 0.0));
			float4 lerpResult134 = lerp( temp_cast_0 , appendResult128 , ase_vertex3Pos.y);
			float3 rotatedValue130 = RotateAroundAxis( float3( 0,0,0 ), lerpResult134.xyz, normalize( float3( 0,0,0 ) ), _WindDirection );
			v.vertex.xyz += rotatedValue130;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord7 = i.uv_texcoord * _Tiling + _Offset;
			float2 TileUVs9 = uv_TexCoord7;
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, TileUVs9 ), _NormalIntensity );
			o.Albedo = tex2D( _AlbedoMap, TileUVs9 ).rgb;
			float4 tex2DNode32 = tex2D( _MaskMap, TileUVs9 );
			o.Metallic = ( tex2DNode32.r * _Float4 );
			o.Smoothness = ( tex2DNode32.a * _Float5 );
			float temp_output_59_0 = pow( tex2DNode32.g , _Float6 );
			float blendOpSrc103 = i.vertexColor.r;
			float blendOpDest103 = temp_output_59_0;
			float lerpBlendMode103 = lerp(blendOpDest103,( blendOpSrc103 * blendOpDest103 ),_VertexAointensity);
			#ifdef _VERTEXAOONOFF_ON
				float staticSwitch105 = ( saturate( lerpBlendMode103 ));
			#else
				float staticSwitch105 = temp_output_59_0;
			#endif
			o.Occlusion = staticSwitch105;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18935
7;92;1906;811;2569.013;162.3277;2.152577;True;True
Node;AmplifyShaderEditor.CommentaryNode;131;-2570.808,1265.309;Inherit;False;2446.957;632.8082;Comment;17;115;108;111;130;129;134;128;120;127;121;119;118;116;113;110;109;138;Trunk and Branch Bending;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;108;-2530.332,1389.382;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldToObjectTransfNode;138;-2340.925,1494.699;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;4;-2121.842,297.9239;Inherit;False;698.2522;375.7902;Comment;4;9;7;6;5;Tile UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-2124.6,1580.709;Inherit;False;Property;_WorldFrequency;World Frequency;11;0;Create;True;0;0;0;False;0;False;1;0.08;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-2119.147,1464.823;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;115;-1882.576,1683.473;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1894.983,1459.309;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;6;-2091.473,518.6396;Float;False;Property;_Offset;Offset;8;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;5;-2087.66,347.9239;Float;False;Property;_Tiling;Tiling;7;0;Create;True;0;0;0;False;0;False;1,1;3,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-1678.869,1553.276;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1896.723,451.6418;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-1640.051,488.1368;Inherit;False;TileUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CosOpNode;116;-1535.715,1558.85;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;118;-1542.736,1392.223;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-1345.798,1522.074;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1411.559,1779.895;Inherit;False;Property;_BendAmount;Bend Amount;13;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1966.952,93.35655;Inherit;False;9;TileUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;142;-970.3307,878.3635;Inherit;False;809.1835;350.3906;;4;105;103;101;102;Vertex Ao Switch;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-1121.01,1578.44;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1059.423,415.1855;Inherit;False;230;183;AO Output;1;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;127;-1146.51,1350.73;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;32;-1383.288,197.0916;Inherit;True;Property;_MaskMap;Mask Map;3;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-1371.808,514.1867;Float;False;Property;_Float6;Ambient Occlusion;4;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-927.3311,1126.317;Inherit;False;Property;_VertexAointensity;Vertex Ao intensity;10;0;Create;True;0;0;0;False;0;False;0;0.765;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;102;-818.4333,938.6047;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;59;-1010.423,465.1854;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;128;-953.8022,1571.65;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1368.731,411.3753;Float;False;Property;_Float5;Smoothness;6;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;139;-1050.979,641.3113;Inherit;False;219;183;Metallic Output;1;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-793.0605,1346.906;Inherit;False;Property;_WindDirection;Wind Direction;12;0;Create;True;0;0;0;False;0;False;1;1.566;1.54;1.6;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;134;-693.9865,1444.236;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;65;-1670.64,47.2079;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendOpsNode;103;-610.9067,981.0635;Inherit;False;Multiply;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-1370.648,609.5497;Float;False;Property;_Float4;Metallic;5;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-1038.374,199.183;Inherit;False;212;185;Smoothness Output;1;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1683.693,90.80537;Inherit;False;Property;_NormalIntensity;Normal Intensity;2;0;Create;True;0;0;0;False;0;False;1;1;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-1000.979,691.3114;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;31;-1381.298,-242.5739;Inherit;True;Property;_AlbedoMap;Albedo Map;0;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-990.3738,259.1832;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;130;-439.8461,1345.782;Inherit;False;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;19;-1398.297,-16.80828;Inherit;True;Property;_NormalMap;Normal Map;1;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;105;-415.2456,944.1715;Inherit;False;Property;_VertexAoOnOff;Vertex Ao (On/Off);9;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;;0;0;Standard;Tobyfredson/Tree Bark Foliage Wind;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;138;0;108;0
WireConnection;109;0;138;1
WireConnection;109;1;138;3
WireConnection;110;0;109;0
WireConnection;110;1;111;0
WireConnection;113;0;110;0
WireConnection;113;1;115;2
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;9;0;7;0
WireConnection;116;0;113;0
WireConnection;119;0;118;2
WireConnection;119;1;116;0
WireConnection;120;0;119;0
WireConnection;120;1;121;0
WireConnection;32;1;13;0
WireConnection;59;0;32;2
WireConnection;59;1;53;0
WireConnection;128;0;120;0
WireConnection;128;1;127;2
WireConnection;134;0;127;2
WireConnection;134;1;128;0
WireConnection;134;2;118;2
WireConnection;65;0;13;0
WireConnection;103;0;102;1
WireConnection;103;1;59;0
WireConnection;103;2;101;0
WireConnection;140;0;32;1
WireConnection;140;1;141;0
WireConnection;31;1;13;0
WireConnection;42;0;32;4
WireConnection;42;1;39;0
WireConnection;130;1;129;0
WireConnection;130;3;134;0
WireConnection;19;1;65;0
WireConnection;19;5;12;0
WireConnection;105;1;59;0
WireConnection;105;0;103;0
WireConnection;0;0;31;0
WireConnection;0;1;19;0
WireConnection;0;3;140;0
WireConnection;0;4;42;0
WireConnection;0;5;105;0
WireConnection;0;11;130;0
ASEEND*/
//CHKSM=4938D3033DA15FACF5C7AF0C52B1C7C41D695E7F