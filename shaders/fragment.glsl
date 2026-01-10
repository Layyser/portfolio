#version 300 es
precision highp float;

in vec3 vColor;
in vec3 vNormal;
in vec3 vFragPos;

out vec4 fragColor;

uniform vec2 resolution;
uniform float time;
uniform vec2 uMouse;

uniform float matrixSize; 
uniform float bias;       

// Cyber-Lime Color
vec3 ditherColor = vec3(0.8, 1.0, 0.0); 

const mat2x2 bayerMatrix2x2 = mat2x2(0.0, 2.0, 3.0, 1.0) / 4.0;
const mat4 bayerMatrix4x4 = mat4( 0.0,  8.0,  2.0, 10.0,
                                 12.0,  4.0, 14.0,  6.0,
                                  3.0, 11.0,  1.0,  9.0,
                                 15.0,  7.0, 13.0,  5.0) / 16.0;

vec3 orderedDither(vec2 uv, float lum) {
    float threshold = 0.0;
    int x = int(gl_FragCoord.x) % int(matrixSize);
    int y = int(gl_FragCoord.y) % int(matrixSize);

    if (matrixSize == 2.0) threshold = bayerMatrix2x2[x][y]; 
    else threshold = bayerMatrix4x4[x][y]; 

    // Dither logic
    return (lum < threshold + bias - 0.5) ? vec3(0.02) : ditherColor;
}

vec3 getPhongLight(vec3 normal, vec3 fragPos, vec3 viewPos, vec3 lightPos, vec3 baseColor) {
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - fragPos);
    vec3 viewDir = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm); 

    // Ambient
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * vec3(1.0);
  
    // Diffuse
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * vec3(1.0);
    
    // Specular (Sharper highlights look better with dithering)
    float specularStrength = 0.8;
    float shininess = 32.0; 
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
    vec3 specular = specularStrength * spec * vec3(1.0);   

    return (ambient + diffuse + specular) * baseColor;
}

void main() {
    // Map mouse range (-1 to 1) to a wider physical space for lighting
    // Z is positive so the light is in front of the object
    vec3 lightPos = vec3(uMouse.x * 10.0, uMouse.y * 10.0, 5.0);
    
    vec3 viewPos = vec3(0.0, 0.0, 0.0);

    vec3 litColor = getPhongLight(vNormal, vFragPos, viewPos, lightPos, vColor);

    // Standard Grayscale conversion
    float lum = dot(vec3(0.299, 0.587, 0.114), litColor);

    vec3 finalColor = orderedDither(gl_FragCoord.xy, lum);

    fragColor = vec4(finalColor, 1.0);
}