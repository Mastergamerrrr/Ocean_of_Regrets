shader_type canvas_item;

uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool show_outline = false;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	if (show_outline) {
		vec2 size = outline_width * TEXTURE_PIXEL_SIZE;
		
		float alpha = texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
		alpha = max(alpha, texture(TEXTURE, UV - vec2(size.x, 0.0)).a);
		alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, size.y)).a);
		alpha = max(alpha, texture(TEXTURE, UV - vec2(0.0, size.y)).a);
		
		if (color.a < 0.1 && alpha > 0.1) {
			// Pulse the alpha in and out using sine wave
			float pulse = (sin(TIME * 3.0) * 0.5) + 0.5;
			color = vec4(outline_color.rgb, pulse);
		}
	}
	
	COLOR = color;
}