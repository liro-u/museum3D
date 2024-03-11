// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tobyfredson/Candela Flame"
{
	Properties
	{
		[NoScaleOffset]_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Brightnessmultiply("Brightness multiply", Range( 0 , 10)) = 0
		[NoScaleOffset]_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Color0("Color 0", Color) = (1,0.6099074,0,0)
		_Color1("Color 1", Color) = (1,0.08614121,0,0)
		_Color2("Color 2", Color) = (1,1,1,0)
		_Color3("Color 3", Color) = (1,1,1,0)
		_Flamespeed("Flame speed", Float) = 0
		_NoiseScale("Noise Scale", Float) = 1
		_DepthFadeAmount("Depth Fade Amount", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Overlay+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "DisableBatching" = "True" "IsEmissive" = "true"  }
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
			float2 uv_texcoord;
			float3 worldPos;
		};

		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFadeAmount;
		uniform float _Brightnessmultiply;
		uniform float4 _Color0;
		uniform sampler2D _TextureSample0;
		uniform sampler2D _TextureSample1;
		uniform float _Flamespeed;
		uniform float _NoiseScale;
		uniform float4 _Color1;
		uniform float4 _Color2;
		uniform float4 _Color3;

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
			float screenDepth57 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth57 = saturate( abs( ( screenDepth57 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeAmount ) ) );
			float2 appendResult30 = (float2(-_Flamespeed , -_Flamespeed));
			float3 ase_worldPos = i.worldPos;
			float2 appendResult40 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 panner27 = ( 1.0 * _Time.y * appendResult30 + ( ( appendResult40 * 0.1 ) + ( i.uv_texcoord * _NoiseScale ) ));
			float4 tex2DNode1 = tex2D( _TextureSample0, ( i.uv_texcoord + ( i.uv_texcoord.y * ( (tex2D( _TextureSample1, panner27 )).g - 0.2 ) * i.uv_texcoord.y ) ) );
			float2 uv_TextureSample055 = i.uv_texcoord;
			o.Emission = ( distanceDepth57 * ( _Brightnessmultiply * ( ( _Color0 * tex2DNode1.r ) + ( _Color1 * tex2DNode1.g ) + ( tex2DNode1.b * _Color2 ) + ( tex2D( _TextureSample0, uv_TextureSample055 ).a * _Color3 ) ) ) ).rgb;
			float temp_output_60_0 = 0.0;
			float3 temp_cast_1 = (temp_output_60_0).xxx;
			o.Specular = temp_cast_1;
			o.Smoothness = temp_output_60_0;
			o.Alpha = 1;
		}

		ENDCG
	}
}
/*ASEBEGIN
Version=18935
7;119;1906;900;810.6094;632.4661;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;43;-3897.287,-44.6251;Inherit;False;673.9661;307.9057;World Space variation;4;39;40;41;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-3847.287,5.374957;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;40;-3600.846,24.33185;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3596.472,148.2805;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-3719.903,318.5668;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-3668.694,433.7205;Inherit;False;Property;_NoiseScale;Noise Scale;9;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-3655.802,559.7565;Inherit;False;Property;_Flamespeed;Flame speed;8;0;Create;True;0;0;0;False;0;False;0;0.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-3392.322,66.62024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;29;-3481.46,639.7633;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3468.263,370.8015;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;30;-3277.056,634.4124;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-3262.179,308.2718;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;27;-3063.341,402.1845;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;25;-2803.024,342.1693;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;e28dc97a9541e3642a48c0e3886688c5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;36;-2483.272,288.8926;Inherit;True;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-2306.971,-66.59528;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;37;-2212.064,282.9467;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2020.671,179.0085;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1201.805,-995.1403;Inherit;False;457.4534;257;R core col;2;7;10;;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-1240.67,-162.8893;Inherit;False;526.0117;261.1976;Blue;2;54;53;;0,0.1724138,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-1236.189,-432.4344;Inherit;False;526.0117;261.1976;Blue;2;12;9;;0,0.1724138,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-1208.776,-722.2021;Inherit;False;475.6421;280.942;Green;2;11;8;;0,1,0.1724138,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1935.754,20.72166;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;8;-1158.776,-672.2022;Inherit;False;Property;_Color1;Color 1;5;0;Create;True;0;0;0;False;0;False;1,0.08614121,0,0;1,0.08614109,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-1151.805,-945.1405;Inherit;False;Property;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;1,0.6099074,0,0;1,0.6099074,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1737.009,60.8175;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-1186.189,-378.2367;Inherit;False;Property;_Color2;Color 2;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;55;-1733.119,-186.6097;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;53;-1190.67,-108.6915;Inherit;False;Property;_Color3;Color 3;7;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-883.6577,-112.8893;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-902.1335,-574.2601;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-879.1771,-382.4344;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1239.752,-1289.067;Inherit;False;568.2368;247.6563;Comment;2;56;57;Dapth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-913.3508,-882.178;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1189.752,-1157.41;Inherit;False;Property;_DepthFadeAmount;Depth Fade Amount;10;0;Create;True;0;0;0;False;0;False;0;-3.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-599.1077,-631.264;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-617.8362,-830.8407;Inherit;False;Property;_Brightnessmultiply;Brightness multiply;2;0;Create;True;0;0;0;False;0;False;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;57;-939.5152,-1239.067;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;31;-1170.54,195.0641;Inherit;False;612.5899;322.9999;Bilboard;4;2;5;6;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-299.389,-721.432;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;60;41.35022,-145.7095;Inherit;False;Constant;_Float4;Float 4;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-711.9498,290.9019;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;3;-1120.54,339.0643;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleNode;5;-885.9496,348.9022;Inherit;False;2;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BillboardNode;2;-1114.54,245.0643;Inherit;False;Cylindrical;False;True;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-100.6456,-884.6082;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;50;231.3071,-261.245;Float;False;True;-1;2;;0;0;StandardSpecular;Tobyfredson/Candela Flame;False;False;False;False;True;True;True;True;True;True;False;False;False;True;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;2;Custom;0.5;True;False;0;True;Opaque;;Overlay;All;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;5;False;-1;10;False;-1;0;False;-1;3;False;-1;0;False;0;0,0,0,0;VertexOffset;True;True;Spherical;True;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;40;0;39;1
WireConnection;40;1;39;2
WireConnection;42;0;40;0
WireConnection;42;1;41;0
WireConnection;29;0;28;0
WireConnection;33;0;26;0
WireConnection;33;1;32;0
WireConnection;30;0;29;0
WireConnection;30;1;29;0
WireConnection;44;0;42;0
WireConnection;44;1;33;0
WireConnection;27;0;44;0
WireConnection;27;2;30;0
WireConnection;25;1;27;0
WireConnection;36;0;25;0
WireConnection;37;0;36;0
WireConnection;38;0;34;2
WireConnection;38;1;37;0
WireConnection;38;2;34;2
WireConnection;35;0;34;0
WireConnection;35;1;38;0
WireConnection;1;1;35;0
WireConnection;54;0;55;4
WireConnection;54;1;53;0
WireConnection;11;0;8;0
WireConnection;11;1;1;2
WireConnection;12;0;1;3
WireConnection;12;1;9;0
WireConnection;10;0;7;0
WireConnection;10;1;1;1
WireConnection;18;0;10;0
WireConnection;18;1;11;0
WireConnection;18;2;12;0
WireConnection;18;3;54;0
WireConnection;57;0;56;0
WireConnection;19;0;20;0
WireConnection;19;1;18;0
WireConnection;6;0;2;0
WireConnection;6;1;5;0
WireConnection;5;0;3;0
WireConnection;59;0;57;0
WireConnection;59;1;19;0
WireConnection;50;2;59;0
WireConnection;50;3;60;0
WireConnection;50;4;60;0
ASEEND*/
//CHKSM=52AC35943C139FE1BA440EBDBB6DBAA012A26C42