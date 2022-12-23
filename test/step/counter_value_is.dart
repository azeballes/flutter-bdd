import 'package:flutter_bdd/my_home_page_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qinject/qinject.dart';

import 'counter_value_is.mocks.dart';

@GenerateNiceMocks([MockSpec<MyHomePageViewModel>()])
Future<void> counterValueIs(WidgetTester tester, int counterValue) async {
  MyHomePageViewModel viewModel = MockMyHomePageViewModel();
  when(viewModel.counterValue).thenReturn(counterValue);
  Qinject.register((_) => viewModel);
}
