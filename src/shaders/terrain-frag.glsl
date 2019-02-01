#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Time;

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Sine;

in float noise;
in float type;
in float slope;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{
    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog

    vec3 fog_color = vec3(164.0 / 255.0, 233.0 / 255.0, 1.0);

    if (u_Time == 1.f) {
        fog_color = vec3(6.0 / 255.0, 12.0 / 255.0, 58.0 / 255.0);
    }
    
    if (type == 1.f) {
            out_Col = vec4(mix(vec3(244.0 / 255.0, 66.0 / 255.0, 146.0 / 255.0) * 0.5 * (fs_Sine*0.15) + 0.1, fog_color, t), 1.0);
    } else if (type == 2.f) {
        out_Col = vec4(mix(vec3(235.0/255.0, 192.0/255.0, 114.0/255.0) * 0.5 * (fs_Sine*0.15) + 0.1, fog_color, t), 1.0);
    } else if (type == 3.f) {
        if (fs_Sine == 1.f) {
            out_Col = vec4(mix(vec3(11.0/255.0, 140.0/255.0, 24.0/255.0), fog_color, t), 1.0);
        } else if (fs_Sine > 0.6) {
            vec3 ground = vec3(11.0/255.0, 140.0/255.0, 24.0/255.0);
            vec3 sand = vec3(193.0/255.0, 175.0/255.0, 94.0/255.0);
            vec3 in_between = mix(sand, ground, (fs_Sine - 0.6) / 0.4);
            out_Col = vec4(mix(in_between, fog_color, t), 1.0);
        } else {
            vec3 sand = vec3(193.0/255.0, 175.0/255.0, 94.0/255.0);
            vec3 water = vec3(16.0 / 255.0, 61.0 / 255.0, 186.0 / 255.0);
            vec3 in_between = mix(water, sand, (fs_Sine - 0.4) / 0.6);
            out_Col = vec4(mix(in_between, fog_color, t), 1.0);
        }
    } else if (type == 4.f) {
        if (fs_Sine <= 0.3) {
            out_Col = vec4(mix(vec3(0.9,0.9,0.9) * fs_Sine + 0.5, fog_color, t), 1.0);
        } else if (fs_Sine <= 0.7) {
            //lerp between water color and ground color
            vec3 water = vec3(0.8,0.8,0.8) * (fs_Sine + 0.25f)*2.f;
            vec3 ground = vec3(0.2,0.2,0.2);
            vec3 lerpColor = mix(water, ground, (fs_Sine - 0.3f) / 0.4f);
            out_Col = vec4(mix(lerpColor, fog_color, t), 1.0);
        } else if (fs_Sine < 0.9999) {
            vec3 bark = vec3(0.2,0.2,0.2);
            out_Col = vec4(mix(bark, fog_color, t), 1.0);
        } else {
            vec3 bark = vec3(64.0 / 255.0, 40.0 / 255.0, 10.0 / 255.0);
            out_Col = vec4(mix(vec3(0.5 * (fs_Sine*0.1) + 0.05), fog_color, t), 1.0);
        }
    } else {
        out_Col = vec4(mix(vec3(0.5 * (fs_Sine*0.15) + 0.1), fog_color, t), 1.0);
    }
}
