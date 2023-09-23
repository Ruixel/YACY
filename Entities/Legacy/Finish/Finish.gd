extends Node3D

var enabled := true
var conditions = []

func set_condition(condition):
	if condition == 2:
		return
	
	await self.ready
	get_parent().get_parent().connect("all_collected", Callable(self, "on_condition_finished"))
	if condition == 1 or condition == 4:
		conditions.append("diamond")
	if condition == 3 or condition == 4:
		conditions.append("iceman")
	
	self.enabled = false
	$On.visible = true

func on_condition_finished(condition_name):
	if self.conditions.has(condition_name):
		self.conditions.erase(condition_name)
	
	if self.conditions.is_empty():
		enable_finish()

func enable_finish():
	self.enabled = true
	
	$On.mesh.surface_get_material(0).albedo_color = Color(0.0, 1.0, 0.0)
	$On.mesh.surface_get_material(0).emission = Color(0.0, 1.0, 0.0)
	
	$On/SpotLight3D.light_color = Color(0.0, 1.0, 0.0)

func _on_Area_body_entered(body):
	if body.has_meta("player") and self.enabled and body.busy == false:
		if body.has_method("finish_level"):
			var picked_up = body.finish_level()
