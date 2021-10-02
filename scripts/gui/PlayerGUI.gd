extends Control

var max_diamonds = 0
var total_icemen = 0
var icemen = 0
var time = 0
var global_time = 0
onready var items_left_nodes = [$ItemsLeft/Diamonds, $ItemsLeft/Icemen]

func reset():
	# Shift back UI
	if $BR/Jetpack.visible:
		$BR/Ammo.rect_position.y += 50
	
	# Reset win screen
	var win_screen = get_node_or_null("WinScreen")
	if win_screen != null:
		win_screen.queue_free()
	
	if not $Clock/Timer.is_connected("timeout", self, "_on_Timer_timeout"):
		global_time -= time
		$Clock/Timer.connect("timeout", self, "_on_Timer_timeout")
	
	# Reset Player Stats/Items
	$BR/Jetpack.visible = false
	$BR/Ammo.visible = false
	$Items/Keys.visible = false
	max_diamonds = 0
	$ItemsLeft/Diamonds.visible = false
	$ItemsLeft/Icemen.visible = false
	updateJetpackFuel(0, 240)
	
	# Update ingame timer
	global_time += time
	time = 0
	var global_minutes = global_time / 60
	var global_seconds = global_time % 60
	$Clock/GlobalClock.visible = true
	$Clock/GlobalClock.bbcode_text = "[right]" + str("%02d" % global_minutes) + ":" + str("%02d" % global_seconds) + "[/right]"
	draw_clock()

func setupCollectables(collectables: Dictionary):
	for key in collectables:
		if key == "diamond":
			loadDiamonds(collectables[key])
		if key == "iceman":
			loadIcemen(collectables[key])
	updateItemsLeft()

func loadDiamonds(max_diamonds: int):
	if max_diamonds > 0:
		self.max_diamonds = max_diamonds
#		$ItemsLeft/Diamonds/Count.bbcode_text = "[b]0[/b] / " + str(max_diamonds)
		updateDiamonds(0)
		$ItemsLeft/Diamonds.visible = true

func updateDiamonds(diamonds: int):
	if diamonds == max_diamonds:
		$ItemsLeft/Diamonds/Count.bbcode_text = " [wave amp=20 freq=10][b]" + str(diamonds) + "[/b] / " + str(max_diamonds) + "[/wave]"
		$ItemsLeft/Diamonds/Panel.get_stylebox("panel").bg_color = Color(0.2, 1.0, 0.2, 0.24)
	else:
		$ItemsLeft/Diamonds/Count.bbcode_text = " [b]" + str(diamonds) + "[/b] / " + str(max_diamonds)
		$ItemsLeft/Diamonds/Panel.get_stylebox("panel").bg_color = Color(0.0, 0.0, 0.0, 0.24)
	
	var big_text_width = $ItemsLeft/Diamonds/Count.get_font("bold_font").get_string_size(str(diamonds))
	var small_text_width = $ItemsLeft/Diamonds/Count.get_font("normal_font").get_string_size("  / " + str(max_diamonds))
	$ItemsLeft/Diamonds/Panel.rect_size.x = big_text_width.x + small_text_width.x + 66

func loadIcemen(total_icemen: int):
	if total_icemen:
		self.total_icemen = total_icemen
		self.icemen = total_icemen
		
		self.icemen += 1
		killedIceman()
		
		$ItemsLeft/Icemen.visible = true

func killedIceman():
	self.icemen -= 1
	
	if self.icemen == 0:
		$ItemsLeft/Icemen/Count.bbcode_text = " [wave amp=20 freq=10][b]" + str(self.icemen) + "[/b]  left[/wave]"
		$ItemsLeft/Icemen/Panel.get_stylebox("panel").bg_color = Color(0.2, 1.0, 0.2, 0.24)
	else:
		$ItemsLeft/Icemen/Count.bbcode_text = " [b]" + str(self.icemen) + "[/b]  left"
		$ItemsLeft/Icemen/Panel.get_stylebox("panel").bg_color = Color(0.0, 0.0, 0.0, 0.24)
	
	var big_text_width = $ItemsLeft/Icemen/Count.get_font("bold_font").get_string_size(str(self.icemen))
	var small_text_width = $ItemsLeft/Icemen/Count.get_font("normal_font").get_string_size("   left")
	$ItemsLeft/Icemen/Panel.rect_size.x = big_text_width.x + small_text_width.x + 66

func updateItemsLeft():
	var y = 25
	for node in items_left_nodes:
		if node.visible:
			node.rect_position = Vector2(10, y)
			y += 60



func pickupJetpack():
	$BR/Jetpack.visible = true
	$BR/Ammo.rect_position.y -= 50

func toggleJetpack(on: bool):
	if on:
		$BR/Jetpack/JetpackOn.text = "JetPack ON - Press 'F'"
	else:
		$BR/Jetpack/JetpackOn.text = "JetPack OFF - Press 'F'"

func updateJetpackFuel(fuel_amount: float, max_fuel: float):
	$BR/Jetpack/Fuel.color = Color.from_hsv((fuel_amount / max_fuel) * 0.33, 0.9, 0.95, 0.5)
	$BR/Jetpack/Fuel.rect_scale = Vector2(fuel_amount / max_fuel, 1)

func updateCrumbs(ammo: int):
	$BR/Ammo/Count.bbcode_text = "[right][b]" + str(ammo) + "[/b] x[/right]"
	$BR/Ammo.visible = true

func updateKeys(keys: Array):
	# Show if user has collected any keys
	if keys.empty():
		$Items/Keys.visible = false
		return
	$Items/Keys.visible = true
	
	# Check if user has master key
	if WorldConstants.MASTER_KEY in keys:
		$Items/Keys/KeysCollected.text = "Key: Master"
	else:
		var key_string = "Keys: "
		if keys.size() == 1:
			key_string = "Key: "
			
		keys.sort()
		for key in keys:
			key_string = key_string + str(key) + ", "
		key_string = key_string.substr(0, key_string.length() - 2)
		$Items/Keys/KeysCollected.text = key_string

func freezeScreen(seconds: float):
	$FrozenScreen/Tween.stop_all()
	$FrozenScreen.visible = true
	$FrozenScreen.modulate = Color(1, 1, 1, 0.37)
	
	yield(get_tree().create_timer(seconds), "timeout") 
	$FrozenScreen/Tween.interpolate_property($FrozenScreen, "modulate", 
	  Color(1, 1, 1, 0.37), Color(1, 1, 1, 0), 1.0,Tween.TRANS_QUAD, Tween.EASE_OUT)
	$FrozenScreen/Tween.start()

# Clock UI
func draw_clock():
	var minutes = time / 60
	var seconds = time % 60
	
	$Clock.bbcode_text = "[center][b]" + str("%02d" % minutes) + ":" + str("%02d" % seconds) + "[/b][/center]"

func _on_Timer_timeout():
	time += 1
	draw_clock()

func time_save(seconds: int):
	time -= seconds
	if time < 0:
		time = 0
	
	draw_clock()

func display_level_finish():
	if $Clock/Timer.is_connected("timeout", self, "_on_Timer_timeout"):
		$Clock/Timer.disconnect("timeout", self, "_on_Timer_timeout")
		
	var finish_ui = load("res://Scenes/UI/WinScreen.tscn").instance()
	add_child(finish_ui)
