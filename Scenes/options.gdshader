shader_type canvas_item;

uniform float scanline_intensity = 0.08;
uniform float glow_intensity = 0.25;
uniform float pulse_speed = 1.2;
uniform vec3 accent_color = vec3(0.2, 0.8, 0.9);  // Cyan accent

void fragment() {
    vec4 color = COLOR;
    vec2 uv = UV;
    float time = TIME * pulse_speed;
    
    // Subtle scanlines for tech feel
    float scanline = sin(uv.y * SCREEN_PIXEL_SIZE.y * SCREEN_PIXEL_SIZE.y * 300.0);
    scanline = mix(1.0, 1.0 - scanline_intensity, scanline * 0.5 + 0.5);
    
    // Horizontal glows (like sound waves)
    float wave1 = sin(uv.y * 20.0 - time * 3.0) * 0.5 + 0.5;
    float wave2 = cos(uv.y * 15.0 + time * 2.5) * 0.5 + 0.5;
    float wave_glow = (wave1 * wave2) * 0.15;
    
    // Edge glow for settings panel
    float edge_glow_x = smoothstep(0.0, 0.05, uv.x) * (1.0 - smoothstep(0.95, 1.0, uv.x));
    float edge_glow_y = smoothstep(0.0, 0.05, uv.y) * (1.0 - smoothstep(0.95, 1.0, uv.y));
    float edge_glow = (edge_glow_x + edge_glow_y) * 1.5;
    edge_glow = clamp(edge_glow, 0.0, 0.4);
    
    // Vignette
    float vignette = 1.0 - length(uv - 0.5) * 0.6;
    vignette = clamp(vignette, 0.5, 1.0);
    
    // Combine effects
    color.rgb *= scanline * vignette;
    color.rgb += accent_color * (wave_glow + edge_glow) * glow_intensity;
    
    // Pulsing border
    float pulse = sin(time) * 0.1 + 0.9;
    color.rgb *= pulse;
    
    COLOR = color;
}