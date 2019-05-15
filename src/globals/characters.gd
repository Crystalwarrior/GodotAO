extends Node

var names = []
var emotes = {}

func _ready():
	var path = ProjectSettings.globalize_path("res://")
	if path == "":
		# Exported, will return the folder where the executable is located.
		path = OS.get_executable_path().get_base_dir()
	else:
		# Editor
		path = path.get_base_dir()
	load_characters(path + "/characters")
	print(path)

func load_characters(path):
	names.clear()
	emotes.clear()
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			var p = dir.get_current_dir() + "/" + file_name
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				names.append(file_name)
				emotes[file_name] = load_emotes(p + "/emotes")
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func load_emotes(path):
	var list = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			var file = file_name
			var p = dir.get_current_dir() + "/" + file_name
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				var png_file = File.new()
				png_file.open(path, File.READ)
#				var bytes = png_file.get_buffer(png_file.get_len())
				var texture = ImageTexture.new()
				texture.load(p) #deprecated method apparently
				png_file.close()
				list.append({"name": file_name.left(file_name.find_last(".png")), "file": texture})
				print("Added emote for " + file_name)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list