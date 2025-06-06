// Thanks ChatGpt

#include "ReShade.fxh"

// === UI CONTROLS ===
uniform int iAmount <
    ui_type = "slider";
    ui_min = 1; ui_max = 1000;
    ui_label = "Dot Amount";
> = 100;

uniform float fMinSize <
    ui_type = "slider";
    ui_min = 0.0001; ui_max = 0.05;
    ui_label = "Min Dot Size";
    hidden = true;
> = 0.001;

uniform float fMaxSize <
    ui_type = "slider";
    ui_min = 0.0001; ui_max = 0.05;
    ui_step = 0.0001;
    ui_label = "Max Dot Size";
> = 0.03;

uniform float fSpread <
    ui_type = "slider";
    ui_min = 1.0; ui_max = 4.0;
    ui_label = "Spread";
> = 1.0;

uniform int iSeed <
    ui_type = "slider";
    ui_min = 0; ui_max = 100;
    ui_label = "Random Seed";
> = 42;

// === DEPTH CONTROLS ===
uniform float fDepthMin <
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0;
    ui_label = "Min Depth";
> = 0.0;

uniform float fDepthMax <
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0;
    ui_label = "Max Depth";
> = 1.0;

// === COLOR CONTROLS ===
uniform int colorAmmount <
    ui_type = "slider";
    ui_min = 1; ui_max = 8;
    ui_label = "Color Amount";
> = 3;

uniform float3 Color0 < ui_type = "color"; ui_label = "Color 0"; > = float3(1.0, 0.0, 0.0); // Red
uniform float3 Color1 < ui_type = "color"; ui_label = "Color 1"; > = float3(0.0, 1.0, 0.0); // Green
uniform float3 Color2 < ui_type = "color"; ui_label = "Color 2"; > = float3(0.0, 0.0, 1.0); // Blue
uniform float3 Color3 < ui_type = "color"; ui_label = "Color 3"; > = float3(1.0, 1.0, 0.0); // Yellow
uniform float3 Color4 < ui_type = "color"; ui_label = "Color 4"; > = float3(1.0, 0.0, 1.0); // Magenta
uniform float3 Color5 < ui_type = "color"; ui_label = "Color 5"; > = float3(0.0, 1.0, 1.0); // Cyan
uniform float3 Color6 < ui_type = "color"; ui_label = "Color 6"; > = float3(1.0, 0.5, 0.0); // Orange
uniform float3 Color7 < ui_type = "color"; ui_label = "Color 7"; > = float3(0.5, 0.0, 1.0); // Purple

// === RANDOM UTILS ===
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

// === MAIN PASS ===
float4 PS_Dots(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
    float4 color = tex2D(ReShade::BackBuffer, uv);

    // Sample scene depth
    float depth = tex2D(ReShade::DepthBuffer, uv).r;

    // Discard pixels not in depth range
    if (depth < fDepthMin || depth > fDepthMax)
        return color;

    float minPixelSize = 1.0 / max(BUFFER_WIDTH, BUFFER_HEIGHT);

    for (int i = 0; i < iAmount; ++i)
    {
        float2 seed = float2(iSeed, i);
        float2 randPos = rand2(seed) * fSpread;
        float2 center = frac(randPos);
        float radius = lerp(max(0.0001, minPixelSize), fMaxSize, rand(center + 0));

        // Aspect ratio correction for circular dots
        float aspectRatio = float(BUFFER_WIDTH) / float(BUFFER_HEIGHT);
        float2 aspectUV = uv - center;
        aspectUV.x *= aspectRatio;
        float dist = length(aspectUV);

        if (dist < radius)
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

            color.rgb = dotColor;
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
