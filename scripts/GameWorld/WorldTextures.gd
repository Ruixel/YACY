extends Node

var tArray : TextureArray
var textures : Array

const numberOfTextures : int = 16
const imgFormat = Image.FORMAT_RGBA8
enum TextureID {
	WCOLOR, GRASS, STUCCO, BRICK, STONE, WOOD, HAPPY, EGYPT, BARK, SCIFI, TILES, ROCK, PARQUET, BOOKSHELF, BAR, GLASS
}

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
		
		if (img.get_format() != imgFormat):
			img.convert(imgFormat)
		
		img.generate_mipmaps()
		tArray.set_layer_data(img, layer)

# Load textures in order the enumenation of TextureID
func loadTexturesToArray():
	textures.append(LevelTexture.new("Color", "res://res/txrs/color256.jpg", Vector2(2, 2), tArray, 0))
	textures.append(LevelTexture.new("Grass", "res://res/txrs/grass256.jpg", Vector2(1, 1), tArray, 1))
	textures.append(LevelTexture.new("Stucco", "res://res/txrs/stucco256.jpg", Vector2(1, 1), tArray, 2))
	textures.append(LevelTexture.new("Brick", "res://res/txrs/brick256.jpg", Vector2(2.5, 2.667), tArray, 3))
	textures.append(LevelTexture.new("Stone", "res://res/txrs/stone256.jpg", Vector2(1, 1), tArray, 4))
	textures.append(LevelTexture.new("Wood", "res://res/txrs/wood256.jpg", Vector2(1, 1), tArray, 5))
	textures.append(LevelTexture.new("Happy", "res://res/txrs/happy256.jpg", Vector2(4, 4), tArray, 6))
	textures.append(LevelTexture.new("Egypt", "res://res/txrs/egypt256.jpg", Vector2(1, 1), tArray, 7))
	textures.append(LevelTexture.new("Bark", "res://res/txrs/bark256.jpg", Vector2(1, 1), tArray, 8))
	textures.append(LevelTexture.new("Sci-Fi", "res://res/txrs/scifi256.jpg", Vector2(1, 1), tArray, 9))
	textures.append(LevelTexture.new("Tiles", "res://res/txrs/tile256.jpg", Vector2(4, 4), tArray, 10))
	textures.append(LevelTexture.new("Rock", "res://res/txrs/rock256.jpg", Vector2(1, 1), tArray, 11))
	textures.append(LevelTexture.new("Parquet", "res://res/txrs/parquet256.jpg", Vector2(1, 1), tArray, 12))
	textures.append(LevelTexture.new("Bookshelf", "res://res/txrs/bookshelf256.png", Vector2(1, 1.333), tArray, 13))
	
	# Transparent Textures
	textures.append(LevelTexture.new("Bars", "res://res/txrs/bars256.png", Vector2(3.5, 1), tArray, 14))
	textures.append(LevelTexture.new("Glass", "res://res/txrs/glass256.png", Vector2(1, 1), tArray, 15))

func _ready():
	tArray = TextureArray.new()
	
	tArray.create(256, 256, numberOfTextures, imgFormat, 7)
	
	# Load images
	loadTexturesToArray()
	
	# Add texture array to the material
	aTexture_mat.set_shader_param("texture_array", tArray)


func getWallTexture(id : int) -> LevelTexture:
	match id:
		1:  return TextureID.BRICK
		2:  return TextureID.BARS
		3:  return TextureID.STONE
		4:  return TextureID.GRASS
		5:  return TextureID.WOOD
		6:  return TextureID.HAPPY
		7:  return TextureID.EGYPT
		8:  return TextureID.GLASS
		9:  return TextureID.STUCCO
		10: return TextureID.BARK
		11: return TextureID.SCIFI
		12: return TextureID.TILES
		13: return TextureID.ROCK
		14: return TextureID.BOOKSHELF	
		16: return TextureID.PARQUET
		_:  return TextureID.WColor
