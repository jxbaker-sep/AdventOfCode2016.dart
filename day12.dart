
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'utils/input.dart';
import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';

Future<void> main() async {
  final sample = parse(await getInput('day12.sample'));
  final data = parse(await getInput('day12'));
  group("Day 12", (){
    group("Part 1", (){
      test("Sample", () => expect(assemBunnyExecute(sample)['a'], equals(42)));
      test("Data", () => expect(assemBunnyExecute(data)['a'], equals(318020)));
    });
    group("Part 2", (){
      test("Data", () => expect(assemBunnyExecute(data, true)['a'], equals(9227674)));
    });
  });
}

List<dynamic> parse(String s) => s.lines().map((m) => matcher.allMatches(m).single).toList();

typedef Registers = Map<String, int>;

Registers assemBunnyExecute(List<dynamic> instructions, [bool part2 = false]) {
  final r = {'a': 0, 'b': 0, 'c': part2 ? 1 : 0, 'd': 0};
  var pc = 0;

  while (pc < instructions.length) {
    final i = instructions[pc];
    if (i is CopyLiteral) {
      r[i.destination] = i.value;
    } else if (i is CopyRegister) {
      r[i.destination] = r[i.source]!;
    } else if (i is IncRegister) {
      r[i.destination] = r[i.destination]! + i.value;
    } else if (i is Jump) {
      pc += i.pcShift;
      continue;
    } else if (i is Jnz) {
      if (r[i.sourceRegister]! != 0) {
        pc += i.pcShift;
        continue;
      }
    } else {
      throw Exception();
    }
    pc += 1;
  }
  return r;
}

class CopyLiteral {
  final int value;
  final String destination;

  CopyLiteral(this.value, this.destination);
}

class CopyRegister {
  final String source;
  final String destination;

  CopyRegister(this.source, this.destination);
}

class IncRegister {
  final int value;
  final String destination;

  IncRegister(this.value, this.destination);
}

class Jump {
  final int pcShift;

  Jump(this.pcShift);
}

class Jnz {
  final String sourceRegister;
  final int pcShift;

  Jnz(this.sourceRegister, this.pcShift);
}

final matcher = copyLiteralP | copyRegisterP | incP | decP | jump | jnz;
final copyLiteralP = seq2(number.before("cpy"), registerP).map((m) => CopyLiteral(m.$1, m.$2));
final copyRegisterP = seq2(registerP.before("cpy"), registerP).map((m) => CopyRegister(m.$1, m.$2));
final incP = registerP.before("inc").map((m) => IncRegister(1, m));
final decP = registerP.before("dec").map((m) => IncRegister(-1, m));
final jump = number.skip(before: string("jnz") & number).map((m) => Jump(m));
final jnz = seq2(registerP.before("jnz"), number).map((m) => Jnz(m.$1, m.$2));

final registerP = oneOf(['a', 'b', 'c', 'd']);