Shader "XSJ/VFX/Other/Ghost" {
    Properties {
        [NoScaleOffset]_NorTex ("NorTex", 2D) = "bump" {}
        [NoScaleOffset]_Level ("Level", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Color2 ("Color2", Color) = (0.5,0.5,0.5,1)
        [NoScaleOffset]_Shadow ("Shadow", 2D) = "white" {}
        _LightDir ("LightDir", Vector) = (1511.6,387,-1227,0.1)
        _Fresnel ("Fresnel", Range(1, 8)) = 2.39
        _FreColor ("FreColor", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        Pass{
            ZWrite on 
            colormask 0 
        }
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
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _NorTex; uniform fixed4 _NorTex_ST;
            uniform sampler2D _Level; uniform fixed4 _Level_ST;
            uniform fixed4 _Color;
            uniform fixed4 _Color2;
            uniform sampler2D _Shadow; uniform fixed4 _Shadow_ST;
            uniform fixed4 _LightDir;
            uniform fixed _Fresnel;
            uniform fixed4 _FreColor;
            struct a2v {
                fixed4 vertex : POSITION;
                fixed3 normal : NORMAL;
                fixed4 tangent : TANGENT;
                fixed2 texcoord0 : TEXCOORD0;
                fixed4 vertexColor : COLOR;
            };
            struct v2f {
                fixed4 pos : SV_POSITION;
                fixed2 uv0 : TEXCOORD0;
                fixed4 posWorld : TEXCOORD1;
                fixed3 normalDir : TEXCOORD2;
                fixed3 tangentDir : TEXCOORD3;
                fixed3 bitangentDir : TEXCOORD4;
                fixed4 vertexColor : COLOR;
            };
            v2f vert (a2v v) {
                v2f o = (v2f)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, fixed4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            fixed4 frag(v2f i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                fixed3x3 taTra = fixed3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                fixed3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                fixed3 nDir = i.normalDir;
                fixed3 nTex = UnpackNormal(tex2D(_NorTex,i.uv0));
                fixed ligH = 0.5*dot(normalize(_LightDir.rgb),mul( nTex.rgb, taTra ).xyz.rgb)+0.5;
                fixed level = tex2D(_Level,fixed2(ligH,ligH)).r;
                fixed4 anCol = tex2D(_Shadow,TRANSFORM_TEX(i.uv0, _Shadow));
                fixed3 finalColor = (lerp(_Color2.rgb,_Color.rgb,(level*anCol.r))+(pow(1.0-max(0,dot(nDir, vDir)),_Fresnel)*_FreColor.rgb));
                fixed4 finalRGBA = fixed4(finalColor,i.vertexColor.a);
                return finalRGBA;
            }
            ENDCG
        }
    }
}
