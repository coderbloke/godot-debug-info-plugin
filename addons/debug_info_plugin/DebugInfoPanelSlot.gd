@tool
class_name DebugInfoPanelSlot extends HBoxContainer

@export var key := "":
	set(new_value):
		key = new_value
		update_info_label()
@export_multiline var text := "":
	set(new_value):
		text = new_value
		update_info_label()
		if auto_reset_timer:
			reset_timer()
@export var timeout := 5.0
@export var auto_reset_timer := true
@export var selected := false:
	set(new_value):
		if selected != new_value:
			selected = new_value
			selection_changed.emit(key)
			queue_redraw()
@export var auto_select := true
@export var selection_color: Color = Color(1.0, 1.0, 1.0, 0.2)

signal selection_changed(key: String)

@onready var timer_progress_disk := $TimerProgressDisk
@onready var info_label = $InfoLabel

var start_tick_ms: int = -1 

func _init():
	pass
	
func _ready():
	update_timer_progress_disk()
	
func _input(event):
	# TODO Also check somehow, if Control is visible at all
	# UIn this way it fires also, when the Controlé is on an inactive tab
	if auto_select:
		if event is InputEventMouseButton \
				and event.button_index == MOUSE_BUTTON_LEFT \
				and event.pressed:
			selected = Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position())

func _draw():
	if selected:
		var style_box := get_theme_stylebox("selected", "Tree")
		draw_style_box(style_box, Rect2(Vector2.ZERO, size))
		style_box = get_theme_stylebox("cursor", "Tree")
		draw_style_box(style_box, Rect2(Vector2.ZERO, size))
	pass

func _process(delta):
	update_timer_progress_disk()
	
func reset_timer():
	start_tick_ms = Time.get_ticks_msec()
	update_timer_progress_disk()
	
func get_age():
	return (Time.get_ticks_msec() - start_tick_ms) / 1000.0 if start_tick_ms >= 0 else 0

func is_timed_out():
	return get_age() >= timeout if timeout > 0 else false

func update_timer_progress_disk():
	if timer_progress_disk != null:
		timer_progress_disk.min = 0
		timer_progress_disk.max = timeout
		if timeout > 0:
			timer_progress_disk.value = get_age()
		else:
			timer_progress_disk.value = 0
		
func update_info_label():
	if info_label != null:
		var s = ""
		if key != null and key.length() > 0:
			s += "[u]" + key + "[/u]\n"
		s += text
		info_label.text = s
		
func clear():
	text = ""
	
func add_line(line: String):
	if text.length() > 0:
		text += "\n" + line
	else:
		text = line
