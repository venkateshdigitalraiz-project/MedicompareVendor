import 'dart:io';

void main() {
  final file = File('lib/features/appointment/presentation/pages/appointment_bookings_page.dart');
  String content = file.readAsStringSync();
  content = content.replaceAllMapped(
    RegExp(r'\.withOpacity\((.*?)\)'),
    (match) => '.withValues(alpha: ${match.group(1)})',
  );
  file.writeAsStringSync(content);
  print('Done replacing in appointment_bookings_page.dart');
}
