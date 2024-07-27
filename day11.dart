import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/list_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';

Future<void> main() async {
  final sample = parse(await getInput('day11.sample'));
  final data = parse(await getInput('day11'));

  final extras = [
    (label: "elerium", type: "generator"),
    (label: "elerium", type: "microchip"),
    (label: "dilithium", type: "generator"),
    (label: "dilithium", type: "microchip"),
  ];
  final data2 = data.clone();
  data2[0].addAll(extras);

  group("Day 11", (){
    group("Part 1", (){
      test("Sample", () => expect(do1(sample), equals(11)));
      test("Data", () => expect(do1(data), equals(31)));
    });
    group("Part 2", (){
      test("Data", () => expect(do1(data2), equals(55))); // 07m38s
    });

  });
}

typedef Floors = List<List<LabeledType>>;
typedef SearchItem = ({int elevator, Floors floors, int steps});

extension on Floors {
  Floors clone() => map((m) => m.toList()).toList();
  int distance() => take(4).indexed.map((m) => (3-m.$1) * m.$2.length).sum;
}

extension on SearchItem {
  String get uniqueKey => '$elevator,${floors.map((f) {
    final temp = f.map((i) => '$i').toList();
    temp.sort();
    return temp.join(',');
  }).join(';')}';
}

int do1(Floors startFloors) {
  final totalItems = startFloors.map((m) => m.length).sum;
  final open = PriorityQueue<SearchItem>((a,b) => (a.steps + a.floors.distance() ) - (b.steps + b.floors.distance()));
  open.add((elevator: 0, floors: startFloors.clone(), steps: 0));
  final closed = {open.first.uniqueKey};

  while (open.isNotEmpty) {
    final current = open.removeFirst();
    for (final neighbor in neighbors(current)) {
      if (neighbor.floors[3].length == totalItems) return neighbor.steps;
      if (!closed.add(neighbor.uniqueKey)) continue;
      open.add(neighbor);
    }
  }
  throw Exception();
}

extension on List<LabeledType> {
  bool get isLegal {
    final chips = where((item) => item.type == "microchip").map((it) => it.label).toSet();
    final rtgs = where((item) => item.type == "generator").map((it) => it.label).toSet();
    final truth = rtgs.isEmpty || chips.intersection(rtgs).length == chips.length;
    return truth;
  }
}

Iterable<SearchItem> neighbors(SearchItem current) sync* {
  for(final i in [-1,1]) {
    final nextFloor = current.elevator + i;
    if (nextFloor < 0 || nextFloor >= current.floors.length) continue;
    final items = current.floors[current.elevator];
      for(final item in items) {
        final clone = current.floors.clone();
        clone[current.elevator].remove(item);
        clone[nextFloor].add(item);
        if (clone[nextFloor].isLegal && clone[current.elevator].isLegal) yield (elevator: nextFloor, floors: clone, steps: current.steps + 1);
      }
    for (final (item1, item2) in items.pairs()) {
      final clone = current.floors.clone();
      clone[current.elevator].remove(item1);
      clone[current.elevator].remove(item2);
      clone[nextFloor].add(item1);
      clone[nextFloor].add(item2);
      if (clone[nextFloor].isLegal && clone[current.elevator].isLegal) yield (elevator: nextFloor, floors: clone, steps: current.steps + 1);
    }
  }
}

List<List<LabeledType>> parse(String s) => s.lines().map((line) => matcher.allMatches(line).single).toList();

typedef LabeledType = ({String label, String type});

final matcher = zeroOrMoreThingsP.skip(before: lexical.between('The', 'floor contains')).after('.').end();

final zeroOrMoreThingsP = choice2(oneOrMoreThingsP, string("nothing relevant").map((_) => <LabeledType>[]));

final oneOrMoreThingsP = 
    seq2(oneThingP, 
      choice2(
        oneThingP.before("and").map((m) => [m]),
        seq2(oneThingP.before(', ').star(), oneThingP.before(', and'))
          .map((m) => m.$1 + [m.$2])
      ).optional().map((m) => m ?? [])
    ).map((m) => [m.$1] + m.$2);

final exactlyTwoThingsP = seq2(oneThingP.after("and"), oneThingP)
  .map((m) => [m.$1, m.$2]);

final oneThingP = seq2(lexicalWithDashes.before("a"), typeP)
  .map((m) => (label: m.$1, type: m.$2));

final typeP = oneOf(["generator", "microchip"]);

final lexicalWithDashes = lexical.skip(after: string("-compatible").trim().optional());