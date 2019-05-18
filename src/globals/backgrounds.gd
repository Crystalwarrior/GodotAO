extends Node

var list: = []
onready var missing = preload("res://res/missingbg.png")

func _ready():
	var path = ProjectSettings.globalize_path("res://")
	if path == "":
		# Exported, will return the folder where the executable is located.
		path = OS.get_executable_path().get_base_dir()
	else:
		# Editor
		path = path.get_base_dir()
	load_backgrounds(path + "/backgrounds")

func get_bg_index(name: String) -> int:
	if list.empty():
		return -1
	for i in list.size():
		var bg: Dictionary = list[i] as Dictionary
		if bg["name"] == name:
			return i
	return -1

func get_bg(idx: int):
	if list.empty() or idx > list.size():
		return null
	return list[idx]

func get_bg_names():
	if list.empty():
		return null
	var names = []
	for bg in list:
		names.append(bg["name"])
	return names

func get_bg_pos(bg_idx: int, pos_idx: int):
	if list.empty() or bg_idx > list.size():
		return null
	var bg = get_bg(bg_idx)
	if not bg:
		return null
	if bg["positions"].empty() or pos_idx >= bg["positions"].size():
		return null
	return bg["positions"][pos_idx]

func get_client_in_bg(bg_idx: int, client: int):
	if list.empty() or bg_idx > list.size():
		return null
	var bg = get_bg(bg_idx)
	if not bg:
		return null
	return bg["clients"].find(client)

func load_backgrounds(path):
	list.clear()
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			var file = file_name
			var file_path = dir.get_current_dir() + "/" + file_name
			if dir.current_is_dir():
				print("Found background: " + file_name)
				var data = get_positions(file_path)
				if data:
					list.append({"name": file_name, "positions": data, "clients": []})
#			else:
#				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func get_positions(path):
	var data = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			var file = file_name
			var file_path = dir.get_current_dir() + "/" + file_name
			if not dir.current_is_dir():
				print("Found position: " + file_name)
				var texture: Resource
				if cache.has(file_path):
					texture = cache.get(file_path)
				else:
					texture = ImageTexture.new()
					if texture.load(file_path) == OK: #deprecated method apparently
						cache.add(file_path, texture)
					else:
						texture = null
				data.append({"name": file_name.left(file_name.find(".")), "file": texture})
				print(data)
			file_name = dir.get_next()
		return data
	else:
		print("An error occurred when trying to access the path.")