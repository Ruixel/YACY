extends Node

var default_objs : Dictionary

# Deep copy at the start
func load_default_objects(obj_dict):
	default_objs = obj_dict.duplicate(true) 

func save_file(objects, fixed_objects, toolToObjectDict):
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
		
	print(JSON.print(level))
