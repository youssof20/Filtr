shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float radius : hint_range(0.0, 4.0) = 0.0;

void fragment() {
	// Godot does not allow `return` in fragment(); use a branch and assign COLOR once.
	if (radius < 0.01) {
		COLOR = texture(screen_texture, SCREEN_UV);
	} else {
		vec2 px = 1.0 / vec2(textureSize(screen_texture, 0));
		vec4 acc = vec4(0.0);
		float w = 0.0;
		for (int xi = -2; xi <= 2; xi++) {
			for (int yi = -2; yi <= 2; yi++) {
				vec2 offs = vec2(float(xi), float(yi));
				float d = length(offs);
				if (d > 2.5) {
					continue;
				}
				float ww = 1.0 / (1.0 + d);
				acc += texture(screen_texture, SCREEN_UV + offs * px * radius) * ww;
				w += ww;
			}
		}
		COLOR = acc / max(w, 0.0001);
	}
}
