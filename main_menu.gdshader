shader_type canvas_item;

// Vignette settings you can adjust in the Inspector
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Color of the edge (default black)
uniform float intensity : hint_range(0.0, 1.0) = 0.7;                  // How dark the edges are
uniform float softness : hint_range(0.1, 2.0) = 0.8;                  // How soft the edge transition is
uniform float scale : hint_range(0.1, 2.0) = 1.0;                     // How far the vignette reaches inward

void fragment() {
    // Calculate distance from the center
    vec2 uv_centered = UV - vec2(0.5);
    float dist = length(uv_centered) * 2.0;
    
    // Create the vignette mask
    float vignette = smoothstep(0.0, softness, dist * scale);
    
    // Apply color and intensity
    vec4 final_color = vignette_color;
    final_color.a = vignette * intensity;
    
    COLOR = final_color;
}