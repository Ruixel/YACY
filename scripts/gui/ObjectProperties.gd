extends Panel

signal s_changeTexture
signal s_changeColor

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VSplitContainer/Texture/TexContainer/TextureList.connect("s_wallTextureChange", self, "on_select_texture")

func on_select_texture(texIndex):
	print("hey", texIndex)
	emit_signal("s_changeTexture", texIndex)

func _on_ColorPickerButton_color_changed(color):
	emit_signal("s_changeColor", color)
