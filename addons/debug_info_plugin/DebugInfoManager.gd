@tool
class_name DebugInfoManager extends Node

var info_panel: DebugInfoPanel
var log_panel: DebugInfoEditorLogPanel

var slots = { }
var logs = { }

const DEFAULT_LOG_KEY = "default"

var log: DebugInfoLog:
	get:
		if log == null:
			log = get_log(DEFAULT_LOG_KEY)
		return log

func get_slot(key: String, clear := true, timeout := -1) -> DebugInfoSlot:
	var slot: DebugInfoSlot
	if slots.has(key):
		slot = slots[key]
	else:
		slot = DebugInfoSlot.new(self)
		slot.key = key
		slots[key] = slot
	if clear:
		slot.clear()
	if timeout >= 0:
		slot.set_timeout(timeout)
	return slot
	
func get_log(key: String, title: String = "") -> DebugInfoLog:
	var log: DebugInfoLog
	if logs.has(key):
		log = logs[key]
	else:
		log = DebugInfoLog.new(self)
		log.key = key
		logs[key] = log
	if title.length() > 0:
		log.set_title(title)
	log.redirect_to_main = false
	return log
	
func send_debugger_message(message: String, data: Array):
	if OS.is_debug_build() and not Engine.is_editor_hint():
#		print("[send_debugger_message] message " + str(message) + ", data = " + str(data))
		EngineDebugger.send_message("DebugInfo:" + message, data)
