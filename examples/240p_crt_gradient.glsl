#version 330 core
uniform float iTime;
uniform ivec2 iResolution;

float lerp(float a, float b, float t) {
    return (1 - t) * a + b * t;
}

float inv_lerp(float a, float b, float v) {
    return (v - a) / (b - a);
}

float remap(float a, float b, float c, float d, float v) {
    return lerp(c, d, inv_lerp(a, b, v));
}

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
}

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

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    // 960x720
    ivec2 subpixel_pos = ivec2(floor(uv.x * 960), floor(uv.y * 720));

    vec3 subpixel_color = vec3(0.0, 0.0, 0.0);
    if (mod(subpixel_pos.x, 3) == 0) {
        subpixel_color.b = 1.0;
    } else if (mod(subpixel_pos.x, 3) == 1) {
        subpixel_color.r = 1.0;
    } else {
        subpixel_color.g = 1.0;
    }
  
    // 640x480
    vec2 pixel_uv = vec2(floor(uv.x * 640) / 640, floor(uv.y * 480) / 480); 
    
    // Time varying color gradient
    vec3 color = 0.5 + 0.5 * cos(iTime + pixel_uv.xyx + vec3(0,2,4));
    vec3 color2 = mix(color, subpixel_color, 0.4);

    // Noise
    color2 = mix(color2, noise(uv * 480, color2), 0.3);

    // Scanlines
    float s = floor(sin(uv.y * 480));
    s = remap(-1.0, 0.0, 0.0, 1.0, s);
    vec4 color3 = vec4(color2 * s, 1.0); 

    gl_FragColor = color3;
}

