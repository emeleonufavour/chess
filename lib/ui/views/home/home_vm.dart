import 'dart:developer';

import 'package:chess/services/chess_service.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app_setup.locator.dart';
import '../../../models/position.dart';

class HomeViewModel extends ReactiveViewModel {
  final ChessService _chessService = locator<ChessService>();
  Position? get selectedPosition => _chessService.getSelectedPosition;
  bool isSelected(int row, int col) =>
      selectedPosition?.row == row && selectedPosition?.column == col;
  bool get isPlayerTurn =>
      _chessService.getPreviousPlayerVariation != _chessService.bot?.botColor;

  ChessService get chessService => _chessService;

  Future<void> select(int row, int col) async {
    final position = Position(row: row, column: col);
    if (!isPlayerTurn) {
      return; // Prevent player from moving during bot's turn
    }
    await chessService.select(position, chessService.board![row][col]);
    if (_chessService.getPreviousPlayerVariation ==
        _chessService.bot?.botColor) {
      // If it's now the bot's turn, make a move
      makeBotMove();
    }

    notifyListeners();
  }

  restartGame() {
    chessService.init();
    notifyListeners();
  }

  Future<void> makeBotMove() async {
    setBusy(true);
    await _chessService.makeBotMove();
    setBusy(false);
    notifyListeners();
  }

  undoMove() {
    chessService.undoMove();
    notifyListeners();
  }
}
