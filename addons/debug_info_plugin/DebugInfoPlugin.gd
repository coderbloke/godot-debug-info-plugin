@tool
class_name DebugInfoPlugin extends EditorPlugin

const AUTOLOAD_NAME = "DebugInfo"

var singleton: DebugInfoManager

var info_panel: DebugInfoPanel = preload("debug_info_panel.tscn").instantiate()
var log_panel = preload("debug_info_editor_log_panel.tscn").instantiate()

var debugger_plugin = DebugInfoDebuggerPlugin.new()

func init_singleton():
	singleton = get_node_or_null("/root/" + AUTOLOAD_NAME)
	if singleton != null:
		singleton.info_panel = info_panel
		singleton.log_panel = log_panel
		singleton.log = log_panel.get_default_log()

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, self.get_script().get_path().get_base_dir() + "/DebugInfoManager.gd")
	init_singleton()
	
	add_control_to_dock(DOCK_SLOT_LEFT_BR, info_panel)
	add_debugger_plugin(debugger_plugin)
	debugger_plugin.info_panel = info_panel
	debugger_plugin.log_panel = log_panel
	
	add_control_to_bottom_panel(log_panel, "DebugInfoLog")

func _process(delta):
	# Do once somehow
	init_singleton()
	
func _exit_tree():
	if singleton != null:
		singleton.info_panel = null
		singleton.log = null
		
	remove_control_from_docks(info_panel)
	info_panel.queue_free()
	
	remove_debugger_plugin(debugger_plugin)

	remove_control_from_bottom_panel(log_panel)
	log_panel.queue_free()

