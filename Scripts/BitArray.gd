extends RefCounted
class_name BitArray

var data: PackedByteArray = PackedByteArray([])
var length: int = 0

func getBit(index: int) -> int:
	var byteI: int = index / 8
	var bitI: int = index % 8
	return 0 if data[byteI] & (0b10000000 >> bitI) == 0 else 1

func getBitBool(index: int) -> bool:
	return true if getBit(index) == 1 else false

func setBit(index: int, value: int) -> void:
	var byteI: int = index / 8
	var bitI: int = index % 8
	if value != 0:
		data[byteI] = data[byteI] | (0b10000000 >> bitI)
	else:
		data[byteI] = data[byteI] & ~(0b10000000 >> bitI)

func setBitBool(index: int, value: bool) -> void:
	setBit(index, 1 if value else 0)

func changeLength(newLength: int) -> void:
	if newLength == length:
		return
	
	var arrNeededLength: int = newLength / 8
	if newLength > length:
		while len(data) < arrNeededLength + 1:
			data.append(0)
	else:
		while len(data) > arrNeededLength + 1:
			data.remove_at(len(data) - 1)
	
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
	return value

static func floatBitsToInt(value: float) -> int:
	var arr: PackedByteArray = PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
	arr.encode_double(0, value)
	return arr.decode_s64(0)

static func intBitsToFloat(value: int) -> float:
	var arr: PackedByteArray = PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
	arr.encode_s64(0, value)
	return arr.decode_double(0)

func setFromFloat(index: int, value: float) -> void: #sets 64 bits always
	setFromInt(index, 64, floatBitsToInt(value))

func getToFloat(index: int) -> float: #gets 64 bits always
	return intBitsToFloat(getToInt(index, 64))

func toBase64(compressionMode: int) -> String:
	var lengthArr: PackedByteArray = PackedByteArray([0, 0, 0, 0])
	lengthArr.encode_u32(0, length)
	return Marshalls.raw_to_base64((data + lengthArr).compress(compressionMode))

static func fromBase64(string: String, compressionMode: int) -> BitArray:
	var bitArr: BitArray = BitArray.new()
	bitArr.data = Marshalls.base64_to_raw(string).decompress_dynamic(-1, compressionMode)
	if len(bitArr.data) < 4:
		return null
	bitArr.length = bitArr.data.decode_u32(len(bitArr.data) - 4)
	for i in range(4):
		bitArr.data.remove_at(len(bitArr.data) - 1)
	if len(bitArr.data) * 8 < bitArr.length:
		return null
	return bitArr

func dataToString():
	var string: String = ""
	for i in range(min(length, len(data) * 8)):
		string += str(1 if getBit(i) else 0)
	return string
