shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// Number of discrete steps per channel (2 = harsh poster, higher = softer).
uniform float steps : hint_range(2.0, 32.0) = 8.0;

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	float s = max(steps, 2.0);
	vec3 q = floor(c.rgb * s + 0.5) / s;
	COLOR = vec4(q, c.a);
}
