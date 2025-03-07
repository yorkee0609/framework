﻿Shader "XSJBeijing/Role"
{
    Properties
    {
        [Header(Base)]
        _LightDir ("LightDir",Vector) = (1,1,1,1)
        _LightIntensity("LightIntensity",Range(1,2)) = 1
		_MainColor ("MainColor", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

        [Header(OutLine)]
        [Toggle]_OutlineSwitch("OutlineSwitch",Float) = 1
        _OutlineWidth ("OutlineWidth",Range(0,5)) = 0
        _OutlineColor ("OutlineColor",Color ) = (0,0,0,1)
        // _OffsetZ("OffsetZ" , Range(-0.5,0)) = 0

        [Header(LambertColor)]
        [Toggle]_FloorSwitch("FloorSwitch",Float) = 0
        _SmoothFloor("SmoothFloor",Range(1,10)) = 0
		_ForwardColor ("ForwardColor", Color) = (1,1,1,1)
		_BackColor ("BackColor", Color) = (0.5,0.5,0.5,1)
		_Mask ("Mask(R:Refl G:Cloth B:null A:Shadow)", 2D) = "white" {}
        _ShadowMapRange("ShadowMapRange",Range(0,1)) = 1

		[Header(Specular)]
		_Specular ("Specular", 2D) = "white" {}
		_SpecularColor ("SpecularColor", Color) = (0.5,0.5,0.5,1)
		_SpecularRange ("SpecularRange", Range(0, 1)) = 1
		_SpecularIntensity ("SpecularIntensity", Range(1, 5)) = 1

        _ClothSpecularColor ("ClothSpecularColor", Color) = (0.5,0.5,0.5,1)
		_ClothSpecularRange ("ClothSpecularRange", Range(0, 1)) = 1
		_ClothSpecularIntensity ("ClothSpecularIntensity", Range(1, 5)) = 1

		[Header(Fresnel)]
		[MaterialToggle] _FresnelToggler ("FresnelToggler", Float ) = 0
		_Fresnel ("Fresnel", Range(1, 10)) = 5
		_FresnelPost ("FresnelPost", Range(1.1, 10)) = 2
		_FresnelColor ("FresnelColor", Color) = (0.5,0.5,0.5,1)

        [Header(Shadow)]
        _ShadowDir ("ShadowDir",Vector) = (.5,.5,.5,0)
        [Toggle]_ShadowSwitch("ShadowSwitch" , Float) = 1
        _ShadowColor("ShadowColor",Color) = (0,0,0,1)
        _ShadowFalloff("ShadowFallOff",Range(0,2)) = 0

        [Header(Other)]
        _Saturation("Saturation",Range(0,2)) = 1
		_OtherColor ("OtherColor", Color) = (1,1,1,1)
        _Alpha("Alpha",Range(0,1)) = 1
        [Toggle]_WorldClip("水平面下裁剪",Float) = 0

        [Header(Dissolution)]
        _DissolutionTex ("溶解贴图", 2D) = "white" {}
        _Dissolvability ("溶解程度", Range(0,1)) = 0
        _Eclosion("边缘羽化", Range(0,1)) = 1
        _EdgeColor ("边缘颜色", Color) = (1,1,1,1)
        _EdgeWidth ("边缘宽度", Range(0,1)) = 0

        [Header(FeedBack)]
		_FeedBackAlpha ("FeedBackAlpha", Range(0, 1)) = 0
		_FeedBackColor ("FeedBackColor", Color) = (1,1,1,1)


        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha
//        outline
//        Pass
//        {
//            Tags{"IgnoreProjector" = "true"}
//			ZWrite Off
//            Cull Off
//            
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            // #pragma multi_compile UNITY_PASS_SHADOWCASTER
//            #include "UnityCG.cginc"
//
//            struct appdata
//            {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//                float4 normal : NORMAL;
//
//            };
//
//            struct v2f
//            {
//                float2 uv : TEXCOORD0;
//                float4 vertex : SV_POSITION;
//                half3 posWorld : TEXCOORD1;
//            };
//            fixed _OutlineWidth;
//            fixed _OutlineSwitch,_Alpha;
//            fixed _WorldClip;
//
//            v2f vert (appdata v){
//                v2f o;
//                // o.vertex = UnityObjectToClipPos(v.vertex+v.normal*float4(_OutlineWidth,_OutlineWidth,_OutlineWidth,0));
//                o.uv = v.uv;
//                v.vertex.xyz += v.normal * (_OutlineWidth/80);
//				o.vertex = UnityObjectToClipPos(v.vertex);
//                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
//                return o;
//
//            }
//
//            fixed4 _OutlineColor;
//            fixed4 frag (v2f i) : SV_Target
//            {
//                // fixed4 col = tex2D(_MainTex, i.uv);
//                fixed4 col = _OutlineColor;
//                fixed worldposHigh =lerp(1,ceil(saturate(normalize(i.posWorld).y)),_WorldClip);
//                fixed switchAlpha = lerp(0,_Alpha,_OutlineSwitch)*worldposHigh;
//                return fixed4(col.rgb,switchAlpha);
//            }
//            ENDCG
//        }
        Pass {
            Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma multi_compile_fog
            #pragma multi_compile_instancing // 添加实例化支持

            // 定义实例化属性
            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(half4, _BackColor)
            UNITY_DEFINE_INSTANCED_PROP(half4, _ForwardColor)
            UNITY_DEFINE_INSTANCED_PROP(half4, _FeedBackColor)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _FloorSwitch)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _SmoothFloor)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _LightIntensity)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _FeedBackAlpha)
            // UNITY_DEFINE_INSTANCED_PROP(sampler2D, _MainTex)
            // UNITY_DEFINE_INSTANCED_PROP(sampler2D, _Mask)
            // UNITY_DEFINE_INSTANCED_PROP(sampler2D, _Specular)
            // UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
            // UNITY_DEFINE_INSTANCED_PROP(float4, _Mask_ST)
            // UNITY_DEFINE_INSTANCED_PROP(float4, _Specular_ST)
            UNITY_DEFINE_INSTANCED_PROP(half4, _SpecularColor)
            UNITY_DEFINE_INSTANCED_PROP(half4, _LightDir)
            UNITY_DEFINE_INSTANCED_PROP(half4, _FresnelColor)
            UNITY_DEFINE_INSTANCED_PROP(half4, _ClothSpecularColor)
            UNITY_DEFINE_INSTANCED_PROP(half, _SpecularRange)
            UNITY_DEFINE_INSTANCED_PROP(half, _Fresnel)
            UNITY_DEFINE_INSTANCED_PROP(half, _SpecularIntensity)
            UNITY_DEFINE_INSTANCED_PROP(half, _FresnelToggler)
            UNITY_DEFINE_INSTANCED_PROP(half, _FresnelPost)
            UNITY_DEFINE_INSTANCED_PROP(half, _ClothSpecularIntensity)
            UNITY_DEFINE_INSTANCED_PROP(half, _ClothSpecularRange)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _Saturation)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _OtherColor)
            // UNITY_DEFINE_INSTANCED_PROP(sampler2D, _DissolutionTex)
            // UNITY_DEFINE_INSTANCED_PROP(half4, _DissolutionTex_ST)
            UNITY_DEFINE_INSTANCED_PROP(half, _Dissolvability)
            UNITY_DEFINE_INSTANCED_PROP(half, _Eclosion)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _EdgeColor)
            UNITY_DEFINE_INSTANCED_PROP(half, _EdgeWidth)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _WorldClip)
            UNITY_DEFINE_INSTANCED_PROP(half, _ShadowMapRange)
            UNITY_DEFINE_INSTANCED_PROP(half, _Alpha)
            UNITY_INSTANCING_BUFFER_END(Props) 
			// half4 _BackColor,_ForwardColor,_FeedBackColor;
            // fixed _FloorSwitch,_SmoothFloor,_LightIntensity,_FeedBackAlpha;
			 sampler2D _MainTex,_Mask,_Specular;  
            float4 _MainTex_ST,_Mask_ST,_Specular_ST;
			// half4 _SpecularColor,_LightDir,_FresnelColor,_ClothSpecularColor;
			// half _SpecularRange,_Fresnel,_SpecularIntensity,_FresnelToggler,_FresnelPost,_ClothSpecularIntensity,_ClothSpecularRange;
            // fixed _Saturation;
            // fixed4 _OtherColor;

             sampler2D _DissolutionTex;
            half4 _DissolutionTex_ST;
            // half _Dissolvability,_Eclosion;
            // fixed4 _EdgeColor;
            // half _EdgeWidth;
            // fixed _WorldClip;
            // half _ShadowMapRange,_Alpha;
		
			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0; 
                 UNITY_VERTEX_INPUT_INSTANCE_ID // 添加实例化ID
			};
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
                UNITY_FOG_COORDS(4)
                 UNITY_VERTEX_INPUT_INSTANCE_ID // 添加实例化ID
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o ;
                 UNITY_SETUP_INSTANCE_ID(v); // 设置实例化ID
                 UNITY_TRANSFER_INSTANCE_ID(v, o); // 传递实例化ID
                o.uv = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                o.uv3 = TRANSFORM_TEX(v.texcoord0,  _DissolutionTex); // 使用实例化属性
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed3 saturation(fixed3 Graycolor){
                fixed Gray = .2125*Graycolor.r+.7154*Graycolor.g+.0721*Graycolor.b;
                fixed3 GraySaturationColor = fixed3(Gray,Gray,Gray);
                fixed3 outGrayColor = lerp(GraySaturationColor,Graycolor,UNITY_ACCESS_INSTANCED_PROP(Props, _Saturation)); // 使用实例化属性
                return outGrayColor;
            }


			float4 frag(VertexOutput i) : COLOR {
				 UNITY_SETUP_INSTANCE_ID(i); // 设置实例化ID
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(UNITY_ACCESS_INSTANCED_PROP(Props, _LightDir).xyz); // 使用实例化属性
                float3 halfDirection = normalize(viewDirection+lightDirection);

                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv, _MainTex)); // 使用实例化属性
                float4 _Specular_var = tex2D(_Specular,TRANSFORM_TEX(i.uv, _Specular)); // 使用实例化属性
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv, _Mask)); // 使用实例化属性

                float lbt =  saturate(dot(lightDirection,i.normalDir)*.5+.5);
                float FloorForward =saturate( floor(lbt*2));

                float lambertB=saturate(pow((lbt-1.0),2 ));
                float FloorB = saturate(pow(1-FloorForward,2));

                float smoothLbt =saturate( (atan((lbt-.5)*(UNITY_ACCESS_INSTANCED_PROP(Props, _SmoothFloor)*10))/2)+.5); // 使用实例化属性
                float ForwardFloorSwitch = lerp(smoothLbt,FloorForward,UNITY_ACCESS_INSTANCED_PROP(Props, _FloorSwitch)); // 使用实例化属性

                //ShadowMapMask-----
                half shadowMaskVar = pow(saturate(step(_Mask_var.g,UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowMapRange)))-1,2); // 使用实例化属性
                float3 lambertA =saturate(lerp(UNITY_ACCESS_INSTANCED_PROP(Props, _BackColor),UNITY_ACCESS_INSTANCED_PROP(Props, _ForwardColor),FloorForward*shadowMaskVar)); // 使用实例化属性
                float3 lambertD =saturate(lerp(UNITY_ACCESS_INSTANCED_PROP(Props, _ForwardColor),UNITY_ACCESS_INSTANCED_PROP(Props, _BackColor),saturate(1.0 - (ForwardFloorSwitch*_Mask_var.g)))); // 使用实例化属性
                float3 lambertC = lerp(lambertA,lambertD,floor(UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowMapRange))); // 使用实例化属性
                //------        
                float3 gloss = pow(saturate(dot(i.normalDir,halfDirection)),exp2((UNITY_ACCESS_INSTANCED_PROP(Props, _SpecularRange)*10.0))); // 使用实例化属性
				float3 maskgloss = ((gloss*_Mask_var.r)*_Specular_var)*UNITY_ACCESS_INSTANCED_PROP(Props,_SpecularColor.rgb)*UNITY_ACCESS_INSTANCED_PROP(Props,_SpecularIntensity);


                //ClothGloss
                float3 Clothgloss = pow(saturate(dot(i.normalDir,halfDirection)),exp2((UNITY_ACCESS_INSTANCED_PROP(Props,_ClothSpecularRange)*10.0)));
				float3 Clothmaskgloss = ((Clothgloss*_Mask_var.g)*_Specular_var)*UNITY_ACCESS_INSTANCED_PROP(Props,_ClothSpecularColor).rgb*UNITY_ACCESS_INSTANCED_PROP(Props,_ClothSpecularIntensity);

				float3 OutTex = (_MainTex_var.rgb)+maskgloss+Clothmaskgloss;
				float3 floorC =OutTex*lambertC*UNITY_ACCESS_INSTANCED_PROP(Props,_LightIntensity);

                //fresnel
				float fresnel=saturate(dot(i.normalDir, viewDirection) ) ;
				float fresnelpower = pow(1.0-fresnel,UNITY_ACCESS_INSTANCED_PROP(Props,_Fresnel));
				float3 fresnelswitch=lerp( 0, (((lbt*fresnelpower) * UNITY_ACCESS_INSTANCED_PROP(Props,_FresnelPost)) / (UNITY_ACCESS_INSTANCED_PROP(Props,_FresnelPost) - 1)*UNITY_ACCESS_INSTANCED_PROP(Props,_FresnelColor).rgb), UNITY_ACCESS_INSTANCED_PROP(Props,_FresnelToggler) );

                // float3 floorC = lerp(float3(1,0,0),float3(0,1,0),saturate((1.0 - (FloorForward*_Mask_var.g))));

                //out 
                //FeedBack
                float3 feedbackswitch = lerp(0,UNITY_ACCESS_INSTANCED_PROP(Props,_FeedBackColor),UNITY_ACCESS_INSTANCED_PROP(Props,_FeedBackAlpha));
				float3 addcolor = saturation(floorC + fresnelswitch + feedbackswitch);
                fixed4 outc = fixed4(addcolor*UNITY_ACCESS_INSTANCED_PROP(Props,_OtherColor).rgb,1);
 
                //Dissolution------
                
                // half4 DissolutionTexVar = tex2D(Dissolution,TRANSFORM_TEX(i.uv,Dissolution));
                fixed4 Dissolution = tex2D(_DissolutionTex, i.uv3);

                fixed dissolve = ((Dissolution.r-(UNITY_ACCESS_INSTANCED_PROP(Props,_Dissolvability))));

                float degree = saturate((dissolve-UNITY_ACCESS_INSTANCED_PROP(Props,_EdgeWidth))*lerp(0,100,UNITY_ACCESS_INSTANCED_PROP(Props,_Eclosion)));
                float A = saturate(dissolve*lerp(0,100,UNITY_ACCESS_INSTANCED_PROP(Props,_Eclosion)));
                outc.rgb = lerp(UNITY_ACCESS_INSTANCED_PROP(Props,_EdgeColor).rgb,outc.rgb,degree);
                fixed worldposHigh =lerp(1,ceil(saturate(normalize(i.posWorld).y)),UNITY_ACCESS_INSTANCED_PROP(Props,_WorldClip));
                outc.a *= UNITY_ACCESS_INSTANCED_PROP(Props,_Alpha)*A*worldposHigh;

				UNITY_APPLY_FOG(i.fogCoord, outc);

				return outc;
			}
			ENDCG
		}
        Pass{
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
            Blend DstColor Zero //正片叠底 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_instancing // 添加实例化支持

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4, _ShadowDir)
            UNITY_DEFINE_INSTANCED_PROP(float4, _ShadowColor)
            UNITY_DEFINE_INSTANCED_PROP(float, _ShadowFalloff)
            UNITY_DEFINE_INSTANCED_PROP(float, _ShadowSwitch)
            UNITY_DEFINE_INSTANCED_PROP(float, _TestInt)
            UNITY_DEFINE_INSTANCED_PROP(float, _TestInt2)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _Alpha)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _WorldClip)
            UNITY_INSTANCING_BUFFER_END(Props)
            // float4 _ShadowDir;
            // float4 _ShadowColor;
            // float _ShadowFalloff,_ShadowSwitch;
            // float _TestInt,_TestInt2;
            // fixed _Alpha;
            // fixed _WorldClip;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v); // 设置实例化ID
                UNITY_TRANSFER_INSTANCE_ID(v, o); // 传递实例化ID

                float3 shadowPos;
                float3 worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;
                float4 shadowDir = UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowDir);
                float3 lightDir = normalize(shadowDir.xyz);

                // shadowPos.y = worldPos.y-v.vertex.y*worldPos.y;
                shadowPos.y = min(worldPos .y , shadowDir.w);
                // shadowPos.y = worldPos.y -  worldPos.y+min(worldPos.y,v.vertex.y);

                // shadowPos.y = (v.vertex.y);
                // _TestInt =worldPos.y-v.vertex.y;
                // shadowPos.y = _TestInt;
 
                // shadowPos.x = worldPos.x - lightDir.x * max(0 ,worldPos.y) / lightDir.y; 
                shadowPos.xz = worldPos.xz - lightDir.xz * max(0 , worldPos.y) / lightDir.y; 
                // shadowPos.x = worldPos.x - lightDir.x * worldPos.y; 
                // shadowPos.z = worldPos.z - lightDir.x * worldPos.y;

                // shadowPos.z = _TestInt2;

                // float3 shadowVertex = float3(shadowPos.x,(worldPos.y-v.vertex.y),shadowPos.z);

                float3 shadowPos2 = float3(shadowPos.x,shadowPos.y,shadowPos.z);
                o.vertex = UnityWorldToClipPos(shadowPos2);

                float3 center =float3( unity_ObjectToWorld[0].w ,shadowDir.w, unity_ObjectToWorld[2].w);
                
                float falloff =1-saturate(distance(shadowPos , center) * UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowFalloff));  //非正片叠底状态下1-

                o.color = UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowColor); 
                // float g = saturate(worldPos.x);
                // o.color = float4(0,1,0,g);
                fixed worldposHigh =lerp(1,ceil(saturate(normalize(worldPos).y)),UNITY_ACCESS_INSTANCED_PROP(Props, _WorldClip));

                o.color.rgb = lerp(fixed3(1,1,1),lerp(fixed3(1,1,1),UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowColor).rgb,falloff),UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowSwitch)*UNITY_ACCESS_INSTANCED_PROP(Props, _Alpha)*worldposHigh); //正片叠底之后给白色.
                // o.color.a = lerp(1,o.color.a*falloff,_ShadowSwitch);
                // o.color.a *= falloff;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i); // 设置实例化ID
                return i.color;
            }
            ENDCG
        }
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        LOD 150
        Blend SrcAlpha OneMinusSrcAlpha
        //outline
        Pass
        {
            Tags{"IgnoreProjector" = "true"}
			ZWrite Off
            Cull Off
            
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
            fixed _OutlineWidth;
            fixed _OutlineSwitch,_Alpha;
            fixed _WorldClip;

            v2f vert (appdata v){
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex+v.normal*float4(_OutlineWidth,_OutlineWidth,_OutlineWidth,0));
                o.uv = v.uv;
                v.vertex.xyz += v.normal * (_OutlineWidth/80);
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
                fixed switchAlpha = lerp(0,_Alpha,_OutlineSwitch)*worldposHigh;
                return fixed4(col.rgb,switchAlpha);
            }
            ENDCG
        }
        Pass {
            Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma multi_compile_fog
			half4 _BackColor,_ForwardColor;
            fixed _FloorSwitch,_SmoothFloor,_LightIntensity;
			sampler2D _MainTex,_Mask,_Specular;  
            float4 _MainTex_ST,_Mask_ST,_Specular_ST;
			half4 _SpecularColor,_LightDir,_FresnelColor,_ClothSpecularColor;
			half _SpecularRange,_Fresnel,_SpecularIntensity,_FresnelToggler,_FresnelPost,_ClothSpecularIntensity,_ClothSpecularRange;
            fixed _Saturation;

            sampler2D _DissolutionTex;
            half4 _DissolutionTex_ST;
            half _Dissolvability,_Eclosion;
            fixed4 _EdgeColor;
            half _EdgeWidth;
            fixed _WorldClip;
            half _ShadowMapRange,_Alpha;
		
			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
				UNITY_FOG_COORDS(4)

			};
			VertexOutput vert (VertexInput v) {
				VertexOutput o ;
				o.uv = v.texcoord0;
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos( v.vertex );

                o.uv3 = TRANSFORM_TEX(v.texcoord0,_DissolutionTex);

				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

            fixed3 saturation(fixed3 Graycolor){
                fixed Gray = .2125*Graycolor.r+.7154*Graycolor.g+.0721*Graycolor.b;
                fixed3 GraySaturationColor = fixed3(Gray,Gray,Gray);
                fixed3 outGrayColor = lerp(GraySaturationColor,Graycolor,_Saturation);
                return outGrayColor;
            }


			float4 frag(VertexOutput i) : COLOR {
				i.normalDir = normalize(i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 normalDirection = i.normalDir;
				float3 lightDirection = normalize(_LightDir.xyz);
				float3 halfDirection = normalize(viewDirection+lightDirection);

				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv, _MainTex));
				float4 _Specular_var = tex2D(_Specular,TRANSFORM_TEX(i.uv, _Specular));
				float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv, _Mask)); //R A:ShadowMap

				
				float lbt =  saturate(dot(lightDirection,i.normalDir)*.5+.5);
				float FloorForward =saturate( floor(lbt*2));

				float lambertB=saturate(pow((lbt-1.0),2 ));
                float FloorB = saturate(pow(1-FloorForward,2));


                float smoothLbt =saturate( (atan((lbt-.5)*(_SmoothFloor*10))/2)+.5);
                float ForwardFloorSwitch = lerp(smoothLbt,FloorForward,_FloorSwitch);
//ShadowMapMask-----
                half shadowMaskVar = pow(saturate(step(_Mask_var.g,_ShadowMapRange))-1,2);
                float3 lambertA =saturate(lerp(_BackColor,_ForwardColor,FloorForward*shadowMaskVar)); 
                float3 lambertD =saturate(lerp(_ForwardColor,_BackColor,saturate(1.0 - (ForwardFloorSwitch*_Mask_var.g))));
                float3 lambertC = lerp(lambertA,lambertD,floor(_ShadowMapRange));
//------        
				float3 gloss = pow(saturate(dot(i.normalDir,halfDirection)),exp2((_SpecularRange*10.0)));
				float3 maskgloss = ((gloss*_Mask_var.r)*_Specular_var)*_SpecularColor.rgb*_SpecularIntensity;


                //ClothGloss
                float3 Clothgloss = pow(saturate(dot(i.normalDir,halfDirection)),exp2((_ClothSpecularRange*10.0)));
				float3 Clothmaskgloss = ((Clothgloss*_Mask_var.g)*_Specular_var)*_ClothSpecularColor.rgb*_ClothSpecularIntensity;

				float3 OutTex = (_MainTex_var.rgb)+maskgloss+Clothmaskgloss;
				float3 floorC =OutTex*lambertC*_LightIntensity;

                //fresnel
				float fresnel=saturate(dot(i.normalDir, viewDirection) ) ;
				float fresnelpower = pow(1.0-fresnel,_Fresnel);
				float3 fresnelswitch=lerp( 0, (((lbt*fresnelpower) * _FresnelPost) / (_FresnelPost - 1)*_FresnelColor.rgb), _FresnelToggler );

                // float3 floorC = lerp(float3(1,0,0),float3(0,1,0),saturate((1.0 - (FloorForward*_Mask_var.g))));

                //out 
				float3 addcolor = saturation(floorC+fresnelswitch);
				fixed4 outc = fixed4(addcolor,1);

                //Dissolution------
                
                // half4 DissolutionTexVar = tex2D(Dissolution,TRANSFORM_TEX(i.uv,Dissolution));
                fixed4 Dissolution = tex2D(_DissolutionTex, i.uv3);

                fixed dissolve = ((Dissolution.r-(_Dissolvability)));

                float degree = saturate((dissolve-_EdgeWidth)*lerp(0,100,_Eclosion));
                float A = saturate(dissolve*lerp(0,100,_Eclosion));
                outc.rgb = lerp(_EdgeColor.rgb,outc.rgb,degree);
                fixed worldposHigh =lerp(1,ceil(saturate(normalize(i.posWorld).y)),_WorldClip);
                outc.a *= _Alpha*A*worldposHigh;

				UNITY_APPLY_FOG(i.fogCoord, outc);

				return outc;
			}
			ENDCG
		}
    }
    SubShader
    {
        NAME "LOWROLE"
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma multi_compile_fog
			half4 _BackColor,_ForwardColor;
            fixed _FloorSwitch,_SmoothFloor,_LightIntensity;
			sampler2D _MainTex,_Mask,_Specular;  
            float4 _MainTex_ST,_Mask_ST,_Specular_ST;
			half4 _SpecularColor,_LightDir,_FresnelColor,_ClothSpecularColor;
			half _SpecularRange,_Fresnel,_SpecularIntensity,_FresnelToggler,_FresnelPost,_ClothSpecularIntensity,_ClothSpecularRange;
		
			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
				UNITY_FOG_COORDS(3)

			};
			VertexOutput vert (VertexInput v) {
				VertexOutput o ;
				o.uv = v.texcoord0;
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos( v.vertex );
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			float4 frag(VertexOutput i) : COLOR {
				i.normalDir = normalize(i.normalDir);
				float3 lightDirection = normalize(_LightDir.xyz);

				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv, _MainTex));
				float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv, _Mask)); //R A:ShadowMap

				
				float lbt =  saturate(dot(lightDirection,i.normalDir)*.5+.5);
				float FloorForward =saturate( floor(lbt*2));

				float lambertB=saturate(pow((lbt-1.0),2 ));
                float FloorB = saturate(pow(1-FloorForward,2));


                float smoothLbt =saturate( (atan((lbt-.5)*(_SmoothFloor*10))/2)+.5);
                float ForwardFloorSwitch = lerp(smoothLbt,FloorForward,_FloorSwitch);

                float3 lambertC =saturate(lerp(_ForwardColor,_BackColor,saturate(1.0 - (ForwardFloorSwitch*_Mask_var.g))));

				float3 OutTex = (_MainTex_var.rgb);
				float3 floorC =OutTex*lambertC*_LightIntensity;
               
                //out 
				float3 addcolor = floorC;

				fixed4 outc = fixed4(addcolor,1);
				UNITY_APPLY_FOG(i.fogCoord, outc);
				return outc;
			}
			ENDCG
		}
    }
}
