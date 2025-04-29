Shader "Unity Shaders Book/Chapter 6/URP/Specular/Specular Vertex-Level"
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
                float3 color : COLOR;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 worldNormal = TransformObjectToWorldNormal(IN.normalOS);
                Light light = GetMainLight();

                float3 worldLightDir = normalize(light.direction);
                float3 diffuse = light.color.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                float3 reflectDir = normalize(reflect(-worldLightDir, worldNormal)); //这里注意是反射的入射光线方向
                float3 viewDir = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(IN.positionOS.xyz));
                float3 specular = light.color.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);//I=LightColor∗pow(max(0,R⋅V),α)   R=2(N⋅L)N−L
                OUT.color = ambient + specular + diffuse;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return half4(IN.color, 1);
            }



            ENDHLSL
        }
    }
}
