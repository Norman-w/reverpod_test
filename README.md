# Flutter Riverpod 状态管理器使用测试

## 总结:
1. `flutter pub add flutter_riverpod` 即可安装
2. main.dart中 引用 `'package:flutter_riverpod/flutter_riverpod.dart';`
3. main函数改为`void main() {
   runApp(const ProviderScope(child: MyApp()));
   }`
4. 需要使用到多组件共享状态全局状态等的地方 也入main.dart中一样引用.
5. 使用`final counterProvider = StateProvider((ref) => 0);`定义一个状态为直接单个状态的provider
6. `class StateController extends ChangeNotifier {
   int _count = 0;
   int get count => _count;
   set count(int value) {
   _count = value;
   notifyListeners();
   }
   }`可以定义一个状态为多个状态的控制器,然后使用`final counterProvider = StateNotifierProvider((ref) => StateController());`定义一个状态为多个状态的provider来使用
7. 使用ConsumerStatefulWidget可以管理自身的状态而不需要借助Riverpod把状态升级到外面
8. 通过使用Riverpod可以在不同的Widget中共享状态,StateLess的组件也可以变成像有状态一样.因为他的状态在外面
9. 我们不可直接赋值触发状态变更吗?哦,或许那样使用起来更简单,但是代码可读性差一点,有时候不知道是页面刷新操作.所以我们使用`context.read(counterProvider).state = 0;`来触发状态变更