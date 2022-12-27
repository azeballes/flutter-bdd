# Flutter BDD

En este artículo vamos a crear una aplicación extremadamente simple para android devices pero siguiendo la estrategia de diseño guiado por el comportamiento [Behavior Driven Development](https://cucumber.io/docs/bdd/)

Tomaremos la aplicación por defecto que nos proporciona flutter (push counter) modificando su comportamiento para que el contador consuma un servicio de conteo centralizado. Por simplicidad solo vamos a trabajar en la capa cliente de la aplicación (sin entrar en detalles de la construcción del servicio).

## Algunas aclaraciones

- En el ejemplo iremos tomando algunas decisiones que por motivos de practicidad no aclaramos el fundamento detrás de tal decisión. En tal caso cualquier comentario, pregunta o recomendación será muy bien bienvenida :grin:

## Prerrequisitos

- [Instalar flutter](https://docs.flutter.dev/get-started/install)
- Vamos a utilizar [Android Studio](https://developer.android.com/studio) como entorno de desarrollo integrado.

## Creamos la aplicacion por defecto

- Creamos una nueva app ![image](./doc/images/new-flutter-bdd-project.png). O desde la terminal podemos ejecutar

```bash
mkdir flutter-bdd
cd flutter-bdd
flutter create --template=app --platforms android --project-name flutter_bdd --org com.example .
```

- Seleccionamos un emulador android y ejecutamos la app ![image](./doc/images/initial-screen.png)

```bash
flutter emulators
flutter emulators --launch Pixel_4_API_30
flutter run
```

## Preparación del entorno BDD

- Agregamos el paquete [bdd_widget_test](https://pub.dev/packages/bdd_widget_test)

```bash
flutter pub add bdd_widget_test --dev
```

- Agregamos el paquete build_runner como dependencia de desarrollo

```bash
flutter pub add build_runner --dev
```

- Eliminamos el test por defecto test/widget_test.dart

## Nuestro primer escenario

En BDD se abordan los casos de uso de la aplicación o interacciones del usuario con la aplicación con ejemplos que se denominan escenarios. Las características y escenarios se describen mediante el uso de un lenguaje natural de especificación denominado [Gherkin](https://cucumber.io/docs/gherkin/reference/)

A continuación vamos a crear la característica "Contador" con el escenario inicial de la aplicación.

> test/counter.feature:

```gherkin
Feature: Counter
    
    Scenario: Show initial counter value
        Given the app is running
        Given counter value is {10}
        Then I see {10} value
```

En lenguaje coloquial estamos diciendo que cuando ejecutemos la aplicación y el servicio contador tenga un valor 10 entonces mostraremos este valor en la aplicación.

Ahora que tenemos especificada la primer iteración de nuestra aplicación. Vamos a generar el test de integración asociado que nos "guíe" en la construcción.

- Generamos el test (y pasos) asociados a nuestro primer escenario mediante la ejecución del siguiente comando

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Lo anterior nos genera un test de widget _test/counter_test.dart_ con los pasos asociados a la ejecución del test.
Los pasos de la ejecución del test son generados en la carpeta _test/step/_

### TDD RED: Implementación de los pasos

#### Given the app is running

> test/step/the_app_is_running.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bdd/main.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
}
```

#### Given counter value is {10}

> test/step/counter_value_is.dart

```dart
import 'package:flutter_test/flutter_test.dart';

Future<void> counterValueIs(WidgetTester tester, int counterValue) async {}
```

#### Then I see {10} value

> test/step/i_see_value.dart

```dart
import 'package:flutter_test/flutter_test.dart';

Future<void> iSeeValue(WidgetTester tester, int counterValue) async {
  await tester.pump();
  expect(find.text(counterValue.toString()), findsOneWidget);
}
```

### Ejecutamos el test

```bash
flutter test
```

Veremos que el test falla porque no encuentra el valor '10'

```bash
00:02 +0: Counter Show initial counter value                                                                           
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching node in the widget tree
  Actual: _TextFinder:<zero widgets with text "10" (ignoring offstage widgets)>
   Which: means none were found but one was expected
```

### TDD GREEN: Hacemos la implementación más simple

Modificamos el valor inicial de _counter en el estado del widget MyHomePage

> lib/main.dart

```dart
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 10;
```

Y veremos que ahora el test pasa

### TDD BLUE: Mejoras en el código

#### 1- Separación de componentes

- Vamos a separar los tres componentes principales cada uno en su archivo

![image](./doc/images/main-files.png).

#### 2- Eliminamos la lógica asociada al estado por defecto

> lib/my_home_page.dart

```dart
import 'package:flutter/material.dart';

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### 3- MVVM

Como paso siguiente vamos a eliminar el código duro del valor inicial 10 en nuestro HomeState. Para ello necesitaremos de un colaborador que nos indique cúal es el valor inicial del contador.

La comunicación entre vistas y modelo la vamos a efectuar siguiendo el patrón MVVM, motivo por el que vamos a crear un view model asociado a la vista.

Para poder acceder a la instancia del view model vamos a utilizar IoC (Inversión de control) mediante el paquete qinject

```bash
flutter pub add qinject
```

> lib/my_home_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bdd/my_home_page_view_model.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MyHomePageViewModel _viewModel;

  @override
  void initState() {
    _viewModel = Provider.of<MyHomePageViewModel>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${_viewModel.counterValue}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

> lib/my_home_page_view_model.dart

```dart
class MyHomePageViewModel {
  int get counterValue => 0;
}
```

## Segundo escenario

En BDD vamos identificando necesidades del usuario de la aplicación, automatizamos este escenario y luego construímos la lógica asociada utilizando TDD. Esto puede ser visto como dos ciclos de desarrollo bien definidos como se muestra en la siguiente imagen:

![](https://huddle.eurostarsoftwaretesting.com/wp-content/uploads/2015/06/bdd-cycle-around-tdd-cycles.png)

En nuestro ejemplo luego de haber implementado el primer escenario deberíamos continuar implementando el view model, servicios, repositorios, servidor, etc.

Por simplicidad solo nos vamos a limitar a mostrar el ciclo de BDD y vamos a dejar de lado la implementación end to end (de extremo a extremo) de la aplicación.

Incluso vale aclarar que en general la técnica BDD se utiliza con test de aceptación (pruebas sobre la aplicación real) y en nuestro caso lo hemos aplicado con test unitarios de widgets.

Dicho lo anterior vamos a continuar con nuestro segundo escenario de uso lo cual nos permitirá seguir identificando necesidades de nuestra aplicación.

> test/counter.feature

```gherkin
Feature: Counter
    
    Scenario: Show initial counter value
        Given counter value is {10}
        Given the app is running        
        Then I see {10} value

    Scenario: Tap add button
        Given counter value is {5}
        When tap add button
        Then I see {6} value
```

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
```

> test/step/tap_add_button.dart

En el paso "tap add button" debemos verificar que se informe al view model que se ha tapeado el botón de incremento y también debemos simular el valor de retorno del valor del contador (incrementado en 1).

```dart
import 'package:flutter_bdd/my_home_page_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qinject/qinject.dart';

import 'counter_value_is.mocks.dart';

Future<void> tapAddButton(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Increment'));
  
  var mockViewModel =
      Qinject.use<dynamic, MyHomePageViewModel>() as MockMyHomePageViewModel;  
  verify(mockViewModel.onAddButtonTapped()).called(1);
  when(mockViewModel.counterValue).thenReturn(mockViewModel.counterValue + 1);
}
```
