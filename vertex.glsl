#version 300 es
in vec3 position;
in vec3 color; // Ignored for now
in vec3 normal;

out vec3 vColor;
out vec3 vNormal;
out vec3 vFragPos;

uniform float time;
uniform float aspect;
uniform vec2 uMouse;
uniform vec3 uCenterOffset;

void main() {
    vColor = vec3(1.0); // Use gray color for lighting
    
    // --- ROTATION BASED ON MOUSE POSITION ---
    float mouseSensivity = 1.0;

    float angleX = uMouse.y * mouseSensivity; 
    float angleY = uMouse.x * mouseSensivity;

    // Pre-calculate Sin/Cos for X rotation
    float cx = cos(angleX);
    float sx = sin(angleX);

    // Pre-calculate Sin/Cos for Y rotation
    float cy = cos(angleY);
    float sy = sin(angleY);

    // Rotation Matrices
    mat4 rotX = mat4(1.0, 0.0, 0.0, 0.0, 
                     0.0,  cx, -sx, 0.0, 
                     0.0,  sx,  cx, 0.0, 
                     0.0, 0.0, 0.0, 1.0);

    // Rotation Y (Yaw) - uses cy, sy
    mat4 rotY = mat4(cy,  0.0,  sy, 0.0, 
                     0.0, 1.0, 0.0, 0.0, 
                     -sy, 0.0,  cy, 0.0, 
                     0.0, 0.0, 0.0, 1.0);

    // Scaling Matrix
    float xMult = 2.0;  
    float yMult = 2.0;
    float zMult = 2.0;
    mat4 scaleMat = mat4(xMult, 0.0, 0.0, 0.0,
                         0.0, yMult, 0.0, 0.0,
                         0.0, 0.0, zMult, 0.0,
                         0.0, 0.0, 0.0, 1.0);

    mat4 rotationMatrix = rotY * rotX;


    // Center the model around uCenterOffset for good rotation
    vec3 centeredPos = position - uCenterOffset;
    
    // Apply Rotation (now rotating around the center)
    vec4 pos = rotationMatrix * vec4(centeredPos, 1.0);

    // Move camera
    pos.z -= 3.0;           

    vec4 rotNormal = rotationMatrix * vec4(normal, 0.0);
    vNormal = normalize(rotNormal.xyz);
    vFragPos = pos.xyz;

    float zNear = 0.1;
    float zFar = 100.0;
    
    // Standard OpenGL Perspective Projection Z calculation
    // This ensures Z isn't just divided into -1.0, but keeps its depth sorting
    float zParams = (zFar + zNear) / (zNear - zFar);
    float wParams = (2.0 * zFar * zNear) / (zNear - zFar);
    
    // We manually construct the gl_Position so we don't need a full matrix library
    // x = x / aspect
    // y = y
    // z = standard depth mapping
    // w = -z
    gl_Position = vec4(pos.x / aspect, pos.y, pos.z * zParams + wParams, -pos.z);
}