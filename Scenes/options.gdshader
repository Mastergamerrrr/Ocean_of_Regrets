shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.87, 1.0);
uniform float glow_intensity : hint_range(0.5, 6.0) = 2.8;
uniform float edge_width : hint_range(0.01, 0.3) = 0.06;
uniform float speed : hint_range(0.1, 3.0) = 1.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
        f.y
    );
}

float fbm(vec2 p) {
    float v = 0.0;
    v += noise(p) * 0.5;
    v += noise(p * 2.1 + 5.3) * 0.25;
    v += noise(p * 4.4 - 2.7) * 0.125;
    return v;
}

void fragment() {
    vec2 uv = UV;
    float t = TIME * speed;

    float edge_dist = min(
        min(uv.x, 1.0 - uv.x),
        min(uv.y, 1.0 - uv.y)
    );

    float n  = fbm(uv * 7.0 + vec2(t * 0.7, t * 0.4));
    float n2 = fbm(uv * 3.5 - vec2(t * 0.3, t * 0.6));

    float glow = smoothstep(edge_width + n * edge_width, 0.0, edge_dist);
    glow = pow(glow, 0.6);
    float electric = glow * (0.6 + 0.4 * n2);

    float inner  = smoothstep(edge_width, edge_width * 3.0, edge_dist);
    float ripple = fbm(uv * 3.5 + t * 0.25) * 0.12;
    vec3 void_col = vec3(0.015, 0.015, 0.04) * (1.0 + inner * ripple * 4.0);

    float r = fbm(uv * 14.0 + t * 1.3) * glow * 0.5;
    vec3 chroma = vec3(r, 0.0, -r * 0.8) * glow_color.rgb;

    vec3 col = void_col
        + glow_color.rgb * electric * glow_intensity
        + chroma * 0.6;

    COLOR = vec4(col, 1.0);
}
