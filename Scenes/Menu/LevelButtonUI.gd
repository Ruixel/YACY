extends TextureButton

@onready var tween = $Tween
@onready var ctween = $Shine/Tween
var normal_pos
var got_normal_pos = false
var gameNumber
var mazeFile

func _on_Level_mouse_entered():
	if not got_normal_pos:
		normal_pos = self.position
		got_normal_pos = true
	
	# Shift button up
	var shifted_pos = normal_pos + Vector2(0, -5)
	tween.interpolate_property(self, "position", normal_pos, shifted_pos, 
	  0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	
	# Highlight button
	ctween.interpolate_property($Shine, "color", $Shine.color, Color(1,1,1,0.1),
	  0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	ctween.start()
	
	$Hover.play()


func _on_Level_mouse_exited():
	# Shift back 
	tween.interpolate_property(self, "position", self.position, normal_pos, 
	  0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	
	# Remove highlight
	ctween.interpolate_property($Shine, "color", $Shine.color, Color(1,1,1,0),
	  0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	ctween.start()

# Show user object has been clicked
func _on_Level_button_down():
	ctween.stop_all()
	$Shine.color = Color(0, 0, 0, 0.2)
	
	$Click.play()

func _on_Level_button_up():
	ctween.stop_all()
	$Shine.color = Color(1, 1, 1, 0.1)

func setGameNumber(num):
	gameNumber = num

func setMazeFile(filePath):
	mazeFile = filePath

