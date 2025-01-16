Shader "XSJ/VFX/SP_Rotate"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "black" {}
		[Toggle(_FX_ADD)] _Add ("Add", Float) = 0
		_FxCol ("FxColor", Color) = (1,1,1,1)
		_FxTex ("Fx Texture (R)",2D) = "white"{}
		_AlphaValue ("Alpha", Range(0,2)) = 1
        _RSpeed ("旋转速度", Range(-10,10) ) = 0
		_MaskTex ("Mask Texture (R)",2D) = "white"{}
		// [Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("Straight Alpha Texture", Int) = 0
		[HideInInspector] [Toggle(_CANVAS_GROUP_COMPATIBLE)] _CanvasGroupCompatible("CanvasGroup Compatible", Int) = 0
		_Color ("Tint", Color) = (1,1,1,1)

		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil ("Stencil ID", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255

		[HideInInspector] _ColorMask ("Color Mask", Float) = 15

		[HideInInspector] [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

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

			struct a2v {
				fixed4 vertex   : POSITION;
				fixed4 color    : COLOR;
				fixed2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				fixed4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				fixed4 texcoord  : TEXCOORD0;
				fixed4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			fixed4 _Color;
			fixed4 _TextureSampleAdd,_FxTex_ST;
			fixed4 _ClipRect;
			fixed _RSpeed;

			v2f vert (a2v IN) {
				v2f OUT;

				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord.xy = IN.texcoord;
				fixed time = _Time.y;
                fixed cosA = cos(_RSpeed*time);
                fixed sinA = sin(_RSpeed*time);
                fixed2 center = fixed2(0.5,0.5);
				OUT.texcoord.zw = mul((IN.texcoord * _FxTex_ST.xy + _FxTex_ST.zw)-center,fixed2x2( cosA, -sinA, sinA, cosA))+center;
				
				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw-1.0) * fixed2(-1,1);
				#endif

				OUT.color = IN.color * fixed4(_Color.rgb * _Color.a, _Color.a); // Combine a PMA version of _Color with vertexColor.

				return OUT;
			}

			sampler2D _MainTex,_FxTex,_MaskTex;
			uniform fixed4 _MaskTex_ST,_FxCol;
			uniform fixed _AlphaValue;

			fixed4 frag (v2f IN) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, IN.texcoord.xy);
				fixed fxtex = tex2D(_FxTex, IN.texcoord.zw).r;
				fixed masktex = tex2D(_MaskTex, TRANSFORM_TEX(IN.texcoord.xy,_MaskTex)).r;

				// #if defined(_STRAIGHT_ALPHA_INPUT) TRANSFORM_TEX(v.texcoord.xy,_MainTex)
				tex.rgb *= tex.a;
				#if _FX_ADD
				half4 ACol = tex + half4((fxtex * masktex) * _AlphaValue * _FxCol.xyz * _FxCol.w , 0);
				#else
				half4 ACol = half4(tex.xyz * (1 - fxtex * masktex * _FxCol.w),tex.w) + (fxtex * masktex) * _AlphaValue * _FxCol;
				#endif
				fixed4 color = (ACol + _TextureSampleAdd) * IN.color;
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
