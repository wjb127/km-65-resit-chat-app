import 'package:flutter_test/flutter_test.dart';
import 'package:resit/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ResitApp());
    expect(find.text('RESIT'), findsOneWidget);
  });
}
