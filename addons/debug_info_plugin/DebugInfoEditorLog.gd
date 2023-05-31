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

@onready var log := %Log as RichTextLabel

@onready var clear_button := %ClearButton as Button
@onready var copy_button := %CopyButton as Button
	
@onready var collapse_button := %CollapseButton as Button
var collapse := false
		
var tool_button: Button # TODO: intro state for tool_button, make _update_function, call it from setter also
	
@onready var show_search_button := %ShowSearchButton as Button
@onready var search_box := %SearchBox as LineEdit

@onready var is_loading_state := false
@onready var save_state_timer := %SaveStateTimer as Timer


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
			_load_state()
		NOTIFICATION_THEME_CHANGED:
			_update_theme()
			_rebuild_log()


func _set_collapse(collapse: bool):
	self.collapse = collapse
	_start_state_save_timer()
	_rebuild_log()
	

func _start_state_save_timer():
	if not is_loading_state:
		save_state_timer.start()


func _save_state():
	var editor_path := EditorPaths.new()
	var config := ConfigFile.new()
	# Load and amend existing config if it exists.
	config.load(editor_path.get_project_settings_dir().path_join("editor_layout.cfg"))

	const section := "editor_log"
	for key in type_filter_map:
		config.set_value(section, "log_filter_" + str(key), type_filter_map[key].is_active())

	config.set_value(section, "collapse", collapse)
	config.set_value(section, "show_search", search_box.is_visible())

	config.save(editor_path.get_project_settings_dir().path_join("editor_layout.cfg"))


func _load_state():
	if not is_node_ready():
		return
	
	is_loading_state = true

	var editor_path := EditorPaths.new()
	var config := ConfigFile.new()
	config.load(editor_path.get_project_settings_dir().path_join("editor_layout.cfg"))

	# Run the below code even if config.load returns an error, since we want the defaults to be set even if the file does not exist yet.
	const section := "debug_info_editor_log"
	for key in type_filter_map:
		type_filter_map[key].active = config.get_value(section, "log_filter_" + str(key), true) as bool

	collapse = config.get_value(section, "collapse", false)
	collapse_button.button_pressed = collapse
	var show_search := config.get_value(section, "show_search", true) as bool
	search_box.visible = show_search
	show_search_button.button_pressed = show_search

	is_loading_state = false


func _clear_request():
	log.clear()
	messages.clear()
	_reset_message_counts()
	if tool_button != null:
		tool_button.icon = Texture2D.new()


func _copy_request():
	var text := log.get_selected_text()

	if text.is_empty():
		text = log.get_parsed_text()

	if not text.is_empty():
		DisplayServer.clipboard_set(text)


func clear():
	_clear_request()


func _process_message(msg: String, type: MessageType):
	if messages.size() > 0 and messages[messages.size() - 1].text == msg and messages[messages.size() - 1].type == type:
		# If previous message is the same as the new one, increase previous count rather than adding another
		# instance to the messages list.
		var previous := messages[messages.size() - 1]
		previous.count += 1
		_add_log_line(previous, collapse)
	else:
		# Different message to the previous one received.
		var message := LogMessage.new(msg, type)
		_add_log_line(message, type)
		messages.push_back(message)

	type_filter_map[type].message_count += 1
	

func add_message(msg: String, type: MessageType):
	var lines := msg.split("\n", true)
	for line in lines:
		_process_message(line, type)


func _rebuild_log():
	if log == null:
		return
	
	log.clear()

	for msg in messages:
		if collapse:
			# If collapsing, only log one instance of the message.
			_add_log_line(msg)
		else:
			# If not collapsing, log each instance on a line.
			for i in msg.count:
				_add_log_line(msg)


func _add_log_line(message: LogMessage, replace_previous: bool = false):
	if not is_inside_tree():
		# The log will be built all at once when it enters the tree and has its theme items.
		return

#	if log.is_updating(): # Non-existing in GDScript
#		# The new message arrived during log RTL text processing/redraw (invalid BiDi control characters / font error), ignore it to avoid RTL data corruption.
#		return

	# Only add the message to the log if it passes the filters.
	var filter_active := (type_filter_map[message.type] as LogFilter).active
	var search_text := search_box.text
	var search_match := search_text.is_empty() or message.text.findn(search_text) > -1

	if !filter_active or !search_match:
		return

	if replace_previous:
		# Remove last line if replacing, as it will be replace by the next added line.
		# Why "- 2"? RichTextLabel is weird. When you add a line with add_newline(), it also adds an element to the list of lines which is null/blank,
		# but it still counts as a line. So if you remove the last line (count - 1) you are actually removing nothing...
		log.remove_paragraph(log.get_paragraph_count() - 2)

	match message.type:
		MessageType.STD:
			pass
		MessageType.STD_RICH:
			pass
		MessageType.ERROR:
			log.push_color(theme_cache.error_color)
			var icon := theme_cache.error_icon
			log.add_image(icon)
			log.add_text(" ")
			if tool_button != null:
				tool_button.icon = icon
		MessageType.WARNING:
			log.push_color(theme_cache.warning_color)
			var icon := theme_cache.warning_icon
			log.add_image(icon)
			log.add_text(" ")
			if tool_button != null:
				tool_button.set_icon(icon)
		MessageType.EDITOR:
			# Distinguish editor messages from messages printed by the project
			log.push_color(theme_cache.message_color)

	# If collapsing, add the count of this message in bold at the start of the line.
	if collapse and message.count > 1:
		log.push_bold()
		log.add_text("(%s) " % message.count)
		log.pop()

	if message.type == MessageType.STD_RICH:
		log.append_text(message.text)
	else:
		log.add_text(message.text)

	# Need to use pop() to exit out of the RichTextLabels current "push" stack.
	# We only "push" in the above switch when message type != STD and RICH, so only pop when that is the case.
	if message.type != MessageType.STD && message.type != MessageType.STD_RICH:
		log.pop()

	log.newline()
	

func _set_filter_active(active: bool, type: MessageType):
	type_filter_map[type].set_active(active)
	_start_state_save_timer()
	_rebuild_log()


func _set_search_visible(visible):
	search_box.visible = visible
	if visible:
		search_box.grab_focus()
	_start_state_save_timer()


func _search_changed(new_text):
	_rebuild_log()


func _reset_message_counts():
	for key in type_filter_map:
		type_filter_map[key].message_count = 0