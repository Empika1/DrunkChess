extends RefCounted
class_name Replay

static func validateBoardStateForReplay(startingState: BoardState, moves: Array[Move]) -> bool: #true if good, false if bad
	if !startingState.result in [BoardState.StateResult.VALID, BoardState.StateResult.DRAW]:
		return false
	if len(startingState.capturedPieces) != 0:
		return false
	for piece in startingState.pieces:
		if piece.hasMoved:
			return false
	var currentState: BoardState = startingState
	for move in moves:
		if currentState.result != BoardState.StateResult.VALID:
			return false
		currentState = currentState.makeMove(move)
	return currentState.result in [BoardState.StateResult.VALID, BoardState.StateResult.DRAW, BoardState.StateResult.WIN_WHITE, BoardState.StateResult.WIN_WHITE]

static func validBoardStateToBitArray(state: BoardState) -> BitArray:
	var arr: BitArray = BitArray.new()
	var i: int = 0
	
	#read in version length as ubyte
	arr.changeLength(i + 8)
	arr.setFromInt(i, 8, 1) #version 1
	i += 8
	
	#get starting state and all moves that have happened in the game
	var moves: Array[Move] = []
	var states: Array[BoardState] = [state]
	var startingState: BoardState = state
	while startingState.previousState != null:
		moves.append(startingState.previousMove)
		states.append(startingState.previousState)
		startingState = startingState.previousState
	moves.reverse()
	states.reverse()
	
	#validate state
	if !validateBoardStateForReplay(startingState, moves):
		return null
	
	#read in startsettings
	arr.changeLength(i + 3)
	arr.setFromInt(i, 2, int(startingState.startSettings.assistMode))
	i += 2
	arr.setFromInt(i, 1, 1 if startingState.startSettings.isTimed else 0)
	i += 1
	if startingState.startSettings.isTimed:
		arr.changeLength(i + 64)
		arr.setFromFloat(i, startingState.startSettings.startingTime)
		i += 64
	
	#get exact starting pieces
	var whitePieces: Array[Piece] = []
	var blackPieces: Array[Piece] = []
	for piece in startingState.pieces:
		if piece.color == Piece.PieceColor.WHITE:
			whitePieces.append(piece)
		else:
			blackPieces.append(piece)
	
	#read in starting state of board
	#read in number of white pieces, number of black pieces, number of white captured pieces, number of black captured pieces as 4 ubytes
	arr.changeLength(i + 16)
	arr.setFromInt(i, 8, len(whitePieces))
	i += 8
	arr.setFromInt(i, 8, len(blackPieces))
	i += 8
	
	#read in all pieces in the order of their length being specified
	for piece in whitePieces + blackPieces:
		arr.changeLength(i + 35)
		arr.setFromInt(i, 3, int(piece.type)) #7 options for type, so 3 bytes
		i += 3
		arr.setFromInt(i, 16, piece.pos.x) #16 bytes for x pos and y pos each
		i += 16
		arr.setFromInt(i, 16, piece.pos.y)
		i += 16
		arr.setFromInt(i, 1, 1 if piece.hasMoved else 0) #1 byte for has moved
	
	#read in all state updates
	for updateI in range(len(moves)):
		var move: Move = moves[updateI]
		var state_: BoardState = states[updateI + 1]
		
		arr.changeLength(i + 2)
		arr.setFromInt(i, 2, int(move.moveType)) #3 options for type, so 2 bytes
		i += 2
		match move.moveType:
			Move.MoveType.NORMAL:
				arr.changeLength(i + 40)
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedPiece)) #8 bytes for index of moved piece
				i += 8
				arr.setFromInt(i, 16, move.posTryMovedTo.x) #16 bytes for x pos and y pos each
				i += 16
				arr.setFromInt(i, 16, move.posTryMovedTo.y)
				i += 16
			Move.MoveType.PROMOTION:
				arr.changeLength(i + 43)
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedPiece)) #8 bytes for index of moved piece
				i += 8
				arr.setFromInt(i, 16, move.posTryMovedTo.x) #16 bytes for x pos and y pos each
				i += 16
				arr.setFromInt(i, 16, move.posTryMovedTo.y)
				i += 16
				arr.setFromInt(i, 3, int(move.promotingTo)) #7 options for type, so 3 bytes
				i += 3
			Move.MoveType.CASTLE:
				arr.changeLength(i + 16)
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedKing))
				i += 8
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedRook))
				i += 8
		arr.changeLength(i + 5)
		arr.setFromInt(i, 3, int(state_.drawState)) #7 options for draw state, so 3 bytes
		i += 3
		var timeUpdateState: int = (2 if state_.whiteTime != state_.previousState.whiteTime else 0) + (1 if state_.blackTime != state_.previousState.blackTime else 0)
		arr.setFromInt(i, 2, timeUpdateState) #0 if neither updated, 1 if only black, 2 if only white, 3 if both
		i += 2
		if state_.whiteTime != state_.previousState.whiteTime:
			arr.changeLength(i + 64)
			arr.setFromFloat(i, state_.whiteTime)
			i += 64
		if state_.blackTime != state_.previousState.blackTime:
			arr.changeLength(i + 64)
			arr.setFromFloat(i, state_.blackTime)
			i += 64
	
	return arr


#static func pieceToArr(piece: Piece) -> Array:
	#return [
		#piece.pos,
		#piece.type,
		#piece.color,
		#piece.hasMoved,
	#]
#
#static func arrToPiece(arr: Array) -> Piece:
	#if (len(arr) < 4 or
		#!arr[0] is Vector2i or 
		#!arr[1] is Piece.PieceType or 
		#!arr[2] is Piece.PieceColor or 
		#!arr[3] is bool):
		#return null
	#return Piece.new(
		#arr[0],
		#arr[1],
		#arr[2],
		#arr[3]
	#)
#
#static func startSettingsToArr(startSettings: BoardState.StartSettings) -> Array:
	#return [
		#startSettings.isTimed,
		#startSettings.startingTime,
		#startSettings.assistMode,
	#]
#
#static func arrToStartSettings(arr: Array) -> BoardState.StartSettings:
	#if (len(arr) < 3 or
		#!arr[0] is bool or 
		#!arr[1] is float or 
		#!arr[2] is BoardState.StartSettings.AssistMode):
		#return null
	#return BoardState.StartSettings.new(
		#arr[2], #weird order cause i'm stupid
		#arr[0],
		#arr[1]
	#)
#
#static func moveToArr(move: Move) -> Array:
	#return [
		#move.moveType,
		#null if move.movedPiece == null else pieceToArr(move.movedPiece),
		#move.posTryMovedTo,
		#move.promotingTo,
		#null if move.movedKing == null else pieceToArr(move.movedKing),
		#null if move.movedRook == null else pieceToArr(move.movedRook),
	#]
#
#static func arrToMove(arr: Array) -> Move:
	#if len(arr) < 6 or !arr[0] is Move.MoveType:
		#return null
	#
	#match arr[0]:
		#Move.MoveType.NORMAL, Move.MoveType.PROMOTION:
			#if !arr[1] is Array:
				#return null
			#var movedPiece = arrToPiece(arr[1])
			#if movedPiece == null:
				#return null
			#if !arr[2] is Vector2i:
				#return null
			#if arr[0] == Move.MoveType.NORMAL:
				#return Move.newNormal(movedPiece, arr[2])
			#if !arr[3] is Piece.PieceType:
				#return null
			#return Move.newPromotion(movedPiece, arr[2], arr[3])
		#Move.MoveType.CASTLE:
			#if !arr[4] is Array:
				#return null
			#var movedKing = arrToPiece(arr[4])
			#if movedKing == null:
				#return null
			#if !arr[5] is Array:
				#return null
			#var movedRook = arrToPiece(arr[5])
			#if movedRook == null:
				#return null
			#return Move.newCastle(movedKing, movedRook)
		#_:
			#return null
#
#static func boardStateToArr(boardState: BoardState) -> Array:
	#var pieces = []
	#for piece in boardState.pieces:
		#pieces.append(pieceToArr(piece))
	#var capturedPieces = []
	#for piece in boardState.capturedPieces:
		#capturedPieces.append(pieceToArr(piece))
	#return [
		#pieces,
		#capturedPieces,
		#boardState.turnToMove,
		#boardState.result,
		#null if boardState.previousState == null else boardStateToArr(boardState.previousState),
		#null if boardState.previousMove == null else moveToArr(boardState.previousMove),
		#null if boardState.startSettings == null else startSettingsToArr(boardState.startSettings),
		#boardState.whiteTime,
		#boardState.blackTime,
		#boardState.drawState
		##move info generated on conversion back, not saved
	#]
#
#static func arrToBoardState(arr: Array) -> BoardState:
	#if (!arr[0] is Array or 
		#!arr[1] is Array or 
		#!arr[2] is Piece.PieceColor or 
		#!arr[3] is BoardState.StateResult or
		#!arr[4] is Array or
		#!(arr[5] == null or arr[5] is Array) or
		#!(arr[6] == null or arr[6] is Array) or
		#!arr[7] is float or
		#!arr[8] is float or
		#!arr[9] is BoardState.DrawState):
		#return null
	#var pieces: Array[Piece] = []
	#for pieceArr: Array in arr[0]:
		#var piece = arrToPiece(pieceArr)
		#if piece == null:
			#return null
		#pieces.append(piece)
	#var capturedPieces: Array[Piece] = []
	#for capturedPieceDict: Array in arr[1]:
		#var capturedPiece = arrToPiece(capturedPieceDict)
		#if capturedPiece == null:
			#return null
		#capturedPieces.append(capturedPiece)
	#var boardState: BoardState = BoardState.new(
		#pieces,
		#capturedPieces,
		#arr[2],
		#arr[3],
		#arrToBoardState(arr[4]),
		#null if arr[5] == null else arrToMove(arr[5]),
		#[],
		#[],
		#null,
		#null,
		#null if arr[6] == null else arrToStartSettings(arr[6]),
		#arr[7],
		#arr[8],
		#arr[9],
	#)
	#boardState.addMoveInfo()
	#return boardState
#
#class StateUpdate:
	##move stuff
	#var moveType: Move.MoveType
	#var movedPieceIndex: int #only for normal and promote move
	#var posTryMovedTo: Vector2i #only for normal and promote move
	#var promotingTo: Piece.PieceType #only for promote move
	#var movedKingIndex: int #only for castle move
	#var movedRookIndex: int #only for castle move
	#
	##other
	#var whiteTime: float
	#var blackTime: float
	#var drawState: BoardState.DrawState
	#func _init(moveType_: Move.MoveType, movedPieceIndex_: int, posTryMovedTo_: Vector2i, 
		#promotingTo_: Piece.PieceType, movedKingIndex_: int, movedRookIndex_: int,
		#whiteTime_: float, blackTime_: float, drawState_: BoardState.DrawState):
		#moveType = moveType_
		#movedPieceIndex = movedPieceIndex_
		#posTryMovedTo = posTryMovedTo_
		#promotingTo = promotingTo_
		#movedKingIndex = movedKingIndex_
		#movedRookIndex = movedRookIndex_
		#whiteTime = whiteTime_
		#blackTime = blackTime_
		#drawState = drawState_
	#
	#static func moveAndStuffToStateUpdate(lastState: BoardState, move: Move, whiteTime_: float, 
		#blackTime_: float, drawState_: BoardState.DrawState) -> StateUpdate:
		#return StateUpdate.new (
			#move.moveType,
			#lastState.findPieceIndex(move.movedPiece),
			#move.posTryMovedTo,
			#move.promotingTo,
			#lastState.findPieceIndex(move.movedKing),
			#lastState.findPieceIndex(move.movedRook),
			#whiteTime_,
			#blackTime_,
			#drawState_
		#)
	#
	#static func stateUpdateToMoveAndStuff(lastState: BoardState, stateUpdate: StateUpdate) -> Array: # [move, whiteTime, blackTime, drawState]
		#var move = Move.new(
			#stateUpdate.moveType,
			#lastState.pieces[stateUpdate.movedPieceIndex] if stateUpdate.movedPieceIndex > 0 else null,
			#stateUpdate.posTryMovedTo,
			#stateUpdate.promotingTo,
			#lastState.pieces[stateUpdate.movedKingIndex] if stateUpdate.movedKingIndex > 0 else null,
			#lastState.pieces[stateUpdate.movedRookIndex] if stateUpdate.movedRookIndex > 0 else null,
		#)
		#return [move, stateUpdate.whiteTime, stateUpdate.blackTime, stateUpdate.drawState]
#
#static func stateUpdateToArr(stateUpdate: StateUpdate) -> Array:
	#return [
		#stateUpdate.moveType,
		#stateUpdate.movedPieceIndex,
		#stateUpdate.posTryMovedTo,
		#stateUpdate.promotingTo,
		#stateUpdate.movedKingIndex,
		#stateUpdate.movedRookIndex,
		#stateUpdate.whiteTime,
		#stateUpdate.blackTime,
		#stateUpdate.drawState
	#]
#
#static func arrToStateUpdate(arr: Array) -> StateUpdate:
	#if (!arr[0] is Move.MoveType or
		#!arr[1] is int or
		#!arr[2] is Vector2i or
		#!arr[3] is Piece.PieceType or 
		#!arr[4] is int or
		#!arr[5] is int or
		#!arr[6] is float or
		#!arr[7] is float or
		#!arr[8] is BoardState.DrawState):
		#return null
	#return StateUpdate.new(
		#arr[0],
		#arr[1],
		#arr[2],
		#arr[3],
		#arr[4],
		#arr[5],
		#arr[6],
		#arr[7],
		#arr[8],
	#)
#
#static func replayToArr(replay: Replay) -> Array:
	#var stateUpdates_: Array = []
	#for stateUpdate in replay.stateUpdates:
		#stateUpdates_.append(stateUpdateToArr(stateUpdate))
	#return [
		#boardStateToArr(replay.startingState),
		#stateUpdates_
	#]
#
#static func arrToReplay(arr: Array) -> Replay:
	#if (!arr[0] is Array or
		#!arr[1] is Array):
		#print(arr[1])
		#return null
	#var stateUpdates_: Array[StateUpdate] = []
	#for stateUpdateArr in arr[1]:
		#var stateUpdate: StateUpdate = arrToStateUpdate(stateUpdateArr)
		#if stateUpdate == null:
			#return null
		#stateUpdates_.append(stateUpdate)
	#return Replay.new(
		#arrToBoardState(arr[0]),
		#stateUpdates_
	#)
#
#var startingState: BoardState
#var stateUpdates: Array[StateUpdate]
#
#func _init(startingState_: BoardState, stateUpdates_: Array[StateUpdate]):
	#startingState = startingState_
	#stateUpdates = stateUpdates_
#
#static func stateToReplay(state: BoardState) -> Replay:
	#var states: Array[BoardState] = []
	#var currentState: BoardState = state
	#while true:
		#states.append(currentState)
		#if currentState.previousState == null:
			#break
		#currentState = currentState.previousState
	#states.reverse()
	#
	#var stateUpdates_: Array[StateUpdate] = []
	#for i in range(1, len(states)):
		#var stateUpdate = StateUpdate.moveAndStuffToStateUpdate(states[i-1], states[i].previousMove, 
			#states[i].whiteTime, states[i].blackTime, states[i].drawState)
		#stateUpdates_.append(stateUpdate)
	#
	#var replay: Replay = Replay.new(states[0], stateUpdates_)
	#
	#return replay
#
#static func replayToState(replay: Replay) -> BoardState:
	#var states: Array[BoardState] = [replay.startingState]
	#print(replay.startingState)
	#for update: StateUpdate in replay.stateUpdates:
		#var moveAndStuff: Array = StateUpdate.stateUpdateToMoveAndStuff(states[-1], update)
		#var move: Move = moveAndStuff[0]
		#var whiteTime: float = moveAndStuff[1]
		#var blackTime: float = moveAndStuff[2]
		#var drawState: BoardState.DrawState = moveAndStuff[3]
		#
		#states.append(states[-1].makeMove(move))
		#if states[-1].turnToMove == Piece.PieceColor.WHITE:
			#states[-1].updateTimer(whiteTime)
		#else:
			#states[-1].updateTimer(blackTime)
			#
		#states[-1].drawState = drawState
		#if states[-1].drawState in [BoardState.DrawState.WHITE_OFFERED_ACCEPTED, 
									#BoardState.DrawState.BLACK_OFFERED_ACCEPTED]:
			#states[-1].result = BoardState.StateResult.DRAW
	#return states[-1]
#
#const replayCompressionMode: int = 3
#static func replayToString(replay: Replay) -> String:
	#var arr: Array = replayToArr(replay)
	#var uncompressedByteArr: PackedByteArray = var_to_bytes(arr)
	#var byteArr: PackedByteArray = uncompressedByteArr.compress(replayCompressionMode)
	#var string: String = Marshalls.raw_to_base64(byteArr)
	#return "v1" + string
#
#static func stringToReplay(string: String) -> Replay:
	#if string.substr(0, 2) != "v1":
		#return null
	#var byteArr = Marshalls.base64_to_raw(string.substr(2))
	#var uncompressedByteArr = byteArr.decompress_dynamic(-1, replayCompressionMode)
	#if uncompressedByteArr == PackedByteArray([]):
		#return null
	#var arr: Array = bytes_to_var(uncompressedByteArr)
	#var replay: Replay = arrToReplay(arr)
	#return replay
#

