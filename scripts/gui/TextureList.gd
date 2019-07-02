extends ItemList

export(Texture) var texture

# Called when the node enters the scene tree for the first time.
func _ready():
	add_icon_item(texture)
	add_icon_item(texture)
	add_icon_item(texture)
	add_icon_item(texture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
