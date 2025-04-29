Shader "Unity Shaders Book/Chapter 6/URP/Diffuse/Diffuse Vertex-Level"
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

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : POSITION;
                float3 color : COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Diffuse;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz).xyz;
                Light mainLight = GetMainLight();
                float3 lightDirWS = normalize(mainLight.direction);
                float NdotL = saturate(dot(normalWS, lightDirWS));
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 diffuse = mainLight.color.rgb * _Diffuse.rgb * NdotL; //I=LightColor∗max(0,N⋅L)
                OUT.color = ambient + diffuse;
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return half4(IN.color, 1.0);
            }

            ENDHLSL
        }
    }
}