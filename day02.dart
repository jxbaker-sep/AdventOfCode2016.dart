import 'utils/input.dart';
import 'utils/string_extensions.dart';
import 'utils/position.dart';
import 'utils/test.dart';

List<List<Vector>> parse(String s) {
  return s.lines().map((line) => line.split('').map((c) {
    switch (c) {
      case 'U': return Vector.North;
      case 'D': return Vector.South;
      case 'L': return Vector.West;
      case 'R': return Vector.East;
      default: throw Exception();
    }
  }).toList()).toList();
}

Future<void> main() async {
  final sample = parse(await getInput('day02.sample'));
  final data = parse(await getInput('day02'));

  myTest(do1(sample), 1985);
  myTest(do1(data), 12578);

  myTest(do2(sample), '5DB3');
  myTest(do2(data), '516DD');

}

int do1(List<List<Vector>> sample) {
  final keypad = [['1','2','3'],['4','5','6'],['7','8','9']];
  final result = sample.fold((p: Position(1,1), code: ''), (previous, current) {
    final p = current.fold(previous.p, (p2, c) {
      final step = p2 + c;
      return Position(step.x.clamp(0, 2), step.y.clamp(0, 2));
    });
    return (p: p, code: previous.code + keypad[p.y][p.x]);
  });
  return int.parse(result.code);
}

String do2(List<List<Vector>> sample) {
  final keypad = {
                                              Position(2,0) : '1',
                         Position(1,1) : '2', Position(2,1) : '3', Position(3,1) : '4',
    Position(0,2) : '5', Position(1,2) : '6', Position(2,2) : '7', Position(3,2) : '8', Position(4,2) : '9',
                         Position(1,3) : 'A', Position(2,3) : 'B', Position(3,3) : 'C',
                                              Position(2,4) : 'D',
  };

  final result = sample.fold((p: Position(0,2), code: ''), (previous, current) {
    final p = current.fold(previous.p, (p2, c) {
      final step = p2 + c;
      if (keypad.containsKey(step)) return step;
      return p2;
    });
    return (p: p, code: previous.code + keypad[p]!);
  });
  return result.code;
}