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

# Grid information for placing geometry / objects
var grid_plane = Plane(Vector3(0,-1,0), 0.0)
var grid_spacing = 1
var grid_num = 20
var grid_pos = Vector2()

# Wall creation info
var placement_start = Vector2()
var placement_end = Vector2()

# Prototype
# This shows a preview of what will be placed and where
var prototype = null
var prototype_size = Vector2()

# Connect signals
func _ready():
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")

func _process(delta: float) -> void:
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
			
			self.transform.origin = Vector3(grid_pos.x * grid_spacing, 0, grid_pos.y * grid_spacing)
	
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
		prototype = WorldAPI.get_prototype(WorldConstants.Tools.PLATFORM)
		self.visible = false
	
	if Input.is_action_just_pressed("editor_place"):
		WorldAPI.selection_create()
	
	if Input.is_action_pressed("editor_place"):
		WorldAPI.selection_buildPlat(grid_pos)
	else:
		# Show prototype 
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
