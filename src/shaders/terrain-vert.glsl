#version 300 es


uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Time;
uniform float u_Size;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

out float noise;
out float type;
out float slope;
out float time;

out float fs_Sine;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

vec2 random3( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand1D(int x) {
  x = (x << 13) ^ x;
  return (1.0 - ( float(x) * ( float(x) * float(x) * 15731.0 + 789221.0) + 1376312589.0)) / 10737741824.0;
}

float step_map(float value) {

if (value < 0.2f) {
    return 0.2f;
  } else if (value < 0.4f) {
    return 0.2f + ((value - 0.2f) / 0.2f)*0.2f;
  } else if (value < 0.6f) {
    return 0.4f + ((value - 0.4f) / 0.2f)*0.2f;
  } else if (value < 0.8f) {
    return 0.6f + ((value - 0.6f) / 0.2f)*0.2f;
  } else {
    return 1.f;
  }
  
}

float interpNoise2D(float x, float y) {
  float intX = floor(x);
  float fractX = fract(x);
  float intY = floor(y);
  float fractY = fract(y);

  float v1 = rand(vec2(intX, intY));
  float v2 = rand(vec2(intX + 1.f, intY));
  float v3 = rand(vec2(intX, intY + 1.f));
  float v4 = rand(vec2(intX + 1.f, intY + 1.f));

  float i1 = mix(v1, v2, fractX);
  float i2 = mix(v3, v4, fractX);

  return mix(i1, i2, fractY);
}

//mountain fbm
float fbm(float x, float y) {
  float roughness = 1.f;
  float total = 0.f;
  float persistence = 0.5f;
  int octaves = 8;

  for (int i = 0; i < octaves; i++) {
    float freq = pow(2.f, float(i));
    float amp = pow(persistence, float(i));

    total += interpNoise2D(x * freq, y * freq) * amp * roughness;
    roughness *= interpNoise2D(x*freq, y*freq);
  }
  return total;
}

float perlin(float x, float y) { 
  //get the points at each corner
  vec2 q1 = vec2(floor(x), floor(y) + 1.f);
  vec2 q2 = vec2(floor(x), floor(y));
  vec2 q3 = vec2(floor(x) + 1.f, floor(y) + 1.f);
  vec2 q4 = vec2(floor(x) + 1.f, floor(y) + 1.f);

  //get random direction to get the gradient

  //int randnumber = rand();// % (1 + 1 - 1) - 1;
  //vec2 g1 = normalize(vec2(q1.x + randnumber, q1.y + randnumber) - q1);
  //vec2 g1 = normalize(vec2(q2.x + randnumber, q2.y + randnumber) - q2);
  //vec2 g1 = normalize(vec2(q3.x + randnumber, q3.y + randnumber) - q3);
  //vec2 g1 = normalize(vec2(q4.x + randnumber, q4.y + randnumber) - q4);

  //get the difference vectors to point
  //vec2 d1 = q1 - vec2(x,y);
  //vec2 d2 = q2 - vec2(x,y);
  //vec2 d3 = q3 - vec2(x,y);
  //vec2 d4 = q4 - vec2(x,y);

  //dot with the gradients!!
  //float perlin_noise = dot(d1, q1)

  return 1.f;
}

float worley (float c_size, float multiplier) {
  float cell_size = c_size;
  vec2 cell = (vs_Pos.xz + u_PlanePos.xy) / cell_size;
  float noise = 0.f;
  
  vec2 fract_pos = fract(cell);
  vec2 int_pos = floor(cell);

  float m_dist = 1.f;

  for (int y= -1; y <= 1; y++) {
    for (int x= -1; x <= 1; x++) {
      // Neighbor place in the grid
      vec2 neighbor = vec2(float(x),float(y));
      vec2 randpt = random3(int_pos + neighbor);

      vec2 diff = neighbor + randpt - fract_pos;
      float dist = length(diff);
      float rough = 1.0;
      // Keep the closer distance
      if (dist < m_dist) {
        m_dist = dist;
        vec2 pt = (randpt + int_pos + neighbor) / cell_size;
        noise = m_dist*multiplier;
      }
    } 
  }
  return noise;
}

void worley_biome() {
  float noise = worley(2000.f + 100.f * u_Size, 2.f) + 0.05*fbm(vs_Pos.x + u_PlanePos.x, vs_Pos.z + u_PlanePos.y);

  if (noise < 0.25) {
    type = 1.f;
  } else if (noise < 0.5) {
    type = 2.f;
  } else if (noise < 0.75) {
    type = 3.f;
  } else {
    type = 4.f;
  }
}

void main()
{
  //FBM impl
  float y_noise = fbm((vs_Pos.x + u_PlanePos.x) / 24.f, (vs_Pos.z + u_PlanePos.y) / 24.f); //(vs_Pos.xz + u_PlanePos.xy));

  //FBM of Worley
  float worley_fbm_noise = fbm((vs_Pos.x + u_PlanePos.x + worley(50.f,8.f)) / 8.f, (vs_Pos.z + u_PlanePos.y + worley(50.f,8.f)) / 8.f);

  fs_Pos = vs_Pos.xyz;
  //fs_Sine = (sin((vs_Pos.x + u_PlanePos.x) * 3.14159 * 0.1) + cos((vs_Pos.z + u_PlanePos.y) * 3.14159 * 0.1));
    vec4 modelposition = vec4(1.0);
    float n = 0.0;

  worley_biome();

  if (type == 1.f) {
    float n = pow(2.f*y_noise,3.f) + abs(mod(floor(y_noise*30.f), 2.f)) * 0.2f;
    fs_Sine = n;
    modelposition = vec4(vs_Pos.x, vs_Pos.y + n, vs_Pos.z, 1.0);
  } else if (type == 2.f) {
    float n = smoothstep(0.0,0.7,pow(worley(50.f,8.f),3.f)) + sqrt(2.f*worley_fbm_noise);
    fs_Sine = n;
    noise = sin(4.f*y_noise)/y_noise; //pow(worley_fbm_noise,3.f);
    modelposition = vec4(vs_Pos.x, vs_Pos.y + n, vs_Pos.z, 1.0);
  } else if (type == 3.f) {
    float fbm_noise = fbm((vs_Pos.x + u_PlanePos.x) / 8.f, (vs_Pos.z + u_PlanePos.y) / 8.f);
    float n = pow(step_map(y_noise),2.f);
    noise = fbm((vs_Pos.x + u_PlanePos.x) / 10.f, (vs_Pos.z + u_PlanePos.y) / 10.f);
    fs_Sine = n;
    //noise = 0.f;//5.f*worley(1.f,8.f);
    modelposition = vec4(vs_Pos.x, vs_Pos.y + n, vs_Pos.z, 1.0);
  } else if (type == 4.f) {
    //fbm of fbm?
    float fbm_noise = fbm((vs_Pos.x + u_PlanePos.x) / 24.f, (vs_Pos.z + u_PlanePos.y) / 24.f);
    float n = fbm((vs_Pos.x + u_PlanePos.x + fbm_noise) / 8.f, (vs_Pos.z + u_PlanePos.y + fbm_noise) / 8.f);
    n = pow(n, 15.f) + smoothstep(0.0,1.0,worley(100.f,8.f));
    fs_Sine = n + fbm_noise*0.7;
    modelposition = vec4(vs_Pos.x, vs_Pos.y + n, vs_Pos.z, 1.0);
  }

  modelposition = u_Model * modelposition;
  gl_Position = u_ViewProj * modelposition;
}
