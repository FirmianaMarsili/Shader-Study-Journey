Shader "Unity Shader Book/Chapter 8/URP/Alpha Test"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" { }
        _Cutoff ("Cutoff", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "TransparentCutout" "IgnoreProjector" = "True" "Queue" = "AlphaTest" "RenderPipeline" = "UniversalPipeline" }
        pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)

                float4 _Color;
                float4 _MainTex_ST;
                float _Cutoff;

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
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal, true);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                clip(texColor.a - _Cutoff);

                Light light = GetMainLight();

                float3 lightDir = normalize(light.direction);

                float3 albedo = texColor.rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                float3 diffuse = light.color.rgb * albedo * max(0, dot(IN.normalWS, lightDir));

                return half4(albedo + ambient + diffuse, 1);
            }

            
            ENDHLSL
        }
    }
}
