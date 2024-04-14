extends RefCounted
class_name Replay

static func pieceToDict(piece: Piece) -> Dictionary:
	return {
		"pos": piece.pos,
		"type": piece.type,
		"color": piece.color,
		"hasMoved": piece.hasMoved,
	}

static func dictToPiece(dict: Dictionary) -> Piece:
	if (!dict.has("pos") or !dict["pos"] is Vector2i or 
		!dict.has("type") or !dict["type"] is Piece.PieceType or 
		!dict.has("color") or !dict["color"] is Piece.PieceColor or 
		!dict.has("hasMoved") or !dict["hasMoved"] is bool):
		return null
	return Piece.new(
		dict["pos"],
		dict["type"],
		dict["color"],
		dict["hasMoved"]
	)

static func startSettingsToDict(startSettings: BoardState.StartSettings):
	return {
		"isTimed": startSettings.isTimed,
		"startingTime": startSettings.startingTime,
		"assistMode": startSettings.assistMode,
	}

static func dictToStartSettings(dict: Dictionary) -> BoardState.StartSettings:
	if (!dict.has("isTimed") or !dict["isTimed"] is bool or 
		!dict.has("startingTime") or !dict["startingTime"] is float or 
		!dict.has("assistMode") or !dict["assistMode"] is BoardState.StartSettings.AssistMode):
		return null
	return BoardState.StartSettings.new(
		dict["assistMode"], #weird order cause i'm stupid
		dict["isTimed"],
		dict["startingTime"]
	)

static func moveToDict(move: Move) -> Dictionary:
	return {
		"moveType": move.moveType,
		"movedPiece": null if move.movedPiece == null else pieceToDict(move.movedPiece),
		"posTryMovedTo": move.posTryMovedTo,
		"promotingTo": move.promotingTo,
		"movedKing": null if move.movedKing == null else pieceToDict(move.movedKing),
		"movedRook": null if move.movedRook == null else pieceToDict(move.movedRook),
	}

static func dictToMove(dict: Dictionary) -> Move:
	if !dict.has("moveType") or !dict["moveType"] is Move.MoveType:
		return null
	
	match dict["moveType"]:
		Move.MoveType.NORMAL, Move.MoveType.PROMOTION:
			if !dict.has("movedPiece") or !dict["movedPiece"] is Dictionary:
				return null
			var movedPiece = dictToPiece(dict["movedPiece"])
			if movedPiece == null:
				return null
			if !dict.has("posTryMovedTo") or !dict["posTryMovedTo"] is Vector2i:
				return null
			if dict["moveType"] == Move.MoveType.NORMAL:
				return Move.newNormal(movedPiece, dict["posTryMovedTo"])
			if !dict.has("promotingTo") or !dict["promotingTo"] is Piece.PieceType:
				return null
			return Move.newPromotion(movedPiece, dict["posTryMovedTo"], dict["promotingTo"])
		Move.MoveType.CASTLE:
			if !dict.has("movedKing") or !dict["movedKing"] is Dictionary:
				return null
			var movedKing = dictToPiece(dict["movedKing"])
			if movedKing == null:
				return null
			if !dict.has("movedRook") or !dict["movedRook"] is Dictionary:
				return null
			var movedRook = dictToPiece(dict["movedRook"])
			if movedRook == null:
				return null
			return Move.newCastle(movedKing, movedRook)
		_:
			return null

static func boardStateToDict(boardState: BoardState) -> Dictionary:
	var pieces = []
	for piece in boardState.pieces:
		pieces.append(pieceToDict(piece))
	var capturedPieces = []
	for piece in boardState.capturedPieces:
		capturedPieces.append(pieceToDict(piece))
	return {
		"pieces": pieces,
		"capturedPieces": capturedPieces,
		"turnToMove": boardState.turnToMove,
		"result": boardState.result,
		"previousState": null if boardState.previousState == null else boardStateToDict(boardState.previousState),
		"previousMove": null if boardState.previousMove == null else moveToDict(boardState.previousMove),
		"startSettings": null if boardState.startSettings == null else startSettingsToDict(boardState.startSettings),
		"whiteTime": boardState.whiteTime,
		"blackTime": boardState.blackTime,
		"drawState": boardState.drawState
		#move info generated on conversion back, not saved
	}

static func dictToBoardState(dict: Dictionary) -> BoardState:
	if (!dict.has("pieces") or !dict["pieces"] is Array[Dictionary] or 
		!dict.has("capturedPieces") or !dict["capturedPieces"] is Array[Dictionary] or 
		!dict.has("turnToMove") or !dict["turnToMove"] is Piece.PieceColor or 
		!dict.has("result") or !dict["result"] is BoardState.StateResult or
		!dict.has("previousState") or !(dict["previousState"] == null or dict["previousState"] is Dictionary) or
		!dict.has("previousMove") or !(dict["previousMove"] == null or dict["previousMove"] is Dictionary) or
		!dict.has("startSettings") or !(dict["startSettings"] == null or dict["startSettings"] is Dictionary) or
		!dict.has("whiteTime") or !dict["whiteTime"] is float or
		!dict.has("blackTime") or !dict["blackTime"] is float or
		!dict.has("drawState") or !dict["drawState"] is BoardState.DrawState):
		return null
	var pieces: Array[Piece] = []
	for pieceDict: Dictionary in dict["pieces"]:
		var piece = dictToPiece(pieceDict)
		if piece == null:
			return null
		pieces.append(piece)
	var capturedPieces: Array[Piece] = []
	for capturedPieceDict: Dictionary in dict["pieces"]:
		var capturedPiece = dictToPiece(capturedPieceDict)
		if capturedPiece == null:
			return null
		capturedPieces.append(capturedPiece)
	var boardState: BoardState = BoardState.new(
		pieces,
		capturedPieces,
		dict["turnToMove"],
		dict["result"],
		dict["previousState"],
		dict["previousMove"],
		[],
		[],
		null,
		null,
		dict["startSettings"],
		dict["whiteTime"],
		dict["blackTime"],
		dict["drawState"],
	)
	boardState.addMoveInfo()
	return boardState

class StateUpdate:
	#move stuff
	var moveType: Move.MoveType
	var movedPieceIndex: int #only for normal and promote move
	var posTryMovedTo: Vector2i #only for normal and promote move
	var promotingTo: Piece.PieceType #only for promote move
	var movedKingIndex: int #only for castle move
	var movedRookIndex: int #only for castle move
	
	#other
	var whiteTime: float
	var blackTime: float
	var drawState: BoardState.DrawState
	func _init(moveType_: Move.MoveType, movedPieceIndex_: int, posTryMovedTo_: Vector2i, 
		promotingTo_: Piece.PieceType, movedKingIndex_: int, movedRookIndex_: int,
		whiteTime_: float, blackTime_: float, drawState_: BoardState.DrawState):
		moveType = moveType_
		movedPieceIndex = movedPieceIndex_
		posTryMovedTo = posTryMovedTo_
		promotingTo = promotingTo_
		movedKingIndex = movedKingIndex_
		movedRookIndex = movedRookIndex_
		whiteTime = whiteTime_
		blackTime = blackTime_
		drawState = drawState_
	
	static func moveAndStuffToStateUpdate(lastState: BoardState, move: Move, whiteTime_: float, 
		blackTime_: float, drawState_: BoardState.DrawState) -> StateUpdate:
		return StateUpdate.new (
			move.moveType,
			lastState.findPieceIndex(move.movedPiece),
			move.posTryMovedTo,
			move.promotingTo,
			lastState.findPieceIndex(move.movedKing),
			lastState.findPieceIndex(move.movedRook),
			whiteTime_,
			blackTime_,
			drawState_
		)
	
	static func stateUpdateToMoveAndStuff(lastState: BoardState, stateUpdate: StateUpdate) -> Array: # [move, whiteTime, blackTime, drawState]
		var move = Move.new(
			stateUpdate.moveType,
			lastState.pieces[stateUpdate.movedPieceIndex] if stateUpdate.movedPieceIndex > 0 else null,
			stateUpdate.posTryMovedTo,
			stateUpdate.promotingTo,
			lastState.pieces[stateUpdate.movedKingIndex] if stateUpdate.movedKingIndex > 0 else null,
			lastState.pieces[stateUpdate.movedRookIndex] if stateUpdate.movedRookIndex > 0 else null,
		)
		return [move, stateUpdate.whiteTime, stateUpdate.blackTime, stateUpdate.drawState]

static func stateUpdateToDict(stateUpdate: StateUpdate) -> Dictionary:
	return {
		"moveType": stateUpdate.moveType,
		"movedPieceIndex": stateUpdate.movedPieceIndex,
		"posTryMovedTo": stateUpdate.posTryMovedTo,
		"promotingTo": stateUpdate.promotingTo,
		"movedKingIndex": stateUpdate.movedKingIndex,
		"movedRookIndex": stateUpdate.movedRookIndex,
		"whiteTime": stateUpdate.whiteTime,
		"blackTime": stateUpdate.whiteTime,
		"drawState": stateUpdate.drawState
	}

static func dictToStateUpdate(dict: Dictionary) -> StateUpdate:
	if (!dict.has("moveType") or !dict["moveType"] is Move.MoveType or
		!dict.has("movedPieceIndex") or !dict["movedPieceIndex"] is int or
		!dict.has("posTryMovedTo") or !dict["posTryMovedTo"] is Vector2i or
		!dict.has("promotingTo") or !dict["promotingTo"] is Piece.PieceType or 
		!dict.has("movedKingIndex") or !dict["movedKingIndex"] is int or
		!dict.has("movedRookIndex") or !dict["movedRookIndex"] is int or
		!dict.has("whiteTime") or !dict["whiteTime"] is float or
		!dict.has("blackTime") or !dict["whiteTime"] is float or
		!dict.has("drawState") or !dict["drawState"] is BoardState.DrawState):
		return null
	return StateUpdate.new(
		dict["moveType"],
		dict["movedPieceIndex"],
		dict["posTryMovedTo"],
		dict["promotingTo"],
		dict["movedKingIndex"],
		dict["movedRookIndex"],
		dict["whiteTime"],
		dict["blackTime"],
		dict["drawState"]
	)

static func replayToDict(replay: Replay) -> Dictionary:
	var stateUpdates_: Array[Dictionary] = []
	for stateUpdate in replay.stateUpdates:
		stateUpdates_.append(stateUpdateToDict(stateUpdate))
	return {
		"startingState": null if replay.startingState == null else boardStateToDict(replay.startingState),
		"stateUpdates": stateUpdates_
	}

static func dictToReplay(dict: Dictionary) -> Replay:
	if (!dict.has("startingState") or !(dict["startingState"] == null or dict["startingState"] is Dictionary) or
		!dict.has("stateUpdates") or !dict["stateUpdates"] is Array[Dictionary]):
		return null
	var stateUpdates_: Array[StateUpdate] = []
	for stateUpdateDict in dict["stateUpdates"]:
		var stateUpdate: StateUpdate = dictToStateUpdate(stateUpdateDict)
		if stateUpdate == null:
			return null
		stateUpdates_.append(stateUpdate)
	return Replay.new(
		null if dict["startingState"] == null else dictToBoardState(dict["startingState"]),
		stateUpdates_
	)

var startingState: BoardState
var stateUpdates: Array[StateUpdate]

func _init(startingState_: BoardState, stateUpdates_: Array[StateUpdate]):
	startingState = startingState_
	stateUpdates = stateUpdates_

static func stateToReplay(state: BoardState) -> Replay:
	var states: Array[BoardState] = []
	var currentState: BoardState = state
	while currentState.previousState != null:
		states.append(currentState)
		currentState = currentState.previousState
	states.reverse()
	
	var stateUpdates_: Array[StateUpdate] = []
	for i in range(1, len(states)):
		var stateUpdate = StateUpdate.moveAndStuffToStateUpdate(states[i-1], states[i].previousMove, 
			states[i].whiteTime, states[i].blackTime, states[i].drawState)
		stateUpdates_.append(stateUpdate)
	
	var replay: Replay = Replay.new(states[0], stateUpdates_)
	
	return replay

static func replayToState(replay: Replay) -> BoardState:
	var states: Array[BoardState] = [replay.startingState]
	for update: StateUpdate in replay.stateUpdates:
		var moveAndStuff: Array = StateUpdate.stateUpdateToMoveAndStuff(states[-1], update)
		var move: Move = moveAndStuff[0]
		var whiteTime: float = moveAndStuff[1]
		var blackTime: float = moveAndStuff[2]
		var drawState: BoardState.DrawState = moveAndStuff[3]
		
		states.append(states[-1].makeMove(move))
		if states[-1].turnToMove == Piece.PieceColor.WHITE:
			states[-1].updateTimer(whiteTime)
		else:
			states[-1].updateTimer(blackTime)
			
		states[-1].drawState = drawState
		if states[-1].drawState in [BoardState.DrawState.WHITE_OFFERED_ACCEPTED, 
									BoardState.DrawState.BLACK_OFFERED_ACCEPTED]:
			states[-1].result = BoardState.StateResult.DRAW
	return states[-1]

static func replayToString(replay: Replay) -> String:
	var dict: Dictionary = replayToDict(replay)
	var arr: PackedByteArray = var_to_bytes(dict).compress(3)
	return Marshalls.variant_to_base64(arr, false)

static func stringToReplay(string: String) -> Replay:
	return dictToReplay(Marshalls.base64_to_variant(string, false))
