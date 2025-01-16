Shader "XSJ/VFX/Sphericize" {
    Properties {
        [HDR]_MainColor("MainColor",Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _USpeed ("MainU向速度", Range(-5, 5)) = 0
        _VSpeed ("MainV向速度", Range(-5, 5)) = 0
        _Strength ("强度", Range(0, 10)) = 1
        _Radius ("半径", Range(0, 1)) = 1
        _MaskTex ("MaskTex", 2D) = "white" {}
        _USpeed1 ("MaskU向速度", Range(-5, 5)) = 0
        _VSpeed1 ("MaskV向速度", Range(-5, 5)) = 0
        [Header(Other)]
        [HDR]_LerpColor("差值颜色",Color) = (1,1,1,1)
        _LerpValue("差值阈值",Range(0,1)) = 1
        _Alpha("Alpha" , Range(0,1)) = 1
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        Pass {
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase

            sampler2D _MainTex,_MaskTex; 
            half4 _MainTex_ST,_MaskTex_ST,_MainColor,_LerpColor;
            half _Strength,_Radius,_USpeed,_VSpeed,_Alpha,_LerpValue,_USpeed1,_VSpeed1;

            struct a2v {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            v2f vert (a2v v) {
                v2f o = (v2f)0;
                o.uv = v.uv;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(v2f i) : COLOR {
                half2 uv1 = i.uv*2-1;
                half2 UVsqrt = sqrt((pow(_Radius,2)-dot(pow(uv1,2),1)))*_Strength;
                half2 timedata = _Time.g*half2(_USpeed,_VSpeed);
                half2 timedata1 = _Time.g*half2(_USpeed1,_VSpeed1);
                half2 uv2 = 0.5+((i.uv-0.5)/UVsqrt)+timedata;

                half4 mainTex = tex2D(_MainTex,TRANSFORM_TEX(uv2, _MainTex));
                half4 maskTex = tex2D(_MaskTex,TRANSFORM_TEX(i.uv + timedata1, _MaskTex));
                half alpha = mainTex.a*maskTex.r;

                half4 col ; 
                fixed lerpdegree = saturate(1 - mainTex.a - _LerpValue);
                col.rgb = lerp(mainTex.rgb,_LerpColor.rgb,lerpdegree)*_MainColor.rgb;
                col.a = (i.vertexColor.a * alpha)*_Alpha;
                return col;
            }
            ENDCG
        }
    }
}
