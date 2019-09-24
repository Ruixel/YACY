extends Spatial

func _ready():
	var test = load("res://scripts/gdtest.gdns").new()
	
	print("hey", test)
	print(test.a_method())
	test.cat = 3
	print(test.cat, "lol")