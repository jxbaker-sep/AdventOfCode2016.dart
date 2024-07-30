import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/list_extensions.dart';
import 'utils/position.dart';
import 'utils/string_extensions.dart';

typedef Grid = Map<Position, String>;

Future<void> main() async {
  final sample = parse(await getInput('day24.sample'));
  final data = parse(await getInput('day24'));
  group('Day 24', (){
    group('Part 1', (){
      test('Sample', () => expect(do1(sample), equals(14)));
      test('Data', () => expect(do1(data), equals(470)));
    });
    group('Part 2', (){
      test('Data', () => expect(do1(data, true), equals(720)));
    });
  });
}

// PriorityQueue<T> ezPriorityQueue<T>(int Function(T t) priorityFunction) => PriorityQueue<T>((a,b) => priorityFunction(a) - priorityFunction(b));

int do1(Grid grid, [bool returnTo0 = false]) {
  final distances = getDistances(grid);
  final items = grid.values.where((it) => int.tryParse(it) != null).toSet();

  return items.where((it) => it != '0').toList().permute()
    .map((p) => p.followedBy(returnTo0 ? ['0'] : []).fold((0, '0'), (c, it) => (c.$1 + distances[(c.$2, it)]!, it)).$1)
    .min;
}

Map<(String, String), int> getDistances(Grid grid) {
  final items = grid.values.where((it) => int.tryParse(it) != null).toList();
  final result = <(String, String), int>{};
  for (final pair in items.pairs()) {
    final d = getDistance(pair.$1, pair.$2, grid);
    result[(pair.$1, pair.$2)] = d;
    result[(pair.$2, pair.$1)] = d;
  }
  return result;
}

int getDistance(String a, String b, Grid grid) {
  final start = grid.entries.where((e) => e.value == a).first.key;
  final goal = grid.entries.where((e) => e.value == b).first.key;
  final open = Queue<({int steps, Position p})>();
  final closed = <Position>{start};
  open.add((steps: 0, p: start));
  while (open.isNotEmpty) {
    final current = open.removeFirst();
    for (final neighbor in current.p.orthogonalNeighbors()
      .where((n) => grid.containsKey(n)).where((n) => !closed.contains(n))) {
      if (neighbor == goal) return current.steps + 1;
      closed.add(neighbor);
      open.addLast((steps: current.steps + 1, p: neighbor));
    }
  }
  throw Exception();
}

Grid parse(String s) => s.lines().indexed.flatmap((y) => y.$2.split('').indexed.where((it) => it.$2 != '#').map((x) => (x.$1, y.$1, x.$2)))
  .toMap((it) => Position(it.$1, it.$2), (it) => it.$3);