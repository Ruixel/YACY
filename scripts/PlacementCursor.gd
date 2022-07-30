extends "CursorBase.gd"

onready var parent    = get_parent()
onready var camera    = get_node("../../EditorCamera/Camera")
onready var WorldAPI  = get_node("../../WorldInterface")

const Vector2i = preload('res://scripts/Vec2i.gd')

# Prototype
# This shows a preview of what will be placed and where
var prototype      = null
var prototype_size = Vector2i.new(2, 2)
var prototype_placements       = Array()
var prototype_placement_offset = Vector2i.new()

var grid_pos = Vector2i.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#WorldAPI.connect("update_prototype", self, "on_update_prototype")
	pass

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
			
		
		parent.motion_detected = true
	
	if prototype == null:
		var prototype_info = WorldAPI.get_prototype(parent.objType)
		prototype          = prototype_info[0]
		prototype_size     = Vector2i.new(prototype_info[1])
		self.visible = false
	
	if parent.mouse_place_just_pressed:
		WorldAPI.obj_create(grid_pos.cast_to_v2())
		
		prototype_placements.clear()
		prototype_placement_offset.x = grid_pos.x % prototype_size.x
		prototype_placement_offset.y = grid_pos.y % prototype_size.y
		
		parent.mouse_place_just_pressed = false
	
	if parent.mouse_place_pressed:
		if parent.motion_detected:
			if check_prototype_placements(grid_pos, prototype_size):
				WorldAPI.obj_create(grid_pos.cast_to_v2())
				add_prototype_placements(grid_pos, prototype_size)
	else:
		# Show prototype 
		grid_pos.x = clamp(grid_pos.x, floor(prototype_size.x / 2), parent.grid_num - floor(prototype_size.x / 2)) as int 
		grid_pos.y = clamp(grid_pos.y, floor(prototype_size.y / 2), parent.grid_num - floor(prototype_size.y / 2)) as int
		prototype.transform.origin = Vector3(grid_pos.x, 0, grid_pos.y)
	
	if parent.mouse_place_released:
		pass
	
	# Delete recently placed object
	if Input.is_action_just_pressed("editor_delete"):
		WorldAPI.selection_delete()


# Iterates through the placements to make sure it doesn't place objects overlapping
func check_prototype_placements(pos, size) -> bool:
	#for x in range(pos.x - size.x/2, pos.x + size.x/2):
	print("x: ", pos.x % size.x, ", offset: ", prototype_placement_offset.x)
	if ((pos.x % size.x == prototype_placement_offset.x) and (pos.y % size.y == prototype_placement_offset.y)):
		if not prototype_placements.has(pos.x + (parent.grid_num * pos.y)):
			return true
	return false

func add_prototype_placements(pos , size) -> void:
	prototype_placements.append(pos.x + (parent.grid_num * pos.y))

func destroy_prototype():
	if prototype != null:
		prototype.queue_free()
		prototype = null

func on_update_prototype(): # Signal
	destroy_prototype()

func cursor_on_tool_change(newTool) -> void:
	destroy_prototype()

func cursor_on_mode_change(newMode) -> void:
	destroy_prototype()

func cursor_on_level_change(newLevel) -> void:
	destroy_prototype()
