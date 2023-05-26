@icon("ProgressDisk.svg")

@tool
class_name ProgressDisk extends Control

@export var min: float = 0:
	set(value):
		min = value
		queue_redraw()
@export var max: float = 1:
	set(value):
		max = value
		queue_redraw()
@export var value: float = 0:
	set(new_value):
		value = new_value
		queue_redraw()
@export var resolution: int = 0:
	set(new_value):
		resolution = new_value
		queue_redraw()
		
@export_group("Draw settings")
@export var diameter: float = 16:
	set(value):
		diameter = value
		if fit_size:
			update_custom_minimum_size()
		queue_redraw()
@export var margin: float = 4:
	set(value):
		margin = value
		if fit_size:
			update_custom_minimum_size()
		queue_redraw()
@export var fit_size: bool = true:
	set(value):
		fit_size = value
		if fit_size:
			update_custom_minimum_size()
@export_range(-180, 180, 0.001, "radians", "or_greater", "or_less")
var start_angle: float = 0:
	set(value):
		start_angle = value
		queue_redraw()
@export_enum("Clockwise:0", "Counterclockwise:1")
var direction: int = 0:
	set(value):
		direction = value
		queue_redraw()
@export_enum("Left:0", "Center:1", "Right:2")
var horizontal_aligment: int = 1:
	set(value):
		horizontal_aligment = value
		queue_redraw()
@export_enum("Top:0", "Center:1", "Bottom:2")
var vertical_aligment: int = 1:
	set(value):
		vertical_aligment = value
		queue_redraw()
@export var progress_color: Color = Color.WHITE
@export var background_color: Color = Color(1.0, 1.0, 1.0, 0.25)
		
func update_custom_minimum_size():
	var s = diameter + 2 * margin
	custom_minimum_size = Vector2(s, s)

func _draw():
	var min_segment_count := 20
	var max_segment_length := 10.0
	var radius := diameter / 2
	var segment_count := maxi(int(ceil((2 * PI * radius) / max_segment_length)), min_segment_count)
	var delta_angle := (2 * PI) / segment_count 
	var normalized_progress := clampf((value - min) / (max - min), 0, 1)
	if resolution > 0:
		if normalized_progress > 0.99999:
			normalized_progress = 1
		else:
			normalized_progress -= fmod(normalized_progress, 1.0 / resolution)
	var threshold_angle := (2 * PI) * normalized_progress
	var center := Vector2()
	match horizontal_aligment:
		HORIZONTAL_ALIGNMENT_LEFT:
			center.x = margin + radius
		HORIZONTAL_ALIGNMENT_RIGHT:
			center.x = size.x - (margin + radius)
		_:
			center.x = size.x / 2
	match vertical_aligment:
		VERTICAL_ALIGNMENT_TOP:
			center.y = margin + radius
		VERTICAL_ALIGNMENT_BOTTOM:
			center.y = size.y - (margin + radius)
		_:
			center.y = size.y / 2
	var progress_points := PackedVector2Array()
	var remaining_points := PackedVector2Array()
	var n := segment_count
	if normalized_progress > 0 and normalized_progress < 1:
		progress_points.append(center)
		remaining_points.append(center)
		n += 1
	var radius_vector := Vector2(0, -1) * radius
	var angle := 0.0
	var angle_direction := -1 if direction == COUNTERCLOCKWISE else 1
	for i in n:
		var p := center + radius_vector.rotated(start_angle + angle_direction * angle)
		var next_angle = angle + delta_angle
		if angle < threshold_angle:
			progress_points.append(p)
			if next_angle >= threshold_angle:
				p = center + radius_vector.rotated(start_angle + angle_direction * threshold_angle)
				if angle < threshold_angle and normalized_progress < 1:
					progress_points.append(p)
				if next_angle > threshold_angle:
					remaining_points.append(p)
		else:
			remaining_points.append(p)
		angle = next_angle
	if remaining_points.size() >= 3:
		draw_colored_polygon(remaining_points, background_color)
	if progress_points.size() >= 3:
		draw_colored_polygon(progress_points, background_color.blend(progress_color))

func _ready():
	pass

func _process(delta):
	pass
