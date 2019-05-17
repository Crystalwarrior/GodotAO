extends HBoxContainer

onready var http_request: HTTPRequest = $HTTPRequest as HTTPRequest

var url: String = ""

func _on_button_up():
	if url.find("://"): #contains some semblance of syntax I guess
		http_request.set_download_file("res://url_music.mp3")
		http_request.request(url)

func _on_LineEdit_text_changed(new_text):
	url = new_text

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("Success, except Godot doesn't support MP3 so you're fucked.")
#	var stream = AudioStreamSample.new()
#	stream.set_data(body)
#	print(stream.is_stereo())
#	get_node("/root/Main/Music").stream = stream
#	get_node("/root/Main/Music").play()