extends Spatial

onready var camera    = get_node("../EditorCamera/Camera")
onready var WorldAPI  = get_node("../WorldInterface")
onready var EditorGUI = get_node("../GUI")
const Vector2i = preload('res://scripts/Vec2i.gd')

# For handling different methods of placement
enum CursorStates { 
	WALL, PLATFORM, OBJECT
}
var state = CursorStates.WALL

# Input
# For detecting mouse movement
var mouse_motion := Vector2()
var motion_detected := false

var mouse_place_just_pressed := false
var mouse_place_pressed      := false
var mouse_place_released     := false

# Grid information for placing geometry / objects
var grid_plane   := Plane(Vector3(0,-1,0), 0.0)
var grid_pos     = Vector2i.new()
var grid_spacing : int = 1
var grid_num     : int = 20
var grid_height  : int = 0

# Wall creation info
var placement_start = Vector2i.new()
var placement_end = Vector2i.new()

# Prototype
# This shows a preview of what will be placed and where
var prototype      = null
var prototype_size = Vector2i.new(2, 2)
var prototype_placements       = Array()
var prototype_placement_offset = Vector2i.new()

# Connect signals
func _ready():
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")

func _process(delta: float) -> void:
	motion_detected = false

	if mouse_motion != Vector2():
		# Cast ray directly from camera
		var ray_origin = camera.get_camera_transform().origin
		var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position()).normalized()
		
		# If it intersects with the grid, place the cursor on the new position
		var grid_intersection = grid_plane.intersects_ray(ray_origin, ray_direction)
		if grid_intersection != null:
			# Calculate nearest grid edge
			grid_pos.x = clamp(round(grid_intersection.x / grid_spacing), 0, grid_num) as int
			grid_pos.y = clamp(round(grid_intersection.z / grid_spacing), 0, grid_num) as int
			
			self.transform.origin = Vector3(grid_pos.x * grid_spacing, grid_height, grid_pos.y * grid_spacing)
		
		motion_detected = true
	
	match (state):
		CursorStates.WALL:
			_wall_process()
		CursorStates.PLATFORM:
			_plat_process()
	
	mouse_motion = Vector2()

func _wall_process():
	if mouse_place_just_pressed:
		placement_start.assign(grid_pos)
		WorldAPI.selection_create()
		mouse_place_just_pressed = false
	
	if mouse_place_pressed:
		placement_end.assign(grid_pos)
		
		if not placement_start.equals(placement_end):
			WorldAPI.selection_buildWall(placement_start.cast_to_v2(), placement_end.cast_to_v2())
	
	if mouse_place_released:
		pass

func _plat_process():
	if prototype == null:
		var prototype_info = WorldAPI.get_prototype(WorldConstants.Tools.PLATFORM)
		prototype          = prototype_info[0]
		prototype_size     = Vector2i.new(prototype_info[1])
		self.visible = false
	
	if mouse_place_just_pressed:
		WorldAPI.selection_create()
		WorldAPI.selection_buildPlat(grid_pos.cast_to_v2())
		
		prototype_placements.clear()
		prototype_placement_offset.x = grid_pos.x % prototype_size.x
		prototype_placement_offset.y = grid_pos.y % prototype_size.y
		
		mouse_place_just_pressed = false
	
	if mouse_place_pressed:
		if motion_detected:
			if check_prototype_placements(grid_pos, prototype_size):
				WorldAPI.selection_create()
				WorldAPI.selection_buildPlat(grid_pos.cast_to_v2())
				add_prototype_placements(grid_pos, prototype_size)
	else:
		# Show prototype 
		grid_pos.x = clamp(grid_pos.x, floor(prototype_size.x / 2), grid_num - floor(prototype_size.x / 2)) as int 
		grid_pos.y = clamp(grid_pos.y, floor(prototype_size.y / 2), grid_num - floor(prototype_size.y / 2)) as int
		prototype.transform.origin = Vector3(grid_pos.x, 0, grid_pos.y)
	
	if mouse_place_released:
		pass

func _input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			if event.is_pressed():
				if mouse_place_pressed == false:
					mouse_place_just_pressed = true
				mouse_place_pressed = true
			else:
				if mouse_place_released == false and mouse_place_pressed == true:
					mouse_place_released = false
				mouse_place_pressed = false

func destroy_prototype() -> void:
	if prototype != null:
		prototype.queue_free()
		prototype = null

func on_tool_change(type) -> void:
	destroy_prototype()
	
	match (type):
		WorldConstants.Tools.WALL:
			state = CursorStates.WALL
			self.visible = true
		WorldConstants.Tools.PLATFORM:
			state = CursorStates.PLATFORM

func on_level_change(level) -> void:
	destroy_prototype()
	grid_height = (level - 1) * WorldConstants.LEVEL_HEIGHT
	grid_plane = Plane(Vector3(0,1,0), grid_height)
	
	prototype = null # Recreate prototype with correct height

# Iterates through the placements to make sure it doesn't place objects overlapping
func check_prototype_placements(pos, size) -> bool:
	#for x in range(pos.x - size.x/2, pos.x + size.x/2):
	print("x: ", pos.x % size.x, ", offset: ", prototype_placement_offset.x)
	if ((pos.x % size.x == prototype_placement_offset.x) and (pos.y % size.y == prototype_placement_offset.y)):
		if not prototype_placements.has(pos.x + (grid_num * pos.y)):
			return true
	return false
	
func add_prototype_placements(pos , size) -> void:
	prototype_placements.append(pos.x + (grid_num * pos.y))