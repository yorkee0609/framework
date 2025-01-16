Shader "XSJ/VFX/Distortion(GrabPass)"
{
    Properties
    {
        _DistortStrength("热扰动强度",Range(0,1)) = 0.5
        _DistortVelocity("热扰动速率",Range(0,1)) = 0.5
        _XDensity("噪声密度(水平)",float) = 1
        _YDensity("噪声密度(竖直)",float) = 1
        _NoiseTex("噪声贴图",2D) = "white"{} 
        _Mask("噪声遮罩",2D) = "Black"{}

    }
    SubShader
    {   
        Tags{
             "RenderType" = "Transparent"
             "Queue" = "Transparent+1"
             "DisableBatching"="True"
            }
        Zwrite Off
        GrabPass{"_GrabTex"}
        Cull Off

        Pass
        { 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 grabPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
            };

            sampler2D _GrabTex;
            sampler2D _NoiseTex;
            sampler2D _Mask;
            float _XDensity;
            float _YDensity;
            float4 _NoiseTex_ST;
            fixed _DistortStrength;
            fixed _DistortVelocity;

            v2f vert (appdata_base v)
            {
                v2f o;
        float3 center = float3(0, 0, 0);
        float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
        float3 normalDir = normalize(viewer - center);
        float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
        float3 rightDir = normalize(cross(upDir, normalDir));
        upDir = normalize(cross(normalDir, rightDir));
        float3 centerOff = v.vertex.xyz - center;
        float3 localPos = center + rightDir * centerOff.x + center + upDir * centerOff.y + center + normalDir * centerOff.z;

        o.pos = UnityObjectToClipPos(float4(localPos,1));
        o.grabPos = ComputeGrabScreenPos(o.pos);

        _NoiseTex_ST.xy *=float2(_XDensity,_YDensity);
        o.uv.xy = TRANSFORM_TEX(v.texcoord, _NoiseTex);
        o.uv.zw = v.texcoord;
        o.uv.xy -= _Time.y * _DistortVelocity;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                float2 offset = tex2D(_NoiseTex,i.uv.xy).xy;
                offset = (offset - 0.5) * 2* _DistortStrength;
                i.grabPos.xy += tex2D(_Mask, i.uv.zw).x*offset;
                fixed4 color = tex2Dproj(_GrabTex,i.grabPos);
                return color;
                 
            }
            ENDCG
        }
    }
}