extends Panel

onready var EditorGUI = get_parent()

signal s_changeTexture
signal s_changeColour
signal s_changeSize
signal s_changeWallShape
signal s_changeDiagonal

signal s_deleteObject
signal s_setDefault

const PropertyLabelEntity = preload("res://Entities/Editor/PropertyEditor/PropertyLabel.tscn")
const ColourPropertyEntity = preload("res://Entities/Editor/PropertyEditor/ColourProperty.tscn")
const NumericalPropertyEntity = preload("res://Entities/Editor/PropertyEditor/NumericalProperty.tscn")
const TexturePropertyEntity = preload("res://Entities/Editor/PropertyEditor/TextureProperty.tscn")
const WallShapePropertyEntity = preload("res://Entities/Editor/PropertyEditor/WallShapeProperty.tscn")
const BooleanPropertyEntity = preload("res://Entities/Editor/PropertyEditor/BooleanProperty.tscn")

var properties : Dictionary
var toolSelected = WorldConstants.Tools.NOTHING

const BasicProperty = {
	"ColourProperty": {"obj": ColourPropertyEntity, "use_label": false, "select_func": "set_colour"},
	"NumericalProperty": {"obj": NumericalPropertyEntity, "use_label": false, "select_func": "set_number"},
	"TextureProperty": {"obj": TexturePropertyEntity, "use_label": true, "select_func": "select_texture"},
	"WallShapeProperty": {"obj": WallShapePropertyEntity, "use_label": false, "select_func": "set_wallShape"},
	"BooleanProperty": {"obj": BooleanPropertyEntity, "use_label": false, "select_func": "set_bool"}
}

const Property = {
	"Size": {"type": BasicProperty.NumericalProperty, "init_func": "setup_sizeProperty", "min":1, "max":4},
	"PillarSize": {"type": BasicProperty.NumericalProperty, "init_func": "setup_sizeProperty", "min":1, "max":5},
	"Diagonal": {"type": BasicProperty.BooleanProperty, "init_func": "setup_boolProperty"},
	"Texture": {"type": BasicProperty.TextureProperty, "init_func": "setup_textureProperty"},
	"Colour": {"type": BasicProperty.ColourProperty, "init_func": "setup_colourProperty"},
	"WallShape": {"type": BasicProperty.WallShapeProperty, "init_func": "setup_wallShapeProperty"},
}

const ObjectProperties = { 
	WorldConstants.Tools.NOTHING: [],
	WorldConstants.Tools.WALL: ["WallShape", "Colour", "Texture"],
	WorldConstants.Tools.PLATFORM: ["Size", "Colour", "Texture"],
	WorldConstants.Tools.PILLAR: ["PillarSize", "Diagonal", "Colour", "Texture"]
}

# Connect to tool change signal
func _ready():
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")

func on_tool_change(nTool):
	# Clear the GUI
	reset()
	toolSelected = nTool
	
	if nTool == WorldConstants.Tools.NOTHING:
		set_visible(false)
	else:
		set_visible(true)
	
	# Set name of object
	$MarginContainer/Values/ObjectName.set_text(WorldConstants.ToolToString[nTool])
	
	# Where to add the next property
	var next_node = $MarginContainer/Values/ObjectName
	
	# Iterate through 
	var propArray = ObjectProperties.get(nTool)
	for propName in propArray:
		var propInfo = Property.get(propName)
		if propInfo == null:
			continue
		
		# Get the scene for the property
		var propBasic = propInfo.get("type")
		var propSceneObj = propBasic.get("obj")
		
		if propBasic.get("use_label"):
			var propLabel = PropertyLabelEntity.instance()
			propLabel.set_text(propName)
			
			$MarginContainer/Values.add_child_below_node(next_node, propLabel)
			next_node = propLabel
			properties[properties.size()] = propLabel
		
		var propScene = propSceneObj.instance()
		$MarginContainer/Values.add_child_below_node(next_node, propScene)
		next_node = propScene
		properties[propName] = propScene
		
		# Setup the property
		call(propInfo.get("init_func"), propScene, propInfo, propName)

func reset():
	for prop in properties.keys():
		properties.get(prop).queue_free()
	properties.clear()

func update_properties(dict : Dictionary, tType):
	if toolSelected != tType:
		on_tool_change(tType)
	
	for key in dict.keys():
		var property = Property.get(key)
		if property == null:
			continue
		
		var basicProperty = property.get("type")
		var selectNode = properties.get(key)
		if selectNode != null:
			var selectFunc = basicProperty.get("select_func")
			selectNode.call_deferred(selectFunc, dict.get(key))

func setup_sizeProperty(propScene, propInfo : Dictionary, propName : String):
	propScene.get_node("Label").set_text(propName)
	propScene.get_node("SpinBox").connect("value_changed", self, "on_change_size")
	
	var spinbox = propScene.get_node("SpinBox")
	spinbox.set_min(propInfo.get("min"))
	spinbox.set_max(propInfo.get("max"))

func setup_textureProperty(propScene, propInfo : Dictionary, propName : String):
	# propScene.get_node("TextureList").connect("s_wallTextureChange", self, "on_select_texture")
	propScene.connect("s_textureChange", self, "on_select_texture")

func setup_colourProperty(propScene, propInfo : Dictionary, propName : String):
	propScene.get_node("ColorPickerButton").connect("color_changed", self, "on_select_colour")

func setup_wallShapeProperty(propScene, propInfo : Dictionary, propName : String):
	propScene.connect("s_changeWallShape", self, "on_select_wallShape")

func setup_boolProperty(propScene, propInfo : Dictionary, propName : String):
	propScene.get_node("Label").set_text(propName)
	propScene.get_node("CheckBox").connect("toggled", self, "on_select_bool")

func on_change_size(size):
	emit_signal("s_changeSize", size)

func on_select_texture(texIndex):
	emit_signal("s_changeTexture", texIndex)

func on_select_wallShape(wallShape):
	emit_signal("s_changeWallShape", wallShape)

func on_select_colour(colour):
	emit_signal("s_changeColour", colour)
	emit_signal("s_changeTexture", WorldTextures.TextureID.COLOR) # Set the texture to colour

# To do: generalize this
func on_select_bool(value):
	emit_signal("s_changeDiagonal", value)

func set_properties(propList : Dictionary, nTool):
	var propArray = ObjectProperties.get(nTool)
	for propName in propArray:
		pass

func _on_DeleteButton_pressed():
	emit_signal("s_deleteObject")

func _on_DefaultButton_pressed():
	emit_signal("s_setDefault")