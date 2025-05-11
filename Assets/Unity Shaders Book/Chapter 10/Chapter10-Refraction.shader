Shader "Unity Shader Book/Chapter 10/URP/Refraction"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _RefractColor ("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractAmount ("Refraction Amount", Range(0, 1)) = 1
        _RefractRatio ("Refraction Ratio", Range(0.1, 1)) = 0.5
        _Cubemap ("Refraction Cubmap", Cube) = "_Skybox" { }
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
                float4 _RefractColor;
                float _RefractAmount;
                float _RefractRatio;
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
                float3 refractionWS : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS, true);
                OUT.viewDirWS = GetWorldSpaceViewDir(OUT.positionWS);
                OUT.refractionWS = refract(-OUT.viewDirWS, OUT.viewDirWS, _RefractRatio);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {


                Light light = GetMainLight();
                float3 lightDir = normalize(light.direction);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 diffuse = LightingLambert(light.color.rgb, lightDir, IN.normalWS) * _Color.rgb;
                float3 refraction = SAMPLE_TEXTURECUBE(_Cubemap, sampler_Cubemap, IN.refractionWS).rgb * _RefractColor.rgb;
                float3 color = ambient + lerp(diffuse, refraction, _RefractAmount);
                return half4(color, 1);
            }

            ENDHLSL
        }
    }
}
