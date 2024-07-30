import 'package:test/test.dart';

import 'assem_bunny.dart';
import 'utils/input.dart';
import 'utils/xrange.dart';

Future<void> main() async {
  final data = parseAssemBunny(await getInput('day25'));
  test('Data 25', () => expect(do1(data), equals(180)));
}

int do1(List<AssemBunnyInstruction> instructions) {
  for(var i in xrange(0xFFFFFF)) {
    if (detectClockSignal(i, instructions)) {
      return i;
    }
  }
  throw Exception();
}

bool detectClockSignal(int i, List<AssemBunnyInstruction> instructions) {
  final List<Registers> signals = [];
  int expected() => signals.length % 2;
  for (final r in assemBunnyIterate(instructions, {RegisterLabel.a: i}).take(0xFFFF)) {
    if (r.out != expected()) return false;
    for(final other in signals) {
      if (other == r) return true;
    }
    signals.add(r);
  }
  throw Exception();
}