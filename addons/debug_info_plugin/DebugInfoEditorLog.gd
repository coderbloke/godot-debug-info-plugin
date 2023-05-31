@tool
class_name DebugInfoEditorLog extends HBoxContainer

enum MessageType {
	STD,
	ERROR,
	STD_RICH,
	WARNING,
	EDITOR,
}

class LogMessage:

	var text: String
	var type: MessageType
	var count = 1
	
	func _init(text: String = "", type: MessageType = MessageType.STD):
		self.text = text
		self.type = type

class _ThemeCache:

	var error_color: Color
	var error_icon: Texture2D

	var warning_color: Color
	var warning_icon: Texture2D

	var message_color: Color
	
var theme_cache := _ThemeCache.new()

class LogFilter:

	var message_count: int = 0

	var active: bool = true:
		set(value):
			active = value
			toggle_button.set_pressed_no_signal(active)

	var type: MessageType

	var toggle_button: Button:
		set(value):
			if toggle_button != null:
				toggle_button.toggled.disconnect(_button_toggled)
			toggle_button = value
			_update_toggle_button()
			if toggle_button != null:
				toggle_button.toggled.connect(_button_toggled)

	signal toggled(active: bool, type: MessageType)
	
	func _init(type: MessageType, toggle_button: Button = null):
		self.type = type
		self.toggle_button = toggle_button
		
	func _button_toggled(button_pressed: bool):
		active = button_pressed
		toggled.emit(active, type)
	
	func _update_toggle_button():
		toggle_button.set_pressed_no_signal(active)
		toggle_button.text = str(message_count)
		
var messages: Array[LogMessage] = []
var type_filter_map = { }

@onready var clear_button := %ClearButton
@onready var copy_button := %CopyButton
	
@onready var collapse_button := %CollapseButton
var collapse := false
		
var tool_button: Button # TODO: intro state for tool_button, make _update_function, call it from setter also
	
@onready var show_search_button := %ShowSearchButton
@onready var search_box := %SearchBox

@onready var save_state_timer := %SaveStateTimer
@onready var log := %Log


func _ready():
	save_state_timer.timeout.connect(_save_state)
	
	search_box.text_changed.connect(_search_changed)
	
	clear_button.pressed.connect(_clear_request)
	copy_button.pressed.connect(_copy_request)
	collapse_button.toggled.connect(_set_collapse)
	show_search_button.toggled.connect(_set_search_visible)
	
	type_filter_map[MessageType.STD] = LogFilter.new(MessageType.STD, %StdFilterButton)
	type_filter_map[MessageType.ERROR] = LogFilter.new(MessageType.ERROR, %ErrorFilterButton)
	type_filter_map[MessageType.WARNING] = LogFilter.new(MessageType.WARNING, %WarningFilterButton)
	type_filter_map[MessageType.EDITOR] = LogFilter.new(MessageType.EDITOR, %EditorFilterButton)
	for filter in type_filter_map.values():
		filter.toggled.connect(_set_filter_active)


func _update_theme():
	if is_node_ready():
		var theme_default_font := get_theme_default_font()
		
		var normal_font := get_theme_font("output_source", "EditorFonts")
		if normal_font != theme_default_font: # With these checkes, try to find out, whether its just a fallback front. TODO: Find better way
			log.add_theme_font_override("normal_font", normal_font)

		var bold_font := get_theme_font("output_source_bold", "EditorFonts")
		if bold_font != theme_default_font:
			log.add_theme_font_override("bold_font", bold_font)

		var italics_font := get_theme_font("output_source_italic", "EditorFonts")
		if italics_font != theme_default_font:
			log.add_theme_font_override("italics_font", italics_font)

		var bold_italics_font := get_theme_font("output_source_bold_italic", "EditorFonts")
		if bold_italics_font != theme_default_font:
			log.add_theme_font_override("bold_italics_font", bold_italics_font)

		var mono_font := get_theme_font("output_source_mono", "EditorFonts")
		if mono_font != theme_default_font:
			log.add_theme_font_override("mono_font", mono_font)

		# Disable padding for highlighted background/foreground to prevent highlights from overlapping on close lines.
		# This also better matches terminal output, which does not use any form of padding.
		log.add_theme_constant_override("text_highlight_h_padding", 0)
		log.add_theme_constant_override("text_highlight_v_padding", 0)

		var font_size := get_theme_font_size("output_source_size", "EditorFonts")
		log.add_theme_font_size_override("normal_font_size", font_size)
		log.add_theme_font_size_override("bold_font_size", font_size)
		log.add_theme_font_size_override("italics_font_size", font_size)
		log.add_theme_font_size_override("mono_font_size", font_size)

		type_filter_map[MessageType.STD].toggle_button.icon = get_theme_icon("Popup", "EditorIcons")
		type_filter_map[MessageType.ERROR].toggle_button.icon = get_theme_icon("StatusError", "EditorIcons")
		type_filter_map[MessageType.WARNING].toggle_button.icon = get_theme_icon("StatusWarning", "EditorIcons")
		type_filter_map[MessageType.EDITOR].toggle_button.icon = get_theme_icon("Edit", "EditorIcons")

		type_filter_map[MessageType.STD].toggle_button.theme_type_variation = "EditorLogFilterButton"
		type_filter_map[MessageType.ERROR].toggle_button.theme_type_variation = "EditorLogFilterButton"
		type_filter_map[MessageType.WARNING].toggle_button.theme_type_variation = "EditorLogFilterButton"
		type_filter_map[MessageType.EDITOR].toggle_button.theme_type_variation = "EditorLogFilterButton"

		clear_button.icon = get_theme_icon("Clear", "EditorIcons")
		copy_button.icon = get_theme_icon("ActionCopy", "EditorIcons")
		collapse_button.icon = get_theme_icon("CombineLines", "EditorIcons")
		show_search_button.icon = get_theme_icon("Search", "EditorIcons")
		search_box.right_icon = get_theme_icon("Search", "EditorIcons")

	theme_cache.error_color = get_theme_color("error_color", "Editor")
	theme_cache.error_icon = get_theme_icon("Error", "EditorIcons")
	theme_cache.warning_color = get_theme_color("warning_color", "Editor")
	theme_cache.warning_icon = get_theme_icon("Warning", "EditorIcons")
	theme_cache.message_color = get_theme_color("font_color", "Editor") * Color(1, 1, 1, 0.6)


func _notification(what: int):
	match what:
		NOTIFICATION_ENTER_TREE:
			_update_theme()
			_load_state()
		NOTIFICATION_READY:
			_update_theme()
		NOTIFICATION_THEME_CHANGED:
			_update_theme()
			_rebuild_log()


func _set_collapse(collapse: bool):
	self.collapse = collapse
	_start_state_save_timer()
	_rebuild_log()

func _start_state_save_timer():
	pass


func _save_state():
	pass


func _load_state():
	pass
	

func _clear_request():
	pass
	

func _copy_request():
	pass
	

func clear():
	_clear_request()


func _process_message(msg: String, type: MessageType):
	pass
	

func add_message(msg: String, type: MessageType):
	pass
	

func _rebuild_log():
	pass
	

func _add_log_line(message: LogMessage, replace_previous: bool):
	pass
	

func _set_filter_active(active: bool, type: MessageType):
	pass


func _set_search_visible(visible):
	pass


func _search_changed(new_text):
	pass


func _reset_message_counts():
	pass
