extends RefCounted
class_name BitArray

var arr: PackedByteArray = PackedByteArray([])
var length: int = 0

func getBit(index: int) -> int:
	var byteI: int = index / 8
	var bitI: int = index % 8
	return 0 if arr[byteI] & (0b10000000 >> bitI) == 0 else 1

func getBitBool(index: int) -> bool:
	return true if getBit(index) == 1 else false

func setBit(index: int, value: int) -> void:
	var byteI: int = index / 8
	var bitI: int = index % 8
	if value != 0:
		arr[byteI] = arr[byteI] | (0b10000000 >> bitI)
	else:
		arr[byteI] = arr[byteI] & ~(0b10000000 >> bitI)

func setBitBool(index: int, value: bool) -> void:
	setBit(index, 1 if value else 0)

func changeLength(newLength: int) -> void:
	if newLength == length:
		return
	
	var arrNeededLength: int = newLength / 8
	if newLength > length:
		while len(arr) < arrNeededLength + 1:
			arr.append(0)
	else:
		while len(arr) > arrNeededLength + 1:
			arr.remove_at(len(arr) - 1)
	
	length = newLength

func setFromInt(index: int, numBits: int, value: int) -> void:
	for i in range(numBits):
		var bitI: int = index + i
		setBit(bitI, (value >> (numBits - i - 1)) & 0b1)

func getToInt(index: int, numBits: int) -> int:
	var value: int = 0
	for i in range(numBits):
		var bitI: int = index + i
		value |= getBit(bitI) << (numBits - i - 1)
		print(getBit(bitI))
	return value

func toString():
	var string: String = ""
	for i in range(length):
		string += str(1 if getBit(i) else 0)
	return string
