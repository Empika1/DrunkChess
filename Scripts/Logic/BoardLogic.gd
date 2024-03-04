extends RefCounted
class_name BoardLogic

static func doPiecesOverlap(pos1: Vector2i, radius1: int, pos2: Vector2i, radius2: int) -> bool:
	var x_diff: int = abs(pos1.x - pos2.x)
	var y_diff: int = abs(pos1.y - pos2.y)
	var distance_squared: int = x_diff * x_diff + y_diff * y_diff

	var sum_radii: int = radius1 + radius2
	var sum_radii_squared: int = sum_radii ** 2

	return distance_squared < sum_radii_squared

static func isPieceOutsideBoard(pos: Vector2i, radius: int, maxPos: Vector2i) -> bool:
	return pos.x - radius < 0 or pos.y - radius < 0 or pos.x + radius > maxPos.x or pos.y + radius > maxPos.y

static func validateStartingState(state: BoardState) -> BoardState.StateResult:
	for piece: Piece in state.pieces:
		if isPieceOutsideBoard(piece.pos, piece.hitRadius, Vector2i(Piece.boardSize, Piece.boardSize)):
			return BoardState.StateResult.START_PIECE_OUTSIDE_BOARD
			
	for i in range(state.pieces.size()):
		var piece1: Piece = state.pieces[i]
		for j in range(i + 1, state.pieces.size()):
			var piece2: Piece = state.pieces[j]
			if doPiecesOverlap(piece1.pos, piece1.hitRadius, piece2.pos, piece2.hitRadius):
				return BoardState.StateResult.START_PIECE_OVERLAPS_PIECE
	
	var whiteKingCount: int = 0
	var blackKingCount: int = 0
	for piece: Piece in state.pieces:
		if piece.type == Piece.PieceType.KING:
			if piece.color == Piece.PieceColor.WHITE:
				whiteKingCount += 1
			else:
				blackKingCount += 1
		
		if whiteKingCount > 1:
			return BoardState.StateResult.START_MULTIPLE_WHITE_KINGS
		if blackKingCount > 1:
			return BoardState.StateResult.START_MULTIPLE_BLACK_KINGS
	
	if whiteKingCount == 0:
		return BoardState.StateResult.START_NO_WHITE_KING
	if blackKingCount == 0:
		return BoardState.StateResult.START_NO_BLACK_KING
		
	return BoardState.StateResult.VALID

static func validateNormalMove(state: BoardState, move: Move) -> BoardState.StateResult:
	if state.result != BoardState.StateResult.VALID:
		return state.result

	if move.movedPiece.color != state.turnToMove:
		return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_WRONG_COLOR
		
	if isPieceOutsideBoard(move.posMovedTo, move.movedPiece.hitRadius, Vector2i(Piece.boardSize, Piece.boardSize)):
		return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_OUTSIDE_BOARD
	
	var pieceFound: bool = false
	for piece: Piece in state.pieces:
		if piece.valueEquals(move.movedPiece):
			pieceFound = true
			break
	if not pieceFound:
		return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_DOESNT_EXIST
		
	for piece: Piece in state.pieces:
		if piece.valueEquals(move.movedPiece):
			continue
		if piece.color == move.movedPiece.color:
			if doPiecesOverlap(piece.pos, piece.hitRadius, move.posMovedTo, move.movedPiece.hitRadius):
				return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_OVERLAPS_PIECE_OF_SAME_COLOR
	
	for piece: Piece in state.pieces:
		if piece.color != move.movedPiece.color && piece.type == Piece.PieceType.KING:
			if doPiecesOverlap(piece.pos, piece.hitRadius, move.posMovedTo, move.movedPiece.hitRadius):
				if move.movedPiece.color == Piece.PieceColor.WHITE:
					return BoardState.StateResult.WIN_WHITE
				else:
					return BoardState.StateResult.WIN_BLACK

	return BoardState.StateResult.VALID

static func validateCastleMove(state: BoardState, move: Move) -> BoardState.StateResult:
	if state.result != BoardState.StateResult.VALID:
		return state.result
	
	if move.movedKing.color != state.turnToMove:
		return BoardState.StateResult.MOVE_CASTLE_KING_WRONG_COLOR
	if move.movedRook.color != state.turnToMove:
		return BoardState.StateResult.MOVE_CASTLE_ROOK_WRONG_COLOR
	if move.movedKing.hasMoved:
		return BoardState.StateResult.MOVE_CASTLE_KING_ALREADY_MOVED
	if move.movedRook.hasMoved:
		return BoardState.StateResult.MOVE_CASTLE_ROOK_ALREADY_MOVED
	if move.movedKing.type != Piece.PieceType.KING:
		return BoardState.StateResult.MOVE_CASTLE_KING_IS_NOT_KING
	if move.movedRook.type != Piece.PieceType.ROOK:
		return BoardState.StateResult.MOVE_CASTLE_ROOK_IS_NOT_ROOK
	
	if move.movedKing.color == Piece.PieceColor.BLACK:
		if move.movedKing.pos != Vector2i(Piece.boardSize / 16 + Piece.boardSize * 4 / 8, Piece.boardSize / 16):
			return BoardState.StateResult.MOVE_CASTLE_KING_NOT_AT_DEFAULT_START_POS
		if not move.movedRook.pos in [Vector2i(Piece.boardSize / 16, Piece.boardSize / 16), Vector2i(Piece.boardSize / 16 + Piece.boardSize * 7 / 8, Piece.boardSize / 16)]:
			return BoardState.StateResult.MOVE_CASTLE_ROOK_NOT_AT_DEFAULT_START_POS
	else:
		if move.movedKing.pos != Vector2i(Piece.boardSize / 16 + Piece.boardSize * 4 / 8, Piece.boardSize - Piece.boardSize / 16):
			return BoardState.StateResult.MOVE_CASTLE_KING_NOT_AT_DEFAULT_START_POS
		if not move.movedRook.pos in [Vector2i(Piece.boardSize / 16, Piece.boardSize - Piece.boardSize / 16), Vector2i(Piece.boardSize / 16 + Piece.boardSize * 7 / 8, Piece.boardSize - Piece.boardSize / 16)]:
			return BoardState.StateResult.MOVE_CASTLE_ROOK_NOT_AT_DEFAULT_START_POS

	var kingFound: bool = false
	for piece: Piece in state.pieces:
		if piece.valueEquals(move.movedKing):
			kingFound = true
			break
	if not kingFound:
		return BoardState.StateResult.MOVE_CASTLE_MOVED_KING_DOESNT_EXIST

	var rookFound: bool = false
	for piece: Piece in state.pieces:
		if piece.valueEquals(move.movedRook):
			rookFound = true
			break
	if not rookFound:
		return BoardState.StateResult.MOVE_CASTLE_MOVED_ROOK_DOESNT_EXIST
	
	var lowerBound: int = min(move.movedKing.pos.x, move.movedRook.pos.x);
	var upperBound: int = max(move.movedKing.pos.x, move.movedRook.pos.x);
	for piece: Piece in state.pieces:
		if piece.valueEquals(move.movedKing) or piece.valueEquals(move.movedRook):
			continue
		var pieceIntersections: Array[Vector2i] = Geometry.horizontalLineCircleIntersections(move.movedKing.pos.y, piece.pos, Piece.hitRadius * 2, true)
		for intersection: Vector2i in pieceIntersections:
			if intersection.x > lowerBound and intersection.x < upperBound:
				if piece.color == move.movedKing.color:
					return BoardState.StateResult.MOVE_CASTLE_CASTLING_THROUGH_SAME_COLOR_PIECE
				else:
					return BoardState.StateResult.MOVE_CASTLE_CASTLING_THROUGH_OPPOSITE_COLOR_PIECE

	return BoardState.StateResult.VALID
		
static func validatePromotionMove(state: BoardState, move: Move) -> BoardState.StateResult:
	if move.movedPiece.type != Piece.PieceType.PAWN:
		return BoardState.StateResult.MOVE_PROMOTION_PROMOTED_FROM_INVALID_TYPE
	if not move.promotingTo in Piece.promotableTo:
		return BoardState.StateResult.MOVE_PROMOTION_PROMOTED_TO_INVALID_TYPE
	if not Piece.isPromotionPosition(move.posMovedTo, state.turnToMove):
		return BoardState.StateResult.MOVE_PROMOTION_PROMOTED_IN_INVALID_POSITION
	
	var normalResult: BoardState.StateResult = validateNormalMove(state, move)
	return normalResult

static func makeMove(state: BoardState, move: Move) -> BoardState:
	if state.result != BoardState.StateResult.VALID:
		return state
	
	var newState: BoardState = state.duplicate()
	newState.previousState = state
	match move.moveType:
		Move.MoveType.NORMAL:
			var result: BoardState.StateResult = validateNormalMove(newState, move)
			newState.result = result
			for piece: Piece in newState.pieces:
				if piece.valueEquals(move.movedPiece):
					piece.pos = move.posMovedTo
					piece.hasMoved = true
			
			var capturedPieceIndices: Array[int] = []
			for i: int in range(newState.pieces.size()):
				var piece: Piece = newState.pieces[i]
				if piece.color != move.movedPiece.color:
					if doPiecesOverlap(piece.pos, piece.hitRadius, move.posMovedTo, move.movedPiece.hitRadius):
						capturedPieceIndices.append(i)
			
			for i: int in range(capturedPieceIndices.size() - 1, -1, -1):
				var pieceIndex: int = capturedPieceIndices[i]
				newState.capturedPieces.append(newState.pieces[pieceIndex])
				newState.pieces.pop_at(pieceIndex)
			
			newState.turnToMove = (1 - newState.turnToMove) as Piece.PieceColor
			return newState
		Move.MoveType.CASTLE:
			var result: BoardState.StateResult = validateCastleMove(state, move)
			newState.result = result
			
			var newKingPos: Vector2i = Vector2i.ZERO
			newKingPos.y = Piece.boardSize / 16 if move.movedKing.color == Piece.PieceColor.BLACK else Piece.boardSize - Piece.boardSize / 16
			var newRookPos: Vector2i = Vector2i.ZERO
			newRookPos.y = Piece.boardSize / 16 if move.movedRook.color == Piece.PieceColor.BLACK else Piece.boardSize - Piece.boardSize / 16
			
			if move.movedRook.pos.x > move.movedKing.pos.x:
				newKingPos.x = Piece.boardSize / 16 + Piece.boardSize * 6 / 8
				newRookPos.x = Piece.boardSize / 16 + Piece.boardSize * 5 / 8
			else:
				newKingPos.x = Piece.boardSize / 16 + Piece.boardSize * 2 / 8
				newRookPos.x = Piece.boardSize / 16 + Piece.boardSize * 3 / 8
				
			for piece: Piece in newState.pieces:
				if piece.valueEquals(move.movedKing):
					piece.pos = newKingPos
					piece.hasMoved = true
			
			for piece: Piece in newState.pieces:
				if piece.valueEquals(move.movedRook):
					piece.pos = newRookPos
					piece.hasMoved = true

			newState.turnToMove = (1 - newState.turnToMove) as Piece.PieceColor
			return newState
		_:
			var result: BoardState.StateResult = validatePromotionMove(newState, move)
			newState.result = result
			for piece: Piece in newState.pieces:
				if piece.valueEquals(move.movedPiece):
					piece.type = Piece.PieceType.QUEEN
					piece.pos = move.posMovedTo
					piece.hasMoved = true
			
			var capturedPieceIndices: Array[int] = []
			for i: int in range(newState.pieces.size()):
				var piece: Piece = newState.pieces[i]
				if piece.color != move.movedPiece.color:
					if doPiecesOverlap(piece.pos, piece.hitRadius, move.posMovedTo, move.movedPiece.hitRadius):
						capturedPieceIndices.append(i)
			
			for i: int in range(capturedPieceIndices.size() - 1, -1, -1):
				var pieceIndex: int = capturedPieceIndices[i]
				newState.capturedPieces.append(newState.pieces[pieceIndex])
				newState.pieces.pop_at(pieceIndex)
			
			newState.turnToMove = (1 - newState.turnToMove) as Piece.PieceColor
			return newState
