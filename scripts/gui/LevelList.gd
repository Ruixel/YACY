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
	},
	{
		"name": "The Castle",
		"author": "ChallengeYou",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze253SS.jpg",
		"legacy": true,
		"gameNumber": 253,
	},
	{
		"name": "Pacmania",
		"author": "ChallengeYou",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze255SS.jpg",
		"legacy": true,
		"gameNumber": 255,
	},
	{
		"name": "Trash Game",
		"author": "Xard",
		"screenshot": "res://res/txrs/gui/sample_screenshots/DefaultSS.jpg",
		"legacy": true,
		"gameNumber": 54323,
	},
	{
		"name": "Cringe Story",
		"author": "DaVinci",
		"screenshot": "res://res/txrs/gui/sample_screenshots/DefaultSS.jpg",
		"legacy": true,
		"gameNumber": 43121,
	},
	{
		"name": "ChallengeYou HQ",
		"author": "NotPacman94",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65604SS.jpg",
		"legacy": true,
		"gameNumber": 65604,
	},
	{
		"name": "Good Night",
		"author": "Haakson",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65545SS.jpg",
		"legacy": true,
		"gameNumber": 65545,
	},
	{
		"name": "ChallengeYou HQ",
		"author": "NotPacman94",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65604SS.jpg",
		"legacy": true,
		"gameNumber": 65604,
	},
	{
		"name": "Good Night",
		"author": "Haakson",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65545SS.jpg",
		"legacy": true,
		"gameNumber": 65545,
	},
	{
		"name": "ChallengeYou HQ",
		"author": "NotPacman94",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65604SS.jpg",
		"legacy": true,
		"gameNumber": 65604,
	},
	{
		"name": "Good Night",
		"author": "Haakson",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65545SS.jpg",
		"legacy": true,
		"gameNumber": 65545,
	},
	{
		"name": "ChallengeYou HQ",
		"author": "NotPacman94",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65604SS.jpg",
		"legacy": true,
		"gameNumber": 65604,
	},
	{
		"name": "Good Night",
		"author": "Haakson",
		"screenshot": "res://res/txrs/gui/sample_screenshots/Maze65545SS.jpg",
		"legacy": true,
		"gameNumber": 65545,
	},
]

func _ready():
	loadLevels()

func loadLevels():
	for item in data:
		var img = Image.new()
		if (img.load(item.screenshot) != 0):
			push_warning("Warning: Could not load " + item.screenshot)
			return
			
		var new_tex = ImageTexture.new()
		new_tex.create_from_image(img)
		
		var new_lvl = Level.instance()
		new_lvl.texture_normal = new_tex
		new_lvl.get_node("Title").text = item.name
		new_lvl.get_node("Author").text = item.author
		if item.legacy:
			new_lvl.get_node("Archived").visible = true
		
		
		add_child(new_lvl)

