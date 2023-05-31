@tool
class_name DebugInfoPlugin extends EditorPlugin

const AUTOLOAD_NAME = "DebugInfo"

var singleton: DebugInfoManager
var info_panel: DebugInfoPanel = preload("debug_info_panel.tscn").instantiate()
var debugger_plugin = DebugInfoDebuggerPlugin.new()

func init_singleton():
	singleton = get_node_or_null("/root/" + AUTOLOAD_NAME)
	if singleton != null:
		singleton.info_panel = info_panel

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, self.get_script().get_path().get_base_dir() + "/DebugInfoManager.gd")
	init_singleton()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, info_panel)
	add_debugger_plugin(debugger_plugin)
	debugger_plugin.info_panel = info_panel
	
func _process(delta):
	init_singleton()
	
func _exit_tree():
	if singleton != null:
		singleton.info_panel = null
	remove_control_from_docks(info_panel)
	remove_debugger_plugin(debugger_plugin)

