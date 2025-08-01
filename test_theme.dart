import '../utils/app_theme.dart';

void main() {
  print('eveningStartHour: ${AppTheme.eveningStartHour}');
  print('eveningEndHour: ${AppTheme.eveningEndHour}');
  print('isEveningTime: ${AppTheme.isEveningTime}');
  print('isEveningTimeCustom: ${AppTheme.isEveningTimeCustom(20, 6)}');
}
