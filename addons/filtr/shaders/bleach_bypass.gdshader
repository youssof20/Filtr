shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// Blends toward high-contrast, partly desaturated bleach bypass look.
uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform float contrast : hint_range(0.0, 0.8) = 0.35;
uniform float desat : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	vec3 rgb = c.rgb;
	float l = dot(rgb, vec3(0.299, 0.587, 0.114));
	vec3 gray = vec3(l);
	vec3 mixed = mix(rgb, gray, desat);
	mixed = (mixed - 0.5) * (1.0 + contrast) + 0.5;
	mixed = clamp(mixed, 0.0, 1.0);
	COLOR = vec4(mix(rgb, mixed, amount), c.a);
}
