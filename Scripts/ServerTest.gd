extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var upnp = UPNP.new()
	var discoverResult = upnp.discover()
	
	if discoverResult == UPNP.UPNP_RESULT_SUCCESS:
		print("yay!")
	
	var externalIP = upnp.query_external_address()
	print(externalIP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
