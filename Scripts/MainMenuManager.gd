extends Node

@export var title: TextureRect
@export var playButton: BorderScaleButton
@export var loadReplayButton: BorderScaleButton
@export var playMenuTimeControlBox1: LineEdit
@export var playMenuTimeControlBox2: LineEdit
@export var playMenuTimeControlBox3: LineEdit

func _ready():
	playButton.buttonComponent.stateUpdated.connect(play)
	loadReplayButton.buttonComponent.stateUpdated.connect(loadReplay)
	playMenuTimeControlBox1.text_changed.connect(box1TextChanged)
	playMenuTimeControlBox2.text_changed.connect(func(newText: String): box2Or3TextChanged(newText, playMenuTimeControlBox2))
	playMenuTimeControlBox3.text_changed.connect(func(newText: String): box2Or3TextChanged(newText, playMenuTimeControlBox3))

func _process(_delta):
	title.pivot_offset = Vector2(title.size.x * 316.075/611, title.size.y * 191.68/333)
	title.rotation = sin(float(Time.get_ticks_msec()) / 500) / 50

func play(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		GameManager.states = [BoardState.newDefaultStartingState(BoardState.StartSettings.new(BoardState.StartSettings.AssistMode.MOVE_ARROWS, true, 900))]
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func loadReplay(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		get_tree().change_scene_to_file("res://Scenes/Replay.tscn")

func box1TextChanged(newText: String):
	var oldCaretColumn: int = playMenuTimeControlBox1.caret_column
	var newerText: String = ""
	for i: String in newText:
		if i in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]:
			newerText += i
	playMenuTimeControlBox1.text = newerText
	playMenuTimeControlBox1.caret_column = oldCaretColumn - len(newText) + len(newerText)

func box2Or3TextChanged(newText: String, box: LineEdit):
	if len(newText) == 1:
		if not newText[0] in ["1", "2", "3", "4", "5", "0"]:
			box.text = ""
	elif len(newText) == 2:
		var oldCaretColumn: int = box.caret_column
		var newerText: String = ""
		if newText[0] in ["1", "2", "3", "4", "5", "0"]:
			newerText += newText[0]
		if newText[1] in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]:
			newerText += newText[1]
		box.text = newerText
		box.caret_column = oldCaretColumn - len(newText) + len(newerText)
