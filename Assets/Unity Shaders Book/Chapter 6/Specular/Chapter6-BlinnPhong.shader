Shader "Unity Shaders Book/Chapter 6/URP/Specular/BlinnPhong"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
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
                float4 _Specular;
                float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : POSITION;
                float3 normal : NORMAL;
                float3 positionWS : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                Light light = GetMainLight();

                float3 worldLightDir = normalize(light.direction);
                float3 diffuse = light.color.rgb * _Diffuse.rgb * saturate(dot(IN.normal, worldLightDir));

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.positionWS);
                float3 halfDir = normalize(viewDir + worldLightDir);
                float3 specular = light.color.rgb * _Specular.rgb * pow(max(0, dot(IN.normal, halfDir)), _Gloss); //I_specular = k_s * L_specular * max(0, N . H)^p      H = (L + V) / |L + V|
                return half4(ambient + diffuse + specular, 1.0);
            }


            ENDHLSL
        }
    }
}
