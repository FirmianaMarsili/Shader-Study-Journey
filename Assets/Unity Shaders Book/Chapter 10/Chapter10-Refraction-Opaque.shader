
Shader "Unity Shader Book/Chapter 10/URP/Refraction Opaque Texture"
{
    Properties
    {
        _RefractAmount ("Refract Amount", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 viewWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float _RefractAmount;
            CBUFFER_END
            
            TEXTURE2D(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS, true);
                OUT.viewWS = GetWorldSpaceNormalizeViewDir(positionWS);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 screenUV = IN.positionHCS.xy / _ScreenParams.xy;
                half ratio = (1 - pow(dot(IN.normalWS, IN.viewWS), 2.0)) * _RefractAmount;
                float3 refractionOffset = _RefractAmount * TransformWorldToViewDir(IN.normalWS) * ratio;
                half4 col = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV + refractionOffset.xy);
                
                return col;
            }

            ENDHLSL
        }
    }
}