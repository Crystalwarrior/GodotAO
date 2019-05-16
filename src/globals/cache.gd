extends Node

#keeps track of external resources

var dict: Dictionary = {}

func add(path: String, resource: Resource) -> void:
	dict[path] = resource

func remove(path: String) -> void:
	if dict.has(path):
		dict.erase(path)

func has(path: String) -> bool:
	if dict.has(path):
		return true
	return false

func get(path: String) -> Resource:
	return dict[path]

#UHHHHHHH TODO: Probably make this safer and remove the actual resources, buuuuuuut...
#...what about all the references?
func clear() -> void:
	dict.clear()