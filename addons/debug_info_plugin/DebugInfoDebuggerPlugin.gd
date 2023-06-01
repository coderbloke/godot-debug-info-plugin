@tool
class_name DebugInfoDebuggerPlugin extends EditorDebuggerPlugin

const MESSAGE_PREFIX := "DebugInfo"

class Messages:
	const CLEAR_SLOT := "clear_slot"
	const SET_SLOT_TIMEOUT := "set_slot_timeout"
	const ADD_SLOT_LINE := "add_slot_line"
	const CLEAR_LOG := "clear_log"
	const ADD_LOG_MESSAGE := "add_log_message"
	const SET_LOG_TITLE := "set_log_title"

var info_panel: DebugInfoPanel
var log_panel: DebugInfoEditorLogPanel

func _has_capture(prefix):
	return prefix == "DebugInfo"

func _capture(message, data, session_id):
#	print("*** [_capture] session_id = " + str(session_id)
#		+ ", message = " + str(message) + ", data = " + str(data))
	var key = "[" + str(session_id) + "] " + data[0]
	var processed := true
	match message:
		MESSAGE_PREFIX + ":" + Messages.CLEAR_SLOT:
			var panel_slot = info_panel.get_slot(key)
			if panel_slot != null: panel_slot.clear()
		MESSAGE_PREFIX + ":" + Messages.SET_SLOT_TIMEOUT:
			var panel_slot = info_panel.get_slot(key)
			if panel_slot != null: panel_slot.timeout = data[1]
		MESSAGE_PREFIX + ":" + Messages.ADD_SLOT_LINE:
			var panel_slot = info_panel.get_slot(key)
			if panel_slot != null: panel_slot.add_line(data[1])
		MESSAGE_PREFIX + ":" + Messages.CLEAR_SLOT:
			var log = log_panel.get_log(key)
			if log != null: log.clear()
		MESSAGE_PREFIX + ":" + Messages.ADD_LOG_MESSAGE:
			var log = log_panel.get_log(key)
			if log != null: log.add_message(data[1], data[2])
		MESSAGE_PREFIX + ":" + Messages.SET_LOG_TITLE:
			var log = log_panel.get_log(key)
			if log != null: log.title = data[1]
		_:
			processed = false
	return processed

func _setup_session(session_id):
	pass
