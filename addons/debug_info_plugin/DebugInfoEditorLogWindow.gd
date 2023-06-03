@tool
class_name DebugInfoEditorLogWindow extends Window

@onready var background := %Background as PanelContainer
@onready var log_panel := %LogPanel as DebugInfoEditorLogPanel

@export var close_if_no_logs := true
@export var dock_logs_before_close := false

signal closed(window: DebugInfoEditorLogWindow)

func _init():
	close_requested.connect(_close)

func _ready():
	_update_theme()
	log_panel.tabs_changed.connect(_on_tabs_changed)

func _notification(what):
	match what:
		NOTIFICATION_THEME_CHANGED:
			_update_theme()

func _update_theme():
	if background != null:
		background.add_theme_stylebox_override("panel", get_theme_stylebox("panel", "AcceptDialog"))

func _close():
	if dock_logs_before_close:
		for log in log_panel.logs.values():
			if log.external:
				log._request_external_change()
	closed.emit(self)
	queue_free()

func _on_tabs_changed(log: DebugInfoEditorLogPanel):
	if close_if_no_logs and log_panel.logs.size() == 0:
		_close()
