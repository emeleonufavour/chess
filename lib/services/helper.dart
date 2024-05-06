bool withinBounds(int row, int col) {
  if (row >= 0 && row < 8 && col >= 0 && col < 8) {
    return true;
  } else {
    return false;
  }
}
