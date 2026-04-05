class_name FiltrPresetRegistry
extends RefCounted

const _PRESETS: Array[Dictionary] = [
	{"id": "broadcast_tv", "path": "res://addons/filtr/presets/looks/broadcast_tv.gd"},
	{"id": "cold_interrogation", "path": "res://addons/filtr/presets/looks/cold_interrogation.gd"},
	{"id": "dreamcore", "path": "res://addons/filtr/presets/looks/dreamcore.gd"},
	{"id": "film_noir", "path": "res://addons/filtr/presets/looks/film_noir.gd"},
	{"id": "golden_hour", "path": "res://addons/filtr/presets/looks/golden_hour.gd"},
	{"id": "high_contrast", "path": "res://addons/filtr/presets/looks/high_contrast.gd"},
	{"id": "horror", "path": "res://addons/filtr/presets/looks/horror.gd"},
	{"id": "ink_comic", "path": "res://addons/filtr/presets/looks/ink_comic.gd"},
	{"id": "mellow", "path": "res://addons/filtr/presets/looks/mellow.gd"},
	{"id": "neon_night", "path": "res://addons/filtr/presets/looks/neon_night.gd"},
	{"id": "night_vision", "path": "res://addons/filtr/presets/looks/night_vision.gd"},
	{"id": "old_photograph", "path": "res://addons/filtr/presets/looks/old_photograph.gd"},
	{"id": "ps1", "path": "res://addons/filtr/presets/looks/ps1.gd"},
	{"id": "retro_tv", "path": "res://addons/filtr/presets/looks/retro_tv.gd"},
	{"id": "security_cam", "path": "res://addons/filtr/presets/looks/security_cam.gd"},
	{"id": "signal_loss", "path": "res://addons/filtr/presets/looks/signal_loss.gd"},
	{"id": "soft_focus", "path": "res://addons/filtr/presets/looks/soft_focus.gd"},
	{"id": "sun_bleached", "path": "res://addons/filtr/presets/looks/sun_bleached.gd"},
	{"id": "underwater", "path": "res://addons/filtr/presets/looks/underwater.gd"},
	{"id": "vhs", "path": "res://addons/filtr/presets/looks/vhs.gd"},
	{"id": "warm_cinema", "path": "res://addons/filtr/presets/looks/warm_cinema.gd"},
]


static func get_all_preset_ids() -> PackedStringArray:
	var out := PackedStringArray()
	for e in _PRESETS:
		out.append(e["id"])
	return out


static func instantiate_preset(preset_id: String) -> FiltrLookPreset:
	var path := find_script_path(preset_id)
	if path.is_empty():
		return null
	var scr: GDScript = load(path) as GDScript
	if scr == null:
		return null
	return scr.new() as FiltrLookPreset


static func find_script_path(preset_id: String) -> String:
	for e in _PRESETS:
		if e["id"] == preset_id:
			return e["path"]
	return ""


static func label_to_id(label: String) -> String:
	var t := label.strip_edges()
	if t.is_empty():
		return ""
	var slug := t.to_lower().replace(" ", "_")
	if find_script_path(slug) != "":
		return slug
	for id in get_all_preset_ids():
		var p: FiltrLookPreset = instantiate_preset(id)
		if p and p.display_name == t:
			return id
	return ""
