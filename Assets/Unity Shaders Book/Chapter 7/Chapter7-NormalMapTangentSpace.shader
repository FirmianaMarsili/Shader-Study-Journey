Shader "Unity Shader Book/Chapter 7/URP/Texture/Normal Map In Tangent Space"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        _BumpTex ("BumpTex", 2D) = "bump" { }
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

                float4 _BumpText_ST;
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
                float3 lightDirTS : TEXCOORD1;
                float3 vieDirTS : TEXCOORD2;
                float3 lightColor : TEXCOORD3;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                /*
                TangentToWorld = [ T.x  B.x  N.x ]
                                [ T.y  B.y  N.y ]
                                [ T.z  B.z  N.z ]
                */

                float3x3 ttwMatrix = float3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS); //t tb n

                Light light = GetMainLight();
                OUT.lightDirTS = TransformWorldToTangentDir(normalize(light.direction), ttwMatrix, true);
                OUT.vieDirTS = TransformWorldToTangentDir(GetWorldSpaceNormalizeViewDir(IN.positionOS.xyz), ttwMatrix, true);

                OUT.lightColor = light.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float4 normal = SAMPLE_TEXTURE2D(_BumpTex, sampler_BumpTex, IN.uv);
                
                float3 tangentNormal = UnpackNormalScale(normal, _BumpScale);
                //x^2 + y^2 + z^2 = 1
                //tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                float3 diffuse = IN.lightColor * albedo * max(0, dot(tangentNormal, IN.lightDirTS));
                float3 halfDir = normalize(IN.lightDirTS + IN.vieDirTS);
                float3 specular = IN.lightColor.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1);
            }
            ENDHLSL
        }
    }
}
