Shader "XSJ/VFX/Other/OverlapBuff" {
    Properties {
        [NoScaleOffset]_OverTex ("OverTex", 2D) = "white" {}
        [HDR]_Col01 ("Col01", Color) = (1,1,1,1)
        _Col01L ("Col01亮度值", Range(1, 10)) = 1
        [HDR]_Col02 ("Col02", Color) = (1,1,1,1)
        _Col02L ("Col02亮度值", Range(1, 10)) = 1
        [HDR]_Col03 ("Col03", Color) = (1,1,1,1)
        _Col03L ("Col03亮度值", Range(1, 10)) = 1
        [HDR]_Col04 ("Col04", Color) = (1,1,1,1)
        _Col04L ("Col04亮度值", Range(1, 10)) = 1
        [HDR]_Col05 ("Col05", Color) = (1,1,1,1)
        _Col05L ("Col05亮度值", Range(1, 10)) = 1
        [HDR]_Col06 ("Col06", Color) = (1,1,1,1)
        _Col06L ("Col06亮度值", Range(1, 10)) = 1
        [HDR]_Col07 ("Col07", Color) = (1,1,1,1)
        _Col07L ("Col07亮度值", Range(1, 10)) = 1
        _Col00 ("Col00", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _1 ("1", Float ) = 0
        [MaterialToggle] _2 ("2", Float ) = 0
        [MaterialToggle] _3 ("3", Float ) = 0
        [MaterialToggle] _4 ("4", Float ) = 0
        [MaterialToggle] _5 ("5", Float ) = 0
        [MaterialToggle] _6 ("6", Float ) = 0
        [MaterialToggle] _7 ("7", Float ) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        Pass {
            Name "FORWARD"
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
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            sampler2D _OverTex; 
            fixed4 _Col01,_Col00,_Col02,_Col03,_Col04,_Col05,_Col06,_Col07;
            fixed _1,_2,_3,_4,_5,_6,_7,_Col01L,_Col02L,_Col03L,_Col04L,_Col05L,_Col06L,_Col07L;
            struct a2v {
                fixed4 vertex : POSITION;
                fixed2 texcoord0 : TEXCOORD0;
            };
            struct v2f {
                fixed4 pos : SV_POSITION;
                fixed2 uv0 : TEXCOORD0;
            };
            v2f vert (a2v v) {
                v2f o = (v2f)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            fixed4 frag(v2f i) : COLOR {
                fixed4 overTex = tex2D(_OverTex,i.uv0);
                fixed alp0 = abs(floor(clamp(overTex.r,0,0.999)*7.0));
                fixed alp1 = saturate(abs((alp0-1.0)));
                fixed alp2 = saturate(abs((alp0-2.0)));
                fixed alp3 = saturate(abs((alp0-3.0)));
                fixed alp4 = saturate(abs((alp0-4.0)));
                fixed alp5 = saturate(abs((alp0-5.0)));
                fixed alp6 = saturate(abs((alp0-6.0)));
                fixed3 col0 = (1-saturate(alp0))*_Col01.rgb*_Col01L;
                fixed3 col1 = (1-alp1)*_Col02.rgb*_Col02L;
                fixed3 col2 = (1-alp2)*_Col03.rgb*_Col03L;
                fixed3 col3 = (1-alp3)*_Col04.rgb*_Col04L;
                fixed3 col4 = (1-alp4)*_Col05.rgb*_Col05L;
                fixed3 col5 = (1-alp5)*_Col06.rgb*_Col06L;
                fixed3 col6 = (1-alp6)*_Col07.rgb*_Col07L;
                fixed3 col = col0 + col1 + col2 + col3 + col4 + col5 + col6;
                fixed tog = saturate((_1+alp0)*(_2+alp1)*(_3+alp2)*(_4+alp3)*(_5+alp4)*(_6+alp5)*(_7+alp6));
                fixed3 emissive = overTex.b*lerp(_Col00.rgb,col,tog);
                fixed3 finalColor = emissive;
                fixed alpha = overTex.a;
                fixed4 finalRGBA = fixed4(finalColor,alpha);
                return finalRGBA;
            }
            ENDCG
        }
    }
}
