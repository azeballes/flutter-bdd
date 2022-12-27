import 'package:flutter_bdd/my_home_page_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qinject/qinject.dart';

Future<void> tapAddButton(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Increment'));

  var mockViewModel = Qinject.use<dynamic, MyHomePageViewModel>();
  verify(mockViewModel.onAddButtonTapped()).called(1);

  mockViewModel.counterValue.value = mockViewModel.counterValue.value + 1;
  mockViewModel.counterValue.notifyListeners();

  await tester.pumpAndSettle();
}
