package shaders;

import flixel.system.FlxAssets.FlxShader;

class BloomShader extends FlxShader // Taken from BBPanzu anime mod hueh
{
	@:glFragmentSource('
	#pragma header

    uniform float funrange;
    uniform float funsteps;
    uniform float funthreshhold;
    uniform float funbrightness;
    
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    void mainImage() {
        vec2 uv = openfl_TextureCoordv.xy;
        fragColor = texture(iChannel0, uv);
        
        if (funrange <= 0.0) return;
        
        const int MAX_SAMPLES = 16;
        float range2 = 2.0 * funrange;
        float stepsNeeded = ceil(range2 / funsteps);
        float actualSteps = (stepsNeeded > float(MAX_SAMPLES)) ? float(MAX_SAMPLES) : stepsNeeded;
        int steps = int(actualSteps);
        float stepSize = range2 / actualSteps;
        
        for (int j = 0; j < steps; j++) {
            float i = -funrange + (float(j) + 0.5) * stepSize;
            float falloff = 1.0 - abs(i / funrange);
            float weight = falloff * stepSize * funbrightness;
            
            vec4 blur = texture(iChannel0, uv + i);
            if (blur.r + blur.g + blur.b > funthreshhold * 3.0) {
                fragColor += blur * weight;
            }
            
            blur = texture(iChannel0, uv + vec2(i, -i));
            if (blur.r + blur.g + blur.b > funthreshhold * 3.0) {
                fragColor += blur * weight;
            }
        }
    }
	')

	public function new(range:Float = 0.1, steps:Float = 0.005, threshhold:Float = 0.8, brightness:Float = 7.0)
	{
		super();

		data.funrange.value = [range];
		data.funsteps.value = [steps];
		data.funthreshhold.value = [threshhold];
		data.funbrightness.value = [brightness];
	}
}
