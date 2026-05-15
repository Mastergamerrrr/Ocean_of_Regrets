shader_type canvas_item;

uniform float glow_brightness = 0.3;
uniform float fade_height = 0.3;
uniform vec3 top_glow = vec3(0.2, 0.6, 0.8);
uniform vec3 bottom_glow = vec3(0.4, 0.2, 0.6);

void fragment() {
    vec4 color = COLOR;
    vec2 uv = UV;
    
    // Vertical gradient fade
    float fade_top = smoothstep(0.0, fade_height, uv.y);
    float fade_bottom = smoothstep(1.0, 1.0 - fade_height, uv.y);
    float fade = fade_top * fade_bottom;
    
    // Add subtle horizontal gradient glow
    float horizontal_glow = sin(uv.x * 3.14159) * 0.3 + 0.7;
    
    // Mix top and bottom glow colors
    vec3 glow_gradient = mix(bottom_glow, top_glow, uv.y);
    
    // Apply effects
    color.rgb *= fade;
    color.rgb += glow_gradient * horizontal_glow * glow_brightness * (1.0 - fade);
    
    // Soft edge vignette
    float vignette = 1.0 - pow(length(uv - 0.5) * 1.2, 3.0);
    vignette = clamp(vignette, 0.5, 1.0);
    color.rgb *= vignette;
    
    COLOR = color;
}