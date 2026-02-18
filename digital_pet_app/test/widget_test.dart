// basic widget test for the digital pet app
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:digital_pet_app/main.dart';

void main() {
  testWidgets('Digital pet app loads', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DigitalPetApp()));
    expect(find.text('Digital Pet'), findsOneWidget);
  });
}
