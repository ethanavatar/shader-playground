#version 330 core
uniform ivec2 iResolution;

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
    float d = length(uv);

    d -= 0.5;
    d = abs(d);
    d = step(0.1, d);

    gl_FragColor = vec4(vec3(d), 1.0);
}

