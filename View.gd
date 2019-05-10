extends ViewportContainer

onready var viewport: Viewport = $Viewport as Viewport

func _on_View_resized():
	scale_viewport(rect_size)

func scale_viewport(window_size):
#	var window_size = OS.get_window_size()
	print(window_size)
#
#	# see how big the window is compared to the viewport size
#	# floor it so we only get round numbers (0, 1, 2, 3 ...)
#	var scale_x = floor(window_size.x / viewport.size.x)
#	var scale_y = floor(window_size.y / viewport.size.y)
#
#	# use the smaller scale with 1x minimum scale
#	var scale = max(1, min(scale_x, scale_y))
#
#	# find the coordinate we will use to center the viewport inside the window
#	var diff = window_size - (viewport.size * scale)
#	var diffhalf = (diff * 0.5).floor()
#
#	var rect = Rect2(diffhalf, viewport.size * scale)
#	print(rect)
#	# attach the viewport to the rect we calculated
#	viewport.set_attach_to_screen_rect(rect)
#