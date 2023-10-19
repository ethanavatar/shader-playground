#version 330 core
uniform float iTime;
uniform ivec2 iResolution;

// Linearly interpolates between a and b by t
float lerp(float a, float b, float t) {
    return (1 - t) * a + b * t;
}

// Inverse linear interpolation
float inv_lerp(float a, float b, float v) {
    return (v - a) / (b - a);
}

// Remaps a value from the range [a, b] to the range [c, d]
float remap(float a, float b, float c, float d, float v) {
    return lerp(c, d, inv_lerp(a, b, v));
}

// A pseudo-random number generator
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
}

// Returns a combination of the input color with a random color based on the input uv
vec3 noise(vec2 uv, vec3 color) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    
    float a = random(i);
    float b = random(i + vec2(1.,0.));
    float c = random(i + vec2(0., 1.));
    float d = random(i + vec2(1.));
    
    vec2 u = smoothstep(0., 1., f);
    
    float f2 = mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y; 
    return mix(color, vec3(f2), 0.5);
}


// A function that simulates the look of each pixel on
// a CRT TV where each pixel is made of 3 smaller components of red, green, and blue
vec3 rgb_subpixel(vec2 uv, int width, int height) {
    // A fixed-size grid of pixels
    ivec2 subpixel_pos = ivec2(floor(uv.x * width), floor(uv.y * height));

    // The first subpixel is blue, the second is red, the third is green
    // This pattern repeats horizontally
    vec3 subpixel_color = vec3(0.0, 0.0, 0.0);
    if (mod(subpixel_pos.x, 3) == 0) {
        subpixel_color.b = 1.0;
    } else if (mod(subpixel_pos.x, 3) == 1) {
        subpixel_color.r = 1.0;
    } else {
        subpixel_color.g = 1.0;
    }

    return subpixel_color;
}

void main() {
    // The coordinates of the current pixel normalized to [0, 1]
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    // The dimensions of the screen
    int width = 640;
    int height = 480;

    // A 640x480 pixel grid
    vec2 downsampled_uv = vec2(floor(uv.x * 640) / 640, floor(uv.y * 480) / 480);
    
    // A 960x720 subpixel grid
    // Each subpixel is 1/3 of a pixel
    vec3 subpixel_color = rgb_subpixel(uv, 960, 720);
    
    // A color gradient that changes over time
    vec3 color = 0.5 + 0.5 * cos(iTime + downsampled_uv.xyx + vec3(0,2,4));
    vec3 color2 = mix(color, subpixel_color, 0.4);

    // Apply noise to the color
    color2 = mix(color2, noise(uv * 960, color2), 0.3);

    gl_FragColor = vec4(color2, 1.0);
}

