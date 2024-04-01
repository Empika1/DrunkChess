@tool
extends Node

@export var mats: Array[Control]; 
func _process(_delta):
	for i in mats:
		(i.material as ShaderMaterial).set_shader_parameter("realWidth", i.size.x)
		(i.material as ShaderMaterial).set_shader_parameter("realHeight", i.size.y)
