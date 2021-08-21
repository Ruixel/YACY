extends Spatial

onready var aTexture_mat = load("res://res/materials/ArrayTexture.tres") 

# TODO: Move to WorldTextures.gd & Preload once
var scarydoor_image = "res://res/txrs/scary_door.jpg"
var scifidoor_image = "res://res/txrs/scifi_door.jpg"
var colordoor_image = "res://res/txrs/color_door.jpg"

func load_texture(image):
	var stream_texture = load(image)
	var img = stream_texture.get_data()
	img.decompress()
	if (img.get_format() != Image.FORMAT_RGBA8):
		img.convert(Image.FORMAT_RGBA8)
		
	img.generate_mipmaps()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	
	return tex

func set_texture(texture_id: int):	
	var tex
	var scale = Vector2(2, 1)
	var transparent = false
	match texture_id:
		1: tex = load_texture(scarydoor_image)
		2: tex = load_texture(scifidoor_image)
		_: 
			var texture_info = WorldTextures.textures[WorldTextures.getDoorTexture(texture_id)]
			tex = texture_info.getImageTexture()
			scale = texture_info.getTextureScale()
			transparent = texture_info.isTransparent()
	
	var mat = $Door.mesh.surface_get_material(0).duplicate()
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(scale.x/2, scale.y , 1)
	mat.flags_transparent = transparent
	$Door.mesh.surface_set_material(0, mat)
	$Top.mesh.surface_set_material(0, mat)
	#$Door.set_surface_material(0, aTexture_mat)

func set_colour(colour: Color):
	var tex = load_texture(colordoor_image)
	
	var mat = $Door.mesh.surface_get_material(0).duplicate()
	mat.albedo_texture = tex
	mat.albedo_color = colour
	mat.uv1_scale = Vector3(2/2, 1 , 1)
	$Door.mesh.surface_set_material(0, mat)
	$Top.mesh.surface_set_material(0, mat)
	
#func _ready():
#	set_texture(2)
