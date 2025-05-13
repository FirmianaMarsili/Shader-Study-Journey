Shader "Shadertoy/URP/Zippy Zaps [399 Chars]"
{
    Properties
    {
        //maybe 1024
        _MainTex ("Main Tex", 2D) = "white" { }
        _Resolution ("Resolution", Range(1, 2048)) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float _Resolution;
                float4 _MainTex_ST;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 u = IN.uv * _Resolution;
                float2 v = float2(_Resolution, _Resolution);
                u = 0.2 * (u + u - v) / v.y;
                float4 z = float4(1, 2, 3, 0);
                float4 o = z;
                for (float a = 0.5, t = _Time.y, i; ++i < 19; o += (1 + cos(z + t)) / length((1 + i * dot(v, v)) * sin(1.5 * u / (0.5 - dot(u, u)) - 9 * u.yx + t)))
                {
                    v = cos(++t - 7 * u * pow(abs(a += 0.03), i)) - 5 * u;
                    u += tanh(40 * dot(u = mul(u, ((float2x2)cos(i + 0.02 * t - float4(0, 11, 33, 0)))), u) * cos(100 * u.yx + t)) / 200 + 0.2 * a * u + cos(4 / exp(dot(o, o) / 100) + t) / 300;
                }

                o = 25.6 / (min(o, 13) + 164 / o) - dot(u, u) / 250;
                return half4(o);
            }

            




            ENDHLSL
        }
    }
}
