@tool
class_name DebugInfoPlugin extends EditorPlugin

const AUTOLOAD_NAME = "DebugInfo"

var singleton: DebugInfoManager

var info_panel: DebugInfoPanel = preload("debug_info_panel.tscn").instantiate()

var log_panel = preload("debug_info_editor_log_panel.tscn").instantiate()
var log_config_file_path: String
var log_config_file: ConfigFile

var debugger_plugin = DebugInfoDebuggerPlugin.new()

func init_singleton():
	singleton = get_node_or_null("/root/" + AUTOLOAD_NAME) as DebugInfoManager
	if singleton != null:
		singleton.info_panel = info_panel
		singleton.log_panel = log_panel

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, self.get_script().get_path().get_base_dir() + "/DebugInfoManager.gd")
	init_singleton()
	
	add_control_to_dock(DOCK_SLOT_LEFT_BR, info_panel)
	add_debugger_plugin(debugger_plugin)
	debugger_plugin.info_panel = info_panel
	
	var editor_paths := EditorPaths.new()
	log_config_file_path = editor_paths.get_project_settings_dir().path_join("debug_info_editor_logs.cfg")

	log_config_file = ConfigFile.new()
	log_config_file.load(log_config_file_path)
	log_panel.log_created.connect(_on_log_created)
	log_panel.log_settings_changed.connect(_on_log_settings_changed)
	log_panel.get_default_log(true)
	debugger_plugin.log_panel = log_panel
	
	add_control_to_bottom_panel(log_panel, "DebugInfoLog")

func _on_log_created(log_key: String, log: DebugInfoEditorLog):
	if log_config_file.has_section(log_key):
		var settings = { }
		for setting_key in log_config_file.get_section_keys(log_key):
			settings[setting_key] = log_config_file.get_value(log_key, setting_key)
		log._load_settings(settings)

func _on_log_settings_changed(log_key: String, log: DebugInfoEditorLog):
	var settings = log._get_settings()
	for setting_key in settings:
		log_config_file.set_value(log_key, setting_key, settings[setting_key])
	var editor_path := EditorPaths.new()
	log_config_file.save(log_config_file_path)

func _process(delta):
	# Do once somehow
	init_singleton()
	
func _exit_tree():
	if singleton != null:
		singleton.info_panel = null
		singleton.log = null
		
	remove_control_from_docks(info_panel)
	info_panel.queue_free()
	
	var editor_path := EditorPaths.new()
	remove_debugger_plugin(debugger_plugin)

	remove_control_from_bottom_panel(log_panel)
	log_panel.queue_free()

