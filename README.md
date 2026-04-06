# Filtr

MIT-licensed post-processing **looks** for **Godot 4** — curated fullscreen presets (stacks of `canvas_item` shaders), a **FiltrNode** driver, **zones**, an editor **Filtr** dock, per-look detail sliders, and a global **Adjust** pass (hue, saturation, shadow tint / strength, highlights) that scales with look intensity.

By **chuumberry**. Repo: [github.com/youssof20/Filtr](https://github.com/youssof20/Filtr).

## Install

Copy `addons/filtr` into your project → **Project → Project Settings → Plugins** → enable **Filtr**.

Enabling the plugin adds the **`FiltrManager` autoload** if your project does not already define it (required at runtime). If the editor still looks confused after the first enable, save the project and restart the editor once so `project.godot` reloads.

## Basic use

1. Add a **FiltrNode** under your running scene.
2. Pick a **Look** in the Inspector or the **Filtr** dock.
3. Set **Intensity** (0–100), per-look detail sliders, and under **Adjust (global)** optional hue / saturation / shadow grade / highlights.

## Filtr dock

Browse and search looks; select a **FiltrNode** in the scene tree, then click a row to apply. **Escape** clears the search box; **Enter** applies the focused row. **Dock previews:** add `addons/filtr/thumbnails/<look_id>.png` (same id as the preset, e.g. `film_noir.png`). The repo ships example stills for **Film Noir**, **Neon Night**, **Old Photograph**, and **Security Cam** — hover a row in the dock to see them.

## Saved looks

Inspector **Save / Load look** writes a **FiltrSavedLook** resource. Save `.tres` files under **`res://addons/filtr/saved_looks/`** — they are listed in the dock (right-click a saved row to delete). That folder ships with a `.gitkeep` so the path exists.

## Zones

Use **FiltrZone** / **FiltrZone2D** for area volumes: assign a look and blend time; **On exit** can restore the FiltrNode look or clear the stack.

## Code API (AnimationPlayer-safe)

```gdscript
$FiltrNode.set_look("Horror")
$FiltrNode.transition_to("Film Noir", 1.5)
$FiltrNode.set_intensity(0.7)
$FiltrNode.set_sub_value("grain", 0.4)
$FiltrNode.clear(2.0)
```

## Shader building blocks

All fullscreen passes live in `addons/filtr/shaders/`. **Update this list when you add or remove a `.gdshader` file** (reference for authors and fork maintenance).

| File | Role |
|------|------|
| `adjust_grade.gdshader` | Final global grade (FiltrManager): hue, saturation, shadow tint, highlights, blend with intensity |
| `bleach_bypass.gdshader` | High-contrast partly desaturated blend |
| `blur.gdshader` | Soft box blur |
| `chromatic.gdshader` | RGB channel separation |
| `color_grade.gdshader` | Saturation, contrast, tint, optional flicker |
| `crt_warp.gdshader` | Barrel warp + scan-line dimming |
| `dither.gdshader` | Ordered dither / retro banding |
| `glitch_lines.gdshader` | Horizontal row UV offsets (digital tear) |
| `grain.gdshader` | Film grain |
| `halftone.gdshader` | Dot-screen print look |
| `noise_distort.gdshader` | Noise-driven UV warp |
| `pixelate.gdshader` | Pixel block scale |
| `posterize.gdshader` | Quantize RGB to discrete steps |
| `scanlines.gdshader` | Horizontal scan lines |
| `sharpen.gdshader` | Mild unsharp mask |
| `vignette.gdshader` | Edge darken, optional pulse |
| `warp.gdshader` | Wavy warp (`strength`, `frequency`) |

## Godot version

**4.3+**. Forward+ and Compatibility renderers.

## Settings

**Project → Project Settings → Filtr → quiet_log** — suppresses runtime `[Filtr]` console messages.

## Shader references

Community shaders on [Godot Shaders](https://godotshaders.com/shader/?orderby=likes&order=DESC) are useful for ideas and parameter ranges; Filtr ships its own MIT stack. Check licenses before copying third-party code.

## License

MIT — see `LICENSE`.
