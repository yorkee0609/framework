Shader "XSJ/VFX/SP_UVMask"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "black" {}
		[Toggle(_FX_ADD)] _Add ("Add", Float) = 0
		_FxCol ("FxColor", Color) = (1,1,1,1)
		_FxTex ("Fx Texture (R)",2D) = "black"{}
		_Ang ("贴图旋转角度",Range(0,360)) = 0
		_AlphaValue ("Alpha", Range(0,2)) = 1
		[Toggle(_FX_STOP)] _Stop ("Stop", Float) = 1
		_T1 ("UV移动时间",Float ) = 1
		_T2 ("空闲时间",Float ) = 0
		_P1 ("初始位置",Float ) = -1
		_P2 ("终点位置",Float ) = 1
		_UVDir("UV移动轴向", Range(0,1)) = 0
		_MaskTex ("Mask Texture (R)",2D) = "white"{}
		[Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("Straight Alpha Texture", Int) = 0
		[Toggle(_CANVAS_GROUP_COMPATIBLE)] _CanvasGroupCompatible("CanvasGroup Compatible", Int) = 0
		_Color ("Tint", Color) = (1,1,1,1)

		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil ("Stencil ID", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255

		[HideInInspector] _ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

		// Outline properties are drawn via custom editor.
		[HideInInspector] _OutlineWidth("Outline Width", Range(0,8)) = 3.0
		[HideInInspector] _OutlineColor("Outline Color", Color) = (1,1,0,1)
		[HideInInspector] _OutlineReferenceTexWidth("Reference Texture Width", Int) = 1024
		[HideInInspector] _ThresholdEnd("Outline Threshold", Range(0,1)) = 0.25
		[HideInInspector] _OutlineSmoothness("Outline Smoothness", Range(0,1)) = 1.0
		[HideInInspector][MaterialToggle(_USE8NEIGHBOURHOOD_ON)] _Use8Neighbourhood("Sample 8 Neighbours", Float) = 1
		[HideInInspector] _OutlineMipLevel("Outline Mip Level", Range(0,3)) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			Name "Normal"

		CGPROGRAM
			// #pragma shader_feature _ _STRAIGHT_ALPHA_INPUT
			#pragma shader_feature _ _CANVAS_GROUP_COMPATIBLE
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			#pragma multi_compile __ _FX_ADD
			#pragma multi_compile __ _FX_STOP

			struct a2v {
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half4 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			half _USpeed,_VSpeed,_T1,_T2,_P1,_P2,_UVDir,_Ang;
			sampler2D _MainTex,_FxTex,_MaskTex;
			uniform float4 _FxTex_ST,_MaskTex_ST,_FxCol;
			uniform half _AlphaValue;

			v2f vert (a2v IN) {
				v2f OUT;

				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord.xy = IN.texcoord;
				half uvTime = _Time.y;
				half F = min(_T2 - fmod(uvTime,(_T1 + _T2)),0)/-_T1;
				half Offs = lerp(_P1,_P2,F);
				//贴图旋转
				float angA = (0.01745329*_Ang);
                float cosA = cos(angA);
                float sinA = sin(angA);
                float2 center = float2(0.5,0.5);
                float2 rotUV = (mul(IN.texcoord-center,float2x2( cosA, -sinA, sinA, cosA))+center);
				//……
				#if _FX_STOP
				OUT.texcoord.zw = rotUV * _FxTex_ST.xy + half2(_FxTex_ST.z*(1-_UVDir),_FxTex_ST.w*_UVDir);
				#else
				OUT.texcoord.zw = (rotUV * _FxTex_ST.xy) + half2(Offs*(1-_UVDir),Offs*_UVDir);
				#endif
				
				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1);
				#endif

				OUT.color = IN.color * float4(_Color.rgb * _Color.a, _Color.a); // Combine a PMA version of _Color with vertexColor.

				return OUT;
			}

			fixed4 frag (v2f IN) : SV_Target
			{
				half4 tex = tex2D(_MainTex, IN.texcoord.xy);
				half fxtex = tex2D(_FxTex, IN.texcoord.zw).r;
				half masktex = tex2D(_MaskTex, TRANSFORM_TEX(IN.texcoord.xy,_MaskTex)).r;

				// #if defined(_STRAIGHT_ALPHA_INPUT) TRANSFORM_TEX(v.texcoord.xy,_MainTex)
				tex.rgb *= tex.a;
				#if _FX_ADD
				half4 ACol = tex + half4((fxtex * masktex) * _AlphaValue * _FxCol.xyz * _FxCol.w , 0);
				#else
				half4 ACol = half4(tex.xyz * (1 - fxtex * masktex * _FxCol.w),tex.w) + (fxtex * masktex) * _AlphaValue * _FxCol;
				#endif

				half4 color = (ACol + _TextureSampleAdd) * IN.color;
				#ifdef _CANVAS_GROUP_COMPATIBLE
				color.rgb *= IN.color.a;
				#endif

				color *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "SpineShaderWithOutlineGUI"
}
