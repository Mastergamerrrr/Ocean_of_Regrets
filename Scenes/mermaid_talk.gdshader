shader_type canvas_item;

uniform float wave_speed : hint_range(0.0, 5.0) = 0.5;
uniform float wave_strength : hint_range(0.0, 0.1) = 0.025;
uniform float wave_frequency : hint_range(0.0, 20.0) = 10.0;

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * wave_frequency + TIME * wave_speed) * wave_strength;
    COLOR = texture(TEXTURE, uv);
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
