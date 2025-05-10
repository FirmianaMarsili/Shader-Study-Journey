Shader "Unity Shader Book/Chapter 9/URP/Forward Rendering"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _Diffuse;
                float4 _Specular;
                float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal, true);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight();
                float3 mainLightDir = normalize(mainLight.direction);
                float3 diffuse = LightingLambert(mainLight.color.rgb, mainLightDir, IN.normalWS) * _Diffuse.rgb;

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * diffuse;

                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                float3 halfDir = normalize(viewDirWS + mainLightDir);
                
                float3 specular = LightingSpecular(mainLight.color.rgb, mainLightDir, IN.normalWS, viewDirWS, _Specular, _Gloss);

                int additionalLightsCount = GetAdditionalLightsCount();

                for (int index = 0; index < additionalLightsCount; index++)
                {
                    Light light = GetAdditionalLight(index, IN.positionWS);
                    float3 lightDir = normalize(light.direction);
                    specular += LightingSpecular(light.color.rgb * light.distanceAttenuation, lightDir, IN.normalWS, viewDirWS, _Specular, _Gloss);
                }


                return half4(ambient + diffuse + specular, 1);
            }


            ENDHLSL
        }
    }
}
