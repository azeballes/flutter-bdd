import 'package:flutter_test/flutter_test.dart';

Future<void> iSeeValue(WidgetTester tester, int counterValue) async {
  expect(find.text(counterValue.toString()), findsOneWidget);
}
