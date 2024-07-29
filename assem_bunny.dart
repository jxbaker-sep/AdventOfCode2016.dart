

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:either_dart/either.dart';
import 'package:petitparser/petitparser.dart';

import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';

List<AssemBunnyInstruction> parseAssemBunny(String s) => s.lines().map((m) => matcher.allMatches(m).single).toList();

typedef Registers = Map<String, int>;

Registers assemBunnyExecute(Iterable<AssemBunnyInstruction> originalInstructions, [Registers? registerMods]) {
  final instructions = originalInstructions.toList();
  final r = {'a': 0, 'b': 0, 'c': 0, 'd': 0};
  for (final entry in (registerMods ?? {}).entries) {
    r[entry.key] = entry.value;
  }
  var pc = 0;

  bool multiplyOptimize() {
    if (pc < instructions.length - 5) {
      if (instructions[pc + 0] case CopyInstruction(source: var s0, destination: var d0)) 
      if (instructions[pc + 1] case Inc(increment: var i1, destination: var d1)) 
      if (instructions[pc + 2] case Inc(increment: var i2, destination: var d2) when i2 == -1 && d0 == d2) 
      if (instructions[pc + 3] case Jnz(condition: var c3, pcShift: var shift3) when shift3.fold((_) => false, (r) => r == -2) && c3.fold((l) => l == d2, (_) => false)) 
      if (instructions[pc + 4] case Inc(increment: var i4, destination: var d4) when i4 == -1) 
      if (instructions[pc + 5] case Jnz(condition: var c5, pcShift: var shift5) when shift5.fold((_) => false, (r) => r == -5) && c5.fold((l) => l == d4, (_) => false)) {
        // d0 is same as d2, don't need to set
        r[d1] = r[d1]! + i1 * r[d4]! * r.lookup(s0);
        r[d2] = 0;
        r[d4] = 0;
        pc += 6;
        return true;
      }
    }
    return false;
  }

  while (pc < instructions.length) {
    if (multiplyOptimize()) continue;
    final i = instructions[pc];
    if (i is Tgl) {
      final index = pc + r[i.destination]!;
      if (index < instructions.length) instructions[index] = instructions[index].toggle();
      pc += 1;
    } else {
      pc += i.execute(r) ?? 1;
    }
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

class NulledCopyInstruction extends AssemBunnyInstruction {
  final RegisterOrInt source;
  final int destination;

  NulledCopyInstruction(this.source, this.destination);
  
  @override
  int? execute(Registers r) {
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Jnz(source, Right(destination));
}

class CopyInstruction extends AssemBunnyInstruction {
  final RegisterOrInt source;
  final String destination;

  CopyInstruction(this.source, this.destination);
  
  @override
  int? execute(Registers r) {
    r[destination] = r.lookup(source);
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Jnz(source, Left(destination));
}

class Inc extends AssemBunnyInstruction {
  final int increment;
  final String destination;

  Inc(this.increment, this.destination);  
  
  @override
  int? execute(Registers r) {
    r[destination] = r[destination]! + increment;
    return null;
  }
  
  @override
  AssemBunnyInstruction toggle() => Inc(-increment, destination);
}

class Jnz extends AssemBunnyInstruction {
  final RegisterOrInt condition;
  final RegisterOrInt pcShift;

  Jnz(this.condition, this.pcShift);
  
  @override
  int? execute(Registers r) {
    return (r.lookup(condition) != 0) ? r.lookup(pcShift) : null;
  }
  
  @override
  AssemBunnyInstruction toggle() => pcShift.fold((l) => CopyInstruction(condition, l), (r) => NulledCopyInstruction(condition, r));
}

class Tgl extends AssemBunnyInstruction {
  final String destination;

  Tgl(this.destination);
  
  @override
  int? execute(Registers r) {
    throw UnimplementedError();
  }
  
  @override
  AssemBunnyInstruction toggle() => Inc(1, destination);
}

final matcher = [copyLiteralP, copyRegisterP, incP, decP , jnz, tglP].toChoiceParser();
final copyLiteralP = seq2(number.before("cpy"), registerP).map((m) => CopyInstruction(Right(m.$1), m.$2));
final copyRegisterP = seq2(registerP.before("cpy"), registerP).map((m) => CopyInstruction(Left(m.$1), m.$2));
final incP = registerP.before("inc").map((m) => Inc(1, m));
final decP = registerP.before("dec").map((m) => Inc(-1, m));
final tglP = registerP.before("tgl").map((m) => Tgl(m));
final jnz = seq2(registerOrIntP.before("jnz"), registerOrIntP).map((m) => Jnz(m.$1, m.$2));

final registerP = oneOf(['a', 'b', 'c', 'd']);
final registerOrIntP = (registerP | number).map((m) => m is int ? Right<String, int>(m) : Left<String, int>(m as String));