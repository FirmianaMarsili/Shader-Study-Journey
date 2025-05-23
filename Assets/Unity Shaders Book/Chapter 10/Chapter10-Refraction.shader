Shader "Unity Shader Book/Chapter 10/URP/Refraction"
{
    Properties
    {
        _RefractAmount ("Refract Amount", Range(0, 1)) = 1.0
        _Cubemap ("Refraction Cubmap", Cube) = "_Skybox" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalRenderPipeline" }

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
                float3 normalWS : NORMAL;
                float3 viewWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float _RefractAmount;
            CBUFFER_END

            TEXTURECUBE(_Cubemap);
            SAMPLER(sampler_Cubemap);
            

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
                half2 screenUV = IN.positionHCS.xy / _ScreenParams.xy;
                half ratio = (1 - pow(dot(IN.normalWS, IN.viewWS), 2.0)) * _RefractAmount;
                float3 refractionOffset = _RefractAmount * TransformWorldToViewDir(IN.normalWS) * ratio;
                half4 col = SAMPLE_TEXTURECUBE(_Cubemap, sampler_Cubemap, refractionOffset +float3(screenUV, 0));
                
                return col;
            }

            ENDHLSL
        }
    }
}
