import 'package:chess/services/chess_service.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app_setup.locator.dart';
import '../../../models/position.dart';

class HomeViewModel extends ReactiveViewModel {
  final ChessService _chessService = locator<ChessService>();
  Position? get selectedPosition => _chessService.getSelectedPosition;
  bool isSelected(int row, int col) =>
      selectedPosition?.row == row && selectedPosition?.column == col;

  ChessService get chessService => _chessService;

  select(int row, int col) {
    chessService.select(
        Position(row: row, column: col), chessService.board![row][col]);
    notifyListeners();
  }
}
