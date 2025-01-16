Shader "XSJ/VFX/ShuiMo"
{
    Properties
    {
        _Alpha("Alpha", Range(0,5)) = 1
		_Color("Color", Color) = (0,0,0,0)
		_DisTex("溶解贴图", 2D) = "white" {}
		_DisPro("溶解过程", Range(0,1)) = 0
		_Feathering("边缘羽化", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" }
        LOD 100
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            sampler2D _DisTex;
            fixed4 _DisTex_ST,_Color;
            fixed _Alpha,_DisPro,_Feathering;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 viewer : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewer = normalize(_WorldSpaceCameraPos.xyz- mul(unity_ObjectToWorld,v.vertex));
                o.uv1 = TRANSFORM_TEX(v.uv1,_DisTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 NormalDir = normalize(i.normal);
                fixed3 worldNormal = mul(unity_WorldToObject,fixed4(NormalDir,0));
                fixed dotNV = dot(worldNormal,i.viewer);
			    float NVAlpha = clamp(pow(((dotNV+1.0)*0.5*_Alpha),2.2),0,1);
                //float2 uv1_DisTex = i.uv * _DisTex_ST.xy + _DisTex_ST.zw;
			    float FeatheringLerp = lerp( 1.0 , 50.0 , _Feathering);
			    float clampResult19 = clamp(((tex2D( _DisTex, i.uv1).a - _DisPro ) * FeatheringLerp ) , 0.0 , 1.0 );
			    fixed Alpha = ( NVAlpha * clampResult19 );
                fixed4 outC = fixed4(_Color.rgb,Alpha);
                return outC;
            }
            ENDCG
        }
    }
}
