extends Control

func pickupJetpack():
	$Jetpack.visible = true

func toggleJetpack(on: bool):
	if on:
		$Jetpack/JetpackOn.text = "JetPack ON - Press 'F'"
	else:
		$Jetpack/JetpackOn.text = "JetPack OFF - Press 'F'"
