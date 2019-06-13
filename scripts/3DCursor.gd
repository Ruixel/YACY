extends Spatial

onready var camera    = get_node("../EditorCamera/Camera")
onready var WorldAPI  = get_node("../WorldInterface")
onready var EditorGUI = get_node("../GUI")

# For handling different methods of placement
enum CursorStates { 
	WALL, PLATFORM, OBJECT
}
var state = CursorStates.WALL

# For detecting mouse movement
var mouse_motion = Vector2()
var motion_detected = false

# Grid information for placing geometry / objects
var grid_plane = Plane(Vector3(0,-1,0), 0.0)
var grid_spacing = 1
var grid_num = 20
var grid_pos = Vector2()
var grid_height = 0

# Wall creation info
var placement_start = Vector2()
var placement_end = Vector2()

# Prototype
# This shows a preview of what will be placed and where
var prototype = null
var prototype_size = Vector2()
var prototype_placements = PoolVector2Array()

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
			grid_pos.x = clamp(round(grid_intersection.x / grid_spacing), 0, grid_num)
			grid_pos.y = clamp(round(grid_intersection.z / grid_spacing), 0, grid_num)
			
			self.transform.origin = Vector3(grid_pos.x * grid_spacing, grid_height, grid_pos.y * grid_spacing)
		
		motion_detected = true
	
	match (state):
		CursorStates.WALL:
			_wall_process()
		CursorStates.PLATFORM:
			_plat_process()
	
	mouse_motion = Vector2()

func _wall_process():
	if Input.is_action_just_pressed("editor_place"):
		placement_start = grid_pos
		
		WorldAPI.selection_create()
	
	if Input.is_action_pressed("editor_place"):
		placement_end = grid_pos
		
		if placement_start != placement_end:
			WorldAPI.selection_buildWall(placement_start, placement_end)
	
	if Input.is_action_just_released("editor_place"):
		pass

func _plat_process():
	if prototype == null:
		var prototype_info = WorldAPI.get_prototype(WorldConstants.Tools.PLATFORM)
		prototype          = prototype_info[0]
		prototype_size     = prototype_info[1]
		self.visible = false
	
	if Input.is_action_just_pressed("editor_place"):
		WorldAPI.selection_create()
	
	if Input.is_action_pressed("editor_place"):
		WorldAPI.selection_buildPlat(grid_pos)
	else:
		# Show prototype 
		grid_pos.x = clamp(grid_pos.x, floor(prototype_size.x / 2), grid_num - floor(prototype_size.x / 2))
		grid_pos.y = clamp(grid_pos.y, floor(prototype_size.y / 2), grid_num - floor(prototype_size.y / 2))
		prototype.transform.origin = Vector3(grid_pos.x, 0, grid_pos.y)
	
	if Input.is_action_just_released("editor_place"):
		pass

func _input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

func on_tool_change(type):
	if prototype != null:
		prototype.queue_free()
		prototype = null
	
	match (type):
		WorldConstants.Tools.WALL:
			state = CursorStates.WALL
			self.visible = true
		WorldConstants.Tools.PLATFORM:
			state = CursorStates.PLATFORM

func on_level_change(level):
	grid_height = (level - 1) * WorldConstants.LEVEL_HEIGHT
	grid_plane = Plane(Vector3(0,1,0), grid_height)
	
	prototype = null # Recreate prototype with correct height