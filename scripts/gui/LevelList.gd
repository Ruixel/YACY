extends GridContainer

var levels : Array
var data : Array
const Level = preload("res://Scenes/Menu/LevelButton.tscn")
var page = 1
var active = true

onready var scrollGui = get_node("..")
onready var paginationGui = get_node("../../Pagination")
onready var levelBrowserGui = get_node("../..")

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	loadPage(1)

func loadPage(pageNumber : int):
	clear()
	scrollGui.scroll_vertical = 0
	
	var query = '{"query": "{ latestLevels(page: ' + str(pageNumber) + ', pageSize: 24) { title, author, gameNumber, plays, screenshot, mazeFile}}"}'
	var headers : PoolStringArray
	headers.append("Content-Type: application/json")
	
	$HTTPRequest.request("http://localhost:4000/graphql", headers, true, HTTPClient.METHOD_POST, query)

func clear():
	for level in levels:
		level.queue_free()
		var imgreq = level.get_node_or_null("ImgRequest")
		if imgreq != null:
			imgreq.disconnect("request_completed", self, "_img_request_completed")
	levels.clear()

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	#print(response)
	
	var r = JSON.parse(response).result
	data = r.data.latestLevels
	loadLevels()

func loadLevels():
	for item in data:
		var new_lvl = Level.instance()
		levels.append(new_lvl)
		new_lvl.setMazeFile(item.mazeFile)
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
			img_request.set_name("ImgRequest")
			add_child(img_request)
			img_request.connect("request_completed", self, "_img_request_completed", [new_lvl, item.screenshot])
			img_request.request("http://localhost:4000" + item.screenshot)
		
		new_lvl.connect("pressed", self, "_level_selected", [new_lvl])
		add_child(new_lvl)

func _img_request_completed(result, response_code, headers, body, new_lvl, screenshot):
	if (!weakref(new_lvl).get_ref()):
		return
		
	var img = Image.new()
	var error = img.load_jpg_from_buffer(body)
	if error != OK:
		print(error)
		print("Couldn't load the screenshot at " + screenshot)
		return
		
	var new_tex = ImageTexture.new()
	new_tex.create_from_image(img)
	
	new_lvl.texture_normal = new_tex
	
func _on_Next_pressed():
	page = page + 1
	
	paginationGui.get_node("Page").set_text("Page: " + str(page))
	loadPage(page)

func _on_Back_pressed():
	page = page - 1
	if page < 1:
		page = 1
	
	paginationGui.get_node("Page").set_text("Page: " + str(page))
	loadPage(page)

func _level_selected(btn):
	if not active:
		return
	active = false
	
	var fade = get_node("/root/Main/Fade")
	fade.set_visible(true)
	var fade_tween = fade.get_node("Tween")
	fade_tween.interpolate_property(fade, "modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 
	  0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_tween.start()
	yield(fade_tween, "tween_all_completed")
	
	var mazeFile = btn.mazeFile
	var background = get_node_or_null("/root/Main/Background")
	if background != null:
		background.queue_free()
	
	var level_scene = load("res://Scenes/PlayLegacyLevel.tscn")
	var level = level_scene.instance()
	get_node("/root/").add_child(level)
	level.get_node("LegacyWorldLoader/Button").loadLevel(mazeFile)
	
	levelBrowserGui.set_visible(false)
	yield(level.get_node("LegacyLevel"), "s_levelLoaded")
	
	fade_tween = fade.get_node("Tween")
	fade_tween.interpolate_property(fade, "modulate", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 
	  1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	fade_tween.start()
	yield(fade_tween, "tween_all_completed")
	fade.set_visible(false)
