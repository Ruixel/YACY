extends Control

var max_diamonds = 0

func reset():
	$Jetpack.visible = false
	$Items/Keys.visible = false
	max_diamonds = 0
	$ItemsLeft/Diamonds.visible = false
	updateJetpackFuel(0, 240)

func setupCollectables(collectables: Dictionary):
	for key in collectables:
		if key == "diamond":
			loadDiamonds(collectables[key])

func loadDiamonds(max_diamonds: int):
	if max_diamonds > 0:
		self.max_diamonds = max_diamonds
		$ItemsLeft/Diamonds/Count.bbcode_text = "[b]0[/b] / " + str(max_diamonds)
		$ItemsLeft/Diamonds.visible = true

func updateDiamonds(diamonds: int):
	if diamonds == max_diamonds:
		$ItemsLeft/Diamonds/Count.bbcode_text = "[wave amp=20 freq=10][b]" + str(diamonds) + "[/b] / " + str(max_diamonds) + "[/wave]"
	else:
		$ItemsLeft/Diamonds/Count.bbcode_text = "[b]" + str(diamonds) + "[/b] / " + str(max_diamonds)

func pickupJetpack():
	$Jetpack.visible = true

func toggleJetpack(on: bool):
	if on:
		$Jetpack/JetpackOn.text = "JetPack ON - Press 'F'"
	else:
		$Jetpack/JetpackOn.text = "JetPack OFF - Press 'F'"

func updateJetpackFuel(fuel_amount: float, max_fuel: float):
	$Jetpack/Fuel.color = Color.from_hsv((fuel_amount / max_fuel) * 0.33, 0.9, 0.95, 0.5)
	$Jetpack/Fuel.rect_scale = Vector2(fuel_amount / max_fuel, 1)

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
