// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Tree Billboard"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.35
		[SingleLineTexture]_AlbedoMap("Albedo Map", 2D) = "gray" {}
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		[Normal][SingleLineTexture]_Normalmap("Normal map", 2D) = "bump" {}
		_AlbedoLightness("Albedo Lightness", Range( 0 , 5)) = 1
		[SingleLineTexture]_AoGloss("Ao/Gloss", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_LeavesMask("Leaves Mask", 2D) = "white" {}
		[Toggle(_COLORVARIATION_ON)] _ColorVariation("Color Variation", Float) = 0
		_WorldFreq("World Freq", Float) = 1
		_Winddirection("Wind direction", Float) = 1
		_Bentamount("Bent amount", Range( 0 , 1)) = 1
		_AoIntensity("Ao Intensity", Range( 0 , 1)) = 0
		_TranslucencyColor("Translucency Color", Color) = (0.5,0.5,0.5,0)
		_TranslucencyRange("Translucency Range", Float) = 1
		_TranslucencyPower("Translucency Power", Range( 0 , 40)) = 8
		_Gloss("Gloss", Range( 0 , 1)) = 1
		_GrassColorvariatoionPower("Grass Color variatoion Power", Range( 0 , 5)) = 0.6
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma shader_feature _COLORVARIATION_ON
		#pragma surface surf StandardSpecular keepalpha vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			half ASEVFace : VFACE;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _Winddirection;
		uniform float _WorldFreq;
		uniform float _Bentamount;
		uniform sampler2D _Normalmap;
		uniform float4 _Normalmap_ST;
		uniform sampler2D _AlbedoMap;
		uniform float4 _AlbedoMap_ST;
		uniform float4 _AlbedoColor;
		uniform float _GrassColorvariatoionPower;
		uniform float _AlbedoLightness;
		uniform sampler2D _LeavesMask;
		uniform sampler2D _AoGloss;
		uniform float4 _AoGloss_ST;
		uniform float _TranslucencyRange;
		uniform float4 _TranslucencyColor;
		uniform float _TranslucencyPower;
		uniform float _Gloss;
		uniform float _AoIntensity;
		uniform float _Cutoff = 0.35;


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
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 transform12 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float temp_output_22_0 = ( ( ase_vertex3Pos.y * cos( ( ( ( transform12.x + transform12.z ) * _WorldFreq ) + _Time.y ) ) ) * _Bentamount );
			float3 appendResult23 = (float3(temp_output_22_0 , 0.0 , temp_output_22_0));
			float3 rotatedValue30 = RotateAroundAxis( float3( 0,0,0 ), appendResult23, normalize( float3( 0,0,0 ) ), _Winddirection );
			v.vertex.xyz += rotatedValue30;
			v.vertex.w = 1;
			//Calculate new billboard vertex position and normal;
			float3 upCamVec = float3( 0, 1, 0 );
			float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
			float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
			float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
			v.normal = normalize( mul( float4( v.normal , 0 ), rotationCamMatrix )).xyz;
			v.tangent.xyz = normalize( mul( float4( v.tangent.xyz , 0 ), rotationCamMatrix )).xyz;
			//This unfortunately must be made to take non-uniform scaling into account;
			//Transform to world coords, apply rotation and transform back to local;
			v.vertex = mul( v.vertex , unity_ObjectToWorld );
			v.vertex = mul( v.vertex , rotationCamMatrix );
			v.vertex = mul( v.vertex , unity_WorldToObject );
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_Normalmap = i.uv_texcoord * _Normalmap_ST.xy + _Normalmap_ST.zw;
			float3 tex2DNode2 = UnpackScaleNormal( tex2D( _Normalmap, uv_Normalmap ), 1.0 );
			float4 appendResult70 = (float4(tex2DNode2.r , tex2DNode2.g , ( tex2DNode2.b * i.ASEVFace ) , 0.0));
			o.Normal = appendResult70.xyz;
			float2 uv_AlbedoMap = i.uv_texcoord * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
			float4 tex2DNode4 = tex2D( _AlbedoMap, uv_AlbedoMap );
			float4 break95 = tex2DNode4;
			float4 transform93 = mul(unity_ObjectToWorld,float4( 1,1,1,1 ));
			float dotResult4_g17 = dot( transform93.xy , float2( 12.9898,78.233 ) );
			float lerpResult10_g17 = lerp( 0.9 , 1.15 , frac( ( sin( dotResult4_g17 ) * 43758.55 ) ));
			float4 appendResult100 = (float4(( break95.r * lerpResult10_g17 ) , break95.g , break95.b , 0.0));
			float4 lerpResult101 = lerp( tex2DNode4 , appendResult100 , _GrassColorvariatoionPower);
			#ifdef _COLORVARIATION_ON
				float4 staticSwitch103 = lerpResult101;
			#else
				float4 staticSwitch103 = tex2DNode4;
			#endif
			float2 uv_LeavesMask121 = i.uv_texcoord;
			float4 tex2DNode121 = tex2D( _LeavesMask, uv_LeavesMask121 );
			float4 lerpResult120 = lerp( tex2DNode4 , ( staticSwitch103 * _AlbedoLightness ) , tex2DNode121);
			float4 temp_output_114_0 = ( _AlbedoColor * lerpResult120 );
			float4 lerpResult122 = lerp( tex2DNode4 , temp_output_114_0 , tex2DNode121);
			o.Albedo = lerpResult122.rgb;
			float2 uv_AoGloss = i.uv_texcoord * _AoGloss_ST.xy + _AoGloss_ST.zw;
			float4 tex2DNode3 = tex2D( _AoGloss, uv_AoGloss );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV55 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode55 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV55, 5.0 ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir44 = normalize( mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz );
			float dotResult50 = dot( ase_worldViewDir , -( ase_worldlightDir + ( objToWorldDir44 * _TranslucencyRange ) ) );
			float4 temp_output_53_0 = saturate( ( dotResult50 * _TranslucencyColor ) );
			o.Emission = ( ( ( tex2DNode3.b * ( temp_output_114_0 * saturate( fresnelNode55 ) ) ) * ( tex2DNode3.b * temp_output_53_0 ) ) * _TranslucencyPower ).rgb;
			o.Specular = ( -1.0 * temp_output_114_0 ).rgb;
			o.Smoothness = ( _Gloss * tex2DNode3.a );
			float4 color39 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 temp_cast_7 = (tex2DNode3.g).xxxx;
			float4 lerpResult41 = lerp( color39 , temp_cast_7 , _AoIntensity);
			o.Occlusion = lerpResult41.r;
			o.Alpha = 1;
			clip( tex2DNode4.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18935
7;92;1906;811;2939.147;605.683;2.571216;True;True
Node;AmplifyShaderEditor.CommentaryNode;88;-2577.491,-452.1584;Inherit;False;1668.825;1070.927;;16;39;114;113;111;109;103;33;2;3;1;4;118;119;120;121;122;Base Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-2492.726,233.8438;Inherit;True;Property;_AlbedoMap;Albedo Map;1;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;91;-3918.181,-404.7016;Inherit;False;1055.403;552.1744;Comment;8;101;100;98;96;95;94;93;117;Grass Color Variation;0.7504205,1,0,1;0;0
Node;AmplifyShaderEditor.WireNode;119;-2255.557,491.2086;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;116;-3595.156,188.1355;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;93;-3852.422,-341.368;Inherit;False;1;0;FLOAT4;1,1,1,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;42;-1429.776,1688.882;Inherit;False;1329.21;589.1115;Comment;12;54;53;52;50;51;48;49;47;46;45;43;44;Translucency 2;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;94;-3652.193,-351.1746;Inherit;False;Random Range;-1;;17;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.9;False;3;FLOAT;1.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;95;-3653.335,-228.7087;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;118;-2253.738,143.6569;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-3463.332,-285.326;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;54;-1401.829,1982.781;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;10;-3217.311,752.1107;Inherit;False;3214.55;784.7615;Comment;21;29;24;25;26;27;30;31;28;23;22;21;20;18;19;17;15;16;13;14;12;11;Trunk Bend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-3452.539,-74.47817;Inherit;False;Property;_GrassColorvariatoionPower;Grass Color variatoion Power;16;0;Create;True;0;0;0;False;0;False;0.6;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;-3112.949,89.87482;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-3323.417,-222.5901;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;11;-3178.022,821.7598;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;44;-1197.406,1944.266;Inherit;False;Object;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;43;-1199.266,2115.238;Inherit;False;Property;_TranslucencyRange;Translucency Range;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;101;-3129.003,-233.73;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;46;-1207.136,1743.882;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-957.7675,2036.668;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;12;-2987.428,981.5007;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-816.0093,1940.25;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-2765.651,951.6248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2704.49,1172.112;Inherit;False;Property;_WorldFreq;World Freq;8;0;Create;True;0;0;0;False;0;False;1;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;103;-2122.949,-215.151;Inherit;False;Property;_ColorVariation;Color Variation;7;0;Create;True;0;0;0;True;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-2133.322,-97.26996;Inherit;False;Property;_AlbedoLightness;Albedo Lightness;4;0;Create;True;0;0;0;True;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;121;-2092.449,420.3003;Inherit;True;Property;_LeavesMask;Leaves Mask;6;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-1859.592,-156.8503;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TimeNode;16;-2738.489,1267.112;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;49;-682.1754,1938.817;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;48;-854.2794,1787.521;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;61;-1117.187,2336.988;Inherit;False;985.7861;541.6563;Comment;5;59;57;55;58;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-2541.488,946.1107;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-817.0203,2069.025;Inherit;False;Property;_TranslucencyColor;Translucency Color;12;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;113;-2095.38,-398.3896;Inherit;False;Property;_AlbedoColor;Albedo Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;120;-1712.899,-79.48904;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;50;-536.447,1870.997;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-2318.652,1044.111;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;55;-1092.499,2413.175;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1584.414,-295.8813;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-404.0191,1969.025;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;57;-841.2738,2414.584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;19;-2182.219,1045.652;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;18;-2189.24,879.0247;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-2181.063,1273.698;Inherit;False;Property;_Bentamount;Bent amount;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1197.034,146.4559;Inherit;True;Property;_AoGloss;Ao/Gloss;5;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;53;-268.4194,1971.653;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-684.5255,2409.082;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1406.943,59.95644;Inherit;False;Constant;_NormalIntenisty;Normal Intenisty;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1996.097,950.0358;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FaceVariableNode;68;-622.9577,170.5354;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1771.276,1077.605;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-85.98781,1653.322;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;64;-580.9769,2674.719;Inherit;False;350;166;Comment;1;65;Translucnecy Power;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-442.8767,2400.309;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-1199.716,-90.22096;Inherit;True;Property;_Normalmap;Normal map;3;2;[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;-495.286,551.7672;Inherit;False;Property;_Gloss;Gloss;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;81;-1678.851,2388.857;Inherit;False;412.1774;240.6119;Fix shading delete;2;80;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1613.561,1044.64;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;142.2852,1582.841;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-508.2933,86.27257;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-1159.92,425.9004;Inherit;False;Constant;_Color0;Color 0;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;65;-530.9763,2724.719;Inherit;False;Property;_TranslucencyPower;Translucency Power;14;0;Create;True;0;0;0;False;0;False;8;10;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-365.3336,-369.1239;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;87;350.3794,1504.136;Inherit;False;212;185;Comment;1;67;Translucency Output;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-745.1843,821.3217;Inherit;False;Property;_Winddirection;Wind direction;9;0;Create;True;0;0;0;False;0;False;1;1.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1174.034,347.4326;Inherit;False;Property;_AoIntensity;Ao Intensity;11;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1570.846,1287.507;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;25;-1280.511,787.532;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;24;-1352.077,1046.802;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;27;-810.4106,917.6517;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;79;-1628.851,2441.469;Inherit;False;Constant;_Vector1;Vector 1;12;1;[HDR];Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-1428.673,2438.857;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-250.1479,459.0104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;122;-1393.797,-228.8879;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-66.09863,-330.3153;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1070.226,1045.066;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;30;-401.4742,1050.358;Inherit;False;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;41;-460.0369,328.5979;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-331.6656,128.4199;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;407.2858,1542.156;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;29;-1824.274,1238.842;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;528.8303,12.15346;Float;False;True;-1;2;;0;0;StandardSpecular;Tobyfredson/Tree Billboard;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.35;True;False;0;False;TransparentCutout;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;True;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;119;0;4;0
WireConnection;116;0;119;0
WireConnection;94;1;93;0
WireConnection;95;0;116;0
WireConnection;118;0;4;0
WireConnection;96;0;95;0
WireConnection;96;1;94;0
WireConnection;117;0;118;0
WireConnection;100;0;96;0
WireConnection;100;1;95;1
WireConnection;100;2;95;2
WireConnection;44;0;54;0
WireConnection;101;0;117;0
WireConnection;101;1;100;0
WireConnection;101;2;98;0
WireConnection;45;0;44;0
WireConnection;45;1;43;0
WireConnection;12;0;11;0
WireConnection;47;0;46;0
WireConnection;47;1;45;0
WireConnection;14;0;12;1
WireConnection;14;1;12;3
WireConnection;103;1;4;0
WireConnection;103;0;101;0
WireConnection;111;0;103;0
WireConnection;111;1;109;0
WireConnection;49;0;47;0
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;120;0;4;0
WireConnection;120;1;111;0
WireConnection;120;2;121;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;17;0;15;0
WireConnection;17;1;16;2
WireConnection;114;0;113;0
WireConnection;114;1;120;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;57;0;55;0
WireConnection;19;0;17;0
WireConnection;53;0;52;0
WireConnection;58;0;114;0
WireConnection;58;1;57;0
WireConnection;20;0;18;2
WireConnection;20;1;19;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;62;0;3;3
WireConnection;62;1;53;0
WireConnection;59;0;3;3
WireConnection;59;1;58;0
WireConnection;2;5;1;0
WireConnection;23;0;22;0
WireConnection;23;2;22;0
WireConnection;66;0;59;0
WireConnection;66;1;62;0
WireConnection;69;0;2;3
WireConnection;69;1;68;0
WireConnection;31;0;23;0
WireConnection;31;1;29;0
WireConnection;24;0;23;0
WireConnection;27;0;25;2
WireConnection;27;1;26;0
WireConnection;27;2;12;2
WireConnection;80;0;53;0
WireConnection;80;1;79;0
WireConnection;74;0;75;0
WireConnection;74;1;3;4
WireConnection;122;0;4;0
WireConnection;122;1;114;0
WireConnection;122;2;121;0
WireConnection;73;0;72;0
WireConnection;73;1;114;0
WireConnection;26;0;24;0
WireConnection;26;1;25;2
WireConnection;26;2;24;2
WireConnection;30;1;28;0
WireConnection;30;3;23;0
WireConnection;41;0;39;0
WireConnection;41;1;3;2
WireConnection;41;2;33;0
WireConnection;70;0;2;1
WireConnection;70;1;2;2
WireConnection;70;2;69;0
WireConnection;67;0;66;0
WireConnection;67;1;65;0
WireConnection;0;0;122;0
WireConnection;0;1;70;0
WireConnection;0;2;67;0
WireConnection;0;3;73;0
WireConnection;0;4;74;0
WireConnection;0;5;41;0
WireConnection;0;10;4;4
WireConnection;0;11;30;0
ASEEND*/
//CHKSM=F5E079C06CC5FF4A903B36C8CC1B00755A03E5D0