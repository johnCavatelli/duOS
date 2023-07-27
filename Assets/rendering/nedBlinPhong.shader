Shader "Cavatelli/MyLit" {
    // Properties are options set per material, exposed by the material inspector
    Properties{
        [Header(Surface options)] // Creates a text header
        // [MainTexture] and [MainColor] allow Material.mainTexture and Material.color to use the correct properties
        [MainTexture] _ColorMap("Color", 2D) = "white" {}
        [MainColor] _ColorTint("Tint", Color) = (1, 1, 1, 1)
        _Smoothness("Smoothness", Float) = 0
    }
    // Subshaders allow for different behaviour and options for different pipelines and platforms
    SubShader {
        // These tags are shared by all passes in this sub shader
        Tags {"RenderPipeline" = "UniversalPipeline"}

        // Shaders can have several passes which are used to render different data about the material
        // Each pass has it's own vertex and fragment function and shader variant keywords
        Pass {
            Name "ForwardLit" // For debugging
            Tags{"LightMode" = "UniversalForward"} // Pass specific tags. 
            // "UniversalForward" tells Unity this is the main lighting pass of this shader

            HLSLPROGRAM // Begin HLSL code

            #define _SPECULAR_COLOR

            // Shader variant keywords
            // Unity automatically discards unused variants created using "shader_feature" from your final game build,
            // however it keeps all variants created using "multi_compile"
            // For this reason, multi_compile is good for global keywords or keywords that can change at runtime
            // while shader_feature is good for keywords set per material which will not change at runtime

            // Global URP keywords
#if UNITY_VERSION >= 202120
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
#else
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#endif
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            // Register our programmable stage functions
            #pragma vertex Vertex
            #pragma fragment Fragment

            // Include our code file
            #include "MyLitForwardLitPass.hlsl"
            ENDHLSL
        }

        Pass {
            // The shadow caster pass, which draws to shadow maps
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0 // No color output, only depth

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "MyLitShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}