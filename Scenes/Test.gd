extends Button

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func _on_Button_pressed():
	$HTTPRequest.request("http://localhost/getMaze.php?maze=162608")
	set_disabled(true)
	

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	get_parent().loadLevelFromString(response)
	get_parent().get_parent().get_node("LegacyLevel").call("spawnPlayer")
