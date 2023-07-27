Shader "Custom/Toon Diether"
{
    Properties
    {
        [MainColor] _BaseColor("BaseColor", Color) = (1,1,1,1)
        [MainTexture] _BaseMap("BaseMap", 2D) = "white" {}
        _RedColCount("Red Color Count", Int) = 5
        _GrnColCount("Green Color Count", Int) = 5
        _BluColCount("Blue Color Count", Int) = 5
        _Spread("Spread", Float) = 0
        _DitherScale("Dither Scale", Int) = 10
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_ST;
        half4 _BaseColor;
        int _RedColCount, _GrnColCount, _BluColCount, _DitherScale;
        float _Spread;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // Universal Render Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
        
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"        
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normal: NORMAL;
                float2 uv           : TEXCOORD0;
            };
            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;
                float4 positionHCS  : SV_POSITION;
                float3 norm : TEXCOORD2;
                float4 shadowCoord  : TEXCOORD6;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            static const int bayer8[8 * 8] = {
                0, 32, 8, 40, 2, 34, 10, 42,
                48, 16, 56, 24, 50, 18, 58, 26,  
                12, 44,  4, 36, 14, 46,  6, 38, 
                60, 28, 52, 20, 62, 30, 54, 22,  
                3, 35, 11, 43,  1, 33,  9, 41,  
                51, 19, 59, 27, 49, 17, 57, 25, 
                15, 47,  7, 39, 13, 45,  5, 37, 
                63, 31, 55, 23, 61, 29, 53, 21
            };
            float GetBayer8(int x, int y) {
                return float(bayer8[(x % 8) + (y % 8) * 8]) * (1.0f / 64.0f) - 0.5f;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);// GetVertexPositionInputs computes position in different spaces (ViewSpace, WorldSpace, Homogeneous Clip Space)
                OUT.positionHCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.shadowCoord = GetShadowCoord(positionInputs);
                OUT.norm = IN.normal;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight(IN.shadowCoord);
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                color *= mainLight.shadowAttenuation;                

                float2 pixelCoord = floor(IN.positionHCS.xy / _DitherScale);
                float spread = _Spread * (1 + IN.norm);
                float4 output = color + spread * GetBayer8(pixelCoord.x,pixelCoord.y);
                output.r = floor((_RedColCount - 1.0f) * output.r + 0.5) / (_RedColCount - 1.0f);
                output.g = floor((_GrnColCount - 1.0f) * output.g + 0.5) / (_GrnColCount - 1.0f);
                output.b = floor((_BluColCount - 1.0f) * output.b + 0.5) / (_BluColCount - 1.0f);
                return output;
            }
            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}