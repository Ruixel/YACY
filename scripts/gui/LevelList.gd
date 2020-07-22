extends GridContainer

var levels : Array
var data : Array
const Level = preload("res://Scenes/Menu/LevelButton.tscn")
var page = 1

onready var scrollGui = get_node("..")
onready var paginationGui = get_node("../../Pagination")

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	loadPage(1)

func loadPage(pageNumber : int):
	clear()
	scrollGui.scroll_vertical = 0
	
	var query = '{"query": "{ latestLevels(page: ' + str(pageNumber) + ', pageSize: 24) { title, author, creationDate, plays, screenshot}}"}'
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
