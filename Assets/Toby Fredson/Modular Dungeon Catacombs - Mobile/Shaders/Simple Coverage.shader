// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Simple Coverage"
{
	Properties
	{
		[NoScaleOffset][SingleLineTexture]_Albedo("Albedo", 2D) = "white" {}
		[NoScaleOffset][Normal][SingleLineTexture]_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range( -3 , 3)) = 1
		[NoScaleOffset][SingleLineTexture]_MetallicAoGloss("Metallic/Ao/Gloss", 2D) = "white" {}
		_Float3("Metallic", Range( 0 , 1)) = 0
		_Float5("Ambient Occlusion", Range( 0 , 1)) = 0
		_Float4("Smoothness", Range( 0 , 1)) = 0
		_Tiling("Tiling", Vector) = (1,1,0,0)
		_Offset("Offset", Vector) = (1,1,0,0)
		[NoScaleOffset][SingleLineTexture]_CoverageAlbedo("Coverage Albedo", 2D) = "white" {}
		[NoScaleOffset][Normal][SingleLineTexture]_CoverageNormal("Coverage Normal", 2D) = "bump" {}
		_Float6("Smoothness Coverage", Range( 0 , 1)) = 0
		_TilingTriplanar("Tiling Triplanar", Vector) = (1,1,0,0)
		_CoverageAmount("Coverage Amount", Range( 0 , 5)) = 1.2
		_CoverageFalloff("Coverage Falloff", Range( 1 , 5)) = 5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_TEXTURE_PARAMS(textureName) textureName

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
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _NormalMap;
		uniform float2 _Tiling;
		uniform float2 _Offset;
		uniform float _NormalIntensity;
		uniform sampler2D _CoverageNormal;
		uniform float2 _TilingTriplanar;
		uniform float _CoverageFalloff;
		uniform float _CoverageAmount;
		uniform sampler2D _Albedo;
		uniform sampler2D _CoverageAlbedo;
		uniform sampler2D _MetallicAoGloss;
		uniform float _Float3;
		uniform float _Float4;
		uniform float _Float6;
		uniform float _Float5;


		inline float3 TriplanarSamplingSNF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			xNorm.xyz = half3( UnpackNormal( xNorm ).xy * float2( nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz = half3( UnpackNormal( yNorm ).xy * float2( nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSamplingSF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord147 = i.uv_texcoord * _Tiling + _Offset;
			float2 TileUVs232 = uv_TexCoord147;
			float3 NormalMapMain249 = UnpackScaleNormal( tex2D( _NormalMap, TileUVs232 ), _NormalIntensity );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar151 = TriplanarSamplingSNF( _CoverageNormal, ase_worldPos, ase_worldNormal, _CoverageFalloff, _TilingTriplanar, 1.0, 0 );
			float3 tanTriplanarNormal151 = mul( ase_worldToTangent, triplanar151 );
			float3 TriplanarNormal259 = tanTriplanarNormal151;
			float3 lerpResult152 = lerp( NormalMapMain249 , TriplanarNormal259 , saturate( ( ase_worldNormal.y * _CoverageAmount ) ));
			float temp_output_174_0 = saturate( ( (WorldNormalVector( i , lerpResult152 )).y * _CoverageAmount ) );
			float3 lerpResult185 = lerp( lerpResult152 , BlendNormals( NormalMapMain249 , TriplanarNormal259 ) , temp_output_174_0);
			o.Normal = lerpResult185;
			float4 AlbedoMapMain250 = tex2D( _Albedo, TileUVs232 );
			float4 triplanar157 = TriplanarSamplingSF( _CoverageAlbedo, ase_worldPos, ase_worldNormal, _CoverageFalloff, _TilingTriplanar, 1.0, 0 );
			float4 TriplanarAlbedo258 = triplanar157;
			float4 lerpResult182 = lerp( AlbedoMapMain250 , TriplanarAlbedo258 , temp_output_174_0);
			o.Albedo = lerpResult182.xyz;
			float4 tex2DNode156 = tex2D( _MetallicAoGloss, TileUVs232 );
			o.Metallic = ( tex2DNode156.r * _Float3 );
			float lerpResult180 = lerp( ( tex2DNode156.a * _Float4 ) , ( triplanar157.w * _Float6 ) , temp_output_174_0);
			o.Smoothness = lerpResult180;
			o.Occlusion = pow( tex2DNode156.g , _Float5 );
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
Version=18301
0;8;1920;1011;4071.06;1141.804;3.987697;True;True
Node;AmplifyShaderEditor.CommentaryNode;135;-1833.503,237.896;Inherit;False;698.2522;375.7902;Comment;4;232;147;139;137;Tile UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;137;-1799.321,287.896;Float;False;Property;_Tiling;Tiling;7;0;Create;True;0;0;False;0;False;1,1;3,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;139;-1803.134,458.6121;Float;False;Property;_Offset;Offset;8;0;Create;True;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;-1608.384,391.6138;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;136;-2048.962,678.8014;Inherit;False;1136.195;870.1304;Comment;11;245;244;157;155;151;141;146;142;143;258;259;Triplanar Setup;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;-1351.712,428.1089;Inherit;False;TileUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1994.353,1432.386;Float;False;Property;_CoverageFalloff;Coverage Falloff;14;0;Create;True;0;0;False;0;False;5;5;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;146;-1962.72,1287.84;Inherit;False;Property;_TilingTriplanar;Tiling Triplanar;12;0;Create;True;0;0;False;0;False;1,1;0.3,0.3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;144;-1097.212,549.9584;Inherit;False;Property;_NormalIntensity;Normal Intensity;2;0;Create;True;0;0;False;0;False;1;1;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;235;-1092.555,410.1677;Inherit;False;232;TileUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;141;-1958.859,1131.313;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;142;-2002.971,926.3994;Float;True;Property;_CoverageNormal;Coverage Normal;10;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;False;0;False;None;442f7689e3324834cba4501cbad18ee1;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WorldNormalVector;140;-699.523,612.2037;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;138;-778.5955,775.5529;Float;False;Property;_CoverageAmount;Coverage Amount;13;0;Create;True;0;0;False;0;False;1.2;1.2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;151;-1661.573,1089.466;Inherit;True;Spherical;World;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;False;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;2;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;150;-793.7186,416.2023;Inherit;True;Property;_NormalMap;Normal Map;1;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;bdea2a62c97f39d47a56911d9aad747e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-1181.642,1103.078;Inherit;False;TriplanarNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-500.7699,683.6512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;249;-464.5896,312.039;Inherit;False;NormalMapMain;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;149;-363.4787,690.4284;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;-427.0553,591.8705;Inherit;False;249;NormalMapMain;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-428.2945,499.5204;Inherit;False;259;TriplanarNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;265;-877.0776,662.6352;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;148;-194.8828,592.1412;Inherit;False;234;206;Main Merged Normal;1;152;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;155;-1992.95,724.1276;Float;True;Property;_CoverageAlbedo;Coverage Albedo;9;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;False;0;False;None;79abe30ac7e3ffa4384f5f7bdf6514f3;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;152;-144.8833,642.1418;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;264;-878.7186,886.8894;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;223;-791.3536,209.4143;Inherit;True;Property;_Albedo;Albedo;0;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;963fbb6ffffbf5d49a610ff7a315ca5e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;156;-774.1934,879.3931;Inherit;True;Property;_MetallicAoGloss;Metallic/Ao/Gloss;3;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;b1ea955eb7a29044da6ca9d7f8b72cea;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;157;-1691.436,740.2386;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;0;None;Bot Texture 0;_BotTexture0;white;1;None;Triplanar Sampler;False;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;2;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;154;59.5744,746.5861;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;244;-1583.511,948.9141;Float;False;Property;_Float6;Smoothness Coverage;11;0;Create;False;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;161;-435.2624,1291.429;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-1181.109,758.6534;Inherit;False;TriplanarAlbedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;256.153,767.3806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-757.6361,1078.677;Float;False;Property;_Float4;Smoothness;6;0;Create;False;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;250;-461.0155,225.4337;Inherit;False;AlbedoMapMain;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;247;-232.5389,1339.713;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-433.9305,1065.485;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;245;-1295.804,903.3425;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;303.6838,490.3542;Inherit;False;258;TriplanarAlbedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;177;586.6612,387.9555;Inherit;False;234;206;Albedo Output;1;182;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;175;604.5737,854.6277;Inherit;False;219;183;Metallic Output;1;183;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendNormalsNode;168;-189.4635,475.0687;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;163;603.6033,1297.806;Inherit;False;230;183;AO Output;1;178;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;596.3203,1063.69;Inherit;False;234;206;Smoothness Output;1;180;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;255;588.6985,623.037;Inherit;False;234;206;Normal Map Output;1;185;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;300.865,394.8387;Inherit;False;250;AlbedoMapMain;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;174;390.7629,769.7995;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;276.5143,1420.691;Float;False;Property;_Float5;Ambient Occlusion;5;0;Create;False;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;247.4241,993.5258;Float;False;Property;_Float3;Metallic;4;0;Create;False;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;180;646.3202,1113.691;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;185;640.0741,687.5369;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;182;636.6612,437.9536;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;654.5736,904.6278;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;178;653.6031,1347.806;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;926.938,702.4413;Float;False;True;-1;2;;0;0;Standard;Tobyfredson/Simple Coverage;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;147;0;137;0
WireConnection;147;1;139;0
WireConnection;232;0;147;0
WireConnection;151;0;142;0
WireConnection;151;9;141;0
WireConnection;151;3;146;0
WireConnection;151;4;143;0
WireConnection;150;1;235;0
WireConnection;150;5;144;0
WireConnection;259;0;151;0
WireConnection;145;0;140;2
WireConnection;145;1;138;0
WireConnection;249;0;150;0
WireConnection;149;0;145;0
WireConnection;265;0;235;0
WireConnection;152;0;254;0
WireConnection;152;1;263;0
WireConnection;152;2;149;0
WireConnection;264;0;265;0
WireConnection;223;1;235;0
WireConnection;156;1;264;0
WireConnection;157;0;155;0
WireConnection;157;9;141;0
WireConnection;157;3;146;0
WireConnection;157;4;143;0
WireConnection;154;0;152;0
WireConnection;161;0;156;2
WireConnection;258;0;157;0
WireConnection;160;0;154;2
WireConnection;160;1;138;0
WireConnection;250;0;223;0
WireConnection;247;0;161;0
WireConnection;179;0;156;4
WireConnection;179;1;159;0
WireConnection;245;0;157;4
WireConnection;245;1;244;0
WireConnection;168;0;254;0
WireConnection;168;1;263;0
WireConnection;174;0;160;0
WireConnection;180;0;179;0
WireConnection;180;1;245;0
WireConnection;180;2;174;0
WireConnection;185;0;152;0
WireConnection;185;1;168;0
WireConnection;185;2;174;0
WireConnection;182;0;256;0
WireConnection;182;1;262;0
WireConnection;182;2;174;0
WireConnection;183;0;156;1
WireConnection;183;1;166;0
WireConnection;178;0;247;0
WireConnection;178;1;158;0
WireConnection;0;0;182;0
WireConnection;0;1;185;0
WireConnection;0;3;183;0
WireConnection;0;4;180;0
WireConnection;0;5;178;0
ASEEND*/
//CHKSM=C22984672F0B8BE07661F23B7575892C70FB98BA