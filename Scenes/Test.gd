extends Button

func _ready():
	$HTTPRequest.connect("request_completed", Callable(self, "_on_request_completed"))
	#loadLevel("Maze/258.GlassTower2.challengeyou.cy")

func loadLevel(mazeFile):
	var mazeFileEsc = mazeFile.substr(5).uri_encode()
	print(mazeFileEsc)
	$HTTPRequest.request(WorldConstants.SERVER + "/levels/" + mazeFileEsc)
	set_disabled(true)
	

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	get_parent().LoadLevelFromString(response)
	get_parent().get_parent().get_node("LegacyLevel").call("level_finished_loading")
