extends Tree

signal song_selected(song)

func _ready():
	clear()
	set_hide_root(true)
	var path = ProjectSettings.globalize_path("res://")
	if path == "":
		# Exported, will return the folder where the executable is located.
		path = OS.get_executable_path().get_base_dir()
	else:
		# Editor
		path = path.get_base_dir()
	dir_contents(path + "/music")

func dir_contents(path, current=null, name=""):
	var dir = Directory.new()
#	var dict = {"name": name, "contents": []}
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var me = create_item(current)
		me.set_text(0, name)
		me.set_metadata(0, "stop")
		var file_name = dir.get_next()
		while (file_name != ""):
			var file = file_name
			var p = dir.get_current_dir() + "/" + file_name
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				file = dir_contents(p, me, file_name) #recursive woo
			else:
				print("Found file: " + file_name)
			if file is String and file.ends_with(".ogg"):
#				dict["contents"].append(file)
				var item = create_item(me)
				item.set_text(0, file_name)
				item.set_metadata(0, name + "/%s" % file_name)
			file_name = dir.get_next()
#		return dict
	else:
		print("An error occurred when trying to access the path.")
		return null

func _on_item_activated():
	var item = get_selected()
	var meta = item.get_metadata(0)
	if meta:
		emit_signal("song_selected", meta)