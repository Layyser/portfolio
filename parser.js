// Minimal OBJ parser to extract positions, normals, and assign white color

export function parseOBJ(text) {
    const positions = [];
    const normals = [];
    const webglData = []; // This will hold: PosX, PosY, PosZ,  Nx, Ny, Nz,  R, G, B
    const lines = text.split('\n');
    for (let line of lines) {
        line = line.trim();
        if (line.startsWith('v ')) {
            // Vertex Position: v 1.0 2.0 3.0
            positions.push(line.split(/\s+/).slice(1).map(parseFloat));
        } else if (line.startsWith('vn ')) {
            // Vertex Normal: vn 0.0 1.0 0.0
            normals.push(line.split(/\s+/).slice(1).map(parseFloat));
        } else if (line.startsWith('f ')) {
            // Face: f 1//1 2//1 3//1  (Indices for Pos / UV / Norm)
            const vertices = line.split(/\s+/).slice(1);
            
            // Triangulate (handle quads/ngons)
            for (let i = 1; i < vertices.length - 1; i++) {
                const parts = [vertices[0], vertices[i], vertices[i+1]];
                
                for (const part of parts) {
                    // OBJ indices are 1-based, split by '/'
                    const indices = part.split('/');
                    const posIndex = parseInt(indices[0]) - 1;
                    const normIndex = parseInt(indices[2]) - 1;

                    // Get Position
                    const p = positions[posIndex];
                    webglData.push(p[0], p[1], p[2]);

                    // Get Normal (or default to up if missing)
                    let n = [0, 1, 0];
                    if (!isNaN(normIndex) && normals[normIndex]) {
                        n = normals[normIndex];
                    }
                    webglData.push(n[0], n[1], n[2]);

                    // Add Color (White)
                    webglData.push(1, 1, 1);
                }
            }
        }
    }
    return new Float32Array(webglData);
}