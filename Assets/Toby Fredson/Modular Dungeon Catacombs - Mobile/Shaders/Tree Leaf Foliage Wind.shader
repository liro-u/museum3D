// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Tree Leaf Foliage Wind"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		_AlbedoLightness("Albedo Lightness", Range( 0 , 5)) = 1
		[Toggle(_COLORVARIATION_ON)] _ColorVariation("Color Variation", Float) = 0
		_LeafColorvariatoion("Leaf Color variatoion", Range( 0 , 5)) = 0.6
		[NoScaleOffset]_AlbedoMap("Albedo Map", 2D) = "white" {}
		[NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range( -3 , 3)) = 0
		[Toggle(_NORMALBACKFACEFIXBRANCH_ON)] _NormalBackFaceFixBranch("Normal BackFace Fix (Branch)", Float) = 0
		[NoScaleOffset]_MaskMap("Mask Map", 2D) = "white" {}
		_SpecularPower("Specular Power", Range( 0 , 1)) = 0
		_SmoothnessIntensity("Smoothness Intensity", Float) = 1
		_TranslucencyColor("Translucency Color", Color) = (0.5,0.5,0.5,0)
		_TranslucencyPower("Translucency Power", Range( 0 , 40)) = 8
		_TranslucencyRange("Translucency Range", Float) = 1
		_AmbientOcclusion("Ambient Occlusion", Range( 0 , 1)) = 1
		[Toggle(_VERTEXAO_ON)] _VertexAo("Vertex Ao", Float) = 1
		_VertexAointensity("Vertex Ao intensity", Range( 0 , 1)) = 0
		_GlobalWindPower("Global Wind Power", Range( 0 , 1)) = 1
		_WindDirection("Wind Direction", Range( 1.54 , 1.6)) = 1
		_WindPower("Wind Power", Range( 0 , 0.89)) = 1
		_WorldFrequency("World Frequency", Range( 0 , 1)) = 1
		_WindScale("Wind Scale", Range( 0 , 2)) = 1
		_WindAngley("Wind Angle (y)", Range( -100 , 100)) = 20
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature_local _NORMALBACKFACEFIXBRANCH_ON
		#pragma shader_feature _COLORVARIATION_ON
		#pragma shader_feature_local _VERTEXAO_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			half ASEVFace : VFACE;
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _WindDirection;
		uniform float _GlobalWindPower;
		uniform float _WindAngley;
		uniform float _WindPower;
		uniform float _WindScale;
		uniform float _WorldFrequency;
		uniform sampler2D _NormalMap;
		uniform float _NormalIntensity;
		uniform float4 _AlbedoColor;
		uniform sampler2D _AlbedoMap;
		uniform float _LeafColorvariatoion;
		uniform float _AlbedoLightness;
		uniform float _TranslucencyPower;
		uniform sampler2D _MaskMap;
		uniform float _TranslucencyRange;
		uniform float4 _TranslucencyColor;
		uniform float _SpecularPower;
		uniform float _SmoothnessIntensity;
		uniform float _AmbientOcclusion;
		uniform float _VertexAointensity;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		//https://www.shadertoy.com/view/XdXGW8
		float2 GradientNoiseDir( float2 x )
		{
			const float2 k = float2( 0.3183099, 0.3678794 );
			x = x * k + k.yx;
			return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
		}
		
		float GradientNoise( float2 UV, float Scale )
		{
			float2 p = UV * Scale;
			float2 i = floor( p );
			float2 f = frac( p );
			float2 u = f * f * ( 3.0 - 2.0 * f );
			return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
					lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

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
			float mulTime10 = _Time.y * 0.1;
			float simplePerlin2D36 = snoise( (ase_worldPos*1.0 + float3( ( mulTime10 * float2( -0.5,-0.5 ) ) ,  0.0 )).xy*2.0 );
			simplePerlin2D36 = simplePerlin2D36*0.5 + 0.5;
			float gradientNoise19 = GradientNoise((ase_worldPos*1.0 + float3( ( _Time.y * float2( 0,-0.1 ) ) ,  0.0 )).xy,20.0);
			gradientNoise19 = gradientNoise19*0.5 + 0.5;
			float4 temp_cast_6 = (gradientNoise19).xxxx;
			float4 appendResult61 = (float4(( ase_vertex3Pos.y * simplePerlin2D36 ) , ( ( CalculateContrast(_WindAngley,temp_cast_6) * 0.25 ) + ( ase_vertex3Pos.y * 1.2 ) ).r , ase_vertex3Pos.z , 0.0));
			float4 lerpResult74 = lerp( float4( ase_vertex3Pos , 0.0 ) , appendResult61 , v.color.g);
			float2 appendResult54 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult47 = (float2(_Time.y , _Time.y));
			float simplePerlin2D77 = snoise( ( appendResult54 + appendResult47 )*_WindScale );
			simplePerlin2D77 = simplePerlin2D77*0.5 + 0.5;
			float4 FinalWind182 = ( 100.0 * ( ( _GlobalWindPower * ( float4( ase_vertex3Pos , 0.0 ) - lerpResult74 ) ) * ( v.color.g * ( pow( ( v.texcoord.xy.y * 0.5 ) , ( 1.0 - _WindPower ) ) * simplePerlin2D77 ) ) ) );
			float3 _Vector1 = float3(0,0,0);
			float4 temp_cast_8 = (_Vector1.y).xxxx;
			float4 transform114 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float4 appendResult128 = (float4(( ( ase_vertex3Pos.y * cos( ( ( ( transform114.x + transform114.z ) * _WorldFrequency ) + _Time.y ) ) ) * 1.0 ) , _Vector1.y , 0.0 , 0.0));
			float4 lerpResult130 = lerp( temp_cast_8 , appendResult128 , ase_vertex3Pos.y);
			float3 rotatedValue131 = RotateAroundAxis( float3( 0,0,0 ), ( FinalWind182 + lerpResult130 ).xyz, normalize( float3( 0,0,0 ) ), _WindDirection );
			float3 TrunkPivotBend169 = rotatedValue131;
			v.vertex.xyz += TrunkPivotBend169;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_NormalMap81 = i.uv_texcoord;
			float3 tex2DNode81 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap81 ), _NormalIntensity );
			float3 appendResult232 = (float3(tex2DNode81.r , ( tex2DNode81.g * i.ASEVFace ) , tex2DNode81.b));
			float3 appendResult162 = (float3(tex2DNode81.r , tex2DNode81.g , ( tex2DNode81.b * i.ASEVFace )));
			#ifdef _NORMALBACKFACEFIXBRANCH_ON
				float3 staticSwitch163 = appendResult162;
			#else
				float3 staticSwitch163 = appendResult232;
			#endif
			float3 NormalOutput207 = staticSwitch163;
			o.Normal = NormalOutput207;
			float2 uv_AlbedoMap57 = i.uv_texcoord;
			float4 tex2DNode57 = tex2D( _AlbedoMap, uv_AlbedoMap57 );
			float4 break150 = tex2DNode57;
			float4 transform147 = mul(unity_ObjectToWorld,float4( 1,1,1,1 ));
			float dotResult4_g17 = dot( transform147.xy , float2( 12.9898,78.233 ) );
			float lerpResult10_g17 = lerp( 0.9 , 1.15 , frac( ( sin( dotResult4_g17 ) * 43758.55 ) ));
			float4 appendResult152 = (float4(( break150.r * lerpResult10_g17 ) , break150.g , break150.b , 0.0));
			float4 lerpResult155 = lerp( tex2DNode57 , appendResult152 , _LeafColorvariatoion);
			#ifdef _COLORVARIATION_ON
				float4 staticSwitch91 = lerpResult155;
			#else
				float4 staticSwitch91 = tex2DNode57;
			#endif
			float4 AlbedoOutput204 = ( _AlbedoColor * ( staticSwitch91 * _AlbedoLightness ) );
			o.Albedo = AlbedoOutput204.rgb;
			float2 uv_MaskMap44 = i.uv_texcoord;
			float4 tex2DNode44 = tex2D( _MaskMap, uv_MaskMap44 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV35 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode35 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV35, 5.0 ) );
			float4 FresnelBase185 = ( tex2DNode44.b * ( staticSwitch91 * saturate( fresnelNode35 ) ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir7 = normalize( mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz );
			float dotResult38 = dot( ase_worldViewDir , -( ase_worldlightDir + ( objToWorldDir7 * _TranslucencyRange ) ) );
			float4 TranslucencyBase194 = saturate( ( dotResult38 * _TranslucencyColor ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 TranslucencyOutput200 = ( ( i.vertexColor.r * ( _TranslucencyPower * ( FresnelBase185 * ( tex2DNode44.b * TranslucencyBase194 ) ) ) ) * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a );
			o.Emission = TranslucencyOutput200.rgb;
			float temp_output_48_0 = ( tex2DNode44.a * _SmoothnessIntensity );
			float4 lerpResult98 = lerp( FresnelBase185 , ( FresnelBase185 * ( TranslucencyBase194 + -temp_output_48_0 ) ) , float4( 0,0,0,0 ));
			float4 SpecularOutput215 = ( _SpecularPower * lerpResult98 );
			o.Specular = SpecularOutput215.rgb;
			float SmoothnessOutput192 = temp_output_48_0;
			o.Smoothness = SmoothnessOutput192;
			float AoBase175 = pow( tex2DNode44.g , _AmbientOcclusion );
			float blendOpSrc95 = i.vertexColor.r;
			float blendOpDest95 = AoBase175;
			float lerpBlendMode95 = lerp(blendOpDest95,( blendOpSrc95 * blendOpDest95 ),_VertexAointensity);
			#ifdef _VERTEXAO_ON
				float staticSwitch108 = ( saturate( lerpBlendMode95 ));
			#else
				float staticSwitch108 = AoBase175;
			#endif
			float AoOutput202 = staticSwitch108;
			o.Occlusion = AoOutput202;
			o.Alpha = 1;
			float OpacityMaskOutput213 = tex2DNode57.a;
			clip( OpacityMaskOutput213 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18935
7;92;1906;811;3476.234;538.5269;2.514583;True;True
Node;AmplifyShaderEditor.CommentaryNode;25;-3311.314,-469.8424;Inherit;False;2494.41;1204.099;;53;163;105;192;200;103;99;162;92;166;161;165;140;81;160;73;199;70;111;64;96;195;93;175;186;72;80;48;196;78;42;44;91;167;158;156;57;204;207;209;210;213;85;98;109;212;215;219;220;221;222;223;231;232;Base Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;57;-2991.376,-349.4449;Inherit;True;Property;_AlbedoMap;Albedo Map;5;1;[NoScaleOffset];Create;True;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1;-4394.846,790.7449;Inherit;False;2774.201;826.295;;32;97;86;82;74;174;65;173;172;61;55;171;36;37;34;29;24;28;18;21;19;16;14;2;12;9;10;8;3;4;197;198;217;Vertex Wind_Layer A;0,0.7931032,1,1;0;0
Node;AmplifyShaderEditor.WireNode;156;-2705.914,-160.8677;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;146;-4450.489,-478.4167;Inherit;False;1047.931;504.8553;Comment;10;155;152;159;153;151;168;149;150;147;157;Grass Color Variation;0.7504205,1,0,1;0;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;147;-4399.67,-415.0835;Inherit;False;1;0;FLOAT4;1,1,1,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;158;-2725.375,-393.4232;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;4;-4347.783,984.1605;Inherit;False;Constant;_EdgeFlutterFrequency;Edge Flutter Frequency;14;0;Create;True;0;0;0;True;0;False;0,-0.1;0,-0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;157;-4238.141,-109.9799;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-4283.109,887.0696;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;167;-3086.452,-381.9933;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;149;-4199.441,-424.89;Inherit;False;Random Range;-1;;17;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.9;False;3;FLOAT;1.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;150;-4200.584,-302.4241;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-4102.368,943.0771;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;9;-4293.065,1402.975;Inherit;False;Constant;_Vector0;Vector 0;12;0;Create;True;0;0;0;True;0;False;-0.5,-0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;10;-4284.505,1302.604;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;2;-3217.568,1312.574;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;12;-4287.624,1138.172;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;5;-2784.75,2451.73;Inherit;False;1363.509;608.5165;Comment;12;194;60;51;33;38;27;26;20;17;15;11;7;Translucency Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-4010.581,-359.0414;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;16;-3948.064,1010.924;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-4102.831,1362.288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;168;-3485.046,-61.88999;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;6;-3106.329,2531.85;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2702.115,2878.087;Inherit;False;Property;_TranslucencyRange;Translucency Range;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-3999.788,-148.1935;Inherit;False;Property;_LeafColorvariatoion;Leaf Color variatoion;4;0;Create;True;0;0;0;False;0;False;0.6;0.6;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-3747.404,1143.68;Inherit;False;Property;_WindAngley;Wind Angle (y);23;0;Create;True;0;0;0;True;0;False;20;20;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;21;-3948.674,1142.904;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;7;-2700.254,2707.115;Inherit;False;Object;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;159;-3698.381,-75.02069;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;152;-3870.667,-296.3055;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;19;-3721.512,897.2493;Inherit;True;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-3708.842,1317.859;Inherit;False;Constant;_FlutterFrequency;Flutter Frequency;21;0;Create;True;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;155;-3676.252,-309.1174;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;31;-3043.105,1680.361;Inherit;False;1426.626;711.0196;;14;101;84;76;77;63;66;67;62;54;52;47;50;53;39;Vertex Wind_Layer B;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;24;-3461.12,975.6795;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;15;-2709.985,2506.73;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2460.616,2799.517;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;28;-3761.226,1236.964;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleNode;37;-3189.014,978.3224;Inherit;False;0.25;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-2328.043,2709.66;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;178;-2229.112,-919.4766;Inherit;False;1162.169;418.4254;Comment;5;185;75;59;49;35;Fresnel Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;112;-4355.556,3102.126;Inherit;False;2904.729;582.355;Comment;18;184;134;131;169;129;130;128;124;126;123;122;120;119;118;117;116;115;114;Trunk Pivot Bend;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;36;-3461.647,1238.095;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;39;-2985.151,2253.197;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;177;-3342.634,-11.96037;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleNode;34;-2973.154,1416.495;Inherit;False;1.2;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-2816.313,1190.833;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;44;-2995.53,338.3598;Inherit;True;Property;_MaskMap;Mask Map;9;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;171;-2959.86,932.6373;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;114;-4126.771,3268.757;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;-2827.434,967.0376;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;27;-2357.127,2550.37;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-2954.288,1730.361;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;26;-2185.024,2701.666;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;91;-2606.196,-173.5893;Inherit;False;Property;_ColorVariation;Color Variation;3;0;Create;True;0;0;0;True;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-2708.154,2170.196;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-3001.25,1872.442;Inherit;False;Constant;_WindGradient;Wind Gradient;9;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;35;-2180.113,-715.8903;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2783.561,1988.822;Inherit;False;Property;_WindPower;Wind Power;20;0;Create;True;0;0;0;False;0;False;1;0.89;0;0.89;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;47;-2737.154,2267.197;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;33;-2319.868,2831.874;Inherit;False;Property;_TranslucencyColor;Translucency Color;12;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-2532.44,2215.482;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;-2502.863,1044.745;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2653.358,2080.872;Inherit;False;Property;_WindScale;Wind Scale;22;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;173;-2969.006,894.9108;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;49;-1946.721,-695.2714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;66;-2508.013,1981.075;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;172;-2274.574,1028.193;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;181;-2636.945,-583.9021;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-4073.889,3451.442;Inherit;False;Property;_WorldFrequency;World Frequency;21;0;Create;True;0;0;0;False;0;False;1;0.08;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;179;-2311.72,-782.6675;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-3934.583,3282.682;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;38;-2039.298,2633.846;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2658.602,1758.019;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;65;-2796.81,1410.345;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;174;-2254.507,996.0104;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-3715.594,3233.367;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;-2215.351,1154.654;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1913.432,2730.562;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;77;-2341.986,2006.852;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;118;-3702.421,3459.323;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1748.932,-867.6765;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;76;-2374.253,1749.125;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;180;-2309.924,-690.8901;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-3492.756,3331.367;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;60;-1771.272,2734.502;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-2096.712,1906.326;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-2032.653,1079.469;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-2136.426,993.7044;Inherit;False;Property;_GlobalWindPower;Global Wind Power;18;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1493.386,-795.2056;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1847.548,992.9334;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CosOpNode;120;-3356.322,3332.908;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;183;-1579.193,1244.932;Inherit;False;705.807;416.543;Comment;4;110;135;136;182;Final Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;185;-1282.189,-800.7764;Inherit;False;FresnelBase;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2502.358,487.3014;Inherit;False;Property;_SmoothnessIntensity;Smoothness Intensity;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-1629.807,2754.183;Inherit;False;TranslucencyBase;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-1846.1,1745.073;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1529.193,1294.932;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2977.489,592.6654;Inherit;False;Property;_AmbientOcclusion;Ambient Occlusion;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-2241.012,-388.9149;Inherit;False;185;FresnelBase;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-3170.203,3237.293;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-2137.835,533.511;Inherit;False;194;TranslucencyBase;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2275.537,382.5274;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-1472.068,1515.821;Inherit;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3355.167,3560.954;Inherit;False;Constant;_BendAmount;Bend Amount;14;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-2234.989,185.2281;Inherit;False;194;TranslucencyBase;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;64;-2146.562,286.9199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;126;-2886.803,3177.599;Inherit;False;Constant;_Vector1;Vector 1;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-2945.388,3364.86;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;210;-1831.297,-282.085;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1304.117,1407.475;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;197;-2606.203,1242.058;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-3282.993,123.8752;Inherit;False;Property;_NormalIntensity;Normal Intensity;7;0;Create;True;0;0;0;False;0;False;0;1;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;80;-2692.831,523.6613;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-1863.966,373.1519;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FaceVariableNode;160;-2881.934,172.231;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;198;-2581.516,862.1125;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;218;-3172.815,2696.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;128;-2662.111,3346.065;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-2515.849,372.1566;Inherit;False;AoBase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;81;-3004.958,-47.00212;Inherit;True;Property;_NormalMap;Normal Map;6;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-1081.217,1398.339;Inherit;False;FinalWind;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;71;-1576.009,1970.198;Inherit;False;1008.786;448.881;Comment;5;108;95;176;87;202;Vertex AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2512.534,596.5235;Inherit;False;Property;_TranslucencyPower;Translucency Power;13;0;Create;True;0;0;0;False;0;False;8;8;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;222;-1861.427,-253.572;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1735.171,284.7313;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1990.066,223.7055;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;219;-2682.774,28.63831;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1819.356,-17.92918;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;199;-1886.413,602.6767;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-1554.674,2233.298;Inherit;False;Property;_VertexAointensity;Vertex Ao intensity;17;0;Create;True;0;0;0;False;0;False;0;0.765;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-1607.707,424.1729;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-2378.557,3479.451;Inherit;False;182;FinalWind;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2620.596,-50.87578;Inherit;False;Property;_AlbedoLightness;Albedo Lightness;2;0;Create;True;0;0;0;True;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-1422.903,2051.479;Inherit;False;175;AoBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;130;-2442.328,3248.885;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;-2697.601,127.7472;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-2702.872,255.3043;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;223;-1823.543,-360.2081;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-2174.395,3359.121;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BlendOpsNode;95;-1221.831,2138.403;Inherit;True;Multiply;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;165;-1453.704,395.6751;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-1484.3,273.0743;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-2484.312,3164.603;Inherit;False;Property;_WindDirection;Wind Direction;19;0;Create;True;0;0;0;False;0;False;1;1.566;1.54;1.6;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;221;-2281.823,19.51141;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;99;-2577.312,-351.4217;Inherit;False;Property;_AlbedoColor;Albedo Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-2350.715,-133.809;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;-2549.198,218.2076;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;98;-1695.579,-170.1936;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-1717.406,-255.3002;Inherit;False;Property;_SpecularPower;Specular Power;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;232;-2562.204,89.58797;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1435.948,-169.2096;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-2205.481,-279.991;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;209;-2149.49,475.3153;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;131;-1965.226,3234.171;Inherit;False;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;220;-1212.969,152.8139;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;163;-2413.745,54.66759;Inherit;False;Property;_NormalBackFaceFixBranch;Normal BackFace Fix (Branch);8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;108;-957.6432,2054.52;Inherit;False;Property;_VertexAo;Vertex Ao;16;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-1278.138,362.998;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-1662.903,3236.542;Inherit;False;TrunkPivotBend;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-1062.349,79.43416;Inherit;False;SpecularOutput;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;-2053.676,-260.9829;Inherit;False;AlbedoOutput;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-1059.852,181.9136;Inherit;False;NormalOutput;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-1072.293,450.3388;Inherit;False;TranslucencyOutput;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;-1068.439,296.751;Inherit;False;OpacityMaskOutput;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;-778.7432,2192.105;Inherit;False;AoOutput;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-1060.506,554.8484;Inherit;False;SmoothnessOutput;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-361.0876,420.0751;Inherit;False;202;AoOutput;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-397.2667,-79.89816;Inherit;False;207;NormalOutput;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-368.5742,509.5815;Inherit;False;169;TrunkPivotBend;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-388.5868,335.2905;Inherit;False;192;SmoothnessOutput;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-389.1656,13.56282;Inherit;False;200;TranslucencyOutput;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-387.9593,108.6467;Inherit;False;215;SpecularOutput;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-397.2633,241.992;Inherit;False;213;OpacityMaskOutput;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-369.2605,-171.6957;Inherit;False;204;AlbedoOutput;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;;0;0;StandardSpecular;Tobyfredson/Tree Leaf Foliage Wind;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;156;0;57;0
WireConnection;158;0;57;0
WireConnection;157;0;156;0
WireConnection;167;0;158;0
WireConnection;149;1;147;0
WireConnection;150;0;157;0
WireConnection;8;0;3;0
WireConnection;8;1;4;0
WireConnection;151;0;150;0
WireConnection;151;1;149;0
WireConnection;16;0;12;0
WireConnection;16;2;8;0
WireConnection;14;0;10;0
WireConnection;14;1;9;0
WireConnection;168;0;167;0
WireConnection;6;0;2;0
WireConnection;21;0;12;0
WireConnection;21;2;14;0
WireConnection;7;0;6;0
WireConnection;159;0;168;0
WireConnection;152;0;151;0
WireConnection;152;1;150;1
WireConnection;152;2;150;2
WireConnection;19;0;16;0
WireConnection;155;0;159;0
WireConnection;155;1;152;0
WireConnection;155;2;153;0
WireConnection;24;1;19;0
WireConnection;24;0;18;0
WireConnection;17;0;7;0
WireConnection;17;1;11;0
WireConnection;28;0;21;0
WireConnection;37;0;24;0
WireConnection;20;0;15;0
WireConnection;20;1;17;0
WireConnection;36;0;28;0
WireConnection;36;1;29;0
WireConnection;177;0;155;0
WireConnection;34;0;2;2
WireConnection;55;0;37;0
WireConnection;55;1;34;0
WireConnection;171;0;2;0
WireConnection;114;0;12;0
WireConnection;217;0;2;2
WireConnection;217;1;36;0
WireConnection;26;0;20;0
WireConnection;91;1;57;0
WireConnection;91;0;177;0
WireConnection;54;0;12;1
WireConnection;54;1;12;3
WireConnection;47;0;39;0
WireConnection;47;1;39;0
WireConnection;63;0;54;0
WireConnection;63;1;47;0
WireConnection;61;0;217;0
WireConnection;61;1;55;0
WireConnection;61;2;2;3
WireConnection;173;0;2;0
WireConnection;49;0;35;0
WireConnection;66;0;50;0
WireConnection;172;0;171;0
WireConnection;181;0;44;3
WireConnection;179;0;91;0
WireConnection;116;0;114;1
WireConnection;116;1;114;3
WireConnection;38;0;27;0
WireConnection;38;1;26;0
WireConnection;67;0;52;2
WireConnection;67;1;53;0
WireConnection;174;0;173;0
WireConnection;117;0;116;0
WireConnection;117;1;115;0
WireConnection;74;0;172;0
WireConnection;74;1;61;0
WireConnection;74;2;65;2
WireConnection;51;0;38;0
WireConnection;51;1;33;0
WireConnection;77;0;63;0
WireConnection;77;1;62;0
WireConnection;59;0;179;0
WireConnection;59;1;49;0
WireConnection;76;0;67;0
WireConnection;76;1;66;0
WireConnection;180;0;181;0
WireConnection;119;0;117;0
WireConnection;119;1;118;2
WireConnection;60;0;51;0
WireConnection;84;0;76;0
WireConnection;84;1;77;0
WireConnection;82;0;174;0
WireConnection;82;1;74;0
WireConnection;75;0;180;0
WireConnection;75;1;59;0
WireConnection;97;0;86;0
WireConnection;97;1;82;0
WireConnection;120;0;119;0
WireConnection;185;0;75;0
WireConnection;194;0;60;0
WireConnection;101;0;65;2
WireConnection;101;1;84;0
WireConnection;110;0;97;0
WireConnection;110;1;101;0
WireConnection;122;0;2;2
WireConnection;122;1;120;0
WireConnection;48;0;44;4
WireConnection;48;1;42;0
WireConnection;64;0;48;0
WireConnection;124;0;122;0
WireConnection;124;1;123;0
WireConnection;210;0;186;0
WireConnection;136;0;135;0
WireConnection;136;1;110;0
WireConnection;197;0;65;1
WireConnection;80;0;44;2
WireConnection;80;1;78;0
WireConnection;72;0;44;3
WireConnection;72;1;196;0
WireConnection;198;0;197;0
WireConnection;218;0;2;2
WireConnection;128;0;124;0
WireConnection;128;1;126;2
WireConnection;175;0;80;0
WireConnection;81;5;73;0
WireConnection;182;0;136;0
WireConnection;222;0;186;0
WireConnection;93;0;210;0
WireConnection;93;1;72;0
WireConnection;70;0;195;0
WireConnection;70;1;64;0
WireConnection;219;0;57;4
WireConnection;85;0;222;0
WireConnection;85;1;70;0
WireConnection;199;0;198;0
WireConnection;111;0;96;0
WireConnection;111;1;93;0
WireConnection;130;0;126;2
WireConnection;130;1;128;0
WireConnection;130;2;218;0
WireConnection;231;0;81;2
WireConnection;231;1;160;0
WireConnection;161;0;81;3
WireConnection;161;1;160;0
WireConnection;223;0;186;0
WireConnection;134;0;184;0
WireConnection;134;1;130;0
WireConnection;95;0;65;1
WireConnection;95;1;176;0
WireConnection;95;2;87;0
WireConnection;140;0;199;0
WireConnection;140;1;111;0
WireConnection;221;0;219;0
WireConnection;103;0;91;0
WireConnection;103;1;92;0
WireConnection;162;0;81;1
WireConnection;162;1;81;2
WireConnection;162;2;161;0
WireConnection;98;0;223;0
WireConnection;98;1;85;0
WireConnection;232;0;81;1
WireConnection;232;1;231;0
WireConnection;232;2;81;3
WireConnection;109;0;212;0
WireConnection;109;1;98;0
WireConnection;105;0;99;0
WireConnection;105;1;103;0
WireConnection;209;0;48;0
WireConnection;131;1;129;0
WireConnection;131;3;134;0
WireConnection;220;0;221;0
WireConnection;163;1;232;0
WireConnection;163;0;162;0
WireConnection;108;1;176;0
WireConnection;108;0;95;0
WireConnection;166;0;140;0
WireConnection;166;1;165;1
WireConnection;166;2;165;2
WireConnection;169;0;131;0
WireConnection;215;0;109;0
WireConnection;204;0;105;0
WireConnection;207;0;163;0
WireConnection;200;0;166;0
WireConnection;213;0;220;0
WireConnection;202;0;108;0
WireConnection;192;0;209;0
WireConnection;0;0;205;0
WireConnection;0;1;206;0
WireConnection;0;2;201;0
WireConnection;0;3;216;0
WireConnection;0;4;193;0
WireConnection;0;5;203;0
WireConnection;0;10;214;0
WireConnection;0;11;170;0
ASEEND*/
//CHKSM=7B16298F4CD8C686D7C7004ECBC0240E72E4EFA4