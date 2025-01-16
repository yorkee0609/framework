Shader "XSJ/VFX/Other/TwoSides" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _MaskTex ("MaskTex.r", 2D) = "white" {}
        [HDR]_Color01 ("Color01", Color) = (1,1,1,1)
        _Color02 ("Color02", Color) = (0.5,0.5,0.5,1)
        _Lum ("Luminance",Range(0,10)) = 1
        _Alpha ("Alpha", Range(0, 3)) = 1
        _Level ("Level", Range(0, 10)) = 1
    }
    SubShader {
        LOD 200
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
                        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            sampler2D _MainTex,_MaskTex; fixed4 _MainTex_ST,_MaskTex_ST;
            fixed4 _Color01,_Color02;
            fixed _Alpha,_Level,_Lum;
            struct a2v {
                fixed4 vtex : POSITION;
                fixed2 texcoord0 : TEXCOORD0;
            };
            struct v2f {
                fixed4 pos : SV_POSITION;
                fixed2 uv0 : TEXCOORD0;
                fixed4 posWorld : TEXCOORD1;
            };
            v2f vert (a2v v) {
                v2f o = (v2f)0;
                o.uv0 = v.texcoord0;
                o.posWorld = mul(unity_ObjectToWorld, v.vtex);
                o.pos = UnityObjectToClipPos( v.vtex );
                return o;
            }
            fixed4 frag(v2f i, fixed facing : VFACE) : COLOR {
                fixed face = ( facing >= 0 ? 1 : 0 );
                fixed4 mainTex = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                fixed maskTex = tex2D(_MaskTex,TRANSFORM_TEX(i.uv0, _MaskTex)).r;
                fixed3 finalColor = lerp((mainTex.rgb*_Color01.rgb),(mainTex.rgb*_Color02.rgb),face) * _Lum;
                fixed finalAlapha = saturate(mainTex.a * maskTex *_Alpha)*saturate(i.posWorld.g*_Level);
                return fixed4(finalColor,finalAlapha);
            }
            ENDCG
        }

    }
    SubShader {
        LOD 100
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
                        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            sampler2D _MainTex,_MaskTex; fixed4 _MainTex_ST,_MaskTex_ST;
            fixed4 _Color01,_Color02;
            fixed _Alpha,_Level,_Lum;
            struct a2v {
                fixed4 vtex : POSITION;
                fixed2 texcoord0 : TEXCOORD0;
            };
            struct v2f {
                fixed4 pos : SV_POSITION;
                fixed2 uv0 : TEXCOORD0;
                fixed4 posWorld : TEXCOORD1;
            };
            v2f vert (a2v v) {
                v2f o = (v2f)0;
                o.uv0 = v.texcoord0;
                o.posWorld = mul(unity_ObjectToWorld, v.vtex);
                o.pos = UnityObjectToClipPos( v.vtex );
                return o;
            }
            fixed4 frag(v2f i) : COLOR {
                fixed4 mainTex = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                fixed maskTex = tex2D(_MaskTex,TRANSFORM_TEX(i.uv0, _MaskTex)).r;
                fixed3 finalColor = mainTex.rgb*_Color01.rgb * _Lum;
                fixed finalAlapha = saturate(mainTex.a * maskTex *_Alpha)*saturate(i.posWorld.g*_Level);
                return fixed4(finalColor,finalAlapha);
            }
            ENDCG
        }

    }
    
}