shader_type canvas_item;

uniform float glow_intensity : hint_range(0.0, 0.5) = 0.15;
uniform float contrast_boost : hint_range(0.8, 1.2) = 1.05;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Boost contrast
    color.rgb = (color.rgb - 0.5) * contrast_boost + 0.5;
    
    // Enhance warm window lights
    float is_warm = max(color.r, color.g * 0.8);
    color.rgb += vec3(is_warm * 0.15, is_warm * 0.1, 0.0);
    
    // Night atmosphere (blue tint)
    color.rgb = mix(color.rgb, vec3(color.r * 0.9, color.g * 0.95, color.b * 1.1), 0.3);
    
    // Gentle glow
    vec4 glow = texture(TEXTURE, UV);
    color.rgb += glow.rgb * glow_intensity;
    
    COLOR = color;
}