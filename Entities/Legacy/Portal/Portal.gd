extends Spatial

var gameNumber : int = -1
var conditions = []

var enabled = true

func set_gameNumber(id : int):
	gameNumber = id

func set_condition(condition):
	if condition == 2:
		return
	
	yield(self, "ready")
	get_parent().get_parent().connect("all_collected", self, "on_condition_finished")
	if condition == 1 or condition == 4:
		conditions.append("diamond")
	if condition == 3 or condition == 4:
		conditions.append("iceman")
	
	self.enabled = false
	
	match condition:
		1: $Condition.mesh.surface_get_material(0).albedo_texture = load("res://Entities/Legacy/Portal/DiamondCondition.png")
		3: $Condition.mesh.surface_get_material(0).albedo_texture = load("res://Entities/Legacy/Portal/IcemanCondition.png")
		4: $Condition.mesh.surface_get_material(0).albedo_texture = load("res://Entities/Legacy/Portal/DiamondAndIcemanCondition.png")
			
	$Condition.visible = true
	
	$Viewport/FrontTexture.texture = load("res://Entities/Legacy/Portal/portal_blocked.png")
	$AnimationPlayer.play("Spin")

func enable_portal():
	self.enabled = true
	
	$Viewport/FrontTexture.texture = load("res://Entities/Legacy/Portal/portal.png")
	$Condition.visible = false
	$AnimationPlayer.stop()

func on_condition_finished(condition_name):
	print("Condition completed: ", condition_name)
	if self.conditions.has(condition_name):
		self.conditions.erase(condition_name)
	
	if self.conditions.empty():
		enable_portal()

func _on_Area_body_entered(body):
	if body.has_meta("player") and enabled and gameNumber != -1 and body.busy == false:
		body.busy = true
		body.pause = true
		var fade = get_node("/root/Main/Fade")
		fade.fade(0.3)
		yield(fade, "s_fade_complete")
		
		get_node("/root/Gameplay/LegacyLevel").clear_level()
		get_node("/root/Gameplay/LegacyLevel").load_level(gameNumber)
