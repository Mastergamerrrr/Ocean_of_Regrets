shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float time_speed = 0.25;
uniform float glow_intensity = 0.55;
uniform float wave_density = 3.0;
uniform float blur_amount = 0.01;
uniform float panel_opacity = 0.85;
uniform float darkness_intensity = 0.6;
uniform vec3 color_cyan = vec3(0.0, 0.7, 0.85);
uniform vec3 color_teal = vec3(0.0, 0.4, 0.6);
uniform vec3 color_deep = vec3(0.02, 0.12, 0.25);
uniform vec3 color_sparkle = vec3(0.3, 0.8, 0.7);

// Random function for organic shimmer
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    vec2 screen_uv = SCREEN_UV;
    float time = TIME * time_speed;
    
    // === ORGANIC WAVE PATTERNS ===
    float wave1 = sin(uv.y * wave_density * 4.0 + time) * cos(uv.x * wave_density * 3.0 - time * 0.8);
    float wave2 = sin((uv.x * wave_density * 5.0 - uv.y * wave_density * 2.5) + time * 1.2);
    float wave3 = cos((uv.x * wave_density * 6.0 + uv.y * wave_density * 3.0) + time * 0.6);
    float wave4 = sin(uv.x * wave_density * 7.0 * sin(time * 0.5)) * cos(uv.y * wave_density * 4.0);
    float wave5 = sin((uv.x * 2.0 + uv.y) * wave_density * 2.0 + time * 1.5) * 0.5;
    
    // Bioluminescent pulse
    float pulse = sin(time * 0.8) * 0.1 + 0.9;
    
    // Combine waves
    float shimmer = (wave1 * 0.35 + wave2 * 0.25 + wave3 * 0.2 + wave4 * 0.15 + wave5 * 0.05);
    shimmer = (shimmer + 1.0) / 2.0;
    shimmer = pow(shimmer, 1.5) * pulse;
    shimmer = max(0.2, shimmer * 0.7);
    
    // === SPARKLE EFFECT ===
    vec2 sparkle_uv = uv * 12.0;
    float sparkle_pattern = random(floor(sparkle_uv + time * 0.3));
    float sparkle = smoothstep(0.96, 0.99, sparkle_pattern) * 0.5;
    sparkle *= sin(time * 5.0) * 0.5 + 0.5;
    sparkle = max(0.0, sparkle * 0.4);
    
    // === BLUR EFFECT - Sample from SCREEN ===
    vec2 pixel_size = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
    vec4 blurred_color = vec4(0.0);
    int blur_samples = 0;
    
    for (int x = -4; x <= 4; x++) {
        for (int y = -4; y <= 4; y++) {
            float weight = 1.0 / (1.0 + float(x*x + y*y) * 0.3);
            vec2 offset = vec2(float(x), float(y)) * pixel_size * blur_amount;
            blurred_color += texture(SCREEN_TEXTURE, screen_uv + offset) * weight;
            blur_samples += int(weight);
        }
    }
    blurred_color /= float(blur_samples);
    
    // Get original screen color
    vec4 screen_color = texture(SCREEN_TEXTURE, screen_uv);
    
    // Mix with blur
    float mix_factor = 0.6 + shimmer * 0.2;
    vec4 final_content = mix(screen_color, blurred_color, mix_factor);
    
    // Apply darkness to content
    final_content.rgb *= (0.5 + darkness_intensity * 0.3);
    
    // === BIOLUMINESCENT OVERLAY ===
    vec3 glow_color = mix(color_deep, color_teal, shimmer);
    glow_color = mix(glow_color, color_cyan, wave2 * 0.6 + 0.2);
    glow_color += color_sparkle * sparkle * 0.7;
    
    // Add edge glow
    float edge_glow = (1.0 - smoothstep(0.1, 0.9, uv.x)) * (1.0 - smoothstep(0.1, 0.9, uv.y));
    edge_glow += (1.0 - smoothstep(0.1, 0.9, 1.0 - uv.x)) * (1.0 - smoothstep(0.1, 0.9, 1.0 - uv.y));
    edge_glow = clamp(edge_glow * 1.2, 0.0, 0.5);
    glow_color += color_cyan * edge_glow * shimmer * 0.8;
    
    // Dark vignette
    float vignette = 1.0 - length(uv - 0.5) * 0.8;
    vignette = clamp(vignette, 0.4, 1.0);
    glow_color *= vignette;
    
    // Final glow alpha
    float glow_alpha = (0.3 + shimmer * 0.35 + sparkle * 0.15) * glow_intensity;
    
    // Combine content and glow
    vec3 final_rgb = final_content.rgb;
    final_rgb = mix(final_rgb, glow_color, glow_alpha * 0.6);
    final_rgb += glow_color * 0.1 * shimmer;
    
    // Apply vignette darkness
    final_rgb *= (0.7 + vignette * 0.3);
    
    // Apply panel transparency
    float final_alpha = panel_opacity;
    
    COLOR = vec4(final_rgb, final_alpha);
}