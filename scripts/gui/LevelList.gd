extends GridContainer

var levels : Array
var data : Array
var imageRequests : Array
const Level = preload("res://Scenes/Menu/LevelButton.tscn")
var page = 1
var searchQuery : String = ""

var orderType = "newest"
enum OrderType { Newest, Oldest, Plays }
const orderTypeValues = ["newest", "oldest", "plays"]

var searchType = "level"
enum SearchType { Search, User, Random }
const searchTypeValues = ["level", "user", "random"]

var active = true

@onready var scrollGui = get_node("..")
@onready var paginationGui = get_node("../../Pagination")
@onready var levelBrowserGui = get_node("../..")
@onready var searchTermsGui = get_node("../../SearchTerms")
@onready var searchTypeGui = get_node("../../SearchTerms/SearchType")
@onready var orderTypeGui = get_node("../../SearchTerms/OrderType")
@onready var searchGui = get_node("../../SearchTerms/Search")
@onready var fadeGui = get_node("/root/Main/Fade")
@onready var errorLabelGui = get_node("../../ErrorLabel")
@onready var mainScene = get_node("/root/Main/")

func _ready():
	searchTypeGui.add_item("Search Levels")
	searchTypeGui.add_item("From User")
	searchTypeGui.add_item("Random")
	
	orderTypeGui.add_item("Newest")
	orderTypeGui.add_item("Oldest")
	orderTypeGui.add_item("Popularity")
	
	$HTTPRequest.connect("request_completed", Callable(self, "_on_request_completed"))
	loadPage(1)  

func loadPage(pageNumber : int):
	clear()
	scrollGui.scroll_vertical = 0
	errorLabelGui.set_text("Loading levels...")
	
	var query = '{"query": "{ searchLevels(query: \\"' + str(searchQuery) + '\\", page: ' + str(pageNumber) + ', pageSize: 24, searchType: ' + searchType + ', orderBy: ' + orderType + ' ) { title, author, gameNumber, plays, screenshot, mazeFile}}"}'
	var headers : PackedStringArray
	headers.append("Content-Type: application/json")
	
	# Use a different query for random searches
	if (searchType == "random"):
		query = '{"query": "{ getRandomLevels(limit: 24) { title, author, gameNumber, plays, screenshot, mazeFile}}"}'
	
	var error = $HTTPRequest.request(WorldConstants.SERVER + "/graphql", headers, true, HTTPClient.METHOD_POST, query)

func clear():
	# Cancel remaining image requests
	for imgReq in imageRequests:
		imgReq.cancel_request()
		imgReq.disconnect("request_completed", Callable(self, "_img_request_completed"))
		imgReq.queue_free()
	imageRequests.clear()
	
	for level in levels:
		level.queue_free()
	levels.clear()

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	print(response)
	print(response_code)
	data = []
	
	if response_code == 200:
		var test_json_conv = JSON.new()
		test_json_conv.parse(response)
		var jparse = test_json_conv.get_data()
		if jparse.get_error() != OK:
			errorLabelGui.set_text("Error: Could not parse HTTP Response")
			return
			
		print("type: " + str(typeof(jparse.result)))
		if typeof(jparse.result) != TYPE_DICTIONARY:
			errorLabelGui.set_text("Error: Unexpected value when parsing HTTP Response")
			return
		
		var r = jparse.result
		if ("data" in r and "searchLevels" in r.data and r.data.searchLevels != null):
			data = r.data.searchLevels
			loadLevels()
		elif ("data" in r and "getRandomLevels" in r.data and r.data.getRandomLevels != null): 
			data = r.data.getRandomLevels
			loadLevels()
		else:
			errorLabelGui.set_text("Error: Internet server error while retrieving level data")
			
	elif response_code == 0:
		errorLabelGui.set_text("Error: Could not connect to server")
	else:
		errorLabelGui.set_text("Error: Could not load levels, error code: " + str(response_code))

func loadLevels():
	if data.size() == 0:
		errorLabelGui.set_text("No levels found")
		return

	for item in data:
		errorLabelGui.set_text("")
		
		var new_lvl = Level.instantiate()
		levels.append(new_lvl)
		new_lvl.setMazeFile(item.mazeFile)
		new_lvl.setGameNumber(item.gameNumber)
		new_lvl.get_node("Title").text = item.title
		new_lvl.get_node("Author").text = item.author
		new_lvl.get_node("Plays").text = "Plays: " + str(item.plays)
#		if item.legacy:
#			new_lvl.get_node("Archived").visible = true
		
		if (item.screenshot == "/Screenshots/DefaultSS.jpg"):
#			if (img.load("res://res/txrs/gui/DefaultSS.jpg") != 0):
#				push_warning("Warning: Could not load " + item.screenshot)
#				return

			var stream_texture = load("res://res/txrs/gui/DefaultSS.jpg")
			var img = stream_texture.get_data()
			img.decompress()

			var new_tex = ImageTexture.new()
			new_tex.create_from_image(img)

			new_lvl.texture_normal = new_tex
		else:
			var img_request = HTTPRequest.new()
			add_child(img_request)
			img_request.set_name("ImgRequest")
			img_request.connect("request_completed", Callable(self, "_img_request_completed").bind(new_lvl, item.screenshot))
			img_request.request(WorldConstants.SERVER + item.screenshot)
			imageRequests.append(img_request)
		
		new_lvl.connect("pressed", Callable(self, "_level_selected").bind(new_lvl))
		add_child(new_lvl)

func _img_request_completed(result, response_code, headers, body, new_lvl, screenshot):
	if (!weakref(new_lvl).get_ref() or response_code != 200):
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
	
	$LoadLevel.play()
	
	fadeGui.fade(0.6)
	await fadeGui.s_fade_complete
	
	var gameNumber = btn.gameNumber
	mainScene.unload_background()
	
	var level_scene = load("res://Scenes/PlayLegacyLevel.tscn")
	var level = level_scene.instantiate()
	get_node("/root/").add_child(level)
	#level.get_node("LegacyWorldLoader/Button").loadLevel(mazeFile)
	level.get_node("LegacyLevel").load_level(gameNumber)
	
	levelBrowserGui.set_visible(false)
	await level.get_node("LegacyLevel").s_levelLoaded
	
	#fadeGui.unfade(1)
	#yield(fadeGui, "s_unfade_complete")

func _on_Search_text_entered(new_text):
	page = 1
	searchQuery = new_text
	loadPage(page)

func _on_SearchType_item_selected(id):
	# If selecting a user, add ChallengeYou if the search bar hasnt been used
	if (searchGui.text == "" and id == SearchType.User):
		searchGui.text = "ChallengeYou"
		searchQuery = "ChallengeYou"
	else:
		searchGui.text = ""
		searchQuery = ""
	
	if (id == SearchType.Random):
		searchGui.editable = false
	else:
		searchGui.editable = true
	
	page = 1
	searchType = searchTypeValues[id]
	loadPage(page)

func _on_OrderType_item_selected(id):
	page = 1
	orderType = orderTypeValues[id]
	loadPage(page)

