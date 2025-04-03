/// Helper to perform operations based on filter
T executeOnFilter<T>(
  String filter,
  T Function() dailyOperation,
  T Function() monthlyOperation,
  T Function() yearlyOperation,
) {
  switch (filter) {
    case 'Daily':
      return dailyOperation();
    case 'Monthly':
      return monthlyOperation();
    case 'Yearly':
      return yearlyOperation();
    default:
      throw ArgumentError(
        'Invalid filter - Use \'Daily\', \'Monthly\', or \'Yearly\'',
      );
  }
}
