extends Node
class_name test2

@export var node1: test1

var i: int

signal test2Sig()

func _ready():
	node1.test1Sig.connect(
		func():
			node1.i += 1
			print("test2: ", node1.i)
			test2Sig.emit())
