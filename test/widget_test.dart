import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_security_app/main.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Secure Access'), findsOneWidget);
    expect(find.text('Masuk ke akun Anda'), findsOneWidget);
  });
}
