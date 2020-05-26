extends HBoxContainer

export(NodePath) var music_node
onready var audio_player: AudioStreamPlayer = get_node(music_node) as AudioStreamPlayer

onready var trackname: Label = $TrackName as Label
onready var timeline: HSlider = $Timeline as HSlider
onready var timestamp: Label = $Time as Label

var curr_max_seconds = 0
var curr_seconds = 0

func _process(delta):
	update_timestamp()

func update_timestamp():
	if not audio_player or not audio_player.stream or not audio_player.playing:
		timestamp.text = "00 : 00 / 00 : 00"
		trackname.text = "No Track"
		timeline.value = 0
		timeline.max_value = 0
		return
	if curr_max_seconds != audio_player.stream.get_length() or audio_player.get_playback_position() != curr_seconds:
		curr_max_seconds = audio_player.stream.get_length()
		curr_seconds = audio_player.get_playback_position()

		var ltext = time.format(curr_seconds, time.FORMAT_MINUTES | time.FORMAT_SECONDS)
		var rtext = time.format(curr_max_seconds, time.FORMAT_MINUTES | time.FORMAT_SECONDS)
		timestamp.text = ltext + " / " + rtext

		timeline.value = curr_seconds
		timeline.max_value = curr_max_seconds
	if trackname.text != audio_player.track_name:
		trackname.text = audio_player.track_name
