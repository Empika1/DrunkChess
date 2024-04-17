extends RefCounted
class_name BitArray

var arr: PackedByteArray = PackedByteArray([])
var length: int = 0

const oneMasks = [0b01111111,
				  0b10111111,
				  0b11011111,
				  0b11101111,
				  0b11110111,
				  0b11111011,
				  0b11111101,
				  0b11111110]

const zeroMasks = [0b10000000,
				   0b01000000,
				   0b00100000,
				   0b00010000,
				   0b00001000,
				   0b00000100,
				   0b00000010,
				   0b00000001]

func getBit(i: int) -> bool:
	var byteI: int = i / 8
	var bitI: int = i % 8
	return false if arr[byteI] & (0b10000000 >> bitI) == 0 else true

func setBit(i: int, value: bool) -> void:
	var byteI: int = i / 8
	var bitI: int = i % 8
	if value:
		arr[byteI] = arr[byteI] | (0b10000000 >> bitI)
	else:
		arr[byteI] = arr[byteI] & ~(0b10000000 >> bitI)

func changeLength(diff: int):
	if diff == 0:
		return
	
	var newLength: int = length + diff
	var arrNeededLength: int = newLength / 8
	if diff > 0:
		while len(arr) < arrNeededLength + 1:
			arr.append(0)
	else:
		while len(arr) > arrNeededLength + 1:
			arr.remove_at(len(arr) - 1)
	
	length = newLength
