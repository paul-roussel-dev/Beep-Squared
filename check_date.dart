void main() {
  final date = DateTime(2025, 8, 1, 14, 30, 0);
  print('Date: $date');
  print('Weekday: ${date.weekday}'); // 1=Monday, 7=Sunday
  print('Weekday index (0-6): ${(date.weekday - 1) % 7}'); // 0=Monday, 6=Sunday
}
