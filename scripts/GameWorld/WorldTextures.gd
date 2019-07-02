extends Node

var tArray : TextureArray
var textures : Array

onready var aTexture_mat = load("res://res/materials/ArrayTexture.tres")

class LevelTexture:
	var name : String
	
	var img : Image
	var texScale : Vector2
	
	func _init(lname : String, lres : String, lscale : Vector2, tArray : TextureArray, layer : int):
		name = lname
		texScale = lscale
		
		img = Image.new()
		if (img.load(lres) != 0):
			push_warning("Warning: Could not load " + lres)
			return
		
		img.generate_mipmaps()
		tArray.set_layer_data(img, layer)

func loadTexturesToArray():
	textures.append(LevelTexture.new("Color", "res://res/txrs/color256.jpg", Vector2(2, 2), tArray, 0))
	textures.append(LevelTexture.new("Grass", "res://res/txrs/grass256.jpg", Vector2(1, 1), tArray, 1))
	textures.append(LevelTexture.new("Stucco", "res://res/txrs/stucco256.jpg", Vector2(1, 1), tArray, 2))
	textures.append(LevelTexture.new("Brick", "res://res/txrs/brick256.jpg", Vector2(2.5, 2.667), tArray, 3))
	textures.append(LevelTexture.new("Stone", "res://res/txrs/stone256.jpg", Vector2(1, 1), tArray, 4))

func _ready():
	tArray = TextureArray.new()
	
	tArray.create(256, 256, 5, Image.FORMAT_RGB8, 7)
	
	# Load images
	loadTexturesToArray()
	
	# Add texture array to the material
	aTexture_mat.set_shader_param("texture_array", tArray)
	