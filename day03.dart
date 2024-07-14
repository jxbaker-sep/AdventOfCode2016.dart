import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';

import 'utils/input.dart';
import 'utils/my_string_extensions.dart';
import 'utils/parse_utils.dart' as my;
import 'utils/test.dart';

typedef Triplet = (int, int, int);

final matcher = (
  my.number &
  my.number &
  my.number 
  ).map((m) {
    return (m[0] as int, m[1] as int, m[2] as int);
  });


List<Triplet> parse(String s) {
  return s.lines().map((line) => matcher.allMatches(line).first).toList();
}

Future<void> main() async {
  final data = parse(await getInput('day03'));

  test(data.where(isValid).length, 982);
  test(invert(data).where(isValid).length, 1826);
}

Iterable<Triplet> invert(List<Triplet> data) sync* {
  final folded = data.indexed.groupFoldBy<int, List<Triplet>>((t) => t.$1 ~/ 3, (List<Triplet>? previous, current) {
    if (previous == null) return [current.$2];
    previous.add(current.$2);
    return previous;
  });
  for(final item in folded.values) {
    yield (item[0].$1, item[1].$1, item[2].$1);
    yield (item[0].$2, item[1].$2, item[2].$2);
    yield (item[0].$3, item[1].$3, item[2].$3);
  }
}

bool isValid(Triplet t) {
  return 
    ((t.$1 + t.$2) > t.$3) &&
    ((t.$1 + t.$3) > t.$2) &&
    ((t.$2 + t.$3) > t.$1);
}