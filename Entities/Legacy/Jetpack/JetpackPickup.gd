extends Node3D

var expiring: bool = false
var unlimited_fuel: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Spin001")

func set_unlimited_fuel(unlimited: bool):
	unlimited_fuel = unlimited
	
	if unlimited_fuel:
		$Armature/Fire.visible = true
	else:
		$Armature/Fire.visible = false

func _on_Area_body_entered(body):
	if not expiring and body.has_meta("player") and body.busy == false:
		expiring = true
		if body.has_method("pickupJetpack"):
			var picked_up = body.pickupJetpack(unlimited_fuel)
			
			if picked_up:
				$PickupSFX.play()
				await $PickupSFX.finished
				self.queue_free()
