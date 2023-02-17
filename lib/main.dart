import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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
          children: const [
            RView(title: "RiverPodTest"),
            RController(),
            RStatelessView(),
            RStatelessController(),
          ],
        )
    );
  }
}

//region 这种通过notifyListeners手动控制是否通知监听者的方式可以直接使用ViewState里面的一个getter,setter来更新UI,但是写起来很麻烦.而且和Flutter本身自带的Provider没有语法区别.其他的区别也暂时没有发现.
class StateController extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  set count(int value) {
    _count = value;
    notifyListeners();
  }
}
//endregion

var stateControllerProvider =
ChangeNotifierProvider<StateController>((ref) => StateController());


//region 这种方式直接使用ref.read(stateControllerProvider).count++;不能更新UI
// final stateControllerProvider = StateProvider<ViewState>((ref) => ViewState());
//endregion

//region 这种方式直接使用ref.read(stateControllerProvider).count++; 不能更新UI
// final stateControllerProvider = StateNotifierProvider<StateController, ViewState>((ref) => StateController());
// class StateController extends StateNotifier<ViewState> {
//   StateController() : super(ViewState());
//
//   void increment() {
//     state = ViewState()..count = state.count+1;
//   }
// }
//endregion

// class ViewState{
//   int count = 1;
// }


//region 有状态组件
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

  int selfCount = 0;

  void _incrementCounter() {
    var viewState = ref.read(stateControllerProvider);
    viewState.count += 5;
    // ref.read(stateControllerProvider).count++;
    setState(() {
      selfCount += 2;
    });
    // ref.read(stateControllerProvider.notifier).increment();
  }

  @override
  Widget build(BuildContext context) {
    return
    Column(
      children: [
        FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: '点击增加',
          child: const Icon(Icons.add),
        ),
        Text('当前自身State值:$selfCount')
      ],
    );
  }
}
//endregion
//region 无状态组件
class RStatelessView extends ConsumerWidget {
  const RStatelessView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var count = ref.watch(stateControllerProvider).count + 100;
    return Text('StateLess组件中使用值$count');
  }
}

class RStatelessController extends ConsumerWidget {
  const RStatelessController({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(onPressed: (){
      ref.read(stateControllerProvider).count++;
    }, child:
        const Text('点击我增加'),
    );
  }
}
//endregion