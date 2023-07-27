Shader "Custom/toonDither3"
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
         //_MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}

        // Include material cbuffer for all passes. 
        // The cbuffer has to be the same for all passes to make this shader SRP batcher compatible.
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
            
            // -------------------------------------
            // Universal Render Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                      
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;
                float4 positionHCS  : SV_POSITION;
                float4 shadowCoord  : TEXCOORD6;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);



            
            //int _RedColCount, _GrnColCount, _BluColCount , _BayerLevel;

            static const int bayer2[2 * 2] = {
                0, 2,
                3, 1
            };

            static const int bayer4[4 * 4] = {
                0, 8, 2, 10,
                12, 4, 14, 6,
                3, 11, 1, 9,
                15, 7, 13, 5
            };

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

            float GetBayer2(int x, int y) {
                return float(bayer2[(x % 2) + (y % 2) * 2]) * (1.0f / 4.0f) - 0.5f;
            }

            float GetBayer4(int x, int y) {
                return float(bayer4[(x % 4) + (y % 4) * 4]) * (1.0f / 16.0f) - 0.5f;
            }

            float GetBayer8(int x, int y) {
                return float(bayer8[(x % 8) + (y % 8) * 8]) * (1.0f / 64.0f) - 0.5f;
            }


            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // GetVertexPositionInputs computes position in different spaces (ViewSpace, WorldSpace, Homogeneous Clip Space)
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionHCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.shadowCoord = GetShadowCoord(positionInputs);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.positionOS.xyz);
                Light mainLight = GetMainLight(IN.shadowCoord);
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                //half4 color = half4(IN.uv.x,IN.uv.y, 0, 0);
                color *= mainLight.shadowAttenuation;                

                float2 pixelCoord = floor(IN.positionHCS.xy / _DitherScale);
                float4 output = color + _Spread * GetBayer8(pixelCoord.x,pixelCoord.y);
                output.r = floor((_RedColCount - 1.0f) * output.r + 0.5) / (_RedColCount - 1.0f);
                output.g = floor((_GrnColCount - 1.0f) * output.g + 0.5) / (_GrnColCount - 1.0f);
                output.b = floor((_BluColCount - 1.0f) * output.b + 0.5) / (_BluColCount - 1.0f);
                return output;

                /*
                float2 uv = (IN.positionHCS / _ScreenParams.xy) * _BaseMap_ST.xy + _BaseMap_ST.zw;
                //half3 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv) * _BaseColor;
                //return half4(baseColor.r,baseColor.g,baseColor.b,0);
                
                float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                //half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                //half4 color = half4(IN.uv.x,IN.uv.y, 0, 0);
                half4 color = half4(uv.x,uv.y, 0, 0);
                color *= mainLight.shadowAttenuation;
                
                return color;

                float4 output = color + _Spread * GetBayer8(0,0);
                output.r = floor((_RedColCount - 1.0f) * output.r + 0.5) / (_RedColCount - 1.0f);
                output.g = floor((_GrnColCount - 1.0f) * output.g + 0.5) / (_GrnColCount - 1.0f);
                output.b = floor((_BluColCount - 1.0f) * output.b + 0.5) / (_BluColCount - 1.0f);
                return output;
                */
            }
            ENDHLSL
        }

/*
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float _Spread;
            int _RedColCount, _GrnColCount, _BluColCount , _BayerLevel;

            static const int bayer2[2 * 2] = {
                0, 2,
                3, 1
            };

            static const int bayer4[4 * 4] = {
                0, 8, 2, 10,
                12, 4, 14, 6,
                3, 11, 1, 9,
                15, 7, 13, 5
            };

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

            float GetBayer2(int x, int y) {
                return float(bayer2[(x % 2) + (y % 2) * 2]) * (1.0f / 4.0f) - 0.5f;
            }

            float GetBayer4(int x, int y) {
                return float(bayer4[(x % 4) + (y % 4) * 4]) * (1.0f / 16.0f) - 0.5f;
            }

            float GetBayer8(int x, int y) {
                return float(bayer8[(x % 8) + (y % 8) * 8]) * (1.0f / 64.0f) - 0.5f;
            }

            fixed4 fp(v2f i) : SV_Target {
                float4 col = _MainTex.Sample(point_clamp_sampler, i.uv);

                int x = i.uv.x * _MainTex_TexelSize.z;
                int y = i.uv.y * _MainTex_TexelSize.w;

                float bayerValues[3] = { 0, 0, 0 };
                bayerValues[0] = GetBayer2(x, y);
                bayerValues[1] = GetBayer4(x, y);
                bayerValues[2] = GetBayer8(x, y);

                float4 output = col + _Spread * bayerValues[_BayerLevel];

                output.r = floor((_RedColCount - 1.0f) * output.r + 0.5) / (_RedColCount - 1.0f);
                output.g = floor((_GrnColCount - 1.0f) * output.g + 0.5) / (_GrnColCount - 1.0f);
                output.b = floor((_BluColCount - 1.0f) * output.b + 0.5) / (_BluColCount - 1.0f);

                return output;
            }
            ENDCG
        }

*/
        // Used for rendering shadowmaps
        // TODO: there's one issue with adding this UsePass here, it won't make this shader compatible with SRP Batcher
        // as the ShadowCaster pass from Lit shader is using a different UnityPerMaterial CBUFFER. 
        // Maybe we should add a DECLARE_PASS macro that allows to user to inform the UnityPerMaterial CBUFFER to use?
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}