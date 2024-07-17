
import 'dart:collection';

import 'package:collection/collection.dart';

import 'utils/input.dart';
import 'utils/my_iterable_extensions.dart';
import 'utils/my_string_extensions.dart';
import 'utils/test.dart';

typedef Range = ({int start, int stop});

List<Range> parse(String s) => s.lines().map((l) {
  final temp = l.split('-').map(int.parse).toList();
  return (start: temp[0], stop: temp[1]);
}).toList();

Future<void> main() async {
  final data = parse(await getInput('day20'));

  test(do1(data), 17348574);
  test(do2(data), 104);
}

bool isInRange(int value, Range r) => r.start <= value && value <= r.stop;

int do1(List<Range> ranges) {
  var proposed = ranges.map((r) => r.stop + 1).toList();
  for(final range in ranges) {
    proposed = proposed.where((p) => !isInRange(p, range)).toList();
  }
  if (proposed.isNotEmpty) return proposed.min;
  throw Exception();
}

extension on Range {
  bool isLegal() => start <= stop;

  Iterable<Range> excluding(Range other) {
    if (other.stop < start) return [this];
    if (other.start > stop) return [this];
    final r1 = (start: start, stop:other.start-1);
    final r2 = (start: other.stop+1, stop: stop);
    return [r1,r2].where((it) => it.isLegal());
  }
}

int do2(List<Range> ranges) {
  var allowed = <Range>[(start: 0, stop: 4294967295)];
  for (final range in ranges) {
    allowed = allowed.flatmap((allowed1) => allowed1.excluding(range)).toList();
  }
  return allowed.map((it) => it.stop - it.start + 1).sum;
}