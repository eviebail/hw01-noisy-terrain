#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting
uniform float u_Time;
out vec4 out_Col;

void main() {

  if (u_Time == 0.f) {
    out_Col = vec4(164.0 / 255.0, 233.0 / 255.0, 1.0, 1.0);
  } else {
    out_Col = vec4(6.0 / 255.0, 12.0 / 255.0, 58.0 / 255.0, 1.0);
  }
}
