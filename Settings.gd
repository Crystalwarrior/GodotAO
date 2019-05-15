extends VBoxContainer

func _ready():
	$VolumeBlips/Slider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Blips")))
	$VolumeSFX/Slider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	$VolumeMusic/Slider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))

func _on_Blips_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Blips"), linear2db(value))

func _on_SFX_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(value))

func _on_Music_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))