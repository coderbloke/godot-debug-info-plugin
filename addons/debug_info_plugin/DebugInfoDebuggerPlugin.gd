@tool
class_name ExampleEditorDebugger extends EditorDebuggerPlugin

var info_panel: DebugInfoPanel

func _has_capture(prefix):
	return prefix == "DebugInfo"

func _capture(message, data, session_id):
#	print("*** [_capture] session_id = " + str(session_id)
#		+ ", message = " + str(message) + ", data = " + str(data))
	var key = "[" + str(session_id) + "] " + data[0]
	var processed := true
	match message:
		"DebugInfo:clear":
			var panel_slot = info_panel.get_slot(key)
			if panel_slot != null: panel_slot.clear()
		"DebugInfo:set_timeout":
			var panel_slot = info_panel.get_slot(key)
			if panel_slot != null: panel_slot.timeout = data[1]
		"DebugInfo:add_line":
			var panel_slot = info_panel.get_slot(key)
			if panel_slot != null: panel_slot.add_line(data[1])
		_:
			processed = false
	return processed

func _setup_session(session_id):
	pass
