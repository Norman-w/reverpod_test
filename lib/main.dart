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
      Scaffold(
        body:
        Column(
          children: const [
            // TaskListShower(),
            TodoShower(),
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
  TodoState();
  double count = 0;
  List<Task> things =
  // [];
  [
  Task("第一件事儿", Colors.blue),
  Task("第2件事儿", Colors.green),
  ];
  TodoState copyWith({double? count, List<Task>? things}){
    return TodoState()
      ..count = count ?? this.count
      ..things = things ?? this.things
    ;
  }
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

final tasksProvider =
StateNotifierProvider.family<TaskController, Task, dynamic>(
        (ref, task) => TaskController(task, false));

// 定义SpaceObjectWidget
class TaskWidget extends ConsumerWidget {
  final Task task;

  const TaskWidget({required this.task, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final taskNotifier = ref.watch(tasksProvider(task));
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
        ref.read(tasksProvider(task).notifier).setFinished(!isFinished);
      },child: Text(taskNotifier.name),)
    );
  }
}
//endregion

class TodoStateNotifier extends StateNotifier<TodoState> {
  TodoStateNotifier() : super(TodoState());

  void addTask(Task task) {
    state = state.copyWith(
      things: [...state.things, task],
    );
  }
  void insertTask(Task task, int index) {
    List<Task> newThings = [...state.things];
    newThings.insert(index, task);
    state = state.copyWith(things: newThings);
  }
}

final todoStateProvider = StateNotifierProvider<TodoStateNotifier, TodoState>(
        (ref) => TodoStateNotifier());


class TodoShower extends ConsumerWidget {
  const TodoShower({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final todoState = ref.watch(todoStateProvider);
      return Center(
        child: Column(
          children: [
            ...todoState.things
                .map((e) {
              // return getTaskWidget(e);
              return TaskWidget(task:e, key : Key(e.name));
            }
            ),


            //添加记录的按钮
            ElevatedButton(onPressed: (){
              ref.read(todoStateProvider.notifier).addTask(Task("第${todoState.things.length+1}件事儿", Colors.blue));
            },child: const Text("添加任务"),),

            //插入记录的按钮,记录的name使用随机数
            ElevatedButton(onPressed: (){
              ref.read(todoStateProvider.notifier).insertTask(Task("第${todoState.things.length+1}件事儿", Colors.blue), 1);
            },child: const Text("插入任务"),),
          ],
        ),
      );
  }
}