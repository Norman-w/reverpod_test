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