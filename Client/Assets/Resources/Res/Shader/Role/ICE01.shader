Shader "XSJ/ICE" {
    Properties {
        _IceTex ("IceTex", 2D) = "black" {}
        _CoreCol ("CoreCol", Color) = (1,1,1,1)
        _EdgeCol ("EdgeCol", Color) = (0.6084906,0.9178055,1,1)
        _Push ("Push", Range(0, 0.01)) = 0
        _Pow ("Pow", Range(0.3, 5)) = 1
        _Alpha ("Alpha", Range(0, 1)) = 1
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
            #pragma target 3.0
            uniform float _Push;
            uniform sampler2D _IceTex; uniform float4 _IceTex_ST;
            uniform float _Pow;
            uniform float4 _CoreCol;
            uniform float4 _EdgeCol;
            uniform float _Alpha;
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float4 nDir : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };
            v2f vert (a2v v) {
                v2f o = (v2f)0;
                o.nDir.xyz = normalize(UnityObjectToWorldNormal(v.normal));
                v.vertex.xyz += v.normal*_Push;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                float3 vieDir = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
                o.nDir.w = 1-dot(vieDir,o.nDir.xyz);
                return o;
            }
            float4 frag(v2f i) : COLOR {
                
                float2 wordUV = float2(i.posWorld.r,i.posWorld.g);
                float iceTex = tex2D(_IceTex,TRANSFORM_TEX(wordUV, _IceTex)).r;
                float ice = floor((pow(i.nDir.w ,_Pow)*3.0))/3.0+iceTex;
                float3 finalColor = lerp(_EdgeCol.rgb,_CoreCol.rgb,(ice*ice));
                fixed4 finalRGBA = fixed4(finalColor,(ice*_Alpha));
                return finalRGBA;
            }
            ENDCG
        }
    }
}
