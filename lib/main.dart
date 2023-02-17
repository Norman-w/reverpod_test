import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
        Column(
          children: [
            RView(title: "RiverPodTest"),
            RController(),
          ],
        )
    );
  }
}

class StateController extends StateNotifier<ViewState> {
  StateController() : super(ViewState()
      ..count = 10
  );
  void increment() => state = ViewState()..count = state.count + 1;
}

var stateControllerProvider =
StateNotifierProvider<StateController, ViewState>((ref) => StateController());

class ViewState{
  int count = 0;
}

class RView extends ConsumerStatefulWidget {
  const RView({super.key, required this.title});

  final String title;

  @override
  createState() => _RViewState();
}

class _RViewState extends ConsumerState<RView> {
  @override
  Widget build(BuildContext context) {
    // ViewState state = ref.watch(stateControllerProvider);
    print('build yi ci ');
    var count = ref.watch(stateControllerProvider).count;
    return Text(count.toString());
  }
}
final myProvider = StateProvider((ref) => 100);


class RController extends ConsumerStatefulWidget {
  const RController({super.key});

  @override
  createState() => _RControllerState();
}
class _RControllerState extends ConsumerState<RController> {

  void _incrementCounter() {
    // ref.read(stateControllerProvider.notifier).state++;
    ref.read(stateControllerProvider.notifier).increment();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      );
  }
}