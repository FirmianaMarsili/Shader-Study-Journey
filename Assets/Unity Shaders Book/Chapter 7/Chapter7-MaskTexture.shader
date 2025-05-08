Shader "Unity Shader Book/Chapter 7/URP/Texture/Mask Texture"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" { }
        _BumpTex ("BumpTex", 2D) = "bump" { }
        _BumpScale ("BumpScale", Float) = 1
        _SpecularMask ("SpecularMask", 2D) = "white" { }
        _SpecularScale ("Specular Scale", Float) = 1
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

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
                float4 _BumpTex_ST;
                float _BumpScale;
                float4 _SpecularMask_ST;
                float _SpecularScale;
                float4 _Specular;
                float _Gloss;
            CBUFFER_END

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_BumpTex); SAMPLER(sampler_BumpTex);
            TEXTURE2D(_SpecularMask);SAMPLER(sampler_SpecularMask);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDirTS : TEXCOORD1;
                float3 viewDirTS : TEXCOORD2;
                float3 lightColor : TEXCOORD3;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                float3x3 ttwMatrix = float3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS);
                Light light = GetMainLight();
                OUT.lightDirTS = TransformWorldToTangentDir(light.direction, ttwMatrix, true);
                OUT.viewDirTS = TransformWorldToTangentDir(GetWorldSpaceNormalizeViewDir(TransformObjectToWorld(IN.positionOS.xyz)), ttwMatrix, true);
                OUT.lightColor = light.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpTex, sampler_BumpTex, IN.uv), _BumpScale);
                float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                float3 diffuse = IN.lightColor.rgb * albedo * max(0, dot(normalTS, IN.lightDirTS));

                float3 halfDir = normalize(IN.viewDirTS + IN.viewDirTS);
                float specularMask = SAMPLE_TEXTURE2D(_SpecularMask, sampler_SpecularMask, IN.uv).r * _SpecularScale;
                float3 specular = IN.lightColor.rgb * _Specular.rgb * pow(max(0, dot(normalTS, halfDir)), _Gloss) * specularMask;


                return half4(ambient + diffuse + specular, 1);
            }

            ENDHLSL
        }
    }
}
