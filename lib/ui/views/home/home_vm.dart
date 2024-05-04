import 'package:chess/services/chess_service.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  final ChessService _chessService = ChessService();

  ChessService get chessService => _chessService;
}
