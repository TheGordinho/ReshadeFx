/*------------------.
| :: Description :: |
'-------------------/

	Animated Splitscreen (version 2.whatever)

	Author: CeeJay.dk
	Yoinker: TheGordinho
	License: MIT

	About:
	Displays the image before and after it has been modified by effects using a splitscreen
	Now animated
    

	Ideas for future improvement:
    *

	History:
	(*) Feature (+) Improvement (x) Bugfix (-) Information (!) Compatibility
	
	Version 1.0
    * Does a splitscreen before/after view
    
	Version 2.0
    * Ported to Reshade 3.x
    * Added UI settings.
    * Added Diagonal split mode
    - Removed curvy mode. I didn't like how it looked.
    - Threatened other modes to behave or they would be next.
	
	Version 2.whatever
    * Added animations from left to right and a few others that dont really work
*/

/*------------------.
| :: UI Settings :: |
'------------------*/

#include "ReShadeUI.fxh"

uniform int splitscreen_mode <
    ui_type = "combo";
    ui_label = "Mode";
    ui_tooltip = "Choose a mode";
    //ui_category = "";
    ui_items = 
    "Vertical 50/50 split\0"
    "Vertical 25/50/25 split\0"
    "Angled 50/50 split\0"
    "Angled 25/50/25 split\0"
    "Horizontal 50/50 split\0"
    "Horizontal 25/50/25 split\0"
    "Diagonal split\0"
    ;
> = 0;


uniform float2 pingpong < 
	source = "pingpong";
	min = 0.0;
	max = 1.0;
	step = 0.5 ; //this controlls the speed
	//smoothing = 1; //this too
	
 >; 




/*---------------.
| :: Includes :: |
'---------------*/

#include "ReShade.fxh"


/*-------------------------.
| :: Texture and sampler:: |
'-------------------------*/

texture Before { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };
sampler Before_sampler { Texture = Before; };


  

/*-------------.
| :: Effect :: |
'-------------*/

float4 PS_Before(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    return tex2D(ReShade::BackBuffer, texcoord);
}

float4 PS_After(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    float4 color; 

    // -- Vertical 50/50 split --
    [branch] if (splitscreen_mode == 0)
        color = (texcoord.x > pingpong.x /* original has 0.5 here*/ ) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);

    // -- Vertical 25/50/25 split --
    [branch] if (splitscreen_mode == 1)
    {
        //Calculate the distance from center
        float dist = abs(texcoord.x - 0.5);
        
        //Further than 1/4 away from center?
        dist = saturate(dist - pingpong.x);
        
        color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
	}

    // -- Angled 50/50 split --
    [branch] if (splitscreen_mode == 2)
    {
        //Calculate the distance from center
        float dist = ((texcoord.x - pingpong.x) + (texcoord.y * (-pingpong.x)));

        //Further than 1/4 away from center?
        dist = saturate(dist - pingpong.x);

        color = dist ? tex2D(ReShade::BackBuffer, texcoord) : tex2D(Before_sampler, texcoord);
    }

    // -- Angled 25/50/25 split --
    [branch] if (splitscreen_mode == 3)
    {
        //Calculate the distance from center
        float dist = ((texcoord.x - pingpong.x) + (texcoord.y * (-pingpong.x)));

        dist = abs(dist - pingpong.x);

        //Further than 1/4 away from center?
        dist = saturate(dist - 0.25);

        color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
    }
  
    // -- Horizontal 50/50 split --
    [branch] if (splitscreen_mode == 4)
	    color =  (texcoord.y > pingpong.x) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
	
    // -- Horizontal 25/50/25 split --
    [branch] if (splitscreen_mode == 5)
    {
        //Calculate the distance from center
        float dist = abs(texcoord.y - 0.5);
        
        //Further than 1/4 away from center?
        dist = saturate(dist - pingpong.x);
        
        color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
    }

    // -- Diagonal split --
    [branch] if (splitscreen_mode == 6)
    {
        //Calculate the distance from center
        float dist = (texcoord.x - texcoord.y);
        
        //Further than 1/2 away from center?
        //dist = saturate(dist + 1);
        
        color = (dist > 0.025) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
    }

    return color;
}


/*-----------------.
| :: Techniques :: |
'-----------------*/

technique AnimatedTop
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Before;
        RenderTarget = Before;
    }
}

technique AnimatedBottom
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_After;
    }
}
/*
Several people worked on this mess
None of them want to deal this shader anymore and any issues will probably not be fixed
If you find any issues or crashes, good luck, you're on your own (y)
*/
