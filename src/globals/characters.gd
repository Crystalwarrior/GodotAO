extends Node

var list: = []
onready var missing = preload("res://res/missingchar.png")

func _ready():
	var path = ProjectSettings.globalize_path("res://")
	if path == "":
		# Exported, will return the folder where the executable is located.
		path = OS.get_executable_path().get_base_dir()
	else:
		# Editor
		path = path.get_base_dir()
	load_characters(path + "/characters")

func get_char_index(name: String) -> int:
	if list.empty():
		return -1
	for i in list.size():
		var character: Dictionary = list[i] as Dictionary
		if character["name"] == name:
			return i
	return -1

func get_char(idx: int):
	if list.empty() or idx > list.size():
		return null
	return list[idx]

func get_char_names():
	if list.empty():
		return null
	var names = []
	for character in list:
		names.append(character["name"])
	return names

func get_char_emote(char_idx: int, emote_idx: int):
	if list.empty() or char_idx > list.size():
		return null
	var character = get_char(char_idx)
	if not character:
		return null
	if character["emotes"].empty() or emote_idx >= character["emotes"].size():
		return null
	return character["emotes"][emote_idx]

func load_characters(path):
	list.clear()
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			var p = dir.get_current_dir() + "/" + file_name
			if dir.current_is_dir():
				var data = load_character_json(p + "/char.json")
				if data:
					list.append(data)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func load_character_json(path):
	var data_file = File.new()
	if data_file.open(path, File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	var data = data_parse.result
	if not data.has("emotes"):
		return
	for emote in data["emotes"]:
		for entry in emote.keys():
			if entry in ["file", "icon"]: #convert it to image from file path
				var file_path = path.left(path.find_last("/")+1) + emote[entry]
				var texture: Resource
				if cache.has(file_path):
					texture = cache.get(file_path)
				else:
					texture = ImageTexture.new()
					if texture.load(file_path) == OK: #deprecated method apparently
						cache.add(file_path, texture)
					else:
						texture = null
				emote[entry] = texture
	return data