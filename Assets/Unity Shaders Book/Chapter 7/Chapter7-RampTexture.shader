Shader "Unity Shader Book/Chapter 7/URP/Texture/Ramp Texture"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _RampTex ("RampTex", 2D) = "white" { }
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
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
            
            TEXTURE2D(_RampTex);
            SAMPLER(sampler_RampTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _RampTex_ST;
                float4 _Specular;
                float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                

                OUT.uv = TRANSFORM_TEX(IN.uv, _RampTex);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal, true);



                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {

                Light light = GetMainLight();
                float3 lightDir = normalize(light.direction);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float halfLambert = 0.5 * dot(IN.normalWS, lightDir) + 0.5;
                float2 tempUV = float2(halfLambert, halfLambert);
                float3 diffuseColor = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, tempUV).rgb * _Color.rgb;
                float3 diffuse = light.color.rgb * diffuseColor;

                float3 viewDir = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                float3 halfDir = normalize(lightDir + viewDir);
                float3 specular = light.color.rgb * _Specular.rgb * pow(max(0, dot(IN.normalWS, halfDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1);
            }

            ENDHLSL
        }
    }
}
