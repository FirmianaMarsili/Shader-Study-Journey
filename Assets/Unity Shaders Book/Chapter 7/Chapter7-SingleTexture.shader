Shader "Unity Shader Book/Chapter 7/URP/Texture/Single Texture"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 255)) = 20
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

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST; // _ST代表着这个纹理的缩放 .xy => Scale和平移 .zw => Tiling
                float4 _Color;
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
                float4 positionHCS : POSITION;
                float3 normal : NORMAL;
                float3 positionWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal = TransformObjectToWorldNormal(IN.normal);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 albedo = (SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color).rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                Light light = GetMainLight();
                float3 worildLightDir = normalize(light.direction);
                float3 diffuse = light.color.rgb * albedo * saturate(dot(IN.normal, worildLightDir));
                float3 reflectDir = normalize(reflect(-worildLightDir, IN.normal));
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.positionWS);
                float3 specular = light.color.rgb * _Specular.rgb * pow(max(0, dot(reflectDir, viewDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1);
            }

            ENDHLSL
        }
    }
}
