@tool
class_name DebugInfoEditorLogPanel extends VBoxContainer

@onready var tab_bar := %TabBar as TabBar
@onready var log_container := %LogContainer
@onready var default_log := %DefaultLog as DebugInfoEditorLog
@onready var no_log_info := %NoLogInfo as Label

var logs: Dictionary = { }
var tabbed_logs_in_order: Array[DebugInfoEditorLog] = []

var external: bool = false

@export var always_show_tab_bar: bool = false:
	set(new_value):
		if new_value != always_show_tab_bar:
			always_show_tab_bar = new_value
			_update_children_visibility()
@export var auto_activate_new_tabs: bool = false

var selected_tabbed_log_index := 0:
	set(new_value):
		if new_value != selected_tabbed_log_index:
			selected_tabbed_log_index = clampi(new_value, 0, tabbed_logs_in_order.size())
			_update_children_visibility()

func _ready():
	logs["default"] = default_log
	tabbed_logs_in_order = [default_log]
	tab_bar.tab_selected.connect(_on_tab_selected)
	tab_bar.tab_close_pressed.connect(_on_tab_close_pressed)
	tab_bar.active_tab_rearranged.connect(_on_active_tab_rearranged)
	default_log.external_change_requested.connect(_on_external_change_requested)
	default_log.updated.connect(_ensure_log_is_visible)

func get_default_log():
	return default_log
	
func _add_log_to_tabs(log: DebugInfoEditorLog):
	tab_bar.add_tab(log.title)
	tabbed_logs_in_order.append(log)
	
func _ensure_log_is_visible(log: DebugInfoEditorLog):
	if logs.values().find(log) < 0 and not log.visible:
		_add_log_to_tabs(log)
		_update_children_visibility()

func get_log(key: String) -> DebugInfoEditorLog:
	var log: DebugInfoEditorLog
	if logs.has(key):
		log = logs[key]
		if log == default_log:
			_ensure_log_is_visible(default_log)
	else:
		log = _create_log()
		log.title = key
		logs[key] = log
	return log
	
func _create_log() -> DebugInfoEditorLog:
	var log := default_log.duplicate(DUPLICATE_USE_INSTANTIATION)
	log.visible = false
	log_container.add_child(log)
	log.title_changed.connect(_on_log_title_changed)
	_add_log_to_tabs(log)
	_update_children_visibility()
	return log

func _update_children_visibility():
	if not is_node_ready():
		return
	no_log_info.visible = (tabbed_logs_in_order.size() == 0)
	log_container.visible = (tabbed_logs_in_order.size() > 0)
	tab_bar.visible = (tabbed_logs_in_order.size() > 0 \
			and (always_show_tab_bar or tabbed_logs_in_order.size() > 1))
	for i in tabbed_logs_in_order.size():
		var log_visible := (i == selected_tabbed_log_index)
		if tabbed_logs_in_order[i].visible != log_visible:
			tabbed_logs_in_order[i].visible = log_visible
	if tab_bar.tab_count > 0 and tab_bar.current_tab != selected_tabbed_log_index:
		tab_bar.current_tab = selected_tabbed_log_index

func _update_tab_titles():
	for i in tabbed_logs_in_order.size():
		if tab_bar.get_tab_title(i) != tabbed_logs_in_order[i].title:
			tab_bar.set_tab_title(i, tabbed_logs_in_order[i].title)

func _on_log_title_changed(log: DebugInfoEditorLog):
	var tab_index := tabbed_logs_in_order.find(log)
	if tab_index >= 0:
		tab_bar.set_tab_title(tab_index, log.title)

func _on_tab_selected(tab: int):
	selected_tabbed_log_index = tab
	
func _remove_log_from_tabs(log: DebugInfoEditorLog):
	var tab_index = tabbed_logs_in_order.find(log)
	if tab_index < 0:
		return
	tab_bar.remove_tab(tab_index)
	tabbed_logs_in_order.remove_at(tab_index)
	if log == default_log:
		default_log.visible = false
	else:
		log_container.remove_child(log)
	var tabbed_log_index_to_select: int 
	if tab_index < selected_tabbed_log_index:
		tabbed_log_index_to_select = selected_tabbed_log_index - 1
	else:
		tabbed_log_index_to_select = selected_tabbed_log_index 
	if tabbed_log_index_to_select >= tab_bar.tab_count:
		tabbed_log_index_to_select = tab_bar.tab_count - 1
	selected_tabbed_log_index = tabbed_log_index_to_select

func _on_tab_close_pressed(tab: int):
	var closed_log := tabbed_logs_in_order[tab]
	if closed_log == default_log:
		default_log.clear()
	_remove_log_from_tabs(closed_log)
	logs.erase(logs.find_key(closed_log))
	if closed_log != default_log:
		closed_log.queue_free()
	_update_children_visibility()

func _on_active_tab_rearranged(idx_to: int):
	var moved_log := tabbed_logs_in_order[selected_tabbed_log_index]
	tabbed_logs_in_order.remove_at(selected_tabbed_log_index)
	tabbed_logs_in_order.insert(idx_to, moved_log)
	_update_tab_titles()

func _on_external_change_requested(log: DebugInfoEditorLog, external: bool):
	if external:
		_externalize_log(log)
	else:
		_dock_log(log)
		
var window_variant := 0

var external_windows = []

func _externalize_log(log: DebugInfoEditorLog):
	var window = preload("debug_info_editor_log_window.tscn").instantiate()
	add_child(window)
	window.popup_centered(Vector2i(1280, 720))
	external_windows.append(window)
	log.external = true
	
func _dock_log(log: DebugInfoEditorLog):
	log.external = false
