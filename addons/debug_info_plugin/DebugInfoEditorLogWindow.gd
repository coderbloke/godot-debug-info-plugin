@tool
class_name DebugInfoEditorLogWindow extends Window

@onready var background := %Background as PanelContainer
@onready var log_panel := %LogPanel as DebugInfoEditorLogPanel

func _ready():
	_update_theme()

func _notification(what):
	match what:
		NOTIFICATION_THEME_CHANGED:
			_update_theme()

func _update_theme():
	if background != null:
		background.add_theme_stylebox_override("panel", get_theme_stylebox("panel", "AcceptDialog"))

