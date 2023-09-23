extends Node3D

@onready var parts = [$Meshes/Part1, $Meshes/Part2, $Meshes/Part3, $Meshes/Part4]
var parts_props = {}

func _ready():
	$DeadSFX.play()
	
	for part in parts:
		parts_props[part.name] = {}
		parts_props[part.name]["linear_speed"] = Vector3(randf() * 4.0 - 2.0, 7, randf() * 4.0 - 2.0)
		parts_props[part.name]["rotation_vec"] = Vector3(randf() * 4.0 - 2.0, randf() * 4.0 - 2.0, randf() * 4.0 - 2.0).normalized()
		parts_props[part.name]["angular_speed"] = 0.0


func _physics_process(delta):
	for part in parts:
		parts_props[part.name]["linear_speed"].y -= 18 * 0.6 * delta
		part.global_translate(parts_props[part.name]["linear_speed"] * delta)
		
		parts_props[part.name]["angular_speed"] += 0.07 * delta
		part.rotate(parts_props[part.name]["rotation_vec"], parts_props[part.name]["angular_speed"])
		part.global_scale(Vector3(1 - delta, 1 - delta, 1 - delta))


func _on_Timer_timeout():
	self.queue_free()
