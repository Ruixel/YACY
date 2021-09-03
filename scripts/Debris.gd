extends Particles

var play_sfx := true

func _ready():
	self.emitting = true
	if play_sfx:
		$HitSFX.play()

func _on_Timer_timeout():
	self.queue_free()
