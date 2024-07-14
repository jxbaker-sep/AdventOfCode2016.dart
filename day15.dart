import 'package:petitparser/petitparser.dart';

import 'utils/input.dart';
import 'utils/my_string_extensions.dart';
import 'utils/parse_utils.dart' as my;
import 'utils/test.dart';

class Poly {
  final int magnitude;
  final int first;

  Poly(this.magnitude, this.first);

  @override
  String toString() => 'Poly($magnitude, $first)';
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
  final sample = parse(await getInput('day15.sample'));
  final data = parse(await getInput('day15'));
  test(do1(sample), 5);
  test(do1([Poly(2,1), Poly(3,2), Poly(5,3)]), 23);
  test(do1(data), 121834);
  test(do1(data + [Poly(11, 11 - (data.length + 1))]), 3208099);
}

int do1(List<Poly> polies) {
  return polies.reduce((a, b) => combine(a, b)).first;
}

Poly combine(Poly p1, Poly p2) {
  final k2 = p2.first - p1.first;
  for(final i in Iterable.generate(p1.magnitude * p2.magnitude, (i)=>i)) {
    if ((p2.magnitude * i + k2) % p1.magnitude == 0) {
      final n1 = (p2.magnitude * i + k2) ~/ p1.magnitude;
      print('$i, ${p1.magnitude}, ${p2.magnitude}');
      return Poly(p1.magnitude * p2.magnitude, p1.magnitude * n1 + p1.first);
    }
  }
  throw Exception();
}