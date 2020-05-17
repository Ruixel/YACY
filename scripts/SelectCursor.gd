extends "CursorBase.gd"

onready var parent    = get_parent()
onready var camera    = get_node("../../EditorCamera/Camera")
onready var WorldAPI  = get_node("../../WorldInterface")

func cursor_process(delta: float, mouse_motion : Vector2) -> void:
	if parent.mouse_place_pressed:
		var ray_origin = camera.get_camera_transform().origin
		var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position()).normalized()
		
		WorldAPI.deselect()
		WorldAPI.select_obj_from_raycast(ray_origin, ray_direction)
	
	if Input.is_action_just_pressed("editor_delete"):
		WorldAPI.selection_delete()


