extends "CursorBase.gd"

@onready var parent    = get_parent()
@onready var camera    = get_node("../../EditorCamera/Camera3D")
@onready var WorldAPI  = get_node("../../WorldInterface")

const Vector2i = preload('res://scripts/Vec2i.gd')

# Wall creation info
var placement_start = Vector2i.new()
var placement_end = Vector2i.new()

var grid_pos = Vector2i.new()

func cursor_ready(): 
	get_node("WallCursor").set_visible(true)

func cursor_process(delta: float, mouse_motion : Vector2) -> void:
	if mouse_motion != Vector2():
		# Cast ray directly from camera
		var ray_origin = camera.get_camera_transform().origin
		var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position()).normalized()
		
		# If it intersects with the grid, place the cursor on the new position
		var grid_intersection = parent.grid_plane.intersects_ray(ray_origin, ray_direction)
		if grid_intersection != null:
			# Calculate nearest grid edge
			grid_pos.x = clamp(round(grid_intersection.x / parent.grid_spacing), 0, parent.grid_num) as int
			grid_pos.y = clamp(round(grid_intersection.z / parent.grid_spacing), 0, parent.grid_num) as int
			
			self.transform.origin = Vector3(grid_pos.x * parent.grid_spacing, parent.grid_height, 
											grid_pos.y * parent.grid_spacing)
		
		parent.motion_detected = true
	
	if parent.mouse_place_just_pressed:
		placement_start.assign(grid_pos)
		WorldAPI.obj_create(grid_pos.cast_to_v2())
		parent.mouse_place_just_pressed = false
	
	if parent.mouse_place_pressed:
		placement_end.assign(grid_pos)
		
		if not placement_start.equals(placement_end):
			WorldAPI.property_end_vector(placement_end.cast_to_v2())
	
	if parent.mouse_place_released:
		pass
	
	if Input.is_action_just_pressed("editor_delete"):
		WorldAPI.selection_delete()

func cursor_on_tool_change(newTool):
	get_node("WallCursor").set_visible(false)
