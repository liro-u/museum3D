// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Torch Flame"
{
	Properties
	{
		[NoScaleOffset]_BaseFlame("Base Flame", 2D) = "white" {}
		_Brightnessmultiply("Brightness multiply", Range( 0 , 10)) = 0
		[NoScaleOffset]_NoiseTexture("Noise Texture", 2D) = "white" {}
		_Color0("Color 0", Color) = (1,0.4313726,0,1)
		_Color1("Color 1", Color) = (1,0.1058824,0,1)
		_Color2("Color 2", Color) = (0,1,0.145098,1)
		_Color3("Color 3", Color) = (0.7450981,0,0.4313726,1)
		_Flamespeed("Flame speed", Float) = 0
		_NoiseScale("Noise Scale", Float) = 1
		[NoScaleOffset]_AlphaMask("Alpha Mask", 2D) = "white" {}
		[NoScaleOffset]_FastFlame("Fast Flame", 2D) = "white" {}
		[NoScaleOffset]_BlazeParticles("Blaze Particles", 2D) = "white" {}
		_DepthFadeAmount("Depth Fade Amount", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Overlay+0" "ForceNoShadowCasting" = "True" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend One One
		
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma exclude_renderers d3d11_9x 
		#pragma surface surf StandardSpecular keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float2 uv_texcoord;
		};

		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFadeAmount;
		uniform sampler2D _BlazeParticles;
		uniform sampler2D _FastFlame;
		uniform float _Brightnessmultiply;
		uniform float4 _Color0;
		uniform sampler2D _BaseFlame;
		uniform sampler2D _NoiseTexture;
		uniform float _Flamespeed;
		uniform float _NoiseScale;
		uniform float4 _Color1;
		uniform float4 _Color2;
		uniform float4 _Color3;
		uniform sampler2D _AlphaMask;


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


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


		float2 voronoihash140( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi140( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash140( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			//Calculate new billboard vertex position and normal;
			float3 upCamVec = normalize ( UNITY_MATRIX_V._m10_m11_m12 );
			float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
			float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
			float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
			v.normal = normalize( mul( float4( v.normal , 0 ), rotationCamMatrix )).xyz;
			v.tangent.xyz = normalize( mul( float4( v.tangent.xyz , 0 ), rotationCamMatrix )).xyz;
			v.vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
			v.vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
			v.vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
			v.vertex = mul( v.vertex, rotationCamMatrix );
			v.vertex.xyz += unity_ObjectToWorld._m03_m13_m23;
			//Need to nullify rotation inserted by generated surface shader;
			v.vertex = mul( unity_WorldToObject, v.vertex );
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth155 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth155 = saturate( abs( ( screenDepth155 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeAmount ) ) );
			Gradient gradient131 = NewGradient( 0, 5, 3, float4( 0, 0, 0, 0 ), float4( 1, 0.5159165, 0.3254902, 0.2 ), float4( 1, 0.9251295, 0.5417691, 0.6529488 ), float4( 1, 0.9982066, 0.5803922, 0.9029374 ), float4( 1, 1, 1, 1 ), 0, 0, 0, float2( 1, 0 ), float2( 1, 0.282353 ), float2( 1, 1 ), 0, 0, 0, 0, 0 );
			float3 ase_worldPos = i.worldPos;
			float2 appendResult47 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 temp_output_54_0 = ( appendResult47 * 0.1 );
			float2 uv_TexCoord124 = i.uv_texcoord * float2( 0.6,0.6 );
			float2 panner127 = ( 0.3 * _Time.y * float2( 0.5,-2 ) + ( temp_output_54_0 + uv_TexCoord124 ));
			float4 tex2DNode128 = tex2D( _BlazeParticles, panner127 );
			float2 uv_TexCoord125 = i.uv_texcoord * float2( 0.5,0.5 ) + float2( 0.35,0.4 );
			float2 panner126 = ( 0.8 * _Time.y * float2( 0,-1 ) + ( temp_output_54_0 + uv_TexCoord125 ));
			float4 tex2DNode129 = tex2D( _BlazeParticles, panner126 );
			Gradient gradient109 = NewGradient( 0, 4, 3, float4( 0.1415094, 0.02096804, 0, 0 ), float4( 1, 0.5159165, 0.3254902, 0.3353018 ), float4( 1, 0.9982066, 0.5803922, 0.5882353 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 0.282353 ), float2( 1, 1 ), 0, 0, 0, 0, 0 );
			float2 uv_TexCoord112 = i.uv_texcoord * float2( 0.6,0.6 );
			float2 panner110 = ( 0.3 * _Time.y * float2( 0.5,-2 ) + ( temp_output_54_0 + uv_TexCoord112 ));
			float4 tex2DNode105 = tex2D( _FastFlame, panner110 );
			float2 uv_TexCoord116 = i.uv_texcoord * float2( 0.5,0.5 ) + float2( 0.35,0.4 );
			float2 panner114 = ( 0.8 * _Time.y * float2( 0,-1 ) + ( temp_output_54_0 + uv_TexCoord116 ));
			float4 tex2DNode106 = tex2D( _FastFlame, panner114 );
			Gradient gradient1 = NewGradient( 0, 4, 3, float4( 0.1415094, 0.02096804, 0, 0 ), float4( 1, 0.5159165, 0.3254902, 0.3353018 ), float4( 1, 0.9982066, 0.5803922, 0.5882353 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 0.282353 ), float2( 1, 1 ), 0, 0, 0, 0, 0 );
			float2 appendResult5 = (float2(0.0 , -1.5));
			float2 uv_TexCoord7 = i.uv_texcoord * float2( 3,2 );
			float2 panner13 = ( 1.0 * _Time.y * appendResult5 + ( temp_output_54_0 + ( 1.22 * uv_TexCoord7 ) ));
			float simplePerlin2D20 = snoise( panner13 );
			simplePerlin2D20 = simplePerlin2D20*0.5 + 0.5;
			float2 appendResult12 = (float2(0.0 , -1.0));
			float2 panner14 = ( 1.0 * _Time.y * appendResult12 + ( temp_output_54_0 + ( uv_TexCoord7 * 0.5 ) ));
			float simplePerlin2D21 = snoise( panner14 );
			simplePerlin2D21 = simplePerlin2D21*0.5 + 0.5;
			float2 appendResult56 = (float2(-_Flamespeed , -_Flamespeed));
			float2 panner57 = ( 1.0 * _Time.y * appendResult56 + ( temp_output_54_0 + ( i.uv_texcoord * _NoiseScale ) ));
			float4 tex2DNode73 = tex2D( _BaseFlame, ( i.uv_texcoord + ( i.uv_texcoord.y * ( (tex2D( _NoiseTexture, panner57 )).g - 0.2 ) * i.uv_texcoord.y ) ) );
			float4 blendOpSrc92 = saturate( ( SampleGradient( gradient109, ( tex2DNode105 + tex2DNode106 ).r ) + SampleGradient( gradient1, ( simplePerlin2D20 * simplePerlin2D21 ) ) ) );
			float4 blendOpDest92 = ( _Brightnessmultiply * ( ( _Color0 * tex2DNode73.r ) + ( _Color1 * tex2DNode73.g ) + ( tex2DNode73.b * _Color2 ) + ( tex2DNode73.a * _Color3 ) ) );
			float2 uv_AlphaMask90 = i.uv_texcoord;
			float4 tex2DNode90 = tex2D( _AlphaMask, uv_AlphaMask90 );
			float4 lerpBlendMode92 = lerp(blendOpDest92,(( blendOpDest92 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest92 ) * ( 1.0 - blendOpSrc92 ) ) : ( 2.0 * blendOpDest92 * blendOpSrc92 ) ),( 1.0 - tex2DNode90 ).r);
			float4 blendOpSrc139 = SampleGradient( gradient131, ( tex2DNode128 + tex2DNode129 ).r );
			float4 blendOpDest139 = ( saturate( lerpBlendMode92 ));
			float time140 = 0.0;
			float2 voronoiSmoothId140 = 0;
			float2 coords140 = i.uv_texcoord * 1.0;
			float2 id140 = 0;
			float2 uv140 = 0;
			float voroi140 = voronoi140( coords140, time140, id140, uv140, 0, voronoiSmoothId140 );
			float4 lerpBlendMode139 = lerp(blendOpDest139,( blendOpSrc139 + blendOpDest139 ),( tex2DNode90 + ( 6.2 * ( -0.88 + ( 1.0 - voroi140 ) ) ) ).r);
			o.Emission = ( distanceDepth155 * ( saturate( lerpBlendMode139 )) ).rgb;
			float temp_output_158_0 = 0.0;
			float3 temp_cast_5 = (temp_output_158_0).xxx;
			o.Specular = temp_cast_5;
			o.Smoothness = temp_output_158_0;
			o.Alpha = 1;
		}

		ENDCG
	}
}
/*ASEBEGIN
Version=18935
7;119;1906;900;2440.727;1144.965;2.897032;True;True
Node;AmplifyShaderEditor.CommentaryNode;81;-3072.893,944.1064;Inherit;False;3305.431;1216.579;Comment;23;79;78;80;73;61;65;62;59;58;57;55;56;52;53;49;51;50;60;67;66;63;64;45;Base Flame;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-3025.604,1007.041;Inherit;False;673.9661;307.9057;World Space variation;4;54;48;47;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;46;-2975.604,1057.041;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;47;-2729.162,1075.998;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-2848.22,1341.885;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;51;-2784.119,1611.421;Inherit;False;Property;_Flamespeed;Flame speed;8;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2797.011,1485.385;Inherit;False;Property;_NoiseScale;Noise Scale;9;0;Create;True;0;0;0;False;0;False;1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2724.788,1199.946;Inherit;False;Constant;_Float6;Float 6;5;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-2520.639,1118.286;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;53;-2609.776,1691.427;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-2596.579,1422.466;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-2390.495,1359.937;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;56;-2405.373,1686.076;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;57;-2191.657,1453.849;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;104;-2426.847,16.08857;Inherit;False;2036.451;781.509;Flame Animation 2;21;103;4;8;7;3;6;11;9;5;101;100;12;14;13;20;21;22;1;88;90;95;Slow Flame;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2225.779,256.5869;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;1.22;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-2313.115,371.0726;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;3,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;121;-2419.758,-785.2353;Inherit;False;1977.936;729.7361;Fast Flame;12;108;112;116;110;114;106;105;109;115;107;148;149;Fast Flame;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2216.337,551.6528;Inherit;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;58;-2003.081,1429.707;Inherit;True;Property;_NoiseTexture;Noise Texture;3;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-2002.242,351.8699;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;103;-2376.847,586.5317;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;116;-2324.192,-259.1771;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0.35,0.4;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-2225.779,157.4448;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;-1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;151;-2928.858,109.9087;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;59;-1733.974,1695.051;Inherit;True;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;112;-2331.358,-615.9479;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.6,0.6;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;102;-2698.98,455.7368;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2216.337,650.795;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;150;-3049.075,67.83262;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1987.368,536.9648;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;149;-2093.294,-521.8884;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;-1993.27,158.6252;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-1829.67,473.3157;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-1994.45,662.5977;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-1471.206,1779.839;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-1681.957,1421.245;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-1848.454,299.8766;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-2098.937,-333.5205;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;110;-1938.239,-559.2572;Inherit;True;3;0;FLOAT2;1,1;False;2;FLOAT2;0.5,-2;False;1;FLOAT;0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;13;-1672.532,160.5262;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;123;-2421.244,-1594.994;Inherit;False;1977.936;729.7361;Blaze Particles;12;133;132;131;130;129;128;127;126;125;124;152;153;Blaze Particles;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;14;-1662.574,501.8289;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;114;-1913.039,-310.9333;Inherit;True;3;0;FLOAT2;1,1;False;2;FLOAT2;0,-1;False;1;FLOAT;0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1355.838,1625.217;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;67;-723.4177,1050.806;Inherit;False;457.4534;257;R core col;2;75;68;;1,0,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;-2353.393,-1405.533;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.6,0.6;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;66;-762.2827,1883.056;Inherit;False;526.0117;261.1976;Blue;2;74;70;;0,0.1724138,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;106;-1494.161,-285.4992;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;105;None;None;True;0;False;white;Auto;False;Instance;105;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;63;-730.3889,1323.744;Inherit;False;475.6421;280.942;Green;2;77;69;;0,1,0.1724138,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;125;-2359.112,-1052.666;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0.35,0.4;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;105;-1550.776,-547.2102;Inherit;True;Property;_FastFlame;Fast Flame;11;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;21;-1381.665,460.459;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;20;-1394.27,193.899;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-757.8022,1613.511;Inherit;False;526.0117;261.1976;Blue;2;76;72;;0,0.1724138,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-1254.305,1472.685;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GradientNode;1;-1384.302,112.9651;Inherit;False;0;4;3;0.1415094,0.02096804,0,0;1,0.5159165,0.3254902,0.3353018;1,0.9982066,0.5803922,0.5882353;1,1,1,1;1,0;1,0.282353;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;153;-2106.261,-1046.927;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;70;-712.2827,1937.254;Inherit;False;Property;_Color3;Color 3;7;0;Create;True;0;0;0;False;0;False;0.7450981,0,0.4313726,1;0.745283,0,0.4311413,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;68;-673.4178,1100.806;Inherit;False;Property;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;1,0.4313726,0,1;1,0.4313723,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;69;-680.3892,1373.745;Inherit;False;Property;_Color1;Color 1;5;0;Create;True;0;0;0;False;0;False;1,0.1058824,0,1;1,0.1058811,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;72;-707.8022,1667.709;Inherit;False;Property;_Color2;Color 2;6;0;Create;True;0;0;0;False;0;False;0,1,0.145098,1;0,1,0.1433053,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-2093.261,-1322.927;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;73;-1097.516,1478.066;Inherit;True;Property;_BaseFlame;Base Flame;1;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-1060.046,-735.2353;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1126.841,327.0561;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;109;-1085.007,-499.6427;Inherit;False;0;4;3;0.1415094,0.02096804,0,0;1,0.5159165,0.3254902,0.3353018;1,0.9982066,0.5803922,0.5882353;1,1,1,1;1,0;1,0.282353;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.VoronoiNode;140;-375.4698,666.3511;Inherit;False;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-400.7904,1663.511;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-363.3094,785.9236;Inherit;False;Constant;_Float5;Float 5;13;0;Create;True;0;0;0;False;0;False;-0.88;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-405.271,1933.056;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;141;-190.0771,681.0725;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;126;-1914.526,-1120.692;Inherit;True;3;0;FLOAT2;1,1;False;2;FLOAT2;0,-1;False;1;FLOAT;0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-434.964,1163.769;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;88;-971.299,67.6896;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;108;-770.8218,-503.9067;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-423.7467,1471.686;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;127;-1939.726,-1369.016;Inherit;True;3;0;FLOAT2;1,1;False;2;FLOAT2;0.5,-2;False;1;FLOAT;0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;128;-1550.184,-1356.969;Inherit;True;Property;_BlazeParticles;Blaze Particles;12;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-120.7208,1414.683;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;90;-868.2055,374.0731;Inherit;True;Property;_AlphaMask;Alpha Mask;10;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;80;-227.5399,1239.406;Inherit;False;Property;_Brightnessmultiply;Brightness multiply;2;0;Create;True;0;0;0;False;0;False;0;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;144;-43.9966,702.847;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;129;-1495.648,-1095.257;Inherit;True;Property;_TextureSample1;Texture Sample 1;12;0;Create;True;0;0;0;False;0;False;105;None;None;True;0;False;white;Auto;False;Instance;128;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;-198.3076,590.6285;Inherit;False;Constant;_Float8;Float 8;13;0;Create;True;0;0;0;False;0;False;6.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-364.3185,-155.858;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;50.61784,1379.407;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;77.65536,602.0963;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;130;-1061.533,-1544.994;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;120;-58.44512,-71.65452;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;131;-1086.494,-1309.401;Inherit;False;0;5;3;0,0,0,0;1,0.5159165,0.3254902,0.2;1,0.9251295,0.5417691,0.6529488;1,0.9982066,0.5803922,0.9029374;1,1,1,1;1,0;1,0.282353;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.OneMinusNode;95;-559.3046,383.6637;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;146;308.3874,432.9623;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;132;-833.3086,-1381.666;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;-397.8076,-864.402;Inherit;False;Property;_DepthFadeAmount;Depth Fade Amount;13;0;Create;True;0;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;92;141.24,93.33642;Inherit;True;Overlay;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;139;487.0601,-69.99021;Inherit;True;LinearDodge;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;155;-147.5708,-946.0583;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-1086.095,-1148.549;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;609.3113,-633.8004;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-1086.608,-414.7906;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;158;643.5558,183.1512;Inherit;False;Constant;_Float4;Float 4;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;886.7506,-17.62265;Float;False;True;-1;2;;0;0;StandardSpecular;Tobyfredson/Torch Flame;False;False;False;False;True;True;True;True;True;True;False;False;False;True;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;Overlay;All;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;True;Spherical;True;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;47;0;46;1
WireConnection;47;1;46;2
WireConnection;54;0;47;0
WireConnection;54;1;48;0
WireConnection;53;0;51;0
WireConnection;52;0;49;0
WireConnection;52;1;50;0
WireConnection;55;0;54;0
WireConnection;55;1;52;0
WireConnection;56;0;53;0
WireConnection;56;1;53;0
WireConnection;57;0;55;0
WireConnection;57;2;56;0
WireConnection;58;1;57;0
WireConnection;6;0;4;0
WireConnection;6;1;7;0
WireConnection;103;0;54;0
WireConnection;151;0;54;0
WireConnection;59;0;58;0
WireConnection;102;0;54;0
WireConnection;150;0;54;0
WireConnection;11;0;7;0
WireConnection;11;1;8;0
WireConnection;149;0;150;0
WireConnection;149;1;112;0
WireConnection;5;1;3;0
WireConnection;101;0;103;0
WireConnection;101;1;11;0
WireConnection;12;1;9;0
WireConnection;60;0;59;0
WireConnection;100;0;102;0
WireConnection;100;1;6;0
WireConnection;148;0;151;0
WireConnection;148;1;116;0
WireConnection;110;0;149;0
WireConnection;13;0;100;0
WireConnection;13;2;5;0
WireConnection;14;0;101;0
WireConnection;14;2;12;0
WireConnection;114;0;148;0
WireConnection;62;0;61;2
WireConnection;62;1;60;0
WireConnection;62;2;61;2
WireConnection;106;1;114;0
WireConnection;105;1;110;0
WireConnection;21;0;14;0
WireConnection;20;0;13;0
WireConnection;65;0;61;0
WireConnection;65;1;62;0
WireConnection;153;0;54;0
WireConnection;153;1;125;0
WireConnection;152;0;54;0
WireConnection;152;1;124;0
WireConnection;73;1;65;0
WireConnection;115;0;105;0
WireConnection;115;1;106;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;76;0;73;3
WireConnection;76;1;72;0
WireConnection;74;0;73;4
WireConnection;74;1;70;0
WireConnection;141;0;140;0
WireConnection;126;0;153;0
WireConnection;75;0;68;0
WireConnection;75;1;73;1
WireConnection;88;0;1;0
WireConnection;88;1;22;0
WireConnection;108;0;109;0
WireConnection;108;1;115;0
WireConnection;77;0;69;0
WireConnection;77;1;73;2
WireConnection;127;0;152;0
WireConnection;128;1;127;0
WireConnection;78;0;75;0
WireConnection;78;1;77;0
WireConnection;78;2;76;0
WireConnection;78;3;74;0
WireConnection;144;0;143;0
WireConnection;144;1;141;0
WireConnection;129;1;126;0
WireConnection;118;0;108;0
WireConnection;118;1;88;0
WireConnection;79;0;80;0
WireConnection;79;1;78;0
WireConnection;142;0;145;0
WireConnection;142;1;144;0
WireConnection;130;0;128;0
WireConnection;130;1;129;0
WireConnection;120;0;118;0
WireConnection;95;0;90;0
WireConnection;146;0;90;0
WireConnection;146;1;142;0
WireConnection;132;0;131;0
WireConnection;132;1;130;0
WireConnection;92;0;120;0
WireConnection;92;1;79;0
WireConnection;92;2;95;0
WireConnection;139;0;132;0
WireConnection;139;1;92;0
WireConnection;139;2;146;0
WireConnection;155;0;156;0
WireConnection;133;0;128;0
WireConnection;133;1;129;0
WireConnection;157;0;155;0
WireConnection;157;1;139;0
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;0;2;157;0
WireConnection;0;3;158;0
WireConnection;0;4;158;0
ASEEND*/
//CHKSM=9020243E474F6D011C353397192C56B32CAAAF34