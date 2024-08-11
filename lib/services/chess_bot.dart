import 'package:chess/models/enums.dart' as en;
import 'dart:math' as math;
import '../models/move.dart';
import '../models/position.dart';
import 'chess_service.dart';

class ChessBot {
  final ChessService chessService;
  final en.Variation botColor;

  ChessBot(this.chessService, this.botColor);

  List<Move> generateAllPossibleMoves(en.Variation variation) {
    List<Move> allMoves = [];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (chessService.board?[row][col] != null &&
            chessService.board![row][col]!.variation == variation) {
          Position from = Position(row: row, column: col);
          List<List<bool>> validMoves =
              chessService.calculateValidMoves(from, variation);

          for (int toRow = 0; toRow < 8; toRow++) {
            for (int toCol = 0; toCol < 8; toCol++) {
              if (validMoves[toRow][toCol]) {
                allMoves.add(Move(from, Position(row: toRow, column: toCol)));
              }
            }
          }
        }
      }
    }

    return allMoves;
  }

  Future<void> makeMove() async {
    if (chessService.getPreviousPlayerVariation != botColor) {
      Move bestMove = findBestMove(3); // Search 3 moves ahead
      chessService.makeMove(bestMove.from, bestMove.to);
    }
  }

  int minimax(int depth, bool isMaximizingPlayer, int alpha, int beta) {
    if (depth == 0) {
      return chessService.evaluateBoard();
    }

    List<Move> possibleMoves = generateAllPossibleMoves(
        isMaximizingPlayer ? botColor : getOppositeVariation(botColor));

    if (isMaximizingPlayer) {
      int maxEval = -9999;
      for (Move move in possibleMoves) {
        if (chessService.isValidMove(move.from, move.to)) {
          chessService.makeMove(move.from, move.to);
          int eval = minimax(depth - 1, false, alpha, beta);
          chessService.undoMove();
          maxEval = math.max(maxEval, eval);
          alpha = math.max(alpha, eval);
          if (beta <= alpha) {
            break;
          }
        }
      }
      return maxEval;
    } else {
      int minEval = 9999;
      for (Move move in possibleMoves) {
        if (chessService.isValidMove(move.from, move.to)) {
          chessService.makeMove(move.from, move.to);
          int eval = minimax(depth - 1, true, alpha, beta);
          chessService.undoMove();
          minEval = math.min(minEval, eval);
          beta = math.min(beta, eval);
          if (beta <= alpha) {
            break;
          }
        }
      }
      return minEval;
    }
  }

  Move findBestMove(int depth) {
    List<Move> possibleMoves = generateAllPossibleMoves(botColor);
    if (possibleMoves.isEmpty) {
      throw Exception("No valid moves available for the bot");
    }

    Move bestMove = possibleMoves[0];
    int bestValue = -9999;

    for (Move move in possibleMoves) {
      if (chessService.isValidMove(move.from, move.to)) {
        chessService.makeMove(move.from, move.to);
        int moveValue = minimax(depth - 1, false, -10000, 10000);
        chessService.undoMove();

        if (moveValue > bestValue) {
          bestMove = move;
          bestValue = moveValue;
        }
      }
    }

    return bestMove;
  }

  en.Variation getOppositeVariation(en.Variation variation) {
    return variation == en.Variation.white
        ? en.Variation.black
        : en.Variation.white;
  }
}
