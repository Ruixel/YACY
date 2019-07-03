extends ItemList

var textures : Array

signal s_wallTextureChange

func loadTexturesAsItems():
	for item in WorldTextures.textures:
		var new_tex = ImageTexture.new()
		new_tex.create_from_image(item.img)
		
		add_item(item.name, new_tex)

# Called when the node enters the scene tree for the first time.
func _ready():
	loadTexturesAsItems()


func _on_TextureList_item_selected(index):
	emit_signal("s_wallTextureChange", index)
