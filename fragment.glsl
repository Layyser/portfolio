#version 300 es
precision highp float;

in vec3 vColor;
in vec3 vNormal;
in vec3 vFragPos;

out vec4 fragColor;

uniform vec2 resolution;
uniform float time;

// Settings
uniform float matrixSize; 
uniform float bias;       

vec3 ditherColor = vec3(107, 171, 144) / 255.0;

// --- DITHER MATRICES ---
const mat2x2 bayerMatrix2x2 = mat2x2(0.0, 2.0, 
                                     3.0, 1.0) / 4.0;

const mat4 bayerMatrix4x4 = mat4( 0.0,  8.0,  2.0, 10.0,
                                 12.0,  4.0, 14.0,  6.0,
                                  3.0, 11.0,  1.0,  9.0,
                                 15.0,  7.0, 13.0,  5.0) / 16.0;

const float bayerMatrix8x8[64] = float[64](
    0.0/64.0, 48.0/64.0, 12.0/64.0, 60.0/64.0, 3.0/64.0, 51.0/64.0, 15.0/64.0, 63.0/64.0,
    32.0/64.0, 16.0/64.0, 44.0/64.0, 28.0/64.0, 35.0/64.0, 19.0/64.0, 47.0/64.0, 31.0/64.0,
    8.0/64.0, 56.0/64.0, 4.0/64.0, 52.0/64.0, 11.0/64.0, 59.0/64.0, 7.0/64.0, 55.0/64.0,
    40.0/64.0, 24.0/64.0, 36.0/64.0, 20.0/64.0, 43.0/64.0, 27.0/64.0, 39.0/64.0, 23.0/64.0,
    2.0/64.0, 50.0/64.0, 14.0/64.0, 62.0/64.0, 1.0/64.0, 49.0/64.0, 13.0/64.0, 61.0/64.0,
    34.0/64.0, 18.0/64.0, 46.0/64.0, 30.0/64.0, 33.0/64.0, 17.0/64.0, 45.0/64.0, 29.0/64.0,
    10.0/64.0, 58.0/64.0, 6.0/64.0, 54.0/64.0, 9.0/64.0, 57.0/64.0, 5.0/64.0, 53.0/64.0,
    42.0/64.0, 26.0/64.0, 38.0/64.0, 22.0/64.0, 41.0/64.0, 25.0/64.0, 37.0/64.0, 21.0/64.0
);

// --- FUNCTIONS ---

vec3 orderedDither(vec2 uv, float lum) {
    float threshold = 0.0;
    int x = int(gl_FragCoord.x) % int(matrixSize);
    int y = int(gl_FragCoord.y) % int(matrixSize);

    if (matrixSize == 2.0) threshold = bayerMatrix2x2[x][y]; 
    else if (matrixSize == 4.0) threshold = bayerMatrix4x4[x][y]; 
    else if (matrixSize == 8.0) threshold = bayerMatrix8x8[y * 8 + x];

    // Note: We return 0.0 or ditherColor. 
    // You could also return inputColor vs 0.0 if you want the object's original hue.
    return (lum < threshold + bias - 0.5) ? vec3(0.0) : ditherColor;
}

vec3 getPhongLight(vec3 normal, vec3 fragPos, vec3 viewPos, vec3 lightPos, vec3 baseColor) {
    // Normalize inputs
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - fragPos);
    vec3 viewDir = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm); 

    // 1. Ambient
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * vec3(1.0);
  
    // 2. Diffuse
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * vec3(1.0);
    
    // 3. Specular
    float specularStrength = 0.8;
    float shininess = 32.0;
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
    vec3 specular = specularStrength * spec * vec3(1.0);  

    // Combine
    return (ambient + diffuse + specular) * baseColor;
}

void main() {
    // 1. Setup Scene Data
    // Rotate light around the scene
    vec3 lightPos = vec3(sin(time) * 3.0, 2.0, cos(time) * 2.0 - 3.5);
    // vec3 lightPos = vec3(5.0, 5.0, 5.0);
    vec3 viewPos = vec3(0.0, 0.0, 0.0);

    // 2. Compute Lit Color
    vec3 litColor = getPhongLight(vNormal, vFragPos, viewPos, lightPos, vColor);

    // 3. Compute Luminance (Standard Rec. 709)
    float lum = dot(vec3(0.2126, 0.7152, 0.0722), litColor);

    // 4. Apply Dither
    vec3 finalColor = orderedDither(gl_FragCoord.xy, lum);

    fragColor = vec4(finalColor, 1.0);
}