extends Node

func _ready():
	print(var_to_bytes({"abc": 1, "bcd": 2, "cde": 3}))
	print()
	print(var_to_bytes([1, 2, 3]))
