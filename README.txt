Filtr
=====
MIT-licensed post-processing **looks** for Godot 4 — curated fullscreen presets (stacks of canvas_item shaders), a **FiltrNode** driver, **zones**, an editor **Filtr** dock, and per-look detail sliders.

By **chuumberry**. Contributions welcome on the project repo.

INSTALL
-------
Copy `addons/filtr` into your project → **Project → Project Settings → Plugins** → enable **Filtr**.

BASIC USE
---------
1. Add a **FiltrNode** under your running scene.
2. Pick a **Look** in the Inspector (or use the **Filtr** dock).
3. Adjust **Intensity** (0–100) and any named detail sliders for that look.

FILTR DOCK
----------
Browse and search looks; click to apply to the selected FiltrNode. **Escape** clears search; **Enter** applies the focused row. Optional thumbnails: `addons/filtr/thumbnails/<look_id>.png`.

FILTR ZONE / FILTR ZONE 2D
--------------------------
Area volumes: assign a look and fade time. When the camera enters, the look blends in; on exit, restore the FiltrNode look or clear the stack (see **On exit**).

CODE API (AnimationPlayer-safe)
--------------------------------
$FiltrNode.set_look("Horror")
$FiltrNode.transition_to("Film Noir", 1.5)
$FiltrNode.set_intensity(0.7)
$FiltrNode.set_sub_value("grain", 0.4)
$FiltrNode.clear(2.0)

SAVE / LOAD LOOKS
-----------------
Inspector **Save / Load look** writes a `FiltrSavedLook` resource; put `.tres` files under `res://filtr_looks/` to list them in the dock. The folder is optional until you save looks (repo includes `filtr_looks/` with `.gitkeep`).

ADJUST (GLOBAL)
---------------
On **FiltrNode**, **Adjust (global)** tweaks a final grade pass: hue, saturation, shadow tint + shadow strength, highlights — scaled with **Intensity** so fades stay clean.

GODOT VERSION
-------------
Godot **4.3+**. Forward+ and Compatibility renderers.

SETTINGS
--------
**Project → Project Settings → Filtr → quiet_log** — when enabled, runtime `[Filtr]` console messages are suppressed.

LICENSE
-------
MIT — see `LICENSE`. Shaders and scripts are free to use in personal and commercial projects.
