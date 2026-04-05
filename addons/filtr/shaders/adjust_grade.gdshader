shader_type canvas_item;
/// Final-pass grade after preset stack: hue, saturation, shadow tint, highlights.
/// `adjust_blend` follows master look intensity so fades stay clean.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float hue_degrees : hint_range(-180.0, 180.0) = 0.0;
uniform float saturation_add : hint_range(-1.0, 1.0) = 0.0;
uniform vec3 shadow_tint_rgb = vec3(1.0);
uniform float shadow_mix : hint_range(0.0, 1.0) = 0.65;
uniform float highlight_boost : hint_range(0.0, 1.0) = 0.0;
uniform float adjust_blend : hint_range(0.0, 1.0) = 1.0;

vec3 apply_hue(vec3 rgb, float hue_deg) {
	float angle = hue_deg * 0.01745329252;
	float cos_a = cos(angle);
	float sin_a = sin(angle);
	vec3 k = vec3(0.57735026919);
	return rgb * cos_a + cross(k, rgb) * sin_a + k * dot(k, rgb) * (1.0 - cos_a);
}

void fragment() {
	vec4 src = texture(screen_texture, SCREEN_UV);
	vec3 rgb = src.rgb;
	float luma = dot(rgb, vec3(0.299, 0.587, 0.114));
	float shadow_w = smoothstep(0.2, 0.55, 1.0 - luma);
	rgb = mix(rgb, rgb * shadow_tint_rgb, shadow_w * shadow_mix);
	rgb = apply_hue(rgb, hue_degrees);
	float sat_mul = clamp(1.0 + saturation_add, 0.0, 2.5);
	rgb = mix(vec3(luma), rgb, sat_mul);
	rgb += vec3(highlight_boost * 0.4) * smoothstep(0.55, 1.0, luma);
	rgb = clamp(rgb, 0.0, 1.0);
	COLOR = vec4(mix(src.rgb, rgb, adjust_blend), src.a);
}
