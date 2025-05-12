Shader "Unity Shader Book/Chapter 10/URP/Image Sequensce Animation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Image Sequence", 2D) = "white" { }
        _HorizontalAmount ("Horizontal Amount", Float) = 8
        _VerticalAmount ("Vertical Amount", Float) = 8
        _Speed ("Speed", Range(1, 100)) = 30
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Name "ForwardLit"

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
                float _HorizontalAmount;
                float _VerticalAmount;
                float _Speed;
            CBUFFER_END

            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS, true);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float time = floor(_Time.y * _Speed); //if time = 90
                float row = floor(time / _HorizontalAmount); // floor(90 / 8) = 11
                float column = time - row * _VerticalAmount; // 90 - 11 * 8 = 3
                float2 uv = IN.uv + float2(column, -row);
                uv.x = fmod(uv.x / _HorizontalAmount, 1);// (3 / 8) = 0.375
                uv.y = fmod(uv.y / _VerticalAmount, 1); // (11 / 8) = 0.375
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                color *= _Color;

                return half4(color);
            }


            ENDHLSL
        }
    }
}
