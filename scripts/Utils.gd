extends Node

func str2vector2(v2str : String) -> Vector2:
	v2str = v2str.substr(1, v2str.length() - 2)
	var arr = v2str.split(',')
	
	return Vector2(float(arr[0]), float(arr[1]))

func str2v2array(arrStr : String) -> PoolVector2Array:
	arrStr = arrStr.substr(0, arrStr.length() - 4)
	var v2arr = arrStr.split("),")
	
	var vertices = PoolVector2Array()
	for v2 in v2arr:
		v2 = v2.substr(2)
		var arr = v2.split(',')
		
		vertices.append(Vector2(float(arr[0]), float(arr[1])))
	
	return vertices

func json2obj(obj, objType):
	match typeof(objType):
		TYPE_VECTOR2: return str2vector2(obj)
		TYPE_INT: return int(obj)
		TYPE_COLOR: return Color(obj)
		TYPE_REAL: return float(obj)
		TYPE_BOOL: return bool(obj)
		TYPE_VECTOR2_ARRAY: return str2v2array(obj)
