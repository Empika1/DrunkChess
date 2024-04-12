extends Node
class_name test1

@export var node2: test2

var i: int = 0

signal test1Sig()

func _ready():
	node2.test2Sig.connect(
		func():
			i += 1
			print("test1: ", i)
			if i < 10:
				test1Sig.emit())

func _process(delta):
	if Input.is_action_just_pressed("rmb"):
		test1Sig.emit()
