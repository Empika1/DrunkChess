extends Node

@export var playButton: BorderScaleButton

func _ready():
	playButton.buttonComponent.stateUpdated.connect(play)

func play(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		GameManager.states = [BoardState.newDefaultStartingState(BoardState.StartSettings.new(BoardState.StartSettings.AssistMode.MOVE_ARROWS, true, 900))]
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
