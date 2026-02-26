// basic widget test for calculator app
import 'package:flutter_test/flutter_test.dart';
import 'package:rsharma_a1_calculator_app/main.dart';

void main() {
  testWidgets('Calculator app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(find.text('0'), findsOneWidget);
  });
}
