extends Node

var default_objs : Dictionary

# Deep copy at the start
func load_default_objects(obj_dict):
	default_objs = obj_dict.duplicate(true) 

func save_file(fileName, objects, fixed_objects, toolToObjectDict):
	var level : Dictionary
	level["Name"] = "Untitled"
	level["Author"] = "Guest"
	level["Levels"] = WorldConstants.MAX_LEVELS # Useful incase level size changes
	level["Version"] = 0.1 # Should point to another value
	level["Objects"] = {}
	
	var levelFile = level["Objects"]
	for objType in toolToObjectDict.keys():
		var objName = WorldConstants.ToolToString.get(objType)
		levelFile[objName] = []
		
		if toolToObjectDict.get(objType).onePerLevel == true:
			for lvl in range(0, WorldConstants.MAX_LEVELS + 1):
				levelFile[objName].append(fixed_objects[objType][lvl].JSON_serialise())
		else:
			var default_dict = default_objs[objType].get_property_dict()
			for obj in objects[objType]:
				levelFile[objName].append(obj.JSON_serialise(default_dict))
	
	# Save file to disk
	var file = File.new()
	file.open("user://" + fileName, File.WRITE)
	file.store_string(JSON.print(level))
	file.close()

# Note, objects and fixed_objects should be a reference 
func load_file(fileName, objects, fixed_objects, toolToObjectDict):
	# Load file from disk
	var file = File.new()
	file.open("user://" + fileName, File.READ)
	var content = file.get_as_text()
	file.close()
	
	# Error handling
	var attempt = JSON.parse(content)
	if attempt.get_error() != OK:
		print("Error loading " + fileName + ": " + attempt.get_error_string())
		return
	
	var level = attempt.get_result()
	if typeof(level) != TYPE_DICTIONARY:
		print("Unexpected object type when loading " + fileName)
		return
	
	# Write to objects & fixed_objects
	var lvl_objects = level["Objects"]
	for objType in toolToObjectDict.keys():
		var objName = WorldConstants.ToolToString.get(objType)
		if lvl_objects[objName] == null:
			continue
		
		if toolToObjectDict.get(objType).onePerLevel == true:
			var lvl = 0
			for obj in lvl_objects[objName]:
				var new_obj = toolToObjectDict.get(objType).new(lvl)
				new_obj.JSON_deserialise(obj)
				get_parent().call("modify_fixed_object", objType, lvl, new_obj)
				
				lvl = lvl + 1
		else:
			get_parent().mode = objType
			for obj in lvl_objects[objName]:
				var new_obj = get_parent().obj_create(Utils.str2vector2(obj["Pos"]), int(obj["Lvl"]))
				new_obj.JSON_deserialise(obj)
	
	get_parent().deselect()
	get_parent().remesh_world()
