import { parseOBJ } from './parser.js';

// Dither settings
const PIXEL_SCALE = 1; // integers from 1 (no scaling) to 4 (very pixelated)
const DITHER_MATRIX_SIZE = 4; // 2/4/8
const DITHER_BIAS = 0.7; // float from 0 to 1



async function loadShaderSource(url) {
    const response = await fetch(url);
    return await response.text();
}

function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error(gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}

function computeBoundingBox(vertices) {
    let minX = Infinity, maxX = -Infinity;
    let minY = Infinity, maxY = -Infinity;
    let minZ = Infinity, maxZ = -Infinity;

    // The stride is 9 floats (x, y, z, r, g, b, nx, ny, nz)
    for (let i = 0; i < vertices.length; i += 9) {
        const x = vertices[i];
        const y = vertices[i + 1];
        const z = vertices[i + 2];

        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
        if (z < minZ) minZ = z;
        if (z > maxZ) maxZ = z;
    }

    const centerX = (minX + maxX) / 2;
    const centerY = (minY + maxY) / 2;
    const centerZ = (minZ + maxZ) / 2;

    return { center: [centerX, centerY, centerZ], min: [minX, minY, minZ], max: [maxX, maxY, maxZ] };
}

async function init() {
    const canvas = document.getElementById('glcanvas');
    canvas.style.imageRendering = "pixelated"; // Chromium/modern browsers
    canvas.style.imageRendering = "crisp-edges"; // Firefox fallback
    canvas.style.width = "100%";
    canvas.style.height = "100%";

    const gl = canvas.getContext('webgl2');

    
    if (!gl) { 
        alert("WebGL 2 not supported"); 
        return; 
    }

    const vsSource = await loadShaderSource('vertex.glsl');
    const fsSource = await loadShaderSource('fragment.glsl');

    const program = gl.createProgram();
    gl.attachShader(program, createShader(gl, gl.VERTEX_SHADER, vsSource));
    gl.attachShader(program, createShader(gl, gl.FRAGMENT_SHADER, fsSource));
    gl.linkProgram(program);
    
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        console.error(gl.getProgramInfoLog(program));
        return;
    }
    
    gl.useProgram(program);

    // --- Load Model ---
    const response = await fetch('torus.obj');
    const text = await response.text();
    const vertices = parseOBJ(text);
    const boundingBoxInfo = computeBoundingBox(vertices);
    const vBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    // --- Attributes ---
    const STRIDE = 9 * 4; // 9 floats per vertex, 4 bytes each
    
    const posLoc = gl.getAttribLocation(program, 'position');
    gl.enableVertexAttribArray(posLoc);
    gl.vertexAttribPointer(posLoc, 3, gl.FLOAT, false, STRIDE, 0);

    const normLoc = gl.getAttribLocation(program, 'normal');
    gl.enableVertexAttribArray(normLoc);
    gl.vertexAttribPointer(normLoc, 3, gl.FLOAT, false, STRIDE, 3 * 4);

    const colLoc = gl.getAttribLocation(program, 'color');
    gl.enableVertexAttribArray(colLoc);
    gl.vertexAttribPointer(colLoc, 3, gl.FLOAT, false, STRIDE, 6 * 4);

    // --- Uniforms ---
    const timeLoc = gl.getUniformLocation(program, 'time');
    const aspectLoc = gl.getUniformLocation(program, 'aspect');
    const resLoc = gl.getUniformLocation(program, 'resolution');
    const matSizeLoc = gl.getUniformLocation(program, 'matrixSize');
    const biasLoc = gl.getUniformLocation(program, 'bias');
    const mouseLoc = gl.getUniformLocation(program, 'uMouse');
    const centerLoc = gl.getUniformLocation(program, 'uCenterOffset');

    // Set Dither Uniforms
    gl.uniform1f(matSizeLoc, DITHER_MATRIX_SIZE);
    gl.uniform1f(biasLoc, DITHER_BIAS);
    gl.uniform3f(centerLoc, boundingBoxInfo.center[0], boundingBoxInfo.center[1], boundingBoxInfo.center[2]);

    gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.CULL_FACE);


    let mouseX = 0;
    let mouseY = 0;

    document.addEventListener('mousemove', (e) => {
        // Normalize X: 0 to width -> -1 to 1
        mouseX = (e.clientX / window.innerWidth) * 2 - 1;
        
        // Normalize Y: 0 to height -> 1 to -1 (Inverted so up is positive)
        mouseY = -(e.clientY / window.innerHeight) * 2 + 1;
    });

    function resize() {
        // 1. Get the real window size
        const displayWidth = window.innerWidth;
        const displayHeight = window.innerHeight;

        canvas.width = Math.floor(displayWidth / PIXEL_SCALE);
        canvas.height = Math.floor(displayHeight / PIXEL_SCALE);

        gl.viewport(0, 0, canvas.width, canvas.height);
        gl.uniform1f(aspectLoc, canvas.width / canvas.height);
        gl.uniform2f(resLoc, canvas.width, canvas.height);
    }
    window.onresize = resize;
    resize();

    function loop(t) {
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.uniform1f(timeLoc, t * 0.001);
        gl.uniform2f(mouseLoc, mouseX, mouseY);
        gl.drawArrays(gl.TRIANGLES, 0, vertices.length / 9);
        requestAnimationFrame(loop);
    }
    loop(0);
}

init();