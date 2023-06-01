@tool
class_name DebugInfoSlot extends Object

var parent: DebugInfoManager
var key: String

func _init(parent: DebugInfoManager):
	self.parent = parent

func clear():
	if parent.info_panel != null:
		var panel_slot := parent.info_panel.get_slot(key)
		if panel_slot != null: panel_slot.clear()
	parent.send_debugger_message(DebugInfoDebuggerPlugin.Messages.CLEAR_SLOT, [key])

func set_timeout(timeout: float):
	if parent.info_panel != null:
		var panel_slot := parent.info_panel.get_slot(key)
		if panel_slot != null: panel_slot.timeout = timeout
	parent.send_debugger_message(DebugInfoDebuggerPlugin.Messages.SET_SLOT_TIMEOUT, [key, timeout])

func add_line(text: String):
	if parent.info_panel != null:
		parent.info_panel.get_slot(key).add_line(text)
	parent.send_debugger_message(DebugInfoDebuggerPlugin.Messages.ADD_SLOT_LINE, [key, text])
