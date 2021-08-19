extends Control

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
