extends Node

func _ready():
	var b: BitArray = BitArray.new()
	b.changeLength(64)
	b.setFromFloat(0, 3000)
	print(b.dataToString())
