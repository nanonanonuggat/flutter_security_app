import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_security_app/core/services/secure_vault_service.dart';
import 'package:flutter_security_app/main.dart';

void main() {
  testWidgets('renders secure login screen', (WidgetTester tester) async {
    SecureVaultService.instance.useMemoryStoreForTesting();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Secure Access'), findsOneWidget);
    expect(find.text('Rpay'), findsOneWidget);
    expect(find.text('Pay with Rupiah'), findsOneWidget);
    expect(find.text('Masuk ke Rpay'), findsOneWidget);

    SecureVaultService.instance.resetTestingStore();
  });
}
