Shader "Unity Shaders Book/Chapter 6/URP/Diffuse/HalfLambert"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _Diffuse;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normal : NORMAL;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal = TransformObjectToWorldNormal(IN.normalOS, true);



                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                Light light = GetMainLight();

                float3 worldLightDir = normalize(light.direction);
                
                float NDotL = 0.5 * dot(IN.normal, worldLightDir) + 0.5;

                float3 diffuse = light.color.xyz * _Diffuse.xyz * NDotL; //I=LightColor∗(N⋅L * 0.5 + 0.5)

                return half4(diffuse + ambient, 1);
            }

            ENDHLSL
        }
    }
}
