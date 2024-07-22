
import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';

import 'utils/input.dart';
import 'utils/position.dart';
import 'utils/test.dart';

final bits = [0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4];

int countOneBits(int n) {
  var result = 0;
  while (n > 0) {
    result += bits[n & 0xF];
    n >>= 4;
  }
  return result;
}

bool isWall(int x, int y, int favnum) {
  final n = x*x + 3*x + 2*x*y + y + y*y + favnum;
  return countOneBits(n).isOdd;
}

Future<void> main() async {
  final data = int.parse(await getInput('day13'));
  myTest(do1(10, Position(7, 4)), 11);
  myTest(do1(data, Position(31, 39)), 82);
  myTest(do2(data, 50), 138); // 239 too high
}

typedef Step = ({Position head, List<Position> steps});

int do1(int favnum, Position end) {
  final knownPositions = <Position, bool>{};
  final open = PriorityQueue<Step>((a, b) => (a.steps.length + a.head.manhattanDistance(end)) - (b.steps.length + b.head.manhattanDistance(end)));
  open.add((head: Position(1, 1), steps: []));
  while (open.isNotEmpty) {
    final current = open.removeFirst();
    for(final next in current.head.orthogonalNeighbors()) {
      if (next == end) return current.steps.length + 1;
      if (current.steps.contains(next)) continue;
      final nextIsWall = knownPositions.putIfAbsent(next, () => isWall(next.x, next.y, favnum));
      if (!nextIsWall) {
        open.add((head: next, steps: current.steps + [next]));
      }
    }
  }
  throw Exception();
}

int do2(int favnum, int maxSteps) {
  final knownPositions = <Position, bool>{};
  final open = PriorityQueue<Step>((a, b) => (a.steps.length) - (b.steps.length));
  final reached = <Position>{Position(1,1)};
  open.add((head: Position(1, 1), steps: []));
  while (open.isNotEmpty) {
    final current = open.removeFirst();
    reached.add(current.head);
    if (current.steps.length >= maxSteps) continue;
    for(final next in current.head.orthogonalNeighbors()) {
      if (next.x < 0 || next.y < 0) continue;
      if (current.steps.contains(next)) continue;
      final nextIsWall = knownPositions.putIfAbsent(next, () => isWall(next.x, next.y, favnum));
      if (!nextIsWall) {
        open.add((head: next, steps: current.steps + [next]));
      }
    }
  }
  return reached.length;
}