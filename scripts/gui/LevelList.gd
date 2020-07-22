extends GridContainer

var levels : Array
const Level = preload("res://Scenes/Menu/LevelButton.tscn")

var data = [
	{
		"name": "FreeFall",
		"author": "ChallengeYou",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze250SS.jpg",
		"legacy": true,
		"gameNumber": 250
	}
]

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	var query = '{"query": "{ latestLevels(page: 4, pageSize: 25) { title, author, creationDate, plays, screenshot}}"}'
	var headers : PoolStringArray
	headers.append("Content-Type: application/json")
	
	$HTTPRequest.request("http://localhost:4000/graphql", headers, true, HTTPClient.METHOD_POST, query)

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	#print(response)
	
	var r = JSON.parse(response).result
	data = r.data.latestLevels
	loadLevels()

func loadLevels():
	for item in data:
		var new_lvl = Level.instance()
		new_lvl.get_node("Title").text = item.title
		new_lvl.get_node("Author").text = item.author
#		if item.legacy:
#			new_lvl.get_node("Archived").visible = true
		
		if (item.screenshot == "/Screenshots/DefaultSS.jpg"):
			var img = Image.new()
			if (img.load("res://res/txrs/gui/DefaultSS.jpg") != 0):
				push_warning("Warning: Could not load " + item.screenshot)
				return

			var new_tex = ImageTexture.new()
			new_tex.create_from_image(img)

			new_lvl.texture_normal = new_tex
		else:
			var img_request = HTTPRequest.new()
			add_child(img_request)
			img_request.connect("request_completed", self, "_img_request_completed", [new_lvl, item.screenshot])
			img_request.request("http://localhost:4000" + item.screenshot)
		
		add_child(new_lvl)

func _img_request_completed(result, response_code, headers, body, new_lvl, screenshot):
	var img = Image.new()
	var error = img.load_jpg_from_buffer(body)
	if error != OK:
		print(error)
		print("Couldn't load the screenshot at " + screenshot)
		return
		
	var new_tex = ImageTexture.new()
	new_tex.create_from_image(img)
	
	new_lvl.texture_normal = new_tex
	
	
