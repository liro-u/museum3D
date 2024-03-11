// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Grass Foliage"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.4
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		_AlbedoLightness("Albedo Lightness", Range( 0 , 5)) = 1
		[Toggle(_COLORVARIATION_ON)] _ColorVariation("Color Variation", Float) = 0
		_GrassColorVariation("Grass Color Variation", Range( 0 , 5)) = 0.6
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
		_WindSpeed("Wind Speed", Range( 0 , 2)) = 1
		_WindPower("Wind Power", Range( 0 , 0.9)) = 1
		_FlutterFrequency("Flutter Frequency", Range( 0 , 5)) = 2
		_WindAnglexz("Wind Angle (xz)", Range( -200 , 200)) = 20
		_WindAngley("Wind Angle (y)", Range( -100 , 100)) = 20
		[Toggle(_FADEONOFF_ON)] _FadeOnOff("Fade On/Off", Float) = 0
		_CutoutAlphalOD("Cutout Alpha lOD", Float) = 1
		_CameraLength("Camera Length", Float) = 0
		_CameraOffset("Camera Offset", Float) = 0
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
		#pragma shader_feature_local _FADEONOFF_ON
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
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
			float eyeDepth;
		};

		uniform float _GlobalWindPower;
		uniform float _FlutterFrequency;
		uniform float _WindAngley;
		uniform float _WindAnglexz;
		uniform float _WindPower;
		uniform float _WindSpeed;
		uniform sampler2D _NormalMap;
		uniform float _NormalIntensity;
		uniform float4 _AlbedoColor;
		uniform sampler2D _AlbedoMap;
		uniform float _GrassColorVariation;
		uniform float _AlbedoLightness;
		uniform float _TranslucencyPower;
		uniform sampler2D _MaskMap;
		uniform float _TranslucencyRange;
		uniform float4 _TranslucencyColor;
		uniform float _SpecularPower;
		uniform float _SmoothnessIntensity;
		uniform float _AmbientOcclusion;
		uniform float _VertexAointensity;
		uniform float _CameraLength;
		uniform float _CameraOffset;
		uniform float _CutoutAlphalOD;
		uniform float _Cutoff = 0.4;


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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime7 = _Time.y * 0.1;
			float simplePerlin2D34 = snoise( (ase_worldPos*1.0 + float3( ( mulTime7 * float2( -0.5,-0.5 ) ) ,  0.0 )).xy*_FlutterFrequency );
			simplePerlin2D34 = simplePerlin2D34*0.5 + 0.5;
			float temp_output_120_0 = ( ase_vertex3Pos.y + simplePerlin2D34 );
			float gradientNoise14 = GradientNoise((ase_worldPos*1.0 + float3( ( _Time.y * float2( 0,-0.1 ) ) ,  0.0 )).xy,20.0);
			gradientNoise14 = gradientNoise14*0.5 + 0.5;
			float4 temp_cast_6 = (gradientNoise14).xxxx;
			float temp_output_29_0 = ( ase_vertex3Pos.y * 1.2 );
			float3 appendResult141 = (float3(temp_output_120_0 , ( ( CalculateContrast(_WindAngley,temp_cast_6) * 0.2 ) + temp_output_29_0 ).r , ase_vertex3Pos.z));
			float4 temp_cast_9 = (gradientNoise14).xxxx;
			float4 appendResult51 = (float4(( ( CalculateContrast(_WindAnglexz,temp_cast_9) * 0.2 ) + temp_output_29_0 ).r , temp_output_120_0 , ase_vertex3Pos.z , 0.0));
			float4 lerpResult56 = lerp( float4( ase_vertex3Pos , 0.0 ) , ( float4( appendResult141 , 0.0 ) + appendResult51 ) , v.color.g);
			float2 appendResult32 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult35 = (float2(_Time.y , _Time.y));
			float simplePerlin2D48 = snoise( ( appendResult32 + appendResult35 )*_WindSpeed );
			simplePerlin2D48 = simplePerlin2D48*0.5 + 0.5;
			float4 WindOutput253 = ( ( _GlobalWindPower * ( float4( ase_vertex3Pos , 0.0 ) - lerpResult56 ) ) * ( v.color.g * ( pow( ( v.texcoord.xy.y * 0.5 ) , ( 1.0 - _WindPower ) ) * simplePerlin2D48 ) ) );
			v.vertex.xyz += WindOutput253.xyz;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_NormalMap70 = i.uv_texcoord;
			float3 tex2DNode70 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap70 ), _NormalIntensity );
			float3 appendResult259 = (float3(tex2DNode70.r , ( tex2DNode70.g * i.ASEVFace ) , tex2DNode70.b));
			float3 appendResult153 = (float3(tex2DNode70.r , tex2DNode70.g , ( tex2DNode70.b * i.ASEVFace )));
			#ifdef _NORMALBACKFACEFIXBRANCH_ON
				float3 staticSwitch157 = appendResult153;
			#else
				float3 staticSwitch157 = appendResult259;
			#endif
			float3 NormalMapOutput238 = staticSwitch157;
			o.Normal = NormalMapOutput238;
			float2 uv_AlbedoMap33 = i.uv_texcoord;
			float4 tex2DNode33 = tex2D( _AlbedoMap, uv_AlbedoMap33 );
			float4 break183 = tex2DNode33;
			float4 transform173 = mul(unity_ObjectToWorld,float4( 1,1,1,1 ));
			float dotResult4_g17 = dot( transform173.xy , float2( 12.9898,78.233 ) );
			float lerpResult10_g17 = lerp( 0.9 , 1.15 , frac( ( sin( dotResult4_g17 ) * 43758.55 ) ));
			float4 appendResult186 = (float4(( break183.r * lerpResult10_g17 ) , break183.g , break183.b , 0.0));
			float4 lerpResult194 = lerp( tex2DNode33 , appendResult186 , _GrassColorVariation);
			#ifdef _COLORVARIATION_ON
				float4 staticSwitch57 = lerpResult194;
			#else
				float4 staticSwitch57 = tex2DNode33;
			#endif
			float4 AlbedoOutput236 = ( _AlbedoColor * ( staticSwitch57 * _AlbedoLightness ) );
			o.Albedo = AlbedoOutput236.rgb;
			float2 uv_MaskMap59 = i.uv_texcoord;
			float4 tex2DNode59 = tex2D( _MaskMap, uv_MaskMap59 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV42 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode42 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV42, 5.0 ) );
			float4 FresnelBase233 = ( tex2DNode59.b * ( staticSwitch57 * saturate( fresnelNode42 ) ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir75 = normalize( mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz );
			float dotResult83 = dot( ase_worldViewDir , -( ase_worldlightDir + ( objToWorldDir75 * _TranslucencyRange ) ) );
			float4 TranslucencyBase216 = saturate( ( dotResult83 * _TranslucencyColor ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 TranslucencyOutput245 = ( ( _TranslucencyPower * ( FresnelBase233 * ( tex2DNode59.b * TranslucencyBase216 ) ) ) * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a );
			o.Emission = TranslucencyOutput245.rgb;
			float TranslucencyNoC258 = dotResult83;
			float SmoothnessOutput225 = ( tex2DNode59.a * _SmoothnessIntensity );
			float4 lerpResult102 = lerp( FresnelBase233 , ( FresnelBase233 * ( TranslucencyNoC258 + -SmoothnessOutput225 ) ) , tex2DNode70.b);
			float4 SpecularOutput242 = ( _SpecularPower * lerpResult102 );
			o.Specular = SpecularOutput242.rgb;
			o.Smoothness = SmoothnessOutput225;
			float AoBase221 = pow( tex2DNode59.g , _AmbientOcclusion );
			float blendOpSrc108 = i.vertexColor.r;
			float blendOpDest108 = AoBase221;
			float lerpBlendMode108 = lerp(blendOpDest108,( blendOpSrc108 * blendOpDest108 ),_VertexAointensity);
			#ifdef _VERTEXAO_ON
				float staticSwitch109 = ( saturate( lerpBlendMode108 ));
			#else
				float staticSwitch109 = AoBase221;
			#endif
			float AoOutput250 = staticSwitch109;
			o.Occlusion = AoOutput250;
			o.Alpha = 1;
			float cameraDepthFade158 = (( i.eyeDepth -_ProjectionParams.y - _CameraOffset ) / _CameraLength);
			#ifdef _FADEONOFF_ON
				float staticSwitch161 = ( ( 1.0 - cameraDepthFade158 ) * tex2DNode33.a * _CutoutAlphalOD );
			#else
				float staticSwitch161 = tex2DNode33.a;
			#endif
			float GrassDistanceFade246 = staticSwitch161;
			clip( GrassDistanceFade246 - _Cutoff );
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
				float3 customPack1 : TEXCOORD1;
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
				o.customPack1.z = customInputData.eyeDepth;
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
				surfIN.eyeDepth = IN.customPack1.z;
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
39;235;1906;829;3778.317;1027.693;2.519051;True;True
Node;AmplifyShaderEditor.CommentaryNode;22;-4216.001,-571.549;Inherit;False;2029.775;1141.094;;40;245;208;210;236;238;135;207;209;157;126;63;134;89;153;128;73;221;244;217;55;117;152;70;151;113;65;225;57;91;59;227;200;228;201;33;254;255;90;259;260;Base Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;33;-3936.256,-296.3244;Inherit;True;Property;_AlbedoMap;Albedo Map;5;1;[NoScaleOffset];Create;True;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;201;-3646.996,-110.406;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;228;-3898.889,-86.15732;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;195;-5322.509,-573.1503;Inherit;False;1055.403;552.1744;Comment;10;199;194;198;162;186;184;183;180;173;229;Grass Color Variation;0.7504205,1,0,1;0;0
Node;AmplifyShaderEditor.WireNode;229;-4501.689,-114.5986;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1;-5204.375,609.4168;Inherit;False;3036.159;810.4699;;34;121;123;62;56;52;142;51;141;205;29;202;146;118;27;120;45;143;34;23;145;17;14;15;144;24;10;16;5;7;9;4;2;3;18;Vertex Wind_Layer A;0,0.7931032,1,1;0;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;173;-5256.75,-509.8167;Inherit;False;1;0;FLOAT4;1,1,1,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;18;-3994.522,1207.768;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;198;-5061.319,-166.0125;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;88;-3578.179,2291.333;Inherit;False;1436.148;585.5387;Comment;13;216;85;87;86;83;80;84;78;77;79;76;75;258;Translucency Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;183;-5057.661,-397.1574;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector2Node;2;-5115.641,800.054;Inherit;False;Constant;_EdgeFlutterFrequency;Edge Flutter Frequency;14;0;Create;True;0;0;0;True;0;False;0,-0.1;0,-0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;124;-3664.753,2345.522;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-5050.966,702.9636;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;180;-5056.521,-519.6232;Inherit;False;Random Range;-1;;17;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.9;False;3;FLOAT;1.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;200;-3747.219,-429.6998;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-4870.226,758.9711;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-3446.619,2717.69;Inherit;False;Property;_TranslucencyRange;Translucency Range;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-4867.658,-453.7746;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-5055.481,954.0665;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;75;-3444.758,2546.719;Inherit;False;Object;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;162;-4856.865,-242.9268;Inherit;False;Property;_GrassColorVariation;Grass Color Variation;4;0;Create;True;0;0;0;False;0;False;0.6;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-5052.362,1118.497;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;186;-4727.744,-391.0389;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;199;-4520.792,-167.8321;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;79;-3454.489,2346.333;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-3205.12,2639.121;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;10;-4717.022,826.8184;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;9;-5060.922,1218.869;Inherit;False;Constant;_Vector1;Vector 1;12;0;Create;True;0;0;0;True;0;False;-0.5,-0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.NoiseGeneratorNode;14;-4487.37,671.1433;Inherit;True;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-4503.605,999.7039;Inherit;False;Property;_WindAngley;Wind Angle (y);23;0;Create;True;0;0;0;True;0;False;20;10;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-4845.298,1178.182;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;194;-4533.33,-402.1788;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-3063.362,2542.703;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;232;-3371.861,-1102.134;Inherit;False;1173.995;473.4484;Comment;5;66;53;46;42;233;Fresnel Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;145;-4196.605,894.7039;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;80;-2929.528,2541.27;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-3587.063,464.8436;Inherit;False;Property;_SmoothnessIntensity;Smoothness Intensity;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;227;-3722.079,-349.2048;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-4505.262,908.5745;Inherit;False;Property;_WindAnglexz;Wind Angle (xz);22;0;Create;True;0;0;0;True;0;False;20;40;-200;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-3915.083,247.5;Inherit;True;Property;_MaskMap;Mask Map;9;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;84;-3101.632,2389.974;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;24;-4716.532,958.799;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;57;-3523.359,-317.3572;Inherit;False;Property;_ColorVariation;Color Variation;3;0;Create;True;0;0;0;True;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;118;-4545.083,1150.857;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;42;-3321.861,-837.8929;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-4553.096,1250.353;Inherit;False;Property;_FlutterFrequency;Flutter Frequency;21;0;Create;True;0;0;0;True;0;False;2;2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;146;-3954.914,898.6412;Inherit;False;0.2;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;86;-3064.373,2671.478;Inherit;False;Property;_TranslucencyColor;Translucency Color;12;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-3354.915,396.3879;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;23;-4234.978,666.5739;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;83;-2783.8,2473.449;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;29;-3760.063,1054.559;Inherit;False;1.2;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;202;-3662.513,939.6882;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;254;-2514.928,365.3991;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;205;-3803.176,1065.298;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;34;-4233.404,1159.289;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;226;-3447.983,-832.2581;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleNode;27;-3990.62,669.1539;Inherit;False;0.2;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-2651.372,2571.478;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;46;-3081.405,-833.2057;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;11;-3553.389,1504.292;Inherit;False;1373.475;707.0101;;14;21;31;36;64;60;48;50;38;44;37;39;30;35;32;Vertex Wind_Layer B;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-3574.481,887.2444;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;225;-2422.098,77.86255;Inherit;False;SmoothnessOutput;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-3895.451,471.7122;Inherit;False;Property;_AmbientOcclusion;Ambient Occlusion;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;213;-4772.875,1774.564;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-3494.454,2098.178;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;230;-3528.419,-921.5862;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;212;-4800.806,1825.345;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-2917.594,-977.6501;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-3578.439,664.0344;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;-2515.772,2574.105;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;-3548.93,1126.855;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;241;-2139.876,-552.0267;Inherit;False;1452.487;480.2908;Comment;11;242;256;102;100;240;234;95;92;219;235;103;Specular Output;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-2622.327,2444.959;Inherit;False;TranslucencyNoC;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-3271.59,1994.127;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;-3253.517,675.6587;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-2369.981,2567.832;Inherit;False;TranslucencyBase;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-3346.996,1812.752;Inherit;False;Property;_WindPower;Wind Power;20;0;Create;True;0;0;0;False;0;False;1;0.9;0;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-2702.315,-1052.133;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;235;-2086.74,-223.5083;Inherit;False;225;SmoothnessOutput;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;211;-3988.725,-1570.191;Inherit;False;1289.431;412.6073;Comment;8;161;160;169;159;158;170;171;246;Grass Distance Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;-3300.589,2091.127;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;-3260.184,896.5288;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-3472.686,1696.372;Inherit;False;Constant;_WindGradient;Wind Gradient;9;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-3507.724,1565.292;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;117;-3593.754,240.7053;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-3949.725,-1519.191;Inherit;False;Property;_CameraLength;Camera Length;26;0;Create;True;0;0;0;False;0;False;0;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;233;-2443.89,-1049.405;Inherit;False;FresnelBase;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;52;-3210.386,1192.007;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;171;-3947.725,-1392.192;Inherit;False;Property;_CameraOffset;Camera Offset;27;0;Create;True;0;0;0;False;0;False;0;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;92;-1837.567,-192.3403;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-3095.876,2039.412;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-3222.037,1581.95;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-4186.325,22.59504;Inherit;False;Property;_NormalIntensity;Normal Intensity;7;0;Create;True;0;0;0;False;0;False;0;1;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-3001.518,741.1985;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;219;-2081.719,-313.6391;Inherit;False;258;TranslucencyNoC;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3216.794,1904.803;Inherit;False;Property;_WindSpeed;Wind Speed;19;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-3071.449,1805.005;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;255;-2504.132,411.5939;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-3389.697,296.4232;Inherit;False;216;TranslucencyBase;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;48;-2905.422,1830.782;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;50;-2937.689,1573.056;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-3152,243.2303;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FaceVariableNode;151;-3739.403,167.0617;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-1687.712,-263.2478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;234;-1680.675,-416.3944;Inherit;False;233;FresnelBase;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;244;-3157.421,136.3327;Inherit;False;233;FresnelBase;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;56;-2716.511,1032.083;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-2405.176,171.7417;Inherit;False;AoBase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;-2131.984,1522.099;Inherit;False;1202.948;374.0176;Comment;5;109;108;222;111;250;Vertex Ao Switch;1,1,1,1;0;0
Node;AmplifyShaderEditor.CameraDepthFade;158;-3776.299,-1491.247;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;60;False;1;FLOAT;25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;70;-3914.615,-29.38072;Inherit;True;Property;_NormalMap;Normal Map;6;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;159;-3533.299,-1486.946;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;223;-2323.348,1446.469;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;62;-2545.483,928.8225;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-3566.588,-209.3899;Inherit;False;Property;_AlbedoLightness;Albedo Lightness;2;0;Create;True;0;0;0;True;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;209;-3556.401,-501.6639;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2660.146,1730.257;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-3589.12,141.7624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-2624.881,837.0327;Inherit;False;Property;_GlobalWindPower;Global Wind Power;18;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1510.919,-262.3407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-3075.262,42.58302;Inherit;False;Property;_TranslucencyPower;Translucency Power;13;0;Create;True;0;0;0;False;0;False;8;15;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;240;-1415.469,-356.7913;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-2042.559,1647.606;Inherit;False;221;AoBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-3593.581,-63.55314;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-3678.579,-1353.1;Inherit;False;Property;_CutoutAlphalOD;Cutout Alpha lOD;25;0;Create;True;0;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-2081.984,1749.687;Inherit;False;Property;_VertexAointensity;Vertex Ao intensity;17;0;Create;True;0;0;0;False;0;False;0;0.52;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-2927.334,184.1541;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;210;-3536.411,-497.022;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;-3454.683,63.29012;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-2777.548,105.4842;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;214;-2115.338,1122.344;Inherit;False;285;304;Comment;1;69;Final Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;207;-2778.057,219.2164;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;256;-1444.223,-471.0932;Inherit;False;Property;_SpecularPower;Specular Power;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;259;-3450.144,-105.0254;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-2423.016,1605.542;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;128;-3491.881,-495.1998;Inherit;False;Property;_AlbedoColor;Albedo Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-3267.356,-259.0565;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-2330.121,876.3655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;-3373.684,-1399.111;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;102;-1297.014,-263.5796;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;108;-1759.883,1605.814;Inherit;True;Multiply;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2065.338,1172.344;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-3126,-364.2295;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;161;-3227.573,-1360.258;Inherit;False;Property;_FadeOnOff;Fade On/Off;24;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;109;-1458.316,1696.129;Inherit;False;Property;_VertexAo;Vertex Ao;16;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;157;-3287.06,-76.03461;Inherit;False;Property;_NormalBackFaceFixBranch;Normal BackFace Fix (Branch);8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1094.177,-410.1683;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-2593.239,148.5372;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-910.6758,-407.6689;Inherit;False;SpecularOutput;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;-2432.417,-25.25538;Inherit;False;TranslucencyOutput;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;238;-2422.585,-112.1982;Inherit;False;NormalMapOutput;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;236;-2415.934,-205.3391;Inherit;False;AlbedoOutput;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;250;-1215.649,1711.598;Inherit;False;AoOutput;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;246;-2993.609,-1357.844;Inherit;False;GrassDistanceFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;253;-1798.304,1176.395;Inherit;False;WindOutput;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;252;-303.4424,501.9265;Inherit;False;253;WindOutput;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;237;-332.6181,-147.9459;Inherit;False;236;AlbedoOutput;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;-308.5127,322.7268;Inherit;False;250;AoOutput;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-331.347,141.8311;Inherit;False;242;SpecularOutput;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-354.1431,409.0378;Inherit;False;246;GrassDistanceFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;239;-331.08,-54.5589;Inherit;False;238;NormalMapOutput;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-356.0674,240.2529;Inherit;False;225;SmoothnessOutput;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;-352.2792,53.53506;Inherit;False;245;TranslucencyOutput;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;;0;0;StandardSpecular;Tobyfredson/Grass Foliage;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.4;True;True;0;False;TransparentCutout;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;201;0;33;0
WireConnection;228;0;201;0
WireConnection;229;0;228;0
WireConnection;198;0;229;0
WireConnection;183;0;198;0
WireConnection;124;0;18;0
WireConnection;180;1;173;0
WireConnection;200;0;33;0
WireConnection;4;0;3;0
WireConnection;4;1;2;0
WireConnection;184;0;183;0
WireConnection;184;1;180;0
WireConnection;75;0;124;0
WireConnection;186;0;184;0
WireConnection;186;1;183;1
WireConnection;186;2;183;2
WireConnection;199;0;200;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;10;0;5;0
WireConnection;10;2;4;0
WireConnection;14;0;10;0
WireConnection;16;0;7;0
WireConnection;16;1;9;0
WireConnection;194;0;199;0
WireConnection;194;1;186;0
WireConnection;194;2;162;0
WireConnection;78;0;79;0
WireConnection;78;1;77;0
WireConnection;145;1;14;0
WireConnection;145;0;144;0
WireConnection;80;0;78;0
WireConnection;227;0;194;0
WireConnection;24;0;5;0
WireConnection;24;2;16;0
WireConnection;57;1;33;0
WireConnection;57;0;227;0
WireConnection;118;0;24;0
WireConnection;146;0;145;0
WireConnection;90;0;59;4
WireConnection;90;1;91;0
WireConnection;23;1;14;0
WireConnection;23;0;15;0
WireConnection;83;0;84;0
WireConnection;83;1;80;0
WireConnection;29;0;18;2
WireConnection;202;0;146;0
WireConnection;254;0;90;0
WireConnection;205;0;18;2
WireConnection;34;0;118;0
WireConnection;34;1;17;0
WireConnection;226;0;57;0
WireConnection;27;0;23;0
WireConnection;87;0;83;0
WireConnection;87;1;86;0
WireConnection;46;0;42;0
WireConnection;45;0;27;0
WireConnection;45;1;29;0
WireConnection;225;0;254;0
WireConnection;213;0;5;1
WireConnection;230;0;59;3
WireConnection;212;0;5;3
WireConnection;53;0;226;0
WireConnection;53;1;46;0
WireConnection;120;0;205;0
WireConnection;120;1;34;0
WireConnection;85;0;87;0
WireConnection;143;0;202;0
WireConnection;143;1;29;0
WireConnection;258;0;83;0
WireConnection;32;0;213;0
WireConnection;32;1;212;0
WireConnection;141;0;120;0
WireConnection;141;1;143;0
WireConnection;141;2;18;3
WireConnection;216;0;85;0
WireConnection;66;0;230;0
WireConnection;66;1;53;0
WireConnection;35;0;21;0
WireConnection;35;1;21;0
WireConnection;51;0;45;0
WireConnection;51;1;120;0
WireConnection;51;2;18;3
WireConnection;117;0;59;2
WireConnection;117;1;113;0
WireConnection;233;0;66;0
WireConnection;92;0;235;0
WireConnection;44;0;32;0
WireConnection;44;1;35;0
WireConnection;38;0;31;2
WireConnection;38;1;36;0
WireConnection;142;0;141;0
WireConnection;142;1;51;0
WireConnection;39;0;30;0
WireConnection;255;0;117;0
WireConnection;48;0;44;0
WireConnection;48;1;37;0
WireConnection;50;0;38;0
WireConnection;50;1;39;0
WireConnection;89;0;59;3
WireConnection;89;1;217;0
WireConnection;95;0;219;0
WireConnection;95;1;92;0
WireConnection;56;0;18;0
WireConnection;56;1;142;0
WireConnection;56;2;52;2
WireConnection;221;0;255;0
WireConnection;158;0;170;0
WireConnection;158;1;171;0
WireConnection;70;5;65;0
WireConnection;159;0;158;0
WireConnection;223;0;52;1
WireConnection;62;0;18;0
WireConnection;62;1;56;0
WireConnection;209;0;33;4
WireConnection;60;0;50;0
WireConnection;60;1;48;0
WireConnection;152;0;70;3
WireConnection;152;1;151;0
WireConnection;100;0;234;0
WireConnection;100;1;95;0
WireConnection;240;0;234;0
WireConnection;260;0;70;2
WireConnection;260;1;151;0
WireConnection;134;0;244;0
WireConnection;134;1;89;0
WireConnection;210;0;33;4
WireConnection;153;0;70;1
WireConnection;153;1;70;2
WireConnection;153;2;152;0
WireConnection;135;0;63;0
WireConnection;135;1;134;0
WireConnection;259;0;70;1
WireConnection;259;1;260;0
WireConnection;259;2;70;3
WireConnection;64;0;52;2
WireConnection;64;1;60;0
WireConnection;73;0;57;0
WireConnection;73;1;55;0
WireConnection;121;0;123;0
WireConnection;121;1;62;0
WireConnection;160;0;159;0
WireConnection;160;1;209;0
WireConnection;160;2;169;0
WireConnection;102;0;240;0
WireConnection;102;1;100;0
WireConnection;102;2;70;3
WireConnection;108;0;223;0
WireConnection;108;1;222;0
WireConnection;108;2;111;0
WireConnection;69;0;121;0
WireConnection;69;1;64;0
WireConnection;126;0;128;0
WireConnection;126;1;73;0
WireConnection;161;1;210;0
WireConnection;161;0;160;0
WireConnection;109;1;222;0
WireConnection;109;0;108;0
WireConnection;157;1;259;0
WireConnection;157;0;153;0
WireConnection;103;0;256;0
WireConnection;103;1;102;0
WireConnection;208;0;135;0
WireConnection;208;1;207;1
WireConnection;208;2;207;2
WireConnection;242;0;103;0
WireConnection;245;0;208;0
WireConnection;238;0;157;0
WireConnection;236;0;126;0
WireConnection;250;0;109;0
WireConnection;246;0;161;0
WireConnection;253;0;69;0
WireConnection;0;0;237;0
WireConnection;0;1;239;0
WireConnection;0;2;248;0
WireConnection;0;3;243;0
WireConnection;0;4;249;0
WireConnection;0;5;251;0
WireConnection;0;10;247;0
WireConnection;0;11;252;0
ASEEND*/
//CHKSM=5B14AA41E5AB5D46BCFBD691C2476EE1DC6E654B