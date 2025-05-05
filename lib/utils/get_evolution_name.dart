/// Helper to get evolution stage name based on its number.
String getEvolutionName(int stage) {
  switch (stage) {
    case 1:
      return 'baby';
    case 2:
      return 'old';
    default:
      return 'egg';
  }
}
