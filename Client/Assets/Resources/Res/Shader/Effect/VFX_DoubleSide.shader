Shader "XSJ/VFX/DoubleSide" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        [HDR]_TintColor ("InnerColor", Color) = (0.5,0.5,0.5,1)
        [HDR]_OuterColor ("OuterColor", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _Invert ("Invert", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
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
            sampler2D _MainTex; float4 _MainTex_ST;
            float4 _TintColor;
            fixed _Invert;
            float4 _OuterColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float _Invert_var = lerp( (1.0 - isFrontFace), isFrontFace, _Invert ); //是否反转.
                float lerpA = step(_Invert_var,.5);
                float lerpB = step(.5,_Invert_var);
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float alpha = (_MainTex_var.a*i.vertexColor.a*_TintColor.a);
                float lerpAlpha = lerp((lerpA*(_MainTex_var.a*i.vertexColor.a*_OuterColor.a))+(lerpB*alpha),alpha,lerpA*lerpB);
                clip(step(0.1,lerpAlpha) - 0.5);
////// Lighting:
                float3 OutRGB = (_MainTex_var.rgb*i.vertexColor.rgb*_TintColor.rgb*2);
                float3 finalColor = lerp((lerpA*(_MainTex_var.rgb*i.vertexColor.rgb*_OuterColor.rgb*2))+(lerpB*OutRGB),OutRGB,lerpA*lerpB);
                return fixed4(finalColor,lerpAlpha);
            }
            ENDCG
        }
    }
}
