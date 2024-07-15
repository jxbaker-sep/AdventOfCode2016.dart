import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';

import 'utils/input.dart';
import 'utils/my_string_extensions.dart';
import 'utils/position.dart';
import 'utils/test.dart';

Future<void> main() async {
  var data = (await getInput('day17')).lines().first;
  test(do1(data).first, 'DDRRUDLRRD');

  test(do1('ihgpwlah').last.length, 370);
  test(do1('kglvqrro').last.length, 492);
  test(do1('ulqzkmiv').last.length, 830);
  test(do1('ulqzkmiv').last.length, 830);
  test(do1(data).last.length, 488);
}

typedef Step = ({Position p, String path});

Iterable<String> do1(String pw) sync* {
  final goal = Position(3, 3);
  final open = PriorityQueue<Step>((a,b) => (a.path.length + a.p.manhattanDistance(goal)) - (b.path.length + b.p.manhattanDistance(goal)));
  open.add((p: Position.Zero, path: ''));

  while (open.isNotEmpty) {
    final current = open.removeFirst();
    for(final neighbor in neighbors(current, pw)) {
      if (neighbor.p == goal) {
        yield current.path + neighbor.direction;
      } else {
        open.add((p: neighbor.p, path: current.path + neighbor.direction));
      }
    }
  }
}

Iterable<({Position p, String direction})> neighbors(Step step, String pw) sync* {
  bool isInBounds(Position p) => p.x >= 0 && p.y >= 0 && p.x < 4 && p.y < 4;
  bool isOpen(String s) => ['b', 'c', 'd', 'e', 'f'].contains(s);
  final code = generateMd5(pw + step.path);
  if (isInBounds(step.p + Vector.North) && isOpen(code[0])) yield (p: step.p + Vector.North, direction: 'U');
  if (isInBounds(step.p + Vector.South) && isOpen(code[1])) yield (p: step.p + Vector.South, direction: 'D');
  if (isInBounds(step.p + Vector.West) && isOpen(code[2])) yield (p: step.p + Vector.West, direction: 'L');
  if (isInBounds(step.p + Vector.East) && isOpen(code[3])) yield (p: step.p + Vector.East, direction: 'R');
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}