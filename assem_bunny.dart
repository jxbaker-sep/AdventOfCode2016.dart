
import 'package:either_dart/either.dart';
import 'package:petitparser/petitparser.dart';

import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';

List<AssemBunnyInstruction> parseAssemBunny(String s) => s.lines().map((m) => matcher.allMatches(m).single).toList();

typedef Registers = Map<String, int>;

Registers assemBunnyExecute(List<AssemBunnyInstruction> instructions, [Registers? initial]) {
  final r = initial ?? {'a': 0, 'b': 0, 'c': 0, 'd': 0};
  var pc = 0;

  while (pc < instructions.length) {
    pc += instructions[pc].execute(r) ?? 1;
  }
  return r;
}

abstract class AssemBunnyInstruction {
  int? execute(Registers r);
  AssemBunnyInstruction toggle();
}

typedef RegisterOrInt = Either<String, int>;

extension on Registers {
  int lookup(RegisterOrInt l) => l.fold((x) => this[x]!, (i) => i);
}

class CopyInstruction extends AssemBunnyInstruction {
  final RegisterOrInt value;
  final RegisterOrInt destination;

  CopyInstruction(this.value, this.destination);
  
  @override
  int? execute(Registers r) {
    if (destination.isLeft) r[destination.left] = r.lookup(value);
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Jnz(value, destination);
}

class Inc extends AssemBunnyInstruction {
  final int value;
  final String destination;

  Inc(this.value, this.destination);  
  
  @override
  int? execute(Registers r) {
    r[destination] = r[destination]! + value;
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Inc(-value, destination);
}

class Jnz extends AssemBunnyInstruction {
  final RegisterOrInt lookup;
  final RegisterOrInt pcShift;

  Jnz(this.lookup, this.pcShift);
  
  @override
  int? execute(Registers r) {
    if (pcShift.isRight) {
      return (r.lookup(lookup) != 0) ? pcShift.right : null;
    }
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => CopyInstruction(lookup, pcShift);
}

final matcher = [copyLiteralP, copyRegisterP, incP, decP, jump , jnz].toChoiceParser();
final copyLiteralP = seq2(number.before("cpy"), registerP).map((m) => CopyInstruction(Right(m.$1), Left(m.$2)));
final copyRegisterP = seq2(registerP.before("cpy"), registerP).map((m) => CopyInstruction(Left(m.$1), Left(m.$2)));
final incP = registerP.before("inc").map((m) => Inc(1, m));
final decP = registerP.before("dec").map((m) => Inc(-1, m));
final jump = seq2(number.before("jnz"), number).map((m) => Jnz(Right(m.$1), Right(m.$2)));
final jnz = seq2(registerP.before("jnz"), number).map((m) => Jnz(Left(m.$1), Right(m.$2)));

final registerP = oneOf(['a', 'b', 'c', 'd']);