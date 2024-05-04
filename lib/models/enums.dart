import 'package:chess/app/app_theme.dart';
import 'package:flutter/material.dart';

enum ChessPiece { pawn, rook, knight, bishop, queen, king }

enum pieceColor {
  light(AppColors.lightPiece),
  dark(AppColors.darkPiece);

  final Color color;
  const pieceColor(this.color);
}
