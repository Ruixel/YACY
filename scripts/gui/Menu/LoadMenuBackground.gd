extends Spatial

var bg : Object
var rng = RandomNumberGenerator.new()

onready var gui = get_node("Control")
onready var levelbrowserGui = get_node("Control/ScrollContainer/GridContainer")

# Backgrounds w/ level file & camera transformation
const backgrounds = [
	["res://res/levels/Panda.cy", "Transform( 0.82851, -0.0972383, 0.551467, 0, 0.984808, 0.173648, -0.559974, -0.143869, 0.815923, 54.2401, 39.5815, 50.2789 )"],
	["res://res/levels/Panda.cy", "Transform( 0.82535, 0.146135, 0.545382, 0, 0.965926, -0.258819, -0.564621, 0.213616, 0.797227, 53.237, 20.4208, 48.9841 )"],
	["res://res/levels/Panda.cy", "Transform( 0.82535, 0, -0.564621, 0.146135, 0.965926, 0.213616, 0.545382, -0.258819, 0.797227, 53.237, 20.4208, 48.9841 )"],
	["res://res/levels/Puppy.cy", "Transform( 0.93883, -0.059801, 0.339149, 0, 0.984808, 0.173648, -0.344381, -0.163026, 0.924567, 44.0378, 35.5545, 98.8361 )"],
#	["res://res/levels/Puppy.cy", "Transform( 0.939693, 0, 0.34202, 0, 1, 0, -0.34202, 0, 0.939693, 26.838, 10.8048, 49.8793 )"],
	["res://res/levels/Valynstad.cy", "Transform( 0.93883, -0.059801, 0.339149, 0.0164147, 0.991459, 0.129382, -0.34399, -0.1159, 0.931793, 46.1542, 17.2862, 87.5619 )"],
	["res://res/levels/Ashoto District.cy", "Transform( 0.642788, 0, -0.766044, 0, 1, 0, 0.766044, 0, 0.642788, 14.0285, 30.0218, 48.5584 )"],
#	["res://res/levels/Airlands.cy", "Transform( 0.642788, 0, -0.766044, 0, 1, 0, 0.766044, 0, 0.642788, 34.9632, 28.405, 53.8238)" ],
#	["res://res/levels/Airlands.cy", "Transform( -0.834954, -0.0955621, 0.54196, 0, 0.984808, 0.173648, -0.55032, 0.144988, -0.822269, 23.482, 22, 40.481 )"],
	["res://res/levels/Castle.cy", "Transform( -0.866026, -0.0868241, -0.492404, 0, 0.984808, -0.173648, 0.5, -0.150384, -0.852869, 40, 0.995, 10 )"],
	["res://res/levels/Castle.cy", "Transform( -0.866026, -0.321394, -0.383022, 0, 0.766044, -0.642788, 0.5, -0.55667, -0.663414, 41.4028, 1.54786, 49.7476 )"],
	["res://res/levels/Rock Wall.cy", "Transform( 1, 0, 0, 0, 0.5, -0.866025, 0, 0.866025, 0.5, 40.507, 15, 72.527 )"],
	["res://res/levels/Festive.cy", "Transform( 0.939693, 0, -0.34202, 0, 1, 0, 0.34202, 0, 0.939693, 15.9574, 11.7889, 69.7664 )"],
	["res://res/levels/Seattle.cy", "Transform( 0.939693, 0, -0.34202, 0, 1, 0, 0.34202, 0, 0.939693, 3.62938, 26.6117, 90.6639 )"]
]

func _ready():
	rng.randomize()
	load_background()

func load_menu():
	gui.visible = true
	levelbrowserGui.active = true
	load_background()

func load_background(bg_id = -1):
	var bg_scene = load("res://Scenes/Menu/Background.tscn")
	bg = bg_scene.instance()
	add_child(bg)
	
	if bg_id == -1:
		bg_id = rng.randi_range(0, backgrounds.size() - 1)
	
	print(bg_id)
	bg.get_node("LegacyWorldLoader").loadLevelFromFilesystem(backgrounds[bg_id][0])
	bg.get_node("BGCamera").transform = str2var(backgrounds[bg_id][1])
	#print("(" + var2str(bg.get_node("BGCamera").transform.basis) + "," + var2str(bg.get_node("NightCamera").transform.origin) + ")")
	#print(var2str(bg.get_node("BGCamera").transform))

func unload_background():
	if bg != null:
		bg.queue_free()
