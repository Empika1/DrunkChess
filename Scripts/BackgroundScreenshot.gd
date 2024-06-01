@tool
extends SubViewport

@export var takePic: bool

func _process(delta):
	if takePic:
		take()
		takePic = false

func take():
	var txt = get_texture()
	var image = txt.get_image()
	#image.flip_y()
	image.save_png("break.png")
