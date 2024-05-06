import 'package:chess/app/app_theme.dart';
import 'package:flutter/material.dart';

enum ChessPiece {
  pawn("Pawn"),
  rook("Rook"),
  knight("Knight"),
  bishop("Bishop"),
  queen("Queen"),
  king("King");

  final String string;
  const ChessPiece(this.string);
}

enum Variation {
  white("White"),
  black("Black");

  final String string;
  const Variation(this.string);
}

enum pieceColor {
  light(AppColors.lightPiece),
  dark(AppColors.darkPiece);

  final Color color;
  const pieceColor(this.color);
}
