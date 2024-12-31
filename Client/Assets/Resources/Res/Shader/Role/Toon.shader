Shader"Custom/ToonShader"
{
    Properties
    {
        _LightDir("LightDir",Vector) = (.5,.5,.5,.5)
        _LightColor("LightColor",Color) = (1,1,1,1)
        _Color("Color",Color) = (1,1,1,1)
        _ClothShadowColor("ClothShadowColor", Color) = (0.4,0.4,0.4,1)
        _MainTex("MainTexture", 2D) = "white" {}
        _IlmTex("IlmTexture", 2D) = "black" {}
        _rampTex("rampTex", 2D) = "black" {}
        [Toggle(MATCAP)]_MATCAPOn("Use Matcap？",int) = 1
        _matcap("Matcap", 2D) = "white" {}
        _ShadowSmoothness("ShadowSmoothness",Range(0, 1)) = 1
        _SpecularColor("SpecularColor", Color) = (0.9,0.9,0.9,1)
        _SpecularRange("SpecularRange",Range(0, 1)) = 0.15
        _Glossiness("Glossiness",Range(0.01, 256)) = 8
        _RimColor("RimColor", Color) = (0,0,0,0)
        _RimAmount("RimAmount", Range(0, 0.1)) = 0.0
        _Outline("OutlineWidth", Range(0, 5)) = 0.1
        _OutlineColor("OutlineColor", Color) = (1,1,1)
        [HDR]_EmisstionColor("EmisstionColor", Color) = (0,0,0,0)
        [Header(Shadow)]
        [Toggle]_ShadowSwitch("ShadowSwitch" , Float) = 1
        _ShadowDir("ShadowDir",Vector) = (.5,.5,.5,.5)
        _ShadowColor("ShadowColor",Color) = (0,0,0,1)
        _ShadowFalloff("ShadowFallOff",Range(0,2)) = 0
    }

    SubShader {
        
        Pass {
            // Blend SrcAlpha OneMinusSrcAlpha
            Tags { "LightMode"= "ForwardBase" "PassFlags"= "OnlyDirectional" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma shader_feature MATCAP
            #include "UnityCG.cginc"
            // #include "Lighting.cginc"
            // #include "AutoLight.cginc"

        struct appdata{
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float3 normal : NORMAL;
            };

        struct v2f{
            float4 pos : SV_POSITION;
            float3 worldNormal : NORMAL;
            float4 uv : TEXCOORD0;
            float3 viewDir : TEXCOORD1;
            float4 projPos : TEXCOORD2;
            // SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            sampler2D _IlmTex;
#if defined (MATCAP)
            sampler2D _matcap;
#endif
            sampler2D _rampTex;
            float4 _MainTex_ST;


        v2f vert (appdata v){
            v2f o;
            o.pos= UnityObjectToClipPos(v.vertex);

            o.projPos = ComputeScreenPos (o.pos);
            COMPUTE_EYEDEPTH(o.projPos.z);

            o.worldNormal= UnityObjectToWorldNormal(v.normal);
            o.viewDir= WorldSpaceViewDir(v.vertex);
            o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
            o.uv.z = dot(normalize(UNITY_MATRIX_IT_MV[0]), normalize(v.normal));
            o.uv.w = dot(normalize(UNITY_MATRIX_IT_MV[1]), normalize(v.normal));
            o.uv.zw = o.uv.zw * 0.5 + 0.5;

            // TRANSFER_SHADOW(o)
            return o;
            }

            half4 _Color;
            half4 _ShadowColor,_ClothShadowColor;
            half4 _SpecularColor;
            float _ShadowSmoothness;
            float _Glossiness, _SpecularRange;
            half4 _RimColor;
            float _RimAmount;
            half4 _EmisstionColor;
            fixed4 _LightDir,_LightColor;

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

        half4 frag (v2f i) : SV_Target
        {
            half4 ilmTex = tex2D(_IlmTex, i.uv);
            #if defined (MATCAP)
            half4 matCapColor = half4(tex2D(_matcap, i.uv.zw).rgb * ilmTex.b, 1.0);
            half4 mainTexture = tex2D(_MainTex, i.uv) * _Color;
            half4 color = lerp(mainTexture, matCapColor*3, saturate(ilmTex.b));
            #else
            half4 color = tex2D(_MainTex, i.uv) * _Color;
            #endif
            float3 normal = normalize(i.worldNormal);
            float3 viewDir = normalize(i.viewDir);
            float ndotl = max(0,dot(_LightDir.rgb, normal))+ilmTex.a;

            //ilmTex r：高光强度, g：阴影区域, b：高光范围
            half4 diffuse = 0;
            half3 diffuse2 = 0;
            half halfLambert = saturate((ndotl * 0.5 + 0.5));

            // diffuse = lerp(_LightColor,_ClothShadowColor,saturate(step(halfLambert,0.7)+(1-ilmTex.g))) * color;
            diffuse = lerp(_LightColor,tex2D(_rampTex, float2(saturate(halfLambert + 0.3),_ShadowSmoothness)),saturate(step(halfLambert,0.7))) * color ;
            // diffuse2 =_ClothShadowColor.rgb* ;

            float3 halfVector = normalize(_LightDir.rgb + viewDir);//V + L
            float ndoth = max(0,dot(normal, halfVector));
            float specularIntensity = pow(ndoth, _Glossiness) * ilmTex.r;
            float specularRange = step(_SpecularRange, specularIntensity * ilmTex.b);
            half4 specular = specularRange * _SpecularColor;

            half partZ = i.projPos.z;
            i.projPos.x -= _RimAmount;
            half sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
			half rimRange = sceneZ - partZ;
            half4 rimLeft = saturate(rimRange) * _RimColor * color;

            i.projPos.x += _RimAmount * 2;
            half sceneZ1 = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
			half rimRange1 = sceneZ1 - partZ;
            half4 rimRight = saturate(rimRange1) * _RimColor * color;

            fixed4 outC = diffuse + rimLeft + rimRight + specular + _EmisstionColor;
            // return fixed4(outC.rgb, _Color.a);
            fixed shadowlerpValue = pow(step(ndotl,0.2) -1,2);
            return lerp(outC,_ClothShadowColor*color,(1-ilmTex.g)*shadowlerpValue);
            //return matCapColor;
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
            fixed _OutlineSwitch,_Alpha;
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
            // Blend DstColor Zero //正片叠底 
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
            fixed4 _ShadowDir;
            float4 _ShadowColor;
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

                o.color = _ShadowColor; 
                fixed worldposHigh =lerp(1,ceil(saturate(normalize(worldPos).y)),_WorldClip);
                o.color.rgb =lerp(fixed3(0,0,0),_ShadowColor.rgb,falloff) * _ShadowSwitch;
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
	// Fallback"Legacy Shaders/VertexLit"
}