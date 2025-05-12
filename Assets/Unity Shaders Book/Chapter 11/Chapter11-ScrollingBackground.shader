Shader "Unity Shader Book/Chapter 11/URP/Scrolling Background"
{
    Properties
    {
        _MainTex ("Base Layer (RGB)", 2D) = "white" { }
        _DetailTex ("2nd Layer (RGB)", 2D) = "white" { }
        _ScrollX ("Base layer Scroll Speed", Float) = 1
        _Scroll2X ("2nd layer Scroll Speed", Float) = 1
        _Multiplier ("Layer Multiplier", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            Name "ForwardLit"

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
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            ENDHLSL
        }
    }
}
