Shader "Unity Shader Book/Chapter 10/URP/Reflection"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _ReflectColor ("Reflection Color", Color) = (1, 1, 1, 1)
        _ReflectAmount ("Reflect Amount", Range(0, 1)) = 1
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" { }
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }

        pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _ReflectColor;
                float _ReflectAmount;

            CBUFFER_END

            TEXTURECUBE(_Cubemap); SAMPLER(sampler_Cubemap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
                float3 reflectWS : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformViewToWorldNormal(IN.normalOS, true);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = TransformWorldToViewDir(OUT.positionWS);
                OUT.reflectWS = normalize(reflect(-OUT.viewDirWS, OUT.viewDirWS));
                


                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light light = GetMainLight();
                float3 lightDirWS = normalize(light.direction);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 diffuse = LightingLambert(light.color, lightDirWS, IN.normalWS) * _Color.rgb;

                float3 reflection = SAMPLE_TEXTURECUBE(_Cubemap, sampler_Cubemap, IN.reflectWS).rgb * _ReflectColor.rgb;

                float3 color = ambient + lerp(diffuse, reflection, _ReflectAmount);

                return half4(color, 1);
            };

            ENDHLSL
        }
    }
}
