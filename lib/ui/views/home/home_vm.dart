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
    // This prevents the player from playing during Bot's turn
    if (!isPlayerTurn) {
      return;
    }
    await chessService.select(position, chessService.board![row][col]);
    // Move the bot if turn
    if (_chessService.getPreviousPlayerVariation ==
        _chessService.bot?.botColor) {
      await makeBotMove();
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

  // undoMove() {
  //   chessService.undoMove();
  //   notifyListeners();
  // }
}
