extends "CursorBase.gd"

onready var parent    = get_parent()
onready var camera    = get_node("../../EditorCamera/Camera")
onready var WorldAPI  = get_node("../../WorldInterface")

onready var VertexBase = get_node("VertexBase")
var node_vertices = []
var vertices = []
var vertexChosen = null
var dragging = false

const Vector2i = preload('res://scripts/Vec2i.gd')
var grid_pos = Vector2i.new()

signal change_vertex

func cursor_ready():
	var selection = WorldAPI.get_selection()
	on_selection_change(selection)
	
	WorldAPI.connect("change_selection", self, "on_selection_change")
	self.connect("change_vertex", WorldAPI, "property_vertex")

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
		if dragging == false:
			var mouse_in_vertex = false
			for v in vertices:
				if grid_pos.x == v.x and grid_pos.y == v.y:
					mouse_in_vertex = true
					vertexChosen = [v, vertices.find(v)]
					Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
					break
					
			if mouse_in_vertex == false:
				mouse_in_vertex = null
				vertexChosen = null
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	if parent.mouse_place_just_pressed and vertexChosen != null:
		dragging = true
	
	if parent.mouse_place_pressed and dragging and mouse_motion and vertexChosen != null:
		var new_pos = Vector2(grid_pos.x, grid_pos.y)
		if vertexChosen[0].x != new_pos.x or vertexChosen[0].y != new_pos.y:
			vertexChosen[0] = Vector2(grid_pos.x, grid_pos.y)
			vertices[vertexChosen[1]] = Vector2(grid_pos.x, grid_pos.y)
			
			var height = (WorldAPI.level - 1) * WorldConstants.LEVEL_HEIGHT
			node_vertices[vertexChosen[1]].transform.origin = Vector3(grid_pos.x, height, grid_pos.y)
			emit_signal("change_vertex", vertexChosen)
	
	if Input.is_action_just_released("editor_place") and dragging:
		
		dragging = false
		vertexChosen = null
		parent.mouse_place_just_pressed = false

func on_selection_change(selection):
	# Clean up vertices
	cleanup()
	
	# Mark each 
	if selection != null and selection.toolType == WorldConstants.Tools.GROUND:
		for vertex in selection.vertices:
			vertices.append(vertex)
			
			var vertexNode = VertexBase.duplicate()
			self.add_child(vertexNode)
			vertexNode.set_visible(true)
			node_vertices.append(vertexNode)
			
			var v_x = vertex[0]
			var v_z = vertex[1]
			var height = (WorldAPI.level - 1) * WorldConstants.LEVEL_HEIGHT
			
			vertexNode.transform.origin = Vector3(v_x, height, v_z)

func cleanup():
	for v in node_vertices:
		v.queue_free()
	
	node_vertices.clear()
	vertices.clear()

func cursor_on_tool_change(newTool):
	cleanup()
	WorldAPI.disconnect("change_selection", self, "on_selection_change")
	WorldAPI.disconnect("change_vertex", WorldAPI, "property_vertex")
