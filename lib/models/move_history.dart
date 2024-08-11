import 'package:chess/models/chess_piece.dart' as model;

import 'position.dart';

class MoveHistory {
  final Position from;
  final Position to;
  final model.ChessPiece movedPiece;
  final model.ChessPiece? capturedPiece;
  final bool? prevCastlingRights;

  MoveHistory(this.from, this.to, this.movedPiece, this.capturedPiece,
      this.prevCastlingRights);
}
