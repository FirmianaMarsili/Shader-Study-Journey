Shader "Unity Shader Book/Chapter 7/URP/Texture/Normal Map In Tangent Space"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        _BumpTex ("BumpTex", 2D) = "bump" { }
        _BumpScale ("BumpScale", Float) = 1
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 255)) = 20
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            Name = "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex)
            SAMPLER(sampler_MainTex)

            TEXTURE2D(_BumpTex)
            SAMPLER(sampler_BumpTex)

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;

                float4 _BumpText_ST;
                float _BumpScale;
                float4 _Specular;
                float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            //todo: vert
            ENDHLSL
        }
    }
}
