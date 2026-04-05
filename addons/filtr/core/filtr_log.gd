## Lightweight debug trail. Toggle QUIET_LOG via Project Settings → Filtr → quiet_log when you want silence.
class_name FiltrLog
extends RefCounted

const QUIET_SETTING := "filtr/quiet_log"


static func event(message: String) -> void:
	if bool(ProjectSettings.get_setting(QUIET_SETTING, false)):
		return
	print("[Filtr] ", message)
