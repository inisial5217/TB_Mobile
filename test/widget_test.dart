import 'package:flutter_test/flutter_test.dart';
import 'package:tb_ecommerce/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that splash screen is loaded
    expect(find.text('TBPrak Shop'), findsOneWidget);
  });
}
