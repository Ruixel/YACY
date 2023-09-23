extends Control

var debounce := false
var time = null
var world_record = -1

var can_submit = true

func _ready():
	$VBoxContainer/NameDetails/Name.text = PlayerSettings.player_name
	
	var level_manager = get_node_or_null("../../../../LegacyLevel/GameManager")
	world_record = -1
	if level_manager != null:
		if (level_manager.level_info.highscore != null):
			world_record = level_manager.level_info.highscore.time

func set_time(time):
	var minutes = time / 60
	var seconds = time % 60
	self.time = time
	
	if world_record == -1 or time < world_record:
		$VBoxContainer/Time.text = "[center][b]" + str("%02d" % minutes) + ":" + str("%02d" % seconds) + "[/b]         You got the world record![/center]"
	elif time == world_record:
		$VBoxContainer/Time.text = "[center][b]" + str("%02d" % minutes) + ":" + str("%02d" % seconds) + "[/b]         You tied the world record![/center]"
	else:
		var diff = time - world_record
		$VBoxContainer/Time.text = "[center][b]" + str("%02d" % minutes) + ":" + str("%02d" % seconds) + "[/b]         You were " + str(diff) + " seconds off the record[/center]"

func _on_Menu_pressed():
	var pause_menu = get_node_or_null("../../../PauseMenu")
	if pause_menu != null:
		if not debounce:
			debounce = true
			pause_menu.exit_level()
	else:
		push_error("Cannot find the pause menu node")

func _on_Replay_pressed():
	var level_manager = get_node_or_null("../../../../LegacyLevel")
	if level_manager != null:
		if not debounce:
			debounce = true
			level_manager.restart_level()
	else:
		push_error("Cannot find the level_manager")

func _on_Submit_pressed():
	if not can_submit:
		return
	
	var nickname = $VBoxContainer/NameDetails/Name.text
	if nickname.length() < 3 or nickname.length() > 20:
		$VBoxContainer/SubmissionStatus.visible = true
		$VBoxContainer/SubmissionStatus.text = "Invalid nickname: Must be between 3-20 characters"
		return
	
	var legacy_level = get_node_or_null("../../../")
	var gameNumber = legacy_level.get_gameNumber()
	
	print("Printing ", $VBoxContainer/NameDetails/Name.text, "'s submission of ", self.time, " seconds for gameNumber ", gameNumber)
	$VBoxContainer/NameDetails/Submit.disabled = true
	$VBoxContainer/SubmissionStatus.visible = true
	$VBoxContainer/SubmissionStatus.text = "Submitting..."
	can_submit = false
	
	var mutation = '{"query": "mutation { submitHighscore(gameNumber: ' + str(gameNumber) + ', nickname: \\"' + nickname + '\\", time: ' + str(self.time) + ') }"}'
	var headers : PackedStringArray
	headers.append("Content-Type: application/json")
	
	$HTTPRequest.request(WorldConstants.SERVER + "/graphql", headers, true, HTTPClient.METHOD_POST, mutation)
	
	# Save nickname
	PlayerSettings.player_name = nickname


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(response)
	var parse = test_json_conv.get_data()
	if parse.error != OK:
		$VBoxContainer/SubmissionStatus.text = "Error parsing response"
		print(response_code, ": ", response)
		can_submit = true
		return
	
	var js_obj = parse.result
	if js_obj.has("errors"):
		$VBoxContainer/SubmissionStatus.text = "Error submitting"
		can_submit = true
		return
	
	if js_obj.has("data"):
		var data = js_obj.data
		var submitHighscore = data.submitHighscore
		if submitHighscore == true:
			$VBoxContainer/SubmissionStatus.text = "Submitted!"
		else:
			$VBoxContainer/SubmissionStatus.text = "Could not submit time"
