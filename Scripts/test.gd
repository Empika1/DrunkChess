extends Node

func _ready():
	var arr: BitArray = BitArray.new()
	arr.changeLength(25)
	arr.setFromInt(4, 15, 29127)
	print(arr.getToInt(4, 15))
