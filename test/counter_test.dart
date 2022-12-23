// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/counter_value_is.dart';
import './step/the_app_is_running.dart';
import './step/i_see_value.dart';

void main() {
  group('''Counter''', () {
    testWidgets('''Show initial counter value''', (tester) async {
      await counterValueIs(tester, 10);
      await theAppIsRunning(tester);
      await iSeeValue(tester, 10);
    });
  });
}
