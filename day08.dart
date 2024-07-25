
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/list_extensions.dart';
import 'utils/string_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/xrange.dart';

final rectP = seq2(number.before('rect'), number.before('x'))
  .map((m) => RectOperation(m.$1, m.$2) as DisplayOperation);

final rrP = seq2(number.before('rotate row y='), number.before('by'))
  .map((m) => RotateRowOperation(m.$1, m.$2) as DisplayOperation);

final rrC = seq2(number.before('rotate column x='), number.before('by'))
  .map((m) => RotateColumnOperation(m.$1, m.$2) as DisplayOperation);

final commandP = choice3(rectP, rrP , rrC);

List<DisplayOperation> parse(String input) => commandP.allMatches(input).toList();

Future<void> main() async {
  final sample = parse(await getInput('day08.sample'));
  final data = parse(await getInput('day08'));
  group('Day 08', (){
    test('Part 1 sample', () => expect(do1(sample, 7, 3), equals(6)));
    test('Part 1 data', () => expect(do1(data, 50, 6), equals(123)));
  });
}

int do1(List<DisplayOperation> ops, int width, int height) {
  final grid = Iterable.generate(height, (_) => (off * width)).toList();
  final result = ops.fold(grid, (p, c) => c.operate(p));
  for(final y in xrange(height)) {
    print(result[y]);
  }
  return result.flatmap((s) => s.split('')).where((it) => it == on).length;
}

abstract class DisplayOperation {
  List<String> operate(List<String> input);
}

const String on = '█';
const String off = ' ';

class RectOperation extends DisplayOperation {
  final int width;
  final int height;
  
  RectOperation(this.width, this.height);
  
  @override
  List<String> operate(List<String> input) {
    for(final i in xrange(height)) {
      input[i] = on * width + input[i].substring(width);
    }
    return input;
  }
}

class RotateRowOperation extends DisplayOperation {
  final int row;
  final int amount;

  RotateRowOperation(this.row, this.amount);  
  
  @override
  List<String> operate(List<String> input) {
    final l = input[row];
    final n = l.length - amount;
    input[row] = l.substring(n) + l.substring(0, n);
    return input;
  }
}

class RotateColumnOperation extends DisplayOperation {
  final int column;
  final int amount;

  RotateColumnOperation(this.column, this.amount);  
  
  @override
  List<String> operate(List<String> input) {
    final inverted = input.map((it) => it.split('')).toList().invert()
      .map((it) => it.join()).toList();
    return RotateRowOperation(column, amount)
      .operate(inverted)
      .map((it) => it.split(''))
      .toList().invert()
      .map((it) => it.join()).toList();
  }
}