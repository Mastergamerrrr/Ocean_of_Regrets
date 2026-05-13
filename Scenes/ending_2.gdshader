shader_type canvas_item;

uniform float wave_speed : hint_range(0.0, 3.0) = 0.8;
uniform float wave_strength : hint_range(0.0, 0.02) = 0.006;
uniform float wave_frequency : hint_range(0.0, 20.0) = 8.0;
uniform vec4 underwater_tint : source_color = vec4(0.0, 0.3, 0.4, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.15;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;

void fragment() {
	vec2 uv = UV;
	
	// gentle water distortion
	uv.x += sin(uv.y * wave_frequency + TIME * wave_speed) * wave_strength;
	uv.y += cos(uv.x * wave_frequency * 0.5 + TIME * wave_speed * 0.7) * wave_strength * 0.5;
	
	vec4 base = texture(TEXTURE, uv);
	
	// underwater tint
	base = mix(base, underwater_tint, tint_strength);
	
	// dark vignette around edges to feel enclosed
	vec2 vig_uv = UV * (1.0 - UV.yx);
	float vignette = pow(vig_uv.x * vig_uv.y * 15.0, vignette_strength);
	base.rgb *= clamp(vignette, 0.0, 1.0);
	
	COLOR = base * COLOR;
}