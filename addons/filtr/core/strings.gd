## Central place for user-visible labels (inspector, docks, dialogs).
class_name FiltrStrings
extends RefCounted

const PLUGIN_NAME := "Filtr"

const INSPECTOR_NONE := "None"

const DOCK_TAB_TITLE := "Filtr"
const DOCK_HEADER := "Looks"
const DOCK_SEARCH_PLACEHOLDER := "Search looks…"
const DOCK_NO_MATCH := "No looks match ‘%s’."
const DOCK_HINT_NONE := "Select a FiltrNode, then click a look to apply it. Use the Inspector for Intensity and per-look details."
const DOCK_HINT_SELECTED := "Click a look to apply. Adjust Intensity in the Inspector if it feels too strong. Escape clears search · Enter applies the focused row."
const DOCK_UNDO_APPLY := "Filtr: apply look"
const DOCK_UNDO_APPLY_SAVED := "Filtr: apply saved look"
const DOCK_DELETE_CONFIRM := "Delete saved look ‘%s’ from the project?"

## `.tres` **FiltrSavedLook** files saved here are listed in the Filtr dock.
const SAVED_LOOKS_DIR := "res://addons/filtr/saved_looks"
