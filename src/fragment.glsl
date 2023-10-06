#version 330 core

uniform float iGlobalTime;
uniform vec2 iResolution;

void main() {
   vec2 uv = gl_FragCoord.xy / iResolution.xy;
   gl_FragColor = vec4(uv.x, 0.0, 0.0, 1.0);
}
