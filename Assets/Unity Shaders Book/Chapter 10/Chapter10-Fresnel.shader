Shader "Unity Shader Book/Chapter 10/URP/Reflection Fresnel"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            Name "ForwardLit"


            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma vertex vert
            #pragma fragment frag


            CBUFFER_START(UnityPerMaterial)

                float4 _Color;
                float _FresnelScale;

            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 viewDirWS : TEXCOORD0;
            };
            

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS, true);
                OUT.viewDirWS = GetWorldSpaceNormalizeViewDir(TransformObjectToWorld(IN.positionOS.xyz));

                return OUT;
            }


            half4 frag(Varyings IN) : SV_Target
            {
                float fresnel = pow(1.0 - saturate(dot(IN.normalWS, IN.viewDirWS)), _FresnelScale);
                float4 color = _Color * fresnel;
                float3 reflectVec = reflect(-IN.viewDirWS, IN.normalWS);
                color.xyz *= DecodeHDREnvironment(SAMPLE_TEXTURECUBE(unity_SpecCube0, samplerunity_SpecCube0, reflectVec), unity_SpecCube0_HDR);
                return color;
            }








            ENDHLSL
        }
    }
}
