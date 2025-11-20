// Thanks ChatGpt


#include "ReShade.fxh"

uniform int iAmount <
    ui_type = "slider";
    ui_min = 1; ui_max = 1000;
    ui_label = "Dot Amount";
    ui_category = "Dot Configuration";
> = 100;

uniform float fMinSize <
    ui_type = "slider";
    ui_min = 0.0001; ui_max = 0.05;
    ui_label = "Min Dot Size";
    ui_category = "Dot Configuration";
    hidden = true;
> = 0.001;

uniform float fMaxSize <
    ui_type = "slider";
    ui_min = 0.0001; ui_max = 0.1;
    ui_step = 0.0001;
    ui_label = "Max Dot Size";
    ui_category = "Dot Configuration";
> = 0.03;

uniform float fSpread <
    ui_type = "slider";
    ui_min = 1.0; ui_max = 4.0;
    ui_label = "Spread";
    ui_category = "Dot Configuration";
> = 1.0;

uniform int iSeed <
    ui_type = "slider";
    ui_min = 0; ui_max = 50;
    ui_label = "Random Seed";
    ui_category = "Dot Configuration";
> = 42;

uniform float fDepthMin <
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0;
    ui_label = "Min Depth";
    ui_category = "Depth Controls";
> = 0.0;

uniform float fDepthMax <
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0;
    ui_label = "Max Depth";
    ui_category = "Depth Controls";
> = 1.0;

uniform int colorAmmount <
    ui_type = "slider";
    ui_min = 1; ui_max = 8;
    ui_label = "Color Amount";
    ui_category = "Color Controls";
> = 3;

uniform float3 Color0 < 
    ui_type = "color"; 
    ui_label = "Color 0"; 
    ui_category = "Color Controls";
> = float3(1.0, 0.0, 0.0);

uniform float3 Color1 < 
    ui_type = "color"; 
    ui_label = "Color 1"; 
    ui_category = "Color Controls";
> = float3(0.0, 1.0, 0.0);

uniform float3 Color2 < 
    ui_type = "color"; 
    ui_label = "Color 2"; 
    ui_category = "Color Controls";
> = float3(0.0, 0.0, 1.0);

uniform float3 Color3 < 
    ui_type = "color"; 
    ui_label = "Color 3"; 
    ui_category = "Color Controls";
> = float3(1.0, 1.0, 0.0);

uniform float3 Color4 < 
    ui_type = "color"; 
    ui_label = "Color 4"; 
    ui_category = "Color Controls";
> = float3(1.0, 0.0, 1.0);

uniform float3 Color5 < 
    ui_type = "color"; 
    ui_label = "Color 5"; 
    ui_category = "Color Controls";
> = float3(0.0, 1.0, 1.0);

uniform float3 Color6 < 
    ui_type = "color"; 
    ui_label = "Color 6"; 
    ui_category = "Color Controls";
> = float3(1.0, 0.5, 0.0);

uniform float3 Color7 < 
    ui_type = "color"; 
    ui_label = "Color 7"; 
    ui_category = "Color Controls";
> = float3(0.5, 0.0, 1.0);

uniform float fDotAlpha <
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0;
    ui_step = 0.01;
    ui_label = "Dot Alpha";
    ui_category = "Dot Shape & Fade";
> = 1.0;

uniform float fWidthScale <
    ui_type = "slider";
    ui_min = 0.1; ui_max = 4.0;
    ui_step = 0.01;
    ui_label = "Width Scale";
    ui_category = "Dot Shape & Fade";
> = 1.0;

uniform float fHeightScale <
    ui_type = "slider";
    ui_min = 0.1; ui_max = 4.0;
    ui_step = 0.01;
    ui_label = "Height Scale";
    ui_category = "Dot Shape & Fade";
> = 1.0;

uniform float fEdgeFeather <
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0;
    ui_step = 0.01;
    ui_label = "Edge Feather";
    ui_category = "Dot Shape & Fade";
> = 0.0;

uniform float fFalloffCurve <
    ui_type = "slider";
    ui_min = 0.1; ui_max = 5.0;
    ui_step = 0.1;
    ui_label = "Falloff Curve";
    ui_category = "Dot Shape & Fade";
> = 1.0;


uniform float4 EdgeColor < 
    ui_type = "color"; 
    ui_label = "Edge Color"; 
    ui_category = "Dot Shape & Fade";
> = float4(0.0, 0.0, 0.0, 1.0);



float rand(float2 co)
{
    return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

float2 rand2(float2 co)
{
    return float2(rand(co), rand(co + 10.0));
}

int randColorIndex(float2 seed, int maxIndex)
{
    return int(floor(rand(seed) * maxIndex));
}


float4 PS_Dots(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
    float4 color = tex2D(ReShade::BackBuffer, uv);
    float depth = tex2D(ReShade::DepthBuffer, uv).r;

    if (depth < fDepthMin || depth > fDepthMax)
        return color;

    float minPixelSize = 1.0 / max(BUFFER_WIDTH, BUFFER_HEIGHT);

    for (int i = 0; i < iAmount; ++i)
    {
        float2 seed = float2(iSeed, i);
        float2 randPos = rand2(seed) * fSpread;
        float2 center = frac(randPos);

        float radius = lerp(max(0.0001, minPixelSize), fMaxSize, rand(center + 0));
        float2 relUV = uv - center;
        relUV.x *= float(BUFFER_WIDTH) / float(BUFFER_HEIGHT);

        float2 scaled = relUV / (radius * float2(fWidthScale, fHeightScale));
        float dist = length(scaled);

        if (dist < 1.0)
        {
            int index = randColorIndex(seed + 20, colorAmmount);
            float3 dotColor;

            if      (index == 0) dotColor = Color0;
            else if (index == 1) dotColor = Color1;
            else if (index == 2) dotColor = Color2;
            else if (index == 3) dotColor = Color3;
            else if (index == 4) dotColor = Color4;
            else if (index == 5) dotColor = Color5;
            else if (index == 6) dotColor = Color6;
            else                 dotColor = Color7;

            // Smooth fade using feather and falloff curve
            float fade = smoothstep(1.0, 1.0 - fEdgeFeather, dist);
            fade = pow(fade, fFalloffCurve);

            float finalAlpha = fDotAlpha * fade;

            // Blend from edge color (with alpha) to dot color, then blend with background
            float edgeAlpha = EdgeColor.a * (1.0 - fade); // edge alpha fades toward center
            finalAlpha = lerp(edgeAlpha, finalAlpha, fade);

            float3 finalDotColor = lerp(EdgeColor.rgb, dotColor, fade);

            color.rgb = lerp(color.rgb, finalDotColor, finalAlpha);
        }
    }

    return color;
}

technique PolkaDots
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Dots;
    }
}

