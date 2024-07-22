import 'package:petitparser/petitparser.dart';

import 'utils/input.dart';
import 'utils/my_string_extensions.dart';
import 'utils/parse_utils.dart' as my;
import 'utils/test.dart';

class Poly {
  final int magnitude;
  final int offset;

  Poly(this.magnitude, this.offset);

  @override
  String toString() => 'Poly($magnitude, $offset)';
  
  Iterable<int> iter() sync* {
    var x = offset;
    while (true) {
      yield x;
      x += magnitude;
    }
  }
}

final matcher = (
  my.number.skip(before: string("Disc #"), after: string("has")) &
  my.number.skip(after: string("positions; at time=0, it is at position")) &
  my.number.skip(after: string("."))
  ).map((m) {
    final mag = m[1] as int;
    final d = m[0] as int;
    final start = m[2] as int;
    return Poly(m[1] as int, (mag - d - start) % mag);
  });

List<Poly> parse(String s) {
  return s.lines()
    .map((line) => matcher.allMatches(line).first)
  .toList();
}

Future<void> main() async {
  // final sw = Stopwatch();
  // sw.start();
  final sample = parse(await getInput('day15.sample'));
  final data = parse(await getInput('day15'));
  myTest(do1(sample), 5);
  myTest(do1([Poly(2,1), Poly(3,2), Poly(5,3)]), 23);
  myTest(do1(data), 121834);
  myTest(do1(data + [Poly(11, 11 - (data.length + 1))]), 3208099);
  // print(sw.elapsedMilliseconds);
}

int do1(List<Poly> polies) {
  return polies.reduce((a, b) => combine(a, b)).offset;
}

Poly combine(Poly p1, Poly p2) {
  final k2 = p1.offset - p2.offset;
  for(final i in Iterable.generate(p2.magnitude, (i)=>i)) {
    if ((p1.magnitude * i + k2) % p2.magnitude == 0) {
      final n1 = (p1.magnitude * i + k2) ~/ p2.magnitude;
      // print('$i, ${p1.magnitude}, ${p2.magnitude}');
      return Poly(p1.magnitude * p2.magnitude, p2.magnitude * n1 + p2.offset);
    }
  }
  throw Exception();
}

Poly combine2(Poly p1, Poly p2) {
  final offset = intersectionsInAscendingSequences(p1.iter(), p2.iter());
  return Poly(p1.magnitude * p2.magnitude, offset.first);
}

Iterable<int> intersectionsInAscendingSequences(Iterable<int> iter1, Iterable<int> iter2) sync* {
  final it1 = iter1.iterator;
  final it2 = iter2.iterator;

  if (!it1.moveNext() || !it2.moveNext()) return;

  while (true) {
    if (it1.current == it2.current) {
      yield it1.current;
      if (!it1.moveNext() || !it2.moveNext()) return;
    } else if (it1.current < it2.current) {
      if (!it1.moveNext()) return;
    } else {
      if (!it2.moveNext()) return;
    }
  }
}