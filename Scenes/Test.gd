extends Button

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func loadLevel(mazeFile):
	var mazeFileEsc = mazeFile.substr(5).http_escape()
	print(mazeFileEsc)
	$HTTPRequest.request("http://localhost:4000/levels/" + mazeFileEsc)
	set_disabled(true)
	

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	get_parent().loadLevelFromString(response)
	get_parent().get_parent().get_node("LegacyLevel").call("spawnPlayer")
