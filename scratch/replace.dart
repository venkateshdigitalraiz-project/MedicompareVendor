import 'dart:io';

void main() {
  final file = File('lib/features/appointment/presentation/pages/appointment_details_page.dart');
  String content = file.readAsStringSync();
  content = content.replaceAll('.withOpacity(0.4)', '.withValues(alpha: 0.4)');
  content = content.replaceAll('.withOpacity(0.1)', '.withValues(alpha: 0.1)');
  content = content.replaceAll('.withOpacity(0.02)', '.withValues(alpha: 0.02)');
  content = content.replaceAll('.withOpacity(0.04)', '.withValues(alpha: 0.04)');
  content = content.replaceAll('.withOpacity(0.06)', '.withValues(alpha: 0.06)');
  file.writeAsStringSync(content);
  print('Done replacing in appointment_details_page.dart');
}
