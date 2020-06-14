extends Spatial
const toolType = WorldConstants.Tools.HOLE

const canPlace = true
const onePerLevel = false
const hasDefaultObject = true

var pos : Vector2
var level : int

var size : int = 1
const size_list = [2, 4, 8, 16]
const size_offset = 0.05

var platShape = WorldConstants.PlatShape.QUAD

var mesh : MeshInstance
var selection_mesh : MeshInstance
var collision_mesh : StaticBody
var collision_shape : CollisionShape

func _init(position : Vector2, lvl : int):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	pos = position
	level = lvl 
	
	HoleManager.add_hole(self, lvl)
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)
	

# Destructor
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		HoleManager.remove_hole(self, level)

func get_level():
	return level

func change_size(newSize : int):
	var oldSize = size
	size = newSize
	
	# Check new size is valid
	var ground = HoleManager.get_ground(level)
	if ground != null:
		if not is_valid(ground):
			size = oldSize
	
	HoleManager.update_ground_mesh(level)

# No actual visible mesh, but still needs one for selecting
func _genMesh():
	var holeMesh = buildPlatform(pos, level, 0, 0, Color(0,0,0), size, platShape, false)
	collision_shape.shape = holeMesh.create_convex_shape()

func genPrototypeMesh(pLevel : int) -> Mesh:
	return buildPlatform(Vector2(0,0), pLevel, 0, 0, Color(0,0,0), size, platShape, true)

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = buildPlatSelectionMesh(pos, level, size, 0, 0.05)

func get_property_dict() -> Dictionary:
	var dict : Dictionary = {}
	dict["Size"] = size

	return dict

const dictToObj = {
	"Size":"size"
}

func set_property_dict(dict : Dictionary):
	for prop in dictToObj:
		set(dictToObj[prop], dict[prop])

func is_valid(ground):
	# Get vertices of the holes
	var halfSize = size_list[size-1] / 2
	var start = Vector2(pos.x - halfSize, pos.y - halfSize)
	var end   = Vector2(pos.x + halfSize, pos.y + halfSize)
	
	# Put vertices into array
	var vertices = []
	vertices.insert(0, Vector2(start.x, start.y))
	vertices.insert(1, Vector2(end.x,   start.y))
	vertices.insert(2, Vector2(end.x,   end.y))
	vertices.insert(3, Vector2(start.x, end.y))
	
	# Iterate through each point 
	var verts = ground.vertices
	for p in vertices:
		var i = 0
		var j = 3
		var c = false
		for i in range(0, 4):
			if (((verts[i].y >= p.y) != (verts[j].y >= p.y)) && 
				(p.x <= (verts[j].x - verts[i].x) * (p.y - verts[i].y) / (verts[j].y - verts[i].y) + verts[i].x)):
				c = not c
			
			j = i
		
		if c == false:
			return false
	
	# Now check that there are no other colliding holes
	for hole in HoleManager.get_holes(level):
		if hole == self: 
			continue
			
		var halfSize2 = size_list[hole.size-1] / 2
		var start2 = Vector2(hole.pos.x - halfSize2, hole.pos.y - halfSize2)
		var end2   = Vector2(hole.pos.x + halfSize2, hole.pos.y + halfSize2)

		if (start.x < end2.x && end.x > start2.x && start.y < end2.y && end.y > start2.y):
			return false
	 
	return true

const quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
static func _createPlatQuadMesh(surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int, 
	tex : int, colour : Color) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (wall_vertices[2] - wall_vertices[1]).cross(wall_vertices[3] - wall_vertices[1]).normalized()
	
	var texture_float = (tex+1.0)/256
	var texture_scale = WorldTextures.textures[tex].texScale
	
	# Add Vertices
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[0].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[0].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[0])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[3].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[3].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[3])

	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[2].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[2].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[2])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[1].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[1].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[1])
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

func get_vertices() -> PoolVector2Array:
	var halfSize = (size_list[size-1] / 2) - size_offset
	
	var start = Vector2(pos.x - halfSize, pos.y - halfSize)
	var end   = Vector2(pos.x + halfSize, pos.y + halfSize)
	
	var hole_vertices : PoolVector2Array
	hole_vertices.insert(0, Vector2(start.x, start.y))
	hole_vertices.insert(1, Vector2(end.x,   start.y))
	hole_vertices.insert(2, Vector2(end.x,   end.y))
	hole_vertices.insert(3, Vector2(start.x, end.y))
	
	return hole_vertices

static func buildPlatform(pos : Vector2, level : int, height_offset : float, tex : int, colour : Color,
	size : int, pShape, is_prototype : bool) -> Mesh:
		
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = (level - 1 + height_offset + 0.003) * WorldConstants.LEVEL_HEIGHT
	
	var halfSize = size_list[size-1] / 2
	var start = Vector2(pos.x - halfSize, pos.y - halfSize)
	var end   = Vector2(pos.x + halfSize, pos.y + halfSize)
	
	# Set colour to white if not using the colour wall
	var meshColor = colour
	if tex != WorldTextures.TextureID.COLOR:
		meshColor = Color(1,1,1)
	
	# Calculate wall vertices
	var plat_vertices = []
	plat_vertices.insert(0, Vector3(start.x, height, start.y))
	plat_vertices.insert(1, Vector3(end.x,   height, start.y))
	plat_vertices.insert(2, Vector3(end.x,   height, end.y))
	plat_vertices.insert(3, Vector3(start.x, height, end.y))
	
	if pShape == WorldConstants.PlatShape.QUAD or pShape == WorldConstants.PlatShape.DIAMOND:
		_createPlatQuadMesh(surface_tool, plat_vertices, 0, tex, meshColor)
		
		# Rearrange vertices for the backwall
		var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
		_createPlatQuadMesh(surface_tool, bVertices, 4, tex, meshColor)
		
	if is_prototype:
		surface_tool.set_material(WorldTextures.aTexturePrototype_mat)
	else: 
		surface_tool.set_material(WorldTextures.getWallMaterial(tex))
	
	return surface_tool.commit()

static func buildPlatSelectionMesh(pos : Vector2, level : int, size : int, height_offset : float, outlineWidth : float) -> Mesh:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = (level - 1 + height_offset + 0.003) * WorldConstants.LEVEL_HEIGHT
	
	var halfSize = size_list[size-1] / 2
	var start = Vector2(pos.x - halfSize - outlineWidth, pos.y - halfSize - outlineWidth)
	var end   = Vector2(pos.x + halfSize + outlineWidth, pos.y + halfSize + outlineWidth)
	
	# Calculate wall vertices
	var plat_vertices = []
	plat_vertices.insert(0, Vector3(start.x, height, start.y))
	plat_vertices.insert(1, Vector3(end.x,   height, start.y))
	plat_vertices.insert(2, Vector3(end.x,   height, end.y))
	plat_vertices.insert(3, Vector3(start.x, height, end.y))
	for i in range(0, 4):
		plat_vertices[i].y = plat_vertices[i].y + 0.035
	_createPlatQuadMesh(surface_tool, plat_vertices, 0, 0, Color(1,1,1))
	
	# Rearrange vertices for the backwall
	var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
	for i in range(0, 4):
		bVertices[i].y = bVertices[i].y - (0.02 * 2)
	_createPlatQuadMesh(surface_tool, bVertices, 4, 0, Color(1,1,1))
	
	surface_tool.set_material(WorldTextures.selection_mat)
	
	return surface_tool.commit()

func JSON_serialise(default_dict) -> Dictionary:
	# Only add values that differ from the default
	var dict = get_property_dict()
	for k in dict.keys():
		if dict[k] == default_dict[k]:
			dict.erase(k)
	
	# Add unique variables
	dict["Lvl"] = level
	dict["Pos"] = pos
	
	return dict

func JSON_deserialise(dict):
	for k in dict.keys():
		if dictToObj.has(k):
			var property = self.get(dictToObj.get(k)) 
			self.set(dictToObj.get(k), Utils.json2obj(dict[k], property))
