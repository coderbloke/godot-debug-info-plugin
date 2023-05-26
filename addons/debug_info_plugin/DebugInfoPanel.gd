@tool
class_name DebugInfoPanel extends VBoxContainer

@onready var slot_list := $SlotContainer/SlotList
@onready var template_slot := $SlotContainer/SlotList/TemplateSlot
@onready var template_separator := $SlotContainer/SlotList/TemplateSeparator

@export var trigger_create: bool = false:
	set(new_value):
		if new_value:
			create_slot()

var slots: Dictionary = { }

var selected_slot_key: String

func get_slot(key: String) -> DebugInfoPanelSlot:
	var slot: DebugInfoPanelSlot
	if slots.has(key):
		slot = slots[key]
	else:
		slot = create_slot()
		if slot != null:
			slots[key] = slot
	if slot != null:
		slot.key = key
	return slot
	
func create_slot() -> DebugInfoPanelSlot:
	var slot := template_slot.duplicate(DUPLICATE_USE_INSTANTIATION)
	slot.visible = true
	slot_list.add_child(slot)
	slot.selection_changed.connect(_on_slot_selection_changed)
	var separator := template_separator.duplicate(DUPLICATE_USE_INSTANTIATION)
	separator.visible = true
	slot_list.add_child(separator)
	return slot
	
func _on_slot_selection_changed(key: String):
	#print("[" + key + "] selected = " + str(slots[key].selected))
	pass
	
func remove_timed_out_slots():
	var keys_to_remove = []
	var slots_to_remove = []
	var separators_to_remove = []
	for key in slots:
		var slot = slots[key]
		if slot.is_timed_out():
			keys_to_remove.append(key)
			slots_to_remove.append(slot)
	for slot in slots_to_remove:
		var i = slot.get_index() + 1
		while i < slot_list.get_child_count():
			var child = slot_list.get_child(i)
			if child is HSeparator:
				separators_to_remove.append(child)
			else:
				break
			i += 1
	for key in keys_to_remove:
		slots.erase(key)
	for slot in slots_to_remove:
		slot_list.remove_child(slot)
	for separator in separators_to_remove:
		slot_list.remove_child(separator)

func _init():
	pass
	
func _ready():
	template_slot.visible = false 
	template_separator.visible = false 

func _process(delta):
	remove_timed_out_slots()
	pass

