import 'utils/input.dart';
import 'utils/my_string_extensions.dart';
import 'utils/position.dart';
import 'utils/test.dart';

typedef RotatorFunction = Vector Function(Vector v);

class Instruction {
  final RotatorFunction rotator;
  final int m;

  Instruction(this.rotator, this.m);
}

RotatorFunction s2v(String s) {
  switch (s) {
    case "L": return (v) => v.rotateLeft();
    case "R": return (v) => v.rotateRight();
    default: throw Exception('wut?');
  }
}

List<Instruction> parse(String s) => s.lines()[0].split(',').map((it)=>it.trim())
    .map((it) => Instruction(s2v(it[0]), int.parse(it.substring(1)))).toList();

Future<void> main() async {
  final data = parse(await getInput('day01'));

  test(do1(parse('R2, L3')), 5);
  test(do1(parse('R2, R2, R2')), 2);
  test(do1(parse('R5, L5, R5, R3')), 12);
  test(do1(data), 161);

  test(do2(parse('R8, R4, R4, R8')), 4);
  test(do2(data), 0);

}

int do2(Iterable<Instruction> data) {
  var p = Position.Zero;
  var v = Vector.North;
  final pset = <Position>{p};
  for(final current in data) {
    v = current.rotator(v);
    for (final _ in Iterable.generate(current.m)) {
      p = p + v;
      if (!pset.add(p)) return p.manhattanDistance(Position.Zero);
    }
  }
  throw Exception();
}

int do1(Iterable<Instruction> data) {
  return data.fold((p: Position.Zero, v: Vector.North), (previous, current) {
    final v2 = current.rotator(previous.v);
    // print(previous.p + v2 * current.m);
    return (p: previous.p + v2 * current.m, v: v2);
  }).p.manhattanDistance(Position.Zero);
}