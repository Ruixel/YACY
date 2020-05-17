extends "CursorBase.gd"

onready var parent    = get_parent()
onready var camera    = get_node("../../EditorCamera/Camera")
onready var WorldAPI  = get_node("../../WorldInterface")

onready var VertexBase = get_node("VertexBase")
var node_vertices = []

func cursor_ready():
	var selection = WorldAPI.get_selection()
	on_selection_change(selection)
	
	WorldAPI.connect("change_selection", self, "on_selection_change")

func on_selection_change(selection):
	print("sup", randi())
	# Clean up vertices
	cleanup()
	
	# Mark each 
	if selection != null and selection.toolType == WorldConstants.Tools.GROUND:
		for vertex in selection.vertices:
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

func cursor_on_tool_change(newTool):
	cleanup()
	WorldAPI.disconnect("change_selection", self, "on_selection_change")
