extends Control

onready var menu = get_node("/root/Main")
onready var fade = get_node("/root/Main/Fade")

const month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

var busy = false
var paused = false

export var can_pause = true

signal pause
signal unpause

signal change_music_volume

func _ready():
	get_parent().connect("get_level_info", self, "set_level_info")
	
	call_deferred("_on_volume_changed", 75.0, false)

func exit_level():
	busy = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	fade.fade(0.5)
	yield(fade, "s_fade_complete")
	
	menu.load_menu()
	
	fade.unfade(0.5)
	get_node("..").queue_free()

func _input(event):
	if event.is_action_pressed("pause") and not busy:
		paused = not paused
		visible = paused
		get_tree().paused = paused
		
		if paused:
			emit_signal("pause")
		else:
			emit_signal("unpause")
		#exit_level()

func set_level_info(info):
	$Title.text = info.title
	$Author.text = "By " + info.author
	$Description.text = info.description
	
	# Gonna be a while until any game reaches 1 million plays lol
	var plays = int(info.plays)
	if plays >= 1000:
		$Stats/Plays.text = str(floor(plays / 1000)) + "," + str(int(plays) % 1000)
	else:
		$Stats/Plays.text = str(plays)
	
	# Server returns datetime in milliseconds, however unix uses seconds
	var date = OS.get_datetime_from_unix_time(int(info.lastEdited) / 1000)
	$Stats/Date.text = str(date.day) + " " + month_names[date.month-1] + " " + str(date.year)
	
	# Rating is done in 5 stars, switch to like ratio out of lazyness
	if info.numRating > 0:
		var like_ratio = (info.totalRating / (info.numRating * 5)) * 100
		$Stats/LikeRatio.text = "%d%%" % like_ratio
	else:
		$Stats/LikeRatio.text = "--"

func _on_volume_changed(value):
	emit_signal("change_music_volume", value)
