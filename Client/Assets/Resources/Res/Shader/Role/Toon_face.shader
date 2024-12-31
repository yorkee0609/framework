Shader"Custom/ToonShaderface"
{
    Properties
    {
        _LightDir("LightDir",Vector) = (.5,.5,.5,.5)
        _LightColor("LightColor",Color) = (1,1,1,1)
        _Color("Color",Color) = (1,1,1,1)
        _ShadowColor("ShadowColor", Color) = (0.4,0.4,0.4,1)
        _MainTex("MainTexture", 2D) = "white" {}
        _IlmTex("IlmTexture", 2D) = "black" {}
        _FaceMapTex("FaceMapTexture", 2D) = "black" {}
        _rampTex("rampTex", 2D) = "black" {}
        _ShadowThreshold ("ShadowThreshold",Range(0, 1)) = 0.925
        _ShadowSmoothness("ShadowSmoothness",Range(0, 1)) = 1
        _SpecularColor("SpecularColor", Color) = (0.9,0.9,0.9,1)
        _SpecularRange("SpecularRange",Range(0, 1)) = 0.15
        _Glossiness("Glossiness",Range(0.01, 256)) = 8
        _RimColor("RimColor", Color) = (1,1,1,1)
        _RimAmount("RimAmount", Range(0, 1)) = 0.042
        _RimThreshold("RimThreshold", Range(0, 10)) =6
        _Outline("OutlineWidth", Range(0, 5)) = 0.1
        _OutlineColor("OutlineColor", Color) = (1,1,1)
        [HDR]_EmisstionColor("EmisstionColor", Color) = (0,0,0,0)
        [Header(Shadow)]
        [Toggle]_ShadowSwitch("ShadowSwitch" , Float) = 1
        _ShadowDir("ShadowDir",Vector) = (.5,.5,.5,.5)
        _ShadowColor2("ShadowColor2",Color) = (0,0,0,1)
        _ShadowFalloff("ShadowFallOff",Range(0,2)) = 0
    }

    SubShader {

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha

            Tags { "LightMode"= "ForwardBase" "PassFlags"= "OnlyDirectional" }
            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

        struct appdata{
            float4 vertex : POSITION;
            float4 uv : TEXCOORD0;
            float3 normal : NORMAL;
            float4 vertColor : COLOR;
            };

        struct v2f{
            float4 pos : SV_POSITION;
            float3 worldNormal : NORMAL;
            float2 uv : TEXCOORD0;
            float3 viewDir : TEXCOORD1;
            float4 vertColor : COLOR;
            SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            sampler2D _IlmTex;
            sampler2D _rampTex;
            sampler2D _FaceMapTex;
            float4 _MainTex_ST;
            fixed4 _LightDir,_LightColor;


        v2f vert (appdata v){
            v2f o;
            o.pos= UnityObjectToClipPos(v.vertex);
            o.worldNormal= UnityObjectToWorldNormal(v.normal);
            o.viewDir= WorldSpaceViewDir(v.vertex);
            o.uv= TRANSFORM_TEX(v.uv, _MainTex);
            o.vertColor = v.vertColor;
            TRANSFER_SHADOW(o)
            return o;
            }

            half4 _Color;
            half4 _ShadowColor;
            half4 _SpecularColor;
            float _ShadowThreshold , _ShadowSmoothness;
            float _Glossiness, _SpecularRange;
            half4 _RimColor;
            float _RimAmount;
            float _RimThreshold;
            half4 _EmisstionColor;

        half4 frag (v2f i) : SV_Target{
            half4 color = tex2D(_MainTex, i.uv) ;
            half4 ilmTex = tex2D(_IlmTex, i.uv);
            float3 lightDir = normalize(UnityWorldToObjectDir(_LightDir.xyz));

            float2 uvF = float2(-i.uv.x, i.uv.y);
            uvF = lerp(i.uv, uvF, step(0, dot(float3(1,0,0), lightDir)));
            half4 faceTex = tex2D(_FaceMapTex, uvF);
            float3 normal = normalize(i.worldNormal);
            float3 viewDir = normalize(i.viewDir);

            float ndotl = dot(-lightDir, float3(0.0,0.0,1.0));//faceforward
            float halfLambert = ndotl * 0.5 + 0.5;
            half4 diffuse = lerp(_ShadowColor,_LightColor,step(halfLambert,faceTex.r));

            float3 halfVector = normalize(_LightDir + viewDir);//V + L
            float ndoth = max(0,dot(normal, halfVector));
            float specularIntensity = pow(ndoth, _Glossiness) * ilmTex.r;
            float specularRange = step(_SpecularRange, specularIntensity * ilmTex.b);
            half4 specular = specularRange * _SpecularColor;

            float rimDot = pow(1 - dot(viewDir, normal), _RimThreshold);
            float rimIntensity = rimDot * ndotl;
            rimIntensity= smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
            half4 rim = rimIntensity * _RimColor;

            fixed4 outc = (diffuse + rim + specular + _EmisstionColor ) * color;
            
            return fixed4(outc.rgb,_Color.a);
            // return(diffuse + rim + specular + _EmisstionColor * color.a) * color;
            //return i.vertColor;
            }
        ENDCG
        }

        Pass
        {
            Tags{"IgnoreProjector" = "true"}
			ZWrite Off
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma multi_compile UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 posWorld : TEXCOORD1;
            };
            fixed _Outline;
            fixed _OutlineSwitch;
            fixed _WorldClip;

            v2f vert (appdata v){
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex+v.normal*float4(_OutlineWidth,_OutlineWidth,_OutlineWidth,0));
                o.uv = v.uv;
                v.vertex.xyz += v.normal * (_Outline/80);
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 _OutlineColor;
            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = _OutlineColor;
                fixed worldposHigh =lerp(1,ceil(saturate(normalize(i.posWorld).y)),_WorldClip);
                return fixed4(col.rgb,1);
            }
            ENDCG
        }
        Pass{
            Tags { "RenderType"="Opaque" "Queue" = "Transparent"}

            // Blend SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                Ref 0
                Comp equal
                Pass incrWrap
                Fail keep
                ZFail keep
            }
            ZWrite off
            offset -10, 0
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            float4 _ShadowDir;
            float4 _ShadowColor2;
            float _ShadowFalloff,_ShadowSwitch;
            float _TestInt,_TestInt2;
            fixed _Alpha;
            fixed _WorldClip;
            fixed4 _LightDir;

            v2f vert (appdata v)
            {
                v2f o;


                float3 shadowPos;
                float3 worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

                float3 lightDir = normalize(_ShadowDir.xyz);

                shadowPos.y = min(worldPos .y , _ShadowDir.w);

                shadowPos.xz = worldPos.xz + lightDir.xz * max(0 , worldPos.y) / lightDir.y; 

                float3 shadowPos2 = float3(shadowPos.x,shadowPos.y,shadowPos.z);
                o.vertex = UnityWorldToClipPos(shadowPos2);

                float3 center =float3( unity_ObjectToWorld[0].w ,_ShadowDir.w, unity_ObjectToWorld[2].w);
                
                float falloff =1-saturate(distance(shadowPos , center) * _ShadowFalloff);  //非正片叠底状态下1-

                o.color = _ShadowColor2; 
                fixed worldposHigh =lerp(1,ceil(saturate(normalize(worldPos).y)),_WorldClip);
                o.color.rgb =lerp(fixed3(0,0,0),_ShadowColor2.rgb,falloff);
                // o.color.rgb = lerp(fixed3(1,1,1),lerp(fixed3(1,1,1),_ShadowColor.rgb,falloff),_ShadowSwitch*_Alpha*worldposHigh); //正片叠底之后给白色.
                // o.color = fixed4(1,1,1,1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color.rgb,i.color.r);
            }
            ENDCG
        }
    }
	Fallback"Legacy Shaders/VertexLit"
}