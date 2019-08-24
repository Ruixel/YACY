extends Panel

onready var EditorGUI = get_parent()

signal s_changeTexture
signal s_changeColor

const PropertyLabelEntity = preload("res://Entities/Editor/PropertyEditor/PropertyLabel.tscn")
const ColourPropertyEntity = preload("res://Entities/Editor/PropertyEditor/ColourProperty.tscn")
const NumericalPropertyEntity = preload("res://Entities/Editor/PropertyEditor/NumericalProperty.tscn")
const TexturePropertyEntity = preload("res://Entities/Editor/PropertyEditor/TextureProperty.tscn")

var properties : Dictionary
var toolSelected = WorldConstants.Tools.NOTHING

const BasicProperty = {
	"ColourProperty": {"obj": ColourPropertyEntity, "use_label": false,  "init_func": "setup_colourProperty"},
	"NumericalProperty": {"obj": NumericalPropertyEntity, "use_label": false, "init_func": "setup_numericalProperty"},
	"TextureProperty": {"obj": TexturePropertyEntity, "use_label": true, "init_func": "setup_textureProperty", "select_func": "select_texture"}
}

const Property = {
	"Size": {"type": BasicProperty.NumericalProperty, "min":1, "max":4},
	"Texture": {"type": BasicProperty.TextureProperty},
	"Colour": {"type": BasicProperty.ColourProperty}
}

const ObjectProperties = { 
	WorldConstants.Tools.NOTHING: [],
	WorldConstants.Tools.WALL: ["Colour", "Texture"],
	WorldConstants.Tools.PLATFORM: ["Size", "Colour", "Texture"]
}

# Connect to tool change signal
func _ready():
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")

func on_tool_change(nTool):
	# Clear the GUI
	reset()
	toolSelected = nTool
	
	# Where to add the next property
	var next_node = $MarginContainer/VSplitContainer/Values/ObjectName
	
	# Iterate through 
	var propArray = ObjectProperties.get(nTool)
	for propName in propArray:
		var propInfo = Property.get(propName)
		
		# Get the scene for the property
		var propBasic = propInfo.get("type")
		var propSceneObj = propBasic.get("obj")
		
		if propBasic.get("use_label"):
			var propLabel = PropertyLabelEntity.instance()
			propLabel.set_text(propName)
			
			$MarginContainer/VSplitContainer/Values.add_child_below_node(next_node, propLabel)
			next_node = propLabel
			properties[properties.size()] = propLabel
		
		var propScene = propSceneObj.instance()
		$MarginContainer/VSplitContainer/Values.add_child_below_node(next_node, propScene)
		next_node = propScene
		properties[propName] = propScene
		
		# Setup the property
		call(propBasic.get("init_func"), propScene, propInfo, propName)

func reset():
	for prop in properties.keys():
		properties.get(prop).queue_free()
	properties.clear()

func setup_numericalProperty(propScene, propInfo : Dictionary, propName : String):
	propScene.get_node("Label").set_text(propName)
	
	var spinbox = propScene.get_node("SpinBox")
	spinbox.set_min(propInfo.get("min"))
	spinbox.set_max(propInfo.get("max"))

func update_properties(dict : Dictionary, tType):
	if toolSelected != tType:
		on_tool_change(tType)
	
	for key in dict.keys():
		var property = Property.get(key)
		var basicProperty = property.get("type")
		
		# var selectNode = properties.get(key).get_node(basicProperty.get("select_node"))
		var selectNode = properties.get(key)
		if selectNode != null:
			var selectFunc = basicProperty.get("select_func")
			selectNode.call_deferred(selectFunc, dict.get(key))

func setup_textureProperty(propScene, propInfo : Dictionary, propName : String):
	# propScene.get_node("TextureList").connect("s_wallTextureChange", self, "on_select_texture")
	propScene.connect("s_wallTextureChange", self, "on_select_texture")

func setup_colourProperty(propScene, propInfo : Dictionary, propName : String):
	pass

func on_select_texture(texIndex):
	print("hey", texIndex)
	emit_signal("s_changeTexture", texIndex)

func _on_ColorPickerButton_color_changed(color):
	emit_signal("s_changeColor", color)

func set_properties(propList : Dictionary, nTool):
	var propArray = ObjectProperties.get(nTool)
	for propName in propArray:
		pass