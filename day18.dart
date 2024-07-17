import 'package:collection/collection.dart';

import 'utils/input.dart';
import 'utils/my_iterable_extensions.dart';
import 'utils/my_string_extensions.dart';
import 'utils/position.dart';
import 'utils/test.dart';

Future<void> main() async {
  final data = (await getInput('day18')).lines().first;
  
  test(do1('.^^.^.^^^^', 10), 38);
  test(do1(data, 40), 1963);
  test(do1(data, 400000), 20009568);
}

enum Space {
  safe,
  trap
}

final Map<String, List<Space>> _cache = {};

int do1(String initial, int rows) {
  var previous = initial.split('').map((c) => c == '.' ? Space.safe : Space.trap).toList();
  final List<List<Space>> result = [previous];
  for(final _ in Iterable.generate(rows-1)) {
    final key = previous.map((it) => it == Space.safe ? '.' : '^').join();
    final cached = _cache[key];
    if (cached != null) {
      result.add(cached);
      previous = cached;
      continue;
    }
    final List<Space> current = [];

    for(final triplet in ([Space.safe] + previous + [Space.safe]).windows(3)) {
      final trap = 
        (triplet[0] == Space.trap && triplet[1] == Space.trap && triplet[2] == Space.safe) ||
        (triplet[0] == Space.safe && triplet[1] == Space.trap && triplet[2] == Space.trap) ||
        (triplet[0] == Space.trap && triplet[1] == Space.safe && triplet[2] == Space.safe) ||
        (triplet[0] == Space.safe && triplet[1] == Space.safe && triplet[2] == Space.trap);
      current.add(trap ? Space.trap : Space.safe);
    }

    result.add(current);
    previous = current;
    _cache[key] = current;
  }

  return result.flattened.where((c) => c == Space.safe).length;
}