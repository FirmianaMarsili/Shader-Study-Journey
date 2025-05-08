Shader "Unity Shader Book/Chapter 7/URP/Texture/Normal Map In Tangent Space"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BumpTex ("BumpTex", 2D) = "bump" { }
        _BumpScale ("BumpScale", Float) = 1
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

            TEXTURE2D(_BumpTex);
            SAMPLER(sampler_BumpTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;

                float4 _BumpTex_ST;
                float _BumpScale;
                float4 _Specular;
                float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : POSITION;
                float2 uv : TEXCOORD0;
                
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                //float2 bumpUV : TEXCOORD4;
                float3 positionWS : TEXCOORD5;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                //OUT.bumpUV = TRANSFORM_TEX(IN.uv, _BumpTex); //这个是法线纹理使用自己st
                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                
                
                OUT.normalWS = normalInput.normalWS;
                OUT.bitangentWS = normalInput.bitangentWS;
                OUT.tangentWS = normalInput.tangentWS;
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);


                // float3x3 ttwMatrix = float3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS); //t tb n

                // // Light light = GetMainLight();
                // OUT.lightDirTS = TransformWorldToTangentDir(normalize(light.direction), ttwMatrix, true);
                // OUT.vieDirTS = TransformWorldToTangentDir(GetWorldSpaceNormalizeViewDir(positionWS.xyz), ttwMatrix, true);

                // OUT.lightColor = light.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //float4 bump = SAMPLE_TEXTURE2D(_BumpTex, sampler_BumpTex, IN.bumpUV);
                float4 bump = SAMPLE_TEXTURE2D(_BumpTex, sampler_BumpTex, IN.uv);
                
                float3 tangentNormal = UnpackNormalScale(bump, _BumpScale);
                //x^2 + y^2 + z^2 = 1
                //tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;


                /*
                TangentToWorld = [ T.x  B.x  N.x ]
                                [ T.y  B.y  N.y ]
                                [ T.z  B.z  N.z ]
                */
                float3x3 ttwMatrix = float3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS);

                Light light = GetMainLight();
                
                float3 lightDirTS = TransformWorldToTangentDir(normalize(light.direction), ttwMatrix, true);
                float3 diffuse = light.color.rgb * albedo * max(0, dot(tangentNormal, lightDirTS));

                float3 viewDirTS = TransformWorldToTangentDir(GetWorldSpaceNormalizeViewDir(IN.positionWS), ttwMatrix, true);
                float3 halfDir = normalize(lightDirTS + viewDirTS);
                float3 specular = light.color.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1);
            }
            ENDHLSL
        }
    }
}
