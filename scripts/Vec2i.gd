# Vector2 with int values for coordinates
# The actual Vector2i may be introduced in ver 3.2 of Godot so it can be replaced

var x : int
var y : int

func _init(var1 = 0, var2 = 0):
	if var1 is Vector2:
		self.x = round(var1.x) as int
		self.y = round(var1.y) as int
	else:
		self.x = var1
		self.y = var2

func cast_to_v2() -> Vector2:
	return Vector2(self.x, self.y)

func equals(other) -> bool:
	if (self.x == other.x && self.y == other.y):
		return true
	return false

func assign(other) -> void:
	self.x = other.x
	self.y = other.y
