// UNITY_SHADER_NO_UPGRADE
#ifndef UNITY_GRAPHFUNCTIONS_INCLUDED
#define UNITY_GRAPHFUNCTIONS_INCLUDED

// ----------------------------------------------------------------------------
// Included in generated graph shaders
// ----------------------------------------------------------------------------

float4 ComputeScreenPos (float4 pos, float projectionSign)
{
  float4 o = pos * 0.5f;
  o.xy = float2(o.x, o.y * projectionSign) + o.w;
  o.zw = pos.zw;
  return o;
}

struct Gradient
{
    int type;
    int colorsLength;
    int alphasLength;
    float4 colors[8];
    float2 alphas[8];
};

Gradient NewGradient(int type, int colorsLength, int alphasLength,
    float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
    float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
{
    Gradient output = 
    {
        type, colorsLength, alphasLength,
        {colors0, colors1, colors2, colors3, colors4, colors5, colors6, colors7},
        {alphas0, alphas1, alphas2, alphas3, alphas4, alphas5, alphas6, alphas7}
    };
    return output;
}

#ifndef SHADERGRAPH_SAMPLE_SCENE_DEPTH
    #define SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv) shadergraph_SampleSceneDepth(uv)
#endif

#ifndef SHADERGRAPH_SAMPLE_SCENE_COLOR
    #define SHADERGRAPH_SAMPLE_SCENE_COLOR(uv) shadergraph_SampleSceneColor(uv)
#endif

#ifndef SHADERGRAPH_BAKED_GI
    #define SHADERGRAPH_BAKED_GI(positionWS, normalWS, uvStaticLightmap, uvDynamicLightmap, applyScaling) shadergraph_BakedGI(positionWS, normalWS, uvStaticLightmap, uvDynamicLightmap, applyScaling)
#endif

#ifndef SHADERGRAPH_REFLECTION_PROBE
    #define SHADERGRAPH_REFLECTION_PROBE(viewDir, normalOS, lod) shadergraph_ReflectionProbe(viewDir, normalOS, lod)
#endif

#ifndef SHADERGRAPH_FOG
    #define SHADERGRAPH_FOG(position, color, density) shadergraph_Fog(position, color, density)
#endif

#ifndef SHADERGRAPH_AMBIENT_SKY
    #define SHADERGRAPH_AMBIENT_SKY float3(unity_AmbientSky.xyz)
#endif

#ifndef SHADERGRAPH_AMBIENT_EQUATOR
    #define SHADERGRAPH_AMBIENT_EQUATOR float3(unity_AmbientEquator.xyz)
#endif

#ifndef SHADERGRAPH_AMBIENT_GROUND
    #define SHADERGRAPH_AMBIENT_GROUND float3(unity_AmbientGround.xyz)
#endif

#ifndef SHADERGRAPH_OBJECT_POSITION
    #define SHADERGRAPH_OBJECT_POSITION UNITY_MATRIX_M._m03_m13_m23
#endif

#ifdef REQUIRE_DEPTH_TEXTURE
    UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

float shadergraph_SampleSceneDepth(float2 uv)
{
    #if UNITY_SINGLE_PASS_STEREO
        uv = TransformStereoScreenSpaceTex(uv, 1.0);
    #endif
    #ifdef REQUIRE_DEPTH_TEXTURE
    return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
    #else
    return 1;
    #endif
}

#ifdef REQUIRE_OPAQUE_TEXTURE
    UNITY_DECLARE_SCREENSPACE_TEXTURE(_CameraOpaqueTexture);
    float4 _CameraOpaqueTexture_TexelSize;
#endif

float3 shadergraph_SampleSceneColor(float2 uv)
{
    #if UNITY_SINGLE_PASS_STEREO
        uv = TransformStereoScreenSpaceTex(uv, 1.0);
    #endif
    #ifdef REQUIRE_OPAQUE_TEXTURE
            return UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraOpaqueTexture, uv).rgb;
    #else
        return 0;
    #endif
}

float3 shadergraph_BakedGI(float3 positionWS, float3 normalWS, float2 uvStaticLightmap, float2 uvDynamicLightmap, bool applyScaling)
{
    #ifdef LIGHTMAP_ON
    return 0; // TODO
    #else
    return 0;
    #endif
}

float3 shadergraph_ReflectionProbe(float3 viewDir, float3 normalOS, float lod)
{
    #ifdef UNITY_PASS_FORWARDBASE
    float3 reflectVec = reflect(-viewDir, normalOS);
    half4 rgbm = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0, reflectVec, lod);
    return DecodeHDR(rgbm, unity_SpecCube0_HDR);
    #else
    return 0;
    #endif
}

void shadergraph_Fog(float3 position, out float4 color, out float density)
{
    color = unity_FogColor;
    density = unity_FogParams.x;
}

#endif // UNITY_GRAPHFUNCTIONS_INCLUDED
