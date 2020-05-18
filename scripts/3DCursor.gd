extends Spatial

onready var camera    = get_node("../EditorCamera/Camera")
onready var WorldAPI  = get_node("../WorldInterface")
onready var EditorGUI = get_node("../GUI")
const Vector2i = preload('res://scripts/Vec2i.gd')

# For handling different methods of placement

# How the object interacts in the editor
enum CursorType { 
	PENCIL, PLACEMENT, SELECT, POLYGON, NOTHING
}

var cMode = WorldConstants.Mode.CREATE  # Cursor Mode
var cType = CursorType.PENCIL           # Cursor Type (How it interacts)
var objType = WorldConstants.Tools.WALL # Object
onready var childCursor = get_node("Pencil")

# Input
# For detecting mouse movement
var mouse_motion := Vector2()
var motion_detected := false

var mouse_place_just_pressed := false
var mouse_place_pressed      := false
var mouse_place_released     := false

# Grid information for placing geometry / objects
var grid_plane   := Plane(Vector3(0,-1,0), 0.0)
var grid_spacing : int = 1
var grid_num     : int = 80
var grid_height  : float = 0

# Connect signals
func _ready():
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")
	EditorGUI.get_node("ObjectList").connect("s_changeMode", self, "on_mode_change")
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")
	
	childCursor.cursor_ready()

# Process every game frame
func _process(delta: float) -> void:
	motion_detected = false
	
	childCursor.cursor_process(delta, mouse_motion)
	
	mouse_motion = Vector2() # Reset

func _input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

# This takes in any input that wasn't used in the GUI 
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			if event.is_pressed():
				if mouse_place_pressed == false:
					mouse_place_just_pressed = true
				mouse_place_pressed = true
			else:
				if mouse_place_released == false and mouse_place_pressed == true:
					#mouse_place_released = false
					pass
				mouse_place_pressed = false
				
	elif event is InputEventKey:
		# Change the height property of an object via shortcut
		if event.get_scancode() >= KEY_0 and event.get_scancode() <= KEY_9:
			if event.is_echo() == false:
				# Return a number between 0 and 9
				WorldAPI.property_height_value(event.get_scancode() - KEY_0)

func on_tool_change(type) -> void:
	childCursor.cursor_on_tool_change(type)
	
	match (type):
		WorldConstants.Tools.WALL:
			cType = CursorType.PENCIL
			childCursor = get_node("Pencil")
		WorldConstants.Tools.PLATFORM:
			cType = CursorType.PLACEMENT
			childCursor = get_node("Placement")
		WorldConstants.Tools.PILLAR:
			cType = CursorType.PLACEMENT
			childCursor = get_node("Placement")
		WorldConstants.Tools.RAMP:
			cType = CursorType.PENCIL
			childCursor = get_node("Pencil")
		WorldConstants.Tools.GROUND:
			cType = CursorType.POLYGON
			childCursor = get_node("Polygon")
	
	objType = type
	mouse_place_just_pressed = false
	mouse_place_pressed = false
	mouse_place_released = false 
	
	if type != WorldConstants.Tools.NOTHING:
		childCursor.cursor_ready()

func on_mode_change(mode) -> void:
	childCursor.cursor_on_mode_change(mode)
	cMode = mode
	
	match (mode):
		WorldConstants.Mode.SELECT:
			cType = CursorType.SELECT
			childCursor = get_node("Select")

func on_level_change(level) -> void:
	childCursor.cursor_on_level_change(level)
	grid_height = (level - 1) * WorldConstants.LEVEL_HEIGHT
	grid_plane = Plane(Vector3(0,1,0), grid_height)

