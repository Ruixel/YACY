extends Control

const distance = 200
const time = 0.25
const easing_method = Tween.TRANS_QUAD

var vp_container = preload("res://Scenes/UI/SelectedItem.tscn")

func _ready():
	change_item("res://Scenes/UI/Previews/Selected/ThickWall.tscn", "Wall")

func change_item(item_scene, item_name):
	var old_vp = get_node_or_null("SubViewportContainer")
	if old_vp != null:
		var old_tween = old_vp.get_node("Tween")
		old_tween.interpolate_property(old_vp, "position", old_vp.position, old_vp.position + Vector2(0, distance), time, easing_method, Tween.EASE_IN)
		old_tween.start()
		
		old_vp.name = "Removing"
		old_tween.connect("tween_completed", Callable(self, "destroy_item").bind(old_tween))
	
	var vp = vp_container.instantiate()
	
	var item = load(item_scene).instantiate()
	
	$ItemName.text = "[wave amp=30 freq=2] " + item_name + "[/wave]"
	
	vp.get_node("SubViewport").add_child(item)
	add_child(vp)
	move_child(vp, 3)
	vp.position = vp.position + Vector2(0, distance)
	
	#var tween = vp.get_node("Tween")
	#tween.interpolate_property(vp, "position", vp.position, vp.position + Vector2(0, -distance), time, easing_method, Tween.EASE_OUT)
	#tween.start()


func _on_Item_pressed(item_scene, item_name):
	change_item(item_scene, item_name)

func destroy_item(obj):
	obj.queue_free()
