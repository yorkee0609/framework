// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "XSJ/VFX/UVEffect"
{
	Properties
	{
		[Enum(Custom Data,0,Material,1)]_ShaderMode("Shader Mode", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendMode("Blend Mode", Float) = 10
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[Toggle]_UseTurbulence("Use Turbulence", Range( 0 , 1)) = 0
		[Toggle]_UseClip("Use Clip", Range( 0 , 1)) = 0
		[Toggle]_UseMask("UseMask", Range( 0 , 1)) = 0
		_Brightness("Brightness", Float) = 1
		_Contrast("Contrast", Float) = 1
		[HDR]_MainColor("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		[Toggle]_AlphaR("Alpha R", Range( 0 , 1)) = 0
		_MainPannerX("Main Panner X", Float) = 0
		_MainPannerY("Main Panner Y", Float) = 0
		_TurbulenceTex("Turbulence Tex", 2D) = "white" {}
		_DistortPower("Distort Power", Float) = 0
		_PowerU("Power U", Float) = 0
		_PowerV("Power V", Float) = 0
		_MaskTex("Mask Tex", 2D) = "white" {}
		_Hardness("Hardness", Range( 0 , 0.99)) = 0
		_Dissolve("Dissolve", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 10)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 4.0
		ENDCG
		Blend SrcAlpha [_BlendMode]
		Cull [_CullMode]
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
		//only defining to not throw compilation error over Unity 5.5
		#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
			};

			uniform half _BlendMode;
			uniform half _CullMode;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform half _MainPannerX;
			uniform half _MainPannerY;
			uniform half _Dissolve;
			uniform half _DistortPower;
			uniform half _ShaderMode;
			uniform float _UseTurbulence;
			uniform sampler2D _TurbulenceTex;
			uniform float4 _TurbulenceTex_ST;
			uniform half _PowerU;
			uniform half _PowerV;
			uniform half _Contrast;
			uniform half _Brightness;
			uniform float4 _MainColor;
			uniform float _AlphaR;
			uniform half _UseClip;
			uniform half _Hardness;
			uniform half _Alpha;
			uniform float _UseMask;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float2 uv0_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 uv119 = i.ase_texcoord1;
				uv119.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult129 = (float4(uv119.x , uv119.y , uv119.z , uv119.w));
				float4 appendResult137 = (float4(( _MainPannerX * _Time.y ) , ( _Time.y * _MainPannerY ) , _Dissolve , _DistortPower));
				float4 lerpResult125 = lerp( appendResult129 , appendResult137 , _ShaderMode);
				float4 break128 = lerpResult125;
				float2 appendResult21 = (float2(break128.x , break128.y));
				float2 uv0_TurbulenceTex = i.ase_texcoord.xy * _TurbulenceTex_ST.xy + _TurbulenceTex_ST.zw;
				float2 appendResult36 = (float2(_PowerU , _PowerV));
				float4 tex2DNode31 = tex2D( _TurbulenceTex, ( uv0_TurbulenceTex + ( appendResult36 * _Time.y ) ) );
				half Distort148 = break128.w;
				float ifLocalVar211 = 0;
				UNITY_BRANCH 
				if( _UseTurbulence <= 0.0 )
				ifLocalVar211 = 0.0;
				else
				ifLocalVar211 = ( ( tex2DNode31.r - 0.5 ) * Distort148 );
				float4 tex2DNode3 = tex2D( _MainTex, ( ( uv0_MainTex + appendResult21 ) + ifLocalVar211 ) );
				float4 temp_cast_0 = (_Contrast).xxxx;
				float ifLocalVar206 = 0;
				UNITY_BRANCH 
				if( _AlphaR <= 0.0 )
				ifLocalVar206 = tex2DNode3.a;
				else
				ifLocalVar206 = tex2DNode3.r;
				float temp_output_87_0 = ( tex2DNode31.r + 1.0 );
				half dissolve146 = break128.z;
				float temp_output_116_0 = ( dissolve146 * ( 1.0 + 0 ) );
				half hardness89 = _Hardness;
				float temp_output_91_0 = ( 1.0 - hardness89 );
				float2 appendResult158 = (float2(saturate( ( ( ( temp_output_87_0 - ( temp_output_116_0 * ( 1.0 + temp_output_91_0 ) ) ) - hardness89 ) / ( 1.0 - hardness89 ) ) ) , saturate( ( ( ( temp_output_87_0 - ( ( temp_output_116_0 - 0 ) * ( 1.0 + temp_output_91_0 ) ) ) - hardness89 ) / ( 1.0 - hardness89 ) ) )));
				float2 temp_cast_2 = (1.0).xx;
				float2 temp_cast_3 = (1.0).xx;
				float2 ifLocalVar219 = 0;
				UNITY_BRANCH 
				if( _UseClip <= 0.0 )
				ifLocalVar219 = temp_cast_3;
				else
				ifLocalVar219 = appendResult158;
				float2 uv_MaskTex = i.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float ifLocalVar201 = 0;
				UNITY_BRANCH 
				if( _UseMask <= 0.0 )
				ifLocalVar201 = 1.0;
				else
				ifLocalVar201 = tex2D( _MaskTex, uv_MaskTex ).r;
				float4 appendResult173 = (float4(( pow( tex2DNode3 , temp_cast_0 ) * _Brightness * _MainColor * i.ase_color ).rgb , min( ( i.ase_color.a * _MainColor.a * ifLocalVar206 * ifLocalVar219.y * _Alpha * ifLocalVar201 ) , 1.0 )));
				
				
				finalColor = appendResult173;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16800
0;0;2048;1091;4498.424;-1679.469;1.242038;True;True
Node;AmplifyShaderEditor.RangedFloatNode;130;-3863.267,-695.7444;Half;False;Property;_MainPannerX;Main Panner X;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-3857.621,-462.1284;Half;False;Property;_MainPannerY;Main Panner Y;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;133;-3854.526,-608.6367;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;136;-3885.833,-294.1258;Half;False;Property;_DistortPower;Distort Power;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-3894.07,-889.5945;Float;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-3885.521,-386.5566;Half;False;Property;_Dissolve;Dissolve;19;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-3547.219,-549.7;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-3524.253,-653.2999;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-3303.355,-268.9305;Half;False;Property;_ShaderMode;Shader Mode;0;1;[Enum];Create;True;2;Custom Data;0;Material;1;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;137;-3270.573,-620.0473;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-3378.741,-871.256;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;125;-2983.629,-697.2468;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1802.325,1576.897;Half;False;Property;_Hardness;Hardness;18;0;Create;True;0;0;False;0;0;0.741;0;0.99;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;128;-2825.59,-692.8821;Float;True;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;33;-3786.038,1012.28;Half;False;Property;_PowerU;Power U;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-3786.294,1099.465;Half;False;Property;_PowerV;Power V;16;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;37;-3736.925,1389.103;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-2492.346,-415.3174;Half;False;dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-1506.827,1563.587;Half;False;hardness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-3497.227,2038.934;Float;False;-1;;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-3526.265,1052.47;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-3360.502,555.0458;Float;False;0;30;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-3271.948,986.2631;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-3216.607,1945.617;Float;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-3325.577,1827.591;Float;False;146;dissolve;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-3323.987,2182.251;Float;False;89;hardness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-3061.073,759.073;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;91;-3076.838,2197.062;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-3063.61,1826.56;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;30;-3018.544,425.4497;Float;True;Property;_TurbulenceTex;Turbulence Tex;13;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;31;-2687.734,725.1272;Float;True;Property;_TextureSample2;Texture Sample 2;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-2890.953,1883.854;Float;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-2809.518,2166.471;Float;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;-2761.449,2028.87;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-2688.081,1818.203;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-2292.741,1266.825;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-2580.669,2025.76;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-2542.105,-239.7856;Half;False;Distort;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-1491.632,1836.044;Float;False;89;hardness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-2052.208,1754.094;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;-1907.881,1346.22;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-1187.218,1838.44;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-1216.364,1570.049;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-1182.332,1742.867;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-1221.188,1473.482;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1877.077,776.8285;Float;False;148;Distort;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-1845.78,539.3958;Float;False;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;80;-1059.123,1512.663;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;104;-1019.698,1759.292;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-1870.226,-521.4356;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1617.318,578.8416;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-1917.583,43.00583;Float;False;Property;_UseTurbulence;Use Turbulence;3;1;[Toggle];Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-1821.481,-293.0772;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1818.867,310.2522;Half;False;Constant;_turbulencefloat;turbulence float;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-1320.242,-304.966;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;106;-887.1955,1729.831;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;81;-894.638,1514.823;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;211;-1576.583,58.00586;Float;False;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;220;3.793945,793.3314;Half;False;Property;_UseClip;Use Clip;4;1;[Toggle];Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;158;-63.57177,1545.782;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-1041.101,-219.9407;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-310.2979,871.5981;Half;False;Constant;_Clipfloat;Clip float;15;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-733.0618,-666.5654;Float;True;Property;_MainTex;Main Tex;9;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-1141.008,2113.48;Float;True;Property;_MaskTex;Mask Tex;17;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;3;-551.8387,-116.9735;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;202;-439.2195,2048.817;Float;False;Property;_UseMask;UseMask;5;1;[Toggle];Create;True;0;0;True;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-871.469,2112.668;Float;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ConditionalIfNode;219;301.4572,822.8502;Float;False;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-583.3528,2205.021;Half;False;Constant;_Maskfloat;Mask float;13;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-79.72711,331.6315;Float;False;Property;_AlphaR;Alpha R;10;1;[Toggle];Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;159;637.4059,807.7795;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;208;-155.9958,-392.3176;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;289.1778,-426.507;Half;False;Property;_Contrast;Contrast;7;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;22;740.7388,-127.7228;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ConditionalIfNode;201;-96.80027,2072.743;Float;False;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;206;219.6221,414.9956;Float;False;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-48.47189,-24.7894;Float;False;Property;_MainColor;Main Color;8;1;[HDR];Create;True;0;0;False;0;1,1,1,1;0.5754717,0.3836761,0.2144446,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;72;1123.803,884.4954;Half;False;Property;_Alpha;Alpha;20;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;295.0165,-348.9959;Half;False;Property;_Brightness;Brightness;6;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;7;458.3999,-504.2292;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;1786.866,582.6633;Float;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;1026.161,-293.8664;Float;True;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;74;1943.503,88.93385;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1847.143,3225.386;Half;False;Property;_BlendMode;Blend Mode;1;1;[Enum];Create;True;0;1;UnityEngine.Rendering.BlendMode;True;0;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1833.959,3131.04;Half;False;Property;_CullMode;Cull Mode;2;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;173;2743.312,-297.1746;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;3241.563,-358.9372;Half;False;True;2;Half;ASEMaterialInspector;0;1;XSJ/VFX/UVEffect;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;58;10;True;70;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;True;18;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;4;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;139;0;133;2
WireConnection;139;1;131;0
WireConnection;138;0;130;0
WireConnection;138;1;133;2
WireConnection;137;0;138;0
WireConnection;137;1;139;0
WireConnection;137;2;82;0
WireConnection;137;3;136;0
WireConnection;129;0;19;1
WireConnection;129;1;19;2
WireConnection;129;2;19;3
WireConnection;129;3;19;4
WireConnection;125;0;129;0
WireConnection;125;1;137;0
WireConnection;125;2;126;0
WireConnection;128;0;125;0
WireConnection;146;0;128;2
WireConnection;89;0;50;0
WireConnection;36;0;33;0
WireConnection;36;1;35;0
WireConnection;38;0;36;0
WireConnection;38;1;37;2
WireConnection;115;1;147;0
WireConnection;40;0;39;0
WireConnection;40;1;38;0
WireConnection;91;0;90;0
WireConnection;116;0;151;0
WireConnection;116;1;115;0
WireConnection;31;0;30;0
WireConnection;31;1;40;0
WireConnection;92;1;91;0
WireConnection;99;1;91;0
WireConnection;114;0;116;0
WireConnection;114;1;147;0
WireConnection;83;0;116;0
WireConnection;83;1;92;0
WireConnection;87;0;31;1
WireConnection;100;0;114;0
WireConnection;100;1;99;0
WireConnection;148;0;128;3
WireConnection;101;0;87;0
WireConnection;101;1;100;0
WireConnection;88;0;87;0
WireConnection;88;1;83;0
WireConnection;105;1;107;0
WireConnection;79;1;89;0
WireConnection;103;0;101;0
WireConnection;103;1;107;0
WireConnection;78;0;88;0
WireConnection;78;1;89;0
WireConnection;71;0;31;1
WireConnection;80;0;78;0
WireConnection;80;1;79;0
WireConnection;104;0;103;0
WireConnection;104;1;105;0
WireConnection;41;0;71;0
WireConnection;41;1;149;0
WireConnection;21;0;128;0
WireConnection;21;1;128;1
WireConnection;16;0;15;0
WireConnection;16;1;21;0
WireConnection;106;0;104;0
WireConnection;81;0;80;0
WireConnection;211;0;209;0
WireConnection;211;2;41;0
WireConnection;211;3;57;0
WireConnection;211;4;57;0
WireConnection;158;0;81;0
WireConnection;158;1;106;0
WireConnection;43;0;16;0
WireConnection;43;1;211;0
WireConnection;3;0;2;0
WireConnection;3;1;43;0
WireConnection;24;0;23;0
WireConnection;219;0;220;0
WireConnection;219;2;158;0
WireConnection;219;3;59;0
WireConnection;219;4;59;0
WireConnection;159;0;219;0
WireConnection;208;0;3;0
WireConnection;201;0;202;0
WireConnection;201;2;24;1
WireConnection;201;3;55;0
WireConnection;201;4;55;0
WireConnection;206;0;207;0
WireConnection;206;2;3;1
WireConnection;206;3;3;4
WireConnection;206;4;3;4
WireConnection;7;0;208;0
WireConnection;7;1;5;0
WireConnection;113;0;22;4
WireConnection;113;1;9;4
WireConnection;113;2;206;0
WireConnection;113;3;159;1
WireConnection;113;4;72;0
WireConnection;113;5;201;0
WireConnection;8;0;7;0
WireConnection;8;1;4;0
WireConnection;8;2;9;0
WireConnection;8;3;22;0
WireConnection;74;0;113;0
WireConnection;173;0;8;0
WireConnection;173;3;74;0
WireConnection;1;0;173;0
ASEEND*/
//CHKSM=C6E9BFCEA5A6494B5B09D7EC98683A680280E216