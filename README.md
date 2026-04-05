# Filtr

MIT-licensed post-processing **looks** for **Godot 4** — curated fullscreen presets (stacks of `canvas_item` shaders), a **FiltrNode** driver, **zones**, an editor **Filtr** dock, per-look detail sliders, and a global **Adjust** pass (hue, saturation, shadow tint / strength, highlights) that scales with look intensity.

By **chuumberry**. Repo: [github.com/youssof20/Filtr](https://github.com/youssof20/Filtr).

## Install

Copy `addons/filtr` into your project → **Project → Project Settings → Plugins** → enable **Filtr**.

## Basic use

1. Add a **FiltrNode** under your running scene.
2. Pick a **Look** in the Inspector or the **Filtr** dock.
3. Set **Intensity** (0–100), per-look detail sliders, and under **Adjust (global)** optional hue / saturation / shadow grade / highlights.

## Dock & saved looks

Browse and search looks in the **Filtr** dock. Save/load **FiltrSavedLook** resources; place `.tres` files under `res://filtr_looks/` so they appear in the dock (the folder is optional until you save looks).

## Zones

Use **FiltrZone** / **FiltrZone2D** for area volumes: assign a look and blend time; **On exit** can restore the driver look or clear the stack.

## Code API (AnimationPlayer-safe)

```gdscript
$FiltrNode.set_look("Horror")
$FiltrNode.transition_to("Film Noir", 1.5)
$FiltrNode.set_intensity(0.7)
$FiltrNode.set_sub_value("grain", 0.4)
$FiltrNode.clear(2.0)
```

## Godot version

**4.3+**. Forward+ and Compatibility renderers.

## Settings

**Project → Project Settings → Filtr → quiet_log** — suppresses runtime `[Filtr]` console messages.

## Shader references

Community shaders on [Godot Shaders](https://godotshaders.com/shader/?orderby=likes&order=DESC) are useful for ideas and parameter ranges; Filtr ships its own MIT stack. Check licenses before copying third-party code.

## License

MIT — see `LICENSE`.
