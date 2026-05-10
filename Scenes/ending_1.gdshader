shader_type canvas_item;

uniform float wave_speed : hint_range(0.0, 5.0) = 0.5;
uniform float wave_strength : hint_range(0.0, 0.1) = 0.025;
uniform float wave_frequency : hint_range(0.0, 20.0) = 10.0;
uniform float sparkle_density : hint_range(0.0, 100.0) = 50.0;
uniform float sparkle_speed : hint_range(0.0, 5.0) = 1.5;
uniform vec4 sparkle_color : source_color = vec4(1.0, 0.85, 0.2, 1.0);

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * wave_frequency + TIME * wave_speed) * wave_strength;
    vec4 base = texture(TEXTURE, uv);

    // sparkles
    vec2 grid = floor(UV * sparkle_density);
    float rand = hash(grid);
    float twinkle = sin(TIME * sparkle_speed + rand * 6.28) * 0.5 + 0.5;
    float threshold = 0.94;
    float sparkle = step(threshold, rand) * twinkle * twinkle;

    vec2 cell_uv = fract(UV * sparkle_density) - 0.5;
    float dist = length(cell_uv);
    float shape = smoothstep(0.3, 0.0, dist);

    float final_sparkle = sparkle * shape;

    COLOR = mix(base, sparkle_color, final_sparkle) * COLOR;
}