Shader "Unity Shader Book/Chapter 11/URP/Scrolling Background"
{
    Properties
    {
        _MainTex ("Far (RGB)", 2D) = "white" { }
        _DetailTex ("Near (RGB)", 2D) = "white" { }
        _ScrollX ("Far Scroll Speed", Float) = 1
        _Scroll2X ("Near Scroll Speed", Float) = 1
        _Multiplier ("Layer Multiplier", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            Name "ForwardLit"

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _DetailTex_ST;
                float _ScrollX;
                float _Scroll2X;
                float _Multiplier;

            CBUFFER_END

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_DetailTex); SAMPLER(sampler_DetailTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_detail : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_detail : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex) + frac(float2(_ScrollX, 0) * _Time.y) ;
                OUT.uv_detail = TRANSFORM_TEX(IN.uv_detail, _DetailTex) + frac(float2(_Scroll2X, 0) * _Time.y);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float4 first = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float4 second = SAMPLE_TEXTURE2D(_DetailTex, sampler_DetailTex, IN.uv_detail);
                float4 color = lerp(first, second, second.a);
                color.rgb *= _Multiplier;
                return color;
            }



            ENDHLSL
        }
    }
}
