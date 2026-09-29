import 'package:flutter_test/flutter_test.dart';
import 'package:sih/main.dart';

void main() {
  testWidgets('Navigation App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SihnNavigationApp());
    expect(find.byType(SihnNavigationApp), findsOneWidget);
  });
}
