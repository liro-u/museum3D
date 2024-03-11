// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Tree Billboard Plane"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.35
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		[SingleLineTexture]_AlbedoMap("Albedo Map", 2D) = "gray" {}
		[Normal][SingleLineTexture]_Normalmap("Normal map", 2D) = "bump" {}
		_AlbedoLightness("Albedo Lightness", Range( 0 , 5)) = 1
		[SingleLineTexture]_AoGloss("Ao/Gloss", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_LeafMask("Leaf Mask", 2D) = "white" {}
		[Toggle(_COLORVARIATION_ON)] _ColorVariation("Color Variation", Float) = 0
		_WorldFreq("World Freq", Float) = 1
		_Winddirection("Wind direction", Float) = 1
		_Bentamount("Bent amount", Range( 0 , 1)) = 1
		_AoIntensity("Ao Intensity", Range( 0 , 1)) = 0
		_Specular("Specular", Float) = -1
		_TranslucencyColor("Translucency Color", Color) = (0.5,0.5,0.5,0)
		_TranslucencyRange("Translucency Range", Float) = 1
		_TranslucencyPower("Translucency Power", Range( 0 , 40)) = 8
		_Gloss("Gloss", Range( 0 , 1)) = 1
		[Toggle(_NORMALBACKFACEFIX_ON)] _NormalBackFaceFix("Normal BackFace Fix", Float) = 0
		_GrassColorvariatoionPower("Grass Color variatoion Power", Range( 0 , 5)) = 0.6
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _NORMALBACKFACEFIX_ON
		#pragma shader_feature _COLORVARIATION_ON
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			half ASEVFace : VFACE;
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
		uniform sampler2D _LeafMask;
		uniform sampler2D _AoGloss;
		uniform float4 _AoGloss_ST;
		uniform float _TranslucencyRange;
		uniform float4 _TranslucencyColor;
		uniform float _TranslucencyPower;
		uniform float _Specular;
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
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_Normalmap = i.uv_texcoord * _Normalmap_ST.xy + _Normalmap_ST.zw;
			float3 tex2DNode2 = UnpackScaleNormal( tex2D( _Normalmap, uv_Normalmap ), 1.0 );
			float3 appendResult136 = (float3(tex2DNode2.r , ( tex2DNode2.g * i.ASEVFace ) , tex2DNode2.b));
			float3 appendResult82 = (float3(tex2DNode2.r , tex2DNode2.g , ( tex2DNode2.b * i.ASEVFace )));
			#ifdef _NORMALBACKFACEFIX_ON
				float3 staticSwitch83 = appendResult82;
			#else
				float3 staticSwitch83 = appendResult136;
			#endif
			o.Normal = staticSwitch83;
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
			float2 uv_LeafMask118 = i.uv_texcoord;
			float4 tex2DNode118 = tex2D( _LeafMask, uv_LeafMask118 );
			float4 lerpResult120 = lerp( tex2DNode4 , ( staticSwitch103 * _AlbedoLightness ) , tex2DNode118);
			float4 temp_output_114_0 = ( _AlbedoColor * lerpResult120 );
			float4 lerpResult123 = lerp( tex2DNode4 , temp_output_114_0 , tex2DNode118);
			o.Albedo = lerpResult123.rgb;
			float2 uv_AoGloss = i.uv_texcoord * _AoGloss_ST.xy + _AoGloss_ST.zw;
			float4 tex2DNode3 = tex2D( _AoGloss, uv_AoGloss );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir44 = normalize( mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz );
			float dotResult50 = dot( ase_worldViewDir , -( ase_worldlightDir + ( objToWorldDir44 * _TranslucencyRange ) ) );
			float4 temp_output_52_0 = ( dotResult50 * _TranslucencyColor );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			o.Emission = ( ( ( temp_output_114_0 * ( tex2DNode3.b * saturate( temp_output_52_0 ) ) ) * _TranslucencyPower ) * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a ).rgb;
			o.Specular = ( _Specular * lerpResult120 ).rgb;
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
7;92;1906;811;4474.925;614.5767;3.374183;True;True
Node;AmplifyShaderEditor.CommentaryNode;88;-3398.563,-607.9663;Inherit;False;1660.825;932.9272;;11;114;113;111;109;103;4;118;120;121;122;123;Base Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-3185.396,-159.0175;Inherit;True;Property;_AlbedoMap;Albedo Map;2;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;42;-1962.178,1495.157;Inherit;False;1902.669;740.6327;Comment;23;53;52;50;51;49;48;47;46;45;44;43;54;62;86;67;65;126;127;128;129;130;131;134;Translucency 2;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;91;-4539.335,-617.3804;Inherit;False;1055.403;552.1744;Comment;8;101;100;98;96;95;94;93;117;Grass Color Variation;0.7504205,1,0,1;0;0
Node;AmplifyShaderEditor.WireNode;121;-2883.318,55.43172;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;116;-4306.416,-68.19463;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;93;-4481.575,-564.0467;Inherit;False;1;0;FLOAT4;1,1,1,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;54;-1894.505,1755.393;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;44;-1705.726,1749.542;Inherit;False;Object;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;95;-4274.488,-441.3874;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;94;-4273.347,-563.8533;Inherit;False;Random Range;-1;;17;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.9;False;3;FLOAT;1.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;10;-3265.209,650.8735;Inherit;False;3214.55;784.7615;Comment;21;29;24;25;26;27;30;31;28;23;22;21;20;18;19;17;15;16;13;14;12;11;Trunk Bend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1707.586,1921.513;Inherit;False;Property;_TranslucencyRange;Translucency Range;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;46;-1701.408,1550.607;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;11;-3225.92,720.5226;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-4084.487,-498.0047;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;122;-2913.406,-234.6859;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1466.087,1842.943;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-4073.694,-287.157;Inherit;False;Property;_GrassColorvariatoionPower;Grass Color variatoion Power;18;0;Create;True;0;0;0;False;0;False;0.6;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;-3739.49,-121.387;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-3944.573,-435.2689;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;12;-3035.326,880.263;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-1340.329,1748.526;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-2813.549,850.387;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;48;-1361.599,1593.797;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;101;-3750.159,-446.4088;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2752.388,1070.874;Inherit;False;Property;_WorldFreq;World Freq;8;0;Create;True;0;0;0;False;0;False;1;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;49;-1190.495,1745.093;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;50;-1044.767,1677.272;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-2723.648,-235.8937;Inherit;False;Property;_AlbedoLightness;Albedo Lightness;4;0;Create;True;0;0;0;True;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-1149.84,1875.3;Inherit;False;Property;_TranslucencyColor;Translucency Color;13;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;103;-2713.276,-353.7746;Inherit;False;Property;_ColorVariation;Color Variation;7;0;Create;True;0;0;0;True;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TimeNode;16;-2786.387,1165.874;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-2589.386,844.8732;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-920.3385,1769.301;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;118;-3202.898,113.6602;Inherit;True;Property;_LeafMask;Leaf Mask;6;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-2443.028,-310.6393;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-2366.55,942.8729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;19;-2230.117,944.414;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;53;-780.6384,1772.729;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;18;-2237.138,777.7875;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;113;-2685.706,-537.0135;Inherit;False;Property;_AlbedoColor;Albedo Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1;-1649.559,-67.66611;Inherit;False;Constant;_NormalIntenisty;Normal Intenisty;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;120;-2297.652,-172.3969;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-1389.368,124.2623;Inherit;True;Property;_AoGloss;Ao/Gloss;5;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;87;-1043.953,-153.3049;Inherit;False;804.702;390.9415;Normal BackFace Fix;5;81;82;83;135;136;Normal BackFace Fix;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-2043.996,848.7982;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-631.1856,1744.471;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2228.961,1172.46;Inherit;False;Property;_Bentamount;Bent amount;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FaceVariableNode;80;-1229.636,36.80269;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1379.367,-154.6892;Inherit;True;Property;_Normalmap;Normal map;3;2;[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2109.758,-424.197;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-646.0333,1856.859;Inherit;False;Property;_TranslucencyPower;Translucency Power;15;0;Create;True;0;0;0;False;0;False;8;15.8;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1819.177,976.3671;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-494.2788,1711.07;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-997.3976,112.7524;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-993.702,-54.5436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-557.7792,-352.051;Inherit;False;Property;_Specular;Specular;12;0;Create;True;0;0;0;False;0;False;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1661.462,943.402;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-334.6523,1699.281;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-848.2219,57.73497;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1355.622,317.1799;Inherit;False;Property;_AoIntensity;Ao Intensity;11;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-1286.509,398.6477;Inherit;False;Constant;_Color0;Color 0;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;-495.286,551.7672;Inherit;False;Property;_Gloss;Gloss;16;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;136;-838.1851,-86.30991;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-793.0833,720.0845;Inherit;False;Property;_Winddirection;Wind direction;9;0;Create;True;0;0;0;False;0;False;1;1.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;126;-344.0387,1867.778;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-250.1479,459.0104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;29;-1872.175,1137.604;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-811.0077,2070.165;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1118.126,943.828;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-187.8641,1748.811;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-983.0077,2092.165;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;129;-1132.233,2080.141;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;128;-1124.233,2161.141;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;83;-580.2516,-103.3049;Inherit;False;Property;_NormalBackFaceFix;Normal BackFace Fix;17;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;27;-858.309,816.4142;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;41;-460.0369,328.5979;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;30;-449.3727,949.1201;Inherit;False;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;25;-1363.543,761.8309;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightPos;134;-1919.073,1589.053;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;123;-1932.321,-265.8345;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;24;-1399.977,945.564;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1618.746,1186.269;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-367.5118,-298.3497;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;312.1753,3.356727;Float;False;True;-1;2;;0;0;StandardSpecular;Tobyfredson/Tree Billboard Plane;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.35;True;True;0;False;TransparentCutout;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;121;0;4;0
WireConnection;116;0;121;0
WireConnection;44;0;54;0
WireConnection;95;0;116;0
WireConnection;94;1;93;0
WireConnection;96;0;95;0
WireConnection;96;1;94;0
WireConnection;122;0;4;0
WireConnection;45;0;44;0
WireConnection;45;1;43;0
WireConnection;117;0;122;0
WireConnection;100;0;96;0
WireConnection;100;1;95;1
WireConnection;100;2;95;2
WireConnection;12;0;11;0
WireConnection;47;0;46;0
WireConnection;47;1;45;0
WireConnection;14;0;12;1
WireConnection;14;1;12;3
WireConnection;101;0;117;0
WireConnection;101;1;100;0
WireConnection;101;2;98;0
WireConnection;49;0;47;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;103;1;4;0
WireConnection;103;0;101;0
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;111;0;103;0
WireConnection;111;1;109;0
WireConnection;17;0;15;0
WireConnection;17;1;16;2
WireConnection;19;0;17;0
WireConnection;53;0;52;0
WireConnection;120;0;4;0
WireConnection;120;1;111;0
WireConnection;120;2;118;0
WireConnection;20;0;18;2
WireConnection;20;1;19;0
WireConnection;62;0;3;3
WireConnection;62;1;53;0
WireConnection;2;5;1;0
WireConnection;114;0;113;0
WireConnection;114;1;120;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;86;0;114;0
WireConnection;86;1;62;0
WireConnection;81;0;2;3
WireConnection;81;1;80;0
WireConnection;135;0;2;2
WireConnection;135;1;80;0
WireConnection;23;0;22;0
WireConnection;23;2;22;0
WireConnection;67;0;86;0
WireConnection;67;1;65;0
WireConnection;82;0;2;1
WireConnection;82;1;2;2
WireConnection;82;2;81;0
WireConnection;136;0;2;1
WireConnection;136;1;135;0
WireConnection;136;2;2;3
WireConnection;74;0;75;0
WireConnection;74;1;3;4
WireConnection;131;0;130;0
WireConnection;131;1;52;0
WireConnection;26;0;24;0
WireConnection;26;1;25;2
WireConnection;26;2;24;2
WireConnection;127;0;67;0
WireConnection;127;1;126;1
WireConnection;127;2;126;2
WireConnection;130;0;128;0
WireConnection;130;1;129;0
WireConnection;129;0;48;2
WireConnection;128;0;46;2
WireConnection;83;1;136;0
WireConnection;83;0;82;0
WireConnection;27;0;25;2
WireConnection;27;1;26;0
WireConnection;27;2;12;2
WireConnection;41;0;39;0
WireConnection;41;1;3;2
WireConnection;41;2;33;0
WireConnection;30;1;28;0
WireConnection;30;3;23;0
WireConnection;123;0;4;0
WireConnection;123;1;114;0
WireConnection;123;2;118;0
WireConnection;24;0;23;0
WireConnection;31;0;23;0
WireConnection;31;1;29;0
WireConnection;73;0;72;0
WireConnection;73;1;120;0
WireConnection;0;0;123;0
WireConnection;0;1;83;0
WireConnection;0;2;127;0
WireConnection;0;3;73;0
WireConnection;0;4;74;0
WireConnection;0;5;41;0
WireConnection;0;10;4;4
WireConnection;0;11;30;0
ASEEND*/
//CHKSM=2D895B5AF68AB1BBFE7B45ABEC9D0821341A1DFD