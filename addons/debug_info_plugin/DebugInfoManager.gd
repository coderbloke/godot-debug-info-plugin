@tool
class_name DebugInfoManager extends Node

var info_panel: DebugInfoPanel

var send_debugger_messages := true
var slots = { }

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
	
func send_debugger_message(message: String, data: Array):
	if OS.is_debug_build() and not Engine.is_editor_hint():
#		print("[send_debugger_message] message " + str(message) + ", data = " + str(data))
		EngineDebugger.send_message("DebugInfo:" + message, data)
