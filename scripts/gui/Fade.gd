extends ColorRect

var faded = false
var fading = false

signal s_fade_complete
signal s_unfade_complete

func fade(duration):
	faded = true
	fading = true 
	
	self.set_visible(true)
	$Tween.interpolate_property(self, "modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 
	  duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	fading = false
	emit_signal("s_fade_complete")

func unfade(duration):
	faded = false
	fading = true 
	
	$Tween.interpolate_property(self, "modulate", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 
	  duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	self.set_visible(false)
	fading = false
	emit_signal("s_unfade_complete")
