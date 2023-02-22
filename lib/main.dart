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
        // Column(
        //   children: const [
        //     RView(title: "RiverPodTest"),
        //     RController(),
        //     RStatelessView(),
        //     RStatelessController(),
        //   ],
        // )
      Scaffold(
        body:
        Column(
          children: const [
            TodoListShower(),
          ],
        )
        ,
      )
    );
  }
}

//region 这种通过notifyListeners手动控制是否通知监听者的方式可以直接使用ViewState里面的一个getter,setter来更新UI,但是写起来很麻烦.而且和Flutter本身自带的Provider没有语法区别.其他的区别也暂时没有发现.
// class StateController extends ChangeNotifier {
//   int _count = 0;
//   int get count => _count;
//   set count(int value) {
//     _count = value;
//     notifyListeners();
//   }
// }
//endregion

// var stateControllerProvider =
// ChangeNotifierProvider<StateController>((ref) => StateController());

//region 这种方式直接使用ref.read(stateControllerProvider).count++;不能更新UI
// final stateControllerProvider = StateProvider<ViewState>((ref) => ViewState());
//endregion

//region 这种方式直接使用ref.read(stateControllerProvider).count++; 不能更新UI
final stateControllerProvider = StateNotifierProvider<StateController, ViewState>((ref) => StateController());
class StateController extends StateNotifier<ViewState> {
  StateController() : super(ViewState());

  void increment() {
    // state = ViewState()..count = state.count+1;
    var newState = ViewState.copyWith(state);
    newState.count = state.count +1;
    state = newState;
  }
}
class ViewState{
  ViewState();
  int count = 1;
  factory ViewState.copyWith(ViewState old){
    return ViewState()..count = old.count;
  }
}
//endregion

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
    return Text("stateful ${count.toString()}");
  }
}
final myProvider = StateProvider((ref) => 100);


class RController extends ConsumerStatefulWidget {
  const RController({super.key});

  @override
  createState() => _RControllerState();
}

int buildTimes = 0;
class _RControllerState extends ConsumerState<RController> {

  int selfCount = 0;
  Size contextSize = Size.zero;

  void _incrementCounter() {
    // var viewState = ref.read(stateControllerProvider).count +=5;
    ref.read(stateControllerProvider.notifier).increment();
    // viewState.count += 5;
    // ref.read(stateControllerProvider).count++;
    setState(() {
      selfCount += 2;
    });
    // ref.read(stateControllerProvider.notifier).increment();
  }

  void _getSizeInfo(context){
    var size = MediaQuery.of(context).size;
    // print('width:${size.width},height:${size.height}');
    setState(() {
      contextSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildTimes++;
    return
    Column(
      children: [
        FloatingActionButton(
          onPressed:(){
            _incrementCounter();
            _getSizeInfo(context);
          } ,
          tooltip: '点击增加',
          child: const Icon(Icons.add),
        ),
        Text('当前自身State值:$selfCount'),
        Text('当前build次数:$buildTimes'),
        Text('当前contextSize:$contextSize'),
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
      ref.read(stateControllerProvider.notifier).increment();
    }, child:
        const Text('点击我增加'),
    );
  }
}
//endregion


//region state中包含list,每个组件显示一个元素
class Task{
  Task(this.name, this.color);
  String name = "";
  Color color = Colors.white;
  bool isFinished = false;
  // void setStatus(value){
  //   isFinished = value;
  // }
  copyWith(finished){
    return Task(name,color)
      ..isFinished = finished
    ;
  }
}
class TodoState{
  double count = 0;
  List<Task> things = [
    Task("第一件事儿", Colors.blue),
    Task("第2件事儿", Colors.green),
  ];
}

class TaskController extends StateNotifier<Task> {
  TaskController(Task state, this._finished) : super(state);

  bool _finished;
  bool get finished => _finished;

  void setFinished(bool finished) {
    _finished = finished;
    state = state.copyWith(finished);
    // var old = state;
    // var current = state.copyWith(finished);
    // updateShouldNotify(old, current);
  }
}

final taskProvider =
StateNotifierProvider.family<TaskController, Task, dynamic>(
        (ref, task) => TaskController(task, false));

// 定义SpaceObjectWidget
class TaskWidget extends ConsumerWidget {
  final Task task;

  const TaskWidget({required this.task, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final taskNotifier = ref.watch(taskProvider(task));
    final isFinished = taskNotifier.isFinished;
    print('build了task组件:${taskNotifier.name}');
    // 构建widget，并根据isSelected设置样式
    // ...

    return GestureDetector(
        onTap: () {

        },
        child: // widget的child部分
      ElevatedButton(onPressed: (){
        print('点击了任务:${taskNotifier.name} 当前状态:$isFinished');
        ref.read(taskProvider(task).notifier).setFinished(!isFinished);
      },child: Text(taskNotifier.name),)
    );
  }
}

var todoState = TodoState();

class TodoListShower extends ConsumerStatefulWidget{
  const TodoListShower({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TodoListShowerState();
  }
}
class _TodoListShowerState extends ConsumerState<TodoListShower> {
  @override
  Widget build(BuildContext context) {
    return Center(child:Column(
      children: [
        ...todoState.things
            .map((e) {
          // return getTaskWidget(e);
          return TaskWidget(task:e, key : Key(e.name));
        }
        ),
      ],
    ));
  }
}
//endregion