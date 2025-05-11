Shader "Lakehani/URP/Lighting/ReflectionProbe"
{
    Properties
    {
        _ReflectAmount ("Reflect Amount", Range(0, 1)) = 1.0
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
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 viewWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float _ReflectAmount;
            CBUFFER_END


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

                float amount = 1 - _ReflectAmount;
                float mip = PerceptualRoughnessToMipmapLevel(amount);
                float3 reflectVec = reflect(-IN.viewWS, IN.normalWS);
                float3 reflection = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, mip), unity_SpecCube0_HDR);

                return half4(reflection, 1);
            }

            ENDHLSL
        }
    }
}