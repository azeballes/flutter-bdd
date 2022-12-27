import 'package:flutter/material.dart';
import 'package:flutter_bdd/ioc_module.dart';
import 'package:flutter_bdd/my_home_page_view_model.dart';

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
    _viewModel = qinjector.use();
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
            _counterValue(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewModel.onAddButtonTapped,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _counterValue(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _viewModel.counterValue,
      builder: (context, value, _) => Text(
        '$value',
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}
