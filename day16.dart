import 'utils/input.dart';
import 'utils/string_extensions.dart';
import 'utils/test.dart';

Future<void> main() async {
  myTest(do1(20, '10000'), '01100');
  myTest(do1(272, (await getInput('day16')).lines().first), '01110011101111011');
  myTest(do1(35651584, (await getInput('day16')).lines().first), '11001111011000111');
}

String do1(int length, String stateAsString) {
  List<int> state = stateAsString.split('').map(int.parse).toList();
  while (state.length < length) {
    final b = state.reversed.map((i) => i == 1 ? 0 : 1).toList();
    state = state + [0] + b;
  }
  state = state.take(length).toList();
  while (state.length.isEven) {
    var temp = <int>[];
    for (var i = 0; i < state.length; i+=2) {
      temp.add(state[i] == state[i+1] ? 1 : 0);
    }
    state = temp;
  }
  return state.map((i) => '$i').join();
}