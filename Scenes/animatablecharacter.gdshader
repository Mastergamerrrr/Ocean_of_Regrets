shader_type canvas_item;

uniform float wave_speed : hint_range(0.0, 5.0) = 1.9;
uniform float wave_strength : hint_range(0.0, 0.05) = 0.014;

void vertex() {
    VERTEX.y += sin(TIME * wave_speed) * wave_strength * 100.0;
}