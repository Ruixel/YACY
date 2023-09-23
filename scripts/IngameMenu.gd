extends Control

@onready var menu = get_node("/root/Main")
@onready var fade = get_node("/root/Main/Fade")

const month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

var busy = false
var paused = false
var description = ""
var conditions = [[WorldConstants.Objectives.NONE, "None, feel free to explore around", false]]

const CONDITION_TYPE = 0
const CONDITION_STRING = 1
const CONDITION_COMPLETED = 2

@export var can_pause = true

signal pause
signal unpause

signal change_music_volume

func _ready():
	get_parent().connect("get_level_info", Callable(self, "set_level_info"))
	get_parent().connect("s_levelLoaded", Callable(self, "unpause"))
	get_parent().connect("get_finish_conditions", Callable(self, "set_level_conditions"))
	get_parent().connect("all_collected", Callable(self, "on_player_all_collected"))
	
	var volume = PlayerSettings.music_volume
	$MusicVolume/HSlider.value = volume
	call_deferred("_on_volume_changed", volume, false)

func exit_level():
	busy = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	PlayerSettings.save_settings()
	
	fade.fade(0.5)
	await fade.s_fade_complete
	
	# Wait a tiny bit more time for fade to fully complete
	await get_tree().create_timer(0.1).timeout 
	
	menu.load_menu()
	get_tree().paused = false
	
	fade.unfade(0.5)
	get_node("../..").queue_free()

func _input(event):
	if event.is_action_pressed("pause") and not busy and can_pause:
		paused = not paused
		visible = paused
		get_tree().paused = paused
		
		if paused:
			emit_signal("pause")
		else:
			$MenuButtons.call("reset")
			emit_signal("unpause")
		#exit_level()

func set_level_info(info):
	$Title.text = info.title
	$Author.text = "By " + info.author
	
	self.description = info.description
	update_description_and_conditions()
	
	# Gonna be a while until any game reaches 1 million plays lol
	var plays = int(info.plays)
	if plays >= 1000:
		$Stats/Plays.text = str(floor(plays / 1000)) + "," + str("%03d" % (int(plays) % 1000))
	else:
		$Stats/Plays.text = str(plays)
	
	# Server returns datetime in milliseconds, however unix uses seconds
	var date = Time.get_datetime_dict_from_system_from_unix_time(int(info.lastEdited) / 1000)
	$Stats/Date.text = str(date.day) + " " + month_names[date.month-1] + " " + str(date.year)
	
	# Rating is done in 5 stars, switch to like ratio out of lazyness
	if info.numRating > 0:
		var like_ratio = (info.totalRating / (info.numRating * 5)) * 100
		$Stats/LikeRatio.text = "%d%%" % like_ratio
	else:
		$Stats/LikeRatio.text = "--"
	
	# Highscore
	if info.highscore != null:
		var time = info.highscore.time as int
		var minutes = time / 60
		var seconds = time % 60
		
		$Stats/Record.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)
		$Stats/RecordHolder.text = "By " + info.highscore.nickname
	else:
		$Stats/Record.text = "-- : --"
		$Stats/RecordHolder.text = "By Noone"

func unpause():
	paused = false
	visible = paused
	get_tree().paused = paused
	
	emit_signal("unpause")
	$MenuButtons.call("_on_Continue_mouse_exited")

func _on_volume_changed(value, allow_play = true):
	PlayerSettings.music_volume = value
	emit_signal("change_music_volume", value, allow_play)

func _on_Exit_pressed():
	exit_level()

func _on_Restart_pressed():
	get_parent().restart_level()
	get_tree().paused = false

func _on_Continue_pressed():
	unpause()

func set_level_conditions(conditions):
	self.conditions = []
	for condition in conditions:
		match condition[0]:
			WorldConstants.Objectives.DIAMONDS: 
				self.conditions.append([condition[0], "Collect all diamonds", condition[1]])
			WorldConstants.Objectives.ICEMEN: 
				self.conditions.append([condition[0], "Destroy all the icemen", condition[1]])
			WorldConstants.Objectives.FINISH: 
				self.conditions.append([condition[0], "Reach the finish", condition[1]])
			WorldConstants.Objectives.PORTAL: 
				self.conditions.append([condition[0], "There are portals that lead to other levels", condition[1]])
	
	if self.conditions.is_empty():
		self.conditions.append([WorldConstants.Objectives.NONE, "None, feel free to explore around", false])
	
	update_description_and_conditions()

func update_description_and_conditions():
	var desc_and_obj = description
	desc_and_obj += "\n\nObjectives:\n"
	
	for condition in self.conditions:
		if condition[CONDITION_COMPLETED]:
			desc_and_obj += "[color=#22FF22] - " + condition[CONDITION_STRING] + "[/color]\n"
		else: 
			desc_and_obj += " - " + condition[CONDITION_STRING] + "\n"
	
	$Description.text = desc_and_obj

func on_player_all_collected(name: String):
	if name == "diamond":
		finish_objective(WorldConstants.Objectives.DIAMONDS)
	elif name == "iceman":
		finish_objective(WorldConstants.Objectives.ICEMEN)

func finish_objective(objective_type):
	for condition in self.conditions:
		if condition[CONDITION_TYPE] == objective_type:
			condition[CONDITION_COMPLETED] = true
	
	update_description_and_conditions()
