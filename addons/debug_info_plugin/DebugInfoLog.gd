@tool
class_name DebugInfoLog extends Object

var parent: DebugInfoManager
var key: String

func _init(parent: DebugInfoManager):
	self.parent = parent

func clear():
	if parent.log_panel != null:
		var log := parent.log_panel.get_log(key)
		if log != null: log.clear()
	parent.send_debugger_message(DebugInfoDebuggerPlugin.Messages.CLEAR_LOG, [key])

func add_message(msg: String, type: DebugInfoEditorLog.MessageType):
	if parent.log_panel != null:
		var log := parent.log_panel.get_log(key)
		if log != null: log.add_message(msg, type)
	parent.send_debugger_message(DebugInfoDebuggerPlugin.Messages.ADD_LOG_MESSAGE, [key, msg, type])

func set_title(title: String):
	if parent.log_panel != null:
		var log := parent.log_panel.get_log(key)
		if log != null: log.title = title
	parent.send_debugger_message(DebugInfoDebuggerPlugin.Messages.SET_LOG_TITLE, [key, title])

func print(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.STD)

func print_rich(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.STD_RICH)

func printerr(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.ERROR)

func print_warning(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.WARNING)

