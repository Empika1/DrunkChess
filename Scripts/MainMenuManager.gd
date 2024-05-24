extends Node

@export var title: TextureRect
@export var playButton: BorderScaleButton
@export var loadReplayButton: BorderScaleButton

func _ready():
	playButton.buttonComponent.stateUpdated.connect(play)
	loadReplayButton.buttonComponent.stateUpdated.connect(loadReplay)

func _process(_delta):
	title.rotation = sin(float(Time.get_ticks_msec()) / 500) / 50

func play(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		GameManager.states = [BoardState.newDefaultStartingState(BoardState.StartSettings.new(BoardState.StartSettings.AssistMode.MOVE_ARROWS, true, 900))]
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func loadReplay(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		get_tree().change_scene_to_file("res://Scenes/Replay.tscn")
