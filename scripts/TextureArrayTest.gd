extends MeshInstance

var tArray : TextureArray

var img1 : Image
var img2 : Image
var img3 : Image

func _ready():
	tArray = TextureArray.new()
	tArray.create(256, 256, 3, Image.FORMAT_RGB8)
	
	# Load images
	img1 = Image.new()
	print(img1.load('res://res/txrs/stone256.jpg'))
	
	img2 = Image.new()
	print(img2.load('res://res/txrs/rock256.jpg'))
	
	img3 = Image.new()
	print(img3.load('res://res/txrs/stucco256.jpg'))
	
	tArray.set_layer_data(img1, 0)
	tArray.set_layer_data(img2, 1)
	tArray.set_layer_data(img3, 2)
	
	# Set object's texture array
	get_mesh().surface_get_material(0).set_shader_param("texture_array", tArray)
