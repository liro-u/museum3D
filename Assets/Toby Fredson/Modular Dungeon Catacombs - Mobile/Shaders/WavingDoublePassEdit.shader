// Made with Amplify Shader Editor
// Made by Tobyfredson/Original source by Unity Technologies
Shader "Hidden/TerrainEngine/Details/WavingDoublePass"
{
	Properties
	{
		[HideInInspector][PerRendererData][NoScaleOffset][SingleLineTexture]_MainTex("MainTex", 2D) = "gray" {}
		_WavingTint("WavingTint", Color) = (1,1,1,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_cutout("cutout", Range( 0 , 3)) = 1
		_Wetness("Wetness", Range( 0 , 1)) = 0
		_Gloss("Gloss", Float) = 3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1

		//Edit - wind and distance fade
		_WaveAndDistance ("Wave and distance", Vector) = (12, 3.6, 1, 1)
	}

	SubShader
	{
		Tags{ "RenderType" = "Grass"  "Queue" = "Geometry+0" "ForceNoShadowCasting" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float3 viewDir;
			float3 worldNormal;
			float2 uv_texcoord;
			
			//Edit - distance fade
			float4 color : COLOR;
		};

		uniform sampler2D _MainTex;
		uniform float4 _WavingTint;
		uniform float _Wetness;
		uniform float _Gloss;
		uniform float _cutout;
		uniform float _Cutoff = 0.5;

		//Edit - wind and distance fade
		uniform float4 _WaveAndDistance; 
		//Edit - distance fade
		uniform float4 _CameraPosition;  


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult122 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult123 = (float2(_Time.y , _Time.y));

			//Edit - Wind
			float simplePerlin2D132 = snoise( ( appendResult122 + appendResult123 )*_WaveAndDistance.z * 0.3 );
			//float simplePerlin2D132 = snoise( ( appendResult122 + appendResult123 )*1.0 );
			
			simplePerlin2D132 = simplePerlin2D132*0.5 + 0.5;			
			float3 temp_cast_0 = (( pow( ( v.texcoord.xy.y * 0.5 ) , 2.0 ) * simplePerlin2D132 )).xxx;
			v.vertex.xyz += temp_cast_0;
			
			//Edit - distance fade
			float3 offset = v.vertex.xyz - _CameraPosition.xyz;
			v.color.a = saturate (2 * (_WaveAndDistance.w - dot (offset, offset)) * _CameraPosition.w);
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_MainTex124 = i.uv_texcoord;
			float4 tex2DNode124 = tex2D( _MainTex, uv_MainTex124 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult171 = dot( i.viewDir , -( ase_worldlightDir + ( ase_worldNormal * 1.0 ) ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV176 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode176 = ( 0.5 + 3.0 * pow( 1.0 - fresnelNdotV176, 8.58 ) );
			o.Albedo = ( ( tex2DNode124 * ( saturate( dotResult171 ) * ( tex2DNode124 * fresnelNode176 ) ) ) + ( _WavingTint * tex2DNode124 ) ).rgb;
			float grayscale138 = Luminance(tex2DNode124.rgb);
			float3 temp_cast_2 = (( pow( grayscale138 , 4.5 ) * _Wetness )).xxx;
			o.Specular = temp_cast_2;
			o.Smoothness = ( grayscale138 * _Gloss );
			o.Alpha = 1;
			//Edit - distance fade
			tex2DNode124.a *= i.color.a;
			
			clip( ( tex2DNode124.a * _cutout ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18301
476;686;1906;959;3727.296;1230.277;1.981129;True;True
Node;AmplifyShaderEditor.CommentaryNode;136;-2733.351,-235.9568;Inherit;False;1611.704;648.0309;View Dot direction;17;179;160;175;174;171;176;162;163;156;169;167;154;165;166;170;164;194;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;170;-2614.302,152.0811;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;164;-2708.91,304.6805;Inherit;False;Constant;_SubsurfaceDistortionModifire;Subsurface Distortion Modifire;9;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;165;-2626.518,7.849774;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-2417.56,208.6358;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-2268.358,84.86289;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;118;-2642.938,-1098.401;Inherit;False;535.4534;451.7778;Main Texture;3;181;158;124;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;190;-1599.498,464.2219;Inherit;False;1362.583;719.8359;Base Wind;13;121;126;130;132;131;135;120;128;117;123;122;127;115;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;124;-2592.938,-876.6215;Inherit;True;Property;_MainTex;MainTex;0;4;[HideInInspector];[PerRendererData];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;False;0;False;-1;None;cdae7318439d736478272cfc0ac70dda;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;162;-2570.812,-148.6988;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;163;-2082.24,46.38039;Inherit;False;Constant;_FresnelBias;Fresnel Bias;9;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;167;-2118.454,-45.17647;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-2084.681,137.813;Inherit;False;Constant;_FresnelScale;Fresnel Scale;9;0;Create;True;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-2090.672,224.5666;Inherit;False;Constant;_FresnelPower;Fresnel Power;9;0;Create;True;0;0;False;0;False;8.58;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;119;-2607.943,-613.0228;Inherit;False;498.8287;240.6366;Opacity;2;129;125;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;115;-1498.6,872.4641;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;117;-1549.498,1037.057;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;192;-2044.878,-565.3229;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;171;-1983.567,-130.6244;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;176;-1881.894,69.32381;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-1562.763,44.33999;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;120;-1518.635,514.2218;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;122;-1272.497,954.0574;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;123;-1301.497,1051.057;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-2557.943,-487.3863;Inherit;False;Property;_cutout;cutout;3;0;Create;True;0;0;False;0;False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;193;-2013.168,-316.9221;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;134;-1942.748,-841.6075;Inherit;False;807.9027;481.7047;Specular and Wetness;5;186;180;187;138;197;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;174;-1854.326,-123.0989;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1438.269,686.9741;Inherit;False;Constant;_WindGradient;Wind Gradient;9;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-1118.7,862.7329;Inherit;False;Constant;_WindScale;Wind Scale;9;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;194;-1580.099,-116.0389;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;-1409.219,-54.58219;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-1096.781,997.645;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;158;-2527.156,-1048.401;Inherit;False;Property;_WavingTint;WavingTint;1;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;126;-1270.14,782.8242;Inherit;False;Constant;_WindPower;Wind Power;9;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;138;-1892.748,-750.1411;Inherit;True;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-2251.555,-501.727;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1222.943,541.8803;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;197;-1660.049,-571.5366;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-1037.685,-25.56671;Inherit;False;Property;_Gloss;Gloss;5;0;Create;True;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;180;-1633.45,-793.0256;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;4.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-2276.484,-938.2457;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;195;-2060.387,-318.2713;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;132;-906.3297,790.7109;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;131;-938.5947,532.9862;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-1280.926,77.67693;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;191;-1024.483,-1019.55;Inherit;False;204;183;Albedo;1;189;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;139;-835.1442,-169.5991;Inherit;False;219;183;Gloss;1;161;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1887.704,-516.6221;Inherit;False;Property;_Wetness;Wetness;4;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1373.401,-614.2463;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-471.9157,677.546;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;-974.483,-969.5505;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-785.1442,-119.5992;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;196;-371.5962,-226.785;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;7;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Hidden/TerrainEngine/Details/WavingDoublePass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;5;Custom;0.5;True;False;0;True;Grass;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;1;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;166;0;170;0
WireConnection;166;1;164;0
WireConnection;154;0;165;0
WireConnection;154;1;166;0
WireConnection;167;0;154;0
WireConnection;192;0;124;0
WireConnection;171;0;162;0
WireConnection;171;1;167;0
WireConnection;176;1;163;0
WireConnection;176;2;169;0
WireConnection;176;3;156;0
WireConnection;175;0;124;0
WireConnection;175;1;176;0
WireConnection;122;0;115;1
WireConnection;122;1;115;3
WireConnection;123;0;117;0
WireConnection;123;1;117;0
WireConnection;193;0;192;0
WireConnection;174;0;171;0
WireConnection;194;0;193;0
WireConnection;160;0;174;0
WireConnection;160;1;175;0
WireConnection;127;0;122;0
WireConnection;127;1;123;0
WireConnection;138;0;124;0
WireConnection;129;0;124;4
WireConnection;129;1;125;0
WireConnection;130;0;120;2
WireConnection;130;1;121;0
WireConnection;197;0;138;0
WireConnection;180;0;138;0
WireConnection;181;0;158;0
WireConnection;181;1;124;0
WireConnection;195;0;129;0
WireConnection;132;0;127;0
WireConnection;132;1;128;0
WireConnection;131;0;130;0
WireConnection;131;1;126;0
WireConnection;179;0;194;0
WireConnection;179;1;160;0
WireConnection;186;0;180;0
WireConnection;186;1;187;0
WireConnection;135;0;131;0
WireConnection;135;1;132;0
WireConnection;189;0;179;0
WireConnection;189;1;181;0
WireConnection;161;0;197;0
WireConnection;161;1;137;0
WireConnection;196;0;195;0
WireConnection;7;0;189;0
WireConnection;7;3;186;0
WireConnection;7;4;161;0
WireConnection;7;10;196;0
WireConnection;7;11;135;0
ASEEND*/
//CHKSM=59C454E2EB4C7F0E9E8D9444945025A096D8460E