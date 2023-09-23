extends CanvasLayer

@onready var rect_obj = $Fade
@onready var tween_obj = $Fade/Tween

var faded = false
var fading = false

signal s_fade_complete
signal s_unfade_complete

func fade(duration):
	faded = true
	fading = true 
	
	rect_obj.set_visible(true)
	tween_obj.interpolate_property(rect_obj, "modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 
	  duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_obj.start()
	await tween_obj.tween_completed
	
	fading = false
	emit_signal("s_fade_complete")

func unfade(duration):
	faded = false
	fading = true 
	
	tween_obj.interpolate_property(rect_obj, "modulate", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 
	  duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween_obj.start()
	await tween_obj.tween_completed
	
	rect_obj.set_visible(false)
	fading = false
	emit_signal("s_unfade_complete")
