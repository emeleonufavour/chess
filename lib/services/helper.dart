import 'dart:developer';

bool withinBounds(int row, int col) {
  if (row >= 0 && row < 8 && col >= 0 && col < 8) {
    return true;
  } else {
    log("($row,$col) is not within bounds");
    return false;
  }
}
