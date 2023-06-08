@tool
class_name DebugInfoLog extends Object

var parent: DebugInfoManager
var key: String
var redirect_to_main: bool = false

func _init(parent: DebugInfoManager):
	self.parent = parent

func clear():
	if parent.log_panel != null:
		var log := parent.log_panel.get_log(key)
		if log != null: log.clear()
	parent.send_debugger_message(DebugInfoDebuggerPlugin.Messages.CLEAR_LOG, [key])

var collected_raw_msg := ""

func add_message(msg: String, type: DebugInfoEditorLog.MessageType):
	if collected_raw_msg.length() > 0:
		msg = collected_raw_msg + msg
		collected_raw_msg = ""
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
	if redirect_to_main:
		print(msg)

func print_rich(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.STD_RICH)
	if redirect_to_main:
		print_rich(msg)
	
func print_colored(color: Color, msg):
	self.print_rich("[color=#%s]%s[/color]" % [color.to_html(false), str(msg)])
	
func print_verbose(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.VERBOSE)
	if redirect_to_main:
		print_verbose(msg)

func printerr(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.ERROR)
	if redirect_to_main:
		printerr(msg)

func printraw(msg):
	collected_raw_msg += msg
	if redirect_to_main:
		printraw(msg)

func print_error(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.ERROR)
	if redirect_to_main:
		printerr(msg)

func print_warning(msg):
	add_message(str(msg), DebugInfoEditorLog.MessageType.WARNING)
	if redirect_to_main:
		print(msg)

func print_call_stack():
	var call_stack = get_stack()
	print_verbose("call_stack = " + str(call_stack))
	for i in call_stack.size():
		print(call_stack[i])
