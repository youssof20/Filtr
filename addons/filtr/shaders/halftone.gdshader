shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float scale : hint_range(40.0, 320.0) = 140.0;
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 paper_color : source_color = vec4(0.94, 0.93, 0.9, 1.0);
uniform vec4 ink_color : source_color = vec4(0.08, 0.08, 0.1, 1.0);

void fragment() {
	vec4 src = texture(screen_texture, SCREEN_UV);
	float l = dot(src.rgb, vec3(0.299, 0.587, 0.114));
	vec2 g = SCREEN_UV * scale;
	vec2 cell = fract(g) - 0.5;
	float rad = sqrt(clamp(l, 0.0, 1.0)) * 0.48;
	float d = length(cell);
	float dot_mask = smoothstep(rad - 0.08, rad + 0.08, d);
	vec3 halftoned = mix(ink_color.rgb, paper_color.rgb, dot_mask);
	COLOR = vec4(mix(src.rgb, halftoned, strength), src.a);
}
