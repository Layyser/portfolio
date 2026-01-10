#version 300 es
precision highp float;

in vec3 position;
in vec3 color; 
in vec3 normal;

out vec3 vColor;
out vec3 vNormal;
out vec3 vFragPos;

uniform float time;
uniform float aspect;
uniform vec3 uCenterOffset;
uniform float uParallaxOffset;

void main() {
    vColor = vec3(1.0); 

    float spinSpeed = time * 0.1; 
    
    float cy = cos(spinSpeed); 
    float sy = sin(spinSpeed);

    mat4 spinMat = mat4(
        cy,  0.0, sy,  0.0, 
        0.0, 1.0, 0.0, 0.0, 
        -sy, 0.0, cy,  0.0, 
        0.0, 0.0, 0.0, 1.0
    );
    float tiltAngleX = -0.45; 
    float tiltAngleZ = -0.5;
    float cx = cos(tiltAngleX); float sx = sin(tiltAngleX);
    float cz = cos(tiltAngleZ); float sz = sin(tiltAngleZ);

    mat4 tiltX = mat4(
        1.0, 0.0, 0.0, 0.0, 
        0.0, cx, -sx,  0.0, 
        0.0, sx,  cx,  0.0, 
        0.0, 0.0, 0.0, 1.0
    );

    mat4 tiltZ = mat4(
        cz, -sz, 0.0, 0.0,
        sz,  cz, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    float scale = 3.4; 
    mat4 scaleMat = mat4(
        scale, 0.0,   0.0,   0.0,
        0.0,   scale, 0.0,   0.0,
        0.0,   0.0,   scale, 0.0,
        0.0,   0.0,   0.0,   1.0
    );

    // 1. Scale the object
    // 2. Spin it around its vertical axis (Y)
    // 3. Tilt the entire spinning result (X * Z)
    // 4. Apply to the centered 3D model
    // 5. Add offset to position at the right of the camera
    // 6. Push back slightly further
    mat4 modelMatrix = tiltZ * tiltX * spinMat * scaleMat;
    vec3 centeredPos = position - uCenterOffset;
    vec4 offset = vec4(min((uParallaxOffset*0.6 + 1.0),0.0), (uParallaxOffset*-0.65 + 1.4), 0.0, 0.0);
    vec4 pos = modelMatrix * vec4(centeredPos, 1.0) + offset;
    pos.z -= 7.5;          

    // Rotate Normals (using the same rotation logic)
    vec4 rotNormal = tiltZ * tiltX * spinMat * vec4(normal, 0.0);
    vNormal = normalize(rotNormal.xyz);
    vFragPos = pos.xyz;

    // Perspective Projection
    float zNear = 0.1;
    float zFar = 100.0;
    float zParams = (zFar + zNear) / (zNear - zFar);
    float wParams = (2.0 * zFar * zNear) / (zNear - zFar);
    
    gl_Position = vec4(pos.x / aspect, pos.y, pos.z * zParams + wParams, -pos.z);
}