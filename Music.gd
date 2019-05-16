extends AudioStreamPlayer

var track_name = ""

func _on_Main_play_song(song):
	if song != "stop" and song.ends_with(".ogg"):
		track_name = song.right(song.find_last("/")+1)
		song = load_ogg(song)
		if song is AudioStream:
			set_stream(song)
			play()
			return
	track_name = ""
	stop()

func load_ogg(song):
	var path = ProjectSettings.globalize_path("res://")
	if path == "":
		# Exported, will return the folder where the executable is located.
		path = OS.get_executable_path().get_base_dir()
	else:
		# Editor
		path = path.get_base_dir()
	path += "/music/" + song
	var stream: AudioStreamOGGVorbis
	if cache.has(path):
		stream = cache.get(path)
	else:
		var ogg_file = File.new()
		if ogg_file.open(path, File.READ) != OK:
			return null
		var bytes = ogg_file.get_buffer(ogg_file.get_len()) #todo: byte checking for ogg files
		stream = AudioStreamOGGVorbis.new()
		stream.data = bytes
		stream.loop = true
		ogg_file.close()
		cache.add(path, stream)
	return stream