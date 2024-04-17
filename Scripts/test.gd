extends Node

func _ready():
	var arr: BitArray = BitArray.new()
	arr.arr = [0, 0, 0, 0, 0, 0, 0, 0]
	arr.setBit(55, true)
	print(arr.getBit(54))
